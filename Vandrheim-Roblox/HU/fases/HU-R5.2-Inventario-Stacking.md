## HU-R5.2: Stacking de inventario y cantidades

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** Inventario / Economía / R5.2  
**Prioridad:** Alta  
**Estado:** Completada (implementada; reporte equipo 2026-08-22)  
**Fase GDD:** R5.2 (extensión posterior a R5)  
**Depende de:** HU-R4 (inventario), HU-R5 (vendors y consumibles)  
**No modifica:** `rc010` ni el alcance cerrado de vendors/economía de R5.

---

### **Narrativa (INVEST)**

**Como** jugador,  
**quiero** que los ítems compatibles se agrupen en pilas y que la cantidad sea visible,  
**para** administrar mi inventario sin ocupar una entrada por cada unidad.

---

### **Descripción del Requerimiento / Contexto**

Actualmente cada unidad de ítem se guarda como una entrada independiente. Esta HU agrega stacking configurable por ítem y cantidades persistentes, integrándolo con compra, uso, venta y UI.

La capacidad de la bolsa pasa a contabilizar **pilas ocupadas**: una pila, aunque contenga varias unidades, ocupa un slot.

El comportamiento de venta es deliberadamente unitario: una acción vende una unidad y nunca liquida una pila completa en el MVP.

---

### **Especificaciones Técnicas / Contratos de API**

#### **ItemConfig (data-driven)**

Cada ítem debe definir su política de stacking:

```luau
{
  templateId = "potion_health",
  type = "Consumable",
  stackable = true,
  maxStack = 20,
}
```

Defaults cerrados:

| Tipo | `stackable` | `maxStack` |
|------|-------------|------------|
| Consumibles actuales (pociones HP/MP) | `true` | `20` |
| Armas y armaduras | `false` | `1` |
| Tipo no definido / futuro | `false` | `1` hasta que producto lo configure |

* `maxStack` es configurable por `ItemConfig`; no hardcodear el valor en `InventoryService`.
* Una pila solo puede mezclar unidades compatibles del mismo `templateId` y política de stacking.
* Equipo con rolls, rareza o estado propio conserva una entrada independiente.

#### **Estado de instancia**

Las entradas de inventario deben soportar:

```luau
{
  instanceId = "...",
  templateId = "potion_health",
  quantity = 1,
  -- demás campos actuales de la instancia
}
```

* Si una entrada persistida no tiene `quantity`, se interpreta como `1` durante la migración/lectura.
* `quantity` siempre es entero positivo y nunca puede superar `maxStack`.
* Las pilas ocupan un slot; una pila de `x20` ocupa lo mismo que una pila de `x1`.
* Los 20 slots actuales representan **20 pilas ocupadas**, no 20 unidades.

#### **Compra**

`RequestBuyItem { vendorId, templateId, qty }` conserva su contrato.

* El servidor valida `qty >= 1`, precio, oro y capacidad.
* Primero completa pilas compatibles existentes.
* Después crea las pilas adicionales necesarias, respetando `maxStack`.
* Si no hay capacidad para todas las unidades solicitadas, rechaza la transacción completa; no compra parcialmente.
* La transacción es server-authoritative y atómica.

#### **Uso de consumible**

`RequestUseConsumable { instanceId }` conserva su contrato.

* El servidor valida propiedad, ubicación en bolsa, tipo consumible, cooldown y `quantity > 0`.
* Aplica el efecto y descuenta exactamente `1` unidad.
* Si la cantidad llega a `0`, elimina la entrada.

#### **Venta**

`RequestSellItem { instanceId }` conserva su contrato.

* Cada acción vende exactamente `1` unidad de la entrada indicada.
* El servidor acredita el precio unitario y descuenta `1` de `quantity`.
* Si la cantidad llega a `0`, elimina la entrada.
* No existe venta de pila completa en el MVP.
* Ítems bound siguen pudiéndose vender a NPC; trade entre jugadores no cambia.

#### **Persistencia y seguridad**

* `quantity` persiste junto con la entrada de inventario.
* Toda modificación valida límites en servidor y se guarda con las transacciones existentes.
* El cliente no puede establecer una cantidad arbitraria, superar `maxStack`, vender unidades inexistentes ni duplicar ítems.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Configuración por ítem**

* **GIVEN** una poción configurada como `stackable=true`, `maxStack=20`
* **WHEN** el servidor crea o agrega unidades
* **THEN** ninguna pila supera 20 unidades
* **AND** armas y armaduras permanecen en entradas individuales (`maxStack=1`)

#### **Escenario 2: Compra que completa una pila**

* **GIVEN** una pila de Poción HP con `quantity=15`
* **WHEN** el jugador compra 3 unidades
* **THEN** la pila pasa a `quantity=18`
* **AND** no se crea una nueva entrada

#### **Escenario 3: Compra que crea varias pilas**

* **GIVEN** una pila de Poción HP con `quantity=18`
* **WHEN** el jugador compra 5 unidades
* **THEN** la pila existente queda en 20
* **AND** se crea una segunda pila con 3 unidades

#### **Escenario 4: Capacidad de bolsa**

* **GIVEN** 20 pilas ocupadas en la bolsa
* **WHEN** el jugador intenta comprar o recibir otro ítem que necesita una nueva pila
* **THEN** el servidor rechaza la operación por bolsa llena
* **AND** no pierde oro ni crea unidades parciales

#### **Escenario 5: Uso unitario**

* **GIVEN** una pila de Poción HP con `quantity=4`
* **WHEN** el jugador usa la poción
* **THEN** el efecto se aplica una vez
* **AND** la pila queda en `quantity=3`

#### **Escenario 6: Eliminación de pila vacía**

* **GIVEN** una pila con `quantity=1`
* **WHEN** se usa o vende su última unidad
* **THEN** la entrada se elimina de la bolsa

#### **Escenario 7: Venta unitaria**

* **GIVEN** una pila de 20 pociones
* **WHEN** el jugador ejecuta una venta
* **THEN** recibe el precio de una unidad
* **AND** la pila queda en 19
* **AND** la pila completa no se elimina

#### **Escenario 8: Cantidad visible**

* **GIVEN** una entrada con `quantity > 1`
* **WHEN** se muestra el inventario
* **THEN** la UI muestra la cantidad, por ejemplo `x20`
* **AND** una entrada con `quantity=1` no genera una cantidad incorrecta

#### **Escenario 9: Datos existentes**

* **GIVEN** una entrada persistida de una versión anterior sin campo `quantity`
* **WHEN** se carga el perfil
* **THEN** se interpreta como `quantity=1`
* **AND** el ítem no se pierde ni se duplica

#### **Escenario 10: Anti-exploit**

* **GIVEN** un cliente envía cantidades negativas, mayores a `maxStack`, o una venta repetida inválida
* **WHEN** el servidor procesa la solicitud
* **THEN** rechaza la operación
* **AND** el oro y el inventario permanecen consistentes

---

### **Comportamiento Visual e Interfaz (UI/UX) / Reglas de Negocio**

* Mostrar `xN` en el slot cuando `quantity > 1`.
* La capacidad de bolsa se calcula por pilas ocupadas.
* Vender una pila siempre significa vender una unidad por acción; no agregar botón de vender pila completa en esta HU.
* No cambiar precios, cooldown de pociones, reglas de bound ni economía de `rc010`.
* Mantener la UI y controles existentes; solo agregar cantidad y actualización correcta del slot.

---

### **Alcance**

#### Incluye

* Campos configurables `stackable` y `maxStack` en `ItemConfig`.
* Campo persistente `quantity` en entradas de inventario.
* Merge de pilas y creación de pilas adicionales.
* Capacidad de 20 slots medida por pilas ocupadas.
* Integración con compra, uso, venta y recepción de ítems.
* Venta de una unidad por acción.
* Cantidad visible en la UI.
* Compatibilidad con entradas existentes interpretadas como `quantity=1`.
* Validaciones server y persistencia.

#### No incluye

* Venta de pila completa o selector de cantidad para vender.
* Nuevos tipos de ítems, materiales, crafting o trade entre jugadores.
* Cambios en precios, cooldowns, rarezas, BoE o reglas de vendors.
* Modificaciones de `rc010`.

---

### **Definition of Done (DoD)**

* [ ] `ItemConfig` define stacking sin valores hardcodeados en el servicio.
* [ ] Pociones apilan hasta 20; equipo ocupa una unidad por entrada.
* [ ] 20 slots representan 20 pilas ocupadas.
* [ ] Compra `qty` completa pilas antes de crear nuevas y rechaza overflow de forma atómica.
* [ ] Uso y venta descuentan exactamente una unidad.
* [ ] Las pilas vacías se eliminan.
* [ ] La UI muestra cantidades correctamente.
* [ ] Entradas antiguas sin `quantity` se cargan como `1`.
* [ ] Validación server evita cantidades inválidas, duplicación y venta no autorizada.
* [ ] Cantidades persisten tras rejoin.
* [ ] Sin errores rojos en compra → stack → uso/venta → persistencia.
* [ ] `rc010` permanece sin modificaciones de alcance.

---

### **Estimación (orientativa)**

1–2 sesiones: modelo de datos, integración con inventario/vendor/consumibles y UI de cantidad.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-22 | Creación de HU-R5.2; stacking configurable, 20 pilas por bolsa y venta unitaria confirmados |
| 2026-08-22 | Marcada completada según reporte del equipo |
