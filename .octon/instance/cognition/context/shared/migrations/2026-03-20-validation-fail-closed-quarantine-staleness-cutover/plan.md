---
title: Validation, Fail-Closed, Quarantine, And Staleness Atomic Cutover
description: Atomic clean-break migration plan for promoting Packet 14 runtime-effective validation, receipt persistence, reduced locality publication, and proposal closeout.
---

# Migration Plan

## Profile Selection Receipt

- Date: 2026-03-20
- Version source(s): `/.octon/octon.yml`
- Current version: `0.5.1`
- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- Selection facts:
  - downtime tolerance: one-step cutover is acceptable because this is an
    internal harness control-plane validation and publication contract
  - external consumer coordination ability: not required; affected surfaces
    are repo-local validators, generated effective outputs, control state,
    evidence, docs, and proposal lifecycle state
  - data migration/backfill needs: none beyond regenerating live effective
    outputs and writing retained publication receipts
  - rollback mechanism: full revert of the cutover change set
  - blast radius and uncertainty: high; locality publication semantics,
    extension/control schemas, capability routing metadata, tests, scaffolds,
    and docs all move together
  - compliance/policy constraints: fail closed on stale required effective
    outputs, raw-input runtime/policy dependencies, publication-blocking
    locality errors, native-versus-extension collisions, or quarantined
    repo-snapshot state
- Hard-gate outcomes:
  - no zero-downtime requirement
  - no staged coexistence requirement
  - no data backfill requirement
- Tie-break status: `atomic` selected without exception

## Implementation Plan

- Name: Packet 14 validation/fail-closed/quarantine/staleness atomic cutover
- Owner: `architect`
- Motivation: Promote Packet 14 so runtime-facing trust, reduced-scope
  quarantine, publication receipts, and freshness-gated effective
  publication all agree on one canonical contract.
- Scope: runtime-effective validator gate, locality/extension/capability
  publishers and validators, generated effective schemas, retained publication
  receipt family, export/runtime fail-closed behavior, docs/scaffolds, ADR,
  migration evidence, registry state, and proposal archive closeout.

### Atomic Profile Execution

- Clean-break approach:
  - add the new runtime-effective gate and publication receipt family in the
    same change set that bumps the publication/control schemas
  - update locality publication from full blocking to reduced coherent
    publication in the same window as the validator/test changes that define
    the new trust boundary
  - remove obsolete extension `content_roots` from the effective catalog in
    the same change set that hardens raw-input dependency enforcement
  - archive the Packet 14 proposal package as part of the same promotion
    window as the durable code/docs/tests cutover
- Big-bang implementation steps:
  - add `validate-runtime-effective-state.sh`
  - add `state/evidence/validation/publication/**` plus the
    `octon-validation-publication-receipt-v1` schema
  - bump extension/locality/capability publication contracts and scaffolded
    examples to the Packet 14 schema revisions
  - republish locality, extension, and capability effective outputs
  - extend focused shell regressions for reduced locality publication,
    collision fail-closed behavior, umbrella gate failures, and repo-snapshot
    quarantine blocking
  - update architecture/bootstrap/state docs, record ADR 058, write migration
    evidence, archive the Packet 14 proposal, and refresh the proposal
    registry

## Impact Map (code, tests, docs, contracts)

### Code

- publication scripts for locality, extensions, and capability routing
- runtime-effective and per-surface validators
- generated effective schemas and scaffold templates
- generated effective outputs and retained publication receipts

### Tests

- `test-validate-locality-publication-state.sh`
- `test-validate-extension-publication-state.sh`
- `test-validate-capability-publication-state.sh`
- `test-validate-runtime-effective-state.sh`
- `test-export-harness.sh`
- `alignment-check.sh --profile harness`

### Docs

- root/bootstrap architecture guidance
- generated effective family docs
- runtime-vs-ops and state/control/evidence docs
- ADR 058, migration evidence, and proposal lifecycle records

### Contracts

- Packet 14 runtime-effective validation contract
- extension/locality/capability publication schema versions
- publication receipt contract and evidence placement rules

## Compliance Receipt

- [x] Exactly one profile selected before implementation
- [x] Release-state gate applied
- [x] Pre-1.0 atomic default respected
- [x] No compatibility shim introduced
- [x] Required validations linked

## Exceptions/Escalations

- Current exceptions: none
- Escalations raised: alignment-check required an escalated rerun in this
  environment to refresh `.codex/**` host projections cleanly
- Risk acceptance owner: Octon maintainers

## Verification Evidence

Required evidence bundle location:

- `/.octon/state/evidence/migration/2026-03-20-validation-fail-closed-quarantine-staleness-cutover/`
