## HU-R3.1: Fix de cámara (órbita WoW-like + crosshair)

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** Control / Cámara (fix derivado de R3 — se corrige durante la fase en curso)  
**Prioridad:** Alta  
**Estado:** Completada (implementada; reporte equipo 2026-08-12)  
**Fase GDD:** R3.1 (fix de salud de jugabilidad; no cambia alcance MVP)  
**Depende de:** HU-R0 (cámara 3ª base), HU-R1 (targeting TAB/click — no debe romperse)

---

### **Narrativa (INVEST)**

**Como** jugador,  
**quiero** que la cámara siga al mouse de forma directa (1:1, estilo primera persona), sin mira vertical invertida ni cursor que salte al centro al hacer click,  
**para** que el control se sienta inmediato y de MMO tradicional (WoW-like), no como cámara desajustada o de editor.

---

### **Descripción del Requerimiento / Contexto**

Problemas actuales reportados en el hub (R0/R1 en producción):

1. La rotación vertical está invertida.
2. Al hacer click con **cualquier** botón, el cursor se centra en la pantalla (mouse teleport), y la cámara rota solo mientras se mantiene el click con ese artefacto.
3. Falta un punto de mira (crosshair) para que el control "mouse = cámara" tenga referencia visual.

**Decisión de diseño cerrada (equipo + PM):** solución **A** = `UserInputService.MouseBehavior = LockCenter` **solo mientras se mantiene el botón derecho** + rotación vía `UserInputService:GetMouseDelta()` + cursor oculto con crosshair propio. Click izquierdo queda libre para targeting (HU-R1).

---

### **Especificaciones Técnicas / Contratos de API**

#### **Comportamiento del mouse (PC)**

| Acción | Estado |
|--------|--------|
| Mantener **botón derecho** | `MouseBehavior = LockCenter`; cursor oculto; rotación por `GetMouseDelta()` |
| Soltar botón derecho | `MouseBehavior = Default`; cursor vuelve visible |
| **Botón izquierdo** | No toca cámara ni MouseBehavior; sigue disponible para targeting (TAB/click R1) |
| Movimiento mouse (sin click) | No rota cámara en idle; solo cuando el drag derecho está activo |

#### **Rotación (delta 1:1 QoS)**

* Horizontal: `delta.X` → yaw (multiplicar por sensibilidad).
* Vertical: `delta.Y` → pitch con signo **corregido** (mouse arriba = mirar arriba, sin invertir).
* Clamp de pitch: ~`-70° a +70°` (evitar giros sobre la cabeza).
* Sensibilidad: constante `RotationSensitivity` en Config (default razonable, p. ej. 0.2); no se configura desde UI en esta HU (post-MVP opcional).

#### **Zoom**

* Scroll `MouseWheel` → acercar/alejar órbita (mantener comportamiento actual del módulo, corregido si lo rompe el fix).

#### **Crosshair (punto de mira)**

* `ScreenGui` + `ImageLabel` (o `Frame` estilizado) fijo al centro de pantalla.
* Visibilidad: **solo cuando el control con mouse está activo** (botón derecho mantenido y/o mientras el cursor está oculto). Oculto en UI de menús (selección de PJ, inventario futuro).
* No interactúa con targeting; es referencia visual pura.

#### **Móvil**

* No se toca la lógica táctil: en touch se mantiene el drag de cámara actual (R0). El fix es solo para PC (`UserInputService.TouchEnabled == false` o bifurcación equivalente). No romper la integridad multiplataforma (regla del DEV_PROMPT).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Rotación no invertida**

* **GIVEN** el jugador mantiene el botón derecho
* **WHEN** mueve el mouse hacia arriba
* **THEN** la cámara mira hacia arriba (igual que el mouse, 1:1)
* **AND** al mover hacia abajo, mira hacia abajo

#### **Escenario 2: Sin teleport del cursor al hacer click**

* **GIVEN** el jugador en el hub
* **WHEN** hace click con **botón derecho**
* **THEN** el cursor **no** viaja al centro de la pantalla como artefacto visible de rotación
* **AND** la rotación usa deltas suaves del mouse

#### **Escenario 3: Click izquierdo libre para targeting**

* **GIVEN** el jugador hace click izquierdo sobre un dummy enemigo
* **WHEN** no mantiene el botón derecho
* **THEN** se selecciona el target (HU-R1) y la cámara no rota ni cambia MouseBehavior
* **AND** el cursor no se centra

#### **Escenario 4: Cursor vuelve tras soltar**

* **GIVEN** el jugador suelta el botón derecho
* **WHEN** se restaura el estado
* **THEN** el cursor vuelve visible en su posición normal
* **AND** MouseBehavior vuelve a `Default`

#### **Escenario 5: Crosshair**

* **GIVEN** el jugador con control de cámara activo (botón derecho mantenido)
* **WHEN** mira la pantalla
* **THEN** ve un punto de mira fijo al centro
* **AND** el crosshair se oculta cuando el cursor vuelve (estado de UI normal)

#### **Escenario 6: Pitch clamp**

* **GIVEN** el jugador rota la cámara verticalmente
* **WHEN** rota al máximo
* **THEN** el pitch queda limitado (~±70°) sin vueltas sobre la cabeza

#### **Escenario 7: Integridad R1**

* **GIVEN** TAB y click target funcionando (R1)
* **WHEN** se prueba combate con la cámara nueva
* **THEN** targeting no se rompe (TAB cíclico, click selecciona, auto-attack sigue)

#### **Escenario 8: Sin errores**

* **GIVEN** el hub corriendo con el fix
* **WHEN** se revisa el output
* **THEN** no hay errores rojos por el control de cámara

---

### **Comportamiento Visual e Interfaz (UI/UX) / Reglas de Negocio**

* **Afinidad MMO:** drag derecho = órbita; click izquierdo = interacción/combate; scroll = zoom. Nada de "clic para mover cámara con teletransporte de cursor".
* **Crosshair:** discreto, "aim dot" estilo combate (no tipo shooter con alinear/estado de puntería); no bloquea eventos de UI.
* **Estado del cursor:** oculto solo durante el drag de cámara; nunca oculto en menús.
* **Móvil:** el drag táctil existente queda intacto; el crosshair es de PC en esta HU (móvil puede ocultarlo o reutilizarlo — decisión post-R9, fuera de alcance aquí si no se pide).

---

### **Alcance**

#### Incluye

* Fix de rotación vertical: 1:1 con el mouse, sin invertir
* LockCenter solo con botón derecho + `GetMouseDelta()` para rotar
* Restaurar `MouseBehavior = Default` al soltar
* Crosshair (punto de mira) centrado, visible solo con control de cámara activo
* Clamp de pitch automático
* Mantener zoom por scroll
* Compatibilidad con targeting R1 y con móvil (sin romper)

#### No incluye

* Reconfiguración de sensibilidad desde UI del jugador (post-MVP)
* Pan lateral (drag con botón del medio o teclas) — no pedido
* Colisión de cámara compleja / obstáculos, giro automático de follow, shakemap de impacto
* Crosshair para móvil (decisión post-R9)
* Cambios a targeting, combate o input de skills

---

### **Definition of Done (DoD)**

* [ ] Play Solo: rotar con drag derecho sin ver el cursor saltar al centro
* [ ] Mover el mouse arriba = mirar arriba (1:1, no invertido)
* [ ] Click izquierdo aún targetea el dummy (R1 intacto)
* [ ] Al soltar el botón derecho, el cursor vuelve normal
* [ ] Crosshair visible solo con cámara activa
* [ ] Pitch no invierte sobre la cabeza
* [ ] Sin errores rojos en output
* [ ] Nota "R3.1 completo" en GDD (fix de cámara)

---

### **Checklist Studio (referencia dev)**

* [ ] Revisar script de cámara de R0 (StarterPlayerScripts) y corregir el pitch invertido
* [ ] Implementar `MouseBehavior` toggle con drag derecho (`InputBegan`/`InputEnded` con `MouseButton2`)
* [ ] Usar `UserInputService:GetMouseDelta()` para rotación (no `Mouse.X/Y` absolutos)
* [ ] Config de sensibilidad en `Config` (constante `RotationSensitivity`)
* [ ] Clamp de pitch en ~±70°
* [ ] Crosshair en `StarterGui` (Scale + UIAspectRatioConstraint), oculto en menús/selector de PJ
* [ ] Probar con 2 jugadores (opcional): cámara y cursor independientes por jugador
* [ ] Verificar móvil: drag táctil intacto

---

### **Decisiones por defecto R3.1 (si no se cambian)**

| Tema | Default |
|------|---------|
| Botón que agarra cámara | Único: botón derecho |
| Rotación | `GetMouseDelta()` con sensibilidad Constante (0.2 orientativo) |
| Vertical | 1:1 con mouse (sin invertir), pitch clamp ~±70° |
| Cursor | Oculto solo durante drag derecho; `Default` al soltar |
| Click izquierdo | Libre para targeting (R1) |
| Crosshair | Fijo al centro, visible solo con cámara agarrada |
| Móvil | Sin cambios (drag táctil de R0) |

---

### **Estimación (orientativa)**

1 sesión (fix acotado de control).

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-12 | Alta HU-R3.1 (fix cámara WoW-like + crosshair); decisión A cerrada (LockCenter + GetMouseDelta) |
| 2026-08-12 | Marcada completada según reporte del equipo |