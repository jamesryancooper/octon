# CONTRIBUTING.md Structure Pattern

Generate this file by reading actual project state. Replace placeholders
with discovered values.

---

```markdown
# Contributing Guide

## 1. Scope

This repository is contract-first and documentation-heavy in pre-build stages.
Changes must preserve explicit contracts and pass quality gates before merge.

## 2. Branch Naming

Use:

`<type>/<ticket-id>-<short-description>`

Examples:

1. `feat/{{TICKET_PREFIX}}-42-add-resource-endpoint`
2. `fix/{{TICKET_PREFIX}}-77-retry-status-race`
3. `docs/{{TICKET_PREFIX}}-15-openapi-skeleton`

If no ticket exists, omit the ticket segment:

- `docs/update-glossary`

## 3. Commit Message Format

Use Conventional Commits:

`<type>(<scope>): <summary>`

Types:

- `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `chore`, `ci`, `revert`

Examples:

1. `feat(api): add v1 resource status response model`
2. `docs(contracts): add openapi v1 skeleton`
3. `ci(checks): run just check in pull requests`

## 4. Local Workflow

Before opening a PR:

1. `just validate-schemas`
2. `just lint`
3. `just type`
4. `just test`
5. `just check`
6. Ensure local hooks are installed once: `just precommit-install`

## 5. Pull Request Expectations

1. One concern per PR.
2. Include a clear `What/Why/How` description.
3. Reference the ticket in PR description.
4. Update docs/contracts/tests for behavior changes.
5. Keep PRs reviewable; split if broad or mixed concerns.

PR template is provided in `.github/PULL_REQUEST_TEMPLATE.md`.

## 6. Code Review Conventions

Reviewers prioritize, in order:

1. Correctness and contract integrity.
2. Security and data handling risks.
3. Backward compatibility and migration safety.
4. Test coverage for edge/error paths.
5. Operational impact (observability, rollback, runbooks).

Author responsibilities:

1. Respond to every review comment.
2. Do not resolve comments from other reviewers.
3. Re-run `just check` after substantial updates.
4. Avoid force-push during active review unless coordinated.

## 7. Definition of Ready to Merge

1. CI passes (`just check`).
2. Required reviewer approvals are present.
3. No unresolved blocking comments.
4. Docs/contracts are updated for visible changes.
```
