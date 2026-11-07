# HU-R6.52: NPCs ambientales caminando — aldeanos y viajeros (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Mundo / Hub / Ambiente
**Prioridad:** Media — vida ambiental, no bloqueante
**Estado:** Implementada (reporte PO 2026-11-06); QA pendiente
**Tipo:** NPCs ambientales + rutas de caminata (dev)
**Fase GDD:** Hub / Mundo (post-R6.49)
**Depende de:** HU-R6.49 (mapa/Hub y Valgard), HU-ESTETICA-26/27 (pueblo y NPCs), HU-PUBLICAR-04 (separación Hub/Dungeon), `PathfindingService`, `CollectionService`, `Humanoid`, `ASSETS_POLICY`
**Componentes observados:** `Workspace.Valgard`, `CentralPlaza`, `MarketStalls`, `MeadTavern`, `BlacksmithForge`, `ApothecaryShop`, `AuctionVault`, `TrainingYard`, `ExpeditionGuidePost`, `PalisadePerimeter`, `Workspace.AmbientRoutes`, `Workspace.AmbientNpcs`
**No modifica:** vendors, Guía, subasta, dummy, portal, quests, combate, economía, inventario, UI ni dungeon.

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** ver aldeanos caminando por Valgard y viajeros por los caminos,
**para** que el Hub se sienta habitado y con vida entre una dungeon y otra.

**Como** equipo,
**quiero** NPCs ambientales server-owned, no interactivos y no targeteables, con rutas acotadas y bajo costo,
**para** sumar vida sin romper vendors, quests, combate ni rendimiento móvil.

---

### Descripción / Contexto

Valgard y sus caminos necesitan presencia humana. Esta HU agrega **8 aldeanos caminando dentro de Valgard** y **3 viajeros recorriendo los caminos** (Río Escarchado, El Espejo Glacial y Avenida de los Antiguos; sin entrar al Santuario ni a la dungeon):

* Caminan en loops por rutas predefinidas, con pausas cortas en waypoints.
* No interactúan: no tienen `ProximityPrompt`, diálogo, quest, tienda ni icono de misión.
* No son targeteables, no reciben daño letal, no dan loot ni aggro.
* No bloquean vendors, Guía, subasta, dummy, portal, spawn ni caminos.
* Reutilizan rigs R15 y ropa existente; no se genera arte final nuevo.
* El movimiento es server-authoritative; no hay scripts de cliente ni remotes nuevos.

**Criterio de hecho global:** al recorrer Valgard y sus caminos se ven 11 NPCs ambientales caminando de forma natural, sin prompts, sin nameplates, sin target y sin interferir con los sistemas existentes; si se traban o caen, se recuperan sin duplicarse, y no aparecen en `Dungeon_Helada` ni en el Santuario.

---

### Especificaciones Técnicas / Contratos

#### 1. Distribución y rutas

**Total: 11 NPCs** (configurable), repartidos así:

| Grupo | Cantidad | Rutas |
|---|---:|---|
| Aldeanos en Valgard | 8 | 3 loops internos |
| Viajeros en caminos | 3 | 2 loops externos |

**Rutas internas (Valgard):**

1. `Route_Plaza_Market`: `CentralPlaza` → `MarketStalls` → `AuctionVault` → `CentralPlaza` — 3 NPCs.
2. `Route_Plaza_Tavern`: `CentralPlaza` → `MeadTavern` → `BlacksmithForge` → `ApothecaryShop` → `CentralPlaza` — 3 NPCs.
3. `Route_Guide_Training`: `ExpeditionGuidePost` → `TrainingYard` → `PalisadePerimeter` (Puerta Norte) → `CentralPlaza` — 2 NPCs.

**Rutas externas (caminos):**

4. `Route_Road_River`: Puerta Norte → `Río Escarchado` → `El Espejo Glacial` → regreso — 2 NPCs.
5. `Route_Road_Avenue`: Puerta Norte → `Avenida de los Antiguos` (punto de retorno antes del Santuario) → regreso — 1 NPC.

Reglas de ruta:

* Waypoints en `Workspace.AmbientRoutes/<Route>/WaypointNN` como `Part` invisibles, `Anchored=true`, `CanCollide=false`, `CanQuery=false`, `CanTouch=false`.
* Los puntos se colocan sobre terreno caminable, con **4–6 studs de separación** de mostradores, prompts, portal, dummy, spawn y NPCs fijos.
* Ninguna ruta entra al `Santuario Glacial de los Antiguos`, arena, portal, dungeon, interiores de casas ni zonas de combate.
* Los viajeros externos dan la vuelta en el último waypoint permitido; no cruzan al Santuario.
* Si un waypoint queda bloqueado por un prop, el NPC lo salta tras reintentar; no se teletransporta salvo recuperación por caída.

#### 2. Modelos y variantes

* Usar **rigs R15 existentes** con `Humanoid`, `Animator`, `HumanoidRootPart` y `PrimaryPart`; sin scripts, sin `ProximityPrompt`, sin armas ni armaduras de combate.
* **4 variantes visuales** de aldeano (ropa/paleta existente) para evitar clones; no crear arte final nuevo. Si el diseñador entrega modelos finales, se reemplazan sin cambiar la lógica.
* Los viajeros pueden usar una variante con capa/mochila existente; no llevar armas para no confundirlos con enemigos.
* Animaciones: walk/idle estándar de R15; si el rig no las trae, copiar el `Animate` estándar o cargar animaciones existentes. No crear animaciones nuevas.
* Nombres de instancia: `ambient_villager_01..08`, `ambient_traveler_01..03`; `CollectionService` tag `AmbientNPC`; atributos `IsAmbient=true`, `RouteId`, `AmbientVariant`.
* Sin nameplate, sin billboard, sin chat, sin icono de misión.

#### 3. Movimiento server-side

* Nuevo `AmbientNpcService` en `ServerScriptService`; solo servidor. No crear remotes ni lógica de cliente.
* Cada NPC recibe un loop propio con `task.spawn` y `task.wait`; prohibido `wait()`.
* Movimiento por waypoints:
  * `Humanoid.WalkSpeed = 8` en Valgard y `10` en caminos (configurable).
  * `Humanoid.JumpPower = 0`; `AutoRotate = true`; sin saltos.
  * `Humanoid:MoveTo(waypoint.Position)`.
  * Esperar `MoveToFinished` o timeout calculado por distancia/velocidad + 3 s.
* Si el movimiento directo falla o se traba:
  * Calcular path con `PathfindingService:CreatePath({AgentRadius=2, AgentHeight=5, AgentCanJump=false, AgentCanClimb=false})`.
  * Seguir los waypoints del path con `MoveTo`; si `PathStatus` no es `Success`, saltar el waypoint tras 2 intentos.
  * Recalcular solo al cambiar de waypoint o al detectar bloqueo; no cada frame.
* Pausa en waypoint: 2–5 s aleatorios; rotación suave opcional; luego continúa.
* Detección de bloqueo: si la posición cambia menos de 0.5 studs en 2 s, reintentar path; tras 3 fallos, volver al waypoint anterior o al inicio de la ruta.
* Detección de caída: si `HumanoidRootPart.Position.Y < FallenPartsDestroyHeight + 10`, recuperar en el waypoint más cercano de su ruta; sin duplicar el NPC.
* Limpieza: desconectar `MoveToFinished`, `Died`, `AncestryChanged` y cualquier conexión al destruir el NPC; sin loops huérfanos.
* Gate por place: si no existe `Workspace.AmbientRoutes` o `Workspace.Valgard`, el servicio no arranca (por ejemplo, en `Dungeon_Helada`).

#### 4. No interacción y no target

* Sin `ProximityPrompt`, sin `ClickDetector`, sin `DialogView`, sin quest giver, sin vendor, sin subasta.
* `Humanoid.DisplayDistanceType = None`; `HealthDisplayType = Never`; sin nameplate.
* `Humanoid.MaxHealth = 1000000`; `Health = MaxHealth`; `BreakJointsOnDeath = false`; si recibe daño, no muere ni dropea.
* No registrar en `EnemyConfig` ni `EnemyService`; no aggro, no loot, no XP.
* Excluir `AmbientNPC` del targeting de skills/click si el sistema targetea cualquier `Humanoid`; validar que AoE y ataques no los seleccionen.
* No colisionar con prompts ni empujar al jugador contra geometría; si hace falta, usar collision group de NPCs ambientales que colisione con el mundo pero no con personajes.

#### 5. Configuración y assets

* `ReplicatedStorage.Config.AmbientNpcConfig`:
  * `routes`: id, waypoints, cantidad de NPCs, velocidad, pausa mínima/máxima, variantes permitidas.
  * `models`: rutas a `ServerStorage.Assets.AmbientNpcs`.
  * `global`: activado, límite de NPCs, distancia de seguridad, timeouts.
* Modelos en `ServerStorage.Assets.AmbientNpcs`; runtime en `Workspace.AmbientNpcs` (Folder).
* No crear ítems, animaciones ni assets finales. Registrar cualquier modelo nuevo en `ASSETS_POLICY`/`ASSETS_REGISTRY`.
* Sin analítica nueva; solo logs de error controlados para depuración (sin spam).

#### 6. Rendimiento y streaming

* Presupuesto: 11 NPCs; sin `RunService.Heartbeat` por NPC; sin raycasts por frame; pathfinding limitado a transiciones/bloqueos.
* No duplicar NPCs al respawnear jugadores, cambiar de servidor ni recargar el Hub.
* Compatible con `StreamingEnabled`: el servidor simula; el cliente solo ve los modelos cuando corresponde; no hay lógica de cliente.
* Objetivo: sin caídas críticas en móvil de gama media; sin errores rojos en consola.
* Si no hay jugadores, los NPCs pueden quedar en pausa idle para no gastar pathfinding; opcional, no obligatorio.

#### 7. UI/UX ambiental

* Los NPCs deben leerse como población civil, no como vendors ni enemigos: sin prompts, sin iconos, sin barras.
* Caminata y pausas naturales; variedad de modelos y colores.
* No tapar el Guía, mostradores, portal, dummy ni subasta; no invadir el spawn.
* Sin minimapa; el jugador los descubre caminando.

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Vida en Valgard

* **GIVEN** el Hub nuevo activo
* **WHEN** el jugador recorre Valgard
* **THEN** ve 8 aldeanos caminando en las rutas internas
* **AND** no hay prompts, iconos de misión ni nameplates

#### Escenario 2: Viajeros en los caminos

* **GIVEN** el jugador sale por la Puerta Norte
* **WHEN** recorre Río Escarchado, El Espejo Glacial y Avenida de los Antiguos
* **THEN** ve hasta 3 viajeros caminando en sus rutas
* **AND** no entran al Santuario, arena, portal ni dungeon

#### Escenario 3: Sin interacción

* **GIVEN** un NPC ambiental
* **WHEN** el jugador se acerca, hace click o toca en móvil
* **THEN** no aparece prompt, diálogo, tienda ni acción
* **AND** el NPC sigue caminando

#### Escenario 4: Sin target ni daño

* **GIVEN** un NPC ambiental
* **WHEN** el jugador lo ataca, usa una skill o AoE
* **THEN** el NPC no es seleccionable, no muere, no da loot ni XP
* **AND** no genera aggro ni afecta el combate

#### Escenario 5: Sin bloquear sistemas

* **GIVEN** vendors, Guía, subasta, dummy, portal y spawn activos
* **WHEN** los NPCs ambientales recorren sus rutas
* **THEN** no bloquean prompts, no se cruzan con el jugador en exceso y no invaden el spawn
* **AND** vendors, quests, portal, subasta y dummy siguen funcionando

#### Escenario 6: Recuperación

* **GIVEN** un NPC trabado o caído
* **WHEN** pasan 2–3 s sin progreso o cae bajo el mapa
* **THEN** recalcula o vuelve al waypoint/Inicio de su ruta
* **AND** no se duplica ni genera errores

#### Escenario 7: Rendimiento y streaming

* **GIVEN** el Hub con 11 NPCs
* **WHEN** se juega en PC y móvil con streaming
* **THEN** no hay errores rojos ni NPCs duplicados
* **AND** el rendimiento se mantiene estable

#### Escenario 8: Sin NPCs en dungeon

* **GIVEN** el place `Dungeon_Helada`
* **WHEN** se carga el servicio
* **THEN** no aparecen NPCs ambientales
* **AND** no hay errores por rutas ausentes

#### Escenario 9: Regresión

* **GIVEN** los NPCs ambientales activos
* **WHEN** se completa el loop hub → dungeon → hub
* **THEN** inventario, oro, quests, vendors, party y combate siguen funcionando
* **AND** no hay errores rojos

---

### Comportamiento Visual / UI-UX

* Los aldeanos deben sentirse parte del mundo: caminan, se detienen, miran y siguen; no son estatuas.
* Variedad suficiente para no parecer clones; sin uniformes de combate.
* Sin elementos de UI sobre ellos; el jugador no debe confundirlos con NPCs interactivos.
* No deben tapar la lectura de prompts, telegraphs, portal ni nameplates de enemigos.
* Sin minimapa ni marcadores; la vida se descubre caminando.

---

### Alcance

#### Incluye

* 8 aldeanos ambientales en Valgard y 3 viajeros en caminos.
* Rutas internas/externas con waypoints, pausas y loops.
* `AmbientNpcService` server-side, `AmbientNpcConfig` y modelos R15 existentes.
* No interacción, no target, no daño letal, no loot, no aggro.
* Recuperación por bloqueo/caída y gate para no aparecer en dungeon.
* QA en PC/móvil y documentación.

#### No incluye

* Diálogos, quests, tiendas, trade o cualquier interacción.
* Combate, loot, XP, facciones o IA de enemigos.
* Arte final, animaciones nuevas, ropa nueva o modelos únicos.
* Horarios, día/noche, multitudes, rutas dinámicas o multitudes por evento.
* Nameplates, chat, voz, minimapa o iconos.
* NPCs en `Dungeon_Helada` o en el Santuario.

---

### Definition of Done (DoD)

* [ ] 8 aldeanos caminando en Valgard y 3 viajeros en los caminos.
* [ ] Rutas con waypoints, pausas y loops; sin entrar al Santuario/dungeon.
* [ ] Sin prompts, diálogos, quests, tiendas ni nameplates.
* [ ] No targeteables, sin daño letal, sin loot, sin aggro.
* [ ] No bloquean vendors, Guía, subasta, dummy, portal ni spawn.
* [ ] Recuperación por bloqueo/caída; sin duplicados ni loops huérfanos.
* [ ] Sin NPCs ambientales en `Dungeon_Helada`.
* [ ] Rendimiento estable en PC/móvil; sin errores rojos.
* [ ] Config y modelos documentados; assets nuevos registrados.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota de cierre en GDD/roadmap.

---

### Decisiones por defecto

| Tema | Default |
|---|---|
| Cantidad | 8 aldeanos + 3 viajeros = 11 |
| Rutas | 3 loops internos + 2 loops externos |
| Modelos | 4 variantes R15 existentes; sin arte final nuevo |
| Movimiento | Waypoints + `PathfindingService` como fallback |
| Velocidad | 8 Valgard / 10 caminos |
| Pausas | 2–5 s por waypoint |
| Interacción | Ninguna |
| Target | Excluido por tag `AmbientNPC` |
| Nameplates | Desactivados |
| Animaciones | Walk/idle R15 existentes |
| Recuperación | Path retry; reset a waypoint/inicio; sin duplicar |
| Place | Solo Hub; no Dungeon_Helada ni Santuario |
| Streaming | Compatible; sin lógica de cliente |
| Analítica | Sin eventos nuevos; solo logs de error |

---

### Estimación (orientativa)

2–3 sesiones del dev: rigs/variantes, rutas, servicio de movimiento, exclusión de target, recuperación, QA móvil y documentación.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-11-05 | Creación de HU-R6.52: NPCs ambientales caminando (8 aldeanos en Valgard + 3 viajeros en caminos), server-side, sin interacción, sin target ni loot, con rutas, pausas, recuperación y gate para no aparecer en dungeon. |
| 2026-11-06 | Implementada (reporte PO 2026-11-06); QA pendiente. |
