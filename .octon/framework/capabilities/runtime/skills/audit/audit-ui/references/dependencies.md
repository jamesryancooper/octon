---
title: External Dependencies
description: External service dependencies for the audit-ui skill.
---

# External Dependencies

This skill depends on an external service for its ruleset. This is the first
skill in the harness to use the `external-dependent` capability.

## Dependencies

| Service | URL | Purpose | Required |
|---------|-----|---------|----------|
| GitHub Raw Content | See default URL below | Design guidelines ruleset | Yes |

### Default Ruleset URL

```
https://raw.githubusercontent.com/anthropics/anthropic-cookbook/refs/heads/main/misc/web_interface_guidelines.md
```

This URL serves the Web Interface Guidelines maintained by Anthropic. The
content is a markdown document containing 100+ categorized design rules
covering accessibility, performance, forms, focus states, animations,
typography, images, and dark mode.

## Configuration

The ruleset URL can be overridden via the `ruleset_url` parameter:

```
/audit-ui target="src/" ruleset_url="https://example.com/custom-guidelines.md"
```

Requirements for custom rulesets:

- Must be a publicly accessible URL (no authentication)
- Must return markdown content
- Should contain identifiable rule headings and descriptions
- Ideally organized by category with priority/severity indicators

## Health Checks

Before scanning, verify the ruleset is accessible:

1. **WebFetch the URL** — If the request fails, stop execution immediately
2. **Validate content** — Check that the response contains parseable rule content (markdown with headings)
3. **Log metadata** — Record URL, fetch timestamp, response size, and rule count

## Failure Modes

| Failure | Impact | Handling |
|---------|--------|----------|
| URL unreachable (network error) | Cannot audit | Stop execution, report error to user |
| URL returns 404 | Cannot audit | Stop execution, suggest checking URL |
| URL returns non-markdown content | Degraded | Warn user, attempt best-effort parse |
| Content structure changed | Degraded | Warn user, extract identifiable rules |
| Rate limited (429) | Temporary | Wait briefly, retry once, then fail |

## Offline Mode

This skill **cannot operate offline**. The external ruleset is required for
every execution — there is no bundled fallback ruleset.

If offline operation is needed in the future, consider:

- Caching the last fetched ruleset to `_ops/state/configs/audit-ui/cached-ruleset.md`
- Using the cached version when WebFetch fails
- Logging a warning that the cached version may be outdated

This pattern is not implemented yet. The skill currently requires network access.
