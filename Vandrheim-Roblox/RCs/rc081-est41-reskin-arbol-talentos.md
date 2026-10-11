--[[
================================================================================
          REQUERIMIENTO TÉCNICO: rc081 — FASE EST-41 (HU-ESTETICA-41)
================================================================================
Proyecto: Vandrheim — RPG/MMO-like en 3ª persona (Roblox).
Fuente: HU/estetica/HU-ESTETICA-41-Reskin-Arbol-Talentos-Dev.md
        + GDD_ROBLOX_MVP §§4 (talentos/spec/respec), 17 (assets).
Referencia visual: Vandrheim-design.pen, Xff5t,
                   "D · WoW-inspired talent tree" (aprobado por PO).
Estado: EN IMPLEMENTACIÓN (aprobado por el PM; aclaración de alcance aplicada).
Fecha de emisión: 2026-10-09.
Requisitos previos: R5; EST-13; EST-16; iconos EST-40 entregados;
                   R6.27 únicamente como referencia de legibilidad.
Corrección de alcance del usuario (2026-10-09): excluir tooltips/TooltipSystem;
se resolverán en una HU futura. Se conserva únicamente la composición visible de
Xff5t; no se añade panel lateral ni detalle adicional de selección.
Documentación consultada: DEVELOPER_GUIDE, PROJECT_STANDARD,
PROJECT_ARCHITECTURE, DATA_SCHEMA, ASSETS_POLICY, ASSETS_LIST, RC-TEMPLATE;
HU-ESTETICA-13, HU-R6.27 y referencia Xff5t mediante MCP pen.dev.
Place fuente: Hub 84186294312317. Consumidor: Dungeon_Helada 125210265978348.

================================================================================
1. DESCRIPCIÓN
================================================================================
Rediseñar la presentación del árbol para que coincida con la composición visible
de Xff5t: header, tabs, tres ramas y sus tarjetas, gates, rangos y cierre. Mantener
solo el contenido de talentos de la referencia; no agregar información o paneles.

Objetivo de la fase: sustituir la presentación EST-16 y enlazar los iconos
entregados; conservar el flujo R5 de apertura, selección de spec y gasto.
Criterio de hecho global: "El panel de talentos replica la composición visible de
Xff5t, con los estados del servidor y adaptación móvil, sin alterar la lógica R5."

Hallazgos previos: TalentClient utiliza glifos, tarjetas EST-16 y un tooltip
propio; ofrece respec dentro del árbol. Sus tamaños touch superan 85% del
viewport. UIReskinClient/WindowLayoutClient pueden sobrescribir su presentación.
TooltipSystem no está presente; su implementación queda fuera por indicación
expresa del usuario. El reskin no crea un tooltip alternativo.
La regla explícita EST-41 sustituye el flujo visual de respec del árbol.

================================================================================
2. ALCANCE (SÍ)
================================================================================
- StarterGui.TalentUI/MainFrame: header, badge de puntos, tabs, tres ramas,
  tarjetas de talentos, conectores, gates, rangos y cierre, según Xff5t.
- StarterPlayer.StarterPlayerScripts.TalentClient: presentación y conexión de
  datos existentes al reskin; conservar acciones de gasto.
- ReplicatedStorage.Config.TalentUIConfig nuevo: tokens, iconos y ajustes de
  presentación, separados de TalentConfig.
- Ajustes acotados a TalentUI en UIReskinClient y WindowLayoutClient para que
  respeten el nuevo layout/estilo y mantengan OrdenUI, drag y ventana activa.
- Retirar botón y flujo de respec de la experiencia visible del árbol; mantener
  RespecButton oculto/no interactivo para compatibilidad de jerarquía.
- Actualizar documentación técnica del config/presentación y evidencia QA.

================================================================================
3. FUERA DE ALCANCE (NO en esta HU)
================================================================================
- Balance, nuevos talentos, gates, costes, ranks, puntos o reglas de spec.
- Cambios en TalentConfig, TalentService, SkillService o VendorService.
- Cambios de contrato de remotes, persistencia, esquema del personaje o economía.
- Rediseño del Instructor o cambio de su respec: sigue siendo su flujo con oro.
- Producción, regeneración o subida de iconos EST-40.
- Tooltips de cualquier tipo, incluida la plantilla talento: creación de
  TooltipSystem, API show/hide, migración o mejoras de tooltips. Se harán en
  una HU futura dedicada, según indicación explícita del usuario.
- Modificaciones de HUs/GDD o de otras pantallas, boss, combate y assets 3D.
- Publicación de places como parte de la emisión del RC.

================================================================================
4. CRITERIOS DE ACEPTACIÓN (DEFINICIÓN DE HECHO)
================================================================================
1. Comparado con Xff5t, el árbol reproduce únicamente header/badge, tabs, tres
   ramas con tarjetas, conexiones/gates, rangos y cierre. Los nombres de clase,
   specs y ramas son dinámicos; Paladín es solo un ejemplo.
2. Disponible, bloqueado, aprendido, máximo y seleccionado se distinguen con
   los datos reales recibidos, sin desbloqueos ni puntos inventados.
3. Cada tarjeta del árbol presenta nombre, icono, efecto y rank/pips reales;
   gates y estados corresponden al snapshot. La selección conserva el feedback
   visual propio de Xff5t. No se abre ni se añade panel de información.
4. Apertura/cierre, tecla T, MicroMenu/Trainer, selección inicial de spec y gasto
   conservan su funcionamiento. El servidor valida todo; el árbol no ofrece
   respec y el Instructor conserva REENTRENAR con el coste configurado.
5. PC y móvil conservan acceso a ramas y talentos sin cortes ni solapamientos;
   el árbol queda dentro del 85% del viewport seguro. Título/nombres >=9 px
   efectivos, efectos >=7 e iconos de nodo aproximadamente 40 px legibles.
6. Los iconos existentes se cargan desde config; ninguna imagen se produce
   nuevamente. Todas las specs usan contenido real y no ejemplos del mockup.
7. No aparecen errores rojos ni regresiones de otras ventanas por los cambios
   acotados de estilo/layout compartido; reapertura no duplica UI/conexiones.

================================================================================
5. IMPLEMENTACIÓN TÉCNICA
================================================================================
5.1 Jerarquía y responsabilidades
Conservar TalentUI.MainFrame y sus referencias Title, PointsLabel, SpecLabel,
NodesContainer, CloseButton, ErrorLabel, RespecButton y UIAspectRatioConstraint.
Conservar nombres dinámicos de ramas/nodos que consumen scripts existentes.
Agregar adornos/controles como hijos sin renombrar contratos existentes.
TalentClient coordina datos y acciones; TalentUIConfig define solo tokens,
iconos y presentación. No almacenar progreso en estos módulos.

5.2 Diseño y estados
Tomar el contenido visible UQVgD de Xff5t como referencia; BkKGE está desactivado
en el diseño. Adaptar su geometría a escala real legible, sin copiar literalmente
545x368 ni reducir texto globalmente al 30%.
Header: clase real, nombre del personaje, nivel, suma de ranks invertidos y
puntos disponibles del snapshot. Singular/plural coherentes.
Tabs: activo #C89445 con texto #15100D, inactivo #3A302A. Mantener navegación
previa a gastar y spec activa posterior; no permitir cambio de spec por un tab.
Tres ramas obtenidas de branchId/branchName. Orden estable del config existente.
Conectores #6B4A2B, bloqueados #52495D. Gates de pointsRequired/levelReq y
prerequisitos reales: >=4 PTS/NIVEL 8 y >=8 PTS/NIVEL 16 solo cuando correspondan.
Nodos circulares: disponible #3A2C25, seleccionado/activo #203340, bloqueado
#171311; candado superpuesto. Pips de rango dorados/azules/morados por rama,
vacíos #3A302A.
Las tarjetas muestran el efecto real de cada nodo. No agregar panel, resumen de
selección o textos estáticos ajenos a Xff5t.
Cierre #3A2525 con icono de pergamino/contraste del diseño.
Reutilizar UITheme (Title/Body/BodyBold/Mono y fallbacks ya establecidos).

5.3 Iconos/config de presentación
TalentUIConfig tendrá tokens/layout e iconos por efecto con override por nodeId.
IDs registrados en ASSETS_LIST, EST-40:
ATK    rbxassetid://89068082294902
MATK   rbxassetid://139893316216189
DEF    rbxassetid://140021244024450
MDEF   rbxassetid://114061430971883
MaxHP  rbxassetid://109280055205927
MaxMP  rbxassetid://133258370924897
CRIT   rbxassetid://93440920540891
CDR    rbxassetid://81743460448421
Skill: reutilizar iconId de SkillConfig para el skillId del nodo.
Propuesta visual: nodo combinado utiliza el primer efecto de un orden explícito
en TalentUIConfig (CRIT antes de CDR); el texto muestra todos los efectos.
Permitir override sin tocar lógica. El genérico de HU es fallback solo si el
dato/imagen falta; registrar fallo, no ocultarlo como icono definitivo.
Sin cambios de TalentConfig ni nuevos IDs de producción.

5.4 Entrada y presentación de las tarjetas
La selección/tap mantiene el feedback visual de la propia tarjeta y conserva el
flujo actual de gasto. No cambia el contrato de compra ni la validación server-side.
Los nodos bloqueados siguen mostrando solo la tarjeta que forma parte del árbol;
no se abre detalle, panel lateral, ventana, tooltip o resumen de selección.
Actualizar rangos y estados de las tarjetas tras respuesta del servidor.

5.5 Responsive y coexistencia
UDim2 Scale y UIAspectRatioConstraint; safe insets. Medir AbsoluteSize y tamaño
de fuente efectivo después de cualquier UIScale. No compensar espacio con
reducción por debajo de los mínimos.
Recalcular por señales de viewport/orientación; apilar y permitir scroll de ramas
en touch estrecho. Conservar todas las ramas y la composición de referencia.
Acotar los guards de UIReskinClient/WindowLayoutClient a TalentUI para evitar
tamaños touch .92/.90 y overrides de header/estilo; otros paneles conservan
su comportamiento. Preservar drag/orden y UIWindowOpen.

5.6 Red y autoridad
Sin remotes nuevos ni cambios de payload:
C→S RequestTalentTree (solicitud actual sin datos de progreso).
C→S RequestSpendTalentPoint {nodeId, specId cuando aplica}.
S→C TalentTreeData (snapshot existente).
S→C TalentPointSpent {success, error, talents según resultado existente}.
Mantener compatibilidad de TalentData/TalentResult donde ya existe.
Conservar RespecResult para refrescar la UI después del Instructor; retirar
RequestRespec del flujo del árbol. RequestRespec del Instructor/server permanece.
Servidor conserva validaciones de puntos/nivel/prerequisitos/spec y persistencia.
Mostrar un estado local no autoriza compras ni altera el personaje.
Si se necesita espera/asíncrono: task.wait()/task.spawn(); PROHIBIDO wait().

================================================================================
6. INTEGRACIÓN
================================================================================
EST-41 sustituye la presentación EST-16; R5 sigue siendo fuente del progreso.
EST-13 aporta tokens/contrato de jerarquía; EST-40 aporta iconos terminados.
R6.27 se consulta para legibilidad. Su integración de tooltips queda diferida
por instrucción del usuario: rc081 no depende de implementar TooltipSystem.
Talentos reciben nodos del serializer actual: antes de elegir spec hay árboles
disponibles; después solo el activo. No cambiar el servidor para llenar ejemplos
o habilitar un cambio de spec que no existe en el flujo actual.
Instructor conserva respec y sus respuestas refrescan el árbol.
Replicar los mismos scripts/config compartidos y TalentUI en Hub/Dungeon según
rc048; comprobar identidad del place antes de aplicar una copia.

================================================================================
7. OPTIMIZACIÓN
================================================================================
- Dos sesiones orientativas; evitar librerías/pantallas no solicitadas.
- Actualizaciones por respuestas de remotes y señales de entrada/viewport,
  sin while true ni RenderStepped para reconstruir la UI.
- Reutilizar renderer y elementos mientras estén abiertos; limpiar conexiones
  al reconstruir/cerrar y no acumular duplicados tras cada TalentTreeData.
- Cachear metadata visual y usar snapshots del servidor para ranks/puntos.
- No implementar infraestructura ni comportamiento de tooltips en esta HU.
- Cambios de guards solo para TalentUI, sin rediseñar infraestructura de ventanas.

================================================================================
8. DEFINICIÓN DE HECHO (VERIFICACIÓN)
================================================================================
[x] RC aprobado antes de modificar código (usuario, 2026-10-09).
[ ] QA visual PC con Xff5t: siete áreas, paleta, iconos reales y cierre.
[ ] QA nodos pasivos/skill/capstone y efectos combinados, ranks/gates/candados;
    revisar todas las clases/specs existentes, antes/después de elegir spec.
[ ] QA gasto permitido/denegado por servidor, errores visibles, reapertura y
    actualización de puntos; sin cambios de TalentConfig/TalentService.
[ ] QA del feedback visual de tarjeta y cierre en PC/móvil; no hay panel lateral,
    detalle de selección, información adicional, tooltip ni gesto tap-hold.
[ ] QA móvil horizontal/vertical, safe area, límite85%, fuentes efectivas y scroll.
[ ] QA tecla T, MicroMenu/Trainer, drag/OrdenUI y convivencia con otras ventanas.
[ ] QA sin respec visible en árbol; respec del Instructor y refresco conservados.
[ ] Sin errores rojos; revisar seguridad y no inventar desbloqueos en cliente.
[ ] Sincronización obligatoria: TalentClient, TalentUIConfig,
    guards TalentUI en UIReskinClient/WindowLayoutClient y jerarquía TalentUI,
    más docs técnicos aplicables: Hub 84186294312317 → Dungeon 125210265978348.
    Registrar files/placeIds/evidencia; no declarar completo con consumidor pendiente.
[ ] QA en ambos places tras sync; si Dungeon no está conectado, documentar
    pendiente y solicitar disponibilidad sin afirmar que quedó sincronizado.
[x] Actualizar PROJECT_ARCHITECTURE/DATA_SCHEMA solo en secciones técnicas
    de presentación; no modificar datos de personaje ni docs canónicos.
[ ] Entregar al PM evidencia y propuesta de nota GDD "EST-41 completo" tras QA.
[ ] RC pasa a COMPLETO solo con criterios y sincronización verificados.

================================================================================
9. ESTIMACIÓN
================================================================================
2 sesiones de dev (orientativo según HU): reskin, tarjetas/estados y QA.
Supone aprobación del RC revisado y disponibilidad de los places para
sincronización. No constituye compromiso de fecha.

================================================================================
10. DEPENDENCIAS
================================================================================
- HU-R5/TalentConfig/TalentService existentes: lógica conservada.
- EST-16: presentación anterior a reemplazar.
- EST-13/UITheme: tokens y jerarquía.
- EST-40/ASSETS_LIST: iconos ya entregados; ninguna producción adicional.
- Xff5t aprobado: leído mediante pen.dev, sin modificar el diseño.
- Corrección explícita del usuario, 2026-10-09: "No, no hagas el tooltip;
  más adelante habrá una HU totalmente enfocada en tooltips". Esta instrucción
  sustituye la integración TooltipSystem de EST-41/R6.27 para la presente entrega.
Los tooltips siguen fuera del alcance aprobado y se reservarán para una HU futura.
- Aclaración explícita del usuario después de aprobar rc081 (2026-10-09):
  conservar el panel de Xff5t tal como está; no agregar información adicional,
  panel lateral con selección o respec. Esta indicación sustituye el detalle de
  nodo que la HU describe. No requiere otra aprobación para la implementación.
- HU futura dedicada a tooltips: fuera del alcance y sin dependencia bloqueante
  para el reskin actual.
- rc048: Hub fuente y Dungeon consumidor. Solo Hub conectado al emitir este RC;
  la sincronización/QA del consumidor sigue pendiente hasta disponibilidad.
- RC aprobado por el usuario el 2026-10-09; aclaración de alcance integrada.
- Implementación aplicada en Hub 84186294312317: TalentClient, TalentUIConfig,
  guardas de TalentUI en UIReskinClient/WindowLayoutClient y RC081.
- Lectura estática posterior confirma que el árbol no crea detalle lateral,
  leyenda, ayuda de selección, tooltip ni interfaz de respec; conserva el estado
  visual en la tarjeta. El lienzo calcula scroll cuando las ramas exceden el área.
- QA en Play no ejecutado. Dungeon_Helada no estaba conectado; sincronización y
  QA allí siguen pendientes. El RC permanece EN IMPLEMENTACIÓN.

================================================================================
FIN DEL REQUERIMIENTO
================================================================================
--]]

