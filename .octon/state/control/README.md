# State Control

`state/control/**` stores mutable current-state operational truth.

## Canonical Control Records

| Path | Purpose |
| --- | --- |
| `state/control/extensions/active.yml` | Actual active extension publication state, including desired versus published truth |
| `state/control/extensions/quarantine.yml` | Extension quarantine and withdrawal records |
| `state/control/locality/quarantine.yml` | Locality quarantine state |

Desired authored configuration remains under `instance/**`. Runtime-facing
compiled publication remains under `generated/**`. Machine-readable
publication receipts live under `state/evidence/validation/publication/**`.
