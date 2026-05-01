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

Create a parent proposal program packet that references canonical child
packets. Reject nested child proposal package directories.
