# Lifecycle Autopilot Effective Catalog And Validation Portability Correction

_Status: Draft architecture proposal packet_

This packet proposes a narrow correction to Lifecycle Autopilot tooling surfaced
while reviewing the Governed Workflow Runtime transition program.

The observed problem is not that the created program packet is structurally
invalid. The problem is that the runtime lifecycle route for `proposal-program`
cannot currently plan cleanly against the effective extension catalog, so packet
creation depends on disclosed fallback work and post-hoc validators.

## Purpose

Restore the expected route for proposal-program Lifecycle Autopilot planning and
make proposal validation portable enough that registry synchronization checks do
not depend on an accidental shell version.

## Scope

- Effective extension catalog lifecycle-contract discovery.
- Proposal-program lifecycle plan smoke tests.
- Proposal registry generator and proposal standard validator shell behavior.
- Durable evidence expectations when fallback/manual packet creation is used.
- Product/support wording that distinguishes implemented runtime behavior from
  blocked or fallback-assisted creation.

## Authority Boundary

This packet lives under `inputs/**` and is non-authoritative proposal lineage
unless promoted. Generated projections remain derived-only. No runtime behavior
changes are live from this draft packet.

## Non-Implementation Statement

This packet does not create or implement workflow statecharts, task-specific
execution harness schemas, agent-node contracts, workflow replay, Durable Object
adapters, MCP integration, external workflow-engine integration, or Governed
Workflow Runtime cutover behavior.
