# HU-ESTETICA-38 · Reporte de entrega para PM

**Proyecto:** Vandrheim · Roblox MVP  
**Estado:** Diseño visual completado en Pencil  
**Archivo:** `Vandrheim-design.pen`  
**Alcance:** diseño solamente; no se implementó lógica de muerte, compras ni respawn.

## Entregables

- `HU-ESTETICA-38 — Death Panel` (`MDVTC`): dos estados lado a lado, con 2/3 resurrecciones y botón **Reaparecer · Consume 1 de 3**, y 0/3 con botón destacado **R$ 50 · Revivir con Robux**. En ambos permanece disponible **Abandonar la run**, con el texto de conservación de oro y lo ganado.
- Estados de compra: **Reviviendo…**, **Compra completada** y error **No se pudo completar la compra**.
- Confirmación de abandono: explica que no se puede deshacer, que la run no se reanuda y que se conservará lo ganado; ofrece **Volver al panel** y **Confirmar abandono**.
- Variante móvil `HU-ESTETICA-38 — Variante móvil` (`RSYEg`): flujo vertical con botones apilados y estados equivalentes.
- Set `EST-38 — Iconos del panel de muerte` (`WNxnZ`): runa, gema y moneda/Robux; actualizado `ASSETS_LIST.md`.

## Lenguaje visual y verificación

Aplicados los tokens Hearthbound Gold: fondos cálidos oscuros, panel de slot negro, latón, frío y rojo suave para abandonar; tipografías Playfair Display, Inter y Geist Mono. No se sugiere temporizador para decidir. Se revisaron capturas de escritorio, móvil y set de iconos; la inspección de bounds no reportó clipping.

## Pendientes de implementación / validación

- Confirmar el asset final de Robux/moneda y el precio con la configuración publicada antes de integrar compras.
- Mapear Geist Mono / Playfair Display / Inter a las fuentes disponibles en Roblox y validar escala/touch targets en dispositivos.
- R6.28 define el comportamiento real de compra, consumo de revive, éxito/error y abandono; este entregable no establece ni modifica esa lógica.
