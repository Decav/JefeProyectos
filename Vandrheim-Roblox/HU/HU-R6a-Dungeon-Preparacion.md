## HU-R6a: Dungeon — Preparación (enemigos, pisos, generación, XP, respawn)

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** Mazmorra / R6 (parte a — preparación)  
**Prioridad:** Crítica  
**Estado:** Completada (implementada; reporte equipo 2026-08-22)  
**Fase GDD:** R6 (se ejecuta en 2 HUs: R6a preparación + R6b core)  
**Depende de:** R0 (Places/estructura), R1/R3 (combate, target, skills), R4 (loot/rolls), R5 (oro), SKILLS_CATALOG, ASSETS_POLICY

---

### **Narrativa (INVEST)**

**Como** jugador,  
**quiero** poder enfrentar enemigos de mazmorra en pisos generados (con IA simple, XP y recompensas),  
**para** tener preparados todos los componentes de la mazmorra antes de juntarlos en la run completa (R6b).

---

### **Descripción del Requerimiento / Contexto**

Primera mitad de R6. Prepara **sin run real**: `EnemyConfig` (plantillas por piso + IA simple), `FloorService` (kit Helada + layout por seed, boss room al final, packs por presupuesto), `LootTables` por piso, **motor de XP/leveling** y **muerte/respawn del jugador**.

**Validación:** en una **arena de prueba** (debug/test, NO feature de jugador) para poder testear todo sin el teleport/reserved server (que llegan en R6b).

**Criterio de hecho (esta HU):** enemigos matables y pisos generables en la arena de prueba, con XP y respawn funcionando.

---

### **Especificaciones Técnicas / Contratos de API**

#### **EnemyConfig (ReplicatedStorage/Config — data-driven)**

```luau
{
  ["helada_ice_mite"] = {
    name = "Ácaro de escarcha",
    level = 4,                        -- nivel del piso donde aparece
    maxHp = 60,
    atk = 8, matk = 0, def = 3, mdef = 3,
    xpReward = 15,
    lootTable = "floor_1",
    ai = "melee",                     -- "melee" | "ranged" (IA simple)
    speed = 14, aggroRange = 20,
    weaponModel = "Modelo_arma_mite", -- placeholder (HU-ASSETS)
  },
  -- ...plantillas por piso (1–5) + mini-bosses
}
```

* **Plantilla por piso + variación entre runs** (GDD §8): spawns pueden variar combinaciones dentro del presupuesto del piso.
* **IA simple:** `melee` (chase + golpe en rango) / `ranged` (mantiene distancia + disparo). Daño **server**; reusan R1/R3 (target, auto-attack, skills).
* **Mini-bosses:** pisos 1–4 (GDD recomendado); piso 5 boss room queda **sin boss** (R7).

#### **FloorService (generación por seed)**

* **Kit Helada:** salas + conectores; layout **variado por seed** (mismo kit, distribución distinta).
* **Spawns de packs:** según **presupuesto del piso** (nivel fijo del piso — no escala al PJ).
* **Boss room:** sala fija al final del grafo (pisos 1–4 mini-boss; piso 5 boss room sin boss).
* Seed generado/validado en **server** (cliente nunca elige seed ni piso).

#### **Nivel de piso (defaults orientativos)**

| Piso | Nivel | Contenido |
|------|-------|-----------|
| 1 | ~4 | Packs 2–3 + mini-boss |
| 2 | ~7 | Packs + mini-boss |
| 3 | ~10 | Packs + mini-boss |
| 4 | ~13 | Packs + mini-boss |
| 5 | ~16 | Packs + boss room (sala; boss R7) |

#### **Motor de XP/leveling (en 6a)**

* `xp += xpReward(enemigo)` (server); `xpReq(nivel) = nivel * 100` (orientativo; balance R8).
* Al subir: `nivel+1`, stats base de clase escalan (`ClassConfig.perLevel`), MaxHP/MP refrescados, **+1 punto de talento cada 2 niveles** (R5).
* Level-up flash (no interrumpe combate).
* Integra con profile R2 (level/xp ya existían; ahora se llenan de verdad).

#### **Muerte/respawn del jugador (en 6a)**

* Enemigos **sí atacan** (a diferencia del dummy R1).
* Al morir: respawn en la **entrada del piso/arena** con HP/MP llenos (default; sin pérdida de XP ni oro).

#### **Loot / oro por enemigo**

* `LootTables` por piso en `Config/LootTables` (ítems comunes + chance de mejor rareza + oro).
* Reusan el flujo de R4 (rolls, bolsa, ventana de recompensa) y R5 (oro).

#### **Arena de prueba (test-only, NO feature)**

* Zona/Place de test (Studio/test flag) donde se pueden spawnear pisos y enemigos con `GrantFloor`/`SpawnEnemy` (debug), para QA de enemigos, generación, XP y respawn sin teleport.
* **No** debe ser accesible por jugadores en producción (flag/limitación de Studio).

#### **Remotes / intenciones (debug)**

| Remote | Dir | Payload | Nota |
|--------|-----|---------|------|
| `DebugSpawnFloor` | S→C cmd | `{ floorSeed, floorIndex }` | Solo Studio/test |
| `DebugSpawnEnemy` | S→C cmd | `{ templateId }` | Solo Studio/test |

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Arena de prueba disponible**

* **GIVEN** un entorno de test (Studio/test flag)
* **WHEN** se usa `DebugSpawnFloor`
* **THEN** se genera un piso del kit Helada con layout por seed
* **AND** hay spawns de packs según el presupuesto del piso

#### **Escenario 2: Enemigos matables (daño server)**

* **GIVEN** enemigos de un piso en la arena
* **WHEN** el jugador los ataca (auto-attack/skills, R1/R3)
* **THEN** reciben daño calculado en server
* **AND** mueren al llegar a 0 HP

#### **Escenario 3: Enemigos atacan al jugador**

* **GIVEN** un enemigo con IA simple en la arena
* **WHEN** el jugador entra en su rango de aggro
* **THEN** el enemigo lo persigue y ataca (melee o ranged)
* **AND** el jugador puede morir si no lo enfrenta

#### **Escenario 4: Respawn al morir**

* **GIVEN** el jugador muere en la arena/piso
* **WHEN** el server procesa la muerte
* **THEN** respawnea en la entrada del piso/arena con HP/MP llenos
* **AND** sin pérdida de XP ni oro (default)

#### **Escenario 5: XP y level-up**

* **GIVEN** el jugador mata enemigos
* **WHEN** acumula XP suficiente (`xpReq = nivel*100`)
* **THEN** sube de nivel
* **AND** los stats base escalan (perLevel), MaxHP/MP se refrescan
* **AND** recibe +1 punto de talento cada 2 niveles (R5)
* **AND** se muestra el aviso de level-up

#### **Escenario 6: Loot y oro por enemigo**

* **GIVEN** un enemigo muere
* **WHEN** el server tira su `LootTable`
* **THEN** los ítems y oro van a la bolsa (R4/R5)
* **AND** se muestra la ventana de recompensa

#### **Escenario 7: Layout variado por seed**

* **GIVEN** el kit Helada
* **WHEN** se generan dos pisos con seeds distintos
* **THEN** los layouts varían (mismo kit, distribución distinta)

#### **Escenario 8: Mini-boss (pisos 1–4)**

* **GIVEN** el final del grafo de un piso 1–4
* **WHEN** se llega a la sala final
* **THEN** hay un mini-boss con stats propios y loot mejor

#### **Escenario 9: Anti-exploit y estabilidad**

* **GIVEN** un cliente intenta forzar XP, stats o piso
* **WHEN** solo manipula estado local
* **THEN** el server rechaza
* **AND** el loop matar → subir de nivel → morir → respawn no produce errores rojos

---

### **Comportamiento Visual e Interfaz (UI/UX) / Reglas de Negocio**

* **Arena de prueba:** solo accesible con flag de test; no visible para jugadores reales.
* **Muerte:** feedback claro; respawn inmediato en la entrada (sin penalización).
* **Level-up:** aviso visible sin interrumpir el combate.
* **Enemigos:** modelos placeholder (primitivas) en 6a; estética real en paralelo con HU-ASSETS (no bloquea).
* Kit/mazmorra: tema Helada (paleta HU-ASSETS).

---

### **Alcance**

#### Incluye

* `EnemyConfig` data-driven (plantillas por piso + mini-bosses pisos 1–4)
* IA simple (melee/ranged): chase + ataque server
* `FloorService`: kit Helada + layout por seed, boss room al final, packs por presupuesto
* Motor de XP/leveling (xpReq, stats perLevel, talent points cada 2 niveles, level-up)
* Muerte/respawn del jugador (entrada del piso, sin pérdida)
* `LootTables` por piso (ítems + oro) + reward UI (R4/R5)
* Arena de prueba (test-only) con debug spawns

#### No incluye

* Teleport / ReservedServer / run lifecycle (R6b)
* Boss final piso 5 + cofre + uniques (R7)
* Party (R9), matchmaking (post-MVP)
* Reanudar run a mitad (GDD: no)
* IA compleja / threat real (R9)
* Estética final del kit (paralelo HU-ASSETS)

---

### **Definition of Done (DoD)**

* [ ] Arena de prueba: se generan pisos del kit con layout por seed
* [ ] Enemigos matables (daño server) y que atacan al jugador
* [ ] Muerte → respawn en entrada del piso/arena sin pérdida
* [ ] XP/leveling: stats escalan, puntos de talento cada 2 niveles, aviso
* [ ] Loot/oro por enemigo con reward UI (R4/R5)
* [ ] Layout varía por seed; mini-boss en pisos 1–4
* [ ] Cliente no puede forzar XP/stats/piso
* [ ] Sin errores rojos en el loop de prueba
* [ ] Nota "R6a completo" en GDD

---

### **Checklist Studio (referencia dev)**

* [ ] `EnemyConfig` (plantillas por piso + mini-bosses) + `LootTables`
* [ ] IA enemiga simple (melee/ranged, chase, daño server)
* [ ] `FloorService`: kit + generación por seed + boss room + packs por presupuesto
* [ ] Motor XP/leveling + stats perLevel + talent points
* [ ] Respawn del jugador al morir (sin pérdida)
* [ ] Loot/oro por enemigo + reward UI
* [ ] Arena de prueba con `DebugSpawnFloor`/`DebugSpawnEnemy` (solo test)
* [ ] Anti-exploit + sin errores

---

### **Decisiones por defecto R6a (si no se cambian)**

| Tema | Default |
|------|---------|
| Niveles de piso | P1 ~4 · P2 ~7 · P3 ~10 · P4 ~13 · P5 ~16 |
| Mini-boss | Pisos 1–4; piso 5 boss room (sin boss) |
| IA | melee/ranged simple; chase en aggroRange |
| xpReq | `nivel * 100` (orientativo; balance R8) |
| Respawn | Entrada del piso/arena, HP/MP llenos, sin pérdida |
| Puntos de talento | +1 cada 2 niveles (R5) |
| Arena | Solo test (flag Studio); no accesible en producción |

---

### **Estimación (orientativa)**

2–3 sesiones.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-12 | Split de HU-R6 en R6a (preparación) + R6b (core); XP/respawn pasan a R6a |
| 2026-08-22 | Marcada completada según reporte del equipo |
