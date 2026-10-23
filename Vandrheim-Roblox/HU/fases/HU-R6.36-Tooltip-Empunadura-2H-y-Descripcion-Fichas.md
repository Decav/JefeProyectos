# HU-R6.36: Corrección de presentación de armas 2H y descripciones de fichas (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R6.x / UI / Inventario
**Prioridad:** Alta
**Estado:** Implementada (confirmación del PO 2026-10-22; RC cerrado)
**Tipo:** Bugfix de presentación de ítems/tooltip y copy de fichas (dev)
**Depende de:** HU-R6.27 (TooltipSystem), HU-ESTETICA-44 (referencia de tooltip), HU-ITEMS-01 (`wieldType`), HU-ECONOMIA-04 (templates y copy de fichas)
**No modifica:** reglas de equipamiento, almacenamiento `MainHand`/`OffHand`, stats, precios ni comerciabilidad.

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** que el tooltip describa correctamente si un arma es de una o dos manos y que la ficha explique su beneficio,
**para** entender el objeto sin recibir información de equipamiento o comercio engañosa.

---

### Descripción / Contexto

El tooltip de armas está presentando algunos templates con `slot="MainHand"` como **MANO DERECHA**, aunque su `wieldType="TwoHand"`; esto ocurre con espadones y arcos. `slot` representa la ubicación de almacenamiento/equipo, mientras que `wieldType` define el tipo de empuñadura. El tooltip debe usar el segundo para describir el arma.

Algunos `TokenConfig.description` también mezclan el beneficio de la ficha con mensajes de venta/intercambio entre jugadores. La descripción corta del ítem debe explicar solo su efecto/uso; la comerciabilidad sigue funcionando como regla del sistema y no se elimina.

**Criterio de hecho global:** las armas `TwoHand` se muestran como **DOS MANOS · 2H**, y las descripciones de fichas informan el beneficio sin copy de venta/intercambio.

---

### Especificaciones técnicas

#### 1. Etiqueta de empuñadura del tooltip

* Derivar la etiqueta desde el `wieldType` canónico de `ItemConfig`/template; no inferir tipo de arma desde `slot`.
* `TwoHand` (espadón/arco) → **DOS MANOS · 2H**. Nunca mostrar **MANO DERECHA** ni **MANO IZQUIERDA** para ese tipo, aunque `slot="MainHand"`.
* `OneHand` → UNA MANO · 1H; `MainHandOnly` → MANO PRINCIPAL; `OffHand` → MANO SECUNDARIA.
* El texto es informativo. No cambiar la validación de equipamiento: un 2H sigue ocupando `MainHand` + `OffHand` y bloqueando el offhand.

#### 2. Descripciones cortas de fichas

* Mantener `TokenConfig.description` centrado en el efecto/uso:
  * `token_slot3`: desbloquea permanentemente el tercer slot de la cuenta.
  * `token_bag`: añade 10 espacios a la mochila del personaje que la canjea.
  * `token_auction`: amplía los listados simultáneos cuando ECON-02 esté disponible.
  * `token_rename`: permite cambiar el nombre según las reglas R2.
* No mencionar en la descripción del ítem que se puede vender o comerciar con otros jugadores.
* No cambiar que los tokens sean tradeables/subastables. La restricción aplica al copy visible del ítem, no a la lógica.

---

### Criterios de aceptación (Gherkin)

#### Escenario 1: Espadón y arco 2H

* **GIVEN** un espadón o arco con `wieldType="TwoHand"` y `slot="MainHand"`
* **WHEN** se abre su tooltip desde mochila o equipo
* **THEN** muestra **DOS MANOS · 2H**, sin etiqueta de mano derecha/izquierda

#### Escenario 2: Tipos de una mano

* **GIVEN** un arma `OneHand`, varita `MainHandOnly` o escudo `OffHand`
* **WHEN** se abre su tooltip
* **THEN** la etiqueta corresponde al `wieldType` del template, no a un alias incorrecto del slot

#### Escenario 3: Copy de fichas

* **GIVEN** cualquier token en inventario
* **WHEN** se muestra su descripción en el tooltip
* **THEN** explica el efecto/uso y no incluye texto de venta o intercambio entre jugadores

#### Escenario 4: Lógica de equipo intacta

* **GIVEN** un espadón/arco equipado o en mochila
* **WHEN** se consulta el tooltip o se intenta equipar
* **THEN** el tooltip usa la etiqueta 2H y las reglas de ocupación/bloqueo de ambos slots permanecen intactas

---

### Alcance

#### Incluye

* Etiqueta visual del tipo de arma basada en `wieldType`.
* Copy de las descripciones visibles de los cuatro tokens.
* QA de tooltip para 2H, 1H, varita, escudo y fichas.

#### No incluye

* Cambios a `slot`, `wieldType`, remotes, balance, precio o permisos de comercio.
* Rediseñar el TooltipSystem o los paneles de mochila/equipo.

---

### Definition of Done (DoD)

* [ ] Espadones y arcos `TwoHand` muestran DOS MANOS · 2H en inventario, equipo y vendor donde se use `Tooltip_Item`.
* [ ] Los otros `wieldType` muestran etiquetas correctas, sin inferirlas de forma incorrecta desde `slot`.
* [ ] Las cuatro descripciones de tokens explican su efecto y no mencionan venta/intercambio.
* [ ] No cambian las reglas de equipamiento ni la comerciabilidad; sin regresiones ni errores rojos.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-10-21 | HU nueva para el follow-up PO: etiqueta 2H incorrecta y copy innecesario de venta/intercambio en descripciones de fichas. |
