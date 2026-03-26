# Interaction, Scheduling, And Evidence

## Final interaction model

The final interaction grammar remains:

- **Inspect**
- **Signal**
- **Authorize-Update**

This packet makes it operationally complete.

## Signal types that must be supported

- `pause_at_boundary`
- `suspend_future_runs`
- `resume_future_runs`
- `reprioritize`
- `narrow_scope`
- `exclude_target`
- `block_finalize`
- `unblock_finalize`
- `enter_safing`

## Authorize-Update types that must be supported

- `approve`
- `extend_lease`
- `revoke_lease`
- `raise_budget`
- `grant_exception`
- `reset_breaker`
- `enter_break_glass`
- `exit_break_glass`

## Scheduling semantics

The scheduler must consume canonical schedule control truth and the generated effective route together.

It must distinguish:

- `suspend_future_runs`
- `pause_active_run`
- `overlap_policy`
- `backfill_policy`
- `pause_on_failure`

## Finalize handling

Finalize must consume:

- recovery-window state
- route finalize policy
- `block_finalize` directives
- authorize-updates
- breaker/safing overlays

Late feedback must still be able to block finalize or invoke recovery while the recovery window is open.

## Control evidence coverage

The closeout packet requires receipts for:

- mission seed
- directive add
- directive apply
- authorize-update add
- authorize-update apply
- schedule mutation
- lease mutation
- autonomy-budget transition
- breaker transition
- safing enter
- safing exit
- break-glass enter
- break-glass exit
- finalize block
- finalize unblock

## Control receipt rule

Every control mutation must:
1. update canonical control truth
2. emit a control receipt
3. allow summaries and digests to render from the canonical truth and receipt set

No mutation may exist only in a summary or digest.
