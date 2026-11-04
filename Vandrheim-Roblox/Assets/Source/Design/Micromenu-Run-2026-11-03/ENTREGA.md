# Icono de Micromenú / Control Móvil — Correr (Alternancia Correr / Caminar)

Fecha: 2026-11-03.
Rol: DesignerAgent (Producción de assets visuales).

## Objetivo y Contexto

Creación del icono de UI para representar la acción de **Correr** (alternancia correr/caminar con tecla `U` en PC o `MovementToggleButton` en móvil, documentado en `HU-R6.1` y `HU-R6.29`). El estilo emula estrictamente la familia visual de los iconos de micromenú (`Icon_Menu_*`):

- **Paleta canónica:** Latón cálido `#C89445`, pergamino `#F4EDE0`, contornos definidos en carbón oscuro `#292A2E` y cuero marrón cálido.
- **Técnica:** 512×512 PNG, modo RGBA con canal alfa transparente (`corner_alphas = [0,0,0,0]`), silueta centrada (~420 px máx.) con alta legibilidad en tamaños reducidos (24–32 px).

## Entregables

1. **Propuesta principal (canónica):**
   - Archivo: `Assets/Icons/UI/Menu/Icon_Menu_run.png`
   - Símbolo: Bota nórdica alada en zancada veloz hacia adelante con refuerzos de latón dorado, alas de pergamino y estelas de viento.
   - Master: `Masters/Icon_Menu_run_winged_boot_master.jpg`

2. **Propuesta variante (alternativa):**
   - Archivo: `Assets/Source/Design/Micromenu-Run-2026-11-03/Icon_Menu_run_variant_warrior.png`
   - Símbolo: Guerrero nórdico en silueta de sprint hacia la derecha con yelmo de latón, capa corta de pergamino y estelas horizontales de velocidad.
   - Master: `Masters/Icon_Menu_run_warrior_master.jpg`

3. **Láminas de validación:**
   - Previews a 16, 24, 32, 48 y 64 px en `Previews/`.
   - `Preview_StyleMatch.png`: Comparación directa con los iconos actuales (`Icon_Menu_dungeon`, `Icon_Menu_quest`, `Icon_Menu_target_cycle`, `Icon_Menu_party`) sobre fondo oscuro `#222327` y pergamino claro `#EDE7DC`.

4. **Herramientas de apoyo:**
   - Script reproducible: `Tools/Export_Run_Icon.py`.
