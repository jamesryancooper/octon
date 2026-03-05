---
title: Audit Charter I/O Contract
description: Input and output contract for the audit-charter skill.
---

# I/O Contract

## Inputs

- `charter_path`: path to the charter markdown file
- `severity_threshold`: optional reporting floor
- `include_rewrites`: whether to include exact replacement text
- `include_scores`: whether to include final numeric scores

## Outputs

- one markdown audit report with the required sections,
- one execution log,
- one per-skill log index entry.

## Output Expectations

The report should be agent-readable:

- use the exact section names required by the original prompt,
- keep tables flat and use the exact column schemas required by the skill contract,
- cite the charter with concrete file references,
- separate findings from rewrites and scores.

## Exact Score Categories

When `include_scores=true`, emit these exact `0-100` categories:

- `Internal alignment`
- `Contradiction-free coherence`
- `Normative integrity`
- `Authority/accountability clarity`
- `How operational sufficiency`
- `Enforceability/auditability`
- `Standalone clarity`
- `Overall stands on its own score`
