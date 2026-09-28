# HU-R9a.1: Invitaciones al party — cualquier jugador del lobby (no solo amigos)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R9a / Party — Enmienda
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Mejora del sistema de invitaciones (dev)
**Fase GDD:** R9a (enmienda del party de amigos — las demás reglas de R9a quedan intactas)
**Depende de:** HU-R9a (PartyService, invitaciones 60 s, límite 4, UI EST-22), HU-ESTETICA-22 (ventana de party)
**Componentes observados:** `PartyService` (`RequestInvitePlayer`), ventana de party (EST-22), lista de jugadores del servidor (hub/lobby)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** poder **invitar a cualquier jugador que esté en el pueblo (lobby)** — no solo a mis amigos —,
**para** armar grupo con quien haya en el servidor en ese momento.

**Como** equipo,
**quiero** ampliar el destino de las invitaciones manteniendo todas las validaciones de R9a,
**para** que el party siga siendo seguro (límites, líder, 60 s) con más flexibilidad.

---

### **Descripción del Requerimiento / Contexto**

R9a implementó invitaciones entre **amigos** (`RequestInvitePlayer { targetUserId }`). Cambio (decisión PO 2026-09-22): el sistema puede invitar a **cualquier jugador presente en el hub** (lobby del servidor), no solo amigos.

**Criterio de hecho global:** desde la ventana de party, el líder ve a los jugadores del lobby (con PJ activo y sin party) y puede invitar a cualquiera; las reglas de R9a (límite 4, invitación 60 s, expiración, popup Aceptar/Rechazar) funcionan igual.

---

### **Especificaciones Técnicas / Contratos de API**

* **Servidor (`RequestInvitePlayer`):** acepta como destino a **cualquier jugador del mismo servidor (hub)** con PJ activo y sin party — no solo amigos. Validaciones (adicionales a las de R9a):
  * Mismo servidor/instancia (hub), PJ activo, sin party, no a sí mismo.
  * Límite 4 del party; solo el líder invita; invitación 60 s (regla R9a intacta).
* **Cliente (ventana de party, EST-22):** la sección "Invitar" muestra la **lista del lobby** (jugadores del servidor con PJ activo y sin party): nombre + clase + nivel (si está disponible). Invitar = seleccionar de la lista (envía la invitación con el popup normal).
  * Si el lobby está vacío (solo el líder): mostrar "No hay jugadores en el pueblo" y (opcional) botón de **invitación de Roblox** (Players:PromptInvite/overlay) para traer amigos — sin obligación.
* **Coexistencia:** se conserva la posibilidad de invitar a un amigo que esté en el lobby (es parte de la lista); no se agrega una lista de amigos separada (la del lobby la cubre).
* **Anti-exploit:** el server valida siempre el destino (mismo servidor, sin party); nunca se puede invitar a jugadores en la dungeon ni fuera del servidor.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Invitar a cualquiera del lobby**

* **GIVEN** un jugador en el pueblo con otros jugadores (amigos o no)
* **WHEN** el líder abre la ventana de party
* **THEN** ve la lista del lobby (con PJ activo y sin party) y puede invitar a cualquiera
* **AND** el invitado recibe el popup Aceptar/Rechazar (60 s, R9a)

#### **Escenario 2: Validaciones**

* **GIVEN** un líder con invitaciones activas
* **WHEN** intenta invitar a un jugador en la dungeon, sin PJ activo, con party, a sí mismo o con el party lleno
* **THEN** el server rechaza (mismas reglas de R9a + destino del lobby)

#### **Escenario 3: Lobby vacío**

* **GIVEN** un jugador solo en el pueblo
* **WHEN** abre la ventana de party
* **THEN** ve "No hay jugadores en el pueblo" (y el botón opcional de invitación de Roblox)

#### **Escenario 4: Regresión**

* **GIVEN** la mejora implementada
* **WHEN** se arma un party con invitados del lobby (PC y móvil, publicado)
* **THEN** no hay errores rojos y el resto de R9a (teleport grupal, dungeon compartida, threat, loot) funciona igual

---

### **Alcance**

#### Incluye

* Invitaciones a cualquier jugador del lobby (lista en la ventana de party).
* Validaciones server (mismo servidor, PJ activo, sin party, límites).
* Mensaje de lobby vacío + botón opcional de invitación de Roblox.

#### No incluye

* Listas de amigos externas (la lista del lobby la cubre).
* Matchmaking ni búsqueda de grupos públicos.
* Cambios a las demás reglas de R9a (teleport, dungeon, threat, loot).

---

### **Definition of Done (DoD)**

* [ ] El líder invita a cualquier jugador del lobby (lista visible en la ventana de party).
* [ ] Validaciones server correctas (mismo servidor/PJ activo/sin party/límites/60 s).
* [ ] Lobby vacío con mensaje claro (+ invitación de Roblox opcional).
* [ ] Sin errores rojos en party completo (PC y móvil, publicado).
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Estimación (orientativa)**

1 sesión del dev: lista del lobby + ampliación de la validación del destino + UI mínima.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-R9a.1: invitaciones al party para **cualquier jugador del lobby** (no solo amigos) — lista del lobby en la ventana de party, validaciones de R9a intactas y lobby vacío con invitación de Roblox opcional |