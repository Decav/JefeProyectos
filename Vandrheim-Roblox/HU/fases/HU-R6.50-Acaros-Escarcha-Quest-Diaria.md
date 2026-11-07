# HU-R6.50: Misiones diarias del Guía — polvo de escarcha y cacería (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Mundo / Enemigos / Retención
**Prioridad:** Alta — contenido de mundo y motivo de retorno diario
**Estado:** Implementada (reporte PO 2026-11-06); QA pendiente
**Tipo:** Enemigos de mundo + misiones diarias (dev)
**Fase GDD:** Mundo / Retención (post-R6.49; adelanto de quests diarias)
**Depende de:** HU-R6.49 (mapa/Hub y zonas), HU-R6.48 (PoC del mapa), HU-QUEST-01/02 (framework, Guía y onboarding), HU-ITEMS-02 (pociones), HU-ITEMS-03/07/08 (ítems verdes/joyería), HU-R6.31 (notificaciones), `EnemyConfig`, `EnemyService`, `InventoryService`, `DataService`
**Componentes observados:** Santuario Glacial de los Antiguos, `EnemyConfig`, `EnemyService`, spawns de mundo, `QuestService`, panel/tracker de misiones, `InventoryService`, Guía de la Helada en `ExpeditionGuidePost`
**No modifica:** combate base, dungeon, prólogo, economía ni balance de clases; extiende quests con una capa diaria.

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** que el Guía me dé una misión diaria distinta y encontrar ácaros de escarcha en el mundo,
**para** tener un motivo para volver cada día y progresar fuera de la run.

**Como** equipo,
**quiero** contenido diario acotado, con recompensas controladas y sin farmeo,
**para** mejorar la retención sin inflar la economía.

---

### Descripción / Contexto

El mapa nuevo tiene el **Santuario Glacial de los Antiguos** accesible caminando desde Valgard. El PO quiere:

1. **Ácaros de escarcha** como enemigos de mundo cerca del Santuario, con respawn.
2. Una **misión diaria dada por el Guía** (no un tablón), con dos variantes posibles:
   * **Polvo de escarcha:** los ácaros dropean un ítem de misión nuevo, “Polvo de escarcha”, solo mientras la misión está activa; reunir 9.
   * **Cacería:** derrotar un enemigo normal concreto (sin jefes); la recompensa escala con el nivel del enemigo; nivel 12+ da un ítem azul aleatorio.
3. La misión se puede **tomar/reclamar 2 veces por día**, no es acumulable y se resetea a las 00:00 UTC.

La tienda rotativa del Mercader Errante es una HU aparte (`HU-R6.51`).

**Criterio de hecho global:** el Guía ofrece una misión diaria por personaje, con 2 recompensas máximo por día; la variante de polvo requiere 9 drops de ácaros (80 % por kill, solo con la misión activa); la variante de cacería pide 6 kills de un enemigo normal y escala la recompensa por nivel; el estado no se acumula, se resetea a las 00:00 UTC y no se puede reclamar dos veces la misma recompensa.

---

### Especificaciones Técnicas / Contratos

#### 1. Ácaros de escarcha (`helada_frost_mite`)

* Nuevo template en `EnemyConfig`:
  * `id = "helada_frost_mite"`.
  * Nombre visible: “Ácaro de escarcha”.
  * Nivel: **2** (configurable).
  * HP/daño bajos, pensados para un PJ recién creado; valores iniciales a validar en QA.
  * IA melee simple; `aggroRange` ~18, `attackRange` ~6, leash ~40; no persigue hasta el pueblo ni atraviesa el portal.
  * Sin loot, sin oro y sin ítems normales; XP bajo (configurable).
  * Sin élite, invocaciones ni habilidades especiales.
  * `modelId` placeholder; reemplazo por config cuando el diseñador entregue el modelo final. No crear assets nuevos en esta HU.
* Spawns:
  * 8–12 puntos en la periferia del **Santuario Glacial de los Antiguos**, fuera del camino principal, del portal y de los NPCs.
  * Packs de 2–4 ácaros; no bloquear el paso al portal.
  * Respawn **45 s** por punto (configurable), server-side, desde el primer spawn.
  * Respawn por spawn point, no por jugador; si el servidor reinicia, se repueblan.
  * Sin spawns en la dungeon, Valgard o `El Espejo Glacial`.
* Crédito de kills: personal; los kills de party no cuentan si el jugador no participa.
* El enemigo debe respetar el terreno, no caer al vacío ni quedar atrapado.

#### 2. Misión diaria dada por el Guía

* El **Guía de la Helada**, en el **Puesto del Guía y Expedición** (`ExpeditionGuidePost`) de Valgard, ofrece la misión diaria; **no hay tablón ni NPC nuevo**.
* La opción “Misión diaria” aparece en el panel del Guía cuando el jugador tiene un personaje activo y ya completó la onboarding (`intro_helada`).
* Una sola misión diaria **activa** a la vez; no se acumula con otra diaria ni con progreso de días anteriores.
* **2 recompensas por personaje por día UTC**:
  * El jugador puede aceptar/completar/reclamar la diaria hasta 2 veces.
  * Si abandona la misión, puede volver a tomarla; abandonar no consume recompensa, pero solo se pagan 2 recompensas.
  * Después de la 2.ª recompensa, el Guía muestra “Vuelve mañana” hasta el reset.
* Reset a las **00:00 UTC** (`dateKey = YYYY-MM-DD`). Al cambiar el día: variante nueva, progreso 0 y 2 recompensas disponibles.
* La diaria no cuenta para el límite de 5 pendientes; es un slot diario especial.
* Estado por **personaje** (`activeChar.dailyQuest`): variante, progreso, recompensas y `dateKey`; la recompensa se entrega al personaje que la reclama.
* Persistencia: `dailyQuest` en el perfil de cuenta; migración segura; sobrevive rejoin/cambio de personaje.
* Server-authoritative; sin avance desde cliente.

#### 3. Variante A — Polvo de escarcha

* Objetivo: reunir **9 Polvos de escarcha** (`quest_frost_dust`).
* **Ítem nuevo de misión:** `quest_frost_dust`, “Polvo de escarcha”.
  * Icono: `Icon_Item_frost_dust`, asset `100477087334778` (`rbxassetid://100477087334778`, Image, autor Decavii, aportado por el PO). El dev lo registra en `ASSETS_POLICY`/`ASSETS_REGISTRY` e `ItemConfig`. No generar arte nuevo.
  * `questItem = true`; `stackable = true`; `maxStack = 99`; sin stats; **no tradeable, no vendible, no subastable**.
  * Aparece en la mochila para que el jugador vea el progreso; se elimina al reclamar, abandonar o resetear.
* **Drop:** solo los `helada_frost_mite`; **80 % por kill**; solo mientras la variante está `active`; no cae si la misión no está activa, si ya hay 9 o si la misión está completada.
* Al llegar a 9, el drop se detiene; el jugador vuelve al Guía para completar.
* **No acumulable:** si abandona o resetea, se eliminan los polvos; no se guardan para el próximo intento/día.
* Recompensa: **1 ítem verde aleatorio + 5 `potion_hp_large` + 45 de oro** (misma lógica de ítem verde de `HU-R6.50` anterior; pool existente, clase/nivel, sin Unique/Epic).
* `potion_hp_large` es la **poción de vida grande existente (verde)**; no crear una poción nueva.

#### 4. Variante B — Cacería

* Objetivo: derrotar **6 enemigos normales** de un tipo concreto elegido por el Guía.
* Tipos elegibles: enemigos normales de la Helada (mundo o dungeon) que **no sean jefes, mini-jefes ni élites**. No se puede elegir un jefe.
* El objetivo se selecciona según el nivel del jugador (enemigo cercano a su nivel); el nivel del enemigo define la banda de recompensa.
* Crédito personal; kills de party no cuentan si el jugador no participa.
* Bandas de recompensa:

| Nivel del enemigo objetivo | Ítem | Pociones | Oro |
|---|---|---|---|
| 1–5 | 1 verde aleatorio | 5 `potion_hp_large` | 30 |
| 6–11 | 1 verde aleatorio | 5 `potion_hp_large` | 45 |
| 12+ | **1 azul aleatorio** | 5 `potion_hp_large` | 60 |

* Sin morados, uniques ni épicas por la diaria.
* El ítem sigue el mismo pool/filtro de clase y nivel que la variante A; el azul usa templates existentes (`*_blue`, `collar_blue`, `ring_blue_*`).
* El tracker marca el Santuario/dungeon donde se encuentra el objetivo; no marca cada enemigo.

#### 5. Selección de la variante

* El Guía elige **una variante por personaje y día** de forma determinista (`characterId + dateKey`): `frost_dust` o `hunt`.
* El jugador no elige la variante; el Guía la ofrece.
* Las 2 recompensas del día son de la misma variante.
* La variante se mantiene aunque el jugador cambie de personaje o rejoin.

#### 6. UI

* La diaria usa el panel del Guía existente; no hay modal nuevo.
* Muestra: variante, objetivo, progreso (`0/9` o `0/6`), recompensa, recompensas restantes (`2/2`) y “Se renueva en X h”.
* Tracker: si la diaria es la activa, muestra objetivo/progreso; si no, vive en el panel.
* Notificaciones: aceptada, completada, recompensa reclamada, mochila llena, sin recompensas; reutilizar el sistema existente.
* PC y móvil; botones táctiles ≥44 px.

#### 7. Persistencia y seguridad

* Estado de cuenta: `dailyQuest = { dateKey, variant, status, progress, claims, acceptedAt, completedAt }`.
* Una recompensa por claim; máximo 2 claims por `dateKey`; idempotente.
* No se puede reclamar dos veces la misma toma; no se puede saltar el contador con rejoin.
* El servidor valida kills, drops, 9 polvos, nivel del objetivo, fecha UTC, clase/nivel del ítem, mochila y recompensa.
* Los ácaros no dan loot/oro; el único incentivo es la diaria.
* Si la mochila está llena al reclamar, la diaria queda `completed`, el Guía mantiene `?` y se muestra “Mochila llena”; el jugador puede liberar espacio y reclamar antes del reset.

#### 8. Analítica

* Eventos: `daily_offered`, `daily_variant_selected`, `daily_accepted`, `daily_progress`, `daily_completed`, `daily_claimed`, `daily_claim_blocked_full`, `daily_reset`, `frost_dust_dropped`, `frost_mite_killed`.
* Medir tiempo a completar, recompensas usadas y abandono.

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Oferta del Guía

* **GIVEN** un jugador con onboarding completada
* **WHEN** interactúa con el Guía
* **THEN** ve la opción “Misión diaria” con la variante del día
* **AND** no hay tablón ni NPC diario adicional

#### Escenario 2: Dos recompensas por día

* **GIVEN** una diaria disponible
* **WHEN** el jugador completa y reclama
* **THEN** puede tomar la segunda toma del día
* **AND** al reclamar la segunda, el Guía muestra “Vuelve mañana”

#### Escenario 3: No acumulable

* **GIVEN** una diaria completada sin reclamar o abandonada
* **WHEN** el jugador toma otra o cambia de día
* **THEN** no se acumulan recompensas ni progreso
* **AND** los polvos sobrantes se eliminan

#### Escenario 4: Polvo de escarcha

* **GIVEN** la variante de polvo activa
* **WHEN** el jugador derrota ácaros
* **THEN** cada ácaro tiene 80 % de drop de `quest_frost_dust`
* **AND** el drop se detiene al llegar a 9
* **AND** no cae si la misión no está activa

#### Escenario 5: Reunir 9 polvos

* **GIVEN** 9 polvos en la mochila
* **WHEN** el jugador vuelve al Guía
* **THEN** la diaria queda `completed`
* **AND** puede reclamar 1 verde + 5 pociones + 45 oro

#### Escenario 6: Cacería

* **GIVEN** la variante de cacería activa
* **WHEN** el jugador derrota 6 enemigos normales del tipo elegido
* **THEN** la diaria se completa
* **AND** la recompensa corresponde a la banda de nivel del enemigo

#### Escenario 7: Nivel 12+

* **GIVEN** un objetivo de nivel 12 o superior
* **WHEN** el jugador completa la cacería
* **THEN** recibe 1 ítem azul aleatorio, 5 pociones y 60 oro

#### Escenario 8: Sin jefes

* **GIVEN** la selección de objetivo de cacería
* **WHEN** el Guía elige el enemigo
* **THEN** nunca elige un jefe, mini-jefe o élite

#### Escenario 9: Mochila llena

* **GIVEN** la diaria completada y sin espacio
* **WHEN** el jugador intenta reclamar
* **THEN** no se entrega nada
* **AND** la diaria sigue `completed`, el Guía mantiene `?` y se muestra “Mochila llena”

#### Escenario 10: Reset diario

* **GIVEN** una diaria reclamada o completada sin reclamar
* **WHEN** cambia el día UTC
* **THEN** vuelve a estar disponible con 2 recompensas y progreso 0
* **AND** no se acumulan recompensas ni polvos

#### Escenario 11: Rejoin/cambio de personaje

* **GIVEN** una diaria en progreso
* **WHEN** el jugador sale, vuelve o cambia de personaje
* **THEN** el estado de cuenta se conserva
* **AND** cada personaje conserva su propio estado diario; la recompensa se entrega al personaje que la reclama

#### Escenario 12: Regresión

* **GIVEN** el sistema implementado
* **WHEN** se juega solo/party, hub/dungeon, PC/móvil
* **THEN** combate, loot, quests, inventario, economía y dungeon siguen funcionando
* **AND** no hay errores rojos

---

### Comportamiento Visual / UI-UX

* El Guía debe mostrar la diaria sin tapar la onboarding; la opción aparece cuando corresponde.
* Los ácaros deben ser visibles y distinguibles como enemigos de mundo; nameplate/HP estándar.
* El Polvo de escarcha debe verse en la mochila con su icono; sin acciones de venta/trade.
* La recompensa se muestra con iconos/cantidades; el ítem verde/azul con su rareza.
* El estado “mochila llena” y “sin recompensas” se explica; el reset se muestra en horas.
* Sin minimapa; el marcador apunta a la zona/dungeon del objetivo.

---

### Alcance

#### Incluye

* Template `helada_frost_mite`, spawns y respawn de 45 s.
* Guía como único giver de la diaria; 2 recompensas/día; reset UTC.
* Variante polvo: `quest_frost_dust`, drop 80 %, 9 unidades, no acumulable.
* Variante cacería: 6 enemigos normales, bandas por nivel; 12+ azul.
* Recompensas verdes/azules + 5 `potion_hp_large` + oro.
* Claim atómico, persistencia, analítica y UI existente.

#### No incluye

* Tienda rotativa del Mercader Errante (HU-R6.51).
* Cambios a combate, dungeon, prólogo, economía o balance de clases.
* Nuevos ítems verdes/azules, uniques, épicas o pociones verdes; se usan los existentes.
* Loot/oro/XP de los ácaros (solo la diaria).
* Quest semanal, racha o múltiples diarias simultáneas.
* Nuevos assets/modelos finales; se usa placeholder hasta EST-02/diseñador.

---

### Definition of Done (DoD)

* [ ] Ácaros de escarcha con spawns, IA melee y respawn de 45 s.
* [ ] Guía ofrece la diaria; 2 recompensas/día; sin tablón.
* [ ] Variante polvo con drop 80 %, 9 unidades y limpieza de sobrantes.
* [ ] Variante cacería con 6 kills, objetivo sin jefes y bandas por nivel.
* [ ] Recompensa 1 verde/azul + 5 `potion_hp_large` + oro, atómica.
* [ ] Mochila llena bloquea sin perder la recompensa.
* [ ] Sin doble claim; rejoin/cambio de personaje conserva estado.
* [ ] UI/tracker/notificaciones y marcador de zona/dungeon.
* [ ] Analítica y QA en PC/móvil, solo/party.
* [ ] Sin errores rojos; regresión de combate/loot/quests/inventario.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota de cierre en GDD/roadmap.

---

### Decisiones por defecto

| Tema | Default |
|---|---|
| Giver | Guía de la Helada |
| Variantes | `frost_dust` y `hunt`; una por personaje/día |
| Recompensas | 2 por personaje/día UTC; abandonar permite reintentar sin consumir recompensa |
| No acumulable | Sí; sobrantes se eliminan |
| Polvo | `quest_frost_dust`; drop 80 %; 9 unidades |
| Solo con misión activa | Sí |
| Cacería | 6 enemigos normales; sin jefes/mini-jefes/élites |
| Bandas | 1–5 verde/30 oro; 6–11 verde/45; 12+ azul/60 |
| Pociones | 5 `potion_hp_large` (poción de vida grande, verde) |
| Ítem verde/azul | Pool existente, clase/nivel; sin Unique/Epic |
| Claim | Atómico; mochila llena bloquea |
| Reset | 00:00 UTC |
| Estado | Por personaje; recompensa al personaje que la reclama |

---

### Estimación (orientativa)

2–3 sesiones del dev: template/spawns/respawn, ítem de polvo/drop, diaria por personaje, variante cacería, recompensas, UI y QA.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-11-04 | Creación de HU-R6.50: ácaros de escarcha con respawn, misiones diarias del Guía (polvo de escarcha 9×80 % y cacería con bandas por nivel), 2 recompensas/día por personaje, reset UTC y claim atómico. |
| 2026-11-04 | Ajuste PO: la diaria la da el Guía (sin tablón), no acumulable, 2 recompensas/día por personaje; abandonar permite reintentar sin consumir recompensa. Se agrega `quest_frost_dust` con icono `Icon_Item_frost_dust` (`rbxassetid://100477087334778`, Decavii) y la variante de cacería con azul para nivel 12+. |
| 2026-11-06 | Implementada (reporte PO 2026-11-06); QA pendiente. |
