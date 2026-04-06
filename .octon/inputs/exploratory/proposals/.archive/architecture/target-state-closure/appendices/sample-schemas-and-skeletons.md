# Sample Schemas and Skeletons

This appendix provides field-level outlines and representative YAML skeletons for the normalized contracts introduced by the packet.

## 1. Mission Charter v1

```yaml
schema_version: octon-mission-charter-v1
mission_id: mission-autonomy-live-validation
version: 3.0.0
mission_class: live-validation
owner_ref: operator://octon-maintainers
workspace_refs:
  - charter://workspace/current
allowed_run_classes:
  - observe-and-read
  - repo-consequential
default_support_tiers:
  - tuple://repo-local-governed/repo-consequential/reference-owned/english-primary
autonomy_class: reversible-governed
protected_zones:
  - .octon/inputs/**
scope_refs:
  - scope://octon-harness
approval_policy_ref: policy://repo-consequential-default
quorum_policy_ref: quorum://default-acp2
revocation_policy_ref: revocation-policy://default
continuity_root_ref: state://continuity/missions/mission-autonomy-live-validation
retention_expectations:
  replay_required: true
  measurements_required: true
retirement_triggers:
  - release lineage supersedes mission support role
```

## 2. QuorumPolicy v1

```yaml
schema_version: octon-quorum-policy-v1
quorum_policy_id: default-acp2
required: 2
rules:
  - role: operator
    count: 1
  - role: governance-owner
    count: 1
applicable_action_classes:
  - repo-consequential
  - privileged-reversible
support_tiers:
  - tuple://repo-local-governed/*
escalation_paths:
  - operator://octon-maintainers
```

## 3. Run Contract v3

```yaml
schema_version: octon-run-contract-v3
run_id: run-2026-04-07T10-00-00Z-example
status: drafted
workflow_mode: autonomous
objective_refs:
  workspace: charter://workspace/current
  mission: mission://mission-autonomy-live-validation@3.0.0
objective_summary: Reconcile mission control and disclosure artifacts.
scope_in:
  - .octon/state/control/execution/missions/**
  - .octon/state/evidence/**
scope_out:
  - public_release
done_when:
  - release bundle is coherent
acceptance_criteria:
  - structural_pass
  - governance_pass
  - recovery_pass
materiality: consequential
risk_class: ACP-1
reversibility_class: reversible
requested_capabilities:
  - git.read
  - git.write
requested_capability_packs:
  - repo
  - git
  - shell
protected_zone_scope:
  - .octon/inputs/**
support_target_ref: tuple://repo-local-governed/repo-consequential/reference-owned/english-primary
support_target_tuple:
  model_tier: repo-local-governed
  workload_tier: repo-consequential
  language_resource_tier: reference-owned
  locale_tier: english-primary
mission_id: mission-autonomy-live-validation
requires_mission: true
required_approvals:
  - approval-request-01
required_evidence:
  - execution_receipt
  - assurance_reports
  - run_card
retry_class: bounded_retry
rollback_posture_ref: rollback://run-2026-04-07T10-00-00Z-example
stage_attempt_root: state://control/execution/runs/run-.../stage-attempts
checkpoint_root: state://control/execution/runs/run-.../checkpoints
continuity_root_ref: state://continuity/runs/run-...
authority_bundle_ref: evidence://control/execution/authority-grant-bundle-...
run_manifest_ref: state://control/execution/runs/run-.../run-manifest.yml
runtime_state_ref: state://control/execution/runs/run-.../runtime-state.yml
run_card_ref: evidence://disclosure/runs/run-.../run-card.yml
```

## 4. Evidence Classification v2

```yaml
schema_version: octon-evidence-classification-v2
run_id: run-2026-04-07T10-00-00Z-example
generated_at: 2026-04-07T10:14:32Z
class_a:
  - evidence://control/execution/authority-decision-...
  - evidence://control/execution/authority-grant-bundle-...
  - evidence://control/execution/policy-receipt-...
class_b:
  - evidence://runs/run-.../retained-run-evidence.yml
  - evidence://runs/run-.../replay/manifest.yml
  - evidence://runs/run-.../measurements/summary.yml
  - evidence://disclosure/runs/run-.../run-card.yml
class_c:
  - object://replay/run-.../trace-01.ndjson.zst
coverage_status: complete
retention_policy_ref: retention://default
external_index_ref: evidence://external-index/run-....yml
missing_artifacts: []
notes: []
```

## 5. Release Bundle Manifest v1

```yaml
schema_version: octon-release-bundle-manifest-v1
release_id: release-2026-04-07
generated_at: 2026-04-07T12:00:00Z
generator_versions:
  closure_bundle: 1
  harness_card: 1
  run_card: 1
validator_versions:
  g0_constitution: 1
  g1_run_contract: 1
  g5_consistency: 1
authored_input_digests:
  charter: sha256:...
  support_targets: sha256:...
  release_lineage: sha256:...
proof_bundle_runs:
  - run://repo-observe-read-01
  - run://repo-consequential-01
bundle_contents:
  - harness-card.yml
  - closure/closure-summary.yml
  - closure/closure-certificate.yml
```

## 6. Retirement Registry Entry

```yaml
retirement_id: retire-architect-kernel-role
surface_ref: .octon/framework/agency/runtime/agents/architect
surface_class: legacy-kernel-persona
current_status: transitional
why_transitional: preserved only for compatibility and historical context
retirement_trigger: no active ingress/runtime reference remains
owner: team://octon-architecture
ablation_required: true
ablation_receipt_ref: evidence://validation/publication/build-to-delete/ablation-receipts/retire-architect-kernel-role.yml
target_removal_wave: phase-6
residual_risk_if_retained: continued ambiguity about active kernel identity
```
