# HU-R9a.2: Matchmaking de la dungeon — sala de grupo + ventana de info (prelobby)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R9a / Party — Prelobby de dungeon (matchmaking)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Sistema de lobby/matchmaking (dev) sobre el party existente
**Fase GDD:** R9a (enmienda; R9a/R9a.1 declaraban el matchmaking fuera — esta HU lo agrega)
**Depende de:** HU-R9a (PartyService, límite 4, invitación 60 s, teleport grupal, run compartida), HU-R9a.1 (lista del lobby para invitar), HU-PUBLICAR-02/R6b (teleport cross-place con `partyId`), HU-ESTETICA-22 (party frames/ventana de party, estilo EST-13), HU-R8d (bandas), `EnemyConfig`/`LootTables`/`BossConfig` (info de dungeon)
**No modifica:** el juego en solitario ni las reglas de R9a (solo añade la capa de sala/matchmaking previa al teleport)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** antes de entrar a la dungeon elegir si ir solo o en grupo, crear una sala (pública o privada), unirme a una sala de otro jugador, invitar/esperar compañeros y ver la info de la dungeon (enemigos, jefes y loot),
**para** armar una composición 1 tank / 1 heal / 2 dps y entrar todos juntos a la misma run con la información necesaria a la vista.

**Como** equipo,
**quiero** el prelobby de matchmaking integrado al party existente (R9a) y al teleport grupal,
**para** cerrar el flujo social de la demo sin duplicar sistemas ni romper el solo.

---

### **Descripción del Requerimiento / Contexto**

R9a implementó el party de amigos (2–4, invitaciones 60 s, límite 4, teleport grupal con `partyId`, run compartida, threat, loot personal) y R9a.1 amplió las invitaciones a cualquier jugador del lobby. Lo que no existe es el **prelobby de la dungeon**: una interfaz previa al portal donde el jugador decida cómo entrar.

Esta HU agrega la **ventana de matchmaking** (en el hub, al interactuar con el portal o desde el menú):

1. **Elección Solo / Grupo**:
   * **Solo** → arranca la run individual con el flujo actual (partyId nil, sin cambios).
   * **Grupo** → se abre el lobby de sala: **Crear sala** o **Unirse a una sala**.
2. **Crear sala**: elegir **pública** (aparece en la lista) o **privada** (solo invitaciones); opcional nombre de sala; invitar gente desde la lista del lobby (R9a.1) o esperar a que se unan.
2.1 **Autocompletado del party**: si el jugador ya tiene un **party armado** (R9a) al entrar en modo Grupo, la sala se crea/abre **pre-cargada con los miembros de su party** (misma info de roles/ready); no tiene que volver a invitar a quienes ya lo acompañan.
3. **Unirse a una sala**: lista de salas públicas del servidor (líder, tamaño, roles cubiertos); unirse con un click si hay lugar y no se está en party/sala.
4. **Sala (2–4)**: casillas con **rol esperado y rol cubierto** (Tank/Heal/DPS según clase+spec), estado de **Listo** por jugador, botones **Salir de sala** (miembro) y **Empezar run** (líder).
5. **Roles auto-verificados (server)**: el sistema deriva el rol de la clase+spec activa (Protector → Tank, Misericordia → Heal; el resto → DPS). **Si no califica como Tank ni Heal, va como DPS** (no hay selección manual).
6. **Composición — regla final (decisión PO 2026-09-22):**
   * **Party pre-armado:** **no se valida composición** — se inicia con el count que tenga el party (2–4).
   * **Sala pública/privada (matchmaking):** la composición **se valida y se muestra** (objetivo 1 Tank / 1 Heal / 2 DPS, sin duplicar Tank ni Heal), pero el inicio **nunca se bloquea por composición ni por cantidad**.
   * **Inicio siempre permitido con ≥2 jugadores** (2, 3 o 4), con el **ready-check de los presentes**; si la sala/grupo queda con 1 jugador, ese jugador va en modo solo.
7. **Ready-check**: cada miembro marca **Listo**; cuando **todos los presentes** están listos, la run **arranca automáticamente** y todos se teleportan juntos (flujo R6b/PUBLICAR-02 con `partyId`).
7.1 **Ventana de info de la dungeon** (misma interfaz, pestaña/panel): detalle de la Helada, enemigos por piso, mini-jefe del piso 4, boss final (Jotunn) y **loots de los últimos 2 jefes**.

**Criterio de hecho global:** desde el hub, un jugador elige solo o grupo; si es grupo, crea/une a una sala (pública o privada), completa la composición 1/1/2 y el ready-check, y toda la sala entra junta a la misma run; el solo funciona idéntico sin pasar por sala.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Estado de sala (server) — sobre PartyService**

* La sala es el **party existente** (R9a) más metadatos de lobby:
  ```luau
  {
    partyId, leaderUserId,
    isPublic = true/false,        -- pública (listada) o privada (solo invitación)
    roomName = "Sala de Uruz",    -- opcional
    members = { [userId] = { ready = false, role = "Tank"|"Heal"|"DPS" } },
    status = "lobby" | "starting" | "in_dungeon",
  }
  ```
* Solo se permite estar en una sala/party a la vez (regla R9a); las salas viven **solo en el hub**.
* **Autocompletado:** al entrar en modo Grupo con un party existente, la sala se arma con los miembros del party (líder = líder del party); no se obliga a re-invitar. Los miembros del party pueden unirse a la sala del líder sin invitación (ya están "en la sala" de facto).
* Al iniciar la run: `status = starting` → teleport grupal (R9a/PUBLICAR-02) a toda la sala → `in_dungeon` (coincide con la dungeon compartida ya implementada).
* Expulsión/abandono: las reglas de R9a (migrar líder, disolver si quedan 0); si alguien se va con ready confirmado, su ready se resetea.

#### **2. Remotes nuevos**

| Remote | Dir | Payload | Validación server |
|--------|-----|---------|-------------------|
| `RequestCreateRoom` | C→S | `{ roomName?, isPublic }` | Hub, PJ activo, sin party/sala |
| `RequestRoomList` | C→S | — | Lista de salas públicas del servidor (con PJ activo, sin party) |
| `RequestJoinRoom` | C→S | `{ partyId }` | Sala pública del mismo servidor, lugar libre, sin party previo |
| `RequestLeaveRoom` | C→S | — | En sala (antes de iniciar la run) — delega salir de party (R9a) |
| `RequestSetReady` | C→S | `{ ready }` | En sala; al quedar todos ready + composición válida → el server inicia la run |
| `RoomStateUpdate` | S→C | `{ partyId, members, roles, ready, isPublic, roomName, status }` | Estado de la sala a todos los miembros |
| `RoomListUpdate` | S→C | `{ rooms }` | Actualización de la lista de salas públicas |

* El inicio de run con sala usa el **teleport grupal existente** (R9a): no se agrega un segundo sistema de teleport.
* El cliente nunca elige `role` ni decide el inicio: el rol se deriva server-side de clase+spec y el inicio lo dispara el servidor cuando se cumplen condiciones.

#### **3. Roles (data-driven, derivados de clase+spec)**

| Clase + Spec | Rol |
|--------------|-----|
| Paladín Protector | **Tank** |
| Paladín Castigo | DPS |
| Cazador (Asalto/Puntería) | DPS |
| Clérigo Misericordia | **Heal** |
| Clérigo Cólera | DPS |

* Mapa `roleBySpec` en config (`SpecConfig` o `RoomConfig`); sin inventar roles ni permitir selección manual en MVP.
* **Roles auto (server):** Protector → `Tank`; Misericordia → `Heal`; cualquier otra spec o clase sin rol → `DPS` (default). El rol del jugador se recalcula si cambia spec (respec) mientras está en sala.
* **Composición (regla final):** en **sala matchmaking** se valida y muestra el objetivo 1/1/2 (máximo 1 Tank y 1 Heal por sala) como **información**, sin bloquear el inicio; en **party pre-armado** la composición no se valida. El inicio depende solo del ready-check de los presentes (mínimo 2 jugadores).

#### **4. Ventana de info de la dungeon (data-driven)**

* Panel/pestaña de la misma `MatchmakingUI` con datos reales desde configs existentes (nada hardcodeado):
  * **General**: Helada, 5 pisos, nivel por piso (P1 ~4 … P5 ~16), run individual o de sala.
  * **Enemigos por piso**: procedentes de `EnemyConfig` (plantillas por piso + variación).
  * **Jefes**: mini-jefe del piso 4 (Señor de la Escarcha) y **boss final (Jotunn)** disponibles en config de bosses.
  * **Loot de los 2 últimos jefes**:
    * **Señor de la Escarcha (piso 4)**: uniques (Espadón 2H + los 3 uniques frost existentes — pool de uniques decidido en ITEMS-04/06).
    * **Boss final (piso 5, Jotunn)**: cofre con 35% épica de tu clase (50% arma / 50% armadura) + 25% oro (40–80) — datos de `LootTables`/config del boss.
  * Si un dato no existe en config → placeholder "Próximamente" (nunca inventar contenido en la UI).

#### **5. UI (MatchmakingUI)**

* Nueva ventana en el hub (abierta al interactuar con el portal, y/o desde el menú):
  * Vista **Solo/Grupo**.
  * Vista **Crear Sala** (nombre opcional, toggle pública/privada, invitar por lista del lobby R9a.1).
  * Vista **Lista de salas** (públicas: líder, tamaño X/4, roles cubiertos, nombre).
  * Vista **Sala** (casillas 4 con rol + jugador + Listo, botones Salir / Empezar run del líder, mensajes de composición).
  * Vista **Info de dungeon** (pestaña/panel lateral con los datos de la sección 4).
* Estilo EST-13/Hearthbound Gold (tokens, Scale + UIAspectRatioConstraint, PC + móvil); referencias: ventana de party de EST-22 y diseño de ventanas (EST-10/11/12). Si el diseñador entrega un frame propio de matchmaking (EST futura), se implementa ese diseño; para el MVP el dev usa el patrón EST-13.

#### **6. Seguridad y autoridad**

* Solo en el hub; salas del mismo servidor; server-authoritative para roles, ready e inicio.
* El inicio automático lo valida el servidor (composición + todos ready + lugar en servidor reservado); un cliente no puede saltarse el ready-check ni iniciar sin composición.
* Anti-exploit: límite 4, una sala por jugador, unirse solo a salas públicas, invitaciones de R9a intactas, en la dungeon no hay matchmaking.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Elección Solo / Grupo**

* **GIVEN** un jugador en el hub interactúa con el portal.
* **WHEN** se abre la ventana de matchmaking.
* **THEN** ve las opciones **Solo** y **Grupo**.
* **AND** elegir Solo arranca la run individual con el flujo actual (sin sala).

#### **Escenario 2: Crear sala pública**

* **GIVEN** un jugador elige Grupo > Crear sala.
* **WHEN** confirma la sala (pública, con o sin nombre).
* **THEN** queda en una sala con él como líder y casillas vacías para 3 más.
* **AND** la sala aparece en la lista de salas públicas del servidor.

#### **Escenario 3: Crear sala privada**

* **GIVEN** el jugador crea una sala marcada como **privada**.
* **WHEN** confirma.
* **THEN** la sala no aparece en la lista pública.
* **AND** solo se entra por invitación (R9a.1).

#### **Escenario 4: Invitar y esperar**

* **GIVEN** una sala creada.
* **WHEN** el líder invita desde la lista del lobby o espera.
* **THEN** los invitados reciben el popup de R9a (60 s) y al aceptar entran a la sala.
* **AND** cualquiera del lobby puede unirse a una sala pública con lugar.

#### **Escenario 5: Unirse a una sala**

* **GIVEN** el jugador sin party/sala y salas públicas disponibles.
* **WHEN** selecciona una con lugar y confirma.
* **THEN** entra a la sala (miembro, no líder).
* **AND** si no hay listas o están llenas, recibe feedback claro.

#### **Escenario 6: Roles visibles y auto**

* **GIVEN** una sala con miembros.
* **WHEN** se ve la sala.
* **THEN** cada casilla muestra el rol del ocupante derivado automáticamente de su clase+spec.
* **AND** quien no es Tank ni Heal figura como **DPS** (default); nadie elige su rol.

#### **Escenario 6.1: Sala autocompletada con el party**

* **GIVEN** un jugador con un party ya armado (R9a) elige Grupo.
* **WHEN** abre su sala.
* **THEN** la sala muestra ya a los miembros de su party (casillas ocupadas, roles y estado).
* **AND** no tiene que volver a invitar a quienes ya lo acompañan.

#### **Escenario 7: Composición informativa (sala matchmaking)**

* **GIVEN** una sala pública/privada sin el objetivo 1/1/2 (falta tank, heal o dps).
* **WHEN** se ve la sala.
* **THEN** se muestra qué rol falta (objetivo 1/1/2, sin duplicar Tank/Heal).
* **AND** el inicio **no se bloquea** por composición ni por cantidad.

#### **Escenario 7.2: Party pre-armado sin validación**

* **GIVEN** una sala autocompletada desde un party existente.
* **WHEN** el líder intenta iniciar.
* **THEN** la composición no se valida.
* **AND** el inicio depende solo del ready-check de los presentes.

#### **Escenario 7.3: Inicio con 2 o 3 jugadores**

* **GIVEN** una sala con 2 o 3 jugadores (party o matchmaking).
* **WHEN** todos marcan Listo.
* **THEN** la run arranca con esa cantidad (mínimo 2).
* **AND** si queda 1 solo, ese jugador va en modo solo.

#### **Escenario 8: Ready-check**

* **GIVEN** una sala con composición cualquiera (2–4 jugadores).
* **WHEN** los miembros marcan Listo uno a uno.
* **THEN** su estado de ready se refleja en la sala.
* **AND** al quedar **todos los presentes ready**, la run arranca automáticamente.

#### **Escenario 9: Teleport grupal**

* **GIVEN** la run iniciada desde la sala.
* **WHEN** se dispara el inicio.
* **THEN** **toda la sala se teleporta al mismo servidor reservado** (misma run, `partyId`, piso 1 compartido).
* **AND** el flujo es el de R9a/PUBLICAR-02 (dungeon compartida, mismo seed).

#### **Escenario 10: Info de dungeon**

* **GIVEN** la ventana de matchmaking.
* **WHEN** se abre la pestaña de información.
* **THEN** el jugador ve: pisos y niveles, enemigos por piso, mini-jefe del piso 4, boss final (Jotunn) y el loot de los últimos 2 jefes.
* **AND** los datos salen de config sin contenido inventado (placeholder "Próximamente" si falta algo).

#### **Escenario 11: Salir de sala**

* **GIVEN** un miembro o líder en sala (antes de iniciar).
* **WHEN** usa "Salir de sala".
* **THEN** sale de la sala (R9a: migra líder si era el líder; disuelve si quedan 0).
* **AND** puede volver a crear/unirse a otra.

#### **Escenario 12: Anti-exploit y regresión**

* **GIVEN** un cliente manipulador.
* **WHEN** intenta unirse sin invitación a sala privada, entrar dos salas, arrancar sin ready/composición o cambiar su rol.
* **THEN** el servidor rechaza.
* **AND** el solo, R9a/R9a.1, teleport y dungeon compartida no tienen regresiones ni errores rojos.

---

### **Comportamiento Visual / Reglas de Negocio**

* La ventana de matchmaking es la puerta de entrada a la dungeon: decisión explícita de solo o grupo antes del teleport.
* Roles derivados de clase/spec; la composición 1/1/2 es **requisito** para iniciar (con mínimo T+H+DPS).
* Ready-check: el inicio es automático cuando todos están listos y la composición es válida (decisión cerrada).
* La información de la dungeon está disponible en la misma ventana para decidir con datos.
* Sin matchmaking aleatorio fuera del servidor (el GDD lo mantiene post-MVP): la lista de salas es del hub.

---

### **Alcance**

#### Incluye

* Ventana `MatchmakingUI` en el hub: Solo/Grupo, crear sala (pública/privada), lista de salas, sala con roles y ready, pestaña de info.
* Metadatos de sala sobre `PartyService` (isPublic, roomName, ready, roles, status).
* Remotes de sala nuevos; rol derivado de clase+spec (config).
* Composición obligatoria (T+H+DPS) + ready-check con inicio automático server-side.
* Inicio de run con el teleport grupal existente (R9a/PUBLICAR-02).
* Info de dungeon data-driven (pisos, enemigos, jefes, loot de los 2 últimos jefes).
* Verificación PC y móvil.

#### No incluye

* Matchmaking aleatorio/cross-server (post-MVP) ni matchmaking por MMR.
* Need/greed, trade, voice chat ni sistemas sociales nuevos.
* Cambios a R9a/R9a.1 (invitaciones 60 s, límite 4, dungeons compartida, threat, loot personal).
* Cambios al juego en solitario.
* Ready-check con countdown ni kick por "no listo" (post-MVP).

---

### **Definition of Done (DoD)**

* [ ] `MatchmakingUI` con Solo/Grupo, crear sala (pública/privada), lista de salas, sala (roles + ready) e info de dungeon.
* [ ] Roles derivados de clase+spec mediante config; **default DPS** cuando no califica como Tank ni Heal.
* [ ] Sala **autocompletada** con los miembros del party existente (sin re-invitar).
* [ ] Inicio permitido con **2–4 jugadores** con el ready-check de los presentes (mínimo 2; 1 solo = modo solo).
* [ ] En sala matchmaking la composición 1/1/2 se **muestra** (máx 1 Tank/1 Heal) **sin bloquear**; en party pre-armado **no se valida**.
* [ ] Ready-check: al quedar todos los presentes listos, el servidor inicia la run.
* [ ] Toda la sala se teleporta junta (misma run, `partyId`) con el flujo existente.
* [ ] Sala privada no aparece en la lista; invitaciones de R9a.1 intactas.
* [ ] Info de dungeon 100% data-driven (sin contenido inventado).
* [ ] Solo en el hub; anti-exploit (límite 4, una sala, server controla rol/ready/inicio).
* [ ] Solo y R9a/R9a.1 sin regresiones; sin errores rojos en PC y móvil.
* [ ] Se actualizan `PROJECT_ARCHITECTURE`, `DATA_SCHEMA` y el registro de la HU/RC al cerrar.
* [ ] Nota `R9a.2 completo` en el GDD después de la verificación, no antes.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).

---

### **Decisiones por defecto R9a.2**

| Tema | Default |
|------|---------|
| Modos | Solo (run individual) o Grupo (sala) |
| Sala | Pública (listada) o privada (solo invitación), con nombre opcional |
| Tamaño | 2–4 (límite R9a); **inicio permitido con ≥2** |
| Autocompletado | Al entrar en Grupo con party existente, la sala se carga con sus miembros (sin re-invitar) |
| Roles | Automáticos por clase+spec (config): Protector=Tank, Misericordia=Heal, resto=DPS |
| Composición | Objetivo 1/1/2 (máx 1 Tank/1 Heal) **informativo en salas matchmaking**; **sin validación en party pre-armado**; nunca bloquea el inicio |
| Inicio | Automático del servidor cuando todos los presentes están ready (mínimo 2) |
| Teleport | Reutiliza el flujo grupal R9a/PUBLICAR-02 (`partyId`) |
| Info dungeon | Data-driven desde EnemyConfig/LootTables/config de bosses |
| Loot mostrado | Mini-jefe piso 4 (uniques) + boss final (cofre 35% épica clase / 25% oro 40–80) según config |
| Responsabilidad de sala | Líder = dueño; reglas R9a (migrar líder, disolver en 0) |

---

### **Pendientes de confirmación**

* ~~Composición con 3 jugadores~~ **Resuelto (decisión PO 2026-09-22):** el inicio nunca se bloquea por composición ni cantidad (mínimo 2); en sala matchmaking la compo 1/1/2 es informativa y en party pre-armado no se valida.
* **Diseño de la ventana:** el dev implementará con el patrón EST-13/EST-22; si el diseñador quiere entregar un frame propio de matchmaking en Pencil, se crea una HU-ESTETICA y el dev la referencia.

---

### **Estimación (orientativa)**

3–4 sesiones del dev: MatchmakingUI (4 vistas), metadatos de sala en PartyService, remotes, roles/ready/composición, integración con teleport grupal e info data-driven + regresión solo/party.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-R9a.2: prelobby de matchmaking — Solo/Grupo, salas públicas/privadas, unirse/crear/invitar, roles 1/1/2 obligatorios, ready-check con inicio automático y ventana de info de dungeon data-driven; reutiliza party (R9a/R9a.1) y teleport grupal |
| 2026-09-22 | **Ajuste de reglas (decisión PO):** sala **autocompletada con el party existente** (sin re-invitar); **inicio permitido con 2–4** (mínimo 2, 1 solo = modo solo); **roles 100% automáticos** (Protector=Tank, Misericordia=Heal, resto=DPS); composición 1/1/2 **informativa en salas matchmaking** (máx 1 Tank/1 Heal) y **sin validación en party pre-armado** — el inicio depende solo del ready-check de los presentes |