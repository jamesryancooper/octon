# Program - Run Lifecycle

Run or inspect the governed proposal-program lifecycle. During RP-00, route
execution may coordinate only `implemented` or `archive-ready` stage-preserving
work. Publication outcomes and clean-delivery continuation are disabled.

```text
.octon/framework/engine/runtime/run lifecycle run --lifecycle proposal-program --target <program-packet-path> --run-id <id> --set target_outcome=implemented
```

An explicit `archive-ready` target is also allowed when target-owned child
evidence supports it. Omitted/default effectful targets, direct-main, hosted
branch-no-PR, landed, synced, cleaned, cleanup, and any route execution that
would reach Git/GitHub or provider effects fail with
`RP00_CONTAINMENT_PUBLICATION_DISABLED`.

Planning and route-graph inspection remain diagnostic only. Compatibility
parsers do not authorize dispatch. The runner must preserve exact work, emit no
publication/cleanup handoff, and report RP-06/RP-08 as a later owner when such
an outcome is requested.
