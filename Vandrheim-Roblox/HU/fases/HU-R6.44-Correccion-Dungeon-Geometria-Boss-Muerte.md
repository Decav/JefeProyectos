# HU-R6.44: Corrección de dungeon — geometría transitable, reintento de jefes y personaje muerto inerte (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R6.x / Dungeon / Combate — Bugfix crítico (reporte PO 2026-10-27)
**Prioridad:** Crítica (bloquea completar runs)
**Estado:** Implementada (reporte PO 2026-10-27; QA/verificación pendiente)
**Tipo:** Bugfix de generación, estado de encuentro de jefe y estado de muerte
**Fase GDD:** R6.44 (no cambia contenido, balance ni economía)
**Depende de:** HU-R6a (FloorService/kit), HU-R6b (run lifecycle), HU-R6.4 (topología), HU-R6.24/R6.39 (geometría y variantes), HU-R6.28 (DeathPanel/respawn), HU-R7/R7.1 (jefes), HU-R7.3 (arena/puerta), HU-R9a.3 (party)
**Componentes observados:** `FloorService`, `DungeonService`, `EnemyService`, `CombatService`, `SkillService`, `CharacterService`, `DungeonVariantConfig`, `Workspace.Terrain` del Place Dungeon
**No modifica:** topología/seed, contenido de pisos, enemigos, dificultad, loot/XP/oro, matchmaking, precios ni la UI del DeathPanel.

---

### Narrativa (INVEST)

**Como** jugador que corre la dungeon Helada (reporte: “Gruta Glacial”),
**quiero** que todos los pasos generados sean transitables, poder reintentar un jefe tras morir o tras un wipe del party, y que mi personaje muerto deje de existir para el combate hasta que reviva o abandone,
**para** completar la run sin atascos, sin puertas selladas sin salida y sin que un muerto siga atacando o recibiendo golpes.

---

### Descripción del Requerimiento / Contexto

El PO reportó tres defectos que rompen el loop de la dungeon:

1. **Geometría bloqueante:** en la dungeon Helada (“Gruta Glacial”) se generó una pared sobre el acceso de una sala con enemigos. La sala quedó inaccesible y la run no se pudo completar.
2. **Jefe sin reintento:** al morir y revivir frente a un jefe, el encuentro no se reinicia. La puerta de la arena queda cerrada, el jefe sigue vivo dentro y no hay forma de volver a pelear.
   * **Regla cerrada:** en **solo** el jefe se reinicia al morir el jugador; en **party** se reinicia cuando **todos** los miembros están muertos (wipe). Una muerte parcial no reinicia nada: los vivos continúan.
3. **Muerto que sigue interactuando:** al morir en la dungeon, el personaje puede seguir atacando, castear habilidades y ser tratado como entidad por los enemigos. Debe **desaparecer** y quedar inerte hasta revivir o abandonar.

Los tres defectos son regresiones respecto de contratos ya cerrados: R6.39 (pasos libres y props que no bloquean), R6.28 (“el personaje no actúa” con el panel abierto) y R7/R7.3 (estado del encuentro de jefe y reinicio sin duplicar recompensas).

**Criterio de hecho global:** cada piso generado es recorrible de entrada a jefe; un jefe puede reintentarse tras muerte en solo o wipe en party sin duplicar jefe/loot/XP y con entrada habilitada; un jugador muerto en dungeon es invisible, inerte, no colisiona, no es targeteable y no puede ejecutar acciones hasta respawnear o abandonar.

---

### Especificaciones Técnicas / Contratos de API

#### 1. Geometría transitable (generación)

* **Definición de paso libre:** el volumen de la apertura/conector (ancho y alto configurados por variante) no contiene geometría sólida (Parts, props, `Terrain`) ni props decorativos con colisión. El piso es continuo entre salas conectadas.
* **Validación server-side posterior a la generación:** para cada piso, verificar que exista camino físico transitable desde la entrada hasta **todas** las salas del grafo y hasta la sala del jefe, usando la geometría real generada. La validación no altera el grafo ni el seed.
* **Reparación determinista:** si una conexión está bloqueada, despejar esa apertura en el mismo layout (retirar/carvar el bloqueo) sin cambiar seed, topología, número de salas, spawns ni loot. Registrar `seed`, piso, variante, conexión afectada y causa.
* **Determinismo:** el mismo `seed + piso` vuelve a producir el mismo layout, incluida la reparación. Prohibido resolver el bug eligiendo otro seed en silencio.
* **Cobertura:** aplica a todas las variantes y pisos, no solo al caso reportado. Si “Gruta Glacial” corresponde a una variante con nombre interno distinto o nuevo, el dev lo reporta en el RC; el alcance es la clase de defecto.
* **Sin cambios de contenido:** no se agregan/quitan salas, enemigos, packs, props obligatorios ni se modifica la dificultad.

#### 2. Reintento del encuentro de jefe

* **Estados del encuentro:** se conserva el flujo existente (dormido → gracia de 10 s → puerta cerrada → derrotado) y se agrega una transición explícita de **reinicio por wipe**.
* **Detección de wipe (server-authoritative):**
  * **Solo:** la muerte del único jugador es wipe.
  * **Party:** wipe cuando **ningún** miembro de la run queda vivo (los muertos en panel y los que abandonaron/desconectaron cuentan como no vivos). Una muerte parcial no es wipe.
  * **Enmienda R6.45 (softlock de party):** además del wipe total, si el encuentro está activo y **no queda ningún miembro vivo dentro de la arena** (aunque haya vivos fuera), ejecutar el reset para evitar el softlock; ver HU-R6.45.
* **Reset por wipe (idempotente, una vez por wipe):**
  * Jefe a su CFrame inicial y `Health = MaxHealth`.
  * Limpieza de fase, cooldowns, aggro/target, telegraphs, hazards (charcos, zonas persistentes, invocaciones si existieran) y cualquier estado temporal del encuentro.
  * Entrada de la arena **abierta** con una **nueva ventana de gracia de 10 s** para que el party pueda volver a entrar.
  * Sin loot, XP, oro, kill credit ni cofre; sin duplicar jefe, triggers ni recompensas.
  * No reinicia el piso, la topología, el seed, otros enemigos ni la run.
* **Alcance:** mini-jefes de pisos 1–4 y jefe final del piso 5.
* **Muerte parcial en party:** el jefe conserva vida, fase, cooldowns y target de los vivos; la puerta no cambia por esa muerte.
* **Jefe derrotado:** no se reinicia; continúa el flujo normal de puerta/recompensa (R7).
* **Reconciliación con R7.3:** la regla “el grace period no se extiende por reset del boss” sigue aplicando a los resets por **escape** del jefe. El reintento por **wipe de jugadores** es un evento distinto y recibe su propia ventana de 10 s.
* **Reconciliación con R7:** el DoD “muerte del jugador reinicia el encuentro” se precisa: en solo sí; en party solo con wipe total.

#### 3. Personaje muerto inerte (dungeon)

* **Al morir en una run:** el servidor marca al jugador como `dead` y abre el DeathPanel existente (R6.28). El cuerpo:
  * deja de ser visible (oculto; no se muestra como entidad de combate);
  * no colisiona ni dispara `Touched`/consultas contra enemigos, hazards, puertas o cofres;
  * no puede moverse, atacar con auto-attack, castear/channelizar skills, usar ítems ni interactuar con prompts;
  * cancela casts/auto-attacks en curso y deja de aplicar daño;
  * no recibe daño, DoT ni efectos de hazards;
  * deja de ser targeteable por enemigos y se limpia su aggro/target.
* **Autoridad del servidor:** todos los puntos de entrada de acción (auto-attack, `RequestCastSkill`, uso de ítems, interacción y movimiento validado) rechazan al jugador `dead`. El cliente no puede habilitarse por sí mismo ni forzar daño/estado.
* **Cámara:** spectator libre mientras el panel está abierto (R6.28), sin control del cuerpo.
* **Al revivir** (`RequestRespawn` o revive con Robux): el personaje reaparece en la entrada del piso con HP/MP llenos (R6.28), vuelve a ser visible/colisionable y recupera control y acciones; el panel se cierra.
* **Al abandonar:** se aplica el fin de run de R6b; el cuerpo no queda interactuando en la dungeon.
* **Fuera de la dungeon:** sin cambios; se conserva el respawn actual sin panel ni límite (R6.28, escenario 9).

#### 4. Integración con party y run

* El estado `dead`/`alive` es por jugador; el wipe se evalúa sobre los miembros presentes en la run.
* Los muertos no bloquean a los vivos ni cuentan como “vivos dentro de la arena”.
* Si todos abandonan/desconectan, la run termina según R6b/R9a.3.
* Sin cambios a loot/XP/cofre, matchmaking, escalado por integrantes ni composición de salas.

#### 5. Evidencia y observabilidad

* Log de servidor para: bloqueo detectado y reparado (seed/piso/variante/conexión), wipe detectado, reset ejecutado y rechazos de acciones de jugadores muertos.
* El RC debe incluir la reproducción del caso reportado (seed/piso/variante si se conoce) y la evidencia de QA (capturas/video, lista de seeds probados).

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Piso totalmente transitable

* **GIVEN** un piso generado de cualquier variante
* **WHEN** se valida la geometría real
* **THEN** existe un paso libre desde la entrada hasta todas las salas y la sala del jefe
* **AND** ninguna apertura, conector, spawn ni entrada de arena queda bloqueada por Parts, props o Terrain

#### Escenario 2: Caso reportado (sala bloqueada)

* **GIVEN** el seed/piso reportado con una pared sobre el acceso de una sala con enemigos
* **WHEN** se genera el piso con el fix
* **THEN** la sala es accesible y la run puede completarse
* **AND** el layout conserva el mismo seed, topología y contenido

#### Escenario 3: Reparación determinista

* **GIVEN** un piso que requiere reparación de una conexión
* **WHEN** se regenera el mismo `seed + piso`
* **THEN** se obtiene el mismo layout reparado, sin cambiar seed ni topología

#### Escenario 4: Muerte en solo frente al jefe

* **GIVEN** un jugador solo en un encuentro de jefe activo
* **WHEN** muere
* **THEN** el encuentro se reinicia: jefe en su punto inicial, vida completa y sin hazards/aggro/cooldowns
* **AND** la entrada de la arena queda abierta con 10 s de gracia para reintentar

#### Escenario 5: Muerte parcial en party

* **GIVEN** un party con al menos un miembro vivo en la arena
* **WHEN** otro miembro muere
* **THEN** el jefe conserva vida, fase, cooldowns y target de los vivos
* **AND** el encuentro y la puerta no se reinician

#### Escenario 6: Wipe en party

* **GIVEN** un encuentro de jefe activo en party
* **WHEN** muere el último miembro vivo
* **THEN** el encuentro se reinicia una sola vez con la regla de reset del escenario 4
* **AND** el primer miembro que reviva puede volver a entrar y pelear

#### Escenario 7: Sin recompensas por reset

* **GIVEN** un reset por wipe
* **WHEN** el party vuelve a enfrentar al jefe
* **THEN** no se otorgó loot, XP, oro, kill credit ni cofre por el intento anterior
* **AND** no hay jefe, triggers ni recompensas duplicadas

#### Escenario 8: Jefe derrotado

* **GIVEN** un jefe derrotado dentro de su arena
* **WHEN** termina el encuentro
* **THEN** el flujo normal de puerta, cofre y recompensa continúa
* **AND** el reset por wipe no se dispara

#### Escenario 9: Muerto inerte — acciones

* **GIVEN** un jugador muerto en dungeon con DeathPanel abierto
* **WHEN** intenta atacar, castear, usar ítems, moverse o interactuar
* **THEN** el servidor rechaza todas las acciones
* **AND** no se aplica daño a enemigos ni a otros jugadores

#### Escenario 10: Muerto inerte — colisión y targeting

* **GIVEN** un jugador muerto en dungeon
* **WHEN** enemigos, hazards o prompts evalúan su presencia
* **THEN** el cuerpo no colisiona, no dispara eventos y no es targeteable
* **AND** no recibe daño ni efectos mientras espera revivir o abandonar

#### Escenario 11: Revivir restaura el control

* **GIVEN** un jugador muerto que elige Reaparecer o compra el revive
* **WHEN** el servidor valida y ejecuta el respawn
* **THEN** reaparece en la entrada del piso con HP/MP llenos, visible y colisionable
* **AND** recupera control, auto-attack, skills e interacciones

#### Escenario 12: Abandonar desde el panel

* **GIVEN** un jugador muerto en dungeon
* **WHEN** elige Abandonar y confirma
* **THEN** la run termina para él según R6b y conserva lo ganado
* **AND** su cuerpo no queda interactuando en la dungeon

#### Escenario 13: Regresión solo/party y PC/móvil

* **GIVEN** el fix aplicado
* **WHEN** se juega una run completa en solo y party (2–4), PC y móvil
* **THEN** R6.4/R6.28/R7/R7.3/R9a.3 siguen funcionando
* **AND** no hay errores rojos, atascos ni duplicaciones

---

### Comportamiento Visual / Reglas de Negocio

* El cuerpo muerto **no se ve** y no participa del combate; el jugador conserva la cámara spectator y el DeathPanel de R6.28 sin cambios de UI.
* La entrada de la arena muestra el mismo feedback de gracia de 10 s ya existente (R7.3); no se crea UI nueva.
* El reintento debe ser comprensible: al revivir, la puerta está abierta, el jefe está a vida completa y el encuentro puede comenzar de nuevo.
* No se agregan VFX/SFX nuevos; se reutilizan los existentes si hacen falta.
* Los muertos no deben quedar como “espectros” visibles ni seguir siendo seleccionables por nameplates/targeting.

---

### Alcance

#### Incluye

* Validación y reparación determinista de conexiones bloqueadas en la generación de todos los pisos/variantes.
* Reinicio de mini-jefes y jefe final por muerte en solo o wipe total en party, con entrada abierta y gracia de 10 s.
* Estado inerte del jugador muerto en dungeon (oculto, sin colisión, sin targeting, sin acciones) y restauración al revivir.
* Logs de diagnóstico y evidencia de QA (seeds, capturas/video).
* Enmiendas documentales a R7/R7.3 (precisión de la regla de muerte) y verificación del contrato de R6.28.

#### No incluye

* Cambiar seeds, topología, número de salas, spawns, enemigos, dificultad, loot, XP, oro ni economía.
* Rediseñar la UI del DeathPanel, la puerta de arena o el HUD.
* Nuevos jefes, habilidades, telegraphs, VFX/SFX o assets.
* Cambiar reglas de party/matchmaking, respawn fuera de dungeon o el límite de 3 resurrecciones.
* Resolver otros atascos no relacionados con la transitabilidad o el estado del encuentro.

---

### Definition of Done (DoD)

* [ ] Todos los pisos generados son transitables de entrada a jefe; ninguna apertura/conector/spawn/arena queda bloqueado.
* [ ] El caso reportado (“Gruta Glacial”) queda reproducido y corregido; se conserva seed/topología.
* [ ] La reparación es determinista y loguea seed/piso/variante/conexión.
* [ ] En solo, morir frente al jefe reinicia el encuentro (vida completa, sin hazards/aggro/cooldowns).
* [ ] En party, muerte parcial no reinicia; wipe total reinicia una sola vez.
* [ ] Tras el reset, la entrada está abierta con 10 s de gracia y el party puede reintentar.
* [ ] El reset no otorga ni duplica loot/XP/oro/cofre/kill credit.
* [ ] El jugador muerto es invisible, inerte, no colisiona, no es targeteable y no recibe daño.
* [ ] El servidor rechaza auto-attack, skills, ítems, interacción y movimiento de jugadores muertos.
* [ ] Revivir restaura visibilidad, colisión, control y acciones; abandonar cierra la run según R6b.
* [ ] Sin errores rojos en solo/party, PC/móvil; run completable después de un reintento.
* [ ] Evidencia de QA adjunta (seeds probados, capturas/video, logs).
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Se actualizan `PROJECT_ARCHITECTURE`, `DATA_SCHEMA` y el registro de la HU/RC si el fix agrega estados/atributos.
* [ ] Nota de cierre en GDD después de QA.

---

### Enmiendas a HUs vigentes

| HU | Texto vigente | Precisión de esta HU |
|----|---------------|----------------------|
| HU-R7 (DoD) | “Muerte del jugador reinicia el encuentro sin duplicar recompensas.” | En **solo** sí; en **party** solo con **wipe total**. Muerte parcial no reinicia. |
| HU-R7.3 | “El grace period no se extiende por reset del boss.” | Aplica a resets por **escape** del jefe. El reintento por **wipe de jugadores** recibe una ventana nueva de 10 s. |
| HU-R6.28 | “Mientras el panel está abierto… el personaje no actúa.” | Se refuerza: el cuerpo se oculta, no colisiona, no es targeteable y el servidor rechaza toda acción. |

---

### Decisiones por defecto

| Tema | Default |
|------|---------|
| Disparador de reset del jefe | Solo: muerte del jugador. Party: wipe total (ningún miembro vivo). Muerte parcial: sin reset. |
| Momento del reset | Al confirmarse el wipe; la arena queda lista para el reintento. |
| Estado tras el reset | Jefe en spawn, vida completa, sin fase/cooldowns/aggro/hazards; entrada abierta. |
| Gracia tras wipe | 10 s nuevos para entrar; no se extiende por escapes (R7.3). |
| Recompensas por reset | Ninguna: sin loot/XP/oro/cofre/kill credit; sin duplicados. |
| Cuerpo muerto | Oculto, sin colisión/Touched/Query, sin targeting, sin daño recibido ni aplicado. |
| Acciones del muerto | Rechazadas server-side (auto-attack, skills, ítems, interacción, movimiento). |
| Revivir | Entrada del piso, HP/MP llenos, visible/colisionable, control restaurado (R6.28). |
| Alcance de geometría | Todas las variantes/pisos; reparación determinista sin reseed. |
| “Gruta Glacial” | Nombre reportado por el PO; si el nombre interno difiere, el dev lo registra en el RC. |
| QA de geometría | Al menos 10 seeds por variante en los 5 pisos (solo) + el seed reportado si se conoce; party de 4 en muestra. |

---

### Estimación (orientativa)

2–3 sesiones del dev: validación/reparación de geometría, reset de encuentro por wipe, gating del estado muerto y regresión solo/party con evidencia.

---

### Historial

| Fecha | Cambio |
|-------|--------|
| 2026-10-27 | Creación de HU-R6.44 por reporte del PO: (1) pared generada bloquea una sala con enemigos en la dungeon Helada (“Gruta Glacial”); (2) el jefe no se reinicia al morir/revivir y la puerta queda cerrada — se cierra la regla solo/muerte y party/wipe total; (3) el personaje muerto sigue atacando e interactuando. Incluye enmiendas de precisión a R7 y R7.3 y refuerzo del contrato de R6.28. |
| 2026-10-27 | Implementada según reporte del PO; QA/verificación pendiente. |
| 2026-10-27 | Enmienda por HU-R6.45: reset también cuando no queda ningún miembro vivo dentro de la arena, aunque haya vivos fuera (softlock de party). |
