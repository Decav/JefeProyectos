# HU-R6.57: Endless de la Helada — oleadas infinitas, récords y leaderboard semanal (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Combate / Retención / Competencia
**Prioridad:** Alta — modo repeatable y motivo semanal
**Estado:** Abierta — lista para RC
**Tipo:** Modo de juego instanciado + leaderboard (dev)
**Fase GDD:** Dungeon / Endgame / Retención
**Depende de:** R6.54 (juice), R6.58 (títulos/cosméticos), dungeon/combate existentes, `DataService`, `OrderedDataStore`, `TeleportService`/matchmaking de party, `EnemyConfig`, `EnemyService`, `DungeonService`, `UIService`
**Componentes observados:** `Dungeon_Helada` o arena derivada, enemigos/jefes existentes, party, perfil, leaderboard, Hub
**No modifica:** campaña de 5 pisos, balance base, loot de campaña, economía, clases, skills ni stats de enemigos existentes.

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** un modo de oleadas infinitas con enemigos aleatorios y un jefe cada 10 rondas,
**para** poner a prueba mi build, competir por récords y tener una razón semanal para volver.

**Como** equipo,
**quiero** un modo repeatable, server-authoritative y con ranking semanal,
**para** agregar endgame sin crear una campaña nueva ni romper el balance existente.

---

### Descripción / Contexto

La campaña de 5 pisos es finita. Esta HU agrega el **Endless de la Helada**:

* Oleadas infinitas; enemigos aleatorios de la pool existente.
* Jefe cada 10 rondas, usando jefes/mini-jefes existentes.
* Escalado progresivo de vida/daño por oleada.
* Recompensas cada 10 oleadas, con opción de retirarse.
* Récord personal por personaje.
* Leaderboard semanal por clase/spec (solo).
* Sin nuevos enemigos, clases, stats, monedas ni pay-to-win.

**Criterio de hecho global:** un jugador o party puede iniciar el Endless desde el Hub, sobrevivir oleadas con enemigos existentes, enfrentar un jefe cada 10, reclamar recompensas y registrar su récord; el leaderboard semanal se actualiza de forma server-authoritative, se resetea semanalmente y no acepta resultados del cliente.

---

### Especificaciones Técnicas / Contratos

#### 1. Acceso y modo

* Punto de entrada en Valgard: tablero/piedra/portal “Endless de la Helada”, cerca del portal de dungeon; sin bloquearlo.
* Permite **solo o party de 1–4**; no requiere matchmaking público en esta versión.
* Al iniciar:
  * crear una instancia/arena dedicada; no reutilizar una run de 5 pisos;
  * ubicación técnica: arena del place `Dungeon_Helada` o place derivado; el RC decide la ruta final;
  * aplicar cola/fade de entrada y salida segura.
* No se puede iniciar desde dentro de una dungeon de campaña, en combate o muerto.
* Salir/abandonar termina la run; no hay checkpoint ni rejoin dentro de la misma run.

#### 2. Oleadas y enemigos

* Oleada 1 empieza con 5–6 enemigos; incrementar cantidad y dificultad por configuración.
* Enemigos aleatorios de `EnemyConfig` existentes (normales/élites); sin nuevos enemigos ni IA.
* Cada 10 oleadas: **1 jefe/mini-jefe existente** de la pool permitida; no introducir jefes nuevos.
* Escalado:
  * vida/daño multiplicador por oleada,
  * sin cambiar stats base del enemigo ni balance de campaña,
  * valores configurables y testeables.
* Spawns en puntos seguros de la arena; sin spawn sobre el jugador.
* Si un enemigo queda atascado o fuera de la arena, reubicarlo o eliminarlo sin romper la oleada.
* La oleada termina cuando mueren todos los enemigos; breve pausa y siguiente oleada.
* Sin límite de oleadas; el run termina por wipe, abandono o error.

#### 3. Recompensas y cash-out

* Cada 10 oleadas, el grupo puede **reclamar y retirarse** o seguir:
  * recompensa de oro/XP,
  * 1 ítem de una pool existente (verde/azul; morado con baja probabilidad),
  * elección de 1 de 3 recompensas (configurable).
* Las recompensas ya reclamadas se conservan si el grupo muere después.
* Si muere antes de reclamar, no pierde recompensas anteriores ya aseguradas.
* Sin nuevas monedas; usar oro/XP e ítems existentes.
* Sin pay-to-win, revives pagos ni ventajas de estadísticas.
* La pool no incluye uniques de jefe ni ítems fuera de la campaña; configurar exclusiones.

#### 4. Récords personales

* `profile.endlessBest` por personaje:
  * `wave`,
  * `timeSeconds`,
  * `classId`/`specId`,
  * `date`,
  * `partySize`.
* Mostrar el récord personal en el tablero de entrada y en el panel de personaje si ya existe.
* Actualizar solo cuando el run termina con un récord mayor; idempotente.
* Sin récord si el run se abandona antes de la primera oleada o por error del servidor.

#### 5. Leaderboard semanal

* **Solo individual por clase/spec** en esta versión; party no entra al ranking.
* Clave semanal: `weekKey = YYYY-Www` (ISO week) + `classId` + `specId`.
* Persistencia: `OrderedDataStore` con score = oleada alcanzada; desempate por tiempo/menor tiempo.
* Reset semanal lunes 00:00 UTC; no borrar récords personales.
* Top 10 visible en un tablero del Hub.
* Recompensa semanal: título/cosmético de R6.58; sin stats ni oro masivo.
* Validar en servidor: solo se registra un run terminado por wipe/abandono válido, con duración y oleada coherentes; no aceptar submits del cliente.
* Anti-cheat: rechazar oleadas/tiempos imposibles, runs duplicados, rejoin o party carry en el board individual.

#### 6. UI/UX

* HUD de modo: oleada actual, enemigos restantes, próximo jefe, tiempo y récord personal.
* Aviso de jefe cada 10; banner de oleada y de récord.
* Pantalla de fin: oleada, tiempo, recompensas aseguradas y opción Volver al Hub.
* Tablero de leaderboard en Valgard: top 10 por clase/spec y semana actual.
* Usar UITheme y escalado existente; PC/móvil; botones táctiles ≥44 px.
* Sin minimapa; la arena debe ser legible.

#### 7. Rendimiento y estabilidad

* Limitar enemigos vivos por oleada; no acumular IA fuera de la arena.
* Cleanup de enemigos, VFX, conexiones y UI al terminar/abandonar.
* No usar `while true do` sin `task.wait`; no lógica de cliente para oleadas/recompensas.
* QA con solo/party, PC/móvil, runs largas y abandono.

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Iniciar Endless

* **GIVEN** el jugador en Valgard
* **WHEN** interactúa con el tablero del Endless
* **THEN** entra a la arena en solo o party de hasta 4
* **AND** empieza la oleada 1 con enemigos existentes

#### Escenario 2: Oleadas

* **GIVEN** una run activa
* **WHEN** mueren todos los enemigos
* **THEN** aparece la siguiente oleada
* **AND** la dificultad escala según configuración

#### Escenario 3: Jefe cada 10

* **GIVEN** una run en la oleada 10, 20 o 30
* **WHEN** empieza la oleada
* **THEN** aparece un jefe/mini-jefe existente
* **AND** no se usan enemigos nuevos

#### Escenario 4: Recompensa y retiro

* **GIVEN** una run que alcanza una oleada múltiplo de 10
* **WHEN** el grupo reclama
* **THEN** recibe la recompensa y puede retirarse
* **AND** las recompensas aseguradas se conservan

#### Escenario 5: Récord personal

* **GIVEN** una run terminada
* **WHEN** la oleada supera el récord del personaje
* **THEN** se actualiza `endlessBest`
* **AND** se muestra en el tablero/HUD

#### Escenario 6: Leaderboard

* **GIVEN** un run individual terminado
* **WHEN** el servidor valida oleada/tiempo
* **THEN** registra el score semanal por clase/spec
* **AND** el top 10 se muestra en el Hub
* **AND** el reset semanal ocurre los lunes UTC

#### Escenario 7: Anti-cheat

* **GIVEN** un resultado imposible o un submit de cliente
* **WHEN** el servidor valida
* **THEN** rechaza el score
* **AND** no altera el leaderboard

#### Escenario 8: Regresión

* **GIVEN** el Endless activo
* **WHEN** se juega la campaña de 5 pisos, party, vendors y quests
* **THEN** todo sigue funcionando
* **AND** no hay errores rojos

---

### Comportamiento Visual / UI-UX

* El Endless debe sentirse como un desafío, no como una dungeon reciclada.
* La progresión de oleadas y el próximo jefe deben ser legibles de un vistazo.
* El récord y el top 10 deben motivar sin humillar; mostrar clase/spec y semana.
* El cash-out cada 10 debe ser una decisión clara: asegurar o arriesgar.

---

### Alcance

#### Incluye

* Arena/modo Endless solo/party 1–4.
* Oleadas infinitas con enemigos existentes.
* Jefe cada 10 rondas.
* Escalado configurable.
* Recompensas cada 10 y cash-out.
* Récord personal y leaderboard semanal por clase/spec.
* UI de modo y tablero en el Hub.
* Anti-cheat y QA.

#### No incluye

* Enemigos, jefes, clases, skills o stats nuevos.
* Campaña nueva o pisos nuevos.
* Leaderboard de party en esta versión.
* Nuevas monedas, loot exclusivo o pay-to-win.
* Revives pagos o ventajas de estadísticas.
* Cámara semanal/Vault separada; el Endless cumple esa función.

---

### Definition of Done (DoD)

* [ ] Entrada y arena del Endless funcionando.
* [ ] Oleadas infinitas con enemigos existentes y jefe cada 10.
* [ ] Escalado configurable y estable.
* [ ] Recompensas cada 10 con cash-out.
* [ ] Récord personal persistente.
* [ ] Leaderboard semanal por clase/spec, server-authoritative.
* [ ] Reset lunes UTC y top 10 en el Hub.
* [ ] Anti-cheat y QA solo/party, PC/móvil.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).

---

### Decisiones por defecto

| Tema | Default |
|---|---|
| Acceso | Tablero en Valgard |
| Party | 1–4; sin matchmaking público |
| Enemigos | Existentes; aleatorios |
| Jefe | Cada 10; existente |
| Escalado | Configurable por oleada |
| Recompensas | Cada 10; 1 de 3; cash-out |
| Récord | Por personaje |
| Leaderboard | Semanal, solo, por clase/spec |
| Reset | Lunes 00:00 UTC |
| Recompensa semanal | Título/cosmético de R6.58 |
| Vault | No se implementa por separado |

---

### Estimación (orientativa)

1–2 semanas del dev: arena, oleadas, escalado, recompensas, récords, leaderboard, anti-cheat y QA.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-11-12 | Creación de HU-R6.57: Endless de la Helada con oleadas infinitas, enemigos/jefes existentes, cash-out, récord personal y leaderboard semanal por clase/spec; reemplaza la Cámara semanal. |
