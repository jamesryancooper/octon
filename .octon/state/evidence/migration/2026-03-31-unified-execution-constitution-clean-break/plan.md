# Unified Execution Constitution Clean-Break Plan

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- `atomic_mode`: `clean-break`
- `transitional_exception_note`: not applicable
- `selection_rationale`: the branch must converge to one post-merge model and
  fail closed until the final status matrix is fully green

## Work in scope

- make `authority_engine` the owning implementation crate
- bind workflow runtime discovery to `framework/orchestration/runtime/workflows/**`
- make specialized `validate-proposal` honor explicit run ids
- emit canonical RunCards and disclosure placeholders from `finalize_execution`
- add an authoritative status matrix and wire the closeout validator to it
- add a brownfield retrofit playbook and current closeout evidence bundle

## Current outcome

The branch is not at full unified execution constitution. It is in a stricter,
more honest fail-closed state with fresher live-path evidence and narrower
blockers.
