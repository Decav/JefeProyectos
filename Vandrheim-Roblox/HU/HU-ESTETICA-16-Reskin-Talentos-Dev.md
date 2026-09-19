# HU-ESTETICA-16: Reskin de la ventana de Talentos en Roblox (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / Implementación (subconjunto de HU-ESTETICA-14)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Implementación de UI en Roblox Studio (dev)
**Fase GDD:** EST (transversal; ventana por ventana)
**Depende de:** HU-ESTETICA-08 (diseño del panel de talentos en Pencil), HU-ESTETICA-13 (paquete de specs/assets), HU-ESTETICA-14 (reskin general — esta HU ejecuta la parte de talentos), HU-R5.1 (TalentUI/TalentService, árbol v2), HU-R5 (respec con oro)
**Componentes observados:** `StarterGui.TalentUI` (ventana actual R5.1), `ServerScriptService.Services.TalentService`, `ReplicatedStorage.Config.TalentConfig` (ramas, nodos, gates, ranks), remotes de talentos/respec existentes

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que la ventana de talentos se vea con el nuevo estilo Hearthbound Gold: árbol de 3 ramas conectadas, nodos con estados, tooltips, contador de puntos y respec,
**para** gastar mis puntos y armar mi spec con una interfaz clara y moderna.

**Como** desarrollador,
**quiero** implementar el reskin de la ventana de talentos usando como referencia el frame del diseño de Pencil y el paquete de `HU-ESTETICA-13`,
**para** reemplazar el estilo actual **sin tocar la lógica** (TalentService, TalentConfig, gates, ranks, respec).

---

### **Descripción del Requerimiento / Contexto**

El diseñador entregó en `Vandrheim-design.pen` el diseño final del panel de talentos: árbol tipo WoW con **3 ramas conectadas**, estados de nodo, pips de rank, tooltip por rank, contador de puntos, leyenda y botón respec, con mockup de contenido real (Paladín Castigo).

El dev implementa el reskin sobre la `TalentUI` existente (R5.1/rc031), conservando la jerarquía y nombres que los scripts usan, y sin cambiar ninguna regla: gates (tier 2 = ≥4 puntos + nivel 8; capstone = ≥8 puntos + nivel 16), ranks (2, capstone 1), 1 punto cada 2 niveles, nodos `Passive`/`Skill`, respec con 100 oro (revoca skills de talento).

**Criterio de hecho global:** la ventana de talentos se ve como el frame del diseño (árbol conectado, estados y tooltips), con la lógica de talentos funcionando intacta, en PC y móvil.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Referencia visual (frame del diseño)**

* **Frame principal:** `v1eO9E` — "HU-ESTETICA-08 — Paladin Castigo Talents" (dentro de `Vandrheim-design.pen`; 1330×820 en el board) — **frame seleccionado por el PM como referencia**.
* Contiene: header (`d8MBmU`), info del personaje/spec (`QRde6`), **área del árbol** con 3 ramas y nodos conectados (`K6VBoU`), leyenda de estados (`azQHQ`), footer/notas (`xsOMl`), indicador de fuente/puntos de talento (`PsKSd`, `i9YE8M`) y variante "sin talentos" (`kFmLC`).
* La pantalla genérica anterior `hiOXb` ("05 Talentos") queda **obsoleta** como referencia; no se usa para implementar.

#### **2. Reskin (sobre la ventana existente)**

* **Header:** título, nombre del PJ, clase, **spec activa**, nivel y **contador de puntos disponibles** (destacado).
* **Árbol:** 3 ramas etiquetadas con **conexiones entre nodos** (líneas/frames rotados entre nodo 1 → 2 → capstone), nodos con **pips de rank** (2; capstone 1).
* **Estados de nodo (todos obligatorios):**
  * Bloqueado (prerequisito/gate no cumplido) — atenuado.
  * Disponible (prerequisitos cumplidos y hay puntos) — borde brillante.
  * Aprendido (1+ rank, mejorable).
  * Máximo rank — lleno.
  * **Nodo skill** diferenciado (icono de skill + indicador de que enseña habilidad).
* **Tooltip por nodo:** nombre, tipo (Pasivo/Skill), efecto **por rank**, requisitos (nodo anterior; ≥4 pts + nivel 8 para tier 2; ≥8 + nivel 16 para capstone) y la skill que enseña si aplica.
* **Leyenda de estados** en la ventana (como el diseño).
* **Respec:** botón con costo (**100 oro**) y **popup de confirmación** con advertencia (devuelve puntos, revoca skills de talento); feedback **"Sin puntos de talento"** cuando aplica.
* **Estilos:** tokens de `HU-ESTETICA-13` (paleta, radios, bordes, espaciados, escala tipográfica); fuentes mapeadas (PlayfairDisplay/Inter/RobotoMono, confirmar `Font` enum); paneles `ImageLabel` con `ScaleType.Slice`; botones `ImageButton` 3 estados; iconos de skills en los nodos skill (subir faltantes al Asset Server + ASSETS_REGISTRY).
* **Mobile:** `UIScale` + `UIAspectRatioConstraint` + zona segura (`GetSafeAreaInsets`); nodos táctiles con tamaño mínimo.
* **Animaciones:** TweenService según EST-13 (abrir/cerrar fade+scale 0.15–0.25 s, hover de nodo 0.1 s, popup de respec con Back corto).

#### **3. Lógica intacta (reglas duras)**

* No se modifican `TalentService`, `TalentConfig` (ramas/nodos/gates/ranks/efectos) ni los remotes de talentos/respec.
* Gates, prerequisitos, ranks, presupuesto de puntos y revocación por respec siguen siendo server-authoritative.
* Se conservan los nombres de instancias y la jerarquía de la `TalentUI` actual que los scripts referencian.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Ventana fiel al diseño**

* **GIVEN** la ventana de talentos implementada
* **WHEN** se compara con el frame `v1eO9E` del diseño
* **THEN** se ven 3 ramas etiquetadas y conectadas, nodos con pips, contador de puntos, leyenda y botón respec
* **AND** el mockup del diseño (Paladín Castigo con puntos gastados) se replica con contenido real del jugador

#### **Escenario 2: Estados de nodo**

* **GIVEN** un PJ con puntos gastados
* **WHEN** se revisan los nodos
* **THEN** bloqueado / disponible / aprendido / máximo y nodo skill se distinguen sin texto
* **AND** los gates (≥4 pts + lvl 8; ≥8 + lvl 16) se reflejan en tooltip y candado visual

#### **Escenario 3: Tooltip y respec**

* **GIVEN** la ventana abierta
* **WHEN** se hace hover en un nodo y se abre el respec
* **THEN** el tooltip muestra efecto por rank y requisitos, y el popup muestra costo (100 oro) y advertencia

#### **Escenario 4: Gastar y respecear**

* **GIVEN** un PJ con puntos disponibles
* **WHEN** gasta puntos y luego hace respec
* **THEN** el contador se actualiza, el árbol refleja los cambios y el respec devuelve puntos y revoca skills de talento (lógica intacta)

#### **Escenario 5: Móvil y regresión**

* **GIVEN** un dispositivo táctil
* **WHEN** se usa la ventana
* **THEN** la ventana escala, respeta la zona segura y los nodos son táctiles
* **AND** gastar puntos → respec → rejoin no produce errores rojos

#### **Escenario 6: Anti-exploit**

* **GIVEN** un cliente intenta gastar puntos de más, saltar gates o respec sin pago
* **WHEN** envía los remotes manipulados
* **THEN** el servidor rechaza (lógica existente intacta)

---

### **Comportamiento Visual / Reglas de Negocio**

* El frame `v1eO9E` del `.pen` es la **referencia visual**; los specs de EST-13 son la **verdad de implementación**.
* Los estados de nodo usan la paleta aprobada (aprendido = latón/pergamino, disponible = borde brillante, bloqueado = atenuado).
* Nodo skill muestra el icono real de la skill que enseña (ASSETS_LIST o placeholder equivalente).
* El respec es solo acceso al flujo existente: no duplica ni reimplementa el árbol.

---

### **Alcance**

#### Incluye

* Reskin de la ventana de talentos sobre la `TalentUI` existente (árbol conectado, estados, pips, tooltips, contador, leyenda, respec).
* Fuentes mapeadas, 9-slice, botones 3 estados, iconos de skills (subida + ASSETS_REGISTRY), animaciones Tween y safe area móvil.
* Ajustes de layout del árbol dentro de la ventana existente (sin rehacerla ni renombrar lo que el código referencia).

#### No incluye

* Lógica de `TalentService`/`TalentConfig`, gates, ranks, presupuesto ni respec (intactos).
* El contenido de talentos (canónico en SKILLS_CATALOG v2.2) ni balance.
* Las demás ventanas del reskin (HUD, mochila, vendors, etc. — HU-ESTETICA-14/15).
* Diseño en Pencil (diseñador — HU-ESTETICA-08 ya entregada).

---

### **Definition of Done (DoD)**

* [ ] Ventana de talentos fiel al frame `v1eO9E` (3 ramas conectadas, estados, pips, tooltips, contador, leyenda, respec).
* [ ] Estados de nodo (bloqueado/disponible/aprendido/máximo + nodo skill) distinguibles sin texto.
* [ ] Tooltip por rank con requisitos (gates 4/8 pts y niveles 8/16) y skill enseñada cuando aplica.
* [ ] Respec con costo real (100) y confirmación con advertencia; feedback "Sin puntos".
* [ ] Fuentes mapeadas, 9-slice, botones 3 estados, iconos registrados.
* [ ] Animaciones TweenService y safe area móvil aplicadas.
* [ ] Sin errores rojos en gastar puntos → respec → rejoin (PC y móvil).
* [ ] `TalentService`/`TalentConfig`/remotes intactos; anti-exploit vigente.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Al cerrar: PROJECT_ARCHITECTURE, DATA_SCHEMA y registro HU/RC actualizados; nota en GDD después de QA.

---

### **Decisiones por defecto EST-16**

| Tema | Default |
|------|---------|
| Referencia visual | Frame `v1eO9E` ("HU-ESTETICA-08 — Paladin Castigo Talents") — seleccionado por el PM |
| Fuentes | PlayfairDisplay / Inter / RobotoMono (mapa EST-13) |
| Animaciones | Abrir/cerrar fade+scale 0.15–0.25 s; hover de nodo 0.1 s; popup respec Back corto |
| Lógica | `TalentService`/`TalentConfig`/remotes intactos |

---

### **Estimación (orientativa)**

1–2 sesiones del dev: reskin de la ventana de talentos + estados/tooltips + mobile + regresión.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-15 | Creación de HU-ESTETICA-16: reskin de la ventana de talentos (dev), referenciando el frame `v1eO9E` del diseño (EST-08) y el paquete EST-13; árbol conectado, estados de nodo, tooltips y respec — sin tocar la lógica |