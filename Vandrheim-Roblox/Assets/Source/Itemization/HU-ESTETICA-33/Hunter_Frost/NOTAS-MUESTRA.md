# Hunter Frost — muestra de equipo

## Body skins R15

- `BodySkins/hunter_frost_classic_shirt_r15_v1.png` — torso, brazos y guantes integrados en la ropa clásica.
- `BodySkins/hunter_frost_classic_pants_r15_v1.png` — pantalón y grebas integrados en la ropa clásica.

Ambas texturas conservan el lienzo de **585 × 559 px** y la máscara alfa exacta de sus plantillas R15 correspondientes. Las body skins fueron aprobadas visualmente. El diseño toma como guía los iconos Frost del cazador: tela azul noche, cuero oscuro, placas frías, runas cian y gemas moradas.

Vista aplicada en un rig de muestra R15, sin casco ni hombreras:
`Workspace.ModelTest.GFX.HU33_HunterFrost_Prototype.BodySkinPartPreviews.HunterFrost_BodySkin_R15_PREVIEW_v1`.

- ShirtTemplate: `rbxassetid://119465235235941`
- PantsTemplate: `rbxassetid://107983186653415`
- El rig usa la misma base R15 del Hunter Blue, solo como preview aislado en `ModelTest`; no modifica ni integra el set en producción.

## Casco y hombreras — muestra 3D

En Roblox Studio, abrir `Workspace.ModelTest.GFX.HU33_HunterFrost_Prototype.AccessoryModelPreviews.EquippedPreview.HunterFrost_EquippedPreview_R15_v1`.

- `hunter_helmet_frost_equipped_preview` y `hunter_shoulders_frost_equipped_preview` son Accessories de muestra sobre un rig R15.
- Se clonó únicamente la configuración de ajuste del Hunter Blue aprobado. Los `Size`, la pose local de las mallas y los `AttachmentPoint` coinciden; el original no se modificó.
- El acabado visual Frost se generó en las copias de prueba. En Studio pueden verse guías de attachments/constraints; no forman parte de la geometría del equipo.

## Estado

- Body skins: aprobadas visualmente.
- Casco y hombreras: muestra pendiente de aprobación.
- El set sigue aislado en `Workspace.ModelTest`; no se movió a `Equipment` ni se integró en el juego.
