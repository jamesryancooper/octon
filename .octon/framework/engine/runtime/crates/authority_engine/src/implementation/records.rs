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

#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct MissionCharterRecord {
    pub(crate) mission_id: String,
    pub(crate) mission_class: String,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct MissionLeaseRecord {
    #[serde(default)]
    pub(crate) state: String,
    #[serde(default)]
    pub(crate) expires_at: String,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct MissionAutonomyBudgetRecord {
    pub(crate) state: String,
}

#[allow(dead_code)]
#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct MissionModeStateRecord {
    #[serde(default)]
    pub(crate) oversight_mode: String,
    #[serde(default)]
    pub(crate) execution_posture: String,
    #[serde(default)]
    pub(crate) safety_state: String,
    #[serde(default)]
    pub(crate) phase: String,
    #[serde(default)]
    pub(crate) effective_scenario_resolution_ref: Option<String>,
    #[serde(default)]
    pub(crate) autonomy_burn_state: String,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct MissionCircuitBreakersRecord {
    #[serde(default)]
    pub(crate) state: Option<String>,
    #[serde(default)]
    pub(crate) tripped_breakers: Vec<String>,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct MissionScheduleRecord {
    #[serde(default)]
    pub(crate) suspended_future_runs: bool,
    #[serde(default)]
    pub(crate) pause_active_run_requested: bool,
}

#[allow(dead_code)]
#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct ScenarioResolutionRecord {
    #[serde(default)]
    pub(crate) mission_id: String,
    #[serde(default)]
    pub(crate) generated_at: String,
    #[serde(default)]
    pub(crate) fresh_until: String,
    #[serde(default)]
    pub(crate) effective: ScenarioResolutionEffective,
}

#[allow(dead_code)]
#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct ScenarioResolutionEffective {
    #[serde(default)]
    pub(crate) oversight_mode: String,
    #[serde(default)]
    pub(crate) execution_posture: String,
    #[serde(default)]
    pub(crate) proceed_on_silence_allowed: bool,
    #[serde(default)]
    pub(crate) approval_required: bool,
    #[serde(default)]
    pub(crate) safe_interrupt_boundary_class: String,
    #[serde(default)]
    pub(crate) recovery_profile: ScenarioRecoveryProfile,
    #[serde(default)]
    pub(crate) finalize_policy: ScenarioFinalizePolicy,
}

#[allow(dead_code)]
#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct ScenarioRecoveryProfile {
    #[serde(default)]
    pub(crate) action_class: String,
    #[serde(default)]
    pub(crate) primitive: String,
    #[serde(default)]
    pub(crate) rollback_handle_type: String,
    #[serde(default)]
    pub(crate) recovery_window: String,
    #[serde(default)]
    pub(crate) reversibility_class: String,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct ScenarioFinalizePolicy {
    #[serde(default)]
    pub(crate) approval_required: bool,
    #[serde(default)]
    pub(crate) block_finalize: bool,
    #[serde(default)]
    pub(crate) break_glass_required: bool,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct RunContractRecord {
    #[serde(default)]
    pub(crate) support_tier: String,
    #[serde(default)]
    pub(crate) support_target: SupportTargetTuple,
    #[serde(default)]
    pub(crate) support_target_admission_ref: String,
    #[serde(default)]
    pub(crate) requested_capability_packs: Vec<String>,
    #[serde(default)]
    pub(crate) intent_ref: Option<IntentRef>,
    #[serde(default)]
    pub(crate) execution_role_ref: Option<ExecutionRoleRef>,
    #[serde(default)]
    pub(crate) required_approvals: Vec<String>,
    #[serde(default)]
    pub(crate) required_evidence: Vec<String>,
    #[serde(default)]
    pub(crate) reversibility_class: String,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct OwnershipRegistryRecord {
    #[serde(default)]
    pub(crate) operators: Vec<OwnershipOperatorRecord>,
    #[serde(default)]
    pub(crate) assets: Vec<OwnershipAssetRecord>,
    #[serde(default)]
    pub(crate) services: Vec<OwnershipServiceRecord>,
    #[serde(default)]
    pub(crate) defaults: OwnershipDefaultsRecord,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct OwnershipOperatorRecord {
    pub(crate) operator_id: String,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct OwnershipDefaultsRecord {
    #[serde(default)]
    pub(crate) operator_id: Option<String>,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct OwnershipAssetRecord {
    #[serde(default)]
    pub(crate) asset_id: Option<String>,
    #[serde(default)]
    pub(crate) path_globs: Vec<String>,
    #[serde(default)]
    pub(crate) owners: Vec<String>,
    #[serde(default)]
    pub(crate) support_tier: Option<String>,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct OwnershipServiceRecord {
    #[serde(default)]
    pub(crate) service_id: Option<String>,
    #[serde(default)]
    pub(crate) owners: Vec<String>,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct SupportTargetsRecord {
    #[serde(default)]
    pub(crate) default_route: String,
    #[serde(default)]
    pub(crate) tiers: SupportTierDefinitions,
    #[serde(default)]
    pub(crate) compatibility_matrix: Vec<SupportMatrixEntry>,
    #[serde(default)]
    pub(crate) adapter_conformance_criteria: Vec<AdapterConformanceCriterion>,
    #[serde(default)]
    pub(crate) host_adapters: Vec<AdapterSupportDeclaration>,
    #[serde(default)]
    pub(crate) model_adapters: Vec<AdapterSupportDeclaration>,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct SupportTargetAdmissionRecord {
    #[serde(default)]
    pub(crate) tuple_id: String,
    #[serde(default)]
    pub(crate) status: String,
    #[serde(default)]
    pub(crate) route: String,
    #[serde(default)]
    pub(crate) requires_mission: bool,
    #[serde(default)]
    pub(crate) allowed_capability_packs: Vec<String>,
    #[serde(default)]
    pub(crate) required_authority_artifacts: Vec<String>,
    #[serde(default)]
    pub(crate) tuple: SupportTargetTuple,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct SupportTierDefinitions {
    #[serde(default)]
    pub(crate) model: Vec<SupportNamedTier>,
    #[serde(default)]
    pub(crate) workload: Vec<SupportWorkloadTier>,
    #[serde(default)]
    pub(crate) language_resource: Vec<SupportNamedTier>,
    #[serde(default)]
    pub(crate) locale: Vec<SupportNamedTier>,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct SupportNamedTier {
    pub(crate) id: String,
    pub(crate) label: String,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct SupportWorkloadTier {
    pub(crate) id: String,
    pub(crate) label: String,
    #[serde(default)]
    pub(crate) default_route: String,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct SupportMatrixEntry {
    pub(crate) model_tier: String,
    pub(crate) workload_tier: String,
    pub(crate) language_resource_tier: String,
    pub(crate) locale_tier: String,
    pub(crate) support_status: String,
    pub(crate) default_route: String,
    #[serde(default)]
    pub(crate) requires_mission: Option<bool>,
    #[serde(default)]
    pub(crate) allowed_capability_packs: Vec<String>,
    #[serde(default)]
    pub(crate) required_evidence: Vec<String>,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct AdapterConformanceCriterion {
    pub(crate) criterion_id: String,
    pub(crate) adapter_kind: String,
    #[serde(default)]
    pub(crate) required_evidence: Vec<String>,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct AdapterSupportDeclaration {
    pub(crate) adapter_id: String,
    #[serde(default)]
    pub(crate) contract_ref: String,
    #[serde(default)]
    pub(crate) authority_mode: String,
    #[serde(default)]
    pub(crate) replaceable: bool,
    #[serde(default)]
    pub(crate) support_status: String,
    #[serde(default)]
    pub(crate) default_route: String,
    #[serde(default)]
    pub(crate) criteria_refs: Vec<String>,
    #[serde(default)]
    pub(crate) allowed_model_tiers: Vec<String>,
    #[serde(default)]
    pub(crate) allowed_workload_tiers: Vec<String>,
    #[serde(default)]
    pub(crate) allowed_language_resource_tiers: Vec<String>,
    #[serde(default)]
    pub(crate) allowed_locale_tiers: Vec<String>,
    #[serde(default)]
    pub(crate) required_evidence: Vec<String>,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct AdapterRuntimeSurfaceRecord {
    #[serde(default)]
    pub(crate) interface_ref: String,
    #[serde(default)]
    pub(crate) integration_class: String,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct AdapterSupportTierDeclarationsRecord {
    #[serde(default)]
    pub(crate) model_tiers: Vec<String>,
    #[serde(default)]
    pub(crate) workload_tiers: Vec<String>,
    #[serde(default)]
    pub(crate) language_resource_tiers: Vec<String>,
    #[serde(default)]
    pub(crate) locale_tiers: Vec<String>,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct ModelContaminationResetPolicyRecord {
    #[serde(default)]
    pub(crate) clean_checkpoint_required: bool,
    #[serde(default)]
    pub(crate) hard_reset_on_signature: bool,
    #[serde(default)]
    pub(crate) contamination_signal_ref: String,
    #[serde(default)]
    pub(crate) evidence_log_ref: String,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct ModelAdapterManifestRecord {
    #[serde(default)]
    pub(crate) schema_version: String,
    #[serde(default)]
    pub(crate) adapter_id: String,
    #[serde(default)]
    pub(crate) display_name: String,
    #[serde(default)]
    pub(crate) replaceable: bool,
    #[serde(default)]
    pub(crate) authority_mode: String,
    #[serde(default)]
    pub(crate) runtime_surface: AdapterRuntimeSurfaceRecord,
    #[serde(default)]
    pub(crate) support_target_ref: String,
    #[serde(default)]
    pub(crate) support_tier_declarations: AdapterSupportTierDeclarationsRecord,
    #[serde(default)]
    pub(crate) conformance_criteria_refs: Vec<String>,
    #[serde(default)]
    pub(crate) conformance_suite_refs: Vec<String>,
    #[serde(default)]
    pub(crate) contamination_reset_policy: ModelContaminationResetPolicyRecord,
    #[serde(default)]
    pub(crate) known_limitations: Vec<String>,
    #[serde(default)]
    pub(crate) non_authoritative_boundaries: Vec<String>,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct HostAdapterManifestRecord {
    #[serde(default)]
    pub(crate) schema_version: String,
    #[serde(default)]
    pub(crate) adapter_id: String,
    #[serde(default)]
    pub(crate) display_name: String,
    #[serde(default)]
    pub(crate) host_family: String,
    #[serde(default)]
    pub(crate) replaceable: bool,
    #[serde(default)]
    pub(crate) authority_mode: String,
    #[serde(default)]
    pub(crate) runtime_surface: AdapterRuntimeSurfaceRecord,
    #[serde(default)]
    pub(crate) projection_sources: Vec<String>,
    #[serde(default)]
    pub(crate) support_target_ref: String,
    #[serde(default)]
    pub(crate) support_tier_declarations: AdapterSupportTierDeclarationsRecord,
    #[serde(default)]
    pub(crate) conformance_criteria_refs: Vec<String>,
    #[serde(default)]
    pub(crate) known_limitations: Vec<String>,
    #[serde(default)]
    pub(crate) non_authoritative_boundaries: Vec<String>,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct RuntimeCapabilityPackRegistryRecord {
    #[serde(default)]
    pub(crate) packs: Vec<RuntimeCapabilityPackAdmissionRecord>,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct RuntimeCapabilityPackAdmissionRecord {
    #[serde(default)]
    pub(crate) pack_id: String,
    #[serde(default)]
    pub(crate) contract_ref: String,
    #[serde(default)]
    pub(crate) admission_status: String,
    #[serde(default)]
    pub(crate) default_route: String,
    #[serde(default)]
    pub(crate) required_evidence: Vec<String>,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct CapabilityPackManifestRecord {
    #[serde(default)]
    pub(crate) schema_version: String,
    #[serde(default)]
    pub(crate) pack_id: String,
    #[serde(default)]
    pub(crate) surface: String,
    #[serde(default)]
    pub(crate) display_name: String,
    #[serde(default)]
    pub(crate) description: String,
    #[serde(default)]
    pub(crate) runtime_surface_refs: Vec<String>,
    #[serde(default)]
    pub(crate) required_evidence: Vec<String>,
    #[serde(default)]
    pub(crate) support_target_ref: String,
    #[serde(default)]
    pub(crate) known_limitations: Vec<String>,
}

#[derive(Debug, Clone, Default)]
pub(crate) struct ResolvedAdapterSupport {
    pub(crate) adapter_id: String,
    pub(crate) support_status: String,
    pub(crate) route: String,
    pub(crate) criteria_refs: Vec<String>,
    pub(crate) required_evidence: Vec<String>,
}

#[derive(Debug, Clone, Default)]
pub(crate) struct ResolvedCapabilityPackSupport {
    pub(crate) support_status: String,
    pub(crate) route: String,
    pub(crate) required_evidence: Vec<String>,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub(crate) struct RevocationRegistry {
    #[serde(default)]
    pub(crate) revocations: Vec<RevocationArtifact>,
}

#[derive(Debug, Clone)]
pub(crate) struct ResolvedAutonomyState {
    pub(crate) context: AutonomyContext,
    pub(crate) action_class: String,
    pub(crate) rollback_handle: Option<String>,
    pub(crate) compensation_handle: Option<String>,
    pub(crate) recovery_window: String,
    pub(crate) reversibility_primitive: Option<String>,
    pub(crate) autonomy_budget_state: String,
    pub(crate) breaker_state: String,
    pub(crate) approval_required: bool,
    pub(crate) break_glass_required: bool,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub(crate) struct RuntimeStateRecord {
    #[serde(default)]
    pub(crate) schema_version: String,
    #[serde(default)]
    pub(crate) run_id: String,
    #[serde(default)]
    pub(crate) status: String,
    #[serde(default)]
    pub(crate) workflow_mode: String,
    #[serde(default)]
    pub(crate) decision_state: Option<String>,
    #[serde(default)]
    pub(crate) run_contract_ref: String,
    #[serde(default)]
    pub(crate) run_manifest_ref: String,
    #[serde(default)]
    pub(crate) current_stage_attempt_id: Option<String>,
    #[serde(default)]
    pub(crate) last_checkpoint_ref: Option<String>,
    #[serde(default)]
    pub(crate) last_receipt_ref: Option<String>,
    #[serde(default)]
    pub(crate) mission_id: Option<String>,
    #[serde(default)]
    pub(crate) parent_run_ref: Option<String>,
    #[serde(default)]
    pub(crate) created_at: String,
    #[serde(default)]
    pub(crate) updated_at: String,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub(crate) struct RollbackPostureRecord {
    #[serde(default)]
    pub(crate) schema_version: String,
    #[serde(default)]
    pub(crate) run_id: String,
    #[serde(default)]
    pub(crate) reversibility_class: String,
    #[serde(default)]
    pub(crate) rollback_strategy: String,
    #[serde(default)]
    pub(crate) rollback_ref: Option<String>,
    #[serde(default)]
    pub(crate) rollback_handle: Option<String>,
    #[serde(default)]
    pub(crate) compensation_handle: Option<String>,
    #[serde(default)]
    pub(crate) recovery_window: Option<String>,
    #[serde(default)]
    pub(crate) contamination_state: String,
    #[serde(default)]
    pub(crate) retry_record_ref: String,
    #[serde(default)]
    pub(crate) contamination_record_ref: String,
    #[serde(default)]
    pub(crate) resume_allowed: bool,
    #[serde(default)]
    pub(crate) reset_action: String,
    #[serde(default)]
    pub(crate) invalidated_artifacts: Vec<String>,
    #[serde(default)]
    pub(crate) hard_reset_required: bool,
    #[serde(default)]
    pub(crate) posture_source: Option<String>,
    #[serde(default)]
    pub(crate) updated_at: String,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub(crate) struct RunCheckpointRecord {
    #[serde(default)]
    pub(crate) schema_version: String,
    #[serde(default)]
    pub(crate) run_id: String,
    #[serde(default)]
    pub(crate) checkpoint_id: String,
    #[serde(default)]
    pub(crate) stage_attempt_id: String,
    #[serde(default)]
    pub(crate) checkpoint_kind: String,
    #[serde(default)]
    pub(crate) status: String,
    #[serde(default)]
    pub(crate) control_ref: String,
    #[serde(default)]
    pub(crate) evidence_ref: Option<String>,
    #[serde(default)]
    pub(crate) notes: Option<String>,
    #[serde(default)]
    pub(crate) created_at: String,
    #[serde(default)]
    pub(crate) updated_at: String,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub(crate) struct ReplayPointersRecord {
    #[serde(default)]
    pub(crate) schema_version: String,
    #[serde(default)]
    pub(crate) run_id: String,
    #[serde(default)]
    pub(crate) replay_manifest_refs: Vec<String>,
    #[serde(default)]
    pub(crate) receipt_refs: Vec<String>,
    #[serde(default)]
    pub(crate) checkpoint_refs: Vec<String>,
    #[serde(default)]
    pub(crate) trace_refs: Vec<String>,
    #[serde(default)]
    pub(crate) external_index_refs: Vec<String>,
    #[serde(default)]
    pub(crate) updated_at: String,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub(crate) struct TracePointersRecord {
    #[serde(default)]
    pub(crate) schema_version: String,
    #[serde(default)]
    pub(crate) run_id: String,
    #[serde(default)]
    pub(crate) trace_id: String,
    #[serde(default)]
    pub(crate) trace_refs: Vec<String>,
    #[serde(default)]
    pub(crate) external_index_refs: Vec<String>,
    #[serde(default)]
    pub(crate) notes: Option<String>,
    #[serde(default)]
    pub(crate) updated_at: String,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub(crate) struct RetainedRunEvidenceRecord {
    #[serde(default)]
    pub(crate) schema_version: String,
    #[serde(default)]
    pub(crate) run_id: String,
    #[serde(default)]
    pub(crate) evidence_refs: BTreeMap<String, String>,
    #[serde(default)]
    pub(crate) updated_at: String,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub(crate) struct RunContinuityRecord {
    #[serde(default)]
    pub(crate) schema_version: String,
    #[serde(default)]
    pub(crate) run_id: String,
    #[serde(default)]
    pub(crate) status: String,
    #[serde(default)]
    pub(crate) run_contract_ref: String,
    #[serde(default)]
    pub(crate) run_manifest_ref: String,
    #[serde(default)]
    pub(crate) retained_evidence_ref: String,
    #[serde(default)]
    pub(crate) replay_pointers_ref: String,
    #[serde(default)]
    pub(crate) evidence_classification_ref: String,
    #[serde(default)]
    pub(crate) last_receipt_ref: Option<String>,
    #[serde(default)]
    pub(crate) last_checkpoint_ref: String,
    #[serde(default)]
    pub(crate) resume_from_stage_attempt_id: Option<String>,
    #[serde(default)]
    pub(crate) mission_id: Option<String>,
    #[serde(default)]
    pub(crate) parent_run_ref: Option<String>,
    #[serde(default)]
    pub(crate) next_action: Option<String>,
    #[serde(default)]
    pub(crate) updated_at: String,
}

#[derive(Debug, Clone)]
pub(crate) struct BoundRunLifecycle {
    pub(crate) control_root: PathBuf,
    pub(crate) evidence_root: PathBuf,
    pub(crate) assurance_root: PathBuf,
    pub(crate) measurement_root: PathBuf,
    pub(crate) intervention_root: PathBuf,
    pub(crate) disclosure_root: PathBuf,
    pub(crate) replay_manifest_path: PathBuf,
    pub(crate) continuity_handoff_path: PathBuf,
    pub(crate) _run_manifest_path: PathBuf,
    pub(crate) runtime_state_path: PathBuf,
    pub(crate) receipts_root: PathBuf,
    pub(crate) replay_pointers_path: PathBuf,
    pub(crate) _evidence_classification_path: PathBuf,
    pub(crate) retained_evidence_path: PathBuf,
    pub(crate) stage_attempt_path: PathBuf,
    pub(crate) control_root_rel: String,
    pub(crate) evidence_root_rel: String,
    pub(crate) control_checkpoint_ref: String,
    pub(crate) run_manifest_ref: String,
    pub(crate) receipts_root_rel: String,
    pub(crate) replay_pointers_ref: String,
    pub(crate) trace_pointers_ref: String,
    pub(crate) evidence_classification_ref: String,
    pub(crate) retained_evidence_ref: String,
    pub(crate) stage_attempt_ref: String,
    pub(crate) stage_attempt_id: String,
}
