# Source Context

## Bound Planning Sources

- creation prompt:
  .octon/framework/scaffolding/practices/prompts/create-octon-architecture-migration-proposal-program.md
- intake:
  .octon/inputs/additive/.incoming/octon-architecture-and-migration-handoff-v2.0.0/
- reconciliation:
  .octon/inputs/exploratory/reviews/architecture-migration/reconciliations/architecture-migration-reconciliation-20260712T032411Z-10c3ff/
- packet map:
  reconciliation/reconciled-proposal-packet-map.yml
- decisions:
  reconciliation/reconciled-decision-register.yml
- findings:
  reconciliation/reconciled-finding-register.yml
- proofs:
  reconciliation/proof-obligations.yml
- unresolved evidence:
  reconciliation/unresolved-evidence.yml
- operator and engineering dispositions:
  reconciliation/remaining-operator-decisions.yml
- safe states:
  reconciliation/safe-intermediate-states.md

All are non-authoritative planning inputs. The reconciled decision register is
the controlling planning baseline.

## Current Repository Evidence

- .octon/framework/execution-roles/_ops/scripts/git/git-branch-land-hosted-no-pr.sh
- .octon/framework/execution-roles/_ops/scripts/git/git-branch-hosted-preflight.sh
- .octon/framework/execution-roles/_ops/scripts/git/git-branch-authorize-hosted-no-pr.sh
- .octon/framework/execution-roles/practices/git-github-autonomy-workflow-v1.md
- .octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml
- .octon/framework/product/contracts/default-work-unit.yml
- .octon/framework/engine/runtime/crates/authorized_effects/src/lib.rs
- .octon/framework/engine/runtime/crates/kernel/src/commands/mod.rs
- .octon/framework/engine/runtime/crates/kernel/src/side_effects/mod.rs
- .octon/framework/engine/runtime/spec/material-side-effect-inventory.yml
- .octon/framework/engine/runtime/spec/authorization-boundary-coverage.yml
- .octon/framework/engine/runtime/adapters/host/github-control-plane.yml

## Baseline

- reconciliation baseline:
  c5b1f5760c78ff521cca6b054e4e8fef5300505b
- creation HEAD:
  d78ee8b42cb3a39557bbe39b66cb5d156946172a
- relevant-source drift:
  none across engine runtime, execution roles, product contracts,
  constitutional contracts, assurance runtime, orchestration runtime,
  instance governance, and GitHub workflows

## Predecessor Lineage

octon-trustworthy-autonomy-solo-developer-revision-2 was inspected only as
predecessor lineage. Its earlier effect-broker implementation-unit concept is
consistent with the reconciled one-broker boundary, but this packet adopts the
smaller reconciled RP-05 scope and does not inherit predecessor lifecycle
status or authority.

## Source Isolation

No unrelated review directory, external source, live provider mutation, or
unlisted proposal was used. Current provider behavior remains an unresolved
dynamic proof item under UE-005.
