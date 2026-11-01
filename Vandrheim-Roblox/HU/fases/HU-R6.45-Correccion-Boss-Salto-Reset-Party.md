# HU-R6.45: Corrección — pools del Jotunn, salto tras revivir y reset de arena en party (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R6.x / Dungeon / Combate — Bugfix post-R6.44 (reporte PO 2026-10-27)
**Prioridad:** Crítica (charco invisible con daño y softlock de party)
**Estado:** Abierta — lista para implementar (RC obligatorio del dev antes de programar)
**Tipo:** Bugfix de VFX, estado de movimiento y reset de encuentro
**Fase GDD:** R6.45 (no cambia contenido, balance ni reglas de loot)
**Depende de:** HU-R6.44 (reset por wipe), HU-R7.1 (H1 Escombro), HU-R7.3 (arena/puerta), `BossConfig`, `VFXService`, `VFXClient`, `MovementService`, `DungeonService`, `FloorService`
**Componentes observados:** `BossConfig.helada_frostwarden.abilities[escombro_helado]`, `VFXService`, `VFXClient`, `MovementService`, `DungeonService.setBodyInert`, `DungeonService.evaluateRunWipe`, `FloorService.ResetBossForWipe`
**No modifica:** daño, cooldowns, radios, geometría, loot/XP, UI, clases ni balance.

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** que los charcos de escarcha del Jotunn se vean mientras hacen daño, que mi personaje siempre pueda saltar después de revivir y que una party no quede atrapada con el jefe encerrado,
**para** poder leer el peligro, moverme con normalidad y reintentar el encuentro sin softlocks.

---

### Descripción / Reporte

El PO reportó tres defectos después de subir los charcos persistentes del jefe final de 2 a 3:

1. **Charco invisible con daño:** el tercer charco (o el último en expirar) deja de verse en el piso antes de dejar de hacer daño. Queda una zona dañina invisible.
2. **Salto intermitente en dungeon:** de vez en cuando el personaje no salta; ocurre solo dentro de la dungeon y no siempre.
3. **Reset de arena en party:** si un miembro muere y revive mientras el otro sigue peleando, y luego el segundo muere y revive, el jefe no se resetea. La puerta queda cerrada y el jefe sigue dentro, sin forma de volver a pelear.

---

### Causas observadas (diagnóstico)

#### 1. Duración visual vs. duración del daño

* `BossConfig` define H1 con `maxActive = 3` y `poolDuration = 45`.
* El servidor `EnemyService.startPool` permite hasta 60 s (`math.clamp(..., 0.1, 60)`) y mantiene el daño 45 s.
* `VFXService` recorta `payload.duration` a **30 s** y `VFXClient` vuelve a recortar la duración visual a **30 s**.
* Resultado: el charco daña 45 s pero su visual desaparece a los 30 s (15 s de daño invisible). Con 2 charcos se notaba menos; con 3 es evidente.

#### 2. Salto en cero tras muerte/revive

* `DungeonService.setBodyInert` guarda y restaura `JumpPower`/`JumpHeight`, pero también los pone en 0 mientras el cuerpo está inerte.
* `MovementService.applyMode` pone `JumpPower = 0` y `JumpHeight = 0` cuando `DungeonDead` es true, y al volver a vivo **solo restaura `WalkSpeed`**, no el salto.
* Si el snapshot de `setBodyInert` se captura después de que otro flujo ya puso el salto en 0, al revivir se restaura 0. Es un problema de orden/estado residual, no de un único camino.

#### 3. Wipe de party basado en “todos muertos”

* `DungeonService.evaluateRunWipe` solo resetea si **ningún** miembro presente está vivo en cualquier lugar de la dungeon.
* En el caso reportado, A revive y queda en la entrada; B muere después. A sigue “vivo”, así que no hay wipe, no se resetea el jefe y la puerta no se vuelve a abrir.
* La condición correcta para evitar el softlock es **“no queda ningún miembro vivo dentro de la arena del jefe”**, aunque haya vivos fuera.

---

### Especificaciones Técnicas / Contratos

#### 1. H1 — charcos visibles durante toda su duración

* La duración visual de cada charco debe ser **igual a `poolDuration`** del servidor (45 s; máximo permitido 60 s).
* Eliminar el recorte a 30 s en `VFXService` y `VFXClient` para este efecto, o enviar/consumir la duración exacta sin clamp menor a 60.
* Cada charco debe tener su propio `effectId` (el `castId` del servidor ya es único); la limpieza de un charco no debe borrar el visual de otro.
* Con `maxActive = 3`, deben poder verse **3 charcos simultáneos** completos.
* Al expirar el más viejo (o al crear el cuarto), se elimina solo ese charco: su visual y su daño terminan juntos.
* No debe quedar ninguna zona con daño activo sin visual.
* QA temporal: comprobar a los 30 s, 35 s, 44 s y 45 s; el visual debe seguir presente hasta el mismo instante en que termina el daño.

#### 2. Salto — restauración garantizada

* Después de cualquier muerte → revive (gratis o pagado), respawn o cambio de piso, el personaje debe saltar con los valores normales.
* Ningún flujo de dungeon debe dejar `JumpPower`/`JumpHeight` en 0 al volver a estado vivo.
* `MovementService` no debe modificar el salto para representar muerte; si lo hace, debe restaurarlo desde config/defaults al volver a vivo y no desde un snapshot que pueda estar en 0.
* `setBodyInert` debe capturar los valores antes de que otro flujo los ponga en 0, o restaurar defaults seguros.
* QA: morir/revivir 3 veces seguidas, con revive gratuito y pagado, solo y party, en piso normal y en jefe; saltar después de cada revive.
* QA: verificar que el hub y el entrenamiento no cambian.

#### 3. Reset de arena — sin vivos dentro

* **Nueva condición de reset por party:** si el encuentro del jefe está activo y **no queda ningún miembro vivo dentro de la arena**, resetear el encuentro aunque haya miembros vivos fuera (entrada, pasillo, hub, panel de muerte o recién revividos).
* Un miembro cuenta como “vivo dentro” si:
  * `DungeonDead ~= true`,
  * `Humanoid.Health > 0`,
  * su `HumanoidRootPart` está dentro del volumen de la arena del jefe (mismo volumen que usa R7.3 para el escape del boss).
* **No resetear** si al menos un miembro vivo está dentro de la arena.
* **No resetear** si el jefe ya está derrotado, si la run terminó o si el encuentro no está activo.
* **Ventana de asentamiento:** esperar ~3 s sin vivos dentro antes de resetear, para no disparar por un empuje/knockback o por una salida momentánea. No resetear durante la gracia inicial si los jugadores están entrando.
* **Reset:** reutilizar `FloorService.ResetBossForWipe` (o el reset equivalente de R6.44) para:
  * devolver al jefe a su punto inicial y vida completa,
  * limpiar fase/cooldowns/aggro/telegraphs/charcos/hazards,
  * abrir la entrada de la arena y dar una nueva ventana de gracia de 10 s,
  * no otorgar loot/XP/oro/cofre/kill credit.
* **Idempotente:** una sola ejecución por ausencia de vivos; no duplicar jefe, triggers, hazards ni recompensas.
* **Reconciliación:** esta regla complementa el wipe de R6.44; no lo reemplaza. Si todos están muertos, se aplica el wipe existente. Si hay vivos fuera pero ninguno dentro, se aplica este reset.

#### 4. Enmiendas a HUs vigentes

| HU | Texto vigente | Precisión |
|---|---|---|
| HU-R6.44 | Party: wipe cuando ningún miembro vivo. | Se agrega: también resetear si no hay ningún miembro vivo **dentro de la arena**, aunque haya vivos fuera. |
| HU-R7.3 | Gracia de 10 s y reset por escape. | El reset por ausencia de vivos dentro recibe una gracia nueva de 10 s; la regla de no extender la gracia por escape se mantiene. |
| HU-R7.1 | H1 con máximo 2 charcos. | Config actual: `maxActive = 3`; la duración visual debe acompañar `poolDuration` (45 s). |

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Tres charcos visibles

* **GIVEN** el Jotunn con H1 en `maxActive = 3` y `poolDuration = 45`
* **WHEN** lanza Escombro tres veces y hay tres charcos activos
* **THEN** los tres se ven en el piso
* **AND** ninguno desaparece antes de que termine su daño

#### Escenario 2: Expiración del más viejo

* **GIVEN** tres charcos activos
* **WHEN** expira el más viejo
* **THEN** solo ese charco desaparece (visual y daño)
* **AND** los otros dos siguen visibles y haciendo daño

#### Escenario 3: Cuarto charco

* **GIVEN** tres charcos activos y `maxActive = 3`
* **WHEN** el jefe lanza un cuarto Escombro
* **THEN** se elimina el más viejo (visual y daño) y se crea el nuevo
* **AND** nunca hay un charco dañino sin visual

#### Escenario 4: Salto tras revive gratuito

* **GIVEN** un jugador muere en dungeon frente al jefe
* **WHEN** revive con una resurrección gratuita
* **THEN** puede saltar normalmente
* **AND** `JumpPower`/`JumpHeight` no quedan en 0

#### Escenario 5: Salto tras revive pagado

* **GIVEN** un jugador sin resurrecciones gratuitas
* **WHEN** compra el revive y reaparece
* **THEN** puede saltar normalmente
* **AND** el salto sigue funcionando tras varios usos

#### Escenario 6: Muertes repetidas

* **GIVEN** un jugador en dungeon
* **WHEN** muere y revive 3 veces seguidas
* **THEN** el salto funciona después de cada revive
* **AND** no hay estado residual de muerte

#### Escenario 7: Party — A revive, B muere

* **GIVEN** una party de 2 en un encuentro de jefe activo
* **WHEN** A muere y revive en la entrada, y luego B muere
* **THEN** al no quedar ningún miembro vivo dentro de la arena, el encuentro se resetea
* **AND** la entrada se abre con 10 s de gracia para reintentar

#### Escenario 8: Party — queda un vivo dentro

* **GIVEN** una party de 2 con un miembro vivo dentro de la arena
* **WHEN** el otro muere
* **THEN** el encuentro no se resetea
* **AND** el jefe conserva vida, fase, cooldowns y target del vivo

#### Escenario 9: Party — todos mueren

* **GIVEN** una party sin miembros vivos
* **WHEN** muere el último
* **THEN** se aplica el wipe de R6.44
* **AND** el reset es único, sin loot/XP/duplicados

#### Escenario 10: Salida momentánea

* **GIVEN** un miembro vivo dentro de la arena
* **WHEN** sale brevemente por un empuje o por la gracia
* **THEN** el reset no se dispara antes de la ventana de asentamiento
* **AND** si vuelve a entrar, el encuentro continúa

#### Escenario 11: Jefe derrotado

* **GIVEN** el jefe derrotado
* **WHEN** el party está fuera o muere
* **THEN** el reset por ausencia de vivos no se dispara
* **AND** el flujo de cofre/recompensa continúa

#### Escenario 12: Regresión

* **GIVEN** el fix aplicado
* **WHEN** se juega solo y party, PC y móvil, con muerte/revive, salto y H1
* **THEN** combate, loot, puertas, run y UI siguen funcionando
* **AND** no hay errores rojos ni duplicados

---

### Comportamiento Visual / Reglas de Negocio

* Los tres charcos deben leerse como amenazas reales; no puede haber daño sin representación visual.
* El salto es una acción básica: no debe depender del estado de muerte anterior.
* La arena debe poder reintentarse tras una muerte parcial; el jugador no debe quedar encerrado fuera.
* No se agregan VFX, UI, mecánicas ni cambios de balance.

---

### Alcance

#### Incluye

* Alineación de la duración visual de H1 con `poolDuration` y soporte de 3 charcos simultáneos.
* Restauración garantizada de salto tras muerte/revive/respawn.
* Reset de arena por ausencia de miembros vivos dentro, con gracia y sin recompensas.
* QA de solo/party, revive gratis/pagado, muertes repetidas y 3 charcos.

#### No incluye

* Cambiar daño, cooldowns, radios, duración de 45 s, `maxActive = 3` ni balance.
* Nuevos VFX, UI o mecánicas.
* Cambiar geometría, loot, XP, cofres o matchmaking.
* Rediseñar el sistema de muerte o el DeathPanel.

---

### Definition of Done (DoD)

* [ ] Los 3 charcos se ven durante sus 45 s; no hay daño invisible.
* [ ] La expiración de un charco no borra el visual de los otros.
* [ ] El cuarto charco elimina el más viejo de forma consistente.
* [ ] El salto funciona tras revive gratuito, pagado, muertes repetidas y cambio de piso.
* [ ] En party, si no queda ningún vivo dentro de la arena, el jefe se resetea y la puerta se abre.
* [ ] Si hay un vivo dentro, el encuentro no se resetea.
* [ ] El reset no otorga ni duplica loot/XP/cofre/kill credit.
* [ ] La ventana de asentamiento evita resets por salidas momentáneas.
* [ ] Sin errores rojos en solo/party, PC/móvil.
* [ ] Evidencia de QA (video/capturas, tiempos de 30/45 s, muertes/revives).
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota de cierre en GDD y actualización de R6.44/R7.1/R7.3 si corresponde.

---

### Decisiones por defecto

| Tema | Default |
|---|---|
| Duración de H1 | 45 s (la del servidor); visual igual |
| Máximo de charcos | 3 |
| Identidad de charco | `effectId` único por cast |
| Salto | Valores normales de R15; nunca 0 tras revive |
| Reset de arena | Sin vivos dentro, aunque haya vivos fuera |
| Ventana de asentamiento | 3 s |
| Gracia tras reset | 10 s |
| Recompensas por reset | Ninguna |
| Jefe derrotado | No resetear |
| Solo | Muerte = reset (sin cambios) |

### Riesgos / Casos no cubiertos

* Si un miembro revive y **otro sigue vivo dentro** de la arena, el revivido queda fuera y no hay reset; el encuentro continúa con el vivo. Se evalúa en una HU futura si se permite reingreso o se espera al final del encuentro.
* El reset por ausencia de vivos dentro debe coordinarse con la gracia para no resetear a un party que está entrando; la ventana de asentamiento es obligatoria.
* La corrección de duración visual no debe alterar el daño ni el `poolDuration`; solo alinear el visual con el estado del servidor.

---

### Estimación (orientativa)

1–2 sesiones del dev: corregir duración de VFX, restaurar salto y extender la condición de reset con QA de party.

---

### Historial

| Fecha | Cambio |
|-------|--------|
| 2026-10-27 | Creación de HU-R6.45 por reporte del PO: (1) charco de escarcha invisible con daño tras subir H1 a 3; (2) salto intermitente en dungeon tras muerte/revive; (3) jefe sin reset en party cuando un miembro revive y el otro muere. Incluye diagnóstico de duración 30 vs 45 s, salto en 0 y wipe basado en “todos muertos”. |
