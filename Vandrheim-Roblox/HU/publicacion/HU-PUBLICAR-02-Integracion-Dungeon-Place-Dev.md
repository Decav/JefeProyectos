# HU-PUBLICAR-02: Integración de la dungeon como place aparte — portal cross-place, bootstrap y seguridad (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Publicación / Integración (dev)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Integración de servicios + publicación de place (dev)
**Fase GDD:** Publicación (transversal; complementa el flujo R6b ya implementado)
**Depende de:** HU-R6b (DungeonService: start/join/run/exit con ReservedServer + teleport data), HU-PUBLICAR-01 (Place ID de `Dungeon_Helada` + accesos del PO), HU-R6a (FloorService/EnemyService/XP), HU-R2 (perfil/DataStore), HU-R6.5 (HUD dungeon)
**Componentes observados:** `ServerScriptService.Services` (DungeonService, FloorService, EnemyService, XPService, LootService, DataService), `ReplicatedStorage.Config` (EnemyConfig, LootTables, SkillConfig…), remotes del juego, `StarterGui` (HUD dungeon R6.5/R6.10)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** entrar por el portal del pueblo a una dungeon que corre en **otro place** (servidor reservado), avanzar los 5 pisos y volver al pueblo con lo ganado,
**para** que el flujo publicado funcione igual que en Studio: pueblo → portal → mazmorra → recompensa → pueblo.

**Como** desarrollador,
**quiero** dejar el place `Dungeon_Helada` auto-suficiente (servicios, configs, remotes y arranque) y conectar el portal por teleport cross-place con servidor reservado,
**para** que la run se pruebe publicada sin errores, con el perfil cargado desde los DataStores compartidos.

---

### **Descripción del Requerimiento / Contexto**

El flujo de R6b ya existe en el place del pueblo: `DungeonService.StartRun` → teleport a **ReservedServer** con teleport data (`runId`, `floorSeed`, `dungeonDef`, `partyId`), pisos 1–5, exit/abandon = fin de run con persistencia (DataStore). Lo que falta es:

1. **El place `Dungeon_Helada`** dentro de la misma experiencia (lo crea/publica el PO en HU-PUBLICAR-01) con **todo lo que la dungeon necesita** (árbol propio: servicios, configs, remotes, arranque).
2. **Conectar el portal** al Place ID real (config, no código).
3. **Seguridad y robustez**: teleport validado, datos no sensibles, manejo de errores, perfil cargado desde DataStore (compartido entre places de la misma experiencia).
4. **Prueba publicada** (el teleport cross-place no se prueba en Play Solo).

**Criterio de hecho global:** publicado el juego con los 2 places, el portal lleva al jugador a una run en `Dungeon_Helada` (servidor reservado), el perfil carga en la dungeon, la run avanza/termina/abandona y se vuelve al pueblo con lo ganado, sin errores rojos.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Place `Dungeon_Helada` (bootstrap del lugar)**

* El place nuevo tiene **árbol propio**: replicar en él la estructura que la dungeon necesita (sin duplicar el hub):
  * `ServerScriptService.Services`: DungeonService, FloorService, EnemyService, LootService, XPService, DataService (perfil), CharacterService (si la dungeon lo requiere), servicios de combate existentes (skills, targeting server-side).
  * `ReplicatedStorage.Config`: EnemyConfig, LootTables, SkillConfig, ItemConfig, TalentConfig, ClassConfig, VFXConfig, etc. (los que la dungeon use).
  * Remotes del juego (carpeta/instancias compartidas) — los mismos contratos.
  * `StarterGui`: HUD dungeon (piso actual, Abandonar run), HUD base del jugador, sin ventanas del hub (vendors/pueblo) salvo las necesarias.
  * **Arranque:** al iniciar el servidor reservado, `DungeonService.JoinRun` lee el **teleport data** (server) y genera el piso 1 con el seed; el perfil se carga con el **DataService existente** (DataStores compartidos por la experiencia).
* **Sin duplicar lógica:** los servicios/remotes se copian con sus contratos intactos; si un módulo compartido es grande, se documenta la lista exacta en el RC (evitar duplicación manual de código).

#### **2. Portal → teleport cross-place (server)**

* `DUNGEON_PLACE_ID` en **config** (ej. `ReplicatedStorage.Config.DungeonConfig` con `dungeonPlaceId` + `secureOnly = true`), no hardcodeado en servicios.
* **Place ID real de `Dungeon_Helada` (entregado por el PO 2026-09-18): `125210265978348`**.
* En `DungeonService.StartRun` (existe): reemplazar/ajustar el target por el Place ID real de `Dungeon_Helada`:
  * Recomendado (dev): `TeleportService:TeleportAsync(DUNGEON_PLACE_ID, players, options)` con `options.ShouldReserveServer = true` (servidor reservado nuevo por run).
  * Mantener el teleport data existente: `{ runId, floorSeed, dungeonDef, partyId }` — solo **datos no sensibles** (el seed es visible al cliente; el avance real lo controla el server en la dungeon).
* **Manejo de errores:** si el teleport falla (place no publicado, acceso, etc.), feedback al jugador ("No se pudo entrar a la dungeon, intentá de nuevo") y `RequestEnterDungeon` se rechaza sin estado raro.
* **No usar teleport data para el perfil:** el progreso (XP/loot/oro/puntos) viaja por **DataStore** (R2) y se carga en la dungeon; el teleport data solo lleva runId/seed.

#### **3. Seguridad y accesos**

* **Acceso al place:** `Secure within universe only` (lo configura el PO, HU-PUBLICAR-01) — el servidor de la dungeon **valida** que la entrada vino por teleport del hub (teleport data presente con runId válido); si no hay runId → expulsar/volver al hub (no se puede entrar directo).
* **Seed:** generado/validado en server (ya es así en R6a); el cliente nunca elige seed ni piso.
* **Anti-exploit:** remotes de la dungeon (abandonar, completar) validan contexto de run como hoy.

#### **4. Exit / Abandon / completar (flujo R6b intacto)**

* Completar la run (boss room piso 5) → teleport de vuelta al **pueblo** (Place ID del hub en config) con lo ganado.
* Abandonar / salir del place = fin de run; lo ganado persiste (DataStore); no se reanuda a mitad.
* El HUD dungeon (piso + Abandonar con confirmación) se mantiene.

#### **5. Config del hub**

* `DungeonConfig` en el hub y en la dungeon: `hubPlaceId`, `dungeonPlaceId` (config; el PO entrega los IDs de HU-PUBLICAR-01).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: La dungeon es auto-suficiente**

* **GIVEN** el place `Dungeon_Helada` publicado
* **WHEN** un jugador entra por el portal (servidor reservado)
* **THEN** los servicios/configs/remotes de la dungeon están presentes y el perfil carga desde DataStore
* **AND** el HUD dungeon (piso + Abandonar) funciona

#### **Escenario 2: Teleport cross-place**

* **GIVEN** el portal del pueblo
* **WHEN** el jugador lo interactúa
* **THEN** se teleporta a `Dungeon_Helada` en un **servidor reservado** (instancia propia)
* **AND** el teleport data incluye runId y floorSeed (server)

#### **Escenario 3: Sin entrada directa**

* **GIVEN** el place de la dungeon con *Secure within universe only*
* **WHEN** un cliente intenta entrar directo (sin teleport del hub)
* **THEN** no puede entrar (acceso) o el server rechaza (sin runId válido → vuelta al hub)

#### **Escenario 4: Error de teleport manejado**

* **GIVEN** un teleport que falla (place sin publicar, red, etc.)
* **WHEN** el jugador intenta entrar
* **THEN** recibe feedback claro y puede reintentar
* **AND** no queda en un estado raro (run fantasma)

#### **Escenario 5: Run completa publicada**

* **GIVEN** el juego publicado con los 2 places
* **WHEN** se corre pueblo → portal → 5 pisos → completar/abandonar → volver
* **THEN** no hay errores rojos
* **AND** XP/loot/oro ganados persisten tras rejoin

#### **Escenario 6: Multi-jugador**

* **GIVEN** 2+ jugadores con acceso
* **WHEN** entran por el portal
* **THEN** cada uno tiene su servidor reservado (runs independientes)
* **AND** no se interfieren

---

### **Comportamiento Visual / Reglas de Negocio**

* Es integración/servicios: no cambia reglas de juego, balance ni contenido.
* Los contratos de R6b (remotes, teleport data, persistencia) se conservan; solo cambia el destino del teleport y el bootstrap del place.
* El seed/avance lo controla el server; el teleport data solo lleva datos no sensibles.

---

### **Alcance**

#### Incluye

* Bootstrap del place `Dungeon_Helada` (servicios, configs, remotes, HUD dungeon, arranque con perfil desde DataStore).
* Portal con `DUNGEON_PLACE_ID` en config + `TeleportAsync` con `ShouldReserveServer` (reemplaza el destino interno de R6b).
* Manejo de errores de teleport con feedback.
* Validación de entrada a la dungeon (solo vía teleport del hub con runId).
* Config `hubPlaceId`/`dungeonPlaceId` en ambos places.

#### No incluye

* Cambios de gameplay, balance ni contenido.
* Party real (partyId nil en R6; party = R9).
* Accesos del Creator Dashboard (PO — HU-PUBLICAR-01).
* Reanudar run a mitad (GDD: no).

---

### **Definition of Done (DoD)**

* [ ] Place `Dungeon_Helada` publicado con servicios/configs/remotes/HUD dungeon y arranque que carga el perfil (DataStore).
* [ ] Portal teleporta a `Dungeon_Helada` (servidor reservado) con teleport data {runId, floorSeed, dungeonDef, partyId}.
* [ ] Fallo de teleport → feedback y reintento sin estados raros.
* [ ] Entrada directa a la dungeon rechazada (acceso + validación de runId).
* [ ] Run completa publicada: pueblo → portal → 5 pisos → completar/abandonar → pueblo con lo ganado persistido.
* [ ] 2 jugadores: runs independientes sin interferencias.
* [ ] Sin errores rojos; servicios/remotes sin duplicación de lógica.
* [ ] `DungeonConfig` con place IDs en config (no hardcode).
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Al cerrar: PROJECT_ARCHITECTURE, DATA_SCHEMA y registro HU/RC actualizados; nota en GDD después de QA (con la prueba publicada).

---

### **Decisiones por defecto PUBLICAR-02**

| Tema | Default |
|------|---------|
| Teleport | `TeleportAsync` + `ShouldReserveServer` (recomendado dev); destino = Place ID de `Dungeon_Helada` en config |
| Teleport data | Solo no sensible: runId, floorSeed, dungeonDef, partyId (perfil por DataStore) |
| Acceso dungeon | Secure within universe only (PO) + validación de runId en server |
| Errores | Feedback + reintento; sin run fantasma |
| Bootstrap | Copiar servicios/configs/remotes con contratos intactos (lista exacta en el RC) |

---

### **Estimación (orientativa)**

2–3 sesiones del dev: bootstrap del place + portal cross-place + manejo de errores + prueba publicada con el PO.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-18 | Creación de HU-PUBLICAR-02: integración de la dungeon como place aparte — bootstrap de `Dungeon_Helada`, portal con TeleportAsync + servidor reservado (Place ID en config), validación de entrada, errores con feedback y prueba publicada; contratos de R6b intactos |