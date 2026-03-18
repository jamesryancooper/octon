# Guard — Harness-Native Safety Service

Guard performs deterministic content safety checks inside the harness runtime.

## Purpose

- Detect prompt injection and hallucination markers.
- Detect secret and PII leakage patterns.
- Detect unsafe code constructs.
- Provide optional sanitization output.

## Inputs and Outputs

- Input schema: `schema/input.schema.json`
- Output schema: `schema/output.schema.json`

## Operations

- `check`: evaluate content and return check results plus summary.
- `sanitize`: return redacted output when patterns match.

## Policy

- Rules: `no-secrets`, `no-pii`, `no-injection`
- Enforcement: `block`
- Fail-closed: `true`

## Runtime

- Entrypoint: `impl/guard.sh`
- Required runtime tools: `jq`, `grep`, `sed`

## Contract Artifacts

- Invariants: `contracts/invariants.md`
- Errors: `contracts/errors.yml`
- Rules: `rules/rules.yml`
- Fixtures: `fixtures/`
- Compatibility: `compatibility.yml`
- Generation provenance: `impl/generated.manifest.json`
