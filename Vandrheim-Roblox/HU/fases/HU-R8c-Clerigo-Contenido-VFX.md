## HU-R8c: Clérigo completo — contenido de skills, talentos finales y VFX

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** R8 — 3 clases jugables / R8c (tercera parte)  
**Prioridad:** Crítica  
**Estado:** Lista para implementar  
**Tipo:** Contenido de clase + VFX de skills  
**Fase GDD:** R8 (R8a Paladín → R8b Cazador → R8c Clérigo → R8d balance/assets/QA)  
**Depende de:** HU-R8a (**MATKMult** + estándar de la fase), HU-R8b (mismo patrón), HU-R3 (SkillService), HU-R5.1 (TalentConfig v2), SKILLS_CATALOG v2.2, HU-R6.9 (GroundAoE zona), HU-R6.6 (animationKey)  
**Fuente de diseño:** SKILLS_CATALOG v2.2 — árboles de Misericordia y Cólera aprobados

---

### **Narrativa (INVEST)**

**Como** jugador de Clérigo,  
**quiero** que Misericordia y Cólera tengan sus árboles finales, todas sus skills y sus efectos visuales,  
**para** armar una build de healer (MATK = curas) o de mage burst con zona de castigo.

**Como** equipo,  
**quiero** cerrar la última clase del bloque R8,  
**para** dejar las 6 specs con contenido final antes del balance (R8d).

---

### **Descripción del Requerimiento / Contexto**

Igual que R8a/R8b pero para Clérigo: SkillConfig completo (10 skills), árboles finales de Misericordia y Cólera (aprobados en v2.2), y VFX únicos por skill. Requiere el soporte `MATKMult` (ya agregado en R8a) porque las curas y el daño de Cólera escalan con MATK.

Los números son orientativos (balance fino en R8d/R9); esta HU los deja coherentes y funcionando.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. SkillConfig — Clérigo completo (10 skills)**

Según `SKILLS_CATALOG` v2.2 (IDs, tipos, maná/CD, `animationKey`):

| ID | Tipo | animationKey | Maná | CD |
|----|------|--------------|------|----|
| `cleric_smite` | Instant (MATK) | cast_magic | 10 | 4 |
| `cleric_burning_light` | Instant (MATK) | cast_magic | 15 | 6 |
| `cleric_hol_heal` | Heal | heal | 12 | 4 |
| `cleric_hol_word` | Heal | heal | 18 | 8 |
| `cleric_hol_shield` | Shield | shield_buff | 20 | 15 |
| `cleric_hol_miracle` | Heal | heal | 30 | 20 |
| `cleric_wrath_spear` | Instant (MATK) | cast_magic | 15 | 5 |
| `cleric_wrath_mark` | Instant (MATK) | cast_magic | 20 | 8 |
| `cleric_wrath_divine_ire` | GroundAoE (zona) | cast_aoe | 20 | 12 |
| `cleric_wrath_annihilation` | Instant (MATK) | cast_magic | 30 | 12 |

* Obtención según catálogo: básicas lvl 1; Misericordia: heal 1, word 5; Cólera: spear 1, mark 5; talentos según nodos.
* Ira divina usa la mecánica de zona persistente de R6.9 (por tick 4/0.35, zona 4 s, tick 0.5 s).
* Las curas escalan con MATK (fórmula Heal ya existente en SkillService).

#### **2. TalentConfig — Misericordia (aprobado)**

| Rama | Nodo | Tipo | maxRank | perRank | Gate |
|------|------|------|---------|---------|------|
| Vida | devocion | Passive | 2 | +4% MATK (MATKMult) | lvl 2 |
| Vida | shield | Skill | 1 | — | tier 2 (≥4 pts + lvl 8), prereq devocion |
| Vida | miracle | Skill | 1 | — | capstone (≥8 pts + lvl 16), prereq shield |
| Gracia | oracion | Passive | 2 | +5% MaxMP | lvl 2 |
| Gracia | gracia | Passive | 2 | +2% CDR | tier 2 |
| Gracia | misericordia | Passive | 1 | +8% MATK | capstone |
| Protección | vigor | Passive | 2 | +5% MaxHP | lvl 2 |
| Protección | fe_blindada | Passive | 2 | +4% DEF | tier 2 |
| Protección | aura_proteccion | Passive | 1 | +8% DEF | capstone |

#### **3. TalentConfig — Cólera (aprobado)**

| Rama | Nodo | Tipo | maxRank | perRank | Gate |
|------|------|------|---------|---------|------|
| Ira | colera | Passive | 2 | +4% MATK (MATKMult) | lvl 2 |
| Ira | divine_ire | Skill | 1 | — | tier 2 (≥4 pts + lvl 8), prereq colera |
| Ira | annihilation | Skill | 1 | — | capstone (≥8 pts + lvl 16), prereq divine_ire |
| Castigo | juicio | Passive | 2 | +2% CRIT | lvl 2 |
| Castigo | furia | Passive | 2 | +2% CDR | tier 2 |
| Castigo | furia_sagrada | Passive | 1 | +5% CRIT + 3% CDR | capstone |
| Poder | ardor | Passive | 2 | +5% MaxMP | lvl 2 |
| Poder | poder_divino | Passive | 2 | +3% MATK | tier 2 |
| Poder | castigador | Passive | 1 | +8% MATK | capstone |

#### **4. Builds de referencia (QA en R8d)**

* **Misericordia (healer, 10 pts):** Vida completa (devoción 2 + shield 1 + miracle 1 = 4) + Gracia (oración 2 + gracia 2 = 4) + Vigor 2 → mucho output de cura + mana.
* **Cólera (mage burst, 10 pts):** Ira completa (colera 2 + divine_ire 1 + annihilation 1 = 4) + Castigo (juicio 2 + furia 2 = 4) + Ardor 2 → hasta +15% MATK con zona de castigo.

#### **5. VFX de las skills del Clérigo (partículas reales)**

Config por `skillId` (extensión de `VFXConfig`/`SkillVFXConfig`), client-side con autoridad server:

| Skill | VFX esperado |
|-------|--------------|
| Golpe de fe / Luz ardiente | Impacto de luz blanca/dorada + destello |
| Sanación / Palabra de luz / Milagro | Aura de sanación: partículas doradas ascendentes alrededor del PJ |
| Escudo de fe | Barrera translúcida dorada alrededor del PJ (anillo + brillo) |
| Lanza de luz / Marca de castigo / Aniquilación | Proyectil/rayo de luz + explosión al impactar |
| Ira divina | Zona persistente: círculo de castigo con llamas y partículas por tick |

* Los efectos son client-side; el server solo notifica (hit/cast/zona).
* Texturas/partículas: propias, gratuitas o registradas según `ASSETS_POLICY`.

#### **6. Integración**

* `SkillService`/`TalentService` ya validan gates/ranks/spellbook; el contenido entra por config.
* **Requiere `MATKMult` de R8a** (Misericordia y Cólera lo usan en sus ramas).
* Respec (R5) devuelve puntos y revoca Escudo de fe/Milagro/Ira divina/Aniquilación.
* VFX básico de R6.8 (números de daño y cura, proyectiles, muerte) se reutiliza; esta HU agrega los VFX únicos por skill.
* Iconos de las 10 skills del Clérigo: se generan con Gemini (fondo negro = finales); lista en `ASSETS_LIST`.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Skills completas**

* **GIVEN** un Clérigo
* **WHEN** se revisa su spellbook
* **THEN** tiene las 10 skills con tipos/maná/CD correctos
* **AND** las 4 de talento se aprenden por nodos

#### **Escenario 2: Árbol de Misericordia**

* **GIVEN** una Misericordia
* **WHEN** abre la ventana de talentos
* **THEN** ve las 3 ramas finales (Vida/Gracia/Protección)
* **AND** los gates y prereqs funcionan

#### **Escenario 3: Árbol de Cólera**

* **GIVEN** una Cólera
* **WHEN** abre la ventana de talentos
* **THEN** ve las 3 ramas finales (Ira/Castigo/Poder)
* **AND** los gates y prereqs funcionan

#### **Escenario 4: Curas escalan con MATK**

* **GIVEN** una Misericordia con nodos de MATK (Devoción/Misericordia)
* **WHEN** castea Sanación/Palabra/Milagro
* **THEN** la cura refleja el MATK con talentos
* **AND** se muestra el número de cura (R6.8)

#### **Escenario 5: Escudo de fe**

* **GIVEN** una Misericordia con Escudo de fe aprendido
* **WHEN** lo castea
* **THEN** aplica el escudo (absorb) con su VFX de barrera

#### **Escenario 6: Ira divina zona persistente**

* **GIVEN** una Cólera con Ira divina aprendida
* **WHEN** la lanza a un punto
* **THEN** se crea la zona con ticks de daño (R6.9)
* **AND** muestra el VFX de zona (llamas + partículas)

#### **Escenario 7: MATKMult aplica en Cólera**

* **GIVEN** una Cólera con Ardor/Poder divino/Castigador
* **WHEN** se recalculan stats
* **THEN** su MATK incluye los multiplicadores de talento
* **AND** el daño de sus skills lo refleja

#### **Escenario 8: VFX únicos**

* **GIVEN** las 10 skills del Clérigo
* **WHEN** se castean
* **THEN** cada una muestra su VFX configurado (curas doradas, rayos, zona de castigo)
* **AND** los efectos son client-side y no alteran la cura/daño

#### **Escenario 9: Respec**

* **GIVEN** un Clérigo con puntos gastados
* **WHEN** hace respec
* **THEN** vuelve todo a cero
* **AND** las skills de talento desaparecen del spellbook y la barra

#### **Escenario 10: Sin regresiones**

* **GIVEN** el Clérigo completo
* **WHEN** se juega el loop (skills, dungeon, boss, rejoin)
* **THEN** no hay errores rojos
* **AND** Paladín (R8a) y Cazador (R8b) siguen funcionando

---

### **Alcance**

#### Incluye

* SkillConfig del Clérigo completo (10 skills).
* TalentConfig final de Misericordia y Cólera.
* Uso de `MATKMult` (soporte de R8a) en las ramas que corresponden.
* VFX únicos de las 10 skills (partículas reales).
* Builds de referencia para QA.
* Lista de iconos (Gemini) actualizada para el Clérigo.

#### No incluye

* Contenido de Paladín (R8a) o Cazador (R8b).
* Balance final (R8d) y fino (R9).
* Cambios de framework fuera de lo ya soportado.
* Sonido/SFX (R9).
* Party (R9).

---

### **Definition of Done (DoD)**

* [ ] Las 10 skills del Clérigo existen en `SkillConfig` con tipos/maná/CD/animationKey correctos.
* [ ] Misericordia y Cólera tienen sus árboles finales en `TalentConfig`.
* [ ] Escudo de fe, Milagro, Ira divina y Aniquilación se aprenden por talento.
* [ ] `MATKMult` se aplica en las ramas de MATK (curas y daño reflejan los nodos).
* [ ] Ira divina funciona como zona persistente con ticks (R6.9).
* [ ] Las curas muestran número de cura (R6.8).
* [ ] Las 10 skills tienen su VFX único (partículas) configurado por skill.
* [ ] Los VFX son client-side y no modifican cura/daño ni lógica.
* [ ] Texturas de VFX registradas según ASSETS_POLICY.
* [ ] Respec devuelve todo y revoca las skills de talento.
* [ ] Builds de referencia (Misericordia heal y Cólera burst) juegan bien en Play Solo.
* [ ] Sin errores rojos en skills → talentos → dungeon → boss → rejoin.
* [ ] Nota `R8c completo` en GDD al verificar la implementación.

---

### **Estimación (orientativa)**

3–4 sesiones: SkillConfig + árboles de Misericordia/Cólera + VFX de las 10 skills + QA del Clérigo.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-26 | Creación de HU-R8c: Clérigo completo (Misericordia + Cólera), árboles finales v2.2 y VFX por skill; cierra el bloque de clases de R8 |