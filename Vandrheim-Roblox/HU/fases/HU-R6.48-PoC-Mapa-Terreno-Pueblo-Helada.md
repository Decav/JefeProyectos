# HU-R6.48: PoC — mapa de terreno con pueblo y zona Helada (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Mundo / Hub / PoC técnico
**Prioridad:** Media — validación antes de invertir en el mundo final
**Estado:** Abierta — PoC para aprobación (el dev prepara RC antes de construir)
**Tipo:** Prueba de concepto de mundo (dev + apoyo de diseño)
**Fase GDD:** Mundo / Hub (previo a la expansión de biomas)
**Depende de:** HU-ESTETICA-26 (pueblo completo), HU-ESTETICA-27 (integración de NPCs), HU-ESTETICA-28 (zona Helada/entrada), HU-R9a.2 (portal/matchmaking), `StreamingEnabled`, `Lighting`
**No modifica:** la geometría, los NPCs, el portal ni la lógica del Hub actual. El PoC vive en una región vacía del mismo place y no es accesible en juego normal.

---

### Narrativa (INVEST)

**Como** equipo,
**quiero** probar un mapa continuo de terreno con el pueblo y la zona Helada en el mismo espacio,
**para** decidir si el mundo final debe construirse sobre terreno generado antes de invertir en arte y layouts definitivos.

**Como** jugador,
**quiero** caminar del pueblo a la entrada de la Helada sin pantallas de carga ni saltos raros,
**para** que el mundo se sienta un lugar y no un conjunto de salas.

---

### Descripción / Contexto

Hoy el Hub es un place con estructuras de partes y la Helada es un place aparte con pisos generados por kit. Se quiere evaluar un **mundo continuo de terreno**: un valle nevado con el pueblo sobre una meseta y, cerca, una zona de hielo con la entrada a la dungeon.

Esta HU es una **PoC**: valida pipeline, escala, navegación, rendimiento móvil y encaje de los sistemas existentes. No reemplaza el Hub ni define el arte final.

**Criterio de hecho global:** existe una región de terreno generado en el mismo place, aislada del Hub, donde el jugador aparece en el pueblo, camina hasta la zona Helada sin cargas ni bloqueos, los sistemas se prueban con copias controladas y el rendimiento en móvil es aceptable.

---

### Decisiones cerradas (PO 2026-11-03)

1. **Ubicación:** mismo place, en una **región vacía y separada** del Hub. No se modifica la zona actual.
2. **Lago helado:** **sí**, decorativo.
3. **Escala:** **mayor que 1024×1024**; objetivo de la PoC **2048×2048 studs** (16 regiones de terreno), preparado para crecer.

---

### Especificaciones Técnicas / Contratos

#### 1. Aislamiento dentro del mismo place

* Construir el PoC en una región vacía a **≥8.000 studs** del Hub actual, sin partes ni terreno existente alrededor.
* **No mover, duplicar ni editar** los NPCs, portal, spawn o estructuras del Hub real.
* El acceso al PoC es solo por **teleport de debug** (Studio/admin) con un atributo de sesión `WorldPoC`. Un jugador normal no debe poder llegar caminando.
* Las copias de NPCs y portal del PoC arrancan con sus prompts **desactivados**; se activan solo para el tester (`WorldPoC = true`). Los servicios existentes deben ignorar las copias cuando el atributo no está.
* `StreamingEnabled` con radio que impida cargar el PoC desde el Hub y viceversa.

#### 2. Terreno

* Generación con la **herramienta de terreno de Studio** (Generate/Sculpt/Paint), no con partes.
* Extensión: **2048×2048 studs** (16 regiones de 512), con margen para ampliar.
* Tipos: nieve, hielo, roca y tierra/grava en caminos.
* Relieve:
  * **Meseta del pueblo:** zona plana de ~300×300 studs a altura estable.
  * **Valle y camino:** franja de 30–40 studs con pendientes ≤30–35° conectando pueblo y zona Helada.
  * **Zona Helada:** explanada de ~300×300 studs con desniveles suaves y plataforma para el portal.
  * **Anillo de montañas** perimetral como límite natural.
* **Lago helado decorativo:** superficie de hielo transitable, sin agua navegable ni huecos donde caer.

#### 3. Emplazamiento del pueblo (copia)

* Copiar el pueblo existente sobre la meseta, con el terreno aplanado debajo.
* Conservar en la copia: spawn, vendors, Guía de la Helada, NPC de subasta y sus `ProximityPrompt`.
* Suelo del pueblo al mismo nivel que puertas y umbrales; sin escalones invisibles.
* La copia no debe registrarse dos veces en servicios que asumen un único NPC (quests, subasta, vendors).

#### 4. Zona Helada y entrada a la dungeon

* Zona de hielo cercana, visible desde el camino.
* Copia del **portal/matchmaking** sobre plataforma estable, con prompt funcional para el tester.
* Ambientación: hielo, cristales, niebla fría y luz azulada.
* Transición pueblo → zona Helada caminando, sin teleport ni carga.

#### 5. Iluminación (crítica por estar en el mismo place)

* `Lighting` y `Atmosphere` son **globales**; no se pueden cambiar por región sin afectar el Hub.
* Implementar el cambio de atmósfera **en el cliente** con un trigger de la zona PoC: al entrar, interpolar niebla, color y brillo; al salir, restaurar los valores del Hub.
* Prohibido cambiar `Lighting` desde el servidor: afectaría a todos los jugadores del place.
* Sin ciclo día/noche en la PoC.

#### 6. Navegación y seguridad

* Recorrido principal sin saltos obligatorios ni paredes invisibles que confundan.
* Bordes con montañas o barreras suaves; sin caídas letales ni pozos junto al camino.
* El jugador no puede salir del mapa ni quedar atrapado entre geometría y terreno.
* `SpawnLocation` de la copia sobre la meseta, orientado hacia el camino.

#### 7. Rendimiento

* Sin generación de terreno en tiempo de ejecución durante el juego.
* Vigilar memoria de voxels, cantidad de instancias, NPCs y luces.
* Objetivo móvil de gama media: sin caídas críticas y con carga razonable al acercarse a la región.

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Hub intacto

* **GIVEN** el place abierto en juego normal
* **WHEN** un jugador juega en el Hub actual
* **THEN** no ve terreno, NPCs ni portal del PoC, y su experiencia no cambia

#### Escenario 2: Acceso controlado

* **GIVEN** un tester con `WorldPoC` y teleport de debug
* **WHEN** entra a la región PoC
* **THEN** los prompts de la copia funcionan solo para él y el resto de jugadores sigue igual

#### Escenario 3: Llegada al pueblo

* **GIVEN** el tester en el PoC
* **WHEN** aparece
* **THEN** está sobre la meseta, con el camino a la Helada visible

#### Escenario 4: Recorrido continuo

* **GIVEN** el tester en el pueblo
* **WHEN** camina hacia la zona Helada
* **THEN** llega sin cargas, sin saltos obligatorios y sin quedar atrapado
* **AND** cruza el lago helado sin caerse ni hundirse

#### Escenario 5: Sistemas existentes

* **GIVEN** el tester en el pueblo o la zona Helada
* **WHEN** interactúa con vendors, Guía, subasta y el portal
* **THEN** responden como en el Hub y el portal inicia el flujo de dungeon

#### Escenario 6: Iluminación local

* **GIVEN** el tester entrando y saliendo de la región PoC
* **WHEN** cruza el trigger de atmósfera
* **THEN** la niebla/luz cambia solo para él y el Hub mantiene su iluminación

#### Escenario 7: Límites

* **GIVEN** el tester explorando los bordes
* **WHEN** intenta salir del mapa
* **THEN** el relieve o las barreras lo contienen sin caídas ni softlocks

#### Escenario 8: Rendimiento móvil

* **GIVEN** un dispositivo móvil de gama media
* **WHEN** recorre pueblo, camino y zona Helada
* **THEN** no hay caídas críticas de FPS ni errores de streaming

---

### Alcance

#### Incluye

* Región PoC de terreno generado en el mismo place, aislada y no accesible por juego normal.
* 2048×2048 studs con meseta, camino, zona Helada, lago helado y montañas.
* Copias controladas de pueblo, NPCs, spawn y portal con prompts bajo `WorldPoC`.
* Atmósfera local por cliente.
* Pruebas de navegación y rendimiento móvil.

#### No incluye

* Modificar o reemplazar el Hub publicado.
* Arte final, nuevos NPCs, nuevas quests ni cambios de dungeon.
* Ciclo día/noche, clima dinámico ni agua navegable.
* Optimización profunda de VFX o UI.

---

### Definition of Done (DoD)

* [ ] Región PoC a 2048×2048 en el mismo place, a ≥8.000 studs del Hub y sin tocar la zona actual.
* [ ] Streaming impide cargar el PoC desde el Hub y viceversa.
* [ ] Acceso solo por teleport de debug; las copias de NPCs/portal solo se activan con `WorldPoC`.
* [ ] Meseta del pueblo plana y estable; spawn y copias de NPCs funcionando.
* [ ] Camino transitable pueblo → zona Helada; portal operativo para el tester.
* [ ] Lago helado transitable, sin caídas ni hundimiento.
* [ ] Atmósfera local por cliente; `Lighting` del servidor intacto.
* [ ] Bordes contenidos sin caídas letales ni softlocks.
* [ ] Sin errores rojos; rendimiento móvil verificado.

---

### Estimación (orientativa)

4–6 sesiones: generación y esculpido de 16 regiones, emplazamiento del pueblo y portal, atmósfera local, navegación y pruebas móviles.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-11-03 | Decisiones PO: mismo place en región vacía separada; lago helado sí; escala mayor con objetivo 2048×2048. Se añaden aislamiento, `WorldPoC` y atmósfera local por cliente. |
| 2026-11-03 | Creación de HU-R6.48: PoC de mapa de terreno con pueblo y zona Helada en un place aislado, para validar pipeline, navegación, rendimiento móvil y encaje de los sistemas existentes. |
