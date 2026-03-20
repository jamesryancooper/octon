# Cognition Intent-to-Surface Atlas

Intent-first routing map across cognition runtime, governance, and practices.

## How To Use

1. Start with your task intent in the table below.
2. Open the primary entrypoint first.
3. Use companion paths for supporting contracts, operations, and evidence.

## Intent Routing Table

| Intent | Primary Entrypoint | Companion Paths |
|---|---|---|
| Find constraints or operational context before work | `/.octon/instance/cognition/context/index.yml` | `/.octon/instance/cognition/context/shared/constraints.md`, `/.octon/instance/cognition/decisions/README.md` |
| Review or add architecture decisions | `/.octon/instance/cognition/decisions/index.yml` | `/.octon/instance/cognition/decisions/README.md`, `/.octon/framework/cognition/runtime/evidence/index.yml` |
| Plan or audit migration records | `/.octon/instance/cognition/context/shared/migrations/index.yml` | `/.octon/framework/cognition/practices/methodology/migrations/README.md`, `/.octon/framework/cognition/runtime/evidence/index.yml` |
| Generate weekly scorecard digest | `/.octon/framework/cognition/runtime/evaluations/digests/index.yml` | `/.octon/instance/cognition/context/shared/metrics-scorecard.md`, `/.octon/framework/cognition/practices/operations/weekly-evaluations.md` |
| Track remediation actions from evaluations | `/.octon/framework/cognition/runtime/evaluations/actions/index.yml` | `/.octon/framework/cognition/runtime/evaluations/actions/open-actions.yml`, `/.octon/framework/cognition/practices/operations/weekly-evaluations.md` |
| Trace knowledge graph links and provenance | `/.octon/instance/cognition/context/shared/knowledge/index.yml` | `/.octon/instance/cognition/context/shared/knowledge/graph/index.yml`, `/.octon/instance/cognition/context/shared/knowledge/sources/index.yml`, `/.octon/instance/cognition/context/shared/knowledge/queries/index.yml` |
| Consume or regenerate derived runtime projections | `/.octon/framework/cognition/runtime/projections/index.yml` | `/.octon/framework/cognition/runtime/projections/definitions/index.yml`, `/.octon/framework/cognition/runtime/projections/materialized/index.yml` |
| Interpret governance contracts and exceptions | `/.octon/framework/cognition/governance/index.yml` | `/.octon/framework/cognition/governance/principles/README.md`, `/.octon/framework/cognition/governance/controls/index.yml`, `/.octon/framework/cognition/governance/exceptions/README.md` |
| Apply methodology and execution standards | `/.octon/framework/cognition/practices/index.yml` | `/.octon/framework/cognition/practices/methodology/index.yml`, `/.octon/framework/cognition/practices/operations/index.yml` |
| Triage cognition policy lint and drift | `/.octon/framework/cognition/practices/operations/governance-lint-triage.md` | `/.octon/framework/cognition/_ops/principles/scripts/lint-principles-governance.sh`, `/.octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh` |

## Escalation Hints

- If your task touches more than one row, start from the highest-risk intent first.
- If ownership is still unclear, open `/.octon/framework/cognition/README.md` and then recurse via linked indexes.
