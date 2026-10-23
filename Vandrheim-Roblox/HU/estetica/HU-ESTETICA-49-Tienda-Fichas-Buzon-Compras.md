# HU-ESTETICA-49: Tienda de fichas y buzón de compras pendientes (diseñador)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Economía / UI / Monetización
**Prioridad:** Alta — handoff visual para HU-ECONOMIA-04
**Estado:** Implementada (confirmación del PO 2026-10-22; paneles e iconos entregados)
**Tipo:** Diseño de UI en Pencil (solo diseñador; sin código). El PO generará posteriormente los iconos finales con ImageGen.
**Depende de:** HU-ECONOMIA-04 (productos, precios, buzón y canje), HU-ESTETICA-04/13 (dirección Hearthbound Gold y handoff), HU-ESTETICA-25 (referencia de Selección de Personaje), HU-ESTETICA-11 (patrón de inventario), ASSETS_POLICY.md y ASSETS_LIST.md
**No modifica:** precios, lógica de compra/recibos, inventario, selección de personaje ni sistemas de trade/subasta.

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** consultar las fichas disponibles y reclamar las compras pendientes en un personaje,
**para** saber qué obtengo y decidir si uso o comercio cada ficha.

**Como** diseñador,
**quiero** un catálogo claro y un buzón de cuenta con estados completos,
**para** entregar a desarrollo una interfaz implementable sin inventar reglas de ECON-04.

---

### Descripción / Contexto

HU-ECONOMIA-04 define cuatro fichas como Developer Products repetibles. Roblox proporciona el diálogo nativo para confirmar y pagar; **no** proporciona un catálogo visual dentro de Vandrheim. Esta HU diseña el catálogo y la interfaz de grants pendientes, no un checkout propio.

El panel es una superficie de cuenta accesible desde Selección de Personaje. Dentro del mismo panel se navega entre **Tienda** y **Compras pendientes**. La compra confirmada crea un grant durable en el buzón de `UserId`; el jugador selecciona un PJ existente para reclamar el ítem. Los ítems obtenidos por trade/subasta no pasan por este buzón de compras Robux.

**Criterio de hecho global:** existen en `Vandrheim-design.pen` los frames de Tienda y Compras pendientes en PC y móvil con placeholders de icono identificados para las cuatro fichas. El PO generará los iconos finales con ImageGen en una etapa posterior; no dibujarlos ni reemplazarlos por vectores en Pencil. El diálogo de pago de Roblox se invoca desde la CTA; no se replica visualmente.

---

### Especificaciones visuales

#### 1. Acceso y estructura del panel

* Añadir un acceso compacto **Tienda** en el área de cuenta de la Selección de Personaje existente; al abrir, presentar pestañas **Tienda** y **Compras pendientes** con contador cuando haya grants.
* Reutilizar el estilo Hearthbound Gold y componentes existentes. No rehacer las pantallas completas de selección/creación ni crear un acceso en el micromenú/HUD.
* Diseñar escritorio y móvil con área segura y controles táctiles de al menos `44×44 px`.

#### 2. Tienda de fichas

Mostrar cuatro tarjetas, cada una con icono, nombre, beneficio breve, ámbito del perk y precio Robux; la CTA **Comprar** abre el diálogo nativo de Roblox:

| Ficha | Beneficio que muestra | Ámbito | Precio |
|---|---|---|---:|
| `token_slot3` | Desbloquea el tercer slot de personaje | Cuenta | 149 R$ |
| `token_bag` | Añade 10 espacios a la mochila | Personaje que la canjea | 99 R$ |
| `token_auction` | Aumenta a 20 los anuncios simultáneos | Cuenta | 79 R$ |
| `token_rename` | Permite cambiar el nombre del personaje | Personaje que completa el cambio | 49 R$ |

* Los productos son repetibles. Si el jugador ya tiene el perk, indicarlo sin deshabilitar **Comprar**.
* No incluir en las tarjetas o descripciones copy de venta/intercambio entre jugadores; esa comerciabilidad pertenece a las reglas del sistema, no al texto del ítem o de la Tienda.
* No añadir precio en oro ni simular una compra con oro dentro de esta tienda.
* Estados visuales: catálogo normal, CTA activa, confirmación/cancelación devuelta por el prompt nativo y perk ya desbloqueado.

#### 3. Compras pendientes (buzón de cuenta)

* Mostrar solo grants de fichas de compras Robux que ya estén confirmados por el servidor; no es mensajería jugador-a-jugador ni historial de recibos.
* Cada grant muestra icono, nombre de la ficha y cantidad pendiente. Permitir seleccionar uno de los personajes existentes de la cuenta como destinatario y pulsar **Reclamar**.
* Tras reclamar con éxito, mostrar confirmación y retirar el grant de la lista; la ficha aparece en la mochila del PJ elegido. El canje ocurre desde el flujo existente de uso del ítem, no desde el buzón.
* Diseñar estos estados: buzón vacío; grants pendientes; sin personajes disponibles; personaje sin espacio; reclamo temporalmente bloqueado por el lock de trade. En los últimos tres casos, explicar que la ficha sigue segura en el buzón y ofrecer volver a intentar cuando corresponda.
* Un token reclamado queda en el inventario como ítem normal y puede conservarse, canjearse o comerciarse según ECON-04.

#### 4. Placeholders de iconos de fichas (4)

* Mantener en Pencil los cuatro placeholders actuales, identificados por ficha y en el tamaño/proporción previstos para los iconos de ítem. No dibujar los iconos como vectores ni generar los assets finales dentro de esta HU.
* El PO generará los cuatro iconos más adelante con ImageGen, siguiendo la estética ilustrada de los ítems y la moneda canónica `Icon_UI_currency_gold`: objeto con volumen/sombreado pintado, perspectiva leve 3/4, contorno oscuro y bisel ilustrado, detalle nórdico/fantástico, PNG `512×512` RGBA transparente.
* Conceptos de referencia para la futura generación:

| Nombre canónico | Concepto visual |
|---|---|
| `Icon_Item_token_slot3` | Sello rúnico de personaje / tercer emblema |
| `Icon_Item_token_bag` | Bolsa de cuero encantada con espacio expandido |
| `Icon_Item_token_auction` | Martillo de subasta y moneda nórdica |
| `Icon_Item_token_rename` | Pergamino con pluma y sello rúnico |

Los placeholders deben poder sustituirse por estos nombres canónicos cuando el PO entregue los assets. El token de revive pertenece a HU-R6.28 y queda fuera de esta entrega.

#### 5. Reglas de diseño

* El catálogo presenta la ficha y su perk; no promete un beneficio distinto al de HU-ECONOMIA-04.
* No diseñar formularios de pago, saldo Robux propio, sistema de correo ni confirmación de compra que reemplace a Roblox.
* No confundir el buzón de grants Robux con los resultados/recompensas de la subasta.
* Los precios y textos del catálogo deben corresponder a HU-ECONOMIA-04 y MONETIZATION.md.

---

### Criterios de aceptación (Gherkin)

#### Escenario 1: Catálogo claro

* **GIVEN** el panel de Tienda
* **WHEN** el jugador consulta las cuatro fichas
* **THEN** ve icono, beneficio, ámbito y precio correctos en escritorio y móvil

#### Escenario 2: Compra nativa

* **GIVEN** una ficha en el catálogo
* **WHEN** el jugador pulsa **Comprar**
* **THEN** el diseño comunica que se abre el diálogo de Roblox y no muestra un checkout propio

#### Escenario 3: Reclamar grant

* **GIVEN** una ficha confirmada en Compras pendientes y personajes de cuenta disponibles
* **WHEN** el jugador elige un PJ y reclama
* **THEN** la confirmación identifica el PJ destinatario y el grant deja de mostrarse como pendiente tras completarse

#### Escenario 4: Grant no reclamable todavía

* **GIVEN** que no hay PJ, no hay espacio o el lock temporal impide reclamar
* **WHEN** se abre Compras pendientes
* **THEN** se entiende que la ficha sigue segura y pendiente; no se sugiere que se perdió o consumió

#### Escenario 5: Buzón vacío

* **GIVEN** que no hay grants pendientes
* **WHEN** se abre Compras pendientes
* **THEN** aparece un estado vacío claro con acceso de vuelta a Tienda

#### Escenario 6: Perk ya desbloqueado

* **GIVEN** que el jugador ya posee el perk de una ficha
* **WHEN** consulta su tarjeta en Tienda
* **THEN** el estado informa que ya tiene el perk, pero deja visible la CTA **Comprar** porque el Developer Product es repetible; sin texto sobre vender/intercambiar la ficha

#### Escenario 7: Placeholders listos para los iconos

* **GIVEN** los cuatro placeholders de ficha en las pantallas
* **WHEN** se revisa el diseño entregado
* **THEN** cada placeholder está identificado y conserva el tamaño/espacio para sustituirse después por el icono ImageGen correspondiente

---

### Alcance

#### Incluye

* Panel de Tienda con cuatro fichas y CTA al prompt de Roblox.
* Panel de Compras pendientes con selección de personaje y estados vacíos/bloqueados/completados.
* Variantes escritorio y móvil.
* Cuatro placeholders de icono identificados, listos para sustituirse por los assets ImageGen que generará el PO posteriormente.

#### No incluye

* Código, `ProcessReceipt`, grants, reclamos ni canjes (HU-ECONOMIA-04).
* Rediseñar Selección/Creación de Personaje o inventario existentes.
* Compra en oro, trade, subasta, revive ni checkout propio.

---

### Definition of Done (DoD)

* [ ] Frames nombrados en `Vandrheim-design.pen`: Tienda y Compras pendientes, escritorio y móvil.
* [ ] Las cuatro tarjetas muestran beneficio, ámbito y precio vigentes; repetir compra sigue permitido si el perk ya existe.
* [ ] Buzón incluye grants pendientes, selección de PJ, estado vacío, sin PJ, mochila llena, lock temporal y reclamo completado.
* [ ] Se usa el prompt nativo de Roblox; no existe checkout visual propio.
* [ ] Los cuatro placeholders quedan identificados, con tamaño y correspondencia correctos para cada ficha.
* [ ] No se dibujan iconos vectoriales ni se generan assets finales en esta HU; el PO entregará luego los iconos ImageGen para sustituir los placeholders.
* [ ] Handoff a ECON-04 con IDs de frames, estados, rutas de assets y pendientes.

---

### Estimación

1–2 sesiones del diseñador: catálogo, buzón y variantes de pantalla.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-10-19 | Creación de la HU de diseño para Tienda de fichas, buzón de compras pendientes y cuatro iconos ImageGen; vinculada a HU-ECONOMIA-04. |
| 2026-10-19 | El PO pospone la generación ImageGen de los cuatro iconos; el diseñador conserva placeholders identificados en las pantallas. |
