# HU-R6.61: Eventos de mundo — caravanas atacadas y campamentos enemigos (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Mundo / Eventos / Retención
**Prioridad:** Media — sorpresa y actividad en los caminos
**Estado:** Abierta — lista para RC
**Tipo:** Eventos dinámicos + campamentos (dev)
**Fase GDD:** Mundo / Hub / Actividades
**Depende de:** R6.49 (mapa), R6.53 (POIs/caminos), R6.55 (Mina Helada), enemigos existentes, `EnemyService`, `NotificationService`, `ZoneService`, `DataService`, HU-ESTETICA-53 (props de caravana/campamento; placeholders permitidos)
**Componentes observados:** caminos de Valgard, `El Espejo Glacial`, `Avenida de los Antiguos`, enemigos existentes, NPCs ambientales, notificaciones, zona
**No modifica:** stats, loot base, economía, quests, dungeon, clases ni balance de combate.

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** encontrar caravanas atacadas y campamentos enemigos mientras recorro el mundo,
**para** que los caminos tengan sorpresa, acción y recompensas sin depender de la dungeon.

**Como** equipo,
**quiero** eventos acotados que reutilicen enemigos y assets existentes,
**para** dar vida al mundo sin crear enemigos, mapas ni sistemas de combate nuevos.

---

### Descripción / Contexto

Los caminos necesitan algo más que paisaje. Esta HU agrega dos actividades de mundo:

* **Caravana atacada:** cada X minutos, una caravana de NPCs recorre un tramo y es atacada por enemigos existentes; los jugadores la defienden y reciben recompensa.
* **Campamentos enemigos:** 2–3 campamentos en la zona helada con enemigos existentes; se pueden limpiar para loot/actividad.

**Criterio de hecho global:** la caravana aparece, avanza, es atacada y puede defenderse con recompensa; los campamentos tienen enemigos existentes, respawn y recompensa acotada; ambos eventos son server-authoritative, no rompen la dungeon ni la economía y no requieren enemigos o mapas nuevos.

---

### Especificaciones Técnicas / Contratos

#### 1. Caravana atacada

* Frecuencia: cada 30–60 min por servidor (configurable); no se solapa con otra caravana.
* Ruta: tramo seguro de `Río Escarchado`/`Avenida de los Antiguos`, sin entrar al Santuario ni a la dungeon.
* Composición:
  * 2–3 NPCs de caravana (R15 existentes/EST-53),
  * 1 carro/props de EST-53 o placeholder,
  * 2 guardias ambientales,
  * enemigos existentes que atacan en 2–3 oleadas.
* Flujo:
  1. Anuncio de evento en el Hub/notificación.
  2. La caravana aparece y avanza lentamente por waypoints.
  3. En un punto fijo, spawn de enemigos existentes; los jugadores deben defender.
  4. Si la caravana sobrevive, se abre recompensa/cofre y se anuncia el éxito.
  5. Si la caravana es destruida, el evento termina sin recompensa mayor.
* Los NPCs de caravana no son targeteables por jugadores ni sufren friendly fire; los enemigos sí.
* Sin PvP; sin daño entre jugadores.
* La recompensa se otorga a quienes participaron (daño/curas/cerca) con un umbral mínimo; evitar leech desde el Hub.
* Sin nuevos enemigos, jefes ni IA; usar `EnemyConfig` existente.
* Duración acotada (3–5 min); cleanup de NPCs, enemigos, carro y VFX al terminar.

#### 2. Campamentos enemigos

* 2–3 campamentos estáticos en la zona helada, cerca de caminos/POIs, sin bloquear la ruta.
* Composición: tiendas, cajas, empalizada, fogata y props de EST-53 o placeholders.
* 4–6 enemigos existentes por campamento; respawn 60–120 s; sin jefes.
* Limpiar el campamento otorga:
  * un cofre/inventario de campaña con loot existente (oro/ítem verde/azul),
  * progreso para la actividad/quest si aplica.
* No crear loot exclusivo, moneda nueva ni facción.
* El campamento no es una dungeon ni una instancia; es una zona pública.
* Los enemigos no deben salir del radio del campamento ni perseguir hasta el spawn.

#### 3. Recompensas

* Caravana:
  * oro + XP,
  * 1 ítem verde/azul de pool existente,
  * posible cofre compartido con contribution.
* Campamento:
  * oro + XP,
  * 1 ítem de pool existente con cooldown/respawn.
* Sin uniques de jefe, sin morados garantizados, sin pay-to-win.
* Recompensa server-authoritative; no se puede reclamar dos veces por evento.
* Si el jugador no participó, no recibe recompensa.

#### 4. Estado y anti-abuso

* Estado del evento en memoria del servidor; no cross-server.
* Un evento activo por tipo; no acumular caravanas/campamentos.
* Validar daño/cura/participación en servidor; no aceptar contribución del cliente.
* No se puede dañar la caravana siendo jugador; no hay PvP.
* No se puede farmear el mismo campamento sin respawn; cooldown de recompensa.
* Si el servidor se reinicia, el evento se cancela y se regenera; sin recompensas pendientes.
* No ejecutar eventos en `Dungeon_Helada`; gate por `Workspace.Valgard`.

#### 5. UI y notificaciones

* Anuncio de caravana con zona y tiempo restante usando `NotificationService`.
* Aviso de éxito/fallo; sin UI nueva.
* El campamento se descubre caminando; sin minimapa ni iconos permanentes.
* El cofre de caravana usa el sistema de loot existente.
* PC/móvil; textos cortos y legibles.

#### 6. Rendimiento

* Limitar enemigos vivos por evento; no acumular NPCs/enemigos si no hay jugadores.
* Cleanup al terminar o al reiniciar; no loops huérfanos.
* Compatible con `StreamingEnabled`; no forzar carga de toda la zona.
* QA en solo/party, PC/móvil y servidor vacío.

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Caravana aparece

* **GIVEN** un servidor con jugadores en el Hub
* **WHEN** llega el horario del evento
* **THEN** se anuncia la caravana
* **AND** la caravana aparece y avanza por su ruta

#### Escenario 2: Defensa

* **GIVEN** la caravana en marcha
* **WHEN** aparecen los enemigos existentes
* **THEN** los jugadores pueden defenderla
* **AND** los NPCs de caravana no reciben friendly fire
* **AND** no hay PvP

#### Escenario 3: Éxito

* **GIVEN** la caravana sobrevive
* **WHEN** termina el evento
* **THEN** los participantes reciben recompensa
* **AND** se anuncia el éxito
* **AND** no se puede reclamar dos veces

#### Escenario 4: Fallo

* **GIVEN** la caravana es destruida
* **WHEN** termina el evento
* **THEN** no hay recompensa mayor
* **AND** el evento se limpia sin errores

#### Escenario 5: Campamento

* **GIVEN** un campamento enemigo
* **WHEN** el jugador lo limpia
* **THEN** obtiene loot existente y progreso
* **AND** los enemigos respawnean tras el cooldown

#### Escenario 6: Anti-leech

* **GIVEN** un jugador que no participó
* **WHEN** termina el evento
* **THEN** no recibe recompensa
* **AND** no puede reclamar desde el Hub

#### Escenario 7: Rendimiento y dungeon

* **GIVEN** un evento activo
* **WHEN** se juega la campaña de 5 pisos
* **THEN** la dungeon no se ve afectada
* **AND** no hay errores rojos ni NPCs acumulados

#### Escenario 8: Regresión

* **GIVEN** caravanas y campamentos activos
* **WHEN** se juega hub, mina, Endless y quests
* **THEN** todo sigue funcionando
* **AND** no hay errores rojos

---

### Comportamiento Visual / UI-UX

* La caravana debe ser visible desde el camino y sentirse parte del mundo.
* Los campamentos deben leerse como peligro, no como decoración.
* El anuncio debe ser claro pero no invasivo.
* Sin minimapa ni marcadores permanentes.

---

### Alcance

#### Incluye

* Evento de caravana atacada con enemigos existentes.
* 2–3 campamentos enemigos con respawn.
* Recompensas acotadas y contribution.
* Anuncios/notificaciones.
* Cleanup, anti-abuso y QA.

#### No incluye

* Enemigos, jefes, facciones o IA nuevos.
* PvP, friendly fire o daño a NPCs de caravana.
* Dungeon/instancia nueva.
* Loot exclusivo, moneda nueva o pay-to-win.
* Minimapa, iconos permanentes o UI nueva.

---

### Definition of Done (DoD)

* [ ] Caravana con ruta, oleadas, éxito/fallo y recompensa.
* [ ] 2–3 campamentos con enemigos existentes y respawn.
* [ ] Contribution server-authoritative; sin leech.
* [ ] Sin friendly fire ni PvP.
* [ ] Cleanup y rendimiento estables.
* [ ] QA solo/party, PC/móvil y servidor vacío.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).

---

### Decisiones por defecto

| Tema | Default |
|---|---|
| Caravana | Cada 30–60 min; 2–3 oleadas |
| Ruta | Río Escarchado/Avenida, sin Santuario |
| Enemigos | Existentes; sin jefes |
| Campamentos | 2–3; 4–6 enemigos; respawn 60–120 s |
| Recompensa | Oro/XP + ítem existente |
| PvP | No |
| Friendly fire | No |
| UI | Notificaciones existentes |
| Estado | Por servidor, sin cross-server |

---

### Estimación (orientativa)

3–5 sesiones del dev: caravana, oleadas, campamentos, recompensas, anti-abuso y QA.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-11-12 | Creación de HU-R6.61: eventos de caravana atacada y campamentos enemigos con enemigos existentes, recompensas acotadas, contribution server-authoritative y sin PvP ni friendly fire. |
