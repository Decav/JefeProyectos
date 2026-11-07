# Entrega de Diseño — HU-ESTETICA-53: Rediseño de Tiendas de NPCs (Pencil UI)

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** Estética / UI / Comercio  
**Archivo canónico:** `Vandrheim-design.pen`  
**Tablero Maestro en Pencil:** `HU-ESTETICA-53 — Rediseño Tienda NPCs (Comprar / Vender · 2 Columnas)` (ID: `Sh0pBd`)  
**Coordenadas Canvas:** `x: 2316, y: 21700` (ubicado limpiamente debajo del tablero de Misiones HU-51)  
**Estado:** Diseño completado y listo para revisión.

---

## 1. Frames Principales Entregados

| Frame | Node ID | Plataforma / Modo | Descripción |
|---|---|---|---|
| `HU-ESTETICA-52 — Rediseño Tienda NPCs` | `Sh0pBd` | Tablero Maestro | Tablero contenedor general con título, subtítulo y especificaciones. |
| `FRAME_NPC_SHOP_REDSGN_BUY · Comerciante de Vandrheim` | `ShpWin01` | PC · Comprar | Ventana de 720×480 px. Selector activo en "COMPRAR", catálogo en 2 columnas con armas, armaduras, pociones y materiales. Botones dorados de compra. |
| `FRAME_NPC_SHOP_REDSGN_SELL · Comerciante de Vandrheim` | `ShpWin02` | PC · Vender | Ventana de 720×480 px. Selector activo en "VENDER", listado en 2 columnas del inventario del jugador con badges de cantidad (`x5`, `x12`, etc.) y botones de venta carmesí/óxido. |
| `FRAME_NPC_SHOP_REDSGN_BUY · Tienda de Provisiones` | `ShpWin03` | Mobile · Comprar | Ventana de 640×360 px adaptada para móvil (Touch UI) con layout optimizado de 2 columnas. |
| `FRAME_NPC_SHOP_REDSGN_SELL · Venta de Botín` | `ShpWin04` | Mobile · Vender | Ventana de 640×360 px para móvil con selector en Vender y catálogo de mochila. |
| `FRAME_NPC_SHOP_SPECS_HANDOFF` | `ShpSpec01` | Documentación | Panel de tokens, contratos UI, reglas de interacción, accesibilidad y responsive. |

---

## 2. Anatomía de la Fila de Ítem (Listado de 2 Columnas)

Cada tarjeta mide `326 px` de ancho por `64 px` de alto (en PC), distribuida en dos columnas paralelas dentro del contenedor de scroll:

1. **Casilla de Ítem (Izquierda, 48×48 px):**
   - Fondo oscuro `#15100D` con marco de latón nórdico `#6B4A2B` (radio 6px).
   - Render 3D del ítem a `40×40 px` centrado.
   - En modo **Vender**, incorpora un badge en la esquina inferior derecha con la cantidad acumulada en la mochila (`x5`, `x12`), con texto perfectamente centrado horizontal y verticalmente (`textAlign: center`, `textAlignVertical: middle`).
2. **Bloque de Información (Centro):**
   - **Nombre del Ítem:** Tipografía `Geist Mono` bold 11px, color marfil `#F4EDE0`.
   - **Precio en Oro:** Directamente debajo del nombre. Icono oficial de moneda de oro (`14×14 px`) + cantidad en `Geist Mono` bold 10px, color oro latón `#C89445`.
3. **Botón de Acción (Derecha, 68×28 px):**
   - **Alineación del Texto:** Texto perfectamente centrado horizontal y verticalmente (`textAlign: center`, `textAlignVertical: middle`) coincidiendo con los límites del botón.
   - **Comprar:** Fondo oro nórdico `#C89445` con texto `"COMPRAR"` en tinta oscura `#15100D`.
   - **Vender:** Fondo carmesí/cuero oscuro `#6B2A2A` con texto `"VENDER"` en marfil `#F4EDE0`.

---

## 3. ScrollingFrame y Scrollbar Visible

- **Contenedor Scrolleable:**
  - El listado de 2 columnas se aloja dentro de un frame con `clip: true` que aísla el área de scroll vertical.
- **Scrollbar Visible Integrada:**
  - **Pista (Track):** Rectángulo oscuro `#17120F` de 6 px de ancho a la derecha del catálogo con borde sutil `#2E241D`.
  - **Barra de Arrastre (Thumb):** Rectángulo redondeado en oro nórdico `#C89445` (3 px de radio) que indica la posición del scroll dentro del catálogo.
  - Diseñado para responder a la rueda del ratón en PC y al gesto de deslizar (swipe) en móvil.

---

## 3. Selector Comprar / Vender y Barra Superior

- **Selector Unificado:**
  - Situado en la cabecera bajo el título de la tienda.
  - Tabs con contraste activo claro: pestaña activa en fondo oro `#C89445` con texto oscuro, pestaña inactiva en fondo `#211916` con texto atenuado `#B5A79A`.
- **Saldo del Jugador:**
  - En la esquina superior derecha, permanentemente visible: casilla con el icono de oro y el saldo actual (ej. `340 Oro`).
- **Botón de Cierre:**
  - Botón cuadrado de 26×26 px en la esquina superior derecha con icono nórdico de cruz/aspa y soporte para tecla `[ESC]`.

---

## 4. Handoff Técnico para BuilderAgent (Roblox Luau)

1. **Jerarquía UI en Roblox:**
   - La ventana debe residir en `StarterGui` / `NPCShopGui`.
   - El catálogo debe ser un `ScrollingFrame` con `UIGridLayout` de 2 columnas (`CellSize = UDim2.new(0.48, 0, 0, 64)`, `CellPadding = UDim2.new(0.04, 0, 0, 10)`).
2. **Dimensiones Responsive:**
   - PC: Ventana centrada usando `UDim2.fromScale(0.55, 0.65)` con `UIAspectRatioConstraint (1.5)`.
   - Mobile: Escala completa con márgenes seguros para evitar solapamiento con joysticks o botones táctiles.
3. **Flujo de Transacción:**
   - Al pulsar `COMPRAR`: Verificación en servidor de saldo de oro y espacio en mochila (`BackpackService`).
   - Al pulsar `VENDER`: Verificación en servidor de posesión del ítem y actualización atómica de oro e inventario.
