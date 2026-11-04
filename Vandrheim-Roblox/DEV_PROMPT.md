--[=[
# DEV_PROMPT — ORQUESTADOR SDD DE 6 AGENTES (VANDRHEIM ROBLOX STUDIO)

Este archivo conserva la asignación vigente y define la metodología obligatoria de trabajo en Roblox Studio bajo la arquitectura SDD (Spec-Driven Development) de 6 agentes conectados (`/agents/`) y la organización documental de `rc120`.

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

## 2. ARQUITECTURA DE 6 AGENTES Y MODELOS OBLIGATORIOS

| Etapa | Agente | Definición Local | Nivel | Claude | Codex | Antigravity | Rol y Permisos en Studio |
|---|---|---|---|---|---|---|---|
| 1 | `SpecAgent` | `agents/SpecAgent.md` | Máxima | `opus` | `sol` | `pro` (Argon) | Redacta el RC (`rcNNN`) en `Requirement/<Seccion>` y actualiza `Requirement.INDEX`. Prohibido tocar código de juego. |
| 2 | `BuilderAgent` | `agents/BuilderAgent.md` | Máxima | `opus` | `sol` | `pro` (Argon) | Implementa en Studio el RC aprobado, mantiene `Architecture`/`Schemas` vigentes y emite el Manifiesto de Entrega en el chat. |
| 3a | `CodeReviewAgent` | `agents/CodeReviewAgent.md` | Media | `sonnet` | `terra` / `luna-max` | `flash` (Flash) | Estricto Read-Only. Audita código Luau, arquitectura, autoridad servidor, señales, limpieza y docs -> informa a `ApproverAgent`. |
| 3b | `UXReviewAgent` | `agents/UXReviewAgent.md` | Media | `sonnet` | `terra` / `luna-max` | `flash` (Flash) | Estricto Read-Only. Audita flujos, estados (`idle/loading/empty/error/success`), cierres y paridad PC/Mobile -> informa a `ApproverAgent`. |
| 3c | `UIReviewAgent` | `agents/UIReviewAgent.md` | Media | `sonnet` | `terra` / `luna-max` | `flash` (Flash) | Estricto Read-Only. Audita cero tamaños fijos (`Offset`), uso de `Scale` + constraints, responsive, legibilidad y `ZIndex` -> informa a `ApproverAgent`. |
| 4 | `ApproverAgent` | `agents/ApproverAgent.md` | Media | `sonnet` | `terra` / `luna-max` | `flash` (Flash) | Read-Only en código. Recibe los 3 dictámenes; si hay fallos `[BLOQUEANTE]` o `[MAYOR]` emite la Orden de Corrección Consolidada (`[FIX-XX]`) hacia `BuilderAgent`, o certifica `DESARROLLO APROBADO Y LISTO`. |

---

## 3. FLUJO SDD PASO A PASO (RESPETANDO RC120)

Al renovar la asignación en la sección 1, indicar el modo solicitado, la fuente/HU, el RC asociado y las notas adicionales. Conservar siempre el texto de la tarea vigente mientras se ajusta el protocolo.

### Fase 1 — Especificación y Emisión de RC (`SpecAgent` — Opus / Sol / Argon)
Antes de implementar cualquier tarea:
1. Seguir el recorrido de contexto dirigido (sección 4) para inspeccionar la arquitectura, los contratos y las instancias reales afectadas en Studio.
2. Consultar `Workspace.DevelopmentStandard.RC-TEMPLATE` (idéntico a `Vandrheim-Roblox/RC-TEMPLATE.md`) y crear el RC en `Workspace.DevelopmentStandard.Requirement/<Seccion>/` con `Name` en formato `rc-titulo-descriptivo` (minúsculas, sin tildes ni espacios, sin incluir el número en el `Name`).
3. Asignar el siguiente ID estable `rcNNN` revisando `Requirement.INDEX` y los atributos `RCId`/encabezados de todo el árbol `Requirement`. Guardar el ID en el encabezado y en el atributo `RCId`.
4. Mantener las 10 secciones obligatorias de `RC-TEMPLATE` como `Script` con `Disabled = true` y `Source` compuesto únicamente por un comentario Luau válido (jamás `ModuleScript` ni código ejecutable). Detallar dentro del RC los contratos técnicos para `CodeReviewAgent`, la matriz de estados e interacción PC/Mobile para `UXReviewAgent` y las reglas de layout con `Scale` sin `Offset` fijo para `UIReviewAgent`.
5. Actualizar `Workspace.DevelopmentStandard.Requirement.INDEX` con ID, sección, título corto, Name y ruta exacta (sin duplicar estado ni aprobaciones en el índice).
6. Usar los defaults cerrados de HU/GDD. Toda decisión de producto pendiente se registra y consulta al PO/PM antes de continuar; prohibido inventar alcance o valores.
7. Detenerse y esperar la aprobación explícita del PO antes de pasar a la Fase 2.

### Fase 2 — Construcción en Studio (`BuilderAgent` — Opus / Sol / Argon)
Con el `rcNNN` explícitamente aprobado por el PO:
1. Actualizar el estado dentro del propio `rcNNN` a `EN IMPLEMENTACIÓN`.
2. Implementar en Studio únicamente el alcance aprobado (Código + estados UX + UI con `Scale` y constraints), manteniendo al servidor como autoridad de datos y operaciones críticas.
3. Actualizar en `Workspace.DevelopmentStandard` únicamente la descripción vigente de `Architecture.<Dominio>` (si cambió estructura, rutas, responsabilidades o invariantes) y/o `Schemas.<Dominio>` (si cambió esquema, payload, persistencia o migración). Prohibido agregar crónicas por tarea, bitácoras o reportes de QA dentro de los mapas.
4. Emitir en el chat el bloque `MANIFIESTO DE ENTREGA — BUILDER AGENT` para activar la triple auditoría.

### Fase 3 — Triple Auditoría Read-Only en Paralelo (`CodeReviewAgent` + `UXReviewAgent` + `UIReviewAgent` — Sonnet / Terra-Luna Max / Flash)
Los 3 agentes revisores inspeccionan en Studio los cambios realizados contra el `rcNNN`, `PROJECT_STANDARD`, `Architecture.<Dominio>` y `Schemas.<Dominio>` sin modificar ningún script ni instancia:
1. `CodeReviewAgent`: verifica cumplimiento 1:1 del RC, calidad Luau, autoridad del servidor, uso de `task.wait`/`task.spawn`/`task.defer` (prohibido `wait()`), señales en lugar de `while true do`, limpieza de conexiones, actualización documental y 0 errores en consola -> entrega `DICTAMEN DE AUDITORÍA DE CÓDIGO` al `ApproverAgent`.
2. `UXReviewAgent`: verifica flujos completos, estados (`idle`, `loading`, `empty`, `error`, `success`), prevención de doble clic, cierres limpios (`DialogView`, `WindowLayoutClient`) y paridad PC + Mobile (`TouchEnabled`) -> entrega `DICTAMEN DE AUDITORÍA DE UX` al `ApproverAgent`.
3. `UIReviewAgent`: verifica tolerancia cero a tamaños fijos (`Offset`), uso de `Scale` (`UDim2.fromScale`) + `UIAspectRatioConstraint`/`UISizeConstraint`/`UIScale`, `UITextSizeConstraint`, respeto a `UITheme`/`GlobalUIConfig`, `ZIndex` y ausencia de solapes o desbordes en PC y móvil -> entrega `DICTAMEN DE AUDITORÍA DE UI` al `ApproverAgent`.
(Cumpliendo `rc120`, ningún revisor crea instancias ni carpetas `Reports/` en Studio; los dictámenes se entregan en el chat).

### Fase 4 — Consolidación y Veredicto (`ApproverAgent` — Sonnet / Terra-Luna Max / Flash)
1. `ApproverAgent` recibe los 3 dictámenes (`Code`, `UX`, `UI`), deduplica hallazgos y resuelve cualquier contradicción usando el `rcNNN` como árbitro.
2. Si existe al menos un hallazgo `[BLOQUEANTE]` o `[MAYOR]`: emite `RESOLUCIÓN DEL APPROVER AGENT — CAMBIOS REQUERIDOS` con una única `ORDEN DE CORRECCIÓN CONSOLIDADA ([FIX-01..N])` agrupada por script/instancia para que `BuilderAgent` corrija y vuelva a pasar por revisión.
3. Si las 3 auditorías aprueban sin bloqueantes ni mayores: emite `RESOLUCIÓN DEL APPROVER AGENT — DESARROLLO APROBADO Y LISTO`, autorizando el cierre del `rcNNN` (con las notas de verificación reales y recordando que guardar, derivar a `Dungeon_Helada`/`Prólogo` según `rc048` y publicar corresponde al PO).

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
