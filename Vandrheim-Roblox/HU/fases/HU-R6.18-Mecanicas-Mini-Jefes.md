# HU-R6.18: Mecánicas de mini-jefes — Señor de la Escarcha (golpe fuerte + invocar) y Espectro de Ventisca (tifón en cono)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R6.x / Contenido de mini-jefes (dev)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Mecánicas nuevas para mini-jefes (dev, data-driven)
**Fase GDD:** R6.18 (no cambia reglas de solo; balance dentro de bandas R8d)
**Depende de:** HU-R6a (enemigos/mini-bosses), HU-R6.8/R6.9 (VFX/zonas), HU-R6.7 (animaciones por familia — Moon Animator), HU-ESTETICA-31 (patrón de mecánicas del boss final)
**Componentes observados:** `EnemyConfig`/`BossConfig` (minibosses), `EnemyService` (IA), `VFXConfig`, animaciones (Moon Animator)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que los mini-jefes tengan **mecánicas propias** (no solo pegar más fuerte),
**para** que cada pelea sea distinta y más interesante.

---

### **Descripción del Requerimiento / Contexto**

Los mini-jefes hoy solo pegan (melee/ranged). Se agregan mecánicas (decisión PO 2026-09-22):

1. **Señor de la Escarcha** (`miniboss_frost_lord`, piso 4):
   * **Golpe de escarcha:** ataque fuerte telegrafiado (carga visible) que hace **daño adicional** en área frontal/impacto.
   * **Invocar caballeros helados:** invoca `helada_frost_knight` (y/o élite) — **máximo 2 invocados simultáneos**.
2. **Espectro de Ventisca** (`miniboss_blizzard_wraith`, piso 3):
   * **Tifón de escarcha:** ataque en **cono hacia adelante** que daña a **todos los jugadores** dentro del rango del cono (efecto visual de ventisca/tifón).

**Criterio de hecho global:** ambos mini-jefes usan sus mecánicas (data-driven, con telegrafía y VFX), las peleas son distintas y el balance cae dentro de las bandas de R8d.

---

### **Especificaciones Técnicas / Contratos de API**

* **Data-driven (config):** cada mecánica se define en config del mini-jefe:
  * `minibossSkills`: lista de skills del mini-jefe con `skillId`/definición, `cooldown`, `telegraph` (duración de carga), `damage`/params.
  * `summonConfig`: `templateId` (frost_knight/élite), `maxAlive = 2`, `spawnCount`, `cooldown`, `lifetime` si aplica.
  * `coneAttack`: `range`, `angle` (grados), `damage`.
* **Señor de la Escarcha:**
  * **Golpe de escarcha:** cada **9 s fijos** (cooldown fijo — decisión PM 2026-09-22: los cooldowns de mini-jefes son **fijos** dentro del rango indicado para QA determinístico, no aleatorios), con **carga de 1.2 s** (telegrafía visible: cristales/viento acumulándose — el jugador ve venir el golpe) → impacto frontal con **daño = 1.5× el golpe normal (≈60)** y VFX de escarcha. **Rectángulo del área: ancho 8 studs × profundidad 14 studs** (centrado frente al mini-jefe, rojo tenue durante la carga).
  * **Invocar:** cada **22 s fijos**, invoca 1 caballero helado (hasta 2 vivos; si hay 2, no invoca hasta que muera uno). **Los invocados: XP reducida al 25% del valor normal y sin loot** (decisión PM — evita farm sin castigo gratis).
* **Espectro de Ventisca:**
  * **Tifón de escarcha:** cada **10 s fijos**, con **carga de 1.5 s** (viento acumulándose claramente — ventana para anticiparse y esquivar) → **cono frontal** con **rango 25 studs y ángulo 75°** (config) que daña a **todos los jugadores** dentro con **daño = 2× el golpe normal (≈60)**; **cono rojo tenue** dibujado en el suelo durante la carga; VFX de tifón de escarcha.
* **Animaciones (Moon Animator — método estándar):** las animaciones de los ataques se crean con **Moon Animator** (ASSETS_POLICY actualizada 2026-09-22: las animaciones propias son la fuente principal del proyecto — jugador y enemigos; el dev SÍ crea animaciones). **Nota para el dev: sincronizar la copia de ASSETS_POLICY en Workspace.DevelopmentStandard (la local ya está actualizada).**
* **Esquivables por diseño:** ambos ataques cargados son **esquivables** (salir del cono/área frontal durante la carga) — el daño alto se compensa con la ventana de anticipación.
* **Áreas objetivo en el suelo (telegrafía de zona — decisión PO 2026-09-22):** durante la carga, ambos ataques **dibujan el área donde impactarán** sobre el suelo, para que el jugador sepa exactamente dónde:
  * **Tifón de escarcha:** **cono** rojo muy translúcido (tenue) sobre el suelo — muestra rango + ángulo del cono durante la carga (1.5 s).
  * **Golpe de escarcha:** **rectángulo frontal** rojo muy translúcido frente al mini-jefe — muestra el área del impacto durante la carga (1.2 s).
  * Color: rojo tenue/transparente (patrón de telegrafía enemiga; distinto del anillo púrpura del pre-cast del jugador, R6.13). Al disparar, el área parpadea/impacta y desaparece.
* **Telegrafía:** las mecánicas fuertes **siempre** tienen carga visible + área dibujada (el jugador puede esquivar/posicionarse) — patrón del boss final (EST-31).
* **VFX/animaciones:** por config (`animationKey` + VFX id) — animaciones con Moon Animator (método estándar).
* **Balance:** dentro de bandas R8d (TTK mini-jefe según piso); el golpe de escarcha (~1.5×) y el tifón (~2×) son golpes fuertes pero **esquivables**, no one-shot: ~20–25% del MaxHP del jugador del piso (banda R8d de golpes pico 45–60% solo aplica al boss final).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Golpe de escarcha**

* **GIVEN** el Señor de la Escarcha
* **WHEN** pasan su cooldown (y hay telegrafía visible)
* **THEN** durante la carga (1.2 s) se dibuja un **rectángulo frontal rojo tenue** sobre el suelo marcando el área del impacto
* **AND** al impactar, el área parpadea y el golpe aplica el daño con VFX de escarcha (esquivable saliendo del área durante la carga)

#### **Escenario 2: Invocar caballeros**

* **GIVEN** el Señor de la Escarcha en pelea
* **WHEN** pasa su cooldown de invocación
* **THEN** invoca un caballero helado (máximo **2 vivos**; no invoca si ya hay 2)

#### **Escenario 3: Tifón de escarcha**

* **GIVEN** el Espectro de Ventisca
* **WHEN** pasa su cooldown
* **THEN** durante la carga (1.5 s) se dibuja un **cono rojo tenue** sobre el suelo mostrando el área del cono
* **AND** al disparar, el cono daña a todos los jugadores dentro (esquivable saliendo del cono durante la carga)

#### **Escenario 4: Data-driven**

* **GIVEN** las mecánicas implementadas
* **WHEN** se revisan los configs
* **THEN** cooldowns, daños, telegrafías, summon y cono viven en config (sin hardcode)

#### **Escenario 5: Balance y regresión**

* **GIVEN** las mecánicas activas
* **WHEN** se pelean los mini-jefes (pisos 3 y 4)
* **THEN** el TTK/daño caen dentro de las bandas R8d y no hay errores rojos (solo y party)

---

### **Alcance**

#### Incluye

* Golpe de escarcha + invocar caballeros (máx 2) para el Señor de la Escarcha.
* Tifón de escarcha en cono para el Espectro de Ventisca.
* **Áreas objetivo en el suelo durante la carga** (cono rojo tenue para el tifón; rectángulo frontal rojo tenue para el golpe).
* Telegrafías, VFX y animaciones (Moon Animator) por config.
* Verificación dentro de bandas R8d.

#### No incluye

* Mecánicas del boss final (EST-31 ya las cubre; más habilidades en HU futura).
* Cambios a otros enemigos ni al balance global.

---

### **Definition of Done (DoD)**

* [ ] Señor de la Escarcha: golpe de escarcha (carga 1.2 s con **rectángulo frontal rojo tenue**, daño 1.5× ≈60) + invocación de caballeros (máx 2 vivos).
* [ ] Espectro de Ventisca: tifón en cono (carga 1.5 s con **cono rojo tenue**, daño 2× ≈60).
* [ ] Áreas objetivo visibles durante la carga y parpadeo al impactar; esquivables por diseño.
* [ ] Todo data-driven (configs) con animaciones/VFX por id.
* [ ] Bandas R8d cumplidas (solo y party); sin errores rojos.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Estimación (orientativa)**

2–3 sesiones del dev: configs de mecánicas + IA de mini-jefes + VFX/animaciones + balance.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-R6.18: mecánicas de mini-jefes — Señor de la Escarcha (golpe de escarcha telegrafiado + invocar caballeros máx 2) y Espectro de Ventisca (tifón de escarcha en cono); data-driven con telegrafía y VFX |
| 2026-09-22 | **Valores concretos (confirmación PO):** golpe de escarcha con **carga 1.2 s** (daño 1.5× ≈60); **tifón con carga 1.5 s** (daño 2× ≈60) — ambos **esquivables por diseño** durante la carga (ventana de anticipación); ~20–25% MaxHP del jugador del piso; cooldowns 8–10 s y 9–12 s |
| 2026-09-22 | **Áreas objetivo en el suelo (decisión PO):** durante la carga se dibuja el área del ataque — **cono rojo tenue** (tifón) y **rectángulo frontal rojo tenue** (golpe de escarcha) — para que el jugador sepa dónde impactará y pueda esquivar |
| 2026-09-22 | **Decisiones PM (rc061):** cooldowns **fijos** (golpe 9 s · tifón 10 s · invocación 22 s); **cono: rango 25 / ángulo 75°**; **rectángulo: 8×14 studs**; **caballeros invocados: XP 25% y sin loot**; animaciones con **Moon Animator** (método estándar — el dev debe sincronizar ASSETS_POLICY actualizada en Studio) |