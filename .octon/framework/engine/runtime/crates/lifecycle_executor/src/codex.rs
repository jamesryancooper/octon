use crate::approval::now_rfc3339;
use crate::errors::{LifecycleErrorClass, LifecycleExecutionError};
use crate::request::LifecycleRouteExecutionRequest;
use crate::result::LifecycleRouteExecutionResult;
use crate::{observer, prompt_bundle, workflow_leaf};
use std::fs;
use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};
use std::thread;
use std::time::{Duration, Instant};

pub fn execute_codex(
    repo_root: &Path,
    request: &LifecycleRouteExecutionRequest,
    executor_bin: PathBuf,
) -> Result<LifecycleRouteExecutionResult, LifecycleExecutionError> {
    execute_agent(repo_root, request, "codex", executor_bin)
}

pub fn execute_agent(
    repo_root: &Path,
    request: &LifecycleRouteExecutionRequest,
    executor_name: &str,
    executor_bin: PathBuf,
) -> Result<LifecycleRouteExecutionResult, LifecycleExecutionError> {
    let started_at = now_rfc3339();
    let before = observer::manifest_status(
        &request.target,
        &request.manifest_path,
        &request.status_field,
    )
    .map_err(LifecycleExecutionError::from)?;
    let retry_before_target_digest =
        observer::target_digest(&request.target).map_err(LifecycleExecutionError::from)?;
    let before_target_digest = request
        .expected_target_change
        .then(|| retry_before_target_digest.clone());
    fs::create_dir_all(&request.evidence_root)?;
    let prompt = if request.route.route_type == "workflow" {
        workflow_leaf::render_workflow_leaf_prompt(repo_root, request)?
    } else {
        prompt_bundle::render_extension_prompt(repo_root, request)?
    };
    let prompt_path = request
        .evidence_root
        .join(format!("{}-prompt.md", request.route.route_id));
    let stdout_path = request
        .evidence_root
        .join(format!("{}-stdout.log", request.route.route_id));
    let stderr_path = request
        .evidence_root
        .join(format!("{}-stderr.log", request.route.route_id));
    fs::write(&prompt_path, &prompt)?;

    let output = run_with_timeout(repo_root, &executor_bin, executor_name, &prompt, request)?;
    fs::write(&stdout_path, &output.stdout)?;
    fs::write(&stderr_path, &output.stderr)?;
    let observation = observer::observe_completion(request, before.clone(), before_target_digest)
        .map_err(LifecycleExecutionError::from)?;
    let retry_after_target_digest =
        observer::target_digest(&request.target).map_err(LifecycleExecutionError::from)?;
    let status = if output.timed_out {
        "timed-out"
    } else if output.cancelled {
        "cancelled"
    } else if !output.success {
        "failed"
    } else if observation.completion_observed {
        "completed"
    } else {
        "failed"
    };
    let error_class = if output.timed_out {
        Some(LifecycleErrorClass::Timeout)
    } else if output.cancelled {
        Some(LifecycleErrorClass::Cancelled)
    } else if !output.success {
        Some(LifecycleErrorClass::ExecutorFailed)
    } else if !observation.completion_observed {
        Some(LifecycleErrorClass::CompletionNotObserved)
    } else {
        None
    };
    let retryable = matches!(
        error_class,
        Some(LifecycleErrorClass::ExecutorFailed)
            | Some(LifecycleErrorClass::ExecutorUnavailable)
            | Some(LifecycleErrorClass::Timeout)
    ) && before == observation.manifest_status_after
        && retry_before_target_digest == retry_after_target_digest;
    let mut evidence_paths = vec![
        prompt_path.clone(),
        stdout_path.clone(),
        stderr_path.clone(),
    ];
    let observation_path = request.evidence_root.join(format!(
        "{}-completion-observation.yml",
        request.route.route_id
    ));
    fs::write(
        &observation_path,
        serde_yaml::to_string(&observation).map_err(LifecycleExecutionError::from)?,
    )?;
    evidence_paths.push(observation_path);
    Ok(LifecycleRouteExecutionResult {
        schema_version: "octon-lifecycle-route-execution-result-v1".to_string(),
        run_id: request.run_id.clone(),
        route_id: request.route.route_id.clone(),
        executor_used: executor_name.to_string(),
        status: status.to_string(),
        started_at,
        ended_at: now_rfc3339(),
        manifest_status_before: before,
        manifest_status_after: observation.manifest_status_after,
        receipts_observed: observation.receipts_observed,
        evidence_paths,
        stdout_path: Some(stdout_path),
        stderr_path: Some(stderr_path),
        prompt_packet_path: Some(prompt_path),
        retryable,
        next_action: if status == "completed" {
            "replan".to_string()
        } else {
            "manual-intervention".to_string()
        },
        error_class,
        error_message: if status == "completed" {
            None
        } else {
            Some(format!("executor route status: {status}"))
        },
    })
}

struct AgentOutput {
    success: bool,
    timed_out: bool,
    cancelled: bool,
    stdout: Vec<u8>,
    stderr: Vec<u8>,
}

fn run_with_timeout(
    repo_root: &Path,
    executor_bin: &Path,
    executor_name: &str,
    prompt: &str,
    request: &LifecycleRouteExecutionRequest,
) -> Result<AgentOutput, LifecycleExecutionError> {
    let mut command = build_executor_command(executor_bin, executor_name, repo_root)?;
    let mut child = command.spawn().map_err(|error| {
        LifecycleExecutionError::new(LifecycleErrorClass::ExecutorUnavailable, error.to_string())
    })?;
    if let Some(stdin) = child.stdin.as_mut() {
        stdin.write_all(prompt.as_bytes())?;
    }
    drop(child.stdin.take());
    let start = Instant::now();
    loop {
        if let Some(token) = request.policy.cancellation_token.as_ref() {
            if token.exists() {
                let _ = child.kill();
                let output = child.wait_with_output()?;
                return Ok(AgentOutput {
                    success: false,
                    timed_out: false,
                    cancelled: true,
                    stdout: output.stdout,
                    stderr: output.stderr,
                });
            }
        }
        if let Some(status) = child.try_wait()? {
            let output = child.wait_with_output()?;
            return Ok(AgentOutput {
                success: status.success(),
                timed_out: false,
                cancelled: false,
                stdout: output.stdout,
                stderr: output.stderr,
            });
        }
        if start.elapsed() >= Duration::from_secs(request.policy.timeout_seconds) {
            let _ = child.kill();
            let output = child.wait_with_output()?;
            return Ok(AgentOutput {
                success: false,
                timed_out: true,
                cancelled: false,
                stdout: output.stdout,
                stderr: output.stderr,
            });
        }
        thread::sleep(Duration::from_millis(100));
    }
}

fn build_executor_command(
    executor_bin: &Path,
    executor_name: &str,
    repo_root: &Path,
) -> Result<Command, LifecycleExecutionError> {
    let mut command = Command::new(executor_bin);
    match executor_name {
        "codex" => {
            command
                .arg("exec")
                .arg("--ephemeral")
                .arg("--skip-git-repo-check")
                .arg("--cd")
                .arg(repo_root);
        }
        "claude" => {
            command.arg("-p").arg("--output-format").arg("text");
        }
        other => {
            return Err(LifecycleExecutionError::new(
                LifecycleErrorClass::ExecutorUnavailable,
                format!("unsupported lifecycle executor command: {other}"),
            ));
        }
    }
    command
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .current_dir(repo_root);
    Ok(command)
}
