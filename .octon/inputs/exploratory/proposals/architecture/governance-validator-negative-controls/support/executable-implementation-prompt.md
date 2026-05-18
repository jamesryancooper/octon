# Executable Implementation Prompt

implementation_prompt_id: governance-validator-negative-controls-implementation-prompt-2026-05-18
proposal_path: .octon/inputs/exploratory/proposals/architecture/governance-validator-negative-controls
route_id: run-packet-implementation
status: operational-aid
generated_at: 2026-05-18T16:18:02Z

This prompt is an operational implementation aid for the accepted proposal
packet. It does not approve execution, widen scope, create authority, replace
run contracts, replace proposal manifests, or substitute for retained evidence.
Validators enforce governance boundaries; generated outputs cannot grant
authority.

## Prompt Generation Gate Receipt

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/governance-validator-negative-controls --require-implementation-authorization
```

Observed result at prompt-generation time: `errors=0 warnings=0`.

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: add delegated-governance validator coverage and negative
  controls only after enough domain children provide concrete surfaces
- transitional exception: not authorized

## Mandatory Preflight

Confirm the authority-engine, mission/runtime, connector, run-health, and
workflow/capability child packets have implemented evidence or explicit
retained outputs sufficient to attach validator hooks. Then run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/governance-validator-negative-controls
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/governance-validator-negative-controls
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/governance-validator-negative-controls --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/governance-validator-negative-controls
```

Refuse implementation if predecessor domain surfaces are not concrete enough to
validate without guessing.

## In Scope

Durable edits may touch only:

- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/framework/constitution/contracts/authority/`

Expected durable work:

1. Use predecessor child outputs to identify concrete validator hooks.
2. Add positive checks for required proof, evidence gates, scope containment,
   authority-zone allowance, replay or compensation class, receipt retention,
   and fail-closed behavior.
3. Add negative controls for approval-default primitives, missing proof, stale
   digest, scope mismatch, generated-output authority misuse, read-model
   authority misuse, child-authority takeover, unsupported mode, unsafe resume,
   policy override, governance mutation without typed exception, and external
   irreversible effects without explicit proof.
4. Ensure validators fail closed rather than silently falling back to generic
   human approval posture.
5. Add fixtures only where needed and only inside declared target families.

## Out Of Scope

Do not implement the domain migrations themselves in this child. Do not add
validators for surfaces that predecessor packets have not made concrete. Do
not mutate generated projections or state/control truth. Do not change
`proposal.yml#status`.

## Required Evidence And Receipts

Retain evidence under:

```text
.octon/state/evidence/validation/proposals/governance-validator-negative-controls/<timestamp>/
```

Retain:

- predecessor-surface dependency receipt;
- delegated-governance validator run evidence;
- negative-control fixture and test outputs for every named failure class;
- contract validation receipt when authority contracts are touched;
- rollback posture for validator/test/contract changes.

Update:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

## Validation

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/governance-validator-negative-controls
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/governance-validator-negative-controls
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/governance-validator-negative-controls
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/governance-validator-negative-controls
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/governance-validator-negative-controls
```

Also run every validator and test introduced or touched by this packet.

## Rollback And Closeout Refusal

Rollback is revert of validator, test, fixture, and authority contract changes
from this packet. Refuse closeout or archive if any named negative control is
missing, if unsupported cases fall back to generic approval-required posture,
if validators rely on generated/read-model authority, or if
`support/implementation-conformance-review.md` and
`support/post-implementation-drift-churn-review.md` do not pass.
