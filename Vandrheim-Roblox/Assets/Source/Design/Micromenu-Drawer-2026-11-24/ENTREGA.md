# Icono de Micromenú — Drawer / Menú Desplegable

Fecha: 2026-11-24.
Rol: DesignerAgent (Producción de assets visuales).

## Objetivo y Estilo

Icono para el botón de **Drawer** (menú desplegable / cajón de accesos) del micromenú, alineado con los iconos existentes (`Icon_Menu_dungeon`, `Icon_Menu_quest`, `Icon_Menu_run`):
- Paleta: latón cálido `#C89445`, pergamino `#F4EDE0`, contornos gruesos en carbón oscuro `#292A2E` y biselado plano limpio.
- Técnica: PNG `512×512`, RGBA con fondo transparente estricto (`corner_alphas = [0, 0, 0, 0]`), sin marco externo, legible a 24–32 px.

## Entregables

1. **Oficial (canónica):**
   - Archivo: `Assets/Icons/UI/Menu/Icon_Menu_drawer.png`
   - Símbolo: Cuadrícula 2×2 de cuatro piezas biseladas de latón dorado y centro en pergamino.
   - Master: `Masters/Icon_Menu_drawer_grid_master.jpg`

2. **Variante archivada:**
   - Archivo: `Assets/Source/Design/Micromenu-Drawer-2026-11-24/Icon_Menu_drawer_variant_bars.png`
   - Símbolo: Tres barras horizontales nórdicas biseladas de latón dorado con remaches laterales.
   - Master: `Masters/Icon_Menu_drawer_bars_master.jpg`

3. **Validación y soporte:**
   - Previews a 16, 24, 32, 48 y 64 px en `Previews/`.
   - Hoja comparativa con los iconos actuales: `Preview_StyleMatch.png`.
   - Script de exportación: `Tools/Export_Drawer_Icon.py`.
