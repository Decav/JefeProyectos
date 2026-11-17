# Instrucciones de Agentes para Vandrheim-Roblox (Claude Code)

Lee y aplica obligatoriamente las reglas de [`AGENTS.md`](./AGENTS.md) y [`../AGENTS.md`](../AGENTS.md) para ejecutar el flujo SDD con revisión adversarial: `SpecAgent` -> `BuilderAgent` -> revisores (en Vandrheim solo `CodeReviewAgent`, siempre, y `UIReviewAgent`, si hay interfaz; `SecurityReviewAgent`, `ReliabilityReviewAgent` y `UXReviewAgent` no se activan salvo pedido del PO) -> `ApproverAgent`.

Todos los revisores y el aprobador siguen [`../agents/REVIEW-PROTOCOL.md`](../agents/REVIEW-PROTOCOL.md): asumen que el código está roto, lo ejecutan y registran sus ataques. Antes de construir o revisar, lee [`../agents/BUGS-HISTORICOS.md`](../agents/BUGS-HISTORICOS.md).

Regla de formato: No utilizar emojis ni íconos decorativos en ningún archivo `.md`, especificación, RC ni reporte.
