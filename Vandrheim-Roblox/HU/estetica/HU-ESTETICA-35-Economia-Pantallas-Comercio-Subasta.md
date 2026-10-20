# HU-ESTETICA-35: Pantallas de economía — Comercio (tradeo) y Subasta (diseñador, Pencil)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Economía / Diseño UI
**Prioridad:** Alta
**Estado:** Entrega parcial: rediseño de la ventana Trade revisado por PM; selector/invitación previa de Trade pendiente por decisión PO 2026-10-19. El resto del alcance conserva su estado.
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

* **Pestaña 1 — Explorar (catálogo):** lista paginada ordenada por **precio ascendente** (sin filtros en v1). Fila = icono + nombre + tier (color de rareza) + precio. Paginación abajo (◀ 1/3 ▶). Estado vacío ("No hay anuncios aún").
* **Pestaña 2 — Mis listados:** filas con ítem, precio, duración restante, estado (Activo/Vendido/Expirado), botones **Retirar** (solo Activo) y re-publicar si aplica. Indicador de límite (X/10 listados).
* **Pestaña 3 — Mis recompensas (buzón):** separar **Oro a cobrar** y **Ítems a cobrar** con botón **Cobrar** por fila (y "Cobrar todo"). Conteo visible de pendientes.
* **Pestaña 4 — Historial:** ventas y compras (ítem, precio, fecha, corte aplicado).
* **Ventana de PUBLICAR (sub-pantalla o modal):** casilla de ítem (elegir de la bolsa), campo **precio**, selector de **duración (24 h / 48 h)**, aviso del **fee de listado (5 oro, no reembolsable)** y del **corte 5% pagado por el vendedor** (texto breve), botón **Publicar** + confirmación.
* **Confirmación de COMPRA (modal):** ítem + precio + total a pagar + "El 5% lo paga el vendedor" → Confirmar/Cancelar.
* **Feedback:** "Ítem vendido" (al dueño), "Ya no está disponible" (compra fallida — stale), "Publicado", "Retirado", "Recompensa cobrada".
* **Detalle de tier:** usar los colores de rareza del juego (blanco/verde/azul/épica/único) en iconos, bordes y nombres.

#### **3. Reglas de diseño**

* Tokens y fuentes de EST-13; acentos **dorados** para economía (precios/oro).
* Iconos existentes por tier (ASSETS_LIST); casillas con el estándar de la HU-R6.27 (fondo negro + hover de borde).
* Ventanas con 9-slice y cierre (X), escalables sin romper en móvil (patrón de las ventanas actuales).
* Nombrar los frames: `HU-ESTETICA-35 — <pantalla>` (ej. "Trade", "Auction — Explorar", "Auction — Publicar", "Auction — Recompensas") para que el dev los referencie como en EST-22.

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
* [ ] Subasta: confirmar cobertura de sus cuatro pestañas, publicación, compra y recompensas.
* [ ] Estados y feedback visibles; casillas con el estándar (fondo negro + hover de borde).
* [ ] Coherente con tokens EST-13 y ventanas existentes; móvil OK.
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
