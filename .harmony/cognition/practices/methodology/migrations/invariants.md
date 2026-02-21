---
title: Architectural Invariants for Clean-Break Migrations
description: Repository-level invariants that preserve single-authority clean-break migration outcomes.
---

# Architectural Invariants for Clean-Break

These are repository-level invariants and are expected to remain true over time.

## Invariants (MUST)

1. One obvious way: for any migrated capability, there is exactly one supported entrypoint and one authority.
2. No shadow config: there is one config surface for a concept, with no legacy aliases or parallel keys.
3. No legacy namespaces: the repository must not keep `legacy/`, `deprecated/`, or `old/` implementations as runnable alternatives.
4. No split SSOT: a domain SSOT must live in one place. If moved, the old location must be removed.
5. Contracts are authoritative: schemas, manifests, and interfaces define truth and code conforms.
6. Tests bind behavior: tests must make the single intended path obvious and detect reintroduction of legacy paths.

## Allowed Patterns (MAY)

- Hard breaks with explicit migration notes and clear update instructions for humans.
- One-time data backfills or transformations, provided the old data shape is not retained as an accepted input.

