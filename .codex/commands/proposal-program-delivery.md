# /proposal-program-delivery

Coordinate an accepted proposal program to `implemented` or `archive-ready`
while RP-00 containment is active.

## Usage

```text
/proposal-program-delivery target=<proposal-program-path> outcome=implemented|archive-ready route=stage-only profile=<profile-path> run-id=<id>
```

All inputs are required. Resume may satisfy `profile` or `run-id` only through fresh, target-bound
evidence from the same delivery run. The canonical child-
before-parent order and target-owned child receipts remain mandatory.

`direct-main`, hosted `branch-no-pr`, landing, sync, cleanup,
`landed`/`synced`/`cleaned`, and omitted/default effectful requests stop before
dispatch with `RP00_CONTAINMENT_PUBLICATION_DISABLED`. Exact child and parent
work is preserved. The wrapper performs no Git/GitHub, provider, publication,
archive relocation, final-sync, branch-cleanup, or residue-deletion effect.
RP-06/RP-08 remain the later publication/cleanup owners.
