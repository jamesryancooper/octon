# Current-State Gap Map

## Baseline

The fixed reconciliation baseline is
`c5b1f5760c78ff521cca6b054e4e8fef5300505b`. Creation reinspection uses
`d78ee8b42cb3a39557bbe39b66cb5d156946172a`; no RP-03 implementation or
SQLite dependency exists at packet creation.

## Material Gaps

| Gap | Current evidence | Required RP-03 correction | Adjacent owner |
| --- | --- | --- | --- |
| No one transactional authority store | Grants, revocations, run state, journal entries, manifests, attempts, checkpoints, and evidence records span YAML/JSON/NDJSON paths and independent writes. | Import all consequential lifecycle state into one SQLite/WAL schema and mutation API. | RP-01 freezes semantic meaning before persistence changes. |
| Journal append is multi-file | `runtime_bus` appends `events.ndjson` and rewrites `events.manifest.yml`; `authority_engine` separately materializes `runtime-state.yml` and related control/evidence files. | Replace live authority mutations with one transaction and emit files only as post-commit projections or pointers. | RP-03 primary. |
| Duplicate journal models remain | `runtime_bus` and `replay_store` define overlapping journal/event/ledger models and canonical file paths. | Select one SQL operation/attempt/journal model; make replay_store a read-only consumer and projection verifier. | RP-03 owns both sides of this split. |
| Authority files are direct inputs and outputs | `authority_engine` reads approval grants and revocations and writes grant bundles and runtime records directly. | Persist frozen RP-01 representations transactionally; eliminate direct live authority file writers after epoch activation. | RP-01 owns the types and decisions, not persistence. |
| External effects cannot share a SQLite commit | No durable T1/attempt/external/T2 envelope covers every crash boundary. | Commit reservation, consumption, idempotency, capacity, and `ATTEMPTING` in T1; commit bounded result or `UNKNOWN` in T2. | RP-08 later owns provider-specific reconciliation semantics. |
| Terminal capacity is not reserved with operation admission | Evidence retention exists, but no same-transaction physical reserve proves denial/failure/revocation/rollback/closeout remain writable near full storage. | Add capacity accounting and fault-proven physical headroom substrate without a lease subsystem. | RP-07 owns final evidence policy, signatures, quotas, and compaction. |
| Restore can resurrect older authority | No activated SQLite epoch/high-water or certified DB/WAL recovery path exists. | Bind activation and recovery to monotonic epoch/high-water checks; reject direct older-backup activation. | ROD-001 sets recovery tolerance; RP-07 later strengthens checkpoint authenticity. |
| State volume remains operational burden | Large tracked per-run state and repeated projections impose clone, index, validation, and maintenance cost. | Project only minimal classified signed pointers/checkpoints; raw/detail operational evidence remains outside project Git without exception. | RP-14 measures integrated burden; RP-07 owns retention policy. |
| SQLite implementation choice is absent | The runtime workspace has no SQLite crate dependency or migration mechanism. | Select and review the library/linkage/features with a Dependency Receipt before implementation. | RP-03 design gate. |

## Preserved Primitives

- RP-01's typed authority, revocation, scope, and exact guard semantics;
- Run Lifecycle legality and append-time authority-boundary validation;
- existing journal hash/link, reconstruction, replay-gap, and evidence-role
  concepts where they remain compatible with one transactional model;
- control versus retained-evidence separation;
- fail-closed handling for generated/input non-authority and unresolved refs;
- route-neutral preserved work and contained operation while consequential
  effects are disabled; PR remains possible only through a fresh valid
  pre-effect RP-06 decision.

## Removed or Demoted Behavior

- file locking, atomic rename, NDJSON append, or narrow CAS as final runtime
  transaction authority;
- separate writable run journal, runtime-state, grant, revocation, attempt,
  outbox, or recovery files;
- replay_store as a competing canonical journal model;
- blind retry across an uncertain external outcome;
- direct activation of an old database backup or restoration of file authority;
- raw/detail operational evidence payloads in project Git.

## Unresolved Design Inputs

ROD-001 is operator-accepted and fixes bounded local raw evidence outside Git,
longer-lived signed recovery references, terminal reserve, no unsigned fallback,
and deny/preserve-work behavior when recovery evidence is uncertain. Store
location, backup mechanism and provisional cadence/generations, and physical
reserve implementation/size use conservative reversible engineering defaults
with a measurement-and-adjustment rule. The SQLite dependency, linkage,
migration runner, backup API,
and corruption-repair mechanics are engineering choices that require a future
design and dependency receipt. None is an implementation authorization.
