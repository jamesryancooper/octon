---
name: octon-proposal-packet-lifecycle-run-verification-and-correction-loop
description: Run the verification-and-correction convergence bundle.
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

# Proposal Packet Lifecycle Verification And Correction Loop

Run verification, generate targeted corrections, re-verify, and stop only at
`clean`, `blocked`, `needs-packet-revision`, `superseded`, or explicitly
deferred. Retain every verification and correction pass, and honor declared
no-new-finding or consecutive-clean-pass closure thresholds.
