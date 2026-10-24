# HU-R6.39: Rediseño de la dungeon Helada — retirar Corredor y reforzar ambiente

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R6.x / Dungeon / Ambientación y generación
**Prioridad:** Alta — mejora pre-lanzamiento
**Estado:** Borrador para revisión del PO y RC
**Tipo:** Rediseño de entorno procedural, iluminación y decoración (dev)
**Fase GDD:** R6.39 — actualización visual/técnica del dungeon Helada
**Depende de:** HU-R6a (FloorService y kit), HU-R6b (run lifecycle), HU-R6.3 (DungeonVariantConfig), HU-R6.4 (topología ramificada), HU-R6.24 (geometría), HU-R7/R7.1 (boss rooms), ASSETS_POLICY (`Lighting` por Place, materiales y props)
**Componentes observados:** `ReplicatedStorage.Config.DungeonVariantConfig`, `ServerScriptService.Services.FloorService`, `Workspace.Terrain`, `Lighting` del Place Dungeon
**No modifica:** topología/seed, pisos/niveles, enemigos, dificultad, loot/oro, jefe, reglas de combate, party ni matchmaking.

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** explorar una dungeon cómoda de recorrer, con espacios reconocibles y una identidad helada memorable,
**para** sentir que cada piso es un lugar con atmósfera y propósito, no una caja vacía repetida.

**Como** equipo,
**quiero** decidir con una prueba acotada si Terrain aporta valor al generador actual,
**para** elegir una solución ambiental vistosa sin perder control de la generación por seed, el gameplay ni el rendimiento.

---

### Hallazgo / Estado actual

El PO solicita retirar por completo la variante **Corredor de Escarcha** porque su recorrido es demasiado estrecho e incómodo. La configuración actual aún la incluye como variante, valor por defecto y fallback: sala `40×40`, corredor `10` studs (el documento original de R6.3 conserva valores previos de `8`), largo `28`, sala/techo bajos y packs pequeños.

La vista de `DebugStartDungeonPreview` confirma la sensación descrita: habitación cuadrada, techo plano bajo, paredes azules uniformes y pocos hitos visuales. `FloorService` construye el kit principalmente con `Part` anclados (piso y techo de Slate, paredes de Ice), añade algunos cristales/pilares y luces puntuales sencillas. El código ya tiene las variantes Caverna y Salón, topología ramificada y props procedurales; esta HU las conserva y eleva su composición visual.

**Importante:** se retira solo la **variante angosta** `Corredor de Escarcha`, no los pasillos/conectores del grafo R6.4. Los conectores de Caverna y Salón continúan siendo necesarios.

**Criterio de hecho global:** ninguna run nueva puede seleccionar o caer en Corredor; las variantes Caverna y Salón siguen generando todos los pisos y topologías. La iluminación, siluetas, detalle y puntos de interés producen una Helada claramente identificable, más habitada y visualmente distinta por piso, con recorridos legibles y performance estable.

---

### Decisiones y dirección visual propuestas

#### 1. Retirar Corredor de Escarcha

* `DungeonVariantConfig.ORDER` y `VARIANTS` contienen únicamente `Caverna` y `Salon`.
* `DungeonVariantConfig.Choose()` y `FromSeed()` solo pueden producir esas dos variantes; la selección por run conserva la aleatoriedad/determinismo actuales dentro del nuevo conjunto.
* Eliminar `Corredor` de defaults, `VariantName`, HUD, mensajes, teleports, validaciones, pruebas/debug y documentación activa.
* **Fallback recomendado:** `Salon`, por sus salas/corredores amplios y su lectura clara. Un dato legacy/variante desconocida `Corredor` resuelve a `Salon` con warning; nunca reconstruye el layout angosto.
* Mantener medidas cómodas de las variantes supervivientes como base: Caverna (sala `80×80`, corredor `20`) y Salón (sala `70×70`, corredor `16`), ajustables por config si el playtest encuentra puntos de estrangulamiento.

#### 2. Identidad por piso (misma dungeon Helada)

La morfología Caverna/Salón sigue decidiendo la forma general de las habitaciones; cada piso añade una lectura ambiental propia. Los nombres son direcciones de arte, no sistemas, contenido de loot ni nuevas mecánicas:

| Piso | Dirección de ambiente sugerida | Hito/lectura visual |
|---|---|---|
| P1 | Umbral glacial: piedra congelada, hielo pálido y luz fría abierta | Entrada reconocible y primera vista amplia del complejo. |
| P2 | Vetas de cristal: cavidad azul/cian con racimos luminosos controlados | Vetas principales orientan el recorrido; evitar luz uniforme en cada cristal. |
| P3 | Profundidad subglacial: tonos más oscuros, capas de hielo y grietas grandes | Cambiar escala y profundidad, dejando las rutas transitables legibles. |
| P4 | Santuario/ruina helada del mini-boss: arquitectura antigua, runas y contraste frío/cálido | Punto focal del encuentro, puerta final y silueta reconocible antes de combatir. |
| P5 | Trono de Jotunn: cámara de mayor escala, pilares/masas de hielo y foco sobre la arena | El boss y sus telegraphs dominan; preservar el espacio de combate y la luz roja existente como acento. |

La decoración se genera/reparte de forma determinista con `floorSeed` y respeta el layout/topología existente. Cada piso debe tener al menos un landmark memorable, sin llenar las rutas con props repetidos.

#### 3. Iluminación y atmósfera

* Crear un preset exclusivo del **Place Dungeon**; no alterar el Lighting del Hub.
* Base fría con gradientes entre cámaras, contraste y profundidad; fog/Atmosphere sutil solo si conserva visibilidad de enemigos, nameplates, puertas y telegraphs.
* Usar fuentes locales justificadas (cristales, runas, braseros del Santuario); alternar acentos fríos con luz cálida escasa para dar escala y dirigir la mirada.
* Evitar PointLights duplicadas por cada prop pequeño, bloom/fog que lave el contraste y cambios bruscos que oculten señales de combate. Postprocesado moderado y verificado en móvil.
* Boss rooms y zonas de combate mantienen siluetas claras y lectura de ataques; no usar oscuridad como dificultad adicional.

#### 4. Decoración y sensación de lugar

* Añadir detalle en tres escalas: **macro** (paredes/techos irregulares y masas de hielo), **medio** (clusters de cristal, arcos, columnas/ruinas, formaciones) y **micro** (nieve, grietas, runas y fragmentos agrupados).
* Cada tipo de habitación recibe un presupuesto/config de props; reforzar las entradas, intersecciones, ramas y salas finales, no solo cubrir el centro de las salas.
* Mantener una franja de navegación limpia en puertas/corredores y una zona de combate despejada alrededor de spawns, pack markers, mini-bosses y boss.
* Props decorativos sin gameplay tienen `CanCollide/CanTouch/CanQuery` desactivados cuando sea posible; los elementos que sí colisionen deben pasar pruebas de salto/escalada y no tapar accesos.
* Reusar/instanciar clusters de forma consistente y controlar cantidad de luces, transparencias, partículas y piezas por cámara; priorizar formas reconocibles frente a cientos de detalles pequeños.

---

### Prueba de Terrain (decisión técnica, no conversión a ciegas)

El generador actual crea habitaciones y corredores como modelos de Parts por seed. Terrain puede aportar paredes y volúmenes naturales, pero `Workspace.Terrain` es un objeto global del Workspace, no un modelo que se pueda clonar/parentar por habitación.

**Recomendación:** hacer una PoC híbrida en una cámara de Caverna representativa: Terrain para masas orgánicas de pared/techo, taludes, nieve y hielo natural; conservar como piezas/plantillas explícitas los pisos caminables, openings, conectores, puerta sellada y la sala boss. La PoC debe comparar una misma cámara con el kit actual en look, navegación, generación repetida y coste de runtime.

* Si se usa `Terrain:WriteVoxels`, respetar resolución de 4 studs y alinear la región a la grilla; para bloques orientados se puede probar `Terrain:FillBlock`. Limitar toda escritura/limpieza a las regiones reservadas del dungeon.
* Prohibido usar `Terrain:Clear()` global como limpieza de un piso/run. Demostrar cómo se limpia/reconstruye únicamente la región propia sin afectar otras áreas del Place.
* Reproducir la PoC con el mismo seed y verificar que no haya agujeros, colisiones sorpresa, filtraciones de luz ni cambios en conectores.
* **Criterio de decisión:** incluir en el reporte comparación visual/técnica y elegir Terrain híbrido si ofrece mejora clara con limpieza determinista; si no, conservar Parts/plantillas y usar meshes/props modulares para el shell orgánico. La HU se puede cerrar con cualquiera de las dos opciones, pero la decisión y evidencia quedan registradas.

---

### Especificaciones técnicas / contratos

* Actualizar `DungeonVariantConfig`: quitar `Corredor` de `DEFAULT_VARIANT`/`ORDER`/`VARIANTS`; mantener solo Caverna y Salón. El default/fallback recomendado es `Salon`.
* Actualizar validación, `Choose`, `FromSeed`, HUD, `VariantName`, debug preview, teleport data y tests. El mismo seed+piso debe seguir regenerando la misma topología y la misma variante dentro de la run.
* Compatibilidad de datos: si llega `variant = "Corredor"` desde una copia de Place desincronizada o dato legacy, mapear a `Salon`, registrar warning y continuar la run; no producir geometría angosta ni fallar toda la run.
* Mantener el grafo de R6.4, entradas y aperturas, boss trigger, puerta sellada, densidad de spawns, roster de enemigos, packs, nivel de piso, loot y lifecycle R6b.
* Los perfiles de ambiente y decoraciones por piso/variante son config-driven y se evalúan con el seed del piso; los valores ajustables viven en config, no en múltiples ramas hardcodeadas.
* Sin cambiar la arquitectura de party: las HUs R9a/R9a.3 y el matchmaking no se modifican.
* Sin crear o cambiar SFX en esta HU. Se puede reutilizar audio ambiental existente si ya está registrado; cualquier SFX nuevo queda fuera de alcance.

---

### Criterios de aceptación (Gherkin)

#### Escenario 1: Corredor retirado de nuevas runs

* **GIVEN** una nueva run o un debug spawn por seed
* **WHEN** el servidor elige la variante
* **THEN** solo puede seleccionar `Caverna` o `Salon`; `Corredor` no aparece en `ORDER`, `VARIANTS`, HUD ni `VariantName`

#### Escenario 2: Fallback y compatibilidad

* **GIVEN** `DEFAULT_VARIANT`, un ID inválido o un teleport legacy con `Corredor`
* **WHEN** se resuelve la variante
* **THEN** se usa `Salon` como fallback seguro con warning controlado y nunca se genera el corredor estrecho

#### Escenario 3: Espacio cómodo

* **GIVEN** Caverna o Salón con topología ramificada
* **WHEN** se recorre solo y con party de 2–4 jugadores
* **THEN** los conectores permiten pasar y combatir sin amontonamiento; aperturas/puertas están libres de props

#### Escenario 4: Identidad ambiental por piso

* **GIVEN** los cinco pisos de Caverna o Salón
* **WHEN** el jugador avanza entre pisos
* **THEN** percibe diferencias de luz, escala, silueta y landmarks que comunican progresión hasta Santuario y Trono de Jotunn, sin cambiar el orden ni contenido funcional de los encuentros

#### Escenario 5: Iluminación y lectura de combate

* **GIVEN** combate con enemigos, nameplates, puertas y telegraphs
* **WHEN** se juega con el preset del dungeon
* **THEN** los objetivos y señales siguen legibles en el ambiente más atmosférico; el Hub mantiene su iluminación independiente

#### Escenario 6: Decoración sin obstrucciones

* **GIVEN** cualquier sala, corredor, apertura, spawn o arena de boss
* **WHEN** se genera la decoración por seed
* **THEN** la dungeon tiene clusters/landmarks suficientes para no sentirse vacía y los props no bloquean traversal, cámaras ni combate

#### Escenario 7: PoC Terrain

* **GIVEN** la cámara de Caverna elegida para PoC
* **WHEN** se compara Terrain/híbrido con el kit modular y se repite su generación/limpieza por seed
* **THEN** el reporte documenta apariencia, límites de navegación, limpieza de región y performance, y deja una decisión explícita Terrain híbrido o kit modular

#### Escenario 8: Regresión de dungeon

* **GIVEN** cada una de las dos variantes supervivientes
* **WHEN** se completa una run de cinco pisos, incluida muerte/respawn, puerta sellada y boss final
* **THEN** R6.4/R6b/R7 funcionan, se conserva el contenido/loot/balance y no hay errores rojos

#### Escenario 9: Rendimiento

* **GIVEN** salas decoradas, luces locales y party de 2–4 en PC y móvil
* **WHEN** se genera y recorre la dungeon
* **THEN** no hay una caída notable de frames/tiempo de carga por decoración/Terrain; el dev reporta conteos y ajustes por variante

---

### Alcance

#### Incluye

* Retiro completo de la variante Corredor de Escarcha de configuración, randomización, fallback, HUD y debug.
* Rediseño visual de Caverna/Salón y progresión ambiental para los cinco pisos.
* Mejora de preset de iluminación en el Place Dungeon y de decoración ambiental, con landmarks/cluster por piso.
* PoC y decisión documentada de Terrain versus kit modular/híbrido.
* Regresión de seed, topología, conexiones, parties, boss rooms y móvil.

#### No incluye

* Bioma nuevo o cambio de tema fuera de la Helada; mundo semiabierto/superficie fuera de la dungeon.
* Enemigos, bosses, misiones, niveles, loot, recompensas, dificultad o mecánicas nuevas.
* Rebalance de Caverna/Salón: solo ajustes visuales y de comodidad de navegación, salvo regresión necesaria.
* Reescribir el generador de R6.4 o cambiar el número de pisos/topología.
* Conversión completa a Terrain antes del resultado de la PoC.

---

### Definition of Done (DoD)

* [ ] La variante `Corredor` no puede generarse ni aparecer como fallback; `Salon` es fallback seguro y se remapean datos legacy.
* [ ] Caverna y Salón generan los cinco pisos con R6.4; no hay rutas o aperturas estrechas/obstruidas para party.
* [ ] Se implementan los perfiles ambientales/iluminación por piso y los hitos visuales aprobados; nameplates, telegraphs y enemigos conservan contraste.
* [ ] Props y luces siguen presupuestos configurados, tienen colisión/consulta adecuada y no bloquean spawn, puertas o boss arenas.
* [ ] PoC Terrain terminada; decisión entre híbrido y kit modular registrada con captura, seed y medición comparativa.
* [ ] Si se usa Terrain, escritura y limpieza quedan confinadas a regiones reservadas; no se ejecuta `Terrain:Clear()` global.
* [ ] Playtest en PC y móvil, solo y party de cuatro; no se percibe caída notable de rendimiento ni hay errores rojos.
* [ ] HUD/teleport/debug ya no exponen Corredor; R6b/party/boss/loot siguen funcionando.
* [ ] Se actualizan `PROJECT_ARCHITECTURE`, `DATA_SCHEMA`, R6.3/R6.24 y ASSETS_REGISTRY si entran props nuevos.
* [ ] Nota de cierre de R6.39 en GDD después de QA.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-10-23 | HU creada a partir del reporte PO: eliminar la variante Corredor por estrecha e incómoda; elevar ambientación, iluminación, identidad y decoración, y evaluar Terrain mediante PoC híbrida sin comprometer la conversión total. |
