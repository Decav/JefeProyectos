## HU-R6.11: Nameplates de enemigos (barra de vida sobre el enemigo, toggleable)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Combate / UI / R6.11
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Sistema nuevo de UI en el mundo (dev) + estilo definido por el diseñador (HU-ESTETICA-19 y tokens Hearthbound Gold)
**Fase GDD:** R6.11 (mejora transversal de combate; sin cambios a daño, targeting ni balance)
**Depende de:** HU-R6a (enemigos con atributos `HP`/`MaxHP`/`Enemy`), HU-R1 (dummy), HU-R6.5 (HUD/toggle UX), HU-ESTETICA-04/19 (estilo Hearthbound Gold)
**Componentes observados:** `ServerScriptService.Services.EnemyService`, `ReplicatedStorage.Config.EnemyConfig`, enemigos/dummy con `Humanoid`, atributos `HP`/`MaxHP`/`Dead`

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** ver la barra de vida del enemigo sobre su cabeza (nameplate) y poder mostrarla u ocultarla con una tecla,
**para** leer el estado de cada enemigo en combate sin depender solo del target frame.

**Como** equipo de desarrollo,
**quiero** desactivar la barra de vida nativa de Roblox en los enemigos,
**para** que no haya dos barras superpuestas y el nameplate propio sea la única fuente visual de vida.

---

### **Descripción del Requerimiento / Contexto**

Hoy los enemigos (dummy y enemigos de dungeon) muestran la **barra de vida nativa de Roblox** (`Humanoid` default) sobre sus cabezas, y el único estado de vida en UI es el `TargetFrame` del HUD cuando el enemigo está en target. No existe un nameplate propio ni un toggle para ocultarlo.

Esta HU agrega un **sistema de nameplates**:

1. **Desactivar la barra nativa** de Roblox en todos los enemigos (`Humanoid.HealthDisplayType = AlwaysOff` y `Humanoid.DisplayDistanceType = None`), de modo que nunca se vean dos barras.
2. **Nameplate propio**: barra de vida (y nombre opcional) sobre la cabeza del enemigo, estilo Hearthbound Gold, con los atributos `HP`/`MaxHP` existentes.
3. **Toggleable**: una tecla (default propuesto `N`) y botón móvil muestran/ocultan los nameplates; la preferencia persiste por personaje.
4. Aplicable a **dummy y a todos los enemigos de dungeon** (no al jugador: su vida sigue en el player frame).

**Criterio de hecho global:** cada enemigo muestra exactamente **una** barra de vida (la propia), la nativa de Roblox está desactivada, y el jugador puede ocultarla/mostrarla con la tecla de toggle.

---

### **Especificaciones Técnicas / Contratos de API**

#### **Desactivar la barra nativa de Roblox**

* En el spawn de todo enemigo (dummy R1 y enemigos de `EnemyService`) se configura el `Humanoid`:
  * `Humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff`
  * `Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None`
* Aplica también a modelos que reutilicen clones con `Humanoid` (p. ej. body skins del jugador **no** — el jugador conserva su player frame; esta regla es solo para enemigos).
* Si el enemigo se crea después del spawn (spawns procedurales), el nameplate y la desactivación se aplican al momento de creación, no en un loop.

#### **Nameplate propio (client)**

* Se crea un `BillboardGui` sobre la cabeza del enemigo (hijo del `HumanoidRootPart` o del modelo, con `Adornee` en la cabeza/HRP) con:
  * **Barra de vida**: fondo (track) + fill que refleja `HP/MaxHP` (atributos ya replicados server→client).
  * **Nombre** (opcional, configurable): nombre del enemigo (`EnemyConfig.name` o nombre del modelo) en texto pequeño.
* El cliente lee los atributos `HP`/`MaxHP` del enemigo y actualiza el fill con señales (`GetAttributeChangedSignal`) o refresco ligero estilo HUD (0.2 s); **no** por frame en cada enemigo.
* Visibilidad:
  * Solo si el enemigo está vivo (`Dead ~= true`) y con `HP > 0`.
  * Se oculta al morir; si el dummy respawnea (R1), reaparece.
  * Distancia máxima de visibilidad configurable (default propuesto: `40` studs).
  * No se muestra sobre el jugador ni sobre otros jugadores (MVP solo PvE).
* **Toggle**:
  * Tecla default propuesta: `N` (configurable en config de HUD); botón móvil equivalente (puede vivir en el micromenú de HU-ESTETICA-19).
  * Al apagarlo se ocultan **todos** los nameplates (visual local); al encenderlo reaparecen según las reglas anteriores.
  * La preferencia se persiste **por personaje** (perfil/DataStore, campo nuevo `showNameplates`, default `true`).
  * Si está en un `TextBox` o ventana con input procesado, la tecla no dispara.

#### **Estilo (tokens Hearthbound Gold)**

* Barra fina (default propuesto `120×8` studs-pantalla, ajustable), fondo oscuro semitransparente, fill de vida con el color de barras del HUD (`#C45345`-ish rojo/verde por estado o el token de vida existente), borde/cornerRadius según tokens EST-04.
* El nombre en `Geist Mono` pequeño, `#F4EDE0` pergamino.
* No tapa la acción: tamaño acotado y `AlwaysOnTop = true` para la barra (el nombre puede ir sobre ella).
* Si el diseñador entrega un estilo final de nameplate (puede salir de HU-ESTETICA-19 o una EST posterior), se reemplaza solo por config/estilo, sin cambiar la lógica.

#### **Seguridad y autoridad**

* La vida sigue siendo **server-authoritative**: el nameplate solo representa los atributos replicados `HP`/`MaxHP`.
* El cliente no puede modificar vida ni ocultar la barra de otros jugadores en el servidor (el toggle es preferencia local/persistida del propio jugador).
* No se crean RemoteEvents nuevos: los atributos ya se replican y la preferencia viaja en el perfil existente.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Una sola barra de vida**

* **GIVEN** un enemigo en el mundo (dummy o dungeon).
* **WHEN** el jugador lo mira.
* **THEN** se ve **una** barra de vida (el nameplate propio).
* **AND** la barra nativa de Roblox no aparece sobre él.

#### **Escenario 2: Barra sobre la cabeza**

* **GIVEN** un enemigo vivo.
* **WHEN** el jugador lo observa a ≤40 studs.
* **THEN** el nameplate aparece sobre su cabeza con la barra de vida y el nombre.
* **AND** se actualiza al recibir daño (fill = HP/MaxHP).

#### **Escenario 3: Toggle con tecla N**

* **GIVEN** los nameplates visibles.
* **WHEN** el jugador presiona `N`.
* **THEN** todos los nameplates se ocultan.
* **AND** una segunda pulsación los vuelve a mostrar.

#### **Escenario 4: Toggle móvil**

* **GIVEN** un dispositivo táctil.
* **WHEN** el jugador usa el botón de toggle (micromenú u HUD).
* **THEN** los nameplates se ocultan/muestran igual que con la tecla.
* **AND** no rompe el joystick ni la UI.

#### **Escenario 5: Persistencia**

* **GIVEN** el jugador desactivó los nameplates.
* **WHEN** sale y vuelve a entrar con el mismo personaje.
* **THEN** la preferencia se mantiene (nameplates ocultos).

#### **Escenario 6: Muerte y respawn**

* **GIVEN** un enemigo targeteado o no.
* **WHEN** muere.
* **THEN** su nameplate desaparece.
* **AND** si el dummy respawnea, el nameplate reaparece con la vida llena.

#### **Escenario 7: No aplica al jugador**

* **GIVEN** el jugador y otros jugadores en el hub.
* **WHEN** se miran entre sí.
* **THEN** no aparecen nameplates sobre los avatares de jugadores.
* **AND** el player frame del HUD sigue siendo la única vida del jugador.

#### **Escenario 8: Sin doble fuente**

* **GIVEN** cualquier enemigo con `Humanoid`.
* **WHEN** se revisa su configuración.
* **THEN** `HealthDisplayType = AlwaysOff` y `DisplayDistanceType = None`.
* **AND** no hay barras nativas duplicadas en ningún spawn.

#### **Escenario 9: Seguridad**

* **GIVEN** un cliente manipulado.
* **WHEN** intenta cambiar la vida o forzar el nameplate de otro jugador.
* **THEN** el servidor conserva la vida real y el nameplate solo refleja atributos replicados.
* **AND** no hay errores rojos en combate, respawn o cambio de piso.

#### **Escenario 10: Performance**

* **GIVEN** un piso con muchos enemigos (hasta ~20).
* **WHEN** todos tienen nameplate visible.
* **THEN** las actualizaciones usan señales/refresco ligero, sin loops por frame.
* **AND** no hay caídas de frames ni spam de instancias.

---

### **Comportamiento Visual / Reglas de Negocio**

* El nameplate es la única barra sobre los enemigos: la nativa queda desactivada.
* Estilo Hearthbound Gold: barra fina, fondo oscuro, fill de vida, nombre pequeño.
* El toggle es una preferencia del jugador (persistente por personaje), no una regla de servidor.
* No se agregan nameplates para jugadores, party, cast bars ni buffs en esta HU.
* El target frame del HUD (nombre + HP + indicador de target R3.3) sigue intacto; el nameplate lo complementa, no lo reemplaza.

---

### **Alcance**

#### Incluye

* Desactivación de la barra nativa en todos los enemigos (dummy + dungeon).
* Nameplate propio (BillboardGui) sobre la cabeza: barra de vida + nombre opcional.
* Actualización por atributos `HP`/`MaxHP` (señales o refresco ligero).
* Toggle por tecla (`N` propuesta) y botón móvil.
* Persistencia de la preferencia por personaje (perfil).
* Reglas de visibilidad (vivo, distancia ≤40, no jugadores).
* Config data-driven (tamaño, distancia, tecla, colores).

#### No incluye

* Nameplates para jugadores, party o PvP.
* Cast bars, buffs/debuffs sobre enemigos, barras de maná de enemigos.
* Cambios a daño, targeting, target frame, indicador R3.3 ni balance.
* Cambios al player frame del HUD.
* RemoteEvents nuevos o cambios de autoridad server.
* Estilo final artístico si el diseñador lo entrega después (se integra por config sin tocar lógica).

---

### **Definition of Done (DoD)**

* [ ] Todos los enemigos tienen la barra nativa desactivada (`AlwaysOff` + `DisplayDistanceType.None`).
* [ ] Cada enemigo vivo muestra un único nameplate sobre la cabeza con barra de vida y nombre.
* [ ] El fill refleja `HP/MaxHP` replicado y se actualiza al dañar/curar.
* [ ] El nameplate se oculta al morir y reaparece si el dummy respawnea.
* [ ] `N` (o tecla configurada) oculta/muestra todos los nameplates.
* [ ] Existe botón móvil de toggle sin romper joystick/UI.
* [ ] La preferencia persiste por personaje tras rejoin.
* [ ] No aparecen nameplates sobre jugadores.
* [ ] Los nameplates respetan la distancia configurable y no afectan performance.
* [ ] El cliente no puede alterar la vida desde el nameplate (server-authoritative intacto).
* [ ] Sin errores rojos en combate, respawn, dungeon y rejoin.
* [ ] Se actualizan `PROJECT_ARCHITECTURE`, `DATA_SCHEMA` y el registro de la HU/RC al cerrar.
* [ ] Nota `R6.11 completo` en el GDD después de la verificación, no antes.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).

---

### **Decisiones por defecto R6.11**

| Tema | Default |
|------|---------|
| Barra nativa | Desactivada en enemigos (`AlwaysOff` + `DisplayDistanceType.None`) |
| Nameplate | BillboardGui sobre la cabeza: barra de vida + nombre |
| Tamaño | 120×8 (ajustable en config) |
| Distancia máx. | 40 studs (ajustable) |
| Tecla de toggle | `N` (configurable) |
| Móvil | Botón en micromenú/HUD |
| Persistencia | Por personaje (perfil), default `true` |
| Alcance | Solo enemigos (dummy + dungeon); no jugadores |
| Estilo | Tokens Hearthbound Gold (fondo oscuro, fill de vida, texto pergamino) |
| Actualización | Atributos `HP`/`MaxHP` + señales/refresco ligero |

---

### **Pendientes de confirmación**

* Tecla de toggle: se propone `N`; confirmar si se prefiere otra (p. ej. `V` o dentro de opciones del micromenú).
* Si el diseñador entrega un estilo final de nameplate (desde HU-ESTETICA-19 o una EST futura), se integra por config sin tocar la lógica.

---

### **Estimación (orientativa)**

1–2 sesiones: desactivación de la nativa, nameplate, toggle, persistencia y regresión PC/móvil.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-20 | Creación de HU-R6.11: nameplates de enemigos con barra de vida toggleable, desactivación de la barra nativa de Roblox y estilo Hearthbound Gold |