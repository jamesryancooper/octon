# Capability Validation

The validation system ensures skills have consistent capability declarations and matching reference files.

## Validation Rules

### 1. Valid Capability Names

All declared capabilities must be from the valid capabilities list:

```yaml
valid_capabilities:
  # Execution
  - phased
  - branching
  - parallel
  # Coordination
  - task-coordinating
  - agent-delegating
  - human-collaborative
  # State
  - stateful
  - resumable
  # Temporal
  - long-running
  - scheduled
  # Quality
  - self-validating
  - error-resilient
  # Integration
  - composable
  - contract-driven
  # Scope
  - domain-specialized
  - safety-bounded
  # Reliability
  - idempotent
  - cancellable
  - external-dependent
  # Output
  - external-output
```

**Error:** Unknown capability declared

```
ERROR: Skill 'my-skill' declares unknown capability 'resumeable' (did you mean 'resumable'?)
```

### 2. Valid Skill Set Names

All declared skill sets must be from the valid skill sets list:

```yaml
valid_skill_sets:
  - executor
  - coordinator
  - delegator
  - collaborator
  - integrator
  - specialist
  - guardian
```

**Error:** Unknown skill set declared

```
ERROR: Skill 'my-skill' declares unknown skill set 'executer' (did you mean 'executor'?)
```

### 3. Capability-to-Reference Matching

Resolved capabilities should have corresponding reference files:

| Capability | Expected Reference |
|------------|-------------------|
| `phased` | `phases.md` |
| `branching` | `decisions.md` |
| `parallel` | `orchestration.md` |
| `task-coordinating` | `orchestration.md` |
| `agent-delegating` | `agents.md` |
| `human-collaborative` | `interaction.md` |
| `stateful` | `checkpoints.md` |
| `resumable` | `checkpoints.md` |
| `long-running` | `execution-model.md` |
| `scheduled` | `schedule.md` |
| `self-validating` | `validation.md` |
| `error-resilient` | `errors.md` |
| `composable` | `composition.md` |
| `contract-driven` | `io-contract.md` |
| `domain-specialized` | `glossary.md` |
| `safety-bounded` | `safety.md` |
| `idempotent` | `idempotency.md` |
| `cancellable` | `cancellation.md` |
| `external-dependent` | `dependencies.md` |
| `external-output` | `external-outputs.md` |

**Warning:** Capability declared but reference missing

```
WARNING: Skill 'my-skill' has capability 'stateful' but no 'checkpoints.md' reference file
```

### 4. Reference-to-Capability Matching

Reference files should correspond to declared capabilities:

**Warning:** Reference file exists but capability not declared

```
WARNING: Skill 'my-skill' has 'checkpoints.md' but neither 'stateful' nor 'resumable' capability declared
```

### 5. Alignment-First Process Gate

Every new skill implementation must record an alignment decision:

- `aligned` — implemented using existing contracts
- `extension-proposed` — extension proposal created with synchronized docs/schema/validator updates

**Blocking rule for review:** Do not merge ad hoc contract changes without the extension proposal artifacts.

---

## Validation Levels

### Errors (Block Execution)

- Unknown capability name
- Unknown skill set name
- Invalid YAML syntax
- Missing required fields
- Contract extension introduced without synchronized schema/docs/validator updates

### Warnings (Allow Execution)

- Capability without matching reference
- Reference without matching capability
- Empty skill_sets and capabilities (informational)

---

## Running Validation

### Validate All Skills

```bash
.harmony/capabilities/skills/_scripts/validate-skills.sh
```

### Validate Specific Skill

```bash
.harmony/capabilities/skills/_scripts/validate-skills.sh my-skill
```

### Strict Mode (Treat Warnings as Errors)

```bash
.harmony/capabilities/skills/_scripts/validate-skills.sh --strict
```

---

## Validation Output

### Success

```
Validating skill: refactor
  ✓ Skill sets valid: [executor, guardian]
  ✓ Capabilities valid: [resumable]
  ✓ Resolved capabilities: [phased, branching, stateful, self-validating, safety-bounded, resumable]
  ✓ Reference files match capabilities

PASSED: refactor
```

### With Warnings

```
Validating skill: my-skill
  ✓ Skill sets valid: [executor]
  ✓ Capabilities valid: []
  ✓ Resolved capabilities: [phased, branching, stateful]
  ⚠ Missing reference: decisions.md (for capability: branching)

PASSED with warnings: my-skill
```

### With Errors

```
Validating skill: bad-skill
  ✗ Unknown skill set: 'executer' (did you mean 'executor'?)

FAILED: bad-skill
```

---

## Capability Threshold Warnings

When a skill has many capabilities but few reference files, a warning is issued:

```
WARNING: Skill 'complex-skill' has 8 resolved capabilities but only 2 reference files.
         Consider adding documentation for: branching, stateful, self-validating...
```

This helps ensure skills are adequately documented.

---

## Programmatic Validation

### Resolve Capabilities

```python
def resolve_capabilities(skill_sets, capabilities, definitions):
    """Resolve skill sets and capabilities to final capability set."""
    resolved = set()

    # Expand skill sets
    for skill_set in skill_sets:
        resolved.update(definitions[skill_set]['capabilities'])

    # Add explicit capabilities
    resolved.update(capabilities)

    return sorted(resolved)
```

### Validate References

```python
def validate_references(resolved_capabilities, reference_files, capability_refs):
    """Check that capabilities have matching reference files."""
    warnings = []

    for capability in resolved_capabilities:
        expected_refs = capability_refs.get(capability, [])
        for ref in expected_refs:
            if ref not in reference_files:
                warnings.append(f"Missing {ref} for capability {capability}")

    return warnings
```
