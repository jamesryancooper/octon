---
acceptance_criteria:
  - "All 8 search variations return zero results"
  - "Physical artifacts renamed/moved successfully"
  - "Change manifest fully executed"
  - "Checkpoint shows status: completed"
  - "Run log captures all phases"
  - "Continuity artifacts updated (append-only, not modified)"
  - "Suggested commit message generated"
---

# Validation Reference

Acceptance criteria and validation rules for the refactor skill.

## Verification Gate (MANDATORY)

**This is the most critical element of the refactor skill.**

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│   PHASE 5: VERIFICATION GATE                                       │
│                                                                     │
│   This phase MUST pass before the skill can complete.              │
│                                                                     │
│   1. Re-run ALL audit searches from Phase 2                        │
│   2. If ANY search returns results:                                │
│      - Document remaining references                                │
│      - RETURN TO PHASE 4 — Do not proceed                          │
│      - Re-execute Phase 4 for remaining items                      │
│      - Re-run Phase 5                                              │
│   3. Repeat until all searches return zero results                 │
│   4. Only then proceed to Phase 6                                  │
│                                                                     │
│   Agent instruction:                                               │
│   - You may NOT skip this phase                                    │
│   - You may NOT declare completion if verification fails           │
│   - The loop is mandatory                                          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Acceptance Criteria

A refactor is valid when:

- [ ] All 8 search variations return zero results
- [ ] Physical artifacts (directories/files) renamed/moved
- [ ] Change manifest fully executed (all items checked)
- [ ] Checkpoint shows `status: completed`
- [ ] Run log captures input, phases, and output
- [ ] Continuity artifacts updated via append (not modification)
- [ ] Suggested commit message generated

## Verification Checklist

### Search Variation Coverage

All 8 patterns must be verified:

| # | Pattern | Must Return |
|---|---------|-------------|
| 1 | Base pattern | 0 matches |
| 2 | Leading slash | 0 matches |
| 3 | Trailing slash | 0 matches |
| 4 | Both slashes | 0 matches |
| 5 | Double quotes | 0 matches |
| 6 | Single quotes | 0 matches |
| 7 | Path segment | 0 matches |
| 8 | Without special chars | 0 matches |

### Physical Artifacts

- [ ] All directories renamed
- [ ] All files moved/renamed
- [ ] No orphaned files with old names

### Continuity Artifacts

- [ ] Progress log has new entry
- [ ] Decision log updated if applicable
- [ ] ADR created if significant change
- [ ] NO existing entries modified

## Validation Rules

### Phase Progression

Phases must complete in order:

```
1 → 2 → 3 → 4 → 5 → 6
              ↑   |
              |   | (if verification fails)
              +---+
```

Phase 5 can loop back to Phase 4 multiple times.

### Checkpoint State Transitions

Valid state transitions:

```
pending → in_progress → completed
                     → failed → in_progress (retry)
```

### Scope Validation

Before Phase 4 execution:

| Check | Threshold | Result if Exceeded |
|-------|-----------|-------------------|
| File count | ≤50 | STOP, escalate to mission |
| Match count | ≤200 | STOP, escalate to mission |
| Module count | ≤3 | WARN, offer escalation |

### Continuity Artifact Validation

During Phase 4 and Phase 6:

1. Identify files matching continuity patterns
2. For each continuity file:
   - Check if content was modified (not just appended)
   - If modified: STOP, warn, request revert
3. Validate append-only rule enforcement

## Acceptable Exceptions

Some remaining references are acceptable if:

1. **Intentional historical records** — Old names in progress logs, ADRs
2. **Migration documentation** — Files explaining the rename
3. **Explicit comments** — Code comments noting old name for context

Each exception must be:
- Explicitly documented in verification report
- Justified with a clear reason
- Limited in number (not a workaround for incomplete refactor)

## Failure Conditions

The skill must STOP and report failure when:

| Condition | Required Action |
|-----------|-----------------|
| Verification finds remaining references | Loop back to Phase 4 |
| Scope exceeds 50 files | Escalate to mission |
| Continuity artifact modified (not appended) | STOP, warn, request revert |
| User cancels mid-execution | Save checkpoint, report partial completion |
| Verification fails >3 times | STOP, request human intervention |

## Output Validation

### Required Outputs

| File | Required | Format |
|------|----------|--------|
| `checkpoint.yml` | Yes | YAML |
| `scope.md` | Yes | Markdown |
| `audit-manifest.md` | Yes | Markdown |
| `change-manifest.md` | Yes | Markdown |
| `execution-log.md` | Yes | Markdown |
| `verification-report.md` | Yes | Markdown |
| `summary.md` | Yes | Markdown |
| `commit-message.txt` | Yes | Plain text |

### Log Index Update

After completion:
- `/.octon/state/evidence/runs/skills/refactors/index.yml` must be updated
- New run entry added to `runs` array
- `scopes_completed` updated

## Quality Checklist

Before declaring completion:

### Completeness

- [ ] All search variations checked
- [ ] All files in manifest processed
- [ ] All physical changes made
- [ ] All continuity artifacts updated (append-only)

### Correctness

- [ ] No references to old pattern remain
- [ ] New pattern used consistently
- [ ] No broken references (paths exist)
- [ ] No syntax errors introduced

### Documentation

- [ ] Checkpoint reflects final state
- [ ] Verification report documents all checks
- [ ] Summary includes statistics
- [ ] Commit message accurately describes changes
