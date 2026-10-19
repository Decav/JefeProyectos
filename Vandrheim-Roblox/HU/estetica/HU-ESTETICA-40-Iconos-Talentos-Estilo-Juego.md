# HU-ESTETICA-40: Iconos de estadísticas estilo juego (pintados) para el Árbol de Talentos (diseñador)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / Talento
**Prioridad:** Media
**Estado:** Implementada (reporte PO 2026-09-22; verificación/QA pendiente)
**Tipo:** Producción de iconos 2D (diseñador) — el dev los referencia por config
**Fase GDD:** Talentos (nodos de mejora estadística del árbol)
**Depende de:** HU-ESTETICA-39 (mismos stats, estilo minimalista — este set es el **formato de juego**), HU-ESTETICA-16 (talentos dev/panel), ASSETS_LIST (estándar de iconos de juego) + **fondo TRANSPARENTE (decisión 2026-09-22)**
**No modifica:** lógica ni stats (solo assets)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que cada nodo de mejora estadística del **árbol de talentos** tenga su **imagen de juego** (mismo estilo que las habilidades/ítems),
**para** caracterizar de un vistazo qué mejora cada mejora (ATK, vida, crítico…) y que el árbol se vea como parte del mismo mundo.

---

### **Descripción del Requerimiento / Contexto**

El árbol de talentos (EST-16) mostrará los nodos de mejora estadística. Este set usa el **formato normal del juego** (iconos pintados estilo habilidad/ítem — ASSETS_LIST), **distinto** del set minimalista de **EST-39** (que es para tooltips/paneles).

**Criterio de hecho global:** existen los iconos de juego de las estadísticas (uno por nodo de mejora), con estilo pintado de ASSETS_LIST y **fondo transparente** (estándar vigente), listos para referenciar en el árbol.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Lista de iconos (9, mismos stats que EST-39)**

| # | Icono | Nodo del árbol |
|---|-------|----------------|
| 1 | `Icon_Talent_ATK` | Mejora de daño físico |
| 2 | `Icon_Talent_MATK` | Mejora de daño mágico |
| 3 | `Icon_Talent_DEF` | Mejora de defensa física |
| 4 | `Icon_Talent_MDEF` | Mejora de defensa mágica |
| 5 | `Icon_Talent_MaxHP` | Mejora de vida máxima |
| 6 | `Icon_Talent_MaxMP` | Mejora de maná máximo |
| 7 | `Icon_Talent_CRIT` | Mejora de crítico |
| 8 | `Icon_Talent_GOLD` | Mejora económica (si el árbol lo usa) |
| 9 | `Icon_Talent_XP` | Mejora de experiencia (si el árbol lo usa) |

#### **2. Estilo (formato NORMAL del juego — ASSETS_LIST)**

* **Pintado digital** estilo MMO (WoW/Diablo — misma familia que las habilidades y ítems): detalle fino, iluminación de fantasía, gama de acero frío azulado + cuero oscuro + dorado cálido (paleta Vandrheim). No cartoon.
* Objeto/escena central **~85 % del encuadre**, centrado, perspectiva 3/4 — como icono de inventario.
* **Sin marco, sin borde, sin texto, sin UI, sin sombra exterior, sin personajes ni manos.**
* **FONDO TRANSPARENTE** (decisión PO 2026-09-22 — los iconos nuevos ya no llevan fondo negro).
* Elemento sugerido por stat (concepto): ATK = espada/arma de filo · MATK = varita/runa mágica · DEF = escudo de forja · MDEF = escudo encantado con runas · MaxHP = corazón/cristal de vida tallado · MaxMP = gota/frasco de maná con runas · CRIT = dardo/estrella de precisión · GOLD = moneda vikinga tallada · XP = gema ascendente.
* **Formato:** PNG 512×512, transparente.

#### **3. Entrega**

* Archivos canónicos en `Assets/Icons/Talents/`; procedencia aprobada se archiva en `Assets/Source/Design/HU-ESTETICA-40/` si existe.
* Sin scripts; solo assets.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Set completo**

* **GIVEN** la entrega
* **WHEN** se revisan los archivos
* **THEN** existen los **9 iconos** con los nombres exactos (`Icon_Talent_*`)

#### **Escenario 2: Estilo de juego**

* **GIVEN** un icono
* **WHEN** se compara con un icono de skill/ítem existente
* **THEN** comparte la misma familia visual (pintado, paleta Vandrheim, proporción ~85 %)

#### **Escenario 3: Distinto del set minimalista**

* **GIVEN** Icon_Talent_* vs Icon_Stat_* (EST-39)
* **WHEN** se comparan
* **THEN** se distinguen claramente (pintado vs lineal) — cada uno para su uso

#### **Escenario 4: Fondo transparente**

* **GIVEN** los iconos
* **WHEN** se inspecciona el canal alfa
* **THEN** son **transparentes** (nunca negro ni color de fondo) — estándar vigente

#### **Escenario 5: Legible en el árbol**

* **GIVEN** un nodo del árbol con el icono a tamaño de nodo
* **WHEN** se reduce
* **THEN** la estadística se identifica sin esfuerzo

#### **Escenario 6: Registro**

* **GIVEN** la entrega
* **WHEN** se review ASSETS_LIST
* **THEN** los 9 quedan registrados con sus nombres canónicos

---

### **Alcance**

#### Incluye

* 9 iconos de juego de estadísticas (pintados, transparentes) + registro en ASSETS_LIST.

#### No incluye

* El set minimalista (EST-39) ni rediseños del árbol (EST-16).

---

### **Definition of Done (DoD)**

* [ ] 9 iconos `Icon_Talent_*` entregados (PNG 512×512 transparente, estilo ASSETS_LIST).
* [ ] Familia visual coherente con skills/ítems; legibles en el nodo del árbol.
* [ ] Registrados en ASSETS_LIST/ASSETS_REGISTRY.
* [ ] Reporte al PM con el detalle y pendientes.

---

### **Estimación (orientativa)**

1–2 sesiones del diseñador: los 9 iconos pintados + registro.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-ESTETICA-40: iconos de estadísticas **estilo juego** para el Árbol de Talentos — 9 iconos (`Icon_Talent_ATK/MATK/DEF/MDEF/MaxHP/MaxMP/CRIT/GOLD/XP`), pintados (estándar ASSETS_LIST, misma familia que skills/ítems), **fondo transparente** (decisión 2026-09-22), legibles en el nodo; complementa al set minimalista EST-39 (tooltips/paneles) |
| 2026-09-22 | **Producidos y subidos (diseñador):** 8 iconos con `rbxassetid` registrados en ASSETS_LIST — ATK, MATK, DEF, MDEF, MaxHP, MaxMP, CRIT y **CDR (agregado al set: existe como stat y el capstone de Fuego da +3 % CDR)**; **GOLD/XP quedan fuera** (ningún talento actual los usa). Los nodos del árbol (EST-41) se enlazan por `iconId` |
