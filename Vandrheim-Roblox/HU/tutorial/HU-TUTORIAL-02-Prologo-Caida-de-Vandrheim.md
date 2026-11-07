# HU-TUTORIAL-02: Prólogo — La caída de Vandrheim (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Tutorial / Onboarding / Retención
**Prioridad:** Alta — primera sesión y conversión de ads
**Estado:** Implementada y validada funcionalmente por el PO (2026-11-04); QA/performance pendiente
**Tipo:** Contenido de prólogo jugable + NPC guía + misión guionizada (dev)
**Fase GDD:** Tutorial 2 (adelanto de R10+; decisión PO 2026-10-27)
**Depende de:** HU-R2 (selección/creación de PJ), HU-QUEST-01/02 (sistema de misiones y quest de onboarding), HU-TUTORIAL-01 (onboarding por tarjetas; se coordina), HU-R3/MOBS + SKILLS_CATALOG (skills por spec), HU-R6b/R6.3 (kit de la Helada), HU-R7.1 + HU-ESTETICA-36 (Jotunn), HU-ITEMS-04/06 (sets azules y armas épicas), HU-ESTETICA-02 (enemigos de la Helada), `DataService`
**No modifica:** creación de personaje (R2), reglas de combate, economía, balance de clases ni el contenido de la Helada jugable.

---

### Narrativa (INVEST)

**Como** jugador nuevo que llega desde un anuncio,
**quiero** empezar jugando de inmediato con un héroe poderoso y vivir una derrota que me explique el mundo,
**para** entender de qué va Vandrheim y querer crear mi personaje después de haber jugado, no antes.

**Como** equipo,
**quiero** mover la creación de personaje detrás de una experiencia jugable corta,
**para** reducir el abandono que hoy ocurre entre el clic del anuncio y el primer minuto de juego.

---

### Descripción / Contexto

La analítica de ads muestra abandono al entrar: el jugador ve la creación de personaje y se va antes de jugar. La misión de onboarding (`HU-QUEST-02`) ya guía correctamente, pero llega después de la creación.

Este prólogo pone **acción antes que formulario**: el jugador elige clase, juega una introducción de 3–4 minutos con un héroe predefinido de nivel 20, cae ante Jotunn y solo entonces crea su personaje, ya con la clase elegida.

**Criterio de hecho global:** un jugador sin `prologueStage` completado vive el prólogo (pack → Jotunn → derrota guionizada → creación con clase precargada) sin panel de muerte ni pérdidas reales; al llegar al pueblo, el NPC del hub cierra la misión, entrega 50 oro + 5 pociones y le da la quest de onboarding. Un jugador con el prólogo cerrado nunca lo repite.

---

### Flujo

1. Entrada sin `prologueStage` (o en `cave`) → pantalla de selección de clase (3 tarjetas: Paladín, Cazador, Clérigo).
2. Se carga el prólogo con el héroe predefinido de esa clase.
3. Sala 1: el NPC inicia “La caída de Vandrheim”. El jugador limpia 5 caballeros helados + 2 arqueros helados.
4. Al limpiar el pack, se abre la puerta a la sala 2.
5. Sala 2: Jotunn. Combate de ~20–25 s con derrota inevitable.
6. Sin panel de resurrección: diálogo del NPC de la caverna (te envía a salvo al pueblo, pierdes los poderes). **No completa la misión ni entrega nada.**
7. Creación de personaje con la clase precargada; el jugador escribe su nombre (reglas R2) y confirma. `prologueStage = town`.
8. Aparece en el hub a nivel 1 con la misión **activa**: “Habla con el Guía”.
9. Al hablar con el NPC del pueblo se **completa la misión**, se entrega la recompensa y el mismo Guía ofrece la quest de onboarding `intro_helada`. `prologueStage = done`.
10. Jugadores con `prologueStage = done`: la pantalla del prólogo se muestra con **Omitir**; si omiten, van a selección de personaje.

---

### Especificaciones Técnicas / Contratos

#### 1. Elegibilidad y persistencia

* Estado **por cuenta (`UserId`)**, no por personaje ni por slot: `prologueStage`.
  * `nil` o ausente → no iniciado.
  * `cave` → en la caverna o a mitad del combate.
  * `town` → ya jugó la caverna y creó personaje; falta cerrar con el NPC del pueblo.
  * `done` → misión cerrada y recompensa entregada.
* Se guarda bajo el contrato de ECON-03/`DataService` (escritura del dueño del perfil, idempotente).
* La caverna solo se puede jugar con `stage` `nil`/`cave`; con `town` o `done` nunca se repite.
* El progreso de la caverna (`prologueStep`) vive en la capa de cuenta porque **todavía no existe personaje**.
* La misión del prólogo (`prologo_caida_vandrheim`) usa el HUD/tracker/marcadores de QUEST-01, pero su estado de cuenta sobrevive al teleport y a la creación.
* Cerrar la misión pasa `stage` a `done` **una sola vez**; reconexiones o reintentos no duplican recompensa.

#### 2. Selección de clase

* Tres tarjetas con icono de clase (EST-24), nombre y una línea de rol. Sin textos largos.
* La clase elegida se guarda como **clase preseleccionada** para la creación del personaje.
* No se elige spec en el prólogo: la spec ofensiva va fija por clase (ver §3). La spec real se elige después en el flujo normal de R2/R5.

#### 3. Héroe predefinido (nivel 20)

| Clase | Spec del prólogo | Set | Arma épica |
|---|---|---|---|
| Paladín | **Castigo** | Azul de Paladín | Espada o espadón épico |
| Cazador | **Asalto** | Azul de Cazador | Espada o espadón épico (melee, con afinidad de Cazador) |
| Clérigo | **Cólera** | Azul de Clérigo | Varita épica |

* Nivel 20 con el set azul completo y arma épica equipados; visual correcto vía `EquipmentVisualService`.
* **4 skills** de la rama ofensiva de su spec, al rango máximo: 1 AoE/multiobjetivo, 1 single-target, 1 movilidad o defensiva, 1 ultimate.
* Los `skillId` concretos se toman de `SKILLS_CATALOG`; no se crean skills nuevas.
* El Cazador usa Asalto (melee) para evitar kiteo y unificar el tuning del encuentro.
* Sin inventario persistente: el héroe es una plantilla temporal, no un personaje de la cuenta.

#### 4. Zona del prólogo

* Caverna helada de **2 salas** con el kit de la Helada; ambiente de hielo, iluminación fría y puerta entre salas.
* **Sala 1:** NPC guía + pack inicial. **Sala 2:** arena de Jotunn.
* **Decisión PO: place separado** del Hub, con atmósfera de hielo propia. Así la iluminación y el ambiente no se contaminan con el pueblo.
* **Entrada:** al unirse con `prologueStage` nulo o `cave`, el jugador va al place del prólogo (clase primero, luego carga). Usar una pantalla de carga temática (“La caída de Vandrheim”) para que la espera no se lea como error.
* **Salida:** al cerrar el diálogo del NPC, teleport de vuelta al place principal con `returnToCreation = true`; allí abre la creación de personaje (R2). Esa transición es la única carga adicional aceptable, y ocurre después de 3–4 minutos jugados.
* **Fallback:** si el teleport falla o tarda demasiado, no bloquear al jugador: reintentar una vez y, si falla, enviarlo al flujo normal de selección/creación sin marcar el prólogo como completado.
* El place debe ser liviano (StreamingEnabled, assets mínimos) para que la carga sea corta.
* Sin trade, subasta, vendors ni economía real durante el prólogo.

#### 5. Paso 1 — Las últimas fuerzas

* `prologo_step_1`: derrotar **5 caballeros helados + 2 arqueros helados**.
* Los enemigos son de nivel alto pero el héroe nivel 20 los limpia con comodidad; objetivo ~45–60 s.
* No otorgan XP, oro ni loot persistentes.
* Al morir el último enemigo, se abre la puerta y avanza la misión.

#### 6. Paso 2 — Jotunn (derrota guionizada)

* `prologo_step_2`: enfrentar a Jotunn.
* **La derrota es obligatoria**: Jotunn tiene vida efectivamente inmatable y un golpe/fase final que derriba al jugador al cumplir ~20–25 s o al bajar la vida del jugador.
* Se recomienda fase guionizada en lugar de solo balance: HP enorme + daño alto + evento final, para garantizar el mismo resultado con las 3 clases.
* El jugador puede moverse y usar skills; no puede ganar.
* Al activarse la derrota, se corta el control y se reproduce la secuencia del NPC.

#### 7. Derrota sin penalización

* **No** aparece el panel de muerte ni la opción de revivir.
* **No** se consume resurrección, Revive, Robux ni `pendingRevives`.
* **No** hay pérdida de XP, oro ni ítems.
* Al terminar, HP/MP restaurados y el jugador pasa a la creación de personaje.

#### 8. Diálogo del NPC y transición

* El NPC guía aparece tras la derrota: explica que Vandrheim está en peligro y que te enviará a salvo al pueblo, pero perderás tus poderes.
* Diálogo corto (3 líneas máximo), con avance por clic/toque y saltable con una sola pulsación. Sin auto-avance.
* Al confirmar, se transiciona a la creación de personaje.
* **El NPC de la caverna no completa la misión ni entrega recompensa:** solo te envía al pueblo. El cierre ocurre con el NPC del hub (§9.1).

**Texto canónico (3 líneas, tono épico):**

1. “Has caído, pero Vandrheim aún respira en ti.”
2. “Te llevaré al pueblo; allí tus poderes serán solo un recuerdo.”
3. “Levántate. Aún hay algo que puedes salvar.”

* Botón de cierre: **“Despertar en Vandrheim”**.
* Speaker: NPC Guía de la Helada (reutilizar modelo/retrato existente).
* La recompensa **no** se enumera en el diálogo: al aparecer en el hub, el aviso de bienvenida muestra “50 de oro · 5 pociones de vida” para que se entienda de dónde salió.

**Alternativas aprobadas:**

| Tono | Texto |
|---|---|
| Clásica | “Basta. Jotunn es demasiado para ti… todavía.”<br>“Te sacaré de aquí. Despertarás en el pueblo, sin tus antiguos poderes.”<br>“Los ancianos te darán oro y provisiones. Lo que fuiste se queda en el hielo; lo que serás empieza ahora.” |
| Directa | “Jotunn no perdona. Te saco de aquí; despertarás en el pueblo sin tus poderes.”<br>“Los ancianos te darán oro y pociones: tu aventura empieza de cero.” |

#### 9. Creación de personaje

* Se abre el flujo normal de R2 con la **clase ya precargada** desde el prólogo.
* El jugador escribe su nombre y confirma en la misma pantalla.
* Validación de nombre exactamente R2: 3–16 caracteres, alfanumérico con espacios internos limitados, trim, filtro de Roblox, sin unicidad global.
* **No** se otorga ni descuenta `token_rename`; el nombre elegido es definitivo salvo compra posterior en la tienda. No se regalan renombres por el prólogo.

#### 9.1. Cierre en el pueblo y recompensa

* Al spawnear en el hub, la misión `prologo_caida_vandrheim` sigue **activa** con objetivo “Habla con el Guía”.
* El NPC del pueblo (Guía de la Helada, el mismo giver de QUEST-02) hace el cierre:
  * reconoce que volviste,
  * completa la misión,
  * entrega **50 de oro + 5 pociones de vida**,
  * y ofrece la quest de onboarding `intro_helada`.
* La recompensa va al **personaje creado** (nunca al héroe temporal) y es idempotente por `UserId` + transición a `prologueStage = done`.
* Si la mochila no admite las pociones (caso improbable: 5 = 1 slot de pila), la entrega queda **pendiente** en el buzón de bienvenida y no se pierde.
* La misión **no** se completa automáticamente al spawnear: requiere hablar con el NPC.
* Si el jugador se desconecta antes de hablar, al reentrar sigue en el hub con la misión activa y `prologueStage = town`.
* Sin NPC duplicado ni teleport extra: el Guía del hub sirve para cerrar el prólogo y arrancar el onboarding.

**Línea sugerida del NPC del pueblo:**

> “Has vuelto. Vandrheim te recibe con lo que puede darte: 50 de oro y cinco pociones.”
> “La Helada sigue llamando… y tú ya tienes una razón para responder.”

#### 10. Veteranos y reentradas

* Si `prologueStage = done`: la pantalla del prólogo se muestra con **Omitir** visible desde el inicio; omitir lleva a selección de personaje y mantiene el estado.
* Si `prologueStage = town`: no se repite la caverna; el jugador va directo al hub a cerrar con el Guía.
* No se fuerza el prólogo a cuentas con personajes existentes; pueden verlo si quieren.
* Si el jugador se desconecta a mitad:
  * Antes del paso 2: reanuda en el paso actual.
  * Durante el combate con Jotunn: reinicia solo ese paso.
* Salir de la caverna sin completarla no cambia el estado.

#### 11. Móvil y rendimiento

* Debe ser jugable en móvil horizontal: joystick, skillbar táctil y targets ≥44×44 px.
* La zona debe cargar rápido y no introducir esperas largas antes del primer enemigo.
* Objetivo: **primer enemigo muerto en <60 s** desde el clic del anuncio.

#### 12. Analítica (embudo)

Registrar eventos: `prologue_place_entered`, `prologue_started`, `prologue_class_selected`, `prologue_npc_talked`, `prologue_pack_cleared`, `prologue_jotunn_defeat`, `prologue_skipped`, `prologue_return_teleport`, `character_created_after_prologue`, `hub_spawned`, `prologue_town_npc_talked`, `prologue_mission_completed`, `welcome_reward_granted`, `onboarding_quest_offered`.

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Primer acceso

* **GIVEN** una cuenta sin `prologueStage`
* **WHEN** entra al juego
* **THEN** ve la selección de clase en 3 tarjetas y, al elegir, entra al prólogo con el héroe nivel 20 de esa clase

#### Escenario 2: Pack inicial

* **GIVEN** el prólogo iniciado y la misión activa
* **WHEN** derrota a los 5 caballeros helados y 2 arqueros helados
* **THEN** la puerta a la sala 2 se abre y la misión avanza al paso de Jotunn
* **AND** no recibe XP, oro ni loot persistentes

#### Escenario 3: Derrota guionizada

* **GIVEN** el jugador frente a Jotunn
* **WHEN** pasan ~20–25 s de combate o su vida llega al umbral
* **THEN** Jotunn lo derrota de forma guionizada
* **AND** no aparece el panel de muerte, no se consume revive y no pierde nada

#### Escenario 4: Transición a creación

* **GIVEN** la derrota completada
* **WHEN** el dialogo del NPC de la caverna termina
* **THEN** se abre la creación de personaje con la clase elegida ya precargada
* **AND** el nombre se valida según R2 y no se otorga `token_rename`
* **AND** la misión sigue activa y sin recompensa entregada

#### Escenario 5: Llegada al pueblo

* **GIVEN** el personaje creado tras el prólogo
* **WHEN** entra al hub
* **THEN** aparece a nivel 1 con la misión activa “Habla con el Guía”
* **AND** todavía no recibió oro ni pociones

#### Escenario 5a: Cierre con el NPC del pueblo

* **GIVEN** la misión activa en el hub
* **WHEN** habla con el Guía de la Helada
* **THEN** la misión se completa, recibe **50 oro + 5 pociones de vida** una sola vez
* **AND** el mismo Guía le ofrece la quest de onboarding `intro_helada`
* **AND** `prologueStage = done`

#### Escenario 6: Veterano

* **GIVEN** una cuenta con `prologueStage = done`
* **WHEN** entra al juego
* **THEN** ve la pantalla del prólogo con opción **Omitir**
* **AND** al omitir va a selección de personaje sin repetir la experiencia

#### Escenario 6a: Pendiente de cerrar en el pueblo

* **GIVEN** una cuenta con `prologueStage = town`
* **WHEN** entra al juego
* **THEN** no repite la caverna; aparece en el hub con la misión activa para hablar con el Guía

#### Escenario 7: Abandono y reentrada

* **GIVEN** un prólogo incompleto
* **WHEN** el jugador se desconecta y vuelve
* **THEN** reanuda en el paso actual (o reinicia solo el combate con Jotunn)
* **AND** no obtiene el flag ni recompensas por duplicado

#### Escenario 8: Sin economía durante el prólogo

* **GIVEN** el jugador dentro del prólogo
* **WHEN** intenta abrir trade, subasta o vendor
* **THEN** esas acciones están deshabilitadas

---

### Alcance

#### Incluye

* Pantalla de selección de clase con precarga para la creación.
* Zona de prólogo de 2 salas en **place separado**, con NPC, pack de 7 enemigos y arena de Jotunn.
* Héroe temporal nivel 20 (set azul + épica + 4 skills) para las 3 clases.
* Misión guionizada de 2 pasos y derrota sin penalización.
* Persistencia del flag por cuenta, reanudación y opción Omitir para veteranos.
* Eventos de analítica del embudo.

#### No incluye

* Cambios a la creación de personaje, combate, skills, economía o balance.
* Contenido nuevo de la Helada jugable ni rediseño del hub.
* Renombres gratuitos, tokens o recompensas permanentes (pendiente de decisión PO).

---

### Definition of Done (DoD)

* [ ] `prologueStage` por `UserId` (`nil` → `cave` → `town` → `done`); `prologueStep` permite reanudar; cerrar no duplica estado ni recompensas.
* [ ] Selección de clase → héroe nivel 20 con set azul, arma épica y 4 skills de la spec ofensiva (Castigo / Asalto / Cólera).
* [ ] Zona de 2 salas: pack de 5 caballeros + 2 arqueros, puerta y arena de Jotunn.
* [ ] Prólogo en **place separado**, con carga temática, teleport de ida y vuelta al place principal y fallback si el teleport falla.
* [ ] Jotunn derrota siempre en ~20–25 s sin que pueda ser vencido, con las 3 clases.
* [ ] Derrota sin panel de muerte, sin revives, sin pérdida de XP/oro/ítems.
* [ ] Diálogo del NPC de la caverna (3 líneas + “Despertar en Vandrheim”) y transición a creación con clase precargada; **no** completa la misión.
* [ ] Al llegar al hub, la misión sigue activa con objetivo “Habla con el Guía”; el Guía la completa, entrega **50 oro + 5 pociones de vida** una sola vez y ofrece `intro_helada`.
* [ ] Recompensa idempotente por `UserId`, al personaje creado (nunca al héroe del prólogo), con fallback a buzón si no cabe.
* [ ] Nombre validado por R2; no se regala ni consume `token_rename`.
* [ ] Veteranos (`done`) ven Omitir; `town` no repite la caverna; omitir no rompe nada.
* [ ] Trade, subasta y vendors deshabilitados durante el prólogo.
* [ ] Móvil horizontal jugable, targets ≥44×44 px y primer enemigo en <60 s desde el anuncio.
* [ ] Eventos de analítica del embudo registrados.
* [ ] Sin errores rojos; QA en Studio y móvil; nota en GDD.

---

### Decisiones cerradas (PO 2026-10-27)

1. **Ubicación:** **place separado** del Hub, con atmósfera de hielo propia y pantalla de carga temática.
2. **Recompensa al completar:** **50 de oro + 5 pociones de vida** al primer personaje creado; sin cosmético ni título por ahora.
3. **Texto final del NPC:** el canónico de §8 (“Basta. Jotunn es demasiado para ti… todavía.”), con alternativa directa y épica aprobadas.

---

### Estimación (orientativa)

4–6 sesiones del dev: zona y encuentros, héroe temporal y tuning por clase, flujo de cuenta/flag, diálogos, creación precargada, analítica y QA móvil. Reutiliza kit de la Helada, Jotunn y enemigos existentes.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-10-27 | Creación de HU-TUTORIAL-02: prólogo jugable antes de la creación de personaje (selección de clase, héroe nivel 20, pack de 7 enemigos, derrota guionizada ante Jotunn, NPC y transición), con flag por cuenta y opción Omitir para veteranos. |
| 2026-10-27 | Decisiones PO: prólogo en **place separado**; recompensa de **50 oro + 5 pociones de vida** al primer personaje; texto canónico épico del NPC y alternativas aprobadas. |
| 2026-10-27 | El cierre pasa al **NPC del pueblo**: la caverna solo envía al hub; el Guía completa la misión, entrega la recompensa y da la quest de onboarding. Estado por cuenta `nil → cave → town → done`. |
| 2026-10-27 | Implementado según reporte del PO. Pendiente: QA en móvil/PC, verificación del funnel y nota en GDD. |
| 2026-11-04 | **Validación funcional del PO:** prólogo, misiones y tutorial funcionan como se espera. Queda QA/performance y el fix de música de Jotunn (R6.47). |
