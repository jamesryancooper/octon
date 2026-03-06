---
name: swift-macos-app
description: >
  Foundation skill set for Swift macOS applications. Provides context about
  the available skills, their dependencies, and the recommended workflow.
skill_sets: [specialist]
capabilities: []
allowed-tools: Read Grep Glob
---

# Swift macOS App Foundation

Background context for Claude — not invoked directly. This skill set
targets **Swift macOS applications** following local-first, actor-based
concurrency patterns. Claude should use this to guide skill suggestions,
sequencing, and stack assumptions.

## Stack Assumptions

These skills encode a specific technology stack. They apply when the
project matches most of these choices:

| Layer             | Choice                                        |
|-------------------|-----------------------------------------------|
| Language          | Swift 5.9+ / 6.x                             |
| Platform          | macOS 14+ (Sonoma and later)                  |
| Build system      | Swift Package Manager (SPM)                   |
| Concurrency       | Swift Concurrency (async/await, actors)       |
| Database          | SQLite via GRDB.swift                         |
| Config/parsing    | Yams (YAML), Codable (JSON)                   |
| CLI framework     | swift-argument-parser                         |
| UI framework      | SwiftUI (optional)                            |
| Networking        | AsyncHTTPClient or URLSession                 |
| Identity          | ULID.swift or Foundation.UUID                 |
| Testing           | XCTest + swift test                           |
| CI                | GitHub Actions                                |
| Optional          | FSEvents, CryptoKit, CoreGraphics, ImageIO    |

**When not to suggest these skills:** iOS-only projects, server-side Swift
(Vapor/Hummingbird), cross-platform projects targeting Linux, or projects
using a fundamentally different persistence layer (Core Data, SwiftData,
Realm). If the user's stack diverges on more than two rows, these skills
will produce friction rather than value.

## Child Skills

| Skill                | Purpose                                                    |
|----------------------|------------------------------------------------------------|
| `/swift-scaffold-package`  | Package.swift, source targets, typed config, structured logging, standard modules |
| `/swift-data-layer`        | SQLite database actor, schema migrations, GRDB record types, query helpers |
| `/swift-daemon-service`    | Single-writer daemon actor, intent queue, LaunchAgent plist, signal handling |
| `/swift-cli-interface`     | ArgumentParser commands, subcommands, shell completions    |
| `/swift-test-harness`      | XCTest suites, test fixtures, CI workflow, schema validation |
| `/swift-contributor-guide` | CLAUDE.md, CONTRIBUTING.md, architecture overview, PR template, CI config |

## Dependency Graph

```text
scaffold-package ──┬── data-layer ────────────┐
                   │                          ├── test-harness
                   ├── daemon-service ────────┘       │
                   │                                  │
                   ├── cli-interface ◄────────────────┘
                   │
                   └──────────────────────────── contributor-guide
```

## Recommended Sequencing

When a user asks to "set up a Swift macOS app" or similar, suggest
running the skills in this order:

1. **`/swift-scaffold-package`** — always first. Creates Package.swift, source
   targets, module layout, typed config, and structured logging that every
   other skill reads.

2. **`/swift-data-layer`** and **`/swift-daemon-service`** — run in either order (no
   dependency between them). Both only require scaffold-package. If the
   user has a data model ready, start with data-layer. If they want the
   background service first, start with daemon-service.

3. **`/swift-test-harness`** — after data-layer and daemon-service. It discovers
   GRDB record types from `/swift-data-layer` and reads actor interfaces from
   `/swift-daemon-service` to generate integration test scaffolding. Running it
   earlier is safe but produces incomplete coverage.

4. **`/swift-cli-interface`** — after scaffold-package at minimum; benefits from
   running after data-layer (database commands) and daemon-service (watch
   commands). Can run in parallel with test-harness if needed.

5. **`/swift-contributor-guide`** — always last. It reads the outputs of every
   other skill (module layout, Package.swift targets, database schema, CI
   config) to generate accurate documentation.

## Partial Runs

Not every project needs all six skills. Common subsets:

- **Minimal CLI tool**: scaffold-package → cli-interface → contributor-guide
- **Full foundation**: all six in order above
- **Library only**: scaffold-package → data-layer → test-harness
- **Adding persistence to existing project**: data-layer → test-harness
  (assuming package structure already exists)
- **Daemon only**: scaffold-package → daemon-service → cli-interface

When suggesting a partial run, verify the dependencies are met — each
skill's pre-flight checks will warn about missing prerequisites, but
Claude should proactively suggest the right sequence.
