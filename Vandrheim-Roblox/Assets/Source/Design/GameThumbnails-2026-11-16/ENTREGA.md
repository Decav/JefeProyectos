# Miniatura promocional R15 vs Jotunn — Vandrheim

Fecha: 2026-11-16.
Rol: DesignerAgent (Producción de assets visuales).

## Entregables (1920×1080, 16:9, RGB opaco)

Ubicación: `Assets/Images/Marketing/Thumbnails/Candidates/`

| Variante | Archivos | Uso |
|---|---|---|
| Limpia (sin texto) | `Thumbnail_Game_03_R15_Jotunn_clean_1920x1080.png` / `.jpg` | Arte base fiel al prompt con esquina inferior izquierda despejada para logotipo |
| Con logotipo oficial | `Thumbnail_Game_03_R15_Jotunn_logo_1920x1080.png` / `.jpg` | Versión lista para publicar con `Vandrheim__logotipo_nordico_glacial.png` compuesto abajo a la izquierda |

## Especificaciones y Verificación

- **Resolución:** `1920 × 1080` exactos (relación 16:9), modo RGB opaco.
- **Peso JPG (calidad 95):** ~716 KB (limpia) y ~749 KB (con logo), por debajo del límite de 3 MB de Roblox Creator Hub.
- **Referencias respetadas:**
  - Armadura `Paladin_Blue` (`Icon_Item_paladin_helmet_blue.png`, `Icon_Item_paladin_chest_blue.png`) en avatar estilizado Roblox R15.
  - Espadón único de escarcha (`Icon_Item_unique_frost_greatsword.png`).
  - Jefe Jotunn (`Portrait_Boss_Jotunn.png`).
  - Logotipo oficial (`Vandrheim__logotipo_nordico_glacial.png`).
- **Archivo fuente y herramientas:**
  - Master original (`1376×768`): `Masters/Thumbnail_Game_03_R15_Jotunn_master.jpg`.
  - Script reproducible: `Tools/Export_Thumbnail_R15_Jotunn.py`.
  - Comparativa: `Previews/Preview_Comparison.png`.

## Variantes A y C con logotipo (2026-11-16)

Ubicación: `Assets/Images/Marketing/Thumbnails/Candidates/`

| Variante | Archivos | Contenido |
|---|---|---|
| A · Jefe Jotunn | `Thumbnail_Game_04_Jefe_Jotunn_logo_1920x1080.png` / `.jpg` | Paladín R15 con armadura Paladin_Blue y espadón de escarcha contra Jotunn. Logotipo abajo a la izquierda. |
| C · Botín épico | `Thumbnail_Game_05_Botin_Epico_logo_1920x1080.png` / `.jpg` | Paladín R15 frente al cofre con escudo, anillo, Frost Edge y arco de escarcha. Texto "EPIC LOOT" sobre el logotipo. |

- Masters 1920×1080: `Masters/Thumbnail_Game_04_VarianteA_Jotunn_1920_master.png` y `Masters/Thumbnail_Game_05_VarianteC_Botin_1920_master.png`.
- Script reproducible: `Tools/Export_Thumbnails_A_C.py`. Comparativa: `Previews/Preview_A_C_logo.png`.
- JPG calidad 95, ~710 KB cada uno. Prompts de edición en `prompts.json` (`edits_v2`).
- Observación: el logotipo oficial `Vandrheim__logotipo_nordico_glacial.png` tiene un cristal sobre la "a" que se lee como tilde. Decisión del responsable (2026-11-16): se mantiene el logotipo oficial sin cambios.
