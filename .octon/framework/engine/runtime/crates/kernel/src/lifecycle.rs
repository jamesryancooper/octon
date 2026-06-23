use crate::workflow::ExecutorKind;
use crate::{LifecycleCmd, LifecycleProgramCmd};
use anyhow::{bail, Context, Result};
use octon_authority_engine::now_rfc3339;
use octon_core::root::RootResolver;
use octon_lifecycle_executor::{
    default_bound_inputs, LifecycleDelegationContract, LifecycleExecutionPolicy,
    LifecycleHumanBoundaryContext, LifecycleInvocationAuthority, LifecycleReceiptSpec,
    LifecycleRouteExecutionRequest, LifecycleRouteSpec,
};
use octon_runtime_resolver::{
    generated_effective_extension_catalog_path, runtime_effective_route_bundle_path,
};
use serde::{Deserialize, Serialize};
use serde_yaml::Value;
use sha2::{Digest, Sha256};
use std::collections::{BTreeMap, BTreeSet};
use std::fs::{self, OpenOptions};
use std::io::Write;
use std::path::{Component, Path, PathBuf};
use std::process::Command as ProcessCommand;

#[path = "lifecycle_program.rs"]
mod lifecycle_program;

const GENERATED_EXTENSION_PUBLISHED_PREFIX: &str =
    ".octon/generated/effective/extensions/published/";
const FRAMEWORK_ASSURANCE_SCRIPT_PREFIX: &str = ".octon/framework/assurance/runtime/_ops/scripts/";
const WORKFLOW_EVIDENCE_ROOT_REL: &str = "state/evidence/runs/workflows";
const RUN_CONTROL_ROOT_REL: &str = "state/control/execution/runs";
const ROUTE_ID_CLOSEOUT_PACKET: &str = "closeout-packet";
const ROUTE_PROGRESSION_STRATEGY: &str = "route-progression";
const ORCHESTRATED_REPLAN_LOOP_STRATEGY: &str = "orchestrated-replan-loop";
const LIFECYCLE_EVENT_SCHEMA_VERSION: &str = "octon-lifecycle-run-event-v1";
const LIFECYCLE_EVENT_FILE: &str = "lifecycle-events.ndjson";
const LIFECYCLE_CANCELLATION_FILE: &str = "cancellation.yml";
const LIFECYCLE_CANCELLED_EVIDENCE_FILE: &str = "lifecycle-cancelled.yml";

#[derive(Clone, Copy, Debug, Deserialize, Eq, PartialEq, Serialize)]
#[serde(rename_all = "kebab-case")]
pub(crate) enum LifecycleExecutionStrategy {
    RouteProgression,
    OrchestratedReplanLoop,
}

impl LifecycleExecutionStrategy {
    pub(crate) fn as_str(self) -> &'static str {
        match self {
            LifecycleExecutionStrategy::RouteProgression => ROUTE_PROGRESSION_STRATEGY,
            LifecycleExecutionStrategy::OrchestratedReplanLoop => ORCHESTRATED_REPLAN_LOOP_STRATEGY,
        }
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) enum LifecycleStopClass {
    Completed,
    RouteReady,
    Planned,
    BlockedRecoverable,
    BlockedHuman,
    BlockedUnsafe,
    BlockedMaxSteps,
    Failed,
    TimedOut,
    Cancelled,
}

impl LifecycleStopClass {
    pub(crate) fn is_terminal_or_blocked(self) -> bool {
        !matches!(
            self,
            LifecycleStopClass::RouteReady | LifecycleStopClass::Planned
        )
    }
}

pub(crate) fn classify_lifecycle_status(status: &str) -> LifecycleStopClass {
    match status {
        "completed" | "terminal" | "no-op" | "skipped-idempotent" => LifecycleStopClass::Completed,
        "route-ready"
        | "gate-rerouted"
        | "runnable"
        | "mock-route-executed"
        | "adapter-executed" => LifecycleStopClass::RouteReady,
        "planned" | "partial" | "program-route-ready" => LifecycleStopClass::Planned,
        "blocked-human" | "human-boundary-blocked" => LifecycleStopClass::BlockedHuman,
        "blocked-recoverable"
        | "blocked"
        | "authorization-proof-failed"
        | "blocked-no-route"
        | "blocked-gate"
        | "blocked-max-iterations" => LifecycleStopClass::BlockedRecoverable,
        "blocked-unsafe" => LifecycleStopClass::BlockedUnsafe,
        "blocked-max-steps" => LifecycleStopClass::BlockedMaxSteps,
        "failed" => LifecycleStopClass::Failed,
        "timed-out" => LifecycleStopClass::TimedOut,
        "cancelled" => LifecycleStopClass::Cancelled,
        _ => LifecycleStopClass::BlockedUnsafe,
    }
}

pub(crate) struct LifecycleStepBudget {
    max_steps: u32,
    steps_used: u32,
}

impl LifecycleStepBudget {
    pub(crate) fn new(max_steps: u32) -> Self {
        Self {
            max_steps,
            steps_used: 0,
        }
    }

    pub(crate) fn exhausted(&self) -> bool {
        self.steps_used >= self.max_steps
    }

    pub(crate) fn step_index(&self) -> u32 {
        self.steps_used
    }

    pub(crate) fn step_number(&self) -> u32 {
        self.steps_used.saturating_add(1)
    }

    pub(crate) fn consume_dispatch(&mut self) {
        self.steps_used = self.steps_used.saturating_add(1);
    }

    pub(crate) fn steps_used(&self) -> u32 {
        self.steps_used
    }
}

#[derive(Clone, Debug, Deserialize, Serialize)]
struct LifecycleRunEvent {
    schema_version: String,
    run_id: String,
    lifecycle_id: String,
    execution_strategy: String,
    target: String,
    event_index: u64,
    previous_event_sha256: Option<String>,
    event_sha256: Option<String>,
    event_type: String,
    event_category: String,
    recorded_at: String,
    actor: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    step_index: Option<u32>,
    #[serde(skip_serializing_if = "Option::is_none")]
    step_number: Option<u32>,
    #[serde(skip_serializing_if = "Option::is_none")]
    step_kind: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    route_id: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    phase_id: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    transition_id: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    child_id: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    final_verdict: Option<String>,
    #[serde(default)]
    data: BTreeMap<String, String>,
}

#[derive(Clone, Debug)]
pub(crate) struct RunLifecycleOptions {
    pub lifecycle_id: String,
    pub target: PathBuf,
    pub run_id: Option<String>,
    pub executor: ExecutorKind,
    pub max_iterations: Option<u32>,
    pub execute_routes: bool,
    pub max_steps: Option<u32>,
    pub timeout_seconds: Option<u64>,
    pub max_child_concurrency: Option<usize>,
    pub invocation_authority: String,
    pub run_inputs: BTreeMap<String, String>,
    pub program_child_filter: Option<String>,
}

#[derive(Clone, Debug, Serialize)]
pub(crate) struct LifecyclePlanResult {
    pub schema_version: String,
    pub lifecycle_id: String,
    pub owner_extension: String,
    pub execution_strategy: String,
    pub contract_path: String,
    pub target: String,
    pub target_exists: bool,
    pub manifest_status: Option<String>,
    pub receipt_states: BTreeMap<String, ReceiptPlanState>,
    pub terminal_outcome: Option<String>,
    pub next_route: Option<RoutePlanState>,
    pub gate_results: Vec<GatePlanResult>,
    pub blocked_by_gate: Option<String>,
    pub checkpoint_drift: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub phase_loop_model: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub current_phase: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "BTreeMap::is_empty")]
    pub phase_blockers: BTreeMap<String, String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub blocker_class: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub blocker_message: Option<String>,
    pub final_verdict: String,
}

#[derive(Clone, Debug, Serialize)]
pub(crate) struct RoutePlanState {
    pub route_id: String,
    pub route_type: String,
    pub command_id: Option<String>,
    pub skill_id: Option<String>,
    pub prompt_set_id: Option<String>,
}

#[derive(Clone, Debug, Serialize)]
pub(crate) struct ReceiptPlanState {
    pub path: String,
    pub exists: bool,
    pub verdict: Option<String>,
    #[serde(default)]
    pub fields: BTreeMap<String, String>,
    pub missing_required_fields: Vec<String>,
    pub stale: Option<bool>,
    pub stored_digest: Option<String>,
    pub current_digest: Option<String>,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
pub(crate) struct GatePlanResult {
    pub gate_id: String,
    pub validator_id: String,
    pub passed: bool,
    pub exit_code: Option<i32>,
    pub stdout: String,
    pub stderr: String,
}

#[derive(Clone, Debug, Serialize)]
pub(crate) struct LifecycleRunResult {
    pub schema_version: String,
    pub run_id: String,
    pub lifecycle_id: String,
    pub execution_strategy: String,
    pub target: String,
    pub executor: String,
    pub route_execution_mode: String,
    pub bundle_root: String,
    pub checkpoint_path: String,
    pub selected_route: Option<RoutePlanState>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub current_phase: Option<String>,
    pub terminal_outcome: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Vec::is_empty")]
    pub interaction_request_refs: Vec<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Vec::is_empty")]
    pub interaction_return_refs: Vec<String>,
    pub final_verdict: String,
}

#[derive(Clone, Debug, Deserialize)]
struct LifecycleContract {
    lifecycle_id: String,
    owner_extension: String,
    #[serde(default)]
    execution_strategy: Option<LifecycleExecutionStrategy>,
    target: TargetSpec,
    #[serde(default)]
    terminal_outcomes: Vec<TerminalOutcomeSpec>,
    #[serde(default)]
    validators: Vec<ValidatorSpec>,
    #[serde(default)]
    gates: Vec<GateSpec>,
    #[serde(default)]
    receipts: Vec<ReceiptSpec>,
    #[serde(default)]
    loops: Vec<LoopSpec>,
    #[serde(default)]
    phase_loop: Option<PhaseLoopSpec>,
    #[serde(default)]
    routes: Vec<RouteSpec>,
    #[serde(default)]
    input_bindings: BTreeMap<String, InputBindingSpec>,
    #[serde(default)]
    program: Option<ProgramSpec>,
}

#[derive(Clone, Debug, Deserialize)]
struct ProgramSpec {
    child_registry_path: String,
    #[serde(default)]
    child_lifecycle_id_default: Option<String>,
    #[serde(default)]
    supported_execution_modes: Vec<String>,
    #[serde(default)]
    atomic_policy: Option<ProgramAtomicPolicySpec>,
    #[serde(default)]
    recovery_policy: ProgramRecoveryPolicySpec,
    #[serde(default)]
    closeout_policy: Option<ProgramCloseoutPolicySpec>,
    #[serde(default)]
    authority_boundaries: ProgramAuthorityBoundarySpec,
}

#[derive(Clone, Debug, Default, Deserialize)]
struct ProgramAtomicPolicySpec {
    eligibility: String,
    #[serde(default = "default_true")]
    require_declared_write_scopes: bool,
}

fn default_true() -> bool {
    true
}

fn default_route_progression_execution_strategy() -> String {
    LifecycleExecutionStrategy::RouteProgression
        .as_str()
        .to_string()
}

#[derive(Clone, Debug, Deserialize)]
struct PhaseLoopSpec {
    model_version: String,
    #[serde(default)]
    phases: Vec<PhaseSpec>,
}

#[derive(Clone, Debug, Default, Deserialize)]
#[allow(dead_code)]
struct PhaseSpec {
    phase_id: String,
    #[serde(default)]
    mode: String,
    #[serde(default)]
    owner_layer: String,
    #[serde(default)]
    route_refs: Vec<String>,
    #[serde(default)]
    receipt_refs: Vec<String>,
    #[serde(default)]
    gate_refs: Vec<String>,
    #[serde(default)]
    validator_refs: Vec<String>,
    #[serde(default)]
    loop_refs: Vec<String>,
    #[serde(default)]
    terminal_refs: Vec<String>,
    #[serde(default)]
    exit_evidence_refs: Vec<String>,
    #[serde(default)]
    re_entry_triggers: Vec<String>,
    #[serde(default)]
    backward_transitions: Vec<PhaseTransitionSpec>,
    #[serde(default)]
    loop_bounds: PhaseLoopBoundsSpec,
    #[serde(default)]
    stop_conditions: Vec<PhaseStopConditionSpec>,
    #[serde(default)]
    authority_boundaries: Vec<String>,
}

#[derive(Clone, Debug, Default, Deserialize)]
#[allow(dead_code)]
struct PhaseTransitionSpec {
    to_phase_id: String,
}

#[derive(Clone, Debug, Default, Deserialize)]
#[allow(dead_code)]
struct PhaseLoopBoundsSpec {
    #[serde(default)]
    max_phase_iterations: u32,
    #[serde(default)]
    max_route_dispatches: u32,
}

#[derive(Clone, Debug, Default, Deserialize)]
#[allow(dead_code)]
struct PhaseStopConditionSpec {
    stop_class: String,
}

#[derive(Clone, Debug, Default, Deserialize)]
struct ProgramRecoveryPolicySpec {
    #[serde(default)]
    max_recovery_attempts: Option<u32>,
    #[serde(default)]
    serialize_write_scope_conflicts: bool,
    #[serde(default)]
    handlers: BTreeMap<String, ProgramRecoveryHandlerSpec>,
    #[serde(default)]
    recipes: Vec<ProgramRecoveryRecipeSpec>,
}

#[derive(Clone, Debug, Default, Deserialize)]
struct ProgramRecoveryHandlerSpec {
    recovery_route_id: Option<String>,
    #[serde(default)]
    max_attempts: Option<u32>,
    #[serde(default)]
    replan_after_attempt: bool,
    #[serde(default)]
    human_required: bool,
}

#[derive(Clone, Debug, Default, Deserialize)]
struct ProgramRecoveryRecipeSpec {
    blocker_class: String,
    #[serde(default)]
    recovery_route_id: Option<String>,
    #[serde(default)]
    recovery_action_id: Option<String>,
    #[serde(default)]
    preconditions: Vec<String>,
    #[serde(default)]
    idempotency_class: Option<String>,
    #[serde(default)]
    human_required: bool,
    #[serde(default)]
    retry_budget: Option<u32>,
    #[serde(default)]
    dependent_handling: Option<String>,
    #[serde(default)]
    post_attempt_validation: Vec<String>,
    #[serde(default)]
    replan_behavior: Option<String>,
    #[serde(default)]
    allowed_authority_zones: Vec<String>,
    #[serde(default)]
    allowed_artifact_classes: Vec<String>,
    #[serde(default)]
    operation_class: Option<String>,
    #[serde(default)]
    requires_run_binding: bool,
    #[serde(default)]
    requires_declared_write_scope: bool,
    #[serde(default)]
    requires_zone_evidence: bool,
    #[serde(default)]
    human_required_for_zones: Vec<String>,
}

#[derive(Clone, Debug, Default, Deserialize)]
struct ProgramCloseoutPolicySpec {
    #[serde(default)]
    required_child_terminal_outcomes: Vec<String>,
    #[serde(default)]
    terminal_child_receipt_requirements: Vec<ProgramTerminalChildReceiptRequirementSpec>,
    #[serde(default)]
    require_child_receipts_fresh: bool,
    #[serde(default)]
    require_aggregate_evidence: bool,
    #[serde(default)]
    enforce_authority_boundaries: bool,
}

#[derive(Clone, Debug, Default, Deserialize)]
struct ProgramTerminalChildReceiptRequirementSpec {
    outcome_id: String,
    #[serde(default)]
    required_receipts: Vec<String>,
    #[serde(default)]
    required_receipt_field_equals: Vec<ProgramReceiptFieldRequirementSpec>,
}

#[derive(Clone, Debug, Default, Deserialize)]
struct ProgramReceiptFieldRequirementSpec {
    receipt_id: String,
    field: String,
    value: String,
}

#[derive(Clone, Debug, Default, Deserialize)]
struct ProgramAuthorityBoundarySpec {
    #[serde(default)]
    parent_coordinates_only: bool,
    #[serde(default)]
    child_receipts_remain_child_owned: bool,
    #[serde(default)]
    child_promotion_targets_remain_child_owned: bool,
}

#[derive(Clone, Debug, Deserialize)]
struct TargetSpec {
    manifest_path: String,
    status_field: String,
}

#[derive(Clone, Debug, Deserialize)]
struct TerminalOutcomeSpec {
    outcome_id: String,
    #[serde(default)]
    when: Option<Value>,
}

#[derive(Clone, Debug, Deserialize)]
struct ValidatorSpec {
    validator_id: String,
    argv: Vec<String>,
}

#[derive(Clone, Debug, Deserialize)]
struct GateSpec {
    gate_id: String,
    validator_id: String,
    #[serde(default)]
    required_before_routes: Vec<String>,
    on_fail_route_id: Option<String>,
}

#[derive(Clone, Debug, Deserialize)]
struct ReceiptSpec {
    receipt_id: String,
    path: String,
    #[serde(default)]
    required_fields: Vec<String>,
    verdict_field: Option<String>,
    freshness: Option<FreshnessSpec>,
}

#[derive(Clone, Debug, Deserialize)]
struct FreshnessSpec {
    digest_command: Vec<String>,
    digest_field: String,
}

#[derive(Clone, Debug, Deserialize)]
struct LoopSpec {
    loop_id: String,
    repeat_route_id: String,
    max_iterations: u32,
}

#[derive(Clone, Debug, Deserialize)]
struct RouteSpec {
    route_id: String,
    route_type: String,
    command_id: Option<String>,
    skill_id: Option<String>,
    prompt_set_id: Option<String>,
    #[serde(default)]
    required_inputs: Vec<String>,
    #[serde(default)]
    enter_when: Option<Value>,
    #[serde(default)]
    delegation_contract: Option<RouteDelegationContractSpec>,
    #[serde(default)]
    completion: Option<RouteCompletionSpec>,
    #[serde(default)]
    atomic: Option<RouteAtomicSpec>,
}

#[derive(Clone, Debug, Default, Deserialize)]
struct RouteDelegationContractSpec {
    decision_class: String,
    #[serde(default)]
    safe_delegation: bool,
    #[serde(default)]
    authority_zones_allowed: Vec<String>,
    #[serde(default)]
    declared_write_scope_source: String,
    #[serde(default)]
    required_evidence_gates: Vec<String>,
    #[serde(default)]
    required_receipts_before_dispatch: Vec<String>,
    #[serde(default)]
    required_receipts_before_completion: Vec<String>,
    #[serde(default)]
    replay_class: String,
    #[serde(default)]
    automated_recovery_policy: String,
    #[serde(default)]
    human_only_boundaries: Vec<String>,
}

#[derive(Clone, Debug, Deserialize)]
struct InputBindingSpec {
    source: String,
}

#[derive(Clone, Debug, Deserialize)]
struct RouteCompletionSpec {
    #[serde(default)]
    expected_receipts: Vec<String>,
    #[serde(default)]
    expected_paths: Vec<String>,
    expected_manifest_status: Option<String>,
    #[serde(default)]
    expected_target_change: bool,
    #[serde(default)]
    replan_required: bool,
}

#[derive(Clone, Debug, Deserialize)]
struct RouteAtomicSpec {
    stage_route_id: String,
    commit_route_id: String,
    #[serde(default)]
    rollback_route_id: Option<String>,
    #[serde(default)]
    compensation_route_id: Option<String>,
}

#[derive(Clone, Debug)]
struct LoadedContract {
    path: PathBuf,
    contract: LifecycleContract,
}

#[derive(Clone, Debug)]
struct TargetState {
    target_abs: PathBuf,
    target_exists: bool,
    manifest_status: Option<String>,
    receipts: BTreeMap<String, ReceiptState>,
}

#[derive(Clone, Debug, Default)]
struct LifecycleConditionContext {
    blockers: Vec<String>,
    cleanup_candidates_present: Option<bool>,
    hygiene_preflight_required: Option<bool>,
}

#[derive(Clone, Debug)]
struct ReceiptState {
    path_abs: PathBuf,
    exists: bool,
    fields: BTreeMap<String, String>,
    missing_required_fields: Vec<String>,
    stale: Option<bool>,
    stored_digest: Option<String>,
    current_digest: Option<String>,
}

#[derive(Clone, Debug, Deserialize, Serialize, Default)]
struct LifecycleCheckpoint {
    schema_version: String,
    run_id: String,
    lifecycle_id: String,
    #[serde(default = "default_route_progression_execution_strategy")]
    execution_strategy: String,
    target: String,
    current_state: Option<String>,
    #[serde(default)]
    current_phase: Option<String>,
    completed_states: Vec<String>,
    last_route: Option<String>,
    #[serde(default)]
    loop_counts: BTreeMap<String, u32>,
    #[serde(default)]
    phase_counts: BTreeMap<String, u32>,
    #[serde(default)]
    last_phase_transition: Option<String>,
    #[serde(default)]
    phase_blockers: BTreeMap<String, String>,
    #[serde(default)]
    receipt_digests: BTreeMap<String, String>,
    #[serde(default)]
    last_validator_results: Vec<GatePlanResult>,
    #[serde(default)]
    run_inputs: BTreeMap<String, String>,
    #[serde(default)]
    interaction_request_refs: Vec<String>,
    #[serde(default)]
    interaction_return_refs: Vec<String>,
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

#[derive(Serialize)]
struct LifecycleRunInputsEvidence<'a> {
    schema_version: &'static str,
    run_id: &'a str,
    inputs: &'a BTreeMap<String, String>,
}

#[derive(Serialize)]
struct LifecycleControlResult {
    schema_version: &'static str,
    run_id: String,
    control: String,
    final_verdict: String,
    checkpoint_path: String,
    evidence_path: String,
    recorded_at: String,
    reason: String,
}

#[derive(Serialize)]
struct LifecyclePostmortemResult {
    schema_version: &'static str,
    run_id: String,
    recorded_at: String,
    status: String,
    postmortem_root: String,
    evidence_map_ref: String,
    known_limits_ref: String,
    evaluator_input_ref: String,
    retained_refs_count: usize,
    missing_refs_count: usize,
    authority_boundary: String,
}

#[derive(Serialize)]
struct LifecyclePostmortemEvidenceMap {
    schema_version: &'static str,
    run_id: String,
    subject: LifecyclePostmortemSubject,
    recorded_at: String,
    status: String,
    evidence_posture: LifecyclePostmortemEvidencePosture,
    subject_control_root: String,
    subject_evidence_roots: Vec<String>,
    postmortem_root: String,
    retained_run_evidence_indexes: Vec<LifecyclePostmortemCanonicalRef>,
    direct_control_refs: Vec<LifecyclePostmortemCanonicalRef>,
    retained_refs: Vec<LifecyclePostmortemRef>,
    missing_refs: Vec<LifecyclePostmortemRef>,
    substitute_refs: Vec<LifecyclePostmortemSubstituteRef>,
    terminal_state_refs: LifecyclePostmortemTerminalStateRefs,
    terminal_state_ref_index: Vec<LifecyclePostmortemRef>,
    child_evidence_ref_index: Vec<LifecyclePostmortemCanonicalRef>,
    diagnostic_refs: Vec<LifecyclePostmortemRef>,
    associated_refs: Vec<LifecyclePostmortemRef>,
    generated_refs: Vec<LifecyclePostmortemCanonicalRef>,
    proposal_local_refs: Vec<LifecyclePostmortemCanonicalRef>,
    reconstruction_order: Vec<String>,
    authority_boundary: LifecyclePostmortemAuthorityBoundary,
}

#[derive(Serialize)]
struct LifecyclePostmortemSubject {
    run_id: String,
    lifecycle_kind: String,
}

#[derive(Serialize)]
struct LifecyclePostmortemEvidencePosture {
    purpose: &'static str,
    direct_control_refs_present: bool,
}

#[derive(Clone, Serialize)]
struct LifecyclePostmortemTerminalStateRefs {
    validation: Vec<LifecyclePostmortemCanonicalRef>,
    rollback: Vec<LifecyclePostmortemCanonicalRef>,
}

#[derive(Clone, Serialize)]
struct LifecyclePostmortemCanonicalRef {
    #[serde(rename = "ref")]
    ref_path: String,
    role: String,
    ref_class: String,
    authority_use: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    sha256: Option<String>,
}

#[derive(Clone, Serialize)]
struct LifecyclePostmortemRef {
    ref_name: String,
    path: String,
    ref_class: String,
    authority_role: String,
    exists: bool,
}

#[derive(Clone, Serialize)]
struct LifecyclePostmortemSubstituteRef {
    ref_name: String,
    #[serde(rename = "ref")]
    ref_path: String,
    role: String,
    path: String,
    ref_class: String,
    authority_role: String,
    authority_use: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    sha256: Option<String>,
    substitutes_for: String,
    exists: bool,
}

#[derive(Serialize)]
struct LifecyclePostmortemKnownLimits {
    schema_version: &'static str,
    run_id: String,
    status: String,
    missing_direct_refs_recorded: bool,
    substitute_refs_validated: bool,
    diagnostic_refs_do_not_override_terminal: bool,
    missing_refs: Vec<LifecyclePostmortemRef>,
    substitute_refs: Vec<LifecyclePostmortemSubstituteRef>,
    reconstruction_order: Vec<String>,
    confidence_effect: String,
    evaluator_instruction: String,
    authority_boundary: LifecyclePostmortemKnownLimitsAuthorityBoundary,
}

#[derive(Serialize)]
struct LifecyclePostmortemStatus {
    schema_version: &'static str,
    run_id: String,
    recorded_at: String,
    status: String,
    evidence_map_ref: String,
    known_limits_ref: String,
    evaluator_input_ref: String,
    non_authority_statement: String,
}

#[derive(Clone, Serialize)]
struct LifecyclePostmortemAuthorityBoundary {
    generated_outputs_authority: bool,
    proposal_inputs_authority: bool,
    raw_inputs_authority: bool,
    postmortem_authorizes_lifecycle_transition: bool,
    postmortem_authorizes_closeout: bool,
    locator_replaces_source_evidence: bool,
    lifecycle_authority_mutated: bool,
    postmortem_output_authority: bool,
    statement: String,
}

#[derive(Serialize)]
struct LifecyclePostmortemKnownLimitsAuthorityBoundary {
    locator_replaces_source_evidence: bool,
}

pub(crate) fn lifecycle_cancellation_token_path(control_root: &Path) -> PathBuf {
    control_root.join(LIFECYCLE_CANCELLATION_FILE)
}

fn lifecycle_cancelled_evidence_path(evidence_root: &Path) -> PathBuf {
    evidence_root.join(LIFECYCLE_CANCELLED_EVIDENCE_FILE)
}

fn lifecycle_event_log_path(root: &Path) -> PathBuf {
    root.join(LIFECYCLE_EVENT_FILE)
}

fn lifecycle_checkpoint_cancelled(checkpoint: &LifecycleCheckpoint) -> bool {
    checkpoint.final_verdict == "cancelled" || checkpoint.cancelled_at.is_some()
}

fn lifecycle_sha256_digest(bytes: &[u8]) -> String {
    let mut hasher = Sha256::new();
    hasher.update(bytes);
    format!("sha256:{:x}", hasher.finalize())
}

fn lifecycle_event_hash(event: &LifecycleRunEvent) -> Result<String> {
    let mut event = event.clone();
    event.event_sha256 = None;
    Ok(lifecycle_sha256_digest(
        serde_json::to_string(&event)?.as_bytes(),
    ))
}

fn last_lifecycle_event_hash(log_path: &Path) -> Result<Option<String>> {
    if !log_path.exists() {
        return Ok(None);
    }
    let content = fs::read_to_string(log_path)?;
    for line in content.lines().rev() {
        if line.trim().is_empty() {
            continue;
        }
        let event: LifecycleRunEvent = serde_json::from_str(line)?;
        return Ok(event.event_sha256);
    }
    Ok(None)
}

fn count_lifecycle_events(log_path: &Path) -> Result<u64> {
    if !log_path.exists() {
        return Ok(0);
    }
    Ok(fs::read_to_string(log_path)?
        .lines()
        .filter(|line| !line.trim().is_empty())
        .count() as u64)
}

#[allow(clippy::too_many_arguments)]
pub(crate) fn append_lifecycle_event(
    control_root: &Path,
    evidence_root: &Path,
    run_id: &str,
    lifecycle_id: &str,
    execution_strategy: &str,
    target: &Path,
    event_type: &str,
    event_category: &str,
    actor: &str,
    step_index: Option<u32>,
    step_number: Option<u32>,
    step_kind: Option<&str>,
    route_id: Option<&str>,
    child_id: Option<&str>,
    final_verdict: Option<&str>,
    data: BTreeMap<String, String>,
) -> Result<u64> {
    fs::create_dir_all(control_root)?;
    fs::create_dir_all(evidence_root)?;
    let mut data = data;
    let phase_id = data.remove("phase_id");
    let transition_id = data.remove("transition_id");
    let control_log = lifecycle_event_log_path(control_root);
    let evidence_log = lifecycle_event_log_path(evidence_root);
    let event_index = count_lifecycle_events(&control_log)?;
    let previous_event_sha256 = last_lifecycle_event_hash(&control_log)?;
    let mut event = LifecycleRunEvent {
        schema_version: LIFECYCLE_EVENT_SCHEMA_VERSION.to_string(),
        run_id: run_id.to_string(),
        lifecycle_id: lifecycle_id.to_string(),
        execution_strategy: execution_strategy.to_string(),
        target: target.display().to_string(),
        event_index,
        previous_event_sha256,
        event_sha256: None,
        event_type: event_type.to_string(),
        event_category: event_category.to_string(),
        recorded_at: now_rfc3339()?,
        actor: actor.to_string(),
        step_index,
        step_number,
        step_kind: step_kind.map(str::to_string),
        route_id: route_id.map(str::to_string),
        phase_id,
        transition_id,
        child_id: child_id.map(str::to_string),
        final_verdict: final_verdict.map(str::to_string),
        data,
    };
    event.event_sha256 = Some(lifecycle_event_hash(&event)?);
    let line = serde_json::to_string(&event)?;
    for path in [&control_log, &evidence_log] {
        let mut file = OpenOptions::new().create(true).append(true).open(path)?;
        writeln!(file, "{line}")?;
    }
    Ok(event_index)
}

pub(crate) fn append_lifecycle_run_started_if_needed(
    control_root: &Path,
    evidence_root: &Path,
    run_id: &str,
    lifecycle_id: &str,
    execution_strategy: &str,
    target: &Path,
) -> Result<()> {
    if count_lifecycle_events(&lifecycle_event_log_path(control_root))? == 0 {
        append_lifecycle_event(
            control_root,
            evidence_root,
            run_id,
            lifecycle_id,
            execution_strategy,
            target,
            "run-started",
            "lifecycle",
            "runtime",
            None,
            None,
            None,
            None,
            None,
            None,
            BTreeMap::new(),
        )?;
    }
    Ok(())
}

pub(crate) fn cmd_lifecycle(cmd: LifecycleCmd) -> Result<()> {
    let octon_dir = RootResolver::resolve()?;
    match cmd {
        LifecycleCmd::Plan {
            lifecycle_id,
            target,
        } => match lifecycle_execution_strategy_from_octon_dir(&octon_dir, &lifecycle_id)? {
            LifecycleExecutionStrategy::RouteProgression => {
                let plan = plan_lifecycle_from_octon_dir(&octon_dir, &lifecycle_id, &target)?;
                println!("{}", serde_yaml::to_string(&plan)?);
            }
            LifecycleExecutionStrategy::OrchestratedReplanLoop => {
                let plan = lifecycle_program::plan_program_lifecycle_from_octon_dir(
                    &octon_dir,
                    &lifecycle_id,
                    &target,
                )?;
                println!("{}", serde_yaml::to_string(&plan)?);
            }
        },
        LifecycleCmd::Run {
            lifecycle_id,
            target,
            run_id,
            executor,
            max_iterations,
            execute_routes,
            max_steps,
            timeout_seconds,
            max_child_concurrency,
            invocation_authority,
            set,
            set_file,
        } => {
            let run_inputs = normalize_lifecycle_run_inputs(&octon_dir, &set, &set_file)?;
            let options = RunLifecycleOptions {
                lifecycle_id,
                target,
                run_id,
                executor,
                max_iterations,
                execute_routes,
                max_steps,
                timeout_seconds,
                max_child_concurrency,
                invocation_authority,
                run_inputs,
                program_child_filter: None,
            };
            match lifecycle_execution_strategy_from_octon_dir(&octon_dir, &options.lifecycle_id)? {
                LifecycleExecutionStrategy::RouteProgression => {
                    let result = if options.execute_routes {
                        crate::lifecycle_driver::run_lifecycle_execute_from_octon_dir(
                            &octon_dir, options,
                        )?
                    } else {
                        run_lifecycle_from_octon_dir(&octon_dir, options)?
                    };
                    println!("{}", serde_yaml::to_string(&result)?);
                }
                LifecycleExecutionStrategy::OrchestratedReplanLoop => {
                    let result = lifecycle_program::run_program_lifecycle_from_octon_dir(
                        &octon_dir, options,
                    )?;
                    println!("{}", serde_yaml::to_string(&result)?);
                }
            }
        }
        LifecycleCmd::Postmortem { run_id } => {
            let result = run_lifecycle_postmortem_from_octon_dir(&octon_dir, &run_id)?;
            println!("{}", serde_yaml::to_string(&result)?);
        }
        LifecycleCmd::Resume { run_id } => {
            if lifecycle_program::program_checkpoint_exists(&octon_dir, &run_id)? {
                let result = lifecycle_program::resume_program_lifecycle_from_octon_dir(
                    &octon_dir, &run_id,
                )?;
                println!("{}", serde_yaml::to_string(&result)?);
            } else {
                let result = resume_lifecycle_from_octon_dir(&octon_dir, &run_id)?;
                println!("{}", serde_yaml::to_string(&result)?);
            }
        }
        LifecycleCmd::Cancel { run_id, reason } => {
            let result = cancel_lifecycle_run(&octon_dir, &run_id, &reason)?;
            println!("{}", serde_yaml::to_string(&result)?);
        }
        LifecycleCmd::Program { cmd } => match cmd {
            LifecycleProgramCmd::Inspect { run_id } => {
                let result = lifecycle_program::inspect_program_lifecycle_run(&octon_dir, &run_id)?;
                println!("{}", serde_yaml::to_string(&result)?);
            }
            LifecycleProgramCmd::Replay { run_id, verify } => {
                let result =
                    lifecycle_program::replay_program_lifecycle_run(&octon_dir, &run_id, verify)?;
                println!("{}", serde_yaml::to_string(&result)?);
            }
            LifecycleProgramCmd::Status { run_id, format } => {
                let result = lifecycle_program::status_program_lifecycle_run(&octon_dir, &run_id)?;
                if format == "json" {
                    println!("{}", serde_json::to_string_pretty(&result)?);
                } else if format == "text" {
                    println!("{}", serde_yaml::to_string(&result)?);
                } else {
                    bail!("unsupported lifecycle program status format: {format}");
                }
            }
            LifecycleProgramCmd::ExplainBlockers { run_id } => {
                let result =
                    lifecycle_program::explain_program_lifecycle_blockers(&octon_dir, &run_id)?;
                println!("{}", serde_yaml::to_string(&result)?);
            }
            LifecycleProgramCmd::Approve {
                run_id,
                child,
                route,
                reason,
            } => {
                let result = lifecycle_program::approve_program_lifecycle_child_route(
                    &octon_dir, &run_id, &child, &route, &reason,
                )?;
                println!("{}", serde_yaml::to_string(&result)?);
            }
            LifecycleProgramCmd::Retry { run_id, child } => {
                let result =
                    lifecycle_program::retry_program_lifecycle_run(&octon_dir, &run_id, child)?;
                println!("{}", serde_yaml::to_string(&result)?);
            }
            LifecycleProgramCmd::Cancel { run_id, reason } => {
                let result = cancel_lifecycle_run(&octon_dir, &run_id, &reason)?;
                println!("{}", serde_yaml::to_string(&result)?);
            }
            LifecycleProgramCmd::ProposeMutation { run_id, spec } => {
                let result =
                    lifecycle_program::propose_program_mutation(&octon_dir, &run_id, &spec)?;
                println!("{}", serde_yaml::to_string(&result)?);
            }
            LifecycleProgramCmd::ApplyMutation {
                run_id,
                spec,
                reason,
            } => {
                let result =
                    lifecycle_program::apply_program_mutation(&octon_dir, &run_id, &spec, &reason)?;
                println!("{}", serde_yaml::to_string(&result)?);
            }
            LifecycleProgramCmd::Scaffold {
                target,
                spec,
                dry_run,
            } => {
                let result = lifecycle_program::scaffold_program_from_seed(
                    &octon_dir, &target, &spec, dry_run,
                )?;
                println!("{}", serde_yaml::to_string(&result)?);
            }
        },
    }
    Ok(())
}

fn run_lifecycle_postmortem_from_octon_dir(
    octon_dir: &Path,
    run_id: &str,
) -> Result<LifecyclePostmortemResult> {
    let sanitized_run_id = sanitize_run_id(run_id)?;
    if sanitized_run_id != run_id {
        bail!(
            "lifecycle postmortem run id contains unsupported characters; use only ASCII letters, digits, hyphen, or underscore"
        );
    }

    let repo_root = repo_root_for_octon(octon_dir)?;
    let recorded_at = now_rfc3339()?;
    let control_root = octon_dir.join(RUN_CONTROL_ROOT_REL).join(&sanitized_run_id);
    let direct_evidence_root = octon_dir
        .join("state/evidence/runs")
        .join(&sanitized_run_id);
    let workflow_evidence_root = octon_dir
        .join(WORKFLOW_EVIDENCE_ROOT_REL)
        .join(&sanitized_run_id);
    let postmortem_root = direct_evidence_root
        .join("assurance")
        .join("lifecycle-postmortem");

    let control_exists = control_root.exists();
    let direct_evidence_exists = direct_evidence_root.exists();
    let workflow_evidence_exists = workflow_evidence_root.exists();
    let status = if control_exists || direct_evidence_exists || workflow_evidence_exists {
        "prepared"
    } else {
        "blocked-missing-retained-run"
    }
    .to_string();

    let candidate_refs = lifecycle_postmortem_direct_refs(
        &repo_root,
        &control_root,
        &direct_evidence_root,
        &workflow_evidence_root,
        control_exists,
        direct_evidence_exists,
        workflow_evidence_exists,
    );
    let terminal_state_ref_index =
        lifecycle_postmortem_terminal_state_refs(&repo_root, &workflow_evidence_root);
    let terminal_state_refs = LifecyclePostmortemTerminalStateRefs {
        validation: lifecycle_postmortem_terminal_validation_refs(
            &repo_root,
            &workflow_evidence_root,
        ),
        rollback: lifecycle_postmortem_terminal_rollback_refs(&repo_root, &workflow_evidence_root),
    };
    let child_evidence_ref_index =
        lifecycle_postmortem_child_evidence_ref_index(&repo_root, &workflow_evidence_root);
    let diagnostic_refs = lifecycle_postmortem_diagnostic_refs(&repo_root, &workflow_evidence_root);
    let associated_refs =
        lifecycle_postmortem_associated_refs(&repo_root, octon_dir, &sanitized_run_id)?;
    let substitute_refs = lifecycle_postmortem_substitute_refs(
        &repo_root,
        &control_root,
        &workflow_evidence_root,
        &candidate_refs,
    );
    let reconstruction_order = lifecycle_postmortem_reconstruction_order();

    let mut retained_refs = candidate_refs
        .iter()
        .filter(|item| item.exists)
        .cloned()
        .collect::<Vec<_>>();
    retained_refs.extend(terminal_state_ref_index.clone());
    retained_refs.extend(diagnostic_refs.clone());
    retained_refs.extend(associated_refs.clone());
    retained_refs.extend(
        substitute_refs
            .iter()
            .map(lifecycle_postmortem_ref_from_substitute),
    );
    lifecycle_postmortem_dedupe_refs(&mut retained_refs);
    let missing_refs = candidate_refs
        .iter()
        .filter(|item| !item.exists)
        .cloned()
        .collect::<Vec<_>>();

    let authority_boundary = LifecyclePostmortemAuthorityBoundary {
        generated_outputs_authority: false,
        proposal_inputs_authority: false,
        raw_inputs_authority: false,
        postmortem_authorizes_lifecycle_transition: false,
        postmortem_authorizes_closeout: false,
        locator_replaces_source_evidence: false,
        lifecycle_authority_mutated: false,
        postmortem_output_authority: false,
        statement: "Lifecycle postmortem outputs are retained evidence only. They do not authorize lifecycle transition, closeout, promotion, support widening, redesign, generated-output publication, or invariant amendment.".to_string(),
    };

    fs::create_dir_all(&postmortem_root)?;
    let evidence_map_path = postmortem_root.join("evidence-map.yml");
    let known_limits_path = postmortem_root.join("known-limits.yml");
    let evaluator_input_path = postmortem_root.join("evaluator-input.md");
    let status_path = postmortem_root.join("status.yml");

    let evidence_map = LifecyclePostmortemEvidenceMap {
        schema_version: "lifecycle-postmortem-evidence-map-v2",
        run_id: sanitized_run_id.clone(),
        subject: LifecyclePostmortemSubject {
            run_id: sanitized_run_id.clone(),
            lifecycle_kind: lifecycle_kind_for_run_id(&sanitized_run_id),
        },
        recorded_at: recorded_at.clone(),
        status: status.clone(),
        evidence_posture: LifecyclePostmortemEvidencePosture {
            purpose: "discovery-and-replay-aid",
            direct_control_refs_present: candidate_refs
                .iter()
                .any(|item| item.exists && item.authority_role == "mutable-control-truth"),
        },
        subject_control_root: rel_display(&repo_root, &control_root),
        subject_evidence_roots: vec![
            rel_display(&repo_root, &direct_evidence_root),
            rel_display(&repo_root, &workflow_evidence_root),
        ],
        postmortem_root: rel_display(&repo_root, &postmortem_root),
        retained_run_evidence_indexes: lifecycle_postmortem_retained_index_refs(
            &repo_root,
            &direct_evidence_root,
            &workflow_evidence_root,
        ),
        direct_control_refs: candidate_refs
            .iter()
            .filter(|item| item.exists && item.authority_role == "mutable-control-truth")
            .filter_map(|item| {
                lifecycle_postmortem_canonical_ref_from_repo_ref(
                    &repo_root,
                    &item.path,
                    &item.ref_name,
                    "control",
                    "control-truth",
                )
            })
            .collect(),
        retained_refs: retained_refs.clone(),
        missing_refs: missing_refs.clone(),
        substitute_refs: substitute_refs.clone(),
        terminal_state_refs: terminal_state_refs.clone(),
        terminal_state_ref_index: terminal_state_ref_index.clone(),
        child_evidence_ref_index,
        diagnostic_refs: diagnostic_refs.clone(),
        associated_refs: associated_refs.clone(),
        generated_refs: Vec::new(),
        proposal_local_refs: Vec::new(),
        reconstruction_order: reconstruction_order.clone(),
        authority_boundary: authority_boundary.clone(),
    };
    fs::write(&evidence_map_path, serde_yaml::to_string(&evidence_map)?)?;

    let known_limits = LifecyclePostmortemKnownLimits {
        schema_version: "lifecycle-postmortem-known-limits-v2",
        run_id: sanitized_run_id.clone(),
        status: status.clone(),
        missing_direct_refs_recorded: !missing_refs.is_empty(),
        substitute_refs_validated: substitute_refs.iter().all(|item| item.exists),
        diagnostic_refs_do_not_override_terminal: true,
        missing_refs: missing_refs.clone(),
        substitute_refs: substitute_refs.clone(),
        reconstruction_order: reconstruction_order.clone(),
        confidence_effect: lifecycle_postmortem_confidence_effect(&missing_refs, &substitute_refs),
        evaluator_instruction: "Treat missing direct control refs as evidence gaps. When substitute_refs are listed, use those retained workflow refs for reconstruction before escalating; never fill gaps from generated summaries, raw inputs, chat history, host state, dashboards, or model memory. Diagnostic failing-slice evidence is historical and must not override terminal blocker ledgers.".to_string(),
        authority_boundary: LifecyclePostmortemKnownLimitsAuthorityBoundary {
            locator_replaces_source_evidence: false,
        },
    };
    fs::write(&known_limits_path, serde_yaml::to_string(&known_limits)?)?;

    fs::write(
        &evaluator_input_path,
        lifecycle_postmortem_evaluator_input(
            &sanitized_run_id,
            &recorded_at,
            &retained_refs,
            &missing_refs,
            &substitute_refs,
            &terminal_state_ref_index,
            &diagnostic_refs,
            &associated_refs,
            &reconstruction_order,
            &evidence_map_path,
            &known_limits_path,
            &repo_root,
        ),
    )?;

    let status_record = LifecyclePostmortemStatus {
        schema_version: "lifecycle-postmortem-status-v1",
        run_id: sanitized_run_id.clone(),
        recorded_at: recorded_at.clone(),
        status: status.clone(),
        evidence_map_ref: rel_display(&repo_root, &evidence_map_path),
        known_limits_ref: rel_display(&repo_root, &known_limits_path),
        evaluator_input_ref: rel_display(&repo_root, &evaluator_input_path),
        non_authority_statement: authority_boundary.statement.clone(),
    };
    fs::write(&status_path, serde_yaml::to_string(&status_record)?)?;

    Ok(LifecyclePostmortemResult {
        schema_version: "lifecycle-postmortem-run-result-v1",
        run_id: sanitized_run_id,
        recorded_at,
        status,
        postmortem_root: rel_display(&repo_root, &postmortem_root),
        evidence_map_ref: rel_display(&repo_root, &evidence_map_path),
        known_limits_ref: rel_display(&repo_root, &known_limits_path),
        evaluator_input_ref: rel_display(&repo_root, &evaluator_input_path),
        retained_refs_count: retained_refs.len(),
        missing_refs_count: missing_refs.len(),
        authority_boundary: authority_boundary.statement,
    })
}

fn lifecycle_postmortem_direct_refs(
    repo_root: &Path,
    control_root: &Path,
    direct_evidence_root: &Path,
    workflow_evidence_root: &Path,
    control_exists: bool,
    direct_evidence_exists: bool,
    workflow_evidence_exists: bool,
) -> Vec<LifecyclePostmortemRef> {
    vec![
        lifecycle_postmortem_ref(
            repo_root,
            "run-control-root",
            control_root,
            "control-root",
            "mutable-control-truth",
            control_exists,
        ),
        lifecycle_postmortem_ref(
            repo_root,
            "lifecycle-checkpoint",
            &control_root.join("lifecycle-checkpoint.yml"),
            "control-checkpoint",
            "mutable-control-truth",
            control_root.join("lifecycle-checkpoint.yml").is_file(),
        ),
        lifecycle_postmortem_ref(
            repo_root,
            "program-lifecycle-checkpoint",
            &control_root.join("program-lifecycle-checkpoint.yml"),
            "control-checkpoint",
            "mutable-control-truth",
            control_root
                .join("program-lifecycle-checkpoint.yml")
                .is_file(),
        ),
        lifecycle_postmortem_ref(
            repo_root,
            "lifecycle-events",
            &control_root.join(LIFECYCLE_EVENT_FILE),
            "control-event-log",
            "mutable-control-truth",
            control_root.join(LIFECYCLE_EVENT_FILE).is_file(),
        ),
        lifecycle_postmortem_ref(
            repo_root,
            "program-events",
            &control_root.join("program-events.ndjson"),
            "control-event-log",
            "mutable-control-truth",
            control_root.join("program-events.ndjson").is_file(),
        ),
        lifecycle_postmortem_ref(
            repo_root,
            "run-evidence-root",
            direct_evidence_root,
            "retained-evidence-root",
            "retained-evidence",
            direct_evidence_exists,
        ),
        lifecycle_postmortem_ref(
            repo_root,
            "workflow-evidence-root",
            workflow_evidence_root,
            "retained-evidence-root",
            "retained-evidence",
            workflow_evidence_exists,
        ),
    ]
}

fn lifecycle_postmortem_terminal_state_refs(
    repo_root: &Path,
    workflow_evidence_root: &Path,
) -> Vec<LifecyclePostmortemRef> {
    lifecycle_postmortem_existing_named_refs(
        repo_root,
        workflow_evidence_root,
        "retained-terminal-state",
        "retained-evidence",
        &[
            ("program-summary", "summary.md"),
            (
                "aggregate-terminal-blockers",
                "aggregate-terminal-blockers.yml",
            ),
            ("blocker-ledger", "blocker-ledger.yml"),
            ("recovery-delta-summary", "recovery-delta-summary.yml"),
            ("route-decision-receipt", "route-decision-receipt.yml"),
            ("program-plan", "program-plan.yml"),
            ("scheduler-decision", "scheduler-decision.yml"),
            ("planner-state", "planner-state.yml"),
            ("program-context-capsule", "program-context-capsule.yml"),
            (
                "publication-freshness-preflight-summary",
                "publication-freshness-preflight/summary.yml",
            ),
        ],
    )
}

fn lifecycle_kind_for_run_id(run_id: &str) -> String {
    let Some(rest) = run_id.strip_prefix("lifecycle-") else {
        return "unknown".to_string();
    };
    for kind in ["proposal-program", "proposal-packet", "program", "packet"] {
        if rest == kind || rest.starts_with(&format!("{kind}-")) {
            return kind.to_string();
        }
    }
    rest.split_once('-')
        .map(|(kind, _)| kind.to_string())
        .unwrap_or_else(|| rest.to_string())
}

fn lifecycle_postmortem_retained_index_refs(
    repo_root: &Path,
    direct_evidence_root: &Path,
    workflow_evidence_root: &Path,
) -> Vec<LifecyclePostmortemCanonicalRef> {
    let mut refs = Vec::new();
    for (role, path) in [
        (
            "direct-retained-run-evidence-index",
            direct_evidence_root.join("retained-run-evidence-index.yml"),
        ),
        (
            "workflow-retained-run-evidence-index",
            workflow_evidence_root.join("evidence-index.yml"),
        ),
    ] {
        if let Some(item) = lifecycle_postmortem_canonical_ref(
            repo_root,
            role,
            &path,
            "retained-evidence",
            "evidence-only",
        ) {
            refs.push(item);
        }
    }
    refs
}

fn lifecycle_postmortem_terminal_validation_refs(
    repo_root: &Path,
    workflow_evidence_root: &Path,
) -> Vec<LifecyclePostmortemCanonicalRef> {
    lifecycle_postmortem_existing_canonical_refs(
        repo_root,
        workflow_evidence_root,
        "retained-evidence",
        "evidence-only",
        &[
            ("program-summary", "summary.md"),
            (
                "aggregate-terminal-blockers",
                "aggregate-terminal-blockers.yml",
            ),
            (
                "aggregate-closeout-receipt",
                "aggregate-closeout-receipt.yml",
            ),
        ],
    )
}

fn lifecycle_postmortem_terminal_rollback_refs(
    repo_root: &Path,
    workflow_evidence_root: &Path,
) -> Vec<LifecyclePostmortemCanonicalRef> {
    lifecycle_postmortem_existing_canonical_refs(
        repo_root,
        workflow_evidence_root,
        "retained-evidence",
        "evidence-only",
        &[
            ("route-decision-receipt", "route-decision-receipt.yml"),
            ("recovery-delta-summary", "recovery-delta-summary.yml"),
            ("aggregate-closeout", "aggregate-closeout.yml"),
        ],
    )
}

fn lifecycle_postmortem_child_evidence_ref_index(
    repo_root: &Path,
    workflow_evidence_root: &Path,
) -> Vec<LifecyclePostmortemCanonicalRef> {
    lifecycle_postmortem_existing_canonical_refs(
        repo_root,
        workflow_evidence_root,
        "retained-child-evidence-dereference",
        "evidence-only-non-substitutive",
        &[
            (
                "child-validation-ref-index",
                "aggregate-terminal-blockers.yml",
            ),
            ("child-receipt-ref-index", "aggregate-closeout-receipt.yml"),
            ("child-rollback-ref-index", "aggregate-closeout.yml"),
            ("child-closeout-ref-index", "aggregate-closeout-receipt.yml"),
            ("child-archive-ref-index", "aggregate-closeout-receipt.yml"),
        ],
    )
}

fn lifecycle_postmortem_diagnostic_refs(
    repo_root: &Path,
    workflow_evidence_root: &Path,
) -> Vec<LifecyclePostmortemRef> {
    lifecycle_postmortem_existing_named_refs(
        repo_root,
        workflow_evidence_root,
        "retained-diagnostic-history",
        "retained-evidence-diagnostic",
        &[
            ("raw-log-summary", "raw-log-summary.yml"),
            ("failing-slice-manifest", "failing-slice-manifest.yml"),
        ],
    )
}

fn lifecycle_postmortem_existing_named_refs(
    repo_root: &Path,
    root: &Path,
    ref_class: &str,
    authority_role: &str,
    names: &[(&str, &str)],
) -> Vec<LifecyclePostmortemRef> {
    names
        .iter()
        .filter_map(|(ref_name, rel)| {
            let path = root.join(rel);
            path.is_file().then(|| {
                lifecycle_postmortem_ref(
                    repo_root,
                    ref_name,
                    &path,
                    ref_class,
                    authority_role,
                    true,
                )
            })
        })
        .collect()
}

fn lifecycle_postmortem_existing_canonical_refs(
    repo_root: &Path,
    root: &Path,
    ref_class: &str,
    authority_use: &str,
    names: &[(&str, &str)],
) -> Vec<LifecyclePostmortemCanonicalRef> {
    names
        .iter()
        .filter_map(|(role, rel)| {
            lifecycle_postmortem_canonical_ref(
                repo_root,
                role,
                &root.join(rel),
                ref_class,
                authority_use,
            )
        })
        .collect()
}

fn lifecycle_postmortem_canonical_ref_from_repo_ref(
    repo_root: &Path,
    repo_ref: &str,
    role: &str,
    ref_class: &str,
    authority_use: &str,
) -> Option<LifecyclePostmortemCanonicalRef> {
    lifecycle_postmortem_canonical_ref(
        repo_root,
        role,
        &repo_root.join(repo_ref),
        ref_class,
        authority_use,
    )
}

fn lifecycle_postmortem_canonical_ref(
    repo_root: &Path,
    role: &str,
    path: &Path,
    ref_class: &str,
    authority_use: &str,
) -> Option<LifecyclePostmortemCanonicalRef> {
    if !path.is_file() {
        return None;
    }
    Some(LifecyclePostmortemCanonicalRef {
        ref_path: rel_display(repo_root, path),
        role: role.to_string(),
        ref_class: ref_class.to_string(),
        authority_use: authority_use.to_string(),
        sha256: lifecycle_postmortem_file_digest(path),
    })
}

fn lifecycle_postmortem_file_digest(path: &Path) -> Option<String> {
    fs::read(path)
        .ok()
        .map(|bytes| lifecycle_sha256_digest(&bytes))
}

fn lifecycle_postmortem_substitute_refs(
    repo_root: &Path,
    control_root: &Path,
    workflow_evidence_root: &Path,
    direct_refs: &[LifecyclePostmortemRef],
) -> Vec<LifecyclePostmortemSubstituteRef> {
    let missing = direct_refs
        .iter()
        .filter(|item| !item.exists)
        .map(|item| item.ref_name.as_str())
        .collect::<BTreeSet<_>>();
    let mut refs = Vec::new();
    if missing.contains("program-lifecycle-checkpoint") {
        let path = workflow_evidence_root.join("program-lifecycle-checkpoint.yml");
        if path.is_file() {
            refs.push(lifecycle_postmortem_substitute_ref(
                repo_root,
                "workflow-program-lifecycle-checkpoint",
                &path,
                "retained-workflow-evidence",
                "retained-evidence-substitute",
                &rel_display(
                    repo_root,
                    &control_root.join("program-lifecycle-checkpoint.yml"),
                ),
            ));
        }
    }
    if missing.contains("program-events") {
        let path = workflow_evidence_root.join("program-events.ndjson");
        if path.is_file() {
            refs.push(lifecycle_postmortem_substitute_ref(
                repo_root,
                "workflow-program-events",
                &path,
                "retained-workflow-evidence",
                "retained-evidence-substitute",
                &rel_display(repo_root, &control_root.join("program-events.ndjson")),
            ));
        }
    }
    refs
}

fn lifecycle_postmortem_substitute_ref(
    repo_root: &Path,
    ref_name: &str,
    path: &Path,
    ref_class: &str,
    authority_role: &str,
    substitutes_for: &str,
) -> LifecyclePostmortemSubstituteRef {
    LifecyclePostmortemSubstituteRef {
        ref_name: ref_name.to_string(),
        ref_path: rel_display(repo_root, path),
        role: ref_name.to_string(),
        path: rel_display(repo_root, path),
        ref_class: ref_class.to_string(),
        authority_role: authority_role.to_string(),
        authority_use: "evidence-only".to_string(),
        sha256: lifecycle_postmortem_file_digest(path),
        substitutes_for: substitutes_for.to_string(),
        exists: true,
    }
}

fn lifecycle_postmortem_ref_from_substitute(
    item: &LifecyclePostmortemSubstituteRef,
) -> LifecyclePostmortemRef {
    LifecyclePostmortemRef {
        ref_name: item.ref_name.clone(),
        path: item.path.clone(),
        ref_class: item.ref_class.clone(),
        authority_role: item.authority_role.clone(),
        exists: item.exists,
    }
}

fn lifecycle_postmortem_associated_refs(
    repo_root: &Path,
    octon_dir: &Path,
    run_id: &str,
) -> Result<Vec<LifecyclePostmortemRef>> {
    let roots = lifecycle_postmortem_associated_roots(octon_dir);
    let mut files = Vec::new();
    for (role, root) in &roots {
        lifecycle_postmortem_collect_associated_files(role, root, 0, &mut files)?;
    }
    files.sort_by(|left, right| left.1.cmp(&right.1).then_with(|| left.0.cmp(&right.0)));
    files.dedup_by(|left, right| left.1 == right.1);

    let mut refs = Vec::new();
    for (role, path) in files.into_iter().take(128) {
        let Ok(metadata) = fs::metadata(&path) else {
            continue;
        };
        if metadata.len() > 2_000_000 {
            continue;
        }
        let Ok(content) = fs::read_to_string(&path) else {
            continue;
        };
        if !content.contains(run_id) {
            continue;
        }
        refs.push(lifecycle_postmortem_ref(
            repo_root,
            &format!("{}-{}", role, refs.len() + 1),
            &path,
            role,
            "retained-evidence-associated",
            true,
        ));
    }
    Ok(refs)
}

fn lifecycle_postmortem_associated_roots(octon_dir: &Path) -> Vec<(&'static str, PathBuf)> {
    vec![
        (
            "associated-closeout-receipt",
            octon_dir.join("state/evidence/runs/skills/closeout-change"),
        ),
        (
            "associated-worktree-closeout-receipt",
            octon_dir.join("state/evidence/runs/skills/closeout-worktree"),
        ),
        (
            "associated-pr-closeout-receipt",
            octon_dir.join("state/evidence/runs/skills/closeout-pr"),
        ),
        (
            "associated-archive-receipt",
            octon_dir.join("state/evidence/disclosure/runs"),
        ),
        (
            "associated-validation-report",
            octon_dir.join("state/evidence/validation"),
        ),
        (
            "associated-workflow-evidence",
            octon_dir.join("state/evidence/runs/workflows"),
        ),
    ]
}

fn lifecycle_postmortem_collect_associated_files(
    role: &'static str,
    root: &Path,
    depth: usize,
    files: &mut Vec<(&'static str, PathBuf)>,
) -> Result<()> {
    if depth > 6 || !root.exists() || files.len() >= 512 {
        return Ok(());
    }
    let mut entries = fs::read_dir(root)?.collect::<std::result::Result<Vec<_>, _>>()?;
    entries.sort_by_key(|entry| entry.path());
    for entry in entries {
        let path = entry.path();
        if path.is_dir() {
            lifecycle_postmortem_collect_associated_files(role, &path, depth + 1, files)?;
        } else if lifecycle_postmortem_associated_file_candidate(&path) {
            files.push((role, path));
        }
        if files.len() >= 512 {
            break;
        }
    }
    Ok(())
}

fn lifecycle_postmortem_associated_file_candidate(path: &Path) -> bool {
    matches!(
        path.extension().and_then(|ext| ext.to_str()),
        Some("json" | "yml" | "yaml" | "md")
    )
}

fn lifecycle_postmortem_reconstruction_order() -> Vec<String> {
    vec![
        "1. Use direct control checkpoint and event refs when present.".to_string(),
        "2. Use substitute_refs for missing direct program control refs when listed.".to_string(),
        "3. Use terminal_state_refs for final lifecycle outcome, terminal blockers, route decision, and publication state.".to_string(),
        "4. Use associated_refs for closeout, archive, residue, and publication receipts that explicitly reference the run id.".to_string(),
        "5. Use diagnostic_refs only for historical troubleshooting; failing slices must not override terminal blocker ledgers.".to_string(),
        "6. Treat unresolved missing refs as evidence gaps and keep postmortem outputs non-authoritative.".to_string(),
    ]
}

fn lifecycle_postmortem_confidence_effect(
    missing_refs: &[LifecyclePostmortemRef],
    substitute_refs: &[LifecyclePostmortemSubstituteRef],
) -> String {
    if missing_refs.is_empty() {
        "no known missing lifecycle source refs detected by deterministic binding".to_string()
    } else if !substitute_refs.is_empty() {
        "some direct control refs are missing, but listed substitute_refs provide retained workflow evidence for reconstruction; unresolved missing refs remain evidence gaps".to_string()
    } else {
        "missing refs must be treated as evidence gaps by the evaluator and must not be filled from generated summaries, raw inputs, chat history, host state, or model memory".to_string()
    }
}

fn lifecycle_postmortem_dedupe_refs(refs: &mut Vec<LifecyclePostmortemRef>) {
    let mut seen = BTreeSet::new();
    refs.retain(|item| seen.insert((item.ref_name.clone(), item.path.clone())));
}

fn lifecycle_postmortem_ref(
    repo_root: &Path,
    ref_name: &str,
    path: &Path,
    ref_class: &str,
    authority_role: &str,
    exists: bool,
) -> LifecyclePostmortemRef {
    LifecyclePostmortemRef {
        ref_name: ref_name.to_string(),
        path: rel_display(repo_root, path),
        ref_class: ref_class.to_string(),
        authority_role: authority_role.to_string(),
        exists,
    }
}

fn lifecycle_postmortem_evaluator_input(
    run_id: &str,
    recorded_at: &str,
    retained_refs: &[LifecyclePostmortemRef],
    missing_refs: &[LifecyclePostmortemRef],
    substitute_refs: &[LifecyclePostmortemSubstituteRef],
    terminal_state_refs: &[LifecyclePostmortemRef],
    diagnostic_refs: &[LifecyclePostmortemRef],
    associated_refs: &[LifecyclePostmortemRef],
    reconstruction_order: &[String],
    evidence_map_path: &Path,
    known_limits_path: &Path,
    repo_root: &Path,
) -> String {
    let mut body = format!(
        "# Lifecycle Postmortem Evaluator Input\n\nrun_id: {run_id}\nprepared_at: {recorded_at}\ntemplate_ref: .octon/framework/assurance/evaluators/templates/lifecycle-postmortem-template.md\nstructured_schema_ref: .octon/framework/constitution/contracts/assurance/lifecycle-postmortem-evaluation-v2.schema.json\nevidence_map_ref: {}\nknown_limits_ref: {}\n\n## Retained Refs\n\n",
        rel_display(repo_root, evidence_map_path),
        rel_display(repo_root, known_limits_path)
    );
    if retained_refs.is_empty() {
        body.push_str("- none detected\n");
    } else {
        for item in retained_refs {
            body.push_str(&format!(
                "- `{}`: `{}` ({})\n",
                item.ref_name, item.path, item.ref_class
            ));
        }
    }
    body.push_str("\n## Substitute Refs\n\n");
    if substitute_refs.is_empty() {
        body.push_str("- none detected\n");
    } else {
        for item in substitute_refs {
            body.push_str(&format!(
                "- `{}`: `{}` substitutes for `{}` ({})\n",
                item.ref_name, item.path, item.substitutes_for, item.ref_class
            ));
        }
    }
    body.push_str("\n## Terminal State Evidence\n\n");
    if terminal_state_refs.is_empty() {
        body.push_str("- none detected\n");
    } else {
        for item in terminal_state_refs {
            body.push_str(&format!(
                "- `{}`: `{}` ({})\n",
                item.ref_name, item.path, item.ref_class
            ));
        }
    }
    body.push_str("\n## Diagnostic/Historical Evidence\n\n");
    if diagnostic_refs.is_empty() {
        body.push_str("- none detected\n");
    } else {
        for item in diagnostic_refs {
            body.push_str(&format!(
                "- `{}`: `{}` ({})\n",
                item.ref_name, item.path, item.ref_class
            ));
        }
        body.push_str("- diagnostic rule: failing-slice evidence is historical troubleshooting evidence and must not override terminal blocker ledgers or terminal state receipts.\n");
    }
    body.push_str("\n## Associated Closeout Evidence\n\n");
    if associated_refs.is_empty() {
        body.push_str("- none detected\n");
    } else {
        for item in associated_refs {
            body.push_str(&format!(
                "- `{}`: `{}` ({})\n",
                item.ref_name, item.path, item.ref_class
            ));
        }
    }
    body.push_str("\n## Reconstruction Order\n\n");
    for item in reconstruction_order {
        body.push_str(&format!("- {item}\n"));
    }
    body.push_str("\n## Known Limits\n\n");
    if missing_refs.is_empty() {
        body.push_str("- none detected by deterministic binding\n");
    } else {
        for item in missing_refs {
            body.push_str(&format!("- missing `{}`: `{}`\n", item.ref_name, item.path));
        }
        body.push_str("- missing direct control refs are evidence gaps; use listed substitute refs before escalating, and do not infer missing facts from generated outputs, raw inputs, chat history, host state, dashboards, or model memory.\n");
    }
    body.push_str(
        "\n## Required Evaluator Boundary\n\nThe evaluator must reconstruct facts only from retained evidence refs and must treat unresolved missing refs as evidence gaps. Generated outputs, raw inputs, chat history, host state, dashboards, and postmortem reports are not authority. The report must preserve the full eighteen-section lifecycle postmortem contract from the template and structured output must use lifecycle-postmortem-evaluation-v2. Invariant compliance findings and invariant validity/evolution recommendations are evidence only and cannot approve lifecycle transition, closeout, promotion, support widening, generated-output publication, redesign, or invariant amendment.\n",
    );
    body
}

fn normalize_lifecycle_run_inputs(
    octon_dir: &Path,
    set_values: &[String],
    set_files: &[String],
) -> Result<BTreeMap<String, String>> {
    let repo_root = repo_root_for_octon(octon_dir)?;
    let mut inputs = BTreeMap::new();
    for raw in set_values {
        let (key, value) = parse_run_input_pair(raw, "--set")?;
        insert_run_input(&mut inputs, key, value.to_string())?;
    }
    for raw in set_files {
        let (key, value) = parse_run_input_pair(raw, "--set-file")?;
        let path = resolve_user_repo_path(&repo_root, Path::new(value), "--set-file path")?;
        let content = fs::read_to_string(&path)
            .with_context(|| format!("failed to read lifecycle input file {}", path.display()))?;
        insert_run_input(&mut inputs, key, content)?;
    }
    Ok(inputs)
}

fn lifecycle_interaction_refs_from_run_inputs(
    repo_root: &Path,
    run_inputs: &BTreeMap<String, String>,
) -> Result<(Vec<String>, Vec<String>)> {
    let request_refs = lifecycle_interaction_refs_for_keys(
        repo_root,
        run_inputs,
        &[
            "interaction_request_ref",
            "interaction_request_refs",
            "lifecycle_interaction_request_ref",
            "lifecycle_interaction_request_refs",
        ],
        "lifecycle-interaction-request-v1",
    )?;
    let return_refs = lifecycle_interaction_refs_for_keys(
        repo_root,
        run_inputs,
        &[
            "interaction_return_ref",
            "interaction_return_refs",
            "lifecycle_interaction_return_ref",
            "lifecycle_interaction_return_refs",
        ],
        "lifecycle-interaction-return-v1",
    )?;
    Ok((request_refs, return_refs))
}

fn lifecycle_interaction_refs_for_keys(
    repo_root: &Path,
    run_inputs: &BTreeMap<String, String>,
    keys: &[&str],
    expected_schema_version: &str,
) -> Result<Vec<String>> {
    let mut refs = Vec::new();
    for key in keys {
        let Some(raw) = run_inputs.get(*key) else {
            continue;
        };
        for value in raw
            .split(|ch: char| ch == ',' || ch == '\n' || ch.is_whitespace())
            .filter(|value| !value.trim().is_empty())
        {
            let rel = validate_lifecycle_interaction_ref(
                repo_root,
                value.trim(),
                expected_schema_version,
            )
            .with_context(|| format!("invalid lifecycle interaction ref from run input {key}"))?;
            if !refs.contains(&rel) {
                refs.push(rel);
            }
        }
    }
    Ok(refs)
}

fn validate_lifecycle_interaction_ref(
    repo_root: &Path,
    raw_ref: &str,
    expected_schema_version: &str,
) -> Result<String> {
    let path = resolve_user_repo_path(
        repo_root,
        Path::new(raw_ref),
        "lifecycle interaction receipt ref",
    )?;
    if !path.is_file() {
        bail!(
            "lifecycle interaction receipt ref missing or not a file: {}",
            raw_ref
        );
    }
    let value: serde_json::Value = serde_json::from_slice(&fs::read(&path)?)
        .with_context(|| format!("lifecycle interaction receipt ref must be JSON: {raw_ref}"))?;
    let Some(schema_version) = value.get("schema_version").and_then(|value| value.as_str()) else {
        bail!("lifecycle interaction receipt ref missing schema_version: {raw_ref}");
    };
    if schema_version != expected_schema_version {
        bail!(
            "lifecycle interaction receipt ref schema_version {schema_version} does not match {expected_schema_version}: {raw_ref}"
        );
    }
    Ok(rel_display(repo_root, &path))
}

fn parse_run_input_pair<'a>(raw: &'a str, flag: &str) -> Result<(&'a str, &'a str)> {
    let Some((key, value)) = raw.split_once('=') else {
        bail!("{flag} must use key=value syntax");
    };
    if !valid_run_input_key(key) {
        bail!("lifecycle run input key is invalid: {key}");
    }
    if value.is_empty() {
        bail!("lifecycle run input {key} must not be empty");
    }
    Ok((key, value))
}

fn insert_run_input(inputs: &mut BTreeMap<String, String>, key: &str, value: String) -> Result<()> {
    if inputs.insert(key.to_string(), value).is_some() {
        bail!("duplicate lifecycle run input: {key}");
    }
    Ok(())
}

fn valid_run_input_key(key: &str) -> bool {
    !key.is_empty()
        && key
            .chars()
            .all(|ch| ch.is_ascii_alphanumeric() || ch == '_' || ch == '-')
}

fn cancel_lifecycle_run(octon_dir: &Path, run_id: &str, reason: &str) -> Result<Value> {
    if lifecycle_program::program_checkpoint_exists(octon_dir, run_id)? {
        return Ok(serde_yaml::to_value(
            lifecycle_program::cancel_program_lifecycle_run(octon_dir, run_id, reason)?,
        )?);
    }
    Ok(serde_yaml::to_value(cancel_packet_lifecycle_run(
        octon_dir, run_id, reason,
    )?)?)
}

fn cancel_packet_lifecycle_run(
    octon_dir: &Path,
    run_id: &str,
    reason: &str,
) -> Result<LifecycleControlResult> {
    let sanitized_run_id = sanitize_run_id(run_id)?;
    let control_root = octon_dir.join(RUN_CONTROL_ROOT_REL).join(&sanitized_run_id);
    let evidence_root = octon_dir
        .join(WORKFLOW_EVIDENCE_ROOT_REL)
        .join(&sanitized_run_id);
    let checkpoint_path = control_root.join("lifecycle-checkpoint.yml");
    if !checkpoint_path.is_file() {
        bail!("no retained lifecycle checkpoint found for run id {sanitized_run_id}");
    }
    fs::create_dir_all(&control_root)?;
    fs::create_dir_all(&evidence_root)?;
    let mut checkpoint: LifecycleCheckpoint = serde_yaml::from_slice(&fs::read(&checkpoint_path)?)?;
    let cancelled_at = checkpoint.cancelled_at.clone().unwrap_or(now_rfc3339()?);
    let cancellation_token = lifecycle_cancellation_token_path(&control_root);
    let cancellation_evidence = lifecycle_cancelled_evidence_path(&evidence_root);
    let repo_root = repo_root_for_octon(octon_dir)?;
    let content = format!(
        "schema_version: octon-lifecycle-cancellation-v1\nrun_id: {}\nlifecycle_id: {}\nexecution_strategy: {}\ntarget: {}\nreason: {}\ncancelled_at: {}\ncancellation_token: {}\ncheckpoint_path: {}\n",
        sanitized_run_id,
        checkpoint.lifecycle_id,
        checkpoint.execution_strategy,
        checkpoint.target,
        reason,
        cancelled_at,
        rel_display(&repo_root, &cancellation_token),
        rel_display(&repo_root, &checkpoint_path)
    );
    fs::write(&cancellation_token, &content)?;
    fs::write(&cancellation_evidence, &content)?;
    append_lifecycle_run_started_if_needed(
        &control_root,
        &evidence_root,
        &sanitized_run_id,
        &checkpoint.lifecycle_id,
        &checkpoint.execution_strategy,
        Path::new(&checkpoint.target),
    )?;
    let mut data = BTreeMap::new();
    data.insert("reason".to_string(), reason.to_string());
    data.insert(
        "cancellation_token".to_string(),
        rel_display(&repo_root, &cancellation_token),
    );
    data.insert(
        "cancellation_evidence_path".to_string(),
        rel_display(&repo_root, &cancellation_evidence),
    );
    append_lifecycle_event(
        &control_root,
        &evidence_root,
        &sanitized_run_id,
        &checkpoint.lifecycle_id,
        &checkpoint.execution_strategy,
        Path::new(&checkpoint.target),
        "cancelled",
        "control",
        "operator",
        None,
        None,
        None,
        None,
        None,
        Some("cancelled"),
        data,
    )?;
    checkpoint.cancelled_at = Some(cancelled_at.clone());
    checkpoint.cancel_reason = Some(reason.to_string());
    checkpoint.cancellation_evidence_path = Some(rel_display(&repo_root, &cancellation_evidence));
    checkpoint.final_verdict = "cancelled".to_string();
    checkpoint.terminal_outcome = Some("cancelled".to_string());
    checkpoint.resume_instruction = "cancelled lifecycle runs cannot resume dispatch".to_string();
    fs::write(&checkpoint_path, serde_yaml::to_string(&checkpoint)?)?;
    fs::write(
        evidence_root.join("summary.md"),
        lifecycle_cancelled_summary(&checkpoint, &cancelled_at),
    )?;
    Ok(LifecycleControlResult {
        schema_version: "octon-lifecycle-control-result-v1",
        run_id: sanitized_run_id,
        control: "cancel".to_string(),
        final_verdict: "cancelled".to_string(),
        checkpoint_path: rel_display(&repo_root, &checkpoint_path),
        evidence_path: rel_display(&repo_root, &cancellation_evidence),
        recorded_at: cancelled_at,
        reason: reason.to_string(),
    })
}

fn lifecycle_cancelled_summary(checkpoint: &LifecycleCheckpoint, cancelled_at: &str) -> String {
    format!(
        "# Lifecycle Run\n\nrun_id: {}\nrecorded_at: {}\nlifecycle_id: {}\nexecution_strategy: {}\ntarget: {}\nroute_execution_mode: none\nselected_route: none\nterminal_outcome: cancelled\nfinal_verdict: cancelled\n\nNote: this lifecycle run was cancelled durably. Resume and execute-routes operations must not dispatch routes for this run.\n",
        checkpoint.run_id,
        cancelled_at,
        checkpoint.lifecycle_id,
        checkpoint.execution_strategy,
        checkpoint.target,
    )
}

fn lifecycle_cancelled_run_result(
    repo_root: &Path,
    evidence_root: &Path,
    checkpoint_path: &Path,
    checkpoint: &LifecycleCheckpoint,
    executor: &str,
) -> LifecycleRunResult {
    LifecycleRunResult {
        schema_version: "octon-lifecycle-run-result-v1".to_string(),
        run_id: checkpoint.run_id.clone(),
        lifecycle_id: checkpoint.lifecycle_id.clone(),
        execution_strategy: checkpoint.execution_strategy.clone(),
        target: checkpoint.target.clone(),
        executor: executor.to_string(),
        route_execution_mode: "none".to_string(),
        bundle_root: rel_display(repo_root, evidence_root),
        checkpoint_path: rel_display(repo_root, checkpoint_path),
        selected_route: None,
        current_phase: checkpoint.current_phase.clone(),
        terminal_outcome: Some("cancelled".to_string()),
        interaction_request_refs: checkpoint.interaction_request_refs.clone(),
        interaction_return_refs: checkpoint.interaction_return_refs.clone(),
        final_verdict: "cancelled".to_string(),
    }
}

pub(crate) fn plan_lifecycle_from_octon_dir(
    octon_dir: &Path,
    lifecycle_id: &str,
    target: &Path,
) -> Result<LifecyclePlanResult> {
    let repo_root = repo_root_for_octon(octon_dir)?;
    let loaded = load_lifecycle_contract(octon_dir, lifecycle_id)?;
    let execution_strategy = resolve_lifecycle_execution_strategy(&loaded.contract)?;
    if execution_strategy != LifecycleExecutionStrategy::RouteProgression {
        bail!(
            "lifecycle {} uses execution_strategy {}; use the program lifecycle runner",
            lifecycle_id,
            execution_strategy.as_str()
        );
    }
    let target_abs = resolve_lifecycle_target_path(&repo_root, target)?;
    let target_state = build_target_state(&repo_root, &loaded.contract, &target_abs)?;
    let terminal_outcome = select_terminal_outcome(&loaded.contract, &target_state)?;
    let mut selected_route = if terminal_outcome.is_some() {
        None
    } else {
        select_route(&loaded.contract, &target_state)?
    };
    let mut final_verdict = if terminal_outcome.is_some() {
        "completed".to_string()
    } else if selected_route.is_some() {
        "route-ready".to_string()
    } else {
        "blocked-no-route".to_string()
    };

    let mut gate_results = Vec::new();
    let mut blocked_by_gate = None;
    if let Some(route) = selected_route.as_ref() {
        let results =
            run_required_gates(&repo_root, &loaded.contract, &target_abs, &route.route_id)?;
        if let Some(failed) = results.iter().find(|result| !result.passed) {
            blocked_by_gate = Some(failed.gate_id.clone());
            if let Some(fallback) = fallback_route_for_gate(&loaded.contract, &failed.gate_id) {
                selected_route = route_by_id(&loaded.contract, &fallback).cloned();
                final_verdict = "gate-rerouted".to_string();
            } else {
                final_verdict = "blocked-gate".to_string();
            }
        }
        gate_results = results;
    }

    let receipt_states = receipt_plan_states(&repo_root, &loaded.contract, &target_state);
    if selected_route_reuses_worktree_hygiene_blocked_closeout(
        selected_route.as_ref(),
        &receipt_states,
    ) {
        selected_route = None;
        final_verdict = "blocked-no-route".to_string();
    }
    let (blocker_class, blocker_message) =
        lifecycle_plan_blocker_for_receipts(&final_verdict, &receipt_states);
    let current_phase = current_phase_for_plan(
        &loaded.contract,
        selected_route.as_ref().map(|route| route.route_id.as_str()),
        terminal_outcome.as_deref(),
        &final_verdict,
    );
    let phase_blockers = phase_blockers_for_plan(
        &final_verdict,
        blocked_by_gate.as_deref(),
        blocker_class.as_deref(),
        blocker_message.as_deref(),
    );

    Ok(LifecyclePlanResult {
        schema_version: "octon-lifecycle-plan-v1".to_string(),
        lifecycle_id: loaded.contract.lifecycle_id.clone(),
        owner_extension: loaded.contract.owner_extension.clone(),
        execution_strategy: execution_strategy.as_str().to_string(),
        contract_path: rel_display(&repo_root, &loaded.path),
        target: rel_display(&repo_root, &target_abs),
        target_exists: target_state.target_exists,
        manifest_status: target_state.manifest_status.clone(),
        receipt_states,
        terminal_outcome,
        next_route: selected_route.map(route_plan_state),
        gate_results,
        blocked_by_gate,
        checkpoint_drift: None,
        phase_loop_model: phase_loop_model(&loaded.contract),
        current_phase,
        phase_blockers,
        blocker_class,
        blocker_message,
        final_verdict,
    })
}

pub(crate) fn run_lifecycle_from_octon_dir(
    octon_dir: &Path,
    options: RunLifecycleOptions,
) -> Result<LifecycleRunResult> {
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
    let checkpoint_path = control_root.join("lifecycle-checkpoint.yml");

    let loaded = load_lifecycle_contract(octon_dir, &options.lifecycle_id)?;
    let execution_strategy = resolve_lifecycle_execution_strategy(&loaded.contract)?;
    if execution_strategy != LifecycleExecutionStrategy::RouteProgression {
        bail!(
            "lifecycle {} uses execution_strategy {}; use the program lifecycle runner",
            options.lifecycle_id,
            execution_strategy.as_str()
        );
    }
    let target_abs = resolve_lifecycle_target_path(&repo_root, &options.target)?;
    let target_rel = rel_display(&repo_root, &target_abs);
    let mut plan =
        plan_lifecycle_from_octon_dir(octon_dir, &options.lifecycle_id, &options.target)?;
    let previous_checkpoint = read_checkpoint_for_run(octon_dir, &run_id)?;
    if let Some(checkpoint) = previous_checkpoint.as_ref() {
        validate_checkpoint_binding(
            checkpoint,
            &sanitized_run_id,
            &options.lifecycle_id,
            execution_strategy.as_str(),
            &target_rel,
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
                    "lifecycle run id {sanitized_run_id} is already bound to different run inputs"
                );
            }
        }
        options.run_inputs.clone()
    };
    let (interaction_request_refs, interaction_return_refs) =
        lifecycle_interaction_refs_from_run_inputs(&repo_root, &run_inputs)?;
    let mut loop_counts = previous_checkpoint
        .as_ref()
        .map(|checkpoint| checkpoint.loop_counts.clone())
        .unwrap_or_default();
    let mut final_verdict = plan.final_verdict.clone();

    fs::create_dir_all(&evidence_root)?;
    fs::create_dir_all(&control_root)?;
    append_lifecycle_run_started_if_needed(
        &control_root,
        &evidence_root,
        &sanitized_run_id,
        &options.lifecycle_id,
        execution_strategy.as_str(),
        &target_abs,
    )?;
    if let Some(checkpoint) = previous_checkpoint.as_ref() {
        if lifecycle_checkpoint_cancelled(checkpoint)
            || lifecycle_cancellation_token_path(&control_root).exists()
        {
            return Ok(lifecycle_cancelled_run_result(
                &repo_root,
                &evidence_root,
                &checkpoint_path,
                checkpoint,
                options.executor.as_str(),
            ));
        }
    }

    if let Some(route) = plan.next_route.as_ref() {
        if route_has_skip_when_target_exists(&loaded.contract, &route.route_id)
            && target_abs.exists()
        {
            final_verdict = "skipped-idempotent".to_string();
        } else if let Some(loop_spec) = loop_for_route(&loaded.contract, &route.route_id) {
            let count = loop_counts.entry(loop_spec.loop_id.clone()).or_insert(0);
            let max_iterations = options.max_iterations.unwrap_or(loop_spec.max_iterations);
            if *count >= max_iterations {
                final_verdict = "blocked-max-iterations".to_string();
            } else if matches!(options.executor, ExecutorKind::Mock) {
                *count += 1;
                final_verdict = "mock-route-executed".to_string();
            } else if options.execute_routes {
                *count += 1;
                final_verdict = "route-ready".to_string();
            } else {
                final_verdict = "route-ready".to_string();
            }
        } else if plan.terminal_outcome.is_some() {
            final_verdict = "completed".to_string();
        } else if matches!(options.executor, ExecutorKind::Mock) {
            final_verdict = "mock-route-executed".to_string();
        } else if final_verdict == "route-ready" {
            final_verdict = "route-ready".to_string();
        }
    }

    if plan.next_route.is_none() && plan.terminal_outcome.is_some() {
        final_verdict = "completed".to_string();
    }
    plan.final_verdict = final_verdict.clone();
    plan.current_phase = current_phase_for_plan(
        &loaded.contract,
        plan.next_route
            .as_ref()
            .map(|route| route.route_id.as_str()),
        plan.terminal_outcome.as_deref(),
        &final_verdict,
    );
    plan.phase_blockers = phase_blockers_for_plan(
        &final_verdict,
        plan.blocked_by_gate.as_deref(),
        plan.blocker_class.as_deref(),
        plan.blocker_message.as_deref(),
    );

    let mut phase_counts = previous_checkpoint
        .as_ref()
        .map(|checkpoint| checkpoint.phase_counts.clone())
        .unwrap_or_default();
    if let Some(phase_id) = plan.current_phase.as_ref() {
        *phase_counts.entry(phase_id.clone()).or_insert(0) += 1;
    }
    let last_phase_transition = plan
        .current_phase
        .as_ref()
        .map(|phase_id| phase_transition_id("phase-entered", phase_id));

    let checkpoint = LifecycleCheckpoint {
        schema_version: "octon-lifecycle-checkpoint-v1".to_string(),
        run_id: sanitized_run_id.clone(),
        lifecycle_id: options.lifecycle_id.clone(),
        execution_strategy: execution_strategy.as_str().to_string(),
        target: target_rel.clone(),
        current_state: plan
            .next_route
            .as_ref()
            .map(|route| route.route_id.clone())
            .or_else(|| plan.terminal_outcome.clone()),
        current_phase: plan.current_phase.clone(),
        completed_states: if final_verdict == "mock-route-executed" {
            plan.next_route
                .as_ref()
                .map(|route| vec![route.route_id.clone()])
                .unwrap_or_default()
        } else if final_verdict == "completed" {
            plan.terminal_outcome
                .as_ref()
                .map(|outcome| vec![outcome.clone()])
                .unwrap_or_default()
        } else {
            Vec::new()
        },
        last_route: plan.next_route.as_ref().map(|route| route.route_id.clone()),
        loop_counts,
        phase_counts,
        last_phase_transition,
        phase_blockers: plan.phase_blockers.clone(),
        receipt_digests: receipt_digest_map(&plan),
        last_validator_results: plan.gate_results.clone(),
        run_inputs,
        interaction_request_refs: interaction_request_refs.clone(),
        interaction_return_refs: interaction_return_refs.clone(),
        cancelled_at: previous_checkpoint
            .as_ref()
            .and_then(|checkpoint| checkpoint.cancelled_at.clone()),
        cancel_reason: previous_checkpoint
            .as_ref()
            .and_then(|checkpoint| checkpoint.cancel_reason.clone()),
        cancellation_evidence_path: previous_checkpoint
            .as_ref()
            .and_then(|checkpoint| checkpoint.cancellation_evidence_path.clone()),
        terminal_outcome: plan.terminal_outcome.clone(),
        final_verdict: final_verdict.clone(),
        resume_instruction: format!("octon lifecycle resume --run-id {}", sanitized_run_id),
    };
    fs::write(&checkpoint_path, serde_yaml::to_string(&checkpoint)?)?;
    fs::write(
        evidence_root.join("plan.yml"),
        serde_yaml::to_string(&plan)?,
    )?;
    fs::write(
        evidence_root.join("summary.md"),
        lifecycle_summary(&sanitized_run_id, &options.executor, &plan, &final_verdict),
    )?;
    write_run_inputs_evidence(&evidence_root, &checkpoint.run_id, &checkpoint.run_inputs)?;
    fs::write(
        evidence_root.join("commands.md"),
        lifecycle_commands(&options.lifecycle_id, &target_abs, plan.next_route.as_ref()),
    )?;
    if let Some(phase_id) = plan.current_phase.as_ref() {
        append_lifecycle_event(
            &control_root,
            &evidence_root,
            &sanitized_run_id,
            &options.lifecycle_id,
            execution_strategy.as_str(),
            &target_abs,
            "phase-entered",
            "phase",
            "runtime",
            None,
            None,
            None,
            plan.next_route
                .as_ref()
                .map(|route| route.route_id.as_str()),
            None,
            Some(&final_verdict),
            phase_transition_event_data(phase_id, "phase-entered"),
        )?;
    }
    if !interaction_request_refs.is_empty() || !interaction_return_refs.is_empty() {
        let mut interaction_data = BTreeMap::new();
        insert_interaction_event_context(
            &mut interaction_data,
            &interaction_request_refs,
            &interaction_return_refs,
        );
        interaction_data.insert(
            "authority".to_string(),
            "non-authorizing-context".to_string(),
        );
        insert_phase_event_context(&mut interaction_data, plan.current_phase.as_deref());
        append_lifecycle_event(
            &control_root,
            &evidence_root,
            &sanitized_run_id,
            &options.lifecycle_id,
            execution_strategy.as_str(),
            &target_abs,
            "interaction-context-recorded",
            "interaction",
            "runtime",
            None,
            None,
            None,
            plan.next_route
                .as_ref()
                .map(|route| route.route_id.as_str()),
            None,
            Some(&final_verdict),
            interaction_data,
        )?;
    }
    let mut event_data = BTreeMap::new();
    event_data.insert("final_verdict".to_string(), final_verdict.clone());
    if let Some(route) = plan.next_route.as_ref() {
        event_data.insert("selected_route".to_string(), route.route_id.clone());
    }
    insert_interaction_event_context(
        &mut event_data,
        &interaction_request_refs,
        &interaction_return_refs,
    );
    insert_phase_event_context(&mut event_data, plan.current_phase.as_deref());
    append_lifecycle_event(
        &control_root,
        &evidence_root,
        &sanitized_run_id,
        &options.lifecycle_id,
        execution_strategy.as_str(),
        &target_abs,
        "plan-created",
        "planning",
        "runtime",
        None,
        None,
        None,
        plan.next_route
            .as_ref()
            .map(|route| route.route_id.as_str()),
        None,
        Some(&final_verdict),
        event_data,
    )?;
    if !options.execute_routes && plan.next_route.is_some() && final_verdict == "route-ready" {
        let mut event_data = BTreeMap::new();
        insert_interaction_event_context(
            &mut event_data,
            &interaction_request_refs,
            &interaction_return_refs,
        );
        insert_phase_event_context(&mut event_data, plan.current_phase.as_deref());
        append_lifecycle_event(
            &control_root,
            &evidence_root,
            &sanitized_run_id,
            &options.lifecycle_id,
            execution_strategy.as_str(),
            &target_abs,
            "route-handoff",
            "handoff",
            "runtime",
            None,
            None,
            None,
            plan.next_route
                .as_ref()
                .map(|route| route.route_id.as_str()),
            None,
            Some(&final_verdict),
            event_data,
        )?;
    } else if classify_lifecycle_status(&final_verdict).is_terminal_or_blocked() {
        let mut status_event_data = BTreeMap::new();
        insert_interaction_event_context(
            &mut status_event_data,
            &interaction_request_refs,
            &interaction_return_refs,
        );
        insert_phase_event_context(&mut status_event_data, plan.current_phase.as_deref());
        append_lifecycle_event(
            &control_root,
            &evidence_root,
            &sanitized_run_id,
            &options.lifecycle_id,
            execution_strategy.as_str(),
            &target_abs,
            if final_verdict == "completed" {
                "completed"
            } else {
                "blocked"
            },
            "status",
            "runtime",
            None,
            None,
            None,
            plan.next_route
                .as_ref()
                .map(|route| route.route_id.as_str()),
            None,
            Some(&final_verdict),
            status_event_data,
        )?;
        if let Some(phase_id) = plan.current_phase.as_ref() {
            let phase_event_type = if final_verdict == "completed" {
                "phase-exited"
            } else {
                "phase-blocked"
            };
            append_lifecycle_event(
                &control_root,
                &evidence_root,
                &sanitized_run_id,
                &options.lifecycle_id,
                execution_strategy.as_str(),
                &target_abs,
                phase_event_type,
                "phase",
                "runtime",
                None,
                None,
                None,
                plan.next_route
                    .as_ref()
                    .map(|route| route.route_id.as_str()),
                None,
                Some(&final_verdict),
                phase_transition_event_data(phase_id, phase_event_type),
            )?;
        }
    }

    Ok(LifecycleRunResult {
        schema_version: "octon-lifecycle-run-result-v1".to_string(),
        run_id: sanitized_run_id,
        lifecycle_id: options.lifecycle_id,
        execution_strategy: execution_strategy.as_str().to_string(),
        target: target_rel,
        executor: options.executor.as_str().to_string(),
        route_execution_mode: route_execution_mode(
            &options.executor,
            &final_verdict,
            plan.next_route.is_some(),
            plan.terminal_outcome.is_some(),
        )
        .to_string(),
        bundle_root: rel_display(&repo_root, &evidence_root),
        checkpoint_path: rel_display(&repo_root, &checkpoint_path),
        selected_route: plan.next_route,
        current_phase: plan.current_phase,
        terminal_outcome: plan.terminal_outcome,
        interaction_request_refs,
        interaction_return_refs,
        final_verdict,
    })
}

pub(crate) fn resume_lifecycle_from_octon_dir(
    octon_dir: &Path,
    run_id: &str,
) -> Result<LifecycleRunResult> {
    let checkpoint = read_checkpoint_for_run(octon_dir, run_id)?
        .with_context(|| format!("missing lifecycle checkpoint for run {run_id}"))?;
    let sanitized_run_id = sanitize_run_id(run_id)?;
    let repo_root = repo_root_for_octon(octon_dir)?;
    let target = PathBuf::from(&checkpoint.target);
    let loaded = load_lifecycle_contract(octon_dir, &checkpoint.lifecycle_id)?;
    let execution_strategy = resolve_lifecycle_execution_strategy(&loaded.contract)?;
    if execution_strategy != LifecycleExecutionStrategy::RouteProgression {
        bail!(
            "lifecycle {} uses execution_strategy {}; use the program lifecycle runner",
            checkpoint.lifecycle_id,
            execution_strategy.as_str()
        );
    }
    if checkpoint.execution_strategy != execution_strategy.as_str() {
        bail!(
            "lifecycle run id {sanitized_run_id} checkpoint execution_strategy {} differs from loaded contract strategy {}",
            checkpoint.execution_strategy,
            execution_strategy.as_str()
        );
    }
    let control_root = octon_dir.join(RUN_CONTROL_ROOT_REL).join(&sanitized_run_id);
    let evidence_root = octon_dir
        .join(WORKFLOW_EVIDENCE_ROOT_REL)
        .join(&sanitized_run_id);
    let checkpoint_path = control_root.join("lifecycle-checkpoint.yml");
    if lifecycle_checkpoint_cancelled(&checkpoint)
        || lifecycle_cancellation_token_path(&control_root).exists()
    {
        return Ok(lifecycle_cancelled_run_result(
            &repo_root,
            &evidence_root,
            &checkpoint_path,
            &checkpoint,
            "resume",
        ));
    }
    let mut plan = plan_lifecycle_from_octon_dir(octon_dir, &checkpoint.lifecycle_id, &target)?;
    let reconstructed = plan
        .next_route
        .as_ref()
        .map(|route| route.route_id.clone())
        .or_else(|| plan.terminal_outcome.clone());
    let checkpoint_phase_drifted = plan.current_phase != checkpoint.current_phase;
    let checkpoint_drifted = reconstructed != checkpoint.current_state || checkpoint_phase_drifted;
    if checkpoint_drifted {
        plan.checkpoint_drift = Some(format!(
            "checkpoint current_state {:?} / current_phase {:?} differed from target-derived state {:?} / phase {:?}; target receipts were trusted",
            checkpoint.current_state, checkpoint.current_phase, reconstructed, plan.current_phase
        ));
    } else if checkpoint.final_verdict == "blocked-max-iterations" {
        plan.final_verdict = "blocked-max-iterations".to_string();
    } else if let Some(route) = plan.next_route.as_ref() {
        if let Some(loop_spec) = loop_for_route(&loaded.contract, &route.route_id) {
            let count = checkpoint
                .loop_counts
                .get(&loop_spec.loop_id)
                .copied()
                .unwrap_or_default();
            if count >= loop_spec.max_iterations {
                plan.final_verdict = "blocked-max-iterations".to_string();
            }
        }
    }

    fs::create_dir_all(&evidence_root)?;
    fs::write(
        evidence_root.join("resume-plan.yml"),
        serde_yaml::to_string(&plan)?,
    )?;

    Ok(LifecycleRunResult {
        schema_version: "octon-lifecycle-run-result-v1".to_string(),
        run_id: sanitized_run_id.clone(),
        lifecycle_id: checkpoint.lifecycle_id,
        execution_strategy: execution_strategy.as_str().to_string(),
        target: rel_display(
            &repo_root,
            &resolve_lifecycle_target_path(&repo_root, &target)?,
        ),
        executor: "resume".to_string(),
        route_execution_mode: route_execution_mode(
            &ExecutorKind::Auto,
            &plan.final_verdict,
            plan.next_route.is_some(),
            plan.terminal_outcome.is_some(),
        )
        .to_string(),
        bundle_root: rel_display(&repo_root, &evidence_root),
        checkpoint_path: rel_display(&repo_root, &checkpoint_path),
        selected_route: plan.next_route,
        current_phase: plan.current_phase,
        terminal_outcome: plan.terminal_outcome,
        interaction_request_refs: checkpoint.interaction_request_refs,
        interaction_return_refs: checkpoint.interaction_return_refs,
        final_verdict: plan.final_verdict,
    })
}

fn load_lifecycle_contract(octon_dir: &Path, lifecycle_id: &str) -> Result<LoadedContract> {
    let path = contract_path_from_effective_catalog(octon_dir, lifecycle_id)?;
    read_lifecycle_contract(&path)
}

fn lifecycle_execution_strategy_from_octon_dir(
    octon_dir: &Path,
    lifecycle_id: &str,
) -> Result<LifecycleExecutionStrategy> {
    let loaded = load_lifecycle_contract(octon_dir, lifecycle_id)?;
    resolve_lifecycle_execution_strategy(&loaded.contract)
}

fn resolve_lifecycle_execution_strategy(
    contract: &LifecycleContract,
) -> Result<LifecycleExecutionStrategy> {
    let has_program = contract.program.is_some();
    let strategy = contract.execution_strategy.unwrap_or(if has_program {
        LifecycleExecutionStrategy::OrchestratedReplanLoop
    } else {
        LifecycleExecutionStrategy::RouteProgression
    });
    match (strategy, has_program) {
        (LifecycleExecutionStrategy::RouteProgression, true) => {
            bail!(
                "lifecycle contract {} declares program orchestration but execution_strategy is {}; program lifecycles require {}",
                contract.lifecycle_id,
                strategy.as_str(),
                LifecycleExecutionStrategy::OrchestratedReplanLoop.as_str()
            )
        }
        (LifecycleExecutionStrategy::OrchestratedReplanLoop, false) => {
            bail!(
                "lifecycle contract {} declares execution_strategy {} without a program section; non-program orchestration is not supported",
                contract.lifecycle_id,
                strategy.as_str()
            )
        }
        _ => Ok(strategy),
    }
}

fn contract_path_from_effective_catalog(octon_dir: &Path, lifecycle_id: &str) -> Result<PathBuf> {
    let catalog_path = generated_effective_extension_catalog_path(octon_dir)?;
    if !catalog_path.is_file() {
        bail!(
            "effective extension catalog missing; publish extension state before running lifecycle {lifecycle_id}"
        );
    }
    let catalog: Value = serde_yaml::from_slice(&fs::read(&catalog_path)?)?;
    let Some(packs) = catalog.get("packs").and_then(Value::as_sequence) else {
        bail!("effective extension catalog has no packs for lifecycle discovery");
    };
    let repo_root = repo_root_for_octon(octon_dir)?;
    for pack in packs {
        let Some(contracts) = pack.get("lifecycle_contracts").and_then(Value::as_sequence) else {
            continue;
        };
        if contracts.is_empty() {
            continue;
        }
        if !value_sequence_contains(pack.get("capability_profiles"), "lifecycle-contract") {
            let pack_id = scalar_str(pack.get("pack_id")).unwrap_or("<unknown>");
            bail!(
                "effective extension catalog pack {pack_id} declares lifecycle contracts without lifecycle-contract capability profile"
            );
        }
        for contract in contracts {
            if scalar_str(contract.get("lifecycle_id")) != Some(lifecycle_id) {
                continue;
            }
            let Some(raw) = scalar_str(contract.get("projection_source_path")) else {
                bail!("published lifecycle contract missing projection_source_path for {lifecycle_id}");
            };
            let path = generated_lifecycle_contract_path(&repo_root, lifecycle_id, raw)?;
            if path.is_file() {
                return Ok(path);
            }
            bail!(
                "published lifecycle contract projection missing for {lifecycle_id}: {}",
                path.display()
            );
        }
    }
    bail!("lifecycle contract not found in effective extension catalog: {lifecycle_id}");
}

fn generated_lifecycle_contract_path(
    repo_root: &Path,
    lifecycle_id: &str,
    raw: &str,
) -> Result<PathBuf> {
    if !is_safe_repo_relative(raw)
        || !raw.starts_with(GENERATED_EXTENSION_PUBLISHED_PREFIX)
        || !is_generated_lifecycle_contract_projection(raw)
    {
        bail!(
            "published lifecycle contract projection path for {lifecycle_id} must be under {GENERATED_EXTENSION_PUBLISHED_PREFIX} and end with /context/lifecycle.contract.yml or /context/lifecycles/<id>.contract.yml: {raw}"
        );
    }
    let path = resolve_repo_str(repo_root, raw);
    if path.exists() {
        let generated_root = repo_root
            .join(GENERATED_EXTENSION_PUBLISHED_PREFIX)
            .canonicalize()
            .context("generated published extension root missing")?;
        let canonical_path = path.canonicalize().with_context(|| {
            format!(
                "failed to canonicalize lifecycle projection {}",
                path.display()
            )
        })?;
        if !canonical_path.starts_with(&generated_root) {
            bail!(
                "published lifecycle contract projection escapes generated published extension root for {lifecycle_id}: {}",
                path.display()
            );
        }
    }
    Ok(path)
}

fn is_generated_lifecycle_contract_projection(raw: &str) -> bool {
    raw.ends_with("/context/lifecycle.contract.yml")
        || (raw.contains("/context/lifecycles/") && raw.ends_with(".contract.yml"))
}

fn read_lifecycle_contract(path: &Path) -> Result<LoadedContract> {
    let contract: LifecycleContract = serde_yaml::from_slice(
        &fs::read(path).with_context(|| format!("failed to read {}", path.display()))?,
    )
    .with_context(|| format!("failed to parse lifecycle contract {}", path.display()))?;
    resolve_lifecycle_execution_strategy(&contract)
        .with_context(|| format!("invalid lifecycle contract {}", path.display()))?;
    Ok(LoadedContract {
        path: path.to_path_buf(),
        contract,
    })
}

fn build_target_state(
    repo_root: &Path,
    contract: &LifecycleContract,
    target_abs: &Path,
) -> Result<TargetState> {
    let target_exists = target_abs.exists();
    let manifest_status = read_manifest_status(target_abs, contract)?;
    let mut receipts = BTreeMap::new();
    for receipt in &contract.receipts {
        let path_abs = resolve_target_local_path(
            target_abs,
            &receipt.path,
            &format!("receipt path {}", receipt.receipt_id),
        )?;
        let exists = path_abs.is_file();
        let fields = if exists {
            parse_receipt_fields(&path_abs)?
        } else {
            BTreeMap::new()
        };
        let missing_required_fields = receipt
            .required_fields
            .iter()
            .filter(|field| {
                fields
                    .get(field.as_str())
                    .map(|value| value.trim().is_empty())
                    .unwrap_or(true)
            })
            .cloned()
            .collect::<Vec<_>>();
        let mut stored_digest = None;
        let mut current_digest = None;
        let mut stale = None;
        if exists {
            if let Some(freshness) = receipt.freshness.as_ref() {
                stored_digest = fields.get(&freshness.digest_field).cloned();
                current_digest = run_digest_command(
                    repo_root,
                    &contract.owner_extension,
                    target_abs,
                    &freshness.digest_command,
                )
                .with_context(|| format!("failed freshness digest for {}", receipt.receipt_id))?;
                stale = Some(stored_digest.as_deref() != current_digest.as_deref());
            }
        }
        receipts.insert(
            receipt.receipt_id.clone(),
            ReceiptState {
                path_abs,
                exists,
                fields,
                missing_required_fields,
                stale,
                stored_digest,
                current_digest,
            },
        );
    }
    Ok(TargetState {
        target_abs: target_abs.to_path_buf(),
        target_exists,
        manifest_status,
        receipts,
    })
}

fn read_manifest_status(target_abs: &Path, contract: &LifecycleContract) -> Result<Option<String>> {
    let manifest_path = resolve_target_local_path(
        target_abs,
        &contract.target.manifest_path,
        "target manifest path",
    )?;
    if !manifest_path.is_file() {
        return Ok(None);
    }
    let manifest: Value = serde_yaml::from_slice(&fs::read(&manifest_path)?)?;
    Ok(
        lookup_dotted_field(&manifest, &contract.target.status_field)
            .and_then(|value| scalar_str(Some(value)).map(str::to_string)),
    )
}

fn select_route(
    contract: &LifecycleContract,
    target_state: &TargetState,
) -> Result<Option<RouteSpec>> {
    select_route_with_context(
        contract,
        target_state,
        &LifecycleConditionContext::default(),
    )
}

fn select_route_with_context(
    contract: &LifecycleContract,
    target_state: &TargetState,
    condition_context: &LifecycleConditionContext,
) -> Result<Option<RouteSpec>> {
    for route in &contract.routes {
        if route_matches_with_context(route, contract, target_state, condition_context)? {
            return Ok(Some(route.clone()));
        }
    }
    Ok(None)
}

fn route_matches_with_context(
    route: &RouteSpec,
    contract: &LifecycleContract,
    target_state: &TargetState,
    condition_context: &LifecycleConditionContext,
) -> Result<bool> {
    match route.enter_when.as_ref() {
        Some(condition) => {
            eval_condition_with_context(condition, contract, target_state, condition_context)
        }
        None => Ok(false),
    }
}

fn select_terminal_outcome(
    contract: &LifecycleContract,
    target_state: &TargetState,
) -> Result<Option<String>> {
    for outcome in &contract.terminal_outcomes {
        let matches = match outcome.when.as_ref() {
            Some(condition) => eval_condition(condition, contract, target_state)?,
            None => false,
        };
        if matches {
            return Ok(Some(outcome.outcome_id.clone()));
        }
    }
    Ok(None)
}

fn eval_condition(
    condition: &Value,
    contract: &LifecycleContract,
    target_state: &TargetState,
) -> Result<bool> {
    eval_condition_with_context(
        condition,
        contract,
        target_state,
        &LifecycleConditionContext::default(),
    )
}

fn eval_condition_with_context(
    condition: &Value,
    contract: &LifecycleContract,
    target_state: &TargetState,
    condition_context: &LifecycleConditionContext,
) -> Result<bool> {
    let Some(mapping) = condition.as_mapping() else {
        bail!("lifecycle conditions must be mappings");
    };
    for (key, value) in mapping {
        let Some(key) = key.as_str() else {
            bail!("lifecycle condition key must be a string");
        };
        let matched = match key {
            "all" => value
                .as_sequence()
                .context("all condition must be a sequence")?
                .iter()
                .map(|item| {
                    eval_condition_with_context(item, contract, target_state, condition_context)
                })
                .collect::<Result<Vec<_>>>()?
                .into_iter()
                .all(|item| item),
            "any" => value
                .as_sequence()
                .context("any condition must be a sequence")?
                .iter()
                .map(|item| {
                    eval_condition_with_context(item, contract, target_state, condition_context)
                })
                .collect::<Result<Vec<_>>>()?
                .into_iter()
                .any(|item| item),
            "target_missing" => value.as_bool().unwrap_or(false) == !target_state.target_exists,
            "manifest_status" => scalar_str(Some(value)) == target_state.manifest_status.as_deref(),
            "blocker_present" => {
                let Some(blocker_class) = scalar_str(Some(value)) else {
                    bail!("blocker_present condition must be a blocker class string");
                };
                condition_context
                    .blockers
                    .iter()
                    .any(|candidate| candidate == blocker_class)
            }
            "cleanup_candidates_present" => {
                let expected = value
                    .as_bool()
                    .context("cleanup_candidates_present condition must be boolean")?;
                condition_context.cleanup_candidates_present == Some(expected)
            }
            "hygiene_preflight_required" => {
                let expected = value
                    .as_bool()
                    .context("hygiene_preflight_required condition must be boolean")?;
                condition_context.hygiene_preflight_required == Some(expected)
            }
            "receipt_absent" => scalar_str(Some(value))
                .and_then(|id| target_state.receipts.get(id))
                .map(|receipt| !receipt.exists)
                .unwrap_or(true),
            "receipt_stale" => scalar_str(Some(value))
                .and_then(|id| target_state.receipts.get(id))
                .and_then(|receipt| receipt.stale)
                .unwrap_or(false),
            "receipt_fresh" => scalar_str(Some(value))
                .and_then(|id| target_state.receipts.get(id))
                .map(|receipt| receipt.exists && receipt.stale == Some(false))
                .unwrap_or(false),
            "receipt_complete" => scalar_str(Some(value))
                .and_then(|id| target_state.receipts.get(id))
                .map(|receipt| receipt.exists && receipt.missing_required_fields.is_empty())
                .unwrap_or(false),
            "receipt_incomplete" => scalar_str(Some(value))
                .and_then(|id| target_state.receipts.get(id))
                .map(|receipt| receipt.exists && !receipt.missing_required_fields.is_empty())
                .unwrap_or(false),
            "receipt_verdict" => {
                let receipt_id = mapping_string(value, "receipt_id")?;
                let expected = mapping_string(value, "value")?;
                receipt_verdict(contract, target_state, &receipt_id).as_deref() == Some(&expected)
            }
            "receipt_field_equals" => {
                let receipt_id = mapping_string(value, "receipt_id")?;
                let field = mapping_string(value, "field")?;
                let expected = mapping_string(value, "value")?;
                target_state
                    .receipts
                    .get(&receipt_id)
                    .and_then(|receipt| receipt.fields.get(&field))
                    .map(|actual| actual == &expected)
                    .unwrap_or(false)
            }
            "file_absent" => {
                if let Some(path) = scalar_str(Some(value)) {
                    !resolve_target_local_path(
                        &target_state.target_abs,
                        path,
                        "file_absent condition path",
                    )?
                    .exists()
                } else {
                    false
                }
            }
            "file_present" => {
                if let Some(path) = scalar_str(Some(value)) {
                    resolve_target_local_path(
                        &target_state.target_abs,
                        path,
                        "file_present condition path",
                    )?
                    .exists()
                } else {
                    false
                }
            }
            other => bail!("unsupported lifecycle condition key: {other}"),
        };
        if !matched {
            return Ok(false);
        }
    }
    Ok(true)
}

fn run_required_gates(
    repo_root: &Path,
    contract: &LifecycleContract,
    target_abs: &Path,
    route_id: &str,
) -> Result<Vec<GatePlanResult>> {
    let mut results = Vec::new();
    for gate in contract.gates.iter().filter(|gate| {
        gate.required_before_routes
            .iter()
            .any(|route| route == route_id)
    }) {
        let validator = contract
            .validators
            .iter()
            .find(|validator| validator.validator_id == gate.validator_id)
            .with_context(|| format!("missing validator {}", gate.validator_id))?;
        let result = run_validator(repo_root, contract, target_abs, gate, validator)?;
        results.push(result);
    }
    Ok(results)
}

fn run_validator(
    repo_root: &Path,
    contract: &LifecycleContract,
    target_abs: &Path,
    gate: &GateSpec,
    validator: &ValidatorSpec,
) -> Result<GatePlanResult> {
    if validator.argv.is_empty() {
        bail!("validator {} has empty argv", validator.validator_id);
    }
    let target_arg = rel_display(repo_root, target_abs);
    let argv = validator
        .argv
        .iter()
        .map(|arg| arg.replace("{{target}}", &target_arg))
        .collect::<Vec<_>>();
    validate_lifecycle_command_argv(
        repo_root,
        &contract.owner_extension,
        &argv,
        &format!("validator {}", validator.validator_id),
    )?;
    let output = ProcessCommand::new(&argv[0])
        .args(&argv[1..])
        .current_dir(repo_root)
        .output()
        .with_context(|| format!("failed to run validator {}", validator.validator_id))?;
    Ok(GatePlanResult {
        gate_id: gate.gate_id.clone(),
        validator_id: validator.validator_id.clone(),
        passed: output.status.success(),
        exit_code: output.status.code(),
        stdout: String::from_utf8_lossy(&output.stdout).trim().to_string(),
        stderr: String::from_utf8_lossy(&output.stderr).trim().to_string(),
    })
}

fn fallback_route_for_gate(contract: &LifecycleContract, gate_id: &str) -> Option<String> {
    contract
        .gates
        .iter()
        .find(|gate| gate.gate_id == gate_id)
        .and_then(|gate| gate.on_fail_route_id.clone())
}

fn route_by_id<'a>(contract: &'a LifecycleContract, route_id: &str) -> Option<&'a RouteSpec> {
    contract
        .routes
        .iter()
        .find(|route| route.route_id == route_id)
}

fn loop_for_route<'a>(contract: &'a LifecycleContract, route_id: &str) -> Option<&'a LoopSpec> {
    contract
        .loops
        .iter()
        .find(|loop_spec| loop_spec.repeat_route_id == route_id)
}

fn route_has_skip_when_target_exists(contract: &LifecycleContract, route_id: &str) -> bool {
    let _ = (contract, route_id);
    false
}

fn phase_loop_model(contract: &LifecycleContract) -> Option<String> {
    contract
        .phase_loop
        .as_ref()
        .map(|phase_loop| phase_loop.model_version.clone())
}

fn current_phase_for_plan(
    contract: &LifecycleContract,
    route_id: Option<&str>,
    terminal_outcome: Option<&str>,
    final_verdict: &str,
) -> Option<String> {
    let phase_loop = contract.phase_loop.as_ref()?;
    if let Some(route_id) = route_id {
        if let Some(phase) = phase_loop
            .phases
            .iter()
            .find(|phase| phase.route_refs.iter().any(|route| route == route_id))
        {
            return Some(phase.phase_id.clone());
        }
    }
    if classify_lifecycle_status(final_verdict).is_terminal_or_blocked() {
        if let Some(phase) = phase_loop.phases.iter().find(|phase| {
            phase.mode == "terminal"
                && terminal_outcome
                    .map(|outcome| {
                        phase
                            .terminal_refs
                            .iter()
                            .any(|terminal| terminal == outcome)
                    })
                    .unwrap_or(true)
        }) {
            return Some(phase.phase_id.clone());
        }
    }
    if let Some(terminal_outcome) = terminal_outcome {
        if let Some(phase) = phase_loop.phases.iter().find(|phase| {
            phase
                .terminal_refs
                .iter()
                .any(|terminal| terminal == terminal_outcome)
        }) {
            return Some(phase.phase_id.clone());
        }
    }
    None
}

fn phase_blockers_for_plan(
    final_verdict: &str,
    blocked_by_gate: Option<&str>,
    blocker_class: Option<&str>,
    blocker_message: Option<&str>,
) -> BTreeMap<String, String> {
    let mut blockers = BTreeMap::new();
    if classify_lifecycle_status(final_verdict).is_terminal_or_blocked()
        && final_verdict != "completed"
    {
        blockers.insert("final_verdict".to_string(), final_verdict.to_string());
    }
    if let Some(gate_id) = blocked_by_gate {
        blockers.insert("blocked_by_gate".to_string(), gate_id.to_string());
    }
    if let Some(blocker_class) = blocker_class {
        blockers.insert("blocker_class".to_string(), blocker_class.to_string());
    }
    if let Some(blocker_message) = blocker_message {
        blockers.insert("blocker_message".to_string(), blocker_message.to_string());
    }
    blockers
}

fn insert_phase_event_context(data: &mut BTreeMap<String, String>, phase_id: Option<&str>) {
    if let Some(phase_id) = phase_id {
        data.insert("phase_id".to_string(), phase_id.to_string());
    }
}

fn insert_interaction_event_context(
    data: &mut BTreeMap<String, String>,
    request_refs: &[String],
    return_refs: &[String],
) {
    if !request_refs.is_empty() {
        data.insert(
            "interaction_request_refs".to_string(),
            request_refs.join(","),
        );
    }
    if !return_refs.is_empty() {
        data.insert("interaction_return_refs".to_string(), return_refs.join(","));
    }
}

fn phase_transition_id(event_type: &str, phase_id: &str) -> String {
    format!("{event_type}:{phase_id}")
}

fn phase_transition_event_data(phase_id: &str, event_type: &str) -> BTreeMap<String, String> {
    let mut data = BTreeMap::new();
    data.insert("phase_id".to_string(), phase_id.to_string());
    data.insert(
        "transition_id".to_string(),
        phase_transition_id(event_type, phase_id),
    );
    data
}

fn receipt_verdict(
    contract: &LifecycleContract,
    target_state: &TargetState,
    receipt_id: &str,
) -> Option<String> {
    let spec = contract
        .receipts
        .iter()
        .find(|receipt| receipt.receipt_id == receipt_id)?;
    let field = spec.verdict_field.as_deref().unwrap_or("verdict");
    target_state
        .receipts
        .get(receipt_id)?
        .fields
        .get(field)
        .cloned()
}

fn receipt_plan_states(
    repo_root: &Path,
    contract: &LifecycleContract,
    target_state: &TargetState,
) -> BTreeMap<String, ReceiptPlanState> {
    target_state
        .receipts
        .iter()
        .map(|(id, receipt)| {
            let verdict_field = contract
                .receipts
                .iter()
                .find(|spec| spec.receipt_id == *id)
                .and_then(|spec| spec.verdict_field.as_deref())
                .unwrap_or("verdict");
            (
                id.clone(),
                ReceiptPlanState {
                    path: rel_display(repo_root, &receipt.path_abs),
                    exists: receipt.exists,
                    verdict: receipt.fields.get(verdict_field).cloned(),
                    fields: receipt.fields.clone(),
                    missing_required_fields: receipt.missing_required_fields.clone(),
                    stale: receipt.stale,
                    stored_digest: receipt.stored_digest.clone(),
                    current_digest: receipt.current_digest.clone(),
                },
            )
        })
        .collect()
}

pub(crate) fn lifecycle_plan_has_worktree_hygiene_blocker(plan: &LifecyclePlanResult) -> bool {
    receipt_states_have_worktree_hygiene_blocker(&plan.receipt_states)
}

fn selected_route_reuses_worktree_hygiene_blocked_closeout(
    selected_route: Option<&RouteSpec>,
    receipt_states: &BTreeMap<String, ReceiptPlanState>,
) -> bool {
    selected_route
        .map(|route| route.route_id.as_str() == ROUTE_ID_CLOSEOUT_PACKET)
        .unwrap_or(false)
        && receipt_states_have_worktree_hygiene_blocker(receipt_states)
}

fn lifecycle_plan_blocker_for_receipts(
    final_verdict: &str,
    receipt_states: &BTreeMap<String, ReceiptPlanState>,
) -> (Option<String>, Option<String>) {
    if final_verdict == "blocked-no-route"
        && receipt_states_have_worktree_hygiene_blocker(receipt_states)
    {
        return (
            Some("worktree-hygiene-blocked".to_string()),
            Some(
                "proposal closeout is blocked by foreign or ambiguous worktree hygiene; route through closeout-change or operator scope resolution"
                    .to_string(),
            ),
        );
    }
    (None, None)
}

fn receipt_states_have_worktree_hygiene_blocker(
    receipt_states: &BTreeMap<String, ReceiptPlanState>,
) -> bool {
    let Some(closeout) = receipt_states.get("proposal-closeout") else {
        return false;
    };
    closeout.verdict.as_deref() == Some("blocked")
        && closeout
            .fields
            .get("worktree_hygiene_verdict")
            .map(String::as_str)
            == Some("blocked")
}

fn receipt_digest_map(plan: &LifecyclePlanResult) -> BTreeMap<String, String> {
    plan.receipt_states
        .iter()
        .filter_map(|(id, receipt)| {
            receipt
                .current_digest
                .as_ref()
                .or(receipt.stored_digest.as_ref())
                .map(|digest| (id.clone(), digest.clone()))
        })
        .collect()
}

fn route_plan_state(route: RouteSpec) -> RoutePlanState {
    RoutePlanState {
        route_id: route.route_id,
        route_type: route.route_type,
        command_id: route.command_id,
        skill_id: route.skill_id,
        prompt_set_id: route.prompt_set_id,
    }
}

pub(crate) fn lifecycle_execution_request_from_run(
    octon_dir: &Path,
    run: &LifecycleRunResult,
    executor: ExecutorKind,
    timeout_seconds: u64,
    invocation_authority: &str,
    retry_attempt: u32,
) -> Result<Option<LifecycleRouteExecutionRequest>> {
    let Some(route) = run.selected_route.as_ref() else {
        return Ok(None);
    };
    let checkpoint = read_checkpoint_for_run(octon_dir, &run.run_id)?;
    let last_validator_results = checkpoint
        .as_ref()
        .map(|checkpoint| checkpoint.last_validator_results.as_slice())
        .unwrap_or(&[]);
    let run_inputs = checkpoint
        .as_ref()
        .map(|checkpoint| checkpoint.run_inputs.clone())
        .unwrap_or_default();
    let repo_root = repo_root_for_octon(octon_dir)?;
    let evidence_root = resolve_repo_path(&repo_root, Path::new(&run.bundle_root));
    let checkpoint_path = resolve_repo_path(&repo_root, Path::new(&run.checkpoint_path));
    lifecycle_execution_request_for_route(
        octon_dir,
        &run.run_id,
        &run.lifecycle_id,
        &run.target,
        run.current_phase.as_deref(),
        route,
        executor,
        timeout_seconds,
        invocation_authority,
        retry_attempt,
        &run_inputs,
        last_validator_results,
        evidence_root,
        checkpoint_path,
        Some(lifecycle_cancellation_token_path(
            &octon_dir.join(RUN_CONTROL_ROOT_REL).join(&run.run_id),
        )),
        None,
    )
}

fn lifecycle_execution_request_for_route(
    octon_dir: &Path,
    run_id: &str,
    lifecycle_id: &str,
    target_rel: &str,
    phase_id: Option<&str>,
    route: &RoutePlanState,
    executor: ExecutorKind,
    timeout_seconds: u64,
    invocation_authority: &str,
    retry_attempt: u32,
    run_inputs: &BTreeMap<String, String>,
    gate_results: &[GatePlanResult],
    evidence_root: PathBuf,
    checkpoint_path: PathBuf,
    cancellation_token: Option<PathBuf>,
    human_boundary_context: Option<LifecycleHumanBoundaryContext>,
) -> Result<Option<LifecycleRouteExecutionRequest>> {
    let repo_root = repo_root_for_octon(octon_dir)?;
    let loaded = load_lifecycle_contract(octon_dir, lifecycle_id)?;
    let target = resolve_lifecycle_target_path(&repo_root, Path::new(target_rel))?;
    let route_spec = route_by_id(&loaded.contract, &route.route_id)
        .with_context(|| format!("route missing from lifecycle contract: {}", route.route_id))?;
    let receipts = loaded
        .contract
        .receipts
        .iter()
        .map(|receipt| LifecycleReceiptSpec {
            receipt_id: receipt.receipt_id.clone(),
            path: receipt.path.clone(),
            required_fields: receipt.required_fields.clone(),
            verdict_field: receipt.verdict_field.clone(),
        })
        .collect::<Vec<_>>();
    let mut bound_inputs = default_bound_inputs(Path::new(target_rel));
    for (name, binding) in &loaded.contract.input_bindings {
        if binding.source == "lifecycle.target" {
            bound_inputs.insert(name.clone(), target_rel.to_string());
        } else if let Some(input_name) = binding.source.strip_prefix("run.input.") {
            if let Some(value) = run_inputs.get(input_name) {
                bound_inputs.insert(name.clone(), value.clone());
            }
        } else if let Some((receipt_id, field)) = receipt_field_binding(&binding.source)? {
            if let Some(value) =
                lifecycle_receipt_field_value(&target, &loaded.contract, receipt_id, field)?
            {
                bound_inputs.insert(name.clone(), value);
            }
        } else {
            bail!(
                "unsupported lifecycle input binding source for {}: {}",
                name,
                binding.source
            );
        }
    }
    if route.route_type == "workflow" {
        for (name, value) in run_inputs {
            bound_inputs
                .entry(name.clone())
                .or_insert_with(|| value.clone());
        }
    }
    normalize_archive_proposal_disposition_binding(&route.route_id, &mut bound_inputs);
    normalize_archive_proposal_promotion_evidence_binding(
        &repo_root,
        &route.route_id,
        &mut bound_inputs,
    );
    bind_promote_proposal_promotion_evidence_from_implementation_run(
        &repo_root,
        &target,
        &loaded.contract,
        &route.route_id,
        &mut bound_inputs,
    )?;
    let expected_receipts = route_spec
        .completion
        .as_ref()
        .map(|completion| completion.expected_receipts.clone())
        .unwrap_or_default();
    let expected_paths = route_spec
        .completion
        .as_ref()
        .map(|completion| completion.expected_paths.clone())
        .unwrap_or_default();
    let expected_manifest_status = route_spec
        .completion
        .as_ref()
        .and_then(|completion| completion.expected_manifest_status.clone());
    let expected_target_change = route_spec
        .completion
        .as_ref()
        .map(|completion| completion.expected_target_change)
        .unwrap_or(false);
    let completion_replan_required = route_spec
        .completion
        .as_ref()
        .map(|completion| completion.replan_required)
        .unwrap_or(false);
    let delegation_contract =
        route_spec
            .delegation_contract
            .as_ref()
            .map(|contract| LifecycleDelegationContract {
                decision_class: contract.decision_class.clone(),
                safe_delegation: contract.safe_delegation,
                authority_zones_allowed: contract.authority_zones_allowed.clone(),
                declared_write_scope_source: contract.declared_write_scope_source.clone(),
                required_evidence_gates: contract.required_evidence_gates.clone(),
                required_receipts_before_dispatch: contract
                    .required_receipts_before_dispatch
                    .clone(),
                required_receipts_before_completion: contract
                    .required_receipts_before_completion
                    .clone(),
                replay_class: contract.replay_class.clone(),
                automated_recovery_policy: contract.automated_recovery_policy.clone(),
                human_only_boundaries: contract.human_only_boundaries.clone(),
            });
    let evidence_gate_results = evidence_gate_results_for_route(route_spec, gate_results);
    let (interaction_request_refs, interaction_return_refs) =
        lifecycle_interaction_refs_from_run_inputs(&repo_root, run_inputs)?;
    Ok(Some(LifecycleRouteExecutionRequest {
        schema_version: "octon-lifecycle-route-execution-request-v1".to_string(),
        run_id: run_id.to_string(),
        lifecycle_id: lifecycle_id.to_string(),
        owner_extension: loaded.contract.owner_extension.clone(),
        phase_id: phase_id.map(str::to_string),
        target,
        manifest_path: loaded.contract.target.manifest_path.clone(),
        status_field: loaded.contract.target.status_field.clone(),
        executor: executor.as_str().to_string(),
        route: LifecycleRouteSpec {
            route_id: route.route_id.clone(),
            route_type: route.route_type.clone(),
            command_id: route.command_id.clone(),
            skill_id: route.skill_id.clone(),
            prompt_set_id: route.prompt_set_id.clone(),
            required_inputs: route_spec.required_inputs.clone(),
            completion_replan_required,
            delegation_contract,
        },
        effective_extension_catalog: generated_effective_extension_catalog_path(octon_dir)?,
        runtime_route_bundle: runtime_effective_route_bundle_path(octon_dir)?,
        bound_inputs,
        receipts,
        expected_receipts,
        expected_paths,
        expected_manifest_status,
        expected_target_change,
        evidence_root,
        checkpoint_path,
        interaction_request_refs,
        interaction_return_refs,
        policy: LifecycleExecutionPolicy {
            timeout_seconds,
            cancellation_token,
            retry_attempt,
            invocation_authority: LifecycleInvocationAuthority {
                mode: invocation_authority.to_string(),
                provenance: if invocation_authority == "grant-consumption" {
                    "typed-human-exception-grant".to_string()
                } else {
                    "lifecycle-invocation".to_string()
                },
                authority_ref: None,
            },
        },
        human_boundary_context,
        evidence_gate_results,
    }))
}

fn evidence_gate_results_for_route(
    route_spec: &RouteSpec,
    gate_results: &[GatePlanResult],
) -> BTreeMap<String, String> {
    let mut results = BTreeMap::new();
    let Some(contract) = route_spec.delegation_contract.as_ref() else {
        return results;
    };
    for gate_id in &contract.required_evidence_gates {
        if let Some(result) = gate_results
            .iter()
            .find(|result| result.gate_id == *gate_id)
        {
            results.insert(
                gate_id.clone(),
                if result.passed { "pass" } else { "fail" }.to_string(),
            );
        }
    }
    results
}

fn receipt_field_binding(source: &str) -> Result<Option<(&str, &str)>> {
    let Some(rest) = source.strip_prefix("receipt.") else {
        return Ok(None);
    };
    let Some((receipt_id, field)) = rest.split_once('.') else {
        bail!("receipt input binding source must be receipt.<receipt_id>.<field>: {source}");
    };
    if receipt_id.is_empty() || field.is_empty() {
        bail!("receipt input binding source must be receipt.<receipt_id>.<field>: {source}");
    }
    Ok(Some((receipt_id, field)))
}

fn normalize_archive_proposal_disposition_binding(
    route_id: &str,
    bound_inputs: &mut BTreeMap<String, String>,
) {
    if route_id != "archive-proposal" {
        return;
    }
    if bound_inputs.get("disposition").map(String::as_str) != Some("archive-ready") {
        return;
    }
    bound_inputs.insert("disposition".to_string(), "implemented".to_string());
    bound_inputs.insert(
        "archive_disposition_source_outcome".to_string(),
        "archive-ready".to_string(),
    );
    bound_inputs.insert(
        "archive_disposition_mapping".to_string(),
        "archive-ready->implemented".to_string(),
    );
}

fn normalize_archive_proposal_promotion_evidence_binding(
    repo_root: &Path,
    route_id: &str,
    bound_inputs: &mut BTreeMap<String, String>,
) {
    if route_id != "archive-proposal" {
        return;
    }
    let Some(raw_evidence) = bound_inputs.get("promotion_evidence").cloned() else {
        return;
    };

    let mut existing_refs = Vec::new();
    let mut missing_refs = Vec::new();
    for raw_entry in raw_evidence.split(',') {
        let normalized = raw_entry.trim().trim_end_matches('/').to_string();
        if normalized.is_empty() || !is_safe_repo_relative(&normalized) {
            return;
        }
        if repo_root.join(&normalized).exists() {
            existing_refs.push(normalized);
        } else {
            missing_refs.push(normalized);
        }
    }

    if existing_refs.is_empty() || missing_refs.is_empty() {
        return;
    }

    bound_inputs.insert("promotion_evidence".to_string(), existing_refs.join(","));
    bound_inputs.insert(
        "archive_promotion_evidence_binding".to_string(),
        "suppressed-missing-retained-evidence-refs".to_string(),
    );
    bound_inputs.insert(
        "archive_promotion_evidence_source_ref_count".to_string(),
        (existing_refs.len() + missing_refs.len()).to_string(),
    );
    bound_inputs.insert(
        "archive_promotion_evidence_suppressed_missing_count".to_string(),
        missing_refs.len().to_string(),
    );
    bound_inputs.insert(
        "archive_promotion_evidence_suppressed_missing_refs".to_string(),
        missing_refs.join(","),
    );
}

fn bind_promote_proposal_promotion_evidence_from_implementation_run(
    repo_root: &Path,
    target: &Path,
    contract: &LifecycleContract,
    route_id: &str,
    bound_inputs: &mut BTreeMap<String, String>,
) -> Result<()> {
    if route_id != "promote-proposal" {
        return Ok(());
    }
    let Some(receipt) = contract
        .receipts
        .iter()
        .find(|receipt| receipt.receipt_id == "implementation-run")
    else {
        return Ok(());
    };
    let path = resolve_target_local_path(
        target,
        &receipt.path,
        "promote-proposal implementation-run promotion evidence binding",
    )?;
    if !path.is_file() {
        return Ok(());
    }

    let content = fs::read_to_string(&path)?;
    let refs = implementation_run_promotion_evidence_refs(repo_root, &content);
    if refs.is_empty() {
        bound_inputs.remove("promotion_evidence");
        bound_inputs.insert(
            "promote_promotion_evidence_binding".to_string(),
            "implementation-run-evidence-missing".to_string(),
        );
        return Ok(());
    }

    let prior = bound_inputs.insert("promotion_evidence".to_string(), refs.join(","));
    bound_inputs.insert(
        "promote_promotion_evidence_binding".to_string(),
        "implementation-run-evidence-refs".to_string(),
    );
    bound_inputs.insert(
        "promote_promotion_evidence_source_ref_count".to_string(),
        refs.len().to_string(),
    );
    if prior.is_some() {
        bound_inputs.insert(
            "promote_promotion_evidence_prior_binding".to_string(),
            "superseded-non-controlling".to_string(),
        );
    }
    Ok(())
}

fn implementation_run_promotion_evidence_refs(repo_root: &Path, content: &str) -> Vec<String> {
    let fields = parse_receipt_fields_from_str(content);
    let raw_refs = fields
        .get("promotion_evidence")
        .map(|raw| receipt_ref_list(raw))
        .unwrap_or_else(|| markdown_evidence_refs(content));
    if raw_refs.is_empty() {
        return Vec::new();
    }
    if raw_refs
        .iter()
        .any(|reference| !is_safe_repo_relative(reference) || !repo_root.join(reference).is_file())
    {
        return Vec::new();
    }
    raw_refs
}

fn receipt_ref_list(raw: &str) -> Vec<String> {
    raw.split(',')
        .map(|entry| clean_scalar(entry.trim()).trim_end_matches('/').to_string())
        .filter(|entry| !entry.is_empty())
        .collect()
}

fn markdown_evidence_refs(content: &str) -> Vec<String> {
    let mut refs = Vec::new();
    let mut in_evidence_section = false;
    for line in content.lines() {
        let trimmed = line.trim();
        if trimmed.starts_with("## ") {
            let heading = trimmed.trim_start_matches('#').trim().to_ascii_lowercase();
            in_evidence_section = heading.contains("evidence refs");
            continue;
        }
        if !in_evidence_section {
            continue;
        }
        let Some(raw_ref) = trimmed.strip_prefix("- ") else {
            continue;
        };
        let reference = clean_scalar(raw_ref.trim())
            .trim_end_matches('/')
            .to_string();
        if !reference.is_empty() {
            refs.push(reference);
        }
    }
    refs
}

fn lifecycle_receipt_field_value(
    target: &Path,
    contract: &LifecycleContract,
    receipt_id: &str,
    field: &str,
) -> Result<Option<String>> {
    let Some(receipt) = contract
        .receipts
        .iter()
        .find(|receipt| receipt.receipt_id == receipt_id)
    else {
        bail!("receipt input binding references unknown receipt: {receipt_id}");
    };
    let path = resolve_target_local_path(
        target,
        &receipt.path,
        &format!("receipt input binding {}", receipt.receipt_id),
    )?;
    if !path.is_file() {
        return Ok(None);
    }
    Ok(parse_receipt_fields(&path)?.get(field).cloned())
}

fn parse_receipt_fields(path: &Path) -> Result<BTreeMap<String, String>> {
    Ok(parse_receipt_fields_from_str(&fs::read_to_string(path)?))
}

fn parse_receipt_fields_from_str(content: &str) -> BTreeMap<String, String> {
    let mut fields = BTreeMap::new();
    let lines = content.lines().collect::<Vec<_>>();
    let mut index = 0;
    while index < lines.len() {
        let line = lines[index];
        let trimmed = line.trim();
        if trimmed.is_empty() || trimmed.starts_with('#') {
            index += 1;
            continue;
        }
        if let Some((key, value)) = trimmed.split_once(':') {
            let key = key.trim();
            if is_receipt_key(key) {
                let scalar = clean_scalar(value.trim());
                if scalar.is_empty() {
                    let list_value = receipt_sequence_value(&lines, index + 1);
                    fields.insert(key.to_string(), list_value.unwrap_or(scalar));
                } else {
                    fields.insert(key.to_string(), scalar);
                }
            }
        } else if trimmed.starts_with('|') && trimmed.ends_with('|') {
            let cells = trimmed
                .trim_matches('|')
                .split('|')
                .map(|cell| cell.trim())
                .collect::<Vec<_>>();
            if cells.len() >= 2 && is_receipt_key(cells[0]) {
                fields.insert(cells[0].to_string(), clean_scalar(cells[1]));
            }
        }
        index += 1;
    }
    fields
}

fn receipt_sequence_value(lines: &[&str], start_index: usize) -> Option<String> {
    let mut values = Vec::new();
    for line in lines.iter().skip(start_index) {
        if line.trim().is_empty() {
            continue;
        }
        if !line.starts_with(char::is_whitespace) {
            break;
        }
        let trimmed = line.trim();
        let Some(value) = trimmed.strip_prefix("- ") else {
            break;
        };
        values.push(clean_scalar(value.trim()));
    }
    (!values.is_empty()).then(|| values.join(","))
}

fn is_receipt_key(value: &str) -> bool {
    !value.is_empty()
        && value
            .chars()
            .all(|ch| ch.is_ascii_alphanumeric() || ch == '_' || ch == '-')
}

fn clean_scalar(value: &str) -> String {
    let mut cleaned = value
        .trim()
        .trim_matches('"')
        .trim_matches('\'')
        .to_string();
    if cleaned.starts_with('`') && cleaned.ends_with('`') && cleaned.len() >= 2 {
        cleaned = cleaned.trim_matches('`').to_string();
    }
    cleaned
}

fn run_digest_command(
    repo_root: &Path,
    owner_extension: &str,
    target_abs: &Path,
    command: &[String],
) -> Result<Option<String>> {
    if command.is_empty() || !target_abs.exists() {
        return Ok(None);
    }
    let target_arg = rel_display(repo_root, target_abs);
    let argv = command
        .iter()
        .map(|arg| arg.replace("{{target}}", &target_arg))
        .collect::<Vec<_>>();
    validate_lifecycle_command_argv(
        repo_root,
        owner_extension,
        &argv,
        "receipt freshness digest",
    )?;
    let output = ProcessCommand::new(&argv[0])
        .args(&argv[1..])
        .current_dir(repo_root)
        .output()?;
    if !output.status.success() {
        bail!(
            "digest command failed: {}",
            String::from_utf8_lossy(&output.stderr).trim()
        );
    }
    Ok(Some(
        String::from_utf8_lossy(&output.stdout).trim().to_string(),
    ))
}

fn validate_lifecycle_command_argv(
    repo_root: &Path,
    owner_extension: &str,
    argv: &[String],
    label: &str,
) -> Result<()> {
    if argv.is_empty() {
        bail!("lifecycle command argv is empty for {label}");
    }
    let script = lifecycle_command_script(argv)
        .with_context(|| format!("lifecycle command script missing for {label}"))?;
    if !is_allowed_lifecycle_script(owner_extension, script) {
        bail!("lifecycle command script outside allowed roots for {label}: {script}");
    }
    let script_abs = resolve_repo_str(repo_root, script);
    if !script_abs.is_file() {
        bail!(
            "lifecycle command script missing for {label}: {}",
            script_abs.display()
        );
    }
    Ok(())
}

fn lifecycle_command_script(argv: &[String]) -> Option<&str> {
    match argv.first().map(String::as_str) {
        Some("bash" | "sh") => argv.get(1).map(String::as_str),
        Some(script) => Some(script),
        None => None,
    }
}

fn is_allowed_lifecycle_script(owner_extension: &str, script: &str) -> bool {
    if !is_safe_repo_relative(script) {
        return false;
    }
    script.starts_with(FRAMEWORK_ASSURANCE_SCRIPT_PREFIX)
        || script.starts_with(&format!(
            ".octon/inputs/additive/extensions/{owner_extension}/validation/"
        ))
}

fn is_safe_repo_relative(raw: &str) -> bool {
    !raw.is_empty()
        && !Path::new(raw).is_absolute()
        && Path::new(raw)
            .components()
            .all(|component| matches!(component, Component::Normal(_)))
}

fn mapping_string(value: &Value, field: &str) -> Result<String> {
    let Some(mapping) = value.as_mapping() else {
        bail!("condition value for {field} must be a mapping");
    };
    mapping
        .get(&Value::String(field.to_string()))
        .and_then(|value| scalar_str(Some(value)).map(str::to_string))
        .with_context(|| format!("condition field missing: {field}"))
}

fn lookup_dotted_field<'a>(value: &'a Value, field: &str) -> Option<&'a Value> {
    let mut current = value;
    for part in field.split('.') {
        current = current.get(part)?;
    }
    Some(current)
}

fn scalar_str(value: Option<&Value>) -> Option<&str> {
    value.and_then(|value| match value {
        Value::String(raw) => Some(raw.as_str()),
        _ => None,
    })
}

fn value_sequence_contains(value: Option<&Value>, expected: &str) -> bool {
    value
        .and_then(Value::as_sequence)
        .map(|items| items.iter().any(|item| item.as_str() == Some(expected)))
        .unwrap_or(false)
}

fn repo_root_for_octon(octon_dir: &Path) -> Result<PathBuf> {
    Ok(octon_dir
        .parent()
        .context("octon dir must have a repository parent")?
        .to_path_buf())
}

fn resolve_repo_path(repo_root: &Path, path: &Path) -> PathBuf {
    if path.is_absolute() {
        path.to_path_buf()
    } else {
        repo_root.join(path)
    }
}

fn resolve_repo_str(repo_root: &Path, raw: &str) -> PathBuf {
    let path = PathBuf::from(raw);
    resolve_repo_path(repo_root, &path)
}

fn resolve_lifecycle_target_path(repo_root: &Path, path: &Path) -> Result<PathBuf> {
    resolve_user_repo_path(repo_root, path, "lifecycle target")
}

fn resolve_target_local_path(target_abs: &Path, raw: &str, label: &str) -> Result<PathBuf> {
    let path = Path::new(raw);
    if path.as_os_str().is_empty() {
        bail!("{label} must not be empty");
    }
    if path.is_absolute()
        || !path
            .components()
            .all(|component| matches!(component, Component::Normal(_)))
    {
        bail!(
            "{label} must be target-relative and must not contain . or .. traversal: {}",
            path.display()
        );
    }
    let candidate = target_abs.join(path);
    if target_abs.exists() {
        let canonical_target = target_abs.canonicalize().with_context(|| {
            format!(
                "failed to canonicalize lifecycle target {}",
                target_abs.display()
            )
        })?;
        ensure_existing_target_components_stay_in_target(
            target_abs,
            &canonical_target,
            path,
            label,
        )?;
        let anchor = nearest_existing_ancestor(&candidate).with_context(|| {
            format!(
                "failed to resolve nearest existing ancestor for {label}: {}",
                path.display()
            )
        })?;
        let canonical_anchor = anchor.canonicalize().with_context(|| {
            format!(
                "failed to canonicalize existing ancestor for {label}: {}",
                anchor.display()
            )
        })?;
        if !canonical_anchor.starts_with(&canonical_target) {
            bail!(
                "{label} existing ancestor escapes target root: {} -> {}",
                anchor.display(),
                canonical_anchor.display()
            );
        }
    }
    Ok(candidate)
}

fn ensure_existing_target_components_stay_in_target(
    target_abs: &Path,
    canonical_target: &Path,
    path: &Path,
    label: &str,
) -> Result<()> {
    let mut current = target_abs.to_path_buf();
    for component in path.components() {
        let Component::Normal(part) = component else {
            bail!(
                "{label} must be target-relative and must not contain . or .. traversal: {}",
                path.display()
            );
        };
        current.push(part);
        match fs::symlink_metadata(&current) {
            Ok(metadata) => {
                if metadata.file_type().is_symlink() {
                    let canonical = current.canonicalize().with_context(|| {
                        format!(
                            "{label} contains unresolved symlink component: {}",
                            current.display()
                        )
                    })?;
                    if !canonical.starts_with(canonical_target) {
                        bail!(
                            "{label} symlink component escapes target root: {} -> {}",
                            current.display(),
                            canonical.display()
                        );
                    }
                }
            }
            Err(error) if error.kind() == std::io::ErrorKind::NotFound => break,
            Err(error) => {
                return Err(error).with_context(|| {
                    format!(
                        "failed to inspect existing component for {label}: {}",
                        current.display()
                    )
                });
            }
        }
    }
    Ok(())
}

fn resolve_user_repo_path(repo_root: &Path, path: &Path, label: &str) -> Result<PathBuf> {
    if path.as_os_str().is_empty() {
        bail!("{label} must not be empty");
    }
    if path.is_absolute() {
        bail!(
            "{label} must be repo-relative and must not be absolute: {}",
            path.display()
        );
    }
    if !path
        .components()
        .all(|component| matches!(component, Component::Normal(_)))
    {
        bail!(
            "{label} must be repo-relative and must not contain . or .. traversal: {}",
            path.display()
        );
    }
    let canonical_repo_root = repo_root
        .canonicalize()
        .with_context(|| format!("failed to canonicalize repo root {}", repo_root.display()))?;
    ensure_existing_components_stay_in_repo(repo_root, &canonical_repo_root, path, label)?;
    let candidate = repo_root.join(path);
    let anchor = nearest_existing_ancestor(&candidate).with_context(|| {
        format!(
            "failed to resolve nearest existing ancestor for {label}: {}",
            path.display()
        )
    })?;
    let canonical_anchor = anchor.canonicalize().with_context(|| {
        format!(
            "failed to canonicalize existing ancestor for {label}: {}",
            anchor.display()
        )
    })?;
    if !canonical_anchor.starts_with(&canonical_repo_root) {
        bail!(
            "{label} existing ancestor escapes repo root: {} -> {}",
            anchor.display(),
            canonical_anchor.display()
        );
    }
    Ok(candidate)
}

fn ensure_existing_components_stay_in_repo(
    repo_root: &Path,
    canonical_repo_root: &Path,
    path: &Path,
    label: &str,
) -> Result<()> {
    let mut current = repo_root.to_path_buf();
    for component in path.components() {
        let Component::Normal(part) = component else {
            bail!(
                "{label} must be repo-relative and must not contain . or .. traversal: {}",
                path.display()
            );
        };
        current.push(part);
        match fs::symlink_metadata(&current) {
            Ok(metadata) => {
                if metadata.file_type().is_symlink() {
                    let canonical = current.canonicalize().with_context(|| {
                        format!(
                            "{label} contains unresolved symlink component: {}",
                            current.display()
                        )
                    })?;
                    if !canonical.starts_with(canonical_repo_root) {
                        bail!(
                            "{label} symlink component escapes repo root: {} -> {}",
                            current.display(),
                            canonical.display()
                        );
                    }
                }
            }
            Err(error) if error.kind() == std::io::ErrorKind::NotFound => break,
            Err(error) => {
                return Err(error).with_context(|| {
                    format!(
                        "failed to inspect existing component for {label}: {}",
                        current.display()
                    )
                });
            }
        }
    }
    Ok(())
}

fn nearest_existing_ancestor(path: &Path) -> Option<PathBuf> {
    let mut current = path.to_path_buf();
    loop {
        if current.exists() {
            return Some(current);
        }
        if !current.pop() {
            return None;
        }
    }
}

fn rel_display(repo_root: &Path, path: &Path) -> String {
    path.strip_prefix(repo_root)
        .map(|rel| rel.display().to_string())
        .unwrap_or_else(|_| path.display().to_string())
}

pub(crate) fn update_lifecycle_checkpoint_final_verdict(
    octon_dir: &Path,
    run_id: &str,
    final_verdict: &str,
) -> Result<()> {
    let Some(mut checkpoint) = read_checkpoint_for_run(octon_dir, run_id)? else {
        return Ok(());
    };
    checkpoint.final_verdict = final_verdict.to_string();
    if classify_lifecycle_status(final_verdict).is_terminal_or_blocked()
        && final_verdict != "completed"
    {
        checkpoint
            .phase_blockers
            .insert("final_verdict".to_string(), final_verdict.to_string());
    }
    if final_verdict == "cancelled" && checkpoint.cancelled_at.is_none() {
        checkpoint.cancelled_at = Some(now_rfc3339()?);
        checkpoint.cancel_reason =
            Some("cancellation token observed during route dispatch".to_string());
        checkpoint.terminal_outcome = Some("cancelled".to_string());
    }
    let path = checkpoint_path_for_run(octon_dir, run_id)?;
    fs::write(path, serde_yaml::to_string(&checkpoint)?)?;
    Ok(())
}

pub(crate) fn update_lifecycle_execution_summary(
    octon_dir: &Path,
    run: &LifecycleRunResult,
    adapter_status: &str,
) -> Result<()> {
    let repo_root = repo_root_for_octon(octon_dir)?;
    if run.bundle_root.is_empty() {
        return Ok(());
    }
    let evidence_root = resolve_repo_path(&repo_root, Path::new(&run.bundle_root));
    fs::create_dir_all(&evidence_root)?;
    fs::write(
        evidence_root.join("summary.md"),
        lifecycle_adapter_execution_summary(run, adapter_status),
    )?;
    Ok(())
}

fn write_run_inputs_evidence(
    evidence_root: &Path,
    run_id: &str,
    run_inputs: &BTreeMap<String, String>,
) -> Result<()> {
    let evidence = LifecycleRunInputsEvidence {
        schema_version: "octon-lifecycle-run-inputs-v1",
        run_id,
        inputs: run_inputs,
    };
    fs::write(
        evidence_root.join("run-inputs.yml"),
        serde_yaml::to_string(&evidence)?,
    )?;
    Ok(())
}

fn read_checkpoint_for_run(octon_dir: &Path, run_id: &str) -> Result<Option<LifecycleCheckpoint>> {
    let path = checkpoint_path_for_run(octon_dir, run_id)?;
    if !path.is_file() {
        return Ok(None);
    }
    Ok(Some(serde_yaml::from_slice(&fs::read(path)?)?))
}

fn checkpoint_path_for_run(octon_dir: &Path, run_id: &str) -> Result<PathBuf> {
    let path = octon_dir
        .join(RUN_CONTROL_ROOT_REL)
        .join(sanitize_run_id(run_id)?)
        .join("lifecycle-checkpoint.yml");
    Ok(path)
}

fn validate_checkpoint_binding(
    checkpoint: &LifecycleCheckpoint,
    sanitized_run_id: &str,
    lifecycle_id: &str,
    execution_strategy: &str,
    target: &str,
) -> Result<()> {
    if checkpoint.run_id != sanitized_run_id {
        bail!(
            "lifecycle run id {sanitized_run_id} is inconsistent with checkpoint run_id {}",
            checkpoint.run_id
        );
    }
    if checkpoint.lifecycle_id != lifecycle_id || checkpoint.target != target {
        bail!(
            "lifecycle run id {sanitized_run_id} is already bound to lifecycle {} target {}; requested lifecycle {lifecycle_id} target {target}",
            checkpoint.lifecycle_id,
            checkpoint.target
        );
    }
    if checkpoint.execution_strategy != execution_strategy {
        bail!(
            "lifecycle run id {sanitized_run_id} checkpoint execution_strategy {} differs from loaded contract strategy {execution_strategy}",
            checkpoint.execution_strategy
        );
    }
    Ok(())
}

fn default_run_id(lifecycle_id: &str) -> String {
    let millis = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|duration| duration.as_millis())
        .unwrap_or_default();
    let mut hasher = Sha256::new();
    hasher.update(format!("{lifecycle_id}:{millis}"));
    let digest = hex::encode(hasher.finalize());
    format!("lifecycle-{lifecycle_id}-{millis}-{}", &digest[..8])
}

fn sanitize_run_id(value: &str) -> Result<String> {
    let sanitized = value
        .chars()
        .map(|ch| {
            if ch.is_ascii_alphanumeric() || ch == '-' || ch == '_' {
                ch
            } else {
                '-'
            }
        })
        .collect::<String>();
    if sanitized.is_empty() {
        bail!("lifecycle run id is empty after sanitization");
    }
    Ok(sanitized)
}

fn lifecycle_summary(
    run_id: &str,
    executor: &ExecutorKind,
    plan: &LifecyclePlanResult,
    final_verdict: &str,
) -> String {
    let route = plan
        .next_route
        .as_ref()
        .map(|route| route.route_id.as_str())
        .unwrap_or("none");
    let terminal = plan.terminal_outcome.as_deref().unwrap_or("none");
    let phase = plan.current_phase.as_deref().unwrap_or("none");
    let execution_mode = route_execution_mode(
        executor,
        final_verdict,
        plan.next_route.is_some(),
        plan.terminal_outcome.is_some(),
    );
    let handoff_note = route_execution_note(execution_mode);
    let blocker_note = plan
        .blocker_class
        .as_ref()
        .map(|class| {
            let message = plan.blocker_message.as_deref().unwrap_or("none");
            format!("blocker_class: {class}\nblocker_message: {message}\n")
        })
        .unwrap_or_default();
    format!(
        "# Lifecycle Run\n\nrun_id: {run_id}\nrecorded_at: {}\nlifecycle_id: {}\nexecution_strategy: {}\ntarget: {}\nexecutor: {}\nroute_execution_mode: {execution_mode}\ncurrent_phase: {phase}\nselected_route: {route}\nterminal_outcome: {terminal}\nfinal_verdict: {final_verdict}\n{blocker_note}\n{handoff_note}\n",
        now_rfc3339().unwrap_or_else(|_| "unknown".to_string()),
        plan.lifecycle_id,
        plan.execution_strategy,
        plan.target,
        executor.as_str(),
    )
}

fn lifecycle_adapter_execution_summary(run: &LifecycleRunResult, adapter_status: &str) -> String {
    let route = run
        .selected_route
        .as_ref()
        .map(|route| route.route_id.as_str())
        .unwrap_or("none");
    let terminal = run.terminal_outcome.as_deref().unwrap_or("none");
    let phase = run.current_phase.as_deref().unwrap_or("none");
    let route_execution_result = run
        .selected_route
        .as_ref()
        .map(|route| format!("{}-route-execution.yml", route.route_id))
        .unwrap_or_else(|| "none".to_string());
    format!(
        "# Lifecycle Run\n\nrun_id: {}\nrecorded_at: {}\nlifecycle_id: {}\nexecution_strategy: {}\ntarget: {}\nexecutor: {}\nroute_execution_mode: {}\ncurrent_phase: {}\nselected_route: {}\nterminal_outcome: {}\nfinal_verdict: {}\nadapter_route_status: {}\nroute_execution_result: {}\n\nNote: the lifecycle executor adapter executed the selected route. The runner will re-plan from target receipts and manifest state before selecting any further route.\n",
        run.run_id,
        now_rfc3339().unwrap_or_else(|_| "unknown".to_string()),
        run.lifecycle_id,
        run.execution_strategy,
        run.target,
        run.executor,
        run.route_execution_mode,
        phase,
        route,
        terminal,
        run.final_verdict,
        adapter_status,
        route_execution_result,
    )
}

fn lifecycle_commands(
    lifecycle_id: &str,
    target_abs: &Path,
    route: Option<&RoutePlanState>,
) -> String {
    let mut content = format!(
        "# Lifecycle Commands\n\nPlan again:\n\n```sh\nocton lifecycle plan --lifecycle {lifecycle_id} --target {}\n```\n",
        target_abs.display()
    );
    if let Some(route) = route {
        content.push_str("\nSelected route:\n\n");
        content.push_str(&format!("- route_id: `{}`\n", route.route_id));
        content.push_str(&format!("- route_type: `{}`\n", route.route_type));
        if let Some(command_id) = route.command_id.as_ref() {
            content.push_str(&format!("- command_id: `{command_id}`\n"));
        }
        if let Some(skill_id) = route.skill_id.as_ref() {
            content.push_str(&format!("- skill_id: `{skill_id}`\n"));
        }
        if let Some(prompt_set_id) = route.prompt_set_id.as_ref() {
            content.push_str(&format!("- prompt_set_id: `{prompt_set_id}`\n"));
        }
        content.push_str("\nHandoff:\n\nThe lifecycle runner selected and gated this route. For non-mock executors, it did not invoke the prompt bundle or workflow leaf.\n");
        if route.route_type == "workflow" {
            content.push_str(&format!(
				"\nWorkflow route entry surface:\n\n```sh\nocton workflow run {} --set proposal_path={}\n```\n\nAdd any other required `--set` inputs declared by that workflow contract before running it.\n",
				route.route_id,
				target_abs.display()
			));
        } else {
            content.push_str(
				"\nExtension route entry surface: invoke the listed command or skill to perform the leaf route work.\n",
			);
        }
    }
    content
}

fn route_execution_mode(
    executor: &ExecutorKind,
    final_verdict: &str,
    has_route: bool,
    has_terminal: bool,
) -> &'static str {
    if final_verdict == "mock-route-executed" {
        return "mock-executed";
    }
    if has_terminal || !has_route {
        return "none";
    }
    if matches!(executor, ExecutorKind::Mock) {
        return "mock-not-run";
    }
    if final_verdict == "route-ready" || final_verdict == "gate-rerouted" {
        return "route-handoff";
    }
    "none"
}

fn route_execution_note(mode: &str) -> &'static str {
    match mode {
        "route-handoff" => {
            "Note: this V1 runner stopped after lifecycle orchestration and gate evaluation. It did not invoke the selected extension prompt bundle."
        }
        "mock-executed" => {
            "Note: mock execution is deterministic and synthetic; it does not invoke Codex, Claude, or the selected prompt bundle."
        }
        _ => "Note: no route execution was performed for this run.",
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::time::{SystemTime, UNIX_EPOCH};

    struct FixtureRepo {
        root: PathBuf,
        octon_dir: PathBuf,
    }

    impl FixtureRepo {
        fn new(name: &str) -> Self {
            let millis = SystemTime::now()
                .duration_since(UNIX_EPOCH)
                .unwrap()
                .as_millis();
            let root = std::env::temp_dir().join(format!("octon-lifecycle-{name}-{millis}"));
            fs::create_dir_all(&root).unwrap();
            let octon_dir = root.join(".octon");
            fs::create_dir_all(octon_dir.join("generated/effective/extensions")).unwrap();
            fs::create_dir_all(
                octon_dir.join(
                    "generated/effective/extensions/published/test-extension/bundled/context",
                ),
            )
            .unwrap();
            Self { root, octon_dir }
        }

        fn write(&self, rel: &str, content: &str) {
            let path = self.root.join(rel);
            fs::create_dir_all(path.parent().unwrap()).unwrap();
            fs::write(path, content).unwrap();
        }

        fn write_catalog(&self, lifecycle_id: &str, projection_source_path: &str) {
            self.write(
                ".octon/generated/effective/extensions/catalog.effective.yml",
                &format!(
                    r#"
schema_version: "test"
packs:
  - pack_id: "test-extension"
    capability_profiles: ["validation-surface", "lifecycle-contract"]
    lifecycle_contracts:
      - lifecycle_id: "{lifecycle_id}"
        projection_source_path: "{projection_source_path}"
"#
                ),
            );
        }
    }

    #[test]
    fn lifecycle_unknown_status_fails_closed() {
        assert_eq!(
            classify_lifecycle_status("unrecognized-control-plane-status"),
            LifecycleStopClass::BlockedUnsafe
        );
        for status in [
            "blocked",
            "blocked-gate",
            "blocked-no-route",
            "blocked-max-iterations",
        ] {
            assert_eq!(
                classify_lifecycle_status(status),
                LifecycleStopClass::BlockedRecoverable,
                "{status}"
            );
        }
    }

    #[test]
    fn worktree_hygiene_closeout_receipt_sets_named_plan_blocker() {
        let mut fields = BTreeMap::new();
        fields.insert("verdict".to_string(), "blocked".to_string());
        fields.insert(
            "worktree_hygiene_verdict".to_string(),
            "blocked".to_string(),
        );
        let mut receipt_states = BTreeMap::new();
        receipt_states.insert(
            "proposal-closeout".to_string(),
            ReceiptPlanState {
                path: "packet/support/proposal-closeout.md".to_string(),
                exists: true,
                verdict: Some("blocked".to_string()),
                fields,
                missing_required_fields: Vec::new(),
                stale: None,
                stored_digest: None,
                current_digest: None,
            },
        );

        let (blocker_class, blocker_message) =
            lifecycle_plan_blocker_for_receipts("blocked-no-route", &receipt_states);

        assert_eq!(blocker_class.as_deref(), Some("worktree-hygiene-blocked"));
        assert!(blocker_message
            .as_deref()
            .unwrap_or_default()
            .contains("closeout-change"));
    }

    #[test]
    fn blocked_worktree_hygiene_closeout_receipt_stops_closeout_route_reentry() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("hygiene-closeout-route-reentry");
        fixture.write_catalog(
            "proposal-packet",
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
        );
        fixture.write(
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
            r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["implemented"] }
states: [{ state_id: "closeout" }]
terminal_outcomes: []
receipts:
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
  - route_id: "closeout-packet"
    route_type: "extension"
    enter_when:
      all:
        - manifest_status: "implemented"
        - receipt_complete: "implementation-conformance"
        - receipt_field_equals:
            receipt_id: "implementation-conformance"
            field: "verdict"
            value: "pass"
        - receipt_complete: "post-implementation-drift"
        - receipt_field_equals:
            receipt_id: "post-implementation-drift"
            field: "verdict"
            value: "pass"
        - any:
            - receipt_absent: "proposal-closeout"
            - receipt_field_equals:
                receipt_id: "proposal-closeout"
                field: "verdict"
                value: "blocked"
"#,
        );
        fixture.write("packet/proposal.yml", "status: implemented\n");
        fixture.write(
            "packet/support/implementation-conformance-review.md",
            "verdict: pass\n",
        );
        fixture.write(
            "packet/support/post-implementation-drift-churn-review.md",
            "verdict: pass\n",
        );

        let initial_plan = plan_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-packet",
            Path::new("packet"),
        )
        .unwrap();

        assert_eq!(initial_plan.final_verdict, "route-ready");
        assert_eq!(
            initial_plan
                .next_route
                .as_ref()
                .map(|route| route.route_id.as_str()),
            Some(ROUTE_ID_CLOSEOUT_PACKET)
        );

        fixture.write(
            "packet/support/proposal-closeout.md",
            "verdict: blocked\narchive_authorized: no\nworktree_hygiene_verdict: blocked\nworktree_hygiene_blocker_class: worktree-hygiene-blocked\n",
        );

        let blocked_plan = plan_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-packet",
            Path::new("packet"),
        )
        .unwrap();

        assert_eq!(blocked_plan.final_verdict, "blocked-no-route");
        assert!(blocked_plan.next_route.is_none());
        assert_eq!(
            blocked_plan.blocker_class.as_deref(),
            Some("worktree-hygiene-blocked")
        );
        assert!(blocked_plan
            .blocker_message
            .as_deref()
            .unwrap_or_default()
            .contains("operator scope resolution"));
    }

    #[test]
    fn lifecycle_execution_strategy_defaults_packet_to_route_progression() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("strategy-default-packet");
        fixture.write_catalog(
            "proposal-packet",
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
        );
        fixture.write(
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
            r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["draft"] }
states: [{ state_id: "review" }]
terminal_outcomes: []
receipts: []
routes:
  - route_id: "review-proposal-packet"
    route_type: "extension"
    enter_when:
      manifest_status: "draft"
"#,
        );
        fixture.write("packet/proposal.yml", "status: draft\n");

        let plan = plan_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-packet",
            Path::new("packet"),
        )
        .unwrap();

        assert_eq!(plan.execution_strategy, "route-progression");
    }

    #[test]
    fn lifecycle_execution_strategy_defaults_program_to_orchestrated_replan_loop() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("strategy-default-program");
        fixture.write_catalog(
            "proposal-program",
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycles/proposal-program.contract.yml",
        );
        fixture.write(
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycles/proposal-program.contract.yml",
            r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-program"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "program_packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted"] }
program:
  child_registry_path: "resources/child-packet-index.yml"
  child_lifecycle_id_default: "proposal-packet"
  supported_execution_modes: ["parallel-independent"]
states: [{ state_id: "coordinate" }]
terminal_outcomes: []
receipts:
  - receipt_id: "program-summary"
    path: "support/program-summary.md"
routes:
  - route_id: "review-program"
    route_type: "extension"
"#,
        );

        let strategy =
            lifecycle_execution_strategy_from_octon_dir(&fixture.octon_dir, "proposal-program")
                .unwrap();

        assert_eq!(strategy, LifecycleExecutionStrategy::OrchestratedReplanLoop);
    }

    #[test]
    fn lifecycle_execution_strategy_rejects_program_route_progression() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("strategy-invalid-program");
        fixture.write_catalog(
            "proposal-program",
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycles/proposal-program.contract.yml",
        );
        fixture.write(
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycles/proposal-program.contract.yml",
            r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-program"
owner_extension: "test-extension"
version: "1.0.0"
execution_strategy: "route-progression"
target: { input: "program_packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted"] }
program:
  child_registry_path: "resources/child-packet-index.yml"
  child_lifecycle_id_default: "proposal-packet"
  supported_execution_modes: ["parallel-independent"]
states: [{ state_id: "coordinate" }]
terminal_outcomes: []
receipts:
  - receipt_id: "program-summary"
    path: "support/program-summary.md"
routes:
  - route_id: "review-program"
    route_type: "extension"
"#,
        );

        let error =
            lifecycle_execution_strategy_from_octon_dir(&fixture.octon_dir, "proposal-program")
                .unwrap_err();
        let error = format!("{error:#}");

        assert!(error.contains("program lifecycles require orchestrated-replan-loop"));
    }

    #[test]
    fn lifecycle_execution_strategy_rejects_orchestrated_without_program() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("strategy-invalid-packet");
        fixture.write_catalog(
            "proposal-packet",
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
        );
        fixture.write(
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
            r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
execution_strategy: "orchestrated-replan-loop"
target: { input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["draft"] }
states: [{ state_id: "review" }]
terminal_outcomes: []
receipts: []
routes:
  - route_id: "review-proposal-packet"
    route_type: "extension"
"#,
        );

        let error =
            lifecycle_execution_strategy_from_octon_dir(&fixture.octon_dir, "proposal-packet")
                .unwrap_err();
        let error = format!("{error:#}");

        assert!(error.contains("without a program section"));
    }

    #[test]
    fn lifecycle_postmortem_maps_workflow_substitutes_for_missing_control_refs() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("postmortem-substitutes");
        let run_id = "postmortem-substitutes";
        fixture.write(
            &format!(".octon/state/control/execution/runs/{run_id}/locks/.keep"),
            "",
        );
        fixture.write(
            &format!(
                ".octon/state/evidence/runs/workflows/{run_id}/program-lifecycle-checkpoint.yml"
            ),
            "schema_version: octon-program-lifecycle-checkpoint-v1\nrun_id: postmortem-substitutes\nlatest_event_index: 1\n",
        );
        fixture.write(
            &format!(".octon/state/evidence/runs/workflows/{run_id}/program-events.ndjson"),
            "{\"schema_version\":\"octon-program-lifecycle-event-v2\",\"run_id\":\"postmortem-substitutes\",\"event_index\":1,\"event_type\":\"plan-created\"}\n",
        );
        fixture.write(
            &format!(".octon/state/evidence/runs/workflows/{run_id}/summary.md"),
            "# summary\nfinal_verdict: completed\n",
        );

        let result = run_lifecycle_postmortem_from_octon_dir(&fixture.octon_dir, run_id).unwrap();
        assert_eq!(result.status, "prepared");

        let evidence_map: serde_yaml::Value = serde_yaml::from_slice(
            &fs::read(
                fixture
                    .octon_dir
                    .join("state/evidence/runs/postmortem-substitutes/assurance/lifecycle-postmortem/evidence-map.yml"),
            )
            .unwrap(),
        )
        .unwrap();
        assert_eq!(
            evidence_map
                .get("schema_version")
                .and_then(serde_yaml::Value::as_str),
            Some("lifecycle-postmortem-evidence-map-v2")
        );
        let substitute_names = evidence_map
            .get("substitute_refs")
            .and_then(serde_yaml::Value::as_sequence)
            .unwrap()
            .iter()
            .filter_map(|value| value.get("ref_name"))
            .filter_map(serde_yaml::Value::as_str)
            .collect::<BTreeSet<_>>();
        assert!(substitute_names.contains("workflow-program-lifecycle-checkpoint"));
        assert!(substitute_names.contains("workflow-program-events"));
        let missing_names = evidence_map
            .get("missing_refs")
            .and_then(serde_yaml::Value::as_sequence)
            .unwrap()
            .iter()
            .filter_map(|value| value.get("ref_name"))
            .filter_map(serde_yaml::Value::as_str)
            .collect::<BTreeSet<_>>();
        assert!(missing_names.contains("program-lifecycle-checkpoint"));
        assert!(missing_names.contains("program-events"));

        let known_limits = fs::read_to_string(
            fixture
                .octon_dir
                .join("state/evidence/runs/postmortem-substitutes/assurance/lifecycle-postmortem/known-limits.yml"),
        )
        .unwrap();
        assert!(known_limits.contains("substitute_refs"));
        assert!(known_limits.contains("use those retained workflow refs"));
    }

    #[test]
    fn lifecycle_postmortem_classifies_failing_slices_as_diagnostic() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("postmortem-diagnostics");
        let run_id = "postmortem-diagnostics";
        fixture.write(
            &format!(".octon/state/evidence/runs/workflows/{run_id}/summary.md"),
            "# summary\nfinal_verdict: completed\n",
        );
        fixture.write(
            &format!(
                ".octon/state/evidence/runs/workflows/{run_id}/aggregate-terminal-blockers.yml"
            ),
            "schema_version: octon-program-aggregate-terminal-blockers-v1\nblocked_required_child_count: 0\nblocked_required_children: []\n",
        );
        fixture.write(
            &format!(".octon/state/evidence/runs/workflows/{run_id}/blocker-ledger.yml"),
            "schema_version: octon-program-blocker-ledger-v1\nblocker_count: 0\nblockers: []\n",
        );
        fixture.write(
            &format!(".octon/state/evidence/runs/workflows/{run_id}/failing-slice-manifest.yml"),
            "schema_version: octon-failing-slice-manifest-v1\nno_failure_observed: false\nslices:\n  - reason: failure-marker\n",
        );

        run_lifecycle_postmortem_from_octon_dir(&fixture.octon_dir, run_id).unwrap();
        let evaluator_input = fs::read_to_string(
            fixture
                .octon_dir
                .join("state/evidence/runs/postmortem-diagnostics/assurance/lifecycle-postmortem/evaluator-input.md"),
        )
        .unwrap();
        let terminal_index = evaluator_input.find("## Terminal State Evidence").unwrap();
        let diagnostic_index = evaluator_input
            .find("## Diagnostic/Historical Evidence")
            .unwrap();
        assert!(terminal_index < diagnostic_index);
        assert!(evaluator_input.contains("aggregate-terminal-blockers"));
        assert!(evaluator_input.contains("failing-slice evidence is historical"));
        assert!(evaluator_input.contains("must not override terminal blocker ledgers"));
    }

    #[test]
    fn lifecycle_postmortem_finds_bounded_associated_evidence_with_run_id() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("postmortem-associated");
        let run_id = "postmortem-associated";
        fixture.write(
            &format!(".octon/state/evidence/runs/workflows/{run_id}/summary.md"),
            "# summary\nfinal_verdict: completed\n",
        );
        fixture.write(
            ".octon/state/evidence/runs/skills/closeout-change/receipt.yml",
            "run_id: postmortem-associated\nverdict: pass\n",
        );
        fixture.write(
            ".octon/state/evidence/runs/skills/closeout-worktree/receipt.yml",
            "run_id: postmortem-associated\nverdict: pass\n",
        );
        fixture.write(
            ".octon/state/evidence/disclosure/runs/archive-proposal-postmortem-associated/report.md",
            "archive retained for postmortem-associated\n",
        );
        fixture.write(
            ".octon/state/evidence/validation/analysis/postmortem-associated.md",
            "validation evidence for postmortem-associated\n",
        );

        run_lifecycle_postmortem_from_octon_dir(&fixture.octon_dir, run_id).unwrap();
        let evidence_map: serde_yaml::Value = serde_yaml::from_slice(
            &fs::read(
                fixture
                    .octon_dir
                    .join("state/evidence/runs/postmortem-associated/assurance/lifecycle-postmortem/evidence-map.yml"),
            )
            .unwrap(),
        )
        .unwrap();
        let associated_roles = evidence_map
            .get("associated_refs")
            .and_then(serde_yaml::Value::as_sequence)
            .unwrap()
            .iter()
            .filter_map(|value| value.get("ref_class"))
            .filter_map(serde_yaml::Value::as_str)
            .collect::<BTreeSet<_>>();

        assert!(associated_roles.contains("associated-closeout-receipt"));
        assert!(associated_roles.contains("associated-worktree-closeout-receipt"));
        assert!(associated_roles.contains("associated-archive-receipt"));
        assert!(associated_roles.contains("associated-validation-report"));
    }

    #[test]
    fn lifecycle_postmortem_excludes_unlinked_and_non_evidence_associated_candidates() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("postmortem-associated-negative");
        let run_id = "postmortem-associated-negative";
        fixture.write(
            &format!(".octon/state/evidence/runs/workflows/{run_id}/summary.md"),
            "# summary\nfinal_verdict: completed\n",
        );
        fixture.write(
            ".octon/state/evidence/runs/skills/closeout-change/unlinked.yml",
            "run_id: different-run\nverdict: pass\n",
        );
        fixture.write(
            ".octon/generated/effective/runtime/postmortem-associated-negative.yml",
            "run_id: postmortem-associated-negative\n",
        );
        fixture.write(
            ".octon/inputs/exploratory/proposals/architecture/postmortem-associated-negative/proposal.yml",
            "proposal_id: postmortem-associated-negative\n",
        );

        run_lifecycle_postmortem_from_octon_dir(&fixture.octon_dir, run_id).unwrap();
        let evidence_map: serde_yaml::Value = serde_yaml::from_slice(
            &fs::read(
                fixture
                    .octon_dir
                    .join("state/evidence/runs/postmortem-associated-negative/assurance/lifecycle-postmortem/evidence-map.yml"),
            )
            .unwrap(),
        )
        .unwrap();
        let associated = evidence_map
            .get("associated_refs")
            .and_then(serde_yaml::Value::as_sequence)
            .unwrap();

        assert!(associated.is_empty());
    }

    #[test]
    fn lifecycle_execution_request_binds_inputs_from_receipt_fields() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("receipt-input-binding");
        fixture.write_catalog(
            "proposal-packet",
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
        );
        fixture.write(
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
            r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["implemented"] }
input_bindings:
  target:
    source: "lifecycle.target"
  disposition:
    source: "receipt.proposal-closeout.archive_disposition"
  promotion_evidence:
    source: "receipt.proposal-closeout.promotion_evidence"
states: [{ state_id: "archive" }]
terminal_outcomes: []
receipts:
  - receipt_id: "proposal-closeout"
    path: "support/proposal-closeout.md"
    required_fields: ["verdict", "closed_at", "archive_authorized"]
    verdict_field: "verdict"
routes:
  - route_id: "archive-proposal"
    route_type: "workflow"
"#,
        );
        fixture.write("packet/proposal.yml", "status: implemented\n");
        fixture.write(
            "packet/support/proposal-closeout.md",
            "verdict: pass\nclosed_at: 2026-05-14T00:00:00Z\narchive_authorized: yes\narchive_disposition: implemented\npromotion_evidence: .octon/state/evidence/example.md\n",
        );
        let route = RoutePlanState {
            route_id: "archive-proposal".to_string(),
            route_type: "workflow".to_string(),
            command_id: None,
            skill_id: None,
            prompt_set_id: None,
        };

        let request = lifecycle_execution_request_for_route(
            &fixture.octon_dir,
            "run-1",
            "proposal-packet",
            "packet",
            None,
            &route,
            ExecutorKind::Codex,
            60,
            "unattended",
            0,
            &BTreeMap::new(),
            &[],
            fixture
                .root
                .join(".octon/state/evidence/runs/workflows/run-1"),
            fixture
                .root
                .join(".octon/state/control/execution/runs/run-1/lifecycle-checkpoint.yml"),
            None,
            None,
        )
        .unwrap()
        .unwrap();

        assert_eq!(
            request.bound_inputs.get("disposition").map(String::as_str),
            Some("implemented")
        );
        assert_eq!(
            request
                .bound_inputs
                .get("promotion_evidence")
                .map(String::as_str),
            Some(".octon/state/evidence/example.md")
        );
    }

    #[test]
    fn archive_proposal_request_maps_archive_ready_outcome_to_implemented_disposition() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("archive-ready-disposition-binding");
        fixture.write_catalog(
            "proposal-packet",
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
        );
        fixture.write(
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
            r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["implemented"] }
input_bindings:
  target:
    source: "lifecycle.target"
  disposition:
    source: "receipt.proposal-closeout.archive_disposition"
  promotion_evidence:
    source: "receipt.proposal-closeout.promotion_evidence"
states: [{ state_id: "archive" }]
terminal_outcomes: []
receipts:
  - receipt_id: "proposal-closeout"
    path: "support/proposal-closeout.md"
    required_fields: ["verdict", "closed_at", "archive_authorized"]
    verdict_field: "verdict"
routes:
  - route_id: "archive-proposal"
    route_type: "workflow"
"#,
        );
        fixture.write("packet/proposal.yml", "status: implemented\n");
        fixture.write(
            "packet/support/proposal-closeout.md",
            "verdict: pass\nclosed_at: 2026-06-23T00:00:00Z\narchive_authorized: yes\narchive_disposition: archive-ready\npromotion_evidence: .octon/state/evidence/example.md\n",
        );
        let route = RoutePlanState {
            route_id: "archive-proposal".to_string(),
            route_type: "workflow".to_string(),
            command_id: None,
            skill_id: None,
            prompt_set_id: None,
        };

        let request = lifecycle_execution_request_for_route(
            &fixture.octon_dir,
            "run-1",
            "proposal-packet",
            "packet",
            None,
            &route,
            ExecutorKind::Codex,
            60,
            "unattended",
            0,
            &BTreeMap::new(),
            &[],
            fixture
                .root
                .join(".octon/state/evidence/runs/workflows/run-1"),
            fixture
                .root
                .join(".octon/state/control/execution/runs/run-1/lifecycle-checkpoint.yml"),
            None,
            None,
        )
        .unwrap()
        .unwrap();

        assert_eq!(
            request.bound_inputs.get("disposition").map(String::as_str),
            Some("implemented")
        );
        assert_eq!(
            request
                .bound_inputs
                .get("archive_disposition_source_outcome")
                .map(String::as_str),
            Some("archive-ready")
        );
        assert_eq!(
            request
                .bound_inputs
                .get("archive_disposition_mapping")
                .map(String::as_str),
            Some("archive-ready->implemented")
        );
    }

    #[test]
    fn archive_proposal_request_suppresses_missing_promotion_evidence_when_existing_refs_remain() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("archive-promotion-evidence-suppression");
        fixture.write_catalog(
            "proposal-packet",
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
        );
        fixture.write(
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
            r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["implemented"] }
input_bindings:
  target:
    source: "lifecycle.target"
  disposition:
    source: "receipt.proposal-closeout.archive_disposition"
  promotion_evidence:
    source: "receipt.proposal-closeout.promotion_evidence"
states: [{ state_id: "archive" }]
terminal_outcomes: []
receipts:
  - receipt_id: "proposal-closeout"
    path: "support/proposal-closeout.md"
    required_fields: ["verdict", "closed_at", "archive_authorized"]
    verdict_field: "verdict"
routes:
  - route_id: "archive-proposal"
    route_type: "workflow"
"#,
        );
        fixture.write("packet/proposal.yml", "status: implemented\n");
        fixture.write(
            ".octon/state/evidence/existing-return.json",
            "{\"schema_version\":\"test\"}\n",
        );
        fixture.write(
            ".octon/state/evidence/existing-report.yml",
            "verdict: pass\n",
        );
        fixture.write(
            "packet/support/proposal-closeout.md",
            "verdict: pass\nclosed_at: 2026-06-23T00:00:00Z\narchive_authorized: yes\narchive_disposition: archive-ready\npromotion_evidence:\n  - .octon/state/evidence/missing-validation-summary.yml\n  - .octon/state/evidence/existing-return.json\n  - .octon/state/evidence/existing-report.yml\n",
        );
        let route = RoutePlanState {
            route_id: "archive-proposal".to_string(),
            route_type: "workflow".to_string(),
            command_id: None,
            skill_id: None,
            prompt_set_id: None,
        };

        let request = lifecycle_execution_request_for_route(
            &fixture.octon_dir,
            "run-1",
            "proposal-packet",
            "packet",
            None,
            &route,
            ExecutorKind::Codex,
            60,
            "unattended",
            0,
            &BTreeMap::new(),
            &[],
            fixture
                .root
                .join(".octon/state/evidence/runs/workflows/run-1"),
            fixture
                .root
                .join(".octon/state/control/execution/runs/run-1/lifecycle-checkpoint.yml"),
            None,
            None,
        )
        .unwrap()
        .unwrap();

        assert_eq!(
            request.bound_inputs.get("disposition").map(String::as_str),
            Some("implemented")
        );
        assert_eq!(
            request
                .bound_inputs
                .get("promotion_evidence")
                .map(String::as_str),
            Some(".octon/state/evidence/existing-return.json,.octon/state/evidence/existing-report.yml")
        );
        assert_eq!(
            request
                .bound_inputs
                .get("archive_promotion_evidence_binding")
                .map(String::as_str),
            Some("suppressed-missing-retained-evidence-refs")
        );
        assert_eq!(
            request
                .bound_inputs
                .get("archive_promotion_evidence_suppressed_missing_refs")
                .map(String::as_str),
            Some(".octon/state/evidence/missing-validation-summary.yml")
        );
    }

    #[test]
    fn archive_proposal_request_keeps_missing_promotion_evidence_when_no_existing_refs_remain() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("archive-promotion-evidence-all-missing");
        fixture.write_catalog(
            "proposal-packet",
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
        );
        fixture.write(
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
            r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["implemented"] }
input_bindings:
  target:
    source: "lifecycle.target"
  disposition:
    source: "receipt.proposal-closeout.archive_disposition"
  promotion_evidence:
    source: "receipt.proposal-closeout.promotion_evidence"
states: [{ state_id: "archive" }]
terminal_outcomes: []
receipts:
  - receipt_id: "proposal-closeout"
    path: "support/proposal-closeout.md"
    required_fields: ["verdict", "closed_at", "archive_authorized"]
    verdict_field: "verdict"
routes:
  - route_id: "archive-proposal"
    route_type: "workflow"
"#,
        );
        fixture.write("packet/proposal.yml", "status: implemented\n");
        fixture.write(
            "packet/support/proposal-closeout.md",
            "verdict: pass\nclosed_at: 2026-06-23T00:00:00Z\narchive_authorized: yes\narchive_disposition: implemented\npromotion_evidence:\n  - .octon/state/evidence/missing-one.yml\n  - .octon/state/evidence/missing-two.yml\n",
        );
        let route = RoutePlanState {
            route_id: "archive-proposal".to_string(),
            route_type: "workflow".to_string(),
            command_id: None,
            skill_id: None,
            prompt_set_id: None,
        };

        let request = lifecycle_execution_request_for_route(
            &fixture.octon_dir,
            "run-1",
            "proposal-packet",
            "packet",
            None,
            &route,
            ExecutorKind::Codex,
            60,
            "unattended",
            0,
            &BTreeMap::new(),
            &[],
            fixture
                .root
                .join(".octon/state/evidence/runs/workflows/run-1"),
            fixture
                .root
                .join(".octon/state/control/execution/runs/run-1/lifecycle-checkpoint.yml"),
            None,
            None,
        )
        .unwrap()
        .unwrap();

        assert_eq!(
            request
                .bound_inputs
                .get("promotion_evidence")
                .map(String::as_str),
            Some(".octon/state/evidence/missing-one.yml,.octon/state/evidence/missing-two.yml")
        );
        assert!(!request
            .bound_inputs
            .contains_key("archive_promotion_evidence_binding"));
    }

    #[test]
    fn lifecycle_execution_request_binds_list_inputs_from_receipt_fields() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("receipt-list-input-binding");
        fixture.write_catalog(
            "proposal-packet",
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
        );
        fixture.write(
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
            r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["implemented"] }
input_bindings:
  target:
    source: "lifecycle.target"
  disposition:
    source: "receipt.proposal-closeout.archive_disposition"
  promotion_evidence:
    source: "receipt.proposal-closeout.promotion_evidence"
states: [{ state_id: "archive" }]
terminal_outcomes: []
receipts:
  - receipt_id: "proposal-closeout"
    path: "support/proposal-closeout.md"
    required_fields: ["verdict", "closed_at", "archive_authorized"]
    verdict_field: "verdict"
routes:
  - route_id: "archive-proposal"
    route_type: "workflow"
"#,
        );
        fixture.write("packet/proposal.yml", "status: implemented\n");
        fixture.write(
            "packet/support/proposal-closeout.md",
            "verdict: pass\nclosed_at: 2026-05-14T00:00:00Z\narchive_authorized: yes\narchive_disposition: implemented\npromotion_evidence:\n  - .octon/state/evidence/example-one.md\n  - \".octon/state/evidence/example-two.md\"\n",
        );
        let route = RoutePlanState {
            route_id: "archive-proposal".to_string(),
            route_type: "workflow".to_string(),
            command_id: None,
            skill_id: None,
            prompt_set_id: None,
        };

        let request = lifecycle_execution_request_for_route(
            &fixture.octon_dir,
            "run-1",
            "proposal-packet",
            "packet",
            None,
            &route,
            ExecutorKind::Codex,
            60,
            "unattended",
            0,
            &BTreeMap::new(),
            &[],
            fixture
                .root
                .join(".octon/state/evidence/runs/workflows/run-1"),
            fixture
                .root
                .join(".octon/state/control/execution/runs/run-1/lifecycle-checkpoint.yml"),
            None,
            None,
        )
        .unwrap()
        .unwrap();

        assert_eq!(
            request
                .bound_inputs
                .get("promotion_evidence")
                .map(String::as_str),
            Some(".octon/state/evidence/example-one.md,.octon/state/evidence/example-two.md")
        );
    }

    #[test]
    fn promote_proposal_request_binds_promotion_evidence_from_implementation_run_refs() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("promote-implementation-evidence-binding");
        fixture.write_catalog(
            "proposal-packet",
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
        );
        fixture.write(
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
            r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted"] }
input_bindings:
  target:
    source: "lifecycle.target"
  promotion_evidence:
    source: "receipt.proposal-closeout.promotion_evidence"
states: [{ state_id: "promote" }]
terminal_outcomes: []
receipts:
  - receipt_id: "implementation-run"
    path: "support/implementation-run.md"
    required_fields: ["verdict", "implemented_at", "promotion_evidence_count"]
    verdict_field: "verdict"
  - receipt_id: "proposal-closeout"
    path: "support/proposal-closeout.md"
    required_fields: ["verdict", "closed_at", "archive_authorized"]
    verdict_field: "verdict"
routes:
  - route_id: "promote-proposal"
    route_type: "workflow"
    required_inputs: ["promotion_evidence"]
"#,
        );
        fixture.write("packet/proposal.yml", "status: accepted\n");
        fixture.write(
            ".octon/state/evidence/fresh-promote-one.yml",
            "verdict: pass\n",
        );
        fixture.write(
            ".octon/state/evidence/fresh-promote-two.yml",
            "verdict: pass\n",
        );
        fixture.write(
            "packet/support/implementation-run.md",
            "verdict: pass\nimplemented_at: 2026-06-23T00:00:00Z\npromotion_evidence_count: 2\n\n# Implementation Run\n\n## Evidence Refs\n\n- .octon/state/evidence/fresh-promote-one.yml\n- .octon/state/evidence/fresh-promote-two.yml\n",
        );
        let route = RoutePlanState {
            route_id: "promote-proposal".to_string(),
            route_type: "workflow".to_string(),
            command_id: None,
            skill_id: None,
            prompt_set_id: None,
        };

        let request = lifecycle_execution_request_for_route(
            &fixture.octon_dir,
            "run-1",
            "proposal-packet",
            "packet",
            None,
            &route,
            ExecutorKind::Codex,
            60,
            "unattended",
            0,
            &BTreeMap::new(),
            &[],
            fixture
                .root
                .join(".octon/state/evidence/runs/workflows/run-1"),
            fixture
                .root
                .join(".octon/state/control/execution/runs/run-1/lifecycle-checkpoint.yml"),
            None,
            None,
        )
        .unwrap()
        .unwrap();

        assert_eq!(
            request
                .bound_inputs
                .get("promotion_evidence")
                .map(String::as_str),
            Some(
                ".octon/state/evidence/fresh-promote-one.yml,.octon/state/evidence/fresh-promote-two.yml"
            )
        );
        assert_eq!(
            request
                .bound_inputs
                .get("promote_promotion_evidence_binding")
                .map(String::as_str),
            Some("implementation-run-evidence-refs")
        );
        assert_eq!(
            request
                .bound_inputs
                .get("promote_promotion_evidence_source_ref_count")
                .map(String::as_str),
            Some("2")
        );
    }

    #[test]
    fn promote_proposal_request_supersedes_stale_closeout_promotion_evidence() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("promote-supersedes-closeout-evidence");
        fixture.write_catalog(
            "proposal-packet",
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
        );
        fixture.write(
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
            r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted"] }
input_bindings:
  target:
    source: "lifecycle.target"
  promotion_evidence:
    source: "receipt.proposal-closeout.promotion_evidence"
states: [{ state_id: "promote" }]
terminal_outcomes: []
receipts:
  - receipt_id: "implementation-run"
    path: "support/implementation-run.md"
    required_fields: ["verdict", "implemented_at", "promotion_evidence_count"]
    verdict_field: "verdict"
  - receipt_id: "proposal-closeout"
    path: "support/proposal-closeout.md"
    required_fields: ["verdict", "closed_at", "archive_authorized"]
    verdict_field: "verdict"
routes:
  - route_id: "promote-proposal"
    route_type: "workflow"
    required_inputs: ["promotion_evidence"]
"#,
        );
        fixture.write("packet/proposal.yml", "status: accepted\n");
        fixture.write(
            ".octon/state/evidence/stale-closeout.yml",
            "verdict: blocked\n",
        );
        fixture.write(".octon/state/evidence/fresh-promote.yml", "verdict: pass\n");
        fixture.write(
            "packet/support/proposal-closeout.md",
            "verdict: blocked\nclosed_at: 2026-06-22T00:00:00Z\narchive_authorized: no\npromotion_evidence: .octon/state/evidence/stale-closeout.yml\n",
        );
        fixture.write(
            "packet/support/implementation-run.md",
            "verdict: pass\nimplemented_at: 2026-06-23T00:00:00Z\npromotion_evidence_count: 1\n\n# Implementation Run\n\n## Implementation Evidence Refs\n\n- .octon/state/evidence/fresh-promote.yml\n",
        );
        let route = RoutePlanState {
            route_id: "promote-proposal".to_string(),
            route_type: "workflow".to_string(),
            command_id: None,
            skill_id: None,
            prompt_set_id: None,
        };

        let request = lifecycle_execution_request_for_route(
            &fixture.octon_dir,
            "run-1",
            "proposal-packet",
            "packet",
            None,
            &route,
            ExecutorKind::Codex,
            60,
            "unattended",
            0,
            &BTreeMap::new(),
            &[],
            fixture
                .root
                .join(".octon/state/evidence/runs/workflows/run-1"),
            fixture
                .root
                .join(".octon/state/control/execution/runs/run-1/lifecycle-checkpoint.yml"),
            None,
            None,
        )
        .unwrap()
        .unwrap();

        assert_eq!(
            request
                .bound_inputs
                .get("promotion_evidence")
                .map(String::as_str),
            Some(".octon/state/evidence/fresh-promote.yml")
        );
        assert_eq!(
            request
                .bound_inputs
                .get("promote_promotion_evidence_prior_binding")
                .map(String::as_str),
            Some("superseded-non-controlling")
        );
    }

    #[test]
    fn workflow_lifecycle_request_binds_missing_required_workflow_inputs_from_run_inputs() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("workflow-run-input-fallback");
        fixture.write_catalog(
            "proposal-packet",
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
        );
        fixture.write(
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
            r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted"] }
input_bindings:
  target:
    source: "lifecycle.target"
  proposal_path:
    source: "lifecycle.target"
  promotion_evidence:
    source: "receipt.proposal-closeout.promotion_evidence"
states: [{ state_id: "promote" }]
terminal_outcomes: []
receipts:
  - receipt_id: "proposal-closeout"
    path: "support/proposal-closeout.md"
    required_fields: ["verdict", "closed_at", "archive_authorized"]
    verdict_field: "verdict"
routes:
  - route_id: "promote-proposal"
    route_type: "workflow"
"#,
        );
        fixture.write("packet/proposal.yml", "status: accepted\n");
        let route = RoutePlanState {
            route_id: "promote-proposal".to_string(),
            route_type: "workflow".to_string(),
            command_id: None,
            skill_id: None,
            prompt_set_id: None,
        };
        let mut run_inputs = BTreeMap::new();
        run_inputs.insert(
            "promotion_evidence".to_string(),
            ".octon/framework/product/features/catalog.yml".to_string(),
        );

        let request = lifecycle_execution_request_for_route(
            &fixture.octon_dir,
            "run-1",
            "proposal-packet",
            "packet",
            None,
            &route,
            ExecutorKind::Codex,
            60,
            "unattended",
            0,
            &run_inputs,
            &[],
            fixture
                .root
                .join(".octon/state/evidence/runs/workflows/run-1"),
            fixture
                .root
                .join(".octon/state/control/execution/runs/run-1/lifecycle-checkpoint.yml"),
            None,
            None,
        )
        .unwrap()
        .unwrap();

        assert_eq!(
            request
                .bound_inputs
                .get("proposal_path")
                .map(String::as_str),
            Some("packet")
        );
        assert_eq!(
            request
                .bound_inputs
                .get("promotion_evidence")
                .map(String::as_str),
            Some(".octon/framework/product/features/catalog.yml")
        );
    }

    #[test]
    fn lifecycle_execution_request_uses_retained_gate_results_for_dispatch_proof() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("request-gate-results");
        fixture.write_catalog(
            "proposal-packet",
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
        );
        fixture.write(
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
            r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted"] }
states: [{ state_id: "implement" }]
terminal_outcomes: []
receipts: []
routes:
  - route_id: "run-packet-implementation"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "route-completion-and-target"
      required_evidence_gates: ["strict-review"]
      required_receipts_before_dispatch: []
      required_receipts_before_completion: []
      replay_class: "bounded-retry"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override"]
"#,
        );
        fixture.write("packet/proposal.yml", "status: accepted\n");
        let route = RoutePlanState {
            route_id: "run-packet-implementation".to_string(),
            route_type: "extension".to_string(),
            command_id: None,
            skill_id: None,
            prompt_set_id: None,
        };
        let evidence_root = fixture
            .root
            .join(".octon/state/evidence/runs/workflows/run-1");
        let checkpoint_path = fixture
            .root
            .join(".octon/state/control/execution/runs/run-1/lifecycle-checkpoint.yml");

        let missing_gate = lifecycle_execution_request_for_route(
            &fixture.octon_dir,
            "run-1",
            "proposal-packet",
            "packet",
            None,
            &route,
            ExecutorKind::Codex,
            60,
            "unattended",
            0,
            &BTreeMap::new(),
            &[],
            evidence_root.clone(),
            checkpoint_path.clone(),
            None,
            None,
        )
        .unwrap()
        .unwrap();
        assert!(!missing_gate
            .evidence_gate_results
            .contains_key("strict-review"));

        let passing_results = [GatePlanResult {
            gate_id: "strict-review".to_string(),
            validator_id: "strict-review-validator".to_string(),
            passed: true,
            exit_code: Some(0),
            stdout: String::new(),
            stderr: String::new(),
        }];
        let passing_gate = lifecycle_execution_request_for_route(
            &fixture.octon_dir,
            "run-1",
            "proposal-packet",
            "packet",
            None,
            &route,
            ExecutorKind::Codex,
            60,
            "unattended",
            0,
            &BTreeMap::new(),
            &passing_results,
            evidence_root.clone(),
            checkpoint_path.clone(),
            None,
            None,
        )
        .unwrap()
        .unwrap();
        assert_eq!(
            passing_gate
                .evidence_gate_results
                .get("strict-review")
                .map(String::as_str),
            Some("pass")
        );

        let failing_results = [GatePlanResult {
            gate_id: "strict-review".to_string(),
            validator_id: "strict-review-validator".to_string(),
            passed: false,
            exit_code: Some(1),
            stdout: String::new(),
            stderr: "failed".to_string(),
        }];
        let failing_gate = lifecycle_execution_request_for_route(
            &fixture.octon_dir,
            "run-1",
            "proposal-packet",
            "packet",
            None,
            &route,
            ExecutorKind::Codex,
            60,
            "unattended",
            0,
            &BTreeMap::new(),
            &failing_results,
            evidence_root,
            checkpoint_path,
            None,
            None,
        )
        .unwrap()
        .unwrap();
        assert_eq!(
            failing_gate
                .evidence_gate_results
                .get("strict-review")
                .map(String::as_str),
            Some("fail")
        );
    }

    #[test]
    fn lifecycle_plan_routes_revision_required_to_revision() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("revision");
        fixture.write(
            ".octon/generated/effective/extensions/catalog.effective.yml",
            r#"
schema_version: "test"
packs:
  - pack_id: "test-extension"
    capability_profiles: ["validation-surface", "lifecycle-contract"]
    lifecycle_contracts:
      - lifecycle_id: "proposal-packet"
        projection_source_path: ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml"
"#,
        );
        fixture.write(
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
            r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["in-review"] }
states: [{ state_id: "review" }, { state_id: "revise" }]
terminal_outcomes: [{ outcome_id: "rejected", when: { receipt_verdict: { receipt_id: "proposal-review", value: "rejected" } } }]
receipts:
  - receipt_id: "proposal-review"
    path: "support/proposal-review.md"
    verdict_field: "verdict"
routes:
  - route_id: "revise-proposal-packet"
    route_type: "extension"
    enter_when:
      receipt_verdict: { receipt_id: "proposal-review", value: "revision-required" }
"#,
        );
        fixture.write("packet/proposal.yml", "status: in-review\n");
        fixture.write(
            "packet/support/proposal-review.md",
            "review_id: review-1\nverdict: revision-required\n",
        );

        let plan = plan_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-packet",
            Path::new("packet"),
        )
        .unwrap();

        assert_eq!(
            plan.next_route
                .as_ref()
                .map(|route| route.route_id.as_str()),
            Some("revise-proposal-packet")
        );
        assert_eq!(plan.final_verdict, "route-ready");
    }

    #[test]
    fn packet_lifecycle_cancellation_is_durable_across_resume() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("packet-cancel");
        fixture.write(
            ".octon/generated/effective/extensions/catalog.effective.yml",
            r#"
schema_version: "test"
packs:
  - pack_id: "test-extension"
    capability_profiles: ["validation-surface", "lifecycle-contract"]
    lifecycle_contracts:
      - lifecycle_id: "proposal-packet"
        projection_source_path: ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml"
"#,
        );
        fixture.write(
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
            r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["draft"] }
states: [{ state_id: "review" }]
terminal_outcomes: []
receipts: []
routes:
  - route_id: "review-proposal"
    route_type: "agent"
    enter_when: { manifest_status: "draft" }
"#,
        );
        fixture.write("packet/proposal.yml", "status: draft\n");

        let run = run_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            RunLifecycleOptions {
                lifecycle_id: "proposal-packet".to_string(),
                target: PathBuf::from("packet"),
                run_id: Some("packet-cancel".to_string()),
                executor: ExecutorKind::Auto,
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
        assert_eq!(run.final_verdict, "route-ready");

        let cancel =
            cancel_packet_lifecycle_run(&fixture.octon_dir, "packet-cancel", "operator stop")
                .unwrap();
        assert_eq!(cancel.final_verdict, "cancelled");
        assert!(fixture
            .octon_dir
            .join("state/control/execution/runs/packet-cancel/cancellation.yml")
            .is_file());

        let resumed = resume_lifecycle_from_octon_dir(&fixture.octon_dir, "packet-cancel").unwrap();
        assert_eq!(resumed.final_verdict, "cancelled");
        assert_eq!(resumed.route_execution_mode, "none");
        let checkpoint: LifecycleCheckpoint = serde_yaml::from_slice(
            &fs::read(
                fixture
                    .octon_dir
                    .join("state/control/execution/runs/packet-cancel/lifecycle-checkpoint.yml"),
            )
            .unwrap(),
        )
        .unwrap();
        assert_eq!(checkpoint.cancel_reason.as_deref(), Some("operator stop"));
        let event_log = fs::read_to_string(
            fixture
                .octon_dir
                .join("state/control/execution/runs/packet-cancel/lifecycle-events.ndjson"),
        )
        .unwrap();
        assert!(event_log.contains("\"event_type\":\"cancelled\""));
    }

    #[test]
    fn terminal_outcome_overrides_matching_route() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("archived");
        fixture.write(
            ".octon/generated/effective/extensions/catalog.effective.yml",
            r#"
schema_version: "test"
packs:
  - pack_id: "test-extension"
    capability_profiles: ["validation-surface", "lifecycle-contract"]
    lifecycle_contracts:
      - lifecycle_id: "proposal-packet"
        projection_source_path: ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml"
"#,
        );
        fixture.write(
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
            r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["archived"] }
states: [{ state_id: "done" }]
terminal_outcomes: [{ outcome_id: "done", when: { manifest_status: "archived" } }]
receipts:
  - receipt_id: "proposal-review"
    path: "support/proposal-review.md"
routes:
  - route_id: "review-proposal-packet"
    route_type: "extension"
    enter_when:
      manifest_status: "archived"
"#,
        );
        fixture.write("packet/proposal.yml", "status: archived\n");

        let plan = plan_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-packet",
            Path::new("packet"),
        )
        .unwrap();

        assert!(plan.next_route.is_none());
        assert_eq!(plan.terminal_outcome.as_deref(), Some("done"));
        assert_eq!(plan.final_verdict, "completed");
    }

    #[test]
    fn receipt_plan_uses_configured_verdict_field() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("custom-verdict");
        fixture.write(
            ".octon/generated/effective/extensions/catalog.effective.yml",
            r#"
schema_version: "test"
packs:
  - pack_id: "test-extension"
    capability_profiles: ["validation-surface", "lifecycle-contract"]
    lifecycle_contracts:
      - lifecycle_id: "custom-lifecycle"
        projection_source_path: ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml"
"#,
        );
        fixture.write(
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
            r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "custom-lifecycle"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "packet_path", manifest_path: "manifest.yml", status_field: "status", allowed_statuses: ["open"] }
states: [{ state_id: "review" }]
terminal_outcomes: []
receipts:
  - receipt_id: "approval"
    path: "support/approval.md"
    verdict_field: "decision"
routes:
  - route_id: "approved-route"
    route_type: "extension"
    enter_when:
      receipt_verdict: { receipt_id: "approval", value: "accepted" }
"#,
        );
        fixture.write("packet/manifest.yml", "status: open\n");
        fixture.write(
            "packet/support/approval.md",
            "review_id: custom-1\ndecision: accepted\n",
        );

        let plan = plan_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "custom-lifecycle",
            Path::new("packet"),
        )
        .unwrap();

        assert_eq!(
            plan.receipt_states
                .get("approval")
                .and_then(|receipt| receipt.verdict.as_deref()),
            Some("accepted")
        );
        assert_eq!(
            plan.next_route
                .as_ref()
                .map(|route| route.route_id.as_str()),
            Some("approved-route")
        );
    }

    #[test]
    fn execute_routes_non_mock_consumes_loop_iteration_budget() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("execute-loop-budget");
        fixture.write(
            ".octon/generated/effective/extensions/catalog.effective.yml",
            r#"
schema_version: "test"
packs:
  - pack_id: "test-extension"
    capability_profiles: ["validation-surface", "lifecycle-contract"]
    lifecycle_contracts:
      - lifecycle_id: "proposal-packet"
        projection_source_path: ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml"
"#,
        );
        fixture.write(
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
            r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["in-review"] }
states: [{ state_id: "revise" }]
terminal_outcomes: []
receipts:
  - receipt_id: "proposal-review"
    path: "support/proposal-review.md"
    required_fields: ["review_id", "verdict"]
    verdict_field: "verdict"
loops:
  - loop_id: "proposal-review-revision"
    receipt_id: "proposal-review"
    verdict_field: "verdict"
    repeat_values: ["revision-required"]
    repeat_route_id: "revise-proposal-packet"
    terminal_values: ["accepted", "rejected"]
    max_iterations: 1
routes:
  - route_id: "revise-proposal-packet"
    route_type: "extension"
    enter_when:
      all:
        - receipt_complete: "proposal-review"
        - receipt_verdict: { receipt_id: "proposal-review", value: "revision-required" }
"#,
        );
        fixture.write("packet/proposal.yml", "status: in-review\n");
        fixture.write(
            "packet/support/proposal-review.md",
            "review_id: review-1\nverdict: revision-required\n",
        );
        let options = RunLifecycleOptions {
            lifecycle_id: "proposal-packet".to_string(),
            target: PathBuf::from("packet"),
            run_id: Some("execute-loop".to_string()),
            executor: ExecutorKind::Codex,
            max_iterations: Some(1),
            execute_routes: true,
            max_steps: None,
            timeout_seconds: None,
            max_child_concurrency: None,
            invocation_authority: "unattended".to_string(),
            run_inputs: BTreeMap::new(),
            program_child_filter: None,
        };

        let first = run_lifecycle_from_octon_dir(&fixture.octon_dir, options.clone()).unwrap();
        assert_eq!(first.final_verdict, "route-ready");
        let checkpoint = read_checkpoint_for_run(&fixture.octon_dir, "execute-loop")
            .unwrap()
            .unwrap();
        assert_eq!(
            checkpoint.loop_counts.get("proposal-review-revision"),
            Some(&1)
        );

        let second = run_lifecycle_from_octon_dir(&fixture.octon_dir, options).unwrap();
        assert_eq!(second.final_verdict, "blocked-max-iterations");
    }

    #[test]
    fn lifecycle_discovery_rejects_raw_projection_source_path() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("raw-projection");
        fixture.write(
            ".octon/generated/effective/extensions/catalog.effective.yml",
            r#"
schema_version: "test"
packs:
  - pack_id: "test-extension"
    capability_profiles: ["validation-surface", "lifecycle-contract"]
    lifecycle_contracts:
      - lifecycle_id: "proposal-packet"
        projection_source_path: ".octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
"#,
        );
        fixture.write(
            ".octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml",
            r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["draft"] }
states: [{ state_id: "review" }]
terminal_outcomes: []
receipts: []
routes: []
"#,
        );

        let error = plan_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-packet",
            Path::new("packet"),
        )
        .unwrap_err()
        .to_string();

        assert!(error.contains("must be under .octon/generated/effective/extensions/published/"));
    }

    #[test]
    fn lifecycle_discovery_ignores_empty_contract_arrays_without_profile() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("empty-contract-array");
        fixture.write(
            ".octon/generated/effective/extensions/catalog.effective.yml",
            r#"
schema_version: "test"
packs:
  - pack_id: "empty-extension"
    capability_profiles: ["validation-surface"]
    lifecycle_contracts: []
  - pack_id: "test-extension"
    capability_profiles: ["validation-surface", "lifecycle-contract"]
    lifecycle_contracts:
      - lifecycle_id: "proposal-packet"
        projection_source_path: ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml"
"#,
        );
        fixture.write(
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
            r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["draft"] }
states: [{ state_id: "review" }]
terminal_outcomes: []
receipts: []
routes:
  - route_id: "review-proposal-packet"
    route_type: "extension"
    enter_when:
      manifest_status: "draft"
"#,
        );
        fixture.write("packet/proposal.yml", "status: draft\n");

        let plan = plan_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-packet",
            Path::new("packet"),
        )
        .unwrap();

        assert_eq!(
            plan.next_route
                .as_ref()
                .map(|route| route.route_id.as_str()),
            Some("review-proposal-packet")
        );
    }

    #[test]
    fn lifecycle_discovery_rejects_non_empty_contracts_without_profile() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("contracts-without-profile");
        fixture.write(
            ".octon/generated/effective/extensions/catalog.effective.yml",
            r#"
schema_version: "test"
packs:
  - pack_id: "test-extension"
    capability_profiles: ["validation-surface"]
    lifecycle_contracts:
      - lifecycle_id: "proposal-packet"
        projection_source_path: ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml"
"#,
        );

        let error = plan_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-packet",
            Path::new("packet"),
        )
        .unwrap_err()
        .to_string();

        assert!(error.contains(
            "declares lifecycle contracts without lifecycle-contract capability profile"
        ));
    }

    #[test]
    fn lifecycle_discovery_rejects_missing_contract_projection() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("missing-contract-projection");
        fixture.write(
            ".octon/generated/effective/extensions/catalog.effective.yml",
            r#"
schema_version: "test"
packs:
  - pack_id: "test-extension"
    capability_profiles: ["validation-surface", "lifecycle-contract"]
    lifecycle_contracts:
      - lifecycle_id: "proposal-packet"
        projection_source_path: ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml"
"#,
        );

        let error = plan_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-packet",
            Path::new("packet"),
        )
        .unwrap_err()
        .to_string();

        assert!(error.contains("published lifecycle contract projection missing"));
    }

    #[test]
    fn runtime_rejects_disallowed_validator_command() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("bad-validator-command");
        fixture.write(
            ".octon/generated/effective/extensions/catalog.effective.yml",
            r#"
schema_version: "test"
packs:
  - pack_id: "test-extension"
    capability_profiles: ["validation-surface", "lifecycle-contract"]
    lifecycle_contracts:
      - lifecycle_id: "proposal-packet"
        projection_source_path: ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml"
"#,
        );
        fixture.write(
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
            r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["draft"] }
states: [{ state_id: "review" }]
terminal_outcomes: []
validators:
  - validator_id: "bad-validator"
    argv: ["bash", "/tmp/not-allowed.sh", "--package", "{{target}}"]
gates:
  - gate_id: "bad-gate"
    validator_id: "bad-validator"
    required_before_routes: ["review-route"]
receipts: []
routes:
  - route_id: "review-route"
    route_type: "extension"
    enter_when:
      manifest_status: "draft"
"#,
        );
        fixture.write("packet/proposal.yml", "status: draft\n");

        let error = plan_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-packet",
            Path::new("packet"),
        )
        .unwrap_err()
        .to_string();

        assert!(error.contains("lifecycle command script outside allowed roots"));
    }

    #[test]
    fn runtime_rejects_disallowed_freshness_digest_command() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("bad-digest-command");
        fixture.write(
            ".octon/generated/effective/extensions/catalog.effective.yml",
            r#"
schema_version: "test"
packs:
  - pack_id: "test-extension"
    capability_profiles: ["validation-surface", "lifecycle-contract"]
    lifecycle_contracts:
      - lifecycle_id: "proposal-packet"
        projection_source_path: ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml"
"#,
        );
        fixture.write(
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
            r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["in-review"] }
states: [{ state_id: "review" }]
terminal_outcomes: []
receipts:
  - receipt_id: "proposal-review"
    path: "support/proposal-review.md"
    required_fields: ["review_id", "verdict", "reviewed_packet_digest"]
    verdict_field: "verdict"
    freshness:
      digest_command: ["bash", "/tmp/not-allowed.sh", "--package", "{{target}}", "--print-digest"]
      digest_field: "reviewed_packet_digest"
routes: []
"#,
        );
        fixture.write("packet/proposal.yml", "status: in-review\n");
        fixture.write(
            "packet/support/proposal-review.md",
            "review_id: review-1\nverdict: accepted\nreviewed_packet_digest: sha256:test\n",
        );

        let error = plan_lifecycle_from_octon_dir(
            &fixture.octon_dir,
            "proposal-packet",
            Path::new("packet"),
        )
        .unwrap_err();
        let error_display = error.to_string();
        let error_debug = format!("{error:?}");

        assert!(error_display.contains("failed freshness digest for proposal-review"));
        assert!(error_debug.contains("lifecycle command script outside allowed roots"));
    }
}
