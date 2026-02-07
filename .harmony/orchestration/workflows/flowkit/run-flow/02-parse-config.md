---
title: Parse Config
description: Read and validate the .flow.json configuration file.
---

# Step 2: Parse Config

## Action

1. Read the JSON config file
2. Validate the config against the FlowKit schema

> **Source of Truth:** The canonical `.flow.json` schema and validation logic lives in `packages/kits/flowkit/src/cli.ts` (see `validateFlowConfig`). This workflow step describes the *procedure*, not the schema.

## Key Fields (reference only)

The FlowKit CLI validates these fields automatically:

- `id` — Flow identifier (used as `flowName` in runtime)
- `displayName` — Human-readable name for confirmations
- `canonicalPromptPath` — Path to the canonical prompt
- `workflowManifestPath` — Path to workflow manifest
- `workflowEntrypoint` — Entry point node ID
- `runtime` — Execution binding (type, url, autoStart)

See `packages/kits/flowkit/schema/flowkit.inputs.v1.json` for the full schema.

## Failure Handling

| Condition | Response |
|-----------|----------|
| Invalid JSON | "Failed to parse `.flow.json`: `<parse error>`" |
| Missing required field | "Missing required field `<field>` in `.flow.json`" |
| Unsupported runtime type | "Unsupported runtime type `<type>`" |

## Output

Announce the flow about to run:

```text
Running FlowKit flow `<id>` — `<displayName>` from `<configPath>`
```

## Next

Proceed to [03-execute-flow.md](./03-execute-flow.md)
