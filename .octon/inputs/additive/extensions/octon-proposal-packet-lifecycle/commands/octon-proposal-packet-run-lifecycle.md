# Proposal Packet Run Lifecycle

Run the generic lifecycle runner for one proposal packet target:

```sh
octon lifecycle run --lifecycle proposal-packet --target <packet-path>
```

Use `--run-id`, `--executor`, `--max-iterations`, `--set key=value`, and
`--set-file key=path` when deterministic resume, mock execution, bounded loop
testing, or creation input binding is required. For missing proposal targets,
provide source context with `--set-file source=<path>` or `--set source=<text>`.
The runner plans from the published lifecycle contract, evaluates
receipt-driven gates, records workflow evidence and checkpoints, and reports
the next route.

Executor boundary:

- Without `--execute-routes`, the runner stops at a gated `route-ready`
  handoff and does not invoke the selected route.
- With `--execute-routes`, route execution is delegated to the shared lifecycle
  executor adapter; `mock` remains deterministic and synthetic, while
  `auto|codex|claude` execute through adapter-owned prompt/workflow surfaces.
- Durable implementation, promotion, and archival routes pause for explicit,
  resumable approval by default. `--approval-policy unattended` is an explicit
  operator override; the adapter records approval override evidence before
  executing an approval-gated route under that policy.
- Non-execute route handoffs do not consume bounded loop iterations because
  the selected route has not executed.

It must not create new proposal statuses or treat proposal-local receipts as
durable authority.
