## HU-R6.12: Rediseño del pre-cast de habilidades AoE (anillo púrpura + runa nórdica)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Combate / AoE / Visual de apuntado
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Cambio visual de gameplay (dev)
**Fase GDD:** R6.12 (mejora del indicador de apuntado; sin cambios al cast ni al daño)
**Depende de:** HU-R3 (SkillBarClient, modo AoE), HU-R6.9 (AoE zonas/Self), ASSETS_POLICY.md (assets y placeholders)
**Componentes observados:** `StarterPlayer.StarterPlayerScripts.SkillBarClient` (`ensureAoEIndicator`), color de propuesta en `Vandrheim-design.pen` (nodo `u6eYDO` — `#B48ADE`)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que el indicador de apuntado de las habilidades de área (pre-cast) se vea acorde a la estética del juego — anillo púrpura con una runa nórdica en el centro,
**para** que el apuntado se sienta de fantasía nórdica y no como un círculo celeste genérico.

**Como** equipo de desarrollo,
**quiero** reemplazar el indicador celeste actual por el nuevo diseño,
**para** que el pre-cast combine con las zonas AoE y el resto del HUD.

---

### **Descripción del Requerimiento / Contexto**

El pre-cast de las habilidades `GroundAoE` (y el modo de apuntado del `SelfAoE` cuando corresponda) se dibuja hoy en `SkillBarClient.ensureAoEIndicator` como un único cilindro:

```luau
aoeIndicator.Color = Color3.fromRGB(100, 200, 255) -- celeste fuerte
aoeIndicator.Material = Enum.Material.Neon
aoeIndicator.Transparency = 0.5
```

El producto aprobó una propuesta de color en Pencil (nodo `u6eYDO`, "SelfAoE state zone proposal"): **púrpura lavanda `#B48ADE`** (fill semitransparente `#B48ADE55`, borde `#B48ADE`). Esta HU reemplaza el indicador celeste por:

1. **Anillo de borde** púrpura `#B48ADE`.
2. **Relleno semitransparente** del área (radio de la skill).
3. **Runa nórdica en el centro** como sello de apuntado (visual llamativo y reemplazable por config).

El comportamiento no cambia: el indicador sigue la posición del mouse en el suelo, se muestra solo en modo AoE, y el cast sigue siendo server-authoritative.

**Criterio de hecho global:** al entrar en modo AoE, el indicador de apuntado muestra el anillo púrpura con la runa en el centro, sin restos del celeste anterior, en PC y móvil.

---

### **Especificaciones Técnicas / Contratos de API**

#### **Paleta (aprobada en Pencil)**

| Uso | Color |
|-----|-------|
| Borde/anillo | `#B48ADE` |
| Relleno del área | `#B48ADE` con alfa (~33%, equivalente a `#B48ADE55`) |
| Detalle/runa | `#C9A8E8` (claro) y `#9A6FD0` (oscuro) para contraste |

* Los colores viven en config (nuevo `ReplicatedStorage.Config.AoEIndicatorConfig` o campos en un config de HUD existente); no hardcodeados en `SkillBarClient`.
* El celeste `Color3.fromRGB(100, 200, 255)` desaparece del indicador de apuntado.

#### **Nuevo indicador (client-side)**

* **Anillo de borde:** un anillo delgado (cilindro hueco visual o `StrokeAdornment` sobre el cilindro base) de `#B48ADE`, transparencia baja (visible sobre cualquier material), con el radio de la skill (`skill.aoeRadius`).
* **Relleno:** cilindro plano semitransparente `#B48ADE55` en la zona apuntada (reemplaza al cilindro celeste).
* **Runa nórdica en el centro:**
  * Una placa plana en el centro del indicador con una **runa** (sello) visible desde 3ª persona.
  * Implementación recomendada: `Decal`/`SurfaceAppearance` con textura de runa **referenciada por config** (`runeTextureId`) según `ASSETS_POLICY` (placeholder geométrico permitido hasta que exista el asset del diseñador; registro en `ASSETS_REGISTRY` si se incorpora un asset real).
  * Fallback sin asset: runa armada con primitivas (2–3 barras/cruces delgadas de `#C9A8E8`) hasta tener la textura.
* **Rotación opcional:** la runa puede girar lentamente (tween suave) mientras se apunta; configurable (`runeSpin`, default `false` o velocidad baja) y sin trabajo por frame.
* El indicador sigue al mouse como hoy (`getMouseGroundPosition` y `updateAoEIndicator`); tamaño según `aoeRadius`.

#### **Alcance técnico**

* Se modifica únicamente el **render del indicador de apuntado (pre-cast)** en `SkillBarClient` (o se extrae a un helper/módulo `AoEIndicator` si el dev lo prefiere, sin cambiar contratos).
* No se toca: `RequestCastSkill`, la validación server del cast, el raycast de posición, ni el modo AoE.
* No se toca la **zona activa persistente** (el VFX de la zona ya lanzada sigue siendo el de R6.9/R8a-b-c por skillId).
* El fallback histórico celeste (`AoEVisualFallback`, comentado en `SkillBarClient`) queda fuera de alcance.

#### **Seguridad y autoridad**

* Es visual local puro: no envía datos al servidor, no modifica el cast ni el daño.
* El indicador nunca se replica a otros jugadores ni afecta la zona lanzada.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Indicador púrpura**

* **GIVEN** el jugador entra en modo AoE (skill `GroundAoE` en la barra).
* **WHEN** se mueve el mouse sobre el suelo.
* **THEN** el indicador muestra el anillo `#B48ADE` y el relleno semitransparente púrpura con el radio de la skill.
* **AND** no aparece ningún elemento celeste (`#64C8FF`).

#### **Escenario 2: Runa en el centro**

* **GIVEN** el indicador visible.
* **WHEN** el jugador apunta.
* **THEN** se ve una runa nórdica en el centro del área, legible desde 3ª persona.

#### **Escenario 3: Sigue al mouse**

* **GIVEN** modo AoE activo.
* **WHEN** el jugador mueve el cursor.
* **THEN** el indicador (anillo + runa) sigue la posición del suelo apuntada.

#### **Escenario 4: Al castear se limpia**

* **GIVEN** el indicador apuntando.
* **WHEN** el jugador hace click y castea.
* **THEN** el indicador desaparece y la zona activa se dibuja con su VFX de skill (sin duplicar el pre-cast).

#### **Escenario 5: SelfAoE**

* **GIVEN** una skill `SelfAoE`.
* **WHEN** se lanza.
* **THEN** no aparece el pre-cast de apuntado (el SelfAoE no usa el indicador); el comportamiento actual se mantiene.

#### **Escenario 6: Config data-driven**

* **GIVEN** los colores y la textura de la runa en config.
* **WHEN** se cambian los valores en config.
* **THEN** el indicador refleja los cambios sin modificar código.

#### **Escenario 7: Móvil**

* **GIVEN** un dispositivo táctil.
* **WHEN** se usa una skill AoE.
* **THEN** el indicador nuevo funciona (touch move/tap) sin romper joystick ni UI.

#### **Escenario 8: Sin regresiones**

* **GIVEN** combate con AoE en dungeon.
* **WHEN** se castean `GroundAoE` y `SelfAoE` repetidamente.
* **THEN** no hay errores rojos, el daño es el mismo y la zona activa se dibuja igual que antes.

---

### **Comportamiento Visual / Reglas de Negocio**

* El pre-cast es el "sello" de apuntado: anillo púrpura + relleno + runa nórdica central.
* La runa puede usar placeholder de primitivas hasta que el diseñador entregue la textura; luego se enlaza por config (`runeTextureId`) y se registra en `ASSETS_REGISTRY`.
* No se agrega UI en pantalla (sigue siendo un indicador en el mundo, como hoy).
* El color púrpura del pre-cast convive con los VFX por skill de la zona activa (R8a/b/c), que no cambian.

---

### **Alcance**

#### Incluye

* Reemplazo del color celeste por la paleta púrpura (`#B48ADE`, `#B48ADE55`, claros/oscuros).
* Anillo de borde + relleno semitransparente con el radio de la skill.
* Runa nórdica central (textura por config o placeholder de primitivas).
* Config data-driven (colores, textura de runa, spin opcional).
* Mantener seguimiento del mouse, tamaño por `aoeRadius` y limpieza al castear.
* Verificación PC y móvil.

#### No incluye

* Cambios al cast, daño, rango o validación server del AoE.
* Cambios a la zona activa persistente ni a los VFX por skill (R6.9/R8).
* Nuevos RemoteEvents ni réplica del indicador a otros jugadores.
* Assets nuevos obligatorios: la runa puede ser placeholder; el asset real del diseñador llega por config después.

---

### **Definition of Done (DoD)**

* [ ] El pre-cast usa la paleta púrpura y no queda ningún elemento celeste (`#64C8FF`).
* [ ] Anillo + relleno con radio de la skill visibles al apuntar.
* [ ] Runa nórdica en el centro (textura por config o placeholder de primitivas).
* [ ] El indicador sigue al mouse y se limpia al castear.
* [ ] `SelfAoE` no muestra el indicador de apuntado (comportamiento intacto).
* [ ] Colores y textura viven en config (sin hardcode en `SkillBarClient`).
* [ ] Móvil: funciona sin romper joystick/UI.
* [ ] Sin errores rojos casteando `GroundAoE` y `SelfAoE` repetidamente.
* [ ] El cast y la zona activa (VFX de skill) no cambian.
* [ ] Si se incorpora textura real de runa, queda registrada en `ASSETS_REGISTRY`.
* [ ] Se actualizan `PROJECT_ARCHITECTURE` y el registro de la HU/RC al cerrar.
* [ ] Nota `R6.12 completo` en el GDD después de la verificación, no antes.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).

---

### **Decisiones por defecto R6.12**

| Tema | Default |
|------|---------|
| Borde/anillo | `#B48ADE` |
| Relleno | `#B48ADE` ~33% alfa (`#B48ADE55`) |
| Detalle | `#C9A8E8` (claro) / `#9A6FD0` (oscuro) |
| Runa central | Textura por config (`runeTextureId`) o placeholder de primitivas |
| Spin de la runa | Opcional, configurable; sin trabajo por frame |
| Radio | `skill.aoeRadius` (existente) |
| Zona activa persistente | Sin cambios (VFX por skill de R6.9/R8) |

---

### **Estimación (orientativa)**

1 sesión: paleta/config, anillo + relleno + runa, limpieza y regresión PC/móvil.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-20 | Creación de HU-R6.12: rediseño del pre-cast AoE — anillo púrpura `#B48ADE` (aprobado en Pencil, nodo `u6eYDO`) con runa nórdica central; reemplaza el indicador celeste |