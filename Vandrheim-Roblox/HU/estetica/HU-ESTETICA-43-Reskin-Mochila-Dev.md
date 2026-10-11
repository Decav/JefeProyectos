# HU-ESTETICA-43: Reskin de la Mochila (inventario) — grilla limpia sin panel de detalle (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / Inventario — Reskin (dev)
**Prioridad:** Alta
**Estado:** Lista para implementar (RC obligatorio del dev antes de programar)
**Tipo:** Reskin de UI (dev) — solo visual, sin tocar lógica
**Fase GDD:** UI (sustituye el visual de EST-11/21)
**Depende de:** frame del `.pen`: **`nwaNs` — "Inventario de Eirik · Mochila"** (aprobado por el PO), HU-ESTETICA-13 (tokens/handoff), HU-R6.27 (casillas estándar + TooltipSystem), HU-R6.32 (drag & drop), HU-ESTETICA-44 (tooltips de ítem), R4/R5.2 (inventario/stacking)
**No modifica:** inventario, stacks, vender, equipar ni lógica (R4/R5.2 intactos)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** una mochila limpia: grilla de 20 casillas, cantidades visibles y oro al pie,
**para** ver todo el inventario de un vistazo (el detalle de cada ítem aparece en el tooltip).

---

### **Descripción del Requerimiento / Contexto**

El diseñador entregó el rediseño de la mochila (frame `nwaNs` — "Inventario de Eirik · Mochila", **500×484**): una **grilla limpia de 20 casillas cuadradas** con cantidades y el pie con conteo + oro. **Sin panel de detalle del ítem** (decisión PO: el detalle lo da el TooltipSystem al hacer hover/tap-hold). El dev reskinea la mochila actual (EST-11/21) sobre ese diseño, **conservando nombres de instancias y lógica** (contrato EST-13).

**Criterio de hecho global:** la mochila se ve como el frame `nwaNs` (título, 20 casillas cuadradas con ítem/cantidad/vacío, pie con "X / 20 ESPACIOS · ORO", cerrar) — con datos reales y sin romper inventario/stacks/vender.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Áreas a reskinear (referencia: `nwaNs` — variante entregada "B · Slots cuadrados")**

1. **Encabezado**: título "INVENTARIO DE EIRIK" (índica el PJ — fs 13 bold pergamino; el nombre real va por perfil).
2. **Grilla de 20 casillas cuadradas** (fondo `#0E0D0C`):
   * **Una casilla = una pila** (regla existente R5.2).
   * Casilla con ítem: **imagen del ítem** (`Icon_Item_*`; los `IMAGE` del frame son placeholders) o icono placeholder mientras no exista asset.
   * **Cantidad**: texto bold pergamino (fs 7.5) sobre **backing negro translúcido** (`#00000099`) en la casilla — solo si pila >1 (el "20"/"8" del frame).
   * **Vacío**: label "VACÍO" gris `#8B8178` (fs 6.5 bold).
   * **Hover de interacción**: borde que se ilumina/agranda (estándar R6.27 — sin iluminar el fondo).
3. **Pie de la ventana** (`#171311`): **"12 / 20 ESPACIOS · ORO [ícono de oro] [cantidad]"** — dorado `#C89445` bold (fs 9) — datos reales (slots ocupados y oro del jugador; icono de oro: componente `Icon_UI_currency_gold` de EST-39).
4. **Botón cerrar** (`#3A2525` + X pergamino).
5. **SIN panel de detalle del ítem** dentro de la mochila (decisión PO — el detalle llega por **tooltip informativo** al hover/tap-hold: plantilla `item_equipable`/`item_consumible` de R6.27/EST-44 — **sin botones en el tooltip**; las acciones se hacen por click derecho o drag, ver R6.32).

#### **2. Decisiones de integración (PO 2026-09-22)**

* **SIN indicador de teclas Z/X en la mochila** (decisión PO: el diseño no las dibuja y no van — el badge queda fuera del reskin).

#### **3. Reglas**

* **Conservar los nombres de instancias/jerarquía que los scripts usan** (contrato EST-13).
* Mismo contrato de apertura/cierre, inventario, stacks, usar/vender que EST-11/21 (sin cambios de lógica).
* **Drag & drop (R6.32):** la mochila es la fuente de arrastre — arrastrar fuera de la ventana = eliminar con confirmación; arrastrar a una casilla del panel de personaje = equipar; **click derecho = usar/equipar** (ya no borra). Estados de arrastre según R6.32 (sombra del ítem, drop inválido en rojo).
* Tooltips: hover/tap-hold en casilla → tooltip de ítem (EST-44).
* Móvil: escala (máx 85 % viewport) y tap-hold (R6.32, 300 ms); sin romper.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Reskin fiel**

* **GIVEN** la mochila reskineada
* **WHEN** se compara con el frame `nwaNs`
* **THEN** replica título, grilla de 20 casillas (ítem/placeholder/cantidad/vacío), pie "X / 20 · ORO" y cerrar — **sin panel de detalle**

#### **Escenario 2: Datos reales**

* **GIVEN** la mochila
* **WHEN** se revisan cantidades, slots ocupados y oro
* **THEN** salen del servidor (stacks reales, "X / 20", saldo de oro)

#### **Escenario 3: Interacción**

* **GIVEN** la mochila + panel de personaje
* **WHEN** se arrastra un ítem (R6.32) o se hace click derecho
* **THEN** drag fuera = confirmación de borrado; drag a slot = equipa; click derecho = usar/equipar (nunca borra)

#### **Escenario 4: Sin badge de teclas**

* **GIVEN** una casilla con consumible
* **WHEN** se revisa
* **THEN** **no hay indicador Z/X** en la mochila (decisión PO — el diseño no lo incluye)

#### **Escenario 5: Lógica intacta**

* **GIVEN** el reskin aplicado
* **WHEN** se usa/vende/equipa y se reinicia
* **THEN** inventario/stacks intactos (R4/R5.2 sin cambios; sin errores rojos)

#### **Escenario 6: Móvil**

* **GIVEN** la mochila en móvil
* **WHEN** se revisa
* **THEN** se adapta con escala/tap-hold (R6.32) y fuentes legibles (R6.27)

---

### **Alcance**

#### Incluye

* Reskin de la mochila según `nwaNs` (encabezado, 20 casillas, cantidades, pie con oro, cerrar).

#### No incluye

* Lógica de inventario (R4/R5.2 intactos); panel de detalle (lo cubre el TooltipSystem); bordes de rareza en casillas (decisión: no); **indicador de teclas Z/X (decisión PO: fuera)**.

---

### **Definition of Done (DoD)**

* [ ] Mochila replica el frame `nwaNs` (20 casillas cuadradas, cantidades con backing, pie "X / 20 · ORO", cerrar) — sin panel de detalle y **sin badge Z/X**.
* [ ] Datos reales (stacks, conteo, oro); badge Z/X conservado; sin bordes de rareza.
* [ ] Nombres de instancias conservados; inventario/stacking intactos (sin errores rojos).
* [ ] Drag & drop (R6.32) y tooltips (R6.27/EST-44) integrados; móvil OK.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Estimación (orientativa)**

2 sesiones del dev: reskin de la mochila + integración de interacción.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-ESTETICA-43: reskin de la mochila (frame `nwaNs` "Inventario de Eirik · Mochila" aprobado) — grilla limpia de 20 casillas cuadradas con cantidades (backing negro translúcido), pie "X / 20 ESPACIOS · ORO" y cerrar; **sin panel de detalle** (tooltips EST-44/R6.27); **sin badge Z/X** (decisión PO 2026-09-22) y sin bordes de rareza; integra drag & drop (R6.32) |