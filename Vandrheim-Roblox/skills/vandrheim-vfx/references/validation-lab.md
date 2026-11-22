# Laboratorio de validación de VFX

Dos niveles: captura en Edit (rápido, sin Play, no toca perfiles) y comprobación en Play (confirmación final). Itera en Edit y confirma en Play.

## Regla de seguridad del laboratorio

- Solo propiedades y llamadas del módulo de VFX; nunca el DataModel completo.
- No hagas `GetDescendants()` de todo el juego ni leas el código de muchos scripts: un escaneo así provocó el cierre de Studio por falta de memoria (2026-11-19).
- Todo lo que se cree en Edit se destruye al terminar. Deja `Workspace.VFXClientRuntime` con 0 hijos y sin carpetas temporales.
- No guardes el place desde una sesión con objetos de laboratorio sin limpiar.

## Captura en Edit

Funciona con las herramientas `execute_luau` (`datamodel_type = "Edit"`) y `screen_capture` (parámetros `capture_id`, `camera_position` y `look_at_position`). Los efectos de cliente se instancian en `Workspace.VFXClientRuntime` y se ven en el viewport de Edit.

1. Elige un punto despejado con suelo (por ejemplo la plaza de Valgard, cerca de `Workspace.Hub.Village.CentralPlaza`) y una distancia de cámara de 20 a 30 studs.
2. Dispara el efecto con el módulo real:

```lua
local target = Vector3.new(16000, 82.3, 15975)
local P = require(game.ReplicatedStorage.Shared.PaladinSkillVFX)
P.Zone({ skillId = "paladin_prot_consecration", position = target, radius = 8, duration = 20, zoneId = "lab1" })
```

3. Para efectos cortos, repite el disparo en un bucle de `task.spawn` con `task.wait(0.7)` y una bandera de parada, o usa una duración larga si el efecto lo permite, y captura con `screen_capture` poniendo `camera_position` y `look_at_position`.
4. Captura en cada fase del cronograma (anticipación, impacto, 0,3 s, cola) cambiando el momento del disparo.
5. Compara con el efecto anterior (flag A/B apagado y encendido) y con el entorno claro (nieve) y oscuro (cueva).
6. Limpia: destruye los hijos de `Workspace.VFXClientRuntime`, para el bucle (`_G` de la bandera en `nil`) y restablece la cámara.

Limitaciones: Edit no reproduce el rendimiento ni la cámara del juego; algunas funciones exigen un `target` real (un `Model` con `HumanoidRootPart`); un efecto de 0,2 s puede quedar entre dos fotogramas de captura, así que dispara en bucle y repite la captura. Un efecto que devuelve `true` sin crear nada suele indicar un payload incompleto (posición, `target` o `radius`).

## Medición de presupuesto

Con el efecto activo, mide en Edit sin recorrer el juego:

```lua
local f = workspace:FindFirstChild("VFXClientRuntime")
local emitters, beams, lights = 0, 0, 0
for _, d in ipairs(f:GetDescendants()) do
	if d:IsA("ParticleEmitter") then emitters += 1
	elseif d:IsA("Beam") then beams += 1
	elseif d:IsA("PointLight") then lights += 1 end
end
```

Compara con los topes de nivel del efecto (`SKILL.md`) y con `VFXConfig.classVFX.desktop` y `.mobile`. `Runtime.Stats()` da el recuento acumulado del runtime.

## Comprobaciones obligatorias

1. **Compilación:** `loadstring(Source)` de `VFXConfig` y de cada módulo `*VFX` modificado; el módulo termina en su `return`.
2. **Texturas:** cada textura usada está en `asset-registry.md`; ninguna referencia directa a `ServerStorage.VFXReference`.
3. **Radio y presupuesto:** `payload.radius = 999` no supera `2 * SkillConfig.aoeRadius`; partículas, emisores y beams dentro de los topes de `desktop` y `mobile`.
4. **Entradas hostiles:** `nil`, `{}`, `NaN`, `math.huge`, radios negativos, `Impact` antes de `Cast` y casts duplicados con el mismo `zoneId`, sin errores.
5. **Ráfaga e interrupción:** 10 casts seguidos (activa `quality < 1`), `ClearAll()` a mitad de efecto y muerte real del personaje; al terminar `VFXClientRuntime` queda con 0 hijos y 0 conexiones activas.
6. **Duración:** salvo la marca y el brillo residual, todo termina antes de 1 s (nivel S y M).
7. **Legibilidad:** el efecto no tapa al personaje ni al enemigo, tiene silueta propia, contrasta sobre fondo claro y oscuro y distingue skills del jugador de avisos de enemigos.

## Comprobaciones en Play (PO)

- 0 errores y 0 advertencias nuevas desde el arranque completo.
- Capturas antes y después en PC (1920x1080 y 1366x768) y móvil (844x390).
- Fluidez con varios jugadores y varios casts a la vez (mide la caída de FPS en móvil).
- Aprobación del PO antes de retirar el flag A/B.
- Con `StudioPersistence = true`, Play usa datos reales: declara el perfil que se usa y revierte cualquier cambio.

## Registro de validación

Al terminar un efecto, anota en el RC: capturas por fase, recuentos de emisores, partículas y beams, resultados de las comprobaciones 1 a 7 y las texturas usadas (con su estado en el registro).
