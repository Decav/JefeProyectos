# HU-R6.55: Mina Helada — caverna de mundo, enemigos y minería diaria (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Mundo / Actividades / Retención
**Prioridad:** Alta — actividad diaria y uso del mapa abierto
**Estado:** Abierta — lista para RC
**Tipo:** POI público + minería + variante de diaria (dev)
**Fase GDD:** Mundo / Hub / Economía
**Depende de:** HU-R6.49 (mapa/Hub), HU-R6.50 (diaria del Guía), HU-R6.53 (POIs/caminos), `EnemyConfig`/`EnemyService`, `QuestService`, `InventoryService`, `ItemConfig`, `ProximityPrompt`, HU-ESTETICA-53 (vetas/modelos; placeholders permitidos)
**Componentes observados:** `Río Escarchado`, `El Espejo Glacial`, `Avenida de los Antiguos`, `POI_CuevaHelada`, enemigos existentes, `QuestService`, `InventoryService`, `NotificationService`
**No modifica:** stats de enemigos, loot base, economía general, balance de clases, dungeon instanciada ni quests existentes.

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** entrar a una mina en la zona helada, pelear contra enemigos conocidos y picar minerales,
**para** tener una actividad diaria distinta que me saque del loop dungeon → pueblo.

**Como** equipo,
**quiero** una caverna pública con enemigos existentes, vetas por jugador y una variante de la diaria,
**para** agregar contenido repeatable sin crear enemigos, mapas ni economía nuevos.

---

### Descripción / Contexto

La zona helada necesita una actividad de mundo que no sea la dungeon instanciada. Esta HU agrega la **Mina Helada**:

* Una caverna pública en la zona helada, accesible caminando desde Valgard.
* Enemigos existentes (lobos de escarcha, ácaros, etc.) con respawn; sin jefes ni IA nueva.
* 6–8 vetas de mineral; cada jugador puede picar con su propio cooldown, sin competir por el nodo.
* Nueva variante de la misión diaria del Guía: **Mina Helada**.
* El mineral (`iron_ore`) se usa solo para la diaria; no se acumula ni se vende en esta HU.

**Criterio de hecho global:** el jugador puede entrar caminando a la Mina Helada, enfrentar enemigos existentes, picar 5 vetas con su misión diaria activa, completar la diaria y recibir su recompensa; no hay jefes, no se compite por nodos, no se acumulan minerales y la actividad no rompe la dungeon ni la economía.

---

### Especificaciones Técnicas / Contratos

#### 1. Ubicación y estructura

* Usar `POI_CuevaHelada` de HU-R6.53 como entrada o una cueva equivalente en `Río Escarchado`/`Avenida de los Antiguos`.
* La Mina Helada es una **zona pública del Hub**, no una place ni una dungeon instanciada.
* Sin pantalla de carga, sin portal, sin party obligatoria; se entra caminando.
* La cueva debe tener:
  * entrada visible y cartel,
  * 1 sala principal y 1–2 cámaras laterales,
  * 6–8 vetas de mineral,
  * 8–12 spawns de enemigos existentes,
  * salida clara; sin softlocks.
* No reutilizar el nombre `Dungeon_Helada` para evitar confusión con la dungeon de 5 pisos.

#### 2. Enemigos

* Usar **enemigos existentes** de `EnemyConfig` (por ejemplo, lobo de escarcha, ácaro de escarcha, etc.); no crear enemigos, jefes, élites ni IA nueva.
* 8–12 spawns; respawn 30–45 s; niveles acordes a la zona; sin jefes.
* Loot: usar la tabla existente de cada enemigo; no agregar loot exclusivo.
* No bloquear la entrada ni las vetas; mantener distancia de los prompts.
* Sin facciones nuevas ni eventos de mundo; eso queda para R6.61.

#### 3. Vetas y minería

* 6–8 vetas con `ProximityPrompt` (E/tap), `HoldDuration = 2 s`.
* Al completar:
  * validar que el personaje tenga la diaria `mine` activa,
  * validar cooldown del jugador para esa veta,
  * entregar **1 `iron_ore`**,
  * reproducir VFX/SFX existentes de golpe/mineral,
  * marcar cooldown por jugador (30–45 s); la veta no desaparece para otros.
* Sin misión activa: no entregar mineral; mostrar un aviso breve “El Guía tiene trabajo en la mina” y no iniciar el hold.
* Sin herramienta obligatoria en esta HU; el pico es visual. Si más adelante se agrega pico equipable, será otra HU.
* Sin inventario compartido ni depósito; el mineral va a la mochila solo mientras la diaria está activa.
* No se puede picar en combate; si el jugador recibe daño, se cancela el hold y no se entrega mineral.

#### 4. Nueva variante de diaria: `mine`

* Se agrega a la pool de la diaria del Guía (HU-R6.50); una variante por personaje/día.
* Objetivo:
  * picar **5 vetas** de la Mina Helada,
  * matar **6 enemigos** dentro de la mina.
* Progreso solo con la diaria activa; no se acumula antes ni después.
* `iron_ore` es ítem de misión:
  * aparece en la mochila,
  * no se vende, tradea ni usa en crafting,
  * se elimina al reclamar, abandonar o resetear,
  * no se guarda para el día siguiente.
* Recompensa por banda de nivel, alineada a HU-R6.50:
  * 1–5: 1 verde + 5 `potion_hp_large` + 30 oro,
  * 6–11: 1 verde + 5 `potion_hp_large` + 45 oro,
  * 12+: 1 azul + 5 `potion_hp_large` + 60 oro.
* Mantener 2 recompensas por personaje/día, reset 00:00 UTC, abandono con reintento y sin acumulación.
* El Guía sigue siendo el único giver; no crear un NPC nuevo.

#### 5. Datos, UI y anti-abuso

* Extender `activeChar.dailyQuest` con la variante `mine` y sus contadores; no crear un sistema de quests paralelo.
* `iron_ore` en `ItemConfig` con icono `Icon_Item_iron_ore` existente; registrar en `ASSETS_POLICY` si corresponde.
* El servidor valida distancia, misión activa, cooldown, daño recibido y cantidad; el cliente no decide drops.
* Sin duplicados al rejoin: el mineral y el progreso se derivan del estado de la diaria.
* Si la mochila está llena al reclamar, bloquear con aviso; no perder recompensa.
* Si el jugador abandona o resetea, eliminar los `iron_ore` pendientes.

#### 6. Rendimiento y navegación

* La cueva es pública; usar geometría simple, sin interiores pesados ni partículas excesivas.
* Los enemigos y vetas deben funcionar con `StreamingEnabled`.
* No bloquear el camino principal ni la entrada de la dungeon.
* QA en PC/móvil: entrar, pelear, picar, completar, salir y repetir sin softlocks.

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Entrar a la mina

* **GIVEN** el jugador en Valgard
* **WHEN** camina hacia la Mina Helada
* **THEN** entra sin pantalla de carga ni portal
* **AND** ve enemigos existentes y vetas de mineral
* **AND** la salida es clara

#### Escenario 2: Minería con diaria activa

* **GIVEN** un personaje con la diaria `mine` activa
* **WHEN** completa el hold de una veta
* **THEN** recibe 1 `iron_ore`
* **AND** la veta queda en cooldown solo para ese personaje
* **AND** otro jugador puede picar la misma veta

#### Escenario 3: Minería sin diaria

* **GIVEN** un personaje sin la diaria `mine`
* **WHEN** intenta picar
* **THEN** no recibe mineral
* **AND** se muestra un aviso breve para hablar con el Guía

#### Escenario 4: Completar la diaria

* **GIVEN** la diaria `mine` activa con 5 vetas y 6 enemigos
* **WHEN** el jugador completa los objetivos
* **THEN** puede reclamar la recompensa de su banda de nivel
* **AND** los `iron_ore` pendientes se eliminan
* **AND** no se puede reclamar dos veces

#### Escenario 5: Enemigos y respawn

* **GIVEN** la mina activa
* **WHEN** el jugador mata enemigos
* **THEN** usan el loot existente y respawnean
* **AND** no hay jefes, élites ni IA nueva

#### Escenario 6: Anti-abuso

* **GIVEN** un intento de picar o reclamar fuera de rango, en combate o sin misión
* **WHEN** el servidor valida
* **THEN** bloquea la acción
* **AND** no entrega mineral, progreso ni recompensa

#### Escenario 7: Regresión

* **GIVEN** la mina implementada
* **WHEN** se juega hub → dungeon → hub y las diarias existentes
* **THEN** la dungeon, el Guía, la tienda, el inventario y las otras variantes siguen funcionando
* **AND** no hay errores rojos

---

### Comportamiento Visual / UI-UX

* La entrada debe leerse como una mina, no como una dungeon instanciada.
* Las vetas deben destacar sin saturar; el prompt aparece al acercarse.
* El progreso de la diaria se ve en el tracker existente.
* No agregar minimapa, iconos permanentes ni una UI nueva.

---

### Alcance

#### Incluye

* Caverna pública en la zona helada.
* Enemigos existentes con respawn.
* 6–8 vetas con cooldown por jugador.
* Nueva variante de diaria `mine`.
* `iron_ore` como ítem de misión.
* QA PC/móvil y documentación.

#### No incluye

* Enemigos, jefes, élites o IA nuevos.
* Dungeon instanciada nueva o portal.
* Pico equipable, crafting, fundición o economía de minerales.
* Loot exclusivo, eventos de mundo, caravanas ni campamentos.
* UI nueva de minería o minimapa.

---

### Definition of Done (DoD)

* [ ] Mina accesible caminando, sin portal ni carga.
* [ ] 8–12 enemigos existentes con respawn y loot existente.
* [ ] 6–8 vetas con prompt y cooldown por jugador.
* [ ] Diaria `mine` con 5 vetas + 6 enemigos y recompensas por banda.
* [ ] `iron_ore` no acumulable, no vendible y eliminado al cerrar la diaria.
* [ ] Sin duplicados ni entrega fuera de rango/combate.
* [ ] Sin softlocks; salida clara; QA PC/móvil.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).

---

### Decisiones por defecto

| Tema | Default |
|---|---|
| Ubicación | Cueva en la zona helada, entrada caminable |
| Enemigos | Existentes; 8–12 spawns; sin jefes |
| Vetas | 6–8; cooldown 30–45 s por jugador |
| Ítem | `iron_ore`; solo diaria; no se vende |
| Diaria | 5 vetas + 6 enemigos |
| Recompensas | Iguales a HU-R6.50 por banda de nivel |
| Reset | 00:00 UTC; 2 recompensas por personaje |
| Herramienta | Ninguna en esta HU; pico visual |
| Instancia | Pública; sin party obligatoria |

---

### Estimación (orientativa)

2–3 sesiones del dev: cueva/spawns, vetas/cooldown, variante de diaria, ítem, anti-abuso y QA.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-11-12 | Creación de HU-R6.55: Mina Helada pública con enemigos existentes, vetas de mineral por jugador y nueva variante de diaria `mine` con `iron_ore`. |
