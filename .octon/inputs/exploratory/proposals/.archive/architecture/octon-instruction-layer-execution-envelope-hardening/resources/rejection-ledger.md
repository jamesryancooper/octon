# Rejection / Exclusion Ledger

## Already-covered concepts from earlier upstream work

| Concept | Current disposition | Why not packetized |
|---|---|---|
| Canonical run-loop contract | already covered | run-centered objective/runtime family already live |
| Engine-owned authorization boundary and tripwires | already covered | execution authorization boundary already live |
| Continuity handoffs across context windows | already covered | runtime continuity contracts already live |
| Error taxonomy and bounded retries | already covered | retry and failure-classification surfaces already live |
| Verification loops as retained evidence | already covered | assurance + disclosure families already live |
| Scoped delegation | already covered | delegation governance + orchestrator profile already live |

## Rejected / non-transferable concepts

| Concept | Disposition | Why rejected |
|---|---|---|
| Durable session or chat memory as authority | reject | violates current authority model |
| Framework-specific harness embodiments | reject | packaging choices, not Octon architecture |
| Rhetorical “harness is the product” claims | reject | non-material and non-repository |
