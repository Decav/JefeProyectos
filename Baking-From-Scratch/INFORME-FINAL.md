# Baking From Scratch: informe final de construcción

Construido íntegramente por código a través del MCP de Roblox Studio, sin assets subidos, sin librerías externas y con la interfaz generada de forma programática. Texto visible al jugador en inglés con traducción completa al español neutro en `Config/Localization`.

## 1. Estado por fase

| Fase | Contenido | Estado | Verificación |
| --- | --- | --- | --- |
| 0 | Arquitectura, remotes, configuración, localización, componentes de UI | Completa | Arranque sin errores (15 módulos de servidor, 6 controladores de cliente) |
| 1 | Mundo de Etapa 1, persistencia, economía base, HUD, ajustes y cambio EN/ES | Completa | Pruebas de datastore (15) y economía (21), capturas |
| 2 | Pedidos, clientes, insumos, dosificación, horneado y anti-softlock | Completa | Pruebas de pedidos (13), inventario (17) y horneado (22), capturas |
| 3 | Decoración 3D: corte, relleno y apilado, base giratoria, manga, toppings | Completa | Pruebas de decoración (60) y jugadas reales con el ratón |
| 4 | Entrega, precisión autoritativa, deuda, intereses, mora, averías | Completa | Pruebas de economía y decoración, capturas |
| 5 | Redes sociales, reseñas, encargos digitales y estafas | Completa | Pruebas sociales (30), capturas |
| 6 | Progresión, horno industrial, refrigerador con caducidad, local, personal | Completa | Pruebas de progresión (39) y refrigerador (26), capturas |
| 7 | Selector de modos, modo Creativo, modo Competitivo con ranking global, monetización segura, tutorial de 4 pasos | Completa | Pruebas de modos (21), competitivo (37) y monetización (23), recorrido real con el ratón |
| 8 | Revisión de escala y capas de UI, limpieza, comprobación de fugas, mundo solo en tiempo de ejecución, informe | Completa con las limitaciones de la sección 4 | Regresión total 324/324, prueba de fugas, consola limpia |

Regresión final: 324 comprobaciones automáticas correctas (datastore 15, economy 21, orders 13, inventory 17, baking 22, decorating 60, social 30, progression 39, fridge 26, modes 21, competitive 37, monetization 23). Los únicos avisos en consola son los esperados: el DataStore no responde mientras el lugar no esté publicado y varias pruebas lo simulan a propósito.

## 2. Registro de decisiones

Arquitectura
- Las acciones del cliente son `RemoteFunction` que devuelven `{ ok, err, args, missing }`; las notificaciones del servidor son `RemoteEvent`.
- Se añadió un módulo `Router` (límite de frecuencia, `pcall`, validadores) y un módulo `QA` que solo existe dentro de Studio, fuera del árbol original.
- Se añadió `ModeService` (fuera del árbol original) para centralizar el cambio de modo.
- `Cake3DBuilder` vive en `Shared` y tiene una reexportación en `World`.
- El estado de sesión (modo, decoración, partida competitiva) está separado del perfil persistente.
- El mundo no se guarda en el lugar: `WorldBuilder` lo reconstruye en cada ejecución. Se eliminaron del lugar guardado el `BakeryWorld` y la carpeta `Remotes` que habían quedado de las pruebas en modo Edit.

Perfil y economía
- Campos extra del perfil: `expertiseLevel`, `marketingLevel`, `paidToday`, `introSeen`, `tutorialDone`, `passes`, `fridgeNext`, `sensitivity`.
- Si el DataStore falla al cargar, el jugador entra en modo temporal (sin guardado, con insignia visible) para no pisar datos reales.
- El refrigerador echa a perder el bizcocho a los 2 días. `missedPayments` baja en 1 por cada día con costos cubiertos.
- La marca de estafa de un pedido nunca se envía al cliente. A cada pedido se le añadió `pipingColor`.

Decoración
- La parte superior se aparta sobre la mesa durante el relleno y la mesa de preparación es más ancha. El techo se oculta localmente mientras se decora.
- El cliente informa lo hecho en cada subfase; el servidor valida orden, tiempos mínimos y límites, y calcula la precisión.
- Se desactiva el CoreGui (lista de jugadores, chat, mochila, emotes): en un juego de un jugador solo tapaban el HUD.

Fase 7
- Cambio de modo: salir de Daily cancela los pedidos pendientes o aceptados (aún sin insumos consumidos) y pausa el reloj de jornada. Si hay un pedido en horno, listo, en mano o en decoración, el cambio se rechaza para no perder insumos. Volver a Daily retrasa 4 segundos la llegada de clientes.
- Creativo: totalmente local, sin red, con ingredientes, colores, boquillas y toppings ilimitados, de 1 a 3 pisos, con sabor y relleno a elección. Los colores y la boquilla VIP siguen dependiendo del pase.
- Competitivo: 3 rondas encadenadas con pisos 1, 1 y 2, mismos tipos de reto para todos y límite de 360 segundos para la partida completa. El servidor genera los pedidos con los insumos exactos, mide el tiempo y calcula el puntaje.
- Puntaje por ronda: precisión x 10 más un bono de velocidad de hasta 300 que se escala por la precisión y solo se concede con precisión de 45 % o más, para que decorar rápido y mal no rinda. Salir de la decoración equivale a abandonar la partida y no registra puntaje.
- Ranking: el mejor puntaje se guarda en el perfil y en el `OrderedDataStore` global (`BakingFromScratch_CompetitiveBest_v1`) sin bajarlo nunca. El Top 10 se consulta con caché de 30 segundos y, si el almacén no responde, la interfaz lo indica sin romperse.
- Monetización: todos los IDs están en 0. Un ID en 0 no se ofrece (el botón dice "Coming Soon") y un recibo con ese ID no concede nada. `ProcessReceipt` es idempotente: cada `PurchaseId` queda registrado en `profile.receipts` y solo se confirma la compra cuando el perfil quedó guardado. Con perfil temporal nunca se confirma. Los Game Passes se verifican en el servidor con `UserOwnsGamePassAsync`. Si alguien compra el horno instantáneo teniendo ya un horno industrial, recibe el valor del horno en efectivo.
- Tutorial: 4 pasos contextuales (aceptar pedido, hornear, decorar y entregar, deuda y estafas) que se completan al detectar la acción en el estado replicado, se pueden omitir y se ocultan fuera del Modo Diario. Se muestra abajo al centro, detrás de los modales.

Ajustes de la fase 8
- La insignia de modo del HUD muestra solo el nombre del modo, sin repetir la palabra "Mode".
- La prueba de refrigerador era intermitente porque el horno básico se avería al azar a partir del desgaste 3; ahora la prueba reinicia el desgaste en cada vuelta. No era un fallo del producto.

## 3. Cómo probar el juego paso a paso

Preparación: abrir el lugar en Studio y pulsar Play. Saltar o leer la introducción. Con la guía rápida activa se muestra el paso en el que estás.

Modo Diario
1. Orders: esperar a un cliente (llega en unos segundos) y aceptar su pedido.
2. Supplies: comprar los insumos que falten. Con la estación de preparación, dosificar relleno, crema y toppings y empezar a hornear en el horno. Esperar la barra de progreso y retirar el bizcocho.
3. Llevar el bizcocho a la mesa de preparación y decorar: cortar, rellenar y apilar, cubrir con la base giratoria, trazar con la manga y colocar toppings. Entregar y revisar el resultado (precisión, pago, propina, reputación).
4. Social: publicar el pastel, revisar las reseñas y abrir un encargo digital. Para distinguir una estafa, inspeccionar el comprobante (remitente, monto, referencia) antes de aceptar.
5. Finance: abonar a la deuda. Al terminar la jornada (300 segundos) se muestra el resumen con intereses de 8 % si no hubo abono mínimo de $25.
6. Finance, mejoras: comprar Expertise o Marketing, el horno industrial (exige deuda en cero), el refrigerador, el local comercial y el personal. Revisar los cambios en el mundo.

Modo Creativo: botón Modes, elegir pisos, sabor y relleno, pulsar Start Creating y decorar con todo ilimitado. Leave vuelve al mundo. El reloj queda en pausa.

Modo Competitivo: botón Modes, Start Run. Se muestra la barra superior con ronda, tiempo y puntaje. Completar las 3 rondas para ver el resumen con el récord personal. Con el lugar publicado, el Top 10 aparece en la tarjeta del modo.

Cambio de modo: probar volver a Daily desde cada modo, y que con un pedido ya en el horno el cambio se rechaza con un aviso.

Pruebas automáticas (solo en Studio): `ServerStorage.QA_Run` ejecuta las pruebas con `Invoke("test", "nombre")` para `datastore`, `economy`, `orders`, `inventory`, `baking`, `decorating`, `social`, `progression`, `fridge`, `modes`, `competitive` y `monetization`.

## 4. Riesgos conocidos y pendientes

- El DataStore real (perfil y ranking global) no se pudo verificar porque el lugar no está publicado. Su lógica está probada con almacenes simulados en memoria. Conviene probar una partida real tras publicar: guardar, salir, volver a entrar y ver el Top 10.
- Las compras con Robux no se pudieron probar de punta a punta (todos los IDs están en 0). La lógica de recibos, idempotencia y fallos de guardado está probada con recibos simulados.
- No se probó entrada táctil real ni el emulador móvil. La escala de la interfaz (`UIScale` con mínimos de 0.7 en PC y 0.8 en táctil) y los modales (96 % x 92 % con tope en píxeles) están pensados para pantallas pequeñas, pero conviene revisar corte, base giratoria y manga con el emulador de Studio.
- El texto de los `BillboardGui` del mundo (carteles de clientes y del puesto) no se ve en las capturas de Studio, así que no se pudo validar visualmente.
- Solo se hizo una pasada visual con una ventana de tamaño de portátil.
- `MaxPlayers` sigue en 30 en el lugar; hay que ponerlo en 1 (ver checklist).
- El tiempo límite del modo Competitivo (360 s) y el bono de velocidad son valores de balance iniciales: conviene ajustarlos con jugadores reales en `Config/Constants`.
- El audio funciona por claves de `Config/Assets` y todas están vacías: el juego es silencioso hasta que se pegue algún ID de sonido, y no genera errores mientras estén vacías. Tampoco hay íconos personalizados.

## 5. Checklist de publicación

- [ ] Revisar y guardar copia de seguridad del `.rbxl` (el estado actual está en el Studio abierto: guardar con `File > Save`).
- [ ] Configurar `Game Settings > Places > MaxPlayers = 1` y habilitar `Enable Studio Access to API Services` en `Security`.
- [ ] Crear en Creator Hub los Game Passes `DoubleEarnings` y `VIPPastryPack` y los Developer Products `InstantIndustrialOven` y `StarterCashPack`, y pegar sus IDs en `ReplicatedStorage/Shared/Config/Monetization` (opcional para publicar).
- [ ] Completar `Config/Assets` si se desean audios o íconos personalizados adicionales.
- [ ] Probar en el emulador móvil de Roblox Studio (especialmente corte, base giratoria y manga táctil).
- [ ] Completar el cuestionario de clasificación de contenido, nombre y descripción en inglés, y publicar con `File > Publish to Roblox`.
- [ ] Tras publicar, jugar una sesión real para validar guardado, ranking global y compras.

Sugerencia para la página de Roblox

- Título: Baking From Scratch
- Descripción: Start with $25 and a $500 oven debt in your family's backyard. Take orders from the neighbors, bake from scratch and decorate every cake by hand: cut, fill, frost on the turntable, pipe and top. Spot scam orders before they cost you, pay off your debt, grow from a backyard stand to a full bakery with staff and a commercial kitchen, relax in Creative Mode or race the clock in Competitive Mode.
- Tags sugeridos: tycoon, simulator, bakery, cooking, cake, single player, relaxing, creative, business, decorating
