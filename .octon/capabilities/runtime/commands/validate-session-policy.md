---
title: Validate Session Policy
description: Validate a session policy JSON file against native interop semantics.
access: agent
argument-hint: "--file <path-to-session-policy-json>"
---

# Validate Session Policy `/validate-session-policy`

Validate canonical session-policy content for native interop execution.

## Usage

```text
/validate-session-policy --file <path-to-session-policy-json>
```

Example:

```text
/validate-session-policy --file .octon/capabilities/runtime/services/interfaces/agent-platform/fixtures/native-session-policy.json
```

## Parameters

| Parameter | Required | Description |
|---|---|---|
| `--file` | Yes | Path to session policy JSON file. |

## Implementation

Run:

```bash
bash .octon/capabilities/runtime/services/interfaces/agent-platform/impl/validate-session-policy.sh \
  --file <path-to-session-policy-json>
```

Validation semantics include:

- scope/reset/send class constraints
- fixed thresholds (`80%` warning, `90%` flush)
- flush-before-compaction and fail-closed settings
- routing precedence ordering
- required presence evidence fields

## Output

- Success: JSON with `ok: true`
- Failure: JSON with `ok: false` and explicit error list

## References

- **Schema:** `.octon/capabilities/runtime/services/interfaces/agent-platform/schema/session-policy.schema.json`
- **Contract:** `.octon/cognition/runtime/context/agent-platform-interop.md`
