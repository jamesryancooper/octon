# Source Of Truth Map

## Proposal

- proposal id: `proposal-program-runner-generated-state-publication`
- package role: Proposal Program Runner Generated State Publication
- source lineage: `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-e2e-execution-program/resources/source-lifecycle-improvement.md` and `.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-e2e-execution-program/resources/source-traceability-matrix.md`

## Authority Boundaries

- Proposal-local files are non-authoritative planning and review artifacts.
- Authored authority remains under `.octon/framework/**` and `.octon/instance/**`.
- Retained run evidence belongs under `.octon/state/evidence/**`.
- Generated outputs under `.octon/generated/**` are derived and must not satisfy route receipts.
- Parent program evidence may coordinate and summarize child progress, but never satisfies child receipts, promotion targets, validation verdicts, or archive metadata.
