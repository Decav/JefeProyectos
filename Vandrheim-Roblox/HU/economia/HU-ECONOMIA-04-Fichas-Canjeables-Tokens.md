# HU-ECONOMIA-04: Fichas canjeables (tokens) — compra con Robux, venta por oro, canje de perks (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Economía / Monetización — Tokens (dev)
**Prioridad:** Alta
**Estado:** Pendiente del diseño visual HU-ESTETICA-49 y del RC del dev antes de programar
**Tipo:** Sistema nuevo (dev) — modelo PLEX/Bond
**Fase GDD:** Economía 4 (decisión PO 2026-10-12: **todo Dev Product, sin Game Passes**)
**Depende de:** HU-ECONOMIA-03 (perfil atómico — mutaciones con `UpdateAsync`), HU-ECONOMIA-01/02 (tradeo/subasta: los tokens son ítems normales y circulan por ahí), HU-R6.28 (precedente `ProcessReceipt` + grant eventual), HU-R4 (ítems de inventario), HU-ITEMS-01 (templates en `ItemConfig`), HU-ESTETICA-49 (Tienda, Compras pendientes e iconos)
**Componentes observados:** `MarketplaceService.ProcessReceipt`, inventario/perfil, subasta (ECON-02), `AuctionConfig`

---

### **Narrativa (INVEST)**

**Como** jugador que paga,
**quiero** comprar fichas con Robux y **usarlas o venderlas por oro** en la subasta,
**para** elegir entre quedarme el perk o ganar oro.

**Como** jugador free-to-play,
**quiero** comprar esas fichas con oro a otros jugadores,
**para** conseguir perks de pago sin dinero real.

**Como** equipo,
**quiero** un único mecanismo de compra (todo Dev Product),
**para** no mantener dos sistemas (Game Pass + Dev Products) ni permisos no transferibles.

---

### **Descripción del Requerimiento / Contexto**

Modelo PLEX/Bond (decisión PO 2026-10-12): todo lo comprable con dinero real existe como **token** (ítem consumible). Se compra con Robux (Dev Product repetible) → queda en el buzón durable de la cuenta → el jugador lo reclama en el inventario de un PJ existente → se **consume** (canjea el perk permanente) o se **vende** (tradeo/subasta por oro). **Sin Game Passes**: R2.1 (slot 3) y los perks de `MONETIZATION.md` usan este sistema.

**Criterio de hecho global:** comprar con Robux da el token; el token se consume (perk permanente) o se vende por oro; un F2P puede obtener cualquier perk solo con oro; sin dupes ni pérdidas.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Tokens (templates en `ItemConfig`)**

| Token | Nombre del Developer Product | ProductId | Precio (Robux) | Ámbito y efecto al canjear |
|-------|------------------------------|-----------|----------------|----------------------------|
| `token_slot3` — Pase: Tercer Personaje | `Vandrheim Token - Tercer slot de personaje` | `3718622291` | 149 | **Cuenta:** `perks.slot3 = true` → `maxSlots = 3` |
| `token_bag` — Pase: Mochila Ampliada | `Vandrheim Token - Mochila ampliada` | `3720053583` | 99 | **Personaje que canjea:** `perks.bagPlus10 = true` → `bagSlots = 30` solo para ese PJ |
| `token_auction` — Pase: Subasta Ampliada | `Vandrheim Token - Mejora de subasta` | `3720054258` | 79 | **Cuenta:** `perks.auctionPlus10 = true` → `maxListings = 20` por `UserId`, según ECON-02 (límite por jugador) |
| `token_rename` — Pergamino de Renombre | `Vandrheim Token - Renombrar personaje` | `3720053841` | 49 | **Personaje elegido:** abre el flujo R2 para cambiar el nombre de ese PJ y se consume al aplicar |

* Tokens: `stackable=true` (apilables), tradeables y subastables como cualquier ítem; los placeholders de icono se conservan hasta que el PO genere los finales con ImageGen.
* Los cuatro Developer Products fueron creados por el PO en el Dashboard; nombres, `ProductId` y precios de la tabla son la referencia aprobada al 2026-10-19.
* El revive `Vandrheim Token - Revivir en Mazmorra` (`3717359753`, 49 Robux) es un Developer Product separado de estas cuatro fichas; su comportamiento pertenece a HU-R6.28.

#### **2. Compra con Robux → buzón de cuenta → personaje elegido (server-authoritative)**

* Cada Developer Product es repetible. `ProcessReceipt` valida/idempotencia por `ReceiptId` y registra un grant pendiente en el **buzón de compras de la cuenta (`UserId`)**, sin asignar el recibo al personaje que estuviera activo.
* La confirmación del recibo y el grant pendiente usan el contrato seguro de ECON-03; el recibo no se marca resuelto antes de que el grant quede durable.
* En la UI mínima **Compras pendientes** (accesible desde Selección de Personaje), el usuario elige uno de sus personajes existentes para reclamar el token. El servidor valida que el `characterId` pertenezca al mismo `UserId`, acredita el token a ese inventario y marca el reclamo idempotentemente.
* Si el usuario aún no tiene un personaje disponible, su mochila no tiene espacio o el perfil del PJ está bajo el lock temporal de ECON-01 (`RESERVING`/`LOCKED`/`EXCHANGING`), el grant permanece pendiente; reclamarlo después de liberar el lock no genera duplicados. No se crea correo jugador-a-jugador ni un sistema general de mensajería.
* **Referencia visual:** HU-ESTETICA-49 define la Tienda, Compras pendientes y los cuatro iconos. La CTA **Comprar** abre el diálogo nativo de Developer Product de Roblox; no se crea un checkout propio.
* **Frames que debe revisar el dev antes de integrar** (`Vandrheim-design.pen`, HU-ESTETICA-49): Tienda PC `vz1I4`; Compras pendientes PC `A5qnV`; estados PC — buzón vacío `NnQab`, sin personaje `HeP0v`, mochila llena `Mb9oU`, bloqueado por trade `s8qaB3`, reclamado `Bmm0J`; móvil — Tienda `yoN7T` y Compras pendientes `ARHRK`.
* **Pendientes observados en el handoff visual:** conservar por ahora los cuatro placeholders de iconos; el PO generará después los finales con ImageGen, así que esto no bloquea la integración inicial. Los targets móviles de pestañas, Comprar, Reclamar y cerrar están por debajo de 44×44 px; los estados vacío/sin personaje/mochila llena/bloqueado/reclamado no tienen variante móvil. Coordinar con el diseñador la actualización de estos puntos; mantener los placeholders hasta recibir assets finales.

#### **3. Canje (consumir el token)**

1. Usar token desde la mochila → el servidor valida: token en posesión, no reservado por ECON-01 (`tradeLocked`) ni en custodia de ECON-02, perk **no** poseído y funcionalidad disponible. Si ECON-02 aún no existe, `token_auction` no se consume ni activa el perk.
2. Si ya posee el perk → **rechaza el canje** (con aviso) — el token sigue sirviendo para vender.
3. Si válido → aplica el perk al ámbito indicado en la tabla (§1), vía ECON-03, y **consume el token** en la misma operación idempotente.
4. Rename: el pergamino abre un modal provisional para el personaje que lo usa; validar exactamente las reglas R2 antes de cambiar el nombre y consumir el token: 3–16 caracteres, alfanumérico con espacios internos limitados y trim, rechazar vacío/solo espacios, usar el filtro Roblox y no exigir unicidad global.

#### **4. Venta por oro**

* Los tokens circulan por **tradeo (ECON-01)** y **subasta (ECON-02)** como ítems normales (con su corte del 5 % en subasta — gold sink).
* El mercado fija el precio en oro libremente; el juego no vende perks por oro en vendors (solo entre jugadores).

#### **5. Reglas**

* Solo conveniencia (los 4 perks), nunca poder — anti pay-to-win intacto.
* Sin dupes: recibos idempotentes + mutaciones atómicas (ECON-03); el token consumido desaparece (pila −1).
* Un token = un canje; los flags son permanentes e irreversibles (sin reembolso de perk).
* Las descripciones visibles de tokens (`ItemConfig.description`/tooltip y tarjeta de Tienda) explican solo efecto/uso; no mencionan venta ni intercambio con otros jugadores. La comerciabilidad permanece como regla funcional, no como copy del ítem; el fix de presentación se sigue en HU-R6.36.
* Los tokens no se asignan a los slots rápidos Z/X; se canjean explícitamente desde la mochila.
* `token_bag` aumenta a 30 las casillas del personaje que lo canjea; reutilizar la grilla existente de 5 columnas y su scroll, generando las casillas según `bagSlots` sin rediseñar la mochila.
* Al tocar el slot 3 bloqueado en Selección de Personaje, abrir Tienda con `token_slot3` seleccionado. Canjear `token_slot3` desde la mochila de cualquier PJ activa `perks.slot3` y desbloquea el slot para toda la cuenta.

### **Decisiones PO para RC103 (2026-10-19)**

| Punto | Decisión |
|---|---|
| P1 — `token_auction` antes de ECON-02 | Se puede comprar, reclamar y comerciar por trade (ECON-01). Mientras ECON-02 no exista, canjear se rechaza con aviso; el token no se consume y sigue comerciable. La ruta F2P se valida mediante trade directo; la subasta se prueba cuando ECON-02 esté implementada. |
| P2 — `token_rename` | Modal provisional con campo de nombre; reglas R2 exactas (3–16, alfanumérico + espacios internos limitados, trim, filtro Roblox, sin unicidad global). |
| P3 — `token_bag` | El personaje con el perk muestra 30 casillas, en la grilla existente de 5 columnas con scroll; no rediseñar la mochila. |
| P4 — `token_slot3` | La CTA del slot 3 bloqueado abre Tienda preseleccionando esta ficha; canjearla desde cualquier mochila desbloquea el slot por cuenta. |
| P5 — Z/X | Fichas no asignables a slots rápidos; canje solo desde la acción de uso en mochila. |
| P6 — Studio | Permitir grants/pruebas con perfil temporal solo en Studio; ningún grant de prueba ni bypass se permite en juego publicado ni modifica perfiles reales. |
| P7 — móvil | Targets táctiles ≥44×44 px. Para estados sin frame móvil propio, reutilizar y escalar el estado PC, manteniendo lectura y safe area. |

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Compra → token**

* **GIVEN** un jugador
* **WHEN** compra un Dev Product de token y se confirma
* **THEN** aparece un grant pendiente en el buzón de su cuenta, idempotente por `ReceiptId`; todavía no se aplica ningún perk

#### **Escenario 1a: Reclamar en un personaje**

* **GIVEN** un token pendiente en el buzón de la cuenta y uno o más personajes existentes
* **WHEN** el usuario elige un personaje y reclama el token
* **THEN** el token aparece una vez en el inventario de ese PJ y el grant deja de estar pendiente

#### **Escenario 1b: No se puede reclamar todavía**

* **GIVEN** un grant pendiente y ningún PJ disponible o sin espacio en la mochila elegida
* **WHEN** el usuario intenta reclamarlo
* **THEN** el grant permanece pendiente y puede reclamarse después sin perderse ni duplicarse

#### **Escenario 1c: Reclamo durante lock temporal de trade**

* **GIVEN** un grant de token pendiente y el perfil del PJ está bloqueado por un trade en curso
* **WHEN** el usuario intenta reclamarlo durante `RESERVING`, `LOCKED` o `EXCHANGING`
* **THEN** el grant permanece pendiente y se reclama después de liberar el lock, sin cobrar de nuevo, perderse ni duplicarse

#### **Escenario 2: Canje**

* **GIVEN** un token en el inventario sin el perk poseído
* **WHEN** lo consume
* **THEN** el flag queda permanente y el token se consume

#### **Escenario 2a: Token reservado no se puede canjear**

* **GIVEN** un token `tradeLocked` o en custodia de subasta
* **WHEN** el jugador intenta canjearlo
* **THEN** se rechaza el canje; el token y el estado del trade/anuncio no cambian

#### **Escenario 2b: Token de subasta antes de ECON-02**

* **GIVEN** `token_auction` en la mochila y ECON-02 todavía no implementada
* **WHEN** el jugador intenta canjearlo
* **THEN** se informa que la mejora de subasta aún no está disponible; no se consume ni se altera el token, que sigue comerciable por ECON-01

#### **Escenario 2c: Canje de renombre**

* **GIVEN** un `token_rename` libre en la mochila
* **WHEN** el jugador abre el modal y envía un nombre
* **THEN** se aplican las reglas de R2 (3–16 caracteres, alfanumérico con espacios internos limitados, trim, filtro Roblox, sin unicidad global); un rechazo conserva el token y un cambio exitoso lo consume una sola vez

#### **Escenario 3: Perk ya poseído**

* **GIVEN** el perk ya desbloqueado
* **WHEN** intenta consumir otro token igual
* **THEN** se rechaza (el token sigue vendible)

#### **Escenario 4: Venta F2P por trade directo**

* **GIVEN** un jugador obtiene una ficha por trade directo ECON-01 sin haber pagado Robux
* **WHEN** la recibe en su mochila
* **THEN** la conserva, comercia o canjea si la funcionalidad está disponible; no se requiere ECON-02 para validar la adquisición F2P

#### **Escenario 5: Anti-dupe**

* **GIVEN** recibos repetidos o clientes manipulados
* **WHEN** intentan duplicar tokens o canjes
* **THEN** el servidor rechaza (idempotencia + atomicidad; sin errores rojos)

#### **Escenario 5a: Prueba de grants en Studio**

* **GIVEN** el juego corre en Studio con un perfil temporal de pruebas
* **WHEN** se simula un grant de token para probar compra/reclamo/canje
* **THEN** el flujo puede probarse sin cobrar Robux ni modificar perfiles publicados/reales; el grant de prueba está deshabilitado fuera de Studio

#### **Escenario 5b: Ampliación de mochila por personaje**

* **GIVEN** un personaje con `token_bag` canjeado
* **WHEN** abre su mochila
* **THEN** muestra 30 casillas en la grilla existente de 5 columnas con scroll; los demás personajes mantienen su capacidad

#### **Escenario 5c: Desbloqueo del slot 3 por cuenta**

* **GIVEN** el slot 3 bloqueado en Selección de Personaje
* **WHEN** el usuario activa la CTA, compra/reclama `token_slot3` y lo canjea desde cualquier mochila de su cuenta
* **THEN** la Tienda abre con esa ficha preseleccionada y, al canjear, `perks.slot3` habilita el slot 3 para todos sus personajes

#### **Escenario 5d: Fichas fuera de los slots Z/X**

* **GIVEN** una ficha en la mochila
* **WHEN** el jugador intenta asignarla a Z o X
* **THEN** se rechaza la asignación; el canje solo se inicia explícitamente desde la mochila

#### **Escenario 6: Regresión**

* **GIVEN** el sistema activo
* **WHEN** se prueba el flujo (compras, tradeo, canjes, rejoin; añadir compra/canje por subasta cuando ECON-02 esté implementada)
* **THEN** balances e inventarios consistentes; sin errores rojos

#### **Escenario 6a: Estados móviles sin frame específico**

* **GIVEN** un estado de Tienda/Compras pendientes sin variante móvil propia
* **WHEN** se presenta en móvil
* **THEN** reutiliza el estado PC escalado, conserva lectura/safe area y todos los controles interactivos tienen hitbox de al menos 44×44 px

---

### **Alcance**

#### Incluye

* 4 tokens (templates + Dev Products + canje + venta) con flags permanentes.
* Compra idempotente con grant eventual; anti-dupe.

#### No incluye

* Game Passes (eliminados del modelo); perks nuevos (Fase 2 de `MONETIZATION.md`); generación de iconos finales (el PO los entregará después con ImageGen; placeholders temporales en esta etapa).

---

### **Definition of Done (DoD)**

* [ ] Los 4 Dev Products otorgan sus tokens (idempotentes, con grant eventual).
* [ ] Los recibos Robux generan grants pendientes durables por cuenta; el usuario puede reclamar cada token en un PJ existente desde Compras pendientes.
* [ ] El dev revisa los frames/IDs de HU-ESTETICA-49 indicados en §2 y sigue la última entrega aprobada; cada CTA abre el prompt nativo de Roblox, sin checkout propio.
* [ ] `token_auction` se puede recibir/comerciar antes de ECON-02, pero su canje se rechaza sin consumir el token hasta que la subasta exista; validar F2P con trade ECON-01.
* [ ] `token_rename` usa modal provisional y valida exactamente las reglas R2; rechazo conserva la ficha.
* [ ] `token_bag` muestra 30 casillas en 5 columnas con el scroll existente, solo para el personaje que canjea.
* [ ] CTA del slot 3 abre Tienda con `token_slot3` preseleccionado; el canje desde cualquier PJ desbloquea el slot por cuenta.
* [ ] Fichas no asignables a Z/X; Studio grants usan perfil temporal y no pueden activarse en publicación ni modificar perfiles reales.
* [ ] La UI móvil usa targets táctiles ≥44×44 px y reusa los estados de PC escalados donde no exista variante móvil. Mantener los placeholders de iconos; sustituirlos cuando el PO entregue los assets ImageGen finales.
* [ ] Si no hay PJ disponible, la mochila está llena o aplica el lock temporal de ECON-01, el grant queda pendiente; el reclamo es idempotente y valida la propiedad del personaje.
* [ ] Canje funcional por token (flag permanente + consumo; rechazo si ya poseído).
* [ ] El alcance de perks coincide con §1: slot3/subasta por cuenta; mochila/renombre por personaje.
* [ ] Tokens tradeables/subastables; comprador F2P puede canjear.
* [ ] Sin dupes ni pérdidas (recibos + ECON-03); sin errores rojos.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Decisiones cerradas (PO; actualizadas 2026-10-19)**

| Tema | Decisión |
|------|----------|
| Mecanismo | **Todo Dev Product** (repetibles); **cero Game Passes** |
| Modelo | PLEX/Bond: Robux → token → canje o venta por oro |
| Tokens | 4 específicos (slot3 149 · bag 99 · auction 79 · rename 49) |
| Developer Products | Nombres, IDs y precios registrados en la tabla §1 (PO, 2026-10-19) |
| Compra Robux | Grant durable en buzón por `UserId`; el jugador elige el PJ donde reclamar la ficha |
| Alcance de perks | `slot3` y `auctionPlus10`: cuenta; `bagPlus10` y renombre: personaje que canjea |
| Compra | `ProcessReceipt` idempotente + grant eventual (patrón R6.28) |
| Canje | Flag permanente + consumo; rechazo si ya poseído (vendible igual) |
| Venta | Tradeo/subasta normales (corte 5 %); precio en oro libre; sin vendors de perks |
| Alcance | Solo conveniencia (anti pay-to-win) |

---

### **Estimación (orientativa)**

3–4 sesiones del dev: templates + compras + canje + integración tradeo/subasta + pruebas anti-dupe.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-10-12 | Creación de HU-ECONOMIA-04: fichas canjeables (tokens) — **todo Dev Product, sin Game Passes** (decisión PO): 4 tokens (slot3/bag/auction/rename) comprables con Robux, canjeables por perks permanentes o vendibles por oro (F2P accede sin pagar); compra idempotente con grant eventual; anti-dupe con ECON-03 |
| 2026-10-19 | El PO confirma nombres, ProductId y precios de los 4 Developer Products: `token_slot3` 3718622291/149 R$; `token_bag` 3720053583/99 R$; `token_auction` 3720054258/79 R$; `token_rename` 3720053841/49 R$. El revive 3717359753/49 R$ queda registrado como producto separado en HU-R6.28 y MONETIZATION.md |
| 2026-10-19 | El PO define entrega Robux mediante buzón durable por `UserId` y reclamo explícito en un PJ existente; `token_bag` y `token_rename` aplican al PJ que canjea; `token_slot3` es por cuenta. El alcance de `token_auction` se alinea con el límite por jugador/UserId establecido en ECON-02 |
| 2026-10-19 | Se enlaza HU-ESTETICA-49 para el diseño de la Tienda, Compras pendientes y los cuatro iconos; el diálogo de pago es nativo de Roblox. |
