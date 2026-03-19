# Capability Declaration

Skills declare their capabilities using `skill_sets` and `capabilities` fields. This page covers declaration syntax, resolution rules, and best practices.

## Declaration Syntax

### In manifest.yml

```yaml
skills:
  - id: refactor
    display_name: Refactor
    path: refactor/refactor/
    summary: "Execute verified codebase refactor with exhaustive audit."
    status: active
    tags: [refactor, codebase, verification]
    triggers:
      - "refactor this"
      - "rename across codebase"
    skill_sets:
      - executor
      - guardian
    capabilities:
      - resumable
```

### In SKILL.md Frontmatter

```yaml
---
name: refactor
description: >
  Execute verified codebase refactor with exhaustive audit.
skill_sets: [executor, guardian]
capabilities: [resumable]
allowed-tools: Read Glob Grep Write(/.octon/state/control/skills/checkpoints/*) Write(/.octon/state/evidence/runs/skills/*)
---
```

---

## Resolution Rules

### 1. Capabilities are resolved as a set (deduplicated)

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

# Resolved
resolved_capabilities: [phased, branching, stateful, human-collaborative, resumable]
```

### 2. Reference files are derived from resolved capabilities

```yaml
# From resolved_capabilities above:
required_refs:
  - phases.md        # ← phased
  - decisions.md     # ← branching
  - checkpoints.md   # ← stateful, resumable (deduplicated)
  - interaction.md   # ← human-collaborative
```

### 3. No subtraction — use direct declaration instead

If a skill set doesn't fit exactly, don't use it. Declare capabilities directly:

```yaml
# Instead of "executor minus branching"
skill_sets: []
capabilities: [phased, stateful]
```

---

## Additive Model

The capability model is strictly additive:

- Skill sets expand to their bundled capabilities
- Explicit capabilities add to the set
- No capability can be removed once added

This ensures:
- Predictable resolution (same declaration = same capabilities)
- Simple mental model (everything adds, nothing subtracts)
- No ambiguity ("executor minus X" — is it still an executor?)

---

## Declaration Examples

### Minimal Skill (No Capabilities)

```yaml
skill_sets: []
capabilities: []
```

Resolved capabilities: `[]`

No reference files required.

### Simple Multi-Phase Skill

```yaml
skill_sets: [executor]
capabilities: []
```

Resolved capabilities: `[phased, branching, stateful]`

Required refs: `phases.md`, `decisions.md`, `checkpoints.md`

### Multi-Phase with ACP Oversight

```yaml
skill_sets: [executor, collaborator]
capabilities: []
```

Resolved capabilities: `[phased, branching, stateful, human-collaborative]`

Required refs: `phases.md`, `decisions.md`, `checkpoints.md`, `interaction.md`

### Multi-Phase with Quality Gates

```yaml
skill_sets: [executor, guardian]
capabilities: []
```

Resolved capabilities: `[phased, branching, stateful, self-validating, safety-bounded]`

Required refs: `phases.md`, `decisions.md`, `checkpoints.md`, `validation.md`, `safety.md`

### Pipeline Component

```yaml
skill_sets: [integrator]
capabilities: []
```

Resolved capabilities: `[composable, contract-driven]`

Required refs: `composition.md`, `io-contract.md`

### Executor with Resumability

```yaml
skill_sets: [executor]
capabilities: [resumable]
```

Resolved capabilities: `[phased, branching, stateful, resumable]`

Required refs: `phases.md`, `decisions.md`, `checkpoints.md` (resumable uses same file as stateful)

### Domain Expert with Quality Gates

```yaml
skill_sets: [executor, specialist, guardian]
capabilities: []
```

Resolved capabilities: `[phased, branching, stateful, domain-specialized, self-validating, safety-bounded]`

Required refs: `phases.md`, `decisions.md`, `checkpoints.md`, `glossary.md`, `validation.md`, `safety.md`

---

## Validation

During validation, the system:

1. **Expands skill sets** to their capabilities
2. **Merges with explicit capabilities** (deduplicates)
3. **Checks for required references** based on resolved capabilities
4. **Warns** if reference files don't match capabilities

See [Validation](validation.md) for complete validation rules.

---

## Best Practices

### Do

- Use skill sets when they match your skill's pattern
- Add explicit capabilities for specific needs beyond skill sets
- Keep declarations minimal — only declare what you need
- Use guardian skill set for skills with safety requirements

### Don't

- Don't use skill sets that include capabilities you don't need
- Don't duplicate capabilities already in skill sets
- Don't try to "subtract" capabilities — declare directly instead
- Don't declare capabilities without providing reference files
