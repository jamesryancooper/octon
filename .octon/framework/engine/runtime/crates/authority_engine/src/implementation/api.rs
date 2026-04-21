use super::*;
use octon_core::config::{ExecutorProfileConfig, RuntimeConfig};
use octon_core::errors::{ErrorCode, KernelError, Result as CoreResult};
use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;
use std::fs;
use std::path::{Path, PathBuf};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct IntentRef {
    pub id: String,
    pub version: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExecutionRoleRef {
    pub kind: String,
    pub id: String,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct SupportTargetTuple {
    #[serde(default)]
    pub model_tier: String,
    #[serde(default)]
    pub workload_tier: String,
    #[serde(default)]
    pub language_resource_tier: String,
    #[serde(default)]
    pub locale_tier: String,
    #[serde(default)]
    pub host_adapter: String,
    #[serde(default)]
    pub model_adapter: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AutonomyRef {
    pub id: String,
    #[serde(default)]
    pub version: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AutonomyContext {
    pub mission_ref: AutonomyRef,
    pub slice_ref: AutonomyRef,
    pub intent_ref: IntentRef,
    pub mission_class: String,
    pub oversight_mode: String,
    pub execution_posture: String,
    pub reversibility_class: String,
    pub boundary_id: String,
    #[serde(default)]
    pub applied_directive_refs: Vec<String>,
    #[serde(default)]
    pub applied_authorize_update_refs: Vec<String>,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct SideEffectFlags {
    #[serde(default)]
    pub write_repo: bool,
    #[serde(default)]
    pub write_evidence: bool,
    #[serde(default)]
    pub shell: bool,
    #[serde(default)]
    pub network: bool,
    #[serde(default)]
    pub model_invoke: bool,
    #[serde(default)]
    pub state_mutation: bool,
    #[serde(default)]
    pub publication: bool,
    #[serde(default)]
    pub branch_mutation: bool,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct ReviewRequirements {
    #[serde(default)]
    pub human_approval: bool,
    #[serde(default)]
    pub quorum: bool,
    #[serde(default)]
    pub rollback_metadata: bool,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct ScopeConstraints {
    #[serde(default)]
    pub read: Vec<String>,
    #[serde(default)]
    pub write: Vec<String>,
    #[serde(default)]
    pub executor_profile: Option<String>,
    #[serde(default)]
    pub locality_scope: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExecutionRequest {
    pub request_id: String,
    pub caller_path: String,
    pub action_type: String,
    pub target_id: String,
    #[serde(default)]
    pub requested_capabilities: Vec<String>,
    #[serde(default)]
    pub side_effect_flags: SideEffectFlags,
    pub risk_tier: String,
    #[serde(default = "default_workflow_mode")]
    pub workflow_mode: String,
    #[serde(default)]
    pub locality_scope: Option<String>,
    #[serde(default)]
    pub intent_ref: Option<IntentRef>,
    #[serde(default)]
    pub autonomy_context: Option<AutonomyContext>,
    #[serde(default)]
    pub execution_role_ref: Option<ExecutionRoleRef>,
    #[serde(default)]
    pub parent_run_ref: Option<String>,
    #[serde(default)]
    pub review_requirements: ReviewRequirements,
    #[serde(default)]
    pub scope_constraints: ScopeConstraints,
    #[serde(default)]
    pub policy_mode_requested: Option<String>,
    #[serde(default)]
    pub environment_hint: Option<String>,
    #[serde(default)]
    pub metadata: BTreeMap<String, String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
pub enum ExecutionDecision {
    Allow,
    StageOnly,
    Deny,
    Escalate,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum ExecutionEnvironment {
    Development,
    Protected,
}

impl ExecutionEnvironment {
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Development => "development",
            Self::Protected => "protected",
        }
    }
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct BudgetMetadata {
    pub rule_id: String,
    #[serde(default)]
    pub reason_codes: Vec<String>,
    #[serde(default)]
    pub provider: Option<String>,
    #[serde(default)]
    pub model: Option<String>,
    #[serde(default)]
    pub estimated_cost_usd: Option<f64>,
    #[serde(default)]
    pub actual_cost_usd: Option<f64>,
    #[serde(default)]
    pub evidence_path: Option<String>,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct AuthorityProjection {
    pub kind: String,
    #[serde(rename = "ref", alias = "ref_id")]
    pub ref_id: String,
    #[serde(default)]
    pub notes: Option<String>,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct OwnershipPosture {
    pub status: String,
    #[serde(default)]
    pub source: String,
    #[serde(default)]
    pub owner_refs: Vec<String>,
    #[serde(default)]
    pub matched_asset_ref: Option<String>,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct SupportTierPosture {
    pub support_tier: String,
    #[serde(default)]
    pub model_tier_id: Option<String>,
    #[serde(default)]
    pub workload_tier_id: Option<String>,
    #[serde(default)]
    pub language_resource_tier_id: Option<String>,
    #[serde(default)]
    pub locale_tier_id: Option<String>,
    #[serde(default)]
    pub workload_tier_label: Option<String>,
    #[serde(default)]
    pub host_adapter_id: Option<String>,
    #[serde(default)]
    pub host_adapter_status: Option<String>,
    #[serde(default)]
    pub model_adapter_id: Option<String>,
    #[serde(default)]
    pub model_adapter_status: Option<String>,
    #[serde(default)]
    pub adapter_conformance_criteria: Vec<String>,
    #[serde(default)]
    pub support_status: String,
    #[serde(default)]
    pub route: String,
    #[serde(default)]
    pub requires_mission: bool,
    #[serde(default)]
    pub required_evidence: Vec<String>,
    #[serde(default)]
    pub allowed_capability_packs: Vec<String>,
    #[serde(default)]
    pub requested_capability_packs: Vec<String>,
    #[serde(default)]
    pub declaration_ref: Option<String>,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct NetworkEgressPosture {
    pub route: String,
    #[serde(default)]
    pub matched_rule_id: Option<String>,
    #[serde(default)]
    pub source_kind: Option<String>,
    #[serde(default)]
    pub artifact_ref: Option<String>,
    #[serde(default)]
    pub target_url: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ApprovalRequestArtifact {
    pub schema_version: String,
    pub request_id: String,
    pub run_id: String,
    pub status: String,
    pub target_id: String,
    pub action_type: String,
    pub workflow_mode: String,
    pub support_tier: String,
    #[serde(default)]
    pub quorum_policy_ref: Option<String>,
    #[serde(default)]
    pub ownership_refs: Vec<String>,
    #[serde(default)]
    pub reversibility_class: Option<String>,
    #[serde(default)]
    pub reason_codes: Vec<String>,
    #[serde(default)]
    pub required_evidence: Vec<String>,
    #[serde(default)]
    pub projection_sources: Vec<AuthorityProjection>,
    pub created_at: String,
    pub updated_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ApprovalGrantArtifact {
    pub schema_version: String,
    pub grant_id: String,
    pub request_id: String,
    pub run_id: String,
    pub state: String,
    pub issued_by: String,
    pub issued_at: String,
    #[serde(default)]
    pub expires_at: Option<String>,
    #[serde(default)]
    pub quorum_policy_ref: Option<String>,
    #[serde(default)]
    pub projection_sources: Vec<AuthorityProjection>,
    #[serde(default)]
    pub review_metadata: BTreeMap<String, String>,
    #[serde(default)]
    pub required_evidence: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RevocationArtifact {
    pub schema_version: String,
    pub revocation_id: String,
    #[serde(default)]
    pub grant_id: Option<String>,
    #[serde(default)]
    pub request_id: Option<String>,
    #[serde(default)]
    pub run_id: Option<String>,
    pub state: String,
    pub revoked_at: String,
    pub revoked_by: String,
    #[serde(default)]
    pub reason_codes: Vec<String>,
    #[serde(default)]
    pub notes: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DecisionArtifact {
    pub schema_version: String,
    pub decision_id: String,
    pub request_id: String,
    pub run_id: String,
    pub decision: ExecutionDecision,
    #[serde(default)]
    pub reason_codes: Vec<String>,
    pub ownership: OwnershipPosture,
    pub support_tier: SupportTierPosture,
    pub reversibility: serde_json::Value,
    pub budget: serde_json::Value,
    pub egress: serde_json::Value,
    #[serde(default)]
    pub approval_request_ref: Option<String>,
    #[serde(default)]
    pub approval_grant_refs: Vec<String>,
    #[serde(default)]
    pub exception_refs: Vec<String>,
    #[serde(default)]
    pub revocation_refs: Vec<String>,
    pub generated_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GrantBundle {
    pub grant_id: String,
    pub request_id: String,
    pub decision: ExecutionDecision,
    #[serde(default)]
    pub granted_capabilities: Vec<String>,
    pub scope_constraints: ScopeConstraints,
    pub effective_policy_mode: String,
    #[serde(default)]
    pub reason_codes: Vec<String>,
    #[serde(default)]
    pub review_metadata: BTreeMap<String, String>,
    #[serde(default)]
    pub expires_after: Option<String>,
    #[serde(default)]
    pub receipt_requirements: Vec<String>,
    pub environment_class: ExecutionEnvironment,
    pub workflow_mode: String,
    pub intent_ref: IntentRef,
    #[serde(default)]
    pub autonomy_context: Option<AutonomyContext>,
    pub execution_role_ref: ExecutionRoleRef,
    pub run_root: String,
    #[serde(default)]
    pub run_control_root: Option<String>,
    #[serde(default)]
    pub run_receipts_root: Option<String>,
    #[serde(default)]
    pub replay_pointers_path: Option<String>,
    #[serde(default)]
    pub trace_pointers_path: Option<String>,
    #[serde(default)]
    pub retained_evidence_path: Option<String>,
    #[serde(default)]
    pub stage_attempt_ref: Option<String>,
    #[serde(default)]
    pub policy_receipt_path: Option<String>,
    #[serde(default)]
    pub policy_digest_path: Option<String>,
    #[serde(default)]
    pub instruction_manifest_path: Option<String>,
    #[serde(default)]
    pub budget: Option<BudgetMetadata>,
    #[serde(default)]
    pub rollback_handle: Option<String>,
    #[serde(default)]
    pub compensation_handle: Option<String>,
    #[serde(default)]
    pub recovery_window: Option<String>,
    #[serde(default)]
    pub autonomy_budget_state: Option<String>,
    #[serde(default)]
    pub breaker_state: Option<String>,
    #[serde(default)]
    pub support_tier: Option<String>,
    #[serde(default)]
    pub support_posture: Option<SupportTierPosture>,
    #[serde(default)]
    pub quorum_policy_ref: Option<String>,
    #[serde(default)]
    pub ownership_refs: Vec<String>,
    #[serde(default)]
    pub approval_request_ref: Option<String>,
    #[serde(default)]
    pub approval_grant_refs: Vec<String>,
    #[serde(default)]
    pub exception_lease_refs: Vec<String>,
    #[serde(default)]
    pub revocation_refs: Vec<String>,
    #[serde(default)]
    pub decision_artifact_ref: Option<String>,
    #[serde(default)]
    pub authority_grant_bundle_ref: Option<String>,
    #[serde(default)]
    pub network_egress_posture: Option<NetworkEgressPosture>,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct SideEffectSummary {
    #[serde(default)]
    pub touched_scope: Vec<String>,
    #[serde(default)]
    pub shell_commands: Vec<String>,
    #[serde(default)]
    pub network_targets: Vec<String>,
    #[serde(default)]
    pub publications: Vec<String>,
    #[serde(default)]
    pub branch_mutations: Vec<String>,
    #[serde(default)]
    pub executor_profile: Option<String>,
    #[serde(default)]
    pub dangerous_flags_blocked: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExecutionOutcome {
    pub status: String,
    pub started_at: String,
    pub completed_at: String,
    #[serde(default)]
    pub error: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExecutionReceipt {
    pub schema_version: String,
    pub request_id: String,
    pub grant_id: String,
    pub target_id: String,
    pub action_type: String,
    pub path_type: String,
    pub environment_class: String,
    pub workflow_mode: String,
    pub intent_ref: IntentRef,
    #[serde(default)]
    pub mission_ref: Option<AutonomyRef>,
    #[serde(default)]
    pub slice_ref: Option<AutonomyRef>,
    #[serde(default)]
    pub mission_class: Option<String>,
    #[serde(default)]
    pub oversight_mode: Option<String>,
    #[serde(default)]
    pub execution_posture: Option<String>,
    #[serde(default)]
    pub reversibility_class: Option<String>,
    #[serde(default)]
    pub boundary_id: Option<String>,
    #[serde(default)]
    pub rollback_handle: Option<String>,
    #[serde(default)]
    pub compensation_handle: Option<String>,
    #[serde(default)]
    pub recovery_window: Option<String>,
    #[serde(default)]
    pub autonomy_budget_state: Option<String>,
    #[serde(default)]
    pub breaker_state: Option<String>,
    #[serde(default)]
    pub applied_directive_refs: Vec<String>,
    #[serde(default)]
    pub applied_authorize_update_refs: Vec<String>,
    pub execution_role_ref: ExecutionRoleRef,
    #[serde(default)]
    pub requested_capabilities: Vec<String>,
    #[serde(default)]
    pub granted_capabilities: Vec<String>,
    pub policy_mode_requested: String,
    pub policy_mode_effective: String,
    pub decision: ExecutionDecision,
    #[serde(default)]
    pub reason_codes: Vec<String>,
    #[serde(default)]
    pub touched_scope: Vec<String>,
    pub side_effects: SideEffectSummary,
    pub override_requested: bool,
    pub override_accepted: bool,
    pub ai_review_enforced: bool,
    pub autonomy_policy_enforced: bool,
    #[serde(default)]
    pub evidence_links: BTreeMap<String, String>,
    #[serde(default)]
    pub budget: Option<BudgetMetadata>,
    #[serde(default)]
    pub support_tier: Option<String>,
    #[serde(default)]
    pub ownership_refs: Vec<String>,
    #[serde(default)]
    pub approval_request_ref: Option<String>,
    #[serde(default)]
    pub approval_grant_refs: Vec<String>,
    #[serde(default)]
    pub exception_lease_refs: Vec<String>,
    #[serde(default)]
    pub revocation_refs: Vec<String>,
    #[serde(default)]
    pub decision_artifact_ref: Option<String>,
    #[serde(default)]
    pub authority_grant_bundle_ref: Option<String>,
    #[serde(default)]
    pub network_egress_posture: Option<NetworkEgressPosture>,
    pub timestamps: ReceiptTimestamps,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ReceiptTimestamps {
    pub started_at: String,
    pub completed_at: String,
}

#[derive(Debug, Clone)]
pub struct ExecutionArtifactPaths {
    pub root: PathBuf,
    pub request: PathBuf,
    pub decision: PathBuf,
    pub grant: PathBuf,
    pub side_effects: PathBuf,
    pub outcome: PathBuf,
    pub receipt: PathBuf,
}

impl ExecutionArtifactPaths {
    pub fn new(root: PathBuf) -> Self {
        Self {
            request: root.join("execution-request.json"),
            decision: root.join("policy-decision.json"),
            grant: root.join("grant-bundle.json"),
            side_effects: root.join("side-effects.json"),
            outcome: root.join("outcome.json"),
            receipt: root.join("execution-receipt.json"),
            root,
        }
    }
}

pub enum ManagedExecutorKind {
    Codex,
    Claude,
}

pub struct ExecutorCommandSpec<'a> {
    pub kind: ManagedExecutorKind,
    pub executor_bin: &'a Path,
    pub repo_root: &'a Path,
    pub output_path: Option<&'a Path>,
    pub model: Option<&'a str>,
    pub profile: &'a ExecutorProfileConfig,
}

pub fn default_execution_role_ref() -> ExecutionRoleRef {
    ExecutionRoleRef {
        kind: std::env::var("OCTON_EXECUTION_ROLE_KIND").unwrap_or_else(|_| "system".to_string()),
        id: std::env::var("OCTON_EXECUTION_ROLE_ID").unwrap_or_else(|_| "octon-kernel".to_string()),
    }
}

fn default_workflow_mode() -> String {
    "role-mediated".to_string()
}

pub(crate) fn canonical_quorum_policy_ref() -> &'static str {
    ".octon/instance/governance/policies/mission-autonomy.yml#quorum"
}

pub fn default_policy_mode(cfg: &RuntimeConfig) -> String {
    std::env::var("OCTON_POLICY_MODE_OVERRIDE")
        .or_else(|_| std::env::var("OCTON_EFFECTIVE_POLICY_MODE"))
        .unwrap_or_else(|_| cfg.execution_governance.default_policy_mode.clone())
}

pub fn active_intent_ref(cfg: &RuntimeConfig) -> Option<IntentRef> {
    let path = cfg.repo_root.join(".octon/instance/charter/workspace.yml");
    let raw = fs::read_to_string(path).ok()?;
    let doc = serde_yaml::from_str::<serde_yaml::Value>(&raw).ok()?;
    let chart_id = doc
        .get("workspace_charter_id")
        .and_then(|value| value.as_str())
        .or_else(|| doc.get("intent_id").and_then(|value| value.as_str()))
        .or_else(|| {
            doc.get("legacy_intent_lineage")
                .and_then(|value| value.get("intent_id"))
                .and_then(|value| value.as_str())
        })?;
    Some(IntentRef {
        id: chart_id.to_string(),
        version: doc.get("version")?.as_str()?.to_string(),
    })
}

pub fn resolve_execution_environment(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
) -> ExecutionEnvironment {
    if matches!(request.environment_hint.as_deref(), Some("protected")) {
        return ExecutionEnvironment::Protected;
    }

    if cfg
        .execution_governance
        .protected_workflows
        .contains(&request.target_id)
        || request
            .metadata
            .get("workflow_id")
            .map(|value| cfg.execution_governance.protected_workflows.contains(value))
            .unwrap_or(false)
    {
        return ExecutionEnvironment::Protected;
    }

    if request.side_effect_flags.publication
        || request.side_effect_flags.branch_mutation
        || request.action_type == "release_publication"
    {
        return ExecutionEnvironment::Protected;
    }

    if let Some(branch) = current_branch(&cfg.repo_root) {
        if cfg.execution_governance.protected_refs.contains(&branch)
            && (request.side_effect_flags.write_repo
                || request.side_effect_flags.publication
                || request.side_effect_flags.branch_mutation)
        {
            return ExecutionEnvironment::Protected;
        }
    }

    ExecutionEnvironment::Development
}
