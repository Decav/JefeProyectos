# HU-ESTETICA-31: Integración del boss final — modelo, animaciones con Moon Animator y efectos (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / Enemigos / Boss final — Integración (dev)
**Prioridad:** **CRÍTICA** (cierra la pelea final del juego)
**Estado:** Lista para implementar
**Tipo:** Integración + animación + VFX del boss (dev)
**Fase GDD:** R7 / EST (complementa HU-R7 ya implementada)
**Depende de:** HU-ESTETICA-30 (modelo articulado del boss), HU-R7 (boss `helada_frostwarden`: `glacial_impact`, cofre, uniques), HU-ESTETICA-02 (estructura de enemigos), HU-R6.7 (framework de animaciones por familia), HU-ESTETICA-19/20 (boss bar del HUD), HU-PUBLICAR-04 (sync de places)
**Nota de capacidad (confirmada por el PO 2026-09-22):** **todas las animaciones del juego se crean con Moon Animator** (jugador y casi todos los enemigos ya animados; nada viene de la toolbox). Para el boss se usa el mismo método estándar — la ASSETS_POLICY fue actualizada (la regla vieja "no crear animaciones / solo Library" quedó corregida).

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** una pelea final **espectacular**: el Guardián de la Escarcha con animaciones propias (ataques con telegrafía clara) y efectos de escarcha,
**para** que el cierre del juego sea épico y la pelea se sienta justa y memorable.

**Como** equipo de desarrollo,
**quiero** integrar el modelo articulado del diseñador, animarlo con Moon Animator y darle efectos,
**para** que el boss final funcione de punta a punta (spawn → pelea → cofre → uniques) sin regresiones.

---

### **Descripción del Requerimiento / Contexto**

El boss final (`helada_frostwarden`, Guardián de la Escarcha) existe como dato (R7: ai `boss_melee`, ataque `glacial_impact`, cofre + uniques en `floor_5_boss`) pero **usa placeholder** (no tiene modelo real ni animaciones propias). El diseñador entrega el modelo **articulado** (EST-30); el dev:

1. **Enlaza el modelo** (`modelId` en `BossConfig`/`EnemyConfig`).
2. **Crea las animaciones con Moon Animator** (idle, caminar/lunge, ataques, `glacial_impact`, muerte) usando la tabla de articulaciones del diseñador.
3. **Da efectos al jefe** (VFX de escarcha: aura, impacto glacial, telegrafía de ataques, cristales).
4. **Verifica la pelea completa** (bandas de R8d: boss 60–120 s; cofre y uniques intactos).

**Criterio de hecho global:** el Guardián de la Escarcha aparece con su modelo real, se anima fluidamente (extremidades segmentadas), sus ataques tienen telegrafía y efectos, y la pelea del piso 5 funciona completa (cofre + uniques) sin errores rojos.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Integración del modelo**

* `modelId = "helada_frostwarden"` en la config del boss (BossConfig/EnemyConfig) → `EnemyService` lo clona (estructura estándar: Humanoid + HRP + PrimaryPart).
* Registrar en `ASSETS_REGISTRY` (fuente: diseñador).
* **DebugSpawnEnemy/arena:** el boss spawnea con IA sin errores rojos.

#### **2. Animaciones con Moon Animator (método estándar del proyecto)**

* Crear con **Moon Animator** sobre el rig articulado (tabla de articulaciones de EST-30) — **bestia cuadrúpeda** (Dirección C):
  * **Idle** imponente (respiración pesada, aura de nieve, runas pulsando).
  * **Walk/lunge** (avance pesado con patas segmentadas y balanceo del torso).
  * **Ataque melee** (zarpazo/embestida: wind-up → swipe/bite con patas delanteras, cabeza y mandíbula — usando el torso).
  * **`glacial_impact`** (ataque de R7): telegrafía clara (carga visible, cristales emergiendo del suelo) → impacto con onda de escarcha (pisotón/carga).
  * **Muerte/desmoronarse** (colapso en cristales).
* Integrarlas por config/`AnimationRegistry` (patrón R6.7/enemigos), con `animationKey` correctos en la config del boss.
* Guardar los `rbxassetid` y registrarlos (fuente: producción propia con Moon Animator).

#### **3. Efectos del jefe (VFX)**

* **Aura de escarcha** en idle/combate (partículas de nieve/hielo alrededor, estilo R8a/b/c).
* **`glacial_impact`:** cristales/onda de escarcha al impactar + telegrafía visual del área (círculo/runas antes del golpe — complementa el HUD de combate EST-19/20).
* **Golpes:** impacto con partículas de hielo en el jugador/entorno.
* **Muerte:** explosión de cristales (sin romper el cofre ni el flujo R7).
* Client-side con autoridad server (patrón confirmado); sin SFX (R9b).

#### **4. Pelea y regresión**

* La boss bar (EST-19/20) muestra el boss con su nombre real.
* Bandas R8d: TTK 60–120 s; golpes pico 45–60% MaxHP (fuerza consumibles/curas); ningún kill < 45 s.
* Cofre + uniques (R7) intactos; reward UI funciona.
* **Sync places (PUBLICAR-04):** el cambio va al hub y llega a la dungeon por copia derivada al publicar (verificar la pelea publicada).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Boss con modelo real**

* **GIVEN** el boss configurado
* **WHEN** se spawnea en el piso 5
* **THEN** aparece con el modelo del diseñador (sin placeholder) y la IA funciona

#### **Escenario 2: Animaciones fluidas**

* **GIVEN** el boss animado con Moon Animator
* **WHEN** pelea (idle, avance, ataques, glacial_impact, muerte)
* **THEN** las extremidades segmentadas se mueven fluidamente y cada ataque tiene telegrafía clara

#### **Escenario 3: Efectos**

* **GIVEN** la pelea
* **WHEN** el boss ataca y muere
* **THEN** se ven la aura de escarcha, la telegrafía del glacial_impact, el impacto y la muerte en cristales

#### **Escenario 4: Pelea en banda**

* **GIVEN** un jugador lvl 16–20 con gear del piso
* **WHEN** pelea al boss
* **THEN** el TTK cae en 60–120 s y los golpes pico en 45–60% MaxHP (bandas R8d)
* **AND** ningún kill < 45 s

#### **Escenario 5: Cierre intacto**

* **GIVEN** el boss derrotado
* **WHEN** se abre el cofre
* **THEN** los uniques (frost_edge/frostbow/glacial_wand) caen por el flujo R7 y la reward UI funciona

#### **Escenario 6: Regresión publicada**

* **GIVEN** la integración completa
* **WHEN** se juega el piso 5 publicado (hub → dungeon → boss → cofre → vuelta)
* **THEN** no hay errores rojos y nada del flujo existente se rompe

---

### **Alcance**

#### Incluye

* Enlace del modelo del boss (modelId + registro).
* Animaciones propias con Moon Animator (idle, avance, melee, glacial_impact, muerte) integradas por config.
* VFX del jefe (aura, telegrafía, impacto, muerte) client-side con autoridad server.
* Verificación de la pelea completa (bandas R8d, cofre, uniques) publicada.

#### No incluye

* El modelo del boss (diseñador — HU-ESTETICA-30).
* Animaciones para otros enemigos (regla original: solo librería).
* SFX (R9b), balance (R8d/R9c) ni mecánicas nuevas.

---

### **Definition of Done (DoD)**

* [ ] Boss con modelo real (sin placeholder) y IA funcionando (DebugSpawnEnemy/arena).
* [ ] Animaciones Moon Animator integradas (idle/avance/melee/glacial_impact/muerte) con telegrafía clara.
* [ ] VFX del jefe (aura, telegrafía, impacto, muerte en cristales) funcionando.
* [ ] Pelea dentro de bandas R8d (60–120 s; golpes 45–60% MaxHP).
* [ ] Cofre + uniques + reward UI intactos (R7).
* [ ] Sin errores rojos en el flujo publicado (hub → dungeon → boss → cofre).
* [ ] ASSETS_REGISTRY actualizado; ASSETS_POLICY con la excepción del boss documentada.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Decisiones por defecto EST-31**

| Tema | Default |
|------|---------|
| Animaciones | Creadas con **Moon Animator** (método estándar del proyecto; ASSETS_POLICY actualizada) |
| Integración | `modelId` + `animationKey` por config (patrón R6.7) |
| Efectos | Client-side con autoridad server (patrón confirmado) |
| Pelea | Bandas R8d (60–120 s; golpes 45–60% MaxHP) |
| Sync | Copia derivada al publicar (PUBLICAR-04) |

---

### **Estimación (orientativa)**

3–4 sesiones del dev: integración + animaciones Moon Animator + VFX + verificación de la pelea publicada.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-ESTETICA-31: integración del boss final — modelo enlazado, animaciones con Moon Animator (excepción aprobada), VFX de escarcha y verificación de la pelea completa (bandas R8d, cofre/uniques R7) |