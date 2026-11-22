---
name: vandrheim-vfx
description: Diseña, implementa y valida VFX de habilidades para Vandrheim RPG en Roblox Studio aplicando las técnicas aprendidas del pack de referencia (capas por rol, flipbooks OneShot, emisión por atributos EmitCount/EmitDelay, haces curvos con textura en movimiento), con texturas registradas, presupuesto por dispositivo y un laboratorio de captura en Edit. Úsala al crear o rehacer efectos de skills, impactos, zonas, auras o proyectiles.
---

# Vandrheim VFX

Esta skill enseña a construir VFX propios con la calidad del pack de referencia (`ServerStorage.VFXReference`) sin copiar sus assets. Lo que se reutiliza es la técnica: cómo se descompone un efecto en capas, qué valores usa cada capa y cómo se dispara. Cubre presentación cliente (`ReplicatedStorage.Shared.*VFX`, `SkillVFXRuntime`, `ReplicatedStorage.Config.VFXConfig`) y su validación. No autoriza cambios de daño, radios de gameplay, cooldowns, remotes ni persistencia.

## Cómo usar esta skill

1. Lee este archivo completo.
2. Elige la receta del tipo de efecto en `references/emitter-recipes.md`.
3. Si vas a crear plantillas editables en Studio, sigue `references/template-system.md`.
4. Antes de usar una textura, revisa `references/asset-registry.md`; si necesitas una nueva, usa `references/texture-guide.md`.
5. Valida con `references/validation-lab.md` (captura en Edit) y luego en Play.
6. Para entender el porqué de cada valor, consulta `references/pack-technique-analysis.md`.

## Reglas de arquitectura y seguridad (obligatorias)

- **Solo cliente:** el servidor únicamente dispara el payload existente (`VFXService` -> `VFXClient`). Nunca calcules daño ni crees remotes nuevos desde una tarea visual.
- **Radio y alcance desde config:** deriva el radio visual de `SkillConfig.Get(skillId)` (`aoeRadius`, `range`). Acota cualquier valor extremo del payload.
- **Contenedor y limpieza:** todo vive en un folder temporal por cast en `Workspace.VFXClientRuntime` (usa `SkillVFXRuntime.New`). Cancela tweens, desconecta `RBXScriptConnection` y destruye el folder al cumplirse `lifetime`, en `ClearAll()`, al morir el personaje o al cambiar de zona.
- **Partes visuales inocuas:** toda `BasePart` de apoyo con `CanCollide = false`, `CanTouch = false`, `CanQuery = false`, `Massless = true`, `CastShadow = false`.
- **Cero APIs legadas:** prohibidos `wait()` y `while true do`. Usa `task.delay`, `TweenService` y `Heartbeat` con desconexión garantizada.
- **Sin referenciar `ServerStorage.VFXReference` desde código de producción:** el pack es solo material de estudio. Ningún `Texture`, `MeshId`, `SoundId` ni script del pack se referencia directamente; las texturas de producción salen únicamente de `VFXConfig.classVFX.packTextures` y deben estar en `references/asset-registry.md`.
- **Texturas y propiedad intelectual:**
  - Una textura nueva se registra en `asset-registry.md` (id, creador, rol, origen) antes de entrar a `VFXConfig`.
  - Se prefieren texturas propias. Las texturas de terceros del registro son transitorias y deben tener un reemplazo propio planificado.
  - No se usan efectos, nombres ni arte que remitan a obras o personas ajenas (por ejemplo los efectos `Sukuna`, `Dismantle VFX`, `KiExplosion` o `jacksepticeye` del pack).
  - Toda textura de producción debe tener un respaldo del motor (`rbxasset://textures/particles/sparkles_main.dds` o `fire_main.dds`) si el asset no carga.
- **Interruptor A/B:** al rehacer un VFX existente conserva `paladinV2Enabled`/`hunterV2Enabled` (o un flag equivalente) hasta que el PO valide en Play.

## Principios técnicos aprendidos del pack

Detalle y cifras en `references/pack-technique-analysis.md`. Resumen:

1. **Un efecto es una pila de capas con rol, no un emisor grande.** El pack usa una mediana de 16 emisores por efecto. Cada capa cumple un rol: destello, núcleo animado, onda, humo oscuro de base, líneas de velocidad, chispas, escombros, marca en el suelo y luz.
2. **Casi todo dura menos de un segundo.** El 74 % de los emisores tiene `Lifetime` máximo menor a 0,8 s. El destello dura 0,02 a 0,08 s.
3. **Flipbook `OneShot` para volumen barato.** El 33 % de los emisores usa texturas animadas (sobre todo 4x4 y 8x8) en modo `OneShot`: una partícula reproduce todo el humo o fuego a lo largo de su vida. Logra volumen con 1 a 20 partículas.
4. **Contraste de luminancia.** Mezcla capas aditivas muy brillantes (`LightEmission = 1`, `Brightness` 10 a 100) con capas oscuras (`LightEmission <= 0`) que dan peso y silueta. El 57 % de los emisores del pack es de fondo oscuro.
5. **Color por tinte.** El 94 % de los emisores tiene un solo color: la textura es blanca o gris con alfa y el emisor la tiñe. Así una textura sirve para varias clases y el efecto es recoloreable.
6. **Orden de dibujo explícito.** El 46 % usa `ZOffset` distinto de 0 para decidir qué capa queda encima (destello encima, humo debajo).
7. **Emisión por datos.** Cada emisor lleva atributos `EmitCount` y `EmitDelay` (y `EmitDuration` para ráfagas de 0,1 s). Un reproductor genérico recorre el efecto y llama `:Emit(EmitCount)` tras `EmitDelay`. El diseño vive en Studio y el código solo orquesta.
8. **Haces anchos, curvos y con textura en movimiento.** El 91 % de los beams usa 20 o más segmentos (muchos 100), el 82 % tiene curva, todos desplazan su textura y el 87 % entra y sale con transparencia. El ancho se anima por script.
9. **Velocidad alta con freno fuerte.** Las partículas rápidas (velocidades de 140 a 1100, `Drag` 6 a 22) llegan al borde y se detienen en seco; las orientadas a la velocidad (`VelocityParallel`) dan las líneas y chispas.
10. **Luz real corta.** `PointLight` sin sombras (`Brightness` 3 a 50, `Range` 8 a 60) que se apaga en menos de 0,5 s.

## Presupuestos y degradación

| Nivel | Uso | Emisores | Partículas por cast | Beams |
| :--- | :--- | :--- | :--- | :--- |
| S | ataque básico, impacto menor | hasta 8 | hasta 40 | 0 |
| M | habilidad normal (presupuesto actual) | hasta 25 desktop / 19 mobile | hasta 160 / 104 | hasta 11 / 8 |
| L | definitiva o proc raro (propuesta a validar en el laboratorio) | hasta 40 desktop / 26 mobile | a medir | hasta 14 / 10 |

- Los topes de nivel M son los de `VFXConfig.classVFX.desktop` y `.mobile`. El nivel L es una propuesta: no se adopta hasta medirla en el laboratorio en el dispositivo móvil objetivo.
- Con más de `reduceAfter` efectos activos aplica `quality = 0.5..0.6` sobre los conteos de `Emit`.
- Reserva presupuesto para el destello, el cierre y los impactos antes de asignar relleno.
- Prefiere pocos emisores con curvas ricas y flipbook antes que muchos emisores simples.
- Una sola capa grande y lenta no sustituye a varias capas cortas y escalonadas.

## Lo que falta en el runtime (deuda técnica conocida)

Verificado el 2026-11-22 en `SkillVFXRuntime`:

- `Runtime.BurstEx` no soporta flipbook (`FlipbookLayout`, `FlipbookMode`) ni `ZOffset` ni `TimeScale`. Los módulos de Paladín y Cazador no los usan.
- `Runtime.SpawnTemplate` existe pero busca plantillas fijas en `ReplicatedStorage.Assets.VFXTemplates.Paladin`, esa carpeta no existe y ningún módulo lo llama.
- Antes de rehacer una skill con la técnica de esta skill conviene extender `BurstEx` con esas opciones y generalizar `SpawnTemplate` por clase (ver `references/template-system.md`).

## Flujo de trabajo para un efecto nuevo

1. **Brief visual:** tipo de efecto, spec/clase, paleta (primario, secundario, núcleo, borde), forma (silueta propia, no solo otro color) y mecánica (instantánea, zona, DoT, proyectil).
2. **Receta:** elige la composición de capas de `emitter-recipes.md` y define el cronograma: anticipación, impacto, estela.
3. **Escala:** diseña al tamaño real del radio de gameplay (el pack está a 15 a 80 studs, nuestro juego a 3 a 14).
4. **Texturas:** solo del registro; para una nueva, especifícala con `texture-guide.md`.
5. **Implementación:** plantilla por atributos o `Runtime.BurstEx` según la receta.
6. **Laboratorio:** captura en Edit en cada fase del cronograma y compara con el efecto anterior.
7. **Presupuesto y robustez:** prueba radios extremos, ráfaga, `ClearAll()` y muerte del personaje.
8. **Play y PO:** captura en PC y móvil, 0 errores de consola, aprobación del PO antes de retirar el flag A/B.

## Anti-patrones

- Un único emisor grande con mucha tasa continua.
- Todo en `LightEmission = 1` y `Brightness` bajo: se ve plano y se pierde sobre suelos claros.
- Efectos de 2 s sin destello ni corte: se sienten lentos y tapan la pantalla.
- Reutilizar el mismo VFX cambiando solo el color entre skills.
- Anillos planos como única señal: añade altura (pilares, chispas ascendentes, humo) y un cierre.
- Texturas con color horneado: no se pueden recolorear por clase.
- Beams rectos de pocos segmentos: se ven rígidos.
- Copiar efectos del pack con su arte, su nombre o su composición exacta.
- Probar solo en Play: itera en el laboratorio de Edit y confirma en Play.

## Estado actual del proyecto (2026-11-22)

- Paladín (`PaladinSkillVFX`): rehecho (rc164 y rc165), sin flipbooks, composición por `BurstEx` y `CurvedBeam` con 69 usos de texturas del registro.
- Cazador (`HunterSkillVFX`): rehecho (rc167), usa flipbooks en 20 sitios.
- Clérigo (`ClericSkillVFX`): sin rehacer.
- Referencia aprobada: `ServerStorage.VFXReference.HolyRingVFX_rc164_Approved` y `ReplicatedStorage.Shared.HolyRingVFX` (Anillo sagrado).
