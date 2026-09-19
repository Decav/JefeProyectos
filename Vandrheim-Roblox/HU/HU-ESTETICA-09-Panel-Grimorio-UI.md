# HU-ESTETICA-09: Panel del Grimorio (spellbook) — diseño de UI en Pencil ("como se vería en el juego")

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / EST-04 (diseño a fondo de pantallas)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Diseño de UI en Pencil (solo diseñador; **sin desarrollo, sin código**)
**Fase GDD:** EST (transversal; independiente de R8a–R8c)
**Depende de:** HU-ESTETICA-04 (dirección "Hearthbound Gold", componentes y tokens), HU-R5.1 (ventana de habilidades/spellbook), SKILLS_CATALOG v2.2 (30 skills reales), HU-R3 (barra de 4 slots/loadout)
**No modifica:** lógica del juego, SkillConfig, loadout ni balance

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** ver el grimorio tal como se vería implementado: mis habilidades aprendidas con su tipo, maná, cooldown e icono, y una vista de la barra para armar mi loadout,
**para** saber qué tengo, qué me falta por aprender y elegir mis 4 skills de combate sin confusión.

**Como** equipo de desarrollo,
**quiero** un diseño de pantalla completo y a fondo del spellbook,
**para** implementar la ventana sin reinterpretar nada y que armar la barra sea intuitivo.

---

### **Descripción del Requerimiento / Contexto**

El diseño actual del spellbook en `Vandrheim-design.pen` es **demasiado general** (una lista genérica sin estados ni interacción). Esta HU desarrolla el panel **a fondo**, con el aspecto final que tendría en el juego, usando el sistema real de habilidades:

* **Qué muestra (SKILLS_CATALOG §2 y §5):** todas las skills **aprendidas** — 2 básicas de clase (lvl 1) + 2 por nivel de spec (lvl 1 y 5) + 2 por talento (nodo medio y capstone). Las de talento aparecen al aprenderlas y se **revocan con el respec**.
* **Barra:** 4 slots (loadout, R3). Desde el grimorio se asignan/desasignan skills a la barra; sin límite de "conocidas", solo la barra limita lo equipable.
* **Tipos de skill (MVP):** `Instant`, `GroundAoE` (zona persistente con daño por tick), `SelfAoE` (burst alrededor del jugador), `Heal`, `Shield`.
* **Datos por skill en el UI:** nombre, tipo, coste de maná, cooldown, rango/radio (donde aplique), y cómo se obtuvo (nivel/talento).

**Criterio de hecho global:** existe en el `.pen` una pantalla de grimorio completa y realista — con el contenido real de una clase, estados de skill (asignada/no asignada/bloqueada), vista previa de la barra y tooltip — lista para que el dev la implemente sin rediseñar.

---

### **Especificaciones Técnicas / Contratos de API (visual)**

#### **1. Pantalla a diseñar (frame nuevo en el `.pen`)**

Ventana del grimorio (coherente con Hearthbound Gold, `Scale` + `UIAspectRatioConstraint` en implementación):

* **Header:** nombre del PJ, clase, **spec activa**, nivel.
* **Secciones/tabs:** "Aprendidas" y (si aplica) "Por aprender" — o agrupación por origen: **Básicas** · **Por nivel** · **Por talento**.
* **Lista/grid de skills:** cada skill con **icono real** (estilo ASSETS_LIST o placeholder), nombre, tipo (etiqueta: Instant/AoE zona/Explosión/Cura/Escudo), maná, CD, y origen ("Nivel 1", "Nivel 5", "Talento: <rama>").
* **Estados de skill (todos obligatorios):**
  * Aprendida y **asignada a la barra** (marcada).
  * Aprendida y **no asignada** (disponible para asignar).
  * **Bloqueada** (no aprendida): gris, con indicación de cómo se obtiene (ej. "Talento: Sentencia — rama Ataque").
  * Slots de la barra: ocupado (con skill), vacío, y el estado "arrastrar/asignar".
* **Vista previa de la barra (loadout):** 4 slots siempre visibles en la ventana, con tecla (1–4), icono y coste/CD; refleja la asignación en vivo.
* **Interacción representada:** asignar = click en skill → slot seleccionado, o drag del icono al slot (señal visual de origen y destino); desasignar = click derecho/quitar.
* **Tooltip de skill:** nombre, tipo, coste, CD, rango/radio (si aplica), descripción breve y origen.
* **Empty states:** barra con slots vacíos (ej. PJ nivel 1 con 2 básicas), y "no hay más skills por aprender".

#### **2. Contenido real del mockup (obligatorio)**

Diseñar el grimorio con el contenido **real** de una clase de referencia (para que se vea como en el juego):

* **Ejemplo principal: Paladín — Castigo** (nivel 16, árbol de Castigo completo con Sentencia y Anillo de luz sagrada):

| Skill | Tipo | Maná | CD | Origen |
|-------|------|------|----|--------|
| Golpe sagrado | Instant (ATK) | 10 | 4 s | Básica (lvl 1) |
| Veredicto de luz | Instant (MATK) | 15 | 6 s | Básica (lvl 1) |
| Filo sagrado | Instant (ATK) | 15 | 5 s | Nivel 1 (spec) |
| Llamas divinas | Instant (MATK) | 15 | 6 s | Nivel 5 (spec) |
| Sentencia | Instant (MATK) | 20 | 8 s | Talento: Ataque (tier 2) |
| Anillo de luz sagrada | Explosión (SelfAoE MATK, r6) | 25 | 10 s | Talento: Ataque (profundo) |

* **Escenario del mockup:** las 6 aprendidas; **barra con 4 ocupadas** (Golpe sagrado, Veredicto de luz, Filo sagrado, Llamas divinas) y la skill "Sentencia" en estado **no asignada** (hover sobre ella → destino de barra señalado). Un slot de la barra en estado vacío también debe verse (ej. si una quedó desasignada).
* **Mockups adicionales dentro de la misma pantalla (estados):**
  * Una skill **bloqueada** (ej. skill de la otra spec del Paladín, con "Talento: <rama>" o "Otra spec").
  * Tooltip abierto sobre "Anillo de luz sagrada" (radio 6, SelfAoE).
  * Empty state de la barra (PJ lvl 1, solo 2 básicas).

#### **3. Reglas**

* Trabajar en `Vandrheim-design.pen` en un **frame propio de esta HU** (o pantalla nueva dentro de `DX7OA`); no rehacer las pantallas existentes.
* Usar la paleta/tokens de EST-04 (fondos, latón `#C89445`, pergamino `#F4EDE0`), tipografías Geist Mono / Playfair Display / Inter.
* Reutilizar y **mejorar** componentes exportables si hace falta (casilla de skill, tooltip, botón 3 estados) — sin romper los existentes.
* Los números (maná/CD) son **ilustrativos** (vienen del catálogo); el diseñador no cambia skills ni balance.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: El grimorio se ve implementado**

* **GIVEN** la pantalla del grimorio diseñada
* **WHEN** se mira la pantalla con el mockup de Paladín Castigo nivel 16
* **THEN** se ven las 6 skills reales con icono, tipo, maná, CD y origen
* **AND** la vista previa de la barra muestra las 4 asignadas con su tecla

#### **Escenario 2: Estados de skill**

* **GIVEN** el grimorio con las 6 skills
* **WHEN** se revisan los estados
* **THEN** se distingue sin texto: asignada a la barra, no asignada, y bloqueada (no aprendida, con su forma de obtención)

#### **Escenario 3: Asignar a la barra**

* **GIVEN** una skill no asignada
* **WHEN** se representa la interacción (click/drag hacia el slot)
* **THEN** se ve el origen y destino señalados y el slot destino marcado (ocupado/vacío)

#### **Escenario 4: Tooltip**

* **GIVEN** la pantalla diseñada
* **WHEN** se abre el tooltip de una skill
* **THEN** muestra nombre, tipo, coste, CD, rango/radio y origen

#### **Escenario 5: Fiel al sistema**

* **GIVEN** el diseño del grimorio
* **WHEN** se compara con el sistema real (básicas + nivel + talento; barra de 4; respec revoca skills de talento)
* **THEN** el diseño refleja esas reglas sin inventar habilidades ni estados

---

### **Comportamiento Visual / Reglas de Negocio**

* Es diseño puro: no define lógica, remotes, balance ni cambios a SkillConfig/loadout.
* Los tipos de skill se distinguen visualmente (color/etiqueta: Instant, Zona, Explosión, Cura, Escudo).
* El estado "asignada" se lee de un vistazo (marco/indicador) y la barra siempre está visible en la ventana.
* Los iconos siguen el estándar ASSETS_LIST (fondo negro) o placeholder equivalente.

---

### **Alcance**

#### Incluye

* Pantalla completa del grimorio en el `.pen` con mockup realista de Paladín Castigo (6 skills reales).
* Secciones por origen (Básicas / Nivel / Talento), estados de skill (asignada/no asignada/bloqueada).
* Vista previa de la barra de 4 slots (ocupado/vacío/tecla) y representación de la asignación.
* Tooltip de skill, empty states (barra vacía, sin más skills).
* Mejora de componentes exportables si es necesaria (casilla de skill, tooltip) sin romper los de EST-04.

#### No incluye

* Código, remotes, lógica de loadout ni cambios a SkillConfig (dev).
* Cambios a habilidades, stats ni balance (canónico en SKILLS_CATALOG).
* Cambios a las otras pantallas del `.pen` ni a la dirección aprobada.
* El panel de talentos (HU-ESTETICA-08) ni el de stats del personaje (HU-ESTETICA-10) — HUs independientes.

---

### **Definition of Done (DoD)**

* [ ] Pantalla del grimorio completa en el `.pen` con el mockup de Paladín Castigo (contenido real).
* [ ] Los 3 estados de skill (asignada/no asignada/bloqueada) se distinguen sin texto.
* [ ] Vista previa de la barra de 4 con teclas y estados ocupado/vacío; interacción de asignación representada.
* [ ] Tooltip con tipo, maná, CD, rango/radio y origen; empty states cubiertos.
* [ ] Fiel a las reglas de R5.1/SKILLS_CATALOG (origen de cada skill, barra de 4, respec revoca talento).
* [ ] Paleta y componentes de Hearthbound Gold respetados.
* [ ] Reporte al PM con el detalle del diseño y pendientes.

---

### **Estimación (orientativa)**

1–2 sesiones del diseñador: pantalla completa + estados + mockups con contenido real.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-15 | Creación de HU-ESTETICA-09: diseño a fondo del grimorio (spellbook) con contenido real, estados y vista previa de barra — solo diseñador, sin desarrollo |