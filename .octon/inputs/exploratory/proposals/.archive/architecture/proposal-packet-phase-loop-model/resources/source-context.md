# Source Context

## Bound Source

The conversation-bound architecture decision available to this packet is the
operator request received on 2026-05-23. It requires proposal creation only,
grounding against the current Octon lifecycle system, and preservation of the
following architectural position:

- proposal packets remain temporary, non-canonical, and non-authoritative;
- no new proposal manifest statuses unless a contract-level need is proven;
- generated projections, proposal-local receipts, GitHub or CI state, chat,
  browser state, tool availability, and model memory are not authority;
- self-operating means governed execution through approved runner and executor
  mechanisms;
- self-operating must not become self-authorizing;
- runner orchestration remains separate from proposal-extension route
  semantics;
- implementation, promotion, closeout, and archival remain gated by fresh
  receipts, validators, scope checks, and authority-boundary checks.

## Requested Source Reads

The packet was grounded against:

- `.octon/framework/product/features/lifecycle-autopilot.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle-model.md`
- `.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/extension-lifecycle-contract.schema.json`
- `.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/lifecycle-run-event.schema.json`
- `.octon/framework/product/contracts/change-closeout-state-machine.md`
- `.codex/skills/octon-proposal-lifecycle/SKILL.md`
- `.codex/skills/octon-proposal-lifecycle-run-packet-lifecycle/SKILL.md`

Generated effective projections were used only as discovery and comparison
handles. The source lifecycle contract and its generated effective projection
were compared and no content diff was observed during packet creation.

## Source Request Content

The operator requested an architecture proposal packet for the Proposal Packet
Phase-Loop Model, with no implementation in this step. The packet scope may
affect source-authored proposal lifecycle contracts under
`.octon/inputs/additive/extensions/octon-proposal-lifecycle/**`, lifecycle
substrate behavior under `.octon/framework/**`, lifecycle contract schema and
event schema, runner checkpoint, resume, loop-bound, and event-log behavior,
validators and lifecycle acceptance tests, proposal lifecycle skills and
documentation, and generated effective projection refresh as a derived
publication step only.

The operator required the packet to include current-state summary, target
phase-loop model, placement decision, substrate responsibilities, extension
responsibilities, runner/executor boundary, contract/schema/receipt/gate/
checkpoint/event-log/validator impact, file-by-file impact map, tests and
acceptance scenarios, clean-break cutover, explicit non-changes, risks and
fail-closed behavior, later implementation sequencing, and architecture
proposal implementation-grade acceptance criteria.

The intended route after this packet is review and revision until accepted,
then implementation prompt generation only after fresh acceptance and required
gates pass, then implementation through the governed proposal packet lifecycle.

## Verbatim Operator Request

```text
Create an architecture proposal packet for the Proposal Packet Phase-Loop Model.

This is proposal creation only. Do not implement framework, schema, runtime, validator, generated projection, skill, doc, or test changes in this step.

Source Context

Use the architecture decision from this conversation as source context, then ground it against the current Octon lifecycle system. Read and compare:

- .octon/framework/product/features/lifecycle-autopilot.md
- .octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml
- .octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle-model.md
- .octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/extension-lifecycle-contract.schema.json
- .octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/lifecycle-run-event.schema.json
- .octon/framework/product/contracts/change-closeout-state-machine.md
- .codex/skills/octon-proposal-lifecycle/SKILL.md
- .codex/skills/octon-proposal-lifecycle-run-packet-lifecycle/SKILL.md

Use generated effective projections only as runtime discovery/comparison handles. Do not treat them as source authority.

Packet Scope

The packet should propose a clean-break, governed Proposal Packet Phase-Loop Model that may affect:

- source-authored proposal lifecycle contracts under .octon/inputs/additive/extensions/octon-proposal-lifecycle/**
- lifecycle substrate behavior under .octon/framework/**
- lifecycle contract schema and event schema
- runner checkpoint, resume, loop-bound, and event-log behavior
- validators and lifecycle acceptance tests
- proposal lifecycle skills and documentation
- generated effective projection refresh as a derived publication step only

Required Architectural Position

The packet must preserve these constraints:

- Proposal packets remain temporary, non-canonical, and non-authoritative.
- Do not introduce new proposal manifest statuses unless the packet proves a contract-level need.
- Generated projections, proposal-local receipts, GitHub/CI state, chat, browser state, tool availability, and model memory are not authority.
- Self-operating means governed execution through approved runner/executor mechanisms.
- Self-operating must not become self-authorizing.
- Runner orchestration must remain separate from proposal-extension route semantics.
- Implementation, promotion, closeout, and archival must remain gated by fresh receipts, validators, scope checks, and authority-boundary checks.

Proposal Content Requirements

The packet must include:

1. Current-state summary of the proposal lifecycle and Lifecycle Autopilot.
2. Target Proposal Packet phase-loop model.
3. Decision on placement: extension-only, substrate-only, or layered/both.
4. Proposed substrate responsibilities if a generic Phase-Loop Model is needed.
5. Proposal-extension responsibilities.
6. Runner/executor responsibility boundary.
7. Contract, schema, receipt, gate, checkpoint, event-log, and validator impact.
8. File-by-file impact map distinguishing source-authored files from generated projections.
9. Required tests and acceptance scenarios.
10. Migration or clean-break cutover sequence.
11. Explicit non-changes.
12. Risks, failure modes, and fail-closed behavior.
13. Implementation sequencing for a later packet-approved implementation.
14. Acceptance criteria for considering the architecture proposal implementation-grade.

Intended Lifecycle Route

After packet creation, do not proceed directly to implementation. The intended route is:

1. Create the architecture proposal packet.
2. Review and revise it until accepted and implementation-grade.
3. Generate the implementation prompt only after fresh acceptance and required gates pass.
4. Implement through the governed proposal packet lifecycle.

The purpose is to turn this architecture decision into reviewable, receipt-backed lifecycle work, not to let this chat become hidden implementation authority.
```
