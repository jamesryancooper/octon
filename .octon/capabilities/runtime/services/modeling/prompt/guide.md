# Prompt — Harness-Native Compilation Service

Prompt compiles structured requests into deterministic prompt payloads without external package dependencies.

## Purpose

- Normalize prompt inputs (`promptId`, `variables`, options).
- Render deterministic prompt content.
- Emit chat-ready `messages`.
- Provide approximate token estimates and optional SHA-256 hash.

## Inputs and Outputs

- Input schema: `schema/input.schema.json`
- Output schema: `schema/output.schema.json`

## Operation

- `compile`

## Policy

- Rules: `prompt-exists`, `variables-valid`, `within-context-window`
- Enforcement: `block`
- Fail-closed: `true`

## Runtime

- Entrypoint: `impl/prompt.sh`
- Required runtime tools: `jq`, `shasum`, POSIX shell utilities

## Contract Artifacts

- Invariants: `contracts/invariants.md`
- Errors: `contracts/errors.yml`
- Rules: `rules/rules.yml`
- Fixtures: `fixtures/`
- Compatibility: `compatibility.yml`
- Generation provenance: `impl/generated.manifest.json`
