## HU-R6.7: Sistema de animaciones para enemigos (idle, walk, attack, special) por familia

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** Enemigos / Animaciones / R6.7  
**Prioridad:** Alta  
**Estado:** Lista para implementar  
**Tipo:** Framework data-driven de animaciones de enemigos (tarea del dev)  
**Fase GDD:** R6.7 (posterior a R6.6; no modifica IA, daño ni loot)  
**Depende de:** HU-R6a (EnemyService/IA), HU-R7 (boss special), HU-ESTETICA-02 (modelos por familia), ASSETS_POLICY (animaciones de Library/registro)  
**Objetivo clave:** dejar **todo el código listo** para que el equipo reemplace modelos y animaciones **solo cambiando IDs en config** (sin tocar código)

---

### **Narrativa (INVEST)**

**Como** equipo,  
**quiero** un sistema server-side que reproduzca en cada enemigo las animaciones de idle, walk, attack y special según su **familia de cuerpo**,  
**para** que al reemplazar modelos y animaciones por config, el comportamiento visual funcione sin cambios de código.

**Como** jugador,  
**quiero** que cada enemigo se anime acorde a su tipo (bestia, insecto, humanoide, constructo, espectro),  
**para** que el combate se lea y se sienta creíble.

---

### **Descripción del Requerimiento / Contexto**

Los enemigos actuales se mueven con `Humanoid` (IA de `EnemyService`) pero **no reproducen animaciones propias**: ni idle, ni walk, ni attack. Los modelos de EST-02 se organizan por familias de cuerpo; una misma animación puede compartirse entre enemigos de la misma familia, pero **no entre familias distintas** (un lobo no comparte animación con un humanoide; un espectro flotante no comparte con un gólem).

Esta HU construye el **framework**:

* Config por **familia** con 4 slots: `idle`, `walk`, `attack`, `specialAttack`.
* Cada template de `EnemyConfig` declara su familia (`animationFamily`).
* Un servicio server-side enlaza las pistas al `Humanoid` del enemigo y las reproduce según estado (idle/walk), ataque (IA) y special (mini-boss/boss).
* **Todo data-driven**: cambiar un ID de animación o una familia es editar config; el código no cambia.

Las animaciones reales (IDs de Library o subidas por el equipo para rigs custom) las reemplaza el equipo después; el sistema **no debe romper** si un slot está vacío (fallback sin animación = comportamiento actual).

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Familias de cuerpo (de HU-ESTETICA-02)**

| Familia | Rig | Enemigos | Se comparte entre |
|---------|-----|----------|-------------------|
| `quadruped` | 4 patas | `helada_frost_wolf`, `helada_frost_wolf_elite` | Lobos normales/élite |
| `insectoid` | 6 patas | `helada_ice_mite`, `helada_ice_mite_elite` | Ácaros normales/élite |
| `humanoid` | Bípedo humano | `helada_frost_archer`, `helada_frost_knight` (+élites), `miniboss_frost_troll`, `miniboss_frost_lord`, boss `helada_frostwarden` | Todos los humanoides |
| `construct` | Bípedo macizo | `miniboss_ice_golem` | Gólem |
| `floating` | Sin piernas (levita) | `miniboss_blizzard_wraith`, `helada_ice_elemental`, `helada_ice_elemental_elite` | Espectro + elementales |

* Las élites **heredan** la familia de su base; no necesitan campo propio (pueden sobrescribirlo si el PM lo pide).
* El boss `helada_frostwarden` usa `humanoid` por default (ajustable).

#### **2. EnemyAnimationConfig (ReplicatedStorage.Config — ModuleScript)**

```luau
local EnemyAnimationConfig = {
  families = {
    quadruped = {
      idle = "rbxassetid://...",       -- o nil → sin animación (movimiento base)
      walk = "rbxassetid://...",
      attack = "rbxassetid://...",
      specialAttack = "rbxassetid://...", -- opcional (miniboss/boss)
    },
    insectoid = { ... },
    humanoid = { ... },
    construct = { ... },
    floating = { ... },
  },
}

function EnemyAnimationConfig.GetFamily(familyId) end
function EnemyAnimationConfig.GetAnimationId(familyId, animSlot) end
return EnemyAnimationConfig
```

* Los IDs viven aquí (data-driven). Si un slot es `nil`/vacío → fallback: no reproducir esa animación (el enemigo se mueve como hoy).
* Familia inexistente → fallback a `humanoid` (default del sistema).
* Convenciones del proyecto: `task.wait()`, camelCase/PascalCase, sin `wait()`.

#### **3. EnemyConfig: campo `animationFamily`**

Cada template de enemigo agrega:

```luau
["helada_frost_wolf"] = {
  -- ...
  animationFamily = "quadruped",
}
```

* Se agrega a las 14 plantillas (7 bases + 5 élites + 2 existentes) y al boss.
* Élites: si no se define, heredan la familia de su base (helper `GetFamily(templateId)` resuelve: campo propio → familia de la base → default `humanoid`).

#### **4. EnemyAnimationService (ServerScriptService.Services — ModuleScript)**

API pública:

| Función | Responsabilidad |
|---------|-----------------|
| `BindAnimations(enemy, template)` | Al spawn: cargar tracks de la familia y conectar estados |
| `PlayAttack(enemy)` | Reproducir `attack` (one-shot) al golpear |
| `PlaySpecial(enemy)` | Reproducir `specialAttack` (one-shot) para miniboss/boss |
| `ClearAnimations(enemy)` | Detener/limpiar tracks al morir o despawn |

Comportamiento:

* **Idle/Walk:** con `Humanoid.Running` (o `StateChanged`): `speed > 0` → reproducir `walk` en loop con prioridad `Movement`; si no, `idle` en loop con prioridad `Idle`. Si falta la animación, no se reproduce (el movimiento base del Humanoid continúa).
* **Attack:** se reproduce una vez (prioridad `Action`) cuando la IA ejecuta un golpe válido. Al terminar (o por timeout ≈ `attackInterval`), vuelve a idle/walk. Si llega otro ataque, se reinicia el track (sin acumular).
* **Special:** una vez (prioridad `Action`, puede interrumpir attack) cuando el mini-boss/boss dispara su special (R7: `GlacialImpact` / telegraph). Si no hay `specialAttack`, no se reproduce nada.
* **Servidor autoritativo:** las pistas se cargan y reproducen **server-side** sobre el `Humanoid` del enemigo (la replicación de animaciones de Humanoid las muestra a todos los clientes); el cliente no decide.
* **Limpieza:** al morir/despawn (`Dead=true`, `Parent=nil`), detener tracks y liberar conexiones.
* **Robustez:** si el modelo no tiene `Humanoid` o el ID es inválido → warning controlado y sin error; el enemigo sigue funcionando (IA/daño intactos).

#### **5. Hooks en el código existente**

* **`EnemyService.SpawnEnemy`:** tras crear el modelo, llamar `EnemyAnimationService.BindAnimations(enemy, template)`.
* **IA melee (`runMeleeAI`):** en el momento de aplicar daño (`damagePlayer`), llamar `PlayAttack(enemy)`.
* **IA ranged (`runRangedAI`):** al disparar (aplicar daño a distancia), llamar `PlayAttack(enemy)`.
* **Boss R7 (`glacial_impact`):** al iniciar el special, llamar `PlaySpecial(enemy)` (el timing del telegraph ya lo maneja el boss).
* **`EnemyService` (muerte/despawn):** `ClearAnimations(enemy)` junto con la limpieza actual.

#### **6. Reemplazo por config (objetivo del usuario)**

Para cambiar modelos o animaciones **sin tocar código**:

* **Modelo:** cambiar `modelId` en `EnemyConfig` (ya definido por EST-02).
* **Animaciones:** cambiar los IDs en `EnemyAnimationConfig.families.<familia>.<slot>`.
* **Familia:** cambiar `animationFamily` en el template (solo si el nuevo modelo cambia de rig).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Bind al spawn**

* **GIVEN** un enemigo spawneado con `animationFamily` definida
* **WHEN** `EnemyService.SpawnEnemy` lo crea
* **THEN** el servicio enlaza sus tracks de familia
* **AND** no produce errores en el output

#### **Escenario 2: Idle/Walk por estado**

* **GIVEN** un enemigo con `idle` y `walk` configurados
* **WHEN** está quieto / persigue al jugador
* **THEN** reproduce idle cuando está quieto y walk cuando se mueve
* **AND** no mezcla ambos tracks

#### **Escenario 3: Attack al golpear**

* **GIVEN** un enemigo melee/ranged
* **WHEN** su IA aplica daño al jugador
* **THEN** reproduce `attack` (one-shot)
* **AND** el daño no cambia respecto a antes de la HU

#### **Escenario 4: Special en miniboss/boss**

* **GIVEN** un enemigo con `specialAttack` configurado
* **WHEN** dispara su special (ej. `GlacialImpact` del boss R7)
* **THEN** reproduce `specialAttack`
* **AND** puede interrumpir el attack sin quedarse atascado

#### **Escenario 5: Familias distintas**

* **GIVEN** un lobo (`quadruped`), un ácaro (`insectoid`) y un caballero (`humanoid`)
* **WHEN** todos están idle/caminando/atacando
* **THEN** cada uno usa la animación de **su familia** (no comparten entre familias)

#### **Escenario 6: Compartir dentro de la familia**

* **GIVEN** dos enemigos de la misma familia (ej. lobo y lobo élite)
* **WHEN** ambos se animan
* **THEN** usan la misma animación de familia (no se necesitan IDs duplicados)

#### **Escenario 7: Sin animación configurada**

* **GIVEN** un slot vacío (por ejemplo sin `attack`)
* **WHEN** el enemigo ataca
* **THEN** no reproduce nada, no lanza error
* **AND** el movimiento base del Humanoid continúa

#### **Escenario 8: Reemplazo por config**

* **GIVEN** un ID de animación cualquiera en la familia
* **WHEN** se cambia en `EnemyAnimationConfig`
* **THEN** el enemigo usa la nueva animación sin modificar código
* **AND** lo mismo aplica a `modelId` en `EnemyConfig`

#### **Escenario 9: Muerte/despawn**

* **GIVEN** un enemigo con tracks activos
* **WHEN** muere o se despawna
* **THEN** los tracks se detienen y las conexiones se limpian
* **AND** no quedan sonidos/tracks huérfanos

#### **Escenario 10: Replicación**

* **GIVEN** un servidor con jugadores conectados
* **WHEN** un enemigo se anima
* **THEN** todos los clientes ven la misma animación
* **AND** no hay desincronización con el daño/IA

#### **Escenario 11: Anti-exploit / robustez**

* **GIVEN** un modelo sin Humanoid o un ID inválido
* **WHEN** se intenta animar
* **THEN** se registra warning controlado
* **AND** IA, daño y loot siguen funcionando

---

### **Comportamiento Visual / Reglas de Negocio**

* La animación es cosmética: no modifica IA, daño, XP, loot ni timing de ataques.
* Las prioridades: `Idle` (idle), `Movement` (walk), `Action` (attack/special).
* Un ataque no debe dejar al enemigo "congelado" al terminar; vuelve a idle/walk.
* Las animaciones vienen de Library (R15 estándar) o subidas por el equipo para rigs custom; se registran en `ASSETS_REGISTRY`. El sistema no crea animaciones.
* El modelo custom debe tener `Humanoid` + `Animator` (Humanoid lo crea) y nombres de huesos compatibles con las animaciones que se le asignen (responsabilidad de quien suba las animaciones).

---

### **Alcance**

#### Incluye

* `EnemyAnimationConfig` con 5 familias y 4 slots cada una.
* Campo `animationFamily` en `EnemyConfig` (+ helper de herencia para élites y default `humanoid`).
* `EnemyAnimationService` con Bind/PlayAttack/PlaySpecial/Clear.
* Hooks en `EnemyService` (spawn, IA melee/ranged, muerte) y en el special del boss R7.
* Fallbacks y robustez (slots vacíos, familia inexistente, modelo sin Humanoid).
* Replicación server-side de las animaciones.
* Registro de IDs reales cuando el equipo los provea (los slots quedan `nil` o placeholder hasta entonces).

#### No incluye

* Crear/riggear animaciones (política: solo Library o subidas por el equipo).
* Crear los modelos (EST-02, diseñador).
* Cambios a IA, daño, rango, attackInterval, XP o loot.
* Animaciones de jugador (R6.6 ya cubre).
* VFX/SFX de ataques.
* Pathfinding o movimiento nuevo.

---

### **Definition of Done (DoD)**

* [ ] `EnemyAnimationConfig` con las 5 familias y slots idle/walk/attack/specialAttack.
* [ ] `animationFamily` en todas las plantillas de `EnemyConfig` (élites heredan; boss `humanoid`).
* [ ] El servicio reproduce idle/walk por estado del Humanoid.
* [ ] Attack se reproduce al golpear (melee y ranged) sin cambiar daño.
* [ ] Special se reproduce en miniboss/boss (incluido `GlacialImpact` de R7).
* [ ] Familias distintas usan animaciones distintas; misma familia comparte.
* [ ] Slots vacíos → fallback sin error.
* [ ] Reemplazo de animaciones/modelos 100% por config (sin tocar código).
* [ ] Muerte/despawn limpian tracks y conexiones.
* [ ] Las animaciones se ven igual en todos los clientes.
* [ ] Modelo sin Humanoid o ID inválido → warning controlado, sin romper IA.
* [ ] Sin errores rojos en spawn → perseguir → atacar → morir.
* [ ] Animaciones reales registradas en `ASSETS_REGISTRY` cuando se incorporen.
* [ ] Nota `R6.7 completo` en GDD al verificar la implementación.

---

### **Estimación (orientativa)**

1–2 sesiones: config de familias, servicio con estados, hooks en IA/boss y pruebas con los modelos existentes (lobo/ácaro) + placeholders.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-26 | Creación de HU-R6.7: sistema de animaciones por familia (idle/walk/attack/special) para enemigos; 100% data-driven para reemplazo por config |