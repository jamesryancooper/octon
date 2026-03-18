---
name: swift-daemon-service
description: >
  Generate a single-writer background daemon with actor isolation, intent
  queue, FSEvents file watcher, LaunchAgent plist, and signal handling.
  Invoke with the project name and watched paths.
skill_sets: [specialist]
capabilities: [phased]
# Write scopes are explicit: workspace scaffolding plus skill log output.
allowed-tools: Read Grep Glob Edit Write(../../../**) Write(_ops/state/logs/*) Bash(mkdir)
---

# Daemon Service

Generate a production-grade macOS background daemon using Swift's actor
model for single-writer concurrency, with an intent queue, file system
watcher, and LaunchAgent configuration.

## Arguments

`$ARGUMENTS` should include:

- **Project name** (for naming the daemon executable and LaunchAgent)
- **Watched paths** (directories the daemon should monitor via FSEvents)
- **Intent types** (operations the daemon processes, e.g., move, tag, classify)
- **Optional**: restart policy, logging configuration

Example: `FSGraph ~/Documents ~/Desktop move,tag,classify,index`

## Pre-flight Checks

1. Read `Package.swift` to verify the daemon target exists.
2. Check if `Sources/{PROJECT_NAME}Daemon/` exists beyond `.gitkeep`.
3. Read `Sources/{PROJECT_NAME}/Database/DatabaseManager.swift` if it exists
   (daemon writes through the database actor).
4. Check if `Resources/` directory exists for the LaunchAgent plist.

## Generation Steps

### Step 1: Daemon actor

Create `Sources/{PROJECT_NAME}Daemon/Daemon.swift`:

- `actor Daemon` as the central coordinator.
- `func start() async throws` — initializes subsystems and enters run loop.
- `func stop() async` — graceful shutdown with cleanup.
- Holds references to: database manager, file watcher, intent queue.
- Uses `Task.detached` for long-running loops with `Task.isCancelled` checks.
- Signal handling: SIGTERM and SIGINT via `DispatchSource.makeSignalSource`.

### Step 2: Intent queue

Create `Sources/{PROJECT_NAME}Daemon/IntentQueue.swift`:

- `actor IntentQueue` backed by a separate SQLite database (`queue.db`).
- `struct Intent: Codable` with id, type, payload, status, priority, attempts, createdAt.
- `enum IntentStatus: String, Codable` — pending, processing, completed, failed.
- `func enqueue(_ intent: Intent) async throws`
- `func dequeue() async throws -> Intent?` — fetch highest-priority pending intent.
- `func markCompleted(id: String) async throws`
- `func markFailed(id: String, error: String) async throws` with retry logic.
- Indexes on (status, priority) for efficient polling.

### Step 3: File watcher

Create `Sources/{PROJECT_NAME}Daemon/FileWatcher.swift`:

- `class FileWatcher` using Darwin's FSEvents API.
- `protocol FileWatcherDelegate: AnyObject` with callback methods:
  - `func fileWatcher(_ watcher: FileWatcher, didObserveEvents events: [FileEvent])`
- `struct FileEvent` with path, flags (created, modified, removed, renamed).
- Event stream configuration:
  - Latency: 0.5 seconds (debouncing).
  - Flags: `kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagUseCFTypes`.
- Filtering: ignore `.DS_Store`, `.git/`, `.build/`, temporary files.
- Batch processing: collect events over the latency window, deduplicate by path.

### Step 4: Action executor

Create `Sources/{PROJECT_NAME}Daemon/ActionExecutor.swift`:

- `struct ActionExecutor` (or actor if state is needed).
- `enum Action: Codable` — move, copy, tag, classify, index (matching intent types).
- `func execute(_ action: Action, on path: URL) async throws -> ActionResult`
- `struct ActionResult` with success/failure, details, timestamp.
- All file operations use `FileManager` with error handling.
- Soft-delete pattern: move to trash directory rather than permanent deletion.

### Step 5: Daemon entry point

Create `Sources/{PROJECT_NAME}Daemon/{PROJECT_NAME}Daemon.swift`:

- `@main struct {PROJECT_NAME}DaemonCommand: AsyncParsableCommand` (if using ArgumentParser)
  OR simple `@main struct {PROJECT_NAME}DaemonMain` with static `main()`.
- Parse command-line options: `--config`, `--data-dir`, `--log-level`.
- Initialize configuration, database, daemon actor.
- Call `daemon.start()` and await termination.

### Step 6: LaunchAgent plist

Create `Resources/com.{author}.{project-name}d.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.{author}.{project-name}d</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/{project-name}d</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/{project-name}d.stdout.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/{project-name}d.stderr.log</string>
</dict>
</plist>
```

### Step 7: Daemon configuration

Update `Sources/{PROJECT_NAME}/Config/Configuration.swift`:

- Add `watchedPaths: [URL]` field.
- Add `queueDatabasePath: URL` field (default: `dataDirectory/queue.db`).
- Add `eventLatency: TimeInterval` field (default: `0.5`).
- Add `maxRetries: Int` field (default: `3`).

## Edge Cases

- If `Daemon/` already has files, read them and only add missing components.
- If no database actor exists, the daemon can operate without persistence
  (log-only mode) — warn the user to run `/data-layer` for full functionality.
- If the project does not need file watching, skip the FileWatcher and create
  a simpler daemon that processes intents from a different source.

## Cross-references

- **Depends on**: `/scaffold-package` (for Package.swift and module structure)
- **Optionally depends on**: `/data-layer` (for database persistence)
- **Feeds into**: `/test-harness` (for daemon integration tests), `/cli-interface` (for watch command)

## When to Use

- Generating LaunchAgent daemon scaffolding with intent queue and file-watcher integration
- Need repeatable scaffolding that follows Octon foundation conventions

## Boundaries

- Does not perform in-place migrations of existing implementations
- Does not install runtime dependencies outside generated project files

## When to Escalate

- Project requires a non-standard directory topology or naming scheme
- Existing code must be migrated or reconciled instead of scaffolded from templates
