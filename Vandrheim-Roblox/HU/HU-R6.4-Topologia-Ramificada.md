## HU-R6.4: Topología ramificada del dungeon (sala central + ramas + puertas selladas)

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** Mazmorra / Generación de pisos / R6.4  
**Prioridad:** Alta  
**Estado:** Completada (implementada; reporte equipo 2026-08-26)  
**Tipo:** Mejora de contenido procedural (reemplaza la linealidad del layout)  
**Fase GDD:** R6.4 (mejora posterior a R6.3; puede ejecutarse en paralelo con R7)  
**Depende de:** HU-R6a (FloorService, EnemyService, EnemyConfig), HU-R6b (run lifecycle, DungeonHUD), HU-R6.3 (DungeonVariantConfig, generador parametrizado)  
**Origen:** registro solicitado por el dev — `rc019` (R6.3) excluye expresamente "reemplazar el layout lineal actual por grafos ramificados"; el dev preparará el RC (rc020) desde esta HU antes de programar  
**Componentes observados:** `ServerScriptService.Services.FloorService`, `ServerScriptService.Services.EnemyService`, `ServerScriptService.Services.DungeonService`, `ReplicatedStorage.Config.DungeonVariantConfig`

---

### **Narrativa (INVEST)**

**Como** jugador,  
**quiero** que los pisos de la Helada no sean un pasillo recto de principio a fin, sino que tengan una sala central con ramas laterales, pasillos horizontales y diagonales,  
**para** que cada run se sienta más como una exploración y menos como una fila de salas.

**Como** jugador,  
**quiero** que la sala del jefe esté sellada por una puerta que solo se abra al eliminar a todos los enemigos del piso,  
**para** que el recorrido tenga propósito y no se pueda saltar el combate corriendo.

---

### **Descripción del Requerimiento / Contexto**

El dungeon actual genera siempre el mismo tipo de layout: una fila de salas conectadas por corredores rectos (con variación lateral del seed y, desde R6.3, morfologías Corredor/Caverna/Salón). La ruta es única y lineal: de la entrada a la boss room sin decisiones de recorrido.

Esta HU introduce una **topología ramificada** controlada por seed:

1. **Sala central (hub)** conectada a la entrada y a varias **ramas laterales** con salas de combate.
2. **Conectores horizontales y diagonales** (no solo hacia adelante), de modo que el recorrido deja de ser una línea.
3. **Sala final sellada** (mini-boss en pisos 1–4, jefe en piso 5) con una **puerta que se abre solo cuando el servidor confirma que no queda ningún enemigo normal vivo en el piso**.
4. **Mensaje en la puerta** indicando que está sellada (decisión cerrada: sin contador numérico en HUD).
5. Al morir el jugador, **el progreso de limpieza se mantiene**: los enemigos ya muertos no respawnean y una puerta ya abierta permanece abierta.

La topología se combina con las variantes morfológicas de R6.3: cualquier variante (Corredor, Caverna, Salón) puede tener topología ramificada; las dimensiones de salas, corredores y decoración siguen viniendo de `DungeonVariantConfig`. El seed del piso determina la forma del grafo (número de ramas, salas por rama, orientación de conectores).

**Criterio de hecho global:** un piso generado presenta una sala central con ramas explorables en varias direcciones y una sala final sellada que se abre al limpiar el piso, con progreso persistente ante la muerte y sin que el cliente pueda abrirla.

---

### **Especificaciones Técnicas / Contratos de API**

#### **Grafo de nodos por seed (server)**

* El layout deja de ser una fila y pasa a ser un **grafo de nodos** (salas) y aristas (corredores), generado por el seed en el servidor.
* Estructura base (default):
  ```
  Entrada ──→ Sala central (hub)
                  ├── Rama A: Sala 1 (pack) [─ Sala 2 (pack)]
                  ├── Rama B: Sala 1 (pack) [─ Sala 2 (pack)]
                  └── Sala final (mini-boss / jefe) ── SELLADA hasta limpiar
  ```
* Variación por seed (dentro de rangos configurables):
  * 2–3 ramas laterales.
  * 1–2 salas de combate por rama.
  * Orientación de las ramas (izquierda/derecha/diagonal) y longitud de los corredores.
* **Conectores**: corredores rectos en X y Z + conectores diagonales (45°). Los corredores diagonales se construyen con segmentos en L o tramos a 45° según el kit actual; no se crean mallas nuevas.
* La **sala central** conecta entrada, ramas y sala final; el jugador elige el orden de visita (no hay ruta obligatoria).
* La **sala final** es accesible solo desde la sala central (o desde un conector directo) y permanece sellada hasta completar la limpieza.

#### **Generación con variantes (integración R6.3)**

* `FloorService.GenerateFloor(floorIndex, seed, parent, variant, topology?)` conserva la firma de R6.3 y agrega la generación del grafo.
* `topology` es opcional: si no se pasa, se deriva del seed (server). El cliente nunca lo aporta.
* Las salas (hub, ramas, final) usan el `roomSize` y decoración de la variante activa (`DungeonVariantConfig`).
* Los corredores usan `corridorWidth`/`corridorLength` de la variante; la caverna puede generar más diagonales largos, el corredor ramas más angostas (directrices orientativas en config).
* Los packs se colocan en las salas de combate (central y ramas) respetando la densidad de la variante (`packSizeMin/Max`) y el límite de enemigos por piso de R6.3 (`maxEnemiesPerFloor = 20`).
* Los mini-bosses (pisos 1–4) y la boss room (piso 5) conservan su flujo y formato de R6a/R6.3, ahora ubicados en la sala final sellada.

#### **Puerta sellada (limpieza del piso)**

* Cada piso tiene **una puerta sellada** en la sala final (mini-boss 1–4, jefe 5). Decisiones cerradas con producto:
  * Aplica a la **sala final de cada piso** (no solo al piso 5).
  * La limpieza exige eliminar **todos los enemigos normales** del piso (los que spawnearon en salas de combate).
  * **No hay contador en HUD**: el feedback es el mensaje en la puerta.
* Implementación de la puerta (server-authoritative):
  * Parte visual de hielo/portón que ocupa el hueco del arco de la sala final (reutiliza el formato `Lintel`), con atributo de estado `Sealed = true`/`Open`.
  * Mientras está sellada, bloquea el paso (`CanCollide = true`) y muestra un mensaje (p. ej. `BillboardGui` o `TextLabel` en la puerta): "Puerta sellada — elimina a todos los enemigos del piso".
  * Cuando el servidor confirma 0 enemigos normales vivos del piso, la puerta pasa a `Open`: deja de colisionar, se oculta/desliza (animación simple, sin rigging) y el mensaje desaparece.
  * El estado se replica a los clientes (atributo del modelo de puerta o el canal de estado de piso existente; **no** se crea RemoteEvent nuevo).
* **Detección de limpieza**:
  * `EnemyService` emite/señaliza la muerte de enemigos (o el `FloorService` escucha el estado de spawns del piso).
  * Al morir un enemigo normal, el servidor verifica si quedan enemigos vivos del piso (`Enemy=true`, `Dead ~= true`, pertenecientes al `floorModel` actual).
  * Con cero vivos → abrir puerta. Sin bucles de polling por frame: usar eventos de muerte y una comprobación por muerte.
* **Muerte del jugador** (decisión cerrada):
  * Respawnea en la entrada del piso (R6a).
  * El progreso de limpieza **se mantiene**: no se repueblan salas y la puerta abierta permanece abierta.
  * Los enemigos de dungeon no respawnean (comportamiento R6a vigente, sin cambios).

#### **Mensaje de la puerta**

* Texto configurable en config (default: "Puerta sellada — elimina a todos los enemigos del piso").
* Visible solo mientras la puerta está sellada; al abrirse desaparece.
* Sin contador numérico en HUD (decisión cerrada); el `FloorLabel` de piso/variante no cambia.

#### **Debug (solo Studio)**

* `DebugSpawnFloor` acepta `variant` (R6.3) y opcionalmente `topology` para QA; si no se pasa, la topología se deriva del seed de forma estable (mismo seed+piso → mismo grafo y layout).
* Se mantiene la reproducción determinista del seed en las tres variantes.

#### **Seguridad y autoridad**

* El grafo, el seed, la posición de salas, los spawns y la puerta son **server-authoritative**.
* El cliente no puede: elegir/forzar topología o seed, abrir la puerta, quitar el sello, ni completar la limpieza con estado local.
* Un cliente manipulado que elimine enemigos localmente no afecta la limpieza del servidor ni la puerta.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Piso ramificado con sala central**

* **GIVEN** un piso generado con topología ramificada.
* **WHEN** el jugador explora.
* **THEN** existe una sala central conectada a la entrada, a 2–3 ramas y a la sala final.
* **AND** el recorrido no es una fila única: hay ramas hacia los lados.

#### **Escenario 2: Conectores horizontales y diagonales**

* **GIVEN** el grafo generado por el seed.
* **WHEN** se recorren los conectores.
* **THEN** existen corredores en X y en diagonal además del avance en Z.
* **AND** todos los conectores sellan correctamente con las salas (sin huecos ni obstrucciones).

#### **Escenario 3: Variación entre pisos y seeds**

* **GIVEN** dos pisos o dos seeds distintos.
* **WHEN** se comparan los grafos.
* **THEN** el número de ramas, la cantidad de salas por rama o la orientación de los conectores varía.
* **AND** el mismo seed+piso reproduce exactamente el mismo grafo.

#### **Escenario 4: Puerta sellada en la sala final de cada piso**

* **GIVEN** cualquier piso 1–5.
* **WHEN** el jugador llega a la sala final.
* **THEN** la puerta está sellada y bloquea el paso.
* **AND** muestra el mensaje de limpieza.

#### **Escenario 5: La puerta no se abre con enemigos vivos**

* **GIVEN** quedan enemigos normales vivos en el piso.
* **WHEN** el jugador intenta pasar.
* **THEN** la puerta permanece sellada.
* **AND** no puede atravesarla (colisión activa).

#### **Escenario 6: Limpieza abre la puerta**

* **GIVEN** el jugador elimina a todos los enemigos normales del piso.
* **WHEN** el último enemigo muere.
* **THEN** el servidor abre la puerta.
* **AND** la puerta deja de colisionar, se oculta y el mensaje desaparece.
* **AND** el jugador puede entrar a la sala final (mini-boss 1–4 / jefe 5).

#### **Escenario 7: Muerte sin pérdida de progreso**

* **GIVEN** el jugador murió con parte del piso limpio.
* **WHEN** respawnea en la entrada del piso.
* **THEN** los enemigos muertos siguen muertos.
* **AND** si la puerta ya estaba abierta, permanece abierta.
* **AND** no se repueblan las salas.

#### **Escenario 8: El cliente no abre la puerta**

* **GIVEN** un cliente intenta modificar la puerta, eliminar el sello o completar la limpieza.
* **WHEN** solo manipula estado local.
* **THEN** la puerta permanece sellada en el servidor.
* **AND** el avance sigue controlado por el servidor.

#### **Escenario 9: Integración con variantes**

* **GIVEN** cada variante (Corredor, Caverna, Salón) con topología ramificada.
* **WHEN** se generan pisos.
* **THEN** las salas y corredores usan las dimensiones de la variante.
* **AND** la caverna permite rutas más abiertas y el corredor ramas más angostas, sin romper el generador.

#### **Escenario 10: Densidad y límite de enemigos**

* **GIVEN** una caverna con ramas múltiples.
* **WHEN** se generan los packs.
* **THEN** la densidad respeta `packSizeMin/Max` de la variante.
* **AND** el total de enemigos normales no supera `maxEnemiesPerFloor` (20).

#### **Escenario 11: Run completa**

* **GIVEN** una run con pisos ramificados.
* **WHEN** el jugador completa los 5 pisos (limpieza + mini-bosses + sala final del piso 5).
* **THEN** el flujo de R6b funciona igual (avance, respawn, abandono, final de run).
* **AND** no hay errores rojos en generación, combate, puertas o limpieza.

#### **Escenario 12: Debug reproducible**

* **GIVEN** Studio/test.
* **WHEN** se usa `DebugSpawnFloor` sin topology.
* **THEN** la topología se deriva del seed.
* **AND** repetir seed+piso produce el mismo grafo y la misma puerta.

---

### **Comportamiento Visual e Interfaz (UI/UX) / Reglas de Negocio**

* El piso se siente como un lugar por explorar: sala central + ramas laterales, sin ruta única obligatoria.
* La puerta sellada es un portón de hielo coherente con el kit; el mensaje es breve y claro: "Puerta sellada — elimina a todos los enemigos del piso".
* No hay contador de enemigos en HUD (decisión cerrada); el mensaje en la puerta es el único feedback de limpieza.
* Al abrirse, la puerta se oculta/desliza sin animaciones complejas ni rigging (ASSETS_POLICY: sin animaciones propias).
* El orden de visita de las ramas es libre; ninguna sala es obligatoria antes de la limpieza total.
* Se conservan el `FloorLabel` (piso + variante), la UI, los controles y el comportamiento PC/móvil existentes.
* El respawn en la entrada del piso se mantiene; la limpieza no se pierde (regla de negocio cerrada).

---

### **Alcance**

#### Incluye

* Grafo de nodos por seed: sala central (hub) + 2–3 ramas + sala final.
* Conectores horizontales (X) y diagonales (45°) además del avance en Z.
* Variación del grafo por seed (ramas, salas por rama, orientación de conectores).
* Puerta sellada server-authoritative en la sala final de **cada piso** (mini-boss 1–4, jefe 5).
* Apertura por limpieza: eliminar todos los enemigos normales del piso (evento de muerte, sin polling por frame).
* Progreso persistente ante la muerte (sin repoblado; puerta abierta permanece abierta).
* Mensaje en la puerta (configurable) sin contador en HUD.
* Integración con `DungeonVariantConfig` (dimensiones, decoración, densidad de R6.3).
* `topology` opcional en `DebugSpawnFloor` (solo Studio) y derivación determinista por seed.
* Límite de enemigos por piso respetado (R6.3, `maxEnemiesPerFloor = 20`).

#### No incluye

* Mallas orgánicas, meshes, assets, VFX/SFX o materiales nuevos (se reutiliza el kit Helada).
* Streaming de chunks, generación infinita, navegación orgánica o pathfinding avanzado.
* Llaves, cofres de piso, puzzles, teletransportes internos o mecánicas de apertura adicionales.
* Contador de enemigos en HUD o minimapa (decisión cerrada: solo mensaje en la puerta).
* Repoblado de enemigos al morir (decisión cerrada: el progreso se mantiene).
* Party, matchmaking, cambio del lifecycle de R6b o persistencia de la run.
* Cambios a niveles de piso, plantillas de enemigos, loot, oro o balance (R8).
* Boss final, cofre, uniques y recompensa del piso 5 (R7 — la puerta solo habilita la sala).
* Modificar skills, inventario, talentos, targeting, cámara o controles.

---

### **Definition of Done (DoD)**

* [ ] El piso genera una sala central con 2–3 ramas laterales y una sala final (no lineal).
* [ ] Existen conectores horizontales y diagonales, correctamente sellados contra las salas.
* [ ] El mismo seed+piso reproduce el mismo grafo; seeds distintos varían ramas/orientación.
* [ ] La sala final de cada piso (1–5) tiene puerta sellada que bloquea el paso.
* [ ] La puerta se abre solo cuando el servidor confirma 0 enemigos normales vivos del piso.
* [ ] Con enemigos vivos, la puerta permanece sellada y muestra el mensaje.
* [ ] Al abrirse, la puerta deja de colisionar, se oculta y el mensaje desaparece.
* [ ] Morir conserva la limpieza: sin repoblado y puertas abiertas permanecen abiertas.
* [ ] El cliente no puede abrir la puerta ni forzar topología/seed.
* [ ] Las tres variantes de R6.3 funcionan con la topología ramificada.
* [ ] La densidad respeta `packSizeMin/Max` y el límite de enemigos por piso.
* [ ] Run completa de 5 pisos con respawn, abandono y final sin errores rojos.
* [ ] `DebugSpawnFloor` reproduce topología por seed (y acepta `topology` en Studio).
* [ ] No se crean RemoteEvents nuevos; el estado de la puerta usa atributos/canal existente.
* [ ] Se actualizan `PROJECT_ARCHITECTURE`, `DATA_SCHEMA` y el registro de la HU/RC al cerrar.
* [ ] Nota `R6.4 completo` en el GDD después de la verificación, no antes.
* [ ] El dev prepara y aprueba el RC (rc020) desde esta HU antes de programar (DEV_PROMPT).

---

### **Decisiones por defecto R6.4**

| Tema | Default |
|------|---------|
| Topología | Sala central (hub) + 2–3 ramas + sala final sellada |
| Salas por rama | 1–2 |
| Conectores | Rectos en X/Z + diagonales 45°, según seed |
| Puerta sellada | Sala final de cada piso (mini-boss 1–4, jefe 5) |
| Condición de apertura | 0 enemigos normales vivos del piso (server) |
| Muerte del jugador | Respawnea en entrada; limpieza y puertas se mantienen |
| Feedback de limpieza | Mensaje en la puerta ("Puerta sellada — elimina a todos los enemigos del piso"); sin contador en HUD |
| Apertura visual | Ocultar/deslizar simple, sin animaciones propias |
| Integración variantes | Salas/corredores/decoración según `DungeonVariantConfig` |
| Límite enemigos | `maxEnemiesPerFloor = 20` (R6.3) |
| Debug | `topology` opcional en Studio; derivación determinista por seed |
| Seguridad | Server-authoritative: grafo, seed, spawns, puerta y limpieza |

---

### **Estimación (orientativa)**

3–4 sesiones: grafo por seed, conectores horizontales/diagonales, puerta sellada con limpieza server-side, mensaje, integración con variantes y regresión de run completa.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-26 | Creación de HU-R6.4 por exclusión expresa de la topología ramificada en rc019 (R6.3); decisiones cerradas: sala central + ramas + conectores horizontales/diagonales, puerta sellada en la sala final de cada piso, progreso de limpieza persistente ante la muerte y feedback solo con mensaje en la puerta |
| 2026-08-26 | Marcada completada según reporte del equipo |