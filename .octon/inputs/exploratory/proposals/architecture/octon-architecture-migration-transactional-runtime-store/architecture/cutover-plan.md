# Cutover Plan

## Preconditions

- `octon-architecture-migration-canonical-authority` freezes the versioned
  authority/revocation/guard semantics and exact persistence interfaces.
- Accepted ROD-001 invariants are bound before cutover. The cutover record
  separately binds the proved store path, backup mechanism/defaults, and
  physical reserve engineering configuration.
- The SQLite Design and Dependency Receipt, proposal acceptance,
  implementation-grade completeness, and independent architecture review pass.
- RP-00's exact writer/state inventory is refreshed; all live effect and state
  writers have an owner and cutover disposition.
- The repository/control baseline is quiescent and digest-bound; an immutable,
  certified cutover snapshot and protected recovery route exist.
- Full scratch migration, race, kill-point, capacity, corruption, and
  backup/restore suites pass on the exact selected tuple.

## Offline Preparation

1. Build a new database at an inactive path and verify library engine/compile
   options, filesystem/WAL support, schema migrations, and physical reserve.
2. Freeze and digest every legacy authority, journal, runtime-state, attempt,
   outbox, recovery, checkpoint-head, and relevant evidence source.
3. Import deterministically, rejecting duplicates/conflicts/stale writes, and
   produce row plus semantic parity and omission dispositions.
4. Generate candidate read-only projections and prove their freshness and
   write-back denial.
5. Create and independently restore a consistent backup; certify schema,
   epoch/high-water, integrity, capacity, and recovery-objective results.

## Atomic Authority-Epoch Transition

1. Quiesce all consequential effects and verify no state writer is active.
2. Recheck source digests and refuse any post-freeze legacy mutation.
3. Activate exactly one new authority epoch/high-water and its sole mutation
   API; retire the migration writer.
4. Make every legacy authority/journal write path structurally unreachable and
   enable projection generation only after committed store transactions.
5. Run read-only reconstruction, authorization-semantic parity, writer census,
   store-unavailable denial, and dry-run T1/T2 checks.
6. Run one bounded scratch adapter attempt with no production credential or
   target and complete all kill/restart/UNKNOWN/outbox observations.
7. Publish migration, activation, writer-retirement, capacity, backup/restore,
   rollback, PO-FD-005, UE-004, conformance, and drift receipts.

There is no dual-write or shadow-authority period. Read-only pre-cutover
comparison is allowed; a second normal writer or bidirectional projection is
not.

## Safe Resting State

At SI-03, the one store is authoritative, legacy files are read-only
projections, and consequential effects may remain disabled while RP-04 is not
yet installed. This is a valid extended pause: authority state is durable and
recoverable, candidate work is preserved, and no provider-specific outcome is
inferred.

## Handoff

- RP-04 receives the bounded write API, writer-identity requirements, schema
  digest, epoch/high-water, backup/repair primitives, and no credential state.
- RP-07 receives capacity reservation and payload-pointer substrate but retains
  signing, monotonic checkpoint strengthening, quotas, pins, compaction, and
  retention ownership.
- RP-08 receives generic T1/T2/UNKNOWN/outbox transitions and test fixtures but
  retains provider classification, reconciliation, retry, and manual-
  intervention ownership.
- replay and disclosure consumers receive certified read-only projections or
  snapshots, never a write connection.

Handoffs cite retained evidence by digest and cannot transfer authority or
create another store writer.
