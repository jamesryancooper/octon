---
title: Cognition Discovery Index Model
description: Canonical discovery architecture for cognition documentation with sidecar section indexes and fail-closed validation.
---

# Cognition Discovery Index Model

This document defines the finalized cognition discovery model for long-term maintainability, scalable AI-agent traversal, and clean ownership boundaries.

## Goal

Preserve single-source canonical documents while enabling precise, low-token, machine-readable discovery.

## Finalized Model

1. Canonical content stays in source markdown files (`README.md`, `implementation-guide.md`, `resources.md`, etc.).
2. Section-level discovery is provided by colocated sidecar indexes (`*.index.yml`) that reference headings in canonical markdown.
3. Directory-level discovery is provided by local `index.yml` files that list canonical docs and sidecar indexes.
4. Runtime indexes (`/.octon/cognition/runtime/**/index.yml`) provide centralized discovery across decisions and migrations.
5. Validators enforce source/heading integrity and block deprecated discovery patterns.

## Applied Surfaces in Cognition

| Surface | Canonical Docs | Sidecar Indexes | Directory Index |
|---|---|---|---|
| `/.octon/cognition/practices/methodology/` | `README.md`, `implementation-guide.md` | `README.index.yml`, `implementation-guide.index.yml` | `index.yml` |
| `/.octon/cognition/_meta/architecture/` | `README.md`, `resources.md` | `README.index.yml`, `resources.index.yml` | `index.yml` |

## Non-Negotiable Invariants

- No surrogate section markdown trees (`sections/`) for discovery.
- Sidecar indexes must point to existing source files and real headings.
- Discovery must resolve through explicit indexes, not implicit directory walking.
- Migration and decision records remain append-only under runtime surfaces.

## Validation Contract

- Structure validation: `/.octon/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
- Skill alignment validation: `/.octon/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh`

These checks fail closed when sidecar contracts drift or deprecated section paths reappear.
