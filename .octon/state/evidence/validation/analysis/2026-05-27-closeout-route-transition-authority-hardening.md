---
schema_version: "octon-validation-analysis-note-v1"
note_id: "2026-05-27-closeout-route-transition-authority-hardening"
created_at: "2026-05-27T00:00:00Z"
status: "retained"
change_profile: "atomic"
release_state: "pre-1.0"
authority_refs:
  - ".octon/framework/product/contracts/default-work-unit.yml"
  - ".octon/framework/product/contracts/change-receipt-v1.schema.json"
  - ".octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh"
---

# Closeout Route Transition Authority Hardening

## Profile Selection Receipt

- release_state: `pre-1.0`
- selected change_profile: `atomic`
- rationale: this is a clean policy and validator hardening of the active
  Change closeout route model. It keeps the existing route set and receipt
  schema version while adding backward-compatible optional structured fields.
- transitional exception: none

## Historical Issue

PR #467 exposed an ambiguity in Closeout Change handling: a blocked hosted
landing attempt was followed by PR creation even though the default route was
`branch-no-pr`. The historical receipt is left unchanged. This note records
the follow-up guardrail: blocked direct-main push, GH013, required checks, or
blocked hosted no-PR landing evidence is blocker evidence, not an implicit
`branch-pr` predicate.

## Guardrails Added

- `change-receipt-v1` now allows structured route-transition fields:
  `initial_route`, `route_transition_reason`,
  `route_transition_authority`, `route_transition_authority_ref`, and
  `route_transition_evidence_refs`.
- `change-receipt-v1` now records `branch_pr_predicate` for `branch-pr`
  receipts.
- Closeout lifecycle validation rejects changed routes without explicit
  operator reroute or policy reroute after new evidence.
- Closeout lifecycle validation rejects `branch-pr` receipts that lack
  `branch_pr_predicate`.
- Policy, workflow, quickstart, and Closeout Change skill text now distinguish
  initial route selection from route transition.

## Non-Goals

- No route was added.
- No historical PR #467 receipt was rewritten.
- No GitHub branch protection or ruleset setting was changed.
- No PR creation behavior was authorized outside selected or
  authority-transitioned `branch-pr`.

## Validation

Recorded commands:

- `bash .octon/framework/assurance/runtime/_ops/tests/test-change-closeout-lifecycle-alignment.sh`:
  pass, 54 passed / 0 failed
- `bash .octon/framework/assurance/runtime/_ops/tests/test-solo-route-selection.sh`:
  pass, 4 passed / 0 failed
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh`:
  pass, validation summary `errors=0`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-git-github-workflow-alignment.sh`:
  pass, validation summary `errors=0`
- `git diff --check`: pass

No generated host projection or GitHub branch-protection mutation was run or
required for this hardening.
