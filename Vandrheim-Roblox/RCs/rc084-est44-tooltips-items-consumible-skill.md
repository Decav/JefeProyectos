--[[
================================================================================
          REQUERIMIENTO TÉCNICO: rc084 — FASE ESTÉTICA-44 (HU-ESTETICA-44)
================================================================================
Proyecto: Vandrheim — RPG/MMO-like en 3ª persona (Roblox).
Fuente: HU/estetica/HU-ESTETICA-44-Tooltips-Items-Consumible-Skill.md;
HU-R6.27 §4–6; Pencil Vandrheim-design.pen, frame rIOiC;
GDD §17.1 (EST-14 / tokens y fallback nativo).
Estado: EN IMPLEMENTACIÓN (Hub aplicado; QA táctil y sync Dungeon pendientes).
Requisitos previos: EST-13, EST-39, R6.27/rc073; compatibilidad R6.32/rc083.
Fecha de emisión: 2026-10-10.

================================================================================
1. DESCRIPCIÓN
================================================================================
El jugador puede consultar stats, requisitos, efectos y escalado mediante las
tres plantillas entregadas en Pencil: item_equipable, item_consumible y skill.

Objetivo de la fase: trasladar las tres referencias al TooltipSystem cliente
de R6.27, centralizando presentación, anclaje y ciclo de vida. La HU es un
registro de diseño ENTREGADO; no demuestra que la implementación esté completa.
La interpretación como integración dev de esas tres plantillas requiere la
aprobación indicada en §10.

Criterio de hecho global de la HU: existen los tres diseños con contenido
canónico, tokens y puntero, verificados por el PO. Para esta integración:
las tres plantillas funcionan en Studio con datos reales, mantienen fidelidad
al Pencil y son utilizables con ratón y touch sin romper las acciones existentes.

================================================================================
2. ALCANCE (SÍ)
================================================================================
Integración dev aprobada:
- Un TooltipSystem cliente para las tres plantillas de EST-44.
- Equipables y consumibles de mochila/equipo; consumibles en slots de uso;
  habilidades del grimorio y de la barra de habilidades.
- Hover en PC y pulsación prolongada en móvil; puntero hacia el origen,
  adaptación al espacio disponible y ocultación al invalidarse el origen.
- Nombre, rareza/slot, stats de texto, vinculación, nivel requerido y set real
  para equipables; efecto real para consumibles; coste, reutilización, alcance,
  efecto y escalado reales para habilidades.
- Coordinación con selección, uso, casteo, asignación, scroll y drag-drop.
- Eliminar la barra de botones del tooltip antiguo. Las tres tarjetas son
  únicamente informativas; no trasladar los botones a otro contenedor.
- Documentación técnica y propagación a los places consumidores según §8.

================================================================================
3. FUERA DE ALCANCE (NO en esta HU)
================================================================================
- Plantillas talento, vendor_item, party_member, loot_item y stat.
  VendorClient conserva su comportamiento actual; su migración queda pendiente.
- Comparación nueva de equipo/deltas y paneles adicionales no entregados en EST-44.
  Las obligaciones restantes de R6.27 no se declaran completas por este RC.
- Cambios de balance, cooldowns, daño, curación, requisitos o reglas de sets.
- Cambios de persistencia, loot, economía, restricciones o remotos de gameplay.
- Rediseño del árbol de talentos, del grimorio, del inventario o del HUD.
- Producción de iconos, nuevo arte o publicación de assets sin entrega autorizada.
- Edición del Pencil o de documentos canónicos del producto.

================================================================================
4. CRITERIOS DE ACEPTACIÓN (DEFINICIÓN DE HECHO)
================================================================================
1. Las tres plantillas corresponden a los diseños del frame rIOiC:
   Tooltip_Item_Espada_Campeon, Tooltip_Consumible_Pocion_HP y
   Tooltip_Skill_Anillo_Luz. Los ejemplos ilustran el diseño, no son datos fijos.
2. Equipable: nombre, rareza·slot, stats de texto sin Icon_Stat_*, vinculación
   coherente y levelReq real. El ejemplo épico de nivel 16 indica nivel 16.
3. Equipable de set: nombre y piezas equipadas /5, progreso, bono activo verde
   y siguiente/inactivo pergamino, según reglas reales de clase/spec/tier.
   No se marca activo un bono únicamente por tener tres o cuatro piezas.
4. Consumible: nombre, rareza·CONSUMIBLE y EFECTO verde. No incluye una línea
   de cooldown. Muestra solo los recursos/porcentajes que restaura ese ítem.
5. Habilidad: nombre, tipo, coste MP, reutilización, radio/rango real,
   descripción/efecto y escalado. Anillo de luz sagrada presenta sus valores
   vigentes de config: 25 MP, 10 s y radio 6 studs, salvo modificadores activos.
6. BuilderSans en todas las líneas conforme a la instrucción vigente del usuario.
   Nombre >=11 bold, detalles >=9, stats >=10 bold; legibles sin solaparse.
7. Fondo #171311; progreso #3A302A/#C89445; jerarquía, bordes, colores y espaciado
   derivados del Pencil. Sin botones ni secciones informativas nuevas dentro
   de las tarjetas. Puntero visible hacia el origen.
8. Hover PC y hold móvil muestran la tarjeta; se ajusta al viewport, incluidos
   bordes/esquinas, texto largo y pantallas pequeñas; no queda cortada.
9. Un hold informativo no usa un consumible ni lanza una habilidad al soltar.
   Tap corto, hotkeys, selección, scroll y drag-drop mantienen su función.
10. No hay tooltip duplicado, contenido residual ni conexiones acumuladas al
    cerrar/reabrir paneles, cambiar personaje o regenerar filas/slots.

================================================================================
5. IMPLEMENTACIÓN TÉCNICA
================================================================================
5.1 Scripts según mapa de responsabilidades — respuesta de control DEV_PROMPT
Crear:
- ReplicatedStorage.Config.TooltipConfig (ModuleScript): tokens, medidas
  proporcionales, etiquetas y parámetros de interacción aprobados.
- ReplicatedStorage.Shared.TooltipData (ModuleScript): proyección informativa
  de snapshots/config a las tres plantillas; sin acciones de gameplay.
- ReplicatedStorage.Shared.TooltipSystem (ModuleScript, uso cliente):
  instancia visual única por jugador, Show/Hide/Bind/Unbind, anclaje/puntero,
  medición de contenido y arbitraje del gesto informativo.

Modificar:
- StarterPlayer.StarterPlayerScripts.InventoryClient:
  datos/orígenes de mochila/equipo, selección y coordinación con drag-drop.
- StarterPlayer.StarterPlayerScripts.InventoryPresentationClient:
  eliminar la creación de la barra de acciones del tooltip legado;
  conservar el panel de detalle y los gestos existentes ajenos al tooltip.
- StarterPlayer.StarterPlayerScripts.SpellbookClient:
  vínculo por skillId y coordinación con su drag-drop R6.32.
- StarterPlayer.StarterPlayerScripts.SkillBarClient:
  vínculo por skillId asignado y bloqueo de Activated consumido por hold.
- StarterPlayer.StarterPlayerScripts.ItemUseSlotsClient:
  vínculo por templateId del slot y bloqueo de uso consumido por hold.
- StarterPlayer.StarterPlayerScripts.UIReskinClient: solo si su pasada genérica
  alcanzase el nuevo tooltip; excluirlo para que TooltipSystem sea dueño visual.
- Workspace.DevelopmentStandard.PROJECT_ARCHITECTURE y DATA_SCHEMA cuando
  corresponda: contratos locales, propietarios e integración final.

No se modifica VendorClient ni el comportamiento servidor de InventoryService,
SkillService o ItemConfig/SkillConfig. TooltipSystem no se requiere en servidor.

5.2 Contratos y datos
- API cliente conceptual:
  Show(entityType, data, origin), Hide(owner), Bind(origin, provider, callbacks),
  Unbind(origin). Tipos admitidos: item_equipable, item_consumible, skill.
  Bind devuelve limpieza; callbacks permiten cancelar/suprimir acciones de
  input existentes, sin invocarlas desde Show.
- No remotos nuevos. Reutilizar snapshots existentes de inventario/equipo,
  slots, habilidades y atributos replicados del personaje.
- IDs/instancias de ítems y skillId son identidad; no buscar datos por texto.
- Stats de instancia prevalecen sobre rangos de template; CRIT fraccional se
  formatea como porcentaje. No presentar una tirada aleatoria como stat real.
- Nivel: levelReq de template/snapshot; un dato ausente no se inventa como 16.
- Vinculación: respetar BindType y bindState. BoE libre: "Se liga al equipar";
  ligado: estado real. No etiquetar un ítem libre como ya vinculado.
- Set: contar equipo único por instanceId y consultar GetSetBonus;
  aplicar bonusesEnabled, clase y spec vigentes. Omitir bloque en ítems sin set;
  no rellenar con los textos ni el conteo 3/5 de la maqueta.
- Consumible: usar acción, porcentaje y duración reales de ItemConfig.
  HealHP no se presenta como restauración de HP y MP. Sin línea CD en la tarjeta.
- Skill: SkillConfig vigente y modificadores replicados que ya utiliza el juego.
  Separar radio aoeRadius, distancia maxCastRange/range/allyRange y duración
  cuando aplican. Para autocast sin distancia, indicar objetivo propio.
  Fórmula real damageBase + coefficient*stat; distinguir daño, cura y absorción,
  y daño por pulso frente a daño instantáneo. No prometer daño final tras DEF.
  No mostrar "-" ni fabricar un rango. No persistir resultados informativos.

5.3 Presentación y plataformas
- TooltipSystem es único dueño de las nuevas tarjetas; no clonar tooltips
  independientes por fila. El SharedUI.Tooltip legado sigue disponible para
  Vendor mientras su plantilla quede fuera de alcance.
- PC: hover del origen, posición próxima al cursor; flip y clamp al espacio
  útil del viewport; puntero orientado al origen, separado del contenido.
- Mobile: propuesta §10 basada en hold 0.30 s y tolerancia 8 px ya existentes
  en R6.32. Hold inmóvil muestra tooltip; mover después del hold inicia el
  arrastre existente y oculta tooltip. Movimiento previo cancela hold y deja
  scroll/gesto vigente. Tap corto conserva su acción. Release tras hold
  consume la activación correspondiente y oculta tooltip.
- Arbitrar según InputObject/UserInputType; TouchEnabled no debe desactivar
  mouse/teclado en equipos híbridos.
- Recalcular ante cambios de viewport, contenido o posición del origen.
  Ocultar en drag/scroll, cierre, origen destruido, cambio de datos o personaje.
- Crear tamaño/posición con Scale; UIAspectRatioConstraint en partes críticas.
  Medir texto envuelto y adaptar altura; evitar TextScaled que reduzca letras
  por debajo de mínimos. Respetar safe area/insets y orden visual.
- No asset 9-slice vigente identificado en ASSETS_LIST. Propuesta: fallback
  nativo permitido por GDD §17.1, con UICorner/UIStroke y puntero, preparado
  para ImageLabel Slice cuando exista ID y márgenes registrados. No inventar ID.
- Server-authoritative: tooltip solo lee; equipar/usar/asignar/eliminar/castear
  conservan los remotos y validaciones actuales del servidor.
- task.wait/task.delay/task.spawn; prohibido wait(). No bucles while true.

================================================================================
6. INTEGRACIÓN
================================================================================
- EST-13: tokens, geometría y eventual handoff 9-slice; EST-39: assets vigentes,
  aunque los stats en estas tarjetas no emplean iconos.
- EST-44/rIOiC es la referencia visual de estas tres tarjetas.
- R6.27/rc073 aporta datos reales y objetivo de centralización; las plantillas
  adicionales y migración Vendor no se cierran por esta entrega.
- R6.32/rc083 aporta drag-drop; se conserva contrato servidor y destino de drops.
- EST-41/42: no insertar tooltip de talento ni modificar distribución de paneles.
- BuilderSans prevalece sobre Playfair/GeistMono/Inter utilizados en la maqueta.
- La migración evita que estilos genéricos y controladores legados escriban
  simultáneamente sobre las nuevas tarjetas.

================================================================================
7. OPTIMIZACIÓN
================================================================================
- Una tarjeta visible y un arbitraje de input compartido; instancias reutilizadas.
- Conectar señales únicamente a orígenes activos; limpiar al regenerar UI.
- Cancelar timers de hold con tokens al liberar, mover o destruir el origen.
- Medir/formatear al cambiar datos o viewport; no recalcular todo cada frame.
- RenderStepped solo temporal si el seguimiento del cursor lo necesita.
- Sin replicación extra, escaneo constante del DataModel ni nuevos sistemas
  de inventario/combat/caché persistente.

================================================================================
8. DEFINICIÓN DE HECHO (VERIFICACIÓN)
================================================================================
[x] Aprobación explícita del RC; corrección posterior: sin botones en tooltips.
[ ] Comparación visual de las tres tarjetas con rIOiC, en PC y mobile.
[ ] Play Solo: mochila, equipo, slots consumibles, grimorio y barra de skills.
[ ] Datos: stats con rolls/afijos, CRIT, BoE/Bound, nivel requerido distinto de 1;
    set con 0/3/4/5 piezas, clase/spec incompatibles y tier sin bonus activo.
[ ] Skills: Instant, SelfAoE, GroundAoE, DoT, Heal y Shield; costes,
    distancias, duración/pulsos y escalado coherentes con configuración vigente.
[ ] Consumibles HP, MP y buffs: efecto correcto; sin línea CD en tarjeta.
[ ] Interacción: hover, salida, tap, hold, release, scroll y drag-drop;
    click/hotkeys normales; hold no dispara RequestUseItemSlot ni cast.
[ ] Bordes y esquinas, resoluciones PC/mobile, safe area, texto largo,
    paneles arrastrables, cierre/reapertura y cambio de personaje.
[ ] Drag-drop, hotkeys y acciones del panel de detalle conservados; no botones
    en las tarjetas ni contenedor nuevo con botones del tooltip.
[ ] Sin errores rojos ni duplicación del tooltip; no remotos de gameplay
    emitidos por consultar información.
[ ] PROJECT_ARCHITECTURE actualizado; DATA_SCHEMA solo si corresponde.
    No modificar GDD ni HUs; registrar cierre en RC/documentación técnica.
[ ] Sync obligatorio: Hub (84186294312317) es fuente; Dungeon_Helada
    (125210265978348) es consumidor. Propagar TooltipConfig, TooltipData,
    TooltipSystem y cada cliente modificado listado en §5.1; verificar Source
    o versión/hash idénticos y ejecutar QA de consulta tras teleport.
[ ] Registrar por place qué se sincronizó/verificó. Actualmente solo Hub
    está conectado; Dungeon y QA cross-place quedan pendientes hasta acceso.
    No marcar COMPLETO mientras falte esa propagación/verificación.
[ ] Multiplayer: recomendado para cambio de personaje/equipo/sets sin
    compartir UI entre jugadores; registrar evidencia si se realiza.

================================================================================
9. ESTIMACIÓN
================================================================================
HU de diseño: N/A, entrega realizada. La HU no estima integración dev.
La implementación se estimará tras cerrar §10; sin compromiso de fecha.

================================================================================
10. DEPENDENCIAS
================================================================================
HU-ESTETICA-13, HU-ESTETICA-39, HU-ESTETICA-44/Pencil rIOiC,
HU-R6.27/rc073, R6.32/rc083, UITheme y configs/snapshots actuales.

Decisiones aprobadas por el usuario; P3 corregida explícitamente:
P1. La HU está ENTREGADA como registro del diseñador. Propuesta: esta tarea
    integra solo sus tres plantillas en los orígenes §2; otros tipos de R6.27
    y Vendor quedan pendientes. Confirmar alcance dev con aprobación del RC.
P2. Hold táctil y drag-drop compiten por 0.30 s. Propuesta: hold inmóvil muestra
    tooltip; movimiento posterior >8 px inicia drag y lo oculta; release tras
    hold no activa uso/cast. Tap corto y scroll mantienen comportamiento.
P3. Corrección del usuario: quitar los botones del tooltip; no trasladarlos.
    Eliminar ActionBar (Usar, Equipar/Desequipar, Eliminar) del tooltip antiguo.
    El panel de detalle y los gestos previos fuera del tooltip permanecen.
P4. Falta asset 9-slice registrado. Propuesta: fallback nativo de GDD §17.1
    hasta entrega de asset, manteniendo colores/bordes/puntero de Pencil.

Conflictos advertidos, sin cambiar reglas:
- La HU afirma ausencia de CD de poción, pero InventoryService y
  ItemUseSlotsClient implementan cooldown compartido 30 s. La tarjeta omite
  la línea CD según el diseño; gameplay y overlay actual se conservan.
- La poción de ejemplo restaura HP y MP; configs vigentes tienen acciones HP
  o MP separadas. Mostrar efecto real, no copiar el texto demostrativo.
- Las fuentes originales de Pencil difieren de la instrucción reciente del
  usuario: usar BuilderSans en todas las tarjetas.

================================================================================
REGISTRO DE IMPLEMENTACIÓN — 2026-10-10
Hub (84186294312317): aplicados TooltipConfig, TooltipData, TooltipSystem y
InventoryClient, InventoryPresentationClient, SpellbookClient, SkillBarClient,
ItemUseSlotsClient, UIReskinClient. Los nueve sources compilan.
Eliminado ActionBar del tooltip legado; sin trasladar botones.
PROJECT_ARCHITECTURE y DATA_SCHEMA actualizados con contratos locales.

Evidencia: última sesión Play inicializa clientes sin errores registrados;
tarjetas renderizadas con BuilderSans; siete consumibles; seis tipos de skill;
sets 0/3/4/5, clase incompatible e identidad duplicada; cero GuiButtons.
Contenido largo: 60 filas, canvas 1283 px, tarjeta 625 px; filas de 16 px
y separación de 21 px conservadas. Corregido estiramiento por CanvasSize
detectado durante la primera prueba de overflow.
Las pruebas usaron fixtures informativos temporales; no alteraron perfil,
balance ni reglas. Eliminadas al detener Play.

Pendientes de verificación: gesto touch real/emulado completo (hold,
scroll, arrastre y release sin activar), recorridos completos PC de acciones,
multiplayer y cross-place. El MCP de input disponible no expone touch.
La automatización de hover no produjo evidencia concluyente en todas las
superficies; no declarar recorrido completo verificado.

Dungeon_Helada: sin sincronizar. El usuario respondió que no abrirá ese place;
se difiere su propagación. Mantener EN IMPLEMENTACIÓN hasta cerrar pendientes.
Fuentes antes/después y reporte: implementation/rc084 del repositorio local.

================================================================================
FIN DEL REQUERIMIENTO
================================================================================
--]]

