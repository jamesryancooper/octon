# Protocol Versioning

## Policy

Engine protocol/schema changes MUST use explicit versioning and MUST NOT silently redefine existing versions.

## Rules

- New incompatible protocol behavior requires a new version identifier.
- Existing version semantics are immutable once released.
- Runtime validation must reject unsupported protocol versions (fail closed).
