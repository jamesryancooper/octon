---
# Error Handling Reference
# Documents error conditions, recovery procedures, and troubleshooting.
#
# Error codes follow the standard format defined in:
# .harmony/capabilities/skills/logs/FORMAT.md
errors:
  - code: "E001"
    condition: "Input folder path is empty or not provided"
    severity: fatal
    message: "Input folder path is required"
    action: "Provide a valid folder path containing research notes"

  - code: "E002"
    condition: "Input folder does not exist"
    severity: fatal
    message: "Folder not found: {{path}}"
    action: "Verify folder path and ensure it exists"

  - code: "E003"
    condition: "Input folder contains no .md files"
    severity: fatal
    message: "No markdown files found in: {{path}}"
    action: "Ensure folder contains .md files with research notes"

  - code: "E004"
    condition: "Input folder contains too many files (>50)"
    severity: recoverable
    message: "Large input: {{count}} files found"
    action: "Process first 50 files; suggest splitting into batches"

  - code: "E010"
    condition: "Processing timeout during file reading"
    severity: recoverable
    message: "Timeout reading files"
    action: "Reduce number of input files or file sizes"

  - code: "E011"
    condition: "Cannot parse markdown file"
    severity: recoverable
    message: "Parse error in: {{file}}"
    action: "Skip malformed file; continue with valid files"

  - code: "E012"
    condition: "No extractable findings in source files"
    severity: fatal
    message: "No findings could be extracted from source files"
    action: "Ensure files contain substantive research content"

  - code: "E020"
    condition: "Cannot write to output path"
    severity: fatal
    message: "Cannot write to: {{path}}"
    action: "Check permissions; verify path is within allowed scope"

  - code: "E021"
    condition: "Output would overwrite existing file"
    severity: recoverable
    message: "Output file already exists: {{path}}"
    action: "Use timestamped filename to avoid collision"

  - code: "E030"
    condition: "Harness directory not found"
    severity: fatal
    message: "Harness directory not found: .harmony/"
    action: "Initialize harness or run from correct directory"

  - code: "E040"
    condition: "Required tool not available"
    severity: fatal
    message: "Required tool not available: {{tool}}"
    action: "Verify skill has correct allowed-tools in SKILL.md"

  - code: "E050"
    condition: "Research goal unclear after analysis"
    severity: recoverable
    message: "Research goal could not be determined"
    action: "Ask user one clarifying question about synthesis focus"

  - code: "E051"
    condition: "Major contradictions in source materials"
    severity: recoverable
    message: "Major contradictions found that cannot be automatically resolved"
    action: "Flag contradictions for human review; document in output"

  - code: "E052"
    condition: "Sources span domains requiring specialized expertise"
    severity: recoverable
    message: "Sources span multiple specialized domains"
    action: "Note limitation in output; proceed with general synthesis"

fallback_behavior: |
  When execution cannot complete:
  1. Log list of files that were successfully read
  2. Report any partial findings extracted
  3. Write error details to run log
  4. Report specific error code and recovery action
---

# Error Handling Reference

Error conditions, recovery procedures, and troubleshooting for the synthesize-research skill.

## Error Codes

| Code | Severity | Condition | Action |
|------|----------|-----------|--------|
| E001 | Fatal | No input folder provided | Provide folder path |
| E002 | Fatal | Input folder not found | Verify path exists |
| E003 | Fatal | No .md files in folder | Add markdown files |
| E004 | Recoverable | Too many files (>50) | Processes first 50 |
| E010 | Recoverable | Timeout reading files | Reduce input size |
| E011 | Recoverable | Cannot parse markdown file | Skips malformed file |
| E012 | Fatal | No findings extractable | Add substantive content |
| E020 | Fatal | Cannot write output | Check path/permissions |
| E021 | Recoverable | Output file exists | Uses timestamped name |
| E030 | Fatal | Harness not found | Initialize harness |
| E040 | Fatal | Required tool unavailable | Check allowed-tools |
| E050 | Recoverable | Unclear research goal | Asks clarifying question |
| E051 | Recoverable | Major contradictions | Flags for human review |
| E052 | Recoverable | Multi-domain sources | Notes limitation |

## Severity Levels

| Severity | Exit Code | Behavior |
|----------|-----------|----------|
| **Fatal** | 1 | Execution stops; user must resolve |
| **Recoverable** | 0 | Execution continues with degraded functionality |

## Common Issues

### "No findings could be extracted"

**Symptom:** E012 error despite having markdown files in the folder.

**Cause:** Files exist but contain no substantive research content (e.g., only headers, empty sections, or boilerplate).

**Solution:**

1. Ensure files contain actual research notes with findings
2. Check that content includes conclusions, observations, or data
3. Verify files are not templates with placeholder text

### "Major contradictions found"

**Symptom:** Output includes unresolved contradictions section with E051 warning.

**Cause:** Source materials contain genuinely conflicting information.

**Solution:**

1. Review the contradictions table in output
2. Determine which source is authoritative
3. Either:
   - Resolve contradictions in source files and re-run
   - Accept the flagged contradictions and resolve in synthesis

### "Research goal unclear"

**Symptom:** E050 warning and skill asks a clarifying question.

**Cause:** Source materials span multiple topics without clear focus.

**Solution:**

1. Answer the clarifying question to provide focus
2. Or, organize source files into topic-specific subfolders
3. Run synthesis on each subfolder separately

### "Parse error in file"

**Symptom:** E011 warning with specific file name.

**Cause:** Markdown file has syntax issues or unexpected encoding.

**Solution:**

1. Open the file and check for malformed markdown
2. Verify file encoding is UTF-8
3. Fix or remove problematic file

## Recovery Procedures

### Fatal Error Recovery

1. Read the error message and code from output
2. Address the specific issue (see table above)
3. Retry the command

### Recoverable Error Recovery

1. Review warnings in the output
2. Check the "Issues & Warnings" section of synthesis
3. Decide whether to accept limitations or fix and retry

### Partial Success

When synthesis completes with warnings:

1. Output is still produced but may be incomplete
2. Check the "Sources Reviewed" section to see what was processed
3. Review "Open Questions" for gaps that need follow-up

## Fallback Behavior

When the skill cannot complete execution:

1. **List processed files** — Shows which files were successfully read
2. **Report partial findings** — Any findings extracted before failure
3. **Preserve source files** — Input is never modified
4. **Detailed logging** — Full error context in run log

## Input Quality Guidelines

To avoid errors, ensure input files:

| Guideline | Why |
|-----------|-----|
| Use `.md` extension | Skill only reads markdown files |
| Include substantive content | Headers alone won't synthesize |
| Use clear headings | Helps identify themes |
| State conclusions explicitly | "We found that..." patterns |
| Keep file size reasonable | <100KB per file recommended |
| Use UTF-8 encoding | Other encodings may fail |

## Troubleshooting Checklist

```markdown
## Troubleshooting Checklist

### Before Reporting a Bug

- [ ] Verified harness exists (`.harmony/` directory)
- [ ] Confirmed input folder path is correct
- [ ] Checked folder contains `.md` files
- [ ] Verified files have substantive content (not just headers)
- [ ] Reviewed error code and tried suggested action
- [ ] Ran validation: `./scripts/validate-skills.sh synthesize-research`

### Information to Include in Bug Report

- [ ] Full error message and code
- [ ] Input folder path
- [ ] Number of files in folder
- [ ] Sample file names (not content)
- [ ] Run log contents
```

## See Also

- [Run Log Format](../../../.harmony/capabilities/skills/logs/FORMAT.md) — Structured logging specification
- [Safety Reference](./safety.md) — Behavioral boundaries
- [Validation Reference](./validation.md) — Acceptance criteria
