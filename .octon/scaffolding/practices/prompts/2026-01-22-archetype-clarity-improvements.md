# Archetype Clarity Improvements

## Objective

Address three remaining gaps in the skill archetype documentation:

1. Clarify "multi-phase execution" ambiguity
2. De-emphasize arbitrary line count thresholds
3. Add testing expectations per archetype

---

## Key Concepts to Document

### 1. Clarify "Multi-Phase Execution"

**Problem:** The current phrasing "multi-phase execution" is ambiguous. All skills have implicit phases (parse → process → output). The real question is whether those phases need to be *documented* for an agent to execute correctly.

**Clarification needed:**

| Skill Type | Has Phases? | Phases Need Documentation? | Archetype |
|------------|-------------|---------------------------|-----------|
| `format-json` | Yes (parse → format → output) | No — obvious sequence | Utility |
| `refine-prompt` | Yes (10 documented phases) | Yes — agent needs step-by-step guidance | Workflow |

**Key insight:** The trigger for Workflow isn't "has phases" but "phases require explicit documentation for correct execution."

**Reframe the question from:**
> "Does the skill have multiple execution phases?"

**To:**
> "Do the execution phases need to be documented for an agent to follow correctly?"

### 2. De-emphasize Line Count Thresholds

**Problem:** The documentation uses `<200 lines` as a criterion, but line count is a weak signal. A 150-line skill with complex edge cases may need reference files more than a 250-line straightforward one.

**Better framing:** Focus on *behavioral triggers* rather than line counts:

| Behavioral Trigger | Suggests Archetype |
|--------------------|-------------------|
| Output format isn't self-explanatory | Utility (with examples) |
| Has safety boundaries or escalation rules | Workflow |
| Operates in regulated/specialized domain | Workflow + domain files |
| Has external dependencies that can fail | Workflow (needs `errors.md`) |
| Requires domain-specific terminology | Workflow + `glossary.md` |

**Recommendation:** Change `<200 lines` to "fits comfortably in a single file" and add a note that line count is a rough heuristic, not a hard rule.

### 3. Add Testing Expectations Per Archetype

**Problem:** The documentation doesn't explain how each archetype should be validated/tested. Workflow skills have `validation.md`, but what about Utility skills?

**Testing expectations by archetype:**

| Archetype | Validation Approach |
|-----------|---------------------|
| **Utility** | Inline success criteria in SKILL.md (e.g., "Success: output is valid JSON") |
| **Utility (with examples)** | Examples serve as implicit test cases — output should match demonstrated patterns |
| **Workflow** | Formal `validation.md` with explicit acceptance checklist |

**Key insight:** For Utility skills, the examples (if any) serve as de facto test cases. For Workflow skills, formal validation criteria are required.

---

## Implementation Plan

### File: `docs/architecture/workspaces/skills/reference-artifacts.md`

**Location 1:** In the "Decision Heuristics" table (around line 105-112)

**Change:** Reframe the multi-phase question

**Before:**
```markdown
| Does the skill have multiple execution phases? | **Workflow** |
```

**After:**
```markdown
| Do execution phases need documentation for an agent to follow? | **Workflow** |
```

**Location 2:** In "Utility Skill" definition (around line 133)

**Change:** De-emphasize line count

**Before:**
```markdown
- All instructions fit comfortably in SKILL.md (<200 lines)
```

**After:**
```markdown
- All instructions fit comfortably in SKILL.md (typically <200 lines, but complexity matters more than line count)
```

**Location 3:** After "Archetype Definitions" section, before "Optional Domain-Oriented Reference Files"

**Add new section:** `## Validation Expectations by Archetype`

**Content:**
```markdown
## Validation Expectations by Archetype

Each archetype has different expectations for how skill execution is validated:

| Archetype | Validation Approach | Where Documented |
|-----------|---------------------|------------------|
| **Utility** | Inline success criteria | SKILL.md (e.g., "Success: output is valid JSON") |
| **Utility (with examples)** | Examples as test cases | `examples.md` — output should match demonstrated patterns |
| **Workflow** | Formal acceptance checklist | `validation.md` — explicit criteria for each phase |

### Utility Skills

For Utility skills, include a brief success criterion in SKILL.md:

```markdown
## Success Criteria

- Output is valid JSON
- All input fields are preserved
- Formatting matches specified style
```

### Utility (with examples) Skills

Examples serve as implicit test cases. The agent should produce output that matches the patterns demonstrated in `examples.md`. Include at least one example for:

- Typical input → expected output
- Edge case input → expected handling

### Workflow Skills

Workflow skills require formal validation in `validation.md`:

- Acceptance criteria for each phase
- Quality checklist for final output
- Error conditions and expected handling

See [validation.md template](./../../../.octon/capabilities/runtime/skills/_scaffold/template/references/validation.md) for the standard format.
```

---

### File: `docs/architecture/workspaces/skills/creation.md`

**Location 1:** In "Utility Skills" section (around line 47)

**Change:** De-emphasize line count

**Before:**
```markdown
- All instructions fit comfortably in SKILL.md (<200 lines)
```

**After:**
```markdown
- All instructions fit comfortably in SKILL.md (complexity matters more than line count)
```

**Location 2:** After "Utility (with examples)" section, before "Creation Phases"

**Add:** Brief note on validation expectations

**Content:**
```markdown
### Validation Expectations

- **Utility:** Include inline success criteria in SKILL.md
- **Utility (with examples):** Examples serve as test cases—output should match demonstrated patterns
- **Workflow:** Formal `validation.md` with acceptance criteria for each phase

See [Reference Artifacts](./reference-artifacts.md#validation-expectations-by-archetype) for details.
```

---

### File: `.octon/capabilities/runtime/skills/README.md`

**Location:** In "Archetype Selection Matrix" (around line 74)

**Change:** Reframe the multi-phase question

**Before:**
```markdown
| Does the skill have multiple distinct phases? | Workflow | Utility or Utility (with examples) |
```

**After:**
```markdown
| Do phases need documentation for correct execution? | Workflow | Utility or Utility (with examples) |
```

---

### File: `.octon/capabilities/runtime/skills/_scaffold/template/SKILL.md`

**Location:** After the "Workflow Archetype" section (end of References section)

**Add:** Validation expectations guidance

**Content:**
```markdown
### Validation Expectations

Choose validation approach based on archetype:

- **Utility:** Add a "Success Criteria" section to this SKILL.md with 2-3 bullet points
- **Utility (with examples):** Examples in `examples.md` serve as test cases
- **Workflow:** Use `references/validation.md` for formal acceptance criteria
```

---

## Example Content Blocks

### For reference-artifacts.md (Validation Expectations section)

```markdown
## Validation Expectations by Archetype

Each archetype has different expectations for how skill execution is validated:

| Archetype | Validation Approach | Where Documented |
|-----------|---------------------|------------------|
| **Utility** | Inline success criteria | SKILL.md (e.g., "Success: output is valid JSON") |
| **Utility (with examples)** | Examples as test cases | `examples.md` — output should match demonstrated patterns |
| **Workflow** | Formal acceptance checklist | `validation.md` — explicit criteria for each phase |

### Utility Skills

For Utility skills, include a brief success criterion in SKILL.md:

```markdown
## Success Criteria

- Output is valid JSON
- All input fields are preserved
- Formatting matches specified style
```

### Utility (with examples) Skills

Examples serve as implicit test cases. The agent should produce output that matches the patterns demonstrated in `examples.md`. Include at least one example for:

- Typical input → expected output
- Edge case input → expected handling

### Workflow Skills

Workflow skills require formal validation in `validation.md`:

- Acceptance criteria for each phase
- Quality checklist for final output
- Error conditions and expected handling
```

---

## Validation Checklist

After implementation, verify:

- [ ] "Multi-phase execution" is reframed as "phases need documentation"
- [ ] Line count (`<200 lines`) is de-emphasized or qualified
- [ ] Validation expectations section exists in `reference-artifacts.md`
- [ ] `creation.md` mentions validation expectations per archetype
- [ ] `.octon/capabilities/runtime/skills/README.md` selection matrix uses new phrasing
- [ ] `_scaffold/template/SKILL.md` includes validation guidance

---

## Out of Scope

Do NOT:

- Remove line count mentions entirely (keep as rough heuristic)
- Add new archetypes
- Change the fundamental archetype structure
- Add formal testing frameworks or tooling

The goal is to **clarify existing guidance**, not change the system.
