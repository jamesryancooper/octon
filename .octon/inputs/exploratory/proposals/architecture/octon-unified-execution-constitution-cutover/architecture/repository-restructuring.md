# Repository and Boundary Restructuring

## Keep the super-root
Do **not** replace the current class-root super-root.

## Add the following top-level framework domains
- `framework/constitution/`
- `framework/lab/`
- `framework/observability/`
- `framework/engine/runtime/adapters/hosts/`
- `framework/engine/runtime/adapters/models/`
- `framework/capabilities/packs/browser/`
- `framework/capabilities/packs/api/`

## Add the following instance roots
- `instance/charter/`
- `instance/governance/support-targets.yml`
- `instance/governance/disclosure/HarnessCard.yml`
- `instance/capabilities/runtime/packs/`

## Normalize the following state roots
- `state/control/execution/runs/`
- `state/control/execution/approvals/`
- `state/control/execution/exception-leases/`
- `state/control/execution/revocations/`
- `state/control/execution/budgets/`
- `state/continuity/runs/`
- `state/evidence/disclosure/runs/`
- `state/evidence/disclosure/releases/`
- `state/evidence/benchmarks/`
- `state/evidence/external-index/`

## Re-bound the following
- constitutional prose currently under `framework/cognition/**` into `framework/constitution/**`
- host-shaped approval semantics into host adapters
- provider-shaped model behavior into model adapters
- mission into continuity/orchestration rather than atomic execution
- AI review workflow logic into evaluator adapters and proof plane wiring

## Simplify or delete
- remove mandatory kernel dependency on persona overlays
- deprecate mission-only execution assumption
- retire duplicated constitutional statements after cutover
- demote legacy agent identity surfaces to optional overlays
