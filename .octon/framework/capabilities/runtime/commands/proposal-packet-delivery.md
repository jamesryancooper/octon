# /proposal-packet-delivery

Coordinate one accepted packet to `implemented` or `archive-ready` while the
RP-00 containment gate is active.

## Usage

```text
/proposal-packet-delivery target=<proposal-packet-path> outcome=implemented|archive-ready route=stage-only profile=<profile-path> run-id=<id>
```

All five inputs are required. Resume may satisfy `profile` or `run-id` only through fresh, target-bound
workflow evidence from the same run.

The command validates the containment-bound profile and invokes
`.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-delivery/workflow.yml`.
It may coordinate target-owned implementation, promotion, packet closeout, and
terminal archive-readiness evidence. Pre-archive and Already-archived packets
remain exact-work preserving.

`direct-main`, hosted `branch-no-pr`, landing, sync, cleanup,
`outcome=landed`, `outcome=synced`, `outcome=cleaned`, and omitted/default
effectful requests fail before dispatch with
`RP00_CONTAINMENT_PUBLICATION_DISABLED`. PR fallback is forbidden. No current
request delegates to Change closeout, worktree cleanup, Git/GitHub mutation,
provider mutation, branch deletion, or archive relocation. Historical receipt
vocabulary remains compatibility-only and cannot authorize current work.
