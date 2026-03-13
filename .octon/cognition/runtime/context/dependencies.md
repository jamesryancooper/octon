---
title: Dependencies
description: External systems and references this harness interacts with.
---

# Dependencies

External systems, APIs, or packages this harness interacts with.

## External Documentation

| Resource | Purpose | Location |
|----------|---------|----------|
| Cursor Commands Docs | How Cursor commands work | [cursor.com/docs/agent/chat/commands](https://cursor.com/docs/agent/chat/commands) |
| Cursor Rules Docs | How rules are applied | [cursor.com/docs/context/rules](https://cursor.com/docs/context/rules) |

## Internal References

| Reference | Purpose | Location |
|-----------|---------|----------|
| Canonical Harness Docs | Authoritative harness definition | `.octon/cognition/_meta/architecture/` |
| Harness Templates | Boilerplate for new harnesses | `.octon/scaffolding/runtime/templates/octon/` |
| Cursor Commands | IDE integration entry points | `.cursor/commands/` |
| Engine Governance Rules | Canonical cross-harness rule policy packs | `.octon/engine/governance/rules/` |
| Harness Rule Adapters | Harness-specific symlink entry points | `.cursor/rules/`, `.codex/rules/` |

## Packages

None required. This harness is documentation-only.
