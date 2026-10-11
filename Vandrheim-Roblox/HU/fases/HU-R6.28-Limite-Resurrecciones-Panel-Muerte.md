# HU-R6.28: Límite de resurrecciones + panel de muerte (3 gratis por run, revive con Robux)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Combate / Muerte / Monetización de conveniencia
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Sistema de muerte/resurrección (dev)
**Fase GDD:** R6.28 (mejora del ciclo de muerte; decisión de monetización registrada en GDD §11)
**Depende de:** HU-R6a (muerte/respawn en entrada del piso, HP/MP llenos, sin pérdida), HU-R6b (run lifecycle: abandonar = fin de run con lo ganado), HU-R9a (party: respawn individual), HU-PUBLICAR-02 (dungeon cross-place), checks de compra Robux (Proceso de pago estándar)
**Componentes observados:** `ServerScriptService.Services.DungeonService` (`humanoid.Died → respawn`), runState, `RequestAbandonRun`, perfil/DataStore

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** al morir en la dungeon ver un panel con mis opciones — reaparecer (tengo 3 resurrecciones por run) o abandonar la run —,
**para** decidir si seguir o retirarme sin perder lo ganado.

**Como** jugador,
**quiero** poder revivir con Robux cuando se me agotan las resurrecciones gratuitas,
**para** continuar una run difícil si así lo decido.

**Como** equipo,
**quiero** que el ciclo de muerte sea server-authoritative y el pago esté validado,
**para** que no se pueda revivir sin permiso ni duplicar compras.

---

### **Descripción del Requerimiento / Contexto**

Hoy, al morir el jugador en la dungeon, `DungeonService` lo respawnea **automáticamente** en la entrada del piso con HP/MP llenos (R6a), sin pérdida de XP/loot/oro. No hay límite de muertes ni panel de decisiones.

Esta HU agrega (decisiones PO 2026-09-22):

1. **3 resurrecciones gratis por run** (por jugador; se reinician al entrar a una nueva run; el hub/entrenamiento no aplica límite ni panel).
2. **Panel de muerte** al morir (en vez del respawn inmediato):
   * **Reaparecer** (consume 1 de las 3) → respawn en la entrada del piso, HP/MP llenos.
   * **Abandonar la run** → fin de run (regla R6b), vuelta al pueblo conservando lo ganado.
3. **Revive con Robux cuando llega a 0**: botón "Revivir por **50 Robux**" (Dev Product configurable) — cada compra otorga 1 resurrección; ilimitadas dentro de la run.
4. **Party**: el límite es **individual**; cada miembro ve su propio panel; los vivos continúan mientras otros deciden (reglas de R9a: si todos abandonan/quedan 0 → run termina).

**Criterio de hecho global:** al morir en la dungeon aparece el panel con Reaparecer/Abandonar, las 3 gratuitas se consumen por run y al agotarlas el revive cuesta 50 Robux (validado, idempotente y server-authoritative).

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Contador y estado de run**

* Nuevo campo en `runState` (por jugador en party): `revivesLeft = 3` al iniciar la run (solo o party).
* `revivesLeft` > 0 → resurreción gratuita; llega a 0 → solo revive pagado.
* No se persiste en el perfil (es de la run; el abandonar/rejoin no reanuda la run — R6b).
* Reset: cada `StartRun` fija `revivesLeft = 3`.
* **EXCEPCIÓN — recibo tardío (`pendingRevives`, decisión PM 2026-09-22):** campo persistente en el perfil (entero, 0 por defecto). Se suma solo por **recibos confirmados sin run activa** (ver §4); al iniciar una run: `revivesLeft = 3 + pendingRevives` y `pendingRevives = 0`. Nunca otorga poder fuera de la dungeon (solo se consume en runs).

#### **2. Panel de muerte (DeathPanel UI, cliente)**

* El servidor **retira el respawn automático inmediato** en dungeon: al morir (`humanoid.Died`, DungeonService) se dispara el estado "muerto" con panel.
* `DeathPanel` (ScreenGui): título ("Has muerto"), contador de resurrecciones restantes, botón **Reaparecer** (gratis si `revivesLeft > 0`), botón **Revivir por 50 Robux** (solo si `revivesLeft = 0`), botón **Abandonar run** (confirmación fuerte: no se reanuda; lo ganado se conserva).
* Mientras el panel está abierto, la cámara queda libre (spectator) y el personaje no actúa; sin timeout (el jugador decide, en party los vivos siguen).
* Runnable también como apariencia móvil (mismo contrato).

#### **3. Remotes / contratos**

| Remote | Dir | Payload | Validación server |
|--------|-----|---------|-------------------|
| `DeathState` (S→C) | — | `{ revivesLeft }` | Estado de muerte + contador del jugador |
| `RequestRespawn` | C→S | — | Solo muerto en dungeon; `revivesLeft > 0` → descuenta 1 y respawnea en la entrada del piso |
| `RequestPurchaseRevive` | C→S | — | Solo muerto en dungeon; dispara el flujo de compra del Dev Product (server) |
| `RequestAbandonRun` | C→S | — | Existente (R6b): fin de run con lo ganado |

* El respawn **solo lo ejecuta el servidor** tras validar contador o compra; el cliente no puede respawnearse a sí mismo.
* Si el jugador se desconecta con el panel abierto: regla R6b (run termina para él, conserva lo ganado; en party, el resto sigue).

#### **4. Compra con Robux (Dev Product)**

* Dev Product: **"Vandrheim - Revivir en Mazmorra" — ProductId `3717359753`** (creado por el PO 2026-09-22). **Precio default: 50 Robux** (configurable sin tocar lógica; el precio real lo fija el dashboard).
* Flujo estándar: `ProcessReceipt` server-side; validación idempotente por `ReceiptId` (no duplica revives).
* Compra OK → `revivesLeft` no se "suma como saldo"**: el revive comprado se consume en el respawn inmediato (o se acredita +1 si el jugador queda muerto). Default: comprar revive = recargar +1 y **poder reaparecer al instante** (la compra aplica sobre el cuerpo muerto actual).
* Compra fallida/cancelada → sin revive, el panel sigue (feedback claro).
* **Anti-abuso:** el servidor valida: muerto, en dungeon, run activa, precio del Dev Product de config; receipts únicos; sin multiplicar ventajas (cada compra = 1 revive; **no acumula saldo para runs futuras — única excepción: `pendingRevives` por recibo tardío, ver abajo**).

#### **4.1 RECIBO TARDÍO — decisión PM (2026-09-22)**

**Problema:** Roblox puede confirmar una compra (o reintentar un recibo sin resolver) **después** de que el jugador se desconectó y su run ya terminó (R6b). Roblox NO reembolsa automáticamente y la HU prohibía guardar revives para runs futuras.

**Regla cerrada (Patrón estándar de Roblox — grant eventual):** el recibo se **concede siempre**, aunque llegue tarde:

1. `ProcessReceipt` confirma → valida idempotencia por `ReceiptId` → intenta el grant inmediato:
   * **Run activa y jugador muerto** → revive al instante (caso normal).
   * **Sin run activa** (desconectado/run terminada/otro servidor) → `pendingRevives += 1` (**persistido en el perfil**).
2. Al iniciar una run nueva → `revivesLeft = 3 + pendingRevives`; `pendingRevives = 0` (consumidos; la compra jamás se pierde).
3. Sin tope de acumulación: cada `pendingRevive` corresponde a un recibo real pagado (50 Robux); imposible de explotar (idempotente por `ReceiptId`, solo existe tras pago confirmado).
4. El `DeathPanel` NO muestra `pendingRevives` (es invisible; se aplica al arrancar la próxima run).

#### **5. Información de muerte**

* Al abrir el panel se muestra: muertes de la run usadas (`revivesLeft`) y opciones; aclaración "Abandonar conserva el oro y lo ganado del piso" (regla R6b).
* El botón Robux aparece solo con `revivesLeft = 0` (o siempre visible aclarando el costo, a elección del diseño — default: visible solo cuando llega a 0).

#### **6. Integración con party y resto**

* Límite individual (cada jugador sus 3).
* Si **todos** los miembros están muertos/abandonaron → run termina (reglas R9a/R6b).
* El dummy/entrenamiento y el hub no usan el panel: la muerte del jugador fuera de dungeon conserva el respawn actual (sin límite).
* Los cambios a `DungeonService` no alteran XP/loot/puertas/avance: solo el flujo de muerte.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Muerte en dungeon abre el panel**

* **GIVEN** un jugador en una run activa.
* **WHEN** muere (HP 0).
* **THEN** aparece el panel de muerte con el contador (`X/3`) y las opciones Reaparecer / Abandonar.
* **AND** no respawnea automáticamente.

#### **Escenario 2: Reaparecer consume una de las 3**

* **GIVEN** el panel con `revivesLeft = 3`.
* **WHEN** el jugador toca Reaparecer.
* **THEN** `revivesLeft` baja a 2.
* **AND** respawnea en la entrada del piso con HP/MP llenos y sin pérdida de XP/loot/oro.

#### **Escenario 3: Reaparecer hasta agotar**

* **GIVEN** el jugador reaparece 3 veces.
* **WHEN** muere por 4.ª vez.
* **THEN** el panel no ofrece Reaparecer gratis.
* **AND** ofrece Revivir por Robux y Abandonar.

#### **Escenario 4: Revivir con Robux**

* **GIVEN** el panel con 0 resurrecciones.
* **WHEN** el jugador compra el revive (50 Robux) y la compra se confirma.
* **THEN** respawnea en la entrada del piso y puede seguir la run.
* **AND** la compra es única (misma ReceiptId no da dos revives).

#### **Escenario 5: Compra fallida**

* **GIVEN** el panel de muerte sin resurrecciones.
* **WHEN** la compra falla o el jugador cancela.
* **THEN** no respawnea.
* **AND** el panel permanece con feedback de error y las opciones siguen.

#### **Escenario 6: Abandonar la run**

* **GIVEN** el panel de muerte.
* **WHEN** el jugador elige Abandonar y confirma.
* **THEN** la run termina (regla R6b), vuelve al pueblo y conserva lo ganado (XP/loot/oro).

#### **Escenario 7: Reinicio por run**

* **GIVEN** una nueva run (solo o party).
* **WHEN** comienza.
* **THEN** `revivesLeft = 3` para cada jugador (más `pendingRevives` si los hubiera, que se consumen y quedan en 0).

#### **Escenario 7b: Recibo tardío (decisión PM)**

* **GIVEN** un recibo confirmado sin run activa (jugador desconectado o run terminada)
* **WHEN** el recibo se procesa (ahora o al volver el jugador a cualquier servidor)
* **THEN** no se pierde la compra: `pendingRevives += 1` en el perfil
* **AND** al iniciar la próxima run, `revivesLeft = 3 + pendingRevives` (y `pendingRevives` vuelve a 0) — el recibo se concedió siempre (grant eventual, patrón Roblox)

#### **Escenario 8: Party individual**

* **GIVEN** un party con miembros en la dungeon.
* **WHEN** uno muere y otro sigue vivo.
* **THEN** el muerto ve su panel y el vivo continúa jugando.
* **AND** cada miembro tiene su propio contador de 3.

#### **Escenario 9: Fuera de la dungeon**

* **GIVEN** el jugador en el hub o entrenamiento.
* **WHEN** muere (caída, daño de noches o similar).
* **THEN** no aparece DeathPanel ni límite: se conserva el respawn actual.

#### **Escenario 10: Anti-exploit e idempotencia**

* **GIVEN** un cliente manipulado.
* **WHEN** intenta respawnearse solo, duplicar compras o saltarse el contador.
* **THEN** el servidor rechaza.
* **AND** los receipts de Robux son idempotentes y no se duplica el revive.

#### **Escenario 11: Regresión**

* **GIVEN** el sistema implementado.
* **WHEN** se muere/respawnea/abandona en solo y party (PC y móvil).
* **THEN** no hay errores rojos y XP/loot/puertas/avance no cambian.

---

### **Comportamiento Visual / Reglas de Negocio**

* El panel de muerte es claro: qué opciones hay, cuántas resurrecciones quedan y qué cuesta el revive (50 Robux).
* Abandonar conserva lo ganado (aclaración visible).
* El límite de 3 es por run (por jugador); el revive Robux es de conveniencia (sin poder permanente, alineado con GDD §11 — decisión PO registrada).
* Sin Timeout: el jugador decide; en party, los vivos no se bloquean.

---

### **Alcance**

#### Incluye

* Contador `revivesLeft = 3` por jugador por run (reset en StartRun).
* DeathPanel (UI): Reaparecer / Revivir 50 Robux / Abandonar + contador.
* Respawneo solo tras validación server (gratis si queda; pagado si llegó a 0).
* Dev Product `revive` + ProcessReceipt idempotente (50 Robux configurable, ilimitado en run).
* Ajuste del manejo de muerte en `DungeonService` (panel en vez de respawn inmediato; respawn anclado a RequestRespawn).
* Integración party (individual) y hub/entrenamiento (sin panel).

#### No incluye

* Cambiar reglas de respawn HP/MP/loss (sigue sin pérdida, entrada del piso).
* Persistir el contador entre runs o en el perfil.
* Más de un panel/confirmation extra (la confirmación de abandonar reutiliza el patrón existente).
* Cambios a XP, loot, puertas, avance, economía ni otros sistemas.

---

### **Definition of Done (DoD)**

* [ ] Al morir en dungeon aparece el panel (sin respawn automático).
* [ ] Reaparecer consume 1 de 3 por run (reset en StartRun).
* [ ] Con 0 resurrecciones, el panel ofrece Revivir (50 Robux) y Abandonar.
* [ ] La compra con Robux es server-validada e idempotente (ProcessReceipt).
* [ ] Abandonar cierra la run conservando lo ganado (R6b).
* [ ] Party: contador individual; los vivos no se bloquean; si todos mueren/abandonan → fin de run.
* [ ] Hub/entrenamiento sin panel ni límite (respawn actual).
* [ ] El respawn solo lo ejecuta el servidor (anti-exploit).
* [ ] Sin errores rojos en muerte → panel → reaparecer/comprar/abandonar (PC y móvil, solo y party).
* [ ] Se actualizan `PROJECT_ARCHITECTURE`, `DATA_SCHEMA` y el registro de la HU/RC al cerrar.
* [ ] **GDD §11 y historial:** registrar la excepción de monetización (revive 50 Robux = conveniencia acotada) al cerrar la verificación.
* [ ] Nota `R6.28 completo` en el GDD después de la verificación.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).

---

### **Decisiones por defecto R6.28**

| Tema | Default |
|------|---------|
| Resurrecciones gratis | **3 por run** (por jugador; reset en cada run) |
| Recibo tardío | **Grant eventual (patrón Roblox):** sin run activa → `pendingRevives += 1` en perfil; se consumen en la próxima run (decisión PM 2026-09-22) |
| Panel de muerte | Reaparecer / Revivir 50 Robux / Abandonar (con confirmación) |
| Precio revive | **50 Robux** (Dev Product configurable) |
| Uso del revive pagado | Ilimitado dentro de la run; cada compra = 1 respawn inmediato |
| Respawn | Entrada del piso, HP/MP llenos, sin pérdida (R6a) |
| Fuera de dungeon | Sin panel ni límite (respawn actual) |
| Party | Contador individual; fin de run si nadie queda vivo |
| Timestamp | Sin timeout: el panel espera la decisión |

---

### **Estimación (orientativa)**

2–3 sesiones del dev: contador y estado de muerte, DeathPanel, remotos, integración Robux (ProcessReceipt) y regresión solo/party.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-R6.28: límite de 3 resurrecciones por run, panel de muerte (Reaparecer/Abandonar) y revive con Robux (50, Dev Product configurable); decisión de monetización PO a registrar en GDD §11 |
| 2026-09-22 | **Recibo tardío cerrado (decisión PM, duda del dev en rc076):** Roblox puede confirmar compras tras desconectarse/run terminada → **grant eventual**: sin run activa → `pendingRevives += 1` (persistido en perfil) que se consumen al iniciar la próxima run (`revivesLeft = 3 + pendingRevives`, vuelven a 0); nunca se pierde la compra ni otorga poder fuera de la dungeon |
| 2026-09-22 | **ProductId recibido (PO):** Dev Product **"Vandrheim - Revivir en Mazmorra"** → **`3717359753`** (50 Robux) — config listo para el RC |