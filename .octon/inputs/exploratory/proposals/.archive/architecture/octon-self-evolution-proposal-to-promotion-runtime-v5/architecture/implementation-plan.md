# Implementation Plan

## Workstream 1 — Canonical contracts

Add portable framework contracts for Evolution Program, Evolution Candidate, Governance Impact Simulation, Constitutional Amendment Request, Evolution Ledger, Promotion Runtime, and Recertification Runtime.

## Workstream 2 — Instance governance policy

Add repo-owned policy surfaces for self-evolution, promotion, recertification, and constitutional amendment handling under `instance/governance/evolution/**`.

## Workstream 3 — Control/evidence materialization

Add canonical control roots for candidates, simulations, amendment requests, promotions, recertifications, and ledger. Add retained evidence root conventions for each stage.

## Workstream 4 — Runtime/CLI surface

Define and implement MVP CLI surfaces:

- `octon evolve observe`
- `octon evolve candidates`
- `octon evolve inspect <candidate>`
- `octon evolve propose <candidate>`
- `octon evolve simulate <candidate>`
- `octon evolve lab <candidate>`
- `octon evolve ledger`
- `octon amend request`
- `octon promote inspect`
- `octon promote apply`
- `octon recertify status`
- `octon recertify run`

If runtime implementation is not yet ready, commands must fail closed with machine-readable reason codes rather than silently doing nothing.

## Workstream 5 — Proposal compiler integration

The compiler must generate standard-compliant proposal packets and must not promote anything. It must retain candidate-to-proposal traceability and emit a Decision Request when approval is needed.

## Workstream 6 — Promotion runtime

Promotion must verify proposal status, accepted decision, declared durable targets, promotion safety, rollback/retirement posture, and absence of proposal-path dependencies in durable outputs.

## Workstream 7 — Recertification runtime

Recertification must validate authority placement, root boundaries, execution authorization coverage, support claims, capability routes, generated/effective freshness, evidence completeness, rollback posture, and docs/runtime consistency.

## Workstream 8 — Validators and tests

Add schemas, fixtures, negative tests, and placement checks. Required negative tests include generated summary as authority, proposal path as runtime dependency, lab success without approval, and simulation success without approval.
