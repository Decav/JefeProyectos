## HU-R6.1: Alternancia correr/caminar y pisadas por material

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** Movimiento / Audio / Polish  
**Prioridad:** Alta  
**Estado:** Completada (implementada; reporte equipo 2026-08-23)  
**Fase GDD:** R6.1 (pulido posterior a R6 y previo a R7)  
**Depende de:** HU-R0 (movimiento y cámara), HU-R3.1 (cámara), HU-ASSETS (animaciones/sonidos), `FootstepSystem` existente  
**Script existente:** `StarterPlayer.StarterPlayerScripts.FootstepSystem`

---

### **Narrativa (INVEST)**

**Como** jugador,  
**quiero** que mi personaje corra por defecto, pueda alternar entre correr y caminar con la tecla `U` o un botón móvil, y escuche pisadas acordes a la animación y al material del suelo,  
**para** que el movimiento se sienta más natural y pulido como un MMORPG.

---

### **Descripción del Requerimiento / Contexto**

El movimiento actual permite desplazarse, pero no ofrece una elección explícita entre caminar y correr. Además, `FootstepSystem` ya contiene sonidos por material y ajustes de volumen/pitch, pero actualmente reproduce un sonido en loop continuo mientras el jugador se mueve. Ese enfoque no sincroniza cada sonido con el apoyo real de los pies.

Esta HU agrega dos modos de movimiento y adapta el sistema de audio existente para reproducir **una pisada por evento de apoyo**, usando la animación activa y el material detectado bajo el personaje.

La funcionalidad es de movimiento y feedback audiovisual. No agrega stamina, bonus de combate, monturas ni una mecánica de velocidad adicional.

---

### **Especificaciones Técnicas / Contratos de API**

#### **MovementConfig (data-driven)**

```luau
{
  defaultMode = "Run",
  toggleKey = "U",
  runSpeed = 20,
  walkSpeed = 10,
  runAnimationId = "rbxassetid://...",
  walkAnimationId = "rbxassetid://...",
}
```

* El modo inicial es `Run` en cada spawn/respawn.
* Defaults iniciales de velocidad: correr `20`, caminar `10` studs/s.
* Las velocidades son configurables; no se hardcodean en la UI ni en el sistema de audio.
* Los IDs de animación viven en config. Usar animaciones R15 existentes/default o seleccionadas de Roblox Library según `ASSETS_POLICY`; no crear ni riggear animaciones propias.
* El cambio de modo no se persiste en DataStore en esta HU: cada nuevo spawn empieza corriendo.

#### **Cambio de modo**

* PC: tecla `U`, toggle y no hold.
* Móvil: botón visible de movimiento con estado actual `Correr`/`Caminar`.
* El cambio actualiza velocidad y animación con crossfade corto, sin reiniciar innecesariamente el desplazamiento.
* El indicador de modo refleja el estado confirmado por el servidor.
* El modo se puede cambiar quieto o en movimiento.

#### **Servidor y seguridad**

* El cliente solicita el modo; el servidor valida que sea `Run` o `Walk` y aplica la velocidad configurada al `Humanoid`.
* El servidor aplica `Run` como modo inicial al crear el personaje.
* El cliente no puede elegir una velocidad arbitraria ni convertir el toggle en un tercer modo.
* La animación y el audio son feedback local; no se envía un RemoteEvent por cada pisada.

Remote nuevo o equivalente según la arquitectura existente:

| Remote | Dir | Payload | Validación server |
|--------|-----|---------|-------------------|
| `RequestMovementMode` | C→S | `{ mode = "Run" | "Walk" }` | Modo permitido; personaje/humanoid válido |
| `MovementModeChanged` | S→C | `{ mode, speed }` | Estado actual del jugador |

Si ya existe un contrato de movimiento equivalente, reutilizarlo y no duplicar remotes.

#### **Animaciones**

* Deben existir una animación de `Run` y una de `Walk` compatibles con R15.
* La animación activa debe cambiar junto con la velocidad.
* Prioridad de sincronización de pisadas:
  1. `AnimationTrack` con marker `Footstep` en cada apoyo.
  2. Keyframes/eventos de apoyo equivalentes si la animación existente los trae.
  3. Fallback configurable por ciclo de animación y modo, nunca un loop de sonido por `Heartbeat`.
* La transición de animación no debe duplicar eventos de pisada.
* Si se selecciona una animación nueva de Library, registrar `animationId`, autor, licencia y prueba según `ASSETS_POLICY`.

#### **Adaptación de `FootstepSystem`**

El script existente contiene:

* `FootstepSounds` dentro de `FootstepSystem`.
* Sonidos para `Ice`, `Sand`, `Grass`, `Concrete` y otros materiales Roblox.
* Detección actual mediante `Humanoid.FloorMaterial`.
* Volumen separado para caminar/correr y pitch proporcional a velocidad.

La adaptación debe:

* Conservar los SoundIds, materiales y ajustes útiles existentes.
* Eliminar la reproducción continua `Looped=true` como mecanismo de pisadas.
* Reproducir el sonido seleccionado una vez por marker/apoyo (`Play`), con `Looped=false`.
* Reiniciar o seleccionar una variación sin superponer sonidos excesivos.
* Asociar la emisión al personaje/jugador local para que el audio tenga ubicación coherente; no convertir cada paso en tráfico de red.
* Mantener `Concrete` como fallback cuando el material no tenga sonido.
* No reproducir pisadas con `FloorMaterial = Air` ni durante estados aéreos.
* Evitar duplicación con los sonidos de personaje default de Roblox; si se desactivan, hacerlo solo cuando el reemplazo esté funcionando.

#### **Materiales y ajustes**

* Mapeo base: `Ice` → sonido de hielo, `Sand` → arena, `Grass` → pasto.
* Mantener soporte para los demás nombres existentes del contenedor (`Concrete`, `Brick`, `Cobblestone`, `Snow`, etc.) cuando estén disponibles.
* Permitir aliases de material en config si un `Enum.Material` no coincide directamente con el nombre del sonido.
* El volumen y pitch pueden diferenciar `Run`/`Walk`, pero deben partir de la configuración existente y ajustarse mediante pruebas.
* El pitch debe seguir la velocidad efectiva sin salir de los límites configurados.
* El intervalo de fallback debe depender del ciclo/velocidad del modo, no de un valor fijo que produzca pasos acelerados o lentos.

#### **Estados sin pisadas**

No reproducir sonidos cuando el personaje está:

* Quieto.
* Saltando, en caída libre o sin contacto con el suelo.
* Trepando, nadando o sentado.
* Moviéndose sin desplazamiento real debido a una obstrucción.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Correr por defecto**

* **GIVEN** un jugador crea o respawnea su personaje
* **WHEN** comienza a moverse
* **THEN** usa el modo `Run`
* **AND** se aplica `runSpeed`
* **AND** se reproduce la animación de correr

#### **Escenario 2: Toggle con tecla U**

* **GIVEN** el personaje está en modo `Run`
* **WHEN** el jugador pulsa `U`
* **THEN** cambia a modo `Walk`
* **AND** se aplica `walkSpeed`
* **AND** cambia a la animación de caminar
* **AND** una segunda pulsación vuelve a `Run`

#### **Escenario 3: Toggle móvil**

* **GIVEN** el jugador usa un dispositivo táctil
* **WHEN** pulsa el botón de movimiento
* **THEN** alterna entre `Correr` y `Caminar`
* **AND** el botón muestra el modo actual
* **AND** la UI escala correctamente sin romper el movimiento existente

#### **Escenario 4: Velocidad no manipulable**

* **GIVEN** el cliente envía una velocidad arbitraria o un modo inválido
* **WHEN** el servidor procesa la solicitud
* **THEN** rechaza el valor
* **AND** mantiene solo `runSpeed` o `walkSpeed`

#### **Escenario 5: Pisadas sincronizadas**

* **GIVEN** el personaje se mueve en el suelo
* **WHEN** la animación alcanza un marker/evento `Footstep`
* **THEN** reproduce una sola pisada
* **AND** el sonido coincide temporalmente con el apoyo del pie
* **AND** no existe un sonido continuo independiente de la animación

#### **Escenario 6: Pisadas correr/caminar**

* **GIVEN** el jugador cambia de correr a caminar mientras se desplaza
* **WHEN** la animación y la velocidad cambian
* **THEN** los eventos de pisada siguen la nueva animación
* **AND** el volumen/pitch se ajusta al modo y velocidad
* **AND** no se duplican sonidos durante el crossfade

#### **Escenario 7: Material hielo, arena y pasto**

* **GIVEN** el personaje camina sobre Ice, Sand o Grass
* **WHEN** ocurre una pisada
* **THEN** se reproduce el sonido correspondiente al material
* **AND** se conservan los SoundIds existentes de `FootstepSystem`

#### **Escenario 8: Fallback de material**

* **GIVEN** el personaje pisa un material sin sonido configurado
* **WHEN** ocurre una pisada
* **THEN** usa `Concrete` como fallback
* **AND** el sistema no produce un error

#### **Escenario 9: Estados aéreos o quietos**

* **GIVEN** el personaje está quieto, saltando, cayendo o sobre `Air`
* **WHEN** se actualiza el movimiento
* **THEN** no reproduce sonidos de pisadas
* **AND** al volver al suelo retoma la sincronización normal

#### **Escenario 10: Persistencia de assets y respawn**

* **GIVEN** el personaje cambia de modo y luego respawnea
* **WHEN** aparece el nuevo personaje
* **THEN** vuelve a `Run`
* **AND** `FootstepSystem` se conecta una sola vez al nuevo Humanoid
* **AND** no quedan conexiones ni sonidos del personaje anterior

#### **Escenario 11: Compatibilidad con gameplay**

* **GIVEN** el jugador alterna movimiento durante combate o en dungeon
* **WHEN** cambia entre caminar y correr
* **THEN** no se rompe la cámara, targeting, auto-attack, skills, respawn ni teleport
* **AND** el cambio no otorga ni quita daño, defensa o stamina

#### **Escenario 12: Sin errores y sin spam**

* **GIVEN** el jugador corre y camina por varios materiales durante varios minutos
* **WHEN** cambia repetidamente de modo y respawnea
* **THEN** no hay sonidos atascados, duplicados ni spam audible
* **AND** no aparecen errores rojos en Output

---

### **Comportamiento Visual e Interfaz (UI/UX) / Reglas de Negocio**

* PC: `U` alterna el modo; el indicador muestra `Correr` o `Caminar`.
* Móvil: botón visible y escalable; no reemplaza ni bloquea el joystick.
* La transición debe ser clara, sin modal ni ventana que interrumpa la cámara.
* Correr es el estado inicial; caminar es una preferencia temporal de la sesión/personaje.
* Las pisadas son feedback audiovisual, no afectan estadísticas, combate ni progresión.
* No agregar stamina, sprint, monturas ni penalización por caminar.
* Mantener la paleta/estilo UI existente y las restricciones de escala para móvil.

---

### **Alcance**

#### Incluye

* Modo `Run` por defecto.
* Modo `Walk` alternable con `U` y botón móvil.
* Velocidades configurables de correr/caminar.
* Animaciones R15 de correr/caminar y transición entre ellas.
* Adaptación de `FootstepSystem` existente.
* Pisadas sincronizadas por marker/keyframe/fallback calibrado.
* Detección de Ice, Sand, Grass y materiales existentes con fallback Concrete.
* Volumen/pitch ajustados a modo y velocidad.
* Limpieza de conexiones y sonidos al cambiar de personaje.
* Validación server del modo y de la velocidad.

#### No incluye

* Stamina o sprint temporal.
* Bonus de movimiento, combate o stats.
* Monturas, buffs de velocidad o diferentes velocidades por clase.
* Creación/rigging de animaciones propias.
* Nuevos paquetes de sonidos; se reutilizan los assets existentes salvo que el PM autorice reemplazos.
* Audio de pisadas replicado para todos los jugadores mediante un evento por paso.
* Cambios en cámara, targeting, auto-attack, skills, dungeon o teleport.

---

### **Definition of Done (DoD)**

* [ ] El personaje corre por defecto al spawn/respawn.
* [ ] `U` alterna correctamente entre correr y caminar.
* [ ] Existe botón móvil con indicador de estado.
* [ ] Velocidades y animaciones viven en configuración.
* [ ] Servidor valida los dos modos y aplica la velocidad correcta.
* [ ] `FootstepSystem` ya no reproduce un loop continuo por `Heartbeat`.
* [ ] Cada apoyo de la animación produce como máximo una pisada.
* [ ] Ice, Sand, Grass y fallback Concrete reproducen el sonido correcto.
* [ ] No hay pisadas en idle, salto, caída, natación, escalada, asiento o Air.
* [ ] Pitch/volumen e intervalo de fallback calzan con las dos animaciones.
* [ ] Respawn limpia conexiones y no duplica sonidos.
* [ ] Cámara, combate, dungeon y teleport siguen funcionando.
* [ ] Sin errores rojos ni spam de audio en una prueba prolongada.
* [ ] Animaciones/sonidos reales quedan registrados según `ASSETS_POLICY`.
* [ ] Nota “R6.1 completo” en GDD al verificar la implementación.

---

### **Estimación (orientativa)**

2–3 sesiones: toggle y velocidades, integración de animaciones, sincronización por markers/fallback, materiales y pruebas de regresión.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-23 | Creación de HU-R6.1: correr por defecto, toggle caminar con U/botón móvil y pisadas sincronizadas por material |
| 2026-08-23 | Marcada completada según reporte del equipo |
