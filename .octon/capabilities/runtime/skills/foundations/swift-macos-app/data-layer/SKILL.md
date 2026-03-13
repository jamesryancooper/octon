---
name: swift-data-layer
description: >
  Generate a SQLite persistence layer using GRDB.swift with actor-based
  concurrency: database actor, schema migrations, record types, and query
  helpers. Invoke with entity names, fields, and relationship definitions.
skill_sets: [specialist]
capabilities: [phased]
# Write scopes are explicit: workspace scaffolding plus skill log output.
allowed-tools: Read Grep Glob Edit Write(../../../**) Write(_ops/state/logs/*) Bash(mkdir)
---

# Data Layer

Generate a production-grade SQLite persistence layer using GRDB.swift
with actor isolation, WAL mode, and structured migrations.

## Arguments

`$ARGUMENTS` should include:

- **Entity names** and their fields (types, constraints, required vs optional)
- **Relationships** between entities (one-to-many, many-to-many)
- **Indexes** to create for query performance
- **Optional**: custom query methods beyond standard CRUD

Example: `files(id:ULID path:String contentHash:String? size:Int64 createdAt:Date) entities(id:ULID name:String kind:EntityKind) relationships(subjectId:ULID predicate:String objectId:ULID confidence:Double)`

## Pre-flight Checks

1. Read `Package.swift` to verify GRDB.swift is listed as a dependency.
2. Check if `Sources/{PROJECT_NAME}/Database/` exists beyond `.gitkeep`.
3. Read `Sources/{PROJECT_NAME}/Core/Types.swift` for existing domain types
   that map to database records.
4. Check if a database file exists to determine fresh vs migration scenario.

## Generation Steps

### Step 1: Database actor

Create `Sources/{PROJECT_NAME}/Database/DatabaseManager.swift`:

- `actor DatabaseManager` with a `DatabaseWriter` (GRDB).
- `init(path: URL)` creating/opening the database with WAL mode.
- `static let shared` singleton pattern or dependency injection.
- Foreign key enforcement enabled.
- Migration registration in initializer.

### Step 2: Schema migrations

Create `Sources/{PROJECT_NAME}/Database/Migrations.swift`:

- `struct DatabaseMigrator` with static `migrate(_ db: DatabaseWriter)`.
- Use GRDB's `DatabaseMigrator` with named migrations (`"v1.0-initial"`).
- Create tables for each declared entity with:
  - Primary keys (TEXT for ULIDs, INTEGER for auto-increment).
  - NOT NULL constraints on required fields.
  - DEFAULT values where appropriate.
  - Foreign key references for relationships.
  - Indexes on frequently-queried columns.
- WAL checkpoint configuration.

### Step 3: Record types

For each entity, create `Sources/{PROJECT_NAME}/Database/Records/{Entity}Record.swift`:

- `struct {Entity}Record: Codable, FetchableRecord, PersistableRecord` conformance.
- `static let databaseTableName = "{entities}"` (pluralized, snake_case).
- Column enum: `enum Columns: String, ColumnExpression`.
- Association definitions for relationships.
- `init(row: Row)` and encoding/decoding.

### Step 4: Query helpers

Create `Sources/{PROJECT_NAME}/Database/Queries/{Entity}Queries.swift`:

- Extension on `DatabaseManager` with typed query methods:
  - `func insert(_ record: {Entity}Record) async throws`
  - `func fetch(id: String) async throws -> {Entity}Record?`
  - `func fetchAll(filter: {Entity}Filter?) async throws -> [{Entity}Record]`
  - `func update(_ record: {Entity}Record) async throws`
  - `func delete(id: String) async throws`
- Request builders for complex queries using GRDB's query interface.
- Observation support via `ValueObservation` where appropriate.

### Step 5: Append-only audit log (optional)

If the project requires an immutable decision/event log:

Create `Sources/{PROJECT_NAME}/Database/AuditLog.swift`:

- JSONL (newline-delimited JSON) file writer.
- `struct AuditEntry: Codable` with timestamp, action, details, confidence.
- `func append(_ entry: AuditEntry) throws` — file-append, never modify.
- Path configurable via `AppConfiguration`.

### Step 6: Database configuration

Update `Sources/{PROJECT_NAME}/Config/Configuration.swift`:

- Add `databasePath: URL` field (default: `dataDirectory/graph.db`).
- Add `walMode: Bool` field (default: `true`).
- Add `foreignKeys: Bool` field (default: `true`).

## Edge Cases

- If `Database/` already has files beyond `.gitkeep`, read them and only add missing components.
- If entities overlap with existing `Core/Types.swift` types, use those types
  rather than creating duplicates — add `FetchableRecord` conformance via extensions.
- If GRDB is not in `Package.swift`, warn that `/scaffold-package` should add it.

## Cross-references

- **Depends on**: `/scaffold-package` (for Package.swift and module structure)
- **Feeds into**: `/test-harness` (for database test fixtures), `/daemon-service` (for persistence)

## When to Use

- Building actor-safe GRDB/SQLite persistence scaffolding for a Swift macOS application
- Need repeatable scaffolding that follows Octon foundation conventions

## Boundaries

- Does not perform in-place migrations of existing implementations
- Does not install runtime dependencies outside generated project files

## When to Escalate

- Project requires a non-standard directory topology or naming scheme
- Existing code must be migrated or reconciled instead of scaffolded from templates
