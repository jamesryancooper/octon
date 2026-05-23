# Follow-Up Verification Prompt

## Verification Target

Verify the implemented proposal packet at:

```text
.octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model
```

Packet identity:

- `proposal_id`: `proposal-packet-phase-loop-model`
- `proposal_kind`: `architecture`
- `status`: `implemented`
- `promotion_scope`: `octon-internal`

Act as an independent verifier. Re-ground against the current repository state
before judging the packet. Proposal-local files are lineage, lifecycle
evidence, and operational aids only. Durable Octon behavior must be proven
through promoted targets, validators, generated publication receipts, runtime
evidence, and current repository state.

Return exactly one final route status:

- `clean`
- `corrections-needed`
- `needs-packet-revision`
- `blocked`
- `superseded`
- `explicitly-deferred`

Do not use ambiguous success language.

## Required Source Reading

Read these packet files before checking durable targets:

- `proposal.yml`
- `architecture-proposal.yml`
- `navigation/source-of-truth-map.md`
- `navigation/artifact-catalog.md`
- `architecture/target-architecture.md`
- `architecture/current-state-gap-map.md`
- `architecture/implementation-plan.md`
- `architecture/acceptance-criteria.md`
- `architecture/file-change-map.md`
- `architecture/cutover-checklist.md`
- `architecture/rollback-plan.md`
- `architecture/operator-disclosure.md`
- `architecture/validation-plan.md`
- `resources/traceability-map.md`
- `resources/risk-register.md`
- `support/implementation-grade-completeness-review.md`
- `support/proposal-review.md`
- `support/executable-implementation-prompt.md`
- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

Then verify every `promotion_targets` entry in `proposal.yml` against the
repository. Directory targets are satisfied only when edited descendants exist
inside the declared family.

## Implementation-Grade Completeness Gate

The packet declares this pre-implementation gate outcome:

- `support/implementation-grade-completeness-review.md`
- `verdict: pass`
- `unresolved_questions_count: 0`
- `clarification_required: no`

Treat the implementation-grade gate as satisfied only if the receipt still
exists, still parses as this outcome, and still aligns with the implemented
promotion targets. If current packet content contradicts that receipt, return
`needs-packet-revision` or `corrections-needed` depending on whether the issue
is proposal semantics or a bounded implementation/documentation mismatch.

## Implemented-Packet Closeout Blockers

Because `proposal.yml` is `status: implemented`, these receipts and validators
are mandatory closeout blockers:

- `support/implementation-conformance-review.md` must exist, declare
  `verdict: pass`, and declare `unresolved_items_count: 0`.
- `support/post-implementation-drift-churn-review.md` must exist, declare
  `verdict: pass`, and declare `unresolved_items_count: 0`.
- `validate-proposal-implementation-conformance.sh` must pass for this packet.
- `validate-proposal-post-implementation-drift.sh` must pass for this packet.

If any of those checks are missing or failing, return `corrections-needed`
unless the failure proves the accepted packet itself is semantically
incomplete. In that case return `needs-packet-revision`.

## Closure-Certification Pass Depth

Closure certification for this packet requires two consecutive clean verifier
passes. Each pass must rerun the required commands in this prompt after any
correction edits, and the second pass must introduce no new findings.

Pass depth for each clean pass:

- Depth 1: packet structure, architecture subtype, artifact catalog, manifest
  state, and proposal registry projection.
- Depth 2: implementation readiness, preserved accepted review evidence,
  implementation conformance, post-implementation drift/churn, promotion-target
  existence, and absence of proposal-local authority dependencies.
- Depth 3: lifecycle contract v2 schema and `phase_loop` behavior, lifecycle
  event schema, runner checkpoint/resume behavior, executor phase context
  boundary, loop bounds, stop classes, and generated-authority denial.
- Depth 4: generated/runtime publication checks, including extension
  publication, host projection publication, runtime route bundle freshness,
  capability publication freshness, and retained publication evidence.

The final verifier report must state whether the result is the first clean pass
or the second consecutive clean pass.

## Stable Finding Identity

Use stable finding ids in the `PPLM-VFY` namespace:

- `PPLM-VFY-001`, `PPLM-VFY-002`, and so on.
- Reuse the same id across reruns for the same root cause.
- Do not renumber findings after one is resolved.
- Group issues only when they share one correction and one acceptance test.

Each finding must include:

- id
- severity: `P0`, `P1`, `P2`, or `P3`
- status: `open`, `resolved`, `blocked`, or `accepted-external`
- affected paths
- evidence
- expected behavior
- correction scope
- acceptance criteria
- deferral eligibility: `eligible` or `not-eligible`

No finding is deferrable if it concerns authority boundaries, implementation
conformance, post-implementation drift, required validator failure,
generated/runtime publication freshness, loop-bound enforcement, checkpoint or
resume integrity, event-log integrity, or executor self-authorization risk.

## Evidence Requirements

For every command or deterministic check, record:

- exact command
- exit code
- relevant output summary
- affected paths
- evidence location if a retained evidence file is written
- whether the evidence is packet-local lifecycle evidence or retained Octon
  evidence

Retained evidence belongs under existing Octon evidence roots such as:

- `.octon/state/evidence/validation/**`
- `.octon/state/evidence/runs/skills/**`
- `.octon/state/evidence/runs/workflows/**`
- `.octon/state/evidence/validation/publication/**`

Do not store retained evidence in `generated/**`. Generated support artifacts,
proposal registry projections, GitHub surfaces, CI state, chat context, browser
state, external dashboards, tool availability, and model memory are not Octon
authority.

## Required Commands

Run these checks from the repository root:

```text
yq -e . .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model/proposal.yml
yq -e . .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model/architecture-proposal.yml
rg -n "T[O]DO|T[B]D|F[I]XME|\\{\\{|\\[[D]escribe" .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --write
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model
bash .octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-contracts.sh --contract .octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-lifecycle-contracts.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-lifecycle-runner.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-lifecycle-executor-adapter.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-proposal-lifecycle-v1-acceptance.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-route-bundle.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh
cargo fmt --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml --all --check
cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_kernel lifecycle --quiet
git diff --check
```

For the `rg` placeholder scan, exit code `1` with no matches is a clean result.
Exit code `0` is clean only if every match is a documented false positive and
does not indicate a scaffold placeholder or unresolved implementation marker.

If correction edits occur after `generate-proposal-registry.sh --write`, rerun
all required packet, focused, publication, runtime, conformance, and drift
checks before declaring `clean`.

## Deterministic Checks

In addition to command output, verify these conditions directly:

- Every path in `promotion_targets` exists or is a declared target family whose
  edited descendants exist.
- Durable promoted targets do not cite this active proposal packet as runtime,
  policy, support, closure, generated, retained evidence, state/control,
  publication, host-projection, extension-pack, skill, or model authority.
- Proposal lifecycle contract source uses
  `schema_version: octon-extension-lifecycle-contract-v2`.
- Proposal lifecycle contract source declares
  `phase_loop.model_version: phase-loop-v1`.
- Generated effective lifecycle contract mirrors the source phase-loop model
  only as a derived discovery handle.
- Lifecycle contract schema accepts v2 and validates phase ids, phase refs,
  route refs, receipt refs, gate refs, validator refs, loop refs, terminal refs,
  finite bounds, backward-transition targets, terminal route denial, and
  manifest-status separation.
- Lifecycle event schema supports `phase_id`, `transition_id`, and phase event
  categories without treating phase ids as proposal manifest statuses.
- Runner checkpoint and event-log behavior records phase state, phase counts,
  blockers, route dispatch counts, transition events, cancellation, loop
  exhaustion, stale evidence, and resume fail-closed blockers.
- Executor request/result phase context remains observability context only and
  cannot select routes, reinterpret lifecycle semantics, mint authority, or
  dispatch without runner-selected gates and delegation proof.
- Lifecycle Autopilot and Change Closeout docs describe generic phase-loop
  substrate semantics without moving Proposal Packet route meaning into the
  substrate.
- Proposal lifecycle skills and docs explain phases as lifecycle/checkpoint
  context, not manifest statuses.
- No new proposal manifest status was introduced.
- Publication receipts exist for generated effective extension, host
  projection, runtime route bundle, and capability publication refreshes when
  those generated outputs changed.
- Proposal registry projection is fresh after the implemented packet state.
- Retained validation evidence is kept under evidence roots, not generated
  output roots.
- Rollback can remove v2/phase-loop contract, schema, runtime, executor,
  validator, test, docs, source extension, generated projection, and host
  projection changes without leaving hidden active authority.

## Correction Scope

Allowed corrections are limited to the smallest change that resolves a stable
finding:

- packet support receipts, artifact catalog, validation notes, and source map;
- promoted source targets named in `proposal.yml`;
- validator, test, schema, runtime, executor, docs, command, or skill files
  directly tied to the accepted packet scope;
- generated proposal registry refresh when validator output requires it;
- generated effective or host projection refresh only from source and only with
  retained publication evidence;
- retained validation evidence under canonical evidence roots.

Forbidden corrections:

- broad unrelated refactors;
- new proposal manifest statuses;
- widening support-target, runtime, publication, host-projection, or authority
  claims;
- treating proposal-local receipts, generated projections, GitHub/CI state,
  chat, browser state, tool availability, external dashboards, or model memory
  as authority;
- allowing self-operating routes to self-authorize;
- merging runner orchestration with proposal-extension route semantics;
- bypassing approval, delegation proof, support-target, scope, freshness,
  receipt, validation, closeout, or archive boundaries.

If a required correction exceeds the accepted proposal scope, return
`needs-packet-revision` instead of implementing it silently.

## Acceptance Criteria

Return `clean` only when all of these are true:

- All required validators and deterministic checks pass.
- Mandatory conformance and drift/churn receipts are present, passing, and have
  zero unresolved items.
- The implementation-grade completeness receipt is present, passing, and has
  zero unresolved questions.
- The artifact catalog includes `support/follow-up-verification-prompt.md`.
- Proposal registry projection is fresh.
- Generated effective, runtime route bundle, and capability publication handles
  are fresh and backed by retained publication receipts.
- No durable promoted target depends on proposal-local paths as authority.
- No generated projection, proposal-local receipt, GitHub/CI state, chat,
  browser state, tool availability, external dashboard, or model memory is used
  as authority.
- No new proposal manifest status exists.
- No open `PPLM-VFY` finding remains.
- Two consecutive clean verifier passes have been retained, with no new finding
  introduced by the second pass.

Return `corrections-needed` when a bounded implementation or receipt correction
can satisfy these criteria. Return `needs-packet-revision` when the accepted
proposal scope must change. Return `blocked` when required tooling or authority
is unavailable. Return `explicitly-deferred` only with explicit rationale,
owner, and follow-up route.
