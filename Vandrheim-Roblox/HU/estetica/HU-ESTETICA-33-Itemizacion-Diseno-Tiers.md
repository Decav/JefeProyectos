# HU-ESTETICA-33: Itemización — modelos e iconos de los tiers por clase (diseñador)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Ítems / Itemización / Diseño
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Producción de modelos/reskins e iconos (diseñador) — el dev integra por config
**Fase GDD:** Ítems (mini-épica de itemización — plan cerrado con el PO 2026-09-22)
**Depende de:** HU-ESTETICA-01 (pipeline visual R15), HU-ESTETICA-07 (sets Cazador/Clérigo), HU-ITEMS-03/04 (bonos y contenido), ASSETS_POLICY/ASSETS_LIST
**No modifica:** stats, loot ni balance (solo assets)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que cada tier de equipo se vea distinto (blanco/verde/azul/morado Helada) en mi personaje y en mis iconos,
**para** que la progresión de itemización se sienta visual (miro mi personaje y veo mi tier).

---

### **Descripción del Requerimiento / Contexto**

Mini-épica de itemización (plan cerrado): tiers **blanco, verde, azul y morado (Helada)** para las 3 clases, 5 piezas cada uno. Esta HU produce los **assets**:

* **Modelos sobre la malla: SOLO casco y hombreras** (el resto son reskins del body; collar/anillo sin visual — regla existente).
* **Reskins del body** para pecho, guantes y piernas por tier (recolor/refit de la base por clase).
* **Iconos** por pieza y tier.

**Criterio de hecho global:** existen los modelos de casco/hombreras y los reskins del body para los tiers **azul y morado Helada** (los blancos/verdes son variantes de los sets existentes), más los iconos de cada pieza/tier — listos para enlazar por config (ITEMS-04).

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Modelos (solo casco y hombreras)**

| Tier | Modelos nuevos | Estilo |
|------|----------------|--------|
| **Azul** | Casco + hombreras × 3 clases (6) | Variante más trabajada del set de clase (diseño propio, no recolor del verde): placas reforzadas, acentos fríos |
| **Morado (Helada)** | Casco + hombreras × 3 clases (6) | **Temática Helada** (familia de los uniques EST-18): cristales de hielo, runas `Neon` azul pálido, metal frío oscuro |

* Pipeline EST-01: `ModelAccessory` (HatAttachment/BodyFrontAttachment), `visualModelId` por template, `Anchored=false`, sin scripts.
* Los blancos/verdes **reusan** los modelos existentes (no se modelan de nuevo).

#### **2. Reskins del body (pecho, guantes, piernas)**

* Recolor/refit de la base por clase por tier:
  * **Azul**: tono más frío/refinado, detalles extra.
  * **Morado Helada**: base + placas de hielo/cristales (textura `Ice` en acentos, runas).
* `BodySkin` (patrón EST-01/07: `paladin_r15_body_skin_new`, bodySkinParts por pieza).
* 3 clases × 3 piezas × 2 tiers = **18 reskins**.

#### **3. Iconos (ASSETS_LIST)**

* Iconos por pieza y tier (patrón `Icon_Item_<clase>_<pieza>_<tier>`, ej. `Icon_Item_paladin_chest_frost`):
  * **Blanco/verde**: recolor de los existentes (se actualizan/registran).
  * **Azul**: nuevos (15).
  * **Morado Helada**: nuevos (15).
* Estándar ASSETS_LIST (512×512, fondo negro, paleta Vandrheim).
* Entrega: iconos subidos (dev) + ASSETS_REGISTRY.

#### **4. Reglas**

* Solo assets; sin stats ni loot (ITEMS-03/04).
* Los modelos existentes (bases) no se modifican — los tiers son piezas nuevas.
* Fallback EST-01 si falta un modelo (el ítem sigue siendo equipable como dato).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Modelos por tier**

* **GIVEN** los modelos entregados
* **WHEN** se equipan casco/hombreras azul y morado en cada clase
* **THEN** se ven distintos entre sí y del blanco/verde (el morado con temática Helada)

#### **Escenario 2: Reskins del body**

* **GIVEN** los reskins por tier
* **WHEN** se equipan pecho/guantes/piernas
* **THEN** el body refleja el tier (azul frío refinado; morado con placas de hielo)

#### **Escenario 3: Iconos**

* **GIVEN** los iconos
* **WHEN** se revisa ASSETS_LIST
* **THEN** cada pieza/tier tiene su icono con el estándar y ids coherentes (ITEMS-04)

#### **Escenario 4: Entrega válida**

* **GIVEN** la entrega
* **WHEN** se inspecciona
* **THEN** modelos sin scripts, registrados, y las bases existentes intactas

---

### **Alcance**

#### Incluye

* 12 modelos (casco + hombreras azul/morado × 3 clases).
* 18 reskins del body (pecho/guantes/piernas azul/morado × 3 clases).
* Iconos (azul 15 + morado 15 nuevos + recolor blanco/verde) en ASSETS_LIST.

#### No incluye

* Stats, loot, bonos de set (ITEMS-03/04/05).
* Modelos de pecho/guantes/piernas (son reskins, no modelos nuevos).
* Collar/anillo (sin visual — regla existente).

---

### **Definition of Done (DoD)**

* [ ] 12 modelos de casco/hombreras entregados (azul + morado Helada).
* [ ] 18 reskins del body entregados (azul + morado).
* [ ] Iconos por pieza/tier en ASSETS_LIST (blanco/verde recolor, azul y morado nuevos).
* [ ] Registrados en ASSETS_REGISTRY; bases intactas; sin scripts.
* [ ] Reporte al PM con el detalle y pendientes.

---

### **Estimación (orientativa)**

3–4 sesiones del diseñador: modelos + reskins + iconos.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-ESTETICA-33: assets de la itemización — modelos (solo casco/hombreras azul y morado Helada × 3 clases), 18 reskins del body y 30 iconos nuevos (más recolors); plan cerrado con el PO |