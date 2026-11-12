# HU-R6.56: Red de piedras rúnicas — teletransporte por oro (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Mundo / Navegación / Economía
**Prioridad:** Media-Alta — comodidad y flujo entre zonas
**Estado:** Abierta — lista para RC
**Tipo:** NPC interactivo + teletransporte + POI (dev)
**Fase GDD:** Mundo / Hub / Economía
**Depende de:** HU-R6.49 (mapa/Hub), HU-R6.53 (POIs/caminos), `DialogView`/UI existente, `DataService`, `ProgressionService` (oro), `TeleportService` (solo si se cruza de place), `Workspace.Sounds.sfx_teleport`, HU-ESTETICA-53 (piedras rúnicas y naufragio; placeholders permitidos)
**Componentes observados:** `CentralPlaza`, portal/entrada de dungeon, `El Espejo Glacial`, `Río Escarchado`, `Workspace`, `DialogView`, oro del personaje
**No modifica:** dungeon instanciada, portal/matchmaking, party, economía base, stats, quests ni loot.

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** tres piedras rúnicas que me permitan viajar a Valgard, la entrada de la dungeon y el naufragio por 100 de oro,
**para** no perder tiempo caminando cuando quiero cambiar de actividad.

**Como** equipo,
**quiero** un sistema de viaje rápido acotado, con descubrimiento y costo,
**para** mejorar la comodidad sin vaciar el mundo ni romper el flujo de dungeon/party.

---

### Descripción / Contexto

El mapa nuevo es grande y cruzar de Valgard al Santuario o al naufragio puede volverse tedioso. Esta HU agrega **tres piedras rúnicas**:

1. **Valgard** — en `CentralPlaza`.
2. **Dungeon** — en la entrada/portal de la dungeon, no dentro de una run.
3. **Naufragio** — en un POI nuevo en `El Espejo Glacial`/`Río Escarchado`.

Cada piedra dialoga y ofrece viajar a las otras dos por **100 de oro** (configurable). El viaje se desbloquea al descubrir la piedra de destino; no se puede usar en combate, muerto ni dentro de una dungeon activa.

**Criterio de hecho global:** el jugador descubre las piedras caminando, puede abrir su diálogo y teletransportarse entre destinos descubiertos pagando 100 de oro; el viaje es server-authoritative, no rompe party/dungeon/portal, no permite entrar a una run activa y el naufragio queda como POI visible y seguro.

---

### Especificaciones Técnicas / Contratos

#### 1. Piedras y ubicaciones

| Piedra | Ubicación | Descubrimiento |
|---|---|---|
| `RunicStone_Village` | `CentralPlaza` de Valgard, cerca del spawn sin bloquearlo | Inicial |
| `RunicStone_Dungeon` | Entrada/portal de la dungeon en el Santuario | Al acercarse por primera vez |
| `RunicStone_Shipwreck` | `POI_Naufragio` en `El Espejo Glacial`/`Río Escarchado` | Al acercarse por primera vez |

* Cada piedra tiene `ProximityPrompt` (E/tap) y un diálogo con las otras dos opciones.
* La piedra del pueblo arranca descubierta; las otras se descubren al entrar en su radio de descubrimiento.
* No se puede teletransportar a una piedra no descubierta; la opción aparece bloqueada con “Destino no descubierto”.
* No crear una piedra dentro de la dungeon ni en el naufragio si el POI no existe; el naufragio es parte de esta HU.

#### 2. Naufragio

* Nuevo POI `POI_Naufragio` en la zona helada, cerca del agua/hielo; sin interiores, sin dungeon, sin portal.
* Composición: casco roto, cajas, mástil, cuerdas, nieve y una piedra rúnica; modelos de EST-53 o placeholders.
* Sin enemigos obligatorios ni loot de combate; puede tener ambientación y un futuro quest hook.
* Debe ser visible desde el camino y no bloquear rutas ni prompts.
* Sin softlocks; el jugador puede llegar caminando y salir.

#### 3. Diálogo y viaje

* Al interactuar con una piedra, abrir el diálogo existente (`DialogView` o equivalente) con:
  * título “Piedra rúnica”,
  * opciones a los otros dos destinos,
  * costo “100 de oro”,
  * estado “Destino no descubierto” si aplica,
  * opción Cerrar.
* Al elegir un destino:
  * validar que el jugador esté vivo, no en combate, no dentro de una dungeon activa y no en transición;
  * validar que el destino esté descubierto;
  * validar 100 de oro;
  * descontar oro de forma atómica;
  * teletransportar al punto seguro de la piedra de destino;
  * reproducir el VFX de runa existente;
  * reproducir `Workspace.Sounds.sfx_teleport` (`rbxassetid://80948730666012`); es el único SFX nuevo autorizado;
  * aplicar un fade breve;
  * aplicar cooldown de 5 s para evitar spam.
* Si el oro no alcanza o el destino no está descubierto, bloquear y mostrar el motivo; no descontar.
* Si el jugador está en party, solo se teletransporta él; no mover a la party.
* No teletransportar a una run activa, piso de dungeon, arena de jefe o sala de boss.
* No usar el viaje para saltar el portal/matchmaking ni para entrar a `Dungeon_Helada`; el destino “Dungeon” es la **entrada** en el Hub.
* No crear ni usar otros SFX nuevos; para el viaje, solo `Workspace.Sounds.sfx_teleport`.
* `sfx_teleport` ya está registrado en `ASSETS_POLICY`/`ASSETS_REGISTRY` con `rbxassetid://80948730666012`; no crear otro sonido.

#### 4. Datos y persistencia

* `profile.runicStones` por personaje: set/diccionario de piedras descubiertas.
* Migración con default `{}`; no borrar datos; actualizar `Schemas.PerfilPersistencia`/`DATA_SCHEMA`.
* La piedra del pueblo se marca descubierta al crear/cargar el personaje o al primer spawn.
* El estado de descubrimiento se guarda; el oro se descuenta del personaje activo.
* No se persiste ninguna posición de teletransporte; el destino es un punto fijo y seguro.
* Si el guardado del descubrimiento falla, no bloquear el juego; reintentar de forma segura.

#### 5. UI/UX y navegación

* El diálogo debe ser claro: destino, costo, estado y confirmación.
* No crear una ventana nueva si el diálogo existente alcanza; si se necesita un panel, reutilizar `DialogView`/UITheme.
* Mostrar el nombre del destino y el costo antes de confirmar.
* Sin minimapa ni iconos permanentes; las piedras se encuentran caminando.
* El jugador no debe quedar atrapado dentro de geometría al llegar; cada destino tiene un punto seguro validado.
* PC y móvil: prompt táctil y botones ≥44 px.

#### 6. Seguridad y anti-abuso

* El cliente no decide el destino, el costo ni el oro; todo se valida en servidor.
* No se puede teletransportar a un destino no descubierto, en combate, muerto, en dungeon o en transición.
* No se puede pagar dos veces por el mismo viaje ni duplicar oro/ítems.
* Cooldown de 5 s; si el jugador cancela, no se cobra.
* No se puede usar para evadir daño, bosses, loot o mecánicas de dungeon.
* Validar que el punto de destino esté libre y sea seguro; si está bloqueado, usar un fallback cercano.

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Descubrir una piedra

* **GIVEN** el jugador en el mapa
* **WHEN** se acerca a la piedra de la dungeon o del naufragio
* **THEN** queda descubierta para ese personaje
* **AND** se guarda en el perfil

#### Escenario 2: Viaje válido

* **GIVEN** dos piedras descubiertas y 100 de oro
* **WHEN** el jugador elige el destino
* **THEN** se descuentan 100 de oro
* **AND** aparece en el punto seguro del destino
* **AND** ve el VFX de runa existente
* **AND** escucha `Workspace.Sounds.sfx_teleport`

#### Escenario 3: Destino no descubierto

* **GIVEN** una piedra de destino no descubierta
* **WHEN** el jugador intenta viajar
* **THEN** la opción está bloqueada
* **AND** no se descuenta oro

#### Escenario 4: Sin oro

* **GIVEN** menos de 100 de oro
* **WHEN** el jugador intenta viajar
* **THEN** se bloquea con aviso
* **AND** no se mueve ni se descuenta nada

#### Escenario 5: Combate o dungeon

* **GIVEN** el jugador en combate o dentro de una dungeon activa
* **WHEN** intenta usar una piedra
* **THEN** el viaje se bloquea
* **AND** no se puede evadir la run ni el boss

#### Escenario 6: Party

* **GIVEN** un jugador en party
* **WHEN** se teletransporta
* **THEN** solo se mueve él
* **AND** la party no se divide automáticamente ni pierde la run

#### Escenario 7: Naufragio

* **GIVEN** el POI del naufragio activo
* **WHEN** el jugador llega caminando o por piedra
* **THEN** el lugar es seguro, visible y sin softlocks
* **AND** la piedra del naufragio funciona

#### Escenario 8: Regresión

* **GIVEN** la red de piedras implementada
* **WHEN** se juega hub → dungeon → hub, party y vendors
* **THEN** portal, matchmaking, economía y quests siguen funcionando
* **AND** no hay errores rojos

---

### Comportamiento Visual / UI-UX

* Las piedras deben verse antiguas, rúnicas y parte del mundo; no como un menú de teleport genérico.
* El diálogo debe dejar claro el costo y el destino antes de confirmar.
* El viaje debe sentirse como magia rúnica: VFX de runa existente, `sfx_teleport`, luz y fade breve.
* No agregar minimapa ni marcadores permanentes; el descubrimiento es parte del mundo.

---

### Alcance

#### Incluye

* 3 piedras rúnicas: Valgard, entrada de dungeon y naufragio.
* Diálogo con destinos, costo y estados.
* Viaje por 100 de oro, server-authoritative.
* Descubrimiento persistente por personaje.
* POI de naufragio.
* SFX `Workspace.Sounds.sfx_teleport`.
* Cooldown, validaciones y QA PC/móvil.

#### No incluye

* Teletransporte dentro de dungeons, runs activas o arenas.
* Viaje de party completo.
* Piedra en otras zonas o mapa nuevo.
* Nuevos ítems, monedas o economía de viaje.
* Otros SFX nuevos fuera de `sfx_teleport`.
* Modelos finales; EST-53 o placeholders.
* Minimapa, iconos permanentes o UI nueva si el diálogo existente alcanza.

---

### Definition of Done (DoD)

* [ ] 3 piedras colocadas y descubribles.
* [ ] Naufragio como POI seguro y visible.
* [ ] Diálogo con destinos, costo y bloqueos.
* [ ] Viaje por 100 de oro, sin duplicar ni evadir dungeon.
* [ ] `sfx_teleport` integrado y registrado; sin otros SFX nuevos.
* [ ] Persistencia de descubrimiento por personaje.
* [ ] Party/dungeon/combate validados.
* [ ] QA PC/móvil y puntos de llegada seguros.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).

---

### Decisiones por defecto

| Tema | Default |
|---|---|
| Piedras | Valgard, entrada de dungeon y naufragio |
| Costo | 100 de oro por viaje |
| Descubrimiento | Piedra del pueblo inicial; las otras al acercarse |
| Persistencia | `profile.runicStones` por personaje |
| Party | Solo viaja el jugador |
| Dungeon | Solo a la entrada; nunca dentro de una run |
| Cooldown | 5 s |
| Naufragio | POI nuevo en la zona helada |
| Audio | `Workspace.Sounds.sfx_teleport` (`rbxassetid://80948730666012`); sin otros SFX nuevos |
| UI | Diálogo existente; sin ventana nueva si alcanza |

---

### Estimación (orientativa)

2 sesiones del dev: piedras/diálogo, validaciones, persistencia, naufragio y QA.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-11-12 | Creación de HU-R6.56: red de 3 piedras rúnicas con diálogo, descubrimiento persistente, viaje por 100 de oro, naufragio como POI y bloqueo en combate/dungeon/party. |
| 2026-11-12 | Ajuste PO: se autoriza `Workspace.Sounds.sfx_teleport` (`rbxassetid://80948730666012`) como único SFX nuevo para el teletransporte; el resto del audio debe ser existente. |
