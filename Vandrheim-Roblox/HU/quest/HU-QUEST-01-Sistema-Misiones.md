# HU-QUEST-01: Sistema de misiones — framework (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** QUEST — Sistema de misiones / retención
**Prioridad:** Alta — retención de beta
**Estado:** Implementada y validada funcionalmente por el PO (2026-11-04); QA/performance pendiente
**Tipo:** Sistema nuevo (dev)
**Fase GDD:** QUEST-01 (adelanto de R10+; decisión PO 2026-10-27)
**Depende de:** HU-R2 (perfil/PJ), HU-R4/R5 (inventario/oro), HU-R6a/R6b (dungeon), HU-R6.5/R6.10/R6.35 (UI/menú/micromenú), HU-R8 (XP/nivel), HU-TUTORIAL-01 (onboarding; se coordina), `DataService`, `InventoryService`, `ClassService`, `DungeonService`, `EnemyService`, `LootService`, `CharacterService`
**Componentes observados:** perfil de personaje, inventario/stacking, XP/nivel, eventos de dungeon y enemigos, loot pickup, `MenuUI`/micromenú, HUD, NPCs del hub
**No modifica:** combate, loot, dungeon, economía, clases ni la UI existente; agrega la capa de misiones.

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** una misión activa con un objetivo claro y un marcador en el mundo,
**para** saber qué hacer sin perderme y tener una razón para seguir jugando.

**Como** equipo,
**quiero** un framework de misiones data-driven y reutilizable,
**para** agregar contenido futuro sin rehacer el sistema.

---

### Descripción / Contexto

El juego no tiene sistema de misiones. La onboarding actual usa tarjetas; el jugador no tiene un objetivo persistente ni un marcador en el mundo. Esta HU crea el framework:

* Una misión activa, hasta 5 pendientes aceptadas.
* Tracker solo con la activa y panel completo (Cuaderno).
* Marcadores world-space sin minimapa.
* Dificultades con techo de rareza y claim atómico.
* NPC giver, persistencia, analítica y debug.

El contenido inicial (quest de onboarding) se implementa en `HU-QUEST-02`.

**Criterio de hecho global:** el servidor puede ofrecer, aceptar, trackear, avanzar, completar y reclamar misiones; el cliente ve tracker/log/panel y marcadores; el estado persiste por personaje y cross-place; el claim respeta la mochila y no duplica recompensas.

---

### Especificaciones Técnicas / Contratos

#### 1. `QuestConfig` (data-driven, shared)

ModuleScript en `ReplicatedStorage.Config.QuestConfig` (o equivalente). El cliente puede leer títulos/recompensas; el servidor valida todo.

```lua
{
  id = "intro_helada",
  title = "El primer invierno",
  description = "Aprendé lo básico y completá tu primera incursión.",
  difficulty = "Intro", -- Intro | Facil | Normal | Dificil | Elite
  category = "Onboarding",
  giverNpcId = "guide_helada",
  autoAccept = true,
  maxItemLevel = 1,
  nextQuestId = nil,
  prerequisites = {}, -- futuro: quests/nivel
  steps = {
    { id = "talk_guide", type = "talk", npcId = "guide_helada", text = "Hablá con el Guía." },
    {
      id = "choose_weapon", type = "choice", npcId = "guide_helada",
      text = "Elegí tu primera arma.",
      optionsByClass = {
        Paladin = {
          { id = "sword_shield", label = "Espada 1H + Escudo",
            items = { { templateId = "sword_white" }, { templateId = "shield_white" } } },
          { id = "greatsword", label = "Espadón 2H",
            items = { { templateId = "greatsword_white" } } },
        },
        Hunter = {
          { id = "bow", label = "Arco", items = { { templateId = "bow_white" } } },
          { id = "sword", label = "Espada 1H", items = { { templateId = "sword_white" } } },
        },
        Cleric = {
          { id = "wand", label = "Varita", items = { { templateId = "wand_white" } } },
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
    xp = 0, -- config: XP para nivel 2
    gold = 0,
    items = { { templateId = "potion_health", quantity = 10 } },
  },
}
```

Reglas:

* `id` único; `difficulty` y `category` para UI/filtros.
* `steps` secuenciales; cada paso tiene `type` + parámetros.
* `rewards` es la recompensa de **completar la quest**; no hardcodear en el servicio.
* **Recompensas de paso:** un paso puede tener `reward` o ser `type="choice"`; se entrega al completar ese paso, antes de la recompensa final.
* **Choice:** opciones por clase; el jugador elige una; el servidor valida clase, opción y entrega; es única e idempotente.
* `nextQuestId` permite encadenar; puede ser `nil`.
* `prerequisites` queda en schema para futuro; en MVP solo se usa `autoAccept`.

#### 2. `QuestState` (perfil, server-authoritative)

Agregar al perfil por personaje:

```lua
quests = {
  activeQuestId = "intro_helada",
  trackedQuestId = "intro_helada",
  entries = {
    intro_helada = {
      status = "active", -- available | active | pending | completed | rewarded | skipped
      stepIndex = 1,
      progress = { kill_three = 0, loot_one = 0 },
      choices = { choose_weapon = "sword_shield" },
      stepRewards = { choose_weapon = true },
      acceptedAt = 0,
      completedAt = 0,
      rewardedAt = 0,
      skipped = false,
    },
  },
}
```

* Migración: perfiles sin `quests` arrancan con tabla vacía; no se pierde nada.
* El servidor es la única autoridad; el cliente recibe un snapshot.
* El estado se conserva en rejoin y hub↔dungeon; personaje nuevo arranca limpio; borrar personaje elimina su estado.

#### 3. Estados y flujo

| Estado | Regla |
|---|---|
| `available` | La ofrece un NPC; no aceptada |
| `active` | Aceptada y trackeada; **solo 1** |
| `pending` | Aceptada, no trackeada; **máx. 5** |
| `completed` | Objetivos cumplidos; falta reclamar |
| `rewarded` | Recompensa entregada |
| `skipped` | Omitida; sin recompensa |

* Aceptar: si no hay activa → `active`; si hay activa y hay lugar → `pending`; si hay 5 pendientes → rechazar.
* Trackear: cambiar la activa; la anterior pasa a `pending`; el progreso se conserva.
* La onboarding se auto-acepta (`autoAccept`); no se abandona.
* `skipped` solo para cuentas que ya completaron la onboarding en otro personaje, y solo **después de elegir el arma**; no otorga la recompensa final.

#### 4. Objetivos y eventos

Tipos MVP:

| Tipo | Evento | Parámetros |
|---|---|---|
| `talk` | Interacción con NPC (prompt) | `npcId` |
| `enter` | Entrada a zona/dungeon | `zoneId` |
| `kill` | `EnemyService` muerte de enemigo | `count`, filtro opcional |
| `collect` | Loot pickup | `count`, template opcional |
| `complete_floor` | `FloorService.FloorCompleted` | `floor` |
| `choice` | Interacción con NPC + elección de recompensa | `npcId`, `optionsByClass` |

Reglas:

* Solo avanza el paso actual; los pasos son secuenciales.
* Crédito **personal**: el jugador debe dañar/matar al enemigo; kills de party no cuentan.
* El progreso se guarda por paso y persiste; no se resetea al salir/rejoin.
* No se completa una quest desde el cliente; el servidor escucha los eventos del mundo.
* Tipos nuevos se agregan por un registry; no hardcodear en el servicio.

#### 5. Dificultades y recompensas

| Dificultad | XP | Oro | Ítems | Techo de rareza |
|---|---|---|---|---|
| `Intro` | XP a nivel 2 | 0 | 10 `potion_health` | Common |
| `Facil` | Bajo | Bajo | 1 | Common/Uncommon |
| `Normal` | Medio | Medio | 1 | Uncommon/Rare |
| `Dificil` | Alto | Alto | 1–2 | Rare/Epic |
| `Elite` | Muy alto | Alto | 2 | Epic |

* `Unique` no se entrega por misiones.
* **Recompensas de paso:** `steps[i].reward` o `type="choice"` se entregan al completar el paso, antes de la recompensa final. La primera recompensa de la onboarding es la elección de arma.
* Nivel de ítem = nivel del jugador al reclamar, con cap `maxItemLevel`.
* Valores exactos en config; no hardcodear en el servicio.
* La UI muestra dificultad con color/label propio, sin confundir con rareza.

#### 6. Claim e inventario

* `InventoryService` expone una simulación de capacidad (`CanAddItems` o equivalente) que contempla stacking.
* Claim **atómico**: si no entra todo, no se entrega nada.
* Si la mochila está llena: la quest queda `completed`, el NPC mantiene `?`, el panel muestra “Mochila llena”; no se entrega XP/oro/ítems hasta liberar espacio.
* Claim idempotente: `rewardedAt`/flag evita doble entrega.
* Si la recompensa no tiene ítems, el claim no exige espacio.
* **Recompensa de paso (arma):** se valida contra el equipo/mochila; si el slot de arma está vacío, se equipa directo; si está ocupado, va a la mochila; si no hay espacio, se bloquea hasta liberar. Es única y no se repite.

#### 7. NPC giver

* `QuestConfig.giverNpcId` referencia un NPC con atributo `QuestNpcId`.
* El NPC tiene `ProximityPrompt` y un panel simple: aceptar, trackear, entregar/reclamar.
* Marcador `!` para disponible, `?` para entregar; el paso activo se marca con haz/icono.
* No hay diálogo ramificado ni tienda.
* El servidor valida distancia/interacción para aceptar y reclamar.
* En MVP, solo el Guía (`guide_helada`) da la onboarding; el framework soporta más NPCs.

#### 8. UI

* **Tracker:** solo la misión activa; paso, progreso, distancia y dificultad; siempre visible; click/tap abre panel. Tarjetas secundarias sin misiones (si se conservan).
* **Sin log separado:** el detalle de todas las misiones vive en el panel (Cuaderno).
* **Panel completo:** activas/pendientes/completadas/disponibles; detalle, dificultad, recompensa, “Trackear”/“Reclamar”.
* **Selección de primera arma:** dentro del panel del Guía (paso 2), con 2 opciones por clase; sin modal separado.
* **Acceso:** tecla `L` en PC; icono “Misiones” en micromenú; botón móvil.
* **Notificaciones:** reutilizar el `NotificationFrame` existente, con sus títulos y colores de código; no crear estilos nuevos.
* El cliente solo renderiza el snapshot; no decide estados ni recompensas.

#### 9. Marcadores world-space (sin minimapa)

* Haz de luz vertical + icono flotante + flecha/anillo en el piso sobre el objetivo.
* Si el objetivo está fuera de cámara, una flecha discreta en el borde ayuda; no es un minimapa.
* `AlwaysOnTop` solo para la quest activa y con distancia máxima; no tapar UI/combate.
* Por objetivo: NPC (hablar/elegir arma/entregar), portal (entrar), sala/pack (matar), loot/cofre (recoger), salida/sala del jefe (completar piso).
* Cross-place: en hub apunta al portal; dentro de la dungeon, al objetivo.
* Los marcadores son visuales; el servidor sigue siendo la autoridad del progreso.

#### 10. Persistencia y cross-place

* Estado por personaje en `DataService`; migración segura.
* Rejoin: se conserva; personaje nuevo: limpio; borrar personaje: se elimina.
* Hub ↔ dungeon: el estado se lee del perfil en ambos places; el cliente reconstruye tracker/marcadores.
* Si el jugador sale a mitad de run, el progreso de la quest se conserva; la run puede reiniciarse por R6b.

#### 11. Seguridad y anti-exploit

* Aceptar/trackear/reclamar por remotes validados; el servidor verifica estado, NPC/distance, paso, inventario y recompensa.
* El cliente no puede completar pasos, otorgarse recompensas ni cambiar estados.
* Claim idempotente; sin duplicados por reintentos/rejoins.
* No confiar en posiciones/objetivos enviados por el cliente.

#### 12. Analítica y debug

* Eventos: `quest_offered`, `quest_accepted`, `quest_step_completed`, `quest_completed`, `quest_claimed`, `quest_claim_blocked_full`, `quest_skipped`.
* Tiempo por paso y abandono por paso.
* Comandos de debug (admin/Studio): listar, resetear, completar paso, reclamar, forzar mochila llena.
* Logs estructurados por questId/stepId/playerId; sin datos sensibles.

#### 13. Integración y regresión

* `DataService`: perfil/migración.
* `InventoryService`: capacidad/stacking y entrega.
* `ClassService`/XP: recompensa de XP y nivel.
* `DungeonService`/`FloorService`: entrada y piso completado.
* `EnemyService`: muerte/crédito personal.
* `LootService`/pickup: recogida.
* `MenuUI`/micromenú/HUD: acceso y tracker.
* `Tutorial-01`: la quest reemplaza las tarjetas de pasos; el panel de Ayuda se conserva; evitar doble onboarding.
* `Tutorial-02` (prólogo): la misión de cuenta `prologo_caida_vandrheim` se maneja con `prologueStage` y reutiliza tracker/panel/marcadores; no usa `QuestState` por personaje. La onboarding se habilita recién al cerrar el prólogo con el Guía.
* No cambia combate, loot, economía ni balance.

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Aceptar y trackear

* **GIVEN** un NPC con una quest disponible
* **WHEN** el jugador la acepta
* **THEN** queda `active` (si no hay otra) o `pending` (si hay activa y hay lugar)
* **AND** el tracker muestra la activa y el marcador aparece

#### Escenario 2: Límite de pendientes

* **GIVEN** 5 misiones pendientes
* **WHEN** el jugador intenta aceptar otra
* **THEN** el servidor rechaza y explica el límite

#### Escenario 3: Cambiar la activa

* **GIVEN** una activa y una pendiente con progreso
* **WHEN** el jugador trackea la pendiente desde el panel
* **THEN** la nueva pasa a activa y la anterior a pendiente
* **AND** el progreso de ambas se conserva

#### Escenario 4: Progreso secuencial

* **GIVEN** una quest con pasos talk → enter → kill
* **WHEN** el jugador habla, entra y mata
* **THEN** cada paso avanza solo cuando corresponde
* **AND** matar antes de tiempo no completa el paso

#### Escenario 4b: Elección de arma

* **GIVEN** una quest con un paso `choice` y opciones por clase
* **WHEN** el jugador elige una opción
* **THEN** el servidor valida clase/opción y entrega solo esa opción
* **AND** si el slot de arma está vacío, la equipa; si no, va a la mochila
* **AND** si no hay espacio, la elección se bloquea y el paso no avanza
* **AND** el jugador no puede elegir dos veces

#### Escenario 5: Crédito personal

* **GIVEN** una quest de matar en party
* **WHEN** otro miembro mata al enemigo y el jugador no participa
* **THEN** el paso no avanza para el jugador

#### Escenario 6: Completar y reclamar

* **GIVEN** una quest con todos los pasos completos
* **WHEN** el jugador habla con el NPC y reclama
* **THEN** recibe XP/oro/ítems una sola vez
* **AND** la quest pasa a `rewarded`

#### Escenario 7: Mochila llena

* **GIVEN** una recompensa con ítems y una mochila sin espacio
* **WHEN** el jugador intenta reclamar
* **THEN** no se entrega nada
* **AND** la quest sigue `completed`, el NPC mantiene `?` y se muestra “Mochila llena”

#### Escenario 8: Stacking

* **GIVEN** 10 pociones existentes y espacio para 10 más
* **WHEN** se reclaman 10 pociones
* **THEN** entran en la pila hasta el máximo
* **AND** el claim es atómico

#### Escenario 9: Idempotencia

* **GIVEN** una recompensa ya reclamada
* **WHEN** el jugador reintenta o rejoin
* **THEN** no se duplica la entrega

#### Escenario 10: Rejoin y personaje nuevo

* **GIVEN** una quest en progreso
* **WHEN** el jugador sale y vuelve
* **THEN** el estado se conserva
* **AND** un personaje nuevo arranca sin quests previas

#### Escenario 11: Cross-place

* **GIVEN** una quest activa en el hub
* **WHEN** el jugador entra a la dungeon
* **THEN** el tracker y el marcador se reconstruyen
* **AND** el progreso se conserva

#### Escenario 12: Marcadores

* **GIVEN** una quest activa
* **WHEN** el jugador mira alrededor
* **THEN** ve el haz/icono/flecha en el objetivo
* **AND** si está fuera de cámara, una flecha de borde ayuda
* **AND** no hay minimapa

#### Escenario 13: Seguridad

* **GIVEN** un cliente manipulado
* **WHEN** intenta completar o reclamar sin cumplir
* **THEN** el servidor rechaza
* **AND** no se entrega nada

#### Escenario 14: UI

* **GIVEN** una quest activa y misiones pendientes
* **WHEN** el jugador abre el panel con `L` o el micromenú
* **THEN** ve activa, pendientes y completadas
* **AND** el tracker en pantalla muestra solo la activa

#### Escenario 15: Regresión

* **GIVEN** el sistema implementado
* **WHEN** se juega solo/party, hub/dungeon, PC/móvil
* **THEN** combate, loot, XP, inventario, dungeon y UI siguen funcionando
* **AND** no hay errores rojos ni duplicados

---

### Comportamiento Visual / UI-UX

* Tracker compacto en el lado derecho, solo con la activa; no tapar party/target; en móvil adaptar.
* Panel con tabs Activas/Pendientes/Completadas; detalle y recompensa; “Trackear”/“Reclamar”.
* La elección de arma se muestra dentro del panel del Guía; no hay modal aparte.
* Dificultad con color/label; recompensa con iconos/cantidad; advertencia de mochila llena.
* Marcadores legibles de día/noche, sin saturar; distancia máxima y fade.
* Notificaciones: reutilizar las existentes; no crear estilos nuevos.

---

### Alcance

#### Incluye

* `QuestConfig` + `QuestState` + migración.
* Servicio server-authoritative con aceptar/trackear/avanzar/completar/reclamar.
* Tipos de objetivo MVP y hooks de eventos.
* Dificultades/recompensas, claim atómico y validación de inventario.
* NPC giver genérico; Guía en HU-QUEST-02.
* Tracker solo con la activa, panel completo, `L`/micromenú/móvil.
* Guía con elección de arma en su panel (paso 2), sin modal.
* Marcadores world-space sin minimapa.
* Persistencia, cross-place, analítica y debug.
* QA/regresión.

#### No incluye

* Contenido de quests (salvo un test de QA); la onboarding va en HU-QUEST-02.
* Ramas, diarias, repetibles, party compartida, diálogos ramificados, ítems de misión, prerrequisitos complejos ni elección de recompensa.
* Cambios a combate, loot, economía, clases o balance.
* Log de misiones separado; el detalle va al panel.
* Minimapa.

---

### Definition of Done (DoD)

* [ ] Config/estado/migración implementados y testeados.
* [ ] 1 activa + 5 pendientes + tracker solo activa + panel completo.
* [ ] Aceptar/trackear/avanzar/completar/reclamar server-authoritative.
* [ ] Objetivos talk/enter/kill/collect/complete_floor/choice funcionando.
* [ ] Elección de arma inicial (2 opciones por clase) con equip/bag y bloqueo por espacio.
* [ ] Crédito personal; party no cuenta.
* [ ] Claim atómico con stacking y bloqueo por mochila llena.
* [ ] NPC giver con `!`/`?` y prompt.
* [ ] Tracker solo activa, panel, `L`, micromenú y móvil.
* [ ] Marcadores world-space; sin minimapa; cross-place.
* [ ] Persistencia/rejoin/personaje nuevo/borrado.
* [ ] Analítica y debug.
* [ ] Sin errores rojos; regresión de combate/loot/XP/inventario/dungeon.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Documentación/arquitectura actualizadas al cerrar.

---

### Decisiones por defecto

| Tema | Default |
|---|---|
| Activa | 1 |
| Pendientes | 5 aceptadas; tracker solo activa; panel todas |
| Log | Sin log separado; detalle en el panel |
| Aceptación | En NPC; onboarding auto-start |
| Onboarding | Auto-start; no abandonar; skip solo si la cuenta ya la completó |
| Crédito | Personal |
| Claim | Atómico; sin entrega parcial |
| Recompensa de paso | Elección de arma inicial (2 opciones por clase) |
| Rareza | Techo por dificultad; sin Unique |
| Item level | Nivel del jugador al reclamar, con cap |
| Marcadores | World-space; sin minimapa; flecha de borde opcional |
| Acceso UI | `L` + micromenú + móvil |
| Persistencia | Por personaje; cross-place |

---

### Estimación (orientativa)

3–4 sesiones del dev: modelo/servicio, hooks de objetivos, UI/tracker/panel, marcadores, claim/inventario, persistencia y QA.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-10-27 | Creación de HU-QUEST-01: framework de misiones con 1 activa, 5 pendientes, tracker/log/panel, objetivos MVP, dificultades con techo de rareza, claim atómico, NPC giver, marcadores world-space sin minimapa, persistencia y analítica. |
| 2026-10-27 | **Cambio PO:** soporte de recompensas de paso y `choice`; la onboarding entrega la elección de arma inicial antes de la dungeon. |
| 2026-10-31 | **Decisiones finales de UI:** tracker solo activo; sin log separado; detalle en el panel; elección de arma en el panel del Guía (no modal); notificaciones existentes. Paneles 2, 4 y 4b descartados. |
| 2026-11-04 | **Validado funcionalmente por el PO:** quests, tracker, panel y Guía funcionan. Se documenta la integración con el prólogo (`prologueStage`) y queda QA/performance pendiente. |
