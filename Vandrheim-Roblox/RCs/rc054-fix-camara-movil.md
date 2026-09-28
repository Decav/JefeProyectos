--[[
================================================================================
          REQUERIMIENTO TÉCNICO: rc054 — FASE R6.15 (HU-R6.15)
================================================================================
Proyecto: Vandrheim — RPG/MMO-like en 3ª persona (Roblox).
Fuente: HU-R6.15 (HU/HU-R6.15-Fix-Camara-Movil.md) + GDD §12
  (arquitectura técnica) + HU-R3.1/rc005 (pitch y controles de cámara existentes).
Estado: EN IMPLEMENTACIÓN (código editado en Hub; QA táctil, pruebas PC y sync Dungeon pendientes).
Requisitos previos: HU-R3.1/rc005 (CameraController y CameraConfig).

================================================================================
1. DESCRIPCIÓN
================================================================================
En dispositivos táctiles, permitir mover al personaje con el joystick y girar
la cámara simultáneamente con otro dedo, sin que el movimiento del joystick,
los botones de la interfaz o toques previos contaminen el delta de cámara.

Objetivo de la fase: separar la propiedad del gesto de cámara del resto de
entradas táctiles y mantener la órbita estable durante arrastres repetidos.
Criterio de hecho global: mover y mirar simultáneamente en móvil sin saltos,
sin rotación causada por controles/UI y sin regresión de cámara en PC.

================================================================================
2. ALCANCE (SÍ)
================================================================================
* Modificar únicamente StarterPlayer.StarterPlayerScripts.CameraController en
  la fuente canónica Hub.
* En la rama móvil, asignar como máximo un dedo elegible a la cámara; aceptar
  su drag fuera de controles interactivos. No tratar los contenedores
  TouchControlFrame/GestureArea de pantalla completa como controles táctiles.
* Calcular yaw/pitch con deltas consecutivos del mismo InputObject táctil; no
  reutilizar posiciones de otro dedo ni acumular delta mientras la cámara no es
  dueña del gesto.
* Liberar el estado del gesto al finalizar/cancelarse el toque, perder foco o al
  bloquearse la cámara por UIWindowOpen. Mantener yaw continuo y el clamp
  MinPitch/MaxPitch ya definido en CameraConfig (±70°).
* Conservar movimiento táctil, targeting por tap y funcionamiento de HUD,
  incluyendo BOLSA/EQUIPO/MENÚ y el micro-menú compacto de R6.14.
* Mantener sin cambios la ruta PC y sus controles RMB/LMB/GetMouseDelta.

================================================================================
3. FUERA DE ALCANCE (NO en esta HU)
================================================================================
* Modificar el joystick, PlayerModule, su tamaño/posición o el sistema de
  movimiento del personaje.
* Cambiar TargetingSystem, sus reglas de tap, HUD, ventanas, micro-menú o layout;
  solo se filtran los gestos que pertenecen a esos controles.
* Cambiar sensibilidad, zoom, CameraConfig, pitch del PC o el comportamiento de
  mouse; no añadir remotes, estado persistente ni lógica de servidor.
* Publicar la experiencia o cambiar permisos/configuración de acceso.

================================================================================
4. CRITERIOS DE ACEPTACIÓN (DEFINICIÓN DE HECHO)
================================================================================
1. En móvil, mantener el joystick y arrastrar un segundo dedo fuera de él mueve
   al personaje y rota la cámara simultáneamente de forma estable.
2. Tomar y soltar el gesto de cámara repetidamente no provoca saltos, deltas
   acumulados ni rotación cuando el dedo no pertenece a la cámara.
3. El pitch conserva el clamp existente; el yaw continúa entre gestos sin
   reiniciarse.
4. Los botones del HUD (BOLSA/EQUIPO/MENÚ), el micro-menú y el targeting móvil
   por tap siguen funcionando; sus toques no giran la cámara.
5. La cámara PC conserva sus controles y sensibilidad actuales.

================================================================================
5. IMPLEMENTACIÓN TÉCNICA
================================================================================
* Editar la sección móvil del LocalScript
  StarterPlayer.StarterPlayerScripts.CameraController. Usar eventos de ciclo de
  vida táctil y conservar la identidad del InputObject reclamado por la cámara.
* En el inicio del gesto, rechazar entradas procesadas y objetos de control
  realmente interactivos (incluido el frame del joystick y botones). Al consultar
  PlayerGui:GetGuiObjectsAtPosition, ignorar TouchControlFrame/GestureArea y otros
  contenedores TouchGui que cubren la pantalla completa; no son botones ni zonas
  exclusivas del joystick. No reclamar dedos usados por otra entrada.
* En movimiento, aceptar solo el InputObject reclamado, calcular el delta desde
  la última posición de ese mismo dedo y avanzar siempre la posición base para
  evitar catch-up tras una pausa/bloqueo. Limpiar identidad y posición al terminar
  o cancelarse el toque, al perder foco y mientras UIWindowOpen bloquee la cámara.
* Aplicar yaw con la sensibilidad táctil existente y pitch mediante
  math.clamp(CameraConfig.MinPitch, CameraConfig.MaxPitch); no normalizar ni
  reiniciar yaw entre gestos.
* No alterar la rama PC bajo `if not isMobile`, ni añadir configuración,
  remotes, atributos persistentes o lógica server-authoritative: el cambio es
  exclusivamente de input/cámara local.

================================================================================
6. INTEGRACIÓN
================================================================================
Depende de CameraController/CameraConfig de HU-R3.1 y de los controles móviles
existentes. TargetingSystem conserva su TouchTap y los componentes de UI no se
modifican. El Hub es fuente única de verdad; Dungeon_Helada consume el módulo
compartido como copia derivada según rc048, sin una implementación aparte.

================================================================================
7. OPTIMIZACIÓN
================================================================================
Estimación de HU: 1 sesión. Usar eventos táctiles existentes, mantener un único
gesto dueño de cámara y no añadir polling/bucles, módulos ni estado persistente.
La ruta de mouse queda separada mediante la condición TouchEnabled ya existente.

================================================================================
8. DEFINICIÓN DE HECHO (VERIFICACIÓN)
================================================================================
[x] CameraController actualizado en la fuente Hub: propiedad de un único toque,
    filtro de controles reales sin bloquear los contenedores TouchGui de pantalla
    completa, deltas del mismo InputObject y limpieza al terminar, perder foco o
    abrir ventana. Revisión estática realizada.
[x] La ruta PC RMB/LMB/GetMouseDelta permanece intacta; no se modificaron
    TargetingSystem, joystick, HUD, remotes ni DATA_SCHEMA.
[x] PROJECT_ARCHITECTURE registra rc054 y la propagación derivada pendiente.
[x] Causa del primer intento corregida: el hit-test incluía los contenedores
    TouchControlFrame/GestureArea de pantalla completa y bloqueaba todo toque;
    ahora esos contenedores se omiten y se filtran sus controles reales.
[x] Output consultado en modo Edit: se reportan errores en AssistantCommand y
    un Motor6D de Workspace.EST30_BossPreview; no hay stack de CameraController.
    No se atribuyen esos errores a rc054.
[x] Confirmación del usuario (2026-09-25): con el filtro corregido, el drag
    táctil de cámara en Device Simulator ya produce rotación. Esta confirma
    únicamente el arrastre; no reemplaza el caso multitáctil completo.
[ ] Device Simulator / dispositivo táctil: mover con joystick y rotar con un
    segundo dedo, comprobar pitch/yaw y repetir agarre/soltado sin saltos.
[ ] Tocar joystick, HUD, micro-menú y objetivos: no hay rotación accidental y
    cada control/tap conserva su función.
[ ] Regresión PC: probar RMB, LMB-targeting y zoom; revisar Output sin errores.
[ ] QA runtime móvil pendiente: Play Solo no se inició porque el arranque de
    DataService puede acceder a perfiles persistentes.
[ ] Sync places: módulo afectado StarterPlayer.StarterPlayerScripts.CameraController;
    places consumidores Hub (fuente) y Dungeon_Helada (copia derivada). Propagar
    al generar/publicar la copia derivada rc048 y verificar que su Source coincida
    con el Hub. Dungeon no está abierto como DataModel MCP; sincronización/QA
    cross-place quedan pendientes de generar la copia derivada.
[ ] Registrar en GDD solo después de completar QA móvil, según el DoD de HU-R6.15.

================================================================================
9. ESTIMACIÓN
================================================================================
1 sesión orientativa, según HU-R6.15.

================================================================================
10. DEPENDENCIAS
================================================================================
HU-R3.1/rc005 (CameraController, CameraConfig y clamp ±70°), controles móviles
existentes, TouchTap de TargetingSystem y UI compacta R6.14. No requiere cambios
de DATA_SCHEMA ni de contratos de red.

================================================================================
FIN DEL REQUERIMIENTO
================================================================================
--]]
