---
title: Harmony Charter
description: Foundational charter for Harmony's purpose, objective, operating model, scope, and governance as a portable agent-first filesystem harness.
status: Active
version: "1.0.0"
owner: Harmony governance
review_cadence: Quarterly or per minor release
effective_date: 2026-03-05
---

# Harmony Charter

Harmony is an agent-first, system-governed engineering harness that lives in the filesystem.  
It is not product code; it is the operating system for how work is directed, executed, verified, and learned in the directory where it is installed.

## 1. Charter Scope and Authority

This charter defines Harmony's:

- purpose and objective,
- value proposition and philosophy,
- core goals and strategy,
- autonomy and human authority model,
- architectural domain and surface contracts.

Applicability:

- Applies to the filesystem root containing `/.harmony/` and its descendant directories, subject to explicit policy exclusions and human-led zones.
- Applies to autonomous and human-assisted operations that use Harmony contracts, workflows, capabilities, and assurance gates.

Precedence:

- Repository and agency contract precedence remains authoritative (`AGENTS.md` -> constitution/delegation/memory -> agent contracts).
- This charter provides cross-domain framing and must not weaken stricter domain governance.

## 2. Harmony Definition

Harmony is:

- a portable drop-in harness for governed autonomous engineering operations,
- an execution control plane for PLAN -> SHIP -> LEARN loops,
- a contract system for deterministic, observable, reversible, recoverable, fail-closed, policy-bounded work.

Harmony is not:

- product/runtime business logic,
- a replacement for application architecture,
- a bypass around governance, assurance, or policy ownership.

## 3. Vision

Enable any directory on any operating system to become a governed, autonomous engineering workspace in minutes, with clear contracts, bounded authority, durable learning, and explicit safety, security, privacy, and policy constraints.

## 4. Primary Objective

Deliver highly portable, drop-in autonomous operation that is:

- deterministic enough to trust,
- observable enough to debug and audit,
- safe, secure, and privacy-preserving,
- reversible, recoverable, and fail-closed under policy uncertainty,
- governed enough to run unattended within explicit policy bounds and bound objective contracts.

## 5. Purpose

Harmony exists to:

1. Make long-running autonomous execution reliable, safe, secure, and privacy-preserving: deterministic, observable, adaptable, reversible, recoverable, and fail-closed under policy uncertainty.
2. Standardize delivery across direction-setting, planning, implementation, verification, governance, and continuity.
3. Keep autonomy bounded by policy, explicit objective contracts, evidence, and reversible, recoverable, and escalation controls.
4. Preserve durable continuity memory so decisions, tradeoffs, and outcomes remain auditable and reusable across any managed work context (including organizational, personal, and local filesystem projects).
5. Stay portable and stack-agnostic without vendor lock-in or OS lock-in.

## 6. Core Goals

1. Increase delivery speed without losing safety, security, or privacy.
2. Enforce governance by default.
3. Preserve durable continuity memory across any managed work context (including organizational, personal, research, education, and local filesystem projects).
4. Remain portable across filesystems and operating systems.
5. Favor minimal sufficient complexity.
6. Require explicit objective binding for autonomous execution.
7. Ensure material actions are observable, attributable, reversible, recoverable, and fail-closed on policy uncertainty across all managed work contexts.
8. Maintain interoperability across tools, vendors, and technology stacks.
9. Keep human effort concentrated on policy authorship, exceptions, and escalation authority rather than routine execution steps.

## 7. Value Proposition

Harmony provides:

- fast, objective-bound autonomous execution with bounded safety, security, and privacy risk,
- repeatable governance, assurance, and fail-closed policy enforcement by default,
- explicit intent-contract binding for autonomous runs,
- durable operational memory across sessions,
- transportable operating semantics across projects and environments,
- a consistent agent operating model independent of IDE or AI vendor.

## 8. Operating Philosophy

Harmony is governed by these non-negotiable concepts:

- agent-first execution, system-governed control,
- single source of truth and contract-first design,
- progressive disclosure for discovery and routing,
- deny-by-default permissions and no-silent-apply for material side effects,
- objective-bound autonomy via explicit intent contracts, deterministic provenance, and fail-closed behavior under policy uncertainty,
- assurance-first tradeoff ordering: `Assurance > Productivity > Integration`,
- minimal sufficient complexity and smallest robust solution,
- append-only continuity for historical integrity.

## 9. Autonomy and Human Authority Model

Default stance:

- Maximize unattended operation for routine, policy-compliant work.
- Minimize human intervention to high-leverage governance decisions.

Human authority remains mandatory for:

- policy authorship and policy exceptions,
- objective-contract approval and version changes for autonomous material runs,
- expansion of authority surfaces (new write roots, permission grants, and external integration scopes),
- break-glass escalation and irreversible high-risk actions,
- autonomy-mode suspension or reduction for emergency containment,
- constitutional charter overrides and protected-governance edits,
- compliance/legal interpretation where policy cannot decide deterministically.

Routine execution ownership:

- Agents own planning, implementation, verification, and continuity updates within approved boundaries, authority surfaces, and objective contracts.
- Humans supervise through policy and evidence, not by micromanaging every step.

## 10. Objective Contract Model (Required)

To eliminate ambiguity about what Harmony should do in a target filesystem, Harmony adopts a two-artifact objective contract:

1. Human-readable objective brief: `/OBJECTIVE.md` (workspace root, outside `/.harmony/`).
2. Machine-readable intent contract: `/.harmony/cognition/runtime/context/intent.contract.yml` (must conform to `/.harmony/engine/runtime/spec/intent-contract-v1.schema.json`).

Rules:

- Autonomous execution with material side effects MUST bind `intent_ref.id` and `intent_ref.version` to the active intent contract.
- Autonomous material runs MUST use an approved, effective intent-contract version.
- If objective artifacts are missing or invalid, Harmony MUST fail closed for material autonomy and remain limited to plan/draft/read-only operations.
- Objective changes MUST version the intent contract and record rationale in continuity/decision artifacts.
- If `/OBJECTIVE.md` and `intent.contract.yml` diverge, runtime enforcement MUST treat `intent.contract.yml` as authoritative and require reconciliation evidence in continuity/decision artifacts.
- Intent-contract evaluation for autonomous material runs MUST be coupled with delegation/authority boundary routing (`allow`, `escalate`, `block`); intent binding MUST NOT bypass boundary controls.

Rationale:

- `OBJECTIVE.md` keeps project intent with the host repository.
- The intent contract gives the runtime a deterministic, machine-verifiable objective source.

## 11. Lifecycle Strategy

Harmony operates as a closed loop:

- **PLAN:** validate direction and constraints before implementation.
- **SHIP:** execute quickly through intent-bound, bounded autonomy and policy gates, failing closed under policy uncertainty.
- **LEARN:** persist evidence, outcomes, and lessons to improve the next loop and inform objective/intent updates for the next PLAN cycle.

Each loop should produce:

- explicit intent and scope,
- execution evidence, assurance outcomes, and rollback/recovery evidence,
- continuity artifacts for follow-on work.

## 12. Domain Architecture

Current domain structure is accepted as charter-aligned with no additions/subtractions required.

Canonical machine-readable authority for domain-profile classification is `/.harmony/cognition/governance/domain-profiles.yml`.

Special-profile domains MUST NOT be force-fit into bounded `runtime/governance/practices` surfaces unless their profile classification changes through a governed contract update.

Bounded-surfaces domains:

- `agency`
- `capabilities`
- `cognition`
- `orchestration`
- `scaffolding`
- `assurance`
- `engine`

Special-profile domains:

- `continuity` (`state-tracking`)
- `ideation` (`human-led`)
- `output` (`artifact-sink`)

## 13. Surface Model

Current surface model is accepted and remains normative:

- `runtime/`: executable/discoverable runtime artifacts and runtime contracts.
- `governance/`: normative policy and contract authority.
- `practices/`: operating standards and runbooks.
- `_meta/`: non-normative architecture/reference documentation.
- `_ops/`: operational scripts and mutable state; never a parallel runtime authority.

`governance/` is the sole normative policy authority for its domain; `practices/`, `_meta/`, and `_ops/` MUST NOT override governance contracts.

Discovery metadata (`manifest.yml`, `registry.yml`, and equivalent indexes) MUST resolve to canonical runtime surfaces and MUST NOT route canonical runtime behavior through `_ops/`.

Root-level framing artifacts in `/.harmony/` (for example `START.md`, `scope.md`, `conventions.md`, this charter) define cross-domain orientation and constraints, but do not replace domain runtime/governance/practices boundaries.

## 14. Scope and Non-Goals

In scope:

- governed engineering operations inside the managed filesystem boundary,
- autonomous orchestration with policy and assurance controls,
- evidence-backed change, continuity, and learning.

Out of scope:

- replacing application/product architecture decisions by fiat,
- unconstrained autonomous access to human-led zones,
- ungoverned side effects outside the managed filesystem boundary, except explicitly authorized integrations under policy and boundary controls,
- silent policy bypasses or ungated destructive operations.

## 15. Success Signals

Harmony is successful when:

- autonomous runs are bound to valid objective intent contracts,
- policy/assurance decisions are deterministic and auditable,
- material autonomous runs fail closed on missing or invalid intent, boundary, or policy evidence,
- rollback/recovery paths exist for material changes,
- safety, security, and privacy posture is maintained or improved across release cycles,
- continuity memory remains reusable across sessions and managed work contexts without loss of audit traceability,
- delivery speed increases without increased governance drift,
- portability is preserved across repositories, OSes, and toolchains.

## 16. Change Control

Charter changes require:

- explicit rationale and impact statement,
- consistency with existing constitutional and governance contracts,
- same-change updates to affected references where needed,
- PR-based review and standard assurance gates,
- ADR or decision-record linkage for material charter framing changes,
- same-change update of charter metadata (`effective_date` and charter version marker if present),
- append-only continuity evidence linkage for approved exceptions.

This charter does not override the protected change-control rules for `/.harmony/cognition/governance/principles/principles.md`.

## 17. Normative References

Canonical machine-readable and governance references for this charter include:

- `/.harmony/cognition/governance/domain-profiles.yml` (domain profile classification authority),
- `/.harmony/engine/runtime/spec/intent-contract-v1.schema.json` (intent contract schema authority),
- `/.harmony/agency/governance/delegation-boundaries-v1.yml` and `/.harmony/agency/governance/delegation-boundaries-v1.schema.json` (boundary-routing authority),
- `/.harmony/cognition/_meta/architecture/specification.md` (cross-subsystem specification authority),
- `/.harmony/cognition/_meta/architecture/runtime-vs-ops-contract.md` (runtime vs `_ops/` placement authority),
- `/.harmony/cognition/governance/principles/principles.md` (protected constitutional principles authority).

## 18. Adoption and Bootstrap Contract

For first-time Harmony adoption in a target filesystem, bootstrap initialization MUST establish the minimum entry artifacts before autonomous material runs:

- root-level `AGENTS.md` rendered from Harmony scaffolding templates,
- `CLAUDE.md` aliasing `AGENTS.md` when safe and non-destructive,
- alignment-check shim (`alignment-check`) for assurance entrypoint parity,
- scoped updates to `.harmony/scope.md` and `.harmony/conventions.md` for local boundaries and standards.

Until bootstrap artifacts are present and valid, Harmony SHOULD limit operation to orientation, planning, and setup guidance, and MUST NOT perform ungated material side effects.
