---
name: swift-scaffold-package
description: >
  Create an architecture-aligned Swift package structure with Package.swift,
  source targets, typed configuration, structured logging, and standard modules.
  Invoke with a project name, description, Swift version, platform, and dependencies.
skill_sets: [specialist]
capabilities: [phased, external-dependent]
# Write scopes are explicit: workspace scaffolding plus skill log output.
allowed-tools: Read Grep Glob Edit Write(../../../**) Write(/.octon/state/evidence/runs/skills/*) Bash(mkdir) Bash(swift)
---

# Scaffold Package

Create the foundational package structure for a Swift macOS application
following local-first, actor-based concurrency conventions.

## Arguments

`$ARGUMENTS` should include:

- **Project name** (PascalCase for module names, kebab-case for directory)
- **One-line description**
- **Swift version** (e.g., `5.9`, `6.0`)
- **macOS deployment target** (e.g., `14`, `15`)
- **Dependencies** to include (subset of: grdb, yams, argument-parser, async-http-client, swift-graph, ulid)
- **Optional**: additional targets beyond the standard set

Example: `FSGraph "Local-first semantic file system" 5.9 14 grdb yams argument-parser async-http-client ulid`

## Pre-flight Checks

Before generating anything:

1. Read `Package.swift` if it exists — only fill gaps, never overwrite.
2. Check if `Sources/` directory exists. If not, this is a fresh scaffold.
3. Normalize the project name: PascalCase for library target, kebab-case
   with lowercase for CLI executable name.

## Generation Steps

### Step 1: `Package.swift`

Create the Swift Package Manager manifest.

- Set `swift-tools-version` to the declared version (e.g., `5.9`).
- Set `.macOS(.v14)` (or declared target) in `platforms`.
- Define products:
  - **Library**: `.library(name: "{PROJECT_NAME}", targets: ["{PROJECT_NAME}"])`
  - **CLI**: `.executable(name: "{project-name}-cli", targets: ["{PROJECT_NAME}CLI"])`
  - **Daemon**: `.executable(name: "{project-name}d", targets: ["{PROJECT_NAME}Daemon"])`
  - **UI App** (optional): `.executable(name: "{project-name}-app", targets: ["{PROJECT_NAME}App"])`
- Add declared dependencies with version ranges:
  - **grdb**: `.package(url: "https://github.com/groue/GRDB.swift.git", from: "6.24.0")`
  - **yams**: `.package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0")`
  - **argument-parser**: `.package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0")`
  - **async-http-client**: `.package(url: "https://github.com/swift-server/async-http-client.git", from: "1.19.0")`
  - **swift-graph**: `.package(url: "https://github.com/davecom/SwiftGraph.git", from: "3.1.0")`
  - **ulid**: `.package(url: "https://github.com/yaslab/ULID.swift.git", from: "1.3.0")`
- Define targets with appropriate dependencies.
- If `Package.swift` already exists, merge additively using the Edit tool.

### Step 2: Core library source tree

Create `Sources/{PROJECT_NAME}/` with these modules:

```
Sources/{PROJECT_NAME}/
├── {PROJECT_NAME}.swift       # Public API re-exports
├── Core/
│   └── Types.swift            # Domain types, enums, Codable structs
├── Config/
│   ├── Configuration.swift    # Typed config with Codable
│   └── Defaults.swift         # Default values and paths
├── Database/
│   └── .gitkeep               # Placeholder for data-layer skill
├── Logging/
│   └── Logger.swift           # Structured logging with os.log or custom
└── Extensions/
    └── .gitkeep               # Placeholder for common extensions
```

### Step 3: CLI target

Create `Sources/{PROJECT_NAME}CLI/`:

```
Sources/{PROJECT_NAME}CLI/
└── main.swift                 # CLI entry point (ArgumentParser)
```

### Step 4: Daemon target

Create `Sources/{PROJECT_NAME}Daemon/`:

```
Sources/{PROJECT_NAME}Daemon/
└── .gitkeep                   # Placeholder for daemon-service skill
```

### Step 5: Test target

Create `Tests/{PROJECT_NAME}Tests/`:

```
Tests/{PROJECT_NAME}Tests/
└── .gitkeep                   # Placeholder for test-harness skill
```

### Step 6: `Core/Types.swift`

Define foundational domain types:

- Core enums with `String` raw values (Codable-friendly).
- Value types as `struct` with `Codable`, `Sendable`, `Equatable` conformance.
- A base `Identifiable` protocol or typealias using ULID or UUID.
- Error enums per module with `LocalizedError` conformance.

### Step 7: `Config/Configuration.swift`

- `struct AppConfiguration: Codable` with fields for:
  - `dataDirectory: URL` (default: `~/.{project-name}/`)
  - `logLevel: LogLevel` enum
  - `databasePath: URL` (derived from dataDirectory)
- `static func load(from url: URL) throws -> AppConfiguration`
- `static var `default`: AppConfiguration`

### Step 8: `Logging/Logger.swift`

- Structured logging using `os.Logger` or a custom JSON logger.
- Subsystem set to reverse-DNS (`com.{author}.{project-name}`).
- Categories for major subsystems (database, watcher, daemon, cli).
- Helper for structured context (correlation IDs, component names).

### Step 9: `{PROJECT_NAME}.swift` re-exports

- Module-level file that `@_exported import`s or re-exports public types.
- Public `__all__`-style documentation comment listing key types.

## Edge Cases

- If `Sources/{PROJECT_NAME}/` already exists, only create missing sub-directories and files.
- If `Package.swift` exists, read existing dependencies and only add missing ones.
- Do not create `.build/` — that is SPM's responsibility.

## Cross-references

- **Run first** in the foundation workflow.
- Feeds into: `/data-layer`, `/daemon-service`, `/cli-interface`, `/test-harness`, `/contributor-guide`.

## When to Use

- Starting a new Swift macOS package scaffold with modules, config, and logging conventions
- Need repeatable scaffolding that follows Octon foundation conventions

## Boundaries

- Does not perform in-place migrations of existing implementations
- Does not install runtime dependencies outside generated project files

## When to Escalate

- Project requires a non-standard directory topology or naming scheme
- Existing code must be migrated or reconciled instead of scaffolded from templates
