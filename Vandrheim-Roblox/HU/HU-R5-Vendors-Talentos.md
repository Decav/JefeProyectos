## HU-R5: Vendors, economía (oro) y talentos (spec + respec)

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** Economía / Progresión / R5  
**Prioridad:** Alta  
**Estado:** Completada (implementada; reporte equipo 2026-08-12)  
**Fase GDD:** R5  
**Depende de:** HU-R2 (oro/puntos en profile), HU-R4 (inventario, vender ítems), HU-R3 (loadout restringido por spec), SKILLS_CATALOG.md

---

### **Narrativa (INVEST)**

**Como** jugador,  
**quiero** comprar y vender con oro en el pueblo, elegir mi spec con puntos de talento y poder resetearla pagando,  
**para** cerrar el loop económico mínimo y que la identidad de build sea real y corregible (sin quedar atrapado en una decisión).

---

### **Descripción del Requerimiento / Contexto**

Fase R5 del GDD (§4 Clases/specs, §6 Progresión, §7 Economía, §8 Mundo, §12 Servicios, §14 Plan): `VendorService`, oro como moneda persistente, **talentos (6 nodos por árbol, ranks, 1 punto cada 2 niveles)** y **respec con oro** que incluye la elección de spec única activa.

**Criterio de hecho global GDD:** "Loop económico mínimo" — el oro entra (loot/ventas) y sale (vendor, respec), y la spec + talentos se eligen/corrigen en el pueblo.

---

### **Especificaciones Técnicas / Contratos de API**

#### **NPCs del hub (GDD §8)**

| NPC | Función |
|-----|---------|
| Vendedor de consumibles | Pociones HP/MP |
| Armero / herrero | Gear básico (blanco/verde) + armas; compra ítems del jugador |
| Trainer (respec) | Elegir/cambiar spec + respec de talentos con oro |

#### **VendorService (server)**

* **Comprar:** ítem de la tienda → oro del profile baja, ítem nuevo (con roll) va a la bolsa (si hay espacio).
* **Vender:** ítem de la bolsa (o equipado bound) → oro sube, ítem se elimina.
* **Precios (defaults):** tabla por rarity en `Config/VendorConfig`:

| Rareza | Precio compra (ej.) | Precio venta (ej.) |
|--------|--------------------|--------------------|
| Blanco | 20 | 5 |
| Verde | 60 | 15 |
| Azul | 200 | 40 |
| Morado | 500 | 100 |

Consumibles: 10 oro (Poción HP) / 10 oro (Poción MP). (Ajustable; balance R8.)
* **Vender ítems bound:** permitido (GDD: trade es lo restringido; vender a NPC sí).

#### **Consumibles (nuevo ítem tipo)**

* Nuevo `ItemConfig.type = "Consumable"` (default: Poción HP +30, Poción MP +30).
* Uso: `RequestUseConsumable` → server valida (existe, bolsa), aplica cura/maná, consume 1.
* **CD de uso compartido:** 30 s entre pociones (default) — evita spameo; feedback en UI.

#### **Oro**

* `profile.gold` (ya existe desde R2), server-authoritative.
* Entradas R5: venta a vendor + debug grant (Studio). Entradas reales por loot: R6–7.
* Guardar en los mismos eventos de persistencia (leave/shutdown/autosave + tras cada transacción).

#### **Talentos (GDD §4/§6)**

* **Puntos:** 1 cada 2 niveles → `puntos = floor(nivel / 2)` (lvl 20 → 10 puntos).
* **Árbol:** 6 nodos por spec, **ranks** (maxRank 3), efecto por rank (pasivos).
* **Elegir spec:** al gastar el **primer punto de talento** se elige la spec (o directamente en el trainer). Loadout queda restringido a **básicas + spec elegida** (SKILLS_CATALOG); no mezclar skills de ambas specs (GDD).
* **Efectos de nodos (pasivos):** suman al cálculo de stats = clase base + equip (R4) + talentos. Ej. +%MaxHP, +%ATK, +%DEF, +CRIT, CDR, +%MaxMP.
* **Respec:** devuelve todos los puntos gastados y permite cambiar de spec. **Costo:** oro (default: **100 oro** plano MVP). Repetible (no es permanente; GDD).

#### **TalentConfig (ReplicatedStorage/Config — data-driven)**

```luau
{
  ["paladin_protector"] = {
    specId = "Paladin_Protector",
    nodes = {
      ["fortaleza"] = { name="Fortaleza", maxRank=3, perRank = { MaxHPMult = 0.05 } },
      ["hierro"]     = { name="Hierro",     maxRank=3, perRank = { DEFMult   = 0.04 } },
      ["devocion"]   = { name="Devoción",   maxRank=3, perRank = { ATKMult   = 0.03 } },
      ["vigor"]      = { name="Vigor",      maxRank=3, perRank = { MaxMPMult = 0.05 } },
      ["fe"]         = { name="Fe inquebrantable", maxRank=3, perRank = { CooldownReduction = 0.02 } },
      ["aura"]       = { name="Aura sagrada", maxRank=3, perRank = { CritBonus = 0.03 } },
    },
  },
  -- ...resto de specs (contenido completo en R8; en R5 solo Paladín Protector tiene nodos finales)
}
```

* **Contenido R5 (default):** framework 6 nodos para las 6 specs; **nodos finales solo en Paladín Protector**; el resto con nodos genéricos temporales (mismos efectos placeholder) hasta R8.
* Sin prerequisitos entre nodos en MVP (simplificación; 2 columnas visuales).

#### **Remotes / intenciones**

| Remote | Dir | Payload | Validación server |
|--------|-----|---------|-------------------|
| `RequestVendorList` | C→S | `{ vendorId }` | Catálogo del NPC |
| `RequestBuyItem` | C→S | `{ vendorId, templateId, qty }` | Oro suficiente, espacio en bolsa, qty ≥ 1 |
| `RequestSellItem` | C→S | `{ instanceId }` | Ítem del PJ (bolsa o equipado) |
| `RequestUseConsumable` | C→S | `{ instanceId }` | Es consumible, en bolsa, CD listo |
| `RequestSpendTalentPoint` | C→S | `{ nodeId }` | Puntos disponibles, nodo de su spec, rank < maxRank; primer punto elige spec |
| `RequestRespec` | C→S | `{ newSpecId? }` | En el pueblo (NPC), oro suficiente; devuelve puntos, cambia spec si se pide |

#### **UI**

* **Ventana de vendor:** lista/catálogo con precios, botón comprar; pestaña "vender" para ítems del PJ (precio de venta); cursor normal con ventana abierta (drag de cámara pausado, igual que inventario R4).
* **Ventana de talentos:** árbol 6 nodos por spec, puntos disponibles, tooltip con efecto por rank; botón respec (muestra costo y advertencia de confirmación).
* **Feedbacks:** "Oro insuficiente", "Bolsa llena", "En recarga (poción)", "Sin puntos de talento".
* **HUD:** mostrar oro en el HUD (junto a HP/MP).
* PC primero; móvil básico con Scale.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Vendor abre y muestra catálogo**

* **GIVEN** un NPC vendor en el hub
* **WHEN** el jugador lo interactúa (proximidad + tecla o click)
* **THEN** se abre la ventana con el catálogo (consumibles, gear, armas) y sus precios

#### **Escenario 2: Comprar con oro**

* **GIVEN** el jugador tiene oro suficiente y espacio en bolsa
* **WHEN** compra un ítem del catálogo
* **THEN** el oro baja según precio
* **AND** el ítem aparece en la bolsa (con roll generado por server)

#### **Escenario 3: Comprar sin oro**

* **GIVEN** el jugador tiene oro insuficiente
* **WHEN** intenta comprar
* **THEN** el server rechaza
* **AND** la UI muestra "Oro insuficiente"

#### **Escenario 4: Vender ítem**

* **GIVEN** el jugador tiene un ítem en la bolsa (o equipado)
* **WHEN** lo vende en el vendor
* **THEN** el ítem se elimina
* **AND** el oro sube según la tabla de venta por rarity
* **AND** un ítem bound también se puede vender a NPC

#### **Escenario 5: Usar consumible**

* **GIVEN** el jugador tiene una poción en la bolsa y HP/MP < máximo
* **WHEN** la usa
* **THEN** cura/restaura según la poción (server)
* **AND** el ítem se consume (1)
* **AND** entra en CD compartido de 30 s (rechaza uso inmediato con feedback)

#### **Escenario 6: Gastar punto de talento elige spec**

* **GIVEN** un PJ sin spec elegida (nivel ≥ 2, tiene puntos)
* **WHEN** gasta su primer punto en un nodo
* **THEN** queda elegida la spec de ese árbol
* **AND** el loadout queda restringido a básicas + skills de esa spec (SKILLS_CATALOG)

#### **Escenario 7: Efecto de nodo aplica**

* **GIVEN** un nodo con ranks
* **WHEN** el jugador gasta puntos hasta rank 3
* **THEN** el efecto por rank se refleja en los stats del PJ (server; ej. MaxHP, ATK, DEF)
* **AND** se ve el rank actual en la UI del árbol

#### **Escenario 8: Respec con oro**

* **GIVEN** el jugador en el trainer con puntos gastados y oro suficiente
* **WHEN** confirma el respec (opcional: con nueva spec)
* **THEN** todos los puntos se devuelven
* **AND** el oro baja según el costo (default 100)
* **AND** si pidió nueva spec, el loadout se restringe a la nueva (básicas + nueva spec)
* **AND** el respec es repetible

#### **Escenario 9: Persistencia**

* **GIVEN** el jugador con oro, talentos, spec y consumibles
* **WHEN** sale y vuelve a entrar
* **THEN** todo se mantiene (oro, puntos gastados, spec, bolsa)

#### **Escenario 10: Anti-exploit y estabilidad**

* **GIVEN** un cliente intenta comprar sin oro, vender ítems ajenos, gastar puntos de más o respec sin pago
* **WHEN** solo manipula estado local
* **THEN** el server rechaza todas las transacciones inválidas
* **AND** el flujo comprar → vender → gastar talento → respec → rejoin no produce errores rojos

---

### **Comportamiento Visual e Interfaz (UI/UX) / Reglas de Negocio**

* **Ventanas de vendor/talentos:** pausan el drag de cámara (R3.1) y muestran cursor normal mientras están abiertas; se restaura al cerrar.
* **Precios de venta < precio de compra** (evitar farm de oro infinito); sin reventa rentable.
* **Respec:** advertencia/confirmación antes de gastar oro (cambio de spec no es reversible gratis).
* **Consumibles:** íconos placeholder (ASSETS_POLICY); tooltip con efecto real.
* **Oro en HUD:** junto a HP/MP (server replica).
* **NPC interactuable:** proximidad + interacción; sin diálogo complejo (mensaje corto + ventana).

---

### **Alcance**

#### Incluye

* 3 NPCs del hub (consumibles, gear/armas, trainer)
* VendorService: comprar, vender, precios por rarity (config)
* Oro persistente en profile; HUD de oro
* Consumibles: Poción HP/MP (+30), CD compartido 30 s
* Talentos: 6 nodos/spec, maxRank 3, pasivos aplicados a stats (clase+equip+talentos)
* Spec elegida con el primer punto; loadout restringido (básicas + spec)
* Respec con oro (100), devuelve puntos, puede cambiar spec
* TalentConfig data-driven + UI de árbol
* Debug grant de oro (Studio) hasta que R6–7 den loot real

#### No incluye

* Loot de dungeon/boss con oro real (R6–7)
* Trade entre jugadores (post-MVP)
* Diálogos/NPCs con quests
* Más consumibles (elixires, buffs de comida)
* Talentos con prerequisitos complejos / builds duales
* Compraventa entre jugadores (AH/post-MVP)
* Contenido final de nodos para las otras 5 specs (R8)

---

### **Definition of Done (DoD)**

* [ ] Play Solo: ganar oro (debug/venta) → comprar consumible/gear → vender ítem → gastar talentos → respec
* [ ] Spec elegida restringe loadout (básicas + spec; sin mezclar)
* [ ] Efectos de talentos se reflejan en stats y en daño/cura (R3/R4)
* [ ] Respec devuelve puntos y cambia spec con pago de 100 oro (repetible)
* [ ] Pociones curan con CD de 30 s y se consumen
* [ ] Cliente no puede comprar/vender/respec inválido
* [ ] Oro, talentos, spec y consumibles persisten tras rejoin
* [ ] Sin errores rojos en el loop completo
* [ ] Nota "R5 completo" en GDD

---

### **Checklist Studio (referencia dev)**

* [ ] `VendorConfig` (precios) + `TalentConfig` (6 nodos × 6 specs; finales solo Protector)
* [ ] `VendorService` (server): buy/sell, oro, validaciones
* [ ] Consumibles: tipo nuevo en ItemConfig + uso con CD 30 s
* [ ] Talentos: gastar puntos (1/2 niveles), elegir spec en primer punto, pasivos aplicados
* [ ] Respec: costo 100, devuelve puntos, cambia spec
* [ ] Restricción de loadout por spec (básicas + spec activa)
* [ ] Remotes: vendor list/buy/sell, use consumable, spend talent, respec
* [ ] UI: ventana vendor (comprar/vender), árbol de talentos, HUD oro
* [ ] Compatibilidad: ventanas pausan drag de cámara (R3.1)
* [ ] Persistencia oro/talentos/spec/consumibles + anti-exploit

---

### **Decisiones por defecto R5 (si no se cambian)**

| Tema | Default |
|------|---------|
| Puntos de talento | `floor(nivel/2)` (1 cada 2 niveles; ~10 a lvl 20) |
| Nodos | 6 por spec, maxRank 3, sin prerequisitos |
| Contenido nodos | Finales solo Paladín Protector; resto genérico hasta R8 |
| Spec | Se elige con el primer punto de talento (o en trainer); loadout restringido |
| Respec | 100 oro plano, repetible; devuelve todos los puntos |
| Precios | Tabla por rarity (20/60/200/500 compra; 5/15/40/100 venta) |
| Pociones | HP +30 / MP +30; CD compartido 30 s; 10 oro cada una |
| Vender bound | Permitido (NPC sí; trade jugador no) |
| Oro | Profile (R2); entradas R5: ventas + debug grant; loot real en R6–7 |

---

### **Estimación (orientativa)**

3–5 sesiones (vendors + talentos + respec suelen ser el cuello de botella).

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-12 | Alta HU-R5 al cerrar R4; producción pasa a R5 |
| 2026-08-12 | Marcada completada según reporte del equipo; producción pasa a R6 |
| 2026-08-12 | **Sistema de talentos de R5 reemplazado por R5.1** (árbol WoW + spellbook; SKILLS_CATALOG v2). Vendors/economía/oro de R5 siguen vigentes |
| 2026-08-22 | Stacking de inventario extraído a `HU-R5.2-Inventario-Stacking.md`/`rc011`; no modifica el alcance cerrado de R5 ni `rc010` |
