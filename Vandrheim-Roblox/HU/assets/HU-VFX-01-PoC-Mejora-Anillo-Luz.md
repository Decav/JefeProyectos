# HU-VFX-01: PoC de mejora de VFX de clases — Anillo de luz del Paladín (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** VFX / Polish de clases — PoC
**Prioridad:** Alta
**Estado:** Completada por confirmación del PO 2026-10-22; PoC exitosa.
**Tipo:** Prueba de concepto de VFX (dev) — 1 sola skill
**Fase GDD:** Polish (los VFX de clases pueden mejorar mucho; se prueba con una skill)
**Depende de:** SKILLS_CATALOG (Anillo de luz sagrada: SelfAoE, MATK, radio 6, CD 10 s, 25 MP), HU-R6.8 (VFX base), HU-R8a (contenido Paladín), `sfx_skill_selfAOE` (sonido ya existe)
**No modifica:** daño, radio, coste, CD ni lógica de la skill (solo su VFX)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que el **Anillo de luz** se vea espectacular (onda de luz sagrada que estalla a mi alrededor),
**para** sentir el poder de la skill — y como equipo, **para** validar el estándar con el que mejoraremos el resto de VFX de clases.

**Como** equipo,
**quiero** probar la mejora de VFX con **una sola skill**,
**para** fijar calidad, legibilidad y performance antes de extenderlo al resto.

---

### **Descripción del Requerimiento / Contexto**

Los VFX actuales de las skills de clase son básicos y pueden mejorar mucho. Esta PoC rediseña **solo el VFX del Anillo de luz sagrada** (Paladín, capstone de Ataque): si gusta, el estándar se replica al resto (futura HU).

**Criterio de hecho global:** el Anillo de luz tiene un VFX nuevo (onda expansiva + destello + impacto, con su sonido existente), legible en combate, sin romper la skill ni el performance — y el reporte fija el estándar para las demás.

---

### **Especificaciones Técnicas / Contratos de API**

* **VFX nuevo del Anillo** (client-side, data-driven): onda de luz sagrada expansiva (radio 6 real del skill), destello central, partículas de luz, golpe visible en enemigos alcanzados; dura lo que dura el efecto (sin exceder el CD).
* **Legibilidad:** el VFX no tapa telegraphs (R6.18/R7.1), nameplates (R6.12) ni la vida de aliados; paleta luz sagrada (dorado/blanco, coherente con el Paladín).
* **Performance:** límite de partículas/emitters por cast (config); sin caídas en party de 4 ni en móvil.
* **Sonido:** reutiliza `sfx_skill_selfAOE` (ya existe) sincronizado al impacto.
* **Reporte PoC:** qué estándar queda fijado (estructura del VFX, límites de partículas, tiempos) para replicar en otras skills.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: VFX nuevo**

* **GIVEN** el Paladín con Anillo de luz
* **WHEN** la lanza
* **THEN** se ve la onda expansiva + destello + impacto (radio 6), con su sonido

#### **Escenario 2: Sin romper la skill**

* **GIVEN** el VFX nuevo
* **WHEN** se juega (solo y party, PC y móvil)
* **THEN** daño/radio/CD/coste intactos y sin errores rojos

#### **Escenario 3: Performance**

* **GIVEN** varios Anillos seguidos en party
* **WHEN** se revisa
* **THEN** no hay caídas de frames (límite de partículas respetado)

#### **Escenario 4: Estándar fijado**

* **GIVEN** la PoC terminada
* **WHEN** el dev reporta
* **THEN** el reporte fija el estándar VFX (estructura, límites, tiempos) para extender al resto

---

### **Alcance**

#### Incluye

* VFX nuevo del Anillo de luz + sonido existente + reporte de estándar.

#### No incluye

* Otras skills (futura HU si la PoC gusta); ni cambios de daño/lógica.

---

### **Definition of Done (DoD)**

* [ ] Anillo de luz con VFX nuevo (onda + destello + impacto, radio 6) y sonido sincronizado.
* [ ] Legible en combate (no tapa telegraphs/nameplates); performance OK en party y móvil.
* [ ] Skill intacta (daño/radio/CD/coste); sin errores rojos.
* [ ] Reporte con el estándar para replicar.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Estimación (orientativa)**

1–2 sesiones del dev: VFX + sonido + QA + reporte.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-10-12 | Creación de HU-VFX-01: PoC de mejora de VFX de clases con el **Anillo de luz del Paladín** (onda expansiva radio 6 + destello + impacto, sonido existente); si gusta, el estándar se replica al resto (decisión PO) |
| 2026-10-22 | PO confirma que la PoC fue exitosa y que el VFX del Anillo de luz mejoró notablemente; se crea HU-VFX-02 para extender el rediseño a todas las habilidades. |
