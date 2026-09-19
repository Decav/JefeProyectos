# HU-ESTETICA-11: Panel de Mochila (tecla B) — diseño de UI en Pencil ("como se vería en el juego")

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / EST-04 (diseño a fondo de pantallas)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Diseño de UI en Pencil (solo diseñador; **sin desarrollo, sin código**)
**Fase GDD:** EST (transversal; independiente de R8a–R8c)
**Depende de:** HU-ESTETICA-04 (dirección "Hearthbound Gold", componentes y tokens), HU-R6.5 (mochila B, 20 slots), HU-R5.2 (stacking/pilas), HU-R4 (tooltips, BoE, rarezas), HU-R6.2 (slots rápidos Z/X), HU-ITEMS-01 (ítems nuevos)
**No modifica:** lógica del juego, inventario, stacking ni balance

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** ver mi mochila tal como se vería implementada: 20 casillas con pilas, rarezas, cantidades y tooltips, y saber qué ítem tengo asignado a los atajos Z/X,
**para** encontrar y usar mi equipo, pociones y objetos sin confusión.

**Como** equipo de desarrollo,
**quiero** un diseño de pantalla completo y a fondo de la mochila,
**para** implementarla sin reinterpretar nada y que gestionar el inventario sea intuitivo.

---

### **Descripción del Requerimiento / Contexto**

El diseño actual de la mochila en `Vandrheim-design.pen` (pantalla 02) muestra 20 casillas genéricas con una nota de rareza, sin contenido real ni estados. Esta HU desarrolla la mochila **a fondo**, con el aspecto final que tendría en el juego, usando el sistema real:

* **20 slots** (R6.5): cada slot representa **una pila** (R5.2) — pociones hasta `x20`, equipo `x1`; usar o vender descuenta **1 unidad** de la pila.
* **Rarezas (R4):** Common (blanco), Uncommon (verde), Rare (azul), Epic (morado) — marco de rareza por ítem.
* **Ítems (R4 + R7 + ITEMS-01):** pociones HP/MP, espadas y escudo, arco, sets Paladín/Cazador/Clérigo, varita, collar, anillo y uniques del boss (Filo de la Escarcha, Arco del Vendaval Helado, Vara del Invierno).
* **Tooltip de ítem (R4):** nombre, rareza, stats base+roll, afijos, `levelReq`, BoE ("Se liga al equipar"), descripción.
* **Slots rápidos Z/X (R6.2):** el jugador asigna un ítem utilizable (poción) a Z o X; la mochila debe marcar cuál está asignado.
* **Acciones:** usar (consumible), equipar (gear), vender (1 unidad, R5.2). **No existe ordenar/sortear** en el juego — no se diseña.

**Criterio de hecho global:** existe en el `.pen` una mochila completa y realista — con el contenido real de una build, pilas con cantidades, tooltip, acciones y estados — lista para que el dev la implemente sin rediseñar.

---

### **Especificaciones Técnicas / Contratos de API (visual)**

#### **1. Pantalla a diseñar (frame nuevo en el `.pen`)**

Ventana de mochila (patrón actual: grid de 20 slots; coherente con Hearthbound Gold, `Scale` + `UIAspectRatioConstraint` en implementación):

* **Header:** título "Mochila", y (si aplica) el oro del jugador y/o la cantidad de espacios libres ("3/20").
* **Grid de 20 casillas** (5×4, casillas de ~44px como el patrón actual):
  * **Vacía:** casilla oscura con borde.
  * **Ocupada:** icono real (estilo ASSETS_LIST o placeholder), **cantidad de pila** `xN` (solo si >1) y **marco de rareza**.
  * **Pila máxima** (ej. pociones x20) diferenciable si ayuda a la legibilidad.
* **Tooltip de ítem (hover):** nombre, marco de rareza, stats/afijos, `levelReq`, BoE y descripción — patrón del tooltip de R4/EST-04.
* **Acciones representadas:** click derecho o botones en el tooltip: **Usar** (consumibles), **Equipar** (gear — si el slot está libre o reemplaza), **Vender** (1 unidad, muestra el precio de venta).
* **Slots Z/X conectados:** el ítem asignado a Z o X se marca en su casilla (ej. "Z" / "X" en la esquina) y un detalle mínimo de los atajos si ayuda (ej. pie o nota: "Z/X usan el ítem asignado").
* **Estados obligatorios:** mochila con mezcla de pilas (pociones x20, ítems x1, vacíos), mochila **vacía**, mochila **llena** (20 pilas), casilla con ítem asignado a Z/X, y tooltip abierto con acciones visibles.

#### **2. Contenido real del mockup (obligatorio)**

Diseñar la mochila con el contenido **real** de una build de referencia (para que se vea como en el juego):

* **Ejemplo principal: Paladín — Castigo, nivel 16** — mochila con 12 de 20 casillas ocupadas:

| Casilla | Ítem | Pila | Rareza |
|---------|------|------|--------|
| 1 | Poción de HP | x20 | Blanco |
| 2 | Poción de MP | x8 | Blanco |
| 3 | Espada del campeón | x1 | Epic (morado) |
| 4 | Espada del caballero | x1 | Rare (azul) |
| 5 | Escudo del guardián | x1 | Uncommon (verde) |
| 6 | Coraza de cuero | x2 | Blanco |
| 7 | Pecho del Cazador | x1 | Rare (azul) |
| 8 | Varita del Clérigo | x1 | Blanco |
| 9 | Collar | x1 | Blanco |
| 10 | Anillo | x1 | Blanco |
| 11 | Filo de la Escarcha (unique) | x1 | Epic (morado) |
| 12 | Poción de HP **asignada a Z** | x20 | Blanco (marcada "Z") |

* **Escenario del mockup:** mezcla de pilas y rarezas, la casilla 12 marcada con "Z", **tooltip abierto** sobre la Espada del campeón (Epic: ATK 12–17, afijos "+10 ATK +5 CRIT" — con roll, BoE "Se liga al equipar", levelReq 1) con botones Usar/Equipar/Vender.
* **Mockups adicionales dentro de la misma pantalla (estados):**
  * Mochila vacía (0/20, mensaje claro).
  * Mochila llena (20/20) con feedback visual.
  * Tooltip de una poción (Mostrar "Usar 1 de 20" y precio de venta por unidad).

#### **3. Reglas**

* Trabajar en `Vandrheim-design.pen` en un **frame propio de esta HU** (o pantalla nueva dentro de `DX7OA`); no rehacer las pantallas existentes.
* Usar la paleta/tokens de EST-04 (fondos, latón `#C89445`, pergamino `#F4EDE0`, colores de rareza), tipografías Geist Mono / Playfair Display / Inter.
* Reutilizar y **mejorar** componentes exportables si hace falta (casilla, tooltip, botón 3 estados) — sin romper los existentes.
* No inventar mecánicas (sin ordenar, sin filtros, sin pestañas de categoría si no existen).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: La mochila se ve implementada**

* **GIVEN** la pantalla de mochila diseñada
* **WHEN** se mira la pantalla con el mockup de Paladín nivel 16
* **THEN** se ven las 20 casillas con pilas (`xN`), marcos de rareza y espacios vacíos
* **AND** el contenido refleja ítems reales del juego

#### **Escenario 2: Tooltip y acciones**

* **GIVEN** una casilla con ítem
* **WHEN** se abre el tooltip
* **THEN** muestra nombre, rareza, stats/afijos, levelReq, BoE y acciones (Usar/Equipar/Vender con precio por unidad)

#### **Escenario 3: Slots Z/X**

* **GIVEN** un ítem asignado al atajo Z o X
* **WHEN** se revisa su casilla
* **THEN** la casilla lo marca (Z/X) y se entiende que el atajo usa ese ítem

#### **Escenario 4: Estados extremos**

* **GIVEN** la mochila diseñada
* **WHEN** se revisan los estados vacío y lleno
* **THEN** se distinguen sin texto y no rompen el layout

#### **Escenario 5: Fiel al sistema**

* **GIVEN** el diseño de la mochila
* **WHEN** se compara con el sistema real (20 slots = 20 pilas, maxStack, uso/venta de 1 unidad, rarezas, BoE)
* **THEN** el diseño refleja esas reglas sin inventar mecánicas ni datos

---

### **Comportamiento Visual / Reglas de Negocio**

* Es diseño puro: no define lógica, stacking, remotes ni balance.
* Cada casilla comunica pila y rareza de un vistazo; el tooltip lleva el detalle.
* Los atajos Z/X se leen sin abrir nada.
* Los iconos siguen el estándar ASSETS_LIST (fondo negro) o placeholder equivalente.

---

### **Alcance**

#### Incluye

* Mochila completa en el `.pen` con el mockup de Paladín nivel 16 (12/20 casillas con contenido real).
* Pilas `xN`, marcos de rareza, casilla vacía/ocupada, marcado de atajos Z/X.
* Tooltip de ítem con stats/afijos/levelReq/BoE y acciones (Usar/Equipar/Vender 1 unidad).
* Estados: vacía, llena, pila máxima, ítem asignado a Z/X.
* Mejora de componentes exportables si es necesaria (casilla, tooltip) sin romper los de EST-04.

#### No incluye

* Código, remotes, lógica de inventario/stacking ni cambios a balance (dev).
* Mecánicas inexistentes (ordenar, filtrar, pestañas de categoría, trade).
* Cambios a las otras pantallas del `.pen` ni a la dirección aprobada.
* La ventana de vendor (HU-ESTETICA-12), equipo/stats (10), talentos (08) ni grimorio (09) — HUs independientes.

---

### **Definition of Done (DoD)**

* [ ] Mochila completa en el `.pen` con el mockup de Paladín nivel 16 (contenido real).
* [ ] Pilas `xN`, marcos de rareza y estados vacío/ocupado/lleno se distinguen sin texto.
* [ ] Tooltip con stats/afijos/levelReq/BoE y acciones (Usar/Equipar/Vender 1 unidad con precio).
* [ ] Atajos Z/X marcados en la casilla del ítem asignado.
* [ ] Fiel a las reglas reales (20 pilas, maxStack, uso/venta 1 unidad, rarezas, BoE) sin inventar mecánicas.
* [ ] Paleta y componentes de Hearthbound Gold respetados.
* [ ] Reporte al PM con el detalle del diseño y pendientes.

---

### **Estimación (orientativa)**

1–2 sesiones del diseñador: mochila completa + estados + mockup con contenido real.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-15 | Creación de HU-ESTETICA-11: diseño a fondo de la mochila (20 slots, pilas, rarezas, tooltips, atajos Z/X, estados) — solo diseñador, sin desarrollo |