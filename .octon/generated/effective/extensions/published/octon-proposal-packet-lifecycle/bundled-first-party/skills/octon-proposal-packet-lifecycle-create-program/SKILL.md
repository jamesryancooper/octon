---
name: octon-proposal-packet-lifecycle-create-program
description: Run the create-proposal-program bundle.
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

# Proposal Packet Lifecycle Create Program

Program packets inherit the implementation-grade completeness gate. Do not
present a program as final or implementation-ready until its packet-level or
program-level completeness receipt passes with no unresolved questions.

Implemented child packets also inherit the post-implementation conformance and
drift/churn gates before closeout or implemented archival.

Create a parent proposal program packet that references canonical child
packets. Reject nested child proposal package directories.
