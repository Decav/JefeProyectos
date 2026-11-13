# Protocolo Maestro de Desarrollo SDD (Spec-Driven Development) — Agentes Conectados

Este workspace opera bajo una arquitectura estricta **SDD (Spec-Driven Development)** gobernada por agentes interconectados ubicados en [`agents/`](./agents/README.md): un especificador, un constructor, **cinco revisores adversariales** y un aprobador.

**Regla de estilo documental:** No utilizar emojis ni íconos decorativos en ningún archivo `.md`, especificación, RC, comentario de código ni reporte de auditoría. Mantener un formato estrictamente técnico, sobrio y profesional.

**Regla de independencia de stack:** los agentes del flujo SDD no están atados a ninguna tecnología. Descubren cómo se construye y se prueba cada proyecto leyendo el propio repositorio.

---

## 1. Matriz Oficial de Agentes y Modelos por Plataforma

Cada rol del ciclo SDD DEBE ejecutarse con el modelo correspondiente a su nivel de potencia según el entorno activo (**Claude**, **Codex** o **Antigravity**). **Los revisores y el aprobador corren con Potencia Máxima**, igual que el Builder: un juez más débil que el autor aprueba lo que no entiende.

| Etapa  | Agente                     | Definición                                                               | Nivel      | Claude   | Codex | Antigravity            | Permisos sobre Código                               |
| :----: | :------------------------- | :----------------------------------------------------------------------- | :--------- | :------- | :---- | :--------------------- | :-------------------------------------------------- |
| **1**  | **SpecAgent**              | [`agents/SpecAgent.md`](./agents/SpecAgent.md)                           | **Máxima** | `sonnet` | `sol` | `high` (Hydrogen High) | **Prohibido tocar código** (Solo redacta Spec / RC) |
| **2**  | **BuilderAgent**           | [`agents/BuilderAgent.md`](./agents/BuilderAgent.md)                     | **Máxima** | `sonnet` | `sol` | `high` (Hydrogen High) | **Lectura y Escritura** de código de producción     |
| **3a** | **CodeReviewAgent**        | [`agents/CodeReviewAgent.md`](./agents/CodeReviewAgent.md)               | **Máxima** | `sonnet` | `sol` | `high` (Hydrogen High) | **Read-only** en producción; ejecuta y prueba       |
| **3b** | **SecurityReviewAgent**    | [`agents/SecurityReviewAgent.md`](./agents/SecurityReviewAgent.md)       | **Máxima** | `sonnet` | `sol` | `high` (Hydrogen High) | **Read-only** en producción; ataca el sistema       |
| **3c** | **ReliabilityReviewAgent** | [`agents/ReliabilityReviewAgent.md`](./agents/ReliabilityReviewAgent.md) | **Máxima** | `sonnet` | `sol` | `high` (Hydrogen High) | **Read-only** en producción; fuerza fallos          |
| **3d** | **UXReviewAgent**          | [`agents/UXReviewAgent.md`](./agents/UXReviewAgent.md)                   | **Máxima** | `sonnet` | `sol` | `high` (Hydrogen High) | **Read-only** en producción; ejecuta cada `CA-XX`   |
| **3e** | **UIReviewAgent**          | [`agents/UIReviewAgent.md`](./agents/UIReviewAgent.md)                   | **Máxima** | `sonnet` | `sol` | `high` (Hydrogen High) | **Read-only** en producción; renderiza y mide       |
| **4**  | **ApproverAgent**          | [`agents/ApproverAgent.md`](./agents/ApproverAgent.md)                   | **Máxima** | `sonnet` | `sol` | `high` (Hydrogen High) | **Read-only** en producción; audita a los revisores |

**Recomendación de diversidad:** si el Builder usó una familia de modelos, conviene que los revisores sean de otra familia (por ejemplo, construye Claude y revisan Codex o Antigravity), para no compartir los mismos puntos ciegos.

**Reglas comunes de revisión:** [`agents/REVIEW-PROTOCOL.md`](./agents/REVIEW-PROTOCOL.md) (obligatorio para los cinco revisores y el aprobador). **Memoria de fallas:** [`agents/BUGS-HISTORICOS.md`](./agents/BUGS-HISTORICOS.md).

---

## 2. Reglas de Activación Automática según el Pedido del Usuario

### A. Cuando el usuario pide redactar una Spec, RC o analizar una HU ("Escribe el spec de...", "Prepara el RC de...")
1. Activar **`SpecAgent`** leyendo [`agents/SpecAgent.md`](./agents/SpecAgent.md) con el modelo de **Potencia Máxima** (`sonnet` / `sol` / `high` Hydrogen High).
2. Inspeccionar primero el repositorio real, la arquitectura y las plantillas del proyecto (`HU-TEMPLATE.md`, `RC-TEMPLATE.md`).
3. Generar la Spec / RC completa con contratos técnicos (`TECH-XX`), estados de experiencia de usuario (`UX-XX`), reglas de interfaz fluida sin tamaños fijos (`UI-XX`) y criterios Gherkin (`CA-XX`).
4. **Detenerse y esperar aprobación del usuario** antes de pasar al `BuilderAgent`.

### B. Cuando el usuario aprueba la Spec / RC o pide implementar ("Implementa el spec...", "Ejecuta el ciclo SDD de...")
Ejecutar el pipeline completo hasta obtener la aprobación del `ApproverAgent`:

1. **Construcción (`BuilderAgent`, Potencia Máxima):**
   - Leer [`agents/BuilderAgent.md`](./agents/BuilderAgent.md) y la Spec/RC aprobada.
   - Implementar el 100 % y emitir el **`MANIFIESTO DE ENTREGA — BUILDER AGENT`**, que debe incluir: lista completa de archivos tocados, cómo ejecutar y probar el cambio, pruebas corridas con su resultado, datos de prueba y efectos colaterales. Sin eso, los revisores devuelven la entrega.
2. **Revisión adversarial en paralelo (read-only, Potencia Máxima):**
   - Activar a los revisores **según el riesgo** del cambio (tabla de activación en [`agents/REVIEW-PROTOCOL.md`](./agents/REVIEW-PROTOCOL.md), sección 9):
     - **`CodeReviewAgent`** y **`UXReviewAgent`**: siempre.
     - **`SecurityReviewAgent`**: si el cambio toca fronteras de confianza (red, cliente-servidor, entradas de usuario, pagos, saldos, permisos, secretos).
     - **`ReliabilityReviewAgent`**: si toca estado persistente, concurrencia, asincronía, ciclo de vida de recursos, tareas en segundo plano o dependencias externas.
     - **`UIReviewAgent`**: si hay interfaz visual.
   - Cada revisor **asume que el código está roto, lo ejecuta, intenta romperlo** y entrega un dictamen con **registro de ataques**. Un dictamen sin evidencia de ejecución es inválido. En caso de duda, se activa el revisor.
3. **Juicio final (`ApproverAgent`, Potencia Máxima):**
   - Verifica la cobertura de revisores, audita la calidad de cada dictamen, reejecuta reproducciones y pruebas propias.
   - **Si hay `[BLOQUEANTE]`, `[MAYOR]` o `[NO VERIFICADO]` abiertos:** emite `CAMBIOS REQUERIDOS` con la **orden de corrección consolidada (`[FIX-01..N]`)**. El Builder corrige; los revisores revisan de nuevo el diff completo y reejecutan las reproducciones anteriores. Solo el revisor que halló una falla puede cerrarla.
   - **Si todo está limpio de verdad:** emite `DESARROLLO APROBADO` con el historial de hallazgos y el **riesgo residual**.
   - Tras 3 rondas con bloqueantes abiertos, escala al usuario.

### C. Cuando el usuario reporta una falla después de una aprobación
Registrar la falla en [`agents/BUGS-HISTORICOS.md`](./agents/BUGS-HISTORICOS.md) con su clase, el revisor que debió detectarla y la prueba que la habría revelado. Los revisores la incorporan a su búsqueda.

---

## 3. Otros Agentes Especialistas Disponibles en [`agents/`](./agents/)

- **Producto y Alcance Macro:** [`agents/PMAgent.md`](./agents/PMAgent.md)
- **Producción de Assets Visuales (Aislados):** [`agents/DesignAgent.md`](./agents/DesignAgent.md)
- **Biomecánica y Animación Roblox R15:** [`agents/RobloxAnimatorAgent.md`](./agents/RobloxAnimatorAgent.md)
- **Asistente de Estudio (`Estudio/{asignatura}/`):** [`agents/StudyAgent.md`](./agents/StudyAgent.md)
- **Diagnóstico y Organización de macOS:** [`agents/MacAdvisorAgent.md`](./agents/MacAdvisorAgent.md)
