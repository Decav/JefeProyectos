# HU-R2.2: Avatar starter por defecto — cuerpo R15 Vandrheim y cabeza del jugador

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Personaje / Identidad visual / R2
**Prioridad:** Alta
**Estado:** Implementada (reporte PO 2026-10-27; QA/verificación pendiente)
**Tipo:** Sistema de apariencia de personaje (dev)
**Fase GDD:** R2.2 — enmienda GDD §2 (Avatar) y §9 (Creación de PJ)
**Depende de:** HU-R2 (creación/slots/spawn), HU-ESTETICA-01 (equipment visuals), HU-ESTETICA-07/33 (body skins/clothing R15), modelo `Vandrheim_Traveler_Starter_R15_v3_PREVIEW`, `CharacterService`/`EquipmentVisualService`
**Componentes observados:** `CharacterService`, `EquipmentVisualService`, `InventoryService`, `HumanoidDescription`, `ReplicatedStorage.Assets.Models.*`, `Workspace.ModelTest.VandrheimTravelerStarter_v3`, `CharacterSelect`/`CharacterCreate`
**No modifica:** clases/specs, stats, inventario/equip rules, loot, animaciones, dungeon/party ni la lógica de combate.

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** que mi personaje use el cuerpo base de Vandrheim cuando no tengo armadura equipada, conservando mi cabeza,
**para** verme coherente con el mundo y que el equipo se ajuste siempre bien.

**Como** equipo,
**quiero** una apariencia base R15 server-authoritative y data-driven,
**para** evitar skins meme o desproporcionadas que rompan el flujo de equipamiento.

---

### Descripción del Requerimiento / Contexto

Hoy el personaje entra con el avatar R15 del jugador (GDD §2/§9). Eso permite que un jugador use paquetes como gallina, gato o cuerpos desproporcionados, que rompen el ajuste del equipamiento de EST-01 y la lectura visual del juego.

La nueva regla: **todo personaje sin armadura equipada usa el cuerpo base Vandrheim Traveler Starter R15** y **conserva la cabeza del jugador**. Se reemplazan torso, brazos y piernas; se eliminan la ropa y los accesorios de cuerpo del avatar; se conservan la cabeza, la cara y los accesorios de cabeza. Al equipar armadura, el pipeline de EST-01 sigue mostrando las piezas correspondientes sobre ese cuerpo base. Al desequipar toda la armadura, vuelve el look starter.

La apariencia es **derivada** (equipo + modelo base), no se guarda en el perfil. Se aplica al crear/seleccionar personaje, al spawnear, al reaparecer, al rejoin y al cambiar de Place (hub/dungeon).

**Criterio de hecho global:** cualquier personaje sin armadura equipada se ve con el cuerpo R15 del modelo `Vandrheim_Traveler_Starter_R15_v3_PREVIEW` y la cabeza del jugador; el equipamiento de EST-01 sigue funcionando; no se puede entrar al mundo con un cuerpo meme; y no hay errores rojos ni piezas flotantes.

---

### Especificaciones Técnicas / Contratos de API

#### 1. Modelo canónico

* **Modelo:** `Vandrheim_Traveler_Starter_R15_v3_PREVIEW` (el PO lo reporta como `..._V3_PREVIEW`; el dev confirma el casing exacto en Studio).
* **Ubicación actual:** `Workspace.ModelTest.VandrheimTravelerStarter_v3`.
* **Producción:** duplicarlo a `ReplicatedStorage.Assets.Models.Avatar.Vandrheim_Traveler_Starter_R15` (ruta default) o a la ruta que defina `StarterAvatarConfig`. **Prohibido depender de `Workspace.ModelTest` en runtime.**
* **Tipo de cuerpo:** R15 estándar (no Rthro, no paquetes). Las proporciones, colores y ropa base salen del modelo; no se inventan escalas ni colores.
* **Ropa base:** camisa y pantalón clásicos R15 del Traveler Starter. IDs de preview actuales: Shirt `rbxassetid://129609031177806`, Pants `rbxassetid://124517385758133`. Reemplazar por IDs finales y registrarlos en `ASSETS_LIST`/`ASSETS_REGISTRY`.
* El modelo debe quedar como template reutilizable, con `Humanoid` R15, body parts estándar y attachments R15 (`NeckRigAttachment`, `BodyFrontAttachment`, etc.). No se usa el rig de preview como personaje vivo.

#### 2. Regla de apariencia

* **Sin armadura equipada:** se aplica el cuerpo starter (torso, brazos, piernas + ropa base) y se conserva la cabeza del jugador.
* **Con armadura equipada:** el cuerpo starter sigue siendo la base; `EquipmentVisualService` aplica las piezas de EST-01 (body skins y accesorios) como hoy.
* **“Armadura”**: slots `Helmet`, `Shoulders`, `Chest`, `Gloves`, `Legs`. Las armas (`MainHand`/`OffHand`) **no** cuentan: un PJ con arma y sin armadura sigue mostrando el cuerpo starter.
* **Se conserva:** `Head`, cara/face, color de cabeza y accesorios de cabeza (pelo, sombreros, orejas).
* **Se reemplaza/elimina:** torso, brazos, piernas, colores de cuerpo del avatar, ropa del jugador (`Shirt`/`Pants`) y accesorios de cuerpo (alas, colas, mochilas, etc.).
* **Cabeza del jugador:** se mantiene unida al torso con el joint `Neck` correcto; no debe quedar flotando, girada ni separada. Se respetan su escala y su face.
* **Casco:** si el jugador equipa casco y sus accesorios de cabeza hacen clipping, se ocultan temporalmente los accesorios de cabeza mientras el casco esté equipado y se restauran al desequiparlo (default).
* **Color:** el cuerpo usa los colores del modelo; la cabeza conserva su color. Si el QA detecta un contraste no aceptable, se puede igualar el color del cuerpo al de la cabeza (solo color, sin cambiar la forma) como ajuste visual.

#### 3. Eventos de aplicación

La apariencia se aplica server-side, de forma idempotente, en:

* Creación de personaje (al confirmar nombre + clase y spawnear).
* Selección de personaje / cambio de slot.
* Spawn inicial en hub.
* Respawn por muerte (hub y dungeon, incluido el respawn de R6.28).
* Rejoin (el avatar de Roblox se carga primero y debe normalizarse).
* Teleport hub ↔ dungeon.
* Cambio de equipamiento (equipar/desequipar armadura).

**Orden obligatorio:** aplicar cuerpo starter → reconstruir visuales de equipamiento (`ApplyEquipmentVisuals`) → validar `Neck`/cabeza. Nunca aplicar equipo antes del cuerpo.

**Persistencia:** la apariencia no se guarda en el perfil. Se recalcula desde el equipo persistido + modelo base en cada spawn. Cambiar el avatar de Roblox fuera del juego no cambia el cuerpo; solo la cabeza se actualiza al rejoin.

#### 4. Integridad del rig R15

* `Humanoid.RigType = R15`; el personaje debe ser un R15 válido aunque el avatar del jugador sea R6.
* Mantener los joints estándar (`Neck`, `Waist`, `LeftShoulder`, `RightShoulder`, `LeftHip`, `RightHip`) y los attachments que usa EST-01.
* Animaciones de R6.1/R6.6 deben seguir funcionando (idle, walk, run, jump, combate).
* Los body skins de EST-01/EST-07/EST-33 deben aplicarse a los segmentos correctos (`UpperTorso`, `LowerTorso`, brazos, piernas) sin franjas ni costuras.
* Accesorios de EST-01 (casco, hombreras) deben encajar sobre el cuerpo starter sin flotar ni atravesar.
* Sin piezas duplicadas, sin body parts huérfanos, sin `Humanoid` extra.

#### 5. Autoridad y anti-exploit

* La apariencia la aplica **solo el servidor**; el cliente no puede enviar `HumanoidDescription`, body parts, colores ni ropa.
* No se agregan remotes de apariencia. Cualquier intento de cliente se ignora.
* La apariencia no otorga ventajas de combate, tamaño de hitbox ni stats; solo es visual.
* Si el modelo base no carga, usar un fallback R15 default de Roblox con warning; no romper spawn ni combate.

#### 6. Configuración

Crear `StarterAvatarConfig` (ModuleScript, server-safe) con:

```lua
{
  modelName = "Vandrheim_Traveler_Starter_R15",
  modelPath = "ReplicatedStorage.Assets.Models.Avatar",
  keepHead = true,
  removeBodyAccessories = true,
  removePlayerClothing = true,
  applyStarterClothing = true,
  hideHeadAccessoriesWithHelmet = true,
  bodyColors = { ... }, -- del modelo; no hardcodear en el servicio
  shirtId = "rbxassetid://...",
  pantsId = "rbxassetid://...",
  fallbackToDefaultR15 = true,
}
```

Los IDs y colores viven en config/asset metadata, no en múltiples scripts. El modelo es la fuente de proporciones; el config solo lo referencia.

#### 7. UI de creación/selección

* Si `CharacterCreate`/`CharacterSelect` muestra una preview 3D del PJ, debe mostrar el **cuerpo starter + cabeza del jugador**, no el avatar meme del usuario.
* Si no hay preview 3D, no se agrega en esta HU (fuera de alcance).
* No se agrega editor de apariencia, selección de piel, pelo ni cuerpo.

#### 8. Enmiendas al GDD

| Sección | Texto vigente | Texto nuevo |
|---|---|---|
| §2 Avatar | “R15 del jugador (skin de Roblox) + overrides de equipo/clase” | “Cuerpo R15 Vandrheim Traveler Starter por defecto (sin armadura) + cabeza del jugador + overrides de equipo/clase” |
| §9 Creación PJ | “Solo nombre + clase; skin = avatar Roblox del jugador” | “Solo nombre + clase; cuerpo starter Vandrheim; cabeza del jugador” |
| §9 Apariencia | “Apariencia = avatar R15 del jugador en Roblox (sin editor de pelo/piel propio)” | “Apariencia = cuerpo starter Vandrheim + cabeza del jugador (sin editor de pelo/piel propio)” |

Registrar el cambio en el historial del GDD al aprobar/implementar la HU.

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Personaje nuevo sin armadura

* **GIVEN** un jugador crea un personaje nuevo sin armadura equipada
* **WHEN** spawnea en el hub
* **THEN** su torso, brazos y piernas usan el cuerpo R15 del modelo `Vandrheim_Traveler_Starter_R15_v3_PREVIEW`
* **AND** conserva su cabeza, cara y accesorios de cabeza
* **AND** no conserva la ropa ni los accesorios de cuerpo de su avatar

#### Escenario 2: Rejoin con avatar meme

* **GIVEN** un jugador con un paquete meme (gallina, gato, cuerpo desproporcionado) y sin armadura
* **WHEN** entra o vuelve a entrar al juego
* **THEN** el cuerpo se normaliza al starter
* **AND** solo la cabeza conserva el aspecto del jugador

#### Escenario 3: Cambio de avatar fuera del juego

* **GIVEN** un personaje existente creado con el cuerpo starter
* **WHEN** el jugador cambia su avatar de Roblox y vuelve a entrar
* **THEN** el cuerpo sigue siendo el starter
* **AND** la cabeza refleja el avatar actual del jugador

#### Escenario 4: Equipar armadura

* **GIVEN** un PJ con cuerpo starter
* **WHEN** equipa casco, hombreras, pecho, guantes o piernas
* **THEN** las piezas de EST-01 se aplican sobre el cuerpo starter
* **AND** no se duplican body parts, accesorios ni visuales
* **AND** las piezas encajan sin flotar ni atravesar

#### Escenario 5: Desequipar toda la armadura

* **GIVEN** un PJ con armadura equipada
* **WHEN** desequipa todas las piezas de armadura
* **THEN** vuelve el cuerpo starter con su ropa base
* **AND** las armas equipadas no impiden el look starter

#### Escenario 6: Cabeza preservada

* **GIVEN** un jugador con cabeza, cara y accesorios de cabeza
* **WHEN** se aplica el cuerpo starter
* **THEN** la cabeza sigue unida por el `Neck`, sin flotar ni separarse
* **AND** las animaciones de idle/walk/run/jump y combate siguen funcionando

#### Escenario 7: Respawn y teleport

* **GIVEN** un PJ en dungeon o hub
* **WHEN** muere y reaparece, o cambia de Place
* **THEN** el cuerpo starter se vuelve a aplicar
* **AND** el equipamiento se reconstruye correctamente

#### Escenario 8: Cambio de slot

* **GIVEN** una cuenta con dos personajes
* **WHEN** cambia del slot 1 al slot 2
* **THEN** el cuerpo starter se aplica al personaje activo
* **AND** no queda apariencia residual del personaje anterior

#### Escenario 9: R15 forzado

* **GIVEN** un jugador con avatar R6
* **WHEN** crea o selecciona un personaje
* **THEN** el personaje resultante es R15
* **AND** las animaciones y el equipamiento R15 funcionan

#### Escenario 10: Autoridad del servidor

* **GIVEN** un cliente manipulado
* **WHEN** intenta cambiar body parts, colores, ropa o `HumanoidDescription`
* **THEN** el servidor ignora el intento
* **AND** la apariencia sigue siendo la starter

#### Escenario 11: Casco y accesorios de cabeza

* **GIVEN** un PJ con accesorios de cabeza y un casco equipado
* **WHEN** se aplica el equipo
* **THEN** los accesorios que hacen clipping se ocultan mientras el casco está equipado
* **AND** se restauran al desequipar el casco

#### Escenario 12: Sin armadura, con arma

* **GIVEN** un PJ con un arma equipada y sin piezas de armadura
* **WHEN** se evalúa la apariencia
* **THEN** se muestra el cuerpo starter
* **AND** el arma se mantiene visible y funcional

#### Escenario 13: Regresión de equipamiento

* **GIVEN** el cuerpo starter aplicado
* **WHEN** se equipan y desequipan las 9 piezas de equipo y las armas
* **THEN** EST-01/EST-07/EST-33 siguen funcionando
* **AND** no hay errores rojos ni piezas huérfanas

#### Escenario 14: Fallback

* **GIVEN** que el modelo starter no está disponible
* **WHEN** un PJ spawnea sin armadura
* **THEN** se usa un cuerpo R15 default de Roblox con warning
* **AND** el spawn, el combate y el equipamiento no se rompen

---

### Comportamiento Visual / Reglas de Negocio

* El cuerpo starter es la identidad visual base de Vandrheim; todos los PJ nuevos se ven iguales de cuerpo, con la cabeza de cada jugador.
* No se permite entrar al mundo con un cuerpo meme; la normalización ocurre antes de que el PJ sea visible/jugable.
* La cabeza es la única parte personalizable del avatar del jugador en el MVP; no hay editor de apariencia.
* El equipo de EST-01 manda sobre el look cuando está equipado; el cuerpo starter es la base, no un reemplazo del sistema de equipo.
* Sin cambios de hitbox, stats, velocidad, cámara ni animaciones por la apariencia.

---

### Alcance

#### Incluye

* Integración del modelo `Vandrheim_Traveler_Starter_R15_v3_PREVIEW` como cuerpo base de producción.
* Aplicación server-side del cuerpo starter + cabeza del jugador en creación, selección, spawn, respawn, rejoin y teleport.
* Eliminación de ropa/accesorios de cuerpo del avatar y conservación de cabeza/cara/accesorios de cabeza.
* Integración con EST-01 (equipo sobre el cuerpo starter) y regresión de body skins/accesorios.
* Config `StarterAvatarConfig`, fallback R15 y registro de assets.
* Preview de creación/selección si existe.
* Enmienda al GDD §2/§9.

#### No incluye

* Editor de apariencia, selección de piel/pelo/cuerpo, cosméticos de cuerpo o transmog.
* Cambios a clases, stats, inventario, loot, economía, dungeon, party o combate.
* Nuevos body types, Rthro, paquetes de Roblox o animaciones.
* Cambios de UI más allá de la preview existente.
* Persistir la apariencia en el perfil.
* Resolver cabezas no humanas (ver Riesgos).

---

### Definition of Done (DoD)

* [ ] El modelo starter está en producción y no se depende de `Workspace.ModelTest`.
* [ ] PJ nuevo sin armadura muestra cuerpo starter R15 + cabeza del jugador.
* [ ] Se eliminan ropa y accesorios de cuerpo; se conservan cabeza, cara y accesorios de cabeza.
* [ ] La apariencia se reaplica en spawn, respawn, rejoin, cambio de slot y teleport.
* [ ] Equipar/desequipar armadura funciona sobre el cuerpo starter sin duplicar ni romper EST-01.
* [ ] El rig sigue siendo R15 válido; `Neck` y animaciones funcionan.
* [ ] El servidor es la única autoridad; el cliente no puede cambiar la apariencia.
* [ ] Casco + accesorios de cabeza resuelto sin clipping grave.
* [ ] Preview de creación/selección actualizada (si existe).
* [ ] Fallback R15 default probado.
* [ ] Sin errores rojos en hub/dungeon, solo/party, PC/móvil.
* [ ] `ASSETS_LIST`/`ASSETS_REGISTRY` actualizados con modelo e IDs finales.
* [ ] GDD §2/§9 enmendado y registrado en historial.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Evidencia de QA (capturas/video) adjunta.

---

### Decisiones por defecto

| Tema | Default |
|---|---|
| Modelo base | `Vandrheim_Traveler_Starter_R15_v3_PREVIEW` |
| Ruta de producción | `ReplicatedStorage.Assets.Models.Avatar.Vandrheim_Traveler_Starter_R15` |
| Cuerpo | R15 estándar, proporciones del modelo |
| Cabeza | Se conserva (incluye cara y accesorios de cabeza) |
| Ropa del jugador | Se elimina; se aplica la ropa base del modelo |
| Accesorios de cuerpo | Se eliminan |
| Accesorios de cabeza | Se conservan; se ocultan con casco si hay clipping |
| Umbral de armadura | Cualquier pieza en Helmet/Shoulders/Chest/Gloves/Legs |
| Armas | No cuentan como armadura |
| Persistencia | No se guarda; se deriva del equipo + modelo |
| Aplicación | Server-side, en cada spawn/respawn/rejoin/teleport |
| R6 del jugador | Se fuerza R15 |
| Fallback | R15 default de Roblox + warning |
| Color | Cuerpo del modelo; cabeza del jugador; ajuste solo si el QA lo pide |

---

### Riesgos / Notas de producto

1. **Cabeza no humana:** si el jugador usa un paquete con cabeza de gallina/gato, la cabeza se conserva por regla y el resultado puede seguir viéndose meme. Si el PO quiere eliminarlo, hace falta una regla adicional (cabeza default o whitelist de cabezas). **Decisión pendiente del PO.**
2. **Contraste cabeza/cuerpo:** el cuerpo usa el tono del modelo y la cabeza el del jugador; puede haber mismatch. QA visual.
3. **Compatibilidad EST-01:** las body skins y accesorios deben seguir funcionando sobre el cuerpo starter; es el mayor riesgo técnico.
4. **Neck/escala de cabeza:** cabezas grandes o con accesorios pueden requerir ajuste del joint; validar animaciones.
5. **Performance:** precargar el modelo y aplicar una sola vez por spawn; evitar flicker.
6. **Propiedad de assets:** los IDs de camisa/pantalón actuales son de preview; confirmar ownership y IDs finales.

---

### Estimación (orientativa)

2–3 sesiones del dev: integración del modelo, servicio de apariencia, compatibilidad EST-01, preview y regresión.

---

### Historial

| Fecha | Cambio |
|-------|--------|
| 2026-10-27 | Creación de HU-R2.2 por pedido del PO: al crear un personaje sin armadura, usar el cuerpo R15 Vandrheim Traveler Starter y conservar la cabeza del jugador; evitar skins meme/desproporcionadas que rompan el equipamiento. Incluye enmienda al GDD §2/§9 y nota sobre cabezas no humanas. |
| 2026-10-27 | Implementada según reporte del PO; QA/verificación pendiente. |
