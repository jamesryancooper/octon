---
title: "ADR-006: Prompt Refiner Skill"
description: Context-aware prompt refinement skill with 10-phase pipeline for transforming rough prompts into actionable instructions.
date: 2026-01-14
status: accepted
mutability: append-only
---

# ADR-006: Prompt Refiner Skill

## Status

Accepted

## Context

When working with AI coding assistants, prompt quality significantly impacts output quality. Common issues with raw prompts include:

1. **Vague intent**: "make auth better" lacks specificity
2. **Missing context**: No reference to existing patterns or constraints
3. **Contradictions**: "make it the default but also not the default"
4. **Spelling/grammar errors**: Reduce clarity
5. **No success criteria**: How do we know when it's done?
6. **Scope creep risk**: Unbounded requests lead to over-engineering

Additionally, prompts executed without codebase context often miss existing patterns, violate project constraints, or duplicate functionality.

## Decision

### 1. Create Prompt Refiner Skill

Implement a 10-phase refinement pipeline in `.harmony/skills/prompt-refiner/`:

```
Phase 1:  Context Analysis      → Scan repo, identify scope, load constraints
Phase 2:  Intent Extraction     → Parse intent, expand scope, correct errors
Phase 3:  Persona Assignment    → Assign role, expertise level, execution style
Phase 4:  Reference Injection   → Add file paths, code references, patterns
Phase 5:  Negative Constraints  → Define anti-patterns, forbidden approaches
Phase 6:  Decomposition         → Break into ordered sub-tasks
Phase 7:  Validation            → Check feasibility, identify risks
Phase 8:  Self-Critique         → Review for completeness, fix gaps
Phase 9:  Intent Confirmation   → Summarize and confirm with user
Phase 10: Output                → Save refined prompt, optionally execute
```

### 2. Key Features

**Persona Assignment** (Phase 3):
- Assigns appropriate expertise level (Junior/Mid/Senior/Principal)
- Sets role perspective (Backend, Frontend, Security, etc.)
- Defines execution style (thorough vs. quick, conservative vs. innovative)

**Negative Constraints** (Phase 5):
- Anti-patterns to avoid for this task type
- Forbidden approaches based on project rules
- Explicit out-of-scope boundaries

**Self-Critique** (Phase 8):
- Completeness check: Is all context included?
- Ambiguity check: Could requirements be misinterpreted?
- Feasibility check: Is scope realistic?
- Quality check: Are persona and constraints appropriate?

**Intent Confirmation** (Phase 9):
- Summarizes understanding in one sentence
- Presents key decisions and assumptions
- Asks user to confirm before finalizing
- Can be skipped with `--skip_confirmation`

### 3. Invocation

```bash
/refine-prompt "add caching to the api"
/refine-prompt "refactor auth" --context_depth=deep
/refine-prompt "fix login bug" --execute
/refine-prompt "add feature" --skip_confirmation --execute
```

**Parameters:**
- `raw_prompt` (required): The prompt to refine
- `--execute`: Execute the refined prompt after saving
- `--context_depth`: minimal | standard | deep
- `--skip_confirmation`: Skip intent confirmation step

### 4. Universal Skill Pattern

Following the skills architecture, the skill is defined once and symlinked:

```
.harmony/skills/prompt-refiner/SKILL.md   ← Source of truth
.claude/skills/prompt-refiner  → ../../.harmony/skills/prompt-refiner
.cursor/skills/prompt-refiner  → ../../.harmony/skills/prompt-refiner
.codex/skills/prompt-refiner   → ../../.harmony/skills/prompt-refiner
```

## Rationale

### Why 10 Phases

Each phase addresses a specific failure mode:

| Phase | Prevents |
|-------|----------|
| Context Analysis | Missing codebase patterns, constraint violations |
| Intent Extraction | Vague requirements, spelling errors |
| Persona Assignment | Wrong expertise level, inappropriate style |
| Reference Injection | Generic solutions that ignore existing code |
| Negative Constraints | Common mistakes, scope creep |
| Decomposition | Monolithic changes, unclear ordering |
| Validation | Infeasible requests, unidentified risks |
| Self-Critique | Gaps in the refined prompt itself |
| Intent Confirmation | Misunderstanding user intent |
| Output | Lost work (saves to file) |

### Why Persona Assignment

The same task executed by a "junior developer" vs. "senior architect" produces very different results. Making this explicit:
- Sets appropriate depth and thoroughness
- Aligns documentation style expectations
- Prevents over/under-engineering

### Why Negative Constraints

Telling an AI what NOT to do is often more effective than only saying what to do:
- Prevents common anti-patterns for the task type
- Enforces project-specific rules
- Explicitly bounds scope to prevent creep

### Why Self-Critique

Having the refinement process critique its own output before finalizing catches:
- Missing context
- Ambiguous requirements
- Unmeasurable success criteria
- Inappropriate persona or constraints

### Why Intent Confirmation

The most common cause of wasted AI effort is misunderstanding intent. Confirming understanding before execution:
- Catches misinterpretations early
- Surfaces assumptions for validation
- Gives user control before significant work begins

## Consequences

### Benefits

- **Higher quality prompts**: Systematic refinement catches gaps
- **Codebase awareness**: Prompts reference actual files and patterns
- **Reduced iterations**: Better prompts → better first attempts
- **Explicit assumptions**: No silent guessing
- **Bounded scope**: Negative constraints prevent creep
- **User control**: Intent confirmation before execution

### Tradeoffs

- **Overhead for simple tasks**: 10 phases is overkill for "fix typo"
  - Mitigated by `--context_depth=minimal` for simple tasks
- **Additional confirmation step**: Adds friction
  - Mitigated by `--skip_confirmation` flag

## Files Changed

### Created

- `.harmony/skills/prompt-refiner/SKILL.md` — Full skill definition (v2.1.1)
- `.harmony/skills/prompt-refiner/templates/` — Template directory (empty)
- `.harmony/skills/prompt-refiner/reference/` — Reference directory (empty)
- `.harmony/skills/prompt-refiner/scripts/` — Scripts directory (empty)
- `.claude/skills/prompt-refiner` — Symlink to skill
- `.cursor/skills/prompt-refiner` — Symlink to skill
- `.codex/skills/prompt-refiner` — Symlink to skill

### Updated

- `.harmony/skills/registry.yml` — Added prompt-refiner entry
- `.workspace/catalog.md` — Added skill to catalog table
- `.workspace/context/decisions.md` — Added D021-D024 entries

## Related Decisions

- **D021**: Prompt refiner skill — 10-phase pipeline for prompt refinement
- **D022**: Persona assignment — Explicit role/expertise in refined prompts
- **D023**: Negative constraints — Anti-patterns and forbidden approaches section
- **D024**: Intent confirmation — User confirms understanding before execution

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-01-14 | Initial skill with basic refinement |
| 2.0.0 | 2026-01-14 | Added context analysis, reference injection, decomposition, validation |
| 2.1.0 | 2026-01-14 | Added persona assignment, negative constraints, self-critique, intent confirmation |
| 2.1.1 | 2026-01-14 | Renamed `execute_after` to `--execute` flag |
