# HU-ESTETICA-33 — muestra Paladín azul

## Estado

Muestra de dirección visual para revisión; no es integración ni entrega final de la HU.

## Iconos

PNG de 512×512 con canal alfa y fondo transparente. Los cinco archivos son nuevos y no sustituyen ningún icono existente:

- `Icons/Icon_Item_paladin_helmet_blue.png`
- `Icons/Icon_Item_paladin_shoulders_blue.png`
- `Icons/Icon_Item_paladin_chest_blue.png`
- `Icons/Icon_Item_paladin_gloves_blue.png`
- `Icons/Icon_Item_paladin_legs_blue.png`

Paleta de prueba: acero frío, azul cobalto y dorado sobrio; composición centrada y sin texto.

### Prompt set (built-in image_gen)

Cinco prompts independientes de icono de inventario `stylized-concept`: objeto único en vista 3/4, ~80% del lienzo, alfa transparente real, margen limpio, acabado painterly 3D coherente con los iconos Paladín existentes y sin texto/marco/halo. Sujetos: yelmo cerrado azul; par de hombreras separado del torso; torso R15 con diseño continuo de body skin y sin hombreras; par de guantes; piernas R15 como body skin.

## Previsualización en Studio

`Workspace.ModelTest.GFX.HU33_PaladinBlue_Prototype`

- `AccessoryModelPreviews`: copias de casco y hombreras del Paladín, conservan la geometría/attachment originales y están marcadas como previsualización.
- `BodySkinPartPreviews`: tres copias completas del rig R15; cada una enfatiza pecho, brazos/manos o piernas/pies en los segmentos corporales correspondientes. No se creó armadura superpuesta para esas zonas.
- Todo el contenido lleva `DesignPreviewOnly`; no se enlazó a `ItemConfig` ni al runtime.

## Pendiente para reskins fieles

El modelo Paladín referencia las texturas clásicas de camisa `4092533381` y pantalón `3952513909`, pero no hay PNG fuente local y Asset Delivery responde `Authentication required`. Para hacer un reskin real basado en la textura existente hace falta exportar/proporcionar esos dos PNG; sin ellos, un diseño desde cero sobre la plantilla UV R15 sería una interpretación, no un recolor/refit verificable.

## No realizado

- No se modificaron modelos originales, iconos existentes, configuraciones ni registro canónico.
- No se subieron los PNG locales ni se integraron assets.
- Los modelos generados automáticamente en una primera prueba de forma no se conservaron en el Workspace por no respetar bien la silueta solicitada.
- Esas pruebas 3D sí devolvieron recursos de malla/textura en Roblox: MeshGen `121118342254374` (casco) y `79243290631879` (hombreras); TextureGen casco `125838864346058` / `101905891783111`; hombreras `111991824012521` / `90885161928241` y `118033004159893` / `83386442860550` (malla/textura). No están referenciados por la muestra ni por `ItemConfig`; sus instancias de prueba se retiraron del Workspace. El MCP disponible no ofrece borrado de esos recursos publicados.
