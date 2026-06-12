# Child Packet Index

| Child ID | Phase | Purpose | Dependencies |
| --- | --- | --- | --- |
| `architectural-review-native-doctrine-and-naming` | 1 | Promote doctrine and canonical naming. | none |
| `architectural-review-routing-taxonomy` | 1 | Define deterministic review routing. | `architectural-review-native-doctrine-and-naming` |
| `architectural-review-schemas-and-receipts` | 1 | Add strict schemas and support receipts. | `architectural-review-native-doctrine-and-naming`, `architectural-review-routing-taxonomy` |
| `architectural-review-native-workflows` | 2 | Add canonical workflows. | `architectural-review-routing-taxonomy`, `architectural-review-schemas-and-receipts` |
| `architectural-review-native-skills-commands` | 2 | Add thin skills and commands. | `architectural-review-native-workflows` |
| `architectural-review-proposal-lifecycle-integration` | 2 | Wire mandatory pre-integration gate. | `architectural-review-schemas-and-receipts`, `architectural-review-native-workflows` |
| `architectural-review-post-integration-boundaries` | 3 | Preserve closeout and evidence boundaries. | `architectural-review-proposal-lifecycle-integration` |
| `architectural-review-governed-mechanism-integration` | 3 | Add mechanism index entry and validator coverage. | `architectural-review-native-doctrine-and-naming`, `architectural-review-native-workflows` |
| `architectural-review-extension-split-cleanup` | 4 | Align extension prompts and remove duplicate ownership. | `architectural-review-native-doctrine-and-naming`, `architectural-review-schemas-and-receipts`, `architectural-review-native-workflows` |
| `architectural-review-validation-publication-rollout` | 4 | Add fixtures, publication checks, rollout gates, and completion evidence. | all implementation children |

All child packets are marked `required: true` and `deferred: true` in this
creation packet. That records scope without falsely claiming the children are
already accepted or implementation-authorized.
