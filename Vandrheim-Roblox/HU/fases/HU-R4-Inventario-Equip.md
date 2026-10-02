## HU-R4: Inventario, equipamiento y generación de ítems (BoE + rolls + rareza)

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** Gear / Inventario / R4  
**Prioridad:** Crítica  
**Estado:** Completada (implementada; reporte equipo 2026-08-12)  
**Fase GDD:** R4  
**Depende de:** HU-R2 (profile con stats por clase), HU-R3 (fórmula de daño usa ATK/MATK), HU-R1 (dummy para verificar daño)

---

### **Narrativa (INVEST)**

**Como** jugador,  
**quiero** recibir ítems al matar enemigos, guardarlos en mi inventario, equiparlos y que cambien mis stats,  
**para** sentir progresión de gear, con rarezas que den variedad y bind on equip que proteja la economía futura.

---

### **Descripción del Requerimiento / Contexto**

Fase R4 del GDD (§7 Ítems y economía, §12 Servicios, §14 Plan): `InventoryService` server-authoritative, ítems data-driven con **stats base + roll menor**, **rareza** (Blanco/Verde/Azul/Morado), **Bind on Equip** desde día 1 (flag en data), **requisito de nivel**, y **equip que modifica stats del PJ** (se refleja en daño de R1/R3).

**Criterio de hecho global GDD:** "Equip cambia stats".

No hay dungeon aún (R6–7): en R4 el loot de prueba se obtiene vía **debug grant** y un drop opcional del dummy (test).

---

### **Especificaciones Técnicas / Contratos de API**

#### **ItemConfig (ReplicatedStorage/Config — data-driven)**

```luau
{
  ["sword_apprentice"] = {
    name = "Espada del aprendiz",
    slot = "MainHand",           -- "Helmet"|"Chest"|"Shoulders"|"Legs"|"Gloves"|"Ring"|"Necklace"|"MainHand"|"OffHand"
    rarity = "Uncommon",         -- "Common"|"Uncommon"|"Rare"|"Epic"
    levelReq = 1,
    weaponAffinity = {"Paladin_Protector","Hunter_Assault"},  -- bonus, no hard-lock (GDD §4)
    stats = { ATK = {base=8, roll=2} },   -- roll = ±variación aleatoria
    affixes = {},                         -- afijos posibles por rareza (definidos abajo)
    unique = false,                       -- true para ítems de boss (R7); nombre propio
    iconId = "rbxassetid://...",
    description = "Espada de práctica para el nuevo aventurero."
  },
  -- ...
}
```

#### **Instancia de ítem (data)**

```luau
{
  instanceId = "uuid",
  templateId = "sword_apprentice",
  rarity = "Uncommon",           -- roll de rareza real
  stats = { ATK = 9 },           -- roll final (server genera; cliente nunca)
  affixes = { "+5 CRIT" },       -- según rareza
  bindState = "Free" | "Bound",  -- BoE desde día 1
  ownerCharacterId = "charId",   -- para party/loot futuro (R9)
}
```

#### **Remotes / intenciones**

| Remote | Dir | Payload | Validación server |
|--------|-----|---------|-------------------|
| `RequestInventory` | C→S | — | Devuelve bolsa + equipo del PJ activo |
| `RequestEquipItem` | C→S | `{ instanceId }` | Ítem es del PJ, nivel ≥ levelReq, slot libre (o reemplaza), BoE se aplica al equipar |
| `RequestUnequipItem` | C→S | `{ slotName }` | Hay ítem equipado; vuelve a la bolsa |
| `RequestDropItem` | C→S | `{ instanceId }` | Ítem del PJ; se elimina (solo test/debug; confirmar en UI) |
| (debug, Studio) `GrantItem` | S→C cmd | `{ templateId }` | Solo habilitado en Studio/test — **no** feature de jugador |

#### **Servicios**

| Servicio | Rol R4 |
|----------|--------|
| `InventoryService` | Bolsa, equip, BoE, req nivel, rolls, owner, persistencia en profile |
| `ItemService` / `LootService` (mínimo) | Roll de stats + affixes al instanciar; tabla de drop mínima para test |
| `StatService` (o cálculo en ClassService) | Recalcular stats del PJ = base clase + equip; reaplicar MaxHP/MaxMP/ATK/MATK/DEF/MDEF/CRIT |

#### **Reglas de stats**

* **Equip cambia stats:** stats del PJ = base de clase (R2) + suma de ítems equipados.
* Al equipar/desequipar: recalcular y actualizar Humanoid/attrs server-side (MaxHP/MaxMP clamp; ATK/MATK/DEF/MDEF/CRIT usados por R3).
* **Rol menor:** stats del template con variación `±roll` (server, `Random.new()` por ítem); afijos según rareza.
* **Rareza:**

| Rareza | Color UI | Regla |
|--------|----------|-------|
| Blanco (Common) | Gris | Stats base solos |
| Verde (Uncommon) | Verde | Roll ligeramente mejor |
| Azul (Rare) | Azul | +1 afijo menor |
| Morado (Epic) | Morado | +1 afijo mayor (o 2 menores) |

* **Afijos (defaults):** menores = `+MaxHP 10`, `+CRIT 5`, `+DEF 3`, `+MaxMP 10`; mayores = `+ATK 10`, `+MATK 10`, `+DEF 8`, `+MaxHP 30`. Aleatorios pero coherentes con el slot.
* **BoE:** al **equipar** por primera vez → `bindState = "Bound"` (queda ligado al personaje; desequipar mantiene bound). Flag existe en data desde día 1 (trade futuro).
* **Requisito de nivel:** no equipar si `levelReq > nivel` del PJ; feedback claro.
* **Afinidad de arma:** bonus pequeño (p. ej. +10% stats efectivas si la spec del PJ está en `weaponAffinity`) — **no hard-lock** (GDD §4).
* **Slots:** Casco, Pecho, Hombreras, Pantalón, Guantes, Anillo, Collar, MainHand, OffHand (arma + escudo/offhand).

#### **Loot de prueba (R4)**

* `GrantItem` debug (Studio) para QA de equip/rolls.
* Opcional: el dummy R1 dropea **1 ítem de nivel 1** al morir (tabla de drop mínima en `Config/LootTables`) para probar el loop completo → UI de recompensa (ventana, no pickups en suelo — GDD §7).
* El loot real de dungeon/boss llega en R6–7; los uniques de boss dejan el flag `unique` listo en config.

#### **Persistencia**

* Profile (R2): `characters[].inventory = { bag = {[index]=instance}, equipment = {[slot]=instance} }`.
* Guardar en los mismos eventos que R2 (leave/shutdown/autosave + tras equip/unequip/drop).
* El roll, rareza, affixes y bindState persisten (no se recalculan en rejoin).

#### **UI**

* **Ventana de inventario:** bolsa (grid) + slots de equipo visibles; abrir con tecla (default `B` o botón en HUD).
* **Tooltip:** nombre, color de rareza, stats finales, requisito de nivel, afijos, estado bind.
* **Interacción:** click = equipar (si equipable); con inventario abierto, **click derecho = desequipar** (el drag de cámara se desactiva mientras el inventario está abierto — compatibilidad con R3.1).
* **Feedbacks:** "Nivel insuficiente", "Espacio de bolsa lleno", "Ítem ligado a este personaje" (solo informativo MVP).
* **Ventana de recompensa (loot):** lista de ítems + oro al matar (GDD: UI recompensa, no loot físico).
* UI con Scale + UIAspectRatioConstraint; PC primero, móvil básico.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Inventario abre y muestra**

* **GIVEN** el jugador tiene un PJ activo en el hub
* **WHEN** abre el inventario (tecla B o botón)
* **THEN** ve la bolsa y los slots de equipo
* **AND** el inventario vacío se muestra correctamente (sin errores)

#### **Escenario 2: Loot de prueba llega al inventario**

* **GIVEN** el jugador mata al dummy (o usa GrantItem en Studio)
* **WHEN** el server genera el drop
* **THEN** el ítem aparece en la bolsa
* **AND** se muestra la ventana de recompensa (UI, no pickup en suelo)
* **AND** el ítem tiene stats con roll del server

#### **Escenario 3: Equipar cambia stats**

* **GIVEN** un ítem equipable en la bolsa sin superar su levelReq
* **WHEN** el jugador hace click en él
* **THEN** el ítem pasa al slot de equipo
* **AND** los stats del PJ cambian (ej. ATK/MATK/DEF) según el ítem
* **AND** el daño al dummy (R1/R3) refleja el nuevo stat

#### **Escenario 4: Desequipar restaura stats**

* **GIVEN** un ítem equipado
* **WHEN** el jugador hace click derecho sobre el slot (inventario abierto)
* **THEN** el ítem vuelve a la bolsa
* **AND** los stats del PJ vuelven al valor anterior al equipar

#### **Escenario 5: Requisito de nivel**

* **GIVEN** un ítem con `levelReq` mayor al nivel del PJ
* **WHEN** el jugador intenta equiparlo
* **THEN** el server rechaza
* **AND** la UI muestra "Nivel insuficiente"

#### **Escenario 6: Bind on Equip**

* **GIVEN** un ítem Free en la bolsa
* **WHEN** se equipa por primera vez
* **THEN** `bindState` pasa a `Bound` en data (persistente)
* **AND** desequiparlo no lo devuelve a Free
* **AND** el flag queda guardado tras rejoin

#### **Escenario 7: Rolls y rareza**

* **GIVEN** dos drops del mismo template (mismo ítem base)
* **WHEN** se instancian
* **THEN** los stats pueden variar dentro del rango (±roll)
* **AND** la rareza aplica su regla (afijos según Blanco/Verde/Azul/Morado)
* **AND** la UI muestra el color de rareza correcto

#### **Escenario 8: Afinidad de arma**

* **GIVEN** un arma con `weaponAffinity` que incluye la spec del PJ
* **WHEN** se equipa
* **THEN** aplica el bonus de afinidad (p. ej. +10% stats efectivas)
* **AND** si la spec no está en la lista, equipa igual sin bonus (no hard-lock)

#### **Escenario 9: Anti-exploit**

* **GIVEN** un cliente intenta equipar un ítem de otro personaje, forzar stats o crear ítems
* **WHEN** solo manipula estado local
* **THEN** el server rechaza
* **AND** los rolls/soluciones siempre se generan en server

#### **Escenario 10: Persistencia y estabilidad**

* **GIVEN** el jugador con ítems equipados y en bolsa
* **WHEN** sale y vuelve a entrar
* **THEN** los ítems, rolls, afijos, bind y equipo se mantienen
* **AND** sin errores rojos en el flujo inventario → equip → matar dummy → rejoin

---

### **Comportamiento Visual e Interfaz (UI/UX) / Reglas de Negocio**

* **Apertura del inventario:** pausa el drag de cámara (R3.1) y muestra cursor normal (MouseBehavior Default) mientras está abierto; se restaura al cerrar.
* **Colores de rareza** en nombre/borde/tooltip.
* **Equip vs consumible:** en R4 solo equipo; consumibles/pociones son R5 (vendors).
* **BoE:** aviso en tooltip; en MVP sin trade (futuro), el bind solo debe existir como flag correcto en data (GDD: "flag desde día 1").
* **Vender ítems:** se habilita con vendors en R5; un ítem bound igual se podrá vender a NPC (default), pero **no** transferirse entre jugadores.

---

### **Alcance**

#### Incluye

* ItemConfig data-driven (templates + rarezas + afijos)
* InventoryService server: bolsa, equip/unequip, BoE, req nivel, owner
* Rolls de stats + afijos (server) y rareza con UI por color
* Stats del PJ = clase base + equip (afecta daño de R1/R3)
* Loot de prueba: GrantItem debug + drop opcional del dummy con ventana de recompensa
* Persistencia de ítems/equipo/bind en profile
* Tooltip y slots de equipo (PC + móvil básico)

#### No incluye

* Vendors / compra-venta / oro en tienda (R5)
* Consumibles / pociones
* Dungeon / loot real de boss y cofre (R6–7)
* Trade entre jugadores (post-MVP)
* Sockets, gems, enchant, sets, crafting
* Loot físico en el suelo (GDD: UI recompensa)
* Trade de ítems Free (se mantiene flag para futuro, no funcional)

---

### **Definition of Done (DoD)**

* [ ] Play Solo: matar dummy → ítem en bolsa → equipar → stats cambian → dummy recibe más daño
* [ ] Desequipar restaura stats (click derecho con inventario abierto)
* [ ] Req nivel rechaza equip correctamente
* [ ] BoE: bound al equipar y persiste tras rejoin
* [ ] Rolls varían entre drops del mismo template; rarezas con color correcto
* [ ] Afinidad de arma aplica bonus (no hard-lock)
* [ ] Cliente no puede equipar ajeno / forzar stats / crear ítems
* [ ] Inventario + equipo persisten tras rejoin
* [ ] Sin errores rojos en el flujo completo
* [ ] Nota "R4 completo" en GDD

---

### **Checklist Studio (referencia dev)**

* [ ] `ItemConfig` + seed de templates (armas/armaduras de prueba, 1 por rareza) en `Config`
* [ ] `InventoryService` (server): bolsa, equip/unequip, BoE, req nivel, owner, persistencia
* [ ] Roll de stats + afijos con `Random` del servidor
* [ ] Recalcular stats del PJ (clase + equipo) y reaplicar al Humanoid/attrs
* [ ] Remotes: `RequestInventory`, `RequestEquipItem`, `RequestUnequipItem`, `RequestDropItem`, `GrantItem` (debug)
* [ ] UI: ventana inventario + slots de equipo + tooltip + colores de rareza
* [ ] Ventana de recompensa de loot (test con dummy)
* [ ] Compatibilidad: drag de cámara desactivado con inventario abierto (R3.1)
* [ ] Persistencia: ítems/rolls/bind/equipo sobreviven rejoin

---

### **Decisiones por defecto R4 (si no se cambian)**

| Tema | Default |
|------|---------|
| Roll | `base ± roll` (server); afijos según rareza |
| Rareza | Blanco base / Verde roll+ / Azul +1 afijo menor / Morado +1 afijo mayor |
| BoE | Bound al equipar; desequipar no revierte; vendible a NPC (R5), no trade |
| Req nivel | Sí; rechazo con feedback |
| Afinidad | +10% stats efectivas si la spec está en `weaponAffinity`; no hard-lock |
| Slots | 9: casco, pecho, hombreras, pantalón, guantes, anillo, collar, mainhand, offhand |
| Loot test | `GrantItem` debug (solo Studio) + drop opcional del dummy (tabla mínima) |
| Persistencia | Ítems/rolls/afijos/bind guardados (no recalculados) |
| UI apertura | Tecla `B` (o botón HUD); pausa drag de cámara mientras abierto |

---

### **Estimación (orientativa)**

3–5 sesiones (servicio + UI + persistencia suelen ser el cuello de botella).

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-12 | Alta HU-R4 al cerrar R3/R3.1; producción pasa a R4 |
| 2026-08-12 | Marcada completada según reporte del equipo; producción pasa a R5 |
