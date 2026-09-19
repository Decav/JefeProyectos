# Entrega visual — HU-ESTETICA-07

## Alcance

Activos visuales para los sets Cazador y Clérigo, sin integración de gameplay ni cambios en `ItemConfig` o scripts. Los modelos están en el DataModel de Roblox Studio bajo `ReplicatedStorage.Assets.Models.Equipment`; el dev debe conectar los `visualModelId`, slots y reglas de supresión en la parte de integración.

Se conserva el enfoque de equipamiento del proyecto: casco, hombreras y armas son modelos superpuestos; pecho, guantes y piernas son `BodySkin` sobre segmentos R15, no prendas 3D independientes.

## Modelos en Roblox Studio

| Ruta | Tipo | Segmentos R15 |
| --- | --- | --- |
| `Hunter.hunter_chest` | `BodySkin` | `UpperTorso`, `LowerTorso` |
| `Hunter.hunter_gloves` | `BodySkin` | `LeftUpperArm`, `RightUpperArm`, `LeftLowerArm`, `RightLowerArm`, `LeftHand`, `RightHand` |
| `Hunter.hunter_legs` | `BodySkin` | `LeftUpperLeg`, `RightUpperLeg`, `LeftLowerLeg`, `RightLowerLeg`, `LeftFoot`, `RightFoot` |
| `Cleric.cleric_chest` | `BodySkin` | `UpperTorso`, `LowerTorso` |
| `Cleric.cleric_gloves` | `BodySkin` | `LeftUpperArm`, `RightUpperArm`, `LeftLowerArm`, `RightLowerArm`, `LeftHand`, `RightHand` |
| `Cleric.cleric_legs` | `BodySkin` | `LeftUpperLeg`, `RightUpperLeg`, `LeftLowerLeg`, `RightLowerLeg`, `LeftFoot`, `RightFoot` |
| `Hunter.hunter_helmet` | `ModelAccessory` | Superpuesto; `HatAttachment` |
| `Hunter.hunter_shoulders` | `ModelAccessory` | Superpuesto; `BodyFrontAttachment` |
| `Cleric.cleric_helmet` | `ModelAccessory` | Superpuesto; `HatAttachment` |
| `Cleric.cleric_shoulders` | `ModelAccessory` | Superpuesto; `BodyFrontAttachment` |
| `Weapons.cleric_wand` | `HandModel` | Superpuesto; mano derecha |

Revisión de `Hunter.hunter_shoulders`: se ocultó reversiblemente `fur mantle_geom` para mantener la silueta de hombreras separadas. Las dos mallas visibles conservan las dimensiones del modelo Paladín y usan los nombres `left pauldron_visual_geom` y `right pauldron_visual_geom`. Como `EquipmentVisualService` reubica las piezas llamadas `left pauldron_geom` y `right pauldron_geom`, el modelo mantiene esas dos piezas como guías invisibles; así el servicio conserva su layout sin sobrescribir la pose de las mallas visibles. Estas quedan intercambiadas de lado respecto de las guías y sin giro local en Y: el giro Y de 180° ya aplicado por el offset de `ItemConfig` hace que las caras internas queden orientadas hacia el torso. No añadir otro giro local de 180°, porque cancelaría el offset. `ItemConfig` no se modificó: conserva `offset = CFrame.new(0, 0.5, 0.6) * CFrame.Angles(0, math.rad(180), 0)`, `shoulderSpread = 1.55` y `shoulderOpenAngle = -25`.

Revisión de `Hunter.hunter_helmet`: el visual se reemplazó por un casco rígido de cuero nórdico/vikingo, de cúpula baja y ancha, banda frontal remachada, nasal y placas laterales de protección. La malla base usa `MeshId rbxassetid://120437761988459` y textura `rbxassetid://101432561656394` (asset publicado: `107149545374469`); la banda frontal, el nasal, las mejillas y los remaches son geometría local soldada al `Handle`. El anterior `body_geom` tipo capucha se renombró `body_geom_previous_open_hood` y quedó oculto; también se conservaron ocultas (`ChinStraps`, `BrowVisor`, `HoodShell`) las piezas antiguas para reversión. `Handle`, `HatAttachment`, `visualModelId`, `visualType`, `visualScale = 1.0` y `offset = CFrame.new(0, -0.35, 0) * CFrame.Angles(0, math.rad(180), 0)` de `ItemConfig` permanecen intactos.

Revisión de `Cleric.cleric_shoulders`: el original estaba compuesto por `LeftMantlePanel`, `RightMantlePanel` y `GoldEdgeTrim` centrados como una pieza de pecho. Se ocultaron reversiblemente y se añadieron las dos mallas de pauldron de `Paladin.paladin_shoulders_model`, con tinte oro pálido y offsets locales ±1,6 studs. El modelo sugiere `shoulderSpread = 1.55` y `shoulderOpenAngle = -25`, igual que el layout del Paladín; si la integración activa el layout automático, mantener esos valores.

Los seis `BodySkin` usan geometría R15 del modelo canónico `Paladin.paladin_r15_body_skin_new`, `BodyPart` y `SkinOffset=CFrame.new()`. Cada modelo incluye un `Humanoid` y la instancia de ropa clásica correspondiente. La prueba estructural en Studio confirmó todos los segmentos esperados y física sin colisión.

## Texturas clásicas R15

Archivos locales en `Assets/Clothing/EST-07/` (585×559 px, PNG con alfa):

| Archivo | Uso | Asset ID |
| --- | --- | --- |
| `hunter_classic_shirt_r15.png` | Camisa Cazador; pecho y mangas/guantes | `rbxassetid://122068838695999` |
| `hunter_classic_pants_r15.png` | Pantalón Cazador; piernas | `rbxassetid://87179305366044` |
| `cleric_classic_shirt_r15.png` | Camisa Clérigo; pecho y mangas/guantes | `rbxassetid://100777703457557` |
| `cleric_classic_pants_r15.png` | Pantalón Clérigo; piernas | `rbxassetid://99107701453907` |

Los IDs ya están asignados en `ShirtTemplate`/`PantsTemplate` dentro de sus modelos. Los archivos planos usan los paneles UV R15 oficiales; el resto del lienzo queda transparente. Las manos/pies se completan con el color de los segmentos MeshPart para que no dependan de una malla de guante o calzado superpuesta.

## Iconos existentes — conservar

Los 23 iconos PNG existentes en `Assets/Icons/EST-07/` se conservaron y ya están subidos a Roblox Asset Server. No se generaron iconos adicionales en esta fase.

| Archivo | Asset ID |
| --- | --- |
| `Icon_Item_hunter_helmet` | `rbxassetid://137610109621361` |
| `Icon_Item_hunter_chest` | `rbxassetid://131558470351046` |
| `Icon_Item_hunter_shoulders` | `rbxassetid://139441004785394` |
| `Icon_Item_hunter_legs` | `rbxassetid://85826663702067` |
| `Icon_Item_hunter_gloves` | `rbxassetid://120820499543095` |
| `Icon_Item_cleric_helmet` | `rbxassetid://116241904803125` |
| `Icon_Item_cleric_chest` | `rbxassetid://127848028128931` |
| `Icon_Item_cleric_shoulders` | `rbxassetid://136349816014004` |
| `Icon_Item_cleric_legs` | `rbxassetid://78444397053135` |
| `Icon_Item_cleric_gloves` | `rbxassetid://109283395182473` |
| `Icon_Item_cleric_wand` | `rbxassetid://127783741593782` |
| `Icon_Item_collar` | `rbxassetid://79057728400496` |
| `Icon_Item_ring` | `rbxassetid://71184214544880` |
| `Icon_Skill_cleric_smite` | `rbxassetid://136035690888487` |
| `Icon_Skill_cleric_burning_light` | `rbxassetid://112697972715347` |
| `Icon_Skill_cleric_hol_heal` | `rbxassetid://108254529745098` |
| `Icon_Skill_cleric_hol_word` | `rbxassetid://132555561552162` |
| `Icon_Skill_cleric_hol_shield` | `rbxassetid://139770938869698` |
| `Icon_Skill_cleric_hol_miracle` | `rbxassetid://103619140046107` |
| `Icon_Skill_cleric_wrath_spear` | `rbxassetid://88379416584464` |
| `Icon_Skill_cleric_wrath_mark` | `rbxassetid://122429218133191` |
| `Icon_Skill_cleric_wrath_divine_ire` | `rbxassetid://82677795410529` |
| `Icon_Skill_cleric_wrath_annihilation` | `rbxassetid://77668231097908` |

## Pendiente de integración

- En `ItemConfig`, conectar cada pieza corporal al nombre de modelo indicado, `visualType = "BodySkin"` y su lista exacta `bodySkinParts`.
- Conectar los cuatro modelos superpuestos al tipo/attachment que corresponda según los patrones existentes.
- Revisar las reglas `suppressedByBodySkin` para evitar duplicar visuales antiguos en pecho, guantes o piernas.
- La prueba de viewport con el rig R15 canónico confirmó que las texturas se aplican sobre el cuerpo; probar el set completo junto a casco, hombreras y armas tras la integración.

Los modelos se añadieron a la sesión Edit abierta de Roblox Studio. No se publicó el Place a Roblox; guardar el proyecto desde Studio después de integrar y revisar el set completo.

Los intentos previos de prendas-malla en `Workspace` se dejaron como borradores sin integrar ni borrar. No son los modelos finales de pecho, guantes o piernas.
