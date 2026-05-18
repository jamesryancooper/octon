use super::*;
use octon_lifecycle_executor::{
    DefaultLifecycleRouteExecutor, LifecycleErrorClass, LifecycleExecutionError,
    LifecycleRouteExecutionRequest, LifecycleRouteExecutionResult, LifecycleRouteExecutor,
};
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::collections::{BTreeMap, BTreeSet};
use std::fs;
use std::fs::OpenOptions;
use std::io::Write;
use std::path::{Component, Path, PathBuf};
use std::process::Command;
use std::thread;

const PROGRAM_CHECKPOINT_FILE: &str = "program-lifecycle-checkpoint.yml";
const DEFAULT_CHILD_LIFECYCLE_ID: &str = "proposal-packet";
const DEFAULT_PROGRAM_MAX_STEPS: u32 = 20;
const DEFAULT_MAX_CHILD_CONCURRENCY: usize = 2;
const MISSING_CHILD_REGISTRY_DIGEST: &str = "missing-child-registry";
const INVALID_CHILD_REGISTRY_DIGEST: &str = "invalid-child-registry";
const REFRESH_PUBLICATION_PROJECTIONS_ACTION: &str = "refresh-publication-projections";
const REBASELINE_CHECKPOINT_ACTION: &str = "rebaseline-checkpoint";
const CLEANUP_CURRENT_RUN_ARTIFACTS_ACTION: &str = "cleanup-current-run-artifacts";
const AUTHORITY_ZONE_RUN_BOUND: &str = "octon-run-bound";
const AUTHORITY_ZONE_GENERATED_DERIVED: &str = "octon-generated-derived";
const AUTHORITY_ZONE_AUTHORED_GOVERNANCE: &str = "octon-authored-governance";
const AUTHORITY_ZONE_WORKSPACE_DECLARED: &str = "workspace-declared";
const AUTHORITY_ZONE_CURRENT_RUN_AGENT_ARTIFACT: &str = "current-run-agent-artifact";
const AUTHORITY_ZONE_PROTECTED_OR_EXTERNAL: &str = "protected-or-external";
const ARTIFACT_CLASS_RUN_CONTROL: &str = "run-control";
const ARTIFACT_CLASS_RUN_EVIDENCE: &str = "run-evidence";
const ARTIFACT_CLASS_GENERATED_DERIVED: &str = "generated-derived";
const ARTIFACT_CLASS_AUTHORED_GOVERNANCE: &str = "authored-governance";
const ARTIFACT_CLASS_WORKSPACE_SOURCE: &str = "workspace-source";
const ARTIFACT_CLASS_CURRENT_RUN_GENERATED: &str = "current-run-generated";
const ARTIFACT_CLASS_PROTECTED_OR_EXTERNAL: &str = "protected-human-or-external";
const ARTIFACT_CLASS_UNKNOWN: &str = "unknown";
const OPERATION_CLASS_REFRESH_GENERATED_PROJECTION: &str = "refresh-generated-projection";
const OPERATION_CLASS_CLEANUP_CURRENT_RUN_ARTIFACT: &str = "cleanup-current-run-artifact";
const OPERATION_CLASS_RETRY_CHILD_ROUTE: &str = "retry-child-route";
const OPERATION_CLASS_EXECUTE_CHILD_ROUTE: &str = "execute-child-route";
const OPERATION_CLASS_PROGRAM_RECOVERY_ACTION: &str = "program-recovery-action";
const OPERATION_CLASS_CLOSEOUT_READINESS: &str = "closeout-readiness";
const ROUTE_ID_PROMOTE_PROPOSAL: &str = "promote-proposal";
const ROUTE_ID_CLEANUP_LIFECYCLE_RESIDUE: &str = "cleanup-lifecycle-residue";
const RECEIPT_ID_PROPOSAL_REVIEW: &str = "proposal-review";
const RECEIPT_ID_PROGRAM_IMPLEMENTATION_PROMPT: &str = "program-implementation-prompt";
const RECEIPT_ID_IMPLEMENTATION_RUN: &str = "implementation-run";
const RECEIPT_ID_IMPLEMENTATION_CONFORMANCE: &str = "implementation-conformance";
const RECEIPT_ID_POST_IMPLEMENTATION_DRIFT: &str = "post-implementation-drift";
const FIELD_CHILD_AUTHORITY_PRESERVED: &str = "child_authority_preserved";
const APPROVAL_POSTURE_PRE_GRANTED: &str = "pre-granted";
const APPROVAL_POSTURE_APPROVAL_REQUIRED: &str = "authority-ambiguity";
const APPROVAL_POSTURE_DENY: &str = "deny";
const BLOCKER_AUTHORITY_ZONE_DENIED: &str = "authority-zone-denied";
const BLOCKER_AUTHORITY_ZONE_AMBIGUOUS: &str = "authority-zone-ambiguous";
const BLOCKER_DURABLE_AUTHORITY_APPROVAL_REQUIRED: &str = "scope-expansion";
const BLOCKER_PROTECTED_ARTIFACT_APPROVAL_REQUIRED: &str = "scope-expansion";
const BLOCKER_LIFECYCLE_RESIDUE_CLEANUP_NEEDED: &str = "lifecycle-residue-cleanup-needed";
const UNKNOWN_RESIDUE_FINGERPRINT: &str = "unknown";

fn default_orchestrated_replan_loop_execution_strategy() -> String {
    LifecycleExecutionStrategy::OrchestratedReplanLoop
        .as_str()
        .to_string()
}

#[derive(Clone, Debug, Deserialize, Serialize)]
struct ProgramChildRegistry {
    schema_version: String,
    execution_mode: String,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    default_child_lifecycle_id: Option<String>,
    #[serde(default)]
    children: Vec<ProgramChildSpec>,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
struct ProgramChildSpec {
    child_id: String,
    path: String,
    #[serde(default = "default_required")]
    required: bool,
    #[serde(default)]
    deferred: bool,
    #[serde(default)]
    #[serde(skip_serializing_if = "Vec::is_empty")]
    dependencies: Vec<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    dependency_gate: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    phase_id: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    group_id: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    rollback_posture: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    supersession_evidence: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    replacement_child_id: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    replacement_for: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    recovery_profile: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    phase_commit_barrier: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Vec::is_empty")]
    write_scopes: Vec<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    seed_role: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    child_lifecycle_id: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Vec::is_empty")]
    required_metadata: Vec<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Vec::is_empty")]
    source_lineage_refs: Vec<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Vec::is_empty")]
    parent_contract_refs: Vec<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Vec::is_empty")]
    readiness_requirements: Vec<ProgramChildReadinessRequirement>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Vec::is_empty")]
    predecessor_constraints: Vec<ProgramChildPredecessorConstraint>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Vec::is_empty")]
    successor_constraints: Vec<ProgramChildSuccessorConstraint>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    cutover_constraints: Option<ProgramChildCutoverConstraints>,
}

fn default_required() -> bool {
    true
}

#[derive(Clone, Debug, Deserialize, Serialize)]
struct ProgramChildReadinessRequirement {
    requirement_id: String,
    summary: String,
    #[serde(default)]
    #[serde(skip_serializing_if = "Vec::is_empty")]
    review_must_mention: Vec<String>,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
struct ProgramChildPredecessorConstraint {
    predecessor_child_id: String,
    constraint: String,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
struct ProgramChildSuccessorConstraint {
    successor_child_id: String,
    constraint: String,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
struct ProgramChildCutoverConstraints {
    #[serde(default)]
    compatibility_retirement_requires_predecessor_evidence: bool,
    #[serde(default)]
    canonical_runtime_support_requires_predecessor_evidence: bool,
    #[serde(default)]
    #[serde(skip_serializing_if = "Vec::is_empty")]
    required_predecessor_child_ids: Vec<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Vec::is_empty")]
    forbidden_claims_until_ready: Vec<String>,
}

#[derive(Clone, Debug, Serialize)]
pub(crate) struct ProgramLifecyclePlanResult {
    pub schema_version: String,
    pub lifecycle_id: String,
    pub owner_extension: String,
    pub execution_strategy: String,
    pub contract_path: String,
    pub target: String,
    pub parent_manifest_status: Option<String>,
    pub child_registry_path: String,
    pub child_registry_schema_version: String,
    pub child_registry_digest: String,
    pub execution_mode: String,
    pub aggregate_state: String,
    #[serde(default)]
    pub terminal_outcome: Option<String>,
    #[serde(default)]
    pub parent_receipt_states: BTreeMap<String, ReceiptPlanState>,
    #[serde(default)]
    pub program_route: Option<RoutePlanState>,
    #[serde(default)]
    pub program_gate_results: Vec<GatePlanResult>,
    #[serde(default)]
    pub blocked_by_program_gate: Option<String>,
    #[serde(default)]
    pub program_blockers: Vec<ProgramBlocker>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Vec::is_empty")]
    pub normalized_program_blockers: Vec<ProgramTaxonomyEvidence>,
    #[serde(default)]
    pub child_states: BTreeMap<String, ProgramChildPlanState>,
    #[serde(default)]
    #[serde(skip_serializing_if = "BTreeMap::is_empty")]
    pub normalized_child_blockers: BTreeMap<String, Vec<ProgramTaxonomyEvidence>>,
    #[serde(default)]
    pub runnable_batch: Vec<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub scheduler_phase: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Vec::is_empty")]
    pub skipped_blocked_children: Vec<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "BTreeMap::is_empty")]
    pub required_child_completion: BTreeMap<String, ProgramRequiredChildCompletion>,
    #[serde(default)]
    #[serde(skip_serializing_if = "BTreeMap::is_empty")]
    pub closeout_hygiene_suppressions: BTreeMap<String, ProgramCloseoutHygieneSuppression>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Vec::is_empty")]
    pub safe_repair_candidates: Vec<ProgramSafeRepairCandidate>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub program_recovery_recipe_validation_status: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Vec::is_empty")]
    pub program_recovery_recipe_validation_failures: Vec<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub program_recovery_recipe_blocker_class: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub program_recovery_recipe_route_id: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub program_recovery_recipe_delegation_contract_basis: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Vec::is_empty")]
    pub unsafe_results: Vec<ProgramUnsafeResultSummary>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub unsafe_continuation_decision: Option<String>,
    #[serde(default)]
    pub approval_blockers: Vec<ProgramApprovalBlocker>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Vec::is_empty")]
    pub normalized_approval_blockers: Vec<ProgramTaxonomyEvidence>,
    #[serde(default)]
    pub checkpoint_drift: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub stop_reason: Option<String>,
    pub final_verdict: String,
}

#[derive(Clone, Debug, Serialize)]
pub(crate) struct ProgramChildPlanState {
    pub child_id: String,
    pub child_lifecycle_id: String,
    pub target: String,
    pub required: bool,
    pub deferred: bool,
    #[serde(default)]
    pub dependencies: Vec<String>,
    #[serde(default)]
    pub dependency_gate: Option<String>,
    #[serde(default)]
    pub phase_id: Option<String>,
    #[serde(default)]
    pub group_id: Option<String>,
    #[serde(default)]
    pub seed_role: Option<String>,
    #[serde(default)]
    pub rollback_posture: Option<String>,
    #[serde(default)]
    pub recovery_profile: Option<String>,
    #[serde(default)]
    pub phase_commit_barrier: Option<String>,
    #[serde(default)]
    pub selected_route: Option<RoutePlanState>,
    #[serde(default)]
    pub terminal_outcome: Option<String>,
    #[serde(default)]
    pub receipt_digests: BTreeMap<String, String>,
    #[serde(default)]
    pub gate_status: ProgramChildGateStatus,
    #[serde(default)]
    #[serde(skip_serializing_if = "BTreeMap::is_empty")]
    pub dependency_gate_status: BTreeMap<String, ProgramDependencyGateStatus>,
    #[serde(default)]
    pub write_scopes: Vec<String>,
    #[serde(default)]
    pub blockers: Vec<ProgramBlocker>,
    pub final_verdict: String,
}

#[derive(Clone, Debug, Default, Deserialize, Serialize, PartialEq, Eq)]
pub(crate) struct ProgramChildGateStatus {
    pub terminal: bool,
    pub verification: bool,
    pub closeout: bool,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
pub(crate) struct ProgramDependencyGateStatus {
    pub dependency_id: String,
    pub required_gate: String,
    pub satisfied: bool,
    pub observed_gate: String,
    pub reason: String,
}

#[derive(Clone, Debug, Serialize)]
pub(crate) struct ProgramRequiredChildCompletion {
    pub required: bool,
    pub deferred: bool,
    pub terminal: bool,
    #[serde(default)]
    pub terminal_outcome: Option<String>,
    pub final_verdict: String,
    #[serde(default)]
    pub selected_route: Option<String>,
    #[serde(default)]
    pub blockers: Vec<ProgramBlocker>,
}

#[derive(Clone, Debug, Serialize)]
pub(crate) struct ProgramSafeRepairCandidate {
    pub scope: String,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub child_id: Option<String>,
    pub blocker_class: String,
    pub selected_repair_route: String,
    pub delegation_contract_basis: String,
}

#[derive(Clone, Debug, Serialize)]
pub(crate) struct ProgramUnsafeResultSummary {
    pub scope: String,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub child_id: Option<String>,
    pub route_id: String,
    pub status: String,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub blocker_class: Option<String>,
    pub safe_continuation_available: bool,
    pub continuation_reason: String,
}

#[derive(Clone, Debug, Serialize)]
pub(crate) struct ProgramBlocker {
    pub blocker_class: String,
    pub message: String,
    #[serde(default)]
    pub recovery_route: Option<String>,
}

#[derive(Clone, Debug, Serialize)]
pub(crate) struct ProgramTaxonomyEvidence {
    pub raw_value: String,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub legacy_class: Option<String>,
    pub normalized_category: String,
    pub normalized_blocker_class: String,
    pub disposition: String,
    pub autonomy_basis: String,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub delegation_contract_basis: Option<String>,
}

#[derive(Clone, Debug, Serialize)]
struct ProgramArtifactOperation {
    operation_id: String,
    child_id: String,
    route_id: String,
    operation: String,
    destructive_operation: String,
    artifact_paths: Vec<PathBuf>,
    command_or_operation: String,
}

#[derive(Clone, Debug, Serialize)]
struct ProgramArtifactCriticalityDecision {
    schema_version: String,
    program_run_id: String,
    classification_policy_version: String,
    operation_id: String,
    child_id: String,
    route_id: String,
    operation: String,
    destructive_operation: String,
    artifact_paths: Vec<String>,
    classification_inputs: Vec<String>,
    artifact_owner: String,
    authority_surface: String,
    authority_zone: String,
    artifact_class: String,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    authority_zone_decision: Option<String>,
    criticality: String,
    ownership: String,
    workspace_contained: bool,
    declared_scope_contained: bool,
    human_input_required: bool,
    autonomous_allowed: bool,
    rationale: String,
    command_or_operation: String,
    before_validation: String,
    after_validation: String,
    operation_supported: bool,
    mutation_performed: bool,
    mutation_status: String,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    blocked_reason: Option<String>,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
struct AuthorityZoneDecision {
    schema_version: String,
    decision_id: String,
    run_id: String,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    child_id: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    route_id: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    blocker_class: Option<String>,
    operation_class: String,
    authority_zone: String,
    artifact_class: String,
    approval_posture: String,
    autonomous_allowed: bool,
    fail_closed_blocker: String,
    path_refs: Vec<String>,
    declared_write_scopes: Vec<String>,
    #[serde(default)]
    workspace_contained: bool,
    #[serde(default)]
    declared_scope_contained: bool,
    #[serde(default)]
    run_bound_current: bool,
    #[serde(default)]
    generated_non_authority: bool,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    source_authority_digest: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    write_scope_digest: Option<String>,
    evidence_requirement: String,
    basis: Vec<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Vec::is_empty")]
    forbidden_authority_consumers: Vec<String>,
    decided_at: String,
}

#[derive(Clone, Debug)]
struct AuthorityPathClassification {
    zone: String,
    artifact_class: String,
    basis: String,
    workspace_contained: bool,
    declared_scope_contained: bool,
    run_bound_current: bool,
    generated_non_authority: bool,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
struct ProgramUnsafeRepairEvidence {
    schema_version: String,
    program_run_id: String,
    #[serde(default)]
    repair_scope: String,
    #[serde(default)]
    blocker_scope: String,
    child_id: String,
    unsafe_condition: String,
    original_route_blocked_reason: String,
    selected_repair_route: String,
    agent_authority_basis: String,
    files_artifacts_changed: Vec<String>,
    before_validation: String,
    after_validation: String,
    #[serde(default)]
    safe_continuation_available: bool,
    #[serde(default)]
    route_execution_status: String,
    #[serde(default)]
    recipe_validation_status: String,
    #[serde(default)]
    recipe_validation_failures: Vec<String>,
    #[serde(default)]
    post_attempt_validations_declared: Vec<String>,
    #[serde(default)]
    post_attempt_validation_results: Vec<String>,
    #[serde(default)]
    resume_decision_basis: String,
    #[serde(default)]
    post_attempt_validation_status: String,
    #[serde(default)]
    post_attempt_validation_failures: Vec<String>,
    #[serde(default)]
    final_blocker_class: Option<String>,
    #[serde(default)]
    final_execution_can_resume: bool,
    execution_can_resume: bool,
}

#[derive(Clone, Debug, Serialize)]
struct ProgramDelegatedPromotionReceipt {
    schema_version: String,
    delegation_kind: String,
    program_run_id: String,
    lifecycle_id: String,
    route_id: String,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    child_id: Option<String>,
    registry_digest: String,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    write_scope_digest: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    authority_zone_decision_ref: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    authority_zone: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    artifact_class: Option<String>,
    required_receipt_verdicts: BTreeMap<String, String>,
    required_receipt_digests: BTreeMap<String, String>,
    route_delegation_contract_basis: String,
    invocation_authority: String,
    human_exception_grant: bool,
    authority_provenance: Vec<String>,
    recorded_at: String,
}

#[derive(Clone, Debug, Default)]
struct ProgramRecoveryRecipeValidationEvidence {
    status: Option<String>,
    failures: Vec<String>,
    blocker_class: Option<String>,
    route_id: Option<String>,
    delegation_contract_basis: Option<String>,
}

#[derive(Clone, Debug)]
struct ProgramRepairSelection {
    route: RoutePlanState,
    validation: ProgramRecoveryRecipeValidationEvidence,
}

#[derive(Clone, Debug, Default)]
struct ProgramRepairSelectionResult {
    selection: Option<ProgramRepairSelection>,
    validation: Option<ProgramRecoveryRecipeValidationEvidence>,
}

impl ProgramRecoveryRecipeValidationEvidence {
    fn passed(blocker_class: &str, route_id: &str, delegation_contract_basis: &str) -> Self {
        Self {
            status: Some("passed".to_string()),
            failures: Vec::new(),
            blocker_class: Some(blocker_class.to_string()),
            route_id: Some(route_id.to_string()),
            delegation_contract_basis: Some(delegation_contract_basis.to_string()),
        }
    }

    fn failed(blocker_class: &str, route_id: Option<&str>, failures: Vec<String>) -> Self {
        Self {
            status: Some("failed".to_string()),
            failures,
            blocker_class: Some(blocker_class.to_string()),
            route_id: route_id.map(str::to_string),
            delegation_contract_basis: None,
        }
    }
}

#[derive(Clone, Debug)]
struct ProgramRecoveryPostAttemptValidationOutcome {
    status: String,
    failures: Vec<String>,
    declared: Vec<String>,
    results: Vec<String>,
    execution_can_resume: bool,
    resume_decision_basis: String,
    final_blocker_class: Option<String>,
}

impl ProgramRecoveryPostAttemptValidationOutcome {
    fn route_not_completed(
        status: &str,
        message: Option<&str>,
        blocker_class: Option<String>,
    ) -> Self {
        let mut failures = vec![format!("repair route final status {status}")];
        if let Some(message) = message {
            failures.push(message.to_string());
        }
        Self {
            status: "not-run-route-not-completed".to_string(),
            failures,
            declared: Vec::new(),
            results: Vec::new(),
            execution_can_resume: false,
            resume_decision_basis:
                "repair route did not complete; post-attempt validations were not run".to_string(),
            final_blocker_class: blocker_class,
        }
    }
}

#[derive(Clone, Debug, Serialize)]
pub(crate) struct ProgramApprovalBlocker {
    pub child_id: String,
    pub route_id: String,
    pub reason: String,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub blocker_class: Option<String>,
}

#[derive(Clone, Debug, Serialize)]
pub(crate) struct ProgramLifecycleRunResult {
    pub schema_version: String,
    pub run_id: String,
    pub lifecycle_id: String,
    pub execution_strategy: String,
    pub target: String,
    pub executor: String,
    pub route_execution_mode: String,
    pub bundle_root: String,
    pub checkpoint_path: String,
    pub event_log_path: String,
    pub latest_event_offset: u64,
    #[serde(default)]
    pub selected_parent_route: Option<RoutePlanState>,
    #[serde(default)]
    pub parent_route_result: Option<LifecycleRouteExecutionResult>,
    #[serde(default)]
    pub selected_children: Vec<String>,
    #[serde(default)]
    pub child_results: Vec<ProgramChildExecutionSummary>,
    #[serde(default)]
    pub terminal_outcome: Option<String>,
    pub final_verdict: String,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
pub(crate) struct ProgramChildExecutionSummary {
    pub child_id: String,
    pub child_run_id: String,
    pub route_id: String,
    pub status: String,
    pub attempts: u32,
    #[serde(default)]
    pub retryable: bool,
    #[serde(default)]
    pub blocker_class: Option<String>,
    #[serde(default)]
    pub error_message: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub error_class: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Vec::is_empty")]
    pub evidence_paths: Vec<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub worktree_hygiene_foreign_fingerprint: Option<String>,
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq, Eq)]
struct ProgramRecoveryProgressFingerprint {
    child_id: String,
    route_id: String,
    blocker_class: String,
    final_verdict: String,
    #[serde(default)]
    terminal_outcome: Option<String>,
    #[serde(default)]
    gate_status: ProgramChildGateStatus,
    #[serde(default)]
    receipt_digests: BTreeMap<String, String>,
    #[serde(default)]
    selected_route_id: Option<String>,
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq, Eq)]
pub(crate) struct ProgramCloseoutHygieneSuppression {
    child_id: String,
    route_id: String,
    blocker_class: String,
    message: String,
    #[serde(default)]
    evidence_paths: Vec<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    worktree_hygiene_foreign_fingerprint: Option<String>,
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq, Eq)]
struct ProgramResidueCleanupAttempt {
    child_id: String,
    route_id: String,
    blocker_class: String,
    residue_fingerprint: String,
    cleanup_route_id: String,
    status: String,
    #[serde(default)]
    #[serde(skip_serializing_if = "Vec::is_empty")]
    evidence_paths: Vec<String>,
}

#[derive(Clone, Debug, Default, Deserialize, Serialize)]
struct ProgramLifecycleCheckpoint {
    schema_version: String,
    run_id: String,
    lifecycle_id: String,
    #[serde(default = "default_orchestrated_replan_loop_execution_strategy")]
    execution_strategy: String,
    target: String,
    #[serde(default)]
    executor: Option<String>,
    #[serde(default = "default_invocation_authority_unattended")]
    invocation_authority: String,
    #[serde(default)]
    timeout_seconds: Option<u64>,
    #[serde(default)]
    max_child_concurrency: Option<usize>,
    child_registry_digest: String,
    execution_mode: String,
    #[serde(default)]
    run_inputs: BTreeMap<String, String>,
    #[serde(default)]
    scheduler_decision: Vec<String>,
    #[serde(default)]
    child_states: BTreeMap<String, ProgramChildCheckpointState>,
    #[serde(default)]
    recovery_attempts: BTreeMap<String, u32>,
    #[serde(default)]
    program_recovery_action_attempts: BTreeMap<String, u32>,
    #[serde(default)]
    recovery_progress_fingerprints: BTreeMap<String, ProgramRecoveryProgressFingerprint>,
    #[serde(default)]
    closeout_hygiene_suppressions: BTreeMap<String, ProgramCloseoutHygieneSuppression>,
    #[serde(default)]
    residue_cleanup_attempts: BTreeMap<String, ProgramResidueCleanupAttempt>,
    #[serde(default)]
    approvals: Vec<ProgramApprovalGrant>,
    #[serde(default)]
    program_recovery_recipe_validation_status: Option<String>,
    #[serde(default)]
    program_recovery_recipe_validation_failures: Vec<String>,
    #[serde(default)]
    program_recovery_recipe_blocker_class: Option<String>,
    #[serde(default)]
    program_recovery_recipe_route_id: Option<String>,
    #[serde(default)]
    program_recovery_recipe_delegation_contract_basis: Option<String>,
    #[serde(default)]
    latest_event_offset: u64,
    #[serde(default)]
    latest_event_index: u64,
    #[serde(default)]
    latest_event_sha256: Option<String>,
    #[serde(default)]
    event_log_sha256: Option<String>,
    #[serde(default)]
    derived_from_event_index: u64,
    #[serde(default)]
    atomic_barrier_state: Option<ProgramAtomicBarrierState>,
    #[serde(default)]
    cancelled_at: Option<String>,
    #[serde(default)]
    cancel_reason: Option<String>,
    #[serde(default)]
    cancellation_evidence_path: Option<String>,
    terminal_outcome: Option<String>,
    final_verdict: String,
    resume_instruction: String,
}

fn default_invocation_authority_unattended() -> String {
    "unattended".to_string()
}

#[derive(Clone, Debug, Default, Deserialize, Serialize)]
struct ProgramChildCheckpointState {
    child_lifecycle_id: String,
    target: String,
    current_state: Option<String>,
    final_verdict: String,
    #[serde(default)]
    receipt_digests: BTreeMap<String, String>,
    #[serde(default)]
    gate_status: ProgramChildGateStatus,
    #[serde(default)]
    dependency_gate_status: BTreeMap<String, ProgramDependencyGateStatus>,
    #[serde(default)]
    write_scopes: Vec<String>,
}

struct ProgramContext {
    loaded: LoadedContract,
    target_abs: PathBuf,
    target_rel: String,
    parent_manifest_status: Option<String>,
    registry_rel: String,
    registry_digest: String,
    registry: ProgramChildRegistry,
}

struct ProgramParentContext {
    loaded: LoadedContract,
    target_abs: PathBuf,
    target_rel: String,
    parent_manifest_status: Option<String>,
    registry_abs: PathBuf,
    registry_rel: String,
}

struct ChildExecutionJob {
    child_id: String,
    child_run_id: String,
    route_id: String,
    request: LifecycleRouteExecutionRequest,
    lock_path: PathBuf,
    max_attempts: u32,
    blocker_class: Option<String>,
    unsafe_repair: Option<ProgramUnsafeRepairEvidence>,
}

struct ChildExecutionOutcome {
    summary: ProgramChildExecutionSummary,
    lock_path: PathBuf,
}

#[derive(Clone, Debug)]
struct ProgramRecoveryActionOutcome {
    action_id: String,
    blocker_class: String,
    status: String,
    evidence_path: String,
    failed_command: Option<String>,
    error_message: Option<String>,
}

struct ProgramLifecycleStepOutcome {
    result: ProgramLifecycleRunResult,
    plan: ProgramLifecyclePlanResult,
    dispatch_attempted: bool,
}

#[derive(Clone, Copy, Debug)]
struct ProgramExecutionStepContext {
    step_index: u32,
    step_number: u32,
}

impl ProgramExecutionStepContext {
    fn from_steps_used(steps_used: u32) -> Self {
        Self {
            step_index: steps_used,
            step_number: steps_used + 1,
        }
    }
}

#[derive(Clone, Debug, Deserialize, Serialize)]
pub(crate) struct ProgramApprovalGrant {
    child_id: String,
    route_id: String,
    #[serde(default)]
    human_only_boundary: String,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    blocker_class: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    registry_digest: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    authority_zone: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    operation_class: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    artifact_class: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    write_scope_digest: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    source_authority_digest: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    grant_scope_digest: Option<String>,
    reason: String,
    recorded_at: String,
    evidence_path: String,
}

fn human_only_boundary_for_blocker_class(blocker_class: Option<&str>) -> &'static str {
    match blocker_class {
        Some("policy-override") => "policy-override",
        Some("governance-mutation") => "governance-mutation",
        Some("unsafe-resume") => "unsafe-resume",
        Some("external-irreversible-effect") => "external-irreversible-effect",
        Some("stale-receipt") | Some("publication-drift") => "stale-evidence-acceptance",
        Some("authority-zone-ambiguous")
        | Some("authority-boundary-ambiguous")
        | Some("authority-ambiguity")
        | None => "authority-ambiguity",
        Some("scope-expansion")
        | Some("write-scope-conflict")
        | Some("atomic-write-scope-conflict") => "scope-expansion",
        _ => "unresolved-risk-acceptance",
    }
}

#[derive(Clone, Debug, Deserialize, Serialize)]
pub(crate) struct ProgramEvent {
    schema_version: String,
    run_id: String,
    event_index: u64,
    #[serde(default)]
    previous_event_sha256: Option<String>,
    #[serde(default)]
    event_sha256: Option<String>,
    event_type: String,
    #[serde(default)]
    event_category: Option<String>,
    recorded_at: String,
    #[serde(default)]
    actor: Option<String>,
    #[serde(default)]
    registry_digest: Option<String>,
    #[serde(default)]
    checkpoint_digest: Option<String>,
    #[serde(default)]
    child_id: Option<String>,
    #[serde(default)]
    route_id: Option<String>,
    #[serde(default)]
    atomic_phase: Option<String>,
    message: String,
    #[serde(default)]
    data: BTreeMap<String, String>,
}

#[derive(Clone, Debug, Default, Deserialize, Serialize, PartialEq, Eq)]
pub(crate) struct ProgramAtomicBarrierState {
    pub phase: String,
    #[serde(default)]
    pub staged_children: Vec<String>,
    #[serde(default)]
    pub committed_children: Vec<String>,
    #[serde(default)]
    pub compensated_children: Vec<String>,
    #[serde(default)]
    pub verified: bool,
    #[serde(default)]
    pub unsafe_reason: Option<String>,
}

#[derive(Clone, Debug, Serialize)]
pub(crate) struct ProgramLifecycleInspectResult {
    pub schema_version: String,
    pub run_id: String,
    pub lifecycle_id: String,
    pub target: String,
    pub execution_mode: String,
    pub final_verdict: String,
    pub terminal_outcome: Option<String>,
    pub latest_event_offset: u64,
    pub event_log_path: String,
    #[serde(default)]
    pub scheduler_decision: Vec<String>,
    #[serde(default)]
    pub approvals: Vec<ProgramApprovalGrant>,
    #[serde(default)]
    pub recent_events: Vec<ProgramEvent>,
}

#[derive(Clone, Debug, Serialize)]
pub(crate) struct ProgramLifecycleBlockerExplanation {
    pub schema_version: String,
    pub run_id: String,
    pub final_verdict: String,
    #[serde(default)]
    pub program_route: Option<RoutePlanState>,
    #[serde(default)]
    pub program_gate_results: Vec<GatePlanResult>,
    #[serde(default)]
    pub blocked_by_program_gate: Option<String>,
    #[serde(default)]
    pub parent_receipt_states: BTreeMap<String, ReceiptPlanState>,
    #[serde(default)]
    pub program_blockers: Vec<ProgramBlocker>,
    #[serde(default)]
    pub child_blockers: BTreeMap<String, Vec<ProgramBlocker>>,
    pub retry_instruction: String,
}

#[derive(Clone, Debug, Serialize)]
pub(crate) struct ProgramLifecycleControlResult {
    pub schema_version: String,
    pub run_id: String,
    pub action: String,
    pub final_verdict: String,
    pub evidence_path: String,
    pub latest_event_offset: u64,
}

#[derive(Clone, Debug, Serialize)]
pub(crate) struct ProgramLifecycleReplayResult {
    pub schema_version: String,
    pub run_id: String,
    pub verified: bool,
    pub verdict: String,
    pub legacy_event_log: bool,
    pub events_replayed: usize,
    #[serde(default)]
    pub latest_event_sha256: Option<String>,
    #[serde(default)]
    pub event_log_sha256: Option<String>,
    #[serde(default)]
    pub checkpoint_event_index: u64,
    #[serde(default)]
    pub checkpoint_event_sha256: Option<String>,
    #[serde(default)]
    pub warnings: Vec<String>,
    #[serde(default)]
    pub errors: Vec<String>,
}

#[derive(Clone, Debug, Serialize)]
pub(crate) struct ProgramLifecycleStatusReadModel {
    pub schema_version: String,
    pub authority_notice: String,
    pub run_id: String,
    pub lifecycle_id: String,
    pub target: String,
    pub execution_mode: String,
    pub final_verdict: String,
    #[serde(default)]
    pub terminal_outcome: Option<String>,
    pub registry_digest: String,
    pub latest_event_index: u64,
    #[serde(default)]
    pub event_log_sha256: Option<String>,
    #[serde(default)]
    pub dag: BTreeMap<String, Vec<String>>,
    #[serde(default)]
    pub runnable_batch: Vec<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub scheduler_phase: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Vec::is_empty")]
    pub skipped_blocked_children: Vec<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "BTreeMap::is_empty")]
    pub required_child_completion: BTreeMap<String, ProgramRequiredChildCompletion>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub stop_reason: Option<String>,
    #[serde(default)]
    pub program_route: Option<RoutePlanState>,
    #[serde(default)]
    pub program_gate_results: Vec<GatePlanResult>,
    #[serde(default)]
    pub blocked_by_program_gate: Option<String>,
    #[serde(default)]
    pub parent_receipt_states: BTreeMap<String, ReceiptPlanState>,
    #[serde(default)]
    pub program_blockers: Vec<ProgramBlocker>,
    #[serde(default)]
    pub normalized_program_blockers: Vec<ProgramTaxonomyEvidence>,
    #[serde(default)]
    pub child_blockers: BTreeMap<String, Vec<ProgramBlocker>>,
    #[serde(default)]
    pub normalized_child_blockers: BTreeMap<String, Vec<ProgramTaxonomyEvidence>>,
    #[serde(default)]
    pub normalized_approval_blockers: Vec<ProgramTaxonomyEvidence>,
    #[serde(default)]
    pub approvals: Vec<ProgramApprovalGrant>,
    #[serde(default)]
    pub recovery_attempts: BTreeMap<String, u32>,
    #[serde(default)]
    pub atomic_barrier_state: Option<ProgramAtomicBarrierState>,
    #[serde(default)]
    pub evidence_completeness: BTreeMap<String, bool>,
    #[serde(default)]
    pub rollback_posture: BTreeMap<String, String>,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
struct ProgramMutationSpec {
    schema_version: String,
    expected_registry_digest: String,
    action: String,
    child_id: String,
    #[serde(default)]
    replacement_child_id: Option<String>,
    #[serde(default)]
    path: Option<String>,
    #[serde(default)]
    dependencies: Vec<String>,
    #[serde(default)]
    phase_id: Option<String>,
    #[serde(default)]
    group_id: Option<String>,
    #[serde(default)]
    deferred: Option<bool>,
    #[serde(default)]
    supersession_evidence: Option<String>,
    #[serde(default)]
    rollback_posture: Option<String>,
    #[serde(default)]
    dependency_gate: Option<String>,
    #[serde(default)]
    recovery_profile: Option<String>,
    #[serde(default)]
    write_scopes: Vec<String>,
    rationale: String,
}

#[derive(Clone, Debug, Serialize)]
pub(crate) struct ProgramMutationResult {
    pub schema_version: String,
    pub run_id: String,
    pub action: String,
    pub child_id: String,
    pub applied: bool,
    #[serde(default)]
    pub idempotent: bool,
    pub evidence_path: String,
    #[serde(default)]
    pub registry_path: Option<String>,
    #[serde(default)]
    pub previous_registry_digest: Option<String>,
    #[serde(default)]
    pub new_registry_digest: Option<String>,
    #[serde(default)]
    pub latest_event_offset: Option<u64>,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
struct ProgramScaffoldSpec {
    schema_version: String,
    #[serde(default)]
    program_id: Option<String>,
    title: String,
    #[serde(default)]
    parent_kind: Option<String>,
    execution_mode: String,
    seed_reference_child: ProgramScaffoldChildSpec,
    #[serde(default)]
    follow_on_child_candidates: Vec<ProgramScaffoldChildSpec>,
    rationale: String,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
struct ProgramScaffoldChildSpec {
    child_id: String,
    path: String,
    #[serde(default)]
    dependencies: Vec<String>,
    #[serde(default)]
    phase_id: Option<String>,
    #[serde(default)]
    group_id: Option<String>,
    #[serde(default)]
    required: Option<bool>,
    #[serde(default)]
    deferred: Option<bool>,
    #[serde(default)]
    rollback_posture: Option<String>,
    #[serde(default)]
    write_scopes: Vec<String>,
    #[serde(default)]
    seed_role: Option<String>,
}

#[derive(Clone, Debug, Serialize)]
pub(crate) struct ProgramScaffoldResult {
    pub schema_version: String,
    pub target: String,
    pub dry_run: bool,
    #[serde(default)]
    pub generated_paths: Vec<String>,
    pub child_count: usize,
    pub execution_mode: String,
    pub seed_reference_child: String,
    pub validation_verdict: String,
}

#[derive(Clone, Debug, Serialize)]
struct ProgramCloseoutReceipt {
    schema_version: String,
    run_id: String,
    lifecycle_id: String,
    execution_strategy: String,
    target: String,
    execution_mode: String,
    final_verdict: String,
    aggregate_state: String,
    #[serde(default)]
    checks: BTreeMap<String, String>,
    authority_boundary: String,
}

pub(crate) fn program_checkpoint_exists(octon_dir: &Path, run_id: &str) -> Result<bool> {
    Ok(program_checkpoint_path_for_run(octon_dir, run_id)?.is_file())
}

pub(crate) fn plan_program_lifecycle_from_octon_dir(
    octon_dir: &Path,
    lifecycle_id: &str,
    target: &Path,
) -> Result<ProgramLifecyclePlanResult> {
    plan_program_lifecycle_from_octon_dir_with_checkpoint_and_policy(
        octon_dir,
        lifecycle_id,
        target,
        None,
        "unattended",
    )
}

fn plan_program_lifecycle_from_octon_dir_with_checkpoint(
    octon_dir: &Path,
    lifecycle_id: &str,
    target: &Path,
    checkpoint: Option<&ProgramLifecycleCheckpoint>,
) -> Result<ProgramLifecyclePlanResult> {
    plan_program_lifecycle_from_octon_dir_with_checkpoint_and_policy(
        octon_dir,
        lifecycle_id,
        target,
        checkpoint,
        "unattended",
    )
}

fn plan_program_lifecycle_from_octon_dir_with_checkpoint_and_policy(
    octon_dir: &Path,
    lifecycle_id: &str,
    target: &Path,
    checkpoint: Option<&ProgramLifecycleCheckpoint>,
    invocation_authority: &str,
) -> Result<ProgramLifecyclePlanResult> {
    let repo_root = repo_root_for_octon(octon_dir)?;
    let parent_context = load_program_parent_context(octon_dir, lifecycle_id, target)?;
    let loaded = parent_context.loaded.clone();
    let program = loaded
        .contract
        .program
        .as_ref()
        .context("lifecycle contract is not a program lifecycle")?;
    let execution_strategy = resolve_lifecycle_execution_strategy(&loaded.contract)?;
    validate_authority_boundaries(program)?;

    let target_state =
        build_target_state(&repo_root, &loaded.contract, &parent_context.target_abs)?;
    let parent_receipt_states = receipt_plan_states(&repo_root, &loaded.contract, &target_state);
    let terminal_outcome = select_terminal_outcome(&loaded.contract, &target_state)?;
    let mut program_blockers = Vec::new();
    let (mut program_route, mut program_gate_results, blocked_by_program_gate) =
        if terminal_outcome.is_some() {
            (None, Vec::new(), None)
        } else {
            plan_program_level_route(&repo_root, &parent_context, &mut program_blockers)?
        };

    if !parent_context.registry_abs.is_file() {
        if program_route.is_none() {
            program_blockers.push(ProgramBlocker {
                blocker_class: "missing-evidence".to_string(),
                message: format!(
                    "program child registry missing: {}",
                    parent_context.registry_rel
                ),
                recovery_route: Some("create-program".to_string()),
            });
        }
        let final_verdict = if terminal_outcome.is_some() {
            "completed".to_string()
        } else if program_route.is_some() {
            "route-ready".to_string()
        } else {
            "blocked-recoverable".to_string()
        };
        let normalized_program_blockers =
            normalized_program_blockers(Some(program), &program_blockers);
        return Ok(ProgramLifecyclePlanResult {
            schema_version: "octon-program-lifecycle-plan-v1".to_string(),
            lifecycle_id: loaded.contract.lifecycle_id,
            owner_extension: loaded.contract.owner_extension,
            execution_strategy: execution_strategy.as_str().to_string(),
            contract_path: rel_display(&repo_root, &loaded.path),
            target: parent_context.target_rel,
            parent_manifest_status: parent_context.parent_manifest_status,
            child_registry_path: parent_context.registry_rel,
            child_registry_schema_version: "missing".to_string(),
            child_registry_digest: MISSING_CHILD_REGISTRY_DIGEST.to_string(),
            execution_mode: "unknown".to_string(),
            aggregate_state: final_verdict.clone(),
            terminal_outcome,
            parent_receipt_states,
            program_route,
            program_gate_results,
            blocked_by_program_gate,
            program_blockers,
            normalized_program_blockers,
            child_states: BTreeMap::new(),
            normalized_child_blockers: BTreeMap::new(),
            runnable_batch: Vec::new(),
            scheduler_phase: None,
            skipped_blocked_children: Vec::new(),
            required_child_completion: BTreeMap::new(),
            closeout_hygiene_suppressions: BTreeMap::new(),
            safe_repair_candidates: Vec::new(),
            program_recovery_recipe_validation_status: None,
            program_recovery_recipe_validation_failures: Vec::new(),
            program_recovery_recipe_blocker_class: None,
            program_recovery_recipe_route_id: None,
            program_recovery_recipe_delegation_contract_basis: None,
            unsafe_results: Vec::new(),
            unsafe_continuation_decision: None,
            approval_blockers: Vec::new(),
            normalized_approval_blockers: Vec::new(),
            checkpoint_drift: None,
            stop_reason: Some("missing-child-registry".to_string()),
            final_verdict,
        });
    }

    let registry_digest = file_digest(&parent_context.registry_abs)
        .unwrap_or_else(|_| INVALID_CHILD_REGISTRY_DIGEST.to_string());
    let registry = match serde_yaml::from_slice::<ProgramChildRegistry>(&fs::read(
        &parent_context.registry_abs,
    )?) {
        Ok(registry) => registry,
        Err(error) => {
            program_blockers.push(ProgramBlocker {
                blocker_class: "validation-failed".to_string(),
                message: format!(
                    "failed to parse child registry {}: {error}",
                    parent_context.registry_rel
                ),
                recovery_route: Some("create-program".to_string()),
            });
            let normalized_program_blockers =
                normalized_program_blockers(Some(program), &program_blockers);
            return Ok(ProgramLifecyclePlanResult {
                schema_version: "octon-program-lifecycle-plan-v1".to_string(),
                lifecycle_id: loaded.contract.lifecycle_id,
                owner_extension: loaded.contract.owner_extension,
                execution_strategy: execution_strategy.as_str().to_string(),
                contract_path: rel_display(&repo_root, &loaded.path),
                target: parent_context.target_rel,
                parent_manifest_status: parent_context.parent_manifest_status,
                child_registry_path: parent_context.registry_rel,
                child_registry_schema_version: "invalid".to_string(),
                child_registry_digest: registry_digest,
                execution_mode: "unknown".to_string(),
                aggregate_state: "blocked-unsafe".to_string(),
                terminal_outcome,
                parent_receipt_states,
                program_route,
                program_gate_results,
                blocked_by_program_gate,
                program_blockers,
                normalized_program_blockers,
                child_states: BTreeMap::new(),
                normalized_child_blockers: BTreeMap::new(),
                runnable_batch: Vec::new(),
                scheduler_phase: None,
                skipped_blocked_children: Vec::new(),
                required_child_completion: BTreeMap::new(),
                closeout_hygiene_suppressions: BTreeMap::new(),
                safe_repair_candidates: Vec::new(),
                program_recovery_recipe_validation_status: None,
                program_recovery_recipe_validation_failures: Vec::new(),
                program_recovery_recipe_blocker_class: None,
                program_recovery_recipe_route_id: None,
                program_recovery_recipe_delegation_contract_basis: None,
                unsafe_results: Vec::new(),
                unsafe_continuation_decision: None,
                approval_blockers: Vec::new(),
                normalized_approval_blockers: Vec::new(),
                checkpoint_drift: None,
                stop_reason: Some("invalid-child-registry".to_string()),
                final_verdict: "blocked-unsafe".to_string(),
            });
        }
    };
    let context = ProgramContext {
        loaded: loaded.clone(),
        target_abs: parent_context.target_abs,
        target_rel: parent_context.target_rel,
        parent_manifest_status: parent_context.parent_manifest_status,
        registry_rel: parent_context.registry_rel,
        registry_digest,
        registry,
    };
    if let Err(error) = validate_program_registry(&context.registry) {
        program_blockers.push(ProgramBlocker {
            blocker_class: "validation-failed".to_string(),
            message: error.to_string(),
            recovery_route: None,
        });
        let normalized_program_blockers =
            normalized_program_blockers(Some(program), &program_blockers);
        return Ok(ProgramLifecyclePlanResult {
            schema_version: "octon-program-lifecycle-plan-v1".to_string(),
            lifecycle_id: context.loaded.contract.lifecycle_id,
            owner_extension: context.loaded.contract.owner_extension,
            execution_strategy: execution_strategy.as_str().to_string(),
            contract_path: rel_display(&repo_root, &context.loaded.path),
            target: context.target_rel,
            parent_manifest_status: context.parent_manifest_status,
            child_registry_path: context.registry_rel,
            child_registry_schema_version: context.registry.schema_version,
            child_registry_digest: context.registry_digest,
            execution_mode: context.registry.execution_mode,
            aggregate_state: "blocked-unsafe".to_string(),
            terminal_outcome,
            parent_receipt_states,
            program_route,
            program_gate_results,
            blocked_by_program_gate,
            program_blockers,
            normalized_program_blockers,
            child_states: BTreeMap::new(),
            normalized_child_blockers: BTreeMap::new(),
            runnable_batch: Vec::new(),
            scheduler_phase: None,
            skipped_blocked_children: Vec::new(),
            required_child_completion: BTreeMap::new(),
            closeout_hygiene_suppressions: BTreeMap::new(),
            safe_repair_candidates: Vec::new(),
            program_recovery_recipe_validation_status: None,
            program_recovery_recipe_validation_failures: Vec::new(),
            program_recovery_recipe_blocker_class: None,
            program_recovery_recipe_route_id: None,
            program_recovery_recipe_delegation_contract_basis: None,
            unsafe_results: Vec::new(),
            unsafe_continuation_decision: None,
            approval_blockers: Vec::new(),
            normalized_approval_blockers: Vec::new(),
            checkpoint_drift: None,
            stop_reason: Some("invalid-child-registry".to_string()),
            final_verdict: "blocked-unsafe".to_string(),
        });
    }

    let mut child_states = BTreeMap::new();
    let child_default_lifecycle = context
        .registry
        .default_child_lifecycle_id
        .as_deref()
        .or(program.child_lifecycle_id_default.as_deref())
        .unwrap_or(DEFAULT_CHILD_LIFECYCLE_ID);

    for child in &context.registry.children {
        let child_lifecycle_id = child
            .child_lifecycle_id
            .as_deref()
            .unwrap_or(child_default_lifecycle)
            .to_string();
        let declared_child_target_abs =
            resolve_lifecycle_target_path(&repo_root, Path::new(&child.path))?;
        let child_target_abs = resolve_program_child_target(&declared_child_target_abs)?;
        let child_target_rel = rel_display(&repo_root, &child_target_abs);
        let mut blockers = Vec::new();
        let mut selected_route = None;
        let mut terminal_outcome = None;
        let mut final_verdict = "deferred".to_string();
        let mut receipt_digests = BTreeMap::new();
        let mut gate_status = ProgramChildGateStatus::default();
        let mut write_scopes = declared_or_default_write_scopes(child, &child_target_rel)?;

        if child.deferred {
            blockers.push(ProgramBlocker {
                blocker_class: "deferred".to_string(),
                message: "child is explicitly deferred by the program registry".to_string(),
                recovery_route: None,
            });
        } else {
            match plan_lifecycle_from_octon_dir(
                octon_dir,
                &child_lifecycle_id,
                Path::new(&child_target_rel),
            ) {
                Ok(plan) => {
                    selected_route = plan.next_route.clone();
                    terminal_outcome = plan.terminal_outcome.clone();
                    final_verdict = plan.final_verdict.clone();
                    receipt_digests = receipt_digest_map(&plan);
                    gate_status = child_gate_status_from_lifecycle_plan(&plan);
                    if plan.terminal_outcome.as_deref() != Some("archived") {
                        let worktree_hygiene_blocked =
                            lifecycle_plan_has_worktree_hygiene_blocker(&plan);
                        if worktree_hygiene_blocked {
                            blockers.push(ProgramBlocker {
                                blocker_class: "artifact-ownership-unclear".to_string(),
                                message: "child closeout is blocked by foreign or ambiguous worktree hygiene; route through closeout-change or operator scope resolution".to_string(),
                                recovery_route: None,
                            });
                        }
                        if plan
                            .receipt_states
                            .values()
                            .any(|receipt| receipt.stale == Some(true))
                        {
                            blockers.push(ProgramBlocker {
                                blocker_class: "stale-receipt".to_string(),
                                message: "one or more child receipts are stale".to_string(),
                                recovery_route: selected_route
                                    .as_ref()
                                    .map(|route| route.route_id.clone()),
                            });
                        }
                        if plan.receipt_states.values().any(|receipt| {
                            receipt.exists && !receipt.missing_required_fields.is_empty()
                        }) {
                            blockers.push(ProgramBlocker {
                                blocker_class: "missing-evidence".to_string(),
                                message: "one or more existing child receipts are missing required fields"
                                    .to_string(),
                                recovery_route: selected_route
                                    .as_ref()
                                    .map(|route| route.route_id.clone()),
                            });
                        }
                        if let Some(blocker_class) =
                            child_implementation_blocker_class(&plan, &child_target_abs)
                        {
                            blockers.push(ProgramBlocker {
                                blocker_class: blocker_class.to_string(),
                                message: child_implementation_blocker_message(blocker_class),
                                recovery_route: selected_route
                                    .as_ref()
                                    .map(|route| route.route_id.clone()),
                            });
                        }
                        if plan.final_verdict == "blocked-gate" {
                            blockers.push(ProgramBlocker {
                                blocker_class: "validation-failed".to_string(),
                                message: "child lifecycle gate failed".to_string(),
                                recovery_route: selected_route
                                    .as_ref()
                                    .map(|route| route.route_id.clone()),
                            });
                        } else if plan.final_verdict == "blocked-no-route"
                            && !worktree_hygiene_blocked
                        {
                            blockers.push(ProgramBlocker {
                                blocker_class: "missing-evidence".to_string(),
                                message: "child is not terminal and has no selectable route"
                                    .to_string(),
                                recovery_route: None,
                            });
                        }
                    }
                    match child_write_scopes(child, &child_target_abs, &child_target_rel) {
                        Ok(scopes) => write_scopes = scopes,
                        Err(error) => blockers.push(ProgramBlocker {
                            blocker_class: "authority-boundary-ambiguous".to_string(),
                            message: error.to_string(),
                            recovery_route: None,
                        }),
                    }
                }
                Err(error) => {
                    final_verdict = "blocked-unsafe".to_string();
                    blockers.push(ProgramBlocker {
                        blocker_class: "unsafe-resume".to_string(),
                        message: error.to_string(),
                        recovery_route: None,
                    });
                }
            }
        }

        child_states.insert(
            child.child_id.clone(),
            ProgramChildPlanState {
                child_id: child.child_id.clone(),
                child_lifecycle_id,
                target: child_target_rel,
                required: child.required,
                deferred: child.deferred,
                dependencies: child.dependencies.clone(),
                dependency_gate: child.dependency_gate.clone(),
                phase_id: child.phase_id.clone(),
                group_id: child.group_id.clone(),
                seed_role: child.seed_role.clone(),
                rollback_posture: child.rollback_posture.clone(),
                recovery_profile: child.recovery_profile.clone(),
                phase_commit_barrier: child.phase_commit_barrier.clone(),
                selected_route,
                terminal_outcome,
                receipt_digests,
                gate_status,
                dependency_gate_status: BTreeMap::new(),
                write_scopes,
                blockers,
                final_verdict,
            },
        );
    }

    apply_checkpoint_child_drift(&repo_root, &mut child_states, checkpoint);
    apply_dependency_blockers(&mut child_states);
    let closeout_hygiene_suppressions =
        apply_closeout_hygiene_suppressions(&repo_root, checkpoint, &mut child_states)?;
    apply_lifecycle_residue_cleanup_blocker(
        &context.loaded.contract,
        program,
        &closeout_hygiene_suppressions,
        checkpoint,
        invocation_authority,
        &mut program_blockers,
    );
    if !program
        .supported_execution_modes
        .iter()
        .any(|mode| mode == &context.registry.execution_mode)
    {
        program_blockers.push(ProgramBlocker {
            blocker_class: "unsupported-mode-config".to_string(),
            message: format!(
                "program execution mode {} is not declared by the lifecycle contract",
                context.registry.execution_mode
            ),
            recovery_route: None,
        });
    }
    if context.registry.execution_mode == "program-atomic" {
        apply_atomic_preflight_blockers(
            octon_dir,
            program,
            &context.registry,
            &mut child_states,
            &mut program_blockers,
        )?;
    }
    apply_closeout_policy_blockers(
        octon_dir,
        &repo_root,
        program,
        &context.registry,
        &context.target_rel,
        &child_states,
        &mut program_blockers,
    )?;
    apply_child_receipt_recovery_routes(octon_dir, &repo_root, program, &mut child_states)?;
    apply_executor_result_retry_blockers(&mut child_states, checkpoint);
    apply_program_recovery_action_budget_blockers(
        program,
        &mut child_states,
        &mut program_blockers,
        checkpoint,
    );
    apply_recovery_progress_blockers(program, &mut child_states, checkpoint);
    apply_recovery_budget_blockers(program, &mut child_states, checkpoint);
    apply_recovery_approval_blockers(
        program,
        &context.registry_digest,
        &mut child_states,
        checkpoint.map(|checkpoint| &checkpoint.approvals),
        invocation_authority,
    );
    apply_recovery_dependent_handling(
        program,
        &context.registry,
        &mut child_states,
        &mut program_blockers,
    );
    apply_recoverable_dispatchability_blockers(program, &mut child_states, &mut program_blockers);

    if program_route.is_none() && terminal_outcome.is_none() {
        let structure_results = run_program_gate_by_id(
            &repo_root,
            &context.loaded.contract,
            &context.target_abs,
            "program-structure",
        )?;
        if let Some(failed) = structure_results.iter().find(|result| !result.passed) {
            program_blockers.push(ProgramBlocker {
                blocker_class: "validation-failed".to_string(),
                message: format!("program scheduling failed required gate {}", failed.gate_id),
                recovery_route: None,
            });
        }
        program_gate_results.extend(structure_results);
    }
    let mut program_recovery_recipe_validation = ProgramRecoveryRecipeValidationEvidence::default();
    if terminal_outcome.is_none() {
        let repair_selection = selected_program_repair_blocker_with_validation(
            &context.loaded.contract,
            program,
            &program_blockers,
        );
        if let Some(selection) = repair_selection.selection {
            program_recovery_recipe_validation = selection.validation;
            program_route = Some(selection.route);
        } else if let Some(validation) = repair_selection.validation {
            program_recovery_recipe_validation = validation;
            program_route = None;
        } else if program_blockers.iter().any(|blocker| {
            classify_program_blocker_class(&blocker.blocker_class)
                == ProgramBlockerDisposition::Unsafe
        }) {
            program_route = None;
        } else if program_route.is_none() {
            program_route = selected_program_recoverable_route(
                &context.loaded.contract,
                program,
                &program_blockers,
            );
        }
    }

    let mut runnable_batch = select_runnable_batch(program, &context.registry, &mut child_states);
    if program_route.is_some()
        || terminal_outcome.is_some()
        || program_blockers.iter().any(|blocker| {
            matches!(
                classify_program_blocker_class(&blocker.blocker_class),
                ProgramBlockerDisposition::Human
            ) || (blocker.blocker_class == "validation-failed"
                && blocker
                    .message
                    .contains("program scheduling failed required gate"))
        })
    {
        runnable_batch.clear();
    }

    let approval_blockers = collect_approval_blockers(
        octon_dir,
        program,
        &context.registry_digest,
        &child_states,
        checkpoint.map(|c| &c.approvals),
        invocation_authority,
    )?;
    let (aggregate_state, final_verdict) = aggregate_program_state(
        program,
        Some(&context.loaded.contract),
        &child_states,
        &program_blockers,
        &approval_blockers,
        &runnable_batch,
    );
    let terminal_outcome =
        if terminal_outcome.as_deref() == Some("archived") && final_verdict != "completed" {
            None
        } else {
            terminal_outcome
        };
    let (aggregate_state, final_verdict) = if terminal_outcome.as_deref() == Some("rejected") {
        ("completed".to_string(), "completed".to_string())
    } else if program_route.is_some() {
        ("parent-route-ready".to_string(), "route-ready".to_string())
    } else {
        (aggregate_state, final_verdict)
    };
    let scheduler_phase = scheduler_phase_for_batch(&context.registry, &runnable_batch);
    let skipped_blocked_children = skipped_blocked_children(&child_states, &runnable_batch);
    let required_child_completion = required_child_completion_matrix(&child_states);
    let safe_repair_candidates = collect_safe_repair_candidates(
        &context.loaded.contract,
        program,
        &program_blockers,
        &child_states,
    );
    let stop_reason = program_stop_reason(
        program,
        Some(&context.loaded.contract),
        &final_verdict,
        terminal_outcome.as_deref(),
        program_route.as_ref(),
        &program_blockers,
        &approval_blockers,
        &child_states,
        &runnable_batch,
    );
    let checkpoint_drift = checkpoint.and_then(|checkpoint| {
        if checkpoint.child_registry_digest != context.registry_digest {
            Some(format!(
                "checkpoint child_registry_digest {} differed from current {}",
                checkpoint.child_registry_digest, context.registry_digest
            ))
        } else {
            None
        }
    });
    let normalized_program_blockers = normalized_program_blockers(Some(program), &program_blockers);
    let normalized_child_blockers = normalized_child_blockers(Some(program), &child_states);
    let normalized_approval_blockers = normalized_approval_blockers(&approval_blockers);

    Ok(ProgramLifecyclePlanResult {
        schema_version: "octon-program-lifecycle-plan-v1".to_string(),
        lifecycle_id: context.loaded.contract.lifecycle_id,
        owner_extension: context.loaded.contract.owner_extension,
        execution_strategy: execution_strategy.as_str().to_string(),
        contract_path: rel_display(&repo_root, &context.loaded.path),
        target: context.target_rel,
        parent_manifest_status: context.parent_manifest_status,
        child_registry_path: context.registry_rel,
        child_registry_schema_version: context.registry.schema_version,
        child_registry_digest: context.registry_digest,
        execution_mode: context.registry.execution_mode,
        aggregate_state,
        terminal_outcome,
        parent_receipt_states,
        program_route,
        program_gate_results,
        blocked_by_program_gate,
        program_blockers,
        normalized_program_blockers,
        child_states,
        normalized_child_blockers,
        runnable_batch,
        scheduler_phase,
        skipped_blocked_children,
        required_child_completion,
        closeout_hygiene_suppressions,
        safe_repair_candidates,
        program_recovery_recipe_validation_status: program_recovery_recipe_validation.status,
        program_recovery_recipe_validation_failures: program_recovery_recipe_validation.failures,
        program_recovery_recipe_blocker_class: program_recovery_recipe_validation.blocker_class,
        program_recovery_recipe_route_id: program_recovery_recipe_validation.route_id,
        program_recovery_recipe_delegation_contract_basis: program_recovery_recipe_validation
            .delegation_contract_basis,
        unsafe_results: Vec::new(),
        unsafe_continuation_decision: None,
        approval_blockers,
        normalized_approval_blockers,
        checkpoint_drift,
        stop_reason,
        final_verdict,
    })
}

pub(crate) fn run_program_lifecycle_from_octon_dir(
    octon_dir: &Path,
    options: RunLifecycleOptions,
) -> Result<ProgramLifecycleRunResult> {
    let repo_root = repo_root_for_octon(octon_dir)?;
    let run_id = options
        .run_id
        .clone()
        .unwrap_or_else(|| default_run_id(&options.lifecycle_id));
    let sanitized_run_id = sanitize_run_id(&run_id)?;
    let evidence_root = octon_dir
        .join(WORKFLOW_EVIDENCE_ROOT_REL)
        .join(&sanitized_run_id);
    let control_root = octon_dir.join(RUN_CONTROL_ROOT_REL).join(&sanitized_run_id);
    fs::create_dir_all(&evidence_root)?;
    fs::create_dir_all(&control_root)?;

    let previous_checkpoint = read_program_checkpoint_for_run(octon_dir, &run_id)?;
    let parent_context =
        load_program_parent_context(octon_dir, &options.lifecycle_id, &options.target)?;
    let execution_strategy = resolve_lifecycle_execution_strategy(&parent_context.loaded.contract)?;
    let target_rel = parent_context.target_rel.clone();
    let registry_binding_digest = program_registry_binding_digest(&parent_context)?;
    if let Some(checkpoint) = previous_checkpoint.as_ref() {
        validate_program_checkpoint_binding(
            checkpoint,
            &sanitized_run_id,
            &options.lifecycle_id,
            execution_strategy.as_str(),
            &target_rel,
            &registry_binding_digest,
        )?;
    }
    let run_inputs = if options.run_inputs.is_empty() {
        previous_checkpoint
            .as_ref()
            .map(|checkpoint| checkpoint.run_inputs.clone())
            .unwrap_or_default()
    } else {
        if let Some(checkpoint) = previous_checkpoint.as_ref() {
            if !checkpoint.run_inputs.is_empty() && checkpoint.run_inputs != options.run_inputs {
                bail!(
                    "program lifecycle run id {sanitized_run_id} is already bound to different run inputs"
                );
            }
        }
        options.run_inputs.clone()
    };
    append_program_run_started_if_needed(
        &control_root,
        &evidence_root,
        &sanitized_run_id,
        &options.invocation_authority,
    )?;
    if let Some(checkpoint) = previous_checkpoint.as_ref() {
        if program_checkpoint_cancelled(checkpoint)
            || lifecycle_cancellation_token_path(&control_root).exists()
        {
            return Ok(program_cancelled_run_result(
                &repo_root,
                &evidence_root,
                &control_root,
                checkpoint,
                options.executor.as_str(),
            ));
        }
    }

    if !options.execute_routes {
        return Ok(run_program_lifecycle_single_step(
            octon_dir,
            &repo_root,
            &options,
            &sanitized_run_id,
            &target_rel,
            &run_inputs,
            &evidence_root,
            &control_root,
            previous_checkpoint.as_ref(),
            None,
        )?
        .result);
    }

    let max_steps = options.max_steps.unwrap_or(DEFAULT_PROGRAM_MAX_STEPS);
    let mut step_budget = LifecycleStepBudget::new(max_steps);
    let mut all_child_results = Vec::new();
    let mut latest_step: Option<ProgramLifecycleStepOutcome> = None;

    if max_steps == 0 {
        let mut planning_options = options.clone();
        planning_options.execute_routes = false;
        let mut step = run_program_lifecycle_single_step(
            octon_dir,
            &repo_root,
            &planning_options,
            &sanitized_run_id,
            &target_rel,
            &run_inputs,
            &evidence_root,
            &control_root,
            previous_checkpoint.as_ref(),
            Some(ProgramExecutionStepContext::from_steps_used(
                step_budget.steps_used(),
            )),
        )?;
        step.result.route_execution_mode = "none".to_string();
        if program_execute_loop_should_stop(&step.result, &options.invocation_authority)
            || !program_result_has_pending_dispatch(&step.result)
        {
            return Ok(step.result);
        }
        return mark_program_blocked_max_steps(
            octon_dir,
            &options,
            &sanitized_run_id,
            &evidence_root,
            &control_root,
            max_steps,
            step_budget.steps_used(),
            step,
        );
    }

    while !step_budget.exhausted() {
        let checkpoint = read_program_checkpoint_for_run(octon_dir, &run_id)?;
        if let Some(checkpoint) = checkpoint.as_ref() {
            if program_checkpoint_cancelled(checkpoint)
                || lifecycle_cancellation_token_path(&control_root).exists()
            {
                return Ok(program_cancelled_run_result(
                    &repo_root,
                    &evidence_root,
                    &control_root,
                    checkpoint,
                    options.executor.as_str(),
                ));
            }
        }
        let mut step = run_program_lifecycle_single_step(
            octon_dir,
            &repo_root,
            &options,
            &sanitized_run_id,
            &target_rel,
            &run_inputs,
            &evidence_root,
            &control_root,
            checkpoint.as_ref(),
            Some(ProgramExecutionStepContext::from_steps_used(
                step_budget.steps_used(),
            )),
        )?;
        if !step.dispatch_attempted {
            step.result.child_results = all_child_results;
            return Ok(step.result);
        }

        step_budget.consume_dispatch();
        all_child_results.extend(step.result.child_results.clone());
        step.result.child_results = all_child_results.clone();
        rewrite_program_recovery_log(&evidence_root, &all_child_results)?;
        if program_execute_loop_should_stop(&step.result, &options.invocation_authority) {
            return Ok(step.result);
        }
        latest_step = Some(step);
    }

    if let Some(mut step) = latest_step {
        step.result.child_results = all_child_results.clone();
        rewrite_program_recovery_log(&evidence_root, &all_child_results)?;
        return mark_program_blocked_max_steps(
            octon_dir,
            &options,
            &sanitized_run_id,
            &evidence_root,
            &control_root,
            max_steps,
            step_budget.steps_used(),
            step,
        );
    }

    let mut step = run_program_lifecycle_single_step(
        octon_dir,
        &repo_root,
        &options,
        &sanitized_run_id,
        &target_rel,
        &run_inputs,
        &evidence_root,
        &control_root,
        previous_checkpoint.as_ref(),
        Some(ProgramExecutionStepContext::from_steps_used(
            step_budget.steps_used(),
        )),
    )?;
    step.result.child_results = all_child_results;
    mark_program_blocked_max_steps(
        octon_dir,
        &options,
        &sanitized_run_id,
        &evidence_root,
        &control_root,
        max_steps,
        step_budget.steps_used(),
        step,
    )
}

fn run_program_lifecycle_single_step(
    octon_dir: &Path,
    repo_root: &Path,
    options: &RunLifecycleOptions,
    sanitized_run_id: &str,
    target_rel: &str,
    run_inputs: &BTreeMap<String, String>,
    evidence_root: &Path,
    control_root: &Path,
    previous_checkpoint: Option<&ProgramLifecycleCheckpoint>,
    step_context: Option<ProgramExecutionStepContext>,
) -> Result<ProgramLifecycleStepOutcome> {
    let parent_context =
        load_program_parent_context(octon_dir, &options.lifecycle_id, &options.target)?;
    let mut plan = plan_program_lifecycle_from_octon_dir_with_checkpoint_and_policy(
        octon_dir,
        &options.lifecycle_id,
        &options.target,
        previous_checkpoint,
        &options.invocation_authority,
    )?;
    let mut program_recovery_action_attempts = previous_checkpoint
        .map(|checkpoint| checkpoint.program_recovery_action_attempts.clone())
        .unwrap_or_default();
    let mut program_recovery_action_attempted = false;
    let mut residue_cleanup_attempts = previous_checkpoint
        .map(|checkpoint| checkpoint.residue_cleanup_attempts.clone())
        .unwrap_or_default();
    if plan.program_route.is_none() {
        if let Some(child_id) = options.program_child_filter.as_ref() {
            filter_plan_to_child(&mut plan, child_id)?;
        }
    }
    let step_kind = program_step_kind_for_plan(options.execute_routes, &plan);
    append_program_event(
        control_root,
        evidence_root,
        sanitized_run_id,
        "plan-created",
        None,
        None,
        "program lifecycle plan created",
        program_step_event_data(
            step_context.as_ref(),
            step_kind,
            [("final_verdict", plan.final_verdict.as_str())],
        ),
    )?;
    let mut child_results = Vec::new();
    let mut final_verdict = plan.final_verdict.clone();
    let mut terminal_outcome = plan.terminal_outcome.clone();
    write_program_checkpoint_snapshot(
        octon_dir,
        control_root,
        sanitized_run_id,
        &options.lifecycle_id,
        target_rel,
        options.executor,
        &options.invocation_authority,
        run_inputs,
        &plan,
        &child_results,
        &final_verdict,
        terminal_outcome.clone(),
        previous_checkpoint,
        options,
        Some(&residue_cleanup_attempts),
    )?;
    let cancelled_before_dispatch =
        options.execute_routes && lifecycle_cancellation_token_path(control_root).exists();
    if cancelled_before_dispatch {
        final_verdict = "cancelled".to_string();
        terminal_outcome = Some("cancelled".to_string());
        plan.runnable_batch.clear();
        append_program_event(
            control_root,
            evidence_root,
            sanitized_run_id,
            "cancelled",
            None,
            plan.program_route
                .as_ref()
                .map(|route| route.route_id.as_str()),
            "program lifecycle cancellation observed before dispatch",
            program_step_event_data(
                step_context.as_ref(),
                "no-dispatch",
                [("final_verdict", "cancelled")],
            ),
        )?;
    }
    let selected_parent_route = if cancelled_before_dispatch {
        None
    } else {
        plan.program_route.clone()
    };
    let mut parent_route_result = None;
    let mut parent_route_handled = false;

    if !cancelled_before_dispatch && plan.program_route.is_some() {
        parent_route_handled = true;
        if options.execute_routes {
            let before_parent_plan = plan.clone();
            let parent_repair_blocker_class = before_parent_plan
                .program_recovery_recipe_blocker_class
                .clone();
            parent_route_result = execute_parent_program_route(
                octon_dir,
                sanitized_run_id,
                run_inputs,
                options,
                &plan,
                evidence_root,
                control_root,
                step_context,
            )?;
            if let Some(result) = parent_route_result.as_ref() {
                record_residue_cleanup_attempts_for_parent_route(
                    &mut residue_cleanup_attempts,
                    &before_parent_plan,
                    result,
                );
                let mut parent_repair_validation =
                    ProgramRecoveryPostAttemptValidationOutcome::route_not_completed(
                        &result.status,
                        result.error_message.as_deref(),
                        parent_repair_blocker_class.clone(),
                    );
                if matches!(result.status.as_str(), "completed" | "no-op") {
                    let replan_checkpoint =
                        checkpoint_for_post_execution_replan_with_residue_attempts(
                            previous_checkpoint,
                            &residue_cleanup_attempts,
                        );
                    plan = plan_program_lifecycle_from_octon_dir_with_checkpoint_and_policy(
                        octon_dir,
                        &options.lifecycle_id,
                        &options.target,
                        replan_checkpoint.as_ref(),
                        &options.invocation_authority,
                    )?;
                    if let (Some(program), Some(blocker_class)) = (
                        parent_context.loaded.contract.program.as_ref(),
                        parent_repair_blocker_class.as_deref(),
                    ) {
                        parent_repair_validation =
                            enforce_program_recovery_post_attempt_validations(
                                program,
                                &before_parent_plan,
                                &plan,
                                control_root,
                                blocker_class,
                                result,
                                true,
                            );
                    } else {
                        final_verdict = plan.final_verdict.clone();
                        terminal_outcome = plan.terminal_outcome.clone();
                    }
                    if parent_repair_blocker_class.is_some() {
                        if parent_repair_validation.execution_can_resume {
                            final_verdict = plan.final_verdict.clone();
                            terminal_outcome = plan.terminal_outcome.clone();
                        } else if plan_has_safe_continuation_after_unsafe(&plan) {
                            final_verdict = "blocked-recoverable".to_string();
                            terminal_outcome = None;
                        } else {
                            final_verdict = "blocked-unsafe".to_string();
                            terminal_outcome = None;
                        }
                    }
                } else {
                    final_verdict = final_verdict_for_parent_route_status(&result.status);
                    terminal_outcome = if final_verdict == "cancelled" {
                        Some("cancelled".to_string())
                    } else {
                        None
                    };
                }
                if parent_repair_blocker_class.is_some() {
                    finalize_parent_unsafe_repair_evidence(
                        evidence_root,
                        result,
                        &parent_repair_validation,
                    )?;
                }
            }
        } else {
            final_verdict = "route-ready".to_string();
            terminal_outcome = None;
        }
        plan.runnable_batch.clear();
    }

    if !cancelled_before_dispatch
        && options.execute_routes
        && !parent_route_handled
        && !plan.runnable_batch.is_empty()
    {
        if let Some(program) = parent_context.loaded.contract.program.as_ref() {
            if let Some(outcome) = execute_selected_program_recovery_action(
                program,
                &plan,
                previous_checkpoint,
                &mut program_recovery_action_attempts,
                repo_root,
                control_root,
                evidence_root,
                sanitized_run_id,
                step_context,
            )? {
                program_recovery_action_attempted = true;
                if outcome.status == "completed" {
                    let replan_checkpoint =
                        checkpoint_for_post_execution_replan(previous_checkpoint);
                    plan = plan_program_lifecycle_from_octon_dir_with_checkpoint_and_policy(
                        octon_dir,
                        &options.lifecycle_id,
                        &options.target,
                        replan_checkpoint.as_ref(),
                        &options.invocation_authority,
                    )?;
                    if plan.program_route.is_none() {
                        if let Some(child_id) = options.program_child_filter.as_ref() {
                            filter_plan_to_child(&mut plan, child_id)?;
                        }
                    }
                    if let Some(failed_outcome) = enforce_program_recovery_action_post_validations(
                        repo_root,
                        program,
                        &plan,
                        control_root,
                        evidence_root,
                        sanitized_run_id,
                        &outcome,
                        step_context,
                    )? {
                        record_program_recovery_action_failure(
                            &mut plan,
                            &mut final_verdict,
                            &mut terminal_outcome,
                            &failed_outcome,
                        );
                        plan.runnable_batch.clear();
                    } else {
                        final_verdict = plan.final_verdict.clone();
                        terminal_outcome = plan.terminal_outcome.clone();
                    }
                } else {
                    record_program_recovery_action_failure(
                        &mut plan,
                        &mut final_verdict,
                        &mut terminal_outcome,
                        &outcome,
                    );
                    plan.runnable_batch.clear();
                }
            }
        }
    }

    if !cancelled_before_dispatch
        && options.execute_routes
        && !parent_route_handled
        && !plan.runnable_batch.is_empty()
    {
        let max_concurrency = options
            .max_child_concurrency
            .unwrap_or(DEFAULT_MAX_CHILD_CONCURRENCY)
            .max(1);
        let before_child_dispatch_plan = plan.clone();
        let scheduled_children = plan.runnable_batch.join(",");
        append_program_event(
            control_root,
            evidence_root,
            sanitized_run_id,
            "schedule-created",
            None,
            None,
            "program scheduler selected runnable child batch",
            program_step_event_data(
                step_context.as_ref(),
                "child-batch-dispatch",
                [("children", scheduled_children.as_str())],
            ),
        )?;
        child_results = if plan.execution_mode == "program-atomic" {
            execute_atomic_program(
                octon_dir,
                repo_root,
                sanitized_run_id,
                run_inputs,
                options,
                &plan,
                evidence_root,
                control_root,
                previous_checkpoint.map(|checkpoint| &checkpoint.approvals),
            )?
        } else {
            let (jobs, mut preflight_results) = build_child_execution_jobs(
                octon_dir,
                repo_root,
                sanitized_run_id,
                run_inputs,
                options,
                &plan,
                evidence_root,
                control_root,
                previous_checkpoint.map(|checkpoint| &checkpoint.approvals),
                previous_checkpoint,
            )?;
            let mut executed_results = execute_child_jobs(
                repo_root,
                sanitized_run_id,
                control_root,
                evidence_root,
                jobs,
                max_concurrency,
                step_context,
            )?;
            preflight_results.append(&mut executed_results);
            preflight_results
        };
        let replan_checkpoint = checkpoint_for_post_execution_replan(previous_checkpoint);
        plan = plan_program_lifecycle_from_octon_dir_with_checkpoint_and_policy(
            octon_dir,
            &options.lifecycle_id,
            &options.target,
            replan_checkpoint.as_ref(),
            &options.invocation_authority,
        )?;
        if plan.program_route.is_none() {
            if let Some(child_id) = options.program_child_filter.as_ref() {
                filter_plan_to_child(&mut plan, child_id)?;
            }
        }
        if let Some(program) = parent_context.loaded.contract.program.as_ref() {
            enforce_recovery_post_attempt_validations(
                program,
                &plan,
                control_root,
                true,
                &mut child_results,
            )?;
            let publication_post_validation_failed =
                child_results_have_publication_post_validation_failure(&child_results);
            let no_progress_blockers = mark_no_progress_child_results(
                &before_child_dispatch_plan,
                &plan,
                &mut child_results,
                control_root,
                evidence_root,
                sanitized_run_id,
                step_context,
            )?;
            if (publication_post_validation_failed
                || no_progress_blockers
                    .iter()
                    .any(|blocker| blocker == "publication-drift"))
                && !program_recovery_action_attempted
            {
                if let Some(outcome) = execute_selected_program_recovery_action(
                    program,
                    &plan,
                    previous_checkpoint,
                    &mut program_recovery_action_attempts,
                    repo_root,
                    control_root,
                    evidence_root,
                    sanitized_run_id,
                    step_context,
                )? {
                    program_recovery_action_attempted = true;
                    if outcome.status == "completed" {
                        let replan_checkpoint =
                            checkpoint_for_post_execution_replan(previous_checkpoint);
                        plan = plan_program_lifecycle_from_octon_dir_with_checkpoint_and_policy(
                            octon_dir,
                            &options.lifecycle_id,
                            &options.target,
                            replan_checkpoint.as_ref(),
                            &options.invocation_authority,
                        )?;
                        if plan.program_route.is_none() {
                            if let Some(child_id) = options.program_child_filter.as_ref() {
                                filter_plan_to_child(&mut plan, child_id)?;
                            }
                        }
                        if let Some(failed_outcome) =
                            enforce_program_recovery_action_post_validations(
                                repo_root,
                                program,
                                &plan,
                                control_root,
                                evidence_root,
                                sanitized_run_id,
                                &outcome,
                                step_context,
                            )?
                        {
                            record_program_recovery_action_failure(
                                &mut plan,
                                &mut final_verdict,
                                &mut terminal_outcome,
                                &failed_outcome,
                            );
                            plan.runnable_batch.clear();
                        }
                    } else {
                        record_program_recovery_action_failure(
                            &mut plan,
                            &mut final_verdict,
                            &mut terminal_outcome,
                            &outcome,
                        );
                        plan.runnable_batch.clear();
                    }
                } else {
                    plan.runnable_batch.clear();
                }
            } else if !no_progress_blockers.is_empty() {
                plan.runnable_batch.clear();
            }
        }
        finalize_child_unsafe_repair_evidence(evidence_root, &child_results)?;
        plan.unsafe_results = unsafe_result_summaries_for_children(&plan, &child_results);
        plan.unsafe_continuation_decision = if plan.unsafe_results.is_empty() {
            None
        } else if plan
            .unsafe_results
            .iter()
            .any(|result| result.safe_continuation_available)
        {
            Some("safe-continuation-available".to_string())
        } else {
            Some("no-safe-continuation".to_string())
        };
        final_verdict = final_verdict_after_child_execution(&plan, &child_results);
        if final_verdict == "blocked-unsafe"
            && plan.unsafe_continuation_decision.as_deref() == Some("no-safe-continuation")
        {
            plan.runnable_batch.clear();
            plan.program_route = None;
        }
        terminal_outcome = plan.terminal_outcome.clone();
        if final_verdict == "cancelled" {
            terminal_outcome = Some("cancelled".to_string());
        }
    }

    let mut checkpoint = write_program_checkpoint_snapshot(
        octon_dir,
        control_root,
        sanitized_run_id,
        &options.lifecycle_id,
        target_rel,
        options.executor,
        &options.invocation_authority,
        run_inputs,
        &plan,
        &child_results,
        &final_verdict,
        terminal_outcome.clone(),
        previous_checkpoint,
        options,
        Some(&residue_cleanup_attempts),
    )?;
    let checkpoint_path = program_checkpoint_path_for_run(octon_dir, sanitized_run_id)?;
    fs::write(
        evidence_root.join("program-plan.yml"),
        serde_yaml::to_string(&plan)?,
    )?;
    fs::write(
        evidence_root.join("scheduler-decision.yml"),
        serde_yaml::to_string(&plan.runnable_batch)?,
    )?;
    write_run_inputs_evidence(evidence_root, &checkpoint.run_id, &checkpoint.run_inputs)?;
    fs::write(
        evidence_root.join("summary.md"),
        program_lifecycle_summary(sanitized_run_id, &options.executor, &plan, &final_verdict),
    )?;
    fs::write(
        evidence_root.join("recovery-log.yml"),
        serde_yaml::to_string(&child_results)?,
    )?;
    if should_write_program_aggregate_closeout(terminal_outcome.as_deref()) {
        write_program_aggregate_closeout(octon_dir, evidence_root, &checkpoint, &plan)?;
        append_program_event(
            control_root,
            evidence_root,
            sanitized_run_id,
            "closeout",
            None,
            None,
            "program lifecycle aggregate closeout evidence written",
            program_event_data(std::iter::empty::<(&str, &str)>()),
        )?;
        enrich_checkpoint_event_metadata(&mut checkpoint, control_root)?;
        fs::write(&checkpoint_path, serde_yaml::to_string(&checkpoint)?)?;
    }
    let latest_event_offset = count_program_events(control_root)?;
    checkpoint.program_recovery_action_attempts = program_recovery_action_attempts;
    enrich_checkpoint_event_metadata(&mut checkpoint, control_root)?;
    fs::write(&checkpoint_path, serde_yaml::to_string(&checkpoint)?)?;

    let dispatch_attempted = parent_route_result.is_some()
        || !child_results.is_empty()
        || program_recovery_action_attempted;
    let route_execution_mode = if dispatch_attempted {
        "program-adapter-executed"
    } else if options.execute_routes {
        "none"
    } else {
        "program-route-handoff"
    };

    Ok(ProgramLifecycleStepOutcome {
        plan: plan.clone(),
        dispatch_attempted,
        result: ProgramLifecycleRunResult {
            schema_version: "octon-program-lifecycle-run-result-v1".to_string(),
            run_id: sanitized_run_id.to_string(),
            lifecycle_id: options.lifecycle_id.clone(),
            execution_strategy: plan.execution_strategy.clone(),
            target: target_rel.to_string(),
            executor: options.executor.as_str().to_string(),
            route_execution_mode: route_execution_mode.to_string(),
            bundle_root: rel_display(&repo_root, &evidence_root),
            checkpoint_path: rel_display(&repo_root, &checkpoint_path),
            event_log_path: rel_display(&repo_root, &program_control_event_log_path(&control_root)),
            latest_event_offset,
            selected_parent_route,
            parent_route_result,
            selected_children: plan.runnable_batch,
            child_results,
            terminal_outcome,
            final_verdict,
        },
    })
}

fn append_program_run_started_if_needed(
    control_root: &Path,
    evidence_root: &Path,
    run_id: &str,
    invocation_authority: &str,
) -> Result<()> {
    if count_program_events(control_root)? > 0 {
        return Ok(());
    }
    append_program_event(
        control_root,
        evidence_root,
        run_id,
        "run-started",
        None,
        None,
        "program lifecycle run started",
        program_event_data([("invocation_authority", invocation_authority)]),
    )?;
    Ok(())
}

fn checkpoint_for_post_execution_replan(
    checkpoint: Option<&ProgramLifecycleCheckpoint>,
) -> Option<ProgramLifecycleCheckpoint> {
    checkpoint.cloned().map(|mut checkpoint| {
        checkpoint.child_states.clear();
        checkpoint
    })
}

fn rewrite_program_recovery_log(
    evidence_root: &Path,
    child_results: &[ProgramChildExecutionSummary],
) -> Result<()> {
    fs::write(
        evidence_root.join("recovery-log.yml"),
        serde_yaml::to_string(child_results)?,
    )?;
    Ok(())
}

fn program_execute_loop_should_stop(
    result: &ProgramLifecycleRunResult,
    invocation_authority: &str,
) -> bool {
    if result.terminal_outcome.is_some() {
        return true;
    }
    match normalize_program_state_value(&result.final_verdict) {
        ProgramNormalizedCategory::Terminal
        | ProgramNormalizedCategory::Cancellation
        | ProgramNormalizedCategory::Budget => true,
        ProgramNormalizedCategory::Unsafe => !program_result_has_pending_dispatch(result),
        ProgramNormalizedCategory::Human => {
            invocation_authority != "unattended"
                || !program_result_has_agent_continuable_dispatch(result)
        }
        ProgramNormalizedCategory::Recoverable | ProgramNormalizedCategory::Timeout => {
            !program_result_has_pending_dispatch(result)
        }
    }
}

fn program_result_has_pending_dispatch(result: &ProgramLifecycleRunResult) -> bool {
    result.selected_parent_route.is_some() || !result.selected_children.is_empty()
}

fn program_result_has_agent_continuable_dispatch(result: &ProgramLifecycleRunResult) -> bool {
    if !program_result_has_pending_dispatch(result) {
        return false;
    }
    let parent_human_blocked = result
        .parent_route_result
        .as_ref()
        .map(|result| result.status == "human-boundary-blocked")
        .unwrap_or(false);
    let child_non_continuable_blocks = result
        .child_results
        .iter()
        .filter(|summary| {
            matches!(
                summary.status.as_str(),
                "human-boundary-blocked" | "executor-preflight-blocked" | "blocked-human"
            )
        })
        .count();
    if parent_human_blocked
        && result.child_results.is_empty()
        && result.selected_children.is_empty()
    {
        return false;
    }
    result.child_results.iter().any(|summary| {
        !matches!(
            summary.status.as_str(),
            "human-boundary-blocked" | "executor-preflight-blocked" | "blocked-human"
        )
    }) || child_non_continuable_blocks < result.selected_children.len()
}

fn plan_has_safe_continuation_after_unsafe(plan: &ProgramLifecyclePlanResult) -> bool {
    plan.program_route.is_some()
        || !plan.safe_repair_candidates.is_empty()
        || (plan.execution_mode != "program-atomic" && !plan.runnable_batch.is_empty())
}

fn unsafe_result_summaries_for_children(
    plan: &ProgramLifecyclePlanResult,
    child_results: &[ProgramChildExecutionSummary],
) -> Vec<ProgramUnsafeResultSummary> {
    let safe_continuation = plan_has_safe_continuation_after_unsafe(plan);
    let continuation_reason = if safe_continuation {
        if plan.program_route.is_some() {
            "program repair or parent route dispatch remains available"
        } else if !plan.safe_repair_candidates.is_empty() {
            "safe governed repair candidate remains available"
        } else {
            "independent runnable child work remains available"
        }
    } else {
        "no safe governed repair route or independent runnable work remains"
    };
    child_results
        .iter()
        .filter(|result| result.status == "blocked-unsafe")
        .map(|result| ProgramUnsafeResultSummary {
            scope: "child".to_string(),
            child_id: Some(result.child_id.clone()),
            route_id: result.route_id.clone(),
            status: result.status.clone(),
            blocker_class: result.blocker_class.clone(),
            safe_continuation_available: safe_continuation,
            continuation_reason: continuation_reason.to_string(),
        })
        .collect()
}

fn final_verdict_after_child_execution(
    plan: &ProgramLifecyclePlanResult,
    child_results: &[ProgramChildExecutionSummary],
) -> String {
    let execution_had_human_block = child_results.iter().any(|result| {
        matches!(
            result.status.as_str(),
            "authority-ambiguity" | "executor-preflight-blocked" | "blocked-human"
        )
    });
    let execution_had_cancellation = child_results
        .iter()
        .any(|result| result.status == "cancelled");
    let execution_had_failure = child_results.iter().any(|result| {
        matches!(
            result.status.as_str(),
            "failed" | "timed-out" | "blocked" | "blocked-unsafe" | "executor-preflight-blocked"
        )
    });
    let unsafe_results = child_results
        .iter()
        .any(|result| result.status == "blocked-unsafe");
    if execution_had_cancellation {
        "cancelled".to_string()
    } else if unsafe_results && !plan_has_safe_continuation_after_unsafe(plan) {
        "blocked-unsafe".to_string()
    } else if unsafe_results {
        "blocked-recoverable".to_string()
    } else if execution_had_human_block {
        "blocked-human".to_string()
    } else if execution_had_failure {
        "blocked-recoverable".to_string()
    } else {
        plan.final_verdict.clone()
    }
}

fn mark_program_blocked_max_steps(
    octon_dir: &Path,
    options: &RunLifecycleOptions,
    run_id: &str,
    evidence_root: &Path,
    control_root: &Path,
    max_steps: u32,
    steps_used: u32,
    mut step: ProgramLifecycleStepOutcome,
) -> Result<ProgramLifecycleRunResult> {
    let max_steps_value = max_steps.to_string();
    let steps_used_value = steps_used.to_string();
    let verdict =
        if options.max_steps.is_some() && program_result_has_pending_dispatch(&step.result) {
            "step-budget-exhausted-continuable"
        } else {
            "blocked-max-steps"
        };
    append_program_event(
        control_root,
        evidence_root,
        run_id,
        "max-steps-exhausted",
        None,
        None,
        "program lifecycle execute-routes max step budget exhausted",
        program_event_data([
            ("max_steps", max_steps_value.as_str()),
            ("steps_used", steps_used_value.as_str()),
            ("final_verdict", verdict),
        ]),
    )?;

    let checkpoint_path = program_checkpoint_path_for_run(octon_dir, run_id)?;
    let mut checkpoint = read_program_checkpoint_for_run(octon_dir, run_id)?
        .with_context(|| format!("missing program lifecycle checkpoint for run {run_id}"))?;
    checkpoint.final_verdict = verdict.to_string();
    checkpoint.terminal_outcome = None;
    enrich_checkpoint_event_metadata(&mut checkpoint, control_root)?;
    fs::write(&checkpoint_path, serde_yaml::to_string(&checkpoint)?)?;
    fs::write(
        evidence_root.join("summary.md"),
        program_lifecycle_summary(run_id, &options.executor, &step.plan, verdict),
    )?;
    step.result.final_verdict = verdict.to_string();
    step.result.terminal_outcome = None;
    step.result.latest_event_offset = count_program_events(control_root)?;
    Ok(step.result)
}

pub(crate) fn resume_program_lifecycle_from_octon_dir(
    octon_dir: &Path,
    run_id: &str,
) -> Result<ProgramLifecycleRunResult> {
    let checkpoint = read_program_checkpoint_for_run(octon_dir, run_id)?
        .with_context(|| format!("missing program lifecycle checkpoint for run {run_id}"))?;
    let _ = plan_program_lifecycle_from_octon_dir_with_checkpoint(
        octon_dir,
        &checkpoint.lifecycle_id,
        Path::new(&checkpoint.target),
        Some(&checkpoint),
    )?;

    run_program_lifecycle_from_octon_dir(
        octon_dir,
        RunLifecycleOptions {
            lifecycle_id: checkpoint.lifecycle_id,
            target: PathBuf::from(checkpoint.target),
            run_id: Some(run_id.to_string()),
            executor: executor_kind_from_checkpoint(checkpoint.executor.as_deref()),
            max_iterations: None,
            execute_routes: true,
            max_steps: None,
            timeout_seconds: checkpoint.timeout_seconds,
            max_child_concurrency: checkpoint
                .max_child_concurrency
                .or(Some(DEFAULT_MAX_CHILD_CONCURRENCY)),
            invocation_authority: checkpoint.invocation_authority,
            run_inputs: checkpoint.run_inputs,
            program_child_filter: None,
        },
    )
}

pub(crate) fn inspect_program_lifecycle_run(
    octon_dir: &Path,
    run_id: &str,
) -> Result<ProgramLifecycleInspectResult> {
    let checkpoint = read_program_checkpoint_for_run(octon_dir, run_id)?
        .with_context(|| format!("missing program lifecycle checkpoint for run {run_id}"))?;
    let repo_root = repo_root_for_octon(octon_dir)?;
    let control_root = octon_dir
        .join(RUN_CONTROL_ROOT_REL)
        .join(sanitize_run_id(run_id)?);
    let events = read_program_events(&control_root)?;
    Ok(ProgramLifecycleInspectResult {
        schema_version: "octon-program-lifecycle-inspect-v1".to_string(),
        run_id: checkpoint.run_id,
        lifecycle_id: checkpoint.lifecycle_id,
        target: checkpoint.target,
        execution_mode: checkpoint.execution_mode,
        final_verdict: checkpoint.final_verdict,
        terminal_outcome: checkpoint.terminal_outcome,
        latest_event_offset: checkpoint.latest_event_offset,
        event_log_path: rel_display(&repo_root, &program_control_event_log_path(&control_root)),
        scheduler_decision: checkpoint.scheduler_decision,
        approvals: checkpoint.approvals,
        recent_events: events.into_iter().rev().take(20).collect::<Vec<_>>(),
    })
}

pub(crate) fn explain_program_lifecycle_blockers(
    octon_dir: &Path,
    run_id: &str,
) -> Result<ProgramLifecycleBlockerExplanation> {
    let checkpoint = read_program_checkpoint_for_run(octon_dir, run_id)?
        .with_context(|| format!("missing program lifecycle checkpoint for run {run_id}"))?;
    let plan = plan_program_lifecycle_from_octon_dir_with_checkpoint(
        octon_dir,
        &checkpoint.lifecycle_id,
        Path::new(&checkpoint.target),
        Some(&checkpoint),
    )?;
    let child_blockers = plan
        .child_states
        .iter()
        .filter_map(|(child_id, state)| {
            if state.blockers.is_empty() {
                None
            } else {
                Some((child_id.clone(), state.blockers.clone()))
            }
        })
        .collect();
    Ok(ProgramLifecycleBlockerExplanation {
        schema_version: "octon-program-lifecycle-blocker-explanation-v1".to_string(),
        run_id: checkpoint.run_id,
        final_verdict: plan.final_verdict,
        program_route: plan.program_route,
        program_gate_results: plan.program_gate_results,
        blocked_by_program_gate: plan.blocked_by_program_gate,
        parent_receipt_states: plan.parent_receipt_states,
        program_blockers: plan.program_blockers,
        child_blockers,
        retry_instruction: format!("octon lifecycle program retry --run-id {run_id}"),
    })
}

pub(crate) fn approve_program_lifecycle_child_route(
    octon_dir: &Path,
    run_id: &str,
    child_id: &str,
    route_id: &str,
    reason: &str,
) -> Result<ProgramLifecycleControlResult> {
    let mut checkpoint = read_program_checkpoint_for_run(octon_dir, run_id)?
        .with_context(|| format!("missing program lifecycle checkpoint for run {run_id}"))?;
    if !checkpoint.child_states.contains_key(child_id) {
        bail!("program run {run_id} has no child {child_id}");
    }
    let plan = plan_program_lifecycle_from_octon_dir_with_checkpoint(
        octon_dir,
        &checkpoint.lifecycle_id,
        Path::new(&checkpoint.target),
        Some(&checkpoint),
    )?;
    let approval_blocker = plan
        .approval_blockers
        .iter()
        .find(|blocker| blocker.child_id == child_id && blocker.route_id == route_id)
        .with_context(|| {
            format!(
                "program run {run_id} has no current approval blocker for child route {child_id}:{route_id}"
            )
        })?;
    let repo_root = repo_root_for_octon(octon_dir)?;
    let sanitized_run_id = sanitize_run_id(run_id)?;
    let control_root = octon_dir.join(RUN_CONTROL_ROOT_REL).join(&sanitized_run_id);
    let evidence_root = octon_dir
        .join(WORKFLOW_EVIDENCE_ROOT_REL)
        .join(&sanitized_run_id);
    let human_exception_root = evidence_root.join("human-exception-grants");
    fs::create_dir_all(&human_exception_root)?;
    fs::create_dir_all(&control_root)?;
    let evidence_path =
        human_exception_root.join(format!("{child_id}-{route_id}-human-exception-grant.yml"));
    let recorded_at = now_rfc3339()?;
    let human_only_boundary =
        human_only_boundary_for_blocker_class(approval_blocker.blocker_class.as_deref());
    let authority_decision = plan.child_states.get(child_id).map(|state| {
        let approval_operation_class = if approval_blocker
            .blocker_class
            .as_deref()
            .is_some_and(|class| !matches!(class, "authority-ambiguity"))
        {
            OPERATION_CLASS_RETRY_CHILD_ROUTE
        } else {
            OPERATION_CLASS_EXECUTE_CHILD_ROUTE
        };
        child_route_authority_decision(
            &repo_root,
            &sanitized_run_id,
            state,
            route_id,
            approval_operation_class,
        )
    });
    let authority_decision_path = if let Some(decision) = authority_decision.as_ref() {
        Some(write_authority_zone_decision(&evidence_root, decision)?)
    } else {
        None
    };
    fs::write(
        &evidence_path,
        format!(
            "schema_version: octon-program-lifecycle-human-exception-grant-v1\nrun_id: {sanitized_run_id}\nchild_id: {child_id}\nroute_id: {route_id}\nhuman_only_boundary: {human_only_boundary}\nblocker_class: {}\nregistry_digest: {}\nauthority_zone: {}\noperation_class: {}\nartifact_class: {}\nwrite_scope_digest: {}\nauthority_zone_decision: {}\nreason: {reason}\nrecorded_at: {recorded_at}\nresume_instruction: octon lifecycle resume --run-id {sanitized_run_id}\nretry_instruction: octon lifecycle program retry --run-id {sanitized_run_id} --child {child_id}\n",
            approval_blocker
                .blocker_class
                .as_deref()
                .unwrap_or("route-approval"),
            plan.child_registry_digest,
            authority_decision
                .as_ref()
                .map(|decision| decision.authority_zone.as_str())
                .unwrap_or("unknown"),
            authority_decision
                .as_ref()
                .map(|decision| decision.operation_class.as_str())
                .unwrap_or("unknown"),
            authority_decision
                .as_ref()
                .map(|decision| decision.artifact_class.as_str())
                .unwrap_or("unknown"),
            authority_decision
                .as_ref()
                .and_then(|decision| decision.write_scope_digest.as_deref())
                .unwrap_or(""),
            authority_decision_path.as_deref().unwrap_or("")
        ),
    )?;
    let grant = ProgramApprovalGrant {
        child_id: child_id.to_string(),
        route_id: route_id.to_string(),
        human_only_boundary: human_only_boundary.to_string(),
        blocker_class: approval_blocker.blocker_class.clone(),
        registry_digest: Some(plan.child_registry_digest.clone()),
        authority_zone: authority_decision
            .as_ref()
            .map(|decision| decision.authority_zone.clone()),
        operation_class: authority_decision
            .as_ref()
            .map(|decision| decision.operation_class.clone()),
        artifact_class: authority_decision
            .as_ref()
            .map(|decision| decision.artifact_class.clone()),
        write_scope_digest: authority_decision
            .as_ref()
            .and_then(|decision| decision.write_scope_digest.clone()),
        source_authority_digest: authority_decision
            .as_ref()
            .and_then(|decision| decision.source_authority_digest.clone()),
        grant_scope_digest: Some(plan.child_registry_digest.clone()),
        reason: reason.to_string(),
        recorded_at,
        evidence_path: rel_display(&repo_root, &evidence_path),
    };
    checkpoint.approvals.push(grant);
    let latest_event_offset = append_program_event(
        &control_root,
        &evidence_root,
        &sanitized_run_id,
        "human-exception-granted",
        Some(child_id),
        Some(route_id),
        "typed human exception grant recorded",
        event_data([
            ("reason", reason),
            ("human_only_boundary", human_only_boundary),
            ("registry_digest", plan.child_registry_digest.as_str()),
        ]),
    )?;
    checkpoint.final_verdict = "blocked-recoverable".to_string();
    enrich_checkpoint_event_metadata(&mut checkpoint, &control_root)?;
    let checkpoint_path = program_checkpoint_path_for_run(octon_dir, &sanitized_run_id)?;
    fs::write(&checkpoint_path, serde_yaml::to_string(&checkpoint)?)?;
    Ok(ProgramLifecycleControlResult {
        schema_version: "octon-program-lifecycle-control-result-v1".to_string(),
        run_id: sanitized_run_id,
        action: "approve".to_string(),
        final_verdict: checkpoint.final_verdict,
        evidence_path: rel_display(&repo_root, &evidence_path),
        latest_event_offset,
    })
}

pub(crate) fn retry_program_lifecycle_run(
    octon_dir: &Path,
    run_id: &str,
    child: Option<String>,
) -> Result<ProgramLifecycleRunResult> {
    let checkpoint = read_program_checkpoint_for_run(octon_dir, run_id)?
        .with_context(|| format!("missing program lifecycle checkpoint for run {run_id}"))?;
    run_program_lifecycle_from_octon_dir(
        octon_dir,
        RunLifecycleOptions {
            lifecycle_id: checkpoint.lifecycle_id,
            target: PathBuf::from(checkpoint.target),
            run_id: Some(run_id.to_string()),
            executor: executor_kind_from_checkpoint(checkpoint.executor.as_deref()),
            max_iterations: None,
            execute_routes: true,
            max_steps: None,
            timeout_seconds: None,
            max_child_concurrency: Some(DEFAULT_MAX_CHILD_CONCURRENCY),
            invocation_authority: "unattended".to_string(),
            run_inputs: checkpoint.run_inputs,
            program_child_filter: child,
        },
    )
}

fn executor_kind_from_checkpoint(value: Option<&str>) -> ExecutorKind {
    match value {
        Some("mock") => ExecutorKind::Mock,
        Some("codex") => ExecutorKind::Codex,
        Some("claude") => ExecutorKind::Claude,
        _ => ExecutorKind::Auto,
    }
}

pub(crate) fn cancel_program_lifecycle_run(
    octon_dir: &Path,
    run_id: &str,
    reason: &str,
) -> Result<ProgramLifecycleControlResult> {
    let mut checkpoint = read_program_checkpoint_for_run(octon_dir, run_id)?
        .with_context(|| format!("missing program lifecycle checkpoint for run {run_id}"))?;
    let repo_root = repo_root_for_octon(octon_dir)?;
    let sanitized_run_id = sanitize_run_id(run_id)?;
    let control_root = octon_dir.join(RUN_CONTROL_ROOT_REL).join(&sanitized_run_id);
    let evidence_root = octon_dir
        .join(WORKFLOW_EVIDENCE_ROOT_REL)
        .join(&sanitized_run_id);
    fs::create_dir_all(&control_root)?;
    fs::create_dir_all(&evidence_root)?;
    append_program_run_started_if_needed(
        &control_root,
        &evidence_root,
        &sanitized_run_id,
        &checkpoint.invocation_authority,
    )?;
    let evidence_path = evidence_root.join("program-cancelled.yml");
    let cancellation_token = lifecycle_cancellation_token_path(&control_root);
    let recorded_at = now_rfc3339()?;
    let stale_locks = collect_child_lock_paths(&repo_root, &control_root)?;
    let stale_lock_block = yaml_list(&stale_locks);
    fs::write(
        &evidence_path,
        format!(
            "schema_version: octon-program-lifecycle-cancelled-v1\nrun_id: {sanitized_run_id}\nreason: {reason}\nrecorded_at: {recorded_at}\ncancellation_token: {}\nstale_child_locks:\n{stale_lock_block}",
            rel_display(&repo_root, &cancellation_token),
        ),
    )?;
    fs::write(
        &cancellation_token,
        format!(
            "schema_version: octon-lifecycle-cancellation-v1\nrun_id: {sanitized_run_id}\nlifecycle_id: {}\nexecution_strategy: {}\ntarget: {}\nreason: {reason}\ncancelled_at: {recorded_at}\nevidence_path: {}\n",
            checkpoint.lifecycle_id,
            checkpoint.execution_strategy,
            checkpoint.target,
            rel_display(&repo_root, &evidence_path)
        ),
    )?;
    let mut latest_event_offset = append_program_event(
        &control_root,
        &evidence_root,
        &sanitized_run_id,
        "cancelled",
        None,
        None,
        "program lifecycle run cancelled",
        event_data([("reason", reason)]),
    )?;
    for lock_path in &stale_locks {
        let child_id = Path::new(lock_path)
            .file_stem()
            .and_then(|stem| stem.to_str())
            .unwrap_or("unknown");
        latest_event_offset = append_program_event(
            &control_root,
            &evidence_root,
            &sanitized_run_id,
            "child-lock-stale",
            Some(child_id),
            None,
            "program cancellation preserved existing child execution lock",
            event_data([
                ("status", "preserved-cancelled"),
                ("lock_path", lock_path.as_str()),
            ]),
        )?;
    }
    checkpoint.final_verdict = "cancelled".to_string();
    checkpoint.terminal_outcome = Some("cancelled".to_string());
    checkpoint.cancelled_at = Some(recorded_at.clone());
    checkpoint.cancel_reason = Some(reason.to_string());
    checkpoint.cancellation_evidence_path = Some(rel_display(&repo_root, &evidence_path));
    checkpoint.resume_instruction =
        "cancelled program lifecycle runs cannot resume dispatch".to_string();
    enrich_checkpoint_event_metadata(&mut checkpoint, &control_root)?;
    fs::write(
        program_checkpoint_path_for_run(octon_dir, &sanitized_run_id)?,
        serde_yaml::to_string(&checkpoint)?,
    )?;
    fs::write(
        evidence_root.join("summary.md"),
        program_cancelled_summary(&checkpoint, &recorded_at),
    )?;
    Ok(ProgramLifecycleControlResult {
        schema_version: "octon-program-lifecycle-control-result-v1".to_string(),
        run_id: sanitized_run_id,
        action: "cancel".to_string(),
        final_verdict: checkpoint.final_verdict,
        evidence_path: rel_display(&repo_root, &evidence_path),
        latest_event_offset,
    })
}

fn collect_child_lock_paths(repo_root: &Path, control_root: &Path) -> Result<Vec<String>> {
    let lock_root = control_root.join("locks");
    if !lock_root.is_dir() {
        return Ok(Vec::new());
    }
    let mut locks = Vec::new();
    for entry in fs::read_dir(&lock_root)? {
        let entry = entry?;
        let path = entry.path();
        if path.is_file() {
            locks.push(rel_display(repo_root, &path));
        }
    }
    locks.sort();
    Ok(locks)
}

fn yaml_list(values: &[String]) -> String {
    if values.is_empty() {
        return "  []\n".to_string();
    }
    values
        .iter()
        .map(|value| format!("  - {}\n", yaml_scalar(value)))
        .collect::<String>()
}

fn yaml_scalar(value: &str) -> String {
    serde_yaml::to_string(value)
        .map(|value| value.trim().to_string())
        .unwrap_or_else(|_| format!("{value:?}"))
}

pub(crate) fn replay_program_lifecycle_run(
    octon_dir: &Path,
    run_id: &str,
    verify: bool,
) -> Result<ProgramLifecycleReplayResult> {
    let checkpoint = read_program_checkpoint_for_run(octon_dir, run_id)?
        .with_context(|| format!("missing program lifecycle checkpoint for run {run_id}"))?;
    let sanitized_run_id = sanitize_run_id(run_id)?;
    let control_root = octon_dir.join(RUN_CONTROL_ROOT_REL).join(&sanitized_run_id);
    let events = read_program_events(&control_root)?;
    let mut warnings = Vec::new();
    let mut errors = Vec::new();
    let legacy_event_log = events
        .iter()
        .any(|event| event.schema_version == "octon-program-lifecycle-event-v1");

    if legacy_event_log {
        warnings.push(
            "legacy-event-log: v1 event log is inspectable but not hash-chain-verifiable"
                .to_string(),
        );
    }
    if events.is_empty() {
        errors.push("missing event log entries".to_string());
    }
    validate_event_offsets(&events, &mut errors);
    validate_event_hash_chain(&events, legacy_event_log, &mut errors)?;
    validate_program_event_transitions(&events, &mut errors);

    let latest_event = events.last();
    let latest_event_sha256 = latest_event.and_then(|event| event.event_sha256.clone());
    let event_log_sha256 = program_event_log_digest(&control_root)?;
    let checkpoint_event_index = effective_checkpoint_event_index(&checkpoint);
    let checkpoint_event_sha256 = checkpoint.latest_event_sha256.clone();

    if verify {
        if checkpoint_event_index != latest_event.map(|event| event.event_index).unwrap_or(0) {
            errors.push(format!(
                "checkpoint/event divergence: checkpoint latest event index {} differs from event log latest {}",
                checkpoint_event_index,
                latest_event.map(|event| event.event_index).unwrap_or(0)
            ));
        }
        if !legacy_event_log
            && checkpoint
                .latest_event_sha256
                .as_ref()
                .zip(latest_event_sha256.as_ref())
                .map(|(checkpoint_hash, event_hash)| checkpoint_hash != event_hash)
                .unwrap_or(true)
        {
            errors.push(
                "checkpoint/event divergence: checkpoint latest_event_sha256 is missing or stale"
                    .to_string(),
            );
        }
        if !legacy_event_log
            && checkpoint
                .event_log_sha256
                .as_ref()
                .zip(event_log_sha256.as_ref())
                .map(|(checkpoint_hash, log_hash)| checkpoint_hash != log_hash)
                .unwrap_or(true)
        {
            errors.push(
                "checkpoint/event divergence: checkpoint event_log_sha256 is missing or stale"
                    .to_string(),
            );
        }
        match load_program_context(
            octon_dir,
            &checkpoint.lifecycle_id,
            Path::new(&checkpoint.target),
        ) {
            Ok(context) => {
                if context.registry_digest != checkpoint.child_registry_digest {
                    errors.push(format!(
                        "registry digest drift: checkpoint {} current {}",
                        checkpoint.child_registry_digest, context.registry_digest
                    ));
                }
            }
            Err(error) => errors.push(format!("unsafe resume: {error}")),
        }
        if checkpoint.final_verdict == "blocked-unsafe" {
            errors.push("unsafe resume: checkpoint is blocked-unsafe".to_string());
        }
    }

    let verdict = if errors.is_empty() {
        if legacy_event_log {
            "legacy-event-log"
        } else {
            "replay-verified"
        }
    } else {
        "blocked-unsafe"
    }
    .to_string();
    let result = ProgramLifecycleReplayResult {
        schema_version: "octon-program-lifecycle-replay-v1".to_string(),
        run_id: sanitized_run_id,
        verified: verify && errors.is_empty() && !legacy_event_log,
        verdict,
        legacy_event_log,
        events_replayed: events.len(),
        latest_event_sha256,
        event_log_sha256,
        checkpoint_event_index,
        checkpoint_event_sha256,
        warnings,
        errors,
    };
    if verify && !result.errors.is_empty() {
        bail!(
            "program replay verification failed: {}",
            result.errors.join("; ")
        );
    }
    Ok(result)
}

pub(crate) fn status_program_lifecycle_run(
    octon_dir: &Path,
    run_id: &str,
) -> Result<ProgramLifecycleStatusReadModel> {
    let checkpoint = read_program_checkpoint_for_run(octon_dir, run_id)?
        .with_context(|| format!("missing program lifecycle checkpoint for run {run_id}"))?;
    let sanitized_run_id = sanitize_run_id(run_id)?;
    let plan = plan_program_lifecycle_from_octon_dir_with_checkpoint(
        octon_dir,
        &checkpoint.lifecycle_id,
        Path::new(&checkpoint.target),
        Some(&checkpoint),
    )?;
    let control_root = octon_dir.join(RUN_CONTROL_ROOT_REL).join(&sanitized_run_id);
    let evidence_root = octon_dir
        .join(WORKFLOW_EVIDENCE_ROOT_REL)
        .join(&sanitized_run_id);
    let events = read_program_events(&control_root)?;
    let dag = plan
        .child_states
        .iter()
        .map(|(child_id, state)| (child_id.clone(), state.dependencies.clone()))
        .collect::<BTreeMap<_, _>>();
    let child_blockers = plan
        .child_states
        .iter()
        .filter_map(|(child_id, state)| {
            if state.blockers.is_empty() {
                None
            } else {
                Some((child_id.clone(), state.blockers.clone()))
            }
        })
        .collect::<BTreeMap<_, _>>();
    let rollback_posture = plan
        .child_states
        .iter()
        .filter_map(|(child_id, state)| {
            state
                .rollback_posture
                .as_ref()
                .map(|posture| (child_id.clone(), posture.clone()))
        })
        .collect::<BTreeMap<_, _>>();
    let latest_event_index = events
        .last()
        .map(|event| event.event_index)
        .unwrap_or_else(|| effective_checkpoint_event_index(&checkpoint));
    Ok(ProgramLifecycleStatusReadModel {
        schema_version: "octon-program-lifecycle-status-read-model-v1".to_string(),
        authority_notice: "generated read model only; checkpoint, event log, child manifests, and child receipts remain authoritative for their own domains".to_string(),
        run_id: sanitized_run_id,
        lifecycle_id: checkpoint.lifecycle_id.clone(),
        target: checkpoint.target.clone(),
        execution_mode: checkpoint.execution_mode.clone(),
        final_verdict: checkpoint.final_verdict.clone(),
        terminal_outcome: checkpoint.terminal_outcome.clone(),
        registry_digest: checkpoint.child_registry_digest.clone(),
        latest_event_index,
        event_log_sha256: program_event_log_digest(&control_root)?,
        dag,
        runnable_batch: plan.runnable_batch,
        scheduler_phase: plan.scheduler_phase,
        skipped_blocked_children: plan.skipped_blocked_children,
        required_child_completion: plan.required_child_completion,
        stop_reason: plan.stop_reason,
        program_route: plan.program_route,
        program_gate_results: plan.program_gate_results,
        blocked_by_program_gate: plan.blocked_by_program_gate,
        parent_receipt_states: plan.parent_receipt_states,
        program_blockers: plan.program_blockers,
        normalized_program_blockers: plan.normalized_program_blockers,
        child_blockers,
        normalized_child_blockers: plan.normalized_child_blockers,
        normalized_approval_blockers: plan.normalized_approval_blockers,
        approvals: checkpoint.approvals,
        recovery_attempts: checkpoint.recovery_attempts,
        atomic_barrier_state: reconstruct_atomic_barrier_state(&events)
            .or(checkpoint.atomic_barrier_state),
        evidence_completeness: evidence_completeness(&evidence_root, &control_root),
        rollback_posture,
    })
}

pub(crate) fn propose_program_mutation(
    octon_dir: &Path,
    run_id: &str,
    spec_path: &Path,
) -> Result<ProgramMutationResult> {
    let checkpoint = read_program_checkpoint_for_run(octon_dir, run_id)?
        .with_context(|| format!("missing program lifecycle checkpoint for run {run_id}"))?;
    let repo_root = repo_root_for_octon(octon_dir)?;
    let spec = read_program_mutation_spec(&repo_root, spec_path)?;
    let context = load_program_context(
        octon_dir,
        &checkpoint.lifecycle_id,
        Path::new(&checkpoint.target),
    )?;
    validate_program_mutation_spec(&spec)?;
    validate_program_mutation_against_context(&context, &spec)?;
    if context.registry_digest != spec.expected_registry_digest {
        bail!(
            "mutation proposal blocked: registry digest drifted from expected {} to {}",
            spec.expected_registry_digest,
            context.registry_digest
        );
    }
    let mut proposed = context.registry.clone();
    apply_mutation_to_registry(&mut proposed, &spec)?;
    validate_program_registry(&proposed)?;

    let sanitized_run_id = sanitize_run_id(run_id)?;
    let evidence_root = octon_dir
        .join(WORKFLOW_EVIDENCE_ROOT_REL)
        .join(&sanitized_run_id)
        .join("mutations");
    fs::create_dir_all(&evidence_root)?;
    let evidence_path =
        evidence_root.join(format!("{}-{}-proposal.yml", spec.action, spec.child_id));
    fs::write(
        &evidence_path,
        serde_yaml::to_string(&serde_yaml::to_value(BTreeMap::from([
            (
                "schema_version",
                "octon-proposal-program-mutation-proposal-v1".to_string(),
            ),
            ("run_id", sanitized_run_id.clone()),
            ("action", spec.action.clone()),
            ("child_id", spec.child_id.clone()),
            ("rationale", spec.rationale.clone()),
            (
                "expected_registry_digest",
                spec.expected_registry_digest.clone(),
            ),
        ]))?)?,
    )?;
    Ok(ProgramMutationResult {
        schema_version: "octon-proposal-program-mutation-result-v1".to_string(),
        run_id: sanitized_run_id,
        action: spec.action,
        child_id: spec.child_id,
        applied: false,
        idempotent: false,
        evidence_path: rel_display(&repo_root, &evidence_path),
        registry_path: Some(context.registry_rel),
        previous_registry_digest: Some(context.registry_digest),
        new_registry_digest: None,
        latest_event_offset: None,
    })
}

pub(crate) fn apply_program_mutation(
    octon_dir: &Path,
    run_id: &str,
    spec_path: &Path,
    reason: &str,
) -> Result<ProgramMutationResult> {
    let mut checkpoint = read_program_checkpoint_for_run(octon_dir, run_id)?
        .with_context(|| format!("missing program lifecycle checkpoint for run {run_id}"))?;
    let repo_root = repo_root_for_octon(octon_dir)?;
    let spec = read_program_mutation_spec(&repo_root, spec_path)?;
    validate_program_mutation_spec(&spec)?;
    if reason.trim().is_empty() {
        bail!("mutation apply requires a non-empty operator reason");
    }
    let context = load_program_context(
        octon_dir,
        &checkpoint.lifecycle_id,
        Path::new(&checkpoint.target),
    )?;
    validate_program_mutation_against_context(&context, &spec)?;
    let registry_path = repo_root.join(&context.registry_rel);
    if context.registry_digest != spec.expected_registry_digest {
        if mutation_already_applied(&context.registry, &spec) {
            let evidence_path = write_program_mutation_evidence(
                octon_dir,
                &repo_root,
                run_id,
                &spec,
                reason,
                false,
                Some("idempotent-rerun"),
            )?;
            return Ok(ProgramMutationResult {
                schema_version: "octon-proposal-program-mutation-result-v1".to_string(),
                run_id: sanitize_run_id(run_id)?,
                action: spec.action,
                child_id: spec.child_id,
                applied: false,
                idempotent: true,
                evidence_path,
                registry_path: Some(context.registry_rel),
                previous_registry_digest: Some(context.registry_digest),
                new_registry_digest: None,
                latest_event_offset: None,
            });
        }
        bail!(
            "mutation apply blocked: registry digest drifted from expected {} to {}",
            spec.expected_registry_digest,
            context.registry_digest
        );
    }
    let mut mutated = context.registry.clone();
    apply_mutation_to_registry(&mut mutated, &spec)?;
    validate_program_registry(&mutated)?;
    fs::write(&registry_path, serde_yaml::to_string(&mutated)?)?;
    let new_registry_digest = file_digest(&registry_path)?;
    let sanitized_run_id = sanitize_run_id(run_id)?;
    let control_root = octon_dir.join(RUN_CONTROL_ROOT_REL).join(&sanitized_run_id);
    let evidence_root = octon_dir
        .join(WORKFLOW_EVIDENCE_ROOT_REL)
        .join(&sanitized_run_id);
    let evidence_path = write_program_mutation_evidence(
        octon_dir,
        &repo_root,
        &sanitized_run_id,
        &spec,
        reason,
        true,
        None,
    )?;
    let latest_event_offset = append_program_event(
        &control_root,
        &evidence_root,
        &sanitized_run_id,
        "mutation-applied",
        Some(&spec.child_id),
        None,
        "program registry mutation applied",
        event_data([
            ("action", spec.action.as_str()),
            ("reason", reason),
            ("registry_digest", new_registry_digest.as_str()),
        ]),
    )?;
    checkpoint.child_registry_digest = new_registry_digest.clone();
    checkpoint.scheduler_decision.clear();
    checkpoint.final_verdict = "blocked-recoverable".to_string();
    enrich_checkpoint_event_metadata(&mut checkpoint, &control_root)?;
    fs::write(
        program_checkpoint_path_for_run(octon_dir, &sanitized_run_id)?,
        serde_yaml::to_string(&checkpoint)?,
    )?;
    Ok(ProgramMutationResult {
        schema_version: "octon-proposal-program-mutation-result-v1".to_string(),
        run_id: sanitized_run_id,
        action: spec.action,
        child_id: spec.child_id,
        applied: true,
        idempotent: false,
        evidence_path,
        registry_path: Some(context.registry_rel),
        previous_registry_digest: Some(context.registry_digest),
        new_registry_digest: Some(new_registry_digest),
        latest_event_offset: Some(latest_event_offset),
    })
}

pub(crate) fn scaffold_program_from_seed(
    octon_dir: &Path,
    target: &Path,
    spec_path: &Path,
    dry_run: bool,
) -> Result<ProgramScaffoldResult> {
    let repo_root = repo_root_for_octon(octon_dir)?;
    let target_abs = resolve_lifecycle_target_path(&repo_root, target)?;
    let target_rel = rel_display(&repo_root, &target_abs);
    if !is_safe_repo_relative(&target_rel) {
        bail!("program scaffold target must be repo-relative: {target_rel}");
    }
    let spec_abs = resolve_lifecycle_target_path(&repo_root, spec_path)?;
    let spec: ProgramScaffoldSpec = serde_yaml::from_slice(&fs::read(&spec_abs)?)
        .with_context(|| format!("failed to parse scaffold spec {}", spec_abs.display()))?;
    validate_program_scaffold_spec(&spec)?;
    let registry = scaffold_registry_from_spec(&spec)?;
    validate_program_registry(&registry)?;
    let generated = vec![
        target_abs.join("proposal.yml"),
        target_abs.join("README.md"),
        target_abs.join("resources/child-packet-index.yml"),
        target_abs.join("resources/child-packet-index.md"),
        target_abs.join("architecture/packet-sequence.md"),
    ];
    if !dry_run {
        let existing = generated
            .iter()
            .filter(|path| path.exists())
            .map(|path| rel_display(&repo_root, path))
            .collect::<Vec<_>>();
        if !existing.is_empty() {
            bail!(
                "program scaffold refuses to overwrite existing parent files: {}",
                existing.join(", ")
            );
        }
        fs::create_dir_all(target_abs.join("resources"))?;
        fs::create_dir_all(target_abs.join("architecture"))?;
        fs::write(
            target_abs.join("proposal.yml"),
            scaffold_parent_manifest(&spec),
        )?;
        fs::write(target_abs.join("README.md"), scaffold_parent_readme(&spec))?;
        fs::write(
            target_abs.join("resources/child-packet-index.yml"),
            serde_yaml::to_string(&registry)?,
        )?;
        fs::write(
            target_abs.join("resources/child-packet-index.md"),
            scaffold_child_index_markdown(&spec, &registry),
        )?;
        fs::write(
            target_abs.join("architecture/packet-sequence.md"),
            scaffold_packet_sequence_markdown(&spec, &registry),
        )?;
    }
    Ok(ProgramScaffoldResult {
        schema_version: "octon-proposal-program-scaffold-result-v1".to_string(),
        target: target_rel,
        dry_run,
        generated_paths: generated
            .iter()
            .map(|path| rel_display(&repo_root, path))
            .collect(),
        child_count: registry.children.len(),
        execution_mode: registry.execution_mode,
        seed_reference_child: spec.seed_reference_child.child_id,
        validation_verdict: "valid".to_string(),
    })
}

fn read_program_mutation_spec(repo_root: &Path, spec_path: &Path) -> Result<ProgramMutationSpec> {
    let spec_abs = resolve_lifecycle_target_path(repo_root, spec_path)?;
    serde_yaml::from_slice(&fs::read(&spec_abs)?)
        .with_context(|| format!("failed to parse mutation spec {}", spec_abs.display()))
}

fn validate_program_mutation_spec(spec: &ProgramMutationSpec) -> Result<()> {
    if spec.schema_version != "octon-proposal-program-mutation-v1" {
        bail!(
            "unsupported program mutation schema_version: {}",
            spec.schema_version
        );
    }
    if !matches!(
        spec.action.as_str(),
        "add-child"
            | "defer-child"
            | "supersede-child"
            | "replace-child"
            | "rephase-child"
            | "update-dependencies"
    ) {
        bail!("unsupported program mutation action: {}", spec.action);
    }
    validate_program_id_field(&spec.child_id, "mutation child_id")?;
    if let Some(replacement) = spec.replacement_child_id.as_ref() {
        validate_program_id_field(replacement, "mutation replacement_child_id")?;
        if replacement == &spec.child_id {
            bail!("mutation replacement_child_id must differ from child_id");
        }
    }
    validate_optional_program_id_field(spec.phase_id.as_ref(), "mutation phase_id")?;
    validate_optional_program_id_field(spec.group_id.as_ref(), "mutation group_id")?;
    validate_optional_program_id_field(
        spec.recovery_profile.as_ref(),
        "mutation recovery_profile",
    )?;
    validate_optional_rollback_posture(
        spec.rollback_posture.as_deref(),
        "mutation rollback_posture",
    )?;
    if let Some(gate) = spec.dependency_gate.as_deref() {
        if !matches!(gate, "terminal" | "verification" | "closeout") {
            bail!("mutation dependency_gate must be terminal, verification, or closeout");
        }
    }
    for raw in spec
        .path
        .iter()
        .chain(spec.supersession_evidence.iter())
        .chain(spec.write_scopes.iter())
    {
        if !is_safe_repo_relative(raw) {
            bail!("mutation path must be repo-relative: {raw}");
        }
    }
    for dependency in &spec.dependencies {
        validate_program_id_field(dependency, "mutation dependency id")?;
    }
    if spec.rationale.trim().is_empty() {
        bail!("mutation rationale must not be empty");
    }
    Ok(())
}

fn validate_program_mutation_against_context(
    context: &ProgramContext,
    spec: &ProgramMutationSpec,
) -> Result<()> {
    let parent = Path::new(&context.target_rel);
    if let Some(path) = spec.path.as_deref() {
        let candidate = Path::new(path);
        if candidate == parent || candidate.starts_with(parent) {
            bail!("mutation path would place child under parent program authority: {path}");
        }
    }
    for scope in &spec.write_scopes {
        let scope_path = Path::new(scope);
        if scope_path == parent || scope_path.starts_with(parent) {
            bail!("mutation write_scope would overlap parent program authority: {scope}");
        }
        if scope_path.starts_with(WORKFLOW_EVIDENCE_ROOT_REL)
            || scope_path.starts_with(RUN_CONTROL_ROOT_REL)
        {
            bail!("mutation write_scope would overlap program control/evidence authority: {scope}");
        }
    }
    match spec.action.as_str() {
        "add-child" => {
            if spec.path.is_none() {
                bail!("add-child mutation requires path");
            }
        }
        "supersede-child" | "replace-child" => {
            if spec.supersession_evidence.is_none() {
                bail!("{} mutation requires supersession_evidence", spec.action);
            }
        }
        _ => {}
    }
    Ok(())
}

fn apply_mutation_to_registry(
    registry: &mut ProgramChildRegistry,
    spec: &ProgramMutationSpec,
) -> Result<()> {
    match spec.action.as_str() {
        "add-child" => {
            if registry
                .children
                .iter()
                .any(|child| child.child_id == spec.child_id)
            {
                bail!("program registry already has child {}", spec.child_id);
            }
            let path = spec
                .path
                .clone()
                .with_context(|| "add-child mutation requires path")?;
            registry.children.push(ProgramChildSpec {
                child_id: spec.child_id.clone(),
                path,
                required: !spec.deferred.unwrap_or(false),
                deferred: spec.deferred.unwrap_or(false),
                dependencies: spec.dependencies.clone(),
                dependency_gate: spec.dependency_gate.clone(),
                phase_id: spec.phase_id.clone(),
                group_id: spec.group_id.clone(),
                rollback_posture: spec.rollback_posture.clone(),
                supersession_evidence: None,
                replacement_child_id: None,
                replacement_for: None,
                recovery_profile: spec.recovery_profile.clone(),
                phase_commit_barrier: None,
                write_scopes: spec.write_scopes.clone(),
                seed_role: None,
                child_lifecycle_id: None,
                required_metadata: Vec::new(),
                source_lineage_refs: Vec::new(),
                parent_contract_refs: Vec::new(),
                readiness_requirements: Vec::new(),
                predecessor_constraints: Vec::new(),
                successor_constraints: Vec::new(),
                cutover_constraints: None,
            });
        }
        "defer-child" => {
            let child = child_mut(registry, &spec.child_id)?;
            child.deferred = spec.deferred.unwrap_or(true);
        }
        "supersede-child" => {
            if spec.supersession_evidence.is_none() {
                bail!("supersede-child mutation requires supersession_evidence");
            }
            let child = child_mut(registry, &spec.child_id)?;
            child.deferred = true;
            child.rollback_posture = spec
                .rollback_posture
                .clone()
                .or_else(|| Some("superseded".to_string()));
            child.supersession_evidence = spec.supersession_evidence.clone();
        }
        "replace-child" => {
            let replacement_id = spec
                .replacement_child_id
                .clone()
                .with_context(|| "replace-child mutation requires replacement_child_id")?;
            if registry
                .children
                .iter()
                .any(|child| child.child_id == replacement_id)
            {
                bail!("program registry already has replacement child {replacement_id}");
            }
            let path = spec
                .path
                .clone()
                .with_context(|| "replace-child mutation requires path")?;
            let dependencies = child_mut(registry, &spec.child_id)?.dependencies.clone();
            child_mut(registry, &spec.child_id)?.deferred = true;
            child_mut(registry, &spec.child_id)?.rollback_posture = Some("replaced".to_string());
            child_mut(registry, &spec.child_id)?.supersession_evidence =
                spec.supersession_evidence.clone();
            child_mut(registry, &spec.child_id)?.replacement_child_id =
                Some(replacement_id.clone());
            registry.children.push(ProgramChildSpec {
                child_id: replacement_id,
                path,
                required: true,
                deferred: false,
                dependencies: if spec.dependencies.is_empty() {
                    dependencies
                } else {
                    spec.dependencies.clone()
                },
                dependency_gate: spec.dependency_gate.clone(),
                phase_id: spec.phase_id.clone(),
                group_id: spec.group_id.clone(),
                rollback_posture: spec.rollback_posture.clone(),
                supersession_evidence: None,
                replacement_child_id: None,
                replacement_for: Some(spec.child_id.clone()),
                recovery_profile: spec.recovery_profile.clone(),
                phase_commit_barrier: None,
                write_scopes: spec.write_scopes.clone(),
                seed_role: None,
                child_lifecycle_id: None,
                required_metadata: Vec::new(),
                source_lineage_refs: Vec::new(),
                parent_contract_refs: Vec::new(),
                readiness_requirements: Vec::new(),
                predecessor_constraints: Vec::new(),
                successor_constraints: Vec::new(),
                cutover_constraints: None,
            });
        }
        "rephase-child" => {
            let child = child_mut(registry, &spec.child_id)?;
            child.phase_id = spec.phase_id.clone();
            child.group_id = spec.group_id.clone();
        }
        "update-dependencies" => {
            let child = child_mut(registry, &spec.child_id)?;
            child.dependencies = spec.dependencies.clone();
        }
        _ => unreachable!("validated mutation action"),
    }
    Ok(())
}

fn mutation_already_applied(registry: &ProgramChildRegistry, spec: &ProgramMutationSpec) -> bool {
    match spec.action.as_str() {
        "add-child" => registry.children.iter().any(|child| {
            child.child_id == spec.child_id && spec.path.as_deref() == Some(&child.path)
        }),
        "defer-child" => registry
            .children
            .iter()
            .any(|child| child.child_id == spec.child_id && child.deferred),
        "supersede-child" => registry
            .children
            .iter()
            .any(|child| child.child_id == spec.child_id && child.deferred),
        "replace-child" => spec
            .replacement_child_id
            .as_ref()
            .map_or(false, |replacement| {
                registry
                    .children
                    .iter()
                    .any(|child| child.child_id == *replacement)
                    && registry
                        .children
                        .iter()
                        .any(|child| child.child_id == spec.child_id && child.deferred)
            }),
        "rephase-child" => registry.children.iter().any(|child| {
            child.child_id == spec.child_id
                && child.phase_id == spec.phase_id
                && child.group_id == spec.group_id
        }),
        "update-dependencies" => registry.children.iter().any(|child| {
            child.child_id == spec.child_id && child.dependencies == spec.dependencies
        }),
        _ => false,
    }
}

fn child_mut<'a>(
    registry: &'a mut ProgramChildRegistry,
    child_id: &str,
) -> Result<&'a mut ProgramChildSpec> {
    registry
        .children
        .iter_mut()
        .find(|child| child.child_id == child_id)
        .with_context(|| format!("program registry has no child {child_id}"))
}

fn write_program_mutation_evidence(
    octon_dir: &Path,
    repo_root: &Path,
    run_id: &str,
    spec: &ProgramMutationSpec,
    reason: &str,
    applied: bool,
    note: Option<&str>,
) -> Result<String> {
    let evidence_root = octon_dir
        .join(WORKFLOW_EVIDENCE_ROOT_REL)
        .join(sanitize_run_id(run_id)?)
        .join("mutations");
    fs::create_dir_all(&evidence_root)?;
    let suffix = if applied { "applied" } else { "proposal" };
    let evidence_path =
        evidence_root.join(format!("{}-{}-{suffix}.yml", spec.action, spec.child_id));
    let mut evidence = BTreeMap::from([
        (
            "schema_version".to_string(),
            "octon-proposal-program-mutation-evidence-v1".to_string(),
        ),
        ("run_id".to_string(), sanitize_run_id(run_id)?),
        ("action".to_string(), spec.action.clone()),
        ("child_id".to_string(), spec.child_id.clone()),
        ("reason".to_string(), reason.to_string()),
        ("rationale".to_string(), spec.rationale.clone()),
        (
            "expected_registry_digest".to_string(),
            spec.expected_registry_digest.clone(),
        ),
        ("applied".to_string(), applied.to_string()),
    ]);
    if let Some(note) = note {
        evidence.insert("note".to_string(), note.to_string());
    }
    fs::write(&evidence_path, serde_yaml::to_string(&evidence)?)?;
    Ok(rel_display(repo_root, &evidence_path))
}

fn validate_program_scaffold_spec(spec: &ProgramScaffoldSpec) -> Result<()> {
    if spec.schema_version != "octon-proposal-program-scaffold-v1" {
        bail!(
            "unsupported program scaffold schema_version: {}",
            spec.schema_version
        );
    }
    validate_optional_program_id_field(spec.program_id.as_ref(), "scaffold program_id")?;
    if !matches!(
        spec.execution_mode.as_str(),
        "sequential" | "parallel-independent" | "gated-parallel" | "approval-gated"
    ) {
        bail!(
            "scaffold execution_mode {} is not supported for safe scaffolding",
            spec.execution_mode
        );
    }
    validate_scaffold_child(&spec.seed_reference_child)?;
    for child in &spec.follow_on_child_candidates {
        validate_scaffold_child(child)?;
    }
    Ok(())
}

fn validate_scaffold_child(child: &ProgramScaffoldChildSpec) -> Result<()> {
    validate_program_id_field(&child.child_id, "scaffold child_id")?;
    validate_optional_program_id_field(child.phase_id.as_ref(), "scaffold phase_id")?;
    validate_optional_program_id_field(child.group_id.as_ref(), "scaffold group_id")?;
    validate_optional_rollback_posture(
        child.rollback_posture.as_deref(),
        "scaffold rollback_posture",
    )?;
    validate_optional_seed_role(child.seed_role.as_deref(), "scaffold seed_role")?;
    if !is_safe_repo_relative(&child.path) {
        bail!("scaffold child path must be repo-relative: {}", child.path);
    }
    for dependency in &child.dependencies {
        validate_program_id_field(dependency, "scaffold dependency id")?;
    }
    for scope in &child.write_scopes {
        if !is_safe_repo_relative(scope) {
            bail!("scaffold write scope must be repo-relative: {scope}");
        }
    }
    Ok(())
}

fn scaffold_registry_from_spec(spec: &ProgramScaffoldSpec) -> Result<ProgramChildRegistry> {
    let mut children = Vec::new();
    children.push(scaffold_child_to_registry_child(
        &spec.seed_reference_child,
        Some("seed-reference"),
    ));
    children.extend(
        spec.follow_on_child_candidates
            .iter()
            .map(|child| scaffold_child_to_registry_child(child, None)),
    );
    let registry = ProgramChildRegistry {
        schema_version: "octon-proposal-program-child-registry-v2".to_string(),
        execution_mode: spec.execution_mode.clone(),
        default_child_lifecycle_id: Some(DEFAULT_CHILD_LIFECYCLE_ID.to_string()),
        children,
    };
    Ok(registry)
}

fn scaffold_child_to_registry_child(
    child: &ProgramScaffoldChildSpec,
    default_seed_role: Option<&str>,
) -> ProgramChildSpec {
    ProgramChildSpec {
        child_id: child.child_id.clone(),
        path: child.path.clone(),
        required: child.required.unwrap_or(true),
        deferred: child.deferred.unwrap_or(false),
        dependencies: child.dependencies.clone(),
        dependency_gate: None,
        phase_id: child.phase_id.clone(),
        group_id: child.group_id.clone(),
        rollback_posture: child.rollback_posture.clone(),
        supersession_evidence: None,
        replacement_child_id: None,
        replacement_for: None,
        recovery_profile: None,
        phase_commit_barrier: None,
        write_scopes: child.write_scopes.clone(),
        seed_role: child
            .seed_role
            .clone()
            .or_else(|| default_seed_role.map(str::to_string)),
        child_lifecycle_id: None,
        required_metadata: Vec::new(),
        source_lineage_refs: Vec::new(),
        parent_contract_refs: Vec::new(),
        readiness_requirements: Vec::new(),
        predecessor_constraints: Vec::new(),
        successor_constraints: Vec::new(),
        cutover_constraints: None,
    }
}

fn scaffold_parent_manifest(spec: &ProgramScaffoldSpec) -> String {
    format!(
        "status: accepted\ntitle: {:?}\nprogram_id: {:?}\nprogram_lifecycle: proposal-program\n",
        spec.title,
        spec.program_id
            .clone()
            .unwrap_or_else(|| "proposal-program".to_string())
    )
}

fn scaffold_parent_readme(spec: &ProgramScaffoldSpec) -> String {
    format!(
        "# {}\n\nThis parent packet coordinates a proposal program. The seed/reference child is `{}`; it remains child-owned and does not make this parent program the Governed Workflow Runtime transition program.\n\nRationale: {}\n",
        spec.title, spec.seed_reference_child.child_id, spec.rationale
    )
}

fn scaffold_child_index_markdown(
    spec: &ProgramScaffoldSpec,
    registry: &ProgramChildRegistry,
) -> String {
    let mut out = format!(
        "# Child Packet Index\n\nExecution mode: `{}`\n\n",
        registry.execution_mode
    );
    for child in &registry.children {
        let role = child.seed_role.as_deref().unwrap_or("follow-on-candidate");
        out.push_str(&format!(
            "- `{}`: `{}` ({role})\n",
            child.child_id, child.path
        ));
    }
    out.push_str(&format!("\nRationale: {}\n", spec.rationale));
    out
}

fn scaffold_packet_sequence_markdown(
    spec: &ProgramScaffoldSpec,
    registry: &ProgramChildRegistry,
) -> String {
    let mut out = format!("# Packet Sequence\n\nProgram: {}\n\n", spec.title);
    for child in &registry.children {
        let dependencies = if child.dependencies.is_empty() {
            "none".to_string()
        } else {
            child.dependencies.join(", ")
        };
        out.push_str(&format!(
            "## {}\n\nPath: `{}`\nDependencies: `{}`\n\n",
            child.child_id, child.path, dependencies
        ));
    }
    out.push_str("The seed/reference packet anchors design pressure only. Creating the real Governed Workflow Runtime transition program remains out of scope for this scaffold.\n");
    out
}

fn load_program_parent_context(
    octon_dir: &Path,
    lifecycle_id: &str,
    target: &Path,
) -> Result<ProgramParentContext> {
    let repo_root = repo_root_for_octon(octon_dir)?;
    let loaded = load_lifecycle_contract(octon_dir, lifecycle_id)?;
    let program = loaded
        .contract
        .program
        .as_ref()
        .with_context(|| format!("lifecycle {lifecycle_id} is not a program lifecycle"))?;
    let target_abs = resolve_lifecycle_target_path(&repo_root, target)?;
    let target_rel = rel_display(&repo_root, &target_abs);
    let parent_manifest_status = read_manifest_status(&target_abs, &loaded.contract)?;
    let registry_abs = resolve_target_local_path(
        &target_abs,
        &program.child_registry_path,
        "program child registry path",
    )?;
    let registry_rel = rel_display(&repo_root, &registry_abs);
    Ok(ProgramParentContext {
        loaded,
        target_abs,
        target_rel,
        parent_manifest_status,
        registry_abs,
        registry_rel,
    })
}

fn load_program_context(
    octon_dir: &Path,
    lifecycle_id: &str,
    target: &Path,
) -> Result<ProgramContext> {
    let parent = load_program_parent_context(octon_dir, lifecycle_id, target)?;
    if !parent.registry_abs.is_file() {
        bail!(
            "program child registry missing for lifecycle {lifecycle_id}: {}",
            parent.registry_abs.display()
        );
    }
    let registry: ProgramChildRegistry = serde_yaml::from_slice(&fs::read(&parent.registry_abs)?)
        .with_context(|| {
        format!(
            "failed to parse child registry {}",
            parent.registry_abs.display()
        )
    })?;
    let registry_digest = file_digest(&parent.registry_abs)?;
    Ok(ProgramContext {
        loaded: parent.loaded,
        target_abs: parent.target_abs,
        target_rel: parent.target_rel,
        parent_manifest_status: parent.parent_manifest_status,
        registry_rel: parent.registry_rel,
        registry_digest,
        registry,
    })
}

fn program_registry_binding_digest(context: &ProgramParentContext) -> Result<String> {
    if context.registry_abs.is_file() {
        file_digest(&context.registry_abs)
    } else {
        Ok(MISSING_CHILD_REGISTRY_DIGEST.to_string())
    }
}

fn validate_authority_boundaries(program: &ProgramSpec) -> Result<()> {
    if !program.authority_boundaries.parent_coordinates_only
        || !program
            .authority_boundaries
            .child_receipts_remain_child_owned
        || !program
            .authority_boundaries
            .child_promotion_targets_remain_child_owned
    {
        bail!("program lifecycle contract must declare parent/child authority boundaries");
    }
    Ok(())
}

fn validate_program_registry(registry: &ProgramChildRegistry) -> Result<()> {
    if !matches!(
        registry.schema_version.as_str(),
        "octon-proposal-program-child-registry-v1" | "octon-proposal-program-child-registry-v2"
    ) {
        bail!(
            "unsupported program child registry schema_version: {}",
            registry.schema_version
        );
    }
    if registry.execution_mode == "program-atomic"
        && registry.schema_version != "octon-proposal-program-child-registry-v2"
    {
        bail!("program-atomic requires octon-proposal-program-child-registry-v2");
    }
    if registry.children.is_empty() {
        bail!("program child registry must declare at least one child");
    }
    validate_optional_lifecycle_id_field(
        registry.default_child_lifecycle_id.as_ref(),
        "default_child_lifecycle_id",
    )?;
    if !matches!(
        registry.execution_mode.as_str(),
        "sequential"
            | "parallel-independent"
            | "gated-parallel"
            | "approval-gated"
            | "program-atomic"
    ) {
        bail!(
            "unsupported program execution_mode: {}",
            registry.execution_mode
        );
    }
    let mut ids = BTreeSet::new();
    for child in &registry.children {
        validate_program_id_field(&child.child_id, "program registry child_id")?;
        if !ids.insert(child.child_id.clone()) {
            bail!("duplicate child_id in program registry: {}", child.child_id);
        }
        validate_optional_program_id_field(child.phase_id.as_ref(), "program registry phase_id")?;
        validate_optional_program_id_field(child.group_id.as_ref(), "program registry group_id")?;
        validate_optional_program_id_field(
            child.replacement_child_id.as_ref(),
            "program registry replacement_child_id",
        )?;
        validate_optional_program_id_field(
            child.replacement_for.as_ref(),
            "program registry replacement_for",
        )?;
        validate_optional_program_id_field(
            child.recovery_profile.as_ref(),
            "program registry recovery_profile",
        )?;
        validate_optional_program_id_field(
            child.phase_commit_barrier.as_ref(),
            "program registry phase_commit_barrier",
        )?;
        validate_optional_rollback_posture(
            child.rollback_posture.as_deref(),
            "program registry rollback_posture",
        )?;
        validate_optional_seed_role(child.seed_role.as_deref(), "program registry seed_role")?;
        validate_optional_lifecycle_id_field(
            child.child_lifecycle_id.as_ref(),
            "program registry child_lifecycle_id",
        )?;
        for metadata in &child.required_metadata {
            if metadata != "change_profile" {
                bail!(
                    "child {} required_metadata value is unsupported: {}",
                    child.child_id,
                    metadata
                );
            }
        }
        for source_ref in &child.source_lineage_refs {
            if !is_safe_repo_relative(source_ref) {
                bail!(
                    "child {} source_lineage_ref must be repo-relative: {}",
                    child.child_id,
                    source_ref
                );
            }
        }
        for contract_ref in &child.parent_contract_refs {
            if !is_safe_repo_relative(contract_ref) {
                bail!(
                    "child {} parent_contract_ref must be repo-relative: {}",
                    child.child_id,
                    contract_ref
                );
            }
        }
        for requirement in &child.readiness_requirements {
            validate_program_id_field(
                &requirement.requirement_id,
                "program registry readiness requirement_id",
            )?;
            if requirement.summary.trim().is_empty() {
                bail!(
                    "child {} readiness requirement {} must have a summary",
                    child.child_id,
                    requirement.requirement_id
                );
            }
            for phrase in &requirement.review_must_mention {
                if phrase.trim().is_empty() {
                    bail!(
                        "child {} readiness requirement {} has an empty review_must_mention",
                        child.child_id,
                        requirement.requirement_id
                    );
                }
            }
        }
        for constraint in &child.predecessor_constraints {
            validate_program_id_field(
                &constraint.predecessor_child_id,
                "program registry predecessor_child_id",
            )?;
            if constraint.constraint.trim().is_empty() {
                bail!(
                    "child {} predecessor constraint must have text",
                    child.child_id
                );
            }
        }
        for constraint in &child.successor_constraints {
            validate_program_id_field(
                &constraint.successor_child_id,
                "program registry successor_child_id",
            )?;
            if constraint.constraint.trim().is_empty() {
                bail!(
                    "child {} successor constraint must have text",
                    child.child_id
                );
            }
        }
        if let Some(cutover) = child.cutover_constraints.as_ref() {
            for predecessor in &cutover.required_predecessor_child_ids {
                validate_program_id_field(
                    predecessor,
                    "program registry cutover required_predecessor_child_id",
                )?;
            }
            for claim in &cutover.forbidden_claims_until_ready {
                if !matches!(
                    claim.as_str(),
                    "compatibility-retired" | "canonical-runtime-support"
                ) {
                    bail!(
                        "child {} cutover forbidden claim is unsupported: {}",
                        child.child_id,
                        claim
                    );
                }
            }
        }
        if !is_safe_repo_relative(&child.path) {
            bail!("child path must be repo-relative: {}", child.path);
        }
        if let Some(gate) = child.dependency_gate.as_deref() {
            if !matches!(gate, "terminal" | "verification" | "closeout") {
                bail!(
                    "child {} dependency_gate must be terminal, verification, or closeout",
                    child.child_id
                );
            }
        }
        if let Some(evidence) = child.supersession_evidence.as_deref() {
            if !is_safe_repo_relative(evidence) {
                bail!(
                    "child {} supersession_evidence must be repo-relative: {}",
                    child.child_id,
                    evidence
                );
            }
        }
        if matches!(
            child.rollback_posture.as_deref(),
            Some("superseded" | "replaced" | "rejected")
        ) && child.supersession_evidence.is_none()
        {
            bail!(
                "child {} rollback_posture {} requires supersession_evidence",
                child.child_id,
                child.rollback_posture.as_deref().unwrap_or_default()
            );
        }
        for scope in &child.write_scopes {
            if !is_safe_repo_relative(scope) {
                bail!(
                    "child {} write scope must be repo-relative: {}",
                    child.child_id,
                    scope
                );
            }
        }
        if registry.execution_mode == "program-atomic" && child.required && !child.deferred {
            if child.write_scopes.is_empty() {
                bail!(
                    "program-atomic child {} must declare write_scopes",
                    child.child_id
                );
            }
            if child
                .dependency_gate
                .as_deref()
                .unwrap_or_default()
                .is_empty()
            {
                bail!(
                    "program-atomic child {} must declare dependency_gate",
                    child.child_id
                );
            }
            if child
                .recovery_profile
                .as_deref()
                .unwrap_or_default()
                .is_empty()
            {
                bail!(
                    "program-atomic child {} must declare recovery_profile",
                    child.child_id
                );
            }
            if child
                .rollback_posture
                .as_deref()
                .unwrap_or_default()
                .is_empty()
            {
                bail!(
                    "program-atomic child {} must declare rollback_posture",
                    child.child_id
                );
            }
        }
    }
    for child in &registry.children {
        for dependency in &child.dependencies {
            validate_program_id_field(dependency, "program registry dependency id")?;
            if !ids.contains(dependency) {
                bail!(
                    "child {} depends on missing child {}",
                    child.child_id,
                    dependency
                );
            }
        }
        for constraint in &child.predecessor_constraints {
            if !ids.contains(&constraint.predecessor_child_id) {
                bail!(
                    "child {} predecessor constraint references missing child {}",
                    child.child_id,
                    constraint.predecessor_child_id
                );
            }
        }
        for constraint in &child.successor_constraints {
            if !ids.contains(&constraint.successor_child_id) {
                bail!(
                    "child {} successor constraint references missing child {}",
                    child.child_id,
                    constraint.successor_child_id
                );
            }
        }
        if let Some(cutover) = child.cutover_constraints.as_ref() {
            for predecessor in &cutover.required_predecessor_child_ids {
                if !ids.contains(predecessor) {
                    bail!(
                        "child {} cutover constraint references missing predecessor child {}",
                        child.child_id,
                        predecessor
                    );
                }
            }
        }
    }
    reject_dependency_cycles(registry)
}

fn reject_dependency_cycles(registry: &ProgramChildRegistry) -> Result<()> {
    let deps = registry
        .children
        .iter()
        .map(|child| (child.child_id.as_str(), child.dependencies.as_slice()))
        .collect::<BTreeMap<_, _>>();
    for child in &registry.children {
        let mut visiting = BTreeSet::new();
        let mut visited = BTreeSet::new();
        visit_dependency(child.child_id.as_str(), &deps, &mut visiting, &mut visited)?;
    }
    Ok(())
}

fn visit_dependency<'a>(
    child_id: &'a str,
    deps: &BTreeMap<&'a str, &'a [String]>,
    visiting: &mut BTreeSet<&'a str>,
    visited: &mut BTreeSet<&'a str>,
) -> Result<()> {
    if visited.contains(child_id) {
        return Ok(());
    }
    if !visiting.insert(child_id) {
        bail!("program child dependency cycle includes {child_id}");
    }
    if let Some(children) = deps.get(child_id) {
        for dependency in *children {
            visit_dependency(dependency.as_str(), deps, visiting, visited)?;
        }
    }
    visiting.remove(child_id);
    visited.insert(child_id);
    Ok(())
}

fn apply_atomic_preflight_blockers(
    octon_dir: &Path,
    program: &ProgramSpec,
    registry: &ProgramChildRegistry,
    child_states: &mut BTreeMap<String, ProgramChildPlanState>,
    program_blockers: &mut Vec<ProgramBlocker>,
) -> Result<()> {
    let Some(atomic_policy) = program.atomic_policy.as_ref() else {
        program_blockers.push(ProgramBlocker {
            blocker_class: "unsupported-mode-authority".to_string(),
            message: "program-atomic requires program.atomic_policy".to_string(),
            recovery_route: None,
        });
        return Ok(());
    };
    if atomic_policy.eligibility != "explicit-route-opt-in" {
        program_blockers.push(ProgramBlocker {
            blocker_class: "unsupported-mode-authority".to_string(),
            message: "program-atomic supports only explicit-route-opt-in atomic eligibility"
                .to_string(),
            recovery_route: None,
        });
        return Ok(());
    }
    if registry.schema_version != "octon-proposal-program-child-registry-v2" {
        program_blockers.push(ProgramBlocker {
            blocker_class: "unsupported-mode-authority".to_string(),
            message: "program-atomic requires octon-proposal-program-child-registry-v2".to_string(),
            recovery_route: None,
        });
        return Ok(());
    }
    let mut observed_scopes: Vec<(String, Vec<String>)> = Vec::new();
    for child in registry
        .children
        .iter()
        .filter(|child| child.required && !child.deferred)
    {
        let Some(state) = child_states.get_mut(&child.child_id) else {
            continue;
        };
        if state.terminal_outcome.is_some() {
            continue;
        }
        if let Some((other_child, _)) = observed_scopes.iter().find(|(_, existing)| {
            state.write_scopes.iter().any(|scope| {
                existing
                    .iter()
                    .any(|other_scope| scopes_overlap(scope, other_scope))
            })
        }) {
            program_blockers.push(ProgramBlocker {
                blocker_class: "atomic-write-scope-conflict".to_string(),
                message: format!(
                    "program-atomic child {} write scope overlaps with child {other_child}",
                    state.child_id
                ),
                recovery_route: None,
            });
        }
        observed_scopes.push((state.child_id.clone(), state.write_scopes.clone()));
        if atomic_policy.require_declared_write_scopes && child.write_scopes.is_empty() {
            state.blockers.push(ProgramBlocker {
                blocker_class: "authority-boundary-ambiguous".to_string(),
                message: "program-atomic child must declare write_scopes".to_string(),
                recovery_route: None,
            });
        }
        let Some(route) = state.selected_route.as_ref() else {
            state.blockers.push(ProgramBlocker {
                blocker_class: "missing-evidence".to_string(),
                message: "program-atomic child has no selected route".to_string(),
                recovery_route: None,
            });
            continue;
        };
        let loaded = load_lifecycle_contract(octon_dir, &state.child_lifecycle_id)?;
        match atomic_spec_for_route(&loaded.contract, &route.route_id) {
            Ok(_) => {}
            Err(error) => state.blockers.push(ProgramBlocker {
                blocker_class: "unsupported-mode-authority".to_string(),
                message: error.to_string(),
                recovery_route: None,
            }),
        }
    }
    Ok(())
}

fn apply_closeout_policy_blockers(
    octon_dir: &Path,
    repo_root: &Path,
    program: &ProgramSpec,
    registry: &ProgramChildRegistry,
    parent_target_rel: &str,
    child_states: &BTreeMap<String, ProgramChildPlanState>,
    program_blockers: &mut Vec<ProgramBlocker>,
) -> Result<()> {
    let Some(policy) = program.closeout_policy.as_ref() else {
        return Ok(());
    };
    if policy.enforce_authority_boundaries
        && (!program.authority_boundaries.parent_coordinates_only
            || !program
                .authority_boundaries
                .child_receipts_remain_child_owned
            || !program
                .authority_boundaries
                .child_promotion_targets_remain_child_owned)
    {
        program_blockers.push(ProgramBlocker {
            blocker_class: "authority-boundary-ambiguous".to_string(),
            message: "program closeout policy requires strict parent/child authority boundaries"
                .to_string(),
            recovery_route: None,
        });
    }
    if let Some(message) = policy
        .enforce_authority_boundaries
        .then(|| parent_child_owned_surface_blocker_message(repo_root, parent_target_rel))
        .transpose()?
        .flatten()
    {
        program_blockers.push(ProgramBlocker {
            blocker_class: "authority-boundary-ambiguous".to_string(),
            message,
            recovery_route: None,
        });
    }
    if !policy.required_child_terminal_outcomes.is_empty() {
        for state in child_states
            .values()
            .filter(|state| state.required && !state.deferred)
        {
            let Some(outcome) = state.terminal_outcome.as_ref() else {
                continue;
            };
            if !policy
                .required_child_terminal_outcomes
                .iter()
                .any(|allowed| allowed == outcome)
            {
                program_blockers.push(ProgramBlocker {
                    blocker_class: "validation-failed".to_string(),
                    message: format!(
                        "child {} terminal outcome {} is not allowed by program closeout policy",
                        state.child_id, outcome
                    ),
                    recovery_route: None,
                });
            }
        }
    }
    let required = child_states
        .values()
        .filter(|state| state.required && !state.deferred)
        .collect::<Vec<_>>();
    let required_children_terminal = !required.is_empty()
        && required
            .iter()
            .all(|state| state.terminal_outcome.is_some());
    if required_children_terminal && policy.require_child_receipts_fresh {
        for state in required {
            if let Err(error) = child_closeout_receipts_ready(octon_dir, repo_root, policy, state) {
                program_blockers.push(ProgramBlocker {
                    blocker_class: "receipt-recovery-unavailable".to_string(),
                    message: format!(
                        "required child {} is not closeout-ready: {error}",
                        state.child_id
                    ),
                    recovery_route: None,
                });
            }
        }
    }
    if required_children_terminal {
        for state in child_states.values().filter(|state| state.deferred) {
            if let Some(child) = registry
                .children
                .iter()
                .find(|child| child.child_id == state.child_id)
            {
                if let Err(error) = deferred_child_evidence_ready(repo_root, state, child) {
                    program_blockers.push(ProgramBlocker {
                        blocker_class: "deferred-evidence-missing".to_string(),
                        message: format!(
                            "deferred child {} lacks closeout evidence: {error}",
                            state.child_id
                        ),
                        recovery_route: None,
                    });
                }
            }
        }
    }
    let _ = policy.require_aggregate_evidence;
    Ok(())
}

fn parent_child_owned_surface_blocker_message(
    repo_root: &Path,
    parent_target_rel: &str,
) -> Result<Option<String>> {
    let parent_root = resolve_lifecycle_target_path(repo_root, Path::new(parent_target_rel))?;
    let parent_manifest = parent_root.join("proposal.yml");
    if parent_manifest.is_file() {
        let manifest: serde_yaml::Value = serde_yaml::from_slice(&fs::read(parent_manifest)?)?;
        for forbidden in [
            "child_receipts",
            "child_validation_verdict",
            "child_validation_verdicts",
            "child_validation_results",
            "child_promotion_targets",
            "child_archive_metadata",
        ] {
            if manifest.get(forbidden).is_some() {
                return Ok(Some(format!(
                    "parent manifest contains child-owned surface {forbidden}"
                )));
            }
        }
    }
    for forbidden_path in [
        "support/child-validation-verdicts.yml",
        "support/child-validation-verdicts.yaml",
        "support/child-validation-verdicts.md",
        "resources/child-validation-verdicts.yml",
        "resources/child-validation-verdicts.yaml",
        "resources/child-validation-verdicts.md",
    ] {
        if parent_root.join(forbidden_path).exists() {
            return Ok(Some(format!(
                "parent evidence contains child-owned validation verdict surface {forbidden_path}"
            )));
        }
    }
    Ok(None)
}

fn child_closeout_receipts_ready(
    octon_dir: &Path,
    repo_root: &Path,
    policy: &ProgramCloseoutPolicySpec,
    state: &ProgramChildPlanState,
) -> Result<()> {
    let child_contract = load_lifecycle_contract(octon_dir, &state.child_lifecycle_id)?;
    if child_contract.contract.receipts.is_empty() {
        return Ok(());
    }
    let outcome = state
        .terminal_outcome
        .as_deref()
        .context("child closeout readiness requires terminal outcome")?;
    let required_receipts =
        child_closeout_required_receipt_ids(policy, &child_contract.contract, outcome);
    let live_plan = plan_lifecycle_from_octon_dir(
        octon_dir,
        &state.child_lifecycle_id,
        Path::new(&state.target),
    )?;
    for receipt in child_contract
        .contract
        .receipts
        .iter()
        .filter(|receipt| required_receipts.contains(&receipt.receipt_id))
    {
        let Some(live_receipt) = live_plan.receipt_states.get(&receipt.receipt_id) else {
            bail!("missing live receipt state {}", receipt.receipt_id);
        };
        if !live_receipt.exists {
            bail!("missing child-owned receipt {}", receipt.receipt_id);
        }
        if !live_receipt.missing_required_fields.is_empty() {
            bail!(
                "receipt {} missing required fields: {}",
                receipt.receipt_id,
                live_receipt.missing_required_fields.join(",")
            );
        }
        if live_receipt.stale == Some(true) {
            bail!("receipt {} is stale", receipt.receipt_id);
        }
        let child_target_abs = resolve_lifecycle_target_path(repo_root, Path::new(&state.target))?;
        let receipt_path = resolve_target_local_path(
            &child_target_abs,
            &receipt.path,
            "program closeout child receipt",
        )?;
        if !receipt_path.starts_with(&child_target_abs) {
            bail!("receipt {} is not child-owned", receipt.receipt_id);
        }
    }
    validate_child_closeout_receipt_fields(policy, outcome, &live_plan.receipt_states)?;
    Ok(())
}

fn child_closeout_required_receipt_ids(
    policy: &ProgramCloseoutPolicySpec,
    child_contract: &LifecycleContract,
    outcome: &str,
) -> BTreeSet<String> {
    policy
        .terminal_child_receipt_requirements
        .iter()
        .find(|requirement| requirement.outcome_id == outcome)
        .map(|requirement| {
            requirement
                .required_receipts
                .iter()
                .cloned()
                .collect::<BTreeSet<_>>()
        })
        .filter(|ids| !ids.is_empty())
        .unwrap_or_else(|| {
            child_contract
                .receipts
                .iter()
                .map(|receipt| receipt.receipt_id.clone())
                .collect()
        })
}

fn validate_child_closeout_receipt_fields(
    policy: &ProgramCloseoutPolicySpec,
    outcome: &str,
    receipt_states: &BTreeMap<String, ReceiptPlanState>,
) -> Result<()> {
    let Some(requirement) = policy
        .terminal_child_receipt_requirements
        .iter()
        .find(|requirement| requirement.outcome_id == outcome)
    else {
        return Ok(());
    };
    for expected in &requirement.required_receipt_field_equals {
        let receipt = receipt_states
            .get(&expected.receipt_id)
            .with_context(|| format!("missing live receipt state {}", expected.receipt_id))?;
        let actual = receipt.fields.get(&expected.field).map(String::as_str);
        if actual != Some(expected.value.as_str()) {
            bail!(
                "receipt {} field {} must be {} for terminal outcome {}",
                expected.receipt_id,
                expected.field,
                expected.value,
                outcome
            );
        }
    }
    Ok(())
}

fn deferred_child_evidence_ready(
    repo_root: &Path,
    state: &ProgramChildPlanState,
    child: &ProgramChildSpec,
) -> Result<()> {
    if state.seed_role.is_none()
        && state.rollback_posture.is_none()
        && child.supersession_evidence.is_none()
    {
        bail!("missing seed_role, rollback_posture, or supersession_evidence");
    }
    if matches!(
        state.rollback_posture.as_deref(),
        Some("superseded" | "replaced" | "rejected")
    ) && child.supersession_evidence.is_none()
    {
        bail!("rollback_posture requires supersession_evidence");
    }
    if let Some(evidence_ref) = child.supersession_evidence.as_deref() {
        if !is_safe_repo_relative(evidence_ref) {
            bail!("supersession evidence reference is unsafe: {evidence_ref}");
        }
        let evidence_abs = resolve_lifecycle_target_path(repo_root, Path::new(evidence_ref))?;
        if !evidence_abs.is_file() {
            bail!("supersession evidence reference is dangling: {evidence_ref}");
        }
    }
    Ok(())
}

fn run_program_gate_by_id(
    repo_root: &Path,
    contract: &LifecycleContract,
    target_abs: &Path,
    gate_id: &str,
) -> Result<Vec<GatePlanResult>> {
    let Some(gate) = contract.gates.iter().find(|gate| gate.gate_id == gate_id) else {
        return Ok(Vec::new());
    };
    let validator = contract
        .validators
        .iter()
        .find(|validator| validator.validator_id == gate.validator_id)
        .with_context(|| format!("missing validator {}", gate.validator_id))?;
    Ok(vec![run_validator(
        repo_root, contract, target_abs, gate, validator,
    )?])
}

fn plan_program_level_route(
    repo_root: &Path,
    context: &ProgramParentContext,
    program_blockers: &mut Vec<ProgramBlocker>,
) -> Result<(Option<RoutePlanState>, Vec<GatePlanResult>, Option<String>)> {
    let target_abs = resolve_lifecycle_target_path(repo_root, Path::new(&context.target_rel))?;
    let target_state = build_target_state(repo_root, &context.loaded.contract, &target_abs)?;
    let Some(route) = select_route(&context.loaded.contract, &target_state)? else {
        return Ok((None, Vec::new(), None));
    };
    let route_id = route.route_id.clone();
    let gate_results =
        run_required_gates(repo_root, &context.loaded.contract, &target_abs, &route_id)?;
    if let Some(failed_gate_id) = gate_results
        .iter()
        .find(|result| !result.passed)
        .map(|result| result.gate_id.clone())
    {
        let recovery_route = fallback_route_for_gate(&context.loaded.contract, &failed_gate_id);
        program_blockers.push(ProgramBlocker {
            blocker_class: "validation-failed".to_string(),
            message: format!(
                "program route {} failed required gate {}",
                route_id, failed_gate_id
            ),
            recovery_route: recovery_route.clone(),
        });
        let fallback = recovery_route
            .as_ref()
            .and_then(|route_id| route_by_id(&context.loaded.contract, route_id))
            .cloned()
            .map(route_plan_state);
        return Ok((fallback, gate_results, Some(failed_gate_id)));
    }
    Ok((Some(route_plan_state(route)), gate_results, None))
}

fn resolve_program_child_target(active_target_abs: &Path) -> Result<PathBuf> {
    if active_target_abs.join("proposal.yml").is_file() {
        return Ok(active_target_abs.to_path_buf());
    }
    let Some(archived_target_abs) = archived_target_for_active_target(active_target_abs) else {
        return Ok(active_target_abs.to_path_buf());
    };
    if proposal_status_at_target(&archived_target_abs)?.as_deref() == Some("archived") {
        Ok(archived_target_abs)
    } else {
        Ok(active_target_abs.to_path_buf())
    }
}

fn proposal_status_at_target(target_abs: &Path) -> Result<Option<String>> {
    let manifest_path = target_abs.join("proposal.yml");
    if !manifest_path.is_file() {
        return Ok(None);
    }
    let manifest: serde_yaml::Value = serde_yaml::from_slice(&fs::read(&manifest_path)?)?;
    Ok(manifest
        .get("status")
        .and_then(|value| value.as_str())
        .map(str::to_string))
}

fn archived_target_for_active_target(active_target: &Path) -> Option<PathBuf> {
    let components = active_target.components().collect::<Vec<_>>();
    let proposals_index = components.windows(4).position(|window| {
        matches!(window[0], Component::Normal(part) if part == ".octon")
            && matches!(window[1], Component::Normal(part) if part == "inputs")
            && matches!(window[2], Component::Normal(part) if part == "exploratory")
            && matches!(window[3], Component::Normal(part) if part == "proposals")
    })?;
    let kind_index = proposals_index + 4;
    let id_index = proposals_index + 5;
    if components.len() != id_index + 1
        || matches!(components[kind_index], Component::Normal(part) if part == ".archive")
    {
        return None;
    }
    let mut archived = PathBuf::new();
    for component in components.iter().take(kind_index) {
        archived.push(component.as_os_str());
    }
    archived.push(".archive");
    archived.push(components[kind_index].as_os_str());
    archived.push(components[id_index].as_os_str());
    Some(archived)
}

fn rel_path_string(path: &Path) -> String {
    path.to_string_lossy().replace('\\', "/")
}

fn authority_write_scope_digest(scopes: &[String]) -> Option<String> {
    if scopes.is_empty() {
        return None;
    }
    let mut normalized = scopes.to_vec();
    normalized.sort();
    Some(format!(
        "sha256:{}",
        hex::encode(Sha256::digest(normalized.join("\n").as_bytes()))
    ))
}

fn authority_path_ref(repo_root: &Path, path: &Path) -> String {
    let abs = if path.is_absolute() {
        path.to_path_buf()
    } else {
        repo_root.join(path)
    };
    abs.strip_prefix(repo_root)
        .map(rel_path_string)
        .unwrap_or_else(|_| rel_path_string(path))
}

fn rel_path_under(rel: &str, prefix: &str) -> bool {
    let prefix = prefix.trim_end_matches('/');
    rel == prefix
        || rel
            .strip_prefix(prefix)
            .is_some_and(|tail| tail.starts_with('/'))
}

fn scope_contains_rel_path(scope: &str, rel: &str) -> bool {
    let scope = scope
        .trim()
        .trim_start_matches("./")
        .trim_end_matches("/**")
        .trim_end_matches('/');
    scope.is_empty() || scope == "." || scope == "*" || scope == "**" || rel_path_under(rel, scope)
}

fn declared_scopes_contain_path(scopes: &[String], rel: &str) -> bool {
    scopes
        .iter()
        .any(|scope| scope_contains_rel_path(scope, rel))
}

fn rel_is_manifest_governed_proposal_packet(rel: &str) -> bool {
    rel_path_under(rel, ".octon/inputs/exploratory/proposals")
        && !rel_path_under(rel, ".octon/inputs/exploratory/ideation")
}

fn operation_targets_proposal_lifecycle_packet(operation_class: &str) -> bool {
    matches!(
        operation_class,
        OPERATION_CLASS_EXECUTE_CHILD_ROUTE | OPERATION_CLASS_RETRY_CHILD_ROUTE
    )
}

fn classify_authority_path(
    repo_root: &Path,
    run_id: &str,
    operation_class: &str,
    path: &Path,
    declared_write_scopes: &[String],
) -> AuthorityPathClassification {
    let rel = authority_path_ref(repo_root, path);
    let abs = if path.is_absolute() {
        path.to_path_buf()
    } else {
        repo_root.join(path)
    };
    let workspace_contained = abs.starts_with(repo_root);
    let declared_scope_contained = declared_scopes_contain_path(declared_write_scopes, &rel);
    let run_control_prefix = format!(".octon/state/control/execution/runs/{run_id}");
    let run_evidence_prefix = format!(".octon/state/evidence/runs/{run_id}");
    let run_continuity_prefix = format!(".octon/state/continuity/runs/{run_id}");
    let current_run_lock_prefix = format!("{run_control_prefix}/locks");
    let current_run_tmp_prefix = format!("{run_control_prefix}/tmp");
    let current_run_scratch_prefix = format!("{run_control_prefix}/scratch");
    let under_current_run_generated = rel_path_under(&rel, &current_run_lock_prefix)
        || rel_path_under(&rel, &current_run_tmp_prefix)
        || rel_path_under(&rel, &current_run_scratch_prefix);
    if operation_class == OPERATION_CLASS_CLEANUP_CURRENT_RUN_ARTIFACT
        && under_current_run_generated
    {
        return AuthorityPathClassification {
            zone: AUTHORITY_ZONE_CURRENT_RUN_AGENT_ARTIFACT.to_string(),
            artifact_class: ARTIFACT_CLASS_CURRENT_RUN_GENERATED.to_string(),
            basis: "path is current-run lock/tmp/scratch artifact".to_string(),
            workspace_contained,
            declared_scope_contained,
            run_bound_current: true,
            generated_non_authority: true,
        };
    }
    if rel_path_under(&rel, &run_control_prefix) {
        return AuthorityPathClassification {
            zone: AUTHORITY_ZONE_RUN_BOUND.to_string(),
            artifact_class: ARTIFACT_CLASS_RUN_CONTROL.to_string(),
            basis: "path is under current run control root".to_string(),
            workspace_contained,
            declared_scope_contained: true,
            run_bound_current: true,
            generated_non_authority: false,
        };
    }
    if rel_path_under(&rel, &run_evidence_prefix) || rel_path_under(&rel, &run_continuity_prefix) {
        return AuthorityPathClassification {
            zone: AUTHORITY_ZONE_RUN_BOUND.to_string(),
            artifact_class: ARTIFACT_CLASS_RUN_EVIDENCE.to_string(),
            basis: "path is under current run evidence or continuity root".to_string(),
            workspace_contained,
            declared_scope_contained: true,
            run_bound_current: true,
            generated_non_authority: false,
        };
    }
    if rel_path_under(&rel, ".octon/generated")
        || rel_path_under(&rel, ".claude")
        || rel_path_under(&rel, ".cursor")
        || rel_path_under(&rel, ".codex/commands")
        || rel_path_under(&rel, ".codex/skills")
    {
        return AuthorityPathClassification {
            zone: AUTHORITY_ZONE_GENERATED_DERIVED.to_string(),
            artifact_class: ARTIFACT_CLASS_GENERATED_DERIVED.to_string(),
            basis: "path is generated derived projection surface".to_string(),
            workspace_contained,
            declared_scope_contained: true,
            run_bound_current: false,
            generated_non_authority: true,
        };
    }
    if rel_path_under(&rel, ".octon/framework")
        || rel_path_under(&rel, ".octon/inputs/additive")
        || rel_path_under(&rel, ".octon/instance/governance")
        || rel_path_under(&rel, ".octon/state/control/extensions")
        || rel_path_under(&rel, ".octon/state/control/capabilities")
    {
        return AuthorityPathClassification {
            zone: AUTHORITY_ZONE_AUTHORED_GOVERNANCE.to_string(),
            artifact_class: ARTIFACT_CLASS_AUTHORED_GOVERNANCE.to_string(),
            basis: "path is authored governance or durable control surface".to_string(),
            workspace_contained,
            declared_scope_contained,
            run_bound_current: false,
            generated_non_authority: false,
        };
    }
    if workspace_contained
        && declared_scope_contained
        && operation_targets_proposal_lifecycle_packet(operation_class)
        && rel_is_manifest_governed_proposal_packet(&rel)
    {
        return AuthorityPathClassification {
            zone: AUTHORITY_ZONE_WORKSPACE_DECLARED.to_string(),
            artifact_class: ARTIFACT_CLASS_WORKSPACE_SOURCE.to_string(),
            basis: "path is a declared manifest-governed proposal packet lifecycle target"
                .to_string(),
            workspace_contained,
            declared_scope_contained,
            run_bound_current: false,
            generated_non_authority: false,
        };
    }
    if workspace_contained && !rel_path_under(&rel, ".octon") && declared_scope_contained {
        return AuthorityPathClassification {
            zone: AUTHORITY_ZONE_WORKSPACE_DECLARED.to_string(),
            artifact_class: ARTIFACT_CLASS_WORKSPACE_SOURCE.to_string(),
            basis: "path is workspace-local and contained in declared write scope".to_string(),
            workspace_contained,
            declared_scope_contained,
            run_bound_current: false,
            generated_non_authority: false,
        };
    }
    AuthorityPathClassification {
        zone: AUTHORITY_ZONE_PROTECTED_OR_EXTERNAL.to_string(),
        artifact_class: if workspace_contained {
            ARTIFACT_CLASS_UNKNOWN.to_string()
        } else {
            ARTIFACT_CLASS_PROTECTED_OR_EXTERNAL.to_string()
        },
        basis: "path ownership, scope containment, or authority boundary is not autonomously safe"
            .to_string(),
        workspace_contained,
        declared_scope_contained,
        run_bound_current: false,
        generated_non_authority: false,
    }
}

fn authority_zone_rank(zone: &str) -> u8 {
    match zone {
        AUTHORITY_ZONE_PROTECTED_OR_EXTERNAL => 6,
        AUTHORITY_ZONE_AUTHORED_GOVERNANCE => 5,
        AUTHORITY_ZONE_WORKSPACE_DECLARED => 4,
        AUTHORITY_ZONE_CURRENT_RUN_AGENT_ARTIFACT => 3,
        AUTHORITY_ZONE_RUN_BOUND => 2,
        AUTHORITY_ZONE_GENERATED_DERIVED => 1,
        _ => 7,
    }
}

fn authority_zone_posture(zone: &str) -> (&'static str, &'static str, &'static str) {
    match zone {
        AUTHORITY_ZONE_RUN_BOUND => (
            APPROVAL_POSTURE_PRE_GRANTED,
            BLOCKER_AUTHORITY_ZONE_DENIED,
            "authority-zone-decision",
        ),
        AUTHORITY_ZONE_GENERATED_DERIVED => (
            APPROVAL_POSTURE_PRE_GRANTED,
            BLOCKER_AUTHORITY_ZONE_DENIED,
            "publication-receipt",
        ),
        AUTHORITY_ZONE_CURRENT_RUN_AGENT_ARTIFACT => (
            APPROVAL_POSTURE_PRE_GRANTED,
            "artifact-ownership-unclear",
            "authority-zone-decision",
        ),
        AUTHORITY_ZONE_AUTHORED_GOVERNANCE => (
            APPROVAL_POSTURE_APPROVAL_REQUIRED,
            BLOCKER_DURABLE_AUTHORITY_APPROVAL_REQUIRED,
            "approval-grant",
        ),
        AUTHORITY_ZONE_WORKSPACE_DECLARED => (
            APPROVAL_POSTURE_APPROVAL_REQUIRED,
            BLOCKER_PROTECTED_ARTIFACT_APPROVAL_REQUIRED,
            "authority-zone-decision",
        ),
        AUTHORITY_ZONE_PROTECTED_OR_EXTERNAL => (
            APPROVAL_POSTURE_DENY,
            BLOCKER_AUTHORITY_ZONE_AMBIGUOUS,
            "approval-grant",
        ),
        _ => (
            APPROVAL_POSTURE_DENY,
            BLOCKER_AUTHORITY_ZONE_AMBIGUOUS,
            "approval-grant",
        ),
    }
}

fn operation_allowed_in_zone(zone: &str, operation_class: &str) -> bool {
    match zone {
        AUTHORITY_ZONE_RUN_BOUND => matches!(
            operation_class,
            "inspect"
                | "append-run-evidence"
                | "update-run-control"
                | OPERATION_CLASS_RETRY_CHILD_ROUTE
                | OPERATION_CLASS_PROGRAM_RECOVERY_ACTION
                | OPERATION_CLASS_CLOSEOUT_READINESS
        ),
        AUTHORITY_ZONE_GENERATED_DERIVED => matches!(
            operation_class,
            "inspect"
                | OPERATION_CLASS_REFRESH_GENERATED_PROJECTION
                | OPERATION_CLASS_PROGRAM_RECOVERY_ACTION
        ),
        AUTHORITY_ZONE_CURRENT_RUN_AGENT_ARTIFACT => matches!(
            operation_class,
            "inspect" | OPERATION_CLASS_CLEANUP_CURRENT_RUN_ARTIFACT
        ),
        AUTHORITY_ZONE_AUTHORED_GOVERNANCE | AUTHORITY_ZONE_PROTECTED_OR_EXTERNAL => {
            operation_class == "inspect"
        }
        AUTHORITY_ZONE_WORKSPACE_DECLARED => matches!(
            operation_class,
            "inspect" | OPERATION_CLASS_EXECUTE_CHILD_ROUTE | OPERATION_CLASS_RETRY_CHILD_ROUTE
        ),
        _ => false,
    }
}

fn classify_authority_zone(
    repo_root: &Path,
    run_id: &str,
    child_id: Option<&str>,
    route_id: Option<&str>,
    blocker_class: Option<&str>,
    operation_class: &str,
    paths: &[PathBuf],
    declared_write_scopes: &[String],
    source_authority_digest: Option<&str>,
) -> AuthorityZoneDecision {
    let path_refs = paths
        .iter()
        .map(|path| authority_path_ref(repo_root, path))
        .collect::<Vec<_>>();
    let mut classifications = paths
        .iter()
        .map(|path| {
            classify_authority_path(
                repo_root,
                run_id,
                operation_class,
                path,
                declared_write_scopes,
            )
        })
        .collect::<Vec<_>>();
    if classifications.is_empty() {
        classifications.push(AuthorityPathClassification {
            zone: AUTHORITY_ZONE_PROTECTED_OR_EXTERNAL.to_string(),
            artifact_class: ARTIFACT_CLASS_UNKNOWN.to_string(),
            basis: "no path evidence was supplied for authority-zone classification".to_string(),
            workspace_contained: false,
            declared_scope_contained: false,
            run_bound_current: false,
            generated_non_authority: false,
        });
    }
    classifications.sort_by_key(|classification| authority_zone_rank(&classification.zone));
    let selected = classifications
        .last()
        .cloned()
        .expect("authority classifications are non-empty");
    let mixed_zones = classifications
        .iter()
        .any(|classification| classification.zone != selected.zone);
    let zone = if mixed_zones {
        AUTHORITY_ZONE_PROTECTED_OR_EXTERNAL.to_string()
    } else {
        selected.zone.clone()
    };
    let artifact_class = if mixed_zones {
        ARTIFACT_CLASS_UNKNOWN.to_string()
    } else {
        selected.artifact_class.clone()
    };
    let (approval_posture, fail_closed_blocker, evidence_requirement) =
        authority_zone_posture(&zone);
    let workspace_contained = classifications
        .iter()
        .all(|classification| classification.workspace_contained);
    let declared_scope_contained = classifications
        .iter()
        .all(|classification| classification.declared_scope_contained);
    let run_bound_current = classifications
        .iter()
        .any(|classification| classification.run_bound_current);
    let generated_non_authority = classifications
        .iter()
        .any(|classification| classification.generated_non_authority);
    let operation_allowed = operation_allowed_in_zone(&zone, operation_class);
    let autonomous_allowed = approval_posture == APPROVAL_POSTURE_PRE_GRANTED
        && operation_allowed
        && workspace_contained
        && !mixed_zones
        && match zone.as_str() {
            AUTHORITY_ZONE_RUN_BOUND => run_bound_current,
            AUTHORITY_ZONE_GENERATED_DERIVED => generated_non_authority,
            AUTHORITY_ZONE_CURRENT_RUN_AGENT_ARTIFACT => {
                run_bound_current && declared_scope_contained && generated_non_authority
            }
            _ => false,
        };
    let mut basis = classifications
        .iter()
        .map(|classification| classification.basis.clone())
        .collect::<Vec<_>>();
    basis.push(format!("operation_class={operation_class}"));
    basis.push(format!("operation_allowed={operation_allowed}"));
    if mixed_zones {
        basis.push("mixed authority zones require fail-closed classification".to_string());
    }
    let digest_input = format!(
        "{run_id}:{operation_class}:{}:{}",
        path_refs.join("|"),
        declared_write_scopes.join("|")
    );
    let digest = hex::encode(Sha256::digest(digest_input.as_bytes()));
    let decision_id = format!(
        "authority-zone-{}-{}",
        sanitize_run_id(operation_class).unwrap_or_else(|_| "operation".to_string()),
        &digest[..12]
    );
    AuthorityZoneDecision {
        schema_version: "octon-authority-zone-decision-v1".to_string(),
        decision_id,
        run_id: run_id.to_string(),
        child_id: child_id.map(str::to_string),
        route_id: route_id.map(str::to_string),
        blocker_class: blocker_class.map(str::to_string),
        operation_class: operation_class.to_string(),
        authority_zone: zone,
        artifact_class,
        approval_posture: approval_posture.to_string(),
        autonomous_allowed,
        fail_closed_blocker: fail_closed_blocker.to_string(),
        path_refs,
        declared_write_scopes: declared_write_scopes.to_vec(),
        workspace_contained,
        declared_scope_contained,
        run_bound_current,
        generated_non_authority,
        source_authority_digest: source_authority_digest.map(str::to_string),
        write_scope_digest: authority_write_scope_digest(declared_write_scopes),
        evidence_requirement: evidence_requirement.to_string(),
        basis,
        forbidden_authority_consumers: if generated_non_authority {
            vec![
                "approval".to_string(),
                "child-receipt".to_string(),
                "child-validation".to_string(),
                "child-promotion".to_string(),
                "child-archive".to_string(),
                "terminal-truth".to_string(),
                "closeout-truth".to_string(),
            ]
        } else {
            Vec::new()
        },
        decided_at: now_rfc3339().unwrap_or_else(|_| "unknown".to_string()),
    }
}

fn write_authority_zone_decision(
    evidence_root: &Path,
    decision: &AuthorityZoneDecision,
) -> Result<String> {
    let root = evidence_root.join("authority-zone-decisions");
    fs::create_dir_all(&root)?;
    let file_stem = sanitize_run_id(&decision.decision_id)?;
    let path = root.join(format!("{file_stem}.yml"));
    fs::write(&path, serde_yaml::to_string(decision)?)?;
    Ok(rel_path_string(&path))
}

fn recovery_recipe_allows_authority_decision(
    recipe: Option<&ProgramRecoveryRecipeSpec>,
    decision: &AuthorityZoneDecision,
) -> bool {
    let Some(recipe) = recipe else {
        return false;
    };
    if !recipe.allowed_authority_zones.is_empty()
        && !recipe
            .allowed_authority_zones
            .iter()
            .any(|zone| zone == &decision.authority_zone)
    {
        return false;
    }
    if !recipe.allowed_artifact_classes.is_empty()
        && !recipe
            .allowed_artifact_classes
            .iter()
            .any(|artifact| artifact == &decision.artifact_class)
    {
        return false;
    }
    if recipe
        .operation_class
        .as_deref()
        .is_some_and(|operation| operation != decision.operation_class)
    {
        return false;
    }
    if recipe.requires_run_binding && !decision.run_bound_current {
        return false;
    }
    if recipe.requires_declared_write_scope && !decision.declared_scope_contained {
        return false;
    }
    if recipe
        .human_required_for_zones
        .iter()
        .any(|zone| zone == &decision.authority_zone)
        && !recipe.human_required
    {
        return false;
    }
    true
}

fn authority_decision_allows_route_unattended(decision: &AuthorityZoneDecision) -> bool {
    if decision.autonomous_allowed {
        return true;
    }
    decision.authority_zone == AUTHORITY_ZONE_WORKSPACE_DECLARED
        && decision.operation_class == OPERATION_CLASS_EXECUTE_CHILD_ROUTE
        && decision.workspace_contained
        && decision.declared_scope_contained
}

fn child_route_authority_decision(
    repo_root: &Path,
    run_id: &str,
    state: &ProgramChildPlanState,
    route_id: &str,
    operation_class: &str,
) -> AuthorityZoneDecision {
    classify_authority_zone(
        repo_root,
        run_id,
        Some(&state.child_id),
        Some(route_id),
        None,
        operation_class,
        &[PathBuf::from(&state.target)],
        &state.write_scopes,
        None,
    )
}

fn child_gate_status_from_lifecycle_plan(plan: &LifecyclePlanResult) -> ProgramChildGateStatus {
    let terminal = plan.terminal_outcome.is_some();
    let verification = terminal
        || (receipt_passed(&plan.receipt_states, "implementation-run")
            && receipt_passed(&plan.receipt_states, "implementation-conformance")
            && receipt_passed(&plan.receipt_states, "post-implementation-drift"));
    let closeout = terminal || closeout_receipt_authorizes_archive(&plan.receipt_states);
    ProgramChildGateStatus {
        terminal,
        verification,
        closeout,
    }
}

fn receipt_passed(receipts: &BTreeMap<String, ReceiptPlanState>, receipt_id: &str) -> bool {
    receipts
        .get(receipt_id)
        .map(|receipt| {
            receipt.exists
                && receipt.missing_required_fields.is_empty()
                && receipt.verdict.as_deref() == Some("pass")
        })
        .unwrap_or(false)
}

fn child_implementation_blocker_class(
    plan: &LifecyclePlanResult,
    child_target_abs: &Path,
) -> Option<&'static str> {
    if receipt_verdict_matches(
        &plan.receipt_states,
        "implementation-run",
        &["blocked", "fail"],
    ) {
        return Some(
            if child_receipts_report_projection_drift(child_target_abs) {
                "publication-drift"
            } else {
                "implementation-blocked"
            },
        );
    }
    if receipt_verdict_matches(
        &plan.receipt_states,
        "implementation-conformance",
        &["blocked", "fail"],
    ) || receipt_verdict_matches(
        &plan.receipt_states,
        "post-implementation-drift",
        &["blocked", "fail"],
    ) {
        return Some(
            if child_receipts_report_projection_drift(child_target_abs) {
                "publication-drift"
            } else {
                "validation-failed"
            },
        );
    }
    None
}

fn child_implementation_blocker_message(blocker_class: &str) -> String {
    match blocker_class {
        "publication-drift" => {
            "child implementation is blocked by generated/effective or read-model projection drift"
                .to_string()
        }
        "implementation-blocked" => {
            "child implementation receipt reports a blocked implementation run".to_string()
        }
        _ => "child implementation validation failed".to_string(),
    }
}

fn receipt_verdict_matches(
    receipts: &BTreeMap<String, ReceiptPlanState>,
    receipt_id: &str,
    expected: &[&str],
) -> bool {
    receipts
        .get(receipt_id)
        .and_then(|receipt| receipt.verdict.as_deref())
        .map(|verdict| expected.iter().any(|value| value == &verdict))
        .unwrap_or(false)
}

fn child_receipts_report_projection_drift(child_target_abs: &Path) -> bool {
    [
        "support/implementation-run.md",
        "support/implementation-conformance-review.md",
        "support/post-implementation-drift-churn-review.md",
        "support/validation.md",
    ]
    .iter()
    .filter_map(|path| fs::read_to_string(child_target_abs.join(path)).ok())
    .any(|content| {
        let content = content.to_ascii_lowercase();
        content.contains("generated/effective")
            || content.contains("read-model")
            || content.contains("projection drift")
            || content.contains("publication drift")
            || content.contains("digest drift")
    })
}

fn closeout_receipt_authorizes_archive(receipts: &BTreeMap<String, ReceiptPlanState>) -> bool {
    receipts
        .get("proposal-closeout")
        .map(|receipt| {
            receipt.exists
                && receipt.missing_required_fields.is_empty()
                && receipt.verdict.as_deref() == Some("pass")
                && receipt.fields.get("archive_authorized").map(String::as_str) == Some("yes")
        })
        .unwrap_or(false)
}

fn apply_dependency_blockers(child_states: &mut BTreeMap<String, ProgramChildPlanState>) {
    let gate_statuses = child_states
        .iter()
        .map(|(id, state)| (id.clone(), state.gate_status.clone()))
        .collect::<BTreeMap<_, _>>();
    for state in child_states.values_mut() {
        if state.deferred {
            continue;
        }
        let required_gate = state
            .dependency_gate
            .as_deref()
            .unwrap_or("terminal")
            .to_string();
        for dependency in &state.dependencies {
            let status = gate_statuses.get(dependency);
            let (satisfied, observed_gate, reason) =
                dependency_gate_satisfied(status, &required_gate);
            state.dependency_gate_status.insert(
                dependency.clone(),
                ProgramDependencyGateStatus {
                    dependency_id: dependency.clone(),
                    required_gate: required_gate.clone(),
                    satisfied,
                    observed_gate,
                    reason: reason.clone(),
                },
            );
            if !satisfied {
                state.blockers.push(ProgramBlocker {
                    blocker_class: "dependency-gate-unsatisfied".to_string(),
                    message: format!(
                        "dependency {dependency} has not satisfied {required_gate} gate: {reason}"
                    ),
                    recovery_route: None,
                });
            }
        }
    }
}

fn apply_closeout_hygiene_suppressions(
    repo_root: &Path,
    checkpoint: Option<&ProgramLifecycleCheckpoint>,
    child_states: &mut BTreeMap<String, ProgramChildPlanState>,
) -> Result<BTreeMap<String, ProgramCloseoutHygieneSuppression>> {
    let mut active = BTreeMap::new();
    let Some(checkpoint) = checkpoint else {
        return Ok(active);
    };
    for suppression in checkpoint.closeout_hygiene_suppressions.values() {
        if !route_has_closeout_hygiene_preflight(&suppression.route_id) {
            continue;
        }
        let Some(state) = child_states.get_mut(&suppression.child_id) else {
            continue;
        };
        if state.terminal_outcome.is_some() {
            continue;
        }
        let selected_route_matches = state
            .selected_route
            .as_ref()
            .map(|route| route.route_id.as_str())
            == Some(suppression.route_id.as_str());
        if !selected_route_matches {
            continue;
        }
        let Some(current) =
            closeout_worktree_hygiene_classifier(repo_root, &state.target, &checkpoint.run_id)?
        else {
            continue;
        };
        if current.decision.status == "pass" {
            continue;
        }
        if current.decision.blocker_class != suppression.blocker_class {
            continue;
        }
        if residue_cleanup_fingerprint(current.decision.foreign_fingerprint.as_deref())
            != residue_cleanup_fingerprint(
                suppression.worktree_hygiene_foreign_fingerprint.as_deref(),
            )
        {
            continue;
        }
        let blocker = ProgramBlocker {
            blocker_class: suppression.blocker_class.clone(),
            message: suppression.message.clone(),
            recovery_route: None,
        };
        if !state.blockers.iter().any(|existing| {
            existing.blocker_class == blocker.blocker_class && existing.message == blocker.message
        }) {
            state.blockers.push(blocker);
        }
        active.insert(
            closeout_hygiene_suppression_key(&suppression.child_id, &suppression.route_id),
            suppression.clone(),
        );
    }
    Ok(active)
}

fn apply_lifecycle_residue_cleanup_blocker(
    contract: &LifecycleContract,
    program: &ProgramSpec,
    closeout_hygiene_suppressions: &BTreeMap<String, ProgramCloseoutHygieneSuppression>,
    checkpoint: Option<&ProgramLifecycleCheckpoint>,
    invocation_authority: &str,
    program_blockers: &mut Vec<ProgramBlocker>,
) {
    if !lifecycle_residue_cleanup_authorized(invocation_authority)
        || closeout_hygiene_suppressions.is_empty()
        || route_by_id(contract, ROUTE_ID_CLEANUP_LIFECYCLE_RESIDUE).is_none()
    {
        return;
    }
    let Some(recipe) =
        recovery_recipe_for_blocker(program, BLOCKER_LIFECYCLE_RESIDUE_CLEANUP_NEEDED)
    else {
        return;
    };
    if validate_recovery_recipe_metadata(recipe, BLOCKER_LIFECYCLE_RESIDUE_CLEANUP_NEEDED, false)
        .is_err()
    {
        return;
    }
    for suppression in closeout_hygiene_suppressions.values() {
        if suppression.blocker_class != "artifact-ownership-unclear" {
            continue;
        }
        if residue_cleanup_attempt_recorded(checkpoint, suppression) {
            continue;
        }
        let fingerprint = residue_cleanup_fingerprint(
            suppression.worktree_hygiene_foreign_fingerprint.as_deref(),
        );
        if program_blockers.iter().any(|blocker| {
            blocker.blocker_class == BLOCKER_LIFECYCLE_RESIDUE_CLEANUP_NEEDED
                && blocker
                    .message
                    .contains(&format!("residue_fingerprint={fingerprint}"))
        }) {
            continue;
        }
        program_blockers.push(ProgramBlocker {
            blocker_class: BLOCKER_LIFECYCLE_RESIDUE_CLEANUP_NEEDED.to_string(),
            message: format!(
                "child {} route {} is blocked by lifecycle residue; residue_fingerprint={fingerprint}; cleanup-lifecycle-residue may classify and close out safe residue without bypassing ownership gates",
                suppression.child_id, suppression.route_id
            ),
            recovery_route: Some(ROUTE_ID_CLEANUP_LIFECYCLE_RESIDUE.to_string()),
        });
        break;
    }
}

fn lifecycle_residue_cleanup_authorized(invocation_authority: &str) -> bool {
    matches!(invocation_authority, "unattended" | "grant-consumption")
}

fn residue_cleanup_fingerprint(fingerprint: Option<&str>) -> String {
    fingerprint
        .map(str::trim)
        .filter(|value| !value.is_empty())
        .unwrap_or(UNKNOWN_RESIDUE_FINGERPRINT)
        .to_string()
}

fn residue_cleanup_attempt_key(
    child_id: &str,
    route_id: &str,
    blocker_class: &str,
    fingerprint: Option<&str>,
) -> String {
    format!(
        "{child_id}:{route_id}:{blocker_class}:{}",
        residue_cleanup_fingerprint(fingerprint)
    )
}

fn residue_cleanup_attempt_recorded(
    checkpoint: Option<&ProgramLifecycleCheckpoint>,
    suppression: &ProgramCloseoutHygieneSuppression,
) -> bool {
    let Some(checkpoint) = checkpoint else {
        return false;
    };
    checkpoint
        .residue_cleanup_attempts
        .contains_key(&residue_cleanup_attempt_key(
            &suppression.child_id,
            &suppression.route_id,
            &suppression.blocker_class,
            suppression.worktree_hygiene_foreign_fingerprint.as_deref(),
        ))
}

fn record_residue_cleanup_attempts_for_parent_route(
    attempts: &mut BTreeMap<String, ProgramResidueCleanupAttempt>,
    plan: &ProgramLifecyclePlanResult,
    result: &LifecycleRouteExecutionResult,
) {
    if plan
        .program_route
        .as_ref()
        .map(|route| route.route_id.as_str())
        != Some(ROUTE_ID_CLEANUP_LIFECYCLE_RESIDUE)
        || result.route_id != ROUTE_ID_CLEANUP_LIFECYCLE_RESIDUE
    {
        return;
    }
    for suppression in plan.closeout_hygiene_suppressions.values() {
        if suppression.blocker_class != "artifact-ownership-unclear" {
            continue;
        }
        let fingerprint = residue_cleanup_fingerprint(
            suppression.worktree_hygiene_foreign_fingerprint.as_deref(),
        );
        let key = residue_cleanup_attempt_key(
            &suppression.child_id,
            &suppression.route_id,
            &suppression.blocker_class,
            Some(&fingerprint),
        );
        attempts.insert(
            key,
            ProgramResidueCleanupAttempt {
                child_id: suppression.child_id.clone(),
                route_id: suppression.route_id.clone(),
                blocker_class: suppression.blocker_class.clone(),
                residue_fingerprint: fingerprint,
                cleanup_route_id: ROUTE_ID_CLEANUP_LIFECYCLE_RESIDUE.to_string(),
                status: result.status.clone(),
                evidence_paths: result
                    .evidence_paths
                    .iter()
                    .map(|path| path.to_string_lossy().to_string())
                    .collect(),
            },
        );
    }
}

fn checkpoint_for_post_execution_replan_with_residue_attempts(
    checkpoint: Option<&ProgramLifecycleCheckpoint>,
    residue_cleanup_attempts: &BTreeMap<String, ProgramResidueCleanupAttempt>,
) -> Option<ProgramLifecycleCheckpoint> {
    checkpoint_for_post_execution_replan(checkpoint).map(|mut checkpoint| {
        checkpoint.residue_cleanup_attempts = residue_cleanup_attempts.clone();
        checkpoint
    })
}

fn dependency_gate_satisfied(
    status: Option<&ProgramChildGateStatus>,
    required_gate: &str,
) -> (bool, String, String) {
    let Some(status) = status else {
        return (
            false,
            "missing".to_string(),
            "dependency is absent from child state map".to_string(),
        );
    };
    let observed_gate = observed_gate(status);
    let satisfied = match required_gate {
        "verification" => status.verification || status.closeout || status.terminal,
        "closeout" => status.closeout || status.terminal,
        "terminal" => status.terminal,
        _ => status.terminal,
    };
    let reason = if satisfied {
        format!("observed {observed_gate}")
    } else {
        format!("observed {observed_gate}")
    };
    (satisfied, observed_gate, reason)
}

fn observed_gate(status: &ProgramChildGateStatus) -> String {
    if status.terminal {
        "terminal".to_string()
    } else if status.closeout {
        "closeout".to_string()
    } else if status.verification {
        "verification".to_string()
    } else {
        "none".to_string()
    }
}

fn apply_checkpoint_child_drift(
    repo_root: &Path,
    child_states: &mut BTreeMap<String, ProgramChildPlanState>,
    checkpoint: Option<&ProgramLifecycleCheckpoint>,
) {
    let Some(checkpoint) = checkpoint else {
        return;
    };
    for (child_id, checkpoint_state) in &checkpoint.child_states {
        let Some(state) = child_states.get_mut(child_id) else {
            continue;
        };
        let archived_relocation =
            archived_target_for_active_target(Path::new(&checkpoint_state.target))
                .map(|archived| rel_path_string(&archived) == state.target)
                .unwrap_or(false)
                && state.terminal_outcome.as_deref() == Some("archived");
        if archived_relocation {
            continue;
        }
        if state.target != checkpoint_state.target {
            state.blockers.push(ProgramBlocker {
                blocker_class: "target-drift-unclear".to_string(),
                message: format!(
                    "child target changed from {} to {}",
                    checkpoint_state.target, state.target
                ),
                recovery_route: None,
            });
        }
        if state.receipt_digests != checkpoint_state.receipt_digests {
            let stable_authority_shape = state.target == checkpoint_state.target
                && state.write_scopes == checkpoint_state.write_scopes;
            let blocker_class = if stable_authority_shape
                && child_drift_has_current_run_route_evidence(repo_root, checkpoint, child_id)
            {
                "target-drift-explained"
            } else {
                "target-drift-unclear"
            };
            state.blockers.push(ProgramBlocker {
                blocker_class: blocker_class.to_string(),
                message: if blocker_class == "target-drift-explained" {
                    "child receipt digest set changed since checkpoint with current-run child route evidence".to_string()
                } else {
                    "child receipt digest set changed since checkpoint without current-run child-owned route evidence".to_string()
                },
                recovery_route: None,
            });
        }
        if state.write_scopes != checkpoint_state.write_scopes {
            state.blockers.push(ProgramBlocker {
                blocker_class: "target-drift-unclear".to_string(),
                message: "child write scope set changed since checkpoint".to_string(),
                recovery_route: None,
            });
        }
    }
}

fn child_drift_has_current_run_route_evidence(
    repo_root: &Path,
    checkpoint: &ProgramLifecycleCheckpoint,
    child_id: &str,
) -> bool {
    checkpoint
        .recovery_attempts
        .get(child_id)
        .copied()
        .unwrap_or(0)
        > 0
        && repo_root
            .join(".octon")
            .join(WORKFLOW_EVIDENCE_ROOT_REL)
            .join(&checkpoint.run_id)
            .join("children")
            .join(child_id)
            .is_dir()
}

fn apply_child_receipt_recovery_routes(
    octon_dir: &Path,
    repo_root: &Path,
    program: &ProgramSpec,
    child_states: &mut BTreeMap<String, ProgramChildPlanState>,
) -> Result<()> {
    for state in child_states.values_mut() {
        let child_has_unresolved_authority = state.blockers.iter().any(|blocker| {
            matches!(
                classify_program_blocker_class(&blocker.blocker_class),
                ProgramBlockerDisposition::Human | ProgramBlockerDisposition::Unsafe
            )
        });
        if child_has_unresolved_authority {
            continue;
        }
        let needs_receipt_recovery = state.blockers.iter().any(|blocker| {
            matches!(
                blocker.blocker_class.as_str(),
                "stale-receipt" | "missing-evidence"
            ) && recovery_route_for_blocker(program, blocker).is_none()
                && recovery_action_id(program, &blocker.blocker_class).is_none()
        });
        if !needs_receipt_recovery {
            continue;
        }
        let receipt_ids = recoverable_child_receipt_ids(octon_dir, state)?;
        let recovery_route = if receipt_ids.is_empty() {
            None
        } else {
            enterable_child_receipt_recovery_route(octon_dir, repo_root, state, &receipt_ids)?
        };
        let route_candidates = if receipt_ids.is_empty() {
            Vec::new()
        } else {
            child_receipt_recovery_route_candidates(octon_dir, state, &receipt_ids)?
        };
        for blocker in state.blockers.iter_mut().filter(|blocker| {
            matches!(
                blocker.blocker_class.as_str(),
                "stale-receipt" | "missing-evidence"
            ) && blocker.recovery_route.is_none()
                && recovery_route_id(program, &blocker.blocker_class).is_none()
                && recovery_action_id(program, &blocker.blocker_class).is_none()
        }) {
            if let Some(route_id) = recovery_route.as_ref() {
                blocker.recovery_route = Some(route_id.clone());
                blocker.message = format!(
                    "{}; selected child-owned receipt recovery route {}",
                    blocker.message, route_id
                );
            } else {
                blocker.blocker_class = "receipt-recovery-unavailable".to_string();
                blocker.message = if receipt_ids.is_empty() {
                    "child-owned receipt recovery required but no absent, stale, or incomplete child receipt id was discoverable from live child contract state".to_string()
                } else {
                    format!(
                        "child-owned receipts require recovery but no enterable owning route exists: {}; candidate owning routes: {}",
                        receipt_ids.join(","),
                        if route_candidates.is_empty() {
                            "none".to_string()
                        } else {
                            route_candidates.join(",")
                        }
                    )
                };
                blocker.recovery_route = None;
            }
        }
    }
    Ok(())
}

fn recoverable_child_receipt_ids(
    octon_dir: &Path,
    state: &ProgramChildPlanState,
) -> Result<Vec<String>> {
    let plan = plan_lifecycle_from_octon_dir(
        octon_dir,
        &state.child_lifecycle_id,
        Path::new(&state.target),
    )?;
    let mut receipt_ids = plan
        .receipt_states
        .iter()
        .filter(|(_, receipt)| {
            !receipt.exists
                || receipt.stale == Some(true)
                || (receipt.exists && !receipt.missing_required_fields.is_empty())
        })
        .map(|(id, _)| id.clone())
        .collect::<Vec<_>>();
    receipt_ids.sort();
    receipt_ids.dedup();
    Ok(receipt_ids)
}

fn child_receipt_recovery_route_candidates(
    octon_dir: &Path,
    state: &ProgramChildPlanState,
    receipt_ids: &[String],
) -> Result<Vec<String>> {
    let loaded = load_lifecycle_contract(octon_dir, &state.child_lifecycle_id)?;
    let mut route_ids = loaded
        .contract
        .routes
        .iter()
        .filter(|route| {
            route
                .completion
                .as_ref()
                .map(|completion| {
                    completion
                        .expected_receipts
                        .iter()
                        .any(|receipt_id| receipt_ids.iter().any(|needed| needed == receipt_id))
                })
                .unwrap_or(false)
        })
        .map(|route| route.route_id.clone())
        .collect::<Vec<_>>();
    route_ids.sort();
    route_ids.dedup();
    Ok(route_ids)
}

fn enterable_child_receipt_recovery_route(
    octon_dir: &Path,
    repo_root: &Path,
    state: &ProgramChildPlanState,
    receipt_ids: &[String],
) -> Result<Option<String>> {
    let loaded = load_lifecycle_contract(octon_dir, &state.child_lifecycle_id)?;
    let target_abs = resolve_lifecycle_target_path(repo_root, Path::new(&state.target))?;
    let target_state = build_target_state(repo_root, &loaded.contract, &target_abs)?;
    for route in &loaded.contract.routes {
        let produces_needed_receipt = route
            .completion
            .as_ref()
            .map(|completion| {
                completion
                    .expected_receipts
                    .iter()
                    .any(|receipt_id| receipt_ids.iter().any(|needed| needed == receipt_id))
            })
            .unwrap_or(false);
        if !produces_needed_receipt {
            continue;
        }
        let enterable = route
            .enter_when
            .as_ref()
            .map(|condition| eval_condition(condition, &loaded.contract, &target_state))
            .transpose()?
            .unwrap_or(false);
        if enterable {
            return Ok(Some(route.route_id.clone()));
        }
    }
    Ok(None)
}

fn apply_recoverable_dispatchability_blockers(
    program: &ProgramSpec,
    child_states: &mut BTreeMap<String, ProgramChildPlanState>,
    program_blockers: &mut Vec<ProgramBlocker>,
) {
    for blocker in program_blockers.iter_mut() {
        if recoverable_blocker_lacks_dispatch(program, blocker) {
            let original_class = blocker.blocker_class.clone();
            blocker.blocker_class = "recovery-route-unavailable".to_string();
            blocker.message = format!(
                "program blocker {original_class} has no executable recovery route, action, or wait rule: {}",
                blocker.message
            );
            blocker.recovery_route = None;
        }
    }
    for state in child_states.values_mut() {
        for blocker in &mut state.blockers {
            if recoverable_blocker_lacks_dispatch(program, blocker) {
                let original_class = blocker.blocker_class.clone();
                blocker.blocker_class = "recovery-route-unavailable".to_string();
                blocker.message = format!(
                    "child blocker {original_class} has no executable recovery route, action, or wait rule: {}",
                    blocker.message
                );
                blocker.recovery_route = None;
            }
        }
    }
}

fn recoverable_blocker_lacks_dispatch(program: &ProgramSpec, blocker: &ProgramBlocker) -> bool {
    if classify_program_blocker_class(&blocker.blocker_class)
        != ProgramBlockerDisposition::Recoverable
    {
        return false;
    }
    if declared_wait_blocker(&blocker.blocker_class) {
        return false;
    }
    recovery_route_for_blocker(program, blocker).is_none()
        && recovery_action_id(program, &blocker.blocker_class).is_none()
}

fn declared_wait_blocker(blocker_class: &str) -> bool {
    matches!(
        blocker_class,
        "dependency-gate-unsatisfied"
            | "dependency-blocked"
            | "scheduler-paused"
            | "deferred"
            | "write-scope-serialization-required"
    )
}

fn apply_executor_result_retry_blockers(
    child_states: &mut BTreeMap<String, ProgramChildPlanState>,
    checkpoint: Option<&ProgramLifecycleCheckpoint>,
) {
    let Some(checkpoint) = checkpoint else {
        return;
    };
    for state in child_states.values_mut() {
        if state.terminal_outcome.is_some() {
            continue;
        }
        for blocker_class in ["executor-failed", "executor-timed-out"] {
            let attempts = recovery_attempt_count(checkpoint, &state.child_id, blocker_class);
            if attempts == 0
                || state
                    .blockers
                    .iter()
                    .any(|blocker| blocker.blocker_class == blocker_class)
            {
                continue;
            }
            state.blockers.push(ProgramBlocker {
                blocker_class: blocker_class.to_string(),
                message: format!(
                    "previous child route execution ended with {blocker_class}; attempts recorded: {attempts}"
                ),
                recovery_route: state.selected_route.as_ref().map(|route| route.route_id.clone()),
            });
        }
    }
}

fn apply_program_recovery_action_budget_blockers(
    program: &ProgramSpec,
    child_states: &mut BTreeMap<String, ProgramChildPlanState>,
    program_blockers: &mut Vec<ProgramBlocker>,
    checkpoint: Option<&ProgramLifecycleCheckpoint>,
) {
    let Some(checkpoint) = checkpoint else {
        return;
    };
    for blocker in program_blockers.iter_mut() {
        apply_program_recovery_action_budget_to_blocker(program, blocker, checkpoint);
    }
    for state in child_states.values_mut() {
        for blocker in &mut state.blockers {
            apply_program_recovery_action_budget_to_blocker(program, blocker, checkpoint);
        }
    }
}

fn apply_program_recovery_action_budget_to_blocker(
    program: &ProgramSpec,
    blocker: &mut ProgramBlocker,
    checkpoint: &ProgramLifecycleCheckpoint,
) {
    let Some(action_id) = recovery_action_id(program, &blocker.blocker_class) else {
        return;
    };
    let budget = recovery_attempt_budget(program, &blocker.blocker_class)
        .or(program.recovery_policy.max_recovery_attempts)
        .unwrap_or(1);
    let used =
        program_recovery_action_attempt_count(Some(checkpoint), &blocker.blocker_class, action_id);
    if used < budget {
        return;
    }
    let original = blocker.blocker_class.clone();
    blocker.blocker_class = "recovery-budget-override-required".to_string();
    blocker.message = format!(
        "program recovery action {action_id} for {original} exhausted retry budget: attempts {used} budget {budget}"
    );
    blocker.recovery_route = None;
}

fn apply_recovery_budget_blockers(
    program: &ProgramSpec,
    child_states: &mut BTreeMap<String, ProgramChildPlanState>,
    checkpoint: Option<&ProgramLifecycleCheckpoint>,
) {
    let Some(checkpoint) = checkpoint else {
        return;
    };
    for state in child_states.values_mut() {
        let exhausted = state
            .blockers
            .iter()
            .enumerate()
            .find_map(|(index, blocker)| {
                let budget = recovery_attempt_budget(program, &blocker.blocker_class)?;
                let attempts =
                    recovery_attempt_count(checkpoint, &state.child_id, &blocker.blocker_class);
                (attempts >= budget)
                    .then(|| (index, blocker.blocker_class.clone(), attempts, budget))
            });
        if let Some((exhausted_index, blocker_class, attempts, budget)) = exhausted {
            let alternate_safe_route = state.blockers.iter().find_map(|blocker| {
                (blocker.blocker_class.as_str() != blocker_class.as_str()
                    && recovery_route_for_blocker(program, blocker).is_some()
                    && recovery_delegation_contract_basis(Some(program), &blocker.blocker_class)
                        .is_some())
                .then(|| recovery_route_for_blocker(program, blocker))
                .flatten()
                .map(str::to_string)
            });
            let budget_blocker_class = if alternate_safe_route.is_some() {
                "recovery-budget-exhausted-alternate-route"
            } else {
                "recovery-budget-override-required"
            };
            state.blockers.remove(exhausted_index);
            state.blockers.push(ProgramBlocker {
                blocker_class: budget_blocker_class.to_string(),
                message: format!(
                    "recovery budget exhausted for {blocker_class}: attempts {attempts} budget {budget}"
                ),
                recovery_route: alternate_safe_route,
            });
        }
    }
}

fn apply_recovery_progress_blockers(
    program: &ProgramSpec,
    child_states: &mut BTreeMap<String, ProgramChildPlanState>,
    checkpoint: Option<&ProgramLifecycleCheckpoint>,
) {
    let Some(checkpoint) = checkpoint else {
        return;
    };
    for state in child_states.values_mut() {
        let no_progress = state
            .blockers
            .iter()
            .enumerate()
            .find_map(|(index, blocker)| {
                let route_id = recovery_route_for_blocker(program, blocker)
                    .or(blocker.recovery_route.as_deref())
                    .or_else(|| {
                        state
                            .selected_route
                            .as_ref()
                            .map(|route| route.route_id.as_str())
                    })?;
                let key = recovery_progress_key(&state.child_id, route_id, &blocker.blocker_class);
                let previous = checkpoint.recovery_progress_fingerprints.get(&key)?;
                let current = child_progress_fingerprint(state, route_id, &blocker.blocker_class);
                (previous == &current)
                    .then(|| (index, blocker.blocker_class.clone(), route_id.to_string()))
            });
        if let Some((index, blocker_class, route_id)) = no_progress {
            state.blockers.remove(index);
            state.blockers.push(ProgramBlocker {
                blocker_class: "recovery-integrity-risk".to_string(),
                message: format!(
                    "child route {route_id} already completed without changing progress for blocker {blocker_class}; same child/route/blocker will not be retried automatically"
                ),
                recovery_route: None,
            });
        }
    }
}

fn apply_recovery_approval_blockers(
    program: &ProgramSpec,
    registry_digest: &str,
    child_states: &mut BTreeMap<String, ProgramChildPlanState>,
    approvals: Option<&Vec<ProgramApprovalGrant>>,
    invocation_authority: &str,
) {
    for state in child_states.values_mut() {
        let blockers = state.blockers.clone();
        for blocker in blockers {
            if matches!(
                blocker.blocker_class.as_str(),
                "authority-ambiguity" | "policy-override"
            ) || blocker_non_recoverable(&blocker.blocker_class)
                || !recovery_requires_approval(program, &blocker.blocker_class)
            {
                continue;
            }
            if invocation_authority == "unattended"
                && recovery_delegation_contract_basis(Some(program), &blocker.blocker_class)
                    .is_some()
            {
                continue;
            }
            let Some(route_id) = recovery_route_for_blocker(program, &blocker) else {
                continue;
            };
            if approval_granted(
                approvals,
                &state.child_id,
                route_id,
                Some(registry_digest),
                Some(&blocker.blocker_class),
            ) {
                continue;
            }
            if state.blockers.iter().any(|existing| {
                matches!(existing.blocker_class.as_str(), "authority-ambiguity")
                    && existing.recovery_route.as_deref() == Some(route_id)
            }) {
                continue;
            }
            state.blockers.push(ProgramBlocker {
                blocker_class: "authority-ambiguity".to_string(),
                message: format!(
                    "recovery for {} requires program approval before route {} may execute",
                    blocker.blocker_class, route_id
                ),
                recovery_route: Some(route_id.to_string()),
            });
        }
    }
}

fn apply_recovery_dependent_handling(
    program: &ProgramSpec,
    registry: &ProgramChildRegistry,
    child_states: &mut BTreeMap<String, ProgramChildPlanState>,
    program_blockers: &mut Vec<ProgramBlocker>,
) {
    let mut additions: Vec<(String, ProgramBlocker)> = Vec::new();
    for state in child_states.values() {
        for blocker in state.blockers.iter().filter(|blocker| {
            !matches!(
                blocker.blocker_class.as_str(),
                "authority-ambiguity" | "policy-override"
            )
        }) {
            let Some(handling) = recovery_dependent_handling(program, &blocker.blocker_class)
            else {
                continue;
            };
            match handling.as_str() {
                "continue-independent" => {}
                "block-dependents" | "pause-dependent" => {
                    for dependent in registry
                        .children
                        .iter()
                        .filter(|child| child.dependencies.iter().any(|dep| dep == &state.child_id))
                    {
                        if dependent.child_id == state.child_id {
                            continue;
                        }
                        if dependent_dependency_gate_is_satisfied(
                            child_states,
                            &dependent.child_id,
                            &state.child_id,
                        ) {
                            continue;
                        }
                        additions.push((
                            dependent.child_id.clone(),
                            ProgramBlocker {
                                blocker_class: "scheduler-paused".to_string(),
                                message: format!(
                                    "dependent child paused while {} recovers from {}",
                                    state.child_id, blocker.blocker_class
                                ),
                                recovery_route: None,
                            },
                        ));
                    }
                }
                "pause-phase" => {
                    let phase = state.phase_id.as_ref().or(state.group_id.as_ref());
                    for child in registry.children.iter().filter(|child| {
                        child.child_id != state.child_id
                            && child.phase_id.as_ref().or(child.group_id.as_ref()) == phase
                    }) {
                        additions.push((
                            child.child_id.clone(),
                            ProgramBlocker {
                                blocker_class: "scheduler-paused".to_string(),
                                message: format!(
                                    "phase paused while {} recovers from {}",
                                    state.child_id, blocker.blocker_class
                                ),
                                recovery_route: None,
                            },
                        ));
                    }
                }
                "pause-barrier" => {
                    program_blockers.push(ProgramBlocker {
                        blocker_class: "scheduler-paused".to_string(),
                        message: format!(
                            "program barrier paused while {} recovers from {}",
                            state.child_id, blocker.blocker_class
                        ),
                        recovery_route: None,
                    });
                }
                "fail-closed" => {
                    additions.push((
                        state.child_id.clone(),
                        ProgramBlocker {
                            blocker_class: "unsafe-resume".to_string(),
                            message: format!(
                                "recovery dependent handling fail-closed for {}",
                                blocker.blocker_class
                            ),
                            recovery_route: None,
                        },
                    ));
                }
                _ => {}
            }
        }
    }
    for (child_id, blocker) in additions {
        if let Some(state) = child_states.get_mut(&child_id) {
            if !state.blockers.iter().any(|existing| {
                existing.blocker_class == blocker.blocker_class
                    && existing.message == blocker.message
                    && existing.recovery_route == blocker.recovery_route
            }) {
                state.blockers.push(blocker);
            }
        }
    }
}

fn dependent_dependency_gate_is_satisfied(
    child_states: &BTreeMap<String, ProgramChildPlanState>,
    dependent_id: &str,
    dependency_id: &str,
) -> bool {
    child_states
        .get(dependent_id)
        .and_then(|state| state.dependency_gate_status.get(dependency_id))
        .map(|status| status.satisfied)
        .unwrap_or(false)
}

fn select_runnable_batch(
    program: &ProgramSpec,
    registry: &ProgramChildRegistry,
    child_states: &mut BTreeMap<String, ProgramChildPlanState>,
) -> Vec<String> {
    let mut candidates = match registry.execution_mode.as_str() {
        "sequential" => registry
            .children
            .iter()
            .filter_map(|child| {
                runnable_child(program, child_states, &child.child_id)
                    .then(|| child.child_id.clone())
            })
            .take(1)
            .collect::<Vec<_>>(),
        "gated-parallel" => gated_parallel_candidates(program, registry, child_states),
        "approval-gated" | "parallel-independent" | "program-atomic" => registry
            .children
            .iter()
            .filter_map(|child| {
                runnable_child(program, child_states, &child.child_id)
                    .then(|| child.child_id.clone())
            })
            .collect::<Vec<_>>(),
        _ => Vec::new(),
    };
    if registry.execution_mode != "sequential" && registry.execution_mode != "program-atomic" {
        candidates = enforce_write_scope_independence(
            child_states,
            candidates,
            program.recovery_policy.serialize_write_scope_conflicts,
        );
    }
    candidates
}

fn runnable_child(
    program: &ProgramSpec,
    child_states: &BTreeMap<String, ProgramChildPlanState>,
    child_id: &str,
) -> bool {
    child_states
        .get(child_id)
        .map(|state| {
            let has_executable_route = state.selected_route.is_some()
                || state
                    .blockers
                    .iter()
                    .any(|blocker| recovery_route_for_blocker(program, blocker).is_some());
            !state.deferred
                && state.required
                && state.terminal_outcome.is_none()
                && has_executable_route
                && state
                    .blockers
                    .iter()
                    .all(|blocker| blocker_allows_child_route(program, blocker))
        })
        .unwrap_or(false)
}

fn blocker_allows_child_route(program: &ProgramSpec, blocker: &ProgramBlocker) -> bool {
    let has_route =
        blocker.recovery_route.is_some() || recovery_route_for_blocker(program, blocker).is_some();
    has_route && blocker_is_agent_routable(program, blocker)
}

fn blocker_is_agent_routable(program: &ProgramSpec, blocker: &ProgramBlocker) -> bool {
    classify_program_blocker_class(&blocker.blocker_class) == ProgramBlockerDisposition::Recoverable
        || blocker_has_safe_agent_repair(program, blocker)
}

fn blocker_has_safe_agent_repair(program: &ProgramSpec, blocker: &ProgramBlocker) -> bool {
    classify_program_blocker_class(&blocker.blocker_class) == ProgramBlockerDisposition::Unsafe
        && recovery_route_for_blocker(program, blocker).is_some()
        && recovery_delegation_contract_basis(Some(program), &blocker.blocker_class).is_some()
}

fn program_blocker_has_safe_agent_repair(
    contract: &LifecycleContract,
    program: &ProgramSpec,
    blocker: &ProgramBlocker,
) -> bool {
    classify_program_blocker_class(&blocker.blocker_class) == ProgramBlockerDisposition::Unsafe
        && selected_program_repair_route(contract, program, blocker)
            .and_then(|route| {
                validate_program_recovery_recipe(contract, program, blocker, &route)
                    .ok()
                    .map(|validation| validation.delegation_contract_basis)
            })
            .flatten()
            .is_some()
}

fn program_blocker_has_declared_safe_agent_repair(
    program: &ProgramSpec,
    blocker: &ProgramBlocker,
) -> bool {
    classify_program_blocker_class(&blocker.blocker_class) == ProgramBlockerDisposition::Unsafe
        && recovery_route_for_blocker(program, blocker).is_some()
        && program_repair_delegation_contract_basis(program, &blocker.blocker_class).is_some()
}

fn selected_program_repair_route(
    contract: &LifecycleContract,
    program: &ProgramSpec,
    blocker: &ProgramBlocker,
) -> Option<RoutePlanState> {
    let route_id = recovery_route_for_blocker(program, blocker)?;
    route_by_id(contract, route_id)
        .cloned()
        .map(route_plan_state)
}

fn selected_program_repair_blocker_with_validation(
    contract: &LifecycleContract,
    program: &ProgramSpec,
    blockers: &[ProgramBlocker],
) -> ProgramRepairSelectionResult {
    let mut first_failure = None;
    for blocker in blockers.iter().filter(|blocker| {
        classify_program_blocker_class(&blocker.blocker_class) == ProgramBlockerDisposition::Unsafe
    }) {
        let route_id = recovery_route_for_blocker(program, blocker);
        let Some(route) = selected_program_repair_route(contract, program, blocker) else {
            if route_id.is_some() {
                first_failure.get_or_insert_with(|| {
                    ProgramRecoveryRecipeValidationEvidence::failed(
                        &blocker.blocker_class,
                        route_id,
                        vec![format!(
                            "program recovery route {} is missing from program lifecycle contract",
                            route_id.unwrap_or("unknown")
                        )],
                    )
                });
            }
            continue;
        };
        match validate_program_recovery_recipe(contract, program, blocker, &route) {
            Ok(validation) => {
                if validation.delegation_contract_basis.is_none() {
                    first_failure.get_or_insert_with(|| {
                        ProgramRecoveryRecipeValidationEvidence::failed(
                            &blocker.blocker_class,
                            Some(&route.route_id),
                            vec![
                                "program recovery validation passed without safe unattended basis"
                                    .to_string(),
                            ],
                        )
                    });
                    continue;
                }
                return ProgramRepairSelectionResult {
                    selection: Some(ProgramRepairSelection { route, validation }),
                    validation: None,
                };
            }
            Err(error) => {
                first_failure.get_or_insert_with(|| {
                    ProgramRecoveryRecipeValidationEvidence::failed(
                        &blocker.blocker_class,
                        Some(&route.route_id),
                        vec![error.to_string()],
                    )
                });
            }
        }
    }
    ProgramRepairSelectionResult {
        selection: None,
        validation: first_failure,
    }
}

fn selected_program_recoverable_route(
    contract: &LifecycleContract,
    program: &ProgramSpec,
    blockers: &[ProgramBlocker],
) -> Option<RoutePlanState> {
    for blocker in blockers.iter().filter(|blocker| {
        classify_program_blocker_class(&blocker.blocker_class)
            == ProgramBlockerDisposition::Recoverable
            && !declared_wait_blocker(&blocker.blocker_class)
    }) {
        let Some(route_id) = recovery_route_for_blocker(program, blocker) else {
            continue;
        };
        let Some(recipe) = recovery_recipe_for_blocker(program, &blocker.blocker_class) else {
            continue;
        };
        if validate_recovery_recipe_metadata(recipe, &blocker.blocker_class, false).is_err() {
            continue;
        }
        if recovery_requires_approval(program, &blocker.blocker_class) {
            continue;
        }
        if let Some(route) = route_by_id(contract, route_id) {
            return Some(route_plan_state(route.clone()));
        }
    }
    None
}

fn program_repair_delegation_contract_basis(
    program: &ProgramSpec,
    blocker_class: &str,
) -> Option<String> {
    recovery_delegation_contract_basis(Some(program), blocker_class)
}

fn gated_parallel_candidates(
    program: &ProgramSpec,
    registry: &ProgramChildRegistry,
    child_states: &BTreeMap<String, ProgramChildPlanState>,
) -> Vec<String> {
    let mut phases = Vec::new();
    for child in &registry.children {
        let phase = child_phase_key(child);
        if !phases.iter().any(|existing| existing == &phase) {
            phases.push(phase);
        }
    }
    for phase in phases {
        let candidates = registry
            .children
            .iter()
            .filter(|child| child_phase_key(child) == phase)
            .filter_map(|child| {
                runnable_child(program, child_states, &child.child_id)
                    .then(|| child.child_id.clone())
            })
            .collect::<Vec<_>>();
        if !candidates.is_empty() {
            return candidates;
        }
    }
    Vec::new()
}

fn child_phase_key(child: &ProgramChildSpec) -> String {
    child
        .phase_id
        .clone()
        .or_else(|| child.group_id.clone())
        .unwrap_or_else(|| "default".to_string())
}

fn enforce_write_scope_independence(
    child_states: &mut BTreeMap<String, ProgramChildPlanState>,
    candidates: Vec<String>,
    serialize_conflicts: bool,
) -> Vec<String> {
    let mut selected = Vec::new();
    let mut selected_scopes: Vec<(String, Vec<String>)> = Vec::new();
    for child_id in candidates {
        let scopes = child_states
            .get(&child_id)
            .map(|state| state.write_scopes.clone())
            .unwrap_or_default();
        let conflict = selected_scopes.iter().find(|(_, existing)| {
            scopes
                .iter()
                .any(|scope| existing.iter().any(|other| scopes_overlap(scope, other)))
        });
        if let Some((other_child, _)) = conflict {
            if serialize_conflicts {
                if let Some(state) = child_states.get_mut(&child_id) {
                    state.blockers.push(ProgramBlocker {
                        blocker_class: "write-scope-serialization-required".to_string(),
                        message: format!(
                            "write scope overlaps with runnable child {other_child}; serialized by scheduler"
                        ),
                        recovery_route: None,
                    });
                }
                continue;
            }
            if let Some(state) = child_states.get_mut(&child_id) {
                state.blockers.push(ProgramBlocker {
                    blocker_class: "atomic-write-scope-conflict".to_string(),
                    message: format!("write scope overlaps with runnable child {other_child}"),
                    recovery_route: None,
                });
            }
        } else {
            selected_scopes.push((child_id.clone(), scopes));
            selected.push(child_id);
        }
    }
    selected
}

fn scopes_overlap(left: &str, right: &str) -> bool {
    left == right
        || left
            .strip_prefix(right)
            .map(|tail| tail.starts_with('/'))
            .unwrap_or(false)
        || right
            .strip_prefix(left)
            .map(|tail| tail.starts_with('/'))
            .unwrap_or(false)
}

fn collect_approval_blockers(
    octon_dir: &Path,
    program: &ProgramSpec,
    registry_digest: &str,
    child_states: &BTreeMap<String, ProgramChildPlanState>,
    approvals: Option<&Vec<ProgramApprovalGrant>>,
    invocation_authority: &str,
) -> Result<Vec<ProgramApprovalBlocker>> {
    let mut blockers = Vec::new();
    let repo_root = repo_root_for_octon(octon_dir)?;
    for state in child_states.values() {
        if let Some(route) = state.selected_route.as_ref() {
            let loaded = load_lifecycle_contract(octon_dir, &state.child_lifecycle_id)?;
            if let Some(route_spec) = route_by_id(&loaded.contract, &route.route_id) {
                let authority_decision = child_route_authority_decision(
                    &repo_root,
                    "planning",
                    state,
                    &route.route_id,
                    OPERATION_CLASS_EXECUTE_CHILD_ROUTE,
                );
                let required = route_spec_delegation_contract_basis(&route.route_id, route_spec)
                    .is_none()
                    || matches!(
                        authority_decision.authority_zone.as_str(),
                        AUTHORITY_ZONE_AUTHORED_GOVERNANCE | AUTHORITY_ZONE_PROTECTED_OR_EXTERNAL
                    );
                let route_approval_granted = approval_granted_for_authority_decision(
                    approvals,
                    &state.child_id,
                    &route.route_id,
                    Some(registry_digest),
                    None,
                    &authority_decision,
                );
                if required && !route_approval_granted {
                    if invocation_authority == "unattended"
                        && child_route_delegation_contract_basis(
                            &repo_root,
                            program,
                            state,
                            &route.route_id,
                            route_spec,
                        )
                        .is_some()
                    {
                        continue;
                    }
                    blockers.push(ProgramApprovalBlocker {
                        child_id: state.child_id.clone(),
                        route_id: route.route_id.clone(),
                        blocker_class: Some("authority-ambiguity".to_string()),
                        reason: "child route lacks a machine-provable delegation contract or targets a protected authority zone".to_string(),
                    });
                }
            }
        }
        for blocker in state.blockers.iter().filter(|blocker| {
            !matches!(
                blocker.blocker_class.as_str(),
                "authority-ambiguity" | "policy-override"
            )
        }) {
            if !recovery_requires_approval(program, &blocker.blocker_class) {
                continue;
            }
            let Some(recovery_route) = recovery_route_for_blocker(program, blocker) else {
                continue;
            };
            let authority_decision = child_route_authority_decision(
                &repo_root,
                "planning",
                state,
                recovery_route,
                OPERATION_CLASS_RETRY_CHILD_ROUTE,
            );
            if approval_granted_for_authority_decision(
                approvals,
                &state.child_id,
                recovery_route,
                Some(registry_digest),
                Some(&blocker.blocker_class),
                &authority_decision,
            ) {
                continue;
            }
            if invocation_authority == "unattended"
                && recovery_delegation_contract_basis(Some(program), &blocker.blocker_class)
                    .is_some()
                && authority_decision_allows_route_unattended(&authority_decision)
            {
                continue;
            }
            blockers.push(ProgramApprovalBlocker {
                child_id: state.child_id.clone(),
                route_id: recovery_route.to_string(),
                reason: format!(
                    "recovery for {} requires program approval",
                    blocker.blocker_class
                ),
                blocker_class: Some(blocker.blocker_class.clone()),
            });
        }
    }
    Ok(blockers)
}

fn receipt_complete_and_not_stale(receipt: Option<&ReceiptPlanState>) -> bool {
    receipt
        .map(|receipt| {
            receipt.exists
                && receipt.missing_required_fields.is_empty()
                && receipt.stale != Some(true)
        })
        .unwrap_or(false)
}

fn receipt_verdict_eq(
    receipts: &BTreeMap<String, ReceiptPlanState>,
    receipt_id: &str,
    expected: &str,
) -> bool {
    receipts
        .get(receipt_id)
        .map(|receipt| {
            receipt_complete_and_not_stale(Some(receipt))
                && receipt.verdict.as_deref() == Some(expected)
        })
        .unwrap_or(false)
}

fn receipt_field_eq(
    receipts: &BTreeMap<String, ReceiptPlanState>,
    receipt_id: &str,
    field: &str,
    expected: &str,
) -> bool {
    receipts
        .get(receipt_id)
        .map(|receipt| {
            receipt_complete_and_not_stale(Some(receipt))
                && receipt.fields.get(field).map(String::as_str) == Some(expected)
        })
        .unwrap_or(false)
}

fn child_promotion_evidence_ready(state: &ProgramChildPlanState) -> bool {
    state.gate_status.verification && state.blockers.is_empty()
}

fn parent_promotion_evidence_ready(plan: &ProgramLifecyclePlanResult) -> bool {
    plan.parent_manifest_status.as_deref() == Some("accepted")
        && plan.blocked_by_program_gate.is_none()
        && !plan.program_gate_results.is_empty()
        && plan.program_gate_results.iter().all(|gate| gate.passed)
        && receipt_verdict_eq(
            &plan.parent_receipt_states,
            RECEIPT_ID_PROPOSAL_REVIEW,
            "accepted",
        )
        && receipt_complete_and_not_stale(
            plan.parent_receipt_states
                .get(RECEIPT_ID_PROGRAM_IMPLEMENTATION_PROMPT),
        )
        && receipt_verdict_eq(
            &plan.parent_receipt_states,
            RECEIPT_ID_IMPLEMENTATION_RUN,
            "pass",
        )
        && receipt_field_eq(
            &plan.parent_receipt_states,
            RECEIPT_ID_IMPLEMENTATION_RUN,
            FIELD_CHILD_AUTHORITY_PRESERVED,
            "yes",
        )
}

fn parent_route_delegation_contract_basis(
    octon_dir: &Path,
    plan: &ProgramLifecyclePlanResult,
    route: &RoutePlanState,
) -> Result<Option<String>> {
    let Some(basis) =
        lifecycle_route_delegation_contract_basis(octon_dir, &plan.lifecycle_id, &route.route_id)?
    else {
        return Ok(None);
    };
    if route.route_id != ROUTE_ID_PROMOTE_PROPOSAL {
        return Ok(Some(basis));
    }
    if !parent_promotion_evidence_ready(plan) {
        return Ok(None);
    }
    Ok(Some(format!(
        "{basis}; parent promotion evidence=accepted-review+passing-gates+implementation-run-pass+child_authority_preserved"
    )))
}

fn child_route_delegation_contract_basis(
    repo_root: &Path,
    _program: &ProgramSpec,
    state: &ProgramChildPlanState,
    route_id: &str,
    route: &RouteSpec,
) -> Option<String> {
    let basis = route_spec_delegation_contract_basis(route_id, route)?;
    let authority_decision = child_route_authority_decision(
        repo_root,
        "planning",
        state,
        route_id,
        OPERATION_CLASS_EXECUTE_CHILD_ROUTE,
    );
    if route_id == ROUTE_ID_PROMOTE_PROPOSAL {
        return (child_promotion_evidence_ready(state)
            && authority_decision.authority_zone == AUTHORITY_ZONE_WORKSPACE_DECLARED
            && authority_decision.workspace_contained
            && authority_decision.declared_scope_contained)
            .then(|| {
                format!(
                    "{basis}; child promotion evidence=implementation-run-pass+implementation-conformance-pass+post-implementation-drift-pass; authority_zone={}; artifact_class={}",
                    authority_decision.authority_zone, authority_decision.artifact_class
                )
            });
    }
    authority_decision_allows_route_unattended(&authority_decision).then(|| {
        format!(
            "{basis}; authority_zone={}; artifact_class={}",
            authority_decision.authority_zone, authority_decision.artifact_class
        )
    })
}

fn lifecycle_route_delegation_contract_basis_for_child(
    octon_dir: &Path,
    program: &ProgramSpec,
    state: &ProgramChildPlanState,
    route_id: &str,
) -> Result<Option<String>> {
    let loaded = load_lifecycle_contract(octon_dir, &state.child_lifecycle_id)?;
    let repo_root = repo_root_for_octon(octon_dir)?;
    Ok(route_by_id(&loaded.contract, route_id).and_then(|route| {
        child_route_delegation_contract_basis(&repo_root, program, state, route_id, route)
    }))
}

fn approval_granted(
    approvals: Option<&Vec<ProgramApprovalGrant>>,
    child_id: &str,
    route_id: &str,
    registry_digest: Option<&str>,
    blocker_class: Option<&str>,
) -> bool {
    approvals
        .map(|approvals| {
            approvals.iter().any(|grant| {
                grant.child_id == child_id
                    && grant.route_id == route_id
                    && registry_digest
                        .map(|digest| {
                            grant
                                .registry_digest
                                .as_deref()
                                .map(|grant_digest| grant_digest == digest)
                                .unwrap_or(true)
                        })
                        .unwrap_or(true)
                    && blocker_class
                        .map(|class| {
                            grant
                                .blocker_class
                                .as_deref()
                                .map(|grant_class| grant_class == class)
                                .unwrap_or(true)
                        })
                        .unwrap_or(true)
            })
        })
        .unwrap_or(false)
}

fn authority_grant_requires_zone_binding(decision: &AuthorityZoneDecision) -> bool {
    matches!(
        decision.authority_zone.as_str(),
        AUTHORITY_ZONE_AUTHORED_GOVERNANCE
            | AUTHORITY_ZONE_WORKSPACE_DECLARED
            | AUTHORITY_ZONE_PROTECTED_OR_EXTERNAL
    ) || matches!(
        decision.artifact_class.as_str(),
        ARTIFACT_CLASS_AUTHORED_GOVERNANCE
            | ARTIFACT_CLASS_WORKSPACE_SOURCE
            | ARTIFACT_CLASS_PROTECTED_OR_EXTERNAL
            | ARTIFACT_CLASS_UNKNOWN
    )
}

fn approval_granted_for_authority_decision(
    approvals: Option<&Vec<ProgramApprovalGrant>>,
    child_id: &str,
    route_id: &str,
    registry_digest: Option<&str>,
    blocker_class: Option<&str>,
    decision: &AuthorityZoneDecision,
) -> bool {
    approvals
        .map(|approvals| {
            approvals.iter().any(|grant| {
                if grant.child_id != child_id || grant.route_id != route_id {
                    return false;
                }
                if registry_digest
                    .map(|digest| {
                        grant
                            .registry_digest
                            .as_deref()
                            .map(|grant_digest| grant_digest == digest)
                            .unwrap_or(true)
                    })
                    .unwrap_or(true)
                    == false
                {
                    return false;
                }
                if blocker_class
                    .map(|class| {
                        grant
                            .blocker_class
                            .as_deref()
                            .map(|grant_class| grant_class == class)
                            .unwrap_or(true)
                    })
                    .unwrap_or(true)
                    == false
                {
                    return false;
                }
                if authority_grant_requires_zone_binding(decision) {
                    return grant.authority_zone.as_deref()
                        == Some(decision.authority_zone.as_str())
                        && grant.operation_class.as_deref()
                            == Some(decision.operation_class.as_str())
                        && grant.artifact_class.as_deref()
                            == Some(decision.artifact_class.as_str())
                        && grant.write_scope_digest.as_deref()
                            == decision.write_scope_digest.as_deref();
                }
                true
            })
        })
        .unwrap_or(false)
}

fn invocation_authority_for_child_route(
    default_policy: &str,
    approvals: Option<&Vec<ProgramApprovalGrant>>,
    child_id: &str,
    route_id: &str,
    registry_digest: Option<&str>,
    blocker_class: Option<&str>,
    delegation_safe: bool,
    authority_decision: Option<&AuthorityZoneDecision>,
) -> String {
    let grant_bound = authority_decision
        .map(|decision| {
            approval_granted_for_authority_decision(
                approvals,
                child_id,
                route_id,
                registry_digest,
                blocker_class,
                decision,
            )
        })
        .unwrap_or_else(|| {
            approval_granted(
                approvals,
                child_id,
                route_id,
                registry_digest,
                blocker_class,
            )
        });
    if default_policy == "unattended" {
        if delegation_safe {
            "unattended".to_string()
        } else if grant_bound {
            "grant-consumption".to_string()
        } else {
            "unattended".to_string()
        }
    } else if grant_bound {
        "grant-consumption".to_string()
    } else {
        default_policy.to_string()
    }
}

fn write_program_approval_execution_evidence(
    repo_root: &Path,
    child_evidence_root: &Path,
    program_run_id: &str,
    child_id: &str,
    route_id: &str,
    registry_digest: Option<&str>,
    blocker_class: Option<&str>,
    approvals: Option<&Vec<ProgramApprovalGrant>>,
) -> Result<()> {
    let grant = approvals
        .and_then(|approvals| {
            approvals.iter().rev().find(|grant| {
                grant.child_id == child_id
                    && grant.route_id == route_id
                    && registry_digest
                        .map(|digest| {
                            grant
                                .registry_digest
                                .as_deref()
                                .map(|grant_digest| grant_digest == digest)
                                .unwrap_or(true)
                        })
                        .unwrap_or(true)
                    && blocker_class
                        .map(|class| {
                            grant
                                .blocker_class
                                .as_deref()
                                .map(|grant_class| grant_class == class)
                                .unwrap_or(true)
                        })
                        .unwrap_or(true)
            })
        })
        .with_context(|| {
            format!("missing typed human exception grant for child route {child_id}:{route_id}")
        })?;
    fs::create_dir_all(child_evidence_root)?;
    let path = child_evidence_root.join(format!("{route_id}-grant-consumption.yml"));
    fs::write(
        path,
        format!(
            "schema_version: octon-program-lifecycle-grant-consumption-v1\nprogram_run_id: {program_run_id}\nchild_id: {child_id}\nroute_id: {route_id}\nblocker_class: {}\nregistry_digest: {}\nhuman_exception_grant_ref: {}\nhuman_exception_reason: {}\nrecorded_at: {}\nauthorization_source: typed-human-exception-grant\n",
            grant.blocker_class.as_deref().unwrap_or("route-approval"),
            grant.registry_digest.as_deref().unwrap_or("legacy-grant"),
            grant.evidence_path,
            grant.reason,
            now_rfc3339()?
        ),
    )?;
    let _ = repo_root;
    Ok(())
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
enum ProgramBlockerDisposition {
    Recoverable,
    Human,
    Unsafe,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
enum ProgramNormalizedCategory {
    Recoverable,
    Human,
    Unsafe,
    Budget,
    Timeout,
    Cancellation,
    Terminal,
}

impl ProgramNormalizedCategory {
    fn as_str(self) -> &'static str {
        match self {
            ProgramNormalizedCategory::Recoverable => "recoverable",
            ProgramNormalizedCategory::Human => "human",
            ProgramNormalizedCategory::Unsafe => "unsafe",
            ProgramNormalizedCategory::Budget => "budget",
            ProgramNormalizedCategory::Timeout => "timeout",
            ProgramNormalizedCategory::Cancellation => "cancellation",
            ProgramNormalizedCategory::Terminal => "terminal",
        }
    }

    fn disposition(self) -> &'static str {
        match self {
            ProgramNormalizedCategory::Recoverable => "autonomous/recoverable",
            ProgramNormalizedCategory::Human => "human-required",
            ProgramNormalizedCategory::Unsafe => "unsafe-route/fail-closed",
            ProgramNormalizedCategory::Budget => "budget",
            ProgramNormalizedCategory::Timeout => "timeout",
            ProgramNormalizedCategory::Cancellation => "cancellation",
            ProgramNormalizedCategory::Terminal => "terminal",
        }
    }
}

struct ProgramBlockerNormalization {
    normalized_blocker_class: String,
    normalized_category: ProgramNormalizedCategory,
    legacy_class: Option<String>,
    autonomy_basis: String,
}

fn classify_program_blocker_class(blocker_class: &str) -> ProgramBlockerDisposition {
    match normalize_program_blocker_class(blocker_class).normalized_category {
        ProgramNormalizedCategory::Recoverable
        | ProgramNormalizedCategory::Budget
        | ProgramNormalizedCategory::Timeout
        | ProgramNormalizedCategory::Cancellation
        | ProgramNormalizedCategory::Terminal => ProgramBlockerDisposition::Recoverable,
        ProgramNormalizedCategory::Human => ProgramBlockerDisposition::Human,
        ProgramNormalizedCategory::Unsafe => ProgramBlockerDisposition::Unsafe,
    }
}

fn normalize_program_blocker_class(blocker_class: &str) -> ProgramBlockerNormalization {
    let (normalized_blocker_class, normalized_category, autonomy_basis) = match blocker_class {
        "policy-override" => (
            "policy-override",
            ProgramNormalizedCategory::Recoverable,
            "route or recovery is machine-delegable by contract",
        ),
        "authority-ambiguity" => (
            "authority-ambiguity",
            ProgramNormalizedCategory::Human,
            "route or recovery is blocked at a human-only boundary",
        ),
        "unsupported-mode-config" => (
            "unsupported-mode-config",
            ProgramNormalizedCategory::Human,
            "unsupported mode configuration lacks an authorized normalization route",
        ),
        "unsupported-mode" | "unsupported-mode-authority" => (
            "unsupported-mode-authority",
            ProgramNormalizedCategory::Unsafe,
            "runtime cannot safely interpret authority, write scope, execution semantics, or rollback guarantees",
        ),
        "write-scope-serialization-required" => (
            "write-scope-serialization-required",
            ProgramNormalizedCategory::Recoverable,
            "write-scope conflict can be handled by serializing safe child execution",
        ),
        "write-scope-conflict" | "atomic-write-scope-conflict" => (
            "atomic-write-scope-conflict",
            ProgramNormalizedCategory::Unsafe,
            "conflicting atomic write scope has no safe serialization route",
        ),
        "dependency-blocked" | "dependency-gate-unsatisfied" => (
            "dependency-gate-unsatisfied",
            ProgramNormalizedCategory::Recoverable,
            "dependency gate has not yet been satisfied and may advance through normal lifecycle routes",
        ),
        "scheduler-paused" => (
            "scheduler-paused",
            ProgramNormalizedCategory::Recoverable,
            "scheduler intentionally paused dependent work while recovery proceeds",
        ),
        "deferred" => (
            "deferred",
            ProgramNormalizedCategory::Recoverable,
            "child is explicitly deferred and is non-blocking for required-child completion",
        ),
        "target-drift-explained" => (
            "target-drift-explained",
            ProgramNormalizedCategory::Recoverable,
            "local evidence explains target or receipt drift",
        ),
        "target-drift" | "target-drift-unclear" => (
            "target-drift-unclear",
            ProgramNormalizedCategory::Human,
            "target drift cause, ownership, or authority is unclear",
        ),
        "noncritical-artifact-cleanup"
        | "child-lock-stale"
        | "generated-scratch-stale"
        | "local-run-residue" => (
            "noncritical-artifact-cleanup",
            ProgramNormalizedCategory::Recoverable,
            "artifact is generated, temporary, stale, reproducible, superseded, or current-run-owned",
        ),
        "artifact-cleanup-required" | "critical-artifact-cleanup-required" => (
            "critical-artifact-cleanup-required",
            ProgramNormalizedCategory::Human,
            "cleanup touches critical or authority-sensitive artifacts",
        ),
        "worktree-hygiene-blocked" | "artifact-ownership-unclear" => (
            "artifact-ownership-unclear",
            ProgramNormalizedCategory::Human,
            "artifact ownership or criticality is unclear and must not be guessed",
        ),
        BLOCKER_LIFECYCLE_RESIDUE_CLEANUP_NEEDED => (
            BLOCKER_LIFECYCLE_RESIDUE_CLEANUP_NEEDED,
            ProgramNormalizedCategory::Recoverable,
            "dedicated cleanup route may classify safe residue while preserving ambiguous or foreign artifacts",
        ),
        "executor-timed-out" => (
            "executor-timed-out",
            ProgramNormalizedCategory::Recoverable,
            "executor timeout may recover through a safe alternate route or retry budget",
        ),
        "executor-preflight-blocked" => (
            "executor-preflight-blocked",
            ProgramNormalizedCategory::Human,
            "executor preflight requires access, credentials, or execution authority not already granted",
        ),
        "step-budget-exhausted-continuable" => (
            "step-budget-exhausted-continuable",
            ProgramNormalizedCategory::Budget,
            "caller-provided step budget was exhausted while safe continuation evidence remains",
        ),
        "executor-failed"
        | "failed"
        | "implementation-blocked"
        | "missing-evidence"
        | "missing-required-evidence"
        | "missing-route-evidence"
        | "publication-drift"
        | "stale-receipt"
        | "validation-failed" => (
            blocker_class,
            ProgramNormalizedCategory::Recoverable,
            "routine validation, evidence, receipt, or execution failure is agent-diagnosable",
        ),
        "recovery-budget-exhausted-alternate-route" => (
            "recovery-budget-exhausted-alternate-route",
            ProgramNormalizedCategory::Recoverable,
            "one recovery route exhausted but another safe route remains available",
        ),
        "recovery-budget-override-required" => (
            "recovery-budget-override-required",
            ProgramNormalizedCategory::Human,
            "remaining recovery requires retry-budget override, judgment, scope expansion, or broader authority",
        ),
        "recovery-route-unavailable" => (
            "recovery-route-unavailable",
            ProgramNormalizedCategory::Human,
            "recoverable blocker has no executable route, action, or declared wait condition",
        ),
        "receipt-recovery-unavailable" => (
            "receipt-recovery-unavailable",
            ProgramNormalizedCategory::Human,
            "child-owned receipt repair has no enterable child-owned route",
        ),
        "finding-binding-unavailable" => (
            "finding-binding-unavailable",
            ProgramNormalizedCategory::Human,
            "correction route requires a finding_id that cannot be derived from runtime evidence",
        ),
        "deferred-evidence-missing" => (
            "deferred-evidence-missing",
            ProgramNormalizedCategory::Human,
            "deferred, superseded, replaced, or rejected child lacks explicit registry evidence",
        ),
        "aggregate-closeout-readiness-missing" => (
            "aggregate-closeout-readiness-missing",
            ProgramNormalizedCategory::Human,
            "aggregate clean finish lacks required child-owned receipts, authority evidence, or aggregate evidence",
        ),
        "authority-zone-denied" => (
            "authority-zone-denied",
            ProgramNormalizedCategory::Human,
            "selected route or action is outside the authority zones allowed by contract",
        ),
        "scope-expansion" => (
            "scope-expansion",
            ProgramNormalizedCategory::Human,
            "mutation would expand the declared scope or authority zone without a typed human exception grant",
        ),
        "recovery-integrity-risk" => (
            "recovery-integrity-risk",
            ProgramNormalizedCategory::Unsafe,
            "repeated recovery attempts indicate possible integrity risk",
        ),
        "authority-zone-ambiguous" | "self-authorization-attempt" => (
            blocker_class,
            ProgramNormalizedCategory::Unsafe,
            "authority zone, ownership, or authorization basis is ambiguous or self-produced",
        ),
        "authority-boundary-ambiguous" | "unsafe-resume" => (
            blocker_class,
            ProgramNormalizedCategory::Unsafe,
            "authority, ownership, or resume safety is ambiguous",
        ),
        _ => (
            blocker_class,
            ProgramNormalizedCategory::Unsafe,
            "unknown blocker class fails closed until taxonomy policy is explicit",
        ),
    };
    let legacy_class =
        (normalized_blocker_class != blocker_class).then(|| blocker_class.to_string());
    ProgramBlockerNormalization {
        normalized_blocker_class: normalized_blocker_class.to_string(),
        normalized_category,
        legacy_class,
        autonomy_basis: autonomy_basis.to_string(),
    }
}

fn normalize_program_state_value(value: &str) -> ProgramNormalizedCategory {
    match value {
        "completed" | "skipped-idempotent" | "no-op" => ProgramNormalizedCategory::Terminal,
        "cancelled" => ProgramNormalizedCategory::Cancellation,
        "blocked-max-steps"
        | "blocked-max-iterations"
        | "blocked-budget"
        | "step-budget-exhausted-continuable" => ProgramNormalizedCategory::Budget,
        "timed-out" => ProgramNormalizedCategory::Timeout,
        "blocked-unsafe" => ProgramNormalizedCategory::Unsafe,
        "blocked-human" => ProgramNormalizedCategory::Human,
        "blocked-recoverable"
        | "blocked-gate"
        | "blocked-no-route"
        | "failed"
        | "blocked"
        | "partial"
        | "planned"
        | "route-ready"
        | "parent-route-ready" => ProgramNormalizedCategory::Recoverable,
        _ => ProgramNormalizedCategory::Unsafe,
    }
}

fn taxonomy_evidence_for_blocker(
    program: Option<&ProgramSpec>,
    blocker: &ProgramBlocker,
) -> ProgramTaxonomyEvidence {
    taxonomy_evidence_for_class(program, &blocker.blocker_class)
}

fn taxonomy_evidence_for_class(
    program: Option<&ProgramSpec>,
    blocker_class: &str,
) -> ProgramTaxonomyEvidence {
    let normalized = normalize_program_blocker_class(blocker_class);
    let delegation_contract_basis = recovery_delegation_contract_basis(program, blocker_class);
    ProgramTaxonomyEvidence {
        raw_value: blocker_class.to_string(),
        legacy_class: normalized.legacy_class,
        normalized_category: normalized.normalized_category.as_str().to_string(),
        normalized_blocker_class: normalized.normalized_blocker_class,
        disposition: normalized.normalized_category.disposition().to_string(),
        autonomy_basis: normalized.autonomy_basis,
        delegation_contract_basis,
    }
}

fn normalized_program_blockers(
    program: Option<&ProgramSpec>,
    blockers: &[ProgramBlocker],
) -> Vec<ProgramTaxonomyEvidence> {
    blockers
        .iter()
        .map(|blocker| taxonomy_evidence_for_blocker(program, blocker))
        .collect()
}

fn normalized_child_blockers(
    program: Option<&ProgramSpec>,
    child_states: &BTreeMap<String, ProgramChildPlanState>,
) -> BTreeMap<String, Vec<ProgramTaxonomyEvidence>> {
    child_states
        .iter()
        .filter_map(|(child_id, state)| {
            if state.blockers.is_empty() {
                None
            } else {
                Some((
                    child_id.clone(),
                    normalized_program_blockers(program, &state.blockers),
                ))
            }
        })
        .collect()
}

fn normalized_approval_blockers(
    approval_blockers: &[ProgramApprovalBlocker],
) -> Vec<ProgramTaxonomyEvidence> {
    approval_blockers
        .iter()
        .map(|blocker| {
            let raw_value = blocker
                .blocker_class
                .as_deref()
                .unwrap_or("route-approval")
                .to_string();
            let mut evidence = taxonomy_evidence_for_class(None, "authority-ambiguity");
            if raw_value != evidence.normalized_blocker_class {
                evidence.legacy_class = Some(raw_value.clone());
            }
            evidence.raw_value = raw_value;
            evidence
        })
        .collect()
}

fn collect_safe_repair_candidates(
    contract: &LifecycleContract,
    program: &ProgramSpec,
    program_blockers: &[ProgramBlocker],
    child_states: &BTreeMap<String, ProgramChildPlanState>,
) -> Vec<ProgramSafeRepairCandidate> {
    let mut candidates = Vec::new();
    for blocker in program_blockers {
        if let Some(route) = selected_program_repair_route(contract, program, blocker) {
            if let Ok(validation) =
                validate_program_recovery_recipe(contract, program, blocker, &route)
            {
                if let Some(basis) = validation.delegation_contract_basis {
                    candidates.push(ProgramSafeRepairCandidate {
                        scope: "program".to_string(),
                        child_id: None,
                        blocker_class: blocker.blocker_class.clone(),
                        selected_repair_route: route.route_id,
                        delegation_contract_basis: basis,
                    });
                }
            }
        }
    }
    for state in child_states.values() {
        for blocker in &state.blockers {
            if !blocker_has_safe_agent_repair(program, blocker) {
                continue;
            }
            let Some(route_id) = recovery_route_for_blocker(program, blocker) else {
                continue;
            };
            let Some(basis) =
                recovery_delegation_contract_basis(Some(program), &blocker.blocker_class)
            else {
                continue;
            };
            candidates.push(ProgramSafeRepairCandidate {
                scope: "child".to_string(),
                child_id: Some(state.child_id.clone()),
                blocker_class: blocker.blocker_class.clone(),
                selected_repair_route: route_id.to_string(),
                delegation_contract_basis: basis,
            });
        }
    }
    candidates
}

fn aggregate_program_state(
    program: &ProgramSpec,
    contract: Option<&LifecycleContract>,
    child_states: &BTreeMap<String, ProgramChildPlanState>,
    program_blockers: &[ProgramBlocker],
    approval_blockers: &[ProgramApprovalBlocker],
    runnable_batch: &[String],
) -> (String, String) {
    let program_safe_repair = |blocker: &ProgramBlocker| {
        contract
            .map(|contract| program_blocker_has_safe_agent_repair(contract, program, blocker))
            .unwrap_or_else(|| program_blocker_has_declared_safe_agent_repair(program, blocker))
    };
    if program_blockers.iter().any(|blocker| {
        classify_program_blocker_class(&blocker.blocker_class) == ProgramBlockerDisposition::Unsafe
            && !program_safe_repair(blocker)
    }) {
        return ("blocked-unsafe".to_string(), "blocked-unsafe".to_string());
    }
    if !approval_blockers.is_empty()
        || program_blockers.iter().any(|blocker| {
            classify_program_blocker_class(&blocker.blocker_class)
                == ProgramBlockerDisposition::Human
        })
    {
        return ("blocked-human".to_string(), "blocked-human".to_string());
    }
    if program_blockers.iter().any(|blocker| {
        classify_program_blocker_class(&blocker.blocker_class)
            == ProgramBlockerDisposition::Recoverable
            || program_safe_repair(blocker)
    }) {
        return (
            "blocked-recoverable".to_string(),
            "blocked-recoverable".to_string(),
        );
    }
    let required = child_states
        .values()
        .filter(|state| state.required && !state.deferred)
        .collect::<Vec<_>>();
    let blockers = required
        .iter()
        .flat_map(|state| state.blockers.iter())
        .collect::<Vec<_>>();
    if blockers.iter().any(|blocker| {
        classify_program_blocker_class(&blocker.blocker_class) == ProgramBlockerDisposition::Unsafe
            && !blocker_has_safe_agent_repair(program, blocker)
    }) {
        return ("blocked-unsafe".to_string(), "blocked-unsafe".to_string());
    }
    if blockers.iter().any(|blocker| {
        classify_program_blocker_class(&blocker.blocker_class) == ProgramBlockerDisposition::Human
    }) {
        return ("blocked-human".to_string(), "blocked-human".to_string());
    }
    if runnable_batch.is_empty()
        && blockers.iter().any(|blocker| {
            classify_program_blocker_class(&blocker.blocker_class)
                == ProgramBlockerDisposition::Recoverable
                || blocker_has_safe_agent_repair(program, blocker)
        })
    {
        return (
            "blocked-recoverable".to_string(),
            "blocked-recoverable".to_string(),
        );
    }
    if !required.is_empty()
        && required
            .iter()
            .all(|state| state.terminal_outcome.is_some())
    {
        return ("completed".to_string(), "completed".to_string());
    }
    if required
        .iter()
        .any(|state| state.terminal_outcome.is_some())
    {
        ("partial".to_string(), "partial".to_string())
    } else {
        ("planned".to_string(), "planned".to_string())
    }
}

fn scheduler_phase_for_batch(
    registry: &ProgramChildRegistry,
    runnable_batch: &[String],
) -> Option<String> {
    let first = runnable_batch.first()?;
    registry
        .children
        .iter()
        .find(|child| &child.child_id == first)
        .map(child_phase_key)
}

fn skipped_blocked_children(
    child_states: &BTreeMap<String, ProgramChildPlanState>,
    runnable_batch: &[String],
) -> Vec<String> {
    child_states
        .iter()
        .filter_map(|(child_id, state)| {
            let skipped = state.required
                && !state.deferred
                && state.terminal_outcome.is_none()
                && !state.blockers.is_empty()
                && !runnable_batch.iter().any(|id| id == child_id);
            skipped.then(|| child_id.clone())
        })
        .collect()
}

fn required_child_completion_matrix(
    child_states: &BTreeMap<String, ProgramChildPlanState>,
) -> BTreeMap<String, ProgramRequiredChildCompletion> {
    child_states
        .iter()
        .filter(|(_, state)| state.required)
        .map(|(child_id, state)| {
            (
                child_id.clone(),
                ProgramRequiredChildCompletion {
                    required: state.required,
                    deferred: state.deferred,
                    terminal: state.terminal_outcome.is_some(),
                    terminal_outcome: state.terminal_outcome.clone(),
                    final_verdict: state.final_verdict.clone(),
                    selected_route: state
                        .selected_route
                        .as_ref()
                        .map(|route| route.route_id.clone()),
                    blockers: state.blockers.clone(),
                },
            )
        })
        .collect()
}

fn program_stop_reason(
    program: &ProgramSpec,
    contract: Option<&LifecycleContract>,
    final_verdict: &str,
    terminal_outcome: Option<&str>,
    program_route: Option<&RoutePlanState>,
    program_blockers: &[ProgramBlocker],
    approval_blockers: &[ProgramApprovalBlocker],
    child_states: &BTreeMap<String, ProgramChildPlanState>,
    runnable_batch: &[String],
) -> Option<String> {
    if let Some(outcome) = terminal_outcome {
        return Some(format!("terminal-outcome:{outcome}"));
    }
    if final_verdict == "completed" {
        return Some("all-required-children-terminal".to_string());
    }
    if !runnable_batch.is_empty() {
        return Some("dispatch-available".to_string());
    }
    let program_safe_repair = |blocker: &ProgramBlocker| {
        contract
            .map(|contract| program_blocker_has_safe_agent_repair(contract, program, blocker))
            .unwrap_or_else(|| program_blocker_has_declared_safe_agent_repair(program, blocker))
    };
    if program_route.is_some()
        && program_blockers.iter().any(|blocker| {
            classify_program_blocker_class(&blocker.blocker_class)
                == ProgramBlockerDisposition::Unsafe
                && program_safe_repair(blocker)
        })
    {
        return Some("program-unsafe-repair-dispatch-available".to_string());
    }
    if program_route.is_some() {
        return Some("dispatch-available".to_string());
    }
    if program_blockers.iter().any(|blocker| {
        classify_program_blocker_class(&blocker.blocker_class) == ProgramBlockerDisposition::Unsafe
            && !program_safe_repair(blocker)
    }) {
        return Some("program-unsafe-blocker-no-safe-repair".to_string());
    }
    if !approval_blockers.is_empty()
        || program_blockers.iter().any(|blocker| {
            classify_program_blocker_class(&blocker.blocker_class)
                == ProgramBlockerDisposition::Human
        })
    {
        return Some("approval-blocked-no-dispatch".to_string());
    }
    let required_nonterminal = child_states
        .values()
        .filter(|state| state.required && !state.deferred && state.terminal_outcome.is_none())
        .collect::<Vec<_>>();
    if required_nonterminal.iter().any(|state| {
        state.blockers.iter().any(|blocker| {
            classify_program_blocker_class(&blocker.blocker_class)
                == ProgramBlockerDisposition::Unsafe
                && !blocker_has_safe_agent_repair(program, blocker)
        })
    }) {
        return Some("child-unsafe-blocker".to_string());
    }
    if required_nonterminal
        .iter()
        .any(|state| !state.blockers.is_empty())
    {
        return Some("required-child-blocked-no-dispatch".to_string());
    }
    if !required_nonterminal.is_empty() {
        return Some("required-child-nonterminal-no-route".to_string());
    }
    None
}

fn filter_plan_to_child(plan: &mut ProgramLifecyclePlanResult, child_id: &str) -> Result<()> {
    if !plan.child_states.contains_key(child_id) {
        bail!("program plan has no child {child_id}");
    }
    if plan.runnable_batch.iter().any(|id| id == child_id) {
        plan.runnable_batch.retain(|id| id == child_id);
    } else {
        plan.runnable_batch.clear();
    }
    Ok(())
}

fn execute_parent_program_route(
    octon_dir: &Path,
    program_run_id: &str,
    run_inputs: &BTreeMap<String, String>,
    options: &RunLifecycleOptions,
    plan: &ProgramLifecyclePlanResult,
    evidence_root: &Path,
    control_root: &Path,
    step_context: Option<ProgramExecutionStepContext>,
) -> Result<Option<LifecycleRouteExecutionResult>> {
    let Some(route) = plan.program_route.as_ref() else {
        return Ok(None);
    };
    append_program_event(
        control_root,
        evidence_root,
        program_run_id,
        "parent-route-started",
        None,
        Some(&route.route_id),
        "program parent route execution started",
        program_step_event_data(
            step_context.as_ref(),
            "parent-route-dispatch",
            std::iter::empty::<(&str, &str)>(),
        ),
    )?;
    let parent_evidence_root = evidence_root.join("parent");
    let parent_control_root = control_root.join("parent");
    fs::create_dir_all(&parent_evidence_root)?;
    fs::create_dir_all(&parent_control_root)?;
    let loaded = load_lifecycle_contract(octon_dir, &plan.lifecycle_id)?;
    let mut program_repair_basis = None;
    if let Some(program) = loaded.contract.program.as_ref() {
        for blocker in &plan.program_blockers {
            if recovery_route_for_blocker(program, blocker) == Some(route.route_id.as_str())
                && classify_program_blocker_class(&blocker.blocker_class)
                    == ProgramBlockerDisposition::Unsafe
            {
                let validation =
                    validate_program_recovery_recipe(&loaded.contract, program, blocker, route)
                        .with_context(|| {
                            format!(
                        "program repair route {} failed recovery recipe validation before dispatch",
                        route.route_id
                    )
                        })?;
                program_repair_basis = validation.delegation_contract_basis;
                break;
            }
        }
    }
    let unsafe_repair = loaded.contract.program.as_ref().and_then(|program| {
        unsafe_repair_evidence_for_program_route(
            program_run_id,
            program,
            plan,
            &route.route_id,
            &parent_evidence_root,
        )
    });
    let repo_root = repo_root_for_octon(octon_dir)?;
    let parent_delegation_contract_basis =
        parent_route_delegation_contract_basis(octon_dir, plan, route)?;
    let parent_invocation_authority = if options.invocation_authority == "unattended"
        && parent_delegation_contract_basis.is_none()
        && program_repair_basis.is_none()
    {
        "unattended".to_string()
    } else {
        options.invocation_authority.clone()
    };
    let parent_run_inputs = if route.route_id == "generate-program-correction-prompt"
        && run_inputs
            .get("finding_id")
            .map(|value| value.trim().is_empty())
            .unwrap_or(true)
    {
        match derive_and_write_finding_binding(plan, &parent_evidence_root)? {
            Some(finding_id) => {
                let mut inputs = run_inputs.clone();
                inputs.insert("finding_id".to_string(), finding_id);
                inputs
            }
            None => {
                let result = finding_binding_unavailable_result(
                    program_run_id,
                    route,
                    &plan.target,
                    &parent_evidence_root,
                )?;
                append_program_event(
                    control_root,
                    evidence_root,
                    program_run_id,
                    "parent-route-finished",
                    None,
                    Some(&route.route_id),
                    "program parent route execution finished",
                    program_step_event_data(
                        step_context.as_ref(),
                        "parent-route-dispatch",
                        [("status", result.status.as_str())],
                    ),
                )?;
                return Ok(Some(result));
            }
        }
    } else {
        run_inputs.clone()
    };
    let request = lifecycle_execution_request_for_route(
        octon_dir,
        program_run_id,
        &plan.lifecycle_id,
        &plan.target,
        route,
        options.executor,
        options.timeout_seconds.unwrap_or(1800),
        &parent_invocation_authority,
        0,
        &parent_run_inputs,
        parent_evidence_root.clone(),
        parent_control_root.join("lifecycle-checkpoint.yml"),
        Some(lifecycle_cancellation_token_path(control_root)),
        Some(LifecycleHumanBoundaryContext {
            context_kind: "program-parent-route".to_string(),
            program_run_id: Some(program_run_id.to_string()),
            child_id: None,
            human_exception_instruction: None,
            retry_instruction: Some(format!(
                "octon lifecycle program retry --run-id {program_run_id}"
            )),
        }),
    )?
    .with_context(|| format!("missing selected parent route {}", route.route_id))?;
    if parent_invocation_authority == "unattended" && route.route_id == ROUTE_ID_PROMOTE_PROPOSAL {
        if let Some(basis) = parent_delegation_contract_basis.as_deref() {
            let delegation_receipt = write_delegated_promotion_receipt(
                &parent_evidence_root,
                program_run_id,
                &plan.lifecycle_id,
                &route.route_id,
                None,
                &plan.child_registry_digest,
                None,
                Some("parent-route-contract:child-authority-preserved"),
                Some("program-parent"),
                Some(ARTIFACT_CLASS_WORKSPACE_SOURCE),
                parent_promotion_required_receipt_verdicts(plan),
                parent_promotion_required_receipt_digests(&repo_root, plan)?,
                basis,
                vec![
                    "route-contract:delegation_contract.safe_delegation=true".to_string(),
                    "lifecycle-invocation:invocation_authority=unattended".to_string(),
                    "parent-gates:passing".to_string(),
                    "implementation-run:child_authority_preserved=yes".to_string(),
                ],
            )?;
            let mut data = program_step_event_data(
                step_context.as_ref(),
                "parent-route-dispatch",
                [
                    ("delegation_receipt", delegation_receipt.as_str()),
                    ("invocation_authority", parent_invocation_authority.as_str()),
                    ("delegation_kind", "machine-enforced-delegated-execution"),
                ],
            );
            data.insert(
                "registry_digest".to_string(),
                plan.child_registry_digest.clone(),
            );
            append_program_event(
                control_root,
                evidence_root,
                program_run_id,
                "delegated-promotion-authorized",
                None,
                Some(&route.route_id),
                "parent promotion delegated by route contract, unattended policy, and retained evidence gates",
                data,
            )?;
        }
    }
    let executor = DefaultLifecycleRouteExecutor::new(repo_root);
    let result = match executor.execute_route(request) {
        Ok(result) => result,
        Err(error) => {
            if let Some(evidence) = unsafe_repair {
                write_unsafe_repair_evidence(
                    &parent_evidence_root,
                    evidence,
                    None,
                    Some(&error.to_string()),
                )?;
            }
            return Err(error.into());
        }
    };
    if let Some(evidence) = unsafe_repair {
        write_unsafe_repair_evidence(&parent_evidence_root, evidence, Some(&result), None)?;
    }
    append_program_event(
        control_root,
        evidence_root,
        program_run_id,
        "parent-route-finished",
        None,
        Some(&route.route_id),
        "program parent route execution finished",
        program_step_event_data(
            step_context.as_ref(),
            "parent-route-dispatch",
            [("status", result.status.as_str())],
        ),
    )?;
    Ok(Some(result))
}

#[derive(Serialize)]
struct ProgramFindingBindingEvidence {
    schema_version: &'static str,
    status: String,
    finding_id: Option<String>,
    source_kind: String,
    source_ref: String,
    source_digest: String,
}

fn derive_and_write_finding_binding(
    plan: &ProgramLifecyclePlanResult,
    parent_evidence_root: &Path,
) -> Result<Option<String>> {
    let derived = derive_finding_id(plan);
    let evidence = match derived {
        Some((finding_id, source_kind, source_ref, source_digest)) => {
            ProgramFindingBindingEvidence {
                schema_version: "octon-program-finding-binding-v1",
                status: "derived".to_string(),
                finding_id: Some(finding_id.clone()),
                source_kind,
                source_ref,
                source_digest,
            }
        }
        None => ProgramFindingBindingEvidence {
            schema_version: "octon-program-finding-binding-v1",
            status: "unavailable".to_string(),
            finding_id: None,
            source_kind: "none".to_string(),
            source_ref: "no runtime validation evidence carried a finding id or diagnostic source"
                .to_string(),
            source_digest: "none".to_string(),
        },
    };
    fs::write(
        parent_evidence_root.join("finding-binding.yml"),
        serde_yaml::to_string(&evidence)?,
    )?;
    Ok(evidence.finding_id)
}

fn derive_finding_id(
    plan: &ProgramLifecyclePlanResult,
) -> Option<(String, String, String, String)> {
    for (receipt_id, receipt) in &plan.parent_receipt_states {
        if !receipt.exists
            || !receipt.missing_required_fields.is_empty()
            || receipt.stale == Some(true)
        {
            continue;
        }
        for field in ["finding_id", "finding"] {
            if let Some(value) = receipt
                .fields
                .get(field)
                .filter(|value| !value.trim().is_empty())
            {
                let digest = sha256_hex(value.as_bytes());
                return Some((
                    value.clone(),
                    "parent-receipt-field".to_string(),
                    format!("{receipt_id}.{field}"),
                    format!("sha256:{digest}"),
                ));
            }
        }
    }
    if let Some(gate) = plan.program_gate_results.iter().find(|gate| !gate.passed) {
        let diagnostic = format!(
            "{}\n{}\n{}",
            gate.gate_id,
            gate.stdout.trim(),
            gate.stderr.trim()
        );
        let digest = sha256_hex(diagnostic.as_bytes());
        return Some((
            format!("finding-{}", &digest[..16]),
            "failed-gate".to_string(),
            format!("{}:{}", gate.gate_id, gate.validator_id),
            format!("sha256:{digest}"),
        ));
    }
    if let Some(blocker) = plan
        .program_blockers
        .iter()
        .find(|blocker| blocker.blocker_class == "validation-failed")
    {
        let digest = sha256_hex(blocker.message.as_bytes());
        return Some((
            format!("finding-{}", &digest[..16]),
            "program-blocker".to_string(),
            blocker.blocker_class.clone(),
            format!("sha256:{digest}"),
        ));
    }
    for (child_id, state) in &plan.child_states {
        if let Some(blocker) = state.blockers.iter().find(|blocker| {
            matches!(
                blocker.blocker_class.as_str(),
                "validation-failed" | "missing-evidence" | "stale-receipt"
            )
        }) {
            let diagnostic = format!(
                "{}\n{}\n{}\n{}",
                child_id,
                blocker.blocker_class,
                blocker.recovery_route.as_deref().unwrap_or("no-route"),
                blocker.message
            );
            let digest = sha256_hex(diagnostic.as_bytes());
            return Some((
                format!("finding-{}", &digest[..16]),
                "child-diagnostic".to_string(),
                format!("child:{child_id}:{}", blocker.blocker_class),
                format!("sha256:{digest}"),
            ));
        }
    }
    None
}

fn sha256_hex(bytes: &[u8]) -> String {
    let mut hasher = Sha256::new();
    hasher.update(bytes);
    format!("{:x}", hasher.finalize())
}

fn finding_binding_unavailable_result(
    program_run_id: &str,
    route: &RoutePlanState,
    _target: &str,
    parent_evidence_root: &Path,
) -> Result<LifecycleRouteExecutionResult> {
    let now = now_rfc3339()?;
    let evidence_path = parent_evidence_root.join("finding-binding.yml");
    if !evidence_path.is_file() {
        fs::write(
            &evidence_path,
            "schema_version: octon-program-finding-binding-v1\nstatus: unavailable\nsource_kind: none\nsource_ref: no runtime validation evidence carried a finding id or diagnostic source\nsource_digest: none\n",
        )?;
    }
    Ok(LifecycleRouteExecutionResult {
        schema_version: "octon-lifecycle-route-execution-result-v1".to_string(),
        run_id: program_run_id.to_string(),
        route_id: route.route_id.clone(),
        executor_used: "program-controller".to_string(),
        status: "blocked-human".to_string(),
        started_at: now.clone(),
        ended_at: now,
        manifest_status_before: None,
        manifest_status_after: None,
        receipts_observed: Vec::new(),
        evidence_paths: vec![evidence_path],
        stdout_path: None,
        stderr_path: None,
        prompt_packet_path: None,
        retryable: false,
        next_action: "manual-intervention".to_string(),
        error_class: Some(LifecycleErrorClass::InputBinding),
        error_message: Some(
            "finding-binding-unavailable: generate-program-correction-prompt requires finding_id"
                .to_string(),
        ),
    })
}

fn final_verdict_for_parent_route_status(status: &str) -> String {
    match status {
        "human-boundary-blocked" => "blocked-human".to_string(),
        "authorization-proof-failed" => "blocked-recoverable".to_string(),
        "cancelled" => "cancelled".to_string(),
        "failed" | "timed-out" | "blocked" => "blocked-recoverable".to_string(),
        other => other.to_string(),
    }
}

fn child_promotion_required_receipt_verdicts() -> BTreeMap<String, String> {
    BTreeMap::from([
        (
            RECEIPT_ID_IMPLEMENTATION_RUN.to_string(),
            "pass".to_string(),
        ),
        (
            RECEIPT_ID_IMPLEMENTATION_CONFORMANCE.to_string(),
            "pass".to_string(),
        ),
        (
            RECEIPT_ID_POST_IMPLEMENTATION_DRIFT.to_string(),
            "pass".to_string(),
        ),
    ])
}

fn child_promotion_required_receipt_digests(
    state: &ProgramChildPlanState,
) -> BTreeMap<String, String> {
    [
        RECEIPT_ID_IMPLEMENTATION_RUN,
        RECEIPT_ID_IMPLEMENTATION_CONFORMANCE,
        RECEIPT_ID_POST_IMPLEMENTATION_DRIFT,
    ]
    .into_iter()
    .filter_map(|receipt_id| {
        state
            .receipt_digests
            .get(receipt_id)
            .map(|digest| (receipt_id.to_string(), digest.clone()))
    })
    .collect()
}

fn parent_promotion_required_receipt_verdicts(
    plan: &ProgramLifecyclePlanResult,
) -> BTreeMap<String, String> {
    let mut verdicts = BTreeMap::new();
    for receipt_id in [RECEIPT_ID_PROPOSAL_REVIEW, RECEIPT_ID_IMPLEMENTATION_RUN] {
        if let Some(verdict) = plan
            .parent_receipt_states
            .get(receipt_id)
            .and_then(|receipt| receipt.verdict.as_ref())
        {
            verdicts.insert(receipt_id.to_string(), verdict.clone());
        }
    }
    if let Some(value) = plan
        .parent_receipt_states
        .get(RECEIPT_ID_IMPLEMENTATION_RUN)
        .and_then(|receipt| receipt.fields.get(FIELD_CHILD_AUTHORITY_PRESERVED))
    {
        verdicts.insert(
            format!("{RECEIPT_ID_IMPLEMENTATION_RUN}.{FIELD_CHILD_AUTHORITY_PRESERVED}"),
            value.clone(),
        );
    }
    verdicts.insert("program-gates".to_string(), "pass".to_string());
    verdicts
}

fn parent_promotion_required_receipt_digests(
    repo_root: &Path,
    plan: &ProgramLifecyclePlanResult,
) -> Result<BTreeMap<String, String>> {
    let mut digests = BTreeMap::new();
    for receipt_id in [
        RECEIPT_ID_PROPOSAL_REVIEW,
        RECEIPT_ID_PROGRAM_IMPLEMENTATION_PROMPT,
        RECEIPT_ID_IMPLEMENTATION_RUN,
    ] {
        let Some(receipt) = plan.parent_receipt_states.get(receipt_id) else {
            continue;
        };
        if let Some(digest) = receipt
            .current_digest
            .as_ref()
            .or(receipt.stored_digest.as_ref())
        {
            digests.insert(receipt_id.to_string(), digest.clone());
            continue;
        }
        if receipt.exists {
            digests.insert(
                receipt_id.to_string(),
                file_digest(&repo_root.join(&receipt.path))?,
            );
        }
    }
    Ok(digests)
}

fn write_delegated_promotion_receipt(
    evidence_root: &Path,
    program_run_id: &str,
    lifecycle_id: &str,
    route_id: &str,
    child_id: Option<&str>,
    registry_digest: &str,
    write_scope_digest: Option<&str>,
    authority_zone_decision_ref: Option<&str>,
    authority_zone: Option<&str>,
    artifact_class: Option<&str>,
    required_receipt_verdicts: BTreeMap<String, String>,
    required_receipt_digests: BTreeMap<String, String>,
    route_delegation_contract_basis: &str,
    authority_provenance: Vec<String>,
) -> Result<String> {
    fs::create_dir_all(evidence_root)?;
    let subject = child_id.unwrap_or("parent");
    let path = evidence_root.join(format!(
        "delegated-promotion-{}-{}.yml",
        sanitize_run_id(subject)?,
        sanitize_run_id(route_id)?
    ));
    let receipt = ProgramDelegatedPromotionReceipt {
        schema_version: "octon-program-delegated-promotion-v1".to_string(),
        delegation_kind: "machine-enforced-delegated-execution".to_string(),
        program_run_id: program_run_id.to_string(),
        lifecycle_id: lifecycle_id.to_string(),
        route_id: route_id.to_string(),
        child_id: child_id.map(str::to_string),
        registry_digest: registry_digest.to_string(),
        write_scope_digest: write_scope_digest.map(str::to_string),
        authority_zone_decision_ref: authority_zone_decision_ref.map(str::to_string),
        authority_zone: authority_zone.map(str::to_string),
        artifact_class: artifact_class.map(str::to_string),
        required_receipt_verdicts,
        required_receipt_digests,
        route_delegation_contract_basis: route_delegation_contract_basis.to_string(),
        invocation_authority: "unattended".to_string(),
        human_exception_grant: false,
        authority_provenance,
        recorded_at: now_rfc3339()?,
    };
    fs::write(&path, serde_yaml::to_string(&receipt)?)?;
    Ok(rel_path_string(&path))
}

fn build_child_execution_jobs(
    octon_dir: &Path,
    repo_root: &Path,
    program_run_id: &str,
    run_inputs: &BTreeMap<String, String>,
    options: &RunLifecycleOptions,
    plan: &ProgramLifecyclePlanResult,
    evidence_root: &Path,
    control_root: &Path,
    approvals: Option<&Vec<ProgramApprovalGrant>>,
    checkpoint: Option<&ProgramLifecycleCheckpoint>,
) -> Result<(Vec<ChildExecutionJob>, Vec<ProgramChildExecutionSummary>)> {
    let mut jobs = Vec::new();
    let mut preflight_summaries = Vec::new();
    let result = (|| -> Result<()> {
        for child_id in &plan.runnable_batch {
            let Some(state) = plan.child_states.get(child_id) else {
                continue;
            };
            let (route, blocker_class) = selected_route_for_child_execution(
                octon_dir,
                options,
                state,
                approvals,
                &plan.child_registry_digest,
            )?;
            let Some(route) = route.as_ref() else {
                preflight_summaries.push(ProgramChildExecutionSummary {
                    child_id: child_id.clone(),
                    child_run_id: format!("{program_run_id}-{child_id}-recovery-route"),
                    route_id: "none".to_string(),
                    status: "blocked-human".to_string(),
                    attempts: 0,
                    retryable: false,
                    blocker_class: Some(
                        blocker_class.unwrap_or_else(|| "recovery-route-unavailable".to_string()),
                    ),
                    error_message: Some(
                        "child blocker has no executable selected route".to_string(),
                    ),
                    error_class: None,
                    evidence_paths: Vec::new(),
                    worktree_hygiene_foreign_fingerprint: None,
                });
                continue;
            };
            let child_run_id = sanitize_run_id(&format!("{program_run_id}-{child_id}"))?;
            let child_evidence_root = evidence_root.join("children").join(child_id);
            let child_control_root = control_root.join("children").join(child_id);
            fs::create_dir_all(&child_evidence_root)?;
            fs::create_dir_all(&child_control_root)?;
            fs::write(
                child_evidence_root.join("child-plan.yml"),
                serde_yaml::to_string(state)?,
            )?;
            if let Some(summary) = closeout_worktree_hygiene_preflight(
                repo_root,
                control_root,
                evidence_root,
                &child_evidence_root,
                program_run_id,
                state,
                &route.route_id,
            )? {
                preflight_summaries.push(summary);
                continue;
            }
            let program_contract = load_lifecycle_contract(octon_dir, &options.lifecycle_id)?;
            let program = program_contract.contract.program.as_ref();
            let route_delegation_contract_basis = match program {
                Some(program) => lifecycle_route_delegation_contract_basis_for_child(
                    octon_dir,
                    program,
                    state,
                    &route.route_id,
                )?,
                None => lifecycle_route_delegation_contract_basis(
                    octon_dir,
                    &state.child_lifecycle_id,
                    &route.route_id,
                )?,
            };
            let delegation_contract_basis = if let Some(class) = blocker_class.as_deref() {
                program
                    .and_then(|program| recovery_delegation_contract_basis(Some(program), class))
                    .or(route_delegation_contract_basis)
            } else {
                route_delegation_contract_basis
            };
            let authority_decision = child_route_authority_decision(
                repo_root,
                program_run_id,
                state,
                &route.route_id,
                if blocker_class.is_some() {
                    OPERATION_CLASS_RETRY_CHILD_ROUTE
                } else {
                    OPERATION_CLASS_EXECUTE_CHILD_ROUTE
                },
            );
            let invocation_authority = invocation_authority_for_child_route(
                &options.invocation_authority,
                approvals,
                child_id,
                &route.route_id,
                Some(&plan.child_registry_digest),
                blocker_class.as_deref(),
                delegation_contract_basis.is_some(),
                Some(&authority_decision),
            );
            let authority_decision_path =
                write_authority_zone_decision(evidence_root, &authority_decision)?;
            let route_contract_allows_unapproved_workspace =
                route.route_type != "workflow" && blocker_class.is_none();
            let authority_dispatch_allowed = invocation_authority == "grant-consumption"
                || authority_decision.autonomous_allowed
                || (authority_decision.authority_zone == AUTHORITY_ZONE_WORKSPACE_DECLARED
                    && authority_decision.workspace_contained
                    && authority_decision.declared_scope_contained
                    && route_contract_allows_unapproved_workspace)
                || (authority_decision.authority_zone == AUTHORITY_ZONE_WORKSPACE_DECLARED
                    && authority_decision.workspace_contained
                    && authority_decision.declared_scope_contained
                    && blocker_class.is_some()
                    && delegation_contract_basis.is_some())
                || (invocation_authority == "unattended"
                    && delegation_contract_basis.is_some()
                    && authority_decision_allows_route_unattended(&authority_decision));
            if !authority_dispatch_allowed {
                let dispatch_blocker_class = if authority_decision.authority_zone
                    == AUTHORITY_ZONE_WORKSPACE_DECLARED
                    && route.route_type == "workflow"
                {
                    "authority-ambiguity".to_string()
                } else {
                    authority_decision.fail_closed_blocker.clone()
                };
                append_program_event(
                    control_root,
                    evidence_root,
                    program_run_id,
                    "child-route-authority-blocked",
                    Some(child_id),
                    Some(&route.route_id),
                    "program child route blocked by authority-zone decision",
                    event_data([
                        ("authority_zone", authority_decision.authority_zone.as_str()),
                        ("artifact_class", authority_decision.artifact_class.as_str()),
                        ("authority_decision", authority_decision_path.as_str()),
                    ]),
                )?;
                preflight_summaries.push(ProgramChildExecutionSummary {
                    child_id: child_id.clone(),
                    child_run_id: child_run_id.clone(),
                    route_id: route.route_id.clone(),
                    status: if dispatch_blocker_class == "authority-ambiguity" {
                        "human-boundary-blocked".to_string()
                    } else if classify_program_blocker_class(&dispatch_blocker_class)
                        == ProgramBlockerDisposition::Unsafe
                    {
                        "blocked-unsafe".to_string()
                    } else {
                        "blocked-human".to_string()
                    },
                    attempts: 0,
                    retryable: false,
                    blocker_class: Some(dispatch_blocker_class),
                    error_message: Some(format!(
                        "authority zone {} does not permit unattended dispatch for artifact class {}",
                        authority_decision.authority_zone, authority_decision.artifact_class
                    )),
                    error_class: Some("authority-zone".to_string()),
                    evidence_paths: vec![authority_decision_path],
                    worktree_hygiene_foreign_fingerprint: None,
                });
                continue;
            }
            let unsafe_repair = blocker_class.as_deref().and_then(|class| {
                unsafe_repair_evidence_for_job(
                    program_run_id,
                    state,
                    class,
                    &route.route_id,
                    delegation_contract_basis.as_deref(),
                    &child_evidence_root,
                )
            });
            if invocation_authority == "grant-consumption" {
                write_program_approval_execution_evidence(
                    repo_root,
                    &child_evidence_root,
                    program_run_id,
                    child_id,
                    &route.route_id,
                    Some(&plan.child_registry_digest),
                    blocker_class.as_deref(),
                    approvals,
                )?;
            }
            if invocation_authority == "unattended"
                && blocker_class.is_none()
                && route.route_id == ROUTE_ID_PROMOTE_PROPOSAL
            {
                if let Some(basis) = delegation_contract_basis.as_deref() {
                    let delegation_receipt = write_delegated_promotion_receipt(
                        &child_evidence_root,
                        program_run_id,
                        &state.child_lifecycle_id,
                        &route.route_id,
                        Some(child_id),
                        &plan.child_registry_digest,
                        authority_decision.write_scope_digest.as_deref(),
                        Some(&authority_decision_path),
                        Some(&authority_decision.authority_zone),
                        Some(&authority_decision.artifact_class),
                        child_promotion_required_receipt_verdicts(),
                        child_promotion_required_receipt_digests(state),
                        basis,
                        vec![
                            "route-contract:delegation_contract.safe_delegation=true".to_string(),
                            "lifecycle-invocation:invocation_authority=unattended".to_string(),
                            "authority-zone:workspace-declared".to_string(),
                            "child-verification:implementation-run+conformance+drift=pass"
                                .to_string(),
                        ],
                    )?;
                    let mut data = program_step_event_data(
                        None,
                        "child-route-dispatch",
                        [
                            ("delegation_receipt", delegation_receipt.as_str()),
                            ("invocation_authority", invocation_authority.as_str()),
                            ("authority_decision", authority_decision_path.as_str()),
                            ("delegation_kind", "machine-enforced-delegated-execution"),
                        ],
                    );
                    data.insert(
                        "registry_digest".to_string(),
                        plan.child_registry_digest.clone(),
                    );
                    if let Some(write_scope_digest) = authority_decision.write_scope_digest.as_ref()
                    {
                        data.insert("write_scope_digest".to_string(), write_scope_digest.clone());
                    }
                    append_program_event(
                        control_root,
                        evidence_root,
                        program_run_id,
                        "delegated-promotion-authorized",
                        Some(child_id),
                        Some(&route.route_id),
                        "child promotion delegated by route contract, unattended policy, authority-zone decision, and retained evidence gates",
                        data,
                    )?;
                }
            }
            let request = lifecycle_execution_request_for_route(
                octon_dir,
                &child_run_id,
                &state.child_lifecycle_id,
                &state.target,
                route,
                options.executor,
                options.timeout_seconds.unwrap_or(1800),
                &invocation_authority,
                0,
                run_inputs,
                child_evidence_root,
                child_control_root.join("lifecycle-checkpoint.yml"),
                Some(lifecycle_cancellation_token_path(control_root)),
                Some(program_child_approval_context(
                    program_run_id,
                    child_id,
                    &child_run_id,
                    &state.child_lifecycle_id,
                    &state.target,
                    &route.route_id,
                )),
            )?
            .with_context(|| format!("missing selected route for child {child_id}"))?;
            let lock_path = acquire_child_lock(control_root, child_id)?;
            let max_attempts = plan
                .child_states
                .get(child_id)
                .and_then(|_| {
                    load_lifecycle_contract(octon_dir, &options.lifecycle_id)
                        .ok()
                        .and_then(|loaded| loaded.contract.program)
                        .and_then(|program| {
                            blocker_class
                                .as_deref()
                                .and_then(|class| recovery_attempt_budget(&program, class))
                                .or(program.recovery_policy.max_recovery_attempts)
                        })
                })
                .unwrap_or(1)
                .max(1);
            let max_attempts = if let Some(class) = blocker_class.as_deref() {
                let used = checkpoint
                    .map(|checkpoint| recovery_attempt_count(checkpoint, child_id, class))
                    .unwrap_or(0);
                max_attempts.saturating_sub(used).max(1)
            } else {
                max_attempts
            };
            jobs.push(ChildExecutionJob {
                child_id: child_id.clone(),
                child_run_id,
                route_id: route.route_id.clone(),
                request,
                lock_path,
                max_attempts,
                blocker_class,
                unsafe_repair,
            });
        }
        Ok(())
    })();
    if let Err(error) = result {
        release_child_locks_after_build_failure(
            control_root,
            evidence_root,
            program_run_id,
            &jobs,
        )?;
        return Err(error);
    }
    let _ = repo_root;
    Ok((jobs, preflight_summaries))
}

fn closeout_worktree_hygiene_preflight(
    repo_root: &Path,
    control_root: &Path,
    evidence_root: &Path,
    child_evidence_root: &Path,
    program_run_id: &str,
    state: &ProgramChildPlanState,
    route_id: &str,
) -> Result<Option<ProgramChildExecutionSummary>> {
    if !route_has_closeout_hygiene_preflight(route_id) {
        return Ok(None);
    }
    let stdout_path = child_evidence_root.join("worktree-hygiene-preflight.stdout.yml");
    let stderr_path = child_evidence_root.join("worktree-hygiene-preflight.stderr.log");
    let Some(classifier) =
        closeout_worktree_hygiene_classifier(repo_root, &state.target, program_run_id)?
    else {
        return Ok(None);
    };
    fs::write(&stdout_path, &classifier.stdout)?;
    fs::write(&stderr_path, &classifier.stderr)?;
    let decision = classifier.decision;
    let status = decision.status;
    let stdout_rel = rel_display(repo_root, &stdout_path);
    let stderr_rel = rel_display(repo_root, &stderr_path);
    append_program_event(
        control_root,
        evidence_root,
        program_run_id,
        "worktree-hygiene-preflight",
        Some(&state.child_id),
        Some(route_id),
        "child closeout worktree hygiene preflight completed",
        program_event_data([
            ("status", status),
            ("stdout_path", stdout_rel.as_str()),
            ("stderr_path", stderr_rel.as_str()),
        ]),
    )?;
    if status == "pass" {
        return Ok(None);
    }
    Ok(Some(ProgramChildExecutionSummary {
        child_id: state.child_id.clone(),
        child_run_id: format!("{program_run_id}-{}-worktree-hygiene", state.child_id),
        route_id: route_id.to_string(),
        status: "blocked".to_string(),
        attempts: 0,
        retryable: false,
        blocker_class: Some(decision.blocker_class),
        error_message: Some(decision.message),
        error_class: None,
        evidence_paths: vec![stdout_rel, stderr_rel],
        worktree_hygiene_foreign_fingerprint: decision.foreign_fingerprint,
    }))
}

fn route_has_closeout_hygiene_preflight(route_id: &str) -> bool {
    matches!(route_id, "closeout-packet" | "archive-proposal")
}

fn closeout_hygiene_suppression_key(child_id: &str, route_id: &str) -> String {
    format!("{child_id}:{route_id}")
}

struct WorktreeHygieneClassifierRun {
    stdout: Vec<u8>,
    stderr: Vec<u8>,
    decision: WorktreeHygienePreflightDecision,
}

fn closeout_worktree_hygiene_classifier(
    repo_root: &Path,
    target: &str,
    program_run_id: &str,
) -> Result<Option<WorktreeHygieneClassifierRun>> {
    let script =
        ".octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh";
    if !repo_root.join(script).is_file() {
        return Ok(None);
    }
    let output = Command::new("bash")
        .arg(script)
        .arg("--target")
        .arg(target)
        .arg("--lifecycle")
        .arg("proposal-packet")
        .arg("--run-id")
        .arg(program_run_id)
        .arg("--format")
        .arg("yaml")
        .current_dir(repo_root)
        .env("OCTON_ROOT_DIR", repo_root)
        .output()?;
    let stdout_text = String::from_utf8_lossy(&output.stdout);
    let decision = classify_worktree_hygiene_preflight(output.status.success(), &stdout_text);
    Ok(Some(WorktreeHygieneClassifierRun {
        stdout: output.stdout,
        stderr: output.stderr,
        decision,
    }))
}

#[derive(Clone, Debug)]
struct WorktreeHygienePreflightDecision {
    status: &'static str,
    blocker_class: String,
    message: String,
    foreign_fingerprint: Option<String>,
}

#[derive(Default, Deserialize)]
struct WorktreeHygieneClassifierOutput {
    #[serde(default)]
    worktree_hygiene_verdict: Option<String>,
    #[serde(default)]
    worktree_hygiene_blocker_class: Option<String>,
    #[serde(default)]
    worktree_hygiene_foreign_path_count: Option<u64>,
    #[serde(default)]
    worktree_hygiene_foreign_fingerprint: Option<String>,
}

fn classify_worktree_hygiene_preflight(
    classifier_succeeded: bool,
    stdout: &str,
) -> WorktreeHygienePreflightDecision {
    let parsed = serde_yaml::from_str::<WorktreeHygieneClassifierOutput>(stdout).ok();
    let verdict = parsed
        .as_ref()
        .and_then(|value| value.worktree_hygiene_verdict.as_deref())
        .unwrap_or_default();
    let blocker_class = parsed
        .as_ref()
        .and_then(|value| value.worktree_hygiene_blocker_class.as_deref())
        .unwrap_or_default();
    let foreign_count = parsed
        .as_ref()
        .and_then(|value| value.worktree_hygiene_foreign_path_count);
    let foreign_fingerprint = parsed
        .as_ref()
        .and_then(|value| value.worktree_hygiene_foreign_fingerprint.clone());

    let noncritical_current_run_residue = matches!(
        blocker_class,
        "noncritical-artifact-cleanup"
            | "local-run-residue"
            | "child-lock-stale"
            | "generated-scratch-stale"
    ) && foreign_count == Some(0);

    if classifier_succeeded && (verdict == "pass" || noncritical_current_run_residue) {
        return WorktreeHygienePreflightDecision {
            status: "pass",
            blocker_class: String::new(),
            message: "closeout/archive worktree hygiene is passable".to_string(),
            foreign_fingerprint,
        };
    }

    WorktreeHygienePreflightDecision {
        status: "blocked",
        blocker_class: "artifact-ownership-unclear".to_string(),
        message: "closeout/archive blocked by foreign or ambiguous worktree hygiene".to_string(),
        foreign_fingerprint,
    }
}

fn selected_route_for_child_execution(
    octon_dir: &Path,
    options: &RunLifecycleOptions,
    state: &ProgramChildPlanState,
    approvals: Option<&Vec<ProgramApprovalGrant>>,
    registry_digest: &str,
) -> Result<(Option<RoutePlanState>, Option<String>)> {
    let loaded = load_lifecycle_contract(octon_dir, &options.lifecycle_id)?;
    let Some(program) = loaded.contract.program.as_ref() else {
        return Ok((state.selected_route.clone(), None));
    };
    let unresolved_authority_blocker = unresolved_child_authority_blocker(program, state);
    let Some(blocker) = state.blockers.iter().find(|blocker| {
        recovery_route_for_blocker(program, blocker).is_some()
            && !matches!(
                blocker.blocker_class.as_str(),
                "authority-ambiguity" | "policy-override"
            )
            && (unresolved_authority_blocker.is_none()
                || matches!(
                    classify_program_blocker_class(&blocker.blocker_class),
                    ProgramBlockerDisposition::Human | ProgramBlockerDisposition::Unsafe
                ))
    }) else {
        if let Some(blocker) = unresolved_authority_blocker {
            return Ok((None, Some(blocker.blocker_class.clone())));
        }
        return Ok((state.selected_route.clone(), None));
    };
    if blocker_non_recoverable(&blocker.blocker_class)
        && !blocker_has_safe_agent_repair(program, blocker)
    {
        return Ok((None, Some(blocker.blocker_class.clone())));
    }
    validate_recovery_recipe(program, &blocker.blocker_class, state)?;
    let route_id =
        recovery_route_id(program, &blocker.blocker_class).or(blocker.recovery_route.as_ref());
    let Some(route_id) = route_id else {
        return Ok((state.selected_route.clone(), None));
    };
    let approval_granted = approval_granted(
        approvals,
        &state.child_id,
        route_id,
        Some(registry_digest),
        Some(&blocker.blocker_class),
    );
    let delegation_safe = options.invocation_authority == "unattended"
        && recovery_delegation_contract_basis(Some(program), &blocker.blocker_class).is_some();
    if recovery_requires_approval(program, &blocker.blocker_class)
        && !approval_granted
        && !delegation_safe
    {
        return Ok((None, Some(blocker.blocker_class.clone())));
    }
    let child_contract = load_lifecycle_contract(octon_dir, &state.child_lifecycle_id)?;
    if let Some(route) = route_by_id(&child_contract.contract, route_id) {
        Ok((
            Some(route_plan_state(route.clone())),
            Some(blocker.blocker_class.clone()),
        ))
    } else if let Some(fallback_route) = blocker.recovery_route.as_ref() {
        let route = route_by_id(&child_contract.contract, fallback_route).with_context(|| {
            format!("recovery route missing from child lifecycle: {fallback_route}")
        })?;
        Ok((
            Some(route_plan_state(route.clone())),
            Some(blocker.blocker_class.clone()),
        ))
    } else {
        Ok((
            state.selected_route.clone(),
            Some(blocker.blocker_class.clone()),
        ))
    }
}

fn unresolved_child_authority_blocker<'a>(
    program: &ProgramSpec,
    state: &'a ProgramChildPlanState,
) -> Option<&'a ProgramBlocker> {
    state.blockers.iter().find(|blocker| {
        !matches!(
            blocker.blocker_class.as_str(),
            "authority-ambiguity" | "policy-override"
        ) && matches!(
            classify_program_blocker_class(&blocker.blocker_class),
            ProgramBlockerDisposition::Human | ProgramBlockerDisposition::Unsafe
        ) && !blocker_has_safe_agent_repair(program, blocker)
    })
}

fn unsafe_repair_evidence_for_job(
    program_run_id: &str,
    state: &ProgramChildPlanState,
    blocker_class: &str,
    route_id: &str,
    delegation_contract_basis: Option<&str>,
    child_evidence_root: &Path,
) -> Option<ProgramUnsafeRepairEvidence> {
    if classify_program_blocker_class(blocker_class) != ProgramBlockerDisposition::Unsafe {
        return None;
    }
    let authority_basis = delegation_contract_basis?;
    let unsafe_condition = state
        .blockers
        .iter()
        .find(|blocker| blocker.blocker_class == blocker_class)
        .map(|blocker| blocker.message.clone())
        .unwrap_or_else(|| format!("unsafe blocker {blocker_class}"));
    Some(ProgramUnsafeRepairEvidence {
        schema_version: "octon-program-lifecycle-unsafe-repair-v2".to_string(),
        program_run_id: program_run_id.to_string(),
        repair_scope: "child".to_string(),
        blocker_scope: "child".to_string(),
        child_id: state.child_id.clone(),
        unsafe_condition,
        original_route_blocked_reason: format!(
            "current route or action for {blocker_class} must not continue as-is"
        ),
        selected_repair_route: route_id.to_string(),
        agent_authority_basis: authority_basis.to_string(),
        files_artifacts_changed: vec![rel_path_string(child_evidence_root)],
        before_validation:
            "unsafe blocker selected for governed repair before child route dispatch".to_string(),
        after_validation: "pending repair route execution".to_string(),
        safe_continuation_available: true,
        route_execution_status: "pending".to_string(),
        recipe_validation_status: "passed".to_string(),
        recipe_validation_failures: Vec::new(),
        post_attempt_validations_declared: Vec::new(),
        post_attempt_validation_results: Vec::new(),
        resume_decision_basis: "pending post-attempt validation".to_string(),
        post_attempt_validation_status: "pending".to_string(),
        post_attempt_validation_failures: Vec::new(),
        final_blocker_class: Some(blocker_class.to_string()),
        final_execution_can_resume: false,
        execution_can_resume: false,
    })
}

fn unsafe_repair_evidence_for_program_route(
    program_run_id: &str,
    program: &ProgramSpec,
    plan: &ProgramLifecyclePlanResult,
    route_id: &str,
    parent_evidence_root: &Path,
) -> Option<ProgramUnsafeRepairEvidence> {
    let blocker = plan.program_blockers.iter().find(|blocker| {
        classify_program_blocker_class(&blocker.blocker_class) == ProgramBlockerDisposition::Unsafe
            && recovery_route_for_blocker(program, blocker) == Some(route_id)
    })?;
    let authority_basis =
        program_repair_delegation_contract_basis(program, &blocker.blocker_class)?;
    let declared_validations = recovery_post_attempt_validations(program, &blocker.blocker_class);
    Some(ProgramUnsafeRepairEvidence {
        schema_version: "octon-program-lifecycle-unsafe-repair-v2".to_string(),
        program_run_id: program_run_id.to_string(),
        repair_scope: "program".to_string(),
        blocker_scope: "program".to_string(),
        child_id: "program".to_string(),
        unsafe_condition: blocker.message.clone(),
        original_route_blocked_reason: format!(
            "program route or action for {} must not continue as-is",
            blocker.blocker_class
        ),
        selected_repair_route: route_id.to_string(),
        agent_authority_basis: authority_basis,
        files_artifacts_changed: vec![rel_path_string(parent_evidence_root)],
        before_validation:
            "unsafe program blocker selected for governed repair before parent route dispatch"
                .to_string(),
        after_validation: "pending repair route execution".to_string(),
        safe_continuation_available: true,
        route_execution_status: "pending".to_string(),
        recipe_validation_status: plan
            .program_recovery_recipe_validation_status
            .clone()
            .unwrap_or_else(|| "passed".to_string()),
        recipe_validation_failures: plan.program_recovery_recipe_validation_failures.clone(),
        post_attempt_validations_declared: declared_validations,
        post_attempt_validation_results: Vec::new(),
        resume_decision_basis: "pending post-attempt validation".to_string(),
        post_attempt_validation_status: "pending".to_string(),
        post_attempt_validation_failures: Vec::new(),
        final_blocker_class: Some(blocker.blocker_class.clone()),
        final_execution_can_resume: false,
        execution_can_resume: false,
    })
}

fn program_child_approval_context(
    program_run_id: &str,
    child_id: &str,
    _child_run_id: &str,
    _child_lifecycle_id: &str,
    _child_target: &str,
    route_id: &str,
) -> LifecycleHumanBoundaryContext {
    LifecycleHumanBoundaryContext {
        context_kind: "program-child-route".to_string(),
        program_run_id: Some(program_run_id.to_string()),
        child_id: Some(child_id.to_string()),
        human_exception_instruction: Some(format!(
            "record typed human exception grant for program child route {child_id}:{route_id}"
        )),
        retry_instruction: Some(format!(
            "octon lifecycle program retry --run-id {program_run_id} --child {child_id}"
        )),
    }
}

fn recovery_route_id<'a>(program: &'a ProgramSpec, blocker_class: &str) -> Option<&'a String> {
    program
        .recovery_policy
        .recipes
        .iter()
        .find(|recipe| recovery_recipe_matches(recipe, blocker_class))
        .and_then(|recipe| recipe.recovery_route_id.as_ref())
        .or_else(|| {
            program
                .recovery_policy
                .handlers
                .get(blocker_class)
                .and_then(|handler| handler.recovery_route_id.as_ref())
        })
}

fn recovery_action_id<'a>(program: &'a ProgramSpec, blocker_class: &str) -> Option<&'a String> {
    program
        .recovery_policy
        .recipes
        .iter()
        .find(|recipe| recovery_recipe_matches(recipe, blocker_class))
        .and_then(|recipe| recipe.recovery_action_id.as_ref())
}

fn child_results_have_publication_post_validation_failure(
    child_results: &[ProgramChildExecutionSummary],
) -> bool {
    child_results.iter().any(|result| {
        result.blocker_class.as_deref() == Some("publication-drift")
            && result.status == "failed"
            && result
                .error_message
                .as_deref()
                .map(|message| {
                    message
                        .contains("recovery post-attempt validation failed for publication-drift")
                        && message.contains("publication-freshness-cleared")
                })
                .unwrap_or(false)
    })
}

fn recovery_route_for_blocker<'a>(
    program: &'a ProgramSpec,
    blocker: &'a ProgramBlocker,
) -> Option<&'a str> {
    recovery_route_id(program, &blocker.blocker_class)
        .map(String::as_str)
        .or(blocker.recovery_route.as_deref())
}

fn recovery_recipe_for_blocker<'a>(
    program: &'a ProgramSpec,
    blocker_class: &str,
) -> Option<&'a ProgramRecoveryRecipeSpec> {
    program
        .recovery_policy
        .recipes
        .iter()
        .find(|recipe| recovery_recipe_matches(recipe, blocker_class))
}

fn recovery_delegation_contract_basis(
    program: Option<&ProgramSpec>,
    blocker_class: &str,
) -> Option<String> {
    if blocker_class == "recovery-budget-exhausted-alternate-route" {
        return Some(
            "budget exhausted for one recovery route; selected alternate was preclassified safe"
                .to_string(),
        );
    }
    let program = program?;
    let recipe = recovery_recipe_for_blocker(program, blocker_class)?;
    let idempotency_class = recipe.idempotency_class.as_deref()?;
    delegated_replay_class(idempotency_class).then(|| {
        format!(
            "recovery recipe {} idempotency_class={idempotency_class}",
            recipe.blocker_class
        )
    })
}

fn delegated_replay_class(idempotency_class: &str) -> bool {
    matches!(
        idempotency_class,
        "inspect-only" | "idempotent" | "idempotent-rerun" | "bounded-retry" | "no-op-safe"
    )
}

fn lifecycle_route_delegation_contract_basis(
    octon_dir: &Path,
    lifecycle_id: &str,
    route_id: &str,
) -> Result<Option<String>> {
    let loaded = load_lifecycle_contract(octon_dir, lifecycle_id)?;
    Ok(route_by_id(&loaded.contract, route_id)
        .and_then(|route| route_spec_delegation_contract_basis(route_id, route)))
}

fn route_spec_delegation_contract_basis(route_id: &str, route: &RouteSpec) -> Option<String> {
    let contract = route.delegation_contract.as_ref()?;
    if contract.decision_class == "delegated-execution"
        && contract.safe_delegation
        && delegated_replay_class(&contract.replay_class)
    {
        Some(format!(
            "route {route_id} delegation_contract.safe_delegation=true replay_class={}",
            contract.replay_class
        ))
    } else {
        None
    }
}

fn recovery_attempt_budget(program: &ProgramSpec, blocker_class: &str) -> Option<u32> {
    program
        .recovery_policy
        .recipes
        .iter()
        .find(|recipe| recovery_recipe_matches(recipe, blocker_class))
        .and_then(|recipe| recipe.retry_budget)
        .or_else(|| {
            program
                .recovery_policy
                .handlers
                .get(blocker_class)
                .and_then(|handler| handler.max_attempts)
        })
}

fn recovery_requires_approval(program: &ProgramSpec, blocker_class: &str) -> bool {
    program
        .recovery_policy
        .recipes
        .iter()
        .find(|recipe| recovery_recipe_matches(recipe, blocker_class))
        .map(|recipe| recipe.human_required)
        .or_else(|| {
            program
                .recovery_policy
                .handlers
                .get(blocker_class)
                .map(|handler| handler.human_required)
        })
        .unwrap_or(false)
}

fn recovery_dependent_handling(program: &ProgramSpec, blocker_class: &str) -> Option<String> {
    program
        .recovery_policy
        .recipes
        .iter()
        .find(|recipe| recovery_recipe_matches(recipe, blocker_class))
        .and_then(|recipe| recipe.dependent_handling.clone())
}

fn recovery_replan_after_attempt(program: &ProgramSpec, blocker_class: &str) -> bool {
    program
        .recovery_policy
        .recipes
        .iter()
        .find(|recipe| recovery_recipe_matches(recipe, blocker_class))
        .and_then(|recipe| recipe.replan_behavior.as_deref())
        .map(|behavior| behavior == "always" || behavior == "after-attempt")
        .or_else(|| {
            program
                .recovery_policy
                .handlers
                .get(blocker_class)
                .map(|handler| handler.replan_after_attempt)
        })
        .unwrap_or(false)
}

fn blocker_non_recoverable(blocker_class: &str) -> bool {
    classify_program_blocker_class(blocker_class) != ProgramBlockerDisposition::Recoverable
}

fn recovery_attempt_key(child_id: &str, blocker_class: &str) -> String {
    format!("{child_id}:{blocker_class}")
}

fn recovery_progress_key(child_id: &str, route_id: &str, blocker_class: &str) -> String {
    format!("{child_id}:{route_id}:{blocker_class}")
}

fn child_progress_fingerprint(
    state: &ProgramChildPlanState,
    route_id: &str,
    blocker_class: &str,
) -> ProgramRecoveryProgressFingerprint {
    ProgramRecoveryProgressFingerprint {
        child_id: state.child_id.clone(),
        route_id: route_id.to_string(),
        blocker_class: blocker_class.to_string(),
        final_verdict: state.final_verdict.clone(),
        terminal_outcome: state.terminal_outcome.clone(),
        gate_status: state.gate_status.clone(),
        receipt_digests: state.receipt_digests.clone(),
        selected_route_id: state
            .selected_route
            .as_ref()
            .map(|route| route.route_id.clone()),
    }
}

fn recovery_attempt_count(
    checkpoint: &ProgramLifecycleCheckpoint,
    child_id: &str,
    blocker_class: &str,
) -> u32 {
    checkpoint
        .recovery_attempts
        .get(&recovery_attempt_key(child_id, blocker_class))
        .copied()
        .unwrap_or(0)
}

fn program_recovery_action_attempt_key(blocker_class: &str, action_id: &str) -> String {
    format!("{blocker_class}:{action_id}")
}

fn program_recovery_action_attempt_count(
    checkpoint: Option<&ProgramLifecycleCheckpoint>,
    blocker_class: &str,
    action_id: &str,
) -> u32 {
    checkpoint
        .and_then(|checkpoint| {
            checkpoint
                .program_recovery_action_attempts
                .get(&program_recovery_action_attempt_key(
                    blocker_class,
                    action_id,
                ))
                .copied()
        })
        .unwrap_or(0)
}

fn validate_recovery_recipe(
    program: &ProgramSpec,
    blocker_class: &str,
    state: &ProgramChildPlanState,
) -> Result<()> {
    validate_child_recovery_recipe(program, blocker_class, state)
}

fn validate_child_recovery_recipe(
    program: &ProgramSpec,
    blocker_class: &str,
    state: &ProgramChildPlanState,
) -> Result<()> {
    let Some(recipe) = program
        .recovery_policy
        .recipes
        .iter()
        .find(|recipe| recovery_recipe_matches(recipe, blocker_class))
    else {
        return Ok(());
    };
    validate_recovery_recipe_metadata(recipe, blocker_class, false)?;
    for precondition in &recipe.preconditions {
        match precondition.as_str() {
            "live-state-readable" => {}
            "selected-route-present" => {
                if state.selected_route.is_none() {
                    bail!("recovery recipe precondition selected-route-present failed");
                }
            }
            "receipt-stale" => {
                if blocker_class != "stale-receipt" {
                    bail!("recovery recipe precondition receipt-stale mismatched blocker class");
                }
            }
            "missing-evidence" => {
                if blocker_class != "missing-evidence" {
                    bail!("recovery recipe precondition missing-evidence mismatched blocker class");
                }
            }
            "target-path-unchanged"
            | "write-scope-unchanged"
            | "current-run-child-owned-drift-evidence"
            | "authority-zone-allowed"
            | "artifact-ownership-known"
            | "declared-write-scope-contained"
            | "run-bound-current"
            | "source-authority-digest-unchanged"
            | "generated-non-authority" => {}
            "approval-grant-present" => {
                bail!("recovery recipe precondition approval-grant-present is not automatically recoverable");
            }
            other => bail!("unsupported recovery recipe precondition: {other}"),
        }
    }
    Ok(())
}

fn validate_program_recovery_recipe(
    contract: &LifecycleContract,
    program: &ProgramSpec,
    blocker: &ProgramBlocker,
    selected_route: &RoutePlanState,
) -> Result<ProgramRecoveryRecipeValidationEvidence> {
    let blocker_class = blocker.blocker_class.as_str();
    let route_id = recovery_route_for_blocker(program, blocker)
        .with_context(|| format!("program recovery route missing for {blocker_class}"))?;
    if route_id != selected_route.route_id {
        bail!(
            "selected program recovery route {} does not match declared route {route_id}",
            selected_route.route_id
        );
    }
    route_by_id(contract, route_id).with_context(|| {
        format!("program recovery route {route_id} is missing from program lifecycle contract")
    })?;
    let recipe = recovery_recipe_for_blocker(program, blocker_class)
        .with_context(|| format!("program recovery recipe missing for {blocker_class}"))?;
    validate_recovery_recipe_metadata(recipe, blocker_class, true)?;
    for precondition in &recipe.preconditions {
        match precondition.as_str() {
            "live-state-readable" => {}
            "selected-route-present" => {}
            "receipt-stale" => {
                if blocker_class != "stale-receipt" {
                    bail!("program recovery recipe precondition receipt-stale mismatched blocker class");
                }
            }
            "missing-evidence" => {
                if blocker_class != "missing-evidence" {
                    bail!(
                        "program recovery recipe precondition missing-evidence mismatched blocker class"
                    );
                }
            }
            "target-path-unchanged"
            | "write-scope-unchanged"
            | "current-run-child-owned-drift-evidence"
            | "authority-zone-allowed"
            | "artifact-ownership-known"
            | "declared-write-scope-contained"
            | "run-bound-current"
            | "source-authority-digest-unchanged"
            | "generated-non-authority" => {}
            "approval-grant-present" => {
                bail!(
                    "program recovery recipe precondition approval-grant-present is not automatically recoverable"
                );
            }
            other => bail!("unsupported program recovery recipe precondition: {other}"),
        }
    }
    let delegation_contract_basis =
        program_repair_delegation_contract_basis(program, blocker_class).with_context(|| {
            format!("program recovery recipe for {blocker_class} has no safe unattended basis")
        })?;
    if classify_program_blocker_class(blocker_class) == ProgramBlockerDisposition::Unsafe
        && !delegated_replay_class(recipe.idempotency_class.as_deref().unwrap_or(""))
    {
        bail!("program unsafe repair for {blocker_class} is not safe for unattended execution");
    }
    Ok(ProgramRecoveryRecipeValidationEvidence::passed(
        blocker_class,
        route_id,
        &delegation_contract_basis,
    ))
}

fn validate_recovery_recipe_metadata(
    recipe: &ProgramRecoveryRecipeSpec,
    blocker_class: &str,
    require_post_attempt_validation: bool,
) -> Result<()> {
    if recipe
        .idempotency_class
        .as_deref()
        .map(|class| matches!(class, "non-idempotent" | "unsafe" | "non-recoverable"))
        .unwrap_or(false)
    {
        bail!(
            "recovery recipe for {blocker_class} is not executable because it is non-idempotent, unsafe, or non-recoverable"
        );
    }
    if require_post_attempt_validation && recipe.post_attempt_validation.is_empty() {
        bail!("program recovery recipe for {blocker_class} must declare post_attempt_validation");
    }
    if recipe.requires_zone_evidence
        && (recipe.allowed_authority_zones.is_empty() || recipe.operation_class.is_none())
    {
        bail!("recovery recipe for {blocker_class} requires zone evidence but does not declare authority-zone dispatch metadata");
    }
    for validation in &recipe.post_attempt_validation {
        if !supported_recovery_post_attempt_validation(validation) {
            bail!("unsupported recovery recipe post-attempt validation: {validation}");
        }
    }
    if let Some(dependent_handling) = recipe.dependent_handling.as_deref() {
        if !matches!(
            dependent_handling,
            "block-dependents"
                | "continue-independent"
                | "pause-dependent"
                | "pause-phase"
                | "pause-barrier"
                | "fail-closed"
        ) {
            bail!("unsupported recovery dependent_handling: {dependent_handling}");
        }
    }
    if let Some(replan_behavior) = recipe.replan_behavior.as_deref() {
        if !matches!(replan_behavior, "none" | "after-attempt" | "always") {
            bail!("unsupported recovery replan_behavior: {replan_behavior}");
        }
    }
    if let Some(action_id) = recipe.recovery_action_id.as_deref() {
        if !supported_program_recovery_action(action_id) {
            bail!("unsupported recovery_action_id: {action_id}");
        }
    }
    for zone in &recipe.allowed_authority_zones {
        if !supported_authority_zone(zone) {
            bail!("unsupported recovery authority zone: {zone}");
        }
        if !recipe.human_required
            && matches!(
                zone.as_str(),
                AUTHORITY_ZONE_AUTHORED_GOVERNANCE | AUTHORITY_ZONE_PROTECTED_OR_EXTERNAL
            )
        {
            bail!("approval-free recovery recipe for {blocker_class} allows protected authority zone {zone}");
        }
    }
    for artifact_class in &recipe.allowed_artifact_classes {
        if !supported_authority_artifact_class(artifact_class) {
            bail!("unsupported recovery authority artifact class: {artifact_class}");
        }
        if !recipe.human_required
            && matches!(
                artifact_class.as_str(),
                ARTIFACT_CLASS_AUTHORED_GOVERNANCE
                    | ARTIFACT_CLASS_PROTECTED_OR_EXTERNAL
                    | ARTIFACT_CLASS_UNKNOWN
            )
        {
            bail!("approval-free recovery recipe for {blocker_class} allows protected artifact class {artifact_class}");
        }
    }
    if let Some(operation_class) = recipe.operation_class.as_deref() {
        if !supported_authority_operation_class(operation_class) {
            bail!("unsupported recovery authority operation class: {operation_class}");
        }
        if !recipe.human_required
            && matches!(
                operation_class,
                "durable-authority-mutation" | "protected-artifact-mutation"
            )
        {
            bail!("approval-free recovery recipe for {blocker_class} allows protected operation class {operation_class}");
        }
    }
    for zone in &recipe.human_required_for_zones {
        if !supported_authority_zone(zone) {
            bail!("unsupported authority-ambiguity authority zone: {zone}");
        }
    }
    Ok(())
}

fn supported_program_recovery_action(action_id: &str) -> bool {
    matches!(
        action_id,
        REFRESH_PUBLICATION_PROJECTIONS_ACTION
            | REBASELINE_CHECKPOINT_ACTION
            | CLEANUP_CURRENT_RUN_ARTIFACTS_ACTION
    )
}

fn supported_authority_zone(zone: &str) -> bool {
    matches!(
        zone,
        AUTHORITY_ZONE_RUN_BOUND
            | AUTHORITY_ZONE_GENERATED_DERIVED
            | AUTHORITY_ZONE_AUTHORED_GOVERNANCE
            | AUTHORITY_ZONE_WORKSPACE_DECLARED
            | AUTHORITY_ZONE_CURRENT_RUN_AGENT_ARTIFACT
            | AUTHORITY_ZONE_PROTECTED_OR_EXTERNAL
    )
}

fn supported_authority_artifact_class(artifact_class: &str) -> bool {
    matches!(
        artifact_class,
        ARTIFACT_CLASS_RUN_CONTROL
            | ARTIFACT_CLASS_RUN_EVIDENCE
            | ARTIFACT_CLASS_GENERATED_DERIVED
            | ARTIFACT_CLASS_AUTHORED_GOVERNANCE
            | ARTIFACT_CLASS_WORKSPACE_SOURCE
            | ARTIFACT_CLASS_CURRENT_RUN_GENERATED
            | ARTIFACT_CLASS_PROTECTED_OR_EXTERNAL
            | ARTIFACT_CLASS_UNKNOWN
    )
}

fn supported_authority_operation_class(operation_class: &str) -> bool {
    matches!(
        operation_class,
        "inspect"
            | "append-run-evidence"
            | "update-run-control"
            | OPERATION_CLASS_REFRESH_GENERATED_PROJECTION
            | OPERATION_CLASS_CLEANUP_CURRENT_RUN_ARTIFACT
            | OPERATION_CLASS_RETRY_CHILD_ROUTE
            | OPERATION_CLASS_EXECUTE_CHILD_ROUTE
            | OPERATION_CLASS_PROGRAM_RECOVERY_ACTION
            | OPERATION_CLASS_CLOSEOUT_READINESS
            | "durable-authority-mutation"
            | "protected-artifact-mutation"
    )
}

fn supported_recovery_post_attempt_validation(validation: &str) -> bool {
    matches!(
        validation,
        "replan-live-state"
            | "receipt-fresh"
            | "receipt-freshness"
            | "blocker-cleared"
            | "replay-verify"
            | "authority-boundary-check"
            | "aggregate-closeout-check"
            | "publication-freshness-cleared"
    )
}

fn enforce_recovery_post_attempt_validations(
    program: &ProgramSpec,
    plan: &ProgramLifecyclePlanResult,
    control_root: &Path,
    live_replanned: bool,
    child_results: &mut [ProgramChildExecutionSummary],
) -> Result<()> {
    for result in child_results
        .iter_mut()
        .filter(|result| result.blocker_class.is_some())
    {
        let blocker_class = result.blocker_class.clone().unwrap_or_default();
        let validations = recovery_post_attempt_validations(program, &blocker_class);
        if validations.is_empty() || result.status != "completed" {
            continue;
        }
        if recovery_replan_after_attempt(program, &blocker_class) && !live_replanned {
            result.status = "failed".to_string();
            result.retryable = true;
            result.error_message = Some(format!(
                "recovery post-attempt validation failed for {blocker_class}: declared replan_behavior was not satisfied"
            ));
            continue;
        }
        let Some(state) = plan.child_states.get(&result.child_id) else {
            result.status = "failed".to_string();
            result.retryable = true;
            result.error_message = Some(format!(
                "recovery post-attempt validation failed for {blocker_class}: child missing after live replan"
            ));
            continue;
        };
        if closeout_recovery_blocked_by_worktree(result, &blocker_class, state) {
            result.status = "blocked".to_string();
            result.retryable = false;
            result.blocker_class = Some("artifact-ownership-unclear".to_string());
            result.error_message = Some(
                "closeout-packet wrote a blocked closeout receipt because worktree hygiene is blocked"
                    .to_string(),
            );
            continue;
        }
        let failed = validations.iter().find(|validation| {
            !recovery_post_attempt_validation_passed(
                validation,
                state,
                plan,
                control_root,
                live_replanned,
            )
        });
        if let Some(validation) = failed {
            result.status = "failed".to_string();
            result.retryable = true;
            result.error_message = Some(format!(
                "recovery post-attempt validation failed for {blocker_class}: {validation}"
            ));
        }
    }
    Ok(())
}

fn closeout_recovery_blocked_by_worktree(
    result: &ProgramChildExecutionSummary,
    blocker_class: &str,
    state: &ProgramChildPlanState,
) -> bool {
    result.route_id == "closeout-packet"
        && blocker_class == "stale-receipt"
        && state.blockers.iter().any(|blocker| {
            matches!(
                blocker.blocker_class.as_str(),
                "worktree-hygiene-blocked" | "artifact-ownership-unclear"
            )
        })
}

fn recovery_post_attempt_validations(program: &ProgramSpec, blocker_class: &str) -> Vec<String> {
    program
        .recovery_policy
        .recipes
        .iter()
        .find(|recipe| recovery_recipe_matches(recipe, blocker_class))
        .map(|recipe| recipe.post_attempt_validation.clone())
        .unwrap_or_default()
}

fn recovery_post_attempt_validation_passed(
    validation: &str,
    state: &ProgramChildPlanState,
    plan: &ProgramLifecyclePlanResult,
    control_root: &Path,
    live_replanned: bool,
) -> bool {
    match validation {
        "replan-live-state" => live_replanned,
        "receipt-fresh" | "receipt-freshness" => {
            !state.blockers.iter().any(|blocker| {
                matches!(
                    blocker.blocker_class.as_str(),
                    "stale-receipt" | "missing-evidence"
                )
            }) && !state.receipt_digests.is_empty()
        }
        "blocker-cleared" => state.blockers.is_empty(),
        "authority-boundary-check" => {
            !state
                .blockers
                .iter()
                .any(|blocker| blocker.blocker_class == "authority-boundary-ambiguous")
                && !plan
                    .program_blockers
                    .iter()
                    .any(|blocker| blocker.blocker_class == "authority-boundary-ambiguous")
        }
        "aggregate-closeout-check" => {
            plan.aggregate_state != "completed" || plan.final_verdict == "completed"
        }
        "publication-freshness-cleared" => !state
            .blockers
            .iter()
            .any(|blocker| blocker.blocker_class == "publication-drift"),
        "replay-verify" => verify_program_event_log_for_recovery(control_root).is_ok(),
        _ => false,
    }
}

fn enforce_program_recovery_post_attempt_validations(
    program: &ProgramSpec,
    _before_plan: &ProgramLifecyclePlanResult,
    after_plan: &ProgramLifecyclePlanResult,
    control_root: &Path,
    blocker_class: &str,
    result: &LifecycleRouteExecutionResult,
    live_replanned: bool,
) -> ProgramRecoveryPostAttemptValidationOutcome {
    if !matches!(result.status.as_str(), "completed" | "no-op") {
        return ProgramRecoveryPostAttemptValidationOutcome::route_not_completed(
            &result.status,
            result.error_message.as_deref(),
            Some(blocker_class.to_string()),
        );
    }
    let declared = recovery_post_attempt_validations(program, blocker_class);
    if declared.is_empty() {
        return ProgramRecoveryPostAttemptValidationOutcome {
            status: "failed".to_string(),
            failures: vec![format!(
                "program recovery recipe for {blocker_class} declared no post_attempt_validation"
            )],
            declared,
            results: Vec::new(),
            execution_can_resume: false,
            resume_decision_basis:
                "program repair cannot resume without declared post-attempt validation".to_string(),
            final_blocker_class: Some(blocker_class.to_string()),
        };
    }

    let mut failures = Vec::new();
    let mut results = Vec::new();
    for validation in &declared {
        match program_recovery_post_attempt_validation_result(
            validation,
            after_plan,
            control_root,
            blocker_class,
            live_replanned,
        ) {
            Ok(()) => results.push(format!("{validation}: pass")),
            Err(error) => {
                results.push(format!("{validation}: fail: {error}"));
                failures.push(format!("{validation}: {error}"));
            }
        }
    }
    if failures.is_empty() {
        ProgramRecoveryPostAttemptValidationOutcome {
            status: "passed".to_string(),
            failures,
            declared,
            results,
            execution_can_resume: true,
            resume_decision_basis:
                "repair route completed and all declared program post-attempt validations passed"
                    .to_string(),
            final_blocker_class: None,
        }
    } else {
        ProgramRecoveryPostAttemptValidationOutcome {
            status: "failed".to_string(),
            failures,
            declared,
            results,
            execution_can_resume: false,
            resume_decision_basis:
                "program repair route completed but declared post-attempt validation failed"
                    .to_string(),
            final_blocker_class: Some(blocker_class.to_string()),
        }
    }
}

fn program_recovery_post_attempt_validation_result(
    validation: &str,
    after_plan: &ProgramLifecyclePlanResult,
    control_root: &Path,
    blocker_class: &str,
    live_replanned: bool,
) -> std::result::Result<(), String> {
    match validation {
        "replan-live-state" => live_replanned
            .then_some(())
            .ok_or_else(|| "live replan did not run after program repair".to_string()),
        "blocker-cleared" => {
            let remaining_same_blocker = after_plan
                .program_blockers
                .iter()
                .any(|blocker| blocker.blocker_class == blocker_class);
            (!remaining_same_blocker)
                .then_some(())
                .ok_or_else(|| format!("program blocker {blocker_class} remains after repair"))
        }
        "authority-boundary-check" => {
            let remaining = after_plan.program_blockers.iter().find(|blocker| {
                matches!(
                    classify_program_blocker_class(&blocker.blocker_class),
                    ProgramBlockerDisposition::Unsafe | ProgramBlockerDisposition::Human
                )
            });
            remaining.is_none().then_some(()).ok_or_else(|| {
                format!(
                    "program authority or unsafe blocker remains after repair: {}",
                    remaining
                        .map(|blocker| blocker.blocker_class.as_str())
                        .unwrap_or("unknown")
                )
            })
        }
        "aggregate-closeout-check" => (after_plan.aggregate_state != "completed"
            || after_plan.final_verdict == "completed")
            .then_some(())
            .ok_or_else(|| {
                "aggregate state is completed without completed final verdict".to_string()
            }),
        "publication-freshness-cleared" => {
            let remaining_program = after_plan
                .program_blockers
                .iter()
                .any(|blocker| blocker.blocker_class == "publication-drift");
            if remaining_program {
                return Err("program publication-drift blocker remains after repair".to_string());
            }
            if !after_plan.child_states.values().any(|state| {
                state
                    .blockers
                    .iter()
                    .any(|blocker| blocker.blocker_class == "publication-drift")
            }) {
                return Ok(());
            }
            (blocker_class == "publication-drift"
                && remaining_publication_drift_is_limited_to_rerunnable_children(after_plan))
            .then_some(())
            .ok_or_else(|| {
                "publication-drift blocker remains after repair without a selected child recovery route"
                    .to_string()
            })
        }
        "replay-verify" => {
            verify_program_event_log_for_recovery(control_root).map_err(|error| error.to_string())
        }
        "receipt-fresh" | "receipt-freshness" => {
            Err("program-scope receipt freshness validation has no explicit source".to_string())
        }
        other => Err(format!(
            "unsupported program post-attempt validation {other}"
        )),
    }
}

fn remaining_publication_drift_is_limited_to_rerunnable_children(
    after_plan: &ProgramLifecyclePlanResult,
) -> bool {
    let mut saw_publication_drift = false;
    for state in after_plan.child_states.values() {
        for blocker in state
            .blockers
            .iter()
            .filter(|blocker| blocker.blocker_class == "publication-drift")
        {
            saw_publication_drift = true;
            let selected_route = state
                .selected_route
                .as_ref()
                .map(|route| route.route_id.as_str());
            if selected_route.is_none()
                || blocker.recovery_route.as_deref() != selected_route
                || !after_plan
                    .runnable_batch
                    .iter()
                    .any(|id| id == &state.child_id)
            {
                return false;
            }
        }
    }
    saw_publication_drift
}

fn verify_program_event_log_for_recovery(control_root: &Path) -> Result<()> {
    let events = read_program_events(control_root)?;
    let mut errors = Vec::new();
    let legacy_event_log = events
        .iter()
        .any(|event| event.schema_version == "octon-program-lifecycle-event-v1");
    if legacy_event_log {
        errors.push("legacy event log is not replay-verifiable for recovery".to_string());
    }
    if events.is_empty() {
        errors.push("missing event log entries".to_string());
    }
    validate_event_offsets(&events, &mut errors);
    validate_event_hash_chain(&events, legacy_event_log, &mut errors)?;
    validate_program_event_transitions(&events, &mut errors);
    if errors.is_empty() {
        Ok(())
    } else {
        bail!(
            "program recovery replay verification failed: {}",
            errors.join("; ")
        );
    }
}

fn select_program_recovery_action<'a>(
    program: &'a ProgramSpec,
    plan: &'a ProgramLifecyclePlanResult,
    checkpoint: Option<&ProgramLifecycleCheckpoint>,
) -> Option<(&'a str, &'a str)> {
    for blocker in &plan.program_blockers {
        let Some(action_id) = recovery_action_id(program, &blocker.blocker_class) else {
            continue;
        };
        let budget = recovery_attempt_budget(program, &blocker.blocker_class)
            .or(program.recovery_policy.max_recovery_attempts)
            .unwrap_or(1);
        let used =
            program_recovery_action_attempt_count(checkpoint, &blocker.blocker_class, action_id);
        if used < budget {
            return Some((blocker.blocker_class.as_str(), action_id.as_str()));
        }
    }
    for state in plan.child_states.values() {
        for blocker in &state.blockers {
            let Some(action_id) = recovery_action_id(program, &blocker.blocker_class) else {
                continue;
            };
            let budget = recovery_attempt_budget(program, &blocker.blocker_class)
                .or(program.recovery_policy.max_recovery_attempts)
                .unwrap_or(1);
            let used = program_recovery_action_attempt_count(
                checkpoint,
                &blocker.blocker_class,
                action_id,
            );
            if used < budget {
                return Some((blocker.blocker_class.as_str(), action_id.as_str()));
            }
        }
    }
    None
}

fn execute_selected_program_recovery_action(
    program: &ProgramSpec,
    plan: &ProgramLifecyclePlanResult,
    previous_checkpoint: Option<&ProgramLifecycleCheckpoint>,
    program_recovery_action_attempts: &mut BTreeMap<String, u32>,
    repo_root: &Path,
    control_root: &Path,
    evidence_root: &Path,
    program_run_id: &str,
    step_context: Option<ProgramExecutionStepContext>,
) -> Result<Option<ProgramRecoveryActionOutcome>> {
    let Some((blocker_class, action_id)) =
        select_program_recovery_action(program, plan, previous_checkpoint)
    else {
        return Ok(None);
    };
    let key = program_recovery_action_attempt_key(blocker_class, action_id);
    let attempt_number = program_recovery_action_attempts
        .get(&key)
        .copied()
        .unwrap_or(0)
        + 1;
    let outcome = execute_program_recovery_action(
        program,
        repo_root,
        control_root,
        evidence_root,
        program_run_id,
        blocker_class,
        action_id,
        attempt_number,
        step_context,
    )?;
    *program_recovery_action_attempts.entry(key).or_default() += 1;
    Ok(Some(outcome))
}

fn authority_paths_for_program_recovery_action(
    repo_root: &Path,
    evidence_root: &Path,
    program_run_id: &str,
    action_id: &str,
) -> (Vec<PathBuf>, Vec<String>, &'static str) {
    match action_id {
        REFRESH_PUBLICATION_PROJECTIONS_ACTION => (
            vec![
                repo_root.join(".octon/generated"),
                repo_root.join(".claude"),
                repo_root.join(".cursor"),
                repo_root.join(".codex/commands"),
                repo_root.join(".codex/skills"),
            ],
            Vec::new(),
            OPERATION_CLASS_REFRESH_GENERATED_PROJECTION,
        ),
        REBASELINE_CHECKPOINT_ACTION => (
            vec![evidence_root.to_path_buf()],
            Vec::new(),
            OPERATION_CLASS_PROGRAM_RECOVERY_ACTION,
        ),
        CLEANUP_CURRENT_RUN_ARTIFACTS_ACTION => {
            let run_control = repo_root
                .join(".octon/state/control/execution/runs")
                .join(program_run_id);
            (
                vec![
                    run_control.join("locks"),
                    run_control.join("tmp"),
                    run_control.join("scratch"),
                ],
                vec![authority_path_ref(repo_root, &run_control)],
                OPERATION_CLASS_CLEANUP_CURRENT_RUN_ARTIFACT,
            )
        }
        _ => (
            vec![evidence_root.to_path_buf()],
            Vec::new(),
            OPERATION_CLASS_PROGRAM_RECOVERY_ACTION,
        ),
    }
}

fn mark_no_progress_child_results(
    before_plan: &ProgramLifecyclePlanResult,
    after_plan: &ProgramLifecyclePlanResult,
    child_results: &mut [ProgramChildExecutionSummary],
    control_root: &Path,
    evidence_root: &Path,
    program_run_id: &str,
    step_context: Option<ProgramExecutionStepContext>,
) -> Result<Vec<String>> {
    let mut no_progress_blockers = Vec::new();
    for result in child_results.iter_mut() {
        if !matches!(result.status.as_str(), "completed" | "no-op") {
            continue;
        }
        let Some(blocker_class) = result.blocker_class.as_deref() else {
            continue;
        };
        let Some(before_state) = before_plan.child_states.get(&result.child_id) else {
            continue;
        };
        let Some(after_state) = after_plan.child_states.get(&result.child_id) else {
            continue;
        };
        let before = child_progress_fingerprint(before_state, &result.route_id, blocker_class);
        let after = child_progress_fingerprint(after_state, &result.route_id, blocker_class);
        if before != after {
            continue;
        }
        append_program_event(
            control_root,
            evidence_root,
            program_run_id,
            "child-route-no-progress",
            Some(&result.child_id),
            Some(&result.route_id),
            "child route completed without advancing child lifecycle progress",
            program_step_event_data(
                step_context.as_ref(),
                "child-batch-dispatch",
                [
                    ("blocker_class", blocker_class),
                    ("route_id", result.route_id.as_str()),
                ],
            ),
        )?;
        no_progress_blockers.push(blocker_class.to_string());
        result.status = "blocked".to_string();
        result.retryable = false;
        result.error_message = Some(format!(
            "route completed but child lifecycle progress did not change for blocker {blocker_class}"
        ));
    }
    no_progress_blockers.sort();
    no_progress_blockers.dedup();
    Ok(no_progress_blockers)
}

fn record_program_recovery_action_failure(
    plan: &mut ProgramLifecyclePlanResult,
    final_verdict: &mut String,
    terminal_outcome: &mut Option<String>,
    outcome: &ProgramRecoveryActionOutcome,
) {
    *final_verdict = "blocked-recoverable".to_string();
    *terminal_outcome = None;
    plan.final_verdict = final_verdict.clone();
    plan.terminal_outcome = None;
    plan.stop_reason = Some(format!(
        "program recovery action {} for {} failed at command {} (evidence: {}): {}",
        outcome.action_id,
        outcome.blocker_class,
        outcome.failed_command.as_deref().unwrap_or("unknown"),
        outcome.evidence_path,
        outcome
            .error_message
            .as_deref()
            .unwrap_or("no error message")
    ));
}

fn enforce_program_recovery_action_post_validations(
    repo_root: &Path,
    program: &ProgramSpec,
    after_plan: &ProgramLifecyclePlanResult,
    control_root: &Path,
    evidence_root: &Path,
    program_run_id: &str,
    outcome: &ProgramRecoveryActionOutcome,
    step_context: Option<ProgramExecutionStepContext>,
) -> Result<Option<ProgramRecoveryActionOutcome>> {
    let declared = recovery_post_attempt_validations(program, &outcome.blocker_class);
    let mut failures = Vec::new();
    if declared.is_empty() {
        failures.push(format!(
            "program recovery recipe for {} declared no post_attempt_validation",
            outcome.blocker_class
        ));
    }
    for validation in &declared {
        if let Err(error) = program_recovery_post_attempt_validation_result(
            validation,
            after_plan,
            control_root,
            &outcome.blocker_class,
            true,
        ) {
            failures.push(format!("{validation}: {error}"));
        }
    }
    if failures.is_empty() {
        return Ok(None);
    }
    let message = failures.join("; ");
    let failed_command = "post-validation";
    append_program_event(
        control_root,
        evidence_root,
        program_run_id,
        "program-recovery-action-validation-failed",
        None,
        Some(&outcome.action_id),
        "program recovery action post-validation failed",
        program_step_event_data(
            step_context.as_ref(),
            "program-recovery-action",
            [
                ("blocker_class", outcome.blocker_class.as_str()),
                ("action_id", outcome.action_id.as_str()),
                ("failed_command", failed_command),
                ("evidence_path", outcome.evidence_path.as_str()),
            ],
        ),
    )?;
    let action_root = if Path::new(&outcome.evidence_path).is_absolute() {
        PathBuf::from(&outcome.evidence_path)
    } else {
        repo_root.join(&outcome.evidence_path)
    };
    write_program_recovery_action_summary(
        repo_root,
        &action_root,
        &outcome.action_id,
        &outcome.blocker_class,
        "failed",
        Some(failed_command),
        Some(&message),
    )?;
    Ok(Some(ProgramRecoveryActionOutcome {
        action_id: outcome.action_id.clone(),
        blocker_class: outcome.blocker_class.clone(),
        status: "failed".to_string(),
        evidence_path: outcome.evidence_path.clone(),
        failed_command: Some(failed_command.to_string()),
        error_message: Some(message),
    }))
}

fn execute_program_recovery_action(
    program: &ProgramSpec,
    repo_root: &Path,
    control_root: &Path,
    evidence_root: &Path,
    program_run_id: &str,
    blocker_class: &str,
    action_id: &str,
    attempt_number: u32,
    step_context: Option<ProgramExecutionStepContext>,
) -> Result<ProgramRecoveryActionOutcome> {
    if !supported_program_recovery_action(action_id) {
        bail!("unsupported program recovery action: {action_id}");
    }
    let octon_dir = repo_root.join(".octon");
    let action_root = evidence_root
        .join("program-recovery-actions")
        .join(action_id)
        .join(format!("attempt-{attempt_number}"));
    fs::create_dir_all(&action_root)?;
    let (authority_paths, declared_write_scopes, operation_class) =
        authority_paths_for_program_recovery_action(
            repo_root,
            evidence_root,
            program_run_id,
            action_id,
        );
    let authority_decision = classify_authority_zone(
        repo_root,
        program_run_id,
        None,
        Some(action_id),
        Some(blocker_class),
        operation_class,
        &authority_paths,
        &declared_write_scopes,
        None,
    );
    let authority_decision_path =
        write_authority_zone_decision(evidence_root, &authority_decision)?;
    let recipe = recovery_recipe_for_blocker(program, blocker_class);
    if !authority_decision.autonomous_allowed
        || !recovery_recipe_allows_authority_decision(recipe, &authority_decision)
    {
        let evidence_path = rel_display(repo_root, &action_root);
        let message = format!(
            "program recovery action {action_id} denied by authority zone {} for artifact class {}; decision evidence: {authority_decision_path}",
            authority_decision.authority_zone, authority_decision.artifact_class
        );
        append_program_event(
            control_root,
            evidence_root,
            program_run_id,
            "program-recovery-action-authority-blocked",
            None,
            Some(action_id),
            "program recovery action blocked by authority-zone decision",
            program_step_event_data(
                step_context.as_ref(),
                "program-recovery-action",
                [
                    ("blocker_class", blocker_class),
                    ("action_id", action_id),
                    ("authority_zone", authority_decision.authority_zone.as_str()),
                    ("artifact_class", authority_decision.artifact_class.as_str()),
                    ("authority_decision", authority_decision_path.as_str()),
                ],
            ),
        )?;
        write_program_recovery_action_summary(
            repo_root,
            &action_root,
            action_id,
            blocker_class,
            "failed",
            Some(authority_decision.fail_closed_blocker.as_str()),
            Some(&message),
        )?;
        return Ok(ProgramRecoveryActionOutcome {
            action_id: action_id.to_string(),
            blocker_class: authority_decision.fail_closed_blocker,
            status: "failed".to_string(),
            evidence_path,
            failed_command: Some("authority-zone-decision".to_string()),
            error_message: Some(message),
        });
    }
    append_program_event(
        control_root,
        evidence_root,
        program_run_id,
        "program-recovery-action-started",
        None,
        Some(action_id),
        "program recovery action started",
        program_step_event_data(
            step_context.as_ref(),
            "program-recovery-action",
            [("blocker_class", blocker_class), ("action_id", action_id)],
        ),
    )?;

    if action_id == REBASELINE_CHECKPOINT_ACTION {
        let evidence_path = rel_display(repo_root, &action_root);
        fs::write(
            action_root.join("rebaseline-summary.yml"),
            format!(
                "schema_version: \"octon-program-rebaseline-checkpoint-v1\"\naction_id: \"{action_id}\"\nblocker_class: \"{blocker_class}\"\nstatus: \"completed\"\nreplan_required: true\n"
            ),
        )?;
        append_program_event(
            control_root,
            evidence_root,
            program_run_id,
            "program-recovery-action-finished",
            None,
            Some(action_id),
            "program recovery action finished",
            program_step_event_data(
                step_context.as_ref(),
                "program-recovery-action",
                [
                    ("blocker_class", blocker_class),
                    ("action_id", action_id),
                    ("status", "completed"),
                    ("evidence_path", evidence_path.as_str()),
                ],
            ),
        )?;
        write_program_recovery_action_summary(
            repo_root,
            &action_root,
            action_id,
            blocker_class,
            "completed",
            None,
            None,
        )?;
        return Ok(ProgramRecoveryActionOutcome {
            action_id: action_id.to_string(),
            blocker_class: blocker_class.to_string(),
            status: "completed".to_string(),
            evidence_path,
            failed_command: None,
            error_message: None,
        });
    }

    if action_id == CLEANUP_CURRENT_RUN_ARTIFACTS_ACTION {
        let evidence_path = rel_display(repo_root, &action_root);
        fs::write(
            action_root.join("cleanup-current-run-artifacts.yml"),
            format!(
                "schema_version: \"octon-program-current-run-cleanup-v1\"\naction_id: \"{action_id}\"\nblocker_class: \"{blocker_class}\"\nstatus: \"completed\"\nmutation_performed: false\nrationale: \"current-run artifact cleanup is executed through governed artifact cleanup operations; no standalone cleanup operation was selected by the blocker\"\nreplan_required: true\n"
            ),
        )?;
        append_program_event(
            control_root,
            evidence_root,
            program_run_id,
            "program-recovery-action-finished",
            None,
            Some(action_id),
            "program recovery action finished",
            program_step_event_data(
                step_context.as_ref(),
                "program-recovery-action",
                [
                    ("blocker_class", blocker_class),
                    ("action_id", action_id),
                    ("status", "completed"),
                    ("evidence_path", evidence_path.as_str()),
                ],
            ),
        )?;
        write_program_recovery_action_summary(
            repo_root,
            &action_root,
            action_id,
            blocker_class,
            "completed",
            None,
            None,
        )?;
        return Ok(ProgramRecoveryActionOutcome {
            action_id: action_id.to_string(),
            blocker_class: blocker_class.to_string(),
            status: "completed".to_string(),
            evidence_path,
            failed_command: None,
            error_message: None,
        });
    }

    let commands: Vec<(&str, Vec<String>, Vec<(&str, String)>)> = vec![
        (
            "generate-support-envelope-reconciliation",
            vec![
                ".octon/framework/assurance/runtime/_ops/scripts/generate-support-envelope-reconciliation.sh".to_string(),
            ],
            Vec::new(),
        ),
        (
            "generate-run-health-read-model",
            vec![
                ".octon/framework/assurance/runtime/_ops/scripts/generate-run-health-read-model.sh".to_string(),
                "--all-runs".to_string(),
                "--evidence-root".to_string(),
                action_root.join("run-health").to_string_lossy().to_string(),
            ],
            Vec::new(),
        ),
        (
            "validate-support-envelope-reconciliation",
            vec![
                ".octon/framework/assurance/runtime/_ops/scripts/validate-support-envelope-reconciliation.sh".to_string(),
            ],
            vec![(
                "OCTON_SUPPORT_ENVELOPE_EVIDENCE_DIR",
                action_root
                    .join("support-envelope-validation")
                    .to_string_lossy()
                    .to_string(),
            )],
        ),
        (
            "validate-run-health-read-model",
            vec![
                ".octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh".to_string(),
            ],
            Vec::new(),
        ),
        (
            "validate-architecture-conformance",
            vec![
                ".octon/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh".to_string(),
            ],
            Vec::new(),
        ),
    ];

    for (index, (command_id, argv, extra_env)) in commands.iter().enumerate() {
        let command_index = index + 1;
        let stdout_path = action_root.join(format!("{command_index:02}-{command_id}.stdout.log"));
        let stderr_path = action_root.join(format!("{command_index:02}-{command_id}.stderr.log"));
        let result_path = action_root.join(format!("{command_index:02}-{command_id}.result.yml"));
        let output = run_program_recovery_command(
            repo_root,
            &octon_dir,
            argv,
            extra_env,
            &stdout_path,
            &stderr_path,
        )?;
        let exit_code = output.status.code().unwrap_or(-1).to_string();
        let status = if output.status.success() {
            "completed"
        } else {
            "failed"
        };
        fs::write(
            &result_path,
            format!(
                "schema_version: \"octon-program-recovery-action-command-v1\"\naction_id: \"{action_id}\"\nblocker_class: \"{blocker_class}\"\ncommand_id: \"{command_id}\"\nstatus: \"{status}\"\nexit_code: {exit_code}\nstdout_path: \"{}\"\nstderr_path: \"{}\"\n",
                rel_display(repo_root, &stdout_path),
                rel_display(repo_root, &stderr_path)
            ),
        )?;
        if !output.status.success() {
            let message =
                format!("program recovery action {action_id} failed at command {command_id}");
            let evidence_path = rel_display(repo_root, &action_root);
            append_program_event(
                control_root,
                evidence_root,
                program_run_id,
                "program-recovery-action-validation-failed",
                None,
                Some(action_id),
                "program recovery action validation failed",
                program_step_event_data(
                    step_context.as_ref(),
                    "program-recovery-action",
                    [
                        ("blocker_class", blocker_class),
                        ("action_id", action_id),
                        ("failed_command", command_id),
                        ("evidence_path", evidence_path.as_str()),
                    ],
                ),
            )?;
            append_program_event(
                control_root,
                evidence_root,
                program_run_id,
                "program-recovery-action-finished",
                None,
                Some(action_id),
                "program recovery action finished with failure",
                program_step_event_data(
                    step_context.as_ref(),
                    "program-recovery-action",
                    [
                        ("blocker_class", blocker_class),
                        ("action_id", action_id),
                        ("status", "failed"),
                        ("failed_command", command_id),
                        ("evidence_path", evidence_path.as_str()),
                    ],
                ),
            )?;
            write_program_recovery_action_summary(
                repo_root,
                &action_root,
                action_id,
                blocker_class,
                "failed",
                Some(command_id),
                Some(&message),
            )?;
            return Ok(ProgramRecoveryActionOutcome {
                action_id: action_id.to_string(),
                blocker_class: blocker_class.to_string(),
                status: "failed".to_string(),
                evidence_path,
                failed_command: Some(command_id.to_string()),
                error_message: Some(message),
            });
        }
    }

    write_program_recovery_changed_paths(repo_root, &action_root)?;
    append_program_event(
        control_root,
        evidence_root,
        program_run_id,
        "program-recovery-action-finished",
        None,
        Some(action_id),
        "program recovery action finished",
        program_step_event_data(
            step_context.as_ref(),
            "program-recovery-action",
            [
                ("blocker_class", blocker_class),
                ("action_id", action_id),
                ("status", "completed"),
            ],
        ),
    )?;
    write_program_recovery_action_summary(
        repo_root,
        &action_root,
        action_id,
        blocker_class,
        "completed",
        None,
        None,
    )?;
    Ok(ProgramRecoveryActionOutcome {
        action_id: action_id.to_string(),
        blocker_class: blocker_class.to_string(),
        status: "completed".to_string(),
        evidence_path: rel_display(repo_root, &action_root),
        failed_command: None,
        error_message: None,
    })
}

fn run_program_recovery_command(
    repo_root: &Path,
    octon_dir: &Path,
    argv: &[String],
    extra_env: &Vec<(&str, String)>,
    stdout_path: &Path,
    stderr_path: &Path,
) -> Result<std::process::Output> {
    let (script, args) = argv
        .split_first()
        .context("program recovery command missing script")?;
    let mut command = Command::new("bash");
    command
        .arg(script)
        .args(args)
        .current_dir(repo_root)
        .env("OCTON_DIR_OVERRIDE", octon_dir)
        .env("OCTON_ROOT_DIR", repo_root);
    for (key, value) in extra_env {
        command.env(key, value);
    }
    let output = command.output()?;
    fs::write(stdout_path, &output.stdout)?;
    fs::write(stderr_path, &output.stderr)?;
    Ok(output)
}

fn write_program_recovery_changed_paths(repo_root: &Path, action_root: &Path) -> Result<()> {
    let output = Command::new("git")
        .arg("-C")
        .arg(repo_root)
        .arg("status")
        .arg("--short")
        .arg("--")
        .arg(".octon/generated")
        .arg(".octon/state/evidence/validation/runtime/governed-runtime-materialization-v1/run-health")
        .output()?;
    let stdout = String::from_utf8_lossy(&output.stdout);
    let changed_paths = stdout
        .lines()
        .filter(|line| {
            line.contains("support-envelope-reconciliation.yml")
                || line.contains(".octon/generated/cognition/projections/materialized/runs")
                || line.contains(
                    ".octon/state/evidence/validation/runtime/governed-runtime-materialization-v1/run-health",
                )
        })
        .collect::<Vec<_>>()
        .join("\n");
    let changed_paths = if changed_paths.is_empty() {
        changed_paths
    } else {
        format!("{changed_paths}\n")
    };
    fs::write(action_root.join("changed-paths.txt"), changed_paths)?;
    Ok(())
}

fn write_program_recovery_action_summary(
    repo_root: &Path,
    action_root: &Path,
    action_id: &str,
    blocker_class: &str,
    status: &str,
    failed_command: Option<&str>,
    error_message: Option<&str>,
) -> Result<()> {
    let failed_command = failed_command.unwrap_or("");
    let error_message = error_message.unwrap_or("");
    fs::write(
        action_root.join("summary.yml"),
        format!(
            "schema_version: \"octon-program-recovery-action-v1\"\naction_id: \"{action_id}\"\nblocker_class: \"{blocker_class}\"\nstatus: \"{status}\"\nfailed_command: \"{failed_command}\"\nerror_message: \"{error_message}\"\nevidence_path: \"{}\"\n",
            rel_display(repo_root, action_root)
        ),
    )?;
    Ok(())
}

fn recovery_recipe_matches(recipe: &ProgramRecoveryRecipeSpec, blocker_class: &str) -> bool {
    recipe.blocker_class == blocker_class
}

fn execute_atomic_program(
    octon_dir: &Path,
    repo_root: &Path,
    program_run_id: &str,
    run_inputs: &BTreeMap<String, String>,
    options: &RunLifecycleOptions,
    plan: &ProgramLifecyclePlanResult,
    evidence_root: &Path,
    control_root: &Path,
    approvals: Option<&Vec<ProgramApprovalGrant>>,
) -> Result<Vec<ProgramChildExecutionSummary>> {
    append_program_event(
        control_root,
        evidence_root,
        program_run_id,
        "atomic-preflight",
        None,
        None,
        "program-atomic preflight started",
        BTreeMap::new(),
    )?;
    if !plan.program_blockers.is_empty() {
        bail!("program-atomic preflight blocked by program blockers");
    }
    if !plan.approval_blockers.is_empty() {
        append_program_event(
            control_root,
            evidence_root,
            program_run_id,
            "approval-pause",
            None,
            None,
            "program-atomic paused for approval",
            BTreeMap::new(),
        )?;
        return Ok(plan
            .approval_blockers
            .iter()
            .map(|blocker| ProgramChildExecutionSummary {
                child_id: blocker.child_id.clone(),
                child_run_id: format!("{program_run_id}-{}", blocker.child_id),
                route_id: blocker.route_id.clone(),
                status: "human-boundary-blocked".to_string(),
                attempts: 0,
                retryable: false,
                blocker_class: Some(
                    blocker
                        .blocker_class
                        .clone()
                        .unwrap_or_else(|| "authority-ambiguity".to_string()),
                ),
                error_message: Some(blocker.reason.clone()),
                error_class: None,
                evidence_paths: Vec::new(),
                worktree_hygiene_foreign_fingerprint: None,
            })
            .collect());
    }
    let participants = plan
        .child_states
        .values()
        .filter(|state| state.required && !state.deferred && state.terminal_outcome.is_none())
        .collect::<Vec<_>>();
    if participants.is_empty() {
        return Ok(Vec::new());
    }
    let runnable = plan.runnable_batch.iter().cloned().collect::<BTreeSet<_>>();
    let missing_runnable = participants
        .iter()
        .filter(|state| !runnable.contains(&state.child_id))
        .map(|state| state.child_id.clone())
        .collect::<Vec<_>>();
    if !missing_runnable.is_empty() {
        return Ok(missing_runnable
            .into_iter()
            .map(|child_id| {
                ProgramChildExecutionSummary {
                    child_id: child_id.clone(),
                    child_run_id: format!("{program_run_id}-{child_id}-atomic-preflight"),
                    route_id: "program-atomic".to_string(),
                    status: "blocked-unsafe".to_string(),
                    attempts: 0,
                    retryable: false,
                    blocker_class: Some("unsafe-resume".to_string()),
                    error_message: Some(
                        "program-atomic requires every required non-deferred participant to be runnable"
                            .to_string(),
                    ),
                    error_class: None,
                    evidence_paths: Vec::new(),
                    worktree_hygiene_foreign_fingerprint: None,
                }
            })
            .collect());
    }
    let previous_barrier =
        reconstruct_atomic_barrier_state(&read_program_events(control_root)?).unwrap_or_default();

    let mut locks = Vec::new();
    for state in &participants {
        let lock_path = match acquire_child_lock(control_root, &state.child_id) {
            Ok(lock_path) => lock_path,
            Err(error) => {
                let error_message = error.to_string();
                release_atomic_locks(control_root, evidence_root, program_run_id, locks)?;
                append_program_event(
                    control_root,
                    evidence_root,
                    program_run_id,
                    "atomic-lock-stale",
                    Some(&state.child_id),
                    None,
                    "program-atomic encountered stale or unsafe child lock",
                    event_data([("error", error_message.as_str())]),
                )?;
                return Ok(vec![ProgramChildExecutionSummary {
                    child_id: state.child_id.clone(),
                    child_run_id: format!("{program_run_id}-{}-atomic-lock", state.child_id),
                    route_id: "program-atomic".to_string(),
                    status: "blocked-unsafe".to_string(),
                    attempts: 0,
                    retryable: false,
                    blocker_class: Some("unsafe-resume".to_string()),
                    error_message: Some(error_message),
                    error_class: None,
                    evidence_paths: Vec::new(),
                    worktree_hygiene_foreign_fingerprint: None,
                }]);
            }
        };
        append_program_event(
            control_root,
            evidence_root,
            program_run_id,
            "atomic-lock-acquired",
            Some(&state.child_id),
            None,
            "program-atomic acquired child lock",
            BTreeMap::new(),
        )?;
        locks.push((state.child_id.clone(), lock_path));
    }

    let executor = DefaultLifecycleRouteExecutor::new(repo_root.to_path_buf());
    let mut summaries = Vec::new();
    let mut staged = Vec::new();
    let mut atomic_specs = BTreeMap::new();

    for state in &participants {
        let source_route = state
            .selected_route
            .as_ref()
            .context("program-atomic child missing selected route")?;
        let child_contract = load_lifecycle_contract(octon_dir, &state.child_lifecycle_id)?;
        let atomic = atomic_spec_for_route(&child_contract.contract, &source_route.route_id)?;
        atomic_specs.insert(state.child_id.clone(), atomic.clone());
        if previous_barrier
            .staged_children
            .iter()
            .any(|child_id| child_id == &state.child_id)
        {
            staged.push(state.child_id.clone());
            continue;
        }
        let summary = match execute_atomic_route_phase(
            octon_dir,
            &executor,
            program_run_id,
            run_inputs,
            options,
            state,
            &atomic.stage_route_id,
            "atomic-stage",
            evidence_root,
            control_root,
            approvals,
        ) {
            Ok(summary) => summary,
            Err(error) => {
                let error_message = error.to_string();
                rollback_atomic_children(
                    octon_dir,
                    &executor,
                    program_run_id,
                    run_inputs,
                    options,
                    plan,
                    &atomic_specs,
                    &staged,
                    evidence_root,
                    control_root,
                    "atomic-rollback",
                    approvals,
                )?
                .into_iter()
                .for_each(|summary| summaries.push(summary));
                release_atomic_locks(control_root, evidence_root, program_run_id, locks)?;
                summaries.push(ProgramChildExecutionSummary {
                    child_id: state.child_id.clone(),
                    child_run_id: format!("{program_run_id}-{}-atomic-stage", state.child_id),
                    route_id: atomic.stage_route_id.clone(),
                    status: "blocked-unsafe".to_string(),
                    attempts: 0,
                    retryable: false,
                    blocker_class: Some("unsafe-resume".to_string()),
                    error_message: Some(error_message),
                    error_class: None,
                    evidence_paths: Vec::new(),
                    worktree_hygiene_foreign_fingerprint: None,
                });
                return Ok(summaries);
            }
        };
        let completed = summary.status == "completed";
        summaries.push(summary);
        if completed {
            staged.push(state.child_id.clone());
        } else {
            rollback_atomic_children(
                octon_dir,
                &executor,
                program_run_id,
                run_inputs,
                options,
                plan,
                &atomic_specs,
                &staged,
                evidence_root,
                control_root,
                "atomic-rollback",
                approvals,
            )?
            .into_iter()
            .for_each(|summary| summaries.push(summary));
            release_atomic_locks(control_root, evidence_root, program_run_id, locks)?;
            return Ok(summaries);
        }
    }

    let staged_children = staged.join(",");
    append_program_event(
        control_root,
        evidence_root,
        program_run_id,
        "atomic-barrier-verified",
        None,
        None,
        "program-atomic barrier verified after all required children staged",
        event_data([("staged_children", staged_children.as_str())]),
    )?;

    let mut committed = Vec::new();
    for state in &participants {
        if previous_barrier
            .committed_children
            .iter()
            .any(|child_id| child_id == &state.child_id)
        {
            committed.push(state.child_id.clone());
            continue;
        }
        let atomic = atomic_specs
            .get(&state.child_id)
            .context("missing atomic metadata after stage")?;
        let summary = match execute_atomic_route_phase(
            octon_dir,
            &executor,
            program_run_id,
            run_inputs,
            options,
            state,
            &atomic.commit_route_id,
            "atomic-commit",
            evidence_root,
            control_root,
            approvals,
        ) {
            Ok(summary) => summary,
            Err(error) => {
                let error_message = error.to_string();
                let compensation = rollback_atomic_children(
                    octon_dir,
                    &executor,
                    program_run_id,
                    run_inputs,
                    options,
                    plan,
                    &atomic_specs,
                    &committed,
                    evidence_root,
                    control_root,
                    "atomic-compensation",
                    approvals,
                )?;
                summaries.extend(compensation);
                release_atomic_locks(control_root, evidence_root, program_run_id, locks)?;
                summaries.push(ProgramChildExecutionSummary {
                    child_id: state.child_id.clone(),
                    child_run_id: format!("{program_run_id}-{}-atomic-commit", state.child_id),
                    route_id: atomic.commit_route_id.clone(),
                    status: "blocked-unsafe".to_string(),
                    attempts: 0,
                    retryable: false,
                    blocker_class: Some("unsafe-resume".to_string()),
                    error_message: Some(error_message),
                    error_class: None,
                    evidence_paths: Vec::new(),
                    worktree_hygiene_foreign_fingerprint: None,
                });
                return Ok(summaries);
            }
        };
        let completed = summary.status == "completed";
        summaries.push(summary);
        if completed {
            committed.push(state.child_id.clone());
        } else {
            let compensation = rollback_atomic_children(
                octon_dir,
                &executor,
                program_run_id,
                run_inputs,
                options,
                plan,
                &atomic_specs,
                &committed,
                evidence_root,
                control_root,
                "atomic-compensation",
                approvals,
            )?;
            if compensation
                .iter()
                .any(|summary| summary.status != "completed")
            {
                summaries.extend(compensation);
                summaries.push(ProgramChildExecutionSummary {
                    child_id: state.child_id.clone(),
                    child_run_id: format!("{program_run_id}-{}-atomic-unsafe", state.child_id),
                    route_id: "program-atomic".to_string(),
                    status: "blocked-unsafe".to_string(),
                    attempts: 0,
                    retryable: false,
                    blocker_class: Some("authority-boundary-ambiguous".to_string()),
                    error_message: Some(
                        "program-atomic commit failed and compensation did not complete"
                            .to_string(),
                    ),
                    error_class: None,
                    evidence_paths: Vec::new(),
                    worktree_hygiene_foreign_fingerprint: None,
                });
            } else {
                summaries.extend(compensation);
            }
            release_atomic_locks(control_root, evidence_root, program_run_id, locks)?;
            return Ok(summaries);
        }
    }

    release_atomic_locks(control_root, evidence_root, program_run_id, locks)?;
    Ok(summaries)
}

fn execute_atomic_route_phase(
    octon_dir: &Path,
    executor: &DefaultLifecycleRouteExecutor,
    program_run_id: &str,
    run_inputs: &BTreeMap<String, String>,
    options: &RunLifecycleOptions,
    state: &ProgramChildPlanState,
    route_id: &str,
    phase: &str,
    evidence_root: &Path,
    control_root: &Path,
    approvals: Option<&Vec<ProgramApprovalGrant>>,
) -> Result<ProgramChildExecutionSummary> {
    let child_contract = load_lifecycle_contract(octon_dir, &state.child_lifecycle_id)?;
    let route = route_by_id(&child_contract.contract, route_id)
        .with_context(|| format!("program-atomic {phase} route missing: {route_id}"))?;
    let route_plan = route_plan_state(route.clone());
    let child_run_id = sanitize_run_id(&format!("{program_run_id}-{}-{phase}", state.child_id))?;
    let child_evidence_root = evidence_root
        .join("children")
        .join(&state.child_id)
        .join(phase);
    let child_control_root = control_root
        .join("children")
        .join(&state.child_id)
        .join(phase);
    fs::create_dir_all(&child_evidence_root)?;
    fs::create_dir_all(&child_control_root)?;
    let repo_root = repo_root_for_octon(octon_dir)?;
    let authority_decision = child_route_authority_decision(
        &repo_root,
        program_run_id,
        state,
        route_id,
        OPERATION_CLASS_EXECUTE_CHILD_ROUTE,
    );
    let invocation_authority = invocation_authority_for_child_route(
        &options.invocation_authority,
        approvals,
        &state.child_id,
        route_id,
        None,
        None,
        route_spec_delegation_contract_basis(route_id, route).is_some(),
        Some(&authority_decision),
    );
    let authority_decision_path =
        write_authority_zone_decision(evidence_root, &authority_decision)?;
    let atomic_authority_allowed = invocation_authority == "grant-consumption"
        || authority_decision.autonomous_allowed
        || (authority_decision.authority_zone == AUTHORITY_ZONE_WORKSPACE_DECLARED
            && authority_decision.workspace_contained
            && authority_decision.declared_scope_contained
            && route.route_type != "workflow")
        || (invocation_authority == "unattended"
            && route_spec_delegation_contract_basis(route_id, route).is_some()
            && authority_decision_allows_route_unattended(&authority_decision));
    if !atomic_authority_allowed {
        let dispatch_blocker_class = if authority_decision.authority_zone
            == AUTHORITY_ZONE_WORKSPACE_DECLARED
            && route.route_type == "workflow"
        {
            "authority-ambiguity".to_string()
        } else {
            authority_decision.fail_closed_blocker.clone()
        };
        append_program_event(
            control_root,
            evidence_root,
            program_run_id,
            "atomic-child-route-authority-blocked",
            Some(&state.child_id),
            Some(route_id),
            "program atomic child route blocked by authority-zone decision",
            event_data([
                ("authority_zone", authority_decision.authority_zone.as_str()),
                ("artifact_class", authority_decision.artifact_class.as_str()),
                ("authority_decision", authority_decision_path.as_str()),
            ]),
        )?;
        return Ok(ProgramChildExecutionSummary {
            child_id: state.child_id.clone(),
            child_run_id,
            route_id: route_id.to_string(),
            status: if dispatch_blocker_class == "authority-ambiguity" {
                "human-boundary-blocked".to_string()
            } else if classify_program_blocker_class(&dispatch_blocker_class)
                == ProgramBlockerDisposition::Unsafe
            {
                "blocked-unsafe".to_string()
            } else {
                "blocked-human".to_string()
            },
            attempts: 0,
            retryable: false,
            blocker_class: Some(dispatch_blocker_class),
            error_message: Some(format!(
                "authority zone {} does not permit atomic route dispatch for artifact class {}",
                authority_decision.authority_zone, authority_decision.artifact_class
            )),
            error_class: Some("authority-zone".to_string()),
            evidence_paths: vec![authority_decision_path],
            worktree_hygiene_foreign_fingerprint: None,
        });
    }
    if invocation_authority == "grant-consumption" {
        write_program_approval_execution_evidence(
            &repo_root,
            &child_evidence_root,
            program_run_id,
            &state.child_id,
            route_id,
            None,
            None,
            approvals,
        )?;
    }
    append_program_event(
        control_root,
        evidence_root,
        program_run_id,
        phase,
        Some(&state.child_id),
        Some(route_id),
        "program-atomic route phase started",
        BTreeMap::new(),
    )?;
    let request = lifecycle_execution_request_for_route(
        octon_dir,
        &child_run_id,
        &state.child_lifecycle_id,
        &state.target,
        &route_plan,
        options.executor,
        options.timeout_seconds.unwrap_or(1800),
        &invocation_authority,
        0,
        run_inputs,
        child_evidence_root,
        child_control_root.join("lifecycle-checkpoint.yml"),
        Some(lifecycle_cancellation_token_path(control_root)),
        Some(program_child_approval_context(
            program_run_id,
            &state.child_id,
            &child_run_id,
            &state.child_lifecycle_id,
            &state.target,
            route_id,
        )),
    )?
    .with_context(|| format!("failed to build program-atomic request for {route_id}"))?;
    let result = executor.execute_route(request)?;
    append_program_event(
        control_root,
        evidence_root,
        program_run_id,
        &format!("{phase}-finished"),
        Some(&state.child_id),
        Some(route_id),
        "program-atomic route phase finished",
        event_data([("status", result.status.as_str())]),
    )?;
    Ok(ProgramChildExecutionSummary {
        child_id: state.child_id.clone(),
        child_run_id,
        route_id: route_id.to_string(),
        status: result.status,
        attempts: 1,
        retryable: result.retryable,
        blocker_class: None,
        error_message: result.error_message.clone(),
        error_class: result
            .error_class
            .as_ref()
            .map(|class| class.as_str().to_string()),
        evidence_paths: result
            .evidence_paths
            .iter()
            .map(|path| rel_path_string(path))
            .collect(),
        worktree_hygiene_foreign_fingerprint: None,
    })
}

fn rollback_atomic_children(
    octon_dir: &Path,
    executor: &DefaultLifecycleRouteExecutor,
    program_run_id: &str,
    run_inputs: &BTreeMap<String, String>,
    options: &RunLifecycleOptions,
    plan: &ProgramLifecyclePlanResult,
    atomic_specs: &BTreeMap<String, RouteAtomicSpec>,
    child_ids: &[String],
    evidence_root: &Path,
    control_root: &Path,
    phase: &str,
    approvals: Option<&Vec<ProgramApprovalGrant>>,
) -> Result<Vec<ProgramChildExecutionSummary>> {
    let mut summaries = Vec::new();
    for child_id in child_ids.iter().rev() {
        let Some(state) = plan.child_states.get(child_id) else {
            continue;
        };
        let Some(atomic) = atomic_specs.get(child_id) else {
            continue;
        };
        let route_id = if phase == "atomic-compensation" {
            atomic.compensation_route_id.as_deref()
        } else {
            atomic.rollback_route_id.as_deref()
        };
        let Some(route_id) = route_id else {
            summaries.push(ProgramChildExecutionSummary {
                child_id: child_id.clone(),
                child_run_id: format!("{program_run_id}-{child_id}-{phase}"),
                route_id: phase.to_string(),
                status: "blocked-unsafe".to_string(),
                attempts: 0,
                retryable: false,
                blocker_class: Some("authority-boundary-ambiguous".to_string()),
                error_message: Some("missing rollback or compensation route".to_string()),
                error_class: None,
                evidence_paths: Vec::new(),
                worktree_hygiene_foreign_fingerprint: None,
            });
            continue;
        };
        summaries.push(execute_atomic_route_phase(
            octon_dir,
            executor,
            program_run_id,
            run_inputs,
            options,
            state,
            route_id,
            phase,
            evidence_root,
            control_root,
            approvals,
        )?);
    }
    Ok(summaries)
}

fn release_atomic_locks(
    control_root: &Path,
    evidence_root: &Path,
    program_run_id: &str,
    locks: Vec<(String, PathBuf)>,
) -> Result<()> {
    for (child_id, lock_path) in locks {
        let operation = ProgramArtifactOperation {
            operation_id: format!("remove_atomic_child_lock-{child_id}-program-atomic"),
            child_id: child_id.clone(),
            route_id: "program-atomic".to_string(),
            operation: "remove_atomic_child_lock".to_string(),
            destructive_operation: "remove_file".to_string(),
            artifact_paths: vec![lock_path.clone()],
            command_or_operation: "fs::remove_file".to_string(),
        };
        let criticality_evidence = match perform_governed_artifact_cleanup(
            control_root,
            evidence_root,
            program_run_id,
            &operation,
        ) {
            Ok(path) => path,
            Err(error) => {
                let error_message = error.to_string();
                append_program_event(
                    control_root,
                    evidence_root,
                    program_run_id,
                    "atomic-lock-stale",
                    Some(&child_id),
                    None,
                    "program-atomic could not release child lock",
                    event_data([("error", error_message.as_str())]),
                )?;
                bail!(
                    "program-atomic could not release child lock for {child_id}: {error_message}"
                );
            }
        };
        append_program_event(
            control_root,
            evidence_root,
            program_run_id,
            "atomic-lock-released",
            Some(&child_id),
            None,
            "program-atomic released child lock",
            event_data([("criticality_evidence", criticality_evidence.as_str())]),
        )?;
    }
    Ok(())
}

fn execute_child_jobs(
    repo_root: &Path,
    program_run_id: &str,
    control_root: &Path,
    evidence_root: &Path,
    jobs: Vec<ChildExecutionJob>,
    max_concurrency: usize,
    step_context: Option<ProgramExecutionStepContext>,
) -> Result<Vec<ProgramChildExecutionSummary>> {
    let executor = DefaultLifecycleRouteExecutor::new(repo_root.to_path_buf());
    let mut summaries = Vec::new();
    let mut pending = jobs.into_iter();
    loop {
        let chunk = pending
            .by_ref()
            .take(max_concurrency)
            .collect::<Vec<ChildExecutionJob>>();
        if chunk.is_empty() {
            break;
        }
        for job in &chunk {
            if let Err(error) = append_program_event(
                control_root,
                evidence_root,
                program_run_id,
                "child-route-started",
                Some(&job.child_id),
                Some(&job.route_id),
                "child route execution started",
                program_step_event_data(
                    step_context.as_ref(),
                    "child-batch-dispatch",
                    std::iter::empty::<(&str, &str)>(),
                ),
            ) {
                release_child_locks_after_build_failure(
                    control_root,
                    evidence_root,
                    program_run_id,
                    &chunk,
                )?;
                return Err(error);
            }
            if let Some(blocker_class) = job.blocker_class.as_deref() {
                if let Err(error) = append_program_event(
                    control_root,
                    evidence_root,
                    program_run_id,
                    "recovery-attempt",
                    Some(&job.child_id),
                    Some(&job.route_id),
                    "child recovery route execution started",
                    program_step_event_data(
                        step_context.as_ref(),
                        "child-batch-dispatch",
                        [("blocker_class", blocker_class)],
                    ),
                ) {
                    release_child_locks_after_build_failure(
                        control_root,
                        evidence_root,
                        program_run_id,
                        &chunk,
                    )?;
                    return Err(error);
                }
            }
        }
        let mut handles = Vec::new();
        let mut lock_records = Vec::new();
        for job in chunk {
            lock_records.push((
                job.child_id.clone(),
                job.route_id.clone(),
                job.lock_path.clone(),
            ));
            let executor = executor.clone();
            handles.push(thread::spawn(move || execute_child_job(executor, job)));
        }
        for (handle, (child_id, route_id, lock_path)) in
            handles.into_iter().zip(lock_records.into_iter())
        {
            let outcome = match handle.join() {
                Ok(Ok(outcome)) => outcome,
                Ok(Err(error)) => {
                    release_child_lock(
                        control_root,
                        evidence_root,
                        program_run_id,
                        &child_id,
                        &route_id,
                        &lock_path,
                    )?;
                    return Err(error);
                }
                Err(_) => {
                    release_child_lock(
                        control_root,
                        evidence_root,
                        program_run_id,
                        &child_id,
                        &route_id,
                        &lock_path,
                    )?;
                    return Err(anyhow::anyhow!(
                        "program child executor thread panicked for {child_id}"
                    ));
                }
            };
            let summary = finish_child_execution(
                control_root,
                evidence_root,
                program_run_id,
                outcome,
                step_context,
            )?;
            summaries.push(summary);
        }
    }
    Ok(summaries)
}

fn finish_child_execution(
    control_root: &Path,
    evidence_root: &Path,
    program_run_id: &str,
    outcome: ChildExecutionOutcome,
    step_context: Option<ProgramExecutionStepContext>,
) -> Result<ProgramChildExecutionSummary> {
    let summary = outcome.summary;
    let attempts = summary.attempts.to_string();
    let finish_event = append_program_event(
        control_root,
        evidence_root,
        program_run_id,
        "child-route-finished",
        Some(&summary.child_id),
        Some(&summary.route_id),
        "child route execution finished",
        program_step_event_data(
            step_context.as_ref(),
            "child-batch-dispatch",
            [
                ("status", summary.status.as_str()),
                ("attempts", attempts.as_str()),
            ],
        ),
    );
    let release = release_child_lock(
        control_root,
        evidence_root,
        program_run_id,
        &summary.child_id,
        &summary.route_id,
        &outcome.lock_path,
    );
    match (finish_event, release) {
        (Ok(_), Ok(())) => Ok(summary),
        (Err(finish_error), Ok(())) => Err(finish_error).with_context(|| {
            format!(
                "program child finish event append failed after execution for {}:{}",
                summary.child_id, summary.route_id
            )
        }),
        (Ok(_), Err(release_error)) => Err(release_error),
        (Err(finish_error), Err(release_error)) => {
            bail!(
                "program child finish event append failed after execution for {}:{}: {}; lock cleanup also failed: {}",
                summary.child_id,
                summary.route_id,
                finish_error,
                release_error
            );
        }
    }
}

fn execute_child_job(
    executor: DefaultLifecycleRouteExecutor,
    mut job: ChildExecutionJob,
) -> Result<ChildExecutionOutcome> {
    let mut last_result: Option<LifecycleRouteExecutionResult> = None;
    let mut attempts = 0;
    for attempt in 0..job.max_attempts {
        attempts = attempt + 1;
        job.request.policy.retry_attempt = attempt;
        let result = match executor.execute_route(job.request.clone()) {
            Ok(result) => result,
            Err(error) => {
                let error_message = error.to_string();
                let (blocker_class, retryable) = adapter_error_blocker_class(&error);
                let evidence_paths = write_child_adapter_error_evidence(&job, &error)?;
                if let Some(evidence) = job.unsafe_repair.clone() {
                    write_unsafe_repair_evidence(
                        &job.request.evidence_root,
                        evidence,
                        None,
                        Some(&error_message),
                    )?;
                }
                return Ok(ChildExecutionOutcome {
                    summary: ProgramChildExecutionSummary {
                        child_id: job.child_id,
                        child_run_id: job.child_run_id,
                        route_id: job.route_id,
                        status: "failed".to_string(),
                        attempts,
                        retryable,
                        blocker_class: job.blocker_class.or_else(|| Some(blocker_class)),
                        error_message: Some(error_message),
                        error_class: Some(error.class.as_str().to_string()),
                        evidence_paths,
                        worktree_hygiene_foreign_fingerprint: None,
                    },
                    lock_path: job.lock_path,
                });
            }
        };
        let retry = result.retryable
            && matches!(result.status.as_str(), "failed" | "timed-out" | "cancelled")
            && attempt + 1 < job.max_attempts;
        last_result = Some(result);
        if !retry {
            break;
        }
    }
    let result = last_result.context("child execution produced no result")?;
    if let Some(evidence) = job.unsafe_repair.clone() {
        write_unsafe_repair_evidence(&job.request.evidence_root, evidence, Some(&result), None)?;
    }
    Ok(ChildExecutionOutcome {
        summary: ProgramChildExecutionSummary {
            child_id: job.child_id,
            child_run_id: job.child_run_id,
            route_id: job.route_id,
            status: result.status.clone(),
            attempts,
            retryable: result.retryable,
            blocker_class: job
                .blocker_class
                .or_else(|| execution_result_blocker_class(&result)),
            error_message: result.error_message.clone(),
            error_class: result
                .error_class
                .as_ref()
                .map(|class| class.as_str().to_string()),
            evidence_paths: result
                .evidence_paths
                .iter()
                .map(|path| rel_path_string(path))
                .collect(),
            worktree_hygiene_foreign_fingerprint: None,
        },
        lock_path: job.lock_path,
    })
}

fn adapter_error_blocker_class(error: &LifecycleExecutionError) -> (String, bool) {
    match &error.class {
        LifecycleErrorClass::Timeout => ("executor-timed-out".to_string(), true),
        LifecycleErrorClass::ExecutorFailed | LifecycleErrorClass::ExecutorUnavailable => {
            ("executor-failed".to_string(), true)
        }
        LifecycleErrorClass::AuthorizationProofFailed
        | LifecycleErrorClass::HumanBoundaryRequired
        | LifecycleErrorClass::InputBinding => ("executor-preflight-blocked".to_string(), false),
        _ => ("executor-failed".to_string(), false),
    }
}

fn write_child_adapter_error_evidence(
    job: &ChildExecutionJob,
    error: &LifecycleExecutionError,
) -> Result<Vec<String>> {
    fs::create_dir_all(&job.request.evidence_root)?;
    let evidence_path = job
        .request
        .evidence_root
        .join(format!("{}-adapter-error.yml", job.route_id));
    fs::write(
        &evidence_path,
        format!(
            "schema_version: octon-program-child-adapter-error-v1\nchild_id: {}\nchild_run_id: {}\nroute_id: {}\nstatus: failed\nerror_class: {}\nretryable: {}\nmessage: {}\nrecorded_at: {}\n",
            job.child_id,
            job.child_run_id,
            job.route_id,
            error.class.as_str(),
            matches!(
                &error.class,
                LifecycleErrorClass::Timeout
                    | LifecycleErrorClass::ExecutorFailed
                    | LifecycleErrorClass::ExecutorUnavailable
            ),
            yaml_scalar(&error.message),
            now_rfc3339()?
        ),
    )?;
    Ok(vec![rel_path_string(&evidence_path)])
}

fn execution_result_blocker_class(result: &LifecycleRouteExecutionResult) -> Option<String> {
    if result.status == "executor-preflight-blocked" {
        return Some("executor-preflight-blocked".to_string());
    }
    if !result.retryable {
        return None;
    }
    match result.error_class.as_ref().map(|class| class.as_str()) {
        Some("timeout") => Some("executor-timed-out".to_string()),
        Some("executor-failed") | Some("executor-unavailable") => {
            Some("executor-failed".to_string())
        }
        _ if result.status == "timed-out" => Some("executor-timed-out".to_string()),
        _ if result.status == "failed" => Some("executor-failed".to_string()),
        _ => None,
    }
}

fn write_unsafe_repair_evidence(
    child_evidence_root: &Path,
    mut evidence: ProgramUnsafeRepairEvidence,
    result: Option<&LifecycleRouteExecutionResult>,
    error_message: Option<&str>,
) -> Result<()> {
    if let Some(result) = result {
        let mut changed = result
            .evidence_paths
            .iter()
            .map(|path| rel_path_string(path))
            .collect::<Vec<_>>();
        changed.extend(
            result
                .receipts_observed
                .iter()
                .map(|receipt| rel_path_string(&receipt.path)),
        );
        if let Some(path) = result.stdout_path.as_ref() {
            changed.push(rel_path_string(path));
        }
        if let Some(path) = result.stderr_path.as_ref() {
            changed.push(rel_path_string(path));
        }
        if let Some(path) = result.prompt_packet_path.as_ref() {
            changed.push(rel_path_string(path));
        }
        if !changed.is_empty() {
            changed.sort();
            changed.dedup();
            evidence.files_artifacts_changed = changed;
        }
        evidence.after_validation = format!(
            "repair route status {}; retryable {}; receipts_observed {}",
            result.status,
            result.retryable,
            result.receipts_observed.len()
        );
        evidence.route_execution_status = result.status.clone();
        evidence.post_attempt_validation_status =
            if matches!(result.status.as_str(), "completed" | "no-op") {
                "pending".to_string()
            } else {
                "not-run-route-not-completed".to_string()
            };
        evidence.execution_can_resume = false;
        evidence.final_execution_can_resume = false;
    } else if let Some(error_message) = error_message {
        evidence.after_validation =
            format!("repair route failed before completion: {error_message}");
        evidence.route_execution_status = "failed".to_string();
        evidence.post_attempt_validation_status = "not-run-route-error".to_string();
        evidence.post_attempt_validation_failures = vec![error_message.to_string()];
        evidence.execution_can_resume = false;
        evidence.final_execution_can_resume = false;
    }
    fs::create_dir_all(child_evidence_root)?;
    fs::write(
        child_evidence_root.join("unsafe-repair-decision.yml"),
        serde_yaml::to_string(&evidence)?,
    )?;
    Ok(())
}

fn finalize_unsafe_repair_evidence(
    evidence_root: &Path,
    result: &ProgramChildExecutionSummary,
) -> Result<()> {
    finalize_unsafe_repair_evidence_with_outcome(evidence_root, result, None)
}

fn finalize_unsafe_repair_evidence_with_outcome(
    evidence_root: &Path,
    result: &ProgramChildExecutionSummary,
    outcome: Option<&ProgramRecoveryPostAttemptValidationOutcome>,
) -> Result<()> {
    let evidence_path = evidence_root.join("unsafe-repair-decision.yml");
    if !evidence_path.is_file() {
        return Ok(());
    }
    let mut evidence: ProgramUnsafeRepairEvidence =
        serde_yaml::from_slice(&fs::read(&evidence_path)?)?;
    evidence.final_blocker_class = outcome
        .and_then(|outcome| outcome.final_blocker_class.clone())
        .or_else(|| result.blocker_class.clone());
    evidence.post_attempt_validation_failures.clear();
    if evidence.route_execution_status.is_empty() {
        evidence.route_execution_status = if evidence.execution_can_resume {
            "completed".to_string()
        } else {
            result.status.clone()
        };
    }
    if let Some(outcome) = outcome {
        evidence.post_attempt_validations_declared = outcome.declared.clone();
        evidence.post_attempt_validation_results = outcome.results.clone();
        evidence.post_attempt_validation_status = outcome.status.clone();
        evidence.post_attempt_validation_failures = outcome.failures.clone();
        evidence.resume_decision_basis = outcome.resume_decision_basis.clone();
        evidence.final_execution_can_resume = outcome.execution_can_resume;
        evidence.execution_can_resume = outcome.execution_can_resume;
        fs::write(&evidence_path, serde_yaml::to_string(&evidence)?)?;
        return Ok(());
    }
    let route_completed = matches!(
        evidence.route_execution_status.as_str(),
        "completed" | "no-op"
    );
    if matches!(result.status.as_str(), "completed" | "no-op") && route_completed {
        evidence.post_attempt_validation_status = "passed".to_string();
        evidence.post_attempt_validation_results = vec!["summary-status: pass".to_string()];
        evidence.resume_decision_basis =
            "repair route completed/no-op and post-attempt validations passed".to_string();
        evidence.final_execution_can_resume = true;
        evidence.execution_can_resume = true;
    } else {
        evidence.post_attempt_validation_status = if route_completed {
            "failed".to_string()
        } else {
            "not-run-route-not-completed".to_string()
        };
        if let Some(message) = result.error_message.as_ref() {
            evidence
                .post_attempt_validation_failures
                .push(message.clone());
        } else {
            evidence
                .post_attempt_validation_failures
                .push(format!("repair route final status {}", result.status));
        }
        evidence.post_attempt_validation_results =
            vec![format!("summary-status: fail: {}", result.status)];
        evidence.resume_decision_basis =
            "repair route did not satisfy final post-attempt validation status".to_string();
        evidence.final_execution_can_resume = false;
        evidence.execution_can_resume = false;
    }
    fs::write(&evidence_path, serde_yaml::to_string(&evidence)?)?;
    Ok(())
}

fn finalize_child_unsafe_repair_evidence(
    evidence_root: &Path,
    child_results: &[ProgramChildExecutionSummary],
) -> Result<()> {
    for result in child_results
        .iter()
        .filter(|result| result.blocker_class.is_some())
    {
        let child_evidence_root = evidence_root.join("children").join(&result.child_id);
        finalize_unsafe_repair_evidence(&child_evidence_root, result)?;
    }
    Ok(())
}

fn finalize_parent_unsafe_repair_evidence(
    evidence_root: &Path,
    result: &LifecycleRouteExecutionResult,
    outcome: &ProgramRecoveryPostAttemptValidationOutcome,
) -> Result<()> {
    let summary = ProgramChildExecutionSummary {
        child_id: "program".to_string(),
        child_run_id: "program".to_string(),
        route_id: "program-parent-route".to_string(),
        status: if matches!(result.status.as_str(), "completed" | "no-op")
            && outcome.execution_can_resume
        {
            result.status.clone()
        } else if matches!(result.status.as_str(), "completed" | "no-op") {
            "failed".to_string()
        } else {
            result.status.clone()
        },
        attempts: 1,
        retryable: result.retryable,
        blocker_class: outcome.final_blocker_class.clone(),
        error_message: if matches!(result.status.as_str(), "completed" | "no-op")
            && !outcome.execution_can_resume
        {
            Some(outcome.failures.join("; "))
        } else {
            result.error_message.clone()
        },
        error_class: result
            .error_class
            .as_ref()
            .map(|class| class.as_str().to_string()),
        evidence_paths: result
            .evidence_paths
            .iter()
            .map(|path| rel_path_string(path))
            .collect(),
        worktree_hygiene_foreign_fingerprint: None,
    };
    finalize_unsafe_repair_evidence_with_outcome(
        &evidence_root.join("parent"),
        &summary,
        Some(outcome),
    )
}

fn acquire_child_lock(control_root: &Path, child_id: &str) -> Result<PathBuf> {
    let lock_root = control_root.join("locks");
    fs::create_dir_all(&lock_root)?;
    let lock_path = lock_root.join(format!("{child_id}.lock"));
    let mut file = OpenOptions::new()
        .create_new(true)
        .write(true)
        .open(&lock_path)
        .with_context(|| format!("child target lock already exists for {child_id}"))?;
    writeln!(file, "child_id: {child_id}")?;
    Ok(lock_path)
}

fn release_child_locks_after_build_failure(
    control_root: &Path,
    evidence_root: &Path,
    program_run_id: &str,
    jobs: &[ChildExecutionJob],
) -> Result<()> {
    for job in jobs {
        release_child_lock(
            control_root,
            evidence_root,
            program_run_id,
            &job.child_id,
            &job.route_id,
            &job.lock_path,
        )
        .with_context(|| {
            format!(
                "program child lock cleanup failed after job construction error for {}:{}",
                job.child_id, job.route_id
            )
        })?;
    }
    Ok(())
}

fn release_child_lock(
    control_root: &Path,
    evidence_root: &Path,
    program_run_id: &str,
    child_id: &str,
    route_id: &str,
    lock_path: &Path,
) -> Result<()> {
    let operation = ProgramArtifactOperation {
        operation_id: format!("remove_child_lock-{child_id}-{route_id}"),
        child_id: child_id.to_string(),
        route_id: route_id.to_string(),
        operation: "remove_child_lock".to_string(),
        destructive_operation: "remove_file".to_string(),
        artifact_paths: vec![lock_path.to_path_buf()],
        command_or_operation: "fs::remove_file".to_string(),
    };
    let criticality = assess_program_artifact_criticality(control_root, program_run_id, &operation);
    match perform_governed_artifact_cleanup(control_root, evidence_root, program_run_id, &operation)
    {
        Ok(criticality_evidence) => {
            let artifact_paths = criticality.artifact_paths.join(",");
            append_program_event(
                control_root,
                evidence_root,
                program_run_id,
                "child-lock-released",
                Some(child_id),
                Some(route_id),
                "program child execution lock released",
                event_data([
                    ("criticality", criticality.criticality.as_str()),
                    ("artifact_path", artifact_paths.as_str()),
                    ("criticality_evidence", criticality_evidence.as_str()),
                ]),
            )?;
            Ok(())
        }
        Err(error) if !criticality.autonomous_allowed => {
            let artifact_paths = criticality.artifact_paths.join(",");
            append_program_event(
                control_root,
                evidence_root,
                program_run_id,
                "child-lock-cleanup-blocked",
                Some(child_id),
                Some(route_id),
                "program child execution lock cleanup requires human input",
                event_data([
                    ("criticality", criticality.criticality.as_str()),
                    ("artifact_path", artifact_paths.as_str()),
                    ("criticality_evidence", "artifact-criticality"),
                ]),
            )?;
            bail!(
                "program child execution lock cleanup requires human input: {}",
                criticality.rationale
            );
        }
        Err(error) => {
            let message = format!(
                "program child execution lock could not be released: {}",
                error
            );
            let artifact_paths = criticality.artifact_paths.join(",");
            append_program_event(
                control_root,
                evidence_root,
                program_run_id,
                "child-lock-stale",
                Some(child_id),
                Some(route_id),
                &message,
                event_data([
                    ("status", "blocked-unsafe"),
                    ("criticality", criticality.criticality.as_str()),
                    ("artifact_path", artifact_paths.as_str()),
                ]),
            )?;
            bail!("{message}");
        }
    }
}

fn assess_program_artifact_criticality(
    control_root: &Path,
    program_run_id: &str,
    operation: &ProgramArtifactOperation,
) -> ProgramArtifactCriticalityDecision {
    let lock_root = control_root.join("locks");
    let tmp_root = control_root.join("tmp");
    let scratch_root = control_root.join("scratch");
    let primary_path = operation
        .artifact_paths
        .first()
        .cloned()
        .unwrap_or_else(PathBuf::new);
    let expected_lock_path = lock_root.join(format!("{}.lock", operation.child_id));
    let path_matches_expected = primary_path == expected_lock_path;
    let under_lock_root = primary_path.starts_with(&lock_root);
    let under_current_run_generated_root =
        primary_path.starts_with(&tmp_root) || primary_path.starts_with(&scratch_root);
    let workspace_root = control_root
        .ancestors()
        .find(|path| {
            path.file_name()
                .map(|name| name == ".octon")
                .unwrap_or(false)
        })
        .and_then(Path::parent)
        .map(Path::to_path_buf)
        .unwrap_or_else(|| control_root.to_path_buf());
    let workspace_contained = primary_path.starts_with(&workspace_root);
    let declared_cleanup_scopes = vec![authority_path_ref(&workspace_root, control_root)];
    let authority_decision = classify_authority_zone(
        &workspace_root,
        program_run_id,
        Some(&operation.child_id),
        Some(&operation.route_id),
        None,
        OPERATION_CLASS_CLEANUP_CURRENT_RUN_ARTIFACT,
        &operation.artifact_paths,
        &declared_cleanup_scopes,
        None,
    );
    let declared_scope_contained = under_lock_root || under_current_run_generated_root;
    let exists = primary_path.exists();
    let is_file = primary_path.is_file();
    let is_dir = primary_path.is_dir();
    let artifact_path = primary_path.to_string_lossy().to_string();
    let retained_evidence = artifact_path.contains("/state/evidence/runs/workflows/");
    let archive_metadata = artifact_path.contains("/.archive/");
    let operation_supported = supported_destructive_operation(&operation.destructive_operation);
    let authority_surface = if retained_evidence {
        "retained-lifecycle-evidence"
    } else if archive_metadata {
        "archive-metadata"
    } else if authority_decision.authority_zone == AUTHORITY_ZONE_CURRENT_RUN_AGENT_ARTIFACT {
        if under_lock_root {
            "current-run-control-lock"
        } else {
            "current-run-generated-artifact"
        }
    } else if authority_decision.authority_zone == AUTHORITY_ZONE_AUTHORED_GOVERNANCE {
        "authored-contract-or-policy"
    } else if authority_decision.authority_zone == AUTHORITY_ZONE_RUN_BOUND {
        "current-run-control-or-evidence"
    } else if artifact_path.contains("/.octon/framework/")
        || artifact_path.contains("/.octon/instance/")
        || artifact_path.contains("/.octon/inputs/additive/extensions/")
    {
        "authored-contract-or-policy"
    } else if under_lock_root {
        "current-run-control-lock"
    } else if under_current_run_generated_root {
        "current-run-generated-artifact"
    } else {
        "unclear"
    };
    let before_validation = format!(
        "exists={exists}; is_file={is_file}; is_dir={is_dir}; under_current_run_lock_root={under_lock_root}; under_current_run_generated_root={under_current_run_generated_root}; path_matches_child_lock={path_matches_expected}; authority_surface={authority_surface}; operation_supported={operation_supported}"
    );
    let generated_operation = matches!(
        operation.operation.as_str(),
        "generated_artifact_cleanup" | "remove_generated_artifact"
    );
    if operation_supported
        && workspace_contained
        && declared_scope_contained
        && authority_decision.autonomous_allowed
        && ((path_matches_expected && under_lock_root)
            || (generated_operation && under_current_run_generated_root))
    {
        ProgramArtifactCriticalityDecision {
            schema_version: "octon-program-artifact-criticality-decision-v1".to_string(),
            program_run_id: program_run_id.to_string(),
            classification_policy_version: "octon-program-artifact-criticality-policy-v2"
                .to_string(),
            operation_id: operation.operation_id.clone(),
            child_id: operation.child_id.clone(),
            route_id: operation.route_id.clone(),
            operation: operation.operation.clone(),
            destructive_operation: operation.destructive_operation.clone(),
            artifact_paths: vec![artifact_path],
            classification_inputs: vec![
                format!("path_matches_child_lock={path_matches_expected}"),
                format!("under_current_run_lock_root={under_lock_root}"),
                format!("under_current_run_generated_root={under_current_run_generated_root}"),
                format!("workspace_contained={workspace_contained}"),
                format!("declared_scope_contained={declared_scope_contained}"),
                format!("authority_surface={authority_surface}"),
                format!("operation_supported={operation_supported}"),
            ],
            artifact_owner: "current-run".to_string(),
            authority_surface: authority_surface.to_string(),
            authority_zone: authority_decision.authority_zone,
            artifact_class: authority_decision.artifact_class,
            authority_zone_decision: None,
            criticality: "non-critical".to_string(),
            ownership: if under_lock_root {
                "current-run-child-lock".to_string()
            } else {
                "current-run-generated-artifact".to_string()
            },
            workspace_contained,
            declared_scope_contained,
            human_input_required: false,
            autonomous_allowed: true,
            rationale: if under_lock_root {
                "lock is a current-run coordination artifact, is named for the selected child, and is safe to remove after route completion or abandoned job construction".to_string()
            } else {
                "artifact is a current-run generated temporary or scratch artifact and is safe to remove after classification".to_string()
            },
            command_or_operation: operation.command_or_operation.clone(),
            before_validation,
            after_validation: "pending".to_string(),
            operation_supported,
            mutation_performed: false,
            mutation_status: "pending".to_string(),
            blocked_reason: None,
        }
    } else {
        let (criticality, ownership, rationale, blocked_reason) = if !operation_supported {
            (
                "unclear",
                "unclear",
                "cleanup operation is unsupported and cannot be classified as safe",
                "unsupported-destructive-operation",
            )
        } else if retained_evidence
            || artifact_path.contains("/.octon/state/evidence/")
            || authority_surface == "authored-contract-or-policy"
            || authority_surface == "archive-metadata"
            || authority_decision.authority_zone == AUTHORITY_ZONE_AUTHORED_GOVERNANCE
        {
            (
                    "critical",
                    authority_surface,
                    "artifact is retained lifecycle evidence or authored authority surface and must not be cleaned autonomously",
                    "critical-artifact",
                )
        } else {
            (
                    "unclear",
                    "unclear",
                    "artifact path is not the expected current-run generated artifact path; ownership is unclear",
                    "artifact-ownership-unclear",
                )
        };
        ProgramArtifactCriticalityDecision {
            schema_version: "octon-program-artifact-criticality-decision-v1".to_string(),
            program_run_id: program_run_id.to_string(),
            classification_policy_version: "octon-program-artifact-criticality-policy-v2"
                .to_string(),
            operation_id: operation.operation_id.clone(),
            child_id: operation.child_id.clone(),
            route_id: operation.route_id.clone(),
            operation: operation.operation.clone(),
            destructive_operation: operation.destructive_operation.clone(),
            artifact_paths: vec![artifact_path],
            classification_inputs: vec![
                format!("path_matches_child_lock={path_matches_expected}"),
                format!("under_current_run_lock_root={under_lock_root}"),
                format!("under_current_run_generated_root={under_current_run_generated_root}"),
                format!("workspace_contained={workspace_contained}"),
                format!("declared_scope_contained={declared_scope_contained}"),
                format!("authority_surface={authority_surface}"),
                format!("operation_supported={operation_supported}"),
            ],
            artifact_owner: ownership.to_string(),
            authority_surface: authority_surface.to_string(),
            authority_zone: authority_decision.authority_zone,
            artifact_class: authority_decision.artifact_class,
            authority_zone_decision: None,
            criticality: criticality.to_string(),
            ownership: ownership.to_string(),
            workspace_contained,
            declared_scope_contained,
            human_input_required: true,
            autonomous_allowed: false,
            rationale: rationale.to_string(),
            command_or_operation: operation.command_or_operation.clone(),
            before_validation,
            after_validation: "not-run-human-input-required".to_string(),
            operation_supported,
            mutation_performed: false,
            mutation_status: "blocked".to_string(),
            blocked_reason: Some(blocked_reason.to_string()),
        }
    }
}

fn supported_destructive_operation(operation: &str) -> bool {
    matches!(operation, "remove_file" | "remove_dir" | "remove_dir_all")
}

fn write_artifact_criticality_decision(
    evidence_root: &Path,
    decision: &ProgramArtifactCriticalityDecision,
) -> Result<String> {
    let root = evidence_root.join("artifact-criticality");
    fs::create_dir_all(&root)?;
    let file_stem = sanitize_run_id(&format!(
        "{}-{}-{}",
        decision.operation, decision.child_id, decision.route_id
    ))?;
    let path = root.join(format!("{file_stem}.yml"));
    fs::write(&path, serde_yaml::to_string(decision)?)?;
    Ok(rel_path_string(&path))
}

fn perform_governed_artifact_cleanup(
    control_root: &Path,
    evidence_root: &Path,
    program_run_id: &str,
    operation: &ProgramArtifactOperation,
) -> Result<String> {
    let mut decision = assess_program_artifact_criticality(control_root, program_run_id, operation);
    let workspace_root = control_root
        .ancestors()
        .find(|path| {
            path.file_name()
                .map(|name| name == ".octon")
                .unwrap_or(false)
        })
        .and_then(Path::parent)
        .map(Path::to_path_buf)
        .unwrap_or_else(|| control_root.to_path_buf());
    let declared_cleanup_scopes = vec![authority_path_ref(&workspace_root, control_root)];
    let authority_decision = classify_authority_zone(
        &workspace_root,
        program_run_id,
        Some(&operation.child_id),
        Some(&operation.route_id),
        None,
        OPERATION_CLASS_CLEANUP_CURRENT_RUN_ARTIFACT,
        &operation.artifact_paths,
        &declared_cleanup_scopes,
        None,
    );
    decision.authority_zone_decision = Some(write_authority_zone_decision(
        evidence_root,
        &authority_decision,
    )?);
    write_artifact_criticality_decision(evidence_root, &decision)?;
    if !decision.autonomous_allowed {
        decision.after_validation = "not-run-human-input-required".to_string();
        decision.mutation_performed = false;
        decision.mutation_status = "blocked-human-input-required".to_string();
        if decision.blocked_reason.is_none() {
            decision.blocked_reason = Some("human-input-required".to_string());
        }
        let evidence_path = write_artifact_criticality_decision(evidence_root, &decision)?;
        bail!(
            "program artifact cleanup requires human input: {}; evidence: {}",
            decision.rationale,
            evidence_path
        );
    }
    let Some(path) = operation.artifact_paths.first() else {
        decision.after_validation = "cleanup failed: missing artifact path".to_string();
        write_artifact_criticality_decision(evidence_root, &decision)?;
        bail!("program artifact cleanup failed: missing artifact path");
    };
    match operation.destructive_operation.as_str() {
        "remove_file" => match fs::remove_file(path) {
            Ok(()) => {
                decision.after_validation =
                    "lock artifact absent after autonomous cleanup".to_string();
                decision.mutation_performed = true;
                decision.mutation_status = "completed".to_string();
                let evidence_path = write_artifact_criticality_decision(evidence_root, &decision)?;
                Ok(evidence_path)
            }
            Err(error) if error.kind() == std::io::ErrorKind::NotFound => {
                decision.after_validation =
                    "lock artifact already absent before autonomous cleanup".to_string();
                decision.mutation_performed = false;
                decision.mutation_status = "already-absent".to_string();
                let evidence_path = write_artifact_criticality_decision(evidence_root, &decision)?;
                Ok(evidence_path)
            }
            Err(error) => {
                decision.after_validation = format!("cleanup failed: {error}");
                decision.mutation_performed = false;
                decision.mutation_status = "failed".to_string();
                write_artifact_criticality_decision(evidence_root, &decision)?;
                Err(error).with_context(|| "program artifact cleanup failed")
            }
        },
        "remove_dir" => match fs::remove_dir(path) {
            Ok(()) => {
                decision.after_validation =
                    "directory artifact absent after autonomous cleanup".to_string();
                decision.mutation_performed = true;
                decision.mutation_status = "completed".to_string();
                let evidence_path = write_artifact_criticality_decision(evidence_root, &decision)?;
                Ok(evidence_path)
            }
            Err(error) if error.kind() == std::io::ErrorKind::NotFound => {
                decision.after_validation =
                    "directory artifact already absent before autonomous cleanup".to_string();
                decision.mutation_performed = false;
                decision.mutation_status = "already-absent".to_string();
                let evidence_path = write_artifact_criticality_decision(evidence_root, &decision)?;
                Ok(evidence_path)
            }
            Err(error) => {
                decision.after_validation = format!("cleanup failed: {error}");
                decision.mutation_performed = false;
                decision.mutation_status = "failed".to_string();
                write_artifact_criticality_decision(evidence_root, &decision)?;
                Err(error).with_context(|| "program artifact cleanup failed")
            }
        },
        "remove_dir_all" => match fs::remove_dir_all(path) {
            Ok(()) => {
                decision.after_validation =
                    "directory tree artifact absent after autonomous cleanup".to_string();
                decision.mutation_performed = true;
                decision.mutation_status = "completed".to_string();
                let evidence_path = write_artifact_criticality_decision(evidence_root, &decision)?;
                Ok(evidence_path)
            }
            Err(error) if error.kind() == std::io::ErrorKind::NotFound => {
                decision.after_validation =
                    "directory tree artifact already absent before autonomous cleanup".to_string();
                decision.mutation_performed = false;
                decision.mutation_status = "already-absent".to_string();
                let evidence_path = write_artifact_criticality_decision(evidence_root, &decision)?;
                Ok(evidence_path)
            }
            Err(error) => {
                decision.after_validation = format!("cleanup failed: {error}");
                decision.mutation_performed = false;
                decision.mutation_status = "failed".to_string();
                write_artifact_criticality_decision(evidence_root, &decision)?;
                Err(error).with_context(|| "program artifact cleanup failed")
            }
        },
        other => {
            decision.after_validation = format!("cleanup failed: unsupported operation {other}");
            decision.mutation_performed = false;
            decision.mutation_status = "blocked-unsupported-operation".to_string();
            decision.blocked_reason = Some("unsupported-destructive-operation".to_string());
            write_artifact_criticality_decision(evidence_root, &decision)?;
            bail!("program artifact cleanup failed: unsupported operation {other}");
        }
    }
}

fn checkpoint_from_plan(
    run_id: &str,
    lifecycle_id: &str,
    target: &str,
    executor: ExecutorKind,
    invocation_authority: &str,
    run_inputs: &BTreeMap<String, String>,
    plan: &ProgramLifecyclePlanResult,
    child_results: &[ProgramChildExecutionSummary],
    final_verdict: &str,
    terminal_outcome: Option<String>,
    latest_event_offset: u64,
    mut previous_recovery_attempts: BTreeMap<String, u32>,
    previous_program_recovery_action_attempts: BTreeMap<String, u32>,
    mut previous_progress_fingerprints: BTreeMap<String, ProgramRecoveryProgressFingerprint>,
    mut closeout_hygiene_suppressions: BTreeMap<String, ProgramCloseoutHygieneSuppression>,
    approvals: Vec<ProgramApprovalGrant>,
) -> ProgramLifecycleCheckpoint {
    let child_states = plan
        .child_states
        .iter()
        .map(|(id, state)| {
            (
                id.clone(),
                ProgramChildCheckpointState {
                    child_lifecycle_id: state.child_lifecycle_id.clone(),
                    target: state.target.clone(),
                    current_state: state
                        .selected_route
                        .as_ref()
                        .map(|route| route.route_id.clone())
                        .or_else(|| state.terminal_outcome.clone()),
                    final_verdict: state.final_verdict.clone(),
                    receipt_digests: state.receipt_digests.clone(),
                    gate_status: state.gate_status.clone(),
                    dependency_gate_status: state.dependency_gate_status.clone(),
                    write_scopes: state.write_scopes.clone(),
                },
            )
        })
        .collect();
    for result in child_results {
        let key = recovery_attempt_key(
            &result.child_id,
            result.blocker_class.as_deref().unwrap_or("route"),
        );
        *previous_recovery_attempts.entry(key).or_default() += result.attempts;
        *previous_recovery_attempts
            .entry(result.child_id.clone())
            .or_default() += result.attempts;
        if result.attempts > 0 {
            if let Some(state) = plan.child_states.get(&result.child_id) {
                let blocker_class = result.blocker_class.as_deref().unwrap_or("route");
                previous_progress_fingerprints.insert(
                    recovery_progress_key(&result.child_id, &result.route_id, blocker_class),
                    child_progress_fingerprint(state, &result.route_id, blocker_class),
                );
            }
        }
        if route_has_closeout_hygiene_preflight(&result.route_id) {
            let key = closeout_hygiene_suppression_key(&result.child_id, &result.route_id);
            if result.status == "blocked"
                && result.blocker_class.as_deref() == Some("artifact-ownership-unclear")
            {
                closeout_hygiene_suppressions.insert(
                    key,
                    ProgramCloseoutHygieneSuppression {
                        child_id: result.child_id.clone(),
                        route_id: result.route_id.clone(),
                        blocker_class: "artifact-ownership-unclear".to_string(),
                        message: result.error_message.clone().unwrap_or_else(|| {
                            "closeout/archive blocked by foreign or ambiguous worktree hygiene"
                                .to_string()
                        }),
                        evidence_paths: result.evidence_paths.clone(),
                        worktree_hygiene_foreign_fingerprint: result
                            .worktree_hygiene_foreign_fingerprint
                            .clone(),
                    },
                );
            } else {
                closeout_hygiene_suppressions.remove(&key);
            }
        }
    }

    ProgramLifecycleCheckpoint {
        schema_version: "octon-program-lifecycle-checkpoint-v1".to_string(),
        run_id: run_id.to_string(),
        lifecycle_id: lifecycle_id.to_string(),
        execution_strategy: plan.execution_strategy.clone(),
        target: target.to_string(),
        executor: Some(executor.as_str().to_string()),
        invocation_authority: invocation_authority.to_string(),
        timeout_seconds: None,
        max_child_concurrency: None,
        child_registry_digest: plan.child_registry_digest.clone(),
        execution_mode: plan.execution_mode.clone(),
        run_inputs: run_inputs.clone(),
        scheduler_decision: plan.runnable_batch.clone(),
        child_states,
        recovery_attempts: previous_recovery_attempts,
        program_recovery_action_attempts: previous_program_recovery_action_attempts,
        recovery_progress_fingerprints: previous_progress_fingerprints,
        closeout_hygiene_suppressions,
        residue_cleanup_attempts: BTreeMap::new(),
        approvals,
        program_recovery_recipe_validation_status: plan
            .program_recovery_recipe_validation_status
            .clone(),
        program_recovery_recipe_validation_failures: plan
            .program_recovery_recipe_validation_failures
            .clone(),
        program_recovery_recipe_blocker_class: plan.program_recovery_recipe_blocker_class.clone(),
        program_recovery_recipe_route_id: plan.program_recovery_recipe_route_id.clone(),
        program_recovery_recipe_delegation_contract_basis: plan
            .program_recovery_recipe_delegation_contract_basis
            .clone(),
        latest_event_offset,
        latest_event_index: latest_event_offset,
        latest_event_sha256: None,
        event_log_sha256: None,
        derived_from_event_index: latest_event_offset,
        atomic_barrier_state: None,
        cancelled_at: if final_verdict == "cancelled" {
            Some(now_rfc3339().unwrap_or_else(|_| "unknown".to_string()))
        } else {
            None
        },
        cancel_reason: if final_verdict == "cancelled" {
            Some("cancellation token observed during route dispatch".to_string())
        } else {
            None
        },
        cancellation_evidence_path: None,
        terminal_outcome,
        final_verdict: final_verdict.to_string(),
        resume_instruction: format!("octon lifecycle resume --run-id {run_id}"),
    }
}

fn write_program_checkpoint_snapshot(
    octon_dir: &Path,
    control_root: &Path,
    run_id: &str,
    lifecycle_id: &str,
    target: &str,
    executor: ExecutorKind,
    invocation_authority: &str,
    run_inputs: &BTreeMap<String, String>,
    plan: &ProgramLifecyclePlanResult,
    child_results: &[ProgramChildExecutionSummary],
    final_verdict: &str,
    terminal_outcome: Option<String>,
    previous_checkpoint: Option<&ProgramLifecycleCheckpoint>,
    options: &RunLifecycleOptions,
    residue_cleanup_attempts: Option<&BTreeMap<String, ProgramResidueCleanupAttempt>>,
) -> Result<ProgramLifecycleCheckpoint> {
    let mut checkpoint = checkpoint_from_plan(
        run_id,
        lifecycle_id,
        target,
        executor,
        invocation_authority,
        run_inputs,
        plan,
        child_results,
        final_verdict,
        terminal_outcome,
        count_program_events(control_root)?,
        previous_checkpoint
            .map(|checkpoint| checkpoint.recovery_attempts.clone())
            .unwrap_or_default(),
        previous_checkpoint
            .map(|checkpoint| checkpoint.program_recovery_action_attempts.clone())
            .unwrap_or_default(),
        previous_checkpoint
            .map(|checkpoint| checkpoint.recovery_progress_fingerprints.clone())
            .unwrap_or_default(),
        plan.closeout_hygiene_suppressions.clone(),
        previous_checkpoint
            .map(|checkpoint| checkpoint.approvals.clone())
            .unwrap_or_default(),
    );
    checkpoint.residue_cleanup_attempts = residue_cleanup_attempts
        .cloned()
        .or_else(|| {
            previous_checkpoint.map(|checkpoint| checkpoint.residue_cleanup_attempts.clone())
        })
        .unwrap_or_default();
    checkpoint.timeout_seconds = options.timeout_seconds;
    checkpoint.max_child_concurrency = options.max_child_concurrency;
    if final_verdict == "cancelled" {
        if let Some(existing) = read_program_checkpoint_for_run(octon_dir, run_id)? {
            if existing.cancelled_at.is_some() || existing.cancellation_evidence_path.is_some() {
                checkpoint.cancelled_at = existing.cancelled_at;
                checkpoint.cancel_reason = existing.cancel_reason;
                checkpoint.cancellation_evidence_path = existing.cancellation_evidence_path;
                checkpoint.terminal_outcome = Some("cancelled".to_string());
                checkpoint.resume_instruction =
                    "cancelled program lifecycle runs cannot resume dispatch".to_string();
            }
        }
    }
    enrich_checkpoint_event_metadata(&mut checkpoint, control_root)?;
    let checkpoint_path = program_checkpoint_path_for_run(octon_dir, run_id)?;
    fs::write(&checkpoint_path, serde_yaml::to_string(&checkpoint)?)?;
    Ok(checkpoint)
}

fn enrich_checkpoint_event_metadata(
    checkpoint: &mut ProgramLifecycleCheckpoint,
    control_root: &Path,
) -> Result<()> {
    let events = read_program_events(control_root)?;
    let latest_index = events.last().map(|event| event.event_index).unwrap_or(0);
    checkpoint.latest_event_offset = latest_index;
    checkpoint.latest_event_index = latest_index;
    checkpoint.derived_from_event_index = latest_index;
    checkpoint.latest_event_sha256 = events.last().and_then(|event| event.event_sha256.clone());
    checkpoint.event_log_sha256 = program_event_log_digest(control_root)?;
    checkpoint.atomic_barrier_state = reconstruct_atomic_barrier_state(&events);
    Ok(())
}

fn program_checkpoint_cancelled(checkpoint: &ProgramLifecycleCheckpoint) -> bool {
    checkpoint.final_verdict == "cancelled" || checkpoint.cancelled_at.is_some()
}

fn program_cancelled_run_result(
    repo_root: &Path,
    evidence_root: &Path,
    control_root: &Path,
    checkpoint: &ProgramLifecycleCheckpoint,
    executor: &str,
) -> ProgramLifecycleRunResult {
    ProgramLifecycleRunResult {
        schema_version: "octon-program-lifecycle-run-result-v1".to_string(),
        run_id: checkpoint.run_id.clone(),
        lifecycle_id: checkpoint.lifecycle_id.clone(),
        execution_strategy: checkpoint.execution_strategy.clone(),
        target: checkpoint.target.clone(),
        executor: executor.to_string(),
        route_execution_mode: "none".to_string(),
        bundle_root: rel_display(repo_root, evidence_root),
        checkpoint_path: rel_display(repo_root, &control_root.join(PROGRAM_CHECKPOINT_FILE)),
        event_log_path: rel_display(repo_root, &program_control_event_log_path(control_root)),
        latest_event_offset: checkpoint.latest_event_offset,
        selected_parent_route: None,
        parent_route_result: None,
        selected_children: Vec::new(),
        child_results: Vec::new(),
        terminal_outcome: Some("cancelled".to_string()),
        final_verdict: "cancelled".to_string(),
    }
}

fn validate_program_checkpoint_binding(
    checkpoint: &ProgramLifecycleCheckpoint,
    sanitized_run_id: &str,
    lifecycle_id: &str,
    execution_strategy: &str,
    target: &str,
    child_registry_digest: &str,
) -> Result<()> {
    if checkpoint.run_id != sanitized_run_id {
        bail!(
            "program lifecycle run id {sanitized_run_id} is inconsistent with checkpoint run_id {}",
            checkpoint.run_id
        );
    }
    if checkpoint.lifecycle_id != lifecycle_id || checkpoint.target != target {
        bail!(
            "program lifecycle run id {sanitized_run_id} is already bound to lifecycle {} target {}; requested lifecycle {lifecycle_id} target {target}",
            checkpoint.lifecycle_id,
            checkpoint.target
        );
    }
    if checkpoint.execution_strategy != execution_strategy {
        bail!(
            "program lifecycle run id {sanitized_run_id} checkpoint execution_strategy {} differs from loaded contract strategy {execution_strategy}",
            checkpoint.execution_strategy
        );
    }
    if checkpoint.child_registry_digest != child_registry_digest
        && checkpoint.child_registry_digest != MISSING_CHILD_REGISTRY_DIGEST
    {
        bail!(
            "unsafe program resume: child registry digest changed from {} to {}",
            checkpoint.child_registry_digest,
            child_registry_digest
        );
    }
    Ok(())
}

fn read_program_checkpoint_for_run(
    octon_dir: &Path,
    run_id: &str,
) -> Result<Option<ProgramLifecycleCheckpoint>> {
    let path = program_checkpoint_path_for_run(octon_dir, run_id)?;
    if !path.is_file() {
        return Ok(None);
    }
    Ok(Some(serde_yaml::from_slice(&fs::read(path)?)?))
}

fn program_checkpoint_path_for_run(octon_dir: &Path, run_id: &str) -> Result<PathBuf> {
    Ok(octon_dir
        .join(RUN_CONTROL_ROOT_REL)
        .join(sanitize_run_id(run_id)?)
        .join(PROGRAM_CHECKPOINT_FILE))
}

fn declared_or_default_write_scopes(
    child: &ProgramChildSpec,
    child_target_rel: &str,
) -> Result<Vec<String>> {
    if child.write_scopes.is_empty() {
        return Ok(vec![child_target_rel.to_string()]);
    }
    let mut scopes = BTreeSet::new();
    scopes.insert(child_target_rel.to_string());
    for scope in &child.write_scopes {
        if !is_safe_repo_relative(scope) {
            bail!("child write scope must be repo-relative: {scope}");
        }
        scopes.insert(scope.clone());
    }
    Ok(scopes.into_iter().collect())
}

fn child_write_scopes(
    child: &ProgramChildSpec,
    child_target_abs: &Path,
    child_target_rel: &str,
) -> Result<Vec<String>> {
    if !child.write_scopes.is_empty() {
        return declared_or_default_write_scopes(child, child_target_rel);
    }
    let mut scopes = BTreeSet::new();
    scopes.insert(child_target_rel.to_string());
    let manifest_path = child_target_abs.join("proposal.yml");
    if manifest_path.is_file() {
        let manifest: serde_yaml::Value = serde_yaml::from_slice(&fs::read(&manifest_path)?)?;
        if let Some(targets) = manifest
            .get("promotion_targets")
            .and_then(serde_yaml::Value::as_sequence)
        {
            for target in targets {
                let Some(raw) = target.as_str() else {
                    bail!(
                        "promotion target in {} must be a string",
                        manifest_path.display()
                    );
                };
                if !is_safe_repo_relative(raw) {
                    bail!("promotion target must be repo-relative: {raw}");
                }
                scopes.insert(raw.to_string());
            }
        }
    }
    Ok(scopes.into_iter().collect())
}

fn atomic_spec_for_route<'a>(
    contract: &'a LifecycleContract,
    route_id: &str,
) -> Result<&'a RouteAtomicSpec> {
    let route = route_by_id(contract, route_id)
        .with_context(|| format!("atomic source route missing: {route_id}"))?;
    let atomic = route
        .atomic
        .as_ref()
        .with_context(|| format!("route {route_id} does not declare atomic metadata"))?;
    validate_atomic_route_ref(contract, route_id, &atomic.stage_route_id, "stage_route_id")?;
    validate_atomic_route_ref(
        contract,
        route_id,
        &atomic.commit_route_id,
        "commit_route_id",
    )?;
    let has_rollback = atomic.rollback_route_id.as_deref().is_some();
    let has_compensation = atomic.compensation_route_id.as_deref().is_some();
    if !has_rollback && !has_compensation {
        bail!("route {route_id} atomic metadata must declare rollback_route_id or compensation_route_id");
    }
    if let Some(rollback) = atomic.rollback_route_id.as_deref() {
        validate_atomic_route_ref(contract, route_id, rollback, "rollback_route_id")?;
    }
    if let Some(compensation) = atomic.compensation_route_id.as_deref() {
        validate_atomic_route_ref(contract, route_id, compensation, "compensation_route_id")?;
    }
    Ok(atomic)
}

fn validate_atomic_route_ref(
    contract: &LifecycleContract,
    route_id: &str,
    referenced_route_id: &str,
    label: &str,
) -> Result<()> {
    if referenced_route_id == route_id {
        bail!("route {route_id} atomic {label} must not reference itself");
    }
    let referenced = route_by_id(contract, referenced_route_id).with_context(|| {
        format!("route {route_id} atomic {label} missing: {referenced_route_id}")
    })?;
    if referenced.atomic.is_some() {
        bail!("route {route_id} atomic {label} must reference a non-atomic helper route");
    }
    Ok(())
}

fn file_digest(path: &Path) -> Result<String> {
    Ok(format!(
        "sha256:{}",
        hex::encode(Sha256::digest(fs::read(path)?))
    ))
}

fn program_control_event_log_path(control_root: &Path) -> PathBuf {
    control_root.join("program-events.ndjson")
}

fn program_evidence_event_log_path(evidence_root: &Path) -> PathBuf {
    evidence_root.join("program-events.ndjson")
}

fn append_program_event(
    control_root: &Path,
    evidence_root: &Path,
    run_id: &str,
    event_type: &str,
    child_id: Option<&str>,
    route_id: Option<&str>,
    message: &str,
    data: BTreeMap<String, String>,
) -> Result<u64> {
    if let Some(child_id) = child_id {
        validate_program_id_field(child_id, "program event child_id")?;
    }
    if let Some(route_id) = route_id {
        validate_program_id_field(route_id, "program event route_id")?;
    }
    fs::create_dir_all(control_root)?;
    fs::create_dir_all(evidence_root)?;
    let event_index = count_program_events(control_root)? + 1;
    let previous_event_sha256 = read_last_program_event(control_root)?
        .and_then(|event| event.event_sha256)
        .or_else(|| last_program_event_line_hash(control_root).ok().flatten());
    let mut event = ProgramEvent {
        schema_version: "octon-program-lifecycle-event-v2".to_string(),
        run_id: run_id.to_string(),
        event_index,
        previous_event_sha256,
        event_sha256: None,
        event_type: event_type.to_string(),
        event_category: Some(event_category_for_type(event_type).to_string()),
        recorded_at: now_rfc3339()?,
        actor: Some("lifecycle-program-controller".to_string()),
        registry_digest: data.get("registry_digest").cloned(),
        checkpoint_digest: data.get("checkpoint_digest").cloned(),
        child_id: child_id.map(str::to_string),
        route_id: route_id.map(str::to_string),
        atomic_phase: atomic_phase_for_type(event_type).map(str::to_string),
        message: message.to_string(),
        data,
    };
    event.event_sha256 = Some(program_event_hash(&event)?);
    let line = serde_json::to_string(&event)?;
    for path in [
        program_control_event_log_path(control_root),
        program_evidence_event_log_path(evidence_root),
    ] {
        let mut file = OpenOptions::new().create(true).append(true).open(path)?;
        writeln!(file, "{line}")?;
    }
    Ok(event_index)
}

fn read_last_program_event(control_root: &Path) -> Result<Option<ProgramEvent>> {
    Ok(read_program_events(control_root)?.pop())
}

fn last_program_event_line_hash(control_root: &Path) -> Result<Option<String>> {
    let lines = read_program_event_lines(control_root)?;
    Ok(lines
        .lines()
        .rev()
        .find(|line| !line.trim().is_empty())
        .map(|line| sha256_digest(line.as_bytes())))
}

fn program_event_hash(event: &ProgramEvent) -> Result<String> {
    let mut event = event.clone();
    event.event_sha256 = None;
    Ok(sha256_digest(serde_json::to_string(&event)?.as_bytes()))
}

fn event_category_for_type(event_type: &str) -> &'static str {
    if event_type.starts_with("atomic-") || event_type.starts_with("program-atomic") {
        "atomic"
    } else if event_type.contains("approval") {
        "approval"
    } else if event_type.contains("recovery") {
        "recovery"
    } else if event_type.contains("lock") {
        "lock"
    } else if event_type.contains("closeout") {
        "closeout"
    } else if event_type.contains("mutation") {
        "mutation"
    } else if event_type.contains("cancel") {
        "operator-control"
    } else {
        "lifecycle"
    }
}

fn atomic_phase_for_type(event_type: &str) -> Option<&'static str> {
    if event_type.contains("preflight") {
        Some("preflight")
    } else if event_type.contains("lock") {
        Some("lock")
    } else if event_type.contains("stage") {
        Some("stage")
    } else if event_type.contains("barrier") {
        Some("barrier-verify")
    } else if event_type.contains("commit") {
        Some("commit")
    } else if event_type.contains("rollback") {
        Some("rollback")
    } else if event_type.contains("compensation") || event_type.contains("compensate") {
        Some("compensate")
    } else if event_type.contains("closeout") {
        Some("closeout")
    } else {
        None
    }
}

fn sha256_digest(bytes: &[u8]) -> String {
    format!("sha256:{}", hex::encode(Sha256::digest(bytes)))
}

fn count_program_events(control_root: &Path) -> Result<u64> {
    let path = program_control_event_log_path(control_root);
    if !path.is_file() {
        return Ok(0);
    }
    Ok(fs::read_to_string(path)?
        .lines()
        .filter(|line| !line.trim().is_empty())
        .count() as u64)
}

fn effective_checkpoint_event_index(checkpoint: &ProgramLifecycleCheckpoint) -> u64 {
    if checkpoint.latest_event_index > 0 {
        checkpoint.latest_event_index
    } else {
        checkpoint.latest_event_offset
    }
}

fn validate_event_offsets(events: &[ProgramEvent], errors: &mut Vec<String>) {
    let mut seen = BTreeSet::new();
    for (offset, event) in events.iter().enumerate() {
        if !seen.insert(event.event_index) {
            errors.push(format!("duplicate event index {}", event.event_index));
        }
        let expected = offset as u64 + 1;
        if event.event_index != expected {
            errors.push(format!(
                "missing or out-of-order event offset: expected {expected}, found {}",
                event.event_index
            ));
        }
    }
}

fn validate_event_hash_chain(
    events: &[ProgramEvent],
    legacy_event_log: bool,
    errors: &mut Vec<String>,
) -> Result<()> {
    if legacy_event_log {
        return Ok(());
    }
    let mut previous_hash: Option<String> = None;
    for event in events {
        let expected_hash = program_event_hash(event)?;
        match event.event_sha256.as_ref() {
            Some(actual) if actual == &expected_hash => {}
            Some(actual) => errors.push(format!(
                "hash-chain break at event {}: expected {}, found {}",
                event.event_index, expected_hash, actual
            )),
            None => errors.push(format!(
                "hash-chain break at event {}: missing event_sha256",
                event.event_index
            )),
        }
        if event.previous_event_sha256 != previous_hash {
            errors.push(format!(
                "hash-chain break at event {}: previous hash mismatch",
                event.event_index
            ));
        }
        previous_hash = event.event_sha256.clone();
    }
    Ok(())
}

fn validate_program_event_transitions(events: &[ProgramEvent], errors: &mut Vec<String>) {
    if let Some(first) = events.first() {
        if first.event_type != "run-started" {
            errors.push(
                "impossible transition: event log does not start with run-started".to_string(),
            );
        }
    }
    let mut started_routes = BTreeSet::new();
    for event in events {
        match event.event_type.as_str() {
            "child-route-started" | "recovery-attempt" => {
                if let (Some(child), Some(route)) = (&event.child_id, &event.route_id) {
                    started_routes.insert((child.clone(), route.clone()));
                }
            }
            "child-route-finished" => {
                if let (Some(child), Some(route)) = (&event.child_id, &event.route_id) {
                    if !started_routes.contains(&(child.clone(), route.clone())) {
                        errors.push(format!(
                            "impossible transition: child route finished before start for {child}:{route}"
                        ));
                    }
                }
            }
            "closeout"
                if events
                    .iter()
                    .take_while(|candidate| candidate.event_index < event.event_index)
                    .all(|candidate| candidate.event_type != "plan-created") =>
            {
                errors.push("impossible transition: closeout before plan-created".to_string());
            }
            _ => {}
        }
    }
}

fn program_event_log_digest(control_root: &Path) -> Result<Option<String>> {
    let path = program_control_event_log_path(control_root);
    if !path.is_file() {
        return Ok(None);
    }
    Ok(Some(sha256_digest(&fs::read(path)?)))
}

fn reconstruct_atomic_barrier_state(events: &[ProgramEvent]) -> Option<ProgramAtomicBarrierState> {
    let mut state = ProgramAtomicBarrierState {
        phase: String::new(),
        staged_children: Vec::new(),
        committed_children: Vec::new(),
        compensated_children: Vec::new(),
        verified: false,
        unsafe_reason: None,
    };
    for event in events.iter().filter(|event| {
        event.event_category.as_deref() == Some("atomic")
            || event.event_type.starts_with("atomic-")
            || event.event_type.starts_with("program-atomic")
            || event.event_type.contains("barrier")
    }) {
        if let Some(phase) = event
            .atomic_phase
            .as_deref()
            .or_else(|| atomic_phase_for_type(&event.event_type))
        {
            state.phase = phase.to_string();
        }
        let status = event.data.get("status").map(String::as_str);
        if status == Some("blocked-unsafe") {
            state.unsafe_reason = Some(event.message.clone());
        }
        if status != Some("completed") {
            if event.event_type.contains("finished") && status.is_some() {
                continue;
            }
        }
        match event.event_type.as_str() {
            "atomic-stage-finished" => push_unique_child(&mut state.staged_children, event),
            "atomic-commit-finished" => push_unique_child(&mut state.committed_children, event),
            "atomic-compensation-finished" | "atomic-compensate-finished" => {
                push_unique_child(&mut state.compensated_children, event)
            }
            "atomic-barrier-verified" => state.verified = true,
            _ => {}
        }
    }
    if state.phase.is_empty() {
        None
    } else {
        Some(state)
    }
}

fn push_unique_child(children: &mut Vec<String>, event: &ProgramEvent) {
    let Some(child_id) = event.child_id.as_ref() else {
        return;
    };
    if !children.iter().any(|existing| existing == child_id) {
        children.push(child_id.clone());
    }
}

fn evidence_completeness(evidence_root: &Path, control_root: &Path) -> BTreeMap<String, bool> {
    BTreeMap::from([
        (
            "program_plan".to_string(),
            evidence_root.join("program-plan.yml").is_file(),
        ),
        (
            "checkpoint".to_string(),
            control_root.join(PROGRAM_CHECKPOINT_FILE).is_file(),
        ),
        (
            "scheduler_decision".to_string(),
            evidence_root.join("scheduler-decision.yml").is_file(),
        ),
        (
            "event_log".to_string(),
            program_control_event_log_path(control_root).is_file(),
        ),
        (
            "recovery_log".to_string(),
            evidence_root.join("recovery-log.yml").is_file(),
        ),
        (
            "aggregate_closeout_receipt".to_string(),
            evidence_root
                .join("aggregate-closeout-receipt.yml")
                .is_file(),
        ),
    ])
}

fn read_program_events(control_root: &Path) -> Result<Vec<ProgramEvent>> {
    read_program_event_lines(control_root)?
        .lines()
        .filter(|line| !line.trim().is_empty())
        .map(|line| serde_json::from_str(line).map_err(Into::into))
        .collect()
}

fn read_program_event_lines(control_root: &Path) -> Result<String> {
    let path = program_control_event_log_path(control_root);
    if !path.is_file() {
        return Ok(String::new());
    }
    Ok(fs::read_to_string(path)?)
}

fn event_data<'a, I>(pairs: I) -> BTreeMap<String, String>
where
    I: IntoIterator<Item = (&'a str, &'a str)>,
{
    pairs
        .into_iter()
        .map(|(key, value)| (key.to_string(), value.to_string()))
        .collect()
}

fn program_event_data<'a, I>(pairs: I) -> BTreeMap<String, String>
where
    I: IntoIterator<Item = (&'a str, &'a str)>,
{
    let mut data = event_data(pairs);
    data.insert(
        "execution_strategy".to_string(),
        LifecycleExecutionStrategy::OrchestratedReplanLoop
            .as_str()
            .to_string(),
    );
    data
}

fn program_step_event_data<'a, I>(
    step_context: Option<&ProgramExecutionStepContext>,
    step_kind: &str,
    pairs: I,
) -> BTreeMap<String, String>
where
    I: IntoIterator<Item = (&'a str, &'a str)>,
{
    let mut data = program_event_data(pairs);
    if let Some(step_context) = step_context {
        data.insert(
            "step_index".to_string(),
            step_context.step_index.to_string(),
        );
        data.insert(
            "step_number".to_string(),
            step_context.step_number.to_string(),
        );
        data.insert("step_kind".to_string(), step_kind.to_string());
    }
    data
}

fn program_step_kind_for_plan(
    execute_routes: bool,
    plan: &ProgramLifecyclePlanResult,
) -> &'static str {
    if !execute_routes {
        "no-dispatch"
    } else if plan.program_route.is_some() {
        "parent-route-dispatch"
    } else if !plan.runnable_batch.is_empty() {
        "child-batch-dispatch"
    } else {
        "no-dispatch"
    }
}

fn write_program_aggregate_closeout(
    octon_dir: &Path,
    evidence_root: &Path,
    checkpoint: &ProgramLifecycleCheckpoint,
    plan: &ProgramLifecyclePlanResult,
) -> Result<()> {
    let receipt = verify_program_closeout(octon_dir, evidence_root, checkpoint, plan)?;
    fs::write(
        evidence_root.join("aggregate-closeout-receipt.yml"),
        serde_yaml::to_string(&receipt)?,
    )?;
    fs::write(
        evidence_root.join("aggregate-closeout.yml"),
        serde_yaml::to_string(&receipt)?,
    )?;
    Ok(())
}

fn should_write_program_aggregate_closeout(terminal_outcome: Option<&str>) -> bool {
    matches!(terminal_outcome, Some("archived" | "implemented"))
}

fn verify_program_closeout(
    octon_dir: &Path,
    evidence_root: &Path,
    checkpoint: &ProgramLifecycleCheckpoint,
    plan: &ProgramLifecyclePlanResult,
) -> Result<ProgramCloseoutReceipt> {
    let repo_root = repo_root_for_octon(octon_dir)?;
    let context = load_program_context(
        octon_dir,
        &checkpoint.lifecycle_id,
        Path::new(&checkpoint.target),
    )?;
    let program = context
        .loaded
        .contract
        .program
        .as_ref()
        .context("program closeout requires a program lifecycle contract")?;
    validate_authority_boundaries(program)?;
    let policy = program.closeout_policy.as_ref();
    let allowed_outcomes = policy
        .map(|policy| policy.required_child_terminal_outcomes.as_slice())
        .unwrap_or(&[]);
    let mut checks = BTreeMap::new();
    if let Some(blocker) = plan
        .program_blockers
        .iter()
        .find(|blocker| blocker.blocker_class == "authority-boundary-ambiguous")
    {
        bail!("program closeout blocked: {}", blocker.message);
    }
    verify_parent_program_closeout_receipts(&repo_root, plan)?;
    verify_parent_does_not_own_child_surfaces(&repo_root, checkpoint)?;
    for state in plan.child_states.values() {
        if state.deferred {
            let registry_child = context
                .registry
                .children
                .iter()
                .find(|child| child.child_id == state.child_id)
                .with_context(|| {
                    format!("program closeout missing registry child {}", state.child_id)
                })?;
            if state.seed_role.is_none()
                && state.rollback_posture.is_none()
                && registry_child.supersession_evidence.is_none()
            {
                bail!(
                    "program closeout blocked: deferred child {} lacks explicit evidence metadata",
                    state.child_id
                );
            }
            if matches!(
                state.rollback_posture.as_deref(),
                Some("superseded" | "replaced" | "rejected")
            ) && registry_child.supersession_evidence.is_none()
            {
                bail!(
                    "program closeout blocked: deferred child {} lacks supersession/rejection evidence",
                    state.child_id
                );
            }
            if let Some(evidence_ref) = registry_child.supersession_evidence.as_deref() {
                verify_program_evidence_reference(
                    &repo_root,
                    &state.child_id,
                    evidence_ref,
                    "deferred/supersession/rejection evidence",
                )?;
            }
            checks.insert(
                format!("child:{}:deferred-evidence", state.child_id),
                "present".to_string(),
            );
            continue;
        }
        if !state.required {
            continue;
        }
        if !state.blockers.is_empty() {
            bail!(
                "program closeout blocked: required child {} has unresolved blockers",
                state.child_id
            );
        }
        if Path::new(&state.target).starts_with(&checkpoint.target) {
            bail!(
                "program closeout blocked: child {} target is ambiguous with parent authority",
                state.child_id
            );
        }
        let outcome = state.terminal_outcome.as_deref().with_context(|| {
            format!(
                "program closeout blocked: required child {} has no terminal outcome",
                state.child_id
            )
        })?;
        if !allowed_outcomes.is_empty()
            && !allowed_outcomes.iter().any(|allowed| allowed == &outcome)
        {
            bail!(
                "program closeout blocked: child {} terminal outcome {} is not allowed",
                state.child_id,
                outcome
            );
        }
        checks.insert(
            format!("child:{}:terminal-outcome", state.child_id),
            outcome.to_string(),
        );
        verify_child_receipts_for_closeout(octon_dir, &repo_root, policy, state)?;
        verify_child_authority_surfaces_for_closeout(&repo_root, checkpoint, state)?;
        checks.insert(
            format!("child:{}:receipts", state.child_id),
            "fresh-child-owned".to_string(),
        );
    }
    if policy
        .map(|policy| policy.require_aggregate_evidence)
        .unwrap_or(false)
    {
        for (label, path) in [
            ("program-plan", evidence_root.join("program-plan.yml")),
            (
                "scheduler-decision",
                evidence_root.join("scheduler-decision.yml"),
            ),
            ("summary", evidence_root.join("summary.md")),
            ("recovery-log", evidence_root.join("recovery-log.yml")),
        ] {
            if !path.is_file() {
                bail!("program closeout blocked: missing aggregate evidence {label}");
            }
            checks.insert(format!("aggregate:{label}"), "present".to_string());
        }
    }
    checks.insert(
        "authority:parent-evidence-summary-only".to_string(),
        "enforced".to_string(),
    );
    checks.insert(
        "authority:child-promotion-targets-child-owned".to_string(),
        "enforced".to_string(),
    );
    checks.insert(
        "authority:child-archive-metadata-child-owned".to_string(),
        "enforced".to_string(),
    );
    Ok(ProgramCloseoutReceipt {
        schema_version: "octon-program-aggregate-closeout-receipt-v1".to_string(),
        run_id: checkpoint.run_id.clone(),
        lifecycle_id: checkpoint.lifecycle_id.clone(),
        execution_strategy: checkpoint.execution_strategy.clone(),
        target: checkpoint.target.clone(),
        execution_mode: checkpoint.execution_mode.clone(),
        final_verdict: checkpoint.final_verdict.clone(),
        aggregate_state: plan.aggregate_state.clone(),
        checks,
        authority_boundary:
            "parent evidence summarizes only; child receipts, promotion targets, and archive metadata remain child-owned"
                .to_string(),
    })
}

fn verify_parent_program_closeout_receipts(
    repo_root: &Path,
    plan: &ProgramLifecyclePlanResult,
) -> Result<()> {
    verify_parent_receipt_field(
        repo_root,
        plan,
        "program-implementation-conformance",
        "verdict",
        "pass",
    )?;
    verify_parent_receipt_field(
        repo_root,
        plan,
        "program-implementation-conformance",
        "child_authority_preserved",
        "yes",
    )?;
    verify_parent_receipt_field(
        repo_root,
        plan,
        "program-post-implementation-drift",
        "verdict",
        "pass",
    )?;
    verify_parent_receipt_field(
        repo_root,
        plan,
        "program-post-implementation-drift",
        "child_authority_preserved",
        "yes",
    )?;
    verify_parent_receipt_field(repo_root, plan, "proposal-closeout", "verdict", "pass")?;
    verify_parent_receipt_field(
        repo_root,
        plan,
        "proposal-closeout",
        "archive_authorized",
        "yes",
    )?;
    verify_parent_receipt_field(
        repo_root,
        plan,
        "proposal-closeout",
        "child_authority_preserved",
        "yes",
    )
}

fn verify_parent_receipt_field(
    repo_root: &Path,
    plan: &ProgramLifecyclePlanResult,
    receipt_id: &str,
    field: &str,
    expected: &str,
) -> Result<()> {
    let Some(receipt) = plan.parent_receipt_states.get(receipt_id) else {
        return Ok(());
    };
    if !receipt.exists {
        bail!("program closeout blocked: missing parent receipt {receipt_id}");
    }
    if !receipt.missing_required_fields.is_empty() {
        bail!(
            "program closeout blocked: parent receipt {} missing required fields: {}",
            receipt_id,
            receipt.missing_required_fields.join(",")
        );
    }
    let fields = parse_receipt_fields(&repo_root.join(&receipt.path))?;
    let actual = fields.get(field).map(String::as_str);
    if actual != Some(expected) {
        bail!(
            "program closeout blocked: parent receipt {receipt_id} field {field} must be {expected}"
        );
    }
    Ok(())
}

fn verify_child_receipts_for_closeout(
    octon_dir: &Path,
    repo_root: &Path,
    policy: Option<&ProgramCloseoutPolicySpec>,
    state: &ProgramChildPlanState,
) -> Result<()> {
    let child_contract = load_lifecycle_contract(octon_dir, &state.child_lifecycle_id)?;
    let child_target_abs = resolve_lifecycle_target_path(repo_root, Path::new(&state.target))?;
    if child_contract.contract.receipts.is_empty() {
        return Ok(());
    }
    let outcome = state.terminal_outcome.as_deref().with_context(|| {
        format!(
            "program closeout blocked: child {} has no terminal outcome",
            state.child_id
        )
    })?;
    let required_receipts = policy
        .map(|policy| {
            child_closeout_required_receipt_ids(policy, &child_contract.contract, outcome)
        })
        .unwrap_or_else(|| {
            child_contract
                .contract
                .receipts
                .iter()
                .map(|receipt| receipt.receipt_id.clone())
                .collect()
        });
    let live_plan = plan_lifecycle_from_octon_dir(
        octon_dir,
        &state.child_lifecycle_id,
        Path::new(&state.target),
    )?;
    for receipt in child_contract
        .contract
        .receipts
        .iter()
        .filter(|receipt| required_receipts.contains(&receipt.receipt_id))
    {
        let receipt_path = resolve_target_local_path(
            &child_target_abs,
            &receipt.path,
            "program closeout child receipt",
        )?;
        if !receipt_path.is_file() {
            bail!(
                "program closeout blocked: child {} missing receipt {} at {}",
                state.child_id,
                receipt.receipt_id,
                receipt_path.display()
            );
        }
        if !receipt_path.starts_with(&child_target_abs) {
            bail!(
                "program closeout blocked: child {} receipt {} is outside child target",
                state.child_id,
                receipt.receipt_id
            );
        }
        let live_receipt = live_plan
            .receipt_states
            .get(&receipt.receipt_id)
            .with_context(|| {
                format!(
                    "program closeout blocked: child {} missing live receipt state {}",
                    state.child_id, receipt.receipt_id
                )
            })?;
        if !live_receipt.missing_required_fields.is_empty() {
            bail!(
                "program closeout blocked: child {} receipt {} missing required fields: {}",
                state.child_id,
                receipt.receipt_id,
                live_receipt.missing_required_fields.join(",")
            );
        }
        if live_receipt.stale == Some(true) {
            bail!(
                "program closeout blocked: child {} receipt {} is stale",
                state.child_id,
                receipt.receipt_id
            );
        }
        let observed_child_digest = live_receipt
            .current_digest
            .as_ref()
            .or(live_receipt.stored_digest.as_ref())
            .cloned()
            .unwrap_or(file_digest(&receipt_path)?);
        if let Some(expected_digest) = state.receipt_digests.get(&receipt.receipt_id) {
            if expected_digest != &observed_child_digest {
                bail!(
                    "program closeout blocked: child {} receipt {} digest drifted from {} to {}",
                    state.child_id,
                    receipt.receipt_id,
                    expected_digest,
                    observed_child_digest
                );
            }
        } else if receipt.freshness.is_some() {
            bail!(
                "program closeout blocked: child {} receipt {} lacks checkpointed freshness digest",
                state.child_id,
                receipt.receipt_id
            );
        }
    }
    if let Some(policy) = policy {
        validate_child_closeout_receipt_fields(policy, outcome, &live_plan.receipt_states)
            .with_context(|| {
                format!(
                    "program closeout blocked: child {} terminal outcome {} receipt fields invalid",
                    state.child_id, outcome
                )
            })?;
    }
    Ok(())
}

fn verify_parent_does_not_own_child_surfaces(
    repo_root: &Path,
    checkpoint: &ProgramLifecycleCheckpoint,
) -> Result<()> {
    let parent_manifest = repo_root.join(&checkpoint.target).join("proposal.yml");
    if !parent_manifest.is_file() {
        return Ok(());
    }
    let manifest: serde_yaml::Value = serde_yaml::from_slice(&fs::read(&parent_manifest)?)?;
    for forbidden in [
        "child_receipts",
        "child_validation_verdict",
        "child_validation_verdicts",
        "child_validation_results",
        "child_promotion_targets",
        "child_archive_metadata",
    ] {
        if manifest.get(forbidden).is_some() {
            bail!(
                "program closeout blocked: parent manifest contains child-owned surface {forbidden}"
            );
        }
    }
    let parent_root = repo_root.join(&checkpoint.target);
    for forbidden_path in [
        "support/child-validation-verdicts.yml",
        "support/child-validation-verdicts.yaml",
        "support/child-validation-verdicts.md",
        "resources/child-validation-verdicts.yml",
        "resources/child-validation-verdicts.yaml",
        "resources/child-validation-verdicts.md",
    ] {
        if parent_root.join(forbidden_path).exists() {
            bail!(
                "program closeout blocked: parent evidence contains child-owned validation verdict surface {forbidden_path}"
            );
        }
    }
    Ok(())
}

fn verify_program_evidence_reference(
    repo_root: &Path,
    child_id: &str,
    evidence_ref: &str,
    label: &str,
) -> Result<()> {
    if !is_safe_repo_relative(evidence_ref) {
        bail!(
            "program closeout blocked: child {} {} reference is unsafe: {}",
            child_id,
            label,
            evidence_ref
        );
    }
    let evidence_abs = resolve_lifecycle_target_path(repo_root, Path::new(evidence_ref))?;
    if !evidence_abs.is_file() {
        bail!(
            "program closeout blocked: child {} {} reference is dangling: {}",
            child_id,
            label,
            evidence_ref
        );
    }
    Ok(())
}

fn verify_child_authority_surfaces_for_closeout(
    repo_root: &Path,
    checkpoint: &ProgramLifecycleCheckpoint,
    state: &ProgramChildPlanState,
) -> Result<()> {
    let child_target_abs = resolve_lifecycle_target_path(repo_root, Path::new(&state.target))?;
    let child_manifest = child_target_abs.join("proposal.yml");
    if !child_manifest.is_file() {
        bail!(
            "program closeout blocked: child {} manifest is missing",
            state.child_id
        );
    }
    if !child_manifest.starts_with(&child_target_abs) {
        bail!(
            "program closeout blocked: child {} manifest is not child-owned",
            state.child_id
        );
    }
    let manifest: serde_yaml::Value = serde_yaml::from_slice(&fs::read(&child_manifest)?)?;
    if let Some(targets) = manifest
        .get("promotion_targets")
        .and_then(serde_yaml::Value::as_sequence)
    {
        for target in targets {
            let Some(raw) = target.as_str() else {
                bail!(
                    "program closeout blocked: child {} promotion target must be a string",
                    state.child_id
                );
            };
            if !is_safe_repo_relative(raw) {
                bail!(
                    "program closeout blocked: child {} promotion target is unsafe: {raw}",
                    state.child_id
                );
            }
            if Path::new(raw).starts_with(&checkpoint.target)
                || Path::new(raw).starts_with(WORKFLOW_EVIDENCE_ROOT_REL)
            {
                bail!(
                    "program closeout blocked: child {} promotion target overlaps parent/evidence authority: {raw}",
                    state.child_id
                );
            }
        }
    }
    for archive_key in ["archive_metadata", "archive"] {
        if let Some(value) = manifest.get(archive_key) {
            if !value.is_mapping() {
                bail!(
                    "program closeout blocked: child {} archive metadata must be a mapping",
                    state.child_id
                );
            }
        }
    }
    Ok(())
}

fn valid_program_id(value: &str) -> bool {
    !value.is_empty()
        && value
            .chars()
            .all(|ch| ch.is_ascii_lowercase() || ch.is_ascii_digit() || ch == '-')
        && value
            .chars()
            .next()
            .map(|ch| ch.is_ascii_lowercase())
            .unwrap_or(false)
}

fn valid_rollback_posture(value: &str) -> bool {
    matches!(
        value,
        "none"
            | "manual"
            | "forward-only"
            | "superseded"
            | "replaced"
            | "rejected"
            | "compensating"
            | "staged-commit"
            | "rollback-route"
    )
}

fn validate_optional_rollback_posture(value: Option<&str>, field: &str) -> Result<()> {
    if let Some(value) = value {
        if !valid_rollback_posture(value) {
            bail!("{field} is invalid: {value}");
        }
    }
    Ok(())
}

fn valid_seed_role(value: &str) -> bool {
    matches!(
        value,
        "seed" | "reference" | "seed-reference" | "first-child" | "follow-on"
    )
}

fn validate_optional_seed_role(value: Option<&str>, field: &str) -> Result<()> {
    if let Some(value) = value {
        if !valid_seed_role(value) {
            bail!("{field} is invalid: {value}");
        }
    }
    Ok(())
}

fn validate_program_id_field(value: &str, field: &str) -> Result<()> {
    if !valid_program_id(value) {
        bail!("{field} is invalid: {value}");
    }
    Ok(())
}

fn validate_optional_program_id_field(value: Option<&String>, field: &str) -> Result<()> {
    if let Some(value) = value {
        validate_program_id_field(value, field)?;
    }
    Ok(())
}

fn valid_lifecycle_id(value: &str) -> bool {
    !value.is_empty()
        && value
            .chars()
            .all(|ch| ch.is_ascii_lowercase() || ch.is_ascii_digit() || ch == '-')
        && value
            .chars()
            .next()
            .map(|ch| ch.is_ascii_lowercase() || ch.is_ascii_digit())
            .unwrap_or(false)
}

fn validate_optional_lifecycle_id_field(value: Option<&String>, field: &str) -> Result<()> {
    if let Some(value) = value {
        if !valid_lifecycle_id(value) {
            bail!("{field} is invalid: {value}");
        }
    }
    Ok(())
}

fn program_lifecycle_summary(
    run_id: &str,
    executor: &ExecutorKind,
    plan: &ProgramLifecyclePlanResult,
    final_verdict: &str,
) -> String {
    let blocker_summary = program_lifecycle_blocker_summary(plan);
    let scheduler_phase = plan.scheduler_phase.as_deref().unwrap_or("none");
    let stop_reason = plan.stop_reason.as_deref().unwrap_or("none");
    let skipped = if plan.skipped_blocked_children.is_empty() {
        "none".to_string()
    } else {
        plan.skipped_blocked_children.join(", ")
    };
    let completion_summary = program_required_child_completion_summary(plan);
    let taxonomy_summary = program_lifecycle_taxonomy_summary(plan);
    let unsafe_summary = program_unsafe_continuation_summary(plan);
    let recovery_validation_summary = program_recovery_recipe_validation_summary(plan);
    format!(
        "# Program Lifecycle Run\n\nrun_id: {run_id}\nrecorded_at: {}\nlifecycle_id: {}\nexecution_strategy: {}\ntarget: {}\nexecutor: {}\nexecution_mode: {}\nrunnable_children: {}\nscheduler_phase: {scheduler_phase}\nskipped_blocked_children: {skipped}\naggregate_state: {}\nfinal_verdict: {final_verdict}\nstop_reason: {stop_reason}\n{completion_summary}{blocker_summary}{taxonomy_summary}{recovery_validation_summary}{unsafe_summary}\nProgram evidence coordinates child lifecycle work only. Child packet manifests, receipts, promotion targets, validation verdicts, and archive metadata remain child-owned.\n",
        now_rfc3339().unwrap_or_else(|_| "unknown".to_string()),
        plan.lifecycle_id,
        plan.execution_strategy,
        plan.target,
        executor.as_str(),
        plan.execution_mode,
        plan.runnable_batch.join(", "),
        plan.aggregate_state,
    )
}

fn program_unsafe_continuation_summary(plan: &ProgramLifecyclePlanResult) -> String {
    let mut lines = Vec::new();
    if !plan.safe_repair_candidates.is_empty() {
        lines.push("safe_repair_candidates:".to_string());
        for candidate in &plan.safe_repair_candidates {
            lines.push(format!(
                "- scope: {}; child_id: {}; blocker_class: {}; route: {}; basis: {}",
                candidate.scope,
                candidate.child_id.as_deref().unwrap_or("none"),
                candidate.blocker_class,
                candidate.selected_repair_route,
                candidate.delegation_contract_basis,
            ));
        }
    }
    if !plan.unsafe_results.is_empty() {
        lines.push("unsafe_results:".to_string());
        for result in &plan.unsafe_results {
            lines.push(format!(
                "- scope: {}; child_id: {}; route: {}; status: {}; blocker_class: {}; safe_continuation_available: {}; reason: {}",
                result.scope,
                result.child_id.as_deref().unwrap_or("none"),
                result.route_id,
                result.status,
                result.blocker_class.as_deref().unwrap_or("none"),
                result.safe_continuation_available,
                result.continuation_reason,
            ));
        }
    }
    if let Some(decision) = plan.unsafe_continuation_decision.as_ref() {
        lines.push(format!("unsafe_continuation_decision: {decision}"));
    }
    if lines.is_empty() {
        String::new()
    } else {
        format!("\nUnsafe Continuation:\n{}\n", lines.join("\n"))
    }
}

fn program_recovery_recipe_validation_summary(plan: &ProgramLifecyclePlanResult) -> String {
    let Some(status) = plan.program_recovery_recipe_validation_status.as_ref() else {
        return String::new();
    };
    let failures = if plan.program_recovery_recipe_validation_failures.is_empty() {
        "none".to_string()
    } else {
        plan.program_recovery_recipe_validation_failures.join("; ")
    };
    format!(
        "\nProgram Recovery Recipe Validation:\nstatus: {status}\nblocker_class: {}\nroute_id: {}\ndelegation_contract_basis: {}\nfailures: {failures}\n",
        plan.program_recovery_recipe_blocker_class
            .as_deref()
            .unwrap_or("none"),
        plan.program_recovery_recipe_route_id
            .as_deref()
            .unwrap_or("none"),
        plan.program_recovery_recipe_delegation_contract_basis
            .as_deref()
            .unwrap_or("none"),
    )
}

fn program_required_child_completion_summary(plan: &ProgramLifecyclePlanResult) -> String {
    if plan.required_child_completion.is_empty() {
        return String::new();
    }
    let lines = plan
        .required_child_completion
        .iter()
        .map(|(child_id, completion)| {
            let terminal = if completion.terminal { "yes" } else { "no" };
            let outcome = completion.terminal_outcome.as_deref().unwrap_or("none");
            let route = completion.selected_route.as_deref().unwrap_or("none");
            let blockers = if completion.blockers.is_empty() {
                "none".to_string()
            } else {
                completion
                    .blockers
                    .iter()
                    .map(|blocker| blocker.blocker_class.as_str())
                    .collect::<Vec<_>>()
                    .join(",")
            };
            format!(
                "- child_id: {child_id}; terminal: {terminal}; terminal_outcome: {outcome}; final_verdict: {}; selected_route: {route}; blockers: {blockers}",
                completion.final_verdict
            )
        })
        .collect::<Vec<_>>();
    format!("\nRequired Child Completion:\n{}\n", lines.join("\n"))
}

fn program_lifecycle_blocker_summary(plan: &ProgramLifecyclePlanResult) -> String {
    let mut lines = Vec::new();
    for blocker in &plan.program_blockers {
        lines.push(format!(
            "- scope: program; blocker_class: {}; recovery_route: {}",
            blocker.blocker_class,
            blocker.recovery_route.as_deref().unwrap_or("none")
        ));
    }
    for (child_id, state) in &plan.child_states {
        for blocker in &state.blockers {
            lines.push(format!(
                "- scope: child; child_id: {child_id}; blocker_class: {}; recovery_route: {}",
                blocker.blocker_class,
                blocker.recovery_route.as_deref().unwrap_or("none")
            ));
        }
    }
    if lines.is_empty() {
        String::new()
    } else {
        format!("\nBlockers:\n{}\n", lines.join("\n"))
    }
}

fn program_lifecycle_taxonomy_summary(plan: &ProgramLifecyclePlanResult) -> String {
    let mut lines = Vec::new();
    for evidence in &plan.normalized_program_blockers {
        lines.push(format!(
            "- scope: program; raw_value: {}; normalized_blocker_class: {}; normalized_category: {}; disposition: {}",
            evidence.raw_value,
            evidence.normalized_blocker_class,
            evidence.normalized_category,
            evidence.disposition,
        ));
    }
    for (child_id, evidences) in &plan.normalized_child_blockers {
        for evidence in evidences {
            lines.push(format!(
                "- scope: child; child_id: {child_id}; raw_value: {}; normalized_blocker_class: {}; normalized_category: {}; disposition: {}",
                evidence.raw_value,
                evidence.normalized_blocker_class,
                evidence.normalized_category,
                evidence.disposition,
            ));
        }
    }
    for evidence in &plan.normalized_approval_blockers {
        lines.push(format!(
            "- scope: approval; raw_value: {}; normalized_blocker_class: {}; normalized_category: {}; disposition: {}",
            evidence.raw_value,
            evidence.normalized_blocker_class,
            evidence.normalized_category,
            evidence.disposition,
        ));
    }
    if lines.is_empty() {
        String::new()
    } else {
        format!("\nNormalized Taxonomy:\n{}\n", lines.join("\n"))
    }
}

fn program_cancelled_summary(
    checkpoint: &ProgramLifecycleCheckpoint,
    cancelled_at: &str,
) -> String {
    format!(
        "# Program Lifecycle Run\n\nrun_id: {}\nrecorded_at: {}\nlifecycle_id: {}\nexecution_strategy: {}\ntarget: {}\nexecutor: {}\nexecution_mode: {}\nroute_execution_mode: none\nterminal_outcome: cancelled\nfinal_verdict: cancelled\n\nProgram lifecycle cancellation is durable. Program retry/resume and child route dispatch must stop until an operator starts a new run.\n",
        checkpoint.run_id,
        cancelled_at,
        checkpoint.lifecycle_id,
        checkpoint.execution_strategy,
        checkpoint.target,
        checkpoint.executor.as_deref().unwrap_or("unknown"),
        checkpoint.execution_mode,
    )
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::time::{SystemTime, UNIX_EPOCH};

    fn blocker(class: &str) -> ProgramBlocker {
        ProgramBlocker {
            blocker_class: class.to_string(),
            message: format!("{class} blocker"),
            recovery_route: None,
        }
    }

    fn approval_blocker() -> ProgramApprovalBlocker {
        ProgramApprovalBlocker {
            child_id: "a".to_string(),
            route_id: "review-proposal".to_string(),
            reason: "approval required".to_string(),
            blocker_class: Some("authority-ambiguity".to_string()),
        }
    }

    fn test_program_spec() -> ProgramSpec {
        ProgramSpec {
            child_registry_path: "resources/child-packet-index.yml".to_string(),
            child_lifecycle_id_default: Some("proposal-packet".to_string()),
            supported_execution_modes: Vec::new(),
            atomic_policy: None,
            recovery_policy: ProgramRecoveryPolicySpec::default(),
            closeout_policy: None,
            authority_boundaries: ProgramAuthorityBoundarySpec::default(),
        }
    }

    fn test_recovery_recipe(blocker_class: &str) -> ProgramRecoveryRecipeSpec {
        ProgramRecoveryRecipeSpec {
            blocker_class: blocker_class.to_string(),
            recovery_route_id: None,
            recovery_action_id: None,
            preconditions: Vec::new(),
            idempotency_class: Some("idempotent-rerun".to_string()),
            human_required: false,
            retry_budget: Some(1),
            dependent_handling: Some("continue-independent".to_string()),
            post_attempt_validation: vec!["replan-live-state".to_string()],
            replan_behavior: Some("after-attempt".to_string()),
            allowed_authority_zones: vec![AUTHORITY_ZONE_WORKSPACE_DECLARED.to_string()],
            allowed_artifact_classes: vec![ARTIFACT_CLASS_WORKSPACE_SOURCE.to_string()],
            operation_class: Some(OPERATION_CLASS_RETRY_CHILD_ROUTE.to_string()),
            requires_run_binding: false,
            requires_declared_write_scope: true,
            requires_zone_evidence: true,
            human_required_for_zones: Vec::new(),
        }
    }

    #[test]
    fn authority_zone_classifies_representative_paths() {
        let repo = Path::new("/workspace/octon");
        let run_id = "run-1";

        let run_evidence = classify_authority_zone(
            repo,
            run_id,
            None,
            None,
            None,
            "append-run-evidence",
            &[repo.join(".octon/state/evidence/runs/run-1/events.yml")],
            &[],
            None,
        );
        assert_eq!(run_evidence.authority_zone, AUTHORITY_ZONE_RUN_BOUND);
        assert_eq!(run_evidence.artifact_class, ARTIFACT_CLASS_RUN_EVIDENCE);
        assert!(run_evidence.autonomous_allowed);

        let previous_run_evidence = classify_authority_zone(
            repo,
            run_id,
            None,
            None,
            None,
            "append-run-evidence",
            &[repo.join(".octon/state/evidence/runs/previous-run/events.yml")],
            &[],
            None,
        );
        assert_eq!(
            previous_run_evidence.authority_zone,
            AUTHORITY_ZONE_PROTECTED_OR_EXTERNAL
        );
        assert!(!previous_run_evidence.autonomous_allowed);

        let generated = classify_authority_zone(
            repo,
            run_id,
            None,
            None,
            None,
            OPERATION_CLASS_REFRESH_GENERATED_PROJECTION,
            &[repo.join(".octon/generated/effective/extensions/catalog.effective.yml")],
            &[],
            None,
        );
        assert_eq!(generated.authority_zone, AUTHORITY_ZONE_GENERATED_DERIVED);
        assert_eq!(generated.artifact_class, ARTIFACT_CLASS_GENERATED_DERIVED);
        assert!(generated.autonomous_allowed);
        assert!(generated.generated_non_authority);
        assert!(generated
            .forbidden_authority_consumers
            .iter()
            .any(|consumer| consumer == "child-receipt"));

        let authored = classify_authority_zone(
            repo,
            run_id,
            None,
            None,
            None,
            "durable-authority-mutation",
            &[repo.join(".octon/framework/constitution/contracts/authority/family.yml")],
            &[],
            None,
        );
        assert_eq!(authored.authority_zone, AUTHORITY_ZONE_AUTHORED_GOVERNANCE);
        assert_eq!(
            authored.fail_closed_blocker,
            BLOCKER_DURABLE_AUTHORITY_APPROVAL_REQUIRED
        );
        assert!(!authored.autonomous_allowed);

        let workspace = classify_authority_zone(
            repo,
            run_id,
            Some("child-a"),
            Some("implement"),
            None,
            OPERATION_CLASS_EXECUTE_CHILD_ROUTE,
            &[repo.join("src/lib.rs")],
            &["src".to_string()],
            None,
        );
        assert_eq!(workspace.authority_zone, AUTHORITY_ZONE_WORKSPACE_DECLARED);
        assert!(authority_decision_allows_route_unattended(&workspace));

        let proposal_packet = classify_authority_zone(
            repo,
            run_id,
            Some("child-a"),
            Some("run-packet-implementation"),
            None,
            OPERATION_CLASS_EXECUTE_CHILD_ROUTE,
            &[repo.join(".octon/inputs/exploratory/proposals/architecture/example-child")],
            &[".octon/inputs/exploratory/proposals/architecture/example-child".to_string()],
            None,
        );
        assert_eq!(
            proposal_packet.authority_zone,
            AUTHORITY_ZONE_WORKSPACE_DECLARED
        );
        assert_eq!(
            proposal_packet.artifact_class,
            ARTIFACT_CLASS_WORKSPACE_SOURCE
        );
        assert!(authority_decision_allows_route_unattended(&proposal_packet));
        assert!(proposal_packet
            .basis
            .iter()
            .any(|basis| basis.contains("manifest-governed proposal packet")));

        let undeclared_proposal_packet = classify_authority_zone(
            repo,
            run_id,
            Some("child-a"),
            Some("run-packet-implementation"),
            None,
            OPERATION_CLASS_EXECUTE_CHILD_ROUTE,
            &[repo.join(".octon/inputs/exploratory/proposals/architecture/example-child")],
            &[".octon/framework/engine/runtime/spec".to_string()],
            None,
        );
        assert_eq!(
            undeclared_proposal_packet.authority_zone,
            AUTHORITY_ZONE_PROTECTED_OR_EXTERNAL
        );

        let outside_declared_scope = classify_authority_zone(
            repo,
            run_id,
            Some("child-a"),
            Some("implement"),
            None,
            OPERATION_CLASS_EXECUTE_CHILD_ROUTE,
            &[repo.join("src/lib.rs")],
            &["docs".to_string()],
            None,
        );
        assert_eq!(
            outside_declared_scope.authority_zone,
            AUTHORITY_ZONE_PROTECTED_OR_EXTERNAL
        );
        assert_eq!(
            outside_declared_scope.fail_closed_blocker,
            BLOCKER_AUTHORITY_ZONE_AMBIGUOUS
        );

        let current_run_artifact = classify_authority_zone(
            repo,
            run_id,
            Some("child-a"),
            Some("implement"),
            None,
            OPERATION_CLASS_CLEANUP_CURRENT_RUN_ARTIFACT,
            &[repo.join(".octon/state/control/execution/runs/run-1/tmp/lock.tmp")],
            &[".octon/state/control/execution/runs/run-1".to_string()],
            None,
        );
        assert_eq!(
            current_run_artifact.authority_zone,
            AUTHORITY_ZONE_CURRENT_RUN_AGENT_ARTIFACT
        );
        assert!(current_run_artifact.autonomous_allowed);
    }

    #[test]
    fn authority_zone_recipe_metadata_blocks_approval_free_protected_mutation() {
        let mut recipe = test_recovery_recipe("publication-drift");
        recipe.allowed_authority_zones = vec![AUTHORITY_ZONE_AUTHORED_GOVERNANCE.to_string()];
        recipe.allowed_artifact_classes = vec![ARTIFACT_CLASS_AUTHORED_GOVERNANCE.to_string()];
        recipe.operation_class = Some("durable-authority-mutation".to_string());

        let error = validate_recovery_recipe_metadata(&recipe, "publication-drift", true)
            .expect_err("approval-free durable authority recipe should fail");
        assert!(error
            .to_string()
            .contains("allows protected authority zone"));
    }

    #[test]
    fn authority_zone_grants_require_zone_binding_for_workspace_source() {
        let repo = Path::new("/workspace/octon");
        let decision = classify_authority_zone(
            repo,
            "run-1",
            Some("child-a"),
            Some("implement"),
            None,
            OPERATION_CLASS_EXECUTE_CHILD_ROUTE,
            &[repo.join("src/lib.rs")],
            &["src".to_string()],
            None,
        );
        let legacy_grant = ProgramApprovalGrant {
            child_id: "child-a".to_string(),
            route_id: "implement".to_string(),
            human_only_boundary: "authority-ambiguity".to_string(),
            blocker_class: None,
            registry_digest: Some("sha256:registry".to_string()),
            authority_zone: None,
            operation_class: None,
            artifact_class: None,
            write_scope_digest: None,
            source_authority_digest: None,
            grant_scope_digest: None,
            reason: "unbound grant".to_string(),
            recorded_at: "2026-05-17T00:00:00Z".to_string(),
            evidence_path: "human-exception-grant.yml".to_string(),
        };
        assert!(!approval_granted_for_authority_decision(
            Some(&vec![legacy_grant.clone()]),
            "child-a",
            "implement",
            Some("sha256:registry"),
            None,
            &decision
        ));

        let mut zone_bound_grant = legacy_grant;
        zone_bound_grant.authority_zone = Some(decision.authority_zone.clone());
        zone_bound_grant.operation_class = Some(decision.operation_class.clone());
        zone_bound_grant.artifact_class = Some(decision.artifact_class.clone());
        zone_bound_grant.write_scope_digest = decision.write_scope_digest.clone();
        assert!(approval_granted_for_authority_decision(
            Some(&vec![zone_bound_grant]),
            "child-a",
            "implement",
            Some("sha256:registry"),
            None,
            &decision
        ));
    }

    #[test]
    fn worktree_hygiene_blocker_requires_human_without_criticality_evidence() {
        assert_eq!(
            classify_program_blocker_class("worktree-hygiene-blocked"),
            ProgramBlockerDisposition::Human
        );
    }

    fn child_state(child_id: &str, blockers: Vec<ProgramBlocker>) -> ProgramChildPlanState {
        ProgramChildPlanState {
            child_id: child_id.to_string(),
            child_lifecycle_id: "proposal-packet".to_string(),
            target: format!("children/{child_id}"),
            required: true,
            deferred: false,
            dependencies: Vec::new(),
            dependency_gate: None,
            phase_id: None,
            group_id: None,
            seed_role: None,
            rollback_posture: None,
            recovery_profile: None,
            phase_commit_barrier: None,
            selected_route: Some(RoutePlanState {
                route_id: "review-proposal".to_string(),
                route_type: "agent".to_string(),
                command_id: None,
                skill_id: None,
                prompt_set_id: None,
            }),
            terminal_outcome: None,
            receipt_digests: BTreeMap::new(),
            gate_status: ProgramChildGateStatus::default(),
            dependency_gate_status: BTreeMap::new(),
            write_scopes: vec![format!("children/{child_id}")],
            blockers,
            final_verdict: "route-ready".to_string(),
        }
    }

    fn program_plan_with_children(
        child_states: BTreeMap<String, ProgramChildPlanState>,
        runnable_batch: Vec<&str>,
    ) -> ProgramLifecyclePlanResult {
        ProgramLifecyclePlanResult {
            schema_version: "octon-program-lifecycle-plan-v1".to_string(),
            lifecycle_id: "proposal-program".to_string(),
            owner_extension: "test-extension".to_string(),
            execution_strategy: LifecycleExecutionStrategy::OrchestratedReplanLoop
                .as_str()
                .to_string(),
            contract_path: "test".to_string(),
            target: "parent".to_string(),
            parent_manifest_status: Some("accepted".to_string()),
            child_registry_path: "parent/resources/child-packet-index.yml".to_string(),
            child_registry_schema_version: "octon-proposal-program-child-registry-v2".to_string(),
            child_registry_digest: "sha256:test".to_string(),
            execution_mode: "parallel-independent".to_string(),
            aggregate_state: "planned".to_string(),
            terminal_outcome: None,
            parent_receipt_states: BTreeMap::new(),
            program_route: None,
            program_gate_results: Vec::new(),
            blocked_by_program_gate: None,
            program_blockers: Vec::new(),
            normalized_program_blockers: Vec::new(),
            child_states,
            normalized_child_blockers: BTreeMap::new(),
            runnable_batch: runnable_batch
                .into_iter()
                .map(std::string::ToString::to_string)
                .collect(),
            scheduler_phase: Some("default".to_string()),
            skipped_blocked_children: Vec::new(),
            required_child_completion: BTreeMap::new(),
            closeout_hygiene_suppressions: BTreeMap::new(),
            safe_repair_candidates: Vec::new(),
            program_recovery_recipe_validation_status: None,
            program_recovery_recipe_validation_failures: Vec::new(),
            program_recovery_recipe_blocker_class: None,
            program_recovery_recipe_route_id: None,
            program_recovery_recipe_delegation_contract_basis: None,
            unsafe_results: Vec::new(),
            unsafe_continuation_decision: None,
            approval_blockers: Vec::new(),
            normalized_approval_blockers: Vec::new(),
            checkpoint_drift: None,
            stop_reason: Some("dispatch-available".to_string()),
            final_verdict: "planned".to_string(),
        }
    }

    fn program_with_publication_recovery_action() -> ProgramSpec {
        let mut program = test_program_spec();
        program.recovery_policy.max_recovery_attempts = Some(2);
        program
            .recovery_policy
            .recipes
            .push(ProgramRecoveryRecipeSpec {
                blocker_class: "publication-drift".to_string(),
                recovery_action_id: Some(REFRESH_PUBLICATION_PROJECTIONS_ACTION.to_string()),
                idempotency_class: Some("idempotent-rerun".to_string()),
                human_required: false,
                retry_budget: Some(1),
                dependent_handling: Some("pause-dependent".to_string()),
                post_attempt_validation: vec![
                    "replan-live-state".to_string(),
                    "publication-freshness-cleared".to_string(),
                    "replay-verify".to_string(),
                ],
                replan_behavior: Some("after-attempt".to_string()),
                ..Default::default()
            });
        program
    }

    fn program_with_rebaseline_checkpoint_action() -> ProgramSpec {
        let mut program = test_program_spec();
        program.recovery_policy.max_recovery_attempts = Some(2);
        program
            .recovery_policy
            .recipes
            .push(ProgramRecoveryRecipeSpec {
                blocker_class: "target-drift-explained".to_string(),
                recovery_action_id: Some(REBASELINE_CHECKPOINT_ACTION.to_string()),
                idempotency_class: Some("inspect-only".to_string()),
                human_required: false,
                retry_budget: Some(1),
                dependent_handling: Some("pause-dependent".to_string()),
                post_attempt_validation: vec![
                    "replan-live-state".to_string(),
                    "authority-boundary-check".to_string(),
                    "replay-verify".to_string(),
                ],
                replan_behavior: Some("after-attempt".to_string()),
                ..Default::default()
            });
        program
    }

    #[test]
    fn recoverable_no_dispatch_blocker_becomes_recovery_route_unavailable() {
        let program = test_program_spec();
        let mut program_blockers = vec![blocker("implementation-blocked")];
        let mut child_states = BTreeMap::new();

        apply_recoverable_dispatchability_blockers(
            &program,
            &mut child_states,
            &mut program_blockers,
        );

        assert_eq!(
            program_blockers[0].blocker_class,
            "recovery-route-unavailable"
        );
        assert!(program_blockers[0]
            .message
            .contains("implementation-blocked"));
        assert!(program_blockers[0].recovery_route.is_none());
    }

    #[test]
    fn target_drift_explained_selects_rebaseline_once_then_exhausts_budget() {
        let program = program_with_rebaseline_checkpoint_action();
        let mut child_states = BTreeMap::new();
        child_states.insert(
            "a".to_string(),
            child_state("a", vec![blocker("target-drift-explained")]),
        );
        let plan = program_plan_with_children(child_states.clone(), vec![]);

        assert_eq!(
            select_program_recovery_action(&program, &plan, None),
            Some(("target-drift-explained", REBASELINE_CHECKPOINT_ACTION))
        );

        let mut used_actions = BTreeMap::new();
        used_actions.insert(
            program_recovery_action_attempt_key(
                "target-drift-explained",
                REBASELINE_CHECKPOINT_ACTION,
            ),
            1,
        );
        let checkpoint = checkpoint_from_plan(
            "target-drift-explained-budget",
            "proposal-program",
            "parent",
            ExecutorKind::Mock,
            "unattended",
            &BTreeMap::new(),
            &plan,
            &[],
            "blocked-recoverable",
            None,
            0,
            BTreeMap::new(),
            used_actions,
            BTreeMap::new(),
            BTreeMap::new(),
            Vec::new(),
        );

        assert!(select_program_recovery_action(&program, &plan, Some(&checkpoint)).is_none());

        let mut exhausted_children = child_states;
        let mut exhausted_program_blockers = Vec::new();
        apply_program_recovery_action_budget_blockers(
            &program,
            &mut exhausted_children,
            &mut exhausted_program_blockers,
            Some(&checkpoint),
        );
        let exhausted = exhausted_children
            .get("a")
            .unwrap()
            .blockers
            .first()
            .unwrap();
        assert_eq!(exhausted.blocker_class, "recovery-budget-override-required");
        assert!(exhausted.message.contains(REBASELINE_CHECKPOINT_ACTION));
    }

    #[test]
    fn finding_binding_derives_deterministic_id_from_failed_gate() {
        let mut plan = program_plan_with_children(BTreeMap::new(), vec![]);
        plan.program_gate_results.push(GatePlanResult {
            gate_id: "program-child-proposal-readiness".to_string(),
            validator_id: "proposal-validator".to_string(),
            passed: false,
            exit_code: Some(1),
            stdout: "missing child evidence".to_string(),
            stderr: "validator diagnostic".to_string(),
        });
        let evidence_root = std::env::temp_dir().join(format!(
            "octon-finding-binding-{}",
            SystemTime::now()
                .duration_since(UNIX_EPOCH)
                .unwrap()
                .as_nanos()
        ));
        fs::create_dir_all(&evidence_root).unwrap();

        let finding_id = derive_and_write_finding_binding(&plan, &evidence_root)
            .unwrap()
            .unwrap();
        let repeated = derive_and_write_finding_binding(&plan, &evidence_root)
            .unwrap()
            .unwrap();
        let evidence = fs::read_to_string(evidence_root.join("finding-binding.yml")).unwrap();

        assert_eq!(finding_id, repeated);
        assert!(finding_id.starts_with("finding-"));
        assert!(evidence.contains("status: derived"));
        assert!(evidence.contains("source_kind: failed-gate"));
        assert!(evidence.contains("program-child-proposal-readiness:proposal-validator"));
    }

    #[test]
    fn finding_binding_unavailable_emits_input_binding_stop() {
        let evidence_root = std::env::temp_dir().join(format!(
            "octon-finding-binding-unavailable-{}",
            SystemTime::now()
                .duration_since(UNIX_EPOCH)
                .unwrap()
                .as_nanos()
        ));
        fs::create_dir_all(&evidence_root).unwrap();
        let route = RoutePlanState {
            route_id: "generate-program-correction-prompt".to_string(),
            route_type: "extension".to_string(),
            command_id: None,
            skill_id: None,
            prompt_set_id: None,
        };

        let result =
            finding_binding_unavailable_result("missing-finding", &route, "parent", &evidence_root)
                .unwrap();

        assert_eq!(result.status, "blocked-human");
        assert_eq!(result.error_class, Some(LifecycleErrorClass::InputBinding));
        assert!(result
            .error_message
            .as_deref()
            .unwrap_or_default()
            .contains("finding-binding-unavailable"));
        assert!(result
            .evidence_paths
            .iter()
            .any(|path| path.ends_with("finding-binding.yml")));
    }

    #[test]
    fn retryable_executor_timeout_maps_to_durable_blocker_class() {
        let result = LifecycleRouteExecutionResult {
            schema_version: "octon-lifecycle-route-execution-result-v1".to_string(),
            run_id: "executor-timeout".to_string(),
            route_id: "run-implementation".to_string(),
            executor_used: "mock".to_string(),
            status: "timed-out".to_string(),
            started_at: "now".to_string(),
            ended_at: "now".to_string(),
            manifest_status_before: None,
            manifest_status_after: None,
            receipts_observed: Vec::new(),
            evidence_paths: vec![PathBuf::from("evidence/executor-timeout.yml")],
            stdout_path: None,
            stderr_path: None,
            prompt_packet_path: None,
            retryable: true,
            next_action: "retry".to_string(),
            error_class: Some(LifecycleErrorClass::Timeout),
            error_message: Some("executor timed out".to_string()),
        };

        assert_eq!(
            execution_result_blocker_class(&result).as_deref(),
            Some("executor-timed-out")
        );
    }

    #[test]
    fn aggregate_program_state_maps_program_blockers_to_final_verdicts() {
        let program = test_program_spec();
        for class in ["validation-failed", "missing-evidence"] {
            let (_state, verdict) = aggregate_program_state(
                &program,
                None,
                &BTreeMap::new(),
                &[blocker(class)],
                &[],
                &[],
            );
            assert_eq!(verdict, "blocked-recoverable", "{class}");
        }
        let (_state, verdict) = aggregate_program_state(
            &program,
            None,
            &BTreeMap::new(),
            &[blocker("authority-boundary-ambiguous")],
            &[],
            &[],
        );
        assert_eq!(verdict, "blocked-unsafe");
        let (_state, verdict) = aggregate_program_state(
            &program,
            None,
            &BTreeMap::new(),
            &[],
            &[approval_blocker()],
            &[],
        );
        assert_eq!(verdict, "blocked-human");
    }

    #[test]
    fn aggregate_program_state_preserves_runnable_children_when_unblocked() {
        let program = test_program_spec();
        let mut children = BTreeMap::new();
        children.insert("a".to_string(), child_state("a", Vec::new()));
        let (_state, verdict) =
            aggregate_program_state(&program, None, &children, &[], &[], &["a".to_string()]);
        assert_eq!(verdict, "planned");

        let mut blocked_children = BTreeMap::new();
        blocked_children.insert(
            "a".to_string(),
            child_state("a", vec![blocker("missing-evidence")]),
        );
        let (_state, verdict) =
            aggregate_program_state(&program, None, &blocked_children, &[], &[], &[]);
        assert_eq!(verdict, "blocked-recoverable");
    }

    #[test]
    fn taxonomy_normalizes_legacy_states_and_blocker_classes() {
        for (state, category) in [
            ("blocked-max-steps", ProgramNormalizedCategory::Budget),
            ("blocked-max-iterations", ProgramNormalizedCategory::Budget),
            ("blocked-gate", ProgramNormalizedCategory::Recoverable),
            ("blocked-no-route", ProgramNormalizedCategory::Recoverable),
            ("failed", ProgramNormalizedCategory::Recoverable),
            ("timed-out", ProgramNormalizedCategory::Timeout),
            ("cancelled", ProgramNormalizedCategory::Cancellation),
            ("completed", ProgramNormalizedCategory::Terminal),
        ] {
            assert_eq!(normalize_program_state_value(state), category, "{state}");
        }
        assert_eq!(
            normalize_program_state_value("step-budget-exhausted-continuable"),
            ProgramNormalizedCategory::Budget
        );

        for (class, normalized_class, disposition) in [
            (
                "authority-ambiguity",
                "authority-ambiguity",
                ProgramBlockerDisposition::Human,
            ),
            (
                "unsupported-mode-config",
                "unsupported-mode-config",
                ProgramBlockerDisposition::Human,
            ),
            (
                "executor-preflight-blocked",
                "executor-preflight-blocked",
                ProgramBlockerDisposition::Human,
            ),
            (
                "step-budget-exhausted-continuable",
                "step-budget-exhausted-continuable",
                ProgramBlockerDisposition::Recoverable,
            ),
            (
                "unsupported-mode",
                "unsupported-mode-authority",
                ProgramBlockerDisposition::Unsafe,
            ),
            (
                "write-scope-conflict",
                "atomic-write-scope-conflict",
                ProgramBlockerDisposition::Unsafe,
            ),
            (
                "dependency-blocked",
                "dependency-gate-unsatisfied",
                ProgramBlockerDisposition::Recoverable,
            ),
            (
                "target-drift",
                "target-drift-unclear",
                ProgramBlockerDisposition::Human,
            ),
            (
                "worktree-hygiene-blocked",
                "artifact-ownership-unclear",
                ProgramBlockerDisposition::Human,
            ),
            (
                "child-lock-stale",
                "noncritical-artifact-cleanup",
                ProgramBlockerDisposition::Recoverable,
            ),
            (
                "implementation-blocked",
                "implementation-blocked",
                ProgramBlockerDisposition::Recoverable,
            ),
            (
                "publication-drift",
                "publication-drift",
                ProgramBlockerDisposition::Recoverable,
            ),
            (
                "recovery-budget-override-required",
                "recovery-budget-override-required",
                ProgramBlockerDisposition::Human,
            ),
            (
                "authority-zone-denied",
                "authority-zone-denied",
                ProgramBlockerDisposition::Human,
            ),
            (
                "scope-expansion",
                "scope-expansion",
                ProgramBlockerDisposition::Human,
            ),
            (
                "scope-expansion",
                "scope-expansion",
                ProgramBlockerDisposition::Human,
            ),
            (
                "authority-zone-ambiguous",
                "authority-zone-ambiguous",
                ProgramBlockerDisposition::Unsafe,
            ),
            (
                "self-authorization-attempt",
                "self-authorization-attempt",
                ProgramBlockerDisposition::Unsafe,
            ),
            (
                "recovery-integrity-risk",
                "recovery-integrity-risk",
                ProgramBlockerDisposition::Unsafe,
            ),
        ] {
            let evidence = taxonomy_evidence_for_class(None, class);
            assert_eq!(
                evidence.normalized_blocker_class, normalized_class,
                "{class}"
            );
            assert_eq!(
                classify_program_blocker_class(class),
                disposition,
                "{class}"
            );
        }
    }

    #[test]
    fn program_recovery_action_selection_skips_non_action_child_blockers() {
        let program = program_with_publication_recovery_action();
        let mut child_states = BTreeMap::new();
        child_states.insert(
            "a".to_string(),
            child_state("a", vec![blocker("artifact-ownership-unclear")]),
        );
        child_states.insert(
            "b".to_string(),
            child_state("b", vec![blocker("publication-drift")]),
        );
        let plan = program_plan_with_children(child_states, vec!["a", "b"]);

        let selected = select_program_recovery_action(&program, &plan, None);

        assert_eq!(
            selected,
            Some(("publication-drift", REFRESH_PUBLICATION_PROJECTIONS_ACTION))
        );
    }

    #[test]
    fn publication_post_validation_failure_selects_publication_recovery_action() {
        let program = program_with_publication_recovery_action();
        let mut child_states = BTreeMap::new();
        child_states.insert(
            "a".to_string(),
            child_state(
                "a",
                vec![
                    blocker("artifact-ownership-unclear"),
                    blocker("publication-drift"),
                ],
            ),
        );
        let plan = program_plan_with_children(child_states, vec!["a"]);
        let child_results = vec![ProgramChildExecutionSummary {
            child_id: "a".to_string(),
            child_run_id: "publication-post-validation-a".to_string(),
            route_id: "run-packet-implementation".to_string(),
            status: "failed".to_string(),
            attempts: 1,
            retryable: true,
            blocker_class: Some("publication-drift".to_string()),
            error_message: Some(
                "recovery post-attempt validation failed for publication-drift: publication-freshness-cleared"
                    .to_string(),
            ),
            error_class: None,
            evidence_paths: Vec::new(),
            worktree_hygiene_foreign_fingerprint: None,
        }];

        assert!(child_results_have_publication_post_validation_failure(
            &child_results
        ));
        assert_eq!(
            select_program_recovery_action(&program, &plan, None),
            Some(("publication-drift", REFRESH_PUBLICATION_PROJECTIONS_ACTION))
        );
    }

    #[test]
    fn publication_action_post_validation_allows_selected_child_recovery_route() {
        let mut publication_blocker = blocker("publication-drift");
        publication_blocker.recovery_route = Some("run-packet-implementation".to_string());
        let mut child = child_state("a", vec![publication_blocker]);
        child.selected_route = Some(RoutePlanState {
            route_id: "run-packet-implementation".to_string(),
            route_type: "agent".to_string(),
            command_id: None,
            skill_id: None,
            prompt_set_id: None,
        });
        let mut child_states = BTreeMap::new();
        child_states.insert("a".to_string(), child);
        let plan = program_plan_with_children(child_states, vec!["a"]);

        assert!(program_recovery_post_attempt_validation_result(
            "publication-freshness-cleared",
            &plan,
            Path::new("."),
            "publication-drift",
            true,
        )
        .is_ok());

        let ambiguous_plan = program_plan_with_children(
            BTreeMap::from([(
                "a".to_string(),
                child_state("a", vec![blocker("publication-drift")]),
            )]),
            vec!["a"],
        );
        assert!(program_recovery_post_attempt_validation_result(
            "publication-freshness-cleared",
            &ambiguous_plan,
            Path::new("."),
            "publication-drift",
            true,
        )
        .is_err());
    }

    #[test]
    fn worktree_hygiene_preflight_allows_current_run_noncritical_residue_only() {
        let pass_decision = classify_worktree_hygiene_preflight(
            true,
            r#"
worktree_hygiene_verdict: "blocked"
worktree_hygiene_blocker_class: "local-run-residue"
worktree_hygiene_foreign_path_count: 0
"#,
        );
        assert_eq!(pass_decision.status, "pass");

        let foreign_decision = classify_worktree_hygiene_preflight(
            true,
            r#"
worktree_hygiene_verdict: "blocked"
worktree_hygiene_blocker_class: "local-run-residue"
worktree_hygiene_foreign_path_count: 1
"#,
        );
        assert_eq!(foreign_decision.status, "blocked");
        assert_eq!(foreign_decision.blocker_class, "artifact-ownership-unclear");

        let ambiguous_decision = classify_worktree_hygiene_preflight(
            true,
            r#"
worktree_hygiene_verdict: "blocked"
worktree_hygiene_blocker_class: "worktree-hygiene-blocked"
"#,
        );
        assert_eq!(ambiguous_decision.status, "blocked");
        assert_eq!(
            ambiguous_decision.blocker_class,
            "artifact-ownership-unclear"
        );
    }

    #[test]
    fn recoverable_legacy_stop_states_continue_with_pending_dispatch() {
        let mut result = ProgramLifecycleRunResult {
            schema_version: "octon-program-lifecycle-run-result-v1".to_string(),
            run_id: "legacy-stop-semantics".to_string(),
            lifecycle_id: "proposal-program".to_string(),
            execution_strategy: LifecycleExecutionStrategy::OrchestratedReplanLoop
                .as_str()
                .to_string(),
            target: "parent".to_string(),
            executor: "mock".to_string(),
            route_execution_mode: "program-adapter-executed".to_string(),
            bundle_root: "evidence".to_string(),
            checkpoint_path: "checkpoint.yml".to_string(),
            event_log_path: "events.ndjson".to_string(),
            latest_event_offset: 1,
            selected_parent_route: None,
            parent_route_result: None,
            selected_children: vec!["a".to_string()],
            child_results: Vec::new(),
            terminal_outcome: None,
            final_verdict: "blocked-gate".to_string(),
        };
        for verdict in [
            "blocked-gate",
            "blocked-no-route",
            "failed",
            "timed-out",
            "blocked",
        ] {
            result.final_verdict = verdict.to_string();
            assert!(
                !program_execute_loop_should_stop(&result, "unattended"),
                "{verdict}"
            );
        }
        result.selected_children.clear();
        result.final_verdict = "blocked-gate".to_string();
        assert!(program_execute_loop_should_stop(&result, "unattended"));
    }

    struct ProgramFixture {
        root: PathBuf,
        octon_dir: PathBuf,
    }

    impl ProgramFixture {
        fn new(name: &str, serialize_conflicts: bool) -> Self {
            let millis = SystemTime::now()
                .duration_since(UNIX_EPOCH)
                .unwrap()
                .as_millis();
            let root =
                std::env::temp_dir().join(format!("octon-program-lifecycle-{name}-{millis}"));
            let octon_dir = root.join(".octon");
            fs::create_dir_all(
                octon_dir.join("generated/effective/extensions/published/test-extension/bundled/context/lifecycles"),
            )
            .unwrap();
            let fixture = Self { root, octon_dir };
            fixture.write_generated_catalog();
            fixture.write_child_contract();
            fixture.write_program_contract(serialize_conflicts);
            fixture.write_parent();
            fixture
        }

        fn write(&self, rel: &str, content: &str) {
            let path = self.root.join(rel);
            fs::create_dir_all(path.parent().unwrap()).unwrap();
            fs::write(path, content).unwrap();
        }

        fn write_generated_catalog(&self) {
            self.write(
                ".octon/generated/effective/extensions/catalog.effective.yml",
                r#"
schema_version: "test"
packs:
  - pack_id: "test-extension"
    capability_profiles: ["validation-surface", "lifecycle-contract"]
    lifecycle_contracts:
      - lifecycle_id: "proposal-packet"
        projection_source_path: ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml"
      - lifecycle_id: "proposal-program"
        projection_source_path: ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycles/proposal-program.contract.yml"
"#,
            );
        }

        fn write_child_contract(&self) {
            self.write(
                ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
                r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted", "implemented"] }
states: [{ state_id: "implement" }]
terminal_outcomes:
  - outcome_id: "implemented"
    when: { manifest_status: "implemented" }
receipts:
  - receipt_id: "implementation-run"
    path: "support/implementation-run.md"
routes:
  - route_id: "run-implementation"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: ["implementation-run"]
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
    enter_when: { manifest_status: "accepted" }
    completion:
      expected_receipts: ["implementation-run"]
"#,
            );
        }

        fn write_full_child_contract(&self) {
            self.write(
                ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
                r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted", "implemented", "archived"] }
states: [{ state_id: "implement" }, { state_id: "verify" }, { state_id: "closeout" }]
terminal_outcomes:
  - outcome_id: "archived"
    when: { manifest_status: "archived" }
receipts:
  - receipt_id: "implementation-prompt"
    path: "support/executable-implementation-prompt.md"
  - receipt_id: "implementation-run"
    path: "support/implementation-run.md"
    required_fields: ["verdict"]
    verdict_field: "verdict"
  - receipt_id: "implementation-conformance"
    path: "support/implementation-conformance-review.md"
    required_fields: ["verdict"]
    verdict_field: "verdict"
  - receipt_id: "post-implementation-drift"
    path: "support/post-implementation-drift-churn-review.md"
    required_fields: ["verdict"]
    verdict_field: "verdict"
  - receipt_id: "proposal-closeout"
    path: "support/proposal-closeout.md"
    required_fields: ["verdict", "archive_authorized"]
    verdict_field: "verdict"
routes:
  - route_id: "generate-packet-implementation-prompt"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: ["implementation-prompt"]
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
    enter_when:
      all:
        - manifest_status: "accepted"
        - receipt_absent: "implementation-prompt"
    completion:
      expected_receipts: ["implementation-prompt"]
  - route_id: "run-packet-implementation"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: ["implementation-prompt"]
      required_receipts_before_completion: ["implementation-run"]
      replay_class: "bounded-retry"
      automated_recovery_policy: "bounded-automated-retry"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
    enter_when:
      any:
        - all:
            - manifest_status: "accepted"
            - receipt_complete: "implementation-prompt"
            - receipt_absent: "implementation-run"
        - all:
            - manifest_status: "accepted"
            - receipt_complete: "implementation-prompt"
            - receipt_complete: "implementation-run"
            - receipt_verdict: { receipt_id: "implementation-run", value: "blocked" }
        - all:
            - manifest_status: "accepted"
            - receipt_complete: "implementation-prompt"
            - receipt_complete: "implementation-run"
            - receipt_verdict: { receipt_id: "implementation-conformance", value: "fail" }
        - all:
            - manifest_status: "accepted"
            - receipt_complete: "implementation-prompt"
            - receipt_complete: "implementation-run"
            - receipt_verdict: { receipt_id: "post-implementation-drift", value: "fail" }
    completion:
      expected_receipts: ["implementation-run"]
  - route_id: "promote-proposal"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: ["implementation-run"]
      required_receipts_before_completion: []
      replay_class: "no-op-safe"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
    enter_when:
      all:
        - manifest_status: "accepted"
        - receipt_complete: "implementation-run"
        - receipt_verdict: { receipt_id: "implementation-run", value: "pass" }
    completion:
      expected_manifest_status: "implemented"
  - route_id: "run-packet-verification-and-correction-loop"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: ["implementation-run"]
      required_receipts_before_completion: ["implementation-conformance", "post-implementation-drift"]
      replay_class: "bounded-retry"
      automated_recovery_policy: "bounded-automated-retry"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
    enter_when:
      all:
        - manifest_status: "implemented"
        - any:
            - receipt_absent: "implementation-conformance"
            - receipt_absent: "post-implementation-drift"
    completion:
      expected_receipts: ["implementation-conformance", "post-implementation-drift"]
  - route_id: "closeout-packet"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: ["implementation-conformance", "post-implementation-drift"]
      required_receipts_before_completion: ["proposal-closeout"]
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation", "unresolved-risk-acceptance"]
    enter_when:
      all:
        - manifest_status: "implemented"
        - receipt_complete: "implementation-conformance"
        - receipt_verdict: { receipt_id: "implementation-conformance", value: "pass" }
        - receipt_complete: "post-implementation-drift"
        - receipt_verdict: { receipt_id: "post-implementation-drift", value: "pass" }
        - receipt_absent: "proposal-closeout"
    completion:
      expected_receipts: ["proposal-closeout"]
  - route_id: "archive-proposal"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: ["proposal-closeout"]
      required_receipts_before_completion: []
      replay_class: "no-op-safe"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation", "unresolved-risk-acceptance", "stale-evidence-acceptance"]
    enter_when:
      all:
        - manifest_status: "implemented"
        - receipt_complete: "proposal-closeout"
        - receipt_verdict: { receipt_id: "proposal-closeout", value: "pass" }
        - receipt_field_equals: { receipt_id: "proposal-closeout", field: "archive_authorized", value: "yes" }
    completion:
      expected_manifest_status: "archived"
"#,
            );
        }

        fn write_child_contract_with_human_boundary(&self) {
            self.write(
                ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
                r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted", "implemented"] }
states: [{ state_id: "implement" }]
terminal_outcomes:
  - outcome_id: "implemented"
    when: { manifest_status: "implemented" }
receipts:
  - receipt_id: "implementation-run"
    path: "support/implementation-run.md"
routes:
  - route_id: "run-implementation"
    route_type: "extension"
    enter_when: { manifest_status: "accepted" }
    delegation_contract:
      decision_class: "new-governance-decision"
      safe_delegation: false
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: ["implementation-run"]
      replay_class: "non-replay-safe"
      automated_recovery_policy: "fail-closed-human-boundary"
      human_only_boundaries: ["scope-expansion"]
    completion:
      expected_receipts: ["implementation-run"]
"#,
            );
        }

        fn write_child_contract_with_workflow_promotion_human_boundary(&self) {
            self.write(
                ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
                r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted", "implemented"] }
states: [{ state_id: "promote" }]
terminal_outcomes:
  - outcome_id: "implemented"
    when: { manifest_status: "implemented" }
receipts:
  - receipt_id: "implementation-run"
    path: "support/implementation-run.md"
    required_fields: ["verdict"]
    verdict_field: "verdict"
routes:
  - route_id: "promote-proposal"
    route_type: "workflow"
    delegation_contract:
      decision_class: "new-governance-decision"
      safe_delegation: false
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "workflow-scope"
      required_evidence_gates: []
      required_receipts_before_dispatch: ["implementation-run"]
      required_receipts_before_completion: []
      replay_class: "non-replay-safe"
      automated_recovery_policy: "fail-closed-human-boundary"
      human_only_boundaries: ["scope-expansion"]
    enter_when:
      all:
        - manifest_status: "accepted"
        - receipt_complete: "implementation-run"
        - receipt_verdict: { receipt_id: "implementation-run", value: "pass" }
    completion:
      expected_manifest_status: "implemented"
"#,
            );
        }

        fn write_child_contract_with_safe_workflow_promotion(&self) {
            self.write(
                ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
                r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted", "implemented"] }
states: [{ state_id: "promote" }]
terminal_outcomes:
  - outcome_id: "implemented"
    when: { manifest_status: "implemented" }
receipts:
  - receipt_id: "implementation-run"
    path: "support/implementation-run.md"
    required_fields: ["verdict"]
    verdict_field: "verdict"
  - receipt_id: "implementation-conformance"
    path: "support/implementation-conformance-review.md"
    required_fields: ["verdict"]
    verdict_field: "verdict"
  - receipt_id: "post-implementation-drift"
    path: "support/post-implementation-drift-churn-review.md"
    required_fields: ["verdict"]
    verdict_field: "verdict"
routes:
  - route_id: "promote-proposal"
    route_type: "workflow"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "workflow-scope"
      required_evidence_gates: []
      required_receipts_before_dispatch: ["implementation-run"]
      required_receipts_before_completion: []
      replay_class: "no-op-safe"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
    enter_when:
      all:
        - manifest_status: "accepted"
        - receipt_complete: "implementation-run"
        - receipt_verdict: { receipt_id: "implementation-run", value: "pass" }
    completion:
      expected_manifest_status: "implemented"
"#,
            );
        }

        fn write_child_contract_with_delegation_contract(&self) {
            self.write(
                ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
                r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted", "implemented"] }
states: [{ state_id: "implement" }]
terminal_outcomes:
  - outcome_id: "implemented"
    when: { manifest_status: "implemented" }
receipts:
  - receipt_id: "implementation-run"
    path: "support/implementation-run.md"
routes:
  - route_id: "run-implementation"
    route_type: "extension"
    enter_when: { manifest_status: "accepted" }
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: ["implementation-run"]
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
    completion:
      expected_receipts: ["implementation-run"]
"#,
            );
        }

        fn write_child_contract_with_fresh_receipt(&self) {
            self.write(
                ".octon/framework/assurance/runtime/_ops/scripts/test-digest.sh",
                "#!/usr/bin/env bash\nprintf 'sha256:live\\n'\n",
            );
            self.write(
                ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
                r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted", "implemented"] }
states: [{ state_id: "implement" }]
terminal_outcomes:
  - outcome_id: "implemented"
    when: { manifest_status: "implemented" }
receipts:
  - receipt_id: "implementation-run"
    path: "support/implementation-run.md"
    required_fields: ["verdict"]
    verdict_field: "verdict"
    freshness:
      digest_command: ["bash", ".octon/framework/assurance/runtime/_ops/scripts/test-digest.sh", "{{target}}"]
      digest_field: "reviewed_packet_digest"
routes:
  - route_id: "run-implementation"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: ["implementation-run"]
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation", "stale-evidence-acceptance"]
    enter_when: { manifest_status: "accepted" }
    completion:
      expected_receipts: ["implementation-run"]
"#,
            );
        }

        fn write_child_contract_with_closeout_outcomes(&self) {
            self.write(
                ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
                r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted", "archived", "rejected"] }
states: [{ state_id: "closed" }]
terminal_outcomes:
  - outcome_id: "archived"
    when: { manifest_status: "archived" }
  - outcome_id: "rejected"
    when: { manifest_status: "rejected" }
receipts:
  - receipt_id: "decision"
    path: "support/decision.md"
routes:
  - route_id: "closeout"
    route_type: "extension"
"#,
            );
        }

        fn write_child_contract_with_atomic(
            &self,
            stage_fails: bool,
            commit_fails: bool,
            compensation: bool,
        ) {
            let stage_completion = if stage_fails {
                "expected_paths: [\"support/missing-stage.md\"]"
            } else {
                "expected_manifest_status: \"accepted\""
            };
            let commit_completion = if commit_fails {
                "expected_paths: [\"support/missing-commit.md\"]"
            } else {
                "expected_manifest_status: \"accepted\""
            };
            let compensation_field = if compensation {
                "      compensation_route_id: \"atomic-compensate\"\n"
            } else {
                ""
            };
            self.write(
                ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
                &format!(
                    r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
target: {{ input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted", "implemented"] }}
states: [{{ state_id: "implement" }}]
terminal_outcomes:
  - outcome_id: "implemented"
    when: {{ manifest_status: "implemented" }}
receipts:
  - receipt_id: "implementation-run"
    path: "support/implementation-run.md"
routes:
  - route_id: "run-implementation"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: ["implementation-run"]
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
    enter_when: {{ manifest_status: "accepted" }}
    atomic:
      stage_route_id: "atomic-stage"
      commit_route_id: "atomic-commit"
      rollback_route_id: "atomic-rollback"
{compensation_field}  - route_id: "atomic-stage"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: []
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
    completion:
      {stage_completion}
  - route_id: "atomic-commit"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: []
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
    completion:
      {commit_completion}
  - route_id: "atomic-rollback"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: []
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
    completion:
      expected_manifest_status: "accepted"
  - route_id: "atomic-compensate"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: []
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
    completion:
      expected_manifest_status: "accepted"
"#
                ),
            );
        }

        fn write_program_contract(&self, serialize_conflicts: bool) {
            self.write(
                ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycles/proposal-program.contract.yml",
                &format!(
                    r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-program"
owner_extension: "test-extension"
version: "1.0.0"
target: {{ input: "program_packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted", "implemented"] }}
program:
  child_registry_path: "resources/child-packet-index.yml"
  child_lifecycle_id_default: "proposal-packet"
  supported_execution_modes: ["sequential", "parallel-independent", "gated-parallel", "approval-gated"]
  recovery_policy:
    max_recovery_attempts: 2
    serialize_write_scope_conflicts: {serialize_conflicts}
  authority_boundaries:
    parent_coordinates_only: true
    child_receipts_remain_child_owned: true
    child_promotion_targets_remain_child_owned: true
states: [{{ state_id: "coordinate" }}]
terminal_outcomes:
  - outcome_id: "implemented"
    when: {{ manifest_status: "implemented" }}
receipts:
  - receipt_id: "program-summary"
    path: "support/program-summary.md"
routes:
  - route_id: "generate-program-implementation-prompt"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: ["program-implementation-prompt"]
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
"#
                ),
            );
        }

        fn write_program_contract_with_atomic(&self) {
            self.write(
                ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycles/proposal-program.contract.yml",
                r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-program"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "program_packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted", "implemented"] }
program:
  child_registry_path: "resources/child-packet-index.yml"
  child_lifecycle_id_default: "proposal-packet"
  supported_execution_modes: ["sequential", "parallel-independent", "gated-parallel", "approval-gated", "program-atomic"]
  atomic_policy:
    eligibility: "explicit-route-opt-in"
    require_declared_write_scopes: true
  recovery_policy:
    max_recovery_attempts: 2
    serialize_write_scope_conflicts: false
    handlers:
      executor-failed:
        max_attempts: 2
        replan_after_attempt: true
  closeout_policy:
    required_child_terminal_outcomes: ["implemented"]
    require_child_receipts_fresh: true
    require_aggregate_evidence: true
    enforce_authority_boundaries: true
  authority_boundaries:
    parent_coordinates_only: true
    child_receipts_remain_child_owned: true
    child_promotion_targets_remain_child_owned: true
states: [{ state_id: "coordinate" }]
terminal_outcomes:
  - outcome_id: "implemented"
    when: { manifest_status: "implemented" }
receipts:
  - receipt_id: "program-summary"
    path: "support/program-summary.md"
routes:
  - route_id: "generate-program-implementation-prompt"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: ["program-implementation-prompt"]
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
"#,
            );
        }

        fn write_program_contract_with_failing_program_gate(&self) {
            self.write(
                ".octon/framework/assurance/runtime/_ops/scripts/fail-program-gate.sh",
                "#!/usr/bin/env bash\nprintf 'program gate failed\\n'\nexit 1\n",
            );
            self.write(
                ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycles/proposal-program.contract.yml",
                r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-program"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "program_packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted", "implemented"] }
program:
  child_registry_path: "resources/child-packet-index.yml"
  child_lifecycle_id_default: "proposal-packet"
  supported_execution_modes: ["parallel-independent"]
  recovery_policy:
    max_recovery_attempts: 2
    serialize_write_scope_conflicts: true
  authority_boundaries:
    parent_coordinates_only: true
    child_receipts_remain_child_owned: true
    child_promotion_targets_remain_child_owned: true
states: [{ state_id: "coordinate" }]
terminal_outcomes:
  - outcome_id: "implemented"
    when: { manifest_status: "implemented" }
validators:
  - validator_id: "program-child-proposal-readiness"
    argv: ["bash", ".octon/framework/assurance/runtime/_ops/scripts/fail-program-gate.sh", "--package", "{{target}}"]
gates:
  - gate_id: "program-child-proposal-readiness"
    validator_id: "program-child-proposal-readiness"
    required_before_routes: ["generate-program-implementation-prompt"]
receipts:
  - receipt_id: "program-implementation-prompt"
    path: "support/executable-program-implementation-prompt.md"
routes:
  - route_id: "generate-program-implementation-prompt"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: ["program-implementation-prompt"]
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
    enter_when:
      all:
        - manifest_status: "accepted"
        - receipt_absent: "program-implementation-prompt"
"#,
            );
        }

        fn write_program_contract_with_parent_review_workflows(&self) {
            self.write(
                ".octon/framework/assurance/runtime/_ops/scripts/pass-program-gate.sh",
                "#!/usr/bin/env bash\nprintf 'program gate passed\\n'\n",
            );
            self.write(
                ".octon/framework/assurance/runtime/_ops/scripts/program-digest.sh",
                "#!/usr/bin/env bash\nprintf 'sha256:live\\n'\n",
            );
            self.write(
                ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycles/proposal-program.contract.yml",
                r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-program"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "program_packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["draft", "in-review", "accepted", "rejected", "implemented", "archived"] }
program:
  child_registry_path: "resources/child-packet-index.yml"
  child_lifecycle_id_default: "proposal-packet"
  supported_execution_modes: ["parallel-independent"]
  recovery_policy:
    max_recovery_attempts: 2
    serialize_write_scope_conflicts: true
  authority_boundaries:
    parent_coordinates_only: true
    child_receipts_remain_child_owned: true
    child_promotion_targets_remain_child_owned: true
states: [{ state_id: "review-program" }, { state_id: "revise-program" }, { state_id: "generate-program-implementation-prompt" }]
terminal_outcomes:
  - outcome_id: "archived"
    when: { manifest_status: "archived" }
  - outcome_id: "rejected"
    when: { manifest_status: "rejected" }
validators:
  - validator_id: "proposal-review-strict"
    argv: ["bash", ".octon/framework/assurance/runtime/_ops/scripts/pass-program-gate.sh", "--package", "{{target}}"]
  - validator_id: "program-child-proposal-readiness"
    argv: ["bash", ".octon/framework/assurance/runtime/_ops/scripts/pass-program-gate.sh", "--package", "{{target}}"]
  - validator_id: "program-structure"
    argv: ["bash", ".octon/framework/assurance/runtime/_ops/scripts/pass-program-gate.sh", "--package", "{{target}}"]
gates:
  - gate_id: "program-review-authorization"
    validator_id: "proposal-review-strict"
    required_before_routes: ["generate-program-implementation-prompt", "promote-proposal"]
    on_fail_route_id: "review-proposal-program"
  - gate_id: "program-child-proposal-readiness"
    validator_id: "program-child-proposal-readiness"
    required_before_routes: ["generate-program-implementation-prompt"]
  - gate_id: "program-structure"
    validator_id: "program-structure"
    required_before_routes: ["generate-program-implementation-prompt", "promote-proposal", "generate-program-verification-prompt", "generate-program-closeout-prompt", "closeout-proposal-program", "archive-proposal"]
receipts:
  - receipt_id: "program-creation"
    path: "support/program-creation.md"
    required_fields: ["creation_id", "created_at", "creator", "program_packet_path", "child_packet_count", "execution_mode", "child_registry_digest", "child_authority_preserved", "verdict"]
    verdict_field: "verdict"
  - receipt_id: "proposal-review"
    path: "support/proposal-review.md"
    required_fields: ["review_id", "reviewed_at", "reviewer", "verdict", "implementation_prompt_authorized", "reviewed_packet_digest", "open_blocking_findings_count"]
    verdict_field: "verdict"
    freshness:
      digest_command: ["bash", ".octon/framework/assurance/runtime/_ops/scripts/program-digest.sh", "--package", "{{target}}"]
      digest_field: "reviewed_packet_digest"
  - receipt_id: "program-implementation-prompt"
    path: "support/executable-program-implementation-prompt.md"
  - receipt_id: "implementation-run"
    path: "support/implementation-run.md"
    required_fields: ["verdict", "implemented_at", "promotion_evidence_count", "child_authority_preserved"]
    verdict_field: "verdict"
  - receipt_id: "program-verification-prompt"
    path: "support/follow-up-program-verification-prompt.md"
  - receipt_id: "program-implementation-conformance"
    path: "support/program-implementation-conformance-review.md"
    required_fields: ["verdict", "unresolved_items_count", "child_receipt_summary_count", "child_authority_preserved"]
    verdict_field: "verdict"
  - receipt_id: "program-post-implementation-drift"
    path: "support/program-post-implementation-drift-churn-review.md"
    required_fields: ["verdict", "unresolved_items_count", "child_receipt_summary_count", "child_authority_preserved"]
    verdict_field: "verdict"
  - receipt_id: "program-closeout-prompt"
    path: "support/custom-program-closeout-prompt.md"
  - receipt_id: "proposal-closeout"
    path: "support/proposal-closeout.md"
    required_fields: ["verdict", "closed_at", "archive_authorized", "child_authority_preserved"]
    verdict_field: "verdict"
routes:
  - route_id: "create-proposal-program"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: ["program-creation"]
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
    completion:
      expected_receipts: ["program-creation"]
    enter_when:
      any:
        - target_missing: true
        - file_absent: "proposal.yml"
        - file_absent: "resources/child-packet-index.yml"
  - route_id: "review-proposal-program"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: ["proposal-review"]
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
    completion:
      expected_receipts: ["proposal-review"]
    enter_when:
      any:
        - manifest_status: "draft"
        - all:
            - manifest_status: "in-review"
            - receipt_absent: "proposal-review"
        - all:
            - any:
                - manifest_status: "draft"
                - manifest_status: "in-review"
                - manifest_status: "accepted"
                - manifest_status: "rejected"
            - receipt_stale: "proposal-review"
  - route_id: "revise-proposal-program"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: ["proposal-review"]
      required_receipts_before_completion: []
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
    enter_when:
      all:
        - receipt_complete: "proposal-review"
        - receipt_verdict: { receipt_id: "proposal-review", value: "revision-required" }
  - route_id: "generate-program-implementation-prompt"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: ["program-implementation-prompt"]
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
    enter_when:
      all:
        - manifest_status: "accepted"
        - receipt_complete: "proposal-review"
        - receipt_verdict: { receipt_id: "proposal-review", value: "accepted" }
        - receipt_fresh: "proposal-review"
        - file_present: "resources/child-packet-index.yml"
        - receipt_absent: "program-implementation-prompt"
  - route_id: "promote-proposal"
    route_type: "workflow"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared", "program-child-registry"]
      declared_write_scope_source: "program-child-registry"
      required_evidence_gates: []
      required_receipts_before_dispatch: ["proposal-review", "implementation-run"]
      required_receipts_before_completion: []
      replay_class: "no-op-safe"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
    enter_when:
      all:
        - manifest_status: "accepted"
        - receipt_complete: "proposal-review"
        - receipt_verdict: { receipt_id: "proposal-review", value: "accepted" }
        - receipt_fresh: "proposal-review"
        - receipt_complete: "program-implementation-prompt"
        - file_present: "support/executable-program-implementation-prompt.md"
        - receipt_complete: "implementation-run"
        - receipt_field_equals: { receipt_id: "implementation-run", field: "verdict", value: "pass" }
        - receipt_field_equals: { receipt_id: "implementation-run", field: "child_authority_preserved", value: "yes" }
  - route_id: "generate-program-verification-prompt"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: ["program-verification-prompt"]
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
    enter_when:
      all:
        - manifest_status: "implemented"
        - file_present: "resources/child-packet-index.yml"
        - receipt_absent: "program-verification-prompt"
  - route_id: "run-program-verification-and-correction-loop"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: ["program-verification-prompt"]
      required_receipts_before_completion: ["program-implementation-conformance", "program-post-implementation-drift"]
      replay_class: "bounded-retry"
      automated_recovery_policy: "bounded-automated-retry"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
    completion:
      expected_receipts: ["program-implementation-conformance", "program-post-implementation-drift"]
    enter_when:
      all:
        - manifest_status: "implemented"
        - receipt_complete: "program-verification-prompt"
        - any:
            - receipt_absent: "program-implementation-conformance"
            - receipt_absent: "program-post-implementation-drift"
  - route_id: "generate-program-closeout-prompt"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: ["program-implementation-conformance", "program-post-implementation-drift"]
      required_receipts_before_completion: ["program-closeout-prompt"]
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
    enter_when:
      all:
        - manifest_status: "implemented"
        - receipt_complete: "program-implementation-conformance"
        - receipt_field_equals: { receipt_id: "program-implementation-conformance", field: "verdict", value: "pass" }
        - receipt_field_equals: { receipt_id: "program-implementation-conformance", field: "child_authority_preserved", value: "yes" }
        - receipt_complete: "program-post-implementation-drift"
        - receipt_field_equals: { receipt_id: "program-post-implementation-drift", field: "verdict", value: "pass" }
        - receipt_field_equals: { receipt_id: "program-post-implementation-drift", field: "child_authority_preserved", value: "yes" }
        - receipt_absent: "program-closeout-prompt"
  - route_id: "closeout-proposal-program"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: ["program-implementation-conformance", "program-post-implementation-drift", "program-closeout-prompt"]
      required_receipts_before_completion: ["proposal-closeout"]
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation", "unresolved-risk-acceptance"]
    enter_when:
      all:
        - manifest_status: "implemented"
        - receipt_complete: "program-implementation-conformance"
        - receipt_field_equals: { receipt_id: "program-implementation-conformance", field: "verdict", value: "pass" }
        - receipt_field_equals: { receipt_id: "program-implementation-conformance", field: "child_authority_preserved", value: "yes" }
        - receipt_complete: "program-post-implementation-drift"
        - receipt_field_equals: { receipt_id: "program-post-implementation-drift", field: "verdict", value: "pass" }
        - receipt_field_equals: { receipt_id: "program-post-implementation-drift", field: "child_authority_preserved", value: "yes" }
        - receipt_complete: "program-closeout-prompt"
        - receipt_absent: "proposal-closeout"
  - route_id: "archive-proposal"
    route_type: "workflow"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "workflow-scope"
      required_evidence_gates: []
      required_receipts_before_dispatch: ["proposal-closeout"]
      required_receipts_before_completion: []
      replay_class: "no-op-safe"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation", "unresolved-risk-acceptance", "stale-evidence-acceptance"]
    enter_when:
      all:
        - manifest_status: "implemented"
        - receipt_complete: "program-implementation-conformance"
        - receipt_field_equals: { receipt_id: "program-implementation-conformance", field: "verdict", value: "pass" }
        - receipt_field_equals: { receipt_id: "program-implementation-conformance", field: "child_authority_preserved", value: "yes" }
        - receipt_complete: "program-post-implementation-drift"
        - receipt_field_equals: { receipt_id: "program-post-implementation-drift", field: "verdict", value: "pass" }
        - receipt_field_equals: { receipt_id: "program-post-implementation-drift", field: "child_authority_preserved", value: "yes" }
        - receipt_complete: "proposal-closeout"
        - receipt_field_equals: { receipt_id: "proposal-closeout", field: "verdict", value: "pass" }
        - receipt_field_equals: { receipt_id: "proposal-closeout", field: "archive_authorized", value: "yes" }
        - receipt_field_equals: { receipt_id: "proposal-closeout", field: "child_authority_preserved", value: "yes" }
"#,
            );
        }

        fn write_program_contract_with_canonical_closeout_policy(&self) {
            self.write(
                ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycles/proposal-program.contract.yml",
                r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-program"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "program_packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted", "archived", "rejected"] }
program:
  child_registry_path: "resources/child-packet-index.yml"
  child_lifecycle_id_default: "proposal-packet"
  supported_execution_modes: ["parallel-independent"]
  recovery_policy:
    max_recovery_attempts: 2
    serialize_write_scope_conflicts: true
  closeout_policy:
    required_child_terminal_outcomes: ["archived", "rejected"]
    require_child_receipts_fresh: true
    require_aggregate_evidence: true
    enforce_authority_boundaries: true
  authority_boundaries:
    parent_coordinates_only: true
    child_receipts_remain_child_owned: true
    child_promotion_targets_remain_child_owned: true
states: [{ state_id: "coordinate" }]
terminal_outcomes:
  - outcome_id: "archived"
    when: { manifest_status: "archived" }
  - outcome_id: "rejected"
    when: { manifest_status: "rejected" }
routes:
  - route_id: "generate-program-implementation-prompt"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: ["program-implementation-prompt"]
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
"#,
            );
        }

        fn write_program_contract_with_recovery_recipes(&self) {
            self.write(
                ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycles/proposal-program.contract.yml",
                r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-program"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "program_packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted", "implemented"] }
program:
  child_registry_path: "resources/child-packet-index.yml"
  child_lifecycle_id_default: "proposal-packet"
  supported_execution_modes: ["parallel-independent"]
  recovery_policy:
    max_recovery_attempts: 2
    serialize_write_scope_conflicts: true
    recipes:
      - blocker_class: "stale-receipt"
        recovery_route_id: "run-implementation"
        preconditions: ["receipt-stale", "selected-route-present"]
        idempotency_class: "idempotent"
        human_required: false
        retry_budget: 1
        dependent_handling: "block-dependents"
        post_attempt_validation: ["replan-live-state", "receipt-fresh"]
        replan_behavior: "after-attempt"
  authority_boundaries:
    parent_coordinates_only: true
    child_receipts_remain_child_owned: true
    child_promotion_targets_remain_child_owned: true
states: [{ state_id: "coordinate" }]
routes:
  - route_id: "generate-program-implementation-prompt"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: ["program-implementation-prompt"]
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
"#,
            );
        }

        fn write_program_contract_with_residue_cleanup_route(&self) {
            self.write(
                ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycles/proposal-program.contract.yml",
                r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-program"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "program_packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted", "implemented"] }
program:
  child_registry_path: "resources/child-packet-index.yml"
  child_lifecycle_id_default: "proposal-packet"
  supported_execution_modes: ["parallel-independent"]
  recovery_policy:
    max_recovery_attempts: 2
    serialize_write_scope_conflicts: true
    handlers:
      lifecycle-residue-cleanup-needed:
        recovery_route_id: "cleanup-lifecycle-residue"
        max_attempts: 1
        replan_after_attempt: true
        human_required: false
    recipes:
      - blocker_class: "lifecycle-residue-cleanup-needed"
        recovery_route_id: "cleanup-lifecycle-residue"
        idempotency_class: "idempotent-rerun"
        human_required: false
        retry_budget: 1
        dependent_handling: "continue-independent"
        post_attempt_validation: ["replan-live-state"]
        replan_behavior: "after-attempt"
        allowed_authority_zones: ["workspace-declared", "octon-run-bound", "current-run-agent-artifact"]
        allowed_artifact_classes: ["workspace-source", "run-control", "run-evidence", "current-run-generated"]
        operation_class: "program-recovery-action"
        requires_zone_evidence: true
  authority_boundaries:
    parent_coordinates_only: true
    child_receipts_remain_child_owned: true
    child_promotion_targets_remain_child_owned: true
states: [{ state_id: "coordinate" }]
receipts:
  - receipt_id: "lifecycle-residue-cleanup"
    path: "support/lifecycle-residue-cleanup.md"
    required_fields: ["verdict", "cleaned_at", "cleanup_candidates", "manual_review_count", "worktree_hygiene_verdict", "remaining_blocker_class", "residue_fingerprint"]
    verdict_field: "verdict"
routes:
  - route_id: "generate-program-implementation-prompt"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: ["program-implementation-prompt"]
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
  - route_id: "cleanup-lifecycle-residue"
    route_type: "extension"
    command_id: "octon-proposal-cleanup-lifecycle-residue"
    skill_id: "octon-proposal-lifecycle-cleanup-lifecycle-residue"
    prompt_set_id: "octon-proposal-lifecycle-cleanup-lifecycle-residue"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared", "octon-run-bound", "current-run-agent-artifact"]
      declared_write_scope_source: "route-completion-and-target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: ["lifecycle-residue-cleanup"]
      replay_class: "idempotent-rerun"
      automated_recovery_policy: "bounded-retry"
      human_only_boundaries: ["scope-expansion", "policy-override", "unresolved-risk-acceptance", "authority-ambiguity"]
    completion:
      expected_receipts: ["lifecycle-residue-cleanup"]
      expected_paths: ["support/lifecycle-residue-cleanup.md"]
      replan_required: true
"#,
            );
        }

        fn write_program_contract_with_publication_recovery_action(&self) {
            self.write(
                ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycles/proposal-program.contract.yml",
                r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-program"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "program_packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted", "implemented"] }
program:
  child_registry_path: "resources/child-packet-index.yml"
  child_lifecycle_id_default: "proposal-packet"
  supported_execution_modes: ["parallel-independent"]
  recovery_policy:
    max_recovery_attempts: 2
    serialize_write_scope_conflicts: true
    handlers:
      publication-drift:
        max_attempts: 1
        replan_after_attempt: true
    recipes:
      - blocker_class: "publication-drift"
        recovery_action_id: "refresh-publication-projections"
        idempotency_class: "idempotent-rerun"
        human_required: false
        retry_budget: 1
        dependent_handling: "pause-dependent"
        post_attempt_validation: ["replan-live-state", "publication-freshness-cleared", "replay-verify"]
        replan_behavior: "after-attempt"
  authority_boundaries:
    parent_coordinates_only: true
    child_receipts_remain_child_owned: true
    child_promotion_targets_remain_child_owned: true
states: [{ state_id: "coordinate" }]
routes:
  - route_id: "generate-program-implementation-prompt"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: ["program-implementation-prompt"]
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
"#,
            );
        }

        fn write_publication_recovery_scripts(&self, pass: bool, clear_child_blocker: bool) {
            let generate_support = if pass {
                if clear_child_blocker {
                    r#"#!/usr/bin/env bash
set -euo pipefail
mkdir -p children/a/support
cat > children/a/support/implementation-run.md <<'EOF'
verdict: pass
EOF
cat > children/a/support/implementation-conformance-review.md <<'EOF'
verdict: pass
EOF
cat > children/a/support/post-implementation-drift-churn-review.md <<'EOF'
verdict: pass
EOF
printf 'support envelope refreshed\n'
"#
                } else {
                    "#!/usr/bin/env bash\nprintf 'support envelope refreshed\\n'\n"
                }
            } else {
                "#!/usr/bin/env bash\nprintf 'support envelope failed\\n' >&2\nexit 3\n"
            };
            self.write(
                ".octon/framework/assurance/runtime/_ops/scripts/generate-support-envelope-reconciliation.sh",
                generate_support,
            );
            self.write(
                ".octon/framework/assurance/runtime/_ops/scripts/generate-run-health-read-model.sh",
                "#!/usr/bin/env bash\nprintf 'run health refreshed\\n'\n",
            );
            self.write(
                ".octon/framework/assurance/runtime/_ops/scripts/validate-support-envelope-reconciliation.sh",
                "#!/usr/bin/env bash\nprintf 'support envelope valid\\n'\n",
            );
            self.write(
                ".octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh",
                "#!/usr/bin/env bash\nprintf 'run health valid\\n'\n",
            );
            self.write(
                ".octon/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh",
                "#!/usr/bin/env bash\nprintf 'architecture valid\\n'\n",
            );
        }

        fn write_worktree_hygiene_classifier(&self, pass: bool) {
            let verdict = if pass { "pass" } else { "blocked" };
            let foreign_path_count = if pass { 0 } else { 1 };
            let foreign_fingerprint = if pass { "sha256:clean" } else { "sha256:dirty" };
            self.write(
                ".octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh",
                &format!(
                    "#!/usr/bin/env bash\nprintf 'worktree_hygiene_verdict: \"{verdict}\"\\n'\nprintf 'worktree_hygiene_blocker_class: \"worktree-hygiene-blocked\"\\n'\nprintf 'worktree_hygiene_foreign_path_count: {foreign_path_count}\\n'\nprintf 'worktree_hygiene_foreign_fingerprint: \"{foreign_fingerprint}\"\\n'\n"
                ),
            );
        }

        fn write_worktree_hygiene_classifier_blocking_child(
            &self,
            child_id: &str,
            fingerprint: &str,
        ) {
            self.write(
                ".octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh",
                &format!(
                    r#"#!/usr/bin/env bash
set -euo pipefail
target=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      target="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done
if [[ "$target" == *"children/{child_id}"* ]]; then
  printf 'worktree_hygiene_verdict: "blocked"\n'
  printf 'worktree_hygiene_blocker_class: "worktree-hygiene-blocked"\n'
  printf 'worktree_hygiene_foreign_path_count: 1\n'
  printf 'worktree_hygiene_foreign_fingerprint: "{fingerprint}"\n'
else
  printf 'worktree_hygiene_verdict: "pass"\n'
  printf 'worktree_hygiene_blocker_class: ""\n'
  printf 'worktree_hygiene_foreign_path_count: 0\n'
  printf 'worktree_hygiene_foreign_fingerprint: "sha256:clean"\n'
fi
"#
                ),
            );
        }

        fn write_program_contract_with_safe_unsafe_repair(&self) {
            self.write(
                ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycles/proposal-program.contract.yml",
                r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-program"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "program_packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted", "implemented"] }
program:
  child_registry_path: "resources/child-packet-index.yml"
  child_lifecycle_id_default: "proposal-packet"
  supported_execution_modes: ["parallel-independent"]
  recovery_policy:
    max_recovery_attempts: 2
    serialize_write_scope_conflicts: true
    recipes:
      - blocker_class: "unsupported-mode-authority"
        recovery_route_id: "run-implementation"
        idempotency_class: "idempotent"
        human_required: false
        retry_budget: 1
        dependent_handling: "continue-independent"
        post_attempt_validation: ["replan-live-state"]
        replan_behavior: "after-attempt"
  authority_boundaries:
    parent_coordinates_only: true
    child_receipts_remain_child_owned: true
    child_promotion_targets_remain_child_owned: true
states: [{ state_id: "coordinate" }]
routes:
  - route_id: "generate-program-implementation-prompt"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: ["program-implementation-prompt"]
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
"#,
            );
        }

        fn write_program_contract_with_safe_program_unsafe_repair(&self, safe: bool) {
            let idempotency_class = if safe { "idempotent" } else { "non-idempotent" };
            self.write_program_contract_with_program_unsafe_repair_recipe(
                idempotency_class,
                "post_attempt_validation: [\"replan-live-state\"]",
                "",
                true,
            );
        }

        fn write_program_contract_with_program_unsafe_repair_recipe(
            &self,
            idempotency_class: &str,
            post_attempt_validation_line: &str,
            preconditions_line: &str,
            declare_route: bool,
        ) {
            let route = if declare_route {
                r#"
  - route_id: "generate-program-implementation-prompt"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: ["program-implementation-prompt"]
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
"#
            } else {
                ""
            };
            self.write(
                ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycles/proposal-program.contract.yml",
                &format!(
                    r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-program"
owner_extension: "test-extension"
version: "1.0.0"
target: {{ input: "program_packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted", "implemented"] }}
program:
  child_registry_path: "resources/child-packet-index.yml"
  child_lifecycle_id_default: "proposal-packet"
  supported_execution_modes: ["parallel-independent"]
  recovery_policy:
    max_recovery_attempts: 2
    serialize_write_scope_conflicts: true
    recipes:
      - blocker_class: "unsupported-mode-authority"
        recovery_route_id: "generate-program-implementation-prompt"
        {preconditions_line}
        idempotency_class: "{idempotency_class}"
        human_required: false
        retry_budget: 1
        dependent_handling: "continue-independent"
        {post_attempt_validation_line}
        replan_behavior: "after-attempt"
  authority_boundaries:
    parent_coordinates_only: true
    child_receipts_remain_child_owned: true
    child_promotion_targets_remain_child_owned: true
states: [{{ state_id: "coordinate" }}]
routes:{route}
"#
                ),
            );
        }

        fn write_program_contract_with_recovery_approval(&self) {
            self.write(
                ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycles/proposal-program.contract.yml",
                r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-program"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "program_packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted", "implemented"] }
program:
  child_registry_path: "resources/child-packet-index.yml"
  child_lifecycle_id_default: "proposal-packet"
  supported_execution_modes: ["parallel-independent"]
  recovery_policy:
    max_recovery_attempts: 2
    serialize_write_scope_conflicts: true
    recipes:
      - blocker_class: "stale-receipt"
        recovery_route_id: "run-implementation"
        preconditions: ["receipt-stale", "selected-route-present"]
        idempotency_class: "idempotent"
        human_required: false
        retry_budget: 1
        dependent_handling: "pause-dependent"
        post_attempt_validation: ["replan-live-state"]
        replan_behavior: "after-attempt"
  authority_boundaries:
    parent_coordinates_only: true
    child_receipts_remain_child_owned: true
    child_promotion_targets_remain_child_owned: true
states: [{ state_id: "coordinate" }]
routes:
  - route_id: "generate-program-implementation-prompt"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: ["program-implementation-prompt"]
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
"#,
            );
        }

        fn write_program_contract_with_recovery_handlers_only(&self) {
            self.write(
                ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycles/proposal-program.contract.yml",
                r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-program"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "program_packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted", "implemented"] }
program:
  child_registry_path: "resources/child-packet-index.yml"
  child_lifecycle_id_default: "proposal-packet"
  supported_execution_modes: ["parallel-independent"]
  recovery_policy:
    max_recovery_attempts: 2
    serialize_write_scope_conflicts: true
    handlers:
      stale-receipt:
        recovery_route_id: "run-implementation"
        max_attempts: 1
        human_required: false
        replan_after_attempt: true
  authority_boundaries:
    parent_coordinates_only: true
    child_receipts_remain_child_owned: true
    child_promotion_targets_remain_child_owned: true
states: [{ state_id: "coordinate" }]
routes:
  - route_id: "generate-program-implementation-prompt"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: ["program-implementation-prompt"]
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
"#,
            );
        }

        fn write_program_contract_with_recovery_replay_verify(&self) {
            self.write(
                ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycles/proposal-program.contract.yml",
                r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-program"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "program_packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted", "implemented"] }
program:
  child_registry_path: "resources/child-packet-index.yml"
  child_lifecycle_id_default: "proposal-packet"
  supported_execution_modes: ["parallel-independent"]
  recovery_policy:
    max_recovery_attempts: 2
    serialize_write_scope_conflicts: true
    recipes:
      - blocker_class: "stale-receipt"
        recovery_route_id: "run-implementation"
        idempotency_class: "idempotent"
        human_required: false
        retry_budget: 1
        dependent_handling: "continue-independent"
        post_attempt_validation: ["replay-verify"]
        replan_behavior: "none"
  authority_boundaries:
    parent_coordinates_only: true
    child_receipts_remain_child_owned: true
    child_promotion_targets_remain_child_owned: true
states: [{ state_id: "coordinate" }]
routes:
  - route_id: "generate-program-implementation-prompt"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: ["program-implementation-prompt"]
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
"#,
            );
        }

        fn write_bad_child_contract_with_unsupported_input(&self) {
            self.write(
                ".octon/generated/effective/extensions/catalog.effective.yml",
                r#"
schema_version: "test"
packs:
  - pack_id: "test-extension"
    capability_profiles: ["validation-surface", "lifecycle-contract"]
    lifecycle_contracts:
      - lifecycle_id: "proposal-packet"
        projection_source_path: ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml"
      - lifecycle_id: "bad-child"
        projection_source_path: ".octon/generated/effective/extensions/published/test-extension/bundled/context/bad-child.contract.yml"
      - lifecycle_id: "proposal-program"
        projection_source_path: ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycles/proposal-program.contract.yml"
"#,
            );
            self.write(
                ".octon/generated/effective/extensions/published/test-extension/bundled/context/bad-child.contract.yml",
                r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "bad-child"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted", "implemented"] }
input_bindings:
  unsupported:
    source: "unsupported.source"
states: [{ state_id: "implement" }]
terminal_outcomes:
  - outcome_id: "implemented"
    when: { manifest_status: "implemented" }
receipts:
  - receipt_id: "implementation-run"
    path: "support/implementation-run.md"
routes:
  - route_id: "run-implementation"
    route_type: "extension"
    enter_when: { manifest_status: "accepted" }
"#,
            );
        }

        fn write_parent(&self) {
            self.write("parent/proposal.yml", "status: accepted\n");
        }

        fn write_parent_status(&self, status: &str) {
            self.write("parent/proposal.yml", &format!("status: {status}\n"));
        }

        fn write_parent_review_receipt(&self, verdict: &str, digest: &str) {
            self.write(
                "parent/support/proposal-review.md",
                &format!(
                    "review_id: review-001\nreviewed_at: 2026-05-12T00:00:00Z\nreviewer: tester\nverdict: {verdict}\nimplementation_prompt_authorized: yes\nreviewed_packet_digest: {digest}\nopen_blocking_findings_count: 0\n"
                ),
            );
        }

        fn write_program_implementation_prompt_receipt(&self) {
            self.write(
                "parent/support/executable-program-implementation-prompt.md",
                "prompt_id: program-implementation-001\n",
            );
        }

        fn write_program_verification_prompt_receipt(&self) {
            self.write(
                "parent/support/follow-up-program-verification-prompt.md",
                "prompt_id: program-verification-001\n",
            );
        }

        fn write_program_closeout_prompt_receipt(&self) {
            self.write(
                "parent/support/custom-program-closeout-prompt.md",
                "prompt_id: program-closeout-001\n",
            );
        }

        fn write_parent_aggregate_verification_receipts(
            &self,
            verdict: &str,
            child_authority_preserved: &str,
        ) {
            let body = format!(
                "verdict: {verdict}\nunresolved_items_count: 0\nchild_receipt_summary_count: 1\nchild_authority_preserved: {child_authority_preserved}\n"
            );
            self.write(
                "parent/support/program-implementation-conformance-review.md",
                &body,
            );
            self.write(
                "parent/support/program-post-implementation-drift-churn-review.md",
                &body,
            );
        }

        fn write_parent_implementation_run_receipt(&self, child_authority_preserved: &str) {
            self.write(
                "parent/support/implementation-run.md",
                &format!(
                    "verdict: pass\nimplemented_at: 2026-05-12T00:00:00Z\npromotion_evidence_count: 1\nchild_authority_preserved: {child_authority_preserved}\n"
                ),
            );
        }

        fn write_parent_closeout_receipt(&self, child_authority_preserved: &str) {
            self.write(
                "parent/support/proposal-closeout.md",
                &format!(
                    "verdict: pass\nclosed_at: 2026-05-12T00:00:00Z\narchive_authorized: yes\nchild_authority_preserved: {child_authority_preserved}\n"
                ),
            );
        }

        fn write_child(&self, id: &str, promotion_target: &str, status: &str) {
            self.write(
                &format!("children/{id}/proposal.yml"),
                &format!("status: {status}\npromotion_targets:\n  - \"{promotion_target}\"\n"),
            );
        }

        fn write_registry(&self, execution_mode: &str, children: &str) {
            self.write(
                "parent/resources/child-packet-index.yml",
                &format!(
                    "schema_version: \"octon-proposal-program-child-registry-v1\"\nexecution_mode: \"{execution_mode}\"\ndefault_child_lifecycle_id: \"proposal-packet\"\nchildren:\n{children}"
                ),
            );
        }

        fn write_v2_registry(&self, execution_mode: &str, children: &str) {
            self.write(
                "parent/resources/child-packet-index.yml",
                &format!(
                    "schema_version: \"octon-proposal-program-child-registry-v2\"\nexecution_mode: \"{execution_mode}\"\ndefault_child_lifecycle_id: \"proposal-packet\"\nchildren:\n{children}"
                ),
            );
        }
    }

    impl Drop for ProgramFixture {
        fn drop(&mut self) {
            let _ = fs::remove_dir_all(&self.root);
        }
    }

    fn assert_program_route(plan: &ProgramLifecyclePlanResult, expected: &str) {
        assert_eq!(
            plan.program_route
                .as_ref()
                .map(|route| route.route_id.as_str()),
            Some(expected)
        );
    }

    fn program_review_fixture(name: &str, parent_status: &str) -> ProgramFixture {
        let fixture = ProgramFixture::new(name, true);
        fixture.write_program_contract_with_parent_review_workflows();
        fixture.write_parent_status(parent_status);
        fixture.write_child("a", "framework/a.md", "implemented");
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );
        fixture
    }

    #[test]
    fn parallel_independent_selects_all_independent_children() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("parallel", true);
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_child("b", "framework/b.md", "accepted");
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
  - child_id: "b"
    path: "children/b"
"#,
        );

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert_eq!(plan.runnable_batch, vec!["a".to_string(), "b".to_string()]);
        assert_eq!(plan.final_verdict, "planned");
    }

    #[test]
    fn program_level_route_gate_blocks_program_implementation_prompt() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("program-route-gate", true);
        fixture.write_program_contract_with_failing_program_gate();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert_eq!(
            plan.blocked_by_program_gate.as_deref(),
            Some("program-child-proposal-readiness")
        );
        assert!(plan.program_route.is_none());
        assert!(plan.program_gate_results.iter().any(|result| {
            result.gate_id == "program-child-proposal-readiness" && !result.passed
        }));
        assert!(plan.program_blockers.iter().any(|blocker| {
            blocker.blocker_class == "recovery-route-unavailable"
                && blocker
                    .message
                    .contains("generate-program-implementation-prompt")
                && blocker.message.contains("validation-failed")
        }));
    }

    #[test]
    fn program_review_workflow_routes_draft_parent_to_review() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = program_review_fixture("program-review-draft", "draft");

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert_program_route(&plan, "review-proposal-program");
    }

    #[test]
    fn program_review_workflow_routes_revision_required_to_revise() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = program_review_fixture("program-review-revision", "in-review");
        fixture.write_parent_review_receipt("revision-required", "sha256:live");

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert_program_route(&plan, "revise-proposal-program");
    }

    #[test]
    fn program_review_workflow_routes_accepted_review_to_program_prompt() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = program_review_fixture("program-review-accepted", "accepted");
        fixture.write_parent_review_receipt("accepted", "sha256:live");

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert_program_route(&plan, "generate-program-implementation-prompt");
        assert!(plan
            .program_gate_results
            .iter()
            .any(|result| { result.gate_id == "program-review-authorization" && result.passed }));
        assert!(plan.program_gate_results.iter().any(|result| {
            result.gate_id == "program-child-proposal-readiness" && result.passed
        }));
    }

    #[test]
    fn program_review_workflow_routes_implementation_run_to_promote() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = program_review_fixture("program-review-promote", "accepted");
        fixture.write_parent_review_receipt("accepted", "sha256:live");
        fixture.write_program_implementation_prompt_receipt();
        fixture.write_parent_implementation_run_receipt("yes");

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert_program_route(&plan, "promote-proposal");
        assert!(plan
            .program_gate_results
            .iter()
            .any(|result| { result.gate_id == "program-review-authorization" && result.passed }));
    }

    #[test]
    fn unattended_parent_promotion_dispatches_with_child_authority_preserved() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = program_review_fixture("program-promote-unattended-safe", "accepted");
        fixture.write_parent_review_receipt("accepted", "sha256:live");
        fixture.write_program_implementation_prompt_receipt();
        fixture.write_parent_implementation_run_receipt("yes");

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("program-promote-unattended-safe".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: Some(1),
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        assert_eq!(
            result
                .parent_route_result
                .as_ref()
                .map(|route| route.status.as_str()),
            Some("completed")
        );
        let receipt_path = fixture.octon_dir.join(
            "state/evidence/runs/workflows/program-promote-unattended-safe/parent/delegated-promotion-parent-promote-proposal.yml",
        );
        let receipt = fs::read_to_string(&receipt_path).unwrap();
        assert!(receipt.contains("delegation_kind: machine-enforced-delegated-execution"));
        assert!(receipt.contains("human_exception_grant: false"));
        assert!(receipt.contains("implementation-run.child_authority_preserved"));
    }

    #[test]
    fn program_review_workflow_routes_closeout_receipt_to_archive() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = program_review_fixture("program-review-archive", "implemented");
        fixture.write_program_verification_prompt_receipt();
        fixture.write_parent_aggregate_verification_receipts("pass", "yes");
        fixture.write_program_closeout_prompt_receipt();
        fixture.write_parent_closeout_receipt("yes");

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert_program_route(&plan, "archive-proposal");
    }

    #[test]
    fn program_create_completion_expects_program_creation_receipt() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = program_review_fixture("program-create-receipt", "draft");
        let loaded = load_lifecycle_contract(&fixture.octon_dir, "proposal-program").unwrap();
        let create_route = loaded
            .contract
            .routes
            .iter()
            .find(|route| route.route_id == "create-proposal-program")
            .unwrap();

        assert!(create_route
            .completion
            .as_ref()
            .unwrap()
            .expected_receipts
            .iter()
            .any(|receipt| receipt == "program-creation"));
    }

    #[test]
    fn missing_program_target_or_registry_routes_to_program_create() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("program-create-missing", true);
        fixture.write_program_contract_with_parent_review_workflows();
        fixture.write_parent_status("draft");

        let missing_target = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("missing-parent"),
        )
        .unwrap();
        assert_program_route(&missing_target, "create-proposal-program");
        assert!(missing_target.runnable_batch.is_empty());
        assert_eq!(
            missing_target.child_registry_digest,
            MISSING_CHILD_REGISTRY_DIGEST
        );

        let missing_registry = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();
        assert_program_route(&missing_registry, "create-proposal-program");
        assert!(missing_registry.runnable_batch.is_empty());
    }

    #[test]
    fn invalid_existing_program_registry_blocks_without_scheduling_children() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("program-invalid-registry", true);
        fixture.write("parent/resources/child-packet-index.yml", "children: [");

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert!(plan.program_route.is_none());
        assert!(plan.runnable_batch.is_empty());
        assert_eq!(plan.final_verdict, "blocked-unsafe");
        assert!(plan.program_blockers.iter().any(|blocker| {
            blocker.blocker_class == "validation-failed"
                && blocker.message.contains("failed to parse child registry")
        }));
    }

    #[test]
    fn selected_parent_route_prevents_child_scheduling_for_run_pass() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = program_review_fixture("program-parent-route-precedence", "draft");
        fixture.write_child("a", "framework/a.md", "accepted");

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("program-parent-route-precedence".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: false,
                max_steps: None,
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        assert_eq!(
            result
                .selected_parent_route
                .as_ref()
                .map(|route| route.route_id.as_str()),
            Some("review-proposal-program")
        );
        assert!(result.selected_children.is_empty());
        assert!(result.child_results.is_empty());
        assert_eq!(result.final_verdict, "route-ready");
    }

    #[test]
    fn parent_route_execution_observes_contract_declared_receipts() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = program_review_fixture("program-parent-route-execution", "draft");
        fixture.write_parent_review_receipt("accepted", "sha256:live");

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("program-parent-route-execution".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: Some(1),
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        let parent_result = result.parent_route_result.as_ref().unwrap();
        assert_eq!(parent_result.route_id, "review-proposal-program");
        assert_eq!(parent_result.status, "completed");
        assert!(parent_result.receipts_observed.iter().any(|receipt| {
            receipt.receipt_id == "proposal-review" && receipt.exists && receipt.complete
        }));
        assert!(result.selected_children.is_empty());
        assert_eq!(result.final_verdict, "step-budget-exhausted-continuable");
        let events = read_program_events(
            &fixture
                .octon_dir
                .join("state/control/execution/runs/program-parent-route-execution"),
        )
        .unwrap();
        assert!(events
            .iter()
            .any(|event| event.event_type == "parent-route-started"));
        assert!(events
            .iter()
            .any(|event| event.event_type == "max-steps-exhausted"));
    }

    #[test]
    fn failing_program_structure_preflight_blocks_child_scheduling() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("program-structure-preflight", true);
        fixture.write_program_contract_with_parent_review_workflows();
        fixture.write(
            ".octon/framework/assurance/runtime/_ops/scripts/pass-program-gate.sh",
            "#!/usr/bin/env bash\nprintf 'program gate failed\\n'\nexit 1\n",
        );
        fixture.write_parent_status("accepted");
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert!(plan.program_route.is_none());
        assert!(plan.runnable_batch.is_empty());
        assert!(plan
            .program_gate_results
            .iter()
            .any(|result| { result.gate_id == "program-structure" && !result.passed }));
        assert!(plan.program_blockers.iter().any(|blocker| {
            blocker.blocker_class == "validation-failed"
                && blocker.message.contains("program-structure")
        }));
    }

    #[test]
    fn parent_terminal_status_not_child_aggregate_controls_program_terminal_outcome() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = program_review_fixture("program-parent-terminal", "accepted");

        let child_complete_plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();
        assert_eq!(child_complete_plan.aggregate_state, "completed");
        assert!(child_complete_plan.terminal_outcome.is_none());

        fixture.write_parent_status("archived");
        let parent_terminal_plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();
        assert_eq!(
            parent_terminal_plan.terminal_outcome.as_deref(),
            Some("archived")
        );
        assert_eq!(parent_terminal_plan.final_verdict, "completed");
    }

    #[test]
    fn program_planner_resolves_archived_registry_child_without_recreating_active_path() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("archived-registry-child", true);
        fixture.write_full_child_contract();
        fixture.write(
            ".octon/inputs/exploratory/proposals/.archive/architecture/a/proposal.yml",
            "status: archived\npromotion_targets:\n  - \"framework/a.md\"\n",
        );
        fixture.write(
            ".octon/inputs/exploratory/proposals/architecture/b/proposal.yml",
            "status: accepted\npromotion_targets:\n  - \"framework/b.md\"\n",
        );
        fixture.write_registry(
            "gated-parallel",
            r#"  - child_id: "a"
    path: ".octon/inputs/exploratory/proposals/architecture/a"
    phase_id: "phase-a"
  - child_id: "b"
    path: ".octon/inputs/exploratory/proposals/architecture/b"
    phase_id: "phase-b"
"#,
        );

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        let archived = plan.child_states.get("a").unwrap();
        assert_eq!(archived.terminal_outcome.as_deref(), Some("archived"));
        assert_eq!(
            archived.target,
            ".octon/inputs/exploratory/proposals/.archive/architecture/a"
        );
        assert!(archived.selected_route.is_none());
        assert!(!archived
            .blockers
            .iter()
            .any(|blocker| blocker.recovery_route.as_deref() == Some("create-packet")));
        assert_eq!(plan.runnable_batch, vec!["b".to_string()]);
    }

    #[test]
    fn program_verification_prompt_with_missing_aggregate_receipts_routes_to_loop() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = program_review_fixture("program-verification-loop", "implemented");
        fixture.write_program_verification_prompt_receipt();

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert_program_route(&plan, "run-program-verification-and-correction-loop");
    }

    #[test]
    fn program_aggregate_receipts_route_to_generate_closeout_prompt() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = program_review_fixture("program-aggregate-closeout-prompt", "implemented");
        fixture.write_program_verification_prompt_receipt();
        fixture.write_parent_aggregate_verification_receipts("pass", "yes");

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert_program_route(&plan, "generate-program-closeout-prompt");
    }

    #[test]
    fn program_aggregate_receipts_route_to_closeout_after_prompt() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = program_review_fixture("program-aggregate-closeout", "implemented");
        fixture.write_program_verification_prompt_receipt();
        fixture.write_parent_aggregate_verification_receipts("pass", "yes");
        fixture.write_program_closeout_prompt_receipt();

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert_program_route(&plan, "closeout-proposal-program");
    }

    #[test]
    fn program_closeout_blocks_failing_aggregate_receipts() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = program_review_fixture("program-aggregate-fail", "implemented");
        fixture.write_program_verification_prompt_receipt();
        fixture.write_parent_aggregate_verification_receipts("fail", "yes");
        fixture.write_program_closeout_prompt_receipt();

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert!(plan.program_route.is_none());
    }

    #[test]
    fn program_closeout_blocks_aggregate_receipts_without_child_authority_preservation() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = program_review_fixture("program-aggregate-authority-blocked", "implemented");
        fixture.write_program_verification_prompt_receipt();
        fixture.write_parent_aggregate_verification_receipts("pass", "no");
        fixture.write_program_closeout_prompt_receipt();

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert!(plan.program_route.is_none());
    }

    #[test]
    fn program_review_workflow_routes_stale_parent_review_back_to_review() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = program_review_fixture("program-review-stale", "accepted");
        fixture.write_parent_review_receipt("accepted", "sha256:old");

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert_program_route(&plan, "review-proposal-program");
    }

    #[test]
    fn program_review_workflow_blocks_promote_without_child_authority_preservation() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = program_review_fixture("program-review-promote-blocked", "accepted");
        fixture.write_parent_review_receipt("accepted", "sha256:live");
        fixture.write_program_implementation_prompt_receipt();
        fixture.write_parent_implementation_run_receipt("no");

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert!(plan.program_route.is_none());
    }

    #[test]
    fn program_review_workflow_blocks_archive_without_child_authority_preservation() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = program_review_fixture("program-review-archive-blocked", "implemented");
        fixture.write_program_verification_prompt_receipt();
        fixture.write_parent_aggregate_verification_receipts("pass", "yes");
        fixture.write_program_closeout_prompt_receipt();
        fixture.write_parent_closeout_receipt("no");

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert!(plan.program_route.is_none());
    }

    #[test]
    fn sequential_selects_only_first_runnable_child() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("sequential", true);
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_child("b", "framework/b.md", "accepted");
        fixture.write_registry(
            "sequential",
            r#"  - child_id: "a"
    path: "children/a"
  - child_id: "b"
    path: "children/b"
"#,
        );

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert_eq!(plan.runnable_batch, vec!["a".to_string()]);
    }

    #[test]
    fn dependency_blocks_dependents_until_parent_child_terminal() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("dependency", true);
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_child("b", "framework/b.md", "accepted");
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
  - child_id: "b"
    path: "children/b"
    dependencies: ["a"]
"#,
        );

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert_eq!(plan.runnable_batch, vec!["a".to_string()]);
        let b = plan.child_states.get("b").unwrap();
        assert!(b
            .blockers
            .iter()
            .any(|blocker| blocker.blocker_class == "dependency-gate-unsatisfied"));
    }

    #[test]
    fn verification_dependency_gate_allows_downstream_before_archive() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("dependency-verification-gate", true);
        fixture.write_full_child_contract();
        fixture.write_child("a", "framework/a.md", "implemented");
        fixture.write(
            "children/a/support/implementation-run.md",
            "verdict: pass\n",
        );
        fixture.write(
            "children/a/support/implementation-conformance-review.md",
            "verdict: pass\n",
        );
        fixture.write(
            "children/a/support/post-implementation-drift-churn-review.md",
            "verdict: pass\n",
        );
        fixture.write_child("b", "framework/b.md", "accepted");
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
  - child_id: "b"
    path: "children/b"
    dependencies: ["a"]
    dependency_gate: "verification"
"#,
        );

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert!(plan.runnable_batch.iter().any(|child| child == "b"));
        let b = plan.child_states.get("b").unwrap();
        assert!(b.dependency_gate_status.get("a").unwrap().satisfied);
        assert!(!b
            .blockers
            .iter()
            .any(|blocker| blocker.blocker_class == "dependency-gate-unsatisfied"));
    }

    #[test]
    fn closeout_dependency_gate_requires_closeout_pass_or_terminal() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("dependency-closeout-gate", true);
        fixture.write_full_child_contract();
        fixture.write_child("a", "framework/a.md", "implemented");
        fixture.write(
            "children/a/support/implementation-run.md",
            "verdict: pass\n",
        );
        fixture.write(
            "children/a/support/implementation-conformance-review.md",
            "verdict: pass\n",
        );
        fixture.write(
            "children/a/support/post-implementation-drift-churn-review.md",
            "verdict: pass\n",
        );
        fixture.write_child("b", "framework/b.md", "accepted");
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
  - child_id: "b"
    path: "children/b"
    dependencies: ["a"]
    dependency_gate: "closeout"
"#,
        );

        let blocked = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();
        let b = blocked.child_states.get("b").unwrap();
        assert!(!b.dependency_gate_status.get("a").unwrap().satisfied);
        assert!(b
            .blockers
            .iter()
            .any(|blocker| blocker.message.contains("closeout gate")));

        fixture.write(
            "children/a/support/proposal-closeout.md",
            "verdict: pass\narchive_authorized: yes\n",
        );
        let released = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();
        let b = released.child_states.get("b").unwrap();
        assert!(b.dependency_gate_status.get("a").unwrap().satisfied);
        assert!(released.runnable_batch.iter().any(|child| child == "b"));
    }

    #[test]
    fn partial_child_completion_keeps_remaining_child_runnable() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("partial", true);
        fixture.write_child("a", "framework/a.md", "implemented");
        fixture.write_child("b", "framework/b.md", "accepted");
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
  - child_id: "b"
    path: "children/b"
"#,
        );

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert_eq!(plan.runnable_batch, vec!["b".to_string()]);
        assert_eq!(plan.aggregate_state, "partial");
        assert_eq!(plan.final_verdict, "partial");
    }

    #[test]
    fn gated_parallel_selects_only_the_next_open_phase() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("gated-parallel", true);
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_child("b", "framework/b.md", "accepted");
        fixture.write_child("c", "framework/c.md", "accepted");
        fixture.write_registry(
            "gated-parallel",
            r#"  - child_id: "a"
    path: "children/a"
    phase_id: "phase-1"
  - child_id: "b"
    path: "children/b"
    phase_id: "phase-1"
  - child_id: "c"
    path: "children/c"
    phase_id: "phase-2"
"#,
        );

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert_eq!(plan.runnable_batch, vec!["a".to_string(), "b".to_string()]);
    }

    #[test]
    fn gated_parallel_skips_blocked_non_runnable_phase_when_dependency_gate_is_satisfied() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("gated-parallel-skip-blocked-phase", true);
        fixture.write_full_child_contract();
        fixture.write_child("a", "framework/a.md", "implemented");
        fixture.write(
            "children/a/support/implementation-run.md",
            "verdict: pass\n",
        );
        fixture.write(
            "children/a/support/implementation-conformance-review.md",
            "verdict: pass\n",
        );
        fixture.write(
            "children/a/support/post-implementation-drift-churn-review.md",
            "verdict: pass\n",
        );
        fixture.write(
            "children/a/support/proposal-closeout.md",
            "verdict: blocked\narchive_authorized: no\nworktree_hygiene_verdict: blocked\n",
        );
        fixture.write_child("b", "framework/b.md", "accepted");
        fixture.write_registry(
            "gated-parallel",
            r#"  - child_id: "a"
    path: "children/a"
    phase_id: "phase-1"
  - child_id: "b"
    path: "children/b"
    dependencies: ["a"]
    dependency_gate: "verification"
    phase_id: "phase-2"
"#,
        );

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert_eq!(plan.runnable_batch, vec!["b".to_string()]);
        assert_eq!(plan.scheduler_phase.as_deref(), Some("phase-2"));
        assert!(plan
            .skipped_blocked_children
            .iter()
            .any(|child| child == "a"));
    }

    #[test]
    fn approval_gated_planning_reports_approval_blockers() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("approval-gated", true);
        fixture.write_child_contract_with_human_boundary();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_registry(
            "approval-gated",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert_eq!(plan.runnable_batch, vec!["a".to_string()]);
        assert_eq!(plan.approval_blockers.len(), 1);
        assert_eq!(plan.approval_blockers[0].child_id, "a");
        assert_eq!(plan.approval_blockers[0].route_id, "run-implementation");
    }

    #[test]
    fn unattended_approval_auto_grants_only_safe_contract_routes() {
        let _guard = crate::acquire_kernel_test_lock();
        let unsafe_fixture = ProgramFixture::new("approval-unattended-unsafe-route", true);
        unsafe_fixture.write_child_contract_with_human_boundary();
        unsafe_fixture.write_child("a", "framework/a.md", "accepted");
        unsafe_fixture.write_registry(
            "approval-gated",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let unsafe_result = run_program_lifecycle_from_octon_dir(
            &unsafe_fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("approval-unattended-unsafe-route".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: Some(2),
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();
        assert_eq!(unsafe_result.final_verdict, "blocked-human");
        assert!(unsafe_result
            .child_results
            .iter()
            .any(|summary| summary.status == "human-boundary-blocked"));
        assert!(!unsafe_fixture
            .root
            .join("children/a/support/implementation-run.md")
            .exists());

        let safe_fixture = ProgramFixture::new("approval-unattended-safe-route", true);
        safe_fixture.write_child_contract_with_delegation_contract();
        safe_fixture.write_child("a", "framework/a.md", "accepted");
        safe_fixture.write_registry(
            "approval-gated",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let safe_result = run_program_lifecycle_from_octon_dir(
            &safe_fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("approval-unattended-safe-route".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: Some(1),
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();
        assert!(safe_result
            .child_results
            .iter()
            .any(|summary| summary.status == "completed"));
        assert!(safe_fixture
            .root
            .join("children/a/support/implementation-run.md")
            .is_file());
    }

    #[test]
    fn unattended_policy_blocks_workflow_promotion_without_safe_basis() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("approval-unattended-workflow-promote", true);
        fixture.write_child_contract_with_workflow_promotion_human_boundary();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write(
            "children/a/support/implementation-run.md",
            "verdict: pass\n",
        );
        fixture.write_registry(
            "approval-gated",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("approval-unattended-workflow-promote".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: Some(1),
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        assert_eq!(result.final_verdict, "blocked-human");
        assert!(result.child_results.iter().any(|summary| {
            summary.route_id == "promote-proposal" && summary.status == "human-boundary-blocked"
        }));
        assert_eq!(
            proposal_status_at_target(&fixture.root.join("children/a"))
                .unwrap()
                .as_deref(),
            Some("accepted")
        );
        assert!(!fixture
            .octon_dir
            .join("state/evidence/runs/workflows/approval-unattended-workflow-promote/children/a/authorization/promote-proposal-delegation-proof.yml")
            .exists());
    }

    #[test]
    fn unattended_policy_dispatches_workflow_promotion_with_safe_evidence() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("approval-unattended-workflow-promote-safe", true);
        fixture.write_child_contract_with_safe_workflow_promotion();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write(
            "children/a/support/implementation-run.md",
            "verdict: pass\n",
        );
        fixture.write(
            "children/a/support/implementation-conformance-review.md",
            "verdict: pass\n",
        );
        fixture.write(
            "children/a/support/post-implementation-drift-churn-review.md",
            "verdict: pass\n",
        );
        fixture.write_registry(
            "approval-gated",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("approval-unattended-workflow-promote-safe".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: Some(1),
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        assert!(result.child_results.iter().any(|summary| {
            summary.route_id == "promote-proposal" && summary.status == "completed"
        }));
        assert_eq!(
            proposal_status_at_target(&fixture.root.join("children/a"))
                .unwrap()
                .as_deref(),
            Some("implemented")
        );
        let receipt_path = fixture.octon_dir.join(
            "state/evidence/runs/workflows/approval-unattended-workflow-promote-safe/children/a/delegated-promotion-a-promote-proposal.yml",
        );
        let receipt = fs::read_to_string(&receipt_path).unwrap();
        assert!(receipt.contains("delegation_kind: machine-enforced-delegated-execution"));
        assert!(receipt.contains("human_exception_grant: false"));
        assert!(receipt.contains("implementation-conformance"));
        assert!(receipt.contains("post-implementation-drift"));
    }

    #[test]
    fn unattended_child_promotion_requires_conformance_and_drift_receipts() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("approval-unattended-workflow-promote-missing", true);
        fixture.write_child_contract_with_safe_workflow_promotion();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write(
            "children/a/support/implementation-run.md",
            "verdict: pass\n",
        );
        fixture.write_registry(
            "approval-gated",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("approval-unattended-workflow-promote-missing".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: Some(1),
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        assert!(result.child_results.iter().any(|summary| {
            summary.route_id == "promote-proposal" && summary.status == "human-boundary-blocked"
        }));
        assert!(!fixture
            .octon_dir
            .join("state/evidence/runs/workflows/approval-unattended-workflow-promote-missing/children/a/delegated-promotion-a-promote-proposal.yml")
            .exists());
    }

    #[test]
    fn unattended_child_promotion_blocks_failed_drift_receipt() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("approval-unattended-workflow-promote-drift", true);
        fixture.write_child_contract_with_safe_workflow_promotion();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write(
            "children/a/support/implementation-run.md",
            "verdict: pass\n",
        );
        fixture.write(
            "children/a/support/implementation-conformance-review.md",
            "verdict: pass\n",
        );
        fixture.write(
            "children/a/support/post-implementation-drift-churn-review.md",
            "verdict: fail\n",
        );
        fixture.write_registry(
            "approval-gated",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("approval-unattended-workflow-promote-drift".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: Some(1),
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        assert!(!result.child_results.iter().any(|summary| {
            summary.route_id == "promote-proposal" && summary.status == "completed"
        }));
        assert_eq!(
            proposal_status_at_target(&fixture.root.join("children/a"))
                .unwrap()
                .as_deref(),
            Some("accepted")
        );
        assert!(!fixture
            .octon_dir
            .join("state/evidence/runs/workflows/approval-unattended-workflow-promote-drift/children/a/delegated-promotion-a-promote-proposal.yml")
            .exists());
    }

    #[test]
    fn workflow_promotion_safe_basis_rejects_undeclared_scope_and_protected_zone() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("approval-unattended-workflow-promote-zone", true);
        fixture.write_child_contract_with_safe_workflow_promotion();
        let child_contract =
            load_lifecycle_contract(&fixture.octon_dir, "proposal-packet").unwrap();
        let route = route_by_id(&child_contract.contract, ROUTE_ID_PROMOTE_PROPOSAL).unwrap();
        let program_contract =
            load_lifecycle_contract(&fixture.octon_dir, "proposal-program").unwrap();
        let program = program_contract.contract.program.as_ref().unwrap();

        let mut undeclared = child_state("a", Vec::new());
        undeclared.selected_route = Some(route_plan_state(route.clone()));
        undeclared.gate_status.verification = true;
        undeclared.write_scopes = vec!["children/other".to_string()];
        assert!(child_route_delegation_contract_basis(
            &fixture.root,
            program,
            &undeclared,
            ROUTE_ID_PROMOTE_PROPOSAL,
            route,
        )
        .is_none());

        let mut protected = child_state("b", Vec::new());
        protected.target = ".octon/framework/protected-child".to_string();
        protected.write_scopes = vec![".octon/framework/protected-child".to_string()];
        protected.selected_route = Some(route_plan_state(route.clone()));
        protected.gate_status.verification = true;
        assert!(child_route_delegation_contract_basis(
            &fixture.root,
            program,
            &protected,
            ROUTE_ID_PROMOTE_PROPOSAL,
            route,
        )
        .is_none());
    }

    #[test]
    fn program_resume_preserves_checkpointed_unattended_invocation_authority() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("resume-preserves-unattended", true);
        fixture.write_child_contract_with_workflow_promotion_human_boundary();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write(
            "children/a/support/implementation-run.md",
            "verdict: pass\n",
        );
        fixture.write_registry(
            "approval-gated",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("resume-preserves-unattended".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: false,
                max_steps: Some(7),
                timeout_seconds: Some(42),
                max_child_concurrency: Some(2),
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();
        let checkpoint =
            read_program_checkpoint_for_run(&fixture.octon_dir, "resume-preserves-unattended")
                .unwrap()
                .unwrap();
        assert_eq!(checkpoint.invocation_authority, "unattended");
        assert_eq!(checkpoint.timeout_seconds, Some(42));
        assert_eq!(checkpoint.max_child_concurrency, Some(2));

        let resumed = resume_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "resume-preserves-unattended",
        )
        .unwrap();

        assert_eq!(resumed.final_verdict, "blocked-human");
        assert!(resumed.child_results.iter().any(|summary| {
            summary.route_id == "promote-proposal" && summary.status == "human-boundary-blocked"
        }));
        assert_eq!(
            proposal_status_at_target(&fixture.root.join("children/a"))
                .unwrap()
                .as_deref(),
            Some("accepted")
        );
        let resumed_checkpoint =
            read_program_checkpoint_for_run(&fixture.octon_dir, "resume-preserves-unattended")
                .unwrap()
                .unwrap();
        assert_eq!(resumed_checkpoint.invocation_authority, "unattended");
        assert_eq!(resumed_checkpoint.timeout_seconds, Some(42));
        assert_eq!(resumed_checkpoint.max_child_concurrency, Some(2));
    }

    #[test]
    fn approval_grant_is_consumed_by_retry_without_unattended_cli_policy() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("approval-consumed", true);
        fixture.write_child_contract_with_human_boundary();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_registry(
            "approval-gated",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let first = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("approval-consumed".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: None,
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();
        assert!(first
            .child_results
            .iter()
            .any(|summary| summary.status == "human-boundary-blocked"));
        assert!(!fixture
            .root
            .join("children/a/support/implementation-run.md")
            .exists());

        approve_program_lifecycle_child_route(
            &fixture.octon_dir,
            "approval-consumed",
            "a",
            "run-implementation",
            "operator approved child implementation",
        )
        .unwrap();
        let retry =
            retry_program_lifecycle_run(&fixture.octon_dir, "approval-consumed", Some("a".into()))
                .unwrap();
        assert!(
            retry
                .child_results
                .iter()
                .any(|summary| summary.route_id == "run-implementation"
                    && summary.status == "completed"),
            "retry child results: {:?}",
            retry.child_results
        );
        assert!(fixture
            .root
            .join("children/a/support/implementation-run.md")
            .is_file());
        assert!(fixture
            .octon_dir
            .join("state/evidence/runs/workflows/approval-consumed/children/a/run-implementation-grant-consumption.yml")
            .is_file());
        assert!(fixture
            .octon_dir
            .join("state/evidence/runs/workflows/approval-consumed/children/a/run-implementation-grant-consumption.yml")
            .is_file());
    }

    #[test]
    fn approval_grant_is_consumed_by_resume_without_unattended_cli_policy() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("approval-resume", true);
        fixture.write_child_contract_with_human_boundary();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_registry(
            "approval-gated",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let first = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("approval-resume".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: None,
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();
        assert!(first
            .child_results
            .iter()
            .any(|summary| summary.status == "human-boundary-blocked"));

        approve_program_lifecycle_child_route(
            &fixture.octon_dir,
            "approval-resume",
            "a",
            "run-implementation",
            "operator approved child implementation",
        )
        .unwrap();
        let resumed =
            resume_program_lifecycle_from_octon_dir(&fixture.octon_dir, "approval-resume").unwrap();

        assert!(resumed.child_results.iter().any(|summary| summary.route_id
            == "run-implementation"
            && summary.status == "completed"));
        assert!(fixture
            .root
            .join("children/a/support/implementation-run.md")
            .is_file());
    }

    #[test]
    fn recovery_approval_blocks_until_program_grant_exists() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("recovery-approval", true);
        fixture.write_child_contract_with_fresh_receipt();
        fixture.write_program_contract_with_recovery_approval();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write(
            "children/a/support/implementation-run.md",
            "verdict: pass\nreviewed_packet_digest: sha256:old\n",
        );
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();
        assert_eq!(plan.runnable_batch, vec!["a".to_string()]);
        assert_ne!(plan.final_verdict, "blocked-human");
        assert!(plan.approval_blockers.is_empty());

        let first = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("recovery-approval".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: None,
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();
        assert!(first
            .child_results
            .iter()
            .any(
                |summary| summary.blocker_class.as_deref() == Some("stale-receipt")
                    && summary.route_id == "run-implementation"
            ));
        assert!(!fixture
            .octon_dir
            .join("state/evidence/runs/workflows/recovery-approval/children/a/run-implementation-grant-consumption.yml")
            .exists());
    }

    #[test]
    fn unattended_recovery_approval_runs_without_human_block() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("recovery-approval-unattended", true);
        fixture.write_child_contract_with_fresh_receipt();
        fixture.write_program_contract_with_recovery_approval();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write(
            "children/a/support/implementation-run.md",
            "verdict: pass\nreviewed_packet_digest: sha256:old\n",
        );
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("recovery-approval-unattended".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: Some(1),
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        assert_ne!(result.final_verdict, "blocked-human");
        assert!(!result
            .child_results
            .iter()
            .any(|summary| summary.status == "human-boundary-blocked"));
        assert!(result.child_results.iter().any(|summary| {
            summary.blocker_class.as_deref() == Some("stale-receipt")
                && summary.route_id == "run-implementation"
        }));
    }

    #[test]
    fn recovery_handler_only_semantics_are_enforced() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("recovery-handler-only-budget", true);
        fixture.write_child_contract_with_fresh_receipt();
        fixture.write_program_contract_with_recovery_handlers_only();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write(
            "children/a/support/implementation-run.md",
            "verdict: pass\nreviewed_packet_digest: sha256:old\n",
        );
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();
        let program = load_lifecycle_contract(&fixture.octon_dir, "proposal-program")
            .unwrap()
            .contract
            .program
            .unwrap();
        assert_eq!(
            recovery_route_id(&program, "stale-receipt").map(String::as_str),
            Some("run-implementation")
        );
        assert_eq!(recovery_attempt_budget(&program, "stale-receipt"), Some(1));
        assert!(!recovery_requires_approval(&program, "stale-receipt"));
        assert!(recovery_replan_after_attempt(&program, "stale-receipt"));
        assert_eq!(plan.runnable_batch, vec!["a".to_string()]);
        assert_ne!(plan.final_verdict, "blocked-human");
        assert!(plan.approval_blockers.is_empty());

        let mut checkpoint = checkpoint_from_plan(
            "recovery-handler-only-budget",
            "proposal-program",
            "parent",
            ExecutorKind::Mock,
            "unattended",
            &BTreeMap::new(),
            &plan,
            &[],
            &plan.final_verdict,
            None,
            0,
            BTreeMap::new(),
            BTreeMap::new(),
            BTreeMap::new(),
            BTreeMap::new(),
            Vec::new(),
        );
        checkpoint
            .recovery_attempts
            .insert("a:stale-receipt".to_string(), 1);
        let budget_plan = plan_program_lifecycle_from_octon_dir_with_checkpoint(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
            Some(&checkpoint),
        )
        .unwrap();
        assert!(budget_plan.runnable_batch.is_empty());
        assert!(budget_plan
            .child_states
            .get("a")
            .unwrap()
            .blockers
            .iter()
            .any(|blocker| blocker.message.contains("recovery budget exhausted")));

        let fixture = ProgramFixture::new("recovery-handler-only-exec", true);
        fixture.write_child_contract_with_fresh_receipt();
        fixture.write_program_contract_with_recovery_handlers_only();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write(
            "children/a/support/implementation-run.md",
            "verdict: pass\nreviewed_packet_digest: sha256:old\n",
        );
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );
        let first = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("recovery-handler-only-exec".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: None,
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();
        assert!(first.child_results.iter().any(|summary| {
            summary.blocker_class.as_deref() == Some("stale-receipt")
                && summary.route_id == "run-implementation"
                && summary.status == "blocked"
                && summary
                    .error_message
                    .as_deref()
                    .unwrap_or_default()
                    .contains("did not change")
        }));
        assert!(!fixture
            .octon_dir
            .join("state/evidence/runs/workflows/recovery-handler-only-exec/children/a/run-implementation-grant-consumption.yml")
            .exists());
        let events = read_program_events(
            &fixture
                .octon_dir
                .join("state/control/execution/runs/recovery-handler-only-exec"),
        )
        .unwrap();
        assert!(events
            .iter()
            .any(|event| event.event_type == "child-route-no-progress"));
    }

    #[test]
    fn arbitrary_recoverable_blocker_with_route_is_runnable() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("recoverable-blocker-route", true);
        fixture.write_program_contract_with_recovery_recipes();
        let program = load_lifecycle_contract(&fixture.octon_dir, "proposal-program")
            .unwrap()
            .contract
            .program
            .unwrap();
        let blocker = ProgramBlocker {
            blocker_class: "executor-failed".to_string(),
            message: "retryable executor failure".to_string(),
            recovery_route: Some("run-implementation".to_string()),
        };

        assert!(blocker_allows_child_route(&program, &blocker));
    }

    #[test]
    fn unsafe_blocker_without_safe_repair_is_not_runnable() {
        let program = test_program_spec();
        let blocker = ProgramBlocker {
            blocker_class: "unsupported-mode-authority".to_string(),
            message: "unsafe route cannot continue as-is".to_string(),
            recovery_route: Some("run-implementation".to_string()),
        };

        assert!(!blocker_allows_child_route(&program, &blocker));
        let mut children = BTreeMap::new();
        children.insert("a".to_string(), child_state("a", vec![blocker]));
        let (_state, verdict) = aggregate_program_state(&program, None, &children, &[], &[], &[]);
        assert_eq!(verdict, "blocked-unsafe");
    }

    #[test]
    fn safe_agent_repair_route_can_run_for_unsafe_blocker() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("unsafe-agent-repair", true);
        fixture.write_child_contract();
        fixture.write_program_contract_with_safe_unsafe_repair();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );
        let mut plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();
        plan.child_states
            .get_mut("a")
            .unwrap()
            .blockers
            .push(ProgramBlocker {
                blocker_class: "unsupported-mode-authority".to_string(),
                message: "unsafe route cannot continue as-is; repair route is bounded".to_string(),
                recovery_route: None,
            });
        let program = load_lifecycle_contract(&fixture.octon_dir, "proposal-program")
            .unwrap()
            .contract
            .program
            .unwrap();
        assert!(blocker_has_safe_agent_repair(
            &program,
            plan.child_states.get("a").unwrap().blockers.last().unwrap()
        ));
        let (aggregate_state, verdict) = aggregate_program_state(
            &program,
            None,
            &plan.child_states,
            &[],
            &[],
            &["a".to_string()],
        );
        assert_eq!(aggregate_state, "planned");
        assert_eq!(verdict, "planned");

        let control_root = fixture
            .octon_dir
            .join("state/control/execution/runs/unsafe-agent-repair");
        let evidence_root = fixture
            .octon_dir
            .join("state/evidence/runs/workflows/unsafe-agent-repair");
        fs::create_dir_all(&control_root).unwrap();
        fs::create_dir_all(&evidence_root).unwrap();
        let (jobs, preflight_summaries) = build_child_execution_jobs(
            &fixture.octon_dir,
            &fixture.root,
            "unsafe-agent-repair",
            &BTreeMap::new(),
            &RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("unsafe-agent-repair".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: None,
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
            &plan,
            &evidence_root,
            &control_root,
            None,
            None,
        )
        .unwrap();
        assert!(preflight_summaries.is_empty());
        assert_eq!(jobs.len(), 1);
        assert!(jobs[0].unsafe_repair.is_some());
        let summaries = execute_child_jobs(
            &fixture.root,
            "unsafe-agent-repair",
            &control_root,
            &evidence_root,
            jobs,
            1,
            None,
        )
        .unwrap();
        assert_eq!(summaries[0].status, "completed");
        assert_eq!(
            summaries[0].blocker_class.as_deref(),
            Some("unsupported-mode-authority")
        );
        finalize_child_unsafe_repair_evidence(&evidence_root, &summaries).unwrap();
        let evidence =
            fs::read_to_string(evidence_root.join("children/a/unsafe-repair-decision.yml"))
                .unwrap();
        assert!(evidence.contains("unsafe_condition: unsafe route cannot continue as-is"));
        assert!(evidence.contains("selected_repair_route: run-implementation"));
        assert!(evidence.contains("agent_authority_basis: recovery recipe unsupported-mode-authority idempotency_class=idempotent"));
        assert!(evidence.contains("post_attempt_validation_status: passed"));
        assert!(evidence.contains("execution_can_resume: true"));
    }

    #[test]
    fn program_unsafe_blocker_uses_safe_governed_program_repair_route() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("program-unsafe-repair", true);
        fixture.write_program_contract_with_safe_program_unsafe_repair(true);
        let loaded = load_lifecycle_contract(&fixture.octon_dir, "proposal-program").unwrap();
        let program = loaded.contract.program.as_ref().unwrap();
        let blocker = ProgramBlocker {
            blocker_class: "unsupported-mode-authority".to_string(),
            message: "program route cannot continue as-is".to_string(),
            recovery_route: None,
        };

        let blockers = vec![blocker.clone()];
        let selection =
            selected_program_repair_blocker_with_validation(&loaded.contract, program, &blockers)
                .selection
                .expect("safe program repair route should be selected");

        assert_eq!(
            selection.route.route_id,
            "generate-program-implementation-prompt"
        );
        let basis = selection
            .validation
            .delegation_contract_basis
            .expect("safe program repair basis should be retained");
        assert!(basis.contains("idempotency_class=idempotent"));
        assert!(program_blocker_has_safe_agent_repair(
            &loaded.contract,
            program,
            &blocker
        ));
        let (_state, verdict) = aggregate_program_state(
            program,
            Some(&loaded.contract),
            &BTreeMap::new(),
            &[blocker],
            &[],
            &[],
        );
        assert_eq!(verdict, "blocked-recoverable");
    }

    #[test]
    fn program_unsafe_blocker_without_safe_basis_fails_closed() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("program-unsafe-no-safe-repair", true);
        fixture.write_program_contract_with_safe_program_unsafe_repair(false);
        let loaded = load_lifecycle_contract(&fixture.octon_dir, "proposal-program").unwrap();
        let program = loaded.contract.program.as_ref().unwrap();
        let blocker = ProgramBlocker {
            blocker_class: "unsupported-mode-authority".to_string(),
            message: "program route cannot continue as-is".to_string(),
            recovery_route: None,
        };

        let blockers = vec![blocker.clone()];
        assert!(selected_program_repair_blocker_with_validation(
            &loaded.contract,
            program,
            &blockers
        )
        .selection
        .is_none());
        let (_state, verdict) = aggregate_program_state(
            program,
            Some(&loaded.contract),
            &BTreeMap::new(),
            &[blocker],
            &[],
            &[],
        );
        assert_eq!(verdict, "blocked-unsafe");
    }

    #[test]
    fn program_unsafe_repair_recipe_validation_rejects_invalid_metadata() {
        let _guard = crate::acquire_kernel_test_lock();
        for (name, idempotency, post_validation, preconditions, declare_route, expected) in [
            (
                "program-unsafe-bad-precondition",
                "idempotent",
                "post_attempt_validation: [\"replan-live-state\"]",
                "preconditions: [\"unsupported-precondition\"]",
                true,
                "unsupported program recovery recipe precondition",
            ),
            (
                "program-unsafe-empty-post-validation",
                "idempotent",
                "post_attempt_validation: []",
                "",
                true,
                "must declare post_attempt_validation",
            ),
            (
                "program-unsafe-non-idempotent",
                "non-idempotent",
                "post_attempt_validation: [\"replan-live-state\"]",
                "",
                true,
                "not executable",
            ),
            (
                "program-unsafe-unsafe-idempotency",
                "unsafe",
                "post_attempt_validation: [\"replan-live-state\"]",
                "",
                true,
                "not executable",
            ),
            (
                "program-unsafe-non-recoverable-idempotency",
                "non-recoverable",
                "post_attempt_validation: [\"replan-live-state\"]",
                "",
                true,
                "not executable",
            ),
            (
                "program-unsafe-missing-route",
                "idempotent",
                "post_attempt_validation: [\"replan-live-state\"]",
                "",
                false,
                "missing from program lifecycle contract",
            ),
        ] {
            let fixture = ProgramFixture::new(name, true);
            fixture.write_program_contract_with_program_unsafe_repair_recipe(
                idempotency,
                post_validation,
                preconditions,
                declare_route,
            );
            let loaded = load_lifecycle_contract(&fixture.octon_dir, "proposal-program").unwrap();
            let program = loaded.contract.program.as_ref().unwrap();
            let blockers = vec![ProgramBlocker {
                blocker_class: "unsupported-mode-authority".to_string(),
                message: "program route cannot continue as-is".to_string(),
                recovery_route: None,
            }];

            let selection = selected_program_repair_blocker_with_validation(
                &loaded.contract,
                program,
                &blockers,
            );

            assert!(selection.selection.is_none(), "{name}");
            let validation = selection.validation.expect("validation failure evidence");
            assert_eq!(validation.status.as_deref(), Some("failed"), "{name}");
            assert!(
                validation
                    .failures
                    .iter()
                    .any(|failure| failure.contains(expected)),
                "{name}: {:?}",
                validation.failures
            );
        }
    }

    #[test]
    fn program_repair_post_attempt_validation_controls_parent_resume_evidence() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("program-parent-post-validation", true);
        fixture.write_program_contract_with_program_unsafe_repair_recipe(
            "idempotent",
            "post_attempt_validation: [\"replan-live-state\", \"blocker-cleared\"]",
            "",
            true,
        );
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );
        let loaded = load_lifecycle_contract(&fixture.octon_dir, "proposal-program").unwrap();
        let program = loaded.contract.program.as_ref().unwrap();
        let mut before_plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();
        before_plan.program_recovery_recipe_blocker_class =
            Some("unsupported-mode-authority".to_string());
        let mut blocked_after_plan = before_plan.clone();
        blocked_after_plan.program_blockers.push(ProgramBlocker {
            blocker_class: "unsupported-mode-authority".to_string(),
            message: "unsafe blocker remains".to_string(),
            recovery_route: None,
        });
        let route_result = LifecycleRouteExecutionResult {
            schema_version: "octon-lifecycle-route-execution-result-v1".to_string(),
            run_id: "program-parent-post-validation".to_string(),
            route_id: "generate-program-implementation-prompt".to_string(),
            executor_used: "mock".to_string(),
            status: "completed".to_string(),
            started_at: "now".to_string(),
            ended_at: "now".to_string(),
            manifest_status_before: None,
            manifest_status_after: None,
            receipts_observed: Vec::new(),
            evidence_paths: Vec::new(),
            stdout_path: None,
            stderr_path: None,
            prompt_packet_path: None,
            retryable: false,
            next_action: "replan".to_string(),
            error_class: None,
            error_message: None,
        };
        let control_root = fixture
            .octon_dir
            .join("state/control/execution/runs/program-parent-post-validation");
        let evidence_root = fixture
            .octon_dir
            .join("state/evidence/runs/workflows/program-parent-post-validation");
        fs::create_dir_all(evidence_root.join("parent")).unwrap();
        let evidence = ProgramUnsafeRepairEvidence {
            schema_version: "octon-program-lifecycle-unsafe-repair-v2".to_string(),
            program_run_id: "program-parent-post-validation".to_string(),
            repair_scope: "program".to_string(),
            blocker_scope: "program".to_string(),
            child_id: "program".to_string(),
            unsafe_condition: "unsafe blocker remains".to_string(),
            original_route_blocked_reason: "program route cannot continue as-is".to_string(),
            selected_repair_route: "generate-program-implementation-prompt".to_string(),
            agent_authority_basis:
                "recovery recipe unsupported-mode-authority idempotency_class=idempotent"
                    .to_string(),
            files_artifacts_changed: Vec::new(),
            before_validation: "planned".to_string(),
            after_validation: "pending".to_string(),
            safe_continuation_available: true,
            route_execution_status: "pending".to_string(),
            recipe_validation_status: "passed".to_string(),
            recipe_validation_failures: Vec::new(),
            post_attempt_validations_declared: vec![
                "replan-live-state".to_string(),
                "blocker-cleared".to_string(),
            ],
            post_attempt_validation_results: Vec::new(),
            resume_decision_basis: "pending post-attempt validation".to_string(),
            post_attempt_validation_status: "pending".to_string(),
            post_attempt_validation_failures: Vec::new(),
            final_blocker_class: Some("unsupported-mode-authority".to_string()),
            final_execution_can_resume: false,
            execution_can_resume: false,
        };
        write_unsafe_repair_evidence(
            &evidence_root.join("parent"),
            evidence,
            Some(&route_result),
            None,
        )
        .unwrap();

        let failed = enforce_program_recovery_post_attempt_validations(
            program,
            &before_plan,
            &blocked_after_plan,
            &control_root,
            "unsupported-mode-authority",
            &route_result,
            true,
        );
        assert!(!failed.execution_can_resume);
        assert_eq!(failed.status, "failed");
        finalize_parent_unsafe_repair_evidence(&evidence_root, &route_result, &failed).unwrap();
        let failed_evidence =
            fs::read_to_string(evidence_root.join("parent/unsafe-repair-decision.yml")).unwrap();
        assert!(failed_evidence.contains("post_attempt_validation_status: failed"));
        assert!(failed_evidence.contains("blocker-cleared: fail"));
        assert!(failed_evidence.contains("execution_can_resume: false"));

        let passed = enforce_program_recovery_post_attempt_validations(
            program,
            &before_plan,
            &before_plan,
            &control_root,
            "unsupported-mode-authority",
            &route_result,
            true,
        );
        assert!(passed.execution_can_resume);
        assert_eq!(passed.status, "passed");
    }

    #[test]
    fn unsafe_child_result_continues_only_when_safe_work_remains() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("unsafe-child-continuation", true);
        fixture.write_child_contract();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );
        let mut plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();
        let unsafe_result = vec![ProgramChildExecutionSummary {
            child_id: "a".to_string(),
            child_run_id: "unsafe-child-continuation-a".to_string(),
            route_id: "run-implementation".to_string(),
            status: "blocked-unsafe".to_string(),
            attempts: 1,
            retryable: false,
            blocker_class: Some("unsafe-resume".to_string()),
            error_message: Some("unsafe route stopped".to_string()),
            error_class: None,
            evidence_paths: Vec::new(),
            worktree_hygiene_foreign_fingerprint: None,
        }];

        plan.runnable_batch = vec!["b".to_string()];
        assert_eq!(
            final_verdict_after_child_execution(&plan, &unsafe_result),
            "blocked-recoverable"
        );
        assert!(
            unsafe_result_summaries_for_children(&plan, &unsafe_result)[0]
                .safe_continuation_available
        );

        plan.runnable_batch.clear();
        plan.safe_repair_candidates.clear();
        plan.program_route = None;
        assert_eq!(
            final_verdict_after_child_execution(&plan, &unsafe_result),
            "blocked-unsafe"
        );
        assert!(
            !unsafe_result_summaries_for_children(&plan, &unsafe_result)[0]
                .safe_continuation_available
        );
    }

    #[test]
    fn unsafe_repair_evidence_finalizes_after_validation_result() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("unsafe-repair-finalization", true);
        let evidence_root = fixture
            .octon_dir
            .join("state/evidence/runs/workflows/unsafe-repair-finalization/children/a");
        fs::create_dir_all(&evidence_root).unwrap();
        let evidence = ProgramUnsafeRepairEvidence {
            schema_version: "octon-program-lifecycle-unsafe-repair-v2".to_string(),
            program_run_id: "unsafe-repair-finalization".to_string(),
            repair_scope: "child".to_string(),
            blocker_scope: "child".to_string(),
            child_id: "a".to_string(),
            unsafe_condition: "unsafe route stopped".to_string(),
            original_route_blocked_reason: "current route cannot continue as-is".to_string(),
            selected_repair_route: "run-implementation".to_string(),
            agent_authority_basis: "recovery recipe idempotency_class=idempotent".to_string(),
            files_artifacts_changed: Vec::new(),
            before_validation: "planned".to_string(),
            after_validation: "pending".to_string(),
            safe_continuation_available: true,
            route_execution_status: "pending".to_string(),
            recipe_validation_status: "passed".to_string(),
            recipe_validation_failures: Vec::new(),
            post_attempt_validations_declared: vec!["replan-live-state".to_string()],
            post_attempt_validation_results: Vec::new(),
            resume_decision_basis: "pending post-attempt validation".to_string(),
            post_attempt_validation_status: "pending".to_string(),
            post_attempt_validation_failures: Vec::new(),
            final_blocker_class: Some("unsafe-resume".to_string()),
            final_execution_can_resume: false,
            execution_can_resume: false,
        };
        let route_result = LifecycleRouteExecutionResult {
            schema_version: "octon-lifecycle-route-execution-result-v1".to_string(),
            run_id: "unsafe-repair-finalization-a".to_string(),
            route_id: "run-implementation".to_string(),
            executor_used: "mock".to_string(),
            status: "completed".to_string(),
            started_at: "now".to_string(),
            ended_at: "now".to_string(),
            manifest_status_before: None,
            manifest_status_after: None,
            receipts_observed: Vec::new(),
            evidence_paths: Vec::new(),
            stdout_path: None,
            stderr_path: None,
            prompt_packet_path: None,
            retryable: false,
            next_action: "replan".to_string(),
            error_class: None,
            error_message: None,
        };
        write_unsafe_repair_evidence(&evidence_root, evidence, Some(&route_result), None).unwrap();
        let failed_summary = ProgramChildExecutionSummary {
            child_id: "a".to_string(),
            child_run_id: "unsafe-repair-finalization-a".to_string(),
            route_id: "run-implementation".to_string(),
            status: "failed".to_string(),
            attempts: 1,
            retryable: true,
            blocker_class: Some("unsafe-resume".to_string()),
            error_message: Some("post validation failed".to_string()),
            error_class: None,
            evidence_paths: Vec::new(),
            worktree_hygiene_foreign_fingerprint: None,
        };

        finalize_unsafe_repair_evidence(&evidence_root, &failed_summary).unwrap();

        let evidence_text =
            fs::read_to_string(evidence_root.join("unsafe-repair-decision.yml")).unwrap();
        assert!(evidence_text.contains("route_execution_status: completed"));
        assert!(evidence_text.contains("post_attempt_validation_status: failed"));
        assert!(evidence_text.contains("final_execution_can_resume: false"));
        assert!(evidence_text.contains("execution_can_resume: false"));
    }

    #[test]
    fn human_required_blocker_is_not_agent_repairable_without_local_evidence() {
        let program = test_program_spec();
        let blocker = ProgramBlocker {
            blocker_class: "artifact-ownership-unclear".to_string(),
            message: "ownership cannot be resolved from local evidence".to_string(),
            recovery_route: Some("run-implementation".to_string()),
        };

        assert_eq!(
            classify_program_blocker_class(&blocker.blocker_class),
            ProgramBlockerDisposition::Human
        );
        assert!(!blocker_allows_child_route(&program, &blocker));
    }

    #[test]
    fn program_atomic_requires_v2_registry() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("atomic", true);
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_registry(
            "program-atomic",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert_eq!(plan.final_verdict, "blocked-unsafe");
        assert!(plan.runnable_batch.is_empty());
        assert!(plan.program_blockers.iter().any(|blocker| {
            blocker.blocker_class == "validation-failed"
                && blocker
                    .message
                    .contains("program-atomic requires octon-proposal-program-child-registry-v2")
        }));
    }

    #[test]
    fn program_atomic_success_records_stage_commit_events() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("atomic-success", true);
        fixture.write_child_contract_with_atomic(false, false, true);
        fixture.write_program_contract_with_atomic();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_v2_registry(
            "program-atomic",
            r#"  - child_id: "a"
    path: "children/a"
    dependency_gate: "terminal"
    recovery_profile: "default"
    rollback_posture: "compensating"
    write_scopes: ["framework/a.md"]
"#,
        );
        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();
        assert_eq!(
            plan.runnable_batch,
            vec!["a".to_string()],
            "program blockers: {:?}; child state: {:?}",
            plan.program_blockers,
            plan.child_states.get("a")
        );

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("atomic-success".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: None,
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        assert!(result
            .child_results
            .iter()
            .any(|summary| summary.route_id == "atomic-stage" && summary.status == "completed"));
        assert!(result
            .child_results
            .iter()
            .any(|summary| summary.route_id == "atomic-commit" && summary.status == "completed"));
        assert!(result.latest_event_offset >= 5);
        assert!(fixture
            .octon_dir
            .join("state/control/execution/runs/atomic-success/program-events.ndjson")
            .is_file());
    }

    #[test]
    fn execute_routes_loops_until_required_children_are_terminal() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("execute-loop-terminal", true);
        fixture.write_full_child_contract();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_child("b", "framework/b.md", "accepted");
        fixture.write_registry(
            "sequential",
            r#"  - child_id: "a"
    path: "children/a"
  - child_id: "b"
    path: "children/b"
"#,
        );

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("execute-loop-terminal".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: Some(20),
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        assert_eq!(result.final_verdict, "completed");
        assert_eq!(result.child_results.len(), 12);
        assert_eq!(
            result
                .child_results
                .iter()
                .filter(|summary| summary.child_id == "a")
                .count(),
            6
        );
        assert_eq!(
            result
                .child_results
                .iter()
                .filter(|summary| summary.child_id == "b")
                .count(),
            6
        );
        assert!(fixture
            .root
            .join("children/a/support/proposal-closeout.md")
            .is_file());
        assert!(fixture
            .root
            .join("children/b/support/proposal-closeout.md")
            .is_file());
        assert!(
            fs::read_to_string(fixture.root.join("children/a/proposal.yml"))
                .unwrap()
                .contains("status: archived")
        );
        assert!(
            fs::read_to_string(fixture.root.join("children/b/proposal.yml"))
                .unwrap()
                .contains("status: archived")
        );

        let events = read_program_events(
            &fixture
                .octon_dir
                .join("state/control/execution/runs/execute-loop-terminal"),
        )
        .unwrap();
        assert_eq!(
            events
                .iter()
                .filter(|event| event.event_type == "run-started")
                .count(),
            1
        );
        assert!(
            events
                .iter()
                .filter(|event| event.event_type == "plan-created")
                .count()
                > 1
        );
        let schedule_event = events
            .iter()
            .find(|event| event.event_type == "schedule-created")
            .unwrap();
        assert_eq!(
            schedule_event
                .data
                .get("execution_strategy")
                .map(String::as_str),
            Some("orchestrated-replan-loop")
        );
        assert_eq!(
            schedule_event.data.get("step_index").map(String::as_str),
            Some("0")
        );
        assert_eq!(
            schedule_event.data.get("step_number").map(String::as_str),
            Some("1")
        );
        assert_eq!(
            schedule_event.data.get("step_kind").map(String::as_str),
            Some("child-batch-dispatch")
        );
        let child_start_event = events
            .iter()
            .find(|event| event.event_type == "child-route-started")
            .unwrap();
        assert_eq!(
            child_start_event
                .data
                .get("execution_strategy")
                .map(String::as_str),
            Some("orchestrated-replan-loop")
        );
        assert_eq!(
            child_start_event.data.get("step_kind").map(String::as_str),
            Some("child-batch-dispatch")
        );
        let recovery_log: Vec<ProgramChildExecutionSummary> = serde_yaml::from_slice(
            &fs::read(
                fixture
                    .octon_dir
                    .join("state/evidence/runs/workflows/execute-loop-terminal/recovery-log.yml"),
            )
            .unwrap(),
        )
        .unwrap();
        assert_eq!(recovery_log.len(), result.child_results.len());
        assert_eq!(
            recovery_log
                .iter()
                .map(|summary| (&summary.child_id, &summary.route_id, &summary.status))
                .collect::<Vec<_>>(),
            result
                .child_results
                .iter()
                .map(|summary| (&summary.child_id, &summary.route_id, &summary.status))
                .collect::<Vec<_>>()
        );
    }

    #[test]
    fn execute_routes_max_steps_bounds_child_batch_dispatches() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("execute-loop-max-steps", true);
        fixture.write_full_child_contract();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_registry(
            "sequential",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("execute-loop-max-steps".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: Some(2),
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        assert_eq!(result.final_verdict, "step-budget-exhausted-continuable");
        assert_eq!(
            result
                .child_results
                .iter()
                .map(|summary| summary.route_id.as_str())
                .collect::<Vec<_>>(),
            vec![
                "generate-packet-implementation-prompt",
                "run-packet-implementation"
            ]
        );
        assert!(fixture
            .root
            .join("children/a/support/implementation-run.md")
            .is_file());
        assert!(!fixture
            .root
            .join("children/a/support/implementation-conformance-review.md")
            .exists());
        assert!(
            fs::read_to_string(fixture.root.join("children/a/proposal.yml"))
                .unwrap()
                .contains("status: accepted")
        );

        let events = read_program_events(
            &fixture
                .octon_dir
                .join("state/control/execution/runs/execute-loop-max-steps"),
        )
        .unwrap();
        assert!(events
            .iter()
            .any(|event| event.event_type == "max-steps-exhausted"));
        let checkpoint: ProgramLifecycleCheckpoint = serde_yaml::from_slice(
            &fs::read(
                fixture
                    .octon_dir
                    .join("state/control/execution/runs/execute-loop-max-steps/program-lifecycle-checkpoint.yml"),
            )
            .unwrap(),
        )
        .unwrap();
        assert_eq!(
            checkpoint.final_verdict,
            "step-budget-exhausted-continuable"
        );
        assert_eq!(checkpoint.execution_strategy, "orchestrated-replan-loop");

        let resumed =
            resume_program_lifecycle_from_octon_dir(&fixture.octon_dir, "execute-loop-max-steps")
                .unwrap();
        assert_eq!(resumed.final_verdict, "completed");
        assert!(fixture
            .root
            .join("children/a/support/proposal-closeout.md")
            .is_file());
        let resumed_events = read_program_events(
            &fixture
                .octon_dir
                .join("state/control/execution/runs/execute-loop-max-steps"),
        )
        .unwrap();
        assert_eq!(
            resumed_events
                .iter()
                .filter(|event| event.event_type == "run-started")
                .count(),
            1
        );
    }

    #[test]
    fn max_child_concurrency_limits_workers_without_charging_extra_steps() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("execute-loop-child-concurrency", true);
        fixture.write_full_child_contract();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_child("b", "framework/b.md", "accepted");
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
  - child_id: "b"
    path: "children/b"
"#,
        );

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("execute-loop-child-concurrency".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: Some(1),
                timeout_seconds: None,
                max_child_concurrency: Some(1),
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        assert_eq!(result.final_verdict, "step-budget-exhausted-continuable");
        assert_eq!(result.child_results.len(), 2);
        assert!(result.child_results.iter().all(|summary| {
            summary.route_id == "generate-packet-implementation-prompt"
                && summary.status == "completed"
        }));
        assert!(fixture
            .root
            .join("children/a/support/executable-implementation-prompt.md")
            .is_file());
        assert!(fixture
            .root
            .join("children/b/support/executable-implementation-prompt.md")
            .is_file());

        let events = read_program_events(
            &fixture
                .octon_dir
                .join("state/control/execution/runs/execute-loop-child-concurrency"),
        )
        .unwrap();
        let child_events = events
            .iter()
            .filter(|event| {
                matches!(
                    event.event_type.as_str(),
                    "child-route-started" | "child-route-finished"
                )
            })
            .map(|event| {
                (
                    event.event_type.as_str(),
                    event.child_id.as_deref().unwrap_or_default(),
                )
            })
            .collect::<Vec<_>>();
        assert_eq!(
            child_events,
            vec![
                ("child-route-started", "a"),
                ("child-route-finished", "a"),
                ("child-route-started", "b"),
                ("child-route-finished", "b"),
            ],
            "events: {:?}",
            events
                .iter()
                .map(|event| (
                    event.event_index,
                    event.event_type.as_str(),
                    event.child_id.as_deref()
                ))
                .collect::<Vec<_>>()
        );
    }

    #[test]
    fn execute_routes_zero_max_steps_plans_without_dispatching() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("execute-loop-zero-steps", true);
        fixture.write_full_child_contract();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_registry(
            "sequential",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("execute-loop-zero-steps".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: Some(0),
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        assert_eq!(result.final_verdict, "step-budget-exhausted-continuable");
        assert!(result.child_results.is_empty());
        assert!(!fixture
            .root
            .join("children/a/support/executable-implementation-prompt.md")
            .exists());
        assert_eq!(result.route_execution_mode, "none");
        let summary = fs::read_to_string(
            fixture
                .octon_dir
                .join("state/evidence/runs/workflows/execute-loop-zero-steps/summary.md"),
        )
        .unwrap();
        assert!(!summary.contains("program-adapter-executed"));
    }

    #[test]
    fn execute_routes_no_dispatch_does_not_emit_dispatch_events() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("execute-loop-no-dispatch", true);
        fixture.write_full_child_contract();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_registry(
            "sequential",
            r#"  - child_id: "a"
    path: "children/a"
    deferred: true
"#,
        );

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("execute-loop-no-dispatch".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: Some(20),
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        assert_eq!(result.final_verdict, "planned");
        assert_eq!(result.route_execution_mode, "none");
        assert!(result.child_results.is_empty());
        let events = read_program_events(
            &fixture
                .octon_dir
                .join("state/control/execution/runs/execute-loop-no-dispatch"),
        )
        .unwrap();
        assert!(!events.iter().any(|event| matches!(
            event.event_type.as_str(),
            "schedule-created"
                | "parent-route-started"
                | "parent-route-finished"
                | "child-route-started"
                | "child-route-finished"
        )));
        let plan_event = events
            .iter()
            .find(|event| event.event_type == "plan-created")
            .unwrap();
        assert_eq!(
            plan_event.data.get("step_kind").map(String::as_str),
            Some("no-dispatch")
        );
        let recovery_log: Vec<ProgramChildExecutionSummary> =
            serde_yaml::from_slice(
                &fs::read(fixture.octon_dir.join(
                    "state/evidence/runs/workflows/execute-loop-no-dispatch/recovery-log.yml",
                ))
                .unwrap(),
            )
            .unwrap();
        assert!(recovery_log.is_empty());
    }

    #[test]
    fn preexisting_program_cancellation_token_blocks_first_dispatch() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("preexisting-cancel-token", true);
        fixture.write_full_child_contract();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_registry(
            "sequential",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );
        let control_root = fixture
            .octon_dir
            .join("state/control/execution/runs/preexisting-cancel-token");
        fs::create_dir_all(&control_root).unwrap();
        fs::write(
            control_root.join("cancellation.yml"),
            "schema_version: octon-lifecycle-cancellation-v1\n",
        )
        .unwrap();

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("preexisting-cancel-token".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: Some(20),
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        assert_eq!(result.final_verdict, "cancelled");
        assert_eq!(result.terminal_outcome.as_deref(), Some("cancelled"));
        assert!(result.child_results.is_empty());
        let checkpoint: ProgramLifecycleCheckpoint = serde_yaml::from_slice(
            &fs::read(control_root.join("program-lifecycle-checkpoint.yml")).unwrap(),
        )
        .unwrap();
        assert_eq!(checkpoint.final_verdict, "cancelled");
        let events = fs::read_to_string(control_root.join("program-events.ndjson")).unwrap();
        assert!(events.contains("\"event_type\":\"cancelled\""));
        assert!(!events.contains("\"event_type\":\"child-route-started\""));
    }

    #[test]
    fn program_cancel_after_plan_checkpoint_records_stale_locks() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("cancel-after-plan-checkpoint", true);
        fixture.write_full_child_contract();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_registry(
            "sequential",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let planned = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("cancel-after-plan-checkpoint".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: false,
                max_steps: Some(20),
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();
        assert_eq!(planned.final_verdict, "planned");
        let control_root = fixture
            .octon_dir
            .join("state/control/execution/runs/cancel-after-plan-checkpoint");
        let lock_path = control_root.join("locks/a.lock");
        fs::create_dir_all(lock_path.parent().unwrap()).unwrap();
        fs::write(&lock_path, "child_id: a\n").unwrap();

        let cancelled = cancel_program_lifecycle_run(
            &fixture.octon_dir,
            "cancel-after-plan-checkpoint",
            "operator stop",
        )
        .unwrap();

        assert_eq!(cancelled.final_verdict, "cancelled");
        assert!(
            lock_path.exists(),
            "cancel must preserve existing stale lock"
        );
        let evidence = fs::read_to_string(fixture.octon_dir.join(
            "state/evidence/runs/workflows/cancel-after-plan-checkpoint/program-cancelled.yml",
        ))
        .unwrap();
        assert!(evidence.contains("stale_child_locks"));
        assert!(evidence.contains("locks/a.lock"));
        let events = fs::read_to_string(control_root.join("program-events.ndjson")).unwrap();
        assert!(events.contains("\"event_type\":\"child-lock-stale\""));
        let checkpoint: ProgramLifecycleCheckpoint = serde_yaml::from_slice(
            &fs::read(control_root.join("program-lifecycle-checkpoint.yml")).unwrap(),
        )
        .unwrap();
        assert_eq!(checkpoint.final_verdict, "cancelled");
        assert_eq!(checkpoint.terminal_outcome.as_deref(), Some("cancelled"));
        assert!(checkpoint.cancellation_evidence_path.is_some());
    }

    #[test]
    fn non_execute_program_lifecycle_only_writes_route_handoff() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("execute-loop-handoff", true);
        fixture.write_full_child_contract();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_registry(
            "sequential",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("execute-loop-handoff".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: false,
                max_steps: Some(20),
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        assert_eq!(result.route_execution_mode, "program-route-handoff");
        assert_eq!(result.selected_children, vec!["a".to_string()]);
        assert!(result.child_results.is_empty());
        assert!(!fixture
            .root
            .join("children/a/support/executable-implementation-prompt.md")
            .exists());
        let events = read_program_events(
            &fixture
                .octon_dir
                .join("state/control/execution/runs/execute-loop-handoff"),
        )
        .unwrap();
        assert!(!events
            .iter()
            .any(|event| event.event_type == "child-route-started"));
    }

    #[test]
    fn program_operator_controls_use_checkpointed_event_log() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("operator-control", true);
        fixture.write_child_contract_with_human_boundary();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );
        let run = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("operator-control".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: false,
                max_steps: None,
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();
        assert!(run.latest_event_offset > 0);

        let inspect =
            inspect_program_lifecycle_run(&fixture.octon_dir, "operator-control").unwrap();
        assert_eq!(inspect.run_id, "operator-control");
        assert!(!inspect.recent_events.is_empty());

        let explanation =
            explain_program_lifecycle_blockers(&fixture.octon_dir, "operator-control").unwrap();
        assert_eq!(explanation.run_id, "operator-control");
        assert_eq!(
            explanation.retry_instruction,
            "octon lifecycle program retry --run-id operator-control"
        );

        let approval = approve_program_lifecycle_child_route(
            &fixture.octon_dir,
            "operator-control",
            "a",
            "run-implementation",
            "operator approved test route",
        )
        .unwrap();
        assert_eq!(approval.action, "approve");
        assert!(fixture.root.join(&approval.evidence_path).is_file());

        let retry =
            retry_program_lifecycle_run(&fixture.octon_dir, "operator-control", Some("a".into()))
                .unwrap();
        assert_eq!(retry.run_id, "operator-control");

        let cancelled = cancel_program_lifecycle_run(
            &fixture.octon_dir,
            "operator-control",
            "operator cancelled test run",
        )
        .unwrap();
        assert_eq!(cancelled.final_verdict, "cancelled");
        assert!(fixture
            .octon_dir
            .join("state/control/execution/runs/operator-control/cancellation.yml")
            .is_file());
        let retry_after_cancel =
            retry_program_lifecycle_run(&fixture.octon_dir, "operator-control", Some("a".into()))
                .unwrap();
        assert_eq!(retry_after_cancel.final_verdict, "cancelled");
        assert_eq!(retry_after_cancel.route_execution_mode, "none");
        assert!(retry_after_cancel.child_results.is_empty());
        let events = read_program_events(
            &fixture
                .octon_dir
                .join("state/control/execution/runs/operator-control"),
        )
        .unwrap();
        assert!(events.iter().any(|event| event.event_type == "cancelled"));
    }

    #[test]
    fn replay_verify_and_status_use_v2_event_hash_chain() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("replay-status", true);
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );
        run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("replay-status".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: false,
                max_steps: None,
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        let replay =
            replay_program_lifecycle_run(&fixture.octon_dir, "replay-status", true).unwrap();
        assert!(replay.verified);
        assert_eq!(replay.verdict, "replay-verified");
        assert!(replay.latest_event_sha256.is_some());

        let status = status_program_lifecycle_run(&fixture.octon_dir, "replay-status").unwrap();
        assert_eq!(status.runnable_batch, vec!["a".to_string()]);
        assert_eq!(
            status.authority_notice,
            "generated read model only; checkpoint, event log, child manifests, and child receipts remain authoritative for their own domains"
        );
        assert_eq!(status.dag.get("a").unwrap(), &Vec::<String>::new());
    }

    #[test]
    fn replay_verify_fails_closed_on_hash_break() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("replay-break", true);
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );
        run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("replay-break".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: false,
                max_steps: None,
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();
        let event_log = fixture
            .octon_dir
            .join("state/control/execution/runs/replay-break/program-events.ndjson");
        let tampered = fs::read_to_string(&event_log)
            .unwrap()
            .replace("plan-created", "plan-mutated");
        fs::write(&event_log, tampered).unwrap();

        let error =
            replay_program_lifecycle_run(&fixture.octon_dir, "replay-break", true).unwrap_err();
        assert!(error.to_string().contains("hash-chain break"));
    }

    #[test]
    fn replay_verify_fails_closed_on_offsets_checkpoint_registry_and_unsafe_resume() {
        let _guard = crate::acquire_kernel_test_lock();
        for (name, mutation, expected) in [
            ("duplicate-offset", "duplicate", "duplicate event index"),
            (
                "missing-offset",
                "missing",
                "missing or out-of-order event offset",
            ),
            (
                "checkpoint-divergence",
                "checkpoint",
                "checkpoint/event divergence",
            ),
            ("registry-drift", "registry", "registry digest drift"),
            ("unsafe-resume", "unsafe", "unsafe resume"),
        ] {
            let fixture = ProgramFixture::new(name, true);
            fixture.write_child("a", "framework/a.md", "accepted");
            fixture.write_registry(
                "parallel-independent",
                r#"  - child_id: "a"
    path: "children/a"
"#,
            );
            run_program_lifecycle_from_octon_dir(
                &fixture.octon_dir,
                RunLifecycleOptions {
                    lifecycle_id: "proposal-program".to_string(),
                    target: PathBuf::from("parent"),
                    run_id: Some(name.to_string()),
                    executor: ExecutorKind::Mock,
                    max_iterations: None,
                    execute_routes: false,
                    max_steps: None,
                    timeout_seconds: None,
                    max_child_concurrency: None,
                    invocation_authority: "unattended".to_string(),
                    run_inputs: BTreeMap::new(),
                    program_child_filter: None,
                },
            )
            .unwrap();
            match mutation {
                "duplicate" | "missing" => {
                    let event_log = fixture.octon_dir.join(format!(
                        "state/control/execution/runs/{name}/program-events.ndjson"
                    ));
                    let mut lines = fs::read_to_string(&event_log)
                        .unwrap()
                        .lines()
                        .map(str::to_string)
                        .collect::<Vec<_>>();
                    if lines.len() > 1 {
                        let from = if mutation == "duplicate" {
                            "\"event_index\":2"
                        } else {
                            "\"event_index\":2"
                        };
                        let to = if mutation == "duplicate" {
                            "\"event_index\":1"
                        } else {
                            "\"event_index\":3"
                        };
                        lines[1] = lines[1].replace(from, to);
                    }
                    fs::write(&event_log, format!("{}\n", lines.join("\n"))).unwrap();
                }
                "checkpoint" | "unsafe" => {
                    let checkpoint_path = fixture.octon_dir.join(format!(
                        "state/control/execution/runs/{name}/program-lifecycle-checkpoint.yml"
                    ));
                    let mut checkpoint: ProgramLifecycleCheckpoint =
                        serde_yaml::from_slice(&fs::read(&checkpoint_path).unwrap()).unwrap();
                    if mutation == "checkpoint" {
                        checkpoint.latest_event_index = 999;
                    } else {
                        checkpoint.final_verdict = "blocked-unsafe".to_string();
                    }
                    fs::write(
                        &checkpoint_path,
                        serde_yaml::to_string(&checkpoint).unwrap(),
                    )
                    .unwrap();
                }
                "registry" => {
                    fixture.write(
                        "parent/resources/child-packet-index.yml",
                        r#"schema_version: "octon-proposal-program-child-registry-v1"
execution_mode: "parallel-independent"
default_child_lifecycle_id: "proposal-packet"
children:
  - child_id: "a"
    path: "children/a"
    phase_id: "changed"
"#,
                    );
                }
                _ => unreachable!(),
            }
            let error = replay_program_lifecycle_run(&fixture.octon_dir, name, true).unwrap_err();
            assert!(
                error.to_string().contains(expected),
                "{} did not contain {}",
                error,
                expected
            );
        }
    }

    #[test]
    fn legacy_event_log_remains_inspectable_with_warning() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("legacy-replay", true);
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );
        run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("legacy-replay".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: false,
                max_steps: None,
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();
        let event_log = fixture
            .octon_dir
            .join("state/control/execution/runs/legacy-replay/program-events.ndjson");
        fs::write(
            event_log,
            r#"{"schema_version":"octon-program-lifecycle-event-v1","run_id":"legacy-replay","event_index":1,"event_type":"run-started","recorded_at":"2026-01-01T00:00:00Z","message":"legacy"}
"#,
        )
        .unwrap();

        let replay =
            replay_program_lifecycle_run(&fixture.octon_dir, "legacy-replay", false).unwrap();
        assert!(replay.legacy_event_log);
        assert_eq!(replay.verdict, "legacy-event-log");
        assert!(replay
            .warnings
            .iter()
            .any(|warning| warning.contains("legacy-event-log")));
    }

    #[test]
    fn mutation_propose_apply_and_idempotent_rerun_update_parent_registry_only() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("mutation", true);
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );
        run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("mutation".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: false,
                max_steps: None,
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();
        let digest =
            file_digest(&fixture.root.join("parent/resources/child-packet-index.yml")).unwrap();
        fixture.write(
            "mutation.yml",
            &format!(
                r#"
schema_version: "octon-proposal-program-mutation-v1"
expected_registry_digest: "{digest}"
action: "add-child"
child_id: "b"
path: "children/b"
dependencies: ["a"]
phase_id: "phase-2"
rollback_posture: "forward-only"
write_scopes: ["framework/b.md"]
rationale: "add follow-on packet candidate"
"#
            ),
        );

        let proposal =
            propose_program_mutation(&fixture.octon_dir, "mutation", Path::new("mutation.yml"))
                .unwrap();
        assert!(!proposal.applied);
        assert!(fixture.root.join(&proposal.evidence_path).is_file());

        let applied = apply_program_mutation(
            &fixture.octon_dir,
            "mutation",
            Path::new("mutation.yml"),
            "operator accepted mutation",
        )
        .unwrap();
        assert!(applied.applied);
        let registry =
            fs::read_to_string(fixture.root.join("parent/resources/child-packet-index.yml"))
                .unwrap();
        assert!(registry.contains("child_id: b"));
        assert!(registry.contains("dependencies:"));

        let idempotent = apply_program_mutation(
            &fixture.octon_dir,
            "mutation",
            Path::new("mutation.yml"),
            "operator accepted mutation",
        )
        .unwrap();
        assert!(idempotent.idempotent);
    }

    #[test]
    fn every_supported_mutation_action_is_validated_and_applied() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("mutation-actions", true);
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_child("b", "framework/b.md", "accepted");
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
  - child_id: "b"
    path: "children/b"
"#,
        );
        run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("mutation-actions".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: false,
                max_steps: None,
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        let registry_path = fixture.root.join("parent/resources/child-packet-index.yml");
        let actions = [
            (
                "defer-child",
                "a",
                "deferred: true\nrationale: \"defer child a\"\n",
            ),
            (
                "rephase-child",
                "b",
                "phase_id: \"phase-2\"\ngroup_id: \"group-2\"\nrationale: \"rephase child b\"\n",
            ),
            (
                "update-dependencies",
                "b",
                "dependencies: [\"a\"]\nrationale: \"gate b on a\"\n",
            ),
            (
                "supersede-child",
                "a",
                "supersession_evidence: \"parent/resources/a-superseded.md\"\nrollback_posture: \"superseded\"\nrationale: \"supersede child a\"\n",
            ),
            (
                "replace-child",
                "b",
                "replacement_child_id: \"c\"\npath: \"children/c\"\ndependencies: [\"a\"]\ndependency_gate: \"terminal\"\nrecovery_profile: \"default\"\nsupersession_evidence: \"parent/resources/b-replaced.md\"\nrollback_posture: \"forward-only\"\nwrite_scopes: [\"framework/c.md\"]\nrationale: \"replace child b\"\n",
            ),
        ];
        for (action, child_id, body) in actions {
            let digest = file_digest(&registry_path).unwrap();
            fixture.write(
                "mutation-action.yml",
                &format!(
                    "schema_version: \"octon-proposal-program-mutation-v1\"\nexpected_registry_digest: \"{digest}\"\naction: \"{action}\"\nchild_id: \"{child_id}\"\n{body}"
                ),
            );
            let applied = apply_program_mutation(
                &fixture.octon_dir,
                "mutation-actions",
                Path::new("mutation-action.yml"),
                "operator accepted mutation action",
            )
            .unwrap();
            assert!(applied.applied, "{action} should apply");
        }
        let registry = fs::read_to_string(registry_path).unwrap();
        assert!(registry.contains("child_id: c"));
        assert!(registry.contains("supersession_evidence"));
        assert!(registry.contains("dependency_gate: terminal"));

        let digest =
            file_digest(&fixture.root.join("parent/resources/child-packet-index.yml")).unwrap();
        fixture.write(
            "bad-mutation.yml",
            &format!(
                r#"schema_version: "octon-proposal-program-mutation-v1"
expected_registry_digest: "{digest}"
action: "add-child"
child_id: "bad"
path: "parent/bad"
rationale: "attempt parent-authority overlap"
"#
            ),
        );
        let error = apply_program_mutation(
            &fixture.octon_dir,
            "mutation-actions",
            Path::new("bad-mutation.yml"),
            "operator accepted mutation action",
        )
        .unwrap_err();
        assert!(error.to_string().contains("parent program authority"));
    }

    #[test]
    fn scaffold_from_seed_reference_supports_dry_run_and_generated_registry() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("scaffold", true);
        fixture.write(
            "scaffold.yml",
            r#"
schema_version: "octon-proposal-program-scaffold-v1"
program_id: "governed-workflow-runtime-transition"
title: "Governed Workflow Runtime Transition Candidate"
execution_mode: "gated-parallel"
seed_reference_child:
  child_id: "canonical-framing"
  path: ".octon/inputs/exploratory/proposals/architecture/foundational-entry-artifact-canonical-framing-update"
  phase_id: "framing"
  seed_role: "seed-reference"
follow_on_child_candidates:
  - child_id: "runtime-contracts"
    path: ".octon/inputs/exploratory/proposals/architecture/runtime-contracts"
    dependencies: ["canonical-framing"]
    phase_id: "contracts"
rationale: "exercise safe program scaffolding without creating the real transition program"
"#,
        );

        let dry_run = scaffold_program_from_seed(
            &fixture.octon_dir,
            Path::new("program-parent"),
            Path::new("scaffold.yml"),
            true,
        )
        .unwrap();
        assert!(dry_run.dry_run);
        assert!(!fixture.root.join("program-parent/proposal.yml").exists());

        let result = scaffold_program_from_seed(
            &fixture.octon_dir,
            Path::new("program-parent"),
            Path::new("scaffold.yml"),
            false,
        )
        .unwrap();
        assert_eq!(result.seed_reference_child, "canonical-framing");
        let registry = fs::read_to_string(
            fixture
                .root
                .join("program-parent/resources/child-packet-index.yml"),
        )
        .unwrap();
        assert!(registry.contains("octon-proposal-program-child-registry-v2"));
        assert!(registry.contains("seed-reference"));
        assert!(registry.contains("foundational-entry-artifact-canonical-framing-update"));
    }

    #[test]
    fn scaffold_refuses_to_overwrite_existing_parent_files() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("scaffold-overwrite", true);
        fixture.write(
            "scaffold.yml",
            r#"
schema_version: "octon-proposal-program-scaffold-v1"
title: "Overwrite Guard"
execution_mode: "sequential"
seed_reference_child:
  child_id: "seed"
  path: "children/seed"
rationale: "prove overwrite guard"
"#,
        );
        fixture.write("program-parent/proposal.yml", "status: accepted\n");

        let error = scaffold_program_from_seed(
            &fixture.octon_dir,
            Path::new("program-parent"),
            Path::new("scaffold.yml"),
            false,
        )
        .unwrap_err();

        assert!(error.to_string().contains("refuses to overwrite"));
    }

    #[test]
    fn aggregate_closeout_receipt_requires_child_owned_receipts() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("closeout", true);
        fixture.write_program_contract_with_atomic();
        fixture.write_parent_status("implemented");
        fixture.write_child("a", "framework/a.md", "implemented");
        fixture.write_v2_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let error = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("closeout-missing".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: false,
                max_steps: None,
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap_err();
        assert!(error.to_string().contains("missing receipt"));

        fixture.write(
            "children/a/support/implementation-run.md",
            "receipt: child-owned\n",
        );
        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("closeout-pass".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: false,
                max_steps: None,
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();
        assert_eq!(result.final_verdict, "completed");
        assert!(fixture
            .octon_dir
            .join("state/evidence/runs/workflows/closeout-pass/aggregate-closeout-receipt.yml")
            .is_file());
    }

    #[test]
    fn aggregate_closeout_accepts_archived_and_rejected_required_children() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("closeout-required-states", true);
        fixture.write_child_contract_with_closeout_outcomes();
        fixture.write_program_contract_with_canonical_closeout_policy();
        fixture.write_parent_status("archived");
        fixture.write_child("a", "framework/a.md", "archived");
        fixture.write("children/a/support/decision.md", "decision: archived\n");
        fixture.write_child("b", "framework/b.md", "rejected");
        fixture.write("children/b/support/decision.md", "decision: rejected\n");
        fixture.write_v2_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
  - child_id: "b"
    path: "children/b"
"#,
        );

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("closeout-required-states".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: false,
                max_steps: None,
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        assert_eq!(result.final_verdict, "completed");
        assert!(fixture
            .octon_dir
            .join(
                "state/evidence/runs/workflows/closeout-required-states/aggregate-closeout-receipt.yml"
            )
            .is_file());
    }

    #[test]
    fn aggregate_closeout_accepts_deferred_and_superseded_children_with_evidence() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("closeout-deferred-states", true);
        fixture.write_child_contract_with_closeout_outcomes();
        fixture.write_program_contract_with_canonical_closeout_policy();
        fixture.write_parent_status("archived");
        fixture.write_child("a", "framework/a.md", "archived");
        fixture.write("children/a/support/decision.md", "decision: archived\n");
        fixture.write_child("b", "framework/b.md", "accepted");
        fixture.write_child("c", "framework/c.md", "accepted");
        fixture.write("parent/resources/c-superseded.md", "superseded_by: a\n");
        fixture.write_v2_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
  - child_id: "b"
    path: "children/b"
    deferred: true
    seed_role: "reference"
  - child_id: "c"
    path: "children/c"
    deferred: true
    rollback_posture: "superseded"
    supersession_evidence: "parent/resources/c-superseded.md"
"#,
        );

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("closeout-deferred-states".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: false,
                max_steps: None,
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        assert_eq!(result.final_verdict, "completed");
        assert!(fixture
            .octon_dir
            .join(
                "state/evidence/runs/workflows/closeout-deferred-states/aggregate-closeout-receipt.yml"
            )
            .is_file());
    }

    #[test]
    fn dangling_supersession_evidence_blocks_aggregate_closeout() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("closeout-dangling-evidence", true);
        fixture.write_program_contract_with_atomic();
        fixture.write_parent_status("implemented");
        fixture.write_child("a", "framework/a.md", "implemented");
        fixture.write(
            "children/a/support/implementation-run.md",
            "receipt: child-owned\n",
        );
        fixture.write_child("b", "framework/b.md", "accepted");
        fixture.write_v2_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
  - child_id: "b"
    path: "children/b"
    deferred: true
    rollback_posture: "superseded"
    supersession_evidence: "parent/resources/missing-supersession.md"
"#,
        );

        let error = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("closeout-dangling-evidence".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: false,
                max_steps: None,
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap_err();

        assert!(error.to_string().contains("reference is dangling"));
    }

    #[test]
    fn stale_child_receipt_blocks_aggregate_closeout() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("closeout-stale", true);
        fixture.write_child_contract_with_fresh_receipt();
        fixture.write_program_contract_with_atomic();
        fixture.write_child("a", "framework/a.md", "implemented");
        fixture.write(
            "children/a/support/implementation-run.md",
            "verdict: pass\nreviewed_packet_digest: sha256:old\n",
        );
        fixture.write_v2_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert_eq!(plan.final_verdict, "blocked-human");
        assert!(plan.program_blockers.iter().any(|blocker| {
            blocker.blocker_class == "receipt-recovery-unavailable"
                && blocker
                    .message
                    .contains("required child a is not closeout-ready")
        }));
    }

    #[test]
    fn parent_evidence_cannot_satisfy_child_receipt_or_child_authority_surfaces() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("closeout-authority", true);
        fixture.write_program_contract_with_atomic();
        fixture.write_child("a", "framework/a.md", "implemented");
        fixture.write("parent/support/implementation-run.md", "receipt: parent\n");
        fixture.write(
            "parent/proposal.yml",
            "status: implemented\nchild_promotion_targets:\n  a:\n    - framework/a.md\n",
        );
        fixture.write_v2_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let error = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("closeout-authority".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: false,
                max_steps: None,
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap_err();

        assert!(error
            .to_string()
            .contains("parent manifest contains child-owned surface"));
    }

    #[test]
    fn parent_owned_child_validation_verdict_surface_blocks_closeout() {
        let _guard = crate::acquire_kernel_test_lock();
        for (name, parent_manifest, parent_evidence, expected) in [
            (
                "manifest",
                "status: implemented\nchild_validation_verdicts:\n  a: pass\n",
                None,
                "child-owned surface child_validation_verdicts",
            ),
            (
                "evidence",
                "status: implemented\n",
                Some("parent/support/child-validation-verdicts.yml"),
                "child-owned validation verdict surface",
            ),
        ] {
            let fixture = ProgramFixture::new(&format!("closeout-validation-{name}"), true);
            fixture.write_program_contract_with_atomic();
            fixture.write_child("a", "framework/a.md", "implemented");
            fixture.write(
                "children/a/support/implementation-run.md",
                "receipt: child-owned\n",
            );
            fixture.write("parent/proposal.yml", parent_manifest);
            if let Some(path) = parent_evidence {
                fixture.write(path, "a: pass\n");
            }
            fixture.write_v2_registry(
                "parallel-independent",
                r#"  - child_id: "a"
    path: "children/a"
"#,
            );

            let error = run_program_lifecycle_from_octon_dir(
                &fixture.octon_dir,
                RunLifecycleOptions {
                    lifecycle_id: "proposal-program".to_string(),
                    target: PathBuf::from("parent"),
                    run_id: Some(format!("closeout-validation-{name}")),
                    executor: ExecutorKind::Mock,
                    max_iterations: None,
                    execute_routes: false,
                    max_steps: None,
                    timeout_seconds: None,
                    max_child_concurrency: None,
                    invocation_authority: "unattended".to_string(),
                    run_inputs: BTreeMap::new(),
                    program_child_filter: None,
                },
            )
            .unwrap_err();

            assert!(
                error.to_string().contains(expected),
                "{name} error should mention {expected}: {error}"
            );
        }
    }

    #[test]
    fn program_atomic_stage_failure_rolls_back_staged_children() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("atomic-stage-failure", true);
        fixture.write_child_contract_with_atomic(true, false, true);
        fixture.write_program_contract_with_atomic();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write("children/a/support/missing-stage.md", "staged: yes\n");
        fixture.write_child("b", "framework/b.md", "accepted");
        fixture.write_v2_registry(
            "program-atomic",
            r#"  - child_id: "a"
    path: "children/a"
    dependency_gate: "terminal"
    recovery_profile: "default"
    rollback_posture: "compensating"
    write_scopes: ["framework/a.md"]
  - child_id: "b"
    path: "children/b"
    dependency_gate: "terminal"
    recovery_profile: "default"
    rollback_posture: "compensating"
    write_scopes: ["framework/b.md"]
"#,
        );

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("atomic-stage-failure".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: None,
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        assert!(result
            .child_results
            .iter()
            .any(|summary| summary.route_id == "atomic-stage" && summary.status == "failed"));
        assert!(result
            .child_results
            .iter()
            .any(|summary| summary.route_id == "atomic-rollback" && summary.status == "completed"));
        assert!(result
            .child_results
            .iter()
            .all(|summary| summary.route_id != "atomic-commit"));
    }

    #[test]
    fn program_atomic_commit_failure_compensates_committed_children() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("atomic-commit-failure", true);
        fixture.write_child_contract_with_atomic(false, true, true);
        fixture.write_program_contract_with_atomic();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write("children/a/support/missing-commit.md", "committed: yes\n");
        fixture.write_child("b", "framework/b.md", "accepted");
        fixture.write_v2_registry(
            "program-atomic",
            r#"  - child_id: "a"
    path: "children/a"
    dependency_gate: "terminal"
    recovery_profile: "default"
    rollback_posture: "compensating"
    write_scopes: ["framework/a.md"]
  - child_id: "b"
    path: "children/b"
    dependency_gate: "terminal"
    recovery_profile: "default"
    rollback_posture: "compensating"
    write_scopes: ["framework/b.md"]
"#,
        );

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("atomic-commit-failure".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: None,
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        assert!(result
            .child_results
            .iter()
            .any(|summary| summary.route_id == "atomic-commit" && summary.status == "failed"));
        assert!(result
            .child_results
            .iter()
            .any(|summary| summary.route_id == "atomic-compensate"));
    }

    #[test]
    fn program_atomic_preflights_all_required_participants() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("atomic-all-required", true);
        fixture.write_child_contract_with_atomic(false, false, true);
        fixture.write_program_contract_with_atomic();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_child("b", "framework/b.md", "accepted");
        fixture.write_v2_registry(
            "program-atomic",
            r#"  - child_id: "a"
    path: "children/a"
    dependency_gate: "terminal"
    recovery_profile: "default"
    rollback_posture: "compensating"
    write_scopes: ["framework/a.md"]
  - child_id: "b"
    path: "children/b"
    dependencies: ["a"]
    dependency_gate: "terminal"
    recovery_profile: "default"
    rollback_posture: "compensating"
    write_scopes: ["framework/b.md"]
"#,
        );

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("atomic-all-required".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: None,
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        assert!(result
            .child_results
            .iter()
            .any(|summary| summary.child_id == "b" && summary.status == "blocked-unsafe"));
        assert!(!result
            .child_results
            .iter()
            .any(|summary| summary.route_id == "atomic-stage"));
    }

    #[test]
    fn program_atomic_missing_compensation_becomes_blocked_unsafe() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("atomic-missing-compensation", true);
        fixture.write_child_contract_with_atomic(false, true, false);
        fixture.write_program_contract_with_atomic();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write("children/a/support/missing-commit.md", "commit: yes\n");
        fixture.write_child("b", "framework/b.md", "accepted");
        fixture.write_v2_registry(
            "program-atomic",
            r#"  - child_id: "a"
    path: "children/a"
    dependency_gate: "terminal"
    recovery_profile: "default"
    rollback_posture: "compensating"
    write_scopes: ["framework/a.md"]
  - child_id: "b"
    path: "children/b"
    dependency_gate: "terminal"
    recovery_profile: "default"
    rollback_posture: "compensating"
    write_scopes: ["framework/b.md"]
"#,
        );

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("atomic-missing-compensation".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: None,
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        assert!(result
            .child_results
            .iter()
            .any(|summary| summary.status == "blocked-unsafe"
                && summary.error_message.as_deref()
                    == Some("missing rollback or compensation route")));
        assert_eq!(result.final_verdict, "blocked-unsafe");
    }

    #[test]
    fn program_atomic_stale_lock_fails_closed() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("atomic-stale-lock", true);
        fixture.write_child_contract_with_atomic(false, false, true);
        fixture.write_program_contract_with_atomic();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_v2_registry(
            "program-atomic",
            r#"  - child_id: "a"
    path: "children/a"
    dependency_gate: "terminal"
    recovery_profile: "default"
    rollback_posture: "compensating"
    write_scopes: ["framework/a.md"]
"#,
        );
        fixture.write(
            ".octon/state/control/execution/runs/atomic-stale-lock/locks/a.lock",
            "stale: true\n",
        );

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("atomic-stale-lock".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: None,
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        assert!(result
            .child_results
            .iter()
            .any(|summary| summary.status == "blocked-unsafe"));
        assert_eq!(result.final_verdict, "blocked-unsafe");
    }

    #[test]
    fn write_scope_conflict_blocks_when_serialization_not_allowed() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("conflict", false);
        fixture.write_child("a", "framework/shared.md", "accepted");
        fixture.write_child("b", "framework/shared.md", "accepted");
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
  - child_id: "b"
    path: "children/b"
"#,
        );

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert_eq!(plan.runnable_batch, vec!["a".to_string()]);
        let b = plan.child_states.get("b").unwrap();
        assert!(b
            .blockers
            .iter()
            .any(|blocker| blocker.blocker_class == "atomic-write-scope-conflict"));
    }

    #[test]
    fn write_scope_conflict_serializes_when_allowed() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("conflict-serialized", true);
        fixture.write_child("a", "framework/shared.md", "accepted");
        fixture.write_child("b", "framework/shared.md", "accepted");
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
  - child_id: "b"
    path: "children/b"
"#,
        );

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert_eq!(plan.runnable_batch, vec!["a".to_string()]);
        let b = plan.child_states.get("b").unwrap();
        assert!(b
            .blockers
            .iter()
            .any(|blocker| blocker.blocker_class == "write-scope-serialization-required"));
    }

    #[test]
    fn dependency_cycle_fails_closed() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("dependency-cycle", true);
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_child("b", "framework/b.md", "accepted");
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
    dependencies: ["b"]
  - child_id: "b"
    path: "children/b"
    dependencies: ["a"]
"#,
        );

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert_eq!(plan.final_verdict, "blocked-unsafe");
        assert!(plan.runnable_batch.is_empty());
        assert!(plan.program_blockers.iter().any(|blocker| {
            blocker.blocker_class == "validation-failed"
                && blocker.message.contains("dependency cycle")
        }));
    }

    #[test]
    fn checkpoint_child_write_scope_drift_blocks_resume_planning() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("drift", true);
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );
        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();
        let checkpoint = checkpoint_from_plan(
            "test-run",
            "proposal-program",
            "parent",
            ExecutorKind::Mock,
            "unattended",
            &BTreeMap::new(),
            &plan,
            &[],
            &plan.final_verdict,
            None,
            0,
            BTreeMap::new(),
            BTreeMap::new(),
            BTreeMap::new(),
            BTreeMap::new(),
            Vec::new(),
        );

        fixture.write_child("a", "framework/changed.md", "accepted");
        let replanned = plan_program_lifecycle_from_octon_dir_with_checkpoint(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
            Some(&checkpoint),
        )
        .unwrap();

        let a = replanned.child_states.get("a").unwrap();
        assert!(a
            .blockers
            .iter()
            .any(|blocker| blocker.blocker_class == "target-drift-unclear"));
        assert_eq!(replanned.final_verdict, "blocked-human");
    }

    #[test]
    fn recovery_recipe_budget_blocks_after_exhaustion_and_requires_replan() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("recovery-budget", true);
        fixture.write_child_contract_with_fresh_receipt();
        fixture.write_program_contract_with_recovery_recipes();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write(
            "children/a/support/implementation-run.md",
            "verdict: pass\nreviewed_packet_digest: sha256:old\n",
        );
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );
        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();
        assert_eq!(plan.runnable_batch, vec!["a".to_string()]);

        let mut checkpoint = checkpoint_from_plan(
            "recovery-budget",
            "proposal-program",
            "parent",
            ExecutorKind::Mock,
            "unattended",
            &BTreeMap::new(),
            &plan,
            &[],
            &plan.final_verdict,
            None,
            0,
            BTreeMap::new(),
            BTreeMap::new(),
            BTreeMap::new(),
            BTreeMap::new(),
            Vec::new(),
        );
        checkpoint
            .recovery_attempts
            .insert("a:stale-receipt".to_string(), 1);
        let replanned = plan_program_lifecycle_from_octon_dir_with_checkpoint(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
            Some(&checkpoint),
        )
        .unwrap();
        assert!(replanned.runnable_batch.is_empty());
        assert!(replanned
            .child_states
            .get("a")
            .unwrap()
            .blockers
            .iter()
            .any(|blocker| blocker.message.contains("recovery budget exhausted")));
    }

    #[test]
    fn recovery_budget_does_not_block_after_route_progress() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("recovery-budget-progress", true);
        fixture.write_full_child_contract();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write(
            "children/a/support/executable-implementation-prompt.md",
            "# Executable Implementation Prompt\n",
        );
        fixture.write(
            "children/a/support/implementation-run.md",
            "verdict: pass\n",
        );
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );
        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();
        assert_eq!(
            plan.child_states
                .get("a")
                .unwrap()
                .selected_route
                .as_ref()
                .map(|route| route.route_id.as_str()),
            Some("promote-proposal")
        );

        let mut checkpoint = checkpoint_from_plan(
            "recovery-budget-progress",
            "proposal-program",
            "parent",
            ExecutorKind::Mock,
            "unattended",
            &BTreeMap::new(),
            &plan,
            &[],
            &plan.final_verdict,
            None,
            0,
            BTreeMap::new(),
            BTreeMap::new(),
            BTreeMap::new(),
            BTreeMap::new(),
            Vec::new(),
        );
        checkpoint
            .recovery_attempts
            .insert("a:missing-evidence".to_string(), 2);
        let replanned = plan_program_lifecycle_from_octon_dir_with_checkpoint(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
            Some(&checkpoint),
        )
        .unwrap();
        let child = replanned.child_states.get("a").unwrap();
        assert_eq!(replanned.runnable_batch, vec!["a".to_string()]);
        assert!(!child.blockers.iter().any(|blocker| {
            blocker.blocker_class == "recovery-budget-override-required"
                || blocker.blocker_class == "missing-evidence"
        }));
    }

    #[test]
    fn blocked_implementation_receipt_selects_recoverable_retry_route() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("implementation-blocked-route", true);
        fixture.write_full_child_contract();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write(
            "children/a/support/executable-implementation-prompt.md",
            "# Executable Implementation Prompt\n",
        );
        fixture.write(
            "children/a/support/implementation-run.md",
            "verdict: blocked\n",
        );
        fixture.write(
            "children/a/support/implementation-conformance-review.md",
            "verdict: fail\nunresolved_items_count: 1\n\nGenerated/effective projection drift remains.\n",
        );
        fixture.write(
            "children/a/support/post-implementation-drift-churn-review.md",
            "verdict: fail\nunresolved_items_count: 1\n\nRead-model digest drift remains.\n",
        );
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();
        let child = plan.child_states.get("a").unwrap();
        assert_eq!(
            child
                .selected_route
                .as_ref()
                .map(|route| route.route_id.as_str()),
            Some("run-packet-implementation")
        );
        assert_eq!(plan.runnable_batch, vec!["a".to_string()]);
        assert!(child.blockers.iter().any(|blocker| {
            blocker.blocker_class == "publication-drift"
                && blocker.recovery_route.as_deref() == Some("run-packet-implementation")
        }));
        assert!(!child
            .blockers
            .iter()
            .any(|blocker| blocker.blocker_class == "missing-evidence"));
    }

    #[test]
    fn no_progress_fingerprint_blocks_same_child_route_retry() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("no-progress-fingerprint", true);
        fixture.write_full_child_contract();
        fixture.write_program_contract_with_publication_recovery_action();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write(
            "children/a/support/executable-implementation-prompt.md",
            "# Executable Implementation Prompt\n",
        );
        fixture.write(
            "children/a/support/implementation-run.md",
            "verdict: blocked\n",
        );
        fixture.write(
            "children/a/support/implementation-conformance-review.md",
            "verdict: fail\nGenerated/effective projection drift remains.\n",
        );
        fixture.write(
            "children/a/support/post-implementation-drift-churn-review.md",
            "verdict: fail\nRead-model digest drift remains.\n",
        );
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );
        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();
        assert_eq!(plan.runnable_batch, vec!["a".to_string()]);
        let child_results = vec![ProgramChildExecutionSummary {
            child_id: "a".to_string(),
            child_run_id: "no-progress-fingerprint-a".to_string(),
            route_id: "run-packet-implementation".to_string(),
            status: "blocked".to_string(),
            attempts: 1,
            retryable: false,
            blocker_class: Some("publication-drift".to_string()),
            error_message: Some(
                "route completed but child lifecycle progress did not change".to_string(),
            ),
            error_class: None,
            evidence_paths: Vec::new(),
            worktree_hygiene_foreign_fingerprint: None,
        }];
        let checkpoint = checkpoint_from_plan(
            "no-progress-fingerprint",
            "proposal-program",
            "parent",
            ExecutorKind::Mock,
            "unattended",
            &BTreeMap::new(),
            &plan,
            &child_results,
            "blocked-recoverable",
            None,
            0,
            BTreeMap::new(),
            BTreeMap::new(),
            BTreeMap::new(),
            BTreeMap::new(),
            Vec::new(),
        );

        let replanned = plan_program_lifecycle_from_octon_dir_with_checkpoint(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
            Some(&checkpoint),
        )
        .unwrap();
        let child = replanned.child_states.get("a").unwrap();
        assert!(replanned.runnable_batch.is_empty());
        assert!(child.blockers.iter().any(|blocker| {
            blocker.blocker_class == "recovery-integrity-risk"
                && blocker.message.contains("same child/route/blocker")
        }));
    }

    #[test]
    fn publication_drift_runs_parent_refresh_then_resumes_child_execution() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("publication-recovery-resume", true);
        fixture.write_full_child_contract();
        fixture.write_program_contract_with_publication_recovery_action();
        fixture.write_publication_recovery_scripts(true, true);
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write(
            "children/a/support/executable-implementation-prompt.md",
            "# Executable Implementation Prompt\n",
        );
        fixture.write(
            "children/a/support/implementation-run.md",
            "verdict: blocked\n",
        );
        fixture.write(
            "children/a/support/implementation-conformance-review.md",
            "verdict: fail\nGenerated/effective projection drift remains.\n",
        );
        fixture.write(
            "children/a/support/post-implementation-drift-churn-review.md",
            "verdict: fail\nRead-model digest drift remains.\n",
        );
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("publication-recovery-resume".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: Some(1),
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        assert!(result
            .child_results
            .iter()
            .any(|summary| summary.route_id == "promote-proposal"));
        assert!(fixture
            .octon_dir
            .join("state/evidence/runs/workflows/publication-recovery-resume/program-recovery-actions/refresh-publication-projections/attempt-1/summary.yml")
            .is_file());
        let events = read_program_events(
            &fixture
                .octon_dir
                .join("state/control/execution/runs/publication-recovery-resume"),
        )
        .unwrap();
        assert!(events
            .iter()
            .any(|event| event.event_type == "program-recovery-action-started"));
        assert!(events
            .iter()
            .any(|event| event.event_type == "program-recovery-action-finished"));
    }

    #[test]
    fn failed_publication_refresh_stops_blocked_recoverable_without_child_retry() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("publication-recovery-failed", true);
        fixture.write_full_child_contract();
        fixture.write_program_contract_with_publication_recovery_action();
        fixture.write_publication_recovery_scripts(false, false);
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write(
            "children/a/support/executable-implementation-prompt.md",
            "# Executable Implementation Prompt\n",
        );
        fixture.write(
            "children/a/support/implementation-run.md",
            "verdict: blocked\n",
        );
        fixture.write(
            "children/a/support/implementation-conformance-review.md",
            "verdict: fail\nGenerated/effective projection drift remains.\n",
        );
        fixture.write(
            "children/a/support/post-implementation-drift-churn-review.md",
            "verdict: fail\nRead-model digest drift remains.\n",
        );
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("publication-recovery-failed".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: Some(1),
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        assert_eq!(result.final_verdict, "blocked-recoverable");
        assert!(result.child_results.is_empty());
        let summary_path = fixture.octon_dir.join(
            "state/evidence/runs/workflows/publication-recovery-failed/program-recovery-actions/refresh-publication-projections/attempt-1/summary.yml",
        );
        let summary = fs::read_to_string(summary_path).unwrap();
        assert!(summary.contains("status: \"failed\""));
        assert!(summary.contains("failed_command: \"generate-support-envelope-reconciliation\""));
        let events = read_program_events(
            &fixture
                .octon_dir
                .join("state/control/execution/runs/publication-recovery-failed"),
        )
        .unwrap();
        assert!(events
            .iter()
            .any(|event| event.event_type == "program-recovery-action-validation-failed"));
    }

    #[test]
    fn publication_refresh_allows_child_retry_for_stale_child_receipt() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("publication-recovery-still-stale", true);
        fixture.write_full_child_contract();
        fixture.write_program_contract_with_publication_recovery_action();
        fixture.write_publication_recovery_scripts(true, false);
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write(
            "children/a/support/executable-implementation-prompt.md",
            "# Executable Implementation Prompt\n",
        );
        fixture.write(
            "children/a/support/implementation-run.md",
            "verdict: blocked\n",
        );
        fixture.write(
            "children/a/support/implementation-conformance-review.md",
            "verdict: fail\nGenerated/effective projection drift remains.\n",
        );
        fixture.write(
            "children/a/support/post-implementation-drift-churn-review.md",
            "verdict: fail\nRead-model digest drift remains.\n",
        );
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("publication-recovery-still-stale".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: Some(1),
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        assert_eq!(result.final_verdict, "step-budget-exhausted-continuable");
        assert!(result
            .child_results
            .iter()
            .any(|summary| summary.route_id == "run-packet-implementation"));
        let summary_path = fixture.octon_dir.join(
            "state/evidence/runs/workflows/publication-recovery-still-stale/program-recovery-actions/refresh-publication-projections/attempt-1/summary.yml",
        );
        let summary = fs::read_to_string(summary_path).unwrap();
        assert!(summary.contains("status: \"completed\""));
    }

    #[test]
    fn recovery_post_attempt_validation_failure_marks_route_failed() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("recovery-post-validation", true);
        fixture.write_child_contract_with_fresh_receipt();
        fixture.write_program_contract_with_recovery_recipes();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write(
            "children/a/support/implementation-run.md",
            "verdict: pass\nreviewed_packet_digest: sha256:old\n",
        );
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("recovery-post-validation".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: None,
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        let summary = result
            .child_results
            .iter()
            .find(|summary| summary.blocker_class.as_deref() == Some("stale-receipt"))
            .unwrap();
        assert_eq!(summary.status, "failed");
        assert!(
            summary
                .error_message
                .as_deref()
                .unwrap_or_default()
                .contains("post-attempt validation failed"),
            "summary: {:?}",
            summary
        );
    }

    #[test]
    fn closeout_blocked_receipt_maps_to_worktree_hygiene_blocker() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("closeout-blocked-classification", true);
        fixture.write_program_contract_with_recovery_recipes();
        fixture.write_child("a", "framework/a.md", "implemented");
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );
        let mut plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();
        plan.child_states
            .get_mut("a")
            .unwrap()
            .blockers
            .push(ProgramBlocker {
                blocker_class: "artifact-ownership-unclear".to_string(),
                message: "closeout blocked by worktree hygiene".to_string(),
                recovery_route: None,
            });
        let program = load_lifecycle_contract(&fixture.octon_dir, "proposal-program")
            .unwrap()
            .contract
            .program
            .unwrap();
        let control_root = fixture
            .octon_dir
            .join("state/control/execution/runs/closeout-blocked-classification");
        let mut child_results = vec![ProgramChildExecutionSummary {
            child_id: "a".to_string(),
            child_run_id: "closeout-blocked-classification-a".to_string(),
            route_id: "closeout-packet".to_string(),
            status: "completed".to_string(),
            attempts: 1,
            retryable: false,
            blocker_class: Some("stale-receipt".to_string()),
            error_message: None,
            error_class: None,
            evidence_paths: Vec::new(),
            worktree_hygiene_foreign_fingerprint: None,
        }];

        enforce_recovery_post_attempt_validations(
            &program,
            &plan,
            &control_root,
            true,
            &mut child_results,
        )
        .unwrap();

        assert_eq!(child_results[0].status, "blocked");
        assert_eq!(
            child_results[0].blocker_class.as_deref(),
            Some("artifact-ownership-unclear")
        );
        assert!(!child_results[0].retryable);
    }

    #[test]
    fn closeout_hygiene_preflight_blocks_foreign_paths_before_dispatch() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("closeout-hygiene-preflight", true);
        fixture.write_full_child_contract();
        fixture.write_worktree_hygiene_classifier(false);
        fixture.write_child("a", "framework/a.md", "implemented");
        fixture.write(
            "children/a/support/implementation-conformance-review.md",
            "verdict: pass\n",
        );
        fixture.write(
            "children/a/support/post-implementation-drift-churn-review.md",
            "verdict: pass\n",
        );
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("closeout-hygiene-preflight".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: Some(1),
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        assert_eq!(result.child_results.len(), 1);
        let summary = &result.child_results[0];
        assert_eq!(summary.route_id, "closeout-packet");
        assert_eq!(summary.status, "blocked");
        assert_eq!(summary.attempts, 0);
        assert_eq!(
            summary.blocker_class.as_deref(),
            Some("artifact-ownership-unclear")
        );
        let events = read_program_events(
            &fixture
                .octon_dir
                .join("state/control/execution/runs/closeout-hygiene-preflight"),
        )
        .unwrap();
        assert!(events
            .iter()
            .any(|event| event.event_type == "worktree-hygiene-preflight"));
    }

    #[test]
    fn closeout_hygiene_suppression_skips_repeat_and_continues_other_child() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("closeout-hygiene-suppression-continues", true);
        fixture.write_full_child_contract();
        fixture.write_worktree_hygiene_classifier_blocking_child("a", "sha256:dirty-a");
        fixture.write_child("a", "framework/a.md", "implemented");
        fixture.write(
            "children/a/support/implementation-conformance-review.md",
            "verdict: pass\n",
        );
        fixture.write(
            "children/a/support/post-implementation-drift-churn-review.md",
            "verdict: pass\n",
        );
        fixture.write_child("b", "framework/b.md", "accepted");
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
  - child_id: "b"
    path: "children/b"
"#,
        );

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("closeout-hygiene-suppression-continues".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: Some(20),
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        assert_eq!(
            result
                .child_results
                .iter()
                .filter(|summary| {
                    summary.child_id == "a"
                        && summary.route_id == "closeout-packet"
                        && summary.blocker_class.as_deref() == Some("artifact-ownership-unclear")
                })
                .count(),
            1
        );
        assert!(result.child_results.iter().any(|summary| {
            summary.child_id == "b"
                && summary.route_id == "archive-proposal"
                && summary.status == "completed"
        }));
        assert!(
            fs::read_to_string(fixture.root.join("children/b/proposal.yml"))
                .unwrap()
                .contains("status: archived")
        );
        let events = read_program_events(
            &fixture
                .octon_dir
                .join("state/control/execution/runs/closeout-hygiene-suppression-continues"),
        )
        .unwrap();
        assert_eq!(
            events
                .iter()
                .filter(|event| {
                    event.event_type == "worktree-hygiene-preflight"
                        && event.child_id.as_deref() == Some("a")
                })
                .count(),
            1
        );
    }

    #[test]
    fn closeout_hygiene_suppression_stops_single_child_without_max_steps() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("closeout-hygiene-suppression-single", true);
        fixture.write_full_child_contract();
        fixture.write_worktree_hygiene_classifier_blocking_child("a", "sha256:dirty-a");
        fixture.write_child("a", "framework/a.md", "implemented");
        fixture.write(
            "children/a/support/implementation-conformance-review.md",
            "verdict: pass\n",
        );
        fixture.write(
            "children/a/support/post-implementation-drift-churn-review.md",
            "verdict: pass\n",
        );
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("closeout-hygiene-suppression-single".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: Some(24),
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        assert_eq!(result.final_verdict, "blocked-human");
        assert_eq!(
            result
                .child_results
                .iter()
                .filter(|summary| summary.route_id == "closeout-packet")
                .count(),
            1
        );
        let control_root = fixture
            .octon_dir
            .join("state/control/execution/runs/closeout-hygiene-suppression-single");
        let events = read_program_events(&control_root).unwrap();
        assert!(!events
            .iter()
            .any(|event| event.event_type == "max-steps-exhausted"));
        let status =
            status_program_lifecycle_run(&fixture.octon_dir, "closeout-hygiene-suppression-single")
                .unwrap();
        assert!(status.runnable_batch.is_empty());
        assert!(status
            .child_blockers
            .get("a")
            .unwrap()
            .iter()
            .any(|blocker| blocker.blocker_class == "artifact-ownership-unclear"));
        let explanation = explain_program_lifecycle_blockers(
            &fixture.octon_dir,
            "closeout-hygiene-suppression-single",
        )
        .unwrap();
        assert!(explanation
            .child_blockers
            .get("a")
            .unwrap()
            .iter()
            .any(|blocker| blocker.blocker_class == "artifact-ownership-unclear"));
    }

    #[test]
    fn closeout_hygiene_suppression_invalidates_on_fingerprint_change() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("closeout-hygiene-suppression-fingerprint", true);
        fixture.write_full_child_contract();
        fixture.write_worktree_hygiene_classifier_blocking_child("a", "sha256:dirty-a");
        fixture.write_child("a", "framework/a.md", "implemented");
        fixture.write(
            "children/a/support/implementation-conformance-review.md",
            "verdict: pass\n",
        );
        fixture.write(
            "children/a/support/post-implementation-drift-churn-review.md",
            "verdict: pass\n",
        );
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("closeout-hygiene-suppression-fingerprint".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: Some(24),
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();
        let first_checkpoint = read_program_checkpoint_for_run(
            &fixture.octon_dir,
            "closeout-hygiene-suppression-fingerprint",
        )
        .unwrap()
        .unwrap();
        assert_eq!(
            first_checkpoint
                .closeout_hygiene_suppressions
                .get("a:closeout-packet")
                .and_then(|suppression| suppression
                    .worktree_hygiene_foreign_fingerprint
                    .as_deref()),
            Some("sha256:dirty-a")
        );

        fixture.write_worktree_hygiene_classifier_blocking_child("a", "sha256:dirty-b");
        run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("closeout-hygiene-suppression-fingerprint".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: Some(24),
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        let events = read_program_events(
            &fixture
                .octon_dir
                .join("state/control/execution/runs/closeout-hygiene-suppression-fingerprint"),
        )
        .unwrap();
        assert_eq!(
            events
                .iter()
                .filter(|event| event.event_type == "worktree-hygiene-preflight")
                .count(),
            2
        );
        let second_checkpoint = read_program_checkpoint_for_run(
            &fixture.octon_dir,
            "closeout-hygiene-suppression-fingerprint",
        )
        .unwrap()
        .unwrap();
        assert_eq!(
            second_checkpoint
                .closeout_hygiene_suppressions
                .get("a:closeout-packet")
                .and_then(|suppression| suppression
                    .worktree_hygiene_foreign_fingerprint
                    .as_deref()),
            Some("sha256:dirty-b")
        );
    }

    #[test]
    fn residue_cleanup_route_runs_once_for_suppressed_hygiene_blocker() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("residue-cleanup-route-once", true);
        fixture.write_program_contract_with_residue_cleanup_route();
        fixture.write_full_child_contract();
        fixture.write_worktree_hygiene_classifier_blocking_child("a", "sha256:dirty-a");
        fixture.write_child("a", "framework/a.md", "implemented");
        fixture.write(
            "children/a/support/implementation-conformance-review.md",
            "verdict: pass\n",
        );
        fixture.write(
            "children/a/support/post-implementation-drift-churn-review.md",
            "verdict: pass\n",
        );
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("residue-cleanup-route-once".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: Some(24),
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        assert_eq!(result.final_verdict, "blocked-human");
        let control_root = fixture
            .octon_dir
            .join("state/control/execution/runs/residue-cleanup-route-once");
        let events = read_program_events(&control_root).unwrap();
        assert_eq!(
            events
                .iter()
                .filter(|event| {
                    event.event_type == "parent-route-started"
                        && event.route_id.as_deref() == Some(ROUTE_ID_CLEANUP_LIFECYCLE_RESIDUE)
                })
                .count(),
            1
        );
        let checkpoint =
            read_program_checkpoint_for_run(&fixture.octon_dir, "residue-cleanup-route-once")
                .unwrap()
                .unwrap();
        assert!(checkpoint
            .residue_cleanup_attempts
            .contains_key("a:closeout-packet:artifact-ownership-unclear:sha256:dirty-a"));
        assert!(fixture
            .root
            .join("parent/support/lifecycle-residue-cleanup.md")
            .is_file());
    }

    #[test]
    fn residue_cleanup_unchanged_fingerprint_is_not_redispatched() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("residue-cleanup-no-repeat", true);
        fixture.write_program_contract_with_residue_cleanup_route();
        fixture.write_full_child_contract();
        fixture.write_worktree_hygiene_classifier_blocking_child("a", "sha256:dirty-a");
        fixture.write_child("a", "framework/a.md", "implemented");
        fixture.write(
            "children/a/support/implementation-conformance-review.md",
            "verdict: pass\n",
        );
        fixture.write(
            "children/a/support/post-implementation-drift-churn-review.md",
            "verdict: pass\n",
        );
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        for _ in 0..2 {
            run_program_lifecycle_from_octon_dir(
                &fixture.octon_dir,
                RunLifecycleOptions {
                    lifecycle_id: "proposal-program".to_string(),
                    target: PathBuf::from("parent"),
                    run_id: Some("residue-cleanup-no-repeat".to_string()),
                    executor: ExecutorKind::Mock,
                    max_iterations: None,
                    execute_routes: true,
                    max_steps: Some(24),
                    timeout_seconds: None,
                    max_child_concurrency: None,
                    invocation_authority: "unattended".to_string(),
                    run_inputs: BTreeMap::new(),
                    program_child_filter: None,
                },
            )
            .unwrap();
        }

        let events = read_program_events(
            &fixture
                .octon_dir
                .join("state/control/execution/runs/residue-cleanup-no-repeat"),
        )
        .unwrap();
        assert_eq!(
            events
                .iter()
                .filter(|event| {
                    event.event_type == "parent-route-started"
                        && event.route_id.as_deref() == Some(ROUTE_ID_CLEANUP_LIFECYCLE_RESIDUE)
                })
                .count(),
            1
        );
        let status =
            status_program_lifecycle_run(&fixture.octon_dir, "residue-cleanup-no-repeat").unwrap();
        assert!(status
            .child_blockers
            .get("a")
            .unwrap()
            .iter()
            .any(|blocker| blocker.blocker_class == "artifact-ownership-unclear"));
    }

    #[test]
    fn residue_cleanup_changed_fingerprint_allows_new_attempt() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("residue-cleanup-fingerprint-change", true);
        fixture.write_program_contract_with_residue_cleanup_route();
        fixture.write_full_child_contract();
        fixture.write_worktree_hygiene_classifier_blocking_child("a", "sha256:dirty-a");
        fixture.write_child("a", "framework/a.md", "implemented");
        fixture.write(
            "children/a/support/implementation-conformance-review.md",
            "verdict: pass\n",
        );
        fixture.write(
            "children/a/support/post-implementation-drift-churn-review.md",
            "verdict: pass\n",
        );
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("residue-cleanup-fingerprint-change".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: Some(24),
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        fixture.write_worktree_hygiene_classifier_blocking_child("a", "sha256:dirty-b");
        run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("residue-cleanup-fingerprint-change".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: Some(24),
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        let events = read_program_events(
            &fixture
                .octon_dir
                .join("state/control/execution/runs/residue-cleanup-fingerprint-change"),
        )
        .unwrap();
        assert_eq!(
            events
                .iter()
                .filter(|event| {
                    event.event_type == "parent-route-started"
                        && event.route_id.as_deref() == Some(ROUTE_ID_CLEANUP_LIFECYCLE_RESIDUE)
                })
                .count(),
            2
        );
        let checkpoint = read_program_checkpoint_for_run(
            &fixture.octon_dir,
            "residue-cleanup-fingerprint-change",
        )
        .unwrap()
        .unwrap();
        assert!(checkpoint
            .residue_cleanup_attempts
            .contains_key("a:closeout-packet:artifact-ownership-unclear:sha256:dirty-a"));
        assert!(checkpoint
            .residue_cleanup_attempts
            .contains_key("a:closeout-packet:artifact-ownership-unclear:sha256:dirty-b"));
    }

    #[test]
    fn residue_cleanup_does_not_prevent_other_child_progress() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("residue-cleanup-continues-other-child", true);
        fixture.write_program_contract_with_residue_cleanup_route();
        fixture.write_full_child_contract();
        fixture.write_worktree_hygiene_classifier_blocking_child("a", "sha256:dirty-a");
        fixture.write_child("a", "framework/a.md", "implemented");
        fixture.write(
            "children/a/support/implementation-conformance-review.md",
            "verdict: pass\n",
        );
        fixture.write(
            "children/a/support/post-implementation-drift-churn-review.md",
            "verdict: pass\n",
        );
        fixture.write_child("b", "framework/b.md", "accepted");
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
  - child_id: "b"
    path: "children/b"
"#,
        );

        let result = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("residue-cleanup-continues-other-child".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: Some(24),
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();

        assert_eq!(result.final_verdict, "blocked-human");
        assert!(
            fs::read_to_string(fixture.root.join("children/b/proposal.yml"))
                .unwrap()
                .contains("status: archived")
        );
        let events = read_program_events(
            &fixture
                .octon_dir
                .join("state/control/execution/runs/residue-cleanup-continues-other-child"),
        )
        .unwrap();
        assert_eq!(
            events
                .iter()
                .filter(|event| {
                    event.event_type == "parent-route-started"
                        && event.route_id.as_deref() == Some(ROUTE_ID_CLEANUP_LIFECYCLE_RESIDUE)
                })
                .count(),
            1
        );
    }

    #[test]
    fn stale_receipt_recovery_waits_for_ownership_resolution() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("stale-receipt-ownership-first", true);
        fixture.write_program_contract_with_recovery_recipes();
        fixture.write_full_child_contract();
        fixture.write_child("a", "framework/a.md", "implemented");
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );
        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();
        let mut state = plan.child_states.get("a").unwrap().clone();
        state.selected_route = Some(RoutePlanState {
            route_id: "run-implementation".to_string(),
            route_type: "extension".to_string(),
            command_id: None,
            skill_id: None,
            prompt_set_id: None,
        });
        state.blockers = vec![
            ProgramBlocker {
                blocker_class: "artifact-ownership-unclear".to_string(),
                message: "ownership cannot be resolved from local evidence".to_string(),
                recovery_route: None,
            },
            ProgramBlocker {
                blocker_class: "stale-receipt".to_string(),
                message: "one or more child receipts are stale".to_string(),
                recovery_route: Some("run-implementation".to_string()),
            },
        ];

        let (route, blocker_class) = selected_route_for_child_execution(
            &fixture.octon_dir,
            &RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("stale-receipt-ownership-first".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: Some(1),
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
            &state,
            None,
            &plan.child_registry_digest,
        )
        .unwrap();

        assert!(route.is_none());
        assert_eq!(blocker_class.as_deref(), Some("artifact-ownership-unclear"));
    }

    #[test]
    fn program_execute_loop_continues_recoverable_or_unattended_pending_dispatch() {
        let result = ProgramLifecycleRunResult {
            schema_version: "octon-program-lifecycle-run-result-v1".to_string(),
            run_id: "stop-semantics".to_string(),
            lifecycle_id: "proposal-program".to_string(),
            execution_strategy: LifecycleExecutionStrategy::OrchestratedReplanLoop
                .as_str()
                .to_string(),
            target: "parent".to_string(),
            executor: "mock".to_string(),
            route_execution_mode: "program-adapter-executed".to_string(),
            bundle_root: "evidence".to_string(),
            checkpoint_path: "checkpoint.yml".to_string(),
            event_log_path: "events.ndjson".to_string(),
            latest_event_offset: 1,
            selected_parent_route: None,
            parent_route_result: None,
            selected_children: vec!["a".to_string()],
            child_results: Vec::new(),
            terminal_outcome: None,
            final_verdict: "blocked-recoverable".to_string(),
        };
        assert!(!program_execute_loop_should_stop(&result, "unattended"));

        let mut blocked_human = result.clone();
        blocked_human.final_verdict = "blocked-human".to_string();
        assert!(!program_execute_loop_should_stop(
            &blocked_human,
            "unattended"
        ));
        let mut approval_blocked = blocked_human.clone();
        approval_blocked.child_results = vec![ProgramChildExecutionSummary {
            child_id: "a".to_string(),
            child_run_id: "stop-semantics-a".to_string(),
            route_id: "run-implementation".to_string(),
            status: "human-boundary-blocked".to_string(),
            attempts: 0,
            retryable: false,
            blocker_class: Some("authority-ambiguity".to_string()),
            error_message: None,
            error_class: None,
            evidence_paths: Vec::new(),
            worktree_hygiene_foreign_fingerprint: None,
        }];
        assert!(program_execute_loop_should_stop(
            &approval_blocked,
            "unattended"
        ));
        let mut executor_preflight_blocked = blocked_human.clone();
        executor_preflight_blocked.child_results = vec![ProgramChildExecutionSummary {
            child_id: "a".to_string(),
            child_run_id: "stop-semantics-a".to_string(),
            route_id: "run-implementation".to_string(),
            status: "executor-preflight-blocked".to_string(),
            attempts: 0,
            retryable: false,
            blocker_class: Some("executor-unavailable".to_string()),
            error_message: Some("nested Codex runtime preflight failed".to_string()),
            error_class: None,
            evidence_paths: Vec::new(),
            worktree_hygiene_foreign_fingerprint: None,
        }];
        assert!(program_execute_loop_should_stop(
            &executor_preflight_blocked,
            "unattended"
        ));

        let mut no_dispatch = result;
        no_dispatch.selected_children.clear();
        assert!(program_execute_loop_should_stop(&no_dispatch, "unattended"));
    }

    #[test]
    fn recovery_replay_verify_post_attempt_validation_passes_only_for_valid_replay() {
        let _guard = crate::acquire_kernel_test_lock();
        for (name, tamper, expected_status) in [
            ("recovery-replay-pass", false, "completed"),
            ("recovery-replay-fail", true, "failed"),
        ] {
            let fixture = ProgramFixture::new(name, true);
            fixture.write_program_contract_with_recovery_replay_verify();
            fixture.write_child("a", "framework/a.md", "accepted");
            fixture.write_registry(
                "parallel-independent",
                r#"  - child_id: "a"
    path: "children/a"
"#,
            );
            run_program_lifecycle_from_octon_dir(
                &fixture.octon_dir,
                RunLifecycleOptions {
                    lifecycle_id: "proposal-program".to_string(),
                    target: PathBuf::from("parent"),
                    run_id: Some(name.to_string()),
                    executor: ExecutorKind::Mock,
                    max_iterations: None,
                    execute_routes: false,
                    max_steps: None,
                    timeout_seconds: None,
                    max_child_concurrency: None,
                    invocation_authority: "unattended".to_string(),
                    run_inputs: BTreeMap::new(),
                    program_child_filter: None,
                },
            )
            .unwrap();
            let control_root = fixture
                .octon_dir
                .join(format!("state/control/execution/runs/{name}"));
            if tamper {
                let event_log = control_root.join("program-events.ndjson");
                let tampered = fs::read_to_string(&event_log)
                    .unwrap()
                    .replace("plan-created", "plan-mutated");
                fs::write(&event_log, tampered).unwrap();
            }
            let plan = plan_program_lifecycle_from_octon_dir(
                &fixture.octon_dir,
                "proposal-program",
                Path::new("parent"),
            )
            .unwrap();
            let program = load_lifecycle_contract(&fixture.octon_dir, "proposal-program")
                .unwrap()
                .contract
                .program
                .unwrap();
            let mut child_results = vec![ProgramChildExecutionSummary {
                child_id: "a".to_string(),
                child_run_id: format!("{name}-a"),
                route_id: "run-implementation".to_string(),
                status: "completed".to_string(),
                attempts: 1,
                retryable: false,
                blocker_class: Some("stale-receipt".to_string()),
                error_message: None,
                error_class: None,
                evidence_paths: Vec::new(),
                worktree_hygiene_foreign_fingerprint: None,
            }];

            enforce_recovery_post_attempt_validations(
                &program,
                &plan,
                &control_root,
                true,
                &mut child_results,
            )
            .unwrap();

            assert_eq!(child_results[0].status, expected_status);
            if tamper {
                assert!(child_results[0]
                    .error_message
                    .as_deref()
                    .unwrap_or_default()
                    .contains("replay-verify"));
            }
        }
    }

    #[test]
    fn recovery_replan_behavior_is_enforced_after_attempts() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("recovery-replan-required", true);
        fixture.write_program_contract_with_recovery_recipes();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );
        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();
        let program = load_lifecycle_contract(&fixture.octon_dir, "proposal-program")
            .unwrap()
            .contract
            .program
            .unwrap();
        let control_root = fixture
            .octon_dir
            .join("state/control/execution/runs/recovery-replan-required");
        let evidence_root = fixture
            .octon_dir
            .join("state/evidence/runs/workflows/recovery-replan-required");
        append_program_event(
            &control_root,
            &evidence_root,
            "recovery-replan-required",
            "plan-created",
            None,
            None,
            "program lifecycle plan created",
            BTreeMap::new(),
        )
        .unwrap();
        let mut child_results = vec![ProgramChildExecutionSummary {
            child_id: "a".to_string(),
            child_run_id: "recovery-replan-required-a".to_string(),
            route_id: "run-implementation".to_string(),
            status: "completed".to_string(),
            attempts: 1,
            retryable: false,
            blocker_class: Some("stale-receipt".to_string()),
            error_message: None,
            error_class: None,
            evidence_paths: Vec::new(),
            worktree_hygiene_foreign_fingerprint: None,
        }];

        enforce_recovery_post_attempt_validations(
            &program,
            &plan,
            &control_root,
            false,
            &mut child_results,
        )
        .unwrap();

        assert_eq!(child_results[0].status, "failed");
        assert!(child_results[0]
            .error_message
            .as_deref()
            .unwrap_or_default()
            .contains("replan_behavior was not satisfied"));
    }

    #[test]
    fn unsupported_recovery_replan_behavior_is_rejected() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("recovery-unsupported-replan", true);
        fixture.write_child_contract_with_fresh_receipt();
        fixture.write(
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycles/proposal-program.contract.yml",
            r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-program"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "program_packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted", "implemented"] }
program:
  child_registry_path: "resources/child-packet-index.yml"
  child_lifecycle_id_default: "proposal-packet"
  supported_execution_modes: ["parallel-independent"]
  recovery_policy:
    max_recovery_attempts: 2
    serialize_write_scope_conflicts: true
    recipes:
      - blocker_class: "stale-receipt"
        recovery_route_id: "run-implementation"
        idempotency_class: "idempotent"
        human_required: false
        retry_budget: 1
        dependent_handling: "continue-independent"
        post_attempt_validation: ["replan-live-state"]
        replan_behavior: "eventually"
  authority_boundaries:
    parent_coordinates_only: true
    child_receipts_remain_child_owned: true
    child_promotion_targets_remain_child_owned: true
states: [{ state_id: "coordinate" }]
routes:
  - route_id: "generate-program-implementation-prompt"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: ["program-implementation-prompt"]
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
"#,
        );
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write(
            "children/a/support/implementation-run.md",
            "verdict: pass\nreviewed_packet_digest: sha256:old\n",
        );
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let error = run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("recovery-unsupported-replan".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: None,
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap_err();

        assert!(error
            .to_string()
            .contains("unsupported recovery replan_behavior"));
    }

    #[test]
    fn child_lock_cleanup_releases_acquired_locks_after_job_build_failure() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("lock-build-failure", true);
        fixture.write_bad_child_contract_with_unsupported_input();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_child("b", "framework/b.md", "accepted");
        let mut child_states = BTreeMap::new();
        for (child_id, lifecycle_id, target, scope) in [
            ("a", "proposal-packet", "children/a", "framework/a.md"),
            ("b", "bad-child", "children/b", "framework/b.md"),
        ] {
            child_states.insert(
                child_id.to_string(),
                ProgramChildPlanState {
                    child_id: child_id.to_string(),
                    child_lifecycle_id: lifecycle_id.to_string(),
                    target: target.to_string(),
                    required: true,
                    deferred: false,
                    dependencies: Vec::new(),
                    dependency_gate: None,
                    phase_id: None,
                    group_id: None,
                    seed_role: None,
                    rollback_posture: None,
                    recovery_profile: None,
                    phase_commit_barrier: None,
                    selected_route: Some(RoutePlanState {
                        route_id: "run-implementation".to_string(),
                        route_type: "extension".to_string(),
                        command_id: None,
                        skill_id: None,
                        prompt_set_id: None,
                    }),
                    terminal_outcome: None,
                    receipt_digests: BTreeMap::new(),
                    gate_status: ProgramChildGateStatus::default(),
                    dependency_gate_status: BTreeMap::new(),
                    write_scopes: vec![target.to_string(), scope.to_string()],
                    blockers: Vec::new(),
                    final_verdict: "route-ready".to_string(),
                },
            );
        }
        let plan = ProgramLifecyclePlanResult {
            schema_version: "octon-program-lifecycle-plan-v1".to_string(),
            lifecycle_id: "proposal-program".to_string(),
            owner_extension: "test-extension".to_string(),
            execution_strategy: LifecycleExecutionStrategy::OrchestratedReplanLoop
                .as_str()
                .to_string(),
            contract_path: "test".to_string(),
            target: "parent".to_string(),
            parent_manifest_status: Some("accepted".to_string()),
            child_registry_path: "parent/resources/child-packet-index.yml".to_string(),
            child_registry_schema_version: "octon-proposal-program-child-registry-v1".to_string(),
            child_registry_digest: "sha256:test".to_string(),
            execution_mode: "parallel-independent".to_string(),
            aggregate_state: "planned".to_string(),
            terminal_outcome: None,
            parent_receipt_states: BTreeMap::new(),
            program_route: None,
            program_gate_results: Vec::new(),
            blocked_by_program_gate: None,
            program_blockers: Vec::new(),
            normalized_program_blockers: Vec::new(),
            child_states,
            normalized_child_blockers: BTreeMap::new(),
            runnable_batch: vec!["a".to_string(), "b".to_string()],
            scheduler_phase: Some("default".to_string()),
            skipped_blocked_children: Vec::new(),
            required_child_completion: BTreeMap::new(),
            closeout_hygiene_suppressions: BTreeMap::new(),
            safe_repair_candidates: Vec::new(),
            program_recovery_recipe_validation_status: None,
            program_recovery_recipe_validation_failures: Vec::new(),
            program_recovery_recipe_blocker_class: None,
            program_recovery_recipe_route_id: None,
            program_recovery_recipe_delegation_contract_basis: None,
            unsafe_results: Vec::new(),
            unsafe_continuation_decision: None,
            approval_blockers: Vec::new(),
            normalized_approval_blockers: Vec::new(),
            checkpoint_drift: None,
            stop_reason: Some("dispatch-available".to_string()),
            final_verdict: "planned".to_string(),
        };
        let evidence_root = fixture
            .octon_dir
            .join("state/evidence/runs/workflows/lock-build-failure");
        let control_root = fixture
            .octon_dir
            .join("state/control/execution/runs/lock-build-failure");
        fs::create_dir_all(&evidence_root).unwrap();
        fs::create_dir_all(&control_root).unwrap();
        let error = match build_child_execution_jobs(
            &fixture.octon_dir,
            &fixture.root,
            "lock-build-failure",
            &BTreeMap::new(),
            &RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: None,
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: true,
                max_steps: None,
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
            &plan,
            &evidence_root,
            &control_root,
            None,
            None,
        ) {
            Ok(_) => panic!("job construction should fail for bad child lifecycle"),
            Err(error) => error,
        };

        assert!(!error.to_string().is_empty());
        assert!(!fixture
            .octon_dir
            .join("state/control/execution/runs/lock-build-failure/locks/a.lock")
            .exists());
        let events = fs::read_to_string(
            fixture
                .octon_dir
                .join("state/control/execution/runs/lock-build-failure/program-events.ndjson"),
        )
        .unwrap();
        assert!(events.contains("child-lock-released"));
        let criticality = fs::read_to_string(
            fixture.octon_dir.join(
                "state/evidence/runs/workflows/lock-build-failure/artifact-criticality/remove_child_lock-a-run-implementation.yml",
            ),
        )
        .unwrap();
        assert!(criticality.contains("criticality: non-critical"));
        assert!(criticality.contains("human_input_required: false"));
        assert!(criticality.contains("after_validation: lock artifact absent"));
    }

    #[test]
    fn child_lock_cleanup_blocks_when_ownership_is_unclear() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("lock-criticality-unclear", true);
        let control_root = fixture
            .octon_dir
            .join("state/control/execution/runs/lock-criticality-unclear");
        let evidence_root = fixture
            .octon_dir
            .join("state/evidence/runs/workflows/lock-criticality-unclear");
        fs::create_dir_all(&control_root).unwrap();
        fs::create_dir_all(&evidence_root).unwrap();
        let unclear_lock_path = control_root.join("unexpected.lock");
        fs::write(&unclear_lock_path, "child_id: a\n").unwrap();

        let error = release_child_lock(
            &control_root,
            &evidence_root,
            "lock-criticality-unclear",
            "a",
            "run-implementation",
            &unclear_lock_path,
        )
        .unwrap_err();

        assert!(error.to_string().contains("requires human input"));
        assert!(
            unclear_lock_path.exists(),
            "unclear ownership must not be cleaned autonomously"
        );
        let criticality = fs::read_to_string(
            evidence_root.join("artifact-criticality/remove_child_lock-a-run-implementation.yml"),
        )
        .unwrap();
        assert!(criticality.contains("criticality: unclear"));
        assert!(criticality.contains("human_input_required: true"));
        assert!(criticality.contains("after_validation: not-run-human-input-required"));
    }

    #[test]
    fn atomic_lock_cleanup_records_generalized_criticality_evidence() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("atomic-lock-criticality", true);
        let control_root = fixture
            .octon_dir
            .join("state/control/execution/runs/atomic-lock-criticality");
        let evidence_root = fixture
            .octon_dir
            .join("state/evidence/runs/workflows/atomic-lock-criticality");
        fs::create_dir_all(control_root.join("locks")).unwrap();
        fs::create_dir_all(&evidence_root).unwrap();
        let lock_path = control_root.join("locks/a.lock");
        fs::write(&lock_path, "child_id: a\n").unwrap();

        release_atomic_locks(
            &control_root,
            &evidence_root,
            "atomic-lock-criticality",
            vec![("a".to_string(), lock_path.clone())],
        )
        .unwrap();

        assert!(!lock_path.exists());
        let criticality = fs::read_to_string(
            evidence_root
                .join("artifact-criticality/remove_atomic_child_lock-a-program-atomic.yml"),
        )
        .unwrap();
        assert!(criticality.contains("operation_id: remove_atomic_child_lock-a-program-atomic"));
        assert!(criticality.contains("destructive_operation: remove_file"));
        assert!(criticality.contains("artifact_owner: current-run"));
        assert!(criticality.contains("human_input_required: false"));
    }

    #[test]
    fn generalized_cleanup_blocks_retained_evidence_artifacts() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("critical-artifact-cleanup", true);
        let control_root = fixture
            .octon_dir
            .join("state/control/execution/runs/critical-artifact-cleanup");
        let evidence_root = fixture
            .octon_dir
            .join("state/evidence/runs/workflows/critical-artifact-cleanup");
        fs::create_dir_all(&control_root).unwrap();
        fs::create_dir_all(&evidence_root).unwrap();
        let retained_evidence = evidence_root.join("program-plan.yml");
        fs::write(&retained_evidence, "final_verdict: planned\n").unwrap();
        let operation = ProgramArtifactOperation {
            operation_id: "remove-retained-evidence".to_string(),
            child_id: "a".to_string(),
            route_id: "run-implementation".to_string(),
            operation: "remove_retained_evidence".to_string(),
            destructive_operation: "remove_file".to_string(),
            artifact_paths: vec![retained_evidence.clone()],
            command_or_operation: "fs::remove_file".to_string(),
        };

        let error = perform_governed_artifact_cleanup(
            &control_root,
            &evidence_root,
            "critical-artifact-cleanup",
            &operation,
        )
        .unwrap_err();

        assert!(error.to_string().contains("requires human input"));
        assert!(retained_evidence.exists());
        let criticality = fs::read_to_string(
            evidence_root
                .join("artifact-criticality/remove_retained_evidence-a-run-implementation.yml"),
        )
        .unwrap();
        assert!(criticality.contains("criticality: critical"));
        assert!(criticality.contains("authority_surface: retained-lifecycle-evidence"));
        assert!(criticality.contains("human_input_required: true"));
        assert!(criticality.contains(
            "classification_policy_version: octon-program-artifact-criticality-policy-v2"
        ));
        assert!(criticality.contains("mutation_status: blocked"));
    }

    #[test]
    fn governed_cleanup_blocks_unsupported_destructive_operations_with_evidence() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("unsupported-cleanup-operation", true);
        let control_root = fixture
            .octon_dir
            .join("state/control/execution/runs/unsupported-cleanup-operation");
        let evidence_root = fixture
            .octon_dir
            .join("state/evidence/runs/workflows/unsupported-cleanup-operation");
        fs::create_dir_all(control_root.join("locks")).unwrap();
        fs::create_dir_all(&evidence_root).unwrap();
        let lock_path = control_root.join("locks/a.lock");
        fs::write(&lock_path, "child_id: a\n").unwrap();
        let operation = ProgramArtifactOperation {
            operation_id: "unsupported-cleanup".to_string(),
            child_id: "a".to_string(),
            route_id: "run-implementation".to_string(),
            operation: "remove_child_lock".to_string(),
            destructive_operation: "archive_mutation".to_string(),
            artifact_paths: vec![lock_path.clone()],
            command_or_operation: "archive_mutation".to_string(),
        };

        let error = perform_governed_artifact_cleanup(
            &control_root,
            &evidence_root,
            "unsupported-cleanup-operation",
            &operation,
        )
        .unwrap_err();

        assert!(error.to_string().contains("requires human input"));
        assert!(lock_path.exists());
        let criticality = fs::read_to_string(
            evidence_root.join("artifact-criticality/remove_child_lock-a-run-implementation.yml"),
        )
        .unwrap();
        assert!(criticality.contains("operation_supported: false"));
        assert!(criticality.contains("blocked_reason: unsupported-destructive-operation"));
        assert!(criticality.contains("mutation_performed: false"));
    }

    #[test]
    fn lifecycle_program_destructive_cleanup_uses_governed_helper() {
        let source = include_str!("lifecycle_program.rs");
        let offenders = source
            .lines()
            .enumerate()
            .filter(|(_, line)| {
                (line.contains("fs::remove_file(")
                    || line.contains("fs::remove_dir(")
                    || line.contains("fs::remove_dir_all("))
                    && !line.contains("match fs::remove_file(path)")
                    && !line.contains("match fs::remove_dir(path)")
                    && !line.contains("match fs::remove_dir_all(path)")
                    && !line.contains("fs::remove_dir_all(&self.root)")
                    && !line.contains("line.contains(")
            })
            .map(|(line, text)| format!("{}: {}", line + 1, text.trim()))
            .collect::<Vec<_>>();
        assert!(
            offenders.is_empty(),
            "destructive cleanup must use perform_governed_artifact_cleanup: {offenders:?}"
        );
    }

    #[test]
    fn child_lock_is_released_when_finish_event_append_fails() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("lock-finish-event-failure", true);
        let control_root = fixture
            .octon_dir
            .join("state/control/execution/runs/lock-finish-event-failure");
        let evidence_root = fixture
            .octon_dir
            .join("state/evidence/runs/workflows/lock-finish-event-failure");
        fs::create_dir_all(control_root.join("locks")).unwrap();
        fs::create_dir_all(evidence_root.join("program-events.ndjson")).unwrap();
        let lock_path = control_root.join("locks/a.lock");
        fs::write(&lock_path, "child_id: a\n").unwrap();
        let outcome = ChildExecutionOutcome {
            summary: ProgramChildExecutionSummary {
                child_id: "a".to_string(),
                child_run_id: "lock-finish-event-failure-a".to_string(),
                route_id: "run-implementation".to_string(),
                status: "completed".to_string(),
                attempts: 1,
                retryable: false,
                blocker_class: None,
                error_message: None,
                error_class: None,
                evidence_paths: Vec::new(),
                worktree_hygiene_foreign_fingerprint: None,
            },
            lock_path: lock_path.clone(),
        };

        let error = finish_child_execution(
            &control_root,
            &evidence_root,
            "lock-finish-event-failure",
            outcome,
            None,
        )
        .unwrap_err();

        assert!(error
            .to_string()
            .contains("finish event append failed after execution"));
        assert!(
            !lock_path.exists(),
            "finish-event append failure must not leave the child lock behind"
        );
    }

    #[test]
    fn child_lock_release_failure_records_stale_lock() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("lock-release-failure", true);
        let control_root = fixture
            .octon_dir
            .join("state/control/execution/runs/lock-release-failure");
        let evidence_root = fixture
            .octon_dir
            .join("state/evidence/runs/workflows/lock-release-failure");
        let lock_path = control_root.join("locks/a.lock");
        fs::create_dir_all(&lock_path).unwrap();
        fs::create_dir_all(&evidence_root).unwrap();
        let outcome = ChildExecutionOutcome {
            summary: ProgramChildExecutionSummary {
                child_id: "a".to_string(),
                child_run_id: "lock-release-failure-a".to_string(),
                route_id: "run-implementation".to_string(),
                status: "completed".to_string(),
                attempts: 1,
                retryable: false,
                blocker_class: None,
                error_message: None,
                error_class: None,
                evidence_paths: Vec::new(),
                worktree_hygiene_foreign_fingerprint: None,
            },
            lock_path: lock_path.clone(),
        };

        let error = finish_child_execution(
            &control_root,
            &evidence_root,
            "lock-release-failure",
            outcome,
            None,
        )
        .unwrap_err();

        assert!(error.to_string().contains("could not be released"));
        let events = fs::read_to_string(control_root.join("program-events.ndjson")).unwrap();
        assert!(events.contains("child-lock-stale"));
        assert!(lock_path.exists());
    }

    #[test]
    fn program_identifier_validation_matches_schema_format() {
        assert!(valid_program_id("child-one"));
        assert!(valid_program_id("phase-2"));
        for invalid in ["Child", "child_one", "child.one", "1-child", ""] {
            assert!(!valid_program_id(invalid), "{invalid} should be invalid");
        }
    }

    #[test]
    fn invalid_optional_registry_identifiers_are_rejected_at_runtime() {
        let _guard = crate::acquire_kernel_test_lock();
        let cases = [
            ("phase", "    phase_id: \"Bad\"\n", "phase_id"),
            ("group", "    group_id: \"bad_group\"\n", "group_id"),
            (
                "replacement-child",
                "    replacement_child_id: \"1-replacement\"\n",
                "replacement_child_id",
            ),
            (
                "replacement-for",
                "    replacement_for: \"bad.child\"\n",
                "replacement_for",
            ),
            (
                "recovery-profile",
                "    recovery_profile: \"Bad\"\n",
                "recovery_profile",
            ),
            (
                "phase-barrier",
                "    phase_commit_barrier: \"bad_barrier\"\n",
                "phase_commit_barrier",
            ),
            (
                "child-lifecycle",
                "    child_lifecycle_id: \"Bad\"\n",
                "child_lifecycle_id",
            ),
            (
                "dependency",
                "    dependencies: [\"Bad\"]\n",
                "dependency id",
            ),
            (
                "rollback-posture",
                "    rollback_posture: \"magic\"\n",
                "rollback_posture",
            ),
            ("seed-role", "    seed_role: \"primary\"\n", "seed_role"),
        ];
        for (name, field, expected) in cases {
            let fixture = ProgramFixture::new(&format!("registry-id-{name}"), true);
            fixture.write_child("a", "framework/a.md", "accepted");
            fixture.write_v2_registry(
                "parallel-independent",
                &format!("  - child_id: \"a\"\n    path: \"children/a\"\n{field}"),
            );

            let plan = plan_program_lifecycle_from_octon_dir(
                &fixture.octon_dir,
                "proposal-program",
                Path::new("parent"),
            )
            .unwrap();

            assert!(
                plan.program_blockers.iter().any(|blocker| {
                    blocker.blocker_class == "validation-failed"
                        && blocker.message.contains(expected)
                }),
                "{name} blocker should mention {expected}: {:?}",
                plan.program_blockers
            );
        }

        let fixture = ProgramFixture::new("registry-id-default-lifecycle", true);
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write(
            "parent/resources/child-packet-index.yml",
            r#"schema_version: "octon-proposal-program-child-registry-v1"
execution_mode: "parallel-independent"
default_child_lifecycle_id: "Bad"
children:
  - child_id: "a"
    path: "children/a"
"#,
        );
        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();
        assert!(plan.program_blockers.iter().any(|blocker| {
            blocker.blocker_class == "validation-failed"
                && blocker.message.contains("default_child_lifecycle_id")
        }));
    }

    #[test]
    fn program_atomic_rejects_invalid_child_rollback_posture() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("atomic-rollback-posture", true);
        fixture.write_child_contract_with_atomic(false, false, true);
        fixture.write_program_contract_with_atomic();
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_v2_registry(
            "program-atomic",
            r#"  - child_id: "a"
    path: "children/a"
    dependency_gate: "terminal"
    recovery_profile: "default"
    rollback_posture: "magic"
    write_scopes: ["framework/a.md"]
"#,
        );

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert_eq!(plan.final_verdict, "blocked-unsafe");
        assert!(plan.runnable_batch.is_empty());
        assert!(plan.program_blockers.iter().any(|blocker| {
            blocker.blocker_class == "validation-failed"
                && blocker.message.contains("rollback_posture")
        }));
    }

    #[test]
    fn invalid_optional_mutation_identifiers_are_rejected_at_runtime() {
        let _guard = crate::acquire_kernel_test_lock();
        let cases = [
            ("phase", "phase_id: \"Bad\"\n", "phase_id"),
            ("group", "group_id: \"bad_group\"\n", "group_id"),
            (
                "recovery-profile",
                "recovery_profile: \"Bad\"\n",
                "recovery_profile",
            ),
            ("dependency", "dependencies: [\"Bad\"]\n", "dependency id"),
            (
                "rollback-posture",
                "rollback_posture: \"magic\"\n",
                "rollback_posture",
            ),
        ];
        for (name, field, expected) in cases {
            let fixture = ProgramFixture::new(&format!("mutation-id-{name}"), true);
            fixture.write_child("a", "framework/a.md", "accepted");
            fixture.write_registry(
                "parallel-independent",
                r#"  - child_id: "a"
    path: "children/a"
"#,
            );
            run_program_lifecycle_from_octon_dir(
                &fixture.octon_dir,
                RunLifecycleOptions {
                    lifecycle_id: "proposal-program".to_string(),
                    target: PathBuf::from("parent"),
                    run_id: Some(format!("mutation-id-{name}")),
                    executor: ExecutorKind::Mock,
                    max_iterations: None,
                    execute_routes: false,
                    max_steps: None,
                    timeout_seconds: None,
                    max_child_concurrency: None,
                    invocation_authority: "unattended".to_string(),
                    run_inputs: BTreeMap::new(),
                    program_child_filter: None,
                },
            )
            .unwrap();
            let digest =
                file_digest(&fixture.root.join("parent/resources/child-packet-index.yml")).unwrap();
            fixture.write(
                "bad-mutation.yml",
                &format!(
                    "schema_version: \"octon-proposal-program-mutation-v1\"\nexpected_registry_digest: \"{digest}\"\naction: \"add-child\"\nchild_id: \"b\"\npath: \"children/b\"\n{field}rationale: \"bad optional identifier\"\n"
                ),
            );

            let error = propose_program_mutation(
                &fixture.octon_dir,
                &format!("mutation-id-{name}"),
                Path::new("bad-mutation.yml"),
            )
            .unwrap_err();

            assert!(
                error.to_string().contains(expected),
                "{name} error should mention {expected}: {error}"
            );
        }

        let fixture = ProgramFixture::new("mutation-id-replacement", true);
        fixture.write_child("a", "framework/a.md", "accepted");
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );
        run_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-program".to_string(),
                target: PathBuf::from("parent"),
                run_id: Some("mutation-id-replacement".to_string()),
                executor: ExecutorKind::Mock,
                max_iterations: None,
                execute_routes: false,
                max_steps: None,
                timeout_seconds: None,
                max_child_concurrency: None,
                invocation_authority: "unattended".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();
        let digest =
            file_digest(&fixture.root.join("parent/resources/child-packet-index.yml")).unwrap();
        fixture.write(
            "bad-mutation.yml",
            &format!(
                "schema_version: \"octon-proposal-program-mutation-v1\"\nexpected_registry_digest: \"{digest}\"\naction: \"replace-child\"\nchild_id: \"a\"\nreplacement_child_id: \"Bad\"\npath: \"children/b\"\nsupersession_evidence: \"parent/resources/a-replaced.md\"\nrationale: \"bad replacement identifier\"\n"
            ),
        );
        let error = propose_program_mutation(
            &fixture.octon_dir,
            "mutation-id-replacement",
            Path::new("bad-mutation.yml"),
        )
        .unwrap_err();
        assert!(error.to_string().contains("replacement_child_id"));
    }

    #[test]
    fn invalid_optional_scaffold_identifiers_are_rejected_at_runtime() {
        let _guard = crate::acquire_kernel_test_lock();
        let cases = [
            (
                "program",
                "program_id: \"Bad\"\nseed_reference_child:\n  child_id: \"seed\"\n  path: \"children/seed\"\n",
                "program_id",
            ),
            (
                "phase",
                "seed_reference_child:\n  child_id: \"seed\"\n  path: \"children/seed\"\n  phase_id: \"Bad\"\n",
                "phase_id",
            ),
            (
                "group",
                "seed_reference_child:\n  child_id: \"seed\"\n  path: \"children/seed\"\n  group_id: \"bad_group\"\n",
                "group_id",
            ),
            (
                "dependency",
                "seed_reference_child:\n  child_id: \"seed\"\n  path: \"children/seed\"\nfollow_on_child_candidates:\n  - child_id: \"follow\"\n    path: \"children/follow\"\n    dependencies: [\"Bad\"]\n",
                "dependency id",
            ),
            (
                "rollback-posture",
                "seed_reference_child:\n  child_id: \"seed\"\n  path: \"children/seed\"\n  rollback_posture: \"magic\"\n",
                "rollback_posture",
            ),
            (
                "seed-role",
                "seed_reference_child:\n  child_id: \"seed\"\n  path: \"children/seed\"\n  seed_role: \"primary\"\n",
                "seed_role",
            ),
        ];
        for (name, body, expected) in cases {
            let fixture = ProgramFixture::new(&format!("scaffold-id-{name}"), true);
            fixture.write(
                "bad-scaffold.yml",
                &format!(
                    "schema_version: \"octon-proposal-program-scaffold-v1\"\ntitle: \"Bad Scaffold Identifier\"\nexecution_mode: \"sequential\"\n{body}rationale: \"bad optional identifier\"\n"
                ),
            );

            let error = scaffold_program_from_seed(
                &fixture.octon_dir,
                Path::new("program-parent"),
                Path::new("bad-scaffold.yml"),
                true,
            )
            .unwrap_err();

            assert!(
                error.to_string().contains(expected),
                "{name} error should mention {expected}: {error}"
            );
        }
    }

    #[test]
    fn invalid_event_child_or_route_identifiers_are_rejected_at_runtime() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("event-id", true);
        let control_root = fixture
            .octon_dir
            .join("state/control/execution/runs/event-id");
        let evidence_root = fixture
            .octon_dir
            .join("state/evidence/runs/workflows/event-id");

        let child_error = append_program_event(
            &control_root,
            &evidence_root,
            "event-id",
            "child-route-started",
            Some("Bad"),
            Some("run-implementation"),
            "bad child id",
            BTreeMap::new(),
        )
        .unwrap_err();
        assert!(child_error.to_string().contains("child_id"));

        let route_error = append_program_event(
            &control_root,
            &evidence_root,
            "event-id",
            "child-route-started",
            Some("a"),
            Some("bad_route"),
            "bad route id",
            BTreeMap::new(),
        )
        .unwrap_err();
        assert!(route_error.to_string().contains("route_id"));
    }

    #[test]
    fn non_recoverable_authority_boundary_blockers_fail_closed() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("non-recoverable", true);
        fixture.write_child("a", "/absolute/promotion-target.md", "accepted");
        fixture.write_registry(
            "parallel-independent",
            r#"  - child_id: "a"
    path: "children/a"
"#,
        );

        let plan = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap();

        assert_eq!(plan.final_verdict, "blocked-unsafe");
        assert!(plan.runnable_batch.is_empty());
    }
}
