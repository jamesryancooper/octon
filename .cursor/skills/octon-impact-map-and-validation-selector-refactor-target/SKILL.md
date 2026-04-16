---
name: octon-impact-map-and-validation-selector-refactor-target
description: >
  Analyze a rename, move, or restructure target, derive its exhaustive impact
  scope, select the minimum credible validation floor, and route toward the
  canonical refactor workflow.
license: MIT
compatibility: Designed for Octon extension-pack publication and host projection.
metadata:
  author: Octon Framework
  created: "2026-04-15"
  updated: "2026-04-15"
skill_sets: [executor, specialist]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(/.octon/state/control/skills/checkpoints/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Refactor Target Impact Map

Use this skill when the only primary input is `refactor_target`.

Required result:

- normalize rename, move, or restructure intent
- derive exhaustive reference-check scope and path variations
- select `/refactor` as the primary execution route
- add only the extra validators implied by the affected surfaces
