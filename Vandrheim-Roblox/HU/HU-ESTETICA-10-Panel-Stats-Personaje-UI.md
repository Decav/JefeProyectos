# HU-ESTETICA-10: Ventana de Equipo y Estadísticas (tecla C) — diseño de UI en Pencil ("como se vería en el juego")

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / EST-04 (diseño a fondo de pantallas)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Diseño de UI en Pencil (solo diseñador; **sin desarrollo, sin código**)
**Fase GDD:** EST (transversal; independiente de R8a–R8c)
**Depende de:** HU-ESTETICA-04 (dirección "Hearthbound Gold", componentes y tokens), HU-R6.5 (panel de stats en Equipo), HU-R2 (stats base por clase), HU-R4 (stats de equipo), HU-R5.1 (stats de talentos), SKILLS_CATALOG v2.2 (stats soportadas: ATK, MATK, MaxHP, MaxMP, DEF, CRIT, CDR)
**No modifica:** lógica del juego, cálculo de stats ni balance

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** ver mis estadísticas tal como se verían implementadas: valores totales y de dónde vienen (clase, equipo, talentos), junto a mi nivel y progreso de XP,
**para** entender por qué mis números son los que son y tomar decisiones de equipo y talentos.

**Como** equipo de desarrollo,
**quiero** un diseño de pantalla completo y a fondo del panel de stats,
**para** implementarlo sin reinterpretar nada y que el jugador entienda su personaje de un vistazo.

---

### **Descripción del Requerimiento / Contexto**

Hoy la tecla **`C` abre una sola ventana** que combina el equipo del personaje (9 slots: casco, pecho, hombreras, piernas, guantes, collar, anillo, mano derecha e izquierda) con el panel de estadísticas. El diseño actual de esa ventana en `Vandrheim-design.pen` muestra los slots y 7 filas de números, pero **no conecta el equipo activo con las stats**: no se ve qué ítem puesto aporta cada punto.

Esta HU desarrolla **la ventana completa de Equipo (`C`)** — equipo activo + estadísticas como una sola pantalla, con el aspecto final que tendría en el juego, usando el sistema real:

* **Cálculo de stats (R2 + R4 + R5.1):** stats = **clase base** + **equipo activo** (R4, base + rolls) + **talentos** (pasivos +% o +fijos).
* **Equipo activo:** los ítems equipados en los 9 slots (R4/EST-01/ITEMS-01) — cada pieza aporta stats con su icono y rareza.
* **Stats del framework (v2.2):** HP/MaxHP, MP/MaxMP, ATK, MATK, DEF, MDEF, CRIT (y CDR si aplica) — confirmados en `ClassConfig`/atributos.
* **Nivel y XP:** progresión de R6a (nivel + barra de XP con el siguiente nivel).

**Criterio de hecho global:** existe en el `.pen` la ventana de Equipo (`C`) completa y realista — slots con el equipo activo de una build + stats con desglose que **cita los ítems puestos** — lista para que el dev la implemente sin rediseñar.

---

### **Especificaciones Técnicas / Contratos de API (visual)**

#### **1. Pantalla a diseñar (frame nuevo en el `.pen`)**

**Ventana de Equipo (`C`) completa** — una sola pantalla en **dos columnas** que combina el equipo activo y las estadísticas, **con desglose bajo demanda** (decisión PM 2026-09-15; coherente con Hearthbound Gold, `Scale` + `UIAspectRatioConstraint` en implementación):

* **Tamaño de referencia:** ~480×320 (más grande que el template de 430×260 para respirar, pero **máximo ~85% de la pantalla en móvil**; el board de diseño crece, la ventana en juego no).
* **Header de identidad:** nombre del PJ, clase, **spec activa**, nivel, y **barra de XP** con "XP actual / XP para el próximo nivel" (ej. "1,240 / 2,000").
* **Columna izquierda — Equipo:** los **9 slots** con etiquetas y separador (patrón actual R6.5/EST-04): casco, pecho, hombreras, piernas, guantes, collar, anillo, mano derecha e izquierda — cada slot **con el ítem activo puesto** (icono real, marco de rareza) y el estado vacío visible.
* **Conexión equipo → stats:** al seleccionar/hover un slot o ítem, la stat que aporta **se resalta** en la columna de stats (el tooltip del ítem indica "+17 ATK" y la fila de ATK se ilumina).
* **Columna derecha — Stats (compacta):** stats agrupadas y etiquetadas con **filas compactas** (icono + nombre + valor total destacado):
  * **Recursos:** HP y MP (máximos).
  * **Ataque:** ATK, MATK, CRIT.
  * **Defensa:** DEF, MDEF.
  * (CDR si aplica o se deja visible con 0).
* **Desglose bajo demanda (no siempre visible):** al hacer hover/expandir una fila (flecha o tooltip), se muestra el detalle **"Base + <ítem(s) del equipo> + Talentos"** citando los ítems puestos (ej. "ATK 112 = 85 + **Espada del campeón** +17 + **Fervor** +10"). Las filas nunca muestran el desglose permanente.
* **Tooltip por stat:** qué es, qué ítems equipados la aportan y qué talentos la afectan.
* **Estados obligatorios:** ventana con build completa (slots llenos + desglose visible en una fila expandida), ventana con slots vacíos (solo clase base), y slot seleccionado resaltando su stat.

#### **2. Contenido real del mockup (obligatorio)**

Diseñar la ventana con el **equipo activo real de una build de referencia** (para que se vea como en el juego):

* **Ejemplo principal: Paladín — Castigo, nivel 16**, con **9 slots poblados**: espada del campeón (Epic, ATK 12–17 con roll) en mano derecha, escudo del guardián en mano izquierda, yelmo/hombreras/grebas/guantes del Paladín, collar y anillo (ITEMS-01); talentos de Castigo (Fervor +4% ATK ×2 ranks, Ardor sagrado +4% MATK ×2, Tenacidad +5% MaxHP, Foco divino +5% MaxMP).

| Stat | Total | Desglose (ejemplo ilustrativo, citando ítems) |
|------|-------|--------------------------------|
| MaxHP | 1,050 | 800 base + 120 equipo (yelmo/grebas/collar) + 130 talentos (Tenacidad) |
| MaxMP | 840 | 700 base + 40 equipo (collar) + 100 talentos (Foco divino) |
| ATK | 112 | 85 base + 17 equipo (**Espada del campeón**) + 10 talentos (Fervor 8%) |
| MATK | 96 | 72 base + 16 equipo (anillo) + 8 talentos (Ardor sagrado 8%) |
| DEF | 68 | 52 base + 14 equipo (yelmo/hombreras/grebas/guantes/escudo) + 2 talentos |
| CRIT | 12% | 5% base + 5% equipo (espada/escudo) + 2% talentos (Llamas ardientes) |
| CDR | 0% | 0 base + 0 equipo + 0 talentos |

* **Escenario del mockup:** todos los slots llenos con los ítems reales (iconos + marcos de rareza), stats compactas (icono+nombre+valor), **una fila expandida** (ej. ATK) mostrando el desglose que cita los ítems puestos, y **un slot seleccionado** (ej. Espada del campeón) con su aporte resaltado en la fila ATK; barra de XP a mitad (1,240/2,000) y nivel 16 destacado.
* **Mockups adicionales dentro de la misma pantalla (estados):**
  * PJ nivel 1 **sin equipo** (slots vacíos) — solo clase base.
  * Tooltip abierto sobre un ítem del slot (ej. espada: "+17 ATK, +5 CRIT, Epic") y sobre una stat (ATK con sus fuentes).
  * Variante con CDR > 0 (si se quiere mostrar la stat con talentos de CDR).

#### **3. Reglas**

* Trabajar en `Vandrheim-design.pen` en un **frame propio de esta HU** (o pantalla nueva dentro de `DX7OA`); no rehacer las pantallas existentes.
* Usar la paleta/tokens de EST-04 (fondos, latón `#C89445`, pergamino `#F4EDE0`), tipografías Geist Mono / Playfair Display / Inter.
* Coherencia con el panel de stats del Equipo (EST-06): mismas stats y orden visual; si este panel es más rico (desglose), el de Equipo puede quedarse resumido.
* Los números son **ilustrativos** (build de referencia); el diseñador no cambia stats ni balance.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: El panel se ve implementado**

* **GIVEN** el panel de estadísticas diseñado
* **WHEN** se mira la pantalla con el mockup de Paladín Castigo nivel 16
* **THEN** se ven las stats reales agrupadas (Recursos/Ataque/Defensa) con valor total destacado
* **AND** la barra de XP y el nivel se leen sin esfuerzo

#### **Escenario 2: Desglose de fuentes bajo demanda**

* **GIVEN** una build con clase + equipo + talentos
* **WHEN** se expande/hace hover sobre una fila de stat
* **THEN** se ve el total y el desglose Base + ítems + Talentos (citando qué ítem lo aporta)
* **AND** las filas en reposo se mantienen compactas (icono + nombre + valor), sin texto de desglose permanente

#### **Escenario 3: Estados sin fuentes**

* **GIVEN** un PJ nivel 1 sin equipo ni talentos
* **WHEN** se revisa el panel
* **THEN** se ve solo la clase base, sin números fantasma ni filas vacías confusas

#### **Escenario 4: Tooltip**

* **GIVEN** el panel diseñado
* **WHEN** se abre el tooltip de una stat
* **THEN** explica qué es la stat y qué la afecta (base/equipo/talentos)

#### **Escenario 5: Coherencia con la ventana actual (`C`)**

* **GIVEN** la tecla `C` abre hoy una sola ventana con equipo + stats
* **WHEN** se compara el diseño
* **THEN** el diseño es **una sola pantalla** que combina los 9 slots con el equipo activo y el panel de stats (no dos ventanas separadas)

#### **Escenario 6: Equipo activo conectado a las stats**

* **GIVEN** la ventana con el equipo puesto (ej. Espada del campeón)
* **WHEN** se revisa el desglose de ATK
* **THEN** la fila cita el ítem ("+17 **Espada del campeón**") y al seleccionar el slot el aporte se resalta
* **AND** el desglose refleja fielmente el cálculo real (R2 + R4 + R5.1) sin inventar stats ni fórmulas

---

### **Comportamiento Visual / Reglas de Negocio**

* Es diseño puro: no define lógica, cálculo de stats, balance ni cambios al sistema.
* El valor total es lo primero que se lee; el desglose es secundario pero accesible.
* Las stats usan los iconos/colores de la paleta (HP rojo, MP azul, ATK/MATK latón, DEF/MDEF frío, CRIT latón).
* El panel es solo presentación: no cambia stats, inventario ni progresión.

---

### **Alcance**

#### Incluye

* Ventana de Equipo (`C`) completa en el `.pen`: **dos columnas** (~480×320 de referencia, máx ~85% en móvil) — 9 slots con el equipo activo de la build de referencia + stats compactas.
* Secciones agrupadas (Recursos/Ataque/Defensa), valor total destacado y **desglose bajo demanda** (fila expandida/tooltip) que cita los ítems puestos.
* Conexión visual slot ↔ stat (selección/hover resalta el aporte).
* Barra de XP con "actual / próximo nivel".
* Tooltips (de ítem y de stat) y estados (build completa, sin equipo, slot seleccionado, fila expandida).
* Coherencia con el panel resumido actual (R6.5/EST-06) y con los ítems de ITEMS-01/EST-07.

#### No incluye

* Código, remotes, cálculo de stats ni cambios a balance (dev).
* Cambios al sistema de stats ni a las fórmulas (canónico en GDD/R2/R4/R5.1).
* Cambios a las otras pantallas del `.pen` ni a la dirección aprobada.
* El panel de talentos (HU-ESTETICA-08) ni el grimorio (HU-ESTETICA-09) — HUs independientes.

---

### **Definition of Done (DoD)**

* [ ] Ventana de Equipo (`C`) completa en el `.pen` con la build de referencia (Paladín Castigo lvl 16, 9 slots poblados), en dos columnas.
* [ ] Stats compactas con valor total destacado; desglose Base + ítems + Talentos **bajo demanda** (fila expandida/tooltip) citando el equipo puesto.
* [ ] Conexión visual slot ↔ stat (selección/hover resalta el aporte).
* [ ] Barra de XP (actual/próximo) y nivel visibles en el header.
* [ ] Tooltips (ítem y stat) y estados cubiertos (build completa / sin equipo / slot seleccionado / fila expandida).
* [ ] Fiel al cálculo real (R2 + R4 + R5.1) sin inventar stats ni fórmulas.
* [ ] Paleta y componentes de Hearthbound Gold respetados; es una sola ventana como la actual (`C`), con tamaño máx ~85% en móvil.
* [ ] Reporte al PM con el detalle del diseño y pendientes.

---

### **Estimación (orientativa)**

1–2 sesiones del diseñador: panel completo + desglose + estados con la build de referencia.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-15 | Creación de HU-ESTETICA-10: diseño a fondo de la ventana de Equipo (`C`) — 9 slots con el equipo activo + stats con desglose base/ítems/talentos — solo diseñador, sin desarrollo |
| 2026-09-15 | Corrección de alcance: el diseño es **una sola ventana** que combina el equipo activo del PJ y las estadísticas (como la ventana `C` actual), con desglose que cita los ítems puestos y conexión visual slot ↔ stat |
| 2026-09-15 | **Decisión PM (layout):** dos columnas (~480×320 de referencia, máx ~85% en móvil) con filas de stats compactas y **desglose bajo demanda** (fila expandida/tooltip) — evita una ventana sobredimensionada |