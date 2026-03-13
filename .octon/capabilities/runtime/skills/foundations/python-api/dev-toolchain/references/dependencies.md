---
title: Dependencies Reference
description: External dependencies for python-dev-toolchain.
---

# Dependencies Reference

## Required External Tools

| Tool | Purpose | Verification |
|---|---|---|
| `python3` | Runtime for lint/type/test tooling | `python3 --version` |
| `uv` | Dependency and virtual environment management | `uv --version` |

## Optional Dependencies

| Dependency | Purpose | When Needed |
|---|---|---|
| `just` | Task runner wiring in generated toolchain | If project uses `justfile` tasks |
| Docker / Docker Compose | Local integration targets for `check` orchestration | If service-backed checks are configured |

## Fallback Behavior

- If required tools are unavailable, stop and report prerequisite setup.
- If optional tools are unavailable, generate configuration and include manual execution guidance.
