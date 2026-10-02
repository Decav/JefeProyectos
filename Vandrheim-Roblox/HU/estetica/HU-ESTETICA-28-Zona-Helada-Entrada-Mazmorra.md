# HU-ESTETICA-28: Zona helada completa con la entrada a la mazmorra (diseñador)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / Mundo / Hub
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Producción de zona y props 3D (diseñador, en Studio) — **sin scripts ni lógica**; el dev integra conservando el portal
**Fase GDD:** EST (transversal; complementa a HU-ESTETICA-26/27)
**Depende de:** HU-ESTETICA-26 (pueblo completo), HU-ESTETICA-27 (integración del hub), HU-R6b (portal `PortalFrame`/`PortalMarker`), ASSETS_POLICY (estructura/naming/registro)
**No modifica:** interactividad del portal (teleporta a la dungeon), gameplay ni lógica

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** llegar a una **zona helada** clara y temática que contenga la entrada a la mazmorra,
**para** entender que ahí empieza la aventura a la Helada y entrar por un portal que se vea épico.

**Como** equipo de desarrollo,
**quiero** la zona helada entregada lista para integrar,
**para** que el dev la ubique conservando el portal funcional.

---

### **Descripción del Requerimiento / Contexto**

El hub tiene el pueblo completo (EST-26) y su integración (EST-27). Esta HU entrega la **zona helada completa** que contiene la **entrada a la mazmorra** (el portal existente `PortalFrame`/`PortalMarker` se conserva con su `PortalPrompt`).

**Contenido de la zona:**

| Elemento | Detalle |
|----------|---------|
| **Suelo de la zona** | Material `Ice` (plataforma de hielo), con grietas/cristales decorativos |
| **Entrada a la mazmorra** | El portal existente se decora alrededor: **arcos rúnicos helados**, columnas de cristal, runas de hielo en el suelo; el portal conserva su `PortalPrompt` (el dev valida que teleporta) |
| **Decoración de hielo** | Cristales de hielo (prefab con variantes), estalactitas, antorchas/braseros **fríos** (luz azul), piedras nevadas |
| **Fondo visual** | Montañas/peñas de nieve alrededor (visual, `CanCollide=false` según caso) que delimitan la zona sin trapar |
| **Árboles de la zona helada** | Prefabs: **pino cubierto de hielo, abeto, árbol muerto congelado** — con 2–3 tamaños c/u, repartidos en el perímetro |
| **Camino de transición** | Sendero/puente de piedra con nieve que conecta el pueblo con la zona helada (transición natural) |

**Reglas generales (heredadas de EST-26/03 y ASSETS_POLICY):**

* Modelos estáticos sin scripts; `Anchored=true` con `PrimaryPart` en estructuras grandes; props decorativos `CanCollide=false`/`CanTouch=false`/`CanQuery=false`/`Massless=true`; troncos de árboles pueden colisionar (sin trapar navegación).
* **Conservar funcionalidad:** el portal mantiene su instancia y `PortalPrompt`; el diseñador decora alrededor sin tocar el prompt.
* Nombres descriptivos `snake_case` en `Assets/Models/Hub/` (patrón EST-26/03); registro en `ASSETS_REGISTRY`; notas de entrega (ubicaciones propuestas).
* Rendimiento: prefabs con pocas piezas, sin partículas pesadas.

**Criterio de hecho global:** el hub tiene una zona helada completa y navegable con la entrada a la mazmorra (portal funcional), decoración de hielo, árboles helados y camino de transición desde el pueblo — sin romper nada.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Zona helada completa**

* **GIVEN** la zona helada integrada
* **WHEN** se recorre
* **THEN** se ve el suelo de hielo, cristales, arcos rúnicos y decoración helada, con el portal al centro

#### **Escenario 2: Portal funcional**

* **GIVEN** la zona helada
* **WHEN** el jugador llega al portal
* **THEN** conserva su prompt y teleporta a la dungeon (flujo R6b/PUBLICAR-02)

#### **Escenario 3: Árboles helados**

* **GIVEN** los prefabs de la zona helada
* **WHEN** se recorren el perímetro y el camino
* **THEN** hay pinos helados, abetos y árboles congelados sin trapar navegación

#### **Escenario 4: Camino de transición**

* **GIVEN** el camino integrado
* **WHEN** se va del pueblo a la zona helada
* **THEN** la transición se siente natural y navegable

#### **Escenario 5: Entrega válida**

* **GIVEN** los modelos entregados
* **WHEN** se inspecciona `Assets/Models/Hub/`
* **THEN** están registrados, con nombres claros y sin scripts

#### **Escenario 6: Regresión**

* **GIVEN** la zona integrada
* **WHEN** se juega el flujo (pueblo → camino → zona helada → portal → dungeon)
* **THEN** no hay errores rojos y el portal funciona igual

---

### **Alcance**

#### Incluye

* Zona helada completa (suelo `Ice`, cristales, arcos rúnicos, antorchas frías, fondo de montañas).
* Decoración de la entrada a la mazmorra (portal conservado).
* Árboles de la zona helada (prefabs).
* Camino de transición pueblo → zona helada.
* Notas de entrega + ASSETS_REGISTRY.

#### No incluye

* Scripts, prompts ni lógica (los conserva el dev).
* La zona de entrenamiento, árboles del pueblo ni zona de respawn (**HU-ESTETICA-29**).
* Modelos de enemigos ni otros assets.
* Cambios a gameplay, balance ni reglas.

---

### **Definition of Done (DoD)**

* [ ] Zona helada completa y navegable (hielo, cristales, arcos, antorchas frías).
* [ ] Portal conservado y funcional (teleporta a la dungeon).
* [ ] Árboles helados variados en el perímetro y el camino.
* [ ] Camino de transición desde el pueblo integrado.
* [ ] Modelos estáticos, registrados, con nombres claros y sin scripts.
* [ ] Navegación fluida y rendimiento OK; sin regresión (playtest).
* [ ] Reporte al PM con el detalle y pendientes.

---

### **Estimación (orientativa)**

1–2 sesiones del diseñador: zona helada + portal decorado + árboles + camino.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-ESTETICA-28: zona helada completa con la entrada a la mazmorra (portal conservado), decoración de hielo, árboles helados y camino de transición desde el pueblo — separada del resto de zonas (HU-ESTETICA-29) |