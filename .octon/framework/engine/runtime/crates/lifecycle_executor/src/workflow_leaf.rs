use crate::generated::resolve_workflow_manifest;
use crate::request::LifecycleRouteExecutionRequest;
use crate::result::{
    LifecycleRouteCompletionObservation, LifecycleRouteExecutionResult, ReceiptObservation,
};
use crate::{authorization::now_rfc3339, observer};
use serde::Serialize;
use serde_yaml::Value;
use std::fs;
use std::fs::File;
use std::path::{Path, PathBuf};
use std::process::{Command, ExitStatus, Stdio};
use std::thread;
use std::time::{Duration, Instant};

const OBSERVATION_INTERVAL: Duration = Duration::from_secs(1);

pub fn render_workflow_leaf_prompt(
    repo_root: &Path,
    request: &LifecycleRouteExecutionRequest,
) -> std::result::Result<String, crate::LifecycleExecutionError> {
    let (manifest_path, manifest) = load_workflow_manifest(repo_root, request)?;
    let mut rendered = format!(
        "# Lifecycle Workflow Leaf Execution\n\nRun workflow `{}` for lifecycle `{}`.\n\n- run_id: `{}`\n- invocation_authority: `{}`\n\nWorkflow contract: `{}`\n\nInputs:\n",
        request.route.route_id,
        request.lifecycle_id,
        request.run_id,
        request.policy.invocation_authority.mode,
        manifest_path.display()
    );
    if let Some(context) = request.human_boundary_context.as_ref() {
        rendered.push_str("- context_kind: `");
        rendered.push_str(&context.context_kind);
        rendered.push_str("`\n");
        if let Some(program_run_id) = context.program_run_id.as_ref() {
            rendered.push_str("- program_run_id: `");
            rendered.push_str(program_run_id);
            rendered.push_str("`\n");
        }
        if let Some(child_id) = context.child_id.as_ref() {
            rendered.push_str("- child_id: `");
            rendered.push_str(child_id);
            rendered.push_str("`\n");
        }
    }
    for (key, value) in &request.bound_inputs {
        rendered.push_str(&format!("- `{key}`: `{value}`\n"));
    }
    if let Some(inputs) = manifest.get("inputs").and_then(Value::as_sequence) {
        rendered.push_str("\nRequired workflow inputs declared by the workflow:\n");
        for input in inputs {
            let name = scalar(input.get("name")).unwrap_or("unknown");
            let required = input
                .get("required")
                .and_then(Value::as_bool)
                .unwrap_or(false);
            rendered.push_str(&format!("- `{name}` required={required}\n"));
        }
    }
    rendered.push_str("\nExecute the workflow leaf route and produce its declared evidence. Do not treat proposal-local receipts as durable runtime authority.\n");
    Ok(rendered)
}

pub fn execute_workflow_leaf(
    repo_root: &Path,
    request: &LifecycleRouteExecutionRequest,
) -> std::result::Result<LifecycleRouteExecutionResult, crate::LifecycleExecutionError> {
    let started_at = now_rfc3339();
    let before = observer::manifest_status(
        &request.target,
        &request.manifest_path,
        &request.status_field,
    )
    .map_err(crate::LifecycleExecutionError::from)?;
    let retry_before_target_digest =
        observer::target_digest(&request.target).map_err(crate::LifecycleExecutionError::from)?;
    let before_target_digest = request
        .expected_target_change
        .then(|| retry_before_target_digest.clone());
    fs::create_dir_all(&request.evidence_root).map_err(crate::LifecycleExecutionError::from)?;

    let attempt_ordinal = workflow_attempt_ordinal(request);
    let evidence_stem = workflow_attempt_evidence_stem(request, attempt_ordinal);
    let workflow_run_id = workflow_run_id(request, attempt_ordinal);
    let invocation_path = request
        .evidence_root
        .join(format!("{evidence_stem}-workflow-invocation.yml"));
    let stdout_path = request
        .evidence_root
        .join(format!("{evidence_stem}-stdout.log"));
    let stderr_path = request
        .evidence_root
        .join(format!("{evidence_stem}-stderr.log"));
    let terminal_path = request
        .evidence_root
        .join(format!("{evidence_stem}-workflow-terminal.yml"));
    let observation_path = request
        .evidence_root
        .join(format!("{evidence_stem}-completion-observation.yml"));

    let dispatch_receipts = observer::observe_receipts(&request.target, &request.receipts)
        .map_err(crate::LifecycleExecutionError::from)?;
    if let Some((blocker_class, reason)) = archive_pre_dispatch_blocker(request, &dispatch_receipts)
    {
        let blocked_at = now_rfc3339();
        let observation =
            observer::observe_completion(request, before.clone(), before_target_digest.clone())
                .map_err(crate::LifecycleExecutionError::from)?;
        fs::write(
            &observation_path,
            serde_yaml::to_string(&observation).map_err(crate::LifecycleExecutionError::from)?,
        )
        .map_err(crate::LifecycleExecutionError::from)?;
        let blocked_path = write_archive_blocked_evidence(
            request,
            &workflow_run_id,
            attempt_ordinal,
            &evidence_stem,
            blocker_class,
            reason,
            &observation,
            dispatch_receipts.clone(),
            vec![observation_path.clone()],
            "manual-intervention",
        )?;
        return Ok(LifecycleRouteExecutionResult {
            schema_version: "octon-lifecycle-route-execution-result-v1".to_string(),
            run_id: request.run_id.clone(),
            route_id: request.route.route_id.clone(),
            phase_id: request.phase_id.clone(),
            executor_used: "workflow-leaf".to_string(),
            status: "blocked".to_string(),
            started_at,
            ended_at: blocked_at,
            manifest_status_before: before,
            manifest_status_after: observation.manifest_status_after,
            receipts_observed: observation.receipts_observed,
            evidence_paths: vec![observation_path, blocked_path],
            stdout_path: None,
            stderr_path: None,
            prompt_packet_path: None,
            retryable: false,
            next_action: "manual-intervention".to_string(),
            error_class: Some(crate::LifecycleErrorClass::ReceiptInvalid),
            error_message: Some(
                "archive workflow dispatch blocked by non-authorizing archive receipt state"
                    .to_string(),
            ),
        });
    }

    let existing_state_paths = existing_workflow_run_state_paths(repo_root, &workflow_run_id);
    if !existing_state_paths.is_empty() {
        let denied_path = request
            .evidence_root
            .join(format!("{evidence_stem}-workflow-resume-denied.yml"));
        let denied_at = now_rfc3339();
        let evidence = WorkflowResumeDeniedEvidence {
            schema_version: "octon-lifecycle-workflow-leaf-resume-denied-v1",
            run_id: &request.run_id,
            route_id: &request.route.route_id,
            retry_attempt: request.policy.retry_attempt,
            attempt_ordinal,
            workflow_run_id: &workflow_run_id,
            status: "failed",
            resume_decision: "denied",
            replay_safe_proof: "absent",
            reason: "workflow run id already has canonical execution artifacts; same-input, same-authority, same-target replay-safe resume proof was not provided",
            existing_state_paths: existing_state_paths
                .iter()
                .map(|path| path.display().to_string())
                .collect(),
            target: request.target.display().to_string(),
            bound_inputs: &request.bound_inputs,
            invocation_authority: &request.policy.invocation_authority.mode,
            human_boundary_context: workflow_context_evidence(request),
            recorded_at: denied_at.clone(),
        };
        fs::write(
            &denied_path,
            serde_yaml::to_string(&evidence).map_err(crate::LifecycleExecutionError::from)?,
        )
        .map_err(crate::LifecycleExecutionError::from)?;
        let observation =
            observer::observe_completion(request, before.clone(), before_target_digest.clone())
                .map_err(crate::LifecycleExecutionError::from)?;
        fs::write(
            &observation_path,
            serde_yaml::to_string(&observation).map_err(crate::LifecycleExecutionError::from)?,
        )
        .map_err(crate::LifecycleExecutionError::from)?;
        let mut evidence_paths = vec![denied_path, observation_path.clone()];
        if archive_route_requires_blocked_evidence(request) {
            let blocked_path = write_archive_blocked_evidence(
                request,
                &workflow_run_id,
                attempt_ordinal,
                &evidence_stem,
                "duplicate-workflow-run-id",
                format!(
                    "workflow run id {workflow_run_id} already has canonical execution artifacts and replay-safe resume proof is absent"
                ),
                &observation,
                observation.receipts_observed.clone(),
                evidence_paths.clone(),
                "manual-intervention",
            )?;
            evidence_paths.push(blocked_path);
        }
        return Ok(LifecycleRouteExecutionResult {
            schema_version: "octon-lifecycle-route-execution-result-v1".to_string(),
            run_id: request.run_id.clone(),
            route_id: request.route.route_id.clone(),
            phase_id: request.phase_id.clone(),
            executor_used: "workflow-leaf".to_string(),
            status: "failed".to_string(),
            started_at,
            ended_at: denied_at,
            manifest_status_before: before,
            manifest_status_after: observation.manifest_status_after,
            receipts_observed: observation.receipts_observed,
            evidence_paths,
            stdout_path: None,
            stderr_path: None,
            prompt_packet_path: None,
            retryable: true,
            next_action: "manual-intervention".to_string(),
            error_class: Some(crate::LifecycleErrorClass::ExecutorFailed),
            error_message: Some(format!(
                "workflow run id {workflow_run_id} already exists and replay-safe resume proof is absent"
            )),
        });
    }

    let executable = workflow_executable(repo_root);
    let mut argv = vec![
        "workflow".to_string(),
        "run".to_string(),
        request.route.route_id.clone(),
        "--run-id".to_string(),
        workflow_run_id.clone(),
        "--executor".to_string(),
        request.executor.clone(),
    ];
    for (key, value) in &request.bound_inputs {
        argv.push("--set".to_string());
        argv.push(format!("{key}={value}"));
    }
    let invocation = WorkflowInvocationEvidence {
        schema_version: "octon-lifecycle-workflow-leaf-invocation-v1",
        run_id: &request.run_id,
        route_id: &request.route.route_id,
        retry_attempt: request.policy.retry_attempt,
        attempt_ordinal,
        workflow_run_id: &workflow_run_id,
        executable: executable.display().to_string(),
        argv: &argv,
        target: request.target.display().to_string(),
        bound_inputs: &request.bound_inputs,
        invocation_authority: &request.policy.invocation_authority.mode,
        human_boundary_context: workflow_context_evidence(request),
        started_at: &started_at,
    };
    fs::write(
        &invocation_path,
        serde_yaml::to_string(&invocation).map_err(crate::LifecycleExecutionError::from)?,
    )
    .map_err(crate::LifecycleExecutionError::from)?;

    let output = run_workflow_command(
        repo_root,
        &executable,
        &argv,
        request,
        &stdout_path,
        &stderr_path,
    )?;
    let terminal = WorkflowTerminalEvidence {
        schema_version: "octon-lifecycle-workflow-leaf-terminal-v1",
        run_id: &request.run_id,
        route_id: &request.route.route_id,
        retry_attempt: request.policy.retry_attempt,
        attempt_ordinal,
        workflow_run_id: &workflow_run_id,
        success: output.success,
        timed_out: output.timed_out,
        cancelled: output.cancelled,
        exit_code: output
            .status
            .as_ref()
            .and_then(ExitStatus::code)
            .map(|code| code.to_string())
            .unwrap_or_else(|| "none".to_string()),
        human_boundary_context: workflow_context_evidence(request),
        ended_at: now_rfc3339(),
    };
    fs::write(
        &terminal_path,
        serde_yaml::to_string(&terminal).map_err(crate::LifecycleExecutionError::from)?,
    )
    .map_err(crate::LifecycleExecutionError::from)?;
    let observation = observer::observe_completion(request, before.clone(), before_target_digest)
        .map_err(crate::LifecycleExecutionError::from)?;
    let retry_after_target_digest =
        observer::target_digest(&request.target).map_err(crate::LifecycleExecutionError::from)?;
    let (status, error_class, error_message) =
        workflow_route_status(&output, observation.completion_observed);
    let retryable = matches!(
        &error_class,
        Some(crate::LifecycleErrorClass::ExecutorFailed)
            | Some(crate::LifecycleErrorClass::ExecutorUnavailable)
            | Some(crate::LifecycleErrorClass::Timeout)
    ) && before == observation.manifest_status_after
        && retry_before_target_digest == retry_after_target_digest;
    fs::write(
        &observation_path,
        serde_yaml::to_string(&observation).map_err(crate::LifecycleExecutionError::from)?,
    )
    .map_err(crate::LifecycleExecutionError::from)?;
    let mut evidence_paths = vec![
        invocation_path,
        stdout_path.clone(),
        stderr_path.clone(),
        terminal_path,
        observation_path.clone(),
    ];
    if let Some((blocker_class, reason, next_action)) =
        archive_post_execution_blocker(request, &output, &observation)
    {
        let blocked_path = write_archive_blocked_evidence(
            request,
            &workflow_run_id,
            attempt_ordinal,
            &evidence_stem,
            blocker_class,
            reason,
            &observation,
            observation.receipts_observed.clone(),
            evidence_paths.clone(),
            next_action,
        )?;
        evidence_paths.push(blocked_path);
    }
    Ok(LifecycleRouteExecutionResult {
        schema_version: "octon-lifecycle-route-execution-result-v1".to_string(),
        run_id: request.run_id.clone(),
        route_id: request.route.route_id.clone(),
        phase_id: request.phase_id.clone(),
        executor_used: "workflow-leaf".to_string(),
        status: status.to_string(),
        started_at,
        ended_at: now_rfc3339(),
        manifest_status_before: before,
        manifest_status_after: observation.manifest_status_after,
        receipts_observed: observation.receipts_observed,
        evidence_paths,
        stdout_path: Some(stdout_path),
        stderr_path: Some(stderr_path),
        prompt_packet_path: None,
        retryable,
        next_action: if status == "completed" {
            "replan".to_string()
        } else {
            "manual-intervention".to_string()
        },
        error_class,
        error_message,
    })
}

pub fn required_workflow_inputs(
    repo_root: &Path,
    request: &LifecycleRouteExecutionRequest,
) -> std::result::Result<Vec<String>, crate::LifecycleExecutionError> {
    let (_, manifest) = load_workflow_manifest(repo_root, request)?;
    Ok(manifest
        .get("inputs")
        .and_then(Value::as_sequence)
        .into_iter()
        .flatten()
        .filter(|input| {
            input
                .get("required")
                .and_then(Value::as_bool)
                .unwrap_or(false)
        })
        .filter_map(|input| scalar(input.get("name")).map(str::to_string))
        .collect())
}

fn load_workflow_manifest(
    repo_root: &Path,
    request: &LifecycleRouteExecutionRequest,
) -> std::result::Result<(std::path::PathBuf, Value), crate::LifecycleExecutionError> {
    let manifest_path = resolve_workflow_manifest(
        repo_root,
        &request.runtime_route_bundle,
        &request.route.route_id,
    )?;
    let manifest: Value = serde_yaml::from_slice(&fs::read(&manifest_path).map_err(|error| {
        crate::LifecycleExecutionError::new(
            crate::LifecycleErrorClass::Discovery,
            error.to_string(),
        )
    })?)
    .map_err(|error| {
        crate::LifecycleExecutionError::new(
            crate::LifecycleErrorClass::Discovery,
            error.to_string(),
        )
    })?;
    Ok((manifest_path, manifest))
}

struct WorkflowCommandOutput {
    success: bool,
    timed_out: bool,
    cancelled: bool,
    status: Option<ExitStatus>,
}

fn run_workflow_command(
    repo_root: &Path,
    executable: &Path,
    argv: &[String],
    request: &LifecycleRouteExecutionRequest,
    stdout_path: &Path,
    stderr_path: &Path,
) -> std::result::Result<WorkflowCommandOutput, crate::LifecycleExecutionError> {
    let stdout = File::create(stdout_path).map_err(crate::LifecycleExecutionError::from)?;
    let stderr = File::create(stderr_path).map_err(crate::LifecycleExecutionError::from)?;
    let mut command = Command::new(executable);
    command
        .args(argv)
        .current_dir(repo_root)
        .env("OCTON_WORKFLOW_RUN_COMPAT", "1")
        .stdout(Stdio::from(stdout))
        .stderr(Stdio::from(stderr));
    let mut child = command.spawn().map_err(|error| {
        crate::LifecycleExecutionError::new(
            crate::LifecycleErrorClass::ExecutorUnavailable,
            format!("failed to start workflow leaf executor: {error}"),
        )
    })?;
    let started = Instant::now();
    loop {
        if let Some(status) = child
            .try_wait()
            .map_err(crate::LifecycleExecutionError::from)?
        {
            return Ok(WorkflowCommandOutput {
                success: status.success(),
                timed_out: false,
                cancelled: false,
                status: Some(status),
            });
        }
        if request
            .policy
            .cancellation_token
            .as_ref()
            .map(|token| token.exists())
            .unwrap_or(false)
        {
            let _ = child.kill();
            let _ = child.wait();
            return Ok(WorkflowCommandOutput {
                success: false,
                timed_out: false,
                cancelled: true,
                status: None,
            });
        }
        if started.elapsed() >= Duration::from_secs(request.policy.timeout_seconds) {
            let _ = child.kill();
            let _ = child.wait();
            return Ok(WorkflowCommandOutput {
                success: false,
                timed_out: true,
                cancelled: false,
                status: None,
            });
        }
        thread::sleep(OBSERVATION_INTERVAL);
    }
}

#[derive(Serialize)]
struct WorkflowInvocationEvidence<'a> {
    schema_version: &'static str,
    run_id: &'a str,
    route_id: &'a str,
    retry_attempt: u32,
    attempt_ordinal: u32,
    workflow_run_id: &'a str,
    executable: String,
    argv: &'a [String],
    target: String,
    bound_inputs: &'a std::collections::BTreeMap<String, String>,
    invocation_authority: &'a str,
    #[serde(skip_serializing_if = "Option::is_none")]
    human_boundary_context: Option<WorkflowContextEvidence<'a>>,
    started_at: &'a str,
}

#[derive(Serialize)]
struct WorkflowTerminalEvidence<'a> {
    schema_version: &'static str,
    run_id: &'a str,
    route_id: &'a str,
    retry_attempt: u32,
    attempt_ordinal: u32,
    workflow_run_id: &'a str,
    success: bool,
    timed_out: bool,
    cancelled: bool,
    exit_code: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    human_boundary_context: Option<WorkflowContextEvidence<'a>>,
    ended_at: String,
}

#[derive(Serialize)]
struct WorkflowResumeDeniedEvidence<'a> {
    schema_version: &'static str,
    run_id: &'a str,
    route_id: &'a str,
    retry_attempt: u32,
    attempt_ordinal: u32,
    workflow_run_id: &'a str,
    status: &'static str,
    resume_decision: &'static str,
    replay_safe_proof: &'static str,
    reason: &'static str,
    existing_state_paths: Vec<String>,
    target: String,
    bound_inputs: &'a std::collections::BTreeMap<String, String>,
    invocation_authority: &'a str,
    #[serde(skip_serializing_if = "Option::is_none")]
    human_boundary_context: Option<WorkflowContextEvidence<'a>>,
    recorded_at: String,
}

#[derive(Serialize)]
struct ArchiveBlockedEvidence {
    schema_version: &'static str,
    run_id: String,
    route_id: String,
    workflow_run_id: String,
    attempt_ordinal: u32,
    blocker_class: String,
    reason: String,
    target: String,
    observation_target: String,
    completion_observed: bool,
    receipt_summaries: Vec<ReceiptObservation>,
    next_action: String,
    authority_boundary: &'static str,
    source_evidence_paths: Vec<String>,
    recorded_at: String,
}

#[derive(Serialize)]
struct WorkflowContextEvidence<'a> {
    context_kind: &'a str,
    #[serde(skip_serializing_if = "Option::is_none")]
    program_run_id: Option<&'a str>,
    #[serde(skip_serializing_if = "Option::is_none")]
    child_id: Option<&'a str>,
    #[serde(skip_serializing_if = "Option::is_none")]
    human_exception_instruction: Option<&'a str>,
    #[serde(skip_serializing_if = "Option::is_none")]
    retry_instruction: Option<&'a str>,
}

fn workflow_context_evidence(
    request: &LifecycleRouteExecutionRequest,
) -> Option<WorkflowContextEvidence<'_>> {
    request
        .human_boundary_context
        .as_ref()
        .map(|context| WorkflowContextEvidence {
            context_kind: &context.context_kind,
            program_run_id: context.program_run_id.as_deref(),
            child_id: context.child_id.as_deref(),
            human_exception_instruction: context.human_exception_instruction.as_deref(),
            retry_instruction: context.retry_instruction.as_deref(),
        })
}

fn workflow_attempt_ordinal(request: &LifecycleRouteExecutionRequest) -> u32 {
    request.policy.retry_attempt.saturating_add(1)
}

fn workflow_attempt_evidence_stem(
    request: &LifecycleRouteExecutionRequest,
    attempt_ordinal: u32,
) -> String {
    format!("{}-attempt-{attempt_ordinal}", request.route.route_id)
}

fn workflow_run_id(request: &LifecycleRouteExecutionRequest, attempt_ordinal: u32) -> String {
    format!("{}-attempt-{attempt_ordinal}-workflow", request.run_id)
}

fn existing_workflow_run_state_paths(repo_root: &Path, workflow_run_id: &str) -> Vec<PathBuf> {
    let octon_dir = repo_root.join(".octon");
    [
        octon_dir
            .join("state/control/execution/runs")
            .join(workflow_run_id),
        octon_dir.join("state/evidence/runs").join(workflow_run_id),
        octon_dir
            .join("state/evidence/runs/workflows")
            .join(workflow_run_id),
        octon_dir
            .join("state/continuity/runs")
            .join(workflow_run_id),
        octon_dir
            .join("state/control/execution/approvals/requests")
            .join(format!("{workflow_run_id}.yml")),
        octon_dir
            .join("state/control/execution/approvals/grants")
            .join(format!("grant-{workflow_run_id}.yml")),
        octon_dir
            .join("state/evidence/control/execution")
            .join(format!("authority-decision-{workflow_run_id}.yml")),
        octon_dir
            .join("state/evidence/control/execution")
            .join(format!("authority-grant-bundle-{workflow_run_id}.yml")),
    ]
    .into_iter()
    .filter(|path| path.exists())
    .collect()
}

fn archive_route_requires_blocked_evidence(request: &LifecycleRouteExecutionRequest) -> bool {
    request.route.route_id == "archive-proposal"
        && request.expected_manifest_status.as_deref() == Some("archived")
}

fn archive_pre_dispatch_blocker(
    request: &LifecycleRouteExecutionRequest,
    receipts: &[ReceiptObservation],
) -> Option<(&'static str, String)> {
    if !archive_route_requires_blocked_evidence(request) {
        return None;
    }
    let required = request
        .route
        .delegation_contract
        .as_ref()
        .map(|contract| contract.required_receipts_before_dispatch.as_slice())
        .unwrap_or(&[]);
    for receipt_id in required {
        let Some(receipt) = receipts
            .iter()
            .find(|receipt| &receipt.receipt_id == receipt_id)
        else {
            return Some((
                "archive-authorization-missing",
                format!("required archive dispatch receipt {receipt_id} was not observed"),
            ));
        };
        if !receipt.exists {
            return Some((
                "archive-authorization-missing",
                format!("required archive dispatch receipt {receipt_id} does not exist"),
            ));
        }
        if !receipt.missing_required_fields.is_empty() {
            return Some((
                "archive-authorization-incomplete",
                format!(
                    "required archive dispatch receipt {receipt_id} is missing required fields: {}",
                    receipt.missing_required_fields.join(",")
                ),
            ));
        }
        if receipt
            .verdict
            .as_deref()
            .is_some_and(|verdict| verdict != "pass")
        {
            return Some((
                "archive-authorization-non-authorizing",
                format!("required archive dispatch receipt {receipt_id} verdict is not pass"),
            ));
        }
        if receipt.fields.contains_key("archive_authorized")
            && receipt.fields.get("archive_authorized").map(String::as_str) != Some("yes")
        {
            return Some((
                "archive-authorization-non-authorizing",
                format!(
                    "required archive dispatch receipt {receipt_id} does not authorize archive"
                ),
            ));
        }
    }
    None
}

fn archive_post_execution_blocker(
    request: &LifecycleRouteExecutionRequest,
    output: &WorkflowCommandOutput,
    observation: &LifecycleRouteCompletionObservation,
) -> Option<(&'static str, String, &'static str)> {
    if !archive_route_requires_blocked_evidence(request) || observation.completion_observed {
        return None;
    }
    if output.cancelled {
        return Some((
            "archive-workflow-cancelled",
            "archive workflow execution was cancelled before archive completion was observed"
                .to_string(),
            "manual-intervention",
        ));
    }
    if output.timed_out {
        return Some((
            "archive-workflow-timeout",
            "archive workflow execution timed out before archive completion was observed"
                .to_string(),
            "manual-intervention",
        ));
    }
    if output.success {
        return Some((
            "archive-completion-not-observed",
            "archive workflow exited successfully but archived target completion was not observed"
                .to_string(),
            "manual-intervention",
        ));
    }
    Some((
        "archive-workflow-failed",
        "archive workflow executor exited with non-zero status before archive completion was observed"
            .to_string(),
        "manual-intervention",
    ))
}

fn write_archive_blocked_evidence(
    request: &LifecycleRouteExecutionRequest,
    workflow_run_id: &str,
    attempt_ordinal: u32,
    evidence_stem: &str,
    blocker_class: &str,
    reason: String,
    observation: &LifecycleRouteCompletionObservation,
    receipt_summaries: Vec<ReceiptObservation>,
    source_evidence_paths: Vec<PathBuf>,
    next_action: &str,
) -> std::result::Result<PathBuf, crate::LifecycleExecutionError> {
    let path = request
        .evidence_root
        .join(format!("{evidence_stem}-archive-blocked.yml"));
    let evidence = ArchiveBlockedEvidence {
        schema_version: "octon-lifecycle-archive-blocked-evidence-v1",
        run_id: request.run_id.clone(),
        route_id: request.route.route_id.clone(),
        workflow_run_id: workflow_run_id.to_string(),
        attempt_ordinal,
        blocker_class: blocker_class.to_string(),
        reason,
        target: request.target.display().to_string(),
        observation_target: observation.observation_target.display().to_string(),
        completion_observed: observation.completion_observed,
        receipt_summaries,
        next_action: next_action.to_string(),
        authority_boundary: "archive mutation remains workflow-owned; lifecycle executor records observation and fail-closed blocked evidence only",
        source_evidence_paths: source_evidence_paths
            .iter()
            .map(|path| path.display().to_string())
            .collect(),
        recorded_at: now_rfc3339(),
    };
    fs::write(
        &path,
        serde_yaml::to_string(&evidence).map_err(crate::LifecycleExecutionError::from)?,
    )
    .map_err(crate::LifecycleExecutionError::from)?;
    Ok(path)
}

fn workflow_route_status(
    output: &WorkflowCommandOutput,
    completion_observed: bool,
) -> (
    &'static str,
    Option<crate::LifecycleErrorClass>,
    Option<String>,
) {
    if output.cancelled {
        return (
            "cancelled",
            Some(crate::LifecycleErrorClass::Cancelled),
            Some("workflow leaf execution was cancelled".to_string()),
        );
    }
    if output.timed_out {
        return (
            "timed-out",
            Some(crate::LifecycleErrorClass::Timeout),
            Some("workflow leaf execution timed out".to_string()),
        );
    }
    if output.success && completion_observed {
        return ("completed", None, None);
    }
    if output.success {
        return (
            "failed",
            Some(crate::LifecycleErrorClass::CompletionNotObserved),
            Some("workflow leaf exited successfully but completion was not observed".to_string()),
        );
    }
    (
        "failed",
        Some(crate::LifecycleErrorClass::ExecutorFailed),
        Some("workflow leaf executor exited with non-zero status".to_string()),
    )
}

fn workflow_executable(repo_root: &Path) -> std::path::PathBuf {
    if let Ok(executable) = std::env::current_exe() {
        if executable
            .file_name()
            .and_then(|name| name.to_str())
            .map(|name| name == "octon" || name.starts_with("octon-"))
            .unwrap_or(false)
        {
            return executable;
        }
    }
    repo_root.join(".octon/framework/engine/runtime/run")
}

fn scalar(value: Option<&Value>) -> Option<&str> {
    value.and_then(|value| match value {
        Value::String(raw) => Some(raw.as_str()),
        _ => None,
    })
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::request::{
        LifecycleDelegationContract, LifecycleExecutionPolicy, LifecycleInvocationAuthority,
        LifecycleReceiptSpec, LifecycleRouteSpec,
    };
    use std::collections::BTreeMap;
    use std::time::{SystemTime, UNIX_EPOCH};

    fn temp_root(name: &str) -> PathBuf {
        let nanos = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap()
            .as_nanos();
        let root = std::env::temp_dir().join(format!(
            "octon-workflow-leaf-{name}-{}-{nanos}",
            std::process::id()
        ));
        fs::create_dir_all(&root).unwrap();
        root
    }

    fn archive_request(root: &Path) -> LifecycleRouteExecutionRequest {
        let target = root.join(".octon/inputs/exploratory/proposals/architecture/fixture");
        fs::create_dir_all(&target).unwrap();
        fs::write(target.join("proposal.yml"), "status: implemented\n").unwrap();
        LifecycleRouteExecutionRequest {
            schema_version: "octon-lifecycle-route-execution-request-v1".to_string(),
            run_id: "test-run".to_string(),
            lifecycle_id: "proposal-packet".to_string(),
            owner_extension: "test-extension".to_string(),
            phase_id: Some("archive".to_string()),
            target: target.clone(),
            manifest_path: "proposal.yml".to_string(),
            status_field: "status".to_string(),
            executor: "codex".to_string(),
            route: LifecycleRouteSpec {
                route_id: "archive-proposal".to_string(),
                route_type: "workflow".to_string(),
                command_id: None,
                skill_id: None,
                prompt_set_id: None,
                required_inputs: Vec::new(),
                completion_replan_required: true,
                delegation_contract: Some(LifecycleDelegationContract {
                    decision_class: "delegated-execution".to_string(),
                    safe_delegation: true,
                    authority_zones_allowed: vec!["workspace-declared".to_string()],
                    declared_write_scope_source: "target".to_string(),
                    required_evidence_gates: Vec::new(),
                    required_receipts_before_dispatch: vec!["proposal-closeout".to_string()],
                    required_receipts_before_completion: Vec::new(),
                    replay_class: "no-op-safe".to_string(),
                    automated_recovery_policy: "fail-closed".to_string(),
                    human_only_boundaries: vec!["stale-evidence-acceptance".to_string()],
                }),
            },
            effective_extension_catalog: root
                .join(".octon/generated/effective/extensions/catalog.effective.yml"),
            runtime_route_bundle: root.join(".octon/generated/effective/runtime/route-bundle.yml"),
            bound_inputs: BTreeMap::from([
                ("proposal_path".to_string(), target.display().to_string()),
                ("disposition".to_string(), "implemented".to_string()),
            ]),
            receipts: vec![LifecycleReceiptSpec {
                receipt_id: "proposal-closeout".to_string(),
                path: "support/proposal-closeout.md".to_string(),
                required_fields: vec!["verdict".to_string(), "archive_authorized".to_string()],
                verdict_field: Some("verdict".to_string()),
            }],
            expected_receipts: Vec::new(),
            expected_paths: Vec::new(),
            expected_manifest_status: Some("archived".to_string()),
            expected_target_change: false,
            evidence_root: root.join(".octon/state/evidence/runs/workflows/test-run"),
            checkpoint_path: root
                .join(".octon/state/control/execution/runs/test-run/lifecycle-checkpoint.yml"),
            interaction_request_refs: Vec::new(),
            interaction_return_refs: Vec::new(),
            policy: LifecycleExecutionPolicy {
                timeout_seconds: 30,
                cancellation_token: None,
                retry_attempt: 0,
                invocation_authority: LifecycleInvocationAuthority {
                    mode: "unattended".to_string(),
                    provenance: "test".to_string(),
                    authority_ref: None,
                },
            },
            human_boundary_context: None,
            evidence_gate_results: BTreeMap::new(),
        }
    }

    #[test]
    fn archive_missing_authorization_writes_blocked_evidence_before_dispatch() {
        let root = temp_root("missing-archive-authorization");
        let request = archive_request(&root);

        let result = execute_workflow_leaf(&root, &request).unwrap();

        assert_eq!(result.status, "blocked");
        assert!(!root.join(".octon/framework/engine/runtime/run").exists());
        let blocked = fs::read_to_string(
            request
                .evidence_root
                .join("archive-proposal-attempt-1-archive-blocked.yml"),
        )
        .unwrap();
        assert!(blocked.contains("schema_version: octon-lifecycle-archive-blocked-evidence-v1"));
        assert!(blocked.contains("blocker_class: archive-authorization-missing"));
        assert!(blocked.contains("completion_observed: false"));
    }
}
