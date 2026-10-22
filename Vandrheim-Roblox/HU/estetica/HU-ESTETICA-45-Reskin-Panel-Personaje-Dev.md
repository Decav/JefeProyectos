# HU-ESTETICA-45: Reskin del Panel de Personaje (Equipo + Estadísticas) — variante B (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / Personaje — Reskin (dev)
**Prioridad:** Alta
**Estado:** Implementada (reporte PO 2026-09-22); QA y seguimiento de color de stats pendientes
**Tipo:** Reskin de UI (dev) — solo visual, sin tocar lógica
**Fase GDD:** UI (sustituye el visual de EST-10/21 — ventana C: equipo + stats)
**Depende de:** frame del `.pen`: **`HUMWS` — "Equipo y estadísticas · Panel de personaje" (VARIANTE B, seleccionada por el PO)** dentro de **`MqBFE` — "HU-EST-10 · Variantes de reskin de personaje"** (A/C/D = alternativas descartadas, documentadas), HU-ESTETICA-13 (tokens/handoff), HU-R6.27 (fuentes + TooltipSystem), HU-R6.32 (drag & drop de ítems), HU-ITEMS-01 (slot order/reglas), R2/R4/R6.5 (lógica)
**No modifica:** calculo de stats, equipamiento, slots ni lógica (R4/R6.5 intactos)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** el panel de personaje rediseñado (nombre arriba, atributos agrupados al centro y los 9 slots de equipo),
**para** leer de un vistazo mis stats y qué llevo puesto, en una ventana compacta (tecla C).

---

### **Descripción del Requerimiento / Contexto**

El diseñador entregó las **variantes de reskin del panel de personaje** (frame `MqBFE`) y el PO seleccionó la **variante B** (`HUMWS` — "Equipo y estadísticas · Panel de personaje"): una ventana de **480×455** con encabezado, grupo central de **atributos** y **9 slots de equipo**. El dev reskinea la ventana combinada C actual (EST-10/21) sobre ese diseño, **conservando nombres de instancias y lógica** (contrato EST-13).

**Criterio de hecho global:** el panel C se ve como la variante B del frame (título + identidad, grupos de atributos con filas alternadas, 9 slots con ítems/vacíos, cerrar) — con datos reales del servidor y sin romper equipamiento ni cálculo de stats.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Áreas a reskinear (referencia: `HUMWS` — variante B)**

1. **Encabezado**: nombre del PJ ("Eirik" — fs 15 bold pergamino) + identidad dorada ("PALADÍN · CASTIGO · NIVEL 16" — clase real · spec real · nivel real, fs 9 bold `#C89445`).
2. **Lista central de atributos** ("ATRIBUTOS DEL PERSONAJE" — `#171311`, fs 12 bold pergamino), agrupada en **3 secciones** con cabecera `#3A2C25` (label pergamino fs 9.5 bold):
   * **RECURSOS**: MaxHP · MaxMP
   * **ATAQUE**: ATK · MATK · CRIT · CDR
   * **DEFENSA**: DEF · MDEF
   * Filas con **stripes alternos** `#171311`/`#211916`: label dorado `#C89445` (fs 8.5) + **valor bold** (fs 9). El valor usa **verde `#70C08B` solo si equipo o talentos aportan un bonus positivo a ese stat**; usa **pergamino `#F4EDE0`** si solo tiene el valor base. No pintar verde solo porque el total sea mayor que cero ni por un efecto únicamente consumible.
   * **CDR se muestra siempre** aunque sea 0 % (dato real; es el mismo stat del panel actual).
3. **9 slots de equipo** (casillas `#0E0D0C`): order de slots = `ItemConfig.SLOTS` (Helmet, Chest, Shoulders, Legs, Gloves, **Necklace**, **Ring**, **OffHand**, **MainHand** — per ITEMS-01):
   * Slots con ítem: **imagen del ítem** (`Icon_Item_*` — los `photo` del frame son placeholders; el dev mapea `visualModelId`/icono real) + hover de borde (estándar R6.27).
   * Slots vacíos: label descriptivo gris `#8B8178` ("COLLAR · VACÍO", "ANILLO · VACÍO", "MANO I. · VACÍO", "MANO D. · VACÍO" — fs 6.5).
4. **Botón cerrar** (`#3A2525` + icono X pergamino).

#### **2. Reglas**

* **Conservar los nombres de instancias/jerarquía que los scripts usan** (contrato EST-13).
* Mismo contrato de apertura/cierre (tecla C), slot mapping y stats que EST-10/21 (sin cambios de lógica).
* Los valores salen **del servidor** (base de clase + equipo + talentos — mismo desglose que el panel actual; el tooltip de stat lo cubre el TooltipSystem de R6.27 §6).
* La decisión de color consulta las fuentes de `statsBreakdown` (equipo/talentos); si no hay contribución positiva de esas fuentes, el valor queda en pergamino aunque el stat base sea >0. Para CDR, mostrar verde solo cuando exista bonus de talento y pergamino cuando sea 0/base.
* **Drag & drop (R6.32):** los slots son destinos válidos para equipar arrastrando desde la mochila (highlight verde al hover con ítem válido; rechazo si no aplica); click derecho = equipar/usar (ya no borra). Estados de interacción según el estándar de casillas (R6.27).
* Tooltips: slot con ítem → tooltip de ítem (plantilla `item_equipable` — Tooltip_Item_* de EST-44); fila de stat → tooltip de stat (plantilla `stat`).
* Móvil: se adapta por escala (máx 85 % viewport), sin romper y con fuentes legibles (R6.27: labels ≥8.5, valores ≥9).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Reskin fiel**

* **GIVEN** el panel C reskineado
* **WHEN** se compara con la variante B (`HUMWS`)
* **THEN** replica encabezado, 3 grupos de atributos con stripes, 9 slots (con ítems/vacíos) y cerrar (colores/fuentes del diseño)

#### **Escenario 2: Datos reales**

* **GIVEN** el panel
* **WHEN** se revisan los valores
* **THEN** identidad (clase/spec/nivel) y stats (incl. CDR) salen del servidor — desglose base+equipo+talentos en el tooltip

#### **Escenario 3: Slots correctos**

* **GIVEN** los 9 slots
* **WHEN** se equipan/desocupan ítems
* **THEN** muestran icono real o label de vacío en el orden de `ItemConfig.SLOTS` (collar/anillo/manos incluidas)

#### **Escenario 4: Interacción**

* **GIVEN** el panel con la mochila abierta
* **WHEN** se arrastra un ítem sobre su slot o se hace click derecho
* **THEN** se equipa (R6.32) con highlight válido/inválido — misma lógica de equip que antes

#### **Escenario 5: Lógica intacta**

* **GIVEN** el reskin aplicado
* **WHEN** se examina equipamiento, stats y dual/2H
* **THEN** funciona igual que antes (R4/R6.5 sin cambios; sin errores rojos)

#### **Escenario 6: Móvil**

* **GIVEN** el panel en móvil
* **WHEN** se revisa
* **THEN** se adapta (escale/touch) sin romper y con fuentes legibles (R6.27)

#### **Escenario 7: Color refleja fuente del bonus**

* **GIVEN** un stat del personaje con desglose base/equipo/talentos
* **WHEN** no recibe bonus de equipo ni de talentos
* **THEN** su valor se muestra en pergamino; al aportar equipo o talento positivo cambia a verde, y vuelve a pergamino al retirar el origen del bonus

---

### **Alcance**

#### Incluye

* Reskin del panel de personaje (variante B) — encabezado, atributos agrupados, 9 slots, cerrar.

#### No incluye

* Lógica de stats/equip (R4/R6.5 intactos); las alternativas A/C/D del frame (descartadas por el PO, quedan documentadas como referencia).

---

### **Definition of Done (DoD)**

* [ ] Panel C replica la variante B (`HUMWS`): título+identidad, grupos RECURSOS/ATAQUE/DEFENSA con stripes y valores coloreados según aporte real de equipo/talentos, 9 slots (ítem/vacío), cerrar.
* [ ] Datos reales del servidor (incl. CDR); slots en el orden de `ItemConfig.SLOTS`.
* [ ] Nombres de instancias conservados; equip/stats intactos (sin errores rojos).
* [ ] Interacción (R6.32) y tooltips (R6.27) integrados.
* [ ] Móvil OK y fuentes legibles (R6.27).
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Estimación (orientativa)**

2 sesiones del dev: reskin del panel + slots + integración de interacción.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-ESTETICA-45: reskin del panel de personaje (Equipo + Estadísticas) — **variante B seleccionada** (frame `HUMWS` dentro de `MqBFE` "HU-EST-10 · Variantes"); titular + identidad real, 3 grupos de atributos (RECURSOS/ATAQUE/DEFENSA incl. CDR) con stripes y colores por valor, 9 slots de equipo con ítem/vacío (order `ItemConfig.SLOTS`), cerrar; integra drag & drop (R6.32) y tooltips (R6.27); alternativas A/C/D descartadas documentadas |
| 2026-10-21 | Seguimiento PO: el color del valor debe depender de bonus positivo de equipo/talentos; valor base sin bonus queda en pergamino. |
