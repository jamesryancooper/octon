---
title: Initialize Skill
description: Update SKILL.md with ID and initial values.
---

# Step 3: Initialize Skill

## Input

- `skill-id` from Step 1
- `SKILL.md` template from Step 2

## Actions

Update `skills/<skill-id>/SKILL.md` frontmatter and content:

```text
1. Replace placeholders with actual skill-id:
   - id: "<skill-id>"
   - name: "[Skill Name - TODO]"
   - explicit_call_patterns: ["use skill: <skill-id>"]
   - commands: [/<skill-id>]
   - All other [skill-id] placeholders in content

2. Set initial values:
   - version: "0.1.0"
   - created_at: "[current date YYYY-MM-DD]"
   - updated_at: "[current date YYYY-MM-DD]"

3. Leave other placeholders for user to fill:
   - summary
   - description
   - author
   - triggers
   - inputs/outputs
   - behavior goals/steps
   - acceptance criteria
   - examples
```

## Verification

- Frontmatter has correct `id`
- `commands` array has `/<skill-id>`
- `explicit_call_patterns` has `use skill: <skill-id>`
- Dates are set to current date

## Output

- Initialized `SKILL.md` ready for user customization
- Proceed to Step 4
