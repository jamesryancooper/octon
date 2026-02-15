---
title: Dependencies Reference
description: External dependencies for python-infra-manifest.
---

# Dependencies Reference

## Required External Tools

| Tool | Purpose | Verification |
|---|---|---|
| `python3` | Runtime used by generated project conventions | `python3 --version` |
| `uv` | Dependency workflow used in generated docs/examples | `uv --version` |

## Optional Dependencies

| Dependency | Purpose | When Needed |
|---|---|---|
| Docker / Docker Compose | Local infrastructure manifests and smoke checks | If local infra services are declared |

## Fallback Behavior

- If required tools are unavailable, stop and report missing prerequisites.
- If optional infrastructure tooling is unavailable, generate manifests and mark runtime validation as pending.
