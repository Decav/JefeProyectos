# HU-ESTETICA-18: Uniques del boss final — modelos 3D e iconos (Filo de la Escarcha, Arco del Vendaval Helado, Vara del Invierno)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / Equipamiento visual
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Producción de assets (diseñador: modelos + iconos) + integración mínima (dev: enlazar por config)
**Fase GDD:** R7 (recompensa del boss) / transversal EST
**Depende de:** HU-ESTETICA-01 (pipeline visual R15/HandModel y estructura de Assets), HU-ESTETICA-05 (patrón arco: modelo diseñador + enlace dev), HU-R7 (uniques en `floor_5_boss`), HU-ITEMS-01 (wieldType: frost_edge `OneHand`, frostbow `TwoHand`, glacial_wand `MainHandOnly`), ASSETS_POLICY/ASSETS_LIST
**No modifica:** loot del boss, stats de los uniques, balance ni economía

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que los ítems épicos que dropea el Guardián de la Escarcha (piso 5) tengan modelo 3D e icono propios,
**para** que la recompensa final del dungeon se sienta épica y distinta de los ítems comunes.

**Como** equipo de desarrollo,
**quiero** los 3 modelos e iconos de los uniques listos y registrados,
**para** que el dev solo los enlace por config (`visualModelId`/`iconId`) sin tocar el loot del boss ni el gameplay.

---

### **Descripción del Requerimiento / Contexto**

Los 3 uniques del boss final (R7) caen del `floor_5_boss` (`uniquePool`, R7) y **ya están implementados como dato** en `ItemConfig` — pero **no tienen modelo 3D ni icono**: hoy funcionan con fallback/placeholder. Esta HU produce sus assets:

| templateId | Nombre | Tipo de arma | wieldType (ITEMS-01) | Stats (seed) |
|------------|--------|--------------|----------------------|--------------|
| `unique_frost_edge` | Filo de la Escarcha | Espada 1H | `OneHand` (dual) | ATK 25, +10 ATK, +5 CRIT |
| `unique_frostbow` | Arco del Vendaval Helado | Arco 2H | `TwoHand` (ocupa MainHand+OffHand) | ATK 25, +10 ATK, +5 CRIT |
| `unique_glacial_wand` | Vara del Invierno | Varita 1H | `MainHandOnly` (puede llevar escudo) | MATK 25, +10 MATK, +5 CRIT |

**Criterio de hecho global:** los 3 uniques tienen modelo 3D (se ven en la mano del jugador con estética de hielo/escarcha, coherente con Vandrheim) e icono (estándar ASSETS_LIST), quedan registrados y el dev los enlaza por config sin tocar loot ni gameplay.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Modelos 3D (diseñador)**

| ID visual | Modelo | visualType / attachment (pipeline EST-01) |
|-----------|--------|--------------------|
| `unique_frost_edge` | Espada 1H de hielo: hoja de cristal translúcido azul, guarda de metal frío y empuñadura envuelta; aura de escarcha sutil (sin VFX pesado) | `HandModel` — `attachTo = RightHand` (patrón `paladin_sword_1h_mesh`) |
| `unique_frostbow` | Arco grande 2H de hielo: arco de cuerno helado con cuerda de luz fría y cristales en las puntas | `HandModel` — `attachTo = RightHand` (patrón `hunter_bow`) |
| `unique_glacial_wand` | Varita de cristal de hielo con gema azul profunda y filigrana plateada, silueta legible desde 3ª persona | `HandModel` — `attachTo = RightHand` (patrón `cleric_wand`) |

Reglas (heredadas de EST-01/EST-05 y ASSETS_POLICY):

* Estética: **hielo/escarcha** (azul hielo, cristal translúcido, metal frío), coherente con el boss "Guardián de la Escarcha" y la temática Helada.
* Distinguibles entre sí y de los ítems comunes (silueta y color únicos; el jugador debe reconocer un unique de un vistazo).
* `Anchored=false`, `CanCollide=false`, `Massless=true`; sin interferir con el Humanoid ni las animaciones.
* Nombres estables = `templateId`; ubicación en `ReplicatedStorage/Assets/Models/Equipment/Weapons/` (o carpeta `Unique/` si se prefiere, documentado).
* Sin scripts ni lógica dentro del modelo.

#### **2. Iconos 2D (diseñador — ASSETS_LIST)**

Se agregan a `ASSETS_LIST.md` (mismo estándar: 512×512, fondo negro #000000 = finales, objeto ~85% centrado, perspectiva 3/4, paleta Vandrheim):

| Icono | Ítem |
|-------|------|
| `Icon_Item_unique_frost_edge` | Espada de hielo con aura de escarcha |
| `Icon_Item_unique_frostbow` | Arco de hielo con cuerda de luz fría |
| `Icon_Item_unique_glacial_wand` | Varita de cristal de hielo con gema azul |

* Los iconos se entregan como imágenes; el dev los coloca en `Assets/Icons` (patrón actual de los uniques: `iconId = "Icon_Item_unique_*"` por nombre de asset) y registra en `ASSETS_REGISTRY`.

#### **3. Integración mínima (dev)**

* `ItemConfig`: agregar a cada unique `visualModelId` (id del modelo), `visualType = "HandModel"`, `attachTo = "RightHand"` y `offset` razonable (patrones de espada/arco/varita existentes).
* **No** se toca: stats, affixes, rareza, `unique=true`, `bindState`, `uniquePool` del `floor_5_boss`, ni el flujo de recompensa.
* Registrar modelos e iconos en `ASSETS_REGISTRY` (id, tipo, uso, fuente, licencia).
* Si un modelo aún no está listo, el ítem conserva el fallback/warning controlado (regla EST-01) y sigue dropeando con normalidad.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Modelos creados y organizados**

* **GIVEN** el diseñador entrega los modelos
* **WHEN** se inspecciona `ReplicatedStorage.Assets.Models.Equipment`
* **THEN** existen los 3 modelos con nombre = `templateId`, sin scripts y sin copias sueltas en `Workspace.GFX`

#### **Escenario 2: Uniques visibles en el avatar**

* **GIVEN** el jugador equipa un unique (ej. Filo de la Escarcha)
* **WHEN** se aplican los visuales (pipeline EST-01)
* **THEN** el arma se ve en la mano derecha y sigue las animaciones
* **AND** los 3 se distinguen entre sí y de los ítems comunes (estética de hielo)

#### **Escenario 3: Iconos listos**

* **GIVEN** los 3 uniques
* **WHEN** se revisa `ASSETS_LIST.md` y `Assets/Icons`
* **THEN** cada uno tiene su icono (512×512, fondo negro, paleta Vandrheim)
* **AND** los ids coinciden con los `iconId` del `ItemConfig`

#### **Escenario 4: Loot del boss intacto**

* **GIVEN** el boss del piso 5
* **WHEN** se mata y se abre el cofre
* **THEN** los uniques siguen cayendo por el `uniquePool` existente (sin cambios de drop ni de flujo de recompensa)

#### **Escenario 5: Registro y licencias**

* **GIVEN** todo asset incorporado
* **WHEN** se revisa `ASSETS_REGISTRY`
* **THEN** cada asset tiene id, tipo, uso, fuente, autor y licencia

#### **Escenario 6: Fallback seguro**

* **GIVEN** un modelo faltante o no adjuntable
* **WHEN** el jugador equipa el ítem
* **THEN** el dato no se corrompe y el inventario sigue funcionando con warning controlado (regla EST-01)

---

### **Comportamiento Visual / Reglas de Negocio**

* Los uniques se ven épicos y temáticos (hielo/escarcha), sin tapa al personaje ni a la UI.
* No cambian stats, rareza, drop, economía ni reglas de equipamiento.
* Los iconos mantienen el estándar aprobado (fondo negro, estilo pintado, paleta Vandrheim).

---

### **Alcance**

#### Incluye

* 3 modelos 3D (`unique_frost_edge`, `unique_frostbow`, `unique_glacial_wand`).
* 3 iconos (`Icon_Item_unique_*`) en ASSETS_LIST + Assets/Icons.
* Enlace por config: `visualModelId`/`visualType`/`attachTo`/`offset` en `ItemConfig` (dev).
* Registro en `ASSETS_REGISTRY`.

#### No incluye

* Cambios al loot del boss, `uniquePool`, stats, affixes, rareza o bind de los uniques.
* VFX/SFX nuevos (las armas pueden usar los VFX existentes de la clase; sin partículas propias en esta HU).
* Cambios a las reglas de armas (wieldType ya definido en ITEMS-01).
* Otros ítems, sets o modelos de otras clases.

---

### **Definition of Done (DoD)**

* [ ] Los 3 modelos existen en `Assets/Models/Equipment` con nombre = templateId y estructura válida (sin scripts).
* [ ] Cada unique se ve en la mano derecha y sigue las animaciones (pipeline EST-01).
* [ ] Los 3 iconos existen con el estándar aprobado y sus ids coinciden con el `ItemConfig`.
* [ ] `ItemConfig` enlaza `visualModelId`/`visualType`/`attachTo`/`offset` (sin tocar stats ni loot).
* [ ] `ASSETS_LIST.md` y `ASSETS_REGISTRY` actualizados (fuente/licencia).
* [ ] El boss del piso 5 sigue dropeando los uniques por el flujo R7 (sin regresión).
* [ ] Fallback/warning controlado si falta un modelo (no rompe inventario).
* [ ] Sin errores rojos en equip → combate → respawn → rejoin.
* [ ] Nota de esta HU en el GDD después de la verificación, no antes.

---

### **Estimación (orientativa)**

Diseñador: 1–2 sesiones (3 modelos + 3 iconos). Dev: tarea mínima de enlace por config.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-18 | Creación de HU-ESTETICA-18: modelos e iconos de los 3 uniques del boss final (Filo de la Escarcha, Arco del Vendaval Helado, Vara del Invierno); diseñador produce assets, dev enlaza por config — sin tocar loot ni gameplay |