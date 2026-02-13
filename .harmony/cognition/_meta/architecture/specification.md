---
title: Harmony Harness Umbrella Specification
description: Canonical cross-subsystem contract for the root .harmony harness.
status: Active
---

# Harmony Harness Umbrella Specification

## Purpose

Define the authoritative cross-subsystem contract for `.harmony/`.

This specification states what must remain true across all harness domains. It is the normative source for cross-cutting invariants; subsystem specifications and READMEs expand and implement these rules.

## Scope

This document applies to the root harness at `/.harmony/`.

It covers:

- Structural and portability invariants
- Cross-cutting governance and safety rules
- Subsystem contract boundaries
- Normative references and expansion paths

It does not cover:

- Runtime implementation internals
- Product-level application architecture outside `/.harmony/`
- Domain-level execution details that belong in subsystem specs

## Normative Language

The keywords **MUST**, **MUST NOT**, **SHOULD**, and **MAY** are normative.

## Authority and Precedence

Within harness documentation, precedence is:

1. This umbrella specification for cross-subsystem invariants
2. Subsystem specifications in each domain for local contracts
3. Manifests/registries for machine-readable routing and metadata
4. Domain READMEs and guides for orientation and usage

If this file conflicts with `/.harmony/scope.md` or `/.harmony/conventions.md`, scope and conventions for this harness take precedence.

## Canonical Rules

### HARMONY-SPEC-001: Domain-Organized Harness Root

The root harness MUST remain domain-organized under `/.harmony/` with explicit top-level domains (`agency`, `capabilities`, `cognition`, `continuity`, `orchestration`, `quality`, `scaffolding`, `ideation`, `output`).

Expands in:

- [The `.harmony` Directory README](/.harmony/cognition/_meta/architecture/README.md)
- [Start Here](/.harmony/START.md)

### HARMONY-SPEC-002: Portability Is Metadata-Driven

Portable framework assets, human-led zones, and resolution rules MUST be declared in `/.harmony/harmony.yml`.

Expands in:

- [Harmony Manifest](/.harmony/harmony.yml)
- [Shared Foundation README](/.harmony/README.md)
- [The `.harmony` Directory README](/.harmony/cognition/_meta/architecture/README.md)

### HARMONY-SPEC-003: Progressive-Disclosure Discovery

Routable capabilities MUST use progressive disclosure:

- discovery index (`manifest.yml`)
- extended metadata (`registry.yml`)
- full definition (`SKILL.md` / `WORKFLOW.md`)

Expands in:

- [Skills Manifest](/.harmony/capabilities/skills/manifest.yml)
- [Workflows Manifest](/.harmony/orchestration/workflows/manifest.yml)
- [Progressive Disclosure Principle](/.harmony/cognition/principles/progressive-disclosure.md)

### HARMONY-SPEC-004: Deny-by-Default Permissions

Agent access MUST be allowlist-based and fail-closed for tools, file writes, and service invocation.

Expands in:

- [Deny by Default](/.harmony/cognition/principles/deny-by-default.md)
- [Guardrails](/.harmony/cognition/principles/guardrails.md)
- [Capabilities Tools Manifest](/.harmony/capabilities/tools/manifest.yml)

### HARMONY-SPEC-005: No Silent Apply for Material Side Effects

Material side effects (edits, merges, deploys, runtime mutations) MUST require explicit human approval.

Expands in:

- [No Silent Apply](/.harmony/cognition/principles/no-silent-apply.md)
- [HITL Checkpoints](/.harmony/cognition/principles/hitl-checkpoints.md)

### HARMONY-SPEC-006: Risk-Tiered Human Governance

Approval intensity MUST scale with risk tier. Low-risk read-only automation MAY run without hard checkpoints; consequential actions MUST use explicit checkpoints.

Expands in:

- [HITL Checkpoints](/.harmony/cognition/principles/hitl-checkpoints.md)
- [Harmony Methodology](/.harmony/cognition/methodology/README.md)

### HARMONY-SPEC-007: Continuity Artifact Integrity

Continuity artifacts designated append-only MUST preserve historical integrity. Past entries MUST NOT be rewritten except where explicitly allowed by contract.

Expands in:

- [Conventions](/.harmony/conventions.md)
- [Continuity README](/.harmony/continuity/README.md)
- [Session Exit Checklist](/.harmony/quality/session-exit.md)

### HARMONY-SPEC-008: Completion and Exit Quality Gates

Tasks MUST satisfy definition-of-done and session-exit gates before completion or handoff.

Expands in:

- [Quality README](/.harmony/quality/README.md)
- [Definition of Done](/.harmony/quality/complete.md)
- [Session Exit Checklist](/.harmony/quality/session-exit.md)

### HARMONY-SPEC-009: Human-Led Ideation Boundaries

`/.harmony/ideation/**` MUST be treated as human-led; autonomous access is prohibited unless a human explicitly scopes the request.

Expands in:

- [Start Here](/.harmony/START.md)
- [Ideation README](/.harmony/ideation/README.md)
- [Harmony Manifest](/.harmony/harmony.yml)

### HARMONY-SPEC-010: Documentation and Contract Coupling

Behavioral, contract, policy, or operational changes SHOULD update corresponding docs in the same change set.

Expands in:

- [Documentation is Code](/.harmony/cognition/principles/documentation-is-code.md)
- [Contract-first](/.harmony/cognition/principles/contract-first.md)

### HARMONY-SPEC-101: Agency Contract Boundary

`/.harmony/agency/**` MUST define actor taxonomy, invocation model, and delegation boundaries as an explicit contract.

Expands in:

- [Agency Subsystem Specification](/.harmony/agency/_meta/architecture/specification.md)
- [Agency Manifest](/.harmony/agency/manifest.yml)

### HARMONY-SPEC-201: Capabilities Contract Boundary

`/.harmony/capabilities/**` MUST preserve the four-part capabilities taxonomy (`commands`, `skills`, `tools`, `services`) and its interaction model.

Expands in:

- [Capabilities Specification](/.harmony/capabilities/_meta/architecture/specification.md)
- [Capabilities README](/.harmony/capabilities/README.md)

### HARMONY-SPEC-301: Orchestration Contract Boundary

`/.harmony/orchestration/**` MUST preserve workflow and mission boundaries, including discovery metadata and lifecycle semantics.

Expands in:

- [Orchestration Specification](/.harmony/orchestration/_meta/architecture/specification.md)
- [Orchestration README](/.harmony/orchestration/README.md)

### HARMONY-SPEC-501: Continuity Contract Boundary

`/.harmony/continuity/**` MUST preserve session-state continuity through explicit log, task, and next-step artifacts.

Expands in:

- [Continuity Architecture README](/.harmony/continuity/_meta/architecture/README.md)
- [Continuity README](/.harmony/continuity/README.md)

### HARMONY-SPEC-601: Quality Contract Boundary

`/.harmony/quality/**` MUST preserve completion and exit contracts as enforceable quality gates.

Expands in:

- [Quality Architecture README](/.harmony/quality/_meta/architecture/README.md)
- [Quality README](/.harmony/quality/README.md)

### HARMONY-SPEC-701: Ideation Contract Boundary

`/.harmony/ideation/**` MUST remain human-led and separate from autonomous agent execution paths.

Expands in:

- [Ideation Architecture README](/.harmony/ideation/_meta/architecture/README.md)
- [Ideation README](/.harmony/ideation/README.md)

### HARMONY-SPEC-801: Output Contract Boundary

`/.harmony/output/**` MUST be used for generated artifacts and reporting outputs, separated from source and policy domains.

Expands in:

- [Output Architecture README](/.harmony/output/_meta/architecture/README.md)
- [Output README](/.harmony/output/README.md)

## Subsystem Ownership Map

| Subsystem | Contract Source |
|---|---|
| Agency | `/.harmony/agency/_meta/architecture/specification.md` |
| Capabilities | `/.harmony/capabilities/_meta/architecture/specification.md` |
| Orchestration | `/.harmony/orchestration/_meta/architecture/specification.md` |
| Cognition (cross-cutting) | `/.harmony/cognition/_meta/architecture/specification.md` (this file) |
| Continuity | `/.harmony/continuity/_meta/architecture/README.md` |
| Quality | `/.harmony/quality/_meta/architecture/README.md` |
| Ideation | `/.harmony/ideation/_meta/architecture/README.md` |
| Output | `/.harmony/output/_meta/architecture/README.md` |

## Reference Contract for Expansion Docs

Documents that expand one or more normative rules SHOULD declare frontmatter references:

```yaml
spec_refs:
  - HARMONY-SPEC-201
  - HARMONY-SPEC-003
```

This creates a stable mapping from detailed documents back to canonical rules.

## Change Policy

Changes to this specification SHOULD:

1. Keep rule IDs stable
2. Add new rules instead of mutating semantics silently
3. Update affected expansion docs in the same change
4. Record material governance shifts in ADRs when applicable
