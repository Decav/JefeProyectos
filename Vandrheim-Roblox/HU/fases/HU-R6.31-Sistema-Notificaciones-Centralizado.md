# HU-R6.31: Sistema de notificaciones centralizado — frame único ordenable en el OrdenUI (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R6.x / UI — Mejora (decisión PO 2026-09-22)
**Prioridad:** Alta
**Estado:** **Cerrada por confirmación explícita del PO (2026-10-19): implementación y QA completos.**
**Tipo:** Sistema de UI (dev)
**Fase GDD:** R6.31 (no cambia reglas de juego — centraliza feedback)
**Depende de:** HU-R6.11/20 (OrdenUI, whitelist y persistencia por personaje), HU-R6.29 (LootPopup separado y OrdenUI por plataforma), R8c (HUD), HU-R6.27 (feedback claro de UI), R5/R5.2 (consumibles), skills/InventoryService/Vendor etc. (fuentes de mensajes)
**Componentes observados:** mensajes/feedback actuales (errores, avisos, éxitos) distribuidos en UI, OrdenUI (R6.20), HUD

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que los avisos pasivos del sistema (errores, avisos, éxitos e información) aparezcan **en un solo apartado ordenado** y que ese frame se pueda **mover con el OrdenUI**,
**para** que el feedback deje de aparecer al azar en cualquier lado y la UI se sienta ordenada.

---

### **Descripción del Requerimiento / Contexto**

**Problema:** los mensajes de error y feedback de acciones (no puedes usar un objeto, skill en enfriamiento, inventario lleno, compra rechazada, etc.) aparecen **en lugares arbitrarios y sin orden**. Se centralizan los avisos pasivos de sistema en un **frame único** con cola ordenada, y ese frame se agrega al **OrdenUI** (config R6.20) para poder moverse. La adquisición de loot conserva su `LootPopup` independiente (R6.29).

**Criterio de hecho global:** existe un NotificationFrame central para todos los avisos pasivos de sistema (cola ordenada, tipos visibles), movible con el OrdenUI (PC y móvil); el aviso de adquisición de loot permanece en `LootPopup` por separado, conforme a R6.29.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. NotificationService / NotificationFrame (cliente)**

* **Un único contenedor raíz `NotificationFrame`** contiene todos los avisos; cada toast es hijo visual de ese frame, nunca un elemento independiente del HUD ni un elemento separado del OrdenUI.
* Cola visual: máximo **2 avisos simultáneos**. Si ambos espacios están ocupados, los nuevos esperan en cola priorizada; no se descarta un error para mostrar un mensaje de menor prioridad. Los avisos repetidos se consolidan con contador (ej. `Sin maná ×3`) en vez de crear una fila por repetición.
* Cada aviso es de **una línea, sin caja ni botón de cierre**; desaparece solo tras **2 s** (errores: **2,5 s**) con fade. Los avisos largos/historial permanecen en el chat.
* Al liberar un espacio, mostrar primero la prioridad **error > aviso > éxito > info**; entre avisos de la misma prioridad, mantener orden de llegada.
* **Tipos de mensaje:** error (rojo), aviso (ámbar), éxito (verde), info (pergamino) — tokens EST-13, coherente con R6.27.
* **Fuentes a migrar:** consumibles (no puedes usar / sin pociones / buff activo) · skills (sin maná, en enfriamiento, sin target, fuera de rango) · inventario (bolsa llena, ítem ligado, no equipable, nivel insuficiente) · equipar/desequipar · vendors (sin oro, compra/vende OK) · mensajes de error de inventario/loot (ej. mochila llena) · party (invitaciones, expulsión, R9a) · subasta/comercio (ECON-01/02: publicar, comprado, vendido, rechazo) · tutorial (avisos) · muerte/revive (R6.28) · cualquier aviso pasivo de sistema suelto del HUD actual. El aviso de adquisición de ítems se mantiene fuera de esta migración como `LootPopup`.
* **Se eliminan los avisos pasivos de sistema dispersos** (reemplazados por el frame central). El frame NO reemplaza: `LootPopup` de adquisición (R6.29), barras de estado, boss bar, tooltips o diálogos modales con botones.

#### **2. OrdenUI**

* Agregar **un solo `elementId = "NotificationFrame"`** a la whitelist editable existente de R6.11/R6.20 y a `profile.uiLayout`; guardar posición (y escala si usa el comportamiento común de R6.20) **por personaje y por plataforma** (R6.29 PC/móvil). Los toast hijos no tienen posición/persistencia individuales.
* Al ordenar la UI, arrastrar el marco raíz mueve la pila completa de avisos. El cambio de contenido o llegada de un nuevo toast no restaura su posición por defecto.
* Posición por defecto: **centro superior, debajo del TargetFrame**, sin tapar al personaje ni las habilidades. Una vez movido por el jugador, respetar su posición guardada, con clamp y zona segura.
* Editable en **PC y móvil** mediante el modo Ordenar UI existente; no crear un modo drag propio para las notificaciones. Mover el frame raíz desplaza juntos los avisos pasivos de sistema; `LootPopup` conserva su posición separada de R6.29.

#### **3. Reglas**

* API única interna (cliente): `notify(type, message[, duration])` — todas las fuentes de aviso pasivo de sistema la usan (prohibido crear mensajes sueltos). `LootPopup` de adquisición mantiene su contrato separado de R6.29.
* Server-authoritative donde aplique (mensajes críticos validados por el server, como el feedback de rechazos — el sistema actual ya valida; solo cambia el canal de presentación).
* Sin cambios de gameplay: solo centralizar la presentación.

---

### **Referencia visual del diseñador (Pencil)**

Referencia visual (solo lectura): `Vandrheim-design.pen`, nodos `AUchh` (frame) y `Ha041` (toast master); la pila de preview es `D7iCZu` dentro de `nlV7M`. Los rótulos visibles `EST-41` son nombres del canvas, no el ID de esta HU (EST-41 está asignado al árbol de talentos). Para código/seguimiento, usar HU-R6.31 y los IDs de nodo; no se modificó Pencil.

* Default visual: stack transparente en el centro superior, bajo el objetivo; mensajes de texto en línea, sin panel, marco ni cierre.
* Master del toast: marcador pequeño por tipo + texto legible con sombra suave; el color/marker varía por tipo según la regla de §1.
* Ejemplos del mockup: error `No tienes maná suficiente · Fuego Sagrado (18 MP)` y confirmación `Equipado: Espada de escarcha`.
* La adquisición de loot no requiere una variante visual en `NotificationFrame`; conserva su `LootPopup` dedicado con icono y nombre según R6.29.
* Toda la pila debe quedar parentada a un único `NotificationFrame` movible con OrdenUI; no convertir cada instancia del master en un item independiente de la whitelist.
* **Color de éxito (decisión PO 2026-10-19):** `Equipado: Espada de escarcha` es un éxito y usa verde `#7BC47F` (referencia visual de HU-ESTETICA-19); esta regla de producto prevalece sobre el ejemplo dorado del Pencil, que queda como referencia visual sin editar.
* **Decisión PO 2026-10-19:** se revierte la propuesta anterior de absorber `LootPopup`; la adquisición de loot permanece en su popup independiente de R6.29. Correr también sigue independiente en OrdenUI.
* **Cola (decisión PO 2026-10-19):** máximo 2 visibles; los nuevos esperan en cola priorizada (error > aviso > éxito > info, FIFO dentro de prioridad). Esta regla prevalece sobre la nota antigua del Pencil que dice que el tercero desplaza al más antiguo.
* **Identificación del diseño:** el rótulo visible `EST-41` se conserva como nombre de canvas, no como HU; HU-ESTETICA-41 sigue siendo el árbol de talentos. El dev usa `AUchh`/`Ha041` como referencia visual y HU-R6.31 como requerimiento.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Todo centralizado**

* **GIVEN** el sistema implementado
* **WHEN** ocurren acciones con aviso pasivo de sistema (error de consumible, skill en CD, bolsa llena, compra, party…)
* **THEN** todos esos avisos aparecen en el **NotificationFrame** (cola ordenada, tipo visible) y ninguno aparece suelto en la UI
* **AND** cada toast es hijo del mismo frame raíz; el chat conserva el aviso para leerlo después
* **AND** la adquisición de un ítem se muestra en `LootPopup`, independiente del `NotificationFrame`, según R6.29

#### **Escenario 2: Orden y prioridad**

* **GIVEN** varios mensajes a la vez
* **WHEN** se muestran
* **THEN** se muestran como máximo dos a la vez; lo demás espera en cola, con prioridad error > aviso > éxito > info y orden de llegada dentro de cada prioridad
* **AND** una notificación de menor prioridad no desplaza ni descarta un error ya visible o pendiente
* **AND** los repetidos se consolidan en una notificación con contador

#### **Escenario 3: Movible con OrdenUI**

* **GIVEN** el NotificationFrame
* **WHEN** se abre el OrdenUI
* **THEN** se mueve el `NotificationFrame` raíz completo (PC y móvil), y una posición por plataforma se persiste por personaje en `profile.uiLayout`; los mensajes individuales no generan entradas de layout

#### **Escenario 4: No rompe lo existente**

* **GIVEN** el sistema activo
* **WHEN** se juega el flujo completo
* **THEN** barras de estado, boss bar, tooltips y modales con botones funcionan igual — solo se centralizó el feedback pasivo

#### **Escenario 5: Regresión**

* **GIVEN** el sistema implementado
* **WHEN** se juega completo (PC y móvil, publicado)
* **THEN** no hay errores rojos y todas las fuentes migraron (sin mensajes sueltos)

#### **Escenario 6: Separación del aviso de adquisición de loot**

* **GIVEN** el inventario recibe un ítem de loot
* **WHEN** se notifica la adquisición
* **THEN** se conserva el `LootPopup` independiente y movible de R6.29; no se duplica en `NotificationFrame`

---

### **Alcance**

#### Incluye

* NotificationFrame central (cola, tipos, prioridad) + API única `notify(type, message, duration)`.
* Migración de TODAS las fuentes de mensajes actuales.
* Entrada en el OrdenUI (PC y móvil) con persistencia.

#### No incluye

* Modales con botones, barras de estado ni tooltips (solo feedback pasivo).
* La adquisición de loot en `LootPopup`; R6.31 centraliza errores/avisos pasivos de sistema, pero no absorbe ese popup.

---

### **Definition of Done (DoD)**

* [x] NotificationFrame central funcional (cola + tipos + prioridad + duración).
* [x] Cola con máximo 2 visibles y prioridad error > aviso > éxito > info; mensajes restantes esperan y no descartan errores por mensajes de menor prioridad.
* [x] Todas las fuentes pasivas de sistema migradas (consumibles, skills, errores de inventario, vendors, party, economía, tutorial, muerte/revive) — cero mensajes sueltos; la adquisición de loot conserva su `LootPopup`.
* [x] Todos los avisos de sistema se agrupan en el único `NotificationFrame` raíz y también quedan en el chat; `LootPopup` permanece fuera.
* [x] Solo `NotificationFrame` entra en la whitelist del OrdenUI; moverlo desplaza la pila completa y persiste por personaje y plataforma con el layout existente.
* [x] Posición por defecto centro superior bajo el objetivo; OrdenUI permite cambiarla con clamps/zona segura y no se resetea al refrescar la cola.
* [x] Sin errores rojos; HUD/estado/modales intactos (confirmación de cierre del PO).
* [x] `LootPopup` continúa independiente y movible según R6.29; no se integra ni duplica dentro del `NotificationFrame`.
* [x] La cola priorizada no reemplaza un mensaje prioritario por el más nuevo.
* [x] Referencias Pencil identificadas por `AUchh`/`Ha041`; las reglas de HU prevalecen sobre rótulos/notas antiguas del canvas.
* [x] RC/implementación/QA y nota de GDD confirmados por el PO como cerrados.

---

### **Estimación (orientativa)**

2–3 sesiones del dev: NotificationFrame + API + migración de todas las fuentes + OrdenUI.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-R6.31: sistema de notificaciones centralizado — frame único con cola ordenada (errores/avisos/éxitos/info, prioridad), API `notify()` para todas las fuentes (consumibles, skills, inventario, vendors, loot, party, economía, tutorial, muerte), movible con el OrdenUI en PC y móvil; se eliminan los mensajes sueltos (reportado por PO) |
| 2026-10-19 | Revisión PM de la base Pencil `AUchh` + master `Ha041`: una línea sin caja/cierre, máximo 2 visibles, duración 2 s/2,5 s para error, repetidos consolidados y chat log. Se registran ajustes pendientes de diseñador: regla de prioridad, éxito verde y rótulo HU-R6.31. El loot conserva `LootPopup` por R6.29 |
| 2026-10-19 | Decisión PO de cola: máximo 2 avisos visibles; el resto espera en cola priorizada (error > aviso > éxito > info, FIFO dentro de prioridad). Un aviso nuevo no expulsa un error visible/pendiente. El Pencil aún requiere esa actualización |
| 2026-10-19 | **Reversión de alcance PO:** la adquisición de loot permanece en el `LootPopup` independiente de R6.29; R6.31 centraliza el resto de avisos pasivos del sistema. Se descarta el brief visual de variante de loot dentro del NotificationFrame |
| 2026-10-19 | **Cierre HU confirmado por el PO:** implementación y QA completos; DoD aceptado. El Pencil queda como referencia sin modificar y las reglas de producto vigentes de esta HU prevalecen sobre sus anotaciones visuales anteriores |
