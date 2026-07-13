# Minimal Workspace Projects

This is the draft RP-10 architecture proposal for
`octon-architecture-migration-workspace-projects`. It is a temporary,
non-authoritative implementation aid. It does not authorize implementation,
execution, capability grants, project access, or support promotion.

## Outcome

Octon gains the smallest durable project layer needed by one developer working
across multiple projects:

- stable project identity independent of the current filesystem path;
- strict project boundary, lifecycle, relationship, and Project Profile
  bindings;
- deterministic inference and refresh that preserve operator corrections;
- an immutable project/profile snapshot for each active run;
- a rebuildable location index; and
- one read-only CLI mission inbox spanning projects.

Workspace Project data can identify, select, describe, and narrow. It cannot
authorize, grant, widen a Run Contract, select a capability, or become a second
control plane.

## Program Position

- logical packet: `RP-10`
- workgroup: `RWG-10`
- parent program: `octon-architecture-migration-program`
- dependency: `RP-01`, proposal
  `octon-architecture-migration-canonical-authority`
- downstream consumer: `RP-11`, the deterministic Harness Factory

RP-10 may be implemented alongside the broker and trust spine after RP-01
freezes canonical authority and launch semantics. RP-11 may not exit until
RP-10 has proved project non-authority and two-project continuity.

## Promotion Scope

The proposal is `octon-internal`. All promotion targets are under `.octon/**`.
Host-provider configuration and `.github/**` are outside this packet.

## Reading Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `navigation/source-of-truth-map.md`
4. `resources/packet-contract.yml`
5. `resources/traceability.yml`
6. `architecture/current-state-gap-map.md`
7. `architecture/target-architecture.md`
8. `architecture/file-change-map.md`
9. `architecture/cutover-plan.md`
10. `architecture/rollback-plan.md`
11. `architecture/acceptance-criteria.md`
12. `architecture/validation-plan.md`
13. `architecture/implementation-plan.md`
14. `architecture/operator-disclosure.md`
15. `support/implementation-grade-completeness-review.md`

## Current Gate

The packet remains `draft`. Structural validation does not make it accepted or
implementation-ready. RP-01 completion, independent review, dynamic proof
UE-010, and later implementation receipts remain future gates.
