# HU-ESTETICA-25: Selección y Creación de Personaje — reskin de UI en Pencil ("como se vería en el juego")

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / Pantallas de personaje
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Diseño de UI en Pencil (solo diseñador; **sin desarrollo, sin código**)
**Fase GDD:** EST (transversal; primera impresión del juego)
**Depende de:** HU-ESTETICA-04/06 (sistema Hearthbound Gold), HU-ESTETICA-24 (iconos de clase), HU-R2 (selección/creación reales: 2 slots + 3.º Robux, nombre+clase), HU-ESTETICA-13 (specs/assets)
**No modifica:** lógica del juego, slots, persistencia ni balance

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** ver la selección y creación de personaje tal como se verían implementadas: slots con mi clase/nivel/spec, opciones de clase con sus iconos y creación clara,
**para** que la primera impresión del juego esté a la altura del resto de la UI.

**Como** equipo de desarrollo,
**quiero** un diseño de pantalla completo y a fondo de ambas pantallas,
**para** implementarlas (reskin sobre `CharacterSelect`/`CharacterCreate` de R2) sin reinterpretar nada.

---

### **Descripción del Requerimiento / Contexto**

Las pantallas de selección y creación de PJ (R2) existen pero están **genéricas** (sin diseño a fondo). Esta HU las desarrolla **como se verían en el juego**, con el sistema real:

* **Selección de PJ:** **2 slots gratis** + **3.º desbloqueable con Robux** (GDD §3): cada slot muestra el personaje (clase, spec, nivel, nombre) o el estado vacío/bloqueado; elegir PJ → jugar.
* **Creación de PJ:** **nombre + clase** (Paladín/Cazador/Clérigo con sus specs — R2/ClassConfig); validaciones (nombre válido, slot libre).
* **Iconos de clase** (HU-ESTETICA-24) en ambas pantallas.

**Criterio de hecho global:** existen en el `.pen` las pantallas de selección (con sus 3 estados de slot) y creación (con las 3 clases y sus specs), con mockup real — listas para que el dev haga el reskin sobre R2 sin tocar la lógica.

---

### **Especificaciones Técnicas / Contratos de API (visual)**

#### **1. Pantalla a diseñar: Selección de PJ (frame nuevo en el `.pen`)**

* **Fondo/ambiente:** identidad nórdica (coherente con el pueblo); el frame central con los slots.
* **Header:** título (ej. "Elige tu personaje"), nombre de cuenta y (si aplica) el botón de slot 3.º Robux.
* **Slots (3):**
  * **Ocupado:** icono de clase (EST-24), nombre, **clase + spec**, nivel, y acción "Jugar" (hover/estados).
  * **Vacío:** casilla "Crear personaje" (acción → pantalla de creación).
  * **Bloqueado (3.º):** candado + "Desbloquear con Robux" (estilo GDD §3; sin flujo de compra en esta HU).
* **Estados obligatorios:** slot ocupado (con PJ real), vacío, bloqueado, hover y seleccionado; móvil (layout táctil).

#### **2. Pantalla a diseñar: Creación de PJ (frame nuevo en el `.pen`)**

* **Header:** "Crear personaje" + paso actual (si aplica).
* **Nombre:** campo de texto con validación visual (vacío/inválido → feedback).
* **Clase:** 3 opciones con **icono de clase (EST-24)**, nombre y **las 2 specs** (ej. Paladín: Protector / Castigo) con rol (tanque/dps…); selección con estados.
* **Confirmar/Crear:** botón principal (habilitado solo con nombre válido + clase elegida) y botón volver.
* **Estados obligatorios:** sin clase elegida, clase seleccionada, nombre inválido, confirmación en hover/disabled; móvil.

#### **3. Contenido real del mockup (obligatorio)**

* **Mockup principal (Selección):** cuenta con **slot 1 ocupado** (Paladín Castigo, nivel 16), **slot 2 vacío** ("Crear personaje") y **slot 3 bloqueado** (Robux) — con iconos de clase.
* **Mockup principal (Creación):** clase **Paladín seleccionada** (mostrando Protector/Castigo), nombre ingresado, botón crear habilitado; variantes: **Cazador** (Asalto/Puntería) y **Clérigo** (Misericordia/Cólera) con sus roles.
* **Mockups adicionales (estados):** nombre inválido (feedback), slot bloqueado en hover, móvil.

#### **4. Reglas**

* Trabajar en `Vandrheim-design.pen` en **frames propios de esta HU**; no rehacer las pantallas existentes del `.pen`.
* Paleta/tokens de EST-04/06; tipografías Geist Mono / Playfair Display / Inter; iconos de EST-24.
* Fiel a R2 (2 slots + 3.º Robux, nombre+clase, specs de `ClassConfig`) sin inventar mecánicas.
* El dev implementará sobre `CharacterSelect`/`CharacterCreate` (R2) conservando nombres/jerarquía (regla EST-04).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Selección implementable**

* **GIVEN** la pantalla de selección diseñada
* **WHEN** se mira el mockup
* **THEN** se ven los 3 slots (ocupado con PJ real, vacío "crear", bloqueado Robux) con iconos de clase y acciones claras

#### **Escenario 2: Creación implementable**

* **GIVEN** la pantalla de creación diseñada
* **WHEN** se mira el mockup
* **THEN** se ven nombre, 3 clases con specs (roles) e iconos, y el botón crear con sus estados

#### **Escenario 3: Estados**

* **GIVEN** ambas pantallas
* **WHEN** se revisan los estados
* **THEN** ocupado/vacío/bloqueado, nombre inválido, selección de clase y hover/disabled se distinguen sin texto

#### **Escenario 4: Móvil**

* **GIVEN** las pantallas diseñadas
* **WHEN** se revisa la variante móvil
* **THEN** es usable táctilmente (slots/opciones legibles y accesibles)

#### **Escenario 5: Fiel al sistema**

* **GIVEN** el diseño
* **WHEN** se compara con R2
* **THEN** refleja 2 slots + 3.º Robux, nombre + clase con specs reales, sin inventar mecánicas

---

### **Comportamiento Visual / Reglas de Negocio**

* Es diseño puro: no define lógica, persistencia, compra del slot 3 ni balance.
* Los iconos de clase (EST-24) se usan en slots y opciones.
* La selección/creación respeta las reglas de R2 (slots, nombre, clase).

---

### **Alcance**

#### Incluye

* Selección de PJ (3 slots con estados, acciones, iconos de clase, header) + móvil.
* Creación de PJ (nombre, clases con specs y roles, botón crear con estados, feedback) + móvil.
* Mockups con contenido real (Paladín Castigo lvl 16, slots vacío/bloqueado, clases con specs).

#### No incluye

* Código ni lógica (dev — reskin sobre `CharacterSelect`/`CharacterCreate` de R2 en HU futura o dentro de EST-14).
* Flujo de compra del slot 3.º (Robux).
* Otras pantallas del `.pen` ni la dirección aprobada.

---

### **Definition of Done (DoD)**

* [ ] Selección de PJ completa (3 slots: ocupado/vacío/bloqueado, acciones, iconos de clase) + móvil.
* [ ] Creación de PJ completa (nombre + 3 clases con specs y roles, botón crear con estados) + móvil.
* [ ] Mockups con contenido real (R2: 2 slots + Robux, specs de ClassConfig).
* [ ] Estados distinguibles sin texto; fiel a R2 sin inventar mecánicas.
* [ ] Paleta y componentes de Hearthbound Gold; iconos de EST-24 usados.
* [ ] Reporte al PM con el detalle del diseño y pendientes.

---

### **Estimación (orientativa)**

1–2 sesiones del diseñador: selección + creación + estados + mockups (usa los iconos de EST-24).

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-ESTETICA-25: reskin de Selección y Creación de PJ (3 slots con estados, clases con specs e iconos de EST-24) — solo diseñador, sin desarrollo; el dev implementará sobre R2 |