---
title: Validation Reference
description: Acceptance criteria for the build-mcp-server skill.
---

# Validation Reference

## Acceptance Criteria

### Build Quality

| Check | Requirement |
| ----- | ----------- |
| TypeScript compiles | `npx tsc --noEmit` passes with no errors |
| Server starts | Process starts and listens on stdio transport |
| Tools listed | `tools/list` returns all defined tools |
| Tool responds | At least one tool returns valid output for sample input |
| Errors handled | Invalid input returns structured error, not crash |

### Security

| Check | Requirement |
| ----- | ----------- |
| No hardcoded secrets | Grep for API keys, tokens returns zero hits |
| .env.example exists | Placeholder values for all required env vars |
| .gitignore includes .env | Credentials never committed |
| Inputs validated | All tool inputs checked before API calls |

### Documentation

| Check | Requirement |
| ----- | ----------- |
| README exists | Setup instructions, tool reference, usage examples |
| Tool reference complete | Every tool has name, description, and input schema |
| Config documented | All env vars listed with descriptions |
| Usage examples | At least Claude Desktop config example |

## Verification Checklist

1. Project compiles without errors
2. Server starts and responds to handshake
3. All tools appear in tools/list
4. At least one tool tested with sample input
5. Error handling returns structured messages
6. No credentials in source code
7. README is complete and accurate
8. Log exists at `/.octon/state/evidence/runs/skills/build-mcp-server/{{run_id}}.md`
