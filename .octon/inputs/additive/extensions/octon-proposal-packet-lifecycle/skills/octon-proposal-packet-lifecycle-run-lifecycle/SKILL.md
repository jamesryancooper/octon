---
name: octon-proposal-packet-lifecycle-run-lifecycle
description: Run the generic lifecycle runner against one proposal packet target.
license: MIT
compatibility: Octon proposal packet lifecycle extension.
metadata:
  author: Octon Framework
  created: "2026-05-06"
  updated: "2026-05-06"
skill_sets: [executor, integrator, specialist]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Bash(octon lifecycle *) Write(/.octon/state/*)
---

# Proposal Packet Lifecycle Runner

Use the shared lifecycle runner for one proposal packet target:

```sh
octon lifecycle run --lifecycle proposal-packet --target <packet-path>
```

For a missing target, bind creation source context with
`--set-file source=<path>` or `--set source=<text>`. Optional generic creation
inputs include `source_kind`, `proposal_kind`, and `proposal_id`; these are
stored in lifecycle checkpoints and evidence for safe retry.

The runner resolves `proposal-packet` from the published effective extension
catalog, reconstructs proposal state from `proposal.yml` and proposal-local
support receipts, evaluates gates and stale-review checks, selects the next
route, and writes run evidence plus a resumable checkpoint.

Executor behavior:

- Without `--execute-routes`, the runner stops at a gated `route-ready`
  handoff and does not invoke the selected extension prompt bundle.
- With `--execute-routes`, route execution is delegated to the shared lifecycle
  executor adapter. The adapter owns `mock`, `auto`, `codex`, and `claude`
  route execution outside the lifecycle runner.
- Durable implementation, promotion, and archival routes pause for explicit,
  resumable approval by default. `--approval-policy unattended` is an explicit
  operator override; the adapter records approval override evidence before
  executing an approval-gated route under that policy.
- Non-execute handoffs do not consume bounded loop iterations because the
  selected route has not executed.

## Boundaries

- Do not introduce new `proposal.yml` statuses.
- Use `support/proposal-review.md` and `support/revisions/<revision-id>.md` as
  loop receipts.
- Enforce strict implementation authorization before implementation prompt
  generation, implementation execution, or promotion.
- Treat proposal-local receipts as packet evidence only, never as runtime,
  policy, support, or durable authority.
- Do not interpret `route-ready` as completed route execution.
