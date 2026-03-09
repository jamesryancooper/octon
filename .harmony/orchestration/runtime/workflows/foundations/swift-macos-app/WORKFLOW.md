---
name: "swift-macos-app-foundation"
description: "Orchestrate the six Swift macOS app foundation skills in dependency order: scaffold-package first, then data-layer / daemon-service in parallel, then test-harness, then cli-interface, then contributor-guide last. Supports partial runs and resume after interruption."
steps:
  - id: "gather-input"
    file: "01-gather-input.md"
    description: "gather-input"
  - id: "scaffold-package"
    file: "02-scaffold-package.md"
    description: "scaffold-package"
  - id: "parallel-middle"
    file: "03-parallel-middle.md"
    description: "parallel-middle"
  - id: "test-harness"
    file: "04-test-harness.md"
    description: "test-harness"
  - id: "cli-interface"
    file: "05-cli-interface.md"
    description: "cli-interface"
  - id: "contributor-guide"
    file: "06-contributor-guide.md"
    description: "contributor-guide"
  - id: "smoke-test"
    file: "07-smoke-test.md"
    description: "smoke-test"
  - id: "verify"
    file: "08-verify.md"
    description: "verify"
---

# Swift Macos App Foundation

_Generated projection from canonical pipeline `swift-macos-app-foundation`._

## Usage

```text
/swift-macos-app-foundation
```

## Target

This projection wraps the canonical pipeline `swift-macos-app-foundation` for staged human review and slash-facing compatibility.

## Prerequisites

- Required pipeline inputs are available.
- Canonical pipeline assets exist under `.harmony/orchestration/runtime/pipelines/foundations/swift-macos-app`.
- External runtime dependencies required by the target project are available.

## Parameters

- `project_name` (text, required=true): Project name (PascalCase for modules)
- `description` (text, required=true): One-line project description
- `swift_version` (text, required=true), default=`5.9`: Swift version (e.g., 5.9, 6.0)
- `macos_target` (text, required=true), default=`14`: macOS deployment target (e.g., 14, 15)
- `dependencies` (text, required=false): Dependencies: grdb, yams, argument-parser, async-http-client, swift-graph, ulid
- `skip` (text, required=false): Comma-separated skill IDs to skip

## Failure Conditions

- Required inputs are missing or invalid.
- The backing canonical pipeline contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `package_manifest` -> `Package.swift`: Swift Package Manager manifest
- `source_tree` -> `Sources/{{PROJECT_NAME}}/`: Complete Swift source module structure
- `test_suite` -> `Tests/{{PROJECT_NAME}}Tests/`: XCTest test suites and fixtures
- `agent_doc` -> `CLAUDE.md`: AI agent orientation document

## Steps

1. [gather-input](./01-gather-input.md)
2. [scaffold-package](./02-scaffold-package.md)
3. [parallel-middle](./03-parallel-middle.md)
4. [test-harness](./04-test-harness.md)
5. [cli-interface](./05-cli-interface.md)
6. [contributor-guide](./06-contributor-guide.md)
7. [smoke-test](./07-smoke-test.md)
8. [verify](./08-verify.md)

## Verification Gate

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

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical pipeline `swift-macos-app-foundation` |

## References

- Canonical pipeline: `.harmony/orchestration/runtime/pipelines/foundations/swift-macos-app/`
