---
name: octon-proposal-lifecycle-generate-program-closeout-prompt
description: Run the generate-program-closeout-prompt bundle.
license: MIT
compatibility: Octon proposal lifecycle extension.
metadata:
  author: Octon Framework
  created: "2026-04-30"
  updated: "2026-04-30"
skill_sets: [executor, specialist]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(/.octon/inputs/exploratory/proposals/*)
---

# Octon Proposal Lifecycle: Generate Program Closeout Prompt

Generate closeout guidance for coherent child closeout and parent archival.

Require passing parent-local aggregate receipts
`support/program-implementation-orchestration-conformance-review.md` and
`support/program-post-implementation-orchestration-drift-churn-review.md` before closeout.

For implemented child packets, require child-level implementation conformance
and post-implementation drift/churn receipts before parent closeout claims.

The generated prompt must require parent-local `support/proposal-closeout.md`
with `verdict`, `closed_at`, `archive_authorized`, and
`child_authority_preserved`. Parent closeout evidence may summarize child
outcomes but never satisfies child receipts, child promotion targets, child
validation verdicts, or child archive metadata, and it does not authorize child
archival by itself.
