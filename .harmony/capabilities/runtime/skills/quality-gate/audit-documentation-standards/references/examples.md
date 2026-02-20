---
title: Examples
description: Example invocations for audit-documentation-standards.
---

# Examples

## Default audit

```text
/audit-documentation-standards docs_root="docs"
```

## Audit with explicit canonical paths

```text
/audit-documentation-standards docs_root="docs" template_root=".harmony/scaffolding/templates/docs/documentation-standards" policy_doc=".harmony/cognition/principles/documentation-is-code.md"
```

## High-severity filter

```text
/audit-documentation-standards docs_root="docs" severity_threshold="high"
```
