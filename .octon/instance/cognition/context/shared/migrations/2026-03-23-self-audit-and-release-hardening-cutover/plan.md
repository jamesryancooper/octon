---
title: Self-Audit And Release Hardening Atomic Cutover
description: Atomic clean-break migration plan for promoting topology-correct self-audit dispatch, authority-aware doc triggers, dependency and workflow trust hardening, runtime target parity, and proposal closeout.
---

# Migration Plan

## Profile Selection Receipt

- Date: 2026-03-23
- Version source(s): `/.octon/octon.yml`
- Current version: `0.5.5`
- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- Selection facts:
  - downtime tolerance: one-step cutover is acceptable because this is a
    repo-local self-audit and release hardening migration
  - external consumer coordination ability: not required; affected surfaces
    are repo-local validators, workflows, launcher scripts, manifests, and
    docs
  - data migration/backfill needs: none beyond writing the new truth surfaces,
    tests, and proposal closeout records
  - rollback mechanism: full revert of the cutover change set
  - blast radius and uncertainty: medium-high; alignment dispatch, safety
    gating, dependency hygiene, workflow trust refs, runtime packaging, tests,
    docs, and proposal lifecycle state all change together
  - compliance/policy constraints: fail closed on retired root references,
    authoritative-doc blind spots, missing Cargo review coverage, mutable
    third-party Action refs in high-trust workflows, or runtime target drift
    masked by source fallback
- Hard-gate outcomes:
  - no zero-downtime requirement
  - no staged coexistence requirement
  - no data backfill requirement
- Tie-break status: `atomic` selected without exception

## Implementation Plan

- Name: Self-audit and release hardening atomic cutover
- Owner: `architect`
- Motivation: Promote one declared truth surface per trust concern so
  self-audit and release behavior becomes reproducible, machine-validated, and
  fail-closed.
- Scope: alignment profile registry, doc-authority classification,
  dependency-review and pin-policy enforcement, runtime release targets,
  launcher/release workflow parity, focused validators/tests/docs, migration
  evidence, proposal registry, and proposal archive closeout.

### Atomic Profile Execution

- Clean-break approach:
  - land the new contract surfaces and the consumers that read or validate them
    in the same change set
  - eliminate the existing drift in the same promotion that adds the blocking
    validators; no advisory coexistence window
  - make runtime strict packaging mode and the target matrix live together so
    launcher and release automation cannot diverge
  - close out proposal lifecycle state only after the durable surfaces,
    validators, and workflows are green in the same branch
- Big-bang implementation steps:
  - add `alignment-profiles.yml`,
    `github-action-pin-policy.yml`, and `release-targets.yml`; extend
    `contract-registry.yml` with authority-aware doc classification
  - thin `alignment-check.sh` around the alignment registry and update
    `alignment-check.yml` plus local validation docs to use the same profile ids
  - replace blanket Markdown ignore behavior in `main-push-safety.yml` with
    `classify-authoritative-doc-change.sh` plus
    `validate-authoritative-doc-triggers.sh`
  - extend `dependabot.yml` for Cargo, add `dependency-review.yml`, and pin the
    high-trust workflow set
    (`ai-review-gate.yml`, `harness-self-containment.yml`,
    `main-push-safety.yml`, `release-please.yml`,
    `runtime-binaries.yml`, `pr-autonomy-policy.yml`,
    `main-change-route-guard.yml`, `change-route-projection.yml`) to full
    commit SHAs
  - add `validate-github-action-pins.sh` and focused workflow-pin regressions
  - add `validate-runtime-target-parity.sh`, update `run`, `run.cmd`, and
    `runtime-binaries.yml` to the declared target matrix, and add strict
    packaging mode coverage
  - refresh durable docs, record the migration evidence and ADR, archive the
    proposal package, and update `generated/proposals/registry.yml`

## Impact Map (Code, Tests, Docs, Contracts)

### Code

- assurance runtime contract registries and validator scripts
- GitHub workflow triggers, dependency review, immutable action refs, and
  release automation
- runtime launcher scripts and release target matrix
- proposal registry and proposal lifecycle records at closeout

### Tests

- `test-alignment-profile-registry.sh`
- `test-validate-authoritative-doc-triggers.sh`
- `test-validate-github-action-pins.sh`
- `test-validate-runtime-target-parity.sh`
- `alignment-check.sh --profile harness`
- targeted workflow/path-filter and dependency-hygiene smoke coverage as needed

### Docs

- proposal README plus implementation and validation plans
- local validation guidance that names alignment profile ids
- runtime and release docs touched by the target matrix and strict packaging
  mode
- ADR and migration evidence bundle

### Contracts

- alignment profile registry contract
- architecture contract registry doc-authority extension
- GitHub Action pin policy contract
- runtime release target matrix contract

## Compliance Receipt

- [x] Exactly one profile selected before implementation
- [x] Release-state gate applied
- [x] Pre-1.0 atomic default respected
- [x] No compatibility shim planned
- [x] Required validations executed and linked

## Exceptions/Escalations

- Current exceptions: none
- Escalations raised: elevated reruns were required in this environment to
  refresh `.codex/**` host projections and complete the final
  `alignment-check.sh --profile harness` verification cleanly
- Risk acceptance owner: Octon maintainers

## Verification Evidence

Required evidence bundle location:

- `/.octon/state/evidence/migration/2026-03-23-self-audit-and-release-hardening-cutover/`
