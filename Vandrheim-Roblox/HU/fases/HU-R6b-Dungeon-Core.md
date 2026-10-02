## HU-R6b: Dungeon — Run core (teleport + reserved server, instancia, run, exit)

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** Mazmorra / R6 (parte b — core)  
**Prioridad:** Crítica  
**Estado:** Completada (implementada; reporte equipo 2026-08-22)  
**Fase GDD:** R6 (parte b — depende de R6a)  
**Depende de:** **HU-R6a** (enemigos, pisos, XP, respawn, loot listos), R0 (Places + teleport base), R2 (profile)

---

### **Narrativa (INVEST)**

**Como** jugador,  
**quiero** entrar por el portal del pueblo a una run de 5 pisos (instancia propia), avanzar piso a piso con lo preparado en R6a, y salir cuando quiera conservando lo ganado,  
**para** cerrar el loop central: pueblo → portal → mazmorra → recompensa → pueblo.

---

### **Descripción del Requerimiento / Contexto**

Segunda mitad de R6. Une los componentes de **R6a** dentro de una **run real**: `DungeonService` con teleport a **ReservedServer** (instancia propia), teleport data, secuencia de pisos 1–5, completar la run, **exit/abandon = fin de run** y vuelta al pueblo con persistencia de lo ganado.

**Criterio de hecho global GDD (R6):** "Run completa solo" (sin boss final — R7).

---

### **Especificaciones Técnicas / Contratos de API**

#### **Flujo**

```text
Pueblo (Place_Hub)
  → interactuar portal → DungeonService.StartRun(player)
  → TeleportService.TeleportToPrivateServer (Place_Dungeon, ReservedServer)
     con teleport data: { runId, floorSeed, dungeonDef="Helada", partyId(nil R6) }
  → Piso 1 … Piso 5 (usa R6a: enemigos, layout, XP, loot)
  → Completar (llegar a la boss room del piso 5) → volver al pueblo con lo ganado
  → Salir / desconectar = run terminada (lo ganado persiste; el piso no se reanuda)
```

#### **DungeonService (server)**

| Función | Detalle |
|---------|---------|
| `StartRun(player)` | Genera `runId` + `floorSeed` (server); teleport a ReservedServer |
| `JoinRun` (en Place_Dungeon) | Lee teleport data; inicializa piso 1 con el seed |
| `CompleteFloor` | Al limpiar/activar el paso del piso → genera el siguiente |
| `CompleteRun` | Al llegar a la boss room del piso 5 → run terminada → vuelta al pueblo |
| `ExitRun` / `Abandon` | Fin de run; teleport de vuelta al pueblo; guarda lo ya obtenido |

* **ReservedServer por run:** 1 jugador en R6 (party-ready; party real = R9).
* **Teleport data** (server): `runId`, `floorSeed`, `dungeonDef`, `partyId`.
* **Exit/abandon:** botón en HUD + salir del Place = run terminada; **no** se reanuda el piso a medias; lo ya ganado (XP, loot entregado, oro) persiste vía DataStore (R2).

#### **Secuencia de pisos**

* Piso 1 → 2 → 3 → 4 → 5 (niveles de contenido de R6a: ~4/7/10/13/16).
* Mini-boss en pisos 1–4; piso 5 boss room (sala lista; **boss + cofre = R7**).
* `floorSeed` fija el layout del piso (R6a); el server controla el avance (cliente no salta pisos).

#### **Persistencia de la run**

* **No se guarda el progreso de piso** a mitad (GDD §2.7: salir = termina la run).
* **Sí persisten** XP, loot entregado y oro obtenidos en la run (DataStore, R2/R4/R5).
* Rejoin tras salir: el PJ vuelve al pueblo con su progresión acumulada.

#### **Remotes / intenciones**

| Remote | Dir | Payload | Validación server |
|--------|-----|---------|-------------------|
| `RequestEnterDungeon` | C→S | — | En hub, con PJ activo; no en run |
| `RequestAbandonRun` | C→S | — | En run; fin + vuelta al pueblo |
| `RequestCompleteRun` | S | — | Server al llegar a la boss room del piso 5 |

#### **UI**

* **Portal:** interactuar (proximidad + tecla/click) → confirmación → teleport. El marcador R0 se activa.
* **HUD dungeon:** piso actual (ej. "Piso 2/5"), botón **Abandonar run** (confirmación fuerte: no se reanuda), aviso de muerte/respawn (R6a).
* **Recompensa:** ventana existente (R4) al matar; level-up flash (R6a).
* **Feedback de salir:** aviso de que la run termina (lo ganado se conserva).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Entrar por el portal**

* **GIVEN** un jugador con PJ activo en el hub
* **WHEN** interactúa el portal y confirma
* **THEN** se teleporta a una instancia propia (ReservedServer) del Place_Dungeon
* **AND** el teleport data incluye runId y floorSeed (server)

#### **Escenario 2: Instancia independiente**

* **GIVEN** dos jugadores entran al dungeon
* **WHEN** ambos entran por el portal
* **THEN** cada uno está en su propia run (no se ven ni interfieren)

#### **Escenario 3: Piso 1 con enemigos (integra R6a)**

* **GIVEN** la run iniciada
* **WHEN** el jugador explora el piso 1
* **THEN** hay enemigos del nivel del piso (~4) que atacan (IA R6a)
* **AND** mueren con daño server y entregan XP/loot/oro (R6a/R4/R5)

#### **Escenario 4: Avanzar de piso**

* **GIVEN** el jugador derrota a enemigos y mini-boss del piso
* **WHEN** el server completa el piso
* **THEN** se abre el paso al siguiente piso
* **AND** el HUD muestra el piso nuevo (Piso 2/5…)

#### **Escenario 5: Muerte y respawn en la run**

* **GIVEN** el jugador muere en un piso
* **WHEN** el server procesa la muerte (R6a)
* **THEN** respawnea en la entrada del piso actual con HP/MP llenos
* **AND** sin pérdida de XP ni oro (default)

#### **Escenario 6: Completar la run**

* **GIVEN** el jugador llega a la boss room del piso 5 (sin boss en R6)
* **WHEN** completa la run
* **THEN** vuelve al pueblo con lo ganado (XP/loot/oro)
* **AND** la run se da por terminada

#### **Escenario 7: Abandonar = fin de run**

* **GIVEN** el jugador está en medio de la run
* **WHEN** usa "Abandonar run" o sale del Place
* **THEN** la run termina (no se reanuda a mitad)
* **AND** XP/loot/oro ya obtenidos persisten
* **AND** vuelve al pueblo

#### **Escenario 8: Persistencia tras salir/rejoin**

* **GIVEN** el jugador salió a mitad de run con XP/loot/oro ganados
* **WHEN** vuelve a entrar al juego
* **THEN** su progresión acumulada se mantiene (nivel, inventario, oro)
* **AND** la run anterior no se reanuda

#### **Escenario 9: Anti-exploit y estabilidad**

* **GIVEN** un cliente intenta saltar de piso o spawnear en piso 5
* **WHEN** solo manipula estado local
* **THEN** el server rechaza (avance y seeds los controla el server)
* **AND** una run completa de principio a fin no produce errores rojos

---

### **Comportamiento Visual e Interfaz (UI/UX) / Reglas de Negocio**

* **Portal:** claro y destacado en el hub; confirmación antes de entrar.
* **HUD dungeon:** piso actual + Abandonar (confirmación: la run no se reanuda).
* **Salir del Place = run terminada:** aviso informativo (no sorpresa; ya se conserva lo ganado).
* **Muerte:** respawn inmediato en la entrada del piso (no penaliza) — R6a.
* Estética del dungeon: kit Helada (paralelo HU-ASSETS).

---

### **Alcance**

#### Incluye

* DungeonService: StartRun/JoinRun/CompleteFloor/CompleteRun/ExitRun/Abandon
* Teleport a ReservedServer por run + teleport data (runId, floorSeed, dungeonDef, partyId)
* Instancia independiente (1 jugador; party-ready para R9)
* Secuencia de pisos 1–5 usando R6a (enemigos, layout, XP, respawn, loot)
* Completar run (boss room piso 5, sin boss) y vuelta al pueblo
* Exit/abandon = fin de run; lo ganado persiste (DataStore)
* HUD dungeon (piso + Abandonar) y portal funcional

#### No incluye

* Boss final piso 5 + cofre + uniques (R7)
* Party de amigos (R9); matchmaking (post-MVP)
* Reanudar run a mitad (GDD: no)
* Más biomas (post-MVP)
* Threat real / IA compleja (R9)
* Contenido de R6a (se consume tal cual)

---

### **Definition of Done (DoD)**

* [ ] Play Solo: pueblo → portal → run de 5 pisos → volver con loot/XP/oro
* [ ] 2 jugadores: runs independientes (cada uno en su instancia)
* [ ] Pisos 1–5 en secuencia (R6a integrado); completar la run llega a la boss room
* [ ] Abandonar/salir = fin de run; lo ganado persiste tras rejoin
* [ ] Cliente no puede saltar pisos
* [ ] Run completa sin errores rojos
* [ ] Nota "R6 completo" en GDD

---

### **Checklist Studio (referencia dev)**

* [ ] `DungeonService` (server): start/join/complete floor/complete run/exit/abandon
* [ ] Teleport a ReservedServer por run + teleport data
* [ ] Inicialización del piso 1 desde el seed (consumir R6a)
* [ ] Secuencia de pisos y boss room final (sin boss)
* [ ] Exit/abandon + vuelta al pueblo + persistencia de lo ganado
* [ ] HUD dungeon (piso + Abandonar con confirmación)
* [ ] Portal funcional en el hub (marcador R0 activado)
* [ ] Anti-exploit: avance controlado por server

---

### **Decisiones por defecto R6b (si no se cambian)**

| Tema | Default |
|------|---------|
| Instancia | 1 jugador por run (ReservedServer); party-ready |
| Teleport data | `runId`, `floorSeed`, `dungeonDef`, `partyId` |
| Completar run | Llegar a la boss room del piso 5 (sin boss en R6) |
| Exit/abandon | Fin de run; lo ganado persiste; piso no se reanuda |
| Avance de piso | Controlado por server (cliente no salta) |
| Respawn | Entrada del piso actual (R6a), sin pérdida |

---

### **Estimación (orientativa)**

3–4 sesiones.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-12 | Split de HU-R6 en R6a + R6b; esta es la parte core (depende de R6a) |
| 2026-08-22 | Marcada completada según reporte del equipo |
