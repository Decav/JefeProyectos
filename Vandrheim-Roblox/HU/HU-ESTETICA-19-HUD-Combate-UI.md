# HU-ESTETICA-19: HUD de Combate — diseño de UI en Pencil ("como se vería en el juego")

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / EST-04 (diseño a fondo de pantallas)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Diseño de UI en Pencil (solo diseñador; **sin desarrollo, sin código**)
**Fase GDD:** EST (transversal; independiente de R8a–R8c)
**Depende de:** HU-ESTETICA-04/06 (HUD base Hearthbound Gold), HU-R6.8 (VFX básico: números de daño, hits, muerte), HU-R6.9 (AoE: zonas persistentes y SelfAoE), HU-R3.3 (indicador visual de target), HU-R6.5 (skillbar/XP), HU-R7 (boss piso 5), HU-R6a (XP/leveling)
**No modifica:** lógica del juego, combate, VFX ni balance

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** ver los elementos del HUD de combate tal como se verían implementados: números de daño y cura, barra del boss, zonas AoE, cooldowns y feedback de golpes,
**para** leer el combate de un vistazo y que la pelea se sienta clara y épica.

**Como** equipo de desarrollo,
**quiero** un diseño de pantalla completo y a fondo de los elementos de combate del HUD,
**para** implementarlos sin reinterpretar nada y que los VFX y la UI combinen.

---

### **Descripción del Requerimiento / Contexto**

El HUD base (EST-04/06) está diseñado: player card, HP/MP/XP/oro, target frame, crosshair, skillbar 4 y slots Z/X. Pero los **elementos que aparecen durante el combate** no tienen diseño propio. Esta HU los desarrolla **a fondo**, con el aspecto final que tendrían en el juego, usando los sistemas reales:

* **Números de daño/cura (R6.8):** flotantes al golpear/curar, con críticos y estilos diferenciados.
* **Indicador de target (R3.3):** el jugador debe saber qué enemigo tiene seleccionado (anillo/marcador en el mundo).
* **AoE (R6.9):** marcador de zona al lanzar `GroundAoE` (punto elegido, ≤20 de rango) y la **zona persistente activa** con daño por tick; `SelfAoE` (anillo alrededor del jugador).
* **Boss (R7):** barra de HP del Guardián de la Escarcha (piso 5) destacada sobre el target normal.
* **Skillbar (R6.5):** cooldowns (overlay), coste de maná al lanzar, recarga visual.
* **XP/leveling (R6a):** notificación de subida de nivel.
* **Feedback de golpes:** daño recibido (borde/flash rojo) y muerte de enemigo (R6.8).

**Criterio de hecho global:** existe en el `.pen` un conjunto de elementos de HUD de combate completo y realista — con un mockup de pelea (incluido el boss del piso 5) — listo para que el dev lo implemente sin rediseñar.

---

### **Especificaciones Técnicas / Contratos de API (visual)**

#### **1. Elementos a diseñar (frames nuevos en el `.pen`)**

Coherentes con Hearthbound Gold (`Scale` + `UIAspectRatioConstraint` en implementación), integrados visualmente al HUD base:

* **Números de daño/cura (flotantes):** estilo del HUD (Geist Mono mapeada); daño normal (pergamino), **crítico** (más grande, latón o rojo), cura (verde/frío `#8FB7D6`), daño recibido (rojo `#C45345`); alineación y tamaño por tipo; sin desorden (se diseñan 2–3 tamaños, no 10).
* **Indicador de target (R3.3):** anillo/marcador bajo el enemigo seleccionado (estilo nórdico, latón `#C89445` o frío), distinto del anillo de SelfAoE; visible también sobre el objetivo de los marcadores de zona.
* **Marcador de GroundAoE:** círculo de **pre-lanzamiento** (donde el jugador apunta, con radio visible) y la **zona activa persistente** (relleno semitransparente con borde, estilo de la skill: sagrada/íra).
* **Barra del boss (R7):** frame superior con nombre del Guardián de la Escarcha, HP grande y distintivo (latón/rojo), visible solo en la pelea del piso 5; distinta del target normal.
* **Cooldowns en la skillbar:** overlay oscuro con **cuenta regresiva** (número o barra) sobre el slot en recarga; el slot activo con resaltado al lanzar; coste de maná indicado (el coste ya está en el slot; se resalta al no alcanzar el maná).
* **Feedback de golpes:** flash/borde rojo en el HUD al recibir daño (sutil), sin tapar la pantalla.
* **Notificación de nivel:** popup breve "¡Nivel 17!" con estilo del juego (al subir, R6a).
* **Muerte de enemigo:** confirmación visual breve (ya hay VFX; el HUD no la repite — solo se aclara si el diseñador ve un hueco).
* **Estados obligatorios:** pelea normal (mob), pelea de boss con barra + AoE activa + CD, crítico visible, cura visible, daño recibido, nivel arriba.

#### **2. Contenido real del mockup (obligatorio)**

Diseñar **una escena de pelea realista** (lo que vería el jugador en el juego):

* **Mockup principal: pelea contra el Guardián de la Escarcha (piso 5, R7):**
  * HUD base completo (player card con HP/MP/XP, target reemplazado por la **barra del boss**).
  * **Barra del boss** con nombre y HP (ej. al 60%).
  * **Zona de Consagración/Ira divina activa** en el suelo (GroundAoE persistente, ticks visibles) y/o **SelfAoE** (Anillo de luz sagrada/Torbellino) alrededor del jugador.
  * **Números flotantes:** daño del jugador al boss (normal + 1 crítico), **cura** (si el mockup lo permite), y daño recibido del jugador.
  * **Skillbar** con 2 slots en cooldown (overlay + cuenta) y 1 slot resaltado al lanzar.
  * **Indicador de target** sobre el boss.
* **Mockups adicionales dentro de la misma pantalla (estados):**
  * **Pelea normal** (mob de piso 1–2): target frame normal, números pequeños, sin barra de boss.
  * **Pre-lanzamiento de GroundAoE**: círculo de puntería sobre el suelo con radio.
  * **Notificación de nivel** (ej. "¡Nivel 17!") y **flash de daño recibido**.
  * Variante con **SelfAoE** alrededor del jugador.

#### **3. Reglas**

* Trabajar en `Vandrheim-design.pen` en **frames propios de esta HU** (o pantallas nuevas dentro de `DX7OA`); no rehacer el HUD base ni las pantallas existentes.
* Usar la paleta/tokens de EST-04 (fondos, latón `#C89445`, pergamino `#F4EDE0`, barras HP/MP/XP, frío `#8FB7D6`), tipografías Geist Mono / Playfair Display / Inter.
* Los números (daño, HP del boss) son **ilustrativos**; el diseñador no cambia combate ni balance.
* Los elementos deben convivir con los VFX de R6.8/R8 (no taparlos): el diseñador documenta posiciones/tamaños para que no compitan.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: La pelea se ve implementada**

* **GIVEN** el mockup de la pelea contra el boss
* **WHEN** se mira la escena
* **THEN** se ven la barra del boss, la zona AoE activa, los números de daño/cura y los cooldowns como en el juego
* **AND** el HUD base (HP/MP/XP/skillbar) se mantiene coherente

#### **Escenario 2: Números de daño/cura**

* **GIVEN** los números flotantes diseñados
* **WHEN** se revisan los tipos
* **THEN** daño normal, crítico, cura y daño recibido se distinguen sin texto (tamaño/color)

#### **Escenario 3: AoE clara**

* **GIVEN** el marcador de pre-lanzamiento y la zona activa
* **WHEN** se comparan
* **THEN** el jugador distingue dónde va a caer la zona y cuál zona ya está activa (GroundAoE)
* **AND** el SelfAoE se ve distinto (alrededor del jugador)

#### **Escenario 4: Boss y cooldowns**

* **GIVEN** la pelea contra el boss
* **WHEN** se revisa la barra del boss y la skillbar
* **THEN** la barra del boss es distintiva (nombre + HP grande) y los slots en cooldown muestran overlay y cuenta regresiva

#### **Escenario 5: Estados restantes**

* **GIVEN** los elementos diseñados
* **WHEN** se revisan nivel, daño recibido y pelea normal
* **THEN** la notificación de nivel, el flash de daño y la pelea normal (sin barra de boss) están representados

#### **Escenario 6: Fiel al sistema**

* **GIVEN** el diseño del HUD de combate
* **WHEN** se compara con el juego real (R6.8/R6.9/R3.3/R7)
* **THEN** el diseño refleja los sistemas existentes sin inventar mecánicas ni elementos

---

### **Comportamiento Visual / Reglas de Negocio**

* Es diseño puro: no define lógica, daño, VFX ni balance.
* Los elementos de combate se leen sin tapar la acción (tamaños acotados, sin superponerse al centro de la pantalla).
* Los colores siguen la paleta y los roles ya establecidos (daño/cura/golpe recibido).

---

### **Alcance**

#### Incluye

* Números de daño/cura/crítico (estilos y tamaños).
* Indicador de target (R3.3), marcador de GroundAoE (pre-lanzamiento + zona activa) y SelfAoE.
* Barra del boss del piso 5 (R7).
* Cooldowns con overlay/cuenta en la skillbar y resaltado de lanzamiento.
* Feedback de daño recibido y notificación de nivel.
* Mockup principal (pelea de boss) + estados (pelea normal, pre-lanzamiento, SelfAoE, nivel).

#### No incluye

* Código, remotes, lógica de combate ni VFX (dev — los VFX son de R6.8/R8).
* Cambios al HUD base ni a las demás pantallas del `.pen`.
* Balance, daños ni mecánicas nuevas.

---

### **Definition of Done (DoD)**

* [ ] Mockup de pelea contra el boss del piso 5 (barra de boss, AoE activa, números, cooldowns).
* [ ] Números de daño/cura/crítico/recibido distinguibles sin texto.
* [ ] Indicador de target, marcador de GroundAoE (pre y activa) y SelfAoE diseñados y diferenciados.
* [ ] Barra del boss distintiva; cooldowns con overlay y cuenta regresiva.
* [ ] Notificación de nivel y flash de daño recibido representados.
* [ ] Fiel a R6.8/R6.9/R3.3/R7 sin inventar mecánicas.
* [ ] Paleta y componentes de Hearthbound Gold respetados; no tapa la acción.
* [ ] Reporte al PM con el detalle del diseño y pendientes.

---

### **Estimación (orientativa)**

1–2 sesiones del diseñador: elementos de combate + mockup de pelea + estados.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-18 | Creación de HU-ESTETICA-19: diseño a fondo del HUD de combate (números de daño/cura, indicador de target, AoE, barra del boss, cooldowns, nivel, feedback de golpes) — solo diseñador, sin desarrollo |