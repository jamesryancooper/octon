---
name: octon-proposal-lifecycle-run-program-lifecycle
description: Run contained proposal-program lifecycle coordination.
license: MIT
compatibility: Octon proposal lifecycle extension.
metadata:
  author: Octon Framework
  created: "2026-05-05"
  updated: "2026-07-14"
skill_sets: [executor, integrator, guardian]
capabilities: [safety-bounded, self-validating]
allowed-tools: Read Glob Grep Write(/.octon/state/evidence/runs/skills/*)
---

# Program - Run Lifecycle

During RP-00, coordinate only explicit `implemented` or `archive-ready`
outcomes. Preserve child-before-parent ordering and target-owned child receipts.

An effectful/default target, `direct-main`, hosted `branch-no-pr`, `landed`,
`synced`, `cleaned`, cleanup, Git/GitHub, provider, archive relocation, branch
deletion, or publication request fails before adapter dispatch with
`RP00_CONTAINMENT_PUBLICATION_DISABLED`.

Route-graph and planning views are diagnostic only. The lifecycle runner must
not emit a publication or cleanup handoff, treat compatibility vocabulary as
current authority, or use parent summaries/generated output in place of child
receipts. It preserves exact refs, branches, worktrees, rollback handles,
evidence, and unrelated work and names RP-06/RP-08 only as later owners.

The contained runner does not create an independent lifecycle contract. Any
historical `proposal-program-delivery-order-override-receipt-v1` remains
non-authorizing. A delivery-readiness preflight and include-path classification
may classify preserved work, but cannot authorize reconstruction, publication,
cleanup, or a clean-worktree claim during RP-00.
