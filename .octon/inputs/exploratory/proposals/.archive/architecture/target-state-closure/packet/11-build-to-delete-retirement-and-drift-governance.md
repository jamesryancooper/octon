# 11. Build-to-Delete, Retirement, and Drift Governance

## 1. Goal

Turn simplification and deletion from a good instinct into an institutional mechanism.

## 2. Problems to solve

Current repo reality shows:
- major simplification has happened in spirit
- phase-7 build-to-delete governance exists in CI naming
- but retirement and ablation are not yet the single central lifecycle mechanism

## 3. Retirement registry

Create:
- `.octon/instance/governance/retirement/registry.yml`

Each registry entry must include:
- `retirement_id`
- `surface_ref`
- `surface_class`
- `current_status`
- `why_transitional`
- `retirement_trigger`
- `owner`
- `ablation_required`
- `ablation_receipt_ref`
- `target_removal_wave`
- `residual_risk_if_retained`

## 4. Ablation receipts

Create evidence root:
- `.octon/state/evidence/validation/publication/build-to-delete/ablation-receipts/<retirement-id>.yml`

Minimum fields:
- surface removed or disabled
- benchmark/proof-plane deltas
- support tuple coverage impact
- intervention rate change
- rollback outcome
- final recommendation

## 5. Drift governance

Create drift report roots:
- `.octon/state/evidence/validation/publication/drift/documentation-drift.yml`
- `.octon/state/evidence/validation/publication/drift/state-drift.yml`
- `.octon/state/evidence/validation/publication/drift/governance-drift.yml`
- `.octon/state/evidence/validation/publication/drift/adapter-drift.yml`

### Documentation drift
Detect:
- superseded wording in active artifacts
- charter/support mismatch
- shims that still speak as if active

### State drift
Detect:
- control/evidence mismatch
- empty evidence classifications
- stale replay manifests
- inconsistent run bundle refs

### Governance drift
Detect:
- route / approval / support tuple mismatch
- host-native semantics creeping back in
- unsupported-case behavior not failing closed

### Adapter drift
Detect:
- adapter contracts diverging from actual admitted support behavior
- changed provider behavior without conformance refresh

## 6. Build-to-delete rules

Any temporary scaffold may remain only if it has:
- registry entry
- owner
- metric of value
- review date
- retirement trigger
- ablation requirement

No “just keep it around for now” artifacts.

## 7. Simplification triggers

A scaffold becomes a retirement candidate if:
- its function is duplicated elsewhere
- its target failure mode has disappeared
- the model/adapter now handles the issue natively
- it remains on a critical path but adds no benchmark/proof value
- it increases contradiction risk between active claim surfaces

## 8. Validators

Create:
- `validate-retirement-registry.sh`
- `validate-ablation-receipts.sh`
- `validate-drift-reports.sh`
- `validate-no-untracked-transitional-surfaces.sh`

## 9. Governance cadence

Require:
- per-release retirement review
- per-release drift review
- support-target change review
- adapter recertification review when adapters or policies change materially

## 10. Acceptance criteria

- every transitional surface is in the retirement registry
- every deletion in closure-critical areas has an ablation receipt
- drift reports are regenerated for each closure cycle
- no untracked transitional surface remains in active claim paths
