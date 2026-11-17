# Protocolo Maestro de Desarrollo SDD (Spec-Driven Development) — Agentes Conectados

Este workspace opera bajo una arquitectura estricta **SDD (Spec-Driven Development)** gobernada por agentes interconectados ubicados en [`agents/`](./agents/README.md): un especificador, un constructor, **cinco revisores adversariales** y un aprobador.

**Regla de estilo documental:** No utilizar emojis ni íconos decorativos en ningún archivo `.md`, especificación, RC, comentario de código ni reporte de auditoría. Mantener un formato estrictamente técnico, sobrio y profesional.

**Regla de independencia de stack:** los agentes del flujo SDD no están atados a ninguna tecnología. Descubren cómo se construye y se prueba cada proyecto leyendo el propio repositorio.

---

## 1. Matriz Oficial de Agentes y Modelos por Plataforma

Cada rol del ciclo SDD DEBE ejecutarse con el modelo y el nivel de esfuerzo de esta tabla según el entorno activo (**Claude**, **Codex** o **Antigravity**). El perfil está optimizado para reducir tiempo y cuota por tarea: el Spec y el Builder usan modelos de razonamiento medio o bajo, y los revisores y el aprobador usan modelos más livianos con esfuerzo alto, porque su fiabilidad depende de **ejecutar y registrar evidencia** (`agents/REVIEW-PROTOCOL.md`), no del tamaño del modelo.

| Etapa  | Agente                     | Definición                                                               | Perfil     | Claude   | Codex | Antigravity            | Permisos sobre Código                               |
| :----: | :------------------------- | :----------------------------------------------------------------------- | :--------- | :------- | :---- | :--------------------- | :-------------------------------------------------- |
| **1**  | **SpecAgent**              | [`agents/SpecAgent.md`](./agents/SpecAgent.md)                           | **Costo reducido** | `opus` (esfuerzo `low`) | `sol` (GPT Sol, `low`) | `high` (Hydrogen High) | **Prohibido tocar código** (Solo redacta Spec / RC) |
| **2**  | **BuilderAgent**           | [`agents/BuilderAgent.md`](./agents/BuilderAgent.md)                     | **Costo reducido** | `sonnet` (esfuerzo `medium`) | `terra` (GPT Terra, `medium`) | `medium` (Hydrogen Medium) | **Lectura y Escritura** de código de producción     |
| **3a** | **CodeReviewAgent**        | [`agents/CodeReviewAgent.md`](./agents/CodeReviewAgent.md)               | **Costo reducido** | `haiku` (esfuerzo `xhigh`, Extra) | `luna` (GPT Luna, `max`) | `medium` (Flash Medium) | **Read-only** en producción; ejecuta y prueba       |
| **3b** | **SecurityReviewAgent**    | [`agents/SecurityReviewAgent.md`](./agents/SecurityReviewAgent.md)       | **Costo reducido** | `haiku` (esfuerzo `xhigh`, Extra) | `luna` (GPT Luna, `max`) | `medium` (Flash Medium) | **Read-only** en producción; ataca el sistema       |
| **3c** | **ReliabilityReviewAgent** | [`agents/ReliabilityReviewAgent.md`](./agents/ReliabilityReviewAgent.md) | **Costo reducido** | `haiku` (esfuerzo `xhigh`, Extra) | `luna` (GPT Luna, `max`) | `medium` (Flash Medium) | **Read-only** en producción; fuerza fallos          |
| **3d** | **UXReviewAgent**          | [`agents/UXReviewAgent.md`](./agents/UXReviewAgent.md)                   | **Costo reducido** | `haiku` (esfuerzo `xhigh`, Extra) | `luna` (GPT Luna, `max`) | `medium` (Flash Medium) | **Read-only** en producción; ejecuta cada `CA-XX`   |
| **3e** | **UIReviewAgent**          | [`agents/UIReviewAgent.md`](./agents/UIReviewAgent.md)                   | **Costo reducido** | `haiku` (esfuerzo `xhigh`, Extra) | `luna` (GPT Luna, `max`) | `medium` (Flash Medium) | **Read-only** en producción; renderiza y mide       |
| **4**  | **ApproverAgent**          | [`agents/ApproverAgent.md`](./agents/ApproverAgent.md)                   | **Costo reducido** | `haiku` (esfuerzo `xhigh`, Extra) | `luna` (GPT Luna, `max`) | `high` (Flash High) | **Read-only** en producción; audita a los revisores |

**Recomendación de diversidad:** si el Builder usó una familia de modelos, conviene que los revisores sean de otra familia (por ejemplo, construye Claude y revisan Codex o Antigravity), para no compartir los mismos puntos ciegos.

**Reglas comunes de revisión:** [`agents/REVIEW-PROTOCOL.md`](./agents/REVIEW-PROTOCOL.md) (obligatorio para los cinco revisores y el aprobador). **Memoria de fallas:** [`agents/BUGS-HISTORICOS.md`](./agents/BUGS-HISTORICOS.md).

---

## 2. Reglas de Activación Automática según el Pedido del Usuario

### A. Cuando el usuario pide redactar una Spec, RC o analizar una HU ("Escribe el spec de...", "Prepara el RC de...")
1. Activar **`SpecAgent`** leyendo [`agents/SpecAgent.md`](./agents/SpecAgent.md) con su modelo asignado (`opus` low / `sol` low / `high` Hydrogen High).
2. Inspeccionar primero el repositorio real, la arquitectura y las plantillas del proyecto (`HU-TEMPLATE.md`, `RC-TEMPLATE.md`).
3. Generar la Spec / RC completa con contratos técnicos (`TECH-XX`), estados de experiencia de usuario (`UX-XX`), reglas de interfaz fluida sin tamaños fijos (`UI-XX`) y criterios Gherkin (`CA-XX`).
4. **Detenerse y esperar aprobación del usuario** antes de pasar al `BuilderAgent`.

### B. Cuando el usuario aprueba la Spec / RC o pide implementar ("Implementa el spec...", "Ejecuta el ciclo SDD de...")
Ejecutar el pipeline completo hasta obtener la aprobación del `ApproverAgent`:

1. **Construcción (`BuilderAgent`, `sonnet` medium / `terra` medium / Hydrogen Medium):**
   - Leer [`agents/BuilderAgent.md`](./agents/BuilderAgent.md) y la Spec/RC aprobada.
   - Implementar el 100 % y emitir el **`MANIFIESTO DE ENTREGA — BUILDER AGENT`**, que debe incluir: lista completa de archivos tocados, cómo ejecutar y probar el cambio, pruebas corridas con su resultado, datos de prueba y efectos colaterales. Sin eso, los revisores devuelven la entrega.
2. **Revisión adversarial en paralelo (read-only, `haiku` Extra / `luna` Max / Flash Medium):**
   - Fijar el **nivel de revisión** (S / M / L, [`agents/REVIEW-PROTOCOL.md`](./agents/REVIEW-PROTOCOL.md), sección 9.1): el `SpecAgent` lo propone y el `BuilderAgent` lo confirma en el Manifiesto. En nivel **S** basta `CodeReviewAgent` (que también ejecuta los `CA-XX`); en **M** y **L** se activan los revisores según el riesgo.
   - Activar a los revisores **según el riesgo** del cambio (tabla de activación en [`agents/REVIEW-PROTOCOL.md`](./agents/REVIEW-PROTOCOL.md), sección 9):
     - **`CodeReviewAgent`** y **`UXReviewAgent`**: siempre.
     - **`SecurityReviewAgent`**: si el cambio toca fronteras de confianza (red, cliente-servidor, entradas de usuario, pagos, saldos, permisos, secretos).
     - **`ReliabilityReviewAgent`**: si toca estado persistente, concurrencia, asincronía, ciclo de vida de recursos, tareas en segundo plano o dependencias externas.
     - **`UIReviewAgent`**: si hay interfaz visual.
   - Cada revisor **asume que el código está roto, lo ejecuta, intenta romperlo** y entrega un dictamen con **registro de ataques** (mínimos por nivel: S 4, M 6, L 10). Un dictamen sin evidencia de ejecución es inválido. En caso de duda, se activa el revisor.
3. **Juicio final (`ApproverAgent`, `haiku` Extra / `luna` Max / Flash High):**
   - Verifica la cobertura de revisores, audita la calidad de cada dictamen y reejecuta reproducciones por muestreo según el nivel (S: 1 ataque, M: 2 más uno propio, L: uno por dictamen más uno propio).
   - **Si hay `[BLOQUEANTE]`, `[MAYOR]` o `[NO VERIFICADO]` abiertos:** emite `CAMBIOS REQUERIDOS` con la **orden de corrección consolidada (`[FIX-01..N]`)**. El Builder corrige; en las rondas v2 en adelante cada revisor revisa el diff del fix, reejecuta las reproducciones de sus hallazgos abiertos y una muestra de regresión de 3 ataques (revisión completa solo si el fix tocó código fuera de los `[FIX-XX]` o si es nivel L con un bloqueante de seguridad o confiabilidad). Solo el revisor que halló una falla puede cerrarla.
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
