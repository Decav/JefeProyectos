# HU-R6.64: Pociones — cooldowns separados y fusión de stacks (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Consumibles / Inventario / HUD
**Prioridad:** Alta — corrige una limitación de combate y una pérdida de espacio en la mochila
**Estado:** Abierta — lista para RC
**Tipo:** Ajuste de consumibles + fusión de stacks (dev)
**Fase GDD:** Ítems / Combate / UI
**Depende de:** HU-R6.2 (slots Z/X y uso genérico), HU-ITEMS-02 (pociones y buffs), HU-R5.2 (stacking y maxStack), HU-R6.32 (drag & drop), `ItemConfig`, `InventoryService`, HUD de consumibles/cooldown, `NotificationService`
**Componentes observados:** slots Z/X, barra de consumibles, `ItemConfig`, `InventoryService`, mochila/drag & drop, cooldown de uso, buffs temporales
**No modifica:** curación, maná, duración/efecto de buffs, `maxStack`, `stackable`, precios, vendors, loot, economía ni autoridad del servidor. Sí agrega **fusión de pilas** sin cambiar los valores de stacking.

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** usar una poción de buff y una de vida/maná sin bloquearme mutuamente,
**para** responder a distintas situaciones de combate sin que un tipo de consumible me inutilice el otro.

**Como** jugador,
**quiero** juntar dos pilas del mismo ítem y que el inventario no me ocupe dos slots de más,
**para** aprovechar mejor los 20 espacios y no perder tiempo acomodando pilas.

**Como** equipo,
**quiero** dos grupos de cooldown separados y una fusión de stacks server-authoritative,
**para** corregir ambos problemas sin tocar efectos, economía ni cantidades máximas.

---

### Descripción / Contexto

Hay dos problemas de consumibles/inventario:

1. Las pociones comparten un cooldown de 30 s: usar una poción de buff deja en CD la de vida/maná, y viceversa. El PO confirma que son **dos tipos de consumibles diferentes** y deben tener **CDs separados**.
2. Cuando un ítem queda partido en dos pilas (por ejemplo 5 y 10 del mismo template), la mochila usa **dos slots** aunque juntas no superen el `maxStack` de 20. El jugador espera poder unirlas al arrastrar una sobre otra y que el inventario se compacte solo cuando sea seguro.

**Criterio de hecho global:** el jugador puede usar recuperación y buff con cooldowns independientes; al arrastrar una pila sobre otra compatible se fusionan hasta el máximo sin perder unidades; al recibir ítems se completan pilas existentes antes de abrir slots nuevos; y al cargar el inventario se compactan pilas separadas sin duplicar ni perder nada. Todo server-authoritative.

---

### Especificaciones Técnicas / Contratos

#### 1. Grupos de consumibles

* Agregar a `ItemConfig` un campo canónico `cooldownGroup` (o equivalente):
  * `recovery` para `potion_hp`, `potion_hp_large`, `potion_mp`, `potion_mp_large`.
  * `buff` para `potion_buff_atk`, `potion_buff_def`, `potion_buff_hp`.
* Los ítems sin grupo declarado no se pueden usar en slots rápidos o usan el default existente; para pociones, el default debe ser `recovery`.
* La agrupación es por categoría, no por `templateId`.

#### 2. Cooldowns separados

* Cada personaje tiene un cooldown independiente por grupo:
  * `recoveryCooldownUntil`,
  * `buffCooldownUntil`.
* Default: **30 s por grupo** (configurable; conserva el valor actual).
* Usar una poción de recuperación:
  * valida y aplica solo el CD de `recovery`,
  * no modifica `buffCooldownUntil`.
* Usar una poción de buff:
  * valida y aplica solo el CD de `buff`,
  * no modifica `recoveryCooldownUntil`.
* Dentro del mismo grupo:
  * HP y MP comparten el CD de recuperación,
  * ATK, DEF y MaxHP comparten el CD de buff.
* El servidor es la única autoridad; el cliente no puede saltar el CD cambiando de slot, reasignando ítem, rejoin ni cerrando/abriendo el HUD.

#### 3. Flujo de uso

* `RequestUseItemSlot`/`RequestUseItem` resuelve el `templateId` en servidor, obtiene su `cooldownGroup` y valida el grupo correspondiente.
* No duplicar la lógica de efectos; reutilizar el `UseItem` existente.
* Si el grupo está en CD, bloquear con feedback “En recarga” y no consumir la unidad.
* Si el grupo está libre, aplicar efecto, consumir 1 unidad y actualizar el estado.
* Si el jugador tiene dos slots con grupos distintos, cada slot refleja su propio overlay de CD.

#### 4. UI de cooldown

* Overlay de cooldown por slot/ítem, no un CD global compartido.
* Al usar un buff con recuperación en CD, el slot de recuperación sigue mostrando su CD; el buff se usa.
* Al usar una recuperación con buff en CD, el buff sigue en CD; la recuperación se usa.
* Tooltips de consumibles muestran el grupo/CD correcto si ya muestran CD.
* Feedback breve si se intenta usar un grupo en CD.
* Sin HUD nuevo; reutilizar la barra de consumibles.

#### 5. Fusión de stacks

Aplica a **cualquier ítem stackable** (`stackable=true`, `maxStack > 1`), no solo a pociones. No aplica a equipo (`maxStack=1`), ítems con metadata/rolls únicos ni templates distintos.

**Regla base:**

* Solo se fusionan ítems del **mismo `templateId`**.
* El destino recibe `min(cantidadOrigen, maxStack - cantidadDestino)`.
* Si la origen queda en 0, se libera su slot.
* Si la origen tiene sobrante, permanece con el resto.
* Si el destino está lleno, no se mueve nada; mostrar “Pila llena”.
* Nunca se crean, duplican ni pierden unidades.

**Al arrastrar y soltar:**

* Arrastrar una pila sobre otra compatible abre la fusión; la UI resalta el destino y muestra una preview (`5 + 10 → 15`).
* Si el destino está en el `maxStack`, el drop se bloquea o se muestra “Pila llena”; no se pierde la pila.
* Si el jugador suelta sobre un slot vacío, se mueve la pila completa; no se fuerza una fusión automática en ese gesto.
* Si existe una acción de “separar pila”, separar crea stacks independientes y **no** se vuelven a fusionar inmediatamente; se fusionan en el próximo cambio de inventario, al soltar una sobre otra o al usar “Compactar”.

**Al agregar ítems:**

* Loot, compras, recompensas, trade, correo y quests deben completar primero las pilas parciales existentes del mismo template, en orden de slot, antes de crear un stack nuevo.
* Si no hay espacio suficiente para todas las unidades, la operación se rechaza completa (mantener el comportamiento atómico actual).
* Si hay varias pilas parciales, completar la primera y seguir con la siguiente.

**Al cargar/compactar:**

* Al cargar el perfil o abrir la mochila, compactar pilas compatibles para liberar slots; preservar el total exacto.
* Agregar un botón opcional **“Compactar”** en la mochila para ejecutar la misma operación manualmente.
* La compactación no debe alterar el orden de los ítems no fusionables ni mover equipo.
* Si el jugador tiene una separación intencional, la compactación automática solo ocurre en la carga/próximo cambio de inventario, no en el instante del split.

#### 6. UI y feedback de fusión

* Resaltar destinos compatibles al arrastrar.
* Preview de cantidad resultante; estado “Pila llena” si no entra.
* Al fusionar, actualizar cantidades y slots en la misma respuesta server-side.
* Si una pila se vacía, mostrar el slot libre sin dejar un ítem fantasma.
* No agregar una ventana nueva; usar la mochila/drag & drop existente.

#### 7. Compatibilidad y datos

* No cambiar efectos, duración de buffs, porcentajes de curación/maná, `maxStack`, precios ni vendors.
* Los cooldowns son por sesión/personaje; no agregar persistencia nueva de CD.
* Mantener compatibilidad con `potion_hp`/`potion_mp` y los templates de ITEMS-02.
* La fusión es server-authoritative e idempotente; una repetición de la misma operación no duplica ni pierde unidades.
* Aplicar la fusión también a otros stackables existentes, respetando `maxStack`.
* Migración/config default: pociones existentes → `recovery`; buffs → `buff`.
* No fusionar ítems con datos únicos por instancia aunque compartan template.

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Buff con recuperación en CD

* **GIVEN** una poción de recuperación en cooldown
* **WHEN** el jugador usa una poción de buff
* **THEN** el buff se aplica
* **AND** la recuperación sigue en cooldown

#### Escenario 2: Recuperación con buff en CD

* **GIVEN** una poción de buff en cooldown
* **WHEN** el jugador usa una poción de vida o maná
* **THEN** la recuperación se aplica
* **AND** el buff sigue en cooldown

#### Escenario 3: Mismo grupo comparte CD

* **GIVEN** una poción de vida usada
* **WHEN** el jugador intenta usar una de maná
* **THEN** se bloquea por el CD de recuperación
* **AND** no se consume la unidad

#### Escenario 4: Buffs comparten CD

* **GIVEN** una poción de ataque usada
* **WHEN** el jugador intenta usar una de defensa
* **THEN** se bloquea por el CD de buff
* **AND** la recuperación sigue disponible

#### Escenario 5: UI por slot

* **GIVEN** un slot con recuperación y otro con buff
* **WHEN** uno está en CD
* **THEN** solo ese slot muestra el overlay
* **AND** el otro sigue utilizable

#### Escenario 6: Sin bypass de CD

* **GIVEN** un grupo en CD
* **WHEN** el jugador cambia el ítem de slot, rejoin o reabre el HUD
* **THEN** el CD del grupo se mantiene
* **AND** el servidor rechaza el uso

#### Escenario 7: Fusión completa

* **GIVEN** una pila de 5 y otra de 10 del mismo ítem con maxStack 20
* **WHEN** el jugador arrastra una sobre la otra
* **THEN** el destino queda en 15
* **AND** la pila origen desaparece
* **AND** el total sigue siendo 15

#### Escenario 8: Fusión parcial

* **GIVEN** una pila de 15 y otra de 10 del mismo ítem con maxStack 20
* **WHEN** el jugador las fusiona
* **THEN** el destino queda en 20
* **AND** la origen queda en 5
* **AND** no se pierde ninguna unidad

#### Escenario 9: Destino lleno

* **GIVEN** una pila destino en maxStack 20
* **WHEN** el jugador intenta fusionar otra pila encima
* **THEN** la operación se bloquea con “Pila llena”
* **AND** ninguna pila cambia

#### Escenario 10: Nuevo loot completa pilas

* **GIVEN** una pila parcial de 12 y un slot libre
* **WHEN** el jugador recibe 10 unidades del mismo ítem
* **THEN** la pila existente se completa hasta 20
* **AND** el resto usa un slot nuevo
* **AND** no se crea un slot de más si hay espacio en la pila

#### Escenario 11: Compactación al cargar

* **GIVEN** dos pilas separadas compatibles al cargar el personaje
* **WHEN** se abre el inventario
* **THEN** se compactan hasta el máximo permitido
* **AND** el total de unidades se conserva
* **AND** se liberan slots

#### Escenario 12: Ítems no fusionables

* **GIVEN** dos templates distintos o equipo con maxStack 1
* **WHEN** el jugador intenta fusionarlos
* **THEN** no se fusionan
* **AND** no se modifica ninguna cantidad

#### Escenario 13: Sin duplicados por reintento

* **GIVEN** una fusión aceptada
* **WHEN** se repite la misma solicitud por reintento
* **THEN** el servidor no duplica ni pierde unidades
* **AND** el estado final es el mismo

#### Escenario 14: Regresión de cooldowns

* **GIVEN** la fusión y los CD separados activos
* **WHEN** se juega combate, dungeon, vendors y mochila
* **THEN** los efectos, precios, stacking máximo y economía siguen igual
* **AND** no hay errores rojos

---

### Comportamiento Visual / UI-UX

* El arrastre debe indicar si el destino acepta la pila y cuánto va a quedar.
* “Pila llena” debe ser claro y no ambiguo.
* La compactación no debe desordenar equipo ni ítems no fusionables.
* Cada slot de consumible debe comunicar su propio CD; no un gris global.
* No agregar una UI nueva; reutilizar mochila y barra de consumibles.

---

### Alcance

#### Incluye

* Campo/grupo de cooldown en `ItemConfig`.
* Dos cooldowns server-authoritative: recuperación y buff.
* UI/overlay por slot.
* Fusión de stacks al soltar, al agregar ítems y al cargar/compactar.
* Botón opcional “Compactar”.
* Preview/feedback de fusión y “Pila llena”.
* QA PC/móvil y regresión de inventario.

#### No incluye

* Cambios a efectos, curación, maná, duración de buffs, `maxStack` o `stackable`.
* Cambios de precios, vendors, loot o economía.
* Nuevos consumibles o grupos adicionales.
* Persistencia nueva de cooldowns.
* UI nueva de consumibles o inventario.
* Fusión de ítems con metadata/rolls únicos.

---

### Definition of Done (DoD)

* [ ] Pociones de recuperación y buffs con grupos separados.
* [ ] Usar un grupo no bloquea al otro; mismo grupo comparte CD.
* [ ] UI muestra el CD correcto por slot.
* [ ] Fusión al soltar una pila sobre otra compatible.
* [ ] Fusión parcial con sobrante y sin pérdida.
* [ ] Destino lleno bloqueado con feedback.
* [ ] Nuevo loot completa pilas existentes antes de abrir slots.
* [ ] Compactación al cargar y botón “Compactar”.
* [ ] Sin duplicados por reintento; total conservado.
* [ ] Sin cambios de efectos, `maxStack`, stacking máximo, precios ni vendors.
* [ ] QA PC/móvil y regresión.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).

---

### Decisiones por defecto

| Tema | Default |
|---|---|
| Grupos de CD | `recovery` y `buff` |
| Recuperación | HP/MP chica y grande |
| Buff | ATK/DEF/MaxHP |
| Cooldown | 30 s por grupo (config) |
| Fusión | Solo mismo `templateId` stackable |
| Destino lleno | Bloquea con “Pila llena” |
| Sobrante | Queda en la pila origen |
| Al agregar | Completa pilas parciales primero |
| Al cargar | Compacta pilas compatibles |
| Botón | “Compactar” opcional |
| MaxStack | Sin cambios |
| Ítems únicos | No se fusionan |
| UI | Mochila/drag & drop y barra actuales |

---

### Estimación (orientativa)

2–3 sesiones del dev: grupos de CD, fusión de stacks, UI de drop, compactación y QA.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-11-12 | Creación de HU-R6.64: separar cooldowns de pociones de recuperación y de buff, manteniendo el CD compartido dentro de cada grupo y sin tocar efectos, stacking ni economía. |
| 2026-11-12 | Ampliación por PO: se incorpora fusión de stacks (drag & drop, al agregar ítems y compactación al cargar) para evitar que dos pilas del mismo ítem ocupen dos slots cuando pueden unirse hasta el `maxStack`; sin cambiar `maxStack` ni la economía. |
