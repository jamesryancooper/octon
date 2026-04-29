# Source of Truth Map

## Proposal-local lifecycle authority

1. `proposal.yml`
2. `architecture-proposal.yml`

These govern the proposal lifecycle only. They are not runtime authority.

## Durable promotion targets

If accepted, durable implementation must land in:

- `framework/**`: portable contracts, schemas, standards, validators, runtime specs.
- `instance/**`: repo-specific trust policy, compatibility profile, trust registry, accepted issuers, local adoption posture.
- `state/control/**`: operational truth for imported proof acceptance, attestation status, compatibility inspection status, revocation state.
- `state/evidence/**`: retained proof for compatibility inspections, adoption scans, proof imports, attestation verification, redaction/freshness checks.
- `state/continuity/**`: resumable external project and trust-review continuity.
- `generated/**`: derived trust/compatibility read models only.
- `inputs/**`: this proposal packet and exploratory support material only.

## Existing repo anchors

- `.octon/README.md`: super-root and root discipline.
- `.octon/octon.yml`: portability profiles and fail-closed policies.
- `.octon/framework/cognition/_meta/architecture/specification.md`: structural contract narrative.
- `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`: proposal lifecycle and non-canonical rule.
- `.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md`: architecture proposal requirements.
- `.octon/framework/engine/runtime/spec/execution-authorization-v1.md`: material execution boundary.
- `.octon/instance/governance/support-targets.yml`: bounded-admitted-finite support model and generated no-widening.
