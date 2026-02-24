# Harmony Policy Interface (v1)

> **Normative:** This file defines the engine-owned v1 launch interface for
> policy evaluation and validation.

## Purpose

Provide a stable contract boundary for policy execution so `capabilities/`
depends on engine interfaces, not engine implementation internals.

## Launcher Endpoints

- POSIX: `/.harmony/engine/runtime/policy`
- Windows: `/.harmony/engine/runtime/policy.cmd`

These launchers are the canonical invocation boundary for policy operations.

## Engine Contract

- Interface owner: `engine/runtime/**`
- Runtime implementation owner: `engine/runtime/crates/policy_engine/**`
- Caller contract: invoke launchers only; do not couple to crate paths or
  build paths.
- Launcher behavior defaults are runtime-configured in:
  - `engine/runtime/config/policy-interface.yml`

## Supported Command Surface (v1)

The launcher forwards to `harmony-policy` and supports these command groups:

- `preflight`
- `enforce`
- `acp-preflight`
- `acp-enforce`
- `receipt-validate`
- `grant-eval`
- `doctor`

Wrapper extension for `acp-enforce`:

- `--emit-receipt`
- `--run-id <id>` (requires `--request`)
- `--digest` (requires `--emit-receipt`)

## Receipt And Digest Contracts

ACP receipt/digest artifacts emitted by wrapper-assisted `acp-enforce`
evaluations must follow:

- Receipt schema: `engine/runtime/spec/policy-receipt-v1.schema.json`
- Digest format: `engine/runtime/spec/policy-digest-v1.md`

Decision outputs for `ALLOW`, `STAGE_ONLY`, and `DENY` must include:

- machine-readable `reason_codes`
- human-readable `remediation` guidance

## Exit Codes

- `0` - allow/success
- `13` - deny by policy decision
- `2` - contract/runtime invocation error

## Environment

- `HARMONY_POLICY_BIN`: optional explicit binary path override.
- `HARMONY_POLICY_MODE_OVERRIDE`: optional runtime mode override exported by
  launcher when rollout-mode state is present.

## Versioning

- Incompatible interface changes require a new versioned spec file
  (`policy-interface-vN.md`) and corresponding launcher/runtime updates.
- Existing v1 semantics are immutable once released.
