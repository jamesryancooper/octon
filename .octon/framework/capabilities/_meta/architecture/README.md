---
title: Harness Skills
description: Capability-driven harness skills system with progressive disclosure (manifest → registry → SKILL.md → references/).
---

# Harness Skills

Skills are **composable capability units** defined by the [agentskills.io](https://agentskills.io) specification. In Octon, they use a **progressive disclosure architecture**: all skill artifacts live in `.octon/framework/capabilities/runtime/skills/`, with layered discovery from compact metadata (manifest) through full definitions (SKILL.md) to deep reference material (references/).

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

### Alignment-First Policy

New skills must align to existing Octon skill contracts first.

- Reuse existing `skill_sets`, `capabilities`, reference mappings, and `allowed-tools` vocabulary.
- Do not introduce ad hoc schema changes while implementing a skill.
- If current contracts are insufficient, create a spec extension proposal and update docs/templates/validation together.

See [Alignment Policy](./alignment-policy.md).

---

## Harness Model

Octon uses one repo-root `.octon/` directory per repository.

```markdown
repo/
└── .octon/
```

**Repo-root authority:**

- Skills and workflows resolve the single repo-root `.octon/` on the current ancestor chain
- If more than one `.octon/` exists on that chain, resolution fails because exactly one repo-root harness is allowed
- Writes stay within the repository root and declared output locations
- Deliverables go to `.octon/{{category}}/` (final destination)
- Execution state goes to `.octon/state/control/skills/checkpoints/{{skill-id}}/{{run-id}}/`

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
| [Architecture](./architecture.md) | Single-root harness model, scope authority, progressive disclosure |
| [Capabilities](./capabilities.md) | All 20 capabilities with reference file mapping |
| [Skill Sets](./skill-sets.md) | Pre-defined capability bundles and common combinations |
| [Declaration](./declaration.md) | How to declare capabilities, resolution rules |
| [Validation](./validation.md) | Validation rules for capabilities and references |
| [Alignment Policy](./alignment-policy.md) | Alignment-first implementation policy and extension process |
| [Reference Artifacts](./reference-artifacts.md) | Reference files organized by capability |
| [Skill Format](./skill-format.md) | SKILL.md structure, naming conventions, frontmatter |
| [Discovery](./discovery.md) | Manifest and registry formats for skill discovery |
| [Creation](./creation.md) | Creating new skills with capabilities |
| [Invocation](./invocation.md) | Commands, triggers, routing rules |
| [Execution](./execution.md) | Run logging, safety policies |
| [Harness Resolution](./harness-resolution.md) | Repo-root resolution model |
| [Design Conventions](../../practices/design-conventions.md) | Cross-cutting patterns |
| [Comparison](./comparison.md) | Skills vs. other primitives |
| [Specification](./specification.md) | Spec compliance, extensions |
| [Migration Guide](./migration-guide.md) | Migrating from archetype model |

Conventions placement: canonical naming and authoring conventions are defined in
`../../practices/design-conventions.md`.

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
| `.octon/framework/capabilities/runtime/skills/` | Skill definitions and operational state |
| `.octon/framework/capabilities/runtime/skills/manifest.yml` | Skill index with capabilities (Tier 1 discovery) |
| `.octon/framework/capabilities/runtime/skills/capabilities.yml` | Skill sets, valid capabilities, refs |
| `.octon/framework/capabilities/runtime/skills/registry.yml` | Extended metadata, I/O mappings, composition (Tier 2) |
| `.octon/framework/capabilities/runtime/skills/<skill-id>/SKILL.md` | Full skill definition (Tier 3) |
| `.octon/framework/capabilities/runtime/skills/<skill-id>/references/` | Phase details, safety, validation (Tier 4) |
| `.octon/framework/capabilities/runtime/skills/_scaffold/template/` | Scaffolding for new skills |
| `.octon/framework/capabilities/runtime/skills/_ops/scripts/validate-skills.sh` | Capability validation script |
| `.octon/state/control/skills/checkpoints/{{skill-id}}/` | Execution state (checkpoints) |
| `.octon/state/evidence/runs/skills/{{skill-id}}/` | Skill-specific logs |
| `.octon/{{category}}/` | Deliverables (prompts, drafts, etc.) |

---

## See Also

### External Resources

- [agentskills.io](https://agentskills.io) — Official specification
- [agentskills.io/specification](https://agentskills.io/specification) — Full format specification

### Internal Resources

- `.octon/framework/capabilities/runtime/skills/refactor/refactor/` — Example skill with `[executor, guardian]` skill sets
- `.octon/framework/capabilities/runtime/skills/synthesis/refine-prompt/` — Example skill with `[executor, collaborator]` skill sets
- `.octon/framework/capabilities/runtime/skills/_scaffold/template/` — Skill template with capability guidance

### Related Documentation

- [Agency](../../../agency/README.md) — Canonical actor taxonomy and assistant role
- [Workflows](../../../orchestration/README.md) — Multi-step procedures
- [Taxonomy](../../../cognition/_meta/architecture/taxonomy.md) — Artifact type classification
