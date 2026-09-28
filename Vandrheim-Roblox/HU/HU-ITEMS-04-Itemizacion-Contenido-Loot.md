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
* **Uniques → Señor de la Escarcha:** `floor_4_boss` pasa a tener el `uniquePool` (frost_edge/frostbow/glacial_wand) con su chance (el mismo mecanismo que tenía el piso 5); nivel de los uniques a **14**.
* `floor_5_boss` pierde el `uniquePool` (ya no dropea armas; dropea el set).
* Sin cambios al resto de loot (pociones, etc.).

#### **3. Reglas**

* Todo data-driven (configs); sin tocar servicios de gameplay (el flujo de recompensa R4/R7 se reutiliza).
* Sync places (PUBLICAR-04): configs compartidos — dungeon por copia derivada.
* Balance de números en ITEMS-05 (drops %, stats, precios).

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
* **WHEN** se abre su cofre
* **THEN** las armas únicas pueden caer (mismo mecanismo que tenía el piso 5) y su nivel es 14

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
| Set Helada | Boss final: 1 pieza de tu clase (aleatoria), % ~35% (ITEMS-05 afina) |
| Uniques | Señor de la Escarcha (piso 4), lvl 14 |

---

### **Estimación (orientativa)**

2–3 sesiones del dev: templates + loot + swap de jefes + regresión.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-ITEMS-04: itemización de contenido y loot — 60 templates por tier (blanco/verde/azul/frost), levelReq cerrados (progresión por pieza hasta verde), azul en piso 3+, set Helada del boss final (%) y uniques al Señor de la Escarcha (lvl 14) |