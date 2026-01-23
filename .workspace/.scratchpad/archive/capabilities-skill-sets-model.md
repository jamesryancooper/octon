# Capabilities + Skill Sets Model

## Overview

Skills are defined by **capabilities** (what they can do) and **skill sets** (pre-defined capability bundles). This model introduces a clean conceptual distinction:

| Concept | Applies to | Describes |
|---------|------------|-----------|
| **Capabilities** | Skills | What it *can do* (potential, affordance) |

A skill is a specification—it defines capabilities.

---

## Capabilities (Granular)

All capabilities use adjective or present-participle forms that describe the skill:

```yaml
capabilities:
  # Execution
  - phased              # Has distinct execution phases
  - branching           # Has conditional execution paths
  - parallel            # Can execute work concurrently

  # Coordination
  - task-coordinating   # Manages external tasks/jobs
  - agent-delegating    # Delegates to autonomous sub-agents
  - human-collaborative # Requires human decisions

  # State
  - stateful            # Persists state across phases
  - resumable           # Can checkpoint and resume

  # Quality
  - self-validating     # Has formal acceptance criteria
  - error-resilient     # Has recovery procedures

  # Integration
  - composable          # Designed for chaining
  - contract-driven     # Formal I/O specification

  # Scope
  - domain-specialized  # Requires domain knowledge
  - safety-bounded      # Explicit constraints

  # Reliability
  - idempotent          # Safe to retry; same input = same effect
  - cancellable         # Can be stopped mid-execution
  - external-dependent  # Requires external services (APIs, DBs)
```

---

## Skill Sets (Capability Bundles)

Pre-defined groupings for coherence. Skill sets provide sensible defaults; capabilities allow fine-tuning.

| Skill Set | Description | Bundled Capabilities | Primary Refs |
|-----------|-------------|---------------------|--------------|
| `executor` | Does multi-step work itself | `phased`, `branching`, `stateful` | `phases.md`, `decisions.md`, `checkpoints.md` |
| `coordinator` | Manages external tasks/jobs | `task-coordinating`, `parallel` | `orchestration.md` |
| `delegator` | Delegates to autonomous sub-agents | `agent-delegating` | `agents.md` |
| `collaborator` | Works with humans at decision points | `human-collaborative`, `stateful` | `interaction.md`, `checkpoints.md` |
| `integrator` | Pipeline building block | `composable`, `contract-driven` | `composition.md`, `io-contract.md` |
| `specialist` | Requires domain expertise | `domain-specialized` | `glossary.md` |
| `guardian` | Enforces quality and safety | `self-validating`, `safety-bounded` | `validation.md`, `safety.md` |

### Skill Set Definitions (YAML)

```yaml
skill_sets:
  executor:
    description: Does multi-step work itself
    capabilities: [phased, branching, stateful]
    primary_refs: [phases.md, decisions.md, checkpoints.md]

  coordinator:
    description: Manages external tasks/jobs
    capabilities: [task-coordinating, parallel]
    primary_refs: [orchestration.md]

  delegator:
    description: Delegates to autonomous sub-agents
    capabilities: [agent-delegating]
    primary_refs: [agents.md]

  collaborator:
    description: Works with humans at decision points
    capabilities: [human-collaborative, stateful]
    primary_refs: [interaction.md, checkpoints.md]

  integrator:
    description: Pipeline building block
    capabilities: [composable, contract-driven]
    primary_refs: [composition.md, io-contract.md]

  specialist:
    description: Requires domain expertise
    capabilities: [domain-specialized]
    primary_refs: [glossary.md]

  guardian:
    description: Enforces quality and safety
    capabilities: [self-validating, safety-bounded]
    primary_refs: [validation.md, safety.md]
```

---

## Capability-to-Reference Mapping

Each capability maps to specific reference files:

| Capability | Reference File(s) |
|------------|-------------------|
| `phased` | `phases.md` |
| `branching` | `decisions.md` |
| `parallel` | `orchestration.md` |
| `task-coordinating` | `orchestration.md` |
| `agent-delegating` | `agents.md` |
| `human-collaborative` | `interaction.md` |
| `stateful` | `checkpoints.md` |
| `resumable` | `checkpoints.md` |
| `self-validating` | `validation.md` |
| `error-resilient` | `errors.md` |
| `composable` | `composition.md` |
| `contract-driven` | `io-contract.md` |
| `domain-specialized` | `glossary.md`, `<domain>.md` |
| `safety-bounded` | `safety.md` |
| `idempotent` | `idempotency.md` |
| `cancellable` | `cancellation.md` |
| `external-dependent` | `dependencies.md` |

---

## Declaration Syntax

Skills declare skill sets and additional capabilities. The model is **additive**—skill sets provide base capabilities, explicit capabilities add more.

```yaml
# In manifest.yml entry or SKILL.md frontmatter
skill_sets: [executor, guardian]      # Base capability bundles
capabilities: [resumable]             # Additional capabilities
```

---

## Resolution Rules

### 1. Capabilities are resolved as a set (deduplicated)

```yaml
# Declaration
skill_sets: [executor, collaborator]
capabilities: [resumable]

# Resolution process
# 1. Expand skill sets:
#    executor     → {phased, branching, stateful}
#    collaborator → {human-collaborative, stateful}
# 2. Union all:
#    {phased, branching, stateful, human-collaborative, stateful}
# 3. Deduplicate:
#    {phased, branching, stateful, human-collaborative}
# 4. Add explicit capabilities:
#    {phased, branching, stateful, human-collaborative, resumable}

# Resolved
resolved_capabilities: [phased, branching, stateful, human-collaborative, resumable]
```

### 2. Reference files are derived from resolved capabilities

```yaml
# From resolved_capabilities above:
required_refs:
  - phases.md      # ← phased
  - decisions.md      # ← branching
  - checkpoints.md    # ← stateful, resumable (deduplicated)
  - interaction.md    # ← human-collaborative
```

### 3. No subtraction—use direct declaration instead

If a skill set doesn't fit, don't use it. Declare capabilities directly:

```yaml
# Instead of "executor minus branching"
skill_sets: []
capabilities: [phased, stateful]
```

---

## Discovery Patterns

| Query Type | Use When | Example |
|------------|----------|---------|
| **By skill set** | Coarse discovery, finding skills of a "type" | "Find all `coordinator` skills" |
| **By capability** | Fine-grained discovery, specific needs | "Find skills that are `composable`" |
| **By resolved** | Validation, dependency checking | "Does this skill have `stateful`?" |

**Guidance:**

- Use **skill set queries** for browsing and categorization
- Use **capability queries** for composition and integration checks
- Use **resolved capabilities** for validation (never query raw declarations)

---

## Schema

```yaml
# In manifest.yml entry
- id: refactor
  display_name: Refactor
  path: refactor/
  summary: "Execute verified codebase refactor with exhaustive audit."
  status: active

  # Capability model fields
  skill_sets: [executor, guardian]
  capabilities: [resumable]

  # Computed at validation time (optional in manifest, required in resolved view)
  resolved_capabilities: [phased, branching, stateful, self-validating, safety-bounded, resumable]

  # Existing fields
  tags: [refactor, codebase, verification]
  triggers:
    - "refactor this"
    - "rename across codebase"
```

---

## Complete Examples

### refactor

Multi-phase workflow with quality gates

```yaml
skill_sets: [executor, guardian]
capabilities: [resumable]
resolved_capabilities: [phased, branching, stateful, resumable, self-validating, safety-bounded]
```

### refine-prompt

Interactive refinement loop

```yaml
skill_sets: [executor, collaborator]
capabilities: []
resolved_capabilities: [phased, branching, stateful, human-collaborative]
```

### build-and-deploy

Coordinates build, test, deploy tasks

```yaml
skill_sets: [coordinator, guardian]
capabilities: [error-resilient]
resolved_capabilities: [task-coordinating, parallel, self-validating, safety-bounded, error-resilient]
```

### research-deep

Spawns research agents

```yaml
skill_sets: [delegator, executor]
capabilities: []
resolved_capabilities: [agent-delegating, phased, branching, stateful]
```

### audit-compliance

Domain-specific workflow

```yaml
skill_sets: [executor, specialist, guardian]
capabilities: []
resolved_capabilities: [phased, branching, stateful, domain-specialized, self-validating, safety-bounded]
```

### extract-entities

Composable pipeline component

```yaml
skill_sets: [integrator]
capabilities: [self-validating]
resolved_capabilities: [composable, contract-driven, self-validating]
```

### format-json

Atomic, composable utility

```yaml
skill_sets: []
capabilities: [composable]
resolved_capabilities: [composable]
```

### count-tokens

Atomic, minimal

```yaml
skill_sets: []
capabilities: []
resolved_capabilities: []
```

---

## Validation Rules

1. **Declared capabilities must be valid** — reject unknown capability names
2. **Declared skill sets must be valid** — reject unknown skill set names
3. **Resolved capabilities should have reference files** — warn if `stateful` declared but no `checkpoints.md`
4. **Reference files should map to capabilities** — warn if `checkpoints.md` exists but `stateful`/`resumable` not in resolved capabilities

---

## Migration from Two-Tiered Model

| Old Model | New Model |
|-----------|-----------|
| `archetype: atomic` | `skill_sets: []` with minimal capabilities |
| `archetype: complex` | One or more skill sets based on exhibited patterns |
| Pattern-triggered files | Derived from resolved capabilities |
| Common Profiles | Replaced by skill set combinations |

### Profile to Skill Set Mapping

| Old Profile | New Skill Sets |
|-------------|----------------|
| Workflow Skill | `[executor]` or `[executor, guardian]` |
| Coordinator Skill | `[coordinator]` or `[coordinator, guardian]` |
| Interactive Skill | `[executor, collaborator]` |
| Domain Expert Skill | `[executor, specialist, guardian]` |
| Pipeline Component | `[integrator]` |

---

## Design Rationale

### Why Capabilities + Skill Sets

1. **Conceptual clarity** — Capabilities describe skills (potential);
2. **Flexibility** — Granular capabilities allow precise customization
3. **Coherence** — Skill sets provide sensible bundles, reducing decision fatigue
4. **Composability** — Multiple skill sets combine naturally without hierarchy
5. **Discoverability** — Query by skill set (coarse) or capability (fine)
6. **Progressive** — Atomic skills are simply empty declarations; complexity emerges from additions

### Why Additive Only

Subtraction creates ambiguity ("executor minus branching"—is that still an executor?). The additive model is simpler:

- If a skill set fits, use it
- If it doesn't fit exactly, declare capabilities directly
- Explicit is better than implicit

### Why Deduplicated Sets

Multiple skill sets may include the same capability (e.g., `stateful` in both `executor` and `collaborator`). Treating resolved capabilities as a set:

- Avoids double-counting in token budgets
- Simplifies validation logic
- Matches intuition (a skill either has a capability or doesn't)
