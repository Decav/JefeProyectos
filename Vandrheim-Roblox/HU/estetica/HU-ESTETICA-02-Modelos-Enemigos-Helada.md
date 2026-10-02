## HU-ESTETICA-02: Modelos de los enemigos de la Helada (por piso)

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** Assets / Modelos / EST-02  
**Prioridad:** Alta  
**Estado:** Lista para implementar  
**Tipo:** Producción de modelos 3D (diseñador de assets)  
**Fase GDD:** Épica transversal `EST-02` (paralela a R6.x/R7; no bloquea gameplay)  
**Rol responsable:** Diseñador de assets — **exclusivamente modelos** (sin scripts, sin código, sin animaciones)  
**Depende de:** HU-ASSETS (estructura/naming/política), `EnemyConfig` (plantillas por piso), modelos existentes `helada_ice_mite` y `helada_frost_wolf` (referencia de estructura)  
**Integración (dev, tarea mínima aparte):** agregar `modelId` en `EnemyConfig` para cada plantilla + registrar en `ASSETS_REGISTRY`

---

### **Narrativa (INVEST)**

**Como** diseñador de assets,  
**quiero** crear los modelos 3D de todos los enemigos de la Helada que aún no existen, siguiendo una estructura estándar compatible con el juego,  
**para** que un desarrollador pueda usarlos directamente (solo referenciándolos por config) sin tocar código de gameplay.

**Como** jugador,  
**quiero** ver enemigos distintos y reconocibles en cada piso,  
**para** que la mazmorra no se sienta repetitiva y cada piso tenga identidad visual.

---

### **Descripción del Requerimiento / Contexto**

Estado actual verificado:

* `ReplicatedStorage.Assets.Models.Enemies` contiene solo 2 modelos: `helada_ice_mite` y `helada_frost_wolf`.
* `EnemyConfig` define las plantillas por piso y mini-bosses; la mayoría no tiene `modelId`, por lo que `EnemyService` cae al placeholder procedural.

Esta HU entrega **exclusivamente los modelos 3D** del resto de enemigos. No incluye programación: el dev solo deberá enlazar cada plantilla con su modelo mediante `modelId` (tarea de integración documentada al final).

Los modelos deben ser compatibles con `EnemyService` (que clona el modelo, configura el `Humanoid` y lo mueve con IA). La referencia estructural es el modelo existente `helada_ice_mite` (rig con `Humanoid` + `HumanoidRootPart`, partes soldadas y piezas decorativas sin colisión).

---

### **Especificaciones Técnicas / Contratos**

#### **1. Lista de modelos a crear**

Los modelos deben nombrarse **exactamente igual** que el `templateId` de `EnemyConfig`:

| # | Modelo (`modelId` = nombre del template) | Nombre display | Piso | Rol | Tipo |
|---|------------------------------------------|----------------|------|-----|------|
| 1 | `helada_frost_archer` | Arquera helada | 2 | Ranged | Base nueva |
| 2 | `helada_frost_troll` | Trol de escarcha | 1 | Mini-boss | Base nueva |
| 3 | `helada_ice_golem` | Gólem de hielo | 2 | Mini-boss | Base nueva |
| 4 | `helada_blizzard_wraith` | Espectro de ventisca | 3 | Mini-boss | Base nueva |
| 5 | `helada_ice_elemental` | Elemental de hielo | 4 | Ranged | Base nueva |
| 6 | `helada_frost_knight` | Caballero helado | 4 | Melee | Base nueva |
| 7 | `helada_frost_lord` | Señor de la escarcha | 4 | Mini-boss | Base nueva |
| 8 | `helada_ice_mite_elite` | Ácaro de escarcha élite | 2 | Variante | Recolor de `helada_ice_mite` |
| 9 | `helada_frost_wolf_elite` | Lobo helado élite | 3 | Variante | Recolor de `helada_frost_wolf` |
| 10 | `helada_frost_archer_elite` | Arquera helada élite | 3 | Variante | Recolor de `helada_frost_archer` |
| 11 | `helada_ice_elemental_elite` | Elemental de hielo élite | 5 | Variante | Recolor de `helada_ice_elemental` |
| 12 | `helada_frost_knight_elite` | Caballero helado élite | 5 | Variante | Recolor de `helada_frost_knight` |

Reglas de variantes élite:

* Se crean como modelos **separados** (mismo rig y silueta que su base) con recolor más frío/intenso y, opcionalmente, leve aumento de escala (≤15%).
* Deben ser distinguibles del normal en el juego (tinte azulado más saturado o detalle extra de hielo).
* No duplicar el modelo base: se parte de un clon limpio.

Fuera de esta HU (entregas futuras):

* Boss del piso 5 (`helada_frostwarden`) — acompaña a R7.
* Objetos/props, cofres, armas y equipo visual (EST-01) — HUs separadas.

#### **2. Requisitos estructurales obligatorios (compatibilidad con EnemyService)**

Cada modelo debe cumplir:

* `Model` raíz con `Name = templateId` y `PrimaryPart = HumanoidRootPart`.
* Un `Humanoid` como hijo directo (stats los setea el server; no fijar `MaxHealth` ni `WalkSpeed` de forma que interfieran).
* `HumanoidRootPart` (Part) con `Anchored=false` y colisión principal.
* Todas las demás piezas soldadas al rig (`Weld` o `WeldConstraint`) — **sin partes sueltas**.
* Piezas decorativas: `CanCollide=false`, `CanTouch=false`, `CanQuery=false`.
* Piezas pequeñas: `Massless=true` para estabilidad física.
* Todas las partes `Anchored=false` (el modelo se mueve con `Humanoid:MoveTo`).
* **Sin scripts** (ni LocalScript ni Script) dentro del modelo.
* **Sin animaciones propias** ni `AnimationController`: el movimiento lo maneja el `Humanoid` del juego.
* **Sin** `Sound`, `ParticleEmitter`, `Trail` ni efectos (VFX es de otra fase).
* Altura/hipheight razonable para terreno de piso; evitar colisiones que empujen al jugador.
* `Humanoid:SetStateEnabled` y configuraciones de IA quedan del lado del server (EnemyService), no del modelo.

Referencia de estructura: inspeccionar `helada_ice_mite` (rig, welds y jerarquía).

#### **3. Estética Vandrheim (Helada)**

* Paleta: fríos, azules, hielo, nieve; acentos oscuros para mini-bosses (ej. morado/gris pizarra en `blizzard_wraith`).
* Siluetas legibles desde la cámara 3ª persona; cada familia debe diferenciarse:
  * Arquera: humanoides delgados, arco/capucha de hielo.
  * Trol: cuerpo pesado, mandíbulas, cuernos de hielo.
  * Gólem: bloque/piedra helada, lento e imponente.
  * Espectro: translúcido/flotante, ventisca, sin piernas sólidas.
  * Elemental: núcleo brillante, brazos de hielo, flotante.
  * Caballero: placas heladas, espada/escudo de escarcha.
  * Señor: tamaño grande, corona/capa de hielo.
* Mini-bosses: más grandes y detallados que los normales, sin exceder presupuesto.
* Estilo estilizado/liviano para MVP; no calidad AAA ni meshes ultra densos.
* Se pueden usar `MaterialVariant` existentes del tema (`Mat_hielo`, `Mat_nieve`, etc.) o nuevos creados por el diseñador.

#### **4. Naming y ubicación**

* Carpeta: `ReplicatedStorage.Assets.Models.Enemies`.
* `modelId` = nombre del template en `EnemyConfig` (snake_case en inglés) — **sin guiones ni espacios**.
* Mantener los 2 modelos existentes intactos (no renombrar, no reestructurar).
* No dejar copias sueltas en `Workspace.GFX` ni en otras carpetas.

#### **5. Integración (tarea del dev, NO del diseñador)**

Después de que el diseñador entregue los modelos:

* Agregar `modelId = "<templateId>"` en `EnemyConfig` para: `helada_frost_archer`, `helada_frost_troll`, `helada_ice_golem`, `helada_blizzard_wraith`, `helada_ice_elemental`, `helada_frost_knight`, `helada_frost_lord` y las 5 variantes élite.
* Verificar `DebugSpawnEnemy` en la arena: cada modelo spawnea con IA sin errores rojos.
* Registrar cada modelo en `ASSETS_REGISTRY` (fuente: diseñador/producción propia).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Modelos entregados**

* **GIVEN** la lista de 12 modelos requeridos
* **WHEN** se inspecciona `ReplicatedStorage.Assets.Models.Enemies`
* **THEN** cada modelo existe con el nombre exacto de su `templateId`
* **AND** los 2 modelos existentes no fueron modificados

#### **Escenario 2: Estructura válida**

* **GIVEN** un modelo entregado
* **WHEN** se valida su jerarquía
* **THEN** tiene `Humanoid`, `HumanoidRootPart` y `PrimaryPart` correctos
* **AND** todas las piezas están soldadas
* **AND** las piezas decorativas tienen colisión/canquery/cantouch desactivados

#### **Escenario 3: Sin scripts**

* **GIVEN** un modelo entregado
* **WHEN** se revisan sus descendientes
* **THEN** no contiene Script, LocalScript, AnimationController ni efectos de sonido/partículas

#### **Escenario 4: Elites distinguibles**

* **GIVEN** una variante élite y su modelo base
* **WHEN** se comparan visualmente
* **THEN** se distinguen por recolor (y opcional escala leve)
* **AND** comparten la misma estructura/silhouette

#### **Escenario 5: Spawn en la arena (post-integración)**

* **GIVEN** los `modelId` enlazados en `EnemyConfig`
* **WHEN** se usa `DebugSpawnEnemy` con cada template
* **THEN** cada enemigo aparece con su modelo real
* **AND** la IA (melee/ranged) y la muerte funcionan sin errores rojos

#### **Escenario 6: Física estable**

* **GIVEN** los enemigos spawneados
* **WHEN** persiguen y atacan al jugador
* **THEN** no arrastran piezas sueltas ni empujan al jugador
* **AND** no interfieren con respawn ni con el piso generado

#### **Escenario 7: Presupuesto**

* **GIVEN** la escena con packs de enemigos
* **WHEN** se revisa el rendimiento
* **THEN** no se generan errores de streaming ni de física
* **AND** los modelos son livianos (sin meshes excesivos)

---

### **Comportamiento Visual / Reglas de Negocio**

* El modelo es 100% visual: no define stats, daño, XP ni loot (eso vive en `EnemyConfig`).
* La silueta por familia debe leerse a distancia de combate.
* Mini-bosses y élites deben verse "más peligrosos" que los normales.
* Un modelo mal estructurado (partes sueltas/scripts) se rechaza en revisión antes de integrarse.

---

### **Alcance**

#### Incluye

* 7 modelos base nuevos.
* 5 variantes élite (recolor de sus bases).
* Estructura estándar compatible con `EnemyService`.
* Uso de materiales/paleta Helada.
* Ubicación y naming según `EnemyConfig`.

#### No incluye

* Scripts, código, remotes o lógica (lo hace el dev).
* Animaciones, rigging de animación o `AnimationController`.
* Boss del piso 5 (`helada_frostwarden` → R7).
* Objetos, props, cofres, armas, armaduras o equipo visual (EST-01 / HUs futuras).
* Iconos, UI, VFX o SFX.
* Modelos de otras mazmorras/clases.

---

### **Definition of Done (DoD)**

* [ ] Los 12 modelos existen en `ReplicatedStorage.Assets.Models.Enemies` con el nombre del `templateId`.
* [ ] Cada modelo cumple la estructura (Humanoid, HRP, PrimaryPart, welds, sin colisión decorativa).
* [ ] Sin scripts ni animaciones dentro de los modelos.
* [ ] Elites distinguibles de sus bases.
* [ ] Paleta Helada y silueta por familia respetadas.
* [ ] Los 2 modelos originales intactos.
* [ ] (Dev) `EnemyConfig` enlaza todos los `modelId`.
* [ ] (Dev) Cada template spawnea en la arena sin errores rojos.
* [ ] Modelos registrados en `ASSETS_REGISTRY`.
* [ ] Nota `EST-02 completo` en GDD tras verificación.

---

### **Estimación (orientativa)**

4–6 sesiones de modelado (7 bases + 5 elites), según complejidad por familia y ajuste de estructura.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-25 | Creación de HU-ESTETICA-02: modelos de enemigos de la Helada (7 bases + 5 elites); rol diseñador, solo modelos |