# Implementation Plan

1. Implement compact blocker-remediation mode and artifact-budget triggers for
   repeated fingerprints, file count, and byte size.
2. Add autonomous closeout-worktree preserve/exclude continuation for
   recoverable hygiene, ownership, and stale-fingerprint blockers.
3. Add stale local branch retirement logic that proves no unique commits,
   resolves dirty worktree dependency through a governed local-worktree route,
   switches to the surviving branch, and deletes only proven stale local refs.
4. Redirect speculative run-health projections to scratch or local-private
   storage; require path-and-digest promotion receipts for durable evidence.
5. Add no-dispatch deduplication so repeated resumptions with unchanged inputs
   update one bounded attempt ledger instead of producing duplicate evidence
   trees.
6. Add final report schema fields and validators for delivered branch,
   route-owned delivery branch, source-dirty-anchor branches, retained local
   anchors, retained worktrees, retained evidence, deleted residue,
   generated/local-private residue, and manual-review residue.
7. Replace human `--confirm` landing semantics with an explicit
   authorization-consuming non-interactive execution flag when a current hosted
   no-PR landing receipt validates.
8. Add negative controls proving every autonomous path blocks on foreign
   unpreservable residue, destructive action without authority, protected refs,
   stale receipts, missing credentials, provider-rule drift, or conflicting
   operator instructions.
