# HU-ESTETICA-44: Tooltips — ítem equipable, consumible y habilidad (diseñador) — ENTREGADO

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / Tooltips
**Prioridad:** Alta
**Estado:** ✅ **Entregado y verificado** (2026-09-22) — referencia de diseño para el dev (TooltipSystem de R6.27 §6)
**Tipo:** Diseño de UI (diseñador) — registro formal de la entrega (brief PO 2026-09-22)
**Fase GDD:** UI (acompaña a R6.27: tooltips centralizados)
**Depende de:** HU-ESTETICA-13 (tokens/9-slice/handoff), HU-ESTETICA-39 (iconos `Icon_Stat_*`), HU-R6.27 (§4–6: rango real, daño/escalado, levelReq real, TooltipSystem), frame del `.pen`: **"Tooltips de Vandrheim · Item Consumible Skill"** (`rIOiC`)
**No modifica:** lógica ni stats (solo diseño)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** tooltips claros y completos para **ítems equipables, consumibles y habilidades**,
**para** entender stats, requisitos, efectos y escalado sin abrir nada más.

---

### **Descripción del Requerimiento / Contexto**

Los 3 tipos de tooltip del juego, diseñados por brief del PO y **entregados en el `.pen`** (frame "Tooltips de Vandrheim · Item Consumible Skill", verificado): servirán de referencia visual del **TooltipSystem** de R6.27 (§6, plantillas `item_equipable`, `item_consumible` y `skill`).

**Criterio de hecho global:** existen los 3 tooltips en el `.pen` con el contenido canónico (stats texto puro, set con progreso, BoE, levelReq real, efecto sin CD, skill con rango/escalado), tokens EST-13 y puntero al origen — verificados por el PO.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Tooltip_Item (equipable — `Tooltip_Item_Espada_Campeon`)**

* Nombre + línea de **rareza · slot** ("ÉPICO · MANO DERECHA").
* **Stats solo texto** (decisión PO: sin iconos `Icon_Stat_*`): "+17 ATK", "+5 % CRIT" (fs ≥10 bold).
* **Conjunto**: "CONJUNTO PALADÍN · 3/5 PIEZAS" + **progreso** (track `#3A302A` / fill `#C89445`), bono activo en verde ("3 piezas · Bono activo del conjunto") y bono inactivo en pergamino ("4 piezas · Siguiente bono del conjunto").
* **BoE**: "Se liga al equipar".
* **levelReq REAL**: "Requiere nivel 16" (la épica es lvl 16 — dato de ITEMS-06; incluido tras la corrección PO).
* **Puntero** (flecha) hacia el origen.

#### **2. Tooltip_Consumible (poción — `Tooltip_Consumible_Pocion_HP`)**

* Nombre + línea de rareza ("COMÚN · CONSUMIBLE").
* **EFECTO**: "Restaura 25 % de HP y MP" (verde).
* **SIN cooldown** (la config del juego no tiene CD de pociones — quitado por decisión PO).
* Puntero hacia el origen.

#### **3. Tooltip_Skill (habilidad — `Tooltip_Skill_Anillo_Luz`)**

* Nombre + tipo ("Explosión a tu alrededor · Daño mágico").
* Línea de datos: **"Coste de maná: 25 MP · Reutilización: 10 segundos · Radio de efecto: 6 studs"** (rango real, nunca "-").
* **Efecto** (descripción del skill) + **escalado**: "El daño aumenta con tu ataque mágico (MATK)".
* Puntero hacia el origen.

#### **4. Reglas visuales (board del frame — canónico)**

* Tokens **EST-13** · **9-slice** · **fondo `#171311`** · textos: nombre ≥11 bold pergamino, detalles ≥9.
* **Puntero al origen** + "gira al lado disponible en viewport" · **móvil = tap-hold** (documentado en el board).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Entrega presente**

* **GIVEN** el frame "Tooltips de Vandrheim · Item Consumible Skill" (`rIOiC`)
* **WHEN** se inspecciona
* **THEN** existen los **3 tooltips** (`Tooltip_Item_*`, `Tooltip_Consumible_*`, `Tooltip_Skill_*`) con sus contenidos canónicos

#### **Escenario 2: Nada del brief faltante**

* **GIVEN** el tooltip del ítem
* **WHEN** se revisa
* **THEN** tiene stats de texto, set con progreso, BoE y **levelReq real (16)** — sin iconos de stat (decisión PO)

#### **Escenario 3: Sin cooldown inventado**

* **GIVEN** el tooltip de la poción
* **WHEN** se revisa
* **THEN** muestra efecto y rareza — **sin CD** (no hay CD de pociones en config)

#### **Escenario 4: Skill completo**

* **GIVEN** el tooltip de habilidad
* **WHEN** se revisa
* **THEN** muestra coste, reutilización, **radio real (6 studs)** y **escalado (MATK)**

#### **Escenario 5: Listo para el dev**

* **GIVEN** los tooltips entregados
* **WHEN** el dev implementa el TooltipSystem (R6.27 §6)
* **THEN** usa estos 3 como referencia visual de las plantillas `item_equipable`, `item_consumible` y `skill`

---

### **Alcance**

#### Incluye

* Registro formal de los 3 tooltips entregados (contenido canónico + reglas visuales).

#### No incluye

* Los demás tipos de tooltip (talento, vendor, party, loot, stat — los define el TooltipSystem de R6.27 con comportamiento y se diseñan en iteración si aplica).

---

### **Definition of Done (DoD)**

* [ ] Los 3 tooltips entregados y verificados en el `.pen` (contenido + reglas).
* [ ] Registrados en R6.27 (historial) como referencia del TooltipSystem.
* [ ] LevelReq real incluido; sin CD de poción; sin iconos en stats (acuerdos del PO).

---

### **Estimación (orientativa)**

— (entrega ya realizada; HU de registro/referencia)

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-ESTETICA-44: tooltips de ítem equipable, consumible y habilidad — registro formal de la entrega (diseñador + ajustes PO, verificado en el `.pen`): stats solo texto, conjunto con progreso, BoE, **levelReq real 16**, poción sin CD, skill con coste/reutilización/radio 6/escalado MATK, tokens EST-13 con 9-slice y puntero; referencia visual del TooltipSystem (R6.27 §6) |