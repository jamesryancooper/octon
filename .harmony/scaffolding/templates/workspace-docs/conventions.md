---
title: Conventions
description: Style and formatting rules for documentation workspaces.
---

# Conventions

## File Naming

- Lowercase with hyphens: `get-user.md`, `authentication.md`
- Index files: `README.md` in each directory
- Versioned docs: `v2/endpoint-name.md`

## Document Structure

### Standard Documentation

```markdown
# Title

Brief description of the topic.

## Overview

What this document covers and why it matters.

## Content Sections

Organized by logical flow.

## Examples

Concrete, realistic examples.

## Related

Links to related documentation.
```

## Writing Style

| Do | Don't |
|----|-------|
| Use active voice | Use passive voice |
| Show concrete examples | Describe abstractly |
| Keep descriptions concise | Write lengthy paragraphs |
| Include error scenarios | Only show happy path |

## Code Examples

- Include relevant language examples
- Use realistic (but fake) data
- Show both success and error cases

## Progress Log Format

```markdown
## YYYY-MM-DD

**Session focus:** [one-line summary]

**Completed:**
- [task 1]

**Next:**
- [priority item]

**Blockers:**
- [if any]
```

