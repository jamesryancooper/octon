use crate::errors::LifecycleErrorClass;
use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;
use std::path::PathBuf;

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct LifecycleRouteExecutionResult {
    pub schema_version: String,
    pub run_id: String,
    pub route_id: String,
    pub executor_used: String,
    pub status: String,
    pub started_at: String,
    pub ended_at: String,
    pub manifest_status_before: Option<String>,
    pub manifest_status_after: Option<String>,
    #[serde(default)]
    pub receipts_observed: Vec<ReceiptObservation>,
    #[serde(default)]
    pub evidence_paths: Vec<PathBuf>,
    pub stdout_path: Option<PathBuf>,
    pub stderr_path: Option<PathBuf>,
    pub prompt_packet_path: Option<PathBuf>,
    pub retryable: bool,
    pub next_action: String,
    pub error_class: Option<LifecycleErrorClass>,
    pub error_message: Option<String>,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct ReceiptObservation {
    pub receipt_id: String,
    pub path: PathBuf,
    pub exists: bool,
    pub complete: bool,
    pub verdict: Option<String>,
    #[serde(default)]
    pub missing_required_fields: Vec<String>,
    #[serde(default)]
    pub fields: BTreeMap<String, String>,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct LifecycleRouteCompletionObservation {
    pub schema_version: String,
    pub route_id: String,
    pub manifest_status_before: Option<String>,
    pub manifest_status_after: Option<String>,
    pub expected_manifest_status: Option<String>,
    #[serde(default)]
    pub receipts_observed: Vec<ReceiptObservation>,
    #[serde(default)]
    pub expected_receipts: Vec<String>,
    #[serde(default)]
    pub expected_paths: Vec<String>,
    #[serde(default)]
    pub missing_expected_paths: Vec<PathBuf>,
    #[serde(default)]
    pub expected_target_change: bool,
    pub target_digest_before: Option<String>,
    pub target_digest_after: Option<String>,
    pub completion_observed: bool,
    pub completion_message: String,
}
