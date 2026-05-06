# Follow-Up Verification Prompt

## Verification Target

Verify the implemented proposal packet at:

```text
.octon/inputs/exploratory/proposals/architecture/mission-plan-compiler-layer
```

Packet identity:

- `proposal_id`: `mission-plan-compiler-layer`
- `proposal_kind`: `architecture`
- `status`: `implemented`
- `promotion_scope`: `octon-internal`

Act as an independent verifier. Re-ground against the current repository state
before judging the packet. Proposal-local files are lineage and lifecycle
evidence only; durable Octon behavior must be proven through the promoted
targets, validators, registries, and retained evidence.

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
- `architecture/implementation-plan.md`
- `architecture/acceptance-criteria.md`
- `architecture/validation-plan.md`
- `architecture/rollback-plan.md`
- `support/profile-selection-receipt.md`
- `support/implementation-grade-completeness-review.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

Then verify all `promotion_targets` in `proposal.yml` against the repository.

## Implementation-Grade Completeness Gate

The packet declares this pre-implementation gate outcome:

- `support/implementation-grade-completeness-review.md`
- `verdict: pass`
- `unresolved_questions_count: 0`
- `clarification_required: no`

Treat the implementation-grade gate as satisfied only if the receipt still
exists, still parses as this outcome, and still aligns with the implemented
promotion targets. If the packet content now contradicts that receipt, return
`needs-packet-revision` or `corrections-needed` depending on whether the issue
is proposal semantics or a repairable implementation/documentation mismatch.

## Implemented-Packet Closeout Blockers

Because `proposal.yml` is `status: implemented`, these receipts are mandatory
closeout blockers:

- `support/implementation-conformance-review.md` must exist, declare
  `verdict: pass`, and declare `unresolved_items_count: 0`.
- `support/post-implementation-drift-churn-review.md` must exist, declare
  `verdict: pass`, and declare `unresolved_items_count: 0`.
- `validate-proposal-implementation-conformance.sh` must pass for this packet.
- `validate-proposal-post-implementation-drift.sh` must pass for this packet.

If any of those checks are missing or failing, return `corrections-needed`
unless the failure proves the packet itself is semantically incomplete; in that
case return `needs-packet-revision`.

## Closure-Certification Pass Depth

Closure certification for this packet requires two consecutive clean verifier
passes. Each pass must rerun the required commands in this prompt after any
correction edits, and the second pass must introduce no new findings.

Pass depth for each clean pass:

- Depth 1: packet structure, architecture subtype, artifact catalog, checksum,
  and manifest state.
- Depth 2: implementation readiness, implementation conformance, post-
  implementation drift/churn, promotion-target existence, and no durable
  proposal-local authority references.
- Depth 3: Mission Plan Compiler runtime checks, negative controls, contract
  registry checks, runtime documentation boundary checks, and rollback posture.
- Depth 4: generated/runtime publication checks, including proposal registry
  freshness, absence of unexpected generated planning projections, and retained
  evidence placement outside generated output roots.

The final verifier report must state whether the result is the first clean pass
or the second consecutive clean pass.

## Stable Finding Identity

Use stable finding ids in the `MPC-VFY` namespace:

- `MPC-VFY-001`, `MPC-VFY-002`, and so on.
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
conformance, post-implementation drift, generated/runtime publication freshness,
or required validator failure.

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

Do not store retained evidence in `generated/**`. Generated support artifacts,
proposal registry projections, chat context, GitHub surfaces, browser state,
external tools, and model memory are not Octon authority.

## Required Commands

Run these checks from the repository root:

```text
yq -e . .octon/inputs/exploratory/proposals/architecture/mission-plan-compiler-layer/proposal.yml
yq -e . .octon/inputs/exploratory/proposals/architecture/mission-plan-compiler-layer/architecture-proposal.yml
rg -n "T[O]DO|T[B]D|F[I]XME|\\{\\{|\\[[D]escribe" .octon/inputs/exploratory/proposals/architecture/mission-plan-compiler-layer
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --write
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/mission-plan-compiler-layer
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/mission-plan-compiler-layer
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/mission-plan-compiler-layer
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/mission-plan-compiler-layer
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/mission-plan-compiler-layer
bash .octon/framework/assurance/runtime/_ops/scripts/validate-mission-plan-compiler.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-mission-plan-compiler.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-contract-registry.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-docs-consistency.sh
shasum -a 256 -c .octon/inputs/exploratory/proposals/architecture/mission-plan-compiler-layer/support/SHA256SUMS.txt
git diff --check
```

Run this broad check as a classified repository-health sweep:

```text
bash .octon/framework/assurance/runtime/_ops/scripts/validate-contract-governance.sh
```

The broad check is a closeout blocker only if a failure is caused or worsened
by this packet's promoted targets. Existing `_ops` fixture boundary failures
and the known script line 551 shell evaluation failure remain residual
repository health debt unless new evidence ties them to this packet.

If correction edits occur after `generate-proposal-registry.sh --write`, rerun
all required commands and refresh packet checksums before the final pass.

## Deterministic Checks

In addition to command output, verify these conditions directly:

- Every path in `promotion_targets` exists.
- Durable promoted targets do not cite this active proposal packet as runtime
  authority.
- Mission Plan Compiler specs and schemas preserve non-authority,
  compile-only, mission-bound semantics.
- PlanNode cannot directly execute, bypass run-contract creation, bypass
  context-pack construction, bypass authorization, widen support targets, admit
  capabilities, or mutate mission scope without approval.
- The derive-mission-plan workflow binds mission authority before planning and
  compiles only to action-slice candidates or run-contract drafts.
- The hierarchical planning policy remains optional and stage-only.
- Generated planning projections are not required for this implementation
  slice; if any are present, they must be derived-only and non-authoritative.
- Proposal registry generation is fresh after the implemented packet state.
- Retained validation evidence is kept under evidence roots, not generated
  output roots.
- Rollback can remove the planning layer without invalidating mission charters,
  action slices, run contracts, authorization, evidence, replay, rollback, or
  continuity surfaces.

## Correction Scope

Allowed corrections are limited to the smallest change that resolves a stable
finding:

- packet support receipts, artifact catalog, validation notes, and checksums
- Mission Plan Compiler promoted targets named in `proposal.yml`
- registry entries, boundary documentation, validator, and test files directly
  tied to this packet
- generated proposal registry refresh when validator output requires it

Forbidden corrections:

- broad unrelated refactors
- widening support-target claims
- enabling production planning beyond the declared stage-only policy
- creating materialized planning read models unless the finding proves they are
  required by accepted scope and validates them as derived-only
- treating proposal-local files, generated registries, prompts, GitHub, chat,
  browser state, tool output, or model memory as authority
- bypassing mission authority, run lifecycle, context-pack, authorization,
  evidence, replay, rollback, support-target, or capability-admission
  boundaries

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
- Packet checksums verify.
- Proposal registry projection is fresh.
- No durable promoted target depends on proposal-local paths as authority.
- No unexpected generated planning projection or production enablement exists.
- No open `MPC-VFY` finding remains.
- The final report states first-pass or second-pass closure-certification
  status.

Return `corrections-needed` when a bounded implementation or receipt correction
can satisfy these criteria. Return `needs-packet-revision` when the accepted
proposal itself lacks enough authority or specificity to justify the correction.
Return `blocked` when an external repository condition prevents deterministic
verification. Return `superseded` only if a newer accepted packet clearly
replaces this one. Return `explicitly-deferred` only with an explicit deferral
authority and retained evidence.

## Output Contract

Produce a report with these sections:

- `Verification Summary`
- `Closure-Certification Pass`
- `Findings`
- `Commands And Evidence`
- `Generated And Runtime Publication Checks`
- `Closeout Blockers`
- `Correction Scope`
- `Final Route Status`
- `Next Route`

For `Findings`, include a table with stable finding ids even when the table is
empty. For `Next Route`, use:

- `octon-proposal-packet-lifecycle-closeout` when the final route status is
  `clean` and this is the second consecutive clean pass.
- `octon-proposal-packet-lifecycle-generate-correction-prompt` when the final
  route status is `corrections-needed`.
- `octon-proposal-packet-lifecycle-create` or proposal revision routing when
  the final route status is `needs-packet-revision`.
