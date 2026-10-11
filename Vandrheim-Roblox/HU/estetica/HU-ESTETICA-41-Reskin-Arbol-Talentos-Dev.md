# HU-ESTETICA-41: Reskin del Árbol de Talentos — estilo WoW + panel de información del nodo (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / Talentos — Reskin (dev)
**Prioridad:** Alta
**Estado:** Lista para implementar (RC obligatorio del dev antes de programar)
**Tipo:** Reskin de UI (dev) — solo visual, sin tocar lógica
**Fase GDD:** UI (sustituye el visual de EST-16)
**Depende de:** **HU-ESTETICA-16 (reskin a superar — el frame nuevo lo reemplaza)**, frame del `.pen`: **`Xff5t` — "D · WoW-inspired talent tree"** (aprobado por PO; incluye el panel de información del nodo), HU-ESTETICA-13 (tokens/handoff), HU-ESTETICA-40 (iconos `Icon_Talent_*` para nodos), HU-R6.27 (fuentes legibles + TooltipSystem), HU-R5 (talentos/lógica)
**No modifica:** puntos, gates, respec, datos de nodos ni lógica (R5/TalentConfig intactos)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** el árbol de talentos rediseñado (estilo WoW con nodos por rama, gates y **panel de información del nodo seleccionado**),
**para** que entender y gastar puntos sea claro y se sienta parte del juego.

---

### **Descripción del Requerimiento / Contexto**

El diseñador entregó el árbol estilo WoW (frame `Xff5t`) — **aprobado por el PO**. El dev reskinea la UI de talentos (EST-16 actual) sobre ese diseño, **conservando nombres de instancias y lógica** (contrato de EST-13).

**Criterio de hecho global:** el panel de talentos se ve como el frame `Xff5t` (header, puntos, tabs de spec, 3 ramas con nodos/conexiones/gates/candados, panel de info del nodo seleccionado, cierre) — con los estados visuales correctos y sin romper la lógica ni el respec.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Áreas a reskinear (referencia: frame `Xff5t`)**

1. **Header**: título "TALENTOS · PALADÍN", línea de personaje/nivel/puntos, **badge de puntos disponibles** (dorado, icono + "1 PUNTO DISPONIBLE" — datos reales de R5).
2. **Tabs de spec**: Protector / **Castigo · ACTIVA** (tab activo dorado con texto oscuro `#15100D`; inactivo `#3A302A`).
3. **3 ramas** (Ataque · Fuego · Vigor): títulos con acento dorado, **conexiones** entre tiers (`#6B4A2B`, bloqueadas `#52495D`), **tier gates** ("≥4 PTS · NIVEL 8" azul `#8FB7D6`; bloqueado gris) y **cap gates** ("≥8 PTS · NIVEL 16").
4. **Nodos (28×28 en diseño, escalar a ~40 para legibilidad — ver R6.27)**: marco por estado — disponible `#3A2C25`, seleccionado/activo `#203340`, bloqueado `#171311`; icono `Icon_Talent_*` (EST-40; hasta que existan: icono genérico `#F4EDE0`/gris si bloqueado); **candado** en bloqueados; rango con pips (dorado/azul/morado por rama; vacío `#3A302A`).
5. **Nodo seleccionado**: subtítulo bajo el nombre con **efecto real** ("PASIVA · +4% ATK / RANGO", "HABILIDAD · REQUIERE TIER 3", "CAPSTONE …") — datos del TalentConfig.
6. **Panel de información del nodo** (derecha o lateral): encabezado de rama, conectores y **gates por tier**, **tarjetas de talento** (nombre + efecto + RANK con pips + icono circular), estados bloqueados con candado y **botón de cerrar** (`#3A2525` + icono pergamino).
7. **Nota del árbol** ("SELECCIONADO · Fervor: +4%…" — texto real del nodo).

#### **2. Reglas**

* **Conservar los nombres de instancias/jerarquía que los scripts usan** (contrato EST-13: cambiar visuales sin romper lógica).
* **REPLICA SOLO EL FRAME `Xff5t` (regla de oro):** se implementa ÚNICAMENTE lo que muestra el frame aprobado. **NO** se añaden elementos del diseño viejo (EST-08/EST-16): **sin leyenda de estados** (APRENDIDO/DISPONIBLE/BLOQUEADO), **sin popup de respec**, sin paneles ni extras que no estén dibujados en `Xff5t`. El **panel lateral de información ES el sub-frame "Talent tree · node info organized" del propio diseño** (rama, gates de tier, tarjetas con RANK/pips, icono circular, bloqueados con candado, botón de cerrar) — nada más.
* Mismo contrato de apertura/cierre, tecla y flujo de puntos que EST-16 (nada nuevo en lógica).
* **RESPEC NO SE MANEJA DESDE EL ÁRBOL (decisión PO 2026-09-22):** el respec con oro vive en el **Instructor/entrenador del pueblo** (EST-12/15 — "REENTRENAR · 100 ORO"); el árbol de talentos **solo gasta puntos** (no lleva botón ni flujo de respec).
* Estados visuales = **datos reales** (puntos, gates por nivel, aprendido/bloqueado) — el servidor sigue siendo la fuente (R5).
* Fuentes legibles (R6.27): títulos ≥9, nombres ≥9, detalles ≥7 en escala real; adaptar el frame desde el `.pen` (30 % de escala del diseño) a una UI móvil-safe (máx 85 % viewport).
* El **TooltipSystem** (R6.27 §6) es el destino del panel de info (plantilla `talento`) — el panel del frame se usa como referencia visual del tooltip/pantalla de detalle.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Reskin fiel**

* **GIVEN** el panel de talentos reskineado
* **WHEN** se compara con el frame `Xff5t`
* **THEN** replica header, puntos, tabs, 3 ramas, gates, nodos con estados y panel de info (colores/fuentes del diseño)

#### **Escenario 2: Estados reales**

* **GIVEN** un árbol con nodos aprendidos/disponibles/bloqueados
* **WHEN** se revisa
* **THEN** cada nodo muestra su estado correcto (colores, candados, pips de rango) según los datos del servidor

#### **Escenario 3: Nodo seleccionado**

* **GIVEN** un nodo con datos (pasiva/skill/capstone)
* **WHEN** se selecciona
* **THEN** se abre el panel de información con rama, gates, tarjetas, ranks y cierre — y el subtítulo del nodo muestra su efecto real

#### **Escenario 4: Lógica intacta**

* **GIVEN** el reskin aplicado
* **WHEN** se gastan puntos y se cumplen gates
* **THEN** todo funciona igual que antes (R5 sin cambios; sin errores rojos)
* **AND** el árbol **no ofrece respec** (ese flujo vive en el Instructor del pueblo — EST-12/15)

#### **Escenario 5: Móvil**

* **GIVEN** el panel en móvil
* **WHEN** se revisa
* **THEN** se adapta (escale/touch) sin romper y con fuentes legibles (R6.27)

---

### **Alcance**

#### Incluye

* Reskin completo del árbol de talentos según `Xff5t` (7 áreas) + panel de información del nodo.

#### No incluye

* Lógica, gates nuevos ni balance (R5 intactos); **respec (vive en el Instructor del pueblo — EST-12/15)**; ni los iconos `Icon_Talent_*` (los produce EST-40, el dev los enlaza cuando existan).

---

### **Definition of Done (DoD)**

* [ ] Panel de talentos replica el frame `Xff5t` (header/tabs/ramas/gates/nodos/panel de info/cierre).
* [ ] Estados y efectos del nodo con datos reales del servidor.
* [ ] Nombres de instancias conservados; lógica/respec intactos (sin errores rojos).
* [ ] Móvil OK y fuentes legibles (R6.27).
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Estimación (orientativa)**

2 sesiones del dev: reskin del árbol + panel de info + estados.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-ESTETICA-41: reskin del árbol de talentos estilo WoW (frame `Xff5t` aprobado) — header, puntos, tabs de spec, 3 ramas con gates/candados/pips, **panel de información del nodo** y subtítulos con efecto real; sustituye el visual de EST-16; iconos `Icon_Talent_*` (EST-40) cuando existan |
| 2026-09-22 | **Corrección PO:** **el respec NO se maneja desde el árbol de talentos** — solo gasta puntos; el respec con oro vive en el **Instructor del pueblo** (EST-12/15, REENTRENAR · 100 ORO). Actualizados reglas/escenarios/alcance |
| 2026-09-22 | **Regla de oro añadida (dev intentaba replicar el diseño viejo EST-08):** se implementa **SOLO lo del frame `Xff5t`** — sin leyenda de estados (APRENDIDO/DISPONIBLE/BLOQUEADO), sin popup de respec ni extras del design viejo; el panel lateral ES el sub-frame **"Talent tree · node info organized"** del propio diseño aprobado (rama, gates, tarjetas, RANK, cerrar) |