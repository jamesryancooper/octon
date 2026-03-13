---
name: swift-test-harness
description: >
  Generate testing infrastructure for a Swift macOS app: XCTest suites,
  in-memory database fixtures, mock actors, CI workflow, and schema
  validation tests. Invoke with the project name and test categories.
skill_sets: [specialist]
capabilities: [phased, external-dependent]
# Write scopes are explicit: workspace scaffolding plus skill log output.
allowed-tools: Read Grep Glob Edit Write(../../../**) Write(_ops/state/logs/*) Bash(mkdir) Bash(swift)
---

# Test Harness

Generate a structured testing pyramid: `Tests/{PROJECT_NAME}Tests/` for
unit tests, database integration tests, and schema validation — with
shared fixtures, mock actors, and CI configuration.

## Arguments

`$ARGUMENTS` should include:

- **Project name** (to discover package paths and targets)
- **Test categories** (e.g., "types, database, daemon, cli") or `auto-discover`
  to scan `Sources/` for testable modules
- **Optional**: specific test scenarios to generate beyond defaults

Example: `FSGraph auto-discover`

## Pre-flight Checks

1. Read `Package.swift` to discover test targets and verify XCTest dependency.
2. Scan `Sources/{PROJECT_NAME}/Core/Types.swift` for domain types to test.
3. Scan `Sources/{PROJECT_NAME}/Database/` for GRDB record types and migrations.
4. Scan `Sources/{PROJECT_NAME}Daemon/` for actors and protocols.
5. Check for existing `Tests/` directory and test files to avoid overwriting.

## Generation Steps

### Step 1: Directory structure

Create these directories if they do not exist:

```
Tests/
├── {PROJECT_NAME}Tests/
│   ├── Core/
│   │   └── TypesTests.swift
│   ├── Database/
│   │   ├── MigrationTests.swift
│   │   └── RecordTests.swift
│   ├── Daemon/
│   │   └── IntentQueueTests.swift
│   └── Fixtures/
│       ├── TestFixtures.swift
│       └── SampleData/
│           └── test-ontology.yaml
├── IntegrationTests/
│   └── .gitkeep
└── fixtures/
    └── .gitkeep
```

### Step 2: Test fixtures

Create `Tests/{PROJECT_NAME}Tests/Fixtures/TestFixtures.swift`:

- `enum TestFixtures` with static factory methods for each domain type.
- In-memory database helper:
  ```swift
  static func makeInMemoryDatabase() throws -> DatabaseQueue {
      let db = try DatabaseQueue()
      try DatabaseMigrator.migrate(db)
      return db
  }
  ```
- Sample data generators for each record type.
- Temporary directory helper for file-based tests.

### Step 3: Core type tests

Create `Tests/{PROJECT_NAME}Tests/Core/TypesTests.swift`:

For each enum and struct in `Core/Types.swift`:
- Test raw value round-tripping for enums.
- Test Codable encoding/decoding for structs.
- Test Equatable conformance.
- Test edge cases (empty strings, nil optionals, boundary values).

### Step 4: Database tests

Create `Tests/{PROJECT_NAME}Tests/Database/MigrationTests.swift`:

- Test migration creates all expected tables.
- Test migration is idempotent (running twice does not error).
- Test foreign key constraints are enforced.
- Test WAL mode is enabled.

Create `Tests/{PROJECT_NAME}Tests/Database/RecordTests.swift`:

For each GRDB record type:
- Test insert and fetch by ID.
- Test update modifies the correct row.
- Test delete removes the record.
- Test query filters return expected results.
- Test relationship queries (joins, associations).

### Step 5: Daemon tests

Create `Tests/{PROJECT_NAME}Tests/Daemon/IntentQueueTests.swift`:

- Test enqueue and dequeue ordering (priority-based).
- Test status transitions (pending → processing → completed/failed).
- Test retry logic (failed intents with attempts < maxRetries).
- Test concurrent access via actor isolation.

### Step 6: Schema validation tests (optional)

If JSON Schema files exist in `Schemas/`:

Create `tests/test_spec_conformance.py` (Python):

- Use `jsonschema` to validate YAML/JSON config files against schemas.
- Parametrize tests across all schema files.
- Run via: `pytest tests/test_spec_conformance.py`

Create `requirements-dev.txt`:

```
pytest>=7.0
pyyaml>=6.0
jsonschema>=4.0
```

### Step 7: CI workflow

Create `ci.yml` in `.github/workflows/`:

```yaml
name: CI
on: [push, pull_request]
jobs:
  build-and-test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      - name: Build
        run: swift build
      - name: Test
        run: swift test
  spec-conformance:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - run: pip install -r requirements-dev.txt
      - run: pytest tests/
```

## Edge Cases

- If test files already exist, do not overwrite — only add new test methods.
- If no database layer exists, skip database test generation and note that
  tests will be added when `/data-layer` is run.
- If no daemon exists, skip daemon test generation.
- Use in-memory databases for all database tests (no file I/O).

## Cross-references

- **Depends on**: `/scaffold-package` (package structure), `/data-layer` (record types), `/daemon-service` (actors)
- **Feeds into**: `/contributor-guide` (for test documentation and CI config)

## When to Use

- Building XCTest and fixture scaffolding for Swift macOS modules and persistence layers
- Need repeatable scaffolding that follows Octon foundation conventions

## Boundaries

- Does not perform in-place migrations of existing implementations
- Does not install runtime dependencies outside generated project files

## When to Escalate

- Project requires a non-standard directory topology or naming scheme
- Existing code must be migrated or reconciled instead of scaffolded from templates
