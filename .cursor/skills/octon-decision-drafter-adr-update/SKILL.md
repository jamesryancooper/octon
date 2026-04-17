---
name: octon-decision-drafter-adr-update
description: Run the adr-update bundle.
metadata:
  author: Octon Framework
  updated: "2026-04-15"
skill_sets: [executor, integrator]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(/.octon/state/control/skills/checkpoints/*) Write(/.octon/state/evidence/runs/skills/*)
---

# ADR Update Draft

Use this skill when you want a non-authoritative ADR update draft grounded in
a diff plus retained evidence.
