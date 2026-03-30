# Source of Truth Map

## Canonical authorities after promotion

### Constitutional kernel
- `/.octon/framework/constitution/CHARTER.md`
- `/.octon/framework/constitution/charter.yml`
- `/.octon/framework/constitution/precedence/normative.yml`
- `/.octon/framework/constitution/precedence/epistemic.yml`
- `/.octon/framework/constitution/obligations/*.yml`
- `/.octon/framework/constitution/contracts/**`

### Repo-local authored authority
- `/.octon/instance/charter/workspace.{md,yml}`
- `/.octon/instance/governance/policies/**`
- `/.octon/instance/governance/contracts/**`
- `/.octon/instance/governance/ownership/**`
- `/.octon/instance/governance/support-targets.yml`
- `/.octon/instance/orchestration/missions/**`
- `/.octon/instance/capabilities/runtime/packs/**`
- `/.octon/instance/assurance/runtime/**`

### Runtime control truth
- `/.octon/state/control/execution/runs/**`
- `/.octon/state/control/execution/approvals/**`
- `/.octon/state/control/execution/exception-leases/**`
- `/.octon/state/control/execution/revocations/**`
- `/.octon/state/control/execution/budgets/**`

### Continuity truth
- `/.octon/state/continuity/repo/**`
- `/.octon/state/continuity/scopes/**`
- `/.octon/state/continuity/missions/**`
- `/.octon/state/continuity/runs/**`

### Retained evidence
- `/.octon/state/evidence/runs/**`
- `/.octon/state/evidence/validation/**`
- `/.octon/state/evidence/lab/**`
- `/.octon/state/evidence/disclosure/**`
- `/.octon/state/evidence/benchmarks/**`
- `/.octon/state/evidence/external-index/**`

### Derived-only projections
- `/.octon/generated/effective/**`
- `/.octon/generated/reports/**`
- `/.octon/generated/projections/**`

## Transitional shims to retire
- `/.octon/instance/bootstrap/OBJECTIVE.md`
- `/.octon/instance/cognition/context/shared/intent.contract.yml`
- constitutional prose still rooted under `/.octon/framework/cognition/**`
- host-native approval semantics under GitHub workflow labels/checks/comments
- persona-heavy kernel ingress dependencies

## Proposal status
This proposal is non-canonical. After promotion, canonical truth must live in the durable
roots above, not in this packet.
