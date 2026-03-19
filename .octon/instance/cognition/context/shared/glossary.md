---
title: Glossary
description: Domain-specific terminology for the harness system.
---

# Glossary

Terms used consistently throughout harness documentation. Use these terms exactly as defined.

> **See also:** `.octon/instance/cognition/context/shared/glossary-repo.md` for repo-wide terminology including task status values, workflow states, and roles.

| Term | Definition |
|------|------------|
| Harness | The `.octon` support structure that guides agent work. |
| Boot sequence | Steps to orient and begin work (defined in `START.md`). |
| Cold start | First session without prior context from `continuity/`. |
| Token budget | Maximum tokens for agent-facing content (~2,000 target, ~5,000 max). |
| Cursor command | User entry point in `.cursor/commands/`, triggered by `/command-name`. |
| Harness command | Atomic operation in `.octon/framework/capabilities/runtime/commands/`. |
| Harness workflow | Multi-step procedure in `.octon/framework/orchestration/runtime/workflows/`. |
| Prompt | Task template in `.octon/framework/scaffolding/practices/prompts/` requiring judgment. |
| Agent-ignored | Dot-prefixed directories that agents MUST NOT access autonomously. |
| Human-led | Directories (`ideation/projects/`, `ideation/scratchpad/`) agents may access only when human explicitly directs to specific files. |
| Scratchpad | Human-led zone (`ideation/scratchpad/`) for ephemeral content and the early-stage idea funnel. Subdirectories: `inbox/` (staging), `archive/` (deprecated), `brainstorm/` (exploration), `ideas/`, `drafts/`, `daily/`. |
| Project | Human-led exploration in `ideation/projects/` that produces harness artifacts. |
| Brainstorm | Single-file structured exploration in `ideation/scratchpad/brainstorm/` -- filter stage between ideas and projects. |
| The Funnel | Pipeline from ideas to committed work: `ideation/scratchpad/ideas/` → `ideation/scratchpad/brainstorm/` → `ideation/projects/` → `instance/orchestration/missions/` → `instance/cognition/context/shared/`. |
