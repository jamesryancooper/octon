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

This invokes the `create-skill` skill defined in `.harmony/capabilities/skills/meta/create-skill/`.

---

## Alignment-First Gate (Mandatory)

Before defining a new skill, run this decision gate:

1. **Align first:** Model behavior with existing `skill_sets`, `capabilities`, reference artifact mappings, and `allowed-tools` vocabulary.
2. **No ad hoc schema:** Do not invent new capability names, reference file types, or metadata fields during implementation.
3. **Escalate only by proposal:** If alignment is not possible, stop and prepare a **Spec Extension Proposal** before implementation.

A Spec Extension Proposal must include:

- Why current contracts are insufficient
- Proposed contract delta
- Required updates across `capabilities.yml`, docs, templates, and validation
- Migration impact on existing skills (if any)

See [Alignment Policy](./alignment-policy.md) for policy details.

---

## Choose Your Capabilities

**Reference files are driven by capabilities.** Before creating a skill, identify what capabilities it needs:

### Step 1: Choose Skill Sets

Skill sets are pre-defined capability bundles. Choose those that match your skill's pattern:

| Skill Set | Use When | Bundled Capabilities |
|-----------|----------|---------------------|
| `executor` | Multi-step work with phases | phased, branching, stateful |
| `coordinator` | Manages external tasks/jobs | task-coordinating, parallel |
| `delegator` | Spawns sub-agents | agent-delegating |
| `collaborator` | Requires human decisions | human-collaborative, stateful |
| `integrator` | Pipeline building block | composable, contract-driven |
| `specialist` | Requires domain expertise | domain-specialized |
| `guardian` | Has quality gates/safety | self-validating, safety-bounded |

### Step 2: Add Extra Capabilities

Add individual capabilities for specific needs beyond skill sets:

| Capability | When to Add |
|------------|-------------|
| `resumable` | Can checkpoint and resume after interruption |
| `error-resilient` | Has complex error recovery procedures |
| `idempotent` | Safe to retry; same input = same effect |
| `cancellable` | Can be stopped mid-execution |
| `external-dependent` | Requires external services |

### Step 3: Confirm Alignment Decision (Required)

Before creating files, record one of:

- `aligned` — existing contracts are sufficient
- `extension-proposed` — spec extension proposal created and approved

If neither can be stated with evidence, stop and clarify scope.

### Step 4: Add Reference Files

Each capability maps to a reference file. Add files for your resolved capabilities:

```
my-skill/
├── SKILL.md              # Core instructions (required)
└── references/           # Capability-driven reference files
    ├── phases.md         # ← phased
    ├── decisions.md      # ← branching
    ├── checkpoints.md    # ← stateful, resumable
    ├── validation.md     # ← self-validating
    ├── safety.md         # ← safety-bounded
    └── examples.md       # ← (optional for any skill)
```

### Common Patterns

**Minimal skill (no capabilities):**
```yaml
skill_sets: []
capabilities: []
# No reference files needed
```

**Standard multi-phase skill:**
```yaml
skill_sets: [executor]
capabilities: []
# Refs: phases.md, decisions.md, checkpoints.md
```

**Multi-phase with quality gates:**
```yaml
skill_sets: [executor, guardian]
capabilities: []
# Refs: phases.md, decisions.md, checkpoints.md, validation.md, safety.md
```

**Pipeline component:**
```yaml
skill_sets: [integrator]
capabilities: []
# Refs: composition.md, io-contract.md
```

See [Capabilities](./capabilities.md) and [Skill Sets](./skill-sets.md) for complete reference.

---

## Creation Phases

The `create-skill` skill executes these phases:

| Phase | Purpose |
|-------|---------|
| **Validate Name** | Check format (kebab-case), action-oriented naming, uniqueness |
| **Copy Template** | Copy `_template/` to `.harmony/capabilities/skills/<group>/<skill-name>/` |
| **Initialize** | Update placeholders with skill name, display name, description |
| **Update Manifest** | Add entry to `manifest.yml` (Tier 1 discovery) |
| **Update Registry** | Add entry to `registry.yml` (extended metadata) |
| **Create Symlinks** | Link skill to host adapter directories (`.claude/`, `.cursor/`, `.codex/`) |
| **Report** | Confirm success and show next steps |

---

## Output Structure

A new skill directory following the agentskills.io spec:

```markdown
.harmony/capabilities/skills/<group>/<skill-name>/
├── SKILL.md              # Core definition (<500 lines)
├── references/           # Progressive disclosure
│   ├── phases.md
│   ├── io-contract.md
│   ├── safety.md
│   ├── examples.md
│   └── validation.md
├── scripts/              # Executable code (optional)
└── assets/               # Static resources (optional)

# Plus symlinks in harness folders:
.claude/skills/<skill-name> -> ../../.harmony/capabilities/skills/<group>/<skill-name>
.cursor/skills/<skill-name> -> ../../.harmony/capabilities/skills/<group>/<skill-name>
.codex/skills/<skill-name> -> ../../.harmony/capabilities/skills/<group>/<skill-name>
```

---

## Post-Creation Steps

After creation completes, customize based on your declared skill_sets and capabilities.

### 1. Edit `SKILL.md`

**For minimal skills,** add:

- Description of what the skill does
- When to use it (trigger conditions)
- Parameters and their defaults
- Output format specification
- Inline success criteria (e.g., "Success: output is valid JSON")

**For phased skills,** add:

- Description of what the skill does
- When to use it (trigger conditions)
- Core execution phases (high-level overview)
- Parameters and their defaults
- Output locations
- Boundaries and constraints
- Escalation conditions

### 2. Edit Reference Files

Reference file requirements depend on your declared skill_sets and capabilities:

**Minimal skills (no phased execution):** Reference files are optional. Add them only when they reduce agent confusion:

| File | When to Add |
|------|-------------|
| `examples.md` | Output format needs demonstration (>3 example cases) |
| `errors.md` | Complex failure modes or external dependencies (>30 lines) |
| `glossary.md` | Domain-specific terminology (>5 terms) |

If no reference files are needed, delete the empty `references/` directory if created.

**Phased skill:** Customize all five core reference files in `references/`:

| File | What to Add |
|------|-------------|
| `io-contract.md` | Input names, types, output paths, command-line usage |
| `safety.md` | Tool permissions, behavioral boundaries |
| `examples.md` | 2-4 worked examples with full output |
| `phases.md` | Phase-by-phase execution details |
| `validation.md` | Acceptance criteria specific to this skill |

See [Reference Artifacts](./reference-artifacts.md) for detailed guidance on each file.

**Note:** Commands and triggers are defined in `manifest.yml` and `registry.yml`, not in reference files.

### 3. Update Shared Manifest

Add the skill to `.harmony/capabilities/skills/manifest.yml` for Tier 1 discovery:

```yaml
skills:
  - id: your-skill-name
    display_name: Your Skill Name
    group: quality-gate
    path: quality-gate/your-skill-name/
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

Add extended metadata to `.harmony/capabilities/skills/registry.yml`:

```yaml
skills:
  your-skill-name:
    version: "1.0.0"
    commands:
      - /your-skill-name
    requires:
      context:
        - type: directory_exists
          path: ".harmony/"
          description: "Requires a harness directory"
    depends_on: []
```

> **Note:** Tool permissions are defined in SKILL.md frontmatter via `allowed-tools`, not in registry.yml. See [Specification](./specification.md#tool-permissions-single-source-of-truth) for details.

### 5. Add Harness Mappings

If the skill needs harness-specific I/O paths, add them to `.harmony/capabilities/skills/registry.yml`:

```yaml
skills:
  your-skill-name:
    io:
      inputs:
        - path: "_state/resources/your-skill-name/input/"
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

**Note:** All `.harmony/capabilities/skills/` categories follow the `{{category}}/{{skill-id}}/` pattern. See [Design Conventions](./design-conventions.md#harness-skills-directory-structure) for details.

**Placeholder Syntax:** Use `{{snake_case}}` for path placeholders (e.g., `{{timestamp}}`, `{{project}}`). See [Placeholder Resolution](./execution.md#placeholder-resolution) for details.

### 6. Create Symlinks

Run the setup script or create symlinks manually:

```bash
# Using setup script
.harmony/capabilities/skills/_scripts/setup-harness-links.sh

# Or manually
ln -s ../../.harmony/capabilities/skills/quality-gate/your-skill-name .claude/skills/your-skill-name
ln -s ../../.harmony/capabilities/skills/quality-gate/your-skill-name .cursor/skills/your-skill-name
ln -s ../../.harmony/capabilities/skills/quality-gate/your-skill-name .codex/skills/your-skill-name
```

### 7. Test

Run the skill with a test input:

```markdown
/your-skill-name "test input"
```

Verify:
- [ ] Output created in expected location
- [ ] Run log created in `_state/logs/{{skill-id}}/{{run-id}}.md`
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
