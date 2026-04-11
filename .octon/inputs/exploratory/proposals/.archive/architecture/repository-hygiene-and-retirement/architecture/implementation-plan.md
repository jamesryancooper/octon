# Implementation Plan

## Program overview

The implementation program is designed to land the repository-hygiene
capability family without broad Octon redesign. The governing principle is:

> **Land the authoritative hygiene architecture atomically inside `.octon/**`,
> then use that architecture to drive baseline audits, registrations, and
> cleanup work.**

This keeps the architecture clean-break while allowing cleanup execution to be
iterative and evidence-backed afterward.

## Workstreams

### Workstream A — Governance and policy authoring

Deliverables:

- `repo-hygiene.yml` policy
- retirement policy/review/drift/ablation contract updates
- source-of-truth clarification that hygiene remains subordinate to existing
  retirement/build-to-delete governance

Exit criteria:

- no second registry or review plane exists;
- same-change registration rule is explicit;
- closure-grade packet requirements are explicit.

### Workstream B — Repo-native command capability

Deliverables:

- command manifest registration
- command README
- command runner and common helper
- operator-facing mode contract (`scan`, `enforce`, `audit`, `packetize`)

Exit criteria:

- command lane is no longer empty;
- detector stack and mode boundaries are explicit;
- destructive action remains outside the command.

### Workstream C — Assurance and integration wiring

Deliverables:

- dedicated hygiene validator
- updates to phase-7 institutionalization validator
- updates to global retirement closure validator
- repo-local workflow integrations for architecture conformance, closure
  certification, and scheduled hygiene audits

Exit criteria:

- structure-level failures are catchable in CI;
- closure-grade evidence includes hygiene findings;
- repo-local integrations are linked to the authoritative `.octon/**` design.

### Workstream D — Baseline audit and registration normalization

Deliverables:

- first full audit packet under retained evidence roots
- normalized findings across the six decision actions
- same-change registry/register updates for newly discovered transitional or
  historical surfaces

Exit criteria:

- every high-confidence transitional residue finding is fixed or registered;
- direct-delete candidates are separated from ablation-required candidates;
- a reusable audit baseline exists for later cleanup waves.

### Workstream E — First cleanup wave and closure readiness

Deliverables:

- low-risk safe deletes
- ablation plans for nontrivial delete/demote candidates
- build-to-delete packet attachment
- dual clean validation passes

Exit criteria:

- the capability family is operational, validated, and closure-ready;
- proposal implementation status can advance once durable targets and evidence
  exist.

## Ordered phases

### Phase 0 — Packet review and acceptance

Inputs:

- this proposal packet
- governance review of the scope split between `.octon/**` promotion targets
  and repo-local workflow integrations

Outputs:

- accepted target architecture
- implementation ownership assignment

### Phase 1 — Atomic authoritative landing

Create or modify the `.octon/**` authority surfaces in one clean-break change:

- policy
- command registration and command files
- retirement/drift/ablation contract updates
- assurance validators

Phase 1 must not claim the architecture live until its dependent repo-local
workflow integrations are also ready to run.

### Phase 2 — Repo-local workflow integration

Land the dependent `.github/workflows/**` edits that wire the authoritative
surfaces into PR, scheduled-audit, and closure flows.

If implementation governance requires proposal-scope purity beyond this packet,
track this phase explicitly as a linked repo-local change package. The
architecture defined here remains the governing design either way.

### Phase 3 — Baseline audit

Run the first scheduled/full audit against `main` after the command and
workflow surfaces exist. Produce:

- audit summary
- findings
- blocking findings
- initial packetization design proof

### Phase 4 — Registration and low-risk cleanup

Resolve baseline findings by class:

- direct safe deletes for high-confidence whole-path items;
- same-change registration for transitional residue;
- retained-with-rationale or demotion plans for historical surfaces;
- no destructive action for ambiguous items.

### Phase 5 — Closure readiness

Require two consecutive clean validation passes across the architecture
conformance, hygiene, and closure flows after the authoritative surfaces and
baseline registration work are stable.

## Dependencies

- existing support-target and pack admissions remain unchanged;
- build-to-delete retirement spine remains authoritative;
- repo-local workflow integrations cannot be skipped if the target state is to
  be claimed as operationally live;
- baseline audit cannot precede command + workflow availability.

## Ownership expectations by role

| Role | Expected responsibility |
| --- | --- |
| Octon governance | approve policy/contract/validator changes; maintain retirement and closure semantics |
| `operator://octon-maintainers` | implement command surfaces, workflow integrations, and cleanup PRs |
| reviewers | validate scope containment, evidence sufficiency, and proposal conformance |
| future cleanup operators | use the landed capability family rather than inventing local ad hoc cleanup procedures |

## Governing migration principle

The proposal is **atomic in architecture** and **iterative in use**.
Authoritative surfaces land as one coherent capability family; cleanup
operations then execute repeatedly inside that governed family.
