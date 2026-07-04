# Source Lineage

- PM-002: recoverable blockers were classified as human-required too often.
- Audit evidence: duplicate `parent-worktree-disposition-required` blockers
  were recorded as `human-required` even though route-owned closeout-worktree
  evidence could resolve the ambiguity.
- Audit acceptance: when cleanup-safe count is `0` and a non-mutating
  preserve/exclude route can bind the current fingerprint, lifecycle continues
  automatically after the gate reruns.
- Operator steering: recoverable closeout hygiene ambiguity should resolve
  through the narrowest target-owned route and then continue.
- Prior cleanup lineage:
  `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-cleanup-disposition`
