# Octon Run Lifecycle v1 State-Machine Enforcement

## Purpose

This proposal packet defines the implementation plan for the next single highest-leverage step for Octon after the already-implemented:

1. canonical append-only **Run Journal**;
2. **Authorized Effect Token** enforcement; and
3. deterministic **Context Pack Builder v1**.

The target is narrow and implementation-oriented:

> Enforce **Run Lifecycle v1** end-to-end as the fail-closed, journal-driven state machine behind Octon's Governed Agent Runtime.

## Why this packet exists

Octon already has the architectural primitives that make governed execution possible. The live repository defines a Run Journal, Authorized Effect Tokens, Context Pack Builder v1, evidence-store closeout, support-target requirements, and a Run Lifecycle v1 contract. The gap is not another broad constitutional redesign. The gap is runtime coherence: every runtime operation must be valid for the Run's current lifecycle state, and every lifecycle state must be reconstructable from the canonical journal.

## Current repo posture this packet assumes

- `/.octon/` is the only super-root.
- `framework/**` and `instance/**` are durable authored authority.
- `state/control/**` is mutable operational truth.
- `state/evidence/**` is retained proof and receipts.
- `generated/**` is rebuildable derived output only.
- Proposal packets under `inputs/exploratory/proposals/**` are lineage-only and never authority.
- Consequential execution is Run-centered, not mission-centered.
- Material side effects are already intended to require `AuthorizedEffect<T>` verification.
- Working Context is already intended to be represented by deterministic context-pack evidence.

## Implementation closure status

Status as of 2026-04-24: implemented in durable runtime/spec/assurance/lab
surfaces and retained validation evidence, then archived as non-authoritative
lineage under the proposal archive.

Observed validation evidence:

- `git diff --check` passed.
- `jq empty` passed on `run-lifecycle-transition-v1.schema.json` and
  `run-lifecycle-reconstruction-v1.schema.json`.
- `.octon/framework/assurance/runtime/_ops/scripts/validate-run-lifecycle-v1.sh`
  passed 19 lifecycle cases, including raw-bypass closure controls for fake
  closeout refs, absolute generated/input authority refs, non-stage-only
  staged routing, and unknown `created`/`authorizing` lifecycle states, with
  retained reports under
  `.octon/state/evidence/validation/assurance/run-lifecycle-v1/`. The retained
  report writer is promotion-clean: reruns preserve `generated_at` and avoid
  tracked-file churn when the semantic report is unchanged.
- `.octon/framework/assurance/runtime/_ops/scripts/validate-run-journal-append-boundary.sh`
  passed and is included in the lifecycle validator coverage as
  `journal-append-boundary`.
- `.octon/framework/assurance/runtime/_ops/tests/test-run-lifecycle-v1.sh`
  passed 4 shell regression controls.
- `.octon/framework/assurance/runtime/_ops/scripts/validate-run-journal-contracts.sh`
  passed.
- `.octon/framework/assurance/runtime/_ops/scripts/validate-run-lifecycle-transition-coverage.sh`
  passed.
- `.octon/framework/assurance/governance/_ops/scripts/run-uec-packet-certification-pass.sh --output-dir /tmp/octon-uec-certification-pass`
  passed with `01-verify-run-journals-and-auxiliary-evidence`, which verifies
  existing runtime-owned UEC journals instead of synthesizing canonical journal
  authority. The UEC pass now verifies existing auxiliary evidence read-only
  and writes only to the caller-provided output directory.
- `cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -- --test-threads=1`
  passed after the lifecycle hardening updates.
- `shasum -a 256 -c SHA256SUMS.txt` is the packet-local checksum gate for
  these closure artifacts.
- Required validation reruns are expected to leave `git diff --name-only`
  empty after the staged promotion bundle is refreshed.

This packet remains proposal-local lineage. It does not become runtime,
policy, governance, assurance, evidence, or generated authority by recording
this closure status.

## Executive recommendation

Implement a runtime lifecycle transition gate that makes `run-lifecycle-v1.md` executable. The runtime must reject any attempted bind, authorize, execute, pause, resume, stage, revoke, fail, rollback, succeed, deny, close, replay, or disclose operation unless the requested transition is valid under the lifecycle contract and backed by the required journal, authority, context, effect-token, rollback, evidence, and disclosure facts.

## Recommended reading order

1. `navigation/source-of-truth-map.md`
2. `resources/repository-baseline-audit.md`
3. `resources/implementation-gap-analysis.md`
4. `architecture/current-state-gap-map.md`
5. `architecture/target-architecture.md`
6. `architecture/file-change-map.md`
7. `architecture/implementation-plan.md`
8. `architecture/validation-plan.md`
9. `architecture/acceptance-criteria.md`
10. `architecture/cutover-checklist.md`
11. `architecture/execution-constitution-conformance-card.md`

## Non-authority notice

This packet lives under `inputs/exploratory/proposals/**`. It is not canonical runtime, policy, evidence, governance, or generated authority. Promotion outputs must land in durable `framework/**`, `instance/**`, `state/**`, and generated projection surfaces as appropriate, never by referencing this proposal as runtime truth.
