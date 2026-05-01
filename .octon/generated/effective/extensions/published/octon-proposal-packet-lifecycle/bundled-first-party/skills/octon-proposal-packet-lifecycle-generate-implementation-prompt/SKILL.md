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
