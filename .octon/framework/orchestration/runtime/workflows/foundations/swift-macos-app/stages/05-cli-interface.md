---
name: cli-interface
title: "CLI Interface"
description: "Run /cli-interface after scaffold-package and optionally data-layer/daemon."
---

# Step 5: CLI Interface

## Input

- Validated input record (from step 1)
- Completed package structure (from step 2)
- Data layer outputs (from step 3a, if run) — for database commands
- Daemon outputs (from step 3b, if run) — for watch/daemon commands

## Purpose

Generate a structured command-line interface with subcommands that
integrate with the database layer and daemon service (if available).

## Actions

1. **Check skip list:**

   If `cli-interface` is in the skip list:

   - Verify `Sources/{PROJECT_NAME}CLI/main.swift` has content beyond scaffold
   - If verified, skip to step 6
   - If just a scaffold, warn and ask user whether to proceed

2. **Determine available commands:**

   Based on which previous skills ran:

   - **Always**: `init`, `status`, `completions`
   - **If data-layer ran**: `scan`, `query`
   - **If daemon ran**: `watch`, `decide`, `review`

3. **Invoke the skill:**

   ```text
   /cli-interface {PROJECT_SLUG} {SUBCOMMANDS}
   ```

   Example:

   ```text
   /cli-interface fsgraph init,scan,watch,query,decide,review,status
   ```

4. **Validate outputs:**

   - `Sources/{PROJECT_NAME}CLI/main.swift` has `AsyncParsableCommand` root
   - `Sources/{PROJECT_NAME}CLI/Commands/` has one file per subcommand
   - `Sources/{PROJECT_NAME}CLI/Helpers/` has CLIOutput and ConfigLoader

5. **Record result:**

   Note which subcommands were generated.

## Idempotency

**Check:** CLI already has subcommands.

- [ ] `Sources/{PROJECT_NAME}CLI/Commands/` directory has `.swift` files
- [ ] `Sources/{PROJECT_NAME}CLI/main.swift` lists subcommands

**If Already Complete:**

- Skip to step 6
- Only add new subcommands for newly-available functionality

**Marker:** `checkpoints/swift-macos-app-foundation/05-cli-interface.complete`

## Error Messages

- Skill failed: "CLI_FAILED: /cli-interface exited with errors: {details}"
- ArgumentParser missing: "CLI_NO_PARSER: swift-argument-parser not in Package.swift dependencies"

## Output

- Root command with subcommands
- Per-subcommand Swift files
- Helper utilities (output formatting, config loading, error handling)
- Shell completion support

## Proceed When

- [ ] `Sources/{PROJECT_NAME}CLI/main.swift` has `AsyncParsableCommand`
- [ ] At least `init` and `status` subcommands exist
- [ ] Helper files exist in `Helpers/`
