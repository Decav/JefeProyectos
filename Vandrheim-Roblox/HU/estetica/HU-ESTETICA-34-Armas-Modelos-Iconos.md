# HU-ESTETICA-34: Armas — modelos e iconos por tier + único de espadón 2H (diseñador)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Ítems / Armas / Diseño
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Producción de modelos e iconos de armas (diseñador) — el dev integra por config
**Fase GDD:** Ítems (mini-épica de itemización — ampliación de armas, plan cerrado con el PO 2026-09-22)
**Depende de:** HU-ESTETICA-01/05 (pipeline HandModel, arco), HU-ESTETICA-18 (uniques existentes), HU-ITEMS-06 (templates), ASSETS_POLICY/ASSETS_LIST
**No modifica:** stats, loot ni balance (solo assets)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que cada arma de tier **azul y morado** tenga su propio modelo (ya no compartir el de blanco/verde),
**para** que el progreso de armas se sienta visual y cada tier se distinga.

**Como** Paladín Castigo,
**quiero** el **espadón 2H** con su tier único Helada,
**para** que mi arma de dos manos tenga identidad propia.

---

## ⚠️ CORRECCIÓN 1 (PO, 2026-09-22) — revisada con el dev 2026-09-22

### Reconocimiento actual del juego (confirmado por el dev)

* **Morado = rareza ÉPICA** (UI morada, "ÉPICA"). El **tier interno de las épicas es `frost`** (igual que las armaduras: `paladin_helmet_frost` es Épica).
* **Los modelos entregados `*_frost_segmented` SON las armas ÉPICAS** — NO son los uniques del jefe. **Están correctos y se integran como épicas** (están en Workspace/catálogo; la HU ITEMS-06 los convierte en ítems).
* **Uniques del jefe (registrados en ItemConfig):** `unique_frost_edge`, `unique_frostbow`, `unique_glacial_wand` (existen, EST-18) + `unique_frost_greatsword` (nuevo, entregado ✓). Épica existente genérica: `sword_champion` (modelo compartido — recibe el modelo nuevo).
* **No se rehicieron modelos de uniques:** las réplicas detectadas eran en realidad los modelos épicos (los uniques existentes tienen sus propios modelos EST-18).

### Lo que SÍ falta (producir)

| Tier (nivel) | Espada 1H | Espadón 2H | Arco | Varita | Escudo |
|---|---|---|---|---|---|
| **Blanco (1)** | **NUEVO** (la actual se ELIMINA) | **Base** (entregado ✓) | **Actual se MANTIENE** (reuso) | **Cleric wand se MANTIENE** (reuso) | **NUEVO** (el actual se ELIMINA) |
| **Verde (5)** | **NUEVO** | **NUEVO** | **NUEVO** | **NUEVO** | **NUEVO** |
| **Azul (9)** | Entregado ✓ | Entregado ✓ | Entregado ✓ | Entregado ✓ | Entregado ✓ |
| **ÉPICA frost (16)** | Entregado ✓ (frost) | Entregado ✓ (frost) | Entregado ✓ (frost) | Entregado ✓ (frost) | Entregado ✓ (frost) |
| **Único (14, jefe)** | Filo — EXISTE, no rehacer | Guardián — entregado ✓ | Vendaval — EXISTE, no rehacer | Vara — EXISTE, no rehacer | — |

**Resumen: producir 7 modelos nuevos** = 2 blancas (espada, escudo) + 5 verdes. Las épicas frost entregadas se conservan tal cual.

**Distinción visual obligatoria:**
- **Épica frost:** estilo hielo del tier épico — forja/cristal con brillo frío, **SIN** la ornamentación superior de los uniques.
- **Único (EST-18):** estilo Helada especial (runas `Neon` azul pálido) — se ve claramente superior a la épica.

**Iconos:** nuevos para cada modelo nuevo (2 blancas + 5 verdes = **7 iconos nuevos**); los iconos de varita/arco blancos = recolors de los existentes; los de épicas frost y uniques ya están.

**Nombres (todos GENÉRICOS por familia, nunca por clase):** `sword_<tier>`, `greatsword_<tier>`, `bow_<tier>`, `wand_<tier>`, `shield_<tier>` (`white/green/blue/frost`); uniques: `unique_frost_edge`, `unique_frost_greatsword`, `unique_frostbow`, `unique_glacial_wand` — los archivos e iconos se nombran igual (el dev usa estos nombres en ReplicatedStorage).

---

### **Descripción del Requerimiento / Contexto**

La itemización agregó armaduras pero las armas quedaron planas (las 4 espadas comparten modelo; arco/varita tienen uno solo). Plan de armas cerrado (PO):

* **Familias (5):** espada 1H · **espadón 2H (nuevo)** · arco · varita · escudo.
* **Tiers:** blanco 1 · verde 5 · azul 9 · morado 16 · **uniques 14** (solo del 4.º boss).
* **Modelos nuevos SOLO azul y morado** por familia; blancas/verdes mantienen el actual (recolor opcional).
* **Nuevo único: Espadón del Guardián de la Escarcha (2H)** — el 4.º unique, exclusivo del Señor de la Escarcha.

**Criterio de hecho global:** existen los modelos de las armas azul y morado (5 familias), el modelo base del espadón 2H, el modelo del único 2H Helada, y los iconos correspondientes — listos para enlazar en ITEMS-06.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Modelos nuevos**

| Familia | Azul | Morado (Helada) | Extra |
|---------|------|-----------------|-------|
| Espada 1H | Modelo propio (forja refinada) | Modelo Helada (cristales/runas) | — |
| **Espadón 2H (nuevo)** | Modelo propio (2H grande) | Modelo Helada (2H) | **Modelo base blanco/verde** (no existe hoy) |
| Arco | Modelo propio (madera reforzada) | Modelo Helada (arco de hielo) | — |
| Varita | Modelo propio (madera/gema) | Modelo Helada (cristal) | — |
| Escudo | Modelo propio | Modelo Helada (escudo de hielo) | — |
| **Único 2H** | — | — | **Espadón del Guardián de la Escarcha** (estilo EST-18: hielo/cristal, silueta grande) |

* Total: **10 modelos de tier** (azul + morado × 5 familias) + **1 modelo base de espadón** + **1 único 2H** = 12 modelos.
* Pipeline: `HandModel` con `attachTo` (RightHand; escudo LeftHand — patrón EST-01/05), `visualModelId` por template, sin scripts.
* Estilo morado: familia de los uniques EST-18 (hielo, runas `Neon` azul pálido).

#### **2. Iconos (ASSETS_LIST)**

* Nuevos: azul + morado por familia (10) + **único 2H (1)** = 11 iconos (`Icon_Item_<arma>_<tier>`, ej. `Icon_Item_sword_blue`, `Icon_Item_greatsword_frost`, `Icon_Item_unique_frost_greatsword`).
* Blanco/verde: recolor de los existentes (se registran).
* Estándar ASSETS_LIST (512×512, fondo negro, paleta Vandrheim).

#### **3. Reglas**

* Solo assets; sin stats ni loot (ITEMS-06/05).
* Los modelos actuales (blanco/verde) no se modifican salvo el recolor si aplica.
* Fallback EST-01 si falta un modelo (el ítem sigue siendo equipable como dato).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Modelos por tier**

* **GIVEN** los modelos entregados
* **WHEN** se equipan armas azul y morado de cada familia
* **THEN** se ven modelos propios, distintos entre sí y del blanco/verde (morado con temática Helada)

#### **Escenario 2: Espadón 2H completo**

* **GIVEN** la familia del espadón
* **WHEN** se revisa
* **THEN** existe el modelo base (blanco/verde), el azul, el morado y el **único 2H Helada** — todos con silueta grande de dos manos

#### **Escenario 3: Iconos**

* **GIVEN** los iconos
* **WHEN** se revisa ASSETS_LIST
* **THEN** cada arma/tier tiene su icono (11 nuevos + recolors) con el estándar

#### **Escenario 4: Entrega válida**

* **GIVEN** la entrega
* **WHEN** se inspecciona
* **THEN** modelos sin scripts, registrados, y las bases existentes intactas

---

### **Alcance**

#### Incluye

* 12 modelos (10 de tier azul/morado + base de espadón + único 2H Helada).
* 11 iconos nuevos (azul/morado por familia + único 2H) + recolors de blanco/verde.

#### No incluye

* Stats, loot ni balance (ITEMS-06/05).
* Templates (ITEMS-06).

---

### **Definition of Done (DoD)**

* [ ] 12 modelos entregados (espada/2H/arco/varita/escudo azul+morado, base 2H, único 2H).
* [ ] 11 iconos nuevos en ASSETS_LIST (+ recolors).
* [ ] Registrados en ASSETS_REGISTRY; bases intactas; sin scripts.
* [ ] Reporte al PM con el detalle y pendientes.

---

### **Estimación (orientativa)**

2–3 sesiones del diseñador: modelos de armas + iconos.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-ESTETICA-34: armas por tier — modelos propios azul/morado por familia (5), base + tiers del espadón 2H, único 2H Helada (Espadón del Guardián de la Escarcha) y 11 iconos nuevos; plan cerrado con el PO |
| 2026-09-22 | **CORRECCIÓN 1 (PO):** la entrega replicó los uniques frost existentes (espada/arco/varita — se descartan las réplicas), no produjo **moradas NORMALES** (distintas de los uniques del jefe) ni blancas/verdes → **12 modelos nuevos** (2 blancas: espada+escudo que reemplazan a los actuales eliminados · 5 verdes · 5 moradas normales no-frost); reuso: varita (cleric wand) y arco actuales como blancos, base de espadón ya entregado; **nombres genéricos por familia** (nunca por clase); distinción visual morada normal vs único frost obligatoria |
| 2026-09-22 | **CORRECCIÓN 1 REVISADA (aclaración del dev):** morado = rareza **ÉPICA** (UI "ÉPICA"), tier interno `frost` (como `paladin_helmet_frost`) → **los modelos `*_frost_segmented` entregados SON las épicas (correctos, se integran)**; no se rehicieron uniques (los existentes EST-18 tienen sus modelos propios); épica genérica existente `sword_champion` recibe el modelo nuevo → **solo faltan 7 modelos** (2 blancas: espada+escudo · 5 verdes) + 7 iconos |