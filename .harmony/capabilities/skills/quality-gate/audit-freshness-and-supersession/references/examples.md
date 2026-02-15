---
title: Examples
description: Example invocations for audit-freshness-and-supersession.
---

# Examples

## Default Freshness Audit

```text
/audit-freshness-and-supersession scope=".harmony"
```

## Stricter Age Threshold

```text
/audit-freshness-and-supersession scope=".harmony" max_age_days="14"
```

## Focused Artifact Families

```text
/audit-freshness-and-supersession scope=".harmony" artifact_globs="output/plans/**/*.md,output/reports/**/*.md"
```
