---
name: octon-proposal-packet-lifecycle-generate-verification-prompt
description: Run the generate-verification-prompt bundle.
license: MIT
compatibility: Octon proposal packet lifecycle extension.
metadata:
  author: Octon Framework
  created: "2026-04-30"
  updated: "2026-04-30"
skill_sets: [verifier, specialist]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(/.octon/inputs/exploratory/proposals/*)
---

# Proposal Packet Lifecycle Generate Verification Prompt

Generate `support/follow-up-verification-prompt.md` with stable finding
identity, evidence requirements, correction scope, acceptance criteria,
generated/runtime publication checks, and declared closure-certification pass
depth.

Verification prompts must include the implementation-grade completeness gate
outcome and must verify the packet against
`validate-proposal-implementation-readiness.sh` in addition to structural and
subtype validators.

For implemented packets or closeout verification, prompts must also require
`validate-proposal-implementation-conformance.sh` and
`validate-proposal-post-implementation-drift.sh`, and must treat missing or
failing post-implementation receipts as closeout blockers.
