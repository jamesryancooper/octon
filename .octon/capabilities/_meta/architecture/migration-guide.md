# Migration Guide: Archetypes to Capabilities

This guide helps migrate existing skills from the v1 two-tiered archetype model to the capabilities + skill sets model.

## Quick Migration Table

| Old Model | New Model |
|-----------|-----------|
| `archetype: atomic` | `skill_sets: []` with minimal capabilities |
| `archetype: complex` | One or more skill sets based on exhibited patterns |
| Pattern-triggered files | Derived from resolved capabilities |

---

## Archetype to Skill Set Mapping

### Atomic Archetype

**Old:**
```yaml
archetype: atomic
```

**New:**
```yaml
skill_sets: []
capabilities: []
```

If the atomic skill had `examples.md`, no capability declaration needed — examples are optional for all skills.

### Complex Archetype

Map the complex archetype to skill sets based on the skill's behavior:

| Skill Pattern | Skill Sets |
|---------------|------------|
| Standard multi-phase workflow | `[executor]` |
| Multi-phase with ACP gate | `[executor, collaborator]` |
| Multi-phase with quality gates | `[executor, guardian]` |
| Pipeline component | `[integrator]` |
| Task orchestrator | `[coordinator]` |
| Agent spawner | `[delegator]` |
| Domain expert | `[specialist]` |

---

## File Migrations

### legacy phases file rename

Rename the legacy phase reference file to `references/phases.md`:

```bash
mv .octon/capabilities/runtime/skills/my-skill/references/<legacy-phases-file> \
   .octon/capabilities/runtime/skills/my-skill/references/phases.md
```

### Reference Files to Keep

Reference files map to capabilities. Keep files based on the skill's declared capabilities:

| Keep This File | When Skill Has Capability |
|----------------|---------------------------|
| `phases.md` | `phased` |
| `decisions.md` | `branching` |
| `checkpoints.md` | `stateful` or `resumable` |
| `interaction.md` | `human-collaborative` |
| `agents.md` | `agent-delegating` |
| `orchestration.md` | `task-coordinating` or `parallel` |
| `composition.md` | `composable` |
| `io-contract.md` | `contract-driven` |
| `validation.md` | `self-validating` |
| `safety.md` | `safety-bounded` |
| `glossary.md` | `domain-specialized` |
| `errors.md` | `error-resilient` |
| `examples.md` | (Optional for any skill) |

---

## Migration Examples

### Example 1: refactor Skill

**Before (archetype model):**
```yaml
# manifest.yml
- id: refactor
  archetype: complex
  tags: [refactor, codebase]

# SKILL.md frontmatter
archetype: complex
```

**After (capabilities model):**
```yaml
# manifest.yml
- id: refactor
  skill_sets:
    - executor
    - guardian
  capabilities:
    - resumable
  tags: [refactor, codebase]

# SKILL.md frontmatter
skill_sets: [executor, guardian]
capabilities: [resumable]
```

**Reasoning:**
- `executor` — Has phases, branching, and state
- `guardian` — Has validation and safety constraints
- `resumable` — Supports checkpoint/resume (beyond basic stateful)

### Example 2: refine-prompt Skill

**Before:**
```yaml
archetype: complex
```

**After:**
```yaml
skill_sets: [executor, collaborator]
capabilities: []
```

**Reasoning:**
- `executor` — Multi-phase workflow
- `collaborator` — Requires human interaction/confirmation

### Example 3: create-skill Skill

**Before:**
```yaml
archetype: complex
```

**After:**
```yaml
skill_sets: [executor]
capabilities: [self-validating]
```

**Reasoning:**
- `executor` — Multi-phase scaffolding workflow
- `self-validating` — Validates created skill (not full guardian pattern)

### Example 4: format-json (Atomic Skill)

**Before:**
```yaml
archetype: atomic
```

**After:**
```yaml
skill_sets: []
capabilities: []
```

No skill sets or capabilities needed for simple utilities.

---

## Step-by-Step Migration Process

### 1. Identify Current Archetype

Check the skill's current archetype declaration:
- `archetype: atomic` → Start with empty skill_sets
- `archetype: complex` → Analyze exhibited patterns

### 2. Map to Skill Sets

For complex skills, identify which skill sets match:

| Question | If Yes |
|----------|--------|
| Does it have phases with transitions? | Add `executor` |
| Does it require human decisions? | Add `collaborator` |
| Does it have quality gates/validation? | Add `guardian` |
| Does it spawn sub-agents? | Add `delegator` |
| Does it coordinate external tasks? | Add `coordinator` |
| Is it a pipeline building block? | Add `integrator` |
| Does it need domain terminology? | Add `specialist` |

### 3. Add Extra Capabilities

Check for capabilities not covered by skill sets:

| Feature | Capability to Add |
|---------|-------------------|
| Can resume from interruption | `resumable` |
| Has error recovery procedures | `error-resilient` |
| Safe to retry | `idempotent` |
| Can be cancelled mid-execution | `cancellable` |
| Requires external services | `external-dependent` |

### 4. Rename legacy phase reference

If the skill has the legacy phase reference file, rename it to `phases.md`:

```bash
mv references/<legacy-phases-file> references/phases.md
```

### 5. Update Reference File Headers

Add capability headers to reference files:

```markdown
# Phases Reference

**Required when capability:** `phased`

...
```

### 6. Update manifest.yml and SKILL.md

Replace archetype with skill_sets and capabilities:

```yaml
# Remove
archetype: complex

# Add
skill_sets: [executor, guardian]
capabilities: [resumable]
```

### 7. Run Validation

```bash
.octon/capabilities/runtime/skills/_ops/scripts/validate-skills.sh my-skill
```

Fix any warnings about missing or extra reference files.

---

## Validation After Migration

After migration, validation should show:

```
Validating skill: my-skill
  ✓ Skill sets valid
  ✓ Capabilities valid
  ✓ Reference files match capabilities

PASSED: my-skill
```

If you see warnings about missing references, either:
1. Add the missing reference file, or
2. Remove the capability if you don't need it

---

## FAQ

**Q: Can I keep my skill at atomic even if it has a few reference files?**

A: Yes. Use `skill_sets: []` and declare only the specific capabilities you need. Not every skill needs skill sets.

**Q: What if my skill doesn't fit any skill set exactly?**

A: Declare capabilities directly without skill sets. The model is flexible — skill sets are conveniences, not requirements.

**Q: Do I need to migrate all skills at once?**

A: No. The validation script supports both models during transition. Migrate skills incrementally.

**Q: What happens to the archetype field?**

A: Remove it. The archetype field is no longer used and will be ignored by validation.
