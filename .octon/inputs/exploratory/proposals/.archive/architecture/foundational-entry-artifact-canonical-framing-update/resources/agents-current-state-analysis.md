# AGENTS Current-State Analysis

_Status: In-review proposal packet artifact_


## Current state

Root `AGENTS.md` and `.octon/AGENTS.md` are thin adapters. They point to canonical internal ingress and require parity / no extra runtime or policy text.

## Strengths

- Very short.
- Correctly points to canonical ingress.
- Explicitly prohibits adapter-added runtime/policy text.

## Weakness

The behavioral contract says "Enable reliable agent execution..." This should become workflow-participation language.

## Recommended action

Change only the behavioral sentence and preserve parity.
