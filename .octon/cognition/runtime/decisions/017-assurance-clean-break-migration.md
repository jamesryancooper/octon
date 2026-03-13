# ADR 017: Assurance Clean-Break Migration

## Status
Accepted

## Date
2026-02-18

## Superseding Links (Historical Terminology)

- Superseded by: `040-principles-charter-successor-v2026-02-24.md`
- Scope of supersession: legacy path-token references only; migration decision remains accepted.

## Context

Octon's legitimacy layer evolved from `quality` checks to a broader
assurance model that includes standards, governance, and trust evidence.
Maintaining both `quality` and `assurance` domains in parallel would keep
semantic ambiguity and increase long-term contract risk.

## Decision

Adopt a clean-break migration from `quality` to `assurance` with no
compatibility layer.

1. Remove `.octon/quality/` from active source.
2. Treat `.octon/assurance/` as the only canonical legitimacy domain.
3. Remove runtime and CI dependencies on legacy quality paths and tool names.
4. Publish migration notice with explicit breaking-change semantics and full
   old->new mappings.
5. Use `.octon/runtime/crates/Cargo.toml` `workspace.package.version` as the
   canonical release version source for this repository.
6. Apply a major version bump for the clean break: `0.1.0` -> `1.0.0`.
7. Freeze unrelated harness contract changes during the migration PR scope.

## Consequences

- External consumers must update path references and automation bindings from
  `quality` to `assurance`.
- Compatibility shims are intentionally not provided.
- Release communication must include migration mapping and breaking-change
  guidance.
- Future legitimacy work is centralized in the Assurance domain contract.
