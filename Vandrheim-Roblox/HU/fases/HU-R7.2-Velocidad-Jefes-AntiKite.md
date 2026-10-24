# HU-R7.2: Aumentar la velocidad de movimiento de los jefes (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R7 / Bosses / Combate
**Prioridad:** Alta
**Estado:** Lista para RC
**Tipo:** Ajuste de movimiento/IA de bosses (dev)
**Depende de:** HU-R6.7 (animaciones/enemy movement), HU-R6.19 (IA melee/ranged), HU-R7/R7.1 (bosses actuales), HU-R8d/R9c (balance y QA), `EnemyConfig`/`BossConfig`
**No modifica:** velocidad del jugador, daño, cooldowns, telegraphs, knockback ni reglas de encuentro.

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** que los jefes puedan alcanzar a los jugadores que corren a distancia,
**para** que no sea posible mantenerlos kiteados indefinidamente y que la pelea obligue a usar posicionamiento y ventanas de ataque.

---

### Descripción / Contexto

Los jefes son demasiado kiteables por jugadores ranged. El jugador corre a 20 studs/s (caminar 10); la velocidad normal de persecución del boss debe superar el máximo de carrera para que pueda recortar distancia, sin eliminar telegraphs ni convertir al boss en una embestida instantánea.

**Criterio de hecho global:** todo boss (mini-boss y boss final) tiene velocidad efectiva de persecución configurable superior a `CharacterConfig.runSpeed`; el valor de referencia inicial es **22 studs/s frente a 20 del jugador**, validado mediante playtest de builds ranged.

---

### Especificaciones técnicas / Contratos

* Definir una sola fuente de verdad configurable, por ejemplo `BossConfig.moveSpeed`/`EnemyConfig`, con un mínimo de persecución mayor que `CharacterConfig.runSpeed` (referencia inicial: 22 studs/s).
* Aplicar el mínimo a todos los enemigos marcados como boss/mini-boss, incluido Jotunn; permitir overrides por boss solo si mantienen la regla `bossChaseSpeed > playerRunSpeed`.
* Usar la velocidad de persecución normal, no alterar velocidades de ataques especiales, cargas/embestidas, desplazamientos guionados o animaciones.
* Mantener pausas, ataques, cooldowns, telegraphs, root/stun/knockback y orientación existentes; el boss debe seguir respetando obstáculos/pathfinding y límites de arena (R7.3).
* No cambiar velocidad del jugador, alcance de las skills, daño, vida, recompensa ni balance de encuentros.
* Exponer los valores en config para tuning y documentar cuánto más rápido que la carrera del jugador quedó cada boss.

---

### Criterios de aceptación (Gherkin)

#### Escenario 1: Boss alcanza a jugador ranged

* **GIVEN** un boss en fase de persecución y un jugador que corre alejándose en espacio navegable
* **WHEN** ambos se mueven a velocidad normal
* **THEN** el boss tiene velocidad efectiva mayor que el jugador y recorta distancia con el tiempo

#### Escenario 2: Todos los bosses

* **GIVEN** cualquier mini-boss de los pisos 1–4 o boss final
* **WHEN** se mide su desplazamiento de persecución
* **THEN** su velocidad normal de chase supera la velocidad máxima de carrera del jugador

#### Escenario 3: Telegraphed attacks intactos

* **GIVEN** el boss empieza un casteo o una habilidad con telegraph
* **WHEN** se aplica el ajuste de movimiento
* **THEN** se conservan la pausa/orientación y ventana de reacción existentes; no se mueve más rápido durante un ataque que ya lo inmoviliza

#### Escenario 4: Navegación y arena

* **GIVEN** el boss persigue alrededor de obstáculos y dentro de su arena
* **WHEN** llega a un borde, corredor o puerta
* **THEN** no atraviesa geometría ni sale de su arena; respeta el límite definido en HU-R7.3

#### Escenario 5: Regresión

* **GIVEN** boss melee/ranged y builds melee/ranged
* **WHEN** se prueba solo y party
* **THEN** la pelea sigue siendo esquivable, la presión ranged mejora y no hay loops de movimiento/errores rojos

---

### Alcance

#### Incluye

* Velocidad de persecución de todos los bosses y mini-bosses con config.
* Tuning frente a velocidad de carrera de jugador (20 studs/s), con valor inicial de referencia 22.
* Playtest ranged/melee y regresión de telegraphs.

#### No incluye

* Cambiar la velocidad del jugador o nerfear/alterar habilidades ranged.
* Rebalancear HP/daño/cooldowns/telegraphs.
* Cambiar el combate de enemigos normales.
* Leash/puertas de arena (HU-R7.3).

---

### Definition of Done (DoD)

* [ ] `BossConfig`/config de cada boss garantiza velocidad normal de persecución > `CharacterConfig.runSpeed`; valor inicial recomendado 22 frente a 20.
* [ ] Incluye bosses de piso 1–4 y boss final; excepciones de movimiento están documentadas y no rompen la regla durante chase.
* [ ] Telegráficos, ventanas de casteo, control de orientación, pathfinding y límites de arena funcionan sin cambios de gameplay.
* [ ] QA con Cazador Puntería, otras builds ranged/melee, solo y party; sin kiting indefinido ni atrapamientos.
* [ ] RC y evidencia de mediciones adjuntos; sin errores rojos.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-10-23 | HU nueva por reporte del PO: bosses más rápidos que el jugador para reducir el kiteo por ranged. |
