---
name: octon-proposal-packet-lifecycle-generate-correction-prompt
description: Run the generate-correction-prompt bundle.
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

# Proposal Packet Lifecycle Generate Correction Prompt

Generate one targeted correction prompt under
`support/correction-prompts/<finding-id>.md` for an unresolved verification
finding or justified finding group.
