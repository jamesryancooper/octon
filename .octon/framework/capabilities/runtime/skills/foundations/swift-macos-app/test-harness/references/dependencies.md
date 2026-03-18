---
title: Dependencies Reference
description: External dependencies for swift-test-harness.
---

# Dependencies Reference

## Required External Tools

| Tool | Purpose | Verification |
|---|---|---|
| `swift` | Test harness generation aligned to Swift toolchain | `swift --version` |

## Optional Dependencies

| Dependency | Purpose | When Needed |
|---|---|---|
| `xcodebuild` | Extended macOS test execution and CI parity | If Xcode project test targets are present |

## Fallback Behavior

- If required tools are unavailable, stop and report prerequisites.
- If optional tools are unavailable, generate test scaffolding and note deferred execution checks.
