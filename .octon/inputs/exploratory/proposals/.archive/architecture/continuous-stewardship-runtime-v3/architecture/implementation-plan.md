# Implementation Plan

## Workstream 0 — Repository Recheck

Before implementation, re-inspect live repo state for v1/v2 surfaces. If v1/v2
are missing, add only compatibility shims needed to compile stewardship handoff
records and document the dependency. Do not reimplement v1/v2 inside v3.

## Workstream 1 — Framework Contracts

Add JSON schemas/specs for Stewardship Program, Epoch, Trigger, Admission
Decision, Renewal Decision, Ledger, and Stewardship Evidence Profile. These
contracts must reference existing mission/run/runtime contracts rather than
replacing them.

## Workstream 2 — Instance Stewardship Authority

Create `instance/stewardship/programs/**` conventions and scaffold for one
program per repo/workspace in the MVP. Define `program.yml`, `policy.yml`,
`trigger-rules.yml`, and `review-cadence.yml`.

## Workstream 3 — Control / Evidence / Continuity Roots

Create state roots for program status, epochs, triggers, admission decisions,
renewal decisions, ledger, evidence, and continuity. Ensure state/control is
operational truth, state/evidence is retained proof, and state/continuity is
resumable context only.

## Workstream 4 — Runtime Stewardship Engine

Implement runtime modules that:

1. resolve the active Stewardship Program;
2. open or verify active epoch;
3. observe enabled trigger sources;
4. normalize triggers;
5. evaluate admission decisions;
6. emit Idle Decisions when no admissible work exists;
7. hand admitted work to v1/v2 mission surfaces;
8. update Stewardship Ledger;
9. evaluate renewal at epoch close.

## Workstream 5 — CLI

Add `octon steward ...` commands. CLI must be high-level and operator-friendly,
but all material work must hand off to v2 Mission Runner and governed run paths.

## Workstream 6 — Campaign Coordination Hook

Add only non-executing campaign hook logic. Campaigns remain deferred unless
campaign promotion criteria are satisfied by evidence. A campaign candidate may
be emitted as an admission result; it cannot launch work.

## Workstream 7 — Validators

Add validation for:

- root placement;
- schema validity;
- no work outside active epoch;
- trigger admission before mission creation;
- idle decision emitted when no work exists;
- renewal closeout requirements;
- campaign gate adherence;
- no direct material execution from stewardship;
- generated/read-model non-authority.

## Workstream 8 — Documentation and Closeout

Update framework practices, runtime docs, CLI help, and generated read-model
rules. Retain promotion evidence and run two consecutive validation passes before
marking implementation complete.
