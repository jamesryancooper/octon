# Errors Reference

**Required when capability:** `error-resilient`

Error handling and recovery procedures for the {{skill_name}} skill.

## Error Categories

| Category | Severity | Recovery Strategy |
|----------|----------|-------------------|
| {{category_1}} | {{critical/warning/info}} | {{strategy}} |
| {{category_2}} | {{critical/warning/info}} | {{strategy}} |
| {{category_3}} | {{critical/warning/info}} | {{strategy}} |

## Recovery Procedures

### {{Error Type 1}}

**Symptoms:**
- {{symptom_1}}
- {{symptom_2}}

**Cause:** {{root_cause}}

**Recovery:**
1. {{recovery_step_1}}
2. {{recovery_step_2}}
3. {{recovery_step_3}}

**Prevention:** {{how_to_prevent}}

### {{Error Type 2}}

**Symptoms:**
- {{symptom_1}}
- {{symptom_2}}

**Cause:** {{root_cause}}

**Recovery:**
1. {{recovery_step_1}}
2. {{recovery_step_2}}

**Prevention:** {{how_to_prevent}}

## Escalation Matrix

| Error Pattern | Auto-Retry | Max Retries | Escalate After |
|---------------|------------|-------------|----------------|
| {{pattern_1}} | Yes/No | {{n}} | {{condition}} |
| {{pattern_2}} | Yes/No | {{n}} | {{condition}} |

## Logging Requirements

When errors occur, log:
- Timestamp
- Error category and severity
- Input that triggered the error (sanitized)
- Recovery action taken
- Outcome (resolved/escalated)
