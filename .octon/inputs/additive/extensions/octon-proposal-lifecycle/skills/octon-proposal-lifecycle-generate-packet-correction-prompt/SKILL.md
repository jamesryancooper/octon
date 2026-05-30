---
name: octon-proposal-lifecycle-generate-packet-correction-prompt
description: Run the generate-packet-correction-prompt bundle.
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

# Packet - Generate Correction Prompt

Generate one targeted correction prompt under
`support/correction-prompts/<finding-id>.md` for an unresolved verification
finding or justified finding group.

Correction prompts must preserve the implementation-grade completeness gate and
must target missing or failing receipt fields when those are the active blocker.
For implemented packets, correction prompts must also target missing or failing
implementation conformance and post-implementation drift/churn receipts before
closeout can continue.
