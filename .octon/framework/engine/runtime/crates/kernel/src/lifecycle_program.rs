use super::*;
use octon_lifecycle_executor::{
    DefaultLifecycleRouteExecutor, LifecycleRouteExecutionRequest, LifecycleRouteExecutionResult,
    LifecycleRouteExecutor,
};
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::collections::{BTreeMap, BTreeSet};
use std::fs;
use std::fs::OpenOptions;
use std::io::Write;
use std::path::{Path, PathBuf};
use std::thread;

const PROGRAM_CHECKPOINT_FILE: &str = "program-lifecycle-checkpoint.yml";
const DEFAULT_CHILD_LIFECYCLE_ID: &str = "proposal-packet";
const DEFAULT_MAX_CHILD_CONCURRENCY: usize = 2;

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
    pub contract_path: String,
    pub target: String,
    pub parent_manifest_status: Option<String>,
    pub child_registry_path: String,
    pub child_registry_schema_version: String,
    pub child_registry_digest: String,
    pub execution_mode: String,
    pub aggregate_state: String,
    #[serde(default)]
    pub program_route: Option<RoutePlanState>,
    #[serde(default)]
    pub program_gate_results: Vec<GatePlanResult>,
    #[serde(default)]
    pub blocked_by_program_gate: Option<String>,
    #[serde(default)]
    pub program_blockers: Vec<ProgramBlocker>,
    #[serde(default)]
    pub child_states: BTreeMap<String, ProgramChildPlanState>,
    #[serde(default)]
    pub runnable_batch: Vec<String>,
    #[serde(default)]
    pub approval_blockers: Vec<ProgramApprovalBlocker>,
    #[serde(default)]
    pub checkpoint_drift: Option<String>,
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
    pub write_scopes: Vec<String>,
    #[serde(default)]
    pub blockers: Vec<ProgramBlocker>,
    pub final_verdict: String,
}

#[derive(Clone, Debug, Serialize)]
pub(crate) struct ProgramBlocker {
    pub blocker_class: String,
    pub message: String,
    #[serde(default)]
    pub recovery_route: Option<String>,
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
    pub target: String,
    pub executor: String,
    pub route_execution_mode: String,
    pub bundle_root: String,
    pub checkpoint_path: String,
    pub event_log_path: String,
    pub latest_event_offset: u64,
    #[serde(default)]
    pub selected_children: Vec<String>,
    #[serde(default)]
    pub child_results: Vec<ProgramChildExecutionSummary>,
    #[serde(default)]
    pub terminal_outcome: Option<String>,
    pub final_verdict: String,
}

#[derive(Clone, Debug, Serialize)]
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
}

#[derive(Clone, Debug, Default, Deserialize, Serialize)]
struct ProgramLifecycleCheckpoint {
    schema_version: String,
    run_id: String,
    lifecycle_id: String,
    target: String,
    #[serde(default)]
    executor: Option<String>,
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
    approvals: Vec<ProgramApprovalGrant>,
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
    terminal_outcome: Option<String>,
    final_verdict: String,
    resume_instruction: String,
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
    write_scopes: Vec<String>,
}

struct ProgramContext {
    loaded: LoadedContract,
    target_rel: String,
    parent_manifest_status: Option<String>,
    registry_rel: String,
    registry_digest: String,
    registry: ProgramChildRegistry,
}

struct ChildExecutionJob {
    child_id: String,
    child_run_id: String,
    route_id: String,
    request: LifecycleRouteExecutionRequest,
    lock_path: PathBuf,
    max_attempts: u32,
    blocker_class: Option<String>,
}

struct ChildExecutionOutcome {
    summary: ProgramChildExecutionSummary,
    lock_path: PathBuf,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
pub(crate) struct ProgramApprovalGrant {
    child_id: String,
    route_id: String,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    blocker_class: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    registry_digest: Option<String>,
    reason: String,
    recorded_at: String,
    evidence_path: String,
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
    pub program_blockers: Vec<ProgramBlocker>,
    #[serde(default)]
    pub child_blockers: BTreeMap<String, Vec<ProgramBlocker>>,
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
    plan_program_lifecycle_from_octon_dir_with_checkpoint(octon_dir, lifecycle_id, target, None)
}

fn plan_program_lifecycle_from_octon_dir_with_checkpoint(
    octon_dir: &Path,
    lifecycle_id: &str,
    target: &Path,
    checkpoint: Option<&ProgramLifecycleCheckpoint>,
) -> Result<ProgramLifecyclePlanResult> {
    let repo_root = repo_root_for_octon(octon_dir)?;
    let context = load_program_context(octon_dir, lifecycle_id, target)?;
    let program = context
        .loaded
        .contract
        .program
        .as_ref()
        .context("lifecycle contract is not a program lifecycle")?;
    validate_authority_boundaries(program)?;
    validate_program_registry(&context.registry)?;

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
        let child_target_abs = resolve_lifecycle_target_path(&repo_root, Path::new(&child.path))?;
        let child_target_rel = rel_display(&repo_root, &child_target_abs);
        let mut blockers = Vec::new();
        let mut selected_route = None;
        let mut terminal_outcome = None;
        let mut final_verdict = "deferred".to_string();
        let mut receipt_digests = BTreeMap::new();
        let mut write_scopes = declared_or_default_write_scopes(child, &child_target_rel)?;

        if child.deferred {
            blockers.push(ProgramBlocker {
                blocker_class: "dependency-blocked".to_string(),
                message: "child is explicitly deferred by the program registry".to_string(),
                recovery_route: None,
            });
        } else {
            match plan_lifecycle_from_octon_dir(
                octon_dir,
                &child_lifecycle_id,
                Path::new(&child.path),
            ) {
                Ok(plan) => {
                    selected_route = plan.next_route.clone();
                    terminal_outcome = plan.terminal_outcome.clone();
                    final_verdict = plan.final_verdict.clone();
                    receipt_digests = receipt_digest_map(&plan);
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
                    if plan
                        .receipt_states
                        .values()
                        .any(|receipt| !receipt.missing_required_fields.is_empty())
                    {
                        blockers.push(ProgramBlocker {
                            blocker_class: "missing-evidence".to_string(),
                            message: "one or more child receipts are missing required fields"
                                .to_string(),
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
                    } else if plan.final_verdict == "blocked-no-route" {
                        blockers.push(ProgramBlocker {
                            blocker_class: "missing-evidence".to_string(),
                            message: "child is not terminal and has no selectable route"
                                .to_string(),
                            recovery_route: None,
                        });
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
                write_scopes,
                blockers,
                final_verdict,
            },
        );
    }

    apply_checkpoint_child_drift(&mut child_states, checkpoint);
    apply_dependency_blockers(&mut child_states);
    let mut program_blockers = Vec::new();
    let (program_route, program_gate_results, blocked_by_program_gate) =
        plan_program_level_route(&repo_root, &context, &mut program_blockers)?;
    if !program
        .supported_execution_modes
        .iter()
        .any(|mode| mode == &context.registry.execution_mode)
    {
        program_blockers.push(ProgramBlocker {
            blocker_class: "unsupported-mode".to_string(),
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
    apply_closeout_policy_blockers(program, &child_states, &mut program_blockers);
    apply_recovery_budget_blockers(program, &mut child_states, checkpoint);
    apply_recovery_approval_blockers(
        program,
        &context.registry_digest,
        &mut child_states,
        checkpoint.map(|checkpoint| &checkpoint.approvals),
    );
    apply_recovery_dependent_handling(
        program,
        &context.registry,
        &mut child_states,
        &mut program_blockers,
    );

    let mut runnable_batch = select_runnable_batch(program, &context.registry, &mut child_states);
    if program_blockers
        .iter()
        .any(|blocker| blocker.blocker_class == "unsupported-mode")
    {
        runnable_batch.clear();
    }

    let approval_blockers = collect_approval_blockers(
        octon_dir,
        program,
        &context.registry_digest,
        &child_states,
        checkpoint.map(|c| &c.approvals),
    )?;
    let (aggregate_state, final_verdict) =
        aggregate_program_state(&child_states, &program_blockers, &runnable_batch);
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

    Ok(ProgramLifecyclePlanResult {
        schema_version: "octon-program-lifecycle-plan-v1".to_string(),
        lifecycle_id: context.loaded.contract.lifecycle_id,
        owner_extension: context.loaded.contract.owner_extension,
        contract_path: rel_display(&repo_root, &context.loaded.path),
        target: context.target_rel,
        parent_manifest_status: context.parent_manifest_status,
        child_registry_path: context.registry_rel,
        child_registry_schema_version: context.registry.schema_version,
        child_registry_digest: context.registry_digest,
        execution_mode: context.registry.execution_mode,
        aggregate_state,
        program_route,
        program_gate_results,
        blocked_by_program_gate,
        program_blockers,
        child_states,
        runnable_batch,
        approval_blockers,
        checkpoint_drift,
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
    append_program_event(
        &control_root,
        &evidence_root,
        &sanitized_run_id,
        "run-started",
        None,
        None,
        "program lifecycle run started",
        BTreeMap::new(),
    )?;

    let previous_checkpoint = read_program_checkpoint_for_run(octon_dir, &run_id)?;
    let context = load_program_context(octon_dir, &options.lifecycle_id, &options.target)?;
    let target_rel = context.target_rel.clone();
    if let Some(checkpoint) = previous_checkpoint.as_ref() {
        validate_program_checkpoint_binding(
            checkpoint,
            &sanitized_run_id,
            &options.lifecycle_id,
            &target_rel,
            &context.registry_digest,
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

    let mut plan = plan_program_lifecycle_from_octon_dir_with_checkpoint(
        octon_dir,
        &options.lifecycle_id,
        &options.target,
        previous_checkpoint.as_ref(),
    )?;
    if let Some(child_id) = options.program_child_filter.as_ref() {
        filter_plan_to_child(&mut plan, child_id)?;
    }
    append_program_event(
        &control_root,
        &evidence_root,
        &sanitized_run_id,
        "plan-created",
        None,
        None,
        "program lifecycle plan created",
        event_data([("final_verdict", plan.final_verdict.as_str())]),
    )?;
    let mut child_results = Vec::new();
    let mut final_verdict = plan.final_verdict.clone();
    let mut terminal_outcome = if plan.aggregate_state == "completed" {
        Some("completed".to_string())
    } else {
        None
    };

    if options.execute_routes && !plan.runnable_batch.is_empty() {
        let max_concurrency = options
            .max_child_concurrency
            .unwrap_or(DEFAULT_MAX_CHILD_CONCURRENCY)
            .max(1);
        let scheduled_children = plan.runnable_batch.join(",");
        append_program_event(
            &control_root,
            &evidence_root,
            &sanitized_run_id,
            "schedule-created",
            None,
            None,
            "program scheduler selected runnable child batch",
            event_data([("children", scheduled_children.as_str())]),
        )?;
        child_results = if plan.execution_mode == "program-atomic" {
            execute_atomic_program(
                octon_dir,
                &repo_root,
                &sanitized_run_id,
                &run_inputs,
                &options,
                &plan,
                &evidence_root,
                &control_root,
                previous_checkpoint
                    .as_ref()
                    .map(|checkpoint| &checkpoint.approvals),
            )?
        } else {
            let jobs = build_child_execution_jobs(
                octon_dir,
                &repo_root,
                &sanitized_run_id,
                &run_inputs,
                &options,
                &plan,
                &evidence_root,
                &control_root,
                previous_checkpoint
                    .as_ref()
                    .map(|checkpoint| &checkpoint.approvals),
                previous_checkpoint.as_ref(),
            )?;
            execute_child_jobs(
                &repo_root,
                &sanitized_run_id,
                &control_root,
                &evidence_root,
                jobs,
                max_concurrency,
            )?
        };
        plan = plan_program_lifecycle_from_octon_dir_with_checkpoint(
            octon_dir,
            &options.lifecycle_id,
            &options.target,
            previous_checkpoint.as_ref(),
        )?;
        if let Some(child_id) = options.program_child_filter.as_ref() {
            filter_plan_to_child(&mut plan, child_id)?;
        }
        if let Some(program) = context.loaded.contract.program.as_ref() {
            enforce_recovery_post_attempt_validations(
                program,
                &plan,
                &control_root,
                true,
                &mut child_results,
            )?;
        }
        let execution_had_human_block = child_results
            .iter()
            .any(|result| result.status == "approval-required");
        let execution_had_failure = child_results.iter().any(|result| {
            matches!(
                result.status.as_str(),
                "failed" | "timed-out" | "cancelled" | "blocked" | "blocked-unsafe"
            )
        });
        final_verdict = if child_results
            .iter()
            .any(|result| result.status == "blocked-unsafe")
        {
            "blocked-unsafe".to_string()
        } else if execution_had_human_block {
            "blocked-human".to_string()
        } else if execution_had_failure {
            "blocked-recoverable".to_string()
        } else {
            plan.final_verdict.clone()
        };
        terminal_outcome = if plan.aggregate_state == "completed" {
            Some("completed".to_string())
        } else {
            None
        };
    }

    let mut checkpoint = checkpoint_from_plan(
        &sanitized_run_id,
        &options.lifecycle_id,
        &target_rel,
        options.executor,
        &run_inputs,
        &plan,
        &child_results,
        &final_verdict,
        terminal_outcome.clone(),
        count_program_events(&control_root)?,
        previous_checkpoint
            .as_ref()
            .map(|checkpoint| checkpoint.recovery_attempts.clone())
            .unwrap_or_default(),
        previous_checkpoint
            .as_ref()
            .map(|checkpoint| checkpoint.approvals.clone())
            .unwrap_or_default(),
    );
    enrich_checkpoint_event_metadata(&mut checkpoint, &control_root)?;
    let checkpoint_path = program_checkpoint_path_for_run(octon_dir, &sanitized_run_id)?;
    fs::write(&checkpoint_path, serde_yaml::to_string(&checkpoint)?)?;
    fs::write(
        evidence_root.join("program-plan.yml"),
        serde_yaml::to_string(&plan)?,
    )?;
    fs::write(
        evidence_root.join("scheduler-decision.yml"),
        serde_yaml::to_string(&plan.runnable_batch)?,
    )?;
    write_run_inputs_evidence(&evidence_root, &checkpoint.run_id, &checkpoint.run_inputs)?;
    fs::write(
        evidence_root.join("summary.md"),
        program_lifecycle_summary(&sanitized_run_id, &options.executor, &plan, &final_verdict),
    )?;
    fs::write(
        evidence_root.join("recovery-log.yml"),
        serde_yaml::to_string(&child_results)?,
    )?;
    if terminal_outcome.is_some() {
        write_program_aggregate_closeout(octon_dir, &evidence_root, &checkpoint, &plan)?;
        append_program_event(
            &control_root,
            &evidence_root,
            &sanitized_run_id,
            "closeout",
            None,
            None,
            "program lifecycle aggregate closeout evidence written",
            BTreeMap::new(),
        )?;
        enrich_checkpoint_event_metadata(&mut checkpoint, &control_root)?;
        fs::write(&checkpoint_path, serde_yaml::to_string(&checkpoint)?)?;
    }
    let latest_event_offset = count_program_events(&control_root)?;

    Ok(ProgramLifecycleRunResult {
        schema_version: "octon-program-lifecycle-run-result-v1".to_string(),
        run_id: sanitized_run_id,
        lifecycle_id: options.lifecycle_id,
        target: target_rel,
        executor: options.executor.as_str().to_string(),
        route_execution_mode: if options.execute_routes {
            "program-adapter-executed".to_string()
        } else {
            "program-route-handoff".to_string()
        },
        bundle_root: rel_display(&repo_root, &evidence_root),
        checkpoint_path: rel_display(&repo_root, &checkpoint_path),
        event_log_path: rel_display(&repo_root, &program_control_event_log_path(&control_root)),
        latest_event_offset,
        selected_children: plan.runnable_batch,
        child_results,
        terminal_outcome,
        final_verdict,
    })
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
            timeout_seconds: None,
            max_child_concurrency: Some(DEFAULT_MAX_CHILD_CONCURRENCY),
            approval_policy: "minimize".to_string(),
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
    let approval_root = evidence_root.join("approvals");
    fs::create_dir_all(&approval_root)?;
    fs::create_dir_all(&control_root)?;
    let evidence_path = approval_root.join(format!("{child_id}-{route_id}-approval.yml"));
    let recorded_at = now_rfc3339()?;
    fs::write(
        &evidence_path,
        format!(
            "schema_version: octon-program-lifecycle-approval-v1\nrun_id: {sanitized_run_id}\nchild_id: {child_id}\nroute_id: {route_id}\nblocker_class: {}\nregistry_digest: {}\nreason: {reason}\nrecorded_at: {recorded_at}\nresume_instruction: octon lifecycle resume --run-id {sanitized_run_id}\nretry_instruction: octon lifecycle program retry --run-id {sanitized_run_id} --child {child_id}\n",
            approval_blocker
                .blocker_class
                .as_deref()
                .unwrap_or("route-approval"),
            plan.child_registry_digest
        ),
    )?;
    let grant = ProgramApprovalGrant {
        child_id: child_id.to_string(),
        route_id: route_id.to_string(),
        blocker_class: approval_blocker.blocker_class.clone(),
        registry_digest: Some(plan.child_registry_digest.clone()),
        reason: reason.to_string(),
        recorded_at,
        evidence_path: rel_display(&repo_root, &evidence_path),
    };
    checkpoint.approvals.push(grant);
    let latest_event_offset = append_program_event(
        &control_root,
        &evidence_root,
        &sanitized_run_id,
        "approval-granted",
        Some(child_id),
        Some(route_id),
        "operator approval evidence recorded",
        event_data([
            ("reason", reason),
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
            approval_policy: "minimize".to_string(),
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
    let evidence_path = evidence_root.join("program-cancelled.yml");
    fs::write(
        &evidence_path,
        format!(
            "schema_version: octon-program-lifecycle-cancelled-v1\nrun_id: {sanitized_run_id}\nreason: {reason}\nrecorded_at: {}\n",
            now_rfc3339()?
        ),
    )?;
    let latest_event_offset = append_program_event(
        &control_root,
        &evidence_root,
        &sanitized_run_id,
        "cancel",
        None,
        None,
        "program lifecycle run cancelled",
        event_data([("reason", reason)]),
    )?;
    checkpoint.final_verdict = "cancelled".to_string();
    checkpoint.terminal_outcome = Some("cancelled".to_string());
    enrich_checkpoint_event_metadata(&mut checkpoint, &control_root)?;
    fs::write(
        program_checkpoint_path_for_run(octon_dir, &sanitized_run_id)?,
        serde_yaml::to_string(&checkpoint)?,
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
        program_blockers: plan.program_blockers,
        child_blockers,
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

fn load_program_context(
    octon_dir: &Path,
    lifecycle_id: &str,
    target: &Path,
) -> Result<ProgramContext> {
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
    if !registry_abs.is_file() {
        bail!(
            "program child registry missing for lifecycle {lifecycle_id}: {}",
            registry_abs.display()
        );
    }
    let registry: ProgramChildRegistry = serde_yaml::from_slice(&fs::read(&registry_abs)?)
        .with_context(|| format!("failed to parse child registry {}", registry_abs.display()))?;
    let registry_digest = file_digest(&registry_abs)?;
    let registry_rel = rel_display(&repo_root, &registry_abs);
    Ok(ProgramContext {
        loaded,
        target_rel,
        parent_manifest_status,
        registry_rel,
        registry_digest,
        registry,
    })
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
                bail!("child {} successor constraint must have text", child.child_id);
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
                if !matches!(claim.as_str(), "compatibility-retired" | "canonical-runtime-support")
                {
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
            blocker_class: "unsupported-mode".to_string(),
            message: "program-atomic requires program.atomic_policy".to_string(),
            recovery_route: None,
        });
        return Ok(());
    };
    if atomic_policy.eligibility != "explicit-route-opt-in" {
        program_blockers.push(ProgramBlocker {
            blocker_class: "unsupported-mode".to_string(),
            message: "program-atomic supports only explicit-route-opt-in atomic eligibility"
                .to_string(),
            recovery_route: None,
        });
        return Ok(());
    }
    if registry.schema_version != "octon-proposal-program-child-registry-v2" {
        program_blockers.push(ProgramBlocker {
            blocker_class: "unsupported-mode".to_string(),
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
                blocker_class: "write-scope-conflict".to_string(),
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
                blocker_class: "unsupported-mode".to_string(),
                message: error.to_string(),
                recovery_route: None,
            }),
        }
    }
    Ok(())
}

fn apply_closeout_policy_blockers(
    program: &ProgramSpec,
    child_states: &BTreeMap<String, ProgramChildPlanState>,
    program_blockers: &mut Vec<ProgramBlocker>,
) {
    let Some(policy) = program.closeout_policy.as_ref() else {
        return;
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
    let _ = policy.require_child_receipts_fresh;
    let _ = policy.require_aggregate_evidence;
}

fn plan_program_level_route(
    repo_root: &Path,
    context: &ProgramContext,
    program_blockers: &mut Vec<ProgramBlocker>,
) -> Result<(
    Option<RoutePlanState>,
    Vec<GatePlanResult>,
    Option<String>,
)> {
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

fn apply_dependency_blockers(child_states: &mut BTreeMap<String, ProgramChildPlanState>) {
    let completed = child_states
        .iter()
        .filter_map(|(id, state)| state.terminal_outcome.as_ref().map(|_| id.clone()))
        .collect::<BTreeSet<_>>();
    for state in child_states.values_mut() {
        if state.deferred {
            continue;
        }
        for dependency in &state.dependencies {
            if !completed.contains(dependency) {
                state.blockers.push(ProgramBlocker {
                    blocker_class: "dependency-blocked".to_string(),
                    message: format!("dependency {dependency} is not terminal"),
                    recovery_route: None,
                });
            }
        }
    }
}

fn apply_checkpoint_child_drift(
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
        if state.target != checkpoint_state.target {
            state.blockers.push(ProgramBlocker {
                blocker_class: "target-drift".to_string(),
                message: format!(
                    "child target changed from {} to {}",
                    checkpoint_state.target, state.target
                ),
                recovery_route: None,
            });
        }
        if state.receipt_digests != checkpoint_state.receipt_digests {
            state.blockers.push(ProgramBlocker {
                blocker_class: "target-drift".to_string(),
                message: "child receipt digest set changed since checkpoint".to_string(),
                recovery_route: None,
            });
        }
        if state.write_scopes != checkpoint_state.write_scopes {
            state.blockers.push(ProgramBlocker {
                blocker_class: "target-drift".to_string(),
                message: "child write scope set changed since checkpoint".to_string(),
                recovery_route: None,
            });
        }
    }
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
        let exhausted = state.blockers.iter().find_map(|blocker| {
            let budget = recovery_attempt_budget(program, &blocker.blocker_class)?;
            let attempts =
                recovery_attempt_count(checkpoint, &state.child_id, &blocker.blocker_class);
            (attempts >= budget).then(|| (blocker.blocker_class.clone(), attempts, budget))
        });
        if let Some((blocker_class, attempts, budget)) = exhausted {
            state.blockers.push(ProgramBlocker {
                blocker_class: "executor-failed".to_string(),
                message: format!(
                    "recovery budget exhausted for {blocker_class}: attempts {attempts} budget {budget}"
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
) {
    for state in child_states.values_mut() {
        let blockers = state.blockers.clone();
        for blocker in blockers {
            if blocker.blocker_class == "approval-required"
                || blocker_non_recoverable(&blocker.blocker_class)
                || !recovery_requires_approval(program, &blocker.blocker_class)
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
                existing.blocker_class == "approval-required"
                    && existing.recovery_route.as_deref() == Some(route_id)
            }) {
                continue;
            }
            state.blockers.push(ProgramBlocker {
                blocker_class: "approval-required".to_string(),
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
        for blocker in state
            .blockers
            .iter()
            .filter(|blocker| blocker.blocker_class != "approval-required")
        {
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
                        additions.push((
                            dependent.child_id.clone(),
                            ProgramBlocker {
                                blocker_class: "dependency-blocked".to_string(),
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
                                blocker_class: "dependency-blocked".to_string(),
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
                        blocker_class: "dependency-blocked".to_string(),
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
                runnable_child(child_states, &child.child_id).then(|| child.child_id.clone())
            })
            .take(1)
            .collect::<Vec<_>>(),
        "gated-parallel" => gated_parallel_candidates(registry, child_states),
        "approval-gated" | "parallel-independent" | "program-atomic" => registry
            .children
            .iter()
            .filter_map(|child| {
                runnable_child(child_states, &child.child_id).then(|| child.child_id.clone())
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

fn runnable_child(child_states: &BTreeMap<String, ProgramChildPlanState>, child_id: &str) -> bool {
    child_states
        .get(child_id)
        .map(|state| {
            !state.deferred
                && state.required
                && state.terminal_outcome.is_none()
                && state.selected_route.is_some()
                && state.blockers.iter().all(blocker_allows_child_route)
        })
        .unwrap_or(false)
}

fn blocker_allows_child_route(blocker: &ProgramBlocker) -> bool {
    blocker.recovery_route.is_some()
        && matches!(
            blocker.blocker_class.as_str(),
            "stale-receipt" | "validation-failed" | "missing-evidence"
        )
}

fn gated_parallel_candidates(
    registry: &ProgramChildRegistry,
    child_states: &BTreeMap<String, ProgramChildPlanState>,
) -> Vec<String> {
    let next_phase = registry.children.iter().find_map(|child| {
        let state = child_states.get(&child.child_id)?;
        if state.terminal_outcome.is_none() && !state.deferred {
            Some(
                child
                    .phase_id
                    .clone()
                    .or_else(|| child.group_id.clone())
                    .unwrap_or_else(|| "default".to_string()),
            )
        } else {
            None
        }
    });
    registry
        .children
        .iter()
        .filter(|child| {
            next_phase.as_ref().map_or(false, |phase| {
                child.phase_id.as_ref().or(child.group_id.as_ref()) == Some(phase)
                    || (phase == "default" && child.phase_id.is_none() && child.group_id.is_none())
            })
        })
        .filter_map(|child| {
            runnable_child(child_states, &child.child_id).then(|| child.child_id.clone())
        })
        .collect()
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
                continue;
            }
            if let Some(state) = child_states.get_mut(&child_id) {
                state.blockers.push(ProgramBlocker {
                    blocker_class: "write-scope-conflict".to_string(),
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
) -> Result<Vec<ProgramApprovalBlocker>> {
    let mut blockers = Vec::new();
    for state in child_states.values() {
        if let Some(route) = state.selected_route.as_ref() {
            let loaded = load_lifecycle_contract(octon_dir, &state.child_lifecycle_id)?;
            if let Some(route_spec) = route_by_id(&loaded.contract, &route.route_id) {
                let required = route_spec
                    .approval
                    .as_ref()
                    .map(|approval| approval.required_by_default)
                    .unwrap_or(false)
                    || route_spec.route_type == "workflow";
                let route_approval_granted = approval_granted(
                    approvals,
                    &state.child_id,
                    &route.route_id,
                    Some(registry_digest),
                    None,
                );
                if required && !route_approval_granted {
                    blockers.push(ProgramApprovalBlocker {
                        child_id: state.child_id.clone(),
                        route_id: route.route_id.clone(),
                        blocker_class: None,
                        reason: route_spec
                            .approval
                            .as_ref()
                            .and_then(|approval| approval.reason.clone())
                            .unwrap_or_else(|| "durable child route requires approval".to_string()),
                    });
                }
            }
        }
        for blocker in state
            .blockers
            .iter()
            .filter(|blocker| blocker.blocker_class != "approval-required")
        {
            if !recovery_requires_approval(program, &blocker.blocker_class) {
                continue;
            }
            let Some(recovery_route) = recovery_route_for_blocker(program, blocker) else {
                continue;
            };
            if approval_granted(
                approvals,
                &state.child_id,
                recovery_route,
                Some(registry_digest),
                Some(&blocker.blocker_class),
            ) {
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

fn approval_policy_for_child_route(
    default_policy: &str,
    approvals: Option<&Vec<ProgramApprovalGrant>>,
    child_id: &str,
    route_id: &str,
    registry_digest: Option<&str>,
    blocker_class: Option<&str>,
) -> String {
    if default_policy == "unattended" {
        "unattended".to_string()
    } else if approval_granted(
        approvals,
        child_id,
        route_id,
        registry_digest,
        blocker_class,
    ) {
        "program-approved".to_string()
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
        .with_context(|| format!("missing approval grant for child route {child_id}:{route_id}"))?;
    fs::create_dir_all(child_evidence_root)?;
    let path = child_evidence_root.join(format!("{route_id}-program-approval-consumed.yml"));
    fs::write(
        path,
        format!(
            "schema_version: octon-program-lifecycle-approval-consumed-v1\nprogram_run_id: {program_run_id}\nchild_id: {child_id}\nroute_id: {route_id}\nblocker_class: {}\nregistry_digest: {}\napproval_grant_ref: {}\napproval_reason: {}\nrecorded_at: {}\nauthorization_source: program-operator-approval-grant\n",
            grant.blocker_class.as_deref().unwrap_or("route-approval"),
            grant.registry_digest.as_deref().unwrap_or("legacy-approval"),
            grant.evidence_path,
            grant.reason,
            now_rfc3339()?
        ),
    )?;
    let _ = repo_root;
    Ok(())
}

fn aggregate_program_state(
    child_states: &BTreeMap<String, ProgramChildPlanState>,
    program_blockers: &[ProgramBlocker],
    runnable_batch: &[String],
) -> (String, String) {
    if program_blockers.iter().any(|blocker| {
        matches!(
            blocker.blocker_class.as_str(),
            "unsupported-mode" | "authority-boundary-ambiguous" | "write-scope-conflict"
        )
    }) {
        return ("blocked-unsafe".to_string(), "blocked-unsafe".to_string());
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
        matches!(
            blocker.blocker_class.as_str(),
            "unsafe-resume" | "unsupported-mode" | "authority-boundary-ambiguous"
        )
    }) {
        return ("blocked-unsafe".to_string(), "blocked-unsafe".to_string());
    }
    if blockers
        .iter()
        .any(|blocker| blocker.blocker_class == "approval-required")
    {
        return ("blocked-human".to_string(), "blocked-human".to_string());
    }
    if runnable_batch.is_empty() && !blockers.is_empty() {
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

fn filter_plan_to_child(plan: &mut ProgramLifecyclePlanResult, child_id: &str) -> Result<()> {
    if !plan.child_states.contains_key(child_id) {
        bail!("program plan has no child {child_id}");
    }
    if plan.runnable_batch.iter().any(|id| id == child_id) {
        plan.runnable_batch.retain(|id| id == child_id);
        Ok(())
    } else {
        bail!("program child {child_id} is not currently runnable")
    }
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
) -> Result<Vec<ChildExecutionJob>> {
    let mut jobs = Vec::new();
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
            let approval_policy = approval_policy_for_child_route(
                &options.approval_policy,
                approvals,
                child_id,
                &route.route_id,
                Some(&plan.child_registry_digest),
                blocker_class.as_deref(),
            );
            if approval_policy == "program-approved" {
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
            let request = lifecycle_execution_request_for_route(
                octon_dir,
                &child_run_id,
                &state.child_lifecycle_id,
                &state.target,
                route,
                options.executor,
                options.timeout_seconds.unwrap_or(1800),
                &approval_policy,
                0,
                run_inputs,
                child_evidence_root,
                child_control_root.join("lifecycle-checkpoint.yml"),
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
    Ok(jobs)
}

fn selected_route_for_child_execution(
    octon_dir: &Path,
    options: &RunLifecycleOptions,
    state: &ProgramChildPlanState,
    approvals: Option<&Vec<ProgramApprovalGrant>>,
    registry_digest: &str,
) -> Result<(Option<RoutePlanState>, Option<String>)> {
    let Some(blocker) = state.blockers.iter().find(|blocker| {
        blocker.recovery_route.is_some()
            && blocker.blocker_class != "approval-required"
            && !blocker_non_recoverable(&blocker.blocker_class)
    }) else {
        return Ok((state.selected_route.clone(), None));
    };
    let loaded = load_lifecycle_contract(octon_dir, &options.lifecycle_id)?;
    let Some(program) = loaded.contract.program.as_ref() else {
        return Ok((state.selected_route.clone(), None));
    };
    if blocker_non_recoverable(&blocker.blocker_class) {
        return Ok((None, Some(blocker.blocker_class.clone())));
    }
    validate_recovery_recipe(program, &blocker.blocker_class, state)?;
    let route_id =
        recovery_route_id(program, &blocker.blocker_class).or(blocker.recovery_route.as_ref());
    let Some(route_id) = route_id else {
        return Ok((state.selected_route.clone(), None));
    };
    if recovery_requires_approval(program, &blocker.blocker_class)
        && options.approval_policy != "unattended"
        && !approval_granted(
            approvals,
            &state.child_id,
            route_id,
            Some(registry_digest),
            Some(&blocker.blocker_class),
        )
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

fn recovery_route_for_blocker<'a>(
    program: &'a ProgramSpec,
    blocker: &'a ProgramBlocker,
) -> Option<&'a str> {
    recovery_route_id(program, &blocker.blocker_class)
        .map(String::as_str)
        .or(blocker.recovery_route.as_deref())
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
        .map(|recipe| recipe.approval_required)
        .or_else(|| {
            program
                .recovery_policy
                .handlers
                .get(blocker_class)
                .map(|handler| handler.approval_required)
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
    matches!(
        blocker_class,
        "unsafe-resume" | "authority-boundary-ambiguous"
    )
}

fn recovery_attempt_key(child_id: &str, blocker_class: &str) -> String {
    format!("{child_id}:{blocker_class}")
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

fn validate_recovery_recipe(
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
    if recipe
        .idempotency_class
        .as_deref()
        .map(|class| class == "non-idempotent" || class == "unsafe")
        .unwrap_or(false)
    {
        bail!("recovery recipe for {blocker_class} is not executable because it is non-idempotent");
    }
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
            "approval-grant-present" => {
                bail!("recovery recipe precondition approval-grant-present is not automatically recoverable");
            }
            other => bail!("unsupported recovery recipe precondition: {other}"),
        }
    }
    for validation in &recipe.post_attempt_validation {
        if !matches!(
            validation.as_str(),
            "replan-live-state"
                | "receipt-fresh"
                | "receipt-freshness"
                | "blocker-cleared"
                | "replay-verify"
                | "authority-boundary-check"
                | "aggregate-closeout-check"
        ) {
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
    Ok(())
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
        "replay-verify" => verify_program_event_log_for_recovery(control_root).is_ok(),
        _ => false,
    }
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
    if !plan.approval_blockers.is_empty() && options.approval_policy != "unattended" {
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
                status: "approval-required".to_string(),
                attempts: 0,
                retryable: false,
                blocker_class: Some("approval-required".to_string()),
                error_message: Some(blocker.reason.clone()),
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
    let approval_policy = approval_policy_for_child_route(
        &options.approval_policy,
        approvals,
        &state.child_id,
        route_id,
        None,
        None,
    );
    if approval_policy == "program-approved" {
        write_program_approval_execution_evidence(
            &repo_root_for_octon(octon_dir)?,
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
        &approval_policy,
        0,
        run_inputs,
        child_evidence_root,
        child_control_root.join("lifecycle-checkpoint.yml"),
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
        error_message: result.error_message,
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
        match fs::remove_file(&lock_path) {
            Ok(()) => {}
            Err(error) if error.kind() == std::io::ErrorKind::NotFound => {}
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
        }
        append_program_event(
            control_root,
            evidence_root,
            program_run_id,
            "atomic-lock-released",
            Some(&child_id),
            None,
            "program-atomic released child lock",
            BTreeMap::new(),
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
                if job.blocker_class.is_some() {
                    "recovery-attempt"
                } else {
                    "child-route-started"
                },
                Some(&job.child_id),
                Some(&job.route_id),
                "child route execution started",
                BTreeMap::new(),
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
            let summary =
                finish_child_execution(control_root, evidence_root, program_run_id, outcome)?;
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
        event_data([
            ("status", summary.status.as_str()),
            ("attempts", attempts.as_str()),
        ]),
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
                return Ok(ChildExecutionOutcome {
                    summary: ProgramChildExecutionSummary {
                        child_id: job.child_id,
                        child_run_id: job.child_run_id,
                        route_id: job.route_id,
                        status: "failed".to_string(),
                        attempts,
                        retryable: false,
                        blocker_class: job.blocker_class,
                        error_message: Some(error.to_string()),
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
    Ok(ChildExecutionOutcome {
        summary: ProgramChildExecutionSummary {
            child_id: job.child_id,
            child_run_id: job.child_run_id,
            route_id: job.route_id,
            status: result.status,
            attempts,
            retryable: result.retryable,
            blocker_class: job.blocker_class,
            error_message: result.error_message,
        },
        lock_path: job.lock_path,
    })
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
    match fs::remove_file(lock_path) {
        Ok(()) => {
            append_program_event(
                control_root,
                evidence_root,
                program_run_id,
                "child-lock-released",
                Some(child_id),
                Some(route_id),
                "program child execution lock released",
                BTreeMap::new(),
            )?;
            Ok(())
        }
        Err(error) => {
            let message = format!(
                "program child execution lock could not be released: {}",
                error
            );
            append_program_event(
                control_root,
                evidence_root,
                program_run_id,
                "child-lock-stale",
                Some(child_id),
                Some(route_id),
                &message,
                event_data([("status", "blocked-unsafe")]),
            )?;
            bail!("{message}");
        }
    }
}

fn checkpoint_from_plan(
    run_id: &str,
    lifecycle_id: &str,
    target: &str,
    executor: ExecutorKind,
    run_inputs: &BTreeMap<String, String>,
    plan: &ProgramLifecyclePlanResult,
    child_results: &[ProgramChildExecutionSummary],
    final_verdict: &str,
    terminal_outcome: Option<String>,
    latest_event_offset: u64,
    mut previous_recovery_attempts: BTreeMap<String, u32>,
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
    }

    ProgramLifecycleCheckpoint {
        schema_version: "octon-program-lifecycle-checkpoint-v1".to_string(),
        run_id: run_id.to_string(),
        lifecycle_id: lifecycle_id.to_string(),
        target: target.to_string(),
        executor: Some(executor.as_str().to_string()),
        child_registry_digest: plan.child_registry_digest.clone(),
        execution_mode: plan.execution_mode.clone(),
        run_inputs: run_inputs.clone(),
        scheduler_decision: plan.runnable_batch.clone(),
        child_states,
        recovery_attempts: previous_recovery_attempts,
        approvals,
        latest_event_offset,
        latest_event_index: latest_event_offset,
        latest_event_sha256: None,
        event_log_sha256: None,
        derived_from_event_index: latest_event_offset,
        atomic_barrier_state: None,
        terminal_outcome,
        final_verdict: final_verdict.to_string(),
        resume_instruction: format!("octon lifecycle resume --run-id {run_id}"),
    }
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

fn validate_program_checkpoint_binding(
    checkpoint: &ProgramLifecycleCheckpoint,
    sanitized_run_id: &str,
    lifecycle_id: &str,
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
    if checkpoint.child_registry_digest != child_registry_digest {
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
    if plan
        .program_blockers
        .iter()
        .any(|blocker| blocker.blocker_class == "authority-boundary-ambiguous")
    {
        bail!("program closeout blocked: unresolved program authority ambiguity");
    }
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
        verify_child_receipts_for_closeout(octon_dir, &repo_root, state)?;
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

fn verify_child_receipts_for_closeout(
    octon_dir: &Path,
    repo_root: &Path,
    state: &ProgramChildPlanState,
) -> Result<()> {
    let child_contract = load_lifecycle_contract(octon_dir, &state.child_lifecycle_id)?;
    let child_target_abs = resolve_lifecycle_target_path(repo_root, Path::new(&state.target))?;
    if child_contract.contract.receipts.is_empty() {
        return Ok(());
    }
    let live_plan = plan_lifecycle_from_octon_dir(
        octon_dir,
        &state.child_lifecycle_id,
        Path::new(&state.target),
    )?;
    for receipt in &child_contract.contract.receipts {
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
    format!(
        "# Program Lifecycle Run\n\nrun_id: {run_id}\nrecorded_at: {}\nlifecycle_id: {}\ntarget: {}\nexecutor: {}\nexecution_mode: {}\nrunnable_children: {}\naggregate_state: {}\nfinal_verdict: {final_verdict}\n\nProgram evidence coordinates child lifecycle work only. Child packet manifests, receipts, promotion targets, validation verdicts, and archive metadata remain child-owned.\n",
        now_rfc3339().unwrap_or_else(|_| "unknown".to_string()),
        plan.lifecycle_id,
        plan.target,
        executor.as_str(),
        plan.execution_mode,
        plan.runnable_batch.join(", "),
        plan.aggregate_state,
    )
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::time::{SystemTime, UNIX_EPOCH};

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
    enter_when: { manifest_status: "accepted" }
    completion:
      expected_receipts: ["implementation-run"]
"#,
            );
        }

        fn write_child_contract_with_approval(&self) {
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
    completion:
      expected_receipts: ["implementation-run"]
    approval:
      required_by_default: true
      reason: "child route mutates a durable target"
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
    enter_when: {{ manifest_status: "accepted" }}
    atomic:
      stage_route_id: "atomic-stage"
      commit_route_id: "atomic-commit"
      rollback_route_id: "atomic-rollback"
{compensation_field}  - route_id: "atomic-stage"
    route_type: "extension"
    completion:
      {stage_completion}
  - route_id: "atomic-commit"
    route_type: "extension"
    completion:
      {commit_completion}
  - route_id: "atomic-rollback"
    route_type: "extension"
    completion:
      expected_manifest_status: "accepted"
  - route_id: "atomic-compensate"
    route_type: "extension"
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
    enter_when:
      all:
        - manifest_status: "accepted"
        - receipt_absent: "program-implementation-prompt"
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
routes:
  - route_id: "generate-program-implementation-prompt"
    route_type: "extension"
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
        approval_required: false
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
"#,
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
        approval_required: true
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
        approval_required: true
        replan_after_attempt: true
  authority_boundaries:
    parent_coordinates_only: true
    child_receipts_remain_child_owned: true
    child_promotion_targets_remain_child_owned: true
states: [{ state_id: "coordinate" }]
routes:
  - route_id: "generate-program-implementation-prompt"
    route_type: "extension"
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
        approval_required: false
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
            blocker.blocker_class == "validation-failed"
                && blocker
                    .message
                    .contains("generate-program-implementation-prompt")
        }));
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
            .any(|blocker| blocker.blocker_class == "dependency-blocked"));
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
    fn approval_gated_planning_reports_approval_blockers() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("approval-gated", true);
        fixture.write_child_contract_with_approval();
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
    fn approval_grant_is_consumed_by_retry_without_unattended_cli_policy() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("approval-consumed", true);
        fixture.write_child_contract_with_approval();
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
                approval_policy: "minimize".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();
        assert!(first
            .child_results
            .iter()
            .any(|summary| summary.status == "approval-required"));
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
            .join("state/evidence/runs/workflows/approval-consumed/children/a/run-implementation-program-approval-consumed.yml")
            .is_file());
        assert!(fixture
            .octon_dir
            .join("state/evidence/runs/workflows/approval-consumed/children/a/run-implementation-approval-override.yml")
            .is_file());
    }

    #[test]
    fn approval_grant_is_consumed_by_resume_without_unattended_cli_policy() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("approval-resume", true);
        fixture.write_child_contract_with_approval();
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
                approval_policy: "minimize".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();
        assert!(first
            .child_results
            .iter()
            .any(|summary| summary.status == "approval-required"));

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
        assert!(plan.runnable_batch.is_empty());
        assert_eq!(plan.final_verdict, "blocked-human");
        assert_eq!(plan.approval_blockers.len(), 1);
        assert_eq!(
            plan.approval_blockers[0].blocker_class.as_deref(),
            Some("stale-receipt")
        );

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
                approval_policy: "minimize".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();
        assert!(first.child_results.is_empty());

        approve_program_lifecycle_child_route(
            &fixture.octon_dir,
            "recovery-approval",
            "a",
            "run-implementation",
            "operator approved recovery route",
        )
        .unwrap();
        let retry =
            retry_program_lifecycle_run(&fixture.octon_dir, "recovery-approval", Some("a".into()))
                .unwrap();
        assert!(retry
            .child_results
            .iter()
            .any(
                |summary| summary.blocker_class.as_deref() == Some("stale-receipt")
                    && summary.route_id == "run-implementation"
            ));
        assert!(fixture
            .octon_dir
            .join("state/evidence/runs/workflows/recovery-approval/children/a/run-implementation-program-approval-consumed.yml")
            .is_file());
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
        assert!(recovery_requires_approval(&program, "stale-receipt"));
        assert!(recovery_replan_after_attempt(&program, "stale-receipt"));
        assert!(plan.runnable_batch.is_empty());
        assert_eq!(plan.final_verdict, "blocked-human");
        assert_eq!(
            plan.approval_blockers[0].blocker_class.as_deref(),
            Some("stale-receipt")
        );

        let mut checkpoint = checkpoint_from_plan(
            "recovery-handler-only-budget",
            "proposal-program",
            "parent",
            ExecutorKind::Mock,
            &BTreeMap::new(),
            &plan,
            &[],
            &plan.final_verdict,
            None,
            0,
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
                approval_policy: "minimize".to_string(),
                run_inputs: BTreeMap::new(),
                program_child_filter: None,
            },
        )
        .unwrap();
        assert!(first.child_results.is_empty());

        approve_program_lifecycle_child_route(
            &fixture.octon_dir,
            "recovery-handler-only-exec",
            "a",
            "run-implementation",
            "operator approved handler recovery route",
        )
        .unwrap();
        let retry = retry_program_lifecycle_run(
            &fixture.octon_dir,
            "recovery-handler-only-exec",
            Some("a".into()),
        )
        .unwrap();

        assert!(retry.child_results.iter().any(|summary| {
            summary.blocker_class.as_deref() == Some("stale-receipt")
                && summary.route_id == "run-implementation"
                && summary.status == "completed"
        }));
        assert!(fixture
            .octon_dir
            .join("state/evidence/runs/workflows/recovery-handler-only-exec/children/a/run-implementation-program-approval-consumed.yml")
            .is_file());
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

        let error = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap_err();

        assert!(error
            .to_string()
            .contains("program-atomic requires octon-proposal-program-child-registry-v2"));
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
                approval_policy: "minimize".to_string(),
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
    fn program_operator_controls_use_checkpointed_event_log() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = ProgramFixture::new("operator-control", true);
        fixture.write_child_contract_with_approval();
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
                approval_policy: "minimize".to_string(),
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
                approval_policy: "minimize".to_string(),
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
                approval_policy: "minimize".to_string(),
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
                    approval_policy: "minimize".to_string(),
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
                approval_policy: "minimize".to_string(),
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
                approval_policy: "minimize".to_string(),
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
                approval_policy: "minimize".to_string(),
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
                approval_policy: "minimize".to_string(),
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
                approval_policy: "minimize".to_string(),
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
                approval_policy: "minimize".to_string(),
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
                approval_policy: "minimize".to_string(),
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
                approval_policy: "minimize".to_string(),
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

        assert_eq!(plan.final_verdict, "blocked-recoverable");
        assert!(plan
            .child_states
            .get("a")
            .unwrap()
            .blockers
            .iter()
            .any(|blocker| blocker.blocker_class == "stale-receipt"));
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
            "status: accepted\nchild_promotion_targets:\n  a:\n    - framework/a.md\n",
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
                approval_policy: "minimize".to_string(),
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
                "status: accepted\nchild_validation_verdicts:\n  a: pass\n",
                None,
                "child-owned surface child_validation_verdicts",
            ),
            (
                "evidence",
                "status: accepted\n",
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
                    approval_policy: "minimize".to_string(),
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
                approval_policy: "minimize".to_string(),
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
                approval_policy: "minimize".to_string(),
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
                approval_policy: "minimize".to_string(),
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
                approval_policy: "minimize".to_string(),
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
                approval_policy: "minimize".to_string(),
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
            .any(|blocker| blocker.blocker_class == "write-scope-conflict"));
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
            .all(|blocker| blocker.blocker_class != "write-scope-conflict"));
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

        let error = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap_err();

        assert!(error.to_string().contains("dependency cycle"));
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
            &BTreeMap::new(),
            &plan,
            &[],
            &plan.final_verdict,
            None,
            0,
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
            .any(|blocker| blocker.blocker_class == "target-drift"));
        assert_eq!(replanned.final_verdict, "blocked-recoverable");
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
            &BTreeMap::new(),
            &plan,
            &[],
            &plan.final_verdict,
            None,
            0,
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
                approval_policy: "minimize".to_string(),
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
                    approval_policy: "minimize".to_string(),
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
        approval_required: false
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
                approval_policy: "minimize".to_string(),
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
            contract_path: "test".to_string(),
            target: "parent".to_string(),
            parent_manifest_status: Some("accepted".to_string()),
            child_registry_path: "parent/resources/child-packet-index.yml".to_string(),
            child_registry_schema_version: "octon-proposal-program-child-registry-v1".to_string(),
            child_registry_digest: "sha256:test".to_string(),
            execution_mode: "parallel-independent".to_string(),
            aggregate_state: "planned".to_string(),
            program_route: None,
            program_gate_results: Vec::new(),
            blocked_by_program_gate: None,
            program_blockers: Vec::new(),
            child_states,
            runnable_batch: vec!["a".to_string(), "b".to_string()],
            approval_blockers: Vec::new(),
            checkpoint_drift: None,
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
                approval_policy: "minimize".to_string(),
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
            },
            lock_path: lock_path.clone(),
        };

        let error = finish_child_execution(
            &control_root,
            &evidence_root,
            "lock-finish-event-failure",
            outcome,
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
            },
            lock_path: lock_path.clone(),
        };

        let error = finish_child_execution(
            &control_root,
            &evidence_root,
            "lock-release-failure",
            outcome,
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

            let error = plan_program_lifecycle_from_octon_dir(
                &fixture.octon_dir,
                "proposal-program",
                Path::new("parent"),
            )
            .unwrap_err();

            assert!(
                error.to_string().contains(expected),
                "{name} error should mention {expected}: {error}"
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
        let error = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap_err();
        assert!(error.to_string().contains("default_child_lifecycle_id"));
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

        let error = plan_program_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-program",
            Path::new("parent"),
        )
        .unwrap_err();

        assert!(error.to_string().contains("rollback_posture"));
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
                    approval_policy: "minimize".to_string(),
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
                approval_policy: "minimize".to_string(),
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
