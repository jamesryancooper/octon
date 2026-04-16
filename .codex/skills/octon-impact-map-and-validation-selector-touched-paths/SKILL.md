---
name: octon-impact-map-and-validation-selector-touched-paths
description: >
  Analyze touched repo paths, map their direct and adjacent impact, select the
  minimum credible validation floor, and recommend the next canonical route.
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

# Touched Paths Impact Map

Use this skill when the only primary input is `touched_paths`.

Required result:

- classify touched surfaces using published repo rules
- identify direct and adjacent impact
- select the minimum credible validation set from existing repo surfaces
- recommend one next canonical route

Do not guess when no path rule yields a credible validation floor.
