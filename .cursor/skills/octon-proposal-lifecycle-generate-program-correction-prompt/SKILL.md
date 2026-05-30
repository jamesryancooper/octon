---
name: octon-proposal-lifecycle-generate-program-correction-prompt
description: Run the generate-program-correction-prompt bundle.
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

# Program - Generate Correction Prompt

Generate targeted correction for a parent, child, child-group, or cross-packet
finding without overriding child proposal authority.

When correction changes aggregate verification posture, refresh only the
parent-local aggregate conformance and drift receipts. Do not rewrite child
receipts, child promotion targets, child validation verdicts, or child archive
metadata from the parent program.
