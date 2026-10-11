# Nota de arquitectura — rc086

La presentación de `InventoryUI` pertenece a `InventoryPresentationClient` y a `BackpackUIConfig`. La mochila presenta sus 20 casillas compactas en una grilla responsiva de hasta cinco columnas (72×72 con gaps 10/16 en el Pencil seleccionado). Las casillas vacías muestran «VACÍO»; las ocupadas muestran icono, borde de rareza y contador si la pila supera 1, sin nombre. Los objetos sin ID de imagen usan un placeholder gráfico. La grilla tiene margen interior y el `ScrollingFrame` deriva el `CanvasSize` del `UIGridLayout` para mantener el scroll vertical cuando hace falta.

`InventoryClient` conserva los veinte índices de inventario, las acciones y los remotos existentes; soporta equipar y usar consumibles con doble toque móvil. `UIReskinClient` cede los estilos de `InventoryUI`. `WindowLayoutClient` conserva apertura, foco, contención, cierre accesible y arrastre.

Hub `84186294312317` aplicado. La propagación a Dungeon_Helada `125210265978348` y su QA siguen pendientes mientras el place esté desconectado.
