# Instruction-Layer Precedence Contract (ENGINE-GOV-002)

## Scope

Defines how instruction layers are modeled for governance, policy evaluation,
and explainable receipts.

This contract governs observable/local instruction sources. Upstream provider
or hidden system layers that are not observable at runtime are represented as
`visibility: partial` in receipts.

## Precedence Model

Instruction precedence is:

1. Provider
2. System
3. Developer
4. User

Lower-precedence layers MUST NOT override higher-precedence layers.

## Developer-Layer Governance

1. Developer-layer instruction sources MUST be explicitly mapped as approved
   artifacts.
2. Unapproved developer-layer artifacts MUST be rejected by policy in strict
   enforcement mode.
3. Developer-layer artifacts are optional and SHOULD be minimal, concrete, and
   tied to recurring failures.

## Receipt and Manifest Requirements

Material runs MUST emit an instruction-layer manifest that includes, at
minimum:

- `layer_id`
- `source`
- `sha256`
- `bytes`
- `visibility`

Material policy receipts MUST include a layer summary so investigations can
attribute steering behavior to a specific instruction source.

## Failure Mode

If precedence resolution is ambiguous or required layer metadata is missing,
policy enforcement MUST fail closed.
