---
title: Audit Charter Validation
description: Acceptance criteria for the audit-charter skill.
---

# Validation

## Acceptance Criteria

- Report includes all 12 required output sections.
- `Overall Verdict` is constrained to `Aligned`, `Partially aligned`, or `Not aligned` and includes a one-paragraph rationale.
- Canonical statements are extracted or explicitly marked as missing.
- Every material finding cites charter evidence.
- Every evaluation criterion from the original prompt is addressed explicitly.
- Normative clause audit covers all `MUST`, `SHOULD`, and `MAY` clauses in the charter.
- Authority/accountability map names decision owner, execution owner, and escalation owner, or records the gap.
- Dependency resilience analysis covers every referenced normative artifact named by the charter.
- Every required table uses the exact schema defined in the skill output contract.
- Rewrite pack exists for every High and Medium issue when `include_rewrites=true`, and each entry quotes current text plus proposed text.
- Final scores are present for all required categories on an explicit `0-100` scale when `include_scores=true`.
- The audit explicitly judges whether the charter is internally complete, coherent, enforceable, and self-sufficient.

## Quality Gate

A run is complete only when findings, rewrites, and scores tell the same story. Do not emit inflated scores if unresolved High or Medium issues remain.
