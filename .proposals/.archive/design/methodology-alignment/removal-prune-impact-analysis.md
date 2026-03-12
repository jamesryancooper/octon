# Removal and Prune Impact Analysis

- Units marked `prune` or `move_or_merge`: 22
- No artifact met remove-all gating; full deletion is not recommended for any artifact.
- Risk posture: low-to-medium because recommended moves preserve content via relocate/merge/summarize-and-link plans.

## High-Impact Consolidations
- Consolidate CI gate matrix ownership into `ci-cd-quality-gates.md`.
- Consolidate shared SLO constants into `reliability-and-ops.md` and reference from other artifacts.
- Move prompt/example/quick-start operational content out of `README.md` into dedicated playbook/example surfaces.
