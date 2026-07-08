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

# Program - Run Lifecycle

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
catalog and lifecycle contract, never from skill or prompt bundle discovery. It
reconstructs parent program state from `proposal.yml`,
`resources/child-packet-index.yml`, and parent-local support receipts, evaluates
parent review and child-readiness gates, selects the next route, and writes run
evidence plus a resumable checkpoint. Its contract declares
`execution_strategy: orchestrated-replan-loop`, so program lifecycle execution
remains on the program controller rather than the packet route-progression
driver.

Clean-delivery continuation is a runner posture inside that replan loop. Use
`--set target_outcome=cleaned` only to request Proposal Program Delivery as a
later handoff input. The runner records route-selection inputs, selected route
ownership, blocked alternatives, retry fingerprint fields, resume source refs,
and delivery handoff posture in `route-decision-receipt.yml`; it does not turn
the requested target outcome into landing, sync, cleanup, branch cleanup,
terminal proof, or a final `cleaned` claim.

Before mutating, inspect the route graph with:

```sh
octon lifecycle route-graph --lifecycle proposal-program --target <program-packet-path> --set target_outcome=cleaned
```

The route graph is diagnostic-only. It can expose selected parent routes, child
batches, review and architecture-review status, delivery handoff posture,
blockers, and resume hints, but it never satisfies child receipts, delivery
admission, Change closeout, cleanup authorization, archive authorization,
terminal proof, or a cleaned claim.

The explicit clean-delivery request wrapper is:

```text
/proposal-program-clean-delivery target=<program-packet-path> run-id=<id> [max-steps=<n>] [max-child-concurrency=<n>] [executor=auto|codex|mock]
```

It expands to the route graph preview followed by the same lifecycle runner
with `--execute-routes` and `--set target_outcome=cleaned`.

Executor behavior:

- Without `--execute-routes`, the runner stops at a planned
  `program-route-handoff` and does not invoke selected parent or child routes.
- With `--execute-routes`, the runner performs a bounded plan-execute-replan
  loop. Each iteration plans from live repository state, dispatches either one
  selected parent route or one runnable child batch through the shared lifecycle
  executor adapter, replans from parent and child manifests, child-owned
  receipts, gates, and checkpoints, and continues until terminal completion,
  blocked state, approval pause, failure, timeout, cancellation, or max-step
  exhaustion.
- Use `--max-steps` to bound adapter dispatch attempts. One step is one parent
  route dispatch or one runnable child batch dispatch; pure planning and
  non-execute handoffs do not consume steps. Use `--max-child-concurrency` to
  bound concurrent child route executors inside one child batch.
- Durable implementation, promotion, closeout, and archival routes execute only after
  proof-gated delegation succeeds. `--invocation-authority unattended` authorizes
  delegated execution, but missing or invalid proof fails closed.
- Proposal-program delivery preserves the canonical order
  `child implementation -> child validation -> child closeout -> child archive -> parent/program delivery -> landing/sync/cleanup`.
  Non-canonical requested order stops before continuation unless a retained,
  target-bound order override receipt validates against
  `proposal-program-delivery-order-override-receipt-v1`.
- Before expensive child continuation, parent delivery, Git mutation,
  publication checks, landing, sync, cleanup, or branch deletion, delivery must
  consume one retained delivery-readiness preflight receipt covering Git write
  access, worktree cleanliness, source staleness, review freshness, child receipt
  compatibility, tooling, route legality, and generated freshness.
- Dirty or stale source posture defaults to a route-owned clean worktree from
  current `origin/main`; include-path classification is required before
  reconstruction, broad stage-all, staging, or commit.
- Repeatedly blocked, recovered, or long-running delivery paths require
  validated lifecycle postmortem evidence before learned-from completion claims.
- Program recovery is bounded by the proposal-program autonomous recovery
  envelope. Low-risk generated refresh, diagnostics, evidence-index
  materialization, lifecycle-residue classification, and current-run
  rebaseline actions may run only with retained route evidence and
  post-attempt validation. The runner must stop before archive, push, landing,
  cleanup deletion, branch deletion, PR creation or merge, external
  publication, and any `cleaned` claim.
- `cleanup-lifecycle-residue` recovery is non-mutating unless a separate
  retained authority route explicitly authorizes deletion. Its evidence can
  preserve or exclude residue for matching gates, but cannot transfer archive,
  cleanup, delivery, landing, branch cleanup, child validation, child receipt,
  or child lifecycle outcome authority.
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
- `octon lifecycle program retry --run-id <program-run>` continues an existing
  checkpoint with execute-routes enabled. It accepts `--max-steps`,
  `--timeout-seconds`, and `--max-child-concurrency` for one bounded retry
  attempt. Supplied values override checkpointed execution limits for that
  attempt; omitted values inherit retained checkpoint limits when present, then
  fall back to the safe one-step/single-child retry defaults.
- `octon lifecycle cancel --run-id <run> --reason <text>` is the shared durable
  cancellation control. `octon lifecycle program cancel` remains a compatibility
  alias. Cancelled runs must not dispatch selected parent or child routes.
- Do not interpret `planned`, `program-route-handoff`, or `route-ready` as
  completed child implementation.

This wrapper has no prompt bundle and is not a dispatcher route. It must
preserve child-owned manifests, receipts, validation verdicts, promotion
targets, and archive metadata. Parent receipts may summarize child outcomes but
never satisfy child receipts or child authority.
