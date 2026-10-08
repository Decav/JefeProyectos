# HU-ESTETICA-38: Panel de muerte — diseño de UI en Pencil

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / Death panel
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Diseño de UI en Pencil (solo diseñador; **sin desarrollo, sin código**)
**Fase GDD:** EST (transversal; complementa la HU dev `HU-R6.28-Limite-Resurrecciones-Panel-Muerte`)
**Depende de:** HU-R6.28 (funcionalidad: 3 revives por run, revive 50 Robux, abandonar), HU-ESTETICA-13 (tokens/paquete de UI), HU-ESTETICA-12 (patrón de ventana/vendor), HU-R6.27 (casillas fondo negro + borde hover)
**No modifica:** la lógica de muerte, respawn, compras ni gameplay

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** un panel de muerte claro y nórdico que muestre mis opciones al morir — cuántas resurrecciones me quedan, reaparecer, revivir con Robux o abandonar —,
**para** decidir rápido y sin confusión si sigo la run o me retiro conservando lo ganado.

**Como** equipo de desarrollo,
**quiero** el diseño del panel listo en Pencil,
**para** implementarlo sin reinterpretar nada.

---

### **Descripción del Requerimiento / Contexto**

`HU-R6.28` agrega el sistema de muerte: al morir en la dungeon se abre un panel con **Reaparecer** (3 gratis por run), **Revivir por 50 Robux** (cuando llegan a 0) y **Abandonar la run** (conservando lo ganado). Esta HU produce el **diseño visual** de ese panel en `Vandrheim-design.pen`, coherente con Hearthbound Gold (tokens EST-13) y el estándar de casillas (R6.27).

**Criterio de hecho global:** existe en el `.pen` el frame del panel de muerte con sus estados (con revives, sin revives con compra, confirmación de abandono) y variante móvil, listo para que el dev lo implemente en R6.28.

---

### **Especificaciones Técnicas / Contratos de API (visual)**

#### **Frame a diseñar: `HU-ESTETICA-38 — Death Panel`**

1. **Estado principal — "Has muerto":**
   * Título nórdico ("Has muerto" / runa de muerte), atmosférico pero legible.
   * **Contador de resurrecciones**: indicador visual (3 runas/gemas) que muestra cuántas quedan (ej. 2/3).
   * Botón **Reaparecer** (primario, latón) — habilitado si quedan resurrecciones, con label claro ("Reaparecer · Consume 1 de 3").
   * Botón **Abandonar la run** (secundario/rojo suave) — con aclaración "Conservas el oro y lo ganado del piso".
2. **Estado sin resurrecciones:**
   * Contador en 0/3 (gemas apagadas).
   * Botón **Revivir por 50 Robux** (destacado, con icono de moneda/R$ y el precio) — habilitado.
   * Botón **Abandonar la run** — disponible igualmente.
3. **Estado compra/feedback:**
   * Microcopia de "Reviviendo…" / error breve si la compra falla ("No se pudo completar la compra").
4. **Confirmación de Abandonar:**
   * Modal/overlay simple: "¿Abandonar la run? Esta acción no se puede deshacer. Conservarás lo ganado." con Confirmar / Volver.
5. **Variante móvil:** panel vertical adaptado (botones apilados, contador arriba), legible en touch.

#### **Reglas de diseño**

* Tokens Hearthbound Gold: fondo oscuro cálido `#15100D/#211916`, panel central con borde de madera `#6B4A2B`, casillas/fondo negro `#0E0D0C`, latón `#C89445` (botón principal), rojo suave `#C45345` para abandonar, pergamino `#F4EDE0` para texto; Geist Mono / Playfair Display / Inter.
* Iconos: runa de muerte (etiqueta), gema/runas para el contador y moneda Robux para el botón de revive.
* **Entrega de iconos (indicación PO 2026-09-22):** los iconos del panel se generan como **imágenes PNG** (estilo pintado del juego, fondo transparente, 512×512, legibles a 24 px) y se suben a Roblox — **no** como glifos vectoriales de Pencil. Indicaciones completas y naming en `ASSETS_LIST.md` (sección EST-38: `Icon_UI_death_death`, `Icon_UI_death_revive`, `Icon_UI_death_revive_off`, `Icon_UI_death_robux`); los ids van a `ReviveConfig`/`DeathPanelConfig`.
* Sin inventar mecánicas: solo los elementos de R6.28 (contador, reaparecer, comprar, abandonar).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Panel completo**

* **GIVEN** el frame `Death Panel` en el `.pen`.
* **WHEN** se observa.
* **THEN** se ven el título, el contador de resurrecciones y las opciones Reaparecer / (Revivir 50 Robux) / Abandonar.
* **AND** el lenguaje visual es coherente con EST-13/R6.27.

#### **Escenario 2: Contador claro**

* **GIVEN** el estado con resurrecciones.
* **WHEN** se mira el contador.
* **THEN** se entiende cuántas quedan sin leer números grandes (runas/gemas).
* **AND** el botón Reaparecer indica que consume una.

#### **Escenario 3: Sin resurrecciones**

* **GIVEN** el estado con 0/3.
* **WHEN** se revisa.
* **THEN** el botón de revive (50 Robux) es el protagonista y Abandonar sigue disponible.

#### **Escenario 4: Confirmación de abandono**

* **GIVEN** el usuario toca Abandonar.
* **WHEN** se ve el modal.
* **THEN** aclara que la run no se reanuda y que se conserva lo ganado, con Confirmar/Volver.

#### **Escenario 5: Móvil**

* **GIVEN** la variante móvil.
* **WHEN** se revisa.
* **THEN** el flujo vertical funciona y los botones son tocables sin amontonarse.

---

### **Comportamiento Visual / Reglas de Negocio**

* Diseño puro: no define lógica de muertes, contador, compra ni teleport (eso es R6.28).
* El panel refleja las 3 reglas: 3 revives por run, revive 50 Robux al agotar, abandonar conserva lo ganado.
* Sin timeout visual sugerido (el panel espera la decisión).

---

### **Alcance**

#### Incluye

* Frame `HU-ESTETICA-38 — Death Panel` (estado con revives, sin revives, feedback de compra, confirmación de abandono).
* Variante móvil.
* Mini iconos: runa de muerte, gema/runas del contador, moneda Robux (patrón EST-23/37).

#### No incluye

* Implementación en Roblox (el dev usa la HU-R6.28).
* Cambios a HUD, party frames ni otras pantallas.
* Lógica de compra, precios ni teleport.

---

### **Definition of Done (DoD)**

* [x] Existe el frame `HU-ESTETICA-38 — Death Panel` (`MDVTC`) en el `.pen`.
* [x] Estado con revives (2/3 + Reaparecer) y sin revives (0/3 + Revivir 50 Robux + Abandonar).
* [x] Confirmación de Abandonar con aclaración de que no se reanuda y se conserva lo ganado.
* [x] Feedback de compra: Reviviendo…, compra completada y error representados.
* [x] Variante móvil (`RSYEg`) con acciones apiladas y táctiles.
* [x] Mini iconos del panel entregados (runa, gemas, moneda) en el set `WNxnZ` y registrados en `ASSETS_LIST.md`.
* [x] Coherente con EST-13/R6.27; revisión visual y bounds sin recortes.
* [x] El dev puede implementar R6.28 con los estados y textos visuales definidos, sin reinterpretar.
* [x] Reporte al PM con el detalle del diseño y pendientes (`HU-ESTETICA-38-REPORTE-PM.md`).

---

### **Decisiones por defecto EST-38**

| Tema | Default |
|------|---------|
| Estados | Con revives · Sin revives (compra) · Feedback de compra · Confirmación abandonar |
| Contador | Runas/gemas 3 (X/3) |
| Botón principal | Reaparecer (latón) / Revivir 50 Robux (destacado con moneda) |
| Abandonar | Secundario rojo suave + aclaración "conservas lo ganado" |
| Estilo | Tokens EST-13 + casillas R6.27 |
| Móvil | Panel vertical apilado |

---

### **Estimación (orientativa)**

1 sesión del diseñador: panel + estados + confirmación + variante móvil + mini iconos.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-ESTETICA-38: diseño en Pencil del panel de muerte (contador 3/revive 50 Robux/abandonar + confirmación + móvil) — complementa la HU dev R6.28 |
| 2026-09-22 | Diseño entregado: frames `MDVTC` (estados escritorio), `RSYEg` (móvil) y `WNxnZ` (iconos muerte/gema/Robux); `ASSETS_LIST.md` actualizado y reporte PM creado. Capturas y bounds revisados; sin lógica ni comportamiento implementados |