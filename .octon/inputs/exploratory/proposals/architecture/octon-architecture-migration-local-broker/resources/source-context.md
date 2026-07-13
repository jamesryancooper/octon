# Source Context

## Bounded Source Set

This packet uses only the current repository, the specified architecture and
migration intake, the specified completed reconciliation, the named Revision 2
proposal for predecessor lineage, and the program-creation prompt. Unrelated
review directories are excluded and not used as planning authority.

## Controlling Non-Authoritative Planning Input

- reconciliation id:
  `architecture-migration-reconciliation-20260712T032411Z-10c3ff`
- reconciled packet map:
  `.octon/inputs/exploratory/reviews/architecture-migration/reconciliations/architecture-migration-reconciliation-20260712T032411Z-10c3ff/reconciliation/reconciled-proposal-packet-map.yml`
- decision register: `reconciliation/reconciled-decision-register.yml`
- finding register: `reconciliation/reconciled-finding-register.yml`
- proof obligations: `reconciliation/proof-obligations.yml`
- engineering dispositions: `reconciliation/remaining-operator-decisions.yml`
- unresolved evidence: `reconciliation/unresolved-evidence.yml`
- workgroup roadmap: `reconciliation/reconciled-workgroup-roadmap.yml`
- safe states: `reconciliation/safe-intermediate-states.md`
- migration architecture: `reconciliation/reconciled-migration-architecture.md`

Relative paths above resolve beneath the fixed reconciliation directory. These
artifacts guide authoring but do not authorize implementation.

## Intake Lineage

The intake root is
`.octon/inputs/additive/.incoming/octon-architecture-and-migration-handoff-v2.0.0/`.
RP-04 uses its broker transaction/recovery, credential, authority/effect,
degraded-operation, migration, validation, and solo-experience inputs only
through reconciled corrections. Where intake and reconciliation differ, the
reconciliation decision register controls planning.

## Current Repository Evidence

Current implementation and contract surfaces inspected include:

- `.octon/framework/capabilities/_ops/scripts/policy-grant-broker.sh` and its
  overview, solely to classify and reject it as the RP-04 implementation;
- `.octon/framework/engine/runtime/crates/{authorized_effects,authority_engine,runtime_bus,kernel}/`;
- `.octon/framework/engine/runtime/crates/kernel/src/{main.rs,commands/mod.rs}`;
- `.octon/framework/engine/runtime/{config,adapters/host,spec}/`;
- `.octon/framework/constitution/contracts/{runtime,adapters}/`;
- `.octon/instance/governance/policies/mission-autonomy.yml`; and
- material-effect, authorization-boundary, token-enforcement, execution-
  governance, service, host-adapter, and runtime validation surfaces.

At creation commit `d78ee8b42cb3a39557bbe39b66cb5d156946172a`,
the runtime workspace has no local_broker crate or reviewed macOS IPC/Keychain
dependency. No broker-specific launch-service config, authenticated endpoint,
Keychain custody, sole store writer, restart scan, or lifecycle CLI exists.
`policy-grant-broker.sh` writes ephemeral JSON grants and is not the accepted
broker boundary.

The fixed reconciliation baseline is
`c5b1f5760c78ff521cca6b054e4e8fef5300505b`. Implementation must refresh the
writer/credential/effect/launcher inventory, exact macOS/dependency/signing
tuple, store epoch, and dependency-child evidence at its clean baseline.

## Predecessor Lineage

`octon-trustworthy-autonomy-solo-developer-revision-2` is retained unchanged as
predecessor lineage. It is not a child of this program, does not authorize this
packet, and is not edited or superseded by packet creation.
