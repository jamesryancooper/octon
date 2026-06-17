# Target Architecture

The target state is a packet lifecycle that can proceed from accepted packet to
cleaned branch-no-PR delivery with materially fewer operator choices while
remaining fail-closed and evidence-backed.

## Desired Operating Model

- `/proposal-packet-delivery outcome=cleaned route=branch-no-pr` acts as the
  outer route-owned orchestrator.
- The wrapper recognizes pre-archive and already-archived states explicitly.
- Blocked aggregate receipts validate as truthful blocked receipts when their
  blockers are explicit.
- `closeout-change` owns the branch-no-PR state sequence from published branch
  through landed, synced, cleaned, and branch-deleted.
- Generated freshness authorization is routed automatically when implementation
  touches generator inputs.
- Worktree closeout uses first-class buckets for publishable evidence,
  cleanup-safe residue, protected retained evidence, and manual-review paths.
- Terminal proof is emitted without changing the source branch after landing.
- Git mutation helpers preflight sandbox and permission-sensitive operations
  before fetch, checkout, landing, sync, and cleanup attempts.

## Non-Authority Boundaries

The completed instruction-envelope run is evidence and lineage only. The
program must not edit its receipts, convert blocked receipts into pass
receipts, treat generated outputs as authority, or use proposal-local files as
runtime control truth.

## Child Ownership

Each improvement belongs to a sibling child packet. The parent may sequence,
summarize, and gate child work; it may not implement durable changes or satisfy
child-owned receipts.
