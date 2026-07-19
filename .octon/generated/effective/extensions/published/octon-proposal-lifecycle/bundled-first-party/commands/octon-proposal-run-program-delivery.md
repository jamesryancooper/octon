# Run Program Contained Delivery

```text
/octon-proposal-run-program-delivery target=<proposal-program-path> outcome=implemented|archive-ready route=stage-only profile=<profile-path> run-id=<id>
```

This alias delegates to `proposal-program-delivery`:

```text
/proposal-program-delivery target=<proposal-program-path> outcome=implemented|archive-ready route=stage-only profile=<profile-path> run-id=<id>
```

It does not create an independent lifecycle contract, workflow id, profile,
receipt, cleanup rule, or publication authority. Missing `profile` or `run-id` fails closed before mutation.

Direct-main, hosted branch-no-PR, landing, sync, cleanup,
landed/synced/cleaned, and omitted/default effectful requests fail with
`RP00_CONTAINMENT_PUBLICATION_DISABLED`. Exact parent and child work is
preserved and no external or Git effect is delegated.

Canonical workflow:
`.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/workflow.yml`.
