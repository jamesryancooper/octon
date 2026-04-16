---
name: octon-retirement-and-hygiene-packetizer-registry-gap-analysis
description: Run the registry-gap-analysis flow.
metadata:
  author: Octon Framework
  updated: "2026-04-15"
skill_sets: [executor, integrator]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(/.octon/state/control/skills/checkpoints/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Registry Gap Analysis

Use this skill when you need a deterministic comparison between:

- `retirement-registry.yml`
- `retirement-register.yml`
- latest review packet references
- optional repo-hygiene audit evidence

The output should identify missing coverage, stale coverage, and contradictions
without modifying any governance truth.
