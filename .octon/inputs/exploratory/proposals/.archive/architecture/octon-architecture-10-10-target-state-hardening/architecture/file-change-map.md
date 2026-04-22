# File Change Map

## Legend

- **Edit**: modify existing durable surface.
- **Add**: introduce durable surface outside proposal path.
- **Move**: relocate files while preserving content/lineage.
- **Generate**: derived output; not authoritative.
- **Retain evidence**: retained proof under `state/evidence/**`.

## Structural architecture

| Change | Target | Type | Purpose |
| --- | --- | --- | --- |
| Add target-state validator refs and path families | `.octon/framework/cognition/_meta/architecture/contract-registry.yml` | Edit | Make health contract, support partitioning, freshness gates, and generated maps registry-visible. |
| Update human narrative | `.octon/framework/cognition/_meta/architecture/specification.md` | Edit | Describe target-state partitioning, health contract, and compatibility-retirement posture without restating path matrices. |
| Reduce overloaded execution-governance detail | `.octon/octon.yml` | Edit | Keep root bindings and defaults; delegate bulky execution policies to referenced contracts. |

## Operator boot

| Change | Target | Type | Purpose |
| --- | --- | --- | --- |
| Split closeout logic from ingress | `.octon/instance/ingress/manifest.yml` | Edit | Keep boot manifest focused on reads/orientation. |
| Add/adjust closeout workflow refs | `.octon/framework/orchestration/runtime/workflows/meta/closeout/**` | Add/Edit | Hold branch closeout and merge-lane rules. |
| Update boot instructions | `.octon/instance/bootstrap/START.md` | Edit | Add doctor/first-run flow and non-authority reminders. |

## Runtime enforcement

| Change | Target | Type | Purpose |
| --- | --- | --- | --- |
| Expand side-effect inventory | `.octon/framework/engine/runtime/spec/material-side-effect-inventory.yml` | Edit | Include all material paths. |
| Expand coverage map | `.octon/framework/engine/runtime/spec/authorization-boundary-coverage.yml` | Edit | Map every material path to request builder, authorization, grant, receipt, negative controls, tests. |
| Add architecture health contract | `.octon/framework/engine/runtime/spec/architecture-health-contract-v1.md` | Add | Define single health gate semantics. |
| Add publication freshness gates | `.octon/framework/engine/runtime/spec/publication-freshness-gates-v1.md` | Add | Define runtime rejection behavior for stale generated/effective outputs. |
| Wire doctor command | `.octon/framework/engine/runtime/crates/kernel/src/main.rs` and command modules | Edit | Expose `octon doctor --architecture` or equivalent. |

## Support claims

| Change | Target | Type | Purpose |
| --- | --- | --- | --- |
| Partition admissions | `.octon/instance/governance/support-target-admissions/{live,stage-only,unadmitted,retired}/**` | Move | Make claim state visible by path. |
| Partition dossiers | `.octon/instance/governance/support-dossiers/{live,stage-only,unadmitted,retired}/**` | Move | Make proof posture visible by path. |
| Update support matrix refs | `.octon/instance/governance/support-targets.yml` | Edit | Point tuple refs to partitioned paths and claim effects. |
| Add support-pack alignment contract | `.octon/instance/governance/contracts/support-pack-admission-alignment.yml` | Add | Seal support/pack/runtime claim graph. |

## Pack, extension, publication

| Change | Target | Type | Purpose |
| --- | --- | --- | --- |
| Normalize pack registry | `.octon/framework/capabilities/packs/registry.yml` | Edit/Add | Single discovery point for framework pack contracts. |
| Normalize runtime pack admissions | `.octon/instance/capabilities/runtime/packs/admissions/registry.yml` | Edit | Generate/validate admitted runtime pack graph. |
| Normalize active extension dependency locks | `.octon/state/control/extensions/active.yml` | Edit | Group content-addressed dependencies. |
| Update generated/effective publication rules | `.octon/generated/effective/**` plus receipts | Generate/Retain evidence | Runtime-facing outputs require current receipts. |

## Assurance and tests

| Change | Target | Type | Purpose |
| --- | --- | --- | --- |
| Add architecture health validator | `.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-health.sh` | Add | Aggregate target-state gates. |
| Add support/pack/admission validator | `.octon/framework/assurance/runtime/_ops/scripts/validate-support-pack-admission-alignment.sh` | Add | Prevent claim widening. |
| Add publication freshness validator | `.octon/framework/assurance/runtime/_ops/scripts/validate-publication-freshness-gates.sh` | Add | Reject stale generated/effective outputs. |
| Add lifecycle transition validator | `.octon/framework/assurance/runtime/_ops/scripts/validate-run-lifecycle-transition-coverage.sh` | Add | Validate run state machine evidence. |
| Add compatibility retirement validator | `.octon/framework/assurance/runtime/_ops/scripts/validate-compatibility-retirement-readiness.sh` | Add | Ensure shims have owners/triggers. |
| Add operator boot validator | `.octon/framework/assurance/runtime/_ops/scripts/validate-operator-boot-surface.sh` | Add | Keep ingress/boot clean. |
| Add corresponding tests | `.octon/framework/assurance/runtime/_ops/tests/**` | Add | Negative-control and fixture coverage. |
| Wire into CI | `.github/workflows/architecture-conformance.yml` | Adjacent repo-local follow-up, not an `octon-internal` promotion target | Make gates blocking through a linked repo-local proposal or companion change. |
