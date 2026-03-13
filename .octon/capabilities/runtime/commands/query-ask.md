---
title: Query Ask
description: Run query service in `ask` mode to return a grounded answer with citations and evidence.
access: agent
argument-hint: "--file <path-to-query-json>"
---

# Query Ask `/query-ask`

Execute the retrieval Query service in `ask` mode.

## Usage

```text
/query-ask --file <path-to-query-json>
```

Example:

```text
/query-ask --file /tmp/query-ask.json
```

## Parameters

| Parameter | Required | Description |
|---|---|---|
| `--file` | Yes | JSON request file. Must include `"command": "ask"`. |

## Implementation

Run:

```bash
bash .octon/capabilities/runtime/services/retrieval/query/impl/query.sh < /tmp/query-ask.json
```

## Output

JSON response with:

- `status`
- `answer`
- `candidates`
- `citations`
- `evidence`
- `diagnostics`

## References

- **Service:** `.octon/capabilities/runtime/services/retrieval/query/`
- **Input schema:** `.octon/capabilities/runtime/services/retrieval/query/schema/input.schema.json`
- **Output schema:** `.octon/capabilities/runtime/services/retrieval/query/schema/output.schema.json`
