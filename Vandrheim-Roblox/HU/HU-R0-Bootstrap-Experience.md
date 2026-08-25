## HU-R0: Bootstrap Experience (hub + 2 Places)

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** Fundación / R0  
**Prioridad:** Crítica  
**Estado:** Completada (implementada por dev; documentada 2026-08-12)  
**Fase GDD:** R0  
**ID técnico dev:** rc001  

---

### **Narrativa (INVEST)**

**Como** jugador,  
**quiero** aparecer en el pueblo de Vandrheim con mi avatar y moverme en 3ª persona,  
**para** sentir que el juego arrancó y tener base para combate, menús y portal a mazmorra.

---

### **Descripción del Requerimiento / Contexto**

Primera fase del plan de desarrollo (GDD §14). Deja la Experience con 2 Places, estructura de carpetas del GDD, hub mínimo navegable y cámara 3ª tipo MMORPG.

**Criterio de hecho global GDD:** "Caminás por el pueblo".

**Dependencias:** ninguna (fase inicial).

---

### **Especificaciones Técnicas / Contratos de API**

N/A (sin red de combate ni DataStore real en esta HU).

**Estructura esperada (GDD §12):**

```text
ReplicatedStorage/
  Shared/     -- enums, net contracts, utils
  Config/     -- ClassConfig, ItemRarity, BindType (seed)
ServerScriptService/
  Services/   -- stubs
  Data/       -- stub
StarterPlayerScripts/
  -- cámara 3ª MMORPG + input
StarterGui/
  -- vacío o mínimo
```

**Places:**

| Place | Rol R0 |
|-------|--------|
| Place_Hub | Pueblo: spawn, blockout, portal marker (sin teleport) |
| Place_Dungeon | Stub vacío con spawn |

**Seed Config (mínimo):**

- `ClassConfig`: Paladín, Cazador, Clérigo (specs + stats base)
- `ItemRarity`: Blanco, Verde, Azul, Morado
- `BindType`: Bind on Equip (flag desde día 1)

**Convenciones:**

- `task.wait` / `task.spawn` (prohibido `wait()`)
- UI con Scale + UIAspectRatioConstraint si hay UI

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Spawn en hub**

* **GIVEN** el jugador entra a la Experience (Play Solo o join)
* **WHEN** carga el Place_Hub
* **THEN** spawnea en el hub
* **AND** se ve el avatar R15 del usuario (skin de Roblox)
* **AND** no hay errores rojos en output

#### **Escenario 2: Movimiento y cámara MMORPG**

* **GIVEN** el jugador está en el hub
* **WHEN** usa WASD y mueve el mouse
* **THEN** la cámara 3ª persona rota y el personaje camina/salta
* **AND** no cae al vacío en el blockout del hub

#### **Escenario 3: Places y estructura**

* **GIVEN** la Experience está configurada
* **WHEN** se inspecciona en Studio
* **THEN** existe Place_Dungeon (aunque solo tenga spawn vacío)
* **AND** existen las carpetas base del GDD
* **AND** los módulos compartidos son copiables/packageables entre Places

#### **Escenario 4 (opcional): Presencia multiplayer en hub**

* **GIVEN** 2 jugadores en el mismo servidor de hub
* **WHEN** ambos spawnean
* **THEN** se ven entre sí

---

### **Comportamiento Visual e Interfaz (UI/UX) / Reglas de Negocio**

* **Hub blockout:** suelo, spawn, 2–3 props, marcador de portal (sin teleport real).
* **Cámara:** 3ª persona tipo MMORPG (no first-person, no shift-lock obligatorio).
* **Avatar:** R15 del jugador; sin editor de apariencia propio.
* **Sin UI RPG** obligatoria en R0 (menús de clase/inventario fuera de alcance).

---

### **Alcance**

#### Incluye

* Experience con Place_Hub + Place_Dungeon
* Carpetas GDD + seed Config
* Spawn hub, R15, cámara 3ª, movimiento walk/jump
* Bootstrap server + client sin errores
* Hub mínimo navegable + portal marker

#### No incluye

* Creación de personaje / slots
* Combate, TAB, skills
* DataStore real
* Teleport a dungeon / reserved servers
* NPCs funcionales, inventario, UI de RPG

---

### **Definition of Done (DoD)**

* [x] Probado en Studio (Play Solo): caminar por el pueblo
* [ ] Probado con 2 jugadores en hub (opcional recomendado)
* [x] Documentación HU-R0 en repo
* [x] Nota de estado R0 en GDD
* [x] Sin errores rojos en output al entrar al hub
* [x] Base lista para R1 (dummy/combate) y R2 (slots/persistencia)

---

### **Estimación (orientativa)**

1–3 sesiones (hub blockout simple).

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-12 | Documentación formal desde requerimiento técnico rc001 del dev |
| 2026-08-12 | Marcada completada al pasar el equipo a R2 |
