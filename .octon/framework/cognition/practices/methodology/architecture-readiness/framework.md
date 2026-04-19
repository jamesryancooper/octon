---
title: Architecture Readiness Framework
description: Scoring dimensions, hard gates, failure modes, and remediation expectations for Octon architecture-readiness audits.
owner: "cognition-owner"
audience: internal
scope: methodology-governance
last_reviewed: 2026-03-11
canonical_links:
  - "/AGENTS.md"
  - "/.octon/framework/execution-roles/governance/CONSTITUTION.md"
  - "/.octon/framework/execution-roles/governance/DELEGATION.md"
  - "/.octon/framework/execution-roles/governance/MEMORY.md"
  - "/.octon/framework/cognition/practices/methodology/authority-crosswalk.md"
  - "/.octon/framework/cognition/practices/methodology/audits/findings-contract.md"
  - "/.octon/framework/cognition/governance/domain-profiles.yml"
---

# Architecture Readiness Framework

## Scoring Rubric

- `0` - absent
- `1` - implicit or informal
- `2` - partial, inconsistent, or bypassable
- `3` - explicit, enforced, observable, and testable

## Hard Gates

Any score below `2` in these dimensions blocks an `implementation-ready`
verdict:

- objective integrity
- authority and delegation
- policy and admission control
- state, evidence, and auditability
- recovery, reversibility, and continuity
- control-plane vs execution-plane separation

## Evaluation Dimensions

1. Objective integrity
2. Authority and delegation
3. Policy and admission control
4. Planning and bounded execution
5. Coordination and concurrency control
6. Runtime and execution integrity
7. State model, evidence, and auditability
8. Observability and assurance
9. Recovery, reversibility, and continuity
10. Domain and boundary integrity
11. AI-agent safety architecture
12. Classical software architecture quality
13. Control-plane vs execution-plane separation

## Mandatory Failure-Mode Analysis

Every run must explicitly assess:

- objective drift
- policy bypass
- authority inflation
- exception creep
- hidden side effects
- non-reproducible execution
- duplicate or conflicting runs
- zombie execution
- audit theater
- assurance capture
- stale or unsafe learning
- plane collapse

## Target Applicability Rules

- `whole-harness` runs evaluate the full Octon control plane and may include
  optional cross-subsystem coherence evidence.
- `bounded-domain` runs evaluate one top-level bounded-surface domain and may
  include optional domain-architecture evidence.
- non-target profiles stop at applicability classification and return
  `not-applicable`.

## Required Remediation Shape

Every critical or high gap must name:

- the exact durable artifact to create or update
- the artifact class (methodology doc, skill/workflow contract, policy doc,
  runbook, test, or ADR pattern)
- the purpose of that artifact
- the acceptance criteria for closing the gap

## Composition With Surface Architecture Analysis

When a readiness finding cannot be closed safely without clarifying the
authority model of one durable surface unit, the follow-up analysis should use
surface-architecture doctrine and classification vocabulary:

- `contract-first`
- `mixed`
- `markdown-first`
- `human-led/non-executable`

That follow-up must preserve the readiness framework's scope boundaries:

- readiness remains the verdict owner
- surface analysis clarifies one unit's authority, validator, and documentation
  shape
- remediation still names exact durable artifacts and objective acceptance
  criteria

## Output Contract

The markdown report must include:

1. executive verdict
2. weighted score summary
3. critical architectural gaps
4. high and medium gaps
5. failure-mode assessment
6. design-smell assessment
7. control-plane vs execution-plane assessment
8. file-level remediation plan
9. promotion recommendation
10. final concise judgment
