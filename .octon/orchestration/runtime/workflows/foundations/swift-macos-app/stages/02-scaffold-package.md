---
name: scaffold-package
title: "Scaffold Package"
description: "Run /scaffold-package to create Package.swift and the foundational module structure."
---

# Step 2: Scaffold Package

## Input

- Validated input record (from step 1)

## Purpose

Create the foundational package structure that every other skill depends on:
`Package.swift`, `Sources/{PROJECT_NAME}/` tree, typed config, structured
logging, and the core type definitions.

## Actions

1. **Check skip list:**

   If `scaffold-package` is in the skip list:

   - Verify `Package.swift` exists with expected products
   - Verify `Sources/{PROJECT_NAME}/` exists with `Core/Types.swift` and `Config/Configuration.swift`
   - If verified, skip to step 3
   - If missing critical files, warn and ask user whether to proceed

2. **Invoke the skill:**

   ```text
   /scaffold-package {PROJECT_NAME} "{DESCRIPTION}" {SWIFT_VERSION} {MACOS_TARGET} {DEPENDENCIES...}
   ```

   Example:

   ```text
   /scaffold-package FSGraph "Local-first semantic file system" 5.9 14 grdb yams argument-parser async-http-client ulid
   ```

3. **Validate outputs:**

   After the skill completes, confirm these files exist:

   - `Package.swift` with expected products and dependencies
   - `Sources/{PROJECT_NAME}/{PROJECT_NAME}.swift` (re-exports)
   - `Sources/{PROJECT_NAME}/Core/Types.swift`
   - `Sources/{PROJECT_NAME}/Config/Configuration.swift`
   - `Sources/{PROJECT_NAME}/Logging/Logger.swift`
   - `Sources/{PROJECT_NAME}CLI/main.swift` (scaffold)
   - `Sources/{PROJECT_NAME}Daemon/.gitkeep` (placeholder)

4. **Record result:**

   Note which files were created vs already existed (for incremental runs).

## Idempotency

**Check:** Package structure already exists.

- [ ] `Package.swift` exists with correct products
- [ ] `Sources/{PROJECT_NAME}/Core/Types.swift` exists
- [ ] `Sources/{PROJECT_NAME}/Config/Configuration.swift` exists
- [ ] `Sources/{PROJECT_NAME}/Logging/Logger.swift` exists

**If Already Complete:**

- Skip to step 3
- The skill itself handles additive generation (only creates missing files)

**Marker:** `checkpoints/swift-macos-app-foundation/02-scaffold-package.complete`

## Error Messages

- Skill invocation failed: "SCAFFOLD_FAILED: /scaffold-package exited with errors: {details}"
- Critical file missing after run: "SCAFFOLD_INCOMPLETE: Expected {file} but it was not created"

## Output

- Complete package structure under `Sources/{PROJECT_NAME}/`
- `Package.swift` with project metadata and dependencies
- List of files created/verified

## Proceed When

- [ ] `Package.swift` exists with correct products and dependencies
- [ ] `Sources/{PROJECT_NAME}/` tree has all standard modules
- [ ] `Core/Types.swift` contains domain type definitions
- [ ] `Config/Configuration.swift` contains typed configuration
