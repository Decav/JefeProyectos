# HU-ESTETICA-32: Implementación del reskin de Selección y Creación de Personaje (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / Implementación
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Implementación de UI en Roblox Studio (dev) — reskin de las pantallas de personaje
**Fase GDD:** EST (transversal; primera impresión del juego)
**Depende de:** HU-ESTETICA-25 (diseño de Selección/Creación de PJ en Pencil), HU-ESTETICA-24 (iconos de clase), HU-ESTETICA-13 (specs/assets), HU-R2 (CharacterSelect/CharacterCreate, slots, persistencia)
**Componentes observados:** `StarterGui.CharacterSelect` y `StarterGui.CharacterCreate` (R2), `ReplicatedStorage.Config.ClassConfig` (clases/specs), remotes R2

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que la selección y creación de personaje se vean como el diseño de Pencil (slots con clase/spec/nivel, opciones de clase con iconos, creación clara),
**para** que la primera impresión del juego esté a la altura del resto de la UI.

**Como** desarrollador,
**quiero** implementar el reskin de ambas pantallas usando los frames del `.pen` como referencia,
**para** que el juego se vea como lo diseñado, **sin tocar la lógica** (slots, nombre+clase, slot 3.º Robux, persistencia).

---

### **Descripción del Requerimiento / Contexto**

El diseñador entregó el diseño a fondo de ambas pantallas (HU-ESTETICA-25, con los iconos de clase de HU-ESTETICA-24). Esta HU implementa el reskin sobre `CharacterSelect`/`CharacterCreate` (R2), conservando la jerarquía y nombres que los scripts usan (regla EST-04).

**Referencia visual:** frames de `HU-ESTETICA-25` en `Vandrheim-design.pen` (Selección de PJ y Creación de PJ — los 2 frames seleccionados por el PO; **pendiente: nombres/IDs exactos de los frames para referenciarlos** — los pasa el PM cuando reconecte el MCP de Pencil). El dev debe **abrir el `.pen`** para el panorama completo; el resultado debe ser **lo más cercano posible a los frames**.

**Criterio de hecho global:** selección (3 slots: ocupado/vacío/bloqueado) y creación (nombre + 3 clases con specs e iconos) se ven como el diseño, con la lógica R2 funcionando, en PC y móvil.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Selección de PJ (`CharacterSelect`)**

* **3 slots** según el diseño:
  * **Ocupado:** icono de clase (EST-24), nombre, **clase + spec**, nivel, acción "Jugar" (con estados hover/disabled).
  * **Vacío:** casilla "Crear personaje" (→ pantalla de creación).
  * **Bloqueado (3.º):** candado + "Desbloquear con Robux" (sin flujo de compra — como hoy).
* Header/título, fondo coherente con el diseño (identidad nórdica).
* Estados: ocupado/vacío/bloqueado, hover, seleccionado.

#### **2. Creación de PJ (`CharacterCreate`)**

* **Nombre** con validación visual (vacío/inválido → feedback).
* **3 clases** con **icono de clase (EST-24)**, nombre y sus **2 specs** con rol (Protector/Castigo, Asalto/Puntería, Misericordia/Cólera) — estados de selección.
* **Botón Crear** (habilitado solo con nombre válido + clase elegida) y volver.
* Estados: sin clase elegida, clase seleccionada, nombre inválido, hover/disabled.

#### **3. Estilos y assets**

* Tokens de EST-13 (paleta, radios, bordes, espaciados, tipografía); fuentes mapeadas (PlayfairDisplay/Inter/RobotoMono, confirmar `Font` enum).
* Paneles `ImageLabel` con `ScaleType.Slice`; botones `ImageButton` 3 estados; iconos de clase (EST-24) subidos al Asset Server + `ASSETS_REGISTRY`.
* Mobile: `UIScale` + `UIAspectRatioConstraint` + zona segura; selección táctil.
* Animaciones TweenService (abrir/cerrar fade+scale, hover) según EST-13.

#### **4. Lógica intacta (reglas duras)**

* No se modifican: remotes de R2 (lista/crear/seleccionar/borrar), slots (2 + 3.º Robux), persistencia, validación de nombre/clase.
* Se conservan los nombres de instancias y jerarquía que los scripts usan.
* El slot 3.º (Robux) mantiene su comportamiento actual (stub).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Selección fiel al diseño**

* **GIVEN** la pantalla de selección implementada
* **WHEN** se compara con el frame del `.pen` (EST-25)
* **THEN** se ven los 3 slots (ocupado con PJ real, vacío "crear", bloqueado Robux) con iconos de clase y acciones
* **AND** el resultado es lo más cercano posible al diseño

#### **Escenario 2: Creación fiel al diseño**

* **GIVEN** la pantalla de creación implementada
* **WHEN** se compara con el frame del `.pen` (EST-25)
* **THEN** se ven nombre, 3 clases con specs (roles) e iconos, y el botón crear con sus estados

#### **Escenario 3: Flujo R2 intacto**

* **GIVEN** el reskin aplicado
* **WHEN** se crea/elige/borra un personaje
* **THEN** la lógica de R2 funciona igual (slots, persistencia, nombre+clase, slot 3.º)

#### **Escenario 4: Móvil**

* **GIVEN** un dispositivo táctil
* **WHEN** se usan ambas pantallas
* **THEN** escalan, respetan la zona segura y las opciones son táctiles

#### **Escenario 5: Regresión**

* **GIVEN** el reskin completo
* **WHEN** se juega el flujo (selección → creación → jugar → rejoin)
* **THEN** no hay errores rojos y el resto de la UI funciona

---

### **Alcance**

#### Incluye

* Reskin de `CharacterSelect` (3 slots con estados) y `CharacterCreate` (nombre + clases con specs) sobre las GUIs existentes.
* Iconos de clase (EST-24), fuentes, 9-slice, botones 3 estados, mobile y Tween.

#### No incluye

* Lógica de R2 (remotes, slots, persistencia, compra del slot 3.º).
* Diseño en Pencil (EST-25 ya entregada).
* Otras pantallas (cada reskin tiene su HU).

---

### **Definition of Done (DoD)**

* [ ] Selección y creación fieles a los frames del `.pen` (EST-25).
* [ ] Estados cubiertos (ocupado/vacío/bloqueado; nombre inválido; hover/disabled).
* [ ] Iconos de clase enlazados y registrados (ASSETS_REGISTRY).
* [ ] Lógica R2 intacta (slots, persistencia, slot 3.º).
* [ ] Móvil OK (escala, safe area, táctil).
* [ ] Sin errores rojos en selección → creación → jugar → rejoin.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Decisiones por defecto EST-32**

| Tema | Default |
|------|---------|
| Referencia visual | Frames de EST-25 en el `.pen` (IDs pendientes — los pasa el PM) |
| Fuentes | PlayfairDisplay / Inter / RobotoMono (mapa EST-13) |
| Iconos | EST-24 (3 clases) |
| Lógica | R2 intacta (slots, persistencia, slot 3.º Robux) |

---

### **Estimación (orientativa)**

1–2 sesiones del dev: reskin de ambas pantallas + assets + móvil + regresión.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-ESTETICA-32: implementación del reskin de Selección y Creación de PJ (dev) sobre CharacterSelect/CharacterCreate (R2), referenciando el diseño EST-25 + iconos EST-24 — sin tocar la lógica |