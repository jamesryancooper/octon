---
title: Create Skill
description: Scaffold a new skill from template with registry entry, following the agentskills.io spec.
access: human
version: "2.0.0"
depends_on: []
checkpoints:
  enabled: true
  storage: ".harmony/continuity/checkpoints/"
parallel_steps: []
deprecated: true
deprecated_by: ".harmony/capabilities/skills/meta/create-skill/"
---

> **DEPRECATED:** This workflow is superseded by the `create-skill` skill.
> Use `use skill: create-skill` or `/create-skill` instead.
> This workflow is retained as historical reference only.
> Active paths, reference file names, and directory structures below may be stale.

# Create Skill

Scaffold a new skill following the [agentskills.io](https://agentskills.io) specification with proper naming, progressive disclosure structure, and registry entry.

## Usage

```text
/create-skill <skill-name>
```

**Examples:**
```text
/create-skill refine-prompt
/create-skill generate-report
/create-skill analyze-codebase
```

## Naming Convention

**Use action-oriented names** following the verb-noun pattern:

| Pattern | Good Examples | Bad Examples |
|---------|---------------|--------------|
| verb-noun | `refine-prompt`, `generate-report` | `prompt-refiner`, `report-generator` |
| verb-object | `analyze-codebase`, `process-payment` | `codebase-analyzer`, `payment-processor` |
| action-target | `validate-schema`, `extract-data` | `schema-validator`, `data-extractor` |

**Rules:**
- Use lowercase letters, numbers, and hyphens only
- Start with a verb (action word)
- Must match the directory name exactly
- No consecutive hyphens (`--`)
- No leading/trailing hyphens

## Prerequisites

- Skill name follows action-oriented naming convention
- No existing skill with the same name in registry
- Name is 1-64 characters, lowercase with hyphens

## Failure Conditions

- Invalid skill name format (not kebab-case)
- Name doesn't follow verb-noun pattern (warning, not blocking)
- Skill name already exists
- Cannot write to skills directory

## Steps

1. [Validate Name](./01-validate-name.md) — Check format, naming convention, and uniqueness
2. [Copy Template](./02-copy-template.md) — Copy template to `.harmony/capabilities/skills/<group>/<skill-name>/`
3. [Initialize Skill](./03-initialize-skill.md) — Update `SKILL.md` with name and placeholders
4. [Update Registry](./04-update-registry.md) — Add entry to `registry.yml`
5. [Update Catalog](./05-update-catalog.md) — Add row to skills table in `catalog.md`
6. [Report Success](./06-report-success.md) — Confirm creation and next steps

## Output Structure

A new skill directory following the agentskills.io spec:

```text
.harmony/capabilities/skills/<group>/<skill-name>/
├── SKILL.md              # Core skill definition (<500 lines)
├── references/           # Detailed documentation (progressive disclosure)
│   ├── phases.md         # Phase-by-phase behavior details
│   ├── io-contract.md    # Inputs, outputs, dependencies, command-line usage
│   ├── safety.md         # Tool and file policies
│   ├── examples.md       # Full usage examples
│   └── validation.md     # Acceptance criteria
├── scripts/              # Executable code (optional)
└── assets/               # Static resources (optional)

# Plus symlinks in harness folders:
.claude/skills/<skill-name> -> ../../.harmony/capabilities/skills/<group>/<skill-name>
.cursor/skills/<skill-name> -> ../../.harmony/capabilities/skills/<group>/<skill-name>
.codex/skills/<skill-name> -> ../../.harmony/capabilities/skills/<group>/<skill-name>
```

## Next Steps After Creation

1. **Edit `SKILL.md`** to define:
   - Description (what it does and when to use it)
   - Core workflow phases
   - Parameters and output locations
   - Boundaries and escalation triggers

2. **Edit reference files** to add details:
   - `references/phases.md` — Detailed phase steps
   - `references/io-contract.md` — Input/output schemas, command-line usage
   - `references/safety.md` — Tool and file policies
   - `references/examples.md` — Full examples
   - `references/validation.md` — Acceptance criteria

3. **Update `registry.yml`** with:
   - Human-readable summary
   - Trigger patterns
   - Tool requirements

4. **Test the skill** by invoking:
   ```text
   /<skill-name> [input]
   ```

## Spec Compliance

This workflow creates skills that comply with [agentskills.io/specification](https://agentskills.io/specification):

- **Required frontmatter:** `name`, `description`
- **Optional frontmatter:** `license`, `compatibility`, `metadata`, `allowed-tools`
- **Directory structure:** `references/`, `scripts/`, `assets/`
- **Progressive disclosure:** Core SKILL.md < 500 lines, details in references/

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.0.0 | 2025-01-15 | Aligned with agentskills.io spec, action-oriented naming, progressive disclosure |
| 1.2.0 | 2025-01-14 | Added idempotency sections to all step files |
| 1.1.0 | 2025-01-14 | Added gap remediation fields |
| 1.0.0 | 2025-01-05 | Initial version |

## References

- **Spec:** [agentskills.io/specification](https://agentskills.io/specification)
- **Documentation:** `.harmony/capabilities/_meta/architecture/README.md`
- **Example:** `.harmony/capabilities/skills/synthesis/refine-prompt/`
- **Template:** `.harmony/capabilities/skills/_scaffold/template/`
- **Registry:** `.harmony/capabilities/skills/registry.yml`
