---
title: Creating Skills
description: How to create new skills and post-creation tasks.
---

# Creating Skills

Use the `/create-skill` command to create new skills that follow the agentskills.io specification.

---

## Quick Start

```markdown
/create-skill <skill-name>
```

This invokes the `create-skill` skill defined in `.harmony/skills/create-skill/`.

---

## Choose Your Archetype First

**Reference files are optional for Atomic skills.** Before creating a skill, choose the appropriate archetype based on complexity:

| Archetype | Structure | When to Use |
|-----------|-----------|-------------|
| **Atomic** | `SKILL.md` + optional refs | Single-purpose, stateless skills (e.g., `format-json`, `validate-schema`, `extract-keywords`) |
| **Complex** | `SKILL.md` + `references/` | Coordinates concerns, maintains state, multi-phase (e.g., `refine-prompt`, `audit-compliance`) |

> **Domain-Oriented Skills:** For Complex skills in specialized domains (finance, legal, security), add optional files: `errors.md`, `glossary.md`, `<domain>.md`. See [Reference Artifacts](./reference-artifacts.md).

### Atomic Skills

Single-purpose skills with clear I/O. Reference files are optional—add them when they reduce agent confusion.

```
my-atomic-skill/
├── SKILL.md              # Core instructions (required)
└── references/           # Optional — add files as needed
    ├── examples.md       # When output format needs demonstration
    ├── errors.md         # When complex failure modes exist
    └── glossary.md       # When domain terminology needs definition
```

**When to use Atomic archetype:**

- Skill does one discrete action
- Obvious inputs and outputs (1-2 inputs, 1 output)
- Stateless — no internal phase management
- Output format is self-explanatory (or can be clarified with examples)

**Optional reference files:**

| File | When to Add | Threshold |
|------|-------------|-----------|
| `examples.md` | Output format needs demonstration | >3 example cases needed |
| `errors.md` | Complex failure modes or external dependencies | >30 lines of error handling |
| `glossary.md` | Domain-specific terminology | >5 terms needing definition |

**Upgrade to Complex when:** The skill coordinates multiple concerns, maintains state across phases, or requires documented phase transitions.

**You still need to:** Add entries to `manifest.yml` and `registry.yml` for discovery.

See [Reference Artifacts](./reference-artifacts.md) for the full archetype decision matrix.

### Validation Expectations

Each archetype has different validation expectations:

- **Atomic:** Include inline success criteria in SKILL.md (e.g., "Success: output is valid JSON"). If the skill includes `examples.md`, those examples serve as additional test cases.
- **Complex:** Formal `validation.md` with acceptance criteria for each phase

See [Reference Artifacts](./reference-artifacts.md#validation-expectations-by-archetype) for details.

---

## Creation Phases

The `create-skill` skill executes these phases:

| Phase | Purpose |
|-------|---------|
| **Validate Name** | Check format (kebab-case), action-oriented naming, uniqueness |
| **Copy Template** | Copy `_template/` to `.harmony/skills/<skill-name>/` |
| **Initialize** | Update placeholders with skill name, display name, description |
| **Update Manifest** | Add entry to `manifest.yml` (Tier 1 discovery) |
| **Update Registry** | Add entry to `registry.yml` (extended metadata) |
| **Create Symlinks** | Link skill to host adapter directories (`.claude/`, `.cursor/`, `.codex/`) |
| **Report** | Confirm success and show next steps |

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

After creation completes, customize based on your chosen archetype.

### 1. Edit `SKILL.md`

**For Atomic skills,** add:

- Description of what the skill does
- When to use it (trigger conditions)
- Parameters and their defaults
- Output format specification
- Inline success criteria (e.g., "Success: output is valid JSON")

**For Complex skills,** add:

- Description of what the skill does
- When to use it (trigger conditions)
- Core execution phases (high-level overview)
- Parameters and their defaults
- Output locations
- Boundaries and constraints
- Escalation conditions

### 2. Edit Reference Files

Reference file requirements depend on your chosen archetype:

**Atomic archetype:** Reference files are optional. Add them only when they reduce agent confusion:

| File | When to Add |
|------|-------------|
| `examples.md` | Output format needs demonstration (>3 example cases) |
| `errors.md` | Complex failure modes or external dependencies (>30 lines) |
| `glossary.md` | Domain-specific terminology (>5 terms) |

If no reference files are needed, delete the empty `references/` directory if created.

**Complex archetype:** Customize all five core reference files in `references/`:

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
    display_name: Your Skill Name
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
      context:
        - type: directory_exists
          path: ".workspace/"
          description: "Requires a workspace directory"
    depends_on: []
```

> **Note:** Tool permissions are defined in SKILL.md frontmatter via `allowed-tools`, not in registry.yml. See [Specification](./specification.md#tool-permissions-single-source-of-truth) for details.

### 5. Add Workspace Mappings

If the skill needs workspace-specific I/O paths, add them to `.workspace/skills/registry.yml`:

```yaml
skill_mappings:
  your-skill-name:
    inputs:
      - path: "resources/your-skill-name/input/"
        kind: directory
        required: true
        description: "Source folder for skill input"
    outputs:
      - path: "../../your-category/{{name}}.md"
        kind: file
        format: markdown
        determinism: stable
        description: "Skill output document"
```

**Note:** All `.workspace/skills/` categories follow the `{{category}}/{{skill-id}}/` pattern. See [Design Conventions](./design-conventions.md#workspace-skills-directory-structure) for details.

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
- [ ] Run log created in `logs/{{skill-id}}/{{run-id}}.md`
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
