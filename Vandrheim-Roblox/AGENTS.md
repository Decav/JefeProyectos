# Protocolo SDD para Vandrheim-Roblox (Integrado con `Workspace.DevelopmentStandard` en Studio)

Este proyecto opera bajo el ecosistema **SDD de 6 Agentes** definido en [`../AGENTS.md`](../AGENTS.md), conectado de forma estricta con la arquitectura documental vigente dentro de **Roblox Studio (`Workspace.DevelopmentStandard`, establecida en `rc120`)** y gobernada por la skill [`skills/project-docs/SKILL.md`](./skills/project-docs/SKILL.md).

**Regla de formato:** Prohibido usar emojis o íconos decorativos en cualquier documento, RC, comentario Luau o dictamen.

---

## 1. Separación Estricta: Qué vive en el Proyecto Local (PM) vs. Qué vive en Roblox Studio (SDD / Dev)

| Tipo de Documentación | Dónde vive (Fuente Única de Verdad) | Quién lo mantiene |
| :--- | :--- | :--- |
| **Documentos de Producto (PM):**<br>- [`GDD_ROBLOX_MVP.md`](./GDD_ROBLOX_MVP.md)<br>- [`SKILLS_CATALOG.md`](./SKILLS_CATALOG.md)<br>- [`HU/`](./HU/), [`ROADMAP.md`](./ROADMAP.md), [`QUEST_SYSTEM.md`](./QUEST_SYSTEM.md), [`ITEMS_DESCRIPTIONS.md`](./ITEMS_DESCRIPTIONS.md), [`MONETIZATION.md`](./MONETIZATION.md) | **ÚNICAMENTE en el proyecto local (`Vandrheim-Roblox/`)**.<br>No deben existir ni consultarse copias de `GDD` ni de `SKILLS_CATALOG` dentro de Roblox Studio. | `PMAgent` / PO |
| **Plantilla de RC (`RC-TEMPLATE`):**<br>- [`RC-TEMPLATE.md`](./RC-TEMPLATE.md) (Local)<br>- `Workspace.DevelopmentStandard.RC-TEMPLATE` (Studio) | **Idéntica en ambos lados** (Local y Studio mantienen exactamente las mismas reglas y los 10 apartados obligatorios). | Compartido (Sincronizado) |
| **Documentación Técnica de Arquitectura, Esquemas y RCs:**<br>- `DEV_PROMPT`, `PROJECT_ARCHITECTURE`, `DEVELOPER_GUIDE`, `DATA_SCHEMA`, `PROJECT_STANDARD`<br>- `Architecture.<Dominio>` (9 dominios)<br>- `Schemas.<Dominio>` (6 dominios)<br>- `Requirement.<Categoria>.rc-...` + `Requirement.INDEX` | **ÚNICAMENTE dentro de Roblox Studio** en `Workspace.DevelopmentStandard` (vía MCP).<br>Prohibido crear archivos `.lua` o RCs en el proyecto local. | `SpecAgent`, `BuilderAgent` (auditados por los 3 Revisores y `ApproverAgent`) |

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

## 2. Cómo operan los 6 Agentes SDD sobre `Vandrheim-Roblox`

### Etapa 1 — `SpecAgent` ([`../agents/SpecAgent.md`](../agents/SpecAgent.md))
- **Modelo:** Claude `Opus` | Codex `Sol` | Antigravity `Argon` (`pro`)
- **Procedimiento obligatorio:**
  1. Leer en Studio `Workspace.DevelopmentStandard.DEV_PROMPT`, `PROJECT_ARCHITECTURE` y `DEVELOPER_GUIDE`, y en el proyecto local la HU asignada (`HU/`) y [`GDD_ROBLOX_MVP.md`](./GDD_ROBLOX_MVP.md) / [`SKILLS_CATALOG.md`](./SKILLS_CATALOG.md) cuando corresponda.
  2. Abrir y leer en Studio únicamente las páginas `Architecture.<Dominio>` y `Schemas.<Dominio>` relacionadas con la tarea, más los scripts reales involucrados en el DataModel (`ServerScriptService`, `ReplicatedStorage`, `StarterPlayerScripts`, `StarterGui`).
  3. Revisar `Workspace.DevelopmentStandard.Requirement.INDEX` y los atributos `RCId` del árbol `Requirement` para obtener el siguiente ID correlativo sin repetir (ej. después de `rc131` sigue `rc132`).
  4. Crear el RC directamente en Roblox Studio como instancia `Script` con `Disabled = true`, atributo `RCId = "rcNNN"`, `Name = "rc-titulo-descriptivo"` bajo la carpeta funcional estable `Workspace.DevelopmentStandard.Requirement.<Categoria>`, con `Source` compuesto únicamente por un comentario Luau válido (`--[[ ... ]]`) que respete las **10 secciones obligatorias de `RC-TEMPLATE`** e incorpore dentro de ellas los contratos verificables para:
     - **`CodeReviewAgent`** (en §5 Implementación técnica, §6 Integración, §7 Optimización).
     - **`UXReviewAgent`** (en §4 Criterios de aceptación y §5 estados de interacción, cierres y paridad PC/Mobile).
     - **`UIReviewAgent`** (en §4 y §5: uso de `Scale`, `UIAspectRatioConstraint`, `UISizeConstraint`, `UIScale`, `ZIndex` y prohibición de `Offset` impropio).
  5. Registrar la nueva entrada en `Workspace.DevelopmentStandard.Requirement.INDEX` (`| rcNNN | Seccion | titulo-corto | rc-titulo-descriptivo | Ruta |`).
  6. **Detenerse y esperar aprobación explícita del PO/usuario** antes de pasar a `BuilderAgent`.

---

### Etapa 2 — `BuilderAgent` ([`../agents/BuilderAgent.md`](../agents/BuilderAgent.md))
- **Modelo:** Claude `Opus` | Codex `Sol` | Antigravity `Argon` (`pro`)
- **Procedimiento obligatorio en Studio (vía MCP):**
  1. Leer el `rcNNN` aprobado en `Workspace.DevelopmentStandard.Requirement.<Categoria>`, junto con `PROJECT_STANDARD` y las páginas `Architecture.<Dominio>` y `Schemas.<Dominio>` involucradas.
  2. Cambiar el estado del `rcNNN` a `EN IMPLEMENTACIÓN`.
  3. Implementar el 100% del alcance en el DataModel de Studio (Hub como fuente de trabajo según `rc048`), cumpliendo los contratos de código, estados UX y reglas UI (`Scale`).
  4. **Mantenimiento documental limpio (según `skills/project-docs/SKILL.md`):**
     - Si cambió estructura, rutas, responsabilidades o invariantes de un sistema: actualizar la descripción vigente en `Workspace.DevelopmentStandard.Architecture.<Dominio>` (y `PROJECT_ARCHITECTURE` solo si cambió el mapa general).
     - Si cambiaron campos, payloads, remotes, persistencia o migración: actualizar `Workspace.DevelopmentStandard.Schemas.<Dominio>` (y `DATA_SCHEMA` si aplica).
     - **Prohibido** agregar crónicas por tarea, transcripciones o reportes de QA dentro de `Architecture` o `Schemas`.
  5. Verificar en Studio que los scripts compilen sin errores y emitir el **`MANIFIESTO DE ENTREGA — BUILDER AGENT`** para activar a los 3 revisores.

---

### Etapa 3 — Triple Auditoría Read-Only en Studio (Informan a `ApproverAgent`)
- **Modelo de los 3 revisores:** Claude `Sonnet` | Codex `Terra` / `Luna Max` | Antigravity `Flash` (`flash`)

1. **`CodeReviewAgent`** ([`../agents/CodeReviewAgent.md`](../agents/CodeReviewAgent.md)):
   - Audita en Studio (modo **Read-Only**) los scripts modificados contra el `rcNNN`, `PROJECT_STANDARD`, `Architecture.<Dominio>` y `Schemas.<Dominio>`:
     - Autoridad del servidor en operaciones críticas (combate, inventario, economía, perfil, party).
     - Uso estricto de `task.wait`/`task.spawn`/`task.defer` (prohibido `wait()`), señales en lugar de `while true do`, limpieza de conexiones y ausencia de errores en consola.
     - Verifica además que `BuilderAgent` haya actualizado correctamente las páginas `Architecture.<Dominio>` y `Schemas.<Dominio>` si el contrato cambió, y que el `rcNNN` sea un `Script` con `Disabled = true` y comentario Luau válido.
   - Entrega su `DICTAMEN DE AUDITORÍA DE CÓDIGO` al **`ApproverAgent`**.

2. **`UXReviewAgent`** ([`../agents/UXReviewAgent.md`](../agents/UXReviewAgent.md)):
   - Audita en Studio (modo **Read-Only**) los flujos de interacción y experiencia del jugador contra el `rcNNN` y los invariantes de `Architecture.Interfaz`:
     - Estados completos (`idle`, `loading/cooldown`, `empty`, `error`, `success`), bloqueo de doble clic/tap y cierre limpio de paneles/diálogos (`DialogView`, `WindowLayoutClient`, `UIWindowOpen`, rueda del mouse en `CameraController`).
     - Paridad total entre **PC y Mobile (`TouchEnabled`)** sin que la lógica móvil pise a la de PC ni dependan de hover.
   - Entrega su `DICTAMEN DE AUDITORÍA DE UX` al **`ApproverAgent`**.

3. **`UIReviewAgent`** ([`../agents/UIReviewAgent.md`](../agents/UIReviewAgent.md)):
   - Audita en Studio (modo **Read-Only**) las plantillas de `StarterGui` y la UI generada en runtime contra el `rcNNN`, `PROJECT_STANDARD` y `Architecture.Interfaz`:
     - Uso de **`Scale` (`UDim2.fromScale`)**, `UIAspectRatioConstraint`, `UISizeConstraint`, `UIScale` y `UITextSizeConstraint` (cero `Offset` rígido indebido).
     - Respeto a `UITheme`, `GlobalUIConfig`, `UILayoutDefaults` (ramas `pc` y `mobile`), herencia de `ZIndex` (`applyZIndexTree` cuando corresponda), legibilidad y ausencia de desbordes/solapes en resoluciones de PC y móvil.
   - Entrega su `DICTAMEN DE AUDITORÍA DE UI` al **`ApproverAgent`**.

---

### Etapa 4 — `ApproverAgent` ([`../agents/ApproverAgent.md`](../agents/ApproverAgent.md))
- **Modelo:** Claude `Sonnet` | Codex `Terra` / `Luna Max` | Antigravity `Flash` (`flash`)
- **Acción:**
  - Recibe los 3 dictámenes (`Code`, `UX`, `UI`), deduplica hallazgos y resuelve cualquier conflicto contra el `rcNNN` y `Workspace.DevelopmentStandard`.
  - **Si hay hallazgos `[BLOQUEANTE]` o `[MAYOR]`:** emite `RESOLUCIÓN DEL APPROVER AGENT — CAMBIOS REQUERIDOS` con la **`ORDEN DE CORRECCIÓN CONSOLIDADA ([FIX-01..N])`** hacia `BuilderAgent`.
  - **Si las 3 auditorías aprueban:** emite `RESOLUCIÓN DEL APPROVER AGENT — DESARROLLO APROBADO Y LISTO` e informa qué criterios quedaron verificados en Studio (recordando que guardar, derivar a `Dungeon_Helada`/`Prólogo` según `rc048` y publicar corresponde al PO).

---

## 3. Skills Especializadas de Vandrheim (en [`skills/`](./skills/))

- [`skills/project-docs/SKILL.md`](./skills/project-docs/SKILL.md): Reglas obligatorias de navegación y mantenimiento de `Workspace.DevelopmentStandard` y `Requirement`.
- [`skills/vandrheim-roblox-animation/SKILL.md`](./skills/vandrheim-roblox-animation/SKILL.md): Creación y validación de animaciones `KeyframeSequence` en Studio.
- [`skills/roblox-r15-body-skins/SKILL.md`](./skills/roblox-r15-body-skins/SKILL.md): Texturas UV (`585×559`) de ropa clásica R15.
- [`skills/vandrheim-weapon-assets/SKILL.md`](./skills/vandrheim-weapon-assets/SKILL.md): Modelos segmentados e íconos de armas en `Workspace.ESTWeaponPlace.Armas`.
