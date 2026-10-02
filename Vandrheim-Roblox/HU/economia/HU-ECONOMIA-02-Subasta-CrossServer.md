# HU-ECONOMIA-02: Sistema de subasta CROSS-SERVER (mercado global entre todos los servidores) — v2 revisada por dev senior

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Economía — Subasta (dev)
**Prioridad:** Alta
**Estado:** Lista para implementar tras revisión del dev senior (RC obligatorio del dev antes de programar)
**Tipo:** Sistema nuevo (dev)
**Fase GDD:** Economía 2 (decisión PO 2026-09-22; v2 tras revisión técnica 2026-09-22)
**Depende de:** **HU-ECONOMIA-03 (PREREQUISITO: seguridad de guardado de DataService)**, HU-ECONOMIA-01 (tradeo), HU-ITEMS-01 (ItemConfig/inventario), R2 (oro), HU-ESTETICA-13 (tokens)
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
| **DataStore `AuctionDB`** | **Fuente de verdad** | Una **clave por anuncio** (`listing_<id>`) con: estado (`LISTED / SOLD / EXPIRED / CANCELLED`), ítem (serializado compacto), vendedor, precio, corte, `expiresAt`, `createdAt`, flags de operación. Custodia del ítem publicada (sale del inventario del vendedor al publicar). Buzón por jugador (`mailbox_<userId>`: ítems a cobrar / oro a cobrar) e historial (`history_<userId>`). |
| **MemoryStoreSortedMap `Vandrheim_Auction_Index`** | **Índice de catálogo (reconstruible)** | Entrada mínima por anuncio activo: value = `{id, price, tier, type, itemName}` (compacto), sortKey = `price`, TTL = duración + margen. Orden por precio ascendente (`GetRangeAsync`). **Nunca contiene el ítem ni es fuente de verdad** — si falta, se reconstruye/ignora. |
| **MessagingService `Vandrheim_Auction_Events`** | **Solo avisos** (best effort) | "Nuevo listado", "Se vendió tu ítem", "Tu ítem expiró" — nunca es garantía de entrega. |

#### **2. Protocolo de operaciones (idempotente + reconciliación)**

Toda operación tiene un **`operationId` (GUID)** generado en el server y pasos que se registran antes/después de cada escritura; un **sweep de reconciliación** (tarea periódica en cada server, con lock distribuido de mantenimiento en DataStore) detecta operaciones en estado intermedio y las completa o revierte según su registro:

* **Publicar:** `op: publish` → (1) validar ítem + oro (fee 5) → (2) retirar ítem a custodia (`SetAsync` en `listing_<id>` con `UpdateAsync` atómico; registrar estado) → (3) descontar fee → (4) escribir índice MemoryStore → (5) aviso best effort. Reconciliación: si (2) hecho y (3) no → completar (3) o revertir (2).
* **Comprar (buyout):** `op: buy` → (1) `UpdateAsync` sobre `listing_<id>` (CAS: LISTED → SOLD, marca comprador y `operationId`) → (2) descontar oro al comprador (`UpdateAsync` transaccional de ECON-03) → (3) acreditar `precio × 0.95` al buzón del vendedor → (4) entregar ítem al buzón del comprador → (5) historial de ambos → (6) quitar del índice + aviso. Reconciliación: si (1) hecho y (2) falló → revertir (1) (vuelve a LISTED); si (2) hecho y (3/4) no → completar (3/4) (idempotente por `operationId`).
* **Cancelar:** solo si estado LISTED; `UpdateAsync` CAS LISTED → CANCELLED → ítem al buzón del vendedor → quitar del índice. Sin reembolso del fee.
* **Expirar (sweep autoritativo):** por **fecha del registro en DataStore** (`expiresAt`), NO por TTL del índice: tarea de mantenimiento (un server a la vez, lock) recorre anuncios vencidos LISTED → EXPIRED → ítem al buzón del vendedor → quitar del índice. El TTL del índice solo evita entradas fantasma; una compra sobre un índice obsoleto falla el CAS con "ya no disponible" y re-sincroniza.
* **Cobrar (buzón):** el jugador reclama oro/ítems desde "Mis recompensas" — entrega idempotente (marcar `delivered` por `operationId`).

#### **3. Funcionalidad MVP (buyout — sin pujas)**

* **Publicar:** ítem + **precio** + **duración 24 h / 48 h**. **Fee 5 oro** (no reembolsable). Máx. **10 listados activos** por jugador. El ítem pasa a custodia (fuera del inventario).
* **Explorar:** catálogo **ordenado por precio ascendente**, paginado (20/página), **sin filtros en v1** (decisión PO — se agregan en fase posterior con índices adicionales); pestañas **Mis listados / Mis recompensas / Historial**.
* **Comprar:** buyout atómico (CAS sobre la clave del anuncio). **Comprador paga el precio exacto**; **vendedor recibe `precio × 0.95`** (corte 5% pagado por el vendedor — sink de oro).
* **Cross-server:** automático: el anuncio vive en DataStore (visible desde cualquier server vía índice MemoryStore compartido); la compra usa `UpdateAsync` sobre la clave del anuncio (un solo server gana el CAS; los demás reciben "no disponible").

#### **4. Config**

* `AuctionConfig`: `feeListing = 5`, `saleCut = 0.05` (**pagado por el vendedor**), `maxListings = 10`, `durations = {24, 48}`, `pageSize = 20`, `indexTtlMarginHours = 2`, `reconcileInterval = 120` s, `expirySweepInterval = 300` s, `globalListingCap = 10000`.

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

#### **Escenario 6: Límites**

* **GIVEN** un jugador con 10 listados activos
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

* **Pujas (bidding)** ni **filtros de catálogo** — fase posterior. Ni tradeo directo (ECON-01). **PREREQUISITO: ECON-03** (sin ella NO se implementa esto).

---

### **Definition of Done (DoD)**

* [ ] HU-ECONOMIA-03 implementada y verificada (session lock + updates transaccionales).
* [ ] Subasta cross-server funcional: compra atómica (CAS por clave de anuncio) sin duplicación ni pérdida en concurrencia y con fallos de server (reconciliación probada).
* [ ] Expiración por DataStore (no por TTL del índice); impuesto 5% pagado por el vendedor (precio exacto para el comprador).
* [ ] Catálogo por precio ascendente, caché por servidor, sin filtros v1; límites activos (10/jugador, cap global).
* [ ] Sin errores rojos y balances consistentes tras reinicios multi-servidor.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Decisiones cerradas (PO 2026-09-22, tras revisión del dev senior)**

| Tema | Decisión |
|------|----------|
| Fuente de verdad | **DataStore** (anuncio por clave, custodia, buzones, historial) |
| Índice de catálogo | **MemoryStoreSortedMap** por precio (reconstruible, entradas mínimas) |
| Avisos | MessagingService solo best effort (nunca garantía) |
| Tipo de venta | Buyout (sin pujas en v1) |
| Duración | 24 h / 48 h (expiración por `expiresAt` en DataStore) |
| Fee de listado | **5 oro** (no reembolsable) |
| Corte de venta | **5% pagado por el VENDEDOR** (comprador paga el precio exacto) |
| Listados máx. | 10 por jugador (+ cap global 10,000) |
| Filtros de catálogo | **Ninguno en v1** (precio ascendente; filtros con índices en fase posterior) |
| Concurrencia/fallos | `operationId` + pasos idempotentes + reconciliación periódica |
| Prerequisito | **ECON-03** (seguridad de DataService) — bloqueante |

---

### **Estimación (orientativa, revisada)**

4–6 sesiones del dev (la v1 estimaba 3–4; el protocolo de operaciones/reconciliación suma complejidad — confirmado por el dev senior).

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación v1 de HU-ECONOMIA-02 (MemoryStore como fuente de verdad) |
| 2026-09-22 | **v2 tras revisión del dev senior:** MemoryStore como fuente de verdad era inseguro (UpdateAsync cubre una clave, no la operación completa) → **DataStore autoritativo por clave + MemoryStore solo índice + protocolo con `operationId`/idempotencia/reconciliación**; expiración por `expiresAt` (no TTL); filtros fuera del MVP; corte 5% pagado por el vendedor (comprador paga precio exacto); **nuevo prerequisito ECON-03** (DataService sin session lock confirmado en Studio — GetAsync/SetAsync completos) |