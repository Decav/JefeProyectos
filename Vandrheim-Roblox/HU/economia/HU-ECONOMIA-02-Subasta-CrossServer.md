# HU-ECONOMIA-02: Sistema de subasta CROSS-SERVER (mercado global entre todos los servidores) — v2 revisada por dev senior

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Economía — Subasta (dev)
**Prioridad:** Alta
**Estado:** ECON-03 está implementada según confirmación del PO. P4 (elegibilidad), P9 (NPC en Hub) y P10 (diseños PC/móvil) confirmados; el resto de P1–P14 se registra como propuesta para aprobación final. RC103 permanece ABIERTO.
**Tipo:** Sistema nuevo (dev)
**Fase GDD:** Economía 2 (decisión PO 2026-09-22; v2 tras revisión técnica 2026-09-22)
**Depende de:** **HU-ECONOMIA-03 (PREREQUISITO: seguridad de guardado de DataService)**, HU-ECONOMIA-01 (tradeo), HU-ITEMS-01 (ItemConfig/inventario), R2 (oro), HU-ESTETICA-13 (tokens), HU-R6.11 (ventanas movibles), HU-R6.31 (NotificationFrame/NotificationSystem), HU-ESTETICA-35 (diseño visual de Subasta)
**Componentes observados:** `InventoryService`, oro del jugador, `DataService` (GetAsync/SetAsync sin session lock — riesgo confirmado), `ItemConfig`

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** un **mercado de subasta global** donde las ventas de **todos los servidores** estén disponibles para todos (comprar un ítem que otro jugador publicó desde otro servidor),
**para** que la economía siempre tenga flujo: vender lo que me sobra y encontrar ítems de otros, con gasto continuo de oro.

---

### **Descripción del Requerimiento / Contexto**

**Objetivo del PO:** ventas de **todos los jugadores, no solo del servidor local**; compra cross-server; flujo continuo de gasto de oro.

### **Investigación (2026-09-22, docs oficiales Roblox + revisión del dev senior)**

**SÍ es posible 100% nativo (sin base de datos externa)** — Roblox cita las subastas cross-server como caso de uso de MemoryStore. **Pero la v1 de esta HU no era segura económicamente: la garantía atómica de `UpdateAsync` cubre UNA clave, no simultáneamente la compra (oro del comprador + ítem + buzón del vendedor + historial). Un fallo del servidor entre pasos podía dejar: compra cobrada sin ítem, venta sin pago o ítem duplicado.**

**Hallazgos de la revisión (dev senior, 2026-09-22):**

1. **Expiración:** MemoryStore elimina la entrada al vencer su TTL — si el ítem vive solo ahí, un barrido posterior ya no puede recuperarlo; y un mapa ordenado por precio no se barre eficientemente por fecha de vencimiento. → **Fix:** el registro durable vive en **DataStore** (con su propia fecha de expiración y sweep autoritativo); el TTL de MemoryStore solo limpia el **índice** (no crítico: es reconstruible).
2. **Capacidad:** 1M entradas/100 MB son máximos de mapa; la cuota real de memoria del universo parte de **64 KB + 1,2 KB × jugadores concurrentes**; una página de 20 anuncios consume ~20 unidades de lectura. → **Fix:** entradas de índice **mínimas** (listingId + precio + resumen compacto), **caché por servidor** + refresco suave; sin paginaciones masivas.
3. **Filtros:** el mapa ordena por una clave (precio); no hay búsqueda por nombre ni filtros simultáneos por tipo/tier; filtrar tras leer 20 anuncios da páginas vacías. → **Fix (decisión PO):** **MVP v1 SIN filtros** — catálogo ordenado por **precio ascendente** + pestañas **Mis listados / Mis recompensas / Historial** (por jugador, desde DataStore). Filtros en fase posterior (índices adicionales).
4. **Impuesto ambiguo:** "comprador paga 105 y vendedor recibe 95" retira 10, no 5. → **Decisión PO:** el **5% lo paga el vendedor** (recibe `precio × 0.95`); el **comprador paga exactamente el precio publicado**. Fee de listado (5 oro) no reembolsable, aparte.
5. **Riesgo de proyecto (confirmado):** `DataService` guarda el perfil completo con `SetAsync` sin **session lock** real (el comentario no se corresponde con implementación). Dos servidores pueden sobrescribir oro/inventario del otro. → **PREREQUISITO: HU-ECONOMIA-03** (bloqueo de sesión + actualizaciones transaccionales con `UpdateAsync` por clave).

**Arquitectura final (recomendación del dev senior adoptada):**

> **DataStore = registro durable y autoritativo de cada anuncio, custodia del ítem y operaciones. MemoryStore = solo índice rápido del catálogo por precio (reconstruible). MessagingService = solo avisos (best effort).** Toda operación (publicar, comprar, cancelar, entregar, reembolsar) lleva **operationId**, pasos **idempotentes** y **reconciliación** tras fallos.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Roles de los servicios**

| Servicio | Rol | Detalle |
|----------|-----|---------|
| **DataStore `AuctionDB`** | **Fuente de verdad** | Una **clave por anuncio** (`listing_<id>`) con estado (`LISTED / SOLD / EXPIRED / CANCELLED`), ítem/cantidad en custodia, vendedor, precio, corte, `expiresAt`, `createdAt` y flags/opIds. Además: buzón (`mailbox_<userId>`), historial (`history_<userId>`, últimas 50 entradas por cuenta), índice de listados por vendedor (`seller_index_<userId>`) y buckets de expiración por hora. Los dos últimos son auxiliares reconstruibles; los registros `listing_<id>` son la autoridad. |
| **MemoryStoreSortedMap `Vandrheim_Auction_Index`** | **Índice de catálogo (reconstruible)** | Entrada mínima por anuncio activo: value = `{id, price, tier, type, itemName}` (compacto), sortKey = `price`, TTL = duración + margen. Orden por precio ascendente (`GetRangeAsync`). **Nunca contiene el ítem ni es fuente de verdad** — si falta, se reconstruye/ignora. |
| **MessagingService `Vandrheim_Auction_Events`** | **Solo avisos** (best effort) | "Nuevo listado", "Se vendió tu ítem", "Tu ítem expiró" — nunca es garantía de entrega. |

#### **2. Protocolo de operaciones (idempotente + reconciliación)**

Toda operación tiene un **`operationId` (GUID)** generado en el server y pasos que se registran antes/después de cada escritura; un **sweep de reconciliación** (tarea periódica en cada server, con lock distribuido de mantenimiento en DataStore) detecta operaciones en estado intermedio y las completa o revierte según su registro:

* **Publicar:** `op: publish` → (1) validar ítem libre/no equipado/no vinculado, cantidad y precio → (2) en un solo `UpdateAsync` ECON-03 del perfil, retirar el ítem/cantidad y el fee 5 oro con el mismo `operationId` → (3) crear el registro durable `listing_<id>` LISTED → (4) actualizar índices de vendedor, expiración y MemoryStore → (5) aviso best effort. Si el registro LISTED nunca queda durable, reconciliar devolviendo ítem/cantidad y fee; después de LISTED, el fee no se reembolsa aunque se retire o expire.
* **Comprar (buyout):** `op: buy` → (1) validar anuncio/listing y que comprador≠vendedor → (2) retener el precio exacto en el perfil del comprador con `UpdateAsync` ECON-03 y `operationId` → (3) CAS `listing_<id>` LISTED → SOLD marcando comprador/opId → (4) si el CAS pierde o el anuncio ya no está disponible, liberar el hold del comprador idempotentemente; si gana, convertirlo en cobro → (5) acreditar el neto del vendedor y entregar ítem/cantidad al buzón del comprador → (6) escribir historial y actualizar índices. La reconciliación resuelve holds/CAS por `operationId`; el comprador nunca pierde oro por una compra que perdió la carrera.
* **Cancelar:** solo si estado LISTED; `UpdateAsync` CAS LISTED → CANCELLED → ítem/cantidad al buzón del vendedor → quitar de los índices. Sin reembolso del fee.
* **Expirar (sweep autoritativo):** los buckets horarios solo proponen candidatos; validar siempre `expiresAt` en el registro `listing_<id>` de DataStore. Si venció: LISTED → EXPIRED → ítem/cantidad al buzón del vendedor → quitar índices. El TTL/índice nunca es la garantía.
* **Cobrar (buzón):** el jugador reclama oro/ítems desde "Mis recompensas" — entrega idempotente (marcar `delivered` por `operationId`).
* **Índices auxiliares:** `seller_index_<userId>` (Mis listados/límite) y `expiry_bucket_<hour>` (candidatos al sweep) aceleran consultas y barridos. Se actualizan de manera idempotente y se reconstruyen desde `listing_<id>`; nunca son fuente de verdad.

#### **3. Funcionalidad MVP (buyout — sin pujas)**

* **Publicar:** cualquier ítem de mochila `Free`, no equipado y sin lock/custodia (`tradeLocked`/auction). Incluir tokens. En ítems stackable se puede elegir una cantidad parcial entera; el precio ingresado corresponde al lote completo. Precio entero `1..1,000,000`, duración 24 h / 48 h, fee 5 oro. Máx. 10 listados activos por `UserId` sin perk o 20 con `perks.auctionPlus10`, compartidos entre PJs.
* **Explorar:** catálogo ordenado por precio ascendente, 20 anuncios/página, sin filtros v1; cache por servidor y página durante 10 s. Los datos de cache sirven para mostrar, nunca para autorizar compra; la compra siempre valida el registro durable por CAS.
* **Comprar:** buyout atómico. El comprador paga exactamente el precio publicado; `corte = floor(precio × 0.05 + 0.5)` (oro entero más cercano, mitad hacia arriba), `netoVendedor = precio - corte`. No se permite comprar el propio anuncio.
* **Cross-server:** automático: el anuncio vive en DataStore (visible desde cualquier server vía índice MemoryStore compartido); la compra usa `UpdateAsync` sobre la clave del anuncio (un solo server gana el CAS; los demás reciben "no disponible").
* **Acceso:** solo mediante `ProximityPrompt` del NPC de Subasta en el Hub; no abrir desde micromenú ni un botón móvil global. El prompt abre la misma `AuctionUI` en PC/móvil.
* **UI de Subasta:** implementar las pestañas/estados con los frames y nodos de HU-ESTETICA-35 §2. Registrar `AuctionUI`/`MainFrame` en `WindowLayoutClient` para drag, foco y clamp; el jugador la mueve arrastrando su cabecera dentro del área visible. No persistir la posición, igual que las ventanas temporales de R6.11.
* **Feedback:** publicar, retirar, vender, compra stale/no disponible, expirar y cobrar recompensas usan el `NotificationFrame`/`NotificationSystem` de HU-R6.31; no crear toasts ni avisos sueltos nuevos. Los modales quedan solo para confirmar publicar/compra.
* El catálogo no filtra por rareza; debe poder representar los cinco tiers del juego (Common, Uncommon, Rare, Epic, Unique) con sus colores/nombres correspondientes.
* `Vandrheim-design.pen` es solo referencia visual. Nombres, iconos, `wieldType`, rareza, precios, balances, fechas, cantidades, estados, conteos y paginación siempre se alimentan de los datos/configuración reales (`ItemConfig`, `AuctionConfig` y registros del mercado); los ejemplos del diseño no se hardcodean.

#### **3.1. Referencia visual y estado del handoff (HU-ESTETICA-35)**

| Estado | Frame Pencil | ID |
|---|---|---|
| Explorar | `HU-ESTETICA-35 — Auction · 01 Explorar` | `yHHUX` |
| Mis listados | `HU-ESTETICA-35 — Auction · 02 Mis listados` | `oDV8o` |
| Recompensas | `HU-ESTETICA-35 — Auction · 03 Recompensas` | `DV62E` |
| Historial | `HU-ESTETICA-35 — Auction · 04 Historial` | `k1PsJW` |
| Publicar | `HU-ESTETICA-35 — Auction · 05 Publicar` | `LVod8` |
| Confirmar compra | `HU-ESTETICA-35 — Auction · 06 Confirmar compra` | `N5kifd` |
| Explorar vacío | `HU-ESTETICA-35 — Auction · 07 Explorar (vacío)` | `Tujod` |
| Mis listados vacío | `HU-ESTETICA-35 — Auction · 02b Mis listados (vacío)` | `E2SzS` |
| Recompensas vacío | `HU-ESTETICA-35 — Auction · 03b Recompensas (vacío)` | `c5XlOD` |
| Historial vacío | `HU-ESTETICA-35 — Auction · 04b Historial (vacío)` | `Clph1` |
| Móvil: Explorar | `HU-ESTETICA-35 — Auction · Móvil 01 Explorar` | `g86mLr` |
| Móvil: Explorar vacío | `HU-ESTETICA-35 — Auction · Móvil 02b Explorar (vacío)` | `jsV6p` |
| Móvil: Publicar | `HU-ESTETICA-35 — Auction · Móvil 02 Publicar` | `OBg6P` |
| Móvil: Mis listados | `HU-ESTETICA-35 — Auction · Móvil 03 Mis listados` | `sc7cd` |
| Móvil: Mis listados vacío | `HU-ESTETICA-35 — Auction · Móvil 03b Mis listados (vacío)` | `Q2ZRh` |
| Móvil: Recompensas | `HU-ESTETICA-35 — Auction · Móvil 04 Recompensas` | `lCsbX` |
| Móvil: Recompensas vacío | `HU-ESTETICA-35 — Auction · Móvil 04b Recompensas (vacío)` | `qdQSn` |
| Móvil: Historial | `HU-ESTETICA-35 — Auction · Móvil 05 Historial` | `JdlBX` |
| Móvil: Historial vacío | `HU-ESTETICA-35 — Auction · Móvil 05b Historial (vacío)` | `cac6B` |
| Móvil: Confirmar compra | `HU-ESTETICA-35 — Auction · Móvil 06 Confirmar compra` | `BGF7k` |

El agregado antiguo `V6A4f` queda supersedido; integrar los estados separados anteriores. Los scrolls ocultan filas fuera del viewport intencionalmente y deben mantener visibles filas completas.

**Pendientes visuales observados:** sincronizar el estado Confirmar compra (en especial móvil) con la paginación `1/4`; corregir la etiqueta `MANO DERECHA` del Arco de escarcha a `DOS MANOS · 2H` y la ilustración de Espada del campeón para que concuerde con su `wieldType=OneHand`; unificar las etiquetas de rareza con los nombres canónicos del juego. El diseñador anotó también que en móvil la ventana queda fija; confirmar si el drag pedido aplica solo a escritorio o también a móvil.

**Redondeo cerrado por el PO (2026-10-21):** corte al oro entero más cercano, mitades hacia arriba. Ejemplo: precio 205 → corte 10, neto del vendedor 195; el comprador paga 205. La liquidación conserva oro entero y `netoVendedor = precio - corte`.

#### **4. Config**

* `AuctionConfig`: `feeListing = 5`, `saleCut = 0.05`, `minPrice = 1`, `maxPrice = 1000000`, `maxListingsBase = 10`, `maxListingsWithPerk = 20`, `durations = {24, 48}`, `pageSize = 20`, `catalogCacheTtl = 10` s por servidor/página, `indexTtlMarginHours = 2`, `reconcileInterval = 120` s, `expirySweepInterval = 300` s, `globalListingCap = 10000` (soft cap aproximado).


### **Propuesta para cerrar P1–P14 en RC103**

P4, P9 y P10 recogen las confirmaciones directas del PO; las demás son recomendaciones para aprobar o ajustar. Mantener RC103 ABIERTO hasta que el PO confirme.

| # | Decisión |
|---|---|
| P1 — orden de compra | Retener el precio en el perfil del comprador con `operationId`; después CAS LISTED→SOLD. Si el CAS pierde/falla, soltar el hold idempotentemente; solo el ganador convierte el hold en cobro y completa la entrega. |
| P2 — publicar | Retirar ítem/cantidad y fee en un solo `UpdateAsync` del perfil. Si el listing no llega a LISTED durable, devolver ambos por reconciliación; después de LISTED el fee no se devuelve al retirar/expirar. |
| P3 — índices extra | Mantener índice de listados por cuenta y buckets de expiración por hora. Son secundarios y reconstruibles; `listing_<id>` sigue siendo la fuente de verdad. |
| P4 — ítems/cantidad | **Confirmado por PO:** permitir cualquier ítem no vinculado ni equipado, fichas incluidas. Recomendación: rechazar también ítems con lock/custodia; permitir cantidad parcial en pilas stackable, con precio total por lote y remanente en la mochila. |
| P5 — precio | Entero entre 1 y 1.000.000 de oro, inclusive. |
| P6 — compra propia | Rechazar la compra del propio anuncio antes de retener oro. |
| P7 — historial | Conservar las últimas 50 entradas por `UserId`, compartidas entre sus personajes. |
| P8 — caché | Cache de 10 s por servidor y página; un precio/cache stale nunca autoriza la compra, siempre CAS al registro durable. |
| P9 — acceso | Solo ProximityPrompt de NPC de Subasta en el Hub; nada de micromenú ni botón móvil global. |
| P10 — responsive | Usar los frames PC y móvil específicos de HU-ESTETICA-35 para todos los tabs/estados; no fallback escalado donde existe frame móvil. |
| P11 — Studio | Persistencia desactivada = RAM. Persistencia de prueba = AuctionDB separado y perfiles/test users dedicados; no gastar oro de perfiles reales o de producción. Las compras de Studio no generan cobros Robux reales. |
| P12 — `token_auction` | Al canjear, `perks.auctionPlus10` eleva el límite de 10 a 20 por `UserId`, compartido entre personajes. |
| P13 — re-publicar | Fuera de v1: expirado devuelve el ítem/cantidad al buzón; el jugador lo reclama y crea un listing nuevo pagando otro fee. |
| P14 — tope global | 10.000 anuncios es un soft cap operativo aproximado medido con el índice; puede desviarse en concurrencia. No sustituye límites ni CAS por anuncio. |

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Compra cross-server**

* **GIVEN** jugador A publica en el servidor 1
* **WHEN** jugador B en el **servidor 2** compra
* **THEN** B paga el precio exacto, el ítem llega a su buzón, A recibe `precio × 0.95` en su buzón, y el anuncio queda SOLD (sin duplicados ni pérdidas)

#### **Escenario 2: Compra concurrente (anti-dupe)**

* **GIVEN** dos jugadores compran el mismo anuncio a la vez
* **WHEN** ambos confirman
* **THEN** solo uno gana el CAS (SOLD); el otro recibe "ya no está disponible" y su oro intacto

#### **Escenario 3: Fallo a mitad de compra (reconciliación)**

* **GIVEN** un server falla tras marcar SOLD pero antes de entregar
* **WHEN** la reconciliación corre
* **THEN** la operación se completa (oro e ítem en sus buzones) usando el `operationId` — nadie pierde ni duplica

#### **Escenario 4: Expiración correcta**

* **GIVEN** un anuncio vencido (por `expiresAt` en DataStore)
* **WHEN** corre el sweep de expiración
* **THEN** el ítem vuelve al buzón del vendedor y el anuncio pasa a EXPIRED (el TTL del índice no es la garantía)

#### **Escenario 5: Impuesto claro**

* **GIVEN** un anuncio de precio 100 vendido
* **WHEN** se cobra
* **THEN** el comprador pagó 100 y el vendedor recibe 95 (5% pagado por el vendedor — 5 salen de circulación, no 10)

#### **Escenario 5a: Redondeo del corte**

* **GIVEN** un anuncio de precio 205 oro
* **WHEN** se vende y se liquida
* **THEN** el corte del vendedor es 10 oro (10,25 redondeado al entero más cercano, mitad hacia arriba), el vendedor recibe 195 y el comprador paga 205

#### **Escenario 6: Límites**

* **GIVEN** una cuenta (`UserId`) con 10 listados activos entre sus personajes
* **WHEN** intenta publicar otro
* **THEN** el server lo rechaza con mensaje

#### **Escenario 7: DataService seguro (prerequisito)**

* **GIVEN** HU-ECONOMIA-03 implementada
* **WHEN** dos servidores actualizan el oro del mismo jugador
* **THEN** no hay sobrescrituras (session lock + `UpdateAsync` por clave)

#### **Escenario 8: Regresión y economía**

* **GIVEN** la subasta activa (varios servidores)
* **WHEN** se juega el flujo completo (publicar → comprar → cobrar → gastar; reinicios de server en el medio)
* **THEN** no hay errores rojos, los balances quedan consistentes y el oro circula (el 5% + fee salen del juego)

---

### **Alcance**

#### Incluye

* DataStore autoritativo (anuncios por clave, custodia, buzones, historial) + índice MemoryStore por precio + MessagingService de avisos.
* Protocolo de operaciones con `operationId`, pasos idempotentes y reconciliación.
* Buyout, pestañas por jugador, fees/cortes claros, expiración por DataStore.

#### No incluye

* **Pujas (bidding)** ni **filtros de catálogo** — fase posterior. Ni tradeo directo (ECON-01). El prerequisito ECON-03 está implementado según confirmación del PO.

---

### **Definition of Done (DoD)**

* [x] HU-ECONOMIA-03 implementada (confirmado por PO); adjuntar/verificar la evidencia de integración en RC103.
* [ ] Subasta cross-server funcional: compra atómica (CAS por clave de anuncio) sin duplicación ni pérdida en concurrencia y con fallos de server (reconciliación probada).
* [ ] Expiración por DataStore (no por TTL del índice); impuesto 5% pagado por el vendedor (precio exacto para el comprador).
* [ ] Catálogo por precio ascendente, caché por servidor, sin filtros v1; límites activos (10/jugador, cap global).
* [ ] La UI usa los frames/IDs de §3.1; muestra los cinco tiers y representa 20 anuncios por página con la lista desplazable y paginación coherente.
* [ ] `AuctionUI.MainFrame` se mueve por cabecera, permanece dentro del viewport y no guarda posición entre sesiones.
* [ ] Los avisos de operación usan NotificationFrame/NotificationSystem de R6.31; hay feedback claro para publicar, retirar, vender, stale, expirar y cobrar.
* [ ] Mis listados, Recompensas e Historial incluyen estado vacío; los avisos de resultado no crean modales/toasts nuevos.
* [ ] Móvil cubre Explorar, Mis listados, Recompensas, Historial, Publicar y Confirmar compra; botones interactivos con hitbox ≥44×44 px y safe area.
* [ ] P1/P2: hold de oro antes del CAS; fallos de compra liberan hold y fallos de publicación antes de LISTED restauran ítem/cantidad + fee.
* [ ] Elegibilidad: bound/equiped/locked/custody rechazados; stackable acepta cantidad parcial con retorno del remanente.
* [ ] Precio 1..1.000.000, integer; own-listing rejects; max history 50/account; cache 10 s/page; P9 NPC-only; P12 token perk cap; P13 no direct relist; P14 soft cap verified.
* [ ] Studio testing never touches production user profiles/gold; persistence-on testing uses isolated test profiles/data store.
* [ ] Sin errores rojos y balances consistentes tras reinicios multi-servidor.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Decisiones cerradas (PO; actualizadas 2026-10-21)**

| Tema | Decisión |
|------|----------|
| Fuente de verdad | **DataStore** (anuncio por clave, custodia, buzones, historial) |
| Índice de catálogo | **MemoryStoreSortedMap** por precio (reconstruible, entradas mínimas) |
| Avisos | MessagingService solo best effort (nunca garantía) |
| Tipo de venta | Buyout (sin pujas en v1) |
| Duración | 24 h / 48 h (expiración por `expiresAt` en DataStore) |
| Fee de listado | **5 oro** (no reembolsable) |
| Corte de venta | **5% pagado por el VENDEDOR** (comprador paga el precio exacto) |
| Redondeo del corte | Oro entero más cercano, mitades hacia arriba; `corte=floor(precio×0.05+0.5)`, `neto=precio-corte` |
| Listados máx. | 10 base / 20 con `token_auction`, por cuenta (`UserId`, compartidos entre PJs); soft cap global aproximado 10,000 |
| Filtros de catálogo | **Ninguno en v1** (precio ascendente; filtros con índices en fase posterior) |
| Concurrencia/fallos | `operationId` + pasos idempotentes + reconciliación periódica |
| Prerequisito | **ECON-03 implementada** (confirmación PO 2026-10-21); evidence of integration checked in RC103 |

---

### **Estimación (orientativa, revisada)**

4–6 sesiones del dev (la v1 estimaba 3–4; el protocolo de operaciones/reconciliación suma complejidad — confirmado por el dev senior).

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación v1 de HU-ECONOMIA-02 (MemoryStore como fuente de verdad) |
| 2026-09-22 | **v2 tras revisión del dev senior:** MemoryStore como fuente de verdad era inseguro (UpdateAsync cubre una clave, no la operación completa) → **DataStore autoritativo por clave + MemoryStore solo índice + protocolo con `operationId`/idempotencia/reconciliación**; expiración por `expiresAt` (no TTL); filtros fuera del MVP; corte 5% pagado por el vendedor (comprador paga precio exacto); **nuevo prerequisito ECON-03** (DataService sin session lock confirmado en Studio — GetAsync/SetAsync completos) |
| 2026-10-19 | Se precisa que `maxListings` es por cuenta (`UserId`) y compartido entre sus personajes; ECON-04 usa el mismo ámbito para `token_auction` |
| 2026-10-21 | El PO cierra el redondeo del corte de venta: oro entero más cercano, mitad hacia arriba; comprador paga siempre el precio publicado y vendedor recibe el neto restante. |
