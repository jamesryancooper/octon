# Support Envelope Reconciliation v1

## Purpose

The support-envelope reconciler is the hard gate that proves Octon's live
support claim remains inside the bounded admitted finite support universe.

It reconciles support-target declarations, support admissions, proof bundles,
runtime-effective routes, capability-pack routes, generated support matrices,
support cards, and active disclosure before a live support claim may be used by
publication workflows, validators, or runtime-facing generated handles.

## Authority Boundaries

- Authored support authority comes from
  `/.octon/instance/governance/support-targets.yml`,
  `/.octon/instance/governance/support-target-admissions/**`,
  `/.octon/instance/governance/support-dossiers/**`, and governance
  exclusions.
- Proof truth comes from retained validation evidence under
  `/.octon/state/evidence/validation/support-targets/**` plus the retained
  run, proof-plane, negative-control, and disclosure refs cited there.
- Runtime route posture comes from verified generated/effective handles:
  `/.octon/generated/effective/runtime/route-bundle.yml` and
  `/.octon/generated/effective/capabilities/pack-routes.effective.yml`, with
  their locks and publication receipts.
- Generated support matrices, support cards, and disclosures may summarize,
  narrow, and disclose. They never mint support authority or widen a live
  support claim.
- Raw proposal/input artifacts are forbidden as support authority.

## Live Claim Requirements

A tuple may reconcile to `effective: live` only when all conditions hold:

1. the tuple is declared in `support-targets.yml` with
   `claim_effect: admitted-live-claim`;
2. its admission file exists, is in the live claim-state partition, and has
   `status: supported`, `route: allow`;
3. its proof bundle exists, has `result: pass`, executable evaluator metadata,
   `freshness.status: current`, and a review due date that has not passed;
4. proof sufficiency is qualified and retained evidence refs resolve enough to
   avoid summary-only proof;
5. no active revocation targets representative live proof evidence;
6. the runtime route bundle resolves the tuple as `route: allow` with a live
   claim effect;
7. every admitted live capability pack is admitted and has an allow pack route
   for the same tuple;
8. generated support-matrix, route-bundle, and pack-route outputs do not widen
   the authored claim;
9. support cards and active HarnessCard disclosure do not overclaim the
   reconciled tuple posture; and
10. the tuple is not excluded, stage-only, unadmitted, unsupported, retired, or
    outside the declared live support universe.

If any required leg is missing, stale, route-inconsistent, proof-insufficient,
or disclosure-inconsistent, the tuple must reconcile to `effective: blocked`
or a non-live posture.

## Non-Live Requirements

Stage-only, unadmitted, unsupported, retired, or governance-excluded surfaces
must remain explicit. They may reconcile to `effective: stage_only` or
`effective: unsupported`, but they must not be presented as live by generated
outputs, support cards, final disclosure, route bundles, or pack routes.

## Required Diagnostics

Validators must emit deterministic diagnostics for these classes:

- `declared_live_without_fresh_proof`
- `missing_proof_bundle`
- `stale_proof_bundle`
- `route_live_without_declared_support`
- `route_stage_only_but_support_declares_live`
- `pack_route_widens_runtime_route`
- `generated_matrix_widens_authority`
- `generated_matrix_omits_declared_live_claim`
- `support_card_overclaims_reconciled_support`
- `disclosure_overclaims_reconciled_support`
- `excluded_target_presented_live`
- `stale_lock_or_missing_freshness`
- `revoked_support_evidence`

Validators may emit narrower implementation diagnostics in addition to these
stable classes.

## Generated Result

The canonical generated result is:

```text
/.octon/generated/effective/governance/support-envelope-reconciliation.yml
```

It is derived-only and non-authoritative. Consumers must treat it as a
freshness-checked summary and gate result, not as a support authority source.

The result schema is:

```text
/.octon/framework/engine/runtime/spec/support-envelope-reconciliation-result-v1.schema.json
```

The generated result must include source refs, source digests, generated time,
freshness posture, allowed and forbidden consumers, explicit non-authority
classification, tuple-level reconciliation records, and deterministic
diagnostics.

## Validator

The canonical gate is:

```text
/.octon/framework/assurance/runtime/_ops/scripts/validate-support-envelope-reconciliation.sh
```

The validator fails closed when:

- a live tuple cannot satisfy every live claim requirement;
- a generated route, pack route, support matrix, support card, or disclosure
  widens beyond authored support authority;
- required locks, receipts, freshness modes, or source digests are missing or
  stale;
- a negative fixture fails for a reason other than its declared deterministic
  diagnostic; or
- the checked generated result drifts from the current canonical inputs.
