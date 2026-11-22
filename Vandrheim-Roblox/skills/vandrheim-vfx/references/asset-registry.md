# Registro de texturas de VFX

Fecha de la auditoría: 2026-11-22. Fuente de los datos: `VFXConfig.classVFX.packTextures` (Studio) y la API pública de detalles de assets de Roblox (nombre, creador, fecha de creación).

## Estado de licencia

- Las 41 texturas distintas de producción son **imágenes de terceros** (23 creadores distintos, uno de ellos un grupo). Ninguna es de Roblox ni nuestra, y ninguna figura como dominio público.
- Roblox crea las imágenes y decals como **Open Use** por defecto: "cualquier creador o juego puede usarlas" salvo que su dueño active Asset Privacy (documentación de privacidad de assets). Por eso cargan hoy en el juego.
- Eso es un permiso técnico de la plataforma. **No hay una licencia verificada** para uso comercial ni créditos en el pack. El dueño puede eliminar o moderar el asset y la textura dejaría de cargar.
- Política: estas texturas son **transitorias**. Cada una debe tener un reemplazo propio planificado (ver `texture-guide.md`) y un respaldo del motor mientras tanto.
- Este registro no es un dictamen legal.

## Texturas de producción

Columna Reemplazo: `pendiente` = aún sin textura propia. Cuando exista, anota el id propio y cambia el estado a `hecho`.

| Clave en `packTextures` | Asset id | Nombre original | Creador | Rol | Reemplazo |
| :--- | :--- | :--- | :--- | :--- | :--- |
| ring | 9572518235 | Anillo 1 (1) | niitroxen | anillo fino | pendiente |
| rotating, windSwirl | 9572238730 | Fuerte Impacto | niitroxen | giro / impacto | pendiente |
| wave | 9556807995 | Textura de olas 3 | niitroxen | onda | pendiente |
| shockwave | 9432628250 | Impacto 2 | InsertWasFound | onda ancha | pendiente |
| blast | 10176632695 | Shockwave7 | Yuruzuu | estallido / onda | pendiente |
| sigDot | 10477188774 | punto | kmfssfkm | punto suave | pendiente |
| beam | 14978453395 | thatsawesoem | kmfssfkm | beam | pendiente |
| star | 7216849703 | estrella_01 | imShuang01 | estrella | pendiente |
| electroArc | 7216848960 | star_07 | imShuang01 | arco / estrella | pendiente |
| electroBolt | 13571103636 | e | 000IPLLKO | rayo | pendiente |
| flame | 14524175849 | T_StarFlare004 | XYZ12YT212 | llama / destello | pendiente |
| sigFloor4 | 14968098582 | WindWelt1 | XYZ12YT212 | marca en suelo | pendiente |
| sigGlint | 14960943986 | estrella afilada | XYZ12YT212 | estrella afilada | pendiente |
| slash | 15124806555 | anime-crescent | XYZ12YT212 | corte | pendiente |
| slashAlt | 15153511168 | Brillo02 | XYZ12YT212 | brillo | pendiente |
| sigFloor1 | 15042153033 | snockwave_00000 | ILuvMrCool | marca en suelo | pendiente |
| sigFloor2 | 15253620649 | (sin nombre descriptivo) | ILuvMrCool | marca en suelo | pendiente |
| lightHalo | 15770268686 | Punto10 | fadewhizz | halo | pendiente |
| lightRay | 15823517398 | 6 (1) | fadewhizz | haz de luz | pendiente |
| meteorBeam | 14256113932 | beamv1 | ShafiDev | beam | pendiente |
| meteorBeamDark | 14256127524 | newbeamv2 | ShafiDev | beam oscuro | pendiente |
| meteorSwirl | 13395479051 | SpritesheetslashY (13) | ShafiDev | remolino (probable flipbook) | pendiente |
| acidCloud | 14431663347 | water splash vfx | Clazite_VFX | nube / salpicadura | pendiente |
| acidRing | 16718731802 | hd_shockwave | bryselee811 | anillo | pendiente |
| projBlackFire | 16651218693 | contraste de agua Toon | Abso_Delete | fuego oscuro | pendiente |
| projCircles | 11995386251 | brillo | Abso_Delete | círculos / brillo | pendiente |
| projShards | 15687178002 | Fragmento espinoso | Abso_Delete | fragmentos | pendiente |
| projSoftFire | 12062501141 | sprite4 | Abso_Delete | fuego suave | pendiente |
| projStarTip | 17257940812 | StarBlinky | Abso_Delete | punta estelar | pendiente |
| projStars | 16722791958 | star_something | Abso_Delete | estrellas | pendiente |
| projTrail | 16698745611 | Portal de rutas | Abso_Delete | estela | pendiente |
| projSpikeyFire | 13136714025 | Volteo de Llama Estilizado | PrimeVoxel | llama con puntas | pendiente |
| sigFlames | 11499447365 | flipbook1 | jxydnnnn_alt2 | llamas (flipbook) | pendiente |
| sigShard | 10111094276 | chispa | coolestfloppa | chispa | pendiente |
| smoke | 10034873151 | smoke1024 (1) | cathorolokochup | humo | pendiente |
| sparks | 15316530495 | Chispa gruesa | MuG3ED | chispas | pendiente |
| wind | 15602659755 | g | moy466 | viento | pendiente |
| windBeam | 79598379412341 | Textura | Felku (grupo) | beam de viento | pendiente |
| windCircle | 11037291253 | Círculo27 | StucksDucks | círculo | pendiente |
| windRing | 15889417470 | Remolino 4x4 | kur_Dev | remolino (flipbook 4x4) | pendiente |
| windSpin | 10856287046 | SpinSw1 | Sheikal | giro | pendiente |

Creadores con más texturas: Abso_Delete (7), XYZ12YT212 (5), ShafiDev (3), niitroxen (3). Son los candidatos a pedir permiso por escrito si se decide conservarlas.

## Otros assets del pack (no usados en producción)

- Mallas: 1886703108 (MysticProphecy), 7351745872 (norperz), 92189547 (Roblox).
- Sonidos: 3929458420 y 4299587602, de dominio público según la API (`Paladinzzz2`).
- Efectos del pack con nombres que remiten a propiedad intelectual ajena y que no deben usarse: `Sukuna`, `Dismantle VFX`, `KiExplosion`, `jacksepticeye`, `SUPER ANIME LIGHT GOLDEN BLAST`.

## Texturas del motor (respaldo)

- `rbxasset://textures/particles/sparkles_main.dds`
- `rbxasset://textures/particles/fire_main.dds`

## Texturas propias

Aún no hay. Al subir la primera, añade aquí una tabla con: id, nombre (`VFX_<Rol>_<Variante>`), rol, autor o herramienta, fecha, creador (nuestra cuenta o grupo) y clave de `packTextures` que sustituye.

## Cómo repetir la auditoría

1. Leer `VFXConfig.classVFX.packTextures` en Edit y extraer los ids.
2. Consultar `https://economy.roblox.com/v2/assets/<id>/details` para cada id (nombre, creador, fecha, `IsPublicDomain`).
3. Actualizar esta tabla y la fecha de la auditoría.
Evita escaneos del DataModel completo: la lectura de `packTextures` basta.
