---
name: refine-prompt
description: >
  Transforms rough, incomplete prompts into clear, actionable instructions
  with full codebase context awareness. Analyzes the repository to identify
  relevant files, patterns, and constraints. Assigns appropriate execution
  persona, defines negative constraints (what NOT to do), performs self-critique
  to catch gaps, and confirms intent with user before finalizing.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2025-01-14"
  updated: "2026-02-10"
skill_sets: [executor, collaborator]
capabilities: []
allowed-tools: Read Glob Grep Write(../../scaffolding/practices/prompts/*) Write(_ops/state/logs/*)
---

# Refine Prompt

Transform rough prompts into clear, actionable instructions grounded in codebase context.

## When to Use

Use this skill when:

- A prompt is vague or incomplete
- You need codebase-aware context added to a request
- Complex tasks need decomposition into sub-tasks
- You want persona assignment for task execution
- You need negative constraints (what NOT to do) defined

## Quick Start

```
/refine-prompt "add caching to the api"
```

## Core Workflow

1. **Context Analysis** - Analyze repo structure, find relevant files and patterns
2. **Intent Extraction** - Parse the prompt, expand implicit goals, fix errors
3. **Persona Assignment** - Assign appropriate expertise level and role
4. **Reference Injection** - Add specific file paths, functions, patterns
5. **Negative Constraints** - Define anti-patterns and forbidden approaches
6. **Decomposition** - Break complex requests into ordered sub-tasks
7. **Validation** - Check feasibility, identify risks and edge cases
8. **Self-Critique** - Review for completeness, ambiguity, quality
9. **Intent Confirmation** - Verify understanding with user
10. **Output** - Save refined prompt and execution log

## Parameters

Parameters are defined in `.octon/capabilities/runtime/skills/registry.yml` (single source of truth).

This skill accepts one required parameter (`raw_prompt`) and three optional parameters for execution mode, context depth, and confirmation behavior.

## Output Location

Output paths are defined in `.octon/capabilities/runtime/skills/registry.yml` (single source of truth).

Outputs are written to `.octon/scaffolding/practices/prompts/` (refined prompt) and `_ops/state/logs/refine-prompt/` (execution log).

## Boundaries

- Never change the core intent of the original prompt
- Always preserve explicit user preferences
- State all assumptions explicitly
- Reference only files that actually exist
- Write only to designated output paths
- Always perform self-critique before finalizing
- Confirm intent unless explicitly skipped

## When to Escalate

- Unresolvable contradictions in the prompt
- Completely unclear intent
- Referenced files don't exist
- Request conflicts with project constraints
- Scope exceeds 20 files
- Self-critique reveals major issues

## References

For detailed documentation:

- [Behavior phases](references/phases.md) - Full phase-by-phase instructions
- [I/O contract](references/io-contract.md) - Inputs, outputs, dependencies, command-line usage
- [Safety policies](references/safety.md) - Tool and file policies
- [Examples](references/examples.md) - Full refinement examples
- [Validation](references/validation.md) - Acceptance criteria
- [Error handling](references/errors.md) - Error codes, recovery procedures, troubleshooting
