# HU-ESTETICA-34 — Entrega de diseño para revisión

**Estado:** prototipo visual pendiente de aprobación. Los modelos quedaron ordenados en `Workspace.ESTWeaponPlace` para revisión, dentro del DataModel abierto de `Vandrheim-RPG [ALFA]`. Los cambios siguen en la sesión de edición de Studio; no he guardado ni publicado el place. Los PNG y documentos siguen en `Assets/Temp/HU-ESTETICA-34`.

## Meshes AI segmentados

Galería de revisión en Roblox Studio: `Workspace.ESTWeaponPlace.Armas`.

Hay 12 modelos generados con Mesh AI y 74 `MeshPart` independientes en total. Las piezas tienen nombres por componente (hoja, guarda, empuñadura, pomo, cristales, runas, etc.) y permanecen bajo un mismo modelo para conservar su ensamblaje. La galería usa `Anchored=true` y sin colisión; ningún modelo contiene scripts. Cada modelo incluye atributos de icono fuente, tier, mano de ajuste, número de piezas e ID del asset.

La escena se limpió: se retiraron los modelos de una sola malla, las copias con nombres de prompts y la galería anterior de bloques/ajuste R15. En Studio quedan solo los 12 modelos segmentados de esta HU dentro de las cuatro carpetas de categoría. Los IDs de los modelos publicados siguen en el manifiesto.

`MESH_AI_SEGMENTED.md` registra los IDs de los 12 modelos y el nombre de cada componente. Los modelos se deben revisar visualmente y ajustar al rig R15 antes de enlazarlos. Las piezas están separadas para poder sustituir una sección, pero todavía no se añadieron welds/constraints de producción.

**Flujo de referencia:** Mesh AI en Studio solo recibe texto. Tras consultarte, se usaron prompts detallados escritos a partir de la silueta y materiales de cada icono; no se pudo pasar el PNG directamente a la generación de geometría.

## Iconos

Finales en `Icons_512/`: 21 PNG, 512×512, RGBA con transparencia alfa real. Son 11 iconos azul/morado por familia y el único 2H, más 10 propuestas blanco/verde. No hay archivos fuente locales para los iconos blanco/verde, así que esas diez propuestas aún requieren comparación o recolor técnico de los originales.

Los renders fuente de mayor resolución quedan en `Icons/`. Los nombres siguen la convención de ASSETS_LIST/HU-ITEMS-06.

## Scripts de apoyo

`Tools/BuildWeaponPreviews.luau`, `BuildWeaponFitPreviews.luau`, `ArrangeWeaponFitPreviews.luau`, `CleanWeaponFitRigs.luau` y `ResizeIcons.ps1` sirven para prototipos y exportación local.

## Pendientes

- Tu instrucción de transparencia aplica a estos borradores; `ASSETS_LIST.md` todavía especifica fondo negro. No actualicé el catálogo ni los documentos canónicos.
- `ASSETS_POLICY.md` indica Gemini Imagen para iconos IA. Los iconos actuales se generaron con OpenAI ImageGen y requieren aprobación antes de usarlos como finales.
- Revisar la similitud visual de las 12 meshes frente a sus iconos y comprobar escala/agarre en R15. Los modelos AI aún no tienen fit preview sobre rigs.
- Los assets que produjo la herramienta Mesh AI tienen IDs listados en el manifiesto; no están enlazados en `ItemConfig`, `ReplicatedStorage`, `ASSETS_REGISTRY` ni `ASSETS_LIST`.
- No guardé cambios en el place de producción.
