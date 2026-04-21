use super::*;
use anyhow::Context;
use octon_core::config::{ExecutorProfileConfig, RuntimeConfig};
use octon_core::errors::{ErrorCode, KernelError, Result as CoreResult};
use octon_core::execution_integrity::{
    evaluate_execution_budget, evaluate_network_egress, infer_provider_from_model,
    load_execution_budget_policy, load_execution_exception_leases, load_network_egress_policy,
    record_budget_consumption, write_execution_cost_evidence, BudgetCheckContext, BudgetDecision,
    NetworkEgressContext, NetworkEgressDecision,
};
use octon_core::policy::PolicyEngine;
use octon_core::registry::ServiceDescriptor;
use serde::{Deserialize, Serialize};
use serde_json::json;
use sha2::{Digest, Sha256};
use std::collections::{BTreeMap, BTreeSet};
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::sync::{Mutex, OnceLock};

mod tests {
use super::*;
use octon_core::config::{
    ExecutionGovernanceConfig, PolicyConfig, ReceiptRootsConfig, RuntimeConfig,
};
use std::fs;
use std::path::PathBuf;
use std::time::{SystemTime, UNIX_EPOCH};

fn support_targets_fixture(
    workload_id: &str,
    workload_label: &str,
    workload_default_route: &str,
) -> String {
    format!(
        "schema_version: \"octon-support-targets-v1\"\nowner: \"test\"\ndefault_route: \"deny\"\ngovernance_exclusions_ref: \".octon/instance/governance/exclusions/action-classes.yml\"\ntiers:\n  model:\n    - id: \"repo-local-governed\"\n      label: \"repo-local-governed\"\n      default_autonomy: \"bounded\"\n      description: \"fixture\"\n  workload:\n    - id: \"{workload_id}\"\n      label: \"{workload_label}\"\n      default_route: \"{workload_default_route}\"\n      description: \"fixture\"\n  language_resource:\n    - id: \"reference-owned\"\n      label: \"reference-owned\"\n      description: \"fixture\"\n  locale:\n    - id: \"english-primary\"\n      label: \"english-primary\"\n      description: \"fixture\"\ncompatibility_matrix:\n  - model_tier: \"repo-local-governed\"\n    workload_tier: \"{workload_id}\"\n    language_resource_tier: \"reference-owned\"\n    locale_tier: \"english-primary\"\n    support_status: \"supported\"\n    default_route: \"allow\"\n    requires_mission: false\n    allowed_capability_packs:\n      - \"repo\"\n      - \"shell\"\n      - \"telemetry\"\n      - \"browser\"\n      - \"api\"\n    required_evidence:\n      - \"authority-decision-artifact\"\nadapter_conformance_criteria:\n  - criterion_id: \"HOST-001\"\n    adapter_kind: \"host\"\n    description: \"fixture\"\n    required_evidence:\n      - \"authority-decision-artifact\"\n  - criterion_id: \"HOST-002\"\n    adapter_kind: \"host\"\n    description: \"fixture\"\n    required_evidence:\n      - \"instruction-layer-manifest\"\n  - criterion_id: \"MODEL-001\"\n    adapter_kind: \"model\"\n    description: \"fixture\"\n    required_evidence:\n      - \"authority-decision-artifact\"\n  - criterion_id: \"MODEL-002\"\n    adapter_kind: \"model\"\n    description: \"fixture\"\n    required_evidence:\n      - \"instruction-layer-manifest\"\n  - criterion_id: \"MODEL-003\"\n    adapter_kind: \"model\"\n    description: \"fixture\"\n    required_evidence:\n      - \"run-evidence-root\"\nhost_adapters:\n  - adapter_id: \"repo-shell\"\n    contract_ref: \".octon/framework/engine/runtime/adapters/host/repo-shell.yml\"\n    authority_mode: \"non_authoritative\"\n    replaceable: true\n    support_status: \"supported\"\n    default_route: \"allow\"\n    criteria_refs:\n      - \"HOST-001\"\n      - \"HOST-002\"\n    allowed_model_tiers:\n      - \"repo-local-governed\"\n    allowed_workload_tiers:\n      - \"{workload_id}\"\n    allowed_language_resource_tiers:\n      - \"reference-owned\"\n    allowed_locale_tiers:\n      - \"english-primary\"\n    required_evidence:\n      - \"instruction-layer-manifest\"\nmodel_adapters:\n  - adapter_id: \"repo-local-governed\"\n    contract_ref: \".octon/framework/engine/runtime/adapters/model/repo-local-governed.yml\"\n    authority_mode: \"non_authoritative\"\n    replaceable: true\n    support_status: \"supported\"\n    default_route: \"allow\"\n    criteria_refs:\n      - \"MODEL-001\"\n      - \"MODEL-002\"\n      - \"MODEL-003\"\n    allowed_model_tiers:\n      - \"repo-local-governed\"\n    allowed_workload_tiers:\n      - \"{workload_id}\"\n    allowed_language_resource_tiers:\n      - \"reference-owned\"\n    allowed_locale_tiers:\n      - \"english-primary\"\n    required_evidence:\n      - \"run-evidence-root\"\n"
    )
}

fn temp_runtime_config() -> RuntimeConfig {
    let stamp = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("time should move forward")
        .as_nanos();
    let base =
        std::env::temp_dir().join(format!("octon-auth-test-{}-{stamp}", std::process::id()));
    let _ = fs::remove_dir_all(&base);
    fs::create_dir_all(base.join(".octon/instance/charter"))
        .expect("create workspace charter dir");
    fs::create_dir_all(base.join(".octon/framework/capabilities/governance/policy"))
        .expect("create ACP policy dir");
    fs::create_dir_all(base.join(".octon/framework/engine/runtime/adapters/host"))
        .expect("create host adapter dir");
    fs::create_dir_all(base.join(".octon/framework/engine/runtime/adapters/model"))
        .expect("create model adapter dir");
    fs::create_dir_all(base.join(".octon/framework/capabilities/packs/repo"))
        .expect("create repo pack dir");
    fs::create_dir_all(base.join(".octon/framework/capabilities/packs/git"))
        .expect("create git pack dir");
    fs::create_dir_all(base.join(".octon/framework/capabilities/packs/shell"))
        .expect("create shell pack dir");
    fs::create_dir_all(base.join(".octon/framework/capabilities/packs/browser"))
        .expect("create browser pack dir");
    fs::create_dir_all(base.join(".octon/framework/capabilities/packs/api"))
        .expect("create api pack dir");
    fs::create_dir_all(base.join(".octon/framework/capabilities/packs/telemetry"))
        .expect("create telemetry pack dir");
    fs::create_dir_all(base.join(".octon/state/evidence/runs"))
        .expect("create run evidence dir");
    fs::create_dir_all(base.join(".octon/state/continuity/runs"))
        .expect("create run continuity dir");
    fs::create_dir_all(base.join(".octon/state/evidence/control/execution"))
        .expect("create control evidence dir");
    fs::create_dir_all(base.join(".octon/state/control/execution"))
        .expect("create execution control dir");
    fs::create_dir_all(base.join(".octon/state/control/execution/approvals/requests"))
        .expect("create approval request dir");
    fs::create_dir_all(base.join(".octon/state/control/execution/approvals/grants"))
        .expect("create approval grant dir");
    fs::create_dir_all(base.join(".octon/state/control/execution/exceptions"))
        .expect("create exception dir");
    fs::create_dir_all(base.join(".octon/state/control/execution/revocations"))
        .expect("create revocation dir");
    fs::create_dir_all(base.join(".octon/generated/.tmp/execution"))
        .expect("create execution tmp dir");
    fs::create_dir_all(base.join(".octon/instance/governance")).expect("create governance dir");
    fs::create_dir_all(base.join(".octon/instance/governance/ownership"))
        .expect("create ownership dir");
    fs::create_dir_all(base.join(".octon/instance/capabilities/runtime/packs"))
        .expect("create runtime pack dir");
    fs::write(
        base.join(".octon/instance/charter/workspace.yml"),
        "schema_version: workspace-charter-v1\nworkspace_charter_id: workspace-charter://test/example\nversion: 1.0.0\n",
    )
    .expect("write workspace machine charter");
    fs::write(
        base.join(".octon/instance/governance/support-targets.yml"),
        support_targets_fixture("repo-consequential", "repo-consequential", "allow"),
    )
    .expect("write support targets");
    fs::write(
        base.join(".octon/instance/governance/ownership/registry.yml"),
        "schema_version: \"ownership-registry-v1\"\ndirective_precedence:\n  - mission_owner\noperators:\n  - operator_id: \"test\"\n    display_name: \"Test\"\n    contact: \"repo://test\"\ndefaults:\n  operator_id: \"test\"\n  support_tier: \"repo-consequential\"\nassets:\n  - asset_id: \"workflow-evidence\"\n    path_globs:\n      - \"workflow-evidence\"\n    owners:\n      - \"test\"\nservices: []\nsubscriptions: {}\n",
    )
    .expect("write ownership registry");
    fs::create_dir_all(base.join(".octon/state/control/execution/exceptions/leases"))
        .expect("create exception lease directory");
    let source_root = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../../../../../..")
        .canonicalize()
        .expect("source repo root should resolve");
    fs::copy(
        source_root
            .join(".octon/framework/capabilities/governance/policy/deny-by-default.v2.yml"),
        base.join(".octon/framework/capabilities/governance/policy/deny-by-default.v2.yml"),
    )
    .expect("copy ACP policy");
    fs::copy(
        source_root.join(".octon/framework/engine/runtime/adapters/host/repo-shell.yml"),
        base.join(".octon/framework/engine/runtime/adapters/host/repo-shell.yml"),
    )
    .expect("copy repo-shell adapter");
    fs::copy(
        source_root
            .join(".octon/framework/engine/runtime/adapters/model/repo-local-governed.yml"),
        base.join(".octon/framework/engine/runtime/adapters/model/repo-local-governed.yml"),
    )
    .expect("copy repo-local-governed adapter");
    fs::copy(
        source_root.join(".octon/framework/capabilities/packs/repo/manifest.yml"),
        base.join(".octon/framework/capabilities/packs/repo/manifest.yml"),
    )
    .expect("copy repo pack");
    fs::copy(
        source_root.join(".octon/framework/capabilities/packs/git/manifest.yml"),
        base.join(".octon/framework/capabilities/packs/git/manifest.yml"),
    )
    .expect("copy git pack");
    fs::copy(
        source_root.join(".octon/framework/capabilities/packs/shell/manifest.yml"),
        base.join(".octon/framework/capabilities/packs/shell/manifest.yml"),
    )
    .expect("copy shell pack");
    fs::copy(
        source_root.join(".octon/framework/capabilities/packs/browser/manifest.yml"),
        base.join(".octon/framework/capabilities/packs/browser/manifest.yml"),
    )
    .expect("copy browser pack");
    fs::copy(
        source_root.join(".octon/framework/capabilities/packs/api/manifest.yml"),
        base.join(".octon/framework/capabilities/packs/api/manifest.yml"),
    )
    .expect("copy api pack");
    fs::copy(
        source_root.join(".octon/framework/capabilities/packs/telemetry/manifest.yml"),
        base.join(".octon/framework/capabilities/packs/telemetry/manifest.yml"),
    )
    .expect("copy telemetry pack");
    fs::copy(
        source_root.join(".octon/instance/capabilities/runtime/packs/registry.yml"),
        base.join(".octon/instance/capabilities/runtime/packs/registry.yml"),
    )
    .expect("copy runtime pack registry");
    RuntimeConfig {
        octon_dir: base.join(".octon"),
        repo_root: base.clone(),
        run_evidence_root: base.join(".octon/state/evidence/runs"),
        run_continuity_root: base.join(".octon/state/continuity/runs"),
        execution_control_root: base.join(".octon/state/control/execution"),
        execution_tmp_root: base.join(".octon/generated/.tmp/execution"),
        policy: PolicyConfig::default(),
        policy_path: Some(PathBuf::from(
            "framework/capabilities/governance/policy/deny-by-default.v2.yml",
        )),
        execution_governance: ExecutionGovernanceConfig {
            receipt_roots: ReceiptRootsConfig::default(),
            ..ExecutionGovernanceConfig::default()
        },
        ndjson_max_line_bytes: 1024,
        wasmtime_cache_config: None,
    }
}

fn seed_mission_autonomy_fixture(cfg: &RuntimeConfig, mission_id: &str, budget_state: &str) {
    let mission_dir = cfg
        .octon_dir
        .join("instance/orchestration/missions")
        .join(mission_id);
    let control_dir = cfg.execution_control_root.join("missions").join(mission_id);
    let effective_dir = cfg
        .octon_dir
        .join("generated/effective/orchestration/missions")
        .join(mission_id);
    fs::create_dir_all(&mission_dir).expect("create mission dir");
    fs::create_dir_all(cfg.octon_dir.join("instance/governance/policies"))
        .expect("create mission policy dir");
    fs::create_dir_all(cfg.octon_dir.join("instance/governance/ownership"))
        .expect("create ownership dir");
    fs::create_dir_all(&control_dir).expect("create control dir");
    fs::create_dir_all(&effective_dir).expect("create effective route dir");
    fs::write(
        cfg.octon_dir.join("instance/orchestration/missions/registry.yml"),
        format!("schema_version: \"octon-mission-registry-v2\"\nactive:\n  - {mission_id}\narchived: []\n"),
    )
    .expect("write mission registry");
    fs::write(
        mission_dir.join("mission.yml"),
        format!(
            "schema_version: \"octon-mission-v2\"\nmission_id: \"{mission_id}\"\ntitle: \"Test Mission\"\nsummary: \"Fixture mission\"\nstatus: \"active\"\nmission_class: \"maintenance\"\nowner_ref: \"operator://test\"\ncreated_at: \"2026-03-23\"\nrisk_ceiling: \"ACP-2\"\nallowed_action_classes:\n  - \"repo-maintenance\"\ndefault_safing_subset:\n  - \"observe_only\"\n  - \"stage_only\"\ndefault_schedule_hint: \"continuous\"\ndefault_overlap_policy: \"skip\"\nscope_ids: []\nsuccess_criteria:\n  - \"Fixture completes\"\nfailure_conditions: []\n"
        ),
    )
    .expect("write mission charter");
    fs::write(
        cfg.octon_dir.join("instance/governance/policies/mission-autonomy.yml"),
        "schema_version: \"mission-autonomy-policy-v1\"\nmode_defaults: {}\nexecution_postures: {}\npreview_defaults: {}\ndigest_cadence_defaults: {}\nownership_routing: {}\noverlap_defaults: {}\nbackfill_defaults: {}\npause_on_failure: {}\nrecovery_windows: {}\nproceed_on_silence: {}\nsafe_interrupt_boundaries: {}\nautonomy_burn: {}\ncircuit_breakers: {}\nquorum: {}\nsafing_defaults: {}\n",
    )
    .expect("write mission autonomy policy");
    fs::write(
        cfg.octon_dir.join("instance/governance/ownership/registry.yml"),
        "schema_version: \"ownership-registry-v1\"\ndirective_precedence:\n  - mission_owner\noperators:\n  - operator_id: \"test\"\n    display_name: \"Test\"\n    contact: \"repo://test\"\ndefaults:\n  operator_id: \"test\"\n  support_tier: \"repo-consequential\"\nassets:\n  - asset_id: \"fixture\"\n    path_globs:\n      - \"workflow-evidence\"\n    owners:\n      - \"test\"\nservices: []\nsubscriptions: {}\n",
    )
    .expect("write ownership registry");
    fs::write(
        control_dir.join("lease.yml"),
        format!("schema_version: \"mission-control-lease-v1\"\nmission_id: \"{mission_id}\"\nlease_id: \"lease-1\"\nstate: \"active\"\nissued_by: \"operator://test\"\nissued_at: \"2026-03-23T00:00:00Z\"\nexpires_at: \"2099-03-24T00:00:00Z\"\ncontinuation_scope:\n  summary: \"Fixture continuation\"\n  allowed_execution_postures:\n    - \"continuous\"\n  max_concurrent_runs: 1\n  allowed_action_classes:\n    - \"repo-maintenance\"\n  default_safing_subset:\n    - \"observe_only\"\n    - \"stage_only\"\nrevocation_reason: null\nlast_reviewed_at: \"2026-03-23T00:00:00Z\"\n"),
    )
    .expect("write lease");
    fs::write(
        control_dir.join("mode-state.yml"),
        format!("schema_version: \"mode-state-v1\"\nmission_id: \"{mission_id}\"\noversight_mode: \"feedback_window\"\nexecution_posture: \"continuous\"\nsafety_state: \"active\"\nphase: \"planning\"\nactive_run_ref: null\ncurrent_slice_ref: null\nnext_safe_interrupt_boundary_id: null\neffective_scenario_resolution_ref: null\nautonomy_burn_state: \"{budget_state}\"\nbreaker_state: \"clear\"\nupdated_at: \"2026-03-23T00:00:00Z\"\n"),
    )
    .expect("write mode state");
    fs::write(
        control_dir.join("intent-register.yml"),
        format!("schema_version: \"intent-register-v1\"\nmission_id: \"{mission_id}\"\nrevision: 1\ngenerated_from:\n  - \"kernel-test\"\nentries:\n  - slice_ref:\n      id: \"slice-1\"\n    intent_ref:\n      id: \"intent://test/example\"\n      version: \"1.0.0\"\n    action_class: \"git.commit\"\n    target_ref:\n      id: \"fixture\"\n    rationale: \"fixture\"\n    status: \"published\"\n    predicted_acp: \"ACP-1\"\n    planned_reversibility_class: \"reversible\"\n    safe_interrupt_boundary_id: \"task-boundary\"\n    boundary_class: \"task_boundary\"\n    expected_blast_radius: \"small\"\n    expected_budget_impact: {{}}\n    required_authorize_updates: []\n    rollback_plan_ref: \"plan://rollback\"\n    compensation_plan_ref: null\n    finalize_policy_ref: \"policy://finalize\"\n    earliest_start_at: \"2026-03-23T00:00:00Z\"\n    feedback_deadline_at: \"2026-03-23T00:30:00Z\"\n    default_on_silence: \"feedback_window\"\n"),
    )
    .expect("write intent register");
    fs::write(control_dir.join("directives.yml"), format!("schema_version: \"control-directive-v1\"\nmission_id: \"{mission_id}\"\nrevision: 1\ndirectives: []\n"))
        .expect("write directives");
    fs::write(
        control_dir.join("schedule.yml"),
        format!("schema_version: \"schedule-control-v1\"\nmission_id: \"{mission_id}\"\nschedule_source: \"test\"\ncadence_or_trigger: \"continuous\"\nnext_planned_run_at: null\nsuspended_future_runs: false\npause_active_run_requested: false\noverlap_policy: \"skip\"\nbackfill_policy: \"latest_only\"\npause_on_failure_rules:\n  enabled: true\n  triggers: []\npreview_lead: null\nfeedback_window_default: null\nquiet_hours: null\ndigest_route_override: null\nlast_schedule_mutation_ref: null\n"),
    )
    .expect("write schedule");
    fs::write(
        control_dir.join("autonomy-budget.yml"),
        format!("schema_version: \"autonomy-budget-v1\"\nmission_id: \"{mission_id}\"\nstate: \"{budget_state}\"\nwindow: \"PT24H\"\nthreshold_profile_ref: \"fixture\"\nlast_state_change_at: \"2026-03-23T00:00:00Z\"\napplied_mode_adjustments: []\nupdated_at: \"2026-03-23T00:00:00Z\"\ncounters: {{}}\n"),
    )
    .expect("write autonomy budget");
    fs::write(
        control_dir.join("circuit-breakers.yml"),
        format!("schema_version: \"circuit-breaker-v1\"\nmission_id: \"{mission_id}\"\nstate: \"clear\"\ntrip_reasons: []\ntrip_conditions_snapshot: {{}}\napplied_actions: []\ntripped_at: null\nreset_requirements: []\nreset_ref: null\nupdated_at: \"2026-03-23T00:00:00Z\"\ntripped_breakers: []\n"),
    )
    .expect("write breakers");
    fs::write(control_dir.join("subscriptions.yml"), format!("schema_version: \"subscriptions-v1\"\nmission_id: \"{mission_id}\"\nowners:\n  - \"operator://test\"\nwatchers: []\ndigest_recipients:\n  - \"operator://test\"\nalert_recipients:\n  - \"operator://test\"\nrouting_policy_ref: \".octon/instance/governance/ownership/registry.yml\"\nlast_routing_evaluation_at: \"2026-03-23T00:00:00Z\"\n"))
        .expect("write subscriptions");
    fs::write(
        effective_dir.join("scenario-resolution.yml"),
        format!("schema_version: \"scenario-resolution-v1\"\nmission_id: \"{mission_id}\"\nsource_refs: {{}}\neffective:\n  scenario_family: \"maintenance.repo_housekeeping\"\n  mission_class: \"maintenance\"\n  effective_scenario_family: \"maintenance.repo_housekeeping\"\n  effective_action_class: \"git.commit\"\n  scenario_family_source: \"mission_class.default\"\n  boundary_source: \"action_class.default\"\n  recovery_source: \"deny_by_default_policy\"\n  tightening_overlays: []\n  oversight_mode: \"feedback_window\"\n  execution_posture: \"continuous\"\n  preview_policy: {{}}\n  feedback_window_required: true\n  proceed_on_silence_allowed: false\n  approval_required: false\n  safe_interrupt_boundary_class: \"task_boundary\"\n  overlap_policy: \"skip\"\n  backfill_policy: \"latest_only\"\n  pause_on_failure:\n    enabled: true\n    triggers: []\n  digest_route: \"preview_plus_closure_digest\"\n  alert_route: \"owners-first-digest\"\n  required_quorum: \"1\"\n  recovery_profile:\n    action_class: \"git.commit\"\n    primitive: \"git.revert_commit\"\n    rollback_handle_type: \"git-commit\"\n    recovery_window: \"P30D\"\n    reversibility_class: \"reversible\"\n  finalize_policy:\n    approval_required: false\n    block_finalize: false\n    break_glass_required: false\n  safing_subset:\n    - \"observe_only\"\nrationale:\n  - \"fixture\"\ngenerated_at: \"2026-03-23T00:00:00Z\"\nfresh_until: \"2099-03-24T00:00:00Z\"\n"),
    )
    .expect("write scenario resolution");
}

fn mission_request(
    cfg: &RuntimeConfig,
    mission_id: &str,
    oversight_mode: &str,
    reversibility_class: &str,
) -> ExecutionRequest {
    let control_dir = cfg.execution_control_root.join("missions").join(mission_id);
    let effective_dir = cfg
        .octon_dir
        .join("generated/effective/orchestration/missions")
        .join(mission_id);
    let budget_state = fs::read_to_string(control_dir.join("autonomy-budget.yml"))
        .ok()
        .and_then(|raw| serde_yaml::from_str::<serde_yaml::Value>(&raw).ok())
        .and_then(|value| {
            value
                .get("state")
                .and_then(|inner| inner.as_str())
                .map(str::to_string)
        })
        .unwrap_or_else(|| "healthy".to_string());
    fs::write(
        control_dir.join("mode-state.yml"),
        format!(
            "schema_version: \"mode-state-v1\"\nmission_id: \"{mission_id}\"\noversight_mode: \"{oversight_mode}\"\nexecution_posture: \"continuous\"\nsafety_state: \"active\"\nphase: \"planning\"\nactive_run_ref: null\ncurrent_slice_ref: null\nnext_safe_interrupt_boundary_id: null\neffective_scenario_resolution_ref: null\nautonomy_burn_state: \"healthy\"\nbreaker_state: \"clear\"\nupdated_at: \"2026-03-23T00:00:00Z\"\n"
        ),
    )
    .expect("rewrite mode state");
    fs::write(
        effective_dir.join("scenario-resolution.yml"),
        format!(
            "schema_version: \"scenario-resolution-v1\"\nmission_id: \"{mission_id}\"\nsource_refs: {{}}\neffective:\n  scenario_family: \"maintenance.repo_housekeeping\"\n  mission_class: \"maintenance\"\n  effective_scenario_family: \"maintenance.repo_housekeeping\"\n  effective_action_class: \"git.commit\"\n  scenario_family_source: \"mission_class.default\"\n  boundary_source: \"action_class.default\"\n  recovery_source: \"deny_by_default_policy\"\n  tightening_overlays: []\n  oversight_mode: \"{oversight_mode}\"\n  execution_posture: \"continuous\"\n  preview_policy: {{}}\n  feedback_window_required: {feedback_window_required}\n  proceed_on_silence_allowed: {proceed_on_silence_allowed}\n  approval_required: {approval_required}\n  safe_interrupt_boundary_class: \"task_boundary\"\n  overlap_policy: \"skip\"\n  backfill_policy: \"latest_only\"\n  pause_on_failure:\n    enabled: true\n    triggers: []\n  digest_route: \"preview_plus_closure_digest\"\n  alert_route: \"owners-first-digest\"\n  required_quorum: \"1\"\n  recovery_profile:\n    action_class: \"git.commit\"\n    primitive: \"git.revert_commit\"\n    rollback_handle_type: \"git-commit\"\n    recovery_window: \"P30D\"\n    reversibility_class: \"{reversibility_class}\"\n  finalize_policy:\n    approval_required: {approval_required}\n    block_finalize: false\n    break_glass_required: false\n  safing_subset:\n    - \"observe_only\"\nrationale:\n  - \"fixture\"\ngenerated_at: \"2026-03-23T00:00:00Z\"\nfresh_until: \"2099-03-24T00:00:00Z\"\n",
            feedback_window_required = if oversight_mode == "feedback_window" { "true" } else { "false" },
            proceed_on_silence_allowed = if oversight_mode == "proceed_on_silence"
                && budget_state == "healthy"
                && reversibility_class != "irreversible"
            {
                "true"
            } else {
                "false"
            },
            approval_required = if oversight_mode == "approval_required" { "true" } else { "false" },
        ),
    )
    .expect("rewrite scenario resolution");
    let mut request = minimal_request();
    request.workflow_mode = "autonomous".to_string();
    request.autonomy_context = Some(
        default_autonomy_context(
            cfg,
            mission_id,
            "slice-1",
            "workflow-stage:test",
            oversight_mode,
            "continuous",
            reversibility_class,
        )
        .expect("autonomy context"),
    );
    request
}

fn minimal_request() -> ExecutionRequest {
    ExecutionRequest {
        request_id: "req-1".to_string(),
        caller_path: "workflow-stage".to_string(),
        action_type: "execute_stage".to_string(),
        target_id: "test-stage".to_string(),
        requested_capabilities: vec!["workflow.stage.execute".to_string()],
        side_effect_flags: SideEffectFlags {
            write_evidence: true,
            shell: true,
            model_invoke: true,
            ..SideEffectFlags::default()
        },
        risk_tier: "low".to_string(),
        workflow_mode: "human-only".to_string(),
        locality_scope: None,
        intent_ref: None,
        autonomy_context: None,
        execution_role_ref: Some(default_execution_role_ref()),
        parent_run_ref: None,
        review_requirements: ReviewRequirements::default(),
        scope_constraints: ScopeConstraints {
            read: vec!["repo-root".to_string()],
            write: vec!["workflow-evidence".to_string()],
            executor_profile: Some("read_only_analysis".to_string()),
            locality_scope: None,
        },
        policy_mode_requested: Some("soft-enforce".to_string()),
        environment_hint: Some("development".to_string()),
        metadata: BTreeMap::from([
            ("support_tier".to_string(), "repo-consequential".to_string()),
            (
                "support_model_tier".to_string(),
                "repo-local-governed".to_string(),
            ),
            (
                "support_language_resource_tier".to_string(),
                "reference-owned".to_string(),
            ),
            (
                "support_locale_tier".to_string(),
                "english-primary".to_string(),
            ),
            ("support_host_adapter".to_string(), "repo-shell".to_string()),
            (
                "support_model_adapter".to_string(),
                "repo-local-governed".to_string(),
            ),
        ]),
    }
}

#[test]
fn development_mode_allows_soft_enforce() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let grant = authorize_execution(&cfg, &policy, &minimal_request(), None)
        .expect("development request should authorize");
    assert_eq!(grant.effective_policy_mode, "soft-enforce");
}

#[test]
fn protected_execution_rejects_soft_enforce() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let mut request = minimal_request();
    request.environment_hint = Some("protected".to_string());
    let err = authorize_execution(&cfg, &policy, &request, None)
        .expect_err("protected request must deny soft-enforce");
    assert_eq!(err.code, ErrorCode::CapabilityDenied);
}

#[test]
fn critical_action_requires_hard_enforce() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let mut request = minimal_request();
    request.action_type = "mutate_repo".to_string();
    request.side_effect_flags.write_repo = true;
    request.scope_constraints.write = vec!["repo-scope".to_string()];
    let err = authorize_execution(&cfg, &policy, &request, None)
        .expect_err("critical action should deny outside hard-enforce");
    assert_eq!(err.code, ErrorCode::CapabilityDenied);
}

#[test]
fn request_level_human_approval_applies_without_executor_profile() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let mut request = minimal_request();
    request.scope_constraints.executor_profile = None;
    request.side_effect_flags.shell = false;
    request.review_requirements.human_approval = true;
    let err = authorize_execution(&cfg, &policy, &request, None)
        .expect_err("request-level approval should deny without env approval");
    assert_eq!(err.code, ErrorCode::CapabilityDenied);
}

#[test]
fn executor_wrapper_blocks_dangerous_flags_by_default() {
    let cfg = temp_runtime_config();
    let profile =
        resolve_executor_profile(&cfg, "read_only_analysis").expect("profile should exist");
    let (_, blocked) = build_executor_command(ExecutorCommandSpec {
        kind: ManagedExecutorKind::Codex,
        executor_bin: Path::new("/usr/bin/env"),
        repo_root: &cfg.repo_root,
        output_path: Some(Path::new("/tmp/out.txt")),
        model: None,
        profile,
    })
    .expect("command should build");
    assert_eq!(blocked, vec!["--full-auto".to_string()]);
}

#[test]
fn autonomous_request_requires_mission_context() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let mut request = minimal_request();
    request.workflow_mode = "autonomous".to_string();
    let err = authorize_execution(&cfg, &policy, &request, None)
        .expect_err("autonomous request without mission context must deny");
    assert_eq!(err.code, ErrorCode::CapabilityDenied);
    assert_eq!(
        err.details["reason_codes"][0].as_str(),
        Some("MISSION_AUTONOMY_CONTEXT_MISSING")
    );
}

#[test]
fn autonomous_request_allows_seeded_mission_context() {
    let cfg = temp_runtime_config();
    seed_mission_autonomy_fixture(&cfg, "mission-a", "healthy");
    let policy = PolicyEngine::new(cfg.clone());
    let request = mission_request(&cfg, "mission-a", "feedback_window", "reversible");
    let grant = authorize_execution(&cfg, &policy, &request, None)
        .expect("autonomous request with seeded mission surfaces should authorize");
    assert_eq!(grant.workflow_mode, "autonomous");
    assert_eq!(
        grant
            .autonomy_context
            .as_ref()
            .map(|value| value.mission_ref.id.as_str()),
        Some("mission-a")
    );
    assert_eq!(grant.autonomy_budget_state.as_deref(), Some("healthy"));
}

#[test]
fn approval_required_autonomous_request_returns_stage_only_without_human_approval() {
    let cfg = temp_runtime_config();
    seed_mission_autonomy_fixture(&cfg, "mission-b", "healthy");
    let policy = PolicyEngine::new(cfg.clone());
    let request = mission_request(&cfg, "mission-b", "approval_required", "reversible");
    let err = authorize_execution(&cfg, &policy, &request, None)
        .expect_err("approval-required autonomous request should stage only without approval");
    assert_eq!(err.details["decision"].as_str(), Some("STAGE_ONLY"));
}

#[test]
fn authority_projection_serializes_ref_and_accepts_legacy_alias() {
    let projection = AuthorityProjection {
        kind: "github-label".to_string(),
        ref_id: "github://pull/214/check/manual-review-requested".to_string(),
        notes: None,
    };

    let encoded = serde_yaml::to_string(&projection).expect("serialize projection");
    assert!(encoded.contains("ref:"));
    assert!(!encoded.contains("ref_id:"));

    let decoded: AuthorityProjection = serde_yaml::from_str(
        "kind: github-label\nref: github://pull/214/check/manual-review-requested\n",
    )
    .expect("decode canonical projection");
    assert_eq!(
        decoded.ref_id,
        "github://pull/214/check/manual-review-requested"
    );

    let legacy: AuthorityProjection = serde_yaml::from_str(
        "kind: github-label\nref_id: github://pull/214/check/manual-review-requested\n",
    )
    .expect("decode legacy projection");
    assert_eq!(
        legacy.ref_id,
        "github://pull/214/check/manual-review-requested"
    );
}

#[test]
fn active_revocation_refs_use_canonical_file_paths() {
    let cfg = temp_runtime_config();
    let revocations_dir = cfg.octon_dir.join("state/control/execution/revocations");
    fs::write(
        revocations_dir.join("revoke-1.yml"),
        "schema_version: \"authority-revocation-v2\"\nrevocation_id: \"revoke-1\"\ngrant_id: \"grant-req-1\"\nrequest_id: \"req-1\"\nrun_id: \"req-1\"\nstate: \"active\"\nrevoked_at: \"2026-03-27T00:00:00Z\"\nrevoked_by: \"operator://test\"\nreason_codes: []\nnotes: null\n",
    )
    .expect("write revocation fixture");

    let refs =
        load_active_revocation_refs(&cfg, "req-1", "grant-req-1").expect("load revocations");
    assert_eq!(
        refs,
        vec![".octon/state/control/execution/revocations/revoke-1.yml".to_string()]
    );
}

#[test]
fn active_revocation_refs_prefer_canonical_files_when_present() {
    let cfg = temp_runtime_config();
    let revocation_dir = cfg.octon_dir.join("state/control/execution/revocations");
    fs::write(
        revocation_dir.join("revoke-2.yml"),
        "schema_version: \"authority-revocation-v2\"\nrevocation_id: \"revoke-2\"\ngrant_id: \"grant-req-2\"\nrequest_id: \"req-2\"\nrun_id: \"req-2\"\nstate: \"active\"\nrevoked_at: \"2026-03-27T00:00:00Z\"\nrevoked_by: \"operator://test\"\nreason_codes: []\nnotes: null\n",
    )
    .expect("write canonical revocation fixture");

    let refs =
        load_active_revocation_refs(&cfg, "req-2", "grant-req-2").expect("load revocations");
    assert_eq!(
        refs,
        vec![".octon/state/control/execution/revocations/revoke-2.yml".to_string()]
    );
}

#[test]
fn unsupported_support_tier_denies_execution() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    fs::write(
        cfg.octon_dir
            .join("instance/governance/support-targets.yml"),
        support_targets_fixture("boundary-sensitive", "not-the-requested-tier", "deny"),
    )
    .expect("rewrite support targets");
    let err = authorize_execution(&cfg, &policy, &minimal_request(), None)
        .expect_err("unsupported support tier should deny");
    assert_eq!(
        err.details["reason_codes"][0].as_str(),
        Some("SUPPORT_TIER_UNSUPPORTED")
    );
}

#[test]
fn undeclared_host_adapter_denies_execution() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let mut request = minimal_request();
    request.metadata.insert(
        "support_host_adapter".to_string(),
        "missing-host".to_string(),
    );

    let err = authorize_execution(&cfg, &policy, &request, None)
        .expect_err("undeclared host adapter should deny");
    assert_eq!(
        err.details["reason_codes"][0].as_str(),
        Some("SUPPORT_TIER_UNSUPPORTED")
    );
}

#[test]
fn unadmitted_api_pack_denies_declared_execution() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let mut request = minimal_request();
    request
        .metadata
        .insert("support_capability_packs".to_string(), "api".to_string());

    let err = authorize_execution(&cfg, &policy, &request, None)
        .expect_err("unadmitted api pack should deny when declared");
    assert_eq!(
        err.details["reason_codes"][0].as_str(),
        Some("SUPPORT_TIER_UNSUPPORTED")
    );
}

#[test]
fn unadmitted_browser_pack_denies_declared_execution() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let mut request = minimal_request();
    request
        .requested_capabilities
        .push("browser.click".to_string());
    request.metadata.insert(
        "support_capability_packs".to_string(),
        "browser".to_string(),
    );

    let err = authorize_execution(&cfg, &policy, &request, None)
        .expect_err("unadmitted browser pack should deny when declared");
    assert_eq!(
        err.details["reason_codes"][0].as_str(),
        Some("SUPPORT_TIER_UNSUPPORTED")
    );
}

#[test]
fn invalid_model_adapter_manifest_denies_execution() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    fs::write(
        cfg.octon_dir
            .join("framework/engine/runtime/adapters/model/repo-local-governed.yml"),
        "schema_version: \"octon-model-adapter-v1\"\nadapter_id: \"repo-local-governed\"\ndisplay_name: \"Broken\"\nreplaceable: true\nauthority_mode: \"non_authoritative\"\nruntime_surface:\n  interface_ref: \".octon/framework/engine/runtime/spec/policy-interface-v1.md\"\n  integration_class: \"native-planning\"\nsupport_target_ref: \".octon/instance/governance/support-targets.yml\"\nsupport_tier_declarations:\n  model_tiers:\n    - \"repo-local-governed\"\n  workload_tiers:\n    - \"repo-consequential\"\n  language_resource_tiers:\n    - \"reference-owned\"\n  locale_tiers:\n    - \"english-primary\"\nconformance_criteria_refs:\n  - \"MODEL-001\"\nconformance_suite_refs: []\ncontamination_reset_policy:\n  clean_checkpoint_required: true\n  hard_reset_on_signature: true\n  contamination_signal_ref: \".octon/framework/constitution/contracts/runtime/rollback-posture-v1.schema.json\"\n  evidence_log_ref: \".octon/state/evidence/runs/<run-id>/interventions/log.yml\"\nknown_limitations:\n  - \"fixture\"\nnon_authoritative_boundaries:\n  - \"fixture\"\n",
    )
    .expect("write invalid model adapter manifest");

    let err = authorize_execution(&cfg, &policy, &minimal_request(), None)
        .expect_err("invalid model adapter manifest should deny");
    assert_eq!(
        err.details["reason_codes"][0].as_str(),
        Some("SUPPORT_TIER_UNSUPPORTED")
    );
}

#[test]
fn proceed_on_silence_blocks_when_autonomy_budget_not_healthy() {
    let cfg = temp_runtime_config();
    seed_mission_autonomy_fixture(&cfg, "mission-c", "warning");
    let policy = PolicyEngine::new(cfg.clone());
    let request = mission_request(&cfg, "mission-c", "proceed_on_silence", "reversible");
    let err = authorize_execution(&cfg, &policy, &request, None)
        .expect_err("warning autonomy budget should block proceed-on-silence");
    assert_eq!(err.details["decision"].as_str(), Some("STAGE_ONLY"));
    assert_eq!(
        err.details["reason_codes"][0].as_str(),
        Some("MISSION_PROCEED_ON_SILENCE_BLOCKED")
    );
}

#[test]
fn missing_scenario_resolution_returns_stage_only() {
    let cfg = temp_runtime_config();
    seed_mission_autonomy_fixture(&cfg, "mission-d", "healthy");
    let policy = PolicyEngine::new(cfg.clone());
    let request = mission_request(&cfg, "mission-d", "feedback_window", "reversible");
    fs::remove_file(
        cfg.octon_dir.join(
            "generated/effective/orchestration/missions/mission-d/scenario-resolution.yml",
        ),
    )
    .expect("remove scenario resolution");
    let err = authorize_execution(&cfg, &policy, &request, None)
        .expect_err("missing route must fail closed");
    assert_eq!(err.details["decision"].as_str(), Some("STAGE_ONLY"));
    assert_eq!(
        err.details["reason_codes"][0].as_str(),
        Some("MISSION_SCENARIO_RESOLUTION_MISSING")
    );
}

#[test]
fn stale_scenario_resolution_returns_stage_only() {
    let cfg = temp_runtime_config();
    seed_mission_autonomy_fixture(&cfg, "mission-e", "healthy");
    let policy = PolicyEngine::new(cfg.clone());
    let request = mission_request(&cfg, "mission-e", "feedback_window", "reversible");
    let effective_path = cfg
        .octon_dir
        .join("generated/effective/orchestration/missions/mission-e/scenario-resolution.yml");
    let stale = fs::read_to_string(&effective_path).expect("read route");
    fs::write(
        &effective_path,
        stale.replace(
            "fresh_until: \"2099-03-24T00:00:00Z\"",
            "fresh_until: \"2020-03-24T00:00:00Z\"",
        ),
    )
    .expect("rewrite route stale");
    let err = authorize_execution(&cfg, &policy, &request, None)
        .expect_err("stale route must fail closed");
    assert_eq!(err.details["decision"].as_str(), Some("STAGE_ONLY"));
    assert_eq!(
        err.details["reason_codes"][0].as_str(),
        Some("MISSION_SCENARIO_RESOLUTION_STALE")
    );
}

#[test]
fn failed_run_measurement_artifacts_remain_workflow_agnostic() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let mut request = minimal_request();
    request.request_id = "archive-proposal-failure-fixture".to_string();
    request.action_type = "archive_proposal".to_string();
    request.target_id = "archive-proposal-fixture".to_string();
    request
        .metadata
        .insert("workflow_id".to_string(), "archive-proposal".to_string());

    let grant = authorize_execution(&cfg, &policy, &request, None)
        .expect("archive proposal request should authorize");
    let artifacts_root = cfg.execution_tmp_root.join(&request.request_id);
    let paths = write_execution_start(&artifacts_root, &request, &grant)
        .expect("execution start should materialize");
    let outcome = ExecutionOutcome {
        status: "failed".to_string(),
        started_at: "2026-03-31T00:00:00Z".to_string(),
        completed_at: "2026-03-31T00:01:00Z".to_string(),
        error: Some("fixture failure".to_string()),
    };
    finalize_execution(
        &paths,
        &request,
        &grant,
        &outcome.started_at,
        &outcome,
        &SideEffectSummary::default(),
    )
    .expect("finalize execution should emit disclosure");

    let measurement_path = cfg
        .run_root(&request.request_id)
        .join("measurements")
        .join("summary.yml");
    let measurement: serde_yaml::Value = serde_yaml::from_str(
        &fs::read_to_string(&measurement_path).expect("read measurement summary"),
    )
    .expect("parse measurement summary");

    assert_eq!(
        measurement["summary"].as_str(),
        Some("Run emitted fail-closed measurement and disclosure artifacts for a non-success outcome.")
    );
    let metric_ids: Vec<&str> = measurement["metrics"]
        .as_sequence()
        .expect("metrics should be a sequence")
        .iter()
        .filter_map(|metric| metric["metric_id"].as_str())
        .collect();
    assert!(metric_ids.contains(&"receipt-count"));
    assert!(metric_ids.contains(&"checkpoint-count"));
    assert!(metric_ids.contains(&"proof-plane-count"));
    assert!(!metric_ids.contains(&"validator-count"));
}

#[test]
fn missing_scenario_action_class_returns_stage_only() {
    let cfg = temp_runtime_config();
    seed_mission_autonomy_fixture(&cfg, "mission-f", "healthy");
    let policy = PolicyEngine::new(cfg.clone());
    let request = mission_request(&cfg, "mission-f", "feedback_window", "reversible");
    let effective_path = cfg
        .octon_dir
        .join("generated/effective/orchestration/missions/mission-f/scenario-resolution.yml");
    let route = fs::read_to_string(&effective_path).expect("read route");
    fs::write(
        &effective_path,
        route.replace(
            "    action_class: \"git.commit\"\n",
            "    action_class: \"\"\n",
        ),
    )
    .expect("rewrite route without action class");
    let err = authorize_execution(&cfg, &policy, &request, None)
        .expect_err("missing route action class must fail closed");
    assert_eq!(err.details["decision"].as_str(), Some("STAGE_ONLY"));
    assert_eq!(
        err.details["reason_codes"][0].as_str(),
        Some("MISSION_ACTION_CLASS_MISSING")
    );
}
}
