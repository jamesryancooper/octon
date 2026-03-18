---
name: extract-blueprint
title: Extract Minimal Implementation Architecture
description: Execute prompt 08 and persist the implementer blueprint.
---

# Step 9: Extract Minimal Implementation Architecture

## Input

- stabilized target proposal state
- canonical stage prompt for blueprint extraction

## Purpose

Turn the stabilized package into a concise implementation blueprint that a team
can use to start building immediately.

## Actions

1. Load the canonical blueprint-extraction stage prompt.
2. Substitute `<PACKAGE_PATH>` with the target proposal path.
3. Execute the prompt against the stabilized package.
4. Persist the blueprint at:
   - `bundle/reports/08-minimal-implementation-architecture-blueprint.md`

## Output

- `bundle/reports/08-minimal-implementation-architecture-blueprint.md`

## Proceed When

- [ ] Blueprint exists
- [ ] Minimal production architecture is explicit
- [ ] Core boundaries, state, and invariants are covered
- [ ] Residual ambiguities are called out separately
