---
# Composition Documentation (Composable Pattern)
# Add this file when your skill is designed as a building block for registry composition.
#
# When to use:
# - Skill is explicitly designed for multi-skill composition
# - Skill has defined input/output compatibility with other skills
# - Skill provides integration hooks for customization
#
# See: .harmony/capabilities/_meta/architecture/reference-artifacts.md#compositionmd
#
composition:
  role: transformer                  # source | transformer | sink

  # Composable Interface Contract
  # This defines the "shape" of this skill for skill-local composition
  interface:
    # What this skill accepts (input contract)
    input:
      format: structured             # structured | raw | stream
      schema:
        type: object
        required: ["{{required_field}}"]
        properties:
          "{{required_field}}":
            type: "{{string | object | array}}"
            description: "{{What this field represents}}"
          "{{optional_field}}":
            type: "{{type}}"
            description: "{{What this field represents}}"
            default: "{{default_value}}"
      # Validation rules for upstream compatibility
      validation:
        - rule: "{{field}} must not be empty"
          severity: error
        - rule: "{{field}} should have at least 3 items"
          severity: warning

    # What this skill produces (output contract)
    output:
      format: structured
      schema:
        type: object
        properties:
          "{{output_field}}":
            type: "{{type}}"
            description: "{{What downstream skills receive}}"
          "metadata":
            type: object
            description: "Execution metadata for downstream"
            properties:
              "source_skill": { type: string }
              "timestamp": { type: string, format: "iso8601" }
              "version": { type: string }

  # Chaining contract: how this skill connects to others
  chaining:
    # Upstream compatibility (skills that can feed into this one)
    accepts_from:
      - skill_id: "{{upstream-skill-id}}"
        output_field: "{{output_field_name}}"
        adapter: null                # null | "adapter_function_name"
        description: "{{What this skill accepts from upstream}}"

    # Downstream compatibility (skills that can consume this one's output)
    feeds_into:
      - skill_id: "{{downstream-skill-id}}"
        input_field: "{{input_field_name}}"
        adapter: null
        description: "{{What downstream skills can consume}}"

    # Data flow guarantees
    guarantees:
      idempotent: false              # Same input always produces same output?
      side_effect_free: true         # Does skill modify external state?
      order_independent: false       # Can items be processed in any order?

  # Integration hooks for customization
  hooks:
    pre_execution:
      enabled: true
      signature: "(input, context) => input | Error"
      description: "Transform or validate input before execution"
    post_execution:
      enabled: true
      signature: "(output, context) => output | Error"
      description: "Transform or validate output after execution"
    on_error:
      enabled: false
      signature: "(error, context) => Recovery | Rethrow"
      description: "Custom error handling for pipeline recovery"

  # Example compositions using this skill
  pipeline_examples:
    - name: "{{Pipeline Name}}"
      skills: ["{{skill-1}}", "{{skill-2}}", "{{skill-3}}"]
      description: "{{What this pipeline accomplishes}}"
---

# Composition Reference

**Required when capability:** `composable`

Building block design for the {{skill-name}} skill.

> **When to Add This File:**
>
> - Skill is explicitly designed for multi-skill composition
> - Skill has defined input/output compatibility with other skills
> - Skill provides integration hooks for customization

## Composition Role

**Role:** {{source | transformer | sink}}

| Role | Description | Position | Input | Output |
|------|-------------|----------|-------|--------|
| **source** | Produces initial data | First | User input / external | Structured data |
| **transformer** | Transforms data | Middle | Structured from upstream | Structured for downstream |
| **sink** | Finalizes output | Last | Structured from upstream | Final deliverable |

This skill acts as a **{{role}}** in skill compositions.

## Composable Interface Contract

The interface contract defines the "shape" of this skill—what it accepts, what it produces, and the guarantees it provides. This contract enables type-safe chaining with other skills.

### Input Contract

**Format:** {{structured | raw | stream}}

```yaml
# Input Schema
type: object
required:
  - "{{required_field}}"
properties:
  {{required_field}}:
    type: {{string | object | array}}
    description: "{{What this field represents}}"
  {{optional_field}}:
    type: {{type}}
    description: "{{What this field represents}}"
    default: "{{default_value}}"
```

**Validation Rules:**

| Rule | Severity | Description |
|------|----------|-------------|
| `{{field}} must not be empty` | error | Execution fails if violated |
| `{{field}} should have at least 3 items` | warning | Logged but execution continues |

**Example Valid Input:**

```json
{
  "{{required_field}}": "{{example_value}}",
  "{{optional_field}}": "{{example_value}}"
}
```

### Output Contract

**Format:** {{structured | raw | stream}}

```yaml
# Output Schema
type: object
properties:
  {{output_field}}:
    type: {{type}}
    description: "{{What downstream skills receive}}"
  metadata:
    type: object
    description: "Execution metadata for downstream"
    properties:
      source_skill:
        type: string
        value: "{{skill-id}}"
      timestamp:
        type: string
        format: iso8601
      version:
        type: string
        value: "{{version}}"
```

**Example Output:**

```json
{
  "{{output_field}}": {
    // Skill-specific output
  },
  "metadata": {
    "source_skill": "{{skill-id}}",
    "timestamp": "2024-01-15T10:30:00Z",
    "version": "1.0.0"
  }
}
```

## Chaining Contract

The chaining contract defines how this skill connects to other skills in a pipeline.

### Upstream Compatibility (Accepts From)

Skills that can feed into this skill:

| Upstream Skill | Output Field | Adapter | Notes |
|----------------|--------------|---------|-------|
| `{{skill-id}}` | `{{field}}` | None | Direct compatibility |
| `{{skill-id}}` | `{{field}}` | `adapt_{{skill}}_output` | Requires transformation |

**Compatibility Requirements:**

For this skill to accept input from an upstream skill:

1. Upstream output must match this skill's input schema
2. Required fields must be present: `{{required_field}}`
3. Data types must be compatible (or adapter provided)

**Adapter Example:**

When upstream output doesn't match input schema directly:

```javascript
// Adapter: adapt_gather_sources_output
function adapt(upstreamOutput) {
  return {
    {{required_field}}: upstreamOutput.{{upstream_field}},
    {{optional_field}}: upstreamOutput.{{other_field}} || "default"
  };
}
```

### Downstream Compatibility (Feeds Into)

Skills that can consume this skill's output:

| Downstream Skill | Input Field | Adapter | Notes |
|------------------|-------------|---------|-------|
| `{{skill-id}}` | `{{field}}` | None | Direct compatibility |
| `{{skill-id}}` | `{{field}}` | `adapt_for_{{skill}}` | Requires transformation |

### Data Flow Guarantees

| Guarantee | Value | Implication |
|-----------|-------|-------------|
| **Idempotent** | {{true/false}} | {{Same input always produces same output / Output may vary}} |
| **Side-effect free** | {{true/false}} | {{No external state modified / May modify files, APIs, etc.}} |
| **Order independent** | {{true/false}} | {{Items can be processed in any order / Order matters}} |

**Why This Matters for Pipelines:**

- **Idempotent:** Enables retry without duplication
- **Side-effect free:** Enables parallel execution
- **Order independent:** Enables batch optimization

## Pipeline Chaining Protocol

When skills are chained in a pipeline, they follow this protocol:

```text
┌─────────────────────────────────────────────────────────────────────────┐
│  PIPELINE CHAINING PROTOCOL                                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Skill A (source)                                                       │
│       │                                                                 │
│       │ 1. Execute skill                                                │
│       │ 2. Produce output matching output contract                      │
│       │ 3. Include metadata: { source_skill, timestamp, version }       │
│       │                                                                 │
│       ▼                                                                 │
│  ┌─────────────────────────────────────────┐                            │
│  │  HANDOFF                                │                            │
│  │  • Validate output against A's schema   │                            │
│  │  • Apply adapter if needed              │                            │
│  │  • Validate input against B's schema    │                            │
│  └─────────────────────────────────────────┘                            │
│       │                                                                 │
│       ▼                                                                 │
│  Skill B (transformer) ← THIS SKILL                                     │
│       │                                                                 │
│       │ 1. Receive validated input                                      │
│       │ 2. Execute transformation                                       │
│       │ 3. Produce output matching output contract                      │
│       │ 4. Preserve or extend metadata chain                            │
│       │                                                                 │
│       ▼                                                                 │
│  ┌─────────────────────────────────────────┐                            │
│  │  HANDOFF                                │                            │
│  │  • Same validation as above             │                            │
│  └─────────────────────────────────────────┘                            │
│       │                                                                 │
│       ▼                                                                 │
│  Skill C (sink)                                                         │
│       │                                                                 │
│       │ 1. Receive validated input                                      │
│       │ 2. Produce final deliverable                                    │
│       │ 3. Write to output location                                     │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Handoff Validation

At each handoff point between skills:

1. **Schema validation:** Output matches declared schema
2. **Adapter application:** Transform if schemas don't match directly
3. **Input validation:** Input matches receiving skill's schema
4. **Error on mismatch:** Fail fast with clear error message

**Validation Failure Response:**

```json
{
  "status": "chain_error",
  "error": {
    "type": "schema_mismatch",
    "upstream_skill": "gather-sources",
    "downstream_skill": "synthesize-research",
    "field": "sources",
    "expected": "array",
    "received": "object",
    "suggestion": "Apply adapter 'adapt_sources_to_array' or fix upstream output"
  }
}
```

## Integration Hooks

Hooks allow customization without modifying skill internals.

### pre_execution_hook

**Signature:** `(input, context) => input | Error`

**Called:** After input validation, before skill execution

**Use Cases:**

- Add default values to optional fields
- Enrich input with external data
- Custom validation beyond schema

**Example:**

```javascript
function preExecutionHook(input, context) {
  // Add context from pipeline
  return {
    ...input,
    pipeline_id: context.pipeline_id,
    enriched_at: new Date().toISOString()
  };
}
```

### post_execution_hook

**Signature:** `(output, context) => output | Error`

**Called:** After skill execution, before handoff to downstream

**Use Cases:**

- Transform output format for specific downstream
- Add pipeline-specific metadata
- Filter or redact sensitive data

**Example:**

```javascript
function postExecutionHook(output, context) {
  // Redact sensitive fields before downstream
  return {
    ...output,
    {{sensitive_field}}: "[REDACTED]"
  };
}
```

### on_error_hook

**Signature:** `(error, context) => Recovery | Rethrow`

**Called:** When skill execution fails

**Use Cases:**

- Provide fallback output for non-critical failures
- Transform errors for better downstream handling
- Attempt recovery before failing pipeline

**Example:**

```javascript
function onErrorHook(error, context) {
  if (error.code === "RATE_LIMIT") {
    // Return partial result instead of failing
    return { recovery: "partial", output: context.partial_result };
  }
  // Re-throw for critical errors
  throw error;
}
```

## Pipeline Examples

### {{Pipeline Name}}

**Skills:** `{{skill-1}}` → `{{skill-2}}` → `{{skill-3}}`

**Description:** {{What this pipeline accomplishes}}

**Data Flow:**

```text
{{skill-1}} (source)
     │
     │ Output: { sources: [...], query: "..." }
     │
     ▼
{{skill-2}} (transformer) ← THIS SKILL
     │
     │ Input:  { sources: [...], query: "..." }
     │ Output: { synthesis: "...", themes: [...] }
     │
     ▼
{{skill-3}} (sink)
     │
     │ Input:  { synthesis: "...", themes: [...] }
     │ Output: Final report written to .harmony/output/reports/analysis/
```

**Invocation:**

```bash
# Run entire pipeline
/workflow run "{{workflow-name}}" --input "{{user_input}}"

# Or chain manually
/{{skill-1}} "{{input}}" | /{{skill-2}} | /{{skill-3}}
```

### {{Another Pipeline Name}}

**Skills:** `{{skill-a}}` → `{{this-skill}}` → `{{skill-b}}`

**Description:** {{What this pipeline accomplishes}}

## Standalone vs Pipeline Mode

| Aspect | Standalone Mode | Pipeline Mode |
|--------|-----------------|---------------|
| **Input** | Raw user input | Structured from upstream |
| **Output** | Final deliverable | Intermediate for downstream |
| **Metadata** | Optional | Required (source_skill, timestamp) |
| **Validation** | Lenient | Strict schema validation |
| **Error handling** | User-facing messages | Machine-readable errors |

### Detecting Mode

Skills can detect whether they're running standalone or in a pipeline:

```javascript
function execute(input, context) {
  const isPipeline = context.pipeline_id !== undefined;

  if (isPipeline) {
    // Strict mode: validate schema, produce structured output
    validateInput(input, inputSchema);
    const result = process(input);
    return { ...result, metadata: buildMetadata(context) };
  } else {
    // Lenient mode: accept flexible input, produce user-friendly output
    const normalizedInput = normalizeUserInput(input);
    const result = process(normalizedInput);
    return formatForUser(result);
  }
}
```

## Versioning and Compatibility

### Schema Versioning

When input/output schemas change:

| Change Type | Version Bump | Backward Compatible |
|-------------|--------------|---------------------|
| Add optional field | Minor (1.1.0) | Yes |
| Add required field | Major (2.0.0) | No |
| Remove field | Major (2.0.0) | No |
| Change field type | Major (2.0.0) | No |

### Compatibility Matrix

| This Skill Version | Compatible Upstream Versions | Compatible Downstream Versions |
|--------------------|------------------------------|--------------------------------|
| 1.0.0 | gather-sources >=1.0.0 | generate-report >=1.0.0 |
| 1.1.0 | gather-sources >=1.0.0 | generate-report >=1.0.0 |
| 2.0.0 | gather-sources >=2.0.0 | generate-report >=1.5.0 |

### Migration Adapters

When breaking changes occur, provide migration adapters:

```javascript
// Adapter for gather-sources 1.x output to this skill 2.x input
function adapt_gather_sources_v1_to_v2(v1Output) {
  return {
    sources: v1Output.results.map(r => ({
      id: r.id,
      content: r.text,  // renamed field
      metadata: { url: r.source }  // restructured
    }))
  };
}
```

---

## Skill-to-Skill Invocation

When one skill needs to invoke another skill directly (not just registry composition):

### Invocation Protocol

```yaml
# Skill A invoking Skill B
invocation:
  skill_id: "skill-b"
  trigger: explicit           # explicit | implicit (via pipeline)
  inputs:
    param_1: "value from Skill A"
    param_2: "${output.field}" # Reference Skill A output
  timeout: 300000             # ms
  context:
    parent_skill: "skill-a"
    parent_run_id: "${run_id}"
    phase: "execution"
```

### Response Contract

```yaml
response:
  status: success | partial | failed
  result:
    # Skill B's output matching its output contract
  metadata:
    skill_id: "skill-b"
    duration_ms: 1234
    tokens_used: 500
  error:                      # Present only on failure
    code: "ERROR_CODE"
    message: "Human-readable description"
    recoverable: true | false
```

### Error Handling in Skill Chains

| Error Type | Default Behavior | Override With |
|------------|------------------|---------------|
| Timeout | Retry 1x, then fail chain | `on_timeout: skip \| abort \| retry(N)` |
| Recoverable error | Retry 1x, then fail | `on_error.recoverable: continue \| abort` |
| Unrecoverable error | Abort chain | `on_error.unrecoverable: abort` (always) |
| Partial result | Accept if ≥80% complete | `partial_threshold: 0.0-1.0` |

### Example: Skill A Invokes Skill B

```text
Skill A (refine-prompt)
     │
     │ Phase 3: Needs codebase context
     │
     │ INVOKE(analyze-codebase, {
     │   inputs: { path: "./src", depth: "shallow" },
     │   timeout: 60000
     │ })
     │
     ▼
Skill B (analyze-codebase)
     │
     │ Returns: { structure: {...}, patterns: [...] }
     │
     ▼
Skill A continues with enriched context
```

### Declaring Invocable Skills

In `registry.yml`, declare that a skill can be invoked by others:

```yaml
analyze-codebase:
  invocable: true
  invocation_contract:
    accepts:
      - name: path
        type: string
        required: true
      - name: depth
        type: enum
        values: [shallow, deep]
        default: shallow
    returns:
      - name: structure
        type: object
      - name: patterns
        type: array
```

### Invocation vs Pipeline Composition

| Aspect | Skill Invocation | Pipeline Composition |
|--------|------------------|----------------------|
| Control flow | Parent skill controls execution | Orchestrator manages flow |
| Error handling | Parent handles child errors | Pipeline handles errors |
| Context sharing | Explicit via `context` param | Implicit via metadata chain |
| Use when | Need result mid-execution | Building data transformation chains |
