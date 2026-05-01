---
name: octon-proposal-packet-lifecycle-generate-program-implementation-prompt
description: Run the generate-program-implementation-prompt bundle.
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

# Proposal Packet Lifecycle Generate Program Implementation Prompt

Generate aggregate implementation guidance that respects each child packet's
own manifests, validators, acceptance criteria, and promotion targets while
keeping parent coordination distinct from child authority.
