# HU-R6.29: Mejoras UI móvil — botón Target independiente, Correr y Loot en el OrdenUI

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R6.x / UI móvil — Mejora (decisión PO 2026-09-22)
**Prioridad:** Alta
**Estado:** Implementada (confirmación del PO 2026-10-22; RC cerrado)
**Tipo:** Mejoras de UI (dev)
**Fase GDD:** R6.29 (no cambia reglas de juego)
**Depende de:** HU-R3.1/R3.3 (targeting TAB/click + indicador visual), HU-R6.14/15 (controles móviles), HU-R6.20 (OrdenUI — escala/orden configurable), HU-R6.21 (target de habilidades), R8c (HUD), loot pickup (R6a/R4)
**Componentes observados:** OrdenUI (config R6.20), botón Correr (móvil), TAB de PC, botón/frame de loot del piso, HUD R8c

---

### **Narrativa (INVEST)**

**Como** jugador móvil,
**quiero** un **botón Target** que seleccione al enemigo más cercano y alterne (como el TAB de PC), y poder **mover mis botones** (Target y Correr) en la pantalla,
**para** jugar en móvil con el mismo control de objetivo que en PC.

**Como** jugador (PC y móvil),
**quiero** mover el **botón de loot** en la pantalla como el resto de la UI,
**para** acomodarla a mi gusto.

---

### **Descripción del Requerimiento / Contexto**

En móvil no existe TAB ni forma de targetear alternando enemigos. R6.29 define el comportamiento de target (seleccionar el más cercano, alternar y limpiar si no hay enemigos) como **botón independiente en el HUD móvil**, movible en el OrdenUI. R6.35 le asigna `Icon_Menu_target_cycle` y mueve únicamente los accesos de Dungeon y Party al micromenú. El botón **Correr** y el **LootPopup de adquisición** siguen como elementos independientes del OrdenUI; el LootPopup es movible en PC y móvil y no forma parte de R6.31.

**Criterio de hecho global:** en móvil, el botón Target independiente selecciona/alterna enemigos como TAB; Correr y Target son movibles vía OrdenUI solo en móvil; el `LootPopup` de adquisición sigue siendo independiente y movible en PC y móvil.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Acción TARGET (móvil; presentación en micromenú por R6.35)**

* Botón Target **independiente en el HUD móvil**; al presionarlo → selecciona el **enemigo más cercano** al jugador (patrón TAB de R3.1); **cada pulsación alterna** al siguiente enemigo (patrón de ciclo de R3.1/R3.3 — mismo orden/prioridad que TAB).
* El botón usa el icono `Icon_Menu_target_cycle` de R6.35; el icono no implica que el botón pertenezca al micromenú.
* Muestra el indicador de target existente (R3.3: contorno + flecha) sobre el seleccionado.
* **Sin enemigos cercanos → LIMPIA la selección actual** (mismo comportamiento que TAB — decisión PM 2026-09-22, cerrada para rc079).
* La acción Target **no aparece en PC** (TAB nativo), tampoco como entrada ni slot vacío del micromenú/OrdenUI.

#### **2. OrdenUI (config R6.20)**

* Se agregan al OrdenUI (movibles/ordenables con el sistema existente):
  * **Botón Correr** (móvil, existente) — *solo móvil*.
  * **LootPopup (aviso de loot recibido)** — **PC y móvil**: el loot va **directo al inventario** (no hay pickups en el piso — GDD/R6a); este aviso temporal de adquisición sigue siendo un elemento propio del HUD y movible por el jugador. Por decisión PO 2026-10-19, **no se absorbe en el NotificationFrame de R6.31**.
* Target ya no es un elemento independiente del OrdenUI: su ubicación dentro del micromenú se define en R6.35. Los ítems marcados **mobile-only** no se muestran en PC ni dejan slots fantasmas.
* **Persistencia por plataforma (decisión PM):** un guardado desde PC preserva las posiciones de PC y no pisa las de móvil (TouchEnabled separa los controles móviles — la config guarda posiciones por plataforma). Target/Correr móvil y LootPopup PC/móvil conservan sus posiciones separadas.

#### **3. Reglas**

* Nada de esto cambia el comportamiento de targeting en PC (TAB intacto) ni el resto del HUD.
* Coherente con el sistema de escala/orden de R6.20 (persistencia incluida).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Botón Target independiente en móvil**

* **GIVEN** un jugador móvil con enemigos cercanos
* **WHEN** pulsa el botón Target independiente
* **THEN** se selecciona el enemigo más cercano (indicador R3.3 visible) y con cada pulsación alterna al siguiente

#### **Escenario 2: Sin enemigos**

* **GIVEN** móvil sin enemigos cercanos
* **WHEN** pulsa Target
* **THEN** **la selección actual se limpia** (mismo comportamiento que TAB — decisión PM)

#### **Escenario 3: Correr y Target movibles (solo móvil)**

* **GIVEN** la UI móvil
* **WHEN** se abre el OrdenUI
* **THEN** los botones **Correr** y **Target** se pueden mover/ordenar y la posición se persiste

#### **Escenario 4: No aparece en PC**

* **GIVEN** un jugador en PC
* **WHEN** se carga el HUD
* **THEN** ni el botón Target ni el botón Correr aparecen en PC (ni slots fantasmas en OrdenUI); TAB queda intacto

#### **Escenario 5: LootPopup independiente movible (PC y móvil)**

* **GIVEN** un ítem de loot se acredita directamente al inventario (no hay pickup)
* **WHEN** se publica su aviso
* **THEN** aparece el `LootPopup` independiente de adquisición
* **AND** al abrir OrdenUI (PC/móvil), el usuario puede mover el LootPopup y su posición se persiste por personaje/plataforma; no se integra en `NotificationFrame`

#### **Escenario 6: Regresión**

* **GIVEN** los cambios aplicados
* **WHEN** se juega el flujo completo (PC y móvil, publicado)
* **THEN** TAB/click en PC intactos y no hay errores rojos

---

### **Alcance**

#### Incluye

* Botón Target móvil (más cercano + alternar, icono `Icon_Menu_target_cycle` de R6.35).
* OrdenUI: Correr + Target (mobile-only) y LootPopup independiente (PC y móvil), persistencia por plataforma.

#### No incluye

* Cambios al targeting de PC ni a las reglas de combate.

---

### **Definition of Done (DoD)**

* [ ] Botón Target independiente selecciona/alterna como TAB (indicador R3.3, icono de R6.35).
* [ ] Correr y Target movibles vía OrdenUI (solo móvil); LootPopup independiente movible en PC/móvil con persistencia por personaje/plataforma; no se absorbe en `NotificationFrame`.
* [ ] Target y Correr no aparecen en PC (TAB intacto para target).
* [ ] Sin errores rojos (PC y móvil, publicado).
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Estimación (orientativa)**

1–2 sesiones del dev: botón Target + entradas de OrdenUI + regresión.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-R6.29: comportamiento de Target móvil (seleccionar el más cercano y alternar, patrón TAB) + Correr y LootPopup en OrdenUI (reportado por PO) |
| 2026-09-22 | **Decisiones PM cerradas (rc079):** loot directo al inventario → LootPopup movible (no se absorbe en R6.31); sin enemigos, Target limpia selección; OrdenUI persiste por plataforma |
| 2026-10-17 | **Enmienda de icono (R6.35):** Target **sigue como botón móvil independiente y movible en OrdenUI**; se le asigna `Icon_Menu_target_cycle`. Dungeon y Party sí se retiran del HUD móvil y pasan al micromenú. Target no aparece en PC (TAB nativo) |
| 2026-10-19 | **Decisión PO que supersede rc079:** integrar el aviso de adquisición de loot en `NotificationFrame` de R6.31, con icono del ítem + nombre; el frame raíz es el único elemento de notificaciones movible (PC/móvil), persistido por personaje/plataforma. Se elimina el LootPopup independiente |
| 2026-10-19 | **Reversión de alcance PO:** se descarta la integración de la adquisición de loot en `NotificationFrame`; el `LootPopup` independiente de esta HU permanece movible en PC/móvil. R6.31 centraliza los demás avisos pasivos |
