# HU-ESTETICA-33 — muestra Hunter Blue

## Estado

- Body skin R15: aprobada visualmente por el usuario.
- Casco y hombreras: aprobados visualmente por el usuario; continúan como previews, no aprobados para integración.

## Body skin R15

- `BodySkins/hunter_blue_classic_shirt_r15_v1.png` — torso y brazos.
- `BodySkins/hunter_blue_classic_pants_r15_v1.png` — piernas.
- Ambos mapas son PNG RGBA de 585×559; la máscara alfa coincide píxel por píxel con las plantillas R15 existentes de Hunter.
- Texturas subidas para el rig de preview: camisa `rbxassetid://127500184998879`, pantalón `rbxassetid://90697441775271`.
- Apariencia basada en los iconos azules de Hunter: cuero marrón oscuro, tela cobalto, placas de acero azulado y ribetes/remaches dorados. Pecho, brazos y piernas están dibujados en los mapas clásicos, no como piezas superpuestas.

## Preview en Studio

- `Workspace.ModelTest.GFX.HU33_HunterBlue_Prototype.BodySkinPartPreviews.BodySkin_Hunter_Blue_PREVIEW_v1`
- Rig R15 de preview, sin scripts; separado de las muestras aprobadas de Paladín.
- Atributos `UserApprovedVisual=true`, `ApprovalScope=VisualReviewOnly`, `DesignPreviewOnly=true`, `ApprovedForIntegration=false`, `FinalCandidate=false`.

## Casco y hombreras — preview

- Modelos de referencia en `Workspace.ModelTest.GFX.HU33_HunterBlue_Prototype.AccessoryModelPreviews`: `hunter_helmet_blue_preview` y `hunter_shoulders_blue_preview`.
- Vista equipada en `Workspace.ModelTest.GFX.HU33_HunterBlue_Prototype.AccessoryModelPreviews.EquippedPreview.HunterBlue_EquippedPreview_R15`.
- Tamaños y attachments visuales basados en la configuración aprobada de Paladin Blue.
- El casco requiere una corrección visual de 180° en el weld interno para orientar la abertura hacia el frente del personaje; no se cambiaron los offsets de montaje ni `C1`.
- El usuario corrigió y aprobó la orientación de las dos hombreras en el modelo de referencia: ambas tienen yaw visual de 180°.
- La copia separada `EquippedPreview` es solo QA y conserva la rotación anterior de las hombreras; se dejó intacta para no sobrescribir la corrección del usuario.
- Casco: MeshId `rbxassetid://97625702006775`; TextureID `rbxassetid://98470434735607`.
- Hombrera derecha: MeshId `rbxassetid://76234379495737`; TextureID `rbxassetid://74119595879384`.
- Hombrera izquierda: MeshId `rbxassetid://125288884210629`; TextureID `rbxassetid://117109784594125`.
- Las fuentes generadas se conservan ocultas en `AccessoryModelPreviews.GeneratedMeshSources`.
- Los modelos de referencia llevan `UserApprovedVisual=true`, `ApprovalScope=VisualReviewOnly`, `DesignPreviewOnly=true`, `ApprovedForIntegration=false`, `FinalCandidate=false`.

## Límites

- No se modificaron iconos, assets originales de Hunter, modelos de Paladín, `ReplicatedStorage`, `ItemConfig`, `ASSETS_LIST` ni `ASSETS_REGISTRY`.
- Los cambios de casco y hombreras están limitados a copias de prueba dentro de `Workspace.ModelTest`; no se tocaron los modelos de producción.
