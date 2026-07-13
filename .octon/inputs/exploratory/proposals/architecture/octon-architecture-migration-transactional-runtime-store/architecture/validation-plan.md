# Validation Plan

## Evidence Posture

All proof described here is planned. Future receipts bind exact commit,
SQLite library/engine/compile options, schema and migration digests, macOS and
filesystem, store path/class, authority epoch/high-water, ROD-001 policy,
commands, times, exit codes, fault point, retained logs/digests, and evidence
classification. Scratch state contains no production credential or effect.

## Structural Proposal Validation

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-transactional-runtime-store`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-transactional-runtime-store`
- `validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-transactional-runtime-store`
- architecture review and strict review-gate validators after real review

## Schema and Ownership Matrix

- migration checksum/order, foreign keys, uniqueness/check constraints, schema
  downgrade/upgrade refusal, and application-state invariants;
- exhaustive state-row coverage against the RP-00 writer/state inventory;
- static and dynamic write-connection census proving only migration-before-
  activation and the normal RP-04 broker identity can write;
- direct legacy file-write, raw NDJSON append, manifest rewrite, replay-store
  mutation, projection write-back, and second-database attempts all deny;
- store unavailable, wrong epoch, stale high-water, and stale projection deny
  without semantic fallback.

## Transaction and Concurrency Matrix

- N-way same-guard consume, consume-versus-revoke, duplicate idempotency key,
  duplicate operation, concurrent T1, concurrent T2, and writer-lock races;
- busy timeout and lock-holder crash before begin, during constraint checks,
  before commit, after commit acknowledgement loss, and during checkpoint;
- assert at most one authorized attempt, monotonic state, no revoked/expired
  resurrection, and no evidence-capacity double allocation;
- verify an `UNKNOWN` attempt cannot enter a new send-eligible state through
  RP-03 APIs.

## T1 / External / T2 Kill Matrix

Kill before, during, and after:

1. authority/revocation/precondition read;
2. guard/reservation consumption;
3. capacity reservation and operation/attempt creation;
4. T1 WAL flush/commit and caller acknowledgement;
5. external send start, accepted request, response, and lost response;
6. T2 observation/result-or-UNKNOWN commit and acknowledgement;
7. outbox claim, delivery, acknowledgement, and cursor update; and
8. projection/checkpoint generation.

Every restart reconstructs one explicit state. No test claims SQLite is atomic
with the external provider, no unknown is blindly retried, and RP-03 does not
classify provider-specific outcomes.

## Migration and Projection Matrix

- empty, representative, maximum-volume, duplicate, malformed, stale,
  partially written, conflicting, and post-baseline legacy inputs;
- import interruption at every migration and batch boundary;
- row-count, primary-key, semantic, digest, and lifecycle reconstruction parity;
- exact epoch activation with no dual-write observation window;
- fresh, stale, missing, tampered, wrong-epoch, and wrong-high-water projections;
- tracked file/inode/byte delta and raw/detail payload exclusion from project
  Git.

## Capacity and Storage Fault Matrix

- constrained filesystem at each threshold before T1, during WAL growth,
  before T2, during outbox, checkpoint, backup, and projection;
- ENOSPC, quota exhaustion, short write, fsync failure, permission loss,
  read-only remount, I/O error, and directory/file replacement;
- prove every required terminal class fits the selected physical reserve and
  that ordinary payload growth cannot consume it;
- prove reserve exhaustion denies admission before guard consumption or send.

## Backup, Restore, and Corruption Matrix

- online-consistent and offline backup, interrupted backup, generation pruning,
  retention window, restore to alternate path, and recovery-objective timing;
- missing/corrupt/truncated/mismatched DB or WAL, wrong schema, failed migration,
  foreign-key violation, bit flip, page corruption, and checksum mismatch;
- restore newest certified snapshot, an older valid snapshot, wrong epoch,
  lower high-water, and a snapshot before/after an external attempt;
- before-first-effect cutover snapshot rollback and post-effect no-direct-old-
  snapshot recovery with external reconciliation/epoch advance;
- repair interruption and forward-repair auditability.

## Required Evidence

Future evidence under
`.octon/state/evidence/validation/proposals/octon-architecture-migration-transactional-runtime-store/`
includes accepted ROD-001 lineage binding, the engineering-default record,
SQLite Design and Dependency Receipt, schema and
migration digests, writer inventory, import/parity and epoch receipts, every
race/kill/storage/backup/corruption result, capacity proof, projection and
tracked-state delta, rollback drill, PO-FD-005/UE-004 dispositions, conformance,
and drift/churn review.
