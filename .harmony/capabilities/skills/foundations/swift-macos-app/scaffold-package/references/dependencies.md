---
title: Dependencies Reference
description: External dependencies for swift-scaffold-package.
---

# Dependencies Reference

## Required External Tools

| Tool | Purpose | Verification |
|---|---|---|
| `swift` | Swift package scaffolding and build metadata defaults | `swift --version` |

## Optional Dependencies

| Dependency | Purpose | When Needed |
|---|---|---|
| Xcode command line tools | Expanded local build/test behavior | If local compile/test checks are run immediately |

## Fallback Behavior

- If `swift` is unavailable, stop and report required toolchain setup.
- If optional tooling is unavailable, scaffold files and mark local verification as deferred.
