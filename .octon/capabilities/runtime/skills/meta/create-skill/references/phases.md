---
title: Behavior Phases
description: Phased execution guidance for the create-skill skill.
---

# Create Skill Phases

## Phase 1: Validate

- Validate `skill_name` against the kebab-case contract.
- Validate `group` against the canonical groups declared in `capabilities.yml`.
- Check uniqueness in `manifest.yml` and `registry.yml`.
- Record the alignment-first decision before any file writes.

## Phase 2: Copy Template

- Create `.octon/capabilities/runtime/skills/<group>/<skill_name>/`.
- Copy `SKILL.md` and `references/` from `_scaffold/template/`.
- Create `scripts/` if it is not present from the template.
- Do not create `assets/` unless the template or requested skill actually needs it.

## Phase 3: Initialize

- Replace template placeholders in `SKILL.md` and reference files.
- Set metadata dates.
- Leave `allowed-services` blank unless the new skill explicitly composes services.
- Keep placeholder usage in registry/output examples to standard placeholders plus declared parameters.

## Phase 4: Register

- Add a manifest entry with `id`, `display_name`, `path`, `skill_class`, `summary`, `status`, `tags`, `triggers`, `skill_sets`, and `capabilities`.
- Add a registry entry with `version`, `commands`, `parameters`, `requires.context`, optional `composition`, and `io`.
- Do not write `depends_on`.

## Phase 5: Validate And Refresh Links

- Run `.octon/capabilities/runtime/skills/_ops/scripts/validate-skills.sh <skill_name>`.
- If validation passes, run `.octon/capabilities/runtime/skills/_ops/scripts/setup-harness-links.sh <skill_name>` to refresh host adapter links when needed.
- Write the run log and update log indexes.

## Phase 6: Report

- Report the created directory path, selected `skill_class`, and whether `composition` was added.
- Call out any remaining manual follow-up, such as filling in domain-specific references.
