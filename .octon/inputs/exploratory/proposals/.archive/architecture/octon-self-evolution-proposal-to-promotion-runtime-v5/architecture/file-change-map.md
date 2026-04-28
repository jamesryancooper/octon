# File Change Map

Proposed durable target families:

`framework/**`
- `framework/engine/runtime/spec/evolution-program-v1.schema.json`
- `framework/engine/runtime/spec/evolution-candidate-v1.schema.json`
- `framework/engine/runtime/spec/evolution-proposal-compiler-v1.md`
- `framework/engine/runtime/spec/governance-impact-simulation-v1.schema.json`
- `framework/engine/runtime/spec/constitutional-amendment-request-v1.schema.json`
- `framework/engine/runtime/spec/promotion-runtime-v1.md`
- `framework/engine/runtime/spec/recertification-runtime-v1.md`
- `framework/engine/runtime/spec/evolution-ledger-v1.schema.json`
- `framework/orchestration/practices/evolution-lifecycle-standards.md`

`instance/**`
- `instance/governance/evolution/programs/<program-id>/program.yml`
- `instance/governance/evolution/policies/evolution-policy.yml`
- `instance/governance/evolution/policies/promotion-policy.yml`
- `instance/governance/evolution/policies/recertification-policy.yml`
- `instance/governance/evolution/policies/constitutional-amendment-policy.yml`
- ADRs or durable decisions under `instance/cognition/decisions/**` where promotion changes durable architecture.

`state/control/**`
- `state/control/evolution/candidates/<candidate-id>.yml`
- `state/control/evolution/simulations/<simulation-id>.yml`
- `state/control/evolution/lab-gates/<gate-id>.yml`
- `state/control/evolution/amendment-requests/<request-id>.yml`
- `state/control/evolution/promotions/<promotion-id>.yml`
- `state/control/evolution/recertifications/<recertification-id>.yml`
- `state/control/evolution/ledger.yml`

`state/evidence/**`
- `state/evidence/evolution/candidates/<candidate-id>/**`
- `state/evidence/evolution/simulations/<simulation-id>/**`
- `state/evidence/evolution/lab-gates/<gate-id>/**`
- `state/evidence/evolution/proposals/<proposal-id>/**`
- `state/evidence/evolution/promotions/<promotion-id>/**`
- `state/evidence/evolution/recertifications/<recertification-id>/**`
- `state/evidence/evolution/rollbacks/<rollback-id>/**`

`state/continuity/**`
- `state/continuity/evolution/programs/<program-id>/summary.yml`
- `state/continuity/evolution/open-candidates.yml`
- `state/continuity/evolution/open-risks.yml`
- `state/continuity/evolution/next-reviews.yml`

`generated/**`
- derived evolution dashboards and projections only, never authority.

`inputs/**`
- proposal packets and exploratory lineage only; no runtime or policy dependency.
