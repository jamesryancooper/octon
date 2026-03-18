# Filesystem Discovery Service

Native-first query plane for graph traversal and progressive discovery over snapshot artifacts.

## Purpose

- Expose read-only `kg.*` traversal over deterministic snapshot artifacts.
- Support progressive disclosure workflows via `discover.*` operations.
- Keep graph/discovery behavior decoupled from snapshot write concerns.

## Core Artifacts

- `SERVICE.md` - service metadata contract.
- `contract.md` - normative query-plane behavior.
- `schema/*.json` - operation and artifact schemas.
- `rules/rules.yml` - policy and contract checks.
- `contracts/invariants.md` - non-negotiable invariants.
- `contracts/errors.yml` - typed error semantics.
- `service.json` / `service.wasm` - runtime-native package.

## Operations

- Graph: `kg.get-node`, `kg.neighbors`, `kg.traverse`, `kg.resolve-to-file`
- Discovery: `discover.start`, `discover.expand`, `discover.explain`, `discover.resolve`

## Routing

Use `filesystem-discovery` directly for all graph/discovery operations.
