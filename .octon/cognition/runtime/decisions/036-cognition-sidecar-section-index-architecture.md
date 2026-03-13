---
id: 036
title: "ADR-036: Cognition Sidecar Section Index Architecture"
status: accepted
date: 2026-02-21
---

# ADR-036: Cognition Sidecar Section Index Architecture

## Context

The previous `sections/` directories improved discoverability for heavyweight
cognition docs but introduced duplicate surrogate artifacts that can drift from
canonical documents.

## Decision

Adopt sidecar section indexes colocated with canonical documents:

1. Replace `sections/` directory artifacts with `*.index.yml` sidecars.
2. Keep canonical content in existing source docs (`README.md`,
   `implementation-guide.md`, `resources.md`, etc.).
3. Require validators to enforce sidecar index contracts and heading integrity.
4. Remove legacy `sections/` directories in the same change set.

## Consequences

### Positive

- Stronger canonicality: no duplicate section markdown artifacts.
- Better maintainability: one source doc + one index sidecar.
- Cleaner machine discoverability and easier fail-closed validation.

### Tradeoffs

- Sidecar indexes must be maintained when headings change.
- Validators become stricter and require index hygiene.

## Evidence

- Migration plan: `/.octon/cognition/runtime/migrations/2026-02-21-cognition-sidecar-section-indexes/plan.md`
- Migration bundle: `/.octon/output/reports/migrations/2026-02-21-cognition-sidecar-section-indexes/`
