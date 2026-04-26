use crate::implementation::execution::normalized_repo_relative_ref;
use octon_core::errors::{ErrorCode, KernelError};
use octon_core::policy::PolicyEngine;
use serde_json::json;
use sha2::{Digest, Sha256};
use std::collections::BTreeMap;
use std::path::Path;

mod tests {
use super::*;
use octon_core::config::{
    ExecutionGovernanceConfig, PolicyConfig, ReceiptRootsConfig, RuntimeConfig,
};
use std::fs;
use std::path::PathBuf;
use std::sync::atomic::{AtomicU64, Ordering};
use std::time::{SystemTime, UNIX_EPOCH};

static TEMP_RUNTIME_COUNTER: AtomicU64 = AtomicU64::new(0);

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
    let serial = TEMP_RUNTIME_COUNTER.fetch_add(1, Ordering::Relaxed);
    let base = std::env::temp_dir().join(format!(
        "octon-auth-test-{}-{stamp}-{serial}",
        std::process::id()
    ));
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
    let copy_rel = |rel: &str| {
        let target = base.join(rel);
        if let Some(parent) = target.parent() {
            fs::create_dir_all(parent).expect("create parent directories for fixture copy");
        }
        fs::copy(source_root.join(rel), target).expect("copy fixture path");
    };
    copy_rel(".octon/octon.yml");
    copy_rel(".octon/framework/constitution/CHARTER.md");
    copy_rel(".octon/framework/constitution/obligations/fail-closed.yml");
    copy_rel(".octon/framework/engine/runtime/spec/context-pack-builder-v1.md");
    copy_rel(".octon/framework/engine/runtime/spec/execution-authorization-v1.md");
    copy_rel(".octon/instance/charter/workspace.md");
    copy_rel(".octon/instance/governance/runtime-resolution.yml");
    copy_rel(".octon/instance/governance/policies/context-packing.yml");
    copy_rel(".octon/instance/governance/support-targets.yml");
    copy_rel(".octon/instance/governance/capability-packs/registry.yml");
    copy_rel(".octon/instance/governance/capability-packs/repo.yml");
    copy_rel(".octon/instance/governance/capability-packs/git.yml");
    copy_rel(".octon/instance/governance/capability-packs/shell.yml");
    copy_rel(".octon/instance/governance/capability-packs/telemetry.yml");
    copy_rel(".octon/instance/governance/capability-packs/browser.yml");
    copy_rel(".octon/instance/governance/capability-packs/api.yml");
    copy_rel(".octon/instance/governance/support-target-admissions/live/repo-shell-observe-read-en.yml");
    copy_rel(".octon/instance/governance/support-target-admissions/live/repo-shell-repo-consequential-en.yml");
    copy_rel(".octon/instance/governance/support-target-admissions/live/ci-observe-read-en.yml");
    copy_rel(".octon/instance/governance/support-target-admissions/stage-only/repo-shell-boundary-sensitive-en.yml");
    copy_rel(".octon/instance/governance/support-target-admissions/live/github-repo-consequential-en.yml");
    copy_rel(".octon/instance/governance/support-target-admissions/stage-only/frontier-studio-boundary-sensitive-es.yml");
    copy_rel(".octon/instance/governance/support-dossiers/live/repo-shell-observe-read-en/dossier.yml");
    copy_rel(".octon/instance/governance/support-dossiers/live/repo-shell-repo-consequential-en/dossier.yml");
    copy_rel(".octon/instance/governance/support-dossiers/live/ci-observe-read-en/dossier.yml");
    copy_rel(".octon/instance/governance/support-dossiers/stage-only/repo-shell-boundary-sensitive-en/dossier.yml");
    copy_rel(".octon/instance/governance/support-dossiers/live/github-repo-consequential-en/dossier.yml");
    copy_rel(".octon/instance/governance/support-dossiers/stage-only/frontier-studio-boundary-sensitive-es/dossier.yml");
    copy_rel(".octon/instance/capabilities/runtime/packs/admissions/repo.yml");
    copy_rel(".octon/instance/capabilities/runtime/packs/admissions/git.yml");
    copy_rel(".octon/instance/capabilities/runtime/packs/admissions/shell.yml");
    copy_rel(".octon/instance/capabilities/runtime/packs/admissions/telemetry.yml");
    copy_rel(".octon/instance/capabilities/runtime/packs/admissions/browser.yml");
    copy_rel(".octon/instance/capabilities/runtime/packs/admissions/api.yml");
    copy_rel(".octon/generated/effective/runtime/route-bundle.yml");
    copy_rel(".octon/generated/effective/runtime/route-bundle.lock.yml");
    copy_rel(".octon/generated/effective/governance/support-target-matrix.yml");
    copy_rel(".octon/generated/effective/governance/support-envelope-reconciliation.yml");
    copy_rel(".octon/generated/effective/capabilities/pack-routes.effective.yml");
    copy_rel(".octon/generated/effective/capabilities/pack-routes.lock.yml");
    copy_rel(".octon/generated/effective/extensions/catalog.effective.yml");
    copy_rel(".octon/generated/effective/extensions/generation.lock.yml");
    copy_rel(".octon/state/control/extensions/active.yml");
    copy_rel(".octon/state/control/extensions/quarantine.yml");
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
    {
        let receipt_rel = std::fs::read_to_string(
            source_root.join(".octon/generated/effective/runtime/route-bundle.lock.yml"),
        )
        .expect("read live route bundle lock");
        let receipt_rel = receipt_rel;
        let route_receipt = source_root
            .join(
                serde_yaml::from_str::<serde_yaml::Value>(&receipt_rel)
                    .expect("parse route bundle lock")
                    .get("publication_receipt_path")
                    .and_then(|value| value.as_str())
                    .expect("route bundle receipt path"),
            );
        let pack_receipt = source_root
            .join(
                serde_yaml::from_str::<serde_yaml::Value>(
                    &std::fs::read_to_string(
                        source_root.join(".octon/generated/effective/capabilities/pack-routes.lock.yml"),
                    )
                    .expect("read pack routes lock"),
                )
                .expect("parse pack routes lock")
                .get("publication_receipt_path")
                .and_then(|value| value.as_str())
                .expect("pack routes receipt path"),
            );
        let extension_receipt = source_root
            .join(
                serde_yaml::from_str::<serde_yaml::Value>(
                    &std::fs::read_to_string(
                        source_root.join(".octon/generated/effective/extensions/generation.lock.yml"),
                    )
                    .expect("read extension generation lock"),
                )
                .expect("parse extension generation lock")
                .get("publication_receipt_path")
                .and_then(|value| value.as_str())
                .expect("extension receipt path"),
            );
        let route_target = base.join(route_receipt.strip_prefix(&source_root).expect("route receipt relative"));
        let pack_target = base.join(pack_receipt.strip_prefix(&source_root).expect("pack receipt relative"));
        let extension_target = base.join(extension_receipt.strip_prefix(&source_root).expect("extension receipt relative"));
        fs::create_dir_all(route_target.parent().expect("route receipt parent")).expect("create route receipt parent");
        fs::create_dir_all(pack_target.parent().expect("pack receipt parent")).expect("create pack receipt parent");
        fs::create_dir_all(extension_target.parent().expect("extension receipt parent")).expect("create extension receipt parent");
        fs::copy(route_receipt, route_target).expect("copy route receipt");
        fs::copy(pack_receipt, pack_target).expect("copy pack receipt");
        fs::copy(extension_receipt, extension_target).expect("copy extension receipt");
    }
    RuntimeConfig {
        octon_dir: base.join(".octon"),
        repo_root: base.clone(),
        run_evidence_root: base.join(".octon/state/evidence/runs"),
        run_continuity_root: base.join(".octon/state/continuity/runs"),
        execution_control_root: base.join(".octon/state/control/execution"),
        execution_tmp_root: base.join(".octon/generated/.tmp/execution"),
        runtime_resolution_path: base.join(".octon/instance/governance/runtime-resolution.yml"),
        runtime_route_bundle_path: base.join(".octon/generated/effective/runtime/route-bundle.yml"),
        runtime_route_bundle_lock_path: base.join(".octon/generated/effective/runtime/route-bundle.lock.yml"),
        runtime_pack_routes_effective_path: base.join(".octon/generated/effective/capabilities/pack-routes.effective.yml"),
        runtime_pack_routes_lock_path: base.join(".octon/generated/effective/capabilities/pack-routes.lock.yml"),
        runtime_route_bundle_generation_id: String::new(),
        runtime_route_bundle_sha256: String::new(),
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

fn fixture_sha256(path: &Path) -> String {
    let bytes = fs::read(path).expect("read fixture file");
    let mut hasher = Sha256::new();
    hasher.update(bytes);
    hex::encode(hasher.finalize())
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
        context_pack_ref: None,
        context_evidence_binding: None,
        requires_context_evidence: false,
        boundary_sensitive: false,
        risk_materiality_ref: None,
        support_target_tuple_ref: None,
        rollback_plan_ref: None,
        browser_ui_execution_ref: None,
        api_egress_ref: None,
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

fn supplied_context_fixture(
    request_id: &str,
) -> (RuntimeConfig, ExecutionRequest, ContextEvidenceBinding) {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let mut request = minimal_request();
    request.request_id = request_id.to_string();
    let grant = authorize_execution(&cfg, &policy, &request, None)
        .expect("context-required request should authorize");
    let binding = grant
        .context_evidence_binding
        .expect("context evidence binding should be present");
    (cfg, request, binding)
}

fn repo_ref_path(cfg: &RuntimeConfig, reference: &str) -> PathBuf {
    cfg.repo_root.join(reference)
}

fn start_run_for_effect_consumption(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
    grant: &GrantBundle,
) -> PathBuf {
    let runtime_path = cfg.execution_tmp_root.join(&request.request_id);
    fs::create_dir_all(&runtime_path).expect("create runtime path");
    let artifact_effects = issue_execution_artifact_effects(
        &runtime_path,
        grant,
        runtime_path.display().to_string(),
    )
    .expect("execution artifact effects should mint");
    write_execution_start(&runtime_path, request, grant, &artifact_effects)
        .expect("run should enter running state");
    runtime_path
}

fn read_json_value(path: &Path) -> serde_json::Value {
    serde_json::from_str(&fs::read_to_string(path).expect("read json artifact"))
        .expect("parse json artifact")
}

fn write_json_value(path: &Path, value: &serde_json::Value) {
    fs::write(
        path,
        serde_json::to_vec_pretty(value).expect("serialize json artifact"),
    )
    .expect("write json artifact");
}

fn assert_context_reason(err: KernelError, reason_code: &str) {
    assert_eq!(err.code, ErrorCode::CapabilityDenied);
    assert!(
        err.details["reason_codes"]
            .as_array()
            .expect("reason codes should be present")
            .iter()
            .any(|value| value.as_str() == Some(reason_code)),
        "expected reason code {reason_code}, got {:?}",
        err.details["reason_codes"]
    );
}

#[test]
fn context_pack_journal_uses_canonical_run_events() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let mut request = minimal_request();
    request.request_id = "req-context-journal".to_string();

    let grant = authorize_execution(&cfg, &policy, &request, None)
        .expect("context-required request should authorize");
    let binding = grant
        .context_evidence_binding
        .expect("context evidence binding should be present");
    assert!(binding.model_visible_context_ref.is_some());

    let journal_path = cfg
        .execution_control_root
        .join("runs")
        .join(&request.request_id)
        .join("events.ndjson");
    let raw = fs::read_to_string(&journal_path).expect("read run journal");
    assert!(
        !raw.contains("run.context_pack_"),
        "canonical journal must not persist runtime-event-v1 aliases"
    );
    let event_types: Vec<String> = raw
        .lines()
        .filter(|line| !line.trim().is_empty())
        .map(|line| {
            serde_json::from_str::<serde_json::Value>(line)
                .expect("journal event should parse")["event_type"]
                .as_str()
                .expect("event_type should be a string")
                .to_string()
        })
        .collect();
    assert!(event_types.iter().any(|value| value == "context-pack-requested"));
    assert!(event_types.iter().any(|value| value == "context-pack-built"));
    assert!(event_types.iter().any(|value| value == "context-pack-bound"));
}

#[test]
fn lifecycle_reconstruction_authorizes_from_journal_head() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let mut request = minimal_request();
    request.request_id = "req-lifecycle-authorized".to_string();

    authorize_execution(&cfg, &policy, &request, None).expect("request should authorize");
    let report = validate_run_lifecycle_operation(
        &cfg.repo_root,
        &request.request_id,
        RunLifecycleOperation::Start,
    )
    .expect("authorized run should pass start gate");
    assert_eq!(report.reconstructed_state, "authorized");
    assert!(report.runtime_state_match);
    assert!(report.latest_sequence.is_some());
    assert!(report.latest_hash.is_some());
}

#[test]
fn lifecycle_gate_blocks_runtime_state_drift() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let mut request = minimal_request();
    request.request_id = "req-lifecycle-drift".to_string();

    authorize_execution(&cfg, &policy, &request, None).expect("request should authorize");
    let runtime_state_path = cfg
        .execution_control_root
        .join("runs")
        .join(&request.request_id)
        .join("runtime-state.yml");
    let mut state: serde_yaml::Mapping =
        serde_yaml::from_str(&fs::read_to_string(&runtime_state_path).expect("read state"))
            .expect("parse runtime-state");
    state.insert(
        serde_yaml::Value::String("state".to_string()),
        serde_yaml::Value::String("running".to_string()),
    );
    fs::write(
        &runtime_state_path,
        serde_yaml::to_string(&state).expect("serialize tampered state"),
    )
    .expect("write tampered runtime-state");

    let err = validate_run_lifecycle_operation(
        &cfg.repo_root,
        &request.request_id,
        RunLifecycleOperation::Inspect,
    )
    .expect_err("runtime-state drift should fail closed");
    assert_eq!(err.code, ErrorCode::CapabilityDenied);
    assert!(
        err.details["reason_codes"]
            .as_array()
            .expect("reason codes")
            .iter()
            .any(|value| value.as_str() == Some("RUN_LIFECYCLE_DRIFT"))
    );
}

#[test]
fn material_effect_consumption_outside_running_is_rejected() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let mut request = minimal_request();
    request.request_id = "req-effect-outside-running".to_string();
    request.action_type = "mutate_repo".to_string();
    request.side_effect_flags.write_repo = true;
    request.policy_mode_requested = Some("hard-enforce".to_string());
    let grant = authorize_execution(&cfg, &policy, &request, None).expect("request should authorize");
    let runtime_path = cfg.execution_tmp_root.join(&request.request_id);
    fs::create_dir_all(&runtime_path).expect("create runtime path");
    let effect = issue_repo_mutation_effect(&runtime_path, &grant, "repo-scope")
        .expect("repo effect should mint");

    let err = verify_authorized_effect(
        &runtime_path,
        &grant,
        &effect,
        "test::repo_consumer",
        "repo-scope",
    )
    .expect_err("repo mutation should not verify before running");
    assert!(
        err.details["reason_codes"]
            .as_array()
            .expect("reason codes should be present")
            .iter()
            .any(|value| value.as_str() == Some("EFFECT_TOKEN_WRONG_LIFECYCLE_STATE"))
    );
}

#[test]
fn context_pack_retains_exact_model_visible_hash() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let mut request = minimal_request();
    request.request_id = "req-model-visible-hash".to_string();

    let grant = authorize_execution(&cfg, &policy, &request, None)
        .expect("context-required request should authorize");
    let binding = grant
        .context_evidence_binding
        .expect("context evidence binding should be present");
    let model_ref = binding
        .model_visible_context_ref
        .expect("model-visible context ref should be bound");
    let model_path = cfg.repo_root.join(model_ref);
    let model_bytes = fs::read(&model_path).expect("read model-visible context");
    let computed = format!("sha256:{}", sha256_bytes(&model_bytes));
    assert_eq!(
        binding.model_visible_context_sha256.as_deref(),
        Some(computed.as_str())
    );
    let retained_hash = fs::read_to_string(model_path.with_file_name("model-visible-context.sha256"))
        .expect("read retained model-visible hash");
    assert_eq!(retained_hash.trim(), computed);
}

#[test]
fn supplied_context_binding_model_hash_mismatch_denies() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let mut request = minimal_request();
    request.request_id = "req-context-hash-mismatch".to_string();
    let grant = authorize_execution(&cfg, &policy, &request, None)
        .expect("context-required request should authorize");
    let mut binding = grant
        .context_evidence_binding
        .expect("context evidence binding should be present");
    binding.model_visible_context_sha256 = Some(
        "sha256:0000000000000000000000000000000000000000000000000000000000000000"
            .to_string(),
    );
    request.context_evidence_binding = Some(binding);
    let err = authorize_execution(&cfg, &policy, &request, None)
        .expect_err("model-visible hash mismatch should deny");
    assert_eq!(err.code, ErrorCode::CapabilityDenied);
    assert!(
        err.details["reason_codes"]
            .as_array()
            .expect("reason codes should be present")
            .iter()
            .any(|value| value.as_str() == Some("CONTEXT_MODEL_VISIBLE_DIGEST_MISMATCH"))
    );
}

#[test]
fn optional_supplied_context_binding_is_still_validated() {
    let (cfg, mut request, mut binding) =
        supplied_context_fixture("req-optional-context-binding-invalid");
    let policy = PolicyEngine::new(cfg.clone());
    request.side_effect_flags = SideEffectFlags::default();
    request.requires_context_evidence = false;
    request.boundary_sensitive = false;
    request
        .metadata
        .insert("support_tier".to_string(), "observe-and-read".to_string());
    binding.model_visible_context_sha256 = Some(
        "sha256:0000000000000000000000000000000000000000000000000000000000000000"
            .to_string(),
    );
    request.context_evidence_binding = Some(binding);

    let err = authorize_execution(&cfg, &policy, &request, None)
        .expect_err("optional supplied context binding should still be validated");
    assert_context_reason(err, "CONTEXT_MODEL_VISIBLE_DIGEST_MISMATCH");
}

#[test]
fn execution_request_payload_includes_authorized_context_binding() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let mut request = minimal_request();
    request.request_id = "req-optional-context-payload".to_string();
    request.side_effect_flags = SideEffectFlags::default();
    request.requires_context_evidence = false;
    request.boundary_sensitive = false;
    request
        .metadata
        .insert("support_tier".to_string(), "observe-and-read".to_string());

    let grant = authorize_execution(&cfg, &policy, &request, None)
        .expect("authorization should build context-pack proof before authorizing");
    let binding = grant
        .context_evidence_binding
        .as_ref()
        .expect("Context Pack Builder v1 binding should be retained");
    assert_eq!(grant.context_pack_ref.as_deref(), Some(binding.context_pack_ref.as_str()));

    let payload = phases::receipt::execution_request_payload(&request, &grant);
    assert_eq!(payload["context_pack_ref"], binding.context_pack_ref);
    assert_eq!(
        payload["context_evidence_binding"]["context_pack_receipt_ref"],
        binding.context_pack_receipt_ref
    );
}

#[test]
fn supplied_context_binding_stale_or_invalidated_denies() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let mut request = minimal_request();
    request.request_id = "req-context-state-deny".to_string();
    let grant = authorize_execution(&cfg, &policy, &request, None)
        .expect("context-required request should authorize");
    let binding = grant
        .context_evidence_binding
        .expect("context evidence binding should be present");

    let mut stale_request = request.clone();
    let mut stale_binding = binding.clone();
    stale_binding.valid_until = Some("2020-01-01T00:00:00Z".to_string());
    stale_request.context_evidence_binding = Some(stale_binding);
    let stale_err = authorize_execution(&cfg, &policy, &stale_request, None)
        .expect_err("expired context binding should deny");
    assert_eq!(stale_err.code, ErrorCode::CapabilityDenied);

    let mut invalidated_request = request;
    let mut invalidated_binding = binding;
    invalidated_binding.context_validity_state = Some("invalidated".to_string());
    invalidated_request.context_evidence_binding = Some(invalidated_binding);
    let invalidated_err = authorize_execution(&cfg, &policy, &invalidated_request, None)
        .expect_err("invalidated context binding should deny");
    assert_eq!(invalidated_err.code, ErrorCode::CapabilityDenied);
}

#[test]
fn supplied_context_binding_missing_hash_sidecar_denies() {
    let (cfg, mut request, binding) = supplied_context_fixture("req-context-missing-hash-file");
    let policy = PolicyEngine::new(cfg.clone());
    let model_path = repo_ref_path(
        &cfg,
        binding
            .model_visible_context_ref
            .as_deref()
            .expect("model-visible ref"),
    );
    fs::remove_file(model_path.with_file_name("model-visible-context.sha256"))
        .expect("remove retained model-visible hash");

    request.context_evidence_binding = Some(binding);
    let err = authorize_execution(&cfg, &policy, &request, None)
        .expect_err("missing retained model-visible hash should deny");
    assert_context_reason(err, "CONTEXT_MODEL_VISIBLE_HASH_MISSING");
}

#[test]
fn supplied_context_binding_missing_source_manifest_denies() {
    let (cfg, mut request, binding) = supplied_context_fixture("req-context-missing-source-manifest");
    let policy = PolicyEngine::new(cfg.clone());
    let receipt_path = repo_ref_path(&cfg, &binding.context_pack_receipt_ref);
    let receipt = read_json_value(&receipt_path);
    let source_manifest_ref = receipt["source_manifest_ref"]
        .as_str()
        .expect("source manifest ref");
    fs::remove_file(repo_ref_path(&cfg, source_manifest_ref))
        .expect("remove retained source manifest");

    request.context_evidence_binding = Some(binding);
    let err = authorize_execution(&cfg, &policy, &request, None)
        .expect_err("missing retained source manifest should deny");
    assert_context_reason(err, "CONTEXT_SOURCE_MANIFEST_MISSING");
}

#[test]
fn supplied_context_binding_replay_refs_missing_hash_denies() {
    let (cfg, mut request, mut binding) =
        supplied_context_fixture("req-context-replay-missing-hash-ref");
    let policy = PolicyEngine::new(cfg.clone());
    let receipt_path = repo_ref_path(&cfg, &binding.context_pack_receipt_ref);
    let mut receipt = read_json_value(&receipt_path);
    let hash_ref = binding
        .model_visible_context_ref
        .as_deref()
        .expect("model-visible ref")
        .replace("model-visible-context.json", "model-visible-context.sha256");
    receipt["replay_reconstruction_refs"]
        .as_array_mut()
        .expect("replay refs")
        .retain(|value| value.as_str() != Some(hash_ref.as_str()));
    write_json_value(&receipt_path, &receipt);
    binding.receipt_sha256 = format!("sha256:{}", fixture_sha256(&receipt_path));

    request.context_evidence_binding = Some(binding);
    let err = authorize_execution(&cfg, &policy, &request, None)
        .expect_err("missing replay hash ref should deny");
    assert_context_reason(err, "CONTEXT_REPLAY_REF_MISSING");
}

#[test]
fn supplied_context_binding_retained_source_manifest_mismatch_denies() {
    let (cfg, mut request, binding) = supplied_context_fixture("req-context-source-manifest-mismatch");
    let policy = PolicyEngine::new(cfg.clone());
    let receipt_path = repo_ref_path(&cfg, &binding.context_pack_receipt_ref);
    let receipt = read_json_value(&receipt_path);
    let source_manifest_ref = receipt["source_manifest_ref"]
        .as_str()
        .expect("source manifest ref");
    write_json_value(
        &repo_ref_path(&cfg, source_manifest_ref),
        &json!([".octon/framework/context/tampered.md sha256:0000000000000000000000000000000000000000000000000000000000000000"]),
    );

    request.context_evidence_binding = Some(binding);
    let err = authorize_execution(&cfg, &policy, &request, None)
        .expect_err("retained source manifest mismatch should deny");
    assert_context_reason(err, "CONTEXT_SOURCE_MANIFEST_MISMATCH");
}

#[test]
fn supplied_context_binding_missing_source_file_denies() {
    let (cfg, mut request, binding) = supplied_context_fixture("req-context-missing-source-file");
    let policy = PolicyEngine::new(cfg.clone());
    let receipt_path = repo_ref_path(&cfg, &binding.context_pack_receipt_ref);
    let receipt = read_json_value(&receipt_path);
    let source_ref = receipt["sources"]
        .as_array()
        .expect("sources")
        .iter()
        .find_map(|source| source["source_ref"].as_str())
        .expect("source ref");
    fs::remove_file(repo_ref_path(&cfg, source_ref)).expect("remove valid source");

    request.context_evidence_binding = Some(binding);
    let err = authorize_execution(&cfg, &policy, &request, None)
        .expect_err("missing source file should deny");
    assert_context_reason(err, "CONTEXT_SOURCE_MISSING");
}

#[test]
fn supplied_context_binding_source_digest_drift_denies() {
    let (cfg, mut request, binding) = supplied_context_fixture("req-context-source-digest-drift");
    let policy = PolicyEngine::new(cfg.clone());
    let receipt_path = repo_ref_path(&cfg, &binding.context_pack_receipt_ref);
    let receipt = read_json_value(&receipt_path);
    let source_ref = receipt["sources"]
        .as_array()
        .expect("sources")
        .iter()
        .find_map(|source| source["source_ref"].as_str())
        .expect("source ref");
    fs::write(repo_ref_path(&cfg, source_ref), "tampered source\n").expect("tamper source");

    request.context_evidence_binding = Some(binding);
    let err = authorize_execution(&cfg, &policy, &request, None)
        .expect_err("source digest drift should deny");
    assert_context_reason(err, "CONTEXT_SOURCE_DIGEST_MISMATCH");
}

#[test]
fn absolute_generated_authority_path_normalizes_to_forbidden_prefix() {
    let cfg = temp_runtime_config();
    let generated_source = cfg
        .repo_root
        .join(".octon/generated/effective/runtime/route-bundle.yml")
        .display()
        .to_string();
    let normalized = normalized_repo_relative_ref(&cfg.repo_root, &generated_source)
        .expect("absolute repo-local source should normalize");
    assert!(normalized.starts_with(".octon/generated/"));
}

fn effect_token_record_path(runtime_path: &Path, token_record_ref: &str) -> PathBuf {
    resolve_relative_from_runtime_path(runtime_path, token_record_ref)
        .expect("token record path should resolve")
}

fn recompute_effect_token_digest(payload: &AuthorizedEffectPayload) -> String {
    let mut canonical = payload.clone();
    canonical.token_digest.clear();
    format!(
        "sha256:{}",
        sha256_bytes(&serde_json::to_vec(&canonical).expect("serialize token digest payload"))
    )
}

fn rewrite_effect_payload<T: EffectKind>(
    runtime_path: &Path,
    effect: &AuthorizedEffect<T>,
    mutate: impl FnOnce(&mut AuthorizedEffectPayload),
) -> AuthorizedEffect<T> {
    let record_path = effect_token_record_path(runtime_path, effect.token_record_ref());
    let mut record: serde_json::Value = serde_json::from_str(
        &fs::read_to_string(&record_path).expect("read token record"),
    )
    .expect("parse token record");
    let mut payload: AuthorizedEffectPayload =
        serde_json::from_value(record["payload"].clone()).expect("parse token payload");
    mutate(&mut payload);
    payload.token_digest = recompute_effect_token_digest(&payload);
    record["payload"] = serde_json::to_value(&payload).expect("serialize token payload");
    fs::write(
        &record_path,
        serde_json::to_vec_pretty(&record).expect("serialize updated token record"),
    )
    .expect("write updated token record");
    octon_authorized_effects::authority_mint::mint_authorized_effect::<T>(payload)
}

fn assert_effect_denial(err: KernelError, code: &str, reason: &str) {
    assert_eq!(err.code, ErrorCode::CapabilityDenied);
    let message = err.to_string();
    assert!(
        message.contains(code),
        "expected error code {code}, got {message}"
    );
    assert!(
        message.contains(reason),
        "expected denial reason {reason}, got {message}"
    );
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
fn invoke_service_requests_always_grant_service_invocation_effects() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let mut request = minimal_request();
    request.action_type = "invoke_service".to_string();
    request.target_id = "interfaces/filesystem-watch::watch.poll".to_string();
    request.side_effect_flags.network = false;
    request.side_effect_flags.model_invoke = false;

    let grant = authorize_execution(&cfg, &policy, &request, None)
        .expect("invoke_service request should authorize");
    assert!(
        grant.granted_effect_kinds
            .iter()
            .any(|kind| kind == ServiceInvocation::KIND),
        "invoke_service requests must always carry the service-invocation effect grant"
    );
}

#[test]
fn issued_effect_verifies_and_records_consumption_receipt() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let request = minimal_request();
    let grant = authorize_execution(&cfg, &policy, &request, None).expect("request should authorize");
    let runtime_path = start_run_for_effect_consumption(&cfg, &request, &grant);
    let effect = issue_service_invocation_effect(&runtime_path, &grant, "service::invoke")
        .expect("service effect should mint");
    let verified = verify_authorized_effect(
        &runtime_path,
        &grant,
        &effect,
        "test::service_consumer",
        "service::invoke",
    )
    .expect("service effect should verify");
    assert_eq!(verified.token_id(), effect.token_id());
    let receipt_path = cfg
        .repo_root
        .join(verified.consumption_receipt_ref());
    assert!(receipt_path.is_file(), "consumption receipt must exist");
    let receipt = read_json_value(&receipt_path);
    assert_eq!(
        receipt["verifier_version"].as_str(),
        Some("authorized-effect-verifier-v1")
    );
    assert_eq!(
        receipt["source_token_digest"].as_str(),
        Some(effect.token_digest())
    );
}

#[test]
fn acp_runner_empty_stdout_surfaces_stderr_context() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let fake_runner = cfg
        .repo_root
        .join(".octon/generated/.tmp/tests/fake-policy-runner.sh");
    if let Some(parent) = fake_runner.parent() {
        fs::create_dir_all(parent).expect("create fake policy runner parent");
    }
    fs::write(
        &fake_runner,
        "#!/usr/bin/env bash\necho 'fixture ACP failure' >&2\nexit 2\n",
    )
    .expect("write fake policy runner");

    let prior = std::env::var("OCTON_POLICY_RUNNER_OVERRIDE").ok();
    let prior_route_bundle = std::env::var("OCTON_ALLOW_STALE_RUNTIME_ROUTE_BUNDLE").ok();
    std::env::set_var("OCTON_POLICY_RUNNER_OVERRIDE", &fake_runner);
    std::env::set_var("OCTON_ALLOW_STALE_RUNTIME_ROUTE_BUNDLE", "1");
    let err = authorize_execution(&cfg, &policy, &minimal_request(), None)
        .expect_err("empty ACP stdout must fail with stderr context");
    match prior {
        Some(value) => std::env::set_var("OCTON_POLICY_RUNNER_OVERRIDE", value),
        None => std::env::remove_var("OCTON_POLICY_RUNNER_OVERRIDE"),
    }
    match prior_route_bundle {
        Some(value) => std::env::set_var("OCTON_ALLOW_STALE_RUNTIME_ROUTE_BUNDLE", value),
        None => std::env::remove_var("OCTON_ALLOW_STALE_RUNTIME_ROUTE_BUNDLE"),
    }
    assert!(
        err.to_string().contains("fixture ACP failure")
            || err.to_string().contains("no JSON decision output")
    );
}

#[test]
fn missing_token_record_fails_closed() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let request = minimal_request();
    let grant = authorize_execution(&cfg, &policy, &request, None).expect("request should authorize");
    let runtime_path = cfg.execution_tmp_root.join(&request.request_id);
    let effect = issue_service_invocation_effect(&runtime_path, &grant, "service::invoke")
        .expect("service effect should mint");
    let record_path = effect_token_record_path(&runtime_path, effect.token_record_ref());
    fs::remove_file(&record_path).expect("remove token record");
    let err = verify_authorized_effect(
        &runtime_path,
        &grant,
        &effect,
        "test::missing_record",
        "service::invoke",
    )
    .expect_err("missing token record must fail closed");
    assert_effect_denial(err, "EFFECT_TOKEN_RECORD_MISSING", "missing_token");
}

#[test]
fn denied_grant_rejects_effect_consumption() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let request = minimal_request();
    let grant = authorize_execution(&cfg, &policy, &request, None).expect("request should authorize");
    let runtime_path = start_run_for_effect_consumption(&cfg, &request, &grant);
    let effect = issue_service_invocation_effect(&runtime_path, &grant, "service::invoke")
        .expect("service effect should mint");
    let mut denied_grant = grant.clone();
    denied_grant.decision = ExecutionDecision::Deny;
    let err = verify_authorized_effect(
        &runtime_path,
        &denied_grant,
        &effect,
        "test::service_consumer",
        "service::invoke",
    )
    .expect_err("denied grant must fail");
    assert_effect_denial(
        err,
        "EFFECT_TOKEN_DECISION_NOT_ALLOW",
        "decision_not_allow",
    );
}

#[test]
fn single_use_effect_cannot_be_consumed_twice() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let mut request = minimal_request();
    request.action_type = "mutate_repo".to_string();
    request.side_effect_flags.write_repo = true;
    request.policy_mode_requested = Some("hard-enforce".to_string());
    let grant = authorize_execution(&cfg, &policy, &request, None).expect("request should authorize");
    let runtime_path = start_run_for_effect_consumption(&cfg, &request, &grant);
    let effect = issue_repo_mutation_effect(&runtime_path, &grant, "repo-scope")
        .expect("repo effect should mint");
    verify_authorized_effect(
        &runtime_path,
        &grant,
        &effect,
        "test::repo_consumer",
        "repo-scope",
    )
    .expect("first consumption should verify");
    let err = verify_authorized_effect(
        &runtime_path,
        &grant,
        &effect,
        "test::repo_consumer",
        "repo-scope",
    )
    .expect_err("second single-use consumption must fail");
    assert_effect_denial(
        err,
        "EFFECT_TOKEN_ALREADY_CONSUMED",
        "already_consumed",
    );
}

#[test]
fn wrong_scope_effect_fails_closed() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let mut request = minimal_request();
    request.action_type = "mutate_repo".to_string();
    request.side_effect_flags.write_repo = true;
    request.policy_mode_requested = Some("hard-enforce".to_string());
    let grant = authorize_execution(&cfg, &policy, &request, None).expect("request should authorize");
    let runtime_path = start_run_for_effect_consumption(&cfg, &request, &grant);
    let effect = issue_repo_mutation_effect(&runtime_path, &grant, "allowed-scope")
        .expect("repo effect should mint");
    let err = verify_authorized_effect(
        &runtime_path,
        &grant,
        &effect,
        "test::repo_consumer",
        "other-scope",
    )
    .expect_err("scope mismatch must fail");
    assert_effect_denial(err, "EFFECT_TOKEN_SCOPE_MISMATCH", "wrong_scope");
}

#[test]
fn expired_effect_is_rejected() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let request = minimal_request();
    let grant = authorize_execution(&cfg, &policy, &request, None).expect("request should authorize");
    let runtime_path = start_run_for_effect_consumption(&cfg, &request, &grant);
    let effect = issue_service_invocation_effect(&runtime_path, &grant, "service::invoke")
        .expect("service effect should mint");
    let record_path = effect_token_record_path(&runtime_path, effect.token_record_ref());
    let mut record: serde_json::Value = serde_json::from_str(
        &fs::read_to_string(&record_path).expect("read token record"),
    )
    .expect("parse token record");
    record["payload"]["expires_at"] = serde_json::Value::String("2000-01-01T00:00:00Z".to_string());
    let payload: AuthorizedEffectPayload = serde_json::from_value(record["payload"].clone())
        .expect("parse token payload");
    record["payload"]["token_digest"] =
        serde_json::Value::String(recompute_effect_token_digest(&payload));
    fs::write(
        &record_path,
        serde_json::to_vec_pretty(&record).expect("serialize updated token record"),
    )
    .expect("write updated token record");
    let expired_effect = octon_authorized_effects::authority_mint::mint_authorized_effect::<
        ServiceInvocation,
    >(
        serde_json::from_value(record["payload"].clone()).expect("rebuild expired token"),
    );
    let err = verify_authorized_effect(
        &runtime_path,
        &grant,
        &expired_effect,
        "test::service_consumer",
        "service::invoke",
    )
    .expect_err("expired token must fail");
    assert_effect_denial(err, "EFFECT_TOKEN_EXPIRED", "expired_token");
}

#[test]
fn forged_effect_digest_is_rejected() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let request = minimal_request();
    let grant = authorize_execution(&cfg, &policy, &request, None).expect("request should authorize");
    let runtime_path = start_run_for_effect_consumption(&cfg, &request, &grant);
    let effect = issue_service_invocation_effect(&runtime_path, &grant, "service::invoke")
        .expect("service effect should mint");
    let record_path = effect_token_record_path(&runtime_path, effect.token_record_ref());
    let mut record = read_json_value(&record_path);
    record["payload"]["token_digest"] = serde_json::Value::String(format!(
        "sha256:{}",
        "0".repeat(64)
    ));
    write_json_value(&record_path, &record);
    let err = verify_authorized_effect(
        &runtime_path,
        &grant,
        &effect,
        "test::service_consumer",
        "service::invoke",
    )
    .expect_err("forged digest must fail");
    assert_effect_denial(err, "EFFECT_TOKEN_DIGEST_MISMATCH", "forged_token");
}

#[test]
fn wrong_effect_class_is_rejected() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let request = minimal_request();
    let grant = authorize_execution(&cfg, &policy, &request, None).expect("request should authorize");
    let runtime_path = start_run_for_effect_consumption(&cfg, &request, &grant);
    let effect = issue_service_invocation_effect(&runtime_path, &grant, "service::invoke")
        .expect("service effect should mint");
    let wrong_kind = rewrite_effect_payload(&runtime_path, &effect, |payload| {
        payload.effect_kind = RepoMutation::KIND.to_string();
        payload.token_type = "AuthorizedEffect<RepoMutation>".to_string();
    });
    let err = verify_authorized_effect(
        &runtime_path,
        &grant,
        &wrong_kind,
        "test::service_consumer",
        "service::invoke",
    )
    .expect_err("wrong effect class must fail");
    assert_effect_denial(err, "EFFECT_TOKEN_KIND_MISMATCH", "wrong_effect_class");
}

#[test]
fn wrong_run_binding_is_rejected() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let request = minimal_request();
    let grant = authorize_execution(&cfg, &policy, &request, None).expect("request should authorize");
    let runtime_path = start_run_for_effect_consumption(&cfg, &request, &grant);
    let effect = issue_service_invocation_effect(&runtime_path, &grant, "service::invoke")
        .expect("service effect should mint");
    let wrong_run = rewrite_effect_payload(&runtime_path, &effect, |payload| {
        payload.run_id = "other-run".to_string();
    });
    let err = verify_authorized_effect(
        &runtime_path,
        &grant,
        &wrong_run,
        "test::service_consumer",
        "service::invoke",
    )
    .expect_err("wrong run binding must fail");
    assert_effect_denial(err, "EFFECT_TOKEN_RUN_MISMATCH", "wrong_run");
}

#[test]
fn wrong_route_binding_is_rejected() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let request = minimal_request();
    let grant = authorize_execution(&cfg, &policy, &request, None).expect("request should authorize");
    let runtime_path = start_run_for_effect_consumption(&cfg, &request, &grant);
    let effect = issue_service_invocation_effect(&runtime_path, &grant, "service::invoke")
        .expect("service effect should mint");
    let wrong_route = rewrite_effect_payload(&runtime_path, &effect, |payload| {
        payload.route_id = Some("runtime-route:wrong:tuple://wrong".to_string());
    });
    let err = verify_authorized_effect(
        &runtime_path,
        &grant,
        &wrong_route,
        "test::service_consumer",
        "service::invoke",
    )
    .expect_err("wrong route binding must fail");
    assert_effect_denial(err, "EFFECT_TOKEN_ROUTE_MISMATCH", "wrong_route");
}

#[test]
fn stale_runtime_effective_route_rejects_effect_consumption() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let request = minimal_request();
    let grant = authorize_execution(&cfg, &policy, &request, None).expect("request should authorize");
    let runtime_path = start_run_for_effect_consumption(&cfg, &request, &grant);
    let effect = issue_service_invocation_effect(&runtime_path, &grant, "service::invoke")
        .expect("service effect should mint");
    fs::write(
        cfg.repo_root
            .join(".octon/generated/effective/runtime/route-bundle.yml"),
        "schema_version: octon-runtime-effective-route-bundle-v1\ngeneration_id: stale-fixture\nroutes: []\n",
    )
    .expect("tamper runtime-effective route bundle");

    let err = verify_authorized_effect(
        &runtime_path,
        &grant,
        &effect,
        "test::service_consumer",
        "service::invoke",
    )
    .expect_err("stale runtime-effective route must fail");
    assert_effect_denial(err, "EFFECT_TOKEN_FRESHNESS_STALE", "stale_token");
}

#[test]
fn wrong_support_tuple_is_rejected() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let request = minimal_request();
    let grant = authorize_execution(&cfg, &policy, &request, None).expect("request should authorize");
    let runtime_path = start_run_for_effect_consumption(&cfg, &request, &grant);
    let effect = issue_service_invocation_effect(&runtime_path, &grant, "service::invoke")
        .expect("service effect should mint");
    let wrong_support = rewrite_effect_payload(&runtime_path, &effect, |payload| {
        payload.support_target_tuple_ref = Some(
            "tuple://repo-local-governed/observe-read/reference-owned/english-primary/repo-shell"
                .to_string(),
        );
    });
    let err = verify_authorized_effect(
        &runtime_path,
        &grant,
        &wrong_support,
        "test::service_consumer",
        "service::invoke",
    )
    .expect_err("wrong support tuple must fail");
    assert_effect_denial(
        err,
        "EFFECT_TOKEN_SUPPORT_TUPLE_MISMATCH",
        "wrong_support_tuple",
    );
}

#[test]
fn support_envelope_block_rejects_effect_consumption() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let request = minimal_request();
    let grant = authorize_execution(&cfg, &policy, &request, None).expect("request should authorize");
    let runtime_path = start_run_for_effect_consumption(&cfg, &request, &grant);
    let effect = issue_service_invocation_effect(&runtime_path, &grant, "service::invoke")
        .expect("service effect should mint");

    let tuple_ref = grant
        .support_target_tuple_ref
        .as_deref()
        .expect("grant should bind a support tuple");
    let envelope_path = cfg
        .repo_root
        .join(".octon/generated/effective/governance/support-envelope-reconciliation.yml");
    let mut envelope: serde_yaml::Value =
        serde_yaml::from_str(&fs::read_to_string(&envelope_path).expect("read support envelope"))
            .expect("parse support envelope");
    let tuple = envelope["tuples"]
        .as_sequence_mut()
        .expect("support envelope tuples")
        .iter_mut()
        .find(|entry| entry["tuple_ref"].as_str() == Some(tuple_ref))
        .expect("support envelope tuple exists");
    tuple["effective"] = serde_yaml::Value::String("blocked".to_string());
    tuple["diagnostics"] = serde_yaml::Value::Sequence(vec![serde_yaml::Value::String(
        "fixture_support_envelope_block".to_string(),
    )]);
    fs::write(
        &envelope_path,
        serde_yaml::to_string(&envelope).expect("serialize support envelope"),
    )
    .expect("write blocked support envelope");

    let err = verify_authorized_effect(
        &runtime_path,
        &grant,
        &effect,
        "test::service_consumer",
        "service::invoke",
    )
    .expect_err("blocked support envelope must fail");
    assert_effect_denial(
        err,
        "EFFECT_TOKEN_SUPPORT_ENVELOPE_BLOCKED",
        "wrong_support_tuple",
    );
}

#[test]
fn unsupported_support_envelope_tuple_is_rejected() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let request = minimal_request();
    let grant = authorize_execution(&cfg, &policy, &request, None).expect("request should authorize");
    let runtime_path = start_run_for_effect_consumption(&cfg, &request, &grant);
    let effect = issue_service_invocation_effect(&runtime_path, &grant, "service::invoke")
        .expect("service effect should mint");

    let tuple_ref = grant
        .support_target_tuple_ref
        .as_deref()
        .expect("grant should bind a support tuple");
    let envelope_path = cfg
        .repo_root
        .join(".octon/generated/effective/governance/support-envelope-reconciliation.yml");
    let mut envelope: serde_yaml::Value =
        serde_yaml::from_str(&fs::read_to_string(&envelope_path).expect("read support envelope"))
            .expect("parse support envelope");
    let tuple = envelope["tuples"]
        .as_sequence_mut()
        .expect("support envelope tuples")
        .iter_mut()
        .find(|entry| entry["tuple_ref"].as_str() == Some(tuple_ref))
        .expect("support envelope tuple exists");
    tuple["generated_matrix"] = serde_yaml::Value::String("not_supported".to_string());
    fs::write(
        &envelope_path,
        serde_yaml::to_string(&envelope).expect("serialize support envelope"),
    )
    .expect("write unsupported support envelope");

    let err = verify_authorized_effect(
        &runtime_path,
        &grant,
        &effect,
        "test::service_consumer",
        "service::invoke",
    )
    .expect_err("unsupported support envelope tuple must fail");
    assert_effect_denial(
        err,
        "EFFECT_TOKEN_SUPPORT_TUPLE_UNSUPPORTED",
        "unsupported_tuple",
    );
}

#[test]
fn excluded_support_envelope_tuple_is_rejected() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let request = minimal_request();
    let grant = authorize_execution(&cfg, &policy, &request, None).expect("request should authorize");
    let runtime_path = start_run_for_effect_consumption(&cfg, &request, &grant);
    let effect = issue_service_invocation_effect(&runtime_path, &grant, "service::invoke")
        .expect("service effect should mint");

    let tuple_ref = grant
        .support_target_tuple_ref
        .as_deref()
        .expect("grant should bind a support tuple");
    let envelope_path = cfg
        .repo_root
        .join(".octon/generated/effective/governance/support-envelope-reconciliation.yml");
    let mut envelope: serde_yaml::Value =
        serde_yaml::from_str(&fs::read_to_string(&envelope_path).expect("read support envelope"))
            .expect("parse support envelope");
    let tuple = envelope["tuples"]
        .as_sequence_mut()
        .expect("support envelope tuples")
        .iter_mut()
        .find(|entry| entry["tuple_ref"].as_str() == Some(tuple_ref))
        .expect("support envelope tuple exists");
    tuple["effective"] = serde_yaml::Value::String("excluded".to_string());
    fs::write(
        &envelope_path,
        serde_yaml::to_string(&envelope).expect("serialize support envelope"),
    )
    .expect("write excluded support envelope");

    let err = verify_authorized_effect(
        &runtime_path,
        &grant,
        &effect,
        "test::service_consumer",
        "service::invoke",
    )
    .expect_err("excluded support envelope tuple must fail");
    assert_effect_denial(
        err,
        "EFFECT_TOKEN_SUPPORT_TUPLE_EXCLUDED",
        "excluded_tuple",
    );
}

#[test]
fn wrong_capability_pack_is_rejected() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let request = minimal_request();
    let grant = authorize_execution(&cfg, &policy, &request, None).expect("request should authorize");
    let runtime_path = start_run_for_effect_consumption(&cfg, &request, &grant);
    let effect = issue_service_invocation_effect(&runtime_path, &grant, "service::invoke")
        .expect("service effect should mint");
    let wrong_pack = rewrite_effect_payload(&runtime_path, &effect, |payload| {
        payload.allowed_capability_packs = vec!["unadmitted-pack".to_string()];
    });
    let err = verify_authorized_effect(
        &runtime_path,
        &grant,
        &wrong_pack,
        "test::service_consumer",
        "service::invoke",
    )
    .expect_err("wrong capability pack must fail");
    assert_effect_denial(
        err,
        "EFFECT_TOKEN_CAPABILITY_PACK_MISMATCH",
        "wrong_capability_pack",
    );
}

#[test]
fn active_revocation_rejects_effect_consumption() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let request = minimal_request();
    let grant = authorize_execution(&cfg, &policy, &request, None).expect("request should authorize");
    let runtime_path = start_run_for_effect_consumption(&cfg, &request, &grant);
    let effect = issue_service_invocation_effect(&runtime_path, &grant, "service::invoke")
        .expect("service effect should mint");
    fs::write(
        cfg.execution_control_root
            .join("revocations")
            .join("token-test.yml"),
        format!(
            "schema_version: authority-revocation-v1\nrevocation_id: token-test\ngrant_id: {}\nrequest_id: {}\nstate: active\nrevoked_at: 2026-04-24T00:00:00Z\nrevoked_by: operator://test\nreason_codes:\n  - TEST_REVOCATION\n",
            grant.grant_id, grant.request_id
        ),
    )
    .expect("write revocation");
    let err = verify_authorized_effect(
        &runtime_path,
        &grant,
        &effect,
        "test::service_consumer",
        "service::invoke",
    )
    .expect_err("revoked effect must fail");
    assert_effect_denial(err, "EFFECT_TOKEN_REVOKED", "revoked_token");
}

#[test]
fn missing_approval_binding_rejects_effect_consumption() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let request = minimal_request();
    let grant = authorize_execution(&cfg, &policy, &request, None).expect("request should authorize");
    let runtime_path = start_run_for_effect_consumption(&cfg, &request, &grant);
    let effect = issue_service_invocation_effect(&runtime_path, &grant, "service::invoke")
        .expect("service effect should mint");
    let mut grant = grant;
    grant.approval_request_ref =
        Some(".octon/state/control/execution/approvals/requests/missing.yml".to_string());
    let err = verify_authorized_effect(
        &runtime_path,
        &grant,
        &effect,
        "test::service_consumer",
        "service::invoke",
    )
    .expect_err("missing approval must fail");
    assert_effect_denial(
        err,
        "EFFECT_TOKEN_APPROVAL_MISSING",
        "missing_approval",
    );
}

#[test]
fn missing_exception_binding_rejects_effect_consumption() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let request = minimal_request();
    let grant = authorize_execution(&cfg, &policy, &request, None).expect("request should authorize");
    let runtime_path = start_run_for_effect_consumption(&cfg, &request, &grant);
    let effect = issue_service_invocation_effect(&runtime_path, &grant, "service::invoke")
        .expect("service effect should mint");
    let mut grant = grant;
    grant.exception_lease_refs =
        vec![".octon/state/control/execution/exceptions/leases/missing.yml".to_string()];
    let err = verify_authorized_effect(
        &runtime_path,
        &grant,
        &effect,
        "test::service_consumer",
        "service::invoke",
    )
    .expect_err("missing exception must fail");
    assert_effect_denial(
        err,
        "EFFECT_TOKEN_EXCEPTION_MISSING",
        "missing_exception",
    );
}

#[test]
fn missing_rollback_posture_rejects_effect_consumption() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let request = minimal_request();
    let grant = authorize_execution(&cfg, &policy, &request, None).expect("request should authorize");
    let runtime_path = start_run_for_effect_consumption(&cfg, &request, &grant);
    let effect = issue_service_invocation_effect(&runtime_path, &grant, "service::invoke")
        .expect("service effect should mint");
    let mut grant = grant;
    grant.rollback_posture_ref =
        Some(".octon/state/control/execution/runs/missing/rollback-posture.yml".to_string());
    let err = verify_authorized_effect(
        &runtime_path,
        &grant,
        &effect,
        "test::service_consumer",
        "service::invoke",
    )
    .expect_err("missing rollback posture must fail");
    assert_effect_denial(
        err,
        "EFFECT_TOKEN_ROLLBACK_NOT_READY",
        "rollback_not_ready",
    );
}

#[test]
fn budget_denial_rejects_effect_consumption() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let request = minimal_request();
    let grant = authorize_execution(&cfg, &policy, &request, None).expect("request should authorize");
    let runtime_path = start_run_for_effect_consumption(&cfg, &request, &grant);
    let effect = issue_service_invocation_effect(&runtime_path, &grant, "service::invoke")
        .expect("service effect should mint");
    let mut grant = grant;
    grant.budget = Some(BudgetMetadata {
        rule_id: "budget-test".to_string(),
        reason_codes: vec!["BUDGET_EXCEEDED".to_string()],
        provider: None,
        model: None,
        estimated_cost_usd: Some(1000.0),
        actual_cost_usd: None,
        evidence_path: Some(".octon/state/evidence/runs/missing/budget.json".to_string()),
    });
    let err = verify_authorized_effect(
        &runtime_path,
        &grant,
        &effect,
        "test::service_consumer",
        "service::invoke",
    )
    .expect_err("budget-denied effect must fail");
    assert_effect_denial(err, "EFFECT_TOKEN_BUDGET_EXCEEDED", "budget_exceeded");
}

#[test]
fn egress_denial_rejects_effect_consumption() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let request = minimal_request();
    let grant = authorize_execution(&cfg, &policy, &request, None).expect("request should authorize");
    let runtime_path = start_run_for_effect_consumption(&cfg, &request, &grant);
    let effect = issue_service_invocation_effect(&runtime_path, &grant, "service::invoke")
        .expect("service effect should mint");
    let mut grant = grant;
    grant.network_egress_posture = Some(NetworkEgressPosture {
        route: "deny".to_string(),
        matched_rule_id: Some("egress-test".to_string()),
        source_kind: Some("policy".to_string()),
        artifact_ref: None,
        target_url: Some("https://example.invalid".to_string()),
    });
    let err = verify_authorized_effect(
        &runtime_path,
        &grant,
        &effect,
        "test::service_consumer",
        "service::invoke",
    )
    .expect_err("egress-denied effect must fail");
    assert_effect_denial(err, "EFFECT_TOKEN_EGRESS_DENIED", "egress_denied");
}

#[test]
fn verification_bundle_scope_mismatch_fails_closed() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let mut request = minimal_request();
    request.action_type = "mutate_repo".to_string();
    request.side_effect_flags.write_repo = true;
    request.scope_constraints.write = vec!["allowed-scope".to_string()];
    request.policy_mode_requested = Some("hard-enforce".to_string());
    let prior_route_bundle = std::env::var("OCTON_ALLOW_STALE_RUNTIME_ROUTE_BUNDLE").ok();
    std::env::set_var("OCTON_ALLOW_STALE_RUNTIME_ROUTE_BUNDLE", "1");
    let grant = authorize_execution(&cfg, &policy, &request, None).expect("request should authorize");
    match prior_route_bundle {
        Some(value) => std::env::set_var("OCTON_ALLOW_STALE_RUNTIME_ROUTE_BUNDLE", value),
        None => std::env::remove_var("OCTON_ALLOW_STALE_RUNTIME_ROUTE_BUNDLE"),
    }
    let runtime_path = start_run_for_effect_consumption(&cfg, &request, &grant);
    let execution_grant_path = runtime_path.join("grant-bundle.json");
    fs::write(
        &execution_grant_path,
        serde_json::to_vec_pretty(&grant).expect("serialize execution grant"),
    )
    .expect("write execution grant bundle");
    let effect =
        issue_repo_mutation_effect(&runtime_path, &grant, "allowed-scope").expect("repo effect should mint");
    let bundle_path = cfg
        .repo_root
        .join(".octon/generated/.tmp/tests/repo-effect-bundle.json");
    write_authorized_effect_verification_bundle(
        &effect,
        execution_grant_path.display().to_string(),
        "test::bundle_consumer",
        "other-scope",
        &bundle_path,
    )
    .expect("write verification bundle");
    let err = verify_authorized_effect_verification_bundle(&bundle_path)
        .expect_err("scope-mismatched verification bundle must fail");
    assert_eq!(err.code, ErrorCode::CapabilityDenied);
}

#[test]
fn tampered_verification_bundle_fails_closed() {
    let cfg = temp_runtime_config();
    let policy = PolicyEngine::new(cfg.clone());
    let request = minimal_request();
    let prior_route_bundle = std::env::var("OCTON_ALLOW_STALE_RUNTIME_ROUTE_BUNDLE").ok();
    std::env::set_var("OCTON_ALLOW_STALE_RUNTIME_ROUTE_BUNDLE", "1");
    let grant = authorize_execution(&cfg, &policy, &request, None).expect("request should authorize");
    match prior_route_bundle {
        Some(value) => std::env::set_var("OCTON_ALLOW_STALE_RUNTIME_ROUTE_BUNDLE", value),
        None => std::env::remove_var("OCTON_ALLOW_STALE_RUNTIME_ROUTE_BUNDLE"),
    }
    let runtime_path = cfg.execution_tmp_root.join(&request.request_id);
    fs::create_dir_all(&runtime_path).expect("create runtime path");
    let execution_grant_path = runtime_path.join("grant-bundle.json");
    fs::write(
        &execution_grant_path,
        serde_json::to_vec_pretty(&grant).expect("serialize execution grant"),
    )
    .expect("write execution grant bundle");
    let effect = issue_service_invocation_effect(&runtime_path, &grant, "service::invoke")
        .expect("service effect should mint");
    let bundle_path = cfg
        .repo_root
        .join(".octon/generated/.tmp/tests/service-effect-bundle.json");
    write_authorized_effect_verification_bundle(
        &effect,
        execution_grant_path.display().to_string(),
        "test::bundle_consumer",
        "service::invoke",
        &bundle_path,
    )
    .expect("write verification bundle");
    let mut bundle: serde_json::Value =
        serde_json::from_str(&fs::read_to_string(&bundle_path).expect("read bundle"))
            .expect("parse bundle");
    bundle["token_payload"]["effect_kind"] =
        serde_json::Value::String("repo-mutation".to_string());
    bundle["token_payload"]["token_type"] =
        serde_json::Value::String("AuthorizedEffect<RepoMutation>".to_string());
    fs::write(
        &bundle_path,
        serde_json::to_vec_pretty(&bundle).expect("serialize tampered bundle"),
    )
    .expect("write tampered bundle");
    let err = verify_authorized_effect_verification_bundle(&bundle_path)
        .expect_err("tampered verification bundle must fail");
    assert_eq!(err.code, ErrorCode::CapabilityDenied);
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
    let mut request = minimal_request();
    request.metadata.insert(
        "support_tier".to_string(),
        "unsupported-tier".to_string(),
    );
    let err = authorize_execution(&cfg, &policy, &request, None)
        .expect_err("unsupported support tier should deny");
    assert!(
        err.details["reason_codes"]
            .as_array()
            .expect("reason codes should be an array")
            .iter()
            .filter_map(|value| value.as_str())
            .any(|value| value == "SUPPORT_TIER_UNSUPPORTED")
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
    let artifact_effects = issue_execution_artifact_effects(
        &artifacts_root,
        &grant,
        artifacts_root.display().to_string(),
    )
    .expect("artifact effects should issue");
    let paths = write_execution_start(&artifacts_root, &request, &grant, &artifact_effects)
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
        &artifact_effects,
        &outcome.started_at,
        &outcome,
        &SideEffectSummary::default(),
    )
    .expect("finalize execution should emit disclosure");

    let request_payload: serde_json::Value = serde_json::from_str(
        &fs::read_to_string(&paths.request).expect("read request payload"),
    )
    .expect("parse request payload");
    let receipt_payload: serde_json::Value = serde_json::from_str(
        &fs::read_to_string(&paths.receipt).expect("read receipt payload"),
    )
    .expect("parse receipt payload");
    assert_eq!(
        request_payload["schema_version"].as_str(),
        Some("execution-request-v3")
    );
    assert_eq!(
        receipt_payload["schema_version"].as_str(),
        Some("execution-receipt-v3")
    );
    assert!(
        cfg.run_root(&request.request_id)
            .join("receipts/authorization-phases/request-materialization.json")
            .is_file()
    );
    assert!(
        cfg.run_root(&request.request_id)
            .join("receipts/authorization-phases/receipt-materialization.json")
            .is_file()
    );

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

    let close_report = validate_run_lifecycle_operation(
        &cfg.repo_root,
        &request.request_id,
        RunLifecycleOperation::Close,
    )
    .expect("closed failed run should satisfy closeout completeness");
    assert_eq!(close_report.reconstructed_state, "closed");

    let review_dispositions_path = cfg
        .execution_control_root
        .join("runs")
        .join(&request.request_id)
        .join("authority/review-dispositions.yml");
    let evidence_completeness_path = cfg
        .run_root(&request.request_id)
        .join("closeout/evidence-store-completeness.yml");
    assert!(review_dispositions_path.is_file());
    assert!(evidence_completeness_path.is_file());

    fs::remove_file(&review_dispositions_path).expect("remove review disposition fixture");
    let err = validate_run_lifecycle_operation(
        &cfg.repo_root,
        &request.request_id,
        RunLifecycleOperation::Close,
    )
    .expect_err("closed run without review/risk disposition should fail closed");
    assert!(
        err.details["reason_codes"]
            .as_array()
            .expect("reason codes")
            .iter()
            .any(|value| value.as_str() == Some("RUN_LIFECYCLE_REVIEW_DISPOSITION_MISSING"))
    );
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
