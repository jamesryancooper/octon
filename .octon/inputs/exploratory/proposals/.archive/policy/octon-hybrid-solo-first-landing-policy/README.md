# Hybrid Solo-First Landing Policy

Policy proposal for making Octon's Change-first closeout model fast for a solo
maintainer without weakening safety.

The proposal keeps PRs as a route, not a universal landing tax:

- `direct-main` remains for clean, low-risk Changes made directly on current
  `main`.
- `branch-no-pr` gains a real hosted fast-forward landing path when route
  preflight, validation, receipt, rollback, freshness, and provider rules all
  pass.
- `branch-pr` remains mandatory for hosted review, external signoff, unresolved
  review discussion, high-impact or protected governance handling, team
  collaboration, and explicit operator PR requests.
- `stage-only-escalate` captures blocked validation, route selection,
  permissions, or hosted landing feasibility without completion claims.

This packet owns Octon-internal policy, schema, skill, workflow, helper, and
validator changes. Repo-local `.github/**` workflow and live GitHub ruleset
changes are recorded as linked projection work because active proposal packets
must not mix `.octon/**` authority targets with repo-local projection targets.
