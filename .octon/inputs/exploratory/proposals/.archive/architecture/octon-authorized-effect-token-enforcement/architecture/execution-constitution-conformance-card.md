# Execution Constitution Conformance Card

| Principle | Packet posture | Conformance |
|---|---|---|
| Octon remains a Constitutional Engineering Harness | Packet hardens one runtime enforcement boundary only. | Pass |
| Governed Agent Runtime remains execution substrate | Runtime consumes tokens; it does not mint a new constitution. | Pass |
| Engine-owned authorization boundary | Tokens derive only from `authorize_execution` or engine-owned grant projection. | Pass |
| Deny by default | Missing, invalid, expired, revoked, wrong-kind, wrong-scope, or unjournaled tokens fail closed. | Pass |
| Generated non-authority | Generated outputs may display status only. | Pass |
| Raw inputs non-authority | Raw paths/caller assertions cannot substitute for tokens. | Pass |
| State/control distinction | Live token states live under `state/control/execution/**`. | Pass |
| Evidence/provenance distinction | Token receipts and bypass proof live under `state/evidence/**`. | Pass |
| Support-target realism | No support-target widening; live tuples only gain proof obligations. | Pass |
| Reversibility and recovery | Token scopes must cite rollback/compensation posture where consequential. | Pass |
| Operator legibility | Token lifecycle appears in Run Journal and retained disclosure. | Pass |
| Promotion safety | Proposal path is non-authoritative and temporary. | Pass |

## Residual conditions

- Closure depends on canonical Run Journal availability for final event/item semantics.
- `.github/**` workflow wiring, if required, must be handled outside this octon-internal packet or via existing validator discovery.
