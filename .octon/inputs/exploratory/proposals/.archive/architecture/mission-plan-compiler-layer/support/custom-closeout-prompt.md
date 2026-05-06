# Custom Closeout Prompt

Run implemented closeout for the proposal packet at:

`.octon/inputs/exploratory/proposals/architecture/mission-plan-compiler-layer/`

## Required Closeout

1. Verify the implementation-grade, conformance, and drift/churn receipts pass
   with zero unresolved items.
2. Verify the second independent verification pass was clean or preserve any
   remaining finding as an explicit blocker.
3. Archive the implemented packet under
   `.octon/inputs/exploratory/proposals/.archive/architecture/mission-plan-compiler-layer/`
   with implemented disposition, original path, promotion evidence, and retained
   closeout evidence.
4. Regenerate `.octon/generated/proposals/registry.yml`.
5. Refresh packet checksums if packet files or their paths change.
6. Run the proposal, architecture, implementation-readiness, conformance,
   drift/churn, mission-plan compiler, runtime-docs, registry, checksum, and
   whitespace validation floor.
7. Classify broad repository-health checks separately when failures are outside
   this packet's promotion targets.
8. Preserve unrelated worktree changes and do not claim Change-level landing,
   PR readiness, merge, or branch cleanup unless that route is separately
   selected and evidenced.

## Boundaries

- Proposal-local files remain lineage and lifecycle evidence only.
- Generated proposal registry output remains discovery-only.
- Do not treat packet archive as runtime authority.
- Do not delete user work or unrelated untracked files.
- Do not widen Mission Plan Compiler support beyond the optional stage-only
  policy and compile-only architecture already verified.
