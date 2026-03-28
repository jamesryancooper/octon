# Run Continuity

`state/continuity/runs/<run-id>/` stores mutable resumability and handoff state
for bound runs.

## Canonical Shape

```text
state/continuity/runs/<run-id>/
  handoff.yml
```

`handoff.yml` is the canonical run-continuity document. It must remain
subordinate to:

- `state/control/execution/runs/<run-id>/**`
- `state/evidence/runs/<run-id>/**`

## Purpose

- capture the last safe resume point for operator or agent handoff
- keep run continuity separate from append-oriented retained evidence
- make run-only execution resumable without requiring mission continuity
