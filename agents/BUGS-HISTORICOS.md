# Registro de Fallas Históricas (memoria de los revisores)

Este archivo es la memoria del proyecto. Cada entrada es una falla que **llegó al usuario o se detectó tarde**. Los revisores lo leen antes de cada revisión y deben buscar activamente cada clase de falla de su área (regla R10 del [`REVIEW-PROTOCOL.md`](./REVIEW-PROTOCOL.md)).

## Cómo se mantiene

- Cuando el usuario encuentre una falla **después de una aprobación**, se agrega una entrada. La registra el `ApproverAgent` o quien reciba el reporte.
- Se describe la **clase de falla** de forma independiente del proyecto y de la tecnología, para que sirva en cualquier repositorio.
- Cada entrada indica qué revisor debió detectarla y qué prueba la habría revelado.
- Nunca se borran entradas. Si una deja de aplicar, se marca como `OBSOLETA` con el motivo.

## Plantilla

```markdown
### BH-NNN — [Título corto de la clase de falla]
- **Origen:** [proyecto, fecha]
- **Qué pasó:** [síntoma observado]
- **Causa raíz:** [por qué ocurrió]
- **Revisor responsable:** [CR | SEC | REL | UI | UX]
- **Cómo se habría detectado:** [prueba concreta]
- **Cómo buscarla:** [pasos genéricos para cualquier proyecto]
```

---

## Entradas

### BH-001 — Identificador no definido que detiene la inicialización en cascada
- **Origen:** Physics Lab, noviembre de 2026.
- **Qué pasó:** una pantalla usaba una variable que nunca se declaró. Al crearse falló y, como las demás pantallas se creaban en secuencia, **todas las posteriores dejaron de existir**. El resto del código parecía correcto.
- **Causa raíz:** el identificador solo se resolvía al ejecutar esa ruta. Nadie ejecutó el arranque completo mirando la salida de errores.
- **Revisor responsable:** CR.
- **Cómo se habría detectado:** arrancar el producto completo y leer el registro de errores; análisis estático en modo estricto que marque identificadores no definidos.
- **Cómo buscarla:** ejecutar el punto de entrada real, revisar la consola o el log desde el primer segundo, y verificar que cada módulo nuevo se inicialice. Un error en una pantalla o módulo nunca debe pasar por "solo afecta a uno".

### BH-002 — Interfaz que choca o desborda al cambiar la escala o la resolución
- **Origen:** Physics Lab, noviembre de 2026.
- **Qué pasó:** un menú se superponía con el banner del jugador en pantallas grandes; botones de compra se salían de su panel y un panel se veía apretado.
- **Causa raíz:** posiciones y tamaños calculados para una sola resolución, con medidas fijas en el contenedor y textos de ejemplo cortos.
- **Revisor responsable:** UI.
- **Cómo se habría detectado:** renderizar en la matriz de resoluciones y escalas, y comparar las cajas de los elementos para detectar intersecciones.
- **Cómo buscarla:** medir, no mirar. Calcular solapamientos entre elementos hermanos y entre un elemento y su contenedor en cada resolución y escala.

### BH-003 — Glifos o emojis que la fuente no soporta
- **Origen:** Physics Lab, noviembre de 2026.
- **Qué pasó:** un símbolo decorativo se mostró como un cuadro vacío.
- **Causa raíz:** se usó un carácter que la fuente de la interfaz no incluye. Nadie lo renderizó.
- **Revisor responsable:** UI.
- **Cómo se habría detectado:** renderizar la pantalla real y revisar cada carácter no alfanumérico.
- **Cómo buscarla:** listar todos los símbolos y emojis nuevos y comprobarlos renderizados, en cada plataforma objetivo.

### BH-004 — Cambios que no persisten por escribir desde una copia obsoleta
- **Origen:** Physics Lab, noviembre de 2026.
- **Qué pasó:** una edición hecha sobre un archivo se perdió porque una vista abierta del mismo archivo, con contenido anterior, lo sobrescribió.
- **Causa raíz:** dos copias del mismo artefacto y la antigua ganó.
- **Revisor responsable:** CR.
- **Cómo se habría detectado:** releer el artefacto **final** desde su fuente real tras el cambio y comprobar que contiene lo esperado.
- **Cómo buscarla:** no confiar en que una escritura "se aplicó"; verificar leyendo el estado final y la longitud o hash del contenido.

### BH-005 — Las pruebas modifican datos reales
- **Origen:** Physics Lab, noviembre de 2026.
- **Qué pasó:** al probar funcionalidades de recompensa y compra, los datos de la cuenta real del usuario (monedas, giros, máquinas) cambiaron y hubo que revertirlos a mano.
- **Causa raíz:** el único entorno disponible usaba el perfil real y las pruebas no se aislaron.
- **Revisor responsable:** REL (y todos, por el protocolo de seguridad de pruebas).
- **Cómo se habría detectado:** declarar antes de probar qué datos se tocarán y registrar el estado inicial.
- **Cómo buscarla:** anotar el estado antes y después de cada prueba; revertir y declarar todo cambio.

### BH-006 — Lo que la interfaz muestra no coincide con lo que el sistema hace
- **Origen:** Physics Lab, noviembre de 2026.
- **Qué pasó:** los precios de unos productos de pago que mostraba el juego (39, 145 y 359) no coincidían con los que el equipo había definido en la documentación y en los comentarios del código (49, 199 y 499).
- **Causa raíz:** el valor mostrado venía de la plataforma de ventas y el valor documentado vivía en otro lugar; nadie los contrastó.
- **Revisor responsable:** UX.
- **Cómo se habría detectado:** comparar, para cada cifra visible, el valor mostrado con el valor realmente aplicado por el sistema.
- **Cómo buscarla:** listar toda cifra, precio, probabilidad o recompensa visible y contrastarla con la fuente real. Si hay dinero o probabilidades, es `[BLOQUEANTE]`.

### BH-007 — Camino de usuario nuevo leído pero nunca ejecutado
- **Origen:** Physics Lab, noviembre de 2026.
- **Qué pasó:** un regalo de bienvenida y otros pasos del primer uso se verificaron solo leyendo el código; el usuario que ya tenía cuenta antigua nunca recorrió ese camino.
- **Causa raíz:** el entorno de prueba tenía datos de un usuario veterano, que ocultan los caminos de primer uso.
- **Revisor responsable:** UX y REL.
- **Cómo se habría detectado:** ejecutar con una cuenta completamente vacía.
- **Cómo buscarla:** exigir siempre una prueba de primer uso con estado vacío, y otra con el estado más cargado posible.

### BH-008 — Plantillas de prueba interna (seed/QA) filtradas en tablas de botín o recompensas
- **Origen:** Vandrheim RPG, noviembre de 2026.
- **Qué pasó:** al reclamar una recompensa de misión de cacería, un jugador recibió un casco con nombre `[QA Azul] Yelmo del Cazador` y descripción `"Template seed de prueba de set. No pertenece a loot ni vendor."`.
- **Causa raíz:** `InventoryService.RollClassEquipment` iteraba sobre `pairs(ItemConfig)` seleccionando equipamiento por rareza y clase, omitiendo el filtro `template.seedOnly ~= true` y `not ItemConfig.IsSeedTemplate(templateId)`.
- **Revisor responsable:** CR y UX.
- **Cómo se habría detectado:** auditar todas las funciones que iteran catálogos globales de ítems buscando que respeten banderas de exclusión de prueba (`seedOnly`, `testOnly`, `debugOnly`), y probar la ruleta de recompensas con 100 tiradas consecutivas verificando que ningún ítem resultante contenga prefijos `[QA ...]` ni `seed_`.
- **Cómo buscarla:** buscar `pairs(ItemCatalog)` o equivalentes y verificar que todas las selecciones aleatorias descarten plantillas marcadas como exclusivas de pruebas.

### BH-009 — Autocancelación de corrutina de refresco al re-renderizar un diálogo abierto (`cannot cancel thread`)
- **Origen:** Vandrheim RPG, noviembre de 2026 (`rc151`, `RunicStoneClient`).
- **Qué pasó:** al abrir el diálogo de la piedra rúnica durante el enfriamiento de 5 s (o mantenerlo abierto tras una interacción en cooldown), a los 0.5 s se lanzó el error en cliente `RunicStoneClient:58: cannot cancel thread`.
- **Causa raíz:** el hilo periódico `cooldownRefreshThread` llamaba cada `0.5 s` a `renderRunicDialog(...)`, que volvía a invocar `startDialogWatches(...)` -> `disconnectDialogWatches()`, ejecutando `task.cancel(cooldownRefreshThread)` desde dentro de la propia corrutina en ejecución (`cooldownRefreshThread == coroutine.running()`).
- **Revisor responsable:** REL y UX.
- **Cómo se habría detectado:** mantener abierto el panel/diálogo en vivo durante más de dos ciclos completos del temporizador (incluyendo la transición hasta que expire el enfriamiento) en Play real, en lugar de cerrar el panel o validar el cooldown solo mediante llamadas inmediatas a remotes.
- **Cómo buscarla:** buscar `task.cancel(` en funciones de limpieza o refresco llamadas desde el propio ticker/watch loop, verificar que las guardas comparen `thread ~= coroutine.running()` y separar el re-render visual del ciclo de vida de conexiones y timers.

### BH-010 — Propiedad inexistente en tabla de configuración al renderizar pantalla creada por flujo completo de UI (`nil` concatenation) y solape por `UILayoutDefaults`
- **Origen:** Vandrheim RPG, noviembre de 2026 (`rc152`, `MatchmakingClient` y `DungeonClient`).
- **Qué pasó:** al crear una sala desde la pestaña `CREAR SALA` de `MatchmakingUI` (especialmente en modo Endless) o cambiar de pestaña en party, el cliente lanzó `MatchmakingClient:757: attempt to concatenate nil with string` porque `renderRoom()` leía `roomModeInfo.displayName`, propiedad inexistente en `RoomConfig.DungeonModes` (`title`, `label`, `shortLabel`). Además, con `UILayoutDefaults` activo sobre `DungeonHUD.TopBar` (`y ≈ 0.088`), `EndlessCountdownBanner` en `y = 0.165` fijo se superponía sobre `TopBar`.
- **Causa raíz:** la auditoría probó `RequestCreateRoom` sin validar la renderización completa de `TU SALA` tras crear la sala por interfaz con el selector de modo, y midió `EndlessCountdownBanner` con `Y` estático sin derivarlo del borde inferior real de `TopBar` tras aplicar `UILayoutClient` / `UILayoutDefaults`.
- **Revisor responsable:** CR, UX y UI.
- **Cómo se habría detectado:** recorrer el flujo real completo de UI de extremo a extremo (`CREAR SALA` -> elegir modo -> crear -> navegar por todas las pestañas en `TU SALA`) y medir solapes de HUD después de que `UILayoutClient` aplique `UILayoutDefaults` / layout persistido del personaje.
- **Cómo buscarla:** contrastar cada campo accedido en UI (`cfg.displayName`, `cfg.label`, etc.) contra las claves reales definidas en su módulo `Config` (`table.freeze`) y anclar todo banner adyacente a elementos gestionados por `UILayoutClient` respecto a `AbsolutePosition`/`AbsoluteSize`.


### BH-011 — Posición de origen cacheada antes de reubicar un contenedor padre (`SpawnOrigin` desfasado tras `PivotTo`)
- **Origen:** Vandrheim RPG, noviembre de 2026 (`rc155`, `DungeonService`, `FloorService` y `EnemyService`).
- **Qué pasó:** al entrar a una dungeon en Studio Play (`DebugStartDungeonPreview`), el 100 % de los enemigos generados en el piso caminaban en línea recta contra los muros intentando regresar al origen `(0, Y, 0)` y rechazaban todo ataque del jugador con `"El objetivo está regresando."`.
- **Causa raíz:** `FloorService.GenerateFloor` spawneaba packs y miniboss en coordenadas locales cercanas al origen `(0, 0, 0..218)` fijando `SpawnOrigin` en ese instante, y inmediatamente después `DungeonService` movía todo el modelo del piso con `floorModel:PivotTo(floorModel:GetPivot() + STUDIO_PREVIEW_OFFSET)` (`+6000` Z) sin desplazar `SpawnOrigin`. Además, `EnemyService.createLeashController` cacheaba `SpawnOrigin` una sola vez al crearse, ignorando reubicaciones posteriores. Por otro lado, ninguna prueba de Fase 2 ni Fase 3 ejecutó el flujo real de entrada a dungeon (`DebugStartDungeonPreview`), probando únicamente en Hub/Prólogo.
- **Revisor responsable:** REL, UX y CR (radio de impacto de `PivotTo` / entornos declarados en la Spec).
- **Cómo se habría detectado:** buscar todos los `PivotTo` de contenedores padres que alojan entidades con coordenadas mundiales cacheadas (`SpawnOrigin`, `ArenaBounds`, checkpoints) y ejecutar el arranque real de cada modo afectado por la Spec (Hub, Dungeon normal, Endless y Prólogo) en Play.
- **Cómo buscarla:** auditar todo atributo o caché de posición mundial guardado en entidades recién creadas y comprobar si un padre (`floorModel`, zona, arena) o rutina de reset ejecuta `PivotTo` después del spawn; exigir relectura dinámica o sincronización atómica del atributo tras trasladar el contenedor.

### BH-012 — Campo de payload perdido al ampliar un serializador compartido (`quantity` ausente, etiquetas de stack invisibles)
- **Origen:** Vandrheim RPG, noviembre de 2026 (`rc156`, `InventoryService.serializeItem`).
- **Qué pasó:** en el juego publicado, las pociones y demás ítems apilables dejaron de mostrar la etiqueta de cantidad en la mochila (y en subasta y avisos de botín), porque el cliente recibía todos los ítems sin `quantity` y asumía 1.
- **Causa raíz:** al agregar `questItem` y `commerceBlocked` al serializador de `InventoryService`, el campo `quantity` quedó fuera del payload (el serializador de `VendorService` sí lo conserva). La auditoría verificó los campos nuevos pero no comparó el payload completo ni probó una mochila con stacks.
- **Revisor responsable:** CR y UX.
- **Cómo se habría detectado:** abrir en Play una mochila con ítems apilables (por ejemplo, 5 pociones) después del cambio y comprobar la etiqueta de cantidad; comparar las claves del payload antes y después de editar un serializador.
- **Cómo buscarla:** al modificar una función que arma payloads para el cliente, listar las claves previas y posteriores y confirmar que ninguna se perdió; buscar en el cliente los campos que lee (`item.quantity`, `item.stackable`) y verificar que cada serializador los emite.

### BH-013 — Condición de exclusión demasiado amplia en el reparto de loot (los mini-jefes no soltaban nada)
- **Origen:** Vandrheim RPG, noviembre de 2026 (`InventoryService.onDummyDied`).
- **Qué pasó:** el mini-jefe Señor de la escarcha (`miniboss_frost_lord`, tabla `floor_4_boss`) y los otros tres mini-jefes de los pisos 1 a 4 dejaron de soltar ítems y oro, en solitario y en grupo, durante un tiempo largo hasta que el PO lo notó probando varias dungeons.
- **Causa raíz:** `onDummyDied` salía antes de tirar la tabla cuando el enemigo tenía `IsBoss == true`. Los cuatro mini-jefes tienen `isBoss = true` en `EnemyConfig`, así que se excluían junto con el jefe final, que ya se excluye por `SkipAutoLoot`. La tabla de loot estaba bien; nunca se tiraba.
- **Revisor responsable:** CR y UX.
- **Cómo se habría detectado:** matar a cada mini-jefe en Play y verificar que cae ítem y oro, o ejecutar el hook de muerte sobre un mini-jefe y comprobar que se llama a `rollLootTable`; contrastar las tablas `floor_N_boss` con quién las consume.
- **Cómo buscarla:** ante cualquier `return` temprano por una bandera de tipo (`IsBoss`, `IsMiniboss`, `IsEndlessEnemy`), listar todas las plantillas que la cumplen y confirmar que ninguna debía quedar dentro del alcance; preferir banderas específicas (`SkipAutoLoot`) a banderas de categoría.

### BH-014 — Requerimiento marcado COMPLETO sin que su código exista en Studio (rc145, rechazo de misiones)
- **Origen:** Vandrheim RPG, noviembre de 2026 (`rc145`, `QuestService` y `QuestClient`).
- **Qué pasó:** el PO notó que no podía rechazar misiones desde el Cuaderno aunque el rc145 figuraba COMPLETO (verificado el 2026-11-05). En Studio, `RequestAbandonQuest` existía sin ningún receptor en el servidor, `QuestService.AbandonQuest` solo contemplaba la diaria y el botón "Rechazar misión" no existía en `QuestClient` (solo quedaban variables declaradas sin uso).
- **Causa raíz:** no se pudo establecer con certeza (pérdida del cambio al publicar o sincronizar el place, o entrega parcial dada por completa). La verificación del RC no contrastó cada punto del alcance contra el DataModel vigente.
- **Revisor responsable:** CR y UX.
- **Cómo se habría detectado:** buscar en el DataModel cada símbolo que el RC dice haber agregado (`RequestAbandonQuest.OnServerEvent`, el botón "Rechazar misión", el modal) y ejecutar el flujo completo de punta a punta en Play antes de cerrar.
- **Cómo buscarla:** para cada RC cerrado, comprobar con una búsqueda en scripts que sus handlers, botones y remotes existen y están conectados; tratar variables declaradas sin uso como señal de implementación incompleta.

