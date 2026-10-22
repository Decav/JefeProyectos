# HU-R6.37: Corregir color de estadísticas según bonus de equipo y talentos (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R6.x / UI / Panel de personaje
**Prioridad:** Alta
**Estado:** Lista para RC
**Tipo:** Bugfix de presentación de estadísticas (dev)
**Depende de:** HU-ESTETICA-45 (panel C, variante B), HU-R6.27 (tokens de UI/TooltipSystem), HU-R4 (stats de equipo), HU-R5.1 (bonos de talentos), `InventoryData.statsBreakdown`
**No modifica:** fórmulas, valores, balance ni autoridad server-side de estadísticas.

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** distinguir qué estadísticas reciben un bonus de mi equipo o talentos,
**para** reconocer el aporte de mi build sin confundirlo con los valores base.

---

### Descripción / Contexto

El panel de personaje debe mostrar el valor total real del servidor. El color del valor indica si ese total incluye una contribución positiva de equipo o talentos:

* **Verde `#70C08B`:** existe bonus positivo desde equipo o talentos.
* **Pergamino `#F4EDE0`:** el stat conserva solo su valor base, o no tiene bonus positivo de esas fuentes.

El color no se debe deducir únicamente de que el total sea mayor que cero. `MaxMP` puede recibir equipo/talento y debe poder verse verde; los efectos únicamente de consumibles no activan el verde. Para CDR, que no tiene aporte de equipo en los templates actuales, el verde indica el bonus de talento.

**Criterio de hecho global:** al equipar/desequipar o cambiar talentos, el total sigue siendo el del servidor y el color cambia de acuerdo con las fuentes de bonus vigentes.

---

### Especificaciones técnicas / Contratos de UI

* Leer `InventoryData.statsBreakdown[stat].equipment` y `.talents` (o la fuente autoritativa equivalente) para decidir el color. Asegurar que el breakdown incluya cada stat al que equipo o talentos puedan aportar.
* Si `equipment > 0` o `talents > 0`, pintar el valor total en verde. Si ambos son cero/no están disponibles, usar pergamino. No usar el valor base o total `>0` como condición de verde.
* No alterar el valor que se muestra: HP/MaxHP, MP/MaxMP, ATK, MATK, DEF, MDEF, CRIT y CDR siguen las conversiones y formatos actuales.
* Refrescar valor y color tras cambios de equipo/talentos, cambio de personaje y respuesta nueva de `InventoryData`; no dejar el color del personaje anterior.
* CDR se muestra verde solo cuando hay bonus positivo de talento; con `0 %`/sin bonus, pergamino. No inferir la fuente solo de un total distinto de cero si no existe breakdown de origen.

---

### Criterios de aceptación (Gherkin)

#### Escenario 1: Solo valor base

* **GIVEN** un stat sin aportes positivos de equipo ni talentos
* **WHEN** se muestra el panel de personaje
* **THEN** el valor total usa pergamino, aunque el stat base sea mayor que cero

#### Escenario 2: Bonus de equipo

* **GIVEN** una pieza equipada que añade un stat
* **WHEN** llega el nuevo breakdown al panel
* **THEN** el total se conserva y se muestra verde

#### Escenario 3: Bonus de talento

* **GIVEN** un talento que añade un stat o CDR
* **WHEN** se aplica/recalcula el talento
* **THEN** el stat correspondiente se muestra verde; el resto conserva el color según sus propias fuentes

#### Escenario 4: Retirar el bonus

* **GIVEN** un stat mostrado en verde por equipo/talento
* **WHEN** se desequipa la fuente o se elimina el talento y llega el nuevo breakdown
* **THEN** el valor y su color se actualizan; si no quedan aportes, vuelve a pergamino

#### Escenario 5: Consumible solamente

* **GIVEN** un consumible modifica temporalmente un stat sin bonus de equipo/talento
* **WHEN** se presenta el panel
* **THEN** el color no se vuelve verde solo por el consumible

#### Escenario 6: Sin regresión

* **GIVEN** stats con distintos orígenes
* **WHEN** se prueba el panel en PC y móvil
* **THEN** los valores, desglose TooltipSystem, interacción y layout siguen funcionando sin errores rojos

---

### Alcance

#### Incluye

* Color dinámico de valores de estadísticas según el desglose de equipo/talentos.
* Actualización visual en respuesta a cambios de inventario, talentos o personaje.
* QA de valores base, bonus de equipo, bonus de talento y consumible temporal.

#### No incluye

* Cambiar fórmulas o recalcular stats en cliente.
* Cambiar el diseño del panel más allá de la semántica de color establecida en HU-ESTETICA-45.

---

### Definition of Done (DoD)

* [ ] Base sin equipo/talentos = pergamino; bonus positivo de equipo/talentos = verde.
* [ ] `MaxMP`, CDR y los demás stats muestran el color desde una fuente autoritativa de bonus; consumible solo no activa verde.
* [ ] Valores y colores se refrescan al cambiar equipo, talentos o PJ.
* [ ] No se modifican valores server-side ni balance; pruebas PC/móvil sin errores rojos.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-10-21 | HU nueva para el follow-up PO de color de stats según fuentes de equipo/talentos en el panel de personaje. |
