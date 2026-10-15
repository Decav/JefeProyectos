# Miniaturas promocionales — Vandrheim

Fecha: 2026-10-14. Creadas con ImageGen integrado a partir de los assets propios y la identidad visual de los iconos del juego.

| Propuesta | JPG para cargar | Contenido |
|---|---|---|
| 01 · Desafío de Jotunn | `Thumbnail_Game_01_Desafio_Jotunn_1920x1080.jpg` | Paladín con luz dorada frente al jefe de hielo. |
| 02 · Reliquia de Helada | `Thumbnail_Game_02_Reliquia_Helada_1920x1080.jpg` | Paladín con el espadón único en el acceso a la mazmorra. |

Recomendación visual para la miniatura principal: **01 · Desafío de Jotunn**. Presenta el conflicto principal, dos siluetas separadas y contraste entre luz cálida e hielo. La segunda complementa la colección mostrando equipamiento y exploración.

## Formato y preparación

- Entregas: **1920×1080, 16:9, fondo opaco**, en JPG y PNG.
- JPG con calidad 95 y menos de 3 MB por archivo; conveniente para la carga de miniaturas.
- Originales generados: 1672×941, conservados en `Masters/`. La exportación ajusta mínimamente el encuadre y escala a la resolución de entrega sin deformar proporciones.
- Texto: **Vandrheim**, sin tilde. Título en la parte superior; se evita colocar texto esencial en la franja inferior.
- Revisión visual: personajes y equipamiento reconocibles, legibilidad del título y composición horizontal. Ver `Preview_Comparison.png`.

Formato y ubicación del texto basados en [Roblox Creator Hub — Miniaturas](https://create.roblox.com/docs/es-es/production/publishing/thumbnails). Estado: pendiente de selección y publicación por el responsable del juego.

## Fuentes y reproducción

Referencias: los masters de los iconos `02_Desafio` y `03_Reliquia`, el retrato propio de Jotunn, casco y coraza Paladin_Blue y `Icon_Item_unique_frost_greatsword`. Ilustraciones promocionales asistidas con IA basadas en assets internos de Vandrheim.

Los prompts exactos, roles de las referencias y rutas fuente están en `prompts.json`. `Tools/ExportThumbnails.py` reproduce las entregas, preserva los originales y crea la comparación. Registro agregado en `ASSETS_LIST.md`.
