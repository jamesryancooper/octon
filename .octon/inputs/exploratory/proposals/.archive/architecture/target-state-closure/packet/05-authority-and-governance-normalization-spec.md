# 05. Authority and Governance Normalization Spec

## 1. Goal

Preserve artifactized authority while removing the last remaining policy anchoring, set-file lifecycle ambiguity, and host-shaped leakage.

## 2. Preserve current family

Preserve these roots:

- `.octon/state/control/execution/approvals/requests/**`
- `.octon/state/control/execution/approvals/grants/**`
- `.octon/state/control/execution/exceptions/**`
- `.octon/state/control/execution/revocations/**`
- `.octon/state/evidence/control/execution/authority-decision-*.yml`
- `.octon/state/evidence/control/execution/authority-grant-bundle-*.yml`

## 3. Standalone QuorumPolicy

Create:
- `.octon/framework/constitution/contracts/authority/quorum-policy-v1.schema.json`
- `.octon/instance/governance/contracts/quorum-policies/default.yml`

Migration:
- keep `mission-autonomy.yml` as the authored operational policy
- remove it as the canonical home of quorum semantics
- make it reference `quorum_policy_ref`

Required ApprovalRequest / ApprovalGrant / DecisionArtifact fields:
- `quorum_policy_ref`
- `required_signers`
- `quorum_status`

## 4. Route lattice

Canonical values:
- `allow`
- `stage_only`
- `escalate`
- `deny`

Required route rules:
- unsupported tuple -> `deny`
- missing required mission / missing required evidence -> `stage_only` or `deny` according to policy
- irreversible or privileged work without approval -> `escalate`
- all admitted and satisfied -> `allow`

Route is always resolved by the authority engine, never by host-native status.

## 5. Lease normalization

Target canonical root:
- `.octon/state/control/execution/exceptions/leases/<lease-id>.yml`

Optional generated index:
- `.octon/state/control/execution/exceptions/index.yml`

Each lease file must declare:
- `lease_id`
- `subject_ref`
- `relaxed_rule`
- `justification`
- `scope`
- `issued_by`
- `issued_at`
- `expires_at`
- `conditions`
- `renewal_policy`
- `retirement_trigger`

## 6. Revocation normalization

Target canonical root:
- `.octon/state/control/execution/revocations/<subject-class>/<revocation-id>.yml`

Optional generated index:
- `.octon/state/control/execution/revocations/index.yml`

Each revocation file must declare:
- `revocation_id`
- `subject_ref`
- `reason`
- `issued_by`
- `effective_at`
- `required_safing_action`
- `status`

## 7. Host-projection non-authority

Create projection evidence root:
- `.octon/state/evidence/control/host-projections/<adapter-id>/<projection-id>.yml`

Purpose:
- preserve raw host signals
- make GitHub labels/comments/checks auditable as inputs
- prohibit silent promotion of host signals into authority

Rule:
- host projection receipts may inform routing
- only canonical Approval/Grant/Lease/Revocation/Decision artifacts may authorize execution

## 8. Protected-zone and irreversible-action governance

Protected zones and one-way-door actions must be evaluated against:
- support-target matrix
- run reversibility class
- mission charter
- approval / exception / revocation state

No host adapter may override these checks.

## 9. Validators and generators

Create under `.octon/framework/assurance/runtime/_ops/scripts/`:

- `validate-quorum-policy-bindings.sh`
- `validate-authority-artifact-parity.sh`
- `validate-host-projection-non-authority.sh`
- `migrate-lease-set-file.sh`
- `migrate-revocation-set-file.sh`

## 10. Migration

1. Introduce quorum-policy contract and default instance declaration.
2. Rebind mission-autonomy policy to quorum-policy refs.
3. Convert lease set-file entries into per-file artifacts.
4. Convert revocation set-file entries into per-file artifacts.
5. Keep generated index files if ergonomically useful.
6. Introduce host projection receipts.
7. Make authority engine consume projection receipts and emit canonical DecisionArtifacts.

## 11. Acceptance criteria

- QuorumPolicy is a first-class constitutional authority contract
- leases and revocations are per-artifact lifecycle units
- no host-native surface can authorize anything by itself
- every authority decision agrees with support-target, run contract, manifest, and RunCard
- route resolution is deterministic and fail-closed
