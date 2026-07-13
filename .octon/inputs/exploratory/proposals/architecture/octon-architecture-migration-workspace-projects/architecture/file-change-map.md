# File Change Map

Every path below is an Octon-internal target. Ownership is limited to the
declared RP-10 contract, symbol, or registry entry; shared files are not claimed
wholesale.

| Target | Current assumption | Required change | RP-10 ownership | Priority |
| --- | --- | --- | --- | --- |
| `.octon/framework/engine/runtime/spec/workspace-project-v1.schema.json` | Absent | Add strict runtime schema for registry, active pointers, immutable revisions, boundaries, relations, corrections, and Profile binding. | Whole new contract | P0 |
| `.octon/framework/constitution/contracts/runtime/workspace-project-v1.schema.json` | Absent | Add constitutional mirror to the runtime schema. | Whole new mirror | P0 |
| `.octon/framework/engine/runtime/spec/project-profile-v1.schema.json` | Existing runtime Profile schema | Add explicit Workspace Project binding/projection semantics without treating all Profile facts as execution input. | Declared binding fields only | P0 |
| `.octon/framework/constitution/contracts/runtime/project-profile-v1.schema.json` | Existing permissive constitutional Profile schema | Align the binding and non-authority contract while preserving evidence-backed descriptive facts. | Declared binding fields only | P0 |
| `.octon/framework/constitution/contracts/runtime/family.yml` | Registers Project Profile, not Workspace Project | Register the new schema, instance root, and evidence/continuity roles. | Workspace Project entry only | P0 |
| `.octon/framework/constitution/contracts/registry.yml` | Registers current Project Profile integration | Add Workspace Project integration refs and non-authority boundaries. | Workspace Project entries only | P1 |
| `.octon/framework/cognition/_meta/architecture/contract-registry.yml` | Maps current locality/Profile surfaces | Add authored, state, and generated path roles for Workspace Projects and inbox/location read models. | Workspace Project entries only | P1 |
| `.octon/instance/locality/projects/` | Absent | Add registry plus path-safe project active pointers and immutable revisions. | Whole new namespace | P0 |
| `.octon/instance/locality/project-profile.yml` | Singleton active Profile | Preserve as first selected Profile/compatibility projection during migration. | Migration semantics only | P0 |
| `.octon/instance/governance/engagements/path-families.yml` | Contains Project Profile authority/evidence families | Add exact Workspace Project authored/evidence/continuity families. | New path-family entries only | P1 |
| `.octon/framework/engine/runtime/crates/kernel/src/commands/engagement.rs` | Writes/reads the singleton Profile | Resolve/adopt a project, preserve correction precedence, and emit exact binding refs/digests. | Project-resolution symbols only | P0 |
| `.octon/framework/engine/runtime/crates/kernel/src/commands/mission.rs` | Supports per-mission status/resume and continuity | Tag continuity with project identity and implement read-only cross-project inbox assembly. | Inbox/project-tag symbols only | P1 |
| `.octon/framework/engine/runtime/crates/kernel/src/main.rs` | Exposes mission commands but no inbox | Register the read-only inbox CLI surface. | Inbox command declaration only | P1 |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-engagement-change-package-compiler.sh` | Validates singleton Project Profile flow | Validate strict project/Profile binding, path families, and source-fact roles. | RP-10 assertions only | P0 |
| `.octon/framework/assurance/runtime/_ops/tests/test-engagement-change-package-compiler.sh` | Covers current engagement/Profile compiler | Add two-project, correction, relocation, snapshot, and negative fixtures. | RP-10 fixtures only | P0 |
| `.octon/state/evidence/validation/proposals/octon-architecture-migration-workspace-projects/` | Absent | Retain exact-commit validation, migration, negative, and acceptance evidence. | RP-10 evidence bundle | P0 |

## Affected Outputs, Not Promotion Targets

- `.octon/state/evidence/project-profiles/**`
- `.octon/state/continuity/repo/missions/**`
- project location continuity/read-model state
- generated mission/project views
- `.octon/generated/proposals/registry.yml`

These are written or regenerated only through their canonical owners. The
proposal-registry projection is outside this child authoring write scope.

## Shared-File Integration Rule

The trusted integration lane serializes shared registry and kernel edits.
Other packets may own different entries or symbols in the same physical file;
that does not give RP-10 semantic ownership of those areas.
