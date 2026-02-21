---
title: "ADR-008: Skills Architecture Refactor"
status: accepted
date: 2026-01-15
mutability: append-only
---

# ADR-008: Skills Architecture Refactor

## Status

Accepted

## Context

The skills system needed alignment with the [agentskills.io specification](https://agentskills.io/specification) while addressing several architectural concerns:

1. **Naming inconsistency** - Skill names used noun-verb patterns (e.g., `prompt-refiner`) instead of the action-oriented verb-noun convention
2. **Monolithic documentation** - `skills.md` was 763 lines covering everything
3. **No progressive disclosure** - SKILL.md files contained all details upfront, consuming unnecessary tokens
4. **Workspace authority unclear** - No clear rules for which workspace could write where
5. **No spec compliance verification** - No validation that skills followed the agentskills.io format

## Decision

Refactor the skills architecture to align with agentskills.io spec and implement progressive disclosure.

### Decisions Made

| ID | Decision | Choice |
|----|----------|--------|
| D027 | Skill naming convention | Verb-noun pattern (e.g., `refine-prompt`, `synthesize-research`) |
| D028 | Progressive disclosure | Three-tier model: SKILL.md (core) + references/ (details) + assets/ (resources) |
| D029 | Reference file structure | Standard files: phases.md, io-contract.md, safety.md, examples.md, validation.md |
| D030 | Hierarchical workspace authority | Workspaces can write DOWN (descendants), not UP (ancestors) or SIDEWAYS (siblings) |
| D031 | Output permission tiers | Tier 1 (default outputs/), Tier 2 (.workspace/**), Tier 3 (workspace root/**) |
| D032 | Documentation split | Monolithic skills.md split into 10 focused documents |

## Changes

### Skill Renaming

```
prompt-refiner  →  refine-prompt
```

The verb-noun pattern follows agentskills.io convention and reads more naturally as a command.

### Progressive Disclosure Structure

```
.harmony/capabilities/skills/<skill-name>/
├── SKILL.md              # Core instructions (<500 lines, ~5000 tokens)
├── references/           # Detailed documentation
│   ├── phases.md      # Phase-by-phase execution
│   ├── io-contract.md    # Inputs, outputs, parameters
│   ├── safety.md         # Tool/file policies, constraints
│   ├── examples.md       # Worked examples
│   └── validation.md     # Acceptance criteria
├── scripts/              # Helper scripts (optional)
└── assets/               # Static resources (optional)
```

### Hierarchical Workspace Model

```
repo/                              ← Root workspace (scope: repo/**)
├── .workspace/
├── docs/                          ← Docs workspace (scope: docs/**)
│   ├── .workspace/
│   └── guides/
└── packages/
    └── flowkit/                   ← FlowKit workspace (scope: flowkit/**)
        └── .workspace/
```

**Authority rules:**
- DOWN: Can write into descendant workspaces
- UP: Cannot write into ancestor workspaces
- SIDEWAYS: Cannot write into sibling workspaces

### Documentation Split

| Old File | New Files |
|----------|-----------|
| skills.md (763 lines) | README.md, architecture.md, comparison.md, creation.md, execution.md, invocation.md, reference-artifacts.md, registry.md, skill-format.md, specification.md |

## Consequences

### Positive

- Skills now follow agentskills.io specification
- Progressive disclosure reduces token consumption at discovery time
- Clear workspace authority prevents accidental cross-workspace writes
- Focused documentation is easier to find and maintain
- Reference file structure is predictable across all skills

### Negative

- More files to maintain per skill
- Migration effort for existing skills
- Symlinks need updating when skills are renamed

## Related

- [agentskills.io/specification](https://agentskills.io/specification) - Format specification
- `docs/architecture/workspaces/skills/` - Split documentation
- `.harmony/capabilities/skills/_scaffold/template/` - Updated skill template
- `.harmony/orchestration/workflows/skills/create-skill/` - Updated workflow (v2.0.0)
