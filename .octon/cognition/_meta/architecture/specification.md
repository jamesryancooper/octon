---
title: Octon Harness Umbrella Specification
description: Canonical cross-subsystem contract for the root .octon harness.
status: Active
---

# Octon Harness Umbrella Specification

## Purpose

Define the authoritative cross-subsystem contract for `.octon/`.

This specification states what must remain true across all harness domains. It is the normative source for cross-cutting invariants; subsystem specifications and READMEs expand and implement these rules.

## Scope

This document applies to the root harness at `/.octon/`.

It covers:

- Structural and portability invariants
- Cross-cutting governance and safety rules
- Subsystem contract boundaries
- Normative references and expansion paths

It does not cover:

- Runtime implementation internals
- Product-level application architecture outside `/.octon/`
- Domain-level execution details that belong in subsystem specs

## Normative Language

The keywords **MUST**, **MUST NOT**, **SHOULD**, and **MAY** are normative.

## Authority and Precedence

Within harness documentation, precedence is:

1. This umbrella specification for cross-subsystem invariants
2. Subsystem specifications in each domain for local contracts
3. Manifests/registries for machine-readable routing and metadata
4. Domain READMEs and guides for orientation and usage

If this file conflicts with `/.octon/scope.md` or `/.octon/conventions.md`, scope and conventions for this harness take precedence.

When agency actor contracts are in scope, contract-layer precedence remains:
`AGENTS.md` -> `CONSTITUTION.md` -> `DELEGATION.md` -> `MEMORY.md` -> `AGENT.md` -> `SOUL.md`.

## SSOT Precedence Matrix (Runtime, Governance, Practices)

| Authority ID | Canonical SSOT | Constraint | Conflict Resolution |
|---|---|---|---|
| runtime-execution | `/.octon/engine/runtime/**` | `/.octon/capabilities/runtime/**` defines capability semantics only; it MUST NOT override engine enforcement. | Fail closed and require ADR-backed contract reconciliation before promotion. |
| governance-policy | `/.octon/*/governance/**` | Governance contracts are normative policy authority for their domain and MUST NOT be superseded by practices guidance. | Fail closed and escalate through governance owners plus ADR update. |
| operating-practices | `/.octon/*/practices/**` | Practices are implementation guidance and MUST NOT override runtime or governance contracts. | Record drift violation and block promotion until guidance aligns with authority contracts. |

## Canonical Rules

### OCTON-SPEC-001: Domain-Organized Harness Root

The root harness MUST remain domain-organized under `/.octon/` with explicit top-level domains (`agency`, `capabilities`, `cognition`, `continuity`, `orchestration`, `assurance`, `scaffolding`, `engine`, `ideation`, `output`).

Expands in:

- [The `.octon` Directory README](/.octon/cognition/_meta/architecture/README.md)
- [Start Here](/.octon/START.md)

### OCTON-SPEC-002: Portability Is Metadata-Driven

Portable framework assets, human-led zones, and resolution rules MUST be declared in `/.octon/octon.yml`.

Expands in:

- [Octon Manifest](/.octon/octon.yml)
- [Shared Foundation README](/.octon/README.md)
- [The `.octon` Directory README](/.octon/cognition/_meta/architecture/README.md)

### OCTON-SPEC-003: Progressive-Disclosure Discovery

Routable capabilities MUST use progressive disclosure:

- discovery index (`manifest.yml`)
- extended metadata (`registry.yml`)
- full definition (`SKILL.md` / `README.md`)

Expands in:

- [Skills Manifest](/.octon/capabilities/runtime/skills/manifest.yml)
- [Workflows Manifest](/.octon/orchestration/runtime/workflows/manifest.yml)
- [Progressive Disclosure Principle](/.octon/cognition/governance/principles/progressive-disclosure.md)

### OCTON-SPEC-004: Deny-by-Default Permissions

Agent access MUST be allowlist-based and fail-closed for tools, file writes, and service invocation.

Expands in:

- [Deny by Default](/.octon/cognition/governance/principles/deny-by-default.md)
- [Guardrails](/.octon/cognition/governance/principles/guardrails.md)
- [Capabilities Tools Manifest](/.octon/capabilities/runtime/tools/manifest.yml)

### OCTON-SPEC-005: No Silent Apply for Material Side Effects

Material side effects (edits, merges, deploys, runtime mutations) MUST require explicit ACP policy gating before durable promotion.

Expands in:

- [No Silent Apply](/.octon/cognition/governance/principles/no-silent-apply.md)
- [Autonomous Control Points](/.octon/cognition/governance/principles/autonomous-control-points.md)

### OCTON-SPEC-006: Risk-Tiered System Governance

Control intensity MUST scale with risk tier under a system-governed model. Low-risk read-only automation MAY run without hard gates; consequential actions MUST use explicit ACP gates that run by default.

Humans retain policy authorship, exceptions handling, and escalation authority.

Expands in:

- [Autonomous Control Points](/.octon/cognition/governance/principles/autonomous-control-points.md)
- [Octon Methodology](/.octon/cognition/practices/methodology/README.md)

### OCTON-SPEC-007: Continuity Artifact Integrity

Continuity artifacts designated append-only MUST preserve historical integrity. Past entries MUST NOT be rewritten except where explicitly allowed by contract.

Expands in:

- [Conventions](/.octon/conventions.md)
- [Continuity README](/.octon/continuity/README.md)
- [Session Exit Checklist](/.octon/assurance/practices/session-exit.md)

### OCTON-SPEC-008: Completion and Exit Assurance Gates

Tasks MUST satisfy definition-of-done and session-exit gates before completion or handoff.

Expands in:

- [Assurance README](/.octon/assurance/README.md)
- [Definition of Done](/.octon/assurance/practices/complete.md)
- [Session Exit Checklist](/.octon/assurance/practices/session-exit.md)

### OCTON-SPEC-009: Human-Led Ideation Boundaries

`/.octon/ideation/**` MUST be treated as human-led; autonomous access is prohibited unless a human explicitly scopes the request.

Expands in:

- [Start Here](/.octon/START.md)
- [Ideation README](/.octon/ideation/README.md)
- [Octon Manifest](/.octon/octon.yml)

### OCTON-SPEC-010: Documentation and Contract Coupling

Behavioral, contract, policy, or operational changes SHOULD update corresponding docs in the same change set.

Expands in:

- [Documentation is Code](/.octon/cognition/governance/principles/documentation-is-code.md)
- [Contract-first](/.octon/cognition/governance/principles/contract-first.md)

### OCTON-SPEC-011: Project Bootstrap Initialization

After a harness is introduced into a repository, project-level bootstrap artifacts MUST be initialized via `/init` (or script equivalent) using scaffolding templates.

Minimum bootstrap outputs:

- canonical `/.octon/AGENTS.md` rendered from `.octon/scaffolding/runtime/bootstrap/AGENTS.md`
- repo-root `AGENTS.md` ingress adapter to `/.octon/AGENTS.md`
- repo-root `CLAUDE.md` ingress adapter to `/.octon/AGENTS.md` when safe and non-destructive
- canonical `/.octon/OBJECTIVE.md` rendered from `.octon/scaffolding/runtime/bootstrap/objectives/`
- `alignment-check` shim rendered from `.octon/scaffolding/runtime/bootstrap/alignment-check`

Optional compatibility outputs (when explicitly requested):

- `BOOT.md` rendered from `.octon/scaffolding/runtime/bootstrap/BOOT.md`
- `BOOTSTRAP.md` rendered from `.octon/scaffolding/runtime/bootstrap/BOOTSTRAP.md`

Expands in:

- [Init Command](/.octon/capabilities/runtime/commands/init.md)
- [Init Script](/.octon/scaffolding/runtime/_ops/scripts/init-project.sh)
- [Templates Architecture](/.octon/scaffolding/_meta/architecture/templates.md)

### OCTON-SPEC-012: Portability and Independence Defaults

Octon core behavior MUST remain:

- self-contained (required harness contracts and assets live within `.octon/`),
- tech/runtime-agnostic (core semantics do not require a specific provider, framework, or runtime),
- OS-agnostic (core contract semantics hold across operating systems).

Provider/runtime/OS-specific implementation details MAY exist only as optional adapters or implementation paths and MUST NOT redefine core contract behavior.

Expands in:

- [Portability and Independence Principle](/.octon/cognition/governance/principles/portability-and-independence.md)
- [Octon Methodology](/.octon/cognition/practices/methodology/README.md)
- [Services README](/.octon/capabilities/runtime/services/README.md)

### OCTON-SPEC-013: Bounded Surface Separation

Subsystems with executable actors or runtime-routing artifacts SHOULD separate:

- runtime artifacts,
- governance contracts,
- operating practices.

This separation SHOULD be adopted only when all three concern classes are
materially present and independently owned in the subsystem; domains that
naturally have fewer concern classes SHOULD NOT be force-fit.

When adopted, each concern MUST have one canonical surface and legacy parallel surfaces MUST be removed by clean-break migration.

Expands in:

- [Bounded Surfaces Contract](/.octon/cognition/_meta/architecture/bounded-surfaces-contract.md)
- [Agency Subsystem Specification](/.octon/agency/_meta/architecture/specification.md)
- [Capabilities Specification](/.octon/capabilities/_meta/architecture/specification.md)
- [Orchestration Subsystem Specification](/.octon/orchestration/_meta/architecture/specification.md)
- [Cognition README](/.octon/cognition/README.md)
- [Assurance README](/.octon/assurance/README.md)
- [Engine README](/.octon/engine/README.md)

### OCTON-SPEC-014: Runtime vs `_ops/` Surface Semantics

For domains that use both `runtime/` and `_ops/` surfaces:

- `runtime/` MUST remain the canonical surface for executable/discoverable
  runtime artifacts and runtime contracts.
- `_ops/` MUST contain operational scripts and mutable state used to validate,
  enforce, or support runtime behavior.
- `_ops/` MUST NOT become a parallel canonical runtime artifact surface.
- Normative policy contracts MUST remain in `governance/`; `_ops/` MAY contain
  operational policy state consumed by enforcement tooling.

Expands in:

- [Runtime vs Ops Surface Contract](/.octon/cognition/_meta/architecture/runtime-vs-ops-contract.md)
- [Start Here](/.octon/START.md)

### OCTON-SPEC-015: Contract Registry Metadata and Coverage

Contract-bearing surfaces MUST be represented in a canonical contract registry
with machine-readable metadata.

Each registry entry MUST declare:

- `contract_id`
- `path`
- `owner`
- `version`
- `supersedes`
- `enforced_by` (at least one enforcement path)

Assurance gates MUST fail closed for missing metadata, missing enforcement
bindings, or broken registry path resolution.

Expands in:

- [Context Index](/.octon/cognition/runtime/context/index.yml)
- [Definition of Done](/.octon/assurance/practices/complete.md)
- [Contract Governance Validator](/.octon/assurance/runtime/_ops/scripts/validate-contract-governance.sh)

### OCTON-SPEC-016: Engine and Capabilities Runtime Tie-Breaker

Runtime authority is split intentionally:

- `capabilities/runtime/` defines behavioral contract semantics and discovery
  routing for capability classes.
- `engine/runtime/` defines execution lifecycle, runtime safety policy
  enforcement, and final execution authority.

When capability semantics and engine runtime enforcement disagree, the engine
decision is authoritative for execution. If conflict cannot be resolved via a
declared contract, enforcement MUST fail closed and require an ADR-backed
contract update before promotion.

Expands in:

- [Engine Governance](/.octon/engine/governance/README.md)
- [Assurance Precedence Contract](/.octon/assurance/governance/precedence.md)
- [Assurance Contract Boundary](/.octon/assurance/README.md)

### OCTON-SPEC-017: Instruction-Layer Precedence Contract

Material runs MUST model instruction layers using a deterministic precedence
order and emit explainable layer manifests for observable/local instruction
sources.

Developer-layer instruction artifacts MUST be policy-governed and fail closed
when unapproved sources are supplied in strict mode.

Expands in:

- [Instruction-Layer Precedence Contract](/.octon/engine/governance/instruction-layer-precedence.md)
- [Engine Governance](/.octon/engine/governance/README.md)
- [Context Index](/.octon/cognition/runtime/context/index.yml)

### OCTON-SPEC-101: Agency Contract Boundary

`/.octon/agency/**` MUST define actor taxonomy, invocation model, and delegation boundaries as an explicit contract.

Expands in:

- [Agency Subsystem Specification](/.octon/agency/_meta/architecture/specification.md)
- [Agency Manifest](/.octon/agency/manifest.yml)

### OCTON-SPEC-201: Capabilities Contract Boundary

`/.octon/capabilities/**` MUST preserve the four-part capabilities taxonomy (`commands`, `skills`, `tools`, `services`) and its interaction model.

Expands in:

- [Capabilities Specification](/.octon/capabilities/_meta/architecture/specification.md)
- [Capabilities README](/.octon/capabilities/README.md)

### OCTON-SPEC-301: Orchestration Contract Boundary

`/.octon/orchestration/**` MUST preserve workflow and mission boundaries, including discovery metadata and lifecycle semantics.

Expands in:

- [Orchestration Specification](/.octon/orchestration/_meta/architecture/specification.md)
- [Orchestration README](/.octon/orchestration/README.md)

### OCTON-SPEC-401: Engine Contract Boundary

`/.octon/engine/**` MUST preserve bounded engine surfaces (`runtime/`,
`governance/`, `practices/`) with executable authority restricted to
`engine/runtime/`.

Expands in:

- [Engine README](/.octon/engine/README.md)
- [Engine Architecture Contract](/.octon/engine/_meta/architecture/README.md)

### OCTON-SPEC-451: Cognition Contract Boundary

`/.octon/cognition/**` MUST preserve bounded cognition surfaces
(`runtime/`, `governance/`, `practices/`) and keep cognition operational
scripts and state in `cognition/_ops/`.

Expands in:

- [Cognition README](/.octon/cognition/README.md)
- [Cognition Architecture Contract](/.octon/cognition/_meta/architecture/README.md)
- [Engineering Principles & Standards](/.octon/cognition/governance/principles/principles.md)
- [Cognition Methodology](/.octon/cognition/practices/methodology/README.md)

### OCTON-SPEC-501: Continuity Contract Boundary

`/.octon/continuity/**` MUST preserve session-state continuity through explicit log, task, and next-step artifacts.

Expands in:

- [Continuity Architecture README](/.octon/continuity/_meta/architecture/README.md)
- [Continuity README](/.octon/continuity/README.md)

### OCTON-SPEC-601: Assurance Contract Boundary

`/.octon/assurance/**` MUST preserve bounded assurance surfaces
(`runtime/`, `governance/`, `practices/`) and completion/exit contracts as
enforceable assurance gates.
The Assurance Engine is the authoritative local engine for
weighted assurance policy resolution, scoring, and gating in this boundary.

Expands in:

- [Assurance Architecture README](/.octon/assurance/_meta/architecture/README.md)
- [Assurance README](/.octon/assurance/README.md)

### OCTON-SPEC-701: Ideation Contract Boundary

`/.octon/ideation/**` MUST remain human-led and separate from autonomous agent execution paths.

Expands in:

- [Ideation Architecture README](/.octon/ideation/_meta/architecture/README.md)
- [Ideation README](/.octon/ideation/README.md)

### OCTON-SPEC-801: Output Contract Boundary

`/.octon/output/**` MUST be used for generated artifacts and reporting outputs, separated from source and policy domains.

Expands in:

- [Output Architecture README](/.octon/output/_meta/architecture/README.md)
- [Output README](/.octon/output/README.md)

## Subsystem Ownership Map

| Subsystem | Contract Source |
|---|---|
| Agency | `/.octon/agency/_meta/architecture/specification.md` |
| Capabilities | `/.octon/capabilities/_meta/architecture/specification.md` |
| Orchestration | `/.octon/orchestration/_meta/architecture/specification.md` |
| Engine | `/.octon/engine/_meta/architecture/README.md` |
| Cognition (cross-cutting) | `/.octon/cognition/_meta/architecture/specification.md` (this file) |
| Continuity | `/.octon/continuity/_meta/architecture/README.md` |
| Assurance | `/.octon/assurance/_meta/architecture/README.md` |
| Ideation | `/.octon/ideation/_meta/architecture/README.md` |
| Output | `/.octon/output/_meta/architecture/README.md` |

## Reference Contract for Expansion Docs

Documents that expand one or more normative rules SHOULD declare frontmatter references:

```yaml
spec_refs:
  - OCTON-SPEC-201
  - OCTON-SPEC-003
```

This creates a stable mapping from detailed documents back to canonical rules.

## Change Policy

Changes to this specification SHOULD:

1. Keep rule IDs stable
2. Add new rules instead of mutating semantics silently
3. Update affected expansion docs in the same change
4. Record material governance shifts in ADRs when applicable
5. Update contract registry metadata (`contract_id`, `version`, `enforced_by`)
   when new or modified contracts are introduced
