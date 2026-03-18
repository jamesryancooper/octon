---
title: Octon Harness Umbrella Specification
description: Canonical cross-subsystem contract for the Octon super-root.
status: Active
---

# Octon Harness Umbrella Specification

## Purpose

Define the authoritative cross-subsystem contract for `/.octon/` after the
super-root cutover.

## Root Invariants

1. `/.octon/` is the single authoritative super-root.
2. The only canonical class roots are `framework/`, `instance/`, `inputs/`,
   `state/`, and `generated/`.
3. Only `framework/**` and `instance/**` are authored authority.
4. `state/**` is authoritative only as operational truth and retained
   evidence.
5. `generated/**` is never source of truth.
6. Raw `inputs/**` paths must never become direct runtime or policy
   dependencies.
7. Human-led ideation lives under `inputs/exploratory/ideation/**`.
8. Retired legacy roots from the mixed-tree topology must not be
   reintroduced.
9. `/.octon/octon.yml` is the authoritative root manifest for topology,
   versioning, profiles, and fail-closed policy hooks.
10. `repo_snapshot` is behaviorally complete and includes enabled-pack
    dependency closure.
11. `full_fidelity` is advisory only and is not a synthetic export payload.

## Precedence

1. `framework/**` base contracts and runtime authority
2. `instance/**` repo-specific authored authority
3. `state/**` operational truth
4. `generated/**` derived support artifacts
5. `inputs/**` non-authoritative raw input

## Contract Markers

### OCTON-SPEC-015

The umbrella specification is the canonical cross-subsystem contract registry
surface for super-root authority, placement, and fail-closed behavior.

### OCTON-SPEC-016

The umbrella specification owns the cross-subsystem SSOT precedence contract
for runtime, governance, and practices.

## SSOT Precedence Matrix (Runtime, Governance, Practices)

| Authority slice | Canonical surface | Rule |
| --- | --- | --- |
| runtime-execution | `/.octon/framework/engine/runtime/**` | Engine execution authority MUST NOT override engine enforcement. |
| governance-policy | `/.octon/*/governance/**` | Governance policy MUST NOT be superseded by practices guidance. |
| operating-practices | `/.octon/*/practices/**` | Practices guidance MUST NOT override runtime or governance contracts. |

## Canonical References

- root manifest: `/.octon/octon.yml`
- desired extension config: `/.octon/instance/extensions.yml`
- ingress: `/.octon/instance/ingress/AGENTS.md`
- bootstrap docs: `/.octon/instance/bootstrap/`
- export runner: `/.octon/framework/orchestration/runtime/_ops/scripts/export-harness.sh`
- framework architecture: `/.octon/framework/cognition/_meta/architecture/`
- generated proposal registry: `/.octon/generated/proposals/registry.yml`

## Fail-Closed Rules

- Missing required manifests block runtime.
- Wrong-class placement blocks runtime.
- Stale required generated outputs block runtime.
- Direct reads from raw `inputs/**` by runtime or policy code block runtime.
- Incomplete enabled-pack closure blocks `repo_snapshot` export.
