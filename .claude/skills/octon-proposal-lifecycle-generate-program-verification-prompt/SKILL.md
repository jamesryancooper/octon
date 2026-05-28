---
name: octon-proposal-lifecycle-generate-program-verification-prompt
description: Run the generate-program-verification-prompt bundle.
license: MIT
compatibility: Octon proposal lifecycle extension.
metadata:
  author: Octon Framework
  created: "2026-04-30"
  updated: "2026-04-30"
skill_sets: [verifier, specialist]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(/.octon/inputs/exploratory/proposals/*)
---

# Octon Proposal Lifecycle: Generate Program Verification Prompt

Generate aggregate verification across parent sequence, dependency, risk,
evidence, and child packet acceptance criteria.

Require the verification loop to produce parent-local
`support/program-implementation-orchestration-conformance-review.md` and
`support/program-post-implementation-orchestration-drift-churn-review.md` with aggregate
verdicts and `child_authority_preserved`. These receipts may summarize child
state but never satisfy child receipts or child validation verdicts.
