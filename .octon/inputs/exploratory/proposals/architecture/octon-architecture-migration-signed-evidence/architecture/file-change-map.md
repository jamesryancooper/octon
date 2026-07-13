# File Change Map

All targets are `.octon/**`. The map is exhaustive for this packet's planned
scope; directory targets grant ownership only of the RP-07 artifacts described
here.

| Promotion target | Planned change | Ownership / boundary |
| --- | --- | --- |
| `.octon/framework/constitution/contracts/retention/family.yml` | Register signed checkpoint, capacity, quota, pin, compaction, and projection contracts. | RP-07 exact entries only. |
| `.octon/framework/constitution/contracts/retention/README.md` | Document authenticated bounded evidence and raw-local boundary. | RP-07 retention narrative. |
| `.octon/framework/constitution/contracts/retention/evidence-retention-contract-v1.schema.json` | Replace prose-only rules with enforceable quota/window/pin/compaction fields. | RP-07; no SQL schema. |
| `.octon/framework/constitution/contracts/retention/evidence-store-v1.schema.json` | Bind signed checkpoint/head, capacity class, locality, and completeness refs. | Evidence contract only; RP-03 store schema excluded. |
| `.octon/framework/constitution/contracts/retention/evidence-classification-v2.schema.json` | Classify raw-local, compact, checkpoint, pointer, and publishability. | RP-07 exact classification fields. |
| `.octon/framework/constitution/contracts/retention/run-evidence-classification-v2.schema.json` | Require terminal completeness and signed checkpoint coverage. | RP-07 exact evidence fields. |
| `.octon/framework/constitution/contracts/retention/evidence-disclosure-tiers-v1.yml` | Disclose signature/anchor/locality limits without overclaim. | RP-07 evidence disclosure. |
| `.octon/framework/constitution/contracts/retention/publishable-evidence-receipt-v1.schema.json` | Require verified signed source, anchor receipt, classification, and freshness. | RP-07 projection eligibility. |
| `.octon/framework/constitution/contracts/runtime/checkpoint-v2.schema.json` | Add signed range/terminal envelope, key epoch, prior head, pins, completeness, and reserve refs. | RP-07 checkpoint fields; no lifecycle transition ownership. |
| `.octon/framework/constitution/contracts/registry.yml` | Register exact signed-evidence/retention contract identities. | Serialized exact-entry edit. |
| `.octon/framework/engine/runtime/spec/evidence-store-v1.md` | Define signed-source completeness, local raw data, compact/pointer, and failure behavior. | RP-07 evidence semantics; RP-03 operation storage remains frozen. |
| `.octon/framework/engine/runtime/spec/signed-evidence-envelope-v1.schema.json` | New strict producer-direct canonical signed envelope. | RP-07. |
| `.octon/framework/engine/runtime/spec/signed-evidence-checkpoint-v1.schema.json` | New strict signed range/terminal checkpoint and anchor-receipt contract. | RP-07. |
| `.octon/framework/engine/runtime/spec/evidence-capacity-retention-v1.md` | Specify logical/physical reserve, quotas, pins, compaction, locality, and degraded state. | RP-07; consumes RP-03 API. |
| `.octon/framework/engine/runtime/crates/evidence_attestation/` | Add canonical encoder/verifier, signer/key epoch, head client, physical reserve, pins, and compaction implementation/tests. | RP-07 library; no service/control plane. |
| `.octon/framework/engine/runtime/crates/local_broker/src/evidence.rs` | Convert RP-04 direct broker observations to RP-07 envelopes/signatures. | RP-07 exact adapter module; RP-04 retains effect behavior. |
| `.octon/framework/engine/runtime/crates/verification_publication/src/evidence.rs` | Convert RP-06 direct verifier observations to RP-07 envelopes/signatures. | RP-07 exact adapter module; RP-06 retains verdict/publication. |
| `.octon/framework/engine/runtime/crates/Cargo.toml` | Add exact `evidence_attestation` workspace membership/dependencies. | Serialized exact-entry edit. |
| `.octon/instance/governance/policies/evidence-signing.yml` | Declare admitted roles, key epochs, algorithms, revocation/rotation, anchor, and no-fallback policy. | RP-07 instance policy binding accepted ROD-001 invariants plus proved engineering defaults. |
| `.octon/instance/governance/policies/evidence-retention.yml` | Declare quotas, windows, pins, physical reserve, compaction, raw locality, and projection policy. | RP-07 instance policy binding accepted ROD-001 invariants plus proved engineering defaults. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-signed-bounded-evidence.sh` | Validate contracts, signatures, head, reserve, retention, locality, and ownership. | RP-07 assurance. |
| `.octon/framework/assurance/runtime/_ops/tests/signed-bounded-evidence/` | Add wrong-key/forgery/rechain/snapshot/ENOSPC/pin/compaction fixtures. | RP-07 dynamic/adversarial proof. |
| `.octon/framework/assurance/recovery/suites/checkpoint-fault-recovery.yml` | Add signer/head/reserve/compaction recovery boundaries. | RP-07 exact cases in existing suite. |
| `.octon/framework/assurance/scripts/validate-evidence-retention.sh` | Enforce quotas, pins, compaction receipts, raw locality, and tracked-volume bounds. | RP-07 retention checks. |
| `.octon/state/evidence/validation/proposals/octon-architecture-migration-signed-evidence/` | Retain public signer metadata, anchor/reserve policy, adversarial results, compaction/volume/UX proof, and receipts. | Evidence owner; never private keys or sensitive raw payloads. |

## Explicitly Excluded Shared Sources

- RP-03 owns its SQL migrations/schema, operation transitions, outbox,
  `runtime_bus`, and `replay_store` convergence.
- RP-04 owns all broker modules except its exact RP-07 evidence adapter.
- RP-06 owns all verifier/publication modules except its exact RP-07 evidence
  adapter.
- `.github/**`, raw provider/model payloads, and generated proposal registry are
  not RP-07 promotion targets.
