# RC084 — Tooltips EST-44

## Entrega en Hub

Aplicado en Roblox Studio, place 84186294312317, el 2026-10-10.
Estado: **EN IMPLEMENTACIÓN — Hub aplicado; QA táctil y sync Dungeon pendientes**.

- Tres tarjetas informativas derivadas de Pencil rIOiC: equipable, consumible y habilidad.
- BuilderSans; datos reales, stats y afijos de texto, vinculación y nivel requerido.
- Set con progreso y bonos según equipo, clase/spec/tier; instanceId deduplicado.
- Coste, cooldown efectivo, alcance, efecto y fórmula de habilidades.
- Efectos reales de consumibles sin línea de cooldown.
- Corrección del formato CRIT: el anillo guarda `1` como un punto porcentual,
  mientras otras piezas guardan fracciones (`0.05`); ambos se muestran como
  `+1 %` y `+5 %` respectivamente.
- Tooltips sin botones. Se eliminó ActionBar del tooltip legado; no se trasladó.
- Hold inmóvil 0,30 s muestra información; movimiento posterior >8 px inicia drag en mochila/equipo/grimorio. Release tras hold no ejecuta acción primaria.
- Slot de skill/consumible conserva hotkeys y tap; CanActivate suprime la activación consumida por hold/movimiento.
- Las filas de compra y venta de vendedores usan TooltipSystem/TooltipData (mismo formato, sin botones); en móvil una pulsación larga muestra la ficha y no compra/vende. Una pulsación normal mantiene la acción existente.
- Los artículos sin oro suficiente también exponen su tooltip; la validación de compra sigue bloqueando la compra.
- Sin cambios de gameplay, remotos ni persistencia; fallback nativo de panel.

## Fuentes

`before/`: respaldo de lectura de los sources previos (incluye configs consultadas).
`after/`: nueve sources del RC original más VendorClient, migrado después para los tooltips de vendedores. Nuevos: TooltipConfig, TooltipData, TooltipSystem.
Clientes: InventoryClient, InventoryPresentationClient, SpellbookClient,
SkillBarClient, ItemUseSlotsClient, UIReskinClient y VendorClient.
`architecture-note.md` y `schema-note.md`: notas añadidas a los documentos del Studio.

## Evidencia y límites

- Los nueve sources del RC original compilan con loadstring, sin ejecutar sus acciones al compilar.
- VendorClient fue revisado en código: elimina el render manual y enlaza compra/venta con Bind y CanActivate. Esta migración no se probó en Play.
- Último arranque de Play: clientes inicializados; sin errores registrados en output.
- Render de habilidad y equipable, comprobación de bordes de viewport, tarjeta sin GuiButtons.
- Proyección de siete consumibles y seis tipos de skill: Instant, SelfAoE, GroundAoE, DoT, Heal y Shield.
- Fixtures de sets 0/3/4/5, clase incompatible e instanceId duplicado: comprobaciones aprobadas.
- Overflow de 60 filas: canvas 1283 px, tarjeta 625 px, filas 16 px y separación 21 px. Se corrigió el estiramiento de filas detectado en la primera prueba.
- Fixtures temporales cliente, sin guardar ni modificar perfil. Se retiraron al detener Play.
- La automatización de hover no fue concluyente en todas las superficies; no se declara recorrido PC completo aprobado.
- Pendientes: gesto touch real/emulado completo, regresión completa de drag/cast/uso/asignación, multiplayer y cross-place. El MCP de input disponible no expone touch.

## Sincronización pendiente

Dungeon_Helada (125210265978348) no está conectado. El usuario indicó que no lo abrirá en esta entrega.
Cuando se retome: copiar los nueve sources de `after/` a los mismos paths indicados en RC084, comparar Source/versión y realizar QA tras teleport. No marcar RC completo hasta cerrar pendientes.
