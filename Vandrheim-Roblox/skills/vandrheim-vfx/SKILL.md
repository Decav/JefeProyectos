---
name: vandrheim-vfx
description: Diseña, implementa y valida VFX de habilidades e impactos para Vandrheim RPG en Roblox Studio usando capas de partículas, beams curvos, curvas de tamaño/transparencia y presupuestos por dispositivo aprendidos de ServerStorage.VFXReference, sin copiar assets externos ni tocar lógica de servidor.
---

# Vandrheim VFX

Usa esta skill para crear o mejorar efectos visuales de habilidades, zonas AoE e impactos en Roblox Studio para Vandrheim RPG. Cubre presentación cliente (`ReplicatedStorage.Shared.*VFX`, `SkillVFXRuntime`, `ReplicatedStorage.Config.VFXConfig`) y validación en Play; no autoriza cambios de daño, radios de gameplay, cooldowns, remotes ni persistencia.

## Reglas de arquitectura y seguridad

- **Solo cliente:** todo VFX vive en presentación cliente. El servidor únicamente dispara el evento/payload existente (`VFXService` -> `VFXClient`). Nunca calcules daño ni crees remotes nuevos desde una tarea visual.
- **Radio derivado de config:** deriva el radio o alcance visual desde `SkillConfig.Get(skillId)` (`aoeRadius`, `range`). Ignora o acota cualquier valor extremo que llegue en el payload.
- **Contenedor y limpieza estricta:** instancia todo dentro de un folder temporal por cast en `Workspace.VFXClientRuntime` (o vía `SkillVFXRuntime.New`). Cancela tweens, desconecta `RBXScriptConnection` (como `Heartbeat` o `AncestryChanged`) y destruye el folder al cumplirse `lifetime`, en `ClearAll()`, al morir el personaje o al cambiar de zona.
- **Partes visuales inocuas:** toda `BasePart` creada para anclar emisores, beams o `SurfaceGui` debe tener `CanCollide = false`, `CanTouch = false`, `CanQuery = false`, `Massless = true` y `CastShadow = false`.
- **Cero APIs legadas:** prohibido usar `wait()` o bucles `while true do`. Usa `task.delay`, `Debris`, `TweenService` y `RunService.Heartbeat` con desconexión garantizada.
- **Sin assets del pack de referencia:** `ServerStorage.VFXReference` es únicamente referencia técnica. No referencies ningún `Texture`, `MeshId`, `SoundId`, `Tool` ni script del pack en código de producción salvo aprobación explícita del PO. Usa las texturas nativas del motor (`rbxasset://textures/particles/sparkles_main.dds`, `rbxasset://textures/particles/fire_main.dds`) o texturas propias aprobadas del proyecto.

## Receta técnica de capas (patrones de `VFXReference`)

Para evitar efectos planos, construye cada habilidad combinando estas capas en `VFXConfig` + el módulo `*VFX` correspondiente:

1. **Anticipación e implosión breve (`0.04 s`–`0.12 s`):**
   - Antes de la expansión principal, dispara un pre-destello corto con `PointLight` transitoria, esfera central que se contrae y un emisor con `Shape = Enum.ParticleEmitterShape.Sphere`, `ShapeInOut = Inward` y `ShapeStyle = Surface` para concentrar energía hacia el centro.
2. **Contraste cromático y de luminancia:**
   - No pongas todo en `LightEmission = 1` con tonos blancos saturados ni dejes `Brightness = 1..3`. En el pack de referencia, la presencia vibrante viene de combinar un respaldo oscuro o cálido (`LightEmission = 0` o `-1`) con núcleos y haces de `Brightness = 8..25` (`LightEmission = 1`) y `SurfaceGui.Brightness = 6..12`, para que la silueta brille y se lea sobre nieve, piedra o cielo sin verse plana.
3. **Onda expansiva y anillo al ras del suelo:**
   - Usa expansión cóncava rápida (`0 -> diámetro objetivo`) con `TweenInfo` `Quart`/`Quad` `Out`, acompañada de una segunda onda eco retrasada (`0.06 s`–`0.12 s`) y un emisor radial en disco (`Shape = Disc`, `Outward`) con `Drag` alto (`6`–`10`) para que frene en seco al llegar al borde del `aoeRadius`.
   - Para anillos rúnicos o de suelo, rota un `SurfaceGui` plano elevado unos `0.04`–`0.10` studs sobre el piso y suma rayos rasantes cortos acotados dentro del radio real (`rayReachRatio <= 0.96`).
4. **Beams curvos superpuestos:**
   - Los pilares planos se ven rígidos. Usa pares de `Beam` verticales con `CurveSize0`/`CurveSize1` opuestos, `FaceCamera = true`, `LightEmission = 1` y `Brightness` alto (`2.8`–`3.6`): un beam ancho con textura scrolling (`fire_main.dds`) para el aura y un beam delgado limpio para el núcleo, cerrando ancho y transparencia con `Quad.In`.
5. **Partículas orientadas a la velocidad (`VelocityParallel` + `Squash`):**
   - Para agujas de impacto, viento o chispas ascendentes, usa `Orientation = Enum.ParticleEmitterOrientation.VelocityParallel`, `Squash` no nulo en `NumberSequence` y `Drag` (`4`–`15`) con `Emit(N)` en lugar de `Rate` continuo.
6. **Impacto por enemigo ajustado al bounding box:**
   - Limita el número de impactos por cast (`maxImpacts`) y escala el emisor al `GetBoundingBox()` del objetivo. Combina fuego/chispas breves con una cruz estelar de 2 planos rotados (`EnemyImpactStar`) para dar lectura inmediata de golpe.
7. **Cierre estelar y cola corta:**
   - Alrededor del `60 %`–`75 %` del `lifetime`, dispara un destello breve de cierre (cruz estelar + burst corto + `PointLight` breve) y apaga el resto con suavidad antes de destruir el contenedor.

## Presupuestos y degradación por perfil

Configura los topes en `VFXConfig` diferenciando `desktop` y `mobile` (`UserInputService.TouchEnabled`):

| Parámetro | Referencia Desktop | Referencia Mobile |
| :--- | :--- | :--- |
| `maxParticles` por cast | `160` | `104` |
| `maxEmitters` por cast | `25` | `19` |
| `maxBeams` por cast | `11` | `8` |
| `maxImpacts` por cast | `8` | `6` |
| `reduceAfter` (casts simultáneos) | `4` | `2` |

- Reserva primero el presupuesto de partículas/emisores necesario para el cierre y los impactos antes de asignar partículas de relleno.
- Cuando haya más de `reduceAfter` efectos activos en pantalla, aplica un factor de reducción (`quality = 0.5..0.6`) sobre `Emit(count)` y columnas periféricas.
- Prefiere pocos emisores con curvas ricas (`NumberSequence`, `ColorSequence`, `Squash`, `RotSpeed`) antes que multiplicar emisores pequeños.
- Cuando rehagas un VFX existente, conserva un interruptor A/B en `VFXConfig` (por ejemplo `poc.enabled`) hasta que el PO valide el reemplazo en Play.

## Validación obligatoria antes de entregar

Ejecuta y verifica en Roblox Studio:

1. **Integridad estática:** `loadstring(src)` compila en `VFXConfig` y en el módulo `*VFX`; el módulo termina en su `return`; cero referencias a `AssetId` externos de `ServerStorage.VFXReference`.
2. **Radio y presupuesto:** probar en Play con `payload.radius = 999` y confirmar que el diámetro visual no supera `2 * SkillConfig.aoeRadius` y que `particles`, `emitters` y `beams` no superan los topes de `desktop` y `mobile`.
3. **Entradas hostiles y orden invertido:** probar `nil`, `{}`, `NaN`, `math.huge`, radios negativos, `Impact` antes de `Cast` y casts duplicados con el mismo `zoneId` sin errores.
4. **Ráfaga e interrupción:** disparar 10 casts seguidos verificando activación de `quality < 1`, probar `ClearAll()` a mitad del efecto y muerte real del personaje (`Humanoid.Health = 0`). Al terminar el `lifetime`, `Workspace.VFXClientRuntime` debe quedar con `0` hijos y `0` conexiones activas.
5. **Consola y capturas:** `0` errores y `0` advertencias nuevas desde el arranque completo en Play; adjuntar capturas antes/después en PC y validar en resolución móvil (`844x390`) cuando aplique.
