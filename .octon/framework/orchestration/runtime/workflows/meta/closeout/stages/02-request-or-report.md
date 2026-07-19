# Request Or Report

Report the highest evidence-backed preservation state:

- `preserved`, `branch-local-complete`, or `published-branch` for
  branch-no-PR candidate state;
- `preserved`, `published`, or `ready` for stage-preserving PR state; or
- `deferred`, `blocked`, `escalated`, or `denied` with the exact missing gate.

If landing is already independently established, report `landed` only as a
read-only observation with exact ref evidence and cleanup deferred. Never
perform or infer that landing.

Always include exact candidate refs, rollback/discard posture, validation,
retained residue, stable denial reason when applicable, and the next owner.
Never report direct-main, cleaned, synced, or autonomous publication success.

Classify local run residue using the read-only mode of
`cleanup-local-run-artifacts.sh`; this stage must not authorize or perform its
cleanup mode.
