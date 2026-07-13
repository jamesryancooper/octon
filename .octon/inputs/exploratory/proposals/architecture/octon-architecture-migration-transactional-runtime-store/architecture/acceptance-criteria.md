# Acceptance Criteria

These are future implementation gates. Packet creation satisfies none of the
runtime-store, migration, concurrency, or recovery proof conditions.

## Entry and Design

- **AC-00:** `octon-architecture-migration-canonical-authority` freezes its
  versioned authority, revocation, exact guard, and launch semantics and RP-03
  consumes them without reinterpretation.
- **AC-01:** Accepted ROD-001 invariants are bound: raw evidence remains bounded
  and outside project Git, longer-lived signed recovery references are retained,
  terminal reserve/no-unsigned-fallback behavior remains mandatory, and missing
  recovery evidence denies while preserving work. Design exit separately
  records conservative reversible engineering defaults for store path, backup
  mechanism/cadence/generations, and physical terminal reserve.
- **AC-02:** A reviewed SQLite Design and Dependency Receipt pins the library,
  version, source, linkage, feature flags, license, advisories, supported
  macOS/toolchain, migration/backup APIs, operational burden, and rollback.

## Single Store and Writer

- **AC-03:** One schema contains every inventoried consequential grant,
  revocation, guard, operation, reservation, attempt, idempotency, outbox,
  recovery, checkpoint-head, and terminal state; every omitted state has an
  explicit non-authoritative or payload-pointer disposition.
- **AC-04:** `runtime_bus` is the only mutation library and the admitted
  migration identity or RP-04 broker is the only live write-connection owner;
  a structural writer census finds no bypass.
- **AC-05:** After epoch activation, no process writes a legacy authority or
  competing journal file. Legacy files are read-only projections/exports or
  payload pointers with store-backed freshness.
- **AC-06:** `runtime_bus` and `replay_store` use one canonical operation,
  attempt, and journal model; replay_store is mechanically read-only.

## Transaction and External Boundary

- **AC-07:** T1 atomically checks epoch/authority/revocation/precondition,
  consumes the exact one-shot guard, claims the idempotency key, reserves
  terminal capacity, creates operation/attempt/outbox state, and records
  `ATTEMPTING` before send eligibility.
- **AC-08:** T2 atomically records a bounded generic observation and result or
  `UNKNOWN`; no `UNKNOWN` attempt can be retried through RP-03 APIs.
- **AC-09:** N-way consumption, revocation, duplicate idempotency keys,
  concurrent writers, busy locks, and process races permit at most one
  authorized attempt and never resurrect revoked or consumed authority.
- **AC-10:** RP-03 exposes generic transition and observation storage only; it
  contains no Git/GitHub/provider-specific outcome classification, causal
  attribution, retry policy, or manual-intervention decision.

## Migration and Projection

- **AC-11:** The importer binds exact source digests, rejects malformed,
  duplicate, conflicting, stale, or post-baseline writes, and produces
  row-by-row plus semantic parity before activation.
- **AC-12:** Cutover quiesces effects and atomically advances one authority
  epoch with no dual-write interval. Projection parity and tracked state delta
  are retained.
- **AC-13:** Every projection carries epoch/high-water/source/freshness and is
  never accepted as a write-back or recovery authority source.

## Capacity, Backup, and Recovery

- **AC-14:** Near-full and ENOSPC tests prove the selected physical reserve can
  still record every required denial, failure, revocation, cancellation,
  rollback, unknown, manual-intervention substrate, and closeout terminal row.
- **AC-15:** Backup/restore preserves DB/WAL consistency, schema, foreign keys,
  application invariants, epoch, high-water, projection cursor, and terminal
  capacity under the ROD-001 recovery objective.
- **AC-16:** Old valid backup, missing/corrupt WAL, partial migration, wrong
  schema, bit corruption, permission loss, and interrupted repair all fail
  closed without promoting files or an older database to authority.
- **AC-17:** Before the first effect in a new epoch, the immutable certified
  cutover snapshot restores. After any effect, recovery requires high-water
  reconciliation and revocation/epoch advance or forward repair; direct older
  snapshot activation denies.

## Proof and Closeout

- **AC-18:** PO-FD-005 passes PG-03-SINGLE-STORE and UE-004 records concurrency,
  every T1/external/T2 kill point, outbox, ENOSPC, corruption, migration, and
  backup/restore results.
- **AC-19:** RP-03's FD-012 transaction and FD-013 capacity substrates are
  directly proved without claiming RP-08 reconciliation behavior or RP-07
  signed-retention/capacity completion.
- **AC-20:** RF-006 and RF-021 resolve for RP-03; RF-011, RF-012, and RF-017
  remain correctly cross-referenced to their primary owners.
- **AC-21:** Implementation conformance and post-implementation drift/churn
  receipts pass before `implemented` or implemented archival is claimed.
- **AC-22:** Publication T1 persists the complete opaque
  repository/source/target/`O/S`/grant/`V`/route/policy/history/evidence tuple,
  and no `ATTEMPTING` or `UNKNOWN` record can mutate route or any binding.
