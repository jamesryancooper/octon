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
- `_ops/`: Operational support surface for scripts, validators, control-plane
  helpers, and mutable operational state.

## Contract Rules

1. Artifacts that are discovered/executed as canonical runtime behavior MUST
   live under `runtime/`.
2. Operational scripts and mutable operational state MUST live under `_ops/`
   (domain-level or runtime-local, depending on ownership).
3. `_ops/` MUST NOT become a parallel canonical runtime artifact surface.
4. Discovery metadata for runtime artifact classes (for example manifests and
   registries) MUST resolve to canonical runtime surfaces.
5. Normative policy contracts MUST live in `governance/`; `_ops/` MAY carry
   operational policy state used by enforcement tooling.
6. When an operational asset is owned by one runtime subsystem only, it SHOULD
   live in runtime-local `_ops/` (for example `runtime/_ops/`).
7. When an operational asset coordinates multiple runtime classes in the same
   domain, it SHOULD live in domain-level `_ops/`.
8. Mutable control-plane state in `_ops/` MUST be scoped to declared allowlist
   roots and MUST fail closed when a write target falls outside those roots.
9. `_ops/` automation MUST emit enforcement receipts for failed-closed
   decisions and out-of-policy write attempts.
10. `_ops/` automation MUST NOT mutate immutable governance targets without a
    time-boxed, explicitly recorded exception lease.

## Default Mutation Allowlist (Fail-Closed)

Unless a stricter domain contract is declared, `_ops/` automation is limited to
these mutable targets:

- `<domain>/_ops/state/**`
- `/.octon/output/**`
- `/.octon/continuity/**`
- domain-specific generated artifacts that are explicitly declared in the
  contract registry and linked to enforcement checks

Any undeclared write target is denied by default.

## Immutable Targets for `_ops/` Automation

The following targets are immutable to `_ops/` automation by default:

- `/.octon/cognition/governance/principles/principles.md`
- any `/.octon/*/governance/**` contract path unless an explicit
  exception lease is approved and recorded
- canonical runtime discovery contracts (`manifest.yml`, `registry.yml`) unless
  changed through governed contract updates with matching assurance evidence

## Classification Test

Use this decision sequence:

1. If the artifact is part of canonical runtime behavior or runtime discovery,
   place it in `runtime/`.
2. If the artifact is a validator/control script, lease/grant/lock/log state,
   or other mutable operational support data, place it in `_ops/`.
3. If the artifact defines normative policy intent, place it in `governance/`
   (not `_ops/`).
4. If the artifact is mutable control-plane state, verify that writes are
   constrained to allowlist roots and not targeting immutable governance paths.

## Canonical Examples

- Capabilities:
  - `runtime/` hosts executable capability classes (`commands`, `skills`,
    `tools`, `services`).
  - `_ops/` hosts deny-by-default policy control-plane scripts and mutable
    grant/kill-switch state.
- Cognition:
  - `runtime/` hosts authoritative context/decision/analysis artifacts.
  - `_ops/` hosts guardrail lint/check scripts and mutable guardrail state.
- Engine:
  - `runtime/` hosts launchers, runtime crates, runtime contracts, and config.
  - `_ops/` hosts prebuilt binaries and mutable runtime state.
- Assurance:
  - Runtime-local `_ops/` under `runtime/` hosts assurance engine entrypoints
    and lock/state artifacts for assurance execution.

## Non-Goals

- This contract does not redefine `runtime/governance/practices` bounded
  surface separation.
- This contract does not replace domain-specific artifact conventions for file
  naming, indexing, or retention.
