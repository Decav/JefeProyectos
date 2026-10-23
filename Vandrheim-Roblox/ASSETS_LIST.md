Eres un artista de iconos para un MMO de fantasía medieval (estilo WoW/Diablo).
Genera cada ítem como UNA imagen separada, en estilo consistente.

REGLAS TÉCNICAS (obligatorias para todas):

- 512x512, **FONDO TRANSPARENTE** (decisión 2026-09-22: los iconos nuevos ya NO llevan fondo negro; reemplaza el estándar anterior).
- Sin marco, sin borde, sin texto, sin UI, sin sombra exterior.
- El objeto ocupa ~85% del encuadre, centrado, en perspectiva 3/4 (diagonal),
  como icono de inventario MMO.
- Estilo: pintado digital, detalle fino, iluminación de fantasía, gama de acero
  frío azulado + cuero oscuro + dorado cálido (paleta Vandrheim). No es cartoon.
  Sin personajes, manos ni texto.

ÍTEMS (uno por imagen, nómbrala así):

1. Icon_Item_sword_1h — Espada larga de acero azulado con guarda dorada y
   empuñadura de cuero oscuro, filo brillante.
2. Icon_Item_shield_protector — Escudo torre de acero con cruz dorada embutida y
   remaches.
3. Icon_Item_sword_2h_paladin — Espadón de dos manos, hoja ancha azulada, guarda
   dorada, pomo con cruz.
4. Icon_Item_helmet_plate — Yelmo de caballero con visor, cresta dorada y gema
   azul.
5. Icon_Item_chest_plate — Coraza de placas con pectorales marcados y hombreras
   con dorado.
6. Icon_Item_shoulders_plate — Hombreras de placas grandes con ribete dorado y
   remaches.
7. Icon_Item_legs_plate — Grebas de placas con rodilleras y cuero oscuro.
8. Icon_Item_gloves_plate — Guantes de placas articulados con dorado en
   nudillos.
9. Icon_Item_potion_health — Frasco de vidrio redondo con corcho y líquido rojo
   brillante, brillo mágico.
10. Icon_Item_potion_mana — Frasco igual con líquido azul brillante.

POCIONES NUEVAS (HU-ITEMS-02 — una por imagen, nómbrala así; las chicas reusan los iconos existentes 9/10):
11. Icon_Item_potion_hp_large — Frasco grande de vidrio con corcho y líquido rojo brillante, brillo mágico intenso, tamaño doble que la poción chica.
12. Icon_Item_potion_mp_large — Frasco grande igual con líquido azul brillante intenso.
13. Icon_Item_potion_buff_atk — Frasco con líquido naranja/dorado incandescente y un filo de espada en llamas como motivo, aura de furia.
14. Icon_Item_potion_buff_def — Frasco con líquido gris/pizarra metálico y un escudo de hierro como motivo, aura de protección.
15. Icon_Item_potion_buff_hp — Frasco con líquido rojo profundo y un corazón de runas doradas como motivo, aura de vitalidad.

ÍTEM EXTRA (sin número para no chocar con las skills):
Icon_Item_bow — Arco de cazador: arco curvo de madera oscura con cuerdas tensas, refuerzos de cuero y hierro frío.

HABILIDADES DEL PALADÍN (una por imagen, nómbrala así):
11. Icon_Skill_paladin_holy_strike — Golpe sagrado: espada de luz dorada golpeando en diagonal con destellos sagrados.
12. Icon_Skill_paladin_light_verdict — Veredicto de luz: rayo de fe dorado brillante lanzado hacia arriba, resplandor radiante.
13. Icon_Skill_paladin_prot_shield_bash — Embate de escudo: escudo de acero impactando de frente con ondas de choque y chispas.
14. Icon_Skill_paladin_prot_vow — Voto protector: símbolo de cruz dorada resplandeciente con aura de sanación cálida y partículas ascendentes.
15. Icon_Skill_paladin_prot_sacred_wall — Muro sagrado: escudo de energía dorada translúcida con runas brillantes, como barrera mágica.
16. Icon_Skill_paladin_prot_consecration — Consagración: círculo de runas sagradas en el suelo con llamas doradas, vista cenital.
17. Icon_Skill_paladin_ret_holy_edge — Filo sagrado: hoja de energía dorada flameante en diagonal.
18. Icon_Skill_paladin_ret_divine_flames — Llamas divinas: llamas sagradas blancas/doradas ardiendo alrededor de una llama central.
19. Icon_Skill_paladin_ret_sentence — Sentencia: martillo de juicio dorado brillante con rayos de luz.
20. Icon_Skill_paladin_ret_holy_ring — Anillo de luz sagrada: anillo de luz dorada expandiéndose en todas direcciones, burst sagrado.

HABILIDADES DEL CAZADOR (una por imagen, nómbrala así): 
21. Icon_Skill_hunter_savage_cut — Corte salvaje: garra/hoja curva cortando en diagonal con estela de velocidad. 
22. Icon_Skill_hunter_piercing_shot — Disparo perforante: flecha en vuelo con punta metálica brillante y estela de viento. 
23. Icon_Skill_hunter_asm_ambush — Emboscada: hoja corta apareciendo desde la oscuridad con destello de acero. 
24. Icon_Skill_hunter_asm_crimson — Filo carmesí: hoja teñida de rojo sangre con gotas y brillo. 
25. Icon_Skill_hunter_asm_twin — Cortes gemelos: dos hojas cruzadas en X con chispas de acero. 
26. Icon_Skill_hunter_asm_whirlwind — Torbellino: anillo de viento con hojas de acero girando alrededor del centro. 
27. Icon_Skill_hunter_mm_venom — Flecha venenosa: flecha con punta envuelta en veneno verde burbujeante y estela tóxica, vista diagonal. (v2.3/R8e — reemplaza a Flecha pesada) 
28. Icon_Skill_hunter_mm_trueshot — Tiro certero: flecha centrada en un blanco con impacto preciso y anillo de tensión. 
29. Icon_Skill_hunter_mm_chain — Tiro en cadena: rayo de energía conectando dos objetivos con flechas. 
30. Icon_Skill_hunter_mm_death — Disparo mortal: flecha espectral con brillo oscuro y destello letal.

## UBICACIÓN CANÓNICA DE ICONOS FINALES

Los PNG finales se guardan bajo `Assets/Icons/` por dominio; **no se dejan sueltos ni en `Assets/Temp`**. Masters, prompts, previews, renders fuente y entregas aprobadas se archivan bajo `Assets/Source/`; Temp queda para trabajo no aprobado. Estructura completa: `Assets/README.md`.

| Tipo | Ruta canónica | Convención / contenido |
|---|---|---|
| Clases | `Assets/Icons/Classes/` | `Icon_Class_*` |
| Armadura | `Assets/Icons/Items/Armor/<Clase>/<Tier>/` | Base, Blue, Frost; nombres `Icon_Item_<clase>_<pieza>_<tier>.png`; iconos base existentes en `<Clase>/Base/` |
| Armas | `Assets/Icons/Items/Weapons/<Familia>/` | `OneHand`, `TwoHand`, `Bow`, `Wand`, `Shield`, `Unique`; conservar el nombre canónico `Icon_Item_*` |
| Consumibles | `Assets/Icons/Items/Consumables/` | `Icon_Item_potion_*` |
| Accesorios | `Assets/Icons/Items/Accessories/` | collar, anillo y joyería |
| Habilidades | `Assets/Icons/Skills/<Clase>/` | `Icon_Skill_<clase>_*` |
| Talentos | `Assets/Icons/Talents/` | `Icon_Talent_*` activos |
| UI | `Assets/Icons/UI/<Menu,Common,Currency,Stats,Death,PartyRoles>/` | `Icon_Menu_*`, `Icon_UI_*`, `Icon_Stat_*` |
| Retratos/branding/marketing | `Assets/Images/{Enemies/Portraits,Brand,Marketing}/` | `Portrait_*`, logotipo/banner, iconos/miniaturas promocionales |

### Armaduras y armas por tier (HU-ESTETICA-33/34)

* Armaduras azules y Frost: `Assets/Icons/Items/Armor/<Paladin|Hunter|Cleric>/<Blue|Frost>/`.
* Armas por tier: `Assets/Icons/Items/Weapons/<familia>/` (`sword→OneHand`, `greatsword→TwoHand`, `bow→Bow`, `wand→Wand`, `shield→Shield`); las cuatro `unique_frost_*` van en `Unique/`.
* Los `Icons/` fuente, masters y previews de EST-33/34 se archivan en `Assets/Source/Itemization/` y `Assets/Source/Design/`; el juego y la documentación de integración usan la ruta canónica de arriba.

## ICONOS UI · PANEL DE MUERTE / EST-38

**Imágenes PNG generadas** (no glifos vectoriales de Pencil): mismo estilo que los iconos de ítems/skills — pintado digital de fantasía, paleta Vandrheim (latón `#C89445`, pergamino `#F4EDE0`, frío `#8FB7D6`, fondos oscuros), silueta legible a 24 px. Archivos locales finales en `Assets/Icons/UI/Death/`; los `rbxassetid` aún están pendientes de enlace/config.
**Técnica:** 512×512, **fondo transparente** (estándar vigente), sin texto, objeto ~85% centrado, perspectiva 3/4 o frontal según el icono; se suben a Roblox como PNG y el dev configura los `rbxassetid` en el config del death panel (`ReviveConfig`/`DeathPanelConfig`: `deathRuneIconId`, `reviveGemIconId`, `reviveGemOffIconId`, `robuxIconId`).

- `Icon_UI_death_death` — runa de muerte (calavera/cráneo nórdico grabado), frío `#8FB7D6`.
- `Icon_UI_death_revive` — gema de resurrección (oro/latón con brillo interior), latón `#C89445`. **Variante apagada:** `Icon_UI_death_revive_off` (gema oscura/opaca `#52495D`) para el contador X/3.
- `Icon_UI_death_robux` — moneda Vanrhheim (oro) sobre anillo de hielo; el texto "R$ 50" NO va dentro del glifo (lo pinta la UI).

| Asset | Nodo Pencil / archivo | Roblox |
|---|---|---|
| Icon_UI_death_death | `Assets/Icons/UI/Death/Icon_UI_death_death.png` | (pendiente) |
| Icon_UI_death_revive | `Assets/Icons/UI/Death/Icon_UI_death_revive.png` | (pendiente) |
| Icon_UI_death_revive_off | `Assets/Icons/UI/Death/Icon_UI_death_revive_off.png` | (pendiente) |
| Icon_UI_death_revive_spent | `Assets/Icons/UI/Death/Icon_UI_death_revive_spent.png` | (pendiente) |
| Icon_UI_death_robux | `Assets/Icons/UI/Death/Icon_UI_death_robux.png` | (pendiente) |


## ICONOS UI · MATCHMAKING / EST-37

Pictogramas legibles a 24 px, **fondo transparente**, sin texto dentro del glifo. El estado cubierto usa el icono en color; la falta de rol usa su variante apagada. IDs actualizados con los recursos de Roblox proporcionados por el usuario:

- `Icon_UI_role_tank` / `Icon_UI_role_tank_uncovered` — escudo: rol Tank cubierto / pendiente.
- `Icon_UI_role_heal` / `Icon_UI_role_heal_uncovered` — cruz de vida: rol Heal cubierto / pendiente.
- `Icon_UI_role_dps` / `Icon_UI_role_dps_uncovered` — espadas cruzadas: rol DPS cubierto / pendiente.

Los iconos cubiertos se registran en `RoomConfig.RoleIcons`; sus variantes apagadas en `RoomConfig.RoleIconsUncovered`. El indicador de composición considera cubierto Tank con 1, Heal con 1 y DPS con 2 miembros.

| Asset | ID de recurso | Tipo | Modificado | Creador |
|---|---:|---|---:|---|
| Icon_UI_role_heal | `128865686691543` | Image | `1792729030367` | Decavii |
| Icon_UI_role_dps_uncovered | `109267135109201` | Image | `1792729030595` | Decavii |
| Icon_UI_role_heal_uncovered | `115978652940412` | Image | `1792729030667` | Decavii |
| Icon_UI_role_tank_uncovered | `95037433065246` | Image | `1792729030775` | Decavii |
| Icon_UI_role_tank | `99345927547899` | Image | `1792729030743` | Decavii |
| Icon_UI_role_dps | `111799977902329` | Image | `1792729030897` | Decavii |

Archivos locales canónicos: `Assets/Icons/UI/PartyRoles/` (nombres de archivo `Icon_UI_role_*.png`).

La licencia no venía indicada en los metadatos recibidos. Los seis IDs de la tabla fueron proporcionados por el PO el 2026-10-23 para los PNG simplificados aprobados; queda pendiente validar su render en el cliente publicado.

### PROPUESTAS SIMPLIFICADAS DE PARTY ROLES · 2026-10-22

Rediseño visual de Tank, Heal y DPS. El Tank con chevron, Heal y DPS activos y sus variantes `uncovered` fueron aprobados el 2026-10-23 e instalados como archivos canónicos. La primera opción activa de Tank sigue en revisión. Masters, prompts y muestras a 16–64 px en `Assets/Temp/PartyRoles-Simplified-2026-10-22/`.

| Propuesta | Rol | Archivo local | Fuente / licencia | Estado |
|---|---|---|---|---|
| `Icon_UI_role_tank_simplified` | Tank · escudo | `Assets/Temp/PartyRoles-Simplified-2026-10-22/Icon_UI_role_tank_simplified.png` | ImageGen + referencias propias; interno Vandrheim | Pendiente de revisión |
| `Icon_UI_role_tank` | Tank · escudo con chevron defensivo | `Assets/Icons/UI/PartyRoles/Icon_UI_role_tank.png` | ImageGen + referencias propias; interno Vandrheim | Aprobado; cargado a Roblox; ID vigente en la tabla superior |
| `Icon_UI_role_heal` | Heal · cruz | `Assets/Icons/UI/PartyRoles/Icon_UI_role_heal.png` | ImageGen + referencias propias; interno Vandrheim | Aprobado; cargado a Roblox; ID vigente en la tabla superior |
| `Icon_UI_role_dps` | DPS · espadas cruzadas | `Assets/Icons/UI/PartyRoles/Icon_UI_role_dps.png` | ImageGen + referencias propias; interno Vandrheim | Aprobado; cargado a Roblox; ID vigente en la tabla superior |
| `Icon_UI_role_tank_uncovered` | Tank · inactivo, escudo con chevron | `Assets/Icons/UI/PartyRoles/Icon_UI_role_tank_uncovered.png` | ImageGen + iconos uncovered propios; interno Vandrheim | Aprobado; cargado a Roblox; ID vigente en la tabla superior |
| `Icon_UI_role_heal_uncovered` | Heal · inactivo, cruz | `Assets/Icons/UI/PartyRoles/Icon_UI_role_heal_uncovered.png` | ImageGen + iconos uncovered propios; interno Vandrheim | Aprobado; cargado a Roblox; ID vigente en la tabla superior |
| `Icon_UI_role_dps_uncovered` | DPS · inactivo, espadas cruzadas | `Assets/Icons/UI/PartyRoles/Icon_UI_role_dps_uncovered.png` | ImageGen + iconos uncovered propios; interno Vandrheim | Aprobado; cargado a Roblox; ID vigente en la tabla superior |

Los iconos activos canónicos anteriores se conservaron en `Assets/Source/Design/PartyRoles-Active-Originals-2026-10-23/`; los anteriores uncovered están en `Assets/Source/Design/PartyRoles-Uncovered-Originals-2026-10-23/`. Los IDs de la tabla superior corresponden ahora a los PNG simplificados aprobados; falta validar su render en el cliente publicado.

## ICONO UNIVERSAL DE ORO

- `Icon_UI_currency_gold` — diamante vectorial inspirado en el glifo `◈`, color Hearthbound Gold `#C89445`. Componente maestro reutilizable en `Vandrheim-design.pen` (`S9eT1`, frame `tDU80`). Dos diamantes concéntricos; sin fondo, para usar junto al valor numérico.
- `Icon_UI_currency_gold_coins_stack` — alternativa de monedas apiladas (`Lucide / coins`), componente (`SOi1o`, frame `xqC61`).
- Tamaños de referencia: 16 / 24 / 32 / 48 px; recomendado 24 px para HUD, inventario y listas, 32 px en botones o recompensas. Usar junto al valor numérico (`12,840`), sin escribir “oro” dentro del glifo.
- La versión ilustrada de la moneda rúnica se creó con ImageGen a partir del componente de `Vandrheim-design.pen`; la carga como asset Roblox queda pendiente. Mantener color y silueta consistentes en HUD, tienda, vendors, recompensas y loot.
- Variantes para comparar en `EST-39 — Variantes del icono de oro` (`rQjsU`):
  - `Icon_UI_currency_gold_rune` — moneda individual con sello solar rúnico (`BikRQ`); PNG de alternativa en `Assets/Icons/UI/Currency/Alternatives/Icon_UI_currency_gold_rune.png` (256×256, RGBA transparente); opción compacta para precios, saldo y drops.
  - `Icon_UI_currency_gold_ingot` — lingotes apilados (`eMWzk`); alternativa ornamental o para botín.
- Nuevas variantes (`EST-39 — Variantes adicionales de oro`, `hVu6u`):
  - `Icon_UI_currency_gold_pouch` — bolsa con moneda visible (`LhU0X`); indicada para tiendas, ventas y recompensas.
  - `Icon_UI_currency_gold_nugget` — pepita con brillo (`hT89i`); indicada para botín, minería o materiales.
- El diamante `◈` queda como variante preferida para uso global porque coincide con el símbolo monetario ya usado en las UI. Las monedas apiladas, sello rúnico, lingote, bolsa y pepita quedan como alternativas visuales.


## ICONOS DE ESTADÍSTICAS · HU-ESTETICA-39

Iconos gráficos de trazo sólido, estilo del menú de talentos, sin marco ni fondo; PNG 256×256 con alfa transparente. Paleta dorado `#C89445` y pergamino `#F4EDE0`. Fuente: producción propia asistida por IA, limpiada y normalizada localmente; uso interno de Vandrheim. Los nombres canónicos sirven como `iconId`; `rbxassetid` queda pendiente de carga por el desarrollador.

| iconId | Tipo | Uso | Archivo local | Fuente / licencia | rbxassetid |
|---|---|---|---|---|---|
| `Icon_Stat_ATK` | Icono | Daño físico | `Assets/Icons/UI/Stats/Icon_Stat_ATK.png` | Producción propia asistida por IA; interno Vandrheim | Pendiente |
| `Icon_Stat_MATK` | Icono | Daño mágico | `Assets/Icons/UI/Stats/Icon_Stat_MATK.png` | Producción propia asistida por IA; interno Vandrheim | Pendiente |
| `Icon_Stat_DEF` | Icono | Defensa física | `Assets/Icons/UI/Stats/Icon_Stat_DEF.png` | Producción propia asistida por IA; interno Vandrheim | Pendiente |
| `Icon_Stat_MDEF` | Icono | Defensa mágica | `Assets/Icons/UI/Stats/Icon_Stat_MDEF.png` | Producción propia asistida por IA; interno Vandrheim | Pendiente |
| `Icon_Stat_MaxHP` | Icono | Vida máxima | `Assets/Icons/UI/Stats/Icon_Stat_MaxHP.png` | Producción propia asistida por IA; interno Vandrheim | Pendiente |
| `Icon_Stat_MaxMP` | Icono | Maná máximo | `Assets/Icons/UI/Stats/Icon_Stat_MaxMP.png` | Producción propia asistida por IA; interno Vandrheim | Pendiente |
| `Icon_Stat_CRIT` | Icono | Probabilidad de golpe crítico | `Assets/Icons/UI/Stats/Icon_Stat_CRIT.png` | Producción propia asistida por IA; interno Vandrheim | Pendiente |
| `Icon_Stat_GOLD` | Icono | Oro (opcional, no enlazado en UI) | `Assets/Icons/UI/Stats/Icon_Stat_GOLD.png` | Producción propia asistida por IA; interno Vandrheim | Pendiente |
| `Icon_Stat_XP` | Icono | Experiencia / nivel (opcional, no enlazado en UI) | `Assets/Icons/UI/Stats/Icon_Stat_XP.png` | Producción propia asistida por IA; interno Vandrheim | Pendiente |


## ICONOS DE TALENTOS · HU-ESTETICA-40

Iconos de talento con composición de habilidad activa: sellos rúnicos, impactos y energía pintada en la estética de las skills de Vandrheim. PNG 512×512 con alfa transparente, sin marco ni texto. Fuente: producción propia asistida por ImageGen; uso interno de Vandrheim. Los nombres canónicos sirven como `iconId`; `rbxassetid` queda pendiente de carga por el desarrollador.

| iconId | Tipo | Uso | Archivo local | Fuente / licencia | rbxassetid |
|---|---|---|---|---|---|
| `Icon_Talent_ATK` | Icono | Mejora de daño físico | `Assets/Icons/Talents/Icon_Talent_ATK.png` | ImageGen; interno Vandrheim | `rbxassetid://89068082294902` |
| `Icon_Talent_MATK` | Icono | Mejora de daño mágico | `Assets/Icons/Talents/Icon_Talent_MATK.png` | ImageGen; interno Vandrheim | `rbxassetid://139893316216189` |
| `Icon_Talent_DEF` | Icono | Mejora de defensa física | `Assets/Icons/Talents/Icon_Talent_DEF.png` | ImageGen; interno Vandrheim | `rbxassetid://140021244024450` |
| `Icon_Talent_MDEF` | Icono | Mejora de defensa mágica | `Assets/Icons/Talents/Icon_Talent_MDEF.png` | ImageGen; interno Vandrheim | `rbxassetid://114061430971883` |
| `Icon_Talent_MaxHP` | Icono | Mejora de vida máxima | `Assets/Icons/Talents/Icon_Talent_MaxHP.png` | ImageGen; interno Vandrheim | `rbxassetid://109280055205927` |
| `Icon_Talent_MaxMP` | Icono | Mejora de maná máximo | `Assets/Icons/Talents/Icon_Talent_MaxMP.png` | ImageGen; interno Vandrheim | `rbxassetid://133258370924897` |
| `Icon_Talent_CRIT` | Icono | Mejora de crítico | `Assets/Icons/Talents/Icon_Talent_CRIT.png` | ImageGen; interno Vandrheim | `rbxassetid://93440920540891` |
| `Icon_Talent_CDR` | Icono | Mejora de reducción de cooldown | `Assets/Icons/Talents/Icon_Talent_CDR.png` | ImageGen; interno Vandrheim | `rbxassetid://81743460448421` |
| `Icon_Talent_GOLD` | Icono | Mejora económica opcional (ningún nodo actual) | `Assets/Icons/Talents/Optional/Icon_Talent_GOLD.png` | ImageGen; interno Vandrheim | Pendiente |
| `Icon_Talent_XP` | Icono | Mejora de experiencia | — | — | — (no requerido: ningún talento actual mejora XP) |
| `Icon_Talent_MultiStat` | Icono | Mejora simultánea opcional de varias estadísticas | `Assets/Icons/Talents/Optional/Icon_Talent_MultiStat.png` | ImageGen; interno Vandrheim | Pendiente |

> **Nota:** los 8 iconos activos del diseñador están subidos (IDs de `Decavii`). CDR se incluye porque es stat del juego; los iconos GOLD y MultiStat aprobados quedan disponibles como opcionales aunque ningún nodo actual los usa. `Icon_Talent_XP` no se produjo.

## TEXTURAS BODY-SKIN · HU-ESTETICA-33

Mapas de camisa/pantalón clásicos R15 con alfa transparente, organizados por clase/tier. Se conservan las variantes aprobadas/versionadas. Notas de producción en `Assets/Source/Itemization/HU-ESTETICA-33/`.

| Clase / tier | Archivos canónicos |
|---|---|
| Paladín azul | `Assets/Clothing/EST-33/BodySkins/Paladin_Blue/paladin_blue_classic_{shirt,pants}_r15.png` y variantes `_v2.png` |
| Paladín Frost | `Assets/Clothing/EST-33/BodySkins/Paladin_Frost/paladin_frost_classic_{shirt,pants}_r15_v1.png` |
| Cazador azul | `Assets/Clothing/EST-33/BodySkins/Hunter_Blue/hunter_blue_classic_{shirt,pants}_r15_v1.png` |
| Cazador Frost | `Assets/Clothing/EST-33/BodySkins/Hunter_Frost/hunter_frost_classic_{shirt,pants}_r15_v1.png` |
| Clérigo azul | `Assets/Clothing/EST-33/BodySkins/Cleric_Blue/cleric_blue_classic_{shirt,pants}_r15_v1.png`, `_v2.png`, `_v2_body_skin_ready.png` |
| Clérigo Frost | `Assets/Clothing/EST-33/BodySkins/Cleric_Frost/cleric_frost_classic_{shirt,pants}_r15_v1.png` |

## RETRATOS DE JEFES Y ENEMIGOS · GUÍA DE DUNGEON

Retratos con fondo transparente para la pestaña de información de la dungeon (HU-R9a.2 / HU-ESTETICA-37): dos jefes, un enemigo genérico reutilizable y ocho retratos específicos de enemigos regulares. PNG RGBA 512×512; sin marco ni texto. Basados en las capturas de los modelos y producidos con ImageGen; uso interno de Vandrheim. Los retratos de jefe y genérico ya están subidos a Roblox; los nuevos retratos específicos están pendientes de carga. También se usan en el medallón del **TargetFrame** (EST-47): Jotunn para el boss final, FrostLord para el Señor de la Escarcha y los retratos específicos o genérico para el resto.

| assetId | Tipo | Uso | Archivo local | Fuente / licencia | rbxassetid |
|---|---|---|---|---|---|
| `Portrait_Boss_Jotunn` | Retrato | Jotunn, Guardián de la Escarcha — jefe final | `Assets/Images/Enemies/Portraits/Portrait_Boss_Jotunn.png` | ImageGen; interno Vandrheim | `rbxassetid://112251764292750` |
| `Portrait_Boss_FrostLord` | Retrato | Señor de la Escarcha — mini-jefe del piso 4 | `Assets/Images/Enemies/Portraits/Portrait_Boss_FrostLord.png` | ImageGen; interno Vandrheim | `rbxassetid://105086910359542` |
| `Portrait_Enemy_Generic` | Retrato | Enemigos regulares de la dungeon — retrato genérico | `Assets/Images/Enemies/Portraits/Portrait_Enemy_Generic.png` | ImageGen; interno Vandrheim | `rbxassetid://99954963258644` |
| `Portrait_Enemy_FrostArcher` | Retrato | Helada, arquera helada (`helada_frost_archer`) | `Assets/Images/Enemies/Portraits/Portrait_Enemy_FrostArcher.png` | ImageGen; interno Vandrheim | Pendiente |
| `Portrait_Enemy_FrostKnight` | Retrato | Helada, caballero helado (`helada_frost_knight`) | `Assets/Images/Enemies/Portraits/Portrait_Enemy_FrostKnight.png` | ImageGen; interno Vandrheim | Pendiente |
| `Portrait_Enemy_IceTroll` | Retrato | Helada, trol de escarcha (`helada_frost_troll`) | `Assets/Images/Enemies/Portraits/Portrait_Enemy_IceTroll.png` | ImageGen; interno Vandrheim | Pendiente |
| `Portrait_Enemy_BlizzardWraith` | Retrato | Helada, espectro de ventisca (`helada_blizzard_wraith`) | `Assets/Images/Enemies/Portraits/Portrait_Enemy_BlizzardWraith.png` | ImageGen; interno Vandrheim | Pendiente |
| `Portrait_Enemy_IceMite` | Retrato | Helada, ácaro de escarcha (`helada_ice_mite`) | `Assets/Images/Enemies/Portraits/Portrait_Enemy_IceMite.png` | ImageGen; interno Vandrheim | Pendiente |
| `Portrait_Enemy_IceGolem` | Retrato | Helada, gólem de hielo (`helada_ice_golem`) | `Assets/Images/Enemies/Portraits/Portrait_Enemy_IceGolem.png` | ImageGen; interno Vandrheim | Pendiente |
| `Portrait_Enemy_FrostWolf` | Retrato | Helada, lobo helado (`helada_frost_wolf`) | `Assets/Images/Enemies/Portraits/Portrait_Enemy_FrostWolf.png` | ImageGen; interno Vandrheim | Pendiente |
| `Portrait_Enemy_IceElemental` | Retrato | Helada, elemental de hielo (`helada_ice_elemental`) | `Assets/Images/Enemies/Portraits/Portrait_Enemy_IceElemental.png` | ImageGen; interno Vandrheim | Pendiente |

## ICONO OFICIAL DEL JUEGO · PROPUESTAS 2026-10-14

Tres candidatos aprobados de icono de experiencia basados en el logotipo, los personajes y el equipamiento de Vandrheim. PNG RGB 512×512 con fondo ilustrado en `Assets/Images/Marketing/ExperienceIcons/Candidates/`. Masters, comparación a 150×150, notas y prompts en `Assets/Source/Design/GameIcons-2026-10-14/`. Pendiente seleccionar el icono oficial y publicarlo.

| assetId | Tipo | Uso | Archivo local | Fuente / licencia | rbxassetid |
|---|---|---|---|---|---|
| `Icon_Game_01_Jotunn` | Icono de experiencia | Candidato 01: Jotunn protagonista | `Assets/Images/Marketing/ExperienceIcons/Candidates/Icon_Game_01_Jotunn_512.png` | ImageGen + referencias propias; interno Vandrheim | Pendiente |
| `Icon_Game_02_Desafio` | Icono de experiencia | Candidato 02: paladín frente a Jotunn | `Assets/Images/Marketing/ExperienceIcons/Candidates/Icon_Game_02_Desafio_512.png` | ImageGen + referencias propias; interno Vandrheim | Pendiente |
| `Icon_Game_03_Reliquia` | Icono de experiencia | Candidato 03: espadón único de escarcha | `Assets/Images/Marketing/ExperienceIcons/Candidates/Icon_Game_03_Reliquia_512.png` | ImageGen + referencias propias; interno Vandrheim | Pendiente |

## MINIATURAS DEL JUEGO · PROPUESTAS 2026-10-14

Arte promocional horizontal 16:9 basado en los assets propios. Dos candidatos aprobados en JPG y PNG 1920×1080, en `Assets/Images/Marketing/Thumbnails/Candidates/`. Masters, comparativas, notas y prompts en `Assets/Source/Design/GameThumbnails-2026-10-14/`. Pendientes de selección y publicación.

| assetId | Tipo | Uso | Archivo local | Fuente / licencia | rbxassetid |
|---|---|---|---|---|---|
| `Thumbnail_Game_01_Desafio_Jotunn` | Miniatura | Candidato: Paladín frente a Jotunn | `Assets/Images/Marketing/Thumbnails/Candidates/Thumbnail_Game_01_Desafio_Jotunn_1920x1080.jpg` | ImageGen + referencias propias; interno Vandrheim | Pendiente |
| `Thumbnail_Game_02_Reliquia_Helada` | Miniatura | Candidato: equipo único y exploración de Helada | `Assets/Images/Marketing/Thumbnails/Candidates/Thumbnail_Game_02_Reliquia_Helada_1920x1080.jpg` | ImageGen + referencias propias; interno Vandrheim | Pendiente |

## MICROMENÚ · DUNGEON, GUÍA, GRUPOS Y OBJETIVO · 2026-10-17

Cuatro iconos complementarios aprobados del micromenú, basados en los originales de grimorio, equipamiento y talentos. PNG 512×512 RGBA transparentes, sin texto ni marco en `Assets/Icons/UI/Menu/`. Masters, comparaciones, originales y revisiones a 24–32 px en `Assets/Source/Design/Micromenu-2026-10-17/`. Subidos a Roblox; IDs registrados abajo.

| assetId | Tipo | Uso | Archivo local | Fuente / licencia | rbxassetid |
|---|---|---|---|---|---|
| `Icon_Menu_dungeon` | Icono | Panel de dungeon | `Assets/Icons/UI/Menu/Icon_Menu_dungeon.png` | ImageGen + referencias propias; interno Vandrheim | `rbxassetid://83060256059692` |
| `Icon_Menu_dungeon_guide` | Icono | Guía de dungeon en pergamino | `Assets/Icons/UI/Menu/Icon_Menu_dungeon_guide.png` | ImageGen + referencias propias; interno Vandrheim | `rbxassetid://86986450600688` |
| `Icon_Menu_party` | Icono | Panel de equipos/grupos | `Assets/Icons/UI/Menu/Icon_Menu_party.png` | ImageGen + referencias propias; interno Vandrheim | `rbxassetid://123627897975211` |
| `Icon_Menu_target_cycle` | Icono | Alternar el objetivo entre enemigos | `Assets/Icons/UI/Menu/Icon_Menu_target_cycle.png` | ImageGen + referencias propias; interno Vandrheim | `rbxassetid://107774845279668` |

## COMPONENTES GENERALES DE UI · 2026-10-17

Iconos reutilizables aprobados para paneles y ventanas, con la familia visual del micromenú. PNG 512×512 RGBA transparente bajo `Assets/Icons/UI/{Common,Currency}/`. Revisiones a 16–48 px, masters y prompts en `Assets/Source/Design/UI-Components-2026-10-17/`.

| assetId | Tipo | Uso | Archivo local | Fuente / licencia | rbxassetid |
|---|---|---|---|---|---|
| `Icon_UI_close` | Icono | Cerrar paneles y ventanas | `Assets/Icons/UI/Common/Icon_UI_close.png` | ImageGen + referencias propias; interno Vandrheim | `rbxassetid://130341785019897` |
| `Icon_UI_currency_gold` | Icono | Moneda de oro global: HUD, precios, comercio, recompensas y contadores | `Assets/Icons/UI/Currency/Icon_UI_currency_gold.png` | ImageGen + referencias propias; interno Vandrheim | `rbxassetid://95443487243282` |

## ICONO DE TIENDA · 2026-10-22

Icono aprobado de un puesto de comerciante nórdico para identificar la tienda. PNG 512×512 RGBA transparente en `Assets/Icons/UI/Menu/`. Original, prompt y vistas previas archivados en `Assets/Source/Design/Micromenu-Shop-2026-10-22/`. La carga a Roblox queda pendiente.

| assetId | Tipo | Uso | Archivo local | Fuente / licencia | Estado / rbxassetid |
|---|---|---|---|---|---|
| `Icon_Menu_shop` | Icono | Entrada/panel de tienda | `Assets/Icons/UI/Menu/Icon_Menu_shop.png` | ImageGen + referencias propias; interno Vandrheim | Aprobado; carga pendiente |

## NAMEPLATES · REEMPLAZO TRANSPARENTE · 2026-10-22

Reemplazo aprobado del icono de nameplates con fondo RGBA transparente, conservando los detalles negros interiores. La versión anterior permanece archivada en `Assets/Source/Design/Micromenu-Nameplates-Transparent-2026-10-22/Masters/`. El ID de Roblox existente aún sirve la imagen previa y requiere actualizarse.

| assetId | Tipo | Uso | Archivo local | Fuente / licencia | Estado / rbxassetid |
|---|---|---|---|---|---|
| `Icon_Menu_nameplates` | Icono | Toggle de nameplates del micromenú | `Assets/Icons/UI/Menu/Icon_Menu_nameplates.png` | ImageGen + referencia propia; interno Vandrheim | Aprobado; re-subida pendiente (ID previo: `rbxassetid://121076782362772`) |
