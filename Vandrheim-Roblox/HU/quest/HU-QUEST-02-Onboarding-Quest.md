# HU-QUEST-02: Quest de onboarding — El primer invierno (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** QUEST — Onboarding / retención
**Prioridad:** Alta — primera sesión de beta
**Estado:** Implementada y validada funcionalmente por el PO (2026-11-04); QA/performance pendiente
**Tipo:** Contenido de misión + NPC Guía (dev)
**Fase GDD:** QUEST-02 (primera quest; adelanto de R10+; decisión PO 2026-10-27)
**Depende de:** HU-QUEST-01 (framework), HU-TUTORIAL-01 (onboarding actual; se coordina), HU-TUTORIAL-02 (prólogo y cierre en el Guía), HU-R2 (perfil/PJ), HU-R6a/R6b (dungeon), HU-R8 (XP/nivel), `InventoryService`, `DataService`, modelo/placeholder del Guía
**Componentes observados:** `QuestConfig`, `QuestService`, HUD/tracker, portal de la Helada, primer piso, loot, Guía del hub
**No modifica:** combate, loot, dungeon, economía, clases ni balance.

---

### Narrativa (INVEST)

**Como** jugador nuevo,
**quiero** una primera misión clara que me enseñe a hablar con el Guía, entrar a la Helada, matar, lootear y completar el primer piso,
**para** entender el loop y llegar a nivel 2 con una recompensa útil en mis primeros minutos.

**Como** equipo,
**quiero** que la onboarding sea la primera quest del sistema,
**para** validar el framework y mejorar la retención de la primera sesión.

---

### Descripción / Contexto

El jugador nuevo necesita un objetivo persistente y un marcador en el mundo. Esta HU agrega la primera quest real del sistema: `intro_helada`, auto-iniciada al crear/seleccionar un personaje nuevo, con el **Guía de la Helada** como único NPC giver.

La quest reemplaza las tarjetas de pasos de TUTORIAL-01; el panel de Ayuda y los tips contextuales de control se conservan para no duplicar onboarding.

**Criterio de hecho global:** un personaje nuevo recibe la quest automáticamente, ve el marcador del Guía, elige su arma inicial antes de entrar, completa los 6 pasos, reclama XP suficiente para nivel 2 + 10 pociones comunes de salud y termina con el loop entendido; si la mochila está llena, el claim se bloquea sin perder la recompensa.

---

### Especificaciones Técnicas / Contratos

#### 1. Definición de la quest

Agregar a `QuestConfig`:

```lua
{
  id = "intro_helada",
  title = "El primer invierno",
  description = "El Guía te espera. Aprendé lo básico y completá tu primera incursión en la Helada.",
  difficulty = "Intro",
  category = "Onboarding",
  giverNpcId = "guide_helada",
  autoAccept = true,
  maxItemLevel = 1,
  nextQuestId = nil,
  steps = {
    { id = "talk_guide", type = "talk", npcId = "guide_helada", text = "Hablá con el Guía de la Helada." },
    {
      id = "choose_weapon", type = "choice", npcId = "guide_helada",
      text = "Elegí tu primera arma.",
      optionsByClass = {
        Paladin = {
          { id = "sword_shield", label = "Espada 1H + Escudo", recommended = true,
            items = { { templateId = "sword_white" }, { templateId = "shield_white" } } },
          { id = "greatsword", label = "Espadón 2H",
            items = { { templateId = "greatsword_white" } } },
        },
        Hunter = {
          { id = "bow", label = "Arco", recommended = true,
            items = { { templateId = "bow_white" } } },
          { id = "sword", label = "Espada 1H", items = { { templateId = "sword_white" } } },
        },
        Cleric = {
          { id = "wand", label = "Varita", recommended = true,
            items = { { templateId = "wand_white" } } },
          { id = "sword_exp", label = "Espada 1H (experimental)",
            items = { { templateId = "sword_white" } } },
        },
      },
      equipIfSlotEmpty = true,
      bindState = "Bound",
    },
    { id = "enter_helada", type = "enter", zoneId = "helada", text = "Entrá a la Helada." },
    { id = "kill_three", type = "kill", count = 3, text = "Derrotá 3 enemigos." },
    { id = "loot_one", type = "collect", count = 1, text = "Recogé tu primer botín." },
    { id = "clear_floor", type = "complete_floor", floor = 1, text = "Completá el piso 1." },
  },
  rewards = {
    xp = 0, -- config: XP necesaria para nivel 2 desde nivel 1
    gold = 0,
    items = { { templateId = "potion_health", quantity = 10 } },
  },
}
```

Reglas:

* **Primera recompensa (paso 2):** elegir un arma inicial antes de entrar a la dungeon. Se entrega en el Guía; auto-equipa si el slot está vacío; si no, va a la mochila; si no hay espacio, se bloquea hasta liberar.
* Las opciones son armas blancas existentes (`sword_white`, `greatsword_white`, `bow_white`, `wand_white`, `shield_white`); no crear ítems nuevos. Son nivel 1, Common y `Bound` (no trade/auction).
* Cada clase tiene 2 opciones; la recomendada se marca en la UI. La opción de espada del Clérigo es experimental (sin afinidad) y debe verse como tal.
* `xp` se configura con la XP necesaria para pasar de nivel 1 a 2 según la curva vigente; al reclamar desde nivel 1, el jugador llega a nivel 2. Si ya está en nivel 2+, la XP se aplica a la progresión normal.
* `potion_health` es el ítem de poción de salud común existente; no crear un ítem nuevo.
* No hay oro; la recompensa final no incluye equipo. El arma inicial es una recompensa de paso separada.
* `nextQuestId = nil` por ahora; el sistema queda listo para encadenar.

#### 2. Guía de la Helada (NPC)

* `npcId = "guide_helada"`; nombre visible “Guía de la Helada”.
* Ubicación: hub, cerca del spawn y del portal de la Helada; visible desde el punto de aparición.
* Modelo: placeholder R15 con ropa de viajero; si el diseñador entrega un modelo final, se reemplaza sin tocar lógica.
* Atributos: `QuestNpcId = "guide_helada"`, `QuestGiver = true`.
* `ProximityPrompt` (E / tap) que abre el panel simple de la quest.
* No es vendor, no tiene tienda ni diálogo ramificado.
* Marcador `!`/`?` y haz/icono según el estado; el paso 1 es hablar con él y el paso 2 es elegir el arma.
* El Guía cierra primero `prologo_caida_vandrheim` (si está activo) y luego ofrece `intro_helada`; no iniciar la onboarding antes de ese cierre.
* Al hablar en el paso 2, abre el estado de elección de arma dentro del mismo panel del Guía; al completar los pasos, mantiene `?` hasta que el jugador reclame; si la mochila está llena, sigue `?` y muestra “Mochila llena”.

#### 3. Auto-start y skip

* Al crear/seleccionar un personaje nuevo sin la quest: si `prologueStage = done` (prólogo cerrado o veterano), el servidor la auto-acepta; si viene de `prologueStage = town`, la onboarding se ofrece al cerrar `prologo_caida_vandrheim` con el Guía y recién entonces queda `active`. No se auto-inicia antes del cierre del prólogo.
* Si el personaje ya la tiene (rejoin), no se duplica; se restaura el estado.
* Si la cuenta tiene otro personaje con `intro_helada` en `rewarded` o `skipped`, el jugador puede **omitir** la onboarding **después de elegir el arma** en el personaje nuevo, sin recompensa final.
* Si no hay personaje previo completado, no se puede omitir; el jugador puede ignorar la quest, pero el tracker sigue.
* La onboarding no se abandona.

#### 4. Pasos y progreso

1. **Hablar con el Guía:** interacción con el NPC; avanza a la elección de arma.
2. **Elegir el arma inicial:** estado de elección dentro del panel del Guía, con 2 opciones por clase; el jugador elige una; se otorga/equipa antes de entrar; avanza al paso 3.
3. **Entrar a la Helada:** entrada a la dungeon; avanza al paso 4.
4. **Derrotar 3 enemigos:** crédito personal; kills de party no cuentan; el jugador debe participar del daño/muerte.
5. **Recoger 1 botín:** pickup de cualquier ítem del primer piso; si la mochila está llena, no puede recoger y debe liberar espacio.
6. **Completar el piso 1:** evento de piso completado; al terminar, la quest pasa a `completed` y el marcador apunta al Guía para reclamar.

Reglas:

* Los pasos son secuenciales; las acciones previas al paso no cuentan.
* El progreso persiste en rejoin/cambio de piso; si la run se reinicia, el paso de piso completado se mantiene solo si ya se cumplió.
* Si el jugador muere, el progreso se conserva; no hay fallo de quest.
* Si el jugador sale a mitad de la dungeon, conserva los pasos completados; puede volver a entrar.

#### 5. Recompensa y claim

* **Primera recompensa (paso 2):** elegir arma inicial; se entrega/equipa en el Guía antes de la dungeon; es única e idempotente.
* **Recompensa final:** XP a nivel 2 + 10 `potion_health`.
* Claim final en el Guía, con panel de recompensa y preview de ítems.
* **Atómico:** si no entran las 10 pociones (stacking), no se entrega nada; no hay entrega parcial.
* Si la mochila está llena: la quest queda `completed`, el Guía mantiene `?`, se muestra “Mochila llena. Liberá espacio para reclamar.”; el jugador puede volver después.
* XP/oro/ítems se entregan juntos; el claim es idempotente y no se duplica por reintentos/rejoin.
* Si el jugador ya está en nivel 2+, la XP se suma a la progresión normal.

#### 6. Marcadores de la onboarding

| Paso | Marcador |
|---|---|
| 1 Hablar | Haz + icono sobre el Guía |
| 2 Elegir arma | Haz + icono sobre el Guía (abre la elección en el panel) |
| 3 Entrar | Haz sobre el portal de la Helada |
| 4 Matar | Haz sobre el piso 1/sala y el pack más cercano; no cada enemigo |
| 5 Recoger | Haz sobre el loot; si aún no hay drop, sobre el enemigo/cofre |
| 6 Completar piso | Haz sobre la salida/sala del jefe |
| Reclamar | Haz + `?` sobre el Guía |

* Marcadores world-space; sin minimapa; flecha de borde opcional si el objetivo está fuera de cámara.
* Cross-place: en el hub apunta al portal/Guía; dentro de la dungeon, al objetivo.
* No tapar UI/combate; distancia máxima y fade.

#### 7. UI y coordinación con TUTORIAL-01

* Tracker solo con la quest activa; sin log separado; panel completo con `L`/micromenú/móvil.
* **Elección de primera arma dentro del panel del Guía:** 2 tarjetas por clase, recomendada/experimental, icono, nombre, tipo, stats y “Elegir”; estados seleccionada, equipada y mochila llena. Sin modal aparte.
* Notificaciones: reutilizar las existentes del juego; no crear títulos/colores nuevos.
* La quest **reemplaza las tarjetas de pasos** de TUTORIAL-01; el panel de Ayuda se conserva.
* Los tips de control (mover, target, auto-attack, skills) se muestran contextualmente, una vez, sin bloquear; no duplicar con las tarjetas.
* Si el jugador ya completó la onboarding, no se muestran los tips de nuevo.

#### 8. Analítica

* Eventos: `intro_started`, `intro_step_talk`, `intro_step_weapon`, `intro_step_enter`, `intro_step_kill`, `intro_step_loot`, `intro_step_floor`, `intro_completed`, `intro_claimed`, `intro_claim_blocked_full`, `intro_skipped`.
* Tiempo por paso y abandono.
* Funnel: start → talk → weapon → enter → 3 kills → loot → floor 1 → claim.

#### 9. Integración y regresión

* `QuestService`/`QuestConfig` de HU-QUEST-01.
* `InventoryService` para stacking/capacidad y entrega de `potion_health`.
* `ClassService`/XP para nivel 2.
* `DungeonService`/`FloorService` para entrada y piso 1.
* `EnemyService` para kills personales.
* Loot pickup para el paso 4.
* HUD/micromenú/panel de misiones.
* No cambia combate, loot, economía ni balance.

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Auto-start

* **GIVEN** un personaje nuevo
* **WHEN** entra al hub
* **THEN** la quest `intro_helada` está `active`
* **AND** el tracker muestra “Hablá con el Guía” y el marcador aparece

#### Escenario 2: Hablar con el Guía

* **GIVEN** la quest en el paso 1
* **WHEN** el jugador interactúa con el Guía
* **THEN** avanza a la elección de arma
* **AND** el marcador sigue en el Guía

#### Escenario 2b: Elegir arma inicial

* **GIVEN** el paso 2 activo y la clase del personaje
* **WHEN** el jugador elige una de las 2 opciones
* **THEN** el servidor valida la clase/opción y entrega solo esa opción
* **AND** si el slot de arma está vacío, la equipa; si no, va a la mochila
* **AND** si no hay espacio, se bloquea y el paso no avanza
* **AND** el arma es Common, nivel 1 y Bound
* **AND** avanza al paso 3; el marcador apunta al portal

#### Escenario 3: Entrar a la Helada

* **GIVEN** el paso 3 activo
* **WHEN** el jugador entra a la dungeon
* **THEN** avanza al paso 4
* **AND** el marcador apunta al piso 1

#### Escenario 4: Tres kills personales

* **GIVEN** el paso 4 activo
* **WHEN** el jugador derrota 3 enemigos
* **THEN** el progreso llega a 3/3 y avanza al paso 5
* **AND** los kills de party no cuentan si el jugador no participa

#### Escenario 5: Loot

* **GIVEN** el paso 5 activo
* **WHEN** el jugador recoge un ítem
* **THEN** avanza al paso 6
* **AND** si la mochila está llena, no puede recoger y debe liberar espacio

#### Escenario 6: Piso 1 completo

* **GIVEN** el paso 6 activo
* **WHEN** el jugador completa el piso 1
* **THEN** la quest pasa a `completed`
* **AND** el marcador apunta al Guía para reclamar

#### Escenario 7: Recompensa

* **GIVEN** la quest `completed` y espacio en la mochila
* **WHEN** el jugador reclama en el Guía
* **THEN** recibe XP suficiente para nivel 2 y 10 `potion_health`
* **AND** la quest pasa a `rewarded` una sola vez

#### Escenario 8: Mochila llena

* **GIVEN** la quest `completed` y sin espacio para las 10 pociones
* **WHEN** el jugador intenta reclamar
* **THEN** no se entrega nada
* **AND** la quest sigue `completed`, el Guía mantiene `?` y se muestra “Mochila llena”

#### Escenario 9: Stacking

* **GIVEN** una pila de pociones con espacio parcial
* **WHEN** el jugador reclama
* **THEN** el claim solo procede si entran las 10 completas
* **AND** no hay entrega parcial

#### Escenario 10: Rejoin

* **GIVEN** la quest en progreso
* **WHEN** el jugador sale y vuelve
* **THEN** el estado y el progreso se conservan
* **AND** no se duplica la quest ni la recompensa

#### Escenario 11: Muerte y salida

* **GIVEN** el jugador muere o sale de la dungeon
* **WHEN** vuelve
* **THEN** los pasos completados se conservan
* **AND** puede continuar desde el paso actual

#### Escenario 12: Skip

* **GIVEN** una cuenta con otro personaje que completó la onboarding
* **WHEN** crea un personaje nuevo y elige el arma
* **THEN** puede omitir la quest sin recompensa final
* **AND** conserva el arma elegida
* **AND** no se muestra el tracker de onboarding

#### Escenario 13: Sin doble onboarding

* **GIVEN** la quest activa
* **WHEN** el jugador recibe los tips de control
* **THEN** no se muestran las tarjetas de pasos duplicadas
* **AND** el panel de Ayuda sigue disponible

#### Escenario 14: Regresión

* **GIVEN** la onboarding implementada
* **WHEN** se juega solo/party, hub/dungeon, PC/móvil
* **THEN** combate, loot, XP, inventario y dungeon siguen funcionando
* **AND** no hay errores rojos

---

### Comportamiento Visual / UI-UX

* El Guía debe ser visible desde el spawn; haz/icono de quest.
* Tracker claro y compacto; no tapar la UI de combate.
* Panel con título, descripción, pasos, recompensa (XP + 10 pociones) y estado de mochila.
* Notificaciones al completar cada paso y al reclamar.
* Tips de control contextuales, una vez, sin bloquear.

---

### Alcance

#### Incluye

* Quest `intro_helada` completa.
* Guía de la Helada como NPC giver en el hub.
* Auto-start, skip después de elegir el arma para cuentas con onboarding completada, progreso persistente.
* Elección de arma inicial antes de la dungeon, con auto-equip y bloqueo por espacio.
* Recompensa final XP a nivel 2 + 10 `potion_health`, claim atómico y bloqueo por mochila llena.
* Marcadores world-space de la onboarding.
* Integración con TUTORIAL-01 sin duplicar tarjetas.
* Analítica de los 6 pasos y claim.

#### No incluye

* Segunda quest, cadena de pisos, diarias, ramas o party compartida.
* Nuevos enemigos, loot, balance o cambios de dungeon.
* Editor de misiones o diálogos ramificados.
* Nuevos ítems de recompensa.

---

### Definition of Done (DoD)

* [ ] Personaje nuevo recibe `intro_helada` automáticamente.
* [ ] Guía presente y visible en el hub; prompt y marcador.
* [ ] 6 pasos funcionando con progreso personal y persistente.
* [ ] Elección de arma inicial antes de la dungeon, 2 opciones por clase, auto-equip y bloqueo por espacio.
* [ ] Recompensa final XP a nivel 2 + 10 pociones una sola vez.
* [ ] Claim atómico; mochila llena bloquea sin perder recompensa.
* [ ] Skip después de elegir el arma para cuentas con onboarding completada; sin recompensa final.
* [ ] Marcadores world-space; sin minimapa.
* [ ] Tracker solo activa, panel y notificaciones existentes.
* [ ] Sin doble onboarding con TUTORIAL-01.
* [ ] Analítica de pasos y claim.
* [ ] Sin errores rojos en solo/party, hub/dungeon, PC/móvil.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota de cierre en GDD y actualización del roadmap.

---

### Decisiones por defecto

| Tema | Default |
|---|---|
| Quest | `intro_helada` |
| Inicio | Auto-start al crear personaje |
| NPC | `guide_helada` en el hub |
| Pasos | Hablar → elegir arma → entrar → 3 kills → loot → piso 1 |
| Crédito | Personal |
| Primera recompensa | Elegir arma inicial (2 opciones por clase, Common, Bound) |
| Recompensa final | XP a nivel 2 + 10 `potion_health` |
| Claim | Atómico, en el Guía |
| Mochila llena | Bloquea; quest queda `completed` |
| Skip | Solo si la cuenta ya completó la onboarding y después de elegir el arma |
| Marcadores | World-space; sin minimapa |
| Siguiente quest | `nil` por ahora |

---

### Estimación (orientativa)

1–2 sesiones del dev: contenido de la quest, Guía, marcadores, integración con TUTORIAL-01, claim y QA.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-10-27 | Creación de HU-QUEST-02: primera quest `intro_helada` con Guía, 5 pasos, XP a nivel 2 + 10 pociones comunes, claim atómico, marcadores world-space y coordinación con TUTORIAL-01. |
| 2026-10-27 | **Cambio PO:** la primera recompensa es elegir el arma inicial antes de la dungeon (paso 2, 2 opciones por clase); la quest pasa a 6 pasos y la recompensa final sigue siendo XP nivel 2 + 10 pociones. Skip solo después de elegir el arma. |
| 2026-10-31 | **Decisiones finales de UI:** la elección de arma se hace dentro del panel del Guía (sin modal); tracker solo activo; sin log separado; notificaciones existentes. Los paneles 2, 4 y 4b quedan descartados. |
| 2026-11-04 | **Validado funcionalmente por el PO:** tutorial, misiones y prólogo funcionan. Se aclara que la onboarding no se auto-inicia antes de cerrar `prologo_caida_vandrheim` con el Guía. QA/performance pendiente. |
