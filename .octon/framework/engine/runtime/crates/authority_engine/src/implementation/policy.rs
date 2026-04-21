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

pub fn resolve_executor_profile<'a>(
    cfg: &'a RuntimeConfig,
    name: &str,
) -> CoreResult<&'a ExecutorProfileConfig> {
    cfg.execution_governance
        .executor_profiles
        .get(name)
        .ok_or_else(|| {
            KernelError::new(
                ErrorCode::CapabilityDenied,
                format!("unknown executor profile '{}'", name),
            )
            .with_details(json!({"reason_codes":["EXECUTOR_PROFILE_UNKNOWN"]}))
        })
}

pub fn build_executor_command(spec: ExecutorCommandSpec<'_>) -> CoreResult<(Command, Vec<String>)> {
    let mut command = Command::new(spec.executor_bin);
    let blocked_flags = dangerous_flags_for(&spec.kind)
        .into_iter()
        .filter(|_| !spec.profile.dangerous_flags_allowed)
        .collect::<Vec<_>>();
    match spec.kind {
        ManagedExecutorKind::Codex => {
            command
                .arg("exec")
                .arg("--ephemeral")
                .arg("--skip-git-repo-check")
                .arg("--cd")
                .arg(spec.repo_root);
            if spec.profile.dangerous_flags_allowed {
                command.arg("--full-auto");
            }
            if let Some(output_path) = spec.output_path {
                command.arg("--output-last-message").arg(output_path);
            }
        }
        ManagedExecutorKind::Claude => {
            command.arg("-p").arg("--output-format").arg("text");
            if spec.profile.dangerous_flags_allowed {
                command.arg("--permission-mode").arg("bypassPermissions");
            }
        }
    }
    if let Some(model) = spec.model {
        command.arg("--model").arg(model);
    }
    command.current_dir(spec.repo_root);
    Ok((command, blocked_flags))
}

pub fn now_rfc3339() -> anyhow::Result<String> {
    Ok(time::OffsetDateTime::now_utc().format(&time::format_description::well_known::Rfc3339)?)
}

pub(crate) fn env_bool(name: &str) -> bool {
    std::env::var(name)
        .map(|value| value.eq_ignore_ascii_case("true"))
        .unwrap_or(false)
}

pub(crate) fn write_json(path: &Path, value: &impl Serialize) -> anyhow::Result<()> {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)
            .with_context(|| format!("create parent directory {}", parent.display()))?;
    }
    fs::write(path, serde_json::to_vec_pretty(value)?)
        .with_context(|| format!("write {}", path.display()))
}

pub(crate) fn write_yaml(path: &Path, value: &impl Serialize) -> anyhow::Result<()> {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)
            .with_context(|| format!("create parent directory {}", parent.display()))?;
    }
    fs::write(path, serde_yaml::to_string(value)?)
        .with_context(|| format!("write {}", path.display()))
}

pub(crate) fn evidence_links(
    paths: &ExecutionArtifactPaths,
    grant: &GrantBundle,
) -> BTreeMap<String, String> {
    let mut links = BTreeMap::new();
    links.insert(
        "request".to_string(),
        path_tail(&paths.root, &paths.request),
    );
    links.insert(
        "decision".to_string(),
        path_tail(&paths.root, &paths.decision),
    );
    links.insert("grant".to_string(), path_tail(&paths.root, &paths.grant));
    links.insert(
        "side_effects".to_string(),
        path_tail(&paths.root, &paths.side_effects),
    );
    links.insert(
        "outcome".to_string(),
        path_tail(&paths.root, &paths.outcome),
    );
    links.insert(
        "receipt".to_string(),
        path_tail(&paths.root, &paths.receipt),
    );
    if let Some(path) = &grant.policy_receipt_path {
        links.insert("policy_receipt".to_string(), path.clone());
    }
    if let Some(path) = &grant.policy_digest_path {
        links.insert("policy_digest".to_string(), path.clone());
    }
    if let Some(path) = &grant.instruction_manifest_path {
        links.insert("instruction_manifest".to_string(), path.clone());
    }
    links.insert("run_root".to_string(), grant.run_root.clone());
    if let Some(path) = &grant.run_control_root {
        links.insert("run_control_root".to_string(), path.clone());
    }
    if let Some(path) = &grant.run_receipts_root {
        links.insert("run_receipts_root".to_string(), path.clone());
        links.insert(
            "authorization_phase_preflight".to_string(),
            format!("{path}/authorization-phases/preflight.json"),
        );
        links.insert(
            "authorization_phase_routing".to_string(),
            format!("{path}/authorization-phases/routing.json"),
        );
        links.insert(
            "authorization_phase_grant".to_string(),
            format!("{path}/authorization-phases/grant.json"),
        );
        links.insert(
            "authorization_phase_request_materialization".to_string(),
            format!("{path}/authorization-phases/request-materialization.json"),
        );
        links.insert(
            "authorization_phase_receipt_materialization".to_string(),
            format!("{path}/authorization-phases/receipt-materialization.json"),
        );
    }
    if let Some(path) = &grant.replay_pointers_path {
        links.insert("replay_pointers".to_string(), path.clone());
    }
    if let Some(path) = &grant.trace_pointers_path {
        links.insert("trace_pointers".to_string(), path.clone());
    }
    if let Some(path) = &grant.retained_evidence_path {
        links.insert("retained_evidence".to_string(), path.clone());
    }
    if let Some(path) = &grant.stage_attempt_ref {
        links.insert("stage_attempt".to_string(), path.clone());
    }
    if let Some(budget) = &grant.budget {
        if let Some(path) = &budget.evidence_path {
            links.insert("cost".to_string(), path.clone());
        }
    }
    if grant
        .granted_capabilities
        .iter()
        .any(|value| value == "net.http")
    {
        links.insert(
            "network_egress".to_string(),
            format!("{}/network-egress.ndjson", grant.run_root),
        );
    }
    if let Some(path) = &grant.approval_request_ref {
        links.insert("approval_request".to_string(), path.clone());
    }
    if !grant.approval_grant_refs.is_empty() {
        links.insert(
            "approval_grants".to_string(),
            grant.approval_grant_refs.join(","),
        );
    }
    if !grant.exception_lease_refs.is_empty() {
        links.insert(
            "exception_leases".to_string(),
            grant.exception_lease_refs.join(","),
        );
    }
    if !grant.revocation_refs.is_empty() {
        links.insert("revocations".to_string(), grant.revocation_refs.join(","));
    }
    if let Some(path) = &grant.decision_artifact_ref {
        links.insert("authority_decision".to_string(), path.clone());
    }
    if let Some(path) = &grant.authority_grant_bundle_ref {
        links.insert("authority_grant_bundle".to_string(), path.clone());
    }
    links
}

pub(crate) fn path_tail(root: &Path, path: &Path) -> String {
    path.strip_prefix(root)
        .unwrap_or(path)
        .display()
        .to_string()
}

pub(crate) fn current_branch(repo_root: &Path) -> Option<String> {
    let head_path = repo_root.join(".git/HEAD");
    let head = fs::read_to_string(head_path).ok()?;
    let head = head.trim();
    if let Some(rest) = head.strip_prefix("ref: ") {
        return rest.rsplit('/').next().map(ToOwned::to_owned);
    }
    None
}

pub(crate) fn dedupe_strings(values: &[String]) -> Vec<String> {
    let mut set = BTreeSet::new();
    values
        .iter()
        .filter(|value| set.insert((*value).clone()))
        .cloned()
        .collect()
}

pub(crate) fn is_critical_action(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
    executor_profile: Option<&ExecutorProfileConfig>,
) -> bool {
    cfg.execution_governance
        .critical_action_types
        .contains(&request.action_type)
        || request.side_effect_flags.publication
        || request.side_effect_flags.branch_mutation
        || executor_profile
            .map(|profile| profile.require_hard_enforce)
            .unwrap_or(false)
}

pub(crate) fn dangerous_flags_for(kind: &ManagedExecutorKind) -> Vec<String> {
    match kind {
        ManagedExecutorKind::Codex => vec!["--full-auto".to_string()],
        ManagedExecutorKind::Claude => vec!["--permission-mode bypassPermissions".to_string()],
    }
}

pub(crate) fn capability_classification_for_mode(workflow_mode: &str) -> &str {
    match workflow_mode {
        "human-only" => "human-only",
        "role-mediated" => "role-mediated",
        _ => "execution-role-ready",
    }
}

pub(crate) struct PolicyArtifacts {
    pub(crate) allow: bool,
    pub(crate) decision: ExecutionDecision,
    pub(crate) reason_codes: Vec<String>,
    pub(crate) remediation: Option<String>,
    pub(crate) receipt_path: Option<String>,
    pub(crate) digest_path: Option<String>,
    pub(crate) instruction_manifest_path: Option<String>,
}

pub(crate) fn compose_policy_receipt(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
    intent_ref: &IntentRef,
    execution_role_ref: &ExecutionRoleRef,
    effective_policy_mode: &str,
    budget_preview: Option<&BudgetMetadata>,
    autonomy_state: Option<&ResolvedAutonomyState>,
    ownership: &OwnershipPosture,
    support_tier: &SupportTierPosture,
    approval_request_ref: Option<&str>,
    approval_grant_refs: &[String],
    exception_refs: &[String],
    revocation_refs: &[String],
    network_egress_posture: Option<&NetworkEgressPosture>,
) -> CoreResult<PolicyArtifacts> {
    let _test_guard = if cfg!(test) {
        Some(
            ACP_TEST_LOCK
                .get_or_init(|| Mutex::new(()))
                .lock()
                .map_err(|_| {
                    KernelError::new(ErrorCode::Internal, "failed to acquire ACP test lock")
                })?,
        )
    } else {
        None
    };
    let mut policy_runner = std::env::var("OCTON_POLICY_RUNNER_OVERRIDE")
        .map(PathBuf::from)
        .unwrap_or_else(|_| cfg.repo_root.join(".octon/framework/engine/runtime/policy"));
    let mut policy_file = resolve_acp_policy_path(cfg);
    let mut receipt_writer = cfg
        .repo_root
        .join(".octon/framework/capabilities/_ops/scripts/policy-receipt-write.sh");
    if cfg!(test) {
        let source_root = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
            .join("../../../../../..")
            .canonicalize()
            .unwrap_or_else(|_| PathBuf::from(env!("CARGO_MANIFEST_DIR")));
        if !policy_runner.is_file() {
            policy_runner = source_root.join(".octon/framework/engine/runtime/policy");
        }
        if !policy_file.is_file() {
            policy_file = source_root
                .join(".octon/framework/capabilities/governance/policy/deny-by-default.v2.yml");
        }
        if !receipt_writer.is_file() {
            receipt_writer = source_root
                .join(".octon/framework/capabilities/_ops/scripts/policy-receipt-write.sh");
        }
    }
    if !policy_runner.is_file() {
        return Err(KernelError::new(
            ErrorCode::Internal,
            format!(
                "execution authorization requires ACP runner: {}",
                policy_runner.display()
            ),
        ));
    }
    if !receipt_writer.is_file() {
        return Err(KernelError::new(
            ErrorCode::Internal,
            format!(
                "execution authorization requires ACP receipt writer: {}",
                receipt_writer.display()
            ),
        ));
    }
    if !policy_file.is_file() {
        return Err(KernelError::new(
            ErrorCode::Internal,
            format!(
                "execution authorization requires ACP policy file: {}",
                policy_file.display()
            ),
        ));
    }

    let request_path = unique_temp_file(&format!("policy-request-{}", request.request_id), "json");
    let decision_path =
        unique_temp_file(&format!("policy-decision-{}", request.request_id), "json");
    let run_root = cfg
        .repo_root
        .join(".octon/state/evidence/runs")
        .join(&request.request_id);
    let execution_request_path = run_root.join("execution-request.json");
    let policy_decision_path = run_root.join("policy-decision.json");
    let receipt_path = run_root.join("receipt.latest.json");
    let digest_path = run_root.join("digest.latest.md");
    let instruction_manifest_path = run_root.join("instruction-layer-manifest.json");
    let canonical_receipts_root = run_root.join("receipts");
    let canonical_policy_receipt_path = canonical_receipts_root.join("policy-receipt.latest.json");
    let canonical_policy_digest_path = canonical_receipts_root.join("policy-digest.latest.md");

    let request_json = build_policy_request_json(
        cfg,
        request,
        intent_ref,
        execution_role_ref,
        effective_policy_mode,
        budget_preview,
        autonomy_state,
        ownership,
        support_tier,
        approval_request_ref,
        approval_grant_refs,
        exception_refs,
        revocation_refs,
        network_egress_posture,
    )?;

    fs::create_dir_all(&run_root).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to create ACP run root: {e}"),
        )
    })?;
    fs::write(
        &request_path,
        serde_json::to_vec_pretty(&request_json).map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!("failed to serialize policy request temp file: {e}"),
            )
        })?,
    )
    .map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to write policy request temp file: {e}"),
        )
    })?;
    fs::write(
        &execution_request_path,
        serde_json::to_vec_pretty(&request_json).map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!("failed to serialize execution request artifact: {e}"),
            )
        })?,
    )
    .map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to write execution request artifact: {e}"),
        )
    })?;
    let acp_output = Command::new("bash")
        .arg(&policy_runner)
        .arg("acp-enforce")
        .arg("--policy")
        .arg(&policy_file)
        .arg("--request")
        .arg(&execution_request_path)
        .current_dir(&cfg.repo_root)
        .output()
        .map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!("failed to spawn ACP execution flow: {e}"),
            )
        })?;
    let stdout = String::from_utf8_lossy(&acp_output.stdout).to_string();
    let decision_json: serde_json::Value = serde_json::from_str(stdout.trim()).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to parse ACP decision output: {e}"),
        )
    })?;
    let decision = match decision_json
        .get("decision")
        .and_then(|value| value.as_str())
        .unwrap_or("DENY")
    {
        "ALLOW" => ExecutionDecision::Allow,
        "STAGE_ONLY" => ExecutionDecision::StageOnly,
        "ESCALATE" => ExecutionDecision::Escalate,
        _ => ExecutionDecision::Deny,
    };
    if !acp_output.status.success()
        && !matches!(
            decision,
            ExecutionDecision::Deny | ExecutionDecision::StageOnly | ExecutionDecision::Escalate
        )
    {
        return Err(KernelError::new(
            ErrorCode::Internal,
            format!(
                "ACP execution flow failed: {}",
                String::from_utf8_lossy(&acp_output.stderr)
            ),
        ));
    }
    fs::write(
        &decision_path,
        serde_json::to_vec_pretty(&decision_json).map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!("failed to serialize ACP decision: {e}"),
            )
        })?,
    )
    .map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to write ACP decision temp file: {e}"),
        )
    })?;
    fs::write(
        &policy_decision_path,
        serde_json::to_vec_pretty(&decision_json).map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!("failed to serialize policy decision artifact: {e}"),
            )
        })?,
    )
    .map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to write policy decision artifact: {e}"),
        )
    })?;
    write_instruction_manifest(
        &instruction_manifest_path,
        request_json
            .get("instruction_layers")
            .cloned()
            .unwrap_or_else(|| json!([])),
    )?;
    let receipt_output = Command::new("bash")
        .arg(&receipt_writer)
        .arg("--policy")
        .arg(&policy_file)
        .arg("--request")
        .arg(&request_path)
        .arg("--decision")
        .arg(&decision_path)
        .current_dir(&cfg.repo_root)
        .output()
        .map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!("failed to emit ACP receipt: {e}"),
            )
        })?;
    fs::remove_file(&request_path).ok();
    fs::remove_file(&decision_path).ok();
    if !receipt_output.status.success() {
        return Err(KernelError::new(
            ErrorCode::Internal,
            format!(
                "ACP receipt emission failed: {}",
                String::from_utf8_lossy(&receipt_output.stderr)
            ),
        ));
    }

    if !receipt_path.is_file() {
        return Err(KernelError::new(
            ErrorCode::Internal,
            "policy receipt writer did not emit receipt.latest.json",
        ));
    }
    fs::create_dir_all(&canonical_receipts_root).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to create canonical receipt root {}: {e}",
                canonical_receipts_root.display()
            ),
        )
    })?;
    copy_json_if_present(&receipt_path, &canonical_policy_receipt_path)?;
    if digest_path.is_file() {
        copy_json_if_present(&digest_path, &canonical_policy_digest_path)?;
    }
    let validate_output = Command::new("bash")
        .arg(&policy_runner)
        .arg("receipt-validate")
        .arg("--policy")
        .arg(&policy_file)
        .arg("--receipt")
        .arg(&receipt_path)
        .current_dir(&cfg.repo_root)
        .output()
        .map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!("failed to validate ACP receipt: {e}"),
            )
        })?;
    if !validate_output.status.success() {
        return Err(KernelError::new(
            ErrorCode::Internal,
            format!(
                "ACP receipt validation failed: {}",
                String::from_utf8_lossy(&validate_output.stderr)
            ),
        ));
    }
    merge_replay_receipt_ref(
        &replay_pointers_path(cfg, &request.request_id),
        &request.request_id,
        path_tail(&cfg.repo_root, &canonical_policy_receipt_path),
    )?;
    merge_retained_evidence_ref(
        &retained_evidence_path(cfg, &request.request_id),
        &request.request_id,
        "policy_receipt",
        path_tail(&cfg.repo_root, &canonical_policy_receipt_path),
    )?;
    if canonical_policy_digest_path.is_file() {
        merge_retained_evidence_ref(
            &retained_evidence_path(cfg, &request.request_id),
            &request.request_id,
            "policy_digest",
            path_tail(&cfg.repo_root, &canonical_policy_digest_path),
        )?;
    }
    merge_retained_evidence_ref(
        &retained_evidence_path(cfg, &request.request_id),
        &request.request_id,
        "instruction_manifest",
        path_tail(&cfg.repo_root, &instruction_manifest_path),
    )?;

    Ok(PolicyArtifacts {
        allow: decision_json
            .get("allow")
            .and_then(|value| value.as_bool())
            .unwrap_or(false),
        decision,
        reason_codes: decision_json
            .get("reason_codes")
            .and_then(|value| value.as_array())
            .map(|items| {
                items
                    .iter()
                    .filter_map(|item| item.as_str().map(ToOwned::to_owned))
                    .collect::<Vec<_>>()
            })
            .unwrap_or_default(),
        remediation: decision_json
            .get("remediation")
            .and_then(|value| value.as_str())
            .map(ToOwned::to_owned),
        receipt_path: Some(path_tail(&cfg.repo_root, &canonical_policy_receipt_path)),
        digest_path: if digest_path.is_file() {
            Some(path_tail(&cfg.repo_root, &canonical_policy_digest_path))
        } else {
            None
        },
        instruction_manifest_path: Some(path_tail(&cfg.repo_root, &instruction_manifest_path)),
    })
}

pub(crate) fn resolve_acp_policy_path(cfg: &RuntimeConfig) -> PathBuf {
    if let Some(path) = &cfg.policy_path {
        let absolute = if path.is_absolute() {
            path.clone()
        } else {
            cfg.octon_dir.join(path)
        };
        let default_runtime_policy = cfg
            .octon_dir
            .join("framework/engine/runtime/config/policy.yml");
        if absolute.is_file() && absolute != default_runtime_policy {
            return absolute;
        }
    }
    cfg.repo_root
        .join(".octon/framework/capabilities/governance/policy/deny-by-default.v2.yml")
}

pub(crate) fn build_policy_request_json(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
    intent_ref: &IntentRef,
    execution_role_ref: &ExecutionRoleRef,
    effective_policy_mode: &str,
    budget_preview: Option<&BudgetMetadata>,
    autonomy_state: Option<&ResolvedAutonomyState>,
    ownership: &OwnershipPosture,
    support_tier: &SupportTierPosture,
    approval_request_ref: Option<&str>,
    approval_grant_refs: &[String],
    exception_refs: &[String],
    revocation_refs: &[String],
    network_egress_posture: Option<&NetworkEgressPosture>,
) -> CoreResult<serde_json::Value> {
    let request_json = serde_json::to_vec(request).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to serialize execution request: {e}"),
        )
    })?;
    let service_mode = request.caller_path == "service";
    let operation_class = if service_mode {
        autonomy_state
            .map(|state| state.action_class.as_str())
            .unwrap_or(if request.workflow_mode == "autonomous" {
                "service.autonomy_route_missing"
            } else {
                "service.execute"
            })
    } else {
        "execution.authorize"
    };
    let phase = if service_mode { "promote" } else { "stage" };
    let instruction_layers = json!([
        {
            "layer_id": "provider",
            "source": "upstream",
            "sha256": zero_sha256(),
            "bytes": 0,
            "visibility": "partial"
        },
        {
            "layer_id": "system",
            "source": "octon-system",
            "sha256": zero_sha256(),
            "bytes": 0,
            "visibility": "partial"
        },
        {
            "layer_id": "developer",
            "source": "AGENTS.md",
            "sha256": sha256_file(&cfg.repo_root.join(".octon/AGENTS.md")),
            "bytes": file_size(&cfg.repo_root.join(".octon/AGENTS.md")),
            "visibility": "full"
        },
        {
            "layer_id": "user",
            "source": "execution-request",
            "sha256": sha256_bytes(&request_json),
            "bytes": request_json.len(),
            "visibility": "full"
        }
    ]);

    Ok(json!({
        "run_id": request.request_id,
        "actor": {
            "id": execution_role_ref.id,
            "type": execution_role_ref.kind
        },
        "profile": policy_profile_for_request(request),
        "phase": phase,
        "intent": format!("execution authorization for {}", request.target_id),
        "boundaries": request.caller_path,
        "operation": {
            "class": operation_class,
            "target": {
                "material_side_effect": material_side_effect(request),
                "telemetry_profile": if effective_policy_mode == "hard-enforce" { "full" } else { "minimal" },
                "workflow_mode": request.workflow_mode.clone(),
                "capability_classification": capability_classification_for_mode(&request.workflow_mode),
                "boundary_route": if service_mode {
                    serde_json::Value::String("allow".to_string())
                } else {
                    serde_json::Value::Null
                }
            },
            "targets": [request.target_id],
            "resources": request.scope_constraints.write
        },
        "intent_ref": {
            "id": intent_ref.id,
            "version": intent_ref.version
        },
        "boundary_id": request.caller_path,
        "boundary_set_version": "v1",
        "workflow_mode": request.workflow_mode.clone(),
        "ownership": ownership,
        "support_tier": support_tier,
        "approval_request_ref": approval_request_ref,
        "approval_grant_refs": approval_grant_refs,
        "exception_refs": exception_refs,
        "revocation_refs": revocation_refs,
        "network_egress": network_egress_posture,
        "oversight_mode": autonomy_state.as_ref().map(|state| json!(state.context.oversight_mode.clone())).unwrap_or(serde_json::Value::Null),
        "execution_posture": autonomy_state.as_ref().map(|state| json!(state.context.execution_posture.clone())).unwrap_or(serde_json::Value::Null),
        "reversibility_class": autonomy_state.as_ref().map(|state| json!(state.context.reversibility_class.clone())).unwrap_or(serde_json::Value::Null),
        "autonomy_budget_state": autonomy_state.as_ref().map(|state| json!(state.autonomy_budget_state.clone())).unwrap_or(serde_json::Value::Null),
        "breaker_state": autonomy_state.as_ref().map(|state| json!(state.breaker_state.clone())).unwrap_or(serde_json::Value::Null),
        "capability_classification": capability_classification_for_mode(&request.workflow_mode),
        "mission_ref": autonomy_state.as_ref().map(|state| json!(state.context.mission_ref.clone())).unwrap_or(serde_json::Value::Null),
        "slice_ref": autonomy_state.as_ref().map(|state| json!(state.context.slice_ref.clone())).unwrap_or(serde_json::Value::Null),
        "reversibility": {
            "reversible": autonomy_state.as_ref().map(|state| state.context.reversibility_class.as_str() != "irreversible").unwrap_or(true),
            "primitive": autonomy_state
                .as_ref()
                .and_then(|state| state.reversibility_primitive.clone())
                .map(serde_json::Value::String)
                .unwrap_or_else(|| serde_json::Value::String("git.revert_commit".to_string())),
            "rollback_handle": autonomy_state
                .as_ref()
                .and_then(|state| state.rollback_handle.clone())
                .unwrap_or_else(|| format!("rollback-{}", request.request_id)),
            "compensation_handle": autonomy_state
                .as_ref()
                .and_then(|state| state.compensation_handle.clone())
                .map(serde_json::Value::String)
                .unwrap_or(serde_json::Value::Null),
            "recovery_window": autonomy_state
                .as_ref()
                .map(|state| state.recovery_window.clone())
                .unwrap_or_else(|| "P14D".to_string())
        },
        "evidence": if service_mode {
            json!([
                {
                    "type": "diff",
                    "ref": format!(".octon/state/evidence/runs/{}/execution-request.json", request.request_id)
                },
                {
                    "type": "docs.spec",
                    "ref": ".octon/framework/engine/runtime/spec/execution-authorization-v1.md"
                },
                {
                    "type": "docs.adr",
                    "ref": ".octon/instance/cognition/decisions/060-runtime-execution-governance-hardening-atomic-cutover.md"
                },
                {
                    "type": "docs.runbook",
                    "ref": ".octon/framework/assurance/runtime/_ops/scripts/validate-execution-governance.sh"
                }
            ])
        } else {
            json!([
                {
                    "type": "diff",
                    "ref": format!(".octon/state/evidence/runs/{}/execution-request.json", request.request_id)
                }
            ])
        },
        "instruction_layers": instruction_layers,
        "context_acquisition": {
            "file_reads": 0,
            "search_queries": 0,
            "commands": 1,
            "subagent_spawns": 0,
            "duration_ms": 0
        },
        "context_overhead_ratio": 0,
        "budget_rule_id": budget_preview.map(|metadata| metadata.rule_id.clone()),
        "budget_reason_codes": budget_preview
            .map(|metadata| metadata.reason_codes.clone())
            .unwrap_or_default(),
        "cost_evidence_path": budget_preview.and_then(|metadata| metadata.evidence_path.clone())
    }))
}

pub(crate) fn policy_profile_for_request(request: &ExecutionRequest) -> &'static str {
    if request.side_effect_flags.publication || request.action_type == "release_publication" {
        "release-readiness"
    } else if request.side_effect_flags.write_repo
        || request.side_effect_flags.shell
        || request.side_effect_flags.state_mutation
    {
        "refactor"
    } else {
        "docs"
    }
}

pub(crate) fn write_instruction_manifest(path: &Path, layers: serde_json::Value) -> CoreResult<()> {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent).map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!("failed to create instruction manifest directory: {e}"),
            )
        })?;
    }
    fs::write(
        path,
        serde_json::to_vec_pretty(&json!({
            "schema_version": "instruction-layer-manifest-v1",
            "generated_at": time::OffsetDateTime::now_utc()
                .format(&time::format_description::well_known::Rfc3339)
                .unwrap_or_else(|_| "1970-01-01T00:00:00Z".to_string()),
            "layers": layers,
        }))
        .map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!("failed to serialize instruction manifest: {e}"),
            )
        })?,
    )
    .map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to write instruction manifest: {e}"),
        )
    })?;
    Ok(())
}

pub(crate) fn material_side_effect(request: &ExecutionRequest) -> bool {
    request.side_effect_flags.write_repo
        || request.side_effect_flags.shell
        || request.side_effect_flags.network
        || request.side_effect_flags.model_invoke
        || request.side_effect_flags.state_mutation
        || request.side_effect_flags.publication
        || request.side_effect_flags.branch_mutation
}

pub(crate) fn authorize_network_egress(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
    executor_profile: Option<&str>,
) -> CoreResult<NetworkEgressDecision> {
    let service_id = request
        .metadata
        .get("network_egress_service")
        .map(|value| value.as_str())
        .unwrap_or("service");
    let method = request
        .metadata
        .get("network_egress_method")
        .map(|value| value.as_str())
        .unwrap_or("GET");
    let url = request.metadata.get("network_egress_url").ok_or_else(|| {
        KernelError::new(
            ErrorCode::CapabilityDenied,
            "network-capable execution request missing network target metadata",
        )
        .with_details(json!({"reason_codes":["NETWORK_EGRESS_CONTEXT_MISSING"]}))
    })?;
    let policy = load_network_egress_policy(&cfg.repo_root)?;
    let leases = load_execution_exception_leases(&cfg.repo_root)?;
    evaluate_network_egress(
        &policy,
        &leases,
        &NetworkEgressContext {
            service_id,
            adapter_id: request
                .metadata
                .get("network_egress_adapter")
                .map(|value| value.as_str()),
            executor_profile,
            method,
        },
        url,
    )
}

pub(crate) fn preview_execution_budget(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
    executor_profile: Option<&str>,
) -> CoreResult<Option<BudgetDecision>> {
    if !request.side_effect_flags.model_invoke {
        return Ok(None);
    }

    let policy = load_execution_budget_policy(&cfg.repo_root)?;
    let provider = request
        .metadata
        .get("budget_provider")
        .cloned()
        .or_else(|| {
            infer_provider_from_model(
                request
                    .metadata
                    .get("budget_model")
                    .map(|value| value.as_str()),
                request
                    .metadata
                    .get("executor_kind")
                    .map(|value| value.as_str()),
            )
        });
    let prompt_bytes = request
        .metadata
        .get("prompt_bytes")
        .and_then(|value| value.parse::<u64>().ok());

    let decision = evaluate_execution_budget(
        &policy,
        &BudgetCheckContext {
            request_id: &request.request_id,
            path_type: &request.caller_path,
            action_type: &request.action_type,
            executor_profile,
            provider: provider.as_deref(),
            model: request
                .metadata
                .get("budget_model")
                .map(|value| value.as_str()),
            prompt_bytes,
        },
    );

    match decision {
        BudgetDecision::Skip => Ok(None),
        other => Ok(Some(other)),
    }
}

pub(crate) fn finalize_execution_budget(
    cfg: &RuntimeConfig,
    decision: Option<BudgetDecision>,
    run_root: &Path,
) -> CoreResult<Option<BudgetMetadata>> {
    let Some(decision) = decision else {
        return Ok(None);
    };

    match decision {
        BudgetDecision::Allow {
            rule_id,
            reason_codes,
            evidence,
        } => {
            let evidence_path = write_execution_cost_evidence(run_root, &evidence)?;
            let _ = record_budget_consumption(&cfg.execution_control_root, &rule_id, &evidence)?;
            Ok(Some(BudgetMetadata {
                rule_id,
                reason_codes,
                provider: evidence.provider.clone(),
                model: evidence.model.clone(),
                estimated_cost_usd: evidence.estimated_cost_usd,
                actual_cost_usd: evidence.actual_cost_usd,
                evidence_path: Some(path_tail(&cfg.repo_root, &evidence_path)),
            }))
        }
        BudgetDecision::StageOnly {
            rule_id,
            reason_codes,
            message,
            evidence,
        } => {
            let evidence_path = write_execution_cost_evidence(run_root, &evidence)?;
            Err(
                KernelError::new(ErrorCode::CapabilityDenied, message).with_details(json!({
                    "reason_codes": reason_codes,
                    "budget_rule_id": rule_id,
                    "cost_evidence_path": path_tail(&cfg.repo_root, &evidence_path),
                })),
            )
        }
        BudgetDecision::Deny {
            rule_id,
            reason_codes,
            message,
            evidence,
        } => {
            let evidence_path = write_execution_cost_evidence(run_root, &evidence)?;
            Err(
                KernelError::new(ErrorCode::CapabilityDenied, message).with_details(json!({
                    "reason_codes": reason_codes,
                    "budget_rule_id": rule_id,
                    "cost_evidence_path": path_tail(&cfg.repo_root, &evidence_path),
                })),
            )
        }
        BudgetDecision::Skip => Ok(None),
    }
}

pub(crate) fn budget_metadata_from_decision(
    repo_root: &Path,
    run_root: &Path,
    decision: &BudgetDecision,
) -> BudgetMetadata {
    match decision {
        BudgetDecision::Allow {
            rule_id,
            reason_codes,
            evidence,
        }
        | BudgetDecision::StageOnly {
            rule_id,
            reason_codes,
            evidence,
            ..
        }
        | BudgetDecision::Deny {
            rule_id,
            reason_codes,
            evidence,
            ..
        } => BudgetMetadata {
            rule_id: rule_id.clone(),
            reason_codes: reason_codes.clone(),
            provider: evidence.provider.clone(),
            model: evidence.model.clone(),
            estimated_cost_usd: evidence.estimated_cost_usd,
            actual_cost_usd: evidence.actual_cost_usd,
            evidence_path: Some(path_tail(repo_root, &run_root.join("cost.json"))),
        },
        BudgetDecision::Skip => BudgetMetadata::default(),
    }
}

pub(crate) fn unique_temp_file(stem: &str, extension: &str) -> PathBuf {
    let millis = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|duration| duration.as_millis())
        .unwrap_or(0);
    std::env::temp_dir().join(format!(
        "{stem}-{millis}-{}.{}",
        std::process::id(),
        extension
    ))
}

pub(crate) fn zero_sha256() -> String {
    "0".repeat(64)
}

static ACP_TEST_LOCK: OnceLock<Mutex<()>> = OnceLock::new();

pub(crate) fn sha256_file(path: &Path) -> String {
    fs::read(path)
        .map(|bytes| sha256_bytes(&bytes))
        .unwrap_or_else(|_| zero_sha256())
}

pub(crate) fn sha256_bytes(bytes: &[u8]) -> String {
    format!("{:x}", Sha256::digest(bytes))
}

pub(crate) fn file_size(path: &Path) -> usize {
    fs::metadata(path)
        .map(|meta| meta.len() as usize)
        .unwrap_or(0)
}
