# File Change Map

All entries are planned, not implemented. `runtime_bus` owns the transactional
store and mutation API; `replay_store` owns read-only reconstruction;
`authority_engine` consumes frozen RP-01 semantics at allocated persistence
seams. The trusted integrator must prevent concurrent semantic and persistence
edits.

| Durable promotion target | Current assumption | Required RP-03 change | Ownership and rationale |
| --- | --- | --- | --- |
| `.octon/framework/engine/runtime/crates/Cargo.toml` | Workspace dependencies contain no SQLite library. | Add only the reviewed, pinned SQLite dependency/features selected by the future Design and Dependency Receipt. | RP-03 dependency gate; no ORM, server, or pool control plane. |
| `.octon/framework/engine/runtime/crates/Cargo.lock` | No SQLite dependency graph is locked. | Lock the accepted dependency and verify exact transitive/native inputs. | Derived durable dependency lock; review required. |
| `.octon/framework/engine/runtime/crates/runtime_bus/Cargo.toml` | runtime_bus uses filesystem, serialization, hashing, and error libraries. | Bind the selected SQLite dependency and only required test support. | RP-03 primary crate. |
| `.octon/framework/engine/runtime/crates/runtime_bus/src/lib.rs` | Defines file-backed Run Journal models and append APIs. | Export one canonical store API and retain compatibility entry points only as projections during migration. | RP-03 primary mutation owner. |
| `.octon/framework/engine/runtime/crates/runtime_bus/src/store.rs` | No database connection/role/epoch boundary exists. | Add role-bound open, transaction, PRAGMA/compile-option verification, epoch/high-water, and fail-closed error handling. | Planned new RP-03 module. |
| `.octon/framework/engine/runtime/crates/runtime_bus/src/schema.rs` | No normalized SQL runtime schema exists. | Define canonical typed rows, constraints, generic states, and invariant checks. | Planned new RP-03 module. |
| `.octon/framework/engine/runtime/crates/runtime_bus/src/transactions.rs` | No one T1/T2 authority/effect substrate exists. | Add atomic reserve/consume/capacity/attempt/outbox T1 and generic result-or-UNKNOWN T2 APIs. | Planned new RP-03 module; no provider policy. |
| `.octon/framework/engine/runtime/crates/runtime_bus/src/migrations.rs` | No ordered migration/import runner exists. | Verify migration checksums/order, bind source digests, import offline, and emit parity/activation receipts. | Planned new RP-03 module. |
| `.octon/framework/engine/runtime/crates/runtime_bus/src/projections.rs` | Journal and runtime files are live sources rather than store-derived read models. | Emit minimal epoch/high-water/source-bound read-only projections and reject write-back. | Planned new RP-03 module. |
| `.octon/framework/engine/runtime/crates/runtime_bus/src/recovery.rs` | No certified DB/WAL backup, restore, integrity, or repair API exists. | Implement ROD-001 backup/restore validation, capacity checks, corruption diagnosis, and anti-resurrection recovery. | Planned new RP-03 module; operator UX later integrates through RP-04. |
| `.octon/framework/engine/runtime/crates/runtime_bus/migrations/` | No SQL migration family exists. | Add ordered immutable SQL migrations for the accepted v1 schema. | Planned new RP-03 source; each migration is checksum-bound. |
| `.octon/framework/engine/runtime/crates/replay_store/Cargo.toml` | replay_store has a separate file-journal model and no shared store binding. | Depend on the canonical read-only model/API without acquiring a SQLite write capability. | RP-03 read-side boundary. |
| `.octon/framework/engine/runtime/crates/replay_store/src/lib.rs` | Duplicates journal/event/ledger types and canonical file paths. | Consume certified snapshots/read-only store views and verify projections; remove competing canonical semantics. | RP-03 read-only owner. |
| `.octon/framework/engine/runtime/crates/authority_engine/Cargo.toml` | Depends on runtime_bus but current persistence remains file-oriented. | Bind the revised store API without adding a second database dependency or direct connection. | Shared RP-01/RP-03 seam. |
| `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/authority.rs` | Loads and writes grant/revocation/bundle files. | Replace only allocated persistence calls with frozen semantic records passed to runtime_bus; projections remain outputs. | RP-01 semantics preserved; RP-03 persistence only. |
| `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/effects.rs` | Effect-token/consumption lifecycle is not one store transaction. | Bind exact one-shot effect substrate to T1/T2 calls without changing authorization meaning. | Shared seam; no provider adapter or broker implementation. |
| `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs` | Orchestrates many independent control/evidence file writes around journal events. | Route consequential lifecycle mutation through the canonical transaction and post-commit projection APIs. | Shared allocated call sites only. |
| `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/records.rs` | File-shaped runtime records do not express the canonical SQL operation/attempt binding. | Add minimal frozen-type adapters and projection records; do not redefine RP-01 types. | Shared data seam. |
| `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/runtime_state.rs` | Appends via runtime_bus but separately materializes runtime-state, checkpoint, replay, and evidence files. | Read canonical state and emit bounded projections/snapshots after commit; eliminate authority write bypasses. | RP-03 persistence integration. |
| `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/tests.rs` | Tests file journals and materializations, not full transactional migration/fault behavior. | Add integration coverage for frozen semantics over one store, projection non-authority, and no file-write fallback. | Shared integration tests. |
| `.octon/framework/engine/runtime/spec/run-journal-v1.md` | Defines canonical NDJSON/YAML control journal. | Recast it as a compatibility projection/export of the canonical store and document retirement/write denial. | RP-03 convergence contract. |
| `.octon/framework/engine/runtime/spec/evidence-store-v1.md` | Defines evidence roots but not same-transaction terminal-capacity/pointer substrate. | Bind bounded terminal metadata/capacity and external raw/detail pointers without taking RP-07 retention ownership. | RP-03 substrate, RP-07 policy. |
| `.octon/framework/engine/runtime/spec/transactional-runtime-store-v1.md` | No canonical store contract exists. | Define schema ownership, writer roles, T1/T2, epoch, projection, migration, backup/restore, and failure behavior. | Planned new RP-03 contract. |
| `.octon/framework/engine/runtime/spec/transactional-runtime-store-v1.schema.json` | No machine contract validates store configuration/metadata. | Validate schema/migration identity, writer role, epoch/high-water, reserve, and projection policy. | Planned new runtime schema. |
| `.octon/framework/engine/runtime/spec/runtime-store-migration-receipt-v1.schema.json` | No typed import/cutover/parity receipt exists. | Validate source digests, row/semantic parity, epoch activation, and writer retirement. | Planned new evidence schema. |
| `.octon/framework/engine/runtime/spec/runtime-store-backup-receipt-v1.schema.json` | No typed backup/restore certification exists. | Validate DB/WAL consistency, integrity, schema, epoch/high-water, recovery objective, and activation disposition. | Planned new recovery schema. |
| `.octon/framework/engine/runtime/spec/runtime-store-projection-v1.schema.json` | Legacy files lack one store-backed projection envelope. | Validate source row/transaction, epoch/high-water, freshness, non-authority, and failure behavior. | Planned new projection schema. |
| `.octon/framework/constitution/contracts/runtime/family.yml` | Runtime contract catalog has no transactional-store family entries. | Register new schemas and supersession/projection relationships through the constitutional owner. | Contract catalog; not implementation authority by proposal. |
| `.octon/framework/constitution/contracts/runtime/transactional-runtime-store-v1.schema.json` | Constitutional mirror is absent. | Add the governed canonical schema mirror and parity validation. | Contract owner with RP-03 content. |
| `.octon/framework/constitution/contracts/runtime/runtime-store-migration-receipt-v1.schema.json` | Constitutional migration receipt is absent. | Add governed mirror for import/cutover proof. | Contract owner. |
| `.octon/framework/constitution/contracts/runtime/runtime-store-backup-receipt-v1.schema.json` | Constitutional backup receipt is absent. | Add governed mirror for recovery certification. | Contract owner. |
| `.octon/framework/constitution/contracts/runtime/runtime-store-projection-v1.schema.json` | Constitutional projection envelope is absent. | Add governed mirror that forbids projection authority/write-back. | Contract owner. |
| `.octon/framework/constitution/contracts/retention/family.yml` | Retention family does not reference transactional capacity/pointer substrate. | Register the narrow cross-contract binding without selecting RP-07 policy. | RP-03/RP-07 reviewed seam. |
| `.octon/framework/constitution/contracts/retention/evidence-store-v1.schema.json` | Evidence-store schema cannot validate transactional terminal reservation/pointers. | Add minimal capacity reservation and external payload-pointer bindings. | RP-03 substrate only. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-run-journal-append-boundary.sh` | Enforces runtime_bus file append dominance. | Enforce store mutation dominance and reject raw journal/file-authority writes after cutover. | Existing validator adapted by RP-03. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-run-journal-contracts.sh` | Validates current file-journal contracts. | Validate one canonical model and compatibility projection status. | Existing validator adapted by RP-03. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-state-surface-alignment.sh` | Checks file placement/alignment. | Compare store inventory to projected/control/evidence surfaces and fail dual authority. | Existing validator adapted by RP-03. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-transactional-runtime-store.sh` | No single-store proof validator exists. | Add deterministic schema, writer, migration, epoch, capacity, projection, backup, and evidence validation. | Planned new RP-03 validator. |
| `.octon/framework/assurance/runtime/_ops/tests/test-transactional-runtime-store.sh` | No complete race/fault/cutover driver exists. | Run N-way, kill-point, ENOSPC, corruption, migration, backup/restore, and no-resurrection suites. | Planned new RP-03 test driver. |
| `.octon/framework/assurance/runtime/_ops/fixtures/transactional-runtime-store/` | No bounded legacy/scratch/provider fault family exists. | Add malformed/conflicting imports, scratch external adapter, constrained volumes, corrupt DB/WAL, and race fixtures. | Planned new RP-03 fixtures; no production effects. |
| `.octon/state/evidence/validation/proposals/octon-architecture-migration-transactional-runtime-store/` | No RP-03 implementation evidence exists at packet creation. | Retain design/dependency, migration, epoch, writer, race, fault, capacity, recovery, rollback, conformance, and drift receipts. | Evidence-only; never live store or authority. |

## Affected but Excluded Surfaces

- The future database, WAL, shared-memory file, locks, backups, scratch imports,
  and monotonic host anchor are deployment state, not repository promotion
  targets or proposal evidence.
- Existing `.octon/state/control/**` and `.octon/state/evidence/**` data are
  import/projection/evidence inputs, never hand-edited implementation targets.
- RP-00's physical writer inventory is consumed, not co-owned.
- RP-04 broker process/IPC/credentials, RP-07 signed retention, and RP-08
  provider classification/reconciliation are affected consumers but excluded.

## Collision Rule

If review cannot allocate exact non-overlapping symbols in authority_engine,
runtime contracts, retention contracts, or validators, implementation stops
and the packet is revised. A shared file path does not permit RP-03 to change
frozen RP-01 semantics or future RP-07/RP-08 policy.
