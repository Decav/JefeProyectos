## HU-R6.3: Variantes de layout del dungeon Helada (Corredor / Caverna / Salón)

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** Mazmorra / Generación de pisos / R6.3  
**Prioridad:** Alta  
**Estado:** Lista para implementar  
**Tipo:** Mejora de contenido procedural del dungeon  
**Fase GDD:** R6.3 (mejora posterior a R6a/R6b; puede ejecutarse en paralelo con R7)  
**Depende de:** HU-R6a (FloorService, EnemyConfig, EnemyService), HU-R6b (DungeonService, teleport data, run lifecycle), HU-R6.1 (HUD/movimiento)  
**Componentes observados:** `ServerScriptService.Services.FloorService`, `ServerScriptService.Services.DungeonService`, `ReplicatedStorage.Config.EnemyConfig`, HUD de dungeon (piso actual)

---

### **Narrativa (INVEST)**

**Como** jugador,  
**quiero** que cada run de la Helada pueda tener una morfología distinta (corredor estrecho, caverna abierta o salón amplio),  
**para** que las partidas no se sientan siempre iguales y haya variedad de espacio y de combate.

**Como** jugador,  
**quiero** saber qué variante estoy recorriendo,  
**para** entender el tipo de dungeon al que entré y preparar mi forma de jugar.

---

### **Descripción del Requerimiento / Contexto**

El dungeon Helada actual genera siempre el mismo tipo de layout: una fila de salas cuadradas de 60×60 unidas por corredores rectos de 12 de ancho, con variación lateral del seed y decoración aleatoria. La morfología nunca cambia: no existe diferencia entre "corredor", "caverna" o "salón" más allá del azar de la decoración.

Esta HU introduce **3 variantes morfológicas del mismo kit Helada** (mismos materiales, niveles de piso, enemigos y tablas de loot):

| Variante | Sensación | Morfología |
|----------|-----------|------------|
| **Corredor de Escarcha** | Estrecho, directo, claustrofóbico | Salas chicas, corredores largos y angostos, pocos enemigos por pack |
| **Caverna Helada** | Abierta, orgánica, espaciosa | Salas grandes, corredores cortos/amplios, más enemigos por pack, mucha decoración (estalactitas, cristales) |
| **Salón del Invierno** | Amplio, elegante, con columnas | Salas medianas-grandes, techos altos, columnas y antorchas, densidad intermedia |

La variante se decide **aleatoriamente por run** (decisión cerrada con producto): el servidor la elige al iniciar la run y la transporta junto con el resto del teleport data. El jugador no la elige ni la manipula.

Los **niveles de piso se mantienen fijos** (P1 ~4 … P5 ~16) y **no cambian los enemigos, el loot ni el oro** (balance global queda en R8). Lo que cambia es la forma del piso y la densidad de los packs (cuántos enemigos por pack), dentro de un presupuesto acotado por piso.

**Criterio de hecho global:** dos runs con el mismo piso pueden generar morfologías distintas (corredor, caverna o salón) y el jugador ve el nombre de la variante en el HUD junto al piso.

---

### **Especificaciones Técnicas / Contratos de API**

#### **DungeonVariantConfig (nuevo, data-driven)**

Se crea `ReplicatedStorage.Config.DungeonVariantConfig` (ModuleScript) con los parámetros de cada variante. El `FloorService` deja de usar constantes globales hardcodeadas y las toma de la variante activa:

```luau
{
  ["Corredor"] = {
    displayName = "Corredor de Escarcha",
    roomSize = Vector3.new(40, 12, 40),
    corridorWidth = 8,
    corridorLength = 28,
    wallHeight = 12,
    packSizeMin = 1, packSizeMax = 2,
    decor = { pillars = true, stalactites = false, crystals = true, snow = true, cracks = true, torches = true },
  },
  ["Caverna"] = {
    displayName = "Caverna Helada",
    roomSize = Vector3.new(80, 16, 80),
    corridorWidth = 20,
    corridorLength = 12,
    wallHeight = 16,
    packSizeMin = 3, packSizeMax = 5,
    decor = { pillars = false, stalactites = true, crystals = true, snow = true, cracks = true, torches = false },
  },
  ["Salon"] = {
    displayName = "Salón del Invierno",
    roomSize = Vector3.new(70, 14, 70),
    corridorWidth = 16,
    corridorLength = 20,
    wallHeight = 14,
    packSizeMin = 2, packSizeMax = 3,
    decor = { pillars = true, stalactites = false, crystals = true, snow = false, cracks = false, torches = true },
  },
}
```

* Los valores son **defaults orientativos** de diseño; deben vivir en config y poder ajustarse en playtest sin tocar lógica.
* Si falta una variante en config, el servidor rechaza la run o cae a un default seguro (`Corredor`) con warning controlado.
* `roomSize`, `corridorWidth`, `corridorLength` y `wallHeight` alimentan a `createRoom` y `createCorridor` en lugar de las constantes actuales.
* `packSizeMin/Max` definen cuántos enemigos spawnan por pack (ver densidad).
* `decor` habilita/deshabilita tipos de decoración por variante (se parametriza la decoración existente; no se crean mallas nuevas).

#### **Elección de variante (server-authoritative)**

* Al iniciar una run (`DungeonService.StartRun`), el servidor elige la variante **aleatoriamente** (uniforme entre las 3) y la incluye en el teleport data:
  ```luau
  { runId = "...", floorSeed = 12345, dungeonDef = "Helada", partyId = nil, variant = "Caverna" }
  ```
* En el Place Dungeon, `JoinRun` lee `variant` del teleport data y lo pasa a `FloorService.GenerateFloor(floorIndex, seed, parent, variant)`.
* El cliente **no puede elegir ni forzar** la variante: viene del servidor en el teleport data.
* El piso generado guarda la variante en atributos: `floorModel:SetAttribute("Variant", variant)` y `floorModel:SetAttribute("VariantName", displayName)` para HUD y respawn.
* `DebugSpawnFloor` (solo Studio): si no recibe `variant`, la deriva del seed (`floorSeed % 3` o rng del seed) para que QA pueda testear variantes sin tocar teleport.

#### **Densidad de packs por variante**

* Se conserva `EnemyConfig.GetFloorBudget(floorIndex)` como base de nivel y presupuesto por piso.
* La variante ajusta la **cantidad de enemigos por pack** (`packSizeMin/Max`) al llamar a `EnemyService.SpawnPack`.
* El **número de salas de packs por piso** puede ajustarse por variante (o mantenerse según `budget.packs`); el default propuesto conserva `budget.packs` y solo cambia el tamaño de cada pack.
* Límite de seguridad: el total de enemigos spawnados por piso no debe exceder un tope razonable (default orientativo: `budget.packs * packSizeMax`, sin exceder ~20 por piso en MVP) para no degradar la performance.
* Los **niveles de los enemigos, sus plantillas y las tablas de loot no cambian** en esta HU (mismas de R6a; balance final en R8).

#### **Layout por variante**

* **Corredor**: salas de 40×40 en fila con corredores largos (28) y angostos (8). Sensación lineal y directa; packs chicos.
* **Caverna**: salas de 80×80 con corredores cortos (12) y anchos (20), casi contiguas. Mucho espacio para moverse y AoE; decoración densa (estalactitas y cristales); sin columnas ni antorchas (iluminación por cristales).
* **Salón**: salas de 70×70, corredores anchos (16) y techos altos (14), con columnas y antorchas. Estética de palacio de hielo; densidad intermedia.
* La variación lateral por seed se conserva en las tres variantes.
* La **boss room** del piso 5 mantiene su estructura base (plataforma central, luz roja) pero adapta su tamaño al `roomSize` de la variante; la sala de mini-boss de pisos 1–4 usa el mismo tamaño que las salas normales.

#### **Decoración parametrizada**

* Las funciones existentes (`addPillars`, `addStalactites`, `addCrystals`, `addSnowPatches`, `addCracks`, `addTorches`) se parametrizan con el `roomSize` y el flag `decor` de la variante.
* No se crean mallas, meshes ni assets nuevos: la caverna se logra con salas grandes, más estalactitas/cristales y menos paredes divisorias; el salón con columnas, antorchas y techos altos.
* Se mantienen las paletas y materiales actuales del kit Helada (sin cambios de asset en esta HU).

#### **HUD: nombre de variante**

* El HUD del dungeon (piso actual, R6b) muestra la variante junto al piso, por ejemplo: `Piso 2/5 · Caverna Helada`.
* El nombre sale del atributo `VariantName` del `floorModel` (o del estado de run replicado existente); no se crea un RemoteEvent nuevo.
* En el hub, antes de entrar, no se anuncia la variante (es aleatoria por run).

#### **Persistencia y seguridad**

* La variante es parte de la run: al abandonar/desconectar la run termina (GDD §2.7) y no se reanuda; no requiere persistencia adicional en DataStore.
* El servidor controla: elección de variante, seed, avance de piso y spawns. El cliente no puede cambiar la variante ni el seed.
* Un cliente manipulado que intente forzar `variant` en el teleport data local no afecta la run del servidor.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Variante elegida por el servidor**

* **GIVEN** un jugador inicia una run por el portal.
* **WHEN** el servidor crea la run.
* **THEN** el teleport data incluye una `variant` válida (`Corredor`, `Caverna` o `Salon`).
* **AND** el cliente no puede modificarla.

#### **Escenario 2: Variante aleatoria entre runs**

* **GIVEN** varias runs iniciadas.
* **WHEN** se comparan las variantes.
* **THEN** las variantes se reparten entre las 3 opciones (aleatoriedad uniforme).
* **AND** una misma run conserva su variante durante los 5 pisos.

#### **Escenario 3: Morfología de Corredor**

* **GIVEN** una run con variante `Corredor`.
* **WHEN** se genera el piso.
* **THEN** las salas son pequeñas (≈40×40) y los corredores angostos (≈8).
* **AND** los packs tienen 1–2 enemigos.

#### **Escenario 4: Morfología de Caverna**

* **GIVEN** una run con variante `Caverna`.
* **WHEN** se genera el piso.
* **THEN** las salas son grandes (≈80×80) con corredores cortos y anchos.
* **AND** los packs tienen 3–5 enemigos.
* **AND** hay estalactitas y cristales en densidad alta.

#### **Escenario 5: Morfología de Salón**

* **GIVEN** una run con variante `Salon`.
* **WHEN** se genera el piso.
* **THEN** las salas son amplias (≈70×70) con columnas y antorchas.
* **AND** los packs tienen 2–3 enemigos.

#### **Escenario 6: Niveles y loot intactos**

* **GIVEN** cualquier variante.
* **WHEN** se revisa el piso.
* **THEN** el nivel de contenido del piso es el mismo que en R6a (P1 ~4 … P5 ~16).
* **AND** las plantillas de enemigos, tablas de loot y oro no cambian.

#### **Escenario 7: HUD muestra la variante**

* **GIVEN** el jugador dentro de una run.
* **WHEN** mira el HUD del dungeon.
* **THEN** ve el piso actual y el nombre de la variante (ej. `Piso 2/5 · Caverna Helada`).

#### **Escenario 8: Boss room adaptada**

* **GIVEN** el piso 5 de cualquier variante.
* **WHEN** se genera la boss room.
* **THEN** mantiene la plataforma central y el formato actual.
* **AND** su tamaño se adapta al `roomSize` de la variante.

#### **Escenario 9: Debug por seed**

* **GIVEN** el entorno de Studio/test.
* **WHEN** se usa `DebugSpawnFloor` sin `variant`.
* **THEN** la variante se deriva del seed.
* **AND** con el mismo seed+piso se regenera la misma variante y layout.

#### **Escenario 10: Anti-exploit**

* **GIVEN** un cliente intenta forzar una variante o un seed.
* **WHEN** solo manipula estado local.
* **THEN** el servidor ignora el intento.
* **AND** la run continúa con la variante del servidor.

#### **Escenario 11: Performance**

* **GIVEN** una caverna con packs de 5 enemigos y salas de 80×80.
* **WHEN** se genera el piso y se combate.
* **THEN** el total de enemigos por piso se mantiene dentro del límite configurado.
* **AND** no hay errores rojos ni caídas de frames por generación.

#### **Escenario 12: Run completa en cada variante**

* **GIVEN** un jugador en cada variante.
* **WHEN** completa los 5 pisos (o abandona).
* **THEN** el flujo de R6b funciona igual (avance, respawn, exit, teleport).
* **AND** la variante no rompe el respawn en la entrada del piso.

---

### **Comportamiento Visual e Interfaz (UI/UX) / Reglas de Negocio**

* Cada variante debe sentirse distinta al primer vistazo: estrechez vs amplitud vs columnas.
* El nombre de la variante aparece en el HUD del dungeon, junto al piso, sin agregar una ventana nueva.
* La caverna es el espacio para combate a granel (AoE, packs grandes); el corredor es la variante directa y rápida.
* No se anuncia la variante antes de entrar: es sorpresa de la run (decisión de producto).
* Se mantienen paleta, materiales y estética Helada (HU-ASSETS ya aplicada); no hay assets nuevos en esta HU.
* La UI existente conserva `Scale` + `UIAspectRatioConstraint`; el texto de variante reutiliza el estilo del HUD.

---

### **Alcance**

#### Incluye

* `DungeonVariantConfig` data-driven con 3 variantes (Corredor, Caverna, Salón).
* Elección aleatoria de variante por run en `DungeonService` + campo `variant` en teleport data.
* `FloorService.GenerateFloor(floorIndex, seed, parent, variant)`: salas, corredores y alturas parametrizados por variante.
* Densidad de packs por variante (`packSizeMin/Max`) dentro de un presupuesto acotado.
* Decoración parametrizada por variante (columnas, estalactitas, cristales, antorchas, nieve, grietas).
* Boss room adaptada al tamaño de la variante.
* Atributos `Variant`/`VariantName` en el `floorModel` + display en HUD del dungeon.
* Derivación de variante desde el seed en `DebugSpawnFloor` (solo Studio).
* Validación de variante desconocida con default seguro.

#### No incluye

* Biomas nuevos (Volcánica, Viento) ni temas visuales distintos del kit Helada (post-MVP).
* Nuevas plantillas de enemigos, mini-bosses, bosses, loot, oro ni niveles de piso (R8).
* Elección de variante por el jugador en el portal (decisión cerrada: aleatoria por run).
* Mallas orgánicas, meshes, assets o VFX nuevos para la caverna.
* Sistemas de party, matchmaking o cambios a la run lifecycle de R6b.
* Balance de dificultad por variante más allá de la densidad de packs (R8).
* Persistencia de la variante en DataStore (la run no se reanuda).

---

### **Definition of Done (DoD)**

* [ ] Existen 3 variantes configurables en `DungeonVariantConfig`.
* [ ] El servidor elige la variante al iniciar la run y viaja en teleport data.
* [ ] `GenerateFloor` genera morfologías distintas por variante (tamaño de sala, ancho/largo de corredor, altura).
* [ ] La densidad de packs cambia por variante sin romper niveles/loot.
* [ ] El total de enemigos por piso se mantiene dentro del límite.
* [ ] La decoración se parametriza y difiere visiblemente entre variantes.
* [ ] La boss room adapta su tamaño sin perder su formato.
* [ ] El HUD muestra `Piso X/5 · <Variante>`.
* [ ] `DebugSpawnFloor` deriva la variante del seed (Studio).
* [ ] El cliente no puede forzar variante ni seed.
* [ ] Respawn en entrada de piso y flujo completo R6b funcionan en las 3 variantes.
* [ ] Sin errores rojos en generación, combate, respawn y teleport.
* [ ] Se actualizan `PROJECT_ARCHITECTURE` y el registro de la HU/RC al cerrar.
* [ ] Nota `R6.3 completo` en el GDD después de la verificación, no antes.

---

### **Decisiones por defecto R6.3**

| Tema | Default |
|------|---------|
| Número de variantes | 3: Corredor de Escarcha, Caverna Helada, Salón del Invierno |
| Elección | Aleatoria por run (server), viaja en teleport data |
| Corredor | Sala 40×40, corredor ancho 8 / largo 28, packs 1–2 |
| Caverna | Sala 80×80, corredor ancho 20 / largo 12, packs 3–5 |
| Salón | Sala 70×70, corredor ancho 16 / largo 20, packs 2–3 |
| Niveles/loot | Sin cambios (fijos por piso; balance en R8) |
| Límite enemigos/piso | `budget.packs * packSizeMax`, tope ~20 (orientativo) |
| Decoración | Parametrizada por flags; sin assets nuevos |
| Boss room | Formato actual, tamaño según variante |
| HUD | `Piso X/5 · <Variante>` (atributo del floorModel) |
| Debug | Variante derivada del seed si no se especifica |
| Config desconocida | Default seguro `Corredor` + warning |

---

### **Estimación (orientativa)**

2–3 sesiones: módulo de config de variantes, parametrización de salas/corredores/decoración, densidad de packs, integración con teleport data y HUD, y pruebas de las 3 morfologías.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-25 | Creación de HU-R6.3 por falta de variedad morfológica en el dungeon; decisiones cerradas: morfología dentro del kit Helada, variante aleatoria por run, 3 variantes, densidad distinta por variante |