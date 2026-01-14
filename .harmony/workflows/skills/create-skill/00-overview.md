---
title: Create Skill
description: Scaffold a new skill from template with registry entry.
access: human
---

# Create Skill

Scaffold a new skill with I/O contracts, safety policies, and registry entry.

## Usage

```text
/create-skill <skill-id>
```

**Example:**
```text
/create-skill history-researcher
```

## Prerequisites

- Skill ID must be lowercase with hyphens (e.g., `history-researcher`)
- No existing skill with the same ID in `skills/registry.yml`

## Failure Conditions

- Invalid skill ID format (not kebab-case)
- Skill ID already exists
- Cannot write to skills directory

## Steps

1. [Validate ID](./01-validate-id.md) — Check format and uniqueness
2. [Copy Template](./02-copy-template.md) — Copy `_template/` to `skills/<skill-id>/`
3. [Initialize Skill](./03-initialize-skill.md) — Update `SKILL.md` with ID and placeholders
4. [Update Registry](./04-update-registry.md) — Add entry to `registry.yml`
5. [Update Catalog](./05-update-catalog.md) — Add row to skills table in `catalog.md`
6. [Report Success](./06-report-success.md) — Confirm creation and next steps

## Output

A new skill directory ready for definition:

```text
skills/<skill-id>/
├── SKILL.md       # Ready for capability definition
├── templates/     # (empty, for skill-specific templates)
└── reference/     # (empty, for detailed reference material)

# Plus symlinks in harness folders:
.claude/skills/<skill-id> -> ../../.workspace/skills/<skill-id>
.cursor/skills/<skill-id> -> ../../.workspace/skills/<skill-id>
.codex/skills/<skill-id> -> ../../.workspace/skills/<skill-id>
```

## Next Steps After Creation

1. Define commands and triggers in `SKILL.md`
2. Specify inputs and outputs
3. Write behavior steps
4. Set safety policies
5. Add acceptance criteria

## References

- **Documentation:** `docs/architecture/workspaces/skills.md`
- **Template:** `.workspace/skills/_template/SKILL.md`
- **Registry:** `.workspace/skills/registry.yml`
