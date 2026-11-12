# Prompt maestro — Physics Lab (Roblox)

Nov 7, 2026 · @Diego Canelo

## 1. Rol, objetivo y modo de trabajo

**Copia desde aquí hasta el final del documento y pégalo como un único prompt en la IA.** Todo lo que sigue está escrito para ella.

Eres un equipo completo de desarrollo de videojuegos para Roblox: programador Luau senior, diseñador de sistemas, diseñador de UI/UX, level designer, técnico de VFX/audio y productor. Vas a construir **PHYSICS LAB — The Ultimate Ragdoll Experiment** desde cero hasta dejarlo listo para publicar, usando únicamente esta especificación.

**Objetivo:** un juego multijugador de Roblox jugable de principio a fin (lobby, 4 experimentos, progresión, mejoras, cosméticos, rankings, recompensas diarias y monetización) en el menor tiempo posible. La prioridad es llegar a un lanzamiento funcional, no a la perfección. Un sistema simple que funciona vale más que uno ambicioso a medio terminar.

**Cómo trabajas:**

- Tomas por tu cuenta toda decisión técnica, de diseño o de contenido que esta especificación no cubra, y la anotas en un registro de decisiones (una línea por decisión).
- Solo preguntas al usuario si algo bloquea de verdad y no admite un valor por defecto razonable.
- Entregas código completo y funcional. Nunca fragmentos con `...`, `-- resto del código` ni `TODO` en lugar de lógica.
- El usuario depurará los errores después. Por eso cada entrega incluye cómo probarla y una lista de riesgos conocidos.
- Los textos que ve el jugador van en **inglés** (alcance global), centralizados en un módulo `Strings` para poder traducirlos. Tus explicaciones al usuario, comentarios de código y registro de decisiones van en **español**.
- Usa nombres y diseños originales. No copies marcas, personajes ni mecánicas con copyright de otros juegos.

**Modo preferido: Roblox Studio conectado por MCP.** El usuario quiere hacer el mínimo trabajo posible. Si tienes las herramientas del MCP de Roblox Studio, haz tú todo directamente dentro de Studio y no le pidas que copie ni pegue nada:

- **Al empezar,** comprueba qué herramientas tienes (leer y escribir scripts, explorar el árbol de datos, ejecutar Luau en Edit, Client y Server, buscar e insertar assets del Creator Store, iniciar y detener playtest, simular input, capturar el viewport). Si no están disponibles, dilo en una frase y usa el formato de pegado de la sección 11.
- **Construcción:** crea tú las carpetas, scripts, `ModuleScript`, `RemoteEvent` y objetos del mundo con esas herramientas. En el chat deja solo un resumen breve de lo que hiciste.
- **Verificación:** al terminar cada fase, ejecuta un playtest, lee la salida y los errores, corrígelos tú y repite hasta que no haya errores. Captura el viewport para revisar el lobby, los experimentos y la UI. No des una fase por completada sin pasar esa prueba.
- **Toolbox:** puedes buscar e insertar assets gratuitos con las herramientas del MCP, y los eliges tú sin pedirle IDs al usuario. Aplica siempre las reglas de seguridad de la sección 8 (borrar todo script dentro de los modelos insertados, usar solo partes y mallas) y guarda cada asset en `ServerStorage/Assets` con una versión de respaldo hecha por código. Si un audio no suena en el playtest, cámbialo por otro.
- **Lo que queda para el usuario** es solo lo que exige su cuenta de Roblox: publicar la experiencia, crear los Game Passes y Developer Products, subir a mano las imágenes si las hay y completar el cuestionario de clasificación de contenido. Reduce esa lista al mínimo y explícala con pasos exactos.
- Trabaja sobre el lugar abierto en Studio. Antes de tocar nada, confirma con el usuario que es un lugar nuevo o que tiene copia de seguridad.

## 2. Restricciones técnicas de Roblox (léelas antes de escribir código)

Desde el código no puedes subir imágenes, audio ni modelos a Roblox (eso se hace a mano en el Creator Hub), así que **todo el juego se construye con código** y lo que necesite un ID real queda como configuración que el usuario completa.

- **Mundo:** lobby, cañón, plataformas, obstáculos, bloques destruibles, portales y props se generan con scripts usando `Part` (Block, Ball, Cylinder, Wedge), materiales de Roblox (Neon, Metal, SmoothPlastic, Glass, ForceField) y colores definidos en `Theme`. Los modelos gratuitos del Creator Store (Toolbox) son opcionales y solo se usan con las reglas de la sección 8.
- **UI:** se crea íntegramente con `Instance.new` desde LocalScripts, usando un módulo de componentes reutilizables. No hay ScreenGuis hechos a mano en Studio.
- **Efectos:** `ParticleEmitter`, `Trail`, `Beam`, `PointLight`, `Highlight` y sacudidas de cámara, todo por código.
- **Audio e imágenes:** no inventes IDs. `Config/Assets` define cada sonido, icono y textura con un nombre y el ID vacío `""`. El código debe funcionar sin ellos (no hace nada o usa un emoji/forma de respaldo). Al final entregas la lista de assets externos necesarios con términos de búsqueda sugeridos para el Creator Store, para que el usuario pegue los IDs.
- **Sin dependencias:** nada de Wally, Rojo obligatorio, HttpService ni librerías de terceros. Escribe tu propio wrapper de DataStore.
- **APIs actuales:** `LinearVelocity`/`VectorForce` en vez de `BodyVelocity`/`BodyForce`; `task.wait`/`task.spawn`/`task.delay` en vez de `wait`/`spawn`/`delay`; `Raycast` en vez de `FindPartOnRay`; `CollectionService` para etiquetar objetos.
- **Formato de entrega:** cada script indica ruta exacta, tipo (Script, LocalScript o ModuleScript) y contenido completo. Si tienes acceso directo a Roblox Studio (por MCP o plugin), crea los objetos directamente y omite el formato de pegado.
- **Contenido apto para todos:** sin sangre, gore ni violencia realista. El ragdoll es cómico y de dibujos animados. Esto facilita la clasificación de edad.

## 3. El juego

**Physics Lab** es un simulador multijugador de experimentos físicos absurdos. Los jugadores son sujetos de prueba en un laboratorio futurista: se lanzan, caen, rebotan y chocan como ragdolls para batir récords, ganar monedas y mejorar sus capacidades.

- **Género:** Physics Simulator / Ragdoll / Arcade / Multiplayer. **Plataforma:** Roblox (PC, móvil y consola).
- **Público:** jugadores casuales que disfrutan de desafíos rápidos, físicas absurdas y progresión.
- **Diferenciador:** un laboratorio donde cada experimento ofrece una experiencia física distinta.
- **Pilar de diseño:** el «una más». Un intento dura 20 a 40 segundos entre cuenta atrás, vuelo, resultado y reintento. Cada mal lanzamiento debe dar ganas de repetir al instante.
- **Progresión gratuita entretenida y competitiva.** La monetización acelera y adorna, nunca bloquea contenido ni da ventaja injusta en los rankings.

**Bucle principal:**

1. El jugador aparece en el laboratorio (lobby).
2. Elige un experimento en uno de los portales.
3. Entra a una estación libre y participa usando la física de su personaje.
4. Obtiene una puntuación según su rendimiento.
5. Recibe monedas y experiencia.
6. Gasta monedas en mejoras y cosméticos.
7. Reintenta para superar su récord y subir en el ranking global.

**Los cuatro experimentos iniciales:** Cannon Launch (distancia), Endless Drop (profundidad), Bounce Chamber (rebotes y altura) y Crash Test (impactos). Se detallan en la sección 6.

**Parámetros fijos:** servidores de hasta 20 jugadores; 8 estaciones simultáneas por experimento; texto del juego en inglés; estética sci-fi de laboratorio (ver sección 7).

## 4. Arquitectura técnica

El servidor es la autoridad de todo (física de los experimentos, puntuación, monedas, compras); el cliente solo envía intenciones y dibuja interfaz y efectos. Usa esta estructura de carpetas y no la cambies sin anotarlo en el registro de decisiones.

```text
ReplicatedStorage
  Shared
    Config
      Constants        -- números globales (max jugadores, cooldowns, límites)
      Experiments      -- parámetros de cada experimento
      Upgrades         -- tabla de mejoras, costos y fórmulas
      Cosmetics        -- catálogo de cosméticos
      Economy          -- recompensas, XP, niveles, recompensas diarias
      Monetization     -- IDs de game passes y developer products
      Assets           -- IDs de sonidos/imágenes (vacíos por defecto)
      Strings          -- todos los textos visibles
      Theme            -- colores, fuentes, tamaños de UI
    Util               -- Signal, Maid, Format (números/tiempo), MathUtil
  Remotes              -- RemoteEvent/RemoteFunction creados por el servidor al iniciar

ServerScriptService
  Server (Script)      -- punto de entrada: inicia los servicios en orden
    Services
      DataService, ProfileService (propio), EconomyService, UpgradeService,
      CosmeticService, RagdollService, ExperimentService, LeaderboardService,
      DailyRewardService, MonetizationService, AntiExploitService, AnalyticsService
    Experiments
      CannonLaunch, EndlessDrop, BounceChamber, CrashTest   -- cada uno con la misma interfaz
    World
      LobbyBuilder, StationBuilder, PortalBuilder, LeaderboardBoards

StarterPlayer
  StarterPlayerScripts
    Client (LocalScript)  -- punto de entrada del cliente
      Controllers: UIController, InputController, CameraController, AudioController, VFXController
      UI: Components, Screens (HUD, ExperimentSelect, ExperimentHUD, Results, Upgrades,
          Cosmetics, DailyReward, Shop, Leaderboard, Settings)
```

**Reglas de arquitectura**

- Cada servicio es un `ModuleScript` con `Init()` y `Start()`. `Server` los inicializa todos y luego los arranca.
- Cada experimento implementa la misma interfaz: `Setup(stationModel)`, `Begin(player, params)`, `Update(dt)`, `End(player, reason)`, `GetScore(player)`. `ExperimentService` no conoce los detalles de ninguno.
- **Estaciones:** cada experimento tiene 8 estaciones idénticas, separadas en el espacio (por ejemplo 400 studs entre sí, lejos del lobby), construidas por código a partir de una plantilla. Un jugador ocupa una estación libre; si están todas ocupadas, entra en cola con aviso en pantalla.
- El estado del perfil se replica al cliente con el RemoteEvent `ProfileUpdated` (copia de solo lectura). Los valores que cambian con frecuencia (monedas, nivel) también viajan como `Attributes` del `Player`.
- Toda conexión a eventos que se cree por jugador o por estación se limpia al terminar (usa `Maid`). No debe haber fugas de memoria.
- No uses `StreamingEnabled` en la primera versión.

**Remotes (todos validados en el servidor, con límite de frecuencia por jugador)**

| Remote | Sentido | Datos | Validación en servidor |
| --- | --- | --- | --- |
| `EnterExperiment` | cliente → servidor | `experimentId` | existe, el jugador no está en otro experimento, hay estación libre |
| `LaunchInput` | cliente → servidor | `angle`, `powerT` | rangos válidos, solo en fase de apuntado, una vez por intento |
| `AirInput` | cliente → servidor | vector `x,z` normalizado | magnitud ≤ 1, máx. 15 envíos por segundo |
| `LeaveExperiment` | cliente → servidor | — | solo si está dentro; no se permite abandonar en pleno vuelo si hay premio pendiente |
| `BuyUpgrade` | cliente → servidor | `upgradeId` | nivel < máximo, monedas suficientes |
| `BuyCosmetic` / `EquipCosmetic` | cliente → servidor | `cosmeticId` | existe, no es exclusivo de Robux, monedas suficientes |
| `ClaimDailyReward` | cliente → servidor | — | han pasado las horas necesarias |
| `ProfileUpdated` | servidor → cliente | snapshot del perfil | — |
| `ExperimentState` | servidor → cliente | fase, tiempo, puntuación en vivo | — |
| `ExperimentResult` | servidor → cliente | puntuación, récord, monedas, XP | — |
| `Notify` | servidor → cliente | texto, tipo | — |

**Esquema de datos del jugador** (DataStore `PhysicsLab_v1`, clave `Player_<UserId>`)

```lua
{
  version = 1,
  coins = 0, totalCoinsEarned = 0, level = 1, xp = 0,
  upgrades = { LaunchPower = 0, AirControl = 0, BouncePower = 0, CoinMultiplier = 0, RecoverySpeed = 0 },
  cosmetics = { owned = { [id] = true }, equipped = { Trail = id, Aura = id, LaunchFX = id, ImpactFX = id } },
  bests = { CannonLaunch = 0, EndlessDrop = 0, BounceChamber = 0, CrashTest = 0 },
  daily = { lastClaimDay = 0, streak = 0 },
  boosts = { coinBoostEndsAt = 0 },
  receipts = { [purchaseId] = true },   -- para que una compra nunca se entregue dos veces
  settings = { music = 0.6, sfx = 0.8, cameraShake = true },
  stats = { attempts = 0, playTime = 0 },
}
```

**Persistencia:** carga con reintentos (`pcall` + espera creciente) y valores por defecto fusionados con los datos guardados. Guardado automático cada 60 segundos, al salir el jugador y en `BindToClose`. Si la carga falla, el jugador juega con un perfil temporal y recibe un aviso de que su progreso no se guardará (nunca sobrescribir datos reales con un perfil vacío). Usa `UpdateAsync`.

## 5. Sistemas del juego

Estos números son el punto de partida; déjalos todos en los módulos de `Config` para poder ajustarlos sin tocar la lógica.

**Ragdoll (`RagdollService`)**

- Al empezar un intento, convierte el personaje (R6 y R15) a ragdoll: reemplaza cada `Motor6D` por un `BallSocketConstraint` con sus `Attachment`, con límites angulares razonables, y pasa el `Humanoid` a estado `Physics`. Desactiva `GettingUp` y el `HumanoidStateType.Dead` por caída.
- Al terminar, restaura las articulaciones originales, devuelve el estado normal y teletransporta al lobby. El personaje nunca debe morir por el experimento. Si muere por otra causa, se limpia la estación.
- Mantén el `NetworkOwnership` del `HumanoidRootPart` en el **servidor** durante el vuelo para que la medición sea fiable y no manipulable. Acepta la pérdida de suavidad que eso implique.
- Detecta que el jugador «se detuvo» cuando su velocidad lineal es menor que 2 studs/s durante 1,5 segundos seguidos, o al superar el tiempo máximo del experimento.

**Puntuación y recompensa**

- Toda puntuación se calcula en el servidor y se limita a un máximo plausible por experimento (`Config.Experiments[id].maxScore`). Si la supera, se descarta y se registra.
- `monedas = floor((baseCoins + puntuación × coinsPerPoint) × multiplicador)`. `XP = 20 + floor(monedas × 0,4)`.
- `multiplicador = 1 + 0,10 × nivel de Coin Multiplier + 0,25 si tiene VIP + 1,0 si tiene el pase x2 + 1,0 mientras dure el boost`. Límite máximo: x6.
- Nivel: `xpParaSubir(nivel) = floor(80 × nivel^1,4)`. Al subir de nivel gana `50 × nivel` monedas y un efecto visual.
- Cooldown entre intentos: `8 − 0,6 × nivel de Recovery Speed` segundos (mínimo 2).

**Mejoras (`UpgradeService`)**

`costo = floor(costoBase × crecimiento^nivelActual)`. Compra atómica en el servidor.

| Mejora | Nivel máx. | Efecto por nivel | Costo base | Crecimiento |
| --- | --- | --- | --- | --- |
| Launch Power | 20 | +5 % a la velocidad de lanzamiento | 100 | 1,35 |
| Air Control | 15 | +8 % a la fuerza de control en el aire | 150 | 1,35 |
| Bounce Power | 15 | +6 % al impulso de las superficies elásticas | 150 | 1,35 |
| Coin Multiplier | 15 | +10 % a las monedas por experimento | 250 | 1,45 |
| Recovery Speed | 10 | −0,6 s de cooldown entre intentos | 200 | 1,40 |

**Cosméticos (`CosmeticService`)** — cuatro categorías, un ítem equipado por categoría, todo con partículas, `Trail` y `Beam` creados por código:

- **Trails (8):** Spark (gratis), Neon Cyan, Plasma Pink, Toxic Green, Solar Flare, Frost, Rainbow, Void.
- **Auras (6):** Static, Embers, Bubbles, Electric, Galaxy, Golden.
- **Launch FX (5):** Puff, Shockwave Ring, Confetti, Lightning, Mini Nuke (versión de dibujos animados).
- **Impact FX (5):** Dust, Stars, Shatter, Slime Splash, Fireworks.
- Rarezas y precios orientativos en monedas: Común 500–1.500, Raro 3.000–8.000, Épico 15.000–30.000, Legendario 60.000+. Algunos ítems son exclusivos de VIP o de Robux (`robuxOnly = true`).

**Rankings (`LeaderboardService`)**

- Un `OrderedDataStore` por experimento. Se escribe solo cuando hay nuevo récord personal, respetando los límites de peticiones (usa una cola con reintento).
- Refresco del top 50 cada 60 segundos, mostrado en pantallas físicas (`SurfaceGui`) del lobby, una por experimento, con nombre, avatar y puntuación.
- El jugador ve su posición aproximada y su récord personal en el menú de resultados.

**Recompensa diaria (`DailyRewardService`)**

- Ciclo de 7 días con racha: 100, 150, 200, 300, 400, 600 y 1.000 monedas más un cosmético raro el día 7. Si falta un día, la racha vuelve al día 1.
- Usa el día calendario UTC calculado con `os.time()`. Pantalla emergente al entrar si hay recompensa disponible.

**Anti-trampas (`AntiExploitService`)**

- El cliente nunca informa de distancias, puntuaciones ni monedas.
- Límite de frecuencia en todos los remotes y rechazo de datos mal formados (tipo, rango, `NaN`).
- Si un jugador se aleja de su estación más de lo posible o su velocidad supera el máximo físico, se aborta su intento sin recompensa.
- Registra los eventos sospechosos en la salida del servidor con un prefijo fácil de buscar.

## 6. Los cuatro experimentos

Todos siguen las mismas fases: **cuenta atrás (3 s) → acción → resultado → cooldown → reintento o lobby**. Cada intento termina por estar detenido, por superar el tiempo máximo o por llegar al final. Construye el **Cannon Launch primero y déjalo completo y pulido** antes de los demás, porque es el experimento principal y valida todo el sistema.

### 6.1 Cannon Launch (experimento principal)

- **Objetivo:** llegar lo más lejos posible. **Puntuación:** distancia horizontal máxima en studs desde el cañón.
- **Escenario:** una pista abierta de unos 2.500 studs con marcas de distancia cada 100 studs, rampas, plataformas elásticas, anillos de impulso (`Neon`) que dan un empujón extra, zonas de viento y obstáculos blandos que frenan. Generada por código con una semilla distinta por intento para variar la colocación.
- **Apuntado:** el jugador entra en el cañón. Con ratón o dedo ajusta el ángulo (20° a 70°) y pulsa para fijar la **barra de potencia**, que oscila en un medidor. Lo que más puntúa es detenerla cerca de la zona verde.
- **Lanzamiento:** el servidor aplica la velocidad inicial `140 × (1 + 0,05 × nivel de Launch Power) × factorDePotencia` studs/s en la dirección del cañón. Efecto de disparo, sacudida de cámara y estela.
- **Vuelo:** el jugador puede inclinarse con WASD o con el joystick. El servidor aplica una fuerza lateral proporcional a Air Control mientras está en el aire. La cámara sigue al personaje con cierto retraso suave.
- **Fin:** detenido 1,5 s, o 25 s de vuelo, o el final de la pista.
- **Monedas:** `10 + distancia × 0,08`.

### 6.2 Endless Drop

- **Objetivo:** caer lo más profundo posible. **Puntuación:** profundidad máxima alcanzada en studs.
- **Escenario:** una torre vertical generada por tramos de 60 studs que se eligen al azar de un catálogo de 8 o más módulos: plataformas fijas, plataformas giratorias, barras rotatorias, superficies elásticas, cintas laterales, paredes con huecos y zonas de ralentización. Los tramos se generan por adelantado según la profundidad y se eliminan los que quedan muy atrás. Profundidad máxima: 6.000 studs.
- **Control:** control aéreo con WASD o joystick, con la misma fuerza de Air Control. Un botón de «impulso hacia abajo» con enfriamiento de 5 s da un pequeño empujón vertical.
- **Dificultad:** crece suavemente con la profundidad (más obstáculos y menos superficies elásticas).
- **Fin:** detenido 3 s, o al llegar al fondo, o 45 s.
- **Monedas:** `10 + profundidad × 0,06`.

### 6.3 Bounce Chamber

- **Objetivo:** encadenar rebotes y subir lo más alto posible. **Puntuación:** `rebotes × 10 + altura máxima ÷ 5`, multiplicada por un combo (+10 % por cada 5 rebotes seguidos sin tocar suelo normal, máximo x2).
- **Escenario:** una cámara cerrada de unos 140 × 140 × 220 studs con suelo, paredes y plataformas flotantes elásticas (`CustomPhysicalProperties` con alta elasticidad). Cada superficie elástica aplica un impulso controlado por el servidor, escalado por Bounce Power. Orbes de energía flotantes dan +25 puntos.
- **Control:** control aéreo ligero para dirigir hacia las plataformas.
- **Duración fija:** 30 segundos con temporizador visible, sin importar si se detiene.
- **Monedas:** `10 + puntos × 0,25`.

### 6.4 Crash Test

- **Objetivo:** los impactos más espectaculares. **Puntuación:** suma de `velocidadDeImpacto × bloquesRotos × 0,5` más bonos por derribar estructuras clave.
- **Escenario:** una rampa de aceleración que lanza al jugador contra una pared de estructuras construidas con bloques sueltos soldados (`WeldConstraint`) que se rompen al superar un umbral de impulso: torres, muros, un «puente de cristal» y objetivos marcados. Límite de 300 partes por estación; todas las partes se eliminan al terminar el intento.
- **Control:** el jugador solo elige la potencia de salida con la misma barra que Cannon Launch. Tras el primer impacto puede dar un empujón extra con Air Control.
- **Fin:** detenido 2 s, o 20 s. Si todo se destruyó, bono de «destrucción total».
- **Monedas:** `10 + puntos × 0,05`.

**Comunes a los cuatro:** efectos de impacto según el Impact FX equipado, sonidos (ver sección 8), números de puntuación que suben en vivo y un texto cómico en la pantalla de resultados («Ouch!», «Great science!») elegido según el rendimiento.

## 7. UI y UX

La interfaz tiene que verse como el panel de un laboratorio futurista, ser legible en móvil y poder construirse entera con código.

**Estilo visual (`Theme`)**

- Paneles azul marino oscuro `#0B1220` con borde fino cian `#19E3FF`, esquinas redondeadas (`UICorner` de 8 a 12 px) y ligera transparencia.
- Acentos: cian `#19E3FF` (principal), amarillo de advertencia `#FFC400` (monedas y atención), verde `#3DFF9A` (éxito), rojo `#FF4D5E` (error), blanco roto para texto.
- Tipografía: `GothamBold` para títulos y botones, `Gotham` para cuerpo, `Code` para números técnicos.
- Botones con animación de pulsación y hover con `TweenService`. Sonido de clic (opcional vía `Assets`). Números de monedas que cuentan hacia arriba al cambiar.
- Iconos con emoji o formas simples mientras no haya imágenes (por ejemplo 🪙 monedas, 🚀 lanzamiento, ⭐ nivel).

**Responsive:** usa `UIScale` según el tamaño de pantalla y márgenes seguros. Todo debe ser manejable con una mano en móvil: botones de al menos 44 px, sin texto menor de 14 px. Soporta ratón, táctil y mando.

**Pantallas**

| Pantalla | Contenido |
| --- | --- |
| HUD del lobby | Monedas, nivel y barra de XP, botones (Experiments, Upgrades, Cosmetics, Shop, Daily, Leaderboard, Settings), indicador de rachas y boost activo |
| Selector de experimentos | 4 tarjetas con nombre, descripción corta, récord personal y botón Play; indica estaciones libres |
| HUD de experimento | Cuenta atrás, fase, puntuación en vivo, velocidad, distancia/profundidad/altura según el experimento, barra de potencia y control de ángulo en Cannon Launch, botón salir |
| Resultados | Puntuación, indicador de «NEW RECORD», monedas y XP ganados con animación, posición aproximada en el ranking, botones Retry (con cooldown visible) y Lobby |
| Mejoras | 5 filas con nivel actual en pips, efecto actual y siguiente, costo y botón comprar (deshabilitado si faltan monedas) |
| Cosméticos | 4 pestañas, cuadrícula de ítems con rareza por color, previsualización sobre el personaje, comprar/equipar |
| Recompensa diaria | 7 casillas, la de hoy resaltada, botón Claim |
| Tienda Robux | Game passes y paquetes de monedas, con precio obtenido de `MarketplaceService` |
| Ranking | Top 50 por experimento con pestañas |
| Ajustes | Volumen de música y efectos, sacudida de cámara |

**Guía de interacción:** el menú no debe tapar el centro de la pantalla durante un experimento. Tras terminar, el botón de reintentar es el más grande y está bajo el pulgar. Evita los menús profundos: ninguna acción importante a más de 2 toques desde el HUD. Primera vez: un tutorial de 3 pasos con globos de texto («Enter a portal», «Hold to power up», «Upgrade your stats»).

## 8. Lobby, assets, audio y efectos

Lo visual se genera por código por defecto, y los assets externos (imágenes, audio, modelos gratuitos) son un añadido opcional cuyos IDs quedan vacíos en `Config/Assets` hasta que el usuario los complete.

**Modo por defecto: cero IDs que rellenar.** El usuario no quiere buscar ni pegar IDs, así que la primera versión debe funcionar sin ningún asset externo:

- **Imágenes:** no uses imágenes subidas. Los iconos son emoji, texto, formas y degradados hechos por código (`UIGradient`, `UICorner`, `UIStroke`).
- **Audio:** usa solo sonidos integrados de Roblox con rutas `rbxasset://sounds/...` que estés segura de que existen en el cliente. Si dudas de una ruta, deja esa clave vacía.
- **Modelos:** no uses el Toolbox, salvo que tengas acceso directo a Studio (por MCP o plugin) y puedas insertar y revisar el asset por tu cuenta siguiendo las reglas de seguridad de más abajo.
- Las claves de `Config/Assets` quedan como mejora opcional para después del lanzamiento. No las pidas durante las fases ni las menciones como un paso obligatorio.
- **Única excepción inevitable:** los Game Passes y Developer Products de la sección 9 necesitan IDs creados en el Creator Hub. El juego puede publicarse sin ellos, porque con el valor `0` esos botones quedan ocultos y se agregan más tarde.

**Lobby (`LobbyBuilder`)**

- Una sala circular de laboratorio de unos 200 studs de diámetro: suelo metálico, paredes con paneles de `Neon`, luces `PointLight`, `Atmosphere` y `Lighting` con ambiente frío y limpio.
- Cuatro portales (aros de `Neon` con `ProximityPrompt` y un cartel flotante con el nombre y el récord del jugador), uno por experimento, que llevan al jugador a su estación.
- Zona de spawn con `SpawnLocation` segura, tres pantallas de ranking en las paredes, un panel de mejoras y uno de cosméticos (con `ProximityPrompt` que abre la UI) y adornos de laboratorio hechos con partes (tubos, tanques, consolas).
- El lobby no debe tener física peligrosa ni forma de caer al vacío. Si el jugador cae por debajo de cierta altura, vuelve al spawn.

**Estaciones:** cada experimento se construye con `StationBuilder` y se coloca a gran distancia del lobby. Cada estación tiene su propia iluminación local, paredes de seguridad invisibles y una zona de retorno automático.

**Audio (nombres que debe usar el código; el ID va vacío)**

| Evento | Clave en `Assets.Sounds` | Búsqueda sugerida en el Creator Store |
| --- | --- | --- |
| Música del lobby | `LobbyMusic` | calm sci-fi ambient loop |
| Música de experimento | `ExperimentMusic` | upbeat electronic arcade loop |
| Cuenta atrás | `Countdown` | countdown beep |
| Disparo de cañón | `CannonFire` | cartoon cannon shot |
| Rebote | `Bounce` | boing spring |
| Impacto suave y fuerte | `ImpactSoft`, `ImpactHard` | punch impact, crash |
| Rotura de bloque | `Shatter` | wood break, glass break |
| Moneda y compra | `Coin`, `Purchase` | coin collect, cash register |
| Subir de nivel | `LevelUp` | level up fanfare |
| Nuevo récord | `NewRecord` | victory jingle |
| Clic y hover de UI | `UIClick`, `UIHover` | ui click, sci-fi ui |

Un `AudioController` único reproduce estos sonidos por clave, respeta los volúmenes de Ajustes y ignora las claves cuyo ID esté vacío.

**Efectos visuales (por código)**

- Disparo: explosión de partículas y anillo de choque.
- Vuelo: estela (`Trail`) según el cosmético, líneas de velocidad en pantalla al superar cierta velocidad y aumento suave del campo de visión.
- Impacto: partículas, sacudida de cámara proporcional a la fuerza y cámara lenta breve (0,3 s) en los impactos más fuertes.
- Récord y nivel: confeti y destello de pantalla.

**Material gráfico para la tienda de Roblox**

Si puedes generar imágenes, genéralas tú; si no, entrega un texto descriptivo listo para pegar en un generador de imágenes. Hacen falta: icono del juego (512 × 512), 3 a 5 miniaturas (1920 × 1080) y las capturas de promoción. Describe el estilo (laboratorio sci-fi, personaje ragdoll cartoon lanzado por un cañón, colores cian y amarillo, sin texto pequeño).

**Assets externos: imágenes generadas por IA y Toolbox gratuito**

El juego debe funcionar siempre sin ningún asset externo. Los assets externos mejoran el aspecto, pero cada uno tiene una versión de respaldo hecha por código.

- **Imágenes generadas por IA (si puedes generarlas):** crea los iconos de UI (monedas, cada mejora, cada cosmético, los 4 experimentos), el icono del juego y las miniaturas. Entrégalos como PNG con el nombre igual a su clave en `Assets.Images`, en estos tamaños: iconos de UI 256 × 256 con fondo transparente, icono del juego 512 × 512, miniaturas 1920 × 1080. Añade los pasos para subirlos (Creator Hub > Creations > Images) y para pegar cada ID en `Config/Assets`. La subida la hace el usuario a mano, y debe comprobar que cada imagen carga en un `ImageLabel`.
- **Audio generado por IA:** solo si el usuario ya sabe subirlo; la subida de audio exige verificación y pasa moderación, así que **prefiere el audio gratuito ya existente** del Creator Store.
- **Modelos y audio gratuitos del Creator Store (Toolbox):** están permitidos con estas reglas.
  - Nunca inventes IDs. Si no puedes buscar en el Toolbox directamente, entrega una lista de lo que hace falta con términos de búsqueda en inglés, y el usuario elige.
  - Los modelos los inserta el usuario desde el Toolbox en Studio y los guarda en `ServerStorage/Assets` con el nombre exacto que indiques. El código los clona si existen y, si no, usa la versión generada por código.
  - **Seguridad:** todo modelo del Toolbox puede traer scripts maliciosos. Indica al usuario que borre cualquier `Script`, `LocalScript` o `ModuleScript` dentro de los modelos insertados y que use solo modelos que sean únicamente partes y mallas. Tu código nunca debe ejecutar scripts que vengan de un asset.
  - Prefiere assets de Roblox o con buena valoración, y vigila el número de partes y el peso de las mallas, sobre todo en móvil.
  - Algunos audios no suenan en la experiencia publicada por permisos. Si pasa, hay que sustituirlos por otro. El `AudioController` debe seguir funcionando sin ellos.
- Cierra la entrega con una **tabla de assets pendientes**: nombre, tipo, clave en `Config/Assets` o nombre en `ServerStorage/Assets`, fuente sugerida y para qué se usa.

## 9. Monetización

La monetización usa Game Passes y Developer Products, y acelera la progresión sin bloquear el juego gratuito ni dar ventaja en los rankings más allá de ganar monedas más rápido. Los IDs reales no existen aún: déjalos en `Config/Monetization` con el valor `0` y haz que el código ignore con gracia los que estén en `0`, ocultando ese botón en la tienda.

| Producto | Tipo | Efecto |
| --- | --- | --- |
| VIP | Game Pass | +25 % de monedas, etiqueta VIP sobre el nombre, 1 trail y 1 aura exclusivos, entrada prioritaria en la cola de estaciones |
| 2x Coins | Game Pass | +1,0 al multiplicador de monedas de forma permanente |
| Exclusive Effects | Game Pass | Desbloquea 3 efectos de lanzamiento e impacto exclusivos |
| Coin Pack S / M / L / XL | Developer Product | +1.000 / +5.000 / +25.000 / +100.000 monedas |
| Coin Boost 15 min | Developer Product | +1,0 al multiplicador durante 15 minutos (se acumula el tiempo si se compra de nuevo) |
| Special Cosmetics | Developer Product | Compra de ítems con `robuxOnly = true` |

**Reglas técnicas**

- `ProcessReceipt` se implementa una sola vez, con guardado en el perfil de cada `purchaseId` para no entregar dos veces. Devuelve `NotProcessedYet` si el perfil no está cargado o falla el guardado.
- Verificación de pases con `UserOwnsGamePassAsync` al entrar y al terminar una compra (`PromptGamePassPurchaseFinished`).
- La tienda muestra el precio real con `MarketplaceService:GetProductInfo`.
- Registra los eventos económicos con `AnalyticsService` (ingresos y gastos de monedas) y los pasos del embudo del primer uso (entra, primer experimento, primera mejora).

## 10. Plan de entrega por fases

Trabaja en este orden. Cada fase termina con algo que se pueda probar en Studio antes de pasar a la siguiente. Entrega el máximo posible por respuesta, y al terminar cada fase escribe exactamente `FASE N COMPLETA — escribe CONTINUAR` para que el usuario te dé paso.

| Fase | Contenido | Criterio de «hecho» |
| --- | --- | --- |
| 0. Base | Estructura de carpetas, todos los módulos de `Config`, `Util`, `Remotes`, `Server` y `Client` mínimos que arrancan sin errores | El juego inicia en Studio sin errores en la salida |
| 1. Núcleo | `DataService`, `RagdollService`, `ExperimentService` (estaciones y fases), `LobbyBuilder`, `StationBuilder`, HUD básico de monedas y nivel | El jugador aparece en el lobby, ve sus monedas y su perfil se guarda y se carga |
| 2. Cannon Launch completo | Experimento entero con apuntado, potencia, vuelo, fin, resultados, monedas, XP y reintento | Se puede jugar el bucle completo varias veces seguidas y ganar monedas |
| 3. Mejoras y progresión | `UpgradeService`, pantalla de mejoras, niveles y efectos reales en Cannon Launch | Comprar Launch Power cambia visiblemente la distancia |
| 4. Resto de experimentos | Endless Drop, Bounce Chamber y Crash Test, con selector de experimentos y portales | Los 4 experimentos se juegan de principio a fin, con 2 jugadores a la vez |
| 5. Sociales y retención | Rankings globales, récords, recompensa diaria, cosméticos y tienda de cosméticos, tutorial inicial | Un récord aparece en el ranking y los cosméticos se ven en el personaje |
| 6. Monetización | Game passes, developer products, boost, tienda Robux, `ProcessReceipt` | Con los IDs en `0`, nada falla; con IDs reales, la compra concede el efecto |
| 7. Pulido y seguridad | Audio, efectos, anti-trampas, rendimiento (límite de partes, limpieza), ajustes, móvil | Sin fugas visibles tras 30 intentos seguidos; usable en móvil |
| 8. Lanzamiento | Lista de verificación final, textos de la tienda, material gráfico, informe de riesgos | El usuario puede seguir la lista de la sección 11 y publicar |

**Recorte de alcance si el tiempo aprieta:** el mínimo lanzable es la Fase 0 a 3 más rankings y monetización básica con **solo Cannon Launch**. Los otros tres experimentos pueden salir en una actualización posterior. Si recortas, dilo con claridad.

## 11. Formato de entrega, calidad y lanzamiento

**Formato de cada respuesta**

1. Una línea con la fase y lo que contiene.
2. Los archivos, uno tras otro, cada uno con un encabezado `RUTA: ServerScriptService/Server/Services/DataService` y `TIPO: ModuleScript`, y luego el código completo en un bloque `lua`.
3. **Orden de creación** en Studio, si importa.
4. **Cómo probar** la fase (pasos concretos, qué debería verse).
5. **Riesgos conocidos** y decisiones tomadas (breve).
6. La frase de cierre de la fase.

Si una respuesta no cabe, divídela en partes numeradas y avisa con claridad cuál falta. No resumas código ni lo dejes incompleto para ahorrar espacio.

**Reglas de calidad**

- Usa `--!strict` solo donde no frene el avance; el código debe ejecutar sin errores de sintaxis ni referencias a objetos que no existan.
- Todo acceso a un objeto que pueda no estar listo usa `WaitForChild` con tiempo límite o `FindFirstChild` con comprobación.
- Nunca confíes en datos del cliente. Nunca uses `loadstring`, `HttpService` ni IDs inventados.
- Cada experimento y cada estación se limpia por completo al terminar (partes, conexiones, hilos, efectos).
- Rendimiento: máximo 300 partes dinámicas por estación, sin bucles `while true` sin `task.wait`, y sin crear instancias nuevas en cada fotograma salvo que sea imprescindible.
- Comenta en español lo que no sea evidente: especialmente fórmulas y puntos donde el servidor y el cliente se coordinan.
- Los valores de balance y los textos viven en `Config`/`Strings`, no repartidos por el código.

**Lista de lanzamiento (entrégala al final, adaptada a lo que construiste)**

Estas son las tareas que la IA no puede hacer y el usuario sí. Incluye los pasos concretos:

- [ ] Crear el lugar en Roblox Studio, pegar los scripts y publicar la experiencia (`File > Publish to Roblox`).
- [ ] Activar `Game Settings > Security > Enable Studio Access to API Services` para probar DataStore en Studio.
- [ ] Crear en el Creator Hub los Game Passes y Developer Products de la sección 9, y pegar sus IDs en `Config/Monetization`.
- [ ] Completar `Config/Assets` con los IDs de audio e imágenes (usa la lista de búsquedas sugeridas).
- [ ] Probar con 2 a 4 jugadores reales o con `Test > Clients and Servers`: entrar, jugar los 4 experimentos, comprar mejoras y reconectar.
- [ ] Probar en móvil o con el emulador de dispositivos de Studio.
- [ ] Configurar el juego: nombre, descripción, géneros, máximo de 20 jugadores, dispositivos compatibles.
- [ ] Subir el icono y las miniaturas generados.
- [ ] Completar el cuestionario de clasificación de contenido de Roblox y revisar los permisos de compras dentro del juego.
- [ ] Poner la experiencia en público y vigilar la salida del servidor y las métricas los primeros días.

**Al terminar la Fase 8 entrega además:** el texto del título y la descripción de la experiencia (en inglés, con palabras clave de búsqueda), una lista de los errores que más probablemente aparecerán en la primera prueba, y la lista de assets externos pendientes.

**Empieza ahora por la Fase 0.**
