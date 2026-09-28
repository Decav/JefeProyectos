# HU-R6.17: Fix — enemigos no flotantes que levitan (tocan el piso)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R6.x / Fix (reportado por PO 2026-09-22)
**Prioridad:** Media
**Estado:** Lista para implementar
**Tipo:** Bugfix de posicionamiento (dev)
**Fase GDD:** R6.17 (no cambia reglas de juego)
**Depende de:** HU-R6a (spawn de enemigos), HU-ESTETICA-02 (modelos por familia), HU-ESTETICA-30 (rig del boss — mismo criterio)
**Componentes observados:** `EnemyService` (spawn/offset), modelos de enemigos (`miniboss_frost_lord` y otros no flotadores)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que los enemigos no flotantes **toquen el piso**,
**para** que no se vean levitando (ej. el Señor de la Escarcha) y el combate se vea natural.

---

### **Descripción del Requerimiento / Contexto**

**Bug:** algunos enemigos que **no** son del tipo flotador (ej. `miniboss_frost_lord`) levitan unos centímetros sobre el suelo. La causa suele ser un **offset de spawn** (posición Y) o el `PrimaryPart`/raíz del modelo desalineado.

**Criterio de hecho global:** todos los enemigos no flotantes tocan el suelo al spawnear y al moverse; los flotadores (espectro, elementales) mantienen su levitación intencional.

---

### **Especificaciones Técnicas / Contratos de API**

* **Auditoría:** revisar el offset de spawn de `EnemyService` y el `PrimaryPart` de cada modelo no flotador (troll, gólem, señor de la escarcha, caballeros, lobos, ácaros, etc.).
* **Fix:** alinear el spawn al suelo (raycast hacia abajo o `PrimaryPart.Position.Y` correcto) para modelos no flotadores; el offset de la familia `floating` se conserva.
* Si el desajuste está en el modelo (raíz/HRP con offset), se corrige en el modelo (el dev ajusta; si requiere rediseño del diseñador, se coordina).
* Aplica también al boss final articulado (EST-30) cuando se integre.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Piso tocado**

* **GIVEN** enemigos no flotadores (incl. Señor de la Escarcha)
* **WHEN** spawnean y se mueven
* **THEN** tocan el suelo (sin levitación visible)

#### **Escenario 2: Flotadores intactos**

* **GIVEN** enemigos de la familia `floating` (espectro, elementales)
* **WHEN** spawnean
* **THEN** mantienen su levitación intencional

#### **Escenario 3: Regresión**

* **GIVEN** el fix aplicado
* **WHEN** se juega la dungeon completa
* **THEN** no hay errores rojos y los enemigos se comportan igual (solo cambia la altura)

---

### **Alcance**

#### Incluye

* Corrección de altura/spawn de enemigos no flotadores (modelos y offset).

#### No incluye

* Cambios de IA, mecánicas ni balance.

---

### **Definition of Done (DoD)**

* [ ] Enemigos no flotadores tocan el suelo (auditoría completa).
* [ ] Flotadores conservan su levitación.
* [ ] Sin errores rojos en la run completa.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Estimación (orientativa)**

1 sesión del dev (auditoría + ajustes).

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-R6.17: fix de enemigos que levitan (no flotadores) — offset de spawn/raíz alineados al piso; flotadores intactos (reportado por PO) |