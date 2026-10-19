# HU-ESTETICA-33 — muestra Paladín Frost

## Estado

Prototipo visual para revisión. No es integración de producción ni está aprobado todavía.

## Body skin R15

- `BodySkins/paladin_frost_classic_shirt_r15_v1.png` — torso y brazos.
- `BodySkins/paladin_frost_classic_pants_r15_v1.png` — piernas.
- Ambos mapas son PNG RGBA de 585×559; el alfa coincide píxel por píxel con la plantilla R15 de la muestra azul aprobada.
- Texturas subidas solo para vestir el rig de preview: camisa `rbxassetid://80022172644621`, pantalón `rbxassetid://107946512736930`.
- Apariencia: placas plata-azuladas, base azul noche, ribete dorado, gemas amatista y runas/cristales cian.

## Accesorios

- Preview en Studio: `Workspace.ModelTest.GFX.HU33_PaladinFrost_Prototype`.
- Modelos: `AccessoryModelPreviews.paladin_helmet_frost_preview` (`HatAttachment`) y `AccessoryModelPreviews.paladin_shoulders_frost_preview` (`BodyFrontAttachment`).
- Derivados de las variantes azules aprobadas para conservar proporciones, orientación y configuración de attachments; retexturizados para Frost, con detalles de hielo y amatista.
- Validación: `Handle`/attachments/welds presentes, escala y attachment CFrames iguales a la muestra azul, partes de preview ancladas y sin colisión, sin scripts.
- `PaladinFrost_EquippedPreview_R15` muestra el body skin y accesorios en el rig R15.

## Límites de la muestra

- Todo permanece bajo `Workspace.ModelTest` como preview. No se modificaron los modelos azules/blancos originales, `ReplicatedStorage`, `ItemConfig`, `ASSETS_LIST` ni `ASSETS_REGISTRY`.
- El outfit usa dos mapas clásicos completos, como la muestra azul aprobada; el dev debe limitar los segmentos con `bodySkinParts` por slot al integrarlo.
- Pendiente de aprobación visual y de extender el estándar a Hunter y Clérigo, según HU-ESTETICA-33.
