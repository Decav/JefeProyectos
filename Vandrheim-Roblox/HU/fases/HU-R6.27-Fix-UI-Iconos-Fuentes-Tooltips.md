# HU-R6.27: Fix UI — casillas de ítems (fondo negro + hover estándar), fuentes, grimorio, tooltips de skills y vendedores

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R6.x / UI — Fix y mejoras (reportado por PO 2026-09-22)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Bugfix/mejoras de UI (dev)
**Fase GDD:** R6.27 (no cambia reglas de juego)
**Depende de:** HU-ESTETICA-10/11/21 (stats/equipo, bolsa), HU-ESTETICA-16/17 (talentos, grimorio), HU-ESTETICA-13 (tokens/fuentes), HU-R5 (vendors), R8c (HUD/skill bar), SKILLS_CATALOG
**Componentes observados:** paneles de stats/equipo y bolsa (casillas de ítems), grimorio y talentos (tipografía y barra activa), tooltips de skills (rango/daño), tooltips de vendedores (levelReq)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que la UI se lea bien y se comporte bien:
* casillas de ítems con fondo negro y un hover limpio (no una iluminación lila rara),
* textos legibles en tooltips y paneles (grimorio y talentos sobre todo),
* la barra activa del grimorio con casillas adaptadas al icono,
* tooltips de skills con **rango real** y **daño/escalado**,
* y tooltips de vendedores con el **nivel mínimo correcto**,
**para** entender el juego sin fricción visual.

---

### **Descripción del Requerimiento / Contexto**

**Bugs/mejoras reportados (PO 2026-09-22):**

1. **Casillas de ítems:** al eliminar o interactuar con un ítem (panel de stats/equipo y bolsa), el fondo de la casilla se ilumina de un color **lila** — con los iconos de fondo negro se ve mal/extraño (parece bug, no intencional).
2. **Tipografía:** los tooltips de ítems del panel de stats/equipo se leen con dificultad (fuente chica/flaca) — **grimorio y talentos son los paneles que peor se ven**.
3. **Grimorio — barra activa:** las casillas de habilidades están **muy apretadas**; el **icono debe rellenar toda la casilla** y la **casilla debe adaptarse al tamaño del icono** (referencia: la **skill bar del HUD** muestra los iconos a la perfección).
4. **Tooltips de skills:** muestran coste, cooldown, rango y origen — pero el **rango siempre aparece "-"** (dato no usado o mal conectado). **Falta el daño de la habilidad y su escalado** (cómo mejora con niveles) — puede ir en la descripción o en un apartado del tooltip, pero falta.
5. **Tooltips de vendedores:** datos desactualizados — el **nivel mínimo de uso muestra "requiere nivel 1" en todos** los ítems.

**Criterio de hecho global:** todas las casillas de ítems comparten el estándar (fondo negro + feedback por borde, sin iluminar el fondo), los textos de tooltips/paneles son legibles (fuente/negrita correcta), la barra activa del grimorio adapta las casillas al icono como el HUD, los tooltips de skills muestran rango real + daño/escalado, y los vendedores muestran el levelReq real del ítem.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Casillas de ítems — estándar (fondo negro + hover de borde)**

* **TODAS las casillas de ítems con fondo `#000000`** (componente compartido de slot, si existe, o por panel): stats/equipo (EST-10), bolsa (EST-11/21), grimorio/talentos y vendor — coherente.
* **Feedback de interacción (hover/select/eliminar):** **agrandar el borde o iluminar el borde** (estilo micro menú / micromenu de EST-20/23) — **NUNCA iluminar el fondo** (adiós a la iluminación lila).
* La iluminación lila actual (estadísticas, equipo y **bolsa**) se elimina en todos los paneles — se reemplaza por el estándar.

#### **2. Tipografía legible**

* **Tooltips de ítems (stats/equipo):** subir tamaño de fuente y/o aplicar **negrita** a los valores importantes (nombre, stats, levelReq) — con los tokens de EST-13 (PlayfairDisplay/Inter/RobotoMono).
* **Grimorio y talentos (prioridad):** revisar tamaño, peso y contraste de TODOS los textos de ambos paneles (títulos, nombres de skill, descripciones, valores) — son los que peor se leen; sin romper el layout (UI responsive, sin overflow).
* Mantener la jerarquía visual (nombre > descripción > detalles) sin agrandar de más (se valida en QA visual).

#### **3. Grimorio — barra activa**

* **Las casillas se adaptan al tamaño del icono** (patrón de dimensionado de la **skill bar del HUD** — replicar su aspect/scale): el icono **rellena toda la casilla** (sin márgenes raros ni apretado).
* Espaciado de la barra revisado (sin solapamiento, scroll coherente si hay muchas skills).

#### **4. Tooltips de skills — rango + daño/escalado**

* **Rango:** dejar de mostrar "-" — conectar el **rango real del skill** (`SkillConfig`/`SKILLS_CATALOG`, ej. rango 1H/arco/proyectil) al campo del tooltip; si algún skill no usa rango (ej. self-buff), mostrar el valor correcto (0/self) o el dato real, nunca "-" sin sentido.
* **Daño/escalado:** añadir al tooltip (en la descripción o apartado "Daño") el **daño/efecto base** y su **escalado por nivel** (datos del SKILLS_CATALOG: ej. "Inflige X de daño (+Y por nivel)" o "Cura X (+Y% MATK)").
* Verificar que el tooltip usa los valores vigentes del skill (no datos quemados).

#### **5. Tooltips de vendedores — levelReq real**

* **Nivel mínimo = `levelReq` real del template** (`ItemConfig`) — hoy todos muestran "requiere nivel 1" (fallback hardcodeado o campo sin leer).
* El tooltip del vendor (R5/VendorConfig) debe leer el levelReq del ítem vendido y mostrar el correcto; coherente con el tooltip del inventario.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Casillas estándar**

* **GIVEN** cualquier panel con ítems (stats/equipo, bolsa, grimorio, talentos, vendor)
* **WHEN** se interactúa (hover, select, eliminar)
* **THEN** la casilla tiene fondo negro y el feedback es por **borde** (agrandado/iluminado, estilo micro menú) — **sin iluminación lila del fondo**

#### **Escenario 2: Textos legibles**

* **GIVEN** tooltips de ítems, grimorio y talentos
* **WHEN** se revisa la legibilidad
* **THEN** los textos se leen sin esfuerzo (tamaño/negrita/contraste adecuados) y sin romper el layout

#### **Escenario 3: Barra activa del grimorio**

* **GIVEN** la barra activa del grimorio
* **WHEN** se comparan sus casillas con la skill bar del HUD
* **THEN** los iconos rellenan toda la casilla (adaptación al tamaño del icono, patrón del HUD) y no hay apretado

#### **Escenario 4: Tooltip de skill completo**

* **GIVEN** un tooltip de skill
* **WHEN** se revisa
* **THEN** el rango muestra el dato real (nunca "-" sin sentido) y aparece el **daño/efecto base + escalado por nivel**

#### **Escenario 5: Tooltips de vendor**

* **GIVEN** un vendor con ítems de distintos niveles
* **WHEN** se revisan los tooltips
* **THEN** cada ítem muestra su `levelReq` real (no "requiere nivel 1" en todos)

#### **Escenario 6: Regresión**

* **GIVEN** los fixes aplicados
* **WHEN** se juega el flujo completo (PC y móvil, publicado)
* **THEN** no hay errores rojos y el HUD/paneles existentes funcionan igual

---

### **Alcance**

#### Incluye

* Estándar de casillas de ítems (fondo negro + hover de borde) en todos los paneles; eliminación de la iluminación lila.
* Tipografía de tooltips de ítems y paneles grimorio/talentos.
* Barra activa del grimorio (casillas adaptadas al icono, patrón HUD).
* Tooltips de skills (rango real + daño/escalado).
* Tooltips de vendedores (levelReq real).

#### No incluye

* Rediseños de paneles ni contenido de skills (solo la presentación de datos existentes).

---

### **Definition of Done (DoD)**

* [ ] Casillas de ítems con fondo negro y hover de borde en todos los paneles (sin iluminación lila).
* [ ] Textos de tooltips/grimorio/talentos legibles (tamaño/negrita) sin romper layout.
* [ ] Barra activa del grimorio con iconos rellenando la casilla (patrón skill bar del HUD).
* [ ] Tooltips de skills con rango real y daño/escalado; tooltips de vendor con levelReq real.
* [ ] PC y móvil OK; sin errores rojos.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Estimación (orientativa)**

2–3 sesiones del dev: slots estándar + fuentes + grimorio + tooltips (skills y vendor).

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-R6.27: fix/mejoras UI — casillas de ítems con fondo negro y hover de borde (estilo micro menú; se elimina la iluminación lila de stats/equipo/bolsa), tipografía legible (tooltips de ítems, grimorio y talentos), barra activa del grimorio con casillas adaptadas al icono (patrón HUD), tooltips de skills con rango real + daño/escalado, y tooltips de vendedores con levelReq real (reportado por PO) |