# Current-State Gap Map

## Repository-Grounded Baseline

Current Octon has useful hash-linked journals, checkpoint contracts,
evidence-store completeness language, retention schemas, localization helpers,
`runtime_bus`, and `replay_store`. Static review also found that the live model
uses unkeyed recomputable hashes, lacks checkpoint signatures, has no
candidate-inaccessible monotonic head, does not reserve physical terminal
capacity, and does not enforce bounded retention/compaction.

## Gaps

| Gap | Current state | Required target | Owner / proof |
| --- | --- | --- | --- |
| FD-013 logical capacity | No same-transaction terminal capacity reservation | RP-03 T1 reserves the RP-07 terminal size class through a frozen API | RP-03 interface, RP-07 policy; PO-FD-013 |
| FD-013 physical capacity | Free-space/SQL state cannot ensure terminal writes under `ENOSPC` | Preallocated non-sparse writer-exclusive reserve survives constrained-volume faults | RP-07; PG-07-EVIDENCE-CAPACITY |
| FD-014 producer authenticity | Hash links and hash-valued `signature` fields are recomputable | Role-bound broker/verifier identities sign canonical direct observations | RP-07; PO-FD-014 |
| FD-014 checkpoints | checkpoint-v2 has no cryptographic signature/head chain | Signed range/terminal checkpoints bind range, prior head, keys, pins, completeness, and terminal state | RP-07; PG-07-SIGNED-EVIDENCE |
| Old-snapshot rollback | DB-local valid old records can be restored together | Candidate-inaccessible monotonic compare-and-advance head rejects older snapshots/forks | RP-07; UE-008 |
| Bounded retention | Retention contract fields are largely descriptive; raw growth remains material | Executable quotas, pins, locality, and verified compaction | RP-07; RF-017/RF-029 |
| Compaction safety | Compact views digest-bind sources but no signed delete-safe operation exists | Verify-checkpoint-anchor-delete with crash recovery and pin protection | RP-07; UE-008 |
| Claim honesty | Some `signature`/attestation language exceeds implemented guarantee | Every cryptographic claim maps to verified key-bound proof; missing evidence blocks claims | RP-07 plus RP-00/RP-14 claim inventory; RF-013 |
| Git substitution | Git may retain hashes but does not authenticate producer observations | Git retains only signed checkpoints/pointers; never substitutes for signatures | RP-07; RF-022 |
| Degraded evidence behavior | Missing storage/signer may prevent evidence without a narrow safe state | Block dependent transition, preserve candidate/raw data, no unsigned fallback | RP-07 evidence part of FD-016 |

## Preserved Strengths

- Keep honest evidence-store completeness and fail-closed closure rules.
- Keep a single embedded transactional store and one canonical operation model;
  do not preserve two canonical journals.
- Keep inline governance exception leases distinct from capacity; do not create
  a capacity lease subsystem.
- Keep raw evidence localization and disclosure classifications, strengthening
  them with enforceable bounds and signed pointers.
- Keep checkpoint-v2 lineage by extending it through an atomic clean-break
  contract rather than inventing a parallel live checkpoint family.

## Evidence Limits

All current-state claims are statically inspected. No RP-07 implementation or
adversarial result exists. UE-008 therefore remains unresolved. Narrowed
Accepted ROD-001 fixes bounded raw locality, longer-lived signed recovery
references, terminal reserve, no unsigned fallback, and deny/preserve-work
behavior; engineering controls the
exact signer, anchor, reserve, backup, and provisional budget mechanisms.
