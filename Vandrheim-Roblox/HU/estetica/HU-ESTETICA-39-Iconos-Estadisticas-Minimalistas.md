# HU-ESTETICA-39: Iconos minimalistas de estadísticas (diseñador)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / Iconografía
**Prioridad:** Media
**Estado:** Implementada (reporte PO 2026-09-22; verificación/QA pendiente)
**Tipo:** Producción de iconos 2D (diseñador) — el dev los referencia por config (ASSETS_LIST)
**Fase GDD:** UI (acompaña a tooltips de ítems/skills, panel de stats y party frame)
**Depende de:** HU-ESTETICA-13 (tokens/fuentes), HU-R6.27 (mejoras de tooltips — casillas y legibilidad), ASSETS_POLICY (estándar de iconos: **fondo TRANSPARENTE desde 2026-09-22**), ASSETS_LIST
**No modifica:** lógica ni stats (solo assets)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** ver cada estadística con su **icono minimalista** en los tooltips y paneles (stats, equipo, party),
**para** identificar de un vistazo qué significa cada número (ATK, DEF, vida, etc.) sin leer.

---

### **Descripción del Requerimiento / Contexto**

Los tooltips y paneles muestran las estadísticas como texto plano (ej. "ATK 20/5", "DEF 13/5", "CRIT 5 %"). Con la mejora de legibilidad (R6.27) se agregan **iconos minimalistas por estadística** que acompañan el texto.

**Criterio de hecho global:** existe un set de **iconos minimalistas** (uno por estadística/valor), con **fondo transparente** (estándar vigente), estilo consistente y legible en fondos oscuros — registrados para referenciar por `iconId`.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Lista de iconos (9)**

| # | Icono | Uso | Concepto sugerido |
|---|-------|-----|-------------------|
| 1 | `Icon_Stat_ATK` | Daño físico (espadas/arco/armas 1H-2H) | Espada cruzada / espada simple |
| 2 | `Icon_Stat_MATK` | Daño mágico (varita, skills de magia) | Varita con estrella / pentagrama sutil |
| 3 | `Icon_Stat_DEF` | Defensa física | Escudo simple |
| 4 | `Icon_Stat_MDEF` | Defensa mágica | Escudo con runa / escudo con aura |
| 5 | `Icon_Stat_MaxHP` | Vida máxima | Corazón / escudo-corazón |
| 6 | `Icon_Stat_MaxMP` | Maná máximo | Gota / frasco con espíritu |
| 7 | `Icon_Stat_CRIT` | Prob. de golpe crítico | Dardo de precisión / estrella de 4 puntas |
| 8 | `Icon_Stat_GOLD` | Oro (tooltips de vendor/subasta) | Moneda estilo vikingo (círculo + cruz/martillo) |
| 9 | `Icon_Stat_XP` | Experiencia/nivel | Gema / estrellas ascendentes |

#### **2. Estilo (minimalista, obligatorio)**

* **Minimalista lineal:** trazo fino y limpio (estilo "icon line"), **sin rellenos complejos**, sin sombras exteriores, sin texto, sin marco.
* **Monocolor claro:** trazo en tono **pergamino claro** (`#F4EDE0` / gama EST-13) para contraste sobre los fondos oscuros del juego (`#15100D`/`#211916`); se puede variar el tono según la familia (ej. vida = tinte frío, mana = tinte azul pálido) **sin romper la familia visual**.
* **Consistencia de familia:** mismo grosor de trazo, mismo peso visual y misma proporción (~80 % del encuadre, centrado) entre los 9 — se ven como una familia.
* **Formato:** **PNG 128×128 (o 256 para nitidez), FONDO TRANSPARENTE** (decisión 2026-09-22 — nunca fondo negro ni de color).
* Legibles a tamaño pequeño (16–24 px en tooltips, 24–32 px en paneles) — prueba de reducción incluida en la entrega.

#### **3. Entrega**

* Archivos `Icon_Stat_*.png` en `Assets/Temp/HU-ESTETICA-39/` + registro en `ASSETS_LIST.md`/`ASSETS_REGISTRY` (naming exacto de la tabla).
* Sin scripts; solo assets.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Set completo**

* **GIVEN** la entrega
* **WHEN** se revisan los archivos
* **THEN** existen los **9 iconos** con los nombres exactos de la tabla (`Icon_Stat_*`)

#### **Escenario 2: Minimalista y legible**

* **GIVEN** un icono a tamaño pequeño (16–24 px)
* **WHEN** se reduce
* **THEN** se identifica la estadística sin esfuerzo (trazo limpio, sin ruido)

#### **Escenario 3: Fondo transparente**

* **GIVEN** los iconos
* **WHEN** se inspecciona el canal alfa
* **THEN** son **transparentes** (nunca negro ni color de fondo) — estándar vigente

#### **Escenario 4: Familia consistente**

* **GIVEN** los 9 iconos juntos
* **WHEN** se comparan
* **THEN** comparten grosor, peso visual y proporción (se ven como una familia)

#### **Escenario 5: Registro**

* **GIVEN** la entrega
* **WHEN** se review ASSETS_LIST
* **THEN** los 9 quedan registrados con sus nombres canónicos (el dev los referencia por `iconId`)

---

### **Alcance**

#### Incluye

* 9 iconos minimalistas de estadísticas (transparentes) + registro en ASSETS_LIST.
* Prueba de legibilidad a tamaño pequeño.

#### No incluye

* Rediseños de tooltips/paneles (R6.27 lo maneja); ni iconos de skills/ítems (otros flujos).

---

### **Definition of Done (DoD)**

* [ ] 9 iconos `Icon_Stat_*` entregados (PNG transparente, minimalista, familia consistente).
* [ ] Legibles a 16–24 px; registrados en ASSETS_LIST/ASSETS_REGISTRY.
* [ ] Reporte al PM con el detalle y pendientes.

---

### **Estimación (orientativa)**

1 sesión del diseñador: los 9 iconos + registro.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-ESTETICA-39 (renumerada de 38 por colisión con EST-38 Panel-Muerte): iconos minimalistas de estadísticas — 9 iconos (`Icon_Stat_ATK/MATK/DEF/MDEF/MaxHP/MaxMP/CRIT/GOLD/XP`), trazo fino monocolor pergamino, **fondo transparente** (estándar vigente), legibles a 16–24 px; acompañan a los tooltips mejorados de R6.27 |