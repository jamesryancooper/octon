# Affected Artifact Map

map_id: run-program-clean-delivery-operator-surface-affected-artifacts-20260629T145230Z
proposal_path: .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-operator-surface
verdict: pass

## Promotion Targets

- `.octon/framework/capabilities/runtime/commands/proposal-program-delivery.md`
  - role: canonical operator command surface
  - rollback: remove command documentation with the paired delivery skill and
    feature note if the surface is rejected
- `.octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery/SKILL.md`
  - role: operations skill that delegates to the canonical Proposal Program
    Delivery workflow
  - rollback: remove the skill with the command surface if rejected
- `.octon/framework/product/features/catalog.yml`
  - role: product feature catalog entry for governed proposal delivery
  - rollback: remove the feature entry if the operator surface is rejected
- `.octon/framework/product/features/README.md`
  - role: feature index reference
  - rollback: remove the feature note reference if rejected
- `.octon/framework/product/features/governed-proposal-delivery.md`
  - role: product feature note and authority boundary documentation
  - rollback: remove the feature note if rejected
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/commands/octon-proposal-run-program-lifecycle.md`
  - role: lifecycle-runner operator handoff wording for
    `target_outcome=cleaned`
  - rollback: remove the clean-delivery handoff wording if rejected
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/commands/manifest.fragment.yml`
  - role: command argument hint for `target_outcome=cleaned`
  - rollback: remove the argument hint if rejected
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/octon-proposal-lifecycle-run-program-lifecycle/SKILL.md`
  - role: lifecycle-runner skill boundary for clean-delivery continuation
  - rollback: remove the clean-delivery handoff wording if rejected
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/registry.fragment.yml`
  - role: skill registry argument surface for `target_outcome`
  - rollback: remove the argument surface if rejected

## Boundary Coverage

- The packet promotes operator-surface and documentation artifacts only.
- The canonical operator command is `/proposal-program-delivery`; no duplicate
  `/run-program-to-clean-delivery` command is introduced.
- `target_outcome=cleaned` is a delivery handoff request and never terminal
  proof.
- Generated outputs remain derived-only and are not hand edited by this packet.
- Runtime delivery, child packet implementation, archive, cleanup, branch
  cleanup, Git mutation, final sync, terminal proof, and `cleaned` claims stay
  owned by their governing routes and validators.

## Downstream Validators

- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-workflow.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh`
