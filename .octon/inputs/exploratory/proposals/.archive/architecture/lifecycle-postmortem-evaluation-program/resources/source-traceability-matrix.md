# Source Traceability Matrix

| Requirement | Parent / Child Owner | Evidence |
| --- | --- | --- |
| Post-run invocation against a completed lifecycle | `lifecycle-postmortem-meta-workflow` | Workflow contract and runtime entry point |
| Reconstruct actual lifecycle run from retained artifacts | `lifecycle-postmortem-meta-workflow` | Evidence binding stage and evidence map |
| Use rigorous required postmortem structure | `lifecycle-postmortem-evaluator-template` | Template and structured output schema |
| Evaluate invariants before quality scoring | `lifecycle-postmortem-evaluator-template` | Invariant Evaluation section and structured invariant records |
| Use strict invariant rating set | `lifecycle-postmortem-evaluator-template` | Pass, Partial, Fail, Unknown, Not Applicable schema enum |
| Treat Unknown invariant ratings as evidence gaps | `lifecycle-postmortem-evaluator-template` and `lifecycle-postmortem-validator` | Template decision rules and Unknown-as-Pass negative fixture |
| Review invariant validity and evolution pressure | `lifecycle-postmortem-evaluator-template` | Invariant Validity and Evolution Review section and structured records |
| Keep invariant changes behind separate governance | all children | Non-authority statements, change-control bar, validator negative controls |
| Preserve evaluator outputs as evidence only | all children | Workflow authorization, evaluator contract, validator negative controls |
| Emit durable findings where needed | `lifecycle-postmortem-evaluator-template` | `review-finding-v1` mapping |
| Validate final judgment enum | `lifecycle-postmortem-validator` | Report validator |
| Validate invariant table shape and blocking semantics | `lifecycle-postmortem-validator` | Positive and negative invariant fixtures |
| Validate invariant validity/evolution table and recommendation categories | `lifecycle-postmortem-validator` | Positive and negative invariant validity fixtures |
| Validate evidence refs resolve and stay in allowed roots | `lifecycle-postmortem-validator` | Positive and negative fixtures |
| Prevent generated/input authority drift | `lifecycle-postmortem-validator` | Negative-control fixtures |
| Keep closeout and redesign authorization separate | all children | Done gates and non-authority statements |
