---
title: Safety Reference
description: Safety policies and constraints for the spec-to-implementation skill.
# AUTHORITATIVE SOURCES (Single Source of Truth):
#   - Tool permissions: SKILL.md frontmatter `allowed-tools`
#   - Output paths: .octon/capabilities/runtime/skills/registry.yml
#
# Current allowed-tools: Read Glob Grep Write(../../output/plans/*) Write(_ops/state/logs/*)
#
# Prose descriptions below are derived from these sources.
# If discrepancies exist, the authoritative sources are correct.
---

# Safety Reference

## Tool Policy

### Mode

Deny-by-default

This skill is **read-only** against the codebase. It analyzes but never modifies source files.

This skill requires:

- Read access to spec documents and codebase files
- Glob/Grep for codebase mapping
- Write access to plan output and log directories

This skill explicitly does **NOT** have:

- Edit access (no source file modifications)
- Bash access (no shell commands)
- Task access (no sub-agent delegation)

## Decision Boundaries

### What the Skill Decides

- How to decompose requirements into tasks
- Task sequencing based on technical dependencies
- Relative complexity assessment (S/M/L)

### What the Skill Defers

- Architectural decisions with significant tradeoffs — present options
- Technology choices not specified in the spec — list alternatives
- Timeline estimates — never estimate time, only complexity
- Scope decisions — flag if requirements seem too large, let human decide

## Behavioral Boundaries

- Never modify source files — analysis and planning only
- Never make architectural decisions unilaterally
- Never estimate time or story points
- Always list assumptions explicitly
- Always present the plan for human review
- If spec exceeds 30 tasks, recommend splitting into phases
