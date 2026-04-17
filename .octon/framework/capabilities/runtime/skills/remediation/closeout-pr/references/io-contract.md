---
title: I/O Contract
description: Parameters, outputs, and tool surface for the closeout-pr skill.
---

# I/O Contract

## Parameters

| Parameter | Type | Required | Default | Description |
| --------- | ---- | -------- | ------- | ----------- |
| `pr` | text | No | — | Existing PR number or URL |
| `title` | text | No | — | Commit/PR title when a PR must be created |
| `summary` | text | No | — | PR summary text |
| `no_issue` | text | No | `autonomy-closeout` | `No-Issue:` reason when no issue link exists |
| `include_paths` | text | No | — | Optional comma-separated include paths |
| `exclude_paths` | text | No | — | Optional comma-separated exclude paths |
| `poll_seconds` | text | No | `30` | Poll interval between rechecks |

## Outputs

- Closeout report:
  `.octon/state/evidence/validation/analysis/{{date}}-pr-closeout-{{run_id}}.md`
- Execution log:
  `/.octon/state/evidence/runs/skills/closeout-pr/{{run_id}}.md`
- Log index:
  `/.octon/state/evidence/runs/skills/closeout-pr/index.yml`

## Dependencies

This skill requires:

- Git working tree access for review, staging, commit, and push
- GitHub CLI access for PR, checks, and review-thread inspection
- Write access to analysis and run-log directories
