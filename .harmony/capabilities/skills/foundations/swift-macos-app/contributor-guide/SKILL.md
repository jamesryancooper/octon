---
name: contributor-guide
description: >
  Generate project documentation: CLAUDE.md for AI agents, CONTRIBUTING.md
  for developers, architecture overview, PR template, and CI config.
  Invoke with the project name — reads outputs from all other skills.
allowed-tools: Read, Grep, Glob, Bash, Write, Edit
disable-model-invocation: true
---

# Contributor Guide

Generate comprehensive project documentation by reading the outputs of
all other foundation skills: CLAUDE.md for AI agent orientation,
CONTRIBUTING.md for human developers, architecture overview, and GitHub
workflow configuration.

## Arguments

`$ARGUMENTS` should include:

- **Project name**
- **Optional**: author name, license type, repository URL

Example: `FSGraph --author "James Cooper" --license MIT`

## Pre-flight Checks

1. Read `Package.swift` to discover all targets and dependencies.
2. Scan `Sources/` to build a module layout map.
3. Read existing `CLAUDE.md`, `CONTRIBUTING.md`, `README.md` to avoid overwriting.
4. Check `.github/workflows/` for existing CI configuration.
5. Read `Schemas/` for JSON Schema files to document.

## Generation Steps

### Step 1: CLAUDE.md

Generate a `CLAUDE.md` at the project root with:

- **Project overview**: one-paragraph description and philosophy.
- **Architecture**: module layout table (target → purpose → key files).
- **Build commands**: `swift build`, `swift test`, `swift build -c release`.
- **Key patterns**: actor concurrency, GRDB conventions, error handling style.
- **Constraints**: things the AI agent must never do (based on project invariants).
- **File conventions**: naming patterns, directory structure.
- **Testing**: how to run tests, where fixtures live.

### Step 2: CONTRIBUTING.md

Generate `CONTRIBUTING.md` with:

- **Development setup**: prerequisites (Swift version, Xcode, macOS version).
- **Building**: `swift build` and target-specific builds.
- **Testing**: `swift test`, integration test setup, Python schema tests.
- **Code style**: Swift conventions, naming patterns, documentation standards.
- **Pull request process**: branch naming, commit messages, review checklist.
- **Architecture guide**: brief module overview with links to detailed docs.

### Step 3: Architecture overview

Generate `Docs/architecture/overview.md` with:

- **System diagram**: ASCII art showing component relationships.
- **Module descriptions**: one paragraph per source target.
- **Data flow**: how data moves through the system (watcher → queue → daemon → database).
- **Key invariants**: critical design constraints (e.g., single-writer, soft-delete).
- **Technology choices**: table of dependencies and their purposes.

### Step 4: PR template

Create `.github/pull_request_template.md`:

```markdown
## Summary

<!-- Brief description of changes -->

## Type of Change

- [ ] Bug fix
- [ ] New feature
- [ ] Refactoring
- [ ] Documentation
- [ ] CI/CD

## Testing

- [ ] `swift test` passes
- [ ] New tests added for changed code
- [ ] Integration tests pass (if applicable)

## Checklist

- [ ] Code follows project conventions
- [ ] No new warnings from `swift build`
- [ ] Documentation updated (if applicable)
- [ ] CLAUDE.md updated (if architecture changed)
```

### Step 5: README.md (if missing)

If no `README.md` exists, generate one with:

- Project name and badge (CI status).
- One-paragraph description.
- Quick start (build, test, install).
- Architecture overview (link to `Docs/architecture/overview.md`).
- License.

### Step 6: .gitignore

Create or update `.gitignore`:

```
.build/
.swiftpm/
*.xcodeproj/
xcuserdata/
DerivedData/
.DS_Store
*.o
*.d
*.swp
.env.local
*.db
*.db-wal
*.db-shm
```

## Edge Cases

- If `CLAUDE.md` already exists, read it and only add missing sections.
- If the project has no daemon, omit daemon-related documentation.
- If the project has no UI app, omit SwiftUI-related documentation.
- Read actual source files to ensure documentation accuracy — never guess
  at module contents.

## Cross-references

- **Depends on**: all other foundation skills (reads their outputs)
- **Run last** in the foundation workflow.
