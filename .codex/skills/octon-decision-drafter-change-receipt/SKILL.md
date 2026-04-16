---
name: octon-decision-drafter-change-receipt
description: Run the change-receipt bundle.
metadata:
  author: Octon Framework
  updated: "2026-04-15"
skill_sets: [executor, integrator]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(/.octon/state/control/skills/checkpoints/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Change Receipt Draft

Use this skill when you want a concise non-authoritative markdown receipt that
summarizes a diff and cites existing retained receipts or evidence.
