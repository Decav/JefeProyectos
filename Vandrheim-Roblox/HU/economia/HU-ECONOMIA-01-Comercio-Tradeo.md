# HU-ECONOMIA-01: Sistema de comercio (tradeo) entre jugadores — v2 revisada por dev senior

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Economía — Comercio (dev)
**Prioridad:** Alta
**Estado:** Lista para implementar tras revisión del dev senior (RC obligatorio del dev antes de programar)
**Tipo:** Sistema nuevo (dev)
**Fase GDD:** Economía 1 (decisión PO 2026-09-22; v2 tras revisión técnica 2026-09-22)
**Depende de:** **HU-ECONOMIA-03 (PREREQUISITO: seguridad de guardado)**, HU-ITEMS-01 (ItemConfig, inventario), R2 (inventario/oro), HU-ESTETICA-13 (tokens)
**Componentes observados:** `InventoryService`, oro del jugador, `ItemConfig`, RemoteEvents del server (patrón `RequestEquipItem`), `DataService` (ECON-03)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** poder **intercambiar ítems y oro directamente con otro jugador** en el Hub,
**para** compartir equipo con amigos y vender/comprar entre jugadores en persona (el mercado global es la subasta).

---

### **Descripción del Requerimiento / Contexto**

El tradeo es el **comercio directo entre 2 jugadores en el mismo servidor** (el cruce entre servidores es exclusivo de la subasta, ECON-02). Sistema **server-authoritative** con confirmación mutua.

**Revisión del dev senior (2026-09-22) — correcciones incorporadas:**
1. **Ambos jugadores ofrecen ítems y oro** → hay que **reservar de forma duradera las ofertas de AMBOS**, identificar el **punto de compromiso** (a partir del cual el intercambio DEBE completarse) y definir la **recuperación si el server cae entre escrituras**. Tras una entrega confirmada, un timeout **NO puede "revertir la retención"** (dejaría a un jugador con lo recibido Y lo entregado). `UpdateAsync` protege una clave, no convierte dos perfiles en una transacción.
2. **Cambio de oferta:** modificar un ítem, cantidad u oro **anula las dos confirmaciones** — ambos deben confirmar **exactamente la misma versión** de la oferta.
3. **Cancelación:** libre **antes del compromiso**; una vez iniciado el tramo irreversible, desconexión o timeout activan **reconciliación**, no una reversión automática.
4. **Validación final:** identificadores de instancia, cantidades de stacks, oro **finito y no negativo**, espacio en **ambas** mochilas, y que ningún ítem reservado pueda **equiparse, consumirse ni entrar en otro trade**. Validar incluso **NaN e infinito** enviados por remotes.

**Criterio de hecho global:** dos jugadores en el Hub pueden completar un trade (ítems + oro por ambos lados) regido por una **máquina de estados duradera** (reserva de ambas ofertas → punto de compromiso → entrega → reconciliación por `opId`), sin duplicación ni pérdida ante concurrencia, desconexiones y fallos de guardado.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Máquina de estados duradera del trade (v2 — núcleo del protocolo)**

El trade es un registro durable `trade_<tradeId>` (DataStore, escrito bajo el contrato de ECON-03: dueño del perfil + ops con `operationId`):

```
OFFERING ──(ambos confirman MISMA versión)──▶ LOCKED ──▶ EXCHANGING ──▶ DELIVERED (terminal)
   │  ▲                                        │  │
   │  │(cambio de oferta anula confirmaciones) │  └─(fallo de reserva 2º jugador)─▶ CANCELLED
   └──(cancel libre pre-compromiso)──▶ CANCELLED (terminal)
```

| Estado | Regla |
|--------|-------|
| **OFFERING** | Ambos arman ofertas (slots + oro). **Cualquier cambio** (ítem, cantidad, oro) **incrementa `offerVersion` y anula las confirmaciones** de ambos. **Cancelación libre** (no hay nada reservado). Timeout 60 s sin actividad → CANCELLED limpio. |
| **LOCKED** | Ambos confirmaron **la misma `offerVersion`**. Se **reservan durablemente las ofertas de AMBOS**: ítems marcados `tradeLocked(opId)` y oro retenido, en los perfiles de A y B vía ECON-03 (ops `HOLD_ITEMS`/`HOLD_GOLD` con `tradeId`). **Punto de compromiso:** cuando ambas reservas están durables → el trade **DEBE completarse** (sin cancelación). Si la reserva del 2º jugador falla → se libera la del 1º y CANCELLED. |
| **EXCHANGING** | Tramo **irreversible**. Se aplican los tramos con `legsDone` por opId: `aToB_items`, `aToB_gold`, `bToA_items`, `bToA_gold`. Cada tramo = op ECON-03 idempotente sobre el perfil destino. **Si el server cae entre tramos → la reconciliación completa los tramos restantes** (nunca revierte). |
| **DELIVERED** | Terminal. Se liberan las reservas (se consumen), historial en ambos perfiles, la ventana se cierra. |
| **CANCELLED** | Terminal. Solo desde OFFERING (pre-compromiso) o por fallo de la 2ª reserva. Se libera cualquier retención existente (solo puede haber retención unilateral si falló la 2ª). |

**Timeout/desconexión:**
* Antes de LOCKED (o con reserva incompleta) → **CANCELLED limpio** (libera lo retenido si lo hubiera).
* Después de LOCKED (ambas reservas durables) → **la reconciliación COMPLETA el trade** (nunca revierte: revolver tras una entrega confirmada dejaría bienes duplicados).

#### **2. Flujo (server-authoritative)**

1. **Inicio:** A abre el panel y **selecciona a B** (target en el Hub, distancia ≤15 studs). Remote `RequestTradeStart(player, targetUserId)` → server valida (ambos vivos, en Hub, distancia, no en combate, sin otro trade activo) y crea `trade_<tradeId>` en OFFERING.
2. **Ofertas:** Remote `RequestTradeOffer(player, {slots, gold, offerVersion})` → server valida **cada ítem** (propiedad, no reservado, no equipado, stacks válidos) y el **oro** (finito, entero, ≥0, ≤balance) → aplica → sube `offerVersion` → **anula confirmaciones**.
3. **Confirmación:** Remote `RequestTradeConfirm(player, offerVersion)` → solo vale si coincide con la **versión vigente**; la 2ª confirmación (misma versión) → **LOCKED**: reserva durable de ambos lados (ECON-03) → EXCHANGING → tramos → DELIVERED.
4. **Cancelación:** Remote `RequestTradeCancel` (pre-compromiso) → CANCELLED limpio. Post-compromiso no existe (la reconciliación completa).
5. **Validación final (en LOCKED y en cada tramo):** instancias existen y pertenecen · stacks `1 ≤ n ≤ stackSize` · oro finito (rechazar `NaN`/`inf`) y entero ≥0 · **espacio en ambas mochilas** para lo recibido · ningún ítem reservado puede **equiparse, consumirse ni entrar en otro trade** (flags `tradeLocked` revisados en equipar/consumir/otros trades).

#### **3. Reglas de tradeo**

* **Solo en el Hub** (zona comercial, cerca del vendor); prohibido en la dungeon y en combate.
* **Ítems:** todos tradeables (no hay ligados en el MVP), incl. uniques; **oro:** cualquier cantidad del balance (server valida).
* **UI:** ventana clásica 2 lados — 6 slots + oro por lado, candados de confirmación (versión vigente), botón cancelar; al LOCKED se bloquea la edición; cierre al DELIVERED.
* **Sin fee** (el corte es de la subasta).
* **Anti-dupe:** máquina de estados durable + reservas por opId + tramos idempotentes + reconciliación (nunca revertir post-compromiso).

#### **4. Config**

* `TradeConfig`: `maxDistance = 15`, `maxSlots = 6`, `timeoutOffering = 60`, `reconcileInterval = 120` s, `cooldownReinvite = 5`.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Trade exitoso bidireccional**

* **GIVEN** dos jugadores en el Hub a ≤15 studs
* **WHEN** ambos ofrecen ítems Y oro, confirman la misma versión y se completa
* **THEN** los bienes de A van a B y los de B van a A exactamente (sin duplicar ni perder) y la ventana se cierra

#### **Escenario 2: Cambio de oferta anula confirmaciones**

* **GIVEN** A confirmó su oferta v1
* **WHEN** A modifica un ítem, cantidad u oro (v2)
* **THEN** la confirmación de A se anula y ambos deben confirmar la v2 (nunca se confirma una versión distinta a la vigente)

#### **Escenario 3: Cancelación pre-compromiso**

* **GIVEN** un trade en OFFERING (o con reserva unilateral fallida)
* **WHEN** uno cancela, muere, se aleja >20 studs o pasan 60 s
* **THEN** el trade se aborta limpiamente y se libera cualquier retención — nada se pierde

#### **Escenario 4: Fallo entre tramos (reconciliación)**

* **GIVEN** un trade en EXCHANGING con la entrega A→B aplicada
* **WHEN** el server cae antes de B→A
* **THEN** la reconciliación completa B→A por `opId` (tramos `legsDone`) — nadie queda con lo suyo + lo ajeno

#### **Escenario 5: Timeout post-compromiso**

* **GIVEN** un trade LOCKED con ambas reservas durables
* **WHEN** un jugador se desconecta (timeout)
* **THEN** el trade se **COMPLETA** vía reconciliación (nunca se revierte) — sin bienes duplicados

#### **Escenario 6: ítems reservados intocables**

* **GIVEN** ítems de A en retención (LOCKED)
* **WHEN** A intenta equiparlos, consumirlos o incluirlos en otro trade
* **THEN** el server los bloquea (flags `tradeLocked`)

#### **Escenario 7: Validación hostil**

* **GIVEN** remotes manipulados
* **WHEN** se envía oro `NaN`/infinito/negativo, stacks inválidos, instancias ajenas o cantidad > balance
* **THEN** el server rechaza todo con mensaje (validación finita y por-instancia)

#### **Escenario 8: Sin duplicación**

* **GIVEN** dos trades simultáneos con el mismo ítem (intento de explotar)
* **WHEN** ambos confirman
* **THEN** solo uno llega a LOCKED (el ítem ya está `tradeLocked`); el otro falla la validación

#### **Escenario 9: Regresión**

* **GIVEN** el sistema implementado
* **WHEN** se juega el flujo completo (inventario → trade → equipo → dungeon)
* **THEN** no hay errores rojos y el inventario/oro quedan consistentes tras reinicios

---

### **Alcance**

#### Incluye

* Máquina de estados duradera del trade (OFFERING → LOCKED → EXCHANGING → DELIVERED/CANCELLED) con reservas de ambos lados, punto de compromiso y reconciliación por opId.
* Ventana de trade (2 lados, 6 slots + oro, confirmación por versión, cancelar).
* Validación final completa (instancias, stacks, oro finito, espacio, ítems reservados, NaN/inf).

#### No incluye

* Subasta cross-server (ECON-02), historial persistente de trades ni impuestos.

---

### **Definition of Done (DoD)**

* [ ] Máquina de estados duradera implementada (reservas de AMBOS jugadores, punto de compromiso en LOCKED, tramos `legsDone`, reconciliación por opId).
* [ ] Trade funcional en el Hub (ítems + oro bidireccional, confirmación por versión vigente).
* [ ] Cancelación limpia pre-compromiso; post-compromiso solo completa (nunca revierte).
* [ ] Validación final completa (NaN/inf/negativos/stacks/instancias/espacio/ítems bloqueados) probada.
* [ ] Sin errores rojos; sin duplicación ni pérdida probado con fallos entre fases.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Decisiones cerradas (PO 2026-09-22, tras revisión del dev senior)**

| Tema | Decisión |
|------|----------|
| Protocolo | **Máquina de estados duradera** (OFFERING → LOCKED → EXCHANGING → DELIVERED/CANCELLED) con reserva durable de AMBOS lados y `opId` |
| Punto de compromiso | **LOCKED con ambas reservas durables** → el trade DEBE completarse |
| Post-compromiso | Desconexión/timeout → **reconciliación COMPLETA** (nunca revertir) |
| Cambio de oferta | Sube `offerVersion` y **anula las confirmaciones** (ambos confirmar la misma versión) |
| Cancelación | Libre solo pre-compromiso (o reserva unilateral fallida) |
| Zona | Solo Hub (zona comercial), distancia 15 studs |
| Slots / oro | 6 por lado · oro finito, entero, ≥0, ≤balance |
| Ítems tradeables | Todos (incl. uniques); reservados = intocables (no equipar/consumir/otro trade) |
| Fee | Sin fee (el corte es de la subasta) |
| Prerequisito | **ECON-03** (seguridad de DataService) — bloqueante |

---

### **Estimación (orientativa, revisada)**

3–4 sesiones del dev (la v1 estimaba 2–3; la máquina de estados durable + pruebas de fallos entre fases suman trabajo — confirmado por el dev senior).

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación v1 de HU-ECONOMIA-01 (tradeo básico, retención de A → entrega a B) |
| 2026-09-22 | **v2 tras revisión del dev senior:** máquina de estados durable completa — reserva de AMBOS jugadores, `offerVersion` (cambio de oferta anula confirmaciones), punto de compromiso en LOCKED (debe completarse), tramos idempotentes `legsDone` + reconciliación (post-compromiso NUNCA revierte), validación final hostil (NaN/inf/negativos/stacks/instancias/espacio/ítems `tradeLocked`); estimación 3–4 sesiones |