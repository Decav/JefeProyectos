# PHYSICS LAB — Entrega final (Fase 8)

Estado: construido en el lugar **Place2** de Roblox Studio (sin publicar, sin guardar en disco). Todo el juego se genera por código; no hace falta ningún asset externo para jugarlo.

## 1. Qué contiene el juego

- **Lobby** circular con 4 portales, consola de mejoras, consola de cosméticos y 4 pantallas de ranking (top 50 en páginas de 10).
- **4 experimentos** con 8 estaciones cada uno: Cannon Launch, Endless Drop, Bounce Chamber, Crash Test.
- **Progresión:** monedas, XP y niveles, 5 mejoras (con efecto real), 24 cosméticos (trails, auras, efectos de lanzamiento e impacto), recompensa diaria de 7 días, tutorial de 3 pasos.
- **Social:** rankings globales con OrderedDataStore, récord personal en cada portal.
- **Monetización:** 3 Game Passes y 6 Developer Products (todos con ID 0 hasta que los crees), boost de monedas, tienda Robux, `ProcessReceipt` único con recibos guardados.
- **Seguridad y calidad:** servidor autoritativo, validación y límite de frecuencia en todos los remotes, anti-trampas por límites físicos, audio con sonidos integrados, ajustes de volumen y cámara, interfaz comprobada en un móvil de 666×374.

## 2. Lista de lanzamiento (lo que solo puedes hacer tú)

- [ ] **Guardar el trabajo.** Ahora mismo Place2 solo existe dentro de esta sesión de Studio: `File > Save to File As…` para tener una copia local.
- [ ] **Publicar.** `File > Publish to Roblox` (crea la experiencia). Sin esto no funcionan el DataStore, los rankings persistentes ni las compras.
- [ ] **Activar la API en Studio** para probar el guardado: `Home > Game Settings > Security > Enable Studio Access to API Services`.
- [ ] **Probar el guardado:** juega, gana monedas, detén el playtest, vuelve a jugar y comprueba que las monedas siguen. En la consola ya no debe aparecer "You must publish this place to the web".
- [ ] **Crear los 3 Game Passes** en el Creator Hub (`Creations > tu experiencia > Monetization > Passes`) y pegar sus IDs en `ReplicatedStorage/Shared/Config/Monetization`, tabla `GamePasses`:
  - `VIP` — +25 % monedas, etiqueta VIP, trail Void y aura Golden exclusivos, prioridad en la cola.
  - `DoubleCoins` — +1,0 al multiplicador de monedas.
  - `ExclusiveEffects` — desbloquea Lightning, Mini Nuke y Fireworks.
- [ ] **Crear los 6 Developer Products** (`Monetization > Developer Products`) y pegar sus IDs en la tabla `Products` del mismo módulo:
  - `CoinPackS` (+1.000), `CoinPackM` (+5.000), `CoinPackL` (+25.000), `CoinPackXL` (+100.000).
  - `CoinBoost15` (+1,0 multiplicador 15 min, acumulable).
  - `SpecialCosmetics` (otorga el aura Galaxy).
  - Precios sugeridos de partida: pases 199–499 R$, packs 49 / 199 / 799 / 2499 R$, boost 99 R$, Galaxy 399 R$. Ajusta con las métricas.
- [ ] **Probar en 2 a 4 clientes:** `Test > Clients and Servers` (2–4 jugadores). Entrar a los 4 experimentos a la vez, comprobar la cola cuando las 8 estaciones están ocupadas, comprar mejoras y reconectar.
- [ ] **Probar en móvil real o con el emulador** (`Test > Device`): joystick táctil durante el vuelo, deslizador de ángulo, botón FIRE y botón de impulso.
- [ ] **Configurar la experiencia:** nombre, descripción, géneros, **máximo 20 jugadores** (los servidores se diseñaron para 20), dispositivos compatibles (PC, móvil, consola).
- [ ] **Subir icono y miniaturas** (ver sección 5).
- [ ] **Cuestionario de clasificación de contenido** de Roblox (el ragdoll es de dibujos animados, sin sangre) y revisar los permisos de compras dentro del juego.
- [ ] **Poner la experiencia en público** y vigilar la consola del servidor y las métricas los primeros días. Busca en el registro del servidor el prefijo `[PL-EXPLOIT]`.
- [ ] **Opcional tras el lanzamiento:** completar `Config/Assets` con IDs de música (ver sección 4).

## 3. Textos de la tienda (en inglés)

**Título (≤ 50 caracteres):**

`Physics Lab: The Ultimate Ragdoll Experiment`

**Descripción:**

```
Welcome to Physics Lab, the lab where YOU are the test subject!

Blast out of a cannon, plunge down an endless tower, bounce around a chamber of springs and smash through walls in the Crash Test. Every run is quick, funny and makes you want to go one more time.

FOUR EXPERIMENTS
• Cannon Launch – aim, power up and fly as far as you can
• Endless Drop – fall deeper than anyone else
• Bounce Chamber – chain bounces and climb for combos
• Crash Test – hit the wall at top speed and break everything

PROGRESS AND COMPETE
• Earn coins and XP on every attempt
• Upgrade launch power, air control, bounce power and more
• Unlock trails, auras and launch and impact effects
• Claim a daily reward and keep your streak
• Climb the global leaderboards

Play with friends, beat each other's records and see who is the best scientist in the lab!

Tags: ragdoll, physics, simulator, launch, cannon, fling, obby, funny, record, upgrades
```

**Géneros sugeridos:** Simulation (principal) y Comedy; **etiquetas:** ragdoll, physics, simulator, fling, arcade.

## 4. Assets externos pendientes (todos opcionales)

El juego funciona sin ninguno. Usa sonidos integrados de Roblox como respaldo.

| Nombre | Tipo | Clave | Fuente sugerida | Para qué se usa |
| --- | --- | --- | --- | --- |
| Música del lobby | Audio | `Config/Assets.Sounds.LobbyMusic` | Creator Store: "calm sci-fi ambient loop" | Ambiente del lobby (bucle) |
| Música de experimento | Audio | `Config/Assets.Sounds.ExperimentMusic` | Creator Store: "upbeat electronic arcade loop" | Música durante los intentos |
| Cuenta atrás | Audio | `Sounds.Countdown` | Creator Store: "countdown beep" | Sustituye al sonido integrado |
| Disparo de cañón | Audio | `Sounds.CannonFire` | Creator Store: "cartoon cannon shot" | Sustituye al sonido integrado |
| Rebote | Audio | `Sounds.Bounce` | Creator Store: "boing spring" | Sustituye al sonido integrado |
| Impacto suave / fuerte | Audio | `Sounds.ImpactSoft`, `Sounds.ImpactHard` | Creator Store: "punch impact", "crash" | Impactos |
| Rotura de bloque | Audio | `Sounds.Shatter` | Creator Store: "wood break", "glass break" | Crash Test |
| Moneda y compra | Audio | `Sounds.Coin`, `Sounds.Purchase` | Creator Store: "coin collect", "cash register" | Recompensas y tienda |
| Subir de nivel / nuevo récord | Audio | `Sounds.LevelUp`, `Sounds.NewRecord` | Creator Store: "level up fanfare", "victory jingle" | Celebraciones |
| Clic y hover de UI | Audio | `Sounds.UIClick`, `Sounds.UIHover` | Creator Store: "ui click", "sci-fi ui" | Botones |
| Icono de juego | Imagen | (Creator Hub) | Generador de imágenes (ver sección 5) | Icono de la experiencia |
| Miniaturas | Imagen | (Creator Hub) | Generador de imágenes (ver sección 5) | Página de la experiencia |

Notas: si un audio no suena en la experiencia publicada por permisos, cámbialo por otro; el `AudioController` ignora las claves vacías. Un ID en `Sounds` manda sobre el respaldo integrado.

## 5. Material gráfico para la tienda

No se generaron imágenes. Descripciones listas para pegar en un generador:

- **Icono (512 × 512):** "Cartoon sci-fi laboratory scene, a cute blocky ragdoll test subject being launched out of a big chunky cannon, motion trails, cyan and yellow color palette, neon glow, dark navy background, bold clean shapes, no text, centered composition, game icon style."
- **Miniatura 1 (1920 × 1080) — Cannon Launch:** "Wide shot of a long neon cyan track in a futuristic lab, a cartoon ragdoll flying high with a bright trail, distance markers glowing below, dark navy sky with stars, cyan and yellow accents, no small text."
- **Miniatura 2 — Crash Test:** "Cartoon ragdoll crashing through a wall of colorful blocks, bricks flying everywhere, yellow explosion burst, sci-fi lab background, cyan rim light, no small text."
- **Miniatura 3 — Bounce Chamber:** "Glass chamber full of glowing magenta and cyan bounce pads, a ragdoll mid-bounce with sparkles and orbs, vertical composition, neon style, no small text."
- **Miniatura 4 — Endless Drop:** "Looking down a tall glass shaft with spinning bars and platforms, a ragdoll falling with a cyan trail, deep perspective, dramatic lighting, no small text."
- **Capturas de promoción:** haz capturas en Studio del lobby, de un vuelo de Cannon Launch con estela, de la pantalla de resultados con "NEW RECORD" y de la pantalla de Mejoras.

## 6. Errores que más probablemente aparecerán en la primera prueba

1. **DataStore sin activar:** aviso "Your data could not be loaded". Causa: lugar sin publicar o sin la API activada. El juego sigue funcionando con perfil temporal.
2. **Personajes R6:** el ragdoll se probó solo con R15. Si usas avatares R6, revisa el vuelo y las articulaciones.
3. **Joystick táctil durante el vuelo:** el control aéreo lee `Humanoid.MoveDirection`; en móvil real conviene confirmar que responde en estado Physics.
4. **Dos jugadores en el mismo experimento:** el código guarda el estado por jugador y por estación, pero no se probó con varios jugadores reales. Revisa colisiones entre personajes y la cola de estaciones.
5. **Compras reales:** `ProcessReceipt` y la tienda con precios de `GetProductInfo` no se pudieron comprobar sin IDs reales.
6. **Rankings:** al estar en memoria en Studio, el top 50 persistente y la cola de escritura se verán por primera vez al publicar. Pueden tardar hasta 60 s en refrescarse.
7. **Equilibrio:** distancias de Cannon Launch, duración de Endless Drop (termina si el jugador se queda 3 s en una plataforma), pagos y costes están sin ajustar. Todo está en `ReplicatedStorage/Shared/Config`.
8. **Rate limits:** un cliente muy ruidoso puede aparecer en el registro como `RateLimit:AirInput`. El cliente normal envía unos 12 por segundo (límite 15).
9. **Falsos positivos del anti-trampas:** un pico de velocidad o un empujón de física puede superar 900 studs/s o los límites de distancia; se exige que ocurra dos veces seguidas antes de cancelar el intento.
10. **Texto en inglés:** los avisos del servidor viajan como claves de `Strings`; si ves el nombre de una clave en pantalla, falta añadirla al módulo.

## 7. Informe de riesgos

| Riesgo | Impacto | Mitigación |
| --- | --- | --- |
| Pérdida de datos por guardado | Alto | Reintentos, perfil temporal si falla la carga (nunca sobrescribe datos reales), autoguardado cada 60 s, guardado al salir y en `BindToClose`. **No hay bloqueo de sesión entre servidores.** |
| Entrega duplicada de compras | Alto | Recibo anotado antes de entregar y guardado; devuelve `NotProcessedYet` si no se guarda. Los recibos crecen sin límite. |
| Trampas | Medio | Servidor autoritativo, red del personaje en el servidor, rangos y frecuencia validados, límites físicos, puntuaciones imposibles descartadas. |
| Rendimiento con 20 jugadores | Medio | Máximo 300 partes por estación, limpieza completa por intento, 30 intentos seguidos sin fugas. No probado con 20 jugadores. |
| Móvil | Medio | Pantallas verificadas a 666×374, botones táctiles ≥ 44 px. Sin prueba en dispositivo real. |
| Cuota de DataStore y nombres | Bajo | Una escritura de ranking por récord, cola con reintentos; búsqueda de nombres limitada por refresco. |

## 8. Registro de decisiones (una línea por decisión)

- Los remotes se crean desde el script `Server`; añadí `ActionInput`, `TutorialDone`, `SetSetting`, `DevCommand` (solo Studio) y la función `GetLeaderboard`, que no estaban en la spec.
- El orden de arranque de servicios es AntiExploit, Analytics, Profile, Data, Economy, Upgrade, Cosmetic, Ragdoll, Experiment, Leaderboard, DailyReward, Monetization.
- Todo texto visible del jugador va por claves de `Strings`; las notificaciones viajan como "Clave" o "Clave:argumento".
- Las estaciones están a 8000 studs de altura y separadas 400 en Z y 4000 en X por experimento; `FallenPartsDestroyHeight` se fija en el lugar (los scripts no pueden escribirlo).
- La plantilla de estación no lleva paredes (bloquearían el cañón); cada experimento añade las suyas.
- El ragdoll mantiene el `RootJoint` y la red del `HumanoidRootPart` queda en el servidor.
- Gravedad reducida en vuelo (Cannon 0,4, Drop 0,5, Bounce 0,4, Crash 0,4) con `VectorForce` por miembro, para que las distancias sean jugables.
- Cannon Launch: el servidor decide la potencia con su reloj y solo acepta la del cliente si difiere menos de 0,2.
- No se puede abandonar un experimento en pleno vuelo; sí en cuenta atrás, apuntado y resultados.
- Retry usa `EnterExperiment` con el mismo id tras el cooldown; sin respuesta en 30 s se vuelve al lobby.
- Endless Drop: los tramos se generan al vuelo y se borran los de atrás; fin por quedarse 3 s, 45 s o llegar al fondo.
- Bounce Chamber: el combo se aplica al sumar cada rebote y orbe; hay un resorte de seguridad si el jugador se queda quieto.
- Crash Test: bloques `Anchored` hasta romperse (no `WeldConstraint`) con colapso por columna; ángulo fijo, solo cuenta la potencia.
- Los efectos de cosméticos se crean en el servidor para que los vean todos; el trail es una única instancia que se alarga durante el intento.
- Los niveles de mejora, récords, cosméticos y ajustes viajan también como `Attributes` del jugador (evita perder eventos tempranos).
- Los rankings usan una copia en memoria cuando el DataStore no está disponible (p. ej. Studio sin publicar).
- La recompensa diaria usa día UTC `os.time() // 86400`; el día 7 da un cosmético Raro o 2000 monedas si ya los tiene.
- Los pases se leen con `UserOwnsGamePassAsync` y se marcan como atributos (`HasVIP`, `Has2x`, `HasEffectsPass`); el multiplicador máximo es x6.
- La herramienta `DevCommand` (dar monedas, simular compras y pases) solo se conecta si `RunService:IsStudio()`.
- Los iconos son emoji; 🪙 y ✕ no se dibujan en la fuente de Roblox, por eso se usa 💰 y "X".
- El `UIStroke` de los botones se limita a `Border` para no contornear el texto.
- Los sonidos integrados se verificaron cargándolos en el cliente; las claves de música quedan vacías.
- El anti-trampas exige dos revisiones seguidas fuera de límites antes de cancelar un intento sin recompensa.
- El menú del HUD es una lista con scroll; el HUD de monedas y el menú se ocultan mientras hay una ventana abierta o un experimento.
- No se usó `StreamingEnabled`, `HttpService` ni librerías de terceros.
