# Source of Truth Map

## Proposal-local lifecycle authority

1. `proposal.yml`
2. `architecture-proposal.yml`

These manifests govern this proposal packet only. They do not create runtime, policy, support, or execution authority.

## Durable authority targets after promotion

### Portable authored core

- `.octon/framework/engine/runtime/spec/connector-operation-v1.schema.json`
- `.octon/framework/engine/runtime/spec/connector-admission-v1.schema.json`
- `.octon/framework/engine/runtime/spec/connector-trust-dossier-v1.schema.json`
- `.octon/framework/engine/runtime/spec/connector-execution-receipt-v1.schema.json`
- `.octon/framework/orchestration/practices/connector-admission-standards.md`

### Repo-specific authored authority

- `.octon/instance/governance/connectors/**`
- `.octon/instance/governance/connector-admissions/**`
- `.octon/instance/governance/support-targets.yml`
- `.octon/instance/governance/capability-packs/**`
- `.octon/instance/governance/policies/network-egress.yml`
- `.octon/instance/governance/policies/execution-budgets.yml`

### Mutable control truth

- `.octon/state/control/connectors/**`
- `.octon/state/control/execution/**`

### Retained evidence

- `.octon/state/evidence/connectors/**`
- `.octon/state/evidence/control/execution/**`
- `.octon/state/evidence/runs/**`
- `.octon/state/evidence/validation/support-targets/**`

### Continuity

- `.octon/state/continuity/connectors/**` if connector posture must be resumable across stewardship/mission cycles.

### Generated projections

- `.octon/generated/cognition/projections/materialized/connectors/**`
- `.octon/generated/cognition/projections/materialized/connectors/support-cards/**`
- `.octon/generated/effective/governance/support-target-matrix.yml`

Generated projections are derived only. They may narrow operator understanding but never widen claims, admit support, or authorize execution.

## Non-authoritative surfaces

- This proposal packet under `inputs/exploratory/proposals/**`
- Any packet support files
- Chat history
- Generated summaries
- Dashboards, labels, comments, checks, and external UI affordances
