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

pub(crate) fn mission_denial(message: impl Into<String>, reason_codes: Vec<&str>) -> KernelError {
    KernelError::new(ErrorCode::CapabilityDenied, message.into()).with_details(json!({
        "reason_codes": reason_codes,
        "decision": "DENY"
    }))
}

pub(crate) fn mission_stage_only(
    message: impl Into<String>,
    reason_codes: Vec<&str>,
) -> KernelError {
    KernelError::new(ErrorCode::CapabilityDenied, message.into()).with_details(json!({
        "reason_codes": reason_codes,
        "decision": "STAGE_ONLY"
    }))
}

pub(crate) fn is_autonomous_request(request: &ExecutionRequest) -> bool {
    request.workflow_mode == "autonomous"
}

pub(crate) fn read_yaml_file<T>(path: &Path) -> CoreResult<T>
where
    T: for<'de> Deserialize<'de>,
{
    let raw = fs::read_to_string(path).map_err(|e| {
        KernelError::new(
            ErrorCode::CapabilityDenied,
            format!(
                "failed to read mission autonomy surface {}: {e}",
                path.display()
            ),
        )
    })?;
    serde_yaml::from_str::<T>(&raw).map_err(|e| {
        KernelError::new(
            ErrorCode::CapabilityDenied,
            format!(
                "failed to parse mission autonomy surface {}: {e}",
                path.display()
            ),
        )
    })
}

pub(crate) fn ensure_file_exists(path: &Path, reason_code: &str) -> CoreResult<()> {
    if path.is_file() {
        Ok(())
    } else {
        Err(mission_denial(
            format!(
                "required mission autonomy surface missing: {}",
                path.display()
            ),
            vec![reason_code],
        ))
    }
}

pub(crate) fn parse_rfc3339(raw: &str) -> CoreResult<time::OffsetDateTime> {
    time::OffsetDateTime::parse(raw, &time::format_description::well_known::Rfc3339).map_err(|e| {
        KernelError::new(
            ErrorCode::CapabilityDenied,
            format!("failed to parse RFC3339 timestamp '{raw}': {e}"),
        )
    })
}

pub(crate) fn decision_label(decision: &ExecutionDecision) -> &'static str {
    match decision {
        ExecutionDecision::Allow => "ALLOW",
        ExecutionDecision::StageOnly => "STAGE_ONLY",
        ExecutionDecision::Deny => "DENY",
        ExecutionDecision::Escalate => "ESCALATE",
    }
}

pub(crate) fn authority_control_root(cfg: &RuntimeConfig) -> PathBuf {
    cfg.execution_control_root.clone()
}

pub(crate) fn approval_request_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    authority_control_root(cfg)
        .join("approvals")
        .join("requests")
        .join(format!("{request_id}.yml"))
}

pub(crate) fn approval_grant_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    authority_control_root(cfg)
        .join("approvals")
        .join("grants")
        .join(format!("grant-{request_id}.yml"))
}

pub(crate) fn revocation_registry_path(cfg: &RuntimeConfig) -> PathBuf {
    authority_control_root(cfg)
        .join("revocations")
        .join("__legacy_removed__")
}

pub(crate) fn revocation_directory_path(cfg: &RuntimeConfig) -> PathBuf {
    authority_control_root(cfg).join("revocations")
}

pub(crate) fn authority_evidence_root(cfg: &RuntimeConfig) -> PathBuf {
    cfg.repo_root
        .join(".octon/state/evidence/control/execution")
}

pub(crate) fn decision_artifact_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    authority_evidence_root(cfg).join(format!("authority-decision-{request_id}.yml"))
}

pub(crate) fn authority_grant_bundle_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    authority_evidence_root(cfg).join(format!("authority-grant-bundle-{request_id}.yml"))
}

pub(crate) fn run_contract_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    cfg.execution_control_root
        .join("runs")
        .join(request_id)
        .join("run-contract.yml")
}

pub(crate) fn run_manifest_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    cfg.run_control_root(request_id).join("run-manifest.yml")
}

pub(crate) fn runtime_state_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    cfg.run_control_root(request_id).join("runtime-state.yml")
}

pub(crate) fn run_journal_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    cfg.run_control_root(request_id).join("events.ndjson")
}

pub(crate) fn run_journal_manifest_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    cfg.run_control_root(request_id).join("events.manifest.yml")
}

pub(crate) fn run_journal_snapshot_root(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    cfg.run_root(request_id).join("run-journal")
}

pub(crate) fn run_journal_snapshot_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    run_journal_snapshot_root(cfg, request_id).join("events.snapshot.ndjson")
}

pub(crate) fn run_journal_manifest_snapshot_path(
    cfg: &RuntimeConfig,
    request_id: &str,
) -> PathBuf {
    run_journal_snapshot_root(cfg, request_id).join("events.manifest.snapshot.yml")
}

pub(crate) fn run_journal_redaction_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    run_journal_snapshot_root(cfg, request_id).join("redactions.yml")
}

pub(crate) fn rollback_posture_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    cfg.run_control_root(request_id)
        .join("rollback-posture.yml")
}

pub(crate) fn control_checkpoint_path(
    cfg: &RuntimeConfig,
    request_id: &str,
    checkpoint_id: &str,
) -> PathBuf {
    cfg.run_control_root(request_id)
        .join("checkpoints")
        .join(format!("{checkpoint_id}.yml"))
}

pub(crate) fn evidence_checkpoint_path(
    cfg: &RuntimeConfig,
    request_id: &str,
    checkpoint_id: &str,
) -> PathBuf {
    cfg.run_root(request_id)
        .join("checkpoints")
        .join(format!("{checkpoint_id}.yml"))
}

pub(crate) fn stage_attempt_dir_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    cfg.run_control_root(request_id).join("stage-attempts")
}

pub(crate) fn stage_attempt_file_path(
    cfg: &RuntimeConfig,
    request_id: &str,
    stage_attempt_id: &str,
) -> PathBuf {
    stage_attempt_dir_path(cfg, request_id).join(format!("{stage_attempt_id}.yml"))
}

pub(crate) fn evidence_receipts_root(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    cfg.run_root(request_id).join("receipts")
}

pub(crate) fn replay_pointers_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    cfg.run_root(request_id).join("replay-pointers.yml")
}

pub(crate) fn trace_pointers_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    cfg.run_root(request_id).join("trace-pointers.yml")
}

pub(crate) fn retained_evidence_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    cfg.run_root(request_id).join("retained-run-evidence.yml")
}

pub(crate) fn evidence_classification_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    cfg.run_root(request_id).join("evidence-classification.yml")
}

pub(crate) fn run_continuity_handoff_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    cfg.run_continuity_path(request_id).join("handoff.yml")
}

pub(crate) fn stage_attempt_id_for_request(request: &ExecutionRequest) -> String {
    request
        .metadata
        .get("stage_id")
        .map(|stage_id| format!("{stage_id}--initial"))
        .unwrap_or_else(|| "initial".to_string())
}

pub(crate) fn stage_ref_for_request(request: &ExecutionRequest) -> String {
    if let Some(stage_id) = request.metadata.get("stage_id") {
        return format!("workflow-stage:{stage_id}");
    }
    if let Some(workflow_id) = request.metadata.get("workflow_id") {
        return format!("workflow:{workflow_id}");
    }
    request.target_id.clone()
}

pub(crate) fn required_request_metadata(
    request: &ExecutionRequest,
    key: &str,
) -> CoreResult<String> {
    request
        .metadata
        .get(key)
        .map(|value| value.trim().to_string())
        .filter(|value| !value.is_empty())
        .ok_or_else(|| {
            KernelError::new(
                ErrorCode::CapabilityDenied,
                format!("execution request missing required support-target binding: {key}"),
            )
            .with_details(
                json!({"reason_codes":["SUPPORT_TARGET_BINDING_MISSING"],"missing_key":key}),
            )
        })
}

pub(crate) fn requested_support_target_tuple(
    request: &ExecutionRequest,
) -> CoreResult<SupportTargetTuple> {
    Ok(SupportTargetTuple {
        model_tier: required_request_metadata(request, "support_model_tier")?,
        workload_tier: required_request_metadata(request, "support_tier")?,
        language_resource_tier: required_request_metadata(
            request,
            "support_language_resource_tier",
        )?,
        locale_tier: required_request_metadata(request, "support_locale_tier")?,
        host_adapter: required_request_metadata(request, "support_host_adapter")?,
        model_adapter: required_request_metadata(request, "support_model_adapter")?,
    })
}
