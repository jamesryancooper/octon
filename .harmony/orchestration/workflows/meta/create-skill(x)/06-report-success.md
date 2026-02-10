---
title: Report Success
description: Confirm skill creation and provide next steps.
---

# Step 6: Report Success

## Input

- Completed steps 1-5

## Actions

Report to user:

```markdown
## Skill Created: <skill-name>

**Location:** `.harmony/capabilities/skills/<skill-name>/`

### Files Created

**Core:**
- `SKILL.md` — Main skill definition (ready for customization)

**References (progressive disclosure):**
- `references/behaviors.md` — Detailed phase behavior
- `references/io-contract.md` — Inputs, outputs, dependencies, command-line usage
- `references/safety.md` — Tool and file policies
- `references/examples.md` — Full usage examples
- `references/validation.md` — Acceptance criteria

**Directories:**
- `scripts/` — For executable code
- `assets/` — For static resources

**Registry updated:** `skills/registry.yml`
**Catalog updated:** `.harmony/catalog.md`

### Next Steps

#### 1. Define the Skill

Edit `SKILL.md` to customize:

```yaml
---
name: <skill-name>
description: >
  [Describe what this skill does and when to use it.
  Include keywords to help agents identify relevant tasks.]
---
```

Add:
- Clear description with keywords
- Core workflow phases
- Parameters table
- Output locations
- Boundaries and escalation triggers

#### 2. Add Reference Details

Edit reference files for progressive disclosure:

| File | Content |
|------|---------|
| `references/behaviors.md` | Detailed step-by-step behavior |
| `references/io-contract.md` | Input/output schemas, command-line usage |
| `references/safety.md` | Tool permissions and file policies |
| `references/examples.md` | Full worked examples |
| `references/validation.md` | Acceptance criteria |

#### 3. Update Manifest and Registry

Edit `manifest.yml` and `registry.yml` to add:
- Human-readable `name` and `summary` (manifest)
- `status` and `tags` for filtering (manifest)
- `triggers` for natural language activation (manifest)
- `commands` and `requires.context` (registry)

#### 4. Test the Skill

```text
/<skill-name> [input]
```

### Spec Compliance

This skill follows [agentskills.io/specification](https://agentskills.io/specification):
- ✓ Required frontmatter: `name`, `description`
- ✓ Directory structure: `references/`, `scripts/`, `assets/`
- ✓ Progressive disclosure: Core SKILL.md < 500 lines
- ✓ Action-oriented naming: verb-noun pattern

### Documentation

- **Spec:** [agentskills.io/specification](https://agentskills.io/specification)
- **Example skill:** `.harmony/capabilities/skills/synthesis/refine-prompt/`
- **Template:** `.harmony/capabilities/skills/_template/`
```

## Verification

- All steps completed successfully
- User has clear next steps
- Spec compliance noted

## Idempotency

**Check:** Was success already reported?
- [ ] Checkpoint file exists: `checkpoints/create-skill/<skill-name>/06-success.complete`

**If Already Complete:**
- Display cached success message
- Workflow already finished

**Marker:** `checkpoints/create-skill/<skill-name>/06-success.complete`

## Output

- Skill creation complete
- Workflow finished
