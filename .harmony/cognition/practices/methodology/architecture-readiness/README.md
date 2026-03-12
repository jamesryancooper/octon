---
title: Architecture Readiness Evaluation
description: Clean-break methodology for evaluating Harmony whole-harness and bounded-surface domain architecture readiness.
owner: "cognition-owner"
audience: internal
scope: methodology-governance
last_reviewed: 2026-03-11
canonical_links:
  - "/AGENTS.md"
  - "/.harmony/agency/governance/CONSTITUTION.md"
  - "/.harmony/agency/governance/DELEGATION.md"
  - "/.harmony/agency/governance/MEMORY.md"
  - "/.harmony/cognition/practices/methodology/authority-crosswalk.md"
  - "/.harmony/cognition/practices/methodology/audits/README.md"
  - "/.harmony/cognition/governance/domain-profiles.yml"
  - "/.harmony/cognition/_meta/architecture/bounded-surfaces-contract.md"
---

# Architecture Readiness Evaluation

This methodology defines how Harmony evaluates architecture readiness as a
bounded audit, without force-fitting the framework onto unsupported domain
profiles.

## Supported Targets

- `/.harmony/` as `whole-harness`
- top-level bounded-surface domains as `bounded-domain`:
  - `agency`
  - `capabilities`
  - `cognition`
  - `orchestration`
  - `assurance`
  - `scaffolding`
  - `engine`

## Explicit Non-Targets

- `continuity`
- `ideation`
- `output`
- isolated surface-only paths such as `governance/`, `practices/`, `_meta/`,
  and `_ops/`

Unsupported targets must return `verdict=not-applicable`. They do not receive
forced failing scorecards.

## Composition With Existing Audits

This framework introduces a new primary capability:

- `audit-architecture-readiness`

It may compose with existing audits, but does not replace them:

- `audit-cross-subsystem-coherence` supplements whole-harness runs
- `audit-domain-architecture` supplements bounded-domain runs
- `audit-surface-architecture` supplements unit-level follow-up when a finding
  must be narrowed to one workflow, skill, watcher, automation, contract
  surface, or methodology surface

Existing audit semantics remain unchanged. The architecture-readiness evaluator
owns the final readiness verdict.

## Output Expectations

Every run must emit:

- a markdown findings report
- a bounded-audit evidence bundle
- a machine-readable summary JSON
- stable finding IDs with acceptance criteria

For doctrine and scoring rules, see [framework.md](./framework.md).
