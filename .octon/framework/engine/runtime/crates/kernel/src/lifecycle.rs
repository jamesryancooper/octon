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
use std::collections::BTreeMap;
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
    let mut event_data = BTreeMap::new();
    event_data.insert("final_verdict".to_string(), final_verdict.clone());
    if let Some(route) = plan.next_route.as_ref() {
        event_data.insert("selected_route".to_string(), route.route_id.clone());
    }
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
    for route in &contract.routes {
        let matches = match route.enter_when.as_ref() {
            Some(condition) => eval_condition(condition, contract, target_state)?,
            None => false,
        };
        if matches {
            return Ok(Some(route.clone()));
        }
    }
    Ok(None)
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
                .map(|item| eval_condition(item, contract, target_state))
                .collect::<Result<Vec<_>>>()?
                .into_iter()
                .all(|item| item),
            "any" => value
                .as_sequence()
                .context("any condition must be a sequence")?
                .iter()
                .map(|item| eval_condition(item, contract, target_state))
                .collect::<Result<Vec<_>>>()?
                .into_iter()
                .any(|item| item),
            "target_missing" => value.as_bool().unwrap_or(false) == !target_state.target_exists,
            "manifest_status" => scalar_str(Some(value)) == target_state.manifest_status.as_deref(),
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
    let evidence_gate_results = route_spec
        .delegation_contract
        .as_ref()
        .map(|contract| {
            contract
                .required_evidence_gates
                .iter()
                .map(|gate| (gate.clone(), "pass".to_string()))
                .collect::<BTreeMap<_, _>>()
        })
        .unwrap_or_default();
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
    let mut fields = BTreeMap::new();
    let content = fs::read_to_string(path)?;
    for line in content.lines() {
        let trimmed = line.trim();
        if trimmed.is_empty() || trimmed.starts_with('#') {
            continue;
        }
        if let Some((key, value)) = trimmed.split_once(':') {
            let key = key.trim();
            if is_receipt_key(key) {
                fields.insert(key.to_string(), clean_scalar(value.trim()));
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
    }
    Ok(fields)
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
