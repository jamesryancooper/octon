---
title: Scope
description: Boundaries and responsibilities for Node.js/TypeScript workspaces.
---

# Scope: {{PACKAGE_NAME}}

## This Workspace Covers

{{DESCRIPTION of the package}}

## In Scope

- {{List specific features}}
- {{List specific components}}
- {{List testing responsibilities}}

## Out of Scope

- {{What belongs elsewhere}}
- {{Adjacent packages to avoid}}

## Decision Authority

**Decide locally:**

- Internal implementation details
- Test coverage approach
- Component API design

**Escalate:**

- Breaking API changes
- New dependencies
- Cross-cutting changes affecting other packages

## Adjacent Areas

| Area | Relationship |
|------|--------------|
| `packages/config/` | Shared TypeScript/ESLint configs |
| {{related package}} | {{relationship}} |

