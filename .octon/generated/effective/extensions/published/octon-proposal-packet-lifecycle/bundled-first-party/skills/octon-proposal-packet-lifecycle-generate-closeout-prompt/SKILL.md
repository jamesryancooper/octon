---
name: octon-proposal-packet-lifecycle-generate-closeout-prompt
description: Run the generate-closeout-prompt bundle.
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

# Proposal Packet Lifecycle Generate Closeout Prompt

Generate `support/custom-closeout-prompt.md` with proposal archival,
validation, evidence, PR/CI/review, merge, branch cleanup, and sync gates.
