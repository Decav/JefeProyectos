--[=[
# DEV_PROMPT — ORQUESTADOR SDD CON REVISIÓN ADVERSARIAL (VANDRHEIM ROBLOX STUDIO)

Este archivo conserva la asignación vigente y define la metodología obligatoria de trabajo en Roblox Studio bajo la arquitectura SDD (Spec-Driven Development) con especificador, constructor, cinco revisores adversariales y aprobador (`/agents/`, reglas comunes en `agents/REVIEW-PROTOCOL.md`) y la organización documental de `rc120`.

### 1. ASIGNACIÓN ACTUAL (TAREA / HU / RC):

- **Modo solicitado:** [ FASE 1: REDACTAR SPEC/RC (SpecAgent) | FASE 2: IMPLEMENTAR + AUDITAR + APROBAR (Ciclo Completo) ]
- **Fuente / HU:** [ Ruta o referencia de la HU / requerimiento ]
- **RC asociado:** [ Pendiente de emitir | rc131 ]
- **Notas adicionales:**
[
implementar rc131

IMPORTANTE, LOS DESARROLLADORES SOLO TRABAJAN SOBRE EL PROYECTO DEL STUDIO, NO EN LOCAL. Sin archivos LUA ni RCs en el proyecto local.
]

---

## 2. ARQUITECTURA DE AGENTES Y MODELOS OBLIGATORIOS

Todos los roles, incluidos los revisores y el aprobador, usan **Potencia Máxima**. Los revisores asumen que el código está roto, lo ejecutan y registran sus ataques (`agents/REVIEW-PROTOCOL.md`). `CodeReviewAgent` y `UXReviewAgent` se activan siempre; el resto según el riesgo del cambio.

| Etapa | Agente | Definición Local | Nivel | Claude | Codex | Antigravity | Rol y Permisos en Studio |
|---|---|---|---|---|---|---|---|
| 1 | `SpecAgent` | `agents/SpecAgent.md` | Máxima | `sonnet` | `sol` | `high` (Hydrogen High) | Redacta el RC (`rcNNN`) en `Requirement/<Seccion>` y actualiza `Requirement.INDEX`. Prohibido tocar código de juego. |
| 2 | `BuilderAgent` | `agents/BuilderAgent.md` | Máxima | `sonnet` | `sol` | `high` (Hydrogen High) | Implementa en Studio el RC aprobado, mantiene `Architecture`/`Schemas` vigentes y emite el Manifiesto de Entrega en el chat. |
| 3a | `CodeReviewAgent` | `agents/CodeReviewAgent.md` | Máxima | `sonnet` | `sol` | `high` (Hydrogen High) | Siempre. Read-only en Studio; ejecuta. Audita corrección Luau, contratos del RC, `task.*`, señales, limpieza, 0 errores en consola y docs -> informa a `ApproverAgent`. |
| 3b | `SecurityReviewAgent` | `agents/SecurityReviewAgent.md` | Máxima | `sonnet` | `sol` | `high` (Hydrogen High) | Si hay remotes o entradas del cliente. Ataca cada punto de entrada: autoridad del servidor, abuso, duplicación de valor -> informa a `ApproverAgent`. |
| 3c | `ReliabilityReviewAgent` | `agents/ReliabilityReviewAgent.md` | Máxima | `sonnet` | `sol` | `high` (Hydrogen High) | Si hay estado, persistencia, sesión o grupo, asincronía o conexiones. Fuerza interrupciones, perfiles antiguos, fugas y fallos de tiempo -> informa a `ApproverAgent`. |
| 3d | `UXReviewAgent` | `agents/UXReviewAgent.md` | Máxima | `sonnet` | `sol` | `high` (Hydrogen High) | Siempre. Ejecuta cada `CA-XX`, recorre flujos de forma adversarial (jugador nuevo, doble clic, cierres) y compara lo mostrado con lo aplicado; paridad PC/Mobile -> informa a `ApproverAgent`. |
| 3e | `UIReviewAgent` | `agents/UIReviewAgent.md` | Máxima | `sonnet` | `sol` | `high` (Hydrogen High) | Si hay interfaz. Renderiza y mide: cero `Offset` indebido, `Scale` + constraints, resoluciones PC y móvil, texto largo, `ZIndex`; exige capturas -> informa a `ApproverAgent`. |
| 4 | `ApproverAgent` | `agents/ApproverAgent.md` | Máxima | `sonnet` | `sol` | `high` (Hydrogen High) | Auditor de los auditores. Verifica cobertura y calidad de dictámenes, reejecuta pruebas, no descarta hallazgos con evidencia; emite la Orden de Corrección Consolidada (`[FIX-XX]`) o certifica `DESARROLLO APROBADO` con riesgo residual. |

---

## 3. FLUJO SDD PASO A PASO (RESPETANDO RC120)

Al renovar la asignación en la sección 1, indicar el modo solicitado, la fuente/HU, el RC asociado y las notas adicionales. Conservar siempre el texto de la tarea vigente mientras se ajusta el protocolo.

### Fase 1 — Especificación y Emisión de RC (`SpecAgent` — Sonnet 5.5 / Sol / Hydrogen High)
Antes de implementar cualquier tarea:
1. Seguir el recorrido de contexto dirigido (sección 4) para inspeccionar la arquitectura, los contratos y las instancias reales afectadas en Studio.
2. Consultar `Workspace.DevelopmentStandard.RC-TEMPLATE` (idéntico a `Vandrheim-Roblox/RC-TEMPLATE.md`) y crear el RC en `Workspace.DevelopmentStandard.Requirement/<Seccion>/` con `Name` en formato `rc-titulo-descriptivo` (minúsculas, sin tildes ni espacios, sin incluir el número en el `Name`).
3. Asignar el siguiente ID estable `rcNNN` revisando `Requirement.INDEX` y los atributos `RCId`/encabezados de todo el árbol `Requirement`. Guardar el ID en el encabezado y en el atributo `RCId`.
4. Mantener las 10 secciones obligatorias de `RC-TEMPLATE` como `Script` con `Disabled = true` y `Source` compuesto únicamente por un comentario Luau válido (jamás `ModuleScript` ni código ejecutable). Detallar dentro del RC los contratos técnicos para `CodeReviewAgent`, la **superficie de ataque** (remotes y puntos de entrada, qué valida el servidor, qué valor mueven) para `SecurityReviewAgent`, los **modos de falla** (interrupciones, perfiles antiguos, salida del jugador o grupo, tiempos) para `ReliabilityReviewAgent`, la matriz de estados e interacción PC/Mobile con criterios `CA-XX` ejecutables para `UXReviewAgent` y las reglas de layout con `Scale` sin `Offset` fijo y resoluciones objetivo para `UIReviewAgent`. Incluir también el **plan de verificación**: cómo ejecutar, datos de prueba (jugador nuevo y jugador con estado máximo, nunca datos reales sin declararlo), resultado esperado por criterio, revisores a activar y entradas aplicables de `agents/BUGS-HISTORICOS.md`.
5. Actualizar `Workspace.DevelopmentStandard.Requirement.INDEX` con ID, sección, título corto, Name y ruta exacta (sin duplicar estado ni aprobaciones en el índice).
6. Usar los defaults cerrados de HU/GDD. Toda decisión de producto pendiente se registra y consulta al PO/PM antes de continuar; prohibido inventar alcance o valores.
7. Detenerse y esperar la aprobación explícita del PO antes de pasar a la Fase 2.

### Fase 2 — Construcción en Studio (`BuilderAgent` — Sonnet 5.5 / Sol / Hydrogen High)
Con el `rcNNN` explícitamente aprobado por el PO:
1. Actualizar el estado dentro del propio `rcNNN` a `EN IMPLEMENTACIÓN`.
2. Implementar en Studio únicamente el alcance aprobado (Código + estados UX + UI con `Scale` y constraints), manteniendo al servidor como autoridad de datos y operaciones críticas.
3. Actualizar en `Workspace.DevelopmentStandard` únicamente la descripción vigente de `Architecture.<Dominio>` (si cambió estructura, rutas, responsabilidades o invariantes) y/o `Schemas.<Dominio>` (si cambió esquema, payload, persistencia o migración). Prohibido agregar crónicas por tarea, bitácoras o reportes de QA dentro de los mapas.
4. Antes de entregar, probar de forma hostil: ejecutar el juego en Play y revisar la consola desde el arranque, entradas extremas, repetidas y fuera de orden, jugador nuevo con estado vacío y con estado máximo, e interrupciones a mitad de cada operación de varios pasos. Prohibido debilitar o saltar pruebas existentes.
5. Emitir en el chat el bloque `MANIFIESTO DE ENTREGA — BUILDER AGENT` (lista completa de scripts e instancias tocados, cómo ejecutar y probar, pruebas corridas y resultado, áreas de riesgo, datos de prueba, efectos colaterales y limitaciones) para activar la revisión adversarial.

### Fase 3 — Revisión Adversarial en Paralelo (Potencia Máxima: `sonnet` / `sol` / `high`)
Se activan `CodeReviewAgent` y `UXReviewAgent` siempre, y `SecurityReviewAgent`, `ReliabilityReviewAgent` y `UIReviewAgent` según el riesgo del cambio (en caso de duda, se activan). Cada revisor sigue `agents/REVIEW-PROTOCOL.md`: asume que el código está roto, lee los scripts reales **antes** del Manifiesto, **ejecuta** en Studio e intenta romperlo, y entrega un dictamen con **registro de ataques** (mínimo 10 intentos, 4 categorías, 6 ejecutados) y reproducción de cada hallazgo. Lo que no pueda ejecutar queda `[NO VERIFICADO]` y bloquea. Antes de empezar leen `agents/BUGS-HISTORICOS.md`.
1. `CodeReviewAgent`: cumplimiento 1:1 del RC, corrección Luau, uso de `task.wait`/`task.spawn`/`task.defer` (prohibido `wait()`), señales en lugar de `while true do`, limpieza de conexiones, actualización documental y 0 errores en consola desde el arranque -> `DICTAMEN DE AUDITORÍA DE CÓDIGO` al `ApproverAgent`.
2. `SecurityReviewAgent`: ataca cada remote y punto de entrada con argumentos hostiles, ráfagas y replay; verifica autoridad del servidor en combate, inventario, economía, perfil y party, y duplicación de ítems o monedas -> `DICTAMEN DE AUDITORÍA DE SEGURIDAD` al `ApproverAgent`.
3. `ReliabilityReviewAgent`: fuerza interrupciones, perfiles con esquema anterior, salida del jugador o grupo, respawn, repetición para detectar fugas de conexiones y fallos de tiempo -> `DICTAMEN DE AUDITORÍA DE CONFIABILIDAD` al `ApproverAgent`.
4. `UXReviewAgent`: ejecuta cada `CA-XX`; flujos y estados (`idle`, `loading`, `empty`, `error`, `success`), jugador nuevo, doble clic, cierres limpios (`DialogView`, `WindowLayoutClient`), paridad PC + Mobile (`TouchEnabled`) y coincidencia entre lo mostrado y lo aplicado -> `DICTAMEN DE AUDITORÍA DE UX` al `ApproverAgent`.
5. `UIReviewAgent`: renderiza y mide; tolerancia cero a `Offset` indebido, `Scale` (`UDim2.fromScale`) + `UIAspectRatioConstraint`/`UISizeConstraint`/`UIScale`, `UITextSizeConstraint`, `UITheme`/`GlobalUIConfig`, `ZIndex`, texto largo, glifos y solapes o desbordes en PC y móvil, con capturas -> `DICTAMEN DE AUDITORÍA DE UI` al `ApproverAgent`.
(Cumpliendo `rc120`, ningún revisor crea instancias ni carpetas `Reports/` en Studio, ni modifica scripts o instancias, ni guarda; el código de prueba vive solo en la sesión de Play y los dictámenes se entregan en el chat. Si el Play usa un perfil o datos reales, lo declaran antes y revierten cualquier cambio).

### Fase 4 — Juicio Final (`ApproverAgent` — Potencia Máxima: `sonnet` / `sol` / `high`)
1. `ApproverAgent` verifica que corrieron todos los revisores que el riesgo exige, audita la calidad de cada dictamen (rechaza los que no tengan registro de ataques o evidencia de ejecución), reejecuta reproducciones y pruebas propias, deduplica hallazgos y resuelve contradicciones usando el `rcNNN` como árbitro. No puede descartar un hallazgo con evidencia.
2. Si existe al menos un `[BLOQUEANTE]`, `[MAYOR]` o `[NO VERIFICADO]` abierto: emite `RESOLUCIÓN DEL APPROVER AGENT — CAMBIOS REQUERIDOS` con una única `ORDEN DE CORRECCIÓN CONSOLIDADA ([FIX-01..N])` agrupada por script/instancia. `BuilderAgent` corrige y los revisores revisan de nuevo el diff completo reejecutando las reproducciones anteriores; solo el revisor que halló una falla la cierra. Tras 3 rondas con bloqueantes abiertos, se escala al PO.
3. Solo si todo está limpio de verdad: emite `RESOLUCIÓN DEL APPROVER AGENT — DESARROLLO APROBADO`, autorizando el cierre del `rcNNN` (con las notas de verificación reales, el historial de hallazgos y el **riesgo residual**, y recordando que guardar, derivar a `Dungeon_Helada`/`Prólogo` según `rc048` y publicar corresponde al PO).
4. Toda falla que el PO encuentre después de la aprobación se registra en `agents/BUGS-HISTORICOS.md`.

---

## 4. SEPARACIÓN DE FUENTES Y CONTEXTO DIRIGIDO

### Recorrido técnico en Studio (`Workspace.DevelopmentStandard`)
1. Leer primero: `DEV_PROMPT` -> HU asignada -> `PROJECT_ARCHITECTURE` -> `DEVELOPER_GUIDE`.
2. Leer después únicamente las subpáginas `Architecture/<Dominio>` y `Schemas/<Dominio>` pertinentes a la tarea; expandir lectura solo al descubrir una dependencia real.
3. Consultar `PROJECT_STANDARD` para las reglas técnicas y `RC-TEMPLATE` para la estructura del RC.
4. No leer `DevelopmentStandard.History` ni `ServerStorage.DevelopmentStandardHistory` en el recorrido normal.

### Documentos de Producto (Viven exclusivamente en el Proyecto Local — Mantenidos por el PM)
- Diseño y reglas de producto: `Vandrheim-Roblox/GDD_ROBLOX_MVP.md` (solo en proyecto local).
- Catálogo y reglas de skills: `Vandrheim-Roblox/SKILLS_CATALOG.md` (solo en proyecto local).
- Historias de usuario: `Vandrheim-Roblox/HU/` (solo en proyecto local).
- Políticas de assets: `ASSETS_POLICY`.
(`GDD` y `SKILLS_CATALOG` no deben guardarse dentro de Studio para evitar copias desactualizadas respecto al trabajo del PM).
]=]
