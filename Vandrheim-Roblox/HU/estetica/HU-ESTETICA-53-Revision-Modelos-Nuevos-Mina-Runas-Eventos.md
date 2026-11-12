# HU-ESTETICA-53: Revisión de modelos nuevos — mina, runas, naufragio, eventos y maestría (diseño/PO)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Arte / Mundo / Assets
**Prioridad:** Media — habilitador visual de R6.55, R6.56, R6.60 y R6.61
**Estado:** Abierta — lista para revisión
**Tipo:** Revisión y aprobación de modelos/assets (diseño + PO; sin código)
**Fase GDD:** Arte / Mundo / Hub
**Depende de:** HU-R6.55 (mina), HU-R6.56 (piedras/naufragio), HU-R6.60 (cosméticos de maestría), HU-R6.61 (caravanas/campamentos), HU-ESTETICA-52 (proceso de revisión), `ASSETS_POLICY`
**Componentes observados:** modelos de mina, piedras rúnicas, naufragio, caravana/campamento, cosméticos de clase, `Workspace.TestPlace`, `ASSETS_REGISTRY`
**No modifica:** gameplay, stats, quests, economía, combate, dungeon ni UI núcleo.

---

### Narrativa (INVEST)

**Como** diseñador/PO,
**quiero** revisar y aprobar los modelos nuevos de mina, runas, naufragio, eventos y cosméticos,
**para** que las nuevas actividades se vean coherentes y rindan en móvil sin frenar a los devs.

**Como** dev,
**quiero** una lista cerrada de assets aprobados con escala, pivote y presupuesto,
**para** integrar los modelos en R6.55/R6.56/R6.60/R6.61 sin rehacer trabajo.

---

### Descripción / Contexto

Las HUs de dopamina y mundo agregan actividades que necesitan assets nuevos o variantes. Esta HU es la **compuerta de revisión visual**:

* No implementa gameplay ni código.
* Revisa el paquete producido/propuesto por el diseñador o `DesignAgent`.
* Define qué se reutiliza y qué se produce.
* Entrega listas aprobadas a R6.55, R6.56, R6.60 y R6.61.
* Los devs pueden avanzar con placeholders; esta HU no bloquea la lógica, solo el arte final.

**Criterio de hecho global:** existe un paquete de revisión con screenshots, escala, triángulos, texturas y pivotes; cada asset tiene dictamen; los aprobados quedan registrados en `ASSETS_REGISTRY` y listos para integrarse; los rechazados no se usan.

---

### Especificaciones Técnicas / Contratos

#### 1. Alcance de assets

**Mina Helada (R6.55) — P0:**

* Veta de hierro y veta de escarcha (2 variantes).
* Pico/herramienta visual de minería.
* Entrada de mina/cartel (si no se reutiliza el POI de R6.53).
* Lámparas, vigas, cajas y escombros de mina.
* Props de cueva: piedras, nieve, vagoneta opcional.

**Red rúnica (R6.56) — P0:**

* Piedra rúnica de Valgard.
* Piedra rúnica de dungeon/portal.
* Piedra rúnica de naufragio.
* Naufragio: casco, mástil, cajas, cuerdas y hielo.
* VFX de activación (si no se reutiliza uno existente).

**Maestría de clase (R6.60) — P1:**

* Emblema de Paladín/Cazador/Clérigo.
* Estandarte/aura cosmética por clase.
* Variante cosmética de arma/armadura de clase, si aplica.
* No debe verse como una ventaja de combate.

**Eventos de mundo (R6.61) — P0/P1:**

* Carro de caravana.
* Toldos, cajas, barriles y estandartes de caravana.
* Campamento enemigo: tiendas, empalizada, cajas, fogata y jaulas.
* Props de daño/ruina para caravana atacada.

**Fuera de alcance:**

* Enemigos, jefes, armas funcionales, armaduras con stats, UI, iconos, animaciones nuevas o audio.
* Modelos de la dungeon de 5 pisos y de la expansión de fuego.

#### 2. Formato de entrega

Cada modelo o conjunto debe incluir:

* Modelo en Studio (`Workspace.TestPlace` o carpeta de revisión).
* Nombre canónico sin espacios.
* `PrimaryPart` definido; pivote en la base y al centro; frente hacia `-Z`.
* `Anchored=true`; colisión definida según uso.
* Screenshots: frente, lateral, superior y escala con R15 de jugador.
* Triángulos y tamaño de texturas.
* Fuente/licencia; si es IA/Toolbox, indicarlo.
* Notas de integración: HU destino, ubicación, colisión y si requiere VFX.

#### 3. Criterios de aprobación

| Criterio | Regla |
|---|---|
| Estilo | Nórdico, low-poly/pintado, paleta fría de Vandrheim |
| Escala | R15 ~5 studs; piedras/props proporcionales a puertas y jugador |
| Geometría | Sin agujeros, caras invertidas, z-fighting ni piezas flotantes |
| Presupuesto piedra | ≤3k triángulos; textura ≤512 |
| Presupuesto veta | ≤2k triángulos; textura ≤512 |
| Presupuesto naufragio | ≤15k triángulos; reutilizar props |
| Presupuesto caravana/campamento | ≤12k triángulos por conjunto; props reutilizables |
| Cosméticos | ≤8k triángulos; sin stats; legibles en móvil |
| Colisión | Pequeños: `CanCollide=false`; grandes: simple y sin bloquear rutas/prompts |
| Naming | `Prop_Mina_*`, `Prop_Runa_*`, `POI_Naufragio_*`, `Prop_Caravana_*`, `Prop_Campamento_*`, `Cosmetic_Mastery_*` |
| Licencia | Propia/comprada/compatible; autor y fuente registrados |
| Legibilidad | Se reconoce a distancia; no se confunde con enemigo, portal o vendor |

#### 4. Proceso de revisión

1. Inventario de assets existentes reutilizables.
2. Paquete del diseñador/`DesignAgent` con formato de §2.
3. Revisión visual de estilo, escala y legibilidad.
4. Revisión técnica de triángulos, texturas, pivote, colisión y naming.
5. Dictamen: `Aprobado`, `Aprobado con cambios`, `Rechazado` o `Pendiente`.
6. Registro de aprobados en `ASSETS_POLICY`/`ASSETS_REGISTRY`.
7. Handoff a las HUs consumidoras; placeholders hasta entonces.

#### 5. Integración y rendimiento

* Los assets deben funcionar con `StreamingEnabled` y no duplicar geometría.
* Compartir texturas/materiales cuando sea posible.
* No crear mallas gigantes para props pequeños.
* Las piedras rúnicas y el naufragio no deben tapar caminos, prompts ni cámaras.
* Los cosméticos de maestría no deben afectar la silueta de combate ni confundirse con buffs.
* Los campamentos/caravanas no deben superar el presupuesto de la zona.

#### 6. UI/UX visual

* La mina debe leerse como mina, no como dungeon instanciada.
* Las piedras rúnicas deben verse antiguas y mágicas, no como un menú de teleport.
* El naufragio debe ser un landmark visible desde el camino.
* La caravana y los campamentos deben reforzar la sensación de mundo vivo.
* Los cosméticos de maestría deben ser aspiracionales y claramente cosméticos.

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Paquete completo

* **GIVEN** el paquete de modelos para las HUs consumidoras
* **WHEN** se revisa
* **THEN** incluye screenshots, escala, triángulos, texturas y pivote
* **AND** cada asset tiene uso y naming documentados

#### Escenario 2: Estilo y escala

* **GIVEN** un asset candidato
* **WHEN** se compara con el mundo y un R15
* **THEN** el estilo y la escala son coherentes
* **AND** no se confunde con enemigo, portal o vendor

#### Escenario 3: Presupuesto

* **GIVEN** un asset candidato
* **WHEN** se revisan sus métricas
* **THEN** cumple el presupuesto de §3
* **AND** no compromete el rendimiento móvil

#### Escenario 4: Dictamen y registro

* **GIVEN** un asset revisado
* **WHEN** el PO/PM emite el dictamen
* **THEN** queda aprobado/rechazado/pendiente con notas
* **AND** los aprobados se registran en `ASSETS_REGISTRY`

#### Escenario 5: Handoff

* **GIVEN** un asset aprobado
* **WHEN** se entrega a R6.55/R6.56/R6.60/R6.61
* **THEN** el dev sabe dónde va, qué escala tiene y qué colisión usar
* **AND** no se integra arte no aprobado

#### Escenario 6: Sin código

* **GIVEN** esta HU
* **WHEN** se ejecuta
* **THEN** no se modifica gameplay, stats, quests ni economía
* **AND** no se crean scripts de producción

---

### Comportamiento Visual / UI-UX

* La revisión prioriza legibilidad y coherencia sobre detalle.
* Un asset lindo pero fuera de escala o pesado se rechaza.
* Los props deben verse parte del mundo, no pegados.
* Los cosméticos de maestría no deben sugerir poder.

---

### Alcance

#### Incluye

* Lista de assets para mina, runas, naufragio, eventos y maestría.
* Criterios de estilo, escala, presupuesto, colisión, naming y licencia.
* Proceso de dictamen y registro.
* Handoff a las HUs consumidoras.

#### No incluye

* Producción de código o gameplay.
* Enemigos, jefes, armas/armaduras funcionales, UI, iconos, animaciones o audio.
* Integración final; eso lo hacen las HUs consumidoras.
* Assets de la expansión de fuego.

---

### Definition of Done (DoD)

* [ ] Inventario de assets reutilizables.
* [ ] Paquete P0 con screenshots, escala, métricas y pivote.
* [ ] Dictamen por asset.
* [ ] Aprobados registrados en `ASSETS_REGISTRY`.
* [ ] Rechazados documentados y fuera de las HUs.
* [ ] Handoff a R6.55/R6.56/R6.60/R6.61.
* [ ] Sin cambios de código.

---

### Decisiones por defecto

| Tema | Default |
|---|---|
| Mina | Vetas, pico, lámparas, cajas, entrada |
| Runas | 3 piedras + activación |
| Naufragio | Casco, mástil, cajas, cuerdas, hielo |
| Eventos | Carro, toldos, cajas, campamento, empalizada |
| Maestría | Emblema, estandarte/aura y variante cosmética |
| Revisión | PO/PM + dev técnico |
| Escala | R15 ~5 studs; props proporcionales |
| Registro | Obligatorio en `ASSETS_REGISTRY` |
| Handoff | A HUs consumidoras; sin código aquí |

---

### Estimación (orientativa)

1–2 sesiones de revisión, más producción del diseñador/`DesignAgent`. Las HUs consumidoras usan placeholders hasta la aprobación.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-11-12 | Creación de HU-ESTETICA-53: revisión de modelos nuevos para mina, piedras rúnicas, naufragio, caravanas/campamentos y cosméticos de maestría, con criterios de escala, presupuesto, naming, registro y handoff. |
