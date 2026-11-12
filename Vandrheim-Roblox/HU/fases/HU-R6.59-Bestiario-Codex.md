# HU-R6.59: Bestiario y Codex — enemigos, lore y lugares (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Colección / Progresión / Lore
**Prioridad:** Media — meta de largo plazo y razón para explorar
**Estado:** Abierta — lista para RC
**Tipo:** Codex/colección + UI (dev)
**Fase GDD:** Progresión / Mundo / UI
**Depende de:** R6.53 (coleccionables/POIs), R6.58 (títulos), `EnemyConfig`, `DataService`, `UIService`, `NotificationService`
**Componentes observados:** enemigos/jefes existentes, coleccionables `worldCollectibles`, POIs, perfil, panel de personaje
**No modifica:** stats, daño, loot, economía, spawns, quests ni balance. El Codex es informativo y cosmético.

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** un bestiario y un codex con enemigos, lore y lugares descubiertos,
**para** tener una colección que completar y aprender sobre el mundo sin depender solo del loot.

**Como** equipo,
**quiero** reutilizar los enemigos y coleccionables existentes en una colección persistente,
**para** agregar profundidad y retención sin crear contenido de combate nuevo.

---

### Descripción / Contexto

El juego tiene enemigos, jefes, POIs y coleccionables de R6.53, pero no hay un lugar que los unifique. Esta HU agrega el **Codex de Vandrheim**:

* **Bestiario:** enemigos y jefes existentes; se desbloquean al matarlos.
* **Lore:** los 8 coleccionables de R6.53.
* **Lugares:** los 6 POIs de R6.53 y la Mina Helada de R6.55.
* Progreso por categoría, entradas bloqueadas/descubiertas y recompensas cosméticas.
* Sin stats, sin debuffs/buffs, sin loot nuevo.

**Criterio de hecho global:** el jugador puede abrir el Codex, ver entradas bloqueadas y descubiertas, desbloquear enemigos/jefes al matarlos, lore al recoger coleccionables y lugares al visitarlos; el progreso persiste por personaje y las recompensas son solo títulos/cosméticos.

---

### Especificaciones Técnicas / Contratos

#### 1. Categorías y entradas

**Bestiario:**

* Todos los enemigos normales, élites, mini-jefes y jefes existentes en `EnemyConfig`.
* Entrada por template, no por spawn.
* Se desbloquea al matar al enemigo al menos una vez; el contador de kills puede mostrarse.
* Contenido: nombre, imagen/icono existente, descripción corta y hábitat; sin revelar fórmulas internas.

**Lore:**

* Las 8 entradas de R6.53 (`frost_rune_01..04`, `lost_page_01..04`).
* Se desbloquean al reclamar el coleccionable; muestran el texto de lore ya usado en la notificación.
* Sin nuevos coleccionables.

**Lugares:**

* Los 6 POIs de R6.53 y la entrada de la Mina Helada de R6.55.
* Se desbloquean al entrar en su radio de descubrimiento.
* Contenido: nombre, descripción y zona; sin minimapa ni fast travel nuevo.

#### 2. Datos y persistencia

* `profile.codex` por personaje:
  * `enemies` (set de IDs + kills),
  * `lore` (set de IDs),
  * `places` (set de IDs).
* Migración con default `{}`; no borrar datos; actualizar `Schemas.PerfilPersistencia`/`DATA_SCHEMA`.
* Un enemigo/lugar/lore se descubre una vez; los kills pueden seguir contando.
* El servidor evalúa los eventos y actualiza el perfil; el cliente solo muestra.
* Si el guardado falla, no perder el progreso ya confirmado; reintentar de forma segura.

#### 3. Progreso y recompensas

* Progreso por categoría: descubiertos / total.
* Hitos configurables:
  * 50 % del bestiario: título `Erudito de la Helada` (R6.58).
  * 100 % del lore: título `Cartógrafo` o cosmético.
  * 100 % de lugares: título `Explorador de Valgard`.
  * 100 % del Codex: cosmético/título especial.
* Sin oro, XP, stats ni loot por completar; solo estatus cosmético.
* No se puede reclamar dos veces; si R6.58 no está implementado, dejar los títulos como pendientes y no bloquear.

#### 4. UI

* Nueva pestaña “Codex” en el panel de personaje existente; no crear una ventana separada si se puede integrar.
* Tres subsecciones: Bestiario, Lore, Lugares.
* Cada entrada:
  * icono/imagen existente,
  * nombre,
  * estado bloqueado/descubierto,
  * descripción,
  * contador de kills si aplica.
* Filtros: todos, descubiertos, bloqueados.
* Barra de progreso por categoría y total.
* PC/móvil; scroll táctil; sin HUD permanente.

#### 5. Integración con sistemas existentes

* Escuchar muerte de enemigo/jefe desde el servicio de combate existente.
* Escuchar reclamo de coleccionable de R6.53.
* Escuchar entrada a POI/ Mina Helada desde `ZoneService` o trigger existente.
* Notificación breve al descubrir una entrada nueva; no spam si se descubren varias.
* Sin nuevas stats ni debuffs por conocer enemigos.

#### 6. Seguridad y anti-abuso

* El cliente no puede desbloquear entradas ni modificar kills.
* El servidor valida que el enemigo/POI/coleccionable exista y que el jugador haya participado.
* No se puede farmear kills falsos; usar eventos reales de muerte.
* No hay recompensas de poder; no afecta economía.

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Descubrir un enemigo

* **GIVEN** un enemigo existente
* **WHEN** el jugador lo mata por primera vez
* **THEN** su entrada del bestiario se desbloquea
* **AND** se incrementa el contador de kills
* **AND** aparece una notificación breve

#### Escenario 2: Descubrir lore

* **GIVEN** un coleccionable de R6.53
* **WHEN** el jugador lo reclama
* **THEN** su entrada de lore se desbloquea
* **AND** se puede leer en el Codex

#### Escenario 3: Descubrir un lugar

* **GIVEN** un POI o la Mina Helada
* **WHEN** el jugador entra en su radio
* **THEN** su entrada de lugar se desbloquea
* **AND** no se otorga loot ni stats

#### Escenario 4: Progreso y recompensa

* **GIVEN** el jugador alcanza un hito del Codex
* **WHEN** el servidor valida el progreso
* **THEN** se desbloquea el título/cosmético correspondiente
* **AND** no se otorga poder

#### Escenario 5: Persistencia

* **GIVEN** entradas descubiertas
* **WHEN** el jugador rejoin o cambia de personaje
* **THEN** el Codex conserva el progreso por personaje
* **AND** no se duplican entradas

#### Escenario 6: UI

* **GIVEN** el panel del Codex
* **WHEN** se abre en PC y móvil
* **THEN** las tres categorías, filtros y descripciones son legibles
* **AND** no tapan otros paneles

#### Escenario 7: Regresión

* **GIVEN** el Codex activo
* **WHEN** se juega dungeon, mina, eventos, vendors y quests
* **THEN** todo sigue funcionando
* **AND** no hay errores rojos

---

### Comportamiento Visual / UI-UX

* El Codex debe sentirse como una colección del mundo, no como una tabla de datos.
* Las entradas bloqueadas deben dar curiosidad, no frustración.
* Los iconos/imágenes existentes deben mantener el estilo; no crear arte nuevo en esta HU.
* Sin minimapa ni marcadores permanentes; el descubrimiento sigue siendo parte del juego.

---

### Alcance

#### Incluye

* Bestiario de enemigos/jefes existentes.
* Lore de los 8 coleccionables de R6.53.
* Lugares de R6.53 y Mina Helada.
* Progreso persistente por personaje.
* Panel Codex con filtros.
* Hitos con títulos/cosméticos.
* QA PC/móvil.

#### No incluye

* Enemigos, jefes, POIs, coleccionables o lore nuevos.
* Stats, debuffs, buffs, loot o economía.
* Minimapa, map markers o fast travel.
* Modelos/iconos nuevos; usar assets existentes.
* Recompensas pagas.

---

### Definition of Done (DoD)

* [ ] Categorías Bestiario/Lore/Lugares con entradas existentes.
* [ ] Desbloqueo server-authoritative por muerte, coleccionable y visita.
* [ ] Persistencia por personaje sin duplicados.
* [ ] Panel Codex con filtros, progreso y descripciones.
* [ ] Hitos con títulos/cosméticos, sin poder.
* [ ] QA de rejoin, cambio de personaje y móvil.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).

---

### Decisiones por defecto

| Tema | Default |
|---|---|
| Categorías | Bestiario, Lore, Lugares |
| Bestiario | Todos los enemigos/jefes existentes |
| Lore | 8 coleccionables de R6.53 |
| Lugares | 6 POIs + Mina Helada |
| Persistencia | `profile.codex` por personaje |
| Recompensas | Títulos/cosméticos; sin stats |
| UI | Pestaña en panel de personaje |
| Filtros | Todos / descubiertos / bloqueados |
| Notificación | Sistema existente |

---

### Estimación (orientativa)

3–4 sesiones del dev: datos, hooks de eventos, UI, hitos y QA.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-11-12 | Creación de HU-R6.59: Codex con bestiario de enemigos existentes, lore de coleccionables de R6.53 y lugares/POIs; progreso persistente y recompensas solo cosméticas. |
