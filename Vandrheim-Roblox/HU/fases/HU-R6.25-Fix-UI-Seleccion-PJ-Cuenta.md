# HU-R6.25: Fix UI — fila de "cuenta" ilegible en la Selección de Personaje

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R6.x / UI — Fix (reportado por PO 2026-09-22)
**Prioridad:** Media
**Estado:** Lista para implementar
**Tipo:** Bugfix de UI (dev)
**Fase GDD:** R6.25 (no cambia reglas de juego)
**Depende de:** HU-ESTETICA-25/32 (selección de PJ), HU-ESTETICA-13 (tokens)
**Componentes observados:** `CharacterSelect` (fila de cuenta/header), paleta EST-13

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** ver la fila de **cuenta** en la selección de personaje con fondo y texto legibles,
**para** leer mi nombre/cuenta sin esfuerzo.

---

### **Descripción del Requerimiento / Contexto**

**Bug:** en la selección de personaje, la parte donde dice **cuenta** aparece como una **fila entera de color gris muy claro/blanco** y el **texto no se percibe bien** (contraste roto).

**Criterio de hecho global:** la fila de cuenta usa el estilo del sistema (fondo oscuro de la paleta, texto legible con los tokens de EST-13) — sin brillos blancos que rompan el contraste.

---

### **Especificaciones Técnicas / Contratos de API**

* Revisar la fila/header de cuenta en `CharacterSelect`: fondo y color de texto con los **tokens de EST-13** (fondos `#15100D`/`#211916`/`#241B16`, texto pergamino `#F4EDE0`/gris legible `#B5A79A`).
* Sin fondos blancos/gris claro; estados hover/disabled coherentes.
* Coherente con el diseño de EST-25 (la fila debe verse como en el frame del `.pen`).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Fila legible**

* **GIVEN** la pantalla de selección de personaje
* **WHEN** se mira la fila de cuenta
* **THEN** el fondo es oscuro (paleta) y el texto se lee sin esfuerzo (contraste correcto)

#### **Escenario 2: Sin blancos**

* **GIVEN** la fila corregida
* **WHEN** se revisan los estados (normal/hover)
* **THEN** no hay filas de gris claro/blanco que rompan la legibilidad

#### **Escenario 3: Regresión**

* **GIVEN** el fix aplicado
* **WHEN** se abre la selección de PJ (PC y móvil)
* **THEN** el resto de la pantalla se ve igual y no hay errores rojos

---

### **Alcance**

#### Incluye

* Corrección de estilo de la fila de cuenta en `CharacterSelect` (fondo + texto legibles).

#### No incluye

* Otros cambios de la pantalla (el reskin completo es EST-32).

---

### **Definition of Done (DoD)**

* [ ] Fila de cuenta con fondo oscuro y texto legible (tokens EST-13).
* [ ] Sin estados blancos/gris claro; PC y móvil OK.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Estimación (orientativa)**

1 sesión del dev.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-R6.25: fix UI — fila de cuenta ilegible (gris claro/blanco) en la Selección de Personaje; se aplican los tokens de EST-13 (reportado por PO) |