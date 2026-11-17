# Instrucciones de Agentes para Claude Code

Este repositorio se rige por el protocolo SDD definido en [`AGENTS.md`](./AGENTS.md) y en el catálogo [`agents/README.md`](./agents/README.md).

**Regla de formato:** No utilizar emojis ni íconos decorativos en ningún documento `.md`, especificación, RC ni reporte.

## Reglas rápidas para Claude
1. **Para redactar Specs / RCs:** Actúa como [`agents/SpecAgent.md`](./agents/SpecAgent.md) usando **Claude Opus (`opus`) con esfuerzo `low`**.
2. **Para implementar Specs / RCs aprobados:** Actúa como [`agents/BuilderAgent.md`](./agents/BuilderAgent.md) usando **Claude Sonnet 5.5 (`sonnet`) con esfuerzo `medium`**. Al finalizar, entrega un Manifiesto con archivos tocados, cómo probar y efectos colaterales, y ejecuta la **revisión adversarial** con subagentes en **Claude Haiku 5.5 (`haiku`) con esfuerzo `xhigh` (Extra)**.
3. **Revisores (modelo `haiku`, esfuerzo `xhigh`; todos obligados por [`agents/REVIEW-PROTOCOL.md`](./agents/REVIEW-PROTOCOL.md): asumen que el código está roto, lo ejecutan y registran sus ataques):**
   - [`agents/CodeReviewAgent.md`](./agents/CodeReviewAgent.md): siempre.
   - [`agents/UXReviewAgent.md`](./agents/UXReviewAgent.md): siempre.
   - [`agents/SecurityReviewAgent.md`](./agents/SecurityReviewAgent.md): si hay fronteras de confianza, entradas de usuario, pagos, saldos o permisos.
   - [`agents/ReliabilityReviewAgent.md`](./agents/ReliabilityReviewAgent.md): si hay estado persistente, concurrencia, asincronía o ciclo de vida de recursos.
   - [`agents/UIReviewAgent.md`](./agents/UIReviewAgent.md): si hay interfaz visual.
   - En caso de duda, se activa el revisor.
   - **Nivel de revisión (S / M / L, [`agents/REVIEW-PROTOCOL.md`](./agents/REVIEW-PROTOCOL.md) sección 9.1):** en nivel S (cambio acotado, sin fronteras de confianza, estado ni interfaz nueva) basta `CodeReviewAgent`, que también ejecuta los `CA-XX`; los mínimos de ataques bajan a 4 (S), 6 (M) y 10 (L). Desde la ronda v2 se revisa solo el diff del fix y una muestra de regresión.
4. **Juicio final:** [`agents/ApproverAgent.md`](./agents/ApproverAgent.md) (`haiku`, esfuerzo `xhigh`) verifica la cobertura y la calidad de los dictámenes, reejecuta pruebas, ordena `[FIX-XX]` al `BuilderAgent` o certifica `DESARROLLO APROBADO` con el riesgo residual.
5. **Si el usuario reporta una falla tras una aprobación:** regístrala en [`agents/BUGS-HISTORICOS.md`](./agents/BUGS-HISTORICOS.md).

Consulta siempre [`AGENTS.md`](./AGENTS.md) para el detalle completo del flujo.
