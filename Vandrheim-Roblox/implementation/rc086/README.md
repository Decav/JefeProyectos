# rc086 — HU-ESTETICA-43

**Estado:** EN IMPLEMENTACIÓN. RC aprobado por el PO el 2026-10-10; ajustes visuales aplicados en Hub tras feedback del PO.

## Aplicado en Studio

Place Hub `84186294312317`:

- `ReplicatedStorage.Config.BackpackUIConfig`: geometría 500×484, casillas de 72×72, cinco columnas en Pencil y menos columnas al reducirse el viewport, gaps, margen, paleta, rarezas, BuilderSans y límites responsivos.
- `StarterGui.InventoryUI.MainFrame`: proporción 500:484, título y estructura de mochila compacta.
- `InventoryPresentationClient`: muestra las 20 casillas; las ocupadas contienen icono, borde de rareza y cantidad si la pila supera 1, sin nombre. Las vacías muestran «VACÍO» y las ocupadas sin ID de imagen usan un placeholder gráfico. Sin panel de detalle ni badge Z/X.
- El listado usa margen interior, grilla responsiva y scroll vertical cuando el contenido supera el área visible. Pie con pilas ocupadas/oro.
- `InventoryClient`: doble toque móvil de 0.35 s para equipar o usar un consumible; conteos sin prefijo «x».
- `UIReskinClient` y `WindowLayoutClient`: la mochila conserva sus estilos, tamaño responsivo, cierre pequeño con área táctil y arrastre de ventana.
- `Workspace.DevelopmentStandard.PROJECT_ARCHITECTURE` y `DATA_SCHEMA`: actualización técnica sin modificar persistencia ni contratos de remotos.

Las fuentes aplicadas están copiadas en `after/` para revisión. La grilla conserva margen interior y scroll vertical responsivo. No se ejecutó Play ni se hizo QA visual en esta etapa; la sesión de Studio quedó en Edit. Dungeon_Helada `125210265978348` sigue pendiente de sync porque no está conectado.
