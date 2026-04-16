# Scenario: Touched Paths Authoritative Doc

## Input

- `touched_paths` includes an authoritative-doc trigger surface such as
  `/.octon/instance/ingress/AGENTS.md`

## Expected Route

- `touched-paths`

## Expected Validation Floor

- `classify-authoritative-doc-change.sh`
- `validate-authoritative-doc-triggers.sh`
- `alignment-check.sh --profile harness`

## Expected Next Step

- continue with the authoritative-doc-trigger safety path instead of a
  cheaper docs-only path
