# HU-R6.62: Senda del Jotunn — orbes, recompensas endgame y respawn seguro (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Endgame / Retención / Balance de recompensas
**Prioridad:** Alta — el modo ya está implementado, pero la experiencia de recompensa y muerte no se siente endgame
**Estado:** Abierta — lista para RC
**Tipo:** Mejoras de modo existente (dev)
**Fase GDD:** Endgame / Retención
**Depende de:** HU-R6.57 (implementada por el dev como **“Senda del Jotunn”**), HU-R6.54 (juice), `EnemyService`, `LootService`, `ProgressionService`, `DataService`, `UIService`, `ItemConfig`
**Componentes observados:** arena de Senda del Jotunn, oleadas, respawn, recompensas, perfil, oro/XP, potions
**No modifica:** campaña de 5 pisos, enemigos/jefes existentes, balance de clases, stats de combate, audio ni economía base.

---

### Narrativa (INVEST)

**Como** jugador de endgame,
**quiero** orbes de vida/maná, recompensas acordes al modo y un respawn que no me mate al instante,
**para** que Senda del Jotunn se sienta desafiante y recompensante, no frustrante.

**Como** equipo,
**quiero** ajustar el modo ya implementado sin rehacerlo,
**para** mejorar retención y percepción de recompensa sin tocar la campaña ni el balance general.

---

### Descripción / Contexto

El dev implementó R6.57 bajo el nombre **“Senda del Jotunn”**. El modo funciona, pero el PO reporta tres problemas:

1. **Sustain:** no hay recuperación dentro de la arena; el desgaste es excesivo.
2. **Recompensas:** un ítem verde/blanco, pociones comunes, poco oro o poca XP no se sienten como endgame. La XP además no llega de forma automática al completar oleadas.
3. **Respawn:** al morir, el jugador reaparece en el centro y los enemigos lo masacran; no hay margen para reincorporarse.

Esta HU corrige esos tres puntos. No cambia la estructura de oleadas, enemigos ni jefes.

**Criterio de hecho global:** Senda del Jotunn tiene orbes periódicos de vida/maná, XP automática por oleada, recompensas de cash-out solo azul/morado con pociones grandes y oro relevante, y un respawn seguro con inmunidad y reset de aggro; el jugador no muere al reaparecer y el modo sigue siendo server-authoritative.

---

### Especificaciones Técnicas / Contratos

#### 1. Orbes de vida y maná

* Spawn automático en la arena cada **20–30 s** (configurable; default 25 s), solo durante oleadas activas.
* Máximo **3 orbes vivos** a la vez; no acumular.
* Tipo:
  * **Vida:** restaura 20 % del MaxHP (configurable),
  * **Maná:** restaura 20 % del MaxMP (configurable).
* Distribución 50/50; si el jugador está full, el orbe permanece y puede tomarlo otro.
* Aparecen en puntos seguros de la arena, lejos de spawns de enemigos y de hazards; no dentro de paredes.
* Pickup por proximidad (sin prompt) o prompt corto; el servidor valida jugador, distancia y tipo.
* No se puede acumular el efecto: si el jugador ya está al máximo, no se guarda.
* Despawn a los 30 s si nadie lo toma.
* VFX existente; sin audio nuevo.
* Limpieza al terminar la oleada/run o al cambiar de arena.
* En party, los orbes son **compartidos**: el primero que los toma recibe la curación; no hay orbe personal por jugador.

#### 2. XP automática por oleada

* Al completar cada oleada, entregar XP automáticamente a todos los jugadores vivos/participantes de la run.
* Fórmula configurable; default `xp = 15 + wave * 5` (ajustar en QA).
* No requiere abrir cofre ni reclamar manualmente.
* Mostrar un aviso breve de XP ganada al iniciar la siguiente oleada.
* Si el personaje está en el nivel máximo:
  * convertir la XP a oro equivalente configurado, o
  * no entregar XP y mostrar “Nivel máximo”; evitar recompensa invisible.
* No duplicar XP por oleada si el jugador muere y revive; una entrega por oleada/participante.
* No cambiar la XP de la campaña ni la curva de nivel.

#### 3. Recompensas de cash-out endgame

Cada 10 oleadas se mantiene el cash-out, pero con pool endgame:

* **Sin ítems blancos ni verdes.**
* **Sin pociones comunes/chicas** (`potion_hp`, `potion_mp`).
* Solo ítems **azules o morados** de la pool existente; sin uniques de jefe.
* Pociones **grandes** (`potion_hp_large`, `potion_mp_large`).
* Oro relevante; no cantidades bajas.
* XP ya se entrega por oleada; el cash-out no depende de XP.

Default de recompensa por hito:

| Oleada | Ítem | Pociones | Oro |
|---:|---|---|---:|
| 10 | 1 azul garantizado | 2 grandes de vida + 1 grande de maná | 300 |
| 20 | 1 azul garantizado + 20 % de morado | 2 grandes de vida + 2 grandes de maná | 600 |
| 30 | 1 azul garantizado + 35 % de morado | 3 grandes de vida + 2 grandes de maná | 1000 |
| 40+ | 1 azul garantizado + 50 % de morado | 3 grandes de vida + 3 grandes de maná | 1500 |

* Los valores son configurables; el principio es **nunca blanco/verde ni poción chica**.
* El jugador elige 1 de 3 opciones cuando aplique; todas las opciones deben respetar la regla de rareza mínima.
* Las recompensas ya aseguradas se conservan si el grupo muere después.
* No agregar moneda nueva, loot exclusivo de campaña ni pay-to-win.

#### 4. Respawn seguro

* Al morir en Senda del Jotunn, reaparecer en un **punto seguro** de la arena, no en el centro de la pelea.
* Aplicar **4 s de inmunidad** al reaparecer (configurable), con VFX/ForceField visible.
* Restaurar **60 % de HP/MP** al reaparecer (configurable), no el 100 %.
* Al respawnear:
  * limpiar el aggro de los enemigos hacia ese jugador,
  * hacer que los enemigos lo ignoren durante la inmunidad,
  * evitar que haya enemigos a menos de 20 studs del punto seguro; si los hay, reubicarlos al borde de la arena o hacer que vuelvan a su spawn.
* La inmunidad termina antes si el jugador ataca o lanza una habilidad; no se puede usar para hacer daño gratis.
* Si toda la party muere, la run termina; no hay respawn infinito.
* No cambiar el límite de resurrecciones si existe; esta HU solo corrige el spawn-kill.
* Si el jugador muere repetidamente en la misma oleada, mantener la inmunidad y el punto seguro; no reducirla.

#### 5. UI y feedback

* Orbes visibles con color claro (vida/maná) y VFX existente.
* Aviso de XP por oleada.
* Pantalla de cash-out con rareza mínima y pociones grandes.
* Indicador visual de inmunidad al respawn.
* Sin HUD nuevo permanente; usar notificaciones/UI del modo.
* Sin audio nuevo; usar SFX existentes si ya hay uno adecuado.

#### 6. Configuración y rendimiento

* Valores en config: intervalo/máximo/curación de orbes, XP por oleada, tabla de cash-out, inmunidad, HP/MP de respawn, radio seguro.
* No crear partículas por frame; pool/cleanup.
* No duplicar orbes/recompensas en rejoin o al cambiar de oleada.
* Compatibilidad con party 1–4 y `StreamingEnabled`.
* QA en PC/móvil y runs largas.

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Orbes periódicos

* **GIVEN** una run activa de Senda del Jotunn
* **WHEN** pasan 20–30 s
* **THEN** aparece un orbe de vida o maná en un punto seguro
* **AND** como máximo hay 3 orbes vivos
* **AND** el jugador recupera 20 % de MaxHP/MaxMP al tomarlo

#### Escenario 2: XP automática

* **GIVEN** una oleada completada
* **WHEN** empieza la siguiente
* **THEN** todos los participantes reciben XP automáticamente
* **AND** no hay que abrir un cofre ni reclamar
* **AND** no se duplica por rejoin/muerte

#### Escenario 3: Recompensa endgame

* **GIVEN** el cash-out de una oleada múltiplo de 10
* **WHEN** se genera la recompensa
* **THEN** no aparece ningún ítem blanco ni verde
* **AND** no aparece ninguna poción chica
* **AND** hay al menos 1 azul, oro relevante y pociones grandes

#### Escenario 4: Morado en hitos altos

* **GIVEN** una run en oleada 20, 30 o 40+
* **WHEN** se genera el cash-out
* **THEN** la probabilidad de morado sigue la tabla configurada
* **AND** nunca se garantiza un unique de jefe

#### Escenario 5: Respawn seguro

* **GIVEN** un jugador que muere en la arena
* **WHEN** reaparece
* **THEN** aparece en un punto seguro
* **AND** tiene 4 s de inmunidad visible
* **AND** los enemigos no lo atacan durante la inmunidad
* **AND** recupera 60 % de HP/MP

#### Escenario 6: Sin spawn-kill

* **GIVEN** enemigos cerca del punto de respawn
* **WHEN** el jugador reaparece
* **THEN** los enemigos son reubicados/ignoran al jugador
* **AND** no puede morir en el primer segundo por daño inevitable

#### Escenario 7: Party wipe

* **GIVEN** una party donde todos mueren
* **WHEN** no queda nadie vivo
* **THEN** la run termina
* **AND** no hay respawn infinito

#### Escenario 8: Regresión

* **GIVEN** las mejoras activas
* **WHEN** se juega Senda del Jotunn, campaña, party y vendors
* **THEN** el modo sigue siendo server-authoritative
* **AND** no hay errores rojos ni duplicados

---

### Comportamiento Visual / UI-UX

* Los orbes deben ser visibles y legibles en medio del combate.
* La XP automática debe sentirse como progreso, no como spam de notificaciones.
* El cash-out debe mostrar claramente que la recompensa es endgame.
* La inmunidad de respawn debe ser visible pero no tapar la acción.

---

### Alcance

#### Incluye

* Orbes de vida/maná periódicos y compartidos.
* XP automática por oleada.
* Cash-out solo azul/morado, pociones grandes y oro relevante.
* Respawn seguro con inmunidad, HP/MP y reset de aggro.
* QA PC/móvil y party.

#### No incluye

* Cambios a la estructura de oleadas, enemigos o jefes.
* Nuevos ítems, monedas, uniques o loot de campaña.
* Cambios de balance de clases/stats.
* Nuevos SFX o VFX finales.
* Respawn infinito o revives pagos.
* Cambios a la campaña de 5 pisos.

---

### Definition of Done (DoD)

* [ ] Orbes de vida/maná con spawn, máximo, curación y despawn.
* [ ] XP automática por oleada y conversión a oro en nivel máximo.
* [ ] Cash-out sin blancos/verdes ni pociones chicas; azul garantizado y morado por hito.
* [ ] Respawn seguro con 4 s de inmunidad y 60 % HP/MP.
* [ ] Reset/reubicación de enemigos para evitar spawn-kill.
* [ ] Party wipe termina la run; sin respawn infinito.
* [ ] QA PC/móvil y runs largas; sin duplicados.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).

---

### Decisiones por defecto

| Tema | Default |
|---|---|
| Nombre del modo | Senda del Jotunn |
| Orbes | Cada 25 s; máximo 3; 20 % HP/MP; 30 s de vida |
| XP por oleada | 15 + wave × 5; automática |
| Nivel máximo | Convertir XP a oro equivalente |
| Cash-out | Cada 10; azul garantizado; morado 20/35/50 %; pociones grandes; 300/600/1000/1500 oro |
| Blancos/verdes | Prohibidos en cash-out |
| Pociones chicas | Prohibidas en cash-out |
| Respawn | Punto seguro; 4 s de inmunidad; 60 % HP/MP |
| Spawn-kill | Enemigos a <20 studs reubicados/ignorados |
| Party wipe | Termina la run |
| Audio | Solo existente |

---

### Estimación (orientativa)

2–3 sesiones del dev: orbes, XP automática, tabla de loot, respawn/aggro y QA.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-11-12 | Creación de HU-R6.62: mejoras de Senda del Jotunn (ex Endless) — orbes de vida/maná, XP automática por oleada, cash-out endgame sin blancos/verdes/pociones chicas y respawn seguro con inmunidad y reset de aggro. |
