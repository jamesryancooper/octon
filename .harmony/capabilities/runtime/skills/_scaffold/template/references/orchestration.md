---
# Orchestration Documentation (Orchestrated Pattern)
# Add this file when your Complex skill coordinates multiple sub-tasks.
#
# When to use:
# - Skill coordinates multiple sub-skills or sub-tasks
# - Skill manages parallel execution
# - Skill has complex dependency relationships between sub-tasks
#
# See: .harmony/capabilities/_meta/architecture/reference-artifacts.md#orchestrationmd
#
orchestration:
  pattern: sequential                # sequential | parallel | dag

  sub_tasks:
    - id: "{{task_1_id}}"
      description: "{{What this sub-task does}}"
      delegates_to: null             # null = inline, or skill-id to delegate
      inputs: ["{{input_1}}", "{{input_2}}"]
      outputs: ["{{output_1}}"]

    - id: "{{task_2_id}}"
      description: "{{What this sub-task does}}"
      delegates_to: "{{skill-id}}"   # Delegates to another skill
      inputs: ["{{input_from_task_1}}"]
      outputs: ["{{output_2}}"]
      depends_on: ["{{task_1_id}}"]

    - id: "{{task_3_id}}"
      description: "{{What this sub-task does}}"
      delegates_to: null
      inputs: ["{{output_1}}", "{{output_2}}"]
      outputs: ["{{final_output}}"]
      depends_on: ["{{task_1_id}}", "{{task_2_id}}"]

  coordination:
    failure_handling: fail-fast      # fail-fast | continue | retry
    timeout_per_task: 300000         # ms, optional
    max_parallel: 3                  # For parallel patterns
---

# Orchestration Reference

**Required when capability:** `task-coordinating` or `parallel`

Sub-task coordination for the {{skill-name}} skill.

> **When to Add This File:**
>
> - Skill coordinates multiple sub-skills or sub-tasks
> - Skill manages parallel execution
> - Skill has complex dependency relationships between tasks

## Orchestration Pattern

**Pattern:** {{sequential | parallel | dag}}

| Pattern | Description | Use When |
|---------|-------------|----------|
| **sequential** | Tasks execute one after another | Order matters, each task depends on previous |
| **parallel** | Tasks execute concurrently | Independent tasks that can run simultaneously |
| **dag** | Directed acyclic graph | Complex dependencies between tasks |

## Sub-task Definitions

### {{task_1_id}}: {{Task 1 Name}}

**Description:** {{What this sub-task accomplishes}}

| Property | Value |
|----------|-------|
| Delegates to | {{null (inline) OR skill-id}} |
| Inputs | {{input_1}}, {{input_2}} |
| Outputs | {{output_1}} |
| Depends on | None |

### {{task_2_id}}: {{Task 2 Name}}

**Description:** {{What this sub-task accomplishes}}

| Property | Value |
|----------|-------|
| Delegates to | {{skill-id}} |
| Inputs | Output from {{task_1_id}} |
| Outputs | {{output_2}} |
| Depends on | {{task_1_id}} |

### {{task_3_id}}: {{Task 3 Name}}

**Description:** {{What this sub-task accomplishes}}

| Property | Value |
|----------|-------|
| Delegates to | {{null (inline) OR skill-id}} |
| Inputs | Outputs from {{task_1_id}}, {{task_2_id}} |
| Outputs | {{final_output}} |
| Depends on | {{task_1_id}}, {{task_2_id}} |

## Delegation Rules

When to delegate to another skill vs execute inline:

| Condition | Action |
|-----------|--------|
| Sub-task matches another skill's purpose | Delegate to that skill |
| Sub-task is simple and specific to this skill | Execute inline |
| Sub-task needs specialized safety constraints | Delegate (inherits delegated skill's constraints) |

## Failure Handling

**Policy:** {{fail-fast | continue | retry}}

| Policy | Behavior |
|--------|----------|
| **fail-fast** | Stop immediately on first failure |
| **continue** | Log failure, continue with remaining tasks |
| **retry** | Retry failed task up to N times before failing |

### On Sub-task Failure

1. Log the failure with task ID and error details
2. Apply failure policy (fail-fast/continue/retry)
3. If fail-fast: abort and report partial results
4. If continue: mark task as failed, proceed with independent tasks
5. If retry: attempt task again (max {{retry_count}} times)

## Coordination Diagram

```
{{task_1_id}}
      │
      ▼
{{task_2_id}}
      │
      └──────┐
             ▼
      {{task_3_id}}
```

Replace with actual task flow diagram showing dependencies.
