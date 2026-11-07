# Vandrheim — Diseño del sistema de misiones

**Proyecto:** Vandrheim (Roblox MVP)
**Estado:** Implementado y validado funcionalmente por el PO (2026-11-04); QA/performance pendiente
**Alcance:** framework de misiones + primera quest de onboarding
**Fuente:** GDD §14 (R10+), decisiones PO 2026-10-27
**HUs:** `HU/quest/HU-QUEST-01-Sistema-Misiones.md` y `HU/quest/HU-QUEST-02-Onboarding-Quest.md`

> Este documento define el producto y la UX del sistema. Los contratos técnicos viven en las HUs.

---

## 1. Objetivo

Dar al jugador un **objetivo claro y siempre visible** que lo lleve de “entré a un juego” a “completé mi primera dungeon y quiero seguir”, sin llenarlo de texto ni de misiones.

El sistema debe ser simple para el jugador y reutilizable para contenido futuro:

* Una misión activa a la vez.
* Hasta 5 misiones pendientes aceptadas.
* Un tracker en pantalla y un panel completo (Cuaderno).
* Marcadores en el mundo para saber dónde ir.
* Recompensas por dificultad, con validación de mochila.

---

## 2. Principios

1. **Una activa:** solo una misión se trackea y se marca en el mundo.
2. **Pocas pendientes:** máximo 5 aceptadas sin trackear; el tracker muestra solo la activa; el panel muestra todas.
3. **Sin minimapa:** el marcador es un objeto del mundo (haz, icono flotante, flecha en el piso). Si queda fuera de cámara, una flecha discreta en el borde ayuda, pero no reemplaza al marcador 3D.
4. **Server-authoritative:** el servidor valida aceptación, progreso, entrega y recompensa.
5. **Personal:** el progreso es por personaje; los kills de party no cuentan para la quest personal.
6. **Recompensa honesta:** la dificultad define el techo de rareza; las misiones complementan el loot de dungeon, no lo reemplazan.
7. **Sin pay-to-win:** las misiones no venden progreso ni recompensas.

---

## 3. Loop

Aceptar → trackear → ver el marcador → ir → completar el objetivo → volver al Guía → reclamar → siguiente objetivo.

El jugador nunca se pregunta “¿y ahora qué hago?”: el tracker y el marcador responden.

---

## 4. Estados

| Estado | Significado | UI |
|---|---|---|
| `available` | El NPC la ofrece; no aceptada | `!` en el NPC / panel |
| `active` | Aceptada y trackeada (solo 1) | Tracker + marcador |
| `pending` | Aceptada, no trackeada (máx. 5) | Panel |
| `completed` | Objetivos cumplidos; falta reclamar | `?` en el NPC / panel |
| `rewarded` | Recompensa entregada | Historial |
| `skipped` | Omitida (sin recompensa) | Historial |

Cambiar la activa desde el panel: la anterior pasa a `pending`; el progreso se conserva.

La onboarding no se puede abandonar; sí se puede omitir si la cuenta ya la completó en otro personaje (sin recompensa).

---

## 5. Dificultades y recompensas

| Dificultad | XP | Oro | Ítems | Techo de rareza |
|---|---|---|---|---|
| `Intro` | XP suficiente para nivel 2 | 0 | 10 `potion_health` | Common |
| `Fácil` | Bajo | Bajo | 1 | Common / Uncommon |
| `Normal` | Medio | Medio | 1 | Uncommon / Rare |
| `Difícil` | Alto | Alto | 1–2 | Rare / Epic |
| `Élite` | Muy alto | Alto | 2 | Epic |

Reglas:

* `Unique` no se entrega por misiones; sigue siendo exclusivo de jefes.
* El nivel del ítem = nivel del jugador al reclamar, con cap por `maxItemLevel` de la quest.
* Los valores exactos de XP/oro son config y se ajustan en balance; las bandas no se hardcodean.
* La dificultad se muestra en el panel y en el tracker con un color/label propio, sin confundirla con la rareza del ítem.
* **Recompensas de paso:** una quest puede otorgar una recompensa al completar un paso intermedio, no solo al final. La onboarding usa esto para la **elección de arma inicial**.
* **Onboarding:** dos recompensas: (1) elegir el arma inicial antes de entrar a la dungeon, en el Guía; (2) XP a nivel 2 + 10 `potion_health` al completar el piso 1 y reclamar. La elección de arma es de rareza Common, nivel 1 y ligada al personaje.

---

## 6. Claim e inventario

* La entrega es **atómica**: si no entra todo, no se entrega nada.
* Se simula el stacking: 10 pociones pueden entrar en una pila existente si queda capacidad.
* Si la mochila está llena, la quest queda en `completed`, el Guía mantiene `?` y el panel muestra “Mochila llena”.
* No hay entrega parcial ni pérdida de recompensa: el jugador libera espacio y reclama después.
* XP, oro e ítems se entregan juntos en el mismo claim; el claim es idempotente.
* Si la recompensa no tiene ítems, el claim no requiere espacio.
* **Recompensa de paso (arma inicial):** se valida contra el equipo/mochila; si el slot de arma está vacío, se equipa directo; si está ocupado, va a la mochila; si no hay espacio, se bloquea hasta liberar. La elección es única, idempotente y no se puede repetir.

---

## 7. NPC y aceptación

* Por ahora, **solo el Guía de la Helada** da misiones.
* El Guía está cerca del spawn, visible, con icono de quest y prompt simple; no tiene diálogo ramificado ni tienda.
* La onboarding arranca automáticamente; el paso 1 es hablar con el Guía y el paso 2 es elegir el arma inicial antes de entrar a la dungeon.
* **Prólogo (`TUTORIAL-02`):** la misión de cuenta `prologo_caida_vandrheim` se maneja con `prologueStage` y reutiliza el tracker/panel/marcadores. El Guía cierra primero el prólogo y recién después ofrece `intro_helada`; la onboarding no se auto-inicia antes de ese cierre.
* Misiones futuras: se aceptan en el NPC (`!`) y se entregan en el NPC (`?`).
* Si el jugador tiene 5 pendientes, no puede aceptar otra; el NPC lo explica.
* El panel puede mostrar disponibles, pero la aceptación se hace en el NPC.

---

## 8. Marcadores (sin minimapa)

El marcador principal es **world-space**:

* **Haz de luz** vertical en el objetivo, visible desde lejos.
* **Icono flotante** sobre el NPC, portal, loot o sala.
* **Flecha/anillo en el piso** para precisar el punto.
* Si el objetivo queda fuera de cámara, una **flecha discreta en el borde** ayuda; no es un minimapa.
* El icono/haz usa `AlwaysOnTop` solo para la quest activa y con distancia máxima; no debe tapar la UI ni el combate.

Por objetivo:

| Objetivo | Marcador |
|---|---|
| Hablar | Haz + icono sobre el NPC |
| Elegir arma | Haz + icono sobre el Guía |
| Entrar | Haz sobre el portal/puerta |
| Matar N | Haz sobre la dungeon/sala; dentro, sobre el pack más cercano; no cada enemigo |
| Recoger N | Haz sobre el loot; si aún no hay drop, sobre el enemigo/cofre que lo produce |
| Completar piso | Haz sobre la salida/sala del jefe |
| Entregar | Haz + `?` sobre el Guía |

Cross-place: en el hub el marcador apunta al portal; dentro de la dungeon, al objetivo.

---

## 9. UI

* **Tracker** (siempre visible): solo la misión activa; título, paso actual, progreso (`2/3`), distancia y dificultad. Click/tap abre el panel. Sin tarjetas secundarias.
* **Sin log separado:** el detalle de todas las misiones vive en el panel (Cuaderno).
* **Panel completo:** activas, pendientes, completadas y disponibles; detalle con dificultad, objetivos, recompensa y botón “Trackear”/“Reclamar”.
* **Selección de primera arma:** dentro del panel del Guía (paso 2), con 2 opciones por clase; no hay modal separado.
* **Acceso:** tecla `L` en PC; icono/botón “Misiones” en el micromenú; botón equivalente en móvil.
* **Notificaciones:** reutilizar el `NotificationFrame` centralizado existente, con sus títulos y colores de código; no crear estilos nuevos.
* **Estilo:** usar el kit de UI existente; no crear una ventana nueva con otro lenguaje visual.

---

## 10. Persistencia y cross-place

* Estado por personaje en el perfil: activa, trackeada, progreso por paso, completadas, recompensas.
* Migración segura: perfiles viejos arrancan sin quests; no se pierde nada.
* Rejoin: el estado se conserva; un personaje nuevo empieza limpio.
* Hub ↔ dungeon: el estado se lee del perfil en ambos places; el tracker y los marcadores se reconstruyen.
* Si el jugador sale a mitad de una run, el progreso de la quest se conserva; la run puede reiniciarse por R6b.
* Borrar personaje elimina su estado de misiones.

---

## 11. Party

* Progreso **personal**: los kills de otros miembros no cuentan.
* Para onboarding, se recomienda solo; si juega en party, debe participar del kill para recibir crédito.
* Misiones de party compartidas quedan para después; el sistema no las implementa ahora.

---

## 12. Analítica

Eventos mínimos:

* `quest_offered`, `quest_accepted`, `quest_step_completed`, `quest_completed`, `quest_claimed`, `quest_claim_blocked_full`, `quest_skipped`.
* Tiempo por paso y abandono por paso.
* Funnel de onboarding: inicio → hablar → entrar → 3 kills → loot → piso 1 → claim.

---

## 13. Retención (honesto)

La onboarding mejora la **primera sesión**, pero una sola quest no retiene sola. La retención sostenida necesita:

* Un **siguiente objetivo siempre visible**: piso 1 → piso 2 → … → Jotunn.
* Recompensas por hitos (loot, nivel, desbloqueos).
* Contenido nuevo con cadencia (expansiones y mini-actualizaciones).

El sistema debe soportar `nextQuestId` desde el día 1 para encadenar misiones sin rehacerlo. El contenido inicial es solo onboarding; las quests de piso/hito se agregan después.

---

## 14. Alcance MVP vs. futuro

**MVP (esta entrega):**

* Framework: config, estados, objetivos, NPC, tracker, panel, marcadores, recompensas, persistencia, analytics, debug.
* Dificultades `Intro` a `Élite`, con techo de rareza y claim atómico.
* Una sola quest: `intro_helada` (onboarding).
* Elección de arma inicial como recompensa de paso (2 opciones por clase; Common, nivel 1, ligada), dentro del panel del Guía.
* Un solo NPC: Guía de la Helada.
* Sin log separado: tracker solo activo y detalle en el panel.

**Futuro (no ahora):**

* Quests de piso/hito, ramas, diarias/semanales, repetibles, party compartida, diálogos ramificados, ítems de misión, prerrequisitos complejos, elección de recompensa.
* El schema queda preparado, pero no se implementa hasta que haya contenido.

---

## 15. Decisiones cerradas (PO 2026-10-27)

| Tema | Decisión |
|---|---|
| Activa | 1 |
| Pendientes | Máx. 5 aceptadas; tracker solo activa; panel todas |
| Log | Sin log separado; detalle en el panel |
| Onboarding | Auto-start; paso 1 hablar con el Guía; paso 2 elegir arma |
| Arma inicial | Elección dentro del panel del Guía; sin modal |
| Primera recompensa | Elegir arma inicial antes de la dungeon |
| Recompensa final onboarding | XP para nivel 2 + 10 `potion_health` |
| Dificultades | `Intro`, `Fácil`, `Normal`, `Difícil`, `Élite` |
| Claim | Atómico; si no entra todo, no se entrega |
| Acceso panel | `L` + micromenú + móvil |
| Marcadores | World-space (haz/icono/flecha), sin minimapa |
| Notificaciones | Reutilizar las existentes del juego |
| Progreso | Personal |
| NPC | Solo el Guía por ahora |
| Rareza | Techo por dificultad; sin `Unique` |
| Cross-place | Estado en perfil; hub/dungeon |

---

## 16. Riesgos

1. **Scope creep:** el framework puede crecer más de lo necesario; el MVP debe cerrarse con onboarding y no con contenido.
2. **Doble onboarding:** la quest y las tarjetas de TUTORIAL-01 pueden duplicarse; la quest reemplaza los pasos y el panel de Ayuda queda como consulta.
3. **Marcadores invasivos:** haz/icono demasiado brillante o visible a través de todo; limitar distancia y opacidad.
4. **Mochila llena:** fricción si el jugador no entiende por qué no puede reclamar; el panel debe explicarlo.
5. **Economía:** quests que den mejor equipo que las dungeons; el techo de rareza y el nivel de ítem lo evitan.
6. **Party:** el progreso personal puede frustrar en grupo; la onboarding está pensada para jugar solo.
7. **Elección de arma:** el Clérigo solo tiene `wand_white` como arma de afinidad; la segunda opción debe marcarse “Experimental” o requerir un template nuevo. Evitar trampas: mostrar recomendación, stats y playstyle.
8. **Persistencia:** migración de perfiles y cross-place; probar rejoin y teleport.

---

## 17. Historial

| Fecha | Cambio |
|---|---|
| 2026-10-27 | Diseño aprobado: 1 activa, 5 pendientes, tracker + log 3 + panel, marcadores world-space sin minimapa, dificultades con techo de rareza, claim atómico con validación de mochila, Guía como único NPC, progreso personal y onboarding con XP a nivel 2 + 10 pociones. |
| 2026-10-27 | **Cambio PO:** la primera recompensa de la onboarding es elegir el arma inicial antes de entrar a la dungeon (recompensa de paso); la recompensa final (XP nivel 2 + 10 pociones) se mantiene. |
| 2026-10-31 | **Decisiones finales de UI:** tracker solo con la misión activa; sin quest log separado; el detalle va al Cuaderno; la elección de arma se hace dentro del panel del Guía (sin modal); las notificaciones reutilizan el sistema existente. Paneles 2, 4 y 4b descartados. |
| 2026-11-04 | **Validado funcionalmente por el PO:** tutorial, misiones y prólogo funcionan. Se documenta la secuencia prólogo → creación → Guía → onboarding y que la onboarding no se auto-inicia antes del cierre del prólogo. |
