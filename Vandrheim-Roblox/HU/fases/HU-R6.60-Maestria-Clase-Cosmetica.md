# HU-R6.60: Maestría de clase — progresión cosmética (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Progresión / Cosmética / Retención
**Prioridad:** Media — meta de largo plazo para jugar la clase
**Estado:** Abierta — lista para RC
**Tipo:** Progresión cosmética por clase (dev)
**Fase GDD:** Progresión / Social / UI
**Depende de:** R6.58 (títulos), `DataService`, `UIService`, `NotificationService`, HU-ESTETICA-53 (cosméticos; placeholders permitidos)
**Componentes observados:** perfil, clase activa, combate, dungeon, diaria, Endless, panel de personaje, títulos
**No modifica:** daño, vida, XP de nivel, loot, economía, skills, talentos, cooldowns ni balance. **La maestría solo da cosméticos.**

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** subir la maestría de mi clase jugando con ella y desbloquear títulos/cosméticos,
**para** demostrar dedicación a mi clase sin que eso me haga más fuerte que otros.

**Como** equipo,
**quiero** una progresión paralela y cosmética por clase,
**para** dar una meta de largo plazo sin introducir power creep ni desbalancear el combate.

---

### Descripción / Contexto

El nivel de personaje llega a 20 y se termina; la maestría de clase agrega una meta posterior **solo cosmética**. Cada clase (Paladín, Cazador, Clérigo) gana maestría por jugar:

* Matar enemigos/jefes.
* Completar runs de campaña.
* Completar diarias.
* Alcanzar oleadas en el Endless.
* Participar en eventos de mundo.

La maestría desbloquea títulos y cosméticos de clase. **No otorga daño, vida, XP extra, oro, loot ni ventajas de combate.**

**Criterio de hecho global:** el jugador acumula maestría por clase, sube niveles de maestría, desbloquea recompensas cosméticas y las equipa; el sistema no altera ningún stat ni economía y el progreso persiste por clase y personaje.

---

### Especificaciones Técnicas / Contratos

#### 1. Progreso

* Una barra de maestría por **clase** (no por spec) en cada personaje.
* Niveles 1–10; XP acumulada de actividades:
  * kill normal: 1,
  * élite/mini-jefe: 5,
  * jefe: 20,
  * run de campaña completada: 40,
  * diaria completada: 15,
  * oleada 10/20/30 del Endless: 10/25/50,
  * evento de mundo completado: 20.
* Valores configurables; el objetivo es tiempo, no poder.
* No hay límite diario que obligue a grindear; se puede jugar cualquier actividad.
* La maestría se gana para la clase del personaje activo.

#### 2. Recompensas

| Nivel | Recompensa |
|---:|---|
| 2 | Emblema de clase (cosmético) |
| 4 | Título “Veterano de <Clase>” |
| 6 | Variante cosmética de arma/armadura de clase |
| 8 | Aura/estandarte de clase |
| 10 | Título “Maestro de <Clase>” + cosmético final |

* Todos los cosméticos son visuales; **cero stats**.
* Las recompensas se reclaman una vez por personaje/clase.
* Si un cosmético requiere modelo nuevo, se entrega por HU-ESTETICA-53 o placeholder; no bloquear el sistema.
* No se pueden equipar cosméticos de otra clase.

#### 3. Datos y persistencia

* `profile.classMastery[classId] = { xp, level, claimed }`.
* Migración con default `{}`; no borrar datos; actualizar `Schemas.PerfilPersistencia`/`DATA_SCHEMA`.
* El servidor suma XP y valida hitos; el cliente solo muestra.
* Idempotente: no duplicar XP por el mismo evento; usar IDs de evento o contadores de servidor.
* Persistencia por personaje y clase.

#### 4. UI

* Sección “Maestría” en el panel de personaje existente:
  * clase,
  * nivel de maestría,
  * barra de XP,
  * siguiente recompensa,
  * lista de recompensas desbloqueadas.
* Botón “Reclamar” cuando corresponde; no reclamar dos veces.
* Mostrar el título/emblema equipado.
* PC/móvil; sin HUD permanente.
* Notificación al subir de nivel de maestría.

#### 5. Integración

* Escuchar eventos reales de kill, fin de run, diaria, oleada y evento.
* No otorgar maestría por acciones en el Hub sin riesgo (por ejemplo, matar dummies) si se puede explotar; configurar qué enemigos cuentan.
* No otorgar maestría por PvP (no existe en esta fase).
* La maestría no reemplaza XP de nivel ni talentos.

#### 6. Seguridad y anti-abuso

* El cliente no puede sumar maestría ni reclamar recompensas.
* Validar clase activa, evento y límites de repetición.
* No se puede farmear con spawns infinitos o dummies; excluirlos.
* Sin ventajas de poder; no afecta economía ni combate.

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Ganar maestría

* **GIVEN** un personaje jugando con su clase
* **WHEN** mata enemigos o completa actividades válidas
* **THEN** su maestría de clase aumenta
* **AND** la barra se actualiza
* **AND** no cambia ningún stat

#### Escenario 2: Subir de nivel de maestría

* **GIVEN** XP suficiente
* **WHEN** alcanza un nivel de maestría
* **THEN** se desbloquea la recompensa correspondiente
* **AND** recibe una notificación
* **AND** puede reclamarla en el panel

#### Escenario 3: Recompensa cosmética

* **GIVEN** una recompensa desbloqueada
* **WHEN** el jugador la reclama y equipa
* **THEN** se ve el título/emblema/aura
* **AND** no hay diferencia de daño, vida, XP, oro o loot

#### Escenario 4: Clase incorrecta

* **GIVEN** un cosmético de otra clase
* **WHEN** el jugador intenta equiparlo
* **THEN** se bloquea
* **AND** no se modifica el personaje

#### Escenario 5: Persistencia

* **GIVEN** maestría y recompensas obtenidas
* **WHEN** el jugador rejoin o cambia de personaje
* **THEN** el progreso se conserva por clase
* **AND** no se duplican reclamos

#### Escenario 6: Anti-abuso

* **GIVEN** un dummy o spawn no válido
* **WHEN** el jugador lo mata repetidamente
* **THEN** no gana maestría
* **AND** no puede explotar el sistema

#### Escenario 7: Regresión

* **GIVEN** la maestría activa
* **WHEN** se juega dungeon, Endless, diarias y eventos
* **THEN** el gameplay sigue funcionando
* **AND** no hay errores rojos

---

### Comportamiento Visual / UI-UX

* La maestría debe celebrar la identidad de clase, no el poder.
* Las recompensas deben verse codiciables pero cosméticas.
* La barra y el siguiente hito deben ser claros y no invasivos.
* Sin ventajas ocultas ni números que sugieran daño.

---

### Alcance

#### Incluye

* XP de maestría por clase y niveles 1–10.
* Recompensas cosméticas y títulos.
* Persistencia por personaje/clase.
* Panel de maestría y notificaciones.
* Anti-abuso y QA.

#### No incluye

* Stats, daño, vida, XP extra, oro, loot o cooldowns.
* Talentos, skills, puntos de maestría ni poder.
* Maestría por spec.
* PvP o clases nuevas.
* Arte final si EST-53 no está listo; se usan placeholders.

---

### Definition of Done (DoD)

* [ ] XP de maestría por clase y niveles 1–10.
* [ ] Recompensas solo cosméticas; cero stats.
* [ ] Persistencia por personaje/clase.
* [ ] Panel y notificaciones.
* [ ] Anti-abuso de dummies/spawns.
* [ ] QA PC/móvil y rejoin.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).

---

### Decisiones por defecto

| Tema | Default |
|---|---|
| Alcance | Por clase, no por spec |
| Niveles | 1–10 |
| Poder | Cero; solo cosmético |
| Recompensas | Emblema, títulos, variantes, aura |
| Persistencia | `profile.classMastery` por personaje |
| XP | Actividades reales; dummies excluidos |
| UI | Sección en panel de personaje |
| Arte | EST-53 o placeholders |

---

### Estimación (orientativa)

2–3 sesiones del dev: datos, XP, recompensas, UI, anti-abuso y QA.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-11-12 | Creación de HU-R6.60: maestría de clase cosmética por niveles, con recompensas visuales/títulos y cero ventajas de combate o economía; confirmado por PO que no da daño extra. |
