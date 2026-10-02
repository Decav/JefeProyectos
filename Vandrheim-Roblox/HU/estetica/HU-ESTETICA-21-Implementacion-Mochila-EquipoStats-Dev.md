# HU-ESTETICA-21: Rediseño de Mochila (B) y Equipo + Stats (C) en Roblox (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / Implementación (subconjunto de HU-ESTETICA-14)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Implementación de UI en Roblox Studio (dev)
**Fase GDD:** EST (transversal; ventana por ventana)
**Depende de:** HU-ESTETICA-10 (diseño de Equipo+Stats), HU-ESTETICA-11 (diseño de Mochila), HU-ESTETICA-13 (paquete de specs/assets), HU-ESTETICA-14 (reskin general), HU-R6.5 (InventoryUI/EquipmentUI actuales), HU-R5.2 (stacking/venta 1 unidad), HU-R6.2 (slots Z/X), HU-R4 (tooltips/BoE/rolls), HU-ITEMS-01 (ítems nuevos)
**Componentes observados:** `StarterGui.InventoryUI` (mochila R6.5), `StarterGui.EquipmentUI` (equipo/stats rc022), `StarterPlayer.StarterPlayerScripts.InventoryClient`, `ServerScriptService.Services.InventoryService` (RecalculateStats), `ReplicatedStorage.Config` (ItemConfig, ItemRarity)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que la mochila y la ventana de equipo/estadísticas se vean como el diseño de Pencil: 20 casillas con pilas y rarezas, tooltips con acciones, y el equipo activo junto a mis stats con desglose,
**para** gestionar mi inventario y entender mi personaje de un vistazo con la estética Hearthbound Gold.

**Como** desarrollador,
**quiero** implementar el rediseño de ambas ventanas usando como referencia los frames del `.pen` (mirando el diseño completo para el panorama de cómo debe quedar la UI),
**para** que el juego se vea como lo diseñado, **sin tocar la lógica** (inventario, stacking, equip, stats).

---

### **Descripción del Requerimiento / Contexto**

El diseñador entregó en `Vandrheim-design.pen` los diseños a fondo de la **Mochila (HU-ESTETICA-11)** y de la **Ventana de Equipo + Stats (HU-ESTETICA-10)**. Esta HU implementa ambos rediseños en Roblox sobre las ventanas existentes (R6.5/rc022), conservando la jerarquía y nombres que los scripts usan.

**Importante:** el dev debe **abrir `Vandrheim-design.pen`** y revisar los frames de `HU-ESTETICA-10 — Equipo+Stats` y `HU-ESTETICA-11 — Mochila` (junto al sistema de EST-04/06 y las specs de EST-13) para ver **el panorama completo de cómo debe quedar la UI**. El resultado debe ser **lo más cercano posible a los frames**.

**Criterio de hecho global:** la mochila y la ventana de equipo/stats se ven como el diseño (pilas/rarezas/tooltips; equipo activo + stats con desglose bajo demanda), con la lógica existente funcionando, en PC y móvil.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Referencia visual**

* Frames del `.pen`: `HU-ESTETICA-10 — Equipo+Stats` (dos columnas, desglose bajo demanda, resaltado slot↔stat) y `HU-ESTETICA-11 — Mochila` (20 slots con pilas, rarezas, tooltip con acciones, marcado Z/X, estados vacía/llena).
* Ver también los mockups de tooltip ya existentes en el `.pen` (tooltip de ítem con stats/afijos/levelReq/BoE y acciones).
* Las pantallas viejas ("02 Mochila" / "03 Equipo" genéricas) se actualizan al nuevo diseño.

#### **2. Mochila (B) — sobre `InventoryUI` (R6.5)**

* **Grid de 20 casillas** con: casilla vacía, ocupada (icono real + **cantidad `xN`** + **marco de rareza**), pila máxima (pociones x20), y **marcado del ítem asignado a Z/X** (esquina "Z"/"X").
* **Tooltip de ítem** (hover): nombre, rareza, stats/afijos, `levelReq`, BoE y **acciones** (Usar / Equipar / **Vender 1 unidad** con precio) — patrón R4/tooltip del `.pen`.
* **Estados obligatorios:** mochila con mezcla de pilas, **vacía** y **llena** (20/20) sin romper layout.
* **Lógica intacta:** 20 slots = 20 pilas (R5.2), maxStack, uso/venta de 1 unidad, BoE al equipar; `InventoryService` y remotes sin cambios.

#### **3. Equipo + Stats (C) — sobre `EquipmentUI` (rc022)**

* **Dos columnas** (tamaño de referencia ~480×320; **máximo ~85% de pantalla en móvil**):
  * **Columna izquierda — Equipo:** 9 slots (casco, pecho, hombreras, piernas, guantes, collar, anillo, mano derecha e izquierda) con etiquetas, **equipo activo puesto** (icono + marco de rareza) y vacío visible.
  * **Columna derecha — Stats (compactas):** Recursos (HP/MP), Ataque (ATK/MATK/CRIT), Defensa (DEF/MDEF) — filas **icono + nombre + valor total** (sin desglose permanente).
* **Desglose bajo demanda:** al expandir/hover una fila (o tooltip), muestra **Base + ítems puestos + Talentos** citando el equipo (ej. "ATK 112 = 85 + **Espada del campeón** +17 + **Fervor** +10").
* **Resaltado slot↔stat:** al seleccionar/hover un slot, la fila de la stat que aporta se ilumina.
* **Header:** identidad (nombre, clase, spec, nivel) + **barra de XP** ("actual / próximo").
* **Punto de ingeniería (acotado):** el desglose por fuente **no existe hoy** (RecalculateStats devuelve totales; el cliente lee atributos). Implementar una de estas opciones (decisión del dev con PM):
  * a) Extender `RecalculateStats` para devolver también el breakdown `{ base, equipo, talentos }` por stat (sin cambiar el cálculo final), expuesto al cliente por un remote pequeño o campo nuevo en el payload existente.
  * b) Calcular el breakdown en cliente a partir de configs replicados + profile (sin remote nuevo).
  * Recomendado: **(a)** server-side (única fuente de verdad; sin duplicar fórmulas en cliente).

#### **4. Estilos y assets (ambas ventanas)**

* Tokens de `HU-ESTETICA-13` (paleta, radios, bordes, espaciados, escala tipográfica); fuentes mapeadas (PlayfairDisplay/Inter/RobotoMono, confirmar `Font` enum).
* Paneles `ImageLabel` con `ScaleType.Slice`; casillas/botones `ImageButton` 3 estados; barras con fondo + fill separados.
* Iconos de ítems según ASSETS_LIST (fondo negro = finales); subir faltantes al Asset Server + `ASSETS_REGISTRY`.
* Animaciones TweenService según EST-13 (abrir/cerrar fade+scale 0.15–0.25 s, hover 0.1 s, expandir desglose con fade breve).
* Mobile: `UIScale` + `UIAspectRatioConstraint` + zona segura (`GetSafeAreaInsets`); casillas táctiles con tamaño mínimo.

#### **5. Lógica intacta (reglas duras)**

* No se modifican: `InventoryService` (excepto la extensión opcional del breakdown), remotes de inventario/equip, `ItemConfig`/`ItemRarity` (solo `iconId`/`visualModelId` nuevos si aplica).
* Equip, desequip, BoE, rolls, stacking, uso/venta y RecalculateStats final funcionan igual.
* Se conservan los nombres de instancias y la jerarquía de `InventoryUI`/`EquipmentUI` que los scripts referencian.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Mochila fiel al frame**

* **GIVEN** la mochila implementada
* **WHEN** se compara con el frame `HU-ESTETICA-11 — Mochila` del `.pen`
* **THEN** se ven 20 casillas con pilas `xN`, marcos de rareza, estados vacío/ocupado/lleno y el marcado Z/X
* **AND** el contenido refleja ítems reales del jugador

#### **Escenario 2: Tooltip y acciones de la mochila**

* **GIVEN** una casilla con ítem
* **WHEN** se abre el tooltip
* **THEN** muestra nombre, rareza, stats/afijos, levelReq, BoE y acciones (Usar/Equipar/Vender 1 unidad con precio)

#### **Escenario 3: Equipo+Stats fiel al frame**

* **GIVEN** la ventana de equipo implementada
* **WHEN** se compara con el frame `HU-ESTETICA-10 — Equipo+Stats` del `.pen`
* **THEN** se ven dos columnas: 9 slots con el equipo activo y stats compactas (icono+nombre+valor) con header + XP

#### **Escenario 4: Desglose bajo demanda**

* **GIVEN** una build con clase + equipo + talentos
* **WHEN** se expande/hace hover sobre una fila de stat
* **THEN** se ve el desglose Base + ítems + Talentos citando el equipo puesto
* **AND** las filas en reposo se mantienen compactas

#### **Escenario 5: Resaltado slot↔stat**

* **GIVEN** un slot seleccionado (ej. la espada)
* **WHEN** se revisa la columna de stats
* **THEN** la fila de la stat que aporta se resalta
* **AND** deseleccionar restaura el estado normal

#### **Escenario 6: Móvil y regresión**

* **GIVEN** un dispositivo táctil
* **WHEN** se usan ambas ventanas
* **THEN** escalan (UIScale + aspect ratio), respetan la zona segura y son táctiles
* **AND** el flujo completo (mochila → equipar → stats → combatir → respawn → rejoin) no produce errores rojos

#### **Escenario 7: Anti-rotura de lógica**

* **GIVEN** ambas ventanas implementadas
* **WHEN** se envían remotes de inventario/equip manipulados
* **THEN** el servidor sigue rechazando (validaciones existentes intactas)

---

### **Comportamiento Visual / Reglas de Negocio**

* Los frames `HU-ESTETICA-10` / `HU-ESTETICA-11` del `.pen` son la **referencia visual**; los specs de EST-13 son la **verdad de implementación**.
* El desglose es **presentación**: no cambia el cálculo final de stats (el breakdown es informativo).
* El marcado Z/X y las acciones del tooltip usan los flujos existentes (R6.2/R4/R5.2).

---

### **Alcance**

#### Incluye

* Rediseño de la mochila (`InventoryUI`): pilas, rarezas, estados, marcado Z/X, tooltip con acciones.
* Rediseño de Equipo+Stats (`EquipmentUI`): dos columnas, desglose bajo demanda, resaltado slot↔stat, header + XP.
* Extensión acotada para el breakdown (server-side recomendado) sin cambiar el cálculo final.
* Fuentes mapeadas, 9-slice, botones 3 estados, iconos (subida + ASSETS_REGISTRY), animaciones Tween y safe area móvil.

#### No incluye

* Lógica de inventario, equip, stats, stacking ni venta (intacta, salvo la extensión del breakdown).
* Cambios a reglas de juego, balance ni economía.
* Las demás ventanas del reskin (HUD, talentos, grimorio, vendors — HUs propias).
* Diseño en Pencil (diseñador — HU-ESTETICA-10/11 ya entregadas).

---

### **Definition of Done (DoD)**

* [ ] Mochila fiel al frame EST-11 (20 casillas, pilas `xN`, rarezas, Z/X, tooltip con acciones, estados vacía/llena).
* [ ] Equipo+Stats fiel al frame EST-10 (dos columnas, 9 slots con equipo activo, stats compactas, header + XP).
* [ ] Desglose bajo demanda citando ítems; resaltado slot↔stat funcionando.
* [ ] Breakdown server-side (o alternativa aprobada) sin alterar el cálculo final.
* [ ] Fuentes mapeadas, 9-slice, botones 3 estados, iconos registrados.
* [ ] Animaciones TweenService y safe area móvil aplicadas.
* [ ] Sin errores rojos en mochila → equipar → stats → combatir → respawn → rejoin (PC y móvil).
* [ ] Servicios/remotes intactos (salvo la extensión acotada); anti-exploit vigente.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Al cerrar: PROJECT_ARCHITECTURE, DATA_SCHEMA y registro HU/RC actualizados; nota en GDD después de QA.

---

### **Decisiones por defecto EST-21**

| Tema | Default |
|------|---------|
| Referencia visual | Frames `HU-ESTETICA-10 — Equipo+Stats` y `HU-ESTETICA-11 — Mochila` del `.pen` (mirar el diseño completo) |
| Desglose | Breakdown **server-side** (extensión de RecalculateStats informativa; no cambia el total) |
| Tamaño ventana C | ~480×320 de referencia; máx ~85% en móvil |
| Fuentes | PlayfairDisplay / Inter / RobotoMono (mapa EST-13) |
| Lógica | `InventoryService`/remotes intactos (salvo la extensión del breakdown) |

---

### **Estimación (orientativa)**

2–3 sesiones del dev: rediseño de mochila + equipo/stats (con breakdown) + mobile + regresión.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-18 | Creación de HU-ESTETICA-21: rediseño de Mochila (B) y Equipo+Stats (C) en Roblox (dev), referenciando los frames `HU-ESTETICA-10/11` del `.pen`; pilas/rarezas/tooltips y desglose bajo demanda con resaltado slot↔stat — sin tocar la lógica |