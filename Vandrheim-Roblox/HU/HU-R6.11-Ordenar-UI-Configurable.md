# HU-R6.11: Ordenar la UI de forma manual — modo edición con cuadrícula, HUD configurable y persistencia por personaje

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** UI / Menú / R6.11
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Sistema de UI configurable por el usuario (dev; sin diseñador — es UI funcional sobre el sistema Hearthbound Gold)
**Fase GDD:** R6.11 (posterior a R6.10; no modifica reglas de juego)
**Depende de:** HU-R6.10 (menú ESC con el placeholder "Orden de UI" → **esta HU lo implementa**), HU-R6.5 (HUD: player frame, target frame, skillbar, XP/oro, slots Z/X, micro menú), HU-R2 (perfil por personaje en DataStore), HU-R6.10 (ventanas: mochila/equipo/talentos/grimorio/vendor), HU-ESTETICA-13 (estilos)
**Componentes observados:** `StarterGui.MenuUI` (botón "Orden de UI" placeholder), `StarterGui.HUD` (frames del HUD), ventanas (`InventoryUI`, `EquipmentUI`, `TalentUI`, `SpellbookUI`, `VendorUI`), `DataService` (perfil por characterId), remotes de perfil existentes

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** ordenar la UI a mi gusto desde el menú: activar una cuadrícula que marque el centro de la pantalla, mover los frames del HUD (player, target, skillbar, consumibles, micro menú) y que se guarde **por personaje** entre sesiones,
**para** acomodar la interfaz a mi forma de jugar y que se mantenga cada vez que entro.

**Como** jugador,
**quiero** poder **arrastrar las ventanas** (mochila, stats, grimorio, talentos) para acomodarlas y ver varias a la vez durante la sesión,
**para** comparar paneles sin perder mi configuración guardada.

**Como** equipo de desarrollo,
**quiero** implementar el botón "Ordenar UI" que quedó como placeholder en el menú in-game (R6.10),
**para** cerrar el placeholder con una función real, persistente y sin romper la lógica existente.

---

### **Descripción del Requerimiento / Contexto**

El menú in-game (R6.10) tiene el botón **"Orden de UI"** como placeholder ("Próximamente"). Esta HU lo implementa:

1. **Modo de edición del HUD:** al pulsar "Ordenar UI" se activa una **cuadrícula en pantalla** que marca el **centro** (líneas vertical/horizontal) y guías de simetría/tamaño. Desde ahí el jugador puede **mover todos los frames del HUD** (player frame, target frame, skillbar, barra de consumibles Z/X, micro menú, y el resto de elementos HUD fijos del diseño).
2. **Persistencia por personaje:** al finalizar, los cambios se guardan en el **perfil del personaje** (DataStore, R2) y se **mantienen entre sesiones** — cada personaje tiene su propio layout.
3. **Ventanas arrastrables (sin persistir):** mochila, equipo/stats, grimorio y talentos se pueden **arrastrar por su header** para acomodarlas y ver varias a la vez; la posición **no se guarda** entre sesiones (es solo comodidad de la sesión actual).

**Criterio de hecho global:** desde el menú, el jugador activa la cuadrícula, mueve los frames del HUD con límites seguros, guarda el layout por personaje (persiste al rejoin y es independiente por PJ), y las ventanas se arrastran libremente durante la sesión sin tocar la configuración guardada.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Botón en el menú in-game (MenuUI)**

* El botón **"Ordenar UI"** pasa de placeholder a **funcional** (los placeholders de Volumen/Gráficos se mantienen como están).
* Al pulsarlo: se cierra el menú y se entra al **modo de edición**.

#### **2. Modo de edición (HUD)**

* **Overlay de edición** (`ScreenGui` nueva, `EditLayoutUI`):
  * **Cuadrícula** en pantalla: línea **central vertical** y **central horizontal** (marcan el centro exacto), guías de tercios (opcional) y regla con medidas (ancho/alto en escala) para que el jugador vea **tamaños y simetrías**.
  * Fondo atenuado; cursor normal; **pausa de cámara** (como las ventanas, R3.1).
  * Al entrar: se **apagan las interacciones de juego** (skills, targeting, uso de ítems — el jugador no pelea en modo edición).
* **Frames movibles del HUD** (drag con mouse):
  * Player frame (nombre+nivel, HP, MP, XP, oro).
  * Target frame (nombre+nivel, HP, élite).
  * Skillbar (4 slots).
  * Consumable bar (slots Z/X).
  * Micro menú (botones BOLSA/EQUIPO/MENÚ).
  * (Si el diseño de EST-19 lo contempla: boss bar y level up **siguen** a sus anclas — no son arrastrables por separado por defecto).
* **Crosshair: bloqueado** (es el centro de la puntería; no se mueve).
* **Límites de drag:** cada frame queda **dentro de la pantalla** (clamp con margen mínimo) y respeta la **zona segura móvil** (`GetSafeAreaInsets`).
* **Snap opcional:** toggle para que los frames se alineen a las líneas de la cuadrícula (centro/tercios) al soltar.
* **Salir:** botón "Listo" guarda y sale; `ESC` sale **sin guardar** (o con confirmación si hubo cambios — decisión: confirmación "¿Guardar cambios?").

#### **3. Persistencia por personaje (server-authoritative)**

* **Dato:** `profile.uiLayout` por personaje (R2: perfil por characterId): `{ [elementId] = { x = 0..1, y = 0..1 } }` (posiciones **normalizadas** en Scale, válidas para cualquier resolución).
* **Remote nuevo:** `RequestSaveUILayout` (C→S) `{ layout }` + `SaveUILayoutResult` (S→C `{ success }`):
  * Server valida: solo `elementId` de la **whitelist** del HUD, posiciones normalizadas (0–1) y dentro de clamps; descarta lo inválido (anti-exploit).
  * Se guarda en el perfil del personaje activo y se persiste con el flujo de save existente (R2).
* **Aplicación:** al spawnear el PJ activo, el cliente aplica `profile.uiLayout` después de construir el HUD (sin duplicar frames ni romper jerarquía/nombres que los scripts usan).
* **Por personaje:** cada PJ guarda el suyo; cambiar de personaje usa el layout de ese PJ.

#### **4. Ventanas arrastrables (sesión actual, sin persistir)**

* **Mochila (B), Equipo+Stats (C), Grimorio y Talentos** (y vendors si aplica) se arrastran por su **header** con el mouse (y touch).
* **Sin persistencia:** al cerrar la ventana o salir del juego, la posición vuelve al default de la próxima sesión; **no toca** el layout guardado del HUD.
* **Límites:** la ventana no puede salirse de la pantalla (clamp) ni quedar inaccesible.
* No cambia la lógica de las ventanas (abrir/cerrar, pausa de cámara, ESC, etc.).

#### **5. Mobile / regresión**

* Touch: en modo edición se arrastra con el dedo (drag en el frame); cuadrícula visible y útil en móvil; las ventanas se arrastran desde el header táctil.
* `UIScale` + `UIAspectRatioConstraint` intactos (se mueven posiciones Scale, no tamaños).
* No romper: combate, targeting, ESC, inventario, equip, stats, talentos, grimorio, vendors.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Activar el modo edición**

* **GIVEN** el menú in-game abierto
* **WHEN** el jugador pulsa "Ordenar UI"
* **THEN** se abre el modo edición con la cuadrícula (centro vertical/horizontal visible)
* **AND** el cursor es normal, la cámara pausa y no se puede pelear

#### **Escenario 2: Mover frames del HUD**

* **GIVEN** el modo edición activo
* **WHEN** el jugador arrastra el player frame, target frame, skillbar, consumable bar o micro menú
* **THEN** los frames se mueven y quedan dentro de la pantalla (clamps + zona segura)
* **AND** el crosshair no se puede mover

#### **Escenario 3: Guardar y persistir por personaje**

* **GIVEN** el jugador guarda el layout
* **WHEN** sale del juego y vuelve a entrar con el mismo PJ
* **THEN** el HUD aparece en las posiciones guardadas
* **AND** otro personaje del mismo jugador usa su propio layout (independiente)

#### **Escenario 4: ESC sin guardar**

* **GIVEN** el modo edición con cambios sin guardar
* **WHEN** el jugador pulsa ESC
* **THEN** se pregunta si quiere guardar (o se descartan los cambios)
* **AND** el layout guardado previo no se pierde

#### **Escenario 5: Ventanas arrastrables**

* **GIVEN** la mochila, stats, grimorio o talentos abiertos
* **WHEN** el jugador arrastra la ventana por su header
* **THEN** la ventana se mueve (puede ver varias a la vez)
* **AND** al cerrarla/reentrar, la ventana vuelve a su posición default (sin persistir)

#### **Escenario 6: Móvil**

* **GIVEN** un dispositivo táctil
* **WHEN** se usan el modo edición y el drag de ventanas
* **THEN** funciona con touch y respeta la zona segura
* **AND** no rompe joystick, botones táctiles ni el HUD móvil

#### **Escenario 7: Anti-exploit**

* **GIVEN** un cliente envía un layout manipulado (ids fuera de whitelist, posiciones inválidas)
* **WHEN** llama `RequestSaveUILayout`
* **THEN** el servidor descarta lo inválido y guarda solo lo válido
* **AND** el perfil no se corrompe

#### **Escenario 8: Regresión**

* **GIVEN** el sistema implementado
* **WHEN** se juega el flujo completo (jugar → menú → ordenar → guardar → combatir → dungeon → rejoin)
* **THEN** no hay errores rojos
* **AND** inventario, skills, dungeon, vendors y talentos siguen funcionando

---

### **Comportamiento Visual / Reglas de Negocio**

* El modo edición es **solo layout**: no cambia stats, inventario, oro ni progresión.
* La cuadrícula usa un estilo funcional mínimo coherente con la paleta (líneas latón `#C89445`/pergamino tenue sobre fondo atenuado).
* El layout guardado es **por personaje**; las ventanas arrastrables son **de sesión** (no se guardan).
* Los frames conservan su escala/responsive; solo cambia su posición (Scale).

---

### **Alcance**

#### Incluye

* Botón "Ordenar UI" funcional en el menú (R6.10) + modo edición con cuadrícula (centro, tercios, regla, snap opcional).
* Drag de frames del HUD (player, target, skillbar, consumable bar, micro menú) con clamps y zona segura; crosshair bloqueado.
* Persistencia por personaje: `profile.uiLayout` + `RequestSaveUILayout` (validado) + aplicación al spawnear.
* Ventanas arrastrables por header (mochila, equipo/stats, grimorio, talentos, vendors) sin persistencia.
* Touch (móvil) para edición y drag.

#### No incluye

* Cambios de tamaño/posición de elementos por config global (solo por jugador).
* Placeholders de Volumen/Gráficos del menú (siguen pendientes).
* Cambios a reglas de juego, balance, combate ni economía.
* Diseño nuevo en Pencil (es UI funcional; estilo sobre tokens EST-13).

---

### **Definition of Done (DoD)**

* [ ] "Ordenar UI" del menú abre el modo edición con cuadrícula (centro visible) y pausa de interacciones.
* [ ] Frames del HUD movibles con clamps + zona segura; crosshair fijo; snap opcional.
* [ ] Guardado por personaje: `profile.uiLayout` persiste al rejoin y es independiente por PJ.
* [ ] `RequestSaveUILayout` validado (whitelist + posiciones 0–1); perfil nunca se corrompe.
* [ ] Ventanas (mochila, stats, grimorio, talentos, vendors) arrastrables por header, sin persistir.
* [ ] Funciona con touch y respeta zona segura.
* [ ] Sin errores rojos en jugar → ordenar → guardar → combatir → dungeon → rejoin.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Al cerrar: PROJECT_ARCHITECTURE, DATA_SCHEMA (campo `uiLayout` por personaje) y registro HU/RC actualizados; nota en GDD después de QA.

---

### **Decisiones por defecto R6.11**

| Tema | Default |
|------|---------|
| Botón | "Ordenar UI" del menú (R6.10) pasa a funcional |
| Elementos movibles | Player frame, target frame, skillbar, consumable bar, micro menú |
| Crosshair | Fijo (centro de puntería) |
| Snap | Opcional (toggle a líneas de la cuadrícula) |
| Persistencia | Por personaje (`profile.uiLayout`), server-validada |
| Ventanas arrastrables | Sesión actual, sin guardar |
| Salir del modo | Botón "Listo" (guarda) / ESC (confirma descarte) |

---

### **Estimación (orientativa)**

2–3 sesiones del dev: modo edición + cuadrícula + drag del HUD + persistencia por personaje + drag de ventanas + móvil + regresión.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-18 | Creación de HU-R6.11: sistema de orden de UI manual — botón "Ordenar UI" del menú (implementa el placeholder de R6.10), modo edición con cuadrícula de centro/simetría, frames del HUD movibles y configurables por personaje (persiste en perfil), y ventanas arrastrables por sesión — sin tocar la lógica |