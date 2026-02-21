---
title: "ADR-022: Orchestration Bounded Surfaces Clean-Break Migration"
description: Apply bounded surface separation to orchestration by splitting runtime artifacts, governance contracts, and operating practices into canonical surfaces.
status: accepted
date: 2026-02-20
---

# ADR-022: Orchestration Bounded Surfaces Clean-Break Migration

## Context

Orchestration mixed runtime artifacts (`workflows/`, `missions/`) with governance artifacts (`incidents.md`, compatibility redirect) at the same root level. This blurred ownership and made policy enforcement less explicit.

The bounded-surfaces contract adopted in ADR-021 requires canonical separation of runtime artifacts, governance contracts, and practices where materially applicable.

## Decision

Apply bounded-surfaces to `/.harmony/orchestration/` as a clean-break migration.

Canonical surfaces:

- runtime artifacts: `/.harmony/orchestration/runtime/`
- governance contracts: `/.harmony/orchestration/governance/`
- operating standards: `/.harmony/orchestration/practices/`

Legacy root paths are removed in the same migration:

- `/.harmony/orchestration/workflows/`
- `/.harmony/orchestration/missions/`
- `/.harmony/orchestration/incidents.md`
- `/.harmony/orchestration/incident-response.md`

## Benefits

1. Makes orchestration runtime routing unambiguous by using one runtime surface.
2. Makes incident governance explicit and auditable as its own surface.
3. Improves CI enforceability for legacy-path regression prevention.
4. Aligns scaffolding templates and runtime integrations to one canonical topology.

## Risks

1. Broad path migration can miss low-visibility references.
2. Runtime/tool integrations may break if legacy paths linger.
3. Historical append-only artifacts may still mention previous locations.

## Mitigations

1. One-shot clean-break migration updates paths, validators, templates, and CI checks together.
2. Validators fail closed for deprecated orchestration paths.
3. Historical append-only artifacts are preserved; enforcement is scoped to active contract surfaces.

## Consequences

1. Orchestration references must now resolve through `runtime/`, `governance/`, or `practices/`.
2. Future orchestration changes must avoid reintroducing legacy root paths.
3. Migration governance artifacts (plan, banlist, evidence) are required for this and subsequent bounded-surface rollouts.
