# HU-ESTETICA-47: Reskin de PlayerFrame, TargetFrame y PartyFrame (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / HUD de combate — Reskin (dev)
**Prioridad:** Alta
**Estado:** Lista para implementar (RC obligatorio del dev antes de programar)
**Tipo:** Reskin de UI (dev) — solo visual, sin tocar lógica
**Fase GDD:** UI (sustituye los visuales de player frame R8c, target frame R3.x y party frame R9a/EST-22)
**Depende de:** frames del `.pen` (componentes reusables, aprobados por PO): **`YDdLZ` — "PlayerFrame · Paladín" (374×135)** · **`AKFQh` — "TargetFrame · Jotunn" (374×132)** · **`cGcxE` — "PartyFrame · Simplificado" (320×182)**, HU-ESTETICA-13 (tokens/handoff), HU-R6.26 (party en tiempo real + colores), HU-R3.1/R3.3 (targeting + indicador), HU-R9a (party), HU-R7.1 (casteos del Jotunn: avalancha/rugido para la cast bar), R6.20 (escala/OrdenUI)
**No modifica:** targeting, party, HP/MP server-authoritative ni lógica (R3.x/R9a/R8c intactos)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** los 3 frames de combate rediseñados (mi vida/maná, el objetivo con su casteo y el party simplificado),
**para** leer el combate de un vistazo con el mismo lenguaje visual del resto del juego.

---

### **Descripción del Requerimiento / Contexto**

El diseñador entregó los 3 frames de combate como **componentes reusables** (aprobados por el PO). El dev reskinea player frame, target frame y party frame sobre esos diseños, **conservando nombres de instancias y lógica** (contrato EST-13).

**Criterio de hecho global:** los 3 frames se ven como sus diseños (retrato, barras con % y valores, cast bar, filas del party) — con datos reales en vivo y sin romper targeting, party ni HP/MP.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. PlayerFrame · Paladín (`YDdLZ`, 374×135)**

* Fondo `#211916`; **medallón de retrato** (`#3A2C25` + retrato IMAGE de la clase — hasta que exista el asset de retrato: placeholder del personaje).
* **Nombre** (fs 16 bold pergamino) + **nivel** (fs 13 bold dorado `#C89445`) — datos reales del PJ.
* **HP**: track `#0E0D0C` + fill **verde `#5E9F3D`** (vida propia/aliada — coherente con R6.26), **% ** (fs 12 bold blanco) + **valor** (fs 12 bold blanco, ej. "4.8k").
* **MP**: track `#0E0D0C` + fill **azul `#2477C6`**, % (fs 11) + valor (fs 11), blancos.

#### **2. TargetFrame · Jotunn (`AKFQh`, 374×132)**

* Mismo formato que el player (medallón + retrato del enemigo + nombre fs 16 + fondo `#211916`).
* **Retratos reales (ASSETS_LIST, subidos 2026-09-22):** Jotunn → `rbxassetid://112251764292750` · Señor de la Escarcha → `rbxassetid://105086910359542` · resto de enemigos → genérico `rbxassetid://99954963258644`. El medallón del player sigue con placeholder hasta el asset de retrato por clase.
* **HP rojo `#B84E5B`** (coherente con R6.26: rojo = enemigos) con valor (fs 12 blanco) + % en barra (fs 12 blanco) y **nivel/% dorado** (fs 13 `#C89445`).
* **Cast bar** (track `#3F3328` + fill dorado `#C89445`): muestra el **casteo en curso** con su **label real** (fs 8 bold pergamino — ej. "AVALANCHA FRONTAL" de R7.1); **oculta cuando no hay casteo** (telegraphs R6.18/R7.1).
* **Type label** (fs 8 bold, color por tipo — "JEFE" en `#D68A78` salmón): tipo del target (`EnemyConfig`: JEFE/ÉLITE/normal — normal sin label o con su tier).

#### **3. PartyFrame · Simplificado (`cGcxE`, 320×182)**

* Fondo `#15100D`; **una fila por miembro** (`#211916`): **icono de clase** (IMAGE — iconos de clase EST-24 cuando existan; placeholder mientras tanto) + **nombre** (fs 10 bold pergamino) + línea **"CLASE · NIV X"** (fs 7.5 `#B5A79A` — ej. "PALADÍN · NIV 16").
* **HP**: track `#402126` + fill **verde `#5E9F3D`** + valor **"actual / máx"** (fs 7 bold blanco, ej. "8.4k / 9.1k").
* **SIN spec** (decisión PO 2026-09-22, diseño aprobado — **enmienda R6.26**: la línea es clase+nivel, no "Clase - Spec").
* **SOLO HP, sin barra de MP** (decisión PO 2026-09-22 — simplificado confirmado).
* **Tiempo real** intacto (R6.26: nivel/HP/estado event-driven; verde para aliados).
* **Estados**: miembro caído (gris + "CAÍDO" — patrón R9a/EST-22); líder con badge corona si aplica (patrón EST-22).

#### **4. Reglas**

* **Conservar los nombres de instancias/jerarquía que los scripts usan** (contrato EST-13).
* Mismos contratos de targeting (R3.x), party (R9a) y HP/MP (server-authoritative) — sin cambios de lógica.
* Móvil: escala/touch (R6.20), sin romper y con fuentes legibles (R6.27).
* OrdenUI/escala de R6.20 donde aplique (party frame incluido).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Reskin fiel ×3**

* **GIVEN** los 3 frames reskineados
* **WHEN** se comparan con `YDdLZ`, `AKFQh` y `cGcxE`
* **THEN** replican retrato/medallón, barras con %/valores, cast bar, filas del party (colores/fuentes del diseño)

#### **Escenario 2: Datos reales**

* **GIVEN** los frames
* **WHEN** se juega
* **THEN** nombre/nivel/HP/MP del player, HP/nivel del target y miembros del party salen del servidor (en vivo)

#### **Escenario 3: Cast bar**

* **GIVEN** el Jotunn (u otro enemigo) casteando
* **WHEN** hay un casteo en curso (avalancha, rugido…)
* **THEN** la cast bar aparece con el **label real del casteo**; sin casteo, oculta

#### **Escenario 4: Type label**

* **GIVEN** un target jefe/élite/normal
* **WHEN** se selecciona
* **THEN** el label muestra su tipo ("JEFE" en `#D68A78`; élite/normal según color por tipo)

#### **Escenario 5: Party simplificado**

* **GIVEN** un party de 2–4
* **WHEN** se revisa el frame
* **THEN** cada fila muestra icono + nombre + "CLASE · NIV X" (**sin spec**) + HP verde con "actual/máx" (**sin MP**); nivel/HP/estado en vivo; caído en gris

#### **Escenario 6: Lógica intacta**

* **GIVEN** el reskin aplicado
* **WHEN** se juega combate + party (targeting, invites, heals, muerte)
* **THEN** todo funciona igual que antes (R3.x/R9a/R8c sin cambios; sin errores rojos)

#### **Escenario 7: Móvil**

* **GIVEN** los frames en móvil
* **WHEN** se revisan
* **THEN** se adaptan (escale/touch) sin romper (R6.20/R6.27)

---

### **Alcance**

#### Incluye

* Reskin de PlayerFrame, TargetFrame (con cast bar y type label) y PartyFrame simplificado según los 3 frames aprobados.

#### No incluye

* Lógica de targeting/party/HP-MP (intactas); spec en el party (decisión: fuera); MP de aliados (decisión: fuera); retratos/iconos finales (placeholders hasta sus assets).

---

### **Definition of Done (DoD)**

* [ ] Los 3 frames replican `YDdLZ`/`AKFQh`/`cGcxE` (retratos, barras con %/valores, cast bar, filas del party).
* [ ] Datos reales en vivo (player, target con casteo, party con estados).
* [ ] Party sin spec y sin MP (decisiones PO); colores coherentes (verde aliado/propio, rojo enemigo).
* [ ] Nombres de instancias conservados; lógica intacta (sin errores rojos).
* [ ] Móvil OK y fuentes legibles (R6.20/R6.27).
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Decisiones cerradas (PO 2026-09-22)**

| Tema | Decisión |
|------|----------|
| Frames | Los 3 (`YDdLZ`/`AKFQh`/`cGcxE`, componentes reusables, aprobados) |
| Spec en party | **Fuera** — línea "CLASE · NIV X" como el diseño (**enmienda R6.26**) |
| MP de aliados | **Fuera** — party solo HP (simplificado confirmado) |
| HP propio/aliados | Verde `#5E9F3D` · HP enemigo rojo `#B84E5B` (coherente R6.26) |
| Cast bar | Visible solo durante casteos, con label real (R7.1) |
| Retratos/iconos | Enemigos: IDs reales (Jotunn/FrostLord/genérico — ASSETS_LIST) · Player: placeholder hasta retrato por clase · Clase: iconos EST-24 |

---

### **Estimación (orientativa)**

2–3 sesiones del dev: 3 frames + cast bar/type label + estados del party + regresión.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-ESTETICA-47: reskin de **PlayerFrame** (`YDdLZ`: retrato, HP verde + MP azul con %/valores), **TargetFrame** (`AKFQh`: HP rojo, **cast bar con label real** y **type label** "JEFE") y **PartyFrame simplificado** (`cGcxE`: icono + nombre + "CLASE · NIV X", HP verde, estados) — **sin spec (enmienda R6.26)** y **sin MP de aliados** (decisiones PO); sustituye los visuales de R8c/R3.x/R9a |
| 2026-09-22 | **Retratos de enemigos subidos (diseñador):** Jotunn `112251764292750` · FrostLord `105086910359542` · genérico `99954963258644` (ASSETS_LIST) — el TargetFrame usa estos IDs; medallón del player con placeholder hasta su asset |