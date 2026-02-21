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

The root harness MUST remain domain-organized under `/.harmony/` with explicit top-level domains (`agency`, `capabilities`, `cognition`, `continuity`, `orchestration`, `assurance`, `scaffolding`, `engine`, `ideation`, `output`).

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

- [Skills Manifest](/.harmony/capabilities/runtime/skills/manifest.yml)
- [Workflows Manifest](/.harmony/orchestration/runtime/workflows/manifest.yml)
- [Progressive Disclosure Principle](/.harmony/cognition/governance/principles/progressive-disclosure.md)

### HARMONY-SPEC-004: Deny-by-Default Permissions

Agent access MUST be allowlist-based and fail-closed for tools, file writes, and service invocation.

Expands in:

- [Deny by Default](/.harmony/cognition/governance/principles/deny-by-default.md)
- [Guardrails](/.harmony/cognition/governance/principles/guardrails.md)
- [Capabilities Tools Manifest](/.harmony/capabilities/runtime/tools/manifest.yml)

### HARMONY-SPEC-005: No Silent Apply for Material Side Effects

Material side effects (edits, merges, deploys, runtime mutations) MUST require explicit ACP policy gating before durable promotion.

Expands in:

- [No Silent Apply](/.harmony/cognition/governance/principles/no-silent-apply.md)
- [Autonomous Control Points](/.harmony/cognition/governance/principles/autonomous-control-points.md)

### HARMONY-SPEC-006: Risk-Tiered Human Governance

Control intensity MUST scale with risk tier. Low-risk read-only automation MAY run without hard gates; consequential actions MUST use explicit ACP gates.

Expands in:

- [Autonomous Control Points](/.harmony/cognition/governance/principles/autonomous-control-points.md)
- [Harmony Methodology](/.harmony/cognition/practices/methodology/README.md)

### HARMONY-SPEC-007: Continuity Artifact Integrity

Continuity artifacts designated append-only MUST preserve historical integrity. Past entries MUST NOT be rewritten except where explicitly allowed by contract.

Expands in:

- [Conventions](/.harmony/conventions.md)
- [Continuity README](/.harmony/continuity/README.md)
- [Session Exit Checklist](/.harmony/assurance/practices/session-exit.md)

### HARMONY-SPEC-008: Completion and Exit Assurance Gates

Tasks MUST satisfy definition-of-done and session-exit gates before completion or handoff.

Expands in:

- [Assurance README](/.harmony/assurance/README.md)
- [Definition of Done](/.harmony/assurance/practices/complete.md)
- [Session Exit Checklist](/.harmony/assurance/practices/session-exit.md)

### HARMONY-SPEC-009: Human-Led Ideation Boundaries

`/.harmony/ideation/**` MUST be treated as human-led; autonomous access is prohibited unless a human explicitly scopes the request.

Expands in:

- [Start Here](/.harmony/START.md)
- [Ideation README](/.harmony/ideation/README.md)
- [Harmony Manifest](/.harmony/harmony.yml)

### HARMONY-SPEC-010: Documentation and Contract Coupling

Behavioral, contract, policy, or operational changes SHOULD update corresponding docs in the same change set.

Expands in:

- [Documentation is Code](/.harmony/cognition/governance/principles/documentation-is-code.md)
- [Contract-first](/.harmony/cognition/governance/principles/contract-first.md)

### HARMONY-SPEC-011: Project Bootstrap Initialization

After a harness is introduced into a repository, project-level bootstrap artifacts MUST be initialized via `/init` (or script equivalent) using scaffolding templates.

Minimum bootstrap outputs:

- `AGENTS.md` rendered from `.harmony/scaffolding/runtime/templates/AGENTS.md`
- `CLAUDE.md` alias to `AGENTS.md` when safe and non-destructive
- `alignment-check` shim rendered from `.harmony/scaffolding/runtime/templates/alignment-check`

Optional compatibility outputs (when explicitly requested):

- `BOOT.md` rendered from `.harmony/scaffolding/runtime/templates/BOOT.md`
- `BOOTSTRAP.md` rendered from `.harmony/scaffolding/runtime/templates/BOOTSTRAP.md`

Expands in:

- [Init Command](/.harmony/capabilities/runtime/commands/init.md)
- [Init Script](/.harmony/scaffolding/runtime/_ops/scripts/init-project.sh)
- [Templates Architecture](/.harmony/scaffolding/_meta/architecture/templates.md)

### HARMONY-SPEC-012: Portability and Independence Defaults

Harmony core behavior MUST remain:

- self-contained (required harness contracts and assets live within `.harmony/`),
- tech/runtime-agnostic (core semantics do not require a specific provider, framework, or runtime),
- OS-agnostic (core contract semantics hold across operating systems).

Provider/runtime/OS-specific implementation details MAY exist only as optional adapters or implementation paths and MUST NOT redefine core contract behavior.

Expands in:

- [Portability and Independence Principle](/.harmony/cognition/governance/principles/portability-and-independence.md)
- [Harmony Methodology](/.harmony/cognition/practices/methodology/README.md)
- [Services README](/.harmony/capabilities/runtime/services/README.md)

### HARMONY-SPEC-013: Bounded Surface Separation

Subsystems with executable actors or runtime-routing artifacts SHOULD separate:

- runtime artifacts,
- governance contracts,
- operating practices.

This separation SHOULD be adopted only when all three concern classes are
materially present and independently owned in the subsystem; domains that
naturally have fewer concern classes SHOULD NOT be force-fit.

When adopted, each concern MUST have one canonical surface and legacy parallel surfaces MUST be removed by clean-break migration.

Expands in:

- [Bounded Surfaces Contract](/.harmony/cognition/_meta/architecture/bounded-surfaces-contract.md)
- [Agency Subsystem Specification](/.harmony/agency/_meta/architecture/specification.md)
- [Capabilities Specification](/.harmony/capabilities/_meta/architecture/specification.md)
- [Orchestration Subsystem Specification](/.harmony/orchestration/_meta/architecture/specification.md)
- [Cognition README](/.harmony/cognition/README.md)
- [Assurance README](/.harmony/assurance/README.md)
- [Engine README](/.harmony/engine/README.md)

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

### HARMONY-SPEC-401: Engine Contract Boundary

`/.harmony/engine/**` MUST preserve bounded engine surfaces (`runtime/`,
`governance/`, `practices/`) with executable authority restricted to
`engine/runtime/`.

Expands in:

- [Engine README](/.harmony/engine/README.md)
- [Engine Architecture Contract](/.harmony/engine/_meta/architecture/README.md)

### HARMONY-SPEC-451: Cognition Contract Boundary

`/.harmony/cognition/**` MUST preserve bounded cognition surfaces
(`runtime/`, `governance/`, `practices/`) and keep cognition operational
scripts and state in `cognition/_ops/`.

Expands in:

- [Cognition README](/.harmony/cognition/README.md)
- [Cognition Architecture Contract](/.harmony/cognition/_meta/architecture/README.md)
- [Engineering Principles & Standards](/.harmony/cognition/governance/principles/principles.md)
- [Cognition Methodology](/.harmony/cognition/practices/methodology/README.md)

### HARMONY-SPEC-501: Continuity Contract Boundary

`/.harmony/continuity/**` MUST preserve session-state continuity through explicit log, task, and next-step artifacts.

Expands in:

- [Continuity Architecture README](/.harmony/continuity/_meta/architecture/README.md)
- [Continuity README](/.harmony/continuity/README.md)

### HARMONY-SPEC-601: Assurance Contract Boundary

`/.harmony/assurance/**` MUST preserve bounded assurance surfaces
(`runtime/`, `governance/`, `practices/`) and completion/exit contracts as
enforceable assurance gates.
The Assurance Engine is the authoritative local engine for
weighted assurance policy resolution, scoring, and gating in this boundary.

Expands in:

- [Assurance Architecture README](/.harmony/assurance/_meta/architecture/README.md)
- [Assurance README](/.harmony/assurance/README.md)

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
| Engine | `/.harmony/engine/_meta/architecture/README.md` |
| Cognition (cross-cutting) | `/.harmony/cognition/_meta/architecture/specification.md` (this file) |
| Continuity | `/.harmony/continuity/_meta/architecture/README.md` |
| Assurance | `/.harmony/assurance/_meta/architecture/README.md` |
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
