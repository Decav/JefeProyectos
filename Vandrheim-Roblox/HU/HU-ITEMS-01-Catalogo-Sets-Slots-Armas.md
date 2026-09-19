## HU-ITEMS-01: Ampliación del catálogo de ítems (sets Cazador/Clérigo, joyería) + reglas de armas

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** Ítems / Equipamiento / Catálogo  
**Prioridad:** Alta  
**Estado:** Lista para implementar  
**Tipo:** Ampliación de contenido + ajuste de reglas de equipamiento  
**Fase GDD:** Ítems (extensión transversal; implementación antes/paralela a R8a–R8c)  
**Depende de:** HU-R4 (inventario/equip/BoE/rolls), HU-R5 (vendors/oro), HU-R5.2 (stacking), HU-R6.5 (UI mochila/equipo), HU-ESTETICA-01 (pipeline visual R15), HU-ESTETICA-07 (modelos/iconos del diseñador), HU-R6a (LootTables)  
**Componentes observados:** `ReplicatedStorage.Config.ItemConfig`, `ServerScriptService.Services.InventoryService`, `ServerScriptService.Services.VendorService`, `ServerScriptService.Services.LootService`, `ReplicatedStorage.Assets.Models.Equipment`

---

### **Narrativa (INVEST)**

**Como** jugador,  
**quiero** más variedad de equipo: sets de armadura para Cazador y Clérigo, una varita, un collar y un anillo,  
**para** que mi personaje tenga opciones de build y pueda conseguirlas jugando.

**Como** jugador,  
**quiero** poder empuñar una espada en cada mano (dual wield) y que las armas de dos manos bloqueen el offhand,  
**para** que las decisiones de equipamiento sean reales y distintas entre armas 1H, 2H, escudos y varitas.

---

### **Descripción del Requerimiento / Contexto**

El catálogo actual tiene el set del Paladín (espada 1H, escudo, espadón 2H, casco, pecho, hombreras, piernas, guantes), las pociones HP/MP y el arco del Cazador (EST-05). No existen piezas para Cazador y Clérigo, ni joyería, ni varita. Además, el equipamiento de armas hoy solo permite una 1H + offhand, sin distinción de armas de dos manos ni dual wield.

Esta HU agrega:

1. **Set Cazador (cuero)** — 5 piezas: casco, pecho, hombreras, piernas, guantes.
2. **Set Clérigo (tela)** — 5 piezas: casco, pecho, hombreras, piernas, guantes.
3. **Varita del Clérigo** (arma 1H mágica).
4. **Collar** (slot `Necklace`) y **Anillo** (slot `Ring`) — 1 slot cada uno (GDD §3); **sin modelo visual** (decisión de producto: solo dato + icono).
5. **Reglas de armas**: melee 1H equipable en cada mano (dual wield); armas 2H (espadón, arco) ocupan MainHand + OffHand y bloquean offhand; escudo solo OffHand; varita 1H sin dual (puede llevar escudo).
6. **Obtención seed mínima**: las piezas caen en las LootTables del dungeon y se pueden comprar en vendors, para probarlas en juego.

Los ítems usan la misma lógica de la armadura actual: `ItemConfig` data-driven, stats base + rolls (R4), BoE al equipar, rareza, `levelReq`, stacking desactivado en equipo y referencia visual (`visualModelId`) hacia los assets de `HU-ESTETICA-07`. El balance fino de números queda en R8d.

**Criterio de hecho global:** un jugador puede equipar el set de Cazador o de Clérigo completo, llevar collar y anillo, empuñar dos espadas 1H, o un arma 2H que bloquea el offhand — todo conseguido por loot/vendor y reflejado en el avatar R15.

---

### **Especificaciones Técnicas / Contratos de API**

#### **Reglas de armas (nuevo campo en ItemConfig)**

Se agrega `wieldType` al `ItemConfig` de armas:

```luau
{
  templateId = "paladin_sword_1h",
  slot = "MainHand",
  wieldType = "OneHand",        -- "OneHand" | "TwoHand" | "MainHandOnly" | "OffHand"
  weaponAffinity = {},
}
```

| `wieldType` | Equipable en | Ejemplos |
|-------------|--------------|----------|
| `OneHand` | `MainHand` o `OffHand` (dual) | Espada 1H, maza 1H (armas melee 1H) |
| `TwoHand` | Ocupa `MainHand` + `OffHand` | Espadón 2H, arco, ballesta |
| `MainHandOnly` | Solo `MainHand`; offhand libre (escudo o vacío) | Varita |
| `OffHand` | Solo `OffHand` | Escudo |

Reglas de validación en `InventoryService` (server-authoritative):

* **Equipar 1H en MainHand**: permitido si no hay un arma 2H equipada.
* **Equipar 1H en OffHand**: permitido si el ítem es `OneHand` y no hay un arma 2H equipada.
* **Equipar 2H**: solo si `MainHand` y `OffHand` están vacíos; al equipar ocupa ambos slots.
* **Equipar escudo** (`OffHand`): solo en `OffHand`; no ocupa `MainHand`.
* **Equipar varita** (`MainHandOnly`): solo en `MainHand`; `OffHand` queda libre para escudo.
* **Desequipar un 2H**: libera `MainHand` y `OffHand` al mismo tiempo.
* **Reemplazo**: si hay un 2H equipado, equipar cualquier 1H/escudo/varita es rechazado hasta desequipar el 2H. Si hay 1H en ambas manos, equipar un 2H es rechazado.
* Las validaciones las aplica el servidor; el cliente solo envía intención (`RequestEquipItem`/`RequestUnequipItem` existentes). No se crean RemoteEvents nuevos.
* El campo `weaponAffinity` ya existe en `ItemConfig` (armas): espadas → specs Paladín/Cazador, `hunter_bow` → `Hunter_Assault`/`Hunter_Punteria` (verificado en código). Los templates nuevos de armas definen el suyo: `cleric_wand` → `Cleric_Misericordia`/`Cleric_Colera`.
* Migración de templates existentes (templateIds reales verificados en `ItemConfig`): `sword_apprentice`, `sword_iron`, `sword_knight`, `sword_champion` → `OneHand`; `shield_guard` → `OffHand`; `hunter_bow` → `TwoHand`; `unique_frost_edge` → `OneHand`; `unique_frostbow` → `TwoHand`; `unique_glacial_wand` → `MainHandOnly`.
* Contrato de equip: `RequestEquipItem { instanceId, preferredSlot? }` — **extensión del contrato actual** (hoy es `{ instanceId }`, rc015/rc022/`InventoryClient:475`): `preferredSlot` (`"MainHand"`/`"OffHand"`) es opcional y habilita el dual wield; el servidor lo valida contra el `wieldType` y el estado actual. Sin `preferredSlot`, se usa el slot por defecto del template.
* Arma 2H: la instancia se guarda en `equipment["MainHand"]` y `equipment["OffHand"]` (misma `instanceId`); `recalculateStats` debe sumar la instancia **una sola vez** (dedupe por instanceId) para no duplicar stats; desequipar libera ambos slots y la serialización de la UI lo muestra como un solo ítem 2H.
* Visual dual: `EquipmentVisualService` debe adjuntar la 1H equipada en `OffHand` a la mano izquierda (mapeo slot→mano o campo `offhandAttachTo` en el template), porque hoy `attachTo` apunta a `RightHand` para ambos slots.

#### **Nuevos slots de joyería**

* Los slots `Necklace` (Collar) y `Ring` (Anillo) **ya existen** en `ItemConfig.SLOTS` (9 slots: Helmet, Chest, Shoulders, Legs, Gloves, Ring, Necklace, MainHand, OffHand) y la UI de equipo de R6.5/rc022 ya los muestra: esta HU agrega **templates**, no slots nuevos.
* Se conserva la regla general: cualquier clase puede equipar cualquier armadura y joyería (1 collar + 1 anillo por personaje).
* La UI de equipo mantiene `Scale` + `UIAspectRatioConstraint` y sin romper móvil.

#### **Nuevos templates (ItemConfig seed)**

| Grupo | Templates | Slots | Stats seed (orientativo) | levelReq | Rareza seed |
|-------|-----------|-------|---------------------------|----------|-------------|
| Set Cazador | `hunter_helmet`, `hunter_chest`, `hunter_shoulders`, `hunter_legs`, `hunter_gloves` | Casco, Pecho, Hombreras, Piernas, Guantes | DEF/MDEF moderados; CRIT o ATK leve en piezas | 1 / 5 / 10 / 15 (por pieza) | Verde/Azul |
| Set Clérigo | `cleric_helmet`, `cleric_chest`, `cleric_shoulders`, `cleric_legs`, `cleric_gloves` | Casco, Pecho, Hombreras, Piernas, Guantes | MDEF alto, MATK leve, MaxMP en piezas | 1 / 5 / 10 / 15 (por pieza) | Blanco/Verde |
| Varita | `cleric_wand` | MainHand (`MainHandOnly`) | MATK base | 1 | Blanco |
| Collar | `item_collar` | Necklace | MaxHP/DEF leve | 1 | Blanco/Verde |
| Anillo | `item_ring` | Ring | ATK o CRIT leve | 1 | Blanco/Verde |

* Cada template: `stackable=false`, `maxStack=1`, `bindState` BoE (se liga al equipar, R4), `iconId` e `iconId` de la lista de assets de `HU-ESTETICA-07`/`ASSETS_LIST`, `visualModelId` apuntando a los modelos del diseñador (solo armadura y varita; collar/anillo sin visual).
* Rolls menores (R4) se aplican igual que al set actual; `unique=false`.
* Los números de stats son seed orientativo; el balance final es R8d.

#### **Seed aprobado (PM, 2026-09-15) — valores concretos para rc034**

Sigue el patrón del equipo existente (`sword_*`: ATK 6/2 → 12/5; `chest_leather`: DEF 4/1; piezas Paladín: DEF 2/0 y guantes 1/0).

| Template | levelReq | Rareza | Stats base/roll |
|----------|----------|--------|-----------------|
| `hunter_helmet` | 1 | Uncommon | DEF 2/0 |
| `hunter_gloves` | 5 | Uncommon | DEF 1/0, CRIT 1/0 |
| `hunter_legs` | 10 | Rare | DEF 3/1, CRIT 2/0 |
| `hunter_shoulders` | 10 | Rare | DEF 2/0, ATK 2/1 |
| `hunter_chest` | 15 | Rare | DEF 4/1, MDEF 2/0 |
| `cleric_helmet` | 1 | Common | MDEF 2/0 |
| `cleric_gloves` | 5 | Common | MDEF 1/0, MaxMP 5/0 |
| `cleric_legs` | 10 | Uncommon | MDEF 3/1, MATK 1/0 |
| `cleric_shoulders` | 10 | Uncommon | MDEF 2/0, MaxMP 10/0 |
| `cleric_chest` | 15 | Uncommon | MDEF 4/1, MATK 2/1 |
| `cleric_wand` | 1 | Common | MATK 6/2; `weaponAffinity` = Cleric_Misericordia, Cleric_Colera |
| `item_collar` | 1 | Common | MaxHP 10/5, DEF 1/0 |
| `item_ring` | 1 | Common | ATK 2/1, CRIT 1/0 |

**Pesos de loot** (formato real de `LootTables`: `Entries { templateId, weight }`, pesos bajos ≤ 6 sin tocar `DropChance` de piso ni las tablas de boss):

| Tabla | Entradas nuevas (templateId = weight) |
|-------|----------------------------------------|
| `floor_1` | hunter_helmet 6, cleric_helmet 6, cleric_wand 3, item_collar 3, item_ring 3 |
| `floor_2` | hunter_gloves 5, cleric_gloves 5, cleric_wand 3, item_collar 3, item_ring 3 |
| `floor_3` | hunter_legs 5, hunter_shoulders 4, cleric_legs 4, cleric_shoulders 4, cleric_wand 2, item_collar 2, item_ring 2 |
| `floor_4` | hunter_chest 4, hunter_legs 4, hunter_shoulders 3, cleric_chest 3, cleric_legs 3, cleric_shoulders 3 |
| `floor_5` | hunter_chest 5, cleric_chest 5, hunter_legs 3, cleric_legs 3, item_collar 2, item_ring 2 |

Regla: cada pieza cae en los pisos acordes a su `levelReq` (lvl 1 → pisos 1–2; lvl 5 → 2–3; lvl 10 → 3–4; lvl 15 → 4–5); collar/anillo (lvl 1) aparecen en todos los pisos con peso bajo. Sin cambios en `floor_X_boss` ni en `uniquePool` del piso 5 (R7 intacto).

#### **Obtención (loot/vendor seed mínimo)**

* **LootTables**: se agregan entradas de los sets, varita, collar y anillo a las tablas de piso `floor_1` a `floor_5` (R6a) con chances bajas y `levelReq` acorde al piso (pisos 1–2 piezas lvl 1–5, pisos 3–4 lvl 10–15, piso 5 mezcla).
* **Vendors**: el vendor de armaduras existente (R5) suma piezas de los dos sets + collar + anillo; el vendor de armas suma la varita. Precios seed coherentes con el rango de R5 (se puede ajustar en R8d).
* El flujo de auto-grant y reward UI (R4/R7) se reutiliza sin cambios.

#### **Integración visual**

* `EquipmentVisualService` (EST-01) aplica los `visualModelId` nuevos con el mismo pipeline (Accessory R15 para armadura, HandModel para varita).
* **Collar y anillo no llevan modelo 3D** (decisión de producto 2026-09-15): se equipan como dato con su `iconId`; el avatar no cambia al equiparlos.
* Si un modelo falta (pendiente del diseñador), el ítem conserva fallback/warning controlado (regla EST-01) y sigue siendo equipable como dato.

#### **Seguridad y autoridad**

* El servidor valida: `wieldType`, slots ocupados, nivel, propiedad, BoE, rareza y capacidad.
* El cliente no puede equipar 2H con offhand ocupado, ni varita en offhand, ni escudo en mainhand, ni duplicar collar/anillo.
* No se aceptan slots, wieldType ni stats inventados desde el cliente; todo sale de `ItemConfig` y profile.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Dual wield de espadas 1H**

* **GIVEN** el jugador tiene dos espadas 1H (`OneHand`).
* **WHEN** equipa la primera en `MainHand` y la segunda en `OffHand`.
* **THEN** ambas quedan equipadas y visibles en el avatar (derecha e izquierda).
* **AND** las stats de ambas se aplican.

#### **Escenario 2: Arma 2H bloquea offhand**

* **GIVEN** el jugador equipa un espadón o arco (`TwoHand`).
* **WHEN** intenta equipar un escudo o una 1H en `OffHand`.
* **THEN** el servidor rechaza la operación.
* **AND** al desequipar el 2H, `MainHand` y `OffHand` quedan libres.

#### **Escenario 3: No se equipa 2H con offhand ocupado**

* **GIVEN** el jugador tiene una 1H en `OffHand`.
* **WHEN** intenta equipar un arma 2H.
* **THEN** el servidor rechaza hasta desequipar el offhand.

#### **Escenario 4: Escudo solo en offhand**

* **GIVEN** un escudo (`OffHand`).
* **WHEN** el jugador intenta equiparlo en `MainHand`.
* **THEN** el servidor rechaza.
* **AND** sí se equipa en `OffHand`.

#### **Escenario 5: Varita 1H sin dual**

* **GIVEN** una varita (`MainHandOnly`).
* **WHEN** el jugador la equipa en `MainHand`.
* **THEN** se equipa correctamente y puede llevar escudo en `OffHand`.
* **AND** no puede equipar una segunda varita en `OffHand`.

#### **Escenario 6: Set Cazador completo**

* **GIVEN** el jugador tiene las 5 piezas del set Cazador.
* **WHEN** las equipa en sus slots.
* **THEN** todas se equipan con sus stats (DEF/MDEF + CRIT/ATK).
* **AND** el avatar muestra el set de cuero (visuales de EST-07).

#### **Escenario 7: Set Clérigo completo**

* **GIVEN** el jugador tiene las 5 piezas del set Clérigo.
* **WHEN** las equipa.
* **THEN** se equipan con sus stats (MDEF + MATK/MaxMP).
* **AND** el avatar muestra el set de tela.

#### **Escenario 8: Collar y anillo**

* **GIVEN** el jugador tiene un collar y un anillo.
* **WHEN** los equipa.
* **THEN** cada uno ocupa su slot (`Necklace`, `Ring`), uno por personaje.
* **AND** sus stats se aplican, sin modelo visual en el avatar (decisión de producto: solo dato + icono).

#### **Escenario 9: Obtención por loot**

* **GIVEN** el jugador mata enemigos en el dungeon.
* **WHEN** caen piezas de los sets, varita, collar o anillo.
* **THEN** van al inventario con el flujo de auto-grant existente.
* **AND** respetan `levelReq` y rareza de la tabla del piso.

#### **Escenario 10: Obtención por vendor**

* **GIVEN** el jugador tiene oro.
* **WHEN** compra piezas en el vendor de armaduras/armas.
* **THEN** la transacción usa el flujo R5/R5.2 (stacking y oro).
* **AND** el ítem queda en la bolsa con sus reglas normales.

#### **Escenario 11: BoE y desequipar**

* **GIVEN** el jugador equipa una pieza nueva.
* **WHEN** la equipa.
* **THEN** queda `Bound` al personaje (BoE, R4).
* **AND** al desequipar vuelve a la bolsa ligada, sin duplicarse ni perderse.

#### **Escenario 12: Anti-exploit**

* **GIVEN** un cliente intenta equipar 2H con offhand ocupado, varita en offhand, escudo en mainhand, o duplicar collar/anillo.
* **WHEN** envía `RequestEquipItem` manipulado.
* **THEN** el servidor rechaza.
* **AND** el profile no se corrompe y no hay errores rojos.

---

### **Comportamiento Visual e Interfaz (UI/UX) / Reglas de Negocio**

* El equipo (R6.5) muestra los huecos de `Necklace` y `Ring` junto a los existentes; la UI se mantiene escalable (Scale + UIAspectRatioConstraint) y usable en móvil.
* Los visuales de los sets se reflejan en el avatar R15 (pipeline EST-01): cuero del Cazador, tela del Clérigo, varita en la mano derecha. El collar y el anillo **no tienen visual** en el avatar.
* El dual wield se ve como dos armas en ambas manos; el 2H como un arma grande en la mano derecha (sin IK de dos manos en esta HU, como EST-01).
* Las reglas de armas son reglas de negocio server-side; la UI solo refleja rechazos con feedback breve ("No podés equipar eso", etc.).
* Sin bonus numérico de dual wield ni penalización en esta HU: es solo equipamiento (balance en R8d).

---

### **Alcance**

#### Incluye

* Campo `wieldType` en `ItemConfig` + migración de templates existentes.
* Reglas de equipamiento server-side: dual 1H, 2H bloquea offhand, escudo solo offhand, varita mainhand-only.
* Slots `Necklace` y `Ring` (1 cada uno) + huecos en la UI de equipo (R6.5).
* 10 templates de armadura nuevos (5 Cazador + 5 Clérigo), varita, collar y anillo con stats seed, `levelReq`, rareza, BoE e `iconId`; `visualModelId` solo para armadura y varita (collar/anillo sin visual).
* Integración con `EquipmentVisualService` (visuales de EST-07 con fallback).
* Entradas seed en LootTables (floor_1–5) y vendors (armaduras/armas) para obtener los ítems.
* Regresión de equip, stats, inventario, vendores, respawn y avatar.

#### No incluye

* Modelos 3D e iconos nuevos (los produce el diseñador en `HU-ESTETICA-07`).
* Sets adicionales, transmog, sets por rareza completa o items únicos nuevos (R7 uniques intactos).
* Bonus/penalización de dual wield, aflicciones o balance de stats (R8d).
* PvP, trade entre jugadores, sockets, gems o crafting.
* Cambios a stacking, cooldowns, vendors de consumibles o economía global.
* Nuevos RemoteEvents; se reutilizan `RequestEquipItem`/`RequestUnequipItem`.

---

### **Definition of Done (DoD)**

* [ ] `wieldType` existe en `ItemConfig` y los templates de armas lo declaran.
* [ ] Dual wield 1H funciona (espada en cada mano) con stats aplicadas.
* [ ] 2H ocupa MainHand+OffHand y bloquea offhand; desequipar libera ambos.
* [ ] Escudo solo offhand; varita solo mainhand (offhand libre).
* [ ] Los templates de collar y anillo usan los slots `Necklace` y `Ring` ya existentes (1 cada uno), sin crear slots nuevos.
* [ ] Los 10 templates de armadura + varita + collar + anillo existen con stats seed, levelReq, rareza, BoE e iconId (visualModelId solo armadura/varita).
* [ ] Los sets completos equipan en el avatar R15 con los modelos de EST-07 (o fallback controlado si faltan).
* [ ] Collar y anillo equipan como dato con su icono, sin modelo visual (decisión de producto).
* [ ] Las piezas caen por loot (floor_1–5) y se compran en vendors sin romper el flujo R5/R5.2.
* [ ] El cliente no puede forzar wieldType, slots ni duplicar joyería.
* [ ] Sin errores rojos en equip → combate → respawn → rejoin.
* [ ] Se actualizan `PROJECT_ARCHITECTURE`, `DATA_SCHEMA` y el registro de la HU/RC al cerrar.
* [ ] Nota de esta HU en el GDD después de la verificación, no antes.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).

---

### **Decisiones por defecto ITEMS-01**

| Tema | Default |
|------|---------|
| Sets nuevos | Cazador (cuero) + Clérigo (tela), 5 piezas cada uno |
| Joyería | 1 Collar (`Necklace`) + 1 Anillo (`Ring`) por personaje, **sin visual** (dato + icono) |
| Armas | `OneHand` dual · `TwoHand` bloquea offhand · `OffHand` solo escudo · `MainHandOnly` varita |
| Varita | 1H mágica, MainHand-only, puede llevar escudo |
| Obtención | Loot floor_1–5 + vendors (armaduras/armas), seed mínimo |
| Stats | Seed orientativo; balance final R8d |
| Visual | `visualModelId` → Assets de EST-07; fallback controlado si falta |
| BoE | Se liga al equipar (R4) |

---

### **Estimación (orientativa)**

2–3 sesiones: wieldType + validaciones de equip, slots Neck/Ring + UI, templates/seed, loot/vendor y regresión completa.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-12 | Creación de HU-ITEMS-01: sets Cazador/Clérigo, varita, collar y anillo; reglas de armas 1H dual / 2H bloquea offhand; obtención seed por loot/vendor; decisiones cerradas con producto |
| 2026-09-15 | Revisión PM: slot canónico `Necklace` confirmado en `ItemConfig.SLOTS` (9 slots, Ring/Necklace ya existen); templateIds de migración y `weaponAffinity` verificados en código; `preferredSlot` marcado como extensión del contrato de `RequestEquipItem`; **collar y anillo sin modelo visual** (decisión de producto: solo dato + icono) |
| 2026-09-15 | **rc034 aprobado** con criterio de vendor confirmado (solo `vendor_gear`, sin NPC nuevo); **seed cerrado por el PM**: stats/rolls por pieza, levelReq/rareza por template y pesos de loot por piso (tablas en "Seed aprobado"); R8d afina balance |