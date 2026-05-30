# Implementation Plan

_Status: Accepted child packet plan. Not implemented in this task._

## Profile Selection Receipt

- release_state: `pre-1.0`
- change_profile: `atomic`
- rationale: bounded proposal-packet slice with no hard gate requiring a
  transitional compatibility phase.

## Dependency Order

Dependencies: `proposal-program-runner-current-state-gap-map`.

## Workstreams

1. Reconfirm the current-state gap map and existing ownership before editing.
2. Update only declared write scopes needed for this child slice.
3. Preserve existing route, validator, workflow, publication, registry,
   cleanup, closeout, archive, disclosure-tier, and run-control ownership.
4. Add focused tests and negative fixtures for the acceptance criteria below.
5. Regenerate generated or registry state only through canonical scripts when
   authored sources require it.
6. Record implementation, conformance, post-implementation drift/churn, and
   validation evidence before promotion, closeout, or archive is considered.

## Write Scopes

- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/engine/runtime/spec/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/`

## Validation Plan

- Add tests for handoff-only default behavior and route-ready non-completion.
- Add tests proving route inventory comes from lifecycle contracts and generated projections.
- Add tests for receipt reread and replan after parent route dispatch or child batch dispatch.

## Rollback

Use `git-revert` rollback. Do not rely on proposal-local files as runtime
truth. If generated outputs drift, regenerate them through canonical publisher
scripts or revert the authored-source change.
