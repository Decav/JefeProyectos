# HU-R9a.3: Instancia compartida de dungeon en party — sin dungeons ni jefes duplicados (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Party / Dungeon — Bug crítico (reportado por PO 2026-10-12)
**Prioridad:** **Crítica** (rompe el juego en grupo)
**Estado:** Lista para implementar (RC obligatorio del dev antes de programar)
**Tipo:** Bugfix de instanciado multiplayer (dev)
**Fase GDD:** R9a.3 (no cambia reglas de loot/XP; cambia quién guía la run)
**Depende de:** HU-R9a (party), HU-R6b (run lifecycle), HU-R9a.2 (matchmaking/lobby), HU-R7/R7.1 (jefes), HU-R8d (bandas de escalado)
**Componentes observados:** creación de runs/dungeons al entrar en grupo, `runState`, spawn de jefes, escalado por integrantes

---

### **Narrativa (INVEST)**

**Como** jugador en grupo,
**quiero** entrar a **una sola dungeon compartida** con mi party,
**para** pelear los mismos jefes juntos (sin duplicados) aunque alguien se vaya.

---

### **Descripción del Requerimiento / Contexto**

**Bug (PO):** al entrar en grupo **se genera 1 dungeon por integrante** (2 jugadores = 2 dungeons); si uno sale, **su dungeon desaparece**; los **jefes salen duplicados** (uno por dungeon).

**Regla cerrada (PO):** debe haber **UNA sola dungeon por party** (instancia compartida). El **líder guía el estado** de la dungeon (seed, spawns, progresión); si el líder sale, el **siguiente miembro hereda la guía** y la dungeon **continúa** (sin resets ni bosses extra). **Lo único que escala es la dificultad** según los integrantes.

**Criterio de hecho global:** un party entra a una sola dungeon con un solo set de jefes; la guía migra al salir el líder sin duplicar nada; los enemigos escalan por integrantes.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Instancia compartida (una run por party)**

* Al entrar en grupo (lobby/teleport conjunto): se crea **UNA run** (`runState` único con `partyId`), no una por jugador. Todos los miembros comparten seed, pisos, puertas y jefes.
* **Spawn de jefes idempotente por run:** cada jefe spawnea **una sola vez** (flag en `runState`, p. ej. `bossSpawned[floor]`); reintentos/rejoins nunca duplican.
* Progreso personal (loot/XP ya ganado) sigue siendo por jugador (R6b intacto).

#### **2. Guía de la run (líder → siguiente miembro)**

* El **líder del party es el guía** de la run (dueño lógico del `runState`: seed y decisiones de progresión).
* Si el **líder sale**: la guía **migra automáticamente al siguiente miembro** (orden del party) **sin resetear** la run (pisos, jefes vivos/muertos, puertas y charcos se conservan).
* Si sale un **no-líder**: la run sigue igual (su progreso personal se conserva por R6b).
* Si **salen todos**: fin de run (regla R6b vigente).

#### **3. Escalado por integrantes (lo único que escala)**

* Enemigos (HP/daño/cantidad) escalan por **miembros presentes** según las bandas de R8d (config-driven, sin tocar reglas de loot/XP).
* Al salir un miembro, el escalado se recalcula a la baja (sin respawnear jefes ni reiniciar).

#### **4. Reglas**

* Server-authoritative: la run y sus flags viven en el servidor; los clientes nunca crean dungeons.
* Anti-dupe de jefes: doble entrada/teleport simultáneo no genera segunda run ni segundo boss (idempotencia por `partyId` + flags).
* Sin cambios a loot, XP, cofres ni matchmaking (R6b/R7/R9a.2 intactos salvo la instanciación).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Una sola dungeon**

* **GIVEN** un party de 2–4 entrando a la dungeon
* **WHEN** entran juntos
* **THEN** existe **UNA** run compartida (mismo seed/pisos/puertas para todos) y cada jefe existe **una sola vez**

#### **Escenario 2: Sale el líder**

* **GIVEN** una run en curso con su líder dentro
* **WHEN** el líder sale
* **THEN** el siguiente miembro hereda la guía **sin reset** (jefes, puertas y progreso intactos) y la dungeon continúa

#### **Escenario 3: Sale un miembro**

* **GIVEN** una run en curso
* **WHEN** sale un no-líder
* **THEN** su dungeon **no** desaparece (nunca fue suya: es compartida), su progreso personal se conserva (R6b) y el escalado se recalcula

#### **Escenario 4: Sin jefes duplicados**

* **GIVEN** entradas/teleports simultáneos o rejoins
* **WHEN** ocurren
* **THEN** ningún jefe spawnea dos veces (flags idempotentes por run)

#### **Escenario 5: Escalado**

* **GIVEN** una run con 2, 3 o 4 miembros
* **WHEN** se juega
* **THEN** los enemigos escalan por integrantes (bandas R8d); el loot/XP no cambia por cantidad

#### **Escenario 6: Regresión**

* **GIVEN** el fix aplicado
* **WHEN** se juega solo y en party (entradas, salidas, líder rotando, publicado)
* **THEN** no hay errores rojos y el ciclo de run (R6b) funciona igual

---

### **Alcance**

#### Incluye

* Una run compartida por party (sin dungeons por integrante) + migración de guía + jefes idempotentes + escalado por integrantes.

#### No incluye

* Cambios a loot/XP/cofres/matchmaking (intactos); ni balance fino (R8d/R9c).

---

### **Definition of Done (DoD)**

* [ ] Party de 2–4 entra a UNA dungeon compartida (un seed, un set de jefes).
* [ ] Guía migra al salir el líder sin resets ni duplicados.
* [ ] Jefes idempotentes (una sola vez por run, ante entradas simultáneas/rejoins).
* [ ] Escalado por integrantes (bandas R8d); loot/XP intactos.
* [ ] Sin errores rojos (solo y party, publicado).
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Decisiones cerradas (PO 2026-10-12)**

| Tema | Decisión |
|------|----------|
| Instancia | **UNA run compartida por party** (nunca una por integrante) |
| Guía | **El líder guía**; al salir, hereda el **siguiente miembro** sin reset |
| Jefes | **Idempotentes** (una sola vez por run) — cero duplicados |
| Escalado | Solo **dificultad por integrantes** (bandas R8d); loot/XP iguales |
| Salidas | No-líder: sigue todo; todos: fin de run (R6b) |

---

### **Estimación (orientativa)**

2–3 sesiones del dev: instanciación compartida + migración de guía + idempotencia de jefes + escalado + regresión.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-10-12 | Creación de HU-R9a.3: instancia compartida de dungeon en party — **una sola run por grupo** (el bug generaba 1 por integrante con jefes duplicados); el **líder guía** y al salir hereda el siguiente miembro **sin reset**; jefes idempotentes; **solo escala la dificultad** por integrantes (reportado por PO) |