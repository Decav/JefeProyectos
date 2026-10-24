# HU-ECONOMIA-05: Tooltips de ítems en las ventanas de Trade (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Economía / Trade / UX
**Prioridad:** Alta
**Estado:** Lista para RC
**Tipo:** Bugfix de interfaz (dev)
**Depende de:** HU-ECONOMIA-01 (trade), HU-R4 (inventario/tooltips de ítems), HU-R6.27 (TooltipSystem), HU-ESTETICA-35 (estados visuales de Trade), `ItemConfig`
**No modifica:** reglas de trade, reservas/locks, inventario, stats ni valores de ítems.

---

### Narrativa (INVEST)

**Como** jugador que está preparando un intercambio,
**quiero** poder inspeccionar los ítems ofrecidos desde las ventanas de Trade,
**para** confirmar exactamente qué recibo y qué entrego antes de aceptar/confirmar la operación.

---

### Descripción / Contexto

Actualmente los tooltips de ítems no aparecen en la UI de Trade. Esta HU conecta las casillas ocupadas de ambos lados del intercambio con el TooltipSystem y los datos reales del ítem. Las ofertas del otro jugador son de solo lectura, pero deben poder inspeccionarse igual que las propias.

**Criterio de hecho global:** al apuntar/seleccionar cualquier ítem ofrecido, el jugador puede revisar su información completa en los estados de Trade permitidos, en PC y móvil, sin alterar la oferta, confirmar accidentalmente ni bloquear la operación.

---

### Especificaciones / Contrato de UI

* Reutilizar el TooltipSystem y el formato de tooltip transversal de R4/R6.27; no crear un segundo sistema de tooltip ni duplicar la fuente de datos.
* En PC, mostrar el tooltip al hacer hover sobre una casilla de ítem ocupada. En móvil, mostrarlo al tocar la casilla; permitir cerrarlo tocando fuera o usando el cierre común sin activar otra acción de Trade.
* Debe funcionar en el lado local y el lado remoto, tanto al inspeccionar ítems propios como los ofrecidos por el otro jugador.
* Mostrar datos reales del `ItemConfig`/instancia de la oferta: nombre, rareza, icono, stats finales/afijos, requisito de nivel, descripción y cualquier dato de set que ya muestre el tooltip común. No hardcodear ejemplos de Pencil.
* Tooltip disponible mientras la oferta es editable (`OFFERING`) y en estados de solo lectura (`LOCKED`, `EXCHANGING` y resumen terminal si aún se muestran los ítems). No debe permitir modificar la oferta desde el tooltip.
* Vaciar el tooltip al cambiar la oferta, retirar/cambiar el ítem, cerrar la ventana o terminar el trade; nunca dejar datos del ítem/personaje anterior.
* Prioridad de input: inspeccionar no emite `RequestTradeConfirm`, `RequestTradeOffer`, `RequestTradeCancel` ni acciones de drag/drop. Si se arrastra un ítem, el tooltip se oculta durante el drag y se restaura al terminar si corresponde.
* En móvil, respetar las áreas táctiles existentes y mantener los dos lados del trade accesibles sin que el tooltip quede fuera de pantalla.

---

### Criterios de aceptación (Gherkin)

#### Escenario 1: Inspeccionar ítem propio

* **GIVEN** un ítem en una casilla de mi oferta
* **WHEN** hago hover (PC) o toco la casilla (móvil)
* **THEN** aparece el tooltip del ítem con datos reales, sin modificar la oferta

#### Escenario 2: Inspeccionar oferta remota

* **GIVEN** un ítem en una casilla ofrecida por el otro jugador
* **WHEN** lo inspecciono
* **THEN** veo el mismo nivel de información; la oferta remota permanece de solo lectura

#### Escenario 3: Estados bloqueados

* **GIVEN** el Trade está `LOCKED` o `EXCHANGING`
* **WHEN** se inspecciona un ítem ofrecido
* **THEN** el tooltip aparece, pero no habilita editar, retirar, confirmar ni cancelar

#### Escenario 4: Sin ítem

* **GIVEN** una casilla vacía
* **WHEN** el usuario hace hover/tap
* **THEN** no aparece tooltip ni se emite una acción de Trade

#### Escenario 5: Input sin efectos secundarios

* **GIVEN** un tooltip abierto durante una oferta editable
* **WHEN** el usuario lo abre, lo cierra o inicia/termina un drag
* **THEN** no cambia la versión de la oferta ni se emiten remotes de confirmación/cancelación accidentalmente

#### Escenario 6: Cambios de oferta y personaje

* **GIVEN** se retira/cambia un ítem, cambia el trade o se cierra la ventana
* **WHEN** aparece otro ítem o se reabre el panel
* **THEN** el tooltip refleja el nuevo dato y no conserva información anterior

---

### Alcance

#### Incluye

* Tooltips de ítems en ambos lados de Trade.
* Estados editables y de solo lectura.
* PC hover y móvil tap, con limpieza y regresión de drag/drop.

#### No incluye

* Cambiar el diseño completo de Trade (EST-35), sus reglas, la máquina de estados ni el flujo de confirmación.
* Nuevos datos de ítems o cambios a `ItemConfig` fuera de campos ya soportados por el TooltipSystem.

---

### Definition of Done (DoD)

* [ ] Tooltip real funciona para cada slot ocupado de ambos lados de Trade.
* [ ] Estados `OFFERING`, `LOCKED`, `EXCHANGING` y terminal conservan sus acciones/reglas; inspeccionar no modifica ofertas ni emite remotes de Trade.
* [ ] PC y móvil probados: hover/tap, cierre, drag/drop, contenido largo y anclaje dentro de pantalla.
* [ ] Tooltip se limpia correctamente al cambiar/cerrar el trade; sin datos obsoletos ni errores rojos.
* [ ] Dev prepara RC desde esta HU y adjunta evidencia de los estados revisados.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-10-23 | HU creada a partir del bug reportado por el PO: tooltips ausentes en las ventanas de Trade. |
