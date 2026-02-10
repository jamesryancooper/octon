---
title: Safety Reference
description: Safety policies and behavioral constraints for the resolve-pr-comments skill.
---

# Safety Reference

Safety policies and behavioral constraints for the resolve-pr-comments skill.

> **Authoritative Sources:**
>
> - Tool permissions: `SKILL.md` frontmatter `allowed-tools`
> - Output paths: `.harmony/capabilities/skills/registry.yml`

## Tool Policy

### Mode

Deny-by-default

This skill requires:

- Read access to source files (for understanding context)
- Glob/Grep for finding related code
- Edit access to apply fixes
- Bash access scoped to `gh` CLI commands only
- Write access to report and log directories

This skill explicitly does **NOT** have:

- `git push` access (user must push manually)
- `git commit --amend` or `git rebase` access
- Permission to resolve/dismiss comments via GitHub API
- Permission to modify CI configuration

## Git Safety

### Commit Protocol

- Create **new commits** for fixes, never amend existing commits
- Use descriptive commit messages referencing the comment being addressed
- Never force-push
- Never rebase the PR branch during resolution

### Review Respect

- Never programmatically resolve or dismiss review comments
- Never mark a review as approved
- Let the reviewer verify that their concern was addressed
- If a resolution is partial, say so explicitly

## File Policy

### Modification Scope

The skill may only modify files that are:

1. Already part of the PR's changed file set, OR
2. Directly referenced by a review comment

Modifying files outside the PR scope requires explicit flagging in the report.

### Destructive Actions

None. The skill:

- **Does NOT** delete files
- **Does NOT** force-push
- **Does NOT** amend commits
- **Does NOT** dismiss reviews
- **Does** create new commits (non-destructive)
- **Does** write report files (non-destructive)

## Decision Boundaries

### What the Skill Decides

- How to fix BUG, STYLE, and NIT comments (clear corrections)
- Order of resolution (dependency-based)
- Classification of comments

### What the Skill Defers

- DESIGN comments with significant tradeoffs
- Conflicting comments from different reviewers
- Changes that would affect code outside the PR scope
- Whether to merge or request another review round

## Escalation Triggers

| Trigger | Action |
| ------- | ------ |
| >50 unresolved comments | Recommend batching |
| Conflicting reviewer comments | Flag conflict, defer |
| DESIGN comment with >2 valid approaches | Present options |
| Comment requires change outside PR scope | Flag, suggest follow-up PR |
