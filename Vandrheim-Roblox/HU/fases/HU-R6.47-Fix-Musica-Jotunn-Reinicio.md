# HU-R6.47: Fix — la música de Jotunn se reinicia al castear el rugido (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Audio / Combate / Dungeon
**Prioridad:** Alta — rompe la continuidad del combate final
**Estado:** Fix implementado (reporte PO); QA de audio pendiente
**Tipo:** Bugfix (dev)
**Fase GDD:** Audio / Jefes
**Depende de:** HU-R6.34 (MusicClient), HU-R7.1/R7.2 (combate de Jotunn), HU-TUTORIAL-02 + rc130 (prólogo: `PrologueMusic` y casteo forzado del rugido), HU-R6.31 (audio)
**No modifica:** la IA de Jotunn, el daño del rugido, el resto de pistas ni el sistema de audio.

---

### Narrativa (INVEST)

**Como** jugador en la Helada,
**quiero** que la música del jefe suene de corrido durante todo el combate,
**para** no perder la tensión del enfrentamiento por cortes o reinicios.

---

### Descripción / Contexto

En el combate de Jotunn (piso 5 de la Helada) la música de jefe se reinicia desde el inicio, aparentemente al castear **Rugido congelante**. La sospecha del PO es que el prólogo introdujo el casteo forzado de esa habilidad, y que algún estado transitorio de ese flujo afecta al contexto musical también en la dungeon.

La música debe reproducirse de corrido durante todo el encuentro, sin reinicios, y cambiar solo cuando cambie el contexto real (entrada al piso, inicio/fin del jefe, fin de run).

---

### Evidencia revisada

* `StarterPlayerScripts.MusicClient` elige la pista en `chooseTrack` y solo devuelve `jotunn_battle` si se cumplen **todas** estas condiciones: piso ≥5, `bossId = helada_frostwarden`, `state == "Active"`, `engaged == true` y `bossHp > 0`.
* `MusicClient` escucha **cada** `BossEncounterState` y llama `refresh()`. Cualquier emisión con un estado transitorio recalcula la pista.
* `EnemyService` recalcula `BossEngaged` en cada ciclo de IA según la distancia al jugador (`findNearestPlayer(root.Position, aggroRange, ...)`); `DungeonService` emite `BossEncounterState` cuando ese atributo cambia.
* `fadeTo` solo evita reiniciar si la pista es la misma **y** el `Sound` está reproduciéndose; durante un fundido, un loop o un cambio de contexto intermedio puede volver a arrancar la pista.
* rc130 añadió `PrologueMusic` (atributo de jugador) y `MusicClient` se refresca también cuando cambia ese atributo.

**Hipótesis principal:** durante el casteo del rugido se produce un cambio transitorio (engaged/bossHp/estado) que hace que `chooseTrack` devuelva `dungeon_3_5` un instante y luego vuelva a `jotunn_battle`, reiniciando la pista. Una variante es que el cambio de `PrologueMusic` provoque un `refresh()` en el momento del casteo.

---

### Especificaciones Técnicas / Contrato del fix

1. **La pista de jefe es pegajosa:** mientras el encuentro esté `Active` y el jefe vivo, `chooseTrack` devuelve `jotunn_battle` aunque `engaged` fluctúe o falte `bossHp` un instante. `engaged`/`bossHp` no deben degradar la pista a la del piso.
2. **Sin reinicios por refrescos redundantes:** `refresh()` no debe llamar a `fadeTo` con una clave distinta para volver a la misma en el mismo frame. Añadir debounce corto (p. ej. 150–250 ms) o comparar la clave resuelta con `currentKey` antes de iniciar el fundido.
3. **`PrologueMusic` aislado:** el atributo solo debe existir dentro del place del prólogo; al salir se limpia en servidor. `MusicClient` debe ignorarlo fuera del prólogo y no refrescar por él si la clave es nil.
4. **Casteo forzado:** el flujo de `ForcedAbilityId`/`ForcedAbilityImpact` no debe publicar cambios de contexto musical. Si publica algo, debe ser solo VFX/HUD.
5. **Regresión:** el resto de contextos (hub, piso 1–2, piso 3–5, jefe, fin de run) cambian con el mismo fundido que antes.

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Rugido sin reinicio

* **GIVEN** un combate activo contra Jotunn con su música sonando
* **WHEN** Jotunn castea Rugido congelante (y el resto de habilidades)
* **THEN** la pista sigue sonando de corrido, sin volver al inicio ni cambiar al tema del piso

#### Escenario 2: Fases y autoataques

* **GIVEN** el mismo combate
* **WHEN** se alternan Escombro, Avalancha, Rugido y autoataques
* **THEN** no hay cortes, reinicios ni dobles fundidos

#### Escenario 3: Entrada y salida del jefe

* **GIVEN** el jugador sube al piso 5 y entra a la arena
* **WHEN** empieza el encuentro
* **THEN** cambia una sola vez del tema del piso a `jotunn_battle`
* **AND** al terminar la run vuelve al contexto correcto una sola vez

#### Escenario 4: PrologueMusic fuera del prólogo

* **GIVEN** un jugador en la Helada que ya completó el prólogo
* **WHEN** cambia de piso o castea habilidades
* **THEN** `PrologueMusic` no existe y no provoca refrescos de música

#### Escenario 5: Solo y party

* **GIVEN** el encuentro en solo y en party de 2–4
* **WHEN** cualquiera de los jugadores observa la música
* **THEN** todos escuchan la pista continua, sin reinicios distintos por jugador

---

### Alcance

#### Incluye

* Estabilización de la selección de pista durante el combate de jefe.
* Debounce/guarda contra refrescos redundantes.
* Aislamiento de `PrologueMusic` al place del prólogo.
* QA de audio en el piso 5.

#### No incluye

* Cambiar pistas, volúmenes, fundidos ni assets.
* Modificar la IA de Jotunn o el daño del rugido.
* Rehacer el sistema de audio.

---

### Definition of Done (DoD)

* [ ] La música de Jotunn suena de corrido durante Rugido, Avalancha, Escombro y autoataques.
* [ ] `chooseTrack` no degrada la pista de jefe por fluctuaciones de `engaged`/`bossHp` mientras el encuentro esté activo y el jefe vivo.
* [ ] No hay dobles fundidos ni reinicios por refrescos redundantes (debounce/guarda aplicados).
* [ ] `PrologueMusic` solo existe en el place del prólogo y se limpia al salir.
* [ ] QA en solo y party, PC y móvil; sin errores ni warnings de audio nuevos.

---

### Estimación (orientativa)

1 sesión del dev: guarda de contexto + debounce + aislamiento del atributo + QA.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-11-03 | Creación de HU-R6.47: la música de Jotunn se reinicia al castear el rugido; se documentan los puntos de `MusicClient` y `BossEncounterState` que pueden causar el corte y el fix propuesto (pista pegajosa, debounce y aislamiento de `PrologueMusic`). |
| 2026-11-06 | Fix implementado (reporte PO); QA de audio pendiente en solo/party, PC/móvil. |
