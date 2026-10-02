# HU-ITEMS-04: Itemización — templates, levelReq por tier y loot (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Ítems / Itemización / Contenido y loot
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Contenido de ítems + loot (dev)
**Fase GDD:** Ítems (mini-épica de itemización — plan cerrado con el PO 2026-09-22)
**Depende de:** HU-ITEMS-03 (setId/sistema de bonos), HU-ESTETICA-33 (assets), HU-R7 (boss/cofre/uniques), HU-R6a (LootTables), HU-ITEMS-01 (sets existentes)
**Componentes observados:** `ItemConfig`, `LootTables`, `BossConfig`/`EnemyConfig` (jefes), `floor_4_boss`/`floor_5_boss`

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** progresar por tiers de equipo (blanco → verde → azul → morado Helada) consiguiéndolos en los lugares correctos,
**para** que cada etapa de la dungeon me dé el siguiente escalón de poder.

---

### **Descripción del Requerimiento / Contexto**

Plan de itemización cerrado (PO 2026-09-22):

* **Tiers por clase**: blanco y verde (variantes de los sets existentes para las **3 clases**) · **azul** (solo dungeon, piso 3+, cualquier enemigo) · **morado Helada** (boss final piso 5, con % de chance).
* **Swap de jefes**: las **armas únicas** (Filo de la Escarcha, Arco del Vendaval Helado, Vara del Invierno) pasan al **Señor de la Escarcha (piso 4)**; el **boss final** deja los uniques y dropea el set Helada.
* **levelReq por tier** (progresión por pieza solo hasta verde):

| Tier | Pecho · Guante · Pierna | Casco · Hombrera | Dónde cae |
|------|------------------------|------------------|-----------|
| Blanco | 3 | 5 | Pisos 1–2 |
| Verde | 8 | 10 | Pisos 2–3 |
| Azul | **12** (uniforme) | | Piso 3+ (cualquier enemigo) |
| Morado (Helada) | **16** (uniforme) | | Boss final (piso 5) — % chance |
| Uniques (armas) | **14** | | Señor de la Escarcha (piso 4) |

**Criterio de hecho global:** existen los templates por tier/clase con levelReq correctos, el loot cae donde corresponde (azul piso 3+, set Helada del boss final con %, uniques del Señor de la Escarcha), y la jerarquía de poder blanco < verde < azul < morado < uniques se respeta.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Templates (ItemConfig, con setId)**

* **Base (blanco):** los sets existentes se normalizan a blanco (todas las piezas de las 3 clases: casco/hombrera/pecho/guante/pierna = 15 piezas) con levelReq 3/3/3/5/5 y stats de blanco (se corrigen piezas descolocadas como el pecho blanco a lvl 16).
* **Verde:** variantes `_green` (15 piezas nuevas) con levelReq 8/8/8/10/10 y stats superiores al blanco.
* **Azul:** variantes `_blue` (15 nuevas) con levelReq **12 uniforme**, stats superiores al verde.
* **Morado Helada:** variantes `_frost` (15 nuevas) con levelReq **16 uniforme** y **temática Helada** — el segundo mejor tier del juego (solo superado por los uniques).
* Naming: `<clase>_<pieza>` (base blanco) + sufijos `_green`/`_blue`/`_frost` (ej. `paladin_chest`, `paladin_chest_green`, `paladin_chest_blue`, `paladin_chest_frost`).
* Cada template: `setId` (ITEMS-03), `iconId` (EST-33), `visualModelId` (solo casco/hombreras nuevos + reskins del body), stats seed según tier (power budget R8d), rareza correcta (blanco/verde/azul/morado).

#### **2. Loot**

* **Azul:** entradas en `floor_3`, `floor_4` y `floor_5` (pesos bajos, piezas de las 3 clases).
* **Set Helada (morado):** el **cofre del boss final** (`floor_5_boss`) dropea **1 pieza del set Helada de la clase del jugador** (pieza aleatoria) con **% de chance** (seed ~35% — balance ITEMS-05); a veces no cae (rejugabilidad).
* **Uniques → Señor de la Escarcha (decisión PM — drop automático, sin cofre nuevo):** el Señor de la Escarcha **dropea al morir** (como el resto de mini-bosses; el cofre queda reservado al boss final como premio de cierre de run). Se extiende el **flujo de loot de mini-jefes por muerte** para procesar `uniqueChance`/`uniquePool` (config `floor_4_boss` con el pool de los 3 uniques y su chance); nivel de los uniques a **14**.
* **Fallback del cofre final (65% — mezcla ponderada, decisión PM):** **40% → pieza azul de la clase del jugador** (slot aleatorio) · **25% → oro (rango 40–80)**. Config-driven.
* `floor_5_boss` pierde el `uniquePool` (ya no dropea armas; dropea el set).
* Sin cambios al resto de loot (pociones, etc.).

#### **2.1 Recompensa del jefe final (extensión aprobada del flujo de loot — decisión PM 2026-09-22)**

* El `LootService` actual no sabe elegir piezas del set por clase ni manejar % con fallback. Se aprueba una **extensión mínima** (excepción documentada como la de pociones en R8d):
  * Al abrir el cofre del boss final: **35%** → 1 pieza épica Helada **de la clase del jugador**; **65%** → recompensa alternativa (**pieza azul de su clase u oro** — config).
  * **Enmendado por ITEMS-06 (2026-09-22):** dentro del 35% épico → **50% arma / 50% armadura** (slot aleatorio); armas épicas por clase: Paladín → espada/espadón/escudo (peso igual), Cazador → arco, Clérigo → varita. La extensión del servicio ahora cubre armas y armaduras.
  * Sin tocar el resto del flujo de recompensa (R4/R7).
* **Riesgo resuelto (seedOnly):** el selector de recompensas genérico debe **excluir los templates `seedOnly`** (los seed de ITEMS-03) del pool de equipo — los templates llevan el flag `seedOnly=true` y el selector lo respeta (config-driven).

#### **3. Stats seed por clase/slot/tier (decisión PM — tabla concreta)**

Valores **blanco** por clase/slot (base/roll, patrón del equipo existente); los tiers superiores usan **multiplicadores** sobre el valor blanco (redondeo a entero; CRIT a 0.01):

| Clase | Slot | Stat principal (blanco) | Multiplicador verde | Multiplicador azul | Multiplicador frost |
|-------|------|------------------------|--------------------|--------------------|--------------------|
| Paladín | Casco / Hombreras / Piernas | DEF 2/0 · 2/0 · 2/0 | ×1.4 | ×1.9 | ×2.5 |
| Paladín | Pecho | DEF 4/1 | ×1.4 | ×1.9 | ×2.5 |
| Paladín | Guantes | DEF 1/0 | ×1.4 | ×1.9 | ×2.5 |
| Cazador | Casco | DEF 2/0 | ×1.4 | ×1.9 | ×2.5 |
| Cazador | Hombreras | DEF 2/0 + ATK 2/1 | ×1.4 | ×1.9 | ×2.5 |
| Cazador | Piernas | DEF 3/1 + CRIT 0.02 | ×1.4 | ×1.9 | ×2.5 |
| Cazador | Pecho | DEF 4/1 + MDEF 2/0 | ×1.4 | ×1.9 | ×2.5 |
| Cazador | Guantes | DEF 1/0 + CRIT 0.01 | ×1.4 | ×1.9 | ×2.5 |
| Clérigo | Casco | MDEF 2/0 | ×1.4 | ×1.9 | ×2.5 |
| Clérigo | Hombreras | MDEF 2/0 + MaxMP 10/0 | ×1.4 | ×1.9 | ×2.5 |
| Clérigo | Piernas | MDEF 3/1 + MATK 1/0 | ×1.4 | ×1.9 | ×2.5 |
| Clérigo | Pecho | MDEF 4/1 + MATK 2/1 | ×1.4 | ×1.9 | ×2.5 |
| Clérigo | Guantes | MDEF 1/0 + MaxMP 5/0 | ×1.4 | ×1.9 | ×2.5 |

* **CRIT siempre en fracción (0.01 = 1%)** — alineado con el fix de escala de R6.22 (nada de +5 enteros).
* Los multiplicadores mantienen la meta de ITEMS-05 (~15–25% de poder entre tiers: verde 1.4×, azul 1.9×, frost 2.5× — el salto lo confirma ITEMS-05).
* El dev aplica los valores con la tabla (no inventa nada).

#### **4. Reglas**

* Todo data-driven (configs); la **única excepción aprobada** es la extensión mínima del flujo de recompensa del boss final (punto 2.1).
* `seedOnly=true` excluido del pool de recompensas genérico.
* Sync places (PUBLICAR-04): configs compartidos — dungeon por copia derivada.
* Balance fino de números en ITEMS-05 (drops %, stats finales, precios).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Templates por tier**

* **GIVEN** los templates
* **WHEN** se revisa `ItemConfig`
* **THEN** existen blanco/verde/azul/frost por pieza y clase (60 piezas en total: 15 × 4 tiers) con levelReq correctos y setId

#### **Escenario 2: Azul en la dungeon**

* **GIVEN** un jugador en piso 3+
* **WHEN** mata enemigos
* **THEN** las piezas azules de las 3 clases pueden caer (pesos bajos)

#### **Escenario 3: Set Helada del boss final**

* **GIVEN** el boss final derrotado
* **WHEN** se abre el cofre
* **THEN** puede caer 1 pieza del set Helada de la clase del jugador (con %; a veces no cae)
* **AND** el cofre ya no dropea armas únicas

#### **Escenario 4: Uniques del Señor de la Escarcha**

* **GIVEN** el Señor de la Escarcha derrotado
* **WHEN** muere (loot automático, sin cofre)
* **THEN** las armas únicas pueden caer por el flujo de muerte con `uniqueChance`/`uniquePool` (misma chance que tenía el piso 5) y su nivel es 14

#### **Escenario 5: levelReq correctos**

* **GIVEN** los templates
* **WHEN** se revisan los requisitos
* **THEN** blanco 3/3/3/5/5 · verde 8/8/8/10/10 · azul 12 · morado 16 · uniques 14 (nada descolocado)

#### **Escenario 6: Regresión**

* **GIVEN** el contenido implementado
* **WHEN** se juega el flujo completo (loot → equipar → combatir → jefes → rejoin)
* **THEN** no hay errores rojos y el resto del loot funciona igual

---

### **Alcance**

#### Incluye

* Templates de los 4 tiers (60 piezas) con levelReq/setId/iconId/visualModelId.
* Azul en piso 3+; set Helada del boss final (%); uniques al Señor de la Escarcha (lvl 14).

#### No incluye

* Sistema de bonos (ITEMS-03), assets (EST-33) ni balance final (ITEMS-05).

---

### **Definition of Done (DoD)**

* [ ] 60 templates (15 × 4 tiers) con levelReq correctos, setId y rarezas.
* [ ] Azul cae en piso 3+ (3 clases).
* [ ] Boss final dropea set Helada de la clase (%, pieza aleatoria); sin uniques.
* [ ] Señor de la Escarcha dropea uniques (lvl 14).
* [ ] Nada descolocado (pecho blanco lvl 16 corregido).
* [ ] Sin errores rojos en el flujo completo (publicado).
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Decisiones por defecto ITEMS-04**

| Tema | Default |
|------|---------|
| levelReq | Blanco 3/3/3/5/5 · Verde 8/8/8/10/10 · Azul 12 · Morado 16 · Uniques 14 |
| Azul | Piso 3+ (cualquier enemigo, pesos bajos) |
| Set Helada | Boss final: 35% pieza de tu clase (slot aleatorio) |
| Fallback 65% | **40% pieza azul de tu clase + 25% oro (40–80)** |
| Uniques | Señor de la Escarcha (piso 4) — **drop automático al morir** (flujo de mini-jefes extendido con uniqueChance/uniquePool), lvl 14 |

---

### **Estimación (orientativa)**

2–3 sesiones del dev: templates + loot + swap de jefes + regresión.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-ITEMS-04: itemización de contenido y loot — 60 templates por tier (blanco/verde/azul/frost), levelReq cerrados (progresión por pieza hasta verde), azul en piso 3+, set Helada del boss final (%) y uniques al Señor de la Escarcha (lvl 14) |
| 2026-09-22 | **Enmendado por ITEMS-06 (cofre del boss final):** el 35% épico ahora puede ser **arma (50%) o armadura (50%)** de la clase; armas épicas por clase (Paladín: espada/espadón/escudo · Cazador: arco · Clérigo: varita); la extensión de LootService cubre armas y armaduras |
| 2026-09-22 | **Decisiones PM (feedback dev):** (1) **extensión aprobada** del flujo de recompensa del boss final (35% → pieza del set de tu clase; 65% → azul/oro) y exclusión de `seedOnly` del pool genérico; (2) **tabla de stats seed por clase/slot/tier** (blanco concreto + multiplicadores verde ×1.4 / azul ×1.9 / frost ×2.5; CRIT en fracción) |
| 2026-09-22 | **Decisiones PM (rc065):** Señor de la Escarcha con **drop automático al morir** (extensión del flujo de mini-jefes para `uniqueChance`/`uniquePool`; sin cofre nuevo — el cofre es solo del boss final); fallback del cofre final = **40% pieza azul de tu clase + 25% oro (40–80)** |