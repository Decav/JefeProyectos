# HU-R8d: Balance de números + QA a nivel 20 (cierre del bloque R8)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R8 — 3 clases jugables / R8d (cierre del bloque)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Balance (dev) + QA — solo números en configs; sin mecánicas nuevas
**Fase GDD:** R8 (R8a Paladín ✅ → R8b Cazador ✅ → R8c Clérigo ✅ → **R8d**)
**Depende de:** HU-R8a/b/c (completas), HU-ITEMS-01 (rc034, sets/armas/joyería), HU-R7 (boss piso 5), HU-R6a (enemigos/XP/loot), SKILLS_CATALOG v2.2 (árboles finales)
**No modifica:** mecánicas, framework, VFX, UI ni animaciones

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que las 6 specs sean jugables de punta a punta hasta el nivel 20 con equipamiento conseguible en el juego,
**para** que cada build se sienta distinta y viable (tanque, dps melee/ranged, healer, dps mágico) sin frustración por números rotos.

**Como** equipo de desarrollo,
**quiero** dejar los números de skills, enemigos, ítems, talentos y economía coherentes entre sí (verificados con QA a nivel 20),
**para** cerrar el bloque R8 con el criterio *"las 6 specs se sienten distintas y el arco a 20 funciona"*.

---

### **Descripción del Requerimiento / Contexto**

R8a/b/c ya dejaron **todo jugable**: 30 skills, árboles finales de las 6 specs, VFX por skill, MATKMult, AoE (zona/Self), enemigos de los 5 pisos, boss del piso 5 (R7) y el catálogo de ítems (ITEMS-01). Pero los números actuales son **seed orientativo** sin verificación cruzada: no se sabe si un jugador con la build completa mata al boss en un tiempo razonable, si las pociones escalan, o si cada spec cumple su rol.

Esta HU **balancea y valida**: fija metas numéricas por piso y por spec, ajusta los configs (solo números), y cierra con un **QA a nivel 20** por spec (run completa de los 5 pisos + boss) registrando métricas.

**Criterio de hecho global:** con una build completa a nivel 20, cada spec completa la dungeon (5 pisos + boss) de forma consistente, con TTK/TTD dentro de las bandas objetivo, maná sostenible con pociones, y las 6 specs se sienten distintas.

---

### **Especificaciones Técnicas / Contratos de API (balance)**

#### **1. Metas por piso (tabla objetivo — referencia actual en `EnemyConfig`)**

Enemigos actuales por piso (HP / daño por golpe): P1 lvl 4: 50–60 / 8–10 · P2 lvl 7: 55–90 / 12–14 · P3 lvl 10: 80–120 / 18–20 · P4 lvl 13: 150–200 / 25–28 · P5 lvl 16: 250–300 / 35–38. Mini-bosses: troll 200/18 · golem 350/25 · wraith 500/30 · lord 800/40. Boss R7: stats actuales (rc021) atk 30 / matk 20 / def 12 / mdef 12.

**Metas (bandas; el dev ajusta configs hasta cumplirlas):**

| Piso (nivel) | TTK mob normal | TTK mini-boss | TTD jugador vs mob (golpes aguantados) | Daño pico recibido por golpe |
|--------------|----------------|---------------|----------------------------------------|------------------------------|
| 1 (lvl 4) | 2–4 s | 15–25 s (troll) | ≥ 8 golpes | 8–10 |
| 2 (lvl 7) | 3–5 s | 20–35 s (gólem) | ≥ 8 golpes | 12–15 |
| 3 (lvl 10) | 4–6 s | 30–45 s (espectro) | ≥ 7 golpes | 18–22 |
| 4 (lvl 13) | 5–8 s | 45–60 s (señor) | ≥ 6 golpes | 25–30 |
| 5 (lvl 16) | 6–10 s | — (boss R7: **60–120 s**) | ≥ 5 golpes | 35–40 |

* **Boss R7:** golpe pico = **45–60% del MaxHP** del jugador a lvl 16–20 con gear del piso (fuerza el uso de pociones/curas/escudos); el TTK 60–120 s obliga a usar el ciclo completo de la spec (skills + consumibles + uniques si los hay).
* **Packs** (2–3 enemigos): la suma de daño de un pack completo **no debe** poder matar al jugador en < 4 s si está full HP y usa consumibles (requiere kiting/pociones, no tankear de pie).
* Regla: la **mitigación de DEF/MDEF** existente se respeta (no se cambia la fórmula); las metas se cumplen ajustando daños/HP de enemigos y poder del jugador.

#### **2. Metas de poder del jugador (curva real desde `ClassConfig`)**

Referencias calculadas (sin gear ni talentos): lvl 4 / 8 / 12 / 16 / 20 → Paladín HP 160/220/280/340/400 · ATK 20/28/36/44/52 · DEF 26/38/50/62/74; Cazador HP 133/181/229/277/325 · ATK 26/38/50/62/74 · CRIT 14/18/22/26/30%; Clérigo HP 142/194/246/298/350 · MATK 26/38/50/62/74.

**Metas de equipamiento (power budget):**
* lvl 1–5: un arma de su nivel aporta **+25–35%** del ATK/MATK base (espada aprendiz 6–8, varita 6, arco 7 — ya cumplen; validar).
* lvl 15–16: arma Rare/Epic (campeón 12–17, uniques 25 + 10) aporta **+40–60%** sobre el poder base (los **uniques deben sentirse claramente superiores** a cualquier Rare del mismo nivel).
* **Set completo** (5 piezas + joyería): aporta ~**+15–25% HP y +20–35% DEF/MDEF** vs sin equipo, y el **Cazador/Clérigo** quedan competitivos con el Paladín en su rol.
* **Pociones (gap detectado):** `potion_hp`/`potion_mp` curan **30 fijos** (seed R5) — a lvl 16–20 eso es < 6% del MaxHP: **no escalan**. **Decisión PM:** pasar a **25% del máximo** (HP y MP) con precio de **15 oro** (VendorConfig + LootTables gold se revisan para no romper la economía: ingresos 3–50 por piso vs gastos 15/poción son coherentes). Alternativa descartada por ahora: pociones por tieres (R9 si hace falta).

#### **3. Metas de skills (SKILLS_CATALOG v2.2 — solo números, no mecánicas)**

| Área | Meta | Verificación |
|------|------|--------------|
| Single Instant | DPS del ciclo (auto + skill) mata al mob del piso en el TTK de la tabla | Todos los Instant |
| Burst capstone | Skill profunda = **1.5–2×** el DPS sostenido de la spec (ej. Aniquilación/Disparo mortal vs ciclo básico) | Capstones |
| GroundAoE (zona) | Daño total (8 ticks) ≈ **1.2–1.5×** un single del mismo rol; worth con ≥ 2 objetivos | Consagración, Ira divina |
| SelfAoE | Burst = **1.3–1.5×** una skill single media | Anillo de luz sagrada, Torbellino |
| Heal (Misericordia) | Cura corta = 20–25% MaxHP · media = 30–40% · capstone (Milagro) = **50%+** con CD 20 s | Sanación/Palabra/Milagro |
| Shield | Absorbe **1–2 golpes** del piso actual | Muro sagrado, Escudo de fe |
| Maná | Ciclo básico sostenible: un **pack completo + mob** cuesta ≤ 60–70% del maná total (pociones cubren el resto) | Todas las specs |
| Threat (Protector) | threatMod > 1 funcionando (sin efecto en solo; listo para R9 party) | Protector |

#### **4. Metas de diferenciación de specs (criterio R8: "builds distintas")**

| Spec | Rol | Meta (con build completa lvl 20) |
|------|-----|----------------------------------|
| Protector (Paladín) | Tanque | Sobrevive **1.5–2×** más que los dps; daño ~0.8× de Castigo; ciclo con escudo/voto |
| Castigo (Paladín) | DPS melee mágico | Daño single alto (referencia 1.0×); burst SelfAoE (Anillo) |
| Asalto (Cazador) | DPS melee físico | Daño sostenido ~0.95× Castigo; Torbellino para packs |
| Puntería (Cazador) | DPS ranged | Burst alto (Disparo mortal) con riesgo de posicionamiento; daño ~1.05× |
| Misericordia (Clérigo) | Healer | Daño bajo (~0.5×), pero **sostenimiento infinito**: nunca muere si no se over-extiende (cura > daño recibido en 1v1) |
| Cólera (Clérigo) | DPS mágico ranged | Daño AoE/single mágico ~1.0× con Ira divina para packs |

* Regla de oro: **ninguna spec debe poder matar al boss del piso 5 en < 45 s** con su build completa a lvl 20 (evita que una sola domine).

#### **5. Reglas de ajuste (solo configs)**

* Se cambian **únicamente números** en: `SkillConfig`, `EnemyConfig`, `BossConfig`, `ItemConfig`, `TalentConfig` (si un % queda desalineado), `VendorConfig` (pociones), y `LootTables` si el oro/rareza lo requiere.
* **No** se tocan: mecánicas, SkillType, framework, fórmulas de mitigación, remotes, UI, VFX, animaciones.
* Cada cambio se anota: **SKILLS_CATALOG → v2.3** (números finales) y se registra en la tabla de resultados del RC.
* El **fino final** (balance medio, ajustes por feedback) queda en **R9** — R8d deja números coherentes y verificados, no "perfectos".

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Arco completo por spec (lvl 20, build completa)**

* **GIVEN** las 6 specs con build completa a nivel 20 (equipo del juego, sin debug grants)
* **WHEN** se corre la dungeon completa (pisos 1–5 + boss) por spec
* **THEN** cada spec completa la run (0–2 muertes aceptadas, con consumibles)
* **AND** los TTK por piso caen dentro de las bandas de la tabla del punto 1

#### **Escenario 2: Boss del piso 5**

* **GIVEN** un jugador lvl 16–20 con gear del piso
* **WHEN** pelea al Guardián de la Escarcha
* **THEN** el boss se mata en 60–120 s
* **AND** un golpe pico es 45–60% del MaxHP (fuerza uso de pociones/curas/escudos)
* **AND** ninguna spec lo mata en < 45 s

#### **Escenario 3: Pociones escalan**

* **GIVEN** pociones HP/MP al 25% del máximo
* **WHEN** se usan a lvl 4 y a lvl 20
* **THEN** curan ~25% del MaxHP/MaxMP en ambos niveles (siempre relevantes)
* **AND** el precio (15 oro) y la economía (oro por piso) siguen coherentes

#### **Escenario 4: Skills cumplen metas**

* **GIVEN** las 30 skills
* **WHEN** se mide cada familia (single, burst, zona, SelfAoE, cura, escudo)
* **THEN** cada una cumple su meta de la tabla del punto 3 (daño/eficiencia/cura/absorción)
* **AND** el maná alcanza para un pack + mob con ≤ 60–70% del pool (pociones cubren el resto)

#### **Escenario 5: Specs distintas**

* **GIVEN** las 6 specs a lvl 20
* **WHEN** se comparan (daño, sostenimiento, sobrevivencia)
* **THEN** Protector sobrevive 1.5–2× los dps, Misericordia se sostiene solo en 1v1, y los dps tienen daños relativos según la tabla del punto 4

#### **Escenario 6: Uniques del boss**

* **GIVEN** los 3 uniques (lvl 16)
* **WHEN** se comparan con las armas Rare/Epic del mismo nivel
* **THEN** los uniques aportan +40–60% sobre el poder base y se sienten claramente superiores

#### **Escenario 7: QA sin regresión**

* **GIVEN** el balance aplicado
* **WHEN** se juega el flujo completo (crear PJ → progresar → dungeon → boss → rejoin)
* **THEN** no hay errores rojos
* **AND** los cambios son solo numéricos (ninguna mecánica alterada)

---

### **Comportamiento Visual / Reglas de Negocio**

* Es balance y QA: **no** hay cambios de UI, VFX, mecánicas ni animaciones.
* Todas las métricas se registran (RC + SKILLS_CATALOG v2.3) para que R9 haga el fino sobre datos, no a ciegas.
* Las decisiones de economía (precio de pociones) quedan documentadas como decisión de producto.

---

### **Alcance**

#### Incluye

* Ajuste de números en SkillConfig/EnemyConfig/BossConfig/ItemConfig/TalentConfig/VendorConfig/LootTables según metas.
* Pociones al 25% del máximo (HP/MP) con precio 15 oro.
* QA a nivel 20: run completa por las 6 specs con build conseguible (TTK/TTD/maná/boss/diferenciación).
* Registro de resultados: SKILLS_CATALOG v2.3 + tabla de métricas en el RC.

#### No incluye

* Mecánicas nuevas, SkillTypes, fórmulas de mitigación, framework, remotes.
* UI, VFX, animaciones (bloque EST/visual ya cubierto).
* Balance fino post-feedback (R9).
* Contenido nuevo (skills, ítems, enemigos, talentos) — solo números de lo existente.

---

### **Definition of Done (DoD)**

* [ ] Las 6 specs completan la dungeon (5 pisos + boss) a lvl 20 con build conseguible (0–2 muertes, consumibles).
* [ ] TTK por piso dentro de las bandas objetivo; boss en 60–120 s y sin kills < 45 s.
* [ ] Pociones al 25% del máximo con precio 15; economía verificada.
* [ ] Familias de skills dentro de sus metas (single/burst/zona/SelfAoE/cura/escudo/maná).
* [ ] Diferenciación de specs verificada (sobrevivencia Protector, sostenimiento Misericordia, dps relativos).
* [ ] Uniques claramente superiores a Rare/Epic del mismo nivel.
* [ ] Todos los cambios son numéricos; sin regresión mecánica; sin errores rojos.
* [ ] SKILLS_CATALOG v2.3 actualizado con números finales + tabla de métricas en el RC.
* [ ] Nota `R8d completo` + cierre de R8 en GDD tras la verificación.
* [ ] PROJECT_ARCHITECTURE / DATA_SCHEMA / registro HU/RC actualizados al cerrar.

---

### **Decisiones por defecto R8d**

| Tema | Default |
|------|---------|
| Pociones | 25% del máximo (HP/MP), precio 15 oro (decisión PM) |
| Bandas TTK/TTD | Tabla del punto 1 (mob/mini-boss/boss por piso) |
| Diferenciación | Tabla del punto 4 (rol por spec con metas relativas) |
| Límite boss | TTK 60–120 s; ningún kill < 45 s |
| Alcance | Solo números en configs; fino final en R9 |

---

### **Estimación (orientativa)**

2–3 sesiones del dev: ajuste de números + QA por las 6 specs + registro de métricas.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-18 | Creación de HU-R8d: balance de números + QA a nivel 20 (cierre de R8). Metas por piso (TTK/TTD), poder del jugador (curva ClassConfig + power budget de ítems), familias de skills, diferenciación de specs, pociones al 25% (decisión PM, precio 15) y reglas de ajuste solo numéricas; fino final en R9 |