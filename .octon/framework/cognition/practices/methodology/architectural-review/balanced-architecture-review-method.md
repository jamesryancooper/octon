# Balanced Architecture Review Method

The Balanced Architecture Review Method is Octon's native method for assessing
architecture change. It starts from first principles, restores current-system
context, then compares clean-sheet and realistic target designs without
discarding existing constraints prematurely.

## Required Sequence

1. Frame the review charter: decision, scope, stakeholders, risk tolerance,
   time horizon, non-goals, and required outcome.
2. Identify the fundamental job of the reviewed system before selecting an
   implementation shape.
3. Map current reality across architecture, runtime behavior, state ownership,
   workflows, validators, generated projections, evidence roots, and recovery.
4. Steelman the current design before proposing changes.
5. Apply Chesterton's Fence to decide what should be preserved, moved, merged,
   renamed, split, retired, or left alone.
6. Separate essential complexity from accidental, compensating, operational,
   integration, and migration complexity.
7. Identify stale constraints, valid constraints, hidden contracts,
   bottlenecks, and leverage points.
8. Build a clean-sheet reference design as a comparison tool.
9. Compare current state against the clean-sheet reference.
10. Produce a realistic target architecture that fits Octon's governance model.
11. Define routing, authority boundaries, evidence requirements, validators,
    rollback posture, and revisit triggers.

## Octon Fit Gates

- Authority gate: durable meaning belongs in authored `framework/**` or
  `instance/**` surfaces, or in extension source only when extension ownership
  is explicit.
- Input gate: raw inputs, proposal analysis, chat, host state, model memory,
  dashboards, and generated views are not authority.
- Evidence gate: lifecycle-impacting conclusions require retained evidence.
- Validator gate: durable changes require validators, tests, fixtures, or an
  explicit blocker with ownership.
- Publication gate: generated outputs are refreshed by canonical scripts only.
- Kernel gate: constitutional conflicts route to Constitutional Challenge.

## Output Contract

Every native architectural review should produce:

- review charter;
- system job and current reality map;
- steelman and Chesterton's Fence analysis;
- constraint and complexity ledgers;
- bottleneck and leverage analysis;
- failure-mode and second-order-effect analysis;
- clean-sheet reference design;
- option comparison and recommendation;
- authority, evidence, validation, publication, and rollback plan;
- final verdict and unresolved blocker count.
