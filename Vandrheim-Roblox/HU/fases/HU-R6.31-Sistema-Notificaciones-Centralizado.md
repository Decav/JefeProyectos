# HU-R6.31: Sistema de notificaciones centralizado — frame único ordenable en el OrdenUI (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R6.x / UI — Mejora (decisión PO 2026-09-22)
**Prioridad:** Alta
**Estado:** Lista para implementar (RC obligatorio del dev antes de programar)
**Tipo:** Sistema de UI (dev)
**Fase GDD:** R6.31 (no cambia reglas de juego — centraliza feedback)
**Depende de:** HU-R6.20 (OrdenUI config + persistencia), R8c (HUD), HU-R6.27 (feedback claro de UI), R5/R5.2 (consumibles), skills/InventoryService/Vendor etc. (fuentes de mensajes)
**Componentes observados:** mensajes/feedback actuales (errores, avisos, éxitos) distribuidos en UI, OrdenUI (R6.20), HUD

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que **todas** las notificaciones del juego (errores, avisos y éxitos) aparezcan **en un solo apartado ordenado** y que ese frame se pueda **mover con el OrdenUI**,
**para** que el feedback deje de aparecer al azar en cualquier lado y la UI se sienta ordenada.

---

### **Descripción del Requerimiento / Contexto**

**Problema:** los mensajes de error y feedback de acciones (no puedes usar un objeto, skill en enfriamiento, inventario lleno, compra rechazada, etc.) aparecen **en lugares arbitrarios y sin orden**. Se centralizan **todas** las notificaciones en un **frame único** con cola ordenada, y ese frame se agrega al **OrdenUI** (config R6.20) para poder moverse.

**Criterio de hecho global:** existe un NotificationFrame central: todos los mensajes del juego pasan por él (cola ordenada, tipos visibles), se pueden mover/ordenar con el OrdenUI (PC y móvil) y desaparecen los mensajes sueltos del HUD.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. NotificationService / NotificationFrame (cliente)**

* **Frame único** (pila/toast apilada, con límite visible de mensajes y cola): duración por tipo, orden cronológico, prioridad (error > aviso > éxito > info) para no enterrar lo importante.
* **Tipos de mensaje:** error (rojo), aviso (ámbar), éxito (verde), info (pergamino) — tokens EST-13, coherente con R6.27.
* **Fuentes a migrar (todas):** consumibles (no puedes usar / sin pociones / buff activo) · skills (sin maná, en enfriamiento, sin target, fuera de rango) · inventario (bolsa llena, ítem ligado, no equipable, nivel insuficiente) · equipar/desequipar · vendors (sin oro, compra/vende OK) · loot (recogido, mochila llena) · party (invitaciones, expulsión, R9a) · subasta/comercio (ECON-01/02: publicar, comprado, vendido, rechazo) · tutorial (avisos) · muerte/revive (R6.28) · cualquier mensaje suelto del HUD actual.
* **Se eliminan los mensajes flotantes dispersos** (reemplazados por el frame central). El frame NO reemplaza: barras de estado, boss bar, tooltips o diálogos modales con botones (solo mensajes pasivos).

#### **2. OrdenUI**

* El NotificationFrame entra al **OrdenUI** (R6.20): movible/ordenable en **PC y móvil**, con persistencia.
* Posición por defecto razonable (ej. centro-superior o esquina según plataforma) y sin romper el resto del HUD.

#### **3. Reglas**

* API única interna (cliente): `notify(type, message[, duration])` — todas las fuentes la usan (prohibido crear mensajes sueltos).
* Server-authoritative donde aplique (mensajes críticos validados por el server, como el feedback de rechazos — el sistema actual ya valida; solo cambia el canal de presentación).
* Sin cambios de gameplay: solo centralizar la presentación.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Todo centralizado**

* **GIVEN** el sistema implementado
* **WHEN** ocurren acciones con feedback (error de consumible, skill en CD, bolsa llena, compra, loot, partys…)
* **THEN** todos los mensajes aparecen en el **NotificationFrame** (cola ordenada, tipo visible) y **ninguno** aparece suelto en la UI

#### **Escenario 2: Orden y prioridad**

* **GIVEN** varios mensajes a la vez
* **WHEN** se muestran
* **THEN** respetan el orden cronológico y la prioridad (los errores no quedan enterrados por avisos/éxitos)

#### **Escenario 3: Movible con OrdenUI**

* **GIVEN** el NotificationFrame
* **WHEN** se abre el OrdenUI
* **THEN** se puede mover (PC y móvil) y la posición se persiste

#### **Escenario 4: No rompe lo existente**

* **GIVEN** el sistema activo
* **WHEN** se juega el flujo completo
* **THEN** barras de estado, boss bar, tooltips y modales con botones funcionan igual — solo se centralizó el feedback pasivo

#### **Escenario 5: Regresión**

* **GIVEN** el sistema implementado
* **WHEN** se juega completo (PC y móvil, publicado)
* **THEN** no hay errores rojos y todas las fuentes migraron (sin mensajes sueltos)

---

### **Alcance**

#### Incluye

* NotificationFrame central (cola, tipos, prioridad) + API única `notify(type, message, duration)`.
* Migración de TODAS las fuentes de mensajes actuales.
* Entrada en el OrdenUI (PC y móvil) con persistencia.

#### No incluye

* Modales con botones, barras de estado ni tooltips (solo feedback pasivo).

---

### **Definition of Done (DoD)**

* [ ] NotificationFrame central funcional (cola + tipos + prioridad + duración).
* [ ] Todas las fuentes migradas (consumibles, skills, inventario, vendors, loot, party, economía, tutorial, muerte/revive) — cero mensajes sueltos.
* [ ] Movible con el OrdenUI (PC y móvil) con persistencia.
* [ ] Sin errores rojos; HUD/estado/modales intactos.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Estimación (orientativa)**

2–3 sesiones del dev: NotificationFrame + API + migración de todas las fuentes + OrdenUI.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-R6.31: sistema de notificaciones centralizado — frame único con cola ordenada (errores/avisos/éxitos/info, prioridad), API `notify()` para todas las fuentes (consumibles, skills, inventario, vendors, loot, party, economía, tutorial, muerte), movible con el OrdenUI en PC y móvil; se eliminan los mensajes sueltos (reportado por PO) |