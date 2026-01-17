---
title: Workspace Skills
description: Two-tier, hierarchical workspace skills system (shared definitions + workspace-specific I/O) aligned with the agentskills.io specification.
---

# Workspace Skills

Skills are **composable capability units** defined by the [agentskills.io](https://agentskills.io) specification. In Harmony, they use a **two-tier hierarchical architecture**: portable, shared skill definitions live in `.harmony/skills/`, while workspace-specific I/O and execution configuration live in `.workspace/skills/`.

---

## Workspace Model

A `.workspace/` directory designates its parent as a **workspace root**. Workspaces can be nested, creating a hierarchy where parent workspaces have authority over descendants.

```markdown
repo/                          ← Root workspace
├── .workspace/
├── docs/                      ← Docs workspace (nested)
│   └── .workspace/
└── packages/kits/             ← Kits workspace (nested)
    ├── .workspace/
    └── flowkit/               ← FlowKit workspace (nested)
        └── .workspace/
```

**Hierarchical authority:**

- Workspaces can write **down** into descendant workspaces
- Workspaces cannot write **up** into ancestors or **sideways** into siblings
- Default output: `.workspace/skills/outputs/` (no declaration needed)
- Custom paths: declared in registry, validated against scope

See [Architecture](./architecture.md) for the complete model.

---

## What is a Skill

Per the [agentskills.io specification](https://agentskills.io/what-are-skills), a skill is a folder containing a `SKILL.md` file with metadata and instructions that tell agents how to perform specific tasks. Skills provide:

- **Procedural knowledge** — Step-by-step instructions for complex tasks
- **Defined I/O contracts** — Clear inputs, outputs, and dependencies
- **Progressive disclosure** — Metadata for routing, full instructions on demand
- **Auditable execution** — Run logs for every invocation
- **Portability** — Skills are just files, easy to edit, version, and share

---

## Documentation Structure

This documentation is organized into the following sections:

| Document                                       | Description                                                           |
|------------------------------------------------|-----------------------------------------------------------------------|
| [Architecture](./architecture.md)              | Hierarchical workspace model, scope authority, progressive disclosure |
| [Skill Format](./skill-format.md)              | SKILL.md structure, naming conventions, frontmatter                   |
| [Reference Artifacts](./reference-artifacts.md)| Reference file system, universal vs. customizable files               |
| [Discovery](./discovery.md)                    | Manifest and registry formats for skill discovery                     |
| [Creation](./creation.md)                      | Creating new skills, workflow steps, post-creation tasks              |
| [Invocation](./invocation.md)                  | Commands, triggers, routing rules                                     |
| [Execution](./execution.md)                    | Run logging, safety policies                                          |
| [Comparison](./comparison.md)                  | Skills vs. other primitives, decision heuristics                      |
| [Specification](./specification.md)            | Spec compliance, extensions, validation                               |

---

## Quick Start

### Using a Skill

```markdown
/refine-prompt "add caching to the api"
```

### Creating a Skill

```markdown
/create-skill <skill-name>
```

See [Creation](./creation.md) for the full workflow.

---

## Key Locations

| Location                             | Purpose                               |
|--------------------------------------|---------------------------------------|
| `.harmony/skills/`                   | Shared skill definitions (portable)   |
| `.harmony/skills/manifest.yml`       | Skill discovery index (id, display_name, summary, triggers) |
| `.harmony/skills/registry.yml`       | Extended metadata (version, commands, parameters) |
| `.harmony/skills/_template/`         | Scaffolding for new skills            |
| `.harmony/skills/scripts/validate-skills.sh` | Drift detection validation script |
| `.workspace/skills/`                 | Workspace-specific I/O configuration  |
| `.workspace/skills/manifest.yml`     | Workspace-specific skill index        |
| `.workspace/skills/registry.yml`     | Workspace I/O mappings                |
| `.workspace/skills/outputs/`         | Skill-generated files                 |
| `.workspace/skills/logs/runs/`       | Execution audit logs                  |

---

## See Also

### External Resources

- [agentskills.io](https://agentskills.io) — Official specification
- [agentskills.io/specification](https://agentskills.io/specification) — Full format specification
- [agentskills.io/integrate-skills](https://agentskills.io/integrate-skills) — Agent integration guide

### Internal Resources

- `.harmony/skills/refine-prompt/` — Example skill implementation
- `.harmony/skills/_template/` — Skill template
- `.harmony/workflows/skills/create-skill/` — Skill creation workflow

### Related Documentation

- [Assistants](../assistants.md) — Focused specialists
- [Workflows](../workflows.md) — Multi-step procedures
- [Taxonomy](../taxonomy.md) — Artifact type classification
