---
title: "ADR-025: Scaffolding Bounded Surfaces Clean-Break Migration"
description: Apply bounded surface separation to scaffolding by splitting runtime artifacts, governance patterns, and operating practices into canonical surfaces.
status: accepted
date: 2026-02-20
---

# ADR-025: Scaffolding Bounded Surfaces Clean-Break Migration

## Context

Scaffolding mixed runtime templates/scripts (`templates/`, `_ops/scripts/`),
operating prompts/examples (`prompts/`, `examples/`), and governance patterns
(`patterns/`) at root-level paths.

This blurred domain ownership and made clean enforcement difficult for both
humans and automated checks.

The bounded-surfaces contract from ADR-021 requires explicit runtime,
governance, and practices separation where those concerns are materially
distinct.

## Decision

Apply bounded-surfaces to `/.octon/scaffolding/` as a clean-break migration.

Canonical surfaces:

- runtime artifacts: `/.octon/scaffolding/runtime/`
- governance contracts: `/.octon/scaffolding/governance/`
- operating standards: `/.octon/scaffolding/practices/`

Legacy root paths removed in the same migration:

- `/.octon/scaffolding/templates/`
- `/.octon/scaffolding/_ops/scripts/`
- `/.octon/scaffolding/prompts/`
- `/.octon/scaffolding/examples/`
- `/.octon/scaffolding/patterns/`

## Benefits

1. Clarifies scaffolding ownership boundaries between executable assets,
   normative contracts, and operating standards.
2. Makes bootstrap/runtime entrypoints explicit under a single runtime surface.
3. Makes policy-like scaffolding patterns auditable under governance.
4. Reduces migration ambiguity and enables deterministic path validation in CI.
5. Improves agent correctness by eliminating mixed-purpose scaffolding roots.

## Risks

1. High-reference path migration can leave stale references in low-visibility
   docs, templates, or skill metadata.
2. Moving runtime scripts can break path-depth assumptions and bootstrap flows.
3. Template internals may drift if generated-harness paths are not migrated with
   the root scaffolding domain.

## Mitigations

1. Execute one-shot clean-break updates across docs, workflows, skills, command
   docs, and template manifests in the same change set.
2. Update bootstrap scripts to derive `OCTON_DIR` from the new path depth and
   validate behavior via dry-run execution.
3. Update harness validators to require canonical scaffolding surfaces and fail
   closed when legacy paths reappear.
4. Update migration banlist and bounded-surface contract to codify removed paths
   and prevent regression.

## Consequences

1. Active scaffolding references must resolve through `runtime/`, `governance/`,
   or `practices/` surfaces only.
2. Legacy scaffolding root paths are blocked by validator checks and banlist
   policy.
3. Future domain migrations can reuse this contract shape and clean-break
   verification pattern.
