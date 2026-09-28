# HU-R6.15: Fix cámara en móvil — mover personaje y girar la cámara sin conflicto (touch)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R6.x / Fix (reportado por PO 2026-09-22)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Bugfix de entrada/cámara (dev)
**Fase GDD:** R6.15 (no cambia reglas de juego)
**Depende de:** HU-R3.1 (cámara WoW-like), HU-R0 (movimiento/mobile), HU-R6.14 (batch 1 — interacción móvil)
**Componentes observados:** cámara del jugador (R3.1), inputs táctiles (joystick), `UserInputService` touch

---

### **Narrativa (INVEST)**

**Como** jugador móvil,
**quiero** poder **moverme y girar la cámara al mismo tiempo** manteniendo la pantalla,
**para** jugar con fluidez: el joystick mueve y el arrastre en el resto de la pantalla rota la cámara, sin que se "vuelva loca".

---

### **Descripción del Requerimiento / Contexto**

**Bug:** en móvil la cámara funciona muy mal: **no se puede mover al personaje mientras se gira la cámara** — al hacerlo, la cámara se vuelve loca y apunta para todos lados. Hay que poder **mover con el joystick y mirar manualmente arrastrando la pantalla** de forma simultánea y estable.

**Criterio de hecho global:** en móvil, el joystick mueve al personaje y el drag en el resto de la pantalla rota la cámara de forma independiente y suave; sin saltos ni giros incontrolados.

---

### **Especificaciones Técnicas / Contratos de API**

* **Separación de inputs:** el joystick (movimiento) y el drag de cámara (rotación) son **canales independientes**: arrastrar fuera del joystick rota la cámara; arrastrar sobre el joystick mueve.
* **Fix del giro loco:** la rotación táctil debe usar **delta limpio** (sin acumular posiciones de frames anteriores ni aplicar rotación cuando el drag no pertenece a la cámara); clamp de pitch (como PC, R3.1) y sin reinicios de yaw.
* **Coexistencia:** movimiento + rotación simultáneos funcionan; soltar/agarrar de nuevo no provoca saltos.
* **No romper:** targeting táctil, botones del HUD (BOLSA/EQUIPO/MENÚ), micromenú compacto (R6.14) ni el joystick existente.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Mover y mirar a la vez**

* **GIVEN** un jugador en móvil
* **WHEN** mueve el joystick y arrastra la pantalla a la vez
* **THEN** el personaje se mueve y la cámara rota de forma estable (sin giros locos)

#### **Escenario 2: Drag limpio**

* **GIVEN** la rotación táctil
* **WHEN** se arrastra y se suelta repetidamente
* **THEN** la cámara no salta ni se acumula (pitch con clamp, yaw continuo)

#### **Escenario 3: HUD intacto**

* **GIVEN** el fix aplicado
* **WHEN** se tocan los botones del HUD
* **THEN** los botones responden (no compiten con la rotación de cámara)

#### **Escenario 4: PC intacto**

* **GIVEN** el fix aplicado
* **WHEN** se juega en PC
* **THEN** la cámara de R3.1 funciona igual (mouse)

---

### **Alcance**

#### Incluye

* Separación de inputs táctiles (joystick vs drag de cámara) y fix del giro inestable.

#### No incluye

* Cambios de cámara en PC, targeting ni otros bugs (R6.16+).

---

### **Definition of Done (DoD)**

* [ ] En móvil: mover (joystick) + girar cámara (drag) simultáneos, estables.
* [ ] Sin saltos/acumulación al soltar y agarrar; pitch clamp como PC.
* [ ] HUD táctil y joystick intactos; PC sin cambios.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA (probado en móvil).

---

### **Estimación (orientativa)**

1 sesión del dev.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-R6.15: fix de cámara móvil — joystick y drag de cámara independientes, sin giros locos (reportado por PO) |