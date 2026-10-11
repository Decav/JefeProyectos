# HU-R6.29: Mejoras UI móvil — botón Target, botones Correr/Target y Loot en el OrdenUI (no en PC)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R6.x / UI móvil — Mejora (decisión PO 2026-09-22)
**Prioridad:** Alta
**Estado:** Lista para implementar (RC obligatorio del dev antes de programar)
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

En móvil no existe TAB ni forma de targetear alternando enemigos — se agrega un **botón Target** con el mismo comportamiento que TAB (selecciona al más cercano y va alternando con cada pulsación). Además, los botones **Correr** (ya existe en móvil) y **Target** entran al **OrdenUI** (config R6.20) para poder moverse — **solo en móvil, NO en PC**. El **loot** también entra al OrdenUI en **PC y móvil**.

**Criterio de hecho global:** en móvil, el botón Target selecciona/alterna enemigos como TAB; los botones Correr y Target son movibles vía OrdenUI **solo en móvil**; el loot es movible vía OrdenUI en **PC y móvil**; nada de esto aparece en PC salvo el loot.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Botón TARGET (móvil)**

* **Botón en el HUD (móvil):** al presionar → selecciona el **enemigo más cercano** al jugador (patrón TAB de R3.1); **cada pulsación alterna** al siguiente enemigo (patrón de ciclo de R3.1/R3.3 — mismo orden/prioridad que TAB).
* Muestra el indicador de target existente (R3.3: contorno + flecha) sobre el seleccionado.
* **Sin enemigos cercanos → LIMPIA la selección actual** (mismo comportamiento que TAB — decisión PM 2026-09-22, cerrada para rc079).
* El botón **no aparece en PC** (TAB nativo).

#### **2. OrdenUI (config R6.20)**

* Se agregan al OrdenUI (movibles/ordenables con el sistema existente):
  * **Botón Target** (móvil) — *solo móvil*.
  * **Botón Correr** (móvil, existente) — *solo móvil*.
  * **LootPopup (aviso de loot recibido)** — **PC y móvil**: el loot va **directo al inventario** (no hay pickups en el piso — GDD/R6a); el LootPopup actual es solo un **aviso temporal de adquisición** y **esa es la interfaz de loot que se vuelve movible** (decisión PM 2026-09-22, cerrada para rc079). El LootPopup **NO se absorbe en el NotificationFrame de R6.31**: queda como elemento propio del HUD, movible por el jugador.
* Regla: los ítems marcados **mobile-only** no se muestran en PC (ni su presencia en la UI ni en la config de orden de PC — sin slots fantasmas).
* **Persistencia por plataforma (decisión PM):** un guardado desde PC preserva las posiciones de PC y no pisa las de móvil (TouchEnabled separa los controles móviles — la config guarda posiciones por plataforma).

#### **3. Reglas**

* Nada de esto cambia el comportamiento de targeting en PC (TAB intacto) ni el resto del HUD.
* Coherente con el sistema de escala/orden de R6.20 (persistencia incluida).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Botón Target en móvil**

* **GIVEN** un jugador móvil con enemigos cercanos
* **WHEN** pulsa Target
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
* **THEN** ni el botón Target ni el Correr aparecen (ni slots fantasmas en el OrdenUI de PC)

#### **Escenario 5: Loot movible (PC y móvil)**

* **GIVEN** el LootPopup (aviso de loot recibido — el loot va directo al inventario, no hay pickup)
* **WHEN** se abre el OrdenUI (PC y móvil)
* **THEN** se puede mover y la posición se persiste (por plataforma — un guardado de PC no pisa el de móvil)
* **AND** no se absorbe en el NotificationFrame de R6.31 (sigue siendo elemento propio del HUD)

#### **Escenario 6: Regresión**

* **GIVEN** los cambios aplicados
* **WHEN** se juega el flujo completo (PC y móvil, publicado)
* **THEN** TAB/click en PC intactos y no hay errores rojos

---

### **Alcance**

#### Incluye

* Botón Target móvil (más cercano + alternar, patrón TAB).
* OrdenUI: Correr + Target (mobile-only) y Loot (PC y móvil).

#### No incluye

* Cambios al targeting de PC ni a las reglas de combate.

---

### **Definition of Done (DoD)**

* [ ] Botón Target móvil selecciona/alterna como TAB (indicador R3.3).
* [ ] Correr y Target movibles vía OrdenUI (solo móvil); Loot movible en PC y móvil; persistencia OK.
* [ ] Nada mobile-only aparece en PC.
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
| 2026-09-22 | Creación de HU-R6.29: mejoras UI móvil — botón **Target** (selecciona el más cercano y alterna, patrón TAB de PC, que no existía en móvil); **Correr y Target al OrdenUI (solo móvil — no en PC)**; **Loot al OrdenUI en PC y móvil** (reportado por PO) |
| 2026-09-22 | **2 decisiones PM cerradas (rc079, dudas del dev):** (1) **el loot va directo al inventario, no hay pickups** → lo movible es el **LootPopup** (aviso temporal de adquisición), que **NO se absorbe en el NotificationFrame de R6.31**; (2) **sin enemigos, Target LIMPIA la selección** (igual que TAB). **+La persistencia del OrdenUI es por plataforma** (un guardado de PC no pisa el de móvil) |