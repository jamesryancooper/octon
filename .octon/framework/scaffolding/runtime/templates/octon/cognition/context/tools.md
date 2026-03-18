---
title: Available Tools
description: Reference of available tools for agents working in this harness
---

# Available Tools

## File Operations

| Tool | Purpose | Notes |
|------|---------|-------|
| `Read` | Read file contents | Supports images |
| `Write` | Create/overwrite files | Use for new files |
| `StrReplace` | Edit files | Requires unique `old_string` |
| `Delete` | Remove files | Fails gracefully |

## Search

| Tool | Purpose | When to Use |
|------|---------|-------------|
| `Grep` | Regex search | Exact text, symbols |
| `Glob` | Find by pattern | File names |
| `SemanticSearch` | Find by meaning | "How does X work?" |

## Execution

| Tool | Purpose | Notes |
|------|---------|-------|
| `Shell` | Run commands | Sandboxed; avoid `cat`, `grep`, `find` |

## Tool Selection

| Task | Use |
|------|-----|
| Find exact text | `Grep` |
| Find files by name | `Glob` |
| Understand code flow | `SemanticSearch` |
| Read file contents | `Read` (not `cat`) |
| Edit existing file | `StrReplace` (not `sed`) |
| Create new file | `Write` |

## Common Mistakes

- Using `cat`/`head`/`tail` instead of `Read`
- Using `grep`/`find` instead of `Grep`/`Glob`
- Using `sed`/`awk` instead of `StrReplace`
- Running `echo` to communicate (use response text)

