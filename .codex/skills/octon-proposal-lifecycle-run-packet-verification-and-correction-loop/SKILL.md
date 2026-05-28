---
name: octon-proposal-lifecycle-run-packet-verification-and-correction-loop
description: Run the verification-and-correction convergence bundle.
license: MIT
compatibility: Octon proposal lifecycle extension.
metadata:
  author: Octon Framework
  created: "2026-04-30"
  updated: "2026-04-30"
skill_sets: [executor, verifier]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(/.octon/inputs/exploratory/proposals/*) Write(/.octon/state/control/skills/checkpoints/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Packet - Run Verification And Correction Loop

Run verification, generate targeted corrections, re-verify, and stop only at
`clean`, `blocked`, `needs-packet-revision`, `superseded`, or explicitly
deferred. Retain every verification and correction pass, and honor declared
no-new-finding or consecutive-clean-pass closure thresholds.

The loop is not clean while the implementation-grade completeness receipt is
missing, failing, contains unresolved questions, or leaves executable
implementation prompt readiness unproven.

This loop is the pre-implementation packet completeness loop unless the packet
has already been implemented. For implemented packets, continue into the
post-implementation conformance loop and drift/churn loop; do not mark the
proposal closed out while either post-implementation receipt is missing,
failing, or unresolved.
