# HU-R6.22: Fix de escala del crítico — normalizar a fracción 0–1 (todos los ataques salían críticos)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R6.x / Bugfix (reportado por PO + dev 2026-09-22)
**Prioridad:** **CRÍTICA** (afecta todo el combate: todos los ataques son críticos)
**Estado:** Lista para implementar
**Tipo:** Bugfix de combate (dev)
**Fase GDD:** R6.22 (no cambia mecánicas ni balance más allá del fix)
**Depende de:** HU-R4 (rolls/afijos de ítems), HU-R2 (ClassConfig: crit base por clase), HU-R5.1 (talentos), HU-R8d (balance)
**Componentes observados:** `InventoryService` (suma de stats), `CombatService` (sorteo de crítico: `math.random() < critChance`), `ItemConfig` (afijos/rolls), `ClassConfig` (crit base), `TalentConfig` (bonos de crit), UI de stats (muestra %)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que el crítico funcione con probabilidad real (5% = 5% de cada golpe),
**para** que no todos los ataques salgan críticos y el daño se sienta justo.

**Como** equipo,
**quiero** una **única unidad interna** para el crítico (fracción 0–1),
**para** que clase + talentos + equipo se sumen consistente y la UI muestre %.

---

### **Descripción del Requerimiento / Contexto**

**Bug (hallazgo dev + PO):** hay una **inconsistencia de escala** en el crítico:
* Clases y talentos lo expresan como **fracción** (`0.05` = 5%).
* Algunos valores de **equipo/afijos** se guardan como **puntos porcentuales enteros** (`+5` = 5%).
* `InventoryService` suma ambos **sin convertir** a la misma escala.
* `CombatService` compara `math.random() < critChance`: si el atributo queda en 5 (en vez de 0.05), **todo valor aleatorio 0–1 es menor → todos los ataques son críticos**. La UI puede mostrar un % chico mientras el server usa otra escala.
* Afecta a **todas las clases y armas** (flujo común de combate).

**Criterio de hecho global:** el crítico se calcula con una **fracción 0–1** en todo el pipeline (clase + talentos + equipo normalizados, clamp 0–1), cada ataque hace un **sorteo independiente** (`math.random() < critChance`), y la UI muestra % (0.05 → "5%"). El multiplicador de daño crítico no cambia.

---

### **Especificaciones Técnicas / Contratos de API**

* **Unidad interna única:** el crítico se almacena/calcula como **fracción 0–1** en todo el pipeline.
* **Conversión en el origen:** los valores de equipo/afijos expresados como puntos porcentuales (**`+5` CRIT → `0.05`**) se convierten **antes de sumar** (en la definición de afijos/rolls de `ItemConfig` o al aplicar stats del ítem — la conversión en un solo lugar, nunca en la UI).
* **Clase + talentos + equipo:** se suman ya **normalizados** (el base por clase ya existe en `ClassConfig`: Paladín 0.05, Cazador 0.10, Clérigo 0.05, + per level — se conserva; equipo y talentos agregan encima).
* **Clamp:** el atributo final CRIT se limita a **[0, 1]** (o el máximo que el PM defina — default 1.0; ajuste de tope si hiciera en R9c).
* **Sorteo por golpe:** `CombatService` usa `math.random() < critChance` con la fracción normalizada → cada golpe es un **sorteo independiente** (50% → 50% por golpe, sin garantía de "5 de 10").
* **UI:** la interfaz **convierte la fracción a %** al mostrar (0.05 → "5%").
* **Multiplicador de daño crítico:** se conserva tal cual (cambio solo si el PM lo pide en otra HU).
* **Auditoría:** revisar que **ningún** otro atributo tenga el mismo problema de escala (CRIT era el conocido; verificar valores de ítems/afijos vs fracciones).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Probabilidad real**

* **GIVEN** un jugador con 50% de crítico (0.50)
* **WHEN** ataca muchas veces
* **THEN** ~50% de los golpes son críticos (sin garantía de conteo exacto; rachas normales)
* **AND** con 5% (0.05), ~5% de los golpes son críticos (no todos)

#### **Escenario 2: Sin escala rota**

* **GIVEN** un ítem/afijo con `+5 CRIT`
* **WHEN** se calculan las stats
* **THEN** aporta `0.05` (normalizado) y se suma con clase/talentos en la misma escala

#### **Escenario 3: Clamp**

* **GIVEN** el crítico calculado
* **WHEN** supera 1.0 (o el tope definido)
* **THEN** se limita a [0, 1] (o el tope) — nunca > 100%

#### **Escenario 4: UI en %**

* **GIVEN** el atributo CRIT = 0.05
* **WHEN** se muestra en la UI
* **THEN** se ve "5%"

#### **Escenario 5: Todas las clases/armas**

* **GIVEN** el fix aplicado
* **WHEN** se ataca con distintas clases y armas (melee, ranged, mágico, básicas)
* **THEN** el crítico funciona con la probabilidad correcta en todos

#### **Escenario 6: Regresión**

* **GIVEN** el fix implementado
* **WHEN** se juega el flujo completo (equipar → combatir → dungeon → rejoin)
* **THEN** no hay errores rojos y el resto de stats no cambia (el daño normal y el multiplicador de crítico intactos)

---

### **Alcance**

#### Incluye

* Normalización del crítico a fracción 0–1 (origen: afijos/rolls de ítems).
* Suma consistente clase + talentos + equipo + clamp [0, 1].
* Sorteo independiente por golpe (ya es `math.random() < critChance`, correcto con la escala).
* UI mostrando %.
* Auditoría de otras stats con posible problema de escala.

#### No incluye

* Cambios al multiplicador de daño crítico.
* Rebalanceo del % base (se conserva: Paladín 5% / Cazador 10% / Clérigo 5% + per level — el tope/balance fino va en R9c si hace falta).

---

### **Definition of Done (DoD)**

* [ ] CRIT en fracción 0–1 en todo el pipeline; afijos `+N` convertidos en el origen.
* [ ] Clase + talentos + equipo sumados normalizados; clamp [0, 1].
* [ ] 50% → ~50% de críticos; 5% → ~5% (sorteos independientes, sin escala rota).
* [ ] UI muestra % (0.05 → "5%").
* [ ] Todas las clases/armas verificadas; multiplicador de crítico intacto.
* [ ] Auditoría de otras stats con el mismo patrón.
* [ ] Sin errores rojos en el flujo completo.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Decisiones por defecto R6.22**

| Tema | Default |
|------|---------|
| Unidad interna | **Fracción 0–1** (5% = 0.05) |
| Conversión | En el origen (afijos/rolls de ítems), un solo lugar |
| Clamp | [0, 1] (tope ajustable en R9c) |
| Sorteo | `math.random() < critChance` por golpe (independiente) |
| UI | Muestra % (0.05 → "5%") |
| Multiplicador crítico | Intacto |
| Base por clase | Se conserva (Paladín 5% / Cazador 10% / Clérigo 5% + per level) |

---

### **Estimación (orientativa)**

1–2 sesiones del dev: normalización + conversión en origen + clamp + UI + auditoría + regresión.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-R6.22: fix de escala del crítico — normalizar a fracción 0–1 (afijos +N → 0.0N), clase+talentos+equipo sumados consistentes, clamp [0,1], UI en %; todos los ataques salían críticos por la escala rota (hallazgo dev + PO) |