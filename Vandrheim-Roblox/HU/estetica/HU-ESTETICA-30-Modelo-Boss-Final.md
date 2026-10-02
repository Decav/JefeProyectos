# HU-ESTETICA-30: Modelo del boss final — Guardián de la Escarcha, rig articulado para Moon Animator (diseñador)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / Enemigos / Boss final
**Prioridad:** **CRÍTICA** (es el jefe final del juego)
**Estado:** Lista para implementar
**Tipo:** Producción de modelo 3D (diseñador) — **sin scripts ni animaciones propias**; el rig se entrega articulado para que el dev anime con Moon Animator
**Fase GDD:** R7 / EST (cubre el hueco que EST-02 dejó para R7: el boss no tiene modelo real)
**Depende de:** HU-R7 (boss del piso 5: `helada_frostwarden`, ai `boss_melee`, ataque `glacial_impact`), HU-ESTETICA-02 (estructura estándar de enemigos), ASSETS_POLICY (naming/registro)
**No modifica:** stats, ataques, loot ni mecánicas del boss (eso vive en `BossConfig`/`EnemyConfig`)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** un jefe final **espectacular**: el Guardián de la Escarcha con presencia, silueta y movimiento a la altura del cierre del juego,
**para** que la pelea final del piso 5 se sienta épica y memorable.

**Como** equipo de desarrollo,
**quiero** un modelo con **más articulaciones** que los enemigos actuales (que usan brazo/pierna sólidos),
**para** que el dev lo anime bien con **Moon Animator** (extremidades segmentadas: hombro/bíceps/antebrazo/mano, cadera/muslo/espinilla/pie, torso segmentado).

---

### **Descripción del Requerimiento / Contexto**

Los enemigos actuales se hicieron con piezas sólidas (brazo completo, pierna completa): sirven para animación simple pero **limitan la calidad del movimiento**. El **Guardián de la Escarcha** (`helada_frostwarden` — boss final del piso 5, R7) será el enemigo más importante del juego y merece un rig **articulado** que permita animar bien con Moon Animator.

**Criterio de hecho global:** existe el modelo del boss con rig articulado (extremidades segmentadas y nombres de articulaciones documentados), compatible con `EnemyService` (Humanoid + HRP + PrimaryPart, sin scripts), espectacular y temático — listo para que el dev lo anime e integre (HU-ESTETICA-31).

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. El modelo (visual) — Dirección C: BESTIA COLOSAL (decisión PO 2026-09-22)**

* **Identidad:** el Guardián de la Escarcha es una **bestia colosal cuadrúpeda** — un **oso/mamut de hielo gigante** — el único enemigo del juego que rompe con el set humanoides (Señor de la Escarcha, caballeros, etc.). Imponente por **masa bruta**.
* **Escala: 3–3.5× el jugador** (más grande que cualquier enemigo actual; ~2–2.5× el lobo élite).
* **Silueta:** cuerpo macizo y bajo (tronco poderoso), **colmillos/cuernos de hielo** grandes y segmentados, **placas de hielo/cristal** en el lomo y hombros, **núcleo de cristal brillante** en el pecho (punto débil visual), garras de glaciar.
* **Presencia:** aura ambiental a su alrededor (nieve/partículas sutiles), **suelo congelado bajo él** (frost aura en el piso de la boss room), runas `Neon` azul pálido pulsantes en las placas (patrón de los uniques EST-18: familia de hielo).
* **Movimiento pesado:** cada paso debe sentirse en el rig (masa, balanceo del torso).

#### **2. El rig articulado (clave para Moon Animator)**

* **Cuadrúpedo segmentado** (superior a los enemigos actuales, que usan piezas sólidas):
  * **4 patas segmentadas** (hombro → muslo → antepierna → garra, 4 articulaciones por pata).
  * **Torso segmentado** (2–3 segmentos: caderas → tronco → pecho) para balanceo y giros.
  * **Cuello largo segmentado + cabeza** con mandíbula articulada (rugido/mordida) y **colmillos/cuernos animables**.
  * (Opcional) **cola de cristal segmentada** (3–5 articulaciones).
* **Nombres de articulaciones documentados** (ej. `RightShoulder`, `RightThigh`, `RightShin`, `RightPaw`, `Spine`, `Chest`, `Neck`, `Head`, `Jaw` — estilo R15 pero cuadrúpedo): el diseñador entrega la **tabla de articulaciones** (nombre → pieza) para que el dev anime sin adivinar.
* **Compatibilidad EnemyService:** `Humanoid` + `HumanoidRootPart` + `PrimaryPart`, `Anchored=false`, piezas decorativas `CanCollide=false`/`CanTouch=false`/`CanQuery=false`/`Massless=true`, **sin scripts** ni `AnimationController` propio. La familia de animación es `quadruped` (ya soportada por el sistema — ver lobos).
* Pesos livianos (sin meshes excesivos; presupuesto de piezas acotado).

#### **3. Entrega**

* `modelId = helada_frostwarden`; ubicación `ReplicatedStorage/Assets/Models/Enemies/helada_frostwarden`.
* Notas de entrega: tabla de articulaciones + recomendaciones de animación (qué mover en cada ataque) + registro en `ASSETS_REGISTRY`.
* No duplicar/alterar los modelos existentes.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Boss espectacular**

* **GIVEN** el modelo entregado
* **WHEN** se lo mira en la arena
* **THEN** impone presencia (bestia cuadrúpeda colosal 3–3.5× el jugador, colmillos/placas de hielo, núcleo brillante, aura) y se reconoce al instante como el jefe final

#### **Escenario 2: Rig articulado**

* **GIVEN** el rig del boss
* **WHEN** se revisan las articulaciones
* **THEN** las 4 patas están segmentadas (hombro/muslo/antepierna/garra), el torso se balancea, el cuello/cabeza y la mandíbula son independientes
* **AND** la tabla de articulaciones documenta nombres → piezas para Moon Animator

#### **Escenario 3: Compatible con el juego**

* **GIVEN** el modelo
* **WHEN** `EnemyService` lo clona (DebugSpawnEnemy)
* **THEN** spawnea con Humanoid/IA (familia `quadruped`) sin errores rojos y las piezas móviles se mueven con los welds

#### **Escenario 4: Entrega válida**

* **GIVEN** la entrega
* **WHEN** se inspecciona
* **THEN** no tiene scripts ni animaciones propias, está registrado y no altera modelos existentes

#### **Escenario 5: Listo para animar**

* **GIVEN** la tabla de articulaciones
* **WHEN** el dev abre el modelo en Moon Animator
* **THEN** encuentra todas las articulaciones nombradas y puede animar extremidades/torso/cabeza por separado

---

### **Alcance**

#### Incluye

* Modelo del Guardián de la Escarcha (visual espectacular, temática hielo).
* Rig articulado (brazos/piernas segmentados, torso, cuello/cabeza; opcional cola/capa).
* Tabla de articulaciones para Moon Animator + notas de entrega.
* Registro en ASSETS_REGISTRY.

#### No incluye

* Animaciones (las crea el dev con Moon Animator — HU-ESTETICA-31).
* VFX/efectos de la pelea (dev — HU-ESTETICA-31).
* Scripts, stats, loot ni mecánicas (R7/BossConfig intactos).
* Otros enemigos (EST-02).

---

### **Definition of Done (DoD)**

* [ ] Modelo espectacular del boss (silueta, escala, hielo/runas) en `Assets/Models/Enemies/helada_frostwarden`.
* [ ] Rig articulado (segmentos mínimos documentados) con welds/PrimaryPart correctos.
* [ ] Tabla de articulaciones (nombre → pieza) entregada para Moon Animator.
* [ ] Compatible con EnemyService (spawn sin errores, sin scripts/animaciones propias).
* [ ] Registrado en ASSETS_REGISTRY; modelos existentes intactos.
* [ ] Aprobación visual del PO (es el jefe final).
* [ ] Reporte al PM con el detalle y pendientes.

---

### **Estimación (orientativa)**

2–4 sesiones del diseñador: modelado del boss + rig articulado + tabla de articulaciones.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-ESTETICA-30: modelo del boss final (Guardián de la Escarcha) con **rig articulado para Moon Animator** (extremidades segmentadas + tabla de articulaciones) — cubre el hueco que EST-02 dejó para R7 |
| 2026-09-22 | **Rediseño (decisión PO — Dirección C):** el boss pasa a ser una **bestia colosal cuadrúpeda** (oso/mamut de hielo, 3–3.5× el jugador) — rompe con el set humanoide; patas segmentadas + torso/cuello/mandíbula articulados, núcleo de cristal brillante, aura de nieve y suelo congelado; familia `quadruped` |