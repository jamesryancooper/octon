# Filesystem Snapshot Service

Native-first writer plane for filesystem reads plus deterministic snapshot lifecycle operations.

## Purpose

- Provide bounded `fs.*` reads for agent tooling.
- Build, diff, and select deterministic snapshot artifacts.
- Publish snapshot state atomically for downstream query/discovery services.

## Core Artifacts

- `SERVICE.md` - service metadata contract.
- `contract.md` - normative writer-plane behavior.
- `schema/*.json` - operation and artifact schemas.
- `rules/rules.yml` - policy and contract checks.
- `contracts/invariants.md` - non-negotiable invariants.
- `contracts/errors.yml` - typed error semantics.
- `service.json` / `service.wasm` - runtime-native package.

## Operations

- Filesystem: `fs.list`, `fs.read`, `fs.stat`, `fs.search`
- Snapshot: `snapshot.build`, `snapshot.diff`, `snapshot.get-current`

## Routing

Use `filesystem-snapshot` directly for all writer-plane operations.
