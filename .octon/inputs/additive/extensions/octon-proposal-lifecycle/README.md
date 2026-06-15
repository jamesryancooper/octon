# Octon Proposal Lifecycle

First-party additive extension pack for proposal lifecycle automation across
proposal packets and proposal programs.

This pack composes existing Octon proposal standards, proposal workflows,
concept-integration routes, impact-map routing, validators, publication
scripts, and host projection publishing into a governed operator flow. Packet
actions operate on one proposal packet. Program actions coordinate a parent
proposal program while preserving child packet authority.

## Scope

The pack owns reusable routes for:

- creating proposal packets from source context,
- explaining existing proposal packets,
- reviewing proposal packets with receipt-only verdict state,
- revising proposal packets through packet-local revision receipts,
- generating packet implementation, verification, correction, and closeout
  prompts,
- running packet verification and correction convergence loops,
- closing out individual proposal packets,
- terminalizing implemented proposal packets as archive-ready or blocked
  without archiving them,
- coordinating accepted proposal program delivery through target-owned child
  lifecycles, packet closeout, archive handoff, Change closeout, final sync,
  cleanup, and terminal proof,
- creating, explaining, reviewing, revising, and operating proposal programs
  across canonical child packets,
- generating program implementation, verification, correction, and closeout
  prompts for parent-owned coordination surfaces.

## Authority Boundary

This pack is additive source. Runtime-facing discovery uses generated effective
extension and capability outputs after publication. Raw pack files, prompts,
generated support artifacts, proposal packets, generated proposal registries,
GitHub comments, labels, checks, chat history, browser state, tool
availability, and model memory do not become Octon authority, control truth,
runtime policy, or permission.

Proposal packet lifecycle authority remains local to each packet's
`proposal.yml`, subtype manifest, proposal standards, validators, declared
promotion targets, and retained evidence. This pack may generate support
artifacts and route lifecycle work; it may not replace the proposal system.

Proposal program authority is parent-owned coordination truth. Program routes
may sequence, gate, summarize, and close out parent coordination evidence, but
they do not satisfy child packet receipts, rewrite child manifests, or own
child promotion, validation, or archive truth.

## Entry Points

The composite command and skill are:

- `/octon-proposal`
- `octon-proposal-lifecycle`

Leaf routes are listed in `context/bundle-matrix.md` and governed by
`context/routing.contract.yml`.

## Naming Scheme

- Pack ID: `octon-proposal-lifecycle`.
- Composite command: `octon-proposal`.
- Route IDs use packet/program-qualified action names, for example
  `create-packet`, `review-program`, `generate-packet-implementation-prompt`,
  or `run-program-verification-and-correction-loop`.
- Leaf command IDs usually use `octon-proposal-<route-id>`, with explicit
  bundle-matrix exceptions for host-safe command names.
- Skill IDs usually use `octon-proposal-lifecycle-<route-id>`, with explicit
  bundle-matrix exceptions for host-safe skill names.
- Prompt set IDs use `octon-proposal-lifecycle-<route-id>`.
- Human-facing command labels omit the redundant namespace and use concise
  forms such as `Packet - Review` or
  `Program - Generate Implementation Orchestration Prompt`.

`/octon-proposal-run-packet-lifecycle` uses the shared lifecycle runner for
orchestration, gate checks, stale-review detection, evidence, checkpoints, and
resume. Its contract uses `execution_strategy: route-progression`. By default,
non-mock executors stop at a gated `route-ready` handoff.
The proposal packet contract also declares `phase_loop.model_version:
phase-loop-v1`; phase ids are checkpoint/event context and not proposal
statuses or approval evidence.
With `--execute-routes`, selected routes run through the shared lifecycle
executor adapter while prompt-bundle execution remains outside the lifecycle
runner itself.
For a missing proposal target, bind creation source context with
`--set-file source=<path>` or `--set source=<text>`; normalized inputs are
retained in the lifecycle checkpoint and evidence so creation can be retried
without losing context.
Durable implementation, promotion, closeout, and archival routes are
machine-delegated when their `delegation_contract`, invocation authority,
evidence gates, scope checks, authority-zone checks, replay class, and
before-dispatch receipts produce a retained delegation proof. `--invocation-authority
unattended` authorizes only proof-gated delegated execution; missing,
ambiguous, stale, unsupported, or out-of-scope proof fails closed.
Packet runs also write hash-chained `lifecycle-events.ndjson` traces under the
run control root and workflow evidence root. `octon lifecycle cancel --run-id
<run> --reason <text>` records durable cancellation evidence; resume and
execute-routes operations return `cancelled` without adapter dispatch after
that marker exists.
Packet-local receipts such as `support/implementation-run.md` and
`support/proposal-closeout.md` advance later lifecycle handoffs without adding
new `proposal.yml` statuses.
`proposal-packet-terminal-closeout` adds a durable terminal-readiness receipt
between proposal closeout and `archive-proposal`. It can report
`archive-ready` or `blocked`, but archive relocation remains a separate
explicitly authorized workflow route.
`proposal-program-delivery` adds a durable delivery coordination receipt for
accepted proposal programs. It can aggregate target-owned child packet
evidence, packet closeout results, archive handoff evidence, Change closeout
evidence, final sync proof, branch cleanup proof, and terminal hygiene proof,
but it does not replace child receipts or own archive, Git, hosted mutation,
branch cleanup, residue deletion, or generated publication authority.

`/octon-proposal-run-program-lifecycle` wraps
`octon lifecycle run --lifecycle proposal-program --target
<program-packet-path>`. It is an orchestration wrapper only, not a dispatcher
route or prompt bundle. Its contract uses
`execution_strategy: orchestrated-replan-loop`. By default it stops at a planned
`program-route-handoff`; full selected-route automation requires
`--execute-routes` plus bounded execution options such as `--max-steps` and
`--max-child-concurrency`. With `--execute-routes`, the program runner loops
through plan, one parent-route or child-batch dispatch, and live replan until
completion, blocker, approval pause, failure, timeout, cancellation, or
max-step exhaustion. One child batch is one step no matter how many child
routes run inside that batch. When `octon` is not installed on PATH, use the
repo-local development launcher `.octon/framework/engine/runtime/run lifecycle
...`; the launcher routes `lifecycle` through the current source-backed kernel
instead of a stale packaged binary.
Program child human-boundary blocks write structured guidance that routes
operators through `octon lifecycle program approve --run-id <program-run>
--child <child> --route <route> --reason <reason>` only for typed
non-machine-provable boundaries. Consuming an already-bound grant records
grant-consumption evidence and still requires a retained delegation proof
before route dispatch.

## Publication

After the pack is selected in `.octon/instance/extensions.yml`, publish with:

```bash
bash .octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh
bash .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh
bash .octon/framework/capabilities/_ops/scripts/publish-host-projections.sh
```

Then run the extension, capability, host projection, and pack-local validators.
