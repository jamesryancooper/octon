---
name: swift-cli-interface
description: >
  Generate a command-line interface using swift-argument-parser with
  subcommands, typed options, shell completions, and help text. Invoke
  with the project name and list of commands/subcommands.
skill_sets: [specialist]
capabilities: [phased]
# Write scopes are explicit: workspace scaffolding plus skill log output.
allowed-tools: Read Grep Glob Edit Write(../../../**) Write(_ops/state/logs/*) Bash(mkdir)
---

# CLI Interface

Generate a structured command-line interface using Swift ArgumentParser
with subcommands, typed options, validation, and shell completions.

## Arguments

`$ARGUMENTS` should include:

- **Project name** (for the CLI executable name)
- **Subcommands** and their options/arguments
- **Optional**: global flags, custom help text, version string

Example: `fsgraph init(path:String) scan(path:String,recursive:Bool) watch(paths:[String],daemon:Bool) query(sql:String) decide(file:String) review(batch:Int?)`

## Pre-flight Checks

1. Read `Package.swift` to verify swift-argument-parser is a dependency.
2. Check if `Sources/{PROJECT_NAME}CLI/main.swift` exists beyond the scaffold.
3. Read `Sources/{PROJECT_NAME}/Database/DatabaseManager.swift` for database
   commands that need a connection.
4. Read `Sources/{PROJECT_NAME}Daemon/Daemon.swift` for daemon-related commands.

## Generation Steps

### Step 1: Root command

Create or update `Sources/{PROJECT_NAME}CLI/main.swift`:

- `@main struct {PROJECT_NAME}CLI: AsyncParsableCommand` with:
  - `static let configuration = CommandConfiguration(commandName: "{project-name}", abstract: "{description}", subcommands: [...])`
  - `--config` global option (path to config file).
  - `--verbose` / `--quiet` global flags.
  - `--version` flag printing the current version.

### Step 2: Subcommands

For each declared subcommand, create `Sources/{PROJECT_NAME}CLI/Commands/{Command}Command.swift`:

- `struct {Command}Command: AsyncParsableCommand` with:
  - `static let configuration = CommandConfiguration(commandName: "{command}", abstract: "{description}")`
  - Typed `@Argument` and `@Option` properties matching declared fields.
  - `@Flag` for boolean options.
  - `mutating func run() async throws` with implementation skeleton.

Standard subcommands for a typical project:

- **init**: Initialize the project's data directory and database.
- **scan**: Index files from a given path into the database.
- **watch**: Start the file watcher (foreground) or daemon (background).
- **query**: Execute a query against the database and print results.
- **status**: Show project status (database stats, watcher state).

### Step 3: Shared helpers

Create `Sources/{PROJECT_NAME}CLI/Helpers/`:

- `CLIOutput.swift` — Formatted console output (table, JSON, progress).
- `ConfigLoader.swift` — Load config from `--config` option or default path.
- `ErrorHandler.swift` — Structured error display with exit codes.

### Step 4: Shell completions

Add instructions for generating shell completions:

```swift
// In the root command:
static let configuration = CommandConfiguration(
    // ...
    subcommands: [/* ... */, GenerateCompletions.self]
)

struct GenerateCompletions: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "completions",
        abstract: "Generate shell completions"
    )
    @Argument var shell: String = "zsh"
    func run() throws {
        // swift-argument-parser handles this automatically
    }
}
```

### Step 5: Exit codes

Define standard exit codes in `Sources/{PROJECT_NAME}CLI/Helpers/ExitCodes.swift`:

```swift
enum ExitCode: Int32 {
    case success = 0
    case generalError = 1
    case configError = 2
    case databaseError = 3
    case watcherError = 4
    case inputError = 64    // EX_USAGE
    case dataError = 65     // EX_DATAERR
    case noInput = 66       // EX_NOINPUT
}
```

## Edge Cases

- If `main.swift` already exists with content, read it and only add missing subcommands.
- If no database layer exists, database-related commands should print a warning
  and suggest running `/data-layer` first.
- If no daemon exists, watch/daemon commands should note that `/daemon-service`
  is needed for background operation.

## Cross-references

- **Depends on**: `/scaffold-package` (for Package.swift and module structure)
- **Optionally depends on**: `/data-layer` (for database commands), `/daemon-service` (for watch commands)
- **Feeds into**: `/contributor-guide` (for CLI usage documentation)

## When to Use

- Creating a Swift ArgumentParser command surface with subcommands and typed options
- Need repeatable scaffolding that follows Harmony foundation conventions

## Boundaries

- Does not perform in-place migrations of existing implementations
- Does not install runtime dependencies outside generated project files

## When to Escalate

- Project requires a non-standard directory topology or naming scheme
- Existing code must be migrated or reconciled instead of scaffolded from templates
