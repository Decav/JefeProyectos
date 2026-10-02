# HU-ESTETICA-14: Implementación del reskin de UI en Roblox (dev) — del diseño de Pencil al juego

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / Implementación
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Implementación de UI en Roblox Studio (dev)
**Fase GDD:** EST (transversal; habilita el reskin de toda la interfaz)
**Depende de:** HU-ESTETICA-04 (sistema de diseño Hearthbound Gold), HU-ESTETICA-06 (revisión UI), HU-ESTETICA-08/09/10/11/12 (diseños a fondo por pantalla), **HU-ESTETICA-13 (paquete de specs/assets del diseñador)**, HU-R6.5 (ventanas actuales), HU-R6.10 (menú ESC), ASSETS_POLICY/ASSETS_LIST
**Componentes observados:** `StarterGui` (HUD, InventoryUI, EquipmentUI, TalentUI, SpellbookUI, MenuUI, VendorUI, CharacterSelect, CharacterCreate, RewardUI), `StarterPlayer.StarterPlayerScripts` (InventoryClient y clientes de ventanas), `ReplicatedStorage.Config` (ItemConfig, ItemRarity), servicios de gameplay (intactos)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que el juego se vea con la nueva interfaz Hearthbound Gold (HUD, mochila, equipo/stats, talentos, grimorio, vendors, menús, móvil),
**para** que la UI se sienta moderna, coherente y a la altura del resto del juego.

**Como** desarrollador,
**quiero** aplicar el reskin del diseño de Pencil **sobre las ventanas existentes** en Roblox (ScreenGui/Frame/ImageLabel/TextLabel/UIStroke/UIGradient/TweenService) usando el paquete de `HU-ESTETICA-13`,
**para** reemplazar la UI actual de forma progresiva **sin tocar la lógica** (inventario, talentos, skills, vendors, menú).

---

### **Descripción del Requerimiento / Contexto**

El diseñador entregó el sistema visual completo en `Vandrheim-design.pen` (referencia visual) + el paquete de handoff de `HU-ESTETICA-13` (specs con valores exactos, mapeo de fuentes a Roblox, assets 9-slice/botones/barras/iconos, notas de adaptación).

El diseño **no se importa directamente**: el visual de Pencil se monta en Roblox con primitivas de UI (ImageLabel/Frame/TextLabel/UIStroke/UIGradient) **sobre las ventanas ya existentes** (HUD, mochila, equipo, talentos, grimorio, vendors, menú, selección/creación — R6.5/R6.10/R5.1/R5). El dev aplica el reskin respetando la regla de EST-04: **se conservan los nombres de instancias y la jerarquía que los scripts usan**, todo con `Scale` + `UIAspectRatioConstraint`, y la lógica de gameplay queda intacta. Los ajustes de layout que piden las HUs de diseño (ej. equipo en dos columnas, árbol con ramas conectadas) se hacen **dentro de la ventana existente**, sin rehacerla ni renombrar lo que el código referencia.

**Criterio de hecho global:** la UI del juego se ve como el diseño aprobado en todas las pantallas (PC y móvil), con la lógica existente funcionando sin cambios.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Alcance por ventana (orden de implementación sugerido)**

| # | Pantalla | GUI existente (mantener nombres/jerarquía) | Cambios |
|---|----------|---------------------------------------------|---------|
| 1 | **HUD** (PC) | `StarterGui.HUD` (R6.5) | Player card (nombre+nivel, HP/MP/XP/oro), target frame (nombre+nivel/HP/élite), crosshair, skillbar 4 (tecla+coste+CD), slots Z/X, estilos Hearthbound Gold |
| 2 | **Mochila (B)** | `InventoryUI` (R6.5) | 20 slots con pilas `xN`, marcos de rareza, tooltip de ítem (stats/afijos/levelReq/BoE) con acciones, marcado del ítem asignado a Z/X (EST-11) |
| 3 | **Equipo + Stats (C)** | `EquipmentUI` (R6.5/rc022) | Dos columnas: 9 slots con equipo activo + stats compactas; desglose **bajo demanda** (fila expandida/tooltip) que cita ítems; resaltado slot↔stat (EST-10) |
| 4 | **Talentos** | `TalentUI` (R5.1/rc031) | Árbol WoW 3 ramas conectadas, estados de nodo, pips de rank, tooltip por rank, contador de puntos, respec con confirmación (EST-08) |
| 5 | **Grimorio** | `SpellbookUI` (R5.1) | Skills aprendidas con tipo/maná/CD/origen, estados (asignada/no asignada/bloqueada), vista previa de la barra de 4 (EST-09) |
| 6 | **Vendors (3 ventanas independientes)** | `VendorUI` (R5) | Vendedor de pociones (sin vender), Armero (pestañas Comprar/Vender, venta por unidad), Instructor (respec 100 oro + confirmación) — EST-12 |
| 7 | **Menú ESC** | `MenuUI` (R6.10) | Botones con iconos (play/users/settings), estados, placeholders de ajustes (EST-04/06) |
| 8 | **Selección / Creación de PJ** | `CharacterSelect` / `CharacterCreate` (R2) | Estilos Hearthbound Gold (slots de PJ, bloqueo Robux, creación nombre+clase) |
| 9 | **Recompensa / Tooltips** | RewardUI + tooltips (R4/R7) | Popup de loot, tooltip de ítem transversal |
| 10 | **Mobile HUD** | HUD móvil (R6.5) | Variante táctil: player card, 4 skills táctiles, botones BOLSA/EQUIPO/MENÚ, safe area |

#### **2. Fuentes (mapeo EST-13, confirmar nombres del `Font` enum en Studio)**

| Diseño | Fuente Roblox (default) | Alternativa |
|--------|-------------------------|-------------|
| Playfair Display | `PlayfairDisplay` | — |
| Inter | `Inter` | `GothamSSM` |
| Geist Mono | `RobotoMono` | `Inconsolata` |

* Si una alternativa se usa en un elemento concreto, se reporta; no se inventan fuentes por elemento.
* Revisar **reflow de texto** (labels que se cortan o ensanchan con la fuente mapeada) y ajustar tamaños dentro de la misma ventana.

#### **3. Assets**

* Subir al **Asset Server** los iconos de ítems/skills pendientes (estándar ASSETS_LIST, fondo negro = finales) y colocar `rbxassetid` en `ItemConfig.iconId` (patrón actual; uniques usan nombre de asset en `Assets/Icons`).
* Paneles: `ImageLabel` con `ScaleType.Slice` (márgenes de corte del paquete EST-13); botones: `ImageButton` con 3 estados (normal/hover/disabled); barras: fondo + fill separados (el fill escala por ancho, patrón actual).
* Registrar todo asset incorporado en `ASSETS_REGISTRY` (id, fuente, licencia).

#### **4. Animaciones (TweenService, según EST-13)**

* Ventanas abrir/cerrar: fade + scale 0.15–0.25 s (easing Quad/Out); hover de botones/casillas: 0.1 s; popups/confirmaciones: easing Back corto.
* Descartar explícitamente animaciones CSS-only sin equivalente útil (las marca el paquete).

#### **5. Mobile / responsive**

* `UIScale` + `UIAspectRatioConstraint` en todas las ventanas (patrón actual; sin layout absoluto por píxel).
* Zona segura: `GuiService:GetSafeAreaInsets()` aplicado a HUD móvil y ventanas (márgenes del paquete EST-13).
* Botones táctiles (BOLSA/EQUIPO/MENÚ, barra) accesibles; mismo flujo de interacción PC/Touch.

#### **6. Lógica intacta (reglas duras)**

* No se modifican: `InventoryService`, `TalentService`, `VendorService`, `SkillService`, `CharacterService`, `DataService`, remotes, `ItemConfig`/`TalentConfig`/`SkillConfig`/`EnemyConfig` (salvo `iconId`/`visualModelId` nuevos).
* No se crean RemoteEvents nuevos; no se cambian reglas de juego, stacking, precios, balance ni progresión.
* Los scripts referencian instancias por nombre: el reskin respeta la jerarquía existente.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: HUD fiel al diseño**

* **GIVEN** el HUD implementado
* **WHEN** se compara con la pantalla 01 del `.pen`
* **THEN** player card, barras (HP/MP/XP/target), crosshair, skillbar 4 y slots Z/X se ven como el diseño
* **AND** HP/MP/XP/oro se actualizan en vivo como hoy

#### **Escenario 2: Ventanas con estados**

* **GIVEN** mochila, equipo/stats, talentos y grimorio implementados
* **WHEN** se revisan estados (pilas, tooltips, nodos, habilidades, desglose bajo demanda)
* **THEN** cada estado se ve como el diseño de su HU (EST-08 a 11) y funciona con la lógica existente

#### **Escenario 3: Vendors separados**

* **GIVEN** los 3 NPCs
* **WHEN** se habla con cada uno
* **THEN** cada uno abre su ventana (pociones / armero con Comprar+Vender / instructor con respec)
* **AND** precios y oro se muestran con los valores reales (VendorConfig)

#### **Escenario 4: Fuentes y assets**

* **GIVEN** la UI implementada
* **WHEN** se revisan fuentes, paneles y botones
* **THEN** las fuentes son las mapeadas (o alternativas reportadas), los 9-slice no deforman, y los botones tienen 3 estados

#### **Escenario 5: Móvil**

* **GIVEN** un dispositivo táctil
* **WHEN** se usa la UI
* **THEN** la UI escala (UIScale + aspect ratio), respeta la zona segura y los botones táctiles funcionan
* **AND** no rompe joystick ni el flujo móvil

#### **Escenario 6: Regresión total**

* **GIVEN** el reskin completo
* **WHEN** se juega el flujo completo (crear PJ → jugar → mochila/equipo → talentos/grimorio → vendors → dungeon → menú ESC → volver → rejoin)
* **THEN** no hay errores rojos
* **AND** inventario, skills, dungeon, vendors, talentos y menú siguen funcionando

#### **Escenario 7: Anti-rotura de lógica**

* **GIVEN** un cliente intenta usar la UI nueva con payloads manipulados
* **WHEN** envía remotes de inventario/talentos/vendor
* **THEN** el server sigue rechazando (lógica intacta, validaciones existentes)

---

### **Comportamiento Visual / Reglas de Negocio**

* La referencia visual es el `.pen`; la verdad de implementación son los specs de EST-13.
* Cada ventana mantiene su comportamiento actual (pausa de cámara al abrir, cursor normal, cierre con ESC, etc.).
* Los iconos/estados siguen el estándar aprobado; sin emojis ni assets sin licencia.

---

### **Alcance**

#### Incluye

* Reskin completo de las 10 áreas de la tabla del punto 1 (HUD, mochila, equipo/stats, talentos, grimorio, vendors, menú ESC, selección/creación, recompensa/tooltips, mobile HUD).
* Aplicación de fuentes mapeadas, assets 9-slice/botones/barras e iconos (subida al Asset Server + ASSETS_REGISTRY).
* Animaciones TweenService según EST-13; zona segura móvil y responsive.
* Ajustes de reflow de texto derivados de las fuentes mapeadas.

#### No incluye

* Diseño en Pencil (diseñador; EST-08 a 13 ya entregadas).
* Cambios de lógica, reglas, balance, precios, stacking ni progresión.
* Assets 3D (EST-01/02/03/05/07) ni modelos de enemigos/pueblo.
* Nuevas mecánicas (trade, ordenar, pestañas nuevas que no existan).

---

### **Definition of Done (DoD)**

* [ ] HUD PC y móvil con estilo Hearthbound Gold (barras, crosshair, skillbar, slots Z/X, botones táctiles).
* [ ] Mochila (pilas, rarezas, tooltip con acciones, marcado Z/X) sin romper stacking/uso/venta.
* [ ] Equipo + Stats en dos columnas con desglose bajo demanda y resaltado slot↔stat.
* [ ] Talentos con árbol, estados, tooltips y respec; grimorio con estados y barra.
* [ ] 3 ventanas de vendor separadas y fieles a VendorConfig.
* [ ] Menú ESC, selección/creación de PJ y recompensa/tooltips con el nuevo estilo.
* [ ] Fuentes mapeadas aplicadas (o alternativas reportadas); 9-slice sin deformar; botones 3 estados.
* [ ] Iconos subidos y registrados (ASSETS_REGISTRY); sin assets sin licencia.
* [ ] Animaciones TweenService según specs; safe area móvil respetada.
* [ ] Sin errores rojos en el flujo completo (PC y móvil).
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Al cerrar: PROJECT_ARCHITECTURE, DATA_SCHEMA y registro HU/RC actualizados; nota en GDD después de QA.

---

### **Decisiones por defecto EST-14**

| Tema | Default |
|------|---------|
| Orden de implementación | HUD → Mochila → Equipo/Stats → Talentos → Grimorio → Vendors → Menú ESC → Selección/Creación → Recompensa → Mobile |
| Fuentes | PlayfairDisplay / Inter / RobotoMono (mapa EST-13; alternativa reportada si se usa) |
| Animaciones | Abrir/cerrar fade+scale 0.15–0.25 s; hover 0.1 s; popups Back corto |
| Mobile | UIScale + UIAspectRatioConstraint + SafeAreaInsets |
| Lógica | Intacta: sin cambios a servicios, remotes ni configs de gameplay (solo iconId/visualModelId) |

---

### **Estimación (orientativa)**

4–6 sesiones del dev: reskin por ventanas en el orden propuesto + assets + mobile + regresión completa.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-15 | Creación de HU-ESTETICA-14: implementación del reskin de UI en Roblox (dev) desde el diseño de Pencil + paquete EST-13; 10 áreas, fuentes mapeadas, assets, animaciones Tween, mobile y regresión — sin tocar la lógica |