---
title: Execution Phases
description: Phased execution guide for test-harness.
---

# Execution Phases

## Phase 1: Discover Context

- Parse arguments and infer target project metadata
- Inspect existing repository files to avoid destructive overwrites

## Phase 2: Plan Scaffold

- Determine which template artifacts are required for this run
- Resolve naming, paths, and dependency toggles before writing files

## Phase 3: Generate Artifacts

- Create directories and files for the selected scaffold components
- Write deterministic template output with project-specific substitutions

## Phase 4: Validate and Summarize

- Confirm expected artifacts exist and key references are internally consistent
- Return a concise summary with follow-up actions

## Outcome

Create pytest harness layers and fixture scaffolding tied to contracts.
