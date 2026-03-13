---
title: Query Retrieve
description: Run query service in `retrieve` mode to return ranked candidates with citations and evidence.
access: agent
argument-hint: "--file <path-to-query-json>"
---

# Query Retrieve `/query-retrieve`

Execute the retrieval Query service in `retrieve` mode.

## Usage

```text
/query-retrieve --file <path-to-query-json>
```

Example:

```text
/query-retrieve --file /tmp/query-retrieve.json
```

## Parameters

| Parameter | Required | Description |
|---|---|---|
| `--file` | Yes | JSON request file. Must include `"command": "retrieve"`. |

## Implementation

Run:

```bash
bash .octon/capabilities/runtime/services/retrieval/query/impl/query.sh < /tmp/query-retrieve.json
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
