# HU-ESTETICA-51: Sistema de misiones — diseño de UI en Pencil

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / Retención
**Prioridad:** Alta — primera sesión de beta
**Estado:** Abierta — lista para diseñar
**Tipo:** Diseño de UI en Pencil (solo diseñador; **sin desarrollo, sin código**)
**Fase GDD:** QUEST-02 / EST-51 (adelanto de R10+; decisión PO 2026-10-27)
**Depende de:** `QUEST_SYSTEM.md`, HU-QUEST-01 (framework), HU-QUEST-02 (onboarding), HU-ESTETICA-13 (tokens/UI), HU-ESTETICA-20 (HUD), HU-ESTETICA-22 (party frames), HU-ESTETICA-31 (notificaciones), HU-ESTETICA-43 (mochila), HU-ESTETICA-50 (lenguaje Cuaderno), HU-R6.27 (casillas)
**No modifica:** lógica de misiones, gameplay, economía, inventario ni backend.

---

### Narrativa (INVEST)

**Como** jugador nuevo,
**quiero** ver una misión activa clara, un marcador en el mundo y un panel donde entender qué hacer y qué gano,
**para** completar mi primera incursión sin perderme y querer seguir jugando.

**Como** diseñador,
**quiero** un set de frames y estados en Pencil listo para implementar,
**para** que el dev conecte el sistema de misiones sin reinterpretar la UI.

---

### Descripción / Contexto

`QUEST_SYSTEM.md` define el producto y `HU-QUEST-01/02` el framework y la primera quest (`intro_helada`). La **presentación visual** quedó en tracker, panel (Cuaderno), panel del Guía con elección de arma, notificaciones existentes y recursos de iconos/marcadores.

El diseño debe integrarse con la UI existente (Hearthbound Gold, Cuaderno, HUD, party, mochila, notificaciones) y funcionar en PC y móvil. Los marcadores 3D (haz, icono flotante, flecha en el piso) se implementan en Studio; Pencil entrega la **referencia visual** y los iconos 2D.

**Criterio de hecho global:** existe en `Vandrheim-design.pen` el tablero `C3BmQ` con los frames aprobados para tracker, panel, Guía con elección de arma y recursos de iconos/marcadores, en PC y móvil, con handoff listo para el dev.

> **Entrega final:** `HU-ESTETICA-51-ENTREGA-DISENO.md` contiene los frames aprobados (`U2DrUw`, `aWOwA`, `QEGTx`, `S0b7Dv`, `XfaqE`, `CRR6f`, `W9kgu`, `Acbwt`, `rjx7B`, `kysdI`). El tablero es `C3BmQ`.
>
> **Decisiones finales PO 2026-10-31 (superseden el resto del brief):**
> - Tracker: solo misión activa; tarjetas secundarias sin misiones (si se conservan); sin log.
> - Detalle: panel Cuaderno (`S0b7Dv`).
> - Elección de arma: dentro del panel del Guía (`CRR6f`); sin modal.
> - Notificaciones: reutilizar las existentes; no diseñar nuevas.
> - Paneles 2, 4 y 4b: descartados.
> - Paneles 7, 8 y 9: aprobados como recursos del dev.
> - Los diseños son orientativos; juego/config/detalle técnico mandan.

---

### Referencias de diseño

Archivo: `Vandrheim-design.pen`.

| Referencia | Uso |
|---|---|
| `EST-13` tokens Hearthbound Gold | Paleta, fuentes, 9-slice, botones y barras. |
| `EST-20` HUD de combate | Tamaño/posición del tracker y no solapamiento con skillbar/party/target. |
| `EST-22` PartyFrame | Patrón compacto de tarjetas y estados. |
| `EST-31` NotificationFrame | Reutilizar notificaciones; no crear otro sistema. |
| `EST-43` Mochila | Patrón de grilla/casillas y pie de capacidad. |
| `EST-50` Cuaderno | Lenguaje de panel/libro de dos páginas para el panel de misiones. |
| `R6.27` casillas | Fondo negro + hover de borde para ítems. |

No crear una paleta ni un lenguaje visual nuevos. El panel de misiones debe sentirse parte de Vandrheim, no una ventana genérica.

---

### Pantallas / frames a diseñar

Nombres propuestos; el diseñador puede ajustar el nombre, pero debe entregar **ID de frame** por cada uno.

#### 1. Quest Tracker — PC y móvil

* Frame compacto, siempre visible.
* Contenido: **solo la misión activa**: título, paso actual, progreso (`0/3`, `1/3`), distancia y dificultad. Tarjetas secundarias sin misiones (si se conservan) y sin recompensa en el tracker.
* Estado “sin misión activa”: texto breve + “Ver misiones”.
* Desktop: lado derecho, debajo/de alineado con PartyFrame; no tapar target/skillbar.
* Móvil: versión compacta, adaptable, con tap para abrir panel.
* Debe funcionar sobre combate y hub; incluir mock sobre una captura del HUD.

#### 2. Quest Log simple — 3 pendientes — **Descartado (PO 2026-10-31)**

* Lista de hasta 3 pendientes con título, dificultad, progreso y estado.
* “Ver todas” abre el panel completo.
* Estado vacío: “No hay misiones pendientes”.
* Desktop y móvil.

#### 3. Panel completo de misiones

* Formato libro/Cuaderno de dos páginas (patrón EST-50) o panel de ventana existente; elegir uno y justificarlo.
* **Izquierda:** tabs **Activas / Pendientes / Completadas / Disponibles** + lista.
* **Derecha:** detalle de la quest: título, giver, dificultad, descripción, pasos con progreso, recompensa (XP, oro, ítems), estado de mochila, botones **Trackear / Reclamar / Omitir** (según estado).
* Estados obligatorios:
  * Activa con progreso.
  * Pendiente.
  * Completada lista para reclamar.
  * Reclamada.
  * Disponible en el Guía.
  * Sin misiones.
  * Límite de 5 pendientes.
  * Mochila llena (claim deshabilitado + aviso).
* Mobile: misma información, lista y detalle apilados; botones táctiles ≥44 px.

#### 4. Panel del Guía (NPC)

* Diálogo simple, sin ramas: retrato/icono del Guía, nombre “Guía de la Helada”, título de la quest, descripción breve, recompensa y botón **Continuar / Elegir arma / Entregar / Reclamar**.
* **La elección de arma vive en este panel (paso 2)**: no hay modal separado.
* Estados: paso 1 (hablar), paso 2 (elegir arma), arma ya elegida, quest completada, mochila llena, quest omitida (si aplica).
* Desktop y móvil.

#### 4b. Selección de primera arma — PC y móvil — **Descartado; va dentro del panel del Guía**

* Histórico: modal que abría el Guía en el paso 2; **descartado**, la elección vive en el panel del Guía.
* 2 tarjetas por clase (recomendada/experimental): icono del arma, nombre, tipo (1H/2H/varita), stats, rareza Common, nivel 1 y tag “Recomendada” / “Experimental”.
* Botón **Elegir**; estados: normal, hover/seleccionada, equipada, mochila llena, bloqueada.
* Una línea de playstyle por opción; no inventar stats, usar los templates existentes.
* PC: 2 tarjetas lado a lado; móvil: apiladas, botones táctiles ≥44 px.

#### 5. Notificaciones — **No se diseña; reutilizar las existentes**

* Reutilizar el `NotificationFrame` centralizado existente, con sus títulos y colores de código.
* No diseñar ejemplos, títulos, colores ni ventanas nuevas.
* El dev usa el sistema actual para misión aceptada, paso completado, misión completada, recompensa reclamada y mochila llena.

#### 6. Kit de iconos y dificultad

* Iconos 24/32/48 px: quest giver `!`, turn-in `?`, tracker, panel, objetivo hablar/entrar/matar/loot/completar piso.
* Badges de dificultad: `Intro`, `Fácil`, `Normal`, `Difícil`, `Élite` con color + label (no solo color).
* Iconos de recompensa: XP, oro, poción.
* Estilo: runas/minimalismo nórdico, legible a 24 px, sin emojis.

#### 7. Kit de marcadores (referencia 3D)

* Board de referencia para el dev: color del haz, opacidad, icono flotante, anillo/flecha en el piso, flecha de borde si está fuera de cámara.
* Estados: objetivo activo, turn-in, disponible.
* No es una pantalla de UI; es una guía visual para implementar en Studio.

---

### Contenido real para los mocks

Usar la quest `intro_helada`:

* Título: **El primer invierno**.
* Giver: **Guía de la Helada**.
* Dificultad: **Intro**.
* Pasos: hablar con el Guía → elegir arma → entrar a la Helada → derrotar 3 enemigos → recoger 1 botín → completar el piso 1.
* Primera recompensa: **elección de arma inicial** antes de la dungeon.
* Recompensa final: **XP para nivel 2 + 10 pociones comunes de salud**; sin oro.
* Opciones de arma:
  * Paladín: `sword_white` + `shield_white` (recomendada) / `greatsword_white`.
  * Cazador: `bow_white` (recomendada) / `sword_white`.
  * Clérigo: `wand_white` (recomendada) / `sword_white` (experimental).
* Estados de progreso: `0/3`, `1/3`, `3/3`; arma elegida; completada; reclamada; mochila llena.

No inventar quests nuevas ni recompensas distintas.

---

### Reglas de diseño

* Tokens Hearthbound Gold: latón `#C89445`, pergamino `#F4EDE0`, frío `#8FB7D6`, fondos oscuros cálidos.
* Tipografías del proyecto (EST-13: Playfair Display / Inter / Geist Mono).
* Casillas de ítems: fondo negro + hover de borde (R6.27).
* Tracker compacto y legible; no tapar combate ni HUD.
* Panel con jerarquía clara: título → pasos → recompensa → acción.
* Dificultad con color + texto; no depender solo del color.
* Botones táctiles ≥44 px en móvil; texto legible en 360 px de ancho.
* Consistencia con Mochila/Equipo/Matchmaking; reutilizar 9-slice y componentes.
* Sin emojis; iconos propios o del set existente.
* No diseñar la lógica ni los datos; solo la representación.

---

### Handoff al dev

* Un **ID de frame** por cada vista/estado; nombres estables.
* Página de especificaciones con medidas, colores, fuentes, espaciados y estados.
* Exportar iconos PNG con alfa y registrar en `ASSETS_LIST.md` / `ASSETS_REGISTRY`.
* Indicar qué componentes son reutilizados de EST-13/20/22/31/43/50.
* Entregar PC y móvil; incluir mock sobre HUD/hub para verificar solapamientos.
* El dev implementa con los IDs; no se aceptan frames sin ID.

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Tracker PC

* **GIVEN** el set de diseño en Pencil
* **WHEN** se revisa el tracker en PC
* **THEN** muestra título, paso, progreso, distancia y recompensa
* **AND** no tapa target, party ni skillbar

#### Escenario 2: Tracker móvil

* **GIVEN** el set móvil
* **WHEN** se revisa en 360 px de ancho
* **THEN** el tracker es legible, compacto y táctil
* **AND** no tapa controles

#### Escenario 3: Log simple — **Descartado**

* **GIVEN** la decisión PO 2026-10-31
* **WHEN** se revisa el set
* **THEN** no hay log separado
* **AND** el detalle de todas las misiones vive en el panel (Cuaderno)

#### Escenario 4: Panel completo

* **GIVEN** el panel de misiones
* **WHEN** se revisan sus tabs y el detalle
* **THEN** incluye Activas/Pendientes/Completadas/Disponibles
* **AND** muestra pasos, recompensa y acciones Trackear/Reclamar/Omitir según estado

#### Escenario 5: Mochila llena

* **GIVEN** una quest completada con recompensa de 10 pociones
* **WHEN** la mochila no tiene espacio
* **THEN** el diseño muestra “Mochila llena” y el claim deshabilitado
* **AND** el jugador entiende que debe liberar espacio

#### Escenario 6: Límite de pendientes

* **GIVEN** 5 misiones pendientes
* **WHEN** se intenta aceptar otra
* **THEN** el diseño muestra el límite y la acción bloqueada

#### Escenario 7: Panel del Guía

* **GIVEN** el diseño del Guía
* **WHEN** se revisan sus estados
* **THEN** incluye hablar, elegir arma, entregar, reclamar y mochila llena
* **AND** no tiene diálogo ramificado

#### Escenario 7b: Selección de primera arma — **En el panel del Guía**

* **GIVEN** el estado 2 del Guía
* **WHEN** se revisan las 2 tarjetas por clase
* **THEN** cada tarjeta muestra icono, nombre, tipo, stats, rareza, nivel y tag recomendada/experimental
* **AND** incluye estados normal, seleccionada, equipada, mochila llena y bloqueada
* **AND** no hay modal separado

#### Escenario 8: Dificultades

* **GIVEN** los badges de dificultad
* **WHEN** se revisan Intro/Fácil/Normal/Difícil/Élite
* **THEN** cada uno tiene color y label legibles
* **AND** no se confunden con la rareza de ítems

#### Escenario 9: Marcadores

* **GIVEN** el board de marcadores
* **WHEN** el dev lo usa como referencia
* **THEN** incluye haz, icono flotante, anillo/flecha y flecha de borde
* **AND** hay estados activo/turn-in/disponible

#### Escenario 10: Handoff

* **GIVEN** la entrega del diseñador
* **WHEN** el dev abre el `.pen`
* **THEN** cada vista/estado tiene ID y nombre estable
* **AND** hay página de especificaciones, iconos exportados y referencias de componentes

---

### Alcance

#### Incluye

* Tracker PC/móvil.
* Tracker solo con la misión activa.
* Panel completo (Cuaderno) con tabs y estados; sin log separado.
* Panel del Guía (hablar/elegir arma/entregar/reclamar/mochila llena); la elección de arma va dentro del panel.
* Notificaciones reutilizando el sistema existente (sin diseño nuevo).
* Kit de iconos, dificultad y marcadores.
* Contenido real de `intro_helada`.
* Handoff con IDs, specs e iconos.

#### No incluye

* Código, lógica, datos ni backend.
* Nuevas quests, recompensas o sistemas.
* Rediseño del HUD, party, mochila, notificaciones o matchmaking.
* Assets 3D finales (haz/beam se implementan en Studio con la referencia).
* Minimapa.

---

### Definition of Done (DoD)

* [ ] Frames de tracker PC/móvil con ID.
* [ ] Tracker solo con la misión activa; tarjetas secundarias sin misiones (si se conservan).
* [ ] Panel completo con tabs, detalle y todos los estados; sin log separado.
* [ ] Panel del Guía con estados, incluida la elección de arma.
* [ ] Ejemplos de notificaciones reutilizando EST-31.
* [ ] Kit de iconos y dificultades.
* [ ] Board de marcadores 3D.
* [ ] Contenido real de `intro_helada`.
* [ ] Mock sobre HUD/hub para verificar solapamientos.
* [ ] Página de especificaciones y handoff.
* [ ] Iconos exportados/registrados.
* [ ] Aprobación del PO.

---

### Decisiones por defecto

| Tema | Default |
|---|---|
| Panel | Libro/Cuaderno de dos páginas (patrón EST-50) |
| Tracker | Lado derecho, compacto, click/tap abre panel |
| Log | Sin log separado; detalle en el panel |
| Acceso | `L` + icono en micromenú + botón móvil |
| Dificultad | Color + label; no solo color |
| Notificaciones | Reutilizar EST-31 |
| Arma inicial | Panel del Guía (paso 2), 2 tarjetas por clase; sin modal |
| Marcadores | World-space; Pencil solo referencia/iconos 2D |
| Móvil | 360 px, botones ≥44 px |

---

### Estimación (orientativa)

1–2 sesiones del diseñador: tracker/panel/Guía con elección de arma, estados, iconos, board de marcadores y handoff.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-10-27 | Creación de HU-ESTETICA-51: diseño en Pencil del tracker, log simple, panel completo, Guía, notificaciones, dificultades, iconos y marcadores para el sistema de misiones y la onboarding `intro_helada`. |
| 2026-10-27 | **Cambio PO:** se agrega la selección de primera arma (2 opciones por clase) y el estado de arma equipada/mochila llena. |
| 2026-10-31 | **Decisiones finales:** tracker solo activo; sin log separado; detalle en el Cuaderno; elección de arma dentro del panel del Guía (sin modal); notificaciones existentes. Paneles 2, 4 y 4b descartados; 7, 8 y 9 aprobados como recursos. |
