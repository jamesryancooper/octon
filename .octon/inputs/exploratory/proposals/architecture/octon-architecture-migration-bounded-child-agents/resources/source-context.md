# Source Context

## Fixed Reconciliation

- reconciliation ID:
  `architecture-migration-reconciliation-20260712T032411Z-10c3ff`
- baseline commit: `c5b1f5760c78ff521cca6b054e4e8fef5300505b`
- packet map: `reconciliation/reconciled-proposal-packet-map.yml`
- workgroup roadmap: `reconciliation/reconciled-workgroup-roadmap.yml`
- migration architecture: `reconciliation/reconciled-migration-architecture.md`
- decision register: `reconciliation/reconciled-decision-register.yml`
- finding register: `reconciliation/reconciled-finding-register.yml`
- proof register: `reconciliation/proof-obligations.yml`
- unresolved evidence: `reconciliation/unresolved-evidence.yml`
- decision/configuration lineage:
  `reconciliation/remaining-operator-decisions.yml`
- safe states: `reconciliation/safe-intermediate-states.md`

All paths above are relative to the fixed reconciliation directory named by
the parent program prompt.

## Intake Inputs Used

- `target-state/extensions-multi-agent-and-provider-boundaries.md`
- `target-state/workspace-projects-and-harness-factory.md`
- `target-state/isolation-publication-and-verification.md`
- `target-state/broker-transaction-and-recovery.md`
- `target-state/threat-model-and-support-envelope.md`
- `product/product-experience.md`
- `product/friction-and-operational-standards.md`
- `validation/acceptance-matrix.yml`
- `validation/adversarial-and-fault-injection-plan.md`
- `validation/host-provider-and-effect-conformance.md`

These paths are relative to the fixed incoming intake directory. They are
planning context, not authority.

## Current Repository Evidence

- kernel `lifecycle_program.rs` contains proposal-program child dependency
  scheduling, bounded concurrency, locks, retries/recovery, cancellation,
  terminal observation, and evidence machinery;
- lifecycle executor requests carry optional child identity/cancellation, while
  the primary provider path implements timeouts and process-group termination;
- token-budget code records child/stage/source/model estimates and provider
  usage when available, but the contract explicitly says the ledger is not an
  authorization or hard budget;
- Agent Node and Harness contracts strongly deny scheduling/authority ownership
  and bind model activity to governed runs;
- existing `ProgramChild` records are durable proposal/program work items and
  are not temporary mission child identities; and
- no complete MissionChildRun contract, strict parent/mission/project/Harness
  scope intersection, depth-one enforcement, credentialless provider-child
  mapping, hard-limit admission, or irreversible retirement proof exists.

## Baseline Drift

Current HEAD is later than the reconciliation baseline through publication of
the fixed reviews/reconciliation, proposal lifecycle tooling, program prompt,
closeout evidence, and sibling packet authoring. No accepted durable change has
closed FD-022 or UE-013, so RP-13's boundary remains valid.

## Predecessor Lineage

The named Revision 2 proposal contains earlier multi-agent design detail and
remains unchanged predecessor lineage. This packet adopts only details
consistent with the controlling reconciliation, current scheduler primitives,
RP-08/RP-11 ownership, the accepted ROD-005 baseline, and ED-001 as a dependency
premise rather than an RP-13 implementation choice.
