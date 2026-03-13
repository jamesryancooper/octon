# Capabilities Reference

Skills are defined by their **capabilities** — what they can do. Each capability maps to specific reference files that document that capability.

## Capability Categories

### Execution Capabilities

Capabilities that define how the skill executes work.

| Capability | Description | Reference File |
|------------|-------------|----------------|
| `phased` | Has distinct execution phases | `phases.md` |
| `branching` | Has conditional execution paths | `decisions.md` |
| `parallel` | Can execute work concurrently | `orchestration.md` |

### Coordination Capabilities

Capabilities for managing external work.

| Capability | Description | Reference File |
|------------|-------------|----------------|
| `task-coordinating` | Manages external tasks/jobs | `orchestration.md` |
| `agent-delegating` | Delegates to autonomous sub-agents | `agents.md` |
| `human-collaborative` | Requires human decisions | `interaction.md` |

### State Capabilities

Capabilities for managing state across execution.

| Capability | Description | Reference File |
|------------|-------------|----------------|
| `stateful` | Persists state across phases | `checkpoints.md` |
| `resumable` | Can checkpoint and resume | `checkpoints.md` |

### Temporal Capabilities

Capabilities for time-oriented execution constraints.

| Capability | Description | Reference File |
|------------|-------------|----------------|
| `long-running` | Execution spans extended time (minutes to hours) | `execution-model.md` |
| `scheduled` | Triggered on a schedule/timer | `schedule.md` |

### Quality Capabilities

Capabilities for ensuring quality and handling errors.

| Capability | Description | Reference File |
|------------|-------------|----------------|
| `self-validating` | Has formal acceptance criteria | `validation.md` |
| `error-resilient` | Has recovery procedures | `errors.md` |

### Integration Capabilities

Capabilities for composing with other skills.

| Capability | Description | Reference File |
|------------|-------------|----------------|
| `composable` | Designed for chaining | `composition.md` |
| `contract-driven` | Formal I/O specification | `io-contract.md` |

### Scope Capabilities

Capabilities defining scope and constraints.

| Capability | Description | Reference File |
|------------|-------------|----------------|
| `domain-specialized` | Requires domain knowledge | `glossary.md` |
| `safety-bounded` | Explicit constraints | `safety.md` |

### Reliability Capabilities

Capabilities for robust execution.

| Capability | Description | Reference File |
|------------|-------------|----------------|
| `idempotent` | Safe to retry; same input = same effect | `idempotency.md` |
| `cancellable` | Can be stopped mid-execution | `cancellation.md` |
| `external-dependent` | Requires external services (e.g., live ruleset fetch via WebFetch). See [Live Ruleset Pattern](../../practices/design-conventions.md#live-ruleset-pattern-external-dependent) for the full design convention. | `dependencies.md` |

### Output Capabilities

Capabilities for non-file execution outputs.

| Capability | Description | Reference File |
|------------|-------------|----------------|
| `external-output` | Produces non-file outputs (URLs, API responses) | `external-outputs.md` |

---

## Capability-to-Reference Mapping

Complete mapping of capabilities to their documentation files:

```yaml
phased: [phases.md]
branching: [decisions.md]
parallel: [orchestration.md]
task-coordinating: [orchestration.md]
agent-delegating: [agents.md]
human-collaborative: [interaction.md]
stateful: [checkpoints.md]
resumable: [checkpoints.md]
long-running: [execution-model.md]
scheduled: [schedule.md]
self-validating: [validation.md]
error-resilient: [errors.md]
composable: [composition.md]
contract-driven: [io-contract.md]
domain-specialized: [glossary.md]
safety-bounded: [safety.md]
idempotent: [idempotency.md]
cancellable: [cancellation.md]
external-dependent: [dependencies.md]
external-output: [external-outputs.md]
```

---

## Declaring Capabilities

Capabilities are declared in the skill's manifest entry and SKILL.md frontmatter:

```yaml
# In manifest.yml or SKILL.md frontmatter
skill_sets: [executor, guardian]  # Bundles that expand to capabilities
capabilities: [resumable]         # Additional capabilities
```

See [Declaration](declaration.md) for the full syntax and resolution rules.

---

## Validation Rules

1. **Declared capabilities must be valid** — Unknown capability names are rejected
2. **Resolved capabilities should have reference files** — Warning if `stateful` declared but no `checkpoints.md`
3. **Reference files should map to capabilities** — Warning if `checkpoints.md` exists but `stateful`/`resumable` not declared

See [Validation](validation.md) for the complete validation rules.

---

## Capability Discovery

Query skills by capability:

```yaml
# Find all skills with resumable capability
query:
  capability: resumable

# Find all skills that are composable
query:
  capability: composable
```

See [Discovery](discovery.md) for capability-based discovery patterns.
