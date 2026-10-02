# HU-ESTETICA-12: Panel de Vendor — diseño de UI en Pencil ("como se vería en el juego")

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / EST-04 (diseño a fondo de pantallas)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Diseño de UI en Pencil (solo diseñador; **sin desarrollo, sin código**)
**Fase GDD:** EST (transversal; independiente de R8a–R8c)
**Depende de:** HU-ESTETICA-04 (dirección "Hearthbound Gold", componentes y tokens), HU-R5 (VendorService, oro, respec), HU-R5.2 (venta de 1 unidad), HU-R6.5 (oro en HUD), HU-ESTETICA-08 (respec del árbol de talentos)
**No modifica:** lógica del juego, VendorService, precios ni economía

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** ver las ventanas de los vendedores tal como se verían implementadas: catálogo con precios, mi oro, pestaña de venta y el instructor para reentrenar,
**para** comprar, vender y resetear mi build con confianza y sin sorpresas.

**Como** equipo de desarrollo,
**quiero** un diseño de pantalla completo y a fondo de los vendors,
**para** implementarlas sin reinterpretar nada y que el loop económico se entienda solo.

---

### **Descripción del Requerimiento / Contexto**

El diseño actual de las ventanas de vendor en `Vandrheim-design.pen` es **genérico** (un placeholder sin precios ni estados). Esta HU desarrolla las ventanas de vendor **a fondo**, con el aspecto final que tendrían en el juego, usando el sistema real:

* **3 NPCs reales (VendorConfig):**
  * **Vendedor de pociones** (`vendor_consumables`): vende poción HP y MP (10 oro c/u); **no compra** al jugador.
  * **Armero** (`vendor_gear`): vende armas y armaduras (espadas, escudos, sets Paladín/Cazador/Clérigo, varita, collar, anillo); **compra** al jugador.
  * **Instructor** (`vendor_trainer`): respec de talentos por **100 oro** (R5; conecta con HU-ESTETICA-08).
* **Precios por rareza (VendorConfig, reales):** compra: Common 20 · Uncommon 60 · Rare 200 · Epic 500; venta: 5 · 15 · 40 · 100.
* **Reglas:** vender descuenta **1 unidad** de la pila (R5.2); el oro del jugador se muestra (HUD R6.5); feedbaks "Oro insuficiente" y "Bolsa llena" (R5).

**Criterio de hecho global:** existen en el `.pen` las ventanas de los 3 vendedores completas y realistas — catálogo con precios reales, pestañas comprar/vender donde aplica, oro del jugador y feedbacks — listas para que el dev las implemente sin rediseñar.

---

### **Especificaciones Técnicas / Contratos de API (visual)**

#### **1. Ventanas a diseñar (frames nuevos en el `.pen`)**

**3 ventanas independientes — una por NPC** (cada NPC abre **solo su propia ventana**, como hoy; **no** es una sola ventana con pestañas entre vendedores). Cada una con su header propio: nombre del vendedor y **oro del jugador** siempre visible (ej. "340 oro"). Coherentes con Hearthbound Gold, `Scale` + `UIAspectRatioConstraint` en implementación:

* **Ventana del Vendedor de pociones** (`vendor_consumables`): catálogo simple (2 ítems: Poción de HP, Poción de MP) con precio (10 oro c/u), botón comprar; **sin pestaña vender** (no compra al jugador).
* **Ventana del Armero** (`vendor_gear`):
  * **Pestañas Comprar / Vender** (solo él compra y vende).
  * **Comprar:** grid de catálogo con icono real, nombre, rareza (marco) y **precio de compra**; estados: disponible, **sin oro suficiente** (gris), y hover con tooltip de ítem (stats/afijos/levelReq — mismo patrón que la mochila).
  * **Vender:** grid con los ítems de la **bolsa del jugador**, cada uno con su **precio de venta** (1 unidad, R5.2 — ej. pociones "x20 → 5 por unidad"); seleccionar ítem → botón/click para vender.
  * **Feedback:** "Oro insuficiente" (al comprar sin oro), "Bolsa llena" (al comprar sin espacio).
* **Ventana del Instructor** (`vendor_trainer`):
  * Ventana simple con el costo de reentrenar (**100 oro**) y botón "Reentrenar talentos" que muestra **advertencia de confirmación** (devuelve puntos y revoca skills de talento — conectado al respec de HU-ESTETICA-08, no duplicar el árbol).
* **Estados obligatorios:** catálogo con mezcla de precios/rarezas, un ítem en gris por falta de oro, feedback visible ("Oro insuficiente"), pestaña Vender con ítems de la bolsa y precios por unidad, e Instructor con su confirmación.

#### **2. Contenido real del mockup (obligatorio)**

Diseñar las ventanas con contenido **real** (precios de VendorConfig) para que se vean como en el juego:

* **Mockup principal: Armero — pestaña Comprar.** Jugador con **340 oro**. Catálogo (extracto real):

| Ítem | Rareza | Precio compra | Estado |
|------|--------|---------------|--------|
| Espada del aprendiz | Common | 20 | Disponible |
| Espada del caballero | Rare | 200 | Disponible |
| Espada del campeón | Epic | 500 | **Gris (oro insuficiente)** |
| Escudo del guardián | Uncommon | 60 | Disponible |
| Pecho del Cazador | Rare | 200 | Disponible |
| Guantes del Clérigo | Common | 20 | Disponible |
| Varita del Clérigo | Common | 20 | Disponible |
| Collar | Common | 20 | Disponible |
| Anillo | Common | 20 | Disponible |
| Poción de HP | — | 10 | Disponible (o en el vendedor de pociones) |

* **Escenario del mockup:** la Espada del campeón en gris con su precio tachado/atenuado, tooltip abierto sobre la Espada del caballero (Rare, afijos, nivel), y el oro del jugador (340) visible en el header.
* **Mockups adicionales dentro de la misma pantalla (estados):**
  * **Pestaña Vender** del Armero: bolsa del jugador con ítems y precios de venta (ej. Poción de HP x20 → 5 c/u, Espada del aprendiz → 5, Filo de la Escarcha → 100).
  * **Feedback "Oro insuficiente"** visible sobre un intento de compra.
  * **Vendedor de pociones** (catálogo simple sin pestaña vender).
  * **Instructor**: botón "Reentrenar talentos (100 oro)" + popup de confirmación con advertencia.

#### **3. Reglas**

* Trabajar en `Vandrheim-design.pen` en **frames propios de esta HU** (o pantallas nuevas dentro de `DX7OA`); no rehacer las pantallas existentes.
* Usar la paleta/tokens de EST-04 (fondos, latón `#C89445`, pergamino `#F4EDE0`, colores de rareza), tipografías Geist Mono / Playfair Display / Inter.
* Reutilizar y **mejorar** componentes exportables si hace falta (tooltip, botón 3 estados, panel 9-slice) — sin romper los existentes.
* Los precios y reglas son **reales** (VendorConfig); el diseñador no cambia economía.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: El Armero se ve implementado**

* **GIVEN** la ventana del Armero diseñada
* **WHEN** se mira la pestaña Comprar con el mockup (340 oro)
* **THEN** se ve el catálogo con precios reales por rareza, el oro del jugador y la Espada del campeón en gris (sin oro)

#### **Escenario 2: Compra y venta**

* **GIVEN** las pestañas Comprar/Vender
* **WHEN** se revisa la pestaña Vender
* **THEN** se ven los ítems de la bolsa con precio de **venta por unidad** (1 unidad, R5.2)
* **AND** el flujo comprar/vender se representa con su feedback

#### **Escenario 3: Feedbacks**

* **GIVEN** un intento de compra sin oro o con bolsa llena
* **WHEN** se revisa la ventana
* **THEN** se ven los mensajes "Oro insuficiente" y "Bolsa llena" representados
* **AND** no confunden al jugador

#### **Escenario 4: Vendedor de pociones (ventana propia)**

* **GIVEN** la ventana del Vendedor de pociones
* **WHEN** se mira su catálogo
* **THEN** vende Poción HP/MP a 10 oro y **no tiene pestaña de venta** (no compra al jugador)

#### **Escenario 5: Instructor (ventana propia)**

* **GIVEN** la ventana del Instructor
* **WHEN** se revisa el respec
* **THEN** muestra el costo real (100 oro) y una confirmación con advertencia
* **AND** no duplica el árbol de talentos (solo el acceso al respec, ver EST-08)

#### **Escenario 6: Ventanas separadas**

* **GIVEN** los 3 NPCs del hub (pociones, armero, instructor)
* **WHEN** se habla con cada uno
* **THEN** cada NPC abre **su propia ventana** (3 ventanas independientes, sin pestañas entre vendedores)
* **AND** el diseño las representa por separado

#### **Escenario 6: Fiel al sistema**

* **GIVEN** el diseño de los vendors
* **WHEN** se compara con VendorConfig y las reglas R5/R5.2
* **THEN** los precios, la venta por unidad y los 3 NPCs son fieles, sin inventar economía ni mecánicas

---

### **Comportamiento Visual / Reglas de Negocio**

* Es diseño puro: no define lógica, precios, oro ni balance.
* El oro del jugador siempre visible en la ventana del vendor.
* Los precios de compra/venta usan formato claro por rareza y por unidad (venta).
* Los estados sin oro se atenúan sin desaparecer (el jugador ve qué le falta).

---

### **Alcance**

#### Incluye

* Ventanas de los 3 vendedores en el `.pen` con contenido real (precios de VendorConfig).
* Armero: pestañas Comprar/Vender, catálogo con precios y rarezas, venta por unidad, feedbacks.
* Vendedor de pociones: catálogo simple sin pestaña vender.
* Instructor: respec (100 oro) + confirmación con advertencia (conectado a EST-08).
* Estados: sin oro, "Oro insuficiente", "Bolsa llena", pestaña vender, confirmación.
* Mejora de componentes exportables si es necesaria (tooltip, botones) sin romper los de EST-04.

#### No incluye

* Código, remotes, lógica de VendorService ni cambios a precios/economía (dev).
* Mecánicas inexistentes (subastas, trade, descuentos, stock rotativo).
* Cambios a las otras pantallas del `.pen` ni a la dirección aprobada.
* El árbol de talentos en sí (HU-ESTETICA-08), mochila (11), equipo/stats (10) ni grimorio (09) — HUs independientes.

---

### **Definition of Done (DoD)**

* [ ] **3 ventanas independientes** (una por NPC: pociones, armero, instructor), cada una con su header y oro del jugador — sin pestañas entre vendedores.
* [ ] Armero: pestañas Comprar/Vender (internas de su ventana), ítem sin oro en gris, tooltip, venta por unidad.
* [ ] Vendedor de pociones sin pestaña vender (fiel al config).
* [ ] Instructor: respec con costo real (100) y confirmación con advertencia.
* [ ] Feedbacks "Oro insuficiente" y "Bolsa llena" representados.
* [ ] Fiel a VendorConfig y R5/R5.2 sin inventar economía ni mecánicas.
* [ ] Paleta y componentes de Hearthbound Gold respetados.
* [ ] Reporte al PM con el detalle del diseño y pendientes.

---

### **Estimación (orientativa)**

1–2 sesiones del diseñador: ventanas de los 3 vendedores + estados + mockups con precios reales.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-15 | Creación de HU-ESTETICA-12: diseño a fondo de las ventanas de vendor (3 NPCs reales, precios por rareza, compra/venta por unidad, respec del instructor) — solo diseñador, sin desarrollo |
| 2026-09-15 | Aclaración de alcance: son **3 ventanas independientes, una por NPC** (pociones / armero / instructor) — no una sola ventana con pestañas entre vendedores |