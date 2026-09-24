## HU-ESTETICA-03: Estructuras del pueblo principal — temática nórdica antigua

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética MVP / Hub
**Prioridad:** — 
**Estado:** **OBSOLETA — absorbida por `HU-ESTETICA-26` (pueblo completo)** (2026-09-22): esta HU queda reemplazada por la entrega integral del pueblo (5 casas sin interior + 3 con interior para NPCs comerciales, murallas, plaza, casa comunal). No implementar por separado.
**Tipo:** Producción de estructuras y props (diseñador de assets)  
**Fase GDD:** Épica transversal `EST-03` (paralela a R6.x/R7; no bloquea gameplay)  
**Rol responsable:** Diseñador de assets — **exclusivamente modelos y estructuras visuales** (sin scripts, sin código, sin lógica)  
**Depende de:** HU-ASSETS (estructura/naming/paleta), estructura actual de `Workspace.Hub`, HU-ESTETICA-01/02 (convenciones de entrega del diseñador)  
**Integración (dev, tarea mínima aparte):** reemplazar/ubicar los modelos en `Workspace.Hub` conservando nombres usados por scripts y registrar en `ASSETS_REGISTRY`

---

### **Narrativa (INVEST)**

**Como** jugador,  
**quiero** un pueblo principal con estética nórdica antigua coherente: casas de madera y piedra, caminos, decoraciones, límites y entradas claras,  
**para** que el hub se sienta como un asentamiento vikingo real y no como un bloqueout genérico.

**Como** equipo,  
**quiero** que el diseñador entregue las estructuras listas para integrar,  
**para** que el dev solo las coloque/reemplace sin crear assets ni tocar gameplay.

---

### **Descripción del Requerimiento / Contexto**

Estado actual verificado en `Workspace.Hub`:

* `Props/` contiene: `Modelo_Inn`, `Modelo_Blacksmith`, `Torch_1..4`, `FencePost_*`, `Path_Stone_*`, `Crate1`, `Crate2`, `Well`.
* `PortalFrame`/`PortalMarker` (portal a la dungeon) y los NPCs `vendor_consumables`, `vendor_gear`, `vendor_trainer` con `Humanoid` + `ProximityPrompt`.
* `TrainingDummy` (combate de prueba).
* Los props actuales ya recibieron una pasada de materiales (rc008), pero no constituyen un asentamiento nórdico completo.

Esta HU entrega **las estructuras y decoraciones del pueblo en temática nórdica antigua**. El diseñador produce los modelos; el dev los integra en `Workspace.Hub` conservando los nombres y componentes que los scripts usan.

Regla general: **nada de scripts ni lógica** en los modelos entregados. Cualquier interactividad existente (ProximityPrompt de NPCs/portal, Humanoid, dummy de combate) se conserva tal cual; el diseñador no la toca.

---

### **Especificaciones Técnicas / Contratos**

#### **1. Entregables del diseñador**

| # | Entregable | Detalle nórdico | Reemplaza / nueva |
|---|-----------|-----------------|-------------------|
| 1 | **Casas nórdicas (3)** | Longhouses de madera oscura + piedra, techos a dos aguas muy inclinados (sugerencia: madera/turba o paja), vigas visibles, puertas y ventanas con luz cálida | Rediseñar `Modelo_Inn` y `Modelo_Blacksmith` + 1 casa nueva `Modelo_CasaNordica` |
| 2 | **Caminos** | Camino principal de adoquín/piedra irregular con nieve/barro; variantes para senderos secundarios | Rediseñar `Path_Stone_*` + nuevas piezas `Path_*` |
| 3 | **Límites del pueblo** | Empalizada/palisada de madera con troncos verticales y refuerzos; muro bajo de piedra en tramos | Nuevas piezas `Wall_*` / `Palisade_*` |
| 4 | **Entradas** | Portón principal de madera maciza (2 hojas) con postes y vigas; 1–2 portones secundarios | Nuevas `Gate_*` |
| 5 | **Decoraciones** | Antorchas y braseros restilizados, banderas/estandartes, piedras rúnicas, barriles, cajas, pozo rediseñado, figuras de madera, carreta | Rediseñar `Torch_1..4`, `Crate1/2`, `Well` + nuevas `Banner_*`, `RuneStone_*`, `Brazier_*`, `Barrel_*`, `Cart` |
| 6 | **Zona del portal** | Marco/portal nórdico (piedra rúnica con hielo) sin perder el prompt de teleport | Rediseño visual de `PortalFrame`/`PortalMarker` (el dev conserva el `ProximityPrompt`) |

Los NPCs (`vendor_*`) y `TrainingDummy` **no se rediseñan en esta HU** (salvo ajuste menor de escala/mat si es aprobado por el PM); su estructura e interactividad son sagradas.

#### **2. Ubicación y naming de entrega**

* Los modelos nuevos se entregan en `ReplicatedStorage.Assets.Models.Hub/` con nombres descriptivos `snake_case` en inglés (ej. `house_longhouse_01`, `gate_main`, `palisade_segment`, `path_cobble_01`, `banner_01`, `rune_stone_01`).
* Para los existentes que se **rediseñan** (Inn, Blacksmith, Torches, Crates, Well, PortalFrame visual), el diseñador entrega la versión nueva con su **nombre original** (para que el dev la reemplace sin romper referencias) y marca en las notas qué instancia reemplaza.
* No dejar copias sueltas en `Workspace` ni nombres genéricos (`Part`, `Model`, `Prop`).
* Los nombres de instancias internas importantes (Humanoid, HumanoidRootPart, ProximityPrompt) se conservan en NPCs/portal; en props decorativos se usan nombres claros por pieza.

#### **3. Requisitos estructurales (consistentes con EST-02)**

* Modelos con `PrimaryPart` definido cuando aplique (estructuras grandes, portones).
* Partes principales (muros, techos, suelos): `Anchored=true` **si el dev las ubica como escenario estático** — el diseñador entrega con `Anchored=false` y `CanCollide=true` en muros/techos/suelos, y documenta que el dev puede anclar al colocarlas en el lugar.
* Piezas decorativas (banderas, runas, barriles pequeños, braseros): `CanCollide=false`, `CanTouch=false`, `CanQuery=false`, `Massless=true`.
* **Sin scripts**, sin `Sound`, sin `ParticleEmitter`/`Trail` (el fuego de antorchas/braseros lo agrega el dev/VFX si corresponde, no el diseñador).
* Sin `ProximityPrompt` nuevos (los prompts los gestiona el dev).
* Escala humana coherente con el avatar R15 y con el kit de la dungeon (el pueblo debe sentirse grande pero navegable).

#### **4. Estética nórdica antigua**

* **Paleta:** maderas oscuras (pino/roble), piedra gris, nieve y escarcha en bordes, acentos rojo/ocre en detalles y banderas, hierro oxidado.
* **Materiales:** reutilizar `MaterialVariant` existentes (`Mat_madera_pueblo`, `Mat_metal_oxido`, `Mat_tela`, `Mat_piedra_helada`) o crear nuevos con nombres consistentes (`Mat_madera_nordica`, `Mat_piedra_pueblo`, `Mat_techo_turba`).
* **Siluetas:** techos inclinados, vigas expuestas en fachada (estilo longhouse), empalizadas con puntas, postes con cuerdas/banderas.
* **Coherencia:** el pueblo debe leerse "nórdico antiguo" de un vistazo, pero mantenerse legible desde la cámara 3ª persona y con el HUD/iluminación actuales.
* Estilo estilizado/liviano para MVP (no calidad AAA).

#### **5. Colisión y jugabilidad**

* Los muros de casas y empalizadas pueden colisionar (dan forma al pueblo), pero no deben crear trampas de navegación ni bloquear el spawn, los NPCs, el dummy o el portal.
* Los caminos son decorativos: `CanCollide=false` (el suelo ya existe) o piezas finas que no estorben el movimiento.
* Verificar que el jugador pueda moverse con fluidez entre casas, llegue a los 3 NPCs, al dummy y al portal.

#### **6. Integración (tarea del dev, NO del diseñador)**

Después de la entrega:

* Reemplazar/colocar los modelos en `Workspace.Hub` (y `Workspace.Hub.Props`) según las notas del diseñador.
* Conservar: `Humanoid`+`ProximityPrompt` de `vendor_*`, `PortalPrompt` del portal, `TrainingDummy`.
* Anclar muros/suelos de estructuras grandes y ajustar iluminación de antorchas/braseros (puede ser parte del dev o una HU de VFX menor).
* Registrar todos los assets en `ASSETS_REGISTRY` (fuente: diseñador/producción propia).
* Playtest: spawn, camino a NPCs/portal/dummy, cámara sin clipping grave.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Entregables completos**

* **GIVEN** la lista de entregables EST-03
* **WHEN** se inspecciona `ReplicatedStorage.Assets.Models.Hub`
* **THEN** existen las casas, caminos, límites, entradas y decoraciones requeridas
* **AND** cada modelo tiene un nombre descriptivo y estable

#### **Escenario 2: Sin scripts**

* **GIVEN** un modelo entregado
* **WHEN** se revisan sus descendientes
* **THEN** no contiene Script, LocalScript, Sound, ParticleEmitter, Trail ni ProximityPrompt

#### **Escenario 3: Estructura y colisión**

* **GIVEN** un modelo entregado
* **WHEN** se valida su jerarquía
* **THEN** tiene `PrimaryPart` cuando corresponde
* **AND** muros/techos/suelos tienen `CanCollide=true` (para anclar en escenario)
* **AND** las decoraciones tienen colisión/query/touch desactivados

#### **Escenario 4: Temática nórdica**

* **GIVEN** el set completo integrado en el hub
* **WHEN** se observa el pueblo desde el spawn
* **THEN** se lee una estética nórdica antigua coherente (longhouses, empalizada, portón, caminos, decoraciones)
* **AND** no hay piezas grises, sin material o fuera de paleta

#### **Escenario 5: Navegación intacta**

* **GIVEN** el pueblo integrado
* **WHEN** el jugador se mueve por el hub
* **THEN** llega con fluidez a los 3 NPCs, al dummy y al portal
* **AND** no queda atrapado ni bloqueado por estructuras

#### **Escenario 6: Interactividad conservada**

* **GIVEN** los NPCs, el portal y el dummy
* **WHEN** se interactúa con ellos tras la integración
* **THEN** vendor/trainer abren sus ventanas, el portal teleporta y el dummy recibe daño
* **AND** nada de esto fue roto por el rediseño visual

#### **Escenario 7: Límites y entradas visibles**

* **GIVEN** el límite del pueblo
* **WHEN** el jugador camina hacia el borde
* **THEN** hay empalizada/muro y portones que marcan la entrada
* **AND** el portón principal se distingue claramente como acceso

#### **Escenario 8: Registro**

* **GIVEN** los assets integrados
* **WHEN** se revisa `ASSETS_REGISTRY`
* **THEN** cada estructura/prop tiene nombre, fuente, autor y licencia

#### **Escenario 9: Rendimiento**

* **GIVEN** el pueblo completo
* **WHEN** se revisa el rendimiento y el output
* **THEN** no hay errores de streaming/física
* **AND** el hub se carga y corre fluido en PC y móvil

---

### **Comportamiento Visual / Reglas de Negocio**

* El pueblo es escenario visual: no cambia reglas de juego, economía ni combate.
* Los props son puramente estéticos; la funcionalidad (NPCs, portal, dummy) vive en las instancias que el dev conserva.
* Estilo nórdico antiguo sin perder legibilidad desde tercera persona.
* Si un rediseño requiere cambiar el nombre de una instancia referenciada por scripts, el diseñador lo marca en las notas y el dev actualiza la referencia (nunca el diseñador).

---

### **Alcance**

#### Incluye

* 3 casas (Inn y Blacksmith rediseñados + 1 longhouse nueva).
* Caminos principales y secundarios.
* Empalizada/límites del pueblo.
* Portón principal + 1–2 portones secundarios.
* Decoraciones: antorchas/braseros, banderas, piedras rúnicas, barriles, cajas, pozo, carreta.
* Rediseño visual del marco del portal (sin tocar el prompt).
* Materiales nuevos del tema si se requieren.
* Notas de entrega para el dev (nombres, reemplazos, estructura).

#### No incluye

* Scripts, código, remotes ni lógica.
* ProximityPrompt, sistemas de interacción o VFX (fuego/partículas).
* Rediseño de NPCs ni del `TrainingDummy`.
* Iluminación/Lighting (dominio del dev/HU-ASSETS).
* Modelos del dungeon, enemigos (EST-02) o equipo visual (EST-01).
* Iconos, UI, SFX.
* Terreno fuera del pueblo (mundo abierto).

---

### **Definition of Done (DoD)**

* [ ] Los entregables existen en `ReplicatedStorage.Assets.Models.Hub` con nombres estables.
* [ ] Inn y Blacksmith rediseñados conservan sus nombres para reemplazo directo.
* [ ] Sin scripts, sonidos, partículas ni prompts en los modelos.
* [ ] Estructuras con `PrimaryPart` y reglas de colisión según contrato.
* [ ] Paleta y silueta nórdicas consistentes.
* [ ] Navegación intacta: NPCs, dummy y portal accesibles.
* [ ] Interactividad (NPCs/portal/dummy) sin regresiones tras la integración.
* [ ] Límites y entradas visibles y claros.
* [ ] Assets registrados en `ASSETS_REGISTRY`.
* [ ] Sin errores en output; hub fluido en PC y móvil.
* [ ] Nota `EST-03 completo` en GDD tras verificación.

---

### **Estimación (orientativa)**

3–5 sesiones de modelado (casas, empalizada, portones, caminos y decoraciones), según nivel de detalle aprobado.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-25 | Creación de HU-ESTETICA-03: estructuras del pueblo en temática nórdica antigua (casas, caminos, límites, entradas, decoraciones) |