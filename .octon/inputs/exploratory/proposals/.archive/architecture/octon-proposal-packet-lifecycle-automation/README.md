# Octon Proposal Packet Lifecycle Automation

This is a temporary, implementation-scoped architecture proposal for
`octon-proposal-packet-lifecycle-automation`.
It is not a canonical runtime, documentation, policy, or contract authority.

## Purpose

- proposal kind: `architecture`
- promotion scope: `octon-internal`
- summary: create a full-scope first-party additive extension pack that
  automates the complete proposal packet lifecycle from source context through
  packet creation, explanation, implementation prompt generation, verification,
  correction, closeout, proposal-program coordination, PR/CI/review cleanup,
  and archival.

## Scope

This proposal intentionally covers the whole lifecycle rather than an MVP-only
subset. The landing must include the reusable extension pack, route contracts,
prompt bundles, command and skill surfaces, validation fixtures, publication
flow, generated effective outputs, host projections, and packet support
artifact conventions.

## Promotion Targets

- `.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle/`
- `.octon/instance/extensions.yml`
- `.octon/state/control/extensions/active.yml`
- `.octon/generated/effective/extensions/`
- `.octon/generated/effective/capabilities/`

Host projections under `.claude/**`, `.codex/**`, and `.cursor/**` are
validation and publication outputs for this proposal, not promotion targets.
They remain outside the `octon-internal` promotion target set.

## Reading Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `navigation/source-of-truth-map.md`
4. `architecture/target-architecture.md`
5. `architecture/reusable-patterns.md`
6. `architecture/proposal-program-pattern.md`
7. `architecture/lifecycle-route-matrix.md`
8. `architecture/implementation-plan.md`
9. `architecture/validation-plan.md`
10. `architecture/acceptance-criteria.md`
11. `navigation/artifact-catalog.md`
12. `/.octon/generated/proposals/registry.yml`

## Exit Path

The proposal exits when the lifecycle automation is implemented as a published
first-party additive extension pack, all required generated outputs and host
projections are coherent, pack-local validation proves the full universe of
manual lifecycle scenarios, and the proposal can be archived without leaving
durable targets dependent on this proposal path.

## Non-Authority Statement

The proposal packet, generated prompts, support files, manual prompt source,
chat history, PR comments, labels, external tools, generated projections, and
raw inputs do not become proposal lifecycle authority. Durable behavior must
land in extension pack contracts, published generated effective extension and
capability outputs, host projections, validators, and retained evidence.
