# Propuestas de icono oficial — Vandrheim

Fecha: 2026-10-14. Producción con la herramienta integrada ImageGen y referencias propias del proyecto.

| Propuesta | Archivo listo para cargar | Idea visual |
|---|---|---|
| 01 · Jotunn | `Icon_Game_01_Jotunn_512.png` | Rostro grande del jefe, identidad nórdica y amenaza de hielo. |
| 02 · Desafío | `Icon_Game_02_Desafio_512.png` | Paladín con luz dorada frente a Jotunn; comunica combate y aventura. |
| 03 · Reliquia | `Icon_Game_03_Reliquia_512.png` | Espadón único de escarcha; comunica equipo y recompensa. |

Recomendación de diseño: **02 · Desafío**. El dorado del héroe se separa del azul del jefe y ofrece dos focos claros. **01 · Jotunn** es la alternativa más directa para reconocer al personaje. Son propuestas para seleccionar el icono oficial; su capacidad de atraer jugadores todavía no se ha medido.

## Referencias consultadas y usadas

- `Assets/Icons/Vandrheim__logotipo_nordico_glacial.png`: lettering e identidad del título.
- `Assets/Icons/VandrheimBanner.png`: referencia de la dirección glacial y la selección de personajes.
- `Assets/Images/Enemies/Portraits/Portrait_Boss_Jotunn.png`: identidad del jefe.
- `Assets/Icons/Items/Armor/Paladin/Blue/Icon_Item_paladin_helmet_blue.png` y `Icon_Item_paladin_chest_blue.png`: armadura del héroe.
- `Assets/Icons/Items/Weapons/Unique/Icon_Item_unique_frost_greatsword.png`: diseño del espadón.
- GDD: RPG en tercera persona, clases, equipamiento y mazmorra Helada. Paleta visual: acero azulado, cuero oscuro, oro cálido y hielo.

## Archivos y preparación

Cada archivo principal es **PNG RGB opaco, 512×512**, con composición cuadrada y fondo ilustrado. El fondo forma parte del arte promocional del icono de experiencia. Los originales de mayor resolución están en `Masters/`; las vistas a 150×150 están en `Previews/`. `Preview_Comparison.png` reúne las tres propuestas en tamaño grande y pequeño.

La revisión visual confirmó el título **Vandrheim**, la identidad del jefe y los assets principales, el contraste y la lectura a tamaño pequeño. Se corrigió la tilde que ImageGen había añadido al título siguiendo la referencia de lettering.

Roblox recomienda iconos cuadrados de al menos 512×512 y revisarlos a tamaños pequeños como 150×150: [Creator Hub — Iconos](https://create.roblox.com/docs/es-es/production/publishing/experience-icons).

Los prompts exactos de creación y corrección, las referencias y las rutas fuente están en `prompts.json`. `Tools/ExportGameIcons.py` reproduce los tamaños de entrega y la lámina de comparación. Fuente/licencia: producción propia asistida con ImageGen, assets internos de Vandrheim. Estado: pendiente de selección y publicación por el responsable del juego.
