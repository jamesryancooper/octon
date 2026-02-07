---
title: Reference Artifacts
description: Capability-based reference file system for progressive disclosure in skills.
---

# Reference Artifacts

Reference files in the `references/` directory provide **progressive disclosure** — detailed content loaded only when needed. **Reference files are driven by capabilities** — each capability maps to specific reference files.

**Design Principle:** Keep individual reference files focused. Agents load these on demand, so smaller files mean less context usage.

---

## Capability-to-Reference Mapping

Skills declare capabilities (or skill sets that bundle capabilities). Each capability maps to reference files:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  CAPABILITY-DRIVEN REFERENCE FILES                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Execution Capabilities                                                     │
│  ─────────────────────                                                      │
│  phased              → phases.md                                            │
│  branching           → decisions.md                                         │
│  parallel            → orchestration.md                                     │
│                                                                             │
│  Coordination Capabilities                                                  │
│  ─────────────────────────                                                  │
│  task-coordinating   → orchestration.md                                     │
│  agent-delegating    → agents.md                                            │
│  human-collaborative → interaction.md                                       │
│                                                                             │
│  State Capabilities                                                         │
│  ──────────────────                                                         │
│  stateful            → checkpoints.md                                       │
│  resumable           → checkpoints.md                                       │
│                                                                             │
│  Quality Capabilities                                                       │
│  ────────────────────                                                       │
│  self-validating     → validation.md                                        │
│  error-resilient     → errors.md                                            │
│                                                                             │
│  Integration Capabilities                                                   │
│  ────────────────────────                                                   │
│  composable          → composition.md                                       │
│  contract-driven     → io-contract.md                                       │
│                                                                             │
│  Scope Capabilities                                                         │
│  ──────────────────                                                         │
│  domain-specialized  → glossary.md                                          │
│  safety-bounded      → safety.md                                            │
│                                                                             │
│  Reliability Capabilities                                                   │
│  ────────────────────────                                                   │
│  idempotent          → idempotency.md                                       │
│  cancellable         → cancellation.md                                      │
│  external-dependent  → dependencies.md                                      │
│                                                                             │
│  Optional (Any Skill)                                                       │
│  ────────────────────                                                       │
│  (none required)     → examples.md (when output format needs demonstration) │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Reference File Summary

| File | Required When | Purpose |
|------|---------------|---------|
| `phases.md` | `phased` | Distinct execution phases |
| `decisions.md` | `branching` | Conditional execution paths |
| `orchestration.md` | `task-coordinating`, `parallel` | External task coordination |
| `agents.md` | `agent-delegating` | Sub-agent management |
| `interaction.md` | `human-collaborative` | Human decision points |
| `checkpoints.md` | `stateful`, `resumable` | State management |
| `validation.md` | `self-validating` | Acceptance criteria |
| `errors.md` | `error-resilient` | Recovery procedures |
| `composition.md` | `composable` | Pipeline integration |
| `io-contract.md` | `contract-driven` | Formal I/O specification |
| `glossary.md` | `domain-specialized` | Domain terminology |
| `safety.md` | `safety-bounded` | Safety constraints |
| `idempotency.md` | `idempotent` | Retry semantics |
| `cancellation.md` | `cancellable` | Mid-execution stopping |
| `dependencies.md` | `external-dependent` | External service requirements |
| `examples.md` | (Optional) | Worked examples |

---

## Reference Files by Category

### Execution References

#### phases.md

**Required when capability:** `phased`

Documents distinct execution phases with:
- Phase descriptions and goals
- Step-by-step execution within each phase
- Phase transitions and conditions
- Phase-level success criteria

#### decisions.md

**Required when capability:** `branching`

Documents conditional execution paths:
- Decision points and conditions
- Branching logic trees
- Path-specific behaviors
- Escalation triggers

#### orchestration.md

**Required when capability:** `task-coordinating` or `parallel`

Documents external task coordination:
- Sub-task definitions
- Dependency graphs
- Parallel execution rules
- Failure handling policies

---

### Coordination References

#### agents.md

**Required when capability:** `agent-delegating`

Documents sub-agent management:
- Sub-agent definitions and purposes
- Interface contracts (inputs/outputs)
- Coordination strategy
- Failure handling and recovery

#### interaction.md

**Required when capability:** `human-collaborative`

Documents human interaction points:
- Decision prompts and options
- Approval gates
- Iterative refinement loops
- Timeout and fallback behaviors

---

### State References

#### checkpoints.md

**Required when capability:** `stateful` or `resumable`

Documents state management:
- Checkpoint strategy (phase, step, time-based)
- State schema and fields
- Recovery procedures
- Resume protocol

---

### Quality References

#### validation.md

**Required when capability:** `self-validating`

Documents acceptance criteria:
- Quality checklist
- Validation rules
- Output requirements
- Scope limits

#### errors.md

**Required when capability:** `error-resilient`

Documents error handling:
- Error categories and severity
- Recovery procedures
- Escalation matrix
- Logging requirements

---

### Integration References

#### composition.md

**Required when capability:** `composable`

Documents pipeline integration:
- Composition role (source, transformer, sink)
- Interface contracts
- Chaining compatibility
- Integration hooks

#### io-contract.md

**Required when capability:** `contract-driven`

Documents formal I/O specification:
- Input schema and validation
- Output schema and format
- Parameter reference
- Usage examples

---

### Scope References

#### glossary.md

**Required when capability:** `domain-specialized`

Documents domain terminology:
- Core terms and definitions
- Abbreviations
- Domain concepts
- Related standards

#### safety.md

**Required when capability:** `safety-bounded`

Documents safety constraints:
- Tool policy (deny-by-default)
- File policy and write scope
- Behavioral boundaries
- Escalation triggers

---

### Reliability References

#### idempotency.md

**Required when capability:** `idempotent`

Documents retry semantics:
- Idempotency guarantees
- Safe retry conditions
- Idempotency keys
- State checking

#### cancellation.md

**Required when capability:** `cancellable`

Documents stopping behavior:
- Cancellation points
- Cleanup procedures
- Partial results
- Resume after cancel

#### dependencies.md

**Required when capability:** `external-dependent`

Documents external requirements:
- External service list
- Configuration requirements
- Health checks
- Failure modes

---

### Optional Reference

#### examples.md

**Optional for any skill**

Worked examples demonstrating skill usage:
- Input/output pairs
- Common use cases
- Edge case handling

Include when output format isn't immediately obvious from the description.

---

## Common Skill Set Patterns

### executor Skill Set

```yaml
skill_sets: [executor]
# Resolved: phased, branching, stateful
# Required refs: phases.md, decisions.md, checkpoints.md
```

### executor + guardian Skill Sets

```yaml
skill_sets: [executor, guardian]
# Resolved: phased, branching, stateful, self-validating, safety-bounded
# Required refs: phases.md, decisions.md, checkpoints.md, validation.md, safety.md
```

### executor + collaborator Skill Sets

```yaml
skill_sets: [executor, collaborator]
# Resolved: phased, branching, stateful, human-collaborative
# Required refs: phases.md, decisions.md, checkpoints.md, interaction.md
```

### integrator Skill Set

```yaml
skill_sets: [integrator]
# Resolved: composable, contract-driven
# Required refs: composition.md, io-contract.md
```

### Minimal Skill (No Capabilities)

```yaml
skill_sets: []
capabilities: []
# No reference files required
# SKILL.md contains all needed documentation
```

---

## File Organization

```
.harmony/capabilities/skills/<skill-id>/
├── SKILL.md                 # Core instructions (always present)
├── assets/                  # Images, diagrams (optional)
├── scripts/                 # Helper scripts (optional)
└── references/              # Capability-driven reference files
    ├── phases.md            # ← phased
    ├── decisions.md         # ← branching
    ├── checkpoints.md       # ← stateful, resumable
    ├── validation.md        # ← self-validating
    ├── safety.md            # ← safety-bounded
    └── examples.md          # ← (optional)
```

---

## Adding Reference Files

1. **Declare capabilities** in manifest.yml and SKILL.md frontmatter
2. **Add reference files** for each declared capability
3. **Run validation** to check completeness

```bash
# Validate capability-to-reference matching
.harmony/capabilities/skills/scripts/validate-skills.sh my-skill
```

Validation warns if:
- A capability is declared but its reference file is missing
- A reference file exists but its capability isn't declared

---

## See Also

- [Capabilities](./capabilities.md) — All 17 capabilities defined
- [Skill Sets](./skill-sets.md) — Pre-defined capability bundles
- [Declaration](./declaration.md) — How to declare capabilities
- [Validation](./validation.md) — Validation rules
- [Template](../../.harmony/capabilities/skills/_template/) — Reference file templates
