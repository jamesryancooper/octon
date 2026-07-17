# Source of Truth Map

| Question | Source of truth |
|---|---|
| What may change? | `proposal.yml#promotion_targets` |
| What is the design? | `architecture/target-architecture.md` |
| What constitutes acceptance? | `architecture/acceptance-criteria.md` |
| How is the credential handled? | target architecture plus `owner-lane-execution-v1.md` |
| What is sealed before issuance? | admission authorization plus operation plan |
| What is generated after observation? | issuance, lifecycle, admission, manifest, attestation, completed-prefix, construction, and retirement receipts |
| How is provider-assigned PR identity bound? | completed-prefix receipt plus strict typed template construction |
| What happens after an unknown outcome? | `architecture/rollback-and-recovery.md` |
| Does this packet authorize GitHub effects? | No; `proposal.yml#explicit_runtime_non_implementation_statement` |
| May support claims widen? | No; target architecture bootstrap posture |
| How does RP-00 resume? | `architecture/cutover-plan.md` |
| What evidence is required? | `support/evidence-plan.md` and validation plan |
