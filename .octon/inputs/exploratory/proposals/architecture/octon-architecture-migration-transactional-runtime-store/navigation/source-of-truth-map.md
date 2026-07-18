# Proposal Reading and Precedence Map

## Authority Boundary

Current constitutional, product, runtime, and instance governance outrank this
packet. The intake, reconciliation, parent program, Revision 2 proposal, this
packet, migration scratch state, database backups, generated projections, and
retained evidence are non-authoritative until the accepted implementation
activates the governed store epoch through durable sources.

## Proposal-Local Precedence

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `resources/packet-contract.yml`
4. `resources/sqlite-design-and-dependency-receipt.yml`
5. `resources/writer-state-census.yml`
6. `architecture/target-architecture.md`
7. `architecture/acceptance-criteria.md`
8. `architecture/implementation-plan.md`
9. supporting architecture and resource documents
10. `navigation/artifact-catalog.md`
11. `.octon/generated/proposals/registry.yml`
12. `README.md`

## Durable Ownership Split

| Concern | Planned owner | Boundary |
| --- | --- | --- |
| Authority evaluation, grant/revocation meaning, exact guard semantics, and launch API | RP-01 | RP-03 consumes the frozen versioned semantics and cannot reinterpret them through storage behavior. |
| SQLite schema/migrations, T1/T2 substrate, authority epoch, legacy import, projection, backup/restore, and corruption policy | RP-03 / `runtime_bus` | One canonical code-level mutation API; no provider-specific outcome classification. |
| Read-only replay, reconstruction, export, and projection parity | RP-03 / `replay_store` | It receives snapshots or a read-only connection and cannot advance authority or repair the store. |
| Deployed write connection, credential custody, broker supervision, and store status/doctor/repair UX | RP-04 | The broker consumes RP-03's store API and is the sole normal deployed writer identity. |
| Provider-specific result classification, reconciliation-before-retry, and manual-intervention policy | RP-08 | RP-03 persists generic states and observations but does not decide provider outcome truth. |
| Signed evidence identity, external monotonic checkpoint strengthening, quotas, pins, and compaction | RP-07 | RP-03 supplies capacity and pointer substrate only. |

## State and Projection Rules

- The activated SQLite/WAL store is the only live runtime authority source.
- Legacy YAML/JSON/NDJSON files are import inputs before cutover and read-only
  projections, exports, or bounded payload pointers afterward.
- A database backup is recovery material, not live authority until certified
  against the candidate-inaccessible epoch/high-water record and activated
  through the recovery procedure.
- Retained evidence proves migration and behavior but cannot advance store
  state or authorize an effect.
- `.octon/generated/proposals/registry.yml` remains discovery-only and changes
  only through its canonical owning generator.

## Conflict and Failure Rules

- If RP-01 semantics are not frozen, RP-03 implementation does not start.
- ROD-001 is operator-accepted; if its invariants are not bound or the
  engineering store/backup/reserve defaults are not recorded and proved, the
  physical design does not pass completeness review.
- If any non-migration process can write both store and legacy authority files,
  cutover fails.
- If the store, WAL, schema, epoch, high-water, or capacity reserve is
  uncertain, consequential effects stop; file authority is never restored.
- If an external outcome is uncertain, RP-03 records `UNKNOWN`; it never
  chooses a provider-specific retry or terminal classification.
