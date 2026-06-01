# Child Packet Index

| Child | Purpose | Dependencies |
|---|---|---|
| `proposal-program-runner-terminal-gap-map` | Verify remaining gaps and map implementation ownership. | none |
| `proposal-program-runner-workflow-retry-ids` | Fix duplicate workflow run-id retry behavior and safe resume policy. | gap map |
| `proposal-program-runner-change-handoff-checkpoints` | Add non-authorizing Change/worktree handoff checkpoints. | gap map |
| `proposal-program-runner-aggregate-terminal-blockers` | Add parent-controller aggregate child terminal blocker evidence. | gap map |
| `proposal-program-runner-promotion-evidence-binding` | Bind promotion evidence to selected child identity. | gap map |
| `proposal-program-runner-publication-freshness-preflight` | Classify generated-state freshness before workflow dispatch. | gap map |
| `proposal-program-runner-parent-review-churn` | Suppress irrelevant parent review freshness churn. | gap map |
| `proposal-program-runner-archive-observation-recovery` | Harden archive observation and blocked archive evidence. | workflow retry, aggregate blockers |
| `proposal-program-runner-terminal-routing-tests` | Add end-to-end regression fixtures and negative controls. | all behavior children |

`proposal-program-runner-change-handoff-checkpoints` is resolved through the
child-owned archived packet path recorded in `resources/child-packet-index.yml`.
The parent index uses that path only for lookup; child receipts, archive
metadata, validation verdicts, promotion targets, and terminal outcomes remain
child-owned.
