# Target Architecture

`closeout-change` should own the branch-no-PR state sequence from local branch
completion through hosted landing and cleanup.

## Desired State Sequence

- `branch-local-complete`: branch-local work is complete but no remote branch
  publication is proven.
- `published-branch`: source branch is pushed and available for handoff, while
  hosted landing remains separate.
- `landed`: source branch work is integrated into hosted `origin/main` with
  governed landing authorization, hosted landing evidence, landed ref, rollback
  handle, and main alignment proof.
- `cleaned`: landed branch work has final sync proof, cleanup authorization,
  cleanup evidence, and branch deletion or retained-branch disposition.
- `blocked`: route-specific evidence is missing, denied, stale, or conflicts
  with policy.

## Durable Authorities

- `.octon/framework/product/contracts/change-receipt-v1.schema.json` owns the
  Change receipt state model.
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/`
  owns closeout-change execution guidance, route selection, branch-no-PR
  progression, hosted landing, final sync, cleanup, and reporting posture.

## Required Behavior

- Do not ask for routine operator confirmation after branch-no-PR is selected
  and all route-specific proof exists.
- Keep route transition separate from route selection.
- Report `published-branch`, `landed`, `deferred`, or `blocked` instead of
  `cleaned` when cleanup, landing, or sync proof is incomplete.
- Require cleanup authorization before branch deletion or a `cleaned` claim.
- Preserve protected retained evidence and local run artifacts outside branch
  cleanup.

## Dependency Boundary

Implementation depends on the wrapper child for the outer route that delegates
Git mutation and closeout to `closeout-change`. This child must not compensate
by moving wrapper orchestration into closeout-change.
