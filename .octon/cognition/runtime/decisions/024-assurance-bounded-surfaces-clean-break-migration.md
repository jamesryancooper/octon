---
title: "ADR-024: Assurance Bounded Surfaces Clean-Break Migration"
description: Apply bounded surface separation to assurance by splitting runtime artifacts, governance contracts, and operating practices into canonical surfaces.
status: accepted
date: 2026-02-20
---

# ADR-024: Assurance Bounded Surfaces Clean-Break Migration

## Context

Assurance mixed governance contracts (`CHARTER.md`, `DOCTRINE.md`, `CHANGELOG.md`, `standards/`), runtime execution artifacts (`_ops/scripts/`, `_ops/state/`), trust artifact runtime surfaces (`trust/`), and operating gates (`complete.md`, `session-exit.md`) at root-level locations.

This blurred authority boundaries and reduced deterministic enforcement for humans and AI agents.

The bounded-surfaces contract adopted in ADR-021 requires canonical separation of runtime artifacts, governance contracts, and practices where materially applicable.

## Decision

Apply bounded-surfaces to `/.octon/assurance/` as a clean-break migration.

Canonical surfaces:

- runtime artifacts: `/.octon/assurance/runtime/`
- governance contracts: `/.octon/assurance/governance/`
- operating standards: `/.octon/assurance/practices/`

Legacy root paths are removed in the same migration:

- `/.octon/assurance/CHARTER.md`
- `/.octon/assurance/DOCTRINE.md`
- `/.octon/assurance/CHANGELOG.md`
- `/.octon/assurance/complete.md`
- `/.octon/assurance/session-exit.md`
- `/.octon/assurance/standards/`
- `/.octon/assurance/trust/`
- `/.octon/assurance/_ops/scripts/`
- `/.octon/assurance/_ops/state/`

## Benefits

1. Makes assurance authority boundaries explicit between runtime execution, governance policy, and operating standards.
2. Makes assurance policy contracts easier to audit and enforce as a dedicated governance surface.
3. Makes completion and session-exit gates explicit operational practices rather than root-level mixed artifacts.
4. Improves CI enforceability by allowing deterministic banlist checks against removed assurance root paths.
5. Reduces path ambiguity for humans and AI agents consuming assurance contracts.

## Risks

1. Broad path migration can miss low-visibility references in workflows, templates, and runtime defaults.
2. Assurance engine scripts may fail if path-depth assumptions are stale after relocation.
3. Historical references in append-only or archival artifacts can create false positives during static sweeps.

## Mitigations

1. One-shot clean-break updates assurance paths, runtime defaults, templates, and CI checks together.
2. Runtime entrypoint scripts are updated to derive repository roots correctly from the new runtime path depth.
3. Harness and alignment validators are updated to fail closed on assurance legacy path reintroduction.
4. Static migration verification scopes out append-only history and archival zones while enforcing active contract surfaces.

## Consequences

1. Assurance references must resolve through `runtime/`, `governance/`, or `practices/` surfaces.
2. Legacy assurance root paths cannot be reintroduced without failing updated validation gates.
3. Future bounded-surface migrations continue using clean-break plans, banlist updates, ADRs, and evidence artifacts.
