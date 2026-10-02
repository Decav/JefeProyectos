# HU-ITEMS-06: Armas — templates por tier, espadón 2H y único nuevo (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Ítems / Armas / Contenido (dev)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Contenido de armas (dev)
**Fase GDD:** Ítems (mini-épica de itemización — ampliación de armas, plan cerrado con el PO 2026-09-22)
**Depende de:** HU-ESTETICA-34 (modelos/iconos), HU-ITEMS-04 (loot/uniques del piso 4), HU-ITEMS-03 (setId/sistema), HU-ESTETICA-18 (uniques existentes)
**Componentes observados:** `ItemConfig`, `LootTables`, `floor_4_boss` (uniquePool)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** armas con variedad real por tier (blanco/verde/azul/morado) en cada familia, incluido el **espadón 2H** del Paladín,
**para** que mi arma progrese conmigo y cada tier se sienta distinto.

**Como** Paladín Castigo,
**quiero** el **Espadón del Guardián de la Escarcha** (único 2H),
**para** tener el arma de dos manos definitiva de la Helada.

---

### **Descripción del Requerimiento / Contexto**

Plan de armas cerrado (PO 2026-09-22) + **Corrección 1 (2026-09-22, revisada con el dev)**:

* **Familias (5):** espada 1H · **espadón 2H (nuevo)** · arco · varita · escudo.
* **Tiers y niveles:** blanco **1** · verde **5** · azul **9** · **ÉPICA frost 16** · **uniques 14**.
* **Reconocimiento del juego (dev):** **morado = rareza ÉPICA** (UI morada, "ÉPICA"); el **tier interno de las épicas es `frost`** (igual que las armaduras `paladin_helmet_frost`). Las armas épicas ya registradas: `sword_champion`, `unique_frost_edge`, `unique_frostbow`, `unique_glacial_wand`. **Los modelos `*_frost_segmented` del diseñador son los modelos ÉPICOS** (catálogo en Workspace; esta HU los convierte en ítems).
* **Dos categorías de "morado" DISTINTAS:**
  * **ÉPICA frost (16):** rareza Epic — cae del **cofre del boss final** (35% pieza de tu clase, arma o armadura). Stats normales de épica.
  * **ÚNICA (14, del Señor de la Escarcha):** `unique_frost_*` — **mejores stats que la épica** — exclusivos del 4.º boss (drop automático). NO sustituyen a las épicas.
* **Drops:** blancas/verdes/azules de cualquier mob (pesos por piso/tier); **épicas frost del cofre del boss final**; **uniques solo del 4.º boss**.
* **Uniques (4):** Filo de la Escarcha (1H) · **Espadón del Guardián de la Escarcha (2H — NUEVO)** · Arco del Vendaval Helado · Vara del Invierno — todos del `floor_4_boss`.

**Criterio de hecho global:** existen los templates de armas por tier/familia con **nombres GENÉRICOS** (nunca por clase) en ReplicatedStorage, con levelReq correctos, stats por tier (multiplicadores de ITEMS-04), el mapa de modelos de EST-34 (Corrección 1 revisada), drops en los lugares correctos y el nuevo único 2H en el pool del Señor de la Escarcha.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Templates (ItemConfig) — NOMBRES GENÉRICOS**

**Regla (PO):** todos los nombres de armas son **genéricos por familia** en ReplicatedStorage — **NUNCA separados por clase** (sin prefijos `paladin_`/`hunter_`/`cleric_`). Patrón: `<familia>_<tier>`; el tier épico se llama **`frost`** (consistente con las armaduras: `paladin_helmet_frost` es Épica).

| Familia | Blanco (1) | Verde (5) | Azul (9) | **ÉPICA frost (16)** | **Única (14, jefe)** |
|---------|-----------|-----------|----------|----------------------|----------------------|
| Espada 1H | `sword_white` (modelo NUEVO — el actual se elimina) | `sword_green` | `sword_blue` (existe: `sword_knight` → **renombrar**) | `sword_frost` (modelo entregado ✓ — `sword_champion` → **renombrar** y recibir modelo) | `unique_frost_edge` (existe) |
| **Espadón 2H** | `greatsword_white` (base entregado) | `greatsword_green` | `greatsword_blue` | `greatsword_frost` (entregado ✓) | `unique_frost_greatsword` (nuevo) |
| Arco | `bow_white` (modelo actual **se mantiene** → renombrar `hunter_bow`) | `bow_green` | `bow_blue` | `bow_frost` (entregado ✓) | `unique_frostbow` (existe) |
| Varita | `wand_white` (**cleric wand se mantiene** → renombrar) | `wand_green` | `wand_blue` | `wand_frost` (entregado ✓) | `unique_glacial_wand` (existe) |
| Escudo | `shield_white` (modelo NUEVO — el actual se elimina) | `shield_green` | `shield_blue` | `shield_frost` (entregado ✓) | — |

* **Renombres obligatorios (genéricos):** `hunter_bow` → `bow_white` · `cleric_wand` → `wand_white` · `sword_knight` → `sword_blue` · `sword_champion` → `sword_frost` · `shield_guard` → se elimina (modelo nuevo) — y CUALQUIER otro con prefijo de clase.
* **Templates NUEVOS: 17** (cuenta verificada): espada×2 (`sword_white`, `sword_green`) + espadón×5 (`greatsword_white/green/blue/frost` + `unique_frost_greatsword`) + arco×3 (`bow_green/blue/frost`) + varita×3 (`wand_green/blue/frost`) + escudo×4 (`shield_white/green/blue/frost`). **Renombres: 4** (`sword_blue`, `sword_frost`, `bow_white`, `wand_white`). `shield_guard` se elimina.
* **Mapa de modelos (EST-34, Corrección 1 revisada):** `sword_white` y `shield_white` usan los **modelos nuevos** del diseñador; `bow_white` y `wand_white` mantienen los **modelos actuales**; épicas = los modelos `*_frost_segmented` entregados; uniques existentes con sus modelos EST-18.
* `wieldType` correcto (2H = `TwoHand`; espada/varita/escudo como ITEMS-01).
* Stats: ATK/MATK base por familia con los **multiplicadores de ITEMS-04** (verde ×1.4, azul ×1.9, **épica frost ×2.5**); **uniques = mejores que la épica** (power budget superior — el nuevo 2H único sigue el patrón de los 3 existentes: ATK 25 + afijos, lvl 14).
* `visualModelId`/`iconId` desde EST-34 (con fallback EST-01 si falta).

#### **2. Stats — BASELINE CERRADO (PO 2026-09-22)**

Bases blancas reales del juego (`sword_apprentice` ATK 8/2 en R4; `cleric_wand` MATK 6/2 en ITEMS-01) + multiplicadores de ITEMS-04 (verde ×1.4 · azul ×1.9 · épica ×2.5), redondeados:

| Familia | Blanco (1) | Verde (5) | Azul (9) | Épica frost (16) | Única (14) |
|---------|-----------|-----------|----------|------------------|------------|
| Espada 1H | ATK 8/2 | ATK 11/3 | ATK 15/4 | ATK 20/5 | ATK 25 + afijos (existe) |
| **Espadón 2H** | ATK 12/3 | ATK 17/4 | ATK 23/5 | ATK 28/6 | **ATK 32 + afijos (nuevo)** |
| Arco | ATK 7/2 | ATK 10/3 | ATK 13/4 | ATK 18/5 | ATK 24 + afijos (existe) |
| Varita | MATK 6/2 | MATK 8/3 | MATK 11/4 | MATK 15/5 | MATK 20 + afijos (existe) |
| Escudo | DEF 5/2 | DEF 7/3 | DEF 10/4 | DEF 13/5 | — |

* El **espadón 2H** ≈ 1.5× la espada 1H (trade-off: bloquea offhand, no escudo). El **único 2H** (32) supera a la épica 2H (28) y sigue el patrón de los 3 existentes (afijos, lvl 14).
* **AFINIDAD DEL ESPADÓN 2H (decisión PO 2026-09-22):** la familia 2H y su único (`unique_frost_greatsword`) reciben **`weaponAffinity` de Paladín** (Protector/Castigo) — hoy el espadón NO la tiene configurada. Con el bonus de afinidad (+10%), el único 2H pasa de 42 a ~46,2 ATK.
* **PENALIZACIÓN DE OFFHAND (decisión PO 2026-09-22, regla en ITEMS-01):** una 1H en `OffHand` aporta solo el **25% de su ATK** (resto de stats completas). Referencia de validación del RC: el 2H afinado (~46,2) debe superar al dual único+épica (~41,9–44,6 con la penalización).
* Los **uniques existentes NO se tocan** (mantienen sus stats/afijos actuales).
* Al renombrar/ajustar los templates existentes: **rareza alineada al tier** (blanco = Common · verde = Uncommon · azul = Rare · épica = Epic · único = Unique) y **levelReq según plan** (1/5/9/16/14).
* Balance fino en ITEMS-05 (dentro de las bandas de R8d/R9c).

#### **3. Cofre del boss final — decisión cerrada (PO 2026-09-22)**

* Dentro del **35% épico de tu clase** del cofre: **50% arma / 50% armadura** (slot aleatorio).
* **Armas épicas por clase** (peso igual entre las de su clase):
  * Paladín → `sword_frost`, `greatsword_frost`, `shield_frost` (1/3 cada una)
  * Cazador → `bow_frost`
  * Clérigo → `wand_frost`
* **Requiere extensión de `LootService`** (hoy solo elige armadura): se extiende la misma excepción aprobada en ITEMS-04 (§2.1) para elegir entre armas y armaduras épicas por `weaponAffinity`/clase. ITEMS-04 queda enmendado.

#### **4. Loot**

* **Pesos por piso (cerrados, patrón ITEMS-01: pesos ≤ 6, sin tocar `DropChance` de piso ni tablas de boss):**

| Tabla | Entradas nuevas (templateId = weight) |
|-------|----------------------------------------|
| `floor_1` | sword_white 6, bow_white 6, wand_white 6, greatsword_white 4, shield_white 4 |
| `floor_2` | sword_white 5, bow_white 5, wand_white 5, greatsword_white 3, shield_white 3, sword_green 3, bow_green 3, wand_green 3 |
| `floor_3` | sword_green 4, bow_green 4, wand_green 4, greatsword_green 3, shield_green 3, sword_blue 2, bow_blue 2, wand_blue 2 |
| `floor_4` | sword_green 3, bow_green 3, wand_green 3, greatsword_green 2, shield_green 2, sword_blue 3, bow_blue 3, wand_blue 3, greatsword_blue 2, shield_blue 2 |
| `floor_5` | sword_blue 4, bow_blue 4, wand_blue 4, greatsword_blue 3, shield_blue 3 |

* **"Azul 9+" aclarado:** el 9 es el **levelReq** (no el piso) — las azules caen de **pisos 3–5** (regla ITEMS-01: lvl 9 → pisos 3–4, piso 5 mezcla).
* **Épicas frost:** NUNCA en tablas de piso — solo el cofre del boss final (50% de la rama arma).
* **Uniques (4):** `floor_4_boss` `uniquePool` = frost_edge, frost_greatsword, frostbow, glacial_wand (misma chance por entrada; 20% de `floor_4_boss`, como ya está configurado — solo se añade el espadón al pool).

#### **3. Reglas**

* Todo data-driven; sin servicios de gameplay (la extensión de recompensa del boss final ya está aprobada en ITEMS-04).
* Sync places (PUBLICAR-04).
* Balance final en ITEMS-05.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Templates por tier**

* **GIVEN** los templates
* **WHEN** se revisa `ItemConfig`
* **THEN** existen las 5 familias con sus tiers (blanco/verde/azul/épica/único donde aplique) con levelReq 1/5/9/16/14 y stats por el baseline cerrado (tabla de PO)

#### **Escenario 1b: Cofre del boss final (arma o armadura)**

* **GIVEN** el cofre del boss final
* **WHEN** activa el 35% épico de clase
* **THEN** entrega 50% arma / 50% armadura épica de la clase (Paladín: espada/espadón/escudo a partes iguales; Cazador: arco; Clérigo: varita) — nunca uniques

#### **Escenario 2: Espadón 2H completo**

* **GIVEN** la familia del espadón 2H
* **WHEN** se equipa (2H, ocupa MainHand+OffHand)
* **THEN** funciona con `wieldType = TwoHand` (ITEMS-01) y cada tier usa su modelo

#### **Escenario 2b: Nombres genéricos**

* **GIVEN** los templates en ReplicatedStorage
* **WHEN** se revisan los nombres
* **THEN** todos son genéricos por familia (`sword_*`, `greatsword_*`, `bow_*`, `wand_*`, `shield_*`, `unique_frost_*`) — **sin prefijos de clase** (`paladin_`, `hunter_`, `cleric_`) y los existentes quedaron renombrados

#### **Escenario 3: Único 2H**

* **GIVEN** el Señor de la Escarcha
* **WHEN** muere (loot automático)
* **THEN** el pool de uniques incluye los 4 (Filo, **Espadón**, Arco del Vendaval, Vara) con su chance

#### **Escenario 4: Drops**

* **GIVEN** las armas por tier
* **WHEN** se mata en los pisos
* **THEN** caen con los pesos cerrados (blanco pisos 1–2, verde 2–4, **azul levelReq 9 → pisos 3–5**, épicas solo del cofre del boss final — nunca uniques, uniques solo del 4.º boss)

#### **Escenario 5: Regresión**

* **GIVEN** el contenido implementado
* **WHEN** se juega el flujo completo (loot → equipar → combatir → jefes → rejoin)
* **THEN** no hay errores rojos y las armas existentes (uniques incluidos) siguen funcionando

---

### **Alcance**

#### Incluye

* **17 templates nuevos** (cuenta verificada: espada×2 + espadón×5 + arco×3 + varita×3 + escudo×4) con **nombres genéricos**, renombres (4: sin prefijos de clase; `sword_champion`→`sword_frost`) y el mapa de modelos de EST-34 (Corrección 1 revisada).
* **Baseline de stats cerrado** (tabla por familia/tier) y **pesos de loot por piso cerrados**.
* **Extensión de `LootService`** para el cofre del boss final (arma 50% / armadura 50%, épicas por clase).
* Pool de 4 uniques en `floor_4_boss` (20%, como ya está — solo se añade el espadón).

#### No incluye

* Modelos/iconos (EST-34) ni balance final (ITEMS-05).

---

### **Definition of Done (DoD)**

* [ ] 5 familias con tiers completos (levelReq 1/5/9/16 y uniques 14) y stats del **baseline cerrado**.
* [ ] **Todos los nombres genéricos** en ReplicatedStorage (sin prefijos de clase; existentes renombrados).
* [ ] **ÉPICA frost (16)** distinta de los **uniques (14)** en stats y loot (cofre del boss final vs 4.º boss).
* [ ] **Cofre del boss final: 50% arma / 50% armadura** épica de clase (extensión de LootService) y **pesos de loot por piso** aplicados.
* [ ] Mapa de modelos de EST-34 (Corrección 1 revisada) aplicado: espada/escudo blancos nuevos, varita/arco blancos reusados, espadón con base nueva.
* [ ] Espadón 2H funcional (TwoHand) con su único Helada en el pool del piso 4.
* [ ] Sin errores rojos en el flujo completo (publicado).
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Decisiones por defecto ITEMS-06**

| Tema | Default |
|------|---------|
| Niveles de armas | Blanco 1 · Verde 5 · Azul 9 · **ÉPICA frost 16** · Uniques 14 |
| Uniques | 4 (incl. **Espadón del Guardián de la Escarcha 2H**) — solo del 4.º boss, **mejores stats que la épica** |
| Épicas (moradas) | **Rareza ÉPICA (UI "ÉPICA"), tier interno `frost`** (como las armaduras) — cofre del boss final (35% arma o armadura de tu clase) — **nunca uniques** |
| Nombres | **Genéricos por familia** en ReplicatedStorage (`sword_*`, `greatsword_*`, `bow_*`, `wand_*`, `shield_*`, `unique_frost_*`) — nunca por clase |
| Modelos (EST-34) | Épicas = entregadas ✓ (`*_frost_segmented`) · blancas: espada 1H y escudo NUEVOS (actuales eliminados), varita (cleric wand) y arco reusados, base 2H ✓ · verdes nuevas (5) · azules entregados ✓ |

---

### **Estimación (orientativa)**

2 sesiones del dev: templates + loot + pool de uniques + regresión.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-ITEMS-06: armas por tier — 5 familias (incl. espadón 2H nuevo) con niveles 1/5/9/16 (uniques 14), drops por piso/moradas del boss final, y el **único 2H nuevo** (Espadón del Guardián de la Escarcha) en el pool del Señor de la Escarcha |
| 2026-09-22 | **Corrección 1 (PO, alineada con EST-34):** **nombres GENÉRICOS** en ReplicatedStorage (nunca por clase — renombrar `hunter_bow`→`bow_white`, `cleric_wand`→`wand_white`, `sword_knight`→`sword_blue`, etc.); **dos categorías de morado**: morada NORMAL (16, cofre del boss final, nunca uniques) vs **uniques frost (14, del 4.º boss, mejores stats)**; reuso de modelos: varita (cleric wand) y arco actuales como blancos, espada 1H y escudo actuales ELIMINADOS (modelos nuevos); 17 templates nuevos |
| 2026-09-22 | **Corrección 1 REVISADA (aclaración del dev):** **morado = rareza ÉPICA, tier interno `frost`** → las épicas son `*_frost` (`sword_frost` renombra a `sword_champion`; las demás épicas usan los modelos `*_frost_segmented` entregados ✓); uniques = `unique_frost_*` (14, 4.º boss, mejores stats) — NO sustituyen a las épicas; blancas: espada+escudo modelos nuevos (actuales eliminados), varita/arco reusados, base 2H entregada; verdes nuevas (5); **13 templates nuevos** |
| 2026-09-22 | **Ajuste de balance cerrado (PO, para el RC):** (1) **afinidad del espadón 2H y su único = Paladín** (Protector/Castigo) — hoy no configurada (con +10% el único pasa a ~46,2 ATK); (2) **penalización de offhand: 25% del ATK** para 1H en `OffHand` (solo ATK; regla documentada en ITEMS-01) — valor inicial a validar en el RC: el 2H debe superar al dual 1H+1H (~46,2 vs ~41,9–44,6) |