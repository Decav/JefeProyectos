# Protocolo Maestro de Desarrollo SDD (Spec-Driven Development) — 6 Agentes Conectados

Este workspace opera bajo una arquitectura estricta **SDD (Spec-Driven Development)** gobernada por **6 agentes interconectados** ubicados en [`agents/`](./agents/README.md).

**Regla de estilo documental:** No utilizar emojis ni íconos decorativos en ningún archivo `.md`, especificación, RC, comentario de código ni reporte de auditoría. Mantener un formato estrictamente técnico, sobrio y profesional.

---

## 1. Matriz Oficial de Agentes y Modelos por Plataforma

Cada rol del ciclo SDD DEBE ejecutarse con el modelo correspondiente a su nivel de potencia según el entorno activo (**Claude**, **Codex** o **Antigravity**):

| Etapa | Agente | Definición | Nivel | Claude | Codex | Antigravity | Permisos sobre Código |
| :-: | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **1** | **SpecAgent** | [`agents/SpecAgent.md`](./agents/SpecAgent.md) | **Máxima** | `opus` | `sol` | `pro` (Argon) | **Prohibido tocar código** (Solo redacta Spec / RC) |
| **2** | **BuilderAgent** | [`agents/BuilderAgent.md`](./agents/BuilderAgent.md) | **Máxima** | `opus` | `sol` | `pro` (Argon) | **Lectura y Escritura** de código de producción |
| **3a** | **CodeReviewAgent** | [`agents/CodeReviewAgent.md`](./agents/CodeReviewAgent.md) | **Media** | `sonnet` | `terra` / `luna-max` | `flash` (Flash) | **Estricto Read-Only** (Informa a `ApproverAgent`) |
| **3b** | **UXReviewAgent** | [`agents/UXReviewAgent.md`](./agents/UXReviewAgent.md) | **Media** | `sonnet` | `terra` / `luna-max` | `flash` (Flash) | **Estricto Read-Only** (Informa a `ApproverAgent`) |
| **3c** | **UIReviewAgent** | [`agents/UIReviewAgent.md`](./agents/UIReviewAgent.md) | **Media** | `sonnet` | `terra` / `luna-max` | `flash` (Flash) | **Estricto Read-Only** (Informa a `ApproverAgent`) |
| **4** | **ApproverAgent** | [`agents/ApproverAgent.md`](./agents/ApproverAgent.md) | **Media** | `sonnet` | `terra` / `luna-max` | `flash` (Flash) | **Read-Only en código** (Consolida fixes o aprueba) |

---

## 2. Reglas de Activación Automática según el Pedido del Usuario

### A. Cuando el usuario pide redactar una Spec, RC o analizar una HU ("Escribe el spec de...", "Prepara el RC de...")
1. Activar **`SpecAgent`** leyendo [`agents/SpecAgent.md`](./agents/SpecAgent.md) con el modelo de **Potencia Máxima** (`opus` / `sol` / `argon`).
2. Inspeccionar primero el repositorio real, la arquitectura y las plantillas del proyecto (`HU-TEMPLATE.md`, `RC-TEMPLATE.md`).
3. Generar la Spec / RC completa con contratos técnicos (`TECH-XX`), estados de experiencia de usuario (`UX-XX`), reglas de interfaz fluida sin tamaños fijos (`UI-XX`) y criterios Gherkin (`CA-XX`).
4. **Detenerse y esperar aprobación del usuario** antes de pasar al `BuilderAgent`.

### B. Cuando el usuario aprueba la Spec / RC o pide implementar ("Implementa el spec...", "Ejecuta el ciclo SDD de...")
Ejecutar el pipeline completo hasta obtener la aprobación del `ApproverAgent`:

1. **Construcción (`BuilderAgent` — `opus` / `sol` / `argon`):**
   - Leer [`agents/BuilderAgent.md`](./agents/BuilderAgent.md) y la Spec/RC aprobada.
   - Implementar el 100% (código + estados UX + layout UI fluido/responsive) y emitir el bloque **`MANIFIESTO DE ENTREGA — BUILDER AGENT`**.
2. **Triple Auditoría en Paralelo (Read-Only — `sonnet` / `terra` o `luna-max` / `flash`):**
   - Invocar (como subagentes o pases de auditoría independientes con modelo medio) a:
     - **`CodeReviewAgent`** ([`agents/CodeReviewAgent.md`](./agents/CodeReviewAgent.md)): revisa calidad, arquitectura, seguridad, errores y limpieza de recursos → entrega `DICTAMEN DE AUDITORÍA DE CÓDIGO` al `ApproverAgent`.
     - **`UXReviewAgent`** ([`agents/UXReviewAgent.md`](./agents/UXReviewAgent.md)): revisa flujos, estados `idle/loading/empty/error/success`, prevención de doble clic y soporte PC/Mobile → entrega `DICTAMEN DE AUDITORÍA DE UX` al `ApproverAgent`.
     - **`UIReviewAgent`** ([`agents/UIReviewAgent.md`](./agents/UIReviewAgent.md)): revisa tolerancia cero a tamaños fijos indebidos, responsive multi-resolución, legibilidad, contraste y overflow → entrega `DICTAMEN DE AUDITORÍA DE UI` al `ApproverAgent`.
3. **Consolidación y Veredicto (`ApproverAgent` — `sonnet` / `terra` o `luna-max` / `flash`):**
   - Leer [`agents/ApproverAgent.md`](./agents/ApproverAgent.md) y recibir los 3 dictámenes.
   - **Si hay hallazgos `[BLOQUEANTE]` o `[MAYOR]`:** emitir `RESOLUCIÓN DEL APPROVER AGENT — CAMBIOS REQUERIDOS` con la **`ORDEN DE CORRECCIÓN CONSOLIDADA ([FIX-01..N])`** agrupada por archivo hacia el `BuilderAgent`, quien corrige y vuelve a pasar por revisión.
   - **Si las 3 auditorías aprueban:** emitir `RESOLUCIÓN DEL APPROVER AGENT — DESARROLLO APROBADO Y LISTO` e informar al usuario.

---

## 3. Otros Agentes Especialistas Disponibles en [`agents/`](./agents/)

- **Producto y Alcance Macro:** [`agents/PMAgent.md`](./agents/PMAgent.md)
- **Producción de Assets Visuales (Aislados):** [`agents/DesignAgent.md`](./agents/DesignAgent.md)
- **Biomecánica y Animación Roblox R15:** [`agents/RobloxAnimatorAgent.md`](./agents/RobloxAnimatorAgent.md)
- **Asistente de Estudio (`Estudio/{asignatura}/`):** [`agents/StudyAgent.md`](./agents/StudyAgent.md)
- **Diagnóstico y Organización de macOS:** [`agents/MacAdvisorAgent.md`](./agents/MacAdvisorAgent.md)
