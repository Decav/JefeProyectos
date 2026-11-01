# Iconos de acciones para UI

Fecha: 2026-10-25. Estado: aprobados y copiados a `Assets/Icons/UI/Common/`. La carga a Roblox queda pendiente.

## Iconos

| Archivo | Función | Lectura visual |
| --- | --- | --- |
| `Exports/Icon_UI_settings.png` | Abrir configuración | Engranaje dorado de ocho dientes. |
| `Exports/Icon_UI_trash.png` | Eliminar basura | Basurero oscuro con tapa y ranuras claras. |
| `Exports/Icon_UI_sell_all.png` | Vender todo | Moneda, pila de monedas y flecha ascendente. |

## Especificación

- Cada exportación es PNG RGBA de 512×512 con transparencia real, sin fondo ni placa.
- Las siluetas usan un contorno carbón, oro cálido y crema pergamino, siguiendo el botón Close y los iconos del micromenú.
- Se incluyen vistas previas a 16, 24, 32, 48 y 64 px por icono, además de una lámina sobre fondos oscuro y claro.
- Los PNG generados originales se conservan en `Masters/`; las exportaciones canónicas de 512×512 están en `Assets/Icons/UI/Common/`. Los exports y previews se pueden regenerar con `Tools/Export_Action_Icons.py`.
- El prompt completo por asset está en `prompts.json`.

Fuente: producción propia asistida con ImageGen integrado, para uso interno de Vandrheim.
