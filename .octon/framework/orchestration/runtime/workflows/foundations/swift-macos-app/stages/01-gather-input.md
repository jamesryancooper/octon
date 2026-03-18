---
name: gather-input
title: "Gather Input"
description: "Collect and validate project name, description, Swift version, macOS target, and dependencies."
---

# Step 1: Gather Input

## Input

- User-provided arguments (project name, description, Swift version, macOS target, dependencies)
- Optional: `--skip` flag listing skills to skip

## Purpose

Normalize and validate all inputs before any skill runs. Every downstream
skill needs the same core arguments — collecting them once prevents
repeated prompting and ensures consistency.

## Actions

1. **Parse arguments:**

   Extract from `$ARGUMENTS`:

   - `PROJECT_NAME` — PascalCase for module names (e.g., `FSGraph`)
   - `PROJECT_SLUG` — kebab-case for executables and directories (e.g., `fsgraph`)
   - `DESCRIPTION` — quoted one-liner
   - `SWIFT_VERSION` — e.g., `5.9` → tools version `5.9`, language mode
   - `MACOS_TARGET` — e.g., `14` → `.macOS(.v14)`
   - `DEPENDENCIES` — subset of: `grdb`, `yams`, `argument-parser`, `async-http-client`, `swift-graph`, `ulid`

2. **Validate:**

   - Project name must be non-empty and valid Swift identifier (PascalCase)
   - Swift version must be 5.9+
   - macOS target must be 14+
   - Dependencies must be from the recognized set (warn on unrecognized, don't fail)

3. **Check for existing project:**

   - If `Package.swift` exists, read product names and confirm compatibility
   - If `Sources/` exists, note this is an incremental run
   - If neither exists, this is a fresh scaffold

4. **Determine skip list:**

   If `--skip` is provided, parse the comma-separated skill names. Validate
   dependency constraints:

   - Cannot skip `scaffold-package` unless `Package.swift` and `Sources/{PROJECT_NAME}/` already exist
   - Cannot skip `data-layer` if `test-harness` is not also skipped
     (unless database files already exist in `Sources/{PROJECT_NAME}/Database/`)

5. **Record input summary:**

   ```markdown
   ## Foundation Input

   | Field          | Value                           |
   | -------------- | ------------------------------- |
   | Project name   | FSGraph                         |
   | Project slug   | fsgraph                         |
   | Description    | Local-first semantic file system |
   | Swift version  | 5.9                             |
   | macOS target   | 14 (.macOS(.v14))               |
   | Dependencies   | grdb, yams, argument-parser     |
   | Skills to run  | all (or list of active)         |
   | Mode           | fresh / incremental             |
   ```

## Idempotency

**Check:** Input summary already recorded.

- [ ] Checkpoint file exists at `checkpoints/swift-macos-app-foundation/01-gather-input.complete`

**If Already Complete:**

- Skip to step 2
- Re-run if arguments have changed

**Marker:** `checkpoints/swift-macos-app-foundation/01-gather-input.complete`

## Error Messages

- Missing project name: "PROJECT_NAME_REQUIRED: Provide a project name as the first argument"
- Invalid project name: "PROJECT_NAME_INVALID: Must be a valid Swift identifier in PascalCase (got '{name}')"
- Conflicting products: "PRODUCT_CONFLICT: Package.swift has product '{existing}', argument implies '{provided}'"
- Invalid skip: "SKIP_INVALID: Cannot skip scaffold-package without existing package structure"

## Output

- Validated input record (PROJECT_NAME, PROJECT_SLUG, DESCRIPTION, SWIFT_VERSION, MACOS_TARGET, DEPENDENCIES, SKIP_LIST, MODE)
- Input summary for downstream steps

## Proceed When

- [ ] All required fields are populated
- [ ] Project name is a valid Swift identifier
- [ ] No unresolvable conflicts with existing project state
- [ ] Skip list (if any) respects dependency constraints
