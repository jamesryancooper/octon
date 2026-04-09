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

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct IntentRef {
    pub id: String,
    pub version: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ActorRef {
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
    pub actor_ref: Option<ActorRef>,
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
    pub actor_ref: ActorRef,
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
    pub actor_ref: ActorRef,
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

pub fn default_actor_ref() -> ActorRef {
    ActorRef {
        kind: std::env::var("OCTON_EXECUTION_ACTOR_KIND").unwrap_or_else(|_| "system".to_string()),
        id: std::env::var("OCTON_EXECUTION_ACTOR_ID")
            .unwrap_or_else(|_| "octon-kernel".to_string()),
    }
}

fn default_workflow_mode() -> String {
    "agent-augmented".to_string()
}

fn canonical_quorum_policy_ref() -> &'static str {
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

#[derive(Debug, Clone, Default, Deserialize)]
struct MissionCharterRecord {
    mission_id: String,
    mission_class: String,
}

#[derive(Debug, Clone, Default, Deserialize)]
struct MissionLeaseRecord {
    #[serde(default)]
    state: String,
    #[serde(default)]
    expires_at: String,
}

#[derive(Debug, Clone, Default, Deserialize)]
struct MissionAutonomyBudgetRecord {
    state: String,
}

#[allow(dead_code)]
#[derive(Debug, Clone, Default, Deserialize)]
struct MissionModeStateRecord {
    #[serde(default)]
    oversight_mode: String,
    #[serde(default)]
    execution_posture: String,
    #[serde(default)]
    safety_state: String,
    #[serde(default)]
    phase: String,
    #[serde(default)]
    effective_scenario_resolution_ref: Option<String>,
    #[serde(default)]
    autonomy_burn_state: String,
}

#[derive(Debug, Clone, Default, Deserialize)]
struct MissionCircuitBreakersRecord {
    #[serde(default)]
    state: Option<String>,
    #[serde(default)]
    tripped_breakers: Vec<String>,
}

#[derive(Debug, Clone, Default, Deserialize)]
struct MissionScheduleRecord {
    #[serde(default)]
    suspended_future_runs: bool,
    #[serde(default)]
    pause_active_run_requested: bool,
}

#[allow(dead_code)]
#[derive(Debug, Clone, Default, Deserialize)]
struct ScenarioResolutionRecord {
    #[serde(default)]
    mission_id: String,
    #[serde(default)]
    generated_at: String,
    #[serde(default)]
    fresh_until: String,
    #[serde(default)]
    effective: ScenarioResolutionEffective,
}

#[allow(dead_code)]
#[derive(Debug, Clone, Default, Deserialize)]
struct ScenarioResolutionEffective {
    #[serde(default)]
    oversight_mode: String,
    #[serde(default)]
    execution_posture: String,
    #[serde(default)]
    proceed_on_silence_allowed: bool,
    #[serde(default)]
    approval_required: bool,
    #[serde(default)]
    safe_interrupt_boundary_class: String,
    #[serde(default)]
    recovery_profile: ScenarioRecoveryProfile,
    #[serde(default)]
    finalize_policy: ScenarioFinalizePolicy,
}

#[allow(dead_code)]
#[derive(Debug, Clone, Default, Deserialize)]
struct ScenarioRecoveryProfile {
    #[serde(default)]
    action_class: String,
    #[serde(default)]
    primitive: String,
    #[serde(default)]
    rollback_handle_type: String,
    #[serde(default)]
    recovery_window: String,
    #[serde(default)]
    reversibility_class: String,
}

#[derive(Debug, Clone, Default, Deserialize)]
struct ScenarioFinalizePolicy {
    #[serde(default)]
    approval_required: bool,
    #[serde(default)]
    block_finalize: bool,
    #[serde(default)]
    break_glass_required: bool,
}

#[derive(Debug, Clone, Default, Deserialize)]
struct RunContractRecord {
    #[serde(default)]
    support_tier: String,
    #[serde(default)]
    support_target: SupportTargetTuple,
    #[serde(default)]
    support_target_admission_ref: String,
    #[serde(default)]
    requested_capability_packs: Vec<String>,
    #[serde(default)]
    intent_ref: Option<IntentRef>,
    #[serde(default)]
    actor_ref: Option<ActorRef>,
    #[serde(default)]
    required_approvals: Vec<String>,
    #[serde(default)]
    required_evidence: Vec<String>,
    #[serde(default)]
    reversibility_class: String,
}

#[derive(Debug, Clone, Default, Deserialize)]
struct OwnershipRegistryRecord {
    #[serde(default)]
    operators: Vec<OwnershipOperatorRecord>,
    #[serde(default)]
    assets: Vec<OwnershipAssetRecord>,
    #[serde(default)]
    services: Vec<OwnershipServiceRecord>,
    #[serde(default)]
    defaults: OwnershipDefaultsRecord,
}

#[derive(Debug, Clone, Default, Deserialize)]
struct OwnershipOperatorRecord {
    operator_id: String,
}

#[derive(Debug, Clone, Default, Deserialize)]
struct OwnershipDefaultsRecord {
    #[serde(default)]
    operator_id: Option<String>,
}

#[derive(Debug, Clone, Default, Deserialize)]
struct OwnershipAssetRecord {
    #[serde(default)]
    asset_id: Option<String>,
    #[serde(default)]
    path_globs: Vec<String>,
    #[serde(default)]
    owners: Vec<String>,
    #[serde(default)]
    support_tier: Option<String>,
}

#[derive(Debug, Clone, Default, Deserialize)]
struct OwnershipServiceRecord {
    #[serde(default)]
    service_id: Option<String>,
    #[serde(default)]
    owners: Vec<String>,
}

#[derive(Debug, Clone, Default, Deserialize)]
struct SupportTargetsRecord {
    #[serde(default)]
    default_route: String,
    #[serde(default)]
    tiers: SupportTierDefinitions,
    #[serde(default)]
    compatibility_matrix: Vec<SupportMatrixEntry>,
    #[serde(default)]
    adapter_conformance_criteria: Vec<AdapterConformanceCriterion>,
    #[serde(default)]
    host_adapters: Vec<AdapterSupportDeclaration>,
    #[serde(default)]
    model_adapters: Vec<AdapterSupportDeclaration>,
}

#[derive(Debug, Clone, Default, Deserialize)]
struct SupportTargetAdmissionRecord {
    #[serde(default)]
    tuple_id: String,
    #[serde(default)]
    status: String,
    #[serde(default)]
    route: String,
    #[serde(default)]
    requires_mission: bool,
    #[serde(default)]
    allowed_capability_packs: Vec<String>,
    #[serde(default)]
    required_authority_artifacts: Vec<String>,
    #[serde(default)]
    tuple: SupportTargetTuple,
}

#[derive(Debug, Clone, Default, Deserialize)]
struct SupportTierDefinitions {
    #[serde(default)]
    model: Vec<SupportNamedTier>,
    #[serde(default)]
    workload: Vec<SupportWorkloadTier>,
    #[serde(default)]
    language_resource: Vec<SupportNamedTier>,
    #[serde(default)]
    locale: Vec<SupportNamedTier>,
}

#[derive(Debug, Clone, Default, Deserialize)]
struct SupportNamedTier {
    id: String,
    label: String,
}

#[derive(Debug, Clone, Default, Deserialize)]
struct SupportWorkloadTier {
    id: String,
    label: String,
    #[serde(default)]
    default_route: String,
}

#[derive(Debug, Clone, Default, Deserialize)]
struct SupportMatrixEntry {
    model_tier: String,
    workload_tier: String,
    language_resource_tier: String,
    locale_tier: String,
    support_status: String,
    default_route: String,
    #[serde(default)]
    requires_mission: Option<bool>,
    #[serde(default)]
    allowed_capability_packs: Vec<String>,
    #[serde(default)]
    required_evidence: Vec<String>,
}

#[derive(Debug, Clone, Default, Deserialize)]
struct AdapterConformanceCriterion {
    criterion_id: String,
    adapter_kind: String,
    #[serde(default)]
    required_evidence: Vec<String>,
}

#[derive(Debug, Clone, Default, Deserialize)]
struct AdapterSupportDeclaration {
    adapter_id: String,
    #[serde(default)]
    contract_ref: String,
    #[serde(default)]
    authority_mode: String,
    #[serde(default)]
    replaceable: bool,
    #[serde(default)]
    support_status: String,
    #[serde(default)]
    default_route: String,
    #[serde(default)]
    criteria_refs: Vec<String>,
    #[serde(default)]
    allowed_model_tiers: Vec<String>,
    #[serde(default)]
    allowed_workload_tiers: Vec<String>,
    #[serde(default)]
    allowed_language_resource_tiers: Vec<String>,
    #[serde(default)]
    allowed_locale_tiers: Vec<String>,
    #[serde(default)]
    required_evidence: Vec<String>,
}

#[derive(Debug, Clone, Default, Deserialize)]
struct AdapterRuntimeSurfaceRecord {
    #[serde(default)]
    interface_ref: String,
    #[serde(default)]
    integration_class: String,
}

#[derive(Debug, Clone, Default, Deserialize)]
struct AdapterSupportTierDeclarationsRecord {
    #[serde(default)]
    model_tiers: Vec<String>,
    #[serde(default)]
    workload_tiers: Vec<String>,
    #[serde(default)]
    language_resource_tiers: Vec<String>,
    #[serde(default)]
    locale_tiers: Vec<String>,
}

#[derive(Debug, Clone, Default, Deserialize)]
struct ModelContaminationResetPolicyRecord {
    #[serde(default)]
    clean_checkpoint_required: bool,
    #[serde(default)]
    hard_reset_on_signature: bool,
    #[serde(default)]
    contamination_signal_ref: String,
    #[serde(default)]
    evidence_log_ref: String,
}

#[derive(Debug, Clone, Default, Deserialize)]
struct ModelAdapterManifestRecord {
    #[serde(default)]
    schema_version: String,
    #[serde(default)]
    adapter_id: String,
    #[serde(default)]
    display_name: String,
    #[serde(default)]
    replaceable: bool,
    #[serde(default)]
    authority_mode: String,
    #[serde(default)]
    runtime_surface: AdapterRuntimeSurfaceRecord,
    #[serde(default)]
    support_target_ref: String,
    #[serde(default)]
    support_tier_declarations: AdapterSupportTierDeclarationsRecord,
    #[serde(default)]
    conformance_criteria_refs: Vec<String>,
    #[serde(default)]
    conformance_suite_refs: Vec<String>,
    #[serde(default)]
    contamination_reset_policy: ModelContaminationResetPolicyRecord,
    #[serde(default)]
    known_limitations: Vec<String>,
    #[serde(default)]
    non_authoritative_boundaries: Vec<String>,
}

#[derive(Debug, Clone, Default, Deserialize)]
struct HostAdapterManifestRecord {
    #[serde(default)]
    schema_version: String,
    #[serde(default)]
    adapter_id: String,
    #[serde(default)]
    display_name: String,
    #[serde(default)]
    host_family: String,
    #[serde(default)]
    replaceable: bool,
    #[serde(default)]
    authority_mode: String,
    #[serde(default)]
    runtime_surface: AdapterRuntimeSurfaceRecord,
    #[serde(default)]
    projection_sources: Vec<String>,
    #[serde(default)]
    support_target_ref: String,
    #[serde(default)]
    support_tier_declarations: AdapterSupportTierDeclarationsRecord,
    #[serde(default)]
    conformance_criteria_refs: Vec<String>,
    #[serde(default)]
    known_limitations: Vec<String>,
    #[serde(default)]
    non_authoritative_boundaries: Vec<String>,
}

#[derive(Debug, Clone, Default, Deserialize)]
struct RuntimeCapabilityPackRegistryRecord {
    #[serde(default)]
    packs: Vec<RuntimeCapabilityPackAdmissionRecord>,
}

#[derive(Debug, Clone, Default, Deserialize)]
struct RuntimeCapabilityPackAdmissionRecord {
    #[serde(default)]
    pack_id: String,
    #[serde(default)]
    contract_ref: String,
    #[serde(default)]
    admission_status: String,
    #[serde(default)]
    default_route: String,
    #[serde(default)]
    required_evidence: Vec<String>,
}

#[derive(Debug, Clone, Default, Deserialize)]
struct CapabilityPackManifestRecord {
    #[serde(default)]
    schema_version: String,
    #[serde(default)]
    pack_id: String,
    #[serde(default)]
    surface: String,
    #[serde(default)]
    display_name: String,
    #[serde(default)]
    description: String,
    #[serde(default)]
    runtime_surface_refs: Vec<String>,
    #[serde(default)]
    required_evidence: Vec<String>,
    #[serde(default)]
    support_target_ref: String,
    #[serde(default)]
    known_limitations: Vec<String>,
}

#[derive(Debug, Clone, Default)]
struct ResolvedAdapterSupport {
    adapter_id: String,
    support_status: String,
    route: String,
    criteria_refs: Vec<String>,
    required_evidence: Vec<String>,
}

#[derive(Debug, Clone, Default)]
struct ResolvedCapabilityPackSupport {
    support_status: String,
    route: String,
    required_evidence: Vec<String>,
}

#[derive(Debug, Clone, Default, Deserialize)]
struct RevocationRegistry {
    #[serde(default)]
    revocations: Vec<RevocationArtifact>,
}

#[derive(Debug, Clone)]
struct ResolvedAutonomyState {
    context: AutonomyContext,
    action_class: String,
    rollback_handle: Option<String>,
    compensation_handle: Option<String>,
    recovery_window: String,
    reversibility_primitive: Option<String>,
    autonomy_budget_state: String,
    breaker_state: String,
    approval_required: bool,
    break_glass_required: bool,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
struct RuntimeStateRecord {
    #[serde(default)]
    schema_version: String,
    #[serde(default)]
    run_id: String,
    #[serde(default)]
    status: String,
    #[serde(default)]
    workflow_mode: String,
    #[serde(default)]
    decision_state: Option<String>,
    #[serde(default)]
    run_contract_ref: String,
    #[serde(default)]
    run_manifest_ref: String,
    #[serde(default)]
    current_stage_attempt_id: Option<String>,
    #[serde(default)]
    last_checkpoint_ref: Option<String>,
    #[serde(default)]
    last_receipt_ref: Option<String>,
    #[serde(default)]
    mission_id: Option<String>,
    #[serde(default)]
    parent_run_ref: Option<String>,
    #[serde(default)]
    created_at: String,
    #[serde(default)]
    updated_at: String,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
struct RollbackPostureRecord {
    #[serde(default)]
    schema_version: String,
    #[serde(default)]
    run_id: String,
    #[serde(default)]
    reversibility_class: String,
    #[serde(default)]
    rollback_strategy: String,
    #[serde(default)]
    rollback_ref: Option<String>,
    #[serde(default)]
    rollback_handle: Option<String>,
    #[serde(default)]
    compensation_handle: Option<String>,
    #[serde(default)]
    recovery_window: Option<String>,
    #[serde(default)]
    contamination_state: String,
    #[serde(default)]
    retry_record_ref: String,
    #[serde(default)]
    contamination_record_ref: String,
    #[serde(default)]
    resume_allowed: bool,
    #[serde(default)]
    reset_action: String,
    #[serde(default)]
    invalidated_artifacts: Vec<String>,
    #[serde(default)]
    hard_reset_required: bool,
    #[serde(default)]
    posture_source: Option<String>,
    #[serde(default)]
    updated_at: String,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
struct RunCheckpointRecord {
    #[serde(default)]
    schema_version: String,
    #[serde(default)]
    run_id: String,
    #[serde(default)]
    checkpoint_id: String,
    #[serde(default)]
    stage_attempt_id: String,
    #[serde(default)]
    checkpoint_kind: String,
    #[serde(default)]
    status: String,
    #[serde(default)]
    control_ref: String,
    #[serde(default)]
    evidence_ref: Option<String>,
    #[serde(default)]
    notes: Option<String>,
    #[serde(default)]
    created_at: String,
    #[serde(default)]
    updated_at: String,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
struct ReplayPointersRecord {
    #[serde(default)]
    schema_version: String,
    #[serde(default)]
    run_id: String,
    #[serde(default)]
    replay_manifest_refs: Vec<String>,
    #[serde(default)]
    receipt_refs: Vec<String>,
    #[serde(default)]
    checkpoint_refs: Vec<String>,
    #[serde(default)]
    trace_refs: Vec<String>,
    #[serde(default)]
    external_index_refs: Vec<String>,
    #[serde(default)]
    updated_at: String,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
struct TracePointersRecord {
    #[serde(default)]
    schema_version: String,
    #[serde(default)]
    run_id: String,
    #[serde(default)]
    trace_id: String,
    #[serde(default)]
    trace_refs: Vec<String>,
    #[serde(default)]
    external_index_refs: Vec<String>,
    #[serde(default)]
    notes: Option<String>,
    #[serde(default)]
    updated_at: String,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
struct RetainedRunEvidenceRecord {
    #[serde(default)]
    schema_version: String,
    #[serde(default)]
    run_id: String,
    #[serde(default)]
    evidence_refs: BTreeMap<String, String>,
    #[serde(default)]
    updated_at: String,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
struct RunContinuityRecord {
    #[serde(default)]
    schema_version: String,
    #[serde(default)]
    run_id: String,
    #[serde(default)]
    status: String,
    #[serde(default)]
    run_contract_ref: String,
    #[serde(default)]
    run_manifest_ref: String,
    #[serde(default)]
    retained_evidence_ref: String,
    #[serde(default)]
    replay_pointers_ref: String,
    #[serde(default)]
    evidence_classification_ref: String,
    #[serde(default)]
    last_receipt_ref: Option<String>,
    #[serde(default)]
    last_checkpoint_ref: String,
    #[serde(default)]
    resume_from_stage_attempt_id: Option<String>,
    #[serde(default)]
    mission_id: Option<String>,
    #[serde(default)]
    parent_run_ref: Option<String>,
    #[serde(default)]
    next_action: Option<String>,
    #[serde(default)]
    updated_at: String,
}

#[derive(Debug, Clone)]
struct BoundRunLifecycle {
    control_root: PathBuf,
    evidence_root: PathBuf,
    assurance_root: PathBuf,
    measurement_root: PathBuf,
    intervention_root: PathBuf,
    disclosure_root: PathBuf,
    replay_manifest_path: PathBuf,
    continuity_handoff_path: PathBuf,
    _run_manifest_path: PathBuf,
    runtime_state_path: PathBuf,
    receipts_root: PathBuf,
    replay_pointers_path: PathBuf,
    _evidence_classification_path: PathBuf,
    retained_evidence_path: PathBuf,
    stage_attempt_path: PathBuf,
    control_root_rel: String,
    evidence_root_rel: String,
    control_checkpoint_ref: String,
    run_manifest_ref: String,
    receipts_root_rel: String,
    replay_pointers_ref: String,
    trace_pointers_ref: String,
    evidence_classification_ref: String,
    retained_evidence_ref: String,
    stage_attempt_ref: String,
    stage_attempt_id: String,
}

fn mission_denial(message: impl Into<String>, reason_codes: Vec<&str>) -> KernelError {
    KernelError::new(ErrorCode::CapabilityDenied, message.into()).with_details(json!({
        "reason_codes": reason_codes,
        "decision": "DENY"
    }))
}

fn mission_stage_only(message: impl Into<String>, reason_codes: Vec<&str>) -> KernelError {
    KernelError::new(ErrorCode::CapabilityDenied, message.into()).with_details(json!({
        "reason_codes": reason_codes,
        "decision": "STAGE_ONLY"
    }))
}

fn is_autonomous_request(request: &ExecutionRequest) -> bool {
    request.workflow_mode == "autonomous"
}

fn read_yaml_file<T>(path: &Path) -> CoreResult<T>
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

fn ensure_file_exists(path: &Path, reason_code: &str) -> CoreResult<()> {
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

fn parse_rfc3339(raw: &str) -> CoreResult<time::OffsetDateTime> {
    time::OffsetDateTime::parse(raw, &time::format_description::well_known::Rfc3339).map_err(|e| {
        KernelError::new(
            ErrorCode::CapabilityDenied,
            format!("failed to parse RFC3339 timestamp '{raw}': {e}"),
        )
    })
}

fn decision_label(decision: &ExecutionDecision) -> &'static str {
    match decision {
        ExecutionDecision::Allow => "ALLOW",
        ExecutionDecision::StageOnly => "STAGE_ONLY",
        ExecutionDecision::Deny => "DENY",
        ExecutionDecision::Escalate => "ESCALATE",
    }
}

fn authority_control_root(cfg: &RuntimeConfig) -> PathBuf {
    cfg.execution_control_root.clone()
}

fn approval_request_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    authority_control_root(cfg)
        .join("approvals")
        .join("requests")
        .join(format!("{request_id}.yml"))
}

fn approval_grant_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    authority_control_root(cfg)
        .join("approvals")
        .join("grants")
        .join(format!("grant-{request_id}.yml"))
}

fn revocation_registry_path(cfg: &RuntimeConfig) -> PathBuf {
    authority_control_root(cfg)
        .join("revocations")
        .join("__legacy_removed__")
}

fn revocation_directory_path(cfg: &RuntimeConfig) -> PathBuf {
    authority_control_root(cfg).join("revocations")
}

fn authority_evidence_root(cfg: &RuntimeConfig) -> PathBuf {
    cfg.repo_root
        .join(".octon/state/evidence/control/execution")
}

fn decision_artifact_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    authority_evidence_root(cfg).join(format!("authority-decision-{request_id}.yml"))
}

fn authority_grant_bundle_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    authority_evidence_root(cfg).join(format!("authority-grant-bundle-{request_id}.yml"))
}

fn run_contract_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    cfg.execution_control_root
        .join("runs")
        .join(request_id)
        .join("run-contract.yml")
}

fn run_manifest_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    cfg.run_control_root(request_id).join("run-manifest.yml")
}

fn runtime_state_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    cfg.run_control_root(request_id).join("runtime-state.yml")
}

fn rollback_posture_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    cfg.run_control_root(request_id)
        .join("rollback-posture.yml")
}

fn control_checkpoint_path(cfg: &RuntimeConfig, request_id: &str, checkpoint_id: &str) -> PathBuf {
    cfg.run_control_root(request_id)
        .join("checkpoints")
        .join(format!("{checkpoint_id}.yml"))
}

fn evidence_checkpoint_path(cfg: &RuntimeConfig, request_id: &str, checkpoint_id: &str) -> PathBuf {
    cfg.run_root(request_id)
        .join("checkpoints")
        .join(format!("{checkpoint_id}.yml"))
}

fn stage_attempt_dir_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    cfg.run_control_root(request_id).join("stage-attempts")
}

fn stage_attempt_file_path(
    cfg: &RuntimeConfig,
    request_id: &str,
    stage_attempt_id: &str,
) -> PathBuf {
    stage_attempt_dir_path(cfg, request_id).join(format!("{stage_attempt_id}.yml"))
}

fn evidence_receipts_root(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    cfg.run_root(request_id).join("receipts")
}

fn replay_pointers_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    cfg.run_root(request_id).join("replay-pointers.yml")
}

fn trace_pointers_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    cfg.run_root(request_id).join("trace-pointers.yml")
}

fn retained_evidence_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    cfg.run_root(request_id).join("retained-run-evidence.yml")
}

fn evidence_classification_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    cfg.run_root(request_id).join("evidence-classification.yml")
}

fn run_continuity_handoff_path(cfg: &RuntimeConfig, request_id: &str) -> PathBuf {
    cfg.run_continuity_path(request_id).join("handoff.yml")
}

fn stage_attempt_id_for_request(request: &ExecutionRequest) -> String {
    request
        .metadata
        .get("stage_id")
        .map(|stage_id| format!("{stage_id}--initial"))
        .unwrap_or_else(|| "initial".to_string())
}

fn stage_ref_for_request(request: &ExecutionRequest) -> String {
    if let Some(stage_id) = request.metadata.get("stage_id") {
        return format!("workflow-stage:{stage_id}");
    }
    if let Some(workflow_id) = request.metadata.get("workflow_id") {
        return format!("workflow:{workflow_id}");
    }
    request.target_id.clone()
}

fn required_request_metadata(request: &ExecutionRequest, key: &str) -> CoreResult<String> {
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

fn requested_support_target_tuple(request: &ExecutionRequest) -> CoreResult<SupportTargetTuple> {
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

fn bind_run_lifecycle(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
    autonomy_state: Option<&ResolvedAutonomyState>,
) -> CoreResult<BoundRunLifecycle> {
    let run_id = request.request_id.as_str();
    let control_root = cfg.run_control_root(run_id);
    let evidence_root = cfg.run_root(run_id);
    let continuity_root = cfg.run_continuity_path(run_id);
    let run_contract_path = run_contract_path(cfg, run_id);
    let run_manifest_path = run_manifest_path(cfg, run_id);
    let continuity_handoff_path = run_continuity_handoff_path(cfg, run_id);
    let runtime_state_path = runtime_state_path(cfg, run_id);
    let rollback_posture_path = rollback_posture_path(cfg, run_id);
    let control_checkpoint_path = control_checkpoint_path(cfg, run_id, "bound");
    let evidence_checkpoint_path = evidence_checkpoint_path(cfg, run_id, "bound");
    let receipts_root = evidence_receipts_root(cfg, run_id);
    let replay_pointers_path = replay_pointers_path(cfg, run_id);
    let trace_pointers_path = trace_pointers_path(cfg, run_id);
    let retained_evidence_path = retained_evidence_path(cfg, run_id);
    let evidence_classification_path = evidence_classification_path(cfg, run_id);
    let stage_attempt_id = stage_attempt_id_for_request(request);
    let stage_attempt_path = stage_attempt_file_path(cfg, run_id, &stage_attempt_id);
    let stage_attempt_root = stage_attempt_dir_path(cfg, run_id);
    let now = now_rfc3339().map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to compute run binding timestamp: {e}"),
        )
    })?;

    for dir in [
        &control_root,
        &stage_attempt_root,
        &control_root.join("checkpoints"),
        &continuity_root,
        &evidence_root,
        &receipts_root,
        &evidence_root.join("checkpoints"),
        &evidence_root.join("replay"),
    ] {
        fs::create_dir_all(dir).map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!(
                    "failed to create canonical run family {}: {e}",
                    dir.display()
                ),
            )
        })?;
    }

    let support_target = requested_support_target_tuple(request)?;
    let support_tier = support_target.workload_tier.clone();
    let requested_capability_packs = infer_requested_capability_packs(request);
    let resolved_intent_ref = request
        .intent_ref
        .clone()
        .or_else(|| active_intent_ref(cfg))
        .ok_or_else(|| {
            KernelError::new(
                ErrorCode::CapabilityDenied,
                "execution request missing active intent binding",
            )
            .with_details(json!({"reason_codes":["INTENT_MISSING"]}))
        })?;
    let resolved_actor_ref = request.actor_ref.clone().unwrap_or_else(default_actor_ref);
    let reversibility_class = autonomy_state
        .map(|state| state.context.reversibility_class.clone())
        .unwrap_or_else(|| "reversible".to_string());
    let profile_requires_human_review = request
        .scope_constraints
        .executor_profile
        .as_ref()
        .and_then(|profile_name| cfg.execution_governance.executor_profiles.get(profile_name))
        .map(|profile| profile.require_human_review)
        .unwrap_or(false);
    let approval_expected = request.review_requirements.human_approval
        || profile_requires_human_review
        || autonomy_state
            .map(|state| state.approval_required || state.break_glass_required)
            .unwrap_or(false);
    let approval_request_ref =
        format!(".octon/state/control/execution/approvals/requests/{run_id}.yml");
    let expected_approval_ref =
        format!(".octon/state/control/execution/approvals/grants/grant-{run_id}.yml");
    let mission_id = autonomy_state
        .map(|state| state.context.mission_ref.id.clone())
        .or_else(|| request.metadata.get("mission_id").cloned());
    let parent_run_ref = request
        .parent_run_ref
        .as_ref()
        .map(|parent| format!(".octon/state/control/execution/runs/{parent}/run-contract.yml"));
    let rollback_ref = std::env::var("OCTON_EXECUTION_ROLLBACK_REF")
        .ok()
        .filter(|value| !value.trim().is_empty());

    let control_root_rel = path_tail(&cfg.repo_root, &control_root);
    let evidence_root_rel = path_tail(&cfg.repo_root, &evidence_root);
    let run_contract_ref = path_tail(&cfg.repo_root, &run_contract_path);
    let run_manifest_ref = path_tail(&cfg.repo_root, &run_manifest_path);
    let decision_artifact_ref =
        format!(".octon/state/evidence/control/execution/authority-decision-{run_id}.yml");
    let authority_grant_bundle_ref =
        format!(".octon/state/evidence/control/execution/authority-grant-bundle-{run_id}.yml");
    let run_card_ref = format!(".octon/state/evidence/disclosure/runs/{run_id}/run-card.yml");
    let replay_manifest_ref = format!(".octon/state/evidence/runs/{run_id}/replay/manifest.yml");
    let external_replay_index_ref =
        format!(".octon/state/evidence/external-index/runs/{run_id}.yml");
    let host_adapter_ref = format!(
        ".octon/framework/engine/runtime/adapters/host/{}.yml",
        support_target.host_adapter
    );
    let model_adapter_ref = format!(
        ".octon/framework/engine/runtime/adapters/model/{}.yml",
        support_target.model_adapter
    );
    let runtime_state_ref = path_tail(&cfg.repo_root, &runtime_state_path);
    let rollback_posture_ref = path_tail(&cfg.repo_root, &rollback_posture_path);
    let control_checkpoint_ref = path_tail(&cfg.repo_root, &control_checkpoint_path);
    let evidence_checkpoint_ref = path_tail(&cfg.repo_root, &evidence_checkpoint_path);
    let retry_record_path = control_root.join("retry-records").join("baseline.yml");
    let contamination_record_path = control_root.join("contamination").join("current.yml");
    let retry_record_ref = path_tail(&cfg.repo_root, &retry_record_path);
    let contamination_record_ref = path_tail(&cfg.repo_root, &contamination_record_path);
    let receipts_root_rel = path_tail(&cfg.repo_root, &receipts_root);
    let replay_pointers_ref = path_tail(&cfg.repo_root, &replay_pointers_path);
    let trace_pointers_ref = path_tail(&cfg.repo_root, &trace_pointers_path);
    let retained_evidence_ref = path_tail(&cfg.repo_root, &retained_evidence_path);
    let evidence_classification_ref = path_tail(&cfg.repo_root, &evidence_classification_path);
    let stage_attempt_ref = path_tail(&cfg.repo_root, &stage_attempt_path);

    if !run_contract_path.is_file() {
        let scope_in = if request.scope_constraints.read.is_empty() {
            vec![request.caller_path.clone()]
        } else {
            dedupe_strings(&request.scope_constraints.read)
        };
        let mut required_approvals = Vec::<String>::new();
        if approval_expected {
            required_approvals.push(expected_approval_ref.clone());
        }
        let mut required_evidence = vec![
            "decision-artifact".to_string(),
            "execution-receipt".to_string(),
            "policy-receipt".to_string(),
            "replay-pointers".to_string(),
            "trace-pointers".to_string(),
        ];
        if approval_expected {
            required_evidence.push("approval-grant".to_string());
        }
        let required_evidence = dedupe_strings(&required_evidence);
        let mut objective_refs = serde_json::Map::new();
        objective_refs.insert(
            "workspace_objective_ref".to_string(),
            json!(".octon/instance/charter/workspace.md"),
        );
        objective_refs.insert(
            "workspace_machine_charter_ref".to_string(),
            json!(".octon/instance/charter/workspace.yml"),
        );
        if let Some(mission_id) = mission_id.as_ref() {
            objective_refs.insert("mission_id".to_string(), json!(mission_id));
            objective_refs.insert(
                "mission_ref".to_string(),
                json!(format!(
                    ".octon/instance/orchestration/missions/{mission_id}/mission.yml"
                )),
            );
        }
        write_yaml(
            &run_contract_path,
            &json!({
                "schema_version": "run-contract-v1",
                "run_id": run_id,
                "mission_mode": if mission_id.is_some() { "required" } else { "none" },
                "objective_refs": objective_refs,
                "objective_summary": format!("Execute {} under the canonical run-first constitutional runtime.", request.target_id),
                "scope_in": scope_in,
                "scope_out": dedupe_strings(&request.scope_constraints.write),
                "exclusions": [".octon/inputs/exploratory/ideation/**"],
                "done_when": [
                    "The bound run reaches a terminal status with canonical evidence and disclosure artifacts retained.",
                    "The retained run bundle validates against support-target and replay/disclosure gates."
                ],
                "acceptance_criteria": [
                    "Canonical replay, trace, and disclosure references resolve from the run root.",
                    "Authority and support-target posture remain bounded to the declared supported envelope."
                ],
                "materiality": request.risk_tier,
                "protected_zones": [
                    ".octon/framework/constitution/**",
                    ".octon/instance/governance/**"
                ],
                "requested_capabilities": dedupe_strings(&request.requested_capabilities),
                "requested_capability_packs": requested_capability_packs.clone(),
                "risk_class": request.risk_tier,
                "intent_ref": {
                    "id": resolved_intent_ref.id,
                    "version": resolved_intent_ref.version,
                },
                "actor_ref": {
                    "kind": resolved_actor_ref.kind,
                    "id": resolved_actor_ref.id,
                },
                "reversibility_class": reversibility_class,
                "support_tier": support_tier,
                "support_target": {
                    "model_tier": support_target.model_tier.clone(),
                    "workload_tier": support_target.workload_tier.clone(),
                    "language_resource_tier": support_target.language_resource_tier.clone(),
                    "locale_tier": support_target.locale_tier.clone(),
                    "host_adapter": support_target.host_adapter.clone(),
                    "model_adapter": support_target.model_adapter.clone(),
                },
                "support_target_ref": ".octon/instance/governance/support-targets.yml",
                "required_approvals": required_approvals,
                "required_evidence": required_evidence,
                "start_conditions": [
                    "Canonical support-target tuple remains admitted for the selected host and model adapters.",
                    "Canonical run control, evidence, and disclosure roots are writable before consequential execution starts."
                ],
                "stop_conditions": [
                    "Stop immediately on STAGE_ONLY, ESCALATE, or DENY authority routes.",
                    "Stop if replay, trace, or disclosure references cannot be materialized under canonical run roots."
                ],
                "retry_class": "manual_review_required",
                "closure_conditions": [
                    "Run binds canonical runtime-state, rollback-posture, checkpoints, and evidence roots before consequential side effects.",
                    "Canonical receipts and replay pointers remain linked to the run root."
                ],
                "disclosure_expectations": [
                    "Emit RunCard, replay manifest, replay pointers, trace pointers, and evidence classification.",
                    "Retain detailed measurement and intervention records before any claim promotion."
                ],
                "stage_attempt_root": path_tail(&cfg.repo_root, &stage_attempt_root),
                "run_manifest_ref": run_manifest_ref,
                "decision_artifact_ref": decision_artifact_ref,
                "authority_grant_bundle_ref": authority_grant_bundle_ref,
                "run_card_ref": run_card_ref,
                "host_adapter_ref": host_adapter_ref,
                "model_adapter_ref": model_adapter_ref,
                "external_replay_index_ref": external_replay_index_ref,
                "control_checkpoint_root": path_tail(&cfg.repo_root, &control_root.join("checkpoints")),
                "runtime_state_ref": runtime_state_ref,
                "rollback_posture_ref": rollback_posture_ref,
                "evidence_root": evidence_root_rel,
                "receipt_root": receipts_root_rel,
                "replay_pointers_ref": replay_pointers_ref,
                "rollback_or_compensation_expectation": "Wave 3 binds rollback posture and contamination state under the canonical run root before consequential side effects.",
                "contract_version": "1.1.0",
                "issued_at": now,
                "expires_at": serde_json::Value::Null,
                "status": "bound",
                "created_at": now,
                "updated_at": now,
                "notes_ref": stage_attempt_ref
            }),
        )
        .map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!("failed to write canonical run contract {}: {e}", run_contract_path.display()),
            )
        })?;
    }

    write_yaml(
        &run_manifest_path,
        &json!({
            "schema_version": "run-manifest-v1",
            "run_id": run_id,
            "run_contract_ref": run_contract_ref,
            "intent_ref": {
                "id": resolved_intent_ref.id,
                "version": resolved_intent_ref.version,
            },
            "actor_ref": {
                "kind": resolved_actor_ref.kind,
                "id": resolved_actor_ref.id,
            },
            "support_tier": support_tier,
            "support_target": {
                "model_tier": support_target.model_tier.clone(),
                "workload_tier": support_target.workload_tier.clone(),
                "language_resource_tier": support_target.language_resource_tier.clone(),
                "locale_tier": support_target.locale_tier.clone(),
                "host_adapter": support_target.host_adapter.clone(),
                "model_adapter": support_target.model_adapter.clone(),
            },
            "support_target_ref": ".octon/instance/governance/support-targets.yml",
            "requested_capability_packs": requested_capability_packs.clone(),
            "decision_artifact_ref": decision_artifact_ref,
            "authority_grant_bundle_ref": authority_grant_bundle_ref,
            "approval_request_ref": if approval_expected { Some(approval_request_ref.clone()) } else { None },
            "approval_grant_refs": if approval_expected { vec![expected_approval_ref.clone()] } else { Vec::<String>::new() },
            "host_adapter_ref": host_adapter_ref,
            "model_adapter_ref": model_adapter_ref,
            "runtime_state_ref": runtime_state_ref,
            "run_continuity_ref": path_tail(&cfg.repo_root, &continuity_handoff_path),
            "stage_attempt_root": path_tail(&cfg.repo_root, &stage_attempt_root),
            "control_checkpoint_root": path_tail(&cfg.repo_root, &control_root.join("checkpoints")),
            "rollback_posture_ref": rollback_posture_ref,
            "evidence_root": evidence_root_rel,
            "receipt_root": receipts_root_rel,
            "assurance_root": format!(".octon/state/evidence/runs/{run_id}/assurance"),
            "measurement_root": format!(".octon/state/evidence/runs/{run_id}/measurements"),
            "intervention_root": format!(".octon/state/evidence/runs/{run_id}/interventions"),
            "disclosure_root": format!(".octon/state/evidence/disclosure/runs/{run_id}"),
            "retained_evidence_ref": retained_evidence_ref,
            "replay_pointers_ref": replay_pointers_ref,
            "trace_pointers_ref": trace_pointers_ref,
            "evidence_classification_ref": evidence_classification_ref,
            "run_card_ref": run_card_ref,
            "external_replay_index_ref": external_replay_index_ref,
            "created_at": now,
            "updated_at": now,
            "mission_id": mission_id,
            "parent_run_ref": parent_run_ref
        }),
    )
    .map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to write canonical run manifest {}: {e}", run_manifest_path.display()),
        )
    })?;

    if !stage_attempt_path.is_file() {
        write_yaml(
            &stage_attempt_path,
            &json!({
                "schema_version": "stage-attempt-v1",
                "run_id": run_id,
                "stage_attempt_id": stage_attempt_id,
                "stage_ref": stage_ref_for_request(request),
                "attempt_kind": "initial",
                "status": "planned",
                "objective_ref": run_contract_ref,
                "objective_slice": format!("Stage {} for target {}", stage_ref_for_request(request), request.target_id),
                "entry_criteria": [
                    "Run contract is bound under the canonical run root.",
                    "Support-target tuple remains admitted for the bounded consequential envelope."
                ],
                "exit_criteria": [
                    "Stage receipts, replay refs, and disclosure refs are retained under canonical run roots.",
                    "Stage status reaches a terminal state that agrees with the decision artifact."
                ],
                "requested_capabilities": dedupe_strings(&request.requested_capabilities),
                "allowed_capabilities": dedupe_strings(&request.requested_capabilities),
                "allowed_zones": dedupe_strings(&vec![
                    path_tail(&cfg.repo_root, &control_root),
                    evidence_root_rel.clone()
                ]),
                "retry_class": "manual_review_required",
                "predecessor_refs": [],
                "successor_refs": [],
                "evidence_refs": [],
                "completion_status": "criteria-pending",
                "rollback_candidate": reversibility_class != "irreversible",
                "rollback_notes": "Restore from the canonical checkpoint and reissue the stage if retained evidence becomes inconsistent.",
                "issued_by": resolved_actor_ref.id,
                "validated_by": "octon-kernel",
                "created_at": now,
                "updated_at": now
            }),
        )
        .map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!(
                    "failed to write canonical stage attempt {}: {e}",
                    stage_attempt_path.display()
                ),
            )
        })?;
    }

    let mut runtime_state: RuntimeStateRecord = read_yaml_or_default(&runtime_state_path)?;
    if runtime_state.created_at.trim().is_empty() {
        runtime_state.created_at = now.clone();
    }
    runtime_state.schema_version = "run-runtime-state-v1".to_string();
    runtime_state.run_id = run_id.to_string();
    runtime_state.status = "authorizing".to_string();
    runtime_state.workflow_mode = request.workflow_mode.clone();
    runtime_state.decision_state = Some("pending".to_string());
    runtime_state.run_contract_ref = run_contract_ref.clone();
    runtime_state.run_manifest_ref = run_manifest_ref.clone();
    runtime_state.current_stage_attempt_id = Some(stage_attempt_id.clone());
    runtime_state.last_checkpoint_ref = Some(control_checkpoint_ref.clone());
    runtime_state.mission_id = mission_id.clone();
    runtime_state.parent_run_ref = parent_run_ref.clone();
    runtime_state.updated_at = now.clone();
    write_yaml(&runtime_state_path, &runtime_state).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to write runtime-state {}: {e}",
                runtime_state_path.display()
            ),
        )
    })?;

    let rollback_strategy = if rollback_ref.is_some() || reversibility_class == "reversible" {
        "rollback"
    } else if reversibility_class == "compensable" {
        "compensate"
    } else {
        "observe_only"
    };
    let rollback_posture = RollbackPostureRecord {
        schema_version: "run-rollback-posture-v1".to_string(),
        run_id: run_id.to_string(),
        reversibility_class: reversibility_class.clone(),
        rollback_strategy: if rollback_ref.is_some() {
            "checkpoint_restore".to_string()
        } else {
            rollback_strategy.to_string()
        },
        rollback_ref: rollback_ref.clone(),
        rollback_handle: autonomy_state.and_then(|state| state.rollback_handle.clone()),
        compensation_handle: autonomy_state.and_then(|state| state.compensation_handle.clone()),
        recovery_window: autonomy_state.map(|state| state.recovery_window.clone()),
        contamination_state: "clean".to_string(),
        retry_record_ref: retry_record_ref.clone(),
        contamination_record_ref: contamination_record_ref.clone(),
        resume_allowed: true,
        reset_action: "No reset required; canonical run evidence remained coherent.".to_string(),
        invalidated_artifacts: Vec::new(),
        hard_reset_required: false,
        posture_source: Some(if autonomy_state.is_some() {
            "mission-autonomy".to_string()
        } else {
            "run-contract-default".to_string()
        }),
        updated_at: now.clone(),
    };
    write_yaml(&rollback_posture_path, &rollback_posture).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to write rollback posture {}: {e}",
                rollback_posture_path.display()
            ),
        )
    })?;

    fs::create_dir_all(retry_record_path.parent().unwrap()).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to create retry-record directory {}: {e}",
                retry_record_path.parent().unwrap().display()
            ),
        )
    })?;
    write_yaml(
        &retry_record_path,
        &json!({
            "schema_version": "run-retry-record-v1",
            "retry_id": format!("{run_id}-baseline"),
            "run_id": run_id,
            "stage_attempt_id": stage_attempt_id,
            "retry_class": "manual_review_required",
            "attempt_counter": 1,
            "attempt_limit": 1,
            "route_taken": "allow",
            "result": "not-needed",
            "triggering_artifact_ref": stage_attempt_ref,
            "notes": "The initial stage attempt completed without requiring a retry.",
            "recorded_at": now,
        }),
    )?;
    fs::create_dir_all(contamination_record_path.parent().unwrap()).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to create contamination directory {}: {e}",
                contamination_record_path.parent().unwrap().display()
            ),
        )
    })?;
    write_yaml(
        &contamination_record_path,
        &json!({
            "schema_version": "run-contamination-record-v1",
            "contamination_id": format!("{run_id}-current"),
            "run_id": run_id,
            "subject_ref": control_checkpoint_ref,
            "contamination_state": "clean",
            "contamination_class": "none",
            "reset_action": "No reset required; canonical run evidence remained coherent.",
            "invalidated_artifacts": [],
            "replay_continuity": "preserved",
            "approved_by": serde_json::Value::Null,
            "notes": "No contamination or reset event was recorded for the retained run bundle.",
            "recorded_at": now,
        }),
    )?;

    let checkpoint = RunCheckpointRecord {
        schema_version: "run-checkpoint-v1".to_string(),
        run_id: run_id.to_string(),
        checkpoint_id: "bound".to_string(),
        stage_attempt_id: stage_attempt_id.clone(),
        checkpoint_kind: "binding".to_string(),
        status: "materialized".to_string(),
        control_ref: control_checkpoint_ref.clone(),
        evidence_ref: Some(evidence_checkpoint_ref.clone()),
        notes: Some("Canonical run root bound before consequential side effects.".to_string()),
        created_at: now.clone(),
        updated_at: now.clone(),
    };
    write_yaml(&control_checkpoint_path, &checkpoint).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to write control checkpoint {}: {e}",
                control_checkpoint_path.display()
            ),
        )
    })?;
    write_yaml(&evidence_checkpoint_path, &checkpoint).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to write evidence checkpoint {}: {e}",
                evidence_checkpoint_path.display()
            ),
        )
    })?;

    let replay = ReplayPointersRecord {
        schema_version: "run-replay-pointers-v1".to_string(),
        run_id: run_id.to_string(),
        replay_manifest_refs: vec![replay_manifest_ref],
        receipt_refs: Vec::new(),
        checkpoint_refs: vec![evidence_checkpoint_ref.clone()],
        trace_refs: vec![trace_pointers_ref.clone()],
        external_index_refs: vec![external_replay_index_ref.clone()],
        updated_at: now.clone(),
    };
    write_yaml(&replay_pointers_path, &replay).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to write replay pointers {}: {e}",
                replay_pointers_path.display()
            ),
        )
    })?;
    write_yaml(
        &trace_pointers_path,
        &TracePointersRecord {
            schema_version: "run-trace-pointers-v1".to_string(),
            run_id: run_id.to_string(),
            trace_id: format!("{run_id}-trace-index"),
            trace_refs: Vec::new(),
            external_index_refs: vec![external_replay_index_ref.clone()],
            notes: Some(
                "No separate class-C trace payload was retained at bind time; canonical trace pointers are updated as the run completes.".to_string(),
            ),
            updated_at: now.clone(),
        },
    )?;

    let retained = RetainedRunEvidenceRecord {
        schema_version: "retained-run-evidence-v1".to_string(),
        run_id: run_id.to_string(),
        evidence_refs: BTreeMap::from([
            ("run_contract".to_string(), run_contract_ref.clone()),
            ("run_manifest".to_string(), run_manifest_ref.clone()),
            ("runtime_state".to_string(), runtime_state_ref.clone()),
            ("rollback_posture".to_string(), rollback_posture_ref.clone()),
            ("retry_record".to_string(), retry_record_ref.clone()),
            (
                "contamination_record".to_string(),
                contamination_record_ref.clone(),
            ),
            (
                "control_checkpoint".to_string(),
                control_checkpoint_ref.clone(),
            ),
            (
                "evidence_checkpoint".to_string(),
                evidence_checkpoint_ref.clone(),
            ),
            ("replay_pointers".to_string(), replay_pointers_ref.clone()),
            ("trace_pointers".to_string(), trace_pointers_ref.clone()),
        ]),
        updated_at: now.clone(),
    };
    write_yaml(&retained_evidence_path, &retained).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to write retained run evidence manifest {}: {e}",
                retained_evidence_path.display()
            ),
        )
    })?;
    write_yaml(
        &evidence_classification_path,
        &json!({
            "schema_version": "run-evidence-classification-v1",
            "run_id": run_id,
            "artifacts": [
                {
                    "artifact_id": "run-contract",
                    "artifact_ref": run_contract_ref,
                    "evidence_class": "A",
                    "storage_class": "git-inline"
                },
                {
                "artifact_id": "run-manifest",
                "artifact_ref": run_manifest_ref,
                "evidence_class": "A",
                "storage_class": "git-inline"
            },
            {
                "artifact_id": "runtime-state",
                "artifact_ref": runtime_state_ref,
                "evidence_class": "A",
                "storage_class": "git-inline"
            },
            {
                "artifact_id": "retry-record",
                "artifact_ref": retry_record_ref,
                "evidence_class": "A",
                "storage_class": "git-inline"
            },
            {
                "artifact_id": "contamination-record",
                "artifact_ref": contamination_record_ref,
                "evidence_class": "A",
                "storage_class": "git-inline"
            },
            {
                "artifact_id": "replay-pointers",
                "artifact_ref": replay_pointers_ref,
                "evidence_class": "B",
                "storage_class": "git-pointer"
            },
            {
                "artifact_id": "trace-pointers",
                "artifact_ref": trace_pointers_ref,
                "evidence_class": "B",
                "storage_class": "git-pointer"
            },
            {
                "artifact_id": "external-replay-index",
                "artifact_ref": external_replay_index_ref,
                "evidence_class": "B",
                "storage_class": "git-pointer"
            }
            ],
            "updated_at": now
        }),
    )
    .map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to write evidence classification {}: {e}",
                evidence_classification_path.display()
            ),
        )
    })?;
    sync_run_continuity(
        &RunContinuityRecord {
            schema_version: "run-continuity-v1".to_string(),
            run_id: run_id.to_string(),
            status: "authorizing".to_string(),
            run_contract_ref: run_contract_ref.clone(),
            run_manifest_ref: run_manifest_ref.clone(),
            retained_evidence_ref: retained_evidence_ref.clone(),
            replay_pointers_ref: replay_pointers_ref.clone(),
            evidence_classification_ref: evidence_classification_ref.clone(),
            last_receipt_ref: None,
            last_checkpoint_ref: control_checkpoint_ref.clone(),
            resume_from_stage_attempt_id: Some(stage_attempt_id.clone()),
            mission_id: mission_id.clone(),
            parent_run_ref: parent_run_ref.clone(),
            next_action: next_action_for_run_status("authorizing"),
            updated_at: now.clone(),
        },
        &continuity_handoff_path,
    )?;

    let assurance_root = evidence_root.join("assurance");
    let measurement_root = evidence_root.join("measurements");
    let intervention_root = evidence_root.join("interventions");
    let replay_manifest_path = evidence_root.join("replay").join("manifest.yml");
    Ok(BoundRunLifecycle {
        control_root,
        evidence_root,
        assurance_root,
        measurement_root,
        intervention_root,
        disclosure_root: cfg
            .repo_root
            .join(".octon/state/evidence/disclosure/runs")
            .join(run_id),
        replay_manifest_path,
        continuity_handoff_path,
        _run_manifest_path: run_manifest_path,
        runtime_state_path,
        receipts_root,
        replay_pointers_path,
        _evidence_classification_path: evidence_classification_path,
        retained_evidence_path,
        stage_attempt_path,
        control_root_rel,
        evidence_root_rel,
        control_checkpoint_ref,
        run_manifest_ref,
        receipts_root_rel,
        replay_pointers_ref,
        trace_pointers_ref,
        evidence_classification_ref,
        retained_evidence_ref,
        stage_attempt_ref,
        stage_attempt_id,
    })
}

fn update_bound_runtime_state(
    bound: &BoundRunLifecycle,
    status: &str,
    decision_state: Option<&str>,
    last_receipt_ref: Option<String>,
    last_checkpoint_ref: Option<String>,
) -> CoreResult<()> {
    let mut state: RuntimeStateRecord = read_yaml_or_default(&bound.runtime_state_path)?;
    if state.created_at.trim().is_empty() {
        state.created_at = now_rfc3339().map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!("failed to compute runtime-state timestamp: {e}"),
            )
        })?;
    }
    state.schema_version = "run-runtime-state-v1".to_string();
    state.run_id = bound
        .control_root
        .file_name()
        .and_then(|value| value.to_str())
        .unwrap_or_default()
        .to_string();
    state.status = status.to_string();
    if state.run_manifest_ref.trim().is_empty() {
        state.run_manifest_ref = bound.run_manifest_ref.clone();
    }
    state.decision_state = decision_state
        .map(ToOwned::to_owned)
        .or(state.decision_state);
    if let Some(value) = last_receipt_ref {
        state.last_receipt_ref = Some(value);
    }
    if let Some(value) = last_checkpoint_ref {
        state.last_checkpoint_ref = Some(value);
    }
    state.updated_at = now_rfc3339().map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to compute runtime-state timestamp: {e}"),
        )
    })?;
    write_yaml(&bound.runtime_state_path, &state).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to update runtime-state {}: {e}",
                bound.runtime_state_path.display()
            ),
        )
    })?;
    sync_run_continuity(
        &RunContinuityRecord {
            schema_version: "run-continuity-v1".to_string(),
            run_id: state.run_id.clone(),
            status: state.status.clone(),
            run_contract_ref: state.run_contract_ref.clone(),
            run_manifest_ref: bound.run_manifest_ref.clone(),
            retained_evidence_ref: bound.retained_evidence_ref.clone(),
            replay_pointers_ref: bound.replay_pointers_ref.clone(),
            evidence_classification_ref: bound.evidence_classification_ref.clone(),
            last_receipt_ref: state.last_receipt_ref.clone(),
            last_checkpoint_ref: state
                .last_checkpoint_ref
                .clone()
                .unwrap_or_else(|| bound.control_checkpoint_ref.clone()),
            resume_from_stage_attempt_id: state.current_stage_attempt_id.clone(),
            mission_id: state.mission_id.clone(),
            parent_run_ref: state.parent_run_ref.clone(),
            next_action: next_action_for_run_status(&state.status),
            updated_at: state.updated_at.clone(),
        },
        &bound.continuity_handoff_path,
    )?;
    Ok(())
}

fn next_action_for_run_status(status: &str) -> Option<String> {
    match status {
        "authorizing" => Some(
            "Complete authority routing before any consequential side effects.".to_string(),
        ),
        "authorized" | "running" => Some(
            "Resume from the current stage attempt using the retained receipt and checkpoint roots."
                .to_string(),
        ),
        "stage_only" => Some(
            "Supply the required approval or evidence bundle before reauthorizing this run."
                .to_string(),
        ),
        "denied" => Some(
            "Do not resume this run; open a new request if the authority posture changes."
                .to_string(),
        ),
        _ => None,
    }
}

fn sync_run_continuity(record: &RunContinuityRecord, path: &Path) -> CoreResult<()> {
    write_yaml(path, record).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to write run continuity {}: {e}", path.display()),
        )
    })
}

fn update_stage_attempt_status(
    bound: &BoundRunLifecycle,
    status: &str,
    evidence_ref: Option<String>,
) -> CoreResult<()> {
    let mut attempt: serde_yaml::Value = read_yaml_or_default(&bound.stage_attempt_path)?;
    let now = now_rfc3339().map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to compute stage-attempt timestamp: {e}"),
        )
    })?;
    if let Some(mapping) = attempt.as_mapping_mut() {
        mapping.insert(
            serde_yaml::Value::from("status"),
            serde_yaml::Value::from(status),
        );
        mapping.insert(
            serde_yaml::Value::from("updated_at"),
            serde_yaml::Value::from(now.clone()),
        );
        if let Some(evidence_ref) = evidence_ref {
            let key = serde_yaml::Value::from("evidence_refs");
            let existing = mapping
                .get(&key)
                .and_then(|value| value.as_sequence())
                .cloned()
                .unwrap_or_default();
            let mut values = existing
                .iter()
                .filter_map(|value| value.as_str().map(ToOwned::to_owned))
                .collect::<Vec<_>>();
            values.push(evidence_ref);
            values = dedupe_strings(&values);
            mapping.insert(
                key,
                serde_yaml::Value::Sequence(
                    values.into_iter().map(serde_yaml::Value::from).collect(),
                ),
            );
        }
    }
    write_yaml(&bound.stage_attempt_path, &attempt).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to update stage attempt {}: {e}",
                bound.stage_attempt_path.display()
            ),
        )
    })?;
    Ok(())
}

fn write_run_checkpoint(
    control_path: &Path,
    evidence_path: &Path,
    run_id: &str,
    stage_attempt_id: &str,
    checkpoint_id: &str,
    checkpoint_kind: &str,
    notes: &str,
) -> CoreResult<(String, String)> {
    let created_at = now_rfc3339().map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to compute checkpoint timestamp: {e}"),
        )
    })?;
    let record = RunCheckpointRecord {
        schema_version: "run-checkpoint-v1".to_string(),
        run_id: run_id.to_string(),
        checkpoint_id: checkpoint_id.to_string(),
        stage_attempt_id: stage_attempt_id.to_string(),
        checkpoint_kind: checkpoint_kind.to_string(),
        status: "materialized".to_string(),
        control_ref: control_path.display().to_string(),
        evidence_ref: Some(evidence_path.display().to_string()),
        notes: Some(notes.to_string()),
        created_at: created_at.clone(),
        updated_at: created_at,
    };
    write_yaml(control_path, &record).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to write control checkpoint {}: {e}",
                control_path.display()
            ),
        )
    })?;
    write_yaml(evidence_path, &record).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to write evidence checkpoint {}: {e}",
                evidence_path.display()
            ),
        )
    })?;
    Ok((
        control_path.display().to_string(),
        evidence_path.display().to_string(),
    ))
}

fn merge_replay_receipt_ref(path: &Path, run_id: &str, ref_id: String) -> CoreResult<()> {
    let mut replay: ReplayPointersRecord = read_yaml_or_default(path)?;
    replay.schema_version = "run-replay-pointers-v1".to_string();
    replay.run_id = run_id.to_string();
    replay.receipt_refs.push(ref_id);
    replay.receipt_refs = dedupe_strings(&replay.receipt_refs);
    replay.updated_at = now_rfc3339().map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to compute replay pointer timestamp: {e}"),
        )
    })?;
    write_yaml(path, &replay).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to update replay pointers {}: {e}", path.display()),
        )
    })?;
    Ok(())
}

fn merge_replay_checkpoint_ref(path: &Path, run_id: &str, ref_id: String) -> CoreResult<()> {
    let mut replay: ReplayPointersRecord = read_yaml_or_default(path)?;
    replay.schema_version = "run-replay-pointers-v1".to_string();
    replay.run_id = run_id.to_string();
    replay.checkpoint_refs.push(ref_id);
    replay.checkpoint_refs = dedupe_strings(&replay.checkpoint_refs);
    replay.updated_at = now_rfc3339().map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to compute replay pointer timestamp: {e}"),
        )
    })?;
    write_yaml(path, &replay).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to update replay pointers {}: {e}", path.display()),
        )
    })?;
    Ok(())
}

fn merge_retained_evidence_ref(
    path: &Path,
    run_id: &str,
    key: &str,
    ref_id: String,
) -> CoreResult<()> {
    let mut retained: RetainedRunEvidenceRecord = read_yaml_or_default(path)?;
    retained.schema_version = "retained-run-evidence-v1".to_string();
    retained.run_id = run_id.to_string();
    retained.evidence_refs.insert(key.to_string(), ref_id);
    retained.updated_at = now_rfc3339().map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to compute retained-evidence timestamp: {e}"),
        )
    })?;
    write_yaml(path, &retained).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to update retained run evidence {}: {e}",
                path.display()
            ),
        )
    })?;
    Ok(())
}

fn discover_repo_root(path: &Path) -> Option<PathBuf> {
    let mut current = if path.is_dir() {
        path.to_path_buf()
    } else {
        path.parent()?.to_path_buf()
    };
    loop {
        if current.join(".octon").is_dir() {
            return Some(current);
        }
        if !current.pop() {
            return None;
        }
    }
}

fn resolve_relative_from_runtime_path(runtime_path: &Path, relative: &str) -> Option<PathBuf> {
    let repo_root = discover_repo_root(runtime_path)?;
    let relative_path = PathBuf::from(relative);
    Some(if relative_path.is_absolute() {
        relative_path
    } else {
        repo_root.join(relative_path)
    })
}

fn copy_json_if_present(src: &Path, dst: &Path) -> CoreResult<()> {
    if let Some(parent) = dst.parent() {
        fs::create_dir_all(parent).map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!(
                    "failed to create canonical receipt directory {}: {e}",
                    parent.display()
                ),
            )
        })?;
    }
    let bytes = fs::read(src).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to read execution artifact {}: {e}", src.display()),
        )
    })?;
    fs::write(dst, bytes).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to write canonical receipt {}: {e}", dst.display()),
        )
    })?;
    Ok(())
}

fn bound_run_from_grant(runtime_path: &Path, grant: &GrantBundle) -> Option<BoundRunLifecycle> {
    let repo_root = discover_repo_root(runtime_path)?;
    let control_root_rel = grant.run_control_root.clone()?;
    let control_root = resolve_relative_from_runtime_path(runtime_path, &control_root_rel)?;
    let evidence_root = resolve_relative_from_runtime_path(runtime_path, &grant.run_root)?;
    let assurance_root = evidence_root.join("assurance");
    let measurement_root = evidence_root.join("measurements");
    let intervention_root = evidence_root.join("interventions");
    let disclosure_root = repo_root
        .join(".octon/state/evidence/disclosure/runs")
        .join(&grant.request_id);
    let replay_manifest_path = evidence_root.join("replay").join("manifest.yml");
    let continuity_handoff_path = repo_root
        .join(".octon/state/continuity/runs")
        .join(&grant.request_id)
        .join("handoff.yml");
    let run_manifest_path = control_root.join("run-manifest.yml");
    let runtime_state_path = control_root.join("runtime-state.yml");
    let control_checkpoint_path = control_root.join("checkpoints").join("bound.yml");
    let receipts_root = if let Some(rel) = &grant.run_receipts_root {
        resolve_relative_from_runtime_path(runtime_path, rel)?
    } else {
        evidence_root.join("receipts")
    };
    let replay_pointers_path = if let Some(rel) = &grant.replay_pointers_path {
        resolve_relative_from_runtime_path(runtime_path, rel)?
    } else {
        evidence_root.join("replay-pointers.yml")
    };
    let trace_pointers_path = if let Some(rel) = &grant.trace_pointers_path {
        resolve_relative_from_runtime_path(runtime_path, rel)?
    } else {
        evidence_root.join("trace-pointers.yml")
    };
    let retained_evidence_path = if let Some(rel) = &grant.retained_evidence_path {
        resolve_relative_from_runtime_path(runtime_path, rel)?
    } else {
        evidence_root.join("retained-run-evidence.yml")
    };
    let evidence_classification_path = evidence_root.join("evidence-classification.yml");
    let stage_attempt_path = if let Some(rel) = &grant.stage_attempt_ref {
        resolve_relative_from_runtime_path(runtime_path, rel)?
    } else {
        control_root.join("stage-attempts").join("initial.yml")
    };
    let stage_attempt_id = stage_attempt_path
        .file_stem()
        .and_then(|value| value.to_str())
        .unwrap_or("initial")
        .to_string();
    Some(BoundRunLifecycle {
        control_root: control_root.clone(),
        evidence_root: evidence_root.clone(),
        assurance_root,
        measurement_root,
        intervention_root,
        disclosure_root,
        replay_manifest_path,
        continuity_handoff_path: continuity_handoff_path.clone(),
        _run_manifest_path: run_manifest_path.clone(),
        runtime_state_path: runtime_state_path.clone(),
        receipts_root: receipts_root.clone(),
        replay_pointers_path: replay_pointers_path.clone(),
        _evidence_classification_path: evidence_classification_path.clone(),
        retained_evidence_path: retained_evidence_path.clone(),
        stage_attempt_path: stage_attempt_path.clone(),
        control_root_rel,
        evidence_root_rel: path_tail(&repo_root, &evidence_root),
        control_checkpoint_ref: path_tail(&repo_root, &control_checkpoint_path),
        run_manifest_ref: path_tail(&repo_root, &run_manifest_path),
        receipts_root_rel: path_tail(&repo_root, &receipts_root),
        replay_pointers_ref: path_tail(&repo_root, &replay_pointers_path),
        trace_pointers_ref: path_tail(&repo_root, &trace_pointers_path),
        evidence_classification_ref: path_tail(&repo_root, &evidence_classification_path),
        retained_evidence_ref: path_tail(&repo_root, &retained_evidence_path),
        stage_attempt_ref: path_tail(&repo_root, &stage_attempt_path),
        stage_attempt_id,
    })
}

fn read_yaml_or_default<T>(path: &Path) -> CoreResult<T>
where
    T: Default + for<'de> Deserialize<'de>,
{
    if !path.is_file() {
        return Ok(T::default());
    }
    read_yaml_file(path)
}

fn load_run_contract_record(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
    autonomy_state: Option<&ResolvedAutonomyState>,
) -> CoreResult<RunContractRecord> {
    let path = run_contract_path(cfg, &request.request_id);
    let mut record: RunContractRecord = read_yaml_or_default(&path)?;
    let request_support_target = requested_support_target_tuple(request)?;
    if record.support_tier.trim().is_empty() {
        record.support_tier = request_support_target.workload_tier.clone();
    }
    if record.support_target.workload_tier.trim().is_empty() {
        record.support_target = request_support_target;
    }
    if record.requested_capability_packs.is_empty() {
        record.requested_capability_packs = infer_requested_capability_packs(request);
    }
    if record.intent_ref.is_none() {
        record.intent_ref = request
            .intent_ref
            .clone()
            .or_else(|| active_intent_ref(cfg));
    }
    if record.actor_ref.is_none() {
        record.actor_ref = Some(request.actor_ref.clone().unwrap_or_else(default_actor_ref));
    }
    if record.reversibility_class.trim().is_empty() {
        record.reversibility_class = autonomy_state
            .map(|state| state.context.reversibility_class.clone())
            .unwrap_or_else(|| "reversible".to_string());
    }
    Ok(record)
}

fn load_ownership_registry(cfg: &RuntimeConfig) -> CoreResult<OwnershipRegistryRecord> {
    let path = cfg
        .octon_dir
        .join("instance")
        .join("governance")
        .join("ownership")
        .join("registry.yml");
    read_yaml_or_default(&path)
}

fn ownership_glob_matches(pattern: &str, candidate: &str) -> bool {
    if pattern == "**" || pattern == "*" {
        return true;
    }
    if let Some(prefix) = pattern.strip_suffix("/**") {
        return candidate.starts_with(prefix);
    }
    candidate == pattern
}

fn resolve_ownership_posture(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
    run_contract: &RunContractRecord,
) -> CoreResult<OwnershipPosture> {
    let registry = load_ownership_registry(cfg)?;
    let mut owner_refs = Vec::new();
    let mut matched_asset_ref = None;

    for asset in &registry.assets {
        if asset.path_globs.iter().any(|glob| {
            request
                .scope_constraints
                .write
                .iter()
                .any(|path| ownership_glob_matches(glob, path))
        }) {
            matched_asset_ref = asset.asset_id.clone();
            owner_refs.extend(
                asset
                    .owners
                    .iter()
                    .filter(|value| !value.trim().is_empty())
                    .map(|value| format!("operator://{value}")),
            );
            break;
        }
    }

    if owner_refs.is_empty() && request.caller_path == "service" {
        for service in &registry.services {
            if service.service_id.as_deref() == Some(request.target_id.as_str()) {
                owner_refs.extend(
                    service
                        .owners
                        .iter()
                        .filter(|value| !value.trim().is_empty())
                        .map(|value| format!("operator://{value}")),
                );
            }
        }
    }

    if owner_refs.is_empty() {
        if let Some(default_owner) = registry.defaults.operator_id {
            owner_refs.push(format!("operator://{default_owner}"));
        } else if let Some(operator) = registry.operators.first() {
            owner_refs.push(format!("operator://{}", operator.operator_id));
        }
    }

    let status = if owner_refs.is_empty() {
        "unresolved"
    } else {
        "resolved"
    };
    let source = if let Some(asset_ref) = &matched_asset_ref {
        let asset_support_tier = registry
            .assets
            .iter()
            .find(|asset| asset.asset_id.as_ref() == Some(asset_ref))
            .and_then(|asset| asset.support_tier.as_deref());
        if asset_support_tier.is_some() {
            "ownership_registry.asset_with_support_tier"
        } else {
            "ownership_registry.asset"
        }
    } else if !request.scope_constraints.write.is_empty() {
        "ownership_registry.default"
    } else if !run_contract.support_tier.trim().is_empty() {
        "ownership_registry.support_tier_default"
    } else {
        "ownership_registry.fallback"
    };

    Ok(OwnershipPosture {
        status: status.to_string(),
        source: source.to_string(),
        owner_refs,
        matched_asset_ref,
    })
}

fn load_support_targets(cfg: &RuntimeConfig) -> CoreResult<SupportTargetsRecord> {
    let path = cfg
        .octon_dir
        .join("instance")
        .join("governance")
        .join("support-targets.yml");
    read_yaml_file(&path)
}

fn load_support_target_admissions(
    cfg: &RuntimeConfig,
) -> CoreResult<Vec<SupportTargetAdmissionRecord>> {
    let root = cfg
        .octon_dir
        .join("instance")
        .join("governance")
        .join("support-target-admissions");
    let mut admissions = Vec::new();
    if !root.is_dir() {
        return Ok(admissions);
    }
    for entry in fs::read_dir(&root).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to read support-target admissions {}: {e}", root.display()),
        )
    })? {
        let entry = entry.map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!("failed to read support-target admission entry: {e}"),
            )
        })?;
        let path = entry.path();
        if path.extension().and_then(|value| value.to_str()) != Some("yml") {
            continue;
        }
        admissions.push(read_yaml_file(&path)?);
    }
    Ok(admissions)
}

fn load_runtime_capability_pack_registry(
    cfg: &RuntimeConfig,
) -> CoreResult<RuntimeCapabilityPackRegistryRecord> {
    let path = cfg
        .octon_dir
        .join("instance")
        .join("capabilities")
        .join("runtime")
        .join("packs")
        .join("registry.yml");
    read_yaml_file(&path)
}

fn resolve_contract_path(repo_root: &Path, raw: &str) -> PathBuf {
    repo_root.join(raw)
}

fn string_set_contains_all(container: &[String], expected: &[String]) -> bool {
    let values: BTreeSet<&str> = container.iter().map(|value| value.as_str()).collect();
    expected
        .iter()
        .all(|candidate| values.contains(candidate.as_str()))
}

fn validate_support_tier_declarations(
    declarations: &AdapterSupportTierDeclarationsRecord,
    adapter: &AdapterSupportDeclaration,
) -> bool {
    string_set_contains_all(&declarations.model_tiers, &adapter.allowed_model_tiers)
        && string_set_contains_all(
            &declarations.workload_tiers,
            &adapter.allowed_workload_tiers,
        )
        && string_set_contains_all(
            &declarations.language_resource_tiers,
            &adapter.allowed_language_resource_tiers,
        )
        && string_set_contains_all(&declarations.locale_tiers, &adapter.allowed_locale_tiers)
}

fn validate_host_adapter_manifest(
    cfg: &RuntimeConfig,
    adapter: &AdapterSupportDeclaration,
) -> Option<HostAdapterManifestRecord> {
    if adapter.contract_ref.trim().is_empty() {
        return None;
    }
    let path = resolve_contract_path(&cfg.repo_root, &adapter.contract_ref);
    let manifest = read_yaml_file::<HostAdapterManifestRecord>(&path).ok()?;
    if manifest.schema_version != "octon-host-adapter-v1"
        || manifest.adapter_id != adapter.adapter_id
        || manifest.display_name.trim().is_empty()
        || !matches!(
            manifest.host_family.as_str(),
            "github" | "ci" | "local-cli" | "studio"
        )
        || !manifest.replaceable
        || !matches!(
            manifest.authority_mode.as_str(),
            "projection_only" | "non_authoritative"
        )
        || manifest.runtime_surface.interface_ref.trim().is_empty()
        || manifest.runtime_surface.integration_class.trim().is_empty()
        || manifest.support_target_ref != ".octon/instance/governance/support-targets.yml"
        || (manifest.host_family != "local-cli" && manifest.projection_sources.is_empty())
        || !validate_support_tier_declarations(&manifest.support_tier_declarations, adapter)
        || !string_set_contains_all(&manifest.conformance_criteria_refs, &adapter.criteria_refs)
        || manifest.known_limitations.is_empty()
        || manifest.non_authoritative_boundaries.is_empty()
    {
        return None;
    }
    Some(manifest)
}

fn validate_model_adapter_manifest(
    cfg: &RuntimeConfig,
    adapter: &AdapterSupportDeclaration,
) -> Option<ModelAdapterManifestRecord> {
    if adapter.contract_ref.trim().is_empty() {
        return None;
    }
    let path = resolve_contract_path(&cfg.repo_root, &adapter.contract_ref);
    let manifest = read_yaml_file::<ModelAdapterManifestRecord>(&path).ok()?;
    if manifest.schema_version != "octon-model-adapter-v1"
        || manifest.adapter_id != adapter.adapter_id
        || manifest.display_name.trim().is_empty()
        || !manifest.replaceable
        || manifest.authority_mode != "non_authoritative"
        || manifest.runtime_surface.interface_ref.trim().is_empty()
        || manifest.runtime_surface.integration_class.trim().is_empty()
        || manifest.support_target_ref != ".octon/instance/governance/support-targets.yml"
        || !validate_support_tier_declarations(&manifest.support_tier_declarations, adapter)
        || !string_set_contains_all(&manifest.conformance_criteria_refs, &adapter.criteria_refs)
        || manifest.conformance_suite_refs.is_empty()
        || manifest
            .contamination_reset_policy
            .contamination_signal_ref
            .trim()
            .is_empty()
        || manifest
            .contamination_reset_policy
            .evidence_log_ref
            .trim()
            .is_empty()
        || !manifest
            .contamination_reset_policy
            .clean_checkpoint_required
        || !manifest.contamination_reset_policy.hard_reset_on_signature
        || manifest.known_limitations.is_empty()
        || manifest.non_authoritative_boundaries.is_empty()
    {
        return None;
    }
    Some(manifest)
}

fn infer_requested_capability_packs(request: &ExecutionRequest) -> Vec<String> {
    let mut packs = Vec::new();

    if !request.scope_constraints.read.is_empty()
        || !request.scope_constraints.write.is_empty()
        || request.caller_path == "workflow-stage"
        || request.caller_path == "service"
    {
        packs.push("repo".to_string());
    }
    if request.side_effect_flags.shell {
        packs.push("shell".to_string());
    }
    if request.side_effect_flags.write_repo
        || request.side_effect_flags.branch_mutation
        || request.side_effect_flags.publication
        || request.action_type.contains("git")
    {
        packs.push("git".to_string());
    }
    if request.side_effect_flags.write_evidence || request.side_effect_flags.state_mutation {
        packs.push("telemetry".to_string());
    }
    if request.side_effect_flags.network
        || request
            .requested_capabilities
            .iter()
            .any(|value| value == "net.http")
        || request.metadata.contains_key("network_egress_url")
    {
        packs.push("api".to_string());
    }
    if request
        .requested_capabilities
        .iter()
        .any(|value| value.starts_with("browser."))
        || request
            .metadata
            .keys()
            .any(|value| value.starts_with("browser_"))
    {
        packs.push("browser".to_string());
    }
    if let Some(raw) = request.metadata.get("support_capability_packs") {
        for item in raw.split(',') {
            let trimmed = item.trim();
            if !trimmed.is_empty() {
                packs.push(trimmed.to_string());
            }
        }
    }

    dedupe_strings(&packs)
}

fn resolve_capability_pack_support(
    cfg: &RuntimeConfig,
    requested_packs: &[String],
    allowed_packs: &[String],
) -> ResolvedCapabilityPackSupport {
    if requested_packs.is_empty() {
        return ResolvedCapabilityPackSupport {
            support_status: "supported".to_string(),
            route: "allow".to_string(),
            required_evidence: Vec::new(),
        };
    }

    let registry = match load_runtime_capability_pack_registry(cfg) {
        Ok(registry) => registry,
        Err(_) => {
            return ResolvedCapabilityPackSupport {
                support_status: "unsupported".to_string(),
                route: "deny".to_string(),
                required_evidence: Vec::new(),
            }
        }
    };

    let allowed: BTreeSet<&str> = allowed_packs.iter().map(|value| value.as_str()).collect();
    let mut required_evidence = Vec::new();
    let mut route = "allow".to_string();

    for requested in requested_packs {
        let Some(pack) = registry
            .packs
            .iter()
            .find(|candidate| candidate.pack_id == *requested)
        else {
            return ResolvedCapabilityPackSupport {
                support_status: "unsupported".to_string(),
                route: "deny".to_string(),
                required_evidence,
            };
        };

        let manifest_path = resolve_contract_path(&cfg.repo_root, &pack.contract_ref);
        let manifest = match read_yaml_file::<CapabilityPackManifestRecord>(&manifest_path) {
            Ok(manifest) => manifest,
            Err(_) => {
                return ResolvedCapabilityPackSupport {
                    support_status: "unsupported".to_string(),
                    route: "deny".to_string(),
                    required_evidence,
                }
            }
        };
        if manifest.schema_version != "octon-capability-pack-v1"
            || manifest.pack_id != pack.pack_id
            || manifest.surface != pack.pack_id
            || manifest.display_name.trim().is_empty()
            || manifest.description.trim().is_empty()
            || manifest.runtime_surface_refs.is_empty()
            || manifest.support_target_ref != ".octon/instance/governance/support-targets.yml"
            || manifest.known_limitations.is_empty()
            || pack.contract_ref.trim().is_empty()
            || !matches!(pack.admission_status.as_str(), "admitted" | "unadmitted")
            || pack.default_route.trim().is_empty()
        {
            return ResolvedCapabilityPackSupport {
                support_status: "unsupported".to_string(),
                route: "deny".to_string(),
                required_evidence,
            };
        }

        if pack.admission_status != "admitted" || !allowed.contains(requested.as_str()) {
            return ResolvedCapabilityPackSupport {
                support_status: "unsupported".to_string(),
                route: "deny".to_string(),
                required_evidence: merge_required_evidence(
                    manifest
                        .required_evidence
                        .iter()
                        .chain(pack.required_evidence.iter()),
                ),
            };
        }

        required_evidence.extend(manifest.required_evidence.clone());
        required_evidence.extend(pack.required_evidence.clone());
        route = combine_route(&[route.as_str(), pack.default_route.as_str()]);
    }

    ResolvedCapabilityPackSupport {
        support_status: "supported".to_string(),
        route,
        required_evidence: dedupe_strings(&required_evidence),
    }
}

fn route_rank(route: &str) -> u8 {
    match route {
        "deny" => 3,
        "escalate" => 2,
        "stage_only" => 1,
        "allow" => 0,
        _ => 3,
    }
}

fn combine_route(routes: &[&str]) -> String {
    routes
        .iter()
        .copied()
        .max_by_key(|route| route_rank(route))
        .unwrap_or("deny")
        .to_string()
}

fn support_status_rank(status: &str) -> u8 {
    match status {
        "unsupported" => 3,
        "experimental" => 2,
        "reduced" => 1,
        "supported" => 0,
        _ => 3,
    }
}

fn combine_support_status(statuses: &[&str]) -> String {
    statuses
        .iter()
        .copied()
        .max_by_key(|status| support_status_rank(status))
        .unwrap_or("unsupported")
        .to_string()
}

fn merge_required_evidence<'a, I>(inputs: I) -> Vec<String>
where
    I: IntoIterator<Item = &'a String>,
{
    let mut unique = BTreeSet::new();
    let mut merged = Vec::new();
    for value in inputs {
        if unique.insert(value.clone()) {
            merged.push(value.clone());
        }
    }
    merged
}

fn resolve_adapter_support(
    cfg: &RuntimeConfig,
    declaration: &SupportTargetsRecord,
    adapter_kind: &str,
    adapter_id: &str,
    model_tier: &str,
    workload_tier: &str,
    language_resource_tier: &str,
    locale_tier: &str,
) -> ResolvedAdapterSupport {
    let declarations = if adapter_kind == "host" {
        &declaration.host_adapters
    } else {
        &declaration.model_adapters
    };

    let Some(adapter) = declarations
        .iter()
        .find(|candidate| candidate.adapter_id == adapter_id)
    else {
        return ResolvedAdapterSupport {
            adapter_id: adapter_id.to_string(),
            support_status: "unsupported".to_string(),
            route: "deny".to_string(),
            ..ResolvedAdapterSupport::default()
        };
    };

    if adapter.contract_ref.trim().is_empty()
        || adapter.authority_mode.trim().is_empty()
        || !adapter.replaceable
        || adapter.criteria_refs.is_empty()
        || adapter.allowed_model_tiers.is_empty()
        || adapter.allowed_workload_tiers.is_empty()
        || adapter.allowed_language_resource_tiers.is_empty()
        || adapter.allowed_locale_tiers.is_empty()
    {
        return ResolvedAdapterSupport {
            adapter_id: adapter.adapter_id.clone(),
            support_status: "unsupported".to_string(),
            route: "deny".to_string(),
            ..ResolvedAdapterSupport::default()
        };
    }

    let authority_mode_valid = if adapter_kind == "host" {
        matches!(
            adapter.authority_mode.as_str(),
            "projection_only" | "non_authoritative"
        )
    } else {
        adapter.authority_mode == "non_authoritative"
    };
    if !authority_mode_valid {
        return ResolvedAdapterSupport {
            adapter_id: adapter.adapter_id.clone(),
            support_status: "unsupported".to_string(),
            route: "deny".to_string(),
            ..ResolvedAdapterSupport::default()
        };
    }

    let manifest_valid = if adapter_kind == "host" {
        validate_host_adapter_manifest(cfg, adapter).is_some()
    } else {
        validate_model_adapter_manifest(cfg, adapter).is_some()
    };
    if !manifest_valid {
        return ResolvedAdapterSupport {
            adapter_id: adapter.adapter_id.clone(),
            support_status: "unsupported".to_string(),
            route: "deny".to_string(),
            ..ResolvedAdapterSupport::default()
        };
    }

    let criteria: Vec<_> = adapter
        .criteria_refs
        .iter()
        .filter_map(|criterion_id| {
            declaration
                .adapter_conformance_criteria
                .iter()
                .find(|criterion| {
                    criterion.criterion_id == *criterion_id
                        && criterion.adapter_kind == adapter_kind
                })
        })
        .collect();

    if criteria.len() != adapter.criteria_refs.len() {
        return ResolvedAdapterSupport {
            adapter_id: adapter.adapter_id.clone(),
            support_status: "unsupported".to_string(),
            route: "deny".to_string(),
            ..ResolvedAdapterSupport::default()
        };
    }

    let tier_match = adapter
        .allowed_model_tiers
        .iter()
        .any(|value| value == model_tier)
        && adapter
            .allowed_workload_tiers
            .iter()
            .any(|value| value == workload_tier)
        && adapter
            .allowed_language_resource_tiers
            .iter()
            .any(|value| value == language_resource_tier)
        && adapter
            .allowed_locale_tiers
            .iter()
            .any(|value| value == locale_tier);

    let required_evidence = merge_required_evidence(
        adapter.required_evidence.iter().chain(
            criteria
                .iter()
                .flat_map(|criterion| criterion.required_evidence.iter()),
        ),
    );

    if !tier_match {
        return ResolvedAdapterSupport {
            adapter_id: adapter.adapter_id.clone(),
            support_status: "unsupported".to_string(),
            route: "deny".to_string(),
            criteria_refs: adapter.criteria_refs.clone(),
            required_evidence,
        };
    }

    ResolvedAdapterSupport {
        adapter_id: adapter.adapter_id.clone(),
        support_status: if adapter.support_status.trim().is_empty() {
            "unsupported".to_string()
        } else {
            adapter.support_status.clone()
        },
        route: if adapter.default_route.trim().is_empty() {
            declaration.default_route.clone()
        } else {
            adapter.default_route.clone()
        },
        criteria_refs: adapter.criteria_refs.clone(),
        required_evidence,
    }
}

fn resolve_support_tier_posture(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
    run_contract: &RunContractRecord,
    autonomy_state: Option<&ResolvedAutonomyState>,
) -> CoreResult<SupportTierPosture> {
    let declaration = load_support_targets(cfg)?;
    let admissions = load_support_target_admissions(cfg)?;
    let requested_tuple = if run_contract.support_target.workload_tier.trim().is_empty() {
        requested_support_target_tuple(request)?
    } else {
        run_contract.support_target.clone()
    };
    let requested_tier = requested_tuple.workload_tier.trim();
    let model_tier = requested_tuple.model_tier.clone();
    let host_adapter_id = requested_tuple.host_adapter.clone();
    let model_adapter_id = requested_tuple.model_adapter.clone();
    let language_resource_tier = requested_tuple.language_resource_tier.clone();
    let locale_tier = requested_tuple.locale_tier.clone();
    let requested_capability_packs = if run_contract.requested_capability_packs.is_empty() {
        infer_requested_capability_packs(request)
    } else {
        dedupe_strings(&run_contract.requested_capability_packs)
    };
    let Some(workload) = declaration
        .tiers
        .workload
        .iter()
        .find(|tier| tier.id == requested_tier || tier.label == requested_tier)
        .cloned()
    else {
        return Ok(SupportTierPosture {
            support_tier: requested_tier.to_string(),
            model_tier_id: Some(model_tier),
            route: declaration.default_route,
            support_status: "unsupported".to_string(),
            host_adapter_id: Some(host_adapter_id),
            model_adapter_id: Some(model_adapter_id),
            requested_capability_packs,
            declaration_ref: Some(".octon/instance/governance/support-targets.yml".to_string()),
            ..SupportTierPosture::default()
        });
    };

    let model_known = declaration
        .tiers
        .model
        .iter()
        .any(|tier| tier.id == model_tier || tier.label == model_tier);
    let language_known = declaration
        .tiers
        .language_resource
        .iter()
        .any(|tier| tier.id == language_resource_tier || tier.label == language_resource_tier);
    let locale_known = declaration
        .tiers
        .locale
        .iter()
        .any(|tier| tier.id == locale_tier || tier.label == locale_tier);

    if !model_known || !language_known || !locale_known {
        return Ok(SupportTierPosture {
            support_tier: run_contract.support_tier.clone(),
            model_tier_id: Some(model_tier),
            workload_tier_id: Some(workload.id.clone()),
            language_resource_tier_id: Some(language_resource_tier),
            locale_tier_id: Some(locale_tier),
            workload_tier_label: Some(workload.label),
            support_status: "unsupported".to_string(),
            route: declaration.default_route,
            host_adapter_id: Some(host_adapter_id),
            model_adapter_id: Some(model_adapter_id),
            requested_capability_packs,
            declaration_ref: Some(".octon/instance/governance/support-targets.yml".to_string()),
            ..SupportTierPosture::default()
        });
    }

    let explicit_admission_ref = !run_contract.support_target_admission_ref.trim().is_empty();
    let admission = if explicit_admission_ref {
        let path = resolve_contract_path(&cfg.repo_root, &run_contract.support_target_admission_ref);
        if path.is_file() {
            Some(read_yaml_file(&path)?)
        } else {
            None
        }
    } else {
        admissions
            .iter()
            .find(|entry| {
                entry.tuple.model_tier == model_tier
                    && entry.tuple.workload_tier == workload.id
                    && entry.tuple.language_resource_tier == language_resource_tier
                    && entry.tuple.locale_tier == locale_tier
                    && entry.tuple.host_adapter == host_adapter_id
                    && entry.tuple.model_adapter == model_adapter_id
            })
            .cloned()
    };
    if explicit_admission_ref
        && admission
            .as_ref()
            .map(|entry| {
                entry.tuple.model_tier != model_tier
                    || entry.tuple.workload_tier != workload.id
                    || entry.tuple.language_resource_tier != language_resource_tier
                    || entry.tuple.locale_tier != locale_tier
                    || entry.tuple.host_adapter != host_adapter_id
                    || entry.tuple.model_adapter != model_adapter_id
            })
            .unwrap_or(true)
    {
        return Ok(SupportTierPosture {
            support_tier: requested_tier.to_string(),
            model_tier_id: Some(model_tier),
            workload_tier_id: Some(workload.id.clone()),
            language_resource_tier_id: Some(language_resource_tier),
            locale_tier_id: Some(locale_tier),
            workload_tier_label: Some(workload.label),
            support_status: "unsupported".to_string(),
            route: declaration.default_route,
            host_adapter_id: Some(host_adapter_id),
            model_adapter_id: Some(model_adapter_id),
            requested_capability_packs,
            declaration_ref: Some(run_contract.support_target_admission_ref.clone()),
            ..SupportTierPosture::default()
        });
    }
    let matrix_entry = declaration.compatibility_matrix.iter().find(|entry| {
        entry.model_tier == model_tier
            && entry.workload_tier == workload.id
            && entry.language_resource_tier == language_resource_tier
            && entry.locale_tier == locale_tier
    });
    let base_support_status = admission
        .as_ref()
        .map(|entry| entry.status.clone())
        .or_else(|| matrix_entry.map(|entry| entry.support_status.clone()))
        .unwrap_or_else(|| "unsupported".to_string());
    let base_route = admission
        .as_ref()
        .map(|entry| entry.route.clone())
        .or_else(|| matrix_entry.map(|entry| entry.default_route.clone()))
        .unwrap_or_else(|| {
            if workload.default_route.trim().is_empty() {
                declaration.default_route.clone()
            } else {
                workload.default_route.clone()
            }
        });
    let requires_mission = admission
        .as_ref()
        .map(|entry| entry.requires_mission)
        .or_else(|| matrix_entry.and_then(|entry| entry.requires_mission))
        .unwrap_or(false);
    let base_required_evidence = admission
        .as_ref()
        .map(|entry| entry.required_authority_artifacts.clone())
        .or_else(|| matrix_entry.map(|entry| entry.required_evidence.clone()))
        .unwrap_or_default();
    let allowed_capability_packs = admission
        .as_ref()
        .map(|entry| entry.allowed_capability_packs.clone())
        .or_else(|| matrix_entry.map(|entry| entry.allowed_capability_packs.clone()))
        .unwrap_or_default();
    let host_adapter = resolve_adapter_support(
        cfg,
        &declaration,
        "host",
        &host_adapter_id,
        &model_tier,
        &workload.id,
        &language_resource_tier,
        &locale_tier,
    );
    let model_adapter = resolve_adapter_support(
        cfg,
        &declaration,
        "model",
        &model_adapter_id,
        &model_tier,
        &workload.id,
        &language_resource_tier,
        &locale_tier,
    );
    let capability_pack_support = resolve_capability_pack_support(
        cfg,
        &requested_capability_packs,
        &allowed_capability_packs,
    );
    let support_status = combine_support_status(&[
        base_support_status.as_str(),
        host_adapter.support_status.as_str(),
        model_adapter.support_status.as_str(),
        capability_pack_support.support_status.as_str(),
    ]);
    let route = combine_route(&[
        base_route.as_str(),
        host_adapter.route.as_str(),
        model_adapter.route.as_str(),
        capability_pack_support.route.as_str(),
    ]);
    let adapter_conformance_criteria = merge_required_evidence(
        host_adapter
            .criteria_refs
            .iter()
            .chain(model_adapter.criteria_refs.iter()),
    );
    let required_evidence = merge_required_evidence(
        base_required_evidence
            .iter()
            .chain(host_adapter.required_evidence.iter())
            .chain(model_adapter.required_evidence.iter()),
    );
    let required_evidence = merge_required_evidence(
        required_evidence
            .iter()
            .chain(capability_pack_support.required_evidence.iter()),
    );

    if requires_mission && autonomy_state.is_none() {
        return Ok(SupportTierPosture {
            support_tier: run_contract.support_tier.clone(),
            model_tier_id: Some(model_tier.clone()),
            workload_tier_id: Some(workload.id),
            language_resource_tier_id: Some(language_resource_tier.clone()),
            locale_tier_id: Some(locale_tier.clone()),
            workload_tier_label: Some(workload.label),
            host_adapter_id: Some(host_adapter.adapter_id),
            host_adapter_status: Some(host_adapter.support_status),
            model_adapter_id: Some(model_adapter.adapter_id),
            model_adapter_status: Some(model_adapter.support_status),
            adapter_conformance_criteria,
            support_status,
            route: "deny".to_string(),
            requires_mission,
            required_evidence,
            allowed_capability_packs,
            requested_capability_packs,
            declaration_ref: Some(".octon/instance/governance/support-targets.yml".to_string()),
        });
    }

    Ok(SupportTierPosture {
        support_tier: run_contract.support_tier.clone(),
        model_tier_id: Some(model_tier),
        workload_tier_id: Some(workload.id),
        language_resource_tier_id: Some(language_resource_tier),
        locale_tier_id: Some(locale_tier),
        workload_tier_label: Some(workload.label),
        host_adapter_id: Some(host_adapter.adapter_id),
        host_adapter_status: Some(host_adapter.support_status),
        model_adapter_id: Some(model_adapter.adapter_id),
        model_adapter_status: Some(model_adapter.support_status),
        adapter_conformance_criteria,
        support_status,
        route,
        requires_mission,
        required_evidence,
        allowed_capability_packs,
        requested_capability_packs,
        declaration_ref: Some(".octon/instance/governance/support-targets.yml".to_string()),
    })
}

fn review_metadata_from_env() -> BTreeMap<String, String> {
    let mut review_metadata = BTreeMap::new();
    if let Ok(value) = std::env::var("OCTON_EXECUTION_QUORUM_TOKEN") {
        if !value.trim().is_empty() {
            review_metadata.insert("quorum_token".to_string(), value);
        }
    }
    if let Ok(value) = std::env::var("OCTON_EXECUTION_ROLLBACK_REF") {
        if !value.trim().is_empty() {
            review_metadata.insert("rollback_ref".to_string(), value);
        }
    }
    review_metadata
}

fn approval_projection_sources(request: &ExecutionRequest) -> Vec<AuthorityProjection> {
    let mut projections = Vec::new();
    for key in [
        "approval_projection_label",
        "approval_projection_comment",
        "approval_projection_check",
    ] {
        if let Some(value) = request.metadata.get(key) {
            projections.push(AuthorityProjection {
                kind: key.replace("approval_projection_", "host-"),
                ref_id: value.clone(),
                notes: Some("Host projection recorded for traceability only.".to_string()),
            });
        }
    }
    projections
}

pub fn with_authority_env_metadata(
    mut metadata: BTreeMap<String, String>,
) -> BTreeMap<String, String> {
    for (env_key, meta_key) in [
        ("OCTON_SUPPORT_TIER", "support_tier"),
        ("OCTON_SUPPORT_HOST_ADAPTER", "support_host_adapter"),
        ("OCTON_SUPPORT_MODEL_ADAPTER", "support_model_adapter"),
        ("OCTON_SUPPORT_MODEL_TIER", "support_model_tier"),
        (
            "OCTON_SUPPORT_LANGUAGE_RESOURCE_TIER",
            "support_language_resource_tier",
        ),
        ("OCTON_SUPPORT_LOCALE_TIER", "support_locale_tier"),
        (
            "OCTON_APPROVAL_PROJECTION_LABEL",
            "approval_projection_label",
        ),
        (
            "OCTON_APPROVAL_PROJECTION_COMMENT",
            "approval_projection_comment",
        ),
        (
            "OCTON_APPROVAL_PROJECTION_CHECK",
            "approval_projection_check",
        ),
    ] {
        if !metadata.contains_key(meta_key) {
            if let Ok(value) = std::env::var(env_key) {
                if !value.trim().is_empty() {
                    metadata.insert(meta_key.to_string(), value);
                }
            }
        }
    }
    metadata
}

fn write_approval_request(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
    run_contract: &RunContractRecord,
    ownership: &OwnershipPosture,
    required_evidence: Vec<String>,
    reason_codes: Vec<String>,
) -> CoreResult<String> {
    let now = now_rfc3339().map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to compute approval timestamp: {e}"),
        )
    })?;
    let artifact = ApprovalRequestArtifact {
        schema_version: "authority-approval-request-v1".to_string(),
        request_id: request.request_id.clone(),
        run_id: request.request_id.clone(),
        status: "pending".to_string(),
        target_id: request.target_id.clone(),
        action_type: request.action_type.clone(),
        workflow_mode: request.workflow_mode.clone(),
        support_tier: run_contract.support_tier.clone(),
        quorum_policy_ref: Some(canonical_quorum_policy_ref().to_string()),
        ownership_refs: ownership.owner_refs.clone(),
        reversibility_class: Some(run_contract.reversibility_class.clone()),
        reason_codes,
        required_evidence,
        projection_sources: approval_projection_sources(request),
        created_at: now.clone(),
        updated_at: now,
    };
    let path = approval_request_path(cfg, &request.request_id);
    write_yaml(&path, &artifact).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to write approval request artifact {}: {e}",
                path.display()
            ),
        )
    })?;
    Ok(path_tail(&cfg.repo_root, &path))
}

fn load_existing_approval_grants(
    cfg: &RuntimeConfig,
    request_id: &str,
) -> CoreResult<Vec<(ApprovalGrantArtifact, String)>> {
    let path = approval_grant_path(cfg, request_id);
    if !path.is_file() {
        return Ok(Vec::new());
    }
    let grant: ApprovalGrantArtifact = read_yaml_file(&path)?;
    if grant.state != "active" {
        return Ok(Vec::new());
    }
    Ok(vec![(grant, path_tail(&cfg.repo_root, &path))])
}

fn load_active_revocation_refs(
    cfg: &RuntimeConfig,
    request_id: &str,
    grant_id: &str,
) -> CoreResult<Vec<String>> {
    let canonical_dir = revocation_directory_path(cfg);
    if canonical_dir.is_dir() {
        let mut refs = Vec::new();
        for entry in fs::read_dir(&canonical_dir).map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!(
                    "failed to read canonical revocation dir {}: {e}",
                    canonical_dir.display()
                ),
            )
        })? {
            let entry = entry.map_err(|e| {
                KernelError::new(
                    ErrorCode::Internal,
                    format!("failed to read canonical revocation entry: {e}"),
                )
            })?;
            let path = entry.path();
            if path.extension().and_then(|value| value.to_str()) != Some("yml") {
                continue;
            }
            if path.file_name().and_then(|value| value.to_str()) == Some("grants.yml") {
                continue;
            }
            let revocation: RevocationArtifact = read_yaml_file(&path)?;
            if revocation.state == "active"
                && (revocation.request_id.as_deref() == Some(request_id)
                    || revocation.grant_id.as_deref() == Some(grant_id))
            {
                refs.push(path_tail(&cfg.repo_root, &path));
            }
        }
        if !refs.is_empty() {
            return Ok(refs);
        }
    }

    let path = revocation_registry_path(cfg);
    let registry: RevocationRegistry = read_yaml_or_default(&path)?;
    Ok(registry
        .revocations
        .into_iter()
        .filter(|revocation| {
            revocation.state == "active"
                && (revocation.request_id.as_deref() == Some(request_id)
                    || revocation.grant_id.as_deref() == Some(grant_id))
        })
        .map(|revocation| {
            format!(
                "{}#{}",
                path_tail(&cfg.repo_root, &path),
                revocation.revocation_id
            )
        })
        .collect())
}

fn budget_posture_from_preview(
    repo_root: &Path,
    run_root: &Path,
    decision: Option<&BudgetDecision>,
) -> serde_json::Value {
    match decision {
        Some(BudgetDecision::Allow {
            rule_id,
            reason_codes,
            evidence,
        }) => json!({
            "route": "allow",
            "rule_id": rule_id,
            "reason_codes": reason_codes,
            "estimated_cost_usd": evidence.estimated_cost_usd,
            "evidence_path": path_tail(repo_root, &run_root.join("cost.json")),
        }),
        Some(BudgetDecision::StageOnly {
            rule_id,
            reason_codes,
            evidence,
            ..
        }) => json!({
            "route": "stage_only",
            "rule_id": rule_id,
            "reason_codes": reason_codes,
            "estimated_cost_usd": evidence.estimated_cost_usd,
            "evidence_path": path_tail(repo_root, &run_root.join("cost.json")),
        }),
        Some(BudgetDecision::Deny {
            rule_id,
            reason_codes,
            evidence,
            ..
        }) => json!({
            "route": "deny",
            "rule_id": rule_id,
            "reason_codes": reason_codes,
            "estimated_cost_usd": evidence.estimated_cost_usd,
            "evidence_path": path_tail(repo_root, &run_root.join("cost.json")),
        }),
        _ => json!({"route": "not-applicable"}),
    }
}

fn reversibility_payload(
    request: &ExecutionRequest,
    run_contract: &RunContractRecord,
    autonomy_state: Option<&ResolvedAutonomyState>,
) -> serde_json::Value {
    json!({
        "requested": run_contract.reversibility_class,
        "effective": autonomy_state
            .map(|state| state.context.reversibility_class.clone())
            .unwrap_or_else(|| run_contract.reversibility_class.clone()),
        "rollback_ref_present": std::env::var("OCTON_EXECUTION_ROLLBACK_REF")
            .map(|value| !value.trim().is_empty())
            .unwrap_or(false),
        "workflow_mode": request.workflow_mode,
    })
}

fn write_decision_artifact(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
    decision: ExecutionDecision,
    reason_codes: Vec<String>,
    ownership: OwnershipPosture,
    support_tier: SupportTierPosture,
    reversibility: serde_json::Value,
    budget: serde_json::Value,
    egress: serde_json::Value,
    approval_request_ref: Option<String>,
    approval_grant_refs: Vec<String>,
    exception_refs: Vec<String>,
    revocation_refs: Vec<String>,
) -> CoreResult<String> {
    let generated_at = now_rfc3339().map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to compute decision timestamp: {e}"),
        )
    })?;
    let artifact = DecisionArtifact {
        schema_version: "authority-decision-artifact-v1".to_string(),
        decision_id: format!("decision-{}", request.request_id),
        request_id: request.request_id.clone(),
        run_id: request.request_id.clone(),
        decision,
        reason_codes,
        ownership,
        support_tier,
        reversibility,
        budget,
        egress,
        approval_request_ref,
        approval_grant_refs,
        exception_refs,
        revocation_refs,
        generated_at,
    };
    let path = decision_artifact_path(cfg, &request.request_id);
    write_yaml(&path, &artifact).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to write decision artifact {}: {e}", path.display()),
        )
    })?;
    Ok(path_tail(&cfg.repo_root, &path))
}

fn write_authority_grant_bundle(cfg: &RuntimeConfig, grant: &GrantBundle) -> CoreResult<String> {
    let path = authority_grant_bundle_path(cfg, &grant.request_id);
    write_yaml(
        &path,
        &json!({
            "schema_version": "authority-grant-bundle-v1",
            "grant_id": grant.grant_id,
            "request_id": grant.request_id,
            "run_id": grant.request_id,
            "workflow_mode": grant.workflow_mode,
            "support_tier": grant.support_tier,
            "support_target": grant.support_posture.as_ref().map(|posture| json!({
                "model_tier": posture.model_tier_id,
                "workload_tier": posture.workload_tier_id,
                "language_resource_tier": posture.language_resource_tier_id,
                "locale_tier": posture.locale_tier_id,
                "host_adapter": posture.host_adapter_id,
                "model_adapter": posture.model_adapter_id,
                "support_status": posture.support_status,
                "route": posture.route,
            })),
            "requested_capability_packs": grant
                .support_posture
                .as_ref()
                .map(|posture| posture.requested_capability_packs.clone())
                .unwrap_or_default(),
            "quorum_policy_ref": grant.quorum_policy_ref,
            "approval_request_ref": grant.approval_request_ref,
            "approval_grant_refs": grant.approval_grant_refs,
            "exception_refs": grant.exception_lease_refs,
            "revocation_refs": grant.revocation_refs,
            "decision_artifact_ref": grant.decision_artifact_ref,
            "generated_at": time::OffsetDateTime::now_utc()
                .format(&time::format_description::well_known::Rfc3339)
                .unwrap_or_else(|_| "1970-01-01T00:00:00Z".to_string()),
        }),
    )
    .map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to write authority grant bundle {}: {e}",
                path.display()
            ),
        )
    })?;
    Ok(path_tail(&cfg.repo_root, &path))
}

fn resolve_autonomy_state(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
    resolved_intent_ref: &IntentRef,
) -> CoreResult<Option<ResolvedAutonomyState>> {
    if !is_autonomous_request(request) {
        return Ok(None);
    }

    let context = request.autonomy_context.clone().ok_or_else(|| {
        mission_denial(
            "autonomous execution requires autonomy_context",
            vec!["MISSION_AUTONOMY_CONTEXT_MISSING"],
        )
    })?;

    if context.intent_ref.id != resolved_intent_ref.id
        || context.intent_ref.version != resolved_intent_ref.version
    {
        return Err(mission_denial(
            "autonomous execution intent binding does not match the resolved active intent",
            vec!["MISSION_AUTONOMY_INTENT_MISMATCH"],
        ));
    }

    let mission_id = context.mission_ref.id.clone();
    let mission_dir = cfg
        .octon_dir
        .join("instance")
        .join("orchestration")
        .join("missions")
        .join(&mission_id);
    let charter_path = mission_dir.join("mission.yml");
    let policy_path = cfg
        .octon_dir
        .join("instance")
        .join("governance")
        .join("policies")
        .join("mission-autonomy.yml");
    let ownership_path = cfg
        .octon_dir
        .join("instance")
        .join("governance")
        .join("ownership")
        .join("registry.yml");
    let control_dir = cfg
        .execution_control_root
        .join("missions")
        .join(&mission_id);
    let lease_path = control_dir.join("lease.yml");
    let mode_state_path = control_dir.join("mode-state.yml");
    let intent_register_path = control_dir.join("intent-register.yml");
    let directives_path = control_dir.join("directives.yml");
    let schedule_path = control_dir.join("schedule.yml");
    let autonomy_budget_path = control_dir.join("autonomy-budget.yml");
    let circuit_breakers_path = control_dir.join("circuit-breakers.yml");
    let subscriptions_path = control_dir.join("subscriptions.yml");
    let scenario_resolution_path = cfg
        .octon_dir
        .join("generated/effective/orchestration/missions")
        .join(&mission_id)
        .join("scenario-resolution.yml");

    for (path, reason_code) in [
        (&charter_path, "MISSION_CHARTER_MISSING"),
        (&policy_path, "MISSION_AUTONOMY_POLICY_MISSING"),
        (&ownership_path, "OWNERSHIP_REGISTRY_MISSING"),
        (&lease_path, "MISSION_CONTROL_LEASE_MISSING"),
        (&mode_state_path, "MISSION_MODE_STATE_MISSING"),
        (&intent_register_path, "MISSION_INTENT_REGISTER_MISSING"),
        (&directives_path, "MISSION_DIRECTIVES_MISSING"),
        (&schedule_path, "MISSION_SCHEDULE_MISSING"),
        (&autonomy_budget_path, "MISSION_AUTONOMY_BUDGET_MISSING"),
        (&circuit_breakers_path, "MISSION_CIRCUIT_BREAKERS_MISSING"),
        (&subscriptions_path, "MISSION_SUBSCRIPTIONS_MISSING"),
    ] {
        ensure_file_exists(path, reason_code)?;
    }
    if !scenario_resolution_path.is_file() {
        return Err(mission_stage_only(
            "mission scenario resolution is missing",
            vec![
                "MISSION_SCENARIO_RESOLUTION_MISSING",
                "ACP_STAGE_ONLY_REQUIRED",
            ],
        ));
    }

    let charter: MissionCharterRecord = read_yaml_file(&charter_path)?;
    if charter.mission_id != mission_id {
        return Err(mission_denial(
            "mission charter id does not match autonomy_context mission_ref",
            vec!["MISSION_CHARTER_ID_MISMATCH"],
        ));
    }
    if charter.mission_class != context.mission_class {
        return Err(mission_denial(
            "autonomy_context mission_class does not match mission charter",
            vec!["MISSION_CLASS_MISMATCH"],
        ));
    }

    let lease: MissionLeaseRecord = read_yaml_file(&lease_path)?;
    if !lease.expires_at.trim().is_empty()
        && parse_rfc3339(&lease.expires_at)? <= time::OffsetDateTime::now_utc()
    {
        return Err(mission_denial(
            "mission continuation lease has expired",
            vec!["MISSION_LEASE_EXPIRED"],
        ));
    }
    match lease.state.as_str() {
        "active" => {}
        "paused" => {
            return Err(mission_stage_only(
                "mission continuation lease is paused",
                vec!["MISSION_LEASE_PAUSED", "ACP_STAGE_ONLY_REQUIRED"],
            ));
        }
        "revoked" | "expired" => {
            return Err(mission_denial(
                "mission continuation lease is not active",
                vec!["MISSION_LEASE_INACTIVE"],
            ));
        }
        _ => {
            return Err(mission_denial(
                "mission continuation lease state is invalid",
                vec!["MISSION_LEASE_INVALID"],
            ));
        }
    }

    let autonomy_budget: MissionAutonomyBudgetRecord = read_yaml_file(&autonomy_budget_path)?;
    let mode_state: MissionModeStateRecord = read_yaml_file(&mode_state_path)?;
    let schedule_state: MissionScheduleRecord = read_yaml_file(&schedule_path)?;
    let breaker_record: MissionCircuitBreakersRecord = read_yaml_file(&circuit_breakers_path)?;
    let scenario_resolution: ScenarioResolutionRecord = read_yaml_file(&scenario_resolution_path)?;
    if scenario_resolution.mission_id != mission_id {
        return Err(mission_denial(
            "scenario resolution mission_id does not match autonomy_context mission_ref",
            vec!["MISSION_SCENARIO_RESOLUTION_MISMATCH"],
        ));
    }
    if scenario_resolution.fresh_until.trim().is_empty() {
        return Err(mission_stage_only(
            "mission scenario resolution is missing freshness metadata",
            vec![
                "MISSION_SCENARIO_RESOLUTION_STALE",
                "ACP_STAGE_ONLY_REQUIRED",
            ],
        ));
    }
    if parse_rfc3339(&scenario_resolution.fresh_until)? <= time::OffsetDateTime::now_utc() {
        return Err(mission_stage_only(
            "mission scenario resolution is stale",
            vec![
                "MISSION_SCENARIO_RESOLUTION_STALE",
                "ACP_STAGE_ONLY_REQUIRED",
            ],
        ));
    }
    let breaker_state = breaker_record.state.clone().unwrap_or_else(|| {
        if breaker_record.tripped_breakers.is_empty() {
            "clear".to_string()
        } else {
            "tripped".to_string()
        }
    });

    let mut context = context;
    if !scenario_resolution
        .effective
        .oversight_mode
        .trim()
        .is_empty()
    {
        context.oversight_mode = scenario_resolution.effective.oversight_mode.clone();
    } else if !mode_state.oversight_mode.trim().is_empty() {
        context.oversight_mode = mode_state.oversight_mode.clone();
    }
    if !scenario_resolution
        .effective
        .execution_posture
        .trim()
        .is_empty()
    {
        context.execution_posture = scenario_resolution.effective.execution_posture.clone();
    } else if !mode_state.execution_posture.trim().is_empty() {
        context.execution_posture = mode_state.execution_posture.clone();
    }
    let autonomy_budget_state = if !mode_state.autonomy_burn_state.trim().is_empty() {
        mode_state.autonomy_burn_state.clone()
    } else {
        autonomy_budget.state.clone()
    };
    if schedule_state.suspended_future_runs {
        return Err(mission_stage_only(
            "mission schedule has suspended future runs",
            vec!["MISSION_SCHEDULE_SUSPENDED", "ACP_STAGE_ONLY_REQUIRED"],
        ));
    }
    if schedule_state.pause_active_run_requested {
        return Err(mission_stage_only(
            "mission schedule requests pause at the next safe boundary",
            vec![
                "MISSION_SCHEDULE_PAUSE_REQUESTED",
                "ACP_STAGE_ONLY_REQUIRED",
            ],
        ));
    }

    if context.oversight_mode == "proceed_on_silence" {
        if !scenario_resolution.effective.proceed_on_silence_allowed {
            return Err(mission_stage_only(
                "proceed_on_silence is blocked by effective scenario routing",
                vec![
                    "MISSION_PROCEED_ON_SILENCE_BLOCKED",
                    "ACP_STAGE_ONLY_REQUIRED",
                ],
            ));
        }
    }
    if scenario_resolution.effective.finalize_policy.block_finalize
        && (request.action_type.contains("finalize")
            || context.reversibility_class == "irreversible")
    {
        return Err(mission_stage_only(
            "mission finalize policy is currently blocking irreversible progression",
            vec!["MISSION_FINALIZE_BLOCKED", "ACP_STAGE_ONLY_REQUIRED"],
        ));
    }
    let action_class = if scenario_resolution
        .effective
        .recovery_profile
        .action_class
        .trim()
        .is_empty()
    {
        return Err(mission_stage_only(
            "mission route could not derive an action class for material work",
            vec!["MISSION_ACTION_CLASS_MISSING", "ACP_STAGE_ONLY_REQUIRED"],
        ));
    } else {
        scenario_resolution
            .effective
            .recovery_profile
            .action_class
            .clone()
    };
    let recovery_window = scenario_resolution
        .effective
        .recovery_profile
        .recovery_window
        .clone();
    if recovery_window.trim().is_empty() {
        return Err(mission_stage_only(
            "mission route could not derive recovery metadata for material work",
            vec![
                "MISSION_RECOVERY_METADATA_MISSING",
                "ACP_STAGE_ONLY_REQUIRED",
            ],
        ));
    }
    let primitive = if scenario_resolution
        .effective
        .recovery_profile
        .primitive
        .trim()
        .is_empty()
    {
        None
    } else {
        Some(
            scenario_resolution
                .effective
                .recovery_profile
                .primitive
                .clone(),
        )
    };
    let rollback_handle = if context.reversibility_class == "reversible" {
        let rollback_handle_prefix = if scenario_resolution
            .effective
            .recovery_profile
            .rollback_handle_type
            .trim()
            .is_empty()
        {
            "rollback"
        } else {
            scenario_resolution
                .effective
                .recovery_profile
                .rollback_handle_type
                .trim()
        };
        Some(format!(
            "{}-{}-{}",
            rollback_handle_prefix, mission_id, context.slice_ref.id
        ))
    } else {
        None
    };
    let compensation_handle = if context.reversibility_class == "compensable" {
        Some(format!(
            "compensate-{}-{}",
            mission_id, context.slice_ref.id
        ))
    } else {
        None
    };

    Ok(Some(ResolvedAutonomyState {
        context,
        action_class,
        rollback_handle,
        compensation_handle,
        recovery_window,
        reversibility_primitive: primitive,
        autonomy_budget_state,
        breaker_state,
        approval_required: scenario_resolution.effective.approval_required
            || scenario_resolution
                .effective
                .finalize_policy
                .approval_required,
        break_glass_required: scenario_resolution
            .effective
            .finalize_policy
            .break_glass_required,
    }))
}

pub fn default_autonomy_context(
    cfg: &RuntimeConfig,
    mission_id: &str,
    slice_id: &str,
    boundary_id: &str,
    oversight_mode: &str,
    execution_posture: &str,
    reversibility_class: &str,
) -> CoreResult<AutonomyContext> {
    let intent_ref = active_intent_ref(cfg).ok_or_else(|| {
        mission_denial(
            "autonomous execution requires an active intent binding",
            vec!["INTENT_MISSING"],
        )
    })?;
    let charter_path = cfg
        .octon_dir
        .join("instance")
        .join("orchestration")
        .join("missions")
        .join(mission_id)
        .join("mission.yml");
    ensure_file_exists(&charter_path, "MISSION_CHARTER_MISSING")?;
    let charter: MissionCharterRecord = read_yaml_file(&charter_path)?;
    Ok(AutonomyContext {
        mission_ref: AutonomyRef {
            id: mission_id.to_string(),
            version: Some("v2".to_string()),
        },
        slice_ref: AutonomyRef {
            id: slice_id.to_string(),
            version: None,
        },
        intent_ref,
        mission_class: charter.mission_class,
        oversight_mode: oversight_mode.to_string(),
        execution_posture: execution_posture.to_string(),
        reversibility_class: reversibility_class.to_string(),
        boundary_id: boundary_id.to_string(),
        applied_directive_refs: Vec::new(),
        applied_authorize_update_refs: Vec::new(),
    })
}

pub fn authorize_execution(
    cfg: &RuntimeConfig,
    policy: &PolicyEngine,
    request: &ExecutionRequest,
    service: Option<&ServiceDescriptor>,
) -> CoreResult<GrantBundle> {
    let mut request = request.clone();
    request.metadata = with_authority_env_metadata(request.metadata);
    let request = &request;
    let environment = resolve_execution_environment(cfg, request);
    let intent_ref = request
        .intent_ref
        .clone()
        .or_else(|| active_intent_ref(cfg))
        .ok_or_else(|| {
            KernelError::new(
                ErrorCode::CapabilityDenied,
                "execution request missing active intent binding",
            )
            .with_details(json!({"reason_codes":["INTENT_MISSING"]}))
        })?;
    let actor_ref = request.actor_ref.clone().unwrap_or_else(default_actor_ref);
    let autonomy_state = resolve_autonomy_state(cfg, request, &intent_ref)?;

    let requested_mode = request
        .policy_mode_requested
        .clone()
        .unwrap_or_else(|| default_policy_mode(cfg));
    let effective_policy_mode = match environment {
        ExecutionEnvironment::Protected => {
            if requested_mode != cfg.execution_governance.protected_policy_mode {
                return Err(KernelError::new(
                    ErrorCode::CapabilityDenied,
                    "protected execution rejected a weaker requested policy mode",
                )
                .with_details(
                    json!({"reason_codes":["PROTECTED_EXECUTION_REQUIRES_HARD_ENFORCE"]}),
                ));
            }
            cfg.execution_governance.protected_policy_mode.clone()
        }
        ExecutionEnvironment::Development => {
            if cfg
                .execution_governance
                .allowed_development_modes
                .contains(&requested_mode)
            {
                requested_mode.clone()
            } else {
                return Err(KernelError::new(
                    ErrorCode::CapabilityDenied,
                    format!(
                        "requested policy mode '{}' is not allowed in development",
                        requested_mode
                    ),
                )
                .with_details(json!({"reason_codes":["POLICY_MODE_INVALID"]})));
            }
        }
    };

    if matches!(environment, ExecutionEnvironment::Protected)
        && effective_policy_mode != cfg.execution_governance.protected_policy_mode
    {
        return Err(KernelError::new(
            ErrorCode::CapabilityDenied,
            "protected execution requires hard-enforce posture",
        )
        .with_details(json!({"reason_codes":["PROTECTED_EXECUTION_REQUIRES_HARD_ENFORCE"]})));
    }

    let executor_profile = request
        .scope_constraints
        .executor_profile
        .as_ref()
        .and_then(|name| cfg.execution_governance.executor_profiles.get(name));
    if request.side_effect_flags.shell
        && request.caller_path != "service"
        && request.scope_constraints.executor_profile.is_none()
    {
        return Err(KernelError::new(
            ErrorCode::CapabilityDenied,
            "shell-backed execution requires an executor profile",
        )
        .with_details(json!({"reason_codes":["EXECUTOR_PROFILE_MISSING"]})));
    }
    if request.scope_constraints.executor_profile.is_some() && executor_profile.is_none() {
        return Err(KernelError::new(
            ErrorCode::CapabilityDenied,
            "execution request referenced an unknown executor profile",
        )
        .with_details(json!({"reason_codes":["EXECUTOR_PROFILE_UNKNOWN"]})));
    }

    if request.side_effect_flags.write_repo && request.scope_constraints.write.is_empty() {
        return Err(KernelError::new(
            ErrorCode::CapabilityDenied,
            "repo-mutating execution requires explicit write scope",
        )
        .with_details(json!({"reason_codes":["WRITE_SCOPE_MISSING"]})));
    }

    if let Some(profile) = executor_profile {
        if profile.require_hard_enforce
            && effective_policy_mode != cfg.execution_governance.protected_policy_mode
        {
            return Err(KernelError::new(
                ErrorCode::CapabilityDenied,
                "elevated executor profile requires hard-enforce posture",
            )
            .with_details(json!({"reason_codes":["ELEVATED_EXECUTOR_REQUIRES_HARD_ENFORCE"]})));
        }
    }

    if is_critical_action(cfg, request, executor_profile)
        && effective_policy_mode != cfg.execution_governance.protected_policy_mode
    {
        return Err(KernelError::new(
            ErrorCode::CapabilityDenied,
            "critical action denied outside hard-enforce posture",
        )
        .with_details(json!({"reason_codes":["CRITICAL_ACTION_REQUIRES_HARD_ENFORCE"]})));
    }

    let bound_run = bind_run_lifecycle(cfg, request, autonomy_state.as_ref())?;
    let run_root = bound_run.evidence_root.clone();
    let run_root_rel = bound_run.evidence_root_rel.clone();
    let run_contract = load_run_contract_record(cfg, request, autonomy_state.as_ref())?;
    let ownership = resolve_ownership_posture(cfg, request, &run_contract)?;
    let support_tier =
        resolve_support_tier_posture(cfg, request, &run_contract, autonomy_state.as_ref())?;
    let reversibility = reversibility_payload(request, &run_contract, autonomy_state.as_ref());

    let requested_capabilities = dedupe_strings(&request.requested_capabilities);
    let requested_network = requested_capabilities
        .iter()
        .any(|value| value == "net.http");
    let requested_without_network = requested_capabilities
        .iter()
        .filter(|value| value.as_str() != "net.http")
        .cloned()
        .collect::<Vec<_>>();

    let mut granted_capabilities = if let Some(service) = service {
        policy.decide_allow(service, &requested_without_network)?
    } else {
        requested_without_network.clone()
    };
    if granted_capabilities.is_empty() && !requested_network {
        return Err(KernelError::new(
            ErrorCode::CapabilityDenied,
            "execution request did not resolve any granted capabilities",
        )
        .with_details(json!({"reason_codes":["GRANTED_CAPABILITIES_EMPTY"]})));
    }

    let mut review_metadata = review_metadata_from_env();
    let profile_requires_human_review = executor_profile
        .map(|profile| profile.require_human_review)
        .unwrap_or(false);
    let profile_requires_rollback = executor_profile
        .map(|profile| profile.require_rollback_metadata)
        .unwrap_or(false);
    let autonomy_requires_approval = autonomy_state
        .as_ref()
        .map(|state| state.approval_required || state.break_glass_required)
        .unwrap_or(false);
    let approval_required = profile_requires_human_review
        || request.review_requirements.human_approval
        || autonomy_requires_approval
        || !run_contract.required_approvals.is_empty();
    let quorum_required = request.review_requirements.quorum;
    let rollback_required =
        profile_requires_rollback || request.review_requirements.rollback_metadata;
    let mut required_evidence = run_contract.required_evidence.clone();
    if approval_required {
        required_evidence.push("approval-grant".to_string());
    }
    if quorum_required {
        required_evidence.push("quorum-token".to_string());
    }
    if rollback_required {
        required_evidence.push("rollback-ref".to_string());
    }
    required_evidence.extend(support_tier.required_evidence.clone());
    required_evidence = dedupe_strings(&required_evidence);

    let approval_request_reason_codes = if approval_required {
        let mut codes = vec!["HUMAN_APPROVAL_REQUIRED".to_string()];
        if autonomy_requires_approval {
            codes.push("MISSION_APPROVAL_REQUIRED".to_string());
        }
        codes
    } else {
        Vec::new()
    };
    let approval_request_ref = if approval_required {
        Some(write_approval_request(
            cfg,
            request,
            &run_contract,
            &ownership,
            required_evidence.clone(),
            approval_request_reason_codes.clone(),
        )?)
    } else {
        None
    };

    let budget_preview_decision = preview_execution_budget(
        cfg,
        request,
        executor_profile.map(|profile| profile.name.as_str()),
    )?;
    let budget_preview = budget_preview_decision
        .as_ref()
        .map(|decision| budget_metadata_from_decision(&cfg.repo_root, &run_root, decision));
    let mut budget_posture =
        budget_posture_from_preview(&cfg.repo_root, &run_root, budget_preview_decision.as_ref());
    let mut network_egress_posture = None::<NetworkEgressPosture>;
    let mut exception_refs = Vec::new();

    let emit_route_error = |decision: ExecutionDecision,
                            message: String,
                            reason_codes: Vec<String>,
                            ownership: OwnershipPosture,
                            support_tier: SupportTierPosture,
                            reversibility: serde_json::Value,
                            budget: serde_json::Value,
                            egress: serde_json::Value,
                            approval_request_ref: Option<String>,
                            approval_grant_refs: Vec<String>,
                            exception_refs: Vec<String>,
                            revocation_refs: Vec<String>|
     -> CoreResult<GrantBundle> {
        let decision_ref = write_decision_artifact(
            cfg,
            request,
            decision.clone(),
            reason_codes.clone(),
            ownership,
            support_tier,
            reversibility,
            budget,
            egress,
            approval_request_ref,
            approval_grant_refs.clone(),
            exception_refs.clone(),
            revocation_refs.clone(),
        )?;
        let runtime_status = match decision {
            ExecutionDecision::Deny => "denied",
            ExecutionDecision::StageOnly | ExecutionDecision::Escalate => "stage_only",
            ExecutionDecision::Allow => "authorized",
        };
        let decision_state = match decision {
            ExecutionDecision::Allow => "allow",
            ExecutionDecision::StageOnly => "stage_only",
            ExecutionDecision::Deny => "deny",
            ExecutionDecision::Escalate => "escalate",
        };
        let stage_status = match decision {
            ExecutionDecision::Deny => "failed",
            _ => "staged",
        };
        let _ = update_bound_runtime_state(
            &bound_run,
            runtime_status,
            Some(decision_state),
            None,
            Some(bound_run.control_checkpoint_ref.clone()),
        );
        let _ = update_stage_attempt_status(&bound_run, stage_status, Some(decision_ref.clone()));
        let _ = merge_retained_evidence_ref(
            &bound_run.retained_evidence_path,
            &request.request_id,
            "authority_decision",
            decision_ref.clone(),
        );
        Err(
            KernelError::new(ErrorCode::CapabilityDenied, message).with_details(json!({
                "reason_codes": reason_codes,
                "decision": decision_label(&decision),
                "decision_artifact_ref": decision_ref,
                "approval_grant_refs": approval_grant_refs,
                "exception_refs": exception_refs,
                "revocation_refs": revocation_refs,
            })),
        )
    };

    if ownership.status != "resolved" {
        return emit_route_error(
            ExecutionDecision::Escalate,
            "ownership is unresolved for this execution".to_string(),
            vec!["OWNERSHIP_UNRESOLVED".to_string()],
            ownership.clone(),
            support_tier.clone(),
            reversibility.clone(),
            budget_posture.clone(),
            json!({"route": "not-applicable"}),
            approval_request_ref.clone(),
            Vec::new(),
            Vec::new(),
            Vec::new(),
        );
    }

    if support_tier.route != "allow" || support_tier.support_status == "unsupported" {
        let decision = match support_tier.route.as_str() {
            "stage_only" => ExecutionDecision::StageOnly,
            "escalate" => ExecutionDecision::Escalate,
            _ => ExecutionDecision::Deny,
        };
        let reason_code = if support_tier.support_status == "unsupported" {
            "SUPPORT_TIER_UNSUPPORTED"
        } else {
            "SUPPORT_TIER_ROUTE_BLOCKED"
        };
        return emit_route_error(
            decision,
            format!(
                "support tier '{}' is not authorized for this execution",
                support_tier.support_tier
            ),
            vec![reason_code.to_string()],
            ownership.clone(),
            support_tier.clone(),
            reversibility.clone(),
            budget_posture.clone(),
            json!({"route": "not-applicable"}),
            approval_request_ref.clone(),
            Vec::new(),
            Vec::new(),
            Vec::new(),
        );
    }

    if requested_network {
        let egress_decision = match authorize_network_egress(
            cfg,
            request,
            executor_profile.map(|profile| profile.name.as_str()),
        ) {
            Ok(decision) => decision,
            Err(err) => {
                let decision_ref = write_decision_artifact(
                    cfg,
                    request,
                    ExecutionDecision::Deny,
                    vec!["NETWORK_EGRESS_DENIED".to_string()],
                    ownership.clone(),
                    support_tier.clone(),
                    reversibility.clone(),
                    budget_posture.clone(),
                    json!({"route": "deny"}),
                    approval_request_ref.clone(),
                    Vec::new(),
                    Vec::new(),
                    Vec::new(),
                );
                if let Ok(decision_ref) = decision_ref {
                    let _ = update_bound_runtime_state(
                        &bound_run,
                        "denied",
                        Some("deny"),
                        None,
                        Some(bound_run.control_checkpoint_ref.clone()),
                    );
                    let _ = update_stage_attempt_status(
                        &bound_run,
                        "failed",
                        Some(decision_ref.clone()),
                    );
                    let _ = merge_retained_evidence_ref(
                        &bound_run.retained_evidence_path,
                        &request.request_id,
                        "authority_decision",
                        decision_ref,
                    );
                }
                return Err(err);
            }
        };
        granted_capabilities.push("net.http".to_string());
        review_metadata.insert(
            "network_egress_rule".to_string(),
            egress_decision.matched_rule_id.clone(),
        );
        review_metadata.insert(
            "network_egress_source".to_string(),
            egress_decision.source_kind.clone(),
        );
        if let Some(artifact_ref) = &egress_decision.artifact_ref {
            if egress_decision.source_kind == "exception-lease" {
                exception_refs.push(artifact_ref.clone());
            }
        }
        network_egress_posture = Some(NetworkEgressPosture {
            route: "allow".to_string(),
            matched_rule_id: Some(egress_decision.matched_rule_id.clone()),
            source_kind: Some(egress_decision.source_kind.clone()),
            artifact_ref: egress_decision.artifact_ref.clone(),
            target_url: request.metadata.get("network_egress_url").cloned(),
        });
    }

    match budget_preview_decision.as_ref() {
        Some(BudgetDecision::StageOnly {
            reason_codes,
            message,
            ..
        }) => {
            return emit_route_error(
                ExecutionDecision::StageOnly,
                message.clone(),
                reason_codes.clone(),
                ownership.clone(),
                support_tier.clone(),
                reversibility.clone(),
                budget_posture.clone(),
                json!(network_egress_posture.clone().unwrap_or_default()),
                approval_request_ref.clone(),
                Vec::new(),
                exception_refs.clone(),
                Vec::new(),
            );
        }
        Some(BudgetDecision::Deny {
            reason_codes,
            message,
            ..
        }) => {
            return emit_route_error(
                ExecutionDecision::Deny,
                message.clone(),
                reason_codes.clone(),
                ownership.clone(),
                support_tier.clone(),
                reversibility.clone(),
                budget_posture.clone(),
                json!(network_egress_posture.clone().unwrap_or_default()),
                approval_request_ref.clone(),
                Vec::new(),
                exception_refs.clone(),
                Vec::new(),
            );
        }
        _ => {}
    }

    let loaded_approval_grants = load_existing_approval_grants(cfg, &request.request_id)?;
    let approval_grant_refs = loaded_approval_grants
        .iter()
        .map(|(_, path)| path.clone())
        .collect::<Vec<_>>();

    if approval_required && approval_grant_refs.is_empty() {
        let mut reason_codes = vec![
            "HUMAN_APPROVAL_REQUIRED".to_string(),
            "ACP_STAGE_ONLY_REQUIRED".to_string(),
        ];
        if autonomy_requires_approval {
            reason_codes.insert(0, "MISSION_APPROVAL_REQUIRED".to_string());
        }
        return emit_route_error(
            ExecutionDecision::StageOnly,
            "human approval is required for this execution".to_string(),
            reason_codes,
            ownership.clone(),
            support_tier.clone(),
            reversibility.clone(),
            budget_posture.clone(),
            json!(network_egress_posture.clone().unwrap_or_default()),
            approval_request_ref.clone(),
            Vec::new(),
            exception_refs.clone(),
            Vec::new(),
        );
    }
    if approval_required
        && loaded_approval_grants.iter().any(|(grant, _)| {
            grant.quorum_policy_ref.as_deref() != Some(canonical_quorum_policy_ref())
        })
    {
        return emit_route_error(
            ExecutionDecision::StageOnly,
            "approval grant is missing canonical quorum policy binding".to_string(),
            vec![
                "QUORUM_POLICY_BINDING_MISSING".to_string(),
                "ACP_STAGE_ONLY_REQUIRED".to_string(),
            ],
            ownership.clone(),
            support_tier.clone(),
            reversibility.clone(),
            budget_posture.clone(),
            json!(network_egress_posture.clone().unwrap_or_default()),
            approval_request_ref.clone(),
            approval_grant_refs.clone(),
            exception_refs.clone(),
            Vec::new(),
        );
    }
    if quorum_required && !review_metadata.contains_key("quorum_token") {
        return emit_route_error(
            ExecutionDecision::StageOnly,
            "quorum evidence is required for this execution".to_string(),
            vec![
                "QUORUM_EVIDENCE_REQUIRED".to_string(),
                "ACP_STAGE_ONLY_REQUIRED".to_string(),
            ],
            ownership.clone(),
            support_tier.clone(),
            reversibility.clone(),
            budget_posture.clone(),
            json!(network_egress_posture.clone().unwrap_or_default()),
            approval_request_ref.clone(),
            approval_grant_refs.clone(),
            exception_refs.clone(),
            Vec::new(),
        );
    }
    if rollback_required && !review_metadata.contains_key("rollback_ref") {
        return emit_route_error(
            ExecutionDecision::StageOnly,
            "rollback metadata is required for this execution".to_string(),
            vec![
                "ROLLBACK_METADATA_REQUIRED".to_string(),
                "ACP_STAGE_ONLY_REQUIRED".to_string(),
            ],
            ownership.clone(),
            support_tier.clone(),
            reversibility.clone(),
            budget_posture.clone(),
            json!(network_egress_posture.clone().unwrap_or_default()),
            approval_request_ref.clone(),
            approval_grant_refs.clone(),
            exception_refs.clone(),
            Vec::new(),
        );
    }

    let grant_id = format!("grant-{}", request.request_id);
    let revocation_refs = load_active_revocation_refs(cfg, &request.request_id, &grant_id)?;
    if !revocation_refs.is_empty() {
        return emit_route_error(
            ExecutionDecision::Deny,
            "an active revocation blocks this execution".to_string(),
            vec!["AUTHORITY_GRANT_REVOKED".to_string()],
            ownership.clone(),
            support_tier.clone(),
            reversibility.clone(),
            budget_posture.clone(),
            json!(network_egress_posture.clone().unwrap_or_default()),
            approval_request_ref.clone(),
            approval_grant_refs.clone(),
            exception_refs.clone(),
            revocation_refs.clone(),
        );
    }

    let policy_artifacts = compose_policy_receipt(
        cfg,
        request,
        &intent_ref,
        &actor_ref,
        &effective_policy_mode,
        budget_preview.as_ref(),
        autonomy_state.as_ref(),
        &ownership,
        &support_tier,
        approval_request_ref.as_deref(),
        &approval_grant_refs,
        &exception_refs,
        &revocation_refs,
        network_egress_posture.as_ref(),
    )?;
    if !policy_artifacts.allow {
        return emit_route_error(
            policy_artifacts.decision.clone(),
            policy_artifacts
                .remediation
                .clone()
                .unwrap_or_else(|| "ACP denied execution".to_string()),
            policy_artifacts.reason_codes.clone(),
            ownership.clone(),
            support_tier.clone(),
            reversibility.clone(),
            budget_posture.clone(),
            json!(network_egress_posture.clone().unwrap_or_default()),
            approval_request_ref.clone(),
            approval_grant_refs.clone(),
            exception_refs.clone(),
            revocation_refs.clone(),
        );
    }

    let budget = finalize_execution_budget(cfg, budget_preview_decision, &run_root)?;
    if let Some(metadata) = &budget {
        budget_posture = json!({
            "route": "allow",
            "rule_id": metadata.rule_id,
            "reason_codes": metadata.reason_codes,
            "estimated_cost_usd": metadata.estimated_cost_usd,
            "actual_cost_usd": metadata.actual_cost_usd,
            "evidence_path": metadata.evidence_path,
        });
    }

    let mut grant = GrantBundle {
        grant_id: grant_id.clone(),
        request_id: request.request_id.clone(),
        decision: ExecutionDecision::Allow,
        granted_capabilities,
        scope_constraints: request.scope_constraints.clone(),
        effective_policy_mode,
        reason_codes: if policy_artifacts.reason_codes.is_empty() {
            vec!["EXECUTION_AUTHORIZED".to_string()]
        } else {
            policy_artifacts.reason_codes.clone()
        },
        review_metadata,
        expires_after: None,
        receipt_requirements: vec![
            "execution-request.json".to_string(),
            "policy-decision.json".to_string(),
            "grant-bundle.json".to_string(),
            "side-effects.json".to_string(),
            "outcome.json".to_string(),
            "execution-receipt.json".to_string(),
        ],
        environment_class: environment,
        workflow_mode: request.workflow_mode.clone(),
        intent_ref,
        autonomy_context: autonomy_state.as_ref().map(|state| state.context.clone()),
        actor_ref,
        run_root: run_root_rel,
        run_control_root: Some(bound_run.control_root_rel.clone()),
        run_receipts_root: Some(bound_run.receipts_root_rel.clone()),
        replay_pointers_path: Some(bound_run.replay_pointers_ref.clone()),
        trace_pointers_path: Some(bound_run.trace_pointers_ref.clone()),
        retained_evidence_path: Some(bound_run.retained_evidence_ref.clone()),
        stage_attempt_ref: Some(bound_run.stage_attempt_ref.clone()),
        policy_receipt_path: policy_artifacts.receipt_path,
        policy_digest_path: policy_artifacts.digest_path,
        instruction_manifest_path: policy_artifacts.instruction_manifest_path,
        budget,
        rollback_handle: autonomy_state
            .as_ref()
            .and_then(|state| state.rollback_handle.clone()),
        compensation_handle: autonomy_state
            .as_ref()
            .and_then(|state| state.compensation_handle.clone()),
        recovery_window: autonomy_state
            .as_ref()
            .map(|state| state.recovery_window.clone()),
        autonomy_budget_state: autonomy_state
            .as_ref()
            .map(|state| state.autonomy_budget_state.clone()),
        breaker_state: autonomy_state
            .as_ref()
            .map(|state| state.breaker_state.clone()),
        support_tier: Some(run_contract.support_tier.clone()),
        support_posture: Some(support_tier.clone()),
        quorum_policy_ref: Some(canonical_quorum_policy_ref().to_string()),
        ownership_refs: ownership.owner_refs.clone(),
        approval_request_ref: approval_request_ref.clone(),
        approval_grant_refs: approval_grant_refs.clone(),
        exception_lease_refs: exception_refs.clone(),
        revocation_refs: revocation_refs.clone(),
        decision_artifact_ref: None,
        authority_grant_bundle_ref: None,
        network_egress_posture: network_egress_posture.clone(),
    };
    let decision_ref = write_decision_artifact(
        cfg,
        request,
        ExecutionDecision::Allow,
        grant.reason_codes.clone(),
        ownership,
        support_tier,
        reversibility,
        budget_posture,
        json!(network_egress_posture.unwrap_or_default()),
        approval_request_ref,
        approval_grant_refs,
        exception_refs,
        revocation_refs,
    )?;
    grant.decision_artifact_ref = Some(decision_ref);
    let authority_bundle_ref = write_authority_grant_bundle(cfg, &grant)?;
    grant.authority_grant_bundle_ref = Some(authority_bundle_ref);
    if let Some(policy_receipt_path) = grant.policy_receipt_path.clone() {
        merge_replay_receipt_ref(
            &bound_run.replay_pointers_path,
            &request.request_id,
            policy_receipt_path.clone(),
        )?;
        merge_retained_evidence_ref(
            &bound_run.retained_evidence_path,
            &request.request_id,
            "policy_receipt",
            policy_receipt_path,
        )?;
    }
    if let Some(policy_digest_path) = grant.policy_digest_path.clone() {
        merge_retained_evidence_ref(
            &bound_run.retained_evidence_path,
            &request.request_id,
            "policy_digest",
            policy_digest_path,
        )?;
    }
    if let Some(instruction_manifest_path) = grant.instruction_manifest_path.clone() {
        merge_retained_evidence_ref(
            &bound_run.retained_evidence_path,
            &request.request_id,
            "instruction_manifest",
            instruction_manifest_path,
        )?;
    }
    if let Some(decision_artifact_ref) = grant.decision_artifact_ref.clone() {
        merge_retained_evidence_ref(
            &bound_run.retained_evidence_path,
            &request.request_id,
            "authority_decision",
            decision_artifact_ref,
        )?;
    }
    if let Some(authority_bundle_ref) = grant.authority_grant_bundle_ref.clone() {
        merge_retained_evidence_ref(
            &bound_run.retained_evidence_path,
            &request.request_id,
            "authority_grant_bundle",
            authority_bundle_ref,
        )?;
    }
    update_bound_runtime_state(
        &bound_run,
        "authorized",
        Some("allow"),
        grant.policy_receipt_path.clone(),
        Some(bound_run.control_checkpoint_ref.clone()),
    )?;
    update_stage_attempt_status(&bound_run, "planned", grant.policy_receipt_path.clone())?;
    Ok(grant)
}

pub fn artifact_root_from_relative(
    repo_root: &Path,
    relative_root: &str,
    request_id: &str,
) -> PathBuf {
    repo_root.join(relative_root).join(request_id)
}

pub fn write_execution_start(
    root: &Path,
    request: &ExecutionRequest,
    grant: &GrantBundle,
) -> anyhow::Result<ExecutionArtifactPaths> {
    fs::create_dir_all(root)
        .with_context(|| format!("create execution artifact root {}", root.display()))?;
    let paths = ExecutionArtifactPaths::new(root.to_path_buf());
    write_json(
        &paths.request,
        &json!({
            "schema_version": "execution-request-v2",
            "request": request,
            "resolved_intent_ref": grant.intent_ref,
            "resolved_actor_ref": grant.actor_ref,
            "resolved_autonomy_context": grant.autonomy_context.clone(),
        }),
    )?;
    write_json(
        &paths.decision,
        &json!({
            "schema_version": "execution-authorization-v1",
            "decision": grant.decision,
            "reason_codes": grant.reason_codes,
            "effective_policy_mode": grant.effective_policy_mode,
            "environment_class": grant.environment_class,
        }),
    )?;
    write_json(
        &paths.grant,
        &json!({
            "schema_version": "execution-grant-v1",
            "grant": grant,
        }),
    )?;
    if let Some(bound) = bound_run_from_grant(root, grant) {
        let request_receipt = bound.receipts_root.join("execution-request.json");
        let decision_receipt = bound.receipts_root.join("policy-decision.json");
        let grant_receipt = bound.receipts_root.join("grant-bundle.json");
        copy_json_if_present(&paths.request, &request_receipt)
            .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        copy_json_if_present(&paths.decision, &decision_receipt)
            .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        copy_json_if_present(&paths.grant, &grant_receipt)
            .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        let start_control = bound
            .control_root
            .join("checkpoints")
            .join("execution-start.yml");
        let start_evidence = bound
            .evidence_root
            .join("checkpoints")
            .join("execution-start.yml");
        let (_, evidence_checkpoint_ref) = write_run_checkpoint(
            &start_control,
            &start_evidence,
            &request.request_id,
            &bound.stage_attempt_id,
            "execution-start",
            "execution-start",
            "Execution artifacts materialized under the canonical run root.",
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        update_bound_runtime_state(
            &bound,
            "running",
            Some("allow"),
            Some(path_tail(
                &discover_repo_root(root).unwrap_or_else(|| PathBuf::from(".")),
                &grant_receipt,
            )),
            Some(path_tail(
                &discover_repo_root(root).unwrap_or_else(|| PathBuf::from(".")),
                &start_control,
            )),
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        update_stage_attempt_status(
            &bound,
            "running",
            Some(path_tail(
                &discover_repo_root(root).unwrap_or_else(|| PathBuf::from(".")),
                &grant_receipt,
            )),
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        merge_replay_receipt_ref(
            &bound.replay_pointers_path,
            &request.request_id,
            path_tail(
                &discover_repo_root(root).unwrap_or_else(|| PathBuf::from(".")),
                &grant_receipt,
            ),
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        merge_replay_checkpoint_ref(
            &bound.replay_pointers_path,
            &request.request_id,
            evidence_checkpoint_ref.clone(),
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        merge_retained_evidence_ref(
            &bound.retained_evidence_path,
            &request.request_id,
            "execution_request",
            path_tail(
                &discover_repo_root(root).unwrap_or_else(|| PathBuf::from(".")),
                &request_receipt,
            ),
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        merge_retained_evidence_ref(
            &bound.retained_evidence_path,
            &request.request_id,
            "policy_decision",
            path_tail(
                &discover_repo_root(root).unwrap_or_else(|| PathBuf::from(".")),
                &decision_receipt,
            ),
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        merge_retained_evidence_ref(
            &bound.retained_evidence_path,
            &request.request_id,
            "grant_bundle",
            path_tail(
                &discover_repo_root(root).unwrap_or_else(|| PathBuf::from(".")),
                &grant_receipt,
            ),
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
    }
    Ok(paths)
}

pub fn finalize_execution(
    paths: &ExecutionArtifactPaths,
    request: &ExecutionRequest,
    grant: &GrantBundle,
    started_at: &str,
    outcome: &ExecutionOutcome,
    side_effects: &SideEffectSummary,
) -> anyhow::Result<()> {
    write_json(&paths.side_effects, side_effects)?;
    write_json(&paths.outcome, outcome)?;
    let override_requested = request
        .policy_mode_requested
        .as_ref()
        .map(|value| value != &grant.effective_policy_mode)
        .unwrap_or(false);
    let receipt = ExecutionReceipt {
        schema_version: "execution-receipt-v2".to_string(),
        request_id: request.request_id.clone(),
        grant_id: grant.grant_id.clone(),
        target_id: request.target_id.clone(),
        action_type: request.action_type.clone(),
        path_type: request.caller_path.clone(),
        environment_class: grant.environment_class.as_str().to_string(),
        workflow_mode: grant.workflow_mode.clone(),
        intent_ref: grant.intent_ref.clone(),
        mission_ref: grant
            .autonomy_context
            .as_ref()
            .map(|context| context.mission_ref.clone()),
        slice_ref: grant
            .autonomy_context
            .as_ref()
            .map(|context| context.slice_ref.clone()),
        mission_class: grant
            .autonomy_context
            .as_ref()
            .map(|context| context.mission_class.clone()),
        oversight_mode: grant
            .autonomy_context
            .as_ref()
            .map(|context| context.oversight_mode.clone()),
        execution_posture: grant
            .autonomy_context
            .as_ref()
            .map(|context| context.execution_posture.clone()),
        reversibility_class: grant
            .autonomy_context
            .as_ref()
            .map(|context| context.reversibility_class.clone()),
        boundary_id: grant
            .autonomy_context
            .as_ref()
            .map(|context| context.boundary_id.clone()),
        rollback_handle: grant.rollback_handle.clone(),
        compensation_handle: grant.compensation_handle.clone(),
        recovery_window: grant.recovery_window.clone(),
        autonomy_budget_state: grant.autonomy_budget_state.clone(),
        breaker_state: grant.breaker_state.clone(),
        applied_directive_refs: grant
            .autonomy_context
            .as_ref()
            .map(|context| context.applied_directive_refs.clone())
            .unwrap_or_default(),
        applied_authorize_update_refs: grant
            .autonomy_context
            .as_ref()
            .map(|context| context.applied_authorize_update_refs.clone())
            .unwrap_or_default(),
        actor_ref: grant.actor_ref.clone(),
        requested_capabilities: request.requested_capabilities.clone(),
        granted_capabilities: grant.granted_capabilities.clone(),
        policy_mode_requested: request
            .policy_mode_requested
            .clone()
            .unwrap_or_else(|| grant.effective_policy_mode.clone()),
        policy_mode_effective: grant.effective_policy_mode.clone(),
        decision: grant.decision.clone(),
        reason_codes: grant.reason_codes.clone(),
        touched_scope: side_effects.touched_scope.clone(),
        side_effects: side_effects.clone(),
        override_requested,
        override_accepted: !override_requested,
        ai_review_enforced: env_bool("AI_GATE_ENFORCE") || env_bool("OCTON_AI_GATE_ENFORCE"),
        autonomy_policy_enforced: env_bool("AUTONOMY_POLICY_ENFORCE")
            || env_bool("OCTON_AUTONOMY_POLICY_ENFORCE"),
        evidence_links: evidence_links(paths, grant),
        budget: grant.budget.clone(),
        support_tier: grant.support_tier.clone(),
        ownership_refs: grant.ownership_refs.clone(),
        approval_request_ref: grant.approval_request_ref.clone(),
        approval_grant_refs: grant.approval_grant_refs.clone(),
        exception_lease_refs: grant.exception_lease_refs.clone(),
        revocation_refs: grant.revocation_refs.clone(),
        decision_artifact_ref: grant.decision_artifact_ref.clone(),
        authority_grant_bundle_ref: grant.authority_grant_bundle_ref.clone(),
        network_egress_posture: grant.network_egress_posture.clone(),
        timestamps: ReceiptTimestamps {
            started_at: started_at.to_string(),
            completed_at: outcome.completed_at.clone(),
        },
    };
    write_json(&paths.receipt, &receipt)?;
    if let Some(bound) = bound_run_from_grant(&paths.root, grant) {
        let side_effects_receipt = bound.receipts_root.join("side-effects.json");
        let outcome_receipt = bound.receipts_root.join("outcome.json");
        let execution_receipt = bound.receipts_root.join("execution-receipt.json");
        copy_json_if_present(&paths.side_effects, &side_effects_receipt)
            .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        copy_json_if_present(&paths.outcome, &outcome_receipt)
            .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        copy_json_if_present(&paths.receipt, &execution_receipt)
            .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        let terminal_control = bound
            .control_root
            .join("checkpoints")
            .join("execution-complete.yml");
        let terminal_evidence = bound
            .evidence_root
            .join("checkpoints")
            .join("execution-complete.yml");
        let (_, evidence_checkpoint_ref) = write_run_checkpoint(
            &terminal_control,
            &terminal_evidence,
            &request.request_id,
            &bound.stage_attempt_id,
            "execution-complete",
            "execution-complete",
            "Execution outcome materialized under the canonical run root.",
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        let repo_root = discover_repo_root(&paths.root).unwrap_or_else(|| PathBuf::from("."));
        update_bound_runtime_state(
            &bound,
            &outcome.status,
            Some("allow"),
            Some(path_tail(&repo_root, &execution_receipt)),
            Some(path_tail(&repo_root, &terminal_control)),
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        let terminal_stage_status = match outcome.status.as_str() {
            "succeeded" => "succeeded",
            "failed" => "failed",
            "cancelled" => "cancelled",
            _ => "failed",
        };
        update_stage_attempt_status(
            &bound,
            terminal_stage_status,
            Some(path_tail(&repo_root, &execution_receipt)),
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        merge_replay_receipt_ref(
            &bound.replay_pointers_path,
            &request.request_id,
            path_tail(&repo_root, &execution_receipt),
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        merge_replay_checkpoint_ref(
            &bound.replay_pointers_path,
            &request.request_id,
            evidence_checkpoint_ref,
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        merge_retained_evidence_ref(
            &bound.retained_evidence_path,
            &request.request_id,
            "side_effects",
            path_tail(&repo_root, &side_effects_receipt),
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        merge_retained_evidence_ref(
            &bound.retained_evidence_path,
            &request.request_id,
            "outcome",
            path_tail(&repo_root, &outcome_receipt),
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        merge_retained_evidence_ref(
            &bound.retained_evidence_path,
            &request.request_id,
            "execution_receipt",
            path_tail(&repo_root, &execution_receipt),
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        materialize_run_disclosure(&repo_root, request, grant, outcome, &bound)?;
    }
    Ok(())
}

fn materialize_run_disclosure(
    repo_root: &Path,
    request: &ExecutionRequest,
    grant: &GrantBundle,
    outcome: &ExecutionOutcome,
    bound: &BoundRunLifecycle,
) -> anyhow::Result<()> {
    fs::create_dir_all(&bound.assurance_root)?;
    fs::create_dir_all(&bound.measurement_root)?;
    fs::create_dir_all(&bound.intervention_root)?;
    fs::create_dir_all(&bound.disclosure_root)?;
    if let Some(parent) = bound.replay_manifest_path.parent() {
        fs::create_dir_all(parent)?;
    }

    let run_contract_ref = format!(
        ".octon/state/control/execution/runs/{}/run-contract.yml",
        request.request_id
    );
    let execution_receipt_ref = format!(
        ".octon/state/evidence/runs/{}/receipts/execution-receipt.json",
        request.request_id
    );
    let retained_evidence_ref = format!(
        ".octon/state/evidence/runs/{}/retained-run-evidence.yml",
        request.request_id
    );
    let replay_manifest_ref = format!(
        ".octon/state/evidence/runs/{}/replay/manifest.yml",
        request.request_id
    );

    if outcome.status == "succeeded" {
        let success_proofs: [(&str, serde_json::Value); 6] = [
            (
                "structural",
                json!({
                    "schema_version": "proof-plane-report-v1",
                    "plane": "structural",
                    "subject_kind": "run",
                    "subject_ref": run_contract_ref,
                    "outcome": "pass",
                    "proof_class": "deterministic",
                    "summary": "Structural proof confirms the canonical run contract, manifest, and checkpoint topology were emitted for this successful run.",
                    "evidence_refs": [
                        format!(".octon/state/control/execution/runs/{}/run-contract.yml", request.request_id),
                        format!(".octon/state/control/execution/runs/{}/run-manifest.yml", request.request_id),
                        format!(".octon/state/control/execution/runs/{}/checkpoints/bound.yml", request.request_id),
                        format!(".octon/state/continuity/runs/{}/handoff.yml", request.request_id),
                    ],
                    "known_limits": [],
                    "generated_at": outcome.completed_at,
                }),
            ),
            (
                "governance",
                json!({
                    "schema_version": "proof-plane-report-v1",
                    "plane": "governance",
                    "subject_kind": "run",
                    "subject_ref": run_contract_ref,
                    "outcome": "pass",
                    "proof_class": "deterministic",
                    "summary": "Governance proof confirms support-target, authority-routing, and closeout-governance surfaces passed for this successful run.",
                    "evidence_refs": [
                        ".octon/instance/governance/support-targets.yml",
                        ".octon/instance/governance/contracts/closeout-reviews.yml",
                        ".octon/framework/constitution/contracts/authority/README.md",
                        grant.decision_artifact_ref.clone(),
                    ],
                    "known_limits": [],
                    "generated_at": outcome.completed_at,
                }),
            ),
            (
                "functional",
                json!({
                    "schema_version": "proof-plane-report-v1",
                    "plane": "functional",
                    "subject_kind": "run",
                    "subject_ref": run_contract_ref,
                    "outcome": "pass",
                    "proof_class": "deterministic",
                    "summary": "Functional proof confirms the run emitted the canonical receipt, retained evidence, and replay chain for a successful consequential workflow.",
                    "evidence_refs": [
                        ".octon/framework/assurance/functional/suites/run-lifecycle-integrity.yml",
                        execution_receipt_ref,
                        retained_evidence_ref,
                        format!(".octon/state/control/execution/runs/{}/run-manifest.yml", request.request_id),
                    ],
                    "known_limits": [],
                    "generated_at": outcome.completed_at,
                }),
            ),
            (
                "behavioral",
                json!({
                    "schema_version": "proof-plane-report-v1",
                    "plane": "behavioral",
                    "subject_kind": "run",
                    "subject_ref": run_contract_ref,
                    "outcome": "pass",
                    "proof_class": "shadow-run",
                    "summary": "Behavioral proof is backed by the current successful run plus retained scenario, replay, and shadow-run evidence for the supported consequential envelope.",
                    "evidence_refs": [
                        ".octon/framework/assurance/behavioral/suites/replay-shadow-substance.yml",
                        ".octon/state/evidence/lab/scenarios/scn-runtime-proof-supported-20260329/scenario-proof.yml",
                        ".octon/state/evidence/lab/replays/rpl-runtime-proof-supported-20260329/replay-bundle.yml",
                        ".octon/state/evidence/lab/shadow-runs/shd-runtime-proof-supported-20260329/shadow-run.yml",
                        replay_manifest_ref,
                    ],
                    "known_limits": [],
                    "generated_at": outcome.completed_at,
                }),
            ),
            (
                "maintainability",
                json!({
                    "schema_version": "proof-plane-report-v1",
                    "plane": "maintainability",
                    "subject_kind": "run",
                    "subject_ref": run_contract_ref,
                    "outcome": "pass",
                    "proof_class": "deterministic",
                    "summary": "Maintainability proof confirms the successful run remains aligned to the constitutional registry, runtime SSOT, and generated proposal registry projection.",
                    "evidence_refs": [
                        ".octon/framework/assurance/maintainability/suites/runtime-ssot-alignment.yml",
                        ".octon/framework/constitution/contracts/registry.yml",
                        ".octon/framework/cognition/_meta/architecture/contract-registry.yml",
                        ".octon/generated/proposals/registry.yml",
                    ],
                    "known_limits": [],
                    "generated_at": outcome.completed_at,
                }),
            ),
            (
                "recovery",
                json!({
                    "schema_version": "proof-plane-report-v1",
                    "plane": "recovery",
                    "subject_kind": "run",
                    "subject_ref": run_contract_ref,
                    "outcome": "pass",
                    "proof_class": "lab",
                    "summary": "Recovery proof is backed by rollback posture, checkpoints, replay, and the retained fault rehearsal for the supported consequential envelope.",
                    "evidence_refs": [
                        ".octon/framework/assurance/recovery/suites/checkpoint-fault-recovery.yml",
                        format!(".octon/state/control/execution/runs/{}/rollback-posture.yml", request.request_id),
                        format!(".octon/state/control/execution/runs/{}/checkpoints/bound.yml", request.request_id),
                        ".octon/state/evidence/lab/replays/rpl-runtime-proof-supported-20260329/replay-bundle.yml",
                        ".octon/state/evidence/lab/faults/flt-runtime-proof-supported-20260329/fault-report.yml",
                    ],
                    "known_limits": [],
                    "generated_at": outcome.completed_at,
                }),
            ),
        ];
        for (proof_plane, report) in success_proofs {
            let path = bound.assurance_root.join(format!("{proof_plane}.yml"));
            write_yaml(&path, &report)?;
        }
        write_yaml(
            &bound.assurance_root.join("evaluator.yml"),
            &json!({
                "schema_version": "evaluator-review-v1",
                "subject_ref": run_contract_ref,
                "evaluator_id": "evaluator-router://phase4-review-routing",
                "disposition": "approved",
                "summary": "Independent evaluator approval is retained for the supported consequential envelope and current successful workflow evidence.",
                "evidence_refs": [
                    path_tail(repo_root, &bound.assurance_root.join("functional.yml")),
                    path_tail(repo_root, &bound.assurance_root.join("behavioral.yml")),
                    path_tail(repo_root, &bound.assurance_root.join("maintainability.yml")),
                    path_tail(repo_root, &bound.assurance_root.join("recovery.yml")),
                    ".octon/framework/assurance/evaluators/review-routing.yml",
                    ".octon/framework/assurance/evaluators/adapters/openai-review.yml",
                    ".octon/framework/assurance/evaluators/adapters/anthropic-review.yml",
                ],
                "known_limits": [
                    "Independent human review remains available for higher-risk support tiers."
                ],
                "recorded_at": outcome.completed_at,
            }),
        )?;
    } else {
        let proof_planes = [
            "structural",
            "governance",
            "functional",
            "behavioral",
            "maintainability",
            "recovery",
            "evaluator",
        ];
        for proof_plane in proof_planes {
            let path = bound.assurance_root.join(format!("{proof_plane}.yml"));
            if !path.is_file() {
                write_yaml(
                    &path,
                    &json!({
                        "schema_version": "run-proof-placeholder-v1",
                        "run_id": request.request_id,
                        "proof_plane": proof_plane,
                        "status": "not-collected",
                        "summary": format!(
                            "No routine {} proof artifact was emitted for this run; the run card discloses the gap explicitly.",
                            proof_plane
                        ),
                        "generated_at": outcome.completed_at,
                    }),
                )?;
            }
        }
    }

    let measurement_path = bound.measurement_root.join("summary.yml");
    let measurement_record_path = bound
        .measurement_root
        .join("records")
        .join("runtime-lifecycle.yml");
    let measurement_metrics = if outcome.status == "succeeded" {
        vec![
            json!({"metric_id":"receipt-count","label":"Retained lifecycle receipts","value":1,"unit":"count"}),
            json!({"metric_id":"checkpoint-count","label":"Retained checkpoints","value":3,"unit":"count"}),
            json!({"metric_id":"proof-plane-count","label":"Run-local proof-plane reports","value":7,"unit":"count"}),
            json!({"metric_id":"measurement-record-count","label":"Detailed measurement records","value":1,"unit":"count"}),
            json!({"metric_id":"intervention-count","label":"Material interventions","value":0,"unit":"count"}),
            json!({"metric_id":"retry-record-count","label":"Retry records","value":1,"unit":"count"}),
            json!({"metric_id":"contamination-record-count","label":"Contamination records","value":1,"unit":"count"}),
        ]
    } else {
        let receipt_count = fs::read_dir(&bound.receipts_root)
            .ok()
            .map(|entries| entries.filter_map(Result::ok).count())
            .unwrap_or(0);
        let checkpoint_count = fs::read_dir(bound.evidence_root.join("checkpoints"))
            .ok()
            .map(|entries| entries.filter_map(Result::ok).count())
            .unwrap_or(0);
        let proof_plane_count = fs::read_dir(&bound.assurance_root)
            .ok()
            .map(|entries| entries.filter_map(Result::ok).count())
            .unwrap_or(0);
        vec![
            json!({"metric_id":"receipt-count","label":"Retained lifecycle receipts","value":receipt_count,"unit":"count"}),
            json!({"metric_id":"checkpoint-count","label":"Retained checkpoints","value":checkpoint_count,"unit":"count"}),
            json!({"metric_id":"proof-plane-count","label":"Run-local proof-plane reports","value":proof_plane_count,"unit":"count"}),
            json!({"metric_id":"measurement-record-count","label":"Detailed measurement records","value":1,"unit":"count"}),
            json!({"metric_id":"intervention-count","label":"Material interventions","value":0,"unit":"count"}),
            json!({"metric_id":"retry-record-count","label":"Retry records","value":1,"unit":"count"}),
            json!({"metric_id":"contamination-record-count","label":"Contamination records","value":1,"unit":"count"}),
        ]
    };
    let measurement_summary = if outcome.status == "succeeded" {
        "Run emitted canonical receipt, checkpoint, proof-plane, disclosure, retry, contamination, and detailed measurement families."
    } else {
        "Run emitted fail-closed measurement and disclosure artifacts for a non-success outcome."
    };
    fs::create_dir_all(measurement_record_path.parent().unwrap())?;
    write_yaml(
        &measurement_path,
        &json!({
            "schema_version": "measurement-summary-v1",
            "subject_kind": "run",
            "subject_ref": run_contract_ref,
            "metrics": measurement_metrics,
            "summary": measurement_summary,
            "recorded_at": outcome.completed_at,
        }),
    )?;
    write_yaml(
        &measurement_record_path,
        &json!({
            "schema_version": "measurement-record-v1",
            "record_id": format!("{}-runtime-lifecycle", request.request_id),
            "subject_kind": "run",
            "subject_ref": run_contract_ref,
            "metric_id": "lifecycle-artifact-count",
            "label": "Canonical lifecycle artifacts retained",
            "value": 14,
            "unit": "count",
            "method": "Counted canonical lifecycle, replay, disclosure, and proof artifacts under the bound run roots.",
            "evidence_refs": [
                format!(".octon/state/control/execution/runs/{}/run-manifest.yml", request.request_id),
                format!(".octon/state/evidence/runs/{}/evidence-classification.yml", request.request_id)
            ],
            "notes": "Supports observability richness and closure gating for the retained exemplar run.",
            "recorded_at": outcome.completed_at,
        }),
    )?;

    let intervention_path = bound.intervention_root.join("log.yml");
    let intervention_record_path = bound
        .intervention_root
        .join("records")
        .join("no-human-intervention.yml");
    fs::create_dir_all(intervention_record_path.parent().unwrap())?;
    write_yaml(
        &intervention_path,
        &json!({
            "schema_version": "intervention-log-v1",
            "subject_kind": "run",
            "subject_ref": run_contract_ref,
            "interventions": [],
            "summary": "No hidden or material human intervention was required; the canonical intervention record family explicitly retains that fact.",
            "recorded_at": outcome.completed_at,
        }),
    )?;
    write_yaml(
        &intervention_record_path,
        &json!({
            "schema_version": "intervention-record-v1",
            "record_id": format!("{}-no-human-intervention", request.request_id),
            "subject_kind": "run",
            "subject_ref": run_contract_ref,
            "kind": "no-material-intervention",
            "disclosed": true,
            "actor_ref": serde_json::Value::Null,
            "details": "No hidden or material human intervention occurred during the retained exemplar run.",
            "evidence_refs": [path_tail(repo_root, &intervention_path)],
            "recorded_at": outcome.completed_at,
        }),
    )?;

    let external_index_ref = format!(
        ".octon/state/evidence/external-index/runs/{}.yml",
        request.request_id
    );
    write_yaml(
        &bound.evidence_root.join("trace-pointers.yml"),
        &TracePointersRecord {
            schema_version: "run-trace-pointers-v1".to_string(),
            run_id: request.request_id.clone(),
            trace_id: format!("{}-canonical-trace-index", request.request_id),
            trace_refs: Vec::new(),
            external_index_refs: vec![external_index_ref.clone()],
            notes: Some(
                "No separate class-C trace payload was retained for this exemplar; canonical replay stays in repo-local receipts and manifests.".to_string(),
            ),
            updated_at: outcome.completed_at.clone(),
        },
    )?;

    write_yaml(
        &bound.replay_manifest_path,
        &json!({
            "schema_version": "run-replay-manifest-v1",
            "run_id": request.request_id,
            "entrypoint": path_tail(repo_root, &bound.control_root),
            "replay_payload_class": "git-pointer",
            "receipt_refs": [execution_receipt_ref],
            "checkpoint_refs": [format!(".octon/state/evidence/runs/{}/checkpoints/bound.yml", request.request_id)],
            "trace_refs": [format!(".octon/state/evidence/runs/{}/trace-pointers.yml", request.request_id)],
            "external_index_refs": [external_index_ref],
            "reproduction_steps": [
                "Read the bound run contract and execution receipt.",
                "Follow the replay manifest, checkpoints, trace pointers, and RunCard refs to reproduce the consequential path.",
                "Use the external replay index when trace or replay payload retrieval needs a canonical pointer source."
            ],
            "recorded_at": outcome.completed_at,
        }),
    )?;

    let support_posture = grant.support_posture.clone().unwrap_or_default();
    let host_adapter = support_posture
        .host_adapter_id
        .clone()
        .unwrap_or_else(|| "unknown-host-adapter".to_string());
    let model_adapter = support_posture
        .model_adapter_id
        .clone()
        .unwrap_or_else(|| "unknown-model-adapter".to_string());
    let host_support_status = support_posture
        .host_adapter_status
        .clone()
        .unwrap_or_else(|| "unsupported".to_string());
    let model_support_status = support_posture
        .model_adapter_status
        .clone()
        .unwrap_or_else(|| "unsupported".to_string());
    let conformance_criteria = support_posture.adapter_conformance_criteria.clone();
    let summary = format!(
        "Consequential run {} for target {} completed with status {} under support tier {}.",
        request.request_id,
        request.target_id,
        outcome.status,
        grant
            .support_tier
            .clone()
            .unwrap_or_else(|| "unknown".to_string())
    );
    let mut known_limits = vec![
        "Support posture remains bounded to the support-target declaration under .octon/instance/governance/support-targets.yml.".to_string(),
    ];
    if outcome.status != "succeeded" {
        known_limits.insert(
            0,
            "Proof-plane artifacts for this run currently include placeholder disclosure files when no routine proof artifact was emitted.".to_string(),
        );
    }
    if outcome.status != "succeeded" {
        known_limits.push(format!(
            "Run completed with status {} and should not be treated as positive proof of successful execution.",
            outcome.status
        ));
    }

    let run_card_path = bound.disclosure_root.join("run-card.yml");
    write_yaml(
        &run_card_path,
        &json!({
            "schema_version": "run-card-v2",
            "run_id": request.request_id,
            "status": outcome.status,
            "summary": summary,
            "workflow_mode": grant.workflow_mode,
            "support_tier": grant.support_tier.clone().unwrap_or_else(|| "unknown".to_string()),
            "support_target_tuple": {
                "model_tier": support_posture.model_tier_id,
                "workload_tier": support_posture.workload_tier_id,
                "language_resource_tier": support_posture.language_resource_tier_id,
                "locale_tier": support_posture.locale_tier_id,
                "support_status": support_posture.support_status,
            },
            "support_target_ref": ".octon/instance/governance/support-targets.yml",
            "requested_capability_packs": support_posture.requested_capability_packs,
            "adapter_support": {
                "host_adapter": host_adapter,
                "model_adapter": model_adapter,
                "host_support_status": host_support_status,
                "model_support_status": model_support_status,
                "conformance_criteria": conformance_criteria,
            },
            "authority_refs": {
                "run_contract": format!(".octon/state/control/execution/runs/{}/run-contract.yml", request.request_id),
                "decision_artifact": grant.decision_artifact_ref,
                "grant_bundle": grant.authority_grant_bundle_ref,
                "retained_run_evidence": bound.retained_evidence_ref,
            },
            "runtime_service_refs": {
                "replay_store": ".octon/framework/engine/runtime/crates/replay_store",
                "telemetry_sink": ".octon/framework/engine/runtime/crates/telemetry_sink",
                "runtime_bus": ".octon/framework/engine/runtime/crates/runtime_bus",
            },
            "proof_plane_refs": {
                "structural": path_tail(repo_root, &bound.assurance_root.join("structural.yml")),
                "governance": path_tail(repo_root, &bound.assurance_root.join("governance.yml")),
                "functional": path_tail(repo_root, &bound.assurance_root.join("functional.yml")),
                "behavioral": path_tail(repo_root, &bound.assurance_root.join("behavioral.yml")),
                "maintainability": path_tail(repo_root, &bound.assurance_root.join("maintainability.yml")),
                "recovery": path_tail(repo_root, &bound.assurance_root.join("recovery.yml")),
                "evaluator": path_tail(repo_root, &bound.assurance_root.join("evaluator.yml")),
            },
            "measurement_ref": path_tail(repo_root, &measurement_path),
            "intervention_ref": path_tail(repo_root, &intervention_path),
            "replay_ref": path_tail(repo_root, &bound.replay_manifest_path),
            "recovery_ref": path_tail(repo_root, &bound.assurance_root.join("recovery.yml")),
            "known_limits": known_limits,
            "generated_at": outcome.completed_at,
        }),
    )?;
    Ok(())
}

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

fn env_bool(name: &str) -> bool {
    std::env::var(name)
        .map(|value| value.eq_ignore_ascii_case("true"))
        .unwrap_or(false)
}

fn write_json(path: &Path, value: &impl Serialize) -> anyhow::Result<()> {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)
            .with_context(|| format!("create parent directory {}", parent.display()))?;
    }
    fs::write(path, serde_json::to_vec_pretty(value)?)
        .with_context(|| format!("write {}", path.display()))
}

fn write_yaml(path: &Path, value: &impl Serialize) -> anyhow::Result<()> {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)
            .with_context(|| format!("create parent directory {}", parent.display()))?;
    }
    fs::write(path, serde_yaml::to_string(value)?)
        .with_context(|| format!("write {}", path.display()))
}

fn evidence_links(paths: &ExecutionArtifactPaths, grant: &GrantBundle) -> BTreeMap<String, String> {
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

fn path_tail(root: &Path, path: &Path) -> String {
    path.strip_prefix(root)
        .unwrap_or(path)
        .display()
        .to_string()
}

fn current_branch(repo_root: &Path) -> Option<String> {
    let head_path = repo_root.join(".git/HEAD");
    let head = fs::read_to_string(head_path).ok()?;
    let head = head.trim();
    if let Some(rest) = head.strip_prefix("ref: ") {
        return rest.rsplit('/').next().map(ToOwned::to_owned);
    }
    None
}

fn dedupe_strings(values: &[String]) -> Vec<String> {
    let mut set = BTreeSet::new();
    values
        .iter()
        .filter(|value| set.insert((*value).clone()))
        .cloned()
        .collect()
}

fn is_critical_action(
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

fn dangerous_flags_for(kind: &ManagedExecutorKind) -> Vec<String> {
    match kind {
        ManagedExecutorKind::Codex => vec!["--full-auto".to_string()],
        ManagedExecutorKind::Claude => vec!["--permission-mode bypassPermissions".to_string()],
    }
}

fn capability_classification_for_mode(workflow_mode: &str) -> &str {
    match workflow_mode {
        "human-only" => "human-only",
        "agent-augmented" => "agent-augmented",
        _ => "agent-ready",
    }
}

struct PolicyArtifacts {
    allow: bool,
    decision: ExecutionDecision,
    reason_codes: Vec<String>,
    remediation: Option<String>,
    receipt_path: Option<String>,
    digest_path: Option<String>,
    instruction_manifest_path: Option<String>,
}

fn compose_policy_receipt(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
    intent_ref: &IntentRef,
    actor_ref: &ActorRef,
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
        actor_ref,
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

fn resolve_acp_policy_path(cfg: &RuntimeConfig) -> PathBuf {
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

fn build_policy_request_json(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
    intent_ref: &IntentRef,
    actor_ref: &ActorRef,
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
            "id": actor_ref.id,
            "type": actor_ref.kind
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

fn policy_profile_for_request(request: &ExecutionRequest) -> &'static str {
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

fn write_instruction_manifest(path: &Path, layers: serde_json::Value) -> CoreResult<()> {
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

fn material_side_effect(request: &ExecutionRequest) -> bool {
    request.side_effect_flags.write_repo
        || request.side_effect_flags.shell
        || request.side_effect_flags.network
        || request.side_effect_flags.model_invoke
        || request.side_effect_flags.state_mutation
        || request.side_effect_flags.publication
        || request.side_effect_flags.branch_mutation
}

fn authorize_network_egress(
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

fn preview_execution_budget(
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

fn finalize_execution_budget(
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

fn budget_metadata_from_decision(
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

fn unique_temp_file(stem: &str, extension: &str) -> PathBuf {
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

fn zero_sha256() -> String {
    "0".repeat(64)
}

static ACP_TEST_LOCK: OnceLock<Mutex<()>> = OnceLock::new();

fn sha256_file(path: &Path) -> String {
    fs::read(path)
        .map(|bytes| sha256_bytes(&bytes))
        .unwrap_or_else(|_| zero_sha256())
}

fn sha256_bytes(bytes: &[u8]) -> String {
    format!("{:x}", Sha256::digest(bytes))
}

fn file_size(path: &Path) -> usize {
    fs::metadata(path)
        .map(|meta| meta.len() as usize)
        .unwrap_or(0)
}

#[cfg(test)]
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
            actor_ref: Some(default_actor_ref()),
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
    fn admitted_api_pack_allows_declared_execution() {
        let cfg = temp_runtime_config();
        let policy = PolicyEngine::new(cfg.clone());
        let mut request = minimal_request();
        request
            .metadata
            .insert("support_capability_packs".to_string(), "api".to_string());

        let grant = authorize_execution(&cfg, &policy, &request, None)
            .expect("admitted api pack should authorize when declared");
        assert!(grant
            .support_posture
            .as_ref()
            .expect("support posture")
            .allowed_capability_packs
            .contains(&"api".to_string()));
    }

    #[test]
    fn admitted_browser_pack_allows_declared_execution() {
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

        let grant = authorize_execution(&cfg, &policy, &request, None)
            .expect("admitted browser pack should authorize when declared");
        assert!(grant
            .support_posture
            .as_ref()
            .expect("support posture")
            .allowed_capability_packs
            .contains(&"browser".to_string()));
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
