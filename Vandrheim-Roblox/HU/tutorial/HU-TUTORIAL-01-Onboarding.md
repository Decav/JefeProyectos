# HU-TUTORIAL-01: Onboarding para nuevos jugadores — pasos guiados + ayuda permanente

**Proyecto:** Vandrheim (Roblox MVP)<br>
**Épica:** Tutorial / Onboarding (dev)<br>
**Prioridad:** Alta<br>
**Estado:** Implementada (reporte PO 2026-10-27; QA/verificación pendiente)<br>
**Tipo:** Sistema nuevo (dev)<br>
**Fase GDD:** Tutorial 1 (decisión PO 2026-09-22)<br>
**Depende de:** perfil de R2 (`activeChar`), menú in-game `MenuUI` (HU-R6.10), HUD R6.5/R8c/EST-20/EST-47, controles R1/R3.1/R3.2/R6.1/R6.15/R6.23/R6.29/R6.30, skills R3/R5.1, consumibles R6.2/ITEMS-02, dungeon R6a/R6b/R6.28/R7, party y matchmaking R9a/R9a.2, equipo R4/R6.5/R6.32, vendors R5, economía ECON-01/02, accesos micromenú R6.35, tokens visuales EST-13<br>
**Componentes observados:** `MenuUI`, PlayerFrame, TargetFrame, skillbar, barra de consumibles, micromenú (Dungeon/Party), matchmaking, mochila, equipo, NPCs del Hub y controles PC/táctiles

---

### **Narrativa (INVEST)**

**Como** jugador nuevo,<br>
**quiero** aprender los controles y el ciclo de juego sin interrumpir la partida, y poder consultar la ayuda cuando quiera,<br>
**para** entender el combate, la dungeon, el party, el equipo y la economía sin depender de que alguien me lo explique.

---

### **Descripción del Requerimiento / Contexto**

El juego ya contiene sistemas de combate, matchmaking, consumibles, dungeon, equipo y economía, pero un jugador nuevo no necesariamente conoce sus controles ni reglas. Esta HU agrega un onboarding breve, de primera vez por personaje, y define el contenido/comportamiento del panel general usando la opción **Ayuda** ya implementada en `MenuUI` (R6.10).

La ayuda general se abre desde la opción **Ayuda** del menú normal (`MenuUI`); en PC, `?` abre el mismo panel como atajo.

**Criterio de hecho global:** al cargar un personaje sin tutorial completado, el jugador recibe hasta 8 tarjetas cortas con controles adaptados a su plataforma; puede avanzar, volver, omitir o seguir jugando. La ayuda completa se reabre desde **Ayuda** en `MenuUI` (PC/móvil) y con `?` en PC.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Estado y ciclo del onboarding**

* Guardar `tutorialDone` como booleano en el registro del personaje activo (`activeChar.tutorialDone`); no es un flag por cuenta ni por sesión.
* Si un perfil existente no tiene el campo, tratarlo como `false`. Los personajes nuevos se crean con `tutorialDone = false`.
* Mostrar la tarjeta 1 una sola vez cuando el perfil y personaje activo ya estén cargados y el jugador tenga su primer spawn jugable (normalmente en el Hub). No mostrarlo en cada respawn ni al teleport entre Hub y Dungeon.
* **Terminar**, **Omitir** y cerrar la tarjeta por su botón de cierre equivalen a completar el onboarding: el servidor establece `tutorialDone = true` y lo persiste usando el flujo de perfil existente.
* Si el jugador se desconecta o cambia de personaje sin completar/omitir, conservar `tutorialDone = false`; la próxima vez se inicia desde la primera tarjeta. No se guarda el índice parcial.
* La ayuda permanente se puede abrir aunque `tutorialDone = true`; abrirla o cerrarla nunca modifica el flag.

**Contrato de servidor propuesto:**

| Remote/estado | Dirección | Payload | Regla |
|---|---|---|---|
| `RequestTutorialDone` | C→S | Ninguno | Usa el personaje activo del servidor; si el perfil está cargado, marca y persiste `tutorialDone = true`. Repetir la solicitud es idempotente. |
| `TutorialDone` (atributo o actualización equivalente) | S→C | Booleano | Refleja el valor persistido del personaje activo; el cliente no puede forzar el estado. |

* No confiar en un `characterId` enviado por el cliente ni en cambios locales del flag.
* Mientras no llegue el estado del perfil, `TutorialDone` es desconocido y la UI espera; solo `false` confirmado después de cargar el personaje activa el onboarding.
* Al terminar/omitir, la interfaz puede cerrarse sin esperar al guardado; el cliente no modifica `TutorialDone`. Si el servidor no confirma la persistencia, notificar sin bloquear el juego; el onboarding volverá a mostrarse al personaje mientras el valor persistido siga en `false`.

#### **2. Tarjetas del onboarding**

* Máximo **8 tarjetas**. Cada una muestra título, texto de 1–2 frases, progreso (`n/8`) y acciones **Anterior**, **Siguiente**, **Omitir**; la última usa **Terminar**.
* Usar el texto de `TutorialContent` de abajo. La versión PC y móvil de cada tarjeta debe ser breve y específica a su esquema de entrada.
* El botón de cerrar está disponible y tiene el mismo efecto que **Omitir**; `Escape` conserva el comportamiento global del juego y no debe marcar el tutorial como completado.
* El juego sigue corriendo durante las tarjetas: no congelar al personaje, no pausar la cámara ni capturar teclas táctiles fuera de los controles de la tarjeta.
* Los highlights son visuales, transitorios y no capturan input. Solo pueden apuntar a elementos reales presentes en el HUD: PlayerFrame, TargetFrame, skillbar, consumibles, PartyFrame o acceso de Dungeon. Si el elemento no está disponible (por ejemplo, PartyFrame sin party), mostrar la tarjeta sin highlight.
* **No existe un minimapa en el HUD actual:** no incluirlo en texto, referencias visuales ni highlights.

#### **3. Contenido canónico de las 8 tarjetas**

| # | Título | PC | Móvil | Highlight sugerido |
|---|---|---|---|---|
| 1 | Movimiento y cámara | «Muévete con WASD. Mantén el botón derecho y mueve el ratón para girar la cámara; usa la rueda para acercar/alejar y `U` para alternar correr/caminar.» | «Usa el joystick para moverte, arrastra fuera del joystick para girar la cámara y haz pinza para cambiar el zoom. El botón Correr alterna correr/caminar.» | Ninguno si no hay control visible; en móvil, el botón Correr solo si está visible. |
| 2 | Objetivo y ataque básico | «Selecciona un enemigo con click izquierdo o pulsa `TAB` para elegir/ciclar objetivos. Con un enemigo válido seleccionado y dentro de rango, los ataques básicos se ejecutan automáticamente.» | «Pulsa Target para elegir/ciclar enemigos. Con un enemigo válido seleccionado y dentro de rango, los ataques básicos se ejecutan automáticamente.» | TargetFrame; si aún no hay target, no forzar una selección. |
| 3 | Habilidades | «Las cuatro skills asignadas a la barra se lanzan con `1–4`; revisa su coste de maná y cooldown.» | «Las cuatro skills asignadas a la barra se lanzan tocando su botón; revisa el coste de maná y cooldown.» | Barra de skills. |
| 4 | Pociones y buffs | «Usa `Z`/`X` para los dos objetos asignados. Las pociones chica/grande restauran 25%/50% del máximo de HP o MP; los buffs dan +10% a ATK, DEF o MaxHP durante 60 s.» | «Usa los dos botones de consumibles. Las pociones chica/grande restauran 25%/50% del máximo de HP o MP; los buffs dan +10% a ATK, DEF o MaxHP durante 60 s.» | Barra de consumibles. |
| 5 | La dungeon y la muerte | «Desde el portal o con `J`/micromenú, elige Solo o Grupo. Cada run da 3 resurrecciones gratuitas en la entrada del piso, sin perder lo ganado; al morir puedes reaparecer si quedan o abandonar conservando lo obtenido.» | «Abre Dungeon desde el micromenú y elige Solo o Grupo. Cada run da 3 resurrecciones gratuitas en la entrada del piso, sin perder lo ganado; al morir puedes reaparecer si quedan o abandonar conservando lo obtenido.» | Acceso Dungeon; no resaltar una sala/piso que el jugador aún no haya abierto. |
| 6 | Party y matchmaking | «Abre Party con `O` o desde el micromenú; las invitaciones vencen en 60 s. Los roles Tank/Heal/DPS se asignan según clase y spec; el objetivo 1/1/2 es informativo y la run de grupo empieza automáticamente cuando todos están Listos.» | «Abre Party desde el micromenú; las invitaciones vencen en 60 s. Los roles Tank/Heal/DPS se asignan según clase y spec; el objetivo 1/1/2 es informativo y la run de grupo empieza automáticamente cuando todos están Listos.» | PartyFrame solo cuando el jugador está en un party; de otro modo, acceso Party/matchmaking. |
| 7 | Equipo y progreso | «Abre Mochila con `B` y Equipo con `C`; en móvil usa los botones BOLSA/EQUIPO. Las rarezas son blanco, verde, azul, morado y único; revisa requisitos y bonos de set, y equipa con click derecho o arrastrando al slot.» | «Abre Mochila y Equipo con BOLSA/EQUIPO. Las rarezas son blanco, verde, azul, morado y único; revisa requisitos y bonos de set, y equipa arrastrando el ítem al slot (mantén pulsado para iniciar el drag).» | Mochila o Equipo, según la plataforma. |
| 8 | Hub, economía y ayuda | «En el Hub puedes comprar/vender con NPCs, cambiar talentos con el Instructor y comerciar; la subasta conecta servidores. Abre Ayuda desde el menú normal cuando quieras; `?` es el atajo directo en PC.» | «En el Hub puedes comprar/vender con NPCs, cambiar talentos con el Instructor y comerciar; la subasta conecta servidores. Abre el menú del juego y elige Ayuda.» | Opción Ayuda de `MenuUI`; en PC también se puede explicar el atajo `?`. |

* Las tarjetas no deben afirmar que click izquierdo es un ataque básico, que morir reinicia el piso, que la composición del party es obligatoria ni que `C` equipa un ítem.

#### **4. Panel de ayuda permanente**

* Apertura principal: opción **Ayuda** dentro del menú normal `MenuUI` (R6.10), disponible en Hub y Dungeon. En PC, el atajo `?` abre el mismo panel; no agregar un botón flotante independiente al HUD móvil ni una entrada de Ayuda al micromenú.
* Reutilizar la opción Ayuda ya implementada en `MenuUI` (confirmación del PO); esta HU conecta el panel/contenido y no crea una segunda opción en el menú.
* Ubicar **Ayuda** al final de la lista de `MenuUI`, inmediatamente debajo de **Configurar interfaz** (Orden de UI en R6.10).
* `MenuUI` se abre con `Escape` en PC o con su botón existente del HUD móvil; la opción **Ayuda** reutiliza el flujo de ventanas del menú y el cierre regresa a la navegación previa definida por `MenuUI`.
* Cierre con el botón reusable existente; no cambiar el comportamiento global de `Escape` de `MenuUI`.
* El atajo `?` no se activa mientras un `TextBox` tiene el foco; contemplar `Shift + /` en distribuciones de teclado que lo usen para escribir `?`.
* Usar un acordeón/scroll responsive; cada sección contiene **2–5 frases**. El contenido canónico es editable desde el mismo ModuleScript que las tarjetas.

**Contenido canónico para `TutorialContent.helpSections`:**

| Sección | Texto de ayuda |
|---|---|
| Controles PC | «Muévete con `WASD`. Mantén el botón derecho y mueve el ratón para girar la cámara; usa la rueda para acercar o alejar. `U` alterna correr/caminar, `TAB` elige/cicla enemigos, `1–4` lanzan las skills asignadas, `Z`/`X` usan consumibles, `B` abre Mochila, `C` abre Equipo, `J` Dungeon y `O` Party. `ESC` abre `MenuUI` y su opción Ayuda; `?` abre Ayuda directamente.» |
| Controles móvil | «El joystick mueve al personaje; arrastrar fuera del joystick gira la cámara y la pinza cambia el zoom. Usa los botones táctiles de correr, Target, skills y consumibles; BOLSA y EQUIPO abren sus paneles. El botón existente del HUD abre `MenuUI`, donde está Ayuda; Dungeon y Party siguen en el micromenú.» |
| Cámara | «En PC, mantén el botón derecho y mueve el ratón para rotar; la rueda ajusta la distancia. En móvil, arrastra fuera del joystick para rotar y usa dos dedos para acercar/alejar. La cámara no cambia al hacer click izquierdo sobre un enemigo.» |
| Combate y objetivos | «Selecciona un enemigo con `TAB`, click izquierdo en PC o el botón Target móvil; `TAB` y Target recorren enemigos válidos. Con el objetivo seleccionado y dentro de rango, el auto-attack golpea automáticamente: no hace falta hacer click repetidamente. Las skills dirigidas usan su objetivo válido; algunas pueden seleccionar automáticamente al enemigo afectado si aún no había uno seleccionado.» |
| Skills y grimorio | «La barra tiene 4 slots, configurables con skills aprendidas desde el Grimorio. En PC usa `1–4`; en móvil toca el slot. Cada skill tiene coste de maná, cooldown y requisitos propios, visibles en su tooltip.» |
| Pociones y buffs | «Los slots `Z`/`X` (o sus botones táctiles) usan los objetos asignados. La poción chica restaura 25% del MaxHP o MaxMP y la grande 50%. Los buffs otorgan +10% a ATK, DEF o MaxHP por 60 s; no se acumulan y volver a usar el mismo refresca su duración.» |
| Dungeon | «Desde el portal o el acceso Dungeon (`J`/micromenú), elige Solo o Grupo. La Helada tiene cinco pisos consecutivos; avanza al abrirse el paso y el loot se entrega automáticamente al inventario, no aparece como pickup en el suelo.» |
| Muerte, resurrección y abandono | «Al morir en una run aparece el panel de muerte; no se reinicia el piso automáticamente. Cada jugador tiene 3 resurrecciones gratuitas por run: reaparece en la entrada del piso actual con HP/MP llenos y conserva XP, loot y oro. Cuando se agotan, puedes comprar un revive opcional por `{revivePrice}` Robux o abandonar; abandonar termina la run, pero conserva lo ganado y no permite reanudarla.» |
| Party y matchmaking | «Un party admite hasta 4 jugadores; las invitaciones duran 60 s. Al entrar a Grupo con un party ya armado, la sala se completa con sus miembros; en las salas de matchmaking la run empieza automáticamente cuando todos los presentes están Listos (mínimo 2). Protector es Tank, Misericordia es Heal y el resto de specs son DPS; 1 Tank/1 Heal/2 DPS es un objetivo informativo, no un requisito. El PartyFrame muestra nombre, clase, nivel y HP verde de los miembros cuando estás en un party.» |
| Mochila, equipo y rarezas | «`B` abre Mochila y `C` Equipo; en móvil usa BOLSA/EQUIPO. Los tiers son blanco, verde, azul, morado y único; revisa el nivel requerido, stats y bonos de set en los tooltips. En PC, click derecho usa o equipa; también puedes arrastrar un ítem a su casilla. En móvil, tap corto muestra información y mantener pulsado inicia el arrastre.» |
| Talentos y respec | «Tu personaje usa una sola spec activa; los puntos de talento se obtienen con la progresión y permiten aprender pasivos y skills de talento. En el Hub, el Instructor puede reiniciar talentos/cambiar la spec por 100 de oro; las skills obtenidas por talentos se deben volver a aprender tras un respec.» |
| NPCs y economía | «En el Hub, los vendedores permiten comprar consumibles/equipo y vender ítems; el Instructor ofrece respec por 100 de oro. El trade entre jugadores solo funciona en el Hub y requiere aceptación mutua. La Subasta del NPC es cross-server: publicar cuesta `{auctionListingFee}` de oro, la venta descuenta `{auctionSaleCut}%` al vendedor y el comprador paga exactamente el precio publicado; las recompensas se reclaman desde la pestaña Mis recompensas.» |
| Preguntas frecuentes | «El loot se entrega automáticamente a la mochila y aparece en el aviso de recompensa. La composición 1/1/2 es orientativa y no bloquea el inicio del grupo. Al abandonar conservas XP, ítems y oro, pero la run termina y no se reanuda.» |

#### **5. ModuleScript y arquitectura de contenido**

* Guardar tarjetas y secciones en un único ModuleScript `TutorialContent`, accesible desde el cliente (por ejemplo, en una carpeta compartida de `ReplicatedStorage`).
* Estructura sugerida: `cards[{id,title,bodyPc,bodyMobile,highlight}]` y `helpSections[{id,title,bodyTemplate}]`. Los textos anteriores son la fuente inicial editable; no copiar strings a distintos LocalScripts.
* El flag del tutorial permanece en el perfil y solo lo modifica el servidor. `TutorialContent` es contenido de presentación: no autoriza compras, resurrecciones, transacciones ni datos de combate. Los valores variables (`revivePrice`, `auctionListingFee`, `auctionSaleCut`) se leen de su config/servicio de origen al mostrar la ayuda.
* Reutilizar los tokens de EST-13, el botón de cerrar reusable de R6.35 y los componentes existentes del HUD; no crear iconos de mapa ni tooltips o notificaciones fuera de sus sistemas globales.

#### **6. Reglas de plataforma y presentación**

* PC y móvil usan el mismo orden y significado, con copy/controles adaptados al dispositivo.
* Durante el RC, contrastar cada instrucción con los controles realmente disponibles en los Places de Hub y Dungeon; no enseñar gestos o botones que aún no estén implementados (R6.15/R6.23 definen los gestos de cámara móvil y deben verificarse en el build).
* Respetar `Scale`, `UIAspectRatioConstraint`, zona segura móvil y targets táctiles de al menos 44×44 px donde aplique.
* La tarjeta, el panel y los highlights no deben cubrir joystick, Target, skillbar, consumibles ni controles del micromenú.
* No mostrar acciones de teclado como input requerido en la variante móvil.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Primera aparición del personaje**

* **GIVEN** un perfil cargado con personaje activo y `tutorialDone = false` o ausente.
* **WHEN** aparece el personaje por primera vez en una sesión jugable.
* **THEN** se muestra la primera tarjeta sin congelar al personaje, la cámara ni el resto del juego.

#### **Escenario 2: Completar, omitir y persistir**

* **GIVEN** el onboarding activo.
* **WHEN** el jugador termina, omite o lo cierra con el botón de cierre.
* **THEN** el servidor guarda `activeChar.tutorialDone = true` y no vuelve a mostrar automáticamente el onboarding para ese personaje.
* **AND** si el jugador se desconecta antes de una acción explícita de completar/omitir, el flag continúa en `false`.

#### **Escenario 3: Flag por personaje**

* **GIVEN** dos personajes de la misma cuenta con estados distintos de tutorial.
* **WHEN** el jugador cambia de personaje o vuelve a entrar.
* **THEN** cada personaje respeta su propio flag y el cliente no puede modificarlo localmente.

#### **Escenario 4: Ayuda permanente**

* **GIVEN** el onboarding ya fue completado u omitido.
* **WHEN** el jugador elige **Ayuda** en `MenuUI` de PC/móvil o pulsa `?` en PC.
* **THEN** se abre la ayuda general con sus secciones, tanto en Hub como en Dungeon.
* **AND** abrir/cerrar ayuda no altera `tutorialDone`.

#### **Escenario 5: Controles y contenido correctos**

* **GIVEN** el jugador revisa las tarjetas o secciones de ayuda.
* **WHEN** consulta combate, cámara, skills, consumibles, dungeon, party, equipo o economía.
* **THEN** los controles y reglas coinciden con las HUs de referencia: auto-attack con objetivo seleccionado, pociones 25%/50%, roles automáticos, matchmaking auto-start, rarezas actuales y muerte con panel/resurrecciones.
* **AND** no aparece un minimapa ni se afirma que morir reinicia el piso, que la composición 1/1/2 es obligatoria o que click izquierdo es el ataque básico.

#### **Escenario 6: Highlights válidos**

* **GIVEN** una tarjeta con highlight sugerido.
* **WHEN** el elemento del HUD existe en el dispositivo/estado actual.
* **THEN** se resalta solo ese elemento, sin capturar su input.
* **AND** si no existe (por ejemplo, PartyFrame sin party), la tarjeta sigue funcionando sin highlight ni error.

#### **Escenario 7: Navegación y accesibilidad**

* **GIVEN** una tarjeta o una sección de ayuda abierta.
* **WHEN** se usan Anterior/Siguiente/Omitir, cerrar o scroll/acordeón.
* **THEN** el contenido no tapa los controles esenciales, la interfaz respeta safe area y el input vuelve al juego al cerrarse.

#### **Escenario 8: PC y móvil**

* **GIVEN** un jugador en PC o en un dispositivo táctil.
* **WHEN** completa el onboarding y usa el panel de ayuda.
* **THEN** las instrucciones y los highlights corresponden a esa plataforma y la interfaz se lee y se toca correctamente.

#### **Escenario 9: Sin regresiones**

* **GIVEN** el tutorial implementado.
* **WHEN** se prueba nuevo personaje → omitir/completar → rejoin → party/dungeon → muerte/respawn → ayuda.
* **THEN** no hay errores rojos, la partida sigue activa y HUD, targeting, skillbar, consumibles, matchmaking, muerte y cámara conservan su comportamiento.

---

### **Alcance**

#### Incluye

* Onboarding de hasta 8 tarjetas, no bloqueante, primera vez por personaje, con navegación y opción de omitir.
* Persistencia server-authoritative de `activeChar.tutorialDone`.
* Integración del panel/contenido con la opción **Ayuda** ya existente en `MenuUI` (PC/móvil) y el atajo `?` (PC); no crear una segunda opción ni un botón flotante.
* Contenido breve adaptado por plataforma y secciones ampliadas para controles, combate, consumibles, dungeon, muerte, party, equipo, talentos, vendors y economía.
* Highlights visuales solo sobre elementos actuales del HUD y solo cuando están disponibles.
* Verificación responsive en PC y móvil.

#### No incluye

* Nuevas reglas de combate, party, dungeon, consumibles, inventario, respec, trade o subasta.
* Cambiar matchmaking (R9a.2), tooltips (R6.27) o notificaciones (R6.31); agregar una entrada Ayuda al micromenú.
* Minimapa, tutoriales de combate que capturen input, pausa, NPC/quest scripting o contenido con branching.
* Ilustraciones nuevas: reutilizar iconos/assets existentes y componentes de UI.

---

### **Definition of Done (DoD)**

* [ ] Un personaje con flag ausente/false recibe el onboarding una sola vez tras cargar el perfil.
* [ ] Completar, omitir o cerrar persiste el flag por personaje en el servidor; desconectarse antes no lo marca.
* [ ] Ocho tarjetas como máximo, con contenido PC/móvil, navegación, progreso y cierre/omisión.
* [ ] Ayuda general accesible desde la opción Ayuda de `MenuUI` en PC/móvil y con `?` en PC; no existe botón flotante adicional de Ayuda ni entrada Ayuda en el micromenú.
* [ ] La entrada Ayuda y el atajo `?` abren el mismo panel sin duplicar ventanas ni estado.
* [ ] En `MenuUI`, Ayuda aparece al final, inmediatamente debajo de Configurar interfaz/Orden de UI.
* [ ] `TutorialContent` es fuente única para onboarding y ayuda; los textos canónicos y las reglas están actualizados.
* [ ] Highlights no bloquean input, no nombran minimapa y omiten elementos no disponibles.
* [ ] Cámara, movimiento, combate, skills, consumibles, party, inventario, matchmaking y muerte siguen activos durante el onboarding.
* [ ] PC y móvil superan pruebas responsive, touch/safe area y flujo de botones.
* [ ] Los controles indicados se cotejan con el build real; no se publica una instrucción móvil para un gesto/botón ausente.
* [ ] Sin errores rojos durante primera aparición, omisión, finalización, cambio de personaje, rejoin y reapertura de ayuda.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de implementación y QA.

---

### **Decisiones por defecto**

| Tema | Default |
|---|---|
| Primera aparición | Primer spawn jugable tras cargar el perfil/personaje activo |
| Persistencia | `activeChar.tutorialDone`; ausencia equivale a `false`; estado escrito por el servidor |
| Formato | Hasta 8 tarjetas no bloqueantes, con Anterior/Siguiente/Omitir y Terminar |
| Abandono del onboarding | Botón cerrar equivale a Omitir; desconexión sin omisión no completa el flag |
| Ayuda general | Opción Ayuda de `MenuUI` PC/móvil + atajo `?` en PC; disponible en Hub y Dungeon |
| Contenido | Un ModuleScript `TutorialContent`, con variantes PC/móvil y textos de ayuda |
| Highlights | PlayerFrame, TargetFrame, skillbar, consumibles, PartyFrame o acceso Dungeon; solo si existen |
| Diseño visual | Tokens EST-13 y componentes globales; sin assets nuevos ni minimapa |

---

### **Estimación (orientativa)**

2–3 sesiones del dev: persistencia y estado por personaje, tarjetas/highlights, panel de ayuda con contenido y regresión PC/móvil.

---

### **Historial**

| Fecha | Cambio |
|---|---|
| 2026-09-22 | Creación de HU-TUTORIAL-01: onboarding guiado (hasta 8 tarjetas no bloqueantes) + panel de ayuda permanente (`?`/botón HUD) con contenido en ModuleScript editable. |
| 2026-10-26 | Revisión de contenido para RC: controles definidos en sus HUs, auto-attack por target, pociones chica/grande y buffs, matchmaking/roles, equipo, economía y muerte con DeathPanel (3 resurrecciones gratis, revive opcional 49 Robux). Se elimina la referencia obsoleta al minimapa y se alinea el contenido con las reglas actuales. |
| 2026-10-26 | Ubicación corregida: reutilizar la opción Ayuda ya implementada en el menú normal `MenuUI` (R6.10), al final debajo de Configurar interfaz/Orden de UI; `?` en PC, sin botón flotante adicional ni entrada Ayuda en micromenú. |
| 2026-10-27 | Implementada según reporte del PO; QA/verificación pendiente. |
