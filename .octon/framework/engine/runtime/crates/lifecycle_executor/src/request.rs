use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;
use std::path::PathBuf;

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct LifecycleRouteExecutionRequest {
    pub schema_version: String,
    pub run_id: String,
    pub lifecycle_id: String,
    pub owner_extension: String,
    pub target: PathBuf,
    pub manifest_path: String,
    pub status_field: String,
    pub executor: String,
    pub route: LifecycleRouteSpec,
    pub effective_extension_catalog: PathBuf,
    pub runtime_route_bundle: PathBuf,
    #[serde(default)]
    pub bound_inputs: BTreeMap<String, String>,
    #[serde(default)]
    pub receipts: Vec<LifecycleReceiptSpec>,
    #[serde(default)]
    pub expected_receipts: Vec<String>,
    #[serde(default)]
    pub expected_paths: Vec<String>,
    pub expected_manifest_status: Option<String>,
    #[serde(default)]
    pub expected_target_change: bool,
    pub evidence_root: PathBuf,
    pub checkpoint_path: PathBuf,
    pub policy: LifecycleExecutionPolicy,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct LifecycleRouteSpec {
    pub route_id: String,
    pub route_type: String,
    pub command_id: Option<String>,
    pub skill_id: Option<String>,
    pub prompt_set_id: Option<String>,
    #[serde(default)]
    pub required_inputs: Vec<String>,
    #[serde(default)]
    pub completion_replan_required: bool,
    #[serde(default)]
    pub approval_required_by_default: bool,
    pub approval_reason: Option<String>,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct LifecycleReceiptSpec {
    pub receipt_id: String,
    pub path: String,
    #[serde(default)]
    pub required_fields: Vec<String>,
    pub verdict_field: Option<String>,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct LifecycleExecutionPolicy {
    pub timeout_seconds: u64,
    pub cancellation_token: Option<PathBuf>,
    pub retry_attempt: u32,
    pub approval_policy: String,
}
