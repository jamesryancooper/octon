---
title: Safety Reference
description: Safety constraints for the create-skill skill.
---

# Create Skill Safety

## Tool Policy

- Read template, manifest, registry, and existing skill definitions before writing.
- Write only inside `.octon/capabilities/runtime/skills/`, `_ops/state/runs/`, and `_ops/state/logs/`.
- Use `Bash(mkdir)` and `Bash(cp)` only for bounded template scaffolding.
- Use the shared `setup-harness-links.sh` flow instead of hand-creating per-skill symlinks.

## Hard Boundaries

- Never overwrite an existing skill directory without explicit user approval.
- Never emit legacy `depends_on` or top-level `pipelines`.
- Never create undeclared placeholder names in registry paths.
- Never mutate unrelated catalogs or docs as a side effect of skill creation.

## Failure Conditions

- Invalid `group` or `skill_name` is blocking.
- Template missing is blocking.
- Validation failure after registration is blocking; report the broken contract and stop.
- Link refresh failure is non-blocking only if the skill artifacts themselves are valid and the failure is reported explicitly.
