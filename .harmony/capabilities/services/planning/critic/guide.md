# Critic Guide

This service evaluates whether a plan is structurally sound and execution-ready.

Use it before scheduling or execution to catch:

- missing or duplicate step IDs
- dangling dependencies
- cyclic dependency graphs
- missing or empty step action metadata

Modes:

- `validate` (default)
  - strict validation, fail-closed on structural defects
- `score`
  - advisory scoring, never fail-closed

Output is deterministic for a given payload.
