---
title: Creating Skills
description: Workflow for creating new skills and post-creation tasks.
---

# Creating Skills

Use the `/create-skill` workflow to create new skills that follow the agentskills.io specification.

---

## Quick Start

```markdown
/create-skill <skill-name>
```

This invokes the workflow defined in `.harmony/workflows/skills/create-skill/`.

---

## Workflow Steps

| Step | File | Purpose |
|------|------|---------|
| 1 | `01-validate-name.md` | Check format, action-oriented naming, uniqueness |
| 2 | `02-copy-template.md` | Copy `_template/` to `skills/<skill-name>/` |
| 3 | `03-initialize-skill.md` | Update placeholders with skill name |
| 4 | `04-update-manifest.md` | Add entry to `manifest.yml` (Tier 1 discovery) |
| 5 | `05-update-registry.md` | Add entry to `registry.yml` (extended metadata) |
| 6 | `06-update-catalog.md` | Add to skills table in documentation |
| 7 | `07-report-success.md` | Confirm and show next steps |

---

## Output Structure

A new skill directory following the agentskills.io spec:

```markdown
.harmony/skills/<skill-name>/
├── SKILL.md              # Core definition (<500 lines)
├── references/           # Progressive disclosure
│   ├── behaviors.md
│   ├── io-contract.md
│   ├── safety.md
│   ├── examples.md
│   └── validation.md
├── scripts/              # Executable code (optional)
└── assets/               # Static resources (optional)

# Plus symlinks in harness folders:
.claude/skills/<skill-name> -> ../../.harmony/skills/<skill-name>
.cursor/skills/<skill-name> -> ../../.harmony/skills/<skill-name>
.codex/skills/<skill-name> -> ../../.harmony/skills/<skill-name>
```

---

## Post-Creation Steps

After the workflow completes, you need to:

### 1. Edit `SKILL.md`

Add the skill's core content:

- Description of what the skill does
- When to use it (trigger conditions)
- Core workflow phases
- Parameters and their defaults
- Output locations
- Boundaries and constraints
- Escalation conditions

### 2. Edit Reference Files

Customize each reference file in `references/`:

| File | What to Add |
|------|-------------|
| `io-contract.md` | Input names, types, output paths, command-line usage |
| `safety.md` | Tool permissions, behavioral boundaries |
| `examples.md` | 2-4 worked examples with full output |
| `behaviors.md` | Phase-by-phase execution details |
| `validation.md` | Acceptance criteria specific to this skill |

See [Reference Artifacts](./reference-artifacts.md) for detailed guidance on each file.

**Note:** Commands and triggers are defined in `manifest.yml` and `registry.yml`, not in reference files.

### 3. Update Shared Manifest

Add the skill to `.harmony/skills/manifest.yml` for Tier 1 discovery:

```yaml
skills:
  - id: your-skill-name
    name: Your Skill Name
    path: your-skill-name/
    summary: "One-line description of what the skill does."
    status: active
    tags:
      - category-tag
      - function-tag
    triggers:
      - "natural language trigger 1"
      - "natural language trigger 2"
```

### 4. Update Shared Registry

Add extended metadata to `.harmony/skills/registry.yml`:

```yaml
skills:
  your-skill-name:
    version: "1.0.0"
    commands:
      - /your-skill-name
    requires:
      tools:
        - filesystem.read
        - filesystem.write.outputs
      context:
        - type: directory_exists
          path: ".workspace/"
          description: "Requires a workspace directory"
    depends_on: []
```

### 5. Add Workspace Mappings

If the skill needs workspace-specific I/O paths, add them to `.workspace/skills/registry.yml`:

```yaml
skill_mappings:
  your-skill-name:
    inputs:
      - path: "sources/your-category/"
        kind: directory
        required: true
        description: "Source folder for skill input"
    outputs:
      - path: "outputs/your-category/{{name}}.md"
        kind: file
        format: markdown
        determinism: stable
        description: "Skill output document"
```

**Placeholder Syntax:** Use `{{snake_case}}` for path placeholders (e.g., `{{timestamp}}`, `{{project}}`). See [Placeholder Resolution](./execution.md#placeholder-resolution) for details.

### 6. Create Symlinks

Run the setup script or create symlinks manually:

```bash
# Using setup script
.harmony/skills/scripts/setup-harness-links.sh

# Or manually
ln -s ../../.harmony/skills/your-skill-name .claude/skills/your-skill-name
ln -s ../../.harmony/skills/your-skill-name .cursor/skills/your-skill-name
ln -s ../../.harmony/skills/your-skill-name .codex/skills/your-skill-name
```

### 7. Test

Run the skill with a test input:

```markdown
/your-skill-name "test input"
```

Verify:
- [ ] Output created in expected location
- [ ] Run log created in `logs/runs/`
- [ ] Output format matches specification
- [ ] All phases executed correctly

---

## Naming Requirements

Skills must follow action-oriented naming:

| Constraint | Rule |
|------------|------|
| Pattern | verb-noun (e.g., `refine-prompt`, `generate-report`) |
| Length | 1-64 characters |
| Characters | Lowercase letters, numbers, and hyphens only |
| Hyphens | Must not start/end with hyphen |
| Consecutive | Must not contain consecutive hyphens (`--`) |
| Directory match | Must match the parent directory name exactly |

**Good:** `refine-prompt`, `analyze-codebase`, `generate-report`

**Bad:** `prompt-refiner`, `Analyze-Codebase`, `--generate-report`

---

## See Also

- [Skill Format](./skill-format.md) — SKILL.md structure requirements
- [Reference Artifacts](./reference-artifacts.md) — Reference file documentation
- [Discovery](./discovery.md) — Manifest and registry formats
