---
name: swift-macos-app-foundation
description: >
  Orchestrate the six Swift macOS app foundation skills in dependency order:
  scaffold-package first, then data-layer / daemon-service in parallel,
  then test-harness, then cli-interface, then contributor-guide last.
  Supports partial runs and resume after interruption.
steps:
  - id: gather-input
    file: 01-gather-input.md
    description: Collect project name, description, Swift version, platform target, and dependencies.
  - id: scaffold-package
    file: 02-scaffold-package.md
    description: Run /scaffold-package to create Package.swift and module structure.
  - id: parallel-middle
    file: 03-parallel-middle.md
    description: Run /data-layer and /daemon-service (independent of each other).
  - id: test-harness
    file: 04-test-harness.md
    description: Run /test-harness after data-layer and daemon-service are in place.
  - id: cli-interface
    file: 05-cli-interface.md
    description: Run /cli-interface after scaffold-package and optionally data-layer/daemon.
  - id: contributor-guide
    file: 06-contributor-guide.md
    description: Run /contributor-guide last, reading all outputs.
  - id: smoke-test
    file: 07-smoke-test.md
    description: Run swift build && swift test to validate the generated project.
  - id: verify
    file: 08-verify.md
    description: Validate workflow executed successfully.
# --- Harmony extensions ---
access: human
version: "1.0.0"
depends_on: []
checkpoints:
  enabled: true
  storage: ".harmony/continuity/checkpoints/"
parallel_steps:
  - group: "middle-tier"
    steps: ["03-parallel-middle"]
    join_at: "04-test-harness"
---

# Swift macOS App Foundation: Overview

Orchestrate a full Swift macOS application scaffold by running the six
foundation skills in dependency order — from empty directory to a
building, tested, documented project.

## Usage

```text
swift-macos-app-foundation <project-name> "<description>" <swift-version> <macos-target> <dependencies...>
```

**Examples:**

```text
# Minimal CLI tool (no database or daemon)
swift-macos-app-foundation MyTool "A developer utility" 5.9 14 argument-parser

# Full stack with persistence and daemon
swift-macos-app-foundation FSGraph "Local-first semantic file system" 5.9 14 grdb yams argument-parser async-http-client ulid swift-graph

# Partial run — add persistence to existing project
swift-macos-app-foundation FSGraph --skip scaffold-package,daemon-service,cli-interface,contributor-guide
```

## Target

A new or existing directory where a Swift macOS application will be
scaffolded. The workflow creates or extends: `Package.swift`, `Sources/`,
`Tests/`, `Docs/`, `Schemas/`, `Resources/`, `.github/`, `CLAUDE.md`,
`CONTRIBUTING.md`, and CI config.

## Prerequisites

- Swift 5.9+ / 6.x toolchain available on PATH
- Xcode or Swift command-line tools installed
- macOS 14+ (Sonoma or later)
- Python 3.11+ (for schema validation tests, optional)

## Failure Conditions

- No project name provided -> STOP, ask user
- `Package.swift` exists with conflicting product names -> STOP, confirm with user
- `/scaffold-package` fails -> STOP, nothing else can proceed
- A middle-tier skill fails -> CONTINUE with remaining skills, document failure
- `/test-harness` fails -> CONTINUE to cli-interface, document failure
- `swift build` fails -> document failures, do NOT block contributor-guide

## Steps

1. [Gather Input](./01-gather-input.md) - Collect and validate arguments
2. [Scaffold Package](./02-scaffold-package.md) - Create package structure
3. [Parallel Middle](./03-parallel-middle.md) - Data layer and daemon service
4. [Test Harness](./04-test-harness.md) - Testing infrastructure
5. [CLI Interface](./05-cli-interface.md) - Command-line interface
6. [Contributor Guide](./06-contributor-guide.md) - Documentation generation
7. [Smoke Test](./07-smoke-test.md) - Run `swift build && swift test`
8. [Verify](./08-verify.md) - Validate workflow executed successfully

## Dependency Diagram

```text
01 gather-input
       │
       ▼
02 scaffold-package
       │
  ┌────┴────┐
  ▼         ▼
 03a       03b        ← 03 parallel-middle
 data     daemon
  └────┬────┘
       ▼
04 test-harness
       │
       ▼
05 cli-interface
       │
       ▼
06 contributor-guide
       │
       ▼
07 smoke-test
       │
       ▼
08 verify
```

## Verification Gate

Swift macOS App Foundation is NOT complete until:

- [ ] `Package.swift` exists with correct targets and dependencies
- [ ] `Sources/{PROJECT_NAME}/` tree exists with all standard modules
- [ ] `Sources/{PROJECT_NAME}/Database/` has GRDB actor and migrations (if data-layer ran)
- [ ] `Sources/{PROJECT_NAME}Daemon/` has daemon actor and intent queue (if daemon ran)
- [ ] `Tests/{PROJECT_NAME}Tests/` has XCTest suites
- [ ] `Sources/{PROJECT_NAME}CLI/main.swift` has ArgumentParser commands
- [ ] `CLAUDE.md` and `CONTRIBUTING.md` exist
- [ ] `swift build` succeeds (or failures are documented)
- [ ] Verification step passes

## Version History

| Version | Date       | Changes         |
| ------- | ---------- | --------------- |
| 1.0.0   | 2026-02-09 | Initial version |

## References

- **Foundation skill:** `.harmony/capabilities/runtime/skills/foundations/swift-macos-app/SKILL.md`
- **Child skills:** `.harmony/capabilities/runtime/skills/foundations/swift-macos-app/*/SKILL.md`
- **Workflow template:** `.harmony/orchestration/runtime/workflows/_scaffold/template/`
