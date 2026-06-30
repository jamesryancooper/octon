# Target Architecture

Architecture-review acceptance becomes a freshness-checked gate, not a prose claim. Each review-sensitive lifecycle transition resolves the applicable proposal packet, computes or validates the current packet digest, and requires an accepted architecture-review receipt whose `packet_digest` matches.

When the digest is stale, the lifecycle planner must select the owning architecture-review route or stop with a specific stale-evidence blocker. It must not cycle unrelated revise or cleanup routes, and it must not let parent evidence replace child-owned receipts.
