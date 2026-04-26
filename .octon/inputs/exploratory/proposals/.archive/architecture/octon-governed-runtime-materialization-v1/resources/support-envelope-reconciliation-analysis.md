# Support-Envelope Reconciliation Analysis

## Problem

Octon's support posture is intentionally bounded, but current support truth is
spread across multiple surfaces. Each surface is useful on its own, but no
single hard gate currently proves that all support-facing artifacts agree before
a live claim is published or consumed.

## Surfaces to reconcile

| Surface | Role |
| --- | --- |
| `.octon/instance/governance/support-targets.yml` | Authored support declarations and bounded universe |
| `.octon/state/evidence/validation/support-targets/**` | Admission/proof records |
| `.octon/generated/effective/runtime/route-bundle.yml` | Runtime-effective route posture |
| `.octon/generated/effective/capabilities/pack-routes.effective.yml` | Capability-pack route posture |
| `.octon/generated/effective/governance/support-target-matrix.yml` | Generated support projection |
| locks/freshness artifacts | Staleness and publication safety |
| support cards | Human/operator disclosure of support |
| final disclosures | External/user-facing support claim boundary |

## Required reconciler behavior

For each support tuple and route, the reconciler computes:

- declared posture
- admission posture
- proof posture
- freshness posture
- runtime route posture
- capability-pack posture
- generated support-matrix posture
- support-card posture
- disclosure posture
- final effective support posture

## Failure classes

- `declared_live_without_fresh_proof`
- `route_live_without_declared_support`
- `route_stage_only_but_support_declares_live`
- `pack_route_widens_runtime_route`
- `generated_matrix_widens_authority`
- `generated_matrix_omits_declared_live_claim`
- `support_card_overclaims_reconciled_support`
- `disclosure_overclaims_reconciled_support`
- `excluded_target_presented_live`
- `stale_lock_or_missing_freshness`

## Output contract

The generated reconciliation artifact should be explicit:

```yaml
schema_version: support-envelope-reconciliation-result-v1
status: reconciled|failed
generated_at: <timestamp>
source_digests: {}
tuples:
  - tuple_ref: <id>
    declared: live|stage_only|unsupported|excluded|unknown
    admitted: live|stage_only|unadmitted|unknown
    proof: fresh|stale|missing|insufficient
    route: allow|stage_only|deny|unknown
    pack_route: allow|stage_only|deny|mixed|unknown
    generated_matrix: supported|not_supported|unknown
    disclosure: matches|overclaims|missing|unknown
    effective: live|stage_only|unsupported|blocked
    diagnostics: []
```

## Why this is high leverage

This gate protects Octon's public trust. It prevents a future README, support
card, route bundle, generated matrix, or capability-pack route from silently
presenting a capability as live when another canonical surface says otherwise.
