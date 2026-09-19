# HU-ESTETICA-17: Reskin del Grimorio (spellbook) en Roblox (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / Implementación (subconjunto de HU-ESTETICA-14)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Implementación de UI en Roblox Studio (dev)
**Fase GDD:** EST (transversal; ventana por ventana)
**Depende de:** HU-ESTETICA-09 (diseño del grimorio en Pencil), HU-ESTETICA-13 (paquete de specs/assets), HU-ESTETICA-14 (reskin general — esta HU ejecuta la parte del grimorio), HU-R5.1 (ventana de habilidades/spellbook), HU-R3 (barra de 4 slots/loadout)
**Componentes observados:** `StarterGui.SpellbookUI` (ventana de habilidades actual R5.1), `ReplicatedStorage.Config.SkillConfig` (skills data-driven), remotes de loadout/skills existentes, cliente del spellbook

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que el grimorio se vea con el nuevo estilo Hearthbound Gold: mis habilidades aprendidas con tipo, maná, cooldown y origen, estados claros, y la vista previa de la barra para armar mi loadout,
**para** saber qué tengo, qué me falta y elegir mis 4 skills de combate sin confusión.

**Como** desarrollador,
**quiero** implementar el reskin del grimorio usando como referencia el frame del diseño de Pencil y el paquete de `HU-ESTETICA-13`,
**para** reemplazar el estilo actual **sin tocar la lógica** (SkillConfig, loadout, asignación/desasignación).

---

### **Descripción del Requerimiento / Contexto**

El diseñador entregó en `Vandrheim-design.pen` el diseño final del grimorio: lista/grid de skills aprendidas con **tipo, maná, CD y origen**, estados (asignada / no asignada / bloqueada), **vista previa de la barra de 4 slots** con teclas y tooltips, con mockup de contenido real (Paladín Castigo).

El dev implementa el reskin sobre la `SpellbookUI` existente (R5.1), conservando la jerarquía y nombres que los scripts usan, y sin cambiar ninguna regla: muestra **todas las skills aprendidas** (2 básicas + 2 por nivel de spec + 2 por talento), la asignación a los **4 slots de la barra** (loadout, R3), y las skills de talento que el respec **revoca** (R5.1).

**Criterio de hecho global:** el grimorio se ve como el frame del diseño (skills con estados y vista previa de la barra), con la lógica de skills/loadout funcionando intacta, en PC y móvil.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Referencia visual (frame del diseño)**

* **Frame principal:** `NXCBS` — "HU-ESTETICA-09 — Paladin Castigo Spellbook" (dentro de `Vandrheim-design.pen`; 1330×890 en el board).
* Contiene: la lista/grid de skills del mockup (6 skills reales de Paladín Castigo), los **estados de skill** (`jz2uv`), la **vista previa del loadout** (`wyTMT`) con 4 slots (`m5WY4Y`/`oV2Ls`/`q75ig`/`mKT7b` — cada uno con tecla, icono, nombre y datos), tooltips y empty states.
* Las pantallas genéricas anteriores `a9Yf1u` ("Spellbook window") y `MDzs3` ("04 Spellbook") quedan **obsoletas** como referencia.

#### **2. Reskin (sobre la ventana existente)**

* **Header:** título, nombre del PJ, clase, **spec activa** y nivel.
* **Lista/grid de skills:** cada skill con **icono real**, nombre, tipo (Instant / AoE zona / Explosión / Cura / Escudo), maná, CD y **origen** ("Nivel 1", "Nivel 5", "Talento: <rama>").
* **Estados de skill (todos obligatorios):**
  * Aprendida y **asignada a la barra** — marcada.
  * Aprendida y **no asignada** — disponible para asignar.
  * **Bloqueada** (no aprendida) — atenuada, con su forma de obtención (ej. "Talento: <rama>" u "Otra spec").
* **Vista previa del loadout:** 4 slots siempre visibles con **tecla (1–4)**, icono, nombre y coste/CD; slots ocupado/vacío; representación de la asignación (click/drag hacia el slot, con origen y destino señalados).
* **Tooltip de skill:** nombre, tipo, coste, CD, rango/radio (si aplica), descripción breve y origen.
* **Empty states:** barra con slots vacíos (PJ nivel 1 con solo básicas) y "no hay más skills por aprender".
* **Estilos:** tokens de `HU-ESTETICA-13` (paleta, radios, bordes, espaciados, escala tipográfica); fuentes mapeadas (PlayfairDisplay/Inter/RobotoMono, confirmar `Font` enum); paneles `ImageLabel` con `ScaleType.Slice`; casillas/botones `ImageButton` 3 estados; iconos de skills (subir faltantes al Asset Server + ASSETS_REGISTRY, estándar ASSETS_LIST).
* **Mobile:** `UIScale` + `UIAspectRatioConstraint` + zona segura (`GetSafeAreaInsets`); skills y slots táctiles con tamaño mínimo.
* **Animaciones:** TweenService según EST-13 (abrir/cerrar fade+scale 0.15–0.25 s, hover 0.1 s, resaltado de destino al asignar).

#### **3. Lógica intacta (reglas duras)**

* No se modifican `SkillConfig`, el loadout (R3), ni los remotes de skills/asignación.
* La lista de aprendidas sale del profile (básicas + nivel + talento); la revocación por respec sigue siendo server-side.
* Se conservan los nombres de instancias y la jerarquía de la `SpellbookUI` actual que los scripts referencian.
* La asignación se representa con el flujo existente (click/remoto actual); **no** se reimplementa drag & drop si el flujo actual es por click.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Ventana fiel al diseño**

* **GIVEN** el grimorio implementado
* **WHEN** se compara con el frame `NXCBS` del diseño
* **THEN** se ven las skills reales del jugador con icono, tipo, maná, CD y origen, y la vista previa del loadout con teclas
* **AND** el mockup del diseño (Paladín Castigo) se replica con contenido real

#### **Escenario 2: Estados de skill**

* **GIVEN** un PJ con skills aprendidas
* **WHEN** se revisan las skills
* **THEN** asignada / no asignada / bloqueada se distinguen sin texto
* **AND** las bloqueadas muestran cómo se obtienen

#### **Escenario 3: Asignar a la barra**

* **GIVEN** una skill no asignada
* **WHEN** se asigna a un slot del loadout
* **THEN** el destino se señala, la skill queda marcada como asignada y la barra refleja el cambio
* **AND** desasignar libera el slot y desmarca la skill

#### **Escenario 4: Tooltip y empty states**

* **GIVEN** la ventana abierta
* **WHEN** se hace hover en una skill y se revisan los empty states
* **THEN** el tooltip muestra tipo/coste/CD/rango/origen, y la barra vacía (PJ nuevo) se ve clara

#### **Escenario 5: Móvil y regresión**

* **GIVEN** un dispositivo táctil
* **WHEN** se usa el grimorio
* **THEN** la ventana escala, respeta la zona segura y las skills/slots son táctiles
* **AND** asignar/desasignar → combatir → rejoin no produce errores rojos

#### **Escenario 6: Anti-exploit**

* **GIVEN** un cliente intenta asignar skills no aprendidas o fuera de la barra
* **WHEN** envía los remotes manipulados
* **THEN** el servidor rechaza (lógica existente intacta)

---

### **Comportamiento Visual / Reglas de Negocio**

* El frame `NXCBS` del `.pen` es la **referencia visual**; los specs de EST-13 son la **verdad de implementación**.
* Los tipos de skill se distinguen visualmente (etiqueta/color: Instant, Zona, Explosión, Cura, Escudo).
* El estado "asignada" se lee de un vistazo y la barra está siempre visible en la ventana.
* Los iconos siguen el estándar ASSETS_LIST (fondo negro = finales) o placeholder equivalente.

---

### **Alcance**

#### Incluye

* Reskin del grimorio sobre la `SpellbookUI` existente (lista/grid con estados, vista previa del loadout 4 slots, tooltips, empty states).
* Fuentes mapeadas, 9-slice, casillas/botones 3 estados, iconos de skills (subida + ASSETS_REGISTRY), animaciones Tween y safe area móvil.
* Ajustes de layout dentro de la ventana existente (sin rehacerla ni renombrar lo que el código referencia).

#### No incluye

* Lógica de `SkillConfig`, loadout, remotes ni balance (intactos).
* El contenido de skills (canónico en SKILLS_CATALOG v2.2).
* Las demás ventanas del reskin (HUD, mochila, vendors, talentos, etc. — HU-ESTETICA-14/15/16).
* Diseño en Pencil (diseñador — HU-ESTETICA-09 ya entregada).

---

### **Definition of Done (DoD)**

* [ ] Grimorio fiel al frame `NXCBS` (skills con icono/tipo/maná/CD/origen, estados y loadout).
* [ ] Estados de skill (asignada/no asignada/bloqueada) distinguibles sin texto.
* [ ] Vista previa del loadout con teclas 1–4, slots ocupado/vacío y asignación señalada.
* [ ] Tooltip con tipo/coste/CD/rango/origen; empty states cubiertos.
* [ ] Fuentes mapeadas, 9-slice, casillas/botones 3 estados, iconos registrados.
* [ ] Animaciones TweenService y safe area móvil aplicadas.
* [ ] Sin errores rojos en asignar/desasignar → combatir → rejoin (PC y móvil).
* [ ] `SkillConfig`/loadout/remotes intactos; anti-exploit vigente.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Al cerrar: PROJECT_ARCHITECTURE, DATA_SCHEMA y registro HU/RC actualizados; nota en GDD después de QA.

---

### **Decisiones por defecto EST-17**

| Tema | Default |
|------|---------|
| Referencia visual | Frame `NXCBS` ("HU-ESTETICA-09 — Paladin Castigo Spellbook") |
| Fuentes | PlayfairDisplay / Inter / RobotoMono (mapa EST-13) |
| Asignación | Flujo existente (click/remoto); sin drag & drop nuevo |
| Animaciones | Abrir/cerrar fade+scale 0.15–0.25 s; hover 0.1 s |
| Lógica | `SkillConfig`/loadout/remotes intactos |

---

### **Estimación (orientativa)**

1–2 sesiones del dev: reskin del grimorio + estados/loadout + mobile + regresión.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-15 | Creación de HU-ESTETICA-17: reskin del grimorio (dev), referenciando el frame `NXCBS` del diseño (EST-09) y el paquete EST-13; estados de skill, vista previa del loadout y tooltips — sin tocar la lógica |