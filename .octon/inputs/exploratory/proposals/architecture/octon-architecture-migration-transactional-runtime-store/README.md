# Transactional Runtime Store and State Migration

This is the accepted RP-03 architecture proposal for moving consequential Octon
runtime authority state into one SQLite/WAL schema and write path. It consumes
the frozen RP-01 authority and guard semantics, defines durable operation and
attempt transitions around external effects, migrates legacy file state, and
demotes those files to read-only projections or payload pointers.

Packet revision is planning only. It does not create a database, import state,
change an authority epoch, perform an effect, resolve/install a SQLite
dependency, or authorize implementation.

## Intended Outcome

- One transactional schema contains grants, revocations, guards, operations,
  reservations, attempts, idempotency, outbox, recovery, and terminal state.
- One code-level writer API and one deployed writer identity replace direct
  file mutations and competing journal models.
- T1 atomically reserves/consumes authority, reserves terminal evidence
  headroom, and records `ATTEMPTING` before any external send.
- T2 records a bounded observed result or `UNKNOWN`; unknown work cannot retry
  until a later owner applies provider-specific reconciliation policy.
- Legacy control files become read-only projections, exports, or pointers;
  raw/detail operational evidence remains outside project Git without exception.
- Backup, restore, schema migration, corruption repair, epoch/high-water
  checks, and constrained-volume terminal writes fail closed.

## Packet Status

- proposal status: `accepted`
- release state: `pre-1.0`
- change profile: `atomic`
- parent program: `octon-architecture-migration-program`
- dependency: `octon-architecture-migration-canonical-authority`

The packet binds ROD-001, passes independent post-remediation architecture and
proposal review, and authorizes only creation of its future exact implementation
through the program DAG. No implementation has begun. ROD-001 is
operator-accepted: raw evidence stays bounded/local/outside project Git;
longer-lived signed receipts, checkpoints, and rollback references are retained;
terminal reserve and no-unsigned-fallback behavior remain mandatory; and
uncertain recovery evidence denies the dependent transition while preserving
work. `resources/sqlite-design-and-dependency-receipt.yml` selects
`rusqlite =0.40.1` with bundled SQLite, exact features, store/backup paths,
online-backup protocol, measurement-adjusted cadence/generations, and a
preallocated terminal reserve. `resources/writer-state-census.yml` classifies
every current production writer/destination family and adds the missing shared
`policy.rs` integration target. RP-01's accepted design freezes the semantic
handoff; its verification remains a future implementation-entry dependency.

## Normal Solo-Builder Experience

The store is invisible during ordinary work. The operator does not edit WAL
files, reconcile YAML, choose transaction boundaries, or approve routine
state writes. Healthy runs show a concise status. Store unavailability blocks
only consequential transitions and preserves work; restore ambiguity produces
one actionable recovery route rather than a silent fallback to file authority.

## Ownership Boundary

RP-01 owns the meaning of authority, grants, revocation, and guard consumption;
RP-03 stores and transacts their frozen representations without changing those
semantics. `runtime_bus` owns the canonical transactional schema/migrations and
sole mutation API. `replay_store` owns read-only reconstruction, export, and
projection verification. RP-04 later owns the sole deployed writer process and
broker access. RP-08 owns provider-specific outcome classification,
reconciliation, retry, and `manual_intervention` behavior.

## Exit Shape

After accepted implementation and direct proof, RP-03 may close only when
PO-FD-005 passes PG-03-SINGLE-STORE, UE-004's store portion is adversarially
proved, no legacy authority writer remains, rollback/restore cannot resurrect
older authority, and conformance plus drift reviews pass.

For publication, T1 also freezes and digests repository, source identity/ref,
target ref, `O`, `S`, grant, `V`, route-policy, history shape, operation,
attempt, and evidence head. Route cannot mutate while `ATTEMPTING` or `UNKNOWN`.
RP-03 persists these opaque values but never issues authority, interprets a
verdict, selects a route, or classifies provider results.
