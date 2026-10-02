## HU-R8b: Cazador completo — contenido de skills, talentos finales y VFX

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** R8 — 3 clases jugables / R8b (segunda parte)  
**Prioridad:** Crítica  
**Estado:** Lista para implementar  
**Tipo:** Contenido de clase + VFX de skills  
**Fase GDD:** R8 (R8a Paladín → R8b Cazador → R8c Clérigo → R8d balance/assets/QA)  
**Depende de:** HU-R8a (framework/estándar de la fase: SkillConfig, árboles, VFX por skill), HU-R3 (SkillService), HU-R5.1 (TalentConfig v2), SKILLS_CATALOG v2.2, HU-R6.9 (SelfAoE), HU-R6.6 (animationKey)  
**Fuente de diseño:** SKILLS_CATALOG v2.2 — árboles de Asalto y Puntería aprobados

---

### **Narrativa (INVEST)**

**Como** jugador de Cazador,  
**quiero** que Asalto y Puntería tengan sus árboles finales, todas sus skills y sus efectos visuales,  
**para** armar una build melee (SelfAoE con Torbellino) o ranged single-target de verdad.

**Como** equipo,  
**quiero** replicar el estándar de R8a en el Cazador,  
**para** que la clase quede 100% jugable con sus dos specs diferenciadas.

---

### **Descripción del Requerimiento / Contexto**

Igual que R8a pero para Cazador: SkillConfig completo (10 skills), árboles finales de Asalto y Puntería (aprobados en v2.2), y VFX únicos por skill con partículas reales (confirmado). No requiere cambios de framework: Cazador usa ATK/CRIT/CDR/MaxHP/MaxMP/DEF (todos soportados desde R8a).

Los números son orientativos (balance fino en R8d/R9); esta HU los deja coherentes y funcionando.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. SkillConfig — Cazador completo (10 skills)**

Según `SKILLS_CATALOG` v2.2 (IDs, tipos, maná/CD, `animationKey`):

| ID | Tipo | animationKey | Maná | CD |
|----|------|--------------|------|----|
| `hunter_savage_cut` | Instant (ATK) | melee_slash | 10 | 4 |
| `hunter_piercing_shot` | Instant (ATK) | ranged_shot | 15 | 6 |
| `hunter_asm_ambush` | Instant (ATK) | melee_slash | 15 | 5 |
| `hunter_asm_crimson` | Instant (ATK) | melee_slash | 20 | 8 |
| `hunter_asm_twin` | Instant (ATK) | melee_slash | 15 | 4 |
| `hunter_asm_whirlwind` | SelfAoE | cast_aoe | 30 | 15 |
| `hunter_mm_heavy_arrow` | Instant (ATK) | ranged_shot | 15 | 6 |
| `hunter_mm_trueshot` | Instant (ATK) | ranged_shot | 20 | 8 |
| `hunter_mm_chain` | Instant (ATK) | ranged_shot | 12 | 4 |
| `hunter_mm_death` | Instant (ATK) | ranged_shot | 30 | 12 |

* Obtención según catálogo: básicas lvl 1; Asalto: ambush 1, crimson 5; Puntería: heavy_arrow 1, trueshot 5; talentos según nodos.
* Torbellino usa la mecánica SelfAoE de R6.9 (radio 8, sin posicionar).

#### **2. TalentConfig — Asalto (aprobado)**

| Rama | Nodo | Tipo | maxRank | perRank | Gate |
|------|------|------|---------|---------|------|
| Ataque | furia | Passive | 2 | +4% ATK | lvl 2 |
| Ataque | twin | Skill | 1 | — | tier 2 (≥4 pts + lvl 8), prereq furia |
| Ataque | whirlwind | Skill | 1 | — | capstone (≥8 pts + lvl 16), prereq twin |
| Sangre | sangre_fria | Passive | 2 | +5% MaxHP | lvl 2 |
| Sangre | voluntad | Passive | 2 | +5% MaxMP | tier 2 |
| Sangre | piel_bestia | Passive | 1 | +8% DEF | capstone |
| Instinto | instinto | Passive | 2 | +2% CRIT | lvl 2 |
| Instinto | reflejos | Passive | 2 | +2% CDR | tier 2 |
| Instinto | implacable | Passive | 1 | +5% CRIT + 3% CDR | capstone |

#### **3. TalentConfig — Puntería (aprobado)**

| Rama | Nodo | Tipo | maxRank | perRank | Gate |
|------|------|------|---------|---------|------|
| Precisión | punteria | Passive | 2 | +4% ATK | lvl 2 |
| Precisión | chain | Skill | 1 | — | tier 2 (≥4 pts + lvl 8), prereq punteria |
| Precisión | death | Skill | 1 | — | capstone (≥8 pts + lvl 16), prereq chain |
| Caza | resistencia | Passive | 2 | +5% MaxHP | lvl 2 |
| Caza | flechas_guerra | Passive | 2 | +3% ATK | tier 2 |
| Caza | cazador_elite | Passive | 1 | +8% ATK | capstone |
| Táctica | ojo_certero | Passive | 2 | +2% CRIT | lvl 2 |
| Táctica | concentracion | Passive | 2 | +2% CDR | tier 2 |
| Táctica | tiro_perfecto | Passive | 1 | +5% CRIT + 3% CDR | capstone |

#### **4. Builds de referencia (QA en R8d)**

* **Asalto (melee, 10 pts):** Ataque completa (furia 2 + twin 1 + whirlwind 1 = 4) + Instinto (2+2) + 2 sobrantes → ritmo alto con SelfAoE.
* **Puntería (ranged single-target, 10 pts):** Precisión completa (4) + Caza (resistencia 2 + flechas 2 = 4) + 2 sobrantes → hasta +15% ATK.

#### **5. VFX de las skills del Cazador (partículas reales)**

Config por `skillId` (extensión de `VFXConfig`/`SkillVFXConfig`), client-side con autoridad server:

| Skill | VFX esperado |
|-------|--------------|
| Corte salvaje / Emboscada / Filo carmesí / Cortes gemelos | Slash de acero con estela de velocidad (2–3 líneas de corte) + chispas al impactar |
| Disparo perforante / Flecha pesada / Tiro certero / Tiro en cadena / Disparo mortal | Flecha con `Trail`/`Beam` hasta el objetivo + impacto de astillas |
| Torbellino | Anillo de viento/hojas de acero alrededor del jugador (partículas circulares + línea de barrido) |

* Los efectos son client-side; el server solo notifica (hit/cast/impacto).
* Texturas/partículas: propias, gratuitas o registradas según `ASSETS_POLICY`.

#### **6. Integración**

* `SkillService`/`TalentService` ya validan gates/ranks/spellbook; el contenido entra por config.
* Respec (R5) devuelve puntos y revoca Cortes gemelos/Torbellino/Tiro en cadena/Disparo mortal.
* VFX básico de R6.8 (números de daño, proyectiles, muerte) se reutiliza; esta HU agrega los VFX únicos por skill.
* Iconos de las 10 skills del Cazador: se generan con Gemini (fondo negro = finales); lista en `ASSETS_LIST`.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Skills completas**

* **GIVEN** un Cazador
* **WHEN** se revisa su spellbook
* **THEN** tiene las 10 skills con tipos/maná/CD correctos
* **AND** las 4 de talento se aprenden por nodos

#### **Escenario 2: Árbol de Asalto**

* **GIVEN** un Asalto
* **WHEN** abre la ventana de talentos
* **THEN** ve las 3 ramas finales (Ataque/Sangre/Instinto)
* **AND** los gates y prereqs funcionan

#### **Escenario 3: Árbol de Puntería**

* **GIVEN** un Puntería
* **WHEN** abre la ventana de talentos
* **THEN** ve las 3 ramas finales (Precisión/Caza/Táctica)
* **AND** los gates y prereqs funcionan

#### **Escenario 4: Torbellino (SelfAoE)**

* **GIVEN** un Asalto con Torbellino aprendido y en la barra
* **WHEN** lo castea con enemigos cercanos
* **THEN** daña a todos dentro del radio 8 alrededor del jugador
* **AND** no requiere posicionamiento

#### **Escenario 5: Puntería single-target**

* **GIVEN** un Puntería con build ofensiva (Precisión + Caza)
* **WHEN** combate a un enemigo
* **THEN** su daño single-target es viable (ATK alto) sin depender de AoE

#### **Escenario 6: VFX únicos**

* **GIVEN** las 10 skills del Cazador
* **WHEN** se castean
* **THEN** cada una muestra su VFX configurado (slashes, flechas con estela, anillo de Torbellino)
* **AND** los efectos son client-side y no alteran el daño

#### **Escenario 7: Respec**

* **GIVEN** un Cazador con puntos gastados
* **WHEN** hace respec
* **THEN** vuelve todo a cero
* **AND** las skills de talento desaparecen del spellbook y la barra

#### **Escenario 8: Sin regresiones**

* **GIVEN** el Cazador completo
* **WHEN** se juega el loop (skills, dungeon, boss, rejoin)
* **THEN** no hay errores rojos
* **AND** Paladín (R8a) y Clérigo (genérico) siguen funcionando

---

### **Alcance**

#### Incluye

* SkillConfig del Cazador completo (10 skills).
* TalentConfig final de Asalto y Puntería.
* VFX únicos de las 10 skills (partículas reales).
* Builds de referencia para QA.
* Lista de iconos (Gemini) actualizada para el Cazador.

#### No incluye

* Contenido de Paladín (R8a) o Clérigo (R8c).
* Balance final (R8d) y fino (R9).
* Cambios de framework fuera de lo ya soportado (no requiere MATKMult).
* Sonido/SFX (R9).
* Party (R9).

---

### **Definition of Done (DoD)**

* [ ] Las 10 skills del Cazador existen en `SkillConfig` con tipos/maná/CD/animationKey correctos.
* [ ] Asalto y Puntería tienen sus árboles finales en `TalentConfig`.
* [ ] Cortes gemelos, Torbellino, Tiro en cadena y Disparo mortal se aprenden por talento.
* [ ] Torbellino funciona como SelfAoE (radio 8, sin posicionar).
* [ ] Los efectos de todos los nodos se aplican a las stats.
* [ ] Las 10 skills tienen su VFX único (partículas) configurado por skill.
* [ ] Los VFX son client-side y no modifican daño ni lógica.
* [ ] Texturas de VFX registradas según ASSETS_POLICY.
* [ ] Respec devuelve todo y revoca las skills de talento.
* [ ] Builds de referencia (Asalto melee y Puntería single-target) juegan bien en Play Solo.
* [ ] Sin errores rojos en skills → talentos → dungeon → boss → rejoin.
* [ ] Nota `R8b completo` en GDD al verificar la implementación.

---

### **Estimación (orientativa)**

3–4 sesiones: SkillConfig + árboles de Asalto/Puntería + VFX de las 10 skills + QA del Cazador.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-26 | Creación de HU-R8b: Cazador completo (Asalto + Puntería), árboles finales v2.2 y VFX por skill |