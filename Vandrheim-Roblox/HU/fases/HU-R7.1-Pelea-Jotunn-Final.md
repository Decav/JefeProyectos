# HU-R7.1: Pelea final del Jotunn (boss piso 5) — 3 habilidades con posicionamiento

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Mazmorra / Boss final / Pelea
**Prioridad:** **CRÍTICA** (es la pelea del último enemigo del juego)
**Estado:** Lista para implementar (RC obligatorio del dev antes de programar)
**Fase GDD:** R7.1 (extiende la pelea de `helada_frostwarden`; no cambia loot/cofre de R7)
**Depende de:** HU-ESTETICA-36 (modelo Jotunn), HU-ESTETICA-31 (integración dev: animaciones Moon Animator + VFX), HU-R7 (boss `helada_frostwarden`, ai `boss_melee`, `glacial_impact`), HU-R6.18 (telegraphs — áreas rojas, cargas 1.2/1.5 s), HU-R8d (bandas de balance nivel 20)
**Componentes observados:** `BossConfig`/`EnemyConfig` (`helada_frostwarden`), sistema de telegraphs R6.18, framework de animaciones R6.7

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** una **pelea final de 3 habilidades** que recompense el **posicionamiento** (mover al jefe, girarlo y retirarse),
**para** que la pelea contra el Jotunn sea memorable, distinta a los mini-jefes y jugable en grupo (party 1–4).

---

### **Descripción del Requerimiento / Contexto**

Diseño de pelea cerrado con el PO (2026-09-22). El **Jotunn** (`helada_frostwarden`, piso 5) pasa de su ataque único (`glacial_impact`) a una **rotación de 3 habilidades** con telegraphs visibles (patrón R6.18). Tema central: **el tank posiciona al jefe** (zona segura + orientación), los demás esquivan áreas.

**Criterio de hecho global:** el Jotunn rota las 3 habilidades con sus tiempos/telegraphs correctos, el tank puede reposicionarlo (la pelea se resuelve moviéndolo), los charcos y empujes crean las jugadas diseñadas, y no hay errores rojos en party (1–4) ni en solo.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. H1 — ESCOMBRO HELADO (charco en el piso)**

* **Target:** la persona que el jefe está atacando (aggro actual → el tank normalmente).
* **Telegraph:** **círculo rojo grande** sobre el objetivo (1 s).
* **Impacto:** cae un **escombro helado**; deja un **charco de daño relativamente grande** en el piso (radio ~8 studs), **30 s de duración**, daño por tick (~8–10 daño/s — banda R8d; números iniciales a validar en QA).
* **CD: 15 s** → el jefe puede tener **hasta 2 charcos simultáneos**.
* **Jugada:** el tank mueve al jefe a una **zona segura** cada cierto tiempo para no pararse en los charcos.

#### **2. H2 — AVALANCHA FRONTAL (empuje + sinergia)**

* **Telegraph:** **rectángulo rojo frente al jefe** (~8×14 studs, patrón R6.18).
* **Casteo: 1,5 s.** Daño fuerte **~60** + **empuje hacia adelante**.
* **CD: ~10 s.**
* **Jugada:** el **tank orienta al jefe** (la avalancha gira con la cara): no debe empujar al party **hacia un charco helado**; los DPS esquivan a los lados (no atrás del rectángulo).

#### **3. H3 — RUGIDO CONGELANTE (AoE + ralentización)**

* **Telegraph:** **círculo rojo grande centrado en el jefe** (radio ~20 studs).
* **Casteo: 1,5 s** (confirmado PO — igual que los mini-jefes; ventana suficiente para salir del radio a velocidad base).
* **Impacto:** daño en área ~45 + aplica **"Congelado"** (ralentiza ~50 % por 4 s — sin root).
* **CD: ~24 s** (el castigo pesado; marca el ritmo de re-posicionamiento).
* **Jugada:** los **melee salen del círculo**; los ranged se mantienen a rango; castigo por amontonarse con el tank.

#### **4. Rotación, animaciones y coreografía**

* Rotación base: **Escombro (15 s) → Avalancha (10 s) → Rugido (24 s)**, intercalando **auto-ataques básicos** (`boss_melee` + `glacial_impact` existente).
* **2 VARIANTES DE ATAQUE BÁSICO (decisión PO):** el Jotunn tiene **2 animaciones/golpes de ataque básico distintos** que se eligen **al azar entre sí** en cada auto-ataque — para que sus golpes normales no sean siempre los mismos. **Solo aplica a los ataques básicos**; las **3 habilidades tienen su propia animación** (una por habilidad).
* **PLACEHOLDER DE ANIMACIÓN POR ATAQUE (decisión PO):** cada ataque deja su **placeholder de animación** (mientras el animador completa las finales con Moon Animator — EST-31): **1 placeholder por habilidad** (Escombro, Avalancha, Rugido) **+ 1 por cada variante de básico** (2). El sistema usa los placeholders hasta que existan las animaciones finales (sin romper la pelea).
* Un ritmo típico: charco → el tank reposiciona · avalancha (girar la cara) · rugido (salir del cuerpo a cuerpo) → repetir en zona nueva.
* **Sin invocaciones** (distinción del mini-boss espectro R6.18 — la pelea es 100 % posicionamiento).
* Telegraphs SIEMPRE visibles antes del golpe (áreas rojas en el piso + VFX/animaciones de wind-up — EST-31).

#### **5. Config**

* Los 3 ataques en `BossConfig`/`EnemyConfig` (`helada_frostwarden`), patrones de telegraph del framework R6.18.
* Daños/duraciones/times en config (ajustables sin código para QA de R8d/R9c).
* **5 slots de animación config-driven** (escombro, avalancha, rugido, básico A, básico B): si falta una, se usa el **fallback autorizado** (placeholder/wind-up genérico del framework) hasta que el animador entregue la final (EST-31) — reemplazo sin tocar código.

#### **5.1 Decisiones PM cerradas (2026-09-22, respuestas al dev)**

| # | Tema | Decisión |
|---|------|----------|
| 1 | **H1 tick** | **Cada 1 s**, **8 daño/tick (8 DPS)** — charco completo (30 s) ≈ 240 evitables |
| 2 | **H2 empuje** | **~15 studs en 0,4 s** (impulso corto; puede empujarte a un charco si estás mal posicionado, no cruza la arena) |
| 3 | **H3 slow** | **50 % por 4 s, SIN apilar** (una sola aplicación); si recibe el rugido congelado → **se renueva el temporizador a 4 s completos** |
| 4 | **Rotación** | **Por cooldown** (cada habilidad se lanza al salir de CD; H1 siempre sobre el aggro actual) — no es secuencia estricta; el ritmo natural reproduce la coreografía y el tank no memoriza un guion rígido |
| 5 | **H2 dirección** | **Fija al INICIO del casteo** (al aparecer el rectángulo) — el área NO sigue la cara durante los 1,5 s (telegraph confiable; el tank gira al jefe ANTES del casteo) |
| 6 | **Animaciones** | **Fallback autorizado**: 5 slots config-driven; faltante → placeholder/wind-up genérico hasta la final del animador (EST-31) |

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Escombro helado**

* **GIVEN** un jugador con aggro
* **WHEN** el Jotunn lanza Escombro
* **THEN** el círculo rojo aparece sobre él 1 s antes, cae el escombro y queda el charco (radio ~8, 30 s, daño por tick) — CD 15 s y **máx 2 charcos simultáneos**

#### **Escenario 2: Avalancha**

* **GIVEN** la cara del Jotunn apuntando a X
* **WHEN** lanza Avalancha (rectángulo rojo 1,5 s)
* **THEN** daño ~60 + empuje hacia adelante en el área — si el tank la gira, el empuje no alcanza al party

#### **Escenario 3: Rugido congelante**

* **GIVEN** el Jotunn
* **WHEN** lanza Rugido (círculo rojo centrado, radio ~20, **1,5 s de casteo**)
* **THEN** daño ~45 en el área + **Congelado** (slow ~50 % por 4 s); los melee que salieron no lo reciben

#### **Escenario 4: Reposicionamiento**

* **GIVEN** los charcos en el piso
* **WHEN** el tank mueve al jefe a una zona segura
* **THEN** la pelea se desarrolla donde está el jefe (el resto del party lo sigue / los charcos quedan atrás)

#### **Escenario 4b: Variantes de básico**

* **GIVEN** los auto-ataques del Jotunn
* **WHEN** se observan varios golpes básicos seguidos
* **THEN** las **2 variantes de ataque básico alternan al azar** (no se ve siempre el mismo golpe)

#### **Escenario 4c: Placeholders**

* **GIVEN** cada ataque del Jotunn (3 habilidades + 2 básicos)
* **WHEN** no existe aún la animación final
* **THEN** se usa su **placeholder de animación propio** (1 por habilidad + 1 por variante de básico) y la pelea funciona sin errores

#### **Escenario 5: Party 1–4**

* **GIVEN** la pelea en party (2–4) y en solo (1)
* **WHEN** se juega el flujo completo
* **THEN** es jugable en ambos (el aggro del escombro va al tank en party; en solo va al jugador) sin errores rojos

#### **Escenario 6: Regresión**

* **GIVEN** la pelea implementada
* **WHEN** se completa la run del piso 5
* **THEN** el cofre, los uniques y el resto del loot siguen funcionando (R7/ITEMS-04 intactos)

---

### **Alcance**

#### Incluye

* Los 3 ataques del Jotunn (telegraphs, tiempos, daños, charco, empuje, slow, CDs) en config.
* Rotación/coreografía integrada con `boss_melee`/`glacial_impact` existentes.
* VFX/animaciones de wind-up por parte de EST-31 (dev) — referenciado.

#### No incluye

* Loot/cofre/uniques (R7/ITEMS-04 intactos), balance final fino (R8d/QEA — validar números iniciales), ni invocaciones de esbirros.

---

### **Definition of Done (DoD)**

* [ ] Jotunn rota las 3 habilidades con telegraphs visibles y tiempos correctos (1 s escombro · 1,5 s avalancha y rugido).
* [ ] Charco helado: radio ~8, 30 s, tick daño, CD 15 s, máx 2 simultáneos.
* [ ] Avalancha: daño + empuje orientado a la cara del jefe; Rugido: daño + Congelado (slow 50 %/4 s, radio 20).
* [ ] **2 variantes de ataque básico que alternan al azar** (solo básicos; las habilidades tienen animación propia).
* [ ] **Placeholder de animación por ataque**: 1 por habilidad (Escombro/Avalancha/Rugido) + 1 por variante de básico — la pelea funciona con los placeholders hasta las animaciones finales (EST-31).
* [ ] El tank puede reposicionar y orientar al jefe (jugable en solo y party 1–4).
* [ ] Sin errores rojos; cofre/uniques/loot intactos (regresión).
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Decisiones cerradas (PO 2026-09-22)**

| Tema | Decisión |
|------|----------|
| H1 Escombro | Telegraph círculo rojo sobre aggro (1 s) → charco radio ~8, **30 s**, tick ~8–10/s; **CD 15 s → máx 2 charcos** |
| H2 Avalancha | Rectángulo frente al jefe (1,5 s) → daño ~60 + **empuje**; CD ~10 s |
| H3 Rugido | Círculo centrado radio ~20 (**1,5 s de casteo**) → daño ~45 + **Congelado** (slow 50 %/4 s); CD ~24 s |
| Formato | 100 % posicionamiento: **sin invocaciones**; telegraphs siempre visibles |
| Valores | Daños iniciales en banda R8d — validar en QA (R9c) |

---

### **Estimación (orientativa)**

2–3 sesiones del dev: 3 ataques en config + telegraphs + VFX básicos (EST-31 cubre animaciones) + regresión.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-R7.1: pelea final del Jotunn — **3 habilidades** (Escombro helado: charco 30 s/CD 15 s/máx 2 · Avalancha frontal: daño + empuje/CD 10 s · Rugido congelante: AoE radio 20 con casteo **1,5 s** + slow/CD 24 s); rotación de posicionamiento (el tank reposiciona y orienta al jefe); sin invocaciones; valores en banda R8d a validar en QA |
| 2026-09-22 | **Añadido (decisión PO):** **2 variantes de ataque básico aleatorias** (solo básicos — las habilidades tienen animación propia) + **placeholder de animación por ataque** (1 por habilidad + 1 por variante de básico) hasta las animaciones finales del animador (EST-31) |
| 2026-09-22 | **6 decisiones PM cerradas (§5.1, respuestas al dev):** H1 tick 1 s / 8 DPS · H2 empuje ~15 studs en 0,4 s · H3 slow 50 %/4 s sin apilar con renovación a 4 s · rotación por cooldown (no estricta) · H2 dirección fija al inicio del casteo · fallback de animación autorizado (5 slots config-driven) |