---
# Error Handling Reference
# Documents error conditions, recovery procedures, and troubleshooting.
#
# Error codes follow the standard format defined in:
# .octon/state/evidence/runs/skills/FORMAT.md
errors:
  - code: "E001"
    condition: "Empty or whitespace-only prompt input"
    severity: fatal
    message: "Input prompt cannot be empty"
    action: "Provide a non-empty prompt text or file path"

  - code: "E002"
    condition: "Input exceeds maximum length (>10000 characters)"
    severity: recoverable
    message: "Prompt exceeds maximum length: {{length}} characters"
    action: "Truncate to first 10000 characters; warn user"

  - code: "E003"
    condition: "Input file path does not exist"
    severity: fatal
    message: "Prompt file not found: {{path}}"
    action: "Verify file path and retry"

  - code: "E010"
    condition: "Context analysis timeout (>60 seconds)"
    severity: recoverable
    message: "Context analysis timed out"
    action: "Reduce context_depth to 'minimal' or specify fewer files"

  - code: "E011"
    condition: "Scope exceeds 20 files"
    severity: recoverable
    message: "Scope too large: {{count}} files identified"
    action: "Suggest narrowing scope; offer to proceed with subset"

  - code: "E012"
    condition: "Repository structure cannot be determined"
    severity: recoverable
    message: "Cannot determine repository structure"
    action: "Proceed with minimal context; note limitation"

  - code: "E020"
    condition: "Cannot write to output path"
    severity: fatal
    message: "Cannot write to: {{path}}"
    action: "Check permissions; verify path is within allowed scope"

  - code: "E030"
    condition: "Harness directory not found"
    severity: fatal
    message: "Harness directory not found: .octon/"
    action: "Initialize harness or run from correct directory"

  - code: "E040"
    condition: "Required tool not available"
    severity: fatal
    message: "Required tool not available: {{tool}}"
    action: "Verify skill has correct allowed-tools in SKILL.md"

  - code: "E050"
    condition: "Intent confirmation rejected by user"
    severity: cancelled
    message: "User rejected intent confirmation"
    action: "Revise prompt based on user feedback and retry"

  - code: "E051"
    condition: "Self-critique reveals major issues"
    severity: recoverable
    message: "Self-critique identified issues: {{issues}}"
    action: "Address identified issues before proceeding"

  - code: "E052"
    condition: "Unresolvable contradictions in prompt"
    severity: fatal
    message: "Prompt contains unresolvable contradictions"
    action: "Clarify contradictions with user before proceeding"

fallback_behavior: |
  When execution cannot complete:
  1. Log partial results if any context was gathered
  2. Preserve original input for user retry
  3. Write error details to run log
  4. Report specific error code and recovery action
---

# Error Handling Reference

Error conditions, recovery procedures, and troubleshooting for the refine-prompt skill.

## Error Codes

| Code | Severity | Condition | Action |
|------|----------|-----------|--------|
| E001 | Fatal | Empty prompt input | Provide non-empty prompt |
| E002 | Recoverable | Prompt exceeds 10000 chars | Truncates with warning |
| E003 | Fatal | Input file not found | Verify file path |
| E010 | Recoverable | Context analysis timeout | Use minimal context depth |
| E011 | Recoverable | Scope exceeds 20 files | Narrow scope or proceed with subset |
| E012 | Recoverable | Cannot determine repo structure | Proceeds with minimal context |
| E020 | Fatal | Cannot write output | Check path and permissions |
| E030 | Fatal | Harness not found | Initialize harness |
| E040 | Fatal | Required tool unavailable | Check allowed-tools |
| E050 | Cancelled | User rejected confirmation | Revise and retry |
| E051 | Recoverable | Self-critique found issues | Address issues first |
| E052 | Fatal | Unresolvable contradictions | Clarify with user |

## Severity Levels

| Severity | Exit Code | Behavior |
|----------|-----------|----------|
| **Fatal** | 1 | Execution stops; user must resolve |
| **Recoverable** | 0 | Execution continues with degraded functionality |
| **Cancelled** | 130 | User-initiated cancellation |

## Common Issues

### "Prompt is too vague"

**Symptom:** Self-critique flags prompt as "too vague" or "lacking specificity."

**Cause:** Original prompt doesn't provide enough detail for meaningful refinement.

**Solution:**
1. Ask user for more context about the goal
2. Specify the domain or technology involved
3. Describe the expected outcome

### "Cannot find relevant files"

**Symptom:** Context analysis returns no relevant files.

**Cause:** Repository structure doesn't match expected patterns, or the prompt domain doesn't relate to existing code.

**Solution:**
1. Check that the skill is run from the correct directory
2. Use `context_depth: minimal` to skip file scanning
3. Manually specify relevant file paths in the prompt

### "Conflicting requirements"

**Symptom:** E052 error for unresolvable contradictions.

**Cause:** Prompt contains requirements that cannot both be satisfied.

**Solution:**
1. Review the prompt for implicit assumptions
2. Prioritize conflicting requirements
3. Split into separate prompts if needed

## Recovery Procedures

### Fatal Error Recovery

1. Read the error message and code from output
2. Address the specific issue (see table above)
3. Retry the command

### Recoverable Error Recovery

1. Review warnings in the output
2. Decide whether degraded output is acceptable
3. If not, adjust parameters and retry

### After User Cancellation

1. Review the partial output (if any)
2. Consider the feedback that led to cancellation
3. Revise the prompt and retry with adjustments

## Fallback Behavior

When the skill cannot complete execution:

1. **Preserve input** — Original prompt is never modified or lost
2. **Log partial work** — Any gathered context is recorded in run log
3. **Report clearly** — Error code and recovery action are always provided
4. **Fail fast** — Fatal errors stop immediately rather than producing garbage

## Troubleshooting Checklist

```markdown
## Troubleshooting Checklist

### Before Reporting a Bug

- [ ] Verified harness exists (`.octon/` directory)
- [ ] Confirmed input is not empty
- [ ] Checked input file path (if using file input)
- [ ] Reviewed error code and tried suggested action
- [ ] Attempted with `--context_depth=minimal`
- [ ] Ran validation: `./scripts/validate-skills.sh refine-prompt`

### Information to Include in Bug Report

- [ ] Full error message and code
- [ ] Input prompt (redact sensitive content)
- [ ] Parameters used
- [ ] Run log contents
- [ ] Repository structure summary
```

## See Also

- [Run Log Format](/.octon/state/evidence/runs/skills/FORMAT.md) — Structured logging specification
- [Safety Reference](./safety.md) — Behavioral boundaries
- [Validation Reference](./validation.md) — Acceptance criteria
