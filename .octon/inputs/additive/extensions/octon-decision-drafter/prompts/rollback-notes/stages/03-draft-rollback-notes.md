# Draft Rollback Notes

Draft the rollback-notes section in the requested output mode.

## Required Shape

- include the label `Draft / Non-Authoritative`
- cite the diff basis and retained evidence basis
- separate supported rollback facts from operator cautions

## Output Mode Rules

- `inline`: return a standalone `Rollback Notes` section
- `patch-suggestion`: return a suggested edit only when `draft_target_path`
  points to an eligible human-authored narrative doc
- `scratch-md`: write scratch support material only under the generic skill
  checkpoint and run-evidence roots

Never auto-edit rollback posture files or other execution-control truth.
