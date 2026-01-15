---
behavior:
  phases:
    - name: "[Phase 1 Name]"
      steps:
        - "[Step 1]"
        - "[Step 2]"
        - "[Step 3]"
    - name: "[Phase 2 Name]"
      steps:
        - "[Step 1]"
        - "[Step 2]"
    - name: "Output"
      steps:
        - "Structure output with all context"
        - "Save to outputs/[category]/<timestamp>-[name].md"
        - "Log execution to logs/runs/"
  goals:
    - "[Primary goal]"
    - "[Secondary goal]"
    - "[Tertiary goal]"
---

# Behavior Reference

Detailed phase-by-phase behavior for the skill-name skill.

## Phase 1: [Phase Name]

[Description of what this phase accomplishes]

1. **[Step 1 name]**
   - [Detail 1]
   - [Detail 2]
   - [Detail 3]

2. **[Step 2 name]**
   - [Detail 1]
   - [Detail 2]

## Phase 2: [Phase Name]

[Description of what this phase accomplishes]

1. **[Step 1 name]**
   - [Detail 1]
   - [Detail 2]

2. **[Step 2 name]**
   - [Detail 1]
   - [Detail 2]

## Phase 3: Output

Produce the final output:

1. **Structure output**
   - Organize with clear sections
   - Include all relevant context
   - Format for readability

2. **Save artifacts**
   - Write to `outputs/[category]/<timestamp>-[name].md`
   - Log to `logs/runs/<timestamp>-skill-name.md`

## [Optional Reference Tables]

| Category | Description |
|----------|-------------|
| [Item 1] | [Description] |
| [Item 2] | [Description] |
