# Protocolo SDD para Vandrheim-Roblox (Integrado con `Workspace.DevelopmentStandard` en Studio)

Este proyecto opera bajo el ecosistema **SDD con revisión adversarial** (especificador, constructor, dos revisores —`CodeReviewAgent` y `UIReviewAgent`— y aprobador) definido en [`../AGENTS.md`](../AGENTS.md) y regido por [`../agents/REVIEW-PROTOCOL.md`](../agents/REVIEW-PROTOCOL.md), conectado de forma estricta con la arquitectura documental vigente dentro de **Roblox Studio (`Workspace.DevelopmentStandard`, establecida en `rc120`)** y gobernada por la skill [`skills/project-docs/SKILL.md`](./skills/project-docs/SKILL.md).

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

**Perfil de modelos por rol (definido en [`../AGENTS.md`](../AGENTS.md)):** SpecAgent: Claude `Opus` low | Codex `GPT Sol` low | Antigravity `Hydrogen High`. BuilderAgent: Claude `Sonnet` medium | Codex `GPT Terra` medium | Antigravity `Hydrogen Medium`. Revisores: Claude `Haiku` Extra | Codex `GPT Luna` Max | Antigravity `Flash Medium`. ApproverAgent: Claude `Haiku` Extra | Codex `GPT Luna` Max | Antigravity `Flash High`. Se recomienda que revise una familia de modelos distinta a la que construyó.

### Etapa 1 — `SpecAgent` ([`../agents/SpecAgent.md`](../agents/SpecAgent.md))
- **Modelo:** Claude `Opus` low | Codex `GPT Sol` low | Antigravity `Hydrogen High`
- **Procedimiento obligatorio:**
  1. Leer en Studio `Workspace.DevelopmentStandard.DEV_PROMPT`, `PROJECT_ARCHITECTURE` y `DEVELOPER_GUIDE`, y en el proyecto local la HU asignada (`HU/`) y [`GDD_ROBLOX_MVP.md`](./GDD_ROBLOX_MVP.md) / [`SKILLS_CATALOG.md`](./SKILLS_CATALOG.md) cuando corresponda.
  2. Abrir y leer en Studio únicamente las páginas `Architecture.<Dominio>` y `Schemas.<Dominio>` relacionadas con la tarea, más los scripts reales involucrados en el DataModel (`ServerScriptService`, `ReplicatedStorage`, `StarterPlayerScripts`, `StarterGui`).
  3. Revisar `Workspace.DevelopmentStandard.Requirement.INDEX` y los atributos `RCId` del árbol `Requirement` para obtener el siguiente ID correlativo sin repetir (ej. después de `rc131` sigue `rc132`).
  4. Crear el RC directamente en Roblox Studio como instancia `Script` con `Disabled = true`, atributo `RCId = "rcNNN"`, `Name = "rc-titulo-descriptivo"` bajo la carpeta funcional estable `Workspace.DevelopmentStandard.Requirement.<Categoria>`, con `Source` compuesto únicamente por un comentario Luau válido (`--[[ ... ]]`) que respete las **10 secciones obligatorias de `RC-TEMPLATE`** e incorpore dentro de ellas los contratos verificables para:
     - **`CodeReviewAgent`** (en §4 Criterios de aceptación ejecutables y estados de interacción, §5 Implementación técnica, §6 Integración, §7 Optimización; incluir los datos de prueba y los textos o cifras visibles que deben coincidir con lo que aplica el servidor).
     - **`UIReviewAgent`** (en §4 y §5: uso de `Scale`, `UIAspectRatioConstraint`, `UISizeConstraint`, `UIScale`, `ZIndex`, prohibición de `Offset` impropio y resoluciones objetivo concretas).
     - Incluir en §4 el **plan de verificación**: cómo ejecutar, datos de prueba (incluido jugador nuevo con estado vacío y jugador con estado máximo), resultado esperado por criterio, revisores a activar y entradas aplicables de [`../agents/BUGS-HISTORICOS.md`](../agents/BUGS-HISTORICOS.md). Todo `CA-XX` debe poder ejecutarse y tener un resultado observable.
  5. Registrar la nueva entrada en `Workspace.DevelopmentStandard.Requirement.INDEX` (`| rcNNN | Seccion | titulo-corto | rc-titulo-descriptivo | Ruta |`).
  6. **Detenerse y esperar aprobación explícita del PO/usuario** antes de pasar a `BuilderAgent`.

---

### Etapa 2 — `BuilderAgent` ([`../agents/BuilderAgent.md`](../agents/BuilderAgent.md))
- **Modelo:** Claude `Sonnet` medium | Codex `GPT Terra` medium | Antigravity `Hydrogen Medium`
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
- **Modelo de los revisores:** Claude `Haiku` Extra | Codex `GPT Luna` Max | Antigravity `Flash Medium`.
- **Mandato:** cada revisor sigue [`../agents/REVIEW-PROTOCOL.md`](../agents/REVIEW-PROTOCOL.md): asume que el código está roto, **lo ejecuta** y entrega un dictamen con **registro de ataques** y evidencia de reproducción. Lo que no pueda ejecutar queda `[NO VERIFICADO]` y bloquea la aprobación. Leen [`../agents/BUGS-HISTORICOS.md`](../agents/BUGS-HISTORICOS.md) antes de empezar.
- **Revisores activos en Vandrheim:** En Vandrheim solo se usan **dos revisores**: `CodeReviewAgent` (siempre; además ejecuta los `CA-XX` y recorre los flujos y estados de la funcionalidad) y `UIReviewAgent` (solo si el cambio toca interfaz visual). `SecurityReviewAgent`, `ReliabilityReviewAgent` y `UXReviewAgent` no se activan en este proyecto; el PO puede pedirlos puntualmente para una tarea concreta.
- **Nivel de revisión (S / M / L):** el `SpecAgent` lo propone en el RC y el `BuilderAgent` lo confirma en el Manifiesto (ver [`../agents/REVIEW-PROTOCOL.md`](../agents/REVIEW-PROTOCOL.md), sección 9.1). En nivel **S** (como quitar un elemento de HUD o ajustar un valor de config) basta `CodeReviewAgent` y la verificación del PO en Play puede cerrar los `CA-XX` que dependan de ver la interfaz real. En **M** y **L** se suma `UIReviewAgent` si hay interfaz. Mínimos de ataques: S 4, M 6, L 10.
- **Cómo ejecutan en Studio (compatible con `rc120`):** por defecto aplican [`skills/studio-simulation-review/SKILL.md`](./skills/studio-simulation-review/SKILL.md) (simulación en el DataModel Edit, sin Play; obligatoria si el PO está probando en Play). Solo para lo que no se pueda simular, pueden iniciar Play, ejecutar código de prueba en los contextos de servidor y cliente, capturar pantalla, emular dispositivos y resoluciones y usar varios clientes. **No crean instancias ni carpetas `Reports/` en el DataModel, no modifican scripts ni instancias y no guardan nada.** El código de prueba vive solo en la sesión de Play. Los dictámenes se entregan en el chat. Si el Play usa un perfil o datos reales, lo declaran antes de probar y revierten cualquier cambio.

1. **`CodeReviewAgent`** ([`../agents/CodeReviewAgent.md`](../agents/CodeReviewAgent.md)): corrección lógica y contratos del `rcNNN`, `PROJECT_STANDARD`, `Architecture.<Dominio>` y `Schemas.<Dominio>`. Además ejecuta cada `CA-XX` y recorre los flujos y estados (`idle`, `loading/cooldown`, `empty`, `error`, `success`), jugador nuevo, doble clic y cierre limpio de paneles.
   - Contexto Vandrheim: uso estricto de `task.wait`/`task.spawn`/`task.defer` (prohibido `wait()`), señales en lugar de `while true do`, limpieza de conexiones, 0 errores en consola **desde el arranque del juego completo**, actualización correcta de `Architecture`/`Schemas` si cambió el contrato, y que el `rcNNN` sea un `Script` con `Disabled = true` y comentario Luau válido.
   - Dictamen: `DICTAMEN DE AUDITORÍA DE CÓDIGO` (prefijo `CR`).

2. **`UIReviewAgent`** ([`../agents/UIReviewAgent.md`](../agents/UIReviewAgent.md)): renderizan, miden y exigen capturas.
   - Contexto Vandrheim: `Scale` (`UDim2.fromScale`), `UIAspectRatioConstraint`, `UISizeConstraint`, `UIScale` y `UITextSizeConstraint` (cero `Offset` rígido indebido), respeto a `UITheme`, `GlobalUIConfig` y `UILayoutDefaults` (ramas `pc` y `mobile`), herencia de `ZIndex` (`applyZIndexTree` cuando corresponda), texto largo y glifos que la fuente no soporte, y solapes o desbordes medidos en las resoluciones de PC y móvil.
   - Dictamen: `DICTAMEN DE AUDITORÍA DE UI` (prefijo `UI`).

---

### Etapa 4 — `ApproverAgent` ([`../agents/ApproverAgent.md`](../agents/ApproverAgent.md))
- **Modelo:** Claude `Haiku` Extra | Codex `GPT Luna` Max | Antigravity `Flash High`.
- **Acción:**
  - Verifica que corrieron los revisores activos (`CodeReviewAgent` y, si hay interfaz, `UIReviewAgent`), **audita la calidad de cada dictamen** (rechaza los que no tengan registro de ataques o evidencia de ejecución) y reejecuta reproducciones por muestreo según el nivel (S: 1 ataque; M: 2 más uno propio; L: uno por dictamen más uno propio).
  - Deduplica hallazgos y resuelve conflictos contra el `rcNNN` y `Workspace.DevelopmentStandard`. **No puede descartar un hallazgo con evidencia.**
  - **Si hay `[BLOQUEANTE]`, `[MAYOR]` o `[NO VERIFICADO]` abiertos:** emite `RESOLUCIÓN DEL APPROVER AGENT — CAMBIOS REQUERIDOS` con la **`ORDEN DE CORRECCIÓN CONSOLIDADA ([FIX-01..N])`** hacia `BuilderAgent`. Desde la ronda v2 cada revisor revisa el diff del fix, reejecuta las reproducciones de sus hallazgos abiertos y una muestra de regresión de 3 ataques (revisión completa solo si el fix tocó scripts fuera de los `[FIX-XX]` o es nivel L con bloqueante de seguridad o confiabilidad); solo el revisor que halló una falla la cierra.
  - **Si todo está limpio de verdad:** emite `RESOLUCIÓN DEL APPROVER AGENT — DESARROLLO APROBADO` con el historial de hallazgos y el **riesgo residual**, e informa qué criterios quedaron verificados en Studio (recordando que guardar, derivar a `Dungeon_Helada`/`Prólogo` según `rc048` y publicar corresponde al PO).
  - Tras 3 rondas con bloqueantes abiertos, escala al PO.
- **Memoria:** toda falla que el PO encuentre después de una aprobación se registra en [`../agents/BUGS-HISTORICOS.md`](../agents/BUGS-HISTORICOS.md).

---

## 3. Skills Especializadas de Vandrheim (en [`skills/`](./skills/))

- [`skills/project-docs/SKILL.md`](./skills/project-docs/SKILL.md): Reglas obligatorias de navegación y mantenimiento de `Workspace.DevelopmentStandard` y `Requirement`.
- [`skills/vandrheim-roblox-animation/SKILL.md`](./skills/vandrheim-roblox-animation/SKILL.md): Creación y validación de animaciones `KeyframeSequence` en Studio.
- [`skills/roblox-r15-body-skins/SKILL.md`](./skills/roblox-r15-body-skins/SKILL.md): Texturas UV (`585×559`) de ropa clásica R15.
- [`skills/vandrheim-weapon-assets/SKILL.md`](./skills/vandrheim-weapon-assets/SKILL.md): Modelos segmentados e íconos de armas en `Workspace.ESTWeaponPlace.Armas`.
- [`skills/studio-simulation-review/SKILL.md`](./skills/studio-simulation-review/SKILL.md): Revisión adversarial por simulación en el DataModel Edit, sin iniciar Play; opción por defecto de los revisores.
- [`skills/vandrheim-vfx/SKILL.md`](./skills/vandrheim-vfx/SKILL.md): Autoría y validación de VFX de habilidades e impactos en Studio usando capas, curvas, beams curvos y presupuestos por perfil.
