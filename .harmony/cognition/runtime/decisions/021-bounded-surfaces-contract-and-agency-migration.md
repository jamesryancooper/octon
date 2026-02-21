---
title: "ADR-021: Bounded Surfaces Contract and Agency Clean-Break Migration"
description: Adopt bounded surface separation for runtime artifacts, governance contracts, and practices; apply clean-break migration to the agency subsystem first.
status: accepted
date: 2026-02-20
---

# ADR-021: Bounded Surfaces Contract and Agency Clean-Break Migration

## Context

Agency mixed runtime actor artifacts and cross-agent governance contracts at the same root level. This increased structural ambiguity and made enforcement less explicit across docs, validation scripts, and discovery metadata.

The repository needs a reusable architecture contract for separating:

- runtime artifacts,
- governance contracts,
- operating standards.

## Decision

Adopt the bounded-surfaces contract for applicable subsystems and apply it first to `/.harmony/agency/` as a clean-break migration.

Agency canonical surfaces:

- runtime artifacts: `/.harmony/agency/actors/`
- governance contracts: `/.harmony/agency/governance/`
- operating standards: `/.harmony/agency/practices/`

Legacy root-level actor and governance paths are removed in the same migration.

## Benefits

1. Improves boundary clarity by making runtime and policy artifacts structurally explicit.
2. Improves correctness and auditability through single canonical paths.
3. Enables deterministic CI enforcement for legacy-path regression prevention.
4. Reduces ambiguity for AI agents during routing and contract loading.

## Risks

1. Migration drift across docs/scripts may produce broken references.
2. Over-generalizing the pattern may add structure where it does not improve semantics.
3. Historical references in append-only artifacts may appear inconsistent with new paths.

## Mitigations

1. Enforce clean-break migration with one-shot reference updates and CI gate updates in the same change set.
2. Apply bounded-surfaces pattern only where runtime/governance/practice boundaries are materially useful.
3. Keep append-only history intact and scope enforcement to active contract surfaces.

## Consequences

1. Any future subsystem rollout must use explicit migration plans, banlist updates, and verification evidence.
2. Agency validators and harness-structure validators become authoritative for preventing legacy path reintroduction.
3. Repository-level architecture docs now include a formal bounded-surfaces contract.

