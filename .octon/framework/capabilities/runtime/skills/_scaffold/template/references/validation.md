---
acceptance_criteria:
  - "{{Criterion 1: what must be true for success}}"
  - "{{Criterion 2}}"
  - "{{Criterion 3}}"
  - "Output exists in designated .octon/generated/{{category}}/ location"
  - "Run log captures input, context, and output"
---

# Validation Reference

**Required when capability:** `self-validating`

Acceptance criteria and validation rules for the skill-name skill.

## Acceptance Criteria

A successful execution requires:

- [ ] {{Criterion 1}}
- [ ] {{Criterion 2}}
- [ ] {{Criterion 3}}
- [ ] Output exists in `.octon/generated/{{category}}/`
- [ ] Run log captures input, context, and output

## Quality Checklist

### Completeness

- Is all necessary information included?
- Are there gaps in the output?
- Would someone unfamiliar understand the result?

### Accuracy

- Is the output factually correct?
- Are all references valid?
- Are assumptions explicitly stated?

### Format

- Is the output properly structured?
- Are sections clearly labeled?
- Is the formatting consistent?

## Validation Rules

### Output Requirements

All outputs must:

- Be written to designated output paths
- Include timestamp in filename
- Follow the expected format

### Scope Limits

- {{Limit 1, e.g., Maximum items: 20}}
- If exceeded, {{action to take}}

### Output Paths

All outputs must be written to:

- `.octon/generated/{{category}}/{{timestamp}}-{{name}}.md` (deliverable)
- `/.octon/state/evidence/runs/skills/{{skill-id}}/{{run-id}}.md` (execution log)

### Timestamp Format

Use ISO 8601 format: `YYYY-MM-DDTHH:MM:SSZ`

Example: `2025-01-15T12:00:00Z`
