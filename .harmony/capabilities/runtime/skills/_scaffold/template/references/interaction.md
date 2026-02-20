---
# Human Collaboration Documentation (Interactive Pattern)
# Add this file when your skill requires user input at runtime.
#
# When to use:
# - Skill has decision points requiring user input
# - Skill has approval gates before proceeding
# - Skill supports interactive refinement loops
#
# See: .harmony/capabilities/_meta/architecture/reference-artifacts.md#interactionmd
#
interaction:
  pattern: approval                  # approval | decision | iterative

  interaction_points:
    - id: "{{interaction_1_id}}"
      phase: {{phase_number}}
      type: approval                 # approval | decision | input
      question: "{{Question to ask user}}"
      options: ["Yes", "No", "Modify"]
      required: true
      timeout: null                  # null = wait indefinitely
      # Pause/wait signaling
      signal:
        method: checkpoint           # checkpoint | block | poll
        state_persistence:
          location: "_ops/state/runs/{{run-id}}/pending_interaction.json"
          ttl: null                  # null = persist until resolved
        resume_trigger: user_response

    - id: "{{interaction_2_id}}"
      phase: {{phase_number}}
      type: decision
      question: "{{Question to ask user}}"
      options: dynamic               # dynamic = generated at runtime
      required: true
      signal:
        method: checkpoint
        state_persistence:
          location: "_ops/state/runs/{{run-id}}/pending_interaction.json"
          ttl: 86400000              # 24 hours in ms

  # State persistence during pause
  state_persistence:
    strategy: checkpoint             # checkpoint | memory | hybrid
    location: "_ops/state/runs/{{skill-id}}/{{run-id}}/"
    artifacts:
      - name: "execution_state"
        file: "state.json"
        contains: ["current_phase", "completed_phases", "intermediate_results"]
      - name: "pending_interaction"
        file: "pending_interaction.json"
        contains: ["interaction_id", "question", "options", "context", "timestamp"]
      - name: "user_response"
        file: "user_response.json"
        contains: ["interaction_id", "response", "timestamp", "metadata"]

  fallback:
    on_timeout: abort                # abort | use_default | escalate
    default_option: null
---

# Interaction Reference

**Required when capability:** `human-collaborative`

Human collaboration design for the {{skill-name}} skill.

> **When to Add This File:**
>
> - Skill has decision points requiring user input
> - Skill has approval gates before proceeding
> - Skill supports interactive refinement loops

## Interaction Pattern

**Pattern:** {{approval | decision | iterative}}

| Pattern | Description | Use When |
|---------|-------------|----------|
| **approval** | User confirms before skill proceeds | High-stakes actions needing explicit consent |
| **decision** | User chooses between options | Multiple valid paths, user preference matters |
| **iterative** | User refines output through cycles | Quality-sensitive output, feedback loops |

## How Pause/Wait Signaling Works

When a skill reaches an interaction point, it must **signal pause and wait** for user input. This section defines the protocol.

### Signaling Methods

| Method | Description | When to Use |
|--------|-------------|-------------|
| **checkpoint** | Save full state to disk, exit cleanly | Long waits, session may close |
| **block** | Hold execution in memory, await response | Quick decisions, active session |
| **poll** | Periodically check for response file | Async workflows, batch processing |

### Pause/Wait Protocol

```text
Skill Execution
     │
     ▼
Reach Interaction Point
     │
     ├── 1. SAVE STATE
     │       Write execution_state.json:
     │       {
     │         "run_id": "abc-123",
     │         "phase": 2,
     │         "status": "waiting_for_input",
     │         "checkpoint_data": { ... },
     │         "timestamp": "2024-01-15T10:30:00Z"
     │       }
     │
     ├── 2. CREATE INTERACTION REQUEST
     │       Write pending_interaction.json:
     │       {
     │         "interaction_id": "scope_approval",
     │         "question": "Proceed with 47 file modifications?",
     │         "options": ["Yes", "No", "Show details"],
     │         "context": { "file_count": 47, "scope_summary": "..." },
     │         "timeout": null,
     │         "timestamp": "2024-01-15T10:30:00Z"
     │       }
     │
     ├── 3. SIGNAL PAUSE
     │       Return control to runtime with:
     │       {
     │         "status": "paused",
     │         "reason": "awaiting_user_input",
     │         "interaction_id": "scope_approval",
     │         "resume_instruction": "Run with --resume abc-123"
     │       }
     │
     ▼
[SKILL PAUSED - WAITING FOR USER]
     │
     ▼
User Provides Response
     │
     ├── 4. RECORD RESPONSE
     │       Write user_response.json:
     │       {
     │         "interaction_id": "scope_approval",
     │         "response": "Yes",
     │         "timestamp": "2024-01-15T10:32:00Z",
     │         "metadata": { "response_time_ms": 120000 }
     │       }
     │
     ├── 5. RESUME EXECUTION
     │       Load execution_state.json
     │       Validate response matches pending interaction
     │       Continue from checkpoint
     │
     ▼
Skill Continues Execution
```

### State Persistence During Pause

When paused, the skill preserves all context needed for seamless resume:

**Persisted Artifacts:**

| Artifact | Location | Purpose |
|----------|----------|---------|
| `execution_state.json` | `_ops/state/runs/{{run-id}}/state.json` | Full checkpoint: phase, intermediate results, decisions |
| `pending_interaction.json` | `_ops/state/runs/{{run-id}}/pending_interaction.json` | Current question, options, context for UI |
| `user_response.json` | `_ops/state/runs/{{run-id}}/user_response.json` | User's answer (written by runtime, read on resume) |

**State Schema:**

```json
// execution_state.json
{
  "run_id": "{{run-id}}",
  "skill_id": "{{skill-id}}",
  "status": "waiting_for_input",
  "current_phase": 2,
  "completed_phases": [1],
  "checkpoint_data": {
    "phase_1_result": { ... },
    "decisions_made": { ... }
  },
  "paused_at": "2024-01-15T10:30:00Z",
  "interaction_id": "scope_approval"
}
```

```json
// pending_interaction.json
{
  "interaction_id": "scope_approval",
  "phase": 2,
  "type": "approval",
  "question": "The refactor will modify 47 files. Proceed?",
  "options": [
    { "value": "yes", "label": "Yes, proceed", "description": "Continue with modifications" },
    { "value": "no", "label": "No, cancel", "description": "Abort without changes" },
    { "value": "details", "label": "Show details", "description": "List affected files" }
  ],
  "context": {
    "file_count": 47,
    "affected_modules": ["auth", "api", "tests"],
    "scope_summary": "Rename 'userId' to 'user_id' across codebase"
  },
  "timeout": null,
  "created_at": "2024-01-15T10:30:00Z"
}
```

```json
// user_response.json (written by runtime after user responds)
{
  "interaction_id": "scope_approval",
  "response": "yes",
  "response_label": "Yes, proceed",
  "timestamp": "2024-01-15T10:32:00Z",
  "metadata": {
    "response_time_ms": 120000,
    "input_method": "button_click"
  }
}
```

### Resume Protocol

When resuming after a pause:

1. **Locate checkpoint:** Find `_ops/state/runs/{{run-id}}/state.json`
2. **Validate state:** Confirm `status === "waiting_for_input"`
3. **Check for response:** Look for `user_response.json`
4. **Validate response:** Ensure `interaction_id` matches pending interaction
5. **Load checkpoint:** Restore `checkpoint_data` into memory
6. **Continue execution:** Jump to recorded phase, apply user's decision

**Resume Command:**

```bash
/{{skill-name}} --resume {{run-id}}
```

## Interaction Points

### {{interaction_1_id}}: {{Interaction Name}}

**Phase:** {{phase_number}}
**Type:** {{approval | decision | input}}
**Required:** {{true | false}}
**Blocking:** Yes (skill pauses until resolved)

**Question:** {{Question presented to user}}

**Options:**

| Value | Label | Effect |
|-------|-------|--------|
| `yes` | Yes, proceed | {{Continue to next phase}} |
| `no` | No, cancel | {{Abort execution, preserve state}} |
| `modify` | Modify scope | {{Return to previous phase for adjustment}} |

**Timeout:** {{timeout_ms}} ms (or `null` for indefinite)

**State Preserved:**
- Current phase number
- All intermediate results from prior phases
- Context needed to render question (e.g., file count)

### {{interaction_2_id}}: {{Interaction Name}}

**Phase:** {{phase_number}}
**Type:** decision
**Required:** {{true | false}}
**Blocking:** Yes

**Question:** {{Question presented to user}}

**Options:** Dynamically generated based on:
- {{Factor 1 that determines options}}
- {{Factor 2 that determines options}}

**Dynamic Option Generation:**

```python
# Pseudo-code for generating options at runtime
def generate_options(context):
    options = []
    for approach in context.identified_approaches:
        options.append({
            "value": approach.id,
            "label": approach.name,
            "description": approach.summary,
            "risk_level": approach.risk
        })
    return options
```

## User Prompts

### Prompt: {{interaction_1_id}}

```text
┌─────────────────────────────────────────────────────────┐
│  {{skill-name}}: Approval Required                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  {{Question text}}                                      │
│                                                         │
│  Context:                                               │
│  • {{context_item_1}}                                   │
│  • {{context_item_2}}                                   │
│                                                         │
│  [Yes, proceed]  [No, cancel]  [Show details]           │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Prompt: {{interaction_2_id}}

```text
┌─────────────────────────────────────────────────────────┐
│  {{skill-name}}: Decision Required                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  {{Question text}}                                      │
│                                                         │
│  Options:                                               │
│  1. {{Option 1 label}}                                  │
│     {{Option 1 description}}                            │
│                                                         │
│  2. {{Option 2 label}}                                  │
│     {{Option 2 description}}                            │
│                                                         │
│  3. {{Option 3 label}}                                  │
│     {{Option 3 description}}                            │
│                                                         │
│  Enter choice (1-3): _                                  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Fallback Behavior

**On Timeout:** {{abort | use_default | escalate}}

| Fallback | Behavior | When to Use |
|----------|----------|-------------|
| **abort** | Stop execution, preserve state for manual resume | Destructive actions, no safe default |
| **use_default** | Apply default option automatically | Non-critical decisions, safe default exists |
| **escalate** | Notify through alternative channel (log, email) | Critical but time-sensitive workflows |

### Timeout Handling Flow

```text
Interaction Point
     │
     ▼
Start Timeout Timer ({{timeout_ms}} ms)
     │
     ├── [User responds before timeout]
     │         │
     │         ▼
     │    Record response, continue
     │
     └── [Timeout expires]
               │
               ▼
          Check fallback policy
               │
               ├── abort ────────▶ Save state, exit with "timed_out" status
               │
               ├── use_default ──▶ Apply default_option, log warning, continue
               │
               └── escalate ─────▶ Send notification, extend timeout or abort
```

### When User Doesn't Respond

1. Wait for configured timeout (or indefinitely if `null`)
2. If timeout expires:
   - Log: `{ interaction_id, timeout_ms, fallback_applied }`
   - Apply fallback policy from configuration
3. Preserve full state regardless of fallback (enables manual recovery)

## Iterative Refinement Loops

For `pattern: iterative`, the skill cycles through refinement until user is satisfied:

```text
┌──────────────────────────────────────────────────────────┐
│  ITERATIVE REFINEMENT LOOP                               │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  Initial Draft                                           │
│       │                                                  │
│       ▼                                                  │
│  Present to User ◀────────────────────────┐              │
│       │                                   │              │
│       ▼                                   │              │
│  "Is this acceptable?"                    │              │
│       │                                   │              │
│       ├── Accept ───▶ Finalize output     │              │
│       │                                   │              │
│       ├── Revise ───▶ Apply feedback ─────┘              │
│       │               (loop continues)                   │
│       │                                                  │
│       └── Abort ────▶ Preserve draft, exit               │
│                                                          │
│  Max iterations: {{max_iterations}} (prevent infinite)   │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

**Iteration State:**

```json
{
  "iteration": 2,
  "max_iterations": 5,
  "history": [
    { "iteration": 1, "feedback": "Too verbose", "action": "revise" },
    { "iteration": 2, "feedback": null, "action": "pending" }
  ],
  "current_draft": "..."
}
```

## Decision Flow Diagram

```text
Phase {{N}}
     │
     ▼
┌─────────────────────────────────────────┐
│ {{interaction_1_id}}                    │
│ "{{question}}"                          │
│                                         │
│ [STATE SAVED TO CHECKPOINT]             │
│ [EXECUTION PAUSED]                      │
└─────────────────────────────────────────┘
     │
     │ (user responds)
     │
     ├── Yes ──────────▶ Phase {{N+1}}
     │                        │
     │                        ▼
     │                   Continue execution
     │
     ├── No ───────────▶ Abort with message
     │                        │
     │                        ▼
     │                   Preserve state, exit
     │
     └── Modify ───────▶ Return to Phase {{N-1}}
                              │
                              ▼
                         (user adjusts scope)
                              │
                              ▼
                         Re-execute Phase {{N-1}}
                              │
                              ▼
                         Return to this interaction
```

## Edge Cases

| Scenario | Handling |
|----------|----------|
| User closes session without responding | State persisted; resume with `--resume {{run-id}}` |
| User provides unexpected input | Validate against options; show error, re-prompt |
| User requests cancel mid-interaction | Abort gracefully, preserve state |
| Session crash during pause | State on disk; resume recovers cleanly |
| Multiple responses to same interaction | First response wins; subsequent ignored with warning |
| Response file corrupted | Log error, re-prompt user |

## Accessibility

- All prompts support keyboard navigation
- Options are clearly labeled with descriptions
- Timeout warnings shown at 75% and 90% of timeout duration
- Screen reader compatible (ARIA labels)
- High contrast mode support for visual prompts
