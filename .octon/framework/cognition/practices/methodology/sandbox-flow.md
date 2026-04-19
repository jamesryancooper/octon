---
title: Sandbox Flow
description: Canonical provider-agnostic flow for validating changes in sandbox environments before controlled promotion.
owner: "cognition-owner"
audience: internal
scope: methodology-governance
last_reviewed: 2026-03-05
canonical_links:
  - "/AGENTS.md"
  - "/.octon/framework/execution-roles/governance/CONSTITUTION.md"
  - "/.octon/framework/execution-roles/governance/DELEGATION.md"
  - "/.octon/framework/execution-roles/governance/MEMORY.md"
  - "/.octon/framework/cognition/practices/methodology/authority-crosswalk.md"
---

# Sandbox Flow

Sandbox validation is a pattern across preview/staging environments, CI checks, and runtime non-production targets.

## Required References

Read this alongside:

- `implementation-guide.md`
- `ci-cd-quality-gates.md`
- `reliability-and-ops.md`
- `performance-and-scalability.md`
- `/.octon/framework/cognition/_meta/architecture/overview.md`
- `/.octon/framework/cognition/_meta/architecture/runtime-architecture.md`
- `/.octon/framework/cognition/_meta/architecture/runtime-policy.md`
- `/.octon/framework/cognition/_meta/architecture/tooling-integration.md`
- `/.octon/instance/cognition/context/shared/knowledge/knowledge.md`

This document does not redefine gate policy.

## Baseline Defaults

- Shared starter SLO defaults are canonical in [reliability-and-ops.md#slis-slos-and-error-budgets](./reliability-and-ops.md#slis-slos-and-error-budgets) and apply to sandbox validation.
- Rollback-first policy: restore previous known-good deployment when SLO threat is detected.
- Flag discipline: new behavior defaults OFF until sandbox and early-cohort checks pass.

## Lifecycle (Sandbox View)

1. Spec and planning define required sandbox checks, rollout flags, and observability expectations.
2. Development prepares deterministic tests and evidence for CI and sandbox execution.
3. PR opens and sandbox targets are created (preview/staging/runtime test environment).
4. CI gates run (tests, contracts, security, observability, policy checks).
5. Promotion is allowed only when required gates and ACP receipt outcomes are satisfied.
6. Watch window runs with rollback-ready posture.

ACP receipt outcomes determine runtime promotion authority; humans retain policy authorship, exceptions, and escalation authority.

## Responsibilities

- Humans: scope, policy, exceptions, escalation, and promotion decisions.
- Agents: draft specs/plans/code/tests and assemble auditable evidence.
- CI: enforce required gates and publish immutable run artifacts.

## Knowledge Plane Recording

For each sandbox run, record:

- commit SHA, branch/PR reference, tier, and ACP target
- CI gate outputs and evidence pointers
- sandbox target identifiers/URLs
- trace IDs linking tests and runtime behavior
- flag/config state used during validation
