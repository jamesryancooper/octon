---
title: Dependencies Reference
description: External dependencies for python-test-harness.
---

# Dependencies Reference

## Required External Tools

| Tool | Purpose | Verification |
|---|---|---|
| `python3` | Target runtime for generated tests | `python3 --version` |
| `uv` | Test dependency management and execution workflow | `uv --version` |

## Optional Dependencies

| Dependency | Purpose | When Needed |
|---|---|---|
| Docker / Docker Compose | Integration test service orchestration | If integration fixtures target local services |

## Fallback Behavior

- If required tools are unavailable, stop and report missing prerequisites.
- If integration dependencies are unavailable, generate integration scaffolding and mark execution as deferred.
