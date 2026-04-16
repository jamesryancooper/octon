---
name: octon-pack-scaffolder-create-skill
description: >
  Scaffold a pack-local skill and update the pack-local skill discovery
  fragments in lexical order.
license: MIT
compatibility: Designed for Octon additive extension-pack authoring.
metadata:
  author: Octon Framework
  created: "2026-04-15"
  updated: "2026-04-15"
skill_sets: [executor, specialist]
capabilities: [self-validating, idempotent]
allowed-tools: Read Glob Grep Write(/.octon/inputs/additive/extensions/*)
---

# Octon Pack Scaffolder Create Skill

Create a pack-local skill plus the matching manifest and registry entries.

## When To Use

- the target pack needs a new skill under `skills/`
- the skill should register through the pack-local fragment model
- the skill should remain additive and pack-scoped

## Core Workflow

1. Validate `pack_id` and `skill_id`.
2. Create `skills/<skill-id>/SKILL.md` plus the three MVP reference files.
3. Insert or create the matching entries in `skills/manifest.fragment.yml`
   and `skills/registry.fragment.yml`.
4. Keep fragment ordering lexical by skill id.
5. Fail closed on conflicting content.

## Boundaries

- Additive only.
- Do not update core or instance skill catalogs.
- Do not create host projection files directly.
- Do not overwrite an existing skill with divergent content.

## References

- `references/phases.md`
- `references/io-contract.md`
- `references/validation.md`
