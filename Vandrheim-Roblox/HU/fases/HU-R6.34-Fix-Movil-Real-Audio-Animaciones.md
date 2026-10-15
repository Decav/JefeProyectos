# HU-R6.34: Fix móvil (teléfono real) — no suenan músicas/SFX ni se ven animaciones (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R6.x / Mobile — Bug (reportado por PO 2026-10-12)
**Prioridad:** **Crítica** (el juego en teléfono real queda sin audio ni animaciones)
**Estado:** Lista para implementar (RC obligatorio del dev antes de programar)
**Tipo:** Bugfix de plataforma (dev)
**Fase GDD:** R6.34 (no cambia reglas de juego)
**Depende de:** HU-R9b (música/SFX), HU-R6.6/6.7 (animaciones), HU-R6.15 (móvil)
**Componentes observados:** `SoundService`/SoundGroups/volumen, replicación de animaciones, calidad gráfica en móvil, logs de dispositivo

---

### **Narrativa (INVEST)**

**Como** jugador en teléfono real,
**quiero** escuchar la música y los SFX y ver las animaciones igual que en PC/simulador,
**para** que el juego móvil no se sienta roto.

---

### **Descripción del Requerimiento / Contexto**

**Bug (PO, solo en teléfono real — en el simulador de Roblox NO ocurre):** las **músicas no se reproducen, las animaciones tampoco y los efectos de sonido tampoco**.

**Criterio de hecho global:** en un teléfono real (iOS y Android) la música, los SFX y las animaciones funcionan igual que en PC/simulador, con el RC incluyendo el diagnóstico de la causa.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Checklist de diagnóstico (el RC debe descartar en orden)**

1. **Volumen/silencio del dispositivo:** switch de silencio (iOS), modo No molestar/vibración, volumen multimedia vs volumen del juego (slider de R9b); el juego debe sonar con el volumen del dispositivo al máximo.
2. **Carga de audio en móvil:** los `SoundId` cargan (`Loaded`) antes de reproducir; timeouts/reintentos en red móvil; los audios son del owner o públicos (permisos).
3. **SoundGroups/volumen maestro:** ningún grupo en 0 en móvil; el slider de Volumen aplica igual en todas las plataformas.
4. **Animaciones:** replicación en móvil (sin gating por calidad gráfica que las desactive); LOD o modo bajo rendimiento que las esté suprimiendo; `Animator`/`AnimationController` activos en el cliente móvil.
5. **Calidad gráfica automática:** si el dispositivo baja a calidad mínima, audio y animaciones deben seguir funcionando (solo baja fidelidad visual, nunca funcionalidad).
6. **Logs del dispositivo:** reproducir con el teléfono del PO (modelo y SO a confirmar) y adjuntar logs/errores al RC.

#### **2. Reglas**

* El fix no cambia volúmenes ni assets (solo que funcionen en móvil real).
* PC/simulador intactos; sin errores rojos.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Audio en teléfono real**

* **GIVEN** un teléfono real (no simulador)
* **WHEN** se juega (hub + dungeon + combate)
* **THEN** se escuchan la música del área y los SFX (hits, skills, UI, boss) igual que en PC

#### **Escenario 2: Animaciones en teléfono real**

* **GIVEN** un teléfono real
* **WHEN** se juega
* **THEN** se ven las animaciones de jugador y enemigos (ataques, skills, jefes)

#### **Escenario 3: Regresión**

* **GIVEN** el fix aplicado
* **WHEN** se juega en PC, simulador y teléfono real (iOS + Android si aplica)
* **THEN** todo suena y se anima igual; sin errores rojos

---

### **Alcance**

#### Incluye

* Diagnóstico (checklist) + fix de música/SFX/animaciones en teléfono real.

#### No incluye

* Cambios de volúmenes, assets ni calidad gráfica (solo que funcionen).

---

### **Definition of Done (DoD)**

* [ ] Causa diagnosticada y documentada en el RC (checklist descartado en orden).
* [ ] Música + SFX + animaciones funcionando en teléfono real (verificado con el dispositivo del PO).
* [ ] PC/simulador intactos; sin errores rojos.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Estimación (orientativa)**

1–2 sesiones del dev: diagnóstico con dispositivo real + fix + verificación.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-10-12 | Creación de HU-R6.34: fix móvil (teléfono real) — músicas, SFX y animaciones no funcionan en el teléfono (en simulador sí); checklist de diagnóstico (silencio/volumen, carga de audio, SoundGroups, replicación/LOD de animaciones, calidad mínima, logs del dispositivo del PO) (reportado por PO) |