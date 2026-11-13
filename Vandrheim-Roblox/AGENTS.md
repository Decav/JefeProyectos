# Protocolo SDD para Vandrheim-Roblox (Integrado con `Workspace.DevelopmentStandard` en Studio)

Este proyecto opera bajo el ecosistema **SDD con revisión adversarial** (especificador, constructor, cinco revisores y aprobador) definido en [`../AGENTS.md`](../AGENTS.md) y regido por [`../agents/REVIEW-PROTOCOL.md`](../agents/REVIEW-PROTOCOL.md), conectado de forma estricta con la arquitectura documental vigente dentro de **Roblox Studio (`Workspace.DevelopmentStandard`, establecida en `rc120`)** y gobernada por la skill [`skills/project-docs/SKILL.md`](./skills/project-docs/SKILL.md).

**Regla de formato:** Prohibido usar emojis o íconos decorativos en cualquier documento, RC, comentario Luau o dictamen.

---

## 1. Separación Estricta: Qué vive en el Proyecto Local (PM) vs. Qué vive en Roblox Studio (SDD / Dev)

| Tipo de Documentación | Dónde vive (Fuente Única de Verdad) | Quién lo mantiene |
| :--- | :--- | :--- |
| **Documentos de Producto (PM):**<br>- [`GDD_ROBLOX_MVP.md`](./GDD_ROBLOX_MVP.md)<br>- [`SKILLS_CATALOG.md`](./SKILLS_CATALOG.md)<br>- [`HU/`](./HU/), [`ROADMAP.md`](./ROADMAP.md), [`QUEST_SYSTEM.md`](./QUEST_SYSTEM.md), [`ITEMS_DESCRIPTIONS.md`](./ITEMS_DESCRIPTIONS.md), [`MONETIZATION.md`](./MONETIZATION.md) | **ÚNICAMENTE en el proyecto local (`Vandrheim-Roblox/`)**.<br>No deben existir ni consultarse copias de `GDD` ni de `SKILLS_CATALOG` dentro de Roblox Studio. | `PMAgent` / PO |
| **Plantilla de RC (`RC-TEMPLATE`):**<br>- [`RC-TEMPLATE.md`](./RC-TEMPLATE.md) (Local)<br>- `Workspace.DevelopmentStandard.RC-TEMPLATE` (Studio) | **Idéntica en ambos lados** (Local y Studio mantienen exactamente las mismas reglas y los 10 apartados obligatorios). | Compartido (Sincronizado) |
| **Documentación Técnica de Arquitectura, Esquemas y RCs:**<br>- `DEV_PROMPT`, `PROJECT_ARCHITECTURE`, `DEVELOPER_GUIDE`, `DATA_SCHEMA`, `PROJECT_STANDARD`<br>- `Architecture.<Dominio>` (9 dominios)<br>- `Schemas.<Dominio>` (6 dominios)<br>- `Requirement.<Categoria>.rc-...` + `Requirement.INDEX` | **ÚNICAMENTE dentro de Roblox Studio** en `Workspace.DevelopmentStandard` (vía MCP).<br>Prohibido crear archivos `.lua` o RCs en el proyecto local. | `SpecAgent`, `BuilderAgent` (auditados por los revisores y `ApproverAgent`) |

### Recorrido de Contexto Dirigido (Obligatorio para no saltar ni saturar documentación)
1. **Nivel 1 (Índices técnicos en Studio):**
   - `Workspace.DevelopmentStandard.DEV_PROMPT` (asignación vigente).
   - `Workspace.DevelopmentStandard.PROJECT_ARCHITECTURE` (mapa general de servicios y puntos de entrada).
   - `Workspace.DevelopmentStandard.DEVELOPER_GUIDE` (tabla Tipo de Tarea -> Mapa/Contrato -> Primeros puntos de código).
   - `Workspace.DevelopmentStandard.DATA_SCHEMA` (índice de contratos de datos).
   - `Workspace.DevelopmentStandard.PROJECT_STANDARD` (políticas técnicas obligatorias).
   - `Workspace.DevelopmentStandard.RC-TEMPLATE` / [`RC-TEMPLATE.md`](./RC-TEMPLATE.md) (plantilla idéntica en ambos lados).
2. **Nivel 2 (Páginas de Dominio en Studio — leer solo las afectadas por la tarea):**
   - **`Workspace.DevelopmentStandard.Architecture.<Dominio>`:** `PersonajesProgresion`, `CombateHabilidades`, `MundoDungeon`, `InventarioEquipo`, `Interfaz`, `Social`, `Economia`, `Assets`, `Publicacion`.
   - **`Workspace.DevelopmentStandard.Schemas.<Dominio>`:** `PerfilPersistencia`, `ItemsYEquipo`, `ProgresionYCombate`, `DungeonYGrupo`, `RemotesYEstadoSesion`, `EconomiaYTransacciones`.
3. **Nivel 3 (Documentos de Producto en el Proyecto Local — consulta bajo demanda):**
   - [`HU/`](./HU/) (la HU asignada).
   - [`GDD_ROBLOX_MVP.md`](./GDD_ROBLOX_MVP.md) (para alcance y reglas de negocio).
   - [`SKILLS_CATALOG.md`](./SKILLS_CATALOG.md) (solo si la tarea toca skills).
   - [`ASSETS_POLICY.md`](./ASSETS_POLICY.md) (solo si la tarea toca assets).
4. **Histórico:** No leer `Workspace.DevelopmentStandard.History` ni `ServerStorage.DevelopmentStandardHistory` en el recorrido normal.

---

## 2. Cómo operan los Agentes SDD sobre `Vandrheim-Roblox`

**Todos los roles (incluidos revisores y aprobador) usan Potencia Máxima:** Claude `Sonnet 5.5` | Codex `Sol` | Antigravity `Hydrogen High` (`high`). Se recomienda que revise una familia de modelos distinta a la que construyó.

### Etapa 1 — `SpecAgent` ([`../agents/SpecAgent.md`](../agents/SpecAgent.md))
- **Modelo:** Claude `Sonnet 5.5` | Codex `Sol` | Antigravity `Hydrogen High` (`high`)
- **Procedimiento obligatorio:**
  1. Leer en Studio `Workspace.DevelopmentStandard.DEV_PROMPT`, `PROJECT_ARCHITECTURE` y `DEVELOPER_GUIDE`, y en el proyecto local la HU asignada (`HU/`) y [`GDD_ROBLOX_MVP.md`](./GDD_ROBLOX_MVP.md) / [`SKILLS_CATALOG.md`](./SKILLS_CATALOG.md) cuando corresponda.
  2. Abrir y leer en Studio únicamente las páginas `Architecture.<Dominio>` y `Schemas.<Dominio>` relacionadas con la tarea, más los scripts reales involucrados en el DataModel (`ServerScriptService`, `ReplicatedStorage`, `StarterPlayerScripts`, `StarterGui`).
  3. Revisar `Workspace.DevelopmentStandard.Requirement.INDEX` y los atributos `RCId` del árbol `Requirement` para obtener el siguiente ID correlativo sin repetir (ej. después de `rc131` sigue `rc132`).
  4. Crear el RC directamente en Roblox Studio como instancia `Script` con `Disabled = true`, atributo `RCId = "rcNNN"`, `Name = "rc-titulo-descriptivo"` bajo la carpeta funcional estable `Workspace.DevelopmentStandard.Requirement.<Categoria>`, con `Source` compuesto únicamente por un comentario Luau válido (`--[[ ... ]]`) que respete las **10 secciones obligatorias de `RC-TEMPLATE`** e incorpore dentro de ellas los contratos verificables para:
     - **`CodeReviewAgent`** (en §5 Implementación técnica, §6 Integración, §7 Optimización).
     - **`SecurityReviewAgent`** (en §5: **superficie de ataque** con cada remote o punto de entrada nuevo o modificado, qué valida el servidor, quién puede usarlo y qué valor mueve: monedas, ítems, daño, perfil, party).
     - **`ReliabilityReviewAgent`** (en §5 y §7: **modos de falla** ante interrupción a mitad de operación, perfiles con esquema anterior, salida del jugador o del grupo, respawn, liberación de conexiones y supuestos de tiempo).
     - **`UXReviewAgent`** (en §4 Criterios de aceptación ejecutables y §5 estados de interacción, cierres y paridad PC/Mobile; indicar qué cifras o textos visibles deben coincidir con lo que aplica el servidor).
     - **`UIReviewAgent`** (en §4 y §5: uso de `Scale`, `UIAspectRatioConstraint`, `UISizeConstraint`, `UIScale`, `ZIndex`, prohibición de `Offset` impropio y resoluciones objetivo concretas).
     - Incluir en §4 el **plan de verificación**: cómo ejecutar, datos de prueba (incluido jugador nuevo con estado vacío y jugador con estado máximo), resultado esperado por criterio, revisores a activar y entradas aplicables de [`../agents/BUGS-HISTORICOS.md`](../agents/BUGS-HISTORICOS.md). Todo `CA-XX` debe poder ejecutarse y tener un resultado observable.
  5. Registrar la nueva entrada en `Workspace.DevelopmentStandard.Requirement.INDEX` (`| rcNNN | Seccion | titulo-corto | rc-titulo-descriptivo | Ruta |`).
  6. **Detenerse y esperar aprobación explícita del PO/usuario** antes de pasar a `BuilderAgent`.

---

### Etapa 2 — `BuilderAgent` ([`../agents/BuilderAgent.md`](../agents/BuilderAgent.md))
- **Modelo:** Claude `Sonnet 5.5` | Codex `Sol` | Antigravity `Hydrogen High` (`high`)
- **Procedimiento obligatorio en Studio (vía MCP):**
  1. Leer el `rcNNN` aprobado en `Workspace.DevelopmentStandard.Requirement.<Categoria>`, junto con `PROJECT_STANDARD` y las páginas `Architecture.<Dominio>` y `Schemas.<Dominio>` involucradas.
  2. Cambiar el estado del `rcNNN` a `EN IMPLEMENTACIÓN`.
  3. Implementar el 100% del alcance en el DataModel de Studio (Hub como fuente de trabajo según `rc048`), cumpliendo los contratos de código, estados UX y reglas UI (`Scale`).
  4. **Mantenimiento documental limpio (según `skills/project-docs/SKILL.md`):**
     - Si cambió estructura, rutas, responsabilidades o invariantes de un sistema: actualizar la descripción vigente en `Workspace.DevelopmentStandard.Architecture.<Dominio>` (y `PROJECT_ARCHITECTURE` solo si cambió el mapa general).
     - Si cambiaron campos, payloads, remotes, persistencia o migración: actualizar `Workspace.DevelopmentStandard.Schemas.<Dominio>` (y `DATA_SCHEMA` si aplica).
     - **Prohibido** agregar crónicas por tarea, transcripciones o reportes de QA dentro de `Architecture` o `Schemas`.
  5. **Probar de forma hostil antes de entregar:** ejecutar el juego en Play, revisar la consola desde el arranque, probar entradas extremas, repetidas y fuera de orden, jugador nuevo con estado vacío y jugador con estado máximo, y una interrupción a mitad de cada operación de varios pasos. Prohibido debilitar o saltar pruebas existentes.
  6. Emitir el **`MANIFIESTO DE ENTREGA — BUILDER AGENT`** con lista completa de scripts e instancias tocados, cómo ejecutar y probar, pruebas corridas y resultado, áreas de riesgo (remotes y economía, estado y concurrencia, interfaz), datos de prueba, efectos colaterales y limitaciones conocidas. Sin eso los revisores devuelven la entrega.

---

### Etapa 3 — Revisión Adversarial en Studio (Informan a `ApproverAgent`)
- **Modelo de los revisores:** Potencia Máxima (Claude `Sonnet 5.5` | Codex `Sol` | Antigravity `Hydrogen High` `high`).
- **Mandato:** cada revisor sigue [`../agents/REVIEW-PROTOCOL.md`](../agents/REVIEW-PROTOCOL.md): asume que el código está roto, **lo ejecuta** y entrega un dictamen con **registro de ataques** y evidencia de reproducción. Lo que no pueda ejecutar queda `[NO VERIFICADO]` y bloquea la aprobación. Leen [`../agents/BUGS-HISTORICOS.md`](../agents/BUGS-HISTORICOS.md) antes de empezar.
- **Activación por riesgo:** `CodeReviewAgent` y `UXReviewAgent` siempre; `SecurityReviewAgent` si el cambio toca remotes, combate, inventario, economía, perfil, party o cualquier entrada del cliente; `ReliabilityReviewAgent` si toca persistencia, estado de sesión o grupo, tareas asíncronas, conexiones o tiempos; `UIReviewAgent` si hay interfaz. En caso de duda se activa.
- **Cómo ejecutan en Studio (compatible con `rc120`):** pueden iniciar Play, ejecutar código de prueba en los contextos de servidor y cliente, capturar pantalla, emular dispositivos y resoluciones y usar varios clientes. **No crean instancias ni carpetas `Reports/` en el DataModel, no modifican scripts ni instancias y no guardan nada.** El código de prueba vive solo en la sesión de Play. Los dictámenes se entregan en el chat. Si el Play usa un perfil o datos reales, lo declaran antes de probar y revierten cualquier cambio.

1. **`CodeReviewAgent`** ([`../agents/CodeReviewAgent.md`](../agents/CodeReviewAgent.md)): corrección lógica y contratos del `rcNNN`, `PROJECT_STANDARD`, `Architecture.<Dominio>` y `Schemas.<Dominio>`.
   - Contexto Vandrheim: uso estricto de `task.wait`/`task.spawn`/`task.defer` (prohibido `wait()`), señales en lugar de `while true do`, limpieza de conexiones, 0 errores en consola **desde el arranque del juego completo**, actualización correcta de `Architecture`/`Schemas` si cambió el contrato, y que el `rcNNN` sea un `Script` con `Disabled = true` y comentario Luau válido.
   - Dictamen: `DICTAMEN DE AUDITORÍA DE CÓDIGO` (prefijo `CR`).

2. **`SecurityReviewAgent`** ([`../agents/SecurityReviewAgent.md`](../agents/SecurityReviewAgent.md)): atacan cada remote y punto de entrada nuevo o modificado.
   - Contexto Vandrheim: autoridad del servidor en combate, inventario, economía, perfil y party (`Schemas.RemotesYEstadoSesion`, `Schemas.EconomiaYTransacciones`); remotes con argumentos hostiles (tipos, `nil`, `NaN`, negativos, enormes), ráfagas, replay, ejecución sin permiso o sin cumplir precondiciones, duplicación de ítems o monedas, y confianza en valores del cliente.
   - Dictamen: `DICTAMEN DE AUDITORÍA DE SEGURIDAD` (prefijo `SEC`).

3. **`ReliabilityReviewAgent`** ([`../agents/ReliabilityReviewAgent.md`](../agents/ReliabilityReviewAgent.md)): fuerzan fallos y estados límite.
   - Contexto Vandrheim: persistencia y migración de perfil (`Schemas.PerfilPersistencia`), interrupciones a mitad de una operación, salida del jugador o del grupo durante una mazmorra (`Schemas.DungeonYGrupo`), respawn, conexiones que no se liberan tras repetir una operación, y supuestos de tiempo.
   - Dictamen: `DICTAMEN DE AUDITORÍA DE CONFIABILIDAD` (prefijo `REL`).

4. **`UXReviewAgent`** ([`../agents/UXReviewAgent.md`](../agents/UXReviewAgent.md)): ejecutan cada `CA-XX` del `rcNNN` y recorren los flujos de forma adversarial.
   - Contexto Vandrheim: estados completos (`idle`, `loading/cooldown`, `empty`, `error`, `success`), bloqueo de doble clic/tap, cierre limpio de paneles y diálogos (`DialogView`, `WindowLayoutClient`, `UIWindowOpen`, rueda del mouse en `CameraController`), paridad PC y Mobile (`TouchEnabled`), jugador nuevo con estado vacío y que lo mostrado en la interfaz coincida con lo que aplica el servidor. Invariantes de `Architecture.Interfaz`.
   - Dictamen: `DICTAMEN DE AUDITORÍA DE UX` (prefijo `UX`).

5. **`UIReviewAgent`** ([`../agents/UIReviewAgent.md`](../agents/UIReviewAgent.md)): renderizan, miden y exigen capturas.
   - Contexto Vandrheim: `Scale` (`UDim2.fromScale`), `UIAspectRatioConstraint`, `UISizeConstraint`, `UIScale` y `UITextSizeConstraint` (cero `Offset` rígido indebido), respeto a `UITheme`, `GlobalUIConfig` y `UILayoutDefaults` (ramas `pc` y `mobile`), herencia de `ZIndex` (`applyZIndexTree` cuando corresponda), texto largo y glifos que la fuente no soporte, y solapes o desbordes medidos en las resoluciones de PC y móvil.
   - Dictamen: `DICTAMEN DE AUDITORÍA DE UI` (prefijo `UI`).

---

### Etapa 4 — `ApproverAgent` ([`../agents/ApproverAgent.md`](../agents/ApproverAgent.md))
- **Modelo:** Potencia Máxima (Claude `Sonnet 5.5` | Codex `Sol` | Antigravity `Hydrogen High` `high`).
- **Acción:**
  - Verifica que corrieron todos los revisores que el riesgo exige, **audita la calidad de cada dictamen** (rechaza los que no tengan registro de ataques o evidencia de ejecución) y reejecuta reproducciones y pruebas propias.
  - Deduplica hallazgos y resuelve conflictos contra el `rcNNN` y `Workspace.DevelopmentStandard`. **No puede descartar un hallazgo con evidencia.**
  - **Si hay `[BLOQUEANTE]`, `[MAYOR]` o `[NO VERIFICADO]` abiertos:** emite `RESOLUCIÓN DEL APPROVER AGENT — CAMBIOS REQUERIDOS` con la **`ORDEN DE CORRECCIÓN CONSOLIDADA ([FIX-01..N])`** hacia `BuilderAgent`. En cada ronda los revisores revisan el diff completo y reejecutan las reproducciones anteriores; solo el revisor que halló una falla la cierra.
  - **Si todo está limpio de verdad:** emite `RESOLUCIÓN DEL APPROVER AGENT — DESARROLLO APROBADO` con el historial de hallazgos y el **riesgo residual**, e informa qué criterios quedaron verificados en Studio (recordando que guardar, derivar a `Dungeon_Helada`/`Prólogo` según `rc048` y publicar corresponde al PO).
  - Tras 3 rondas con bloqueantes abiertos, escala al PO.
- **Memoria:** toda falla que el PO encuentre después de una aprobación se registra en [`../agents/BUGS-HISTORICOS.md`](../agents/BUGS-HISTORICOS.md).

---

## 3. Skills Especializadas de Vandrheim (en [`skills/`](./skills/))

- [`skills/project-docs/SKILL.md`](./skills/project-docs/SKILL.md): Reglas obligatorias de navegación y mantenimiento de `Workspace.DevelopmentStandard` y `Requirement`.
- [`skills/vandrheim-roblox-animation/SKILL.md`](./skills/vandrheim-roblox-animation/SKILL.md): Creación y validación de animaciones `KeyframeSequence` en Studio.
- [`skills/roblox-r15-body-skins/SKILL.md`](./skills/roblox-r15-body-skins/SKILL.md): Texturas UV (`585×559`) de ropa clásica R15.
- [`skills/vandrheim-weapon-assets/SKILL.md`](./skills/vandrheim-weapon-assets/SKILL.md): Modelos segmentados e íconos de armas en `Workspace.ESTWeaponPlace.Armas`.
