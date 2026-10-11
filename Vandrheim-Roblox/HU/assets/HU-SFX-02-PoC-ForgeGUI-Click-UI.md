# HU-SFX-02: PoC ForgeGUI — 1 SFX (Click UI) para validar la herramienta

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** SFX / Prueba de concepto (ForgeGUI)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Prueba de concepto (dev) — 1 solo SFX
**Fase GDD:** R9b (polish SFX — proceso en evaluación)
**Depende de:** HU-SFX-01 (formato, naming e integración por `SFXConfig` + `ASSETS_REGISTRY`), `SFX_LIST.md` (prompt canónico del sonido), integración de SFX vigente (config-driven)
**No modifica:** gameplay, balance ni mecánicas; **no se generan aún los 48 SFX del catálogo**

---

### **Narrativa (INVEST)**

**Como** equipo,
**quiero** probar la nueva herramienta **ForgeGUI** (IA, conectada a Codex) generando **un solo** SFX — el **Click UI** (`Sfx_ui_click`, el sonido más usado del juego) — e integrarlo con el flujo de SFX que ya tenemos,
**para** evaluar su calidad y viabilidad antes de decidir si todo el catálogo se produce con ella.

**Como** jugador,
**quiero** que los botones de la interfaz suenen a un click táctil y cálido (madera/cuero, estilo Vandrheim),
**para** que el feedback de UI se sienta propio y pulido.

---

### **Descripción del Requerimiento / Contexto**

`HU-SFX-01` definió el catálogo de 48 SFX para producir con IA generativa, con formato, naming e integración por config. El PO integró **ForgeGUI**, una herramienta de desarrollo con IA que según su documentación genera SFX, música y assets, ya conectada a Codex.

Esta PoC valida ForgeGUI con **el sonido más transversal**: `Sfx_ui_click` (todos los botones/ventanas del juego). El resultado se integra con el contrato vigente de SFX (sin tocar los demás sonidos).

**Criterio de hecho global:** ForgeGUI genera `Sfx_ui_click` con la calidad/estilo esperado, el click suena en la UI del juego (PC y móvil) integrado por `SFXConfig`, y el resultado queda evaluado para decidir si el catálogo completo pasa a ForgeGUI.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Generación con ForgeGUI (1 sonido)**

* **Sonido:** `Sfx_ui_click` — prompt canónico ya definido en `SFX_LIST.md` (se le pasa tal cual a ForgeGUI):
  > "Short original UI sound effect for a dark fantasy MMORPG. A player pressing a hand-carved wooden button on an old settlement interface. Thick polished wood tapped with a leather-wrapped finger, dry and warm, with a faint low body and a quick natural decay. Subtle, tactile, never sharp or digital. Understated so it can be heard hundreds of times per session without fatigue. 0.2 seconds, clean ending, no modern UI sounds, no imitation of existing games."
* **Formato de entrega — decisión PM 2026-10-09, excepción exclusiva de esta PoC:** se acepta la salida nativa **MP3 de ForgeGUI** en lugar de WAV 44.1 kHz/16-bit/mono. El audio se publica como Roblox Audio y se respetan los límites del publisher. Esta decisión no modifica el contrato global de SFX-01 ni autoriza a cambiar los otros 48 sonidos.
* **Duración/calidad:** el prompt canónico conserva el objetivo de 0.2 s. La API actual solo acepta `duration_seconds` explícito desde 0.5 s; omitir ese campo y conservar la duración indicada en el prompt. Registrar la duración y metadatos que realmente devuelva ForgeGUI; no transcodificar ni regenerar automáticamente. Mantener la evaluación de nivel/ausencia de clipping como criterio de calidad y declarar cualquier métrica no disponible como no verificada.
* **Naming/carpeta:** `Sfx_ui_click` en `Assets/SFX/UI/`.
* **Reglas vigentes:** sin voces, sin música, sin imitación de juegos existentes (paleta sonora Vandrheim).

#### **2. Integración mínima (dev)**

* Subir el MP3 aceptado para esta PoC al Asset Server → `rbxassetid`.
* Crear/actualizar la entrada en `ReplicatedStorage.Config.SFXConfig`:
  ```luau
  { id = "ui_click", assetId = "rbxassetid://...", volume = 0.5, category = "UI", cooldown = 0.05 }
  ```
* Reproducir el click en las interacciones de UI principales (botones de ventanas: HUD/menú/mochila/equipo/matchmaking — al menos un punto central de click para validar; el dev elige el patrón existente de reproducción de UI o conecta el más usado).
* Registrar en `ASSETS_REGISTRY` (fuente: **ForgeGUI** / IA generativa, producción propia; fecha).
* No hay cambios a gameplay, balance ni otros sonidos.

#### **3. Evaluación de la PoC (lo que decide el PO)**

Al cerrar, el reporte del dev debe incluir la evaluación respecto a los criterios del catálogo:

| Criterio | Qué se evalúa |
|----------|---------------|
| Calidad del material | ¿Suena a madera/cuero cálidos y táctiles (no digital/agudo)? ¿coherente con la paleta? |
| Usabilidad en sesiones largas | ¿No fatiga al repetirse cientos de veces? (volumen, cuerpo, decay) |
| Fidelidad al prompt | ¿Cumple el prompt de SFX_LIST sin imitaciones? |
| Flujo de trabajo | Tiempo/resultado de generar, exportar y subir; ¿cómo se integra con Codex? |
| Esfuerzo de integración | ¿El contrato SFXConfig/REGISTRY alcanza tal cual? |

* **Si la evaluación es positiva:** el PO actualizará **HU-SFX-01** para que la producción completa (los 48) se haga con ForgeGUI. **Esto NO se hace en esta HU.**
* **Si es negativa:** se decide la alternativa (otra fuente/herramienta) sin impacto en lo integrado.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: ForgeGUI genera el sonido**

* **GIVEN** el prompt canónico de `Sfx_ui_click`.
* **WHEN** ForgeGUI genera el archivo.
* **THEN** se recibe la salida MP3 nativa de ForgeGUI (excepción aprobada solo para esta PoC); se registran sus metadatos reales y se evalúan el objetivo de duración (~0.2 s), nivel y ausencia de clipping sin afirmar métricas no medidas.
* **AND** suena a madera/cuero, cálido y táctil (no digital).

#### **Escenario 2: Suena en la UI**

* **GIVEN** el sonido subido y enlazado en `SFXConfig`.
* **WHEN** el jugador hace click en botones de la interfaz (PC y móvil).
* **THEN** se escucha el click con volumen coherente.
* **AND** no se satura al hacer clicks rápidos (cooldown de categoría UI).

#### **Escenario 3: Sin cambios colaterales**

* **GIVEN** el sonido integrado.
* **WHEN** se revisa el resto del juego.
* **THEN** no hay otros SFX nuevos, ni cambios de gameplay/balance.
* **AND** no hay errores rojos.

#### **Escenario 4: Registrado**

* **GIVEN** el sonido terminado.
* **WHEN** se revisa `ASSETS_REGISTRY`.
* **THEN** la fuente registrada es ForgeGUI/IA generativa con fecha y licencia clara.

#### **Escenario 5: Evaluación entregada**

* **GIVEN** el resultado de la PoC.
* **WHEN** el dev reporta al PM.
* **THEN** el reporte incluye la evaluación (calidad, fidelidad, flujo de trabajo, esfuerzo) con recomendación de avanzar o no a la producción completa.

---

### **Alcance**

#### Incluye

* 1 generación de SFX con ForgeGUI: `Sfx_ui_click` (prompt de SFX_LIST).
* Subida + entrada en `SFXConfig` + reproducción en clicks de UI (PC/móvil).
* Registro en `ASSETS_REGISTRY`.
* Reporte de evaluación para decidir sobre HU-SFX-01.

#### No incluye

* Los 48 SFX del catálogo (se deciden tras la evaluación).
* Música, voces, pisadas (ya existen).
* Cambios a gameplay, balance, VFX ni mecánicas.
* Cambios al contrato de SFX vigente.

---

### **Definition of Done (DoD)**

* [ ] ForgeGUI generó `Sfx_ui_click` como MP3 nativo (desviación aprobada solo para esta PoC); duración/metadatos reales registrados, objetivo ~0.2 s evaluado y nivel/ausencia de clipping reportados sin afirmar métricas no medidas.
* [ ] Subido y enlazado en `SFXConfig` (`ui_click`) y registrado en `ASSETS_REGISTRY` (fuente ForgeGUI).
* [ ] El click suena en la UI en PC y móvil, sin spam y con volumen coherente.
* [ ] El sonido es coherente con la paleta de Vandrheim (madera/cuero cálidos; no digital/agudo).
* [ ] Sin otros SFX nuevos; sin cambios a gameplay; sin errores rojos.
* [ ] Reporte al PM con la evaluación de la PoC (calidad, fidelidad, flujo de trabajo) y recomendación sobre HU-SFX-01.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de la evaluación del PO.

---

### **Decisiones por defecto SFX-02**

| Tema | Default |
|------|---------|
| Sonido de prueba | `Sfx_ui_click` (el más usado) |
| Herramienta | ForgeGUI (IA, conectada a Codex) |
| Prompt | El canónico de `SFX_LIST.md` (sin modificaciones) |
| Formato | MP3 nativo ForgeGUI (excepción de esta PoC aprobada por PM 2026-10-09); SFX-01 global permanece sin cambios |
| Integración | `SFXConfig` (`ui_click`) + `ASSETS_REGISTRY` (fuente ForgeGUI) |
| Reproducción | Clicks de botones de UI (PC y móvil), cooldown categoría UI |
| Producción completa | **No en esta HU** — decide el PO tras la evaluación |

---

### **Estimación (orientativa)**

Generación: minutos–1 sesión (ForgeGUI). Dev: 1 sesión (subir, config, conectar click de UI, QA). Reporte incluido.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-SFX-02: PoC de ForgeGUI con 1 solo SFX (`Sfx_ui_click`) para validar calidad/flujo antes de producir los 48 del catálogo; la actualización de HU-SFX-01 depende del resultado |
| 2026-10-09 | Decisión PM para esta PoC: aceptar MP3 nativo de ForgeGUI en lugar de WAV; excepción limitada a `Sfx_ui_click`, sin modificar el contrato global SFX-01. Mantener el objetivo de 0.2 s en el prompt, registrar duración/metadatos reales y no transcodificar automáticamente |
