# /proposal-packet-delivery

Run the canonical proposal packet delivery workflow for an accepted proposal
packet.

This command is the outer routing surface for
`.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-delivery/workflow.yml`.
It coordinates implementation, promotion, packet closeout, terminal closeout,
archive handoff, Change closeout, final sync, branch cleanup, terminal proof,
and final hygiene. It does not replace target-owned receipts, archive packets
directly, delete residue, publish generated outputs by hand, stage, commit,
push, create pull requests, or clean up branches.

## Usage

```text
/proposal-packet-delivery target=<proposal-packet-path> outcome=cleaned route=branch-no-pr profile=<profile-path> run-id=<id>
```

## Required Inputs

- `target`: repo-relative path to the accepted proposal packet.
- `outcome`: delivery target outcome. Use `cleaned` for clean delivery; cleaned
  claims require final sync, terminal proof, and clean worktree proof.
- `route`: required Git/change route for cleaned delivery. Use `branch-no-pr`;
  PR fallback is forbidden.
- `profile`: required `proposal-packet-delivery-profile-v1` profile path.
- `run-id`: required delivery run identifier for retained evidence paths.

Resume may satisfy `profile` or `run-id` only through fresh, target-bound
workflow evidence from the prior delivery attempt. Proposal-local support
files, generated prompts, generated outputs, dashboards, host/tool/chat state,
model memory, parent summaries, aggregate delivery receipts, and delivery
evidence indexes do not satisfy these admission inputs.

## Packet State Routing

- Pre-archive packet states route through `closeout-packet`,
  `proposal-packet-terminal-closeout`, and `archive-proposal`.
- Already-archived packet states validate archive evidence, skip archive
  relocation, and route through `closeout-change` or `closeout-worktree` for
  hosted landing, final sync, branch cleanup authorization, terminal
  current-state proof, and worktree hygiene.
- Archive relocation, generated publication, Change closeout, branch cleanup,
  final sync, terminal proof, and hygiene remain owner-routed. The wrapper may
  detect missing evidence and report `blocked`, but it does not replace the
  owner.

## Outputs

- A delivery evidence bundle under `.octon/state/evidence/runs/workflows/`.
- A delivery summary under `.octon/state/evidence/validation/analysis/`.
- A `proposal-packet-delivery-receipt-v1` aggregate receipt.

The receipt may report `cleaned` only when implementation receipts, promotion
receipts, packet closeout, terminal closeout, archive handoff, generated
publication freshness, Change closeout, landing proof, branch cleanup
authorization, final sync proof, terminal proof, and worktree hygiene all pass.
Otherwise it reports `blocked` with explicit blockers and the next owning
lifecycle. Aggregate delivery receipts summarize target-owned receipts and
never replace them.
