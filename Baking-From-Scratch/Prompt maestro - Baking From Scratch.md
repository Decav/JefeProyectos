# Prompt Maestro — Baking From Scratch (Roblox)

**Instrucción de uso:** Copia desde la Sección 1 hasta el final del documento y pégalo como un único prompt maestro en tu agente de desarrollo (Claude / Antigravity) conectado a **Roblox Studio por MCP**.

---

## 1. Rol, Objetivo y Modo de Trabajo

Eres un equipo completo de desarrollo de videojuegos para Roblox: arquitecto Luau senior, diseñador de sistemas económicos, diseñador de UI/UX, level designer, técnico de VFX/audio y productor. Vas a construir **Baking From Scratch** desde cero hasta dejar una versión jugable completa y verificada en **Roblox Studio**, usando únicamente esta especificación.

**Objetivo:** Construir un simulador single-player de pastelería y emprendimiento en Roblox jugable de principio a fin: inicio precario en el patio familiar con deuda del horno, compra y dosificación de insumos, horneado, decoración táctil interactiva (corte, relleno, base giratoria, manga pastelera y toppings), entrega con evaluación y reseñas en redes sociales, detección de estafas financieras, progresión hacia horno industrial, local comercial, personal, refrigerador con perecederos y modos Creativo / Competitivo.

La prioridad es llegar a un juego **funcional, estable y divertido de punta a punta**. Un sistema claro que funciona sin errores vale más que uno sobredimensionado a medio terminar.

### Reglas de Ejecución Autónoma (1 Solo Prompt)

1. **Ejecución continua por fases:** Trabaja siguiendo el Plan de Fases (Sección 11) en orden estricto (`Fase 0` hasta `Fase 8`). **No te detengas entre fases a pedir confirmación** salvo que te quedes sin turnos/contexto o encuentres un bloqueo real del entorno que no admita default. Al terminar cada fase, ejecuta su prueba en Studio, corrige errores y continúa inmediatamente con la fase siguiente.
2. **Decisiones autónomas:** Toda decisión técnica, visual o de balance no cubierta explícitamente aquí la decides tú aplicando el criterio más simple y robusto, y la registras en un historial breve (`DECISIONES` en el resumen final).
3. **Cero código incompleto:** Nunca escribas `...`, `-- resto del código`, `TODO` ni placeholders en lugar de lógica real.
4. **Idioma:**
   - Todos los textos visibles para el jugador dentro del juego van en **inglés (`en`)** como idioma base, centralizados en un módulo `Localization` / `Strings` con estructura lista para traducir a español (`es`) y otros idiomas.
   - Tus explicaciones al usuario, comentarios de código y registro de decisiones van en **español**.
5. **Originalidad y cumplimiento:** Usa nombres, marcas ficticias y diseños propios. Contenido apto para todo público (sin violencia ni elementos inapropiados).

### Modo de Trabajo Obligatorio: Roblox Studio vía MCP

1. **Verificación inicial de herramientas:** Al iniciar, inspecciona qué herramientas del MCP de Roblox Studio tienes disponibles (lectura/escritura de scripts, exploración del árbol del juego, ejecución de Luau en Edit/Client/Server, creación de instancias, búsqueda e inserción de assets del Creator Store, `start_stop_play`, captura de pantalla / viewport, lectura de consola). Si alguna herramienta de Studio no responde, repórtalo brevemente; si el entorno MCP está activo, crea todo directamente en el lugar abierto de Studio (no le pidas al usuario copiar y pegar scripts).
2. **Construcción directa en Studio:** Crea tú las carpetas, `Script`, `LocalScript`, `ModuleScript`, `RemoteEvent`, `RemoteFunction`, modelos del mundo y configuraciones en el DataModel de Studio.
3. **Verificación real en cada fase:** Al concluir cada fase, inicia playtest (`start_stop_play`), lee `get_console_output` y valida con `screen_capture` que la escena, la estación de decoración y la UI se ven correctamente y sin errores ni warnings críticos. Corrige cualquier fallo antes de pasar a la siguiente fase.
4. **Uso responsable del Toolbox (si se usa):** Puedes usar geometría generada por código (opción preferida por estabilidad) y complementar con props gratuitos del Creator Store solo si los inspeccionas: elimina obligatoriamente cualquier `Script`, `LocalScript` o `ModuleScript` dentro de modelos insertados y conserva únicamente `BasePart`, `MeshPart`, `Model`, `SurfaceAppearance` o `Decal`. Almacena copias limpias en `ServerStorage/Assets` con respaldo por código si faltan.
5. **Mínima carga para el usuario:** Al terminar todo el desarrollo, entrega únicamente las tareas que dependen de la cuenta del usuario en Roblox Creator Hub (publicar lugar, habilitar API Services para DataStore, crear IDs reales de Monetización y completar cuestionario de edad).

---

## 2. Restricciones Técnicas de Roblox

- **Construcción integral por código / Studio:** El proyecto debe funcionar al 100 % sin exigir que el usuario suba imágenes ni audios manualmente.
- **Mundo y props:** Patio familiar, puesto improvisado (tablas y cajas recicladas), cocina interior, hornos, mesa de corte/decoración, base giratoria, vitrinas y local comercial se construyen con `Part` (`Block`, `Cylinder`, `Wedge`, `Ball`), `UnionOperation` opcional o modelos simples, materiales (`Wood`, `WoodPlanks`, `Metal`, `SmoothPlastic`, `Tile`, `Brick`, `Glass`, `Neon`) y paleta definida en `Config/Theme`.
- **UI íntegramente programática:** Toda la interfaz se genera por código desde `LocalScript` usando un sistema de componentes reutilizables (`UI/Components`) con `UICorner`, `UIStroke`, `UIGradient`, `UIListLayout`, `UIScale` y `TweenService`. No dependas de ScreenGuis prearmados manualmente salvo contenedores base si hiciera falta.
- **Cero emojis ni dependencias externas:** No uses emojis en UI ni en documentación (usa formas geométricas, barras de progreso, texto limpio e iconos vectoriales/compuestos por frames o etiquetas claras como `[CASH]`, `[DEBT]`, `[STAR]`). Sin Wally, sin Rojo obligatorio, sin librerías externas ni `HttpService` externo. Escribe tu propio wrapper robusto de `DataStore`.
- **APIs modernas de Luau:** Usa `task.wait`, `task.spawn`, `task.delay`, `Workspace:Raycast`, `CollectionService`, `TweenService`, `ProximityPrompt`, `UserInputService`, `LocalizationService` / tabla propia de traducción, y `LinearVelocity`/`AlignPosition` en vez de APIs deprecadas (`BodyVelocity`, `wait`, `spawn`, `FindPartOnRay`).
- **Single-player con autoridad de servidor:** El juego corre como experiencia **single-player** (`MaxPlayers = 1` en configuración recomendada del Place), pero **el servidor sigue siendo la autoridad absoluta** de inventario, dinero, deuda, recetas, puntuación de decoración, fraude y persistencia. El cliente solo envía intenciones y renderiza interfaz/previsualización local.
- **Sin `StreamingEnabled` en la versión inicial** para garantizar que patio, cocina y estación de decoración estén siempre cargados sin demoras ni referencias `nil`.

---

## 3. Identidad y Bucle Principal de Baking From Scratch

**Concepto:** Simulador narrativo de emprendimiento pastelero. El jugador comienza quebrado, usando sus últimos ahorros en utensilios mínimos y contrayendo una deuda obligatoria para comprar un horno doméstico pequeño. Opera primero desde un puesto improvisado con cajas y tablas en el patio de su casa y cocina en el interior familiar, luchando contra los intereses de la deuda, la escasez de ingredientes, averías y estafadores en redes sociales, hasta escalar a hornos industriales, local comercial propio, empleados y pastelería de alta gama.

### Modos de Juego

1. **Daily Mode (Historia — Core principal):** Progresión completa desde Etapa 1 (patio) hasta Etapa 4 (cadena/local expandido), con deuda, inventario, redes sociales, estafas y mejoras.
2. **Creative Mode (Fase 7):** Espacio libre para hornear y decorar pasteles de 1 a 3 pisos con ingredientes, colores, boquillas y toppings ilimitados, sin dinero ni reloj.
3. **Competitive Mode (Fase 7):** Desafío contrarreloj por rondas (ej. 3 pedidos encadenados en tiempo límite) evaluando velocidad y precisión decorativa, registrando puntaje máximo en `OrderedDataStore` global (`CompetitiveBest`).

### Bucle Operativo de Daily Mode

```text
[1. Recibir Encargo (Patio o RRSS)]
        -> [2. Revisar Stock y Dosificar Ingredientes]
        -> [3. Hornear Bizcocho]
        -> [4. Decorar en Mesa (Corte -> Relleno/Apilado -> Base Giratoria -> Manga -> Toppings)]
        -> [5. Entregar, Evaluar Calidad, Cobrar / Reseña RRSS / Amortizar Deuda]
        -> [6. Reponer Insumos, Mejorar Expertise/Equipo y Escalar Negocio]
```

---

## 4. Arquitectura Técnica del Proyecto (Studio DataModel)

Usa esta jerarquía exacta dentro de Roblox Studio:

```text
ReplicatedStorage
  Shared
    Config
      Constants        -- tiempos, límites de partes, duración de día, umbrales de precisión
      Recipes          -- sabores de bizcocho, rellenos, tamaños/pisos, tiempos de horneado
      Ingredients      -- catálogo de insumos, unidades (kg / u), precios de compra, calidad estándar vs VIP
      Upgrades         -- mejoras (Expertise, Marketing, Horno Industrial, Refrigerador, Local, Empleados)
      Economy          -- deuda inicial, tasas de interés, costos operativos, rescates anti-softlock
      Monetization     -- IDs de Game Passes / Developer Products (en 0 por defecto)
      Assets           -- claves de sonidos/imágenes opcionales (vacíos por defecto + rbxasset seguros)
      Localization     -- diccionario multi-idioma (en base + es completo)
      Theme            -- paleta cálida pastelera + UI financiera clara, tipografías y tamaños
    Util
      Signal, Maid, Format (dinero/tiempo), MathUtil, LocalizationUtil
  Remotes              -- RemoteEvent y RemoteFunction creados por Server al arrancar

ServerScriptService
  Server (Script)      -- punto de entrada: crea Remotes, inicia servicios (Init -> Start) y construye mundo
    Services
      DataService          -- wrapper DataStore (UpdateAsync, retry con backoff, autosave 60s, BindToClose)
      EconomyService       -- caja, pagos, reembolsos, deuda del horno, intereses, mora y rescate anti-quiebra
      InventoryService     -- stock de ingredientes, compra de reposición, consumo atómico, refrigerador/perecederos
      OrderService         -- generación de pedidos (vecinos etapa 1, RRSS, VIP), aceptación/rechazo, reputación
      BakingService        -- estaciones de horno, timers de cocción, averías mecánicas y reparación
      DecoratingService    -- validación de sesión de decoración y cálculo autoritativo de precisión (0..100 %)
      SocialService        -- perfiles ficticios, feed de publicaciones, reseñas con estrellas y detección de estafas
      ProgressionService   -- Expertise, Marketing, desbloqueos de etapa, Horno Industrial, arriendo y empleados
      CompetitiveService   -- lógica de partidas contrarreloj y OrderedDataStore de ranking global
      MonetizationService  -- ProcessReceipt, GamePasses (ignora IDs en 0)
      AnalyticsService     -- registro estructurado en consola/AnalyticsService de eventos clave
    World
      WorldBuilder         -- construye Etapa 1 (Patio + Cocina) y habilita expansiones según etapa del perfil
      NPCManager           -- clientes en cola en el patio, diálogos simples y empleados contratados (Recepción/Mezcla)
      Cake3DBuilder        -- utilidades compartidas para ensamblar representación 3D del pastel terminado/en mesa

StarterPlayer
  StarterPlayerScripts
    Client (LocalScript)   -- punto de entrada cliente
      Controllers
        UIController       -- gestión de pantallas, notificaciones, idioma activo
        CameraController   -- transición suave entre cámara libre y vistas fijas de estación (Mesa de Corte/Decoración)
        DecoratingController -- interacción táctil/ratón para corte, espátula, base giratoria, manga y toppings
        AudioController    -- reproducción segura por clave en Config/Assets y volumen de ajustes
        TutorialController -- guía contextual inicial de 4 pasos
      UI
        Components         -- botones, tarjetas, modales, barras de progreso, tooltips, badges
        Screens
          HUD              -- efectivo, deuda del horno, día/reloj, reputación, nivel de negocio, botones de acceso
          OrderModal       -- aceptar/rechazar encargo presencial, requisitos visuales
          SupplyShop       -- compra rápida de insumos con precios y stock actual
          IngredientPrep   -- interfaz ágil de dosificación por receta con botones e inventario en vivo
          DecoratingHUD    -- barra de subfases (Cut -> Fill -> Frost -> Pipe -> Toppings), selector de color/boquilla/toppings
          SocialTerminal   -- feed de RRSS, publicar foto, reseñas, bandeja de encargos digitales y verificador de estafas
          FinanceDebt      -- estado de deuda, pago de capital, intereses acumulados, costos operativos y mejoras/arriendo
          ModeSelect       -- selector Daily / Creative / Competitive y leaderboard competitivo
          Settings         -- idioma (EN / ES), volumen música/SFX, sensibilidad de decoración
```

### Reglas de Arquitectura y Remotes

- Todos los servicios implementan `Init()` y `Start()`.
- La copia del perfil del jugador se replica al cliente mediante `ProfileUpdated` (`RemoteEvent`, solo lectura) y `Attributes` en `Player` (`Cash`, `Debt`, `Reputation`, `Stage`, `Day`).
- Toda sesión/listener temporal se registra con `Maid` para evitar fugas de memoria al reiniciar rondas o cambiar de modo.
- Validación obligatoria en servidor para todos los `RemoteEvent` / `RemoteFunction`:
  - `AcceptOrder(orderId)` / `RejectOrder(orderId)`
  - `BuyIngredient(ingredientId, qty)`
  - `StartMixAndBake(orderId, selectedIngredients)`
  - `SubmitDecoratingStep(orderId, stepData)` / `FinishCakeAndDeliver(orderId, finalMetrics)`
  - `PayDebt(amount)` / `RepairOven()`
  - `PublishPost(cakeSummaryId)` / `InspectScamOrder(orderId, decision)` (`"ACCEPT"` | `"REJECT_SCAM"`)
  - `BuyUpgrade(upgradeId)` / `ToggleEmployee(roleId)`
  - `StoreInFridge(flavor)` / `DiscardSpoiled(slotId)`
  - `SwitchMode(modeName)` / `StartCompetitiveRun()` / `SetLanguage(langCode)`

---

## 5. Esquema de Datos Persistentes (`DataStore: BakingFromScratch_v1`)

Clave: `Player_<UserId>`. Si la carga falla tras reintentos (`pcall` + backoff), el jugador entra en modo temporal con aviso visible y **nunca se sobrescribe un perfil guardado real con datos vacíos**.

```lua
{
  version = 1,
  modeUnlocked = { Daily = true, Creative = true, Competitive = true },
  stage = 1, -- 1: Patio, 2: Horno Industrial (transición), 3: Local Arrendado, 4: Planta Expandida/Cadena
  cash = 25, -- ahorros casi agotados al empezar
  debt = 500, -- deuda inicial obligatoria del horno pequeño
  debtInterestAccrued = 0,
  missedPayments = 0,
  day = 1,
  dayElapsed = 0,
  reputation = 3.0, -- 0.0 a 5.0
  consecutiveRejects = 0,
  expertise = 0, -- XP de habilidad técnica (reduce tiempo de elaboración)
  marketing = 0, -- alcance de marca (aumenta flujo/calidad de pedidos RRSS)
  unlockedRecipes = { Vanilla = true, Chocolate = true },
  inventory = {
    Flour = 4, -- kg
    Sugar = 3, -- kg
    Eggs = 12, -- u
    DulceDeLeche = 6, -- u (Manjar)
    Chocolate = 4, -- u
    Vanilla = 4, -- u
    Peach = 0,
    Blackberry = 0,
    Cream = 6,
    Candles = 4,
    Fruits = 4,
  },
  equipment = {
    ovenTier = 1, -- 1: Pequeño (1 piso, lento, se avería), 2: Industrial (multipiso), 3: Doble Industrial
    ovenBroken = false,
    ovenWear = 0,
    hasFridge = false,
    fridgeSlots = {}, -- { id, flavor, bakedAtDay, spoiled }
    hasShopLease = false,
    plantExpansions = 0,
  },
  staff = {
    receptionCount = 0,
    mixingCount = 0,
  },
  social = {
    handle = "@MyFirstBakery",
    followers = 15,
    posts = {}, -- historial acotado (máx. 20 últimos)
    reviews = {}, -- historial acotado (máx. 20 últimos)
  },
  stats = {
    ordersCompleted = 0,
    ordersPartial = 0,
    ordersFailed = 0,
    scamsAvoided = 0,
    scamsFallen = 0,
    competitiveBestScore = 0,
  },
  receipts = {}, -- purchaseIds de MonetizationService
  settings = { language = "en", music = 0.5, sfx = 0.8 },
}
```

---

## 6. Mecánicas Centrales y Reglas de Balance

### 6.1 Estado Inicial y Narrativa de Apertura (Etapa 1)

- Al iniciar partida nueva por primera vez, mostrar un breve panel introductorio (3 tarjetas rápidas saltables en 1 clic):
  1. Invertiste tus últimos ahorros en utensilios e insumos básicos (`$25` restantes en caja).
  2. Recolectaste cajas y madera para armar un puesto improvisado en el patio de tu casa.
  3. Tomaste un crédito obligatorio de `$500` para comprar el horno más pequeño (solo 1 piso, cocción lenta).
- Posicionamiento inicial en perfil RRSS: `#SelfMade` `#Entrepreneur` `#SmallBusiness` (y en localización `es`: `#SoyMiPropioJefe` `#Emprendedor` `#Pyme`).
- **Regla Anti-Softlock:** Si en algún momento el jugador tiene efectivo insuficiente para comprar al menos 1 tanda mínima de ingredientes y no tiene pedidos en curso, el sistema habilita un botón visible **"Micro-Supplier Credit (+Ingredients / +$35 Debt)"** para que la partida jamás quede bloqueada.

### 6.2 Flujo Operativo Paso a Paso

#### Paso 1: Recepción del Encargo (Patio y RRSS)
- **Etapa 1 (Clientela cercana):** Clientes NPC representan familiares, vecinas y amigas de la madre (`Aunt Clara`, `Neighbor Mrs. Elena`, `Mom's Friend Martha`, etc.) acercándose al puesto del patio con pedidos de **1 piso** (pequeños / 5 porciones).
- **Parámetros de cada pedido:**
  - `flavor`: bizcocho solicitado (`Vanilla`, `Chocolate`, etc.).
  - `filling`: relleno solicitado (`DulceDeLeche`, `Chocolate`, `Peach`, `Blackberry`).
  - `tiers`: número de pisos (`1` en Etapa 1; `2..3` tras desbloquear Horno Industrial / Local).
  - `frostingColor`: color objetivo de cobertura (hex/nombre).
  - `pipingStyle`: boquilla/patrón solicitado (`Star`, `Round`, `Ribbon`, `Rosette`).
  - `toppings`: lista exacta (ej. `{ Candles = 2, Fruits = 3 }`).
  - `basePrice`: pago base y tiempo sugerido.
- **Penalización por rechazo:** Aceptar o rechazar pedido. Rechazar `3+` pedidos seguidos resta `-0.15` de reputación por cada rechazo adicional (mínimo `0.5`).

#### Paso 2: Dosificación e Ingredientes (Cocina)
- Al seleccionar un pedido aceptado para cocinar, se abre `IngredientPrep`:
  - Muestra la receta requerida (ej. `Flour: 1`, `Sugar: 1`, `Eggs: 3`, `Vanilla: 1`, `Cream: 1`, `DulceDeLeche: 1`, más toppings).
  - Muestra el stock disponible en tiempo real con código de color (verde suficiente / rojo faltante).
  - Botones interactivos para dosificar cada ingrediente (descuenta del inventario al confirmar inicio de mezcla/horneado).
  - Si falta algún ingrediente secundario (ej. relleno o fruta en etapa temprana), el jugador puede continuar con **sustitución o sin ese elemento**, lo cual afectará el porcentaje final de precisión (cumplimiento parcial en lugar de bloqueo duro, reflejando fielmente la limitación temprana del GDD).
- Si se contrató **Personal de Mezcla**, la dosificación básica se acelera o pre-carga automáticamente con 1 clic.

#### Paso 3: Horneado y Refrigeración
- **Horneado:** El bizcocho entra al horno. Duración base Etapa 1: `18 s` (reducida progresivamente por `Expertise` hasta `-45 %`, y drásticamente más rápida en `Horno Industrial`).
- **Averías mecánicas:** Cada horneado aumenta `ovenWear`. Al superar umbral (o baja probabilidad tras uso intensivo en horno tier 1), el horno sufre avería (`ovenBroken = true`, humo/chispas en el modelo 3D) y exige reparación (`$45`; si no hay efectivo, se carga a la deuda + recargo).
- **Refrigerador Comercial (Etapa 2+):** Permite guardar bizcochos horneados previamente para despachar más rápido. Cada bizcocho guardado guarda `bakedAtDay`. Si supera `2 días` de juego almacenado sin usarse, pasa a `spoiled = true`: cambia de color a verdoso, emite partículas de moscas (`ParticleEmitter` oscuro) y solo puede descartarse.

#### Paso 4: Estación de Decoración 3D (Mecánica Core)
Al sacar el bizcocho del horno y llevarlo a la **Mesa de Decoración**, la cámara cambia suavemente (`CameraController`) a una vista ergonómica enfocada sobre el pastel en la base giratoria, activando `DecoratingHUD`. Todo debe funcionar con **ratón y toque (móvil)**:

1. **Subfase 1 — Corte del bizcocho (`Cut`):**
   - El bizcocho aparece sobre la base. Se muestra una línea guía horizontal en la mitad de su altura (o dos líneas si es multipiso).
   - El jugador desliza el cuchillo virtual horizontalmente cruzando el bizcocho (`PointerDown` + arrastre horizontal).
   - Se mide la desviación vertical respecto a la guía (`cutScore: 0..100`) y el bizcocho se separa visualmente en capa inferior y superior.
2. **Subfase 2 — Relleno y apilado (`Fill`):**
   - La capa superior se aparta lateralmente en la mesa dejando expuesta la cara interna.
   - El jugador elige el relleno en la barra inferior y arrastra la espátula sobre la cara superior de la base (dividida lógicamente en sectores/cuadrícula circular de cobertura). Cada sector tocado muestra una capa 3D del color del relleno elegido.
   - Al completar o pulsar `Stack Layer`, la capa superior desciende con tween sobre el relleno.
3. **Subfase 3a — Cubrimiento en base giratoria (`Frost`):**
   - El pastel ensamblado queda sobre la **base giratoria (`Turntable`)**.
   - Un botón/control gira la base (rotación continua configurable o botón `Spin` + arrastre de espátula sobre el pastel).
   - A medida que la espátula pasa por los sectores radiales (ej. 12 segmentos laterales + tapa superior), estos se recubren con crema del color elegido. Se muestra porcentaje cubierto en vivo (`0..100 %`).
4. **Subfase 3b — Manga pastelera (`Pipe`):**
   - El jugador selecciona boquilla (`Star`, `Round`, `Ribbon`, `Rosette`) y color.
   - Al arrastrar el puntero sobre la superficie superior del pastel (`Workspace:Raycast` contra la tapa del pastel), se colocan nodos decorativos 3D con forma acorde a la boquilla elegida (límite técnico: máximo 80 nodos por pastel para mantener 60 FPS en móvil).
   - Se evalúa presencia de trazado, coincidencia de boquilla y coincidencia de color.
5. **Subfase 3c — Toppings finales (`Toppings`):**
   - El jugador selecciona vela estándar, vela numérica o fruta (`Pineapple`, `Cherry`) y hace clic/toca sobre la tapa del pastel para posicionarla (`Raycast` validado dentro del radio del bizcocho).
   - Al pulsar `Finish Cake`, el pastel completo se empaqueta en una caja abierta/vitrina y el jugador regresa al puesto de entrega.

#### Paso 5: Evaluación, Cobro y Reseñas
- **Fórmula transparente de Precisión (`accuracy: 0..100`):**
  - Coincidencia de sabor bizcocho + relleno: `30 %`
  - Precisión de corte horizontal: `15 %`
  - Porcentaje de cobertura en base giratoria + color correcto: `25 %`
  - Manga pastelera (boquilla + color + trazado suficiente): `15 %`
  - Toppings exactos dentro del área del pastel: `15 %`
- **Resultado económico:**
  - **Cumplido (`accuracy >= 80 %`):** `100 %` del precio del pedido + propina (`floor(basePrice * (accuracy - 75) / 100)`), `+0.1` reputación, `+15` Expertise.
  - **Parcial (`45 % <= accuracy < 80 %`):** Pago reducido (`floor(basePrice * (accuracy / 100) * 0.75)`), reputación neutra o `-0.05`, `+8` Expertise.
  - **Incumplido (`accuracy < 45 %`):** `$0` de pago, reembolso obligatorio al cliente (`-floor(basePrice * 0.5)` o todo el efectivo disponible; si no alcanza, la diferencia se suma automáticamente a `debt`), `-0.25` reputación.

---

## 7. Economía, Deuda del Horno, RRSS y Estafas

### 7.1 Sistema de Deuda e Intereses
- **Ciclo diario:** `1 día = 300 segundos` (`5 minutos`), con iluminación ambiental que refleja mañana/tarde/cierre de jornada y resumen de fin de día (`End of Day Summary`).
- **Interés automático:** Si al cierre del día el jugador no realizó ningún abono a la deuda durante ese día (o su deuda sigue activa sin pago mínimo de `$25`), la deuda aumenta un **`+8 %`** (redondeado hacia arriba).
- **Pago manual:** En `FinanceDebt`, el jugador puede abonar montos flexibles (`$25`, `$50`, `$100`, `Pay All`).
- **Costo operativo:** En Etapa 1 (patio familiar) es simbólico/bajo (`$15/día` por luz/gas); al arrendar Local Comercial pasa a arriendo diario (`$120/día`) + sueldos de empleados contratados (`$40/día` por empleado). Si no alcanza el efectivo al cierre del día, el déficit se suma a la deuda con recargo por mora (`missedPayments += 1`), bloqueando la transición al siguiente nivel de local hasta ponerse al día.

### 7.2 Terminal de Redes Sociales (RRSS) y Marketing
- **Publicar creaciones:** Tras terminar un pastel, aparece opción de **"Take Photo & Post"** (genera publicación en el feed con nombre del pastel, precisión obtenida, hashtags de etapa y ganancia de `followers` + `marketing`).
- **Reseñas públicas:** Parte de los pedidos completados generan automáticamente una reseña en el feed con estrellas (`1..5`), comentario dinámico según los aciertos/fallos del pastel (ej. cobertura incompleta, relleno faltante, excelencia decorativa) y datos del cliente.
- **Encargos digitales:** A mayor `marketing` y `followers`, llegan mejores pedidos a la bandeja de RRSS (pagos superiores a los vecinos de Etapa 1).

### 7.3 Mecánica de Fraude Financiero (Solo Pedidos RRSS)
- Un porcentaje configurable (~`20 %`) de los pedidos que llegan por RRSS son intentos de estafa.
- **Indicador de riesgo:** Suelen ofrecer un pago anormalmente alto por un pastel sencillo (ej. `$300` por un pastel básico de 1 piso) y adjuntan un **comprobante de transferencia (`Transfer Receipt`)** falsificado.
- **Flujo de verificación en `SocialTerminal`:**
  - Al abrir un pedido de RRSS, se muestra la ficha del pedido junto al comprobante adjunto (`Sender Name`, `Amount`, `Reference ID`, `Status`, `Timestamp`).
  - Las estafas presentan al menos **2 inconsistencias detectables** por el jugador (ej. `Sender Name` distinto al cliente del chat, `Amount` no coincide con el pedido, `Reference ID` marcado como `INVALID / DUPLICATE`, o `Status: PENDING - UNVERIFIED`).
  - Acciones: **`Accept Order & Payment`** vs **`Report Scam`**.
  - Si acepta una estafa: cocina y entrega normalmente, pero al cobrar el banco rechaza la transferencia (`+$0` recibidos, pérdida total de los insumos gastados y notificación de estafa sufrida).
  - Si reporta correctamente una estafa: no pierde reputación, gana `+1` en `scamsAvoided` y un pequeño bono de seguridad/confianza. (Si reporta como estafa un pedido legítimo, simplemente lo rechaza como pedido normal).

---

## 8. Progresión, Contratación y Escalabilidad

| Hito / Mejora | Costo / Requisito | Efecto en Juego |
| :--- | :--- | :--- |
| **Expertise Training** (niveles 1..10) | Dinero + XP acumulado | Reduce tiempo de horneado y aumenta tolerancia en corte/piping. |
| **Marketing Boost / Branding** | Dinero + Publicaciones | Aumenta seguidores, frecuencia de pedidos RRSS y propinas. |
| **Industrial Oven** (Hito Etapa 2) | `$1,200` y `debt == 0` (o salto anticipado con **Robux**) | Habilita pasteles de **2 y 3 pisos**, reduce tiempo de cocción a la mitad y elimina averías frecuentes. |
| **Commercial Fridge** | `$450` | Almacena hasta 6 bizcochos pre-horneados (caducan a los 2 días -> moscas). |
| **Commercial Shop Lease** (Etapa 3) | `$2,000` + `ovenTier >= 2` + `missedPayments == 0` | Traslada/actualiza el negocio del patio familiar a un **Local Comercial** propio con vitrina, mayor flujo y clientela VIP. |
| **Reception Staff** (hasta 3) | `$300` contratación + `$40/día` | Cobra y atiende automáticamente pedidos presenciales sencillos en mostrador (generando ingreso pasivo activo mientras decoras). |
| **Mixing Staff** (hasta 3) | `$350` contratación + `$40/día` | Pre-prepara masas base y agiliza el Paso 2 de dosificación. |
| **Plant Expansion / VIP Supply** (Etapa 4) | `$4,500+` | Habilita estaciones extra, ingredientes premium de alto margen y pedidos VIP de alta complejidad. |

---

## 9. Escenario 3D, UI/UX y Estética

### 9.1 Escenario Construido por Código (`WorldBuilder`)
- **Etapa 1 (Patio + Cocina Familiar):**
  - Suelo de césped/tierra con sendero de losas hacia una pequeña casa familiar de paredes cálidas (`Brick` / `SmoothPlastic`), techo a dos aguas (`Wedge`), iluminación acogedora (`Atmosphere`, luz solar cálida).
  - **Patio (Atención):** Puesto improvisado construido visiblemente con tablas recicladas (`WoodPlanks`) y cajas apiladas, cartel escrito a mano (`SurfaceGui`: `"Baking From Scratch - Homemade Cakes"`), caja metálica para efectivo, punto de spawn de clientes NPC en cola y terminal/laptop sobre una caja para RRSS e insumos.
  - **Cocina Interior:** Conectada por puerta abierta desde el patio; mesón de cocina, **Horno Pequeño** (con puerta transparente, luz naranja interior encendida al hornear y humo si está averiado), **Mesa de Preparación** (con `ProximityPrompt` para abrir dosificación/decoración) y espacio reservado para el **Refrigerador Comercial** al comprarlo.
- **Etapa 3+ (Local Comercial):** Al desbloquear el arriendo, el entorno se transforma/habilita el local comercial en la parcela frontal (piso ajedrezado, vitrina de vidrio para exhibición de pasteles, mostrador profesional, carteles luminosos y puestos para empleados).

### 9.2 Estilo Visual de UI (`Config/Theme`)
- Estética **Warm Bakery / Cozy Tycoon**: crema suave `#FFF8EE`, marrón chocolate `#3D251E` para textos/bordes, rosa pastel `#FF6B8B` (acción principal), dorado caramelo `#F4A236` (monedas/progreso), verde menta `#2ECC71` (éxito), rojo coral `#E74C3C` (deuda/alerta/estafa).
- Botones amplios (`>= 44 px` en móvil), `UIScale` adaptable, tipografía `FredokaOne` / `GothamBold` para títulos y `Gotham` para cuerpo.
- **HUD limpio:** Arriba izquierda: Efectivo, Deuda del Horno (con barra/indicador de mora), Día y reloj de jornada, Reputación. Arriba derecha: Botones compactos (`Orders`, `Supplies`, `Social`, `Finance`, `Modes`, `Settings`). Durante la decoración, el HUD general se oculta/minimiza para no estorbar el área táctil del pastel.

### 9.3 Audio y VFX Seguros
- `AudioController` centralizado: usa solo rutas `rbxasset://sounds/...` verificadas si las hay o falla en silencio sin errores cuando las claves de `Config/Assets` estén vacías `""`.
- VFX por código: humo/chispas en horno averiado, vapor/brillo al sacar bizcocho horneado, partículas de moscas en bizcocho podrido en refrigerador, confeti al lograr pedido 100 % o pagar toda la deuda.

---

## 10. Monetización (Opcional / Segura con IDs en `0`)

Dejar toda la integración implementada en `MonetizationService` y `Config/Monetization` con IDs iniciales en `0`. Si un ID es `0`, su botón de compra con Robux se oculta limpiamente (o muestra `"Coming Soon"` deshabilitado) sin generar errores ni advertencias de `MarketplaceService`.

| Producto | Tipo | Efecto |
| :--- | :--- | :--- |
| **Instant Industrial Oven** | Developer Product / Game Pass | Salta la espera económica de Etapa 1 y desbloquea inmediatamente `ovenTier = 2` (Horno Industrial). |
| **2x Earnings & Tips** | Game Pass | Duplica las ganancias y propinas por pedido en Daily Mode. |
| **Starter Cash Pack / Bakery Grant** | Developer Product | Inyección de capital para salir de deuda o financiar local. |
| **VIP Pastry Pack** | Game Pass | Desbloquea colores pastel/dorados exclusivos y boquilla especial. |

Reglas: `ProcessReceipt` único e idempotente usando `profile.receipts[purchaseId]`.

---

## 11. Plan de Construcción por Fases (Ejecución Continua con Verificación MCP)

Ejecuta estas fases en orden. **Al final de cada fase:** corre playtest en Studio, inspecciona `get_console_output` y toma `screen_capture` para confirmar funcionamiento visual y cero errores en consola antes de seguir con la siguiente fase.

| Fase | Entregable Técnico | Criterio de Verificación en Studio (Playtest + Captura) |
| :--- | :--- | :--- |
| **0. Base y Arquitectura** | Estructura completa de carpetas, `Config/*`, `Util/*`, `Localization` (`en` + `es`), `Remotes`, esqueletos `Server` y `Client` arrancando en orden (`Init` -> `Start`). | El juego arranca en playtest con 0 errores en consola. |
| **1. Mundo Etapa 1 y Persistencia** | `WorldBuilder` (Patio con puesto de cajas/tablas + Cocina interior + Horno pequeño + Mesa), `DataService`, `EconomyService`, `HUD` y `Settings` (cambio EN/ES). | El jugador aparece frente a su puesto en el patio, ve `$25`, Deuda `$500`, Día 1, puede cambiar idioma EN/ES y el perfil se guarda/carga. |
| **2. Pedidos, Stock y Horneado** | `OrderService` + `NPCManager` (clientes cercanos en patio), `SupplyShop`, `InventoryService`, `IngredientPrep`, `BakingService` (horno 1 piso + timer + anti-softlock). | Llega un cliente, aceptas pedido, compras/dosificas insumos con descuento real y horneas un bizcocho con barra de progreso. |
| **3. Decoración Core 3D** | `CameraController` + `DecoratingController` + `DecoratingHUD` + `DecoratingService`: las 5 acciones completas (corte, relleno/apilado, base giratoria, manga pastelera con boquillas y toppings). | Puedes cortar, rellenar, cubrir girando la base, trazar crema y poner velas/frutas sobre el pastel 3D, tanto con clic/arrastre como con UI clara. |
| **4. Entrega, Deuda y Averías** | Cálculo autoritativo de precisión (Cumplido/Parcial/Incumplido), cobro/reembolso, `FinanceDebt`, ciclo diario (`300 s`), intereses `+8 %` por mora, averías y reparación del horno. | Al entregar, recibes pago/propina o reembolsas; al pasar el día sube interés si no pagas; abonar deuda reduce el saldo real. |
| **5. RRSS, Reseñas y Estafas** | `SocialService` y `SocialTerminal`: publicar foto/resumen de pastel, generación de reseñas con estrellas, encargos digitales, comprobantes falsos verificables y penalización de estafa. | Publicas creación, aparecen reseñas y puedes distinguir/reportar un comprobante falso frente a uno legítimo. |
| **6. Progresión y Local Comercial** | `ProgressionService`: Expertise, Marketing, Horno Industrial (multipiso), Refrigerador Comercial con caducidad/moscas, Arriendo de Local Comercial y personal (Recepción y Mezcla). | Comprar mejoras transforma capacidades/escenario, el refrigerador pudre bizcochos viejos y los empleados operan sus tareas. |
| **7. Modos Creativo, Competitivo y Monetización** | `ModeSelect`, **Creative Mode** (sandbox libre), **Competitive Mode** (contrarreloj + `OrderedDataStore`), `MonetizationService` seguro con IDs en `0` y Tutorial inicial de 4 pasos. | Puedes alternar entre Daily, Creative y Competitive sin fugas ni bugs de estado; IDs en `0` no rompen nada. |
| **8. Pulido Final y Entrega** | Revisión completa móvil/PC (`UIScale`), limpieza de memoria (`Maid`), VFX/Audio seguros, playtest integral de punta a punta y reporte final. | Playtest limpio de ciclo completo sin errores ni fugas; capturas validadas. |

**Recorte de emergencia:** Si encuentras restricciones severas de tiempo o tamaño de sesión, asegura primero **Fases 0 a 6 completas y pulidas** (el 100 % de Daily Mode con decoración core, deuda, RRSS, estafas y escalabilidad), y documenta exactamente qué quedó pendiente de Fase 7.

---

## 12. Formato del Reporte Final al Usuario

Cuando completes la ejecución en Studio (o al finalizar el alcance máximo posible), entrega un resumen técnico en español que incluya:

1. **Estado por Fase:** Qué fases quedaron completadas y verificadas mediante playtest en Studio.
2. **Registro de Decisiones:** Decisiones técnicas o de balance tomadas por tu cuenta.
3. **Cómo Probar el Juego Paso a Paso:** Recorrido para validar Daily Mode (pedido, decoración, estafa, deuda, mejoras), Creative Mode y Competitive Mode.
4. **Riesgos Conocidos / Bugs Pendientes:** Cualquier detalle visual o borde que convenga revisar en la siguiente iteración.
5. **Checklist de Publicación para el Usuario:**
   - [ ] Revisar y guardar copia de seguridad del `.rbxl`.
   - [ ] Configurar `Game Settings > Places / MaxPlayers = 1` (para la experiencia single-player principal) y habilitar `Enable Studio Access to API Services` en `Security`.
   - [ ] Crear en Creator Hub los Game Passes / Developer Products de la Sección 10 y pegar sus IDs en `ReplicatedStorage/Shared/Config/Monetization` (opcional para publicar).
   - [ ] Completar `Config/Assets` si se desean audios o iconos personalizados adicionales.
   - [ ] Probar en el emulador móvil de Roblox Studio (especialmente corte, base giratoria y manga pastelera táctil).
   - [ ] Completar cuestionario de clasificación de contenido, nombre/descripción en inglés y publicar (`File > Publish to Roblox`).
   - [ ] Sugerencia de título, descripción y tags para la página de Roblox de **Baking From Scratch**.

**Comienza ahora inspeccionando el estado del lugar en Studio vía MCP y arrancando la Fase 0.**
