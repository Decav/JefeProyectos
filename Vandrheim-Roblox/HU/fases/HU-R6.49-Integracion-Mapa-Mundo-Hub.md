# HU-R6.49: Integración del mapa de mundo y reemplazo del Hub (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Mundo / Hub / Integración
**Prioridad:** Alta — primera impresión y mundo continuo
**Estado:** Implementada (reporte PO 2026-11-06); QA pendiente
**Tipo:** Migración de mapa + integración de sistemas existentes (dev)
**Fase GDD:** Mundo / Hub (post-PoC R6.48; previo a la expansión de biomas)
**Depende de:** HU-R6.48 (PoC aprobada), HU-ESTETICA-26/27/28 (pueblo, NPCs y entrada Helada), HU-R9a.2 (portal/matchmaking), HU-R2/R2.2 (spawn/PJ), HU-R6.10/R6.35 (menú/micromenú), HU-R6.28 (muerte/respawn), HU-R7 (retorno de dungeon), HU-TUTORIAL-02 (prólogo), HU-QUEST-01/02 (quests), `StreamingEnabled`, `Lighting`
**Componentes observados:** `Workspace` del mapa nuevo, `Workspace.Hub` actual, `SpawnLocation`, `VendorConfig`, `VendorService`, NPCs del pueblo, `MatchmakingUI`, `DungeonService`, `CharacterService`, `DataService`, `Lighting`/`Atmosphere`, `WorldPoC`
**No modifica:** contenido de la dungeon, prólogo, combate, ítems, economía, reglas de quests ni balance.

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** aparecer en un pueblo dentro de un mundo continuo y caminar hasta la entrada de la Helada sin pantallas de carga,
**para** sentir que Vandrheim es un lugar y no un conjunto de menús y salas separadas.

**Como** equipo,
**quiero** reemplazar el Hub actual por el mapa nuevo validado en la PoC,
**para** conservar todos los sistemas existentes y mejorar la primera impresión sin rehacer el juego.

---

### Descripción / Contexto

La PoC `HU-R6.48` validó un mapa de terreno de 2048×2048 con la aldea **Valgard**, el entorno del **Río Escarchado**/ **El Espejo Glacial** y el **Santuario Glacial de los Antiguos**. El PO aprobó ese mapa y quiere que sea el **Hub activo**, reemplazando el Hub actual.

El mapa nuevo ya tiene copias de spawn, vendors, Guía, subasta y portal en una región aislada. Esta HU las promueve a producción, archiva el Hub viejo y conecta todos los servicios existentes. Además agrega **zonas con nombre y banner de entrada** con los nombres oficiales de rc138.

**Criterio de hecho global:** el jugador aparece en el pueblo del mapa nuevo, camina hasta la Helada sin teleport ni carga, todos los NPCs/vendors/Guía/subasta/portal/matchmaking funcionan como antes, el Hub viejo no es accesible, y las zonas muestran su nombre al entrar; sin duplicados, sin errores rojos y con rendimiento móvil aceptable.

---

### Especificaciones Técnicas / Contratos

#### 1. Promoción del mapa y reemplazo del Hub

* El mapa nuevo pasa a ser la **única zona activa** del place del Hub.
* El Hub viejo se **archiva** (por ejemplo `Workspace.HubArchived` o `ServerStorage.HubArchived`): sin spawn, sin NPCs activos, sin portal y sin acceso para jugadores. Se conserva para rollback.
* La región PoC deja de ser un acceso de debug: se elimina/desactiva `WorldPoC`, el teleport de prueba y el gating de prompts de las copias.
* El spawn del jugador se mueve a `CentralPlaza` de Valgard, orientado hacia el `ExpeditionGuidePost` y la Puerta Norte.
* No debe quedar ningún `SpawnLocation` activo en el Hub viejo.
* No se duplican NPCs, vendors, Guía, subasta ni portal: se usan los del mapa nuevo y se desactivan los del Hub viejo.
* El mapa nuevo usa `StreamingEnabled`; el terreno ya está generado y no se genera en runtime.
* El dev debe auditar referencias a `Workspace.Hub` y actualizarlas al mapa nuevo (o mantener el nombre `Hub` en la nueva carpeta para no romper servicios).

#### 2. Spawn y flujo del jugador

* Al entrar sin personaje: selección/creación normal.
* Al crear/seleccionar personaje: spawn en `CentralPlaza` de Valgard.
* Si viene del prólogo (`prologueStage = town`): spawn en Valgard; el Guía cierra `prologo_caida_vandrheim` y ofrece `intro_helada`.
* Respawn por muerte: entrada del piso si está en dungeon; en hub, spawn de Valgard.
* Retorno desde dungeon: mismo spawn de Valgard.
* Sin teleports adicionales ni pantallas de carga entre Valgard y el Santuario.

#### 3. Sistemas a conectar

* **Spawn:** `CentralPlaza` de Valgard, orientado al `ExpeditionGuidePost` y a la Puerta Norte.
* **Vendors:** Armero en `BlacksmithForge`, Alquimista en `ApothecaryShop`, Entrenador en `TrainingYard`; mismas ventanas y `VendorConfig`.
* **Guía de la Helada:** `ExpeditionGuidePost`; mismo `QuestNpcId`; cierra prólogo y ofrece onboarding/diaria; sin duplicado.
* **Subasta:** NPC y prompts en `AuctionVault`; servicios de economía sin cambios.
* **Mercader Errante:** se agrega en `MarketStalls` (HU-R6.51).
* **Portal/matchmaking:** `GreatRunicIceArch`/`PortalFrame`/`PortalMarker` en el Santuario; `MatchmakingUI` y `R9a.2` sin cambios; inicia el flujo de dungeon.
* **Dummy de entrenamiento:** en `TrainingYard`; sin cambios de combate.
* **Camino a la Helada:** `PalisadePerimeter` Puerta Norte → `Río Escarchado`/`El Espejo Glacial` → `Avenida de los Antiguos` → `Santuario Glacial de los Antiguos`.
* **Muerte/respawn:** `DungeonService`/`CharacterService` siguen funcionando; sin spawn en el Hub viejo.
* **Quests:** tracker/panel/marcadores funcionan en el mapa nuevo; el marcador de “Entrar a la Helada” apunta al portal físico.
* **Prólogo/onboarding:** la secuencia `prólogo → creación → Valgard → Guía → onboarding` se conserva.
* **Auction/Economy/Party/Matchmaking:** sin cambios de reglas; solo se reubican sus accesos.

#### 3.1 Estructuras oficiales de Valgard (rc138)

| Estructura | Uso |
|---|---|
| `ChieftainGreatHall` | Salón comunal / referencia de lore. |
| `MeadTavern` | Taberna social / ambiente. |
| `BlacksmithForge` | Armero. |
| `ApothecaryShop` | Alquimista. |
| `AuctionVault` | Subasta. |
| `TrainingYard` | Entrenador y dummy. |
| `ExpeditionGuidePost` | Guía de la Helada, onboarding y diaria. |
| `CentralPlaza` | Spawn del pueblo. |
| `MarketStalls` | Mercader Errante (R6.51) y puestos de ambiente. |
| `PalisadePerimeter` | Límites; Puerta Norte hacia la Helada. |
| `GreatRunicIceArch` / `PortalFrame` / `PortalMarker` | Portal de la dungeon en el Santuario. |
| `FishermanCottage`, `WoodcutterCottage`, `TurfRoofCottage`, `StreetLanterns` | Ambiente residencial y vial. |
| `Río Escarchado`, `El Espejo Glacial`, `Watermill`, `FishermanPier`, `IceFishingCamp`, `FrozenVikingShipwreck`, `GlacialCrystalSpikes`, `NorseFarmstead`, `NorthSignalBeacon`, `RunicShrines`, `AncientNordicPines` | Ambiente y landmarks del entorno. |

#### 4. Zonas y banner de entrada

* `ZoneConfig` shared con zonas, nombre visible, bounds y prioridad.
* Zonas oficiales de rc138 (configurables):
  1. `Valgard` — aldea; spawn en `CentralPlaza`; subtítulo opcional “Aldea de los Elegidos”.
  2. `Río Escarchado` — curso fluvial y `RiverBridge`.
  3. `El Espejo Glacial` — lago alpino, muelle y campamento de pesca.
  4. `Avenida de los Antiguos` — vía ceremonial de obeliscos.
  5. `Santuario Glacial de los Antiguos` — explanada, `GreatRunicIceArch`, portal y arena.
* Detección server-side: `ZoneService` revisa el `HumanoidRootPart` cada ~0.5 s, resuelve una sola zona activa por prioridad y publica `CurrentZone` en el jugador y un evento `ZoneChanged`.
* El cliente muestra el banner solo cuando cambia la zona; no repite mientras el jugador permanece dentro.
* Histéresis/debounce de ~1 s para evitar spam en bordes.
* Al spawnear se muestra la zona inicial después de una breve espera; al morir/respawnear en la misma zona no se repite.
* El banner no bloquea input, cámara ni combate.
* Nombres en config; no hardcodear en el cliente.

#### 5. UI del banner de zona

* Texto centrado en la parte superior, debajo del topbar/seguro.
* Título grande + subtítulo opcional de una línea.
* Fade in ~0.4 s, hold ~2.5 s, fade out ~0.6 s; una sola instancia; si entra otra zona, reemplaza.
* Colores por zona: Valgard cálido, río/lago frío, Avenida/Santuario azul/blanco.
* PC y móvil (escala, área segura, sin taps).
* Sin modal, sin botón, sin pausa. Usar tipografías/tokens existentes.

#### 6. Iluminación y atmósfera

* El place del mapa nuevo usa un preset global de `Lighting`/`Atmosphere` coherente con el mundo (pueblo + Helada).
* El Santuario puede tener una transición local de atmósfera en cliente (niebla/tono frío) al entrar/salir; no afecta a otros jugadores.
* Prohibido cambiar `Lighting` global desde el servidor según la zona del jugador.
* Mantener legibilidad de nameplates, telegraphs, portal y NPCs.

#### 7. Navegación, límites y rendimiento

* Camino pueblo → Helada transitable, sin saltos obligatorios ni paredes invisibles.
* `El Espejo Glacial` transitable, sin huecos ni caídas.
* Bordes contenidos por montañas/barreras suaves; sin softlocks.
* `StreamingEnabled`; sin generación de terreno en runtime.
* Objetivo móvil de gama media: sin caídas críticas; carga razonable al acercarse a la Helada.
* El spawn y el camino deben quedar a poca distancia del Guía y del portal; no caminatas largas.

#### 8. Rollback y datos

* El Hub viejo archivado permite volver atrás si el mapa nuevo falla.
* No se modifican perfiles, personajes, inventario, quests ni economía.
* Los teleports/returns de dungeon y prólogo apuntan al spawn nuevo.
* Sin cambios en `DataService` salvo los necesarios para spawn/estado de mapa.

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Spawn en Valgard

* **GIVEN** un jugador que crea o selecciona un personaje
* **WHEN** aparece en el Hub
* **THEN** spawna en `CentralPlaza` de Valgard, mirando al Guía/camino
* **AND** no aparece en el Hub viejo

#### Escenario 2: Mundo continuo

* **GIVEN** el jugador en el pueblo
* **WHEN** camina hacia la Helada
* **THEN** llega al portal sin pantallas de carga, teleports ni saltos obligatorios
* **AND** cruza `El Espejo Glacial` sin caerse

#### Escenario 3: NPCs y vendors

* **GIVEN** el jugador en Valgard
* **WHEN** interactúa con vendors, Guía, subasta y dummy
* **THEN** responden como en el Hub anterior
* **AND** no hay NPCs duplicados ni prompts del Hub viejo

#### Escenario 4: Portal y matchmaking

* **GIVEN** el jugador en el Santuario Glacial de los Antiguos
* **WHEN** interactúa con el portal
* **THEN** se abre el flujo de matchmaking/dungeon existente
* **AND** al volver de la dungeon aparece en Valgard

#### Escenario 5: Prólogo y onboarding

* **GIVEN** un jugador que viene del prólogo (`town`)
* **WHEN** aparece en el pueblo
* **THEN** el Guía cierra `prologo_caida_vandrheim` y ofrece `intro_helada`
* **AND** no hay doble onboarding ni NPC duplicado

#### Escenario 6: Zonas y banners

* **GIVEN** el jugador caminando por el mapa
* **WHEN** entra a Valgard, Río Escarchado, El Espejo Glacial, Avenida de los Antiguos o Santuario Glacial de los Antiguos
* **THEN** aparece el banner con el nombre de la zona
* **AND** no se repite mientras permanece en ella
* **AND** el banner no bloquea input/cámara

#### Escenario 7: Cambio de zona con histéresis

* **GIVEN** el jugador en un borde entre zonas
* **WHEN** oscila alrededor del límite
* **THEN** el banner no se spamea
* **AND** se muestra solo cuando la zona cambia de forma estable

#### Escenario 8: Hub viejo inaccesible

* **GIVEN** el jugador en el juego normal
* **WHEN** intenta buscar el Hub viejo
* **THEN** no hay spawn, NPCs activos ni portal accesibles allí

#### Escenario 9: Iluminación

* **GIVEN** el jugador en el pueblo o la Helada
* **WHEN** cruza la zona
* **THEN** la atmósfera local cambia solo para él si aplica
* **AND** el resto de jugadores no se ve afectado

#### Escenario 10: Rendimiento móvil

* **GIVEN** un dispositivo móvil de gama media
* **WHEN** recorre Valgard, camino, El Espejo Glacial y Santuario
* **THEN** no hay caídas críticas de FPS, errores de streaming ni softlocks

#### Escenario 11: Regresión

* **GIVEN** el mapa nuevo activo
* **WHEN** se juega solo/party, hub/dungeon, PC/móvil
* **THEN** combate, loot, XP, inventario, quests, muerte/respawn y matchmaking siguen funcionando
* **AND** no hay errores rojos

---

### Comportamiento Visual / UI-UX

* El pueblo debe leerse como un lugar habitado y seguro; el camino y la Helada, como una progresión natural.
* El Guía y el portal deben ser visibles desde el spawn o a pocos segundos de caminata.
* Banner de zona legible, efímero y no invasivo; una sola instancia.
* Sin minimapa; el mundo y los landmarks guían.
* Mantener la estética Hearthbound Gold y la legibilidad de combate.

---

### Alcance

#### Incluye

* Promoción del mapa PoC a Hub activo y archivo del Hub viejo.
* Spawn, NPCs, vendors, Guía, subasta, dummy y portal/matchmaking en el mapa nuevo.
* Retorno de dungeon y flujo prólogo → creación → pueblo → onboarding.
* `ZoneConfig`, detección de zonas y banner de entrada.
* Iluminación/atmósfera del mundo y transición local de la Helada.
* Navegación, límites, streaming y QA móvil.
* Rollback del Hub viejo.

#### No incluye

* Enemigos de mundo, ácaros de escarcha ni quest diaria (van en HU-R6.50).
* Cambios a dungeon, prólogo, combate, ítems, economía, quests ni balance.
* Nuevos NPCs, nuevas quests, arte final de props o assets.
* Ciclo día/noche, clima dinámico, agua navegable ni minimapa.

---

### Definition of Done (DoD)

* [ ] El mapa nuevo es el único Hub activo; el Hub viejo está archivado e inaccesible.
* [ ] Spawn en `CentralPlaza` de Valgard, orientado al Guía/camino.
* [ ] Vendors, Guía, subasta, dummy y portal funcionan sin duplicados.
* [ ] Camino Valgard → Santuario y `El Espejo Glacial` transitables; sin softlocks.
* [ ] Zonas configuradas y banners funcionando con histéresis.
* [ ] Prólogo, onboarding, quests y retorno de dungeon funcionan.
* [ ] Iluminación/atmósfera correctas; sin afectar a otros jugadores.
* [ ] Rendimiento móvil aceptable; sin errores rojos.
* [ ] Rollback documentado.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Evidencia de QA y actualización de arquitectura/GDD.

---

### Decisiones por defecto

| Tema | Default |
|---|---|
| Hub activo | Mapa nuevo |
| Hub viejo | Archivado, sin spawn/NPCs/portal |
| Spawn | `CentralPlaza` de Valgard, mirando al Guía/camino |
| Zonas | Valgard, Río Escarchado, El Espejo Glacial, Avenida de los Antiguos, Santuario Glacial de los Antiguos |
| Detección | Server-side cada 0.5 s, una zona activa, histéresis 1 s |
| Banner | Título + subtítulo opcional, fade 0.4/2.5/0.6 s, sin input |
| Iluminación | Global del mundo + transición local en Helada |
| Streaming | Activado; terreno pre-generado |
| Rollback | Hub viejo archivado |
| Dependencia de contenido | R6.50 para ácaros/quest diaria |

---

### Estimación (orientativa)

3–5 sesiones del dev: promoción del mapa, spawn, NPCs/servicios, zonas/banners, iluminación, navegación y QA móvil.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-11-04 | Creación de HU-R6.49: integrar el mapa aprobado de R6.48 como Hub activo, archivar el Hub viejo, conectar NPCs/vendors/Guía/subasta/portal y agregar zonas con banner de entrada. |
| 2026-11-06 | Implementada (reporte PO 2026-11-06); QA pendiente. |
