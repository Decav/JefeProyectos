# HU-R6.63: Cazador a 45 studs, aggro con persecución y rango enemigo máximo 40 (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Combate / Cazador / IA enemiga
**Prioridad:** Alta — corrige el “poke gratis” y aumenta el rango de Puntería
**Estado:** Abierta — lista para RC
**Tipo:** Ajuste de combate/IA (dev)
**Fase GDD:** Combate / Clases / Enemigos
**Depende de:** HU-R6.40 (rangos previos de Cazador), HU-R6.19 (IA melee/ranged), HU-R6.41 (LOS), `SkillConfig`, config de ataque básico, `EnemyConfig`, `EnemyService`, `SKILLS_CATALOG`
**Componentes observados:** Cazador/Puntería, ataque básico de arco, `EnemyConfig` (rangos), `EnemyService` (aggro/chase), cursor/indicadores de rango, tooltips
**No modifica:** daño, cooldowns, coste de maná, crítico, stats, número de objetivos, set bonuses, habilidades de Asalto ni loot.

---

### Narrativa (INVEST)

**Como** jugador de Puntería,
**quiero** que mi arco y mis habilidades lleguen a 45 studs,
**para** tener una identidad ranged clara y sentir el alcance del Cazador.

**Como** equipo,
**quiero** que los enemigos persigan cuando reciben daño y que los ranged enemigos no superen 40 studs,
**para** que atacar a distancia tenga riesgo y no exista un “poke gratis” fuera del alcance enemigo.

---

### Descripción / Contexto

Hoy el Cazador de Puntería tiene rangos de 30 studs (y Disparo mortal 35), mientras que algunos enemigos pueden quedar fuera de alcance o no perseguir al recibir daño. Eso permite atacar sin riesgo y hace que el rango del Cazador se sienta corto.

Esta HU:

* Sube el ataque básico de arco y **todas las habilidades de Puntería** a **45 studs**.
* Hace que los enemigos atacados por el jugador lo **persigan** (aggro/chase), en lugar de quedarse quietos o dejar de atacar.
* Limita el rango de ataque de los enemigos ranged a **40 studs**; los que ya tenían menos se mantienen.

**Criterio de hecho global:** el Cazador de Puntería valida y comunica 45 studs en ataque básico y skills; los enemigos atacados lo persiguen; ningún enemigo ranged supera 40 studs de ataque; los enemigos ranged con menos rango conservan su valor; y no cambian daño, cooldown, maná ni stats.

---

### Especificaciones Técnicas / Contratos

#### 1. Rango del Cazador de Puntería

* Ataque básico de arco: **45 studs**.
* Habilidades de Puntería: **45 studs**.
* Lista a actualizar en `SkillConfig` y en la config del ataque básico:
  * `hunter_piercing_shot` (Disparo perforante),
  * `hunter_mm_venom` (Flecha venenosa),
  * `hunter_mm_trueshot` (Tiro certero),
  * `hunter_mm_chain` (Tiro en cadena; el objetivo inicial a 45; el secundario conserva su regla de cercanía),
  * `hunter_mm_death` (Disparo mortal).
* El servidor valida 45 studs con el mismo valor que la UI/cursor; el cliente no puede extenderlo.
* Actualizar `SKILLS_CATALOG`, tooltips y cualquier indicador de rango para que no contradigan el valor real.
* No cambiar daño, cooldown, coste de maná, crítico, número de objetivos ni bonuses.
* **Asalto melee no se convierte en ranged**: sus habilidades y ataque básico conservan su rango melee. Si el PO quiere llevar también las melee a 45, se hace en otra HU, porque rompería el rol de Asalto.

#### 2. Aggro y persecución al recibir daño

* Cuando un jugador daña a un enemigo, ese enemigo debe:
  * fijar al atacante como objetivo de aggro (salvo taunt/aggro válido existente),
  * perseguir al atacante si está fuera de su rango de ataque,
  * mantener el aggro durante X segundos desde el último daño (default 8 s, configurable),
  * usar pathfinding/movimiento existente para acercarse; no quedarse quieto.
* Aplica a enemigos melee y ranged.
* Los enemigos ranged:
  * se acercan hasta entrar en su rango máximo de 40,
  * no retroceden indefinidamente ni se quedan fuera de alcance,
  * conservan el retroceso acotado de R6.19 cuando el jugador se acerca demasiado.
* Si el jugador huye fuera del leash de la zona, el enemigo vuelve a su spawn; no persigue por todo el mapa.
* Si el enemigo no puede alcanzar al jugador por geometría, se reposiciona para ganar LOS; no se queda atacando a través de paredes.
* El aggro no se activa por curar a un aliado en esta HU; solo por daño recibido del jugador.
* No agregar aggro a NPCs, vendors ni enemigos pasivos.

#### 3. Rango máximo de enemigos ranged

* Revisar `EnemyConfig` de todos los enemigos ranged.
* Si `attackRange > 40`, bajarlo a **40 studs**.
* Si `attackRange <= 40`, **no modificarlo**.
* No cambiar el rango de los enemigos melee.
* Actualizar cualquier telegraph, tooltip o indicador que muestre el rango enemigo.
* No cambiar daño, cadencia, velocidad de proyectil, cooldown ni IA de habilidades; solo el alcance.

#### 4. Interacción esperada

* El Cazador puede iniciar el ataque a 45 studs.
* El enemigo atacado (ranged máximo 40 o melee) debe acercarse y responder; no queda “pokeado” sin reacción.
* Si el Cazador mantiene distancia y el enemigo es ranged con 40, el enemigo avanza 5 studs para contestar.
* Si el Cazador corre fuera del leash, el enemigo vuelve; no se puede kitar indefinidamente.
* La línea de visión (R6.41) se mantiene: no se ataca a través de paredes.
* No se puede aprovechar el rango para atacar sin que el enemigo entre en aggro.

#### 5. UI, feedback y autoridad

* Tooltips de skills y ataque básico deben mostrar 45.
* El indicador de objetivo/rango del cliente debe coincidir con la validación server-side.
* Los enemigos deben mostrar feedback de aggro (mirar/avanzar) sin agregar UI nueva.
* El servidor decide daño, rango, aggro y chase; el cliente no puede forzar target ni extender alcance.
* Sin nuevos SFX; usar los existentes si corresponde.

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Ataque básico a 45

* **GIVEN** un Cazador con un objetivo a 45 studs
* **WHEN** ataca con el arco
* **THEN** el servidor acepta el ataque
* **AND** a 46 studs lo rechaza por rango

#### Escenario 2: Skills de Puntería a 45

* **GIVEN** Disparo perforante, Flecha venenosa, Tiro certero, Tiro en cadena o Disparo mortal
* **WHEN** el objetivo está a 45 studs o menos
* **THEN** el cast se acepta
* **AND** a más de 45 se rechaza por rango

#### Escenario 3: Enemigo persigue

* **GIVEN** un enemigo fuera de su rango de ataque
* **WHEN** el Cazador lo daña desde 45 studs
* **THEN** el enemigo lo toma como objetivo y se acerca
* **AND** no se queda quieto ni deja de atacar por estar fuera de rango

#### Escenario 4: Ranged máximo 40

* **GIVEN** un enemigo ranged con rango mayor a 40
* **WHEN** se revisa su configuración
* **THEN** su rango queda en 40
* **AND** un enemigo ranged con rango menor conserva su valor

#### Escenario 5: Sin poke gratis

* **GIVEN** un Cazador atacando a distancia
* **WHEN** el enemigo sobrevive al daño
* **THEN** el enemigo avanza hacia el Cazador
* **AND** el jugador no puede mantener un ataque sin riesgo indefinidamente

#### Escenario 6: Leash y LOS

* **GIVEN** un enemigo persiguiendo a un jugador
* **WHEN** el jugador sale del leash o rompe la línea de visión
* **THEN** el enemigo se reposiciona o vuelve a su spawn
* **AND** no atraviesa paredes ni persigue por todo el mapa

#### Escenario 7: Sin cambios colaterales

* **GIVEN** el ajuste implementado
* **WHEN** se revisan daño, cooldown, maná, crítico, stats y loot
* **THEN** los valores no cambian
* **AND** las habilidades melee de Asalto conservan su rango

#### Escenario 8: Regresión

* **GIVEN** el cambio activo
* **WHEN** se juega campaña, Senda del Jotunn, party y PvE
* **THEN** no hay errores rojos ni enemigos atascados
* **AND** la IA sigue funcionando

---

### Comportamiento Visual / UI-UX

* El rango de 45 debe comunicarse en tooltips y cursor; no debe sentirse arbitrario.
* El enemigo debe reaccionar visiblemente al aggro: girar, avanzar y atacar.
* No agregar barras, iconos ni UI nueva de amenaza.
* El Cazador debe seguir sintiéndose ranged; no convertirlo en melee.

---

### Alcance

#### Incluye

* Ataque básico de arco y skills de Puntería a 45.
* Aggro/chase al recibir daño.
* Rango máximo 40 para enemigos ranged; menores sin cambios.
* Tooltips/indicadores y validación server-side.
* QA de campaña, Senda del Jotunn y party.

#### No incluye

* Cambios de daño, cooldown, maná, crítico, stats o loot.
* Convertir Asalto melee en ranged.
* Enemigos, jefes, skills o clases nuevas.
* Cambios de velocidad base, daño o cadencia enemiga.
* Nuevos SFX/VFX finales.
* PvP.

---

### Definition of Done (DoD)

* [ ] Ataque básico de arco y Puntería validan 45 studs en servidor y UI.
* [ ] Tooltips/indicadores actualizados.
* [ ] Enemigos atacados persiguen al atacante.
* [ ] Ranged enemigos con rango >40 quedan en 40; los menores no cambian.
* [ ] Leash/LOS evitan persecuciones infinitas y ataques a través de paredes.
* [ ] Sin cambios de daño/cooldown/maná/stats.
* [ ] QA de campaña, Senda, party, PC/móvil.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).

---

### Decisiones por defecto

| Tema | Default |
|---|---|
| Rango Cazador | 45 studs en arco y Puntería |
| Asalto melee | Conserva su rango melee |
| Aggro | Al recibir daño del jugador; 8 s |
| Chase | Persigue fuera de rango; leash a la zona |
| Ranged enemigo | Máximo 40; menores sin cambios |
| LOS | Se mantiene |
| Daño/cooldown/maná | Sin cambios |
| UI | Tooltips/cursor a 45 |
| Audio/VFX | Solo existentes |

---

### Estimación (orientativa)

2–3 sesiones del dev: configs de rango, aggro/chase, clamp de enemigos, tooltips y QA.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-11-12 | Creación de HU-R6.63: Cazador de Puntería a 45 studs, aggro con persecución al recibir daño y rango máximo de enemigos ranged en 40; Asalto melee conserva su rango. |
