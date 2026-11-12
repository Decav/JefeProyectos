# Instrucciones de Agentes para Claude Code

Este repositorio se rige por el protocolo SDD definido en [`AGENTS.md`](./AGENTS.md) y en el catálogo [`agents/README.md`](./agents/README.md).

**Regla de formato:** No utilizar emojis ni íconos decorativos en ningún documento `.md`, especificación, RC ni reporte.

## Reglas rápidas para Claude
1. **Para redactar Specs / RCs:** Actúa como [`agents/SpecAgent.md`](./agents/SpecAgent.md) usando **Claude Opus (`opus`)**.
2. **Para implementar Specs / RCs aprobados:** Actúa como [`agents/BuilderAgent.md`](./agents/BuilderAgent.md) usando **Claude Opus (`opus`)**. Al finalizar, entrega un Manifiesto con archivos tocados, cómo probar y efectos colaterales, y ejecuta la **revisión adversarial** con subagentes en **Claude Opus (`opus`)**.
3. **Revisores (todos obligados por [`agents/REVIEW-PROTOCOL.md`](./agents/REVIEW-PROTOCOL.md): asumen que el código está roto, lo ejecutan y registran sus ataques):**
   - [`agents/CodeReviewAgent.md`](./agents/CodeReviewAgent.md): siempre.
   - [`agents/UXReviewAgent.md`](./agents/UXReviewAgent.md): siempre.
   - [`agents/SecurityReviewAgent.md`](./agents/SecurityReviewAgent.md): si hay fronteras de confianza, entradas de usuario, pagos, saldos o permisos.
   - [`agents/ReliabilityReviewAgent.md`](./agents/ReliabilityReviewAgent.md): si hay estado persistente, concurrencia, asincronía o ciclo de vida de recursos.
   - [`agents/UIReviewAgent.md`](./agents/UIReviewAgent.md): si hay interfaz visual.
   - En caso de duda, se activa el revisor.
4. **Juicio final:** [`agents/ApproverAgent.md`](./agents/ApproverAgent.md) (`opus`) verifica la cobertura y la calidad de los dictámenes, reejecuta pruebas, ordena `[FIX-XX]` al `BuilderAgent` o certifica `DESARROLLO APROBADO` con el riesgo residual.
5. **Si el usuario reporta una falla tras una aprobación:** regístrala en [`agents/BUGS-HISTORICOS.md`](./agents/BUGS-HISTORICOS.md).

Consulta siempre [`AGENTS.md`](./AGENTS.md) para el detalle completo del flujo.
