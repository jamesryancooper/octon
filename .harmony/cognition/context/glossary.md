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
| Workspace command | Atomic operation in `.harmony/capabilities/commands/`. |
| Workspace workflow | Multi-step procedure in `.harmony/orchestration/workflows/`. |
| Prompt | Task template in `.harmony/scaffolding/prompts/` requiring judgment. |
| Agent-ignored | Dot-prefixed directories that agents MUST NOT access autonomously. |
| Human-led | Directories (`ideation/projects/`, `ideation/scratchpad/`) agents may access only when human explicitly directs to specific files. |
| Scratchpad | Human-led zone (`ideation/scratchpad/`) for ephemeral content and the early-stage idea funnel. Subdirectories: `inbox/` (staging), `archive/` (deprecated), `brainstorm/` (exploration), `ideas/`, `drafts/`, `daily/`. |
| Project | Human-led exploration in `projects/` that produces workspace artifacts. |
| Brainstorm | Single-file structured exploration in `ideation/scratchpad/brainstorm/` -- filter stage between ideas and projects. |
| The Funnel | Pipeline from ideas to committed work: `ideas/` → `brainstorm/` → `projects/` → `missions/` → `context/`. |
