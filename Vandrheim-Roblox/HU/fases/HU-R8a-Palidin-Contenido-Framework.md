## HU-R8a: Paladín completo — contenido de skills y talentos finales + soporte MATKMult

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** R8 — 3 clases jugables / R8a (primera parte)  
**Prioridad:** Crítica  
**Estado:** Lista para implementar  
**Tipo:** Contenido de clases + ajuste de framework  
**Fase GDD:** R8 (se ejecuta en 4 HUs: R8a Paladín → R8b Cazador → R8c Clérigo → R8d balance/assets/QA)  
**Depende de:** HU-R3 (SkillService), HU-R5.1 (TalentConfig v2), HU-R5 (respec), SKILLS_CATALOG v2.2 (árboles finales), HU-R6.9 (AoE zona/Self), HU-R6.6 (animationKey)  
**Fuente de diseño:** SKILLS_CATALOG v2.2 — árboles finales de las 6 specs aprobados; esta HU implementa Paladín (Protector + Castigo)

---

### **Narrativa (INVEST)**

**Como** jugador de Paladín,  
**quiero** que mi spec (Protector o Castigo) tenga su árbol de talentos final y todas sus skills funcionando,  
**para** poder armar una build real de tanque o de dps y probar el arco completo hasta nivel 20.

**Como** equipo,  
**quiero** dejar el Paladín 100% jugable primero,  
**para** validar el framework (talentos, gates, skills enseñadas, MATKMult) antes de replicarlo en Cazador y Clérigo.

---

### **Descripción del Requerimiento / Contexto**

El Paladín es la clase base del juego: existe desde R2/R3 con seed de skills, y Protector tiene nodos finales desde R5.1. Falta:

* **Castigo con contenido final** (árbol aprobado en v2.2 + nueva skill SelfAoE `Anillo de luz sagrada`).
* **Protector con árbol formalizado** (nodos y valores finales, no solo el ejemplo).
* **SkillConfig completo del Paladín** (10 skills con `animationKey`, tipos, maná/CD según catálogo).
* **Soporte de `MATKMult`** en el cálculo de talentos (lo requieren Castigo, Misericordia y Cólera).
* Verificación del loop completo: aprender skills por nivel/talento → equiparlas → castearlas → respec.

Los números siguen siendo orientativos para balance fino (R8d/R9); esta HU los deja **coherentes y funcionando**.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Framework: soporte `MATKMult` en talentos**

* `InventoryService.recalculateStats`: aplicar multiplicador de talentos al stat `MATK`, igual que `ATKMult`:

```luau
if talentEffects.MATKMult then
    totalStats.matk = totalStats.matk * (1 + talentEffects.MATKMult)
end
```

* Actualizar `DATA_SCHEMA` (efectos de talento disponibles) y `PROJECT_ARCHITECTURE` (nota del sistema de talentos).
* El resto de multiplicadores ya existe (MaxHPMult, ATKMult, DEFMult, MaxMPMult, CritBonus, CooldownReduction).

#### **2. SkillConfig — Paladín completo (10 skills)**

Según `SKILLS_CATALOG` v2.2 (IDs, tipos, maná/CD, `animationKey`):

| ID | Tipo | animationKey | Maná | CD |
|----|------|--------------|------|----|
| `paladin_holy_strike` | Instant (ATK) | melee_slash | 10 | 4 |
| `paladin_light_verdict` | Instant (MATK) | cast_magic | 15 | 6 |
| `paladin_prot_shield_bash` | Instant (ATK) | melee_slash | 15 | 6 |
| `paladin_prot_vow` | Heal | heal | 20 | 15 |
| `paladin_prot_sacred_wall` | Shield | shield_buff | 20 | 15 |
| `paladin_prot_consecration` | GroundAoE (zona) | cast_aoe | 20 | 12 |
| `paladin_ret_holy_edge` | Instant (ATK) | melee_slash | 15 | 5 |
| `paladin_ret_divine_flames` | Instant (MATK) | cast_magic | 15 | 6 |
| `paladin_ret_sentence` | Instant (MATK) | cast_magic | 20 | 8 |
| `paladin_ret_holy_ring` | SelfAoE | cast_aoe | 25 | 10 |

* La skill nueva `paladin_ret_holy_ring` reemplaza `paladin_ret_execution` (eliminada del catálogo).
* Todos con `levelReq`/obtención según catálogo (básicas lvl 1; Protector: shield_bash 1, vow 5; Castigo: holy_edge 1, divine_flames 5; talentos según nodos).
* Los GroundAoE zona usan la mecánica de R6.9 (`zoneDuration`, `tickInterval`).

#### **3. TalentConfig — Protector (formalizado)**

| Rama | Nodo | Tipo | maxRank | perRank | Gate |
|------|------|------|---------|---------|------|
| Vida/Defensa | fortaleza | Passive | 2 | +5% MaxHP | lvl 2 |
| Vida/Defensa | sacred_wall | Skill | 1 | — | tier 2 (≥4 pts + lvl 8), prereq fortaleza |
| Vida/Defensa | unbreakable_faith | Passive | 1 | +4% CDR | capstone (≥8 pts + lvl 16), prereq sacred_wall |
| Amenaza | devocion | Passive | 2 | +4% ATK | lvl 2 |
| Amenaza | aura_sagrada | Passive | 2 | +2% CRIT | tier 2 (≥4 pts + lvl 8) |
| Amenaza | consagracion | Skill | 1 | — | capstone (≥8 pts + lvl 16), prereq aura_sagrada |
| Utilidad | vigor | Passive | 2 | +5% MaxMP | lvl 2 |
| Utilidad | hierro | Passive | 2 | +4% DEF | tier 2 (≥4 pts + lvl 8) |
| Utilidad | proteccion | Passive | 1 | +8% DEF | capstone (≥8 pts + lvl 16), prereq hierro |

#### **4. TalentConfig — Castigo (nuevo, aprobado)**

| Rama | Nodo | Tipo | maxRank | perRank | Gate |
|------|------|------|---------|---------|------|
| Ataque | fervor | Passive | 2 | +4% ATK | lvl 2 |
| Ataque | sentencia | Skill | 1 | — | tier 2 (≥4 pts + lvl 8), prereq fervor |
| Ataque | holy_ring | Skill | 1 | — | capstone (≥8 pts + lvl 16), prereq sentencia |
| Fuego | ardor_sagrado | Passive | 2 | +4% MATK (MATKMult) | lvl 2 |
| Fuego | llamas_ardientes | Passive | 2 | +2% CRIT | tier 2 |
| Fuego | veredicto_final | Passive | 1 | +5% CRIT + 3% CDR | capstone |
| Vigor | tenacidad | Passive | 2 | +5% MaxHP | lvl 2 |
| Vigor | foco_divino | Passive | 2 | +5% MaxMP | tier 2 |
| Vigor | santuario | Passive | 1 | +8% DEF | capstone |

* El framework existente (spellbook, gates, respec) ya soporta esto; solo falta el contenido.
* `MATKMult` se aplica como cualquier multiplicador de talento (ver punto 1).

#### **5. Builds de referencia (para QA en R8d)**

* **Protector (tank, 10 pts):** Vida/Defensa completa (fortaleza 2 + muro 1 + fe 1 = 4) + Amenaza (devoción 2 + aura 1) + Utilidad (vigor 2 + hierro 1). Resultado: mucho MaxHP/DEF, CDR, escudo y zona de Consagración.
* **Castigo (dps, 10 pts):** Ataque completa (fervor 2 + sentencia 1 + anillo 1 = 4) + Fuego (ardor 2 + llamas 1) + Vigor (tenacidad 2 + foco 1). Resultado: +8% ATK, +8% MATK, SelfAoE y finisher.

#### **5. VFX de las skills del Paladín (partículas reales)**

Cada skill del Paladín debe tener su **efecto visual único** (configurado por skill, data-driven), hecho con las capacidades confirmadas del dev (`ParticleEmitter`, `Beam`, `Trail`, tweens — client-side con autoridad server):

| Skill | VFX esperado |
|-------|--------------|
| Golpe sagrado / Filo sagrado / Embate de escudo | Slash de luz dorada + chispas en el impacto |
| Veredicto de luz / Llamas divinas / Sentencia | Rayo/explosión de luz al impactar |
| Voto protector / Milagro | Aura de sanación (partículas ascendentes doradas) |
| Muro sagrado / Escudo de fe | Barrera translúcida dorada alrededor del PJ |
| Consagración | Zona persistente: círculo de runas + partículas de fuego sagrado en los ticks |
| Anillo de luz sagrada | Onda expansiva de luz dorada (anillo + partículas) |

* Config: extensión de `VFXConfig` (o `SkillVFXConfig`) con un efecto por `skillId` — reemplazable sin tocar código.
* Los efectos son **client-side**; el daño y la lógica siguen en el server (el server solo notifica cuándo ocurren: hit, zona, cast).
* Texturas/partículas: propias, gratuitas o registradas según `ASSETS_POLICY` (registro obligatorio).

#### **6. Integración**

* `SkillService` ya valida gates/ranks/desbloqueos; el contenido nuevo entra por config.
* `TalentService.SendTalentData`/spellbook replican sin cambios.
* `RequestRespec` (R5) sigue funcionando: devuelve puntos y revoca skills de talento (incluida `holy_ring`).
* Icono de la skill nueva: `Icon_Skill_paladin_ret_holy_ring` (lista de assets actualizada; se genera con Gemini — fondo negro final).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: MATKMult aplica**

* **GIVEN** un PJ con talento `ardor_sagrado` rank 1
* **WHEN** se recalculan stats
* **THEN** su MATK incluye el +4% del talento
* **AND** el daño de Llamas divinas/Sentencia refleja el aumento

#### **Escenario 2: Árbol de Castigo visible**

* **GIVEN** un PJ Castigo
* **WHEN** abre la ventana de talentos
* **THEN** ve 3 ramas con los nodos finales
* **AND** los gates/prereqs se muestran correctamente

#### **Escenario 3: Skills enseñadas por talentos**

* **GIVEN** un Castigo
* **WHEN** gasta puntos en `sentencia` (tier 2) y `holy_ring` (capstone)
* **THEN** Sentencia y Anillo de luz sagrada aparecen en el spellbook
* **AND** pueden asignarse a la barra y castearse

#### **Escenario 4: Anillo de luz sagrada (SelfAoE)**

* **GIVEN** un Castigo con `holy_ring` aprendido y en la barra
* **WHEN** la castea con enemigos cercanos
* **THEN** daña a todos los enemigos dentro del radio (6) alrededor del jugador
* **AND** no requiere posicionamiento de suelo

#### **Escenario 5: Protector con árbol formalizado**

* **GIVEN** un Protector
* **WHEN** invierte puntos en el árbol
* **THEN** los nodos finales (fortaleza, muro, fe, devoción, aura, consagración, vigor, hierro, protección) funcionan
* **AND** Consagración es una zona persistente (R6.9)

#### **Escenario 6: Respec**

* **GIVEN** un Paladín con puntos gastados y skills de talento
* **WHEN** hace respec (R5)
* **THEN** vuelve todo a cero
* **AND** las skills de talento desaparecen del spellbook y la barra

#### **Escenario 7: Coherencia de números**

* **GIVEN** el Paladín completo
* **WHEN** se revisa el output/balance básico
* **THEN** los números son coherentes (maná alcanza para la rotación, CDs sensatos)
* **AND** quedan marcados como orientativos (balance fino en R8d/R9)

#### **Escenario 8: Sin regresiones**

* **GIVEN** el contenido nuevo
* **WHEN** se juega el loop completo (skills, talentos, dungeon, boss, rejoin)
* **THEN** no hay errores rojos
* **AND** el resto de clases (Cazador/Clérigo con contenido genérico) sigue funcionando

---

### **Alcance**

#### Incluye

* Soporte `MATKMult` en recalculateStats + docs técnicos.
* SkillConfig del Paladín completo (10 skills, incl. `paladin_ret_holy_ring`).
* TalentConfig final de Protector y Castigo (tablas anteriores).
* Builds de referencia para QA.
* **VFX únicos de las 10 skills del Paladín** (partículas reales, data-driven por skill).
* Icono `Icon_Skill_paladin_ret_holy_ring` en la lista de assets.

#### No incluye

* Contenido de Cazador (R8b) y Clérigo (R8c).
* Balance final de números (R8d) y fino (R9).
* Iconos/animaciones finales (R8d; los iconos se generan por separado).
* Cambios a framework de skills/talentos fuera de `MATKMult`.
* VFX/SFX fuera del Paladín (sonido → R9).
* Party (R9).

---

### **Definition of Done (DoD)**

* [ ] `MATKMult` se aplica y los docs técnicos quedan actualizados.
* [ ] Las 10 skills del Paladín existen en `SkillConfig` con tipos/maná/CD/animationKey correctos.
* [ ] Protector y Castigo tienen sus árboles finales en `TalentConfig`.
* [ ] Sentencia, Anillo de luz sagrada, Muro sagrado, Consagración se aprenden por talento.
* [ ] Anillo de luz sagrada funciona como SelfAoE (radio 6, sin posicionar).
* [ ] Consagración funciona como zona persistente con ticks (R6.9).
* [ ] Los efectos de todos los nodos se aplican a las stats (ATK/MATK/MaxHP/MaxMP/DEF/CRIT/CDR).
* [ ] Las 10 skills del Paladín tienen su VFX único (partículas) configurado por skill.
* [ ] Los VFX son client-side y no modifican daño ni lógica (server-authoritative).
* [ ] Texturas de VFX registradas según ASSETS_POLICY.
* [ ] Respec devuelve todo y revoca las skills de talento.
* [ ] Builds de referencia (Protector tank y Castigo dps) alcanzan ~10 puntos y juegan bien en Play Solo.
* [ ] Sin errores rojos en skills → talentos → dungeon → boss → rejoin.
* [ ] Nota `R8a completo` en GDD al verificar la implementación.

---

### **Estimación (orientativa)**

3–5 sesiones: MATKMult + SkillConfig completo + árboles finales + VFX de las 10 skills + QA del Paladín.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-26 | Creación de HU-R8a: Paladín completo (Protector + Castigo), MATKMult, árboles finales v2.2; primer slice de R8 |
| 2026-08-26 | **VFX únicos de las 10 skills del Paladín** integrados a R8a (partículas reales por skill; cada clase lleva sus efectos en su HU) |