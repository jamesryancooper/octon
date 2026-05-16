---
name: octon-proposal-lifecycle-run-program-lifecycle
description: Run the generic lifecycle runner against one proposal program target.
license: MIT
compatibility: Octon proposal lifecycle extension.
metadata:
  author: Octon Framework
  created: "2026-05-12"
  updated: "2026-05-12"
skill_sets: [executor, integrator, specialist]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Bash(octon lifecycle *) Write(/.octon/state/*)
---

# Octon Proposal Lifecycle: Run Program Lifecycle

Use the shared lifecycle runner for one proposal program target:

```sh
octon lifecycle run --lifecycle proposal-program --target <program-packet-path>
```

If `octon` is not installed on PATH, or if the packaged binary does not expose
`lifecycle`, use the repo-local development launcher:

```sh
.octon/framework/engine/runtime/run lifecycle run --lifecycle proposal-program --target <program-packet-path>
```

The runner resolves `proposal-program` from the published effective extension
catalog, reconstructs parent program state from `proposal.yml`,
`resources/child-packet-index.yml`, and parent-local support receipts, evaluates
parent review and child-readiness gates, selects the next route, and writes run
evidence plus a resumable checkpoint. Its contract declares
`execution_strategy: orchestrated-replan-loop`, so program lifecycle execution
remains on the program controller rather than the packet route-progression
driver.

Executor behavior:

- Without `--execute-routes`, the runner stops at a planned
  `program-route-handoff` and does not invoke selected parent or child routes.
- With `--execute-routes`, the runner performs a bounded plan-execute-replan
  loop. Each iteration plans from live repository state, dispatches either one
  selected parent route or one runnable child batch through the shared lifecycle
  executor adapter, replans from child-owned manifests and receipts, and
  continues until terminal completion, blocked state, approval pause, failure,
  timeout, cancellation, or max-step exhaustion.
- Use `--max-steps` to bound adapter dispatch attempts. One step is one parent
  route dispatch or one runnable child batch dispatch; pure planning and
  non-execute handoffs do not consume steps. Use `--max-child-concurrency` to
  bound concurrent child route executors inside one child batch.
- Durable implementation, promotion, closeout, and archival routes pause for
  explicit, resumable approval by default. `--approval-policy unattended` is an
  explicit operator override; the adapter records approval override evidence
  before executing an approval-gated route under that policy.
- Before a long unattended run with the `codex` executor, preflight nested
  executor runtime access. If the sandbox cannot write the Codex runtime state
  database, app-server socket, or required local executor state, rerun through
  the approved escalated execution path before dispatching child routes. Treat
  this as operator procedure/preflight evidence, not as a child lifecycle
  blocker or recovery-budget attempt.
- Child approval pauses should route operators through `octon lifecycle program
  approve --run-id <program-run> --child <child> --route <route> --reason
  <reason>`, followed by program retry or lifecycle resume. Approval remains
  enforced by the adapter.
- `octon lifecycle cancel --run-id <run> --reason <text>` is the shared durable
  cancellation control. `octon lifecycle program cancel` remains a compatibility
  alias. Cancelled runs must not dispatch selected parent or child routes.
- Do not interpret `planned`, `program-route-handoff`, or `route-ready` as
  completed child implementation.

This wrapper has no prompt bundle and is not a dispatcher route. It must
preserve child-owned manifests, receipts, validation verdicts, promotion
targets, and archive metadata. Parent receipts may summarize child outcomes but
never satisfy child receipts or child authority.
