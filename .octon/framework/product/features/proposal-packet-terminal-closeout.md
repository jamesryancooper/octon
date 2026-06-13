# Proposal Packet Terminal Closeout

Proposal packet terminal closeout verifies that an implemented packet is ready
for archive relocation, or records the exact blocker and next route when it is
not ready.

The mechanism sits between proposal closeout and `archive-proposal`. It emits a
`proposal-packet-terminal-closeout-receipt-v1` receipt with either
`archive-ready` or `blocked`. It does not move packets, mutate proposal status,
delete residue, create or update GitHub state, or publish generated outputs by
hand.

## Boundary

The receipt aggregates target-owned evidence only. Implementation conformance,
post-implementation drift/churn, publication freshness, run-health,
capability-publication, extension-publication, repo-hygiene, worktree hygiene,
Git/GitHub route state, and evidence-only reviews remain owned by their
respective validators and routes.

Generated effective projections, proposal-local support files, raw extension
inputs, host projections, tool state, chat history, and model memory remain
non-authoritative.

## Operator Route

```text
/proposal-packet-terminal-closeout target=<proposal-packet-path> outcome=archive-ready
```

After the receipt validates as `archive-ready`, the next canonical route is
`archive-proposal`. When the receipt is `blocked`, follow the blocker-specific
next route recorded in the receipt.
