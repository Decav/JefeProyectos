# HU-R6.38: Golpes críticos en habilidades de daño (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R6.x / Combate / CRIT
**Prioridad:** Alta
**Estado:** Pendiente de RC para implementación
**Tipo:** Corrección de combate (dev)
**Fase GDD:** R6.38 — habilitar críticos en impactos de habilidades de daño sin cambiar la fórmula CRIT existente.
**Depende de:** HU-R6.22 (CRIT en fracción 0–1 y tirada independiente por impacto), HU-R3 (framework de skills), HU-R6.9 (GroundAoE persistente y SelfAoE), `SKILLS_CATALOG`, R8e (Flecha venenosa), HU-ITEMS-03 (Aniquilación, bono de 4 piezas del set Helada del Clérigo)
**Componentes observados:** `ServerScriptService.Services.CombatService` (crítico de básicos), `ServerScriptService.Services.SkillService` (rutas de daño de skills)

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** que los impactos dañinos de mis habilidades puedan hacer crítico según el CRIT de mi personaje,
**para** que CRIT funcione de manera consistente en mis ataques básicos y habilidades.

---

### Descripción / Contexto

`CombatService` consulta actualmente el atributo `CRIT` para los ataques básicos y, si la tirada tiene éxito, aplica el multiplicador crítico existente de **×1,5**. Las rutas de daño de `SkillService` no consultan CRIT, por lo que las habilidades no pueden hacer críticos.

La tirada debe ocurrir **por impacto dañino sobre cada objetivo**, no una vez por activación de la habilidad. `CRIT` conserva su representación autoritativa actual en fracción de 0 a 1 (R6.22); esta HU no cambia la probabilidad ni el multiplicador.

**Criterio de hecho global:** cada impacto elegible de una habilidad usa una tirada independiente basada en CRIT y el multiplicador ×1,5, y el feedback existente identifica los impactos críticos. Los DoT explícitamente excluidos no tiran ni hacen crítico.

---

### Especificaciones técnicas / Contratos

* Aplicar el mismo CRIT autoritativo y multiplicador ×1,5 usados por `CombatService`; evitar fórmulas divergentes o multiplicación crítica duplicada.
* Resolver el crítico en el servidor dentro de la ruta que aplica el daño. El cliente no decide CRIT, daño ni resultado de la tirada.
* Ejecutar una tirada independiente por cada impacto y objetivo:
  * **Instant:** cada impacto de daño a su objetivo.
  * **SelfAoE:** cada enemigo afectado hace su propia tirada.
  * **GroundAoE:** cada enemigo afectado hace su propia tirada en cada tick. Que el daño ocurra en ticks no convierte por sí mismo a GroundAoE en un DoT excluido.
* El resultado crítico multiplica el daño por ×1,5, siguiendo exactamente el punto y la secuencia de cálculo actuales de los ataques básicos, y marca el número/feedback de daño como crítico mediante el sistema existente.
* Con `CRIT = 0` la tirada nunca tiene éxito; con `CRIT = 1` siempre tiene éxito. Para valores intermedios, cada impacto se sortea por separado; no se exige una proporción exacta de críticos en una muestra pequeña.
* **Excluir daño de tipo DoT** de esta HU. En particular, no pueden hacer crítico los ticks de **Flecha venenosa del Cazador** ni el DoT **Aniquilación** del bono de 4 piezas del set Helada del Clérigo.
* Clasificar por el tipo/contrato de daño, no por su periodicidad: los ticks de GroundAoE son elegibles salvo que una habilidad esté explícitamente definida como DoT.
* Curaciones, escudos, buffs y demás efectos que no aplican daño no realizan tiradas ni consumen el resultado aleatorio.
* Mantener sin cambios el comportamiento de críticos de los ataques básicos, la escala de CRIT de R6.22 y el balance de habilidades.

---

### Criterios de aceptación (Gherkin)

#### Escenario 1: CRIT cero

* **GIVEN** el personaje tiene `CRIT = 0`
* **WHEN** realiza ataques básicos e impactos de habilidades de daño elegibles
* **THEN** ninguno se marca como crítico ni recibe el multiplicador ×1,5

#### Escenario 2: CRIT máximo

* **GIVEN** el personaje tiene `CRIT = 1`
* **WHEN** cada ataque básico o impacto elegible aplica daño
* **THEN** cada uno se marca como crítico y usa ×1,5

#### Escenario 3: Impactos independientes en área

* **GIVEN** el personaje tiene una probabilidad intermedia de CRIT y una habilidad SelfAoE o GroundAoE afecta a varios enemigos
* **WHEN** el servidor resuelve el daño
* **THEN** tira de manera independiente por objetivo y por impacto; no reutiliza el resultado de otro enemigo ni exige una proporción exacta en pocos golpes

#### Escenario 4: GroundAoE persistente

* **GIVEN** una GroundAoE activa daña a un enemigo en varios ticks y el caster tiene `CRIT = 1`
* **WHEN** se resuelve cada tick
* **THEN** cada tick puede hacer crítico y aplica ×1,5 de forma independiente

#### Escenario 5: DoT excluidos

* **GIVEN** se aplican los ticks de Flecha venenosa o Aniquilación
* **WHEN** causan daño periódico
* **THEN** ningún tick hace la tirada de CRIT ni se marca como crítico, incluso si el caster tiene `CRIT = 1`

#### Escenario 6: CRIT intermedio y feedback

* **GIVEN** el personaje tiene una probabilidad de CRIT entre 0 y 1
* **WHEN** varios impactos elegibles ocurren
* **THEN** cada impacto se sortea independientemente, el daño crítico aplica ×1,5 y el feedback existente distingue los críticos

#### Escenario 7: Efectos sin daño

* **GIVEN** una habilidad aplica curación, escudo o buff sin daño
* **WHEN** se resuelve el efecto
* **THEN** no se realiza ninguna tirada de CRIT

#### Escenario 8: Sin regresiones

* **GIVEN** ataques básicos, skills Instant, SelfAoE, GroundAoE y DoT
* **WHEN** se prueban en el servidor con distintos valores de CRIT
* **THEN** se conserva el crítico de básicos, las excepciones DoT y el daño/feedback correcto, sin errores de servidor

---

### Alcance

#### Incluye

* Críticos para daño de habilidades Instant, SelfAoE y GroundAoE.
* Tirada independiente por objetivo e impacto, incluidos los ticks elegibles de GroundAoE.
* Multiplicador ×1,5 y marca visual de crítico usando los contratos existentes.
* Exclusión explícita de Flecha venenosa y Aniquilación como daño de tipo DoT.

#### No incluye

* Hacer que los DoT puedan criticar; esto podrá evaluarse en una HU futura.
* Cambiar la probabilidad, normalización o fuentes de CRIT.
* Cambiar el multiplicador crítico, daño base, fórmulas de habilidad o balance.
* Críticos para curación, escudos, buffs u otros efectos sin daño.

---

### Definition of Done (DoD)

* [ ] `CombatService` y `SkillService` usan un contrato de crítico consistente, server-authoritative, sin doble aplicación.
* [ ] Instant y SelfAoE hacen una tirada independiente por impacto/objetivo.
* [ ] GroundAoE hace una tirada independiente por objetivo en cada tick elegible.
* [ ] Flecha venenosa y Aniquilación no hacen críticos; se valida con `CRIT = 1`.
* [ ] `CRIT = 0` no produce críticos; `CRIT = 1` produce críticos en todos los impactos elegibles.
* [ ] Para CRIT intermedio se verifica independencia sin exigir proporciones exactas en muestras pequeñas.
* [ ] Críticos de skills muestran el feedback correspondiente y usan ×1,5; curas/escudos/buffs no tiran.
* [ ] Los ataques básicos mantienen su comportamiento; sin errores rojos y con evidencia de QA.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-10-22 | HU creada a partir del hallazgo del dev: CRIT solo se consulta en ataques básicos; se define alcance para skills y excepción de DoT. |
