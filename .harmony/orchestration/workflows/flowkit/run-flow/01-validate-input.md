---
title: Validate Input
description: Confirm exactly one .flow.json reference was provided.
---

# Step 1: Validate Input

## Action

1. Check that the user included **exactly one** `@Files`/`@Code` reference
2. Verify the reference resolves to a file ending with `.flow.json`

## Success Criteria

- Exactly one `@` reference present
- Reference path ends with `.flow.json`

## Failure Handling

| Condition | Response |
|-----------|----------|
| No `@` reference | "Please rerun the command and select your `.flow.json` config via `@Files`." |
| Multiple references | "Please provide exactly one `.flow.json` file." |
| Wrong file type | "The referenced file must end with `.flow.json`. You provided: `<path>`" |

## Output

Resolved path relative to repo root (e.g., `packages/workflows/architecture_assessment/config.flow.json`)

## Next

Proceed to [02-parse-config.md](./02-parse-config.md)
