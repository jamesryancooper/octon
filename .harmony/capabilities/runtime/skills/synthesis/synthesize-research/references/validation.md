---
acceptance_criteria:
  - "Synthesis document exists in .harmony/output/drafts/"
  - "Document includes executive summary (3-5 sentences)"
  - "Key findings are organized by theme (3-7 themes)"
  - "Each theme has insight, evidence, and confidence level"
  - "Contradictions are listed with resolutions or marked unresolved"
  - "Open questions are clearly listed"
  - "All source files are listed in Sources Reviewed"
  - "Run log captures inputs, outputs, and status"
  - "No errors during execution"
  - "Output follows expected format"
---

# Validation Reference

Acceptance criteria and quality checklist for the synthesize-research skill.

## Acceptance Criteria

- [ ] Synthesis document exists in `.harmony/output/drafts/`
- [ ] Document includes executive summary (3-5 sentences)
- [ ] Key findings are organized by theme (3-7 themes)
- [ ] Each theme has insight, evidence, and confidence level
- [ ] Contradictions are listed with resolutions or marked unresolved
- [ ] Open questions are clearly listed
- [ ] All source files are listed in Sources Reviewed
- [ ] Run log captures inputs, outputs, and status
- [ ] No errors during execution
- [ ] Output follows expected format

## Quality Checklist

### Completeness

- [ ] Are all source files reflected in the synthesis?
- [ ] Are there findings in source files that weren't captured?
- [ ] Would someone unfamiliar with the research understand the synthesis?
- [ ] Are gaps and open questions explicitly acknowledged?

### Accuracy

- [ ] Are all findings accurately represented?
- [ ] Are confidence levels appropriate for the evidence?
- [ ] Are source attributions correct?
- [ ] Are contradictions accurately identified?

### Format

- [ ] Does the synthesis follow the standard format?
- [ ] Are sections clearly labeled?
- [ ] Is formatting consistent throughout?
- [ ] Are tables properly formatted?

### Coherence

- [ ] Does the executive summary capture the key points?
- [ ] Are themes logically organized?
- [ ] Do findings flow logically within each theme?
- [ ] Is the document readable as a standalone artifact?

## Validation Rules

### Output Requirements

| Requirement | Validation |
|-------------|------------|
| Executive summary | 3-5 sentences, captures key takeaways |
| Theme count | 3-7 themes (unless source material is very limited) |
| Theme structure | Each theme has: insight, evidence (2+ points), confidence |
| Source attribution | Every finding cites at least one source file |
| Contradictions | Table format with Finding A, Finding B, Resolution |
| Open questions | Numbered list of unanswered questions |

### Scope Limits

| Limit | Value | Rationale |
|-------|-------|-----------|
| Maximum source files | 50 | Beyond this, consider splitting into sub-topics |
| Minimum source files | 1 | At least one file required |
| Maximum themes | 7 | More themes indicate need for hierarchical structure |
| Minimum themes | 2 | Single theme suggests narrow focus |

### Path Rules

| Path Type | Pattern | Example |
|-----------|---------|---------|
| Synthesis output | `.harmony/output/drafts/{{topic}}-synthesis.md` | `.harmony/output/drafts/api-design-synthesis.md` |
| Run log | `_ops/state/logs/synthesize-research/{{run_id}}.md` | `_ops/state/logs/synthesize-research/2025-01-12-api-design.md` |

## Error Conditions

| Condition | Expected Behavior |
|-----------|-------------------|
| Empty input folder | Error message, no output created |
| No markdown files | Error message, no output created |
| Unreadable files | Skip file, note in run log, continue |
| Invalid path | Error message, no output created |

## Success Indicators

A successful synthesis run:

1. Creates a synthesis document at the expected path
2. Creates a run log at the expected path
3. Run log shows `status: success`
4. Synthesis document passes all acceptance criteria
5. No error messages in run log
