---
title: Unified Execution Constitution Closure Certification Cutover Prompt
description: Execution-grade prompt for implementing the closure-certification packet as one big-bang, clean-break, atomic migration without stopping at phase boundaries.
---

You are executing the
`unified-execution-constitution-closure-certification-cutover` packet as one
big-bang, clean-break, atomic closure-certification cutover.

Your job is to implement the packet end to end on a single branch and continue
without stopping until final closeout is complete, unless you hit a true hard
blocker.

Do not stop at phase boundaries. Implement through final closeout.

This is a closeout packet over an already-evolved system. Converge, tighten,
and replace live surfaces in place. Do not treat this as a greenfield redesign
and do not create a second live authority, disclosure, validation, or support
path while implementing it.

## Required reading order

Read these before making changes:

1. `/.octon/instance/ingress/AGENTS.md`
2. `/.octon/inputs/exploratory/proposals/architecture/unified-execution-constitution-closure-certification-cutover/README.md`
3. `/.octon/inputs/exploratory/proposals/architecture/unified-execution-constitution-closure-certification-cutover/architecture/target-architecture.md`
4. `/.octon/inputs/exploratory/proposals/architecture/unified-execution-constitution-closure-certification-cutover/resources/implementation-audit.md`
5. `/.octon/inputs/exploratory/proposals/architecture/unified-execution-constitution-closure-certification-cutover/resources/closure-certification-baseline.md`
6. `/.octon/inputs/exploratory/proposals/architecture/unified-execution-constitution-closure-certification-cutover/resources/current-state-gap-analysis.md`
7. `/.octon/inputs/exploratory/proposals/architecture/unified-execution-constitution-closure-certification-cutover/resources/final-remediation-ledger.md`
8. `/.octon/inputs/exploratory/proposals/architecture/unified-execution-constitution-closure-certification-cutover/resources/closure-manifest-spec.md`
9. `/.octon/inputs/exploratory/proposals/architecture/unified-execution-constitution-closure-certification-cutover/resources/de-hosting-authority-closeout.md`
10. `/.octon/inputs/exploratory/proposals/architecture/unified-execution-constitution-closure-certification-cutover/resources/support-target-runtime-disclosure-shim-proof.md`
11. `/.octon/inputs/exploratory/proposals/architecture/unified-execution-constitution-closure-certification-cutover/architecture/implementation-plan.md`
12. `/.octon/inputs/exploratory/proposals/architecture/unified-execution-constitution-closure-certification-cutover/architecture/acceptance-criteria.md`
13. `/.octon/inputs/exploratory/proposals/architecture/unified-execution-constitution-closure-certification-cutover/architecture/validation-plan.md`
14. `/.octon/inputs/exploratory/proposals/architecture/unified-execution-constitution-closure-certification-cutover/navigation/source-of-truth-map.md`
15. `/.octon/inputs/exploratory/proposals/architecture/unified-execution-constitution-closure-certification-cutover/navigation/change-map.md`
16. `/.octon/inputs/exploratory/proposals/architecture/unified-execution-constitution-closure-certification-cutover/architecture/cutover-checklist.md`
17. `/.octon/instance/governance/support-targets.yml`
18. `/.octon/instance/governance/disclosure/harness-card.yml`
19. `/.octon/framework/constitution/contracts/registry.yml`
20. `/.github/workflows/pr-autonomy-policy.yml`

## Profile Selection Receipt

Record and follow this profile:

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- `atomic_mode`: `clean-break`
- `transitional_exception_note`: not applicable
- `selection_rationale`: this packet is explicitly scoped as one final
  closure-certification cutover with one bounded claim, one merge target, and
  no surviving compatibility posture after merge

## Promotion targets

Promote and tighten these authoritative `.octon/**` surfaces:

- `/.octon/instance/governance/closure/`
- `/.octon/instance/governance/disclosure/harness-card.yml`
- `/.octon/instance/governance/support-targets.yml`
- `/.octon/framework/assurance/governance/`
- `/.octon/framework/constitution/contracts/registry.yml`
- `/.octon/framework/engine/runtime/adapters/host/`
- `/.octon/state/control/execution/runs/`
- `/.octon/state/evidence/disclosure/`
- `/.octon/state/evidence/validation/publication/build-to-delete/`

Treat these repo-local workflow files as downstream binding surfaces only:

- `/.github/workflows/pr-autonomy-policy.yml`
- `/.github/workflows/unified-execution-constitution-closure.yml`

## Delivery contract

You must satisfy all of the following:

1. Work on one branch only.
2. Keep exactly one bounded certified claim in scope at all times.
3. Keep exactly one live constitutional authority path after merge.
4. Do not stop at phase boundaries. Implement through final closeout.
5. Carry forward cleanup immediately; do not open a deferred cleanup branch for
   any release-blocking proof, disclosure, shim, or retirement gap.
6. Tighten existing live surfaces where possible instead of creating parallel
   replacements that survive after merge.
7. Treat proposal-local files as non-canonical implementation inputs only.
   Promote durable results into `.octon/**`; do not leave the proposal packet
   on the runtime-critical path.
8. Stop only for a true hard blocker:
   - missing authority to edit required paths
   - required destructive approval you do not have
   - invariant conflict that cannot be resolved locally without weakening the
     certified claim

## Non-negotiable negative constraints

Do not do any of the following:

- do not select a `transitional` profile
- do not widen support beyond `MT-B / WT-2 / LT-REF / LOC-EN`
- do not widen certified adapters beyond `repo-shell` and
  `repo-local-governed`
- do not make GitHub or CI authoritative control planes
- do not let workflow-local labels, checks, comments, or state mint final
  authority
- do not leave a second disclosure source, second validator, second claim
  manifest, or second support matrix live after merge
- do not leave any consequential supported run without the full required run
  bundle
- do not let RunCard or HarnessCard references resolve only narratively; they
  must resolve to retained evidence
- do not treat historical shims as runtime, ingress, bootstrap, workflow, or
  validator authority
- do not let repo-root `AGENTS.md` or `CLAUDE.md` gain runtime or policy text;
  they must remain thin parity adapters only
- do not claim completion while any acceptance criterion or certification gate
  remains open
- do not stop at phase boundaries. Implement through final closeout.

## Required outputs

Produce migration planning, certification evidence, and retained publication
artifacts for this cutover:

- Migration plan path:
  `/.octon/instance/cognition/context/shared/migrations/2026-03-30-unified-execution-constitution-closure-certification-cutover/plan.md`
- Evidence bundle root:
  `/.octon/state/evidence/migration/2026-03-30-unified-execution-constitution-closure-certification-cutover/`
- Required migration bundle files:
  - `bundle.yml`
  - `evidence.md`
  - `commands.md`
  - `validation.md`
  - `inventory.md`
- Closure manifest path:
  `/.octon/instance/governance/closure/unified-execution-constitution.yml`
- Certification publication root:
  `/.octon/state/evidence/validation/publication/unified-execution-constitution-closure/`
- Required retained publication artifacts:
  - `supported-envelope-positive.md`
  - `reduced-stage-only.md`
  - `unsupported-deny.md`
  - `missing-evidence-fail-closed.md`
  - `disclosure-parity.md`
  - `shim-independence.md`
  - `build-to-delete-receipt.md`
  - `summary.md`

Update code, contracts, validators, docs, workflows, migration evidence, and
publication evidence in the same branch where the requirement becomes true.

## Execution phases

Execute these phases in order. Do not pause between them unless blocked.

### Phase 0 — Scope lock and claim freeze

Primary surfaces:

- proposal packet claim wording and proof contract
- `/.octon/instance/governance/support-targets.yml`
- `/.octon/instance/governance/disclosure/harness-card.yml`
- migration plan and evidence bundle roots

Required work:

- Freeze the certified claim to `MT-B / WT-2 / LT-REF / LOC-EN`.
- Freeze the certified adapters to `repo-shell` and `repo-local-governed`.
- Record reduced, stage-only, experimental, and denied surfaces explicitly:
  GitHub, CI, `WT-3`, `LT-EXT`, `LOC-MX`, `MT-C`, `WT-4`.
- Reject any requirement that widens support, adds a second authority path, or
  leaves an unresolved release-blocking proof gap for later.
- Inventory the live repo surfaces that already partially satisfy this packet
  and converge them instead of recreating them in parallel.

Exit gate:

- Every packet artifact, live claim, release wording candidate, and test
  assumption uses the same bounded claim statement.

### Phase 1 — Closure manifest and disclosure alignment

Primary surfaces:

- `/.octon/instance/governance/closure/unified-execution-constitution.yml`
- `/.octon/instance/governance/disclosure/harness-card.yml`
- `/.octon/instance/governance/support-targets.yml`

Required work:

- Add the machine-readable closure manifest at the canonical governance path.
- Encode the supported tuple, adapters, exclusions, required proof artifacts,
  allowed historical shims, and permitted release wording in that manifest.
- Make `harness-card.yml` a pure projection of the closure manifest and tested
  support envelope.
- Normalize support-target wording only where needed to match the bounded claim;
  do not widen coverage.

Exit gate:

- The closure manifest is the single claim boundary and HarnessCard wording
  matches it exactly.

### Phase 2 — Authority de-hosting

Primary surfaces:

- `/.octon/framework/assurance/governance/**`
- `/.octon/state/evidence/control/execution/**`
- `/.octon/framework/engine/runtime/adapters/host/**`
- `/.github/workflows/pr-autonomy-policy.yml`

Required work:

- Materialize consequential lane, blocker, and manual-lane decisions as
  canonical `.octon/**` logic plus retained decision artifacts.
- Refactor `pr-autonomy-policy.yml` so it invokes or projects canonical
  materializers instead of making hidden final authority decisions.
- Keep GitHub and CI limited to request capture, projection, binding, and merge
  gating over canonical artifacts.
- Ensure host adapter declarations and runtime behavior agree that GitHub and CI
  are non-authoritative or reduced/stage-only surfaces.

Exit gate:

- No repo-local workflow remains the final source of authority inside the
  certified envelope.

### Phase 3 — Universal run-bundle gate

Primary surfaces:

- `/.octon/framework/assurance/governance/_ops/scripts/assert-unified-execution-closure.sh`
- `/.octon/state/control/execution/runs/**`
- `/.octon/state/evidence/runs/**`
- RunCard schema and run-contract evidence declarations

Required work:

- Add the canonical closure validator under `.octon/**`.
- Make the validator consume `run-contract.yml#required_evidence` and the
  RunCard contract/schema rather than a prose checklist.
- Require the supported consequential run root to emit:
  - `run-contract.yml`
  - `run-manifest.yml`
  - `runtime-state.yml`
  - `rollback-posture.yml`
  - stage-attempt root
  - checkpoint root
  - decision artifact
  - approval grant bundle
  - evidence classification
  - replay pointers
  - external replay index
  - intervention log
  - measurement summary
  - RunCard

Exit gate:

- Any consequential supported run missing part of the bundle fails the closure
  validator.

### Phase 4 — Executable support-target tests

Primary surfaces:

- `/.octon/instance/governance/support-targets.yml`
- `/.octon/framework/assurance/governance/**`
- `/.octon/state/evidence/validation/publication/unified-execution-constitution-closure/**`

Required work:

- Add one positive certification fixture for the supported envelope
  `MT-B / WT-2 / LT-REF / LOC-EN`.
- Add at least one reduced tuple fixture that proves `stage_only`.
- Add at least one unsupported tuple fixture that proves `deny`.
- Add a missing-evidence supported-tuple fixture that proves fail-closed
  behavior.

Exit gate:

- The certification suite demonstrates allow, `stage_only`, and `deny` exactly
  where `support-targets.yml` says it should.

### Phase 5 — Disclosure, shim, and retirement proofs

Primary surfaces:

- `/.octon/state/evidence/disclosure/**`
- `/.octon/framework/constitution/contracts/registry.yml`
- `/.octon/instance/ingress/**`
- `/.octon/instance/bootstrap/**`
- `/.github/workflows/**`
- `/.octon/state/evidence/validation/publication/build-to-delete/**`

Required work:

- Add proof-reference resolution for RunCard and HarnessCard evidence refs.
- Fail release when any disclosure ref is broken or claim wording drifts from
  the closure manifest.
- Add a static shim-authority audit covering launchers, workflows, validators,
  ingress entrypoints, and bootstrap entrypoints.
- Fail if any historical shim surface is read as authority rather than as a
  projection, compatibility, subordinate, or retirement-conditioned surface.
- Publish at least one deletion or demotion receipt with owner, trigger, and
  replacement state under the canonical build-to-delete publication root.

Exit gate:

- Disclosure parity resolves, shim audit is clean, and at least one retirement
  receipt exists.

### Phase 6 — Blocking release wiring and publication evidence

Primary surfaces:

- `/.github/workflows/unified-execution-constitution-closure.yml`
- `/.github/workflows/pr-autonomy-policy.yml`
- `/.octon/framework/assurance/governance/**`
- `/.octon/state/evidence/validation/publication/unified-execution-constitution-closure/**`
- archival notes for the proposal packet

Required work:

- Bind the canonical closure validator into a repo-local release workflow as a
  downstream binding surface only.
- Publish retained certification evidence under the stable publication root.
- Record the release claim wording, pass/fail result, and proof bundle refs.
- Prepare archival notes so the proposal packet can leave the active lifecycle
  after successful promotion.

Exit gate:

- The next evaluation is operationally a release-blocking certification round,
  not an interpretive architecture round.

## Final closeout gate

Do not stop until all of the following are true:

- every criterion in
  `/.octon/inputs/exploratory/proposals/architecture/unified-execution-constitution-closure-certification-cutover/architecture/acceptance-criteria.md`
  is green
- the migration plan and evidence bundle exist at the required canonical paths
- the closure manifest governs release wording and HarnessCard wording exactly
- the publication bundle exists under
  `/.octon/state/evidence/validation/publication/unified-execution-constitution-closure/`
- the repo-local workflow layer is only a downstream binding surface over
  canonical `.octon/**` validators and materializers
- no certification-critical path depends on proposal-local files or historical
  shims as authority
- at least one live build-to-delete receipt exists and is retained
- the proposal packet is ready for archival after promotion

## Hard blocker response contract

If you hit a true hard blocker, stop only then and report:

1. the exact blocker
2. the acceptance gate or phase exit gate it blocks
3. the file paths or authority surfaces involved
4. what you attempted locally
5. the narrowest human decision or approval required

## Completion response contract

When you finish, report:

1. what changed
2. what migration and certification evidence was produced
3. which acceptance criteria and validation gates were satisfied
4. any residual non-blocking risks
5. whether the branch is ready for closeout
