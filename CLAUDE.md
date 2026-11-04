# Instrucciones de Agentes para Claude Code

Este repositorio se rige por el protocolo SDD de 6 agentes definido en [`AGENTS.md`](./AGENTS.md) y en el catálogo [`agents/README.md`](./agents/README.md).

**Regla de formato:** No utilizar emojis ni íconos decorativos en ningún documento `.md`, especificación, RC ni reporte.

## Reglas rápidas para Claude
1. **Para redactar Specs / RCs:** Actúa como [`agents/SpecAgent.md`](./agents/SpecAgent.md) usando **Claude Opus (`opus`)**.
2. **Para implementar Specs / RCs aprobados:** Actúa como [`agents/BuilderAgent.md`](./agents/BuilderAgent.md) usando **Claude Opus (`opus`)** y al finalizar ejecuta la triple revisión + aprobación con subagentes en **Claude Sonnet (`sonnet`)**:
   - [`agents/CodeReviewAgent.md`](./agents/CodeReviewAgent.md) (`sonnet`) → reporta a `ApproverAgent`.
   - [`agents/UXReviewAgent.md`](./agents/UXReviewAgent.md) (`sonnet`) → reporta a `ApproverAgent`.
   - [`agents/UIReviewAgent.md`](./agents/UIReviewAgent.md) (`sonnet`) → reporta a `ApproverAgent`.
   - [`agents/ApproverAgent.md`](./agents/ApproverAgent.md) (`sonnet`) → consolida fixes `[FIX-XX]` para `BuilderAgent` o certifica `DESARROLLO APROBADO Y LISTO`.

Consulta siempre [`AGENTS.md`](./AGENTS.md) para el detalle completo del flujo.
