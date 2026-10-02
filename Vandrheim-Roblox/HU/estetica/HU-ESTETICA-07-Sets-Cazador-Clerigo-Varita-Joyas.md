## HU-ESTETICA-07: Modelos e iconos de los sets Cazador/Clérigo, varita y joyería

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** Estética MVP / Equipamiento visual  
**Prioridad:** Alta  
**Estado:** Lista para implementar  
**Tipo:** Producción de assets (diseñador) — el dev solo enlaza los recursos por config  
**Fase GDD:** Épica transversal `EST` (previa/paralela a R8; el dev la consume en `HU-ITEMS-01`)  
**Depende de:** HU-ESTETICA-01 (pipeline visual R15 y estructura de Assets), HU-ESTETICA-05 (arco del Cazador), ASSETS_POLICY.md (fuentes, licencias, registro), `ASSETS_LIST.md` (iconos)  
**No modifica:** stats, daño, loot, economía ni reglas de equipamiento

---

### **Narrativa (INVEST)**

**Como** jugador,  
**quiero** que el equipo de Cazador y Clérigo se vea distinto al del Paladín, y que la varita, el collar y el anillo sean visibles en mi personaje,  
**para** que cada clase tenga identidad visual y el progreso de equipo se note.

**Como** equipo de desarrollo,  
**quiero** los modelos e iconos de estos ítems listos y registrados,  
**para** que el dev solo los enlace por `visualModelId`/`iconId` en config y no tenga que crear assets.

---

### **Descripción del Requerimiento / Contexto**

`HU-ITEMS-01` amplía el catálogo con el set del Cazador (cuero), el set del Clérigo (tela), una varita, un collar y un anillo. Esta HU produce los **assets** de esos ítems siguiendo el pipeline de `HU-ESTETICA-01` y la `ASSETS_POLICY`:

* **Modelos 3D** en `ReplicatedStorage/Assets/Models/Equipment/` (misma estructura que `Paladin/`) — **solo los que llevan visual en el avatar**: 10 piezas de sets + varita. **Collar y anillo no llevan modelo 3D** (decisión de producto 2026-09-15: son demasiado pequeños para mostrarse; equipan como dato + icono).
* **Iconos 2D** (512×512, fondo negro según el estándar aprobado) para los 13 ítems nuevos y las skills del Clérigo pendientes de `ASSETS_LIST`.
* **Registro obligatorio** en `ASSETS_REGISTRY` (fuente, autor, licencia).

El dev luego enlaza cada asset por id en `ItemConfig` (HU-ITEMS-01) sin tocar código de gameplay. Mientras un modelo no exista, el ítem funciona con fallback (regla EST-01).

**Criterio de hecho global:** existen los modelos R15 de los **11 ítems con visual** (10 piezas de sets + varita) y los **13 iconos** de los ítems nuevos, y quedan registrados para que `HU-ITEMS-01` los referencie. Collar y anillo quedan como dato + icono, sin modelo.

---

### **Especificaciones Técnicas / Contratos de API**

#### **Modelos 3D a crear**

| ID visual | Modelo | visualType / attachment sugerido (pipeline EST-01) |
|-----------|--------|--------------------|
| `hunter_helmet` | Capucha/casco de cuero con refuerzos, visera corta | `ModelAccessory` — `HatAttachment` (patrón `paladin_helmet`) |
| `hunter_chest` | Coraza de cuero con correas, hombrera ligera y bolsillos | `BodySkin` — `UpperTorso`, `LowerTorso` (patrón `chest_leather`) |
| `hunter_shoulders` | Hombreras de cuero remachado con piel/forro | `ModelAccessory` — `BodyFrontAttachment` + `shoulderSpread`/`shoulderOpenAngle` (patrón `paladin_shoulders`) |
| `hunter_legs` | Grebas/cuero con rodilleras reforzadas | `BodySkin` — piernas/pies R15 (patrón `paladin_legs`) |
| `hunter_gloves` | Guantes de cuero articulados con nudillos de metal | `BodySkin` — brazos/manos R15 (patrón `paladin_gloves`) |
| `cleric_helmet` | Cofia/tiara de tela con diadema dorada | `ModelAccessory` — `HatAttachment` |
| `cleric_chest` | Robe/túnica de tela clara con bordados dorados y cinturón | `BodySkin` — `UpperTorso`, `LowerTorso` |
| `cleric_shoulders` | Capa corta/hombreras de tela con remate dorado | `ModelAccessory` — `BodyFrontAttachment` |
| `cleric_legs` | Faldón/calzas de tela con cintas doradas | `BodySkin` — piernas/pies R15 |
| `cleric_gloves` | Guantes de tela con puños dorados | `BodySkin` — brazos/manos R15 |
| `cleric_wand` | Varita de madera clara con gema azul brillante y filigrana dorada | `HandModel` — `attachTo = RightHand` (patrón espadas) |

Nota: **collar (`item_collar`) y anillo (`item_ring`) no llevan modelo 3D** (decisión de producto): solo icono + dato en `ItemConfig`; no se adjuntan al avatar.

Reglas visuales (heredadas de EST-01 y ASSETS_POLICY):

* **Cazador**: cuero oscuro/marrón, refuerzos de hierro frío, paleta bosque-nórdico (verde/gris).
* **Clérigo**: tela crema/marfil, dorado cálido, acentos azul hielo (coherente con Vandrheim).
* **Varita**: silueta legible desde 3ª persona; gema azul con luz tenue (PointLight opcional, sin VFX pesado).
* **Collar y anillo**: discretos pero visibles; no deforman ni chocan con el R15; siguen las animaciones.
* Piezas `Anchored=false`, `CanCollide=false`, `Massless=true` cuando corresponda; sin interferir con el Humanoid.
* Nombres estables, clonables, dentro de la carpeta de Assets (no dejar única copia en `Workspace.GFX`).
* Collar y anillo: **sin modelo** — no se crean ni se registran modelos para ellos (solo iconos).

#### **Estructura de assets**

```text
ReplicatedStorage/
  Assets/
    Models/
      Equipment/
        Hunter/    -- hunter_helmet, hunter_chest, hunter_shoulders, hunter_legs, hunter_gloves
        Cleric/    -- cleric_helmet, cleric_chest, cleric_shoulders, cleric_legs, cleric_gloves
        Weapons/   -- cleric_wand
```

#### **Iconos 2D (ASSETS_LIST)**

Se agregan a `ASSETS_LIST.md` (mismo estándar: 512×512, fondo negro #000000, objeto ~85% centrado, perspectiva 3/4, paleta Vandrheim):

| Icono | Ítem |
|-------|------|
| `Icon_Item_hunter_helmet` | Capucha/casco de cuero |
| `Icon_Item_hunter_chest` | Coraza de cuero con correas |
| `Icon_Item_hunter_shoulders` | Hombreras de cuero remachado |
| `Icon_Item_hunter_legs` | Grebas de cuero con rodilleras |
| `Icon_Item_hunter_gloves` | Guantes de cuero articulados |
| `Icon_Item_cleric_helmet` | Cofia/tiara de tela con diadema |
| `Icon_Item_cleric_chest` | Túnica de tela con bordados dorados |
| `Icon_Item_cleric_shoulders` | Capa corta de tela con remate dorado |
| `Icon_Item_cleric_legs` | Faldón/calzas de tela |
| `Icon_Item_cleric_gloves` | Guantes de tela con puños dorados |
| `Icon_Item_cleric_wand` | Varita con gema azul |
| `Icon_Item_collar` | Collar de metal dorado con gema |
| `Icon_Item_ring` | Anillo de oro con gema |

Los iconos se entregan como imágenes y se **suben a Roblox (Asset Server)**: el dev coloca el `rbxassetid` resultante en `iconId` de `ItemConfig` (patrón actual de los ítems comunes; los uniques usan nombre de asset en `Assets/Icons`).

Además, quedan pendientes los **iconos de las skills del Clérigo** (10) para `R8c`; se agregan a `ASSETS_LIST` en esta HU si el diseñador puede completarlos (recomendado), o se registran como pendiente explícito.

#### **Registro de assets**

Cada asset incorporado se anota en `ASSETS_REGISTRY`:

* Nombre/ID del modelo o icono.
* Tipo de asset (modelo/icono).
* Uso y slot/ítem.
* Fuente: producción propia o fuente autorizada.
* Autor/licencia cuando aplique.
* Fecha de incorporación.

#### **Entrega al dev**

* Los ids quedan definidos para que `HU-ITEMS-01` los use como `visualModelId`/`iconId`.
* No se modifica `ItemConfig`, `InventoryService` ni ningún script: los assets son referenciables por config.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Modelos creados y organizados**

* **GIVEN** el diseñador entrega los modelos.
* **WHEN** se inspecciona `ReplicatedStorage.Assets.Models.Equipment`.
* **THEN** existen `Hunter/`, `Cleric/` y `Weapons/cleric_wand` con ids estables.
* **AND** no dependen de copias sueltas en `Workspace.GFX`.

#### **Escenario 2: Set Cazador en R15**

* **GIVEN** el jugador equipa las 5 piezas del Cazador.
* **WHEN** se aplican los visuales (pipeline EST-01).
* **THEN** cada pieza encaja en su zona R15.
* **AND** el set se ve como cuero de cazador nórdico, distinto del Paladín.

#### **Escenario 3: Set Clérigo en R15**

* **GIVEN** el jugador equipa las 5 piezas del Clérigo.
* **WHEN** se aplican los visuales.
* **THEN** cada pieza encaja en su zona R15.
* **AND** el set se ve como tela/clérigo, distinto de los otros sets.

#### **Escenario 4: Varita**

* **GIVEN** el jugador equipa la varita.
* **WHEN** aparece o actualiza su personaje.
* **THEN** la varita aparece en la mano derecha.
* **AND** sigue la mano durante movimiento y animaciones existentes.

#### **Escenario 5: Collar y anillo sin modelo visual**

* **GIVEN** el jugador equipa collar y anillo.
* **WHEN** se aplica el equipamiento.
* **THEN** no se adjunta ningún modelo 3D al avatar (decisión de producto: solo dato + icono).
* **AND** stats e icono funcionan con normalidad en inventario y equipo.

#### **Escenario 6: Iconos listos**

* **GIVEN** los ítems nuevos.
* **WHEN** se revisa `ASSETS_LIST.md` y la carpeta de iconos.
* **THEN** cada ítem tiene su icono (512×512, fondo negro, paleta Vandrheim).
* **AND** los ids coinciden con los `iconId` definidos en `HU-ITEMS-01`.

#### **Escenario 7: Registro y licencias**

* **GIVEN** todo asset incorporado.
* **WHEN** se revisa `ASSETS_REGISTRY`.
* **THEN** cada asset tiene id, tipo, uso, fuente, autor y licencia.
* **AND** no hay assets sin licencia clara.

#### **Escenario 8: Compatibilidad**

* **GIVEN** los modelos aplicados.
* **WHEN** el jugador camina, corre, salta, combate y entra a dungeon.
* **THEN** las piezas no generan colisiones, empujes ni caídas.
* **AND** cámara, targeting, skills, respawn y teleport continúan funcionando.

#### **Escenario 9: Fallback seguro**

* **GIVEN** un modelo faltante o no adjuntable.
* **WHEN** el jugador equipa el ítem.
* **THEN** el dato de equipamiento no se corrompe.
* **AND** el inventario sigue funcionando con warning controlado (regla EST-01).

---

### **Comportamiento Visual e Interfaz (UI/UX) / Reglas de Negocio**

* Cada set tiene identidad propia: cuero del Cazador, tela del Clérigo, placas del Paladín.
* La varita es visible pero discreta; no tapa al personaje ni la UI. Collar y anillo no se muestran en el avatar (decisión de producto).
* Los iconos mantienen el estándar aprobado (fondo negro, estilo pintado, paleta Vandrheim).
* El dev no crea assets en esta HU: solo enlaza ids por config.
* No se altera stats, rareza, loot, economía ni reglas de equipamiento.

---

### **Alcance**

#### Incluye

* 10 modelos de armadura (5 Cazador + 5 Clérigo).
* Modelo de varita (`cleric_wand`).
* Organización en `Assets/Models/Equipment/{Hunter,Cleric,Weapons}`.
* Iconos 2D de los 13 ítems nuevos (incl. collar/anillo, que no llevan modelo) + (recomendado) los 10 de skills del Clérigo.
* Actualización de `ASSETS_LIST.md` y registro en `ASSETS_REGISTRY`.
* Prueba de compatibilidad R15 y con las animaciones actuales.

#### No incluye

* Sets adicionales, transmog o modelos de otras clases.
* Modelo final del boss, enemigos o estructuras del dungeon (EST-02/03).
* Creación o rigging de animaciones.
* VFX/SFX nuevos (partículas ya confirmadas van por HU de clase en R8a/b/c).
* Cambios a `ItemConfig`, stats, daño, loot, economía o gameplay.
* IK de dos manos o poses exclusivas.

---

### **Definition of Done (DoD)**

* [ ] Los 11 modelos existen y están organizados en `Assets/Models/Equipment`.
* [ ] Los sets Cazador y Clérigo encajan en el R15 y se distinguen del Paladín.
* [ ] La varita se une a la mano derecha.
* [ ] Collar y anillo no requieren modelo 3D (decisión de producto): solo icono + dato.
* [ ] Las piezas no tienen colisión ni afectan física, stats o daño.
* [ ] Las animaciones actuales no separan las piezas.
* [ ] Los iconos de los 13 ítems (y los 10 de skills del Clérigo si aplica) están listos con el estándar aprobado.
* [ ] `ASSETS_LIST.md` y `ASSETS_REGISTRY` actualizados con fuente/licencia.
* [ ] Fallback/warning controlado si falta un modelo (no rompe inventario).
* [ ] Sin errores rojos en equip → movimiento → combate → respawn.
* [ ] El dev puede enlazar `visualModelId`/`iconId` desde `HU-ITEMS-01`.

---

### **Estimación (orientativa)**

2–4 sesiones del diseñador: 11 modelos + ajuste R15 + 13–23 iconos + registro y pruebas de compatibilidad.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-12 | Creación de HU-ESTETICA-07: modelos e iconos de sets Cazador/Clérigo, varita, collar y anillo; el dev los enlaza por config en HU-ITEMS-01 |
| 2026-09-15 | Revisión PM: **collar y anillo fuera del alcance de modelos 3D** (decisión de producto: solo icono + dato); alcance pasa a 11 modelos (10 piezas + varita) + 13 iconos; se elimina la carpeta `Jewellery/` |