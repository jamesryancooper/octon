# /proposal-packet-terminal-closeout

Run the canonical proposal packet terminal closeout workflow for an implemented
proposal packet.

This command is a thin routing surface for
`.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-terminal-closeout/workflow.yml`.
It does not archive the packet, mutate proposal status, delete residue, publish
generated outputs, stage, commit, push, or create a pull request.

## Usage

```text
/proposal-packet-terminal-closeout target=<proposal-packet-path> [outcome=archive-ready] [profile=<profile-path>] [run-id=<id>]
```

## Required Inputs

- `target`: repo-relative path to the implemented proposal packet.
- `outcome`: optional terminal target outcome. Defaults to `archive-ready`.
- `profile`: optional `proposal-packet-terminal-closeout-profile-v1` profile.
- `run-id`: optional terminal run identifier for retained evidence paths.

## Outputs

- A terminal readiness bundle under `.octon/state/evidence/runs/workflows/`.
- A terminal summary under `.octon/state/evidence/validation/analysis/`.
- A packet-local `support/proposal-terminal-closeout.yml` receipt.

The receipt may report `archive-ready` only when all target-owned validators,
publication freshness checks, hygiene classifications, evidence-only reviews,
and Git/GitHub route checks pass. Otherwise it reports `blocked` with a next
canonical route.
