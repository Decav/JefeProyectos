# HU-R6.51: Mercader Errante — tienda rotativa de ítems (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Mundo / Economía / Retención
**Prioridad:** Alta — motivo de retorno y sumidero de oro
**Estado:** Implementada (reporte PO 2026-11-06); QA pendiente
**Tipo:** NPC + tienda rotativa diaria compartida por servidor (dev)
**Fase GDD:** Economía / Hub (post-R6.49; adelanto de contenido de mundo)
**Depende de:** HU-R6.49 (mapa/Hub y Valgard), HU-R4 (inventario/equip), HU-ITEMS-01/04/06/07/08 (items, tiers y joyería), HU-R5 (oro/VendorService), `VendorService`/`VendorUI`, `InventoryService`, `ItemConfig`
**Componentes observados:** Valgard, `VendorConfig`, `VendorService`, `VendorUI`, `InventoryService`, `ItemConfig`, oro del personaje
**No modifica:** stats de ítems, economía base, loot de dungeon, uniques/épicas de jefes, quests ni balance.

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** un mercader en Valgard que cambie su stock cada día y venda equipo azul y, con suerte, morado,
**para** tener una razón para volver y un lugar donde gastar oro.

**Como** equipo,
**quiero** una tienda rotativa acotada, determinista, server-authoritative y compartida por servidor,
**para** agregar valor sin inundar la economía ni regalar ítems de jefe.

---

### Descripción / Contexto

Valgard necesita un NPC con una tienda rotativa diaria. El stock se genera **una vez por servidor y día UTC** y es **compartido por todos los jugadores del servidor**; no hay stock personal por cuenta, clase ni personaje:

* Por lo general, **1 ítem azul garantizado** en el stock.
* El resto: verdes y, con baja probabilidad, **otro azul**.
* **Máximo 1 morado**, con probabilidad muy baja.
* El morado solo puede ser **joyería morada** o **armas moradas del Jotunn**; nunca las armas únicas del Frost Lord ni las partes del tier Frost Helada.
* Los verdes son **piezas de armadura y joyería que el herrero no vende**; no se incluyen armas verdes porque el herrero ya las cubre.

El stock se mantiene mientras el servidor esté activo; las compras agotan el slot para todos. Se renueva a las **00:00 UTC** o cuando el servidor se reinicia. Cambiar de servidor puede mostrar otro stock, porque cada servidor genera el suyo; no se puede re-rolar el stock del mismo servidor rejoinendo.

**Criterio de hecho global:** el Mercader Errante aparece en Valgard y vende un stock diario por servidor de hasta 10 ítems, compartido, con 1 azul garantizado, azules extra/verdes, máximo 1 morado de la pool permitida, precios por rareza (verde 700, azul 1500, morado 3000) y compra server-authoritative con validación de clase, nivel, oro y mochila; el stock y los slots vendidos se renuevan a las 00:00 UTC o al reiniciar el servidor.

---

### Especificaciones Técnicas / Contratos

#### 1. NPC y acceso

* Nuevo NPC `rotating_merchant` — **"Mercader Errante"**.
* Ubicación: `MarketStalls` de Valgard (HU-R6.49), cerca de los vendors y visible desde `CentralPlaza`; sin bloquear el camino.
* Modelo: placeholder reutilizable; el diseñador puede entregar el modelo final después. No crear arte nuevo en esta HU.
* `ProximityPrompt` (E / tap) que abre la `VendorUI` existente con el stock rotativo.
* No es quest giver, no tiene diálogo ramificado ni tienda de Robux.
* La tienda muestra el **stock del servidor**; no hay stock personal. La UI indica clase y nivel requerido de cada ítem.

#### 2. Generación del stock

* **10 slots** (hasta 10 ítems; si no hay suficientes elegibles, se muestran menos; sin duplicados de template).
* **Por servidor y día UTC**: `seed = JobId + dateKey`. Se genera una vez y se cachea en memoria del servidor; todos los jugadores del mismo servidor ven el mismo stock.
* No se filtra por la cuenta, clase o nivel del jugador que abre la tienda. El generador procura un surtido variado entre clases y bandas de nivel; no garantiza un ítem usable por cada jugador.
* Filtro global de elegibilidad:
  * Sin ítems `Unique`; sin partes de armadura del tier Frost Helada; sin armas únicas del Frost Lord.
  * Los verdes solo salen del pool de armadura y joyería (ver §3).
  * Los azules/morados salen de su pool permitido.
  * Nivel requerido: el ítem puede ser de cualquier banda; la compra valida el nivel del personaje activo.
* Distribución:
  * **1 azul garantizado** si la pool global tiene azules; si no, se reemplaza por un verde.
  * **1 azul extra** con 20 % de probabilidad (máximo 2 azules en total).
  * **1 morado** con 3 % de probabilidad (máximo 1; si no hay morado elegible, no se genera).
  * Resto: **verde** (todos los slots restantes; sin más azules/morados).
  * Sin duplicados de template en el mismo stock.
* El stock puede tener 10 ítems; si la pool no alcanza, se completa con menos y la UI lo muestra.
* El stock no se re-rola al abrir/cerrar la tienda ni al rejoin del mismo servidor.

#### 3. Pool de ítems

**Verdes:** solo **piezas de armadura y joyería** existentes en `ItemConfig`, de cualquier clase, con su nivel requerido. No se incluyen armas verdes; el herrero ya las vende.

**Azules:** armas, armaduras, collares y anillos existentes, de cualquier clase; sin `Unique` y sin armadura Frost Helada.

**Morados permitidos (máximo 1):**

| Tipo | Templates |
|---|---|
| Joyería | `collar_frost`, `ring_frost_atk`, `ring_frost_matk` |
| Armas del Jotunn | `sword_frost`, `greatsword_frost`, `bow_frost`, `wand_frost`, `shield_frost` |

**Morados prohibidos:**

* Armas únicas del Frost Lord: `unique_frost_edge`, `unique_frost_greatsword`, `unique_frostbow`, `unique_glacial_wand`.
* Partes de armadura del tier Frost Helada (`paladin_*_frost`, `hunter_*_frost`, `cleric_*_frost`).
* Cualquier otro `Unique` o ítem de jefe fuera de la tabla permitida.

El pool no se filtra por clase: el stock puede incluir piezas de cualquier clase, y la UI muestra la clase requerida. La compra se bloquea si el personaje activo no coincide con la clase del ítem; la joyería es universal. No crear ítems nuevos.

#### 4. Precios y compra

* Moneda: **oro** del personaje (no Robux).
* Precios por rareza, configurables y distintos a los del herrero:
  * Verde: 700.
  * Azul: 1500.
  * Morado: 3000.
* Valores iniciales; ajustar en balance/economía. Los verdes son piezas de armadura/joyería que el herrero no vende; no se usan precios de armas del herrero.
* Compra server-authoritative y compartida:
  * Validar slot disponible, clase, nivel, oro y mochila/equipo.
  * Un ítem por slot; al comprar, el slot queda **vendido para todos** y no se puede volver a comprar.
  * Dos jugadores no pueden comprar el mismo slot; la operación es atómica.
  * Si la mochila está llena, bloquear con aviso; no entregar parcial.
  * Si el oro no alcanza, bloquear con aviso.
  * Idempotente: rejoin/reintento no duplica la compra ni el ítem.
* El ítem comprado se genera con el pipeline de instancias/rolls existente; no hardcodear stats.

#### 5. Reset y persistencia

* Reset a las **00:00 UTC** (`dateKey = YYYY-MM-DD`) y al reiniciar el servidor.
* Estado **en memoria del servidor**: `rotatingShop = { dateKey, jobId, slots, soldSlots, purchases }`.
* El stock se genera una vez por servidor/día; no se guarda en DataStore ni se comparte entre servidores.
* Las compras y slots vendidos se conservan al rejoin del **mismo servidor**; al cambiar de servidor se usa el stock de ese servidor.
* Al cambiar el día o reiniciar el servidor se genera un stock nuevo y los slots vendidos vuelven a 0; los ítems ya comprados permanecen en el inventario de cada personaje.
* No se acumulan stocks ni compras de días anteriores.
* No hay stock ni compras por cuenta/clase/personaje; la tienda es del servidor.

#### 6. UI

* Reutilizar `VendorUI`; no crear una ventana nueva.
* Mostrar hasta 10 ítems: icono, nombre, rareza, clase, nivel requerido, stats/tooltip y precio.
* Estados: disponible, vendido, otra clase, nivel insuficiente, oro insuficiente, mochila llena, stock vacío.
* Indicar "Stock del servidor" y "Se renueva en X h"; no mostrar "stock personal".
* Al comprar un ítem, el resto de jugadores ve el slot como vendido en la siguiente apertura/refresh.
* PC y móvil; botones táctiles ≥44 px.
* Sin minimapa; el NPC se marca en Valgard.

#### 7. Analítica

* Eventos: `shop_opened`, `shop_stock_generated` (conteo por rareza y servidor), `shop_purchase`, `shop_purchase_blocked_gold`, `shop_purchase_blocked_bag`, `shop_purchase_blocked_class`, `shop_purchase_blocked_level`, `shop_purchase_blocked_sold`, `shop_reset`.
* Medir rareza comprada, oro gastado y slots vendidos por servidor.

#### 8. Seguridad y anti-abuso

* El cliente no puede generar stock, cambiar precios ni comprar sin validación.
* No se puede re-rolar el stock del mismo servidor con rejoin/apertura repetida.
* Cambiar de servidor muestra el stock de ese servidor; no es un re-rolo del mismo stock.
* No se puede comprar dos veces el mismo slot ni duplicar ítems; la compra compartida es atómica.
* El pool morado no incluye uniques ni armadura Frost; validar por template/rareza en servidor.
* No se agrega oro ni ítems por error de compra.
* No se persiste stock ni compras entre servidores.

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Mercader en Valgard

* **GIVEN** el mapa nuevo activo
* **WHEN** el jugador camina por Valgard
* **THEN** encuentra al Mercader Errante en `MarketStalls` con prompt funcional
* **AND** abre la tienda con el stock del servidor

#### Escenario 2: Stock diario del servidor

* **GIVEN** un servidor con fecha UTC actual
* **WHEN** un jugador abre la tienda por primera vez en el día
* **THEN** ve hasta 10 ítems, con 1 azul garantizado
* **AND** otro jugador del mismo servidor ve el mismo stock
* **AND** el stock se mantiene igual al rejoin del mismo servidor

#### Escenario 3: Compra compartida

* **GIVEN** un slot disponible y dos jugadores en el mismo servidor
* **WHEN** el primer jugador compra el ítem
* **THEN** el oro y el ítem se descuentan/entregan solo a ese personaje
* **AND** el slot queda vendido para el segundo jugador
* **AND** no se duplica el ítem ni el cobro

#### Escenario 4: Azul extra

* **GIVEN** la generación del stock
* **WHEN** se aplica la probabilidad de azul extra
* **THEN** puede aparecer como máximo 1 azul adicional (máximo 2 azules)
* **AND** el resto es verde

#### Escenario 5: Morado raro

* **GIVEN** la generación del stock
* **WHEN** se aplica la probabilidad de morado
* **THEN** aparece como máximo 1 morado, con probabilidad baja
* **AND** nunca aparece un unique del Frost Lord ni una armadura Frost
* **AND** si aparece, es joyería morada o un arma morada del Jotunn

#### Escenario 6: Clase y nivel

* **GIVEN** un stock compartido que puede incluir piezas de cualquier clase
* **WHEN** el jugador activo abre la tienda
* **THEN** ve los ítems de otras clases marcados como "Otra clase" y no puede comprarlos
* **AND** la joyería es universal
* **AND** un ítem por encima de su nivel se muestra con el requisito y no se puede comprar

#### Escenario 7: Precios

* **GIVEN** un ítem en el stock
* **WHEN** el jugador consulta su precio
* **THEN** el precio por rareza es verde 700, azul 1500 o morado 3000
* **AND** no se reutilizan los precios del herrero
* **AND** los verdes son armadura/joyería, no armas

#### Escenario 8: Sin oro

* **GIVEN** un ítem disponible y oro insuficiente
* **WHEN** el jugador intenta comprar
* **THEN** la compra se bloquea y se muestra el motivo
* **AND** no se modifica el inventario ni el oro

#### Escenario 9: Mochila llena

* **GIVEN** un ítem disponible y mochila llena
* **WHEN** el jugador intenta comprar
* **THEN** la compra se bloquea
* **AND** el slot sigue disponible

#### Escenario 10: Reset diario

* **GIVEN** un stock comprado o parcialmente comprado
* **WHEN** cambia el día UTC
* **THEN** se genera un stock nuevo y los slots vendidos vuelven a 0
* **AND** no se acumulan compras ni stock anterior

#### Escenario 11: Sin re-rolo en el mismo servidor

* **GIVEN** un stock generado
* **WHEN** el jugador rejoin al mismo servidor
* **THEN** ve el mismo stock y los mismos slots vendidos del día
* **AND** no puede re-rolar cerrando/abriendo la tienda
* **AND** si cambia a otro servidor, ese servidor puede tener otro stock

#### Escenario 12: Reinicio del servidor

* **GIVEN** un servidor con stock y compras
* **WHEN** el servidor se reinicia
* **THEN** se genera un stock nuevo y los slots vendidos vuelven a 0
* **AND** los ítems ya comprados permanecen en el inventario de cada personaje
* **AND** no se persiste stock ni compras entre servidores

#### Escenario 13: Regresión

* **GIVEN** la tienda implementada
* **WHEN** se juega solo/party, hub/dungeon, PC/móvil
* **THEN** economía, inventario, vendors existentes, loot y quests siguen funcionando
* **AND** no hay errores rojos

---

### Comportamiento Visual / UI-UX

* El Mercader Errante debe distinguirse de los vendors fijos; prompt y nombre claros.
* La tienda se siente parte de Valgard y usa el lenguaje visual existente.
* Mostrar rareza con borde/color, clase y nivel requerido; tooltip completo.
* El stock es del servidor: los ítems vendidos se ven como vendidos para todos.
* Estados vendido/otra clase/nivel insuficiente/insuficiente/mochila llena visibles y no ambiguos.
* Sin minimapa; el NPC se encuentra caminando Valgard.

---

### Alcance

#### Incluye

* NPC `rotating_merchant` en Valgard.
* Stock diario determinista por servidor/día; hasta 10 ítems, compartido.
* 1 azul garantizado, azul extra 20 %, morado 3 % (máx. 1), resto verde.
* Verdes limitados a armadura y joyería; azules de todo el gear; morados limitados a joyería y armas del Jotunn.
* Precios en oro: verde 700, azul 1500, morado 3000 (config).
* Compra server-authoritative, compartida y atómica; validación de clase, nivel, oro y mochila.
* Reset UTC/reinicio y UI existente de vendor.

#### No incluye

* Stock personal por cuenta/clase/personaje.
* Persistencia de stock o compras entre servidores.
* Nuevos ítems, stats, uniques o épicas.
* Cambios a loot, dungeon, quests, economía base o balance.
* Subasta, trade ni Robux.
* Diseño de una ventana nueva; se reutiliza VendorUI.
* Modelo final del NPC; placeholder hasta el diseñador.

---

### Definition of Done (DoD)

* [ ] NPC Mercader Errante en Valgard con prompt.
* [ ] Stock de hasta 10 ítems por servidor/día, compartido; 1 azul garantizado, azul extra 20 %, morado 3 % máx. 1.
* [ ] Resto verde; verdes solo armadura/joyería; sin duplicados.
* [ ] Pool morado solo joyería + armas del Jotunn; sin uniques Frost ni armadura Frost.
* [ ] UI muestra clase/nivel; compra bloqueada para otra clase o nivel insuficiente; joyería universal.
* [ ] Precios 700/1500/3000; distintos a los del herrero; sin precios de armas verdes.
* [ ] Compra compartida y atómica; validación de oro/mochila/slot; sin duplicados.
* [ ] Reset UTC/reinicio; sin DataStore; sin persistencia entre servidores.
* [ ] UI vendor existente con estados; PC/móvil.
* [ ] Analítica y QA; sin errores rojos.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota de cierre en GDD/roadmap.

---

### Decisiones por defecto

| Tema | Default |
|---|---|
| NPC | `rotating_merchant` — Mercader Errante |
| Stock | Hasta 10 ítems; sin duplicados |
| Seed | `JobId + dateKey`; stock del servidor |
| Compartido | Sí; stock del servidor por rareza |
| Stock morado | 1 unidad compartida por servidor (agotado al comprarse) |
| Stock azul | 5 unidades compartidas por slot para el servidor (agotado al llegar a 0) |
| Stock verde | Infinito (sin límite de stock, siempre disponible) |
| Límite personaje | Máximo 1 compra por personaje al día en slots azules y morados |
| Garantizado | 1 azul si hay elegible; si no, verde |
| Azul extra | 20 %; máximo 2 azules |
| Morado | 3 %; máximo 1 |
| Resto | Verde (todos los slots restantes) |
| Pool verde | Armadura y joyería; sin armas |
| Pool azul | Todo el gear; sin uniques ni armadura Frost |
| Pool morado | Joyería Frost + armas épicas del Jotunn |
| Prohibido | Uniques Frost y armadura Frost |
| Clase/nivel | Stock global; UI valida clase/nivel; joyería universal |
| Precios | Verde 700 / azul 1500 / morado 3000 (config) |
| Moneda | Oro |
| Reset | 00:00 UTC y reinicio del servidor |
| Persistencia | Memoria del servidor; sin DataStore ni cross-server |
| Re-rolo | Prohibido en el mismo servidor; otro servidor puede tener otro stock |

---

### Estimación (orientativa)

2–3 sesiones del dev: NPC, generación de stock por servidor, pools/filtros, compra compartida, UI y QA.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-11-04 | Creación de HU-R6.51: Mercader Errante con tienda rotativa diaria, 1 azul garantizado, azul extra 20 %, morado 3 % máximo 1, pool morado limitado a joyería y armas del Jotunn, sin uniques Frost ni armadura Frost; compra en oro y reset UTC. |
| 2026-11-04 | Ajuste PO: el stock es **por servidor y compartido** (no por cuenta/clase/personaje); compras compartidas y atómicas. Precios distintos al herrero: blanco 300, verde 700, azul 1500, morado 3000. Blancos/verdes limitados a armadura y joyería que el herrero no vende; se eliminan armas blancas/verdes. |
| 2026-11-05 | Ajuste PO: se eliminan los ítems blancos; el stock mínimo es verde y todos los slots restantes son verdes. Se retira el precio blanco 300; precios vigentes verde 700, azul 1500 y morado 3000. |
| 2026-11-06 | Ajuste PO: diferenciación de stock por rareza para evitar desabastecimiento total por un solo jugador: los morados tienen 1 de stock por servidor, los azules tienen un máximo de 5 de stock por slot para el servidor, y los verdes tienen stock infinito (siempre disponibles). Límite de 1 compra por personaje al día en ítems azules y morados para evitar acaparamiento. Solución a la latencia de clics: debounce inmediato en cliente y estado visual de procesamiento por botón en VendorClient para evitar colas de clics desfasadas. |
| 2026-11-06 | Implementada (reporte PO 2026-11-06); QA pendiente. |
