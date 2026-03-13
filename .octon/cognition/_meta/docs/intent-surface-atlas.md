# Cognition Intent-to-Surface Atlas

Intent-first routing map across cognition runtime, governance, and practices.

## How To Use

1. Start with your task intent in the table below.
2. Open the primary entrypoint first.
3. Use companion paths for supporting contracts, operations, and evidence.

## Intent Routing Table

| Intent | Primary Entrypoint | Companion Paths |
|---|---|---|
| Find constraints or operational context before work | `/.octon/cognition/runtime/context/index.yml` | `/.octon/cognition/runtime/context/constraints.md`, `/.octon/cognition/runtime/context/decisions.md` |
| Review or add architecture decisions | `/.octon/cognition/runtime/decisions/index.yml` | `/.octon/cognition/runtime/context/decisions.md`, `/.octon/cognition/runtime/evidence/index.yml` |
| Plan or audit migration records | `/.octon/cognition/runtime/migrations/index.yml` | `/.octon/cognition/practices/methodology/migrations/README.md`, `/.octon/cognition/runtime/evidence/index.yml` |
| Generate weekly scorecard digest | `/.octon/cognition/runtime/evaluations/digests/index.yml` | `/.octon/cognition/runtime/context/metrics-scorecard.md`, `/.octon/cognition/practices/operations/weekly-evaluations.md` |
| Track remediation actions from evaluations | `/.octon/cognition/runtime/evaluations/actions/index.yml` | `/.octon/cognition/runtime/evaluations/actions/open-actions.yml`, `/.octon/cognition/practices/operations/weekly-evaluations.md` |
| Trace knowledge graph links and provenance | `/.octon/cognition/runtime/knowledge/index.yml` | `/.octon/cognition/runtime/knowledge/graph/index.yml`, `/.octon/cognition/runtime/knowledge/sources/index.yml`, `/.octon/cognition/runtime/knowledge/queries/index.yml` |
| Consume or regenerate derived runtime projections | `/.octon/cognition/runtime/projections/index.yml` | `/.octon/cognition/runtime/projections/definitions/index.yml`, `/.octon/cognition/runtime/projections/materialized/index.yml` |
| Interpret governance contracts and exceptions | `/.octon/cognition/governance/index.yml` | `/.octon/cognition/governance/principles/README.md`, `/.octon/cognition/governance/controls/index.yml`, `/.octon/cognition/governance/exceptions/README.md` |
| Apply methodology and execution standards | `/.octon/cognition/practices/index.yml` | `/.octon/cognition/practices/methodology/index.yml`, `/.octon/cognition/practices/operations/index.yml` |
| Triage cognition policy lint and drift | `/.octon/cognition/practices/operations/governance-lint-triage.md` | `/.octon/cognition/_ops/principles/scripts/lint-principles-governance.sh`, `/.octon/assurance/runtime/_ops/scripts/validate-harness-structure.sh` |

## Escalation Hints

- If your task touches more than one row, start from the highest-risk intent first.
- If ownership is still unclear, open `/.octon/cognition/README.md` and then recurse via linked indexes.
