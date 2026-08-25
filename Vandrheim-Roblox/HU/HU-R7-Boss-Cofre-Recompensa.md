## HU-R7: Boss del piso 5, cofre, uniques y recompensa

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** Mazmorra / Loot / R7  
**Prioridad:** Crítica  
**Estado:** Lista para implementar  
**Fase GDD:** R7  
**Depende de:** HU-R6a (enemigos, loot, XP, respawn), HU-R6b (run de 5 pisos), HU-R4 (inventario/rareza/BoE), HU-R5 (oro/vendors), HU-R5.1 (skills), HU-R5.2 (stacking)

---

### **Narrativa (INVEST)**

**Como** jugador,  
**quiero** derrotar al boss de la Helada, abrir el cofre final y recibir una recompensa con posibilidad de un ítem único,  
**para** cerrar la run con una meta clara y sentir progresión de loot.

---

### **Descripción del Requerimiento / Contexto**

R6a prepara la sala del piso 5 y R6b permite completar la run al llegar a ella sin boss. R7 reemplaza ese comportamiento: llegar a la boss room **inicia el encuentro**, pero no completa la run. La run solo termina después de derrotar al boss y reclamar el cofre.

El boss debe reutilizar el combate, targeting, daño server, IA y skills existentes. Para el MVP tendrá un ataque básico y una habilidad especial telegráfica simple, sin fases complejas, adds, enrage ni party.

El cofre entrega una recompensa de equipo, con posibilidad configurable de un ítem único de boss. La entrega usa el inventario, persistencia y ventana de recompensa existentes; no hay loot físico en el suelo.

**Criterio de hecho global GDD:** “Derrotar al boss y recibir una recompensa válida”.

---

### **Especificaciones Técnicas / Contratos de API**

#### **BossConfig (data-driven)**

```luau
{
  ["helada_frostwarden"] = {
    name = "Guardián de la Escarcha",
    floorIndex = 5,
    level = 16,
    maxHp = 2000,
    atk = 30,
    matk = 20,
    def = 12,
    mdef = 12,
    xpReward = 500,
    ai = "boss_melee",
    aggroRange = 30,
    special = {
      id = "glacial_impact",
      type = "GroundAoE",
      radius = 8,
      warningSeconds = 1,
      cooldown = 10,
    },
    lootTable = "floor_5_boss",
  },
}
```

* Los números son defaults iniciales de balance; deben vivir en config y poder ajustarse sin cambiar la lógica.
* Nivel del boss: nivel de contenido del piso 5 (~16).
* El boss usa ataque básico melee y una sola especial `GroundAoE` con aviso visual previo.
* No incluye fases, adds, enrage, CC complejo ni habilidades adicionales.

#### **Estado del encuentro**

```luau
{
  runId = "...",
  floorIndex = 5,
  state = "NotStarted" | "Active" | "Defeated",
  bossId = "helada_frostwarden",
  chestState = "Locked" | "Available" | "Claimed",
  rewardClaimed = false,
}
```

* `runId` y el estado son controlados por el server.
* El boss solo puede aparecer una vez por run.
* Entrar a la boss room cambia `NotStarted` → `Active`; no completa la run.
* Al morir el jugador durante el encuentro, R6a lo respawnea en la entrada del piso y el encuentro se reinicia a `NotStarted` con el boss completo.
* Al morir el boss, el estado pasa a `Defeated` y el cofre a `Available`.

#### **Flujo de la run R7**

```text
Entrar a boss room piso 5
  → spawn boss (una vez)
  → boss activo
  → derrotar boss
  → chest Available
  → RequestOpenBossChest
  → server tira recompensa y la entrega
  → reward UI
  → chest Claimed
  → CompleteRun
  → volver al pueblo
```

* Llegar a la sala no invoca `CompleteRun`.
* `CompleteRun` solo es válido cuando `state=Defeated`, `chestState=Claimed` y `rewardClaimed=true`.
* Abandonar/desconectar antes de abrir el cofre mantiene las reglas de R6b: la run termina y no se reanuda; no se entrega la recompensa no reclamada.
* XP del boss obtenida al derrotarlo persiste como cualquier otra recompensa de R6a.

#### **LootTables/floor_5_boss**

La tabla debe ser data-driven y permitir balance posterior:

```luau
{
  ["floor_5_boss"] = {
    guaranteedEquipment = 1,
    minimumRarity = "Rare",
    uniqueChance = 0.20,
    uniquePool = {
      "unique_frost_edge",
      "unique_frostbow",
      "unique_glacial_wand",
    },
    gold = { min = 50, max = 100 },
  },
}
```

* El cofre entrega 1 equipo garantizado con rareza mínima `Rare`.
* `uniqueChance` default inicial: 20%; configurable sin hardcodear.
* Si el roll único tiene éxito, se entrega un template del `uniquePool`; no se agrega un segundo equipo garantizado.
* Los números y probabilidades son orientativos de R7 y pueden balancearse en R8.
* Si el jugador ya posee un unique, puede recibir otro; `unique=true` identifica un ítem nombrado de boss, no una restricción de una unidad por cuenta.

#### **Unique ItemConfig (seed mínimo)**

```luau
{
  ["unique_frost_edge"] = {
    name = "Filo de la Escarcha",
    slot = "MainHand",
    rarity = "Epic",
    levelReq = 16,
    unique = true,
    weaponAffinity = {},
    stats = { ATK = {base = 25, roll = 0} },
    affixes = { "+10 ATK", "+5 CRIT" },
    bindState = "Free",
    iconId = "Icon_Item_unique_frost_edge",
  },
  ["unique_frostbow"] = {
    name = "Arco del Vendaval Helado",
    slot = "MainHand",
    rarity = "Epic",
    levelReq = 16,
    unique = true,
    weaponAffinity = {},
    stats = { ATK = {base = 25, roll = 0} },
    affixes = { "+10 ATK", "+5 CRIT" },
    bindState = "Free",
    iconId = "Icon_Item_unique_frostbow",
  },
  ["unique_glacial_wand"] = {
    name = "Vara del Invierno",
    slot = "MainHand",
    rarity = "Epic",
    levelReq = 16,
    unique = true,
    weaponAffinity = {},
    stats = { MATK = {base = 25, roll = 0} },
    affixes = { "+10 MATK", "+5 CRIT" },
    bindState = "Free",
    iconId = "Icon_Item_unique_glacial_wand",
  },
}
```

* Se reutilizan `ItemService`/`InventoryService` de R4 y la regla BoE: el unique cae `Free` y queda `Bound` al equiparlo.
* La afinidad es un bonus, no un hard-lock de clase.
* Los números de stats son seed orientativo; el template es configurable.

#### **Remotes / intenciones**

| Remote | Dir | Payload | Validación server |
|--------|-----|---------|-------------------|
| `RequestOpenBossChest` | C→S | `{ runId }` | Run actual, piso 5, boss derrotado, cofre disponible, recompensa no reclamada, capacidad válida |
| `BossEncounterState` | S→C | `{ runId, state, bossId, chestState }` | Solo estado de la run actual |
| `BossSpecialTelegraph` | S→C | `{ abilityId, position, radius, warningSeconds }` | Emitido por el boss server-side |
| `RewardPopup` (existente) | S→C | `{ items, gold }` | Solo después de grant confirmado |
| `RequestCompleteRun` (R6b) | S | — | Solo después de cofre reclamado y recompensa persistida |

* El cliente no puede spawnear, matar, completar el boss, abrir el cofre ni elegir el reward.
* La recompensa debe ser idempotente: reintentos no duplican items ni oro.

#### **Capacidad y transacción de recompensa**

* Como el reward garantizado es equipo no stackable, se necesita al menos un slot libre.
* Si la bolsa está llena, `RequestOpenBossChest` se rechaza con feedback y el cofre permanece `Available`.
* El server ejecuta roll → valida capacidad → agrega item/oro → persiste → marca `rewardClaimed` → envía UI → completa la run.
* Si la transacción no puede confirmarse, no se marca el cofre como reclamado.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Llegar a la boss room inicia el encuentro**

* **GIVEN** una run activa en el piso 5
* **WHEN** el jugador entra a la boss room
* **THEN** el server spawnea el boss una sola vez
* **AND** el estado pasa a `Active`
* **AND** la run no se completa al entrar

#### **Escenario 2: Boss con combate existente**

* **GIVEN** el boss está `Active`
* **WHEN** el jugador se encuentra en rango
* **THEN** el boss usa su ataque básico
* **AND** el daño y la selección de objetivo se calculan en server

#### **Escenario 3: Especial telegráfica**

* **GIVEN** la especial del boss está disponible
* **WHEN** el server la activa
* **THEN** el cliente recibe el aviso de posición, radio y tiempo
* **AND** después del aviso el server aplica el daño de área válido
* **AND** el cliente no decide el resultado del ataque

#### **Escenario 4: Derrotar al boss**

* **GIVEN** el boss está `Active`
* **WHEN** recibe daño válido hasta llegar a 0 HP
* **THEN** el server lo marca `Defeated`
* **AND** entrega el XP correspondiente
* **AND** cambia el cofre a `Available`
* **AND** no entrega dos recompensas por la muerte

#### **Escenario 5: Cofre bloqueado antes de la muerte**

* **GIVEN** el boss no está derrotado
* **WHEN** el cliente intenta abrir el cofre
* **THEN** el server rechaza la solicitud
* **AND** no entrega items, oro ni completa la run

#### **Escenario 6: Cofre entrega equipo**

* **GIVEN** el boss está derrotado y el cofre `Available`
* **WHEN** el jugador lo abre con espacio de bolsa
* **THEN** el server genera 1 equipo con rareza mínima Rare
* **AND** lo agrega al inventario
* **AND** muestra nombre, rareza, stats y oro en la ventana de recompensa

#### **Escenario 7: Posibilidad de unique**

* **GIVEN** el roll de `uniqueChance` tiene éxito
* **WHEN** se abre el cofre
* **THEN** se entrega un ítem de `uniquePool` con `unique=true`
* **AND** se respetan sus stats, nivel requerido, icono y regla BoE

#### **Escenario 8: Bolsa llena**

* **GIVEN** la bolsa tiene los 20 slots ocupados
* **WHEN** el jugador intenta abrir el cofre
* **THEN** el server rechaza la apertura por falta de espacio
* **AND** el cofre permanece disponible
* **AND** no se pierde oro, item ni estado de recompensa

#### **Escenario 9: Reclamar recompensa completa la run**

* **GIVEN** el boss fue derrotado y la recompensa fue agregada y persistida
* **WHEN** el server marca el cofre como `Claimed`
* **THEN** marca `rewardClaimed=true`
* **AND** completa la run
* **AND** devuelve al jugador al pueblo con XP, oro e item

#### **Escenario 10: Salir antes de reclamar**

* **GIVEN** el boss fue derrotado pero el cofre sigue `Available`
* **WHEN** el jugador abandona o desconecta
* **THEN** la run termina según R6b
* **AND** no se reanuda la run ni se entrega el reward no reclamado

#### **Escenario 11: Reinicio por muerte**

* **GIVEN** el boss está `Active`
* **WHEN** el jugador muere
* **THEN** respawnea en la entrada del piso según R6a
* **AND** el encuentro vuelve a `NotStarted` con el boss completo
* **AND** no se crea ningún cofre ni recompensa

#### **Escenario 12: Anti-exploit e idempotencia**

* **GIVEN** un cliente intenta matar el boss, abrir el cofre dos veces, modificar el roll o completar desde la sala
* **WHEN** envía solicitudes o modifica su estado local
* **THEN** el server rechaza las operaciones inválidas
* **AND** una recompensa solo puede ser reclamada una vez
* **AND** la run completa no produce errores rojos

---

### **Comportamiento Visual e Interfaz (UI/UX) / Reglas de Negocio**

* La boss room muestra un aviso claro de inicio del encuentro y el nombre/HP del boss.
* La especial muestra un telegraph legible en el suelo antes del daño.
* Al morir el boss, el cofre cambia visualmente a disponible y muestra una interacción clara.
* La ventana de recompensa reutiliza el componente existente y muestra item, rareza, stats, unique y oro.
* Si la bolsa está llena, mostrar “Espacio de bolsa lleno”; el cofre no se consume.
* Al completar, mostrar feedback de run completada antes del regreso al pueblo.
* No hay loot físico en el suelo ni selección entre varias recompensas en R7.

---

### **Alcance**

#### Incluye

* Boss único del piso 5 con config data-driven.
* Spawn, estado y combate del encuentro en la boss room.
* Ataque básico y una especial telegráfica simple.
* Muerte server-authoritative y entrega de XP.
* Cofre disponible después de la muerte.
* Loot table del boss con equipo garantizado y chance de unique.
* Tres templates unique iniciales (espada, arco y varita).
* Integración con InventoryService, Vendor/Loot existentes, stacking, BoE y persistencia.
* Ventana de recompensa existente con datos de R7.
* Completar la run solo después de reclamar la recompensa.
* Validaciones anti-exploit e idempotencia.

#### No incluye

* Party de amigos o loot de grupo (R9).
* Bosses adicionales, fases, adds, enrage o IA compleja.
* Más biomas o dungeons.
* Sistema de elección entre múltiples recompensas.
* Set bonuses, sockets, gems, crafting o trade.
* Balance final de stats/probabilidades (R8).
* Assets artísticos definitivos; usar placeholders o assets disponibles según `ASSETS_POLICY`.

---

### **Definition of Done (DoD)**

* [ ] Llegar a boss room inicia el boss y no completa la run.
* [ ] Boss configurable, server-authoritative y derrotável con combate existente.
* [ ] Especial telegráfica funciona sin que el cliente decida el daño.
* [ ] Boss muerto habilita exactamente un cofre por run.
* [ ] Cofre entrega equipo garantizado con rareza mínima Rare.
* [ ] Chance configurable de unique funciona y entrega los templates definidos.
* [ ] Reward se agrega al inventario y persiste.
* [ ] Bolsa llena mantiene el cofre disponible y no pierde recompensas.
* [ ] Recompensa reclamada completa la run y devuelve al pueblo.
* [ ] Abandonar antes de reclamar termina la run sin reanudación.
* [ ] Muerte del jugador reinicia el encuentro sin duplicar recompensas.
* [ ] Cliente no puede forzar kill, reward, roll ni CompleteRun.
* [ ] No hay duplicación al repetir `RequestOpenBossChest`.
* [ ] Flujo pueblo → 5 pisos → boss → cofre → reward → pueblo sin errores rojos.
* [ ] Nota “R7 completo” en GDD al verificar la implementación.

---

### **Estimación (orientativa)**

3–5 sesiones: boss + encounter state, special telegraph, loot/uniques, cofre, recompensa y regresión de la run completa.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-22 | Creación de HU-R7: boss piso 5, cofre, uniques y recompensa; completa run solo después de reclamar el cofre |
