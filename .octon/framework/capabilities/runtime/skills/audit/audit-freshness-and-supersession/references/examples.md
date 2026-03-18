---
title: Examples
description: Example invocations for audit-freshness-and-supersession.
---

# Examples

## Default Freshness Audit

```text
/audit-freshness-and-supersession scope=".octon"
```

## Stricter Age Threshold

```text
/audit-freshness-and-supersession scope=".octon" max_age_days="14"
```

## Focused Artifact Families

```text
/audit-freshness-and-supersession scope=".octon" artifact_globs="output/plans/**/*.md,output/reports/**/*.md"
```
