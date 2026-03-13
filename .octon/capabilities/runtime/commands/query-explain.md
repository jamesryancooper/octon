---
title: Query Explain
description: Run query service in `explain` mode to return ranking rationale and signal-level diagnostics.
access: agent
argument-hint: "--file <path-to-query-json>"
---

# Query Explain `/query-explain`

Execute the retrieval Query service in `explain` mode.

## Usage

```text
/query-explain --file <path-to-query-json>
```

Example:

```text
/query-explain --file /tmp/query-explain.json
```

## Parameters

| Parameter | Required | Description |
|---|---|---|
| `--file` | Yes | JSON request file. Must include `"command": "explain"`. |

## Implementation

Run:

```bash
bash .octon/capabilities/runtime/services/retrieval/query/impl/query.sh < /tmp/query-explain.json
```

## Output

JSON response with:

- `status`
- `candidates`
- `citations`
- `evidence`
- `diagnostics`

## References

- **Service:** `.octon/capabilities/runtime/services/retrieval/query/`
- **Input schema:** `.octon/capabilities/runtime/services/retrieval/query/schema/input.schema.json`
- **Output schema:** `.octon/capabilities/runtime/services/retrieval/query/schema/output.schema.json`
