# HU-R6.32: Drag & drop global — eliminar, equipar/usar ítems y asignar skills a la barra (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** UI / Interacción — Mejora (decisión PO 2026-09-22)
**Prioridad:** Alta
**Estado:** Implementada (reporte PO 2026-09-22; verificación/QA pendiente)
**Tipo:** Sistema de interacción (dev) — server-authoritative
**Fase GDD:** R6.32 (cambia la interacción con ítems y skills; no cambia reglas de daño/equip)
**Depende de:** HU-ITEMS-01 (Reglas de equip: dual 1H/2H/escudo/varita, `RequestEquipItem` con `preferredSlot`), R6.5/EST-10/11/21 (panel de personaje y mochila), HU-ESTETICA-42 (grimorio estilo libro + barra equipada), HU-ESTETICA-13 (tokens/handoff), HU-R6.27 (TooltipSystem), HU-ECONOMIA-01/02 (locks de trade/custodia de subasta), HU-ECONOMIA-03 (perfil atómico — cuando exista)
**Componentes observados:** bolsa (EST-11/21), panel de personaje (EST-10), grimorio y barra equipada (EST-42/R5.1), right-click actual (BORRA ítem — se reemplaza), `RequestEquipItem`, remotes de loadout/skills

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** **arrastrar ítems** fuera de la ventana para eliminarlos (con confirmación), **equipar/usar con click derecho o arrastrando el ítem sobre su casilla**, y **arrastrar habilidades del grimorio a la barra de acción**,
**para** manejar el inventario como en WoW — cómodo y sin errores.

---

### **Descripción del Requerimiento / Contexto**

Hoy: **click derecho = BORRA el ítem** (sin confirmación) y no hay drag. Cambios (decisión PO 2026-09-22):

1. **Arrrastrar afuera = eliminar — con confirmación** (patrón WoW: soltar fuera de la ventana abre un modal de borrado; no se borra al instante).
2. **Click derecho = USAR/EQUIPAR** (reemplaza al borrado actual) **o arrastrar el ítem sobre la casilla correspondiente del panel de personaje** → equipa.
3. **Grimorio: arrastrar una skill a la barra equipada del mismo grimorio** → asigna la skill al slot.

**Criterio de hecho global:** el drag funciona en mochila, panel de personaje y grimorio (PC y móvil); el borrado SIEMPRE pasa por confirmación; el equipar/uso valida server-side igual que hoy; el right-click ya no elimina nada.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Drag de ÍTEMS (bolsa EST-11/21 y panel de personaje EST-10)**

* **Eliminar (soltar fuera de la ventana):** al soltar el ítem fuera del contenedor (mochila o personaje) se abre el **modal de confirmación de borrado** con: icono, nombre, cantidad si es pila ("Poción HP x20"), advertencia "No se puede recuperar" → **Confirmar** borra (server) / Cancelar devuelve el ítem a su casilla.
  * Pila >1 → se borra **la pila completa** (decisión PO — como WoW).
  * **Bloqueado:** no se puede eliminar un ítem **equipado** ni con **lock activo** — marcador definido abajo. (Validación de `tradeLocked`/custodia **inerte hasta que ECON-01/02 existan** — nadie escribe el marcador aún; decisión PM 2026-09-22.)

#### **1.1 Contrato del marcador de lock (definido ahora, escritores en ECON-01/02)**

* Campo en la **instancia del ítem** (perfil/inventario R4): `lock = { kind = "trade" | "auction", opId = string } | nil`.
* **Escritores (futuros):** ECON-01 lo setea con sus ops `HOLD_ITEMS`/reserva de trade y lo limpia al completarse/cancelarse · ECON-02 lo setea al publicar (custodia) y lo limpia al venderse/retirarse/expirar (reembolso al buzón).
* **Lector actual (R6.32):** `RequestDeleteItem` rechaza si `item.lock ≠ nil` (con el aviso del TooltipSystem). Como ECON-01/02 no están implementadas, el campo siempre es `nil` → la validación no altera el comportamiento actual; se activa sola cuando la economía escriba los locks.
* **Equipar (drag sobre casilla):** arrastrar el ítem de la mochila y soltarlo **sobre la casilla correspondiente del panel de personaje** (ej. hombreras → slot Shoulders) → `RequestEquipItem { instanceId, preferredSlot }` (mismas reglas ITEMS-01: 1H dual / 2H bloquea offhand / escudo solo OffHand / varita MainHandOnly; ítem de otra clase sin afinidad: se equipa igual — la afinidad es bonus, no hard-lock).
* **Click derecho (PC) = USAR/EQUIPAR (reemplaza al borrado):** consumible → usar; equipable → equipar en su slot default; si no es usable ni equipable → feedback vía TooltipSystem. **Ya NO elimina.**
* **Móvil:** drag con **tap-hold de 300 ms** (decisión PM 2026-09-22): mantener el dedo 300 ms sin moverse >8 px inicia el arrastre; si el dedo se mueve antes, es scroll (se cancela); una vez activado, el ítem sigue al dedo. El **tap corto** (<300 ms) abre el **tooltip informativo** (sin botones — EST-44). **Sin acciones en el tooltip:** usar/equipar se hace por drag (soltar sobre la casilla) y el borrado solo por drag fuera con confirmación.

#### **2. Drag de SKILLS (grimorio EST-42 / R5.1)**

* Arrastrar una **skill aprendida** de la lista del grimorio → soltar en un **slot de la barra equipada del mismo grimorio** (máx 4) → asigna (valida: aprendida, no bloqueada por spec, slot libre; reemplazo de slot existente con su regla actual).
* **Solo dentro del grimorio** (la lista → la barra del mismo panel); NO se arrastran skills a otras ventanas.
* **Click derecho en un slot de la barra** = quitar la skill del slot (comportamiento actual conservado — referencia del diseño EST-09/42).

#### **3. Server-authoritative / anti-exploit**

* Remotes nuevos/ajustados:
  | Remote | Dir | Payload | Validación |
  |--------|-----|---------|------------|
  | `RequestDeleteItem` | C→S | `{ instanceId }` (+ confirmación desde el modal) | ítem del jugador, en la **bolsa** (nunca equipado), sin `tradeLocked`, sin custodia de subasta; borra la pila completa; idempotente (2.º intento = ya no existe) |
  | `RequestEquipItem` | C→S | existente (+ `preferredSlot` según esté disponible) | reglas ITEMS-01 intactas |
  | `RequestAssignSlot` | C→S | `{ skillId, slot }` | skill aprendida, slot 1–4, dentro de carga válida (R3) |
* El **drop fuera de la ventana** valida que el soltado fue en una zona "externa" (el server nunca confía en la posición del cliente: el modal de confirmación es la intención, y el server valida el ítem).
* Deleción escribe sobre el perfil con el contrato de **ECON-03** cuando esté (hasta entonces, flujo actual de inventario sin duplicar).

#### **4. UI / feedback**

* Cursor al arrastrar (sombra del ítem bajo el puntero; casillas destino resaltadas cuando el drop es válido; rojo cuando es inválido).
* Modal de confirmación de borrado: tokens EST-13, botones Confirmar/Cancelar (patrón de confirmaciones existentes — R6.28/EST-15).
* Coherente con el TooltipSystem (R6.27): al arrastrar se oculta el tooltip; los rechazos usan notificaciones centralizadas (R6.31).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Eliminar con confirmación**

* **GIVEN** un ítem en la bolsa
* **WHEN** el jugador lo arrastra fuera de la ventana y suelta
* **THEN** se abre el modal de confirmación (nombre + cantidad de pila + "no se puede recuperar"); **Confirmar** lo elimina del servidor; **Cancelar** lo devuelve a su casilla

#### **Escenario 2: Equipar arrastrando**

* **GIVEN** unas hombreras en la mochila
* **WHEN** el jugador las arrastra a la casilla de hombreras del panel de personaje
* **THEN** se equipan (validaciones ITEMS-01: 1H/2H/escudo/varita) y el ítem sale de la bolsa

#### **Escenario 3: Click derecho = usar/equipar (ya no borra)**

* **GIVEN** un ítem en la bolsa
* **WHEN** click derecho (PC)
* **THEN** **se usa** (consumible) o **se equipa** (equipable) según su slot default — **y nunca se elimina**

#### **Escenario 4: Drag de skill al barra**

* **GIVEN** una skill aprendida en el grimorio
* **WHEN** se arrastra a un slot libre (o ocupado) de la barra equipada del mismo grimorio
* **THEN** se asigna al slot (y reemplaza si estaba ocupado, con su regla actual); fuera del grimorio el drag no hace nada

#### **Escenario 5: Ítems protegidos**

* **GIVEN** un ítem equipado, en trade (ECON-01) o en custodia de subasta (ECON-02)
* **WHEN** se intenta eliminar (drag fuera + confirmar)
* **THEN** el server rechaza con aviso (TooltipSystem) — no se elimina

#### **Escenario 6: Anti-exploit**

* **GIVEN** remotes manipulados (borrar ítem ajeno/equipado/repetido)
* **WHEN** se envían
* **THEN** el server rechaza (idempotente y validado)

#### **Escenario 7: Móvil**

* **GIVEN** móvil
* **WHEN** se usan tap-hold + herramienta del tooltip
* **THEN** arrastrar/eliminar/equipar/usar funcionan sin conflictos de touch y con confirmaciones visibles

#### **Escenario 8: Regresión**

* **GIVEN** el sistema implementado
* **WHEN** se juega el flujo completo (PC y móvil, publicado)
* **THEN** no hay errores rojos; equipar/dual/2H y la barra de 4 skills siguen igual

---

### **Alcance**

#### Incluye

* Drag para: eliminar (fuera de ventana + confirmación), equipar/usar (click derecho reemplaza al borrado; drag sobre casilla), asignar skills del grimorio a su barra (drag interno).
* Modal de confirmación de borrado + feedback de drops válidos/inválidos.

#### No incluye

* Reordenamiento de la bolsa (NO ordena — decisión EST-11), drag entre ventanas fuera de grimorio→su barra, ni cambios a reglas de equip (ITEMS-01 intactas).

---

### **Definition of Done (DoD)**

* [ ] Eliminar con drag fuera + modal de confirmación (pila completa; ítems protegidos rechazados).
* [ ] Click derecho usa/equipa (nunca borra); drag a casilla equipa con validaciones ITEMS-01.
* [ ] Drag de skills del grimorio a su barra asigna slot (con reemplazo/reglas actuales).
* [ ] Server-authoritative (endpoints validados e idempotentes).
* [ ] PC y móvil OK; sin errores rojos (regresión de equip/dual/2H/barra).
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Decisiones cerradas (PO 2026-09-22)**

| Tema | Decisión |
|------|----------|
| Click derecho | **USAR/EQUIPAR** (reemplaza al borrado actual) |
| Eliminar | **Drag fuera de la ventana + modal de confirmación** (icono, cantidad, "no se puede recuperar"); borra la pila completa |
| Equipar por drag | Sobre la casilla correspondiente del panel de personaje (preferredSlot; reglas ITEMS-01) |
| Skills | Drag solo del grimorio → **su propia barra** (máx 4, reemplazo con regla actual); right-click en slot = quitar |
| Móvil | **Tap-hold 300 ms** para arrastrar; tap corto = **tooltip informativo** (sin botones — EST-44); usar/equipar por drag a la casilla; borrado solo por drag fuera + confirmación |
| Protegidos | No se eliminan: equipados + ítem con **`lock`** (campo `{kind, opId}` definido en la instancia; `trade` lo escribe ECON-01, `auction` ECON-02 — **hoy inerte: nadie lo escribe aún**) |
| Bolsa | Sin reordenamiento por drag (no ordena — EST-11) |
| Móvil (tap-hold) | **300 ms** para iniciar el arrastre; movimiento >8 px antes de eso = scroll (se cancela); tap corto = interacción normal |

---

### **Estimación (orientativa)**

3–4 sesiones del dev: drag cliente + remotes + modal + validaciones + móvil + regresión.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-R6.32: drag & drop global — eliminar ítems (drag fuera + **confirmación**, pila completa, ítems protegidos por trade/subasta/equipado), **click derecho = usar/equipar (reemplaza al borrado)**, equipar arrastrando a la casilla (preferredSlot, ITEMS-01), y asignar skills del grimorio a su barra equipada (drag interno); server-authoritative; móvil = tap-hold (decisión PO) |
| 2026-09-22 | **Corrección PO: tooltips SIN botones** — el tooltip es solo informativo (EST-44); las acciones (usar/equipar) van por drag a la casilla o click derecho, y el borrado solo por drag fuera con confirmación (se elimina la referencia al tooltip contextual de EST-11) |