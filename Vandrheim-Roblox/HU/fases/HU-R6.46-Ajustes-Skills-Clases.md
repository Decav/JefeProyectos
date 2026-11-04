# HU-R6.46: Ajustes de skills por clase (rango, escalado, taunt y TargetAoE) (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Combate / Skills
**Prioridad:** Alta — corrige golpes que no conectan y define el rol del tanque
**Estado:** Abierta — lista para RC
**Tipo:** Ajuste de contenido y framework de skills (dev)
**Fase GDD:** Combate (correcciones sobre R8a–R8c / R8d)
**Depende de:** HU-R3 (framework de skills), HU-R8a/b/c (contenido por clase), HU-R6.8/R8 (VFX), HU-R6.16 (curación a aliados), HU-R6.31 (`NotificationFrame`), HU-ITEMS-03 (bono de 4 piezas de Puntería), SKILLS_CATALOG, `SkillService`, `CombatService`
**No modifica:** daño de ataques básicos (solo el rango de la varita en §7), economía, stats de equipo ni skills fuera de las listadas.

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** que las skills de área conecten a la misma distancia que mi ataque normal, que el tanque pueda sostener la amenaza y que las capstones se sientan impactantes,
**para** que el combate no dependa de la posición exacta y cada spec cumpla su rol.

**Como** equipo,
**quiero** corregir rangos y añadir un tipo de skill dirigido con área,
**para** mejorar la legibilidad del combate sin rehacer el sistema.

---

### Descripción / Contexto

Se detectaron cuatro problemas:
1. Skills SelfAoE con radio menor al rango del ataque básico: el enemigo está a distancia de golpe, pero queda fuera del área.
2. Embate de escudo no escala con la stat que define al Protector y no genera amenaza real frente a DPS alto.
3. Ira divina es una zona persistente cuando debería ser un golpe dirigido con impacto instantáneo y presencia visual.
4. El kit del Clérigo tiene rangos dispersos (15/20/25/self) que no corresponden a su rol a distancia.

Además se reubica el bono de 4 piezas de Puntería: la cadena pasa a la skill base y el set mejora Flecha venenosa.

**Criterio de hecho global:** Anillo de luz sagrada y Torbellino cubren al menos el rango del ataque básico; Embate escala con DEF/ATK y provoca; Ira divina es TargetAoE instantánea de radio 10; Tiro en cadena golpea a un segundo enemigo; el bono de 4 piezas de Puntería convierte Flecha venenosa en área de 6 studs; y el Clérigo queda normalizado a 25 studs de daño, 30 de curación/escudo y 25 de varita.

---

### Especificaciones Técnicas / Contratos

#### 1. Paladín — Castigo: Anillo de luz sagrada

* Skill: `paladin_ret_holy_ring` (SelfAoE).
* **Cambio:** el radio de efecto debe ser **≥ rango del ataque básico melee + 1 stud**. Default: **13** (antes 6).
* El rango de referencia es el `basicAttackRange` del arma equipada (melee = 12 en todos los templates actuales); si el arma cambia el alcance, el radio debe seguir esa referencia.
* No cambia daño, maná ni cooldown.
* Config: `holyRingRadius = 13`.
* Sin chequeo de línea de visión: se mantiene el comportamiento actual de SelfAoE (golpea alrededor del jugador; una pared no bloquea el área).
* Regla general: ninguna SelfAoE de melee puede tener radio menor al alcance de su ataque básico.

#### 2. Paladín — Protector: Embate de escudo

* Skill: `paladin_prot_shield_bash` (Instant, rango 12, maná 15, CD 6, threat 3).
* **Escalado:** pasa de `14 + 1.0×ATK` a `14 + 0.5×ATK + 1.0×DEF` (defaults; el peso de DEF es mayor porque define al Protector). Validar en R8d/R9c.
* **Provocar:** aplica Taunt al objetivo durante **3 s** (default), forzando que lo ataque al paladín. Se aplica al impactar (no hay tiradas de fallo en el juego).
* **Fin anticipado del taunt:** termina antes si el paladín muere, sale del aggro del enemigo, abandona la run o el enemigo muere. Al terminar, el enemigo vuelve a su selección normal de objetivo.
* **Inmunidad anti-perma:** tras terminar un taunt, el mismo enemigo no puede ser provocado de nuevo durante **2 s** (`tauntImmunity`). Con CD 6 y taunt 3 s, la cobertura máxima es ~50 % y varios paladines no lo encadenan.
* **Amenaza:** además del taunt, aplica un pico de amenaza (`tauntThreatBoost = 0.5`) para conservar el aggro cuando el taunt expira.
* **Jefes:** el taunt es **completo**, con la misma duración y reglas. Solo cambia la selección de objetivo; las habilidades del jefe conservan su forma y su área (no se redirigen AoE ni casteos).
* **Varios paladines:** gana el taunt más reciente; la inmunidad es por enemigo.
* Config: `shieldBashDefCoef = 1.0`, `shieldBashAtkCoef = 0.5`, `tauntDuration = 3`, `tauntImmunity = 2`, `tauntThreatBoost = 0.5`.

#### 3. Clérigo — Cólera: Ira divina

* Skill: `cleric_wrath_divine_ire`.
* **Cambio de tipo:** de `GroundAoE` (zona persistente) a **`TargetAoE`** (nuevo tipo).
* Comportamiento:
  * Requiere un enemigo seleccionado, con LOS y dentro del **rango de lanzamiento 25**; sin objetivo válido, falla con aviso (`NotificationFrame`) y no consume maná ni cooldown.
  * Impacto **instantáneo** en la posición del objetivo; sin zona persistente, sin DoT y sin telegraph en el suelo.
  * Daño a todos los enemigos dentro de un radio de **10 studs** (default) alrededor del objetivo, incluido el objetivo. Sin chequeo de LOS dentro del radio.
  * VFX nuevo y potente (meteorito sagrado / ira del cielo) que cae desde arriba y marca el impacto; registrar id en `VFXConfig` (propuesta: `cleric_divine_ire_impact`).
* **Daño:** `damageBase = 17`, `coefficient = 1.75×MATK` como golpe único. Sustituye el total de la zona anterior (8 ticks ≈ `16.8 + 1.76×MATK`); el instantáneo vale más que el daño en el tiempo, así que el número final se valida en R8d/R9c.
* Maná 20 y CD 12 se mantienen.
* Móvil: el objetivo se elige con el sistema de targeting existente; el aviso de "sin objetivo" usa `NotificationFrame` (R6.31).
* **Framework:** implementar `TargetAoE` en `SkillService`/`SkillConfig` como tipo reutilizable. Debe declarar `castRange`, `aoeRadius` y requerir objetivo enemigo.

#### 4. Cazador — Asalto: Torbellino

* Skill: `hunter_asm_whirlwind` (SelfAoE).
* **Cambio:** radio de efecto **≥ rango del ataque básico melee + 1 stud**. Default: **13** (antes 8).
* No cambia daño, maná ni cooldown.
* **Confirmado por PO:** Torbellino es la skill a corregir (única SelfAoE de Asalto).

#### 5. Cazador — Puntería: Tiro en cadena

* Skill: `hunter_mm_chain` (Instant, rango 30, maná 12, CD 4, `10/0.9`).
* **Cambio (base, sin set):** golpea al objetivo **y a 1 enemigo adicional**.
* Selección del secundario: el enemigo **más cercano** al primario, dentro de **8 studs**, excluyendo al primario y con **LOS desde el primario**. Si no hay candidato válido, golpea solo al principal.
* El secundario recibe el **mismo daño** con su propia tirada de crítico; la cadena **no se propaga** más allá de un salto.
* No cambia maná ni cooldown.
* Config: `chainJumpRadius = 8`, `chainExtraTargets = 1`.

#### 6. Cazador — Puntería: bono de 4 piezas

* **Sustituye** el bono actual de ITEMS-03 (“+1 objetivo en Tiro en cadena”). Ese efecto ya no lo da el set: ahora es base (§5).
* Nuevo bono: **Flecha venenosa** (`hunter_mm_venom`) pasa a comportarse como **TargetAoE**: el impacto aplica el **DoT completo** al objetivo y a todos los enemigos dentro de **6 studs** del objetivo, sin reducción de daño y sin chequeo de LOS dentro del radio.
* Mantiene rango 30, maná 15 y CD 10; el DoT conserva sus ticks (4 + 0.35×ATK por segundo, 6 s).
* El golpe directo de la flecha sigue siendo single-target; el bono solo amplía la aplicación del veneno.
* **Sin el bono** (menos de 4 piezas o spec distinta de Puntería), Flecha venenosa sigue siendo single-target como hoy.
* Si el jugador pierde el bono después de aplicar el veneno, los DoT ya activos siguen su curso normal.
* Config: `venomAoeRadius = 6`.
* **Enmienda documental:** ITEMS-03 debe actualizarse para reflejar este bono; el texto anterior deja de ser válido.

#### 7. Clérigo — normalización de rangos

Se unifican los rangos del Clérigo para que el kit sea coherente con su rol a distancia.

**Cólera y básicas dañinas → 25 studs:**

| Skill | Rango actual | Rango nuevo |
|---|---|---|
| `cleric_smite` (Golpe de fe) | 15 | **25** |
| `cleric_burning_light` (Luz ardiente) | 20 | **25** |
| `cleric_wrath_spear` (Lanza de luz) | 20 | **25** |
| `cleric_wrath_mark` (Marca de castigo) | 25 | 25 (sin cambio) |
| `cleric_wrath_divine_ire` (Ira divina) | cast ≤20 | **25** (TargetAoE) |
| `cleric_wrath_annihilation` (Aniquilación) | 25 | 25 (sin cambio) |

* Todas las habilidades de Cólera deben poder lanzarse a **25 studs**.
* Las básicas dañinas del Clérigo también pasan a 25 (las comparten ambas specs).

**Misericordia (curación y escudo) → 30 studs:**

| Skill | Rango actual | Rango nuevo |
|---|---|---|
| `cleric_hol_heal` (Sanación) | self | **aliado a 30** |
| `cleric_hol_word` (Palabra de luz) | self | **aliado a 30** |
| `cleric_hol_shield` (Escudo de fe) | self | **aliado a 30** |
| `cleric_hol_miracle` (Milagro) | self | **aliado a 30** (AOE radio 10 centrada en el aliado) |

* Se usa el soporte de objetivo aliado existente (R6.16); el alcance de 30 se mide al **aliado elegido**, no al lanzador.
* Sin aliado válido (ninguno seleccionado, muerto o fuera de 30), la skill cae en **self** como respaldo, sin consumir maná si se rechaza por objetivo inválido.
* Milagro cura **solo aliados** dentro del radio de 10 centrado en el aliado objetivo; no daña enemigos.
* Móvil: el aliado se elige con el sistema de targeting/party existente.
* Config: `allyRange = 30` en las skills de Misericordia.

**Varita (ataque básico) → 25 studs:**

* Todos los templates de varita (`cleric_wand`, `wand_white`, `wand_green`, `wand_blue`, `wand_frost`, `unique_glacial_wand`) pasan de `basicAttackRange = 30` a **25**.
* No cambia daño, VFX, animación ni stat de ataque (`MATK`).
* Coherente con el rango de las skills de Cólera.

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Anillo de luz sagrada a rango melee

* **GIVEN** un Paladín Castigo con un enemigo a distancia de ataque básico
* **WHEN** lanza Anillo de luz sagrada
* **THEN** el enemigo recibe el daño del burst (radio ≥ alcance del ataque básico)

#### Escenario 2: Torbellino a rango melee

* **GIVEN** un Cazador Asalto con un enemigo a distancia de ataque básico
* **WHEN** lanza Torbellino
* **THEN** el enemigo recibe el daño del burst

#### Escenario 3: Embate escala con DEF

* **GIVEN** dos Paladines Protector con el mismo ATK y distinta DEF
* **WHEN** usan Embate de escudo contra el mismo enemigo
* **THEN** el de mayor DEF inflige más daño

#### Escenario 4: Provocar

* **GIVEN** un Paladín Protector y un aliado con más DPS
* **WHEN** el paladín impacta Embate de escudo
* **THEN** el enemigo lo ataca a él durante la duración del taunt
* **AND** contra un jefe el taunt también fuerza el objetivo durante la misma duración

#### Escenario 5: Fin del taunt e inmunidad

* **GIVEN** un enemigo provocado
* **WHEN** termina el taunt o el paladín muere
* **THEN** el enemigo vuelve a su selección normal
* **AND** no puede ser provocado otra vez hasta pasar `tauntImmunity`

#### Escenario 6: Ira divina dirigida

* **GIVEN** un Clérigo Cólera con un enemigo seleccionado a ≤25 studs
* **WHEN** lanza Ira divina
* **THEN** cae el impacto instantáneo sobre el objetivo y golpea a los enemigos en 10 studs
* **AND** no queda ninguna zona persistente en el suelo

#### Escenario 7: Ira divina sin objetivo

* **GIVEN** un Clérigo sin enemigo seleccionado, sin LOS o fuera de 25 studs
* **WHEN** intenta lanzar Ira divina
* **THEN** la skill falla con aviso y no consume maná ni cooldown

#### Escenario 8: Tiro en cadena base

* **GIVEN** dos enemigos a ≤8 studs entre sí
* **WHEN** el Cazador Puntería usa Tiro en cadena sobre uno
* **THEN** ambos reciben daño completo

#### Escenario 9: Tiro en cadena sin secundario

* **GIVEN** un objetivo sin otro enemigo dentro de 8 studs o sin LOS
* **WHEN** usa Tiro en cadena
* **THEN** solo el objetivo principal recibe daño

#### Escenario 10: Bono de 4 piezas de Puntería

* **GIVEN** Cazador Puntería con el set Helada de 4 piezas
* **WHEN** usa Flecha venenosa
* **THEN** el DoT se aplica al objetivo y a todos los enemigos a ≤6 studs
* **AND** aplicarlo de nuevo refresca la duración sin acumular ticks

#### Escenario 11: Flecha venenosa sin el bono

* **GIVEN** un Cazador con menos de 4 piezas o con otra spec
* **WHEN** usa Flecha venenosa
* **THEN** el veneno se aplica solo al objetivo

#### Escenario 12: Cólera a 25 studs

* **GIVEN** un Clérigo Cólera con un enemigo a 25 studs
* **WHEN** lanza Lanza de luz, Marca de castigo, Ira divina o Aniquilación
* **THEN** la skill conecta; a 26 studs queda fuera de rango

#### Escenario 13: Curación y escudo a 30 studs

* **GIVEN** un Clérigo Misericordia con un aliado a 30 studs
* **WHEN** usa Sanación, Palabra de luz, Escudo de fe o Milagro
* **THEN** el efecto se aplica al aliado
* **AND** sin aliado válido, se aplica a sí mismo como respaldo
* **AND** Milagro cura aliados en radio 10 y no daña enemigos

#### Escenario 14: Varita a 25 studs

* **GIVEN** un Clérigo con varita equipada
* **WHEN** ataca a un enemigo a 25 studs
* **THEN** el ataque básico conecta; a 26 studs no

#### Escenario 15: Regresión

* **GIVEN** los cambios aplicados
* **WHEN** se juega en solo y party, PC y móvil
* **THEN** el resto de skills, cooldowns y daño base funcionan igual y no hay errores rojos

---

### Alcance

#### Incluye

* Radio de SelfAoE de melee corregido (Anillo de luz sagrada y Torbellino).
* Embate de escudo con escalado DEF/ATK, Taunt, amenaza e inmunidad.
* Nuevo SkillType `TargetAoE` + Ira divina dirigida con VFX instantáneo.
* Tiro en cadena con objetivo secundario base.
* Bono de 4 piezas de Puntería aplicado a Flecha venenosa (área 6 studs).
* Normalización de rangos del Clérigo: daño a 25, curación/escudo a 30 y varita a 25.

#### No incluye

* Rediseñar el resto de skills ni sus cifras.
* Cambios de daño de ataques básicos, stats de equipo o economía.
* Nuevos sets o variantes de armas.

---

### Decisiones cerradas (PO 2026-11-03)

1. **Taunt en jefes:** taunt completo, igual que en enemigos normales.
2. **Flecha venenosa en área:** el DoT completo se aplica a todos los enemigos del radio. Si el objetivo ya tenía el veneno, se refresca la duración sin acumular ticks extra.
3. **Asalto:** Torbellino es la skill a corregir.
4. **Rangos del Clérigo:** daño y Cólera a 25 studs, curación/escudo de Misericordia a 30 y varita a 25.

---

### Definition of Done (DoD)

* [ ] Anillo de luz sagrada y Torbellino tienen radio ≥ ataque básico melee + 1 (default 13) y conectan a distancia de golpe.
* [ ] Embate de escudo escala con DEF y ATK según config y aplica Taunt 3 s con pico de amenaza, también contra jefes.
* [ ] El taunt termina correctamente al morir el paladín, salir del aggro o morir el enemigo, y respeta `tauntImmunity`.
* [ ] `TargetAoE` implementado en el framework; Ira divina lo usa con cast 25, radio 10, impacto instantáneo y VFX registrado.
* [ ] Tiro en cadena golpea al secundario más cercano a ≤8 studs con LOS; sin candidato, solo al principal.
* [ ] El bono de 4 piezas de Puntería aplica Flecha venenosa en área de 6 studs; sin el bono sigue single-target.
* [ ] Clérigo: dañinas y Cólera lanzables a 25 studs; curación/escudo a aliado a 30 con fallback self; varita a 25.
* [ ] ITEMS-03 enmendado con el nuevo bono de 4 piezas de Puntería.
* [ ] Sin errores rojos; QA solo/party y móvil; R8d/R9c validan el daño.

---

### Estimación (orientativa)

3–4 sesiones del dev: tipo TargetAoE y VFX, ajustes de radio, taunt con inmunidad, bono de set, rangos del Clérigo y QA de balance.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-11-03 | Revisión de coherencia: se definen bordes del taunt (fin anticipado, inmunidad, amenaza), selección y LOS de la cadena, gating del bono de veneno, números concretos de Ira divina, targeting aliado del Clérigo y enmienda de ITEMS-03. |
| 2026-11-03 | Añadida normalización de rangos del Clérigo: básicas y Cólera a 25 studs, curación/escudo de Misericordia a 30 y varita a 25. |
| 2026-11-03 | Decisiones PO: taunt completo también en jefes; el veneno de Flecha se aplica completo en área (refresca duración sin apilar ticks); Torbellino confirmado como skill de Asalto a corregir. |
| 2026-11-03 | Creación de HU-R6.46: corrección de rango en SelfAoE de melee (Anillo de luz sagrada, Torbellino), Embate de escudo con DEF/ATK y Taunt, Ira divina como TargetAoE instantánea con VFX, Tiro en cadena base con segundo objetivo y bono de 4 piezas de Puntería en Flecha venenosa (área 6 studs). |
