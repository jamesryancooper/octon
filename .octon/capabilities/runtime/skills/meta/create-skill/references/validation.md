---
title: Validation Reference
description: Acceptance checks for the create-skill skill.
---

# Create Skill Validation

## Required Pass Conditions

- New directory exists at `.octon/capabilities/runtime/skills/<group>/<skill_name>/`.
- `SKILL.md` `name` matches `skill_name`.
- `manifest.yml` entry exists and includes `skill_class`.
- `registry.yml` entry exists and contains no `depends_on`.
- Any generated placeholders are standard placeholders or declared parameters only.
- `.octon/capabilities/runtime/skills/_ops/scripts/validate-skills.sh <skill_name>` passes.
- Run log exists and skill-level/top-level log indexes are updated.

## Optional/Conditional Checks

- `composition` exists only when the new skill actually bundles prerequisite or invoke steps.
- `allowed-services` is blank unless the skill composes services.
- Host adapter links are refreshed with `setup-harness-links.sh <skill_name>` when the environment uses them.

## Failure Reporting

- Report the exact contract field that failed.
- Do not report success when validation is red.
- If the only failure is link refresh, mark the skill artifacts valid but the setup incomplete.
