---
disclosure_status: externally-shareable-after-maintainer-review
authority_mode: non-authoritative
external_transmission_approved: false
---

# Risks, Failure Modes, And Rollback

| Risk or failure | Preventive control | Detection | Rollback or containment |
| --- | --- | --- | --- |
| Sensitive workspace file enters public tree | Exact-commit allowlist plus invariant denylist | Manifest and secret/sensitivity scan | Discard candidate before import |
| Sensitive input is reproduced in generated output | Provenance and taint review | Source-to-output classification | Exclude component and rebuild |
| Workspace history reaches public repository | Separate checkout, synthetic history, remote guard | Ancestry and remote-identity check | Stop before first push; restrict legacy as decided |
| Exposed credential remains usable | Revoke-first response | Exposure review | Revoke or rotate before Git cleanup |
| Update overwrites project authority | Explicit ownership registry and hash proof | Pre/post project-path hashes | Restore prior core and lock |
| Interrupted update leaves mixed core | Journal and lock-last transaction | Recovery state machine | Recover to verified old or new state |
| Local evidence is lost | Encrypted system and disconnected backups | Restore test and digests | Restore from verified backup |
| False external-immutable claim | Real-object and content-digest requirement | Storage-class validator | Reclassify local-private |
| Public CI is supply-chain compromised | SHA pins, verified downloads, least privilege | CI policy and attestation verification | Block candidate; rotate affected credentials |
| Solo account is compromised | Independent authenticators and offline recovery | Account security alerts | Account recovery, credential rotation, release withdrawal |
| Tier 1 behavior diverges | Full lifecycle matrix and fault injection | Per-platform receipts | Block or explicitly demote target |
| Parent evidence masks child failure | Child-owned receipt freshness | Program structure/readiness validators | Keep program blocked |
| Migration removes needed hosted evidence | Classification and compact keep-set | Dry-run inventory and collaboration tests | Re-track via forward revert |
| Immutable bad release is published | Deliberate digest-bound publication | Post-publication verification | Withdraw or supersede; never overwrite |

## Rollback Principle

Prefer staging, discard, prior verified versions, forward reverts, and
compensating platform changes. Do not claim that public history or downloaded
artifacts can be recalled.

