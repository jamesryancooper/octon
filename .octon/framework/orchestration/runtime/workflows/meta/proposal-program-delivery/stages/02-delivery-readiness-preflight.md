# Stage 02: Delivery Readiness Preflight

Run one retained readiness preflight before expensive lifecycle continuation, parent/program delivery, Git mutation, publication checks, landing, sync, cleanup, or branch deletion.

Required checks:

- Git index and ref write probes record typed blockers without authorizing side effects.
- Worktree cleanliness and source staleness are recorded before any reconstruction, broad stage-all, staging, or commit.
- Dirty or stale source posture selects a route-owned clean worktree from current `origin/main`.
- Include-path classification is present and valid before reconstruction, broad stage-all, staging, or commit.
- Review freshness, child receipt compatibility, tooling availability, route legality, and generated freshness are checked once and retained as a readiness receipt.
- Later stages consume the retained readiness receipt instead of rediscovering authority blockers independently.
