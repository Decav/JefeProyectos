## HU-R6.8: VFX básico de combate — proyectiles ranged, visual de skills, números de daño y muerte de enemigos

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** Combate / VFX / R6.8  
**Prioridad:** Alta  
**Estado:** Completada (implementada; reporte equipo 2026-08-26)  
**Tipo:** Feedback visual de combate (básico, sin assets externos)  
**Fase GDD:** R6.8 (posterior a R6.7; no modifica daño, timing ni IA)  
**Depende de:** HU-R1 (CombatService), HU-R3 (SkillService), HU-R6a (EnemyService/IA ranged), HU-R6.6 (animaciones de combate), R3 (AoeCastVisual existente)  
**Componentes observados:** `ServerScriptService.Services.CombatService` (ApplyDamage), `SkillService` (tryCastInstant/Heal, AoeCastVisual), `EnemyService` (runRangedAI, damagePlayer, hookEnemyDeath), `StarterGui.SkillBar.SkillBarClient` (AoeCastVisual)

---

### **Narrativa (INVEST)**

**Como** jugador,  
**quiero** ver golpes, proyectiles, números de daño y la muerte de los enemigos con feedback visual,  
**para** que el combate se sienta contundente y se entienda qué está pasando.

**Como** equipo,  
**quiero** un sistema de VFX básico, data-driven y sin assets externos,  
**para** mejorar el feel sin depender de paquetes de partículas y poder iterar en R9.

---

### **Descripción del Requerimiento / Contexto**

Estado actual verificado:

* Las skills **Instant** aplican daño sin ningún visual sobre el objetivo (solo el GroundAoE tiene indicador mediante `AoeCastVisual`).
* El auto-attack del jugador no muestra golpe ni número de daño.
* Los enemigos **ranged** "disparan" aplicando daño a distancia, pero **no se ve ningún proyectil**.
* El daño que recibe el jugador no tiene feedback visual (solo baja la barra del HUD).
* Las curaciones (Heal) no muestran número ni efecto.
* Al morir, los enemigos desaparecen sin feedback (solo `Parent=nil` tras un delay).

Esta HU agrega VFX **básico y puramente visual**:

1. Proyectiles visibles para enemigos ranged.
2. Efecto de golpe al aplicar daño de skills Instant y auto-attack.
3. Números de daño flotantes (daño recibido/recibido por el enemigo, críticos y curaciones).
4. Efecto de muerte de enemigos (fade/burst breve).

**No cambia** daño, timing, IA, cooldowns ni loot. Los efectos se disparan desde el servidor (autoridad) y se reproducen en todos los clientes. Sin assets externos: se usan partes Neon/primitivas, `Beam`/`Trail` simples y `BillboardGui`; configurables en un módulo.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. VFXConfig (ReplicatedStorage.Config — ModuleScript)**

```luau
local VFXConfig = {
  damageNumbers = {
    enabled = true,
    fontSize = 18,
    critFontSize = 24,
    colorNormal = Color3.fromRGB(255, 235, 200),
    colorCrit = Color3.fromRGB(255, 120, 60),
    colorHeal = Color3.fromRGB(120, 255, 160),
    colorDamageTaken = Color3.fromRGB(255, 80, 80),
    riseSpeed = 3,        -- studs/s
    lifeTime = 0.8,
  },
  hitEffects = {
    melee = { color = Color3.fromRGB(255, 220, 160), lifeTime = 0.25 },
    magic = { color = Color3.fromRGB(140, 200, 255), lifeTime = 0.3 },
    rangedImpact = { color = Color3.fromRGB(255, 255, 255), lifeTime = 0.2 },
  },
  projectiles = {
    rangedEnemy = {
      color = Color3.fromRGB(160, 210, 255),
      speed = 70,           -- studs/s
      size = Vector3.new(0.4, 0.4, 1.2),
      lifeTime = 2,
    },
  },
  deathEffect = { fadeTime = 0.6, burstColor = Color3.fromRGB(170, 210, 255) },
}
```

* Todos los valores viven en config; sin hardcode en scripts.
* Los VFX son visuales puros: no crean colisiones, no aplican daño.

#### **2. VFXService (ServerScriptService.Services — ModuleScript)**

API pública (llamada desde los puntos de daño existentes):

| Función | Responsabilidad |
|---------|-----------------|
| `PlayHitEffect(position, effectType)` | Fire `HitEffect` a todos los clientes (`melee`/`magic`/`rangedImpact`) |
| `ShowDamageNumber(position, amount, kind, crit)` | Fire `HitEffect` con payload de número (`normal`/`crit`/`heal`/`taken`) |
| `SpawnProjectile(from, to, configKey)` | Crear proyectil server-side (se replica) y animarlo hasta el objetivo |
| `PlayDeathEffect(enemy)` | Fire `DeathEffect` + fade del modelo antes de removerlo |

**Remotes nuevos (S→C):**

| Remote | Dir | Payload | Cuándo |
|--------|-----|---------|--------|
| `HitEffect` | S→C | `{ position, effectType, damage?, kind?, crit? }` | Golpe de skill/auto-attack, número de daño, cura |
| `DeathEffect` | S→C | `{ modelId, position }` | Muerte de enemigo |

* El cliente **nunca** dispara estos remotes; solo los escucha.
* Los proyectiles se crean **en el server** dentro de `Workspace` (se replican a todos); el server los mueve y los destruye al llegar/expirar.

#### **3. Hooks en el código existente**

* **`CombatService.ApplyDamage`** (auto-attack del jugador): tras aplicar daño, llamar:
  * `VFXService.PlayHitEffect(targetPos, "melee")`
  * `VFXService.ShowDamageNumber(targetPos, damage, "normal"|"crit", crit)`
* **`SkillService.tryCastInstant`**: tras `ApplyDamageToEnemy`, `PlayHitEffect(targetPos, "magic")` + número de daño.
* **`SkillService.tryCastHeal`**: al curar (self o aliado), `ShowDamageNumber(pos, heal, "heal")`.
* **`EnemyService.damagePlayer`**: `ShowDamageNumber(playerPos, amount, "taken")` (opcional: pequeño flash en el jugador).
* **`EnemyService.runRangedAI`**: al disparar, `SpawnProjectile(enemyRoot, playerRoot, "rangedEnemy")`. El daño se aplica **igual que hoy** (instantáneo); el proyectil es cosmético y llega aproximadamente cuando el daño aterriza.
* **`EnemyService.hookEnemyDeath`**: al marcar `Dead`, `VFXService.PlayDeathEffect(enemy)` antes de remover el modelo (el fade reemplaza el `Parent=nil` directo; el timing total de despawn sigue siendo el actual).

#### **4. VFXClient (StarterPlayerScripts — LocalScript)**

Escucha los remotes y renderiza:

* **Números de daño:** `BillboardGui` + `TextLabel` sobre la posición (Adornee = parte cercana o WorldPosition), con animación de subida y fade (`TweenService`), color según `kind` (`normal/crit/heal/taken`).
* **Hit effect:** breve flash en la posición (Part con material `Neon`, `CanCollide=false`, `Anchored=true`, fade rápido y destrucción). Simple y liviano.
* **Death effect:** al recibir `DeathEffect`, el cliente hace fade del modelo (transparencia) + breve burst de Neon (3–5 piezas pequeñas que se expanden y desaparecen). El server también lo anima por si un cliente llega tarde; el servidor es quien remueve el modelo al final del tiempo actual.
* Todos los efectos se limpian solos (lifeTime); sin bucles pesados.
* Compatible con móvil (mismos efectos; sin interacción extra).

#### **5. Reglas y límites**

* **Visual puro:** ningún efecto toca HP, daño, timing de ataque, cooldown ni loot.
* **Autoridad:** todo se dispara desde el server; el cliente solo consume.
* **Rendimiento:** límites de efectos simultáneos (por ejemplo, máx. 30 números/efectos activos globales; si se excede, se reutilizan/omiten los más viejos).
* **Sin assets externos:** primitivas + `Neon` + `Beam/Trail` (opcional) + `BillboardGui`; nada de paquetes de partículas. Si R9 incorpora partículas reales, se reemplaza el `id`/config.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Número de daño al golpear**

* **GIVEN** un jugador ataca con auto-attack o skill Instant
* **WHEN** el server aplica daño a un enemigo
* **THEN** aparece un número flotante sobre el enemigo con el daño
* **AND** el daño real no cambia

#### **Escenario 2: Críticos distinguibles**

* **GIVEN** un golpe crítico
* **WHEN** se muestra el número
* **THEN** es más grande y de color de crítico (config)

#### **Escenario 3: Heal con número**

* **GIVEN** un jugador se cura con una skill Heal
* **WHEN** el server aplica la cura
* **THEN** aparece un número verde sobre el personaje curado

#### **Escenario 4: Daño recibido por el jugador**

* **GIVEN** un enemigo daña al jugador
* **WHEN** se aplica el daño
* **THEN** aparece un número rojo sobre el jugador
* **AND** la barra de HP sigue siendo la fuente de verdad

#### **Escenario 5: Efecto de golpe en skills**

* **GIVEN** una skill Instant (melee o mágica)
* **WHEN** el cast es exitoso
* **THEN** se muestra el efecto de golpe correspondiente en el objetivo (flash Neon)

#### **Escenario 6: Proyectil ranged**

* **GIVEN** un enemigo ranged dispara
* **WHEN** se aplica el daño a distancia
* **THEN** se ve un proyectil visual desde el enemigo hacia el jugador
* **AND** el daño se aplica en el mismo momento que hoy (no se retrasa)

#### **Escenario 7: Muerte con efecto**

* **GIVEN** un enemigo muere
* **WHEN** se marca `Dead`
* **THEN** se ve un breve fade/burst
* **AND** el modelo se remueve al final del tiempo actual

#### **Escenario 8: Multiplayer**

* **GIVEN** varios jugadores conectados
* **WHEN** ocurre un golpe/proyectil/muerte
* **THEN** todos ven los mismos efectos
* **AND** no hay duplicados

#### **Escenario 9: Sin spam ni errores**

* **GIVEN** un combate intenso (varios enemigos + skills)
* **WHEN** se revisa el output
* **THEN** no hay errores rojos
* **AND** los efectos se limpian solos (no se acumulan)

#### **Escenario 10: Config reemplazable**

* **GIVEN** colores, tamaños o velocidades en `VFXConfig`
* **WHEN** se cambian
* **THEN** el comportamiento visual cambia sin tocar código

#### **Escenario 11: Anti-exploit**

* **GIVEN** un cliente envía `HitEffect`/`DeathEffect` por su cuenta
* **WHEN** el server procesa
* **THEN** ignora (remotes S→C sin handler C→S)
* **AND** el daño real sigue validado por el server

#### **Escenario 12: Móvil**

* **GIVEN** un dispositivo táctil
* **WHEN** combate con efectos activos
* **THEN** los VFX se ven sin romper joystick, cámara ni UI
* **AND** el rendimiento se mantiene aceptable

---

### **Comportamiento Visual / Reglas de Negocio**

* Números de daño legibles sobre hielo y piedra (bordes oscuros o escala razonable).
* Efectos cortos (≤0.5 s los flashes; ≤1 s los números) para no tapar el combate.
* Proyectiles rápidos y sin colisión; no bloquean el movimiento del jugador.
* El fade de muerte no interfiere con el loot/XP (eso sigue siendo server).
* Los efectos son cosméticos; la fuente de verdad del combate es el server.

---

### **Alcance**

#### Incluye

* `VFXConfig` (colores, tamaños, velocidades, tiempos).
* `VFXService` (hit, damage number, proyectil, muerte) + remotes `HitEffect`/`DeathEffect`.
* Hooks en CombatService, SkillService (Instant/Heal) y EnemyService (ranged, daño al jugador, muerte).
* `VFXClient` con números flotantes, flashes, proyectiles y fade/burst de muerte.
* Límites de rendimiento y limpieza automática.
* Config 100% reemplazable.

#### No incluye

* Cambios de daño, timing, IA, cooldowns, loot o XP.
* Sonidos/SFX (R9).
* Paquetes de partículas o assets externos (R9 si se confirma capacidad).
* VFX de skills AoE en el suelo (ya existe `AoeCastVisual`).
* Efectos de entorno (lluvia, viento, nieve) ni de UI (botones).
* Cambios a `AoeCastVisual`, `SkillBarClient` ni HUD.

---

### **Definition of Done (DoD)**

* [ ] Números de daño visibles en auto-attack y skills Instant (normal/crit).
* [ ] Números de cura (verde) y daño recibido (rojo).
* [ ] Flash de golpe para skills Instant (melee/magic).
* [ ] Proyectil visible en enemigos ranged sin retrasar el daño.
* [ ] Fade/burst de muerte de enemigos antes del despawn.
* [ ] Efectos replicados a todos los clientes.
* [ ] Sin errores rojos en combate intenso.
* [ ] Efectos con limpieza automática (sin acumulación).
* [ ] `VFXConfig` controla colores/tamaños/velocidades/tempos.
* [ ] Cliente no puede disparar efectos por su cuenta.
* [ ] Móvil sin regresiones ni caída notable de rendimiento.
* [ ] Nota `R6.8 completo` en GDD al verificar la implementación.

---

### **Estimación (orientativa)**

2–3 sesiones: VFXConfig + VFXService + remotes, hooks en daño/IA/muerte, VFXClient y pruebas en combate solo/multi.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-26 | Creación de HU-R6.8: VFX básico de combate (proyectiles ranged, hits, números de daño y muerte de enemigos); data-driven sin assets externos |
| 2026-08-26 | Marcada completada según reporte del equipo |