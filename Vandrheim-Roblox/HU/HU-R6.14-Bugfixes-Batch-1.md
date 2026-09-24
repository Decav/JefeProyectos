# HU-R6.14: Bugfixes batch 1 — interacción móvil, tamaño de UI móvil, spawn de dungeon y targeting del trol

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R6.x / Bugfixes (reportados por PO 2026-09-22)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Bugfix (dev) — 4 bugs en una HU
**Fase GDD:** R6.14 (no cambia reglas de juego)
**Depende de:** HU-R5 (NPCs/ProximityPrompt), HU-R6.10 (menú), HU-ESTETICA-19/20 (HUD de combate), HU-R6a/R6b (dungeon), HU-R3.2/R3.3 (targeting), HU-PUBLICAR-02 (dungeon cross-place)
**Componentes observados:** `Workspace.Hub` (NPCs/portal), `StarterGui.HUD`, `DungeonService`/`FloorService`, `TargetingSystem`/`TargetIndicatorConfig`, modelos de mini-bosses

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que se arreglen los bugs reportados que me impiden jugar bien: interactuar en móvil, una UI móvil que no tape la pantalla, no caerme al vacío en la dungeon y poder targetear al trol con click,
**para** que el juego sea jugable y completo en PC y móvil.

---

### **Descripción del Requerimiento / Contexto**

Batch de **4 bugs** reportados por el PO (2026-09-22). Cada bug tiene su sección, criterios y verificación; se implementan juntos en un solo RC.

**Criterio de hecho global:** los 4 bugs corregidos y verificados sin regresiones (PC y móvil, publicado).

---

### **Especificaciones Técnicas / Contratos de API**

#### **Bug 1 — Móvil: no se puede interactuar con NPCs, portal ni diálogos (tecla E inexistente en touch)**

* Los `ProximityPrompt` (vendors, trainer, portal) deben mostrar el **botón táctil** en móvil; la interacción real sigue server-side (remotes R5/R6b).
* **Ningún diálogo depende de teclas:** todas las acciones de las ventanas/confirmaciones son **botones tappables**; en PC `E` queda como atajo adicional, nunca requisito.
* Sin duplicar botones con el micromenú ni romper el joystick.

#### **Bug 2 — Móvil: micromenú vertical, player frame y target frame tapan la pantalla**

* **Micromenú vertical compacto** en móvil (solo iconos, ≤ ~30% del ancho, safe area).
* **Player/target frames reducidos** en touch (~70–80% del tamaño PC) manteniendo legibilidad (HP/MP/textos); condicional por dispositivo (`TouchEnabled`), **PC sin cambios**.
* Botones táctiles (BOLSA/EQUIPO/MENÚ) nunca por debajo del mínimo táctil recomendado.

#### **Bug 3 — Dungeon: al vencer un jefe de piso, el jugador/enemigos se caen al vacío (la dungeon carga después)**

* **Gate de piso listo (server):** `FloorService` termina de generar el piso **antes** de teleportar al jugador (aplica a `JoinRun`/piso 1 y a cada piso post-jefe).
* Los **enemigos se generan después** y sobre **suelo válido** (validación/reposicionamiento/saltar spawn inválido; nunca al vacío).
* El criterio de avance (todos los muertos) no puede quedar bloqueado por enemigos caídos.

#### **Bug 4 — Targeting: el miniboss trol no se targetea con click (solo con TAB)**

* **Diagnóstico:** click-targeting raycastea sobre partes; si el modelo `troll_mboss` tiene hitbox chica o partes con `CanQuery=false`, el click falla.
* **Fix (una o ambas):**
  * a) Hitbox del modelo: partes del cuerpo con `CanQuery=true` y tamaño coherente (ajuste de partes/hitbox, no creación de modelos).
  * b) **Fallback por proximidad** en el click: si el raycast no acierta, targetear el enemigo más cercano al crosshair (radio pequeño).
* Verificar click en **todos** los mini-bosses/boss (troll, gólem, espectro, señor, Guardián de la Escarcha); TAB intacto.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Interacción móvil**

* **GIVEN** un jugador en móvil
* **WHEN** se acerca a NPCs/portal y abre diálogos
* **THEN** todo se opera con toque (botón táctil + botones tappables), sin depender de teclas
* **AND** en PC `E` y mouse siguen funcionando

#### **Escenario 2: UI móvil compacta**

* **GIVEN** el HUD en móvil
* **WHEN** se revisa
* **THEN** el micromenú no tapa (≤ ~30% ancho) y player/target frames son compactos y legibles
* **AND** en PC el HUD no cambia y no hay superposiciones ni botones intocables

#### **Escenario 3: Spawn de dungeon**

* **GIVEN** la run en la dungeon
* **WHEN** se vence a un jefe de piso (y al iniciar la run)
* **THEN** el piso está generado antes de spawnear jugador y enemigos; nadie cae al vacío
* **AND** el piso siempre se puede completar (solo y party)

#### **Escenario 4: Targeting del trol**

* **GIVEN** el Trol de escarcha (y demás bosses)
* **WHEN** se hace click sobre él
* **THEN** se targetea con click (y con TAB sigue funcionando)
* **AND** no hay regresión en mobs/élites/party ni en el indicador R3.3

#### **Escenario 5: Regresión general**

* **GIVEN** los 4 fixes aplicados
* **WHEN** se juega el flujo completo (crear PJ → pueblo → portal → dungeon → boss → volver), en PC y móvil, publicado
* **THEN** no hay errores rojos y nada del juego existente se rompe

---

### **Alcance**

#### Incluye

* Botón táctil de ProximityPrompt (NPCs/portal) y diálogos tappables.
* Micromenú y frames compactos en móvil (PC intacto).
* Gate de piso listo + spawns sobre suelo válido (dungeon).
* Fix de click-targeting del trol (+ fallback por proximidad) y verificación de todos los bosses.

#### No incluye

* Cambios de reglas de juego, balance ni mecánicas.
* Modelos nuevos (si el trol requiere rediseño visual, es del diseñador — se coordina aparte).
* Otros bugs futuros (cada batch nuevo será su propia HU).

---

### **Definition of Done (DoD)**

* [ ] Móvil: interacción con NPCs/portal/diálogos con toque; PC con `E`/mouse intactos.
* [ ] Móvil: micromenú y frames compactos; PC sin cambios.
* [ ] Dungeon: piso generado antes del spawn (pisos 1–5); sin caídas al vacío; piso completable.
* [ ] Targeting: trol y todos los bosses clickeables; TAB intacto; sin regresión.
* [ ] Sin errores rojos en el flujo completo (PC y móvil, publicado).
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Al cerrar: PROJECT_ARCHITECTURE, DATA_SCHEMA y registro HU/RC actualizados; nota en GDD después de QA.

---

### **Decisiones por defecto R6.14**

| Bug | Default |
|-----|---------|
| Interacción móvil | ProximityPrompt táctil + diálogos tappables; `E` solo atajo en PC |
| Tamaño móvil | Micromenú solo iconos ≤30% ancho; frames ~70–80% (touch); PC intacto |
| Spawn dungeon | Gate "piso listo" server; spawns sobre suelo válido |
| Targeting trol | Hitbox `CanQuery` + fallback por proximidad en click |

---

### **Estimación (orientativa)**

3–4 sesiones del dev (los 4 bugs + regresión PC/móvil publicada).

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-R6.14 (batch 1 de bugs, unifica R6.14–R6.17 individuales): interacción móvil (E/touch), UI móvil compacta, spawn de dungeon (piso listo) y targeting del trol (click/TAB) — 4 bugs en un solo RC |