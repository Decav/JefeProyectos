# Entrega de diseño — HU-ESTETICA-18

Assets visuales producidos para los uniques del Guardián de la Escarcha. No incluye enlace a `ItemConfig`, loot ni gameplay.

## Modelos 3D en Roblox Studio

Ubicación: `ReplicatedStorage.Assets.Models.Equipment`

| Nombre | Uso | PrimaryPart | Tamaño aproximado |
|---|---|---|---|
| `unique_frost_edge` | Filo de la Escarcha, espada 1H | `Handle` | 0.90 × 2.49 × 0.24 studs |
| `unique_frostbow` | Arco del Vendaval Helado, arco 2H | `Handle` | 1.28 × 4.80 × 0.55 studs |
| `unique_glacial_wand` | Vara del Invierno, varita 1H | `Handle` | 0.38 × 2.35 × 0.38 studs |

Los tres modelos son entregas MeshAI (`RBX_AI_GENERATION_TYPE="GenerateMesh"`) sin scripts, con `Anchored=false`, `CanCollide=false`, `CanTouch=false`, `CanQuery=false` y `Massless=true`. El arco sigue el contrato de `hunter_bow`: `Handle` es un `Part` invisible y `BowGrip` es la malla visible del mango. Las piezas editables quedan separadas como `frozen_bow_body`, `upper_ice_cap`, `lower_ice_cap`, `single_bowstring` y los acentos de hielo. El acabado del arco usa material `Ice` azul translúcido para cuerpo y cristales, `Neon` azul pálido para la cuerda y cuero oscuro en el mango. Las piezas del arco están unidas al `Handle` con `WeldConstraint` y el modelo tiene los atributos de asset visual del patrón del cazador.

## Iconos PNG

Ubicación: `Assets/Icons`

| Archivo | ID visual | Especificación |
|---|---|---|
| `Icon_Item_unique_frost_edge.png` | `Icon_Item_unique_frost_edge` | 512×512, fondo negro #000000 |
| `Icon_Item_unique_frostbow.png` | `Icon_Item_unique_frostbow` | 512×512, fondo negro #000000 |
| `Icon_Item_unique_glacial_wand.png` | `Icon_Item_unique_glacial_wand` | 512×512, fondo negro #000000 |

Los iconos fueron generados como ilustraciones originales para este proyecto y redimensionados a 512×512 conservando el fondo negro. No se modificaron archivos de configuración ni registros canónicos.

## Pendiente para integración

El desarrollador puede enlazar cada `templateId` con el mismo `visualModelId` e `iconId`, definir `visualType="HandModel"`, `attachTo="RightHand"` y ajustar el `offset` en `ItemConfig`. El registro de assets y la verificación en juego quedan para esa fase.
