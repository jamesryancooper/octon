# Change Map

## Primary file families to change

### Proposal archive normalization

- `.octon/inputs/exploratory/proposals/.archive/architecture/mission-scoped-reversible-autonomy-steady-state-cutover/**`
- `.octon/inputs/exploratory/proposals/.archive/architecture/mission-scoped-reversible-autonomy-final-closeout-cutover/**`
- `.octon/inputs/exploratory/proposals/.archive/architecture/mission-scoped-reversible-autonomy-provenance-alignment-closeout/**`

### Proposal discovery and historical projection

- `.octon/generated/proposals/registry.yml`

### Decision, migration, and evidence discovery

- `.octon/instance/cognition/decisions/index.yml`
- `.octon/instance/cognition/decisions/<new-id>-mission-scoped-reversible-autonomy-provenance-alignment-closeout.md`
- `.octon/instance/cognition/context/shared/migrations/index.yml`
- `.octon/instance/cognition/context/shared/migrations/2026-03-25-mission-scoped-reversible-autonomy-provenance-alignment-closeout/plan.md`
- `.octon/state/evidence/migration/2026-03-25-mission-scoped-reversible-autonomy-provenance-alignment-closeout/**`

### Operator-facing guidance

- `.octon/README.md`
- `.octon/instance/bootstrap/START.md`
- `.octon/framework/cognition/_meta/architecture/specification.md`
- `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md`

## Expected no-change zones

- `.octon/framework/orchestration/runtime/**`
- `.octon/framework/engine/runtime/**`
- `.octon/instance/governance/policies/mission-autonomy.yml`
- `.octon/instance/governance/ownership/registry.yml`
- `.octon/state/control/execution/**`
- `.octon/state/evidence/control/**`
- `.octon/state/evidence/runs/**`
- `.octon/generated/effective/**`
- `.octon/generated/cognition/**`
- `.github/workflows/**`

## Implementation constraints

1. Do not rewrite historical runtime ADRs to repair provenance drift.
2. Do not reactivate archived MSRAOM packets in the active workspace.
3. Do not mix runtime-remediation changes into this provenance-only cutover.
4. Archive the current implementing packet only in the final closeout
   transaction.
