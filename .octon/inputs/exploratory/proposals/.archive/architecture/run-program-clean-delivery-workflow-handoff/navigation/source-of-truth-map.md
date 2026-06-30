# Source Of Truth Map

## Proposal-Local Lifecycle Sources

1. `proposal.yml`
2. `architecture-proposal.yml`

These files are the only proposal-local lifecycle sources. The packet remains
temporary and non-authoritative at every lifecycle state.

## Proposal-Local Working Material

- `architecture/target-architecture.md`: intended handoff end state and
  affected artifact map.
- `architecture/implementation-plan.md`: implementable workstreams, rollback,
  and closeout expectations.
- `architecture/acceptance-criteria.md`: acceptance and future closeout
  conditions.
- `validation-plan.md`: packet revision validators and future implementation
  validation expectations.
- `support/implementation-grade-completeness-review.md`: packet-local
  implementation-grade completeness receipt.
- `support/pre-integration-architecture-review.yml`: strict architecture review
  receipt for the current packet digest.
- `support/proposal-review.md`: source review receipt that routed this packet
  to revision.
- `support/revisions/revision-20260629T125000Z.md`: revision receipt for this
  revise-packet route.

## Durable Authorities And Target Owners

- `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/`
  owns the aggregate delivery workflow and delivery receipt shape.
- `.octon/framework/capabilities/runtime/commands/proposal-program-delivery.md`
  owns the operator command surface.
- `.octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery/SKILL.md`
  owns model-executor delivery behavior.
- `.octon/framework/product/contracts/default-work-unit.yml` owns default Change
  route policy, target lifecycle defaults, and evidence boundary rules.
- `.octon/framework/product/contracts/change-closeout-state-machine.yml` owns
  closeout phase semantics, route selection, target outcome, actual outcome,
  cleanup, rollback, final sync, and terminal proof boundaries.
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md`
  owns singular Change closeout mutation and receipt behavior.
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/SKILL.md`
  owns dirty-worktree partitioning and wrapper handoff behavior.
- Proposal packet closeout, archive lifecycle, generated publishers,
  repo-hygiene-cleanup, branch landing helpers, branch cleanup helpers, and
  terminal proof validators own their respective effects.

## Derived Projections

- `.octon/generated/proposals/registry.yml` is a discovery projection only.
- Generated effective extension, capability, proposal, and runtime outputs are
  derived-only and must be regenerated through owning publishers when future
  implementation changes require them.
- Compact delivery evidence indexes and readiness projections are retained
  evidence aids, not authority.

## Retained Evidence Surfaces

- `.octon/state/evidence/runs/**` for workflow and skill run evidence.
- `.octon/state/evidence/validation/**` for validator, publication, and
  analysis receipts.
- `.octon/state/evidence/runs/skills/**` for closeout and cleanup receipts
  when those routes own effects.
- `.octon/state/evidence/local/**` for ignored local/private terminal evidence
  only when digest-backed and explicitly classified as retained-evidence-only.

## Boundary Rules

- This proposal does not authorize implementation, promotion, archive,
  generated publication, cleanup, branch mutation, Git mutation, terminal proof,
  or `cleaned` claims.
- Parent summaries, delivery receipts, readiness projections, generated
  outputs, host state, chat, and model memory cannot satisfy child-owned or
  Change-owned receipts.
- Delivery may report the highest evidence-backed outcome only after owning
  receipts are current. Missing or stale owning evidence downgrades the outcome
  and names the next route.
