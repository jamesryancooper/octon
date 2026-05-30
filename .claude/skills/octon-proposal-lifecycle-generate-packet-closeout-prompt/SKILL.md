---
name: octon-proposal-lifecycle-generate-packet-closeout-prompt
description: Run the generate-packet-closeout-prompt bundle.
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

# Packet - Generate Closeout Prompt

Generate `support/custom-closeout-prompt.md` with proposal archival,
validation, evidence, final hygiene, and route-required PR/CI/review, merge,
branch cleanup, or sync gates.

For implemented closeout, include the required post-implementation gates:
`support/implementation-conformance-review.md`,
`support/post-implementation-drift-churn-review.md`,
`validate-proposal-implementation-conformance.sh --package <proposal_path>`,
and `validate-proposal-post-implementation-drift.sh --package <proposal_path>`.
The closeout prompt must refuse implemented, closeout, or archive-ready claims
while either receipt is missing, failing, unresolved, or blocked.
