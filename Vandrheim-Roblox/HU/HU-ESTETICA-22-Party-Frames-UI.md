# HU-ESTETICA-22: Party frames y ventanas de party — diseño de UI en Pencil ("como se vería en el juego")

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / R9a (party)
**Prioridad:** Alta
**Estado:** Diseño entregado (frame `HU-ESTETICA-22 — Party Frames and Windows` en el `.pen`; verificación PM pendiente de MCP de Pencil)
**Tipo:** Diseño de UI en Pencil (solo diseñador; **sin desarrollo, sin código**)
**Fase GDD:** R9a (party de amigos; el dev implementa en HU-R9a)
**Depende de:** HU-ESTETICA-04/06 (sistema Hearthbound Gold), HU-ESTETICA-19/20 (HUD de combate — los party frames conviven con el HUD), HU-R9a (sistema de party: 2–4, líder, invitar/expulsar/salir)
**No modifica:** lógica del juego, party ni balance

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** ver los frames del party tal como se verían implementados: miembros con HP/MP, estado vivo/muerto, líder marcado, ventana para invitar amigos y popup de invitación,
**para** jugar en grupo sabiendo quién está bien, quién cayó y cómo armar el equipo.

**Como** equipo de desarrollo,
**quiero** un diseño de pantalla completo y a fondo de los elementos de party,
**para** implementarlos (HU-R9a) sin reinterpretar nada.

---

### **Descripción del Requerimiento / Contexto**

R9a agrega el party de amigos (2–4 jugadores): se arma en el **pueblo**, el portal teleporta al grupo a la misma run, el tanque sostiene con threat y el loot es personal. Esta HU diseña la **UI de party** a fondo:

* **Party frames del HUD:** lista de miembros con nombre, clase, nivel, **HP/MP**, estados **vivo/muerto**, **líder marcado** y el jugador destacado.
* **Ventana de party en el pueblo:** crear party, **invitar amigos**, expulsar, salir (y ver el líder).
* **Popup de invitación:** aceptar/rechazar.
* **Variante móvil** del HUD de party.

**Criterio de hecho global:** existen en el `.pen` los party frames, la ventana de party y el popup de invitación — con mockup real de un party (ej. Paladín + Cazador + Clérigo) en el pueblo y en la dungeon — listos para implementar en R9a.

**Entrega (2026-09-22):** diseño completado en `Vandrheim-design.pen`, frame **`HU-ESTETICA-22 — Party Frames and Windows`** (seleccionado por el PO como referencia). El dev lo usa como referencia visual al implementar (HU-R9a); verificación del PM pendiente de reconexión del MCP de Pencil.

---

### **Especificaciones Técnicas / Contratos de API (visual)**

#### **1. Elementos a diseñar (frames nuevos en el `.pen`)**

Coherentes con Hearthbound Gold (Scale + UIAspectRatioConstraint en implementación) y conviviendo con el HUD de combate (EST-19/20):

* **Party frames del HUD (esquina, al lado/arriba del player frame):**
  * 1 fila por miembro: **nombre**, clase (icono/texto), nivel, **barra de HP y MP** (estilo de las barras del HUD), y estados.
  * **Líder marcado** (icono de corona/escudo pequeño) y **jugador propio destacado** (borde/etiqueta "Tú").
  * **Muerto:** barra atenuada + estado "Caído" (rojo/gris).
  * El frame crece con el tamaño del party (2–4) sin romper el layout.
* **Ventana de party (pueblo):** lista de miembros con rol, botones **Invitar amigo** (abre el picker de amigos de Roblox o lista propia), **Expulsar** (solo líder, con confirmación), **Salir del party** (con confirmación), y marcado del líder.
* **Popup de invitación:** nombre del invitador, "Te invitó a su party", botones **Aceptar / Rechazar**, y estado "Invitación expirada" si aplica.
* **Estados obligatorios:** party lleno (4/4, botón invitar bloqueado), un miembro muerto en dungeon, líder migrado (el marcador cambia), invitación recibida y expirada.

#### **2. Contenido real del mockup (obligatorio)**

* **Mockup principal: party de 3 en la dungeon (piso 3):** Paladín **Protector** (líder, tanque), Cazador **Puntería**, Clérigo **Misericordia** — con HP/MP reales, **uno caído** (ej. el Cazador), el resto en combate (zona de Ira divina visible si conviene), conviviendo con el HUD de combate (skillbar, target, números).
* **Mockups adicionales dentro de la misma pantalla (estados):**
  * **Ventana de party en el pueblo** (4/4 con invitar bloqueado, líder marcado).
  * **Popup de invitación** (aceptar/rechazar) y variante **expirada**.
  * **Party frame móvil** (compacto, conviviendo con el mobile HUD).

#### **3. Reglas**

* Trabajar en `Vandrheim-design.pen` en **frames propios de esta HU** (o pantallas nuevas dentro de `DX7OA`); no rehacer el HUD ni las pantallas existentes.
* Usar la paleta/tokens de EST-04/06 (fondos, latón `#C89445`, pergamino `#F4EDE0`, barras HP/MP, frío `#8FB7D6`), tipografías Geist Mono / Playfair Display / Inter.
* Coherencia con el HUD de combate (EST-19): mismas barras y jerarquía visual.
* Los nombres/clases del mockup son reales (Protector/Puntería/Misericordia); los números son ilustrativos.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Party frames implementables**

* **GIVEN** el HUD con party frames diseñados
* **WHEN** se mira el mockup de 3 jugadores en la dungeon
* **THEN** cada miembro tiene nombre, clase, nivel, HP/MP y estado (vivo/muerto) con el estilo del HUD
* **AND** el líder y el jugador propio se distinguen sin texto

#### **Escenario 2: Estados**

* **GIVEN** los frames diseñados
* **WHEN** se revisan los estados
* **THEN** party lleno (4/4), miembro caído, líder migrado, invitación recibida/expirada se distinguen sin confusión

#### **Escenario 3: Ventana de party**

* **GIVEN** la ventana de party del pueblo
* **WHEN** se revisa
* **THEN** se ven los miembros, invitar (bloqueado si 4/4), expulsar (solo líder, con confirmación) y salir

#### **Escenario 4: Popup de invitación**

* **GIVEN** el popup de invitación
* **WHEN** llega una invitación
* **THEN** muestra el invitador y Aceptar/Rechazar
* **AND** la variante expirada se ve clara

#### **Escenario 5: Móvil**

* **GIVEN** el party frame móvil
* **WHEN** se revisa con el mobile HUD
* **THEN** es compacto, legible y no rompe los controles táctiles

#### **Escenario 6: Fiel al sistema**

* **GIVEN** el diseño
* **WHEN** se compara con R9a (party 2–4, líder, invitar/expulsar/salir)
* **THEN** refleja las reglas del sistema sin inventar mecánicas

---

### **Comportamiento Visual / Reglas de Negocio**

* Es diseño puro: no define lógica, remotes ni balance.
* Los party frames son **presentación**: leen los datos del party (R9a) sin cambiar reglas.
* Conviven con el HUD de combate sin tapar la acción.

---

### **Alcance**

#### Incluye

* Party frames del HUD (miembros, HP/MP, estados, líder, propio) + variante móvil.
* Ventana de party del pueblo (crear/invitar/expulsar/salir) y popup de invitación (aceptar/rechazar/expirada).
* Mockup principal (party de 3 en la dungeon, un caído) + estados (4/4, líder migrado, expirada).

#### No incluye

* Código, remotes ni lógica de party (dev — HU-R9a).
* Cambios al HUD de combate ni a las demás pantallas del `.pen`.
* Matchmaking, voice chat ni sistemas sociales extra.

---

### **Definition of Done (DoD)**

* [ ] Party frames del HUD completos (nombre/clase/nivel/HP/MP/estado/líder/propio) con mockup real de 3 jugadores.
* [ ] Estados cubiertos: 4/4, caído, líder migrado, invitación recibida/expirada.
* [ ] Ventana de party (invitar/expulsar con confirmación/salir) y popup de invitación diseñados.
* [ ] Variante móvil del party frame.
* [ ] Fiel a R9a (2–4, líder, invitaciones) sin inventar mecánicas.
* [ ] Paleta y componentes de Hearthbound Gold respetados; convive con el HUD de combate.
* [ ] Reporte al PM con el detalle del diseño y pendientes.

---

### **Estimación (orientativa)**

1–2 sesiones del diseñador: party frames + ventana + popup + estados + mockups.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-ESTETICA-22: diseño a fondo de la UI de party (frames del HUD con HP/MP y estados, ventana de party del pueblo, popup de invitación, variante móvil) — solo diseñador, sin desarrollo; el dev la implementa en HU-R9a |
| 2026-09-22 | **Entrega del diseñador:** frame `HU-ESTETICA-22 — Party Frames and Windows` en el `.pen` (referencia para HU-R9a); verificación PM pendiente de MCP |