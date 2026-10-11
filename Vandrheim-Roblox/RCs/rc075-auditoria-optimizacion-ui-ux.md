--[[
================================================================================
          REQUERIMIENTO TÉCNICO: rc075 — AUDITORÍA Y OPTIMIZACIÓN UI/UX
================================================================================
Proyecto: Vandrheim — RPG/MMO-like en 3ª persona (Roblox).
Fuente principal: solicitud directa del usuario, 2026-10-08, de recopilar,
optimizar y validar la interfaz responsive y emitir un RC dentro de Studio.
Inventario de soporte: UI_AUDIT_2026-10-08.md (47 unidades de prueba, Sources
y jerarquía del Hub inspeccionados en Edit el 2026-10-08).
Referencias de producto: GDD §§1 (PC/móvil), 12 (arquitectura), 13 (MVP),
17.1/17.2 (reskin/vendors) y 24 (HUD); HU-R6.11, HU-R6.20, HU-R6.27,
HU-R9a.2 y diseños EST-13/19/21/22/25/37 existentes.
Estado: EN IMPLEMENTACIÓN — aprobado por usuario 2026-10-08; QA en curso.
Requisitos previos: UI actual del Hub, UITheme, contratos de layout R6.11/R6.20
y prelobby rc074; conservar sus estados de QA pendientes.
Lugar fuente: Hub Vandrheim-RPG [ALFA], PlaceId 84186294312317.
Fecha: 2026-10-08 (America/Santiago).

Nota de fuente: esta solicitud no trae una nueva HU formal ni número de fase.
No inventar un identificador de HU ni reasignar DEV_PROMPT, que aún referencia
HU-R9a.2. Mantener las diez secciones del RC-TEMPLATE de Studio; la petición
directa delimita el alcance y las HUs previas aportan contratos existentes.
Este RC no certifica validación jugable. No guardar ni publicar el place.

================================================================================
1. DESCRIPCIÓN
================================================================================
Como jugador, quiero una interfaz legible, cómoda y adaptada a mi pantalla,
con controles accesibles y sin solapamientos accidentales, tamaños rotos ni
contenido esencial recortado, para jugar y gestionar personaje/grupo sin
fricción en PC y móvil.

Objetivo de la fase: auditar las superficies de UI existentes, reproducir
errores con evidencia, corregir su presentación y coordinación de layout/input,
y validar los flujos afectados en una matriz explícita de pantallas/estados.
Preservar Hearthbound Gold y las referencias del diseño del proyecto.

Criterio de hecho global: en la matriz de QA definida, los flujos existentes
pueden completarse, la información esencial y los botones se leen/alcanzan,
no hay obstrucciones accidentales, los layouts personalizados se conservan y
los cierres/transiciones restituyen correctamente los controles del juego.

================================================================================
2. ALCANCE (SÍ)
================================================================================
* Inventario de StarterGui y UI creada en runtime; identificar controlador,
  disparador de apertura, estados y coexistencias por unidad de prueba.
* Medir y corregir contención, padding, grid/lista, tamaño/proporción de iconos,
  texto, botones/cerrar, capas, scroll y visibilidad de estados existentes.
* Revisar responsables de posición, escala, estilos y estado de ventanas;
  eliminar interferencias confirmadas entre controladores de presentación.
* Revisar mouse/teclado y touch, áreas seguras, teclado móvil y resize de
  viewport. Conservar LandscapeSensor y la solución de accesos móvil.
* Proteger posición/escala guardada, editor Ordenar UI y coexistencia PC de
  mochila derecha + equipo izquierda, con drag temporal y enfoque correctos.
* Corregir únicamente fallos de UI/input reproducidos en estos flujos;
  no cambiar decisiones de combate, inventario, economía, party o teleport.
* Registrar evidencia y estado de QA por caso. Las siguientes 47 unidades
  forman el inventario inicial (variantes comparten algunas ScreenGui):

* U01 Selección de personaje — CharacterSelect.
* U02 Creación de personaje — CharacterCreate.
* U03 Confirmación de borrar personaje — CharacterSelect.Background.DeleteDialog.
* U04 Card del jugador — HUD.PlayerFrame.
* U05 Card del objetivo — HUD.TargetFrame.
* U06 Barra de boss — HUD.BossBar (runtime).
* U07 Barra de habilidades — SkillBar.BarContainer.
* U08 Barra de consumibles — HUD.ItemUseSlotsFrame (runtime).
* U09 Micro menú de escritorio — MicroMenuUI (runtime).
* U10 Accesos de móvil — MobileAccessUI (runtime).
* U11 Botón caminar/correr móvil — MovementUI.MovementToggleButton (runtime).
* U12 Estado del grupo en HUD — PartyUI.PartyHUD (runtime).
* U13 Estado de dungeon y acceso a abandonar — DungeonHUD.TopBar; AbandonButton.
* U14 Mochila — InventoryUI.MainFrame.
* U15 Ficha de ítem de mochila — InventoryUI.MainFrame.ItemInfoPanel (runtime).
* U16 Equipo y estadísticas — EquipmentUI.MainFrame.
* U17 Tooltip de ítem y acciones — SharedUI.Tooltip.
* U18 Selección de especialización — TalentUI (SpecSelectionRow, runtime).
* U19 Árbol de talentos — TalentUI.MainFrame.NodesContainer.
* U20 Detalle de talento — TalentUI.MainFrame.TalentTooltip (runtime).
* U21 Confirmación de reasignar talentos — TalentUI.MainFrame.TalentRespecDialog (runtime).
* U22 Grimorio y editor de barra activa — SpellbookUI.MainFrame.
* U23 Detalle de habilidad — SpellbookUI.MainFrame.TooltipFrame (runtime).
* U24 Alquimista/pociones — VendorUI (vendor_consumables).
* U25 Armero: comprar — VendorUI (vendor_gear, BuyPanel).
* U26 Armero: vender — VendorUI (vendor_gear, SellPanel).
* U27 Instructor y confirmación — VendorUI.MainFrame.TrainerPanel.
* U28 Tooltip del vendedor — SharedUI.Tooltip (owner Vendor).
* U29 Menú general — MenuUI.Panel.
* U30 Editor Ordenar UI — EditLayoutUI (runtime).
* U31 Confirmación al salir del editor — EditLayoutUI.ExitConfirmation (runtime).
* U32 Administración de party y confirmación — PartyUI.PartyWindow; Confirm (runtime).
* U33 Selector de invitados — PartyUI.PartyWindow.FriendPicker (runtime).
* U34 Invitación recibida — PartyUI.InvitePopup; InviteScrim (runtime).
* U35 Portal: Solo/Grupo — MatchmakingUI.PortalWindow.Views.Choice (runtime).
* U36 Crear sala — MatchmakingUI.PortalWindow.Views.Create (runtime).
* U37 Listado de salas — MatchmakingUI.PortalWindow.Views.List (runtime).
* U38 Sala y ready-check — MatchmakingUI.PortalWindow.Views.Room (runtime).
* U39 Guía de dungeon — MatchmakingUI.PortalWindow.Views.Guide (runtime).
* U40 Confirmación de entrar Solo desde party — MatchmakingUI.PortalWindow.SoloConfirmation (runtime).
* U41 Prompt de interacción — InteractionPromptUI.PromptPanel (runtime).
* U42 Confirmación de abandonar dungeon — DungeonHUD.ConfirmDialog.
* U43 Aviso de boss/cofre — DungeonHUD.BossNotice (runtime).
* U44 Aviso de fin de run — DungeonHUD.RunEndedNotice.
* U45 Toast de loot — SharedUI.LootPopup (runtime).
* U46 Subida de nivel y feedback — LevelUpFeedback; SharedUI/SkillBar/HUD feedback (runtime).
* U47 Indicadores vinculados al mundo — Crosshair; target billboard; números daño/cura; aviso del cofre.

* Regresión adicional: HUD.DebugFrame/preview se restringen a Studio y no
  determinan el espacio de producción; SkillBar.LoadoutPanel legado se
  mantiene oculto, sin borrar dependencias a ciegas.

================================================================================
3. FUERA DE ALCANCE (NO en esta tarea)
================================================================================
* Implementar DeathPanel/R6.28, trade/subasta ECON-01/02 o nuevas pantallas.
  No se encontraron esas interfaces en la implementación inspeccionada.
* Añadir funcionalidades de volumen/gráficos a los placeholders del menú.
* Rediseñar el lenguaje visual, reemplazar iconos/artwork o inventar asset IDs.
* Cambiar stats, daño, cooldown real, balance, precios, loot, reglas de
  inventario/equipamiento, talentos, progresión o readiness/teleport.
* Cambiar esquemas persistentes o contratos/remotes server-authoritative.
* Añadir soporte nuevo de gamepad/consola/VR u orientación vertical móvil.
* Migración general de DataService ni refactor de servicios de juego.
* Guardado/publicación automática, ni edición de una copia independiente de
  Dungeon_Helada. Hub sigue siendo fuente; el usuario publica copias derivadas.

================================================================================
4. CRITERIOS DE ACEPTACIÓN (DEFINICIÓN DE HECHO)
================================================================================
1. Inventario U01–U47 con responsable, estados y pruebas; cada fila termina en
   validado o no aplica justificado, o queda pendiente visible que impide
   declarar COMPLETO. Source leído no equivale a QA visual/interactiva.
2. Cabeceras, cerrar, acciones y texto esencial permanecen en el área útil en
   cada caso de pantalla; contenido extenso tiene wrap/scroll y final accesible.
3. Layouts predeterminados no superponen accidentalmente HUD, party, estado
   de dungeon, skillbar, consumibles, menú, toasts y controles táctiles.
   Overlays modales/badges/foco y overlaps manuales intencionales se distinguen.
4. Mochila y equipo coexisten en PC, se pueden usar para equipar ambas manos y
   mover/enfocar; reducir la ventana conserva controles alcanzables. Móvil
   mantiene distribución adecuada y no necesita copiar el patrón PC.
5. Tooltips de bolsa/equipo/vendor siguen visibles e interactivos tras drag o
   enfoque de ventana; se limpian al cerrar/cambiar de personaje.
6. Iconos conservan proporción y límites del slot; tecla/cantidad/CD permanecen
   visibles. Rareza y estado no se pierden al aplicar estilos.
7. Estados vacío/lleno, seleccionado/bloqueado, error/loading/éxito, CD y listo
   se distinguen; error solo se presenta cuando existe mensaje. Cooldown de
   consumibles no alterna indebidamente oscuro/claro.
8. Mouse y touch completan los mismos flujos existentes; tooltips no dependen
   exclusivamente de hover. Escribir en NameBox/RoomName no abre accesos ni
   dispara acciones de juego. Volver/cancelar no deja al jugador atrapado.
9. Scroll sobre listas no hace zoom y drag/tap sobre UI no activa targeting ni
   cast; cerrar la última ventana restituye cámara/controles/prompts. Conservar
   excepciones de interacción actuales sin añadir bloqueos permanentes.
10. Ordenar UI mantiene snap/restaurar/guardar/descartar y posición/escala por
    PJ; 0.6–2.0 y máximo efectivo seguro siguen vigentes. Resize/respawn no
    sobrescribe los datos guardados ni acumula insets/deriva.
11. Selección/creación, talentos/grimorio, vendors, party/prelobby y dungeon
    superan sus estados detallados en el inventario, incluyendo nombres largos,
    listas extensas y 4 miembros. Errores de presentación corregidos no cambian
    datos ni autoridad del servidor.
12. Aperturas/cierres repetidos y respawn/cambio de PJ no duplican GUI,
    conexiones o overlays bloqueantes; no se introducen scans por frame.
13. Evidencia de dispositivos/pantallas con capturas, pasos y resultados; no
    confundir emulación de tamaño con validación física ni QA publicada.
    Pendientes de multicliente, dispositivo real o publicación se declaran.

================================================================================
5. IMPLEMENTACIÓN TÉCNICA
================================================================================
5.1 Método de trabajo
* Primero documentar baseline y reproducir hallazgos. Después aplicar fixes
  agrupados por responsable y verificar cada flujo antes de ampliar cambios.
* P0: impide entrar/jugar/completar/cerrar; P1: oculta información/controles;
  P2: inconsistencia visual. Clasificar por impacto demostrado.
* No imponer un rediseño ni breakpoints/tamaños de fuente sin validación:
  la matriz propone casos de QA; tamaños finales se miden y registran.
* Esta emisión solo crea documentación/RC, no inicia la implementación.

5.2 Archivos de presentación candidatos (modificar solo donde exista hallazgo)
* ReplicatedStorage.Config.UITheme: tokens vigentes; no sustituir assets.
* StarterGui: CharacterSelect, CharacterCreate, HUD, SkillBar, InventoryUI,
  EquipmentUI, TalentUI, SpellbookUI, VendorUI, MenuUI, DungeonHUD, SharedUI y
  Crosshair. Mantener nombres/contratos y estilos aprobados.
* StarterGui.HUD.HUDClient: player/target/boss y representación de atributos.
* StarterPlayer.StarterPlayerScripts:
  UIReskinClient, InventoryPresentationClient, InventoryClient,
  WindowLayoutClient, UILayoutClient, CharacterClient, TalentClient,
  SpellbookClient, VendorClient, MenuClient, PartyClient, MatchmakingClient,
  ItemUseSlotsClient, SkillBarClient, InteractionPromptClient, DungeonClient,
  LevelUpClient y MovementClient.
* CameraController/TargetingSystem: únicamente coordinación/filtros de UI
  si QA reproduce zoom, targeting o gestos indebidos; conservar controles.
* TargetIndicator/VFXClient: solo escala/legibilidad de sus indicadores 2D si
  hay hallazgo. FloorService se inspecciona para el aviso existente del cofre;
  no modificar generación de pisos ni lógica core para esta tarea.
* ServerScriptService.UILayoutServer y DATA_SCHEMA son referencias de
  compatibilidad; no son objetivos de cambios de esquema/backend.
* PROJECT_ARCHITECTURE registra los responsables y resultados después de los
  fixes; GDD/HU solo se cierran tras QA. No marcar rc073/rc074 completos por
  arrastre de esta auditoría.

5.3 Layout y coordenadas
* PROJECT_STANDARD: Position/Size de GUI en Scale, task.wait/task.spawn/task.defer
  si procede; UIAspectRatioConstraint en iconos y bloques críticos.
* Reutilizar UIListLayout/UIGridLayout/UIPadding y constraints; corregir
  casos donde un aspect/constraint anule una distribución o fuerce overflow.
* Adaptar columnas/distribución/scroll al espacio útil; no resolver todo
  reduciendo tipografía mediante UIScale. Mantener controles alcanzables.
* Un responsable por propiedad final: panel administra contenido; reskin
  aplica tokens; layout administra x/y y escala del usuario. Verificar el
  resultado efectivo de modifiers existentes antes de unificar.
* Usar coordenadas relativas al contenedor/ScreenGui real; aplicar insets
  una sola vez. Fondo decorativo y UI interactiva pueden requerir áreas
  distintas; comprobar topbar además del notch sin mover el HUD arbitrariamente.
* Recalcular con señales de ViewportSize/AbsoluteSize y reemplazo de cámara,
  desconectando bindings previos; aplicar clamp después de layout/escala.
* ScreenOrientation sigue LandscapeSensor. No alterar orientación de producto.

5.4 Capas e interacción
* DisplayOrder entre ScreenGui y ZIndex dentro de cada GUI se comprueban juntos.
  Tooltip/confirmación quedan sobre su propietario mientras se usan, pero una
  confirmación bloquea acciones de fondo. Evitar subidas de capa ilimitadas.
* Coordinación de UIWindowOpen/MenuUIOpen/UILayoutEditMode y excepciones
  existentes: cada ventana deja estado correcto al cerrar, respawnear o
  deshabilitarse. No basta activar un flag y liberarlo desde otra ventana.
* Mouse/touch: preferir Activated para acciones existentes; respetar foco de
  TextBox y gameProcessed. TouchEnabled conserva compatibilidad; PreferredInput
  puede informar hints/operación híbrida sin rediseñar controles ni gamepad.
* Los tooltips extensos tienen contención/scroll acorde al propietario y se
  consultan con tap donde ya existe selección táctil.
* Texto, contraste y estados se prueban con preferencias existentes de Roblox.
  TextScaled no escala automáticamente con PreferredTextSize; ajustar el
  contenido antes de reducir textos a un tamaño ilegible.

5.5 Riesgos estructurales detectados (pendientes de QA)
* UIReskinClient/HearthboundResponsiveScale (0.86 compacto) y
  InventoryPresentationClient/EST21Scale (0.82) existen en los mismos frames.
* WindowLayoutClient eleva ScreenGui desde DisplayOrder >70; SharedUI es 30.
* PartyUI/MatchmakingUI no integran la misma lista de UIWindowOpen; existen
  checks específicos de cámara/prompts, a contrastar de forma conjunta.
* WindowLayoutClient clampa al abrir/drag, sin binding de resize/cambio de cámara.
* ScreenInsets distintos y reskin que cambia insets; coordenadas/clamp requieren
  prueba de área útil y topbar.
* Prompt/LootPopup tienen geometría con Offset contraria al estándar vigente.
* rc074/prelobby tiene cinco vistas y confirmación con QA jugable aún pendiente.
* Pencil MCP no conectado al recopilar: comparación con frames queda pendiente,
  no afirmar fidelidad visual sin poder consultar las referencias.

5.6 Contratos y datos
* Server-authoritative: servidor decide inventario, oro, stats, talentos,
  compras, readiness y run. El cliente representa y envía intenciones actuales.
* Remotes: ninguno nuevo; payloads existentes se mantienen.
* Perfil: no campos nuevos. uiLayout sigue {elementId={x,y,scale}}, x/y 0–1,
  scale 0.6–2.0; default scale legado=1 y whitelist existente de ocho bloques.
* Reutilizar módulos/componentes existentes. Si el mismo fix se repite, justificar
  en el informe un helper local compartido; no crear un segundo framework de UI.

================================================================================
6. INTEGRACIÓN
================================================================================
* Conservar R2 selección/creación, R4/R6.5 inventario/equipo, R5 vendors,
  R5.1 talentos/grimorio, R6.2 consumibles, R6.10 menú, R6.11/R6.20 layout,
  EST-14/20/21 y party/prelobby R9a/rc074.
* Defaults actuales: bolsa derecha/equipo izquierda en PC; barra consumible
  junto a skillbar salvo ajuste manual; C/P/T/B/M en escritorio, botones
  separados en móvil; M para menú y ESC nativo intacto.
* Inventario actual y referencias de fuentes en UI_AUDIT_2026-10-08.md.
* Todo se trabaja en el Hub. La entrega para Dungeon_Helada se hace por copia
  derivada del Hub según rc048, preparada para publicación por el usuario.
* No depender de otra ventana de Dungeon_Helada para recopilar ni emitir este RC.
  QA cross-place final sigue pendiente hasta comprobar la versión derivada.

================================================================================
7. OPTIMIZACIÓN
================================================================================
* Preferir señales/coalescing y recalcular solo al cambiar viewport/contenido
  relevante; no recorrer todo PlayerGui continuamente ni duplicar loops de CD.
* Suscribir/desuscribir una vez por instancia/cámara; cancelar tweens obsoletos.
* Reutilizar GUI/filas cuando corresponda; no reescribir todo el framework.
* Comparar baseline con misma pantalla/estado; registrar instancias/conexiones
  y profiler donde QA detecte costo, sin fijar un objetivo de FPS inventado.
* Agrupar fixes: coordinación transversal, acceso/ventanas/tooltips,
  talentos/grimorio/party/prelobby, HUD/dungeon/notificaciones y regresión.
* Herramientas de diagnóstico locales/temporales no se entregan activas como
  paneles o loops de producción.

================================================================================
8. DEFINICIÓN DE HECHO (VERIFICACIÓN)
================================================================================
[ ] Inventario U01–U47 con estado de QA y responsables.
[ ] Reproducción de riesgos y capturas antes/después de cada corrección.
[ ] Matriz PC: 960×540, 1024×768, 1280×720, 1366×768, 1920×1080,
    2560×1440 y ultrawide 2560×1080; resize con paneles abiertos.
[ ] Matriz touch horizontal: perfiles equivalentes a 667×375, 844×390 y
    932×430; tablets 1024×768/1194×834; notch/controles nativos y ambos giros.
    Registrar viewport/área segura reales; estos son casos propuestos de QA,
    no límites de soporte ni breakpoints obligatorios.
[ ] Teclado móvil en creación/sala; PreferredTextSize existente y escala de
    usuario; physical-size en simulador y validación en dispositivo disponible.
[ ] Bolsa+equipo, tooltips tras drag, vendor+tooltip, party+sala+invitación,
    boss+HUD+party y toast+micro menú; capas intencionales identificadas.
[ ] Scroll/drag/touch no activan cámara/target/cast accidentalmente; controles
    se recuperan al cerrar y no hay overlays invisibles bloqueantes.
[ ] Ordenar UI: mover/escalar, snap, restaurar, guardar/descartar; 0.6/1/2,
    cambio de resolución, rejoin y separación de personajes sin pérdida.
[ ] QA con dos/cuatro clientes para invitación/room/ready y cambios de roster;
    emulación individual no sustituye estas pruebas.
[ ] Flujos repetidos apertura/cierre, respawn y selección de PJ sin duplicados,
    conexiones acumuladas ni errores rojos atribuibles al proyecto.
[ ] UI legacy/debug no reaparece en producción. Sin implementar paneles futuros.
[ ] Informe distingue inspección estática, Play, emulación, multicliente,
    dispositivo real y build publicado. Pendientes explícitos; RC no se marca
    COMPLETO mientras falte una prueba requerida o haya fallos bloqueantes.
[ ] PROJECT_ARCHITECTURE actualizado tras implementación; DATA_SCHEMA solo si
    una futura ampliación autorizada cambia datos (este alcance no lo requiere).
[ ] Sync/release: Hub 84186294312317 -> copia derivada Dungeon_Helada
    125210265978348 según rc048. Enumerar exactamente las Sources modificadas.
    Candidatos compartidos: UITheme, HUDClient, UIReskinClient,
    InventoryPresentationClient, InventoryClient, WindowLayoutClient,
    UILayoutClient, CharacterClient, TalentClient, SpellbookClient, VendorClient,
    MenuClient, PartyClient, MatchmakingClient, ItemUseSlotsClient, SkillBarClient,
    InteractionPromptClient, DungeonClient, LevelUpClient, MovementClient;
    CameraController/TargetingSystem/TargetIndicator/VFXClient solo si se cambian.
    Incluir las StarterGui modificadas. Verificar identidad/versión y flujos
    Hub/Dungeon en la copia consumidora; MatchmakingClient conserva guardia Hub.
[ ] El usuario guarda/publica. El agente no invoca Save/Publish ni crea un
    branch de contenido distinto en Dungeon_Helada.

================================================================================
9. ESTIMACIÓN
================================================================================
Propuesta técnica inicial: 5–8 sesiones de implementación/QA para una pasada
integral, sujeta al número y gravedad de fallos reproducidos. Incluye triage,
fixes transversales, ventanas, HUD/grupo/dungeon y regresión. Esperas por
dispositivos, multicliente, Pencil o publicación no se contabilizan como trabajo
ya realizado. Esta emisión cubre investigación/inventario/RC, no esas sesiones.

================================================================================
10. DEPENDENCIAS
================================================================================
* Solicitud directa del usuario del 2026-10-08; formalización de HU nueva por
  PM si se requiere administrativamente, sin inventar número ni alcance.
* UITheme, StarterGui y clientes de UI existentes; GDD y diseños vigentes.
* Contratos R6.11/R6.20 de uiLayout y controles PC/touch existentes.
* rc073 (fixes de presentación) y rc074 (prelobby) como bases de regresión,
  no como tareas declaradas cerradas por esta emisión.
* Acceso a Pencil para comparación visual; Device Simulator/Play y clientes
  disponibles para QA; build derivado/dispositivo real para validación final.

================================================================================
FIN DEL REQUERIMIENTO
================================================================================
AVANCE 2026-10-08: implementación parcial aprobada aplicada en once clientes de
presentación. Evidencia y pendientes en UI_AUDIT_2026-10-08.md, sección
Implementación y QA parcial. PC 1258x793 y simulador 874x402 (viewport 750x382).
Anclaje de consumibles reparado solo ante solapamiento; layout guardado intacto.
No hay nuevos remotes ni cambios de esquema/backend. Estado EN IMPLEMENTACIÓN;
no se certifican U01-U47 ni QA física/multicliente/publicada. No guardar/publicar.
--]]

