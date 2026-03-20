# Implementation Plan

## Profile Selection Receipt

- Date: 2026-03-20
- Version source(s): `/.octon/octon.yml`
- Current version: `0.5.1`
- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- Selection facts:
  - downtime tolerance: one-step cutover is acceptable because this is an
    internal harness control-plane migration rather than an external
    compatibility surface
  - external consumer coordination ability: not required; the harness is
    self-hosted in this repository
  - data migration/backfill needs: no staged coexistence window is required;
    the remaining work is a doc/index/validator/generator/template convergence
    sweep plus removal of one duplicate generated summary surface
  - rollback mechanism: full revert of the cutover change set
  - blast radius and uncertainty: broad active-reference rewrite across
    architecture docs, bootstrap docs, skills, workflows, validators,
    scaffolding, and cognition generation scripts
  - compliance/policy constraints: fail closed on duplicate decision-summary
    destinations, wrong-class memory placement, ADR/state confusion, or invalid
    scope continuity assumptions
- Hard-gate outcomes:
  - no zero-downtime requirement
  - no external coexistence requirement
  - no staged publication requirement
- Tie-break status: `atomic` selected without exception

## Implementation Plan

- Name: Memory routing and decision surfaces atomic cutover
- Owner: `architect`
- Motivation: Promote Packet 11 so Octon uses one fail-closed memory-routing
  contract for durable context, ADR authority, active continuity, retained
  evidence, and generated cognition views.
- Scope: memory policy, shared context routing, ADR discovery/readmes, repo and
  scope continuity guidance, operational decision evidence docs, cognition
  summary generation and validation scripts, active reference surfaces,
  scaffolding/workflow guidance, Packet 11 closeout ADR, and migration evidence.

### Atomic Profile Execution

- Clean-break approach:
  - promote Packet 11 as one promotion event
  - remove the duplicate generated ADR summary from
    `instance/cognition/context/shared/decisions.md` in the same change set
    that repoints every active consumer to
    `generated/cognition/summaries/decisions.md`
  - align `framework/**`, `instance/**`, `state/**`, and `generated/**`
    contracts so memory-like artifacts have one canonical home and no active
    alternate path remains
  - harden validators and generators in the same change set so the old summary
    path and other wrong-class memory placements cannot reappear silently
  - preserve historical retained evidence as historical evidence unless a file
    is an active control-plane input; do not rewrite append-oriented evidence
    just to normalize old prose
  - record one Packet 11 closeout ADR and one migration evidence bundle
- Big-bang implementation steps:
  - align memory policy and architecture docs:
    update `framework/agency/governance/MEMORY.md`, `.octon/README.md`,
    `.octon/instance/bootstrap/START.md`,
    `.octon/framework/cognition/_meta/architecture/specification.md`, and
    `runtime-vs-ops-contract.md` to the Packet 11 routing model
  - normalize shared durable-context routing:
    rewrite `instance/cognition/context/shared/memory-map.md`,
    `instance/cognition/context/shared/continuity.md`, and
    `instance/cognition/context/index.yml` so they distinguish durable context
    from continuity, evidence, and generated views
  - reassert ADR authority and remove the duplicate summary:
    update `instance/cognition/decisions/README.md`, retire
    `instance/cognition/context/shared/decisions.md` as an active generated
    surface, and keep the readable ADR summary only at
    `generated/cognition/summaries/decisions.md`
  - cut the generator and generated-artifact validators to the final model:
    update `sync-runtime-artifacts.sh`,
    `validate-generated-runtime-artifacts.sh`, and any associated fixtures so
    generated decisions publish only to `generated/**`
  - rewrite active reference surfaces in one sweep:
    bootstrap/catalog/conventions docs, active practices, skills, workflows,
    templates, assurance checklists, and validator fixtures that currently
    point at `instance/cognition/context/shared/decisions.md`
  - lock the continuity and evidence boundary:
    update continuity architecture docs, decision-retention docs, and evidence
    readmes so ADRs, continuity, and retained evidence no longer overlap
  - harden fail-closed validation:
    update boundary validators and tests so duplicate summary destinations,
    generated-under-instance drift, and wrong-class memory placement block
    publication
  - add closeout records:
    create one Packet 11 atomic-cutover ADR under
    `instance/cognition/decisions/<next-id>-memory-routing-and-decision-surfaces-atomic-cutover.md`
    and publish one migration evidence bundle
- Big-bang rollout steps:
  - run cognition generation and check mode after the generator rewrite
  - run memory, boundary, and alignment validators against the final tree
  - refresh generated cognition summaries and projections from canonical
    sources
  - publish the Packet 11 migration evidence bundle
  - archive or mark the proposal implemented only after validators converge on
    the final one-home model

### Transitional Profile Execution (if selected)

- Not applicable. Packet 11 is planned as a strict `atomic` cutover.

## Atomic Change-Set Inventory

### Active Removals

- remove `instance/cognition/context/shared/decisions.md` as an active
  generated summary destination
- remove active docs, templates, workflows, skills, and validator fixtures
  that instruct operators to read or write that instance-local generated
  summary
- remove validator expectations that require the duplicate instance-local
  summary to exist

### Active Additions And Rewrites

- add the final Packet 11 closeout ADR and migration evidence bundle
- rewrite active discovery/docs surfaces to reference:
  - durable context in `instance/cognition/context/**`
  - ADR authority in `instance/cognition/decisions/**`
  - active continuity in `state/continuity/**`
  - retained evidence in `state/evidence/**`
  - readable generated summaries in `generated/cognition/summaries/**`
- rewrite generator and validation contracts so the generated summary path is
  single-homed under `generated/**`

### Historical Evidence Handling

- preserve historical migration receipts, run evidence, and append-only logs as
  historical records even if they mention the retired instance-local summary
  path
- add new migration evidence that explains the Packet 11 cutover and the
  retirement of the duplicate summary surface
- rewrite historical evidence only if a retained file is still used as an
  active control-plane contract or validator input

## Impact Map (code, tests, docs, contracts)

### Code

- cognition generation scripts and generated-artifact validators
- repo-instance and harness-structure validators plus their fixtures
- any active workflow, skill, or scaffolding asset that still points at the
  retired summary path

### Tests

- `bash .octon/framework/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh --check`
- `bash .octon/framework/cognition/_ops/runtime/scripts/validate-generated-runtime-artifacts.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-repo-instance-boundary.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-continuity-memory.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness`
- fixture-based regressions for:
  - `test-validate-repo-instance-boundary.sh`
  - `test-validate-continuity-memory.sh`
  - `test-packet10-generated-tracking.sh`
  - `test-sync-runtime-artifacts-fixtures.sh`

### Docs

- root and bootstrap orientation surfaces
- memory policy and umbrella architecture contracts
- shared context routing docs and continuity docs
- ADR discovery docs
- active practices, workflows, and templates that currently instruct operators
  to update the retired instance-local summary surface

### Contracts

- Packet 11 memory-routing contract
- generated-cognition summary publication contract
- repo-instance wrong-class placement contract
- continuity/evidence retention boundary contract
- Packet 11 migration evidence bundle

## Promotion Gate Checklist

- [x] Exactly one profile selected before implementation
- [x] Release-state gate applied
- [x] Pre-1.0 atomic default respected
- [x] Hard-gate fact collection recorded
- [ ] No compatibility shims or dual summary destinations remain
- [ ] No active docs or templates instruct operators to use the retired
      instance-local generated summary path
- [ ] Generator and validator contracts converge on the single generated
      summary home
- [ ] Required validations execute cleanly and are linked in migration
      evidence

## Exceptions/Escalations

- Current exceptions:
  - the live repo still carries a duplicate generated summary at
    `/.octon/instance/cognition/context/shared/decisions.md`
  - active docs, workflows, practices, and validator fixtures still point at
    that retired destination
- Escalations raised: none
- Risk acceptance owner: Octon maintainers

## Verification Evidence

### Static Verification

- confirm there is no active generated ADR summary path under `instance/**`
- confirm `memory-map.md`, ADR docs, continuity docs, and bootstrap docs agree
  on the same class-root routing model
- confirm active templates, skills, workflows, and checklists no longer
  mention the retired instance-local summary destination

### Runtime Verification

- confirm `sync-runtime-artifacts.sh` publishes decisions only to
  `generated/cognition/summaries/decisions.md`
- confirm generated-artifact validation passes without requiring the instance
  duplicate
- confirm boundary and continuity validators reject wrong-class memory
  placement and duplicate ledgers

### CI Verification

- confirm the harness alignment path exercises the updated Packet 11 boundary
  rules
- confirm fixture-based tests cover both the valid generated-only summary case
  and the invalid duplicate-summary-under-instance case

Required evidence bundle location on execution day:

- `/.octon/state/evidence/migration/<YYYY-MM-DD>-memory-routing-and-decision-surfaces-cutover/`

Required bundle files:

- `bundle.yml`
- `evidence.md`
- `commands.md`
- `validation.md`
- `inventory.md`

## Rollback

- Rollback strategy: full commit-range revert of the Packet 11 cutover
- Rollback trigger conditions:
  - generator and validator contracts cannot converge on one generated summary
    home
  - active docs, workflows, and templates cannot be aligned to one memory
    routing model in the same change set
  - harness alignment or boundary validation fails closed after the duplicate
    summary path is removed
- Rollback evidence references:
  - `/.octon/state/evidence/migration/<YYYY-MM-DD>-memory-routing-and-decision-surfaces-cutover/`
