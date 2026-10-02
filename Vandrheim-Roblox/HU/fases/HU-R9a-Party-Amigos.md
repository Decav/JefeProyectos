# HU-R9a: Party de amigos — grupo, dungeon compartida, loot y threat (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R9 — Demo estable / Party (primera parte)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Sistema multiplayer cooperativo (dev)
**Fase GDD:** R9 (posterior a R8d y PUBLICAR; el solo ya es estable)
**Depende de:** HU-R8d (balance base), HU-PUBLICAR-02 (dungeon cross-place con `partyId`), HU-R6b (run lifecycle), HU-R4 (loot con `ownerCharacterId`), HU-ESTETICA-22 (diseño de party frames), SKILLS_CATALOG (`threatMod` activo en party)
**No modifica:** el juego en solitario (debe seguir igual)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** invitar a mis amigos, entrar juntos a la dungeon en la misma run y jugar en grupo (packs más grandes, dificultad acorde y mi rol importando),
**para** jugar Vandrheim con amigos como un MMO de verdad.

**Como** equipo,
**quiero** el party de amigos (2–4) sobre el flujo existente (teleport con `partyId`, servidor reservado compartido, loot con owner, `threatMod` activo),
**para** cerrar la demo cooperativa sin romper el solo.

---

### **Descripción del Requerimiento / Contexto**

El juego es solo hoy: `partyId` viaja `nil` en el teleport (R6b/PUBLICAR-02) y `threatMod` no tiene efecto fuera de solo (SKILLS_CATALOG lo reserva para party). Esta HU implementa el **party de amigos v1** (GDD §3 opción C: amigos primero):

* **Party 2–4 jugadores**, armado en el **pueblo** (hub): invitar amigos, aceptar/rechazar, expulsar, salir.
* **Dungeon compartida:** el portal teleporta a **todo el party al mismo servidor reservado** (misma run, `partyId` real).
* **Dificultad de grupo:** packs más grandes (packs 5+) y enemigos escalados por tamaño de party.
* **Loot y experiencia:** decisión MVP: **loot personal** (cada jugador ve/dropea lo suyo) + **XP plena** a cada miembro (el oro del drop se reparte o es personal — ver decisiones).
* **Threat activo:** el Protector genera más amenaza y los enemigos priorizan por `threatMod` (tank real).
* **UI:** party frames del HUD + ventana de party en el hub + popup de invitación (diseñador: HU-ESTETICA-22).

**Criterio de hecho global:** 2–4 amigos arman party en el pueblo, entran juntos a la misma run, el tanque sostiene con threat, los dps/healer cumplen su rol, el loot es personal y el solo sigue funcionando intacto.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. PartyService (server) + remotes**

* Nuevo `PartyService` (server): crear party (2–4), invitar (solo líder), aceptar/rechazar, expulsar (solo líder), salir (migra liderazgo si el líder sale), disolver si todos se van.
* Remotes nuevos:
  * `RequestCreateParty` (C→S) — en el hub, con PJ activo.
  * `RequestInvitePlayer` (C→S) `{ targetUserId }` — solo líder.
  * `RequestRespondInvite` (C→S) `{ partyId, accept }`.
  * `RequestKickPlayer` (C→S) `{ targetUserId }` — solo líder.
  * `RequestLeaveParty` (C→S).
  * `PartyStateUpdate` (S→C) — estado del party a todos (miembros, líder, estados vivos).
* Validaciones server: en el hub (no en dungeon), límite 4, solo líder invita/expulsa, anti-exploit (no unirse a party ajeno sin invitación).
* **Invitación (decisión PM):** dura **60 segundos**; si el invitado no responde, expira (el diseño EST-22 ya contempla el estado "expirada") y se avisa al invitador.

#### **2. Teleport grupal (dungeon compartida)**

* `StartRun` (R6b/PUBLICAR-02): si el jugador está en party, teleporta a **todos los miembros** al mismo servidor reservado; `partyId` real en el teleport data.
* El servidor de la dungeon inicializa la run para el party (pisos compartidos, mismo seed).
* Abandonar/salir: si todos se van → run termina; si queda ≥1 → la run sigue. Líder que sale → **migra liderazgo** (default) dentro de la dungeon.

#### **2.1 Run compartida (refactor acotado — punto técnico delicado)**

* Hoy la run genera **un piso por jugador**; hay que convertirla en **una sola run compartida** por party sin alterar el modo solitario:
  * **Refactor:** la run pasa a identificarse por **runId de party** (la run se genera **una vez** en el servidor: un seed, unos pisos, spawns compartidos para todos los miembros del party). El modo **solo = party de 1**: mismo camino de código, mismo presupuesto y comportamiento que hoy (sin cambios de comportamiento).
  * Los miembros ven el **mismo piso/seed** (compartido); los enemigos son los mismos para todos (daño/loot individuales por jugador, respawn individual en la entrada del piso).
  * Contratos de R6b intactos (remotes, teleport data, persistencia); `partyId = nil` → comportamiento de solo idéntico.
  * Verificación: regresión completa de solo (cada piso igual que antes de esta HU) + party compartiendo la misma run.

#### **3. Dificultad de grupo (decisiones PM cerradas 2026-09-22)**

* **Packs:** presupuesto de packs del piso = **solo + (tamaño de party − 1)** (party de 2: +1 pack; de 3: +2; de 4: +3 sobre el `FLOOR_BUDGET` de solo). **PackSize:** el de solo **+1** (2→3, 3→4).
* **Enemigos:** HP × **1 + 0.30×(party−1)** (×1.3 / ×1.6 / ×1.9); daño × **1 + 0.15×(party−1)** (×1.15 / ×1.3 / ×1.45). El daño sube menos que el HP porque el party reparte la agresión y el tanque sostiene (threat).
* **Metas (bandas R8d):** TTK por mob en party ≈ 1.2–1.5× el solo; el party completo avanza por piso sin muertes infinitas; TTD del tanque con cura ≥ el de solo.
* **XP plena por miembro se mantiene** (decisión MVP) — si el QA de R9c detecta inflación de progresión, se ajusta ahí.
* Regla: en party de 2 la dificultad es ~1.5× un solo; de 3 ~2×; de 4 ~2.5× (medido con el party completo).

#### **4. Threat activo**

* `threatMod` (Protector > 1, config desde R3) empieza a **sumar amenaza** y los enemigos **priorizan al objetivo con mayor amenaza** del party (targeting server-side por lista de enemigos agredidos).
* El healer no roba aggro fácilmente (sus curas generan amenaza baja — se ajusta en config, no en código).

#### **5. Loot y XP (decisiones MVP)**

* **Loot personal:** cada jugador recibe su propio drop (auto-grant R4 con `ownerCharacterId`); sin need/greed en MVP (R9c/posterior si el PO quiere).
* **XP plena** a cada miembro del party (cada uno gana la XP del enemigo muerto; sin reparto proporcional en MVP).
* **Oro:** personal (cada drop/venta es del jugador); los tesoros de cofre del boss se reparten como loot personal.

#### **6. UI (implementa el diseño de EST-22)**

* Party frames del HUD (HP/MP/nombre/nivel/clase, estados vivo/muerto, líder marcado), ventana de party en el hub (crear/invitar/expulsar/salir), popup de invitación, y variante móvil — según el diseño del diseñador (HU-ESTETICA-22).
* **Referencia visual:** frame **`HU-ESTETICA-22 — Party Frames and Windows`** en `Vandrheim-design.pen` (entregado 2026-09-22) — abrir el `.pen` para el panorama completo; el resultado debe ser lo más cercano posible al frame.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Armar el party**

* **GIVEN** 2–4 jugadores en el pueblo
* **WHEN** uno crea el party e invita a sus amigos
* **THEN** los invitados ven el popup, aceptan y quedan en el party (líder marcado)
* **AND** rechazar no rompe nada

#### **Escenario 2: Dungeon compartida**

* **GIVEN** un party completo en el pueblo
* **WHEN** el líder usa el portal
* **THEN** todos se teleportan al **mismo servidor reservado** (misma run, mismo piso/seed)
* **AND** los pisos son compartidos y el avance aplica a todos

#### **Escenario 3: Dificultad de grupo**

* **GIVEN** un party de 2–4 en la dungeon
* **WHEN** se genera un piso
* **THEN** los packs son más grandes (packs 5+) y los enemigos escalan según el tamaño del party
* **AND** el party completo puede completar la run sin muertes infinitas (dentro de bandas R8d)

#### **Escenario 4: Threat**

* **GIVEN** un party con Protector
* **WHEN** el Protector genera amenaza (threatMod > 1)
* **THEN** los enemigos priorizan al Protector
* **AND** el healer/dps no roban aggro con normalidad

#### **Escenario 5: Loot y XP**

* **GIVEN** un party matando enemigos
* **WHEN** caen drops
* **THEN** cada jugador recibe su loot personal (auto-grant con owner)
* **AND** cada uno gana la XP plena del enemigo

#### **Escenario 6: Líder y abandono**

* **GIVEN** el party en la dungeon
* **WHEN** el líder sale
* **THEN** el liderazgo migra (o el party se disuelve si quedan 0)
* **AND** salir a mitad de run conserva lo ganado (regla R6b) para cada miembro

#### **Escenario 7: Anti-exploit**

* **GIVEN** un cliente manipulador
* **WHEN** intenta unirse a un party sin invitación, invitar sin ser líder, o teleportar solo a la run de otro
* **THEN** el servidor rechaza
* **AND** el solo sigue funcionando igual (sin party)

#### **Escenario 8: Regresión**

* **GIVEN** el party implementado
* **WHEN** se juega solo y en party (pueblo → dungeon → rejoin)
* **THEN** no hay errores rojos
* **AND** el flujo solitario no cambia

---

### **Comportamiento Visual / Reglas de Negocio**

* El party se arma en el **pueblo**; dentro de la dungeon no se invita (decisión MVP).
* Loot personal + XP plena (MVP); need/greed queda fuera (decisión posterior).
* El solo queda intacto: sin party, todo funciona como hoy.

---

### **Alcance**

#### Incluye

* PartyService (crear/invitar/aceptar/expulsar/salir/migrar líder, 2–4) + remotes.
* Teleport grupal al mismo servidor reservado (`partyId` real).
* Packs 5+ y escalado de dificultad por tamaño de party.
* Threat activo (priorización por amenaza).
* Loot personal (owner) + XP plena.
* Implementación de la UI de party según HU-ESTETICA-22.

#### No incluye

* Matchmaking, búsqueda de grupos públicos.
* Need/greed o comercio entre jugadores.
* PvP, voice chat ni sistemas sociales extra.
* Cambios al solo (se preserva).

---

### **Definition of Done (DoD)**

* [ ] Party 2–4 armable en el pueblo (invitar/aceptar/expulsar/salir/migrar líder) con remotes validados.
* [ ] Portal teleporta al party completo al mismo servidor reservado (misma run).
* [ ] Packs 5+ y enemigos escalados por tamaño de party (bandas R8d).
* [ ] Threat activo: enemigos priorizan al Protector (threatMod).
* [ ] Loot personal con owner + XP plena.
* [ ] UI de party implementada según EST-22 (HUD, hub, popup, móvil).
* [ ] Solo intacto: sin party, nada cambia; sin errores rojos.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Al cerrar: PROJECT_ARCHITECTURE, DATA_SCHEMA y registro HU/RC actualizados; nota en GDD después de QA (prueba con amigos publicada).

---

### **Decisiones por defecto R9a**

| Tema | Default |
|------|---------|
| Tamaño de party | 2–4 (límite server) |
| Lugar | Party solo en el pueblo; invitar dentro de la dungeon: no (MVP) |
| Loot | Personal (owner) — sin need/greed |
| XP | Plena a cada miembro |
| Oro | Personal |
| Packs | Solo + (party−1) packs; packSize solo +1 |
| Enemigos | HP ×1.3/1.6/1.9 · daño ×1.15/1.3/1.45 (2/3/4 jugadores) |
| Invitación | 60 s de vigencia; expira con aviso |
| Run | Compartida por party (runId de party); solo = party de 1 (mismo camino) |
| Threat | threatMod suma amenaza; priorización server |
| Líder sale | Migra liderazgo; run sigue si queda ≥1 |

---

### **Estimación (orientativa)**

3–4 sesiones del dev: PartyService + teleport grupal + dificultad + threat + loot + UI (con EST-22) + regresión.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-R9a: party de amigos 2–4 — PartyService, teleport grupal al mismo servidor reservado, packs 5+/escalado, threat activo, loot personal + XP plena y UI de party (EST-22); el solo queda intacto |
| 2026-09-22 | **Decisiones PM cerradas:** packs = solo + (party−1) con packSize +1; enemigos HP ×1.3/1.6/1.9 y daño ×1.15/1.3/1.45; invitación 60 s; **run compartida = refactor acotado** (runId de party, solo = party de 1, contratos R6b intactos). No bloquean: R8d (bandas como referencia; fine en R9c) y PUBLICAR-02 (QA cross-place OK) |