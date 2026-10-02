## HU-R3.2: Corrección de targeting con TAB y colisión/distancia de cámara

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** Combate / Control / Cámara  
**Prioridad:** Crítica  
**Estado:** Completada (implementada; reporte equipo 2026-08-26)  
**Tipo:** Corrección de regresión y comportamiento incompleto  
**Fase GDD:** R3.2 (corrección posterior a R3.1; no amplía el alcance del MVP)  
**Depende de:** HU-R1 (targeting TAB/click), HU-R3.1 (cámara WoW-like), HU-R0 (cámara 3ª y movimiento)  
**Componentes observados:** `StarterPlayer.StarterPlayerScripts.TargetingSystem`, `StarterPlayer.StarterPlayerScripts.CameraController`, `ReplicatedStorage.Config.CameraConfig`  

---

### **Narrativa (INVEST)**

**Como** jugador,  
**quiero** que la tecla `TAB` seleccione y recorra enemigos válidos en lugar de abrir la lista de jugadores,  
**para** poder apuntar y cambiar de objetivo como en un MMORPG.

**Como** jugador,  
**quiero** alejar un poco más la cámara y que esta se detenga delante de paredes y objetos sólidos,  
**para** mantener una vista cómoda del personaje y no ver a través de la geometría del mundo.

---

### **Descripción del Requerimiento / Contexto**

El GDD define que `TAB` debe seleccionar el enemigo válido más cercano y que las pulsaciones sucesivas deben ciclar al siguiente objetivo. HU-R1 formaliza el mismo comportamiento y deja el click sobre enemigos como alternativa opcional.

En el Studio conectado se observan los siguientes desvíos:

1. La lista de jugadores de Roblox continúa habilitada y responde a `TAB`, por lo que el comportamiento nativo interfiere con `TargetingSystem`.
2. `TargetingSystem` ya contiene la lógica de búsqueda y el RemoteEvent `ReplicatedStorage.SetTarget`, pero la selección inicial tiene un desplazamiento: cuando no existe un target actual, el primer `TAB` puede saltar al segundo enemigo ordenado en vez del más cercano.
3. `CameraConfig.MaxDistance` está en `12` studs y no existe una comprobación de obstáculos entre el foco del personaje y la posición deseada de la cámara.
4. `CameraController` procesa actualmente el botón izquierdo como movimiento de cámara, aunque R3.1 define que el botón izquierdo debe quedar libre para click-target y que solo el botón derecho debe controlar la órbita.

Esta HU corrige esos desvíos sin rediseñar el combate. El servidor continúa siendo la autoridad para validar el target y el cliente solo envía la intención mediante el RemoteEvent existente.

**Criterio de hecho global:** `TAB` selecciona/cicla enemigos válidos sin abrir PlayerList y la cámara permite el nuevo alcance máximo sin atravesar objetos sólidos.

---

### **Especificaciones Técnicas / Contratos de API**

#### **Targeting y tecla TAB**

No se crea un RemoteEvent nuevo. Se conserva el contrato existente:

| Remote | Dirección | Payload | Validación server |
|--------|-----------|---------|-------------------|
| `SetTarget` | C→S | `target: Model?` o la forma equivalente ya implementada | Target válido del mundo, modelo con atributo/tag `Enemy`, no muerto y perteneciente al contexto actual |

Reglas de candidatos:

* Un candidato válido es un `Model` con atributo `Enemy=true`, que no tenga `Dead=true` y tenga una raíz utilizable para calcular distancia.
* La tecla `TAB` nunca selecciona avatares de jugadores. La presencia de jugadores en el hub, el chat y la interacción pública no se desactivan.
* Se consideran los enemigos válidos del lugar o run actual; no se deben mezclar targets de otra instancia o contexto que no sea accesible para el jugador.
* La lista se ordena por distancia al `HumanoidRootPart` del jugador. El orden debe ser estable cuando dos candidatos tengan la misma distancia.
* Si no hay target actual válido, la primera pulsación selecciona el elemento `1` de la lista ordenada, es decir, el enemigo válido más cercano.
* Si existe un target actual válido, cada pulsación selecciona el siguiente elemento de la lista y vuelve al primero al llegar al final.
* Si el target actual murió, desapareció o dejó de ser válido, la siguiente pulsación comienza desde el enemigo válido más cercano.
* Si no existen candidatos válidos, se limpia el target mediante el flujo existente y no se produce error.
* El `TargetFrame` existente debe reflejar el target confirmado por el flujo actual; no se crea una UI de lista de objetivos en esta HU.

#### **Desactivación de PlayerList**

* El cliente debe desactivar la interfaz nativa `PlayerList` mediante la API de `StarterGui` (`Enum.CoreGuiType.PlayerList`) al inicializar la experiencia o mediante el punto de inicialización equivalente ya usado por el proyecto.
* `TAB` debe quedar reservado para `TargetingSystem` cuando no haya una ventana o `TextBox` procesando el input.
* Al presionar `TAB` no debe aparecer, ocultarse ni alternarse la lista de jugadores.
* Desactivar la UI de PlayerList no elimina jugadores del servidor, no oculta sus avatares y no modifica chat, presencia ni multiplayer del hub.
* No se agrega una lista de jugadores alternativa en esta HU.

#### **Input y compatibilidad con click-target**

* El click izquierdo sobre un enemigo mantiene el comportamiento opcional de HU-R1 y envía el target por `SetTarget`.
* El botón izquierdo no debe iniciar rotación de cámara, cambiar `MouseBehavior` ni mover el cursor como efecto de cámara.
* El botón derecho conserva la órbita de cámara de R3.1 con `MouseBehavior = LockCenter`, `GetMouseDelta()` y crosshair cuando corresponda.
* Si un menú, ventana o `TextBox` tiene el input procesado, `TAB` y el click no deben ejecutar targeting accidentalmente.
* El modo AoE existente mantiene su bloqueo de cámara/input según el contrato actual; esta HU no modifica sus reglas de cast.

#### **CameraConfig**

La distancia debe seguir siendo data-driven y configurable en `ReplicatedStorage.Config.CameraConfig`:

```luau
{
    MinDistance = 3,
    MaxDistance = 16, -- default propuesto; confirmar en playtest
    DefaultDistance = 6,
    ObstaclePadding = 0.5, -- default propuesto, en studs
}
```

* `MaxDistance = 16` es una propuesta inicial para aumentar moderadamente el máximo actual de `12`; el valor final se puede ajustar en config sin modificar la lógica.
* `DefaultDistance` y `MinDistance` no cambian inicialmente.
* El zoom por rueda conserva el comportamiento actual y nunca supera `MaxDistance` ni baja de `MinDistance`.
* `ObstaclePadding` mantiene la cámara ligeramente separada de la superficie detectada para evitar clipping visible.

#### **Colisión de cámara con objetos sólidos**

* La posición deseada se calcula con el yaw, pitch y distancia actuales, tomando como foco `root.Position + Vector3.new(0, LookHeight, 0)`.
* Antes de aplicar el `CFrame` final, el controlador debe consultar el volumen entre el foco y la posición deseada mediante raycast, spherecast o equivalente de cámara.
* La consulta debe ignorar el propio personaje y los objetos visuales que no sean obstáculos, pero debe detectar la geometría sólida del mundo con capacidad de consulta.
* Si se detecta una pared u objeto sólido, la cámara se posiciona en el lado del jugador, antes del impacto, aplicando `ObstaclePadding`; nunca debe atravesar el obstáculo para alcanzar la distancia deseada.
* La distancia efectiva se recalcula mientras el jugador rota, hace zoom o se mueve cerca del obstáculo.
* Si no hay obstáculo, la cámara usa la distancia solicitada por el jugador hasta el máximo configurado.
* La corrección no debe cambiar el foco, el pitch clamp, la sensibilidad ni la orientación del personaje definidos por R3.1.
* No se implementa transparencia, fade ni ocultamiento de paredes; la solución MVP es acercar la cámara al obstáculo.

#### **Seguridad y autoridad**

* El cliente solo declara la intención de target mediante `SetTarget`; no puede convertir un jugador, un objeto arbitrario o un target muerto en un enemigo válido.
* El servidor mantiene sus validaciones existentes de `SetTarget`, daño y auto-attack.
* La distancia y colisión de cámara son comportamiento local y no requieren persistencia ni RemoteEvent.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: TAB no abre PlayerList**

* **GIVEN** el jugador está en el hub o en una dungeon con la interfaz normal activa.
* **WHEN** presiona `TAB`.
* **THEN** no aparece ni se alterna la lista nativa de jugadores.
* **AND** el input queda disponible para `TargetingSystem`.

#### **Escenario 2: Primer TAB selecciona el enemigo más cercano**

* **GIVEN** existen dos o más enemigos válidos a distintas distancias y no hay target actual.
* **WHEN** el jugador presiona `TAB` una vez.
* **THEN** se selecciona el enemigo válido más cercano.
* **AND** el target se envía mediante el `SetTarget` existente.
* **AND** el `TargetFrame` muestra ese enemigo.

#### **Escenario 3: TAB cicla entre enemigos**

* **GIVEN** existen varios enemigos válidos ordenados por distancia.
* **WHEN** el jugador presiona `TAB` varias veces.
* **THEN** cada pulsación selecciona el siguiente enemigo válido.
* **AND** después del último target el ciclo vuelve al primero.
* **AND** no se abre PlayerList durante el ciclo.

#### **Escenario 4: Target inválido**

* **GIVEN** el target actual murió, desapareció o dejó de tener el estado válido.
* **WHEN** el jugador presiona `TAB`.
* **THEN** se selecciona el enemigo válido más cercano disponible.
* **AND** no se envía un target muerto o inexistente.

#### **Escenario 5: Sin enemigos válidos**

* **GIVEN** no hay modelos válidos con `Enemy=true` en el contexto actual.
* **WHEN** el jugador presiona `TAB`.
* **THEN** el target queda vacío o se limpia mediante el flujo existente.
* **AND** no aparece un error rojo ni se selecciona un jugador.

#### **Escenario 6: Los jugadores no son targets**

* **GIVEN** hay otros jugadores visibles en el servidor público del hub.
* **WHEN** el jugador usa `TAB` repetidamente.
* **THEN** solo se seleccionan modelos enemigos válidos.
* **AND** los avatares, el chat y la presencia de los demás jugadores continúan funcionando.

#### **Escenario 7: Click izquierdo conserva el targeting**

* **GIVEN** el jugador apunta a un enemigo válido con el cursor visible.
* **WHEN** hace click izquierdo sobre el enemigo.
* **THEN** el enemigo queda seleccionado mediante el flujo de HU-R1.
* **AND** el click izquierdo no rota la cámara ni cambia `MouseBehavior`.

#### **Escenario 8: Botón derecho conserva la órbita**

* **GIVEN** el jugador está en control normal de cámara en PC.
* **WHEN** mantiene el botón derecho y mueve el mouse.
* **THEN** la cámara rota usando el comportamiento de R3.1.
* **AND** el cursor/crosshair se comporta según R3.1.
* **AND** al soltar el botón derecho se restaura el estado normal del cursor.

#### **Escenario 9: Distancia máxima ampliada**

* **GIVEN** el jugador usa el zoom hasta alejar la cámara.
* **WHEN** alcanza el límite configurado.
* **THEN** la distancia efectiva puede llegar al default propuesto de `16` studs.
* **AND** no supera `CameraConfig.MaxDistance`.
* **AND** el valor puede ajustarse desde `CameraConfig` sin cambiar el controlador.

#### **Escenario 10: Pared entre el personaje y la cámara**

* **GIVEN** existe una pared u objeto sólido entre el foco del personaje y la posición deseada de la cámara.
* **WHEN** la cámara se actualiza.
* **THEN** la cámara se acerca al jugador y queda del lado correcto del obstáculo.
* **AND** no atraviesa la pared ni muestra una vista obtenida desde el interior del objeto.

#### **Escenario 11: Movimiento junto a obstáculos**

* **GIVEN** el jugador camina, corre, rota o hace zoom cerca de una pared.
* **WHEN** cambia la posición deseada de la cámara.
* **THEN** la colisión se recalcula sin permitir que la cámara atraviese objetos sólidos.
* **AND** al despejarse el camino la cámara recupera la distancia solicitada sin superar el máximo.

#### **Escenario 12: Espacio sin obstáculos**

* **GIVEN** no existe geometría sólida entre el foco y la posición deseada.
* **WHEN** el jugador aleja la cámara.
* **THEN** la cámara mantiene la distancia solicitada dentro de los límites configurados.
* **AND** no se acerca de forma injustificada ni cambia el foco del personaje.

#### **Escenario 13: Compatibilidad móvil**

* **GIVEN** el jugador usa un dispositivo táctil.
* **WHEN** arrastra la cámara y se mueve por el mundo.
* **THEN** el drag táctil existente continúa funcionando.
* **AND** la distancia máxima y la prevención de clipping no rompen el joystick ni la UI móvil.

#### **Escenario 14: Compatibilidad con combate**

* **GIVEN** el jugador tiene un enemigo seleccionado.
* **WHEN** cambia de target con `TAB`, hace click, orbita o se acerca a una pared.
* **THEN** el target confirmado, el auto-attack y las skills existentes continúan funcionando.
* **AND** no se modifica el daño, el rango, el cooldown ni la autoridad del servidor.

#### **Escenario 15: Seguridad y estabilidad**

* **GIVEN** un cliente intenta seleccionar un jugador, un modelo sin `Enemy`, un enemigo muerto o enviar estados de cámara al servidor.
* **WHEN** se procesa la interacción.
* **THEN** el servidor rechaza targets inválidos y no se aceptan datos de cámara desde el cliente.
* **AND** el flujo de targeting, cámara, respawn y cambio de personaje no produce errores rojos.

---

### **Comportamiento Visual e Interfaz (UI/UX) / Reglas de Negocio**

* `TAB` es una acción de combate/targeting, no un control de presencia de jugadores.
* PlayerList queda oculto, pero el hub continúa siendo público: los jugadores siguen viéndose e interactuando.
* El `TargetFrame` existente muestra el enemigo seleccionado; no se agrega una lista de objetivos ni una nueva ventana.
* El primer target por `TAB` debe ser inequívocamente el enemigo más cercano; el ciclo debe ser predecible.
* La cámara puede alejarse hasta el límite configurado sin perder legibilidad del personaje.
* Al acercarse a una pared, la cámara se aproxima al jugador en lugar de atravesar o mirar desde el interior del objeto.
* No se agrega fade de paredes, transparencia dinámica ni una opción de configuración de cámara en UI.
* El botón izquierdo queda libre para targeting y el botón derecho conserva el control de órbita de R3.1.
* La UI existente mantiene las reglas de PC/móvil; cualquier control visual futuro debe usar `Scale` y `UIAspectRatioConstraint`.

---

### **Alcance**

#### Incluye

* Desactivar la interfaz nativa `PlayerList` para que no responda a `TAB`.
* Corregir la selección inicial y el ciclo de enemigos válidos en `TargetingSystem`.
* Mantener `SetTarget` y las validaciones server-side existentes.
* Mantener click izquierdo como targeting opcional sin rotación de cámara.
* Mantener botón derecho, crosshair, `GetMouseDelta()`, pitch clamp y `MouseBehavior` de R3.1.
* Aumentar el `MaxDistance` configurable; default inicial propuesto de `16` studs.
* Añadir prevención de clipping mediante consulta de obstáculos sólidos.
* Añadir `ObstaclePadding` configurable; default inicial propuesto de `0.5` studs.
* Aplicar la corrección en hub y dungeon sin separar el contrato por Place.
* Regresión de targeting, auto-attack, skills, respawn, cambio de personaje y teleport.
* Verificación básica en PC y móvil.

#### No incluye

* Targeting PvP o selección de avatares de jugadores.
* Party target, focus target, target-of-target, asistencia ni matchmaking.
* Nuevo sistema de marcadores, lista de enemigos o ventana de objetivos.
* Nuevos RemoteEvents, cambios de daño, rango, auto-attack, skills o combate server-side.
* Cambio de reglas de `SetTarget` más allá de conservar sus validaciones existentes.
* Menú de configuración de sensibilidad, distancia o cámara.
* Fade/transparencia de paredes, cámara inteligente, first-person o nuevo sistema de cámara.
* Cambio de `DefaultDistance` salvo decisión posterior explícita.
* Reemplazo del drag táctil por otro esquema de cámara.
* Cambios a chat, presencia o visibilidad de jugadores del hub.

---

### **Definition of Done (DoD)**

* [ ] `PlayerList` no aparece ni se alterna al presionar `TAB`.
* [ ] El primer `TAB` selecciona el enemigo válido más cercano.
* [ ] Pulsaciones sucesivas ciclan de forma estable y vuelven al primer enemigo.
* [ ] Targets muertos, desaparecidos o inválidos no se seleccionan.
* [ ] Sin enemigos válidos, el target se limpia sin errores.
* [ ] Los jugadores del hub no son seleccionables mediante `TAB`.
* [ ] Click izquierdo sobre enemigo continúa seleccionando target.
* [ ] Click izquierdo no rota la cámara ni modifica `MouseBehavior`.
* [ ] Botón derecho conserva la órbita y el crosshair de R3.1.
* [ ] `CameraConfig.MaxDistance` se puede ajustar sin modificar lógica; el valor inicial propuesto es `16`.
* [ ] La cámara no atraviesa paredes u objetos sólidos entre el personaje y la posición deseada.
* [ ] `ObstaclePadding` evita clipping visible y permanece configurable.
* [ ] En espacios abiertos la cámara alcanza la distancia solicitada sin acercamiento injustificado.
* [ ] El pitch clamp, el zoom, el modo AoE y el foco del personaje siguen funcionando.
* [ ] El drag de cámara móvil y el joystick no se rompen.
* [ ] Targeting, auto-attack, skills, respawn y teleport no presentan regresiones.
* [ ] El servidor sigue rechazando targets inválidos y el cliente no controla daño ni estado de cámara server-side.
* [ ] No hay errores rojos en Output durante pruebas de targeting y cámara.
* [ ] Se actualizan `PROJECT_ARCHITECTURE` y el registro de la HU/RC al cerrar la implementación.
* [ ] Se agrega la nota `R3.2 completo` en el GDD después de la verificación, no antes.

---

### **Decisiones por defecto R3.2**

| Tema | Default |
|------|---------|
| Acción de `TAB` | Enemigo válido más cercano; pulsaciones siguientes ciclan |
| PlayerList | Desactivado; no se agrega reemplazo |
| Target válido | Modelo con `Enemy=true`, no muerto y accesible en el contexto actual |
| Click izquierdo | Targeting opcional; no rota cámara |
| Botón derecho | Órbita de cámara según R3.1 |
| `MinDistance` | `3` studs, sin cambio |
| `DefaultDistance` | `6` studs, sin cambio inicial |
| `MaxDistance` | `16` studs, propuesta inicial ajustable en config |
| `ObstaclePadding` | `0.5` studs, propuesta inicial ajustable en config |
| Colisión | Cámara se acerca al jugador; no atraviesa sólidos y no hace fade de paredes |
| Móvil | Drag táctil existente sin reemplazo |

### **Pendientes de confirmación**

* Confirmar si el objetivo de “queda cerca” se refiere únicamente al límite máximo (`MaxDistance`) o si también debe aumentarse `DefaultDistance`. El default de esta HU mantiene `DefaultDistance = 6` para reducir el alcance del cambio.

---

### **Estimación (orientativa)**

2–3 sesiones: desactivación de PlayerList y corrección del ciclo de targeting, separación definitiva de click izquierdo/botón derecho, colisión de cámara, ajuste de config y regresión PC/móvil.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-25 | Creación de HU-R3.2 por desvío de TAB/PlayerList, selección inicial de target, distancia máxima y clipping de cámara |
| 2026-08-26 | Marcada completada según reporte del equipo |
