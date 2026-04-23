use anyhow::{anyhow, Result};
use octon_authority_engine::{ExecutionDecision, ExecutionRequest, GrantBundle};
use octon_core::config::RuntimeConfig;
use serde::Serialize;
use std::collections::BTreeMap;
use std::fs;
use std::path::Path;

const DEFAULT_MODEL_TIER: &str = "repo-local-governed";
const DEFAULT_WORKLOAD_TIER: &str = "repo-consequential";
const DEFAULT_LANGUAGE_RESOURCE_TIER: &str = "reference-owned";
const DEFAULT_LOCALE_TIER: &str = "english-primary";
const DEFAULT_HOST_ADAPTER: &str = "repo-shell";
const DEFAULT_MODEL_ADAPTER: &str = "repo-local-governed";

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum ExecutionMateriality {
    ObservationOnly,
    BoundedConsequential,
    BoundarySensitive,
}

#[derive(Debug, Clone, Serialize)]
struct BoundExecutionRoleRef<'a> {
    kind: &'a str,
    id: &'a str,
}

#[derive(Debug, Clone, Serialize)]
struct BoundIntentRef<'a> {
    id: &'a str,
    version: &'a str,
}

#[derive(Debug, Clone, Serialize)]
struct SupportTarget {
    model_tier: String,
    workload_tier: String,
    language_resource_tier: String,
    locale_tier: String,
    host_adapter: String,
    model_adapter: String,
}

#[derive(Debug, Clone, Serialize)]
struct ScopeSummary<'a> {
    action_type: &'a str,
    target_id: &'a str,
    workflow_mode: &'a str,
}

#[derive(Debug, Clone, Serialize)]
struct RunContractV2<'a> {
    schema_version: &'static str,
    run_id: &'a str,
    status: &'static str,
    workflow_mode: &'a str,
    materiality: &'a str,
    action_type: &'a str,
    target_id: &'a str,
    objective_summary: String,
    support_tier: String,
    support_target: SupportTarget,
    support_target_ref: &'static str,
    requested_capability_packs: Vec<String>,
    requested_capabilities: Vec<String>,
    authority_bundle_ref: String,
    decision_artifact_ref: Option<String>,
    approval_request_ref: Option<String>,
    approval_grant_refs: Vec<String>,
    exception_lease_refs: Vec<String>,
    revocation_refs: Vec<String>,
    budget_ledger_ref: String,
    run_manifest_ref: String,
    runtime_state_ref: String,
    rollback_posture_ref: String,
    control_checkpoint_root: String,
    stage_attempt_root: String,
    evidence_root: String,
    receipt_root: String,
    replay_manifest_ref: String,
    replay_pointers_ref: String,
    trace_pointers_ref: String,
    run_card_ref: String,
    objective_refs: BTreeMap<&'static str, &'static str>,
    intent_ref: BoundIntentRef<'a>,
    execution_role_ref: BoundExecutionRoleRef<'a>,
    created_at: &'a str,
    issued_at: &'a str,
    updated_at: &'a str,
}

#[derive(Debug, Clone, Serialize)]
struct RunManifestV2<'a> {
    schema_version: &'static str,
    run_id: &'a str,
    run_contract_ref: String,
    workflow_mode: &'a str,
    action_type: &'a str,
    target_id: &'a str,
    support_tier: String,
    support_target: SupportTarget,
    support_target_ref: &'static str,
    requested_capability_packs: Vec<String>,
    requested_capabilities: Vec<String>,
    intent_ref: BoundIntentRef<'a>,
    execution_role_ref: BoundExecutionRoleRef<'a>,
    authority_bundle_ref: String,
    decision_artifact_ref: Option<String>,
    approval_request_ref: Option<String>,
    approval_grant_refs: Vec<String>,
    exception_lease_refs: Vec<String>,
    revocation_refs: Vec<String>,
    budget_ledger_ref: String,
    runtime_state_ref: String,
    rollback_posture_ref: String,
    stage_attempt_root: String,
    control_checkpoint_root: String,
    evidence_root: String,
    receipt_root: String,
    assurance_root: String,
    measurement_root: String,
    intervention_root: String,
    disclosure_root: String,
    replay_manifest_ref: String,
    replay_pointers_ref: String,
    trace_pointers_ref: String,
    evidence_classification_ref: String,
    external_replay_index_ref: String,
    run_continuity_ref: String,
    run_card_ref: String,
    host_adapter_ref: String,
    model_adapter_ref: String,
    created_at: &'a str,
    updated_at: &'a str,
}

#[derive(Debug, Clone, Serialize)]
struct BudgetLedgerV1<'a> {
    schema_version: &'static str,
    run_id: &'a str,
    budget_dimensions: Vec<&'static str>,
    current_usage: BTreeMap<&'static str, serde_json::Value>,
    thresholds: BTreeMap<&'static str, serde_json::Value>,
    escalation_point: &'static str,
    block_point: &'static str,
    overrun_behavior: &'static str,
    updated_at: &'a str,
}

#[derive(Debug, Clone, Serialize)]
struct GrantBundleV2<'a> {
    schema_version: &'static str,
    run_id: &'a str,
    request_id: &'a str,
    route_outcome: String,
    granted_capabilities: Vec<String>,
    requested_capability_packs: Vec<String>,
    support_target: SupportTarget,
    approval_request_ref: Option<String>,
    approval_grant_refs: Vec<String>,
    exception_lease_refs: Vec<String>,
    revocation_refs: Vec<String>,
    budget_ledger_ref: String,
    decision_artifact_ref: Option<String>,
    quorum_policy_ref: Option<String>,
    effective_scope: ScopeSummary<'a>,
    generated_at: &'a str,
}

#[derive(Debug, Clone, Serialize)]
struct AuthorityRefs {
    approval_request_ref: Option<String>,
    approval_grant_refs: Vec<String>,
    exception_lease_refs: Vec<String>,
    revocation_refs: Vec<String>,
    grant_bundle_ref: String,
}

#[derive(Debug, Clone, Serialize)]
struct SupportTargetTuple {
    model_tier: String,
    workload_tier: String,
    language_resource_tier: String,
    locale_tier: String,
    host_adapter: String,
    model_adapter: String,
}

#[derive(Debug, Clone, Serialize)]
struct DecisionArtifactV2<'a> {
    schema_version: &'static str,
    decision_id: String,
    request_id: &'a str,
    run_id: &'a str,
    route_outcome: String,
    reason_codes: Vec<String>,
    policy_refs: Vec<&'static str>,
    authority_refs: AuthorityRefs,
    support_target_tuple: SupportTargetTuple,
    issuing_engine: &'static str,
    issuing_version: &'a str,
    generated_at: &'a str,
}

pub fn classify_direct_surface(surface: &str) -> ExecutionMateriality {
    match surface {
        "services" => ExecutionMateriality::ObservationOnly,
        "tool" => ExecutionMateriality::BoundedConsequential,
        "service" => ExecutionMateriality::BoundedConsequential,
        "studio" => ExecutionMateriality::BoundarySensitive,
        _ => ExecutionMateriality::BoundedConsequential,
    }
}

pub fn ensure_canonical_run_binding(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
    grant: &GrantBundle,
    surface: &str,
) -> Result<()> {
    match classify_direct_surface(surface) {
        ExecutionMateriality::ObservationOnly => Ok(()),
        ExecutionMateriality::BoundedConsequential | ExecutionMateriality::BoundarySensitive => {
            materialize_run_binding(cfg, request, grant, surface)
        }
    }
}

pub fn normalize_support_value(value: &str) -> String {
    match value {
        "repo-local-consequential" => "repo-consequential".to_string(),
        "MT-A" => "frontier-governed".to_string(),
        "MT-B" => "repo-local-governed".to_string(),
        "WT-1" => "observe-and-read".to_string(),
        "WT-2" => "repo-consequential".to_string(),
        "WT-3" => "boundary-sensitive".to_string(),
        "LT-REF" => "reference-owned".to_string(),
        "LT-EXT" => "extended-governed".to_string(),
        "LOC-EN" => "english-primary".to_string(),
        "LOC-ES" => "spanish-secondary".to_string(),
        other => other.to_string(),
    }
}

fn materialize_run_binding(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
    grant: &GrantBundle,
    surface: &str,
) -> Result<()> {
    let run_id = &request.request_id;
    let control_root = cfg.run_control_root(run_id);
    let authority_root = control_root.join("authority");
    let checkpoints_root = control_root.join("checkpoints");
    let stage_root = control_root.join("stage-attempts");
    let continuity_root = cfg.run_continuity_path(run_id);
    let evidence_root = cfg.run_root(run_id);
    let support_target = build_support_target(request);
    let support_tier = support_target.workload_tier.clone();
    let now = request
        .metadata
        .get("generated_at")
        .cloned()
        .unwrap_or_else(|| "2026-04-04T00:00:00Z".to_string());

    fs::create_dir_all(&authority_root)?;
    fs::create_dir_all(authority_root.join("exception-leases"))?;
    fs::create_dir_all(authority_root.join("revocations"))?;
    fs::create_dir_all(&checkpoints_root)?;
    fs::create_dir_all(&stage_root)?;
    fs::create_dir_all(&continuity_root)?;

    let authority_bundle_rel = rel(cfg, &authority_root.join("grant-bundle.yml"))?;
    let budget_ledger_rel = rel(cfg, &authority_root.join("budget-ledger.yml"))?;

    let run_contract = RunContractV2 {
        schema_version: "run-contract-v2",
        run_id,
        status: "bound",
        workflow_mode: &request.workflow_mode,
        materiality: materiality_label(surface),
        action_type: &request.action_type,
        target_id: &request.target_id,
        objective_summary: format!(
            "Compatibility-bound consequential execution for {surface}::{} resolves through canonical run artifacts.",
            request.target_id
        ),
        support_tier: support_tier.clone(),
        support_target: support_target.clone(),
        support_target_ref: ".octon/instance/governance/support-targets.yml",
        requested_capability_packs: infer_capability_packs(request),
        requested_capabilities: grant.granted_capabilities.clone(),
        authority_bundle_ref: authority_bundle_rel.clone(),
        decision_artifact_ref: grant.decision_artifact_ref.clone(),
        approval_request_ref: grant.approval_request_ref.clone(),
        approval_grant_refs: grant.approval_grant_refs.clone(),
        exception_lease_refs: grant.exception_lease_refs.clone(),
        revocation_refs: grant.revocation_refs.clone(),
        budget_ledger_ref: budget_ledger_rel.clone(),
        run_manifest_ref: rel(cfg, &control_root.join("run-manifest.yml"))?,
        runtime_state_ref: rel(cfg, &control_root.join("runtime-state.yml"))?,
        rollback_posture_ref: rel(cfg, &control_root.join("rollback-posture.yml"))?,
        control_checkpoint_root: rel(cfg, &checkpoints_root)?,
        stage_attempt_root: rel(cfg, &stage_root)?,
        evidence_root: rel(cfg, &evidence_root)?,
        receipt_root: rel(cfg, &evidence_root.join("receipts"))?,
        replay_manifest_ref: rel(cfg, &evidence_root.join("replay/manifest.yml"))?,
        replay_pointers_ref: rel(cfg, &evidence_root.join("replay-pointers.yml"))?,
        trace_pointers_ref: rel(cfg, &evidence_root.join("trace-pointers.yml"))?,
        run_card_ref: rel(
            cfg,
            &cfg.repo_root
                .join(".octon/state/evidence/disclosure/runs")
                .join(run_id)
                .join("run-card.yml"),
        )?,
        objective_refs: BTreeMap::from([
            (
                "workspace_objective_ref",
                ".octon/instance/charter/workspace.md",
            ),
            (
                "workspace_machine_charter_ref",
                ".octon/instance/charter/workspace.yml",
            ),
        ]),
        intent_ref: bound_intent_ref(request)?,
        execution_role_ref: bound_execution_role_ref(request),
        created_at: &now,
        issued_at: &now,
        updated_at: &now,
    };
    write_yaml(&control_root.join("run-contract.yml"), &run_contract)?;

    let run_manifest = RunManifestV2 {
        schema_version: "run-manifest-v2",
        run_id,
        run_contract_ref: rel(cfg, &control_root.join("run-contract.yml"))?,
        workflow_mode: &request.workflow_mode,
        action_type: &request.action_type,
        target_id: &request.target_id,
        support_tier,
        support_target: support_target.clone(),
        support_target_ref: ".octon/instance/governance/support-targets.yml",
        requested_capability_packs: infer_capability_packs(request),
        requested_capabilities: grant.granted_capabilities.clone(),
        intent_ref: bound_intent_ref(request)?,
        execution_role_ref: bound_execution_role_ref(request),
        authority_bundle_ref: authority_bundle_rel.clone(),
        decision_artifact_ref: grant.decision_artifact_ref.clone(),
        approval_request_ref: grant.approval_request_ref.clone(),
        approval_grant_refs: grant.approval_grant_refs.clone(),
        exception_lease_refs: grant.exception_lease_refs.clone(),
        revocation_refs: grant.revocation_refs.clone(),
        budget_ledger_ref: budget_ledger_rel.clone(),
        runtime_state_ref: rel(cfg, &control_root.join("runtime-state.yml"))?,
        rollback_posture_ref: rel(cfg, &control_root.join("rollback-posture.yml"))?,
        stage_attempt_root: rel(cfg, &stage_root)?,
        control_checkpoint_root: rel(cfg, &checkpoints_root)?,
        evidence_root: rel(cfg, &evidence_root)?,
        receipt_root: rel(cfg, &evidence_root.join("receipts"))?,
        assurance_root: rel(cfg, &evidence_root.join("assurance"))?,
        measurement_root: rel(cfg, &evidence_root.join("measurements"))?,
        intervention_root: rel(cfg, &evidence_root.join("interventions"))?,
        disclosure_root: rel(
            cfg,
            &cfg.repo_root
                .join(".octon/state/evidence/disclosure/runs")
                .join(run_id),
        )?,
        replay_manifest_ref: rel(cfg, &evidence_root.join("replay/manifest.yml"))?,
        replay_pointers_ref: rel(cfg, &evidence_root.join("replay-pointers.yml"))?,
        trace_pointers_ref: rel(cfg, &evidence_root.join("trace-pointers.yml"))?,
        evidence_classification_ref: rel(cfg, &evidence_root.join("evidence-classification.yml"))?,
        external_replay_index_ref: rel(
            cfg,
            &cfg.repo_root
                .join(".octon/state/evidence/external-index/runs")
                .join(format!("{run_id}.yml")),
        )?,
        run_continuity_ref: rel(cfg, &continuity_root.join("handoff.yml"))?,
        run_card_ref: rel(
            cfg,
            &cfg.repo_root
                .join(".octon/state/evidence/disclosure/runs")
                .join(run_id)
                .join("run-card.yml"),
        )?,
        host_adapter_ref: format!(
            ".octon/framework/engine/runtime/adapters/host/{}.yml",
            support_target.host_adapter
        ),
        model_adapter_ref: format!(
            ".octon/framework/engine/runtime/adapters/model/{}.yml",
            support_target.model_adapter
        ),
        created_at: &now,
        updated_at: &now,
    };
    write_yaml(&control_root.join("run-manifest.yml"), &run_manifest)?;

    write_runtime_state(
        cfg,
        &control_root.join("runtime-state.yml"),
        run_id,
        &request.workflow_mode,
        &now,
    )?;

    let budget_ledger = BudgetLedgerV1 {
        schema_version: "budget-ledger-v1",
        run_id,
        budget_dimensions: vec!["token", "time", "tool_count", "cost", "external_calls"],
        current_usage: BTreeMap::from([
            ("token", serde_json::json!(0)),
            ("time", serde_json::json!(0)),
            ("tool_count", serde_json::json!(0)),
            ("cost", serde_json::json!(0)),
            ("external_calls", serde_json::json!(0)),
        ]),
        thresholds: BTreeMap::from([
            ("token", serde_json::json!("soft")),
            ("time", serde_json::json!("soft")),
            ("tool_count", serde_json::json!("soft")),
            ("cost", serde_json::json!("soft")),
            ("external_calls", serde_json::json!("soft")),
        ]),
        escalation_point: "threshold-crossing",
        block_point: "hard-policy-deny",
        overrun_behavior: "escalate",
        updated_at: &now,
    };
    write_yaml(&authority_root.join("budget-ledger.yml"), &budget_ledger)?;

    let grant_bundle = GrantBundleV2 {
        schema_version: "authority-grant-bundle-v2",
        run_id,
        request_id: &request.request_id,
        route_outcome: decision_route(&grant.decision),
        granted_capabilities: grant.granted_capabilities.clone(),
        requested_capability_packs: infer_capability_packs(request),
        support_target: support_target.clone(),
        approval_request_ref: grant.approval_request_ref.clone(),
        approval_grant_refs: grant.approval_grant_refs.clone(),
        exception_lease_refs: grant.exception_lease_refs.clone(),
        revocation_refs: grant.revocation_refs.clone(),
        budget_ledger_ref: budget_ledger_rel.clone(),
        decision_artifact_ref: grant.decision_artifact_ref.clone(),
        quorum_policy_ref: grant.quorum_policy_ref.clone(),
        effective_scope: ScopeSummary {
            action_type: &request.action_type,
            target_id: &request.target_id,
            workflow_mode: &request.workflow_mode,
        },
        generated_at: &now,
    };
    write_yaml(&authority_root.join("grant-bundle.yml"), &grant_bundle)?;

    let decision = DecisionArtifactV2 {
        schema_version: "authority-decision-artifact-v2",
        decision_id: format!("decision-{run_id}"),
        request_id: &request.request_id,
        run_id,
        route_outcome: decision_route(&grant.decision),
        reason_codes: grant.reason_codes.clone(),
        policy_refs: vec![
            ".octon/framework/constitution/obligations/fail-closed.yml",
            ".octon/instance/governance/support-targets.yml",
            ".octon/instance/governance/exclusions/action-classes.yml",
        ],
        authority_refs: AuthorityRefs {
            approval_request_ref: grant.approval_request_ref.clone(),
            approval_grant_refs: grant.approval_grant_refs.clone(),
            exception_lease_refs: grant.exception_lease_refs.clone(),
            revocation_refs: grant.revocation_refs.clone(),
            grant_bundle_ref: authority_bundle_rel,
        },
        support_target_tuple: SupportTargetTuple {
            model_tier: support_target.model_tier,
            workload_tier: support_target.workload_tier,
            language_resource_tier: support_target.language_resource_tier,
            locale_tier: support_target.locale_tier,
            host_adapter: support_target.host_adapter,
            model_adapter: support_target.model_adapter,
        },
        issuing_engine: "octon-kernel-run-binding",
        issuing_version: env!("CARGO_PKG_VERSION"),
        generated_at: &now,
    };
    write_yaml(&authority_root.join("decision.yml"), &decision)?;

    if !continuity_root.join("handoff.yml").exists() {
        let handoff = serde_yaml::to_string(&serde_yaml::Mapping::from_iter([
            (
                serde_yaml::Value::String("schema_version".into()),
                serde_yaml::Value::String("continuity-artifact-v1".into()),
            ),
            (
                serde_yaml::Value::String("run_id".into()),
                serde_yaml::Value::String(run_id.to_string()),
            ),
            (
                serde_yaml::Value::String("next_step_summary".into()),
                serde_yaml::Value::String(
                    "Resume from the canonical run root; consequential compatibility entry points now bind here."
                        .into(),
                ),
            ),
            (
                serde_yaml::Value::String("runtime_state_ref".into()),
                serde_yaml::Value::String(rel(cfg, &control_root.join("runtime-state.yml"))?),
            ),
        ]))?;
        fs::write(continuity_root.join("handoff.yml"), handoff)?;
    }

    if !checkpoints_root.join("bound.yml").exists() {
        let checkpoint = serde_yaml::to_string(&serde_yaml::Mapping::from_iter([
            (
                serde_yaml::Value::String("schema_version".into()),
                serde_yaml::Value::String("checkpoint-v1".into()),
            ),
            (
                serde_yaml::Value::String("checkpoint_id".into()),
                serde_yaml::Value::String("bound".into()),
            ),
            (
                serde_yaml::Value::String("run_id".into()),
                serde_yaml::Value::String(run_id.to_string()),
            ),
            (
                serde_yaml::Value::String("recorded_at".into()),
                serde_yaml::Value::String(now.clone()),
            ),
        ]))?;
        fs::write(checkpoints_root.join("bound.yml"), checkpoint)?;
    }

    Ok(())
}

fn build_support_target(request: &ExecutionRequest) -> SupportTarget {
    SupportTarget {
        model_tier: normalize_support_value(
            request
                .metadata
                .get("support_model_tier")
                .map(String::as_str)
                .unwrap_or(DEFAULT_MODEL_TIER),
        ),
        workload_tier: normalize_support_value(
            request
                .metadata
                .get("support_tier")
                .map(String::as_str)
                .unwrap_or(DEFAULT_WORKLOAD_TIER),
        ),
        language_resource_tier: normalize_support_value(
            request
                .metadata
                .get("support_language_resource_tier")
                .map(String::as_str)
                .unwrap_or(DEFAULT_LANGUAGE_RESOURCE_TIER),
        ),
        locale_tier: normalize_support_value(
            request
                .metadata
                .get("support_locale_tier")
                .map(String::as_str)
                .unwrap_or(DEFAULT_LOCALE_TIER),
        ),
        host_adapter: normalize_support_value(
            request
                .metadata
                .get("support_host_adapter")
                .map(String::as_str)
                .unwrap_or(DEFAULT_HOST_ADAPTER),
        ),
        model_adapter: normalize_support_value(
            request
                .metadata
                .get("support_model_adapter")
                .map(String::as_str)
                .unwrap_or(DEFAULT_MODEL_ADAPTER),
        ),
    }
}

fn infer_capability_packs(request: &ExecutionRequest) -> Vec<String> {
    let mut packs = Vec::new();
    if request
        .requested_capabilities
        .iter()
        .any(|cap| cap.contains("repo"))
    {
        packs.push("repo".to_string());
    }
    if request
        .requested_capabilities
        .iter()
        .any(|cap| cap.contains("git"))
    {
        packs.push("git".to_string());
    }
    if request
        .requested_capabilities
        .iter()
        .any(|cap| cap.contains("shell") || cap.contains("executor"))
    {
        packs.push("shell".to_string());
    }
    if request
        .requested_capabilities
        .iter()
        .any(|cap| cap.contains("evidence") || cap.contains("telemetry"))
    {
        packs.push("telemetry".to_string());
    }
    if request
        .requested_capabilities
        .iter()
        .any(|cap| cap.contains("browser") || cap.contains("studio"))
    {
        packs.push("browser".to_string());
    }
    if request
        .requested_capabilities
        .iter()
        .any(|cap| cap.contains("net.") || cap.contains("api"))
    {
        packs.push("api".to_string());
    }
    packs.sort();
    packs.dedup();
    if packs.is_empty() {
        vec!["repo".to_string(), "telemetry".to_string()]
    } else {
        packs
    }
}

fn materiality_label(surface: &str) -> &'static str {
    match classify_direct_surface(surface) {
        ExecutionMateriality::ObservationOnly => "observation_only",
        ExecutionMateriality::BoundedConsequential => "bounded_consequential",
        ExecutionMateriality::BoundarySensitive => "boundary_sensitive",
    }
}

fn bound_intent_ref(request: &ExecutionRequest) -> Result<BoundIntentRef<'_>> {
    let intent = request
        .intent_ref
        .as_ref()
        .ok_or_else(|| anyhow!("run binding requires an intent ref"))?;
    Ok(BoundIntentRef {
        id: &intent.id,
        version: &intent.version,
    })
}

fn bound_execution_role_ref(request: &ExecutionRequest) -> BoundExecutionRoleRef<'_> {
    let actor = request.execution_role_ref.as_ref();
    BoundExecutionRoleRef {
        kind: actor.map(|value| value.kind.as_str()).unwrap_or("system"),
        id: actor
            .map(|value| value.id.as_str())
            .unwrap_or("octon-kernel"),
    }
}

fn decision_route(value: &ExecutionDecision) -> String {
    match value {
        ExecutionDecision::Allow => "allow".to_string(),
        ExecutionDecision::StageOnly => "stage_only".to_string(),
        ExecutionDecision::Escalate => "escalate".to_string(),
        ExecutionDecision::Deny => "deny".to_string(),
    }
}

fn rel(cfg: &RuntimeConfig, path: &Path) -> Result<String> {
    Ok(format!(
        ".{}",
        path.strip_prefix(&cfg.repo_root)?
            .to_string_lossy()
            .replace('\\', "/")
    ))
}

fn write_yaml<T: Serialize>(path: &Path, value: &T) -> Result<()> {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)?;
    }
    fs::write(path, serde_yaml::to_string(value)?)?;
    Ok(())
}

fn write_runtime_state(
    cfg: &RuntimeConfig,
    path: &Path,
    run_id: &str,
    workflow_mode: &str,
    now: &str,
) -> Result<()> {
    let mut root = if path.is_file() {
        serde_yaml::from_str::<serde_yaml::Mapping>(&fs::read_to_string(path)?)?
    } else {
        serde_yaml::Mapping::new()
    };

    normalize_runtime_state_mapping(
        &mut root,
        run_id,
        workflow_mode,
        now,
        rel(cfg, &cfg.run_control_root(run_id).join("run-contract.yml"))?,
        rel(cfg, &cfg.run_control_root(run_id).join("run-manifest.yml"))?,
    );

    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)?;
    }
    fs::write(path, serde_yaml::to_string(&root)?)?;
    Ok(())
}

fn normalize_runtime_state_mapping(
    root: &mut serde_yaml::Mapping,
    run_id: &str,
    workflow_mode: &str,
    now: &str,
    run_contract_ref: String,
    run_manifest_ref: String,
) {
    let canonical_state = yaml_string(root, "state")
        .or_else(|| yaml_string(root, "status"))
        .unwrap_or_else(|| "bound".to_string());

    remove_yaml_key(root, "status");

    insert_yaml_string(&mut *root, "schema_version", "runtime-state-v2");
    insert_yaml_string(root, "run_id", run_id);
    insert_yaml_string(root, "state", &canonical_state);
    insert_yaml_string(root, "workflow_mode", workflow_mode);
    root.entry(serde_yaml::Value::String("decision_state".into()))
        .or_insert(serde_yaml::Value::String("allow".into()));
    root.entry(serde_yaml::Value::String("run_contract_ref".into()))
        .or_insert(serde_yaml::Value::String(run_contract_ref));
    root.entry(serde_yaml::Value::String("run_manifest_ref".into()))
        .or_insert(serde_yaml::Value::String(run_manifest_ref));
    root.entry(serde_yaml::Value::String("current_stage_attempt_id".into()))
        .or_insert(serde_yaml::Value::String("initial".into()));
    root.entry(serde_yaml::Value::String("last_checkpoint_ref".into()))
        .or_insert(serde_yaml::Value::Null);
    root.entry(serde_yaml::Value::String("last_receipt_ref".into()))
        .or_insert(serde_yaml::Value::Null);
    root.entry(serde_yaml::Value::String("mission_id".into()))
        .or_insert(serde_yaml::Value::Null);
    root.entry(serde_yaml::Value::String("parent_run_ref".into()))
        .or_insert(serde_yaml::Value::Null);
    root.entry(serde_yaml::Value::String("created_at".into()))
        .or_insert(serde_yaml::Value::String(now.to_string()));
    insert_yaml_string(root, "updated_at", now);
}

fn insert_yaml_string(map: &mut serde_yaml::Mapping, key: &str, value: &str) {
    map.insert(
        serde_yaml::Value::String(key.to_string()),
        serde_yaml::Value::String(value.to_string()),
    );
}

fn remove_yaml_key(map: &mut serde_yaml::Mapping, key: &str) {
    map.remove(serde_yaml::Value::String(key.to_string()));
}

fn yaml_string(map: &serde_yaml::Mapping, key: &str) -> Option<String> {
    map.get(serde_yaml::Value::String(key.to_string()))
        .and_then(|value| value.as_str().map(ToOwned::to_owned))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn runtime_state_normalization_drops_legacy_status_key() {
        let mut root = serde_yaml::Mapping::new();
        insert_yaml_string(&mut root, "schema_version", "run-runtime-state-v1");
        insert_yaml_string(&mut root, "state", "authorized");
        insert_yaml_string(&mut root, "status", "bound");

        normalize_runtime_state_mapping(
            &mut root,
            "tool-run",
            "role-mediated",
            "2026-04-23T00:00:00Z",
            ".octon/state/control/execution/runs/tool-run/run-contract.yml".to_string(),
            ".octon/state/control/execution/runs/tool-run/run-manifest.yml".to_string(),
        );

        assert_eq!(
            yaml_string(&root, "schema_version").as_deref(),
            Some("runtime-state-v2")
        );
        assert_eq!(yaml_string(&root, "state").as_deref(), Some("authorized"));
        assert_eq!(yaml_string(&root, "status"), None);
    }
}
