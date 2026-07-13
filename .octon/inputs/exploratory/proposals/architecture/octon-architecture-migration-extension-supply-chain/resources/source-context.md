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
- decision/configuration lineage: `reconciliation/remaining-operator-decisions.yml`
- safe states: `reconciliation/safe-intermediate-states.md`

All paths above are relative to the fixed reconciliation directory named by
the parent program prompt.

## Intake Inputs Used

- `target-state/extensions-multi-agent-and-provider-boundaries.md`
- `target-state/target-architecture.md`
- `target-state/threat-model-and-support-envelope.md`
- `migration/preserve-modify-add-retire.md`
- `product/product-experience.md`
- `product/friction-and-operational-standards.md`
- `validation/acceptance-matrix.yml`
- `validation/adversarial-and-fault-injection-plan.md`

These paths are relative to the fixed incoming intake directory. They are
planning context, not authority.

## Current Repository Evidence

- extension governance already separates normalized raw packs, desired
  `instance/extensions.yml`, actual active/quarantine control state, and
  generated runtime-facing projections;
- the current pack schema carries provenance source, origin, digest, and
  attestation fields, but no mandatory canonical signed private-release
  envelope or verified signer relationship;
- the current desired schema supports source catalog, trust defaults/overrides,
  acknowledgements, and optional version pins;
- the publisher already validates schemas/compatibility/dependencies,
  quarantines invalid packs, emits compatibility/publication receipts, and
  atomically writes active/quarantine and generated catalog/artifact/lock
  surfaces;
- runtime resolver handles already cross-check generated extension catalog and
  generation lock with active state and desired config; and
- there is no complete one-command signed private import, verified availability
  state, signer revocation propagation, or current-rule prior-generation
  restore proof.

## Baseline Drift

Current HEAD is later than the reconciliation baseline through publication of
the named reviews/reconciliation, proposal lifecycle tooling, program prompt,
closeout evidence, and sibling packet authoring. No accepted durable change has
closed FD-021 or UE-012, so RP-12's boundary remains valid.

## Predecessor Lineage

The named Revision 2 proposal contains earlier extension design detail and
remains unchanged predecessor lineage. This packet adopts only details
consistent with the controlling reconciliation, current source/actual/generated
ownership, RP-07/RP-11 interfaces, and the accepted ROD-004 baseline.
