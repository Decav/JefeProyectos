# HU-ESTETICA-42: Reskin del Grimorio — estilo libro WoW con barra equipada (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / Grimorio — Reskin (dev)
**Prioridad:** Alta
**Estado:** Implementada (reporte PO 2026-09-22; verificación/QA pendiente)
**Tipo:** Reskin de UI (dev) — solo visual, sin tocar lógica
**Fase GDD:** UI (sustituye el visual de EST-17)
**Depende de:** **HU-ESTETICA-17 (reskin a superar — el frame nuevo lo reemplaza)**, frame del `.pen`: **`WUFrU` — "Grimorio · Libro de habilidades WoW style"** (aprobado por PO), HU-ESTETICA-13 (tokens/handoff), HU-R6.27 (fuentes legibles + barra activa con casillas al icono + TooltipSystem), HU-R5.1 (skills/lógica), SKILLS_CATALOG
**No modifica:** skills, costes, CDs, asignación de barra ni lógica (R5.1 intactos)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** el grimorio rediseñado como un **libro de habilidades** con tarjetas por rareza y la **barra equipada** abajo,
**para** ver de un vistazo qué sé, qué está asignado y cómo se ve cada habilidad.

---

### **Descripción del Requerimiento / Contexto**

El diseñador entregó el grimorio estilo libro (frame `WUFrU`) — **aprobado por el PO**. El dev reskinea la UI del grimorio (EST-17 actual) sobre ese diseño, **conservando nombres de instancias y lógica** (contrato EST-13).

**Criterio de hecho global:** el grimorio se ve como el frame `WUFrU` (encabezado de libro, página izquierda con 6 tarjetas por rareza, filtros, y la barra equipada con 4 slots + teclas) — con datos reales (coste/CD/fuente/asignación) y sin romper la asignación de la barra ni las skills.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Áreas a reskinear (referencia: frame `WUFrU`)**

1. **Encabezado de libro**: título "GRIMORIO DE EIRIK" (PlayfairDisplay, pergamino), línea de personaje ("PALADÍN · CASTIGO · NIVEL 16" dorada), botón **cerrar (×)**.
2. **Página izquierda** (`#241B16`): regla superior, título "HABILIDADES" + contador ("6 CONOCIDAS" — dato real).
3. **6 tarjetas de habilidad** (600×96 en diseño): **strip de rareza** al costado (dorado/azul/morado según el skill — SKILLS_CATALOG), **icono en tile** (fondo `#0E0D0C`, icono existente), nombre (≥11 bold), tipo ("INSTANT · ATK/MATK", "SELFAOE · MATK · **R6**"), coste (**8.5+** `#B7C7D3`: "10 MP · CD 4s"), fuente ("Básica · Nivel 1", "Castigo · Nivel 5", "Talento · Ataque · Tier 2", "…Capstone"), **escalado** donde aplique ("ESCALA · MATK") y asignación ("ASIGNADA · SLOT 1" dorado / "NO ASIGNADA · TALENTO" pergamino).
4. **Filtros** (`#171311` con tab activo dorado): las pestañas de la página.
5. **Barra equipada** (abajo, `#211916`): heading "BARRA EQUIPADA · 4 HABILIDADES", **4 slots** (140×72 en diseño) con **tecla 1–4** (bold pergamino), icono, nombre y coste — siguiendo el patrón de icono-visible de la skill bar del HUD (R6.27: el icono se acomoda al slot; tamaño/lectura coherente con el HUD).
6. **Estados**: tarjeta de skill de talento bloqueada si aplica (visual a definir con la lista "por aprender" — misma lógica de EST-17).

#### **2. Reglas**

* **Conservar los nombres de instancias/jerarquía que los scripts usan** (contrato EST-13).
* Mismo contrato de apertura/cierre, filtros y asignación de barra que EST-17 (sin cambios de lógica).
* Los textos usan **datos reales** del SKILLS_CATALOG/config (coste, CD, rango, fuente, escalado) — nunca datos quemados.
* Fuentes legibles (R6.27): las tarjetas usan los nuevos tamaños/colores del diseño (coste ≥8.5, `#B7C7D3`).
* El **TooltipSystem** (R6.27 §6) cubre el tooltip de skill sobre las tarjetas (plantilla `skill` — el tooltip diseñado `Tooltip_Skill_Anillo_Luz` es la referencia).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Reskin fiel**

* **GIVEN** el grimorio reskineado
* **WHEN** se compara con el frame `WUFrU`
* **THEN** replica encabezado, página con 6 tarjetas por rareza, filtros y barra equipada (colores/fuentes del diseño)

#### **Escenario 2: Datos reales**

* **GIVEN** las tarjetas
* **WHEN** se revisan
* **THEN** nombre/tipo/coste/CD/*rango*/fuente/*escalado*/asignación salen del SKILLS_CATALOG/config (sin datos quemados)

#### **Escenario 3: Barra equipada**

* **GIVEN** la barra de abajo
* **WHEN** se comparan los 4 slots con la skill bar del HUD
* **THEN** teclas 1–4, iconos legibles y costes visibles — patrón coherente con el HUD (R6.27)

#### **Escenario 4: Lógica intacta**

* **GIVEN** el reskin aplicado
* **WHEN** se asigna/desasigna habilidades y se filtran
* **THEN** funciona igual que antes (R5.1 sin cambios; sin errores rojos)

#### **Escenario 5: Móvil**

* **GIVEN** el grimorio en móvil
* **WHEN** se revisa
* **THEN** se adapta (escale/touch) sin romper y con fuentes legibles (R6.27)

---

### **Alcance**

#### Incluye

* Reskin completo del grimorio según `WUFrU` (6 áreas) + barra equipada con teclas.

#### No incluye

* Lógica de skills/asignación (R5.1 intactos); ni los iconos de skill nuevos (ASSETS_LIST existente).

---

### **Definition of Done (DoD)**

* [ ] Grimorio replica el frame `WUFrU` (libro, 6 tarjetas por rareza, filtros, barra equipada 1–4).
* [ ] Tarjetas con datos reales (coste/CD/rango/fuente/escalado/asignación).
* [ ] Nombres de instancias conservados; asignación/filtros intactos (sin errores rojos).
* [ ] Móvil OK y fuentes legibles (R6.27).
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Estimación (orientativa)**

2 sesiones del dev: reskin del libro + tarjetas + barra equipada + estados.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-ESTETICA-42: reskin del grimorio estilo libro WoW (frame `WUFrU` aprobado) — encabezado, página con 6 tarjetas por rareza (tipo/coste/CD/rango/fuente/escalado/asignación con datos reales), filtros y **barra equipada 1–4** coherente con la skill bar del HUD; sustituye el visual de EST-17 |