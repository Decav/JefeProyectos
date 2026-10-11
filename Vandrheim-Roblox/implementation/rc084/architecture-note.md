
--[[
================================================================================
HU-ESTETICA-44 / rc084 — TooltipSystem (Hub aplicado, 2026-10-10)
================================================================================
Estado: integración Hub implementada; QA de gestos touch y sync Dungeon pendientes.
El usuario aprobó rc084 y corrigió P3: tooltips solo informativos, sin botones;
no trasladar ActionBar a otro contenedor. Vendor conserva su presentación previa.

Propietarios:
- ReplicatedStorage.Config.TooltipConfig: tokens Pencil rIOiC, BuilderSans,
  mínimos de lectura, ancho adaptable, hold 0.30 s / tolerancia 8 px.
- Shared.TooltipData: proyección de ItemConfig/SkillConfig y snapshots; formato
  stats/CRIT/afijos, BoE, requisitos, sets deduplicados, efectos y alcance.
- Shared.TooltipSystem (cliente): tarjeta reutilizada TooltipUI, puntero,
  layout Scale, scroll para exceso de contenido, Bind/Unbind/Show/Hide y
  arbitraje touch en slots que no tienen drag-drop.
- InventoryClient / SpellbookClient: candidatos externos de drag; hold inmóvil
  consulta, movimiento posterior inicia drag. InputObject identifica el toque,
  sin acceder a TouchId. Tap corto preserva selección/asignación previa.
- SkillBarClient / ItemUseSlotsClient: CanActivate protege Activated después
  de hold o scroll; hotkeys siguen el flujo previo.
- InventoryPresentationClient: se eliminó ActionBar del tooltip legado; el panel
  de detalle de mochila permanece. SharedUI.Tooltip ya no muestra información
  de Inventory/Equipment; sigue disponible para Vendor.
- UIReskinClient excluye TooltipUI para no sobreescribir sus tokens.

Datos:
InventoryData y SpellbookData existentes actualizan contexto y ocultan tarjetas
caducadas. Sets consideran clase/spec/tier y deduplican instanceId. Hasta recibir
spec, se reconoce el efecto activo desde el estado de set serializado en la
descripción por InventoryService; nunca se inventa spec. Skills reflejan CDR
replicado y reglas activas de alcance de set. Sin nuevos remotos ni persistencia.
No se modifica balance ni cooldown servidor de pociones (30 s); esa línea se
omite en la tarjeta según HU. No plantillas de talento/vendor/party/loot/stat.

Assets: fallback UICorner/UIStroke/puntero nativo permitido por GDD §17.1;
TooltipConfig.PanelImage/SliceCenter reservados para asset 9-slice registrado.

QA efectuada: compilación de los nueve sources, arranque Play sin errores
registrados, tarjetas renderizadas, borde viewport, scroll de 60 líneas sin
estirar fuentes/filas, 7 consumibles, 6 tipos de skill, set 0/3/4/5,
clase incompatible y instanceId duplicado; tarjeta sin GuiButtons.
Pendiente: gesto touch real/emulación, recorridos completos de drag/cast/uso,
multiplayer y QA cross-place. No declarar rc084 COMPLETO.

Sync: Hub 84186294312317 fuente; Dungeon_Helada 125210265978348 consumidor.
El usuario indicó que no abrirá Dungeon en esta entrega. Los 3 módulos nuevos
y los 6 clientes modificados deben propagarse más adelante con identidad de
Source y QA. Copias antes/después y reporte en implementation/rc084 del repo.
================================================================================
]]

