## HU-R3.3: Indicador visual del enemigo en target (contorno + flecha)

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** Combate / Targeting / Feedback visual  
**Prioridad:** Alta  
**Estado:** Lista para implementar  
**Tipo:** Mejora de feedback visual de combate  
**Fase GDD:** R3.3 (mejora posterior a R3.2; no amplía el alcance del MVP)  
**Depende de:** HU-R1 (targeting TAB/click), HU-R3.2 (corrección de TAB y PlayerList), HU-R4 (TargetFrame existente)  
**Componentes observados:** `StarterPlayer.StarterPlayerScripts.TargetingSystem`, `ReplicatedStorage.Shared.TargetState`, `StarterGui.HUD.HUDClient`, enemigos con atributos `Enemy`/`HP`/`Dead`

---

### **Narrativa (INVEST)**

**Como** jugador,  
**quiero** ver claramente cuál de los enemigos tengo en target cuando hay varios iguales (lobos, ácaros, etc.),  
**para** saber a quién estoy pegando sin depender solo del frame de vida.

**Como** jugador,  
**quiero** que el indicador se mueva al cambiar de objetivo y desaparezca cuando el enemigo muere,  
**para** que el combate se sienta claro y de MMORPG.

---

### **Descripción del Requerimiento / Contexto**

El sistema actual muestra el target únicamente en el `TargetFrame` del HUD (nombre + HP). Con enemigos del mismo modelo y nombre (ej. cinco lobos o cinco ácaros), el jugador no sabe cuál de ellos está seleccionado: la barra de vida del frame no identifica al modelo en el mundo.

Esta HU agrega un indicador visual en el mundo sobre el enemigo targeteado:

1. **Contorno (Highlight)** alrededor del modelo del enemigo.
2. **Flecha roja fija** flotando sobre la cabeza del enemigo, apuntando hacia abajo (no gira hacia el jugador).

Ambos indicadores son **locales al jugador** (solo se ven en la pantalla del jugador que tiene el target) y se derivan del estado de targeting existente (`TargetState`). No se crean RemoteEvents nuevos ni se toca la autoridad del servidor: el daño, el auto-attack y las validaciones de `CombatService` continúan intactos.

**Criterio de hecho global:** con varios enemigos iguales en pantalla, el jugador identifica al instante cuál tiene en target mediante el contorno y la flecha, y el indicador sigue el ciclo de `TAB`/click sin errores.

---

### **Especificaciones Técnicas / Contratos de API**

#### **Nuevo componente cliente**

| Componente | Tipo | Ubicación | Responsabilidad |
|------------|------|-----------|-----------------|
| `TargetIndicator` | LocalScript | `StarterPlayer.StarterPlayerScripts.TargetIndicator` | Escucha `TargetState.Changed`, aplica/quita Highlight y flecha sobre el modelo targeteado |
| `TargetIndicatorConfig` | ModuleScript | `ReplicatedStorage.Config.TargetIndicatorConfig` | Colores, transparencias, tamaños e ids configurables del indicador |

No se modifica `TargetingSystem`, `TargetState` ni `CombatService`. El `TargetFrame` del HUD se conserva tal cual.

#### **Contorno (Highlight)**

* Al seleccionar un target válido, se crea una instancia `Highlight` (clase nativa de Roblox) como hija del modelo del enemigo.
* `OutlineColor` = rojo enemigo (default propuesto: `Color3.fromRGB(255, 60, 60)`).
* `FillTransparency` = `1` (solo contorno, sin rellenar el modelo) o `0.9` como variante leve si en playtest se ve mejor; configurable.
* `OutlineTransparency` = `0`, `OutlineWidth` = `0.08` (defaults orientativos, configurables).
* Solo puede existir **un** Highlight activo por jugador: al cambiar de target se destruye el anterior antes de crear el nuevo.
* El Highlight se adjunta al modelo y lo acompaña mientras el enemigo se mueve; no requiere actualización por frame.

#### **Flecha sobre la cabeza**

* Se crea un `BillboardGui` como hijo del `HumanoidRootPart` del enemigo (o del modelo si no tiene HRP), con `Adornee` = la parte correspondiente.
* Contenido: `ImageLabel` con la imagen de una flecha roja **apuntando hacia abajo**, centrado, con `UIAspectRatioConstraint` (estándar del proyecto).
* `AlwaysOnTop = true` para que la flecha no quede detrás de paredes/objetos.
* La flecha **no rota**: permanece fija apuntando hacia abajo sobre la cabeza del enemigo (decisión cerrada con producto).
* Offset vertical sobre la cabeza: default propuesto `+3 studs` sobre el `HumanoidRootPart` (ajustable en config).
* Tamaño: default propuesto `UDim2.fromOffset(64, 64)` (ajustable en config).
* `MaxDistance` de visibilidad: default propuesto `0` (siempre visible mientras sea target) o `50` studs si en playtest se ve desordenado; configurable.

#### **Asset de la flecha**

* Fuente según `ASSETS_POLICY.md`: se prefiere una **imagen de flecha roja de la Roblox Library gratuita**, registrada en `ASSETS_REGISTRY` (rbxassetid, autor, licencia).
* Si no se dispone del asset aprobado, se usa **placeholder geométrico propio** (dos `Frame` combinados o forma triangular) marcado como reemplazable cambiando `arrowImageId` en config, sin tocar código.
* El id de la imagen vive en `TargetIndicatorConfig.arrowImageId`; nunca hardcodeado en el script.

#### **Ciclo de vida del indicador**

* **Target nuevo** (`TargetState.Changed`): destruir indicador anterior → aplicar Highlight + flecha al nuevo target.
* **Target inválido / nil**: eliminar todo indicador.
* **Target muere** (`Dead=true`): ocultar/eliminar el indicador. Si el dummy de prueba respawnea (R1) y sigue siendo el target, el indicador reaparece; si el enemigo de dungeon se despawna, se limpia sin errores.
* **Modelo destruido** (AncestryChanged / Parent=nil): limpiar conexiones e instancias del indicador para no dejar huérfanos.
* **Respawn / cambio de personaje del jugador**: el indicador se reconstruye con el nuevo estado de target; no quedan conexiones ni objetos duplicados.
* Los indicadores son **por jugador y locales**: en el MVP cada jugador solo ve su propio indicador (multiplayer-ready: el estado es por jugador).

#### **Detección de estados del enemigo**

* Reutilizar los atributos existentes: `Enemy=true`, `Dead`, `HP`/`MaxHP`.
* Priorizar señales (`GetAttributeChangedSignal("Dead")`, `AncestryChanged`) sobre bucles de polling para actualizar la visibilidad; si se usa un refresco periódico, debe ser ligero (ej. cada `0.2 s`, al estilo del HUD) y no por frame.

#### **Seguridad y autoridad**

* El indicador es **visual puro**: no habilita daño, no cambia target en el servidor ni replica estado.
* `CombatService` mantiene la autoridad del target y del daño; el cliente solo declara intenciones como hasta ahora.
* Un cliente manipulado puede mostrar el indicador sobre cualquier modelo localmente, pero eso no le da daño ni poder: el servidor sigue validando `SetTarget` y `ApplyDamage`.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Target con TAB muestra el indicador**

* **GIVEN** el jugador tiene enemigos válidos cerca.
* **WHEN** presiona `TAB` y selecciona uno.
* **THEN** el enemigo seleccionado muestra contorno rojo.
* **AND** muestra una flecha roja fija sobre su cabeza apuntando hacia abajo.
* **AND** el `TargetFrame` sigue mostrando nombre y HP como hasta ahora.

#### **Escenario 2: Solo un indicador a la vez**

* **GIVEN** el jugador tiene un target con indicador.
* **WHEN** cambia de target.
* **THEN** el indicador anterior desaparece por completo.
* **AND** el nuevo enemigo muestra exactamente un contorno y una flecha.
* **AND** no quedan Highlight ni BillboardGui duplicados en la escena.

#### **Escenario 3: Ciclo de TAB mueve el indicador**

* **GIVEN** cinco enemigos iguales ordenados por distancia.
* **WHEN** el jugador pulsa `TAB` varias veces.
* **THEN** el contorno y la flecha acompañan cada cambio de target.
* **AND** en cada pulsación se distingue sin ambigüedad cuál es el nuevo objetivo.

#### **Escenario 4: Click también muestra el indicador**

* **GIVEN** el jugador hace click izquierdo sobre un enemigo.
* **WHEN** el enemigo queda targeteado.
* **THEN** se aplica el mismo contorno y flecha que con `TAB`.

#### **Escenario 5: Sin target no hay indicador**

* **GIVEN** el jugador no tiene target o el target quedó vacío.
* **WHEN** se actualiza el estado.
* **THEN** no hay contorno ni flecha sobre ningún enemigo.

#### **Escenario 6: Target muere**

* **GIVEN** el enemigo targeteado recibe daño hasta 0 HP.
* **WHEN** el servidor marca `Dead=true`.
* **THEN** el indicador desaparece.
* **AND** no se muestra el indicador sobre enemigos muertos.

#### **Escenario 7: Respawn del dummy**

* **GIVEN** el dummy de prueba (R1) muere y respawnea en el mismo sitio.
* **WHEN** vuelve con HP lleno y sigue siendo el target.
* **THEN** el indicador reaparece sobre él.
* **AND** no se duplica ni se rompe al volver.

#### **Escenario 8: Enemigo destruido**

* **GIVEN** un enemigo targeteado es eliminado del Workspace (despawn de dungeon).
* **WHEN** el modelo deja de existir.
* **THEN** el indicador se limpia sin errores rojos.
* **AND** el target del HUD se comporta según el flujo actual.

#### **Escenario 9: Flecha fija hacia abajo**

* **GIVEN** un enemigo targeteado se mueve y el jugador rota la cámara.
* **WHEN** se observa la flecha.
* **THEN** la flecha permanece apuntando hacia abajo sobre la cabeza del enemigo.
* **AND** no gira hacia el jugador ni cambia de orientación.
* **AND** `AlwaysOnTop` la mantiene visible sobre obstáculos.

#### **Escenario 10: Múltiples enemigos iguales**

* **GIVEN** cinco enemigos del mismo modelo y nombre en pantalla.
* **WHEN** el jugador selecciona uno con `TAB` o click.
* **THEN** el contorno + flecha identifican inequívocamente cuál está targeteado.
* **AND** los demás enemigos no muestran ningún indicador.

#### **Escenario 11: Respawn y cambio de personaje**

* **GIVEN** el jugador respawnea o cambia de personaje.
* **WHEN** el personaje vuelve con su target previo (si persiste) o sin target.
* **THEN** el indicador se reconstruye correctamente o desaparece.
* **AND** no quedan conexiones ni instancias del personaje anterior.

#### **Escenario 12: Móvil**

* **GIVEN** el jugador usa un dispositivo táctil.
* **WHEN** targetea con los controles móviles.
* **THEN** el contorno y la flecha se muestran igual que en PC.
* **AND** no rompen el joystick, la cámara ni la UI móvil.

#### **Escenario 13: Performance**

* **GIVEN** el jugador cambia de target repetidamente durante combate.
* **WHEN** se revisa el output.
* **THEN** no hay errores rojos ni spam de instancias.
* **AND** el Highlight solo se crea/destruye al cambiar de target (no por frame).

#### **Escenario 14: Seguridad**

* **GIVEN** un cliente manipulado intenta usar el indicador para dañar o seleccionar arbitrariamente.
* **WHEN** envía intenciones o modifica estado local.
* **THEN** el servidor sigue rechazando targets y daño inválidos.
* **AND** el indicador no otorga ninguna ventaja de combate.

---

### **Comportamiento Visual e Interfaz (UI/UX) / Reglas de Negocio**

* Rojo enemigo estándar (paleta Vandrheim) para contorno y flecha: claro, legible sobre hielo y sobre el pueblo.
* El contorno rodea al enemigo sin rellenarlo (o con relleno muy leve, según playtest).
* La flecha es discreta, flota sobre la cabeza y no tapa al personaje del jugador ni a la UI.
* `AlwaysOnTop` para la flecha; el contorno es nativo del modelo y puede quedar oculto detrás de paredes (comportamiento aceptado).
* El indicador es **local**: cada jugador ve solo el suyo. En el MVP no hay party, así que no se replica a otros jugadores.
* No se agrega configuración de usuario en UI; todos los valores viven en `TargetIndicatorConfig`.
* Si el asset de flecha no está aprobado, se usa placeholder y se reemplaza solo cambiando `arrowImageId` en config (nunca código).
* La UI existente (`TargetFrame`, HUD) no cambia.

---

### **Alcance**

#### Incluye

* `TargetIndicator` (LocalScript cliente) que escucha `TargetState.Changed`.
* `TargetIndicatorConfig` data-driven (colores, transparencias, tamaño, offset, distancia, `arrowImageId`).
* Highlight rojo sobre el enemigo targeteado (crear/destruir al cambiar de target).
* Flecha roja fija hacia abajo sobre la cabeza (BillboardGui + ImageLabel, `AlwaysOnTop`).
* Manejo de target muerto, modelo destruido, respawn de dummy y cambio de personaje.
* Limpieza de instancias y conexiones (sin huérfanos ni duplicados).
* Uso de asset de flecha de la Library con registro en `ASSETS_REGISTRY`, o placeholder geométrico configurable.
* Verificación PC y móvil.

#### No incluye

* Cambios en `TargetingSystem`, `TargetState`, `CombatService` ni en la validación de targets.
* Nuevos RemoteEvents o replica del target a otros jugadores.
* Party target, focus target, target-of-target ni indicadores para otros jugadores.
* Cambios al `TargetFrame` del HUD (nombre/HP).
* Fade de paredes, anillos de suelo, barras de vida en el mundo ni otros indicadores.
* Configuración de usuario en UI (tamaño/color desde menú).
* Daño, rango, auto-attack, skills o cualquier cambio server-side.

---

### **Definition of Done (DoD)**

* [ ] Al targetear con `TAB` o click, el enemigo muestra contorno rojo y flecha fija hacia abajo.
* [ ] Solo existe un indicador a la vez; al cambiar de target se elimina el anterior.
* [ ] Con varios enemigos iguales se distingue sin ambigüedad el targeteado.
* [ ] El indicador desaparece cuando el target muere o queda vacío.
* [ ] El dummy respawneado vuelve a mostrar indicador si sigue siendo target.
* [ ] Enemigos destruidos limpian el indicador sin errores.
* [ ] La flecha no rota y se mantiene `AlwaysOnTop`.
* [ ] Respawn y cambio de personaje no dejan indicadores huérfanos ni conexiones acumuladas.
* [ ] Móvil: el indicador funciona sin romper joystick/cámara/UI.
* [ ] Colores, tamaños, offset e ids viven en `TargetIndicatorConfig` (no hardcode).
* [ ] Asset de flecha registrado en `ASSETS_REGISTRY` o placeholder configurable.
* [ ] Sin errores rojos en combate con cambios de target repetidos.
* [ ] `CombatService` y la autoridad del daño no se modifican.
* [ ] Se actualizan `PROJECT_ARCHITECTURE` y el registro de la HU/RC al cerrar.
* [ ] Nota `R3.3 completo` en el GDD después de la verificación, no antes.

---

### **Decisiones por defecto R3.3**

| Tema | Default |
|------|---------|
| Indicador | Contorno (`Highlight`) + flecha fija hacia abajo |
| `OutlineColor` | `Color3.fromRGB(255, 60, 60)` (rojo enemigo) |
| `FillTransparency` | `1` (solo contorno; probar `0.9` si se ve mejor) |
| `OutlineWidth` | `0.08` |
| Flecha | `BillboardGui` + `ImageLabel`, `AlwaysOnTop = true`, apuntando hacia abajo, sin rotación |
| Tamaño flecha | `UDim2.fromOffset(64, 64)` |
| Offset flecha | `+3 studs` sobre el `HumanoidRootPart` |
| `MaxDistance` flecha | `0` (siempre visible mientras sea target; ajustar a `50` si molesta) |
| Asset flecha | Library gratuita registrada en `ASSETS_REGISTRY`; placeholder geométrico hasta entonces |
| Alcance visual | Local al jugador; sin replica a otros jugadores |
| Actualización | Señales (`GetAttributeChangedSignal("Dead")`, `AncestryChanged`) y refresco ligero tipo HUD; no por frame |

---

### **Estimación (orientativa)**

1–2 sesiones: componente de indicador, Highlight + flecha, ciclo de vida (muerte/respawn/limpieza), config y regresión PC/móvil.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-25 | Creación de HU-R3.3 por falta de identificación visual del enemigo targeteado; decisión cerrada: contorno + flecha fija hacia abajo |