# Micromenú — cuatro iconos complementarios

Fecha: 2026-10-17. Producción con ImageGen integrado usando como referencias directas los iconos actuales de grimorio, equipamiento y talentos.

| Archivo / iconId | Función | Símbolo |
|---|---|---|
| `Icon_Menu_dungeon.png` | Abrir el panel de dungeon | Entrada de piedra y reja dorada. |
| `Icon_Menu_dungeon_guide.png` | Abrir la guía de dungeon | Pergamino con pictograma de acceso y ruta. |
| `Icon_Menu_party.png` | Abrir el panel de equipos/grupos | Tres bustos que representan miembros de un grupo. |
| `Icon_Menu_target_cycle.png` | Alternar el objetivo entre enemigos | Cabeza enemiga angular rodeada de dos flechas de cambio. |

## Características de entrega

- Cuatro **PNG 512×512 RGBA con transparencia real** y márgenes coherentes; sin texto ni marco exterior.
- Paleta de referencia: latón `#C89445`, pergamino `#F4EDE0`, pizarra y marrón oscuro. Contornos oscuros y sombreado suave, siguiendo el micromenú existente.
- Originales generados conservados en `Masters/`. La exportación normaliza únicamente tamaño y encuadre; preserva el alfa y el dibujo generado.
- Variantes de revisión a 24, 32 y 48 píxeles en `Previews/`.
- `Preview_Micromenu.png`: cuatro diseños grandes y vistas reales a 32/24 px sobre fondo del HUD.
- `Preview_StyleMatch.png`: comparación de los originales del proyecto y los cuatro nuevos sobre negro.

Revisión completada: las cuatro acciones conservan siluetas diferentes y se revisaron a 24–32 px. Confirmados tamaño final, modo RGBA, transparencia exterior y ausencia de recortes en los elementos. En tamaño pequeño se prioriza la silueta; los detalles del mapa y la mampostería son secundarios.

El panel de grupos usa `party` para distinguirlo del icono existente `Icon_Menu_equipment`, destinado a armadura/equipamiento. Estado: pendientes de aprobación visual, carga a Roblox y asignación de `rbxassetid`.

## Procedencia y reproducción

Fuente: producción propia asistida con ImageGen; referencias internas de Vandrheim:

- `Assets/Icons/UI/Menu/Icon_Menu_spellbook.png`
- `Assets/Icons/UI/Menu/Icon_Menu_equipment.png`
- `Assets/Icons/UI/Menu/Icon_Menu_talents.png`

También se consultaron `Icon_Menu_bag.png` y HU-ESTETICA-23 para estilo, tamaños y funciones. El fondo de los nuevos iconos es transparente siguiendo las decisiones posteriores del proyecto.

Prompts exactos, referencias y fuentes generadas: `prompts.json`. Script aislado de exportación y láminas de revisión: `Tools/ExportMicromenu.py`. Registro de los cuatro assets agregado a `ASSETS_LIST.md`.
