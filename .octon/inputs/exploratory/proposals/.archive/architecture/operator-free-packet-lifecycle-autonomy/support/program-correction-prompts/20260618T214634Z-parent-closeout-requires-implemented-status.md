correction_id: operator-free-packet-lifecycle-autonomy-parent-closeout-requires-implemented-status-20260618T214634Z
target_program: .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy
finding_id: parent-closeout-requires-implemented-status
blocking_gate: closeout-program-enter-when
verdict: blocked

# Correction Prompt: Parent Closeout Requires Implemented Status

## Blocker

The parent program closeout route was explicitly authorized, but the canonical
`closeout-program` lifecycle contract cannot enter for the current parent
manifest state.

Observed state:

- parent `proposal.yml#status`: `accepted`
- seven required child packets: `implemented`
- parent closeout prompt:
  `support/custom-program-closeout-prompt.md`
- aggregate parent receipts:
  - `support/program-implementation-orchestration-conformance-review.md`
  - `support/program-post-implementation-orchestration-drift-churn-review.md`

The canonical proposal-program lifecycle contract declares:

```yaml
route_id: "closeout-program"
completion:
  expected_manifest_status: "implemented"
enter_when:
  all:
    - manifest_status: "implemented"
```

The operator authorized parent closeout execution only. That authorization did
not authorize parent promotion, archive, cleanup, landing, publication,
deletion, branch cleanup, or any `cleaned` claim. Because entering the closeout
route would require the parent manifest to already be `implemented`, closeout
must stop before writing `support/proposal-closeout.md`.

## Current Validation Evidence

The route preflight and parent gates passed before this blocker was recorded:

```sh
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-retained-run-evidence-index.sh --index <each child retained index>
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-readiness-projection.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy --skip-registry-check
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --check
```

Results:

- retained-run evidence indexes: 7/7 pass; `errors=0`
- program structure: pass; `errors=0 warnings=0`
- program child readiness: pass; `errors=0 warnings=0`
- program readiness projection: pass; `errors=0 warnings=2`
- parent proposal standard: pass; `errors=0 warnings=1`
- generated proposal registry check: pass; `errors=0`

No generated outputs were refreshed. No parent lifecycle state was mutated.
No child-owned evidence was recreated or rewritten.

## Required Correction Route

Use the smallest governed parent lifecycle decision route before retrying
closeout:

1. If the parent program should close out as implemented, obtain a separate
   explicit operator instruction authorizing the governed parent promotion route
   from `accepted` to `implemented`.
2. Run the canonical parent promotion route and retain its evidence if all
   required gates pass.
3. After the parent status is `implemented`, rerun the parent closeout route
   from fresh preflight using
   `support/custom-program-closeout-prompt.md`.

Alternative route:

- If governance intends program closeout to be valid from `accepted`, revise
  the proposal-program lifecycle contract through a separate governed proposal
  and validator update. Do not bypass the current route precondition locally.

## Prohibitions

- Do not promote the parent from this closeout route.
- Do not write a passing `support/proposal-closeout.md` while parent status is
  `accepted`.
- Do not archive, clean, land, publish, delete, or claim `cleaned`.
- Do not use parent evidence to satisfy child-owned evidence.
- Do not rewrite child receipts, child validation verdicts, child promotion
  targets, child archive metadata, or child terminal outcomes.
- Do not hand-edit generated outputs.

## Resume Condition

Resume parent closeout only after either:

- the parent has been separately and validly promoted to `implemented`; or
- a separately governed lifecycle contract correction changes the legal
  closeout precondition.
