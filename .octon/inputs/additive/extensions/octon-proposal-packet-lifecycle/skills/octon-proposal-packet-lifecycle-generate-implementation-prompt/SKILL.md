---
name: octon-proposal-packet-lifecycle-generate-implementation-prompt
description: Run the generate-implementation-prompt bundle.
license: MIT
compatibility: Octon proposal packet lifecycle extension.
metadata:
  author: Octon Framework
  created: "2026-04-30"
  updated: "2026-04-30"
skill_sets: [executor, specialist]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(/.octon/inputs/exploratory/proposals/*)
---

# Proposal Packet Lifecycle Generate Implementation Prompt

Generate `support/executable-implementation-prompt.md` from the packet's
manifests, promotion targets, acceptance criteria, validation plan, evidence
plan, and live repository state. Include executable workstreams, validation,
evidence, rollback posture, terminal criteria, and any explicitly authorized
delegation boundaries.

Prerequisite: `support/implementation-grade-completeness-review.md` must exist
and pass before this skill writes or refreshes an executable implementation
prompt. Refuse prompt generation when the receipt is missing, failing, or still
requires clarification.

The generated implementation prompt must instruct the implementer to produce
`support/implementation-conformance-review.md` and
`support/post-implementation-drift-churn-review.md` after implementation, run
`validate-proposal-implementation-conformance.sh --package <proposal_path>` and
`validate-proposal-post-implementation-drift.sh --package <proposal_path>`, and
refuse closeout/archive claims until both receipts pass.

After a prompt is generated and the packet is accepted or explicitly approved
for implementation, the next lifecycle route is `run-implementation`.
