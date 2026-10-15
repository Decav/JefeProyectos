# HU-R6.30: Auto-target — lanzar una habilidad selecciona al enemigo golpeado (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Combate / Targeting — Mejora (decisión PO 2026-09-22)
**Prioridad:** Alta
**Estado:** Implementada (reporte PO 2026-09-22; verificación/QA pendiente)
**Tipo:** Mejora de targeting (dev)
**Fase GDD:** R6.30 (no cambia reglas de daño ni de selección manual)
**Depende de:** HU-R3.1/R3.3 (targeting e indicador visual), HU-R6.21 (habilidades dirigidas al target), HU-R6.19 (proyectiles/LOS), SKILLS_CATALOG
**Componentes observados:** sistema de skills (target de habilidad), selección de target (R3.x), indicador visual R3.3

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que al lanzar una habilidad contra un enemigo **cercano pero no seleccionado**, ese enemigo **quede seleccionado** automáticamente,
**para** que el combate fluya (ya no tengo que buscar al enemigo después de lanzar).

---

### **Descripción del Requerimiento / Contexto**

**Problema:** hoy, al usar una habilidad con un enemigo cerca pero sin seleccionar, la habilidad se lanza pero el enemigo **no queda targeteado** — el jugador pierde el foco y el siguiente cast es incómodo (sobre todo en móvil).

**Criterio de hecho global:** cuando una habilidad de daño dirigido se lanza y golpea/afecta a un enemigo que no estaba seleccionado, ese enemigo **queda seleccionado** automáticamente (con su indicador R3.3), sin cambiar el comportamiento de la selección manual.

---

### **Especificaciones Técnicas / Contratos de API**

* **Cuándo:** al lanzar una habilidad **dirigida a enemigo** (single-target, proyectil o melee) contra un enemigo **sin seleccionar** → al lanzarse (o al impactar, según la skill), el enemigo se convierte en el **target seleccionado** del jugador.
* **Qué NO cambia:**
  * La selección explícita (TAB/click/botón Target R6.29) sigue igual.
  * Si ya había un target seleccionado, la habilidad no lo roza (solo aplica si NO había selección).
  * Habilidades **sin target** (self-buffs, AoE centrado en uno mismo, cura) NO cambian la selección.
  * Daño de área que golpea a varios: si no había selección, se selecciona el **primer objetivo de la habilidad** (el del cast inicial); si el cast era AoE sin target primario, no selecciona a ninguno (o al primero golpeado — decisión: **no selecciona** para no sorprender).
* **Server-authoritative:** la selección es del cliente (UI), pero el flujo respeta el mismo canal que TAB/click (R3.x) — el server confirma qué enemigo es válido (no muerto, en rango de visión) y el cliente aplica el indicador.
* Aplica igual en **PC y móvil**.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Auto-target básico**

* **GIVEN** un enemigo cercano sin seleccionar
* **WHEN** el jugador lanza una habilidad de daño dirigido contra él
* **THEN** la habilidad se lanza y el enemigo **queda seleccionado** (indicador R3.3)

#### **Escenario 2: No interfiere con selección manual**

* **GIVEN** un target ya seleccionado
* **WHEN** se lanza contra otro enemigo
* **THEN** el target seleccionado no cambia (comportamiento actual intacto)

#### **Escenario 3: Sin target de habilidad**

* **GIVEN** una habilidad sin target (self-buff/AoE propio)
* **WHEN** se lanza sin selección
* **THEN** no selecciona a nadie

#### **Escenario 4: AoE sin objetivo primario**

* **GIVEN** un AoE sin objetivo primario (círculo libre)
* **WHEN** golpea a varios enemigos sin selección
* **THEN** no selecciona a ninguno (sin sorpresas)

#### **Escenario 5: Regresión**

* **GIVEN** el cambio aplicado
* **WHEN** se juega combate completo (PC y móvil, solo y party, publicado)
* **THEN** TAB/click/botón Target y el daño funcionan igual y no hay errores rojos

---

### **Alcance**

#### Incluye

* Auto-selección del enemigo al lanzar habilidades dirigidas sin target previo (PC y móvil).

#### No incluye

* Cambios al daño, al targeting manual ni al comportamiento de AoEs.

---

### **Definition of Done (DoD)**

* [ ] Habilidad dirigida sin selección → el enemigo queda seleccionado (indicador R3.3).
* [ ] Selección manual y skills sin target intactas.
* [ ] PC y móvil OK; sin errores rojos.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Estimación (orientativa)**

1 sesión del dev.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-R6.30: auto-target — lanzar una habilidad de daño dirigido contra un enemigo no seleccionado lo deja **seleccionado** automáticamente (indicador R3.3); no interfiere con la selección manual ni con skills sin target/AoE libre (reportado por PO) |