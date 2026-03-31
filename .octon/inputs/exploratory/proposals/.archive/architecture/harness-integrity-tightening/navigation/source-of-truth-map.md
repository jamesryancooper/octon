# Source Of Truth Map

## Canonical Authority

| Concern | Source of truth | Notes |
| --- | --- | --- |
| Super-root class ownership, write-root class boundaries, retained evidence placement, and fail-closed path rules | `.octon/framework/cognition/_meta/architecture/specification.md` | Remains the umbrella contract for authored authority vs operational truth vs generated outputs. |
| `runtime/` vs `_ops/` classification and allowed mutable targets | `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md` | This proposal tightens the contract so framework `_ops/**` stays portable and never becomes a mutable state sink. |
| Machine-readable path and invariant registry introduced by this proposal | `.octon/framework/cognition/_meta/architecture/contract-registry.yml` | New authoritative registry for critical write roots, egress-policy roots, budget-policy roots, and CI-enforced invariants. |
| Repo-owned outbound network policy | `.octon/instance/governance/policies/network-egress.yml` | New repo-owned authored policy surface for destination-scoped HTTP access. |
| Repo-owned execution-budget policy | `.octon/instance/governance/policies/execution-budgets.yml` | New repo-owned authored policy surface for cost ceilings, model restrictions, and stage/deny behavior. |
| Mutable execution control truth | `.octon/state/control/execution/**` | New mutable operational truth family for budget counters, temporary exception leases, and other execution control state. |
| Retained per-run execution evidence | `.octon/state/evidence/runs/<run_id>/**` | Canonical retained root for execution request, policy decision, receipt, digest, instruction-layer manifest, trace, network-egress log, and cost evidence. |
| Ephemeral execution scratch | `.octon/generated/.tmp/execution/**` | Optional rebuildable scratch only; never retained evidence and never policy authority. |
| Material execution authorization boundary | `.octon/framework/engine/runtime/crates/authority_engine/src/implementation.rs` and `.octon/framework/engine/runtime/spec/policy-interface-v1.md` | The engine-owned authorization boundary remains the only legal path to material side effects. |
| Architecture conformance automation | `.octon/framework/assurance/runtime/architecture-conformance/**` | New durable home for path, egress, cost, and doc-alignment checks promoted from this proposal. |
| CI enforcement | `.github/workflows/architecture-conformance.yml` | New blocking workflow for architecture-invariant drift. |

## Derived Or Enforced Projections

| Concern | Derived path or enforcement surface | Notes |
| --- | --- | --- |
| Per-run execution digest and receipt validation | `.octon/state/evidence/runs/<run_id>/digest.latest.md` and `receipt.latest.json` | Primary retained proof for material authorization decisions. |
| Per-run trace stream | `.octon/state/evidence/runs/<run_id>/trace.ndjson` | Replaces framework-local trace placement. |
| Per-run outbound egress evidence | `.octon/state/evidence/runs/<run_id>/network-egress.ndjson` | Mandatory when a run uses `net.http`. |
| Per-run cost evidence | `.octon/state/evidence/runs/<run_id>/cost.json` | Mandatory when a run uses billable model or provider resources covered by budget policy. |
| Budget state mutation checks | architecture-conformance tests plus runtime policy checks | Any write outside `state/control/execution/**`, `state/evidence/runs/**`, or declared generated scratch roots fails closed. |
| Doc and code consistency checks | architecture-conformance tests plus CI workflow | `specification.md`, `runtime-vs-ops-contract.md`, `START.md`, engine README, runtime config, and tests must agree on `_ops/` semantics and write roots. |

## Boundary Rules

- `framework/**/_ops/**` may host portable helper scripts, validators, launch assets, and other framework-bundled operational support only.
- Mutable repo-specific operational state, retained evidence, traces, and spend counters MUST NOT live under `framework/**/_ops/**`.
- The canonical retained execution-evidence root is `state/evidence/runs/<run_id>/**`.
- The canonical mutable execution-control root is `state/control/execution/**`.
- The canonical ephemeral execution scratch root is `generated/.tmp/execution/**`.
- `execution/flow` MUST NOT grant `net.http` by default.
- Any outbound HTTP access MUST be justified by repo-owned egress policy and retained per-run evidence.
- Any budgeted execution MUST be evaluated against repo-owned budget policy and emit retained per-run cost evidence.
- Any change to a canonical path or invariant in this map MUST update the machine-readable contract registry, matching docs, and blocking tests in the same change.
