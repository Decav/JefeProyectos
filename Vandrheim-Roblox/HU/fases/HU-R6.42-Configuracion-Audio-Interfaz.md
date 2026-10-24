# HU-R6.42: Ajustes de audio, cámara e interfaz en el menú in-game (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R6.x / Menú / Preferencias de jugador
**Prioridad:** Alta — polish pre-lanzamiento
**Estado:** Lista para RC
**Tipo:** Mejora de menú y preferencias de cliente (dev)
**Fase GDD:** R6.42 — completar ajustes del menú in-game
**Depende de:** HU-R6.10 (MenuUI), HU-R9b (volumen general, SFX y música), HU-R6.1 (FootstepSystem), HU-R3.1/R3.2 (cámara/CameraConfig), HU-R6.15/R6.23 (gestos y sensibilidad móvil), `SFXConfig`, `MusicConfig`, preferencias existentes del jugador
**No modifica:** gameplay, movimiento base, velocidad del jugador, cámara/targeting server-side, contenido ni mezcla de música/contexto.

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** equilibrar por separado la música, los SFX, las pisadas y el volumen general, además de ajustar cámara y zoom desde una pestaña de Interfaz,
**para** adaptar el juego a mis preferencias y a mi dispositivo.

---

### Descripción / Contexto

El menú in-game (R6.10) contiene el esqueleto de ajustes; R9b ya implementa el volumen general, la música por contexto y el catálogo de SFX. Falta exponer mezclas independientes de efectos/música/pisadas y los ajustes de cámara. La cámara ya tiene sensibilidad base por plataforma (R6.23); esta HU permite que cada jugador la ajuste conservando el aumento de sensibilidad que ya se aplicó por defecto.

La opción **Configuración** del menú abre paneles con dos tabs: **Sonido** y **Interfaz**. El tab Interfaz añade sensibilidad y límites de zoom. El fondo blanco visible en la franja superior del menú se registra como ajuste visual extra: el fondo del menú debe cubrir el viewport completo, mientras que sus controles respetan safe areas.

**Criterio de hecho global:** el jugador ajusta y conserva sus preferencias de audio y cámara; los controles de zoom/sensibilidad funcionan tanto con mouse como con touch, y el menú no presenta una franja blanca en la parte superior.

---

### Especificaciones técnicas / Contratos

#### 1. Navegación de ajustes

* Reutilizar `MenuUI`/el panel de configuración existente; no crear un segundo menú ESC.
* Añadir tabs **SONIDO** e **INTERFAZ** con estados seleccionado, hover/foco y táctil.
* El botón **Continuar**, volver al juego y el acceso existente de volver a selección permanecen intactos.
* El ajuste de gráficos de R9b conserva su comportamiento actual; no ampliar ni rediseñar sus opciones en esta HU.

#### 2. Tab Sonido

Exponer cuatro controles deslizantes independientes, rango visual 0–100 %:

| Control | Qué afecta |
|---|---|
| **Volumen general** | Multiplicador maestro de todo el audio. El control existente se conserva; no duplicar ni resetear sus valores. |
| **SFX** | Efectos del juego y UI, excluyendo música y pisadas. |
| **Música** | Tracks de `MusicConfig`, incluidos los cambios/crossfade por contexto. |
| **Pisadas** | Multiplicador de volumen de `FootstepSystem`, sin alterar variaciones por material, modo o pitch. |

* Asignar los canales a `SoundGroup` o al sistema de mezcla actual: Master controla todos; SFX, Music y Footsteps son canales independientes bajo Master.
* Cambiar SFX no cambia música ni pisadas; cambiar pisadas no cambia otros SFX. El multiplicador efectivo nunca supera el master.
* `FootstepSystem` mantiene sus volúmenes relativos por material/correr-caminar; el nuevo control solo agrega un multiplicador global de pisadas.
* `MusicConfig` conserva tracks, contexto, loop/crossfade y reglas actuales. El slider de música solo cambia nivel, no selección ni sincronía.
* Mostrar porcentaje/valor y reflejar el cambio inmediatamente. Un valor 0 silencia solo esa categoría; Master 0 silencia todos los grupos.
* Conservar el valor funcional actual de Volumen general y su alcance de persistencia; guardar los nuevos valores con el mismo mecanismo/ámbito de preferencias.
* Las preferencias sobreviven cerrar/reabrir el menú, respawn y rejoin. Cargar defaults si no hay valor guardado; un botón **Restablecer** devuelve cada control al default sin modificar gameplay.
* No guardar por frame: aplicar cambios en cliente inmediatamente y persistir al cambiar el slider con debounce/commit.

#### 3. Tab Interfaz — sensibilidad de cámara

* Añadir slider **Sensibilidad de cámara** con default `1.0×` (100 %). Aplica como multiplicador al valor base actual de `CameraConfig` para la plataforma activa.
* Mantener los valores base por plataforma (`rotationSensitivityPc` y `rotationSensitivityMobile`) de R6.23; especialmente conservar el aumento móvil ya configurado. El slider escala esos defaults, no los reemplaza por una constante común.
* Actualizar la rotación en vivo para mouse/PC y drag/touch en móvil; no afecta joystick, targeting, click izquierdo, zoom ni control de cámara mientras hay un modal bloqueante.
* Default 100 % representa exactamente la sensibilidad actual de cada plataforma. Rango propuesto configurable: 50–200 %, pasos de 5 %; el RC puede ajustar límites con playtest.

#### 4. Tab Interfaz — límites de zoom

* Exponer dos controles diferenciados:
  * **Acercamiento máximo**: ajusta el límite cercano (`CameraConfig.MinDistance`); menor distancia permite acercarse más.
  * **Alejamiento máximo**: ajusta el límite lejano (`CameraConfig.MaxDistance`); mayor distancia permite alejarse más.
* Defaults iniciales: conservar los valores actuales de `CameraConfig` (R3.2 propone MinDistance 3, DefaultDistance 6 y MaxDistance 16; confirmar los valores live durante RC).
* Los controles solo modifican límites de zoom por preferencia; no cambian el zoom actual hasta la siguiente acción del jugador. Si la distancia actual queda fuera del nuevo rango, clamp suavemente al límite más cercano.
* Mantener `MinDistance < MaxDistance`; no permitir valores inseguros que atraviesen el personaje, cambien el foco del target o causen clipping excesivo.
* El mismo rango configurado se respeta en rueda de mouse/scroll PC y pinza móvil (R6.23). Guardar la preferencia con el mismo ámbito que sensibilidad.

#### 5. Preferencias y persistencia

* Reutilizar el almacenamiento local/de dispositivo que ya usa Volumen general (R9b); no almacenar estos ajustes dentro de un personaje ni añadir escrituras de gameplay al servidor.
* Esquema lógico mínimo: `audio.master`, `audio.sfx`, `audio.music`, `audio.footsteps`, `interface.cameraSensitivityMultiplier`, `interface.cameraMinDistance`, `interface.cameraMaxDistance`.
* Si no existe un valor guardado, cargar el default vigente: los valores actuales de Audio/`CameraConfig` y sensibilidad `100 %` (que conserva los defaults PC/móvil mejorados).
* Aplicar preferencias al iniciar, tras rejoin y al restaurar defaults. Debounce de persistencia; no guardar por cada frame/muestra del slider.

#### 6. Menú a pantalla completa — extra visual opcional

* Si entra en el alcance visual de este RC, el contenedor visual principal del menú y su backdrop ocupan el viewport completo, cubriendo la franja blanca superior que hoy aparece por safe area/inset.
* Mantener título, tabs, cierre y controles dentro de padding seguro; extender el menú a pantalla completa no significa colocar botones bajo notch, cámara o barras del sistema.
* PC: cubrir todo el viewport. Móvil: fondo edge-to-edge con contenido anclado a safe area.
* Este extra puede postergarse sin bloquear los controles funcionales de Sonido/Interfaz.

---

### Criterios de aceptación (Gherkin)

#### Escenario 1: Separar audio por categoría

* **GIVEN** un jugador en el tab Sonido
* **WHEN** baja SFX a 0 y reproduce música/pisadas
* **THEN** se silencian los efectos generales, mientras música y pisadas conservan sus niveles

#### Escenario 2: Control de pisadas

* **GIVEN** música, otros SFX y pisadas activos
* **WHEN** el jugador baja el control de Pisadas
* **THEN** cambia únicamente el nivel de `FootstepSystem`; los sonidos por material y las diferencias caminar/correr permanecen

#### Escenario 3: Volumen general

* **GIVEN** valores independientes de SFX, música y pisadas
* **WHEN** el jugador baja Volumen general
* **THEN** todos los canales bajan proporcionalmente; sus sliders relativos no se sobrescriben

#### Escenario 4: Persistencia

* **GIVEN** el jugador cambió audio, sensibilidad y límites de zoom
* **WHEN** cierra el menú, respawnea o vuelve a entrar
* **THEN** se recuperan sus preferencias; Restablecer devuelve solo ajustes al default

#### Escenario 5: Sensibilidad mantiene el default mejorado

* **GIVEN** el slider de sensibilidad en 100 %
* **WHEN** se abre/cierra el menú y se rota la cámara en PC o móvil
* **THEN** cada plataforma usa su sensibilidad base actual (incluido el aumento móvil de R6.23)

#### Escenario 6: Zoom personalizable

* **GIVEN** el jugador ajusta Acercamiento máximo o Alejamiento máximo
* **WHEN** usa scroll o pinza
* **THEN** la cámara respeta inmediatamente el rango nuevo sin cruzar sus límites ni afectar otras acciones táctiles

#### Escenario 7: Relación min/max

* **GIVEN** el jugador intenta dejar MinDistance igual o mayor que MaxDistance
* **WHEN** mueve cualquiera de los sliders
* **THEN** la UI limita/ajusta el par para mantener `MinDistance < MaxDistance` y muestra los valores efectivos

#### Escenario 8: Backdrop full-screen

* **GIVEN** se implementa el extra visual de backdrop full-screen y el menú está abierto en PC o móvil con safe area/inset
* **WHEN** se muestra la pantalla
* **THEN** no existe la franja blanca superior; el fondo cubre el viewport y los controles siguen dentro del área segura

#### Escenario 9: Regresión

* **GIVEN** ajustes Sonido/Interfaz y HUD táctil activos
* **WHEN** el jugador abre/cierra el menú, combate, usa targeting y rota/zoomea la cámara
* **THEN** no se rompen ESC, joystick, pinch, drag, botones del HUD, audio por contexto ni el flujo de volver a selección

---

### Alcance

#### Incluye

* Ampliar MenuUI con tabs Sonido e Interfaz.
* Sliders Master, SFX, Music y Footsteps; el master actual se conserva.
* Sensibilidad de cámara sobre los defaults PC/móvil actuales.
* Límites de zoom in/out ajustables, guardados y respetados por scroll/pinza.
* Extra visual opcional: backdrop edge-to-edge, manteniendo controles dentro de safe areas.

#### No incluye

* Cambiar tracks, SFX, su selección, crossfade, volumen relativo por evento ni sonidos por material.
* Cambiar defaults aumentados de sensibilidad R6.23; el slider es multiplicador personal.
* Calidad gráfica, resolución, FOV, movimiento, combate, targeting o reglas de juego.
* Persistir ajustes por personaje de forma separada; reutilizar el ámbito global/de dispositivo ya vigente para el Volumen general.

---

### Definition of Done (DoD)

* [ ] El menú ofrece tabs funcionales Sonido e Interfaz; ESC/móvil y volver a selección siguen intactos.
* [ ] Master, SFX, Music y Footsteps son independientes según su contrato; música/crossfade y pisadas por material no se rompen.
* [ ] Sensibilidad ajusta PC/móvil sobre los defaults actuales; 100 % conserva la sensibilidad aumentada actual.
* [ ] MinDistance/MaxDistance se pueden ajustar, persisten y se respetan por scroll y pinza; min siempre menor que max.
* [ ] Defaults y restauración de preferencias funcionan después de respawn/rejoin.
* [ ] **Extra opcional:** backdrop cubre la franja blanca/viewport; controles siguen seguros y accesibles en notch/safe area.
* [ ] QA PC y móvil real/simulador; verificar Master 0, cada canal 0, min/max, sensibilidad baja/alta y regresión de camera inputs.
* [ ] Sin errores rojos ni pérdida de preferencias; captura del menú en desktop y móvil adjunta al RC.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-10-23 | HU nueva: separar mezcla de audio, añadir tab Interfaz con sensibilidad/zoom y registrar fullscreen como extra visual. |
