# Acceptance Criteria

- Architecture proposal children show architecture-review status in the route graph.
- Non-architecture children show not-applicable or omit the edge consistently.
- Missing or stale architecture-review receipts point to the owning workflow or review route.
- Passing state requires a fresh receipt for the current packet digest.
- Tests prove route graph status does not satisfy architecture-review validators.
