# Touched Paths Analysis

You are given `touched_paths` plus optional `validation_depth`,
`strictness`, and `explanation_mode`.

## Required Work

1. Normalize `touched_paths` into a deduplicated repo-relative list.
2. Classify each path using live repo surfaces, including:
   - extension-pack roots
   - authoritative-doc trigger surfaces
   - proposal workspace paths
   - repo-hygiene and retirement surfaces
   - broad multi-subsystem harness surfaces
3. Build `impact_map` with direct surfaces, adjacent surfaces,
   declared-but-unobserved surfaces, and non-impacts.
4. Apply `context/selection-rules.md` to choose the minimum credible
   validation floor from existing validators and workflows only.
5. Use `context/reuse-map.md` to route the operator or agent to one next
   canonical action.

## Failure Rule

If the touched paths do not map to any published validation rule, return the
shared output contract with `impact_map.status: needs-clarification` or
`blocked`, leave `selected[]` empty, and explain the missing fact.
