# Packet Sequence

| Order | Child | Gate | Rationale |
| --- | --- | --- | --- |
| 1 | `lifecycle-postmortem-meta-workflow` | none | Defines the runtime and evidence path that makes the postmortem runnable. |
| 2 | `lifecycle-postmortem-evaluator-template` | workflow child review | Defines the report and structured output consumed by the workflow. |
| 3 | `lifecycle-postmortem-validator` | workflow and template child review | Proves the workflow/template outputs are valid and non-authorizing. |

`lifecycle-postmortem-validator` depends on both earlier children because its
fixtures and validation rules must cover the final workflow output layout and
the final evaluator template contract.
