# Unified Execution Constitution Packet Implementation Plan

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- `atomic_mode`: `clean-break`
- `transitional_exception_note`: not applicable
- `selection_rationale`: ingress defaults pre-1.0 work to `atomic`, and the
  packet requires one branch-local clean-break target state with no mixed live
  constitutional mode after cutover

## Goal

Implement the April 4 clean-break Unified Execution Constitution packet on the
dedicated cutover branch, keeping the packet non-authoritative and moving only
authoritative framework, instance, runtime, state, assurance, and disclosure
surfaces toward packet conformance.

## Immediate Work

1. Normalize the live workspace machine charter onto a dedicated
   `workspace-charter-v1` schema and remove compatibility shims from live
   runtime routing.
2. Re-open the closure claim to a truthful provisional state until packet issue
   closure, certification reruns, and a valid closure certificate exist.
3. Record packet issue status explicitly so complete-claim validators cannot
   pass while packet-open issues remain.

## Impact Map

- `contracts`: objective, disclosure, retention, and runtime contract surfaces
- `runtime`: live policy interface inputs and run-contract objective refs
- `validators`: objective-binding and closure validation rules
- `disclosure`: authored HarnessCard, closure manifest, and release disclosure
- `evidence`: packet issue register and cutover planning receipt

## Compliance Receipt

- packet remains under `.octon/inputs/**` and is not introduced as a runtime
  dependency
- compatibility objective shims may remain retained for lineage or bootstrap
  compatibility, but they are removed from the live runtime path
- closure claims remain bounded to what the current authoritative evidence and
  validators can defend

## Exceptions / Escalations

- human governance sign-off, clean-room Pass 1 / Pass 2 certification, and
  closure-certificate signatories remain external prerequisites for actual
  closure certification
- unrelated user worktree changes in `.octon/inputs/exploratory/proposals/`
  were preserved in place and not reverted
