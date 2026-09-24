# HU-ESTETICA-26: Pueblo completo de Vandrheim — estructuras procedurales, casas con interior, murallas y plaza (diseñador)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / Mundo / Hub
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Producción de estructuras 3D (diseñador, en Studio) — **sin scripts ni lógica**; el dev integra conservando NPCs/portal/dummy
**Fase GDD:** EST (transversal; **reemplaza/absorbe a HU-ESTETICA-03**, que queda obsoleta)
**Depende de:** HU-ESTETICA-03 (estructuras nórdicas — absorbida por esta), HU-R5 (NPCs `vendor_*`, `vendor_trainer`), HU-R6b (portal `PortalFrame`/`PortalMarker`), HU-R1 (TrainingDummy), ASSETS_POLICY (estructura/naming/registro)
**No modifica:** interactividad existente (prompts de NPCs/portal/dummy), gameplay ni lógica

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** un pueblo nórdico completo y coherente: casas (algunas con interior donde están los vendedores), murallas, plaza central y una casa comunal cerrada,
**para** que el hub se sienta como un asentamiento vikingo real y no un blockout.

**Como** equipo de desarrollo,
**quiero** las estructuras del pueblo generadas de forma procedural y entregadas listas para integrar,
**para** que el dev solo las ubique/conserve sin crear assets ni tocar gameplay.

---

### **Descripción del Requerimiento / Contexto**

El pueblo actual tiene estructuras placeholder. Esta HU entrega el **pueblo completo** con temática nórdica/vikinga, **generando las estructuras de forma procedural** en el proceso de diseño (Studio): el diseñador usa técnicas/plugins de generación para crear las piezas, pero **entrega modelos estáticos** (sin scripts) en `ReplicatedStorage/Assets/Models/Hub/`.

**Composición del pueblo (decisión PO 2026-09-22):**

| Elemento | Cantidad | Detalle |
|----------|----------|---------|
| **Casas sin interior** | **5** | Exteriores completos (techos, vigas, puertas/ventanas cerradas); decoración exterior (banco, barril, leña) |
| **Casas con interior** | **3** | Una por NPC comercial: **Vendedor de pociones**, **Armero**, **Instructor** — con interior navegable (suelo, paredes, estantes/mostrador según el comercio, iluminación cálida) y zona donde va el NPC (el dev conserva el NPC + su `ProximityPrompt`) |
| **Murallas** | Perímetro | Empalizada/estacada nórdica alrededor del pueblo con **portón/entrada** principal; muros colisionables (dan forma), sin trapar navegación |
| **Lugar central de reunión** | 1 | **Plaza central**: espacio abierto con hoguera/brasero central, bancos de piedra/madera, estandartes; punto de encuentro visible desde la entrada |
| **Casa comunal cerrada** | 1 | Edificio mediano (longhouse/gran casa comunal) **cerrado** (sin interior accesible por ahora — contenido futuro); se ve sólido y decorado (vigas talladas, runas) |
| **Decoraciones** | varias | Banderas, runas de piedra, braseros/antorchas, barriles, carretas, postes, cráneos/cuernos si aplica — repartidas sin tapar caminos |

**Reglas generales (heredadas de EST-02/03 y ASSETS_POLICY):**

* **Procedural pero estático:** se permite generación procedural en el proceso de diseño (plugins/scripts de Studio), pero la entrega son **modelos estáticos sin scripts**; el dev no genera nada en runtime para el hub.
* Estética: madera oscura, techos a dos aguas muy inclinados (madera/turba o paja), vigas visibles, piedra fría, runas, acentos de hielo — **Helada/Vandrheim**.
* Estructuras grandes: `Anchored=true`, `PrimaryPart` definido; props: `CanCollide=false`, `CanTouch=false`, `CanQuery=false`, `Massless=true`. Muros de casas/empalizada pueden colisionar pero **sin crear trampas de navegación** ni bloquear spawn/NPCs/dummy/portal.
* **Conservar:** `Humanoid` + `ProximityPrompt` de `vendor_*`, `PortalPrompt` del portal, `TrainingDummy` — el diseñador no los toca; si una casa con interior ubica a un NPC, deja la **zona libre** y lo documenta (el dev coloca/ajusta el NPC sin romper su prompt).
* Entregables: modelos con nombres descriptivos `snake_case` en `Assets/Models/Hub/` (patrón EST-03), notas de entrega (qué reemplaza cada modelo), registro en `ASSETS_REGISTRY`.

**Criterio de hecho global:** el hub se ve como un asentamiento nórdico completo y navegable — 5 casas, 3 casas con interior para los NPCs comerciales, murallas con portón, plaza central y casa comunal cerrada — con NPCs/portal/dummy intactos y el jugador moviéndose con fluidez.

---

### **Especificaciones Técnicas / Contratos de API (estructura)**

#### **1. Generación procedural (proceso del diseñador)**

* El diseñador genera las piezas con técnicas procedurales (variaciones paramétricas de casas/murallas: largo, altura, material de techo, decoración) para dar variedad sin modelar casa por casa a mano.
* **Entrega estática:** las estructuras finales se hornean como modelos normales en `Assets/Models/Hub/` (sin scripts ni generadores en runtime).

#### **2. Layout propuesto (referencia; el diseñador puede proponer mejoras)**

```text
        [Muralla / empalizada con portón al sur]
                 ┌──────────────┐
                 │  Casa comunal│ (cerrada, mediana)
                 └──────────────┘
    Casa 1                     Casa 4
        \                       /
         ┌─────────────────────┐
         │   PLAZA CENTRAL     │
         │   (hoguera, bancos) │
         └─────────────────────┘
        /                       \
    Casa 2                     Casa 5
   (sin interior)         (sin interior)
        \                       /
   [Vendedor de pociones]  [Armero]
   (casa con interior)    (casa con interior)
                [Instructor]
                (casa con interior)
        [Camino hacia el resto: dummy / portal / acceso]
```

* El portal, el dummy y los NPCs conservan sus posiciones funcionales actuales (o el diseñador propone reubicaciones documentadas que el dev valida).

#### **3. Casas con interior (detalle)**

* Cada una: puerta abierta/umbral navegable, suelo interior, paredes interiores, y el **mostrador/estante del comercio**:
  * Vendedor de pociones: estantes con frascos/botellas.
  * Armero: soportes/armas en las paredes, yunque si aplica.
  * Instructor: banco/altar de entrenamiento, runas.
* Iluminación interior cálida (antorcha/brasero, sin VFX pesado).
* El NPC se ubica detrás del mostrador (espacio reservado; el dev lo coloca manteniendo su prompt).

#### **4. Navegación y regresión**

* El jugador llega con fluidez a los 3 NPCs, al dummy y al portal (sin quedar atrapado).
* Móvil: sin problemas de colisión extra.
* Playtest: spawn → camino a NPCs/portal/dummy → cámara sin clipping grave.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Pueblo completo**

* **GIVEN** el hub integrado
* **WHEN** se recorre el pueblo
* **THEN** se ven 5 casas sin interior, 3 casas con interior (con su NPC comercial), murallas con portón, plaza central con hoguera y la casa comunal cerrada

#### **Escenario 2: NPCs funcionales**

* **GIVEN** las 3 casas con interior
* **WHEN** el jugador entra
* **THEN** el NPC correspondiente está en su zona (dev), su `ProximityPrompt` funciona y el interior es navegable

#### **Escenario 3: Portal y dummy intactos**

* **GIVEN** el pueblo rediseñado
* **WHEN** se revisan portal y dummy
* **THEN** conservan sus prompts y funcionan (teleport/dummy recibe daño)

#### **Escenario 4: Navegación fluida**

* **GIVEN** el pueblo completo
* **WHEN** el jugador se mueve entre casas, plaza, NPCs, dummy y portal
* **THEN** no queda atrapado ni bloqueado; la cámara no clipea grave

#### **Escenario 5: Entrega válida**

* **GIVEN** los modelos entregados
* **WHEN** se inspecciona `Assets/Models/Hub/`
* **THEN** los modelos tienen nombres claros, están registrados (ASSETS_REGISTRY) y **no contienen scripts ni lógica**

#### **Escenario 6: Regresión**

* **GIVEN** el hub integrado
* **WHEN** se juega el flujo completo (pueblo → vendors → portal → dungeon → vuelta)
* **THEN** no hay errores rojos y todo lo existente sigue funcionando

---

### **Alcance**

#### Incluye

* 5 casas sin interior + 3 casas con interior (para los 3 NPCs comerciales).
* Murallas con portón, plaza central (hoguera, bancos, estandartes), casa comunal cerrada.
* Decoraciones nórdicas (banderas, braseros, barriles, runas, etc.).
* Generación procedural en el proceso de diseño (entrega estática).
* Notas de entrega (qué reemplaza cada modelo) + ASSETS_REGISTRY.

#### No incluye

* Scripts, prompts, interactividad (los conserva el dev).
* Interior de la casa comunal (cerrada; contenido futuro).
* Modelos de enemigos (EST-02) ni otros assets.
* Cambios a gameplay, balance ni reglas.

---

### **Definition of Done (DoD)**

* [ ] Pueblo completo: 5 + 3 casas (con interior comercial), murallas + portón, plaza central, casa comunal cerrada.
* [ ] NPCs/portal/dummy conservados y funcionales; interiores navegables.
* [ ] Navegación fluida (sin trampas); cámara sin clipping grave.
* [ ] Modelos estáticos sin scripts, con nombres claros y registrados.
* [ ] Notas de entrega al dev (reemplazos y ubicaciones propuestas).
* [ ] Playtest: spawn → NPCs → dummy → portal OK.
* [ ] Reporte al PM con el detalle y pendientes.

---

### **Estimación (orientativa)**

3–5 sesiones del diseñador: generación procedural + 8 casas + murallas + plaza + decoración + ajustes de navegación.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-ESTETICA-26: pueblo completo de Vandrheim (diseñador) — 5 casas sin interior, 3 casas con interior para los NPCs comerciales, murallas con portón, plaza central y casa comunal cerrada; generación procedural con entrega estática; **reemplaza/absorbe a HU-ESTETICA-03** |