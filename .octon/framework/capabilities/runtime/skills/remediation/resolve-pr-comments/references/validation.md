---
title: Validation Reference
description: Acceptance criteria and verification for the resolve-pr-comments skill.
---

# Validation Reference

Acceptance criteria for a complete resolve-pr-comments execution.

## Acceptance Criteria

### Phase Completion

All 6 phases must execute:

| Phase | Required | Completion Condition |
| ----- | -------- | -------------------- |
| Fetch | Yes | All unresolved comments retrieved |
| Classify | Yes | Every comment has a type assignment |
| Plan | Yes | Every comment has a resolution strategy |
| Resolve | Yes | Every non-deferred comment has a fix applied |
| Verify | Yes | Every applied fix has been re-read and confirmed |
| Report | Yes | Report written with all comments accounted for |

### Comment Coverage

| Check | Requirement |
| ----- | ----------- |
| All comments classified | Every fetched comment has a type |
| All comments in report | No silent drops — every comment appears |
| All BUG/STYLE/NIT resolved | These types should have fixes applied |
| All QUESTION answered | Draft response provided |
| All DESIGN presented | Options listed, not applied without approval |

### Report Completeness

The output report must include:

- [ ] PR metadata (number, title, branch)
- [ ] Summary statistics (resolved, deferred, answered)
- [ ] Per-file resolution table with line numbers
- [ ] Items needing discussion section (if any)
- [ ] Questions answered section (if any)

### Quality Gates

| Gate | Pass Condition |
| ---- | -------------- |
| No silent drops | Every fetched comment appears in the report |
| No unilateral design decisions | DESIGN comments are presented, not applied |
| No force pushes | Only new commits created |
| Fixes verified | Every APPLIED fix was re-read after editing |

## Verification Checklist

After skill execution, verify:

1. Report exists at `.octon/state/evidence/validation/analysis/YYYY-MM-DD-pr-comments-resolved.md`
2. Every comment has a status (APPLIED, DEFERRED, ANSWERED, NEEDS_DISCUSSION)
3. No comments were silently dropped
4. DESIGN comments were not applied without approval
5. Log exists at `/.octon/state/evidence/runs/skills/resolve-pr-comments/{{run_id}}.md`
6. Log index updated
