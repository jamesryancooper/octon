---
title: Workspace Skills
description: Capability-driven workspace skills system with two-tier architecture (shared definitions + workspace-specific I/O).
---

# Workspace Skills

Skills are **composable capability units** defined by the [agentskills.io](https://agentskills.io) specification. In Harmony, they use a **two-tier hierarchical architecture**: portable, shared skill definitions live in `.harmony/capabilities/skills/`, while workspace-specific I/O and execution configuration live in `.harmony/capabilities/skills/`.

Skills declare their **capabilities** (what they can do) and **skill sets** (capability bundles), which determine their documentation requirements and discovery patterns.

---

## Quick Reference

| Concept | Description |
|---------|-------------|
| **Capability** | What a skill can do (e.g., `phased`, `stateful`, `composable`) |
| **Skill Set** | Pre-defined capability bundle (e.g., `executor`, `guardian`) |
| **Reference File** | Documentation required by a capability |

### Skill Sets

| Skill Set | Capabilities | Use When |
|-----------|--------------|----------|
| `executor` | phased, branching, stateful | Multi-step workflow |
| `coordinator` | task-coordinating, parallel | Manages external tasks |
| `delegator` | agent-delegating | Spawns sub-agents |
| `collaborator` | human-collaborative, stateful | Requires human input |
| `integrator` | composable, contract-driven | Pipeline building block |
| `specialist` | domain-specialized | Requires domain expertise |
| `guardian` | self-validating, safety-bounded | Has quality gates |

See [Skill Sets](./skill-sets.md) and [Capabilities](./capabilities.md) for complete reference.

---

## Workspace Model

A `.harmony/` directory designates its parent as a **workspace root**. Workspaces can be nested, creating a hierarchy where parent workspaces have authority over descendants.

```markdown
repo/                          ← Root workspace
├── .harmony/
├── docs/                      ← Docs workspace (nested)
│   └── .harmony/
└── packages/kits/             ← Kits workspace (nested)
    ├── .harmony/
    └── flowkit/               ← FlowKit workspace (nested)
        └── .harmony/
```

**Hierarchical authority:**

- Workspaces can write **down** into descendant workspaces
- Workspaces cannot write **up** into ancestors or **sideways** into siblings
- Deliverables go to `.harmony/{{category}}/` (final destination)
- Execution state goes to `.harmony/capabilities/skills/runs/{{skill-id}}/{{run-id}}/`

See [Architecture](./architecture.md) for the complete model.

---

## What is a Skill

Per the [agentskills.io specification](https://agentskills.io/what-are-skills), a skill is a folder containing a `SKILL.md` file with metadata and instructions that tell agents how to perform specific tasks. Skills provide:

- **Procedural knowledge** — Step-by-step instructions for complex tasks
- **Defined I/O contracts** — Clear inputs, outputs, and dependencies
- **Progressive disclosure** — Metadata for routing, full instructions on demand
- **Auditable execution** — Run logs for every invocation
- **Portability** — Skills are just files, easy to edit, version, and share
- **Capability declaration** — What the skill can do, driving documentation requirements

---

## Documentation Structure

| Document | Description |
|----------|-------------|
| [Architecture](./architecture.md) | Hierarchical workspace model, scope authority, progressive disclosure |
| [Capabilities](./capabilities.md) | All 17 capabilities with reference file mapping |
| [Skill Sets](./skill-sets.md) | Pre-defined capability bundles and common combinations |
| [Declaration](./declaration.md) | How to declare capabilities, resolution rules |
| [Validation](./validation.md) | Validation rules for capabilities and references |
| [Reference Artifacts](./reference-artifacts.md) | Reference files organized by capability |
| [Skill Format](./skill-format.md) | SKILL.md structure, naming conventions, frontmatter |
| [Discovery](./discovery.md) | Manifest and registry formats for skill discovery |
| [Creation](./creation.md) | Creating new skills with capabilities |
| [Invocation](./invocation.md) | Commands, triggers, routing rules |
| [Execution](./execution.md) | Run logging, safety policies |
| [Workspace Resolution](./workspace-resolution.md) | Nearest ancestor model |
| [Design Conventions](./design-conventions.md) | Cross-cutting patterns |
| [Comparison](./comparison.md) | Skills vs. other primitives |
| [Specification](./specification.md) | Spec compliance, extensions |
| [Migration Guide](./migration-guide.md) | Migrating from archetype model |

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

| Location | Purpose |
|----------|---------|
| `.harmony/capabilities/skills/` | Shared skill definitions (portable) |
| `.harmony/capabilities/skills/manifest.yml` | Skill index with capabilities |
| `.harmony/capabilities/skills/registry.yml` | Extended metadata + skill set definitions |
| `.harmony/capabilities/skills/_template/` | Scaffolding for new skills |
| `.harmony/capabilities/skills/scripts/validate-skills.sh` | Capability validation script |
| `.harmony/capabilities/skills/` | Workspace-specific I/O configuration |
| `.harmony/capabilities/skills/manifest.yml` | Workspace-specific skill index |
| `.harmony/capabilities/skills/registry.yml` | Workspace I/O mappings |
| `.harmony/capabilities/skills/runs/{{skill-id}}/` | Execution state (checkpoints) |
| `.harmony/capabilities/skills/logs/{{skill-id}}/` | Skill-specific logs |
| `.harmony/{{category}}/` | Deliverables (prompts, drafts, etc.) |

---

## See Also

### External Resources

- [agentskills.io](https://agentskills.io) — Official specification
- [agentskills.io/specification](https://agentskills.io/specification) — Full format specification

### Internal Resources

- `.harmony/capabilities/skills/refactor/` — Example skill with `[executor, guardian]` skill sets
- `.harmony/capabilities/skills/refine-prompt/` — Example skill with `[executor, collaborator]` skill sets
- `.harmony/capabilities/skills/_template/` — Skill template with capability guidance

### Related Documentation

- [Assistants](../assistants.md) — Focused specialists
- [Workflows](../workflows.md) — Multi-step procedures
- [Taxonomy](../taxonomy.md) — Artifact type classification
