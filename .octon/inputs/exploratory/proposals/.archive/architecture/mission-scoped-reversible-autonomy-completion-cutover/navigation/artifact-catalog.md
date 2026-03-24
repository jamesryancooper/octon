# Artifact Catalog

| Path | Purpose |
| --- | --- |
| `README.md` | Proposal entry point, scope, non-negotiable rules, and reading order |
| `proposal.yml` | Proposal registry metadata |
| `architecture-proposal.yml` | Architecture proposal classification |
| `architecture/target-architecture.md` | Final target state and atomic-cutover design |
| `architecture/implementation-plan.md` | Workstreams, sequencing, and promotion steps |
| `architecture/acceptance-criteria.md` | Merge-blocking completeness criteria |
| `architecture/validation-plan.md` | Conformance, negative, and integration test plan |
| `architecture/cutover-checklist.md` | Exact execution checklist for branch promotion |
| `navigation/source-of-truth-map.md` | Canonical placement and no-second-control-plane map |
| `resources/implementation-audit.md` | Source implementation audit included with the package |
| `resources/current-state-gap-analysis.md` | Gap summary derived from the implementation audit |
| `resources/mission-control-contracts.md` | Concrete contract sketches for missing control primitives |
| `resources/scenario-routing-design.md` | Derived scenario-resolution design and routing semantics |
| `resources/msraom-completeness-remediation.md` | Narrative rationale and resolved design choices |

## Package Use

This package is intended to be placed under:

`.octon/inputs/exploratory/proposals/architecture/mission-scoped-reversible-autonomy-completion-cutover/`

and then promoted by implementing the durable runtime/policy/spec/docs changes it
describes.

## Canonical Rule

No file in this package becomes operational truth by itself. Anything binding
must be promoted into canonical repo surfaces under `framework/**`,
`instance/**`, `state/**`, or `generated/**`.
