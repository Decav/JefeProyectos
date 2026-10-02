# HU-ESTETICA-27: Integración del pueblo completo y NPCs vendedores en el hub principal (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / Mundo / Hub — Integración (dev)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Integración de assets del diseñador en el flujo principal (dev)
**Fase GDD:** EST (transversal; cierra el hub)
**Depende de:** HU-ESTETICA-26 (pueblo completo, **aprobado por PO 2026-09-22**), diseño de los 3 NPCs vendedores (diseñador, `Workspace.TestPlace.HU26_Village_Procedural.NPC_Designs`), HU-R5 (vendors/prompts), HU-R6b (portal), HU-R1 (dummy), HU-R6.14 (interacción móvil táctil), HU-PUBLICAR-04 (sync de places por copia derivada)
**Componentes observados:** `Workspace.Hub` (estructuras actuales, `vendor_*`, `PortalFrame`/`PortalMarker`, `TrainingDummy`, spawn), `ReplicatedStorage.Config.VendorConfig` (nombres/displayNames), ASSETS_REGISTRY

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** ver el pueblo nuevo con los vendedores (Armero, Alquimista, Entrenador) funcionando en sus casas,
**para** que el hub se sienta vivo y el flujo del juego pase por el asentamiento real.

**Como** equipo de desarrollo,
**quiero** integrar el pueblo y los NPCs del diseñador en el hub principal **sin romper** los flujos existentes (vendors, portal, dummy),
**para** cerrar el hub con la estética aprobada.

---

### **Descripción del Requerimiento / Contexto**

El diseñador entregó:
* **Pueblo completo** (HU-ESTETICA-26): 5 casas sin interior + 3 con interior (para los NPCs comerciales), murallas con portón, plaza central, casa comunal cerrada y decoraciones — **aprobado por el PO**.
* **3 NPCs vendedores** (prototipos R15 estándar, bajo `Workspace.TestPlace.HU26_Village_Procedural.NPC_Designs`):
  * **Armero** — delantal de cuero + martillo (→ `vendor_gear`).
  * **Alquimista** — túnica verde + frascos (→ `vendor_consumables`).
  * **Entrenador de clases** — tabardo azul + espada de práctica (→ `vendor_trainer`).
  * Son **prototipos visuales estáticos**: con `Humanoid`, sin animación, diálogos ni lógica. **El diseñador no guardó el place.**

**Criterio de hecho global:** el hub principal tiene el pueblo nuevo con los 3 vendedores en sus casas (detrás de sus mostradores) funcionando con el flujo R5 (abren sus ventanas, PC y móvil), el portal teleporta, el dummy recibe daño y no hay regresiones.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Dependencia de entrega (antes de arrancar)**

* **El diseñador debe guardar/exportar el place** con el pueblo y los NPCs (no guardó): el dev necesita el archivo del place (o los modelos exportados). **Coordinación previa**: PM/PO pide al diseñador el save antes de que el dev comience.

#### **2. Integrar el pueblo en `Workspace.Hub`**

* Reemplazar las estructuras actuales del hub por el **pueblo nuevo** (EST-26).
* **Conservar y reubicar sin romper** las instancias funcionales:
  * `vendor_consumables`, `vendor_gear`, `vendor_trainer` (con `Humanoid` + `ProximityPrompt`).
  * `PortalFrame`/`PortalMarker` + `PortalPrompt`.
  * `TrainingDummy`.
  * Spawn del jugador y caminos navegables (sin trampas).

#### **3. NPCs vendedores (usar los modelos del diseñador)**

* Ubicar los 3 NPCs **detrás de sus mostradores** en las casas con interior correspondientes:
  * Armero → casa del `vendor_gear`.
  * Alquimista → casa del `vendor_consumables`.
  * Entrenador de clases → casa del `vendor_trainer`.
* **Nombres de instancia:** conservar los que los scripts usan (`vendor_*`); los **nombres visibles** se actualizan en `VendorConfig` (config, sin tocar código): "Vendedor de pociones" → **"Alquimista"**, "Instructor" → **"Entrenador de clases"** (decisión PM: se adoptan los nombres del diseñador).
* Agregar al `Humanoid` de cada NPC su `ProximityPrompt` (el mismo flujo R5) y verificar que la **interacción táctil** funciona (R6.14: botón táctil en móvil).
* Sin animación, diálogos ni lógica nueva (prototipos); si se quiere animación idle después, es otra HU.
* Registrar los modelos/rigs en `ASSETS_REGISTRY` (fuente: diseñador).

#### **4. Verificación del hub completo**

* Los 3 vendedores abren sus ventanas (pociones / armero con Comprar+Vender / entrenador con respec).
* Portal teleporta (flujo R6b/PUBLICAR-02 intacto).
* Dummy recibe daño.
* Interiores navegables; navegación fluida sin trampas; cámara sin clipping grave.
* Móvil: prompts táctiles, UI compacta (ambos en **HU-R6.14 — Bugfixes batch 1**), sin romper joystick.
* **Sync places (PUBLICAR-04):** el pueblo NO va a la dungeon (excluido por compilación derivada); los NPCs/configs compartidos que la dungeon use se actualizan con la copia derivada al publicar.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Pueblo integrado**

* **GIVEN** el hub actualizado
* **WHEN** se recorre
* **THEN** el pueblo nuevo está en `Workspace.Hub` (5+3 casas, murallas, plaza, casa comunal) y se ve como el diseño aprobado

#### **Escenario 2: Vendedores funcionales**

* **GIVEN** los 3 NPCs ubicados en sus casas
* **WHEN** el jugador interactúa (PC: `E`/click; móvil: botón táctil)
* **THEN** cada uno abre su ventana (pociones / armero / entrenador-respec)
* **AND** los nombres visibles son los del diseñador (Alquimista, Armero, Entrenador de clases) vía `VendorConfig`

#### **Escenario 3: Portal y dummy**

* **GIVEN** el hub integrado
* **WHEN** se usa el portal y se golpea al dummy
* **THEN** el portal teleporta a la dungeon y el dummy recibe daño (sin regresión)

#### **Escenario 4: Navegación y móvil**

* **GIVEN** el pueblo completo
* **WHEN** se juega en PC y móvil
* **THEN** no hay trampas de navegación, la cámara no clipea grave, y los prompts funcionan con toque

#### **Escenario 5: Registro y docs**

* **GIVEN** la integración
* **WHEN** se revisa ASSETS_REGISTRY y los configs
* **THEN** los NPCs/modelos están registrados y `VendorConfig` tiene los displayNames nuevos

#### **Escenario 6: Sin regresión**

* **GIVEN** la integración completa
* **WHEN** se juega el flujo completo (pueblo → vendors → portal → dungeon → vuelta, publicado)
* **THEN** no hay errores rojos y todo lo existente funciona

---

### **Alcance**

#### Incluye

* Integración del pueblo nuevo en `Workspace.Hub` (reemplazo de estructuras).
* Ubicación de los 3 NPCs en sus casas con `ProximityPrompt` + `VendorConfig` displayNames.
* Conservación de portal/dummy/spawn y navegación.
* Registro en ASSETS_REGISTRY y verificación publicada.

#### No incluye

* Animaciones/diálogos/lógica de los NPCs (prototipos).
* Cambios a gameplay, balance ni reglas.
* Contenido de la casa comunal (cerrada).
* El pueblo en la dungeon (excluido por compilación derivada, PUBLICAR-04).

---

### **Definition of Done (DoD)**

* [ ] Pueblo nuevo en `Workspace.Hub` (aprobado) con portal/dummy/spawn conservados.
* [ ] Los 3 NPCs en sus casas, detrás de sus mostradores, con prompt funcional (PC y móvil).
* [ ] `VendorConfig` con los displayNames nuevos (config, sin tocar código).
* [ ] Ventanas de vendors, portal y dummy sin regresión.
* [ ] Navegación fluida y cámara sin clipping grave.
* [ ] ASSETS_REGISTRY actualizado.
* [ ] Flujo completo publicado sin errores rojos.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Decisiones por defecto EST-27**

| Tema | Default |
|------|---------|
| Nombres visibles | Se adoptan los del diseñador: **Alquimista**, **Armero**, **Entrenador de clases** (vía `VendorConfig`) |
| Instancias | Nombres que los scripts usan conservados (`vendor_*`) |
| NPCs | Prototipos estáticos (sin animación/lógica); prompts + Humanoid |
| Entrega | El diseñador debe guardar/exportar el place antes de que el dev arranque |
| Sync | Pueblo no va a la dungeon (copia derivada PUBLICAR-04) |

---

### **Estimación (orientativa)**

2–3 sesiones del dev: integración del pueblo + NPCs + prompts + configs + verificación publicada.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-ESTETICA-27: integración del pueblo completo (EST-26, aprobado) y los 3 NPCs vendedores del diseñador en el hub — ubicación en casas, prompts (PC/móvil), displayNames en VendorConfig y sin regresión de portal/dummy |