# RC085 — HU-ESTETICA-45 (variante B HUMWS)

## Estado

Implementación aplicada al Hub de Studio (place 84186294312317), 2026-10-10.
RC aprobado; estado **EN IMPLEMENTACIÓN**. No se inició Play ni se ejecutaron tests.

## Cambios aplicados

- CharacterPanelUIConfig define el canvas lógico 480:455, tokens, 9 slots,
  agrupación y posiciones de HUMWS.
- StarterGui.EquipmentUI conserva el árbol contractual; sus 9 slots están
  dispuestos alrededor del panel central de atributos y se agregó CDR.
- InventoryPresentationClient aplica layout, identidad, valores, estilo de
  filas y tooltips de stat. Todos los textos usan BuilderSans.
- InventoryClient conserva interacciones y remotos; conecta CDR al atributo
  replicado y respeta el nuevo campo visual.
- WindowLayoutClient deja el tamaño a HUMWS y mantiene drag, focus y clamp.
- UIReskinClient cede el estilo de EquipmentUI al reskin específico; el cierre
  conserva un hit area táctil amplio con cara visual del tamaño del Pencil.
- TooltipData.Stat / TooltipSystem aceptan tipo stat; no agregan botones ni
  remotos. El snapshot existente alimenta los siete desgloses; CDR muestra el
  total replicado.
- TooltipData unifica la conversión de CRIT en tooltips de objetos: valores
  enteros en puntos porcentuales y fracciones decimales conservan el mismo
  porcentaje visible.
- Ajustes solicitados tras la aprobación: filas de atributos con BuilderSans
  de 11/12 px y mayor altura; el panel sube para dejar separación del slot
  MainHand. El subtítulo toma classId/specId del payload SpellbookData y los
  resuelve mediante ClassConfig, en vez de depender de atributos ausentes.

## Fuentes

- `before/`: respaldo de los 7 sources previos; también incluye VendorClient para registrar su estado previo al ajuste de tooltips de vendedores.
- `after/`: 7 sources de esta HU, incluida la nueva CharacterPanelUIConfig, más VendorClient con el ajuste de tooltips de vendedores como seguimiento de RC084.
- `architecture-note.md`, `schema-note.md`: notas registradas en
  Workspace.DevelopmentStandard del Hub.
- El RC está guardado en `RCs/rc085-est45-reskin-panel-personaje.md` y en
  `Workspace.DevelopmentStandard.Requirement.rc085`.

## Pendiente

QA visual/funcional en Play y verificación PC/móvil; propagación al place
Dungeon_Helada (125210265978348) pendiente porque el usuario indicó que no
lo abrirá. No marcar rc085 COMPLETO hasta revisar esos pendientes.

