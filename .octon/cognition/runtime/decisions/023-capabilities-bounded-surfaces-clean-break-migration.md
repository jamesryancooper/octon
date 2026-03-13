---
title: "ADR-023: Capabilities Bounded Surfaces Clean-Break Migration"
description: Apply bounded surface separation to capabilities by splitting runtime artifacts, governance contracts, and operating practices into canonical surfaces.
status: accepted
date: 2026-02-20
---

# ADR-023: Capabilities Bounded Surfaces Clean-Break Migration

## Context

Capabilities mixed executable runtime artifacts (`commands/`, `skills/`, `tools/`, `services/`) with governance contracts (`_ops/policy/`) and service operating conventions at root-level locations. This blurred authority boundaries and made static enforcement less deterministic.

The bounded-surfaces contract adopted in ADR-021 requires canonical separation of runtime artifacts, governance contracts, and practices where materially applicable.

## Decision

Apply bounded-surfaces to `/.octon/capabilities/` as a clean-break migration.

Canonical surfaces:

- runtime artifacts: `/.octon/capabilities/runtime/`
- governance contracts: `/.octon/capabilities/governance/`
- operating standards: `/.octon/capabilities/practices/`

Legacy root paths are removed in the same migration:

- `/.octon/capabilities/commands/`
- `/.octon/capabilities/skills/`
- `/.octon/capabilities/tools/`
- `/.octon/capabilities/services/`
- `/.octon/capabilities/_ops/policy/`

## Benefits

1. Makes capability runtime routing unambiguous through a single runtime surface.
2. Makes policy governance explicit and auditable as a dedicated surface.
3. Makes service operating conventions explicit under a practices surface.
4. Improves CI enforceability for deprecated path regression prevention.
5. Reduces path ambiguity for humans and AI agents.

## Risks

1. Broad path migration can miss low-visibility references.
2. Runtime validation and policy scripts may fail if path-depth assumptions are stale.
3. Generated or state artifacts may retain historical legacy paths and create false positives.

## Mitigations

1. One-shot clean-break updates paths, validators, manifests, and CI checks together.
2. Validator scripts are updated to fail closed on deprecated capability path reintroduction.
3. Static migration sweeps exclude append-only/state artifact zones while enforcing active surfaces.
4. Runtime and governance checks are rerun in strict mode before merge.

## Consequences

1. Capability references must resolve through `runtime/`, `governance/`, or `practices/` surfaces.
2. Legacy capability root runtime/policy paths cannot be reintroduced without failing CI gates.
3. Future bounded-surface rollouts continue using clean-break plans, banlist updates, and evidence artifacts.
