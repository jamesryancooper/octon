# /proposal-packet-delivery

Run the canonical proposal packet delivery workflow for an accepted proposal
packet.

This command is a thin routing surface for
`.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-delivery/workflow.yml`.
It coordinates implementation, promotion, packet closeout, terminal closeout,
archive handoff, Change closeout, final sync, branch cleanup, terminal proof,
and final hygiene. It does not replace target-owned receipts, archive packets
directly, delete residue, publish generated outputs by hand, stage, commit,
push, create pull requests, or clean up branches.

## Usage

```text
/proposal-packet-delivery target=<proposal-packet-path> outcome=cleaned route=branch-no-pr [profile=<profile-path>] [run-id=<id>]
```

## Required Inputs

- `target`: repo-relative path to the accepted proposal packet.
- `outcome`: delivery target outcome. Defaults to `cleaned`; cleaned claims
  require final sync, terminal proof, and clean worktree proof.
- `route`: required Git/change route for cleaned delivery. Use `branch-no-pr`;
  PR fallback is forbidden unless a future accepted profile explicitly changes
  the route through its owning lifecycle.
- `profile`: optional `proposal-packet-delivery-profile-v1` profile.
- `run-id`: optional delivery run identifier for retained evidence paths.

## Outputs

- A delivery evidence bundle under `.octon/state/evidence/runs/workflows/`.
- A delivery summary under `.octon/state/evidence/validation/analysis/`.
- A `proposal-packet-delivery-receipt-v1` aggregate receipt.

The receipt may report `cleaned` only when implementation receipts, promotion
receipts, packet closeout, terminal closeout, archive handoff, generated
publication freshness, Change closeout, landing proof, branch cleanup
authorization, final sync proof, terminal proof, and worktree hygiene all pass.
Otherwise it reports `blocked` with the blocker class and next owning lifecycle.
