# /proposal-program-delivery

Run the canonical proposal program delivery workflow for an accepted proposal
program.

This command is a thin routing surface for
`.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/workflow.yml`.
It coordinates target-owned child lifecycles and emits an aggregate delivery
receipt. It does not replace child receipts, archive packets, delete residue,
publish generated outputs by hand, stage, commit, push, create pull requests, or
clean up branches.

The route enforces `execution_order_policy` before continuation:
`child-before-parent-delivery` is canonical, and any non-canonical requested
order requires a retained, target-bound
`proposal-program-delivery-order-override-receipt-v1`. The route also requires
a retained delivery-readiness preflight before expensive child continuation,
parent delivery, Git mutation, publication checks, landing, sync, cleanup, or
branch deletion.

## Usage

```text
/proposal-program-delivery target=<proposal-program-path> [outcome=cleaned] [profile=<profile-path>] [run-id=<id>]
```

## Required Inputs

- `target`: repo-relative path to the accepted proposal program.
- `outcome`: optional delivery target outcome. Defaults to `cleaned`.
- `profile`: optional `proposal-program-delivery-profile-v1` profile.
- `run-id`: optional delivery run identifier for retained evidence paths.

## Outputs

- A delivery evidence bundle under `.octon/state/evidence/runs/workflows/`.
- A delivery summary under `.octon/state/evidence/validation/analysis/`.
- A `proposal-program-delivery-receipt-v1` aggregate receipt.

The receipt may report `cleaned` only when target-owned implementation receipts,
publication freshness, packet closeout, archive handoff, Change closeout,
landing proof, branch cleanup authorization, final sync proof, terminal proof,
worktree hygiene, clean-worktree route selection, include-path classification
when source posture is dirty or stale, and any required lifecycle postmortem
threshold evidence all pass. Otherwise it reports `blocked` with the blocker
class and next owning lifecycle.
