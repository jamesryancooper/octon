# Artifact Catalog

## Manifests and Navigation

- `proposal.yml` — canonical proposal identity, lifecycle, dependency, and promotion targets.
- `architecture-proposal.yml` — architecture subtype manifest.
- `README.md` — operator entry point and packet posture.
- `navigation/source-of-truth-map.md` — precedence, authority, and source ownership.
- `navigation/artifact-catalog.md` — complete packet inventory.

## Architecture

- `architecture/current-state-gap-map.md` — file-state, journal, writer, and recovery gaps.
- `architecture/target-architecture.md` — SI-03 store, transaction, writer, and projection design.
- `architecture/acceptance-criteria.md` — future implementation and proof gates.
- `architecture/implementation-plan.md` — staged design, dependency, migration, and proof work.
- `architecture/validation-plan.md` — concurrency, crash, storage, migration, and recovery matrices.
- `architecture/file-change-map.md` — planned durable targets and ownership.
- `architecture/cutover-plan.md` — quiescence, import, epoch activation, and handoff.
- `architecture/rollback-and-recovery.md` — pre-effect and post-effect recovery rules.
- `architecture/operator-disclosure.md` — solo-builder experience and unsupported remainder.

## Resources

- `resources/source-context.md` — bounded repository, intake, reconciliation, and predecessor lineage.
- `resources/packet-contract.yml` — machine-readable RP-03 contract.
- `resources/traceability.yml` — decision, finding, proof, evidence, and operator-decision map.
- `resources/sqlite-design-and-dependency-receipt.yml` — selected SQLite dependency, physical design, reversible ROD-001 defaults, and evidence order.
- `resources/writer-state-census.yml` — immutable-baseline consequential writer/state inventory and cutover disposition.

## Support Receipts

- `support/profile-selection-receipt.md` — atomic/pre-1.0 profile rationale.
- `support/proposal-creation.md` — canonical direct-template fallback creation receipt.
- `support/proposal-review.md` — digest-bound independent proposal review.
- `support/pre-integration-architecture-review.yml` — subtype architecture review receipt.
- `support/revisions/rp03-store-census-evidence-cycle-20260718.md` — correction receipt for the initial review findings.
- `support/implementation-grade-completeness-review.md` — truthful draft readiness gate.
- `support/implementation-conformance-review.md` — future implementation conformance gate.
- `support/post-implementation-drift-churn-review.md` — future closeout drift gate.
