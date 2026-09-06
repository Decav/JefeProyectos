## HU-R6.6: Animaciones de combate del jugador (auto-attack y skills)

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** Combate / Animaciones / R6.6  
**Prioridad:** Alta  
**Estado:** Completada (implementada; reporte equipo 2026-08-26)  
**Tipo:** Feedback visual de combate (base para pruebas de animación)  
**Fase GDD:** R6.6 (posterior a R6.5; no modifica autoridad ni daño)  
**Depende de:** HU-R1 (CombatService), HU-R3 (SkillService), HU-R5.1 (skills v2), HU-ASSETS (AnimationRegistry), rc013 (controlador de movimiento limpio)  
**Componentes observados:** `ReplicatedStorage.Assets.Animations.AnimationRegistry` (IDs melee_slash, ranged_shot, cast_magic, cast_aoe, heal, shield_buff), `ServerScriptService.Services.CombatService` (auto-attack tick), `ServerScriptService.Services.SkillService` (cast), `StarterCharacterScripts.Animate` (movimiento R15), `StarterGui.SkillBar.SkillBarClient` (AoeCastVisual)

---

### **Narrativa (INVEST)**

**Como** jugador,  
**quiero** que mi personaje reproduzca una animación al golpear automáticamente y al lanzar habilidades,  
**para** que el combate se sienta como un MMO y podamos empezar a probar y refinar animaciones.

**Como** equipo,  
**quiero** una base mínima data-driven que dispare la animación correcta por acción,  
**para** iterar los IDs de animación y el timing sin tocar la lógica de combate.

---

### **Descripción del Requerimiento / Contexto**

Estado actual verificado:

* `AnimationRegistry` ya contiene IDs de la Library para combate por tipo: `melee_slash`, `ranged_shot`, `cast_magic`, `cast_aoe`, `heal`, `shield_buff`.
* `StarterCharacterScripts.Animate` (rc013) maneja solo el movimiento (idle/walk/run/jump/fall) con prioridades explícitas.
* `CombatService` ejecuta el auto-attack server-side (tick ~1.5 s, rango 12) y aplica daño, pero **no dispara ninguna animación**.
* `SkillService` valida y ejecuta casts, y avisa cooldown/AoE visual, pero **no dispara animaciones de cast**.
* No existe ningún script cliente que reproduzca animaciones de combate.

Esta HU agrega el **disparo de animaciones client-side** con timing **server-authoritative**: el servidor decide cuándo hubo un golpe/cast válido y avisa al cliente; el cliente reproduce la animación correspondiente. El daño, rango, cooldowns y validaciones **no cambian**.

El objetivo es tener una base para **fase de pruebas de animación**: poder probar la animación de cada acción en Play Solo y reemplazar IDs en config sin tocar código.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Remote nuevo (server → cliente)**

Agregar en `ReplicatedStorage.Remotes`:

| Remote | Dir | Payload | Cuándo se dispara (server) |
|--------|-----|---------|----------------------------|
| `PlayCombatAnimation` | S→C | `{ key = "<animationKey>" }` | Auto-attack válido que aterriza (daño aplicado) y cast de skill exitoso |

Reglas:

* El server **nunca** confía en el cliente para disparar animaciones: solo el server emite `PlayCombatAnimation` después de validar el hit/cast.
* El payload solo lleva una clave del registro (`melee_slash`, `ranged_shot`, `cast_magic`, `cast_aoe`, `heal`, `shield_buff`, `autoattack`).
* Si un cast es rechazado (rango, CD, maná, target), **no** se emite animación.

#### **2. `CombatService` — auto-attack**

* En el tick de auto-attack, **después** de aplicar daño con éxito (dentro del rango y con target válido), emitir:

```luau
Remotes.PlayCombatAnimation:FireClient(player, { key = "autoattack" })
```

* El key `autoattack` se mapea al valor de `melee_slash` en `AnimationRegistry` (agregar alias `autoattack = melee_slash` en el registro).
* El hit visual queda sincronizado con el tick de 1.5 s: una animación corta de melee no debe superponerse con la siguiente (la animación debe ser de ~0.5–1 s).
* Si en el futuro el jugador usa un arma ranged, el auto-attack puede elegir `ranged_shot` por config; en esta HU el default es melee.

#### **3. `SkillService` — casts**

* Agregar campo data-driven `animationKey` a cada skill en `SkillConfig` (valores del registro):

```luau
{
  ["paladin_holy_strike"] = {
    -- ...
    animationKey = "melee_slash",
  },
  ["paladin_light_verdict"] = {
    -- ...
    animationKey = "cast_magic",
  },
  -- GroundAoE → "cast_aoe" · Heal → "heal" · Shield → "shield_buff" · ranged → "ranged_shot"
}
```

* En el cast exitoso (después de las validaciones y del consumo de maná), emitir:

```luau
Remotes.PlayCombatAnimation:FireClient(player, { key = skill.animationKey })
```

* Fallback: si una skill no tiene `animationKey`, el server emite con el mapeo por tipo: `Instant` → `melee_slash`, `GroundAoE` → `cast_aoe`, `Heal` → `heal`, `Shield` → `shield_buff` (o no emite si el tipo no está definido). El fallback vive en una función pequeña del `SkillService` o en el registro; no hardcodear en múltiples lugares.
* `AoeCastVisual` sigue existiendo tal cual (indicador de área); la animación de cast es complementaria.

#### **4. Cliente: `CombatAnimationClient`**

Nuevo LocalScript en `StarterCharacterScripts.CombatAnimationClient` (se re-arma solo en cada respawn, igual que `Animate`):

```text
StarterPlayer.StarterCharacterScripts.CombatAnimationClient (LocalScript)
```

Responsabilidades:

* Esperar `Remotes.PlayCombatAnimation` y `character`/`Humanoid`/`Animator`.
* Resolver el key → `AnimationRegistry[key]` (require del registro, igual que `Animate`).
* Cargar `humanoid:LoadAnimation(anim)` (o `animator:LoadAnimation`) y reproducir con **prioridad `Enum.AnimationPriority.Action`** para que se vea por encima de idle/walk/run sin interrumpir el movimiento.
* Al recibir un nuevo key mientras hay un track de combate activo: detener el anterior y reproducir el nuevo (sin acumular tracks).
* `track:Play(0.1)` con fade corto; si la animación no está disponible (id vacío), no hacer nada y no romper el flujo.
* Limpieza en respawn: el script del personaje se reinicia solo; no deja tracks huérfanos del personaje anterior.
* No crear remotes client→server; el cliente solo escucha.
* Respetar convenciones: `task.wait()`/`task.spawn()`, sin `wait()`, sin polling.

Alternativa de ubicación aceptada: `StarterPlayerScripts.CombatAnimationClient` manejando `CharacterAdded`; se prefiere `StarterCharacterScripts` por el re-arma automático.

#### **5. Integración con el controlador de movimiento (rc013)**

* Las pistas de combate usan prioridad `Action`; `Animate` usa `Idle`/`Movement`/`Action` (jump). La animación de combate debe poder convivir con walk/run y salto sin cancelarlos de forma permanente.
* Verificar que el reemplazo de pistas no deje el personaje "pegado" en una pose al terminar el ataque (fade de salida corto o stop con fade).
* No modificar `Animate` ni los IDs de movimiento.

#### **6. Seguridad y autoridad**

* El server decide cuándo se ve la animación; un cliente manipulado no puede hacer que otros jugadores vean animaciones, ni dañar, ni falsear casts.
* Cada jugador solo recibe su propio `PlayCombatAnimation` (`FireClient`), no hay spam entre jugadores.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Auto-attack animado**

* **GIVEN** un jugador con target en rango
* **WHEN** el server aplica daño del auto-attack
* **THEN** el cliente reproduce `autoattack` (melee)
* **AND** el daño no cambia respecto a antes de la HU

#### **Escenario 2: Cast de skill animado**

* **GIVEN** un jugador castea una skill válida
* **WHEN** el cast es exitoso
* **THEN** se reproduce el `animationKey` de esa skill
* **AND** el cast rechazado no reproduce animación

#### **Escenario 3: Tipos distintos**

* **GIVEN** skills de tipo Instant melee, Instant ranged, mágico, GroundAoE, Heal y Shield
* **WHEN** se castean
* **THEN** cada una reproduce su animación del registro (melee_slash, ranged_shot, cast_magic, cast_aoe, heal, shield_buff)

#### **Escenario 4: Prioridad sobre movimiento**

* **GIVEN** el jugador corre/camina
* **WHEN** ataca o castea
* **THEN** la animación de combate se ve por encima del movimiento
* **AND** el movimiento continúa (no se queda pegado)

#### **Escenario 5: Sin acumulación**

* **GIVEN** ataques rápidos consecutivos (auto-attack cada 1.5 s o skills seguidas)
* **WHEN** llegan varios `PlayCombatAnimation`
* **THEN** solo hay un track de combate activo a la vez
* **AND** no se acumulan tracks ni errores

#### **Escenario 6: Respawn**

* **GIVEN** el jugador respawnea
* **WHEN** vuelve el personaje
* **THEN** el script cliente se re-enlaza
* **AND** el auto-attack y los casts vuelven a animar sin duplicados

#### **Escenario 7: Fallback de registro**

* **GIVEN** un key sin ID en el registro o sin `animationKey` en la skill
* **WHEN** se dispara el remote
* **THEN** no se reproduce nada
* **AND** no aparece error rojo ni se rompe el combate

#### **Escenario 8: Anti-exploit**

* **GIVEN** un cliente envía `PlayCombatAnimation` por su cuenta o intenta falsear casts
* **WHEN** el server procesa
* **THEN** ignora el intento (remote es S→C, no registra handler C→S)
* **AND** daño/cast siguen validados por el server

#### **Escenario 9: Pruebas de animación**

* **GIVEN** la base implementada
* **WHEN** se quiere probar otra animación
* **THEN** solo se cambia el ID en `AnimationRegistry` (o el `animationKey` en config)
* **AND** no se toca código de combate

#### **Escenario 10: Móvil**

* **GIVEN** un dispositivo táctil
* **WHEN** el jugador ataca y castea
* **THEN** las animaciones se reproducen igual
* **AND** no rompen joystick, cámara ni UI

---

### **Comportamiento Visual / Reglas de Negocio**

* La animación es cosmética y local al jugador que ejecuta la acción.
* El server conserva autoridad total sobre daño, cast, CD y maná.
* Las animaciones vienen del `AnimationRegistry` (Library, Free, R15) según `ASSETS_POLICY`; no se crean animaciones propias.
* Esta HU habilita la **fase de pruebas de animación**: los IDs y `animationKey` se pueden iterar libremente en config.

---

### **Alcance**

#### Incluye

* Remote `PlayCombatAnimation` (S→C).
* Disparo en `CombatService` (auto-attack válido).
* Disparo en `SkillService` (cast exitoso) + fallback por tipo.
* Campo `animationKey` en `SkillConfig` (seed para las skills actuales).
* Alias `autoattack` en `AnimationRegistry`.
* `CombatAnimationClient` (LocalScript) con prioridad `Action`, reemplazo de tracks y limpieza en respawn.
* Prueba en Play Solo de auto-attack y los 6 tipos de animación.

#### No incluye

* Cambios de daño, rango, cooldowns, maná, targeting o autoridad.
* Predicción client-side de golpes (el server decide cuándo animar).
* Animaciones para enemigos o NPCs.
* Creación/rigging de animaciones propias (solo Library, por política).
* VFX/SFX, hit-stop, zoom de impacto ni screen shake.
* Animaciones por arma específica (solo key melee default en esta HU).
* Monturas, emotes o animaciones fuera de combate.

---

### **Definition of Done (DoD)**

* [ ] `PlayCombatAnimation` existe y solo se emite desde el server.
* [ ] Auto-attack válido reproduce `autoattack` (melee) sin cambiar daño.
* [ ] Cada cast exitoso reproduce su `animationKey`.
* [ ] Casts rechazados no reproducen animación.
* [ ] GroundAoE mantiene su indicador visual + animación de cast.
* [ ] La animación de combate convive con walk/run/salto (prioridad Action).
* [ ] Ataques rápidos no acumulan tracks ni causan errores.
* [ ] Respawn re-enlaza el script sin duplicados.
* [ ] Cliente no puede disparar animaciones por su cuenta.
* [ ] Se pueden probar los 6 tipos de animación en Play Solo.
* [ ] Cambiar un ID en `AnimationRegistry` no requiere tocar código de combate.
* [ ] Sin errores rojos en el flujo atacar → castear → morir → respawn.
* [ ] Móvil sin regresiones.
* [ ] Nota `R6.6 completo` en GDD al verificar la implementación.

---

### **Estimación (orientativa)**

1–2 sesiones: remote + hooks server + script cliente + seed de `animationKey` + pruebas en Play Solo.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-25 | Creación de HU-R6.6: animaciones de combate del jugador (auto-attack y skills) sobre el registro existente |
| 2026-08-26 | Marcada completada según reporte del equipo |