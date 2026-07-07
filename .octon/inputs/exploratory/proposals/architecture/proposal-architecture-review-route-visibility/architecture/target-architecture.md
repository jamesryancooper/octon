# Target Architecture

When a proposal-program child is an architecture proposal, the route graph includes an architecture-review edge with one of these states:

- not applicable
- missing required receipt
- stale receipt
- failing receipt
- passing fresh receipt
- owning workflow required

The edge links to the canonical pre-integration architecture review workflow and the current receipt path when present. The edge never satisfies the review gate by itself.
