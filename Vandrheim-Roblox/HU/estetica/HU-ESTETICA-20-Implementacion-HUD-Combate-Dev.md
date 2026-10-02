# HU-ESTETICA-20: Implementación del HUD de Combate en Roblox (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / Implementación (subconjunto de HU-ESTETICA-14)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Implementación de UI en Roblox Studio (dev)
**Fase GDD:** EST (transversal; ventana por ventana)
**Depende de:** HU-ESTETICA-19 (diseño del HUD de combate en Pencil), HU-ESTETICA-13 (paquete de specs/assets), HU-ESTETICA-14 (reskin general — esta HU ejecuta la parte del HUD), HU-R6.5 (HUD actual: player card, target, skillbar, XP/oro), HU-R6.2 (slots Z/X), HU-R6.10 (botón de menú), HU-R3.3 (indicador de target), HU-R7 (boss piso 5), HU-R6a (XP/leveling)
**Componentes observados:** `StarterGui.HUD` (R6.5/rc022), `StarterGui.MenuUI` (R6.10), `ReplicatedStorage.Config.TargetIndicatorConfig` (R3.3), servicios de HUD/skills/target/XP (intactos)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que el HUD de combate se vea como el diseño de Pencil: player frame, target frame, skillbar, barra de consumibles, micro menú, flecha de target, barra del boss y notificación de nivel,
**para** leer el combate de un vistazo con la estética Hearthbound Gold.

**Como** desarrollador,
**quiero** implementar el HUD de combate lo más fiel posible al frame del diseño, mirando el `.pen` como panorama completo,
**para** que la UI en juego se vea como la diseñada, **sin tocar la lógica** (HUD updates, cooldowns, targeting, XP, boss).

---

### **Descripción del Requerimiento / Contexto**

El diseñador entregó en `Vandrheim-design.pen` el diseño del HUD de combate (frame **"HU-ESTETICA-19 — Combat HUD"**) con la escena de pelea contra el boss del piso 5. El dev debe implementar los elementos **lo más cerca posible del frame**, usando el `.pen` como referencia visual completa (no solo el frame: abrir el diseño para ver el panorama de cómo debe quedar la UI).

Los elementos a implementar (según el diseño):

1. **Player frame** (card del jugador: nombre+nivel, HP, MP, XP, oro).
2. **Target frame** (nombre+nivel del objetivo, HP, estado élite).
3. **Skillbar** (4 slots: tecla, coste, CD, cooldown overlay).
4. **Consumable bar** (slots Z/X).
5. **Micro menú** (botones BOLSA/EQUIPO/MENÚ).
6. **Target arrow** (indicador sobre el objetivo seleccionado).
7. **Boss bar** (barra del Guardián de la Escarcha, piso 5).
8. **Level up** (notificación de subida de nivel).

**Criterio de hecho global:** el HUD de combate en juego se ve como el frame del diseño (elementos, colores, espaciados y estados), con la lógica existente funcionando, en PC y móvil.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Referencia visual**

* **Frame principal:** `HU-ESTETICA-19 — Combat HUD` (dentro de `Vandrheim-design.pen`; incluye el mockup de pelea contra el boss con números de daño, AoE, cooldowns).
* **Importante:** abrir el `.pen` y revisar el frame completo + los componentes del sistema (EST-04/06/13) para ver **el panorama completo de cómo debe quedar la UI**; el resultado debe ser **lo más cercano posible al frame**.
* Las pantallas viejas del HUD (ej. "01 HUD" genérico de EST-04) se actualizan al nuevo diseño; no quedan como referencia contradictoria.

#### **2. Reskin por elemento (sobre el HUD existente, R6.5/rc022)**

| Elemento | GUI existente | Cambios (según frame) |
|----------|---------------|------------------------|
| **Player frame** | Card del jugador (nombre+nivel, HP, MP, XP, oro) | Estilos Hearthbound Gold: barras HP/MP/XP con fill, oro, tipografías mapeadas, bordes/9-slice |
| **Target frame** | Frame del objetivo (nombre+nivel, HP, élite) | Estilos del diseño; estado élite diferenciado (como el frame) |
| **Skillbar** | 4 slots (tecla+coste+CD) | Estilos de casillas, overlay de **cooldown con cuenta regresiva**, resaltado al lanzar, coste de maná legible |
| **Consumable bar** | Slots Z/X (R6.2) | Estilos del diseño (casillas Z/X con el ítem asignado) |
| **Micro menú** | Botones móviles BOLSA/EQUIPO/MENÚ (R6.5/R6.10) | Estilos del diseño (iconos + labels); mismo flujo de apertura |
| **Target arrow** | `TargetIndicatorConfig` (R3.3) | Aplicar el **estilo del frame** (flecha/indicador sobre el objetivo) usando el sistema existente |
| **Boss bar** | Target frame o frame de boss (R7) | **Barra de boss distintiva** (nombre + HP grande) visible solo en la pelea del piso 5, como el frame; si no existe, crearla como frame propio sin tocar la lógica del boss |
| **Level up** | XP (R6a) | **Notificación de nivel** ("¡Nivel N!") con el estilo del frame; si no existe, añadirla como elemento visual leve (TweenService), sin tocar la lógica de XP |

#### **3. Estilos y assets**

* Tokens de `HU-ESTETICA-13` (paleta, radios, bordes, espaciados, escala tipográfica); fuentes mapeadas (PlayfairDisplay/Inter/RobotoMono, confirmar `Font` enum).
* Paneles `ImageLabel` con `ScaleType.Slice`; botones/casillas `ImageButton` 3 estados; barras con fondo + fill separados (el fill escala por ancho, patrón actual).
* Iconos de UI/skills según ASSETS_LIST (fondo negro = finales); subir faltantes al Asset Server + `ASSETS_REGISTRY`.
* Animaciones TweenService según EST-13 (abrir/cerrar 0.15–0.25 s, hover 0.1 s, level up con fade/scale breve).

#### **4. Mobile / responsive**

* `UIScale` + `UIAspectRatioConstraint` en el HUD (patrón actual); zona segura (`GetSafeAreaInsets`) para el micro menú y elementos móviles.
* Botones táctiles (BOLSA/EQUIPO/MENÚ, barra) accesibles; mismo flujo PC/Touch.

#### **5. Lógica intacta (reglas duras)**

* No se modifican: `SkillService`, `TargetingSystem` (R3.3), `XPService`, `InventoryService`, `MenuUI` (R6.10), remotes.
* Los scripts referencian instancias por nombre: el reskin respeta la jerarquía existente del HUD.
* La barra del boss y el level up son **presentación**: leen los datos existentes (HP del boss R7, XP R6a) sin cambiar reglas.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Fiel al frame**

* **GIVEN** el HUD de combate implementado
* **WHEN** se compara con el frame `HU-ESTETICA-19 — Combat HUD` del `.pen`
* **THEN** player frame, target frame, skillbar, consumable bar, micro menú, target arrow, boss bar y level up se ven como el frame
* **AND** el resultado es lo más cercano posible al diseño

#### **Escenario 2: En combate**

* **GIVEN** una pelea contra un mob y contra el boss del piso 5
* **WHEN** se combate
* **THEN** el target frame (mob) y la boss bar (piso 5, solo ahí) se muestran con los estilos del diseño
* **AND** la skillbar refleja cooldowns con cuenta regresiva y costes reales

#### **Escenario 3: Consumibles y micro menú**

* **GIVEN** el HUD
* **WHEN** se usan los slots Z/X y los botones del micro menú
* **THEN** se ven como el frame y abren los flujos existentes (usar ítem, abrir BOLSA/EQUIPO/MENÚ)

#### **Escenario 4: Target arrow**

* **GIVEN** un objetivo seleccionado
* **WHEN** se revisa el mundo
* **THEN** el indicador sobre el objetivo tiene el estilo del frame (TargetIndicatorConfig existente, sin cambiar targeting)

#### **Escenario 5: Level up**

* **GIVEN** el jugador sube de nivel
* **WHEN** gana XP suficiente
* **THEN** se muestra la notificación de nivel con el estilo del diseño
* **AND** la lógica de XP (R6a) no cambia

#### **Escenario 6: Móvil y regresión**

* **GIVEN** un dispositivo táctil
* **WHEN** se usa el HUD
* **THEN** escala (UIScale + aspect ratio), respeta la zona segura y los botones táctiles funcionan
* **AND** el flujo completo (combate → consumibles → menú → dungeon → rejoin) no produce errores rojos

#### **Escenario 7: Anti-rotura de lógica**

* **GIVEN** el HUD implementado
* **WHEN** se envían remotes de skills/ítems/targeting manipulados
* **THEN** el servidor sigue rechazando (lógica intacta)

---

### **Comportamiento Visual / Reglas de Negocio**

* El frame `HU-ESTETICA-19 — Combat HUD` es la **referencia visual**; los specs de EST-13 son la **verdad de implementación**.
* Los elementos de combate se leen sin tapar la acción (tamaños del diseño).
* La boss bar solo aparece en la pelea del piso 5; el level up es efímero y no bloquea el HUD.

---

### **Alcance**

#### Incluye

* Reskin de player frame, target frame, skillbar, consumable bar y micro menú sobre el HUD existente.
* Target arrow con el estilo del diseño (sobre TargetIndicatorConfig).
* Boss bar del piso 5 (crear el frame si no existe) y notificación de level up (añadir si no existe).
* Cooldown overlay con cuenta regresiva; fuentes mapeadas, 9-slice, iconos (subida + ASSETS_REGISTRY), animaciones Tween y safe area móvil.

#### No incluye

* Lógica de `SkillService`, `TargetingSystem`, `XPService`, `InventoryService` ni remotes (intactos).
* Números de daño flotantes/VFX (pertenecen a R6.8/R8a-b-c y a los VFX por skill).
* Las demás ventanas del reskin (mochila, equipo, talentos, grimorio, vendors — HUs propias).
* Diseño en Pencil (diseñador — HU-ESTETICA-19 ya entregada).

---

### **Definition of Done (DoD)**

* [ ] HUD de combate fiel al frame `HU-ESTETICA-19 — Combat HUD` (8 elementos).
* [ ] Player frame, target frame (con élite), skillbar (CD overlay + cuenta), consumable bar (Z/X) y micro menú con estilos del diseño.
* [ ] Target arrow con estilo del diseño sobre el sistema R3.3.
* [ ] Boss bar solo en la pelea del piso 5; level up con estilo del diseño.
* [ ] Fuentes mapeadas, 9-slice, botones 3 estados, iconos registrados.
* [ ] Animaciones TweenService y safe area móvil aplicadas.
* [ ] Sin errores rojos en combate → consumibles → menú → dungeon → rejoin (PC y móvil).
* [ ] Servicios y remotes intactos; anti-exploit vigente.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Al cerrar: PROJECT_ARCHITECTURE, DATA_SCHEMA y registro HU/RC actualizados; nota en GDD después de QA.

---

### **Decisiones por defecto EST-20**

| Tema | Default |
|------|---------|
| Referencia visual | Frame `HU-ESTETICA-19 — Combat HUD` (`.pen`) + specs EST-13 |
| Fidelidad | Lo más cercano posible al frame |
| Fuentes | PlayfairDisplay / Inter / RobotoMono (mapa EST-13) |
| Animaciones | Abrir/cerrar fade+scale 0.15–0.25 s; hover 0.1 s; level up fade/scale breve |
| Lógica | `SkillService`/`TargetingSystem`/`XPService`/`InventoryService`/remotes intactos |

---

### **Estimación (orientativa)**

1–2 sesiones del dev: reskin de los 8 elementos + boss bar/level up (si faltan) + mobile + regresión.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-18 | Creación de HU-ESTETICA-20: implementación del HUD de combate (dev), referenciando el frame `HU-ESTETICA-19 — Combat HUD` del `.pen` (panorama completo en Pencil); player frame, target frame, skillbar, consumable bar, micro menú, target arrow, boss bar y level up — sin tocar la lógica |