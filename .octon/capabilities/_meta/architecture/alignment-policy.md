---
title: Skill Alignment Policy
description: Alignment-first policy for implementing new skills and handling contract extensions.
---

# Skill Alignment Policy

This policy standardizes how new skills are implemented in Octon.

## Default Rule

Implement skills by aligning to existing contracts first.

- Reuse existing `skill_sets`, `capabilities`, and capability-to-reference mappings in `.octon/capabilities/runtime/skills/capabilities.yml`.
- Use existing `allowed-tools` vocabulary from the specification (`Read`, `Write(...)`, `Glob`, `Grep`, `WebFetch`, `Shell`, `Task`).
- Keep metadata in current sources of truth (`SKILL.md`, `manifest.yml`, `registry.yml`).

Do not introduce ad hoc schema changes while implementing a skill.

## Exception Rule (Spec Extension)

Only extend skill contracts when both are true:

1. The behavior cannot be represented cleanly with existing contracts.
2. The mismatch is recurring (already seen in multiple skills, or expected to repeat).

Before extension work starts, prepare a proposal with:

- Deviation note: why alignment is insufficient
- Proposed contract delta: capability/skill-set/reference/config changes
- Required synchronized updates: docs, templates, validators
- Migration impact on existing skills (if any)

If these artifacts are missing, do not extend the spec.

## Enforcement Points

This policy is enforced in:

- `create-skill` skill flow (`.octon/capabilities/runtime/skills/meta/create-skill/`)
- Skills creation docs (`.octon/capabilities/_meta/architecture/creation.md`)
- Skills validation docs (`.octon/capabilities/_meta/architecture/validation.md`)
