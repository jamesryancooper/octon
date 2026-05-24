use crate::generated::resolve_workflow_manifest;
use crate::request::LifecycleRouteExecutionRequest;
use crate::result::LifecycleRouteExecutionResult;
use crate::{authorization::now_rfc3339, observer};
use serde_yaml::Value;
use std::fs;
use std::fs::File;
use std::path::Path;
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

    let invocation_path = request.evidence_root.join(format!(
        "{}-workflow-invocation.yml",
        request.route.route_id
    ));
    let stdout_path = request
        .evidence_root
        .join(format!("{}-stdout.log", request.route.route_id));
    let stderr_path = request
        .evidence_root
        .join(format!("{}-stderr.log", request.route.route_id));
    let terminal_path = request
        .evidence_root
        .join(format!("{}-workflow-terminal.yml", request.route.route_id));
    let workflow_run_id = format!("{}-workflow", request.run_id);
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
    fs::write(
        &invocation_path,
        format!(
            "schema_version: octon-lifecycle-workflow-leaf-invocation-v1\nrun_id: {}\nroute_id: {}\nworkflow_run_id: {}\nexecutable: {}\nargv:\n{}\nstarted_at: {}\n",
            request.run_id,
            request.route.route_id,
            workflow_run_id,
            executable.display(),
            argv.iter()
                .map(|arg| format!("  - {}", yaml_string(arg)))
                .collect::<Vec<_>>()
                .join("\n"),
            started_at
        ),
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
    fs::write(
        &terminal_path,
        format!(
            "schema_version: octon-lifecycle-workflow-leaf-terminal-v1\nrun_id: {}\nroute_id: {}\nworkflow_run_id: {}\nsuccess: {}\ntimed_out: {}\ncancelled: {}\nexit_code: {}\nended_at: {}\n",
            request.run_id,
            request.route.route_id,
            workflow_run_id,
            output.success,
            output.timed_out,
            output.cancelled,
            output
                .status
                .as_ref()
                .and_then(ExitStatus::code)
                .map(|code| code.to_string())
                .unwrap_or_else(|| "none".to_string()),
            now_rfc3339()
        ),
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
    let observation_path = request.evidence_root.join(format!(
        "{}-completion-observation.yml",
        request.route.route_id
    ));
    fs::write(
        &observation_path,
        serde_yaml::to_string(&observation).map_err(crate::LifecycleExecutionError::from)?,
    )
    .map_err(crate::LifecycleExecutionError::from)?;
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
        evidence_paths: vec![
            invocation_path,
            stdout_path.clone(),
            stderr_path.clone(),
            terminal_path,
            observation_path,
        ],
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

fn yaml_string(value: &str) -> String {
    serde_yaml::to_string(value)
        .map(|value| value.trim().to_string())
        .unwrap_or_else(|_| format!("{value:?}"))
}

fn scalar(value: Option<&Value>) -> Option<&str> {
    value.and_then(|value| match value {
        Value::String(raw) => Some(raw.as_str()),
        _ => None,
    })
}
