# HU-ESTETICA-36: Modelo del boss final — JOTUNN nórdico (gigante de hielo), rig de 10 partes con Motor6D para Moon Animator (diseñador)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / Enemigos / Boss final
**Prioridad:** **CRÍTICA** (es el último enemigo del juego)
**Estado:** Lista para implementar — **SUSTITUYE a HU-ESTETICA-30** (decisión PO 2026-09-22)
**Tipo:** Producción de modelo 3D (diseñador) — **sin scripts ni animaciones propias**; el rig se entrega articulado (Motor6D) para que el dev anime con Moon Animator
**Fase GDD:** R7 / EST (jefe final del piso 5: `helada_frostwarden`, ai `boss_melee`, ataque `glacial_impact`)
**Depende de:** HU-R7 (boss del piso 5), HU-ESTETICA-02 (estructura estándar de enemigos), HU-ESTETICA-18 (familia visual de hielo: runas `Neon` azul pálido), ASSETS_POLICY (naming/registro)
**No modifica:** stats, ataques, loot ni mecánicas del boss (eso vive en `BossConfig`/`EnemyConfig`)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** un jefe final **épico a la altura del cierre del juego**: un **Jotunn** — un gigante de hielo nórdico — imponente y con movimiento fluido,
**para** que la pelea final del piso 5 sea memorable.

**Como** equipo de desarrollo,
**quiero** un modelo con **rig humanoide de 10 partes con Motor6D bien puestos**,
**para** animarlo con **Moon Animator** sin adivinar articulaciones (extremidades segmentadas: brazo superior/inferior, pierna superior/inferior).

---

### **Descripción del Requerimiento / Contexto**

**Decisión del PO (2026-09-22):** el diseño del boss final cambia de la **bestia colosal cuadrúpeda** (Dirección C de EST-30) a un **Jotunn nórdico**: un **gigante de hielo humanoide** — el último enemigo del juego. **EST-30 queda sustituida por esta HU.**

El rig es **humanoide con 10 partes** (más articulado que los enemigos actuales, que usan brazo/pierna sólidos) y con **Motor6D correctos** para animar con Moon Animator.

**Criterio de hecho global:** existe el modelo del Jotunn con sus **10 partes** y **Motor6D bien puestos** (pivotes en las articulaciones, C0/C1 correctos), compatible con `EnemyService` (Humanoid + HRP + PrimaryPart, sin scripts) — listo para que el dev lo anime e integre (HU-ESTETICA-31).

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. El modelo (visual) — JOTUNN NÓRDICO (decisión PO 2026-09-22)**

* **Identidad:** un **gigante de hielo nórdico** — el **último enemigo del juego**. Humanoide colosal, no bestia: impone por **presencia** (altura, masa y detalle vikingo), no por forma animal.
* **Escala: ~3–3.5× el jugador** (el más grande del juego).
* **Silueta:** cuerpo humanoide macizo con **piel de hielo** (tonos azul cian translúcido, estilo glaciar), **cuernos/corona de hielo** en la cabeza, **barba de hielo**, **runas `Neon` azul pálido pulsantes** en el torso y los brazos (familia visual EST-18), placas de hielo/cristal en hombros, pectoral y faldar, **núcleo de cristal brillante** en el pecho (punto débil visual), garras y pies de glaciar.
* **Movimiento pesado pero humanoide:** cada paso y golpe debe sentirse en el rig (masa, balanceo del torso).

#### **2. El rig — 10 PARTES con Motor6D (clave para Moon Animator)**

* **Las 10 partes exactas (nombres documentados, estilo R15):**

| # | Parte | Nombre sugerido | Articulaciones (Motor6D) |
|---|-------|-----------------|--------------------------|
| 1 | **Pecho** | `Chest` | Con HRP (cintura), `Head`, `UpperArm` L/R, `UpperLeg` L/R |
| 2 | **Cabeza** | `Head` | Con `Chest` (cuello) |
| 3 | Brazo superior **izq.** | `LeftUpperArm` | Con `Chest` (hombro izq.) y `LeftLowerArm` (codo izq.) |
| 4 | Brazo inferior **izq.** | `LeftLowerArm` | Con `LeftUpperArm` (codo izq.); mano = visual del segmento |
| 5 | Brazo superior **der.** | `RightUpperArm` | Con `Chest` (hombro der.) y `RightLowerArm` (codo der.) |
| 6 | Brazo inferior **der.** | `RightLowerArm` | Con `RightUpperArm` (codo der.); mano = visual del segmento |
| 7 | Pierna superior **izq.** | `LeftUpperLeg` | Con `Chest` (cadera izq.) y `LeftLowerLeg` (rodilla izq.) |
| 8 | Pierna inferior **izq.** | `LeftLowerLeg` | Con `LeftUpperLeg` (rodilla izq.); pie = visual del segmento |
| 9 | Pierna superior **der.** | `RightUpperLeg` | Con `Chest` (cadera der.) y `RightLowerLeg` (rodilla der.) |
| 10 | Pierna inferior **der.** | `RightLowerLeg` | Con `RightUpperLeg` (rodilla der.); pie = visual del segmento |

* **Manos y pies NO son piezas separadas**: son parte visual de los segmentos inferiores (brazo/pierna inferior) — el recuento queda en **10 partes** como pidió el PO.
* **Motor6D bien puestos (obligatorio):**
  * **Pivotes en las articulaciones** (hombro, codo, cadera, rodilla, cuello): la `C0` ancla el origen de la pieza hija al punto de giro correcto de la pieza padre (no al centro de la parte).
  * **C0/C1 correctos** (sin rotaciones raras, sin inversiones de eje; el eje de flexión de codos/rodillas apunta en la dirección correcta para animar).
  * Jerarquía: `HumanoidRootPart` → `Chest` → `Head`/`UpperArm L/R`; `Chest` → `UpperLeg L/R` → `LowerLeg L/R`; `UpperArm L/R` → `LowerArm L/R`.
  * Probar la flexión de cada articulación (doblar codo/rodilla/hombro/cuello/cadera sin deformaciones raras).
* **Tabla de articulaciones entregada** (nombre → pieza → origen C0) para que el dev anime sin adivinar (patrón de entrega de EST-30/31).
* **Compatibilidad EnemyService:** `Humanoid` + `HumanoidRootPart` + `PrimaryPart`, `Anchored=false`, piezas decorativas `CanCollide=false`/`CanTouch=false`/`CanQuery=false`/`Massless=true`, **sin scripts** ni `AnimationController` propio. Familia de animación: **`biped`/humanoide** (como el Señor de la Escarcha — ya no `quadruped`).
* Pesos livianos (sin meshes excesivos; presupuesto de piezas acotado).

#### **3. Entrega**

* `modelId = helada_frostwarden`; ubicación `ReplicatedStorage/Assets/Models/Enemies/helada_frostwarden`.
* Notas de entrega: **tabla de articulaciones** (10 partes + Motor6D) + recomendaciones de animación (qué mover en cada ataque) + registro en `ASSETS_REGISTRY`.
* No duplicar/alterar los modelos existentes.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Jotunn espectacular**

* **GIVEN** el modelo entregado
* **WHEN** se lo mira en la arena
* **THEN** impone presencia (gigante de hielo nórdico humanoide 3–3.5× el jugador, cuernos/barba de hielo, runas, núcleo brillante) y se reconoce al instante como el último enemigo del juego

#### **Escenario 2: 10 partes exactas**

* **GIVEN** el rig del Jotunn
* **WHEN** se cuentan las partes móviles
* **THEN** son exactamente **10**: pecho, cabeza, brazo superior/inferior ×2, pierna superior/inferior ×2 (manos y pies son visuales de los segmentos inferiores)

#### **Escenario 3: Motor6D correctos**

* **GIVEN** el rig
* **WHEN** se dobla cada articulación (hombros, codos, caderas, rodillas, cuello)
* **THEN** pivotea en el punto correcto (C0 anclada a la articulación, sin deformaciones) y la jerarquía HRP→Chest→extremidades es la esperada

#### **Escenario 4: Compatible con el juego**

* **GIVEN** el modelo
* **WHEN** `EnemyService` lo clona (DebugSpawnEnemy)
* **THEN** spawnea con Humanoid/IA (familia humanoide/biped) sin errores rojos

#### **Escenario 5: Listo para animar**

* **GIVEN** la tabla de articulaciones
* **WHEN** el dev abre el modelo en Moon Animator
* **THEN** encuentra las 10 articulaciones nombradas y puede animar torso/cabeza/brazos/piernas por separado

#### **Escenario 6: Entrega válida**

* **GIVEN** la entrega
* **WHEN** se inspecciona
* **THEN** no tiene scripts ni animaciones propias, está registrado y no altera modelos existentes

---

### **Alcance**

#### Incluye

* Modelo del Jotunn (gigante de hielo nórdico, temática hielo/vikingo).
* Rig de **10 partes con Motor6D** (pecho, cabeza, brazos sup/inf ×2, piernas sup/inf ×2) + tabla de articulaciones.
* Registro en ASSETS_REGISTRY.

#### No incluye

* Animaciones (las crea el dev con Moon Animator — HU-ESTETICA-31).
* VFX/efectos de la pelea (dev — HU-ESTETICA-31).
* Scripts, stats, loot ni mecánicas (R7/BossConfig intactos).
* Otros enemigos (EST-02).

---

### **Definition of Done (DoD)**

* [ ] Modelo del Jotunn espectacular (silueta, escala 3–3.5×, hielo/runas) en `Assets/Models/Enemies/helada_frostwarden`.
* [ ] **10 partes exactas** con **Motor6D correctos** (pivotes en las articulaciones, C0/C1 verificados).
* [ ] Tabla de articulaciones (10 piezas, nombre → origen) entregada para Moon Animator.
* [ ] Compatible con EnemyService (spawn sin errores, familia humanoide/biped, sin scripts/animaciones propias).
* [ ] Registrado en ASSETS_REGISTRY; modelos existentes intactos.
* [ ] Aprobación visual del PO (es el último enemigo del juego).
* [ ] Reporte al PM con el detalle y pendientes.

---

### **Estimación (orientativa)**

2–4 sesiones del diseñador: modelado del Jotunn + rig de 10 partes con Motor6D + tabla de articulaciones.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-ESTETICA-36: **Jotunn nórdico** (gigante de hielo) como boss final — **sustituye a EST-30** (bestia cuadrúpeda, Dirección C, descartada por decisión PO); rig humanoide de **10 partes** (pecho, cabeza, brazo sup/inf ×2, pierna sup/inf ×2) con **Motor6D bien puestos** (pivotes en articulaciones, C0/C1 correctos) para Moon Animator; familia de animación humanoide/biped |
| 2026-09-22 | **Nombre canónico (decisión PO):** el boss se llama en juego **"Jotunn, Guardián de la Escarcha"** (`helada_frostwarden`) — se unifica la presentación (boss bar, HUD, matchmaking/info) con este nombre |