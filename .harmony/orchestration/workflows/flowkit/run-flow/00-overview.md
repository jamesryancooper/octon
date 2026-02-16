---
title: Run FlowKit Flow
description: Execute a FlowKit LangGraph flow from its .flow.json config file.
access: human
---

# Run FlowKit Flow

Execute any FlowKit LangGraph flow by pointing to its `.flow.json` config file.

## Target

A `.flow.json` configuration file provided via `@` reference.

## Prerequisites

- FlowKit installed (`pnpm flowkit:run` available)
- Valid `.flow.json` config file with required fields
- LangGraph dependencies configured

## Failure Conditions

| Condition | Action |
|-----------|--------|
| No `@` reference provided | Ask user to rerun with `@Files` reference |
| Reference is not a `.flow.json` file | Report error, stop |
| Invalid JSON or missing required fields | Report parse error, stop |
| FlowKit CLI fails | Surface stderr/stdout for user to fix |

## Steps

1. [Validate Input](./01-validate-input.md) — Confirm exactly one `.flow.json` reference
2. [Parse Config](./02-parse-config.md) — Read and validate the JSON config
3. [Execute Flow](./03-execute-flow.md) — Run the flow via FlowKit CLI
4. [Report Results](./04-report-results.md) — Summarize output and provide Studio instructions

## References

- **Canonical:** `.harmony/capabilities/services/execution/flow/guide.md`

