## HU-R3: Skill framework (4 slots, maná/CD, AoE suelo)

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** Combate / Skills / R3  
**Prioridad:** Crítica  
**Estado:** Completada (implementada; reporte equipo 2026-08-12)  
**Fase GDD:** R3  
**Depende de:** HU-R2 (PJ activo con clase + stats base), HU-R1 (targeting + auto-attack server)

---

### **Narrativa (INVEST)**

**Como** jugador,  
**quiero** equipar skills en una barra de 4 y castearlas (incluida una AoE de suelo) con costos de maná y cooldowns,  
**para** sentir progresión de combate y validar el framework server-side antes de specs, talentos y mazmorra.

---

### **Descripción del Requerimiento / Contexto**

Fase R3 del GDD (§5 Combate, §6 Progresión, §12 Servicios, §14 Plan). Introduce `SkillService` server-authoritative **data-driven**: skills definidas en config (no hardcode), barra de 4 slots configurable, maná + cooldown, y al menos un skill de tipo AoE de suelo como prueba del framework.

**Criterio de hecho global GDD:** "Skills data-driven".

---

### **Especificaciones Técnicas / Contratos de API**

#### **SkillConfig (ReplicatedStorage/Config — data-driven)**

```luau
{
  ["paladin_smite"] = {
    name = "Golpe sagrado",
    classId = "Paladin",          -- "Paladin" | "Hunter" | "Cleric"
    iconId = "rbxassetid://...",
    type = "Instant",             -- "Instant" | "GroundAoE" | "Heal" | "HealAoE" | "Shield" | "Buff"
    stat = "ATK",                 -- "ATK" | "MATK"
    cooldown = 4,                 -- segundos
    manaCost = 10,
    damageBase = 12,
    coefficient = 1.2,            -- daño = damageBase + coefficient * stat
    range = 12,                   -- studs (Instant); GroundAoE usa maxCastRange
    aoeRadius = nil,              -- solo GroundAoE (ej. 8 studs)
    maxCastRange = nil,           -- solo GroundAoE: distancia máx. centro AoE (ej. 20)
    levelReq = 1,
    description = "..."
  },
  -- ...
}
```

**Campos por tipo:** `Heal`/`HealAoE` → `healBase`, `healCoeff`; `Shield` → `shieldBase`, `shieldCoeff`, `duration`; `Buff` → `buffStat`, `buffValue`, `duration`; `GroundAoE`/`HealAoE` → `aoeRadius`, `maxCastRange`. Todas → `levelReq`.

#### **Remotes / intenciones**

| Remote | Dir | Payload | Validación server |
|--------|-----|---------|-------------------|
| `RequestCastSkill` | C→S | `{ skillId, targetId?, position? }` | skill en loadout del jugador, CD listo, maná suficiente, rango válido. `Instant`: targetId = enemigo válido en rango (o target actual server-side). `GroundAoE`: position validada a ≤ maxCastRange del personaje |
| `CastRejected` | S→C | `{ skillId, reason }` | Feedback UI ("Sin maná" / "En recarga" / "Fuera de rango") |
| `AoeCastVisual` | S→C | `{ skillId, position, radius }` | Efecto visual mínimo del AoE |

#### **SkillService (server)**

* Cast validate → ejecución: consume maná, inicia CD (server clock), aplica daño.
* Daño: `damage = skill.damageBase + skill.coefficient * playerStats[skill.stat]`; reutiliza `ApplyDamage` del dummy (R1) sobre enemigos validados.
* `GroundAoE`: daño **instantáneo** a todos los `Enemy` en `aoeRadius` alrededor de la posición validada (sin zona persistente/DoT en R3).
* Maná: attribute server (0..MaxMP de clase, R2); **regen base 5 MP/s**; clamps.
* CD por jugador × skill; auto-attack (R1) no comparte CD con skills.

#### **Loadout**

* Profile (R2) agrega `loadout = { skillId x4 }` (4 slots, persistido).
* Default al crear PJ: 4 skills de la clase pre-cargadas.
* UI: click en slot → lista de skills desbloqueadas de la clase → asignar.
* Skills desbloqueadas = `levelReq <= nivel` del PJ (en R3 todas levelReq 1).

#### **HUD**

* Barra de 4 skills (abajo centro): icono, overlay de CD (radial/número), coste de maná; teclas 1–4 + touch móvil.
* Barra de maná junto al HP (R1/R2).
* Seleccionar skill GroundAoE → cursor/modo AoE de suelo.

#### **Seed de skills R3 (desde SKILLS_CATALOG.md)**

* Catálogo completo: `SKILLS_CATALOG.md` — 42 skills (2 básicas/clase + 6/spec), curva 1, 3, 5, 8, 12, 16.
* Disponibles en R3: **básicas + skills de la spec activa por defecto (Spec A)**, con `levelReq` respetado.
* Lvl 1 = 2 básicas + spec#1 (3 skills; un slot de la barra queda vacío — se completa en lvl 3).
* QA de todos los skillType (AoE/Shield/Heal/Buff en lvls 3–16): **debug level flag** (server, solo Studio/test) para fijar el nivel de test — no es feature de jugador.
* Números = borrador orientativo; balance final en R8.

#### **Seguridad**

* Server valida: skill en loadout, CD, maná, rango, target/posición. Cliente no puede castear gratis ni dañar sin validación.
* Posición AoE: nunca confiar en posición del cliente fuera del rango máx. del personaje.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Barra de skills visible**

* **GIVEN** el jugador entra al hub con PJ activo
* **WHEN** mira el HUD
* **THEN** ve la barra de 4 skills pre-cargadas de su clase
* **AND** cada skill muestra icono y coste de maná

#### **Escenario 2: Cast Instant con target**

* **GIVEN** un skill Instant equipado, maná y CD listos, target enemigo en rango
* **WHEN** pulsa tecla/clic del slot
* **THEN** el server aplica daño al target
* **AND** el maná baja según coste
* **AND** el CD se inicia y se ve en el overlay

#### **Escenario 3: Sin maná**

* **GIVEN** MP < coste del skill
* **WHEN** intenta castear
* **THEN** el cast se rechaza
* **AND** la UI muestra feedback ("Sin maná")
* **AND** no se aplica daño

#### **Escenario 4: En cooldown**

* **GIVEN** el skill está en CD
* **WHEN** intenta castear de nuevo
* **THEN** el cast se rechaza
* **AND** la UI muestra feedback ("En recarga")

#### **Escenario 5: AoE de suelo**

* **GIVEN** un skill GroundAoE equipado
* **WHEN** hace click en una posición del suelo dentro de maxCastRange
* **THEN** el server aplica daño a todos los enemigos dentro del radio
* **AND** se ve el visual del AoE (S→C)
* **AND** consume maná y entra en CD

#### **Escenario 6: Fuera de rango**

* **GIVEN** skill Instant con target a mayor distancia que `range` (o posición AoE > maxCastRange)
* **WHEN** intenta castear
* **THEN** el cast se rechaza con feedback ("Fuera de rango")

#### **Escenario 7: Regen de maná**

* **GIVEN** MP < MaxMP
* **WHEN** transcurre tiempo
* **THEN** el MP sube ~5/s (server)
* **AND** el HUD muestra HP y MP actualizados

#### **Escenario 8: Loadout configurable y persistente**

* **GIVEN** skills desbloqueadas de su clase
* **WHEN** reasigna skills en los 4 slots
* **THEN** el cast usa la nueva asignación
* **AND** tras rejoin el loadout persiste

#### **Escenario 9: Coexistencia con auto-attack**

* **GIVEN** el dummy R1 en el hub
* **WHEN** combina auto-attack + skills
* **THEN** ambos aplican daño correctamente y el dummy muere

#### **Escenario 10: Anti-exploit y estabilidad**

* **GIVEN** un cliente intenta castear saltando CD/maná/rango/posición
* **WHEN** solo manipula estado local
* **THEN** el server rechaza todo cast inválido
* **AND** el loop castear → matar dummy → respawn no produce errores rojos

---

### **Comportamiento Visual e Interfaz (UI/UX) / Reglas de Negocio**

* **Barra 4 skills:** abajo centro, teclas 1–4, touch para móvil; CD como overlay radial o número.
* **Modo AoE:** al tener equipada una GroundAoE y activarla, se muestra cursor/zona de suelo (no castea hasta click en suelo).
* **Feedback de rechazo:** mensaje corto + flash (sin maná / recarga / rango).
* **Castear en movimiento:** permitido (GDD: skills mientras te movés); sin cast bar en R3 (instantáneo).
* **Sin heal/buffs en R3:** solo daño Instant + GroundAoE.

---

### **Alcance**

#### Incluye

* SkillConfig data-driven en ReplicatedStorage/Config (seed desde `SKILLS_CATALOG.md`)
* SkillService server: cast, CD, maná, daño con stats de clase
* Barra de 4 slots configurable + persistencia en profile
* Tipos del catálogo implementados en el framework (Instant, GroundAoE, Heal, HealAoE, Shield, Buff)
* HUD: skill bar + mana bar + overlays de CD
* Regen de maná base
* Feedback de rechazos
* Compatibilidad con auto-attack/dummy R1 y stats R2

#### No incluye

* Specs activas / talentos / respec (R5)
* Contenido real de skills por spec / desbloqueo por nivel (R8)
* Heal, buffs, debuffs, DoT, zonas persistentes, cast bars/channeled
* GCD estricto (GDD solo define maná + cooldown por skill)
* Skills que consuman recursos secundarios (energía, etc.)
* Inventario/equip afectando ATK/MATK (R4; la fórmula ya queda parametrizada)
* Dungeon / teleport (R6)

---

### **Definition of Done (DoD)**

* [ ] Play Solo: matar dummy usando auto-attack + skills
* [ ] 4 slots asignables desde UI; loadout persiste tras rejoin
* [ ] Sin maná no castea; en CD no castea; fuera de rango no castea
* [ ] Maná consume y regenera (~5/s); HUD muestra HP/MP
* [ ] AoE suelo daña a todos los enemigos en radio (server)
* [ ] Cliente no puede saltar CD/maná/rango/posición
* [ ] Sin errores rojos en loop de cast
* [ ] Nota "R3 completo" en GDD al cerrar QA
* [ ] HU guardada; RC derivado con RC-TEMPLATE antes de implementar

---

### **Checklist Studio (referencia dev)**

* [ ] `SkillConfig` en ReplicatedStorage/Config + seed 4 skills/clase (1 AoE)
* [ ] `SkillService` (server): validate cast, CD, maná, fórmula daño
* [ ] Remote `RequestCastSkill` + `CastRejected` + `AoeCastVisual`
* [ ] Maná attribute server + regen 5/s + clamps
* [ ] HUD: skill bar 4 + mana bar + CD overlay + modo AoE suelo
* [ ] Loadout UI (asignar slots) + persistencia en profile (R2)
* [ ] Probar anti-exploit: cast sin maná/CD/posición inválida
* [ ] Verificar que auto-attack R1 sigue funcionando

---

### **Decisiones por defecto R3 (si no se cambian)**

| Tema | Default |
|------|---------|
| Cast | Instantáneo (sin cast bar) |
| GCD | No; CD por skill (GDD: maná + cooldown) |
| Regen maná | 5 MP/s constante |
| AoE | GroundAoE/HealAoE: resolución instantánea; radio 6–8; centro según skill; sin zonas persistentes |
| Daño/cura | `damageBase + coefficient * ATK/MATK`; heal/shield con su base+coef (config) |
| Skills R3 | Desde SKILLS_CATALOG.md; básicas + Spec A por defecto; debug level flag para QA |
| Loadout | 4 slots, persistido, default pre-cargado |
| Keybinds | 1–4 + touch móvil |
| Heal/buffs | Fuera de R3 |

---

### **Estimación (orientativa)**

2–4 sesiones (HUD + servicio de cast + AoE suelo).

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-12 | Alta HU-R3 al cerrar R2; producción pasa a R3 |
| 2026-08-12 | Catálogo de skills creado (SKILLS_CATALOG.md); seed y tipos de R3 derivan del catálogo |
| 2026-08-12 | Marcada completada según reporte del equipo; producción pasa a R4 |
