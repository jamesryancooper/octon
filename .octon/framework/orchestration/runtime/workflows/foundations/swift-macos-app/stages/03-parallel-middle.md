---
name: parallel-middle
title: "Parallel Middle Tier"
description: "Run /data-layer and /daemon-service — independent of each other."
---

# Step 3: Parallel Middle Tier

## Input

- Validated input record (from step 1)
- Completed package structure (from step 2)

## Purpose

Run the two middle-tier skills that depend only on `/scaffold-package`
and are independent of each other. These can execute in any order or
concurrently.

## Actions

### 3a: Data Layer

**Skip if** `data-layer` is in the skip list or `grdb` is not in the
declared dependencies.

1. **Check prerequisites:**

   - `Package.swift` lists GRDB.swift as a dependency
   - `Sources/{PROJECT_NAME}/Core/Types.swift` exists with domain types

2. **Invoke:**

   ```text
   /data-layer {ENTITY_DESCRIPTIONS}
   ```

   The entity descriptions come from `$ARGUMENTS`. If the user provided
   entity/field definitions, pass them through. If not, generate default
   entities based on the project description (files, entities, relationships,
   tags, decisions).

3. **Validate outputs:**

   - `Sources/{PROJECT_NAME}/Database/DatabaseManager.swift` exists with actor
   - `Sources/{PROJECT_NAME}/Database/Migrations.swift` exists
   - At least one `Sources/{PROJECT_NAME}/Database/Records/*.swift` file exists
   - `Sources/{PROJECT_NAME}/Database/Queries/` directory exists

### 3b: Daemon Service

**Skip if** `daemon-service` is in the skip list or the project is a
library/CLI-only tool without background processing needs.

1. **Check prerequisites:**

   - `Package.swift` has a daemon target
   - `Sources/{PROJECT_NAME}Daemon/` directory exists

2. **Invoke:**

   ```text
   /daemon-service {PROJECT_NAME} {WATCHED_PATHS} {INTENT_TYPES}
   ```

3. **Validate outputs:**

   - `Sources/{PROJECT_NAME}Daemon/Daemon.swift` exists with actor
   - `Sources/{PROJECT_NAME}Daemon/IntentQueue.swift` exists
   - `Sources/{PROJECT_NAME}Daemon/FileWatcher.swift` exists
   - `Sources/{PROJECT_NAME}Daemon/{PROJECT_NAME}Daemon.swift` exists (entry point)
   - `Resources/com.{author}.{project-slug}d.plist` exists

## Handling Failures

Each sub-step is independent. If one fails:

- Record the failure with details
- Continue with the remaining sub-step
- Failed skills are noted for the verify step

If `data-layer` fails, `/test-harness` (step 4) will still run but
produce only core type tests (no database tests).

## Idempotency

**Check:** Outputs from each sub-step already exist.

- [ ] 3a: `Sources/{PROJECT_NAME}/Database/DatabaseManager.swift` exists (or skipped)
- [ ] 3b: `Sources/{PROJECT_NAME}Daemon/Daemon.swift` exists (or skipped)

**If Already Complete:**

- Skip completed sub-steps, run only those with missing outputs
- Each child skill handles additive generation internally

**Marker:** `checkpoints/swift-macos-app-foundation/03-parallel-middle.complete`

## Error Messages

- Data layer failed: "DATA_LAYER_FAILED: /data-layer exited with errors — test-harness will run without database tests"
- Daemon failed: "DAEMON_FAILED: /daemon-service exited with errors — CLI will lack watch command"
- GRDB not declared: "DATA_LAYER_NO_GRDB: /data-layer requires grdb dependency — add it or skip this skill"

## Output

- Database actor, migrations, record types, query helpers (3a)
- Daemon actor, intent queue, file watcher, LaunchAgent plist (3b)
- Record of which sub-steps succeeded/failed/skipped

## Proceed When

- [ ] All non-skipped sub-steps either succeeded or have documented failures
- [ ] At least one sub-step succeeded (workflow can continue)
