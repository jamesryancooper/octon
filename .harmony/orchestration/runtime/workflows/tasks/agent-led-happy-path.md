---
name: agent-led-happy-path
title: "Task: Agent-Led Happy Path"
description: Canonical onboarding flow for agent-led execution from bootstrap through continuity.
access: human
version: "1.0.0"
---

# Task: Agent-Led Happy Path

## Context

Use this as the canonical onboarding path for agent-led work in this repository.
Legacy onboarding variants are hard-deprecated for new runs.

## Failure Conditions

- Canonical ingress files are missing -> STOP, run the bootstrap path before continuing
- No unblocked task can be identified -> STOP, resolve continuity state before execution
- Required alignment or surface-specific validators fail -> STOP, address the failing checks before handoff

## Flow

1. Bootstrap
   - Read `AGENTS.md`, `/.harmony/OBJECTIVE.md`, `.harmony/START.md`, `.harmony/scope.md`, and `.harmony/conventions.md`.
   - Confirm canonical cross-subsystem rules in `.harmony/cognition/_meta/architecture/specification.md`.
2. Execute
   - Read `.harmony/continuity/log.md` and `.harmony/continuity/tasks.json`.
   - Pick the highest-priority unblocked task and execute a bounded plan.
3. Assure
   - Run `bash .harmony/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness`.
   - Run scope-specific validators required by the changed surfaces.
4. Continuity
   - Append session results in `.harmony/continuity/log.md`.
   - Update `.harmony/continuity/tasks.json` status.
   - Complete `.harmony/assurance/practices/session-exit.md` before handoff.

## Required Outcome

- One execution pass from bootstrap -> execute -> assure -> continuity with
  fail-closed validation and durable continuity updates.
