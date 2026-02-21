---
title: "ADR-005: Workflow Meta-Architecture and Gap Remediation"
status: accepted
date: 2026-01-14
mutability: append-only
---

# ADR-005: Workflow Meta-Architecture and Gap Remediation

## Status

Accepted

## Context

The existing workflow architecture in `.harmony/orchestration/workflows/` was reviewed against eight quality dimensions: efficiency, scalability, performance, reliability, maintainability, adaptability, usability, and robustness.

While the architecture had strong foundations (mandatory verification gates, audit-before-execute pattern, append-only continuity, step-per-file organization), six gaps were identified:

1. **No idempotency guarantees** — Re-running a step could cause issues
2. **No cross-workflow dependencies** — Unclear if workflow A must complete before B
3. **No conditional branching** — All workflows strictly linear
4. **No resumption/checkpoints** — Can't resume long operations
5. **No workflow versioning** — Workflows evolve without version tracking
6. **No parallel step support** — All steps sequential even when independent

Additionally, there was no systematic way to create new workflows that incorporated these improvements.

## Decision

### 1. Enhanced Frontmatter Schema

All workflow `00-overview.md` files now include:

```yaml
---
title: [Title]
description: [Max 160 chars]
access: human|agent
version: "1.0.0"           # Semantic versioning
depends_on: []              # Cross-workflow dependencies
checkpoints:
  enabled: true
  storage: ".harmony/continuity/checkpoints/"
parallel_steps: []          # Steps safe to run in parallel
---
```

### 2. Idempotency Sections

All step files now include:

```markdown
## Idempotency

**Check:** [How to detect if step completed]
**If Already Complete:** [Skip or cleanup action]
**Marker:** `checkpoints/<workflow>/<step>.complete`
```

### 3. Meta-Workflow System

Created `.harmony/orchestration/workflows/workflows/` containing:

- **create-workflow/** (8 steps) — Scaffold new workflows with gap fixes integrated
- **evaluate-workflow/** (5 steps) — Assess workflow quality and gap coverage
- **update-workflow/** (5 steps) — Add gap fixes to existing workflows

### 4. Supporting Infrastructure

- `.harmony/orchestration/workflows/_scaffold/template/` — Canonical templates with gap fix fields
- `.harmony/cognition/context/workflow-gaps.md` — Gap remediation guide
- `.harmony/cognition/context/workflow-quality.md` — Quality criteria and grading rubric
- `.harmony/capabilities/commands/` — Trigger commands (`create-workflow`, `evaluate-workflow`, `update-workflow`)
- Harness symlinks in `.cursor/commands/` and `.claude/commands/`

### 5. Harness Integration

Commands with `access: human` require symlinks in harness directories:

```bash
.cursor/commands/<cmd>.md -> ../../.harmony/capabilities/commands/<cmd>.md
.claude/commands/<cmd>.md -> ../../.harmony/capabilities/commands/<cmd>.md
```

This is documented in `create-workflow/07-update-references.md` and `update-workflow/04-execute-changes.md`.

## Consequences

### Positive

- **Reliability improved:** Idempotency prevents re-run issues
- **Maintainability improved:** Version tracking and history sections
- **Usability improved:** Meta-workflows guide consistent creation
- **Discoverability:** Commands available in all harnesses via symlinks
- **Self-documenting:** Gap fixes make workflows explicit about their capabilities

### Negative

- **Increased verbosity:** Step files are ~20% longer with idempotency sections
- **Migration overhead:** Existing workflows need retroactive updates
- **Learning curve:** New contributors must understand gap fix conventions

### Neutral

- Checkpoint files will accumulate in `.harmony/continuity/checkpoints/` (can be periodically cleaned)

## Decisions Made

| ID | Decision | Choice | Constraint |
|----|----------|--------|------------|
| D017 | Workflow versioning | Semantic versioning in frontmatter | Increment version when modifying workflows |
| D018 | Step idempotency | Required `## Idempotency` section | All step files must include idempotency checks |
| D019 | Harness symlinks | Required for `access: human` commands | Commands must be symlinked to all harness directories |
| D020 | Meta-workflows | `workflows/workflows/` directory | Workflows for creating/evaluating/updating workflows |

## References

- Gap remediation guide: `.harmony/cognition/context/workflow-gaps.md`
- Quality criteria: `.harmony/cognition/context/workflow-quality.md`
- Create workflow: `.harmony/orchestration/workflows/workflows/create-workflow/`
- Evaluate workflow: `.harmony/orchestration/workflows/workflows/evaluate-workflow/`
- Update workflow: `.harmony/orchestration/workflows/workflows/update-workflow/`
