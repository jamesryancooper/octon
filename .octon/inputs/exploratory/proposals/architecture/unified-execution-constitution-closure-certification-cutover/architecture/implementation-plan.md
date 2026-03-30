# Implementation Plan

## Delivery posture

This plan is a **big-bang, clean-break, atomic cutover**.

There is one packet, one claim boundary, one merge target, one certification
release, and one live post-merge release claim for the supported envelope.

## Atomic delivery rules

1. No dual claim posture remains after merge.
2. No host-native authority path remains inside the certified envelope.
3. No run-bundle omission, unresolved disclosure reference, or shim-authority
   dependency is deferred to a cleanup branch.
4. No support widening is smuggled into the closure release.
5. If the branch cannot satisfy the full proof set, it does not merge.

## Execution model

The branch should be executed in seven ordered phases.

Implementation can happen in parallel inside the branch, but integration must
follow this dependency order:

| Phase | Outcome | Primary surfaces | Depends on |
| --- | --- | --- | --- |
| 0 | Scope lock and claim freeze | packet, support-targets, HarnessCard wording | none |
| 1 | Closure manifest and disclosure alignment | `.octon/instance/governance/closure/**`, HarnessCard, support-targets | 0 |
| 2 | Authority de-hosting | host adapters, canonical decision materializers, PR autonomy policy bindings | 1 |
| 3 | Universal run-bundle gate | run-control roots, validator script, run-contract proof logic | 2 |
| 4 | Executable support-target tests | positive supported tuple, reduced stage-only, unsupported deny fixtures | 3 |
| 5 | Disclosure, shim, and retirement proofs | RunCard/HarnessCard parity, shim audit, build-to-delete receipt | 4 |
| 6 | Blocking release wiring and publication evidence | canonical validator, repo-local workflow binding, publication evidence, archival prep | 5 |

## Phase 0 — Scope lock and claim freeze

### Goal

Stop the round from becoming another architecture ideation cycle.

### Actions

1. Freeze the certified claim to `MT-B / WT-2 / LT-REF / LOC-EN`.
2. Freeze the certified adapters to `repo-shell` and `repo-local-governed`.
3. Record excluded or reduced surfaces explicitly: GitHub, CI, WT-3, LT-EXT,
   LOC-MX, MT-C, WT-4.
4. Reject any requirement that widens support or adds a second authority path.

### Exit gate

Every packet artifact, release claim, and test assumption uses the same bounded
claim statement.

## Phase 1 — Closure manifest and disclosure alignment

### Goal

Create the machine-readable closure claim and align HarnessCard disclosure with
it.

### Actions

1. Add `.octon/instance/governance/closure/unified-execution-constitution.yml`.
2. Move the exact supported tuple, adapter set, exclusions, required proof
   artifacts, and permitted release wording into that file.
3. Update `.octon/instance/governance/disclosure/harness-card.yml` so its claim
   wording is a pure projection of the closure manifest.
4. Update `support-targets.yml` only if wording needs normalization for the
   bounded claim; do not widen coverage.

### Exit gate

The closure manifest becomes the single claim boundary and HarnessCard wording
matches it exactly.

## Phase 2 — Authority de-hosting

### Goal

Eliminate hidden host authority from the certified path.

### Actions

1. Move consequential PR lane/manual-lane/high-impact decisions into canonical
   authority-decision artifact generation under `.octon/**`.
2. Refactor `.github/workflows/pr-autonomy-policy.yml` so it only projects or
   invokes canonical materializers.
3. Keep host adapter manifests explicit that GitHub and CI are non-authoritative
   or stage-only projection surfaces.
4. Ensure any repo-local workflow notices or labels are mirrors of canonical
   artifacts, not final decisions.

### Exit gate

No repo-local workflow remains the final source of authority inside the
certified envelope.

## Phase 3 — Universal run-bundle gate

### Goal

Make “every consequential supported run emits the full constitutional bundle” a
release-blocking invariant.

### Actions

1. Add canonical validator logic under
   `.octon/framework/assurance/governance/_ops/scripts/assert-unified-execution-closure.sh`.
2. Make the validator consume `run-contract.yml#required_evidence` and the
   RunCard schema rather than a prose checklist.
3. Require the run root to emit:
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

### Exit gate

Any consequential supported run missing part of the bundle fails the closure
validator.

## Phase 4 — Executable support-target tests

### Goal

Turn the support matrix into executable certification, not declarative intent.

### Actions

1. Add one positive supported-envelope certification fixture for
   `MT-B / WT-2 / LT-REF / LOC-EN`.
2. Add at least one reduced tuple certification fixture that proves staged
   handling.
3. Add at least one unsupported tuple certification fixture that proves deny.
4. Add a missing-evidence variant to prove fail-closed behavior on supported
   tuples.

### Exit gate

The certification suite demonstrates allow, stage-only, and deny exactly where
support-targets says it should.

## Phase 5 — Disclosure, shim, and retirement proofs

### Goal

Convert disclosure, shim independence, and build-to-delete from narrative
expectations into proof artifacts.

### Actions

1. Add a proof-reference resolver for RunCard and HarnessCard refs.
2. Add a static shim-authority audit that scans launchers, workflows,
   validators, ingress, and bootstrap entrypoints.
3. Fail if any historical shim surface is read as authority.
4. Add or update the retirement registry / publication evidence so at least one
   deletion or demotion receipt is retained.

### Exit gate

Disclosure parity resolves, shim audit is clean, and at least one retirement
receipt exists.

## Phase 6 — Blocking release wiring and publication evidence

### Goal

Make the certification result operational and publishable.

### Actions

1. Bind the canonical closure validator into a repo-local release workflow.
2. Publish retained certification evidence under a stable publication root.
3. Record the release claim wording, pass/fail result, and proof bundle refs.
4. Prepare archival notes so this packet can leave the active lifecycle after a
   successful promotion.

### Exit gate

The next evaluation is operationally a release-blocking certification round, not
an interpretive architecture round.
