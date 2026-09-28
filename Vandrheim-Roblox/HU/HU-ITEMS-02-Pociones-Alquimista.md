# HU-ITEMS-02: Pociones variadas del Alquimista — tiers (chica/grande) y pociones de buff (ATK, DEF, MaxHP)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Ítems / Consumibles / Alquimista
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Contenido + mecánica de buffs para consumibles (dev)
**Fase GDD:** Ítems (transversal; reemplaza la decisión de pociones de R8d — el 25% pasa a ser la poción "chica")
**Depende de:** HU-R8d (excepción aprobada: `healPercent`/`manaPercent` en `InventoryService`), HU-R5 (vendors/consumibles), HU-R5.2 (stacking), SKILLS_CATALOG (framework soporta `Buff`)
**No modifica:** skills, combate ni mecánicas existentes (salvo la excepción ya aprobada de % de cura)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** más variedad de pociones en el Alquimista: una **chica** y una **grande** (HP/MP) y pociones de **buff** (más ataque, más defensa, más vida),
**para** preparar mis runas según la situación y que el vendedor de pociones tenga un catálogo real.

**Como** equipo de desarrollo,
**quiero** implementar las pociones nuevas con una mecánica de buffs simple (server-authoritative),
**para** que el Alquimista venda variedad sin romper el flujo de consumibles existente.

---

### **Descripción del Requerimiento / Contexto**

Hoy el Alquimista vende solo 2 pociones fijas (`heal=30`/`mana=30`). La decisión de R8d (pociones al 25%) se **amplía** (decisión PO 2026-09-22):

* **Tiers:** poción **chica** (la actual, **25% del máximo**) y **grande** (**50% del máximo**), para HP y MP.
* **Buffs (3, separadas):** +Ataque, +Defensa, +Vida máxima — temporales (60 s), sin stacks (re-lanzar refresca), se limpian al morir.

El framework ya soporta `Buff` (SKILLS_CATALOG) — la mecánica de buffs para consumibles se reusa/adapta mínimamente.

**Criterio de hecho global:** el Alquimista vende 7 pociones (HP chica/grande, MP chica/grande, buff ATK, buff DEF, buff MaxHP) que funcionan con el flujo de consumibles (Z/X, bolsa, stacking, venta) y autoridad server; la decisión de R8d queda actualizada (el 25% = chica).

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Nuevos templates (ItemConfig, config-driven)**

| templateId | Nombre | Efecto | Config |
|------------|--------|--------|--------|
| `potion_hp` | Poción de vida (chica) | Cura **25%** del MaxHP | `healPercent = 0.25` (excepción aprobada R8d) |
| `potion_hp_large` | Poción de vida grande | Cura **50%** del MaxHP | `healPercent = 0.50` |
| `potion_mp` | Poción de maná (chica) | Restaura **25%** del MaxMP | `manaPercent = 0.25` |
| `potion_mp_large` | Poción de maná grande | Restaura **50%** del MaxMP | `manaPercent = 0.50` |
| `potion_buff_atk` | Poción de furia | **+10% ATK** por 60 s | `useAction = "ApplyBuff"`, `buffStat = "ATK"`, `buffPercent = 0.10`, `buffDuration = 60` |
| `potion_buff_def` | Poción de hierro | **+10% DEF** por 60 s | `useAction = "ApplyBuff"`, `buffStat = "DEF"`, `buffPercent = 0.10`, `buffDuration = 60` |
| `potion_buff_hp` | Poción de vitalidad | **+10% MaxHP** por 60 s | `useAction = "ApplyBuff"`, `buffStat = "MaxHP"`, `buffPercent = 0.10`, `buffDuration = 60` |

* Todas: `stackable=true`, `maxStack=20`, `useAction` según corresponda; sin cambio a los templates existentes salvo `potion_hp`/`potion_mp` (pasan a %).
* **Regla:** las 2 viejas (`potion_hp`/`potion_mp`) se **migran al %** (chicas) — no se crean duplicadas.

#### **2. Mecánica de buffs (consumibles, server-authoritative)**

* `useAction = "ApplyBuff"`: el server aplica un buff temporal con `buffStat`/`buffPercent`/`buffDuration` desde config (nunca del cliente).
* **Sin stacks:** re-lanzar el mismo buff **refresca la duración** (no acumula).
* **Muerte:** los buffs se limpian al morir el jugador.
* Aplica como modificador de stats (súmale al cálculo existente de stats — recalculateStats ya suma fuentes; el buff es una fuente temporal).
* Reusar el soporte `Buff` del framework si es compatible; si no, un `BuffSystem` chico (server) con contrato claro.
* Los buffs **no afectan** el funcionamiento de las pociones de cura/maná.

#### **3. Alquimista (VendorConfig)**

* `vendor_consumables.items` pasa a incluir las 7 pociones.
* **Precios seed (ajustables en R8d/R9c):** chica **15**, grande **30**, buffs **30** (`consumablePrices`).
* El flujo R5/R5.2 (comprar, bolsa, stacking, venta de 1 unidad) intacto.

#### **4. Anti-exploit y regresión**

* Server valida: `buffStat`/`buffPercent`/`buffDuration` desde config, no del cliente; sin stacks; limpieza al morir.
* Regresión: Z/X, bolsa, venta, vendor, respawn, dungeon (pociones usables dentro de la run — sync places por copia derivada, PUBLICAR-04).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Tiers de cura**

* **GIVEN** un jugador con HP/MP dañados
* **WHEN** usa la poción chica o la grande
* **THEN** cura 25% o 50% del máximo según corresponda (HP y MP)

#### **Escenario 2: Buffs**

* **GIVEN** un jugador usa una poción de buff
* **WHEN** la usa
* **THEN** recibe el bono temporal (+ATK/+DEF/+MaxHP 10% por 60 s) y se refleja en sus stats
* **AND** re-usarla refresca la duración (sin acumular)

#### **Escenario 3: Muerte limpia**

* **GIVEN** un jugador con buffs activos
* **WHEN** muere
* **THEN** los buffs se limpian (y las stats vuelven a la normalidad)

#### **Escenario 4: Alquimista con catálogo**

* **GIVEN** el Alquimista
* **WHEN** se abre su ventana
* **THEN** vende las 7 pociones con sus precios (chica 15, grande 30, buffs 30)
* **AND** el flujo de compra/bolsa/stacking/venta funciona

#### **Escenario 5: Anti-exploit**

* **GIVEN** un cliente manipulado
* **WHEN** intenta aplicar un buff con valores inventados o acumular stacks
* **THEN** el server rechaza y el perfil no se corrompe

#### **Escenario 6: Regresión**

* **GIVEN** las pociones nuevas
* **WHEN** se juega el flujo completo (comprar → usar por Z/X → dungeon → morir → respawn → rejoin)
* **THEN** no hay errores rojos y todo lo existente funciona

---

### **Alcance**

#### Incluye

* 7 templates de pociones (4 de cura/maná en tiers + 3 buffs) config-driven.
* Migración de `potion_hp`/`potion_mp` a % (chicas).
* Mecánica `ApplyBuff` para consumibles (server, sin stacks, limpieza al morir).
* Catálogo y precios del Alquimista.

#### No incluye

* Skills ni combate (el `Buff` de skills queda como está).
* Otras pociones (veneno, resistencias, etc.) — futuro si el PO quiere.
* Cambios a balance de stats base (R8d/R9c).

---

### **Definition of Done (DoD)**

* [ ] Las 7 pociones existen en `ItemConfig` (config-driven, con % y buffs).
* [ ] Chica 25% / grande 50% (HP y MP) funcionando.
* [ ] Buffs temporales (+10% ATK/DEF/MaxHP, 60 s) con refresh sin stack y limpieza al morir.
* [ ] Alquimista vende las 7 con precios (15/30/30).
* [ ] Anti-exploit vigente (valores desde config).
* [ ] Sin errores rojos en comprar → usar → dungeon → morir → respawn → rejoin.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Al cerrar: PROJECT_ARCHITECTURE, DATA_SCHEMA y registro HU/RC actualizados; nota en GDD después de QA (sync places incluido).

---

### **Decisiones por defecto ITEMS-02**

| Tema | Default |
|------|---------|
| Tiers | Chica 25% / grande 50% (HP y MP) |
| Buffs | +10% ATK / DEF / MaxHP por 60 s; sin stacks; se limpian al morir |
| Precios | Chica 15 · Grande 30 · Buffs 30 (seed; R8d/R9c afinan) |
| Migración | `potion_hp`/`potion_mp` pasan a % (chicas), sin duplicados |
| Mecánica | `ApplyBuff` server-authoritative (reusa `Buff` del framework si aplica) |

---

### **Estimación (orientativa)**

2 sesiones del dev: templates + mecánica de buffs + Alquimista + regresión.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-ITEMS-02: pociones variadas del Alquimista — tiers chica/grande (25/50% HP y MP) y 3 pociones de buff (ATK/DEF/MaxHP 10% por 60 s, sin stacks); reemplaza/amplía la decisión de pociones de R8d (el 25% pasa a ser la chica) |