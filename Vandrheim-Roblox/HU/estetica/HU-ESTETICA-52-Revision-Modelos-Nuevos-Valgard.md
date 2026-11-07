# HU-ESTETICA-52: Revisión de modelos nuevos para Valgard vivo y caminos (diseño/PO)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Arte / Mundo / Assets
**Prioridad:** Media — habilitador visual de HU-R6.53; no bloqueante para la lógica
**Estado:** Aprobada y entregada a HU-R6.53
**Tipo:** Revisión y aprobación de modelos/assets (diseño + PO; sin código)
**Fase GDD:** Arte / Hub / Mundo
**Depende de:** HU-R6.49 (mapa/Hub), HU-R6.52 (NPCs ambientales), HU-R6.53 (consumidor), HU-ESTETICA-26/27/28 (pueblo y NPCs existentes), `ASSETS_POLICY`
**Componentes observados:** modelos R15, props de Valgard, POIs, fauna pasiva, `Workspace.TestPlace`, `ASSETS_REGISTRY`, `HU-R6.53`
**No modifica:** gameplay, stats, quests, economía, vendors, inventario, UI núcleo ni dungeon.

---

### Narrativa (INVEST)

**Como** diseñador/PO,
**quiero** revisar y aprobar los modelos nuevos de NPCs, props, POIs y fauna antes de integrarlos,
**para** mantener el estilo, la escala y el rendimiento de Vandrheim sin frenar la implementación de HU-R6.53.

**Como** dev,
**quiero** una lista cerrada de modelos aprobados, con notas y presupuesto,
**para** integrar arte final sin adivinar qué asset usar ni rehacer trabajo.

---

### Descripción / Contexto

HU-R6.53 agrega vida a Valgard y sus caminos con NPCs con roles, microescenas, props, POIs y coleccionables. Esta HU es la **compuerta de revisión visual** de los modelos nuevos necesarios:

* No implementa gameplay ni código.
* Revisa el paquete de modelos producido/propuesto por el diseñador o `DesignAgent`.
* Define qué modelos son necesarios, cuáles se reutilizan y cuáles se rechazan.
* Entrega a HU-R6.53 una lista aprobada con notas de integración.
* HU-R6.53 puede avanzar con placeholders R15 y props existentes; esta revisión no bloquea la lógica, solo el arte final.

**Criterio de hecho global:** existe un paquete de revisión con screenshots, escala, conteo de triángulos, texturas y pivotes; cada modelo tiene estado Aprobado, Aprobado con cambios, Rechazado o Pendiente; los aprobados quedan registrados en `ASSETS_REGISTRY` y listos para que HU-R6.53 los integre; los rechazados no se integran.

---

### Especificaciones Técnicas / Contratos

#### 1. Alcance de modelos a revisar

**NPCs (prioridad P0):**

| Modelo | Uso | Variantes |
|---|---|---:|
| Guardia de Valgard | Puerta y patrulla | 2 |
| Ayudante de herrería | Microescena de forja | 1 |
| Ayudante de alquimia | Microescena de alquimia | 1 |
| Vendedor de mercado | Puesto de mercado | 1 |
| Tabernero | Exterior de taberna | 1 |
| Niño/a | Plaza y juego | 2 |
| Perro | Compañero de los niños | 1 |

**Props (prioridad P0):**

* Fogata, carro, barriles, cajas, leña, rack de secado, montículo de nieve, cartel, banco, farol, banderín y herramientas de forja.
* Reutilizar primero los props existentes de HU-ESTETICA-26/27/28 y del mapa nuevo.

**POIs (prioridad P0):**

* Campamento de viajeros, carro volcado, santuario menor, entrada de cueva, mirador del lago y runa antigua.
* Cada POI puede ser una composición de props aprobados; no requiere un modelo único si el conjunto funciona.

**Fauna pasiva (prioridad P1, opcional):**

* Conejo, ave y ciervo; solo si el presupuesto de rendimiento lo permite.

**Fuera de alcance:**

* Enemigos, jefes, armas, armaduras, UI, iconos, animaciones nuevas, VFX nuevos y audio.
* Modelos de dungeon o de otras zonas.

#### 2. Formato de entrega

Cada modelo o conjunto debe entregarse con:

* Archivo/modelo en Studio (`Workspace.TestPlace` o carpeta de revisión acordada), no en el repo local.
* Nombre canónico sin espacios.
* `PrimaryPart` definido; pivote en la base y al centro; frente hacia `-Z`.
* `Anchored=true`; colisiones configuradas según uso.
* Screenshots: frente, lateral, superior y una comparación de escala con un R15 de jugador.
* Conteo de triángulos y tamaño de texturas.
* Origen/licencia del asset; si es generado por IA o Toolbox, indicarlo.
* Notas de integración: dónde se usa, qué animación/idle requiere y qué colisión debe tener.

#### 3. Criterios de aprobación

| Criterio | Regla |
|---|---|
| Estilo | Nórdico, low-poly/pintado, paleta fría de Vandrheim; coherente con el pueblo y el mapa nuevo |
| Escala | R15 de referencia (~5 studs); props proporcionales a puertas, bancos y jugador; perro ~1.5–2 studs |
| Geometría | Sin agujeros, caras invertidas, z-fighting ni piezas flotantes; pivote correcto |
| Presupuesto NPC | ≤12k triángulos por variante; textura ≤512; sin accesorios innecesarios |
| Presupuesto props | ≤3k triángulos por prop; textura ≤512; sin física compleja |
| Presupuesto POI | ≤15k triángulos por conjunto; reutilizar props; sin mallas gigantes |
| Fauna | ≤3k triángulos por animal; rig simple; sin combate |
| Rendimiento | Sin sombras costosas innecesarias, partículas excesivas ni materiales únicos por prop |
| Colisión | Pequeños: `CanCollide=false`; grandes: colisión simple y sin bloquear rutas/prompts |
| Naming | `NPC_Ambient_*`, `Prop_Valgard_*`, `POI_*`, `Fauna_*`; sin espacios ni sufijos de prueba |
| Licencia | Asset propio, comprado o con licencia compatible; registrar autor/fuente |
| Legibilidad | El modelo se reconoce a distancia y no se confunde con enemigo, vendor o portal |
| Animación | R15 con `Humanoid`/`Animator` cuando corresponda; usar animaciones existentes, no crear nuevas |

#### 4. Proceso de revisión

1. **Inventario:** listar assets existentes reutilizables antes de producir nuevos.
2. **Paquete:** el diseñador/`DesignAgent` entrega los modelos con el formato de §2.
3. **Revisión visual:** PO/PM revisa estilo, escala, legibilidad y coherencia en Studio.
4. **Revisión técnica:** dev o PM técnico valida triángulos, texturas, pivote, colisión y naming.
5. **Dictamen:** cada modelo queda como `Aprobado`, `Aprobado con cambios`, `Rechazado` o `Pendiente`, con notas concretas.
6. **Registro:** los aprobados se registran en `ASSETS_POLICY`/`ASSETS_REGISTRY`; los rechazados no se integran.
7. **Handoff:** HU-R6.53 recibe la lista aprobada y reemplaza placeholders sin cambiar lógica.

#### 5. Estados y prioridades

* **P0:** NPCs, props y POIs necesarios para las 5 microescenas y los 6 POIs.
* **P1:** fauna pasiva y variantes extra.
* **P2:** modelos de detalle que no afectan la lectura del mundo; se pueden diferir.
* Un modelo `Pendiente` no bloquea HU-R6.53 si hay placeholder aceptable.
* Un modelo `Rechazado` no se integra; si es P0, se reemplaza por un placeholder o se solicita una nueva versión.

#### 6. Integración y rendimiento

* Los modelos aprobados deben funcionar con `StreamingEnabled` y no duplicar geometría en el Hub.
* No crear texturas/materiales únicos por prop si se pueden compartir.
* Evitar mallas con miles de partes; usar unions/meshes solo cuando aporten.
* Los POIs no deben superar el presupuesto ni tapar rutas, prompts o cámaras.
* La fauna no debe requerir pathfinding complejo ni colisión con el jugador.
* Cualquier asset nuevo se registra antes de integrarse; sin registro, no se aprueba.

#### 7. UI/UX visual

* Los NPCs ambientales no deben parecer vendors ni enemigos: sin prompt, sin icono, sin armas de combate.
* Los POIs deben leerse como lugares, no como dungeons ni portales.
* Los props deben reforzar el asentamiento nórdico, no llenar el mapa de objetos porque sí.
* La escala del jugador es la referencia principal; un modelo fuera de escala se rechaza.

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Paquete completo

* **GIVEN** el paquete de modelos para HU-R6.53
* **WHEN** se revisa
* **THEN** incluye screenshots, escala con R15, triángulos, texturas y pivote
* **AND** cada modelo tiene nombre y uso documentados

#### Escenario 2: Estilo y escala

* **GIVEN** un modelo candidato
* **WHEN** se compara con el pueblo y un R15
* **THEN** el estilo y la escala son coherentes
* **AND** no se confunde con enemigo, vendor o portal

#### Escenario 3: Presupuesto

* **GIVEN** un modelo candidato
* **WHEN** se revisan sus métricas
* **THEN** cumple el presupuesto de triángulos y texturas de §3
* **AND** no compromete el rendimiento móvil

#### Escenario 4: Dictamen

* **GIVEN** un modelo revisado
* **WHEN** el PO/PM emite el dictamen
* **THEN** queda como Aprobado, Aprobado con cambios, Rechazado o Pendiente
* **AND** las notas son accionables

#### Escenario 5: Handoff

* **GIVEN** un modelo aprobado
* **WHEN** se entrega a HU-R6.53
* **THEN** está registrado en `ASSETS_REGISTRY`
* **AND** el dev sabe dónde va, qué escala tiene y qué colisión usar

#### Escenario 6: Sin código

* **GIVEN** esta HU
* **WHEN** se ejecuta
* **THEN** no se modifica gameplay, stats, quests ni economía
* **AND** no se crean scripts de producción

---

### Comportamiento Visual / UI-UX

* La revisión prioriza legibilidad y coherencia sobre cantidad de detalle.
* Un modelo lindo pero fuera de escala o que rompe el rendimiento se rechaza.
* Los POIs y props deben verse parte del mundo, no assets pegados.
* La fauna, si se aprueba, debe sentirse ambiental y no como enemigo.

---

### Alcance

#### Incluye

* Lista de modelos necesarios para HU-R6.53.
* Criterios de estilo, escala, presupuesto, colisión, naming y licencia.
* Proceso de revisión y dictamen.
* Registro de aprobados y handoff a HU-R6.53.
* Revisión de fauna P1.

#### No incluye

* Producción de código o gameplay.
* Animaciones, VFX, audio, UI o iconos nuevos.
* Modelos de enemigos, jefes, armas o armaduras.
* Integración final en el Hub; eso lo hace HU-R6.53.
* Aprobación automática de assets de Toolbox sin licencia.

---

### Definition of Done (DoD)

* [x] Inventario de assets existentes reutilizables.
* [x] Paquete de modelos P0 con screenshots, escala, métricas y pivote.
* [x] Cada modelo tiene dictamen y notas accionables.
* [x] Aprobados registrados en `ASSETS_POLICY`/`ASSETS_REGISTRY`.
* [x] Rechazados documentados y fuera de HU-R6.53 (niños y perro descartados por PO).
* [x] Handoff a HU-R6.53 con nombres, escala y colisión.
* [x] Fauna P1 revisada o diferida explícitamente.
* [x] Sin cambios de código ni gameplay.

---

### Decisiones por defecto

| Tema | Default |
|---|---|
| NPCs P0 | Guardias, herrería, alquimia, mercado, taberna (niños y perro descartados por PO) |
| Props P0 | Fogata, carro, barriles, cajas, leña, cartel, banco, farol, banderín, yunque, rack de secado, montículo nieve |
| POIs P0 | Campamento, carro volcado, santuario menor, cueva, mirador y runa |
| Fauna | P1 diferida |
| Escala | R15 ~5 studs; props proporcionales |
| Presupuesto NPC | ≤12k triángulos; textura ≤512 |
| Presupuesto prop | ≤3k triángulos; textura ≤512 |
| Revisión | PO/PM + dev técnico |
| Estados | Aprobado / Aprobado con cambios / Rechazado / Pendiente |
| Registro | Obligatorio en `ASSETS_REGISTRY` |
| Handoff | A HU-R6.53; sin código en esta HU |

---

### Estimación (orientativa)

1–2 sesiones de revisión, más el tiempo de producción del diseñador/`DesignAgent`. HU-R6.53 no se bloquea: usa placeholders hasta la aprobación.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-11-06 | Creación de HU-ESTETICA-52: compuerta de revisión de modelos nuevos para Valgard vivo y caminos (NPCs, props, POIs y fauna opcional), con criterios de escala, estilo, presupuesto, naming, registro y handoff a HU-R6.53. |
| 2026-11-06 | Entrega P0 de staging y assets en `Workspace.TestPlace` (Guardia con armadura y yelmo, Ayudante de herrería con delantal y guantes, 5 props de utilería nórdica y POI Campamento con tiendas de campaña). Documentado en `HU-ESTETICA-52-ENTREGA-DISENO.md`. |
| 2026-11-06 | Cierre formal de HU-ESTETICA-52: Staging completo en `Workspace.TestPlace` (6 NPCs R15 100% body skin, 14 props alineados con PrimaryPart y 6 POIs completos). Niños y perro descartados por diseño/PO; fauna pasiva diferida a P1. Generado documento final `HU-ESTETICA-52-ENTREGA-DISENO.md` y handoff a HU-R6.53. |
