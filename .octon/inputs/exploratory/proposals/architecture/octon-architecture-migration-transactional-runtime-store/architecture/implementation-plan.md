# Implementation Plan

This plan becomes executable only after proposal acceptance and the entry
gates above. It does not authorize database creation, migration, or effects.

## Workstream 0 — Freeze Policy and Physical Design

1. Bind RP-01's frozen versioned authority/guard semantics and exact shared
   symbol ownership.
2. Bind accepted ROD-001 evidence/recovery invariants; separately record
   conservative reversible engineering defaults for store path, backup
   mechanism/cadence/generations, and physical terminal reserve.
3. Refresh the exhaustive writer/state/source inventory from RP-00 and bind an
   exact clean repository and control-state baseline.
4. Select the one canonical operation/attempt/journal model and prohibit
   provider-specific outcome policy in RP-03.

## SQLite Design and Dependency Gate

Before code changes, compare the smallest credible SQLite integration options,
including pinned/bundled versus platform linkage, and retain a reviewed SQLite
Design and Dependency Receipt with:

- crate/library, exact version, source, checksum, license, feature flags,
  transitive/native dependencies, Rust/toolchain/MSRV, and supported macOS;
- SQLite engine version and compile options, WAL/locking/threading behavior,
  busy policy, foreign-key behavior, backup API, integrity checks, and migration
  transaction support;
- reproducibility, binary-size/build-cache impact, vulnerability/advisory
  posture, update cadence, operational burden, and removal/rollback path;
- reasons the choice preserves one embedded store without a new daemon or
  alternate writer; and
- direct prototype evidence for concurrent transactions, backup/restore,
  corruption detection, WAL recovery, and constrained volume.

No SQLite dependency is selected by this draft. A failing receipt returns the
packet to design review rather than silently adding a library.

## Workstream 1 — Schema and Transaction API

1. Define ordered, checksum-bound migrations and normalized constraints for
   store metadata, epoch/high-water, frozen authority records, operations,
   attempts, idempotency, outbox, evidence capacity, recovery, and projections.
2. Implement runtime_bus as the sole mutation API with explicit transaction
   modes and typed error/failure classes.
3. Implement T1 and T2 generic transitions, `UNKNOWN` non-retryability, and
   terminal-capacity accounting.
4. Prove replay_store opens only read-only/certified sources and shares the
   canonical data model rather than defining another journal.

## Workstream 2 — Integration Without Semantic Ownership

1. Replace authority_engine file persistence at allocated seams with frozen
   RP-01 types passed to runtime_bus transactions.
2. Preserve authority decision/guard validation before mutation and prevent
   storage errors from widening or changing semantics.
3. Define the bounded broker write interface for RP-04 without implementing
   credentials, IPC, supervision, or provider adapters.
4. Define generic observation fields for RP-08 without implementing
   provider-specific result classification, attribution, retry, or terminality.

## Workstream 3 — Legacy Import and Atomic Cutover

1. Inventory, freeze, and digest every legacy authority/journal source.
2. Import into a new offline database with deterministic conflict handling and
   row plus semantic parity reports.
3. Generate minimal read-only projections and prove stale projections cannot
   write back.
4. Quiesce effects, activate one authority epoch/high-water, retire the
   migration writer, and make legacy mutations structurally unreachable.

## Workstream 4 — Backup, Restore, Capacity, and Repair

1. Implement a conservative provisional backup cadence/generation consistent
   with the ROD-001 recovery tolerance, then measure and adjust it through
   restore certification rather than treating the mechanism or value as a new
   operator architecture choice.
2. Enforce epoch/high-water anti-resurrection checks and post-effect recovery
   rules.
3. Implement the conservative provisional physical terminal reserve and bounded
   payload-pointer behavior without a lease service; prove and tune the value
   within the ROD-001 disk/risk envelope.
4. Add corruption diagnosis and forward-repair primitives with fail-closed
   activation; RP-04 later owns operator-facing doctor/repair integration.

## Workstream 5 — Proof and Handoff

1. Run schema/invariant, writer-census, N-way race, kill-point, outbox,
   constrained-volume, migration, backup/restore, corruption, and projection
   suites against scratch state and non-production adapters.
2. Retain PO-FD-005/PG-03-SINGLE-STORE and the RP-03 portion of UE-004.
3. Measure tracked state count/size and routine setup/recovery work without
   claiming the final RF-017 burden result.
4. Complete conformance, drift/churn, rollback, and handoff receipts for RP-04,
   RP-07, and RP-08.

## Parallelization Constraints

- RP-03 begins only after RP-01 freezes semantics and cannot edit the same
  guard-semantic source or its sole validator concurrently.
- RP-03 may proceed beside RP-02 after the RP-01 freeze.
- No privileged external effect occurs until cutover and the complete fault
  proof pass.
- Migration/import fixtures are copies; tests never mutate live operator
  control state or production provider targets.
- Schema/migration implementer, adversarial/fault tester, and final trusted
  integrator are distinct trust-sensitive roles.

## Dependency Discipline

Only the reviewed SQLite dependency and already-approved workspace libraries
may enter the initial implementation. Any additional database, migration,
pooling, backup, replication, or service dependency requires an updated target
map, a new dependency receipt, and re-run completeness review. RP-03 may not
introduce a remote database, ORM control plane, second journal, or generic
project metadata store.
