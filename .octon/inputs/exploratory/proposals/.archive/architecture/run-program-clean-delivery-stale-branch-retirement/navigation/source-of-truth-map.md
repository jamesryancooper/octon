# Source Of Truth Map

Authoritative branch facts come from current Git refs, worktree state, locally
knowable PR/upstream checks, and route-owned receipts. Postmortem summaries and
final reports may explain the branch model but cannot prove retireability.

Remote mutation remains out of scope unless a separate current receipt
authorizes it.

Packet-local lifecycle review is recorded in `support/proposal-review.md`.
Strict pre-integration architecture evidence is recorded in
`support/pre-integration-architecture-review.yml`. Both receipts are
proposal-local evidence only and do not make this packet durable authority.
