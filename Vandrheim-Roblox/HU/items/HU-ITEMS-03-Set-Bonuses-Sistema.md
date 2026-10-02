# HU-ITEMS-03: Sistema de set bonuses — bonos de 3 y 4 piezas (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Ítems / Itemización / Sistema
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Sistema nuevo de bonos por set (dev)
**Fase GDD:** Ítems (mini-épica de itemización — plan cerrado con el PO 2026-09-22)
**Depende de:** HU-R4 (equip/InventoryService), HU-R6.16 (targeting aliado para el heal AOE), SKILLS_CATALOG (skills de las specs); **HU-ITEMS-04 aporta los templates reales después** (el contrato de `setId` se define en esta HU y se prueba con templates seed — sin dependencia circular)
**Componentes observados:** `InventoryService` (equip/desequip), `SkillService` (modificadores y procs), `ItemConfig` (setId), tooltips de ítems (UI)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que equipar 3 o 4 piezas de un set me dé bonos reales (stat y mejora de habilidad),
**para** que armar el set completo se sienta recompensado y mi build mejore.

---

### **Descripción del Requerimiento / Contexto**

No existe ningún sistema de bonos por set hoy. Se crea:

* **Bono de 3 piezas = stat principal de la clase:** Paladín **mitad DEF + mitad ATK** · Cazador **+CRIT%** · Clérigo **+MATK%**.
* **Bono de 4 piezas = mejora de habilidad** (una por spec, confirmadas por el PO):

| Clase | Spec | Mejora |
|-------|------|--------|
| Paladín | Protector | Consagración con **+rango** |
| Paladín | Castigo | Básicos con **% de resetear el CD del Anillo de luz sagrada** (SelfAoE) |
| Cazador | Asalto | **Corte carmesí con lifesteal** (roba vida al hacer daño con la skill) |
| Cazador | Puntería | **Tiro en cadena golpea 1 enemigo extra** cercano al objetivo original |
| Clérigo | Cólera | **Aniquilación deja un DoT** (10% del daño original en 4 s) |
| Clérigo | Misericordia | **Milagro cura en AOE** a aliados dentro del rango del aliado seleccionado (R6.16) |

**Criterio de hecho global:** al equipar 3 piezas del mismo set se aplica el bono de stat; al equipar 4, la mejora de habilidad correspondiente a la spec; todo server-authoritative, **re-evaluado en equipar/desequipar/respawn/respec/carga inicial**, visible en el tooltip.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Detección y aplicación**

* **Contrato de `setId` (acordado para ITEMS-04 — resuelve la dependencia circular):** naming `<clase>_<tier>` en snake_case: `paladin_white`, `paladin_green`, `paladin_blue`, `paladin_frost` · `hunter_*` · `cleric_*` (12 sets en total: 4 tiers × 3 clases). ITEMS-03 define el contrato y prueba con templates seed; **ITEMS-04 agrega los templates reales después** (misma HU que ya los planifica).
* `ItemConfig`: cada template del set lleva su `setId` según el contrato.
* `InventoryService`: al equipar/desequipar, contar piezas del mismo `setId` equipadas (sin duplicar 2H) → aplicar bonos en 3 y 4 piezas; re-calc de stats (patrón RecalculateStats).
* **Bono 3 piezas (stats, defaults configurables — balance en ITEMS-05):** Paladín +8% DEF **y** +8% ATK · Cazador +5% CRIT (+0.05) · Clérigo +8% MATK.
* **Bono 4 piezas (skill modifiers):** config por setId/spec: `setBonus = { pieces = 4, effect = "<skillModId>" }` con los parámetros de cada mejora.

#### **2. Modificadores de skill (SkillService) — defaults configurables (ITEMS-05 ajusta)**

* **Consagración +rango:** aumenta `castRange`/radio de la zona en **+30%** (config override al castear con el bono).
* **Reset de CD del Anillo de luz sagrada:** **proc en básico 15%** por ataque básico de resetear el CD del Anillo; **cooldown interno de 10 s** (config) para evitar spam.
* **Corte carmesí lifesteal:** cura **20% del daño** causado por la skill; **cap de cura por uso = 15% del MaxHP del caster** (config).
* **Tiro en cadena +1 objetivo:** la cadena golpea 1 enemigo adicional cercano al objetivo original (**sin daño extra** — `extraTargets = 1`).
* **Aniquilación DoT:** proc al impactar con la skill: aplica DoT = **10% del daño original en 4 s** (reusa ticks R6.9/R8e).
* **Milagro AOE:** el área (**radio 10 studs**, config) se **centra en el aliado seleccionado** (R6.16) y cura a los aliados dentro; **sin aliado seleccionado → self**; **aliado fuera de rango (25 studs) → self-heal con aviso "Aliado fuera de rango"** (mismo fallback de R6.16).

#### **3. UI**

* El **tooltip del ítem** muestra el setId y los bonos del set (3 y 4 piezas) con el contador de **piezas equipadas / 5** (ej. "Set Helada — 3/5" y el estado de cada bono: "Bono 3 piezas: ACTIVO" / "Bono 4 piezas: falta 1 pieza").
* Estados: bono activo/inactivo visible.

#### **4. Reglas**

* Server-authoritative; el cliente solo lee. Anti-exploit: los bonos salen de config; no se acumulan sets duplicados (una pieza cuenta 1, sin importar cuántas veces se intente).
* **Re-evaluación del bono (completa):** al **equipar**, **desequipar**, **respawn**, **cambio de spec (respec)** y **carga inicial (spawn/join con bono activo)** — nunca se conserva el bono de una spec equivocada.
* Sin persistencia de bonos en el perfil (se derivan del equipo + spec actual).
* Números dentro de bandas R9c (ITEMS-05).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Bono de 3 piezas**

* **GIVEN** un jugador con 3 piezas del mismo setId equipadas
* **WHEN** se calculan stats
* **THEN** recibe el bono de stat de su clase (Paladín DEF+ATK, Cazador CRIT, Clérigo MATK)
* **AND** con 2 piezas no hay bono

#### **Escenario 2: Bono de 4 piezas**

* **GIVEN** un jugador con 4 piezas del setId
* **WHEN** combate
* **THEN** la mejora de habilidad de su spec funciona (rango/lifesteal/+1 target/DoT/reset/heal AOE según el caso)

#### **Escenario 3: Procs**

* **GIVEN** el bono de 4 piezas de Castigo
* **WHEN** se hacen básicos
* **THEN** cada básico tiene la probabilidad de resetear el CD del Anillo (sin spam, con cooldown interno)

#### **Escenario 4: Re-evaluación**

* **GIVEN** un jugador con bono activo
* **WHEN** desequipa una pieza (queda en 3 o menos)
* **THEN** el bono correspondiente se retira al momento

#### **Escenario 4b: Re-evaluación por respawn, respec y carga inicial**

* **GIVEN** un jugador con set equipado
* **WHEN** muere y respawnea, cambia de spec (respec) o entra al juego con el set ya equipado
* **THEN** los bonos se re-evalúan al momento (nunca se conserva el bono de una spec equivocada ni tras el respawn)

#### **Escenario 5: Tooltip**

* **GIVEN** un ítem de set
* **WHEN** se abre su tooltip
* **THEN** muestra setId, contador de piezas y los bonos (3 y 4) con su estado

#### **Escenario 6: Anti-exploit y regresión**

* **GIVEN** un cliente manipulado
* **WHEN** intenta forzar bonos/duplicados
* **THEN** el server rechaza (config + conteo real del equipo)
* **AND** el flujo completo (equipar → combatir → dungeon → rejoin) no produce errores rojos

---

### **Alcance**

#### Incluye

* Sistema de detección de set (setId, conteo, 3/4 piezas).
* Bonos de stat (3 piezas) y modificadores de skill por spec (4 piezas).
* Procs (reset de CD, lifesteal, DoT) y modificadores (rango, +target, heal AOE).
* Tooltip de set con contador y bonos.

#### No incluye

* Templates/índices de loot (ITEMS-04).
* Balance final de números (ITEMS-05).
* Assets visuales (EST-33).

---

### **Definition of Done (DoD)**

* [ ] Detección de setId y bonos en 3/4 piezas (server, re-evaluación en equipar/desequipar/respawn/respec/carga inicial).
* [ ] Los 6 modificadores de skill funcionan (rango, proc reset, lifesteal, +1 target, DoT, heal AOE).
* [ ] Procs con cooldown interno; sin stacks ni duplicados.
* [ ] Tooltip con setId, contador y bonos.
* [ ] Anti-exploit vigente; sin errores rojos en el flujo completo.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Decisiones por defecto ITEMS-03**

| Tema | Default |
|------|---------|
| Bono 3 piezas | Paladín +8% DEF y +8% ATK · Cazador +5% CRIT · Clérigo +8% MATK (seed; balance ITEMS-05) |
| Bono 4 piezas | Por spec: reset Anillo 15%/10 s · lifesteal 20% (cap 15% MaxHP) · DoT 10%/4 s · +1 target sin daño extra · rango +30% · Milagro AOE radio 10 (fallback R6.16) |
| Procs | Cooldown interno (ej. 10 s); sin acumular |
| Persistencia | Los bonos se derivan del equipo + spec actual (nada en perfil) |

---

### **Estimación (orientativa)**

3–4 sesiones del dev: sistema de detección + modificadores + procs + tooltip.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-ITEMS-03: sistema de set bonuses — 3 piezas = stat de clase (Paladín DEF+ATK, Cazador CRIT, Clérigo MATK), 4 piezas = mejora de habilidad por spec (rango, reset CD, lifesteal, +1 target, DoT, heal AOE); plan cerrado con el PO |
| 2026-09-22 | **Decisiones PM (feedback dev):** contrato de `setId` = `<clase>_<tier>` (12 sets) definido en esta HU (ITEMS-04 agrega templates después — sin dependencia circular); valores de bonos como **defaults configurables** (reset 15%/10 s, lifesteal 20% con cap 15% MaxHP por uso, DoT 10%/4 s, +1 target sin daño extra, rango +30%, Milagro AOE radio 10 centrado en el aliado con fallback R6.16); **tooltip con contador X/5**; re-evaluación ampliada (equipar/desequipar/respawn/**respec**/**carga inicial**) |