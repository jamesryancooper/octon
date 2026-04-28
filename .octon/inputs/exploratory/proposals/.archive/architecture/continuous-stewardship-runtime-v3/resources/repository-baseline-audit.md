# Repository Baseline Audit

## Proposal Standards

The live proposal standard requires active proposals to live under
`/.octon/inputs/exploratory/proposals/<kind>/<proposal_id>/`, with
`proposal.yml`, exactly one subtype manifest, `README.md`, and navigation files.
Architecture proposals require `architecture-proposal.yml`,
`architecture/target-architecture.md`, `architecture/acceptance-criteria.md`,
and `architecture/implementation-plan.md`.

## Authority Model

The live architecture specification defines `/.octon/` as the only super-root
and classifies surfaces into authored authority, mutable control, retained
evidence, continuity state, generated runtime-effective handles, generated
operator read models, proposal inputs, and raw additive inputs. It explicitly
states generated outputs never mint authority and proposal packets remain
lineage-only.

## Mission and Autonomy Foundations

The repository already has mission and autonomy-related contracts:

- mission charter v2;
- mission-control lease v1;
- autonomy budget v1;
- circuit breaker v1;
- action slice v1;
- run lifecycle;
- execution authorization;
- context pack builder;
- evidence store.

These make v3 possible but do not by themselves define indefinite stewardship.

## Campaign Posture

Campaigns are deferred. The campaign promotion criteria explicitly require
multi-mission coordination pressure before promotion and prohibit campaigns from
owning workflows, queues, runs, incidents, or becoming a second mission system.

## v1/v2 Dependency Note

The packet assumes v1/v2 surfaces exist. If implementation-time repo inspection
finds that they do not, implementation must add only minimal compatibility shims
and keep v3 focused on stewardship.
