# HU-R6.20: Escalado de frames en el modo Ordenar UI + incorporación del party frame

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** UI / R6.11 (extensión del sistema de orden de UI)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Mejora de UI configurable (dev)
**Fase GDD:** R6.20 (extiende HU-R6.11; no cambia reglas de juego)
**Depende de:** HU-R6.11 (modo edición con cuadrícula, mover frames, persistencia por personaje), HU-R9a (party), HU-ESTETICA-22 (party frames), HU-ESTETICA-13 (specs)
**Componentes observados:** `EditLayoutUI` (modo edición de R6.11), frames del HUD (player, target, skillbar, consumibles, micro menú), **party frame** (R9a/EST-22), `profile.uiLayout`

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** poder **escalar los frames del HUD** (más grandes o más pequeños) desde el modo Ordenar UI, escalando **todo el frame de forma uniforme desde una esquina**,
**para** adaptar la UI a mi pantalla sin que se rompa.

**Como** jugador en party,
**quiero** que el **party frame** (con la vida de mis aliados) también sea **visible, movible y escalable** con el mismo sistema,
**para** acomodar la información del grupo junto al resto de la UI.

---

### **Descripción del Requerimiento / Contexto**

El sistema de Ordenar UI (R6.11) permite **mover** los frames del HUD y persiste por personaje (`profile.uiLayout`). Esta HU lo extiende:

1. **Escalado uniforme:** cada frame editable gana un **handle de esquina** (inferior-derecha) — arrastrándolo se escala **todo el frame proporcionalmente** (nunca solo horizontal o vertical).
2. **Party frame incluido:** el frame del party (HP de aliados, EST-22/R9a) entra al sistema editable (mover + escalar + persistir); y se corrige su visibilidad (hoy no se ve cuando debería).

**Criterio de hecho global:** desde Ordenar UI, el jugador mueve y escala (uniforme, por esquina) todos los frames editables **incluido el party frame**; el escalado no rompe el layout interno; todo persiste por personaje; la UI nunca queda ilegible.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Escalado uniforme (handle de esquina)**

* En modo edición, cada frame editable muestra un **handle en la esquina inferior-derecha** (icono de esquina, estilo del sistema).
* Arrastrar el handle **escala todo el frame con un factor uniforme** (el mismo factor en X e Y) — **prohibido** escalar solo horizontal o vertical (mantiene proporción → no se rompe la UI).
* **Implementación:** aplicar el factor como **`UIScale`** (o escalar el `Size` del frame raíz con el mismo factor en ambos ejes) sobre el frame raíz del elemento; los hijos (barras, textos, iconos) se escalan juntos sin alterar su layout interno (se conserva `UIAspectRatioConstraint`).
* **Límites:** escala mínima y máxima (decisión PM: **0.6× a 2.0×**) para mantener legibilidad; el frame escalado sigue dentro de la pantalla (clamp con zona segura).

#### **2. Party frame editable y visible**

* El **party frame** (R9a/EST-22) se agrega a la lista de elementos editables (player frame, target frame, skillbar, consumable bar, micro menú + **party frame**).
* **Visibilidad:** se muestra solo cuando hay party (como diseño); se corrige que hoy no sea visible cuando debería. En el modo edición es editable igual que los demás.

#### **3. Persistencia (por personaje)**

* `profile.uiLayout` pasa a guardar **`{ x, y, scale }`** por elemento (el `scale` opcional, default 1.0).
* Server valida: posiciones normalizadas (0–1) y **scale dentro de [0.6, 2.0]** (anti-exploit); descarta lo inválido.
* Se aplica al spawnear (posición + escala) con el flujo de R6.11.
* **Reset (recomendado):** botón "Restaurar" en el modo edición que devuelve posiciones/escalas al default.

#### **4. No romper**

* El escalado no cambia la lógica (los scripts siguen referenciando las mismas instancias; solo cambia su visual).
* Mobile: el modo edición con escala funciona por touch (handle táctil con tamaño mínimo).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Escalar desde la esquina**

* **GIVEN** el modo edición activo
* **WHEN** se arrastra el handle de la esquina de un frame
* **THEN** el frame se escala **uniformemente** (X e Y juntos) y el layout interno no se rompe

#### **Escenario 2: Límites**

* **GIVEN** el escalado
* **WHEN** se intenta escalar más allá de los límites
* **THEN** el frame queda dentro de [0.6×, 2.0×] y dentro de la pantalla

#### **Escenario 3: Party frame**

* **GIVEN** un jugador en party
* **WHEN** entra al modo edición
* **THEN** el party frame es visible, movible y escalable como los demás
* **AND** sin party, no se muestra (como el diseño)

#### **Escenario 4: Persistencia**

* **GIVEN** un layout guardado con escala
* **WHEN** el jugador reentra (mismo PJ)
* **THEN** posición y escala se aplican
* **AND** otro personaje tiene el suyo (independiente)

#### **Escenario 5: Anti-exploit**

* **GIVEN** un cliente envía un layout con scale inválido
* **WHEN** llama el remote de guardado
* **THEN** el server descarta lo inválido (scale fuera de rango) y no corrompe el perfil

#### **Escenario 6: Regresión**

* **GIVEN** el sistema extendido
* **WHEN** se juega el flujo completo (mover/escalar → guardar → combatir → dungeon → rejoin)
* **THEN** no hay errores rojos y la UI funciona igual (PC y móvil)

---

### **Alcance**

#### Incluye

* Handle de esquina para escalado uniforme (0.6×–2.0×, clamp de pantalla).
* Party frame visible, movible y escalable en el modo edición.
* Persistencia de `scale` en `profile.uiLayout` (validada) + botón "Restaurar" (recomendado).

#### No incluye

* Escalado no uniforme (horizontal/vertical separados).
* Cambios a la lógica de los elementos ni a otros sistemas.
* El diseño del party frame (EST-22 ya lo cubre).

---

### **Definition of Done (DoD)**

* [ ] Escalado uniforme por handle de esquina en todos los frames editables (sin romper layout interno).
* [ ] Límites [0.6×, 2.0×] y clamp de pantalla.
* [ ] Party frame visible/editable con el sistema (mover + escalar + persistir).
* [ ] `scale` persistido por personaje y validado en server.
* [ ] Botón "Restaurar" (recomendado) funcionando.
* [ ] Funciona por touch; sin errores rojos en el flujo completo.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Decisiones por defecto R6.20**

| Tema | Default |
|------|---------|
| Escalado | **Uniforme** (mismo factor X/Y), handle en esquina inferior-derecha |
| Implementación | `UIScale`/Size uniforme sobre el frame raíz (hijos escalan juntos) |
| Límites | 0.6× – 2.0× |
| Elementos editables | Player, target, skillbar, consumables, micro menú + **party frame** |
| Persistencia | `{ x, y, scale }` por personaje, server-validado |

---

### **Estimación (orientativa)**

1–2 sesiones del dev: handle de escala + party frame editable + persistencia + regresión.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-R6.20: escalado uniforme (por esquina) en el modo Ordenar UI + incorporación del party frame (visible/movible/escalable) + persistencia de `scale` por personaje |