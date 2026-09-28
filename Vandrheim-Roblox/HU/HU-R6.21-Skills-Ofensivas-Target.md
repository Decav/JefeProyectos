# HU-R6.21: Skills ofensivas hacia el target seleccionado (no al enemigo más cercano)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R6.x / Combate — Mejora de targeting (dev)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Mejora de targeting de skills (dev)
**Fase GDD:** R6.21 (no cambia reglas de daño ni balance)
**Depende de:** HU-R3.2 (targeting: TAB/click, `SetTarget`), HU-R3 (SkillService: cast), HU-R6.16 (targeting de aliados — estados separados)
**Componentes observados:** `TargetingSystem`, `SkillService` (selección de objetivo al castear)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que mis skills ofensivas golpeen al **enemigo que tengo targeteado**,
**para** controlar a quién ataco (no que el juego elija al más cercano por mí).

**Regla:** las ofensivas van **siempre al target seleccionado**; el **enemigo más cercano** solo se usa cuando **no hay target** (o el target murió y no se re-selecciona).

---

### **Descripción del Requerimiento / Contexto**

**Bug/problema:** hoy las skills ofensivas salen al **enemigo más cercano** en vez de al que está en target (R3.2 ya permite seleccionar con TAB/click). El jugador no puede controlar a quién golpea (ej. querer quebrar al arquerito detrás y no al lobo encima).

**Criterio de hecho global:** al castear una skill ofensiva con target seleccionado → impacta al **target**; sin target (o target muerto) → cae al **enemigo más cercano** como fallback; el server valida el objetivo (patrón R3.2).

---

### **Especificaciones Técnicas / Contratos de API**

* **Selección de objetivo en el cast:** `SkillService` usa el **target actual** del jugador (`TargetingSystem`) como objetivo de la skill ofensiva.
* **Fallback:** si no hay target válido (sin selección, target muerto/fuera de rango) → **enemigo más cercano** en rango (comportamiento actual como fallback).
* **Server-authoritative:** el server valida el objetivo (mismo criterio R3.2: enemigo válido del lugar/run actual, distancia/rango de la skill) — el cliente solo envía la intención de castear (sin elegir objetivo en el payload, salvo que ya exista el contrato).
* **Targeting de aliados (R6.16):** las ofensivas **nunca** usan el target aliado (estados separados); si el jugador solo tiene aliado seleccionado → ofensiva usa fallback (más cercano) o requiere target enemigo.
* **Auto-targeting:** si el jugador castea sin target, el sistema puede (opcional) seleccionar automáticamente al más cercano (comportamiento actual) para que la skill no quede perdida.
* No cambia: daño, rango, CD, maná ni balance (bandas R8d intactas).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Golpe al target**

* **GIVEN** un jugador con un enemigo targeteado (TAB/click) y otro enemigo más cerca
* **WHEN** castea una skill ofensiva
* **THEN** el golpe impacta al **targeteado** (no al más cercano)

#### **Escenario 2: Fallback sin target**

* **GIVEN** un jugador sin target (o target muerto)
* **WHEN** castea una skill ofensiva
* **THEN** impacta al **enemigo más cercano** en rango

#### **Escenario 3: Con aliado seleccionado**

* **GIVEN** un jugador con aliado seleccionado (R6.16) y sin target enemigo
* **WHEN** castea una ofensiva
* **THEN** la ofensiva no golpea al aliado (usa fallback enemigo o pide target)

#### **Escenario 4: Server valida**

* **GIVEN** un cliente manipulador
* **WHEN** intenta castear a un objetivo inválido
* **THEN** el server valida el target (R3.2) y rechaza/usa el fallback correcto

#### **Escenario 5: Regresión**

* **GIVEN** la mejora implementada
* **WHEN** se juega el flujo completo (combate, dungeon, party, PC/móvil)
* **THEN** no hay errores rojos y el daño/balance no cambian

---

### **Alcance**

#### Incluye

* Cast ofensivo hacia el target seleccionado con fallback al más cercano.
* Validación server del objetivo (R3.2).
* Coexistencia con el targeting de aliados (R6.16).

#### No incluye

* Cambios de daño, rango, balance ni mecánicas.
* Targeting automático/assist nuevo (más allá del fallback actual).

---

### **Definition of Done (DoD)**

* [ ] Las ofensivas impactan al target seleccionado (y al más cercano solo como fallback).
* [ ] Con aliado seleccionado, la ofensiva nunca golpea aliados.
* [ ] Server valida el objetivo (R3.2); sin regresión de targeting.
* [ ] Sin errores rojos en combate/dungeon/party (PC y móvil).
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Estimación (orientativa)**

1 sesión del dev: selección de objetivo en el cast + fallback + validación.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-R6.21: skills ofensivas hacia el **target seleccionado** (no al enemigo más cercano); el más cercano queda como fallback sin target; compatible con el targeting de aliados (R6.16) |