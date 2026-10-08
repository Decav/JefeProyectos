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

## ICONOS UI · PANEL DE MUERTE / EST-38

**Imágenes PNG generadas** (no glifos vectoriales de Pencil): mismo estilo que los iconos de ítems/skills — pintado digital de fantasía, paleta Vandrheim (latón `#C89445`, pergamino `#F4EDE0`, frío `#8FB7D6`, fondos oscuros), silueta legible a 24 px.
**Técnica:** 512×512, **fondo transparente** (estándar vigente), sin texto, objeto ~85% centrado, perspectiva 3/4 o frontal según el icono; se suben a Roblox como PNG y el dev configura los `rbxassetid` en el config del death panel (`ReviveConfig`/`DeathPanelConfig`: `deathRuneIconId`, `reviveGemIconId`, `reviveGemOffIconId`, `robuxIconId`).

- `Icon_UI_death_death` — runa de muerte (calavera/cráneo nórdico grabado), frío `#8FB7D6`.
- `Icon_UI_death_revive` — gema de resurrección (oro/latón con brillo interior), latón `#C89445`. **Variante apagada:** `Icon_UI_death_revive_off` (gema oscura/opaca `#52495D`) para el contador X/3.
- `Icon_UI_death_robux` — moneda Vanrhheim (oro) sobre anillo de hielo; el texto "R$ 50" NO va dentro del glifo (lo pinta la UI).

| Asset | Nodo Pencil / archivo | Roblox |
|---|---|---|
| Icon_UI_death_death | PNG generado (pendiente) | (pendiente) |
| Icon_UI_death_revive | PNG generado (pendiente) | (pendiente) |
| Icon_UI_death_revive_off | PNG generado (pendiente) | (pendiente) |
| Icon_UI_death_robux | PNG generado (pendiente) | (pendiente) |


## ICONOS UI · MATCHMAKING / EST-37

Pictogramas legibles a 24 px, **fondo transparente**, sin texto dentro del glifo. El estado cubierto usa el icono en color; la falta de rol usa su variante apagada. IDs actualizados con los recursos de Roblox proporcionados por el usuario:

- `Icon_UI_role_tank` / `Icon_UI_role_tank_uncovered` — escudo: rol Tank cubierto / pendiente.
- `Icon_UI_role_heal` / `Icon_UI_role_heal_uncovered` — cruz de vida: rol Heal cubierto / pendiente.
- `Icon_UI_role_dps` / `Icon_UI_role_dps_uncovered` — espadas cruzadas: rol DPS cubierto / pendiente.

Los iconos cubiertos se registran en `RoomConfig.RoleIcons`; sus variantes apagadas en `RoomConfig.RoleIconsUncovered`. El indicador de composición considera cubierto Tank con 1, Heal con 1 y DPS con 2 miembros.

| Asset | ID de recurso | Tipo | Modificado | Creador |
|---|---:|---|---:|---|
| Icon_UI_role_heal | `110947674181561` | Image | `1791412121274` | Decavii |
| Icon_UI_role_tank | `108924685421755` | Image | `1791412127510` | Decavii |
| Icon_UI_role_tank_uncovered | `104055532601732` | Image | `1791412121393` | Decavii |
| Icon_UI_role_dps_uncovered | `85742564014865` | Image | `1791412121367` | Decavii |
| Icon_UI_role_dps | `86280431749523` | Image | `1791412121429` | Decavii |
| Icon_UI_role_heal_uncovered | `120110117123296` | Image | `1791412121446` | Decavii |

La licencia no venía indicada en los metadatos recibidos. La disponibilidad/render de los assets en el cliente publicado queda pendiente de QA.

## ICONO UNIVERSAL DE ORO

- `Icon_UI_currency_gold` — diamante vectorial inspirado en el glifo `◈`, color Hearthbound Gold `#C89445`. Componente maestro reutilizable en `Vandrheim-design.pen` (`S9eT1`, frame `tDU80`). Dos diamantes concéntricos; sin fondo, para usar junto al valor numérico.
- `Icon_UI_currency_gold_coins_stack` — alternativa de monedas apiladas (`Lucide / coins`), componente (`SOi1o`, frame `xqC61`).
- Tamaños de referencia: 16 / 24 / 32 / 48 px; recomendado 24 px para HUD, inventario y listas, 32 px en botones o recompensas. Usar junto al valor numérico (`12,840`), sin escribir “oro” dentro del glifo.
- Pendiente de exportar/subir como asset Roblox durante la integración; mantener color y silueta consistentes en HUD, tienda, vendors, recompensas y loot.
- Variantes para comparar en `EST-39 — Variantes del icono de oro` (`rQjsU`):
  - `Icon_UI_currency_gold_rune` — moneda individual con sello rúnico (`BikRQ`); opción compacta para saldo y drops.
  - `Icon_UI_currency_gold_ingot` — lingotes apilados (`eMWzk`); alternativa ornamental o para botín.
- Nuevas variantes (`EST-39 — Variantes adicionales de oro`, `hVu6u`):
  - `Icon_UI_currency_gold_pouch` — bolsa con moneda visible (`LhU0X`); indicada para tiendas, ventas y recompensas.
  - `Icon_UI_currency_gold_nugget` — pepita con brillo (`hT89i`); indicada para botín, minería o materiales.
- El diamante `◈` queda como variante preferida para uso global porque coincide con el símbolo monetario ya usado en las UI. Las monedas apiladas, sello rúnico, lingote, bolsa y pepita quedan como alternativas visuales.
