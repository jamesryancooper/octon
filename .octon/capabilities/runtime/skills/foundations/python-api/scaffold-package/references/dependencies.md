---
title: Dependencies Reference
description: External dependencies for python-scaffold-package.
---

# Dependencies Reference

## Required External Tools

| Tool | Purpose | Verification |
|---|---|---|
| `python3` | Runtime target for scaffolded project defaults | `python3 --version` |
| `uv` | Dependency and environment workflow used by generated template | `uv --version` |

## Optional Dependencies

| Dependency | Purpose | When Needed |
|---|---|---|
| Docker / Docker Compose | Local service stack for generated infra manifests | If infrastructure services are requested |

## Fallback Behavior

- If required tools are unavailable, stop and return setup instructions.
- If optional dependencies are unavailable, generate files but mark local runtime setup as deferred.
