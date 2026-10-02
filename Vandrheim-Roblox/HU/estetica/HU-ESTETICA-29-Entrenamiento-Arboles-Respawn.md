# HU-ESTETICA-29: Zona de entrenamiento, árboles del pueblo y zona de respawn (diseñador)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / Mundo / Hub
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Producción de zonas y props 3D (diseñador, en Studio) — **sin scripts ni lógica**; el dev integra conservando la funcionalidad del dummy
**Fase GDD:** EST (transversal; complementa a HU-ESTETICA-26/27)
**Depende de:** HU-ESTETICA-26 (pueblo completo), HU-ESTETICA-27 (integración del hub), HU-R1 (TrainingDummy), ASSETS_POLICY (estructura/naming/registro)
**No modifica:** interactividad del dummy (recibe daño), gameplay ni lógica

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** una zona de entrenamiento con dummies para probar mi combate, árboles en el pueblo y una zona de inicio/respawn bien marcada,
**para** practicar sin ir a la dungeon y que el pueblo se sienta vivo y claro.

**Como** equipo de desarrollo,
**quiero** estas zonas entregadas listas para integrar,
**para** que el dev las ubique conservando la funcionalidad del dummy.

---

### **Descripción del Requerimiento / Contexto**

El hub tiene el pueblo completo (EST-26) y su integración (EST-27). Esta HU entrega las **zonas complementarias del lado del pueblo**:

| Elemento | Detalle |
|----------|---------|
| **Zona de entrenamiento** | Área delimitada (valla/arena de tablones o piedra) con bancos y marcas de suelo. Dummies: **reutilizar el `TrainingDummy` existente** + **añadir 3–4 nuevos** (melee estándar, con armadura/élite, a distancia/ranged). Los nuevos **replican la estructura del dummy existente** (parte que recibe daño + `Humanoid`) para que sigan siendo dañables; el dev valida el flujo R1/R6.8 |
| **Árboles del pueblo** | Prefabs reutilizables: **abedul, pino y roble con nieve ligera** — 2–3 tamaños c/u, repartidos en el perímetro del pueblo y caminos |
| **Zona de respawn/inicio** | Plataforma de entrada del jugador al pueblo: **runas de spawn, estandartes y braseros** — marca visual del punto de aparición (el dev valida/conserva la posición de spawn actual que usan los scripts) |
| **Atalaya (opcional)** | Torre de vigilancia junto al portón (aprovecha las murallas de EST-26) — solo si el PO la confirma |

**Reglas generales (heredadas de EST-26/03 y ASSETS_POLICY):**

* Modelos estáticos sin scripts; `Anchored=true` con `PrimaryPart` en estructuras grandes; props decorativos `CanCollide=false`/`CanTouch=false`/`CanQuery=false`/`Massless=true`; troncos de árboles pueden colisionar (sin trapar navegación).
* **Conservar funcionalidad:** el `TrainingDummy` original se mantiene (o se reubica); los dummies nuevos replican su estructura de daño. El diseñador **no agrega scripts**.
* Nombres descriptivos `snake_case` en `Assets/Models/Hub/` (patrón EST-26/03); registro en `ASSETS_REGISTRY`; notas de entrega (ubicaciones propuestas y qué reemplaza cada pieza).
* Rendimiento: prefabs con pocas piezas, sin partículas pesadas.

**Criterio de hecho global:** el hub tiene zona de entrenamiento (dummy existente + nuevos, todos dañables), árboles variados en el pueblo y una zona de inicio/respawn marcada — navegable y sin romper nada.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Zona de entrenamiento funcional**

* **GIVEN** la zona de entrenamiento integrada
* **WHEN** el jugador golpea a cualquier dummy (existente o nuevo)
* **THEN** todos reciben daño (flujo R1/R6.8) y el área se ve delimitada

#### **Escenario 2: Dummies variados**

* **GIVEN** los dummies nuevos
* **WHEN** se revisa la zona
* **THEN** se distinguen las variedades (melee, armadura/élite, ranged) y replican la estructura del dummy existente

#### **Escenario 3: Árboles del pueblo**

* **GIVEN** los prefabs del pueblo
* **WHEN** se recorre el pueblo
* **THEN** hay abedules, pinos y robles nevados sin trapar navegación

#### **Escenario 4: Respawn/inicio**

* **GIVEN** la zona inicial integrada
* **WHEN** el jugador entra al pueblo
* **THEN** aparece en la zona marcada (runas/estandartes) y la posición respeta lo que los scripts usan

#### **Escenario 5: Entrega válida**

* **GIVEN** los modelos entregados
* **WHEN** se inspecciona `Assets/Models/Hub/`
* **THEN** están registrados, con nombres claros y sin scripts

#### **Escenario 6: Regresión**

* **GIVEN** las zonas integradas
* **WHEN** se juega el flujo (spawn → entrenamiento → pueblo → portal)
* **THEN** no hay errores rojos y el dummy funciona igual

---

### **Alcance**

#### Incluye

* Zona de entrenamiento (dummy existente + 3–4 nuevos con su estructura de daño).
* Árboles del pueblo (prefabs con variantes).
* Zona de respawn/inicio marcada.
* (Opcional) Atalaya en el portón si el PO la confirma.
* Notas de entrega + ASSETS_REGISTRY.

#### No incluye

* Scripts, prompts ni lógica (los conserva el dev).
* La zona helada con la entrada a la mazmorra (**HU-ESTETICA-28**).
* Modelos de enemigos ni otros assets.
* Cambios a gameplay, balance ni reglas.

---

### **Definition of Done (DoD)**

* [ ] Zona de entrenamiento con dummies (todos dañables) delimitada y navegable.
* [ ] Árboles variados en el pueblo (prefabs).
* [ ] Zona de respawn/inicio marcada y validada con la posición de spawn actual.
* [ ] (Opcional) Atalaya integrada si el PO la confirma.
* [ ] Modelos estáticos, registrados, con nombres claros y sin scripts.
* [ ] Navegación fluida y rendimiento OK; sin regresión (playtest).
* [ ] Reporte al PM con el detalle y pendientes.

---

### **Estimación (orientativa)**

1–2 sesiones del diseñador: entrenamiento + árboles + zona de inicio (+ opcional atalaya).

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-ESTETICA-29: zona de entrenamiento (dummy existente + nuevos dañables), árboles del pueblo y zona de respawn/inicio — separada de la zona helada (HU-ESTETICA-28) |