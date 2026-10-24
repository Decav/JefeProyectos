# HU-R7.3: Cerrar la arena del boss y reiniciar el encuentro si escapa (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R7 / Bosses / Dungeon
**Prioridad:** Alta
**Estado:** Lista para RC
**Tipo:** Bugfix de límites/estado del encuentro de boss (dev)
**Depende de:** HU-R6.4 (puertas y sala final), HU-R6b (run lifecycle), HU-R7/R7.1 (boss rooms y encuentros), HU-R7.2 (velocidad/leash de bosses), `FloorService`, `EnemyService`, `BossConfig`
**No modifica:** composición de salas, daño, loot, niveles, telegraphs ni teleport de la run.

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** que la puerta de la arena dé tiempo para que el grupo entre y luego cierre el combate dentro de la sala,
**para** que el boss no pueda ser arrastrado fuera de su arena ni perderse por el dungeon.

---

### Descripción / Contexto

Los jugadores pueden llevar a un boss fuera de su sala. Al iniciarse cada encuentro, la puerta debe permanecer abierta durante **10 segundos** para que los jugadores crucen; después se cierra server-side. Si el boss cruza fuera del límite de su arena mientras la puerta está abierta —o escapa pese al cierre— el servidor reinicia el encuentro y devuelve al boss a su punto inicial con la vida completa.

**Criterio de hecho global:** mini-bosses y boss final quedan confinados a sus salas; existe una ventana de entrada de 10 segundos al iniciar, y todo escape detectado reinicia de forma segura el encounter sin otorgar kill/loot ni borrar la run.

---

### Especificaciones técnicas / Contratos

* Al activarse el trigger/estado de combate del boss, iniciar un timestamp autoritativo `encounterStartedAt`; la puerta conserva paso durante 10 s y luego se cierra/bloquea.
* Mostrar al grupo feedback del tiempo de entrada restante (texto/contador junto a la puerta o estado existente). El feedback no crea un canal de estado nuevo si puede reutilizar atributos/eventos de la sala.
* Capturar el punto inicial server-side del boss y sus límites/volumen de arena al iniciar el encuentro; validar el root/primary part del boss contra ese volumen, no confiar en CFrame enviado por cliente.
* Si el boss sale de la arena antes de cerrarse la puerta, ejecutar reset del encounter: boss a su CFrame inicial, `Health = MaxHealth`, reset de fase/cooldowns/aggro/target, cleanup de hazards del boss y ninguna recompensa/kill credit. No teleportar ni dañar a jugadores como parte del reset.
* El grace period queda anclado al inicio original y **no se extiende por reset del boss**, para evitar reabrirlo indefinidamente por kiteo. Si el boss vuelve a cruzar después de los 10 s por un fallo de colisión/teleport, resetearlo igualmente y mantener la puerta cerrada.
* La puerta respeta la progresión de R6.4: se abre al limpiar el piso; se cierra temporalmente al comenzar el boss; al derrotar al boss, se abre/avanza según el flujo normal del piso/run.
* Aplicar a mini-bosses en salas finales de pisos 1–4 y al boss final de piso 5.
* Si un jugador queda fuera cuando transcurren los 10 segundos, la puerta se cierra según regla; no teletransportar ni mover jugadores para corregirlo. Mantener el comportamiento normal de party/dungeon.
* Resetear de forma idempotente: una sola ejecución por escape, sin duplicar bosses, drops, triggers ni telegraphs; reportar evento al log de debug.

---

### Criterios de aceptación (Gherkin)

#### Escenario 1: Ventana de entrada

* **GIVEN** un boss room con su puerta abierta
* **WHEN** el servidor activa la pelea
* **THEN** todos los jugadores tienen 10 segundos para cruzar antes de que la puerta cierre

#### Escenario 2: Boss escapa durante los 10 segundos

* **GIVEN** un boss activo y puerta en periodo de gracia
* **WHEN** el boss cruza el límite fuera de su arena
* **THEN** el encounter se reinicia y el boss vuelve a su punto inicial con vida completa, sin kill credit ni loot

#### Escenario 3: Grace period no se prolonga

* **GIVEN** el boss se reseteó por escapar durante el periodo de gracia
* **WHEN** pasan los 10 segundos desde el inicio original del encuentro
* **THEN** la puerta se cierra; el reset no reinicia ni extiende el temporizador

#### Escenario 4: Boss no abandona arena

* **GIVEN** la puerta ya está cerrada
* **WHEN** el boss intenta perseguir a un jugador fuera del volumen
* **THEN** no atraviesa la puerta/límite; si por teletransporte o fallo sale del volumen, el servidor lo resetea a su punto inicial con vida completa y la puerta sigue cerrada

#### Escenario 5: Boss derrotado

* **GIVEN** el boss es derrotado dentro de su arena
* **WHEN** termina el encuentro
* **THEN** el flujo normal de puerta, recompensa y progresión continúa una sola vez; el reset de escape no se dispara

#### Escenario 6: Integridad de la run

* **GIVEN** reinicios de boss por escape, muerte/respawn de jugador o party
* **WHEN** se continúa la run
* **THEN** el piso/topología/seed no se reinicia, no se duplica el boss y no se duplican loot/XP

---

### Alcance

#### Incluye

* Puerta/entrada de boss room con gracia de 10 segundos y cierre al activarse el encounter.
* Detección server-side de salida del boss y reset completo a punto inicial/vida máxima.
* Aplicación a mini-bosses y boss final; feedback visible para el party.

#### No incluye

* Alterar topología, habitaciones, dificultad, loot, player respawn o reglas de R6.4/R6b.
* Evitar que jugadores salgan de la dungeon o modificar límites globales de mundo.
* Resetear al jugador o moverlo automáticamente por el cierre de la puerta.

---

### Definition of Done (DoD)

* [ ] Puerta mantiene paso exactamente 10 s desde el inicio del boss y luego cierra para el grupo.
* [ ] El cierre y el timer son server-authoritative y replican un estado/feedback claro.
* [ ] Escape del boss durante gracia o tras el cierre ejecuta un solo reset: punto inicial, vida completa, fase/cooldowns/aggro/hazards limpios.
* [ ] El reset no otorga loot/XP/kill credit ni duplica bosses/triggers.
* [ ] Al morir el boss, el flujo regular vuelve a abrir/progresar la sala una sola vez.
* [ ] QA en minibosses y Jotunn, solo/party, door open/closed, knockback y teleport edge cases; sin errores rojos.
* [ ] RC y evidencia de prueba adjuntos.

---

### Pendiente de RC

Confirmar con el dev si el detector de salida debe usar `ArenaBounds` por volumen (recomendado) o el umbral del vano de puerta como subcondición. En ambos casos la sala completa es el límite autoritativo y debe cubrir todos los lados/salidas.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-10-23 | HU nueva por reporte del PO: cerrar la arena del boss tras 10 s de gracia y reiniciar el encuentro a vida completa si el boss sale. |
