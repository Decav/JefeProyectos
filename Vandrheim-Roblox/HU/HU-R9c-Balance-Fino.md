# HU-R9c: Balance fino — ajustes post-playtest y QA final de la demo (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R9 — Demo estable / Balance (tercera parte)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Balance fino (dev) — solo números en configs, sobre datos de QA y playtest
**Fase GDD:** R9 (posterior a R8d implementado y al playtest publicado con amigos)
**Depende de:** HU-R8d (balance base implementado), HU-PUBLICAR-01/02 (playtest publicado), HU-R9a (party — números de dificultad grupal), HU-R9b (polish)
**No modifica:** mecánicas, framework ni contenido (solo números)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que los números finales se sientan justos tras jugar: sin specs rotas, sin enemigos injustos y con el boss desafiante pero ganable,
**para** que la demo sea estable y se pueda invitar a más gente sin vergüenza.

**Como** equipo,
**quiero** afinar el balance con datos reales (QA a nivel 20 + feedback del playtest con amigos) dentro de tolerancias acotadas,
**para** cerrar R9 con el criterio *demo estable*.

---

### **Descripción del Requerimiento / Contexto**

R8d dejó el balance **coherente y verificado** (bandas TTK/TTD por piso, power budget, familias de skills, diferenciación de specs, pociones al 25%). R9a agrega el party (dificultad grupal). El playtest publicado (HU-PUBLICAR-01, con amigos) genera el **feedback real**. Esta HU:

1. Recoge métricas de QA a nivel 20 y feedback del playtest (éxitos, frustraciones, tiempos).
2. Aplica **ajustes finos** (solo números, tolerancias ±10–15% por ajuste) en SkillConfig/EnemyConfig/BossConfig/ItemConfig/TalentConfig/VendorConfig/LootTables.
3. Verifica las bandas de R8d siguen cumpliéndose y cierra con un **QA final de demo** (solo + party).

**Criterio de hecho global:** tras los ajustes, el juego a nivel 20 (solo y en party) se siente justo y consistente, sin regresiones de las bandas de R8d, y se declara **demo estable**.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Entrada de datos (fuentes)**

* **QA R8d** (métricas registradas: TTK/TTD por piso, boss, maná, diferenciación).
* **Playtest publicado** (HU-PUBLICAR-01): reportes del PO y amigos — qué se sintió fácil/difícil/roto.
* **Métricas de party** (R9a): dificultad grupal (packs 5+, escalado ×1.5/×2/×2.5).
* Cada ajuste se registra: qué, por qué, fuente (QA/feedback), valor antes → después.

#### **2. Reglas de ajuste fino (solo números)**

* Tolerancia por ajuste: **±10–15%** del valor base (si un número necesita más, se revisa con el PM antes).
* Solo configs: SkillConfig, EnemyConfig, BossConfig, ItemConfig, TalentConfig, VendorConfig, LootTables, DungeonConfig (dificultad de party).
* No se cambian: mecánicas, SkillTypes, fórmulas, remotes, UI.
* Cada cambio verifica que las **bandas de R8d** siguen cumpliéndose (TTK/TTD por piso, boss 60–120 s, maná ≤60–70% pool, cura/escudo, diferenciación de specs).

#### **3. Áreas probables de ajuste (según feedback)**

* **Specs:** si una spec domina o se queda corta (dps relativos, sostenimiento de Misericordia, sobrevivencia de Protector en party).
* **Boss R7:** TTK/golpes pico (45–60% MaxHP) y claridad de sus mecánicas.
* **Economía:** oro por piso vs precios (pociones 15, gear por rareza) — que el jugador pueda progresar sin grind excesivo.
* **Dificultad de party (R9a):** calibrar los factores ×1.5/×2/×2.5 con datos reales.
* **Pociones y consumibles:** 25% del máximo — validar que no sean ni irrelevantes ni rotas.

#### **4. QA final de demo (checklist)**

* **Solo:** las 6 specs a nivel 20 con build conseguible completan la dungeon (bandas R8d).
* **Party:** 2–4 jugadores completan la dungeon compartida (dificultad justa, threat funcional).
* **Boss:** 60–120 s, ganable con consumibles, sin kills < 45 s.
* **Regresión completa:** crear PJ → progresar → dungeon → boss → rejoin (PC y móvil, publicado con amigos).
* **Resultado:** nota "R9 completo — demo estable" en el GDD.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Ajustes con fuente**

* **GIVEN** un ajuste de número
* **WHEN** se aplica
* **THEN** tiene fuente (QA/feedback), razón y valores antes → después registrados
* **AND** el cambio está dentro de ±10–15% (o aprobado por el PM)

#### **Escenario 2: Bandas R8d intactas**

* **GIVEN** los ajustes finos
* **WHEN** se miden los pisos, el boss y el maná
* **THEN** las bandas de R8d se cumplen (TTK/TTD, boss 60–120 s, maná, cura/escudo, diferenciación)

#### **Escenario 3: Feedback aplicado**

* **GIVEN** el playtest con amigos
* **WHEN** hay frustraciones claras (spec débil, boss injusto, grind)
* **THEN** se ajustan los números correspondientes y se verifica la mejora

#### **Escenario 4: Demo estable**

* **GIVEN** el QA final
* **WHEN** se juega solo y en party de punta a punta (publicado)
* **THEN** no hay errores rojos, nada se siente roto y el criterio demo estable se cumple
* **AND** se registra `R9 completo` en el GDD

---

### **Comportamiento Visual / Reglas de Negocio**

* Solo números; el resto del juego no cambia.
* Cada ajuste es rastreable (tabla de cambios en el RC + SKILLS_CATALOG si afecta skills).
* El fino es la última capa sobre R8d: no se reinventa el balance, se pule.

---

### **Alcance**

#### Incluye

* Recopilación de métricas/feedback (QA + playtest publicado).
* Ajustes finos por config (con registro antes → después y fuente).
* Calibración de dificultad de party (R9a).
* QA final de demo (solo + party, PC y móvil, publicado) y cierre de R9.

#### No incluye

* Mecánicas, framework, contenido o UI nuevas.
* Rebalanceo masivo (si un sistema está roto de verdad, es HU propia antes).
* Nuevas specs/clases/skills/ítems.

---

### **Definition of Done (DoD)**

* [ ] Ajustes finos aplicados con fuente, razón y antes → después (dentro de tolerancias).
* [ ] Bandas de R8d verificadas tras los ajustes (solo y party).
* [ ] Dificultad de party calibrada con datos reales.
* [ ] QA final: 6 specs solo + party 2–4 completan la dungeon; boss en banda.
* [ ] Sin errores rojos en el flujo completo publicado.
* [ ] `R9 completo — demo estable` registrado en el GDD.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).

---

### **Decisiones por defecto R9c**

| Tema | Default |
|------|---------|
| Tolerancia | ±10–15% por ajuste (más = aprobar con PM) |
| Fuentes | QA R8d + feedback del playtest publicado + métricas de party |
| Dificultad party | Calibrar ×1.5/×2/×2.5 con datos |
| Registro | Tabla antes → después con fuente en el RC |

---

### **Estimación (orientativa)**

2–3 sesiones del dev: recopilar datos + ajustes + QA final solo/party + cierre.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-R9c: balance fino post-playtest — ajustes numéricos con fuente y tolerancias (±10–15%), verificación de bandas R8d (solo y party), QA final de demo y cierre de R9 |