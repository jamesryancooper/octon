---
title: Audit Charter Examples
description: Example uses of the audit-charter skill.
---

# Examples

## Closed-Book Charter Audit

```text
/audit-charter charter_path=".harmony/CHARTER.md"
```

Expected outcome:

- one structured audit report,
- explicit findings on internal completeness and governance quality,
- exact output tables, rewrite pack, and scores.

## Thresholded Review

```text
/audit-charter charter_path="docs/charter.md" severity_threshold="medium" include_rewrites=true
```

Expected outcome:

- High and Medium findings only,
- rewrite guidance for material issues,
- same required report structure.
