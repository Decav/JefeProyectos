# HU-R6.23: Fix cámara móvil — zoom con pinza (acercar/alejar), distancia ajustable como PC

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R6.x / Fix (reportado por PO 2026-09-22)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Bugfix de cámara (dev)
**Fase GDD:** R6.23 (no cambia reglas de juego)
**Depende de:** HU-R6.15 (cámara móvil: joystick + drag), HU-R3.1 (cámara), `CameraConfig` (distancias)
**Componentes observados:** cámara del jugador (móvil), `CameraConfig` (min/max distancia), inputs táctiles (pinch)

---

### **Narrativa (INVEST)**

**Como** jugador móvil,
**quiero** **acercar y alejar la cámara con pinza** (dos dedos) como en PC, y que la **sensibilidad de rotación** sea la adecuada (no tan lenta),
**para** ajustar la distancia y mirar cómodamente en el móvil.

---

### **Descripción del Requerimiento / Contexto**

**Bugs reportados (PO 2026-09-22):**

1. En móvil la cámara tiene una **distancia fija** — no se puede alejar ni acercar. Debe poder **ajustarse manualmente con pinza** (acercar/alejar con los dedos) y el **máximo de distancia debe ser igual al de PC**.
2. La **sensibilidad de la cámara está muy lenta** — la rotación debe ser más ágil.

**Criterio de hecho global:** en móvil, la pinza ajusta la distancia dentro de los **mismos límites que PC** (min/max de `CameraConfig`) y la **sensibilidad de rotación es configurable y más rápida** (default en `CameraConfig`, por plataforma); sin conflicto con el joystick ni con el drag de rotación (R6.15).

---

### **Especificaciones Técnicas / Contratos de API**

* **Pinch zoom:** gesto de dos dedos (pinza) ajusta la distancia de cámara dentro de `[CameraConfig.MinDistance, CameraConfig.MaxDistance]` — **los mismos valores que usa PC** (una sola fuente: config).
* **Sensibilidad (nueva):** `CameraConfig` gana **sensibilidad de rotación por plataforma** (`rotationSensitivityPc` / `rotationSensitivityMobile`): el default móvil se sube (más ágil que la actual) y el de PC se conserva (R3.1). Ajustable por config, no por código.
* **Sin conflicto:** la pinza no compite con el joystick (movimiento) ni con el drag de un dedo (rotación, R6.15): la pinza usa **dos dedos** y el drag usa uno.
* **Estabilidad:** sin saltos al soltar/agarrar; la distancia se conserva mientras no se cambie con pinza (sin reset en combate).
* **No romper:** targeting táctil, HUD, joystick, rotación de cámara (R6.15) ni la cámara de PC.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Pinza funcional**

* **GIVEN** un jugador en móvil
* **WHEN** hace pinza (dos dedos) acercando/alejando
* **THEN** la cámara se acerca/aleja suavemente dentro de los límites de `CameraConfig`

#### **Escenario 2: Máximo igual a PC**

* **GIVEN** la distancia máxima en móvil
* **WHEN** se compara con PC
* **THEN** es la misma (mismo `CameraConfig.MaxDistance`)

#### **Escenario 3: Sin conflictos**

* **GIVEN** la cámara móvil
* **WHEN** se mueve (joystick), rota (un dedo) y hace pinza
* **THEN** los tres gestos coexisten sin interferencias

#### **Escenario 3b: Sensibilidad**

* **GIVEN** la sensibilidad configurada (mobile más ágil)
* **WHEN** se rota la cámara en móvil
* **THEN** la rotación responde ágil (no lenta) y en PC se conserva la sensibilidad actual (R3.1)

#### **Escenario 4: Regresión**

* **GIVEN** el fix aplicado
* **WHEN** se juega en PC y móvil
* **THEN** la cámara de PC no cambia y no hay errores rojos

---

### **Alcance**

#### Incluye

* Pinch zoom en móvil dentro de los límites de `CameraConfig` (mismos que PC).
* **Sensibilidad de rotación por plataforma** (`rotationSensitivityPc/Mobile` en config) — mobile más ágil, PC intacto.

#### No incluye

* Cambios a la cámara de PC ni a otros gestos (R6.15 intacto).

---

### **Definition of Done (DoD)**

* [ ] Pinza ajusta la distancia (min/max de `CameraConfig`) en móvil.
* [ ] Máximo idéntico al de PC; sin conflictos con joystick/rotación.
* [ ] Sensibilidad móvil más ágil (config) y PC sin cambios.
* [ ] Sin errores rojos.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Estimación (orientativa)**

1 sesión del dev.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-R6.23: fix de cámara móvil — zoom con pinza (acercar/alejar), distancia ajustable con los mismos límites que PC (reportado por PO) |
| 2026-09-22 | **Sensibilidad sumada (decisión PO):** la rotación móvil está muy lenta — `CameraConfig` gana `rotationSensitivityPc/Mobile` (mobile más ágil, PC conserva R3.1) |