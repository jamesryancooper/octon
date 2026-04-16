---
name: octon-retirement-and-hygiene-packetizer-scan-to-reconciliation
description: Run the scan-to-reconciliation flow.
metadata:
  author: Octon Framework
  updated: "2026-04-15"
skill_sets: [executor, integrator]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(/.octon/state/control/skills/checkpoints/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Scan To Reconciliation

Use this skill when you want `repo-hygiene scan` level findings reconciled
against:

- retirement-registry coverage
- retirement-register claim-adjacent flags
- claim-gate context
- protected-surface rules from `repo-hygiene.yml`

This flow is summary-grade only. It does not draft deletion outcomes or write
cleanup packet evidence.
