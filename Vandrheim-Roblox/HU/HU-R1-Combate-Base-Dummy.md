## HU-R1: Pegar a un dummy (combate base)

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** Combate / R1  
**Prioridad:** Crítica  
**Estado:** Completada (implementada; documentada 2026-08-12)  
**Fase GDD:** R1  
**Depende de:** HU-R0 (hub, movimiento, cámara 3ª)

---

### **Narrativa (INVEST)**

**Como** jugador,  
**quiero** seleccionar un enemigo y hacerle daño con auto-attack,  
**para** validar el loop de combate server-side antes de skills, clases y mazmorra.

---

### **Descripción del Requerimiento / Contexto**

Segunda fase del plan (GDD §14). Prueba el feeling MMORPG de target + auto-attack con autoridad de servidor, sin skills ni progresión aún.

**Criterio de hecho global GDD:** "Matás dummy".

---

### **Especificaciones Técnicas / Contratos de API**

#### **Remotes / intenciones (cliente → servidor)**

| Nombre sugerido | Dirección | Payload | Notas |
|-----------------|-----------|---------|--------|
| `SetTarget` / `RequestTarget` | C→S | `target: Model?` o `targetId` | Cliente solo declara intención; server valida que sea Enemy válido |
| (opcional) clear target | C→S | `nil` | Deseleccionar |

#### **Replicación de estado (servidor → clientes)**

* HP del dummy y del jugador vía `NumberValue`, attributes, o réplica de servicio.
* Target actual del jugador (para UI local; no confiar en cliente para daño).

#### **CombatService (server)**

* Mantiene target actual por jugador (validado).
* Tick de auto-attack (~1.5 s) si hay target en rango melee.
* `ApplyDamage(target, amount)` solo en server.
* Al llegar a 0 HP: muerte dummy + respawn tras delay.

#### **Targeting (client)**

* **TAB:** enemigo válido más cercano; TAB sucesivo cicla al siguiente.
* **Click** en enemigo: set target (opcional además de TAB).
* Tag/atributo `Enemy` en dummies.

#### **Defaults de balance R1 (cerrados)**

| Tema | Default R1 |
|------|------------|
| Rango melee | 12 studs |
| Intervalo auto-attack | ~1.5 s |
| Daño | Fijo plano (ej. 10); sin stats de clase aún |
| HP dummy | 100 |
| HP jugador | 100 |
| Dummy pega al player | **No** (solo saco) |
| Fuera de rango | **Deja de atacar**; no chase del player en R1 |
| Muerte dummy | Despawn/ragdoll simple + **respawn 5 s** en el mismo sitio |

#### **Seguridad**

* Cliente **no** puede setear HP a 0 ni aplicar daño.
* Exploit básico: manipular valores en cliente no mata al dummy en server.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Dummy visible**

* **GIVEN** el jugador está en el hub (o zona de prueba)
* **WHEN** mira el área de combate de prueba
* **THEN** hay al menos 1 dummy visible con tag/atributo Enemy

#### **Escenario 2: TAB selecciona y cicla**

* **GIVEN** hay uno o más dummies válidos
* **WHEN** el jugador presiona TAB
* **THEN** el target es el enemigo válido más cercano
* **AND** TAB sucesivo cicla al siguiente válido

#### **Escenario 3: Click target**

* **GIVEN** un dummy es clickeable
* **WHEN** el jugador hace click en el dummy
* **THEN** queda seleccionado como target

#### **Escenario 4: Auto-attack en rango**

* **GIVEN** el jugador tiene target y está a ≤ 12 studs
* **WHEN** no cancela el target
* **THEN** el personaje auto-ataca en ticks de ~1.5 s sin spamear click
* **AND** el HP del dummy baja en el **servidor**

#### **Escenario 5: Fuera de rango**

* **GIVEN** el jugador tiene target a > 12 studs
* **WHEN** corre el tick de auto-attack
* **THEN** no aplica daño
* **AND** no hay chase automático del player en R1
* **AND** al volver al rango, reanuda auto-attack

#### **Escenario 6: Muerte y respawn**

* **GIVEN** el HP del dummy llega a 0
* **WHEN** el server procesa la muerte
* **THEN** el dummy muere (despawn/ragdoll simple)
* **AND** respawnea a los ~5 s en el mismo sitio con HP lleno

#### **Escenario 7: UI mínima**

* **GIVEN** el jugador está en combate de prueba
* **WHEN** tiene o no target
* **THEN** ve barra de HP propia
* **AND** con target, ve frame (nombre + HP del target)

#### **Escenario 8: Anti-exploit HP**

* **GIVEN** un cliente malicioso intenta setear HP del dummy a 0
* **WHEN** solo modifica estado local/cliente
* **THEN** el dummy no muere en el servidor

#### **Escenario 9 (opcional): Coherencia 2 players**

* **GIVEN** 2 jugadores atacan el mismo dummy
* **WHEN** el HP baja
* **THEN** ambos ven el HP del dummy de forma coherente (misma fuente server)

#### **Escenario 10: Estabilidad**

* **GIVEN** el loop atacar → matar → respawn varias veces
* **WHEN** se revisa el output
* **THEN** no hay errores rojos

---

### **Comportamiento Visual e Interfaz (UI/UX) / Reglas de Negocio**

* **HUD:** PlayerHP + TargetFrame (nombre + HP); UI mínima, usable en PC.
* **Feedback de hit:** suficiente para validar daño (número o flash); polish no bloqueante.
* **Dummy:** modelo simple; no IA de persecución en R1.
* **Autoridad:** daño, muerte y respawn solo server.

---

### **Alcance**

#### Incluye

* 1+ dummy en hub / zona de prueba
* HP dummy y jugador (server)
* TAB + click target
* Auto-attack server-tick en rango melee
* UI HP propia + target frame
* Muerte + respawn dummy
* Cliente solo intenciones; daño server

#### No incluye

* Skills, maná, GCD, barra de 4
* Clases / creación de PJ / DataStore
* Inventario, loot, threat real de tank
* Dungeon / teleport
* Múltiples tipos de enemigo / IA chase compleja
* Daño del dummy al jugador

---

### **Definition of Done (DoD)**

* [x] Play Solo: matar dummy varias veces (atacar → matar → respawn)
* [ ] (Opcional) 2 players: HP del mismo dummy coherente
* [x] Documentación HU-R1 en repo
* [x] Nota de estado R1 en GDD
* [x] Exploit básico: cliente no setea HP a 0 en server
* [x] Sin errores rojos en el loop de prueba

---

### **Checklist Studio (referencia dev)**

* [ ] Enemy / Dummy model + tag `Enemy`
* [ ] CombatService (server): target, tick auto-attack, ApplyDamage
* [ ] Targeting (client): TAB + click → Remote SetTarget
* [ ] Replicar HP para UI
* [ ] HUD: PlayerHP + TargetFrame
* [ ] Respawn dummy
* [ ] Probar exploit básico HP

---

### **Estimación (orientativa)**

1–2 sesiones si R0 ya está estable.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-12 | Formalización desde brief de producto del equipo |
| 2026-08-12 | Defaults cerrados: rango 12, tick 1.5s, fuera de rango = deja de atacar, dummy no pega |
| 2026-08-12 | Marcada completada al pasar el equipo a R2 |
