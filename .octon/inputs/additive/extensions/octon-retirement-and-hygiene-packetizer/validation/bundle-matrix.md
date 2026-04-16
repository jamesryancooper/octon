# Bundle Matrix

| Flow | Reads `repo-hygiene scan` | Reads audit artifacts | Reads packet attachment | Can scaffold proposal draft | Guardrails |
| --- | --- | --- | --- | --- | --- |
| `scan-to-reconciliation` | yes | no | no | no | protected and claim-adjacent surfaces remain `never-delete` |
| `audit-to-packet-draft` | no | yes | no | yes | delete-safe signals rewritten as ablation-review candidates |
| `registry-gap-analysis` | optional | optional | no | no | missing or stale coverage is reported, not auto-resolved |
| `ablation-plan-draft` | no | optional | yes | yes | protected and claim-adjacent surfaces remain `never-delete` |
