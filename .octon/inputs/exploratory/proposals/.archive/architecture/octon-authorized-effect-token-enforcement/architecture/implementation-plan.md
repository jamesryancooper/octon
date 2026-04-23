# Implementation Plan

## Posture

This is a proposal-first, closure-ready implementation plan for one target: Authorized Effect Token enforcement across every material path family. It assumes the canonical append-only Run Journal is either already promoted or is the immediate sequencing dependency. The plan does not open browser/API/frontier support admission and does not create a new Control Plane.

## Phase 0 — Acceptance, sequencing, and path inventory freeze

1. Accept packet scope as the narrow post-Run-Journal hardening step.
2. Confirm canonical Run Journal status. If not promoted, pause this packet after inventory work and mark token lifecycle event promotion blocked by the Run Journal dependency.
3. Freeze the material path family inventory:
   - repo mutation
   - generated-effective publication
   - state/control mutation
   - evidence mutation
   - executor launch
   - service invocation
   - protected CI check
   - extension activation
   - capability-pack activation
   - outbound HTTP/network egress if not fully represented by service invocation
   - model-backed invocation if not fully represented by service invocation
   - promotion/disclosure activation if not fully represented by generated-effective publication or evidence mutation
4. Identify each owning module/script/workflow entrypoint.
5. Identify existing material APIs that accept raw paths, requests, grant bundles, policy receipts, or caller assertions.

**Exit criterion:** complete path inventory with no `unknown-owner`, `unknown-effect-kind`, or `unknown-test-ref` entries.

## Phase 1 — Contract hardening

1. Add `authorized-effect-token-v2.schema.json`.
2. Add `authorized-effect-token-consumption-v1.schema.json`.
3. Update `authorized-effect-token-v1.md` to reference v2 schema and consumption receipts.
4. Update `authorization-boundary-coverage-v1.md` so coverage requires token enforcement and negative bypass proof.
5. Update `material-side-effect-inventory-v1.schema.json` to require:
   - `effect_kind`
   - `token_required`
   - `consumer_api_ref`
   - `negative_bypass_test_ref`
   - `consumption_receipt_required`
   - `journal_event_required`
6. Add `material-side-effect-inventory.yml` populated for the current repo.

**Exit criterion:** schemas and inventory validate; every material family maps to exactly one primary token class or an explicit additive v2 class.

## Phase 2 — Runtime type and verifier hardening

1. Extend `octon_authorized_effects` with full metadata and token digest fields.
2. Reduce arbitrary construction risk:
   - prefer private fields;
   - remove or deprecate general-purpose public `new`;
   - introduce authority-owned minting path;
   - require verifier lookup against canonical token records.
3. Add `VerifiedEffect<T>` as the internal non-serializable guard returned by verification.
4. Add verifier checks:
   - token record exists under run control root;
   - token digest matches record;
   - token run/request/grant refs match active Run;
   - effect kind matches `T`;
   - support tuple and capability packs are in grant scope;
   - scope includes target;
   - token not expired/revoked/consumed;
   - Run lifecycle allows consumption;
   - consumption can be journaled and retained.

**Exit criterion:** Rust tests prove forged, stale, wrong-kind, expired, revoked, consumed, wrong-run, and wrong-scope tokens fail verification.

## Phase 3 — Authority-engine minting and control/evidence materialization

1. Update GrantBundle effect issuance so token records include grant and decision provenance.
2. Write minted token records under `state/control/execution/runs/<run-id>/effect-tokens/`.
3. Write token evidence receipts under `state/evidence/runs/<run-id>/receipts/effect-tokens/`.
4. Append Run Journal events/items for token mint/deny/consume/reject/revoke/expire.
5. Update execution receipts to include token refs and consumption refs whenever side effects are material.

**Exit criterion:** representative `ALLOW`, `STAGE_ONLY`, `DENY`, and `ESCALATE` fixtures retain correct token or no-token outcomes.

## Phase 4 — Material API signature hardening

1. Update material side-effect APIs to require `AuthorizedEffect<T>` at their public boundary.
2. Immediately verify into `VerifiedEffect<T>` before mutation.
3. Remove or guard APIs that can write repo, state, evidence, generated-effective outputs, executor launches, protected CI checks, extension activation, or pack activation without a verified token.
4. Add type-level or test-level proof that raw path + ambient grant variants are not used for material effects.

**Exit criterion:** negative bypass tests fail closed across all material path families.

## Phase 5 — Governance and support proof alignment

1. Update repo-shell execution class policy to name required token classes for material class routes.
2. Update support-target evidence requirements to include token coverage proof for live repo-shell and CI-control-plane tuples.
3. Confirm no live support universe expansion.
4. Confirm generated support/read models remain derived-only.

**Exit criterion:** support-target proof bundle requirements include token proof without widening admitted tuples.

## Phase 6 — Assurance, validation, and closure

1. Add validators and tests listed in `file-change-map.md`.
2. Produce retained validation evidence for schema, inventory, Rust, and negative bypass suites.
3. Run two consecutive clean validation passes.
4. Produce closure certification.
5. Archive this packet after promoted targets stand alone.

**Exit criterion:** acceptance criteria pass with retained evidence and no proposal-path dependency.

## Minimal fallback

No fallback that skips token verification or negative bypass proof is acceptable. If implementation risk is high, reduce scope to the live repo-shell and CI-control-plane material families first, but keep the same token model and coverage tests.
