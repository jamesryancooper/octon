---
title: Runtime vs Ops Surface Contract
description: Canonical contract for distinguishing runtime and _ops surfaces across Octon domains.
status: Active
---

# Runtime vs Ops Surface Contract

## Purpose

Define one cross-domain source of truth for classifying artifacts between
`runtime/` and `_ops/`.

This contract reduces placement ambiguity and keeps discovery, validation, and
governance behavior deterministic for both humans and AI agents.

## Scope

This document applies to any Octon domain that exposes both `runtime/` and
`_ops/` surfaces, including runtime-local `_ops/` subpaths.

## Definitions

- `runtime/`: Canonical executable/discovery surface for domain runtime
  artifacts and runtime contracts.
- `_ops/`: Operational support surface for scripts, validators, and
  control-plane helpers that remain portable with the framework bundle.

## Contract Rules

1. Artifacts that are discovered/executed as canonical runtime behavior MUST
   live under `runtime/`.
2. Operational scripts MUST live under `_ops/` (domain-level or runtime-local,
   depending on ownership).
3. Mutable repo-specific operational state, retained evidence, and generated
   outputs MUST NOT live under `framework/**/_ops/**`; they belong under
   `state/**` or `generated/**` according to class ownership.
   Execution-specific mutable control truth belongs under
   `/.octon/state/control/execution/**`; execution scratch belongs under
   `/.octon/generated/.tmp/execution/**`.
4. `_ops/` MUST NOT become a parallel canonical runtime artifact surface.
5. Discovery metadata for runtime artifact classes (for example manifests and
   registries) MUST resolve to canonical runtime surfaces.
6. Normative policy contracts MUST live in `governance/`; `_ops/` MAY carry
   portable helper assets used by enforcement tooling.
7. When an operational asset is owned by one runtime subsystem only, it SHOULD
   live in runtime-local `_ops/` (for example `runtime/_ops/`).
8. When an operational asset coordinates multiple runtime classes in the same
   domain, it SHOULD live in domain-level `_ops/`.
9. `_ops/` automation MUST fail closed when a write target falls outside the
   canonical `state/**` or `generated/**` write roots declared by policy.
10. `_ops/` automation MUST emit enforcement receipts for failed-closed
   decisions and out-of-policy write attempts.
11. `_ops/` automation MUST NOT mutate immutable governance targets without a
    time-boxed, explicitly recorded exception lease.
12. Mission-control helper automation MUST materialize binding state only into
    canonical mission control, retained control evidence, mission continuity,
    generated effective mission-route surfaces, or generated mission/operator
    read-model surfaces.

## Default Mutation Allowlist (Fail-Closed)

Unless a stricter domain contract is declared, `_ops/` automation is limited to
these mutable targets:

- `/.octon/generated/**`
- `/.octon/generated/.tmp/**`
- `/.octon/generated/.tmp/execution/**`
- `/.octon/state/control/**`
- `/.octon/state/control/execution/**`
- `/.octon/state/control/execution/missions/**`
- `/.octon/state/evidence/**`
- `/.octon/state/evidence/control/execution/**`
- `/.octon/state/continuity/**`
- `/.octon/state/continuity/repo/missions/**`
- `/.octon/generated/effective/orchestration/missions/**`
- `/.octon/generated/cognition/summaries/missions/**`
- `/.octon/generated/cognition/summaries/operators/**`
- `/.octon/generated/cognition/projections/materialized/missions/**`
- domain-specific generated artifacts that are explicitly declared in the
  contract registry and linked to enforcement checks

Any undeclared write target is denied by default.

## Immutable Targets for `_ops/` Automation

The following targets are immutable to `_ops/` automation by default:

- `/.octon/framework/cognition/governance/principles/principles.md`
- any `/.octon/*/governance/**` contract path unless an explicit
  exception lease is approved and recorded
- canonical runtime discovery contracts (`manifest.yml`, `registry.yml`) unless
  changed through governed contract updates with matching assurance evidence

## Classification Test

Use this decision sequence:

1. If the artifact is part of canonical runtime behavior or runtime discovery,
   place it in `runtime/`.
2. If the artifact is a validator/control script or other portable operational
   support helper, place it in `_ops/`.
3. If the artifact defines normative policy intent, place it in `governance/`
   (not `_ops/`).
4. If the artifact is mutable control-plane state, retained evidence, or a
   rebuildable generated output, place it in `state/**` or `generated/**`
   rather than `_ops/`.

## Canonical Examples

- Capabilities:
  - `runtime/` hosts executable capability classes (`commands`, `skills`,
    `tools`, `services`).
  - `_ops/` hosts deny-by-default policy control-plane scripts.
  - mutable grant/kill-switch state lives under `/.octon/state/control/**`.
- Cognition:
  - `runtime/` hosts authoritative context/decision/analysis artifacts.
  - `_ops/` hosts guardrail lint/check scripts and mutable guardrail state.
- Engine:
  - `runtime/` hosts launchers, runtime crates, runtime contracts, and config.
  - `_ops/` hosts portable runtime helper scripts only.
  - mutable runtime state and traces live under `/.octon/state/**` or
    `/.octon/generated/**`.
  - mutable execution control truth lives under
    `/.octon/state/control/execution/**`.
  - mission-scoped execution control truth lives under
    `/.octon/state/control/execution/missions/**`.
  - retained control-plane evidence lives under
    `/.octon/state/evidence/control/execution/**`.
  - generated effective mission scenario routes live under
    `/.octon/generated/effective/orchestration/missions/**`.
  - execution scratch lives under `/.octon/generated/.tmp/execution/**`.
  - execution requests, grants, receipts, and executor-profile contracts live
    under `engine/runtime/spec/**`; retained runtime execution evidence lives
    under `/.octon/state/evidence/runs/**`.
- Assurance:
  - Runtime-local `_ops/` under `runtime/` hosts assurance engine entrypoints.
  - retained assurance and validation receipts live under
    `/.octon/state/evidence/validation/assurance/**`.
  - runtime-facing publication receipts live under
    `/.octon/state/evidence/validation/publication/**`.
  - ephemeral assurance rebuild intermediates may live under
    `/.octon/generated/.tmp/assurance/**`.

## Non-Goals

- This contract does not redefine `runtime/governance/practices` bounded
  surface separation.
- This contract does not replace domain-specific artifact conventions for file
  naming, indexing, or retention.
