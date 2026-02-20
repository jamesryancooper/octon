---
# Required when capability: phased
# This file documents the distinct execution phases of the skill.
behavior:
  phases:
    - name: "{{Phase 1 Name}}"
      steps:
        - "{{Step 1}}"
        - "{{Step 2}}"
        - "{{Step 3}}"
    - name: "{{Phase 2 Name}}"
      steps:
        - "{{Step 1}}"
        - "{{Step 2}}"
    - name: "Output"
      steps:
        - "Structure output with all context"
        - "Save to .harmony/output/{{category}}/{{timestamp}}-{{name}}.md"
        - "Log execution to _ops/state/logs/{{skill-id}}/{{run-id}}.md"
  goals:
    - "{{Primary goal}}"
    - "{{Secondary goal}}"
    - "{{Tertiary goal}}"
---

# Phases Reference

**Required when capability:** `phased`

Detailed phase-by-phase execution for the {{skill_name}} skill.

## Phase 1: {{Phase Name}}

{{Description of what this phase accomplishes}}

1. **{{Step 1 name}}**
   - {{Detail 1}}
   - {{Detail 2}}
   - {{Detail 3}}

2. **{{Step 2 name}}**
   - {{Detail 1}}
   - {{Detail 2}}

## Phase 2: {{Phase Name}}

{{Description of what this phase accomplishes}}

1. **{{Step 1 name}}**
   - {{Detail 1}}
   - {{Detail 2}}

2. **{{Step 2 name}}**
   - {{Detail 1}}
   - {{Detail 2}}

## Phase 3: Output

Produce the final output:

1. **Structure output**
   - Organize with clear sections
   - Include all relevant context
   - Format for readability

2. **Save artifacts**
   - Write deliverable to `.harmony/output/{{category}}/{{timestamp}}-{{name}}.md`
   - Log to `_ops/state/logs/{{skill-id}}/{{run-id}}.md`

## Phase Transitions

| From | To | Condition |
|------|-----|-----------|
| Phase 1 | Phase 2 | {{transition_condition}} |
| Phase 2 | Output | {{transition_condition}} |

## {{Optional Reference Tables}}

| Category    | Description      |
|-------------|------------------|
| {{Item 1}}  | {{Description}}  |
| {{Item 2}}  | {{Description}}  |
