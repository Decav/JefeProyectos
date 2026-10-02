# HU-ESTETICA-15: Reskin de las ventanas de Vendor en Roblox (dev) — 3 ventanas independientes

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / Implementación (subconjunto de HU-ESTETICA-14)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Implementación de UI en Roblox Studio (dev)
**Fase GDD:** EST (transversal; ventana por ventana)
**Depende de:** HU-ESTETICA-12 (diseño de vendors en Pencil), HU-ESTETICA-13 (paquete de specs/assets), HU-ESTETICA-14 (reskin general — esta HU ejecuta la parte de vendors), HU-R5 (VendorService, oro), HU-R5.2 (venta de 1 unidad), ASSETS_POLICY/ASSETS_LIST
**Componentes observados:** `StarterGui.VendorUI` (ventana actual R5), `ServerScriptService.Services.VendorService`, `ReplicatedStorage.Config.VendorConfig` (3 vendors, precios por rareza, respecCost 100), `ReplicatedStorage.Assets.Icons`

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que las ventanas de los vendedores se vean con el nuevo estilo Hearthbound Gold, cada NPC con **su propia ventana** (pociones, armero, instructor),
**para** comprar, vender y reentrenar con una interfaz clara, moderna y sin confusión entre vendedores.

**Como** desarrollador,
**quiero** implementar el reskin de las 3 ventanas de vendor usando como referencia el frame de vendors del diseño de Pencil y el paquete de `HU-ESTETICA-13`,
**para** reemplazar el estilo actual **sin tocar la lógica** (VendorService, precios, venta por unidad, oro).

---

### **Descripción del Requerimiento / Contexto**

El diseñador entregó en `Vandrheim-design.pen` el diseño final de los vendors: **3 ventanas independientes, una por NPC** (no una sola ventana para los 3). El dev implementa el reskin de cada ventana sobre la `VendorUI` existente (R5), conservando la jerarquía y nombres que los scripts usan, y sin cambiar ninguna regla del vendor.

**Criterio de hecho global:** los 3 NPCs abren cada uno su ventana rediseñada (fiel al frame del diseño), con precios y flujos reales funcionando, en PC y móvil.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Referencia visual (frames del diseño)**

* **Frame principal:** `BFPNI` — "HU-ESTETICA-12 — Three Independent Vendor Windows" (dentro de `Vandrheim-design.pen`; 1330×840 en el board).
* Contiene **3 ventanas**, cada una con su layout propio:
  * `ajlcF` — **Window vendor consumables** (370×620): Vendedor de pociones.
  * `w2ajX7` — **Window vendor gear** (550×620): Armero (la más ancha: catálogo + pestañas).
  * `mN5Oa` — **Window vendor trainer** (322×620): Instructor.
* La pantalla genérica anterior `R1p9JV` ("06 Vendor") queda **obsoleta** como referencia; no se usa para implementar.

#### **2. 3 ventanas independientes (regla dura)**

* Cada NPC abre **solo su ventana** (`vendor_consumables`, `vendor_gear`, `vendor_trainer` de `VendorConfig`).
* **No** se implementa una sola ventana con pestañas entre vendedores.
* Las pestañas **Comprar/Vender existen solo dentro de la ventana del Armero** (único que compra y vende).

#### **3. Reskin por ventana**

| Ventana | NPC (VendorConfig) | Contenido a implementar |
|---------|--------------------|--------------------------|
| **Consumibles** | `vendor_consumables` "Vendedor de pociones" | Catálogo de Poción HP y Poción MP (precio 10 oro c/u), botón comprar; **sin pestaña vender** (no compra al jugador) |
| **Armero** | `vendor_gear` "Armero" | Pestañas **Comprar / Vender**; Comprar: catálogo con iconos, rarezas y precios por rareza (20/60/200/500); Vender: ítems de la bolsa con precio de **venta por unidad** (5/15/40/100) |
| **Instructor** | `vendor_trainer` "Instructor" | Botón "Reentrenar talentos" con costo (**100 oro**, `respecCost`) y **popup de confirmación** con advertencia (devuelve puntos y revoca skills de talento); **no** duplica el árbol de talentos (solo el acceso al respec) |

* **Común a las 3:** header con nombre del vendedor y **oro del jugador** siempre visible; estilos de `HU-ESTETICA-13` (paleta, radios, bordes, espaciados, escala tipográfica); fuentes mapeadas (PlayfairDisplay/Inter/RobotoMono, confirmar `Font` enum); paneles `ImageLabel` con `ScaleType.Slice` (9-slice del paquete); botones `ImageButton` con 3 estados (normal/hover/disabled); pestaña activa diferenciada.
* **Estados obligatorios:** ítem **sin oro suficiente** (gris/atenuado, no desaparece); feedbacks **"Oro insuficiente"** y **"Bolsa llena"** (flujo R5); hover con tooltip de ítem (stats/afijos/levelReq — patrón R4/mochila); confirmación del instructor.
* **Iconos:** los ítems del catálogo usan sus `iconId` reales; los que falten se suben al Asset Server (estándar ASSETS_LIST, fondo negro = finales) y se registran en `ASSETS_REGISTRY`.
* **Mobile:** `UIScale` + `UIAspectRatioConstraint` + zona segura (`GetSafeAreaInsets`); botones táctiles legibles.
* **Animaciones:** TweenService según EST-13 (abrir/cerrar fade+scale 0.15–0.25 s, hover 0.1 s, popup de confirmación con Back corto).

#### **4. Lógica intacta (reglas duras)**

* No se modifica `VendorService`, `VendorConfig` (precios, catálogo, `respecCost`), ni los remotes de compra/venta/respec.
* Venta de **1 unidad** (R5.2) y validaciones anti-exploit existentes se conservan.
* Se conservan los nombres de instancias y la jerarquía de la `VendorUI` actual que los scripts referencian.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Una ventana por NPC**

* **GIVEN** los 3 NPCs del hub
* **WHEN** se habla con cada uno
* **THEN** cada uno abre **su propia ventana** (consumibles / armero / instructor)
* **AND** no existe una ventana única con pestañas entre vendedores

#### **Escenario 2: Vendedor de pociones**

* **GIVEN** la ventana del Vendedor de pociones
* **WHEN** se compara con el frame `ajlcF` del diseño
* **THEN** el catálogo muestra Poción HP y MP a 10 oro
* **AND** no tiene pestaña vender (no compra al jugador)

#### **Escenario 3: Armero con Comprar/Vender**

* **GIVEN** la ventana del Armero
* **WHEN** se compara con el frame `w2ajX7`
* **THEN** tiene pestañas Comprar/Vender, precios por rareza reales y venta por unidad
* **AND** un ítem sin oro se ve atenuado con su precio

#### **Escenario 4: Instructor**

* **GIVEN** la ventana del Instructor
* **WHEN** se compara con el frame `mN5Oa`
* **THEN** muestra el respec con costo real (100 oro) y confirmación con advertencia
* **AND** no abre ni duplica el árbol de talentos

#### **Escenario 5: Estados y feedbacks**

* **GIVEN** compras con falta de oro o bolsa llena
* **WHEN** se revisa la ventana
* **THEN** se ven "Oro insuficiente" y "Bolsa llena" como en el diseño
* **AND** el oro del jugador se muestra y actualiza en el header

#### **Escenario 6: Móvil y regresión**

* **GIVEN** un dispositivo táctil
* **WHEN** se usa el vendor
* **THEN** la ventana escala y respeta la zona segura
* **AND** el flujo comprar → vender → respec → rejoin no produce errores rojos

#### **Escenario 7: Anti-exploit**

* **GIVEN** un cliente intenta comprar sin oro, vender ítems ajenos o respec sin pago
* **WHEN** envía los remotes manipulados
* **THEN** el servidor rechaza (lógica existente intacta)

---

### **Comportamiento Visual / Reglas de Negocio**

* El frame `BFPNI` del `.pen` es la **referencia visual**; los specs de EST-13 son la **verdad de implementación**.
* Las 3 ventanas comparten sistema visual pero son **ventanas distintas** (una por NPC).
* Precios, catálogo y reglas de venta salen de `VendorConfig`; el dev no inventa economía.

---

### **Alcance**

#### Incluye

* Reskin de las 3 ventanas de vendor (consumibles, armero, instructor) sobre la `VendorUI` existente.
* Pestañas Comprar/Vender solo en el Armero; venta por unidad; feedbacks; confirmación de respec.
* Fuentes mapeadas, 9-slice, botones 3 estados, iconos (subida + ASSETS_REGISTRY), animaciones Tween y safe area móvil.

#### No incluye

* Lógica de `VendorService`, precios, catálogo ni economía (intactos).
* El árbol de talentos (HU-ESTETICA-08/14) — aquí solo el acceso al respec del instructor.
* Las demás ventanas del reskin (mochila, equipo, HUD, etc. — HU-ESTETICA-14).
* Diseño en Pencil (diseñador — HU-ESTETICA-12 ya entregada).

---

### **Definition of Done (DoD)**

* [ ] Los 3 NPCs abren cada uno su ventana rediseñada (fiel a `BFPNI`/`ajlcF`/`w2ajX7`/`mN5Oa`).
* [ ] Consumibles: pociones a 10 oro, sin pestaña vender.
* [ ] Armero: pestañas Comprar/Vender, precios por rareza reales, venta por unidad, ítem sin oro atenuado.
* [ ] Instructor: respec 100 oro + confirmación con advertencia (sin duplicar el árbol).
* [ ] Feedbacks "Oro insuficiente" y "Bolsa llena"; oro del jugador en el header.
* [ ] Fuentes mapeadas, 9-slice, botones 3 estados, iconos registrados.
* [ ] Animaciones TweenService y safe area móvil aplicadas.
* [ ] Sin errores rojos en comprar → vender → respec → rejoin (PC y móvil).
* [ ] `VendorService`/`VendorConfig`/remotes intactos; anti-exploit vigente.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Al cerrar: PROJECT_ARCHITECTURE, DATA_SCHEMA y registro HU/RC actualizados; nota en GDD después de QA.

---

### **Decisiones por defecto EST-15**

| Tema | Default |
|------|---------|
| Referencia visual | Frame `BFPNI` ("Three Independent Vendor Windows") + `ajlcF`/`w2ajX7`/`mN5Oa` |
| Ventanas | 3 independientes (una por NPC); pestañas Comprar/Vender solo en el Armero |
| Fuentes | PlayfairDisplay / Inter / RobotoMono (mapa EST-13) |
| Animaciones | Abrir/cerrar fade+scale 0.15–0.25 s; hover 0.1 s; popup respec Back corto |
| Lógica | `VendorService`/`VendorConfig`/remotes intactos |

---

### **Estimación (orientativa)**

1–2 sesiones del dev: reskin de las 3 ventanas + estados + mobile + regresión de vendor.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-15 | Creación de HU-ESTETICA-15: reskin de las ventanas de vendor (dev) — 3 ventanas independientes (consumibles/armero/instructor), referenciando el frame `BFPNI` del diseño y el paquete EST-13; sin tocar lógica ni precios |