# Sistema de plantillas editables

Objetivo: diseñar los efectos en Studio (emisores, haces, luces y sus valores) y que el código solo los coloque, los escale y los dispare. Es la forma en que el pack consigue más calidad por línea de código, y la que usan los emisores con atributos `EmitCount` y `EmitDelay`.

## Estado actual (verificado el 2026-11-22)

- `Runtime.SpawnTemplate(record, templateName, targetCFrame, opts)` existe en `ReplicatedStorage.Shared.SkillVFXRuntime`.
- Busca la plantilla en `ReplicatedStorage.Assets.VFXTemplates.Paladin.<templateName>` (carpeta fija de Paladín).
- Esa carpeta no existe hoy en Studio y ningún módulo llama a `SpawnTemplate`.
- Lo que ya hace: clona, escala por `BaseRadius`, fuerza `Enabled = false` y `Rate = 0`, ejecuta `:Emit(EmitCount)` tras `EmitDelay`, reduce la cantidad con `quality` y en móvil (x0,65), desvanece los beams y apaga las luces.

## Convención de una plantilla

Ruta: `ReplicatedStorage.Assets.VFXTemplates.<Clase>.<NombreEfecto>` (Model o Part anclada con `Attachment` hijos).

Atributos en la raíz:
- `BaseRadius` (número): radio de gameplay en studs para el que se diseñó (la escala usa `targetRadius / BaseRadius`).
- `Tier` (`"S"`, `"M"` o `"L"`): nivel de presupuesto.
- `Duration` (número): vida total del efecto en segundos.

Atributos en cada `ParticleEmitter`:
- `EmitCount` (número): cuántas partículas se emiten.
- `EmitDelay` (número, segundos): espera antes de emitir; 0 por defecto, 0,1 a 0,3 para la segunda oleada.
- `EmitDuration` (número, segundos, opcional): para ráfagas con `Rate` durante ese tiempo (0,1 s típico) en lugar de `Emit`.

Atributos en cada `Beam`:
- `Width0`, `Width1` y `Duration` para animar el ancho (de 0 al valor y de vuelta, o del valor a 0).

Propiedades del emisor en la plantilla: `Enabled = false`, `Rate = 0` (salvo `EmitDuration`), `LockedToPart` según si debe seguir al objetivo, `ZOffset` para ordenar las capas y todo lo demás (flipbook, `Brightness`, `Drag`, curvas) ya ajustado. Como la plantilla conserva sus propiedades, el flipbook y el `ZOffset` funcionan sin tocar el runtime.

Nombres de capa recomendados (rol): `Flash`, `Core`, `Shock`, `Smoke`, `Lines`, `Sparks`, `Debris`, `Mark`, `Glow`, `Light`.

## Escala

- Diseña la plantilla ya cerca del tamaño final y fija `BaseRadius` al radio de la skill. El pack original está a 15 a 80 studs; nuestras skills van de 3 a 14.
- `SpawnTemplate` limita la escala a 0,25 a 3,5: una plantilla de 40 studs no puede bajar a 8. Por eso conviene diseñar a la escala objetivo.
- Hoy escala `Size` y `Speed` de las partículas pero no `Acceleration`: al escalar, la gravedad queda desproporcionada. Al generalizar, escala también `Acceleration`.
- No escala `Lifetime` ni `Drag`; es correcto, pero verifica el resultado en captura.

## Mejoras pendientes en el runtime (a hacer antes de migrar)

1. Parametrizar la carpeta por clase: reemplazar la búsqueda fija de `Paladin` por `Assets.VFXTemplates[className]`.
2. Soportar `EmitDuration`.
3. Animar los beams con `Width0`, `Width1` y `Duration` en lugar del desvanecimiento genérico.
4. Escalar `Acceleration`.
5. Añadir flipbook, `ZOffset` y `TimeScale` a `Runtime.BurstEx` para los efectos que se sigan construyendo por código.
6. Registrar cada plantilla en `Config.VFXConfig.skillEffects[<skillId>].template` con su nivel de presupuesto.

## Flujo para crear una plantilla

1. Diseña las capas en el espacio de edición (un `Part` con `Attachment` por rol), usando solo texturas del registro.
2. Ajusta valores con las recetas de `emitter-recipes.md`.
3. Previsualiza con `validation-lab.md`: llama a `SpawnTemplate` en Edit y captura en cada fase.
4. Añade los atributos, deja `Enabled = false` y `Rate = 0`, y fija `BaseRadius`, `Tier` y `Duration`.
5. Verifica el presupuesto con `Runtime.Stats()` y las mediciones de partículas, emisores y beams.
6. Mueve la plantilla a `ReplicatedStorage.Assets.VFXTemplates.<Clase>` y conecta el módulo de clase.
