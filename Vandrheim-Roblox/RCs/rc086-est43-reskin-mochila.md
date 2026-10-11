--[[
================================================================================
 REQUERIMIENTO TÉCNICO: rc086 — FASE EST-43 (HU-ESTETICA-43)
================================================================================
Proyecto: Vandrheim — RPG/MMO-like en 3ª persona (Roblox).
Fuente: HU/estetica/HU-ESTETICA-43-Reskin-Mochila-Dev.md;
Pencil nwaNs, "Inventario de Eirik · Mochila", variante B · Slots cuadrados;
GDD §§7, 12, 14 (R4/R5.2/R6.27/R6.32), 17; EST-13 y EST-44;
decisiones explícitas del PO en esta conversación.
Estado: EN IMPLEMENTACIÓN (aprobado por el PO el 2026-10-10).
Fecha de emisión: 2026-10-10.
Revisión de alineación con HU actualizada: 2026-10-10.
Requisitos previos: inventario/stacking R4/R5.2, drag & drop rc083,
TooltipSystem rc084 y panel de personaje rc085 presentes en Hub.
Aprobación: explícita del PO el 2026-10-10.

Enmienda visual del PO del 2026-10-10: la selección actual de Pencil
`nwaNs` es la referencia canónica. Muestra veinte casillas en una grilla de
cinco columnas por cuatro filas, imagen sin nombre, contador de pila y
etiqueta «VACÍO» en las casillas vacías. En viewports más angostos la grilla
reduce columnas/tamaño; conserva margen interior y scroll vertical.

================================================================================
1. DESCRIPCIÓN
================================================================================
Reskinear la mochila para mostrar veinte casillas compactas en una grilla
responsiva. Las casillas ocupadas muestran la imagen del ítem, borde de
rareza y contador numérico de pila cuando supera 1, sin nombre. Las vacías
muestran el label «VACÍO». El detalle de cada ítem se consulta mediante el
tooltip existente.

Objetivo de la fase: conservar la identidad visual de nwaNs y mostrar más
objetos por pantalla, ajustando las columnas al ancho disponible y permitiendo
desplazamiento vertical, sin cambiar contratos de inventario, apertura,
arrastre ni servidor.
Criterio de hecho global: "La mochila muestra veinte casillas compactas,
responsivas y desplazables, con imagen, cantidad, label VACÍO, borde de rareza, pie,
oro y cierre; sin panel de detalle ni badges Z/X".

Se consultaron DEV_PROMPT, RC-TEMPLATE, DEVELOPER_GUIDE, PROJECT_STANDARD,
PROJECT_ARCHITECTURE, DATA_SCHEMA, ASSETS_POLICY y documentos citados.
Se inspeccionaron Pencil (estructura y captura), InventoryUI y los clientes
que controlan presentación, entradas y ventanas. RC aprobado por el PO el
2026-10-10; implementación aplicada al Hub. Play/QA visual queda pendiente.

================================================================================
2. ALCANCE (SÍ)
================================================================================
- Reskin de StarterGui.InventoryUI.MainFrame, Title/CloseButton,
  BagPanel/BagScroll y veinte BagSlotN creados por InventoryClient.
- Título con nombre real del personaje y pie con ocupación y oro reales.
- Veinte casillas compactas: imagen del objeto sin nombre, borde de rareza y
  cantidad numérica si supera 1; casillas vacías rotuladas «VACÍO».
- Añadir margen alrededor de la grilla y ajustar hasta cinco columnas según
  el viewport.
- Retirar ItemInfoPanel y los controles de detalle dentro de la mochila.
- Retirar únicamente los badges visuales Z/X de las casillas.
  Mantener asignación de consumibles y su uso desde los accesos rápidos.
- Tooltips actuales informativos sin botones; preservar descripción gris
  al final del tooltip de ítem y formatos ya corregidos.
- Interacciones existentes de PC, drag & drop y tap-hold de móvil.
- Ampliar doble toque móvil para usar consumibles, autorizado por el PO.
- Presentación responsiva y ventana desplazable en PC y móvil.
- Configuración de presentación, coordinación de propietarios del estilo,
  documentación técnica afectada y registro de sincronización entre places.

================================================================================
3. FUERA DE ALCANCE (NO en esta HU)
================================================================================
- Balance, stacking, capacidad, economía, persistencia y lógica de servidor.
- Cambiar reglas de equipamiento, vender, borrar o asignación Z/X.
- Reordenar pilas, añadir filtros, pestañas u otros paneles.
- Botones en tooltips o un panel sustituto con acciones de detalle.
- Rediseñar equipo, vendedores, talentos, grimorio o barra rápida.
- Producción/upload de iconos, modelos, animaciones o nuevos assets.
- Nuevos remotos, tipos de ítem o campos del perfil.

================================================================================
4. CRITERIOS DE ACEPTACIÓN (DEFINICIÓN DE HECHO)
================================================================================
1. La mochila muestra título, grilla de veinte casillas, pie y cierre; no queda
   sección de detalle ni espacio vacío heredado.
2. Cada casilla ocupada muestra solo el icono, sin nombre ni descripción,
   sobre fondo #0E0D0C y borde de rareza. Hover/foco modifica el borde, no el fondo.
3. Las veinte casillas permanecen visibles. Una casilla vacía muestra «VACÍO»
   en gris y borde neutral. Cantidades >1 aparecen como número sin prefijo x
   sobre backing
   negro translúcido; cantidad 1 se oculta.
4. Título usa el nombre real del personaje; ocupación cuenta pilas ocupadas,
   no unidades; oro refleja los datos replicados actuales.
5. No se muestran badges Z/X en mochila. La asignación y activación desde
   barra rápida/teclas siguen funcionando.
6. PC conserva click derecho para usar/equipar; nunca borra. Móvil conserva
   doble toque para equipar y añade doble toque para usar un consumible.
7. Tap-hold sin desplazamiento muestra tooltip; arrastre conserva prioridad
   al superar sus umbrales. Un arrastre no termina en uso/doble toque.
8. Drag a casilla de equipo usa validación existente; drag fuera conserva
   confirmación de eliminación. Cancelar no elimina el ítem. Se conserva
   la sombra del ítem durante drag y el indicador rojo de destino inválido.
9. Tooltips siguen informativos y sin botones. No se pierde descripción
   final de ítem ni se cambia su cálculo/formato de atributos.
10. En PC y móvil no hay textos superpuestos, recortes ni cierre desmedido;
    la ventana mantiene su proporción, cabe en <=85 % del viewport útil
    móvil y se puede mover y cerrar. El scroll vertical funciona cuando hay
   más casillas que espacio visible y la barra queda perceptible; hay margen
   visible entre el borde de la lista y la primera/última fila de casillas.
11. Nombres/padres consumidos por scripts, inventario, pilas, vender,
    equipar y persistencia permanecen compatibles; sin errores rojos.

================================================================================
5. IMPLEMENTACIÓN TÉCNICA
================================================================================
5.1 Archivos e instancias
- Crear ReplicatedStorage.Config.BackpackUIConfig (ModuleScript):
  geometría de referencia, paleta, rarezas, fuentes, tamaños/mínimos y
  límites del viewport. Solo presentación; no duplicar ItemConfig.
- StarterGui.InventoryUI.MainFrame: adaptar la plantilla estática para
  reflejar la mochila compacta. Conservar MainFrame, Title, CloseButton,
  BagPanel, BagScroll y contratos de BagSlotN/ItemIcon/Quantity.
- StarterPlayer.StarterPlayerScripts.InventoryPresentationClient:
  reconstruir styleBagWindow/styleBagSlot y su rama responsiva.
  Unificar título/pie, vacíos/backing y retiro del detalle/UseMarker visible.
  Mantener intacta la presentación de EquipmentUI del rc085.
  renderItemInfo debe dejar de crear/actualizar el panel retirado.
- StarterPlayer.StarterPlayerScripts.InventoryClient:
  conservar renderBag, veinte slots, selección y conexiones de red;
  ajustar Quantity/VACÍO coherentemente con el propietario de estilo.
  Generalizar el doble toque móvil según ítem sin duplicar peticiones.
- StarterPlayer.StarterPlayerScripts.UIReskinClient:
  excluir estilos genéricos que sobrescriban InventoryUI; mantener
  safe-area y contratos de ventanas, igual que los paneles con dueño propio.
- StarterPlayer.StarterPlayerScripts.WindowLayoutClient:
  ceder dimensiones de InventoryUI a su presentación/configuración;
  mantener apertura, foco, contención y drag por encabezado mouse/touch.
  Dar al cierre una cara proporcional y un área táctil accesible.
- Workspace.DevelopmentStandard.PROJECT_ARCHITECTURE y DATA_SCHEMA:
  registrar cambios de UI/gestos/propietarios; sin ampliar schema de perfil.

5.2 Geometría y estilo medidos en Pencil
Referencia 500×484; convertir posiciones/tamaños a Scale relativo al padre
y mantener UIAspectRatioConstraint 500/484.
- Frame: #211916, borde #6B4A2B de 1, radio 9.
- Encabezado: título centrado, pergamino #F4EDE0; región de referencia
  x15/y10/464×22. Reservar el cierre; truncar nombre largo sin solaparlo.
- El área desplazable empieza en x20/y58 y ocupa 460×336 de la referencia
  500×484. Se muestran las veinte casillas compactas, incluidas las vacías.
- Cada casilla usa fondo negro y, si tiene ítem, la imagen ocupa el interior
  con recorte cover sin deformarse. No se muestra el nombre del objeto; el
  contador numérico aparece solo para pilas mayores que 1. Sin imagen se usa
  el placeholder gráfico centrado. Las vacías muestran «VACÍO» centrado.
- Fondo de slot #0E0D0C. Bordes según rareza existente:
  común #F4EDE0, poco común #70C48A, raro #75A8E0, épico #B48ADE;
  vacío #3A302A. Conservar mapeo semántico de rarezas del proyecto.
- Quantity: chip compacto en la esquina inferior derecha de la casilla,
  backing negro con
  alfa 0.60 y número pergamino.
  Ocultar texto y backing cuando la pila no supera una unidad.
- Las casillas vacías muestran el label «VACÍO» gris (#8B8178), conservan
  fondo #0E0D0C y borde neutral #3A302A.
- Pie: x47/y420/400×30, #171311, radio 5, borde #6B4A2B.
  Texto dorado #C89445: "X / 20 ESPACIOS · ORO DISPONIBLE · ◈ saldo",
  reemplazando X y saldo con datos reales.
- Cierre: cara 22×22 en x463/y10, #3A2525, radio 5, borde #6B4A2B;
  X pergamino 12×12. Área touch >=44px cuando sea necesario, manteniendo
  pequeña la cara y sin invadir slots ni bloquear drag/título.
- Fuentes: BuilderSans/BuilderSansBold para toda la mochila, según decisión
  global del PO. Los tamaños Pencil (13 título, 9 pie, 7.5 cantidad) son
  referencia compositiva; adaptar legibilidad según R6.27, sin recortes.
- No iluminar fondos, añadir tarjetas, badges o paneles ajenos a nwaNs.

5.3 Responsividad y propietarios
Calcular entre una y cinco columnas según el ancho absoluto disponible y un
tamaño mínimo de casilla de 56 px. En referencia Pencil: 72×72, gap horizontal
10 y vertical 16, cinco columnas. La mochila usa scroll vertical habilitado,
barra visible y CanvasSize derivado del contenido de UIGridLayout; el contenido
puede superar el alto visible. Mantener la ventana dentro de <=85 % del ancho
y alto útil móvil y preservar su proporción. Escuchar AbsoluteSize y cambios
de contenido sin bucles de polling. Mantener la lista compacta también en PC.
Separar tamaños de cara de cierre y hitbox. No permitir que UIReskinClient
o WindowLayoutClient restauren la mochila ancha tras abrirla o cambiar
dispositivo. Conservar apertura B, cierre y frame arrastrable mouse/touch.

5.4 Datos, gestos y contratos existentes
Estado: InventoryData.bag y equipment existentes, item.instanceId,
templateId, iconId, rarity y quantity; oro replicado/playerGold y
VendorResult.gold; ItemUseSlotState.slots/quantities.
Nombre: señal/atributo de nombre de personaje usado por el panel actual.
No usar "Eirik" ni valores de ejemplo como datos del jugador.

Remotos C→S existentes:
- RequestEquipItem {instanceId, preferredSlot?}.
- RequestUnequipItem {slotName, instanceId?}.
- RequestUseConsumable {instanceId}.
- RequestAssignItemUseSlot {slotIndex, templateId}.
- RequestDeleteItem {instanceId}, solo después de confirmar.
Remotos S→C existentes:
- InventoryData, InventoryResult, VendorResult, ItemUseSlotState.
Conservar payloads/validaciones actuales; no crear remotos.

Doble toque móvil: conservar ventana existente de 0.35s y mismo instanceId;
si item.usable==true, enviar una única RequestUseConsumable; si equipable,
conservar RequestEquipItem. Primer toque selecciona como hoy. Cancelar
candidato tras drag, tap-hold de tooltip o cambio/desaparición de ítem.
El servidor valida disponibilidad, cooldown y uso, igual que click derecho.
La asignación Z/X conserva ItemUseAssignSlot y RequestAssignItemUseSlot;
ocultar UseMarker no altera ese flujo ni ItemUseSlotState.

Conservar drag PC de 8px y móvil de 300ms + movimiento 8px de R6.32.
Tap-hold inmóvil y drag comparten arbitraje existente con TooltipSystem
(externalTouch=true): el movimiento que inicia drag cierra/suprime tooltip.
Reutilizar las plantillas item_equipable/item_consumible de R6.27/EST-44
según el tipo real del ítem. Conservar sombra de arrastre y destino
inválido en rojo de R6.32; no sustituir esos estados con el hover del borde.
No mover acciones al tooltip ni emitir uso al soltar un arrastre.

Server-authoritative: cantidades, oro, equipamiento, uso y borrado son
validados por los servicios existentes. El cliente solo dibuja/pide acciones.
Convenciones: task.wait()/task.spawn() si hace falta; prohibido wait();
UI con Scale + UIAspectRatioConstraint y señales/Attributes.

================================================================================
6. INTEGRACIÓN
================================================================================
- Reutilizar InventoryService, ItemConfig y perfil existentes, sin editarlos.
- Reutilizar TooltipSystem/TooltipData rc084 y gestión de drag rc083.
  Conservar tooltip de ítem de vendedores y su descripción final ya cerrados.
- Mantener compatibilidad con el panel de personaje rc085 como destino
  de drag, sin modificar su composición ni sus datos de especialización.
- Icon_UI_currency_gold: ASSETS_LIST referencia componente ◈ (S9eT1);
  no se encontró un asset Roblox publicado en la configuración actual.
  Reutilizar el glifo ◈ nativo existente mientras no haya ID registrado,
  según política de placeholders; no inventar/subir un ID en esta HU.
- Hub place 84186294312317 está conectado. Dungeon_Helada
  125210265978348 comparte estos clientes/configuración y requiere sync.
  No está conectado; el PO ya rechazó abrirlo. Registrar pendiente, sin
  simular propagación ni declarar verificación de ese place.
- Dejar un propietario claro de la mochila y config de geometría para
  cambios futuros, sin construir nuevos sistemas.

================================================================================
7. OPTIMIZACIÓN
================================================================================
- Reutilizar veinte instancias/callbacks y refrescar datos por señales.
- Evitar duplicación de tooltips, listeners y UIGridLayout.
- Cachear referencias; no recorrer toda la jerarquía por frame.
- No recrear toda la mochila con cada InventoryData o actualización de oro.
- No modificar fuentes/estilos de ventanas fuera de alcance.
- Presupuesto orientativo: dos sesiones, reskin e integración.

================================================================================
8. DEFINICIÓN DE HECHO (VERIFICACIÓN)
================================================================================
[x] Aprobación explícita de rc086 registrada antes de producción (2026-10-10).
[ ] Comparación visual de captura PC/móvil con nwaNs: composición,
    fondo/bordes/iconos, casillas compactas ocupadas y vacías, labels y cantidades,
    margen, scroll, pie y cierre.
[ ] Viewports PC/móvil: <=85 % móvil, safe-area, textos legibles,
    nombre largo, oro alto, sin solapamiento, recortes ni espacio residual.
[ ] Veinte casillas visibles, inventario parcial/lleno, pila 1/>1, rarezas y
    ítem sin icono: placeholders, labels «VACÍO» y scroll correctos; conteo de pilas,
    no de unidades.
[ ] Actualización de oro tras vendedor y nombre tras carga de personaje.
[ ] Sin badges Z/X; asignar consumible y activar accesos rápidos funciona.
[ ] PC click derecho y móvil doble toque: equipar/usar una vez;
    toque simple, tap-hold o drag no consumen accidentalmente.
[ ] Tooltip hover/tap-hold sin botones y descripción final de ítem intacta.
[ ] Drag a equipo válido/inválido, desequipar, salir de mochila:
    sombra e indicador rojo existentes, confirmación; cancelar conserva ítem.
[ ] Ventana movible/cerrable PC y móvil; cambio de viewport conserva
    contención y proporción, sin restaurar layout viejo.
[ ] Persistencia y vender/equipar/usar conservados; sin errores rojos.
[ ] Sin nuevas escrituras de oro/pilas/equipo desde cliente ni nuevas
    reglas del servidor. No certificar anti-exploit sin ejecutar revisión.
[ ] Actualizar PROJECT_ARCHITECTURE/DATA_SCHEMA técnicos y estado de RC.
    Nota canónica GDD "EST-43 completo" corresponde al PM después de QA.

Sync obligatorio:
- Módulo compartido nuevo: ReplicatedStorage.Config.BackpackUIConfig.
- Clientes: InventoryClient, InventoryPresentationClient, UIReskinClient,
  WindowLayoutClient; plantilla StarterGui.InventoryUI.
- Places consumidores: Hub 84186294312317 y Dungeon_Helada 125210265978348.
[ ] Propagar las mismas fuentes/versión e instancias relevantes a ambos.
[ ] Registrar identidad de Source/versión por place y QA de mochila,
    tooltip, doble toque, drag y Z/X tras flujo Hub→Dungeon.
[ ] Mientras Dungeon esté desconectado, dejar pendiente sync y QA.
    No marcar RC global COMPLETO con esa propagación sin comprobar.

No se ejecuta Play ni QA en la etapa de emisión del RC.

================================================================================
9. ESTIMACIÓN
================================================================================
Dos sesiones del dev: reskin y adaptación; integración de gestos y revisión.
Orientativo; sync/QA Dungeon depende de disponibilidad del place.

================================================================================
10. DEPENDENCIAS
================================================================================
HU-ESTETICA-43, Pencil nwaNs, EST-13, R6.27, R6.32/rc083,
EST-44/rc084, inventario R4/R5.2 y panel de personaje rc085 existente.

Decisiones de PO registradas:
- Bordes de rareza como Pencil, por encima del "sin bordes" de la HU.
- Sin badges Z/X; su funcionalidad sigue en barra rápida/teclas.
- Doble toque móvil usa consumibles, además de equipar equipo.
- BuilderSans global; tooltips informativos sin botones.
La HU actual confirma ausencia de badges y botones, pero su checklist
todavía contiene "badge conservado/sin bordes". Se aplica la decisión
explícita del PO; no se modifica la HU canónica desde el rol dev.
Revisión solicitada por el PO: la exclusión de botones en tooltips ya está
cubierta por alcance, criterios y verificación. Se explicitan además las
plantillas item_equipable/item_consumible y los estados visuales de drag
(sombra/destino inválido rojo) indicados por la HU. No abre nuevas acciones.

Pendientes no bloqueantes de documentación/entrega:
- Icono de oro Roblox definitivo: fallback ◈ registrado en este RC.
- Propagación y QA en Dungeon_Helada: pendiente por place desconectado.
- Actualización canónica HU/GDD de las contradicciones: corresponde al PM.

rc086 aprobado por el PO el 2026-10-10; implementación en curso.

================================================================================
FIN DEL REQUERIMIENTO
================================================================================
--]]

