---
title: Execute Flow
description: Run the flow via FlowKit CLI.
---

# Step 3: Execute Flow

## Action

1. Execute the FlowKit CLI from the repo root:

```bash
pnpm flowkit:run <resolved-config-path>
```

2. Wait for the CLI to complete
3. Capture stdout and stderr

## Success Criteria

- CLI exits with code 0
- Output includes flow results

## Failure Handling

| Condition | Response |
|-----------|----------|
| Bad path | Surface error, suggest checking config path |
| Missing dependencies | Surface error, suggest running `pnpm install` |
| Runtime error | Surface stderr/stdout for user to debug |

## Output

CLI output (stdout/stderr) for use in reporting.

## Next

Proceed to [04-report-results.md](./04-report-results.md)

