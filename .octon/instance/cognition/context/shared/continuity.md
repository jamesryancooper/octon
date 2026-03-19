---
title: Continuity Artifact Signals
description: Optional continuity artifact hints for append-only handling in refactor and migration workflows.
---

# Continuity Artifact Signals

This document provides optional continuity artifact hints used by planning and refactor workflows.
It supplements built-in pattern matching when a repository needs local overrides.

## Purpose

- Mark append-only history artifacts that must never be rewritten.
- Help workflows classify continuity files consistently.
- Provide one local extension point for continuity detection logic.

## Suggested Signals

- `**//.octon/state/continuity/repo/log.md`
- `**//.octon/instance/cognition/context/shared/decisions.md`
- `**/instance/cognition/decisions/*.md`
- `**/cognition/runtime/migrations/*/plan.md`
- `**//.octon/state/evidence/migration/*/evidence.md`

## Mutability

- This file is mutable.
- `runtime/context/decisions.md` is generated from ADR metadata and should not be manually edited.
- Other files matched by these signals are generally append-only and should be updated by adding new entries, not rewriting history.
