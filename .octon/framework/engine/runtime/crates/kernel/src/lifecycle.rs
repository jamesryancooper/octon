use crate::workflow::ExecutorKind;
use crate::LifecycleCmd;
use anyhow::{bail, Context, Result};
use octon_authority_engine::now_rfc3339;
use octon_core::root::RootResolver;
use octon_lifecycle_executor::{
    default_bound_inputs, LifecycleExecutionPolicy, LifecycleReceiptSpec,
    LifecycleRouteExecutionRequest, LifecycleRouteSpec,
};
use serde::{Deserialize, Serialize};
use serde_yaml::Value;
use sha2::{Digest, Sha256};
use std::collections::BTreeMap;
use std::fs;
use std::path::{Component, Path, PathBuf};
use std::process::Command as ProcessCommand;

const EFFECTIVE_EXTENSION_CATALOG_REL: &str =
    "generated/effective/extensions/catalog.effective.yml";
const GENERATED_EXTENSION_PUBLISHED_PREFIX: &str =
    ".octon/generated/effective/extensions/published/";
const FRAMEWORK_ASSURANCE_SCRIPT_PREFIX: &str = ".octon/framework/assurance/runtime/_ops/scripts/";
const RUNTIME_ROUTE_BUNDLE_REL: &str = "generated/effective/runtime/route-bundle.yml";
const WORKFLOW_EVIDENCE_ROOT_REL: &str = "state/evidence/runs/workflows";
const RUN_CONTROL_ROOT_REL: &str = "state/control/execution/runs";

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
    pub approval_policy: String,
    pub run_inputs: BTreeMap<String, String>,
}

#[derive(Clone, Debug, Serialize)]
pub(crate) struct LifecyclePlanResult {
    pub schema_version: String,
    pub lifecycle_id: String,
    pub owner_extension: String,
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
    pub target: String,
    pub executor: String,
    pub route_execution_mode: String,
    pub bundle_root: String,
    pub checkpoint_path: String,
    pub selected_route: Option<RoutePlanState>,
    pub terminal_outcome: Option<String>,
    pub final_verdict: String,
}

#[derive(Clone, Debug, Deserialize)]
struct LifecycleContract {
    lifecycle_id: String,
    owner_extension: String,
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
    routes: Vec<RouteSpec>,
    #[serde(default)]
    input_bindings: BTreeMap<String, InputBindingSpec>,
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
    idempotency: Option<Value>,
    #[serde(default)]
    approval: Option<RouteApprovalSpec>,
    #[serde(default)]
    completion: Option<RouteCompletionSpec>,
}

#[derive(Clone, Debug, Deserialize)]
struct RouteApprovalSpec {
    #[serde(default)]
    required_by_default: bool,
    reason: Option<String>,
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
    target: String,
    current_state: Option<String>,
    completed_states: Vec<String>,
    last_route: Option<String>,
    #[serde(default)]
    loop_counts: BTreeMap<String, u32>,
    #[serde(default)]
    receipt_digests: BTreeMap<String, String>,
    #[serde(default)]
    last_validator_results: Vec<GatePlanResult>,
    #[serde(default)]
    run_inputs: BTreeMap<String, String>,
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

pub(crate) fn cmd_lifecycle(cmd: LifecycleCmd) -> Result<()> {
    let octon_dir = RootResolver::resolve()?;
    match cmd {
        LifecycleCmd::Plan {
            lifecycle_id,
            target,
        } => {
            let plan = plan_lifecycle_from_octon_dir(&octon_dir, &lifecycle_id, &target)?;
            println!("{}", serde_yaml::to_string(&plan)?);
        }
        LifecycleCmd::Run {
            lifecycle_id,
            target,
            run_id,
            executor,
            max_iterations,
            execute_routes,
            max_steps,
            timeout_seconds,
            approval_policy,
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
                approval_policy,
                run_inputs,
            };
            let result = if options.execute_routes {
                crate::lifecycle_driver::run_lifecycle_execute_from_octon_dir(&octon_dir, options)?
            } else {
                run_lifecycle_from_octon_dir(&octon_dir, options)?
            };
            println!("{}", serde_yaml::to_string(&result)?);
        }
        LifecycleCmd::Resume { run_id } => {
            let result = resume_lifecycle_from_octon_dir(&octon_dir, &run_id)?;
            println!("{}", serde_yaml::to_string(&result)?);
        }
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

pub(crate) fn plan_lifecycle_from_octon_dir(
    octon_dir: &Path,
    lifecycle_id: &str,
    target: &Path,
) -> Result<LifecyclePlanResult> {
    let repo_root = repo_root_for_octon(octon_dir)?;
    let loaded = load_lifecycle_contract(octon_dir, lifecycle_id)?;
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

    Ok(LifecyclePlanResult {
        schema_version: "octon-lifecycle-plan-v1".to_string(),
        lifecycle_id: loaded.contract.lifecycle_id.clone(),
        owner_extension: loaded.contract.owner_extension.clone(),
        contract_path: rel_display(&repo_root, &loaded.path),
        target: rel_display(&repo_root, &target_abs),
        target_exists: target_state.target_exists,
        manifest_status: target_state.manifest_status.clone(),
        receipt_states: receipt_plan_states(&repo_root, &loaded.contract, &target_state),
        terminal_outcome,
        next_route: selected_route.map(route_plan_state),
        gate_results,
        blocked_by_gate,
        checkpoint_drift: None,
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

    let loaded = load_lifecycle_contract(octon_dir, &options.lifecycle_id)?;
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

    let checkpoint = LifecycleCheckpoint {
        schema_version: "octon-lifecycle-checkpoint-v1".to_string(),
        run_id: sanitized_run_id.clone(),
        lifecycle_id: options.lifecycle_id.clone(),
        target: target_rel.clone(),
        current_state: plan
            .next_route
            .as_ref()
            .map(|route| route.route_id.clone())
            .or_else(|| plan.terminal_outcome.clone()),
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
        receipt_digests: receipt_digest_map(&plan),
        last_validator_results: plan.gate_results.clone(),
        run_inputs,
        terminal_outcome: plan.terminal_outcome.clone(),
        final_verdict: final_verdict.clone(),
        resume_instruction: format!("octon lifecycle resume --run-id {}", sanitized_run_id),
    };
    let checkpoint_path = control_root.join("lifecycle-checkpoint.yml");
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

    Ok(LifecycleRunResult {
        schema_version: "octon-lifecycle-run-result-v1".to_string(),
        run_id: sanitized_run_id,
        lifecycle_id: options.lifecycle_id,
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
    let mut plan = plan_lifecycle_from_octon_dir(octon_dir, &checkpoint.lifecycle_id, &target)?;
    let reconstructed = plan
        .next_route
        .as_ref()
        .map(|route| route.route_id.clone())
        .or_else(|| plan.terminal_outcome.clone());
    let checkpoint_drifted = reconstructed != checkpoint.current_state;
    if checkpoint_drifted {
        plan.checkpoint_drift = Some(format!(
            "checkpoint current_state {:?} differed from target-derived state {:?}; target receipts were trusted",
            checkpoint.current_state, reconstructed
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

    let evidence_root = octon_dir
        .join(WORKFLOW_EVIDENCE_ROOT_REL)
        .join(&sanitized_run_id);
    fs::create_dir_all(&evidence_root)?;
    fs::write(
        evidence_root.join("resume-plan.yml"),
        serde_yaml::to_string(&plan)?,
    )?;

    Ok(LifecycleRunResult {
        schema_version: "octon-lifecycle-run-result-v1".to_string(),
        run_id: sanitized_run_id.clone(),
        lifecycle_id: checkpoint.lifecycle_id,
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
        checkpoint_path: rel_display(
            &repo_root,
            &octon_dir
                .join(RUN_CONTROL_ROOT_REL)
                .join(&sanitized_run_id)
                .join("lifecycle-checkpoint.yml"),
        ),
        selected_route: plan.next_route,
        terminal_outcome: plan.terminal_outcome,
        final_verdict: plan.final_verdict,
    })
}

fn load_lifecycle_contract(octon_dir: &Path, lifecycle_id: &str) -> Result<LoadedContract> {
    let path = contract_path_from_effective_catalog(octon_dir, lifecycle_id)?;
    read_lifecycle_contract(&path)
}

fn contract_path_from_effective_catalog(octon_dir: &Path, lifecycle_id: &str) -> Result<PathBuf> {
    let catalog_path = octon_dir.join(EFFECTIVE_EXTENSION_CATALOG_REL);
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
        || !raw.ends_with("/context/lifecycle.contract.yml")
    {
        bail!(
            "published lifecycle contract projection path for {lifecycle_id} must be under {GENERATED_EXTENSION_PUBLISHED_PREFIX} and end with /context/lifecycle.contract.yml: {raw}"
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

fn read_lifecycle_contract(path: &Path) -> Result<LoadedContract> {
    let contract: LifecycleContract = serde_yaml::from_slice(
        &fs::read(path).with_context(|| format!("failed to read {}", path.display()))?,
    )
    .with_context(|| format!("failed to parse lifecycle contract {}", path.display()))?;
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
    route_by_id(contract, route_id)
        .and_then(|route| route.idempotency.as_ref())
        .and_then(|value| value.get("skip_when_target_exists"))
        .and_then(Value::as_bool)
        .unwrap_or(false)
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
                    missing_required_fields: receipt.missing_required_fields.clone(),
                    stale: receipt.stale,
                    stored_digest: receipt.stored_digest.clone(),
                    current_digest: receipt.current_digest.clone(),
                },
            )
        })
        .collect()
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
    approval_policy: &str,
    retry_attempt: u32,
) -> Result<Option<LifecycleRouteExecutionRequest>> {
    let Some(route) = run.selected_route.as_ref() else {
        return Ok(None);
    };
    let repo_root = repo_root_for_octon(octon_dir)?;
    let checkpoint = read_checkpoint_for_run(octon_dir, &run.run_id)?;
    let run_inputs = checkpoint
        .as_ref()
        .map(|checkpoint| checkpoint.run_inputs.clone())
        .unwrap_or_default();
    let loaded = load_lifecycle_contract(octon_dir, &run.lifecycle_id)?;
    let target = resolve_lifecycle_target_path(&repo_root, Path::new(&run.target))?;
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
    let mut bound_inputs = default_bound_inputs(Path::new(&run.target));
    for (name, binding) in &loaded.contract.input_bindings {
        if binding.source == "lifecycle.target" {
            bound_inputs.insert(name.clone(), run.target.clone());
        } else if let Some(input_name) = binding.source.strip_prefix("run.input.") {
            if let Some(value) = run_inputs.get(input_name) {
                bound_inputs.insert(name.clone(), value.clone());
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
    let approval_required_by_default = route_spec
        .approval
        .as_ref()
        .map(|approval| approval.required_by_default)
        .unwrap_or(false);
    let approval_reason = route_spec
        .approval
        .as_ref()
        .and_then(|approval| approval.reason.clone());
    Ok(Some(LifecycleRouteExecutionRequest {
        schema_version: "octon-lifecycle-route-execution-request-v1".to_string(),
        run_id: run.run_id.clone(),
        lifecycle_id: run.lifecycle_id.clone(),
        owner_extension: loaded.contract.owner_extension.clone(),
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
            approval_required_by_default,
            approval_reason,
        },
        effective_extension_catalog: octon_dir.join(EFFECTIVE_EXTENSION_CATALOG_REL),
        runtime_route_bundle: octon_dir.join(RUNTIME_ROUTE_BUNDLE_REL),
        bound_inputs,
        receipts,
        expected_receipts,
        expected_paths,
        expected_manifest_status,
        expected_target_change,
        evidence_root: resolve_repo_path(&repo_root, Path::new(&run.bundle_root)),
        checkpoint_path: resolve_repo_path(&repo_root, Path::new(&run.checkpoint_path)),
        policy: LifecycleExecutionPolicy {
            timeout_seconds,
            cancellation_token: None,
            retry_attempt,
            approval_policy: approval_policy.to_string(),
        },
    }))
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
    let execution_mode = route_execution_mode(
        executor,
        final_verdict,
        plan.next_route.is_some(),
        plan.terminal_outcome.is_some(),
    );
    let handoff_note = route_execution_note(execution_mode);
    format!(
        "# Lifecycle Run\n\nrun_id: {run_id}\nrecorded_at: {}\nlifecycle_id: {}\ntarget: {}\nexecutor: {}\nroute_execution_mode: {execution_mode}\nselected_route: {route}\nterminal_outcome: {terminal}\nfinal_verdict: {final_verdict}\n\n{handoff_note}\n",
        now_rfc3339().unwrap_or_else(|_| "unknown".to_string()),
        plan.lifecycle_id,
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
    let route_execution_result = run
        .selected_route
        .as_ref()
        .map(|route| format!("{}-route-execution.yml", route.route_id))
        .unwrap_or_else(|| "none".to_string());
    format!(
        "# Lifecycle Run\n\nrun_id: {}\nrecorded_at: {}\nlifecycle_id: {}\ntarget: {}\nexecutor: {}\nroute_execution_mode: {}\nselected_route: {}\nterminal_outcome: {}\nfinal_verdict: {}\nadapter_route_status: {}\nroute_execution_result: {}\n\nNote: the lifecycle executor adapter executed the selected route. The runner will re-plan from target receipts and manifest state before selecting any further route.\n",
        run.run_id,
        now_rfc3339().unwrap_or_else(|_| "unknown".to_string()),
        run.lifecycle_id,
        run.target,
        run.executor,
        run.route_execution_mode,
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
    fn terminal_outcome_overrides_matching_route() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("archived");
        fixture.write(
            ".octon/generated/effective/extensions/catalog.effective.yml",
            r#"
schema_version: "test"
packs:
  - pack_id: "test-extension"
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
            approval_policy: "minimize".to_string(),
            run_inputs: BTreeMap::new(),
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
    fn runtime_rejects_disallowed_validator_command() {
        let _guard = crate::acquire_kernel_test_lock();
        let fixture = FixtureRepo::new("bad-validator-command");
        fixture.write(
            ".octon/generated/effective/extensions/catalog.effective.yml",
            r#"
schema_version: "test"
packs:
  - pack_id: "test-extension"
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
