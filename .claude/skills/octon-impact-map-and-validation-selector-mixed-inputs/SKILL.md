---
name: octon-impact-map-and-validation-selector-mixed-inputs
description: >
  Reconcile touched paths with proposal or refactor intent, surface drift
  explicitly, and select the minimum credible validation floor plus the next
  canonical route.
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

# Mixed Input Impact Map

Use this skill when more than one primary input family is present.

Required result:

- reconcile observed touched paths against declared packet or refactor intent
- treat touched paths as the stronger factual source for impact claims
- surface drift instead of hiding it
- recommend packet refresh, scope tightening, or clarification before broader
  execution when needed
