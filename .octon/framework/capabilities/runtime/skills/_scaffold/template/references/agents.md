---
# Sub-Agent Coordination Documentation (Agentic Pattern)
# Add this file when your skill spawns or coordinates sub-agents.
#
# When to use:
# - Skill needs to spawn sub-agents for parallel work
# - Skill delegates specialized tasks to other agents
# - Skill coordinates multiple agents working together
#
# See: .octon/framework/capabilities/_meta/architecture/reference-artifacts.md#agentsmd
#
agents:
  pattern: delegate                  # spawn | delegate | coordinate

  sub_agents:
    - id: "{{agent_1_id}}"
      purpose: "{{What this sub-agent does}}"
      delegation_type: sequential    # parallel | sequential
      timeout: 300000                # ms
      # Interface contract
      interface:
        accepts:
          - name: "{{input_name}}"
            type: "{{string | object | array}}"
            required: true
        returns:
          - name: "{{output_name}}"
            type: "{{string | object | array}}"
            nullable: false

    - id: "{{agent_2_id}}"
      purpose: "{{What this sub-agent does}}"
      delegation_type: parallel
      depends_on: ["{{agent_1_id}}"]
      interface:
        accepts:
          - name: "{{input_from_agent_1}}"
            type: "{{type}}"
            source: "{{agent_1_id}}.{{output_name}}"
        returns:
          - name: "{{output_name}}"
            type: "{{type}}"
            nullable: false

  coordination:
    strategy: fan-out-fan-in         # fan-out-fan-in | pipeline | hierarchical
    failure_handling: fail-fast      # fail-fast | continue | retry
    max_concurrent: 3
    result_aggregation: merge        # merge | collect | reduce

  # How sub-agents report results back to parent
  result_protocol:
    format: structured               # structured | stream | callback
    delivery: on_completion          # on_completion | incremental | batched
    schema:
      success:
        - "status"                   # "success" | "partial" | "failed"
        - "result"                   # The actual output data
        - "metadata"                 # Timing, resource usage, etc.
      failure:
        - "status"                   # Always "failed"
        - "error_code"               # Machine-readable error identifier
        - "error_message"            # Human-readable description
        - "partial_result"           # Optional: any salvageable output
        - "recoverable"              # true | false

  # Failure handling for sub-agents
  failure_policy:
    timeout:
      action: retry                  # retry | skip | abort | escalate
      max_retries: 2
      backoff: exponential           # none | linear | exponential
    error:
      recoverable:
        action: retry
        max_retries: 1
      unrecoverable:
        action: abort                # abort | escalate | use_fallback
        preserve_partial: true
    partial_result:
      action: continue               # continue | retry | escalate
      minimum_completeness: 0.8      # 0.0-1.0, threshold for acceptable partial
---

# Sub-Agent Reference

**Required when capability:** `agent-delegating`

Agent coordination for the {{skill-name}} skill.

> **When to Add This File:**
>
> - Skill spawns sub-agents for parallel work
> - Skill delegates specialized tasks to other agents
> - Skill coordinates multiple agents working together

## Agent Pattern

**Pattern:** {{spawn | delegate | coordinate}}

| Pattern | Description | Use When |
|---------|-------------|----------|
| **spawn** | Creates new agent instances for independent parallel work | Tasks are embarrassingly parallel (no shared state) |
| **delegate** | Passes work to specialized agents, awaits result | Task requires expertise parent lacks |
| **coordinate** | Orchestrates multiple agents with dependencies | Complex workflows with inter-agent data flow |

## Valid Sub-Agent Types

Sub-agents spawned by skills must use one of these agent types:

| Type | Description | Tool Access | Use When |
|------|-------------|-------------|----------|
| `Explore` | Codebase exploration, file discovery | Read, Glob, Grep | Need to search/understand code |
| `Plan` | Design implementation approaches | Read, Glob, Grep | Need strategic planning |
| `Bash` | Command execution | Bash | Need to run shell commands |
| `general-purpose` | Full capabilities | All tools | Complex multi-step sub-tasks |

**Restrictions:**

- Sub-agents inherit parent's harness scope limits
- Sub-agents cannot write outside `.octon/framework/capabilities/runtime/skills/` unless parent has explicit permission
- Sub-agents cannot spawn their own sub-agents (max depth = 1)
- Sub-agents share the parent's token budget allocation

## Parent Skill Coordination Model

### How the Parent Coordinates Results

1. **Fan-out phase:** Parent dispatches work to sub-agents
2. **Collection phase:** Parent awaits responses (with timeout)
3. **Aggregation phase:** Parent merges/reduces results
4. **Continuation phase:** Parent proceeds with aggregated data

```text
Parent Skill
     │
     ├──┬── DISPATCH ──────────────────────────────────────┐
     │  │                                                   │
     │  │  Sub-Agent A          Sub-Agent B                │
     │  │       │                    │                      │
     │  │       ▼                    ▼                      │
     │  │  [working...]         [working...]               │
     │  │       │                    │                      │
     │  │  ◄────┴────────────────────┘                      │
     │  │                                                   │
     │  └── COLLECT ───────────────────────────────────────┘
     │
     │  results = [result_a, result_b]
     │
     ├── AGGREGATE ─────────────────────────────────────────
     │
     │  merged = aggregate(results)  # merge | collect | reduce
     │
     └── CONTINUE ──────────────────────────────────────────

         Use merged results in next phase
```

## Parent-Child Interface Contract

The interface between parent skill and sub-agents is defined by a strict contract:

### Invocation Protocol

```
Parent Skill
     │
     │ ┌─────────────────────────────────────────┐
     │ │ INVOKE(agent_id, {                      │
     │ │   task: "description of work",          │
     │ │   inputs: { ... },                       │
     │ │   timeout: 300000,                      │
     │ │   context: { parent_run_id, ... }       │
     │ │ })                                      │
     │ └─────────────────────────────────────────┘
     ▼
Sub-Agent
     │
     │ ┌─────────────────────────────────────────┐
     │ │ RETURN({                                │
     │ │   status: "success" | "partial" | "failed", │
     │ │   result: { ... },                      │
     │ │   metadata: { duration_ms, ... },       │
     │ │   error?: { code, message, recoverable }│
     │ │ })                                      │
     │ └─────────────────────────────────────────┘
     ▼
Parent Skill (continues)
```

### Input Contract

Each sub-agent declares what it accepts:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `task` | string | Yes | Human-readable description of work to perform |
| `inputs` | object | Yes | Structured data matching agent's `interface.accepts` |
| `timeout` | number | No | Override default timeout (ms) |
| `context` | object | No | Parent context for correlation (run_id, phase, etc.) |

### Output Contract

Each sub-agent returns a standardized response:

| Field | Type | Always Present | Description |
|-------|------|----------------|-------------|
| `status` | enum | Yes | `"success"`, `"partial"`, or `"failed"` |
| `result` | object | On success/partial | Output data matching `interface.returns` |
| `metadata` | object | Yes | `{ duration_ms, tokens_used, agent_version }` |
| `error` | object | On failure | `{ code, message, recoverable, stack? }` |

## Sub-Agent Definitions

### {{agent_1_id}}: {{Agent Purpose}}

**Purpose:** {{Detailed description of what this agent does}}

| Property | Value |
|----------|-------|
| Delegation Type | {{parallel \| sequential}} |
| Timeout | {{timeout_ms}} ms |
| Depends On | None |

**Interface Contract:**

```yaml
accepts:
  - name: "{{input_name}}"
    type: string
    required: true
    description: "{{what this input represents}}"

returns:
  - name: "{{output_name}}"
    type: object
    nullable: false
    schema:
      {{field_1}}: {{type}}
      {{field_2}}: {{type}}
```

**Example Invocation:**

```json
{
  "task": "{{description of task}}",
  "inputs": {
    "{{input_name}}": "{{example_value}}"
  },
  "timeout": 300000
}
```

**Example Response (Success):**

```json
{
  "status": "success",
  "result": {
    "{{output_name}}": { "{{field_1}}": "...", "{{field_2}}": "..." }
  },
  "metadata": { "duration_ms": 1234 }
}
```

### {{agent_2_id}}: {{Agent Purpose}}

**Purpose:** {{Detailed description of what this agent does}}

| Property | Value |
|----------|-------|
| Delegation Type | {{parallel \| sequential}} |
| Timeout | {{timeout_ms}} ms |
| Depends On | {{agent_1_id}} |

**Interface Contract:**

```yaml
accepts:
  - name: "{{input_from_agent_1}}"
    type: object
    source: "{{agent_1_id}}.{{output_name}}"  # Data flows from agent_1
    required: true

returns:
  - name: "{{output_name}}"
    type: {{type}}
    nullable: false
```

**Data Flow:** Receives output from `{{agent_1_id}}` automatically via the coordination layer.

## How Sub-Agents Report Results

### Result Delivery Modes

| Mode | Description | Use When |
|------|-------------|----------|
| **on_completion** | Single response when agent finishes | Short tasks, simple workflows |
| **incremental** | Stream partial results as available | Long tasks, progress visibility needed |
| **batched** | Periodic batches of results | High-volume output, rate limiting |

### Result Aggregation Strategies

| Strategy | Behavior | Use When |
|----------|----------|----------|
| **merge** | Combine all results into single object | Results are complementary (different fields) |
| **collect** | Array of all results | Results are independent items |
| **reduce** | Apply reduction function | Results need summarization |

### Result Schema

**Success Response:**

```json
{
  "status": "success",
  "result": {
    // Agent-specific output matching interface.returns
  },
  "metadata": {
    "duration_ms": 1234,
    "tokens_used": 500,
    "agent_version": "1.0.0"
  }
}
```

**Partial Success Response:**

```json
{
  "status": "partial",
  "result": {
    // Whatever was completed
  },
  "metadata": {
    "duration_ms": 5000,
    "completeness": 0.7
  },
  "warning": "Timed out before full completion"
}
```

**Failure Response:**

```json
{
  "status": "failed",
  "error": {
    "code": "AGENT_TIMEOUT",
    "message": "Sub-agent exceeded 300000ms timeout",
    "recoverable": true
  },
  "partial_result": {
    // Any salvageable output
  },
  "metadata": {
    "duration_ms": 300000
  }
}
```

## Failure Handling

### Failure Policy Matrix

| Failure Type | Default Action | Alternatives | When to Override |
|--------------|----------------|--------------|------------------|
| **Timeout** | Retry (2x) | skip, abort, escalate | Skip if result optional; abort if critical |
| **Recoverable Error** | Retry (1x) | abort, escalate | Abort if idempotency uncertain |
| **Unrecoverable Error** | Abort | escalate, use_fallback | Escalate for user decision |
| **Partial Result** | Continue | retry, escalate | Retry if completeness < threshold |

### Error Codes

| Code | Meaning | Recoverable | Suggested Action |
|------|---------|-------------|------------------|
| `AGENT_TIMEOUT` | Agent exceeded timeout | Yes | Retry with longer timeout |
| `AGENT_NOT_FOUND` | Agent ID doesn't exist | No | Abort, fix configuration |
| `INPUT_VALIDATION` | Input doesn't match contract | No | Abort, fix input mapping |
| `DEPENDENCY_FAILED` | Upstream agent failed | Maybe | Check upstream, retry if fixed |
| `RESOURCE_EXHAUSTED` | Rate limit or quota hit | Yes | Backoff and retry |
| `INTERNAL_ERROR` | Unexpected agent failure | No | Abort, log for debugging |

### Recovery Procedures

**On Timeout:**

1. Log timeout: `{ agent_id, timeout_ms, task_summary }`
2. Check retry budget: `retries_remaining > 0`?
3. If retry: apply backoff, re-invoke
4. If no retries: check `partial_result`, apply `failure_policy.timeout.action`
5. Notify parent if escalating

**On Error:**

1. Parse error response: `{ code, message, recoverable }`
2. If recoverable and retries remain: retry with same inputs
3. If unrecoverable: preserve `partial_result` if `preserve_partial: true`
4. Apply configured action: `abort | escalate | use_fallback`
5. Log full error context for debugging

**On Partial Result:**

1. Evaluate completeness: `result.metadata.completeness >= minimum_completeness`?
2. If acceptable: continue with partial data, log warning
3. If unacceptable: retry or escalate based on policy

## Coordination Strategy

**Strategy:** {{fan-out-fan-in | pipeline | hierarchical}}

| Strategy | Data Flow | Best For |
|----------|-----------|----------|
| **fan-out-fan-in** | Parallel distribution → collect results | Independent parallel tasks |
| **pipeline** | A → B → C (sequential chain) | Dependent transformations |
| **hierarchical** | Parent → children → grandchildren | Recursive decomposition |

### Fan-Out-Fan-In Example

```
Parent Skill
     │
     ├──▶ Agent A ──┐
     │              │
     ├──▶ Agent B ──┤ (parallel, independent)
     │              │
     └──▶ Agent C ──┘
                    │
                    ▼
             Collect Results
                    │
                    ▼
        Merge: { a: ..., b: ..., c: ... }
                    │
                    ▼
             Continue Execution
```

### Pipeline Example

```
Parent Skill
     │
     ▼
  Agent A ──▶ result_a
     │
     ▼
  Agent B (input: result_a) ──▶ result_b
     │
     ▼
  Agent C (input: result_b) ──▶ result_c
     │
     ▼
Continue with result_c
```

## Resource Limits

| Resource | Limit | Rationale |
|----------|-------|-----------|
| Max concurrent agents | {{max_concurrent}} | Prevent resource exhaustion, respect rate limits |
| Timeout per agent | {{timeout_ms}} ms | Ensure timely completion, prevent hanging |
| Max total agents per run | {{max_total}} | Limit complexity, bound cost |
| Max retry attempts | 2 | Prevent infinite retry loops |

## Observability

### Logging Requirements

Each sub-agent invocation must log:

- `invocation_start`: `{ agent_id, task, inputs_hash, timestamp }`
- `invocation_end`: `{ agent_id, status, duration_ms, result_hash }`
- `invocation_error`: `{ agent_id, error_code, error_message, recoverable }`

### Correlation

All sub-agent logs include:

- `parent_run_id`: Links to parent skill execution
- `agent_invocation_id`: Unique ID for this specific invocation
- `phase`: Which phase of parent skill triggered this

This enables tracing the full execution tree:

```
Parent Run: abc-123
  └── Agent A: abc-123-a-001
  └── Agent B: abc-123-b-001
  └── Agent C: abc-123-c-001
       └── Sub-Agent C1: abc-123-c-001-c1-001
```

## Failure Model Details

### When a Sub-Agent Fails

```text
┌─────────────────────────────────────────────────────────────────┐
│  SUB-AGENT FAILURE MODEL                                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. Sub-agent returns error response:                           │
│     { status: "failed", error: { code, message, recoverable } } │
│                                                                  │
│  2. Parent evaluates failure policy:                            │
│     ┌─────────────────────────────────────────────────────────┐ │
│     │ Is error recoverable?                                    │ │
│     │   YES → Check retry budget                               │ │
│     │         Retries remaining? → Retry with backoff          │ │
│     │         No retries? → Apply failure_policy               │ │
│     │   NO  → Apply failure_policy.unrecoverable               │ │
│     └─────────────────────────────────────────────────────────┘ │
│                                                                  │
│  3. Failure policy actions:                                     │
│     - abort: Stop skill execution, report failure               │
│     - skip: Continue without this sub-agent's result            │
│     - escalate: Pause and ask user for guidance                 │
│     - use_fallback: Use cached/default value                    │
│                                                                  │
│  4. Partial result handling:                                    │
│     If sub-agent returns partial result before failure:         │
│     - preserve_partial: true → Use what was completed           │
│     - preserve_partial: false → Discard partial work            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Failure Scenarios and Responses

| Scenario | Error Code | Default Response | Recovery Option |
|----------|------------|------------------|-----------------|
| Sub-agent times out | `AGENT_TIMEOUT` | Retry 2x with backoff | Increase timeout, reduce scope |
| Sub-agent not found | `AGENT_NOT_FOUND` | Abort | Fix agents.md configuration |
| Input validation fails | `INPUT_VALIDATION` | Abort | Fix input mapping |
| Upstream dependency failed | `DEPENDENCY_FAILED` | Retry if upstream recovers | Check dependency chain |
| Rate limit hit | `RESOURCE_EXHAUSTED` | Retry with exponential backoff | Reduce parallelism |
| Internal error | `INTERNAL_ERROR` | Abort | Debug sub-agent, file issue |

### Logging Failed Sub-Agents

Every sub-agent failure must be logged to `/.octon/state/control/skills/checkpoints/{{skill-id}}/{{run-id}}/agent-failures.yml`:

```yaml
failures:
  - agent_id: "explore-codebase"
    timestamp: "2026-01-22T10:15:00Z"
    error:
      code: "AGENT_TIMEOUT"
      message: "Sub-agent exceeded 300000ms timeout"
      recoverable: true
    action_taken: "retry"
    retry_count: 1
    outcome: "success_on_retry"

  - agent_id: "analyze-dependencies"
    timestamp: "2026-01-22T10:16:30Z"
    error:
      code: "INTERNAL_ERROR"
      message: "Unexpected parse error in dependency graph"
      recoverable: false
    action_taken: "abort"
    partial_result_preserved: true
    partial_completeness: 0.6
```

### Escalation to User

When to escalate instead of automatic handling:

| Condition | Escalation Trigger |
|-----------|-------------------|
| All retries exhausted | `failure_policy.*.action: escalate` |
| Unrecoverable error with no fallback | No `use_fallback` configured |
| Partial result below threshold | `completeness < minimum_completeness` |
| Multiple agents failing | >50% of parallel agents failed |

**Escalation prompt format:**

```text
Sub-agent '{{agent_id}}' failed: {{error_message}}

Options:
1. Retry with extended timeout ({{timeout * 2}}ms)
2. Skip this agent and continue
3. Abort skill execution
4. Provide manual input to replace agent result

Choose [1-4]:
```
