# HU-R6.53: Valgard vivo — NPCs con rutinas, microescenas, POIs y coleccionables (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Mundo / Hub / Exploración
**Prioridad:** Media-Alta — percepción de mundo vivo, no bloqueante
**Estado:** Abierta — lista para RC
**Tipo:** Contenido ambiental, POIs y coleccionables (dev)
**Fase GDD:** Hub / Mundo (post-R6.49/R6.52)
**Depende de:** HU-R6.49 (mapa/Hub y Valgard), HU-R6.52 (NPCs ambientales y rutas), HU-R6.31 (notificaciones), `AmbientNpcService`, `CollectionService`, `NotificationService`, `InventoryService`, `DataService`, `ASSETS_POLICY`, HU-ESTETICA-52 (modelos finales; placeholders permitidos)
**Componentes observados:** `Workspace.Valgard`, `CentralPlaza`, `MarketStalls`, `MeadTavern`, `BlacksmithForge`, `ApothecaryShop`, `PalisadePerimeter`, `Río Escarchado`, `El Espejo Glacial`, `Avenida de los Antiguos`, `Workspace.AmbientNpcs`, `Workspace.AmbientRoutes`
**No modifica:** vendors, Guía, subasta, dummy, portal, quests existentes, combate, economía base, inventario, UI núcleo ni dungeon.

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** que Valgard y sus caminos tengan gente, movimiento, sonido y pequeños descubrimientos,
**para** que el mundo se sienta habitado y tenga una razón para recorrerlo sin depender solo de la dungeon.

**Como** equipo,
**quiero** ampliar la vida ambiental con NPCs con roles, microescenas, POIs y coleccionables acotados,
**para** mejorar la percepción del mundo reutilizando los sistemas existentes y sin romper la economía ni el combate.

---

### Descripción / Contexto

La HU-R6.52 ya agregó 8 aldeanos y 3 viajeros caminando. Esta HU completa la **Capa 1 y Capa 2** del plan de mundo vivo:

* **Capa 1 — Valgard vivido:** 9 NPCs nuevos con roles y rutinas + 1 perro; 5 microescenas; props y audio ambiental.
* **Capa 2 — Caminos con algo:** 6 POIs, 8 coleccionables de lore, 2 encuentros ambientales de ruta y fauna pasiva opcional.
* Nada de esto agrega una dungeon, un portal, una quest principal ni una UI nueva; usa movimiento, sonido, pequeños hitos y recompensas existentes.
* Los modelos finales dependen de HU-ESTETICA-52; esta HU puede implementarse con placeholders R15 y props existentes.

**Criterio de hecho global:** al recorrer Valgard y sus caminos hay más movimiento, sonido, landmarks y pequeños descubrimientos; los NPCs no interactivos no bloquean sistemas, los POIs no generan softlocks y los 8 coleccionables se reclaman una sola vez por personaje, con recompensa server-authoritative y persistencia sin duplicados.

---

### Especificaciones Técnicas / Contratos

#### 1. NPCs nuevos y rutinas

**Total nuevo: 9 NPCs humanos + 1 perro** (configurable), además de los 11 de HU-R6.52.

| Actor | Rol | Comportamiento |
|---|---|---|
| `ambient_guard_gate_a` | Guardia de puerta | Idle/patrulla corta en `PalisadePerimeter` |
| `ambient_guard_gate_b` | Guardia de puerta | Idle/patrulla corta en `PalisadePerimeter` |
| `ambient_guard_patrol` | Guardia de patrulla | Loop corto plaza ↔ puerta |
| `ambient_smith_assistant` | Ayudante de herrería | Loop de martillo en `BlacksmithForge` |
| `ambient_alchemist_assistant` | Ayudante de alquimia | Ordena frascos en `ApothecaryShop` |
| `ambient_market_vendor` | Puesto de mercado | Idle/gestos en `MarketStalls` |
| `ambient_tavernkeeper` | Tabernero | Idle/gestos en `MeadTavern` |
| `ambient_child_a` | Niño | Juega/corre cerca de `CentralPlaza` |
| `ambient_child_b` | Niño | Juega/corre cerca de `CentralPlaza` |
| `ambient_dog` | Perro | Sigue a los niños en un radio corto |

Reglas:

* Solo **3 actores nuevos** usan pathfinding (patrulla y dos niños); el perro sigue a los niños por offset simple; el resto son idles/loops cortos para no sumar costo.
* No tienen `ProximityPrompt`, diálogo, quest, tienda, nameplate ni target.
* No bloquean vendors, Guía, subasta, dummy, portal, spawn ni prompts; mantener 4–6 studs de separación.
* Reutilizar rigs R15/animaciones existentes; modelos finales de HU-ESTETICA-52. Sin arte final nuevo en esta HU.
* Los guardias pueden llevar lanza/escudo visual, pero no combaten ni tienen `EnemyConfig`.
* El perro es un rig simple; no combate, no loot, no target; si no hay modelo aprobado, se omite sin bloquear la HU.

#### 2. Microescenas

Implementar 5 microescenas cortas y repetibles, sin interacción:

1. **Herrería:** el ayudante golpea el yunque; chispas con VFX existente; pausa y repite.
2. **Alquimia:** el ayudante ordena frascos; humo suave con partículas existentes.
3. **Puerta:** los guardias cambian de posición o saludan; loop lento.
4. **Plaza:** los niños corren y el perro los sigue; radio acotado; sin cruzar prompts.
5. **Taberna/mercado:** dos NPCs existentes conversan con gestos/idle; sin diálogo ni burbujas.

Reglas:

* Usar animaciones R15 existentes (idle, walk, emote); no crear animaciones nuevas.
* Las microescenas no deben reproducirse si el NPC está lejos del jugador o fuera de streaming; no hay lógica de cliente.
* No bloquear caminos ni generar colisiones con el jugador.
* Sin sonidos nuevos; usar SFX existentes de herrería, fuego, viento y ambiente si están disponibles.

#### 3. Props y audio ambiental

* Agregar 12–15 props de ambientación en Valgard y caminos: banderines, faroles, carros, barriles, cajas, leña, racks de secado, montículos de nieve, carteles, bancos y una fogata.
* Props pequeños: `Anchored=true`, `CanCollide=false`, `CanQuery=false`, `Massless=true`; los grandes pueden colisionar sin bloquear rutas.
* Usar modelos existentes o de HU-ESTETICA-52; no crear arte final en esta HU.
* Audio: zonas de ambiente con SFX existentes (viento, fuego, murmullo, martillo, cuervos); volumen por distancia; una sola instancia por zona.
* Sin cambio global de `Lighting` por jugador; si se agregan partículas de nieve/aurora, deben ser locales y no afectar legibilidad de combate/prompts.
* No minimapa ni iconos nuevos.

#### 4. POIs de caminos

Agregar 6 POIs, sin interiores, portales, carga ni dungeon:

| POI | Contenido | Coleccionable |
|---|---|---|
| `POI_CampamentoViajero` | Carpa, fogata, cajas, banco | `lost_page_01` |
| `POI_CarroVolcado` | Carro roto, carga dispersa | `frost_rune_01` |
| `POI_SantuarioMenor` | Altar pequeño, runas, velas | `frost_rune_02` |
| `POI_CuevaHelada` | Entrada visual de cueva, sin interacción | `lost_page_02` |
| `POI_MiradorLago` | Mirador sobre El Espejo Glacial, banco y cartel | `lost_page_03` |
| `POI_RunaAntigua` | Piedra rúnica grande, nieve y marcas | `frost_rune_03` |

Reglas:

* Ubicados sobre o al borde de los caminos, con 30–60 s de recorrido entre hitos; no tapar la ruta principal.
* Sin enemigos nuevos, sin cofres de loot de combate, sin quest principal, sin softlocks.
* Los POIs se leen como landmarks: silueta, luz, humo o banderín; no usan minimapa.
* El `POI_CuevaHelada` es solo visual; no debe confundirse con una entrada de dungeon ni tener portal.
* Los coleccionables restantes (`frost_rune_04`, `lost_page_04`) se colocan en dos puntos de ruta entre POIs.

#### 5. Coleccionables de lore

* **8 coleccionables únicos:** `frost_rune_01..04` y `lost_page_01..04`.
* **Uno por personaje**, no por cuenta; se guardan en `profile.worldCollectibles` como set/diccionario de IDs.
* Migración: campo nuevo con default `{}`; no borrar datos existentes; actualizar `Schemas.PerfilPersistencia`/`DATA_SCHEMA`.
* Al interactuar con `ProximityPrompt` (E/tap):
  * Validar distancia, que el POI exista, que no esté ya reclamado y que el personaje esté en el Hub.
  * Marcar como reclamado solo después de una operación server-authoritative exitosa.
  * Entregar recompensa configurable: 30 de oro + 15 XP (valores iniciales; ajustar en balance).
  * Mostrar una notificación con el texto de lore usando el sistema existente; sin UI nueva.
  * No agregar ítem al inventario; no crear una moneda ni un sistema de logros nuevo.
* Si ya fue reclamado: no mostrar prompt, no pagar de nuevo, no duplicar en rejoin.
* No se puede reclamar desde dungeon ni a distancia; validar en servidor.
* Si el guardado falla, no entregar la recompensa y reintentar de forma segura; no dejar el flag marcado sin recompensa.
* Sin marcadores en el mundo ni en el mapa; el jugador los descubre caminando.

#### 6. Encuentros ambientales de ruta

* 2 encuentros sin interacción:
  * `Viajero perdido`: NPC sentado/caminando cerca de un POI; no tiene prompt ni quest.
  * `Patrulla de Valgard`: 2 guardias caminando en un tramo del camino; no combaten.
* Sin diálogo, sin recompensa, sin target, sin loot; se pueden omitir si el presupuesto de NPCs se recorta.

#### 7. Fauna pasiva (opcional, condicionada a EST-52)

* Hasta 5 animales: 2 conejos, 2 aves y 1 ciervo; sin combate, sin loot, sin target.
* Comportamiento simple: deambular/huir; sin pathfinding complejo; no bloquear caminos.
* Solo se integra si HU-ESTETICA-52 aprueba los modelos y la performance móvil se mantiene; si no, se difiere.
* No crear modelos nuevos en esta HU.

#### 8. Configuración, datos y rendimiento

* `ReplicatedStorage.Config.WorldLifeConfig`:
  * NPCs nuevos, roles, rutinas, microescenas.
  * POIs, posiciones, coleccionables, textos de lore y recompensas.
  * Props, zonas de audio y límites.
* `Workspace.WorldLife` o carpetas equivalentes para POIs/props runtime; `Workspace.AmbientNpcs` para NPCs.
* `WorldLifeService` server-side para POIs/coleccionables/microescenas; `AmbientNpcService` extendido para roles.
* No nuevos remotes; no lógica de recompensa en cliente.
* Presupuesto: 20 NPCs humanos + 1 perro; solo 12–14 con pathfinding; resto idle/loops. Si QA móvil no cumple, recortar a 16 humanos + perro sin perder las 5 microescenas ni los 6 POIs.
* Sin `RunService.Heartbeat` por NPC; pathfinding solo en transiciones/bloqueos; props pequeños sin colisión; partículas limitadas.
* Sin NPCs/POIs/coleccionables en `Dungeon_Helada`; gate por `Workspace.Valgard`.

#### 9. UI/UX

* Sin HUD nuevo: notificaciones y prompts existentes.
* Sin nameplates, iconos de quest ni marcadores de mapa en NPCs ambientales.
* Los coleccionables usan un prompt claro y una notificación de lore; no abren una ventana nueva.
* Los POIs deben ser visibles por silueta/luz/humo, no por minimapa.
* No tapar prompts, telegraphs, portal, vendors ni nameplates de enemigos.

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Valgard más vivo

* **GIVEN** el Hub activo con HU-R6.52
* **WHEN** el jugador recorre Valgard
* **THEN** ve 9 NPCs nuevos y 1 perro con rutinas o idles creíbles
* **AND** se reproducen al menos 3 de las 5 microescenas
* **AND** ningún NPC nuevo tiene prompt, nameplate, target ni quest

#### Escenario 2: Props y audio

* **GIVEN** el jugador en Valgard
* **WHEN** camina por plaza, mercado, herrería y taberna
* **THEN** ve props de ambientación y escucha SFX ambiental existente
* **AND** no hay bloqueos de ruta ni errores de audio

#### Escenario 3: POIs en los caminos

* **GIVEN** el jugador sale por la Puerta Norte
* **WHEN** recorre los caminos
* **THEN** encuentra 6 POIs visibles y seguros
* **AND** ninguno es una dungeon, portal o zona de combate obligatoria
* **AND** no generan softlocks ni bloquean el camino

#### Escenario 4: Coleccionable nuevo

* **GIVEN** un coleccionable no reclamado y el personaje cerca
* **WHEN** interactúa con el prompt
* **THEN** recibe 30 de oro y 15 XP una sola vez
* **AND** ve una notificación con el lore
* **AND** el coleccionable queda marcado para ese personaje

#### Escenario 5: Sin duplicados

* **GIVEN** un coleccionable ya reclamado
* **WHEN** el jugador vuelve a interactuar o rejoin
* **THEN** no recibe otra recompensa
* **AND** no se duplica el flag ni el oro/XP

#### Escenario 6: Persistencia por personaje

* **GIVEN** dos personajes de la misma cuenta
* **WHEN** uno reclama un coleccionable
* **THEN** el otro puede reclamarlo por separado
* **AND** cada uno conserva su propio estado

#### Escenario 7: Sin acceso desde dungeon

* **GIVEN** el place `Dungeon_Helada`
* **WHEN** se cargan los servicios
* **THEN** no aparecen POIs, coleccionables ni NPCs nuevos
* **AND** no hay errores por configuración ausente

#### Escenario 8: Rendimiento

* **GIVEN** el Hub con NPCs, props, POIs y partículas
* **WHEN** se juega en PC y móvil con streaming
* **THEN** no hay errores rojos ni duplicados
* **AND** el rendimiento se mantiene estable; si no, se recorta el presupuesto según §8

#### Escenario 9: Regresión

* **GIVEN** Valgard vivo implementado
* **WHEN** se juega hub → dungeon → hub, vendors, quests y party
* **THEN** inventario, oro, quests, vendors, subasta, portal y combate siguen funcionando
* **AND** no hay errores rojos

---

### Comportamiento Visual / UI-UX

* El mundo debe sentirse habitado por movimiento, sonido y pequeños hitos, no por acumulación de NPCs estáticos.
* Los POIs deben tener silueta reconocible y una luz/objeto que invite a acercarse.
* Los coleccionables deben ser opcionales y no convertir la exploración en una lista de tareas.
* Nada de UI nueva ni marcadores permanentes; el descubrimiento es parte de la experiencia.
* Sin saturar la pantalla ni tapar prompts, combate o nameplates.

---

### Alcance

#### Incluye

* 9 NPCs nuevos + 1 perro con roles, idles y rutinas.
* 5 microescenas de ambientación.
* 12–15 props y audio ambiental existente.
* 6 POIs en caminos, sin dungeon ni portal.
* 8 coleccionables únicos con recompensa y persistencia por personaje.
* 2 encuentros ambientales de ruta sin interacción.
* Fauna pasiva opcional si EST-52 y performance lo permiten.
* QA PC/móvil y documentación.

#### No incluye

* Nuevos enemigos, combate, loot de combate, world bosses ni eventos dinámicos (Capa 3).
* Nuevas quests principales, quests secundarias complejas ni UI de misiones.
* Nuevos modelos finales, animaciones nuevas o arte definitivo; eso es HU-ESTETICA-52.
* Dungeons, portales, interiores nuevos o mapas nuevos.
* Minimapa, iconos de mapa, nameplates o marcadores permanentes.
* Cambios globales de `Lighting` por jugador, clima con gameplay o día/noche sistémico.
* Cambios a vendors, Guía, subasta, portal, economía base, stats o balance de combate.

---

### Definition of Done (DoD)

* [ ] 9 NPCs nuevos + perro con roles y rutinas; 5 microescenas.
* [ ] Props y audio ambiental sin bloquear rutas.
* [ ] 6 POIs de camino, sin dungeon/portal/softlocks.
* [ ] 8 coleccionables únicos, uno por personaje, con recompensa y persistencia.
* [ ] Reclamo server-authoritative, sin duplicados en rejoin.
* [ ] `profile.worldCollectibles` migrado con default `{}`; sin pérdida de datos.
* [ ] Sin NPCs/POIs/coleccionables en `Dungeon_Helada`.
* [ ] Sin prompts/nameplates/target en NPCs ambientales.
* [ ] Rendimiento estable en PC/móvil; presupuesto respetado.
* [ ] Analítica/QA y documentación.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota de cierre en GDD/roadmap.

---

### Decisiones por defecto

| Tema | Default |
|---|---|
| NPCs nuevos | 6 humanos entregados en Workspace.TestPlace (sin niños ni perros por decisión de PO 2026-11-07) |
| Microescenas | 4 (herrería, alquimia, puerta, taberna/mercado) |
| POIs | 6 |
| Coleccionables | 8 (`frost_rune_01..04`, `lost_page_01..04`) |
| Recompensa | 30 oro + 15 XP por coleccionable |
| Persistencia | `profile.worldCollectibles`; por personaje; default `{}` |
| Reclamo | Server-authoritative; una vez; sin duplicados |
| Fauna / Mascotas | Descartadas explícitamente por el PO |
| Encuentros de ruta | 2 ambientales; sin interacción |
| Audio | SFX existentes; sin assets nuevos |
| Modelos | Modelos y props provistos por diseño en Workspace.TestPlace |
| Place | Solo Hub; no dungeon |
| Rendimiento | 17 humanos civiles totales (11 de rc143 + 6 de rc147); solo 1 nuevo con pathfinding (patrulla) |

---

### Estimación (orientativa)

2–3 sesiones del dev: NPCs/rutinas, microescenas, props/audio, POIs, coleccionables + persistencia, QA móvil y documentación.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-11-06 | Creación de HU-R6.53: Capa 1 y 2 de mundo vivo para Valgard y caminos — 9 NPCs + perro, 5 microescenas, props/audio, 6 POIs, 8 coleccionables de lore con persistencia por personaje y 2 encuentros ambientales. |
| 2026-11-07 | Ajuste PO: descarte de niños y perros. Se fija el alcance en los 6 NPCs y 14 props entregados por diseño en Workspace.TestPlace, con 4 microescenas y 1 solo actor nuevo con pathfinding. |
