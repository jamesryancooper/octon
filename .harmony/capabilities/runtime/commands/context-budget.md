---
title: Context Budget
description: Emit deterministic native context budget state and threshold classification.
access: agent
argument-hint: "--limit <int> --used <int> [--unit tokens|characters] [--report <path>]"
---

# Context Budget `/context-budget`

Calculate and emit deterministic context budget output for native mode.

## Usage

```text
/context-budget --limit <int> --used <int>
/context-budget --limit <int> --used <int> --unit tokens
/context-budget --limit <int> --used <int> --report .harmony/output/reports/analysis/<date>-context-budget.md
```

## Parameters

| Parameter | Required | Description |
|---|---|---|
| `--limit` | Yes | Total context budget capacity. |
| `--used` | Yes | Current context usage. |
| `--unit` | No | Unit name (`tokens` or `characters`). Default: `tokens`. |
| `--report` | No | Optional markdown report output path. |

## Implementation

Run:

```bash
bash .harmony/capabilities/runtime/services/interfaces/agent-platform/impl/context-budget.sh \
  --limit <int> \
  --used <int> \
  [--unit tokens|characters] \
  [--report <path>]
```

Threshold semantics:

- `>= 80%`: warning
- `>= 90%`: flush-required

## Output

JSON with canonical fields:

- `interop_contract_version`
- `mode`
- `budget_limit`
- `budget_used`
- `budget_used_percent`
- `threshold_state`

## References

- **Service:** `.harmony/capabilities/runtime/services/interfaces/agent-platform/`
- **Contract:** `.harmony/cognition/runtime/context/agent-platform-interop.md`
