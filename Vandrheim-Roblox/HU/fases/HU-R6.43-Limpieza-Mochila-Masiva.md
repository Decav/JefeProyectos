# HU-R6.43: Limpieza y venta masiva de ítems por rareza en la mochila (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R6.x / UI / Inventario
**Prioridad:** Alta — calidad de vida pre-lanzamiento
**Estado:** Cerrada — implementada (confirmación del PO 2026-10-23; diseño actualizado)
**Tipo:** Mejora de inventario con transacciones server-authoritative
**Fase GDD:** R6.43 — operaciones masivas seguras de mochila
**Depende de:** HU-R4 (inventario/equip), HU-R5 (VendorService/VendorConfig), HU-R5.2 (stacking), HU-R6.27 (UI/feedback), HU-R6.32 (borrado individual y protección de ítems), HU-ECONOMIA-01/02/03 (locks y escritura de inventario), `ItemConfig`, `ItemRarity`, `VendorConfig`, `Vandrheim-design.pen`
**No modifica:** rarezas, reglas de equipamiento, precios unitarios, trade/subasta ni el borrado individual existente.

---

### Narrativa (INVEST)

**Como** jugador que termina una run de dungeon,
**quiero** filtrar rarezas y vender o eliminar en conjunto los ítems seleccionados,
**para** limpiar rápidamente el equipo de poco valor sin repetir una acción por cada pieza.

---

### Descripción / Contexto

Limpiar ítems de baja rareza, especialmente piezas blancas que dejan de ser útiles a nivel alto, toma demasiadas acciones manuales en la dungeon. La mochila debe ofrecer un flujo masivo con selección explícita de rarezas, resumen previo y confirmación separada para vender o eliminar.

La cabecera de la mochila también debe quedar equilibrada visualmente: título del inventario centrado y tres acciones compactas asociadas a la limpieza masiva:

1. **Configuración** — abre un popover de rarezas seleccionables.
2. **Vender** — vende todos los ítems elegibles de las rarezas seleccionadas, después de confirmar.
3. **Eliminar** — elimina todos los ítems elegibles de las rarezas seleccionadas, después de confirmar.

El borrado individual existente en R6.32 se conserva. La venta individual de R5.2 continúa vendiendo una unidad por acción; esta HU añade una acción masiva separada que puede liquidar pilas completas.

**Criterio de hecho global:** después de configurar una o más rarezas, el jugador puede previsualizar, confirmar y completar una transacción masiva de venta o borrado de los ítems elegibles de la mochila, con totales exactos, sin perder/duplicar bienes ni afectar ítems equipados, bloqueados o protegidos.

---

### Diseño de Pencil revisado

Archivo activo: `Vandrheim-design.pen`. Frames seleccionados por el PO:

| ID | Frame | Uso |
|---|---|---|
| `nwaNs` | `Inventario de Eirik · Mochila` (500×484) | Mochila base, título centrado y toolbar de tres iconos. |
| `K5IhNc` | `Inventario de Eirik · Filtro múltiple` (500×484) | Popover de configuración con rarezas multi-select y botón Guardar. |
| `nDUnt` | `Inventario de Eirik · Confirmar venta` (500×484) | Resumen y confirmación de venta masiva. |
| `w8ZVMb` | `Inventario de Eirik · Confirmar eliminación` (500×484) | Resumen y confirmación irreversible de borrado masivo. |

**Coincide con la HU:** title centered; aparecen los botones de configuración, venta y basura; el filtro comunica una selección compartida para “vender + basura”; muestra estados activos/inactivos.

**Revisión final de Pencil y decisiones PO:**

1. **Legendario:** todavía no existe como rareza y se quitó del filtro final. La lista activa son las cuatro categorías canónicas (`Common`, `Uncommon`, `Rare`, `Epic`); `Unique` es una cualidad/flag de Epic, no una quinta rareza. Una rareza Legendaria futura requerirá definición aparte.
2. **Default:** confirmado por el PO: solo **Común/Common** comienza marcado. Las cuatro rarezas siguen pudiendo marcarse o desmarcarse; el estado de tres checks en `K5IhNc` es un ejemplo de multi-select, no el default inicial.
3. El diseñador agregó los estados `nDUnt` (venta) y `w8ZVMb` (eliminación), cada uno con resumen y acción propia.
4. El diseñador ajustó la legibilidad y los hitboxes del popover para PC/móvil en el arte final.

---

### Configuración de rarezas

* La acción Configuración abre un popover anclado a la cabecera, con las rarezas de `ItemRarity` y el nombre/color de UI canónicos: **Blanco/Common**, **Verde/Uncommon**, **Azul/Rare** y **Morado/Epic**.
* Cada fila incluye checkbox/toggle, nombre y swatch de rareza. La selección es multi-select: las mismas rarezas guardadas se aplican a **Vender** y **Eliminar**.
* `K5IhNc` muestra un botón **Guardar**: los checks modificados son borrador hasta guardarlos. Cerrar/cancelar descarta cambios sin guardar. El conteo y “N seleccionadas” muestran el borrador actual.
* Default confirmado por el PO en un perfil sin preferencia: **solo Blanco/Common seleccionado**. El jugador puede marcar/desmarcar las cuatro rarezas canónicas, incluida la selección de varias o ninguna; las tres checks de `K5IhNc` son un estado de muestra de multi-select.
* Al cambiar/guardar la selección, mostrar cuántas entradas/unidades elegibles y cuántos ítems protegidos coinciden. Si no hay rarezas seleccionadas o no hay ítems elegibles, deshabilitar Vender/Eliminar y explicar por qué.
* Usar únicamente las cuatro rarezas actuales de `ItemRarity`; **no mostrar Legendario en esta entrega**. `Unique` no se convierte automáticamente en una rareza separada.
* Conservar preferencia para el jugador en el mismo ámbito de preferencias existente; no guardarla dentro de una instancia de ítem ni hacer writes por toggle a cada frame.

---

### Contratos de venta, borrado y protección

#### Vista previa y confirmación

* Antes de abrir la confirmación, solicitar al servidor un resumen de la operación calculado desde el inventario autoritativo para las rarezas seleccionadas.
* La confirmación presenta:
  * Acción (**Vender** o **Eliminar**).
  * Rarezas incluidas.
  * Número de entradas de inventario y total de unidades/pilas afectadas.
  * Cantidad de ítems excluidos/protegidos.
  * En venta: oro total que se acreditará, calculado con precios reales de venta.
  * En borrado: advertencia **“No se puede recuperar”**.
* Cancelar cierra el modal sin cambiar ítems ni oro. Confirmar envía la intención al servidor; el server vuelve a validar y recalcular antes del commit.
* Si el inventario, los locks o los precios cambian entre resumen y confirmación, no ejecutar un resumen obsoleto: actualizar la vista previa y pedir nueva confirmación.

#### Venta masiva

* Añadir un contrato server-authoritative de venta masiva por rareza. La entrada del cliente es la lista de rarezas seleccionadas y un token/id de confirmación; el cliente **no envía** cantidades ni oro a acreditar.
* El servidor selecciona entradas elegibles en la mochila y usa el `VendorConfig`/valor unitario vigente para cada ítem.
* Venta masiva liquida **todas las unidades** de cada pila elegible seleccionada: `oro += precioUnitario × quantity`; elimina la entrada al vender la pila completa.
* La venta individual de R5.2 permanece unitaria; esta regla de venta de pila completa solo aplica al nuevo botón masivo.
* Eliminar y acreditar oro en una transacción atómica/idempotente conforme a ECON-03. Un reintento del mismo `operationId` no duplica oro ni venta.
* **Venta restringida al vendor:** Vender solo está habilitado mientras la ventana/sesión de vendor está abierta y el servidor valida una interacción vigente y distancia permitida en el Hub. Estar cerca del NPC sin abrirlo no basta.
* En la dungeon o sin sesión de vendor válida, Vender queda deshabilitado con el mensaje **“Acércate a un vendedor y abre su tienda para vender.”** El borrado masivo sigue disponible desde la mochila, sujeto a sus protecciones.
* Una vista previa de venta queda asociada al `vendorId`; si el vendor se cierra, el jugador abandona el Hub o sale del rango antes de confirmar, invalidarla sin mover ítems ni oro.

#### Borrado masivo

* Añadir contrato server-authoritative de borrado masivo por rareza. El servidor vuelve a resolver la selección desde el inventario y elimina las pilas completas de las entradas elegibles tras una confirmación vigente.
* El borrado no acredita oro ni admite reversión. La confirmación debe dejar claro cuántas entradas y unidades se perderán.
* Un reintento de confirmación es idempotente: no elimina otros ítems ni produce errores por instancias ya retiradas.

#### Ítems que no se pueden procesar

* Nunca incluir en venta/borrado masivo:
  * Ítems equipados, aunque su rareza esté seleccionada.
  * Ítems con lock/custodia `tradeLocked`, de subasta u otro lock activo.
  * Ítems declarados no vendibles/no eliminables por `ItemConfig`, misión o protección equivalente.
  * Ítems fuera de la mochila, pertenecientes a otro jugador o con instancia inválida.
* Los ítems bound pueden venderse si la regla actual de vendor lo permite (R5); ser bound por sí solo no invalida venta. Aplicar la política de `ItemConfig` para borrado, sin saltarse locks.
* Los ítems especiales/Unique protegidos no se hacen seleccionables en masa por tener rareza Epic; mostrar cuántos fueron excluidos. El jugador puede gestionarlos individualmente con los flujos normales.
* El servidor procesa/valida cada operación en la economía atómica actual; si no puede realizar la operación completa, no hay resultados parciales ni oro/ítems inconsistentes.

---

### UI / Presentación

* Centrar el título **Inventario** respecto a la ventana completa, no respecto al espacio restante después de los botones de acción.
* Replicar el toolbar compacto del frame `nwaNs` y su orden: Configuración, Vender, Eliminar. Usar `Icon_UI_settings.png`, `Icon_UI_sell_all.png` e `Icon_UI_trash.png` del diseño; los iconos-only deben tener accessible name/tooltip y estados foco/hover.
* Mantener la lectura de slots, cantidad `xN`, rareza, estado de equipamiento, tooltips y marcadores Z/X existentes.
* El popover de configuración sigue `K5IhNc`: checks, contador de seleccionadas y botón Guardar. Es accesible por hover/click en PC y tap en móvil; el cierre común no cierra toda la mochila por accidente.
* Usar los estados de confirmación del Pencil: venta `nDUnt` y borrado `w8ZVMb`. Cada modal tiene acciones **Confirmar**/**Cancelar**, resumen legible de la selección y protección contra doble click mientras la transacción está en curso.
* En móvil, targets táctiles adecuados, scroll de rarezas y modal dentro del área segura. Centrar el título no debe desplazar/ocultar accesos ni slots.

#### API / validación server-side

| Remote | Dir | Payload | Contrato |
|---|---|---|---|
| `RequestBulkInventoryPreview` | C→S | `{ action = "Sell"|"Delete", selectedRarities = {...}, vendorId? }` | Calcula desde mochila autoritativa; para Sell exige sesión de vendor activa/en rango; no acepta instanceIds, cantidades ni oro del cliente. |
| `BulkInventoryPreview` | S→C | `{ previewId, inventoryVersion, entriesByRarity, unitsByRarity, excludedByReason, totalGold?, vendorId? }` | Resumen sanitizado y temporal; en Sell queda vinculado al vendor y al precio estimado real. |
| `RequestConfirmBulkInventoryAction` | C→S | `{ previewId }` | Confirma el plan vigente; servidor revalida sesión/vendor, distancia, rareza, locks, elegibilidad y precio. |
| `BulkInventoryActionResult` | S→C | `{ success, action, entriesAffected, unitsAffected, goldDelta?, stalePreview?, errorCode? }` | Resultado final; un `operationId` repetido no duplica venta/borrado. |

* `previewId` es generado/guardado por el servidor y expira (TTL corto configurable). Si `inventoryVersion` cambió, el servidor no ejecuta el preview viejo: devuelve `stalePreview` y la UI refresca el resumen para una nueva confirmación.
* El servidor genera el `operationId` al confirmar y lo usa para idempotencia; el cliente no envía IDs de instancia ni un importe de oro como autoridad.
* La transacción sobre el conjunto elegible es atómica: si falla la escritura, no hay venta parcial ni pérdida parcial de ítems.
* Confirmar una venta vuelve a validar que siga abierta la sesión de vendor vinculada al preview y que el jugador permanezca en rango permitido.

---

### Criterios de aceptación (Gherkin)

#### Escenario 1: Título y acciones

* **GIVEN** la mochila abierta en PC o móvil
* **WHEN** se muestra la cabecera
* **THEN** el título Inventario aparece centrado y los tres iconos aparecen en el orden del frame `nwaNs`: Configuración, Vender, Eliminar

#### Escenario 2: Filtro por rareza

* **GIVEN** el jugador abre Configuración
* **WHEN** marca Blanco y Azul, desmarca las otras rarezas y pulsa Guardar
* **THEN** la misma selección guardada aplica a los resúmenes de Vender y Eliminar y el conteo corresponde a los ítems elegibles

#### Escenario 3: Default para basura blanca

* **GIVEN** un jugador sin preferencia guardada
* **WHEN** abre la mochila por primera vez
* **THEN** solo Blanco/Common aparece marcado por defecto; las otras rarezas quedan desmarcadas pero se pueden seleccionar manualmente

#### Escenario 4: Confirmación de borrado masivo

* **GIVEN** hay varios ítems elegibles de una o más rarezas seleccionadas
* **WHEN** pulsa Eliminar
* **THEN** ve el total de entradas/unidades y la advertencia de irreversibilidad antes del commit
* **AND** Cancelar conserva todo; Confirmar elimina solo las entradas elegibles del resumen

#### Escenario 5: Confirmación de venta masiva

* **GIVEN** hay varios ítems vendibles de rarezas seleccionadas y una sesión de vendor activa en el Hub
* **WHEN** pulsa Vender
* **THEN** el resumen muestra la cantidad y oro total exacto según VendorConfig
* **AND** Confirmar acredita ese oro y vende todas las unidades/pilas elegibles en una transacción

#### Escenario 5.1: Vender fuera de un vendor

* **GIVEN** la mochila está abierta en la dungeon, lejos del NPC, o el jugador no abrió la ventana de vendor
* **WHEN** mira o intenta pulsar Vender
* **THEN** Vender aparece deshabilitado con “Acércate a un vendedor y abre su tienda para vender”; Eliminar sigue habilitado según las protecciones

#### Escenario 5.2: Vendor deja de ser válido antes de confirmar

* **GIVEN** el jugador generó una vista previa de venta desde una sesión de vendor
* **WHEN** cierra la tienda, sale del Hub o se aleja más del rango permitido antes de confirmar
* **THEN** el servidor invalida el preview y no vende ni acredita oro

#### Escenario 6: Stacking y ventas existentes

* **GIVEN** hay pilas de ítems Common y otros ítems individuales
* **WHEN** se ejecuta venta masiva y luego venta individual
* **THEN** la masiva liquida la pila completa seleccionada; la venta individual de R5.2 sigue descontando solo una unidad

#### Escenario 7: Ítems protegidos

* **GIVEN** hay ítems seleccionados por rareza que están equipados, tradeLocked, en custodia o marcados no vendibles/no eliminables
* **WHEN** se genera vista previa y se confirma la operación
* **THEN** el resumen los marca como excluidos y el servidor no los vende ni elimina

#### Escenario 8: Datos cambian antes de confirmar

* **GIVEN** una vista previa abierta
* **WHEN** el inventario/lock/precio cambia antes de confirmar
* **THEN** el servidor rechaza el resumen obsoleto, recalcula y pide confirmar el nuevo resultado; no ejecuta una operación parcial

#### Escenario 9: Sin selección o sin coincidencias

* **GIVEN** no hay rarezas seleccionadas o ninguna coincidencia elegible
* **WHEN** el jugador consulta las acciones masivas
* **THEN** Eliminar/Vender están deshabilitados con feedback claro y no envían transacciones

#### Escenario 10: Persistencia y seguridad

* **GIVEN** el jugador ha guardado su selección de rarezas
* **WHEN** cierra/reabre la mochila o vuelve a entrar
* **THEN** se conserva la preferencia; un cliente manipulado no puede vender/borrar bienes ajenos, protegidos, ni acreditar oro arbitrario

#### Escenario 11: Móvil y regresión

* **GIVEN** el inventario en dispositivo táctil
* **WHEN** abre filtros, revisa el resumen, confirma/cancela y desplaza la bolsa
* **THEN** los controles no interfieren con scroll/tap-hold del inventario, quedan dentro del área segura y no se pierden slots

#### Escenario 12: Solo rarezas vigentes

* **GIVEN** se abre la configuración de rarezas
* **WHEN** se muestran las categorías disponibles
* **THEN** aparecen Común, Poco común, Raro y Épico con labels/colores canónicos; Legendario no aparece en esta HU

---

### Alcance

#### Incluye

* Título del inventario centrado.
* Botones de Configuración de rarezas, eliminar masivo y vender masivo; venta masiva disponible solo durante una sesión de vendor válida.
* Previsualización y confirmación independiente por acción.
* Venta de todas las unidades de pilas elegibles con precios actuales.
* Protecciones server-side para equipados, locks y objetos no procesables.
* Persistencia de preferencias de filtros y QA PC/móvil.

#### No incluye

* Cambiar tablas de precio o balance; usa `VendorConfig` vigente.
* Cambiar la venta individual, que sigue vendiendo una unidad según R5.2.
* Reordenar la mochila, borrar ítems equipados o saltar trade/auction locks.
* Eliminar automáticamente al recoger loot; la acción siempre requiere que el jugador abra y confirme.

---

### Definition of Done (DoD)

* [x] Integración visual corresponde a `nwaNs` (mochila), `K5IhNc` (filtro), `nDUnt` (confirmar venta) y `w8ZVMb` (confirmar eliminación): título centrado, toolbar y estados completos.
* [x] El PO confirma Common/Blanco como único default; las otras rarezas canónicas siguen siendo seleccionables.
* [x] El popover lista solo las cuatro rarezas vigentes, con etiquetas/colores canónicos; Legendario queda fuera de esta entrega.
* [x] Selección de rarezas gobierna igual Eliminar y Vender; conteos/preview se recalculan correctamente.
* [x] Delete y sell masivos exigen confirmación; cancelar no muta inventario ni oro.
* [x] Bulk sell acredita suma exacta y liquida pilas completas; unit sell continúa unitario.
* [x] Bulk sell está deshabilitado fuera de una ventana/sesión de vendor abierta; servidor revalida `vendorId` y distancia al crear el preview y al confirmar.
* [x] Equipados, locks, custodia, ítems especiales protegidos y elementos no procesables se excluyen y se explican en el resumen.
* [x] Operaciones server-authoritative, atómicas e idempotentes, sin mutaciones parciales ni duplicación de oro.
* [x] Preferencia sobre rarezas persiste según el sistema de usuario vigente.
* [x] Confirmaciones de venta/borrado usan los estados `nDUnt`/`w8ZVMb`; resumen/acciones expresan cantidad/importe exactos.
* [x] PC/móvil probado: title center, hover/tap, scroll, popover, confirmaciones, bolsa vacía/llena/stacked; textos y hitboxes legibles, sin clipping ni errores rojos.
* [x] R5/R5.2/R6.32, equipo, trade/auction locks y persistence sin regresiones; actualizar DATA_SCHEMA/PROJECT_ARCHITECTURE/RC si cambia el contrato.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-10-23 | HU creada a partir del pedido PO: centrar Inventario y añadir filtro de rareza compartido para borrado/venta masiva con confirmación y protección de ítems. |
| 2026-10-23 | Frames finales en Pencil: `nwaNs` (mochila), `K5IhNc` (filtro), `nDUnt` (confirmación venta) y `w8ZVMb` (confirmación eliminación). PO confirma Común como único default, cuatro rarezas y estados finales entregados. |
| 2026-10-23 | Aclaración de flujo: vender masivamente requiere sesión de vendor abierta y rango validado; eliminar masivamente sigue disponible desde la mochila en la dungeon. |
| 2026-10-23 | PO confirma implementación completa y cierre de HU-R6.43. |
