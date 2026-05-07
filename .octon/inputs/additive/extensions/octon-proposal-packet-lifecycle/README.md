# Octon Proposal Packet Lifecycle

First-party additive extension pack for proposal packet lifecycle automation.

This pack composes existing Octon proposal standards, proposal workflows,
concept-integration routes, impact-map routing, validators, publication
scripts, and host projection publishing into a governed operator flow.

## Scope

The pack owns reusable routes for:

- creating proposal packets from source context,
- explaining existing proposal packets,
- reviewing proposal packets with receipt-only verdict state,
- revising proposal packets through packet-local revision receipts,
- generating implementation, verification, correction, and closeout prompts,
- running verification and correction convergence loops,
- closing out individual proposal packets,
- creating and operating proposal programs across canonical child packets.

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

## Entry Points

The composite command and skill are:

- `/octon-proposal-packet`
- `octon-proposal-packet-lifecycle`

Leaf routes are listed in `context/bundle-matrix.md` and governed by
`context/routing.contract.yml`.

`/octon-proposal-packet-run-lifecycle` uses the shared lifecycle runner for
orchestration, gate checks, stale-review detection, evidence, checkpoints, and
resume. By default, non-mock executors stop at a gated `route-ready` handoff.
With `--execute-routes`, selected routes run through the shared lifecycle
executor adapter while prompt-bundle execution remains outside the lifecycle
runner itself.
For a missing proposal target, bind creation source context with
`--set-file source=<path>` or `--set source=<text>`; normalized inputs are
retained in the lifecycle checkpoint and evidence so creation can be retried
without losing context.
Durable implementation, promotion, and archival routes pause for explicit
approval by default. `--approval-policy unattended` is an explicit operator
override for one-run automation; the adapter records approval override evidence
before executing each approval-gated durable route under that policy.
Packet-local receipts such as `support/implementation-run.md` and
`support/proposal-closeout.md` advance later lifecycle handoffs without adding
new `proposal.yml` statuses.

## Publication

After the pack is selected in `.octon/instance/extensions.yml`, publish with:

```bash
bash .octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh
bash .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh
bash .octon/framework/capabilities/_ops/scripts/publish-host-projections.sh
```

Then run the extension, capability, host projection, and pack-local validators.
