# Party roles simplificados

Propuestas de reemplazo para revisar los tres roles del panel de equipos:

- Tank: escudo azul con contorno de latón y una placa central.
- Heal: cruz de curación clara con centro azul.
- DPS: dos espadas simples cruzadas en X.
- PNG RGBA de 512×512 y fondo transparente.
- Se incluyen masters y tamaños de muestra 16, 24, 32, 48 y 64 px.
- Los iconos activos Tank (variante 02 con chevron), Heal y DPS, junto con sus variantes uncovered, están aprobados e instalados en `Assets/Icons/UI/PartyRoles/`. La primera variante activa de Tank queda como alternativa no aprobada.
- Los prompts exactos y referencias están en prompts.json.


## Variante adicional de Tank

Se añadió una segunda versión del mismo escudo heater: conserva el contorno exterior de la opción A y cambia el broquel central por un chevron defensivo. La comparación A/B está en Preview_TankVariants.png. Se eligió y aprobó la variante 02 con chevron, instalada como `Assets/Icons/UI/PartyRoles/Icon_UI_role_tank.png`; la variante A permanece en revisión. Prompt exacto: Prompt_Icon_UI_role_tank_variant_02.json.


## Variantes activas aprobadas · 2026-10-23

- `Assets/Icons/UI/PartyRoles/Icon_UI_role_tank.png` — escudo con chevron de la variante 02.
- `Assets/Icons/UI/PartyRoles/Icon_UI_role_heal.png` — cruz de curación simplificada.
- `Assets/Icons/UI/PartyRoles/Icon_UI_role_dps.png` — espadas cruzadas simplificadas.

Los iconos activos anteriores se archivaron en `Assets/Source/Design/PartyRoles-Active-Originals-2026-10-23/`. Las versiones anteriores siguen necesitando una nueva carga a Roblox para actualizar sus IDs publicados.

## Variantes uncovered aprobadas · 2026-10-23

Se prepararon y aprobaron los estados inactivos de Tank, Heal y DPS a juego con el set simplificado. Se conservaron las siluetas activas; para Tank se usó la variante 02 con chevron, elegida por Diego. La paleta sigue los `*_uncovered` existentes: carbón/gris con matiz violeta apagado y sin bajar la opacidad del símbolo.

- `Assets/Icons/UI/PartyRoles/Icon_UI_role_tank_uncovered.png`
- `Assets/Icons/UI/PartyRoles/Icon_UI_role_heal_uncovered.png`
- `Assets/Icons/UI/PartyRoles/Icon_UI_role_dps_uncovered.png`

PNG RGBA 512×512 con exterior transparente. Masters en `Masters/`, muestras a 16/24/32/48/64 px en `Previews/`, y prompts/referencias en `uncovered_prompts.json`. La comparación activo/inactivo está en `Preview_PartyRoles_Uncovered.png`. Los originales reemplazados están archivados en `Assets/Source/Design/PartyRoles-Uncovered-Originals-2026-10-23/`. Los IDs de Roblox todavía necesitan re-subida para actualizar el juego publicado.
