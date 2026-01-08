---
title: Glossary
description: Domain-specific terminology for the workspace system.
---

# Glossary

Terms used consistently throughout workspace documentation. Use these terms exactly as defined.

> **See also:** `docs/GLOSSARY.md` for repo-wide terminology including task status values, workflow states, and roles.

| Term | Definition |
|------|------------|
| Harness | The `.workspace` support structure that guides agent work. |
| Boot sequence | Steps to orient and begin work (defined in `START.md`). |
| Cold start | First session without prior context from `progress/`. |
| Token budget | Maximum tokens for agent-facing content (~2,000 target, ~5,000 max). |
| Cursor command | User entry point in `.cursor/commands/`, triggered by `/command-name`. |
| Workspace command | Atomic operation in `.workspace/commands/`. |
| Workspace workflow | Multi-step procedure in `.workspace/workflows/`. |
| Prompt | Task template in `.workspace/prompts/` requiring judgment. |
| Agent-ignored | Dot-prefixed directories that agents MUST NOT access autonomously. |
| Never-access | `.humans/` and `.archive/`—agents must not access under any circumstances. |
| Human-led | `.scratch/` and `.inbox/`—agents may access only when human explicitly directs to specific files. |
| Scratch | Persistent human thinking/research space (`.scratch/`); content may remain indefinitely. |
| Inbox | Temporary staging for external imports (`.inbox/`); content should eventually move out. |
| Promote | Workflow to distill mature scratch content into agent-facing artifacts (`workflows/promote-from-scratch.md`). |

