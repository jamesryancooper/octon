# Acceptance Criteria

- Fresh accepted architecture-review receipts pass when `packet_digest` matches the current proposal packet.
- Stale receipts fail with an explicit stale-evidence reason.
- Lifecycle planning selects the owning architecture-review route for stale review evidence and does not reroute through unrelated revise or cleanup loops.
- Parent-owned evidence cannot satisfy child-owned architecture-review receipt requirements.
- Validator and Rust tests cover positive and negative cases.
