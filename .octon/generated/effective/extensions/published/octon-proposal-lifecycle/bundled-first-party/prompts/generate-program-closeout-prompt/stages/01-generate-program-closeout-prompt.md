# Generate Program Closeout Prompt

Generate a closeout prompt that requires coherent child lifecycle states,
declared child closeout order, aggregate evidence, safe proposal registry
regeneration, and proof that durable targets do not depend on parent or child
proposal packet paths.

Require passing parent-local aggregate verification receipts before closeout:
`support/program-implementation-orchestration-conformance-review.md` and
`support/program-post-implementation-orchestration-drift-churn-review.md` must both record
`verdict: pass` and `child_authority_preserved: yes`.

The prompt must delegate PR, CI, review, merge, branch cleanup, and sync
behavior to the shared Git/worktree closeout contract when a child route uses a
PR or branch lane. Program-specific closeout adds only child-state coherence,
parent archival, child archival or deferral evidence, aggregate registry safety,
and parent/child proposal-path dependency checks.

The generated closeout prompt must require a parent-local
`support/proposal-closeout.md` with at least `verdict`, `closed_at`,
`archive_authorized`, and `child_authority_preserved`. Use `verdict: pass`,
`archive_authorized: yes`, and `child_authority_preserved: yes` only when
parent closeout evidence is complete and child manifests, child receipts, child
promotion targets, child validation verdicts, and child archive metadata remain
child-owned. Parent closeout evidence may summarize child outcomes but never
satisfies child receipts or authorizes child archival by itself.
