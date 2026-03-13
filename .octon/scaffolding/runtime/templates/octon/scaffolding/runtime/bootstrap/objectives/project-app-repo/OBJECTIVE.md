---
schema_version: "{{OBJECTIVE_BRIEF_SCHEMA_VERSION}}"
objective_id: "{{OBJECTIVE_ID}}"
intent_id: "{{INTENT_ID}}"
intent_version: "{{INTENT_VERSION}}"
owner: "{{OBJECTIVE_OWNER}}"
approved_by: "{{OBJECTIVE_APPROVED_BY}}"
generated_at: "{{GENERATED_AT}}"
---

# Objective: {{OBJECTIVE_LABEL}}

## Workspace Goal

Use Octon in `{{REPO_NAME}}` to set up, evolve, and ship a software project or application repository with safe, reviewable changes.

## What Octon Should Optimize For

- shipping functional increments without breaking the repo's expected workflow
- keeping architecture, implementation, tests, and docs aligned
- making the next highest-value repo change clear and executable

## In Scope

- source code, tests, configs, automation, and repo-local delivery docs
- bug fixes, features, refactors, and release-readiness work inside this repository
- repo workflow improvements that directly improve delivery or maintainability

## Out of Scope

- unrelated filesystem cleanup outside this repository
- organization-wide policy or process changes without explicit approval
- destructive or irreversible production actions without the required governance path

## Success Signals

- the repo stays buildable, testable, and understandable for the declared workflow
- prioritized work moves from plan to implementation to verification with clear evidence
- repo-local docs and continuity artifacts stay current enough for safe handoff

## Initial Focus

- confirm the current architecture, setup steps, and quality gates
- define the next shippable backlog item or stabilization task
- keep continuity artifacts updated as work progresses
