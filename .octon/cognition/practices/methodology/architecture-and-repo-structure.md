---
title: Architecture and Repository Structure
description: Architecture orientation for Octon methodology with provider-agnostic policy and canonical references.
owner: "cognition-owner"
audience: internal
scope: methodology-governance
last_reviewed: 2026-03-05
canonical_links:
  - "/AGENTS.md"
  - "/.octon/agency/governance/CONSTITUTION.md"
  - "/.octon/agency/governance/DELEGATION.md"
  - "/.octon/agency/governance/MEMORY.md"
  - "/.octon/cognition/practices/methodology/authority-crosswalk.md"
---

# Architecture and Repository Structure

This file is a methodology-facing architecture synopsis. Canonical architecture authority remains under `/.octon/cognition/_meta/architecture/`.

## Canonical Sources

- `/.octon/cognition/_meta/architecture/overview.md`
- `/.octon/cognition/_meta/architecture/monorepo-layout.md`
- `/.octon/cognition/_meta/architecture/repository-blueprint.md`
- `/.octon/cognition/_meta/architecture/runtime-architecture.md`
- `/.octon/cognition/_meta/architecture/runtime-policy.md`
- `/.octon/cognition/_meta/architecture/contracts-registry.md`
- `/.octon/cognition/_meta/architecture/layers.md`
- `/.octon/cognition/_meta/architecture/slices-vs-layers.md`
- `/.octon/cognition/_meta/architecture/governance-model.md`

## Structural Baseline

- Agent-first, system-governed modular monolith.
- Vertical feature slices with explicit ports/adapters boundaries.
- Thin control plane for policy, observability, contracts, and rollout controls.
- Clear separation between runtime surfaces (apps/agents/runtimes) and import surfaces (packages/contracts).

## Flag and Runtime Policy

- Flag resolution must be deterministic, fail-closed, and auditable.
- Evaluate risky behavior server-side and avoid re-implementing policy across runtimes.
- Provider-specific integrations are implementation details, not normative methodology requirements.

## Scaling Guidance (Solo to Small Team)

- Keep WIP small and changes reversible.
- Require explicit review ownership for elevated-risk surfaces.
- Maintain manual promotion authority with rollback-ready posture for high-risk releases.

For implementation details and examples, see stack profiles under `/.octon/scaffolding/practices/examples/stack-profiles/` as non-normative guidance.
