# File Change Map

## Framework contracts

- `framework/engine/runtime/spec/octon-compatibility-profile-v1.schema.json`
- `framework/engine/runtime/spec/external-project-adoption-v1.md`
- `framework/engine/runtime/spec/portable-proof-bundle-v1.schema.json`
- `framework/engine/runtime/spec/attestation-envelope-v1.schema.json`
- `framework/engine/runtime/spec/proof-acceptance-v1.schema.json`
- `framework/engine/runtime/spec/trust-domain-v1.schema.json`
- `framework/engine/runtime/spec/federation-compact-v1.schema.json` as structural hook
- `framework/engine/runtime/spec/delegated-authority-lease-v1.schema.json` as structural hook
- `framework/engine/runtime/spec/cross-domain-decision-request-v1.schema.json` as structural hook
- `framework/engine/runtime/spec/certification-profile-v1.schema.json` as structural hook
- `framework/engine/runtime/spec/federation-ledger-v1.schema.json` as structural hook

## Practices

- `framework/orchestration/practices/octon-adoption-standards.md`
- `framework/orchestration/practices/federated-proof-interop-standards.md`

## Instance authority

- `instance/governance/trust/compatibility-profile.yml`
- `instance/governance/trust/registry.yml`
- `instance/governance/trust/policies/proof-bundle-acceptance.yml`
- `instance/governance/trust/policies/attestation-acceptance.yml`
- `instance/governance/trust/policies/external-project-adoption.yml`

## State and generated

- `state/control/trust/**`
- `state/evidence/trust/**`
- `state/continuity/trust/**`
- `generated/cognition/projections/materialized/trust/**`

## Runtime / CLI

- `octon compatibility inspect`
- `octon compatibility profile`
- `octon adopt`
- `octon proof export/import`
- `octon attest verify/accept/reject`
- `octon federation status/ledger`
