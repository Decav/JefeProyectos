# HU-R8e: Flecha venenosa — skill DoT (daño en el tiempo) para Puntería (Cazador)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R8 — 3 clases jugables / R8e (contenido adicional sobre R8b)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Contenido + framework mínimo (dev): nueva skill con DoT single-target
**Fase GDD:** R8e (posterior a R8b; los números se rigen por las bandas de balance de R8d)
**Depende de:** HU-R8b (Cazador completo), HU-R8d (reglas de balance: bandas de DPS), HU-R6.9 (sistema de ticks de GroundAoE — se reutiliza para el DoT), SKILLS_CATALOG v2.2 (árboles finales), ASSETS_LIST (iconos), VFX por skill (R8b)
**No modifica:** mecánicas existentes de otras clases ni specs

---

### **Narrativa (INVEST)**

**Como** jugador de Puntería,
**quiero** una flecha con veneno que dañe al enemigo **durante un tiempo** (DoT),
**para** que la spec no se sienta "solo flechas y ya": tener una herramienta de presión sostenida además del burst.

**Como** equipo de desarrollo,
**quiero** agregar el DoT sin romper el modelo (30 skills, árboles aprobados),
**para** que el framework lo soporte como tipo nuevo y el contenido quede coherente con el balance de R8d.

---

### **Descripción del Requerimiento / Contexto**

Puntería hoy es puro burst de flechas (Flecha pesada, Tiro certero, Tiro en cadena, Disparo mortal): se siente **plana** porque todo es el mismo tipo de interacción. Se agrega una **skill de DoT single-target** (daño por tick durante un tiempo, como una flecha con veneno).

Cambios que implica:

1. **Framework (mínimo):** nuevo `SkillType = "DoT"` — daño en el tiempo sobre **un solo objetivo**: el objetivo queda marcado y recibe daño por tick (`tickInterval`) durante `duration`. **Reutiliza el sistema de ticks de R6.9** (GroundAoE) con centro = objetivo (DoT que sigue al target), server-authoritative. Sin stacks: **1 DoT activo por caster por objetivo** (re-lanzar refresca la duración, no apila).
2. **Contenido (reemplazo, sin cambiar el conteo):** la skill de **nivel 1** de Puntería **"Flecha pesada"** se reemplaza por **"Flecha venenosa" (DoT)** — decisión PM/PO 2026-09-18. Puntería mantiene **6 skills** (2 básicas + 4 de spec) y el total del catálogo sigue en **30 skills**.
3. **Árbol: sin cambios** — la rama Caza conserva el pasivo "Flechas de guerra (+3% ATK)"; no se enmiendan los árboles aprobados (v2.2).
4. **Números (seed; balance dentro de bandas R8d):** el DoT total ≈ **1.2–1.5×** una skill single media (regla R8d para DoT): por tick `4/0.35×ATK`, `duration 6 s`, `tick 1 s` (6 ticks) → total ≈ 24 + 2.1×ATK.
5. **VFX:** flecha con **rastro venenoso** (Trail/partículas verdes en el proyectil) + **ticks verdes** sobre el objetivo durante la duración (estilo R8b, client-side con autoridad server).
6. **Icono:** `Icon_Skill_hunter_mm_venom` agregado a ASSETS_LIST (512×512, fondo negro).

**Criterio de hecho global:** el Cazador Puntería tiene "Flecha venenosa" desde el nivel 1 (reemplaza Flecha pesada), la lanza con VFX propio, el objetivo recibe DoT por tick sin stackear, y el conjunto queda dentro del balance de R8d.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. SkillType `DoT` (framework, mínimo)**

* Config (SkillConfig): `type = "DoT"`, `duration`, `tickInterval`, `damageBase`/`coefficient` **por tick** (como R6.9), `maxRange`, `manaCost`, `cooldown`, `threatMod`.
* Servidor: al lanzar sobre el objetivo seleccionado (targeting existente), se registra el DoT (id del caster + objetivo); cada tick aplica daño (mitigación DEF/MDEF existente); al terminar la duración se limpia.
* **Sin stacks:** si el mismo caster relanza sobre el mismo objetivo, se **refresca la duración** (no acumula ticks paralelos).
* El maná y el cooldown se descuentan una sola vez al lanzar.
* Cliente: VFX de ticks y marcador visual del DoT sobre el objetivo (estilo R8b).

#### **2. Contenido (SKILLS_CATALOG → v2.3)**

| ID | Nombre | Tipo | Stat | Rango | Maná | CD | Obtención | Params (seed) | Threat |
|----|--------|------|------|-------|------|----|-----------|---------------|--------|
| `hunter_mm_venom` | Flecha venenosa | DoT | ATK | 25 | 15 | 10 | **nivel 1 (spec) — reemplaza "Flecha pesada"** | por tick 4/0.35 · 6 s · tick 1 s (6 ticks) | 1 |

* Puntería mantiene **6 skills** (2 básicas + 4 de spec); el total del catálogo sigue en **30 skills** (sin excepciones).
* `weaponAffinity`: Hunter_Punteria (como el resto de la spec).

#### **3. Árbol de Puntería (sin cambios, v2.2 intacto)**

| Rama | Nodo 1 | Nodo 2 | Capstone |
|------|--------|--------|----------|
| Precisión | Puntería (+4% ATK) | Tiro en cadena (Skill) | Disparo mortal (Skill) |
| Caza | Resistencia (+5% MaxHP) | Flechas de guerra (+3% ATK) | Cazador de élite (+8% ATK) |
| Táctica | Ojo certero (+2% CRIT) | Concentración (+2% CDR) | Tiro perfecto (+5% CRIT + 3% CDR) |

* No se enmienda ningún árbol: el DoT se obtiene por **nivel** (lvl 1 de la spec), no por talento.

#### **4. VFX e icono**

* **Proyectil:** flecha con Trail/partículas **verde veneno** (nuevo color para la paleta VFX; se registra como decisión — alternativa temática "escarcha" si el producto prefiere mantener la paleta fría).
* **Ticks:** destello/partícula verde sobre el objetivo en cada tick (client-side, autoridad server del daño).
* **Icono:** `Icon_Skill_hunter_mm_venom` → ASSETS_LIST + subida al Asset Server + ASSETS_REGISTRY.

#### **5. Balance (bandas R8d)**

* DoT total (6 ticks) ≈ **1.2–1.5×** una skill single media de Puntería → worth en pelea prolongada; DPS sostenido dentro de las bandas de la spec.
* Maná/CD dentro del ciclo (pack + mob ≤ 60–70% del pool, regla R8d).
* El seed (4/0.35, 6 ticks) se ajusta en la verificación de R8d si queda fuera de banda.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Se aprende al elegir la spec (lvl 1)**

* **GIVEN** un Cazador que elige Puntería
* **WHEN** se revisa su grimorio a nivel 1
* **THEN** tiene "Flecha venenosa" (reemplazó a "Flecha pesada") y puede asignarla a la barra
* **AND** no hay cambios en los árboles de talentos (v2.2 intacto)

#### **Escenario 2: DoT aplicado**

* **GIVEN** el Cazador lanza Flecha venenosa a un enemigo
* **WHEN** transcurre la duración
* **THEN** el objetivo recibe daño por tick (1 por segundo, 6 ticks) con VFX verde en cada tick
* **AND** el daño pasa por la mitigación existente

#### **Escenario 3: Sin stacks**

* **GIVEN** el mismo caster relanza la flecha sobre el mismo objetivo
* **WHEN** el DoT está activo
* **THEN** se refresca la duración (no se acumulan DoTs paralelos)
* **AND** el maná/CD se descuenta una vez por lanzamiento

#### **Escenario 4: Balance**

* **GIVEN** la skill implementada
* **WHEN** se mide su daño total
* **THEN** el total (6 ticks) cae en 1.2–1.5× una single media (banda R8d)
* **AND** el ciclo de maná/CD sigue dentro de las reglas de R8d

#### **Escenario 5: VFX e icono**

* **GIVEN** la skill lanzada
* **WHEN** se revisa el proyectil y el objetivo
* **THEN** el proyectil tiene rastro venenoso y el objetivo muestra los ticks
* **AND** el icono `Icon_Skill_hunter_mm_venom` existe (ASSETS_LIST, fondo negro) y se usa en grimorio/barra

#### **Escenario 6: Regresión Hunter**

* **GIVEN** la skill agregada
* **WHEN** se juega el Cazador completo (Asalto + Puntería, combate, respec, rejoin)
* **THEN** el resto de skills, árboles, VFX y el grimorio siguen funcionando sin errores rojos

---

### **Comportamiento Visual / Reglas de Negocio**

* DoT = daño en el tiempo sobre un solo objetivo; sin stacks; server-authoritative.
* El color veneno (verde) es un **nuevo acento de VFX** — se documenta como decisión; alternativa temática: escarcha (paleta fría).
* Solo cambia contenido de Puntería; el resto de specs/clases quedan intactas.

---

### **Alcance**

#### Incluye

* `SkillType = "DoT"` (reusa ticks de R6.9; single-target, refresh sin stack).
* Skill `hunter_mm_venom` **reemplazando "Flecha pesada"** (skill de nivel 1 de Puntería) — el conteo de skills no cambia.
* SKILLS_CATALOG → v2.3 (tipo DoT + skill; sin enmienda de árboles).
* VFX (proyectil + ticks verdes) e icono `Icon_Skill_hunter_mm_venom` (ASSETS_LIST + ASSETS_REGISTRY).
* Ajuste de números dentro de las bandas de R8d.

#### No incluye

* Cambios a otras clases/specs ni al resto de los árboles aprobados.
* Mecánicas nuevas más allá del DoT (sin stacks, sin área, sin cura).
* DoT para otras clases (queda como base si el producto quiere más adelante).
* Animación nueva (reusa `ranged_shot` de R8b).

---

### **Definition of Done (DoD)**

* [ ] `SkillType = "DoT"` funciona server-side (ticks por interval, refresh sin stack, mitigación aplicada).
* [ ] "Flecha venenosa" reemplaza a "Flecha pesada" (skill de nivel 1 de Puntería) y aparece en grimorio/barra.
* [ ] El DoT total cae en 1.2–1.5× single media (banda R8d); maná/CD dentro del ciclo.
* [ ] VFX del proyectil y ticks visibles; icono creado y registrado.
* [ ] SKILLS_CATALOG v2.3 actualizado (tipo + skill; árboles intactos).
* [ ] Regresión del Cazador completa (Asalto + Puntería, respec, rejoin) sin errores rojos.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Al cerrar: PROJECT_ARCHITECTURE, DATA_SCHEMA y registro HU/RC actualizados; nota en GDD después de QA.

---

### **Decisiones por defecto R8e**

| Tema | Default |
|------|---------|
| DoT | Single-target, 6 ticks (1/s), refresh sin stack |
| Obtención | **Nivel 1 de la spec (reemplaza "Flecha pesada")** — decisión PM/PO; sin cambios de árbol |
| Números | Seed 4/0.35 por tick; total 1.2–1.5× single (bandas R8d) |
| VFX | Verde veneno (nuevo acento; alternativa temática: escarcha) |
| Balance | Se rige por las bandas de R8d |

---

### **Estimación (orientativa)**

1–2 sesiones del dev: SkillType DoT + skill + árbol + VFX + icono + regresión (números cerrados en R8d).

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-18 | Creación de HU-R8e: Flecha venenosa (DoT single-target) para Puntería — nuevo SkillType (reusa ticks de R6.9), reemplaza a "Flecha pesada" como skill de nivel 1 (sin enmienda de árboles, Puntería mantiene 6 skills), VFX verde veneno, icono y números bajo bandas de R8d |