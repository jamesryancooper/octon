---
# Identity
id: "[skill-id]"
name: "[Skill Name]"
version: "0.1.0"
summary: "[One-line summary for routing - what it does and when to use it.]"
description: |
  [Longer description with usage context and value proposition.
  Include specific phrases users might say when they need this skill.]
access: agent

# Provenance
author:
  name: "[Author Name]"
  contact: "[email or handle]"
created_at: "[YYYY-MM-DD]"
updated_at: "[YYYY-MM-DD]"
license: "MIT"

# Invocation
commands:
  - /[command-name]
explicit_call_patterns:
  - "use skill: [skill-id]"
triggers:
  - "[natural language trigger 1]"
  - "[natural language trigger 2]"

# I/O Contract
inputs:
  - name: "[input_name]"
    type: file  # file | text | folder | glob | json | yaml
    required: true
    path_hint: "sources/[pattern]"
    schema: null  # optional JSON schema reference

outputs:
  - name: "[output_name]"
    type: markdown  # markdown | html | json | images | audio | log
    path: "outputs/drafts/[pattern]"
    format: "markdown"  # specific format details
    determinism: "stable"  # stable | variable | non-deterministic

# Dependencies
requires:
  tools: []      # filesystem.read, filesystem.write.outputs, web.search, shell, http.fetch
  packages: []   # npm packages, python packages, etc.
  services: []   # external APIs, databases, etc.
depends_on: []   # other skill IDs that should run first

# Safety Policies
safety:
  tool_policy:
    mode: deny-by-default  # deny-by-default | allow-by-default
    allowed:
      - filesystem.read
      - filesystem.write.outputs
  file_policy:
    write_scope:
      - ".workspace/skills/outputs/**"
      - ".workspace/skills/logs/**"
    destructive_actions: never  # never | prompt

# Behavior (structured for machine parsing)
behavior:
  goals:
    - "[Primary goal]"
    - "[Secondary goal]"
  steps:
    - "Read and validate inputs"
    - "[Core processing step]"
    - "Generate outputs"
    - "Write outputs to declared paths"
    - "Write run log to logs/runs/"

# Validation
acceptance_criteria:
  - "[Criterion 1: what must be true for success]"
  - "[Criterion 2]"

# Examples (for testing and documentation)
examples:
  - input: "[Example input or command]"
    invocation: "/[command] [args]"
    output: "outputs/drafts/[expected-output].md"
    description: "[What this example demonstrates]"
---

# Skill: [skill-id]

## Mission

[One sentence defining what this skill does and its primary value.]

## Behavior

### Goals

1. [Primary goal]
2. [Secondary goal]

### Steps

1. **Gather inputs:** [Read/validate inputs]
2. **Process:** [Core processing step]
3. **Generate:** [Create outputs]
4. **Write:** Save outputs to declared paths
5. **Log:** Write run log to `.workspace/skills/logs/runs/`

## Boundaries

- Never [constraint 1]
- Always [requirement 1]
- Write only to designated output paths
- [Additional constraints]

## When to Escalate

- If [ambiguous input condition], ask one clarifying question
- If [failure condition], note gaps and proceed with available information
- If [expertise needed], flag for human review

## Examples

**Input:**
```text
/[command] [args]
```

**Expected Output:**
```text
.workspace/skills/outputs/[path]
```

## References

For detailed information, see `reference/` directory.
For executable helpers, see `scripts/` directory.
