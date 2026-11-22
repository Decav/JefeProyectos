# Guía de texturas propias

Objetivo: tener un conjunto de texturas propias, pequeño y reutilizable, que cubra los roles que usa el pack, para retirar las texturas de terceros del registro (`asset-registry.md`).

## Principios

- **Blancas o grises con alfa, teñidas por el emisor.** El pack usa un solo color en el 94 % de sus emisores. La forma va en la textura; el color lo pone `ParticleEmitter.Color`. Así una textura sirve a todas las clases.
- **Con `LightEmission` mayor a 0, los colores oscuros se vuelven transparentes** (documentación de `ParticleEmitter`). Para efectos aditivos puede bastar un fondo negro sin alfa; para humo y capas oscuras, usa alfa real.
- **Tamaño del flipbook:** el tamaño de la textura debe ser múltiplo exacto del layout (`Grid2x2`, `Grid4x4`, `Grid8x8` o `Custom` con `FlipbookSizeX/Y`). Con `OneShot` el fotograma se reparte a lo largo de la vida de la partícula (`FlipbookFramerate` no aplica).
- **Resolución:** confirma en la documentación vigente de carga de imágenes el tamaño máximo antes de producir. Si el máximo es 1024 x 1024, un flipbook 4x4 tiene fotogramas de 256 px y uno 8x8 de 128 px.
- **Nombres:** `VFX_<Rol>_<Variante>` (por ejemplo `VFX_Smoke_8x8_A`).
- **Privacidad:** por defecto las imágenes se crean como Open Use (cualquiera puede usarlas). Activa Asset Privacy y concede el acceso solo al juego si no queremos que otros las usen.

## Texturas que necesitamos (conjunto mínimo)

| Rol | Contenido | Formato | Se usa en |
| :--- | :--- | :--- | :--- |
| Punto suave (`Dot`) | degradado radial blanco | 256 a 512, alfa | brillo, motas, destello, luz |
| Anillo fino (`Ring`) | anillo con borde suave | 512, alfa | ondas de suelo |
| Onda ancha (`Shock`) | anillo difuso con grano | 512 a 1024, alfa | expansión desde el origen |
| Chispa alargada (`Spark`) | trazo con punta | 256 a 512, alfa | partículas `VelocityParallel` |
| Estrella de 4 puntas (`Star4`) | destello con rayos | 256 a 512, alfa | cierre estelar, impacto |
| Humo flipbook (`Smoke_8x8`) | 64 fotogramas de humo que se disipa | 8x8, alfa | capa oscura de base |
| Fuego flipbook (`Fire_4x4`) | 16 fotogramas de llama | 4x4, alfa | núcleo animado |
| Estallido flipbook (`Burst_4x4`) | 16 fotogramas de explosión | 4x4, alfa | impactos |
| Corte (`Slash`) | arco con degradado a punta | 512 a 1024, alfa | beams de slash |
| Viento (`WindStrip`) | tira con remolino, repetible en horizontal | 512 x 128 a 1024 x 256, alfa | beams de viento y aura |
| Grietas / marca (`Crack`) | grietas o quemadura | 512, alfa | marca en el suelo |
| Runa / sello (`Sigil_A..D`) | sellos geométricos de la clase | 512, alfa | zonas del Paladín y del Clérigo |
| Rayo (`Bolt`) | rayo con ramificación | 512, alfa | efectos eléctricos |
| Haz de luz (`LightRay`) | rayos radiales | 512, alfa | efectos sagrados |

Orientación: las partículas con `VelocityParallel` estiran la textura según su velocidad; verifica en el laboratorio cómo queda la textura (el trazo debe ir en el eje que el motor alinea con la velocidad) antes de producir todo el conjunto.

## Cómo producirlas

Opciones, de menor a mayor esfuerzo:
1. **Pintar o procesar a mano** en Krita, Photoshop o similar (puntos, anillos, chispas, estrellas, cortes, grietas).
2. **Procedural:** Blender u otra herramienta para humo, fuego y explosión: simular, renderizar fotogramas con fondo transparente y montarlos en la grilla.
3. **Encargo** a un artista con cesión de derechos por escrito para el juego.
4. **Generación por IA:** solo si las políticas de Roblox y de la herramienta lo permiten y el resultado se revisa para que no copie arte ajeno; documenta la herramienta en el registro.

Antes de subir una textura, registra en `asset-registry.md`: id, nombre, rol, autor o herramienta, fecha y dónde se usa.

## Reemplazo gradual

1. Prioriza los roles con más usos: punto suave, estrella, chispa, anillo, onda, humo.
2. Sustituye por rol en `VFXConfig.classVFX.packTextures` (mismo `key`, nuevo id propio) y marca el estado en el registro.
3. Valida cada reemplazo con una captura antes y después en el laboratorio.
4. Mantén el respaldo del motor mientras un rol no tenga textura propia.
