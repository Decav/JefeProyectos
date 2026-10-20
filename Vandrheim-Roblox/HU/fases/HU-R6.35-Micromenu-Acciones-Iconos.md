# HU-R6.35: Micromenú — iconos y atajos de dungeon, guía y party; Target móvil

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R6.x / UI móvil y micromenú
**Prioridad:** Alta
**Estado:** Lista para RC (assets subidos; integrar IDs indicados)
**Tipo:** Integración de UI e iconos (dev)
**Fase GDD:** R6.35 (reorganiza accesos; conserva las acciones existentes)
**Depende de:** HU-R6.19 (targeting/ciclo), HU-R6.20 (OrdenUI), HU-R6.29 (Target móvil y controles), HU-R6.31 (`NotificationFrame` central), HU-R9a.2 (lobby/matchmaking), HU-ESTETICA-19/20 (micromenú), HU-ESTETICA-35/37 (ventanas de economía/lobby), `ASSETS_LIST.md` (iconos del 2026-10-17)
**Assets:** IDs en ASSETS_LIST: iconos Dungeon/Guía/Party/Target, `Icon_UI_close` reusable y `Icon_UI_currency_gold` global.

---

### Narrativa (INVEST)

**Como** jugador, quiero abrir dungeon, guía y party desde el micromenú, y tener un botón Target independiente con icono en móvil, para agrupar accesos sin esconder el control de combate.

---

### Descripción / Contexto

El PO produjo cuatro iconos complementarios para la UI. Esta HU integra **Dungeon, Guía y Party** en el micromenú **globalmente: PC y móvil, Hub y dungeon**. El icono `Icon_Menu_target_cycle` se aplica al **botón Target independiente del HUD móvil**: no se mueve al micromenú. El botón Target es editable/movible por OrdenUI solo en móvil; PC conserva TAB. El `NotificationFrame` de R6.31 centraliza avisos pasivos de sistema; el `LootPopup` de adquisición permanece independiente y movible según R6.29.

**Frame/estilo de referencia:** micromenú existente de EST-19/20 y previews `Preview_Micromenu.png` / `Preview_StyleMatch.png` archivados en `Assets/Source/Design/Micromenu-2026-10-17/`.

**Criterio de hecho global:** Dungeon, Guía y Party aparecen como entradas del micromenú en PC/móvil; el botón Target permanece independiente y movible en móvil; `NotificationFrame` y `LootPopup` conservan sus roles independientes; desaparecen los botones sueltos de Dungeon/Party; Target no aparece ni deja slot fantasma en PC.

---

### Especificaciones técnicas

#### 1. Entradas del micromenú

| Acción | Icono | Comportamiento al seleccionar | Plataforma |
|---|---|---|---|
| **Dungeon** | `Icon_Menu_dungeon` | Abrir el panel/lobby de dungeon existente (crear/unirse; no crear una run directamente) | **Global: PC y móvil, Hub y dungeon** |
| **Guía de dungeon** | `Icon_Menu_dungeon_guide` | Abrir la guía independiente de la Helada | **Global: PC y móvil, Hub y dungeon** |
| **Party** | `Icon_Menu_party` | Abrir el panel de party existente | **Global: PC y móvil, Hub y dungeon** |
| **Cambiar objetivo** | `Icon_Menu_target_cycle` | Aplicar el icono al botón Target independiente; ciclo de R6.29/R3.x: seleccionar el objetivo siguiente; sin enemigos, limpiar selección | **Botón independiente, solo móvil y editable por OrdenUI; NO es entrada del micromenú** |

* Usar los IDs registrados en ASSETS_LIST, enlazados por config; no redibujar ni cambiar los masters.
* Mantener el tamaño/padding/estado visual de los iconos actuales del micromenú; el tooltip/label accesible identifica las acciones (Dungeon, Guía, Party). El botón Target independiente usa su icono y tooltip/label propios.
* `Icon_Menu_target_cycle` **no** es `Icon_Menu_nameplates`: el primero cambia el enemigo seleccionado; el segundo solo muestra/oculta nameplates y conserva su comportamiento.

#### 1.1 Atajos de teclado PC

* **G** abre/cierra la Guía de la Helada.
* **O** abre/cierra el panel Party.
* **J** abre/cierra el panel/lobby Dungeon.
* Atajos PC y acciones del micromenú llaman la **misma acción** (no crean ventanas/estados duplicados). PC no muestra botón Target: usa TAB.
* No disparar atajos mientras un TextBox o campo de texto tiene el foco; prevenir doble activación al combinar tecla y click.

#### 1.2 Componentes globales reutilizables

* **Botón cerrar:** crear un único componente reusable `MenuCloseButton` con `Icon_UI_close` (`rbxassetid://130341785019897`), que se use en todos los paneles/ventanas globales. Estados normal/hover/pressed/disabled coherentes; click/cierre con contrato común. Reemplazar los X dibujados de manera independiente donde corresponda, sin cambiar la lógica de cierre de cada ventana.
* **Oro global:** usar `Icon_UI_currency_gold` (`rbxassetid://95443487243282`) como pictograma canónico en todos los contadores/precios/recompensas del juego (HUD, mochila, vendors, loot, comercio/subasta y tooltips). Reemplazar variantes/inconsistencias visuales cuando se integre el icono; no cambiar el dato ni el formato del saldo.
* **Responsividad:** componentes de cierre y oro deben conservar proporción/tamaño legible en PC y móvil; targets táctiles mínimos 44 px donde sean interactivos. El botón cerrar usa el mismo componente visual y puede escalar por ventana.

#### 2. Retirar botones sueltos y OrdenUI

* Retirar del HUD móvil los botones independientes de **Dungeon** y **Party**; sus acciones pasan al micromenú.
* **Target permanece como botón independiente en móvil**, ahora con `Icon_Menu_target_cycle`; se mantiene movible/editable en el OrdenUI móvil según R6.29. No aparece en PC ni reserva slot en el OrdenUI de PC (PC usa TAB).
* **Correr** permanece como botón móvil independiente y movible en OrdenUI. `NotificationFrame` de R6.31 centraliza avisos pasivos de sistema; `LootPopup` de R6.29 permanece separado y movible en PC/móvil.
* Limpiar del OrdenUI móvil solo las posiciones persistidas de los botones independientes de Dungeon y Party, sin borrar las posiciones de PC ni pisar datos de otra plataforma.

#### 3. Autoridad / compatibilidad

* Dungeon/Guía/Party llaman las mismas acciones y ventanas existentes; no duplicar flujos ni crear runs al abrir el acceso.
* Target reutiliza exactamente el ciclo de R6.29/R3.x (incluida la regla sin enemigos: limpiar selección). No añade un algoritmo alternativo.
* No alterar el toggle de nameplates, la lógica del micromenú, el botón Correr ni TAB/click de PC.

---

### Criterios de aceptación (Gherkin)

#### Escenario 1: Accesos integrados

* **GIVEN** el micromenú abierto
* **WHEN** se revisan sus acciones
* **THEN** aparecen Dungeon, Guía y Party en el micromenú en PC y móvil, tanto en Hub como en dungeon; el botón Target independiente de móvil usa su icono aprobado
* **AND** PC también puede abrir Dungeon con J, Party con O y Guía con G
#### Escenario 2: Botones sueltos retirados

* **GIVEN** un jugador móvil
* **WHEN** carga el HUD
* **THEN** no hay botones flotantes independientes de Dungeon ni Party; siguen Correr, Target con icono (movible por OrdenUI) y el `LootPopup` independiente; los demás avisos pasivos usan el `NotificationFrame` central de R6.31

#### Escenario 3: Target independiente solo móvil

* **GIVEN** jugador móvil con enemigos
* **WHEN** pulsa el botón Target independiente con `Icon_Menu_target_cycle`
* **THEN** recorre los objetivos según R6.29/R3.x; sin enemigos, limpia selección
* **AND** en PC no aparece el botón ni un slot vacío; TAB permanece intacto

#### Escenario 4: Enlaces sin duplicar lógica

* **GIVEN** las entradas Dungeon/Guía/Party
* **WHEN** se seleccionan
* **THEN** abren las pantallas/acciones existentes, sin crear una segunda dungeon, party o estado

#### Escenario 5: Persistencia OrdenUI

* **GIVEN** posiciones de OrdenUI guardadas para PC y móvil
* **WHEN** se retiran los botones sueltos en móvil
* **THEN** se limpian solo las posiciones móviles de Dungeon/Party; Correr y `LootPopup` conservan sus posiciones PC/móvil, sin que un guardado de PC pise el de móvil; `NotificationFrame` conserva su posición de R6.31

#### Escenario 6: Regresión visual/funcional

* **GIVEN** los iconos integrados
* **WHEN** se usa el micromenú en PC y móvil
* **THEN** Nameplates, Correr, `NotificationFrame`, `LootPopup`, TAB/click y ventanas existentes siguen funcionando; sin errores rojos

#### Escenario 7: Botón cerrar reusable

* **GIVEN** cualquier menú o panel global compatible
* **WHEN** se renderiza en PC o móvil
* **THEN** usa el componente `MenuCloseButton` y `Icon_UI_close`; click/tap cierra mediante el callback existente, con escala/touch responsivos

#### Escenario 8: Icono de oro global

* **GIVEN** un contador, precio o recompensa de oro
* **WHEN** aparece en HUD, inventario, vendors, loot o economía
* **THEN** usa el icono canónico `Icon_UI_currency_gold` sin cambiar saldo ni formato

---

### Alcance

#### Incluye

* Enlace de iconos Dungeon/Guía/Party y Target móvil; atajos PC G/O/J.
* Componente reusable MenuCloseButton global y uso del icono de oro canónico en todo el juego.
* Retirada de botones sueltos móviles Dungeon/Party y limpieza segura del OrdenUI móvil; Target permanece independiente móvil; R6.31 controla `NotificationFrame` y R6.29 conserva `LootPopup` separado en PC/móvil.

#### No incluye

* Rediseñar el micromenú, rehacer iconos, modificar las ventanas abiertas por cada acción, cambiar targeting de PC, retirar Correr/LootPopup ni cambiar el comportamiento del `NotificationFrame` definido en R6.31, ni modificar el toggle de nameplates.

---

### Definition of Done

* [ ] Iconos Dungeon/Guía/Party enlazados globalmente y Target enlazado al botón móvil independiente.
* [ ] Atajos PC G (Guía), O (Party), J (Dungeon) funcionales, sin conflicto con campos de texto.
* [ ] Dungeon, Guía y Party funcionan desde el micromenú global (PC/móvil, Hub/dungeon).
* [ ] Botones sueltos móviles de Dungeon/Party retirados; Target independiente conserva su edición/posición OrdenUI móvil y muestra `Icon_Menu_target_cycle`; no aparece en PC.
* [ ] Correr sigue movible en móvil; `LootPopup` permanece independiente y movible en PC/móvil junto al `NotificationFrame` de avisos de sistema; posiciones separadas por plataforma se conservan.
* [ ] `MenuCloseButton` reusable con `Icon_UI_close` integrado en todos los paneles/menús incluidos en el alcance.
* [ ] `Icon_UI_currency_gold` usado como icono canónico en todos los contadores/precios/recompensas del juego.
* [ ] Nameplates, targeting PC y accesos existentes intactos; sin errores rojos (PC/móvil, publicado).
* [ ] Dev prepara RC antes de implementar; nota en GDD después de QA.

---

### Estimación

1–2 sesiones del dev: carga/config de iconos, cableado de acciones, retirada de botones y regresión móvil/PC.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-10-17 | Creación de HU-R6.35: integrar iconos Dungeon/Guía/Party en el micromenú global; Target independiente móvil con icono y OrdenUI; Dungeon/Party/GUÍA también con atajos PC J/O/G |
| 2026-10-17 | **Alcance ampliado por PO:** componente reusable `MenuCloseButton` con `Icon_UI_close` para todos los paneles globales; `Icon_UI_currency_gold` como pictograma canónico en todos los contadores/precios/recompensas; PC/móvil responsive |
| 2026-10-19 | Alineación con R6.31: los avisos de loot se integran en `NotificationFrame` con icono + nombre; Correr sigue independiente y el frame central es el único bloque de notificaciones ordenable en PC/móvil |
| 2026-10-19 | **Reversión de alcance PO:** el loot mantiene `LootPopup` independiente y movible conforme a R6.29; R6.31 centraliza solo los demás avisos pasivos y no absorbe el aviso de adquisición |
