# Program Closeout Plan

## Current Task Closeout

This creation task closes only when parent and child proposal artifacts are
accepted, implementation prompts exist, validators pass, and the handoff-only
lifecycle run succeeds. It does not close out the future implementation program.

## Future Program Closeout

A later `--execute-routes` run must enforce the active
`program.closeout_policy` from the proposal-program lifecycle contract. In the
current authored policy, required non-deferred children must reach terminal
outcomes `archived` or `rejected` unless explicit deferral, supersession,
replacement, or rejection evidence applies.

Archived child outcomes require child-owned `implementation-run`,
`implementation-conformance`, `post-implementation-drift`, and
`proposal-closeout` receipts with passing or authorized values, including
`proposal-closeout.archive_authorized: yes`. Rejected child outcomes require
child review evidence with `verdict: rejected`.

## Archive Boundary

Archive mutation is workflow-owned by `archive-proposal`. Parent closeout may
summarize child outcomes but cannot perform archive mutation, satisfy child
receipts, or rewrite child terminal state.

## Blocked Receipts

Blocked closeout or archive receipts must include verdict, archive authorization,
selected git route, blocker class, owned/in-scope/foreign counts, hygiene
fingerprint, cleanup summary, and next route condition.
