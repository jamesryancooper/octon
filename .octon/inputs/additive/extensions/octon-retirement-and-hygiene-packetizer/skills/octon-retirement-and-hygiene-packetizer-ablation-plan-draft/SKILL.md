---
name: octon-retirement-and-hygiene-packetizer-ablation-plan-draft
description: Run the ablation-plan-draft flow.
metadata:
  author: Octon Framework
  updated: "2026-04-15"
skill_sets: [executor, integrator]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(/.octon/inputs/exploratory/proposals/*) Write(/.octon/state/control/skills/checkpoints/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Ablation Plan Draft

Use this skill when you want a non-authoritative ablation plan drafted from:

- repo-hygiene findings or packet attachments
- retirement registry required-ablation suites
- retirement register claim-adjacent flags
- protected-surface rules

Protected or claim-adjacent surfaces must remain `never-delete` in extension
outputs.
