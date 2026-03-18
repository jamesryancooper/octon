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

## Precedence

1. `framework/**` base contracts and runtime authority
2. `instance/**` repo-specific authored authority
3. `state/**` operational truth
4. `generated/**` derived support artifacts
5. `inputs/**` non-authoritative raw input

## Canonical References

- root manifest: `/.octon/octon.yml`
- ingress: `/.octon/instance/ingress/AGENTS.md`
- bootstrap docs: `/.octon/instance/bootstrap/`
- framework architecture: `/.octon/framework/cognition/_meta/architecture/`
- generated proposal registry: `/.octon/generated/proposals/registry.yml`

## Fail-Closed Rules

- Missing required manifests block runtime.
- Wrong-class placement blocks runtime.
- Stale required generated outputs block runtime.
- Direct reads from raw `inputs/**` by runtime or policy code block runtime.
