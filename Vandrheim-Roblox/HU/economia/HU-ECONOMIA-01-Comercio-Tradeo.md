# HU-ECONOMIA-01: Sistema de comercio (tradeo) entre jugadores — v3 con ajustes PO 2026-10-19

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Economía — Comercio (dev)
**Prioridad:** Alta
**Estado:** Cerrada por el PO 2026-10-19; decisiones de producto y criterios de aceptación cerrados para implementación.
**Tipo:** Sistema nuevo (dev)
**Fase GDD:** Economía 1 (decisión PO 2026-09-22; v2 tras revisión técnica 2026-09-22)
**Depende de:** **HU-ECONOMIA-03 (PREREQUISITO: seguridad de guardado)**, HU-ITEMS-01 (ItemConfig, inventario), R2 (inventario/oro), HU-ESTETICA-13 (tokens), HU-ESTETICA-35 (referencia visual de Trade)
**Componentes observados:** `InventoryService`, oro del jugador, `ItemConfig`, RemoteEvents del server (patrón `RequestEquipItem`), `DataService` (ECON-03)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** poder **intercambiar ítems y oro directamente con otro jugador** en el Hub,
**para** compartir equipo con amigos y vender/comprar entre jugadores en persona (el mercado global es la subasta).

---

### **Descripción del Requerimiento / Contexto**

El tradeo es el **comercio directo entre 2 jugadores en el mismo servidor** (el cruce entre servidores es exclusivo de la subasta, ECON-02). Sistema **server-authoritative** con confirmación mutua.

La invitación inicia desde una lista de jugadores cercanos del Hub; el trade solo empieza después de que el receptor acepta. Las ofertas y confirmaciones se vinculan a los `characterId` originales de ambos participantes.

**Revisión del dev senior (2026-09-22) — correcciones incorporadas:**
1. **Ambos jugadores ofrecen ítems y oro** → hay que **reservar de forma duradera las ofertas de AMBOS**, identificar el **punto de compromiso** (a partir del cual el intercambio DEBE completarse) y definir la **recuperación si el server cae entre escrituras**. Tras una entrega confirmada, un timeout **NO puede "revertir la retención"** (dejaría a un jugador con lo recibido Y lo entregado). `UpdateAsync` protege una clave, no convierte dos perfiles en una transacción.
2. **Cambio de oferta:** modificar un ítem, cantidad u oro **anula las dos confirmaciones** — ambos deben confirmar **exactamente la misma versión** de la oferta.
3. **Cancelación:** libre **antes del compromiso**; una vez iniciado el tramo irreversible, desconexión o timeout activan **reconciliación**, no una reversión automática.
4. **Validación final:** identificadores de instancia, cantidades de stacks, oro **finito y no negativo**, espacio en **ambas** mochilas, y que ningún ítem reservado pueda **equiparse, consumirse ni entrar en otro trade**. Validar incluso **NaN e infinito** enviados por remotes.

**Criterio de hecho global:** dos jugadores en el Hub pueden completar un trade (ítems + oro por ambos lados) regido por una **máquina de estados duradera** (reserva de ambas ofertas → punto de compromiso → entrega → reconciliación por `opId`), sin duplicación ni pérdida ante concurrencia, desconexiones y fallos de guardado.

**Ajustes PO 2026-10-19 para `rc102`:** selector de jugadores cercanos + invitación Aceptar/Rechazar; trade permitido en todo el Hub; inicio con distancia ≤15 studs y cancelación precompromiso al superar 20 studs; bloqueo de combate (autoataque activo o daño dentro de 5 s); snapshot durable al confirmar ambas ofertas; `LOCKED` durable como punto de compromiso; sin historial visible; pilas parciales permitidas con validación de capacidad; cambio de PJ/teleport cancela antes del commit y no interrumpe después.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Máquina de estados durable (revisión PO 2026-10-19)**

Mientras la oferta está abierta, su estado vive **solo en memoria del servidor**; no se escribe DataStore por cada cambio de oferta. Cuando ambos confirman la misma versión, el servidor persiste un snapshot durable antes de efectuar reservas. `trade_<tradeId>` usa ECON-03 (dueño del perfil, CAS/`UpdateAsync`, `operationId`):

```
TRADE_REQUEST ─(aceptada)→ OFFERING (memoria)
OFFERING ─(ambos confirman misma versión)→ RESERVING (snapshot durable)
RESERVING ─(ambas reservas durables; escribe LOCKED)→ EXCHANGING → DELIVERED (terminal)
   │          └─(fallo/crash antes de LOCKED: liberar reservas)→ CANCELLED
   └─(cambio/cancel/timeout precommit)────────────────────────→ CANCELLED
```

| Estado | Regla |
|--------|-------|
| **TRADE_REQUEST** | Solicitud directa entre jugadores; no requiere party ni amistad. Efímera, sin `trade_<tradeId>`, reservas ni locks. Rechazo o timeout cierra la solicitud. |
| **OFFERING** | Estado en memoria mientras ambos arman ofertas. **Cualquier cambio** (ítem, cantidad u oro) sube `offerVersion` y anula ambas confirmaciones. Cancelación libre; timeout de 60 s sin actividad → CANCELLED. |
| **RESERVING** | Tras confirmar ambos la misma versión, escribir `trade_<tradeId>` durable con snapshot inmutable de ofertas, `characterId` de ambos participantes y `operationId` de las reservas; después ejecutar `HOLD_ITEMS`/`HOLD_GOLD` en ambos perfiles. Mientras se proteja capacidad, rechazar mutaciones que agreguen/muevan ítems a la mochila de A/B con `Trade en curso`; los grants de loot se difieren/reintentan, nunca se descartan. **No es el punto de compromiso.** Si una reserva falla o el servidor cae antes de LOCKED, reconciliar liberando cualquier reserva parcial y cancelar. |
| **LOCKED** | Solo después de verificar que ambas reservas están durables, escribir `LOCKED` en el registro. **El write durable de LOCKED es el punto de compromiso irreversible**: desde aquí el trade debe completarse, nunca cancelarse ni revertirse. |
| **EXCHANGING** | Aplicar dos liquidaciones idempotentes por perfil (`settleA`, `settleB`): en un `UpdateAsync` ECON-03, cada jugador entrega sus ítems/oro y recibe los del otro, con fusión de pilas. Guardar un `operationId` y estado completado por perfil. Si una liquidación se aplica y la otra falla, reconciliar la pendiente hasta completar; nunca revertir la aplicada. |
| **DELIVERED** | Terminal: consumir/retiro de reservas y cerrar el panel. **No guardar historial de trades visible ni persistente en los perfiles.** El registro técnico se limpia cuando ambas liquidaciones por perfil, reservas y marcadores de idempotencia estén finalizados. |
| **CANCELLED** | Terminal precommit. Liberar todas las reservas/retenciones parciales; no hay entrega ni historial. Puede producirse por rechazo/timeout de invitación, cancelación, combate, cambio de PJ/place, distancia, falta de espacio o fallo en RESERVING. |

**Crash/disconnect:** antes del `LOCKED` durable, recuperación → CANCELLED limpio y libera holds; después de `LOCKED`, reconciliación completa el trade. Nunca se revierten entregas postcommit.

#### **2. Flujo (server-authoritative)**

1. **Inicio:** acceso provisional `COMERCIAR` en el micromenú PC y en los accesos móviles (solo Hub, estilo/token actual; se reemplaza solo el arte al llegar EST-35). Abre un selector de jugadores elegibles cercanos. Al seleccionar B, `RequestTradeStart(player,targetUserId)` envía una solicitud de trade; el servidor filtra/revalida mismo servidor/Hub, distancia ≤15 studs, que ambos estén vivos y no estén en combate ni en otro trade.
2. **Invitación:** B recibe una solicitud modal con Aceptar/Rechazar. Hasta que B acepte no hay `trade_<tradeId>`, panel de ofertas, reservas ni locks. La invitación vence a los 60 s; al aceptar, el servidor revalida las condiciones y vincula el trade a los `characterId` originales de ambos.
3. **Ofertas:** `OFFERING` vive en memoria. `RequestTradeOffer(player,{slots:[{instanceId,quantity}],gold,offerVersion})` valida propiedad, reserva/equipamiento, cantidad y oro. Cambiar ítem/cantidad/oro incrementa `offerVersion` e invalida ambas confirmaciones.
4. **Confirmación y commit:** cuando ambos confirman la misma versión, persistir el snapshot inmutable y `operationId` en estado `RESERVING`; después reservar ítems/oro de ambos con ECON-03. Una vez durables ambas reservas, escribir `LOCKED`: ese write durable es el punto de compromiso. Antes de LOCKED, fallos/crash recuperan liberando holds; después, reconciliación completa siempre el trade.
5. **Cancelación/cambio de contexto:** antes de LOCKED, rechazo/cancelación, timeout, combate, distancia, cambiar PJ o abandonar el Hub cancela y libera reservas. Después de LOCKED, el trade sigue hasta completar contra los `characterId` originales aunque los jugadores cambien de PJ/place o se desconecten.
6. **Stacks y capacidad:** permitir cantidad parcial solo en ítems stackables (`ItemConfig.maxStack`); el resto de la pila permanece en el inventario de origen. En el destino fusionar pilas compatibles primero; si queda una pila nueva, requiere un slot libre. Si cualquier destino no tiene espacio, no comprometer el trade ni generar una entrega pendiente.
7. **Validación server-authoritative:** stacks no-stackables solo se ofrecen completos; cantidad integer `1 ≤ n ≤ quantity/maxStack`; oro finito, entero, `≥0` y `≤balance`; ítems reservados no se pueden equipar/usar/volver a tradear.

#### **3. Reglas de tradeo**

* **Solo en cualquier parte del Hub**; no requiere estar en una zona del vendor. Trade prohibido en Dungeon.
* **Distancia:** iniciar/invitar a ≤15 studs; cancelar antes de LOCKED si la distancia supera 20 studs (histeresis). Tras LOCKED se termina aunque cambie la distancia o el Place.
* **No en combate:** cada jugador debe tener auto-attack inactivo y no haber infligido/recibido daño server-validado en los últimos 5 s. Validar al invitar, aceptar y antes del commit; si se activa combate precommit, cancelar/liberar.
* **Ítems:** todos tradeables (no hay ligados en el MVP), incl. uniques; **oro:** cualquier cantidad del balance (server valida).
* **UI:** integrar los frames de Trade listados en §5 y el acceso provisional COMERCIAR de micromenú/accesos móviles solo en Hub. Mantener 2 lados, 6 slots + oro por lado y el estado de confirmación por oferta; el estado visual siempre refleja el estado autoritativo del servidor. El arte se cambia al recibir los frames finales de EST-35, sin reescribir lógica/remotes.
* **Sin fee** (el corte es de la subasta).
* **Anti-dupe:** máquina de estados durable + reservas por `operationId` + liquidaciones idempotentes por perfil (`settleA`, `settleB`) + reconciliación (nunca revertir post-compromiso).

#### **4. Config**

* `TradeConfig`: `maxDistance = 15`, `cancelDistance = 20`, `maxSlots = 6`, `inviteTimeout = 60`, `timeoutOffering = 60`, `combatGrace = 5`, `reconcileInterval = 120` s, `cooldownReinvite = 5`.
* No existe historial de trade para el jugador. Los registros internos `trade_<tradeId>` se limpian solo en estado terminal y después de confirmar ambas liquidaciones, liberar locks y resolver todos los `operationId`; estados activos o no reconciliados no expiran automáticamente.

---

### **Referencia visual para implementación (HU-ESTETICA-35)**

Fuente: `Vandrheim-design.pen`, frames **“HU-ESTETICA-35 — Trade · Rediseño”**. Usar los frames por nombre/ID como referencia visual; no reconstruir el flujo desde un solo estado.

**Flujo previo pendiente de integrar en EST-35:** selector de jugadores elegibles cercanos y modal de invitación entrante con Aceptar/Rechazar; aún no hay IDs Pencil para esas pantallas. No iniciar `OFFERING` ni bloquear ítems/oro antes de la aceptación.

| Estado de producto | Escritorio | Móvil horizontal | Comportamiento que representa |
|---|---|---|---|
| Oferta abierta | `MHmVu` — 01 | `J49Jo` — 01 | Nadie confirmó; ofertas editables |
| Confirmó solo el jugador local | `x5NRv8` — 02 | `nTldw` — 02 | Lado local confirmado; se espera a Saga |
| Confirmó solo el otro jugador | `gayFI` — 03 | `Lu43g` — 03 | Saga confirmó; falta confirmación local |
| Oferta modificada | `WyaUp` — 04 | `s74Pd` — 04 | Oferta cambia y se reinician ambas confirmaciones |
| Bloqueado, ambos confirmaron | `Fj3Uh` — 05 | `SpU3p` — 05 | Ambas ofertas de solo lectura; no se puede cancelar |
| Intercambiando | `GMRah` — 06 | `MQrb3` — 06 | Operación en curso; sin acciones ni cancelación |
| Completado | `nkmjf` — 07 | `abtHS` — 07 | Confirmación final y acción Cerrar |
| Expirado por timeout | `Y8nUKs` — 08 | `D86y0l` — 08 | Run cancelada antes del compromiso; acción Cerrar |
| Cancelado por distancia | `y9LhE` — 09 | `Fo7bf` — 09 | Run cancelada antes del compromiso; acción Cerrar |

**Medidas de referencia del rediseño:** escritorio `528×396`; móvil horizontal `640×320`, con área segura. Estas dimensiones reemplazan la referencia aproximada anterior de `640×360` para la ventana de Trade.

#### **Reglas de integración visual**

* Mostrar LOCKED solo cuando ambas reservas estén durables en el servidor, no al recibir simplemente dos clicks de confirmación.
* En LOCKED y EXCHANGING no habilitar Confirmar, editar oferta ni Cancelar. La X usa el `MenuCloseButton` compartido y **solo oculta el panel**; no cancela el trade ni revierte una operación comprometida.
* Después de LOCKED, una desconexión no cambia el estado a CANCELLED: continuar EXCHANGING hasta que la reconciliación entregue el resultado terminal real.
* En timeout y distancia, usar también `NotificationFrame` (R6.31) para los mensajes de HU-ESTETICA-35: **“El trade expiró”** y **“Demasiado lejos”**. El panel terminal puede mantener el chip TRADE EXPIRADO / TRADE CANCELADO.
* Cancelación manual pre-compromiso y fallo de la segunda reserva reutilizan el estado terminal CANCELLED; mostrar feedback correspondiente y que las ofertas retenidas se liberaron.
* En móvil conservar ambos lados visibles y hitboxes táctiles de al menos `44×44 px` indicados en las notas del diseño. No reducir el texto por debajo de los mínimos legibles documentados.
* El botón principal deshabilitado que aparece en LOCKED/EXCHANGING no emite `RequestTradeConfirm`; conservar el estado no interactivo aunque el arte use la etiqueta CONFIRMAR OFERTA.
* Eirik/Saga, niveles 16/15, ítems e importes 120/500 son datos de muestra del `.pen`; la integración debe mostrar los datos reales de los dos participantes y la oferta vigente, nunca quemar los valores del mockup.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1a: Selector e invitación de trade**

* **GIVEN** dos jugadores elegibles en el mismo Hub y a ≤15 studs
* **WHEN** A usa COMERCIAR, selecciona a B y B acepta la solicitud
* **THEN** se abre el panel para ambos y comienza `OFFERING` vinculado a sus personajes actuales
* **AND** antes de aceptar no existe trade activo ni se reserva ítem/oro

#### **Escenario 1b: Rechazo o expiración de invitación**

* **GIVEN** una invitación de trade pendiente
* **WHEN** B la rechaza o no responde en 60 s
* **THEN** la invitación se cierra; no se abre el panel, no se bloquean bienes y los balances no cambian

#### **Escenario 1: Trade exitoso bidireccional**

* **GIVEN** dos jugadores en el Hub a ≤15 studs con la invitación aceptada
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

#### **Escenario 3a: Bloqueo por combate**

* **GIVEN** cualquiera de los dos tiene auto-attack activo o infligió/recibió daño en los últimos 5 s
* **WHEN** se invita, acepta o confirma mientras el trade sigue precommit
* **THEN** el servidor rechaza la operación o cancela el trade y libera las reservas

#### **Escenario 3b: Espacio de mochila insuficiente**

* **GIVEN** la oferta entrante no cabe tras fusionar pilas compatibles
* **WHEN** se valida antes de LOCKED
* **THEN** el trade no se compromete, se liberan las reservas y no se deja una entrega pendiente

#### **Escenario 3c: Transferencia parcial de pila**

* **GIVEN** una pila stackable con cantidad mayor que la ofrecida
* **WHEN** el trade se completa
* **THEN** solo se transfiere la cantidad indicada, el resto queda con el origen y el destino fusiona o consume el slot requerido

#### **Escenario 4: Fallo entre liquidaciones (reconciliación)**

* **GIVEN** un trade en EXCHANGING con `settleA` aplicado
* **WHEN** el server cae antes de aplicar `settleB`
* **THEN** la reconciliación completa `settleB` por `operationId`; `settleA` no se repite y el estado final entrega exactamente la oferta acordada a ambos

#### **Escenario 4a: Crash antes del commit LOCKED**

* **GIVEN** un trade durable en `RESERVING` con cero, una o dos reservas aplicadas
* **WHEN** el servidor cae antes de escribir `LOCKED`
* **THEN** la reconciliación cancela y libera todas las reservas parciales; no entrega ítems/oro

#### **Escenario 5: Timeout post-compromiso**

* **GIVEN** un trade LOCKED con ambas reservas durables
* **WHEN** un jugador se desconecta (timeout)
* **THEN** el trade se **COMPLETA** vía reconciliación (nunca se revierte) — sin bienes duplicados

#### **Escenario 5a: Cambio de PJ/place**

* **GIVEN** un trade asociado a los `characterId` originales de ambos jugadores
* **WHEN** uno cambia de PJ o se teleporta al Hub/Dungeon antes de LOCKED
* **THEN** se cancela y libera reservas

#### **Escenario 5b: Cambio de PJ/place postcommit**

* **GIVEN** un trade en LOCKED vinculado a los `characterId` originales
* **WHEN** uno cambia de PJ, entra a Dungeon o se desconecta
* **THEN** la reconciliación completa sobre los personajes originales; no se redirigen bienes al nuevo PJ activo

#### **Escenario 6: ítems reservados intocables**

* **GIVEN** ítems de A en retención (LOCKED)
* **WHEN** A intenta equiparlos, consumirlos o incluirlos en otro trade
* **THEN** el server los bloquea (flags `tradeLocked`)

#### **Escenario 6a: Lock temporal de capacidad sin pérdida de bienes**

* **GIVEN** un trade en `RESERVING`, `LOCKED` o `EXCHANGING`
* **WHEN** cualquiera de los participantes intenta una mutación que agregue o mueva ítems a su mochila, como compra de vendor, grant admin/debug o unequip, o recibe loot
* **THEN** las mutaciones incompatibles se rechazan con `Trade en curso` sin cobrar ni alterar la mochila; los grants de loot quedan pendientes y se reintentan al liberarse el lock, sin perderse ni duplicarse

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

* Acceso provisional `COMERCIAR` con estilo existente en micromenú PC/accesos móviles, solo Hub; selector de jugadores cercanos e invitación Aceptar/Rechazar (arte reemplazable por EST-35); no se reservan bienes hasta aceptar.
* Máquina de estados TRADE_REQUEST → OFFERING (memoria) → RESERVING (snapshot durable) → LOCKED (commit) → EXCHANGING → DELIVERED/CANCELLED, con reservas de ambos lados y reconciliación por opId.
* Ventana de trade (2 lados, 6 slots + oro, cantidades parciales en items stackables, confirmación por versión y cancelar).
* Validación final completa (instancias, stacks, oro finito, capacidad, combate, cambio de PJ/place e ítems reservados); sin historial visible.

#### No incluye

* Subasta cross-server (ECON-02), historial persistente de trades ni impuestos.

---

### **Definition of Done (DoD)**

* [ ] Acceso provisional `COMERCIAR` (PC micromenú/móvil accesos, solo Hub) con estilo actual; al integrar los frames EST-35 se reemplaza solo el arte, no los contratos.
* [ ] Selector de jugadores elegibles del Hub + solicitud de trade modal Aceptar/Rechazar/expiración; no se crea oferta ni reserva antes de aceptar, no requiere Party.
* [ ] `OFFERING` en memoria; `RESERVING` snapshot durable tras confirmar ambos; LOCKED durable después de ambas reservas es el commit point; crash precommit libera y postcommit completa.
* [ ] Trade funcional en cualquier lugar del Hub (ítems + oro bidireccional, confirmación por versión vigente; nunca en Dungeon).
* [ ] Nombres, nivel, iconos de ítems y oro se alimentan de la oferta/estado real; valores Eirik/Saga del mockup no quedan hardcodeados.
* [ ] Integrar las 9 variantes de HU-ESTETICA-35 en escritorio y móvil horizontal; la UI refleja el estado autoritativo del servidor.
* [ ] Integrar los frames del selector COMERCIAR/invitación entrante de HU-ESTETICA-35 cuando el diseñador entregue sus IDs; Aceptar/Rechazar permanece en modal, no en NotificationFrame.
* [ ] Gate server-authoritative de combate (sin target de auto-attack activo ni daño en últimos 5 s).
* [ ] La X usa `MenuCloseButton` y solo oculta el panel; Cancelar solo actúa pre-compromiso; LOCKED/EXCHANGING bloquean edición y cancelación.
* [ ] Durante RESERVING/LOCKED/EXCHANGING, bloquear en ambos participantes las mutaciones que agreguen o muevan ítems a la mochila o puedan invalidar el snapshot/capacidad (incl. vendor, grant admin/debug y unequip); fallan con `Trade en curso` sin cobrar ni alterar bienes, y grants de loot se difieren/reintentan al liberar el lock.
* [ ] Timeout/distancia notifican su motivo; tras LOCKED, una desconexión continúa la reconciliación y nunca muestra reversión/cancelación.
* [ ] Cancelación limpia pre-compromiso; post-compromiso solo completa (nunca revierte).
* [ ] Dos liquidaciones atómicas por perfil (`settleA`, `settleB`) con `operationId`; si una se aplica y la otra falla, reconciliar la pendiente sin repetir la aplicada.
* [ ] Pilas parciales solo para ítems stackables; se fusionan o requieren espacio; si no cabe se rechaza antes del commit sin entrega pendiente.
* [ ] Cambio de PJ/place cancela precommit; postcommit completa en los `characterId` originales.
* [ ] Sin historial visible; registros internos se limpian solo tras terminalidad y reconciliación total.
* [ ] QA aislado en Studio + persistencia real en test place/usuarios de prueba; revisión final del PO registrada.
* [ ] Validación final completa (NaN/inf/negativos/stacks/instancias/espacio/ítems bloqueados) probada.
* [ ] Sin errores rojos; sin duplicación ni pérdida probado con fallos entre fases.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Decisiones históricas (PO 2026-09-22, v2 tras revisión del dev senior)**

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

### **Decisiones vigentes del PO (2026-10-19)**

| Tema | Decisión |
|------|----------|
| Inicio | `COMERCIAR` abre lista de jugadores elegibles cercanos del mismo Hub; invitar y esperar Aceptar/Rechazar antes de OFFERING |
| Party | No se requiere grupo/amistad; es una invitación directa de trade entre dos jugadores |
| Acceso provisional | PC: micromenú; móvil: accesos móviles; solo visible en Hub y con estilo existente hasta integrar el arte EST-35 |
| Distancia/zona | Todo el Hub; invitar a ≤15 studs; cancelar precommit al superar 20 studs; no Dungeon |
| Combate | No auto-attack activo ni daño recibido/infligido en últimos 5 s; revalidar en invitación, aceptación y commit |
| Persistencia/commit | OFFERING en memoria; snapshot `RESERVING` durable tras ambas confirmaciones; LOCKED durable tras ambas reservas es irreversible |
| Contexto PJ/Place | Antes de LOCKED cambiar PJ/salir del Hub cancela; después de LOCKED completar con los `characterId` originales |
| Mochila/stacks | No entrega pendiente; fusionar pilas compatibles; si no cabe antes de commit, cancelar; partial stacks solo en items stackables |
| Capacidad temporal | Durante RESERVING/LOCKED/EXCHANGING, bloquear adiciones/movimientos a mochila que puedan invalidar snapshot/capacidad; no cobrar ni perder bienes; loot se difiere y reintenta al finalizar |
| Liquidación | Dos liquidaciones atómicas por perfil (`settleA`, `settleB`) con `operationId`; completar la segunda por reconciliación si la primera ya se aplicó |
| Historial/limpieza | Sin historial visible; limpiar registros internos terminales al quedar todas las operaciones idempotentes/reconciliadas |
| QA | Pruebas del dev aisladas y test place con DataStore real; cierre final por el PO |

---

### **Estimación (orientativa, revisada)**

3–4 sesiones del dev (la v1 estimaba 2–3; la máquina de estados durable + pruebas de fallos entre fases suman trabajo — confirmado por el dev senior).

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación v1 de HU-ECONOMIA-01 (tradeo básico, retención de A → entrega a B) |
| 2026-09-22 | **v2 tras revisión del dev senior (histórica; liquidación reemplazada en v3):** máquina de estados durable completa — reserva de AMBOS jugadores, `offerVersion` (cambio de oferta anula confirmaciones), punto de compromiso en LOCKED (debe completarse), tramos idempotentes `legsDone` + reconciliación (post-compromiso NUNCA revierte), validación final hostil (NaN/inf/negativos/stacks/instancias/espacio/ítems `tradeLocked`); estimación 3–4 sesiones |
| 2026-10-19 | Se agrega referencia de integración visual al rediseño Trade de HU-ESTETICA-35: nueve estados de escritorio y nueve variantes móviles, IDs de frames, dimensiones actualizadas, cierre compartido y mapeo de estados a ECON-01. Revisión visual sin clipping; feedback de timeout/distancia vía NotificationFrame |
| 2026-10-19 | **v3 — ajustes PO para rc102:** COMERCIAR provisional PC/móvil con estilo existente; selector de jugadores cercanos + solicitud Aceptar/Rechazar; todo el Hub con distancias 15/20; bloqueo de combate 5 s; OFFERING en memoria + RESERVING durable y LOCKED como commit; lock temporal de capacidad sin perder grants; liquidaciones atómicas por perfil; pilas parciales y rechazo si no hay espacio; sin historial, limpieza tras reconciliación; QA en test place con persistencia real |
