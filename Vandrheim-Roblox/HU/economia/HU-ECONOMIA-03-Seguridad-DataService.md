# HU-ECONOMIA-03: PREREQUISITO — Seguridad de guardado en DataService (session lock + escrituras transaccionales) — v2 revisada por dev senior

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Economía — Infraestructura de datos (dev) — PREREQUISITO
**Prioridad:** **CRÍTICA / BLOQUEANTE** (para ECON-01 tradeo y ECON-02 subasta)
**Estado:** Lista para implementar tras revisión del dev senior (RC obligatorio del dev antes de programar)
**Tipo:** Fix de infraestructura (dev)
**Fase GDD:** Economía 0 (infra) — requisito detectado por el dev senior 2026-09-22; v2 tras su revisión 2026-09-22
**Depende de:** R2 (perfil/oro/inventario)
**Componentes observados:** `ServerScriptService.Services.DataService` — `GetAsync`/`SetAsync` completos, **sin bloqueo de sesión real**; llamadas a `SavePlayerProfile` desde inventario, vendedor, loot, XP, talentos, skills y otros sistemas (confirmado en Studio)

---

### **Narrativa (INVEST)**

**Como** jugador (y PO),
**quiero** que mi perfil (oro, inventario, progreso) **nunca se pierda ni se sobrescriba** cuando dos servidores tocan mis datos a la vez,
**para** que el comercio (ECON-01) y la subasta cross-server (ECON-02) —que modifican oro e ítems desde cualquier server— sean seguros.

---

### **Descripción del Requerimiento / Contexto**

**Riesgo confirmado (dev senior + verificación en Studio):** `DataService` carga con `GetAsync`, guarda el **perfil completo con `SetAsync`** y **no tiene bloqueo de sesión real**. Además, **si falla la carga, crea un perfil vacío que podría guardarse después sobre el verdadero** (caso que esta HU prohíbe explícitamente). Con una economía cross-server, dos servidores pueden sobrescribir el oro o el inventario del otro.

**Revisión del dev senior (2026-09-22) — correcciones incorporadas:**
1. **El lock debe vivir en la MISMA clave del perfil** y verificarse dentro de cada `UpdateAsync` (patrón oficial de Roblox: LockId en la propia clave) — un `profileLock_<userId>` separado NO protege `user_<userId>`: entre comprobar el lock y guardar, otro servidor puede tomarlo.
2. **Contrato de escritura explícito:** solo el **servidor dueño del lock** escribe la clave del perfil. Los demás servidores escriben **operaciones/buzones duraderos** (`outbox_<userId>`), y el dueño las **incorpora al perfil** con `UpdateAsync` (CAS + verificación de LockId). **Prohibido:** escritura externa seguida de guardado completo desde una copia en memoria desactualizada.
3. **Migrar TODOS los puntos de escritura del perfil** (inventario, vendedor, loot, XP, talentos, skills, etc. — no solo oro/inventario). Incluso un snapshot con `UpdateAsync` puede borrar cambios ajenos si su callback reemplaza el valor actual por una copia vieja (el orden de operaciones por clave importa).
4. **Fallos y teleports como criterios de aceptación:** carga fallida → perfil NO guardable; renovación de lock fallida/vencida → el server anterior deja de escribir de inmediato; Hub → Dungeon → el destino espera la **liberación/traspaso normal** (no tratar el teleport como doble login sospechoso); resultado de escritura **incierto** (una llamada fallida puede haberse guardado) → los reintentos económicos usan **operationId verificable**, no solo backoff.

**Criterio de hecho global:** ningún guardado puede pisar una actualización de otro servidor: el lock vive en la clave del perfil (verificado en cada `UpdateAsync`), solo el dueño escribe el perfil (los externos escriben outbox), **todos** los puntos de escritura están migrados, y fallos/teleports/resultados inciertos están cubiertos por criterios de aceptación.

**Nota de alcance (dev senior):** esta HU **NO vuelve atómico un trade entre dos perfiles** — ECON-01 mantiene su propio protocolo idempotente de transferencia y recuperación.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Session lock EN la clave del perfil (patrón oficial Roblox)**

* El valor de `user_<userId>` contiene: `data` (perfil) + `lockId` + `lockedUntil` (y versión). Al cargar: `UpdateAsync` adquiere el lock (CAS: si `lockedUntil` pasó o lockId vacío → toma el lock; si está tomado por otro → rechaza/espera).
* **Cada `UpdateAsync` sobre el perfil verifica el LockId** antes de aplicar (si el lock se perdió/venció/otro lo tomó → aborta y el server deja de escribir).
* Renovación periódica (mismo `UpdateAsync` CAS, ej. cada 30 s con TTL 60 s); **fallo/vencimiento de renovación = el servidor detiene TODAS las escrituras al perfil inmediatamente** (no reintenta salvando).
* Liberación al salir; **traspaso por teleport**: al teleportarse Hub → Dungeon, el dueño libera con flag `handover` y el destino adquiere con normalidad (no es doble login).

#### **2. Contrato de escritura: dueño del perfil + outbox**

* **Único escritor de `user_<userId>`: el servidor dueño del lock** (aplica deltas y snapshots con `UpdateAsync` CAS + LockId).
* **Servidores externos (ej. el server de la subasta donde compra un jugador cuyo dueño está en otro server):** NUNCA escriben el perfil. Escriben **operaciones inmutables en `outbox_<userId>`** (`{opId, type: ADD_GOLD|DEDUCT_GOLD|DELIVER_ITEM|..., payload, status}`) con `operationId` verificable.
* El **dueño drena el outbox** (periódico y al refrescar): por cada op → `UpdateAsync` CAS sobre el perfil (verificando LockId) → marca `status = DONE(opId)` (idempotente: si ya está DONE, se omite). **Resultado incierto** (llamada fallida que quizá se guardó): se verifica por `opId` antes de reintentar; nunca solo backoff.
* **Prohibido:** que un server externo escriba el perfil y luego el dueño guarde su copia en memoria desactualizada encima.

#### **3. Migración de TODOS los puntos de escritura**

* Inventario de llamadas a `SavePlayerProfile`/escrituras del perfil: **inventario, vendedor, loot, XP, talentos, skills y cualquier otro** — todas migran al contrato (dueño + `UpdateAsync` CAS + LockId, o outbox para externos).
* Los **snapshots** (guardado periódico completo) usan `UpdateAsync` con callback que **recalcula sobre el valor actual** (nunca reemplaza con copia vieja) y verifican LockId.
* Helpers compartidos en `DataService`: `withProfile(playerId, fn)`, `withGold`, `withInventory` (CAS + LockId), `enqueueOp(playerId, op)`, `drainOutbox(playerId)` — todos con reintento + **verificación por opId**.

#### **4. Carga fallida → perfil NO guardable**

* Si la carga falla (o devuelve datos inválidos), se puede jugar con **perfil temporal**, pero ese perfil queda **marcado `notSaveable`**: NUNCA se guarda sobre el verdadero (prohibido explícitamente). Al reconectar, se reintenta la carga.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Sin sobrescritura entre servidores**

* **GIVEN** dos servidores tocando los datos del mismo jugador
* **WHEN** ambos intentan aplicar deltas
* **THEN** solo el **dueño del lock** aplica al perfil (CAS + LockId); los externos escriben al outbox y el dueño los drena — **ningún delta se pierde y nada se duplica**

#### **Escenario 2: Doble login y teleport**

* **GIVEN** el perfil cargado en el server A
* **WHEN** el jugador entra en B (doble login real)
* **THEN** B rechaza/espera (lock ocupado) — sin corrupción
* **WHEN** se teleporta Hub → Dungeon (traspaso normal)
* **THEN** A libera con `handover` y el destino adquiere sin tratarlo como sospechoso

#### **Escenario 3: Lock perdido**

* **GIVEN** un server dueño cuyo lock vence/no se renueva
* **WHEN** intenta escribir después
* **THEN** la escritura falla (LockId no coincide) y el server deja de escribir de inmediato

#### **Escenario 4: Carga fallida**

* **GIVEN** una carga de perfil fallida
* **WHEN** el jugador juega con datos temporales y luego sale
* **THEN** el perfil temporal NUNCA se guarda sobre el real (marcado `notSaveable`)

#### **Escenario 5: Resultado incierto**

* **GIVEN** una escritura con resultado desconocido (falló pero pudo guardarse)
* **WHEN** se reintenta
* **THEN** la verificación por `operationId` evita aplicar dos veces (idempotente, no solo backoff)

#### **Escenario 6: Outbox de la subasta**

* **GIVEN** un jugador cuyo perfil pertenece al server A
* **WHEN** el server B (subasta) registra una venta/compra del jugador
* **THEN** B escribe la op en `outbox_<userId>`, A la drena y aplica (oro/ítem) con CAS + LockId — sin tocar la copia en memoria de B

#### **Escenario 7: Migración total**

* **GIVEN** todos los sistemas (inventario, vendedor, loot, XP, talentos, skills…)
* **WHEN** se juega el flujo completo (jugar → morir → reiniciar → comerciar → subasta → rejoin, con reinicios de server en el medio)
* **THEN** no hay errores rojos y el perfil queda íntegro (oro/inventario/progreso) — **ninguna escritura queda sin migrar**

#### **Escenario 8: Regresión**

* **GIVEN** la infraestructura migrada
* **WHEN** se prueban los flujos existentes (R2–R9)
* **THEN** todo sigue funcionando (nivel, loot, vendors, skills) con el nuevo contrato de escritura

---

### **Alcance**

#### Incluye

* Session lock **dentro de la clave del perfil** (LockId + lockedUntil, verificado en cada `UpdateAsync`), renovación, liberación y traspaso por teleport.
* Contrato de escritura: dueño único del perfil + **outbox** para servidores externos + drenado idempotente por `operationId`.
* **Migración de TODOS los puntos de escritura** del perfil (inventario, vendedor, loot, XP, talentos, skills y otros) a CAS + LockId.
* Perfil temporal no guardable tras carga fallida; detención de escrituras al perder el lock; verificación por opId en reintentos.

#### No incluye

* La subasta ni el tradeo (consumen estos helpers; ECON-01/02). **NO hace atómico un trade entre dos perfiles** — ECON-01 mantiene su propio protocolo idempotente de transferencia y recuperación.

---

### **Definition of Done (DoD)**

* [ ] Lock en la clave del perfil (CAS + LockId verificado en cada escritura) — doble login bloqueado/espera; teleport con handover normal.
* [ ] Solo el dueño escribe el perfil; externos vía outbox drenado con opId idempotente (probado con dos servers).
* [ ] TODOS los puntos de escritura migrados (sin `SavePlayerProfile` directo fuera del contrato); snapshots con callback sobre valor actual.
* [ ] Carga fallida → `notSaveable` (nunca sobrescribe el real); lock perdido → cero escrituras.
* [ ] Reintentos con verificación por operationId (resultados inciertos cubiertos).
* [ ] Sin errores rojos; perfiles íntegros tras reinicios.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Decisiones cerradas (PO 2026-09-22, tras revisión del dev senior)**

| Tema | Decisión |
|------|----------|
| Ubicación del lock | **Dentro de la clave del perfil** (LockId + lockedUntil), verificado en cada `UpdateAsync` — sin claves de lock separadas |
| Escritura del perfil | **Solo el dueño del lock**; externos escriben `outbox_<userId>` (opId) y el dueño drena con CAS |
| Migración | **Todos** los puntos de escritura (inventario, vendedor, loot, XP, talentos, skills…) — no solo oro/inventario |
| Carga fallida | Perfil temporal marcado `notSaveable` — **prohibido guardarlo sobre el real** |
| Lock vencido | El server anterior **deja de escribir de inmediato** |
| Teleport | Traspaso normal con `handover` (no es doble login) |
| Resultados inciertos | Verificación por `operationId` (idempotencia), no solo backoff |
| Atomicidad entre perfiles | **NO garantizada aquí** — ECON-01 define su propio protocolo de transferencia idempotente |
| Prerequisito | **Bloqueante** para ECON-01/02 |

---

### **Estimación (orientativa, revisada)**

3–4 sesiones del dev (la v1 estimaba 2–3; migrar y probar TODOS los puntos de escritura suma trabajo — confirmado por el dev senior).

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación v1 de HU-ECONOMIA-03 (session lock separado + UpdateAsync por clave) |
| 2026-09-22 | **v2 tras revisión del dev senior:** lock DENTRO de la clave del perfil (patrón oficial, verificado en cada UpdateAsync); contrato de escritura con **dueño único + outbox** para servidores externos; migración de TODOS los puntos de escritura (inventario/vendedor/loot/XP/talentos/skills); carga fallida → perfil **notSaveable**; teleport con handover; resultados inciertos → verificación por operationId; aclaración: NO hace atómico un trade entre perfiles (protocolo propio en ECON-01) |