---
# Decision Logic Documentation (Phased/Procedural Pattern)
# Add this file when your Complex skill has conditional execution paths.
#
# When to use:
# - Skill has multiple execution paths based on input characteristics
# - Skill branches based on intermediate results
# - Skill requires user choices at decision points
#
# See: .octon/capabilities/_meta/architecture/reference-artifacts.md#decisionsmd
#
decisions:
  - id: "{{decision_1_id}}"
    point: "Phase {{N}}: {{Phase Name}}"
    question: "{{What question does this decision answer?}}"
    branches:
      - condition: "{{Condition for branch A}}"
        label: "{{branch_a_label}}"
        next_phase: "Phase {{N+1a}}: {{Phase Name}}"

      - condition: "{{Condition for branch B}}"
        label: "{{branch_b_label}}"
        next_phase: "Phase {{N+1b}}: {{Phase Name}}"

      - condition: "{{Condition for branch C}}"
        label: "{{branch_c_label}}"
        next_phase: "Phase {{N+1c}}: {{Phase Name}}"
        escalate: true               # Requires user confirmation

  - id: "{{decision_2_id}}"
    point: "Phase {{M}}: {{Phase Name}}"
    question: "{{What question does this decision answer?}}"
    branches:
      - condition: "{{Success condition}}"
        label: "success"
        next_phase: "Phase {{M+1}}: {{Phase Name}}"

      - condition: "{{Recoverable failure condition}}"
        label: "retry"
        next_phase: "Phase {{M-1}}: {{Previous Phase}} (retry)"
        max_retries: 2

      - condition: "{{Unrecoverable failure condition}}"
        label: "abort"
        next_phase: "Escalate to user"

default_path: ["Phase 1", "Phase 2", "Phase 3", "Phase 4", "Output"]
---

# Decision Reference

**Required when capability:** `branching`

Branching logic for the {{skill-name}} skill.

> **When to Add This File:**
>
> - Skill has multiple execution paths based on conditions
> - Skill branches based on intermediate results
> - Skill requires user choices at decision points

## Decision Points

### {{decision_1_id}}: {{Decision Name}}

**Point:** Phase {{N}}: {{Phase Name}}

**Question:** {{What question does this decision answer?}}

| Condition | Label | Next Phase | Notes |
|-----------|-------|------------|-------|
| {{Condition A}} | {{branch_a}} | Phase {{N+1a}} | {{notes}} |
| {{Condition B}} | {{branch_b}} | Phase {{N+1b}} | {{notes}} |
| {{Condition C}} | {{branch_c}} | Phase {{N+1c}} | Escalate to user |

### {{decision_2_id}}: {{Decision Name}}

**Point:** Phase {{M}}: {{Phase Name}}

**Question:** {{What question does this decision answer?}}

| Condition | Label | Next Phase | Notes |
|-----------|-------|------------|-------|
| {{Success condition}} | success | Phase {{M+1}} | Continue normally |
| {{Recoverable failure}} | retry | Phase {{M-1}} (retry) | Max 2 retries |
| {{Unrecoverable failure}} | abort | Escalate to user | Cannot proceed |

## Execution Paths

### Happy Path (Default)

The most common execution path when no special conditions apply:

1. Phase 1: {{Phase Name}}
2. Phase 2: {{Phase Name}}
3. Phase 3: {{Phase Name}}
4. Phase 4: {{Phase Name}}
5. Output

### Path: {{path_name}}

When {{condition that triggers this path}}:

1. Phase 1: {{Phase Name}}
2. Phase 2a: {{Alternative Phase Name}}
3. Phase 3: {{Phase Name}}
4. Output

### Path: {{another_path_name}}

When {{condition that triggers this path}}:

1. Phase 1: {{Phase Name}}
2. Phase 2: {{Phase Name}} → Decision: retry
3. Phase 2: {{Phase Name}} (retry)
4. Phase 3: {{Phase Name}}
5. Output

## Escalation Triggers

Conditions that require user intervention:

| Trigger | Decision Point | Action |
|---------|---------------|--------|
| {{Trigger 1}} | {{decision_id}} | Pause and ask user to confirm |
| {{Trigger 2}} | {{decision_id}} | Present options to user |
| {{Trigger 3}} | {{decision_id}} | Abort with explanation |

## Decision Tree

```
Start
  │
  ▼
Phase 1
  │
  ▼
Decision: {{decision_1_id}}
  ├── {{branch_a}} ──▶ Phase 2a
  ├── {{branch_b}} ──▶ Phase 2b
  └── {{branch_c}} ──▶ Phase 2c (escalate)
                           │
                           ▼
                      User Decision
                           │
  ┌────────────────────────┴────────────────────────┐
  ▼                                                 ▼
Phase 3                                         Abort
  │
  ▼
Decision: {{decision_2_id}}
  ├── success ──▶ Phase 4 ──▶ Output
  ├── retry ──▶ Phase 3 (retry, max 2)
  └── abort ──▶ Escalate to user
```

Replace with actual decision flow diagram.
