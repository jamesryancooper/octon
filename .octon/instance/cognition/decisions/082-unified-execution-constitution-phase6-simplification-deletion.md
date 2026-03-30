# ADR 082: Unified Execution Constitution Phase 6 Simplification And Deletion

- Date: 2026-03-29
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/instance/cognition/context/shared/migrations/2026-03-29-unified-execution-constitution-phase6-simplification-deletion/plan.md`
  - `/.octon/state/evidence/migration/2026-03-29-unified-execution-constitution-phase6-simplification-deletion/`
  - `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/`

## Context

After Phase 5, the support matrix and adapter contracts were real, but the repo
still carried the Phase 6 gaps the packet and audit called out:

- the agency path still layered governance shims ahead of the orchestrator
  contract
- `SOUL.md` overlays still existed in active and scaffolded runtime agent paths
- live GitHub workflows still projected autonomy and AI-gate lane labels
- the agency constitutional shim still read more active than historical

That meant the architecture was more correct than before, but not yet as
simple, deletive, and orchestrator-centered as the target state demanded.

## Decision

Execute Phase 6 as an atomic simplification and deletion pass.

Rules:

1. `runtime/agents/orchestrator/AGENT.md` is the kernel execution profile
   beneath the constitutional kernel and ingress.
2. `SOUL.md` overlays are removed from active and scaffolded runtime agent
   paths.
3. Agency `CONSTITUTION.md` becomes a historical shim outside the required
   path.
4. Autonomy-lane and AI-gate labels are deleted from live GitHub control-plane
   flows.
5. Validators and CI must assert the simplified path directly.

## Consequences

### Benefits

- The live interpretive stack is simpler and easier to reason about.
- The orchestrator path is unmistakably the kernel execution profile.
- GitHub checks and canonical artifacts, not labels, now carry the merge/gate
  posture.

### Costs

- Older docs and scripts that assumed autonomy lane labels or scaffolded
  `SOUL.md` needed coordinated cleanup.
- Historical shims remain in the repo, but only as lineage surfaces.

## Completion

This decision is complete once:

- orchestrator is the kernel execution profile
- persona-heavy surfaces are optional overlays only and not scaffolded or
  active in the required path
- at least one host-shaped authority path is deleted
