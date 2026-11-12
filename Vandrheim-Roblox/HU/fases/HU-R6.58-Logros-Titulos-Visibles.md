# HU-R6.58: Logros y títulos visibles — estatus cosmético (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Progresión / Estatus / Retención
**Prioridad:** Alta — motivación de largo plazo y estatus social
**Estado:** Abierta — lista para RC
**Tipo:** Logros + títulos cosméticos (dev)
**Fase GDD:** Progresión / Social / UI
**Depende de:** R6.12 (nameplates), R6.31 (notificaciones), R6.57 (Endless), R6.59 (Codex), R6.60 (maestría), R6.61 (eventos), `DataService`, `UIService`
**Componentes observados:** perfil, nameplates, panel de personaje, notificaciones, eventos de combate/dungeon/quests/coleccionables
**No modifica:** daño, vida, XP, loot, economía, skills, talentos ni balance. Los títulos son **solo cosméticos**.

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** desbloquear logros y mostrar un título visible,
**para** demostrar lo que hice y tener metas de largo plazo que no dependan solo de loot.

**Como** equipo,
**quiero** un sistema de logros y títulos server-authoritative, sin poder,
**para** agregar estatus y retención sin romper el balance ni la economía.

---

### Descripción / Contexto

Vandrheim necesita metas que no sean “subir 1 nivel más”. Esta HU agrega:

* Logros desbloqueables por hitos de juego.
* Títulos cosméticos; uno activo por personaje.
* Título visible bajo el nombre para otros jugadores.
* Panel de logros/títulos con progreso y recompensas.
* Notificaciones al desbloquear.
* Sin stats, sin daño extra, sin ventajas de combate.

**Criterio de hecho global:** los logros se desbloquean una vez por personaje, el jugador puede elegir un título desbloqueado y otros jugadores lo ven en el nameplate; el título no otorga ningún stat ni ventaja y el estado persiste entre sesiones.

---

### Especificaciones Técnicas / Contratos

#### 1. Catálogo inicial de logros

Configurables; valores iniciales:

| Logro | Condición | Título |
|---|---|---|
| Primer Jotunn | Derrotar a Jotunn una vez | `Verdugo de Jotunn` |
| Cazador de la Helada | Matar 100 lobos/enemigos de la Helada | `Cazador de la Helada` |
| Sin cicatrices | Completar una run de 5 pisos sin morir | `Sin Cicatrices` |
| Veterano | Completar 10 runs de campaña | `Veterano de la Helada` |
| Oleada 20 | Alcanzar la oleada 20 en Endless | `Oleada 20` |
| Cartógrafo | Descubrir los 8 coleccionables de R6.53 | `Cartógrafo` |
| Minero | Picar 50 minerales en la Mina Helada | `Minero de Valgard` |
| Defensor | Completar 10 eventos de caravana/campamento | `Defensor de Valgard` |
| Maestro de clase | Nivel máximo de maestría cosmética | `Maestro de <Clase>` |
| Codex | Completar el 50 % del bestiario | `Erudito de la Helada` |

Los valores exactos son configurables y se ajustan en QA/balance de tiempo, no de poder.

#### 2. Datos y persistencia

* `profile.achievements`: set/diccionario de IDs desbloqueados con fecha.
* `profile.achievementProgress`: contadores necesarios.
* `profile.activeTitle`: ID del título equipado o vacío.
* Migración con defaults `{}`/`""`; no borrar datos; actualizar `Schemas.PerfilPersistencia`/`DATA_SCHEMA`.
* Un logro se desbloquea una sola vez por personaje; no se puede reclamar dos veces.
* El título activo se guarda y se replica a los nameplates.
* Si el guardado falla, no perder el progreso local ya confirmado; reintentar de forma segura.

#### 3. Desbloqueo y notificación

* El servidor evalúa condiciones a partir de eventos existentes (muerte de jefe, fin de run, kill, quest, coleccionable, minería, evento, maestría).
* Al cumplir:
  * marcar el logro,
  * desbloquear el título,
  * enviar notificación existente (“Logro desbloqueado: ...”, “Título: ...”),
  * reproducir SFX/VFX de R6.54 si está disponible.
* Sin popup que bloquee combate; notificación no invasiva.
* Si se desbloquean varios a la vez, agrupar o encolar sin spam.

#### 4. Títulos visibles

* Un título activo por personaje; el jugador puede cambiarlo desde el panel.
* Mostrar bajo el nombre en el nameplate de otros jugadores; el jugador local lo ve en su panel.
* Si el nameplate no tiene espacio, mostrar el título en una segunda línea con tamaño menor; no tapar la barra de vida.
* Sin título para enemigos/NPCs; solo jugadores.
* El título no cambia color de nombre, no da prioridad, no otorga stats.
* En móvil, el título debe ser legible sin agrandar demasiado el nameplate.

#### 5. UI

* Nueva pestaña/sección “Logros y títulos” en el panel de personaje existente; no crear una ventana separada si se puede integrar.
* Lista de logros:
  * icono,
  * nombre,
  * descripción,
  * progreso (`3/100`),
  * estado bloqueado/desbloqueado,
  * título asociado.
* Título activo: selector con “Equipar”/“Quitar”.
* Ordenar por: en progreso, desbloqueados, completados.
* Sin HUD permanente ni iconos en el mundo.

#### 6. Seguridad y anti-abuso

* El cliente no desbloquea logros ni equipa títulos no obtenidos.
* El servidor valida condiciones y propiedad del título.
* No se pueden duplicar títulos ni reclamar recompensas dos veces.
* No hay recompensas de poder; no afecta economía ni combate.
* No usar logros para farmear oro/XP si se agregan recompensas; en esta HU son solo cosméticos.

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Desbloquear un logro

* **GIVEN** un jugador que cumple una condición
* **WHEN** el servidor la valida
* **THEN** el logro queda desbloqueado una sola vez
* **AND** recibe una notificación
* **AND** el título asociado queda disponible

#### Escenario 2: Equipar título

* **GIVEN** un título desbloqueado
* **WHEN** el jugador lo equipa
* **THEN** se guarda como título activo
* **AND** otros jugadores lo ven bajo su nombre
* **AND** no cambia ningún stat

#### Escenario 3: Título bloqueado

* **GIVEN** un título no desbloqueado
* **WHEN** el jugador intenta equiparlo
* **THEN** el servidor lo rechaza
* **AND** no se modifica el perfil

#### Escenario 4: Persistencia

* **GIVEN** un título equipado
* **WHEN** el jugador rejoin o cambia de personaje
* **THEN** el título se conserva por personaje
* **AND** el nameplate lo muestra correctamente

#### Escenario 5: Sin poder

* **GIVEN** cualquier título equipado
* **WHEN** se compara daño, vida, XP, loot y economía
* **THEN** no hay ninguna diferencia
* **AND** el título es solo visual

#### Escenario 6: UI y móvil

* **GIVEN** el panel de logros
* **WHEN** se abre en PC y móvil
* **THEN** la lista, el progreso y el selector son legibles
* **AND** no tapan otros paneles ni el juego

#### Escenario 7: Regresión

* **GIVEN** logros/títulos activos
* **WHEN** se juega dungeon, party, vendors y quests
* **THEN** todo sigue funcionando
* **AND** no hay errores rojos

---

### Comportamiento Visual / UI-UX

* Los logros deben sentirse como hitos, no como una lista infinita de tareas.
* El título visible debe ser legible y discreto; no tapar nombre, vida ni nameplates enemigos.
* La notificación debe celebrar sin interrumpir el combate.
* Sin colores de poder ni iconos que sugieran ventajas.

---

### Alcance

#### Incluye

* Catálogo inicial de logros y títulos.
* Persistencia por personaje.
* Desbloqueo server-authoritative y notificaciones.
* Título visible bajo el nombre.
* Panel de logros/títulos.
* QA PC/móvil.

#### No incluye

* Stats, daño, vida, XP, oro o loot por logros.
* Logros de PvP, clases nuevas o contenido futuro no implementado.
* Títulos animados, 3D o efectos costosos.
* Leaderboard; eso vive en R6.57.
* Recompensas pagas.

---

### Definition of Done (DoD)

* [ ] Catálogo de logros/títulos configurable.
* [ ] Progreso y desbloqueo server-authoritative.
* [ ] Título activo persistente y visible.
* [ ] Panel de logros/títulos en PC/móvil.
* [ ] Notificaciones y feedback.
* [ ] Cero cambios de stats/economía.
* [ ] QA de rejoin, cambio de personaje y nameplate.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).

---

### Decisiones por defecto

| Tema | Default |
|---|---|
| Títulos | 1 activo por personaje |
| Visibilidad | Bajo el nombre para otros; panel para el dueño |
| Persistencia | `profile.achievements` + `activeTitle` |
| Desbloqueo | Server-authoritative, una vez |
| Recompensas | Solo título/cosmético |
| UI | Pestaña en panel de personaje |
| Stats | Cero |
| Notificación | Sistema existente + SFX de R6.54 |

---

### Estimación (orientativa)

3–4 sesiones del dev: catálogo, datos, evaluación de eventos, UI, nameplate y QA.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-11-12 | Creación de HU-R6.58: logros y títulos visibles, persistentes y cosméticos, con panel, notificaciones y nameplate; sin stats ni ventajas. |
