---
title: Validation Reference
description: Acceptance criteria for the triage-ci-failure skill.
---

# Validation Reference

Acceptance criteria for a complete triage-ci-failure execution.

## Acceptance Criteria

### Phase Completion

| Phase | Required | Completion Condition |
| ----- | -------- | -------------------- |
| Fetch | Yes | Failing logs retrieved and parsed |
| Diagnose | Yes | Root cause identified with category and confidence |
| Fix | Yes* | Targeted fix applied (*unless INFRA category) |
| Verify | Yes* | Local check passes (*unless INFRA category) |
| Report | Yes | Triage report written |

### Diagnosis Quality

| Check | Requirement |
| ----- | ----------- |
| Category assigned | One of: TEST_FAILURE, BUILD_ERROR, LINT_VIOLATION, DEPENDENCY, TIMEOUT, INFRA |
| Root cause identified | Specific error message and affected file(s) documented |
| Confidence rated | HIGH, MEDIUM, or LOW |
| Pre-existing check | Determined whether failure is from this PR or pre-existing |

### Fix Quality

| Check | Requirement |
| ----- | ----------- |
| Targeted | Fix addresses the root cause, not a symptom |
| Verified | Local run of the failing check passes |
| Minimal | Only changes necessary to fix the failure |
| No suppressions | Tests not skipped, rules not disabled |

### Report Completeness

- [ ] CI run link included
- [ ] Failure category and root cause documented
- [ ] Fix description with affected files
- [ ] Verification result (command and outcome)
- [ ] Relevant log excerpt

## Verification Checklist

1. Report exists at `.harmony/output/reports/YYYY-MM-DD-ci-triage.md`
2. Root cause was identified (not "unknown")
3. Fix was verified locally (or INFRA category documented)
4. Log exists at `_ops/state/logs/triage-ci-failure/{{run_id}}.md`
5. Log index updated
6. No CI config files were modified
7. No tests were skipped or deleted
