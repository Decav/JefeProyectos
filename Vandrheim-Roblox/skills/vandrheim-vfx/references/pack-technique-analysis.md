# Análisis técnico del pack de referencia

Fuente: `ServerStorage.VFXReference`, medido el 2026-11-22 con lectura de solo propiedades en Edit. Es material de estudio: no se referencia desde producción. El objetivo es entender las técnicas para reproducirlas con arte y valores propios.

## 1. Inventario

- 2.069 objetos: 1.233 `ParticleEmitter`, 343 `Beam`, 23 `Trail`, 13 `PointLight`, 333 `Attachment`, 72 `Part`, 3 `MeshPart`, 3 `Sound`.
- 521 texturas distintas, 3 mallas y 2 sonidos (de dominio público). Un solo script: `HolyRingVFX_rc164_Approved`, que es nuestro, no del pack.
- Sin créditos, licencia ni autor en objetos o atributos. Ver `asset-registry.md` para el origen de las texturas.
- Mediana de 16 emisores por efecto (mínimo 3, máximo 356).

## 2. Cifras por propiedad (1.233 emisores)

| Propiedad | Valor medido | Lectura |
| :--- | :--- | :--- |
| `Lifetime` máximo | <0,3 s: 453; 0,3 a 0,8: 460; 0,8 a 2: 256; >2: 64 | 74 % dura menos de 0,8 s |
| Flipbook | 411 emisores: 4x4 (343), 8x8 (42), 2x2 (26) | 33 %; casi todo en modo `OneShot` (382) |
| `LightEmission` | 1: 414; medio: 115; <=0: 704 | mayoría oscura o sustractiva |
| `Brightness` | <=1: 357; 1 a 3: 97; 3 a 10: 429; >10: 350 | capas muy brillantes junto a capas planas |
| Color | un solo color: 1.165; gradiente: 68 | la textura trae la forma, el emisor el tinte |
| `Size` | 921 con 3 o más puntos | curvas de crecer y encoger, no tamaño fijo |
| `ZOffset` | 0: 659; 1 a 5: 236; negativo: 36; 0,001: 24 | orden de capas deliberado |
| `Drag` | >0 en 640 | frenado fuerte |
| `VelocityParallel` | 273 | líneas y chispas alargadas |
| `RotSpeed` | distinto de 0 en 400 | giro constante de sprites |
| `LockedToPart` | 387 | el efecto sigue a la parte |
| `Rate` = 0 (solo `Emit`) | 72 | el resto usa `Rate` con `EmitDuration` corto |
| `Shape` | Box 1.155, Disc 42, Sphere 19, Cylinder 17 | casi todo desde un punto; Disc para ondas al ras |
| `ShapeInOut` | Outward 1.209, Inward 19 | implosión puntual antes del estallido |
| `TimeScale` | 1: 1.063; 0,5 a 0,9: unos 90 | cámara lenta parcial en capas secundarias |

Atributos de control más usados: `EmitCount` (1.031 emisores), `EmitDelay` (793), `EmitDuration` (123), `Duration` y `Width0`/`Width1` en beams (154), `EmitType` (30), `GroundOnly` (13), `UseGroundColor` (9).

- `EmitDelay`: 0 en 513 emisores; 0,1 a 0,3 s en 113 (segunda oleada escalonada). Casi nada pasa de 0,3 s.
- `EmitDuration`: 0,1 s en 94 emisores. Se enciende con `Rate` alto durante 0,1 s: una ráfaga corta con velocidad.

## 3. Beams (343)

- 91 % con 20 o más segmentos, muchos con 100: curvas suaves.
- 82 % con `CurveSize` distinto de 0. Los pares de beams con curvas opuestas cruzan formando hélices.
- `TextureMode` `Stretch` (334). `TextureLength` 0 o 1.
- Los 343 tienen `TextureSpeed` positivo: la textura siempre se desplaza.
- 87 % con transparencia de entrada y salida (opaco en el centro).
- 82 % con ancho de 12 studs o más: son cintas grandes (cortes, remolinos, viento), no líneas finas.
- `Brightness` en general 5 o menos. `LightEmission` 1 en 142, <=0 en 135 (cintas oscuras de contraste).
- Los anchos se animan por script desde los atributos `Width0`, `Width1` y `Duration`.

## 4. Trails y luces

- 23 trails, 20 con `Lifetime` de 0,5 s.
- 13 `PointLight`: `Brightness` 1 a 50, `Range` 8 a 60, sombras desactivadas salvo una.

## 5. Anatomía de un efecto (ejemplo: `GroundSlamEffect`, 40 emisores)

Capas observadas, en orden aproximado de aparición, con lo que aporta cada una:

| Capa | Parámetros observados | Aporta |
| :--- | :--- | :--- |
| Destello (`Flash` x3) | 3 partículas, vida 0,02 a 0,08 s, tamaño 0 a pico a 0, `Brightness` 70, propagación 360 | golpe instantáneo |
| Impacto (`Impact`) | 1 partícula grande, vida 0,18 s, tamaño 15 a 37 | estallido principal |
| Núcleo animado (`Effect` x3) | flipbook 4x4 `OneShot`, vida 0,3 a 0,7 s, tamaño fijo grande, transparencia 1 a 0 a 1, `Brightness` 10, `ZOffset` alto | volumen y fuego |
| Onda (`Shock`, `ring half`) | vida 0,2 a 0,8 s, tamaño 0 a 54 (anillo), flipbook 4x4 | expansión |
| Humo oscuro (`Smoke`) | flipbook 8x8 `OneShot`, 20 partículas, vida 0,6 a 2,4 s, `LightEmission` -1, tamaño 1 a 18, `Drag` 6 | peso y contraste |
| Marca en suelo (`Ground`) | 1 partícula, vida 2,5 s, `LightEmission` -1,2, `Brightness` 0 | quemadura persistente |
| Líneas de velocidad (`Lines`) | 25 partículas, vida 0,03 a 0,11 s, velocidad 136 a 476, `Drag` 15, `VelocityParallel`, `Brightness` 25 | sensación de fuerza |
| Escombros (`Rocks`) | 10 partículas, vida 0,5 a 0,8 s, aceleración 171, rotación 700 | física creíble |
| Chispas y estrellas (`Stars`, `Star`) | velocidad hasta 260, `Drag` 11 a 22, forma Disc, `Brightness` 15 a 55 | cierre brillante |
| Brillo largo (`Glow`) | 1 partícula, vida 2 s, tamaño 30 | resplandor residual |
| Luz | `PointLight` | iluminación real |

Patrones de tamaño y transparencia:
- Destellos: transparencia 0 plana y tamaño 0 a pico a 0; la forma hace el desvanecimiento.
- Capas con textura: transparencia 1 a 0 a 1 (entra, brilla, sale).
- Humo: transparencia 0 a 0,75 a 1 mientras crece.

Otro ejemplo (`Explode`, 21 emisores): ráfagas de `Rate` 40 a 120 con vida 0,1 a 0,3 s, velocidades de 140 a 1.100 y `Drag` 6 a 10, de modo que todo frena justo al llegar al borde; capas de fuego negro (`LightEmission` 0, `Brightness` 0) bajo capas de fuego brillante.

## 6. Qué hace distinto a nuestro código actual

| Aspecto | Pack | Nuestros módulos (2026-11-22) |
| :--- | :--- | :--- |
| Flipbook | 33 % de emisores | Paladín 0, Cazador 20 menciones, runtime sin soporte |
| Capas oscuras | 57 % | pocas (humo `LightEmission = 0` en algunos casos) |
| `ZOffset` por capa | 46 % | no se usa |
| Emisión por atributos | sí, en 1.031 emisores | no hay plantillas; todo por parámetros en código |
| Beams | 20+ segmentos, curvos, textura en movimiento | `CurvedBeam` con curva; segmentos y textura según `opts` |
| Escala del efecto | 15 a 80 studs | 2 a 14 studs |
| Variedad de texturas | 496 distintas | unas 41 en `packTextures` |
| Duración típica | <0,8 s | mezclas de 0,4 a 8 s |

## 7. Qué no se copia

- Las texturas, mallas y sonidos del pack (arte de terceros).
- Los efectos cuyo nombre remite a obras o personas ajenas.
- La composición exacta de un efecto concreto: se aprende el método, se diseña la forma propia.
