# Source Context

## Fixed Reconciliation

- reconciliation ID:
  `architecture-migration-reconciliation-20260712T032411Z-10c3ff`
- baseline commit: `c5b1f5760c78ff521cca6b054e4e8fef5300505b`
- packet map: `reconciliation/reconciled-proposal-packet-map.yml`
- workgroup roadmap: `reconciliation/reconciled-workgroup-roadmap.yml`
- decision register: `reconciliation/reconciled-decision-register.yml`
- finding register: `reconciliation/reconciled-finding-register.yml`
- proof register: `reconciliation/proof-obligations.yml`
- unresolved evidence: `reconciliation/unresolved-evidence.yml`
- operator and engineering dispositions:
  `reconciliation/remaining-operator-decisions.yml`
- safe states: `reconciliation/safe-intermediate-states.md`

All paths above are relative to the fixed reconciliation directory named by
the parent program prompt.

## Intake Inputs Used

- `target-state/workspace-projects-and-harness-factory.md`
- `product/product-experience.md`
- `product/friction-and-operational-standards.md`
- `validation/usability-friction-and-dogfood-plan.md`
- `validation/acceptance-matrix.yml`

These inputs are planning context, not authority.

## Current Repository Evidence

- runtime and constitutional task-specific Harness and compile-receipt
  contracts already exist;
- runtime route bundles, resolver handles, context packs, input binding,
  lifecycle requests/results, and observation code are reusable primitives;
- `lifecycle_executor/src/adapter.rs` defines `LifecycleRouteExecutor`, but
  dispatch still matches `request.executor` against `mock`, `codex`, `claude`,
  and `auto` branches;
- adapter schemas and live model/host manifests exist, while the reconciliation
  records strict live-schema drift and lack of runtime adapter-identity
  consumption;
- current Harness/route compilation does not enumerate and bind the complete
  approved project, mission, run, policy, extension, context, model, tool,
  validation, evidence, and rollback envelope; and
- no retained UE-010 or UE-011 dynamic proof exists.

## Baseline Drift

Current HEAD is later than the reconciliation baseline through publication of
the named reviews/reconciliation, proposal lifecycle tooling, this program
prompt, closeout evidence, and sibling packet authoring. No accepted durable
implementation has closed FD-020 or the RP-11 component portion of FD-023, so
the RP-11 boundary does not require reopening.

## Predecessor Lineage

The named Revision 2 proposal contains earlier Harness Factory and adapter
design detail. It remains unchanged predecessor lineage. This packet adopts
only details consistent with the controlling reconciliation, current code,
and explicit RP-06/RP-08/RP-13/RP-14 ownership split.
