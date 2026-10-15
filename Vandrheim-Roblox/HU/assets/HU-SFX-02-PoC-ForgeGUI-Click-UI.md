# HU-SFX-02: PoC de flujo SFX — 1 sonido (Click UI) con fuente toolbox/externa

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** SFX / Prueba de concepto (flujo de integración)
**Prioridad:** Alta
**Estado:** Implementada (reporte PO 2026-10-12; verificación/QA pendiente — confirmar ID del click en ASSETS_REGISTRY)
**Tipo:** Prueba de concepto (dev) — 1 solo SFX
**Fase GDD:** R9b (polish SFX — valida el flujo que usará R9b)
**Depende de:** HU-SFX-01 (formato, naming e integración por `SFXConfig` + `ASSETS_REGISTRY`), `SFX_LIST.md` (referencia del sonido), HU-R9b (usa el mismo contrato; la PoC y R9b van de la mano)
**No modifica:** gameplay, balance ni mecánicas; **no se generan aún los 48 SFX del catálogo**

---

### **Narrativa (INVEST)**

**Como** equipo,
**quiero** probar el **flujo completo de SFX** (subir → `SFXConfig` → reproducir → registrar) con **un solo** sonido — el **Click UI** (`Sfx_ui_click`, el sonido más usado del juego) — usando una fuente del PO (toolbox de Roblox o archivo externo),
**para** validar que el contrato que usará R9b funciona antes de producir/integrar el catálogo.

**Como** jugador,
**quiero** que los botones de la interfaz suenen a un click táctil y cálido (madera/cuero, estilo Vandrheim),
**para** que el feedback de UI se sienta propio y pulido.

---

### **Descripción del Requerimiento / Contexto**

`HU-SFX-01` definió el catálogo de 48 SFX con formato, naming e integración por config. La PoC con **ForgeGUI falló** (audio solo con suscripción mensual; decisión PO: no pagar). El PO tiene sonidos propios para probar (toolbox de Roblox o archivos externos).

Esta PoC valida **el flujo** —no la herramienta— con **el sonido más transversal**: `Sfx_ui_click` (todos los botones/ventanas del juego). Usa **exactamente el mismo contrato que HU-R9b** (misma entrada `SFXConfig`, mismo registro), para que la PoC y R9b vayan de la mano y nada de lo integrado haya que rehacer.

**Criterio de hecho global:** `Sfx_ui_click` (fuente del PO) suena en la UI del juego (PC y móvil) integrado por `SFXConfig`, queda registrado, y el flujo queda validado para que R9b lo reutilice tal cual.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Sonido del PO (1 sonido)**

* **Sonido:** `Sfx_ui_click` — fuente aportada por el PO (toolbox de Roblox o archivo externo; el PO indica cuál probar).
* **Formato de entrega:** el que traiga la fuente (subible como Roblox Audio; se respetan los límites del publisher). Sin transcodificación obligatoria para la PoC.
* **Naming/carpeta:** `Sfx_ui_click` en `Assets/SFX/UI/`.
* **Reglas vigentes:** sin voces, sin música, sin imitación de juegos existentes (paleta sonora Vandrheim); respetar la licencia de la fuente (toolbox: licencia Roblox; externo: uso propio del PO).

#### **2. Integración mínima (dev)**

* Subir el sonido aceptado para esta PoC al Asset Server → `rbxassetid`.
* Crear/actualizar la entrada en `ReplicatedStorage.Config.SFXConfig`:
  ```luau
  { id = "ui_click", assetId = "rbxassetid://...", volume = 0.5, category = "UI", cooldown = 0.05 }
  ```
* Reproducir el click en las interacciones de UI principales (botones de ventanas: HUD/menú/mochila/equipo/matchmaking — al menos un punto central de click para validar; el dev elige el patrón existente de reproducción de UI o conecta el más usado).
* Registrar en `ASSETS_REGISTRY` (fuente real: toolbox de Roblox o archivo aportado por el PO, con fecha).
* No hay cambios a gameplay, balance ni otros sonidos.
* **Mismo contrato que HU-R9b** (id `ui_click`, campos y registro idénticos) — lo que se integre aquí lo reutiliza R9b sin rehacer.

#### **3. Evaluación de la PoC (lo que decide el PO)**

Al cerrar, el reporte del dev debe incluir la evaluación del **flujo** (lo que reutilizará R9b):

| Criterio | Qué se evalúa |
|----------|---------------|
| Calidad del material | ¿El click suena coherente con la paleta Vandrheim y no fatiga al repetirse? (volumen, cuerpo, decay) |
| Flujo de trabajo | Tiempo/resultado de tomar la fuente del PO, subirla y enlazarla; ¿el contrato SFXConfig/REGISTRY alcanza tal cual? |
| Reutilización en R9b | ¿Lo integrado (entrada `ui_click`, patrón de reproducción, registro) sirve sin cambios para el resto del catálogo? |

* **Si la evaluación es positiva:** R9b integra el resto del catálogo sobre este mismo contrato. **Esto NO se hace en esta HU.**
* **Si es negativa:** se ajusta el contrato antes de R9b, sin impacto en gameplay.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: La fuente del PO genera el sonido**

* **GIVEN** el sonido `Sfx_ui_click` aportado por el PO (toolbox o archivo externo).
* **WHEN** se sube e integra.
* **THEN** se enlaza en `SFXConfig` (`ui_click`) con sus metadatos reales registrados.
* **AND** suena coherente con la paleta Vandrheim (no digital/agudo, no fatiga).

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
* **THEN** la fuente registrada es la real (toolbox de Roblox o archivo del PO) con fecha y licencia clara.

#### **Escenario 5: Evaluación entregada**

* **GIVEN** el resultado de la PoC.
* **WHEN** el dev reporta al PM.
* **THEN** el reporte incluye la evaluación (calidad, fidelidad, flujo de trabajo, esfuerzo) con recomendación de avanzar o no a la producción completa.

---

### **Alcance**

#### Incluye

* 1 sonido del PO: `Sfx_ui_click` (toolbox o archivo externo).
* Subida + entrada en `SFXConfig` + reproducción en clicks de UI (PC/móvil) — **mismo contrato que R9b**.
* Registro en `ASSETS_REGISTRY`.
* Reporte de evaluación del flujo para R9b.

#### No incluye

* Los 48 SFX del catálogo (se deciden tras la evaluación).
* Música, voces, pisadas (ya existen).
* Cambios a gameplay, balance, VFX ni mecánicas.
* Cambios al contrato de SFX vigente.

---

### **Definition of Done (DoD)**

* [ ] Sonido del PO subido y enlazado en `SFXConfig` (`ui_click`) y registrado en `ASSETS_REGISTRY` (fuente real).
* [ ] El click suena en la UI en PC y móvil, sin spam y con volumen coherente.
* [ ] El sonido es coherente con la paleta de Vandrheim (no digital/agudo, no fatiga).
* [ ] Sin otros SFX nuevos; sin cambios a gameplay; sin errores rojos.
* [ ] Reporte al PM con la evaluación del flujo (calidad, flujo de trabajo, reutilización en R9b).
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de la evaluación del PO.

---

### **Decisiones por defecto SFX-02**

| Tema | Default |
|------|---------|
| Sonido de prueba | `Sfx_ui_click` (el más usado) |
| Herramienta/fuente | Sonido aportado por el PO (toolbox de Roblox o archivo externo) — ForgeGUI descartado (audio solo con suscripción; decisión PO) |
| Integración | `SFXConfig` (`ui_click`) + `ASSETS_REGISTRY` (fuente real) — **mismo contrato que R9b** |
| Reproducción | Clicks de botones de UI (PC y móvil), cooldown categoría UI |
| Producción completa | **No en esta HU** — la hace R9b sobre este contrato |

---

### **Estimación (orientativa)**

Generación: minutos–1 sesión (ForgeGUI). Dev: 1 sesión (subir, config, conectar click de UI, QA). Reporte incluido.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-SFX-02: PoC de ForgeGUI con 1 solo SFX (`Sfx_ui_click`) para validar calidad/flujo antes de producir los 48 del catálogo; la actualización de HU-SFX-01 depende del resultado |
| 2026-10-09 | Decisión PM para esta PoC: aceptar MP3 nativo de ForgeGUI en lugar de WAV; excepción limitada a `Sfx_ui_click`, sin modificar el contrato global SFX-01. Mantener el objetivo de 0.2 s en el prompt, registrar duración/metadatos reales y no transcodificar automáticamente |
| 2026-10-12 | **PoC reorientada (ForgeGUI descartado — audio solo con suscripción):** valida el **flujo** con 1 sonido del PO (toolbox/externo), con **el mismo contrato que R9b** (`SFXConfig` + registro) para que ambas vayan de la mano sin rehacer nada |
| 2026-10-12 | **PoC implementada (reporte PO):** el click UI suena integrado; pendiente confirmar su ID en ASSETS_REGISTRY durante QA |
