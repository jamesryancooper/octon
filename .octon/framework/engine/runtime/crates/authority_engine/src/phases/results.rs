use super::*;
use octon_core::config::RuntimeConfig;
use octon_core::errors::{ErrorCode, KernelError, Result as CoreResult};
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use std::collections::BTreeMap;
use std::path::Path;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub(crate) struct AuthorizationPhaseResult {
    pub schema_version: String,
    pub request_id: String,
    pub run_id: String,
    pub phase_id: String,
    pub phase_status: String,
    pub decision: ExecutionDecision,
    #[serde(default)]
    pub reason_codes: Vec<String>,
    #[serde(default)]
    pub artifact_refs: BTreeMap<String, String>,
    #[serde(default)]
    pub details: Value,
    pub generated_at: String,
}

pub(crate) fn write_phase_result(
    receipts_root: &Path,
    phase_result: &AuthorizationPhaseResult,
) -> anyhow::Result<String> {
    let path = phase_results_root(receipts_root).join(format!("{}.json", phase_result.phase_id));
    write_json(&path, phase_result)?;
    Ok(path.display().to_string())
}

pub(crate) fn record_phase_result(
    cfg: &RuntimeConfig,
    bound: &BoundRunLifecycle,
    request_id: &str,
    phase_result: &AuthorizationPhaseResult,
) -> CoreResult<String> {
    let path =
        phase_results_root(&bound.receipts_root).join(format!("{}.json", phase_result.phase_id));
    write_json(&path, phase_result).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to write authorization phase result {}: {e}",
                path.display()
            ),
        )
    })?;
    let rel = path_tail(&cfg.repo_root, &path);
    merge_replay_receipt_ref(&bound.replay_pointers_path, request_id, rel.clone())?;
    merge_retained_evidence_ref(
        &bound.retained_evidence_path,
        request_id,
        &format!("authorization_phase_{}", phase_result.phase_id),
        rel.clone(),
    )?;
    Ok(rel)
}

pub(crate) fn phase_result_details(summary: impl Into<String>, extra: Value) -> Value {
    json!({
        "summary": summary.into(),
        "extra": extra,
    })
}
