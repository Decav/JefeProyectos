# HU-R6.64: Pociones — cooldowns separados para recuperación y buffs (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Consumibles / Combate / HUD
**Prioridad:** Alta — corrige una limitación de combate y habilita el uso táctico de pociones
**Estado:** Abierta — lista para RC
**Tipo:** Ajuste de cooldown de consumibles (dev)
**Fase GDD:** Ítems / Combate / UI
**Depende de:** HU-R6.2 (slots Z/X y uso genérico), HU-ITEMS-02 (pociones y buffs), `ItemConfig`, `InventoryService`, HUD de consumibles/cooldown, `NotificationService`
**Componentes observados:** slots Z/X, barra de consumibles, `ItemConfig`, `InventoryService`, cooldown de uso, buffs temporales
**No modifica:** curación, maná, duración/efecto de buffs, stacking, precios, vendors, loot, economía ni autoridad del servidor.

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** usar una poción de buff y una de vida/maná sin bloquearme mutuamente,
**para** responder a distintas situaciones de combate sin que un tipo de consumible me inutilice el otro.

**Como** equipo,
**quiero** dos grupos de cooldown separados para pociones de recuperación y de buff,
**para** corregir el bloqueo actual sin tocar los efectos ni la economía.

---

### Descripción / Contexto

Hoy las pociones comparten un cooldown de 30 s: usar una poción de fuerza o defensa deja la casilla en CD y no permite usar una de vida/maná, y viceversa. El PO confirma que son **dos tipos de consumibles diferentes** y deben funcionar con **CDs separados**:

* **Grupo recuperación:** pociones de vida y maná (chica/grande).
* **Grupo buff:** pociones de ataque, defensa y MaxHP.

Usar un grupo no debe poner en CD al otro. Dentro del mismo grupo, el cooldown sigue siendo compartido.

**Criterio de hecho global:** el jugador puede usar una poción de recuperación aunque una de buff esté en CD, y viceversa; cada grupo tiene su propio cooldown server-authoritative, la UI muestra el CD correcto por slot y no se puede saltar el CD cambiando de slot/ítem.

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

#### 4. UI y feedback

* Overlay de cooldown por slot/ítem, no un CD global compartido.
* Al usar un buff con recuperación en CD, el slot de recuperación sigue mostrando su CD; el buff se usa.
* Al usar una recuperación con buff en CD, el buff sigue en CD; la recuperación se usa.
* Tooltips de consumibles muestran el grupo/CD correcto si ya muestran CD.
* Feedback breve si se intenta usar un grupo en CD.
* Sin HUD nuevo; reutilizar la barra de consumibles.

#### 5. Compatibilidad y datos

* No cambiar efectos, duración de buffs, porcentajes de curación/maná, stacking, precios ni vendors.
* Los cooldowns son por sesión/personaje; no agregar persistencia nueva salvo la que ya exista.
* Mantener compatibilidad con `potion_hp`/`potion_mp` y los nuevos templates de ITEMS-02.
* Si un ítem de otro tipo usa `cooldownGroup`, no cambiar su comportamiento actual en esta HU.
* Migración/config default: pociones existentes → `recovery`; buffs → `buff`.

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

#### Escenario 6: Sin bypass

* **GIVEN** un grupo en CD
* **WHEN** el jugador cambia el ítem de slot, rejoin o reabre el HUD
* **THEN** el CD del grupo se mantiene
* **AND** el servidor rechaza el uso

#### Escenario 7: Sin cambios colaterales

* **GIVEN** los CD separados
* **WHEN** se revisan curación, maná, buffs, stacking, precios y vendors
* **THEN** todo permanece igual
* **AND** no hay errores rojos

---

### Comportamiento Visual / UI-UX

* Cada slot debe comunicar su propio estado de recarga; no un gris global.
* El jugador debe poder entender por qué una poción está bloqueada.
* No agregar una UI nueva ni tooltips permanentes; reutilizar la barra actual.
* Sin cambios de sonido ni animaciones de uso.

---

### Alcance

#### Incluye

* Campo/grupo de cooldown en `ItemConfig`.
* Dos cooldowns server-authoritative: recuperación y buff.
* Validación en uso directo y slots Z/X.
* UI/overlay por slot.
* QA PC/móvil y regresión.

#### No incluye

* Cambios a efectos, curación, maná, duración de buffs o stacking.
* Cambios de precios, vendors, loot o economía.
* Nuevos consumibles o grupos adicionales.
* Persistencia nueva de cooldowns.
* UI nueva de consumibles.

---

### Definition of Done (DoD)

* [ ] Pociones de recuperación y buffs tienen grupos separados.
* [ ] Usar un grupo no bloquea al otro.
* [ ] Dentro del mismo grupo el CD sigue compartido.
* [ ] UI muestra el CD correcto por slot.
* [ ] Sin bypass por cambio de slot/rejoin.
* [ ] Sin cambios de efectos, stacking, precios ni vendors.
* [ ] QA PC/móvil y regresión de combate.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).

---

### Decisiones por defecto

| Tema | Default |
|---|---|
| Grupos | `recovery` y `buff` |
| Recuperación | HP/MP chica y grande |
| Buff | ATK/DEF/MaxHP |
| Cooldown | 30 s por grupo (config) |
| Mismo grupo | Comparte CD |
| Entre grupos | Independientes |
| UI | Overlay por slot/grupo |
| Persistencia | La existente; sin campo nuevo de CD |
| Efectos | Sin cambios |

---

### Estimación (orientativa)

1–2 sesiones del dev: config, cooldown server, UI por slot y QA.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-11-12 | Creación de HU-R6.64: separar cooldowns de pociones de recuperación y de buff, manteniendo el CD compartido dentro de cada grupo y sin tocar efectos, stacking ni economía. |
