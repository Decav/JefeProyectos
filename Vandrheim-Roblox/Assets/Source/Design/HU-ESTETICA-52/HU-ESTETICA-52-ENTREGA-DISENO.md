# HU-ESTETICA-52: Entrega Formal y Dictamen de Diseno — Modelos para Valgard Vivo y Caminos

**Historia de Usuario:** HU-ESTETICA-52 (Revision de modelos nuevos para Valgard vivo y caminos)  
**Consumidor Tecnico:** HU-R6.53 (Implementacion de microescenas, NPCs ambientales y POIs en Valgard)  
**Ubicacion del Paquete de Staging:** `Workspace.TestPlace` (Roblox Studio)  
**Fecha de Revision:** 2026-11-06  
**Dictamen General:** APROBADO CON OBSERVACIONES (Alcance P0 completo en Studio; Niños y Perro descartados formalmente por PO; Tabernero corregido con indumentaria civil estricta; Fauna pasiva diferida a P1)

---

## 1. Resumen Ejecutivo del Paquete de Revision

El presente documento formaliza la compuerta de aprobacion visual y tecnica de los assets destinados a poblar el pueblo de Valgard y sus caminos perifericos en el Hub principal de Vandrheim.

De acuerdo con las directivas del Product Owner (PO) y los estandares arquitectonicos del proyecto:
1. **NPCs Ambientales 100% Body Skin:** Se elimina de manera estricta cualquier accesorio 3D secundario (cascos, hombreras, capas) en los NPCs de ambientacion civil, garantizando modelos ligeros basados exclusivamente en indumentaria R15 canonica de alta definicion (estandar EST-33).
2. **Correccion de Indumentaria Civil del Tabernero:** Se corrigio la asignacion del tabernero, eliminando cualquier asset de armadura de combate o placas heladas. Ahora viste un atuendo puramente civil y rustico: camisa de lino crudo con mangas arremangadas, chaleco de cuero marron con botones de hueso, pano de servicio doblado en el cinto, pantalon de lana gruesa con rodilleras reforzadas, botas de trabajo y manojo de llaves de bodega para los barriles de hidromiel.
3. **Descarte de Ninos y Perro:** Por definicion explicita de diseno del PO para optimizar el alcance del MVP y evitar rigs no estandar, se descartan los modelos de ninos y perro.
4. **Presupuesto y Rendimiento Movil:** Todos los modelos (NPCs, props y POIs) cumplen estrictamente los limites de triangulos, texturas (<=512x512) y colisiones simples sin generar carga excesiva en dispositivos de gama media o baja.
5. **Fauna Pasiva Diferida:** La fauna pasiva (conejo, ave, ciervo) queda registrada formalmente como P1 diferida, protegiendo el presupuesto de `StreamingEnabled` del Hub.

---

## 2. Inventario Tecnico y Dictamen de NPCs (Prioridad P0)

Todos los NPCs estan montados en `Workspace.TestPlace.NPCs_Valgard_Review`, alineados a lo largo de `Z = 0.0`, con `Anchored = true`, `PrimaryPart = HumanoidRootPart` y `Accessories = []` (0 accesorios 3D).

| Nombre Canonico | Rol / Microescena | Shirt Asset ID | Pants Asset ID | Partes R15 | Accesorios 3D | Estado / Dictamen | Notas de Integracion |
| :--- | :--- | :--- | :--- | :---: | :---: | :--- | :--- |
| `NPC_Ambient_Guard_Door` | Guardia de Valgard (Variante 1: Puerta) | `rbxassetid://88415197605482` | `rbxassetid://81266561479192` | 16 | 0 | **Aprobado** | Armadura de placas de acero y oro sobre gambeson. Sin yelmo ni hombreras. Postura erguida en porton principal. |
| `NPC_Ambient_Guard_Patrol` | Guardia de Valgard (Variante 2: Patrullero) | `rbxassetid://127500184998879` | `rbxassetid://90697441775271` | 16 | 0 | **Aprobado** | Cota de malla y cuero ligero de explorador. Diseñado para rutas de patrulla en los caminos. |
| `NPC_Ambient_Blacksmith_Assistant` | Ayudante de herreria | `rbxassetid://87819650254549` | `rbxassetid://131135835792445` | 16 | 0 | **Aprobado** | Mandil de cuero engrasado con manchas de forja, cinturon de herramientas, brazales termicos y botas reforzadas. |
| `NPC_Ambient_Alchemist_Assistant` | Ayudante de alquimia / Boticario | `rbxassetid://139789230714217` | `rbxassetid://126655618507683` | 16 | 0 | **Aprobado** | Tunica nordica azul con frascos, hierbas medicinales y zurron de reactivos. |
| `NPC_Ambient_Merchant` | Vendedor de mercado | `rbxassetid://129609031177806` | `rbxassetid://124517385758133` | 16 | 0 | **Aprobado** | Ropa de comerciante viajero con jubon marron, hebillas y zurron de monedas. |
| `NPC_Ambient_Tavernkeeper` | Tabernero / Posadero | `rbxassetid://78430914134815` | `rbxassetid://135113559315871` | 16 | 0 | **Aprobado** | Atuendo civil rustico de posadero: camisa de lino crudo con mangas arremangadas, chaleco de cuero oscuro, botones de hueso, pano de taberna, pantalon de lana con rodilleras cosidas, llaves de bodega y botas de trabajo. Cero armadura. |
| `NPC_Ambient_Child_Boy` | Nino en plaza | N/A | N/A | 0 | 0 | **Descartado por diseno** | Descartado formalmente por el PO. No implementar en HU-R6.53. |
| `NPC_Ambient_Child_Girl` | Nina en plaza | N/A | N/A | 0 | 0 | **Descartado por diseno** | Descartado formalmente por el PO. No implementar en HU-R6.53. |
| `NPC_Ambient_Dog` | Perro companero | N/A | N/A | 0 | 0 | **Descartado por diseno** | Descartado formalmente por el PO. No implementar en HU-R6.53. |

---

## 3. Inventario Tecnico y Dictamen de Props (Prioridad P0)

Montados en `Workspace.TestPlace.Props_Valgard_Review`, alineados ordenadamente a lo largo de `Z = 20.0` para inspeccion individual.

| Nombre Canonico | Tipo / Clase | Partes | Dimensiones (X, Y, Z) | Material Predominante | PrimaryPart | Anchored | Dictamen | Origen / Notas |
| :--- | :--- | :---: | :--- | :--- | :--- | :---: | :--- | :--- |
| `Prop_Valgard_Campfire` | Model | 13 | 5.2 x 1.4 x 5.2 | Wood / Neon / Slate | `Embers` | Si | **Aprobado** | Fogata nordica con leños cruzados, brasas y luz calida de punto. |
| `Prop_Valgard_FirewoodStack` | Model | 11 | 3.8 x 3.5 x 0.5 | Wood | `Stake_-1` | Si | **Aprobado** | Pila de leña cortada entre estacas laterales. |
| `Prop_Valgard_Bench` | Model | 4 | 4.2 x 1.6 x 1.4 | WoodPlanks | `SeatPlank` | Si | **Aprobado** | Banco rustico de plaza y exteriores. |
| `Prop_Valgard_LanternPost` | Model | 6 | 2.8 x 7.6 x 1.4 | Wood / Metal / Glass | `MainPost` | Si | **Aprobado** | Poste de farol con brazo de hierro forjado y cristal. |
| `Prop_Valgard_Signpost` | Model | 3 | 4.4 x 6.0 x 1.9 | Wood | `Pole` | Si | **Aprobado** | Cartel indicador de rutas (Valgard / Helada). |
| `Prop_Valgard_Cart` | Model | 9 | 7.0 x 4.4 x 8.7 | Wood / Metal | `CartBed` | Si | **Aprobado** | Carro de carga de dos ruedas con eje de madera. |
| `Prop_Valgard_MeadBarrel` | Model | 1 | 3.4 x 2.6 x 2.6 | WoodPlanks | `Barrel` | Si | **Aprobado** | Barril de hidromiel reutilizado de `MeadTavern`. |
| `Prop_Valgard_Anvil` | Model | 2 | 3.2 x 3.8 x 2.4 | Wood / Metal | `Stump` | Si | **Aprobado** | Yunque de hierro forjado sobre tocon de roble (`BlacksmithForge`). |
| `Prop_Valgard_Crate_1` | Part | 1 | 2.0 x 2.0 x 2.0 | WoodPlanks | `Prop_Valgard_Crate_1` | Si | **Aprobado** | Caja de provisiones de madera reforzada. |
| `Prop_Valgard_Crate_2` | Part | 1 | 2.0 x 2.0 x 2.0 | WoodPlanks | `Prop_Valgard_Crate_2` | Si | **Aprobado** | Caja de provisiones estandar. |
| `Prop_Valgard_Well` | Part | 1 | 4.0 x 3.0 x 4.0 | Slate | `Prop_Valgard_Well` | Si | **Aprobado** | Brocal de pozo de piedra tallada. |
| `Prop_Valgard_DryingRack` | Model | 4 | 6.0 x 6.0 x 0.6 | Wood / Fabric | `Crossbeam` | Si | **Aprobado** | Bastidor de secado con piel curtida tensada. |
| `Prop_Valgard_SnowMound` | Model | 2 | 2.2 x 5.0 x 5.0 | Snow | `SnowBase` | Si | **Aprobado** | Monticulo de nieve decorativo (`CanCollide = false`). |
| `Prop_Valgard_Banner` | Model | 4 | 3.0 x 9.0 x 0.6 | Wood / Fabric / Metal | `BannerPole` | Si | **Aprobado** | Mastil de madera con pendon azul y ribete dorado de Valgard. |

---

## 4. Inventario Tecnico y Dictamen de Puntos de Interes (POIs - Prioridad P0)

Montados en `Workspace.TestPlace` a lo largo de la franja `Z = 70.0`, estructurados como microescenas compuestas de baja poligonalidad.

| Nombre Canonico | Ubicacion Staging (X, Z) | Elementos Integrados | Partes Totales | Presupuesto Triangulos | Dictamen | Descripcion / Composicion |
| :--- | :---: | :--- | :---: | :---: | :--- | :--- |
| `POI_Valgard_Campamento` | (-35.0, 70.0) | 2 Tiendas de campana, Fogata, Carro de suministros, Pila de leña | 49 | <1.5k | **Aprobado** | Asentamiento transitorio de viajeros al borde del camino norte. |
| `POI_Valgard_CarroVolcado` | (-15.0, 70.0) | Carro volcado inclinado, 3 cajas esparcidas, monticulo de nieve | 14 | <800 | **Aprobado** | Escena ambiental de incidente en el camino, con suministros caidos en la nieve. |
| `POI_Valgard_RunaAntigua` | (5.0, 70.0) | Dais de piedra, Monolito central, Runa neon con luz cian, 4 estelas de perimetro | 7 | <400 | **Aprobado** | Antiguo monolito magico nordico reutilizando el lenguaje runico del juego. |
| `POI_Valgard_EntradaCueva` | (25.0, 70.0) | Rocas laterales de pizarra, dintel superior, fondo oscuro, capa de nieve, farol | 11 | <600 | **Aprobado** | Abrigo rocoso que sugiere la entrada a una cavidad en la montaña. |
| `POI_Valgard_Mirador` | (45.0, 70.0) | Plataforma de tablones, barandilla de troncos (4 postes), banco, farol, poste indicador | 19 | <700 | **Aprobado** | Mirador panoramico con vistas al lago helado y descanso para caminantes. |
| `POI_Valgard_SantuarioMenor` | (65.0, 70.0) | Altar de adoquines, cuenco de ofrendas, brasas sagradas con luz azul, 2 estelas | 5 | <300 | **Aprobado** | Altar sagrado menor dedicado a los ancestros, con cuenco de sacrificios y brasas. |

---

## 5. Resolucion Formal sobre Fauna Pasiva (Prioridad P1)

* **Estado:** DIFERIDA A P1.
* **Justificacion Tecnica:**
  1. El MVP de Vandrheim prioriza la estabilidad de fotogramas (60 FPS) y la memoria en dispositivos moviles de gama baja y media.
  2. La adicion de entidades con movimiento o esqueletos independientes (conejo, ave, ciervo) sin combate anadiria calculos innecesarios al motor de animacion del cliente sin aportar valor de progresion inmediata.
  3. La ambientacion visual de los caminos queda plenamente satisfecha con los 6 POIs y los NPCs ambientales aprobados.

---

## 6. Registro de Assets, Texturas y Previews

### Iconos Maestros Generados (512x512 RGBA):
* `Assets/Icons/Items/Armor/Guard/Icon_Item_guard_valgard_chest.png`
* `Assets/Icons/Items/Armor/Guard/Icon_Item_guard_valgard_legs.png`
* `Assets/Icons/Items/Armor/Blacksmith/Icon_Item_blacksmith_valgard_chest.png`
* `Assets/Icons/Items/Armor/Blacksmith/Icon_Item_blacksmith_valgard_legs.png`
* `Assets/Icons/Items/Armor/Tavernkeeper/Icon_Item_tavernkeeper_valgard_chest.png`
* `Assets/Icons/Items/Armor/Tavernkeeper/Icon_Item_tavernkeeper_valgard_legs.png`

### Body Skins R15 Subidos a Roblox:
* Guardia de Valgard (Puerta): Shirt `rbxassetid://88415197605482`, Pants `rbxassetid://81266561479192`
* Guardia de Valgard (Patrulla): Shirt `rbxassetid://127500184998879`, Pants `rbxassetid://90697441775271`
* Ayudante de Herreria: Shirt `rbxassetid://87819650254549`, Pants `rbxassetid://131135835792445`
* Ayudante de Alquimia: Shirt `rbxassetid://139789230714217`, Pants `rbxassetid://126655618507683`
* Vendedor de Mercado: Shirt `rbxassetid://129609031177806`, Pants `rbxassetid://124517385758133`
* Tabernero (Corregido Civil): Shirt `rbxassetid://78430914134815`, Pants `rbxassetid://135113559315871`

### Previews de Inspeccion en Studio:
* Panorama de la linea completa de NPCs: `Assets/Source/Design/HU-ESTETICA-52/Previews/studio_npcs_valgard_lineup.jpg`
* Panorama de los 14 props: `Assets/Source/Design/HU-ESTETICA-52/Previews/studio_valgard_props_panoramic.jpg`
* Panorama de los 6 POIs: `Assets/Source/Design/HU-ESTETICA-52/Previews/studio_pois_valgard_panoramic.jpg`
* Detalle de Campamento y Carro Volcado: `Assets/Source/Design/HU-ESTETICA-52/Previews/studio_pois_campamento_carro.jpg`
* Detalle de Runa, Cueva, Mirador y Santuario: `Assets/Source/Design/HU-ESTETICA-52/Previews/studio_pois_shrines_mirador_cueva.jpg`
* Primer plano de Patrullero, Herrero y Alquimista: `Assets/Source/Design/HU-ESTETICA-52/Previews/studio_npcs_patrol_blacksmith_alchemist.jpg`
* Primer plano de Mercader y Tabernero: `Assets/Source/Design/HU-ESTETICA-52/Previews/studio_npcs_merchant_tavernkeeper.jpg`

---

## 7. Instrucciones de Handoff Tecnico para HU-R6.53

Para integrar los assets aprobados en la escena viva del Hub (`Workspace.Hub`):

1. **NPCs Ambientales:**
   * Mover o clonar los modelos desde `Workspace.TestPlace.NPCs_Valgard_Review` hacia las carpetas correspondientes de `Workspace.Hub.NPCs` o la jerarquia asignada por `HU-R6.53`.
   * Mantener los modelos sin `CanCollide` en partes accesorias o extremidades, y configurar colision unicamente en `HumanoidRootPart` si se requiere bloqueo fisico, o `CanCollide = false` total para evitar obstruccion en rutas estrechas.
   * Asignar animaciones idle estandares ya existentes en el proyecto (`idle_ambient` o `idle_default`). No crear animaciones nuevas.

2. **Props:**
   * Utilizar directamente los modelos de `Workspace.TestPlace.Props_Valgard_Review`.
   * Todos los props tienen su `PrimaryPart` configurado y estan anclados (`Anchored = true`).
   * Mantener `Prop_Valgard_SnowMound` con `CanCollide = false` para que los jugadores puedan caminar a traves de la nieve sin tropiezos fisicos.

3. **POIs:**
   * Los 6 POIs en `Workspace.TestPlace` estan organizados como carpetas independientes con partes 100% ancladas.
   * Pueden ser posicionados directamente en las coordenadas designadas de los senderos y exteriores del pueblo sin modificar su estructura interna.
   * Ningun POI utiliza scripts de ejecucion, cumpliendo la regla de cero codigo en tareas de arte/diseno.
