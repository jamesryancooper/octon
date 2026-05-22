# Follow-Up Verification Prompt

## Verification Target

Verify the implemented proposal packet at:

```text
.octon/inputs/exploratory/proposals/architecture/incoming-additive-intake-unit-contract
```

Packet identity:

- `proposal_id`: `incoming-additive-intake-unit-contract`
- `proposal_kind`: `architecture`
- `status`: `accepted`
- `promotion_scope`: `octon-internal`

Act as an independent verifier. Re-ground against the current repository state
before judging the packet. Proposal-local files are lifecycle evidence and
operational aids only; durable Octon behavior must be proven through promoted
targets, validators, workflow contracts, and retained validation evidence.

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
- `validation-plan.md`
- `support/implementation-grade-completeness-review.md`
- `support/proposal-review.md`
- `support/executable-implementation-prompt.md`
- `support/implementation-run.md`
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
promotion targets. If the current packet content contradicts that receipt,
return `needs-packet-revision` or `corrections-needed` depending on whether the
issue is proposal semantics or a bounded implementation/documentation mismatch.

## Implemented-Packet Verification Blockers

The implementation route intentionally leaves `proposal.yml#status` as
`accepted`, but this packet has implementation receipts and durable target
changes. Therefore these checks are mandatory blockers for a clean result:

- `support/implementation-conformance-review.md` must exist, declare
  `verdict: pass`, and declare `unresolved_items_count: 0`.
- `support/post-implementation-drift-churn-review.md` must exist, declare
  `verdict: pass`, and declare `unresolved_items_count: 0`.
- `validate-proposal-implementation-conformance.sh` must pass for this packet.
- `validate-proposal-post-implementation-drift.sh` must pass for this packet.

If any of those checks are missing or failing, return `corrections-needed`
unless the failure proves the accepted packet itself is semantically incomplete;
in that case return `needs-packet-revision`.

## Closure-Certification Pass Depth

This packet does not declare a two-consecutive-clean-pass threshold. A single
clean pass is sufficient when all required validators pass and no stable
finding remains open.

Clean pass depth:

- Depth 1: packet structure, architecture subtype, artifact catalog, manifest
  state, and proposal registry projection.
- Depth 2: implementation readiness, implementation conformance,
  post-implementation drift/churn, promotion-target existence, and absence of
  proposal-local authority dependencies.
- Depth 3: incoming intake validator behavior, input non-authority scans,
  extension-pack ignore regression, workflow validation, and JSON schema
  parsing.
- Depth 4: raw intake boundary checks proving `.incoming/**` and `.archive/**`
  are not runtime, policy, generated, retained evidence, state/control,
  publication, host-projection, extension-pack, or skill authority.

The final verifier report must state whether the result is a clean pass,
corrections-needed, blocked, needs-packet-revision, superseded, or explicitly
deferred.

## Stable Finding Identity

Use stable finding ids in the `IAIUC-VFY` namespace:

- `IAIUC-VFY-001`, `IAIUC-VFY-002`, and so on.
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
conformance, post-implementation drift, raw input non-authority, validator
failure, generated/runtime publication freshness, or required evidence.

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
yq -e . .octon/inputs/exploratory/proposals/architecture/incoming-additive-intake-unit-contract/proposal.yml
yq -e . .octon/inputs/exploratory/proposals/architecture/incoming-additive-intake-unit-contract/architecture-proposal.yml
rg -n "T[O]DO|T[B]D|F[I]XME|\\{\\{|\\[[D]escribe" .octon/inputs/exploratory/proposals/architecture/incoming-additive-intake-unit-contract
jq . .octon/framework/cognition/_meta/architecture/inputs/additive/schemas/incoming-intake-unit.schema.json >/dev/null
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --write
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/incoming-additive-intake-unit-contract
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/incoming-additive-intake-unit-contract
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/incoming-additive-intake-unit-contract --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/incoming-additive-intake-unit-contract
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/incoming-additive-intake-unit-contract
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/incoming-additive-intake-unit-contract
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-incoming-intake-unit.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-input-non-authority.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-raw-input-dependency-ban.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-extension-pack-contract.sh
bash .octon/framework/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh
git diff --check
```

If correction edits occur after `generate-proposal-registry.sh --write`, rerun
all required packet, focused, and drift checks before declaring `clean`.

## Deterministic Checks

In addition to command output, verify these conditions directly:

- Every path in `promotion_targets` exists or is a declared target family whose
  edited descendants exist.
- Durable promoted targets do not cite this active proposal packet as runtime,
  policy, generated, retained evidence, state/control, publication,
  host-projection, extension-pack, or skill authority.
- `.incoming/**` and `.archive/**` remain raw non-authoritative inputs.
- Existing real intake units are not rewritten, moved, processed, normalized,
  activated, published, archived, deleted, cleaned, or installed.
- The incoming validator uses temporary fixtures for positive and negative
  tests, not real intake units.
- The JSON schema and shell validator agree on required envelope fields,
  naming rules, payload root, provenance posture, and risk classification
  findings.
- Workflow and command docs keep intake validation separate from route
  classification, disposition, normalization, activation, publication, and
  archive retention.
- Generated proposal registry projection is fresh after packet support changes.
- Retained validation evidence is kept under evidence roots, not generated
  output roots.
- Rollback can remove the envelope/schema/validator/workflow/command/test/docs
  changes without authorizing any intake-unit movement or processing.

## Correction Scope

Allowed corrections are limited to the smallest change that resolves a stable
finding:

- packet support receipts, artifact catalog, validation notes, and source map;
- promoted docs, schema, workflow, command, validators, and tests named in
  `proposal.yml`;
- generated proposal registry refresh when validator output requires it;
- retained validation evidence under canonical evidence roots.

Forbidden corrections:

- installing, normalizing, activating, publishing, archiving, migrating,
  deleting, cleaning, or otherwise processing any real intake unit;
- broad unrelated refactors;
- route-specific incoming requirements that belong to normalized extension
  packs or core skill installation;
- widening support-target, runtime, publication, host-projection, or authority
  claims;
- treating proposal-local files, `.incoming/**`, `.archive/**`, generated
  registries, prompts, GitHub, chat, browser state, tool output, or model
  memory as authority.

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
- No durable promoted target depends on proposal-local paths as authority.
- No real `.incoming/**` or `.archive/**` unit was processed or rewritten.
- No open `IAIUC-VFY` finding remains.
- The final report states `clean` or an allowed terminal state.

Return `corrections-needed` when a bounded implementation or receipt correction
can satisfy these criteria. Return `needs-packet-revision` when the accepted
proposal scope must change. Return `blocked` when required tooling or authority
is unavailable. Return `explicitly-deferred` only with explicit rationale,
owner, and follow-up route.
