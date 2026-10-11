--[[
================================================================================
          REQUERIMIENTO TÉCNICO: rc082 — FASE EST-42 (HU-ESTETICA-42)
================================================================================
Proyecto: Vandrheim — RPG/MMO-like en 3ª persona (Roblox).
Fuente: HU/estetica/HU-ESTETICA-42-Reskin-Grimorio-Dev.md
        + GDD_ROBLOX_MVP §§4, 5, 6, 17 y 23 (contratos, no visual superado).
Referencia visual: Vandrheim-design.pen, WUFrU,
                   "Grimorio · Libro de habilidades WoW style".
Estado: EN IMPLEMENTACIÓN (aprobado explícitamente por el PM el 2026-10-09).
Fecha de emisión: 2026-10-09.
Requisitos previos: EST-17, EST-13, R5.1, R6.27 (legibilidad/iconos).
Documentación consultada: DEVELOPER_GUIDE, PROJECT_STANDARD,
PROJECT_ARCHITECTURE, DATA_SCHEMA, RC-TEMPLATE, ASSETS_POLICY, SKILL_CATALOG;
HU-ESTETICA-13, HU-ESTETICA-17, HU-R5.1, HU-R6.27 y WUFrU mediante Pencil MCP.
Place fuente: Hub 84186294312317. Consumidor: Dungeon_Helada 125210265978348.

Decisiones del usuario aprobadas el 2026-10-09:
- Colores de presentación: habilidades por nivel doradas, talento intermedio
  azul y capstone morado, siguiendo Pencil. No se añade rareza de gameplay.
- Activar filtros Todas / No asignadas y conectar desasignación al remoto
  existente; conservar reglas y validaciones del servidor.
- Excluir tooltips y TooltipSystem: quedan para la HU futura indicada.
Estas decisiones cierran las diferencias detectadas. RC aprobado explícitamente por el PM el 2026-10-09.

================================================================================
1. DESCRIPCIÓN
================================================================================
Presentar el grimorio como el libro WUFrU: encabezado del personaje, página de
habilidades, filtros y barra equipada inferior de cuatro slots con teclas.
Mostrar datos vigentes y permitir configurar el loadout con los contratos R5.1.

Objetivo de la fase: sustituir el visual EST-17 por la composición WUFrU y
reutilizar el catálogo, talentos, atributos y snapshots existentes.
Criterio de hecho global: el grimorio replica WUFrU con datos reales y conserva
aprendizaje, asignación, autoridad del servidor y uso de skills en PC y móvil.

================================================================================
2. ALCANCE (SÍ)
================================================================================
- StarterGui.SpellbookUI: shell y jerarquía existente; encabezado, página de
  habilidades, filtros, tarjetas y barra inferior según WUFrU.
- StarterPlayer.StarterPlayerScripts.SpellbookClient: construcción, presentación
  de datos, filtros locales, selección de slot, asignación y desasignación.
- ReplicatedStorage.Config.SpellbookUIConfig (nuevo): tokens, dimensiones de
  referencia, tipografía y colores de origen; solo datos de presentación.
- UIReskinClient: excepción acotada para SpellbookUI, evitando estilos/escala
  genéricos que sobrescriban la composición específica.
- WindowLayoutClient: coordinación acotada del cierre y drag handle del grimorio;
  mantener foco, arrastre, contención y UIWindowOpen.
- Documentación técnica PROJECT_ARCHITECTURE y DATA_SCHEMA, tras implementación.
- Reutilizar iconos SkillConfig. Lista y contadores dependen del snapshot real;
  seis tarjetas es el estado de referencia, no un número forzado ni un límite.

================================================================================
3. FUERA DE ALCANCE (NO en esta HU)
================================================================================
- Balance, SkillService, TalentService, DataService, reglas de aprendizaje/spec,
  costes, cooldowns, rangos, fórmulas, persistencia y payloads nuevos.
- Producción/subida de iconos o sustitución de IDs existentes.
- TooltipSystem, tooltips al cursor/tap-hold y panel de información lateral.
- Leyenda, panel de estados, resumen seleccionado o información permanente
  adicional ausente de WUFrU. InfoLabel/ErrorLabel se conservan para feedback
  transitorio de la interacción existente, sin ocupar una columna de detalles.
- Mostrar habilidades de talento no aprendidas que el servidor no entrega.
  Conservar los estados bloqueados presentes en el snapshot actual.
- Drag/drop de skills R6.32, rediseño de HUD o del árbol de talentos.
- Editar HUs/GDD canónicos; la nota de cierre de producto corresponde al PM.
- Publicación de places. La propagación/QA se registra por separado del reskin.

================================================================================
4. CRITERIOS DE ACEPTACIÓN (DEFINICIÓN DE HECHO)
================================================================================
1. Con seis skills entregadas, PC replica WUFrU: título de libro, personaje,
   página, seis tarjetas, filtros y barra equipada inferior; sin columna lateral. En PC se ven cuatro tarjetas a la vez y el resto por scroll.
2. Título "GRIMORIO DE <nombre>" y línea clase/spec/nivel usan el personaje real.
   Lista/contador muestran las skills del snapshot, sin texto demo quemado.
3. Tarjetas muestran nombre, tipo, stat, coste, CD, rango/radio, origen, escalado
   aplicable y asignación exacta, derivados de SkillConfig/TalentConfig/loadout.
4. Dorado identifica habilidades por nivel, azul talentos intermedios y morado
   capstones; esta clasificación visual no modifica disponibilidad/gameplay.
5. Barra equipada contiene cuatro slots con teclas 1–4, icono legible sin
   deformación, nombre, MP/CD reales y estado de selección. Slot vacío es explícito.
6. Todas / No asignadas filtran localmente; los contadores se actualizan tras
   respuesta autoritativa. Asignar/desasignar conserva el contrato R5.1.
7. Skills bloqueadas del snapshot no se asignan. El servidor conserva la última
   palabra; rechazos muestran el error vigente sin falsificar el loadout.
8. PC y touch horizontal/retrato mantienen fuentes legibles, scroll, cierre
   contenido en header y controles utilizables; el layout móvil no sobrescribe PC.
9. Apertura P/micro menú, cierre, cámara, foco, arrastre y acceso móvil funcionan
   como antes. No se añaden tooltips ni paneles de selección.

================================================================================
5. IMPLEMENTACIÓN TÉCNICA
================================================================================
Jerarquía y responsabilidades:
- Conservar SpellbookUI.MainFrame y sus Title, CloseButton, SkillList,
  BarPreview, InfoLabel y ErrorLabel. Conservar BarSlot1–4 y referencias actuales.
- Añadir decoración/página y labels sin mover instancias consumidas por otros
  scripts a rutas incompatibles. La decoración no intercepta input.
- Desactivar presentación EST-17 de TooltipFrame, StatesFrame y Footer; quitar
  su dependencia visual manteniendo intactos los handlers de red.
- SpellbookClient es dueño de escala/composición interna; WindowLayoutClient
  sigue gestionando posición, foco y arrastre, con excepción específica de cierre.
- UIReskinClient omite estilos genéricos dentro de SpellbookUI y conserva safe
  area. Cambios acotados por nombre de GUI, sin modificar otras ventanas.

Referencia visual (unidades del diseño, convertidas a Scale):
- WUFrU 680×890, fondo #15100D, borde #C89445, radio 14.
- Encabezado título (34,22), personaje (34,52); cierre sobre header con el estilo EST-16 de Talentos: X/GothamBold, color y borde compartidos, tamaño cuadrado 38 px PC / 44 px touch.
- Página (22,82), 636×660, #241B16, borde #6B4A2B, radio 12.
- Header de página HABILIDADES y contador; regla de 600×1 en (18,64).
- Filtros (18,34), 270×26, #171311; activo #C89445, inactivo #3A302A.
- Tarjetas 600×96 en (18,70), separación de 2 unidades; base #171311, borde
  #6B4A2B, radio 8; strip lateral 4×96 y tile negro #0E0D0C de 56×56.
- Nombre pergamino #F4EDE0, mínimo 11 bold; coste #B7C7D3, mínimo 8.5.
  Tipo/origen/asignación respetan posiciones, colores y jerarquía de WUFrU.
- Capstone usa el tratamiento WUFrU #30271F/borde #B48ADE. Hover/selección
  enfatiza borde; iconos conservan su arte y fondo negro sin tintado global.
- Barra (22,758), 636×112, #211916, borde dorado; heading y cuatro slots de
  referencia 140×72 en fila. Icono fill con Crop proporcional; tecla, nombre y coste superpuestos por encima, en tamaños legibles y sobre una banda oscura.
- Fuentes vía UITheme/EST-13: Playfair Display→PlayfairDisplay para título;
  Inter→Inter/GothamSSM para cuerpo; Geist Mono→RobotoMono para datos.

Datos y presentación:
- Consumir SpellbookData.skills/loadout/classId/specId. Leer CharacterName y
  nivel replicado; ClassConfig proporciona nombres públicos de clase/spec.
- SkillConfig.Get(skillId) proporciona name/iconId/type/manaCost/cooldown,
  stat/coefficient/damageBase, range/allyRange/aoeRadius/maxCastRange.
- Origen de talento: buscar skillId en ramas/nodos de TalentConfig, usando
  nombre de rama y posición real para Tier 2/Capstone; restantes usan clase/spec
  y levelReq reales. No inferir origen desde description ni quemar nombres demo.
- Colores en SpellbookUIConfig según categoría de origen aprobada. No agregar
  campos rarity al perfil ni alterar RarityConfig de ítems.
- Mostrar rangos aplicables (distancia, radio/alcance de lanzamiento o propio);
  escalado desde la fórmula configurada, con unidades por tick cuando aplique.
- Asignación deriva de todos los índices del loadout; no asumir unicidad de una
  skill ni cambiar la política de duplicados del servidor.
- Contador de conocidas corresponde a canUse; filas bloqueadas del snapshot se
  conservan con estado explícito. Filtros afectan solo la vista, no el snapshot.
- Todas muestra la lista entregada; No asignadas excluye las skills presentes en
  loadout. No introducir skills ajenas a la spec ni nodos no aprendidos.

Contratos de red existentes, sin modificaciones:
- RequestSpellbook C→S: sin payload; solicita snapshot.
- SpellbookData S→C: {skills={skillId,name,iconId,type,levelReq,cooldown,
  manaCost,description,canUse,specId},loadout,classId,specId}.
- RequestAssignBarSlot C→S: {slot=<1..4>,skillId=<id>}; limpiar usa skillId="".
  Usar slot del código vigente, no slotIndex del ejemplo desactualizado de R5.1.
- BarSlotAssigned S→C: {success,slot,skillId} o {success=false,error}.
- LoadoutData S→C: {loadout}, consumido por la barra HUD existente.
- Conectar desasignación mediante activación de la skill ya asignada al slot
  seleccionado: enviar skillId="". Mismo patrón PC/touch sin nuevo botón visual.
- Actualizar presentación tras respuesta del servidor; no mutar persistencia ni
  disponibilidad en cliente. Servidor valida personaje activo, slot, skill/spec
  disponible y nivel, y persiste por su flujo actual.

Responsive y control de archivos (respuesta a DEV_PROMPT):
- Archivos: SpellbookClient, SpellbookUI, nuevo SpellbookUIConfig y excepciones
  de grimorio en UIReskinClient/WindowLayoutClient; docs técnicos afectados.
- PC usa marco compacto 680/793 dentro del área segura, alto 0.74 del viewport;
  UIAspectRatioConstraint en libro/iconos y medidas Scale. Título, filtros y
  lista quedan en bandas separadas; la X queda fuera del recuadro. Cuatro filas
  visibles y scroll para las demás, sin sección vacía.
- Touch horizontal usa un marco más ancho y compacto. Título, filtros y lista
  ocupan bandas separadas, la X queda fuera del recuadro y se ven cuatro filas.
  Lista y barra equipada quedan juntas, sin sección vacía. Portrait conserva la
  adaptación touch; ScreenOrientation del juego es landscape.
- Distinguir entrada táctil del escritorio híbrido; recalcular por viewport y
  señales de input/orientación, restaurando la composición PC al volver.
- Cierre comparte el estilo X del panel de Talentos (EST-16); tamaño cuadrado 38 px PC / 44 px touch, contenido en header. Drag handle excluye cierre/filtros/controles.
- Señales y task.defer/task.spawn/task.wait; prohibido wait() y polling infinito.
  Preservar conexiones de apertura/cierre/UIWindowOpen y restauración de acceso.

================================================================================
6. INTEGRACIÓN
================================================================================
- R5.1 sigue siendo autoridad de aprendizaje/loadout; R3 conserva casteo y HUD.
- Reutilizar UITheme, SkillConfig, TalentConfig, ClassConfig e iconos existentes.
- Apertura P y MicroMenuAction="Spellbook" conservan contratos y cámara normal.
- El nuevo diseño supera visualmente EST-17/GDD §23; contratos se preservan.
- R6.27 aporta legibilidad/iconos; TooltipSystem queda excluido por decisión PO.
- Hub es fuente. Dungeon_Helada consume los mismos clientes/config/UI de jugador;
  sincronizar después de QA siguiendo el flujo de copia derivada del proyecto.

================================================================================
7. OPTIMIZACIÓN
================================================================================
- Separar tokens/dimensiones de datos/gameplay; sin duplicar servicios.
- Generar filas desde snapshot, reutilizar helpers de presentación y conectar
  handlers una vez; limpiar conexiones/filas al reconstruir.
- Señales de tamaño/atributos/remotes; filtrar sin tráfico de red adicional.
- No cargar lógica de skills, TooltipSystem o drag/drop de otra HU.
- Mantener iconos existentes y no crear assets decorativos si UI nativa basta.

================================================================================
8. DEFINICIÓN DE HECHO (VERIFICACIÓN)
================================================================================
[x] RC aprobado explícitamente antes de modificar código de producción.
[x] Comparación visual WUFrU en PC con seis skills; captura Play Solo
    2026-10-09 confirma header, página, cuatro filas visibles con scroll, filtros y cuatro slots.
[x] Datos reales de Paladín Castigo: básicas, nivel y talento intermedio/capstone,
    iconos, tipo, coste/CD, rango/escalado, origen y asignación observados.
[ ] Datos reales de las otras clases/specs, lista vacía y habilidades bloqueadas.
[x] Filtro No asignadas muestra 2/6 skills y Todas restaura 6/6 en Play Solo.
[ ] Asignación/desasignación en Play Solo; combate/reapertura y respuesta negativa.
[x] QA visual móvil horizontal (iPhone 17 Pro, 750×381): marco 360×245 px,
    título/filtros/lista separados, X fuera de página y cuatro filas completas.
[x] QA visual PC (1712×753): marco 478×557 px, título/filtros/lista separados,
    X fuera de página, cuatro filas completas y 6 px al pie; Play Solo 2026-10-09.
[ ] QA móvil restante: scroll/interacciones, cierre, safe area y retorno PC.
[x] No se observaron errores nuevos del grimorio. Output muestra un error
    preexistente ajeno: InventoryClient:910, nil en GetAttributeChangedSignal.
    Output no queda limpio y no se atribuye el error a esta HU.
[x] Sin modificaciones de servicios, balance, remotes ni esquema persistente.
[x] Actualizar PROJECT_ARCHITECTURE/DATA_SCHEMA con presentación y contratos;
    reportar al PM la nota GDD pendiente, sin editar documento canónico.
[ ] Sync places: SpellbookClient, SpellbookUIConfig, SpellbookUI,
    UIReskinClient y WindowLayoutClient; Hub 84186294312317 → Dungeon_Helada
    125210265978348. Verificar identidad de Source/versión y jerarquía, y flujo
    de grimorio/loadout tras teleport PC/touch. Si falta place conectado,
    registrar sync pendiente y no marcar entrega cross-place completa.
[ ] Sync cross-place Hub→Dungeon_Helada, MicroMenu/drag/foco y restante QA;
    mantener EN IMPLEMENTACIÓN hasta cerrar los criterios y sincronizar.

================================================================================
9. ESTIMACIÓN
================================================================================
2 sesiones orientativas: composición del libro/tarjetas y barra/estados/QA.
Supuesto: iconos existentes accesibles; sync consumidor sujeto a disponibilidad.

================================================================================
10. DEPENDENCIAS
================================================================================
- HU-ESTETICA-42 y frame WUFrU aprobado, inspeccionado vía Pencil.
- EST-17/EST-13, R5.1/R3, R6.27 en legibilidad e iconos, SKILL_CATALOG vigente.
- UITheme, SkillConfig, TalentConfig, ClassConfig y remotes existentes.
- Tres decisiones de alcance del usuario aprobadas y registradas en header.
- Aprobación explícita de rc082 recibida el 2026-10-09.
- Pendiente operativo de cierre: conexión de Dungeon_Helada para sync/QA.

================================================================================
FIN DEL REQUERIMIENTO
================================================================================
--]]
