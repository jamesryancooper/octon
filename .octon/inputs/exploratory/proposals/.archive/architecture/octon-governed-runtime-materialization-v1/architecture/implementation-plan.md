# Implementation Plan

## Phase 0 — Baseline and truth inventory

1. Inventory support-target declarations, route bundle, pack routes, generated
   support matrix, locks, support cards, and disclosures.
2. Inventory proof/admission artifacts and their freshness/completeness fields.
3. Inventory all material side-effect API surfaces and map each to an effect
   class.
4. Inventory current authorization token structs, grant bundle issuance, verifier
   hooks, consumption receipts, run journal entries, and negative tests.
5. Inventory run lifecycle artifacts and evidence roots needed to generate
   health.

Deliverable: baseline inventory evidence under
`.octon/state/evidence/validation/runtime/governed-runtime-materialization-v1/baseline/`.

## Phase 1 — Support-envelope reconciliation gate

1. Add `support-envelope-reconciliation-v1.md`.
2. Add `support-envelope-reconciliation-result-v1.schema.json`.
3. Implement `generate-support-envelope-reconciliation.sh`.
4. Implement `validate-support-envelope-reconciliation.sh`.
5. Add fixtures:
   - coherent-live
   - support-target-live-route-stage-only
   - pack-route-allow-route-stage-only
   - generated-matrix-widens-support
   - generated-matrix-omits-live-claim
   - stale-proof-bundle
   - missing-proof-bundle
   - support-card-overclaims
   - excluded-target-presented-live
6. Integrate validator into `validate-architecture-conformance.sh`.
7. Emit generated reconciliation result and retained validation evidence.

Exit criteria: no live support claim can pass unless declared, admitted,
proof-backed, fresh, route-resolved, capability-pack-consistent, and disclosed
without widening.

## Phase 2 — Typed effect-token enforcement closure

1. Expand `authorized_effects` crate with closure-grade token metadata.
2. Introduce `VerifiedEffect<T>` and explicit verifier/consumption APIs.
3. Bind token issuance to `authorize_execution` and its grant/decision records.
4. Update material side-effect APIs to require `VerifiedEffect<T>`.
5. Record token consumption receipts under retained evidence and run journal.
6. Add deterministic denial reasons:
   - missing_token
   - forged_token
   - wrong_effect_class
   - wrong_run
   - wrong_route
   - wrong_support_tuple
   - wrong_capability_pack
   - expired_token
   - revoked_token
   - missing_approval
   - missing_exception
   - rollback_not_ready
   - budget_exceeded
   - egress_denied
   - already_consumed
7. Update boundary coverage and token enforcement validators.
8. Add positive and negative fixtures/tests for every material path family.

Exit criteria: material side effects cannot execute without a verified typed
effect and retained consumption evidence.

## Phase 3 — Operator-facing run health read model

1. Add `run-health-read-model-v1.schema.json`.
2. Update `operator-read-models-v1.md` to register run health as generated-only.
3. Implement `generate-run-health-read-model.sh`.
4. Implement `validate-run-health-read-model.sh`.
5. Generate health under:
   `.octon/generated/cognition/projections/materialized/runs/<run_id>/health.yml`
6. Add fixtures for healthy, review-required, awaiting-approval, blocked, stale,
   unsupported, revoked, evidence-incomplete, rollback-required, and closure-ready.
7. Validate that generated health cannot authorize action or widen support.

Exit criteria: a solo operator can inspect one generated health artifact and see
state, risk, support posture, authorization posture, evidence posture,
recoverability, and next action, with links to canonical inputs.

## Phase 4 — Integrated validation and promotion

1. Run support reconciliation gate.
2. Run token enforcement and boundary coverage validators.
3. Run run-health validation.
4. Run evidence completeness validation.
5. Run no-generated-authority and no-input-authority validators.
6. Produce migration evidence bundle and closure certification.

Exit criteria: all positive fixtures pass, all negative fixtures fail for the
expected deterministic reason, and closure evidence is retained.

## Phase 5 — Cutover and rollback

1. Promote approved specs, validators, runtime code, fixtures, and schemas.
2. Regenerate generated/effective and generated/read-model artifacts.
3. Retain validation evidence.
4. Re-run existing architecture conformance and runtime-effective-state gates.
5. If any gate fails, rollback promoted runtime/spec changes and delete
   regenerated artifacts; preserve validation evidence as failed-attempt evidence.
