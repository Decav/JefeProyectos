# HU-ESTETICA-48: Rediseño del Grimorio — frame Tomo abierto simplificado (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / Grimorio — Rediseño (dev)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Rediseño de UI (dev) — solo visual + navegación local, sin tocar lógica de skills
**Fase GDD:** UI (rediseño del frame del grimorio; la lógica de EST-42/R5.1 queda intacta)
**Depende de:** **HU-ESTETICA-42 (contrato vivo del grimorio: instancias, lógica, datos reales)**, frame del `.pen`: **`D69Fdc — Grimorio · Tomo abierto simplificado`** (verificado en repo), HU-ESTETICA-09/17 (lógica spellbook), HU-R5.1 (skills), HU-R6.27 (fuentes legibles + TooltipSystem), SKILLS_CATALOG, contrato EST-13
**No modifica:** skills, costes, CDs, asignación de barra, filtros lógicos ni lógica (R5.1 intactos)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** el grimorio rediseñado como un tomo abierto simplificado — título, filtros por asignación, contador, tarjetas con formato nuevo, decoración de folio y paginación ‹ ›,
**para** recorrer mis habilidades en un libro claro y legible.

---

### **Descripción del Requerimiento / Contexto**

El diseñador retrabajó completo el frame `D69Fdc — Grimorio · Tomo abierto simplificado` (verificado por diff contra HEAD). El dev lo implementa sobre el grimorio vivo (EST-42), **conservando nombres de instancias y lógica** (contrato EST-13) y usando **datos reales del SKILLS_CATALOG** (regla EST-42: nunca quemados).

Cambios del rediseño (HEAD → nuevo):

| # | Elemento | Antes | Ahora |
|---|----------|-------|-------|
| 1 | Título del libro | "GRIMORIO DE EIRIK" fs=20 | "GRIMORIO" fs=20 |
| 2 | Filtros | 1 tab "NO APRENDIDAS" | 2 tabs: "APRENDIDAS" / "NO ASIGNADAS" fs=8 (**cambio semántico**: filtrar por asignación) |
| 3 | Título de página | "HABILIDADES APRENDIDAS" fs=14 | "HABILIDADES" fs=12 |
| 4 | Contador | no existía | **"6 CONOCIDAS" fs=9 (dato real)** |
| 5 | Formato de coste | "10 MP · CD 4s" fs=8 | "10 maná · CD 4 s" fs=7 |
| 6 | Hint de arrastre | "ARRASTRA UN ICONO DIRECTAMENTE A TU BARRA DE HABILIDADES" | "ARRASTRA UN ICONO A TU BARRA" fs=7.5 |
| 7 | Decoración | 4 bordes folio outer + top edge | **eliminados**; nuevos: costura central, encuadernación y hojas de folio (se mantienen los 6 divisores) |
| 8 | Paginación | no existía | **nodo `QhMEl`: "PÁGINA 1" fs=7 + ‹ › fs=14** |
| 9 | Tarjeta 4 (mockup) | "Sentencia" / "20 MP · CD 8s" | "Bendición sagrada" / "20 maná · CD 12 s" (**⚠️ contradice el catálogo — ver pendiente**) |
| 10 | Tarjeta 5 (mockup) | "Anillo de luz sagrada" | "Anillo de luz" (coste/CD iguales: 25 · 10 s) |

**Criterio de hecho global:** el grimorio se ve como el frame `D69Fdc` rediseñado (título, filtros, contador, tarjetas con formato nuevo, decoración, paginación) — con datos reales y sin romper asignación, filtros ni tooltips.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Encabezado**

* Título "GRIMORIO" fs=20 (sin "DE EIRIK"); línea de personaje y botón × sin cambios.

#### **2. Filtros (cambio semántico)**

* Dos tabs: **"APRENDIDAS"** (todas las aprendidas) y **"NO ASIGNADAS"** (aprendidas no equipadas en barra).
* La lógica de filtrado es client-side sobre las skills aprendidas (sin cambio server); **cambiar de filtro resetea a la página 1**.

#### **3. Página y contador**

* Título "HABILIDADES" fs=12; contador "N CONOCIDAS" fs=9 con el **número real de aprendidas** (nunca quemado).

#### **4. Tarjetas (6 por página)**

* Mismo layout (strip de rareza, tile de icono, nombre fs=10, coste fs=7).
* **Formato de coste nuevo**: "X maná · CD Y s" (palabra "maná" completa, espacios alrededor de "·").
* **Datos 100% reales del SKILLS_CATALOG** (nombre, coste, CD, rango, fuente, escalado, asignación) **de la clase y especialización activa del jugador**.
* **Resuelto (decisión PO 2026-10-16):** los valores de las tarjetas del mockup son **solo diseño/ejemplo** ("Bendición sagrada", "Anillo de luz", etc.). La fuente de verdad es el **SKILLS_CATALOG**: el dev muestra las skills reales de la clase + spec activa del jugador, sin hardcodear los textos del mockup.

#### **5. Hint de arrastre**

* Texto nuevo: "ARRASTRA UN ICONO A TU BARRA" fs=7.5 (el arrastre a la barra funciona igual).

#### **6. Decoración**

* **Quitar**: los 4 bordes folio outer + top edge.
* **Agregar**: costura central, encuadernación y hojas de folio según el diseño; se mantienen los 6 divisores entre tarjetas.

#### **7. Paginación (nodo `QhMEl`)**

* Texto "PÁGINA X" fs=7 + chevrones ‹ › fs=14 en la página izquierda.
* Tamaño de página = tarjetas visibles por página (default: 6); ‹ › con clamp en bordes (deshabilitados en 1ª/última); cambiar de filtro resetea a página 1.
* Controles visibles solo si lo aprendido excede una página; ocultos si no.

#### **8. Reglas**

* **Conservar los nombres de instancias/jerarquía que los scripts usan** (contrato EST-13); instancias nuevas con el mismo patrón.
* Tooltip de skill (TooltipSystem, R6.27 §6) en todas las tarjetas y páginas.
* Móvil: chevrones con área táctil suficiente, textos legibles (R6.27).

---

### **Decisiones cerradas**

* Mockup 100% ilustrativo en datos (decisión PO 2026-10-16): la fuente de verdad es el SKILLS_CATALOG con las skills de la clase + spec activa del jugador.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Rediseño fiel**

* **GIVEN** el grimorio rediseñado
* **WHEN** se compara con el frame `D69Fdc`
* **THEN** replica título, filtros APRENDIDAS/NO ASIGNADAS, contador, tarjetas con formato nuevo, decoración y paginación (colores/fuentes del diseño)

#### **Escenario 2: Datos reales**

* **GIVEN** las tarjetas y el contador
* **WHEN** se revisan
* **THEN** nombre/coste/CD/rango/fuente/escalado/asignación y el "N CONOCIDAS" salen del SKILLS_CATALOG/config (sin datos quemados; tarjeta 4 según el default del pendiente)

#### **Escenario 3: Filtros por asignación**

* **GIVEN** el tab NO ASIGNADAS
* **WHEN** se activa
* **THEN** muestra solo aprendidas no equipadas; APRENDIDAS muestra todas; al cambiar, vuelve a página 1

#### **Escenario 4: Paginación**

* **GIVEN** más aprendidas que las que entran en una página
* **WHEN** se pulsa › / ‹
* **THEN** cambian las tarjetas, el "PÁGINA X" se actualiza y los bordes se deshabilitan; con una sola página los controles no se muestran

#### **Escenario 5: Asignación intacta**

* **GIVEN** el grimorio rediseñado
* **WHEN** se asigna/desasigna desde cualquier página o filtro y se arrastra a la barra
* **THEN** funciona igual que antes (R5.1 sin cambios; sin errores rojos)

#### **Escenario 6: Móvil**

* **GIVEN** el grimorio en móvil
* **WHEN** se navega, filtra y pagina
* **THEN** todo responde al toque y se lee bien (R6.27)

---

### **Alcance**

#### Incluye

* Rediseño completo según `D69Fdc`: encabezado, filtros por asignación, contador real, formato de coste, hint, decoración (quitar/agregar) y paginación.
* Instancias nuevas con nombres según contrato EST-13; datos reales en todo.

#### No incluye

* Lógica de skills/asignación/filtros server (R5.1 intactos); ni iconos nuevos.
* Crear la skill "Bendición sagrada" ni cambiar el catálogo (pendiente aparte si aplica).
* Tooltips nuevos (TooltipSystem existente).

---

### **Definition of Done (DoD)**

* [ ] Grimorio replica el frame `D69Fdc` rediseñado (título, filtros, contador, formato, decoración, paginación).
* [ ] Filtros APRENDIDAS/NO ASIGNADAS filtran por asignación y resetean a página 1.
* [ ] Contador y tarjetas con datos reales (mockup ilustrativo; manda el catálogo).
* [ ] Paginación con clamp, oculta con una sola página.
* [ ] Nombres de instancias según EST-13; asignación/filtros/tooltips intactos (sin errores rojos).
* [ ] Móvil OK y fuentes legibles (R6.27).
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Estimación (orientativa)**

2 sesiones del dev: rediseño completo + filtros + contador + paginación + regresión.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-10-16 | Creación de HU-ESTETICA-48: paginación del grimorio (nodo `QhMEl`) — ‹ › + "PÁGINA X", navegación local |
| 2026-10-16 | **Ampliación al rediseño completo del frame `D69Fdc`**: título, filtros APRENDIDAS/NO ASIGNADAS, contador real, formato "X maná · CD Y s", hint, decoración (quitar bordes/agregar folio) + conflicto mockup vs catálogo en tarjeta 4 |
| 2026-10-16 | **Conflicto cerrado (decisión PO):** el mockup es solo diseño; la fuente de verdad es el SKILLS_CATALOG con las skills de la clase + spec activa del jugador |
