---
name: "[workflow-id]"
description: "[Brief summary of what this workflow does and when to use it. Max 1024 characters.]"
steps:
  - id: "[step-id]"
    file: 01-step.md
    description: "[Brief step description]"
  - id: verify
    file: NN-verify.md
    description: "Validate workflow executed successfully."
# --- Harmony extensions (optional) ---
access: human
version: "1.0.0"
depends_on: []
checkpoints:
  enabled: true
  storage: ".harmony/continuity/checkpoints/"
parallel_steps: []
---

# [Workflow Title]: Overview

[One-line description of what this workflow accomplishes.]

## Usage

```text
/[command] <arguments>
```

**Example:**

```text
/[command] example-argument
```

## Target

[What this workflow operates on - files, directories, systems, etc.]

## Prerequisites

- [Prerequisite 1]
- [Prerequisite 2]

## Failure Conditions

- [Condition 1] -> STOP, [action to take]
- [Condition 2] -> STOP, [action to take]

## Steps

1. [Step name](./01-step.md) - [Brief description]
2. `NN-<step-name>.md` - [Optional additional step files, if needed]
N. [Verify](./NN-verify.md) - Validate workflow executed successfully

## Verification Gate

[Workflow name] is NOT complete until:

- [ ] [Completion criterion 1]
- [ ] [Completion criterion 2]
- [ ] Verification step passes

## Version History

| Version | Date | Changes |
| ------- | ---- | ------- |
| 1.0.0 | YYYY-MM-DD | Initial version |

## References

- **Canonical:** `[path to canonical documentation]`
- **Related:** `[related workflow or command path]`
