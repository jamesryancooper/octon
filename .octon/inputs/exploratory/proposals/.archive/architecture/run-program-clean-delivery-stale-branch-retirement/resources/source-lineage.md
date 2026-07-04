# Source Lineage

- PM-003: similar branch names made delivery status confusing.
- PM-007: final reporting overclaimed branch cleanup scope.
- Audit evidence: the dirty-anchor branch
  `chore/run-program-clean-delivery-postmortem-hardening` had no unique commits
  relative to `main`, while the route-owned `-delivery` branch delivered the
  changes and was cleaned up.
- Audit acceptance: cleanup reports name every retained local branch, its ref,
  whether it has unique commits, and why it was retained.
- Operator decision: stale local branches with no unique commits should be
  automatically retired whenever safe under a governed route.
- Local cleanup experience:
  `chore/run-program-clean-delivery-postmortem-hardening` was a dirty anchor,
  not the route-owned delivery branch.
