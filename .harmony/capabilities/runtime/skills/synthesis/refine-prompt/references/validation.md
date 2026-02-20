---
acceptance_criteria:
  - "Refined prompt exists in .harmony/scaffolding/prompts/"
  - "Persona is assigned with clear role and expertise level"
  - "Context section includes relevant file paths"
  - "Negative constraints section lists what to avoid"
  - "Core intent is preserved and clarified"
  - "All spelling/grammar errors corrected"
  - "Complex requests are decomposed into sub-tasks"
  - "Risks and edge cases are identified"
  - "Success criteria are defined and measurable"
  - "Self-critique pass completed with no major gaps"
  - "Intent confirmed with user (unless skipped)"
  - "Run log captures input, context, and output"
---

# Validation Reference

Acceptance criteria and validation rules for the refine-prompt skill.

## Acceptance Criteria

A refined prompt is valid when:

- [ ] Refined prompt exists in `.harmony/scaffolding/prompts/`
- [ ] Persona is assigned with clear role and expertise level
- [ ] Context section includes relevant file paths
- [ ] Negative constraints section lists what to avoid
- [ ] Core intent is preserved and clarified
- [ ] All spelling/grammar errors corrected
- [ ] Complex requests are decomposed into sub-tasks
- [ ] Risks and edge cases are identified
- [ ] Success criteria are defined and measurable
- [ ] Self-critique pass completed with no major gaps
- [ ] Intent confirmed with user (unless skipped)
- [ ] Run log captures input, context, and output

## Self-Critique Checklist

### Completeness

- Is all necessary context included?
- Are there gaps in the requirements?
- Would someone unfamiliar with the codebase understand this?

### Ambiguity

- Are there any remaining unclear terms?
- Could any requirement be interpreted multiple ways?
- Are all assumptions explicitly stated?

### Feasibility

- Is the scope realistic?
- Are the success criteria measurable?
- Are there any contradictions?

### Quality

- Is the persona appropriate for the task?
- Are the negative constraints comprehensive?
- Is the decomposition logical?

## Validation Rules

### File References

All file paths referenced in the refined prompt must:
- Exist in the codebase
- Be accessible with current permissions
- Be relevant to the task scope

### Scope Limits

- Maximum files in scope: 20
- If exceeded, suggest narrowing focus

### Output Paths

All outputs must be written to:
- `.harmony/scaffolding/prompts/{{timestamp}}-refined.md` (deliverable)
- `_ops/state/logs/refine-prompt/{{run_id}}.md` (execution log)

### Timestamp Format

Use ISO 8601 format: `YYYY-MM-DDTHH:MM:SSZ`

Example: `2025-01-14T12:00:00Z`
