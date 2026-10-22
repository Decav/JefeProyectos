# HU-ESTETICA-35: Pantallas de economía — Comercio (tradeo) y Subasta (diseñador, Pencil)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Economía / Diseño UI
**Prioridad:** Alta
**Estado:** Entrega parcial: frames de Subasta para escritorio/móvil entregados; quedan pendientes registrados en §2/DoD. Trade conserva su selector/invitación previa pendiente.
**Tipo:** Diseño de pantallas (diseñador) — el dev integra por frames (patrón EST-13/15/16/17/22)
**Fase GDD:** Economía 1 y 2 (comercio y subasta, decisiones PO 2026-09-22)
**Depende de:** HU-ECONOMIA-01 (comercio/tradeo), HU-ECONOMIA-02 (subasta cross-server), HU-ESTETICA-13 (tokens/fuentes/9-slice), HU-ESTETICA-10/11 (patrón de paneles stats/bolsa), HU-ESTETICA-20/23 (micro menú), ASSETS_LIST (iconos por tier)
**No modifica:** lógica ni stats (solo diseño de pantallas)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** pantallas claras y coherentes para **comerciar con otros jugadores** y para **comprar/vender en la subasta global**,
**para** que la economía del juego se sienta parte del mundo (misma familia visual que el resto de Vandrheim).

---

### **Descripción del Requerimiento / Contexto**

Se agregan dos sistemas de economía (épica ECON-01/02) y necesitan sus pantallas. Diseño funcional en Pencil, reutilizando el patrón de ventanas del juego (tokens EST-13, 9-slice, fuentes PlayfairDisplay/Inter/RobotoMono, fondo `#15100D`/`#211916` y dorados de acento).

**Criterio de hecho global:** existen los frames Pencil de las pantallas de **comercio** (ventana de trade) y de **subasta** (catálogo + publicar + recompensas + historial), con estados visuales claros y coherentes con las ventanas existentes — listos para que el dev las integre.

---

### **Especificaciones Técnicas / Contratos de API**

#### **0. Selector cercano e invitación de trade (nuevo — ECON-01 v3)**

* Diseñar el acceso **COMERCIAR** y un selector/modal con los jugadores elegibles del mismo servidor del Hub y dentro del rango de 15 studs.
* El trade es directo entre dos jugadores; no requiere party ni amistad.
* Cada fila identifica al candidato por el **nombre del personaje**; incluir estado vacío **“No hay jugadores elegibles cerca”**. Los no elegibles (fuera de rango, en combate o con trade/invitación activa) no deben poder seleccionarse; el servidor vuelve a validar.
* Al elegir a B, A ve feedback de invitación enviada. B recibe una modal con el nombre del personaje solicitante y botones **Aceptar** / **Rechazar**.
* La invitación expira a los **60 s**; aceptar abre la ventana de ofertas. Rechazo/timeout no reserva ítems ni oro. Mensajes pasivos usan NotificationFrame; la decisión Aceptar/Rechazar permanece en la modal.
* Diseñar variantes PC y móvil horizontal con safe area y objetivos táctiles ≥44×44 px. No inicia `OFFERING` ni aparece el panel de ofertas antes de aceptar.

#### **1. Ventana de TRADE (ECON-01)**

Clásica de dos lados. El rediseño vigente mide **528×396 en escritorio** y tiene una variante **640×320 en móvil horizontal**; estas medidas reemplazan el tamaño inicial aproximado de 640×360.

* **Layout:** A (izquierda, fondo del jugador local) | B (derecha, fondo del otro) — nombres y nivel arriba de cada lado.
* **Cada lado:** 6 casillas de ítem (2×3, patrón de slots estándar: **fondo negro + hover de borde** — HU-R6.27) + campo de **oro** con entrada numérica y botón +/-.
* **Estados de confirmación:** candado/lock por lado ("A confirmó" / "B confirmó"); al cambiar la oferta, **los candados se revierten** (ECON-01 v2 — el estado debe verse claro).
* **Botones:** Confirmar (por lado), Cancelar (común) — con estados deshabilitados cuando corresponda.
* **Estados de la ventana:** OFFRECIENDO (editable) → BLOQUEADO (no editable, candados puestos) → EXCHANGING (feedback "Intercambiando…") → COMPLETADO (cierre) / CANCELADO (cierre).
* **Feedback:** alerta de timeout ("El trade expiró"), de distancia ("Demasiado lejos"), de éxito ("¡Trade completado!").
* **Nota de estilo:** misma familia de la ventana de stats/equipo (EST-10) y del vendor (EST-13/15) — no inventar un patrón nuevo.

**Frames entregados — Trade · Rediseño:**

| Estado | Escritorio | Móvil horizontal |
|---|---|---|
| 01 Oferta abierta | `MHmVu` | `J49Jo` |
| 02 Confirmó solo tú | `x5NRv8` | `nTldw` |
| 03 Confirmó solo Saga | `gayFI` | `Lu43g` |
| 04 Oferta modificada | `WyaUp` | `s74Pd` |
| 05 Bloqueado · confirmado por ambos | `Fj3Uh` | `SpU3p` |
| 06 Intercambiando | `GMRah` | `MQrb3` |
| 07 Completado | `nkmjf` | `abtHS` |
| 08 Expirado · timeout | `Y8nUKs` | `D86y0l` |
| 09 Cancelado · distancia | `y9LhE` | `Fo7bf` |

Las notas de variantes están en el frame `K2Ox5k`. Eirik/Saga, niveles, ítems e importes son datos de muestra; el dev debe enlazar valores reales. La X solo oculta el panel; no cancela un trade bloqueado o en intercambio. En móvil, conservar área segura, texto mínimo de 9 px y hitbox de cierre de al menos 44×44 px. Timeout/distancia reutilizan el `NotificationFrame` existente para mostrar la causa; no se requiere un modal nuevo.

#### **2. Ventana de SUBASTA (ECON-02)**

Principal ~640×400 con pestañas (diseñar el contenedor con 4 pestañas):

* **Pestaña 1 — Explorar (catálogo):** lista paginada ordenada por **precio ascendente** (sin filtros en v1). Fila = icono + nombre + tier/color + tipo desde `wieldType` cuando aplique + precio. Paginación dinámica (página actual / total). Estado vacío ("No hay anuncios aún").
* **Pestaña 2 — Mis listados:** filas con ítem, cantidad del lote, precio, duración restante y estado (Activo/Vendido/Expirado); botón **Retirar** solo en Activo. Mostrar límite dinámico X/10 o X/20 según perk. Sin acción de re-publicar directa en v1.
* **Pestaña 3 — Mis recompensas (buzón):** separar **Oro a cobrar** y **Ítems a cobrar** con botón **Cobrar** por fila (y "Cobrar todo"). Conteo visible de pendientes.
* **Pestaña 4 — Historial:** ventas y compras (ítem, precio, fecha, corte aplicado).
* **Ventana de PUBLICAR (sub-pantalla o modal):** elegir un ítem elegible de la bolsa; en pilas stackable, elegir cantidad entera ≤ disponible y mostrar el remanente. El precio es el total del lote (entero 1–1.000.000), con selector de duración (24 h / 48 h), fee de listado 5 oro no reembolsable y corte/neto del vendedor según ECON-02.
* **Confirmación de COMPRA (modal):** ítem + precio + total a pagar + "El 5% lo paga el vendedor" → Confirmar/Cancelar.
* **Feedback:** "Ítem vendido" (al dueño), "Ya no está disponible" (compra fallida — stale), "Publicado", "Retirado", "Recompensa cobrada".
* **Detalle de tier:** usar los colores de rareza del juego (blanco/verde/azul/épica/único) en iconos, bordes y nombres.
* **Acceso:** abrir la ventana solo desde el `ProximityPrompt` del NPC de Subasta en el Hub; no diseñar un acceso desde el micromenú ni un botón móvil global.

**Frames entregados — Subasta (`Vandrheim-design.pen`):**

| Estado | Escritorio | Móvil horizontal |
|---|---|---|
| 01 Explorar | `yHHUX` | `g86mLr` — Móvil 01 Explorar |
| 02 Mis listados | `oDV8o` | `sc7cd` |
| 02b Mis listados vacío | `E2SzS` | `Q2ZRh` |
| 03 Recompensas | `DV62E` | `lCsbX` |
| 03b Recompensas vacío | `c5XlOD` | `qdQSn` |
| 04 Historial | `k1PsJW` | `JdlBX` |
| 04b Historial vacío | `Clph1` | `cac6B` |
| 05 Publicar | `LVod8` | `OBg6P` — Móvil 02 Publicar |
| 06 Confirmar compra | `N5kifd` | `BGF7k` |
| 07 Explorar vacío | `Tujod` | `jsV6p` |

`sOyxC` — Notas de entrega registra reglas y pendientes de revisión. El frame agregado antiguo `V6A4f` queda supersedido por estos estados separados; no usarlo como pantalla runtime.

#### **3. Reglas de diseño**

* Tokens y fuentes de EST-13; acentos **dorados** para economía (precios/oro).
* Iconos existentes por tier (ASSETS_LIST); casillas con el estándar de la HU-R6.27 (fondo negro + hover de borde).
* Ventanas con 9-slice y cierre (X), escalables sin romper en móvil (patrón de las ventanas actuales).
* Nombrar los frames: `HU-ESTETICA-35 — <pantalla>` (ej. "Trade", "Auction — Explorar", "Auction — Publicar", "Auction — Recompensas") para que el dev los referencie como en EST-22.
* La ventana de Subasta se puede mover arrastrando su cabecera (regla de ventanas de R6.11); conservar una zona de agarre clara sin crear un handle que tape tabs o acciones. Los avisos de operación usan el `NotificationFrame` existente de R6.31; no diseñar toasts independientes.
* En móvil, usar los frames específicos de la tabla, con safe area y targets ≥44×44 px. El diseño actual deja la ventana móvil fija; el arrastre está especificado para escritorio y queda pendiente confirmar si el PO lo requiere también en móvil.
* Los datos visibles en los mockups son solo ejemplos. La implementación debe enlazar precios, saldos, nombres, rareza/tiers, estado, fechas y conteos a ECON-02, ItemConfig y registros reales; no copiar textos/números de muestra como valores de juego.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Pantallas completas**

* **GIVEN** los frames entregados
* **WHEN** se revisa el `.pen`
* **THEN** existen la ventana de **trade** (con todos los estados) y la de **subasta** (4 pestañas + publicar + compra)

#### **Escenario 1a: Selector e invitación previa**

* **GIVEN** jugadores elegibles dentro del Hub
* **WHEN** A usa COMERCIAR, selecciona B y se envía una solicitud
* **THEN** B ve la modal Aceptar/Rechazar; solo tras aceptar se abre la ventana de ofertas
* **AND** rechazo/timeout cierra la invitación sin reservar bienes

#### **Escenario 2: Estados claros**

* **GIVEN** la ventana de trade
* **WHEN** se revisan los estados
* **THEN** se distingue OFRECIENDO / BLOQUEADO / EXCHANGING / COMPLETADO / CANCELADO y el efecto de confirmar/cambiar oferta

#### **Escenario 3: Coherencia**

* **GIVEN** las pantallas de economía
* **WHEN** se comparan con las ventanas existentes
* **THEN** usan los mismos tokens, fuentes, 9-slice y patrón de casillas (fondo negro + hover de borde)

#### **Escenario 4: Entrega válida**

* **GIVEN** la entrega
* **WHEN** se inspecciona
* **THEN** frames nombrados correctamente (patrón EST-22) y sin assets raros (iconos del estándar)

---

### **Alcance**

#### Incluye

* Ventana de trade (2 lados, 6 slots + oro, candados, estados, feedback).
* Ventana de subasta (4 pestañas + publicar + confirmación de compra + vacíos).
* Modales/feedback del flujo.

#### No incluye

* Lógica (ECON-01/02 la define), ni UI del tutorial (TUTORIAL-01), ni reskins.

---

### **Definition of Done (DoD)**

#### Entrega parcial revisada — Trade (2026-10-19)

* [x] Nueve estados del trade entregados en escritorio y nueve variantes en móvil horizontal, con nombres/IDs registrados arriba.
* [x] Inspección visual de los frames: composición y contenido dentro de sus límites, sin clipping observado.
* [x] Notas de variantes documentan confirmaciones, reinicio al modificar, bloqueo, intercambio, cierre y touch targets.
* [ ] Selector COMERCIAR y modal Aceptar/Rechazar diseñados para PC/móvil, con estado vacío y expiración/rechazo; sin reserva antes de aceptar.

#### Cierre global de EST-35

* [x] Trade: nueve estados de escritorio y nueve variantes móviles entregados, revisados y referenciados en esta HU.
* [x] Subasta: estados separados de escritorio y móviles para Explorar, Mis listados, Recompensas, Historial, Publicar, Confirmar compra y estados vacíos (IDs registrados arriba).
* [x] Explorar muestra paginación dinámica; 68 anuncios a 20 por página = 4 páginas. Las filas fuera del viewport se consultan mediante el scroll, mostrando solo filas completas.
* [x] Mis listados muestra precio/duración/estado y límite dinámico; Recompensas ofrece Cobrar por fila y Cobrar todo; hay estado vacío por pestaña.
* [x] Recompensas muestra precio, corte entero y neto según ECON-02 (redondeo al oro más cercano, mitad hacia arriba).
* [x] Los avisos de subasta se mapean al NotificationFrame R6.31; no se requieren toasts ni modales de feedback nuevos.
* [x] La ventana de escritorio se arrastra por la cabecera según R6.11; el diseño móvil actual queda fijo y usa targets ≥44×44 px.
* [x] Los datos de muestra son solo visuales; runtime usa ItemConfig/AuctionConfig/listings para nombres, rareza, wieldType, precio, estado y paginación.
* [ ] Confirmar con el PO si el panel también debe poder arrastrarse en móvil o permanecer fijo como en los frames actuales.
* [ ] Reporte al PM con el detalle y pendientes.

---

### **Estimación (orientativa)**

2–3 sesiones del diseñador: ventana de trade + subasta (4 pestañas + modales).

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-ESTETICA-35: pantallas de economía (Pencil) — ventana de trade (2 lados, estados OFRECIENDO/BLOQUEADO/EXCHANGING/COMPLETADO/CANCELADO, candados por confirmación) y subasta (4 pestañas: Explorar sin filtros v1 · Mis listados · Recompensas/buzón · Historial + modal de publicar y confirmación de compra); estilo con tokens EST-13 y acentos dorados |
| 2026-10-19 | El PO entrega el rediseño de la ventana Trade con nueve estados de escritorio y nueve variantes móvil; el PM revisa composición/bounds y registra los IDs en esta HU y HU-ECONOMIA-01. |
| 2026-10-19 | El PO aprueba el inicio mediante selector de jugadores elegibles del Hub e invitación Aceptar/Rechazar antes de OFFERING; se añade a EST-35 el selector y la modal previa en PC/móvil, pendiente de frames/IDs del diseñador |
| 2026-10-21 | Se registran los nuevos frames separados de Subasta; el handoff incluye movibilidad por cabecera (R6.11) y uso de NotificationFrame R6.31. Quedan anotados estados móviles/empty y correcciones visuales pendientes antes del cierre. |
| 2026-10-21 | El diseñador entrega siete estados de Subasta en escritorio y dos en móvil; se registran sus IDs. Revisión PM anota pendientes de móvil, clipping, paginación/68 anuncios, vacíos y el redondeo del corte. |
