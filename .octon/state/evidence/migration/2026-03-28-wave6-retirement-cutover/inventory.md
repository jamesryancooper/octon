# Change Inventory

## Summary

- Promoted the live constitutional execution model from transitional markers to
  a final active state across contracts, obligations, precedence, and bootstrap
  surfaces.
- Retired mission-only execution metadata from active objective and mission
  contracts, schemas, and exemplars.
- Removed host-shaped approval and waiver shims from runtime and GitHub
  automation, leaving only canonical control artifacts as authority.

## Major Change Groups

### Constitutional closeout

- `framework/constitution/**`
- `instance/bootstrap/{OBJECTIVE.md,START.md}`
- `instance/cognition/context/shared/intent.contract.yml`
- `instance/governance/support-targets.yml`

### Runtime and mission retirement

- `framework/engine/runtime/**`
- `framework/cognition/governance/principles/mission-scoped-reversible-autonomy.md`
- `instance/orchestration/missions/**`
- `state/control/execution/{approvals,runs}/**`

### GitHub automation hardening

- `.github/workflows/{pr-autonomy-policy.yml,pr-auto-merge.yml,pr-triage.yml,pr-stale-close.yml,pr-clean-state-enforcer.yml,ai-review-gate.yml}`
- `framework/agency/_ops/scripts/**`
- `framework/agency/practices/**`

### Generated and publication refresh

- `generated/cognition/**`
- `generated/proposals/registry.yml`
- `generated/effective/{capabilities,extensions,orchestration}/**`
- `state/control/extensions/{active.yml,quarantine.yml}`
- `state/evidence/validation/publication/{capabilities,extensions}/**`

### Durable closeout records

- `instance/cognition/context/shared/migrations/index.yml`
- `instance/cognition/context/shared/migrations/2026-03-28-wave6-retirement-cutover/plan.md`
- `instance/cognition/decisions/{index.yml,074-wave6-retirement-cutover.md}`
- `state/evidence/migration/2026-03-28-wave6-retirement-cutover/**`
- `inputs/exploratory/proposals/.archive/architecture/fully-unified-execution-constitution-for-governed-autonomous-work/**`
- implementing Wave 6 proposal package archived as `implemented`
