---
name: octon-proposal-packet-lifecycle-run-program-verification-and-correction-loop
description: Run the program verification-and-correction convergence bundle.
license: MIT
compatibility: Octon proposal packet lifecycle extension.
metadata:
  author: Octon Framework
  created: "2026-04-30"
  updated: "2026-04-30"
skill_sets: [executor, verifier]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(/.octon/inputs/exploratory/proposals/*) Write(/.octon/state/control/skills/checkpoints/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Proposal Packet Lifecycle Program Verification And Correction Loop

Run parent and child verification, targeted corrections, and re-verification
until the program reaches a declared terminal state.
