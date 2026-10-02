# HU-ITEMS-05: Itemización — balance y QA final de los tiers y bonos (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Ítems / Itemización / Balance y QA
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Balance + QA (dev) — solo números en configs
**Fase GDD:** Ítems (mini-épica de itemización — cierre)
**Depende de:** HU-ITEMS-03 (bonos), HU-ITEMS-04 (templates/loot), HU-R8d/R9c (bandas de balance), HU-ESTETICA-33 (assets)
**No modifica:** mecánicas ni sistemas (solo números)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que el set completo se sienta poderoso pero balanceado (los bonos no rompen el juego),
**para** que armar el tier sea una mejora real y justa.

---

### **Descripción del Requerimiento / Contexto**

La mini-épica de itemización agrega tiers, set bonuses y swaps de loot. Esta HU **balancea y valida** todo: números de stats por tier, bonos (3 y 4 piezas), % de drops y la jerarquía de poder — dentro de las bandas de R8d/R9c.

**Criterio de hecho global:** un jugador con set completo (4 piezas) de su tier se siente ~10–15% más fuerte que con piezas sueltas del mismo nivel; el set Helada es el mejor tier antes de los uniques; ningún bono rompe las bandas (TTK, boss, maná); QA completo solo/party.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Metas de poder por tier (power budget)**

* **Stats:** cada tier supera al anterior en ~15–25% de poder total (blanco < verde < azul < morado).
* **Set completo vs piezas sueltas del mismo nivel:** el bono completo (4 piezas) aporta **~10–15% de poder adicional** sobre las stats puras (sin que el set solo sea el doble de fuerte).
* **Set Helada vs uniques:** el morado es el **mejor tier de armadura**; los **uniques (armas, lvl 14)** siguen siendo las mejores armas.

#### **2. Números de bonos (ITEMS-03 — defaults configurables confirmados 2026-09-22)**

* **3 piezas:** Paladín +8% DEF y +8% ATK · Cazador +5% CRIT · Clérigo +8% MATK — verificar que el Paladín (mitad/mitad) no lo haga dominar: medir el DPS/sobrevivencia vs los otros.
* **4 piezas (defaults configurables — ajustar si la meta no se cumple):** reset del Anillo **15% por básico / 10 s de cooldown interno** · lifesteal de Corte carmesí **20% del daño / cap 15% del MaxHP del caster por uso** · DoT de Aniquilación **10% del daño en 4 s** · Tiro en cadena **+1 objetivo sin daño extra** · Consagración **+30% de rango** · Milagro AOE **radio 10 studs centrado en el aliado seleccionado, fallback R6.16 (self si fuera de rango/sin aliado)** — cada uno se ajusta hasta cumplir la meta de poder (~10–15% extra).
* Regla: los procs tienen **cooldown interno** y nunca permiten infinitos.

#### **3. Drops**

* **Set Helada del boss final:** % seed **35%** — verificar rejugabilidad (a veces no cae) sin frustrar (el cofre siempre da algo: si no cae el set, caen piezas azules/oro).
* **Azul piso 3+:** pesos bajos (verificar que no inunden la bolsa ni rompan la economía de rareza).
* **Uniques del Señor de la Escarcha:** misma chance que tenía el piso 5 (sin cambios percibidos en frecuencia).

#### **4. QA (solo y party, publicado)**

* Cada clase: correr la dungeon con piezas sueltas vs set completo (4 piezas) y medir el delta de poder (meta 10–15%).
* Boss final con set Helada: TTK dentro de bandas (60–120 s).
* Bonos por spec verificados uno a uno (que el proc de reset no haga el Anillo infinito, que el lifesteal no cure más que un heal, etc.).
* Sin errores rojos en equipar → combatir → jefes → rejoin (PC y móvil).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Jerarquía de tiers**

* **GIVEN** los 4 tiers
* **WHEN** se comparan sus stats
* **THEN** cada tier supera al anterior ~15–25% y el morado es el mejor antes de los uniques

#### **Escenario 2: Poder del set**

* **GIVEN** un jugador con set completo (4 piezas)
* **WHEN** se compara contra piezas sueltas del mismo nivel
* **THEN** el delta de poder es ~10–15% (sin que el set rompa las bandas)

#### **Escenario 3: Bonos por spec**

* **GIVEN** los 6 bonos de 4 piezas
* **WHEN** se miden (procs, lifesteal, DoT, +target, rango, heal AOE)
* **THEN** ninguno supera la meta de poder ni genera infinitos (cooldowns internos funcionan)

#### **Escenario 4: Drops justos**

* **GIVEN** los % de drop
* **WHEN** se farmea (boss final y piso 3+)
* **THEN** el set Helada cae a veces (rejugabilidad) sin frustrar (el cofre siempre da algo)
* **AND** las piezas azules no inundan la bolsa

#### **Escenario 5: Regresión**

* **GIVEN** el balance aplicado
* **WHEN** se juega el flujo completo (solo y party, publicado)
* **THEN** no hay errores rojos y las bandas R8d/R9c se mantienen

---

### **Alcance**

#### Incluye

* Ajuste de stats por tier, bonos (3/4 piezas) y % de drops (solo configs).
* QA de poder (set vs sueltas), boss final con set y procs.
* Registro de métricas (tabla en el RC).

#### No incluye

* Mecánicas/sistemas nuevos (ITEMS-03 ya los definió).
* Assets (EST-33) ni contenido (ITEMS-04).

---

### **Definition of Done (DoD)**

* [ ] Jerarquía de tiers verificada (15–25% entre tiers; morado > todo antes de uniques).
* [ ] Set completo = ~10–15% de poder extra; bandas R8d/R9c intactas.
* [ ] Los 6 bonos de 4 piezas dentro de la meta (procs con cooldown interno, sin infinitos).
* [ ] Drops justos (Helada ~35% con fallback de recompensa; azul sin inundar).
* [ ] QA solo/party publicado sin errores rojos.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Decisiones por defecto ITEMS-05**

| Tema | Default |
|------|---------|
| Poder por tier | +15–25% entre tiers |
| Poder del set | ~10–15% extra con 4 piezas |
| Set Helada % | ~35% (cofre siempre da algo si no cae) |
| Procs | Con cooldown interno; sin infinitos |

---

### **Estimación (orientativa)**

2–3 sesiones del dev: ajustes + QA de poder y drops (solo/party, publicado).

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-ITEMS-05: balance y QA de la itemización — jerarquía de tiers (15–25%), poder del set (~10–15%), bonos por spec dentro de la meta, drops justos (Helada ~35% con fallback) y verificación publicada |