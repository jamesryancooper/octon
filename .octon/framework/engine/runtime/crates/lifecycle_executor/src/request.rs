use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;
use std::path::PathBuf;

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct LifecycleRouteExecutionRequest {
    pub schema_version: String,
    pub run_id: String,
    pub lifecycle_id: String,
    pub owner_extension: String,
    #[serde(default)]
    pub phase_id: Option<String>,
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
    #[serde(default)]
    pub interaction_request_refs: Vec<String>,
    #[serde(default)]
    pub interaction_return_refs: Vec<String>,
    pub policy: LifecycleExecutionPolicy,
    #[serde(default)]
    pub human_boundary_context: Option<LifecycleHumanBoundaryContext>,
    #[serde(default)]
    pub evidence_gate_results: BTreeMap<String, String>,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct LifecycleHumanBoundaryContext {
    pub context_kind: String,
    pub program_run_id: Option<String>,
    pub child_id: Option<String>,
    pub human_exception_instruction: Option<String>,
    pub retry_instruction: Option<String>,
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
    pub delegation_contract: Option<LifecycleDelegationContract>,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct LifecycleDelegationContract {
    pub decision_class: String,
    #[serde(default)]
    pub safe_delegation: bool,
    #[serde(default)]
    pub authority_zones_allowed: Vec<String>,
    pub declared_write_scope_source: String,
    #[serde(default)]
    pub required_evidence_gates: Vec<String>,
    #[serde(default)]
    pub required_receipts_before_dispatch: Vec<String>,
    #[serde(default)]
    pub required_receipts_before_completion: Vec<String>,
    pub replay_class: String,
    pub automated_recovery_policy: String,
    #[serde(default)]
    pub human_only_boundaries: Vec<String>,
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
    pub invocation_authority: LifecycleInvocationAuthority,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct LifecycleInvocationAuthority {
    pub mode: String,
    pub provenance: String,
    #[serde(default)]
    pub authority_ref: Option<String>,
}
