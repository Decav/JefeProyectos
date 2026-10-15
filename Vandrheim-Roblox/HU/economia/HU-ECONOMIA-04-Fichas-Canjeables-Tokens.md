# HU-ECONOMIA-04: Fichas canjeables (tokens) — compra con Robux, venta por oro, canje de perks (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Economía / Monetización — Tokens (dev)
**Prioridad:** Alta
**Estado:** Lista para implementar (RC obligatorio del dev antes de programar)
**Tipo:** Sistema nuevo (dev) — modelo PLEX/Bond
**Fase GDD:** Economía 4 (decisión PO 2026-10-12: **todo Dev Product, sin Game Passes**)
**Depende de:** HU-ECONOMIA-03 (perfil atómico — mutaciones con `UpdateAsync`), HU-ECONOMIA-01/02 (tradeo/subasta: los tokens son ítems normales y circulan por ahí), HU-R6.28 (precedente `ProcessReceipt` + grant eventual), HU-R4 (ítems de inventario), HU-ITEMS-01 (templates en `ItemConfig`)
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

Modelo PLEX/Bond (decisión PO 2026-10-12): todo lo comprable con dinero real existe como **token** (ítem consumible). Se compra con Robux (Dev Product repetible) → va al inventario → se **consume** (canjea el perk permanente) o se **vende** (tradeo/subasta por oro). **Sin Game Passes**: R2.1 (slot 3) y los perks de `MONETIZATION.md` usan este sistema.

**Criterio de hecho global:** comprar con Robux da el token; el token se consume (perk permanente) o se vende por oro; un F2P puede obtener cualquier perk solo con oro; sin dupes ni pérdidas.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Tokens (templates en `ItemConfig`)**

| Token | Dev Product (Robux) | Canje (flag permanente en perfil) |
|-------|--------------------|------------------------------------|
| `token_slot3` — Pase: Tercer Personaje | 299 | `perks.slot3 = true` → `maxSlots = 3` |
| `token_bag` — Pase: Mochila Ampliada | 199 | `perks.bagPlus10 = true` → `bagSlots = 30` |
| `token_auction` — Pase: Subasta Ampliada | 149 | `perks.auctionPlus10 = true` → `maxListings = 20` |
| `token_rename` — Pergamino de Renombre | 99 | abre el flujo de cambio de nombre (validación R2) y se consume al aplicar |

* Tokens: `stackable=true` (apilables), tradeables y subastables como cualquier ítem; iconos propios (diseñador, pendiente — placeholder mientras tanto).
* Precios configurables sin tocar lógica; IDs de Dev Product en config (el PO los crea en el Dashboard, como el de R6.28).

#### **2. Compra con Robux → token (server-authoritative)**

* Dev Product repetible por token → `ProcessReceipt` **idempotente por `ReceiptId`** → otorga el token al inventario (patrón R6.28).
* **Grant eventual** (precedente R6.28): si no hay sesión válida al confirmar, el token va al buzón/perfil pendiente y se entrega al volver — la compra nunca se pierde.

#### **3. Canje (consumir el token)**

1. Usar token desde el inventario → el servidor valida: token en posesión + perk **no** poseído.
2. Si ya posee el perk → **rechaza el canje** (con aviso) — el token sigue sirviendo para vender.
3. Si válido → setea el flag en el perfil (vía ECON-03, `UpdateAsync`) + **consume el token**.
4. Rename: el pergamino abre el prompt de nombre; al validar (R2) aplica y consume.

#### **4. Venta por oro**

* Los tokens circulan por **tradeo (ECON-01)** y **subasta (ECON-02)** como ítems normales (con su corte del 5 % en subasta — gold sink).
* El mercado fija el precio en oro libremente; el juego no vende perks por oro en vendors (solo entre jugadores).

#### **5. Reglas**

* Solo conveniencia (los 4 perks), nunca poder — anti pay-to-win intacto.
* Sin dupes: recibos idempotentes + mutaciones atómicas (ECON-03); el token consumido desaparece (pila −1).
* Un token = un canje; los flags son permanentes e irreversibles (sin reembolso de perk).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Compra → token**

* **GIVEN** un jugador
* **WHEN** compra un Dev Product de token y se confirma
* **THEN** el token aparece en su inventario (idempotente por `ReceiptId`; grant eventual si no hay sesión)

#### **Escenario 2: Canje**

* **GIVEN** un token en el inventario sin el perk poseído
* **WHEN** lo consume
* **THEN** el flag queda permanente y el token se consume

#### **Escenario 3: Perk ya poseído**

* **GIVEN** el perk ya desbloqueado
* **WHEN** intenta consumir otro token igual
* **THEN** se rechaza (el token sigue vendible)

#### **Escenario 4: Venta F2P**

* **GIVEN** un token publicado en subasta por un jugador
* **WHEN** otro lo compra con oro
* **THEN** el comprador recibe el token (con el corte del 5 %) y puede canjearlo sin haber pagado Robux

#### **Escenario 5: Anti-dupe**

* **GIVEN** recibos repetidos o clientes manipulados
* **WHEN** intentan duplicar tokens o canjes
* **THEN** el servidor rechaza (idempotencia + atomicidad; sin errores rojos)

#### **Escenario 6: Regresión**

* **GIVEN** el sistema activo
* **WHEN** se juega completo (compras, tradeo, subasta, canjes, rejoin)
* **THEN** balances e inventarios consistentes; sin errores rojos

---

### **Alcance**

#### Incluye

* 4 tokens (templates + Dev Products + canje + venta) con flags permanentes.
* Compra idempotente con grant eventual; anti-dupe.

#### No incluye

* Game Passes (eliminados del modelo); perks nuevos (Fase 2 de `MONETIZATION.md`); iconos finales (placeholder hasta diseñador).

---

### **Definition of Done (DoD)**

* [ ] Los 4 Dev Products otorgan sus tokens (idempotentes, con grant eventual).
* [ ] Canje funcional por token (flag permanente + consumo; rechazo si ya poseído).
* [ ] Tokens tradeables/subastables; comprador F2P puede canjear.
* [ ] Sin dupes ni pérdidas (recibos + ECON-03); sin errores rojos.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Decisiones cerradas (PO 2026-10-12)**

| Tema | Decisión |
|------|----------|
| Mecanismo | **Todo Dev Product** (repetibles); **cero Game Passes** |
| Modelo | PLEX/Bond: Robux → token → canje o venta por oro |
| Tokens | 4 específicos (slot3 299 · bag 199 · auction 149 · rename 99) |
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