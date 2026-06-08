# Child Packet Index

All child packets are required, archived sibling proposal packets. Parent
evidence coordinates only and never satisfies child receipts.

| Order | Child | Focus | Dependencies |
| --- | --- | --- | --- |
| 1 | `lifecycle-postmortem-meta-workflow` | Meta workflow, evidence layout, CLI/runtime entry point | none |
| 2 | `lifecycle-postmortem-evaluator-template` | Evaluator template, invariant compliance and validity reviews, structured output contract, finding mapping | lifecycle-postmortem-meta-workflow |
| 3 | `lifecycle-postmortem-validator` | Validator, invariant compliance and validity fixtures, tests, assurance registration | lifecycle-postmortem-meta-workflow, lifecycle-postmortem-evaluator-template |
