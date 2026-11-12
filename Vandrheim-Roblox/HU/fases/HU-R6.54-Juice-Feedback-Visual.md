# HU-R6.54: Juice visual — level up y loot (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Feedback / Progresión / Retención
**Prioridad:** Alta — impacto inmediato en la sensación del juego
**Estado:** Abierta — lista para RC
**Tipo:** VFX de feedback (dev, client-side)
**Fase GDD:** Combate / UI / Progresión
**Depende de:** R6.8/R6.9 (VFX existentes), eventos existentes de subida de nivel y loot, `SFXConfig` existente, `UITheme`
**Componentes observados:** personaje, `HumanoidRootPart`, `ProgressionService`, `LootService`, `VFXConfig`, `SFXConfig`
**No modifica:** daño, vida, XP, drop rates, loot, economía, balance, números flotantes, críticos, curas, avisos de ítem ni autoridad del servidor.

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** que subir de nivel y recibir loot se sienta grande,
**para** que cada run tenga momentos memorables y ganas de seguir jugando.

**Como** equipo,
**quiero** una capa visual acotada para level up y loot,
**para** mejorar la percepción de recompensa sin tocar el balance, el audio existente ni sistemas que ya funcionan.

---

### Descripción / Contexto

Vandrheim ya tiene números flotantes, críticos, curas y avisos de ítem; **no se tocan en esta HU**. El alcance es únicamente:

* Estallido dorado con luces y detalles alrededor del personaje al subir de nivel.
* Partículas de luz que viajan desde el loot hasta el personaje, con color según la rareza.
* Reutilizar los **sonidos existentes** que ya cubren level up y loot; no crear, pedir ni registrar SFX nuevos.
* Si no existe un sonido adecuado para un caso, no agregarlo.

**Criterio de hecho global:** al subir de nivel y recibir loot, el jugador ve un efecto claro y legible en PC y móvil; los sonidos son solo los existentes; los números flotantes, críticos, curas, avisos y valores de gameplay quedan exactamente como están.

---

### Especificaciones Técnicas / Contratos

#### 1. Subida de nivel

* Escuchar el evento existente de level up (`LevelUp` o equivalente).
* Reproducir un burst alrededor del `HumanoidRootPart`:
  * anillo dorado que se expande,
  * partículas/estrellas ascendentes,
  * luz breve.
* Un solo burst por evento; cleanup con `Debris`/tween; no acumular si sube varios niveles seguidos.
* No bloquear movimiento, cámara ni combate; sin slow-motion.
* Feedback local del dueño; no se replica a otros jugadores.

#### 2. Loot con partículas por rareza

* Al recibir un ítem, originar un haz/orbe de luz desde la fuente (cofre, enemigo, jefe o posición del mundo) hacia el personaje.
* Color por rareza:
  * blanco/gris,
  * verde,
  * azul,
  * morado,
  * único/dorado (configurable).
* El ítem se entrega al instante; la partícula es solo feedback; nunca retrasar la recompensa.
* Si no hay fuente conocida, usar la posición del enemigo/cofre o el centro del personaje como origen.
* Si caen muchos ítems juntos, agrupar o limitar partículas simultáneas; no llenar la pantalla.
* No mostrar partículas de loot de otros jugadores salvo que el sistema ya las replique; evitar confusión.
* No crear un sonido por rareza; usar el sonido de loot existente si corresponde. Si no existe, no agregar audio.

#### 3. Sistemas existentes que NO se tocan

* Números flotantes de daño, cura y crítico.
* Colores/tamaños de críticos.
* Avisos de ítem nuevo/mejora/peor.
* Comparación de ítems.
* Sonidos de combate, crítico, cura o loot ya existentes.
* Cualquier valor de daño, XP, drop rate o economía.

Si alguno de esos sistemas necesita cambios, va en otra HU con aprobación explícita.

#### 4. Audio

* Usar exclusivamente SFX existentes de `SFXConfig`.
* No crear, pedir, grabar, registrar ni integrar sonidos nuevos.
* No agregar un mapeo nuevo de sonidos por rareza si no existe.
* Respetar volumen general, mute y configuración de audio existente.
* Si el evento no tiene un sonido adecuado, dejarlo silencioso; no reemplazarlo por uno que no aplica.

#### 5. Rendimiento y limpieza

* Pool de partículas; límites por tipo y por segundo.
* No crear un `ParticleEmitter` por frame ni por cada tick sin reciclado.
* Cleanup al morir, cambiar de personaje, salir de la dungeon o cerrar la sesión.
* No usar `while true do` sin `task.wait`; no lógica de servidor.
* Objetivo: sin caídas críticas en móvil de gama media.

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Subida de nivel

* **GIVEN** un personaje que sube de nivel
* **WHEN** se dispara el evento
* **THEN** ve un estallido dorado, luces y partículas alrededor del personaje
* **AND** no se bloquea el movimiento ni el combate
* **AND** se usa el sonido existente, si corresponde

#### Escenario 2: Loot por rareza

* **GIVEN** un ítem que cae al suelo o se reclama
* **WHEN** el jugador lo recibe
* **THEN** una partícula viaja desde la fuente hasta el personaje con el color de su rareza
* **AND** el ítem se entrega sin demora
* **AND** no se agrega un sonido nuevo

#### Escenario 3: Sistemas existentes intactos

* **GIVEN** el juice activo
* **WHEN** el jugador pega, cura, critica o recibe un ítem
* **THEN** los números flotantes, críticos, curas y avisos se ven igual que antes
* **AND** no se duplican ni se modifican

#### Escenario 4: Audio existente

* **GIVEN** el juego con sus SFX actuales
* **WHEN** se sube de nivel o se recibe loot
* **THEN** se usan solo sonidos existentes
* **AND** no hay assets de audio nuevos ni mapeos inventados

#### Escenario 5: Rendimiento

* **GIVEN** una pelea con muchos enemigos y loot
* **WHEN** se acumulan efectos en PC y móvil
* **THEN** no hay errores rojos ni duplicados
* **AND** el framerate se mantiene estable; los efectos se limitan por pool

#### Escenario 6: Sin cambios de gameplay

* **GIVEN** el juice activo
* **WHEN** se comparan daño, XP, loot y economía
* **THEN** los valores son idénticos a los de antes
* **AND** el servidor sigue siendo la única autoridad

---

### Comportamiento Visual / UI-UX

* El feedback debe celebrar sin tapar la acción; legible en combate y en móvil.
* No abusar de screen shake ni flashes; evitar mareos y pérdida de lectura.
* Las rarezas deben distinguirse por color del efecto, no por un sistema de audio nuevo.
* El level up debe sentirse como un momento, no como una notificación más.

---

### Alcance

#### Incluye

* Level up con burst dorado, luces y partículas.
* Loot con partículas por rareza.
* Uso de SFX existentes, sin agregar audio.
* Pool, límites, cleanup y compatibilidad móvil.

#### No incluye

* Números flotantes, críticos, curas o avisos de ítem; ya existen y no se tocan.
* Sonidos nuevos, mapeos de audio nuevos o assets de audio.
* Cambios de daño, crítico, XP, loot, drop rates o economía.
* Nuevas animaciones de personaje, modelos, armas o VFX únicos por skill.
* Slow-motion, cinemáticas o cambios de cámara que afecten combate.
* UI nueva de personaje, inventario o ajustes.

---

### Definition of Done (DoD)

* [ ] Level up con VFX dorado alrededor del personaje.
* [ ] Loot con partículas por rareza.
* [ ] Sin sonidos nuevos; solo SFX existentes.
* [ ] Números flotantes, críticos, curas y avisos intactos.
* [ ] Pool y límites de efectos; sin errores rojos.
* [ ] PC y móvil verificados.
* [ ] Sin cambios de daño/XP/loot/economía.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).

---

### Decisiones por defecto

| Tema | Default |
|---|---|
| Level up | Burst dorado + partículas + luces |
| Loot | Orbe/haz por rareza; color configurable |
| Audio | Solo SFX existentes; sin nuevos |
| Números flotantes | Intactos; no se tocan |
| Críticos/curas | Intactos; no se tocan |
| Avisos de ítem | Intactos; no se tocan |
| Autoridad | Cliente solo para VFX; servidor para valores |
| Rendimiento | Pool y límites por segundo |
| Móvil | Menos partículas |

---

### Estimación (orientativa)

1–2 sesiones del dev: eventos, VFX, pool, cleanup y QA PC/móvil.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-11-12 | Creación de HU-R6.54: juice visual para level up y loot, con SFX existentes y sin tocar números flotantes, críticos, curas, avisos ni valores de gameplay. |
| 2026-11-12 | Corrección de alcance por PO: se eliminan números de daño/cura/crítico, avisos/comparación de ítem y cualquier sonido nuevo. Solo quedan level up y partículas de loot, reutilizando audio existente. |
