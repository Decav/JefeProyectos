# Registro de lección para roblox-r15-body-skins

Agregar una regla de revisión de UV antes de producir la próxima skin: en las máscaras R15 del proyecto, la cuarta cara de cada brazo/pierna está separada de las tres caras contiguas. No inferir su posición con `x + col*64`: validar cada isla contra la máscara (en esta plantilla, cuarta cara derecha en x=215 y cuarta cara izquierda en x=503). Extender la pintura/degradado hasta el último píxel cubierto por los bordes antialias de la máscara, dejando que la máscara recorte el excedente.

**Resultado de validación:** condición cumplida. Se aplicaron camisa y pantalón v3 a un rig R15 limpio en `Workspace.ModelTest.VandrheimTravelerStarter_v3.Vandrheim_Traveler_Starter_R15_v3_PREVIEW`. Se revisaron frente, espalda y costado en Studio; las prendas cargan, la cobertura de torso, brazos y piernas se mantiene alineada y no se observan franjas descubiertas ni costuras defectuosas a escala de avatar. El tono negro inicial del rig vacío se cambió a un tono de piel neutro para revisar la prenda.

**Preview usado:** Shirt `rbxassetid://129609031177806`; Pants `rbxassetid://124517385758133`. Los PNG fuente siguen en esta carpeta temporal; el rig vive en una carpeta de preview aislada y no se integró al juego.

**Estado de la skill:** incorporada en `C:\Users\Diego\.codex\skills\roblox-r15-body-skins\SKILL.md`, dentro de “Construct the texture maps”. La nota conserva el detalle del caso que motivó la regla.

Archivos candidatos asociados: esta carpeta `Assets/Temp/BodySkins/Vandrheim_Traveler_Starter_v3/`.
