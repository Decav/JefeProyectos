# Vandrheim — Catálogo de Skills (diseño MVP — v2)

> Documento de diseño canónico para skills. Complementa GDD §4 (clases/specs), §5 (combate) y §6 (progresión).
> Última actualización: 2026-08-26 — **v2.2: árboles de talentos finales de las 6 specs (R8)**
> Estado: **Borrador de diseño** — números orientativos; balance final en R8.

---

## 1. Reglas generales (v2)

1. **2 skills básicas por clase** (nivel 1, ambas specs) + **4 skills por spec**:
   * **2 aprendidas por nivel** (default: lvl 1 y lvl 5 — la de lvl 1 se usa al elegir la spec).
   * **2 aprendidas por talento** (nodos del árbol: 1 medio + 1 profundo/capstone).
   * → **6 skills por spec activa** (2 básicas + 4 de spec); **30 skills en total** (3 clases × 10).
2. **Barra de 4 slots** + **ventana de habilidades (spellbook)**: todas las skills aprendidas, desde ahí se asignan a la barra (loadout).
3. **Spec única activa** (GDD §4): solo básicas + skills de su spec. No mezclar specs.
4. **SkillType MVP:** `Instant`, `GroundAoE`, `SelfAoE`, `Heal`, `Shield` en contenido; framework soporta además `HealAoE` y `Buff` (contenido puede agregarlos en R8).
5. **AoE — dos mecánicas (v2.1, HU-R6.9):**
   * **`GroundAoE` = zona persistente:** se lanza a un punto del suelo (elegido por el jugador, ≤ `maxCastRange`) y la zona **permanece** durante `zoneDuration`; aplica **daño por tick** (`tickInterval`) a los enemigos dentro (incluidos los que entran después). `damageBase`/`coefficient` son **por tick** (total = por tick × ticks).
   * **`SelfAoE` = alrededor del jugador:** sin elegir punto; el centro es el jugador al momento del cast y golpea **una vez** (burst) a los enemigos dentro de `aoeRadius`.
   * El maná y el cooldown se descuentan **una sola vez** al lanzar (no por tick).
6. **Cada skill:** coste de maná + cooldown; daño/cura server-side; cast en movimiento.
7. **Afinidad de arma:** bonus, no hard-lock.
8. **`threatMod`** en config desde día 1 (Protector > 1); sin efecto en solo; activo en party (R9).

---

## 2. Cómo se aprende cada skill

| Capa | Cómo se obtiene | Cantidad |
|------|-----------------|----------|
| Básica de clase | Automática al crear el PJ (lvl 1) | 2 por clase |
| Nivel (spec) | Automática al subir a lvl 1 y lvl 5 (default) | 2 por spec |
| Talento (spec) | Nodo del árbol de talentos (1 medio + 1 profundo) | 2 por spec |

* Al aprender una skill por talento, aparece en la **ventana de habilidades** y se puede asignar a la barra.
* Respec (R5/R5.1): devuelve puntos y **revoca las skills de talento** (hay que volver a tomarlas).
* Level-gated: se mantienen aprendidas para siempre (no se revocan).

---

## 3. Catálogo (v2 — 30 skills)

Columnas: `tipo`, `stat`, `rango/radio`, `maná`, `CD`, `nivel/obtención`, `params (base/coef)`, `threat`.

### 3.1 Paladín — Básicas

| ID | Nombre | Tipo | Stat | Rango | Maná | CD | Obtención | Params | Threat |
|----|--------|------|------|-------|------|----|-----------|--------|--------|
| `paladin_holy_strike` | Golpe sagrado | Instant | ATK | 12 | 10 | 4 | lvl 1 | 12/1.0 | 1 |
| `paladin_light_verdict` | Veredicto de luz | Instant | MATK | 15 | 15 | 6 | lvl 1 | 15/1.1 | 1 |

### 3.2 Paladín — Protector (tank 1H+escudo)

| ID | Nombre | Tipo | Stat | Rango | Maná | CD | Obtención | Params | Threat |
|----|--------|------|------|-------|------|----|-----------|--------|--------|
| `paladin_prot_shield_bash` | Embate de escudo | Instant | ATK | 12 | 15 | 6 | lvl 1 | 14/1.0 | 3 |
| `paladin_prot_vow` | Voto protector | Heal | — | self | 20 | 15 | lvl 5 | 25+1.2×MATK | 2 |
| `paladin_prot_sacred_wall` | Muro sagrado | Shield | — | self | 20 | 15 | **talento (rama Vida/Defensa, tier 2)** | absorb 30+1.5×MATK, 8 s | 2 |
| `paladin_prot_consecration` | Consagración | GroundAoE (zona) | MATK | r8/cast≤20 | 20 | 12 | **talento (rama Amenaza, profundo)** | por tick 6/0.45 · zona 4 s · tick 0.5 s (8 ticks) | 3 |

### 3.3 Paladín — Castigo (2H/1H melee mágico)

| ID | Nombre | Tipo | Stat | Rango | Maná | CD | Obtención | Params | Threat |
|----|--------|------|------|-------|------|----|-----------|--------|--------|
| `paladin_ret_holy_edge` | Filo sagrado | Instant | ATK | 12 | 15 | 5 | lvl 1 | 14/1.1 | 1 |
| `paladin_ret_divine_flames` | Llamas divinas | Instant | MATK | 12 | 15 | 6 | lvl 5 | 16/1.2 | 1 |
| `paladin_ret_sentence` | Sentencia | Instant | MATK | 12 | 20 | 8 | **talento (rama Ataque, tier 2)** | 24/1.3 | 1 |
| `paladin_ret_holy_ring` | Anillo de luz sagrada | SelfAoE | MATK | r6 (alrededor del jugador) | 25 | 10 | **talento (rama Ataque, profunda)** | burst 20/0.9 | 1 |

### 3.4 Cazador — Básicas

| ID | Nombre | Tipo | Stat | Rango | Maná | CD | Obtención | Params | Threat |
|----|--------|------|------|-------|------|----|-----------|--------|--------|
| `hunter_savage_cut` | Corte salvaje | Instant | ATK | 12 | 10 | 4 | lvl 1 | 12/1.0 | 1 |
| `hunter_piercing_shot` | Disparo perforante | Instant | ATK | 25 | 15 | 6 | lvl 1 | 15/1.1 | 1 |

### 3.5 Cazador — Asalto (melee físico)

| ID | Nombre | Tipo | Stat | Rango | Maná | CD | Obtención | Params | Threat |
|----|--------|------|------|-------|------|----|-----------|--------|--------|
| `hunter_asm_ambush` | Emboscada | Instant | ATK | 12 | 15 | 5 | lvl 1 | 14/1.1 | 1 |
| `hunter_asm_crimson` | Filo carmesí | Instant | ATK | 12 | 20 | 8 | lvl 5 | 26/1.3 | 1 |
| `hunter_asm_twin` | Cortes gemelos | Instant | ATK | 12 | 15 | 4 | **talento (rama Ataque, tier 2)** | 10/0.9 | 1 |
| `hunter_asm_whirlwind` | Torbellino | SelfAoE | ATK | r8 (alrededor del jugador) | 30 | 15 | **talento (rama Ataque, profundo)** | burst 30/1.2 | 1 |

### 3.6 Cazador — Puntería (ranged físico)

| ID | Nombre | Tipo | Stat | Rango | Maná | CD | Obtención | Params | Threat |
|----|--------|------|------|-------|------|----|-----------|--------|--------|
| `hunter_mm_heavy_arrow` | Flecha pesada | Instant | ATK | 25 | 15 | 6 | lvl 1 | 16/1.2 | 1 |
| `hunter_mm_trueshot` | Tiro certero | Instant | ATK | 30 | 20 | 8 | lvl 5 | 28/1.3 | 1 |
| `hunter_mm_chain` | Tiro en cadena | Instant | ATK | 20 | 12 | 4 | **talento (rama Precisión, tier 2)** | 10/0.9 | 1 |
| `hunter_mm_death` | Disparo mortal | Instant | ATK | 30 | 30 | 12 | **talento (rama Precisión, profundo)** | 50/1.6 | 1 |

### 3.7 Clérigo — Básicas

| ID | Nombre | Tipo | Stat | Rango | Maná | CD | Obtención | Params | Threat |
|----|--------|------|------|-------|------|----|-----------|--------|--------|
| `cleric_smite` | Golpe de fe | Instant | MATK | 15 | 10 | 4 | lvl 1 | 12/1.0 | 1 |
| `cleric_burning_light` | Luz ardiente | Instant | MATK | 20 | 15 | 6 | lvl 1 | 15/1.1 | 1 |

### 3.8 Clérigo — Misericordia (heal)

| ID | Nombre | Tipo | Stat | Rango | Maná | CD | Obtención | Params | Threat |
|----|--------|------|------|-------|------|----|-----------|--------|--------|
| `cleric_hol_heal` | Sanación | Heal | — | self | 12 | 4 | lvl 1 | 20+1.2×MATK | 0 |
| `cleric_hol_word` | Palabra de luz | Heal | — | self | 18 | 8 | lvl 5 | 35+1.5×MATK | 0 |
| `cleric_hol_shield` | Escudo de fe | Shield | — | self | 20 | 15 | **talento (rama Vida, tier 2)** | absorb 30+1.2×MATK, 8 s | 0 |
| `cleric_hol_miracle` | Milagro | Heal | — | self | 30 | 20 | **talento (rama Vida, profundo)** | 80+2.0×MATK | 0 |

### 3.9 Clérigo — Cólera (ranged mágico)

| ID | Nombre | Tipo | Stat | Rango | Maná | CD | Obtención | Params | Threat |
|----|--------|------|------|-------|------|----|-----------|--------|--------|
| `cleric_wrath_spear` | Lanza de luz | Instant | MATK | 20 | 15 | 5 | lvl 1 | 14/1.1 | 1 |
| `cleric_wrath_mark` | Marca de castigo | Instant | MATK | 25 | 20 | 8 | lvl 5 | 26/1.3 | 1 |
| `cleric_wrath_divine_ire` | Ira divina | GroundAoE (zona) | MATK | r8/cast≤20 | 20 | 12 | **talento (rama Ira, tier 2)** | por tick 4/0.35 · zona 4 s · tick 0.5 s (8 ticks) | 1 |
| `cleric_wrath_annihilation` | Aniquilación | Instant | MATK | 25 | 30 | 12 | **talento (rama Ira, profundo)** | 50/1.6 | 1 |

---

## 4. Árbol de talentos (WoW-like — HU-R5.1)

### Estructura (por spec)

* **3 ramas** × ~3 nodos (nodo 1 → nodo 2 → capstone).
* **Prerequisitos directos:** para un nodo se necesita el anterior de la rama con ≥1 rank.
* **Gates:** tier 2 exige ≥4 puntos en el árbol **y** nivel ≥ 8; capstone exige ≥8 puntos **y** nivel ≥ 16.
* **Ranks:** maxRank 2 (nodos 1 y 2); **capstone rank 1**.
* **Nodos tipo:** `Passive` (efectos de stats) o `Skill` (enseña la skill de talento).
* **Presupuesto:** ~10 puntos a lvl 20 (1 cada 2 niveles) — alcanza una rama completa (5) + media rama (4) + 1.

### Nodos que enseñan skills (por spec)

| Spec | Skill tier 2 (rama) | Skill profunda (rama) |
|------|---------------------|-----------------------|
| Protector | Muro sagrado (Vida/Defensa) | Consagración (Amenaza) |
| Castigo | Sentencia (Ataque) | Anillo de luz sagrada (Ataque, SelfAoE) |
| Asalto | Cortes gemelos (Ataque) | Torbellino (Ataque) |
| Puntería | Tiro en cadena (Precisión) | Disparo mortal (Precisión) |
| Misericordia | Escudo de fe (Vida) | Milagro (Vida) |
| Cólera | Ira divina (Ira) | Aniquilación (Ira) |

### Ejemplo de ramas (Paladín Protector — contenido final de referencia)

* **Vida/Defensa:** Fortaleza (+MaxHP) → Muro sagrado (**skill**, tier 2) → Fe inquebrantable (CDR, capstone).
* **Amenaza:** Devoción (+ATK) → Aura sagrada (+threat) → Consagración (**skill**, capstone).
* **Utilidad:** Vigor (+MaxMP) → Hierro (+DEF) → Protección (+DEF adicional, capstone).

> Contenido final de nodos solo para Paladín Protector en R5.1 (default); resto de specs con nodos genéricos hasta R8.

### Nodos finales por spec (v2.2 — aprobados para R8)

Convención: rama → Nodo1 → Nodo2 → Capstone. Tier 2 exige ≥4 puntos + lvl 8; capstone ≥8 puntos + lvl 16. MaxRank 2 (capstone 1). Efectos por rank.

**Paladín — Protector:**

| Rama | Nodo1 | Nodo2 | Capstone |
|------|-------|-------|----------|
| Vida/Defensa | Fortaleza (+5% MaxHP) | **Muro sagrado** (Skill Shield) | Fe inquebrantable (+4% CDR) |
| Amenaza | Devoción (+4% ATK) | Aura sagrada (+2% CRIT) | **Consagración** (Skill GroundAoE zona) |
| Utilidad | Vigor (+5% MaxMP) | Hierro (+4% DEF) | Protección (+8% DEF) |

**Paladín — Castigo:**

| Rama | Nodo1 | Nodo2 | Capstone |
|------|-------|-------|----------|
| Ataque | Fervor (+4% ATK) | **Sentencia** (Skill Instant MATK) | **Anillo de luz sagrada** (Skill SelfAoE) |
| Fuego | Ardor sagrado (+4% MATK) | Llamas ardientes (+2% CRIT) | Veredicto final (+5% CRIT + 3% CDR) |
| Vigor | Tenacidad (+5% MaxHP) | Foco divino (+5% MaxMP) | Santuario (+8% DEF) |

**Cazador — Asalto:**

| Rama | Nodo1 | Nodo2 | Capstone |
|------|-------|-------|----------|
| Ataque | Furia (+4% ATK) | **Cortes gemelos** (Skill Instant ATK) | **Torbellino** (Skill SelfAoE) |
| Sangre | Sangre fría (+5% MaxHP) | Voluntad de cazador (+5% MaxMP) | Piel de bestia (+8% DEF) |
| Instinto | Instinto (+2% CRIT) | Reflejos (+2% CDR) | Cazador implacable (+5% CRIT + 3% CDR) |

**Cazador — Puntería:**

| Rama | Nodo1 | Nodo2 | Capstone |
|------|-------|-------|----------|
| Precisión | Puntería (+4% ATK) | **Tiro en cadena** (Skill Instant ATK) | **Disparo mortal** (Skill Instant ATK) |
| Caza | Resistencia (+5% MaxHP) | Flechas de guerra (+3% ATK) | Cazador de élite (+8% ATK) |
| Táctica | Ojo certero (+2% CRIT) | Concentración (+2% CDR) | Tiro perfecto (+5% CRIT + 3% CDR) |

**Clérigo — Misericordia:**

| Rama | Nodo1 | Nodo2 | Capstone |
|------|-------|-------|----------|
| Vida | Devoción (+4% MATK) | **Escudo de fe** (Skill Shield) | **Milagro** (Skill Heal) |
| Gracia | Oración (+5% MaxMP) | Gracia (+2% CDR) | Misericordia (+8% MATK) |
| Protección | Vigor (+5% MaxHP) | Fe blindada (+4% DEF) | Aura de protección (+8% DEF) |

**Clérigo — Cólera:**

| Rama | Nodo1 | Nodo2 | Capstone |
|------|-------|-------|----------|
| Ira | Cólera (+4% MATK) | **Ira divina** (Skill GroundAoE zona) | **Aniquilación** (Skill Instant MATK) |
| Castigo | Juicio (+2% CRIT) | Furia (+2% CDR) | Furia sagrada (+5% CRIT + 3% CDR) |
| Poder | Ardor (+5% MaxMP) | Poder divino (+3% MATK) | Castigador (+8% MATK) |

* Nodos `Skill` enseñan la habilidad (tier 2 = media, capstone = profunda) según la tabla de nodos de skills.
* Todos los efectos usan stats soportadas por el framework: ATK, **MATK** (agregado en R8a), MaxHP, MaxMP, DEF, CRIT, CDR.

---

## 5. Ventana de habilidades (spellbook)

* Muestra todas las skills **aprendidas**: básicas + spec (nivel + talento).
* Permite asignarlas a los **4 slots de la barra** (loadout) y desasignar.
* Las skills de talento aparecen al aprenderlas (respec las revoca).
* No hay límite de "conocidas": solo la barra limita lo equipable en el momento.

---

## 6. Impacto por fase

| Fase | Uso del catálogo |
|------|------------------|
| R3 | Seed (ya implementado): básicas + spec level-gated lvl 1 |
| R5.1 | Framework de árbol + ventana de habilidades + revocación por respec |
| R6a/b | Sin dependencia directa (corre en paralelo) |
| R8 | Contenido completo: nodos finales por spec + balance de números |

---

## 7. Defaults cerrados (registro)

| Tema | Default |
|------|---------|
| Cantidad | 2 básicas/clase + 4/spec (2 nivel: lvl 1 y 5; 2 talento) = 30 total |
| Árbol | 3 ramas × ~3 nodos; prereqs + puntos (4/8) + nivel (8/16) |
| Ranks | 2 (capstone 1) |
| Puntos | 1 cada 2 niveles (~10 a lvl 20) |
| Nodos skill | 1 tier 2 + 1 profundo por spec |
| Tipos en contenido | Instant, GroundAoE (zona persistente DoT), SelfAoE, Heal, Shield (HealAoE/Buff listos en framework) |
| Números | Borrador orientativo; balance final R8 |
| Naming | IDs `clase_spec_nombre` snake_case inglés; display español |

---

## 8. Historial

| Fecha | Cambio |
|-------|--------|
| 2026-08-12 | Creación del catálogo v1 (42 skills, 6/spec, curva 1–16) |
| 2026-08-12 | **v2:** modelo 2 básicas + 2 nivel + 2 talento (30 skills); árbol WoW 3 ramas; ventana de habilidades |
| 2026-08-26 | **v2.1:** GroundAoE = zona persistente con daño por tick; SelfAoE = burst alrededor del jugador (HU-R6.9); Torbellino → SelfAoE, Consagración e Ira divina → zona |
| 2026-08-26 | **v2.2:** Castigo: Ejecución divina → **Anillo de luz sagrada** (SelfAoE); árboles de talentos finales de las 6 specs aprobados (R8) |