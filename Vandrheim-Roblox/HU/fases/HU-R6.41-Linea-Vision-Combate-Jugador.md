# HU-R6.41: Validar línea de visión en ataques del jugador (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R6.x / Combate / Autoridad server-side
**Prioridad:** Alta
**Estado:** Lista para RC
**Tipo:** Bugfix de validación de impactos (dev)
**Depende de:** HU-R3/R3.1 (targeting y ataques), HU-R6.19 (LOS existente para enemigos ranged), HU-R6.38 (críticos por impacto), `CombatService`, `SkillService`, TooltipSystem/NotificationFrame
**No modifica:** fórmulas de daño, rango, cooldown, coste, reglas de targeting ni LOS de la IA enemiga R6.19.

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** necesitar línea de visión real para dañar a un enemigo,
**para** que paredes y estructuras protejan de ataques que no deberían alcanzarme.

---

### Descripción / Contexto

El jugador actualmente puede causar daño a enemigos al otro lado de paredes. R6.19 cubre la línea de visión de enemigos ranged hacia el jugador, pero no la autoridad de los ataques del jugador hacia el enemigo. Esta HU añade esa validación en servidor y un mensaje claro cuando el objetivo está oculto.

**Criterio de hecho global:** ningún impacto dañino de jugador atraviesa una obstrucción estructural que interrumpe la visión entre el origen del ataque y el objetivo; el cliente ve `No puedes ver al enemigo.` cuando falla un ataque dirigido por falta de LOS.

---

### Especificaciones técnicas / Contratos

* Implementar/reutilizar una función server-authoritative de LOS con `Workspace:Raycast` o helper equivalente, entre el origen del ataque y el `HumanoidRootPart`/punto de impacto válido del objetivo.
* Filtrar al atacante, el objetivo y efectos visuales/proyectiles. Las estructuras sólidas bloquean; personajes, hitboxes del atacante, partículas, telegraphs y decoración marcada no bloqueante no bloquean.
* Validar antes de confirmar el daño de: básicos melee/ranged, skills de daño dirigidas a un `targetId` y aplicación de DoT. No aceptar `targetId` ni confiar en un LOS enviado por cliente.
* Para SelfAoE/GroundAoE, comprobar LOS individual entre el centro/origen del daño y cada objetivo: los enemigos ocultos por una estructura no reciben ese impacto; los visibles siguen recibiendo el daño normal.
* Para efectos persistentes que hacen daño por tick (DoT/GroundAoE), realizar la misma comprobación por objetivo en cada tick. Un tick bloqueado no daña ni genera feedback de daño; el efecto conserva su duración y expira normalmente.
* Si un ataque dirigido falla LOS, no causar daño ni efectos secundarios y no consumir maná/cooldown; emitir una sola notificación por intento usando el feedback existente: **“No puedes ver al enemigo.”** No repetir la notificación en cada frame.
* Si un AoE afecta algunos objetivos visibles y otros ocultos, solo los visibles reciben daño; no emitir spam de error por cada objetivo oculto. Si no afecta a ningún objetivo debido a la obstrucción, mostrar un único feedback claro cuando la acción tenía un objetivo seleccionado.
* No cambiar la decisión de R6.19 sobre LOS de NPCs ranged (enemigos) ni hacer que NPCs/personajes bloqueen raycasts estructurales.

---

### Criterios de aceptación (Gherkin)

#### Escenario 1: Ataque directo bloqueado por pared

* **GIVEN** un enemigo seleccionado al otro lado de una pared sólida
* **WHEN** el jugador intenta un básico o skill dirigida
* **THEN** el servidor rechaza el impacto, no consume recurso/cooldown y muestra “No puedes ver al enemigo.”

#### Escenario 2: Ataque con visión

* **GIVEN** el jugador tiene visión directa y el enemigo está dentro del rango
* **WHEN** ataca
* **THEN** daño, crítico y feedback siguen el flujo existente sin penalización adicional

#### Escenario 3: AoE con objetivos visibles y ocultos

* **GIVEN** un AoE afecta a enemigos a ambos lados de una pared
* **WHEN** se resuelve el impacto/tick
* **THEN** solo reciben daño los objetivos con LOS desde el centro/origen; no se duplica ni se aplica daño a través de la pared

#### Escenario 4: Persistencia de DoT/AoE

* **GIVEN** un DoT o GroundAoE activo y el objetivo se oculta tras una estructura
* **WHEN** ocurren ticks durante la obstrucción
* **THEN** esos ticks no causan daño ni notifican impacto; al recuperar LOS, los siguientes ticks pueden dañar hasta que expire el efecto

#### Escenario 5: Geometría que no bloquea

* **GIVEN** una partícula, projectile visual, personaje o prop `CanQuery=false` en la trayectoria
* **WHEN** se valida LOS hacia el enemigo
* **THEN** esos objetos no ocultan al objetivo; una pared estructural sí

#### Escenario 6: Regresión y autoridad

* **GIVEN** un cliente manipula localmente el target/resultado del raycast
* **WHEN** intenta atacar a través de una pared
* **THEN** el servidor mantiene el rechazo; ataques válidos, R6.19 enemigo-ranged, Party y Dungeon siguen funcionando

---

### Alcance

#### Incluye

* LOS server-side para básicos y habilidades dañinas dirigidas.
* LOS por objetivo para SelfAoE/GroundAoE y sus ticks.
* Mensaje de error para intentos dirigidos sin visión.

#### No incluye

* Rediseño de targeting/cámara o selección de objetivos.
* LOS de enemigos ranged (ya documentado en R6.19).
* Bloqueo por efectos, jugadores, enemigos o decoración no estructural.
* Cambios a daño, range, balance o VFX.

---

### Definition of Done (DoD)

* [ ] Básicos y habilidades dirigidas no aplican impactos a través de paredes y validan LOS en servidor.
* [ ] Los AoE/ticks resuelven LOS por objetivo y no dañan objetivos ocultos.
* [ ] Un ataque dirigido sin LOS muestra el mensaje acordado, no aplica daño/efecto y no consume recurso/cooldown.
* [ ] Los efectos visuales y objetos no bloqueantes no causan falsos negativos.
* [ ] QA en geometría abierta, una pared, esquina, puerta y pasillo; PC/móvil, solo/party.
* [ ] R6.19 NPC-ranged, R6.38 críticos, y remotes existentes sin regresión; sin errores rojos.
* [ ] RC y evidencia adjuntos.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-10-23 | HU nueva por reporte del PO: impedir daño del jugador a través de paredes y dar feedback de falta de visión. |
