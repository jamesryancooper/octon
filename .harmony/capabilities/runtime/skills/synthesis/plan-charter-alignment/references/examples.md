---
title: Plan Charter Alignment Examples
description: Example uses of the plan-charter-alignment skill.
---

# Examples

## Charter-Only Alignment Plan

```text
/plan-charter-alignment charter_path=".harmony/CHARTER.md" findings_source=".harmony/output/reports/2026-03-05-charter-audit.md"
```

Expected outcome:

- one profile-governed alignment plan,
- explicit change bundles for the charter,
- validation scenarios and assumptions.

## Higher Target Score

```text
/plan-charter-alignment charter_path="docs/charter.md" findings_source="audit.md" target_score="98"
```

Expected outcome:

- tighter acceptance thresholds,
- explicit note if the target score requires broader follow-on scope.
