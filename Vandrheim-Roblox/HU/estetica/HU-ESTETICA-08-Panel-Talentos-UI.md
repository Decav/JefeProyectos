# HU-ESTETICA-08: Panel de Talentos — diseño de UI en Pencil (árbol WoW, "como se vería en el juego")

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / EST-04 (diseño a fondo de pantallas)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Diseño de UI en Pencil (solo diseñador; **sin desarrollo, sin código**)
**Fase GDD:** EST (transversal; independiente de R8a–R8c)
**Depende de:** HU-ESTETICA-04 (dirección "Hearthbound Gold", componentes y tokens), HU-R5.1 (árbol de talentos v2), SKILLS_CATALOG v2.2 (árboles finales de las 6 specs), HU-R5 (respec con oro)
**No modifica:** lógica del juego, TalentConfig, balance ni specs

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** ver el árbol de talentos tal como se vería implementado en el juego: ramas conectadas, nodos con estados, puntos disponibles y tooltips,
**para** entender de un vistazo qué puedo aprender, qué me falta y cómo gastar mis puntos.

**Como** equipo de desarrollo,
**quiero** un diseño de pantalla completo y a fondo (no solo círculos sueltos),
**para** implementar la ventana sin reinterpretar nada y que el jugador la entienda sin explicaciones.

---

### **Descripción del Requerimiento / Contexto**

El diseño actual de la ventana de talentos en `Vandrheim-design.pen` es **demasiado general**: muestra círculos sin conexiones ni estados, y no se puede imaginar cómo quedaría implementada. Esta HU desarrolla el panel **a fondo**, con el aspecto final que tendría en el juego, usando el sistema real de talentos:

* **Estructura (R5.1 / SKILLS_CATALOG v2.2):** 3 ramas × 3 nodos por spec (Nodo 1 → Nodo 2 → Capstone), con prerequisitos directos (≥1 rank en el nodo anterior).
* **Gates:** tier 2 exige **≥4 puntos en el árbol y nivel ≥ 8**; capstone exige **≥8 puntos y nivel ≥ 16**.
* **Ranks:** maxRank 2 en nodos 1 y 2; capstone rank 1.
* **Tipos de nodo:** `Passive` (efectos de stats) o `Skill` (enseña la skill de talento — 1 en tier 2 y 1 profundo por spec).
* **Presupuesto:** 1 punto cada 2 niveles (~10 a lvl 20); spec única activa; respec con oro (100, R5) revoca las skills de talento.
* **Stats que afectan los nodos:** ATK, MATK, MaxHP, MaxMP, DEF, CRIT, CDR.

**Criterio de hecho global:** existe en el `.pen` una pantalla de talentos completa y realista — con contenido real de una spec, todos los estados de nodo, tooltips, contador de puntos y respec — lista para que el dev la implemente sin rediseñar.

---

### **Especificaciones Técnicas / Contratos de API (visual)**

#### **1. Pantalla a diseñar (frame nuevo en el `.pen`)**

Ventana de talentos (ratio y escala libre; coherente con el sistema Hearthbound Gold, `Scale` + `UIAspectRatioConstraint` en implementación):

* **Header:** nombre del PJ, clase, **spec activa**, nivel y **contador de puntos disponibles** (destacado, ej. "Puntos: 4").
* **Selector de spec** (si aplica): tabs o selector de las 2 specs de la clase (ej. Protector / Castigo), con la spec activa marcada.
* **Árbol:** 3 ramas visibles con sus **conexiones** (líneas/ramas entre nodos, no círculos sueltos); cada rama con etiqueta (ej. "Ataque", "Fuego", "Vigor").
* **Nodo:** círculo/rombo con icono (skill) o símbolo (pasivo), marco por estado, y **pips de rank** (2 pips; capstone 1).
* **Estados de nodo (todos obligatorios):**
  * Bloqueado (prerequisito no cumplido, gate de puntos/nivel no cumplido).
  * Disponible (cumple prerequisitos y tiene puntos).
  * Aprendido (1+ rank, sigue siendo mejorable).
  * Máximo rank (lleno).
  * Nodo skill: distinguible visualmente (icono de skill + indicador de que enseña habilidad).
* **Tooltip por nodo:** nombre, tipo (Pasivo/Skill), efecto **por rank** (ej. "Fervor: +4% ATK por rank"), requisitos (nodo anterior, puntos ≥4 y nivel ≥8 para tier 2; ≥8 y nivel ≥16 para capstone), y si es skill, el nombre de la habilidad que enseña.
* **Leyenda de estados** en un rincón de la ventana.
* **Botón Respec:** visible, con costo (100 oro), y **popup de confirmación** con advertencia (devuelve puntos, revoca skills de talento).
* **Feedback:** "Sin puntos de talento" (R5) cuando el jugador intenta gastar sin puntos.

#### **2. Contenido real del mockup (obligatorio)**

Diseñar el árbol con el contenido **real** de una spec de referencia (para que se vea como en el juego):

* **Ejemplo principal: Paladín — Castigo** (árboles finales v2.2):

| Rama | Nodo 1 | Nodo 2 | Capstone |
|------|--------|--------|----------|
| Ataque | Fervor (+4% ATK) | **Sentencia** (Skill Instant MATK) | **Anillo de luz sagrada** (Skill SelfAoE) |
| Fuego | Ardor sagrado (+4% MATK) | Llamas ardientes (+2% CRIT) | Veredicto final (+5% CRIT + 3% CDR) |
| Vigor | Tenacidad (+5% MaxHP) | Foco divino (+5% MaxMP) | Santuario (+8% DEF) |

* **Ejemplo de estado gastado (escenario del mockup):** PJ **nivel 16**, **8 puntos** gastados → rama Ataque completa (Fervor rank 2, Sentencia rank 2, Anillo de luz sagrada) + rama Fuego parcial (Ardor sagrado rank 2, Llamas ardientes rank 1) → nodos de Vigor bloqueados, 1 punto restante "disponible" en algún nodo tier 1. Debe verse el **gate** en acción: nodos tier 2 con lock parcial y capstones con el candado de nivel.
* **Mockups adicionales dentro de la misma pantalla (estados):**
  * Tooltip abierto sobre "Sentencia" (skill, rank 1 de 2, requisitos cumplidos).
  * Popup de confirmación de respec (costo 100 oro, advertencia).
  * Variante "sin puntos" con feedback visible.

#### **3. Reglas**

* Trabajar en `Vandrheim-design.pen` en un **frame propio de esta HU** (o pantalla nueva dentro de `DX7OA`); no rehacer las pantallas existentes.
* Usar la paleta/tokens de EST-04 (fondos, latón `#C89445`, pergamino `#F4EDE0`, estados), tipografías Geist Mono / Playfair Display / Inter.
* Reutilizar y **mejorar** componentes exportables si hace falta (tooltip, botón 3 estados, panel 9-slice) — sin romper los existentes.
* Los números de nodos/efectos son **solo ilustrativos** (vienen del catálogo); el diseñador no cambia stats ni balance.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: El árbol se ve implementado**

* **GIVEN** la pantalla de talentos diseñada
* **WHEN** se mira la pantalla con el mockup de Paladín Castigo nivel 16
* **THEN** se ven 3 ramas etiquetadas y conectadas con nodos, pips de rank y estados claros
* **AND** se distingue sin texto qué nodos están aprendidos, disponibles, bloqueados o al máximo

#### **Escenario 2: Estados y gates**

* **GIVEN** el árbol con puntos gastados
* **WHEN** se revisan nodos de tier 2 y capstones
* **THEN** los nodos que exigen ≥4 puntos + nivel 8 (tier 2) y ≥8 + nivel 16 (capstone) muestran su requisito en el tooltip y su candado en el nodo

#### **Escenario 3: Nodos skill**

* **GIVEN** nodos que enseñan habilidades (Sentencia, Anillo de luz sagrada)
* **WHEN** se revisa su representación
* **THEN** se distinguen visualmente de los pasivos e indican la skill que enseñan (tooltip y/o icono)

#### **Escenario 4: Tooltip y respec**

* **GIVEN** la pantalla diseñada
* **WHEN** se abren tooltip y popup de respec
* **THEN** el tooltip muestra efecto por rank y requisitos, y el popup muestra costo (100 oro) y advertencia de revocación de skills

#### **Escenario 5: Sin romper el sistema**

* **GIVEN** el diseño de talentos
* **WHEN** se compara con la estructura real (3 ramas, gates, ranks, puntos cada 2 niveles)
* **THEN** el diseño refleja fielmente esas reglas (no inventa ramas, nodos ni gates)

---

### **Comportamiento Visual / Reglas de Negocio**

* Es diseño puro: no define lógica, remotes, balance ni cambios a TalentConfig.
* Los estados de nodo usan la paleta (aprendido = latón/pergamino; disponible = borde brillante; bloqueado = atenuado).
* El contador de puntos y el botón respec deben leerse de un vistazo.
* Todo nodo skill muestra el icono real de la skill (estilo ASSETS_LIST) o placeholder equivalente.

---

### **Alcance**

#### Incluye

* Pantalla completa de talentos en el `.pen` con mockup realista de Paladín Castigo (nivel 16, 8 puntos gastados).
* Estados de nodo (bloqueado/disponible/aprendido/máximo + nodo skill), pips de rank, conexiones entre nodos, etiquetas de rama.
* Tooltip por rank, leyenda, contador de puntos, botón respec + popup de confirmación, feedback "Sin puntos".
* Mockups de estados (tooltip abierto, popup respec, sin puntos).
* Mejora de componentes exportables si es necesaria (tooltip, botones) sin romper los de EST-04.

#### No incluye

* Código, remotes, lógica de talentos ni cambios a TalentConfig (dev).
* Cambios al contenido de talentos, stats ni balance (canónico en SKILLS_CATALOG).
* Cambios a las otras pantallas del `.pen` ni a la dirección aprobada.
* El panel de stats del personaje (HU-ESTETICA-10) ni el grimorio (HU-ESTETICA-09) — HUs independientes.

---

### **Definition of Done (DoD)**

* [ ] Pantalla de talentos completa en el `.pen` con el mockup de Paladín Castigo (contenido real).
* [ ] Los 4 estados de nodo + nodo skill se distinguen sin texto.
* [ ] Conexiones entre nodos, etiquetas de rama y pips de rank visibles.
* [ ] Tooltip con efecto por rank y requisitos (gates 4/8 pts y niveles 8/16).
* [ ] Contador de puntos, leyenda, botón respec con popup (100 oro + advertencia) y feedback "Sin puntos".
* [ ] Fiel a las reglas de R5.1/SKILLS_CATALOG v2.2 (sin inventar ramas ni gates).
* [ ] Paleta y componentes de Hearthbound Gold respetados.
* [ ] Reporte al PM con el detalle del diseño y pendientes.

---

### **Estimación (orientativa)**

1–2 sesiones del diseñador: pantalla completa + estados + mockups con contenido real.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-15 | Creación de HU-ESTETICA-08: diseño a fondo del panel de talentos (árbol WoW con contenido real, estados, tooltips, respec) — solo diseñador, sin desarrollo |