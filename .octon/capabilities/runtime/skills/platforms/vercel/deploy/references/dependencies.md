---
title: Dependencies Reference
description: External dependencies for vercel-deploy.
---

# Dependencies Reference

## Required External Tools

| Tool | Purpose | Verification |
|---|---|---|
| `vercel` CLI | Create and manage deployments | `vercel --version` |

## Required External Services

| Service | Purpose | Verification |
|---|---|---|
| Vercel account/project access | Deployment target and metadata retrieval | `vercel whoami` |

## Fallback Behavior

- If CLI is unavailable or unauthenticated, stop and report setup steps.
- If deployment target is unreachable, stop and report actionable diagnostics.
