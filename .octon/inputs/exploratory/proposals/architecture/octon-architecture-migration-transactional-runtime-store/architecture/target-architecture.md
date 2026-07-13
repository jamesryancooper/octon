# Target Architecture

## Target State: SI-03 One Transactional Source of Truth

One local SQLite database in WAL mode becomes the only authoritative runtime
store for consequential lifecycle state. Accepted ROD-001 invariants constrain
recovery, retention, terminal reserve, no-fallback, and deny/preserve-work
behavior; engineering binds the exact location, backup mechanism and provisional values,
and physical terminal reserve through conservative reversible defaults and
proof. Store activation is bound to a
schema version, authority epoch, monotonic high-water value, and exact imported
source digest set.

## Canonical Data Model

The smallest complete schema has one normalized ownership boundary across:

- store metadata, schema migrations, authority epoch, and high-water state;
- frozen RP-01 grant registrations, revocations, guard identities, exact
  scopes, expiries, and one-shot consumption;
- operations, target preconditions, idempotency keys, reservations, and
  operation terminal state;
- attempts, send eligibility, generic observations, `ATTEMPTING`, `UNKNOWN`,
  result, cancellation, compensation, rollback, and manual-intervention
  substrate;
- evidence-capacity reservation, terminal record budget, and outbox delivery;
- recovery/checkpoint heads, projection cursors, import lineage, and repair
  receipts; and
- bounded payload digests/pointers where raw or detailed bodies remain outside
  the database or project Git.

Foreign keys, uniqueness constraints, checks, transaction modes, and schema
migrations enforce the state machine. An application convention alone is not
sufficient for one-shot consumption, idempotency, attempt identity, or epoch
monotonicity.

## T1, External Call, and T2

For every consequential effect:

1. **T1:** one immediate write transaction checks the active epoch, frozen
   authority and revocation state, exact guard/scope, operation precondition,
   idempotency uniqueness, and terminal capacity; it consumes the one-shot
   guard/reservation, creates the operation and attempt, records
   `ATTEMPTING`, and commits the outbox/send intent.
2. **External:** the admitted adapter performs at most the exact authorized
   send outside SQLite. SQLite and the external provider are never described
   as one atomic transaction.
3. **T2:** one write transaction records the authenticated generic observation
   and a bounded result or `UNKNOWN`, advances the outbox/recovery cursor, and
   writes required terminal evidence metadata.

An `UNKNOWN` attempt is not retryable. RP-03 supplies the durable state and
compare-and-set API; RP-08 owns provider-specific classification,
reconciliation, retry eligibility, state-satisfied versus attempt-performed
claims, and honest `manual_intervention` behavior.

## Writer and Reader Topology

- `runtime_bus` owns the schema, ordered migrations, transactional store API,
  generic transition invariants, import, projection cursor, backup validation,
  and repair primitives. It is the only code path that mutates the store.
- A one-use trusted migration identity may open the store before authority
  epoch activation. It cannot perform effects and is retired at cutover.
- RP-04's supervised broker becomes the sole normal deployed process allowed
  to hold a write connection. Other components call its bounded interface.
- `authority_engine` supplies frozen semantic decisions and typed values; it
  cannot bypass runtime_bus or write legacy authority files after cutover.
- `replay_store` opens certified snapshots or a read-only connection for
  reconstruction, export, and projection comparison. It cannot migrate,
  repair, consume, reconcile, or advance authority.

This is one control plane: one schema, one mutation library, one deployed
writer identity, and one epoch. SQLite is embedded storage, not a new service.

## Projection and Payload Boundary

Legacy files may remain only as deterministic, post-commit read models,
exports, or content-addressed payload pointers. Every projection records store
epoch, high-water, transaction/row source identity, source digest, projection
version, and freshness. A missing or stale projection is regenerated from the
store and never imported back into live authority.

Control and retained evidence remain role-separated. Raw logs, transcripts,
and detailed operational payloads are local and outside project Git without exception; the store
retains bounded metadata, digest, locator, classification, and terminal
obligation. RP-07 later owns signing, quotas, pins, compaction, and long-term
retention.

## Backup, Restore, and Corruption Boundary

- Backups use a SQLite-consistent mechanism and include the exact schema,
  epoch, high-water, integrity result, and source database/WAL identity.
- Restore candidates open offline, pass integrity/foreign-key/application
  invariants, and compare against a candidate-inaccessible monotonic
  epoch/high-water record before activation.
- Before any effect in a newly activated epoch, rollback may return to its
  immutable certified cutover snapshot.
- After an effect, an older snapshot is never made live directly. Effects stay
  disabled while external outcomes are reconciled and uncertainty is revoked
  or a higher epoch is activated; otherwise repair proceeds forward.
- Corruption, WAL loss, schema mismatch, busy timeout, disk exhaustion, or
  reserve failure blocks consequential writes and preserves diagnostic proof.

## Availability and Solo Operation

The store starts with the owning local runtime and requires no remote database,
daemon fleet, or per-operation approval. Routine checkpoint, backup, and
projection maintenance follow the selected policy. Store failure preserves
candidate work and safe read-only activity while consequential transitions
stop with one concise status and recovery route.

The publication specialization stores the complete opaque tuple digest:
repository, source identity/ref, `S`, target ref, `O`, RP-01 grant, RP-06 `V`,
route/history/policy, operation/attempt/idempotency, consequence, and RP-07
evidence head. T1 freezes it before send. No API may change route or substitute
one of these bindings while `ATTEMPTING` or `UNKNOWN`; a new route requires a
new pre-effect decision and attempt.
