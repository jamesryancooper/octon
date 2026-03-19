---
# Checkpoint State Documentation (Stateful Pattern)
# Add this file when your Complex skill maintains state across phases.
#
# When to use:
# - Skill supports checkpoint/resume from interruption
# - Skill produces intermediate outputs that must persist
# - Skill needs audit trail of phase transitions
#
# See: .octon/framework/capabilities/_meta/architecture/reference-artifacts.md#checkpointsmd
#
checkpoints:
  strategy: phase                    # phase | step | time-based
  storage: ".octon/state/control/skills/checkpoints/{{skill-id}}/{{run-id}}/"
  retention: session                 # session | permanent

  schema:
    - name: "{{phase_1_name}}_complete"
      trigger: "After {{Phase 1}} completes"
      contains:
        - "input_hash"               # Hash of original input
        - "{{intermediate_data_1}}"  # Replace with actual data
        - "{{decisions_made}}"       # Choices recorded

    - name: "{{phase_2_name}}_complete"
      trigger: "After {{Phase 2}} completes"
      contains:
        - "{{transformed_data}}"
        - "{{validation_results}}"

recovery:
  on_resume: "Load latest checkpoint, verify input unchanged, continue from saved phase"
  on_input_change: "Warn user, offer to restart or continue with stale context"
  on_corruption: "Log error, restart from beginning, preserve corrupted checkpoint for debugging"
---

# Checkpoint Reference

**Required when capability:** `stateful` or `resumable`

State management for the {{skill-name}} skill.

> **When to Add This File:**
>
> - Skill maintains state across phases via checkpoints
> - Skill supports resume from interruption
> - Skill produces intermediate outputs that must persist

## Checkpoint Strategy

**Strategy:** {{phase | step | time-based}}

Describe when and why checkpoints are created. Common strategies:

| Strategy | When to Use |
|----------|-------------|
| **phase** | Checkpoint after each major phase completes |
| **step** | Checkpoint after each discrete step (more granular) |
| **time-based** | Checkpoint at regular intervals (for long-running skills) |

## State Schema

### Checkpoint: {{phase_1_name}}_complete

**Trigger:** After {{Phase 1}} completes

**Contains:**

| Field | Type | Description |
|-------|------|-------------|
| `input_hash` | string | Hash of original input for change detection |
| `{{field_1}}` | {{type}} | {{description}} |
| `{{field_2}}` | {{type}} | {{description}} |

### Checkpoint: {{phase_2_name}}_complete

**Trigger:** After {{Phase 2}} completes

**Contains:**

| Field | Type | Description |
|-------|------|-------------|
| `{{field_1}}` | {{type}} | {{description}} |
| `{{field_2}}` | {{type}} | {{description}} |

## Recovery Procedures

### On Resume

1. Load the latest checkpoint from storage
2. Verify input hash matches current input
3. If unchanged, continue from saved phase
4. If changed, prompt user: restart or continue with stale context

### On Input Change

When input has changed since checkpoint:

- Warn user about potential inconsistency
- Offer options:
  - Restart from beginning (safe)
  - Continue with stale context (fast but potentially inconsistent)

### On Corruption

When checkpoint file is corrupted or invalid:

1. Log the error with checkpoint path
2. Preserve corrupted file for debugging (rename with `.corrupted` suffix)
3. Restart from beginning
4. Notify user of the recovery action

## Intermediate Outputs

Files produced during execution (not just final output):

| Output | Path | Purpose |
|--------|------|---------|
| Phase 1 checkpoint | `/.octon/state/control/skills/checkpoints/{{run-id}}/phase1.json` | {{purpose}} |
| Phase 2 checkpoint | `/.octon/state/control/skills/checkpoints/{{run-id}}/phase2.json` | {{purpose}} |

---

## Worked Example: Checkpoint Recovery

This example shows how a skill recovers from interruption using checkpoints, based on the `refactor` skill pattern.

### Scenario

User runs: `/refactor .scratch/ → .scratchpad/`

Execution is interrupted during Phase 4 (Execute) after completing 7 of 13 file changes.

### Checkpoint State at Interruption

```yaml
# .octon/state/control/skills/checkpoints/refactor/2026-01-22-scratch-to-scratchpad/checkpoint.yml
skill: refactor
version: "1.0.0"
status: in_progress
current_phase: 4

phases:
  1_define_scope:
    status: completed
    completed_at: "2026-01-22T10:00:00Z"
    output: scope.md
  2_audit:
    status: completed
    completed_at: "2026-01-22T10:02:00Z"
    output: audit-manifest.md
    metrics:
      files_found: 13
      total_matches: 47
  3_plan:
    status: completed
    completed_at: "2026-01-22T10:03:00Z"
    output: change-manifest.md
  4_execute:
    status: in_progress
    started_at: "2026-01-22T10:04:00Z"
    output: execution-log.md
    progress:
      total_items: 13
      completed_items: 7
      current_item: ".octon/framework/orchestration/runtime/workflows/example.md"
  5_verify:
    status: pending
  6_document:
    status: pending

resume:
  phase: 4
  instruction: "Continue from item 8 in change-manifest.md"
  last_completed: ".octon/framework/cognition/runtime/context/reference/tools.md"
```

### Recovery Flow

When user invokes `/refactor .scratch/ → .scratchpad/` again:

```text
┌─────────────────────────────────────────────────────────────────┐
│  CHECKPOINT RECOVERY FLOW                                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. DETECT CHECKPOINT                                           │
│     Look for: /.octon/state/control/skills/checkpoints/refactor/*scratch-to-scratchpad*/checkpoint  │
│     Found: 2026-01-22-scratch-to-scratchpad/checkpoint.yml      │
│                                                                  │
│  2. READ CHECKPOINT (~50 tokens)                                │
│     status: in_progress                                          │
│     current_phase: 4                                             │
│     progress.completed_items: 7                                  │
│                                                                  │
│  3. PROMPT USER                                                  │
│     "Found existing refactor in progress (7/13 items complete). │
│      Resume from Phase 4? [Y/n]"                                │
│                                                                  │
│  4. ON RESUME                                                   │
│     - Read change-manifest.md                                   │
│     - Skip items 1-7 (already completed)                        │
│     - Continue from item 8: .octon/framework/orchestration/runtime/workflows/example.md       │
│     - Mark items complete as they finish                        │
│     - Update checkpoint.progress.completed_items incrementally  │
│                                                                  │
│  5. COMPLETE PHASE 4                                            │
│     progress.completed_items: 13                                │
│     status: completed                                            │
│                                                                  │
│  6. PROCEED TO PHASE 5 (Verify)                                 │
│     Normal execution continues                                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Recovery Decision Matrix

| Checkpoint State | User Action | System Response |
|------------------|-------------|-----------------|
| `status: completed` | Invoke same scope | "Already complete. Start new?" |
| `status: in_progress`, phase 1-3 | Invoke same scope | "Resume from Phase N?" |
| `status: in_progress`, phase 4 | Invoke same scope | "Resume from item M?" (shows progress) |
| `status: in_progress`, phase 5 (failed) | Invoke same scope | "Verification failed. Return to Phase 4?" |
| `status: failed` | Invoke same scope | "Previous attempt failed at Phase N. Retry?" |
| Input changed since checkpoint | Invoke same scope | "Input changed. Restart or continue with stale context?" |

### Key Recovery Guarantees

1. **No duplicate changes:** Completed items are tracked; resumption starts from next item
2. **State consistency:** Checkpoint is updated after each item, not batched
3. **Verification still required:** Even after successful resume, verification phase runs fully
4. **User control:** User always prompted before resume; can choose to restart fresh

### Implementing Recovery in Your Skill

```yaml
# In your skill's phases.md, add resumption logic:
resumption:
  detection:
    pattern: "/.octon/state/control/skills/checkpoints/{{skill-id}}/*{{scope-slug}}*/checkpoint.yml"
    load_tokens: 50  # Keep checkpoint small for fast detection

  decision_matrix:
    - condition: "status == completed"
      prompt: "{{skill}} already complete for this scope. Start new?"
      options: [start_new, view_results]

    - condition: "status == in_progress AND current_phase <= 3"
      prompt: "Resume from Phase {{current_phase}}?"
      options: [resume, restart, abort]

    - condition: "status == in_progress AND current_phase == 4"
      prompt: "Resume execution ({{completed}}/{{total}} items done)?"
      options: [resume, restart, abort]

    - condition: "status == failed"
      prompt: "Previous attempt failed at Phase {{current_phase}}. Retry?"
      options: [retry, restart, abort]

  on_resume:
    - "Load phase outputs from checkpoint"
    - "Validate intermediate artifacts still exist"
    - "Continue from resume.instruction"
    - "Update checkpoint incrementally"
```
