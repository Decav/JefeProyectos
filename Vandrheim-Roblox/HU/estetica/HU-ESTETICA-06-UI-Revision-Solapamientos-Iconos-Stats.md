# HU-ESTETICA-06: Revisión del diseño de UI — solapamientos, iconos de mini-menú y panel de stats

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / EST-04
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Revisión del diseño visual en Pencil (diseñador, sin código ni assets 3D)
**Fase GDD:** EST-04 (revisión de la entrega del diseñador; no cambia reglas de juego)
**Depende de:** HU-ESTETICA-04 (dirección "Hearthbound Gold" aprobada, 12 pantallas)
**Componentes observados:** `Vandrheim-design.pen` → frame `DX7OA` ("EST-04 — Hearthbound Gold UI System"), pantallas 01 HUD (`UqfGV`), 02 Mochila (`Eymvh`), 03 Equipo (`Gxz0C`), 07 Menú ESC (`OwhrM`), 12 Mobile HUD (`Li2yr`)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** una interfaz sin elementos superpuestos, con iconos en el mini-menú y una sección de equipo/stats clara y moderna,
**para** entender mi personaje y navegar las ventanas sin confusión y con mejor aspecto visual.

**Como** usuario/equipo,
**quiero** que la UI se sienta más moderna, llamativa e intuitiva manteniendo la dirección Hearthbound Gold,
**para** elevar la calidad percibida del juego sin rehacer el sistema visual aprobado.

---

### **Descripción del Requerimiento / Contexto**

El usuario revisó el diseño de EST-04 y reportó tres problemas y un pedido general:

1. **Faltan iconos en el mini-menú** (botones del menú ESC y botón del menú táctil).
2. **Contenido superpuesto** en los estados del menú ESC, la mochila (nota de rareza sobre la última fila) y las notas del board.
3. **La sección Equipo/stats no gusta** — el texto plano de stats debe convertirse en un panel estructurado y legible.
4. **General:** la UI debe verse más moderna, llamativa e intuitiva.

Como base, el PM ya aplicó correcciones verificadas por bounds (detalle en "Estado base"): el diseñador debe **revisarlas y pulirlas con su criterio** (mantener, mejorar o rehacer), no partir de cero.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Estado base (cambios aplicados, a revisar/pulir)**

| Punto | Nodo(s) | Corrección aplicada |
|-------|---------|---------------------|
| Crosshair pisaba skill 3 del HUD | `mfDKs`, `He95E` | Crosshair movido a (196, 78) |
| Nota de rareza sobre la última fila de la mochila | `XqtUe` | Movida a y=222 |
| Nota ESC sobre los estados del menú | `Z8xVx`, `i6Btji`, `XZbfx` | Movida a y=214 |
| Notas del board sobre variante móvil y componentes | `I2qc7`, `q1ip2q`, `Li2yr`, `QqzaW` | Notas a y=1580/1605; board `DX7OA` altura 1800 |
| Iconos del mini-menú (base) | `TdOqP` (play), `qd9Lj` (users), `E1f4H8` (settings) en `OwhrM`; `uNjfz` (menu) en `Li2yr` | Insertados; labels corridos a x=58 |
| Panel de stats del equipo (base) | `du1mx` + filas `D1TDka` (HP), `iiuWr` (MP), `Fi4o6` (ATK), `F05VB` (MATK), `Ny5va` (DEF), `Et7Uq` (MDEF), `W2Z7M` (CRIT) en `Gxz0C` | Panel con header "STATS", divisor y 7 filas (icono + label + valor) |

#### **2. Tareas del diseñador**

* Verificar visualmente los solapamientos corregidos y que el panel de stats no pise los gear slots (terminan en x≈270).
* Ajustar el estilo de los iconos del mini-menú (tamaño, color, alineación con el label) y cubrir los estados **hover/disabled con sus iconos** (hoy solo están los labels de estado). Mismo criterio para el menú táctil.
* Rediseñar el panel de stats del equipo con estilo moderno, llamativo y con jerarquía clara, usando acentos de la paleta (latón `#C89445`, pergamino `#F4EDE0`). Se puede usar la base actual o rehacerlo.
* Pasada general de modernización de las 12 pantallas (HUD, mochila, talentos, menú, mobile HUD, etc.) sin romper coherencia Hearthbound Gold ni los componentes exportables (9-slice, botones 3 estados).

#### **3. Reglas**

* Trabajar solo dentro del frame `DX7OA`; no tocar las otras direcciones ni frames ajenos.
* No tocar código, scripts ni assets 3D (dominio del dev).
* Paleta y tipografías de Hearthbound Gold: pergamino `#F4EDE0`, latón `#C89445`, madera `#6B4A2B`, frío `#8FB7D6`, fondos `#15100D`/`#241B16`/`#211916`/`#0E0D0C`; Geist Mono / Playfair Display / Inter.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Sin solapamientos**

* **GIVEN** las 12 pantallas del frame `DX7OA`
* **WHEN** se revisa el layout pantalla por pantalla (visual y por bounds)
* **THEN** no hay elementos superpuestos no intencionales
* **AND** fill/inset dentro de su contenedor (barras, insets, labels en botones) no cuenta como solapamiento

#### **Escenario 2: Iconos del mini-menú**

* **GIVEN** el menú ESC y el menú táctil
* **WHEN** se revisan los botones en todos sus estados (normal/hover/disabled)
* **THEN** cada botón tiene icono + label alineados y coherentes
* **AND** los estados hover/disabled incluyen los iconos

#### **Escenario 3: Panel de stats del equipo**

* **GIVEN** la pantalla 03 Equipo
* **WHEN** se abre la sección de stats
* **THEN** las stats (HP, MP, ATK, MATK, DEF, MDEF, CRIT) se muestran en un panel estructurado con jerarquía clara
* **AND** el estilo es moderno/llamativo y coherente con Hearthbound Gold

#### **Escenario 4: Modernización general**

* **GIVEN** las 12 pantallas del diseño
* **WHEN** se revisa el conjunto con ojo de diseñador
* **THEN** la UI se percibe más moderna, llamativa e intuitiva que la versión anterior
* **AND** la dirección Hearthbound Gold y los componentes exportables se mantienen

---

### **Comportamiento Visual / Reglas de Negocio**

* Los iconos del mini-menú siguen la paleta (latón sobre fondos oscuros; pergamino en zonas claras).
* El panel de stats es solo presentación: no cambia stats, inventario ni progresión.
* Los estados de los botones se conservan como componentes exportables para el dev.

---

### **Alcance**

#### Incluye

* Corrección/pulido de los solapamientos listados en el estado base.
* Iconos en el mini-menú (ESC + táctil) con estados completos.
* Rediseño del panel de stats del equipo.
* Pasada de modernización de las 12 pantallas dentro de `DX7OA`.
* Reporte al PM de qué se cambió, qué se rediseñó y qué quedó pendiente.

#### No incluye

* Cambios a las otras direcciones de diseño ni frames ajenos.
* Código, scripts ni assets 3D (dev).
* Cambios a reglas de juego, stats ni balance.
* Cambios a HU-ESTETICA-04 (solo se actualiza si el rediseño altera pantallas/componentes entregables).

---

### **Definition of Done (DoD)**

* [ ] Sin solapamientos reales en las 12 pantallas (verificado visual y por bounds).
* [ ] Mini-menú con iconos + labels en todos los estados (normal/hover/disabled).
* [ ] Panel de stats del equipo rediseñado y aprobado por el usuario.
* [ ] Paleta/tipografías Hearthbound Gold respetadas.
* [ ] Componentes exportables intactos o mejorados.
* [ ] Reporte al PM con el detalle de cambios y pendientes.

---

### **Estimación (orientativa)**

1 sesión del diseñador: pulido de solapamientos + iconos + rediseño de stats + pasada de modernización.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-26 | Creación de HU-ESTETICA-06: revisión del diseño de UI (solapamientos, iconos de mini-menú, panel de stats, modernización general) |