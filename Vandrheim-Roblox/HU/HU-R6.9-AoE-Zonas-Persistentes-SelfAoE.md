## HU-R6.9: AoE — zonas de suelo persistentes (GroundAoE con daño en el tiempo) y SelfAoE

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** Skills / Combate / R6.9  
**Prioridad:** Alta  
**Estado:** Completada (implementada; reporte equipo 2026-08-26)  
**Tipo:** Refactor del framework AoE (tarea del dev)  
**Fase GDD:** R6.9 (posterior a R6.8; no modifica autoridad ni balance final)  
**Depende de:** HU-R3 (SkillService), HU-R5.1 (SkillConfig v2), SKILLS_CATALOG v2.1 (actualizado en esta misma entrega), HU-R6.8 (VFX: hits/proyectiles — reutiliza remotes/visual)  
**Componentes observados:** `ServerScriptService.Services.SkillService` (`tryCastGroundAoE`, `AoeCastVisual`), `ReplicatedStorage.Config.SkillConfig`, `StarterGui.SkillBar.SkillBarClient` (modo posicionamiento de suelo), `Workspace` (contenedores de pisos)

---

### **Narrativa (INVEST)**

**Como** jugador,  
**quiero** distinguir entre dos tipos de AoE: las que se lanzan a una zona y **siguen haciendo daño mientras la zona permanece**, y las que golpean **alrededor de mí al instante**,  
**para** que Consagración, Torbellino e Ira divina se sientan como habilidades distintas y con usos distintos.

**Como** equipo,  
**quiero** un framework que soporte zonas persistentes de suelo y AoE centrado en el jugador,  
**para** poder crear más habilidades con estas mecánicas sin rehacer el sistema.

---

### **Descripción del Requerimiento / Contexto**

Hoy `SkillService` implementa un único tipo `GroundAoE`: el jugador elige un punto, se muestra el indicador circular (`AoeCastVisual`) y se aplica **un burst instantáneo** a los enemigos dentro del radio. No hay distinción entre:

* **GroundAoE (zona persistente):** se lanza a un punto del suelo y **la zona queda ahí** durante `zoneDuration`, aplicando **daño por tick** (`tickInterval`) a los enemigos que estén dentro (incluidos los que entran después).
* **SelfAoE:** centrado en el jugador, **sin elegir punto**: golpea una vez a los enemigos cercanos.

Habilidades afectadas (SKILLS_CATALOG v2.1):

* `paladin_prot_consecration` (Consagración) → **GroundAoE persistente** (zona de fuego sagrado, DoT).
* `cleric_wrath_divine_ire` (Ira divina) → **GroundAoE persistente** (zona de castigo, DoT).
* `hunter_asm_whirlwind` (Torbellino) → **SelfAoE** (giro alrededor del jugador, burst).

El cast en movimiento (GDD) se mantiene para ambos. La autoridad sigue en el server; el cliente nunca decide daño, duración ni radio.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. SkillConfig (data-driven)**

El tipo discrimina la mecánica:

```luau
{
  ["hunter_asm_whirlwind"] = {
    type = "SelfAoE",
    aoeRadius = 8,
    -- sin maxCastRange ni zona (burst instantáneo alrededor del jugador)
    damageBase = 30, coefficient = 1.2,
  },
  ["paladin_prot_consecration"] = {
    type = "GroundAoE",
    aoeRadius = 8,
    maxCastRange = 20,
    zoneDuration = 4,     -- segundos que permanece la zona
    tickInterval = 0.5,   -- daño por tick
    damageBase = 6, coefficient = 0.45,  -- por tick (orientativo; balance R8)
  },
}
```

Campos nuevos:

| Campo | SelfAoE | GroundAoE (zona) |
|-------|---------|------------------|
| `type` | `"SelfAoE"` | `"GroundAoE"` |
| `aoeRadius` | Sí (radio del jugador) | Sí (radio de la zona) |
| `maxCastRange` | No | Sí (posición del lanzamiento) |
| `zoneDuration` | No | Sí (tiempo que dura la zona) |
| `tickInterval` | No | Sí (frecuencia del daño en el tiempo) |
| `damageBase`/`coefficient` | Daño total del burst | **Por tick** (daño total = por tick × ticks) |

* Un `GroundAoE` sin `zoneDuration`/`tickInterval` → comportamiento legado (burst en el punto) o error de config; se prefiere config explícita.
* Maná y cooldown se consumen **una sola vez al lanzar** (no por tick).

#### **2. SkillService: tryCastGroundAoE (zona persistente)**

* Se mantiene el flujo actual de posicionamiento: el cliente envía `position`, el server valida `≤ maxCastRange`.
* Al cast exitoso, el server **crea una zona** (estado server-side):

```luau
{
  zoneId = "zone_<uuid>",
  skillId, ownerId, position, radius,
  duration, tickInterval,
  damagePerTick = damageBase + coefficient * stat,
}
```

* Un loop por zona (o un ticker central) aplica daño cada `tickInterval` a los **enemigos vivos dentro del radio** (se re-consulta cada tick: los que entran después reciben daño).
* Al terminar `duration`, la zona se elimina.
* **Visual:** remote `AoeZoneCreated` (S→C) `{ skillId, position, radius, duration }` → el cliente muestra el anillo persistente. (El indicador de posicionamiento `AoeCastVisual` sigue igual para elegir el punto.)
* **Limpieza:** las zonas viven en un contenedor server (ej. `Workspace.Run/Zones` o el contenedor del piso); al despawnear un piso / abandonar la run, las zonas se destruyen (hook con `FloorService.ClearFloor`/`DungeonService`).
* Si el jugador muere o sale del rango, **la zona continúa** (es un efecto del mundo, no del jugador).

#### **3. SkillService: tryCastSelfAoE**

* **Sin payload de posición:** el centro es la posición del `HumanoidRootPart` del jugador **al momento del cast**.
* Aplica **un burst** de daño a los enemigos vivos dentro de `aoeRadius` (misma lógica de daño server-side).
* Visual: `AoeZoneCreated` con `duration` breve (ej. 0.5 s) o reutilizar el hit effect de R6.8 — el cliente no necesita entrar en modo de posicionamiento.
* `SkillBarClient`: para `SelfAoE`, la activación es directa (tecla) — **no** se abre el modo de apuntar al suelo.
* Cast en movimiento OK (GDD); la posición de centro se toma al validar.

#### **4. Cliente (SkillBarClient + visual de zona)**

* **GroundAoE:** modo actual de posicionamiento se mantiene (click en el suelo + indicador `AoeCastVisual`); luego se muestra la zona persistente por `AoeZoneCreated`.
* **SelfAoE:** activación directa; anillo breve alrededor del jugador (config en `VFXConfig` o `AoeZoneConfig`: color, transparencia, estilo).
* `AoeZoneConfig` (ReplicatedStorage.Config) o extensión de `VFXConfig`: colores/tamaños/estilos del anillo, data-driven.
* Los anillos se limpian solos al terminar `duration`; sin acumulación.

#### **5. Reglas y autoridad**

* Server-authoritative: posición (≤ maxCastRange), radio, ticks, duración y daño son del server.
* El cliente no puede: extender zonas, elegir centro arbitrario en SelfAoE, ni aplicar daño.
* Las zonas son globales (afectan a cualquier enemigo que entre) — listo para party (R9).
* Los números por tick y duración quedan en `SKILLS_CATALOG` como orientativos; balance final en R8.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: GroundAoE crea zona persistente**

* **GIVEN** un jugador lanza Consagración a un punto válido
* **WHEN** el cast es exitoso
* **THEN** se crea una zona en ese punto con `zoneDuration`
* **AND** se muestra el anillo persistente en todos los clientes

#### **Escenario 2: Daño en el tiempo**

* **GIVEN** la zona activa y un enemigo dentro
* **WHEN** pasa cada `tickInterval`
* **THEN** el enemigo recibe el daño del tick
* **AND** el daño total corresponde a `por tick × ticks`

#### **Escenario 3: Enemigos que entran después**

* **GIVEN** una zona activa
* **WHEN** un enemigo entra al radio después del primer tick
* **THEN** empieza a recibir daño en los ticks siguientes
* **AND** no recibe ticks retroactivos

#### **Escenario 4: La zona termina**

* **GIVEN** una zona activa
* **WHEN** se cumple `zoneDuration`
* **THEN** la zona se elimina
* **AND** el anillo visual desaparece
* **AND** ya no se aplican ticks

#### **Escenario 5: SelfAoE alrededor del jugador**

* **GIVEN** un jugador con Torbellino y enemigos cercanos
* **WHEN** activa la habilidad
* **THEN** los enemigos dentro de `aoeRadius` reciben el burst
* **AND** no se abre el modo de posicionamiento de suelo

#### **Escenario 6: SelfAoE no necesita posición**

* **GIVEN** un cliente envía una posición con un SelfAoE
* **WHEN** el server procesa
* **THEN** ignora la posición y usa el centro del jugador

#### **Escenario 7: Cast en movimiento**

* **GIVEN** el jugador se mueve
* **WHEN** lanza un SelfAoE o un GroundAoE
* **THEN** el cast funciona sin interrumpir el movimiento
* **AND** el centro/posición se toman al momento del cast

#### **Escenario 8: Maná/CD una sola vez**

* **GIVEN** un GroundAoE persistente
* **WHEN** se lanza
* **THEN** el maná y el cooldown se descuentan una vez
* **AND** los ticks no descuentan nada extra

#### **Escenario 9: Limpieza con el piso/run**

* **GIVEN** zonas activas en un piso
* **WHEN** el piso se despawna o la run se abandona
* **THEN** las zonas se destruyen
* **AND** no quedan anillos ni loops colgados

#### **Escenario 10: Muerte del jugador**

* **GIVEN** una zona activa de un jugador
* **WHEN** el jugador muere
* **THEN** la zona sigue activa hasta terminar su duración
* **AND** no se duplica ni se elimina antes

#### **Escenario 11: Anti-exploit**

* **GIVEN** un cliente intenta fijar radio, duración, ticks o centro arbitrario
* **WHEN** envía datos manipulados
* **THEN** el server ignora los valores
* **AND** aplica solo la config de la skill

#### **Escenario 12: Regresión**

* **GIVEN** el refactor aplicado
* **WHEN** se revisa el combate completo (Instant, AoE, Heal, Shield, auto-attack)
* **THEN** no hay errores rojos
* **AND** el resto de skills conserva su comportamiento

---

### **Comportamiento Visual / Reglas de Negocio**

* GroundAoE: zona visible persistente (anillo o área con transparencia) que representa el área real de daño.
* SelfAoE: anillo breve al activarse; no bloquea la cámara ni el movimiento.
* El jugador debe distinguir visualmente "zona que sigue haciendo daño" de "golpe instantáneo".
* Números por tick en el catálogo; el total de la habilidad es lo que se balancea en R8.

---

### **Alcance**

#### Incluye

* `type = "SelfAoE"` nuevo en `SkillConfig` y `tryCastSelfAoE`.
* `tryCastGroundAoE` refactorizado a **zona persistente** (duration, ticks, re-chequeo de enemigos).
* Remote `AoeZoneCreated` (S→C) + visual de anillo (config).
* `SkillBarClient`: SelfAoE sin modo de posicionamiento; GroundAoE conserva el modo actual.
* Limpieza de zonas al terminar y al despawnear piso/run.
* Asignación de mecánicas a Consagración (zona), Ira divina (zona) y Torbellino (Self).
* Actualización de `SKILLS_CATALOG` (v2.1) con la semántica y los números por tick.

#### No incluye

* Zonas de cura, buffs de área o control de masas (root/slow) en zona.
* Zonas que siguen al jugador (aura).
* Cambios de balance final (R8).
* VFX finales de zonas (R8/R9 si se confirma capacidad de partículas).
* Cambios a Instant/Heal/Shield, auto-attack o IA de enemigos.
* Remotes client→server nuevos para posicionar SelfAoE.

---

### **Definition of Done (DoD)**

* [ ] `SelfAoE` funciona sin posicionamiento: burst alrededor del jugador.
* [ ] `GroundAoE` crea zona persistente con daño por tick.
* [ ] Enemigos que entran después reciben daño en los ticks siguientes.
* [ ] La zona se elimina al terminar `zoneDuration` (visual y lógica).
* [ ] Maná/CD se descuentan una sola vez.
* [ ] `AoeZoneCreated` replica el anillo a todos los clientes.
* [ ] Zonas se limpian al despawnear piso/run; zonas sobreviven la muerte del jugador.
* [ ] Cliente no puede manipular radio/duración/centro.
* [ ] Torbellino = SelfAoE; Consagración e Ira divina = zona persistente (catálogo v2.1).
* [ ] Cast en movimiento OK; sin errores rojos en regresión de combate.
* [ ] `SKILLS_CATALOG` actualizado con semántica Ground/Self y números por tick.
* [ ] Nota `R6.9 completo` en GDD al verificar la implementación.

---

### **Estimación (orientativa)**

2–3 sesiones: refactor de los dos tipos AoE, zonas con ticks, remote visual, SkillBarClient y pruebas de regresión.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-26 | Creación de HU-R6.9: GroundAoE persistente con daño en el tiempo + SelfAoE alrededor del jugador; SKILLS_CATALOG v2.1 |
| 2026-08-26 | Marcada completada según reporte del equipo |