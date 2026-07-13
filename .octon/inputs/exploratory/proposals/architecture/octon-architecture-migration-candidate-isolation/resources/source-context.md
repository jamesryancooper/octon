# Source Context

## Bounded Source Set

This packet uses only the current repository, the specified architecture and
migration intake, the specified completed reconciliation, the named Revision 2
proposal for predecessor lineage, and the program-creation prompt. Unrelated
review directories are excluded.

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
RP-02 uses its isolation, credential, Git-boundary, proof, and operability
inputs only through reconciled corrections. Where intake and reconciliation
differ, the reconciliation decision register controls planning.

## Current Repository Evidence

Current implementation and contract surfaces inspected include:

- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/{lib.rs,adapter.rs,auto.rs,codex.rs,claude.rs,request.rs}`;
- `.octon/framework/engine/runtime/crates/lifecycle_executor/tests/adapter.rs`;
- `.octon/framework/engine/runtime/spec/task-specific-execution-harness-v1.{md,schema.json}`;
- `.octon/framework/constitution/contracts/runtime/task-specific-execution-harness-v1.schema.json`;
- `.octon/framework/constitution/contracts/adapters/host-adapter-v1.schema.json`;
- `.octon/framework/engine/runtime/adapters/{host,model}/`;
- `.octon/framework/engine/runtime/spec/authorization-boundary-coverage.yml`; and
- `.octon/framework/engine/runtime/spec/material-side-effect-inventory.yml`.

At creation commit `d78ee8b42cb3a39557bbe39b66cb5d156946172a`,
the lifecycle executor launches Codex with the canonical repository as both
`--cd` and process current directory, can add repository-local `.codex` state,
and does not provide the proposed independent-repository/native-policy/session
boundary. Existing process-group cancellation is useful retained groundwork,
not proof of FD-008.

The fixed reconciliation baseline is
`c5b1f5760c78ff521cca6b054e4e8fef5300505b`. Implementation must refresh all
source and provider assumptions against its exact clean baseline.

## Predecessor Lineage

`octon-trustworthy-autonomy-solo-developer-revision-2` is retained unchanged as
predecessor lineage. It is not a child of this program, does not authorize this
packet, and is not edited or superseded by packet creation.
