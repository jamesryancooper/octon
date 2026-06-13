# Proposal Packet Terminal Closeout

`proposal-packet-terminal-closeout` verifies terminal readiness for an
implemented proposal packet and emits an aggregate terminal receipt with either
`archive-ready` or `blocked`.

The workflow can sequence validators, cite target-owned evidence, delegate
required side-effect routes, run evidence-only review hooks, and write a
packet-local receipt projection. It must not move packets into `.archive`,
mutate proposal status, publish generated outputs directly, mutate Git refs,
delete residue, or replace target-owned receipts.

## Command

```text
/proposal-packet-terminal-closeout target=<packet-path> outcome=archive-ready
```

## Contract

- Canonical workflow contract:
  `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-terminal-closeout/workflow.yml`
- Profile schema:
  `.octon/framework/product/contracts/proposal-packet-terminal-closeout-profile-v1.schema.json`
- Receipt schema:
  `.octon/framework/product/contracts/proposal-packet-terminal-closeout-receipt-v1.schema.json`
- Workflow validator:
  `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-workflow.sh`

## Stages

1. `bind-profile`
2. `verify-durable-implementation-state`
3. `verify-implementation-conformance`
4. `verify-post-implementation-drift`
5. `validate-publication-freshness`
6. `classify-repo-hygiene`
7. `classify-worktree-hygiene`
8. `run-evidence-only-reviews`
9. `resolve-git-github-route`
10. `emit-terminal-receipt`
