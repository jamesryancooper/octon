# Spec — Native Planning Specification Service

Spec is the native planning specification service for initializing, validating,
rendering, and diagramming Octon spec artifacts. It is implemented in-house
and does not require GitHub Spec Kit as a runtime dependency.

## Core Operations

- `init`
  - Creates deterministic `spec.md`, `plan.md`, and `tasks.md` scaffolds.
- `validate`
  - Performs structural checks over discovered spec artifacts.
  - Never mutates files.
- `render`
  - Produces deterministic summary artifacts for downstream planning.
- `diagram`
  - Produces deterministic Mermaid flow representation for spec lifecycle.

## Input and Output Contracts

- Input schema: `schema/input.schema.json`
- Output schema: `schema/output.schema.json`
- Invariants: `contracts/invariants.md`
- Errors: `contracts/errors.yml`

## Native-First Notes

- No Python runtime is required.
- No `speckit` executable is required for core operation.
- Existing Spec Kit artifacts can still be consumed if already present on disk,
  but they are treated as optional external inputs.

## Example

```bash
cat <<'JSON' | .octon/capabilities/runtime/services/planning/spec/impl/spec.sh
{"command":"validate","targetPath":".octon","dryRun":true}
JSON
```
