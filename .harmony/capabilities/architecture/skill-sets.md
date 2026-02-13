# Skill Sets Reference

Skill sets are pre-defined **capability bundles** that provide sensible defaults for common skill patterns. Instead of declaring individual capabilities, skills can declare skill sets to get a coherent set of capabilities.

## Available Skill Sets

### executor

**Description:** Does multi-step work itself

**Bundled Capabilities:**
- `phased` — Has distinct execution phases
- `branching` — Has conditional execution paths
- `stateful` — Persists state across phases

**Primary Reference Files:**
- `phases.md`
- `decisions.md`
- `checkpoints.md`

**Use When:** The skill performs multi-phase work with internal state and decision points.

---

### coordinator

**Description:** Manages external tasks/jobs

**Bundled Capabilities:**
- `task-coordinating` — Manages external tasks/jobs
- `parallel` — Can execute work concurrently

**Primary Reference Files:**
- `orchestration.md`

**Use When:** The skill orchestrates external tasks, jobs, or processes.

---

### delegator

**Description:** Delegates to autonomous sub-agents

**Bundled Capabilities:**
- `agent-delegating` — Delegates to autonomous sub-agents

**Primary Reference Files:**
- `agents.md`

**Use When:** The skill spawns or coordinates sub-agents to perform work.

---

### collaborator

**Description:** Works with humans at decision points

**Bundled Capabilities:**
- `human-collaborative` — Requires human decisions
- `stateful` — Persists state across phases

**Primary Reference Files:**
- `interaction.md`
- `checkpoints.md`

**Use When:** The skill requires human input, approval, or decisions during execution.

---

### integrator

**Description:** Pipeline building block

**Bundled Capabilities:**
- `composable` — Designed for chaining
- `contract-driven` — Formal I/O specification

**Primary Reference Files:**
- `composition.md`
- `io-contract.md`

**Use When:** The skill is designed to be composed with other skills in pipelines.

---

### specialist

**Description:** Requires domain expertise

**Bundled Capabilities:**
- `domain-specialized` — Requires domain knowledge

**Primary Reference Files:**
- `glossary.md`

**Use When:** The skill operates in a specialized domain requiring terminology or expertise.

---

### guardian

**Description:** Enforces quality and safety

**Bundled Capabilities:**
- `self-validating` — Has formal acceptance criteria
- `safety-bounded` — Explicit constraints

**Primary Reference Files:**
- `validation.md`
- `safety.md`

**Use When:** The skill has quality gates, safety constraints, or validation requirements.

---

## Common Combinations

| Pattern | Skill Sets | Description |
|---------|------------|-------------|
| Standard workflow | `[executor]` | Multi-phase skill with state |
| Interactive workflow | `[executor, collaborator]` | Multi-phase with human checkpoints |
| Verified workflow | `[executor, guardian]` | Multi-phase with quality gates |
| Domain workflow | `[executor, specialist, guardian]` | Multi-phase with domain expertise and quality |
| Pipeline component | `[integrator]` | Building block for composition |
| Agent orchestrator | `[delegator, executor]` | Spawns agents with phased coordination |
| Task orchestrator | `[coordinator, guardian]` | Manages tasks with quality checks |

---

## Skill Set Resolution

Skill sets expand to their bundled capabilities, then merge with explicit capabilities:

```yaml
# Declaration
skill_sets: [executor, collaborator]
capabilities: [resumable]

# Resolution process:
# 1. Expand skill sets:
#    executor     → {phased, branching, stateful}
#    collaborator → {human-collaborative, stateful}
#
# 2. Union all (deduplicate):
#    {phased, branching, stateful, human-collaborative}
#
# 3. Add explicit capabilities:
#    {phased, branching, stateful, human-collaborative, resumable}

# Resolved capabilities
resolved_capabilities:
  - phased
  - branching
  - stateful
  - human-collaborative
  - resumable
```

---

## Skill Set Definitions (YAML)

The complete skill set definitions as stored in `capabilities.yml`:

```yaml
skill_set_definitions:
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

## Choosing Skill Sets vs Direct Capabilities

**Use skill sets when:**
- The skill clearly fits a common pattern
- You want sensible capability defaults
- Readability matters (skill sets are more descriptive)

**Use direct capabilities when:**
- The skill doesn't fit existing skill set patterns
- You need fine-grained control over capabilities
- The skill has unusual capability combinations

**You can use both:**
```yaml
# Use executor skill set, add resumable capability
skill_sets: [executor]
capabilities: [resumable]
```

---

## No Subtraction

The capability model is **additive only**. If a skill set includes capabilities you don't want, don't use that skill set — declare capabilities directly instead.

```yaml
# Don't try to "subtract" from executor
# Instead, declare exactly what you need:
skill_sets: []
capabilities: [phased, stateful]  # Executor minus branching
```

This keeps the model simple: skill sets always expand, capabilities always add.
