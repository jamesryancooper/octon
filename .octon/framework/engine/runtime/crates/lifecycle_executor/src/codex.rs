use crate::approval::now_rfc3339;
use crate::errors::{LifecycleErrorClass, LifecycleExecutionError};
use crate::request::LifecycleRouteExecutionRequest;
use crate::result::LifecycleRouteExecutionResult;
use crate::{observer, prompt_bundle, workflow_leaf};
use std::fs;
use std::fs::File;
use std::fs::OpenOptions;
use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::{Child, Command, ExitStatus, Stdio};
use std::thread;
use std::time::{Duration, Instant, SystemTime, UNIX_EPOCH};

#[cfg(unix)]
use std::os::unix::process::CommandExt;

const TERMINATION_GRACE: Duration = Duration::from_secs(2);
const FORCE_KILL_GRACE: Duration = Duration::from_secs(2);
const OBSERVATION_INTERVAL: Duration = Duration::from_secs(1);

pub fn execute_codex(
    repo_root: &Path,
    request: &LifecycleRouteExecutionRequest,
    executor_bin: PathBuf,
) -> Result<LifecycleRouteExecutionResult, LifecycleExecutionError> {
    execute_agent(repo_root, request, "codex", executor_bin)
}

pub fn runtime_preflight_failure() -> Option<String> {
    let home = std::env::var_os("HOME")?;
    runtime_preflight_failure_for_home(&PathBuf::from(home))
}

fn runtime_preflight_failure_for_home(home: &Path) -> Option<String> {
    let codex_dir = home.join(".codex");
    if !codex_dir.exists() {
        return None;
    }
    if !codex_dir.is_dir() {
        return Some(format!(
            "Codex runtime path is not a directory: {}",
            codex_dir.display()
        ));
    }
    let state_db = codex_dir.join("state_5.sqlite");
    if state_db.exists() {
        if let Err(error) = OpenOptions::new().read(true).write(true).open(&state_db) {
            return Some(format!(
                "cannot open Codex state database for write access at {}: {error}",
                state_db.display()
            ));
        }
    }
    let nonce = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|duration| duration.as_nanos())
        .unwrap_or(0);
    let probe = codex_dir.join(format!(
        ".octon-codex-runtime-preflight-{}-{nonce}.tmp",
        std::process::id()
    ));
    match OpenOptions::new().write(true).create_new(true).open(&probe) {
        Ok(_) => {
            let _ = fs::remove_file(&probe);
            None
        }
        Err(error) => Some(format!(
            "cannot create Codex runtime preflight file at {}: {error}",
            probe.display()
        )),
    }
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
    let executor_start_path = request
        .evidence_root
        .join(format!("{}-executor-start.yml", request.route.route_id));
    let executor_observation_path = request.evidence_root.join(format!(
        "{}-executor-observation.yml",
        request.route.route_id
    ));
    let executor_terminal_path = request
        .evidence_root
        .join(format!("{}-executor-terminal.yml", request.route.route_id));
    fs::write(&prompt_path, &prompt)?;

    let output = run_with_timeout(
        repo_root,
        &executor_bin,
        executor_name,
        &prompt,
        request,
        &stdout_path,
        &stderr_path,
        &executor_start_path,
        &executor_observation_path,
        &executor_terminal_path,
    )?;
    let observation = observer::observe_completion(request, before.clone(), before_target_digest)
        .map_err(LifecycleExecutionError::from)?;
    let retry_after_target_digest =
        observer::target_digest(&request.target).map_err(LifecycleExecutionError::from)?;
    let (status, error_class) = route_status_and_error(&output, observation.completion_observed);
    let retryable = matches!(
        &error_class,
        Some(LifecycleErrorClass::ExecutorFailed)
            | Some(LifecycleErrorClass::ExecutorUnavailable)
            | Some(LifecycleErrorClass::Timeout)
    ) && before == observation.manifest_status_after
        && retry_before_target_digest == retry_after_target_digest;
    let mut evidence_paths = vec![
        prompt_path.clone(),
        stdout_path.clone(),
        stderr_path.clone(),
        executor_start_path.clone(),
        executor_observation_path.clone(),
        executor_terminal_path.clone(),
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
}

fn route_status_and_error(
    output: &AgentOutput,
    completion_observed: bool,
) -> (&'static str, Option<LifecycleErrorClass>) {
    if output.cancelled {
        ("cancelled", Some(LifecycleErrorClass::Cancelled))
    } else if output.success && completion_observed {
        ("completed", None)
    } else if output.timed_out {
        ("timed-out", Some(LifecycleErrorClass::Timeout))
    } else if !output.success {
        ("failed", Some(LifecycleErrorClass::ExecutorFailed))
    } else {
        ("failed", Some(LifecycleErrorClass::CompletionNotObserved))
    }
}

fn run_with_timeout(
    repo_root: &Path,
    executor_bin: &Path,
    executor_name: &str,
    prompt: &str,
    request: &LifecycleRouteExecutionRequest,
    stdout_path: &Path,
    stderr_path: &Path,
    executor_start_path: &Path,
    executor_observation_path: &Path,
    executor_terminal_path: &Path,
) -> Result<AgentOutput, LifecycleExecutionError> {
    let mut command = build_executor_command(executor_bin, executor_name, repo_root)?;
    let command_line = executor_command_line(executor_bin, executor_name, repo_root);
    write_executor_start_evidence(
        executor_start_path,
        executor_name,
        executor_bin,
        &command_line,
        request,
    )?;
    let stdout_file = File::create(stdout_path)?;
    let stderr_file = File::create(stderr_path)?;
    command
        .stdout(Stdio::from(stdout_file))
        .stderr(Stdio::from(stderr_file));
    let mut child = command.spawn().map_err(|error| {
        LifecycleExecutionError::new(LifecycleErrorClass::ExecutorUnavailable, error.to_string())
    })?;
    if let Some(stdin) = child.stdin.as_mut() {
        stdin.write_all(prompt.as_bytes())?;
    }
    drop(child.stdin.take());
    let start = Instant::now();
    let mut last_observation = Instant::now()
        .checked_sub(OBSERVATION_INTERVAL)
        .unwrap_or_else(Instant::now);
    write_executor_observation(
        executor_observation_path,
        executor_name,
        child.id(),
        start.elapsed(),
        "running",
        request,
    )?;
    loop {
        if let Some(token) = request.policy.cancellation_token.as_ref() {
            if token.exists() {
                let termination = terminate_child(&mut child);
                let exit_observed = termination.status.is_some();
                write_executor_terminal(
                    executor_terminal_path,
                    executor_name,
                    child.id(),
                    "cancelled",
                    start.elapsed(),
                    termination.status,
                    exit_observed,
                    termination.used_force_kill,
                    termination.error.as_deref(),
                )?;
                return Ok(AgentOutput {
                    success: false,
                    timed_out: false,
                    cancelled: true,
                });
            }
        }
        if let Some(status) = child.try_wait()? {
            let state = if status.success() {
                "completed"
            } else {
                "failed"
            };
            write_executor_terminal(
                executor_terminal_path,
                executor_name,
                child.id(),
                state,
                start.elapsed(),
                Some(status),
                true,
                false,
                None,
            )?;
            return Ok(AgentOutput {
                success: status.success(),
                timed_out: false,
                cancelled: false,
            });
        }
        if start.elapsed() >= Duration::from_secs(request.policy.timeout_seconds) {
            let termination = terminate_child(&mut child);
            let exit_observed = termination.status.is_some();
            let terminal_state =
                timeout_terminal_state(termination.status.map(|status| status.success()));
            write_executor_terminal(
                executor_terminal_path,
                executor_name,
                child.id(),
                terminal_state,
                start.elapsed(),
                termination.status,
                exit_observed,
                termination.used_force_kill,
                termination.error.as_deref(),
            )?;
            return Ok(AgentOutput {
                success: termination
                    .status
                    .map(|status| status.success())
                    .unwrap_or(false),
                timed_out: true,
                cancelled: false,
            });
        }
        if last_observation.elapsed() >= OBSERVATION_INTERVAL {
            write_executor_observation(
                executor_observation_path,
                executor_name,
                child.id(),
                start.elapsed(),
                "running",
                request,
            )?;
            last_observation = Instant::now();
        }
        thread::sleep(Duration::from_millis(100));
    }
}

fn timeout_terminal_state(success: Option<bool>) -> &'static str {
    if success.unwrap_or(false) {
        "completed-timeout-boundary"
    } else {
        "timed-out"
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
    command.stdin(Stdio::piped()).current_dir(repo_root);
    configure_process_group(&mut command);
    Ok(command)
}

fn executor_command_line(executor_bin: &Path, executor_name: &str, repo_root: &Path) -> String {
    match executor_name {
        "codex" => format!(
            "{} exec --ephemeral --skip-git-repo-check --cd {}",
            executor_bin.display(),
            repo_root.display()
        ),
        "claude" => format!("{} -p --output-format text", executor_bin.display()),
        _ => executor_bin.display().to_string(),
    }
}

#[cfg(unix)]
fn configure_process_group(command: &mut Command) {
    unsafe {
        command.pre_exec(|| {
            if libc::setpgid(0, 0) == 0 {
                Ok(())
            } else {
                Err(std::io::Error::last_os_error())
            }
        });
    }
}

#[cfg(not(unix))]
fn configure_process_group(_command: &mut Command) {}

struct TerminationResult {
    status: Option<ExitStatus>,
    used_force_kill: bool,
    error: Option<String>,
}

fn terminate_child(child: &mut Child) -> TerminationResult {
    let mut error = None;
    #[cfg(unix)]
    {
        let pid = child.id() as libc::pid_t;
        if unsafe { libc::kill(-pid, libc::SIGTERM) } != 0 {
            error = Some(std::io::Error::last_os_error().to_string());
        }
        if let Ok(Some(status)) = wait_for_child(child, TERMINATION_GRACE) {
            let cleanup = force_kill_process_group(pid);
            if error.is_none() {
                error = cleanup.error;
            }
            return TerminationResult {
                status: Some(status),
                used_force_kill: cleanup.used_force_kill,
                error,
            };
        }
        let cleanup = force_kill_process_group(pid);
        if error.is_none() {
            error = cleanup.error;
        }
        let status = wait_for_child(child, FORCE_KILL_GRACE).ok().flatten();
        return TerminationResult {
            status,
            used_force_kill: cleanup.used_force_kill,
            error,
        };
    }
    #[cfg(not(unix))]
    {
        if let Err(kill_error) = child.kill() {
            error = Some(kill_error.to_string());
        }
        let status = wait_for_child(child, TERMINATION_GRACE).ok().flatten();
        TerminationResult {
            status,
            used_force_kill: false,
            error,
        }
    }
}

#[cfg(unix)]
struct ProcessGroupCleanup {
    used_force_kill: bool,
    error: Option<String>,
}

#[cfg(unix)]
fn force_kill_process_group(pid: libc::pid_t) -> ProcessGroupCleanup {
    let mut error = None;
    let used_force_kill = match unsafe { libc::kill(-pid, libc::SIGKILL) } {
        0 => true,
        _ if std::io::Error::last_os_error().raw_os_error() == Some(libc::ESRCH) => false,
        _ => {
            error = Some(std::io::Error::last_os_error().to_string());
            false
        }
    };
    let start = Instant::now();
    while process_group_exists(pid) && start.elapsed() < FORCE_KILL_GRACE {
        thread::sleep(Duration::from_millis(50));
    }
    if process_group_exists(pid) && error.is_none() {
        error = Some("process group still existed after force kill grace period".to_string());
    }
    ProcessGroupCleanup {
        used_force_kill,
        error,
    }
}

#[cfg(unix)]
fn process_group_exists(pid: libc::pid_t) -> bool {
    unsafe { libc::kill(-pid, 0) == 0 }
}

fn wait_for_child(child: &mut Child, timeout: Duration) -> std::io::Result<Option<ExitStatus>> {
    let start = Instant::now();
    loop {
        if let Some(status) = child.try_wait()? {
            return Ok(Some(status));
        }
        if start.elapsed() >= timeout {
            return Ok(None);
        }
        thread::sleep(Duration::from_millis(50));
    }
}

fn write_executor_start_evidence(
    path: &Path,
    executor_name: &str,
    executor_bin: &Path,
    command_line: &str,
    request: &LifecycleRouteExecutionRequest,
) -> Result<(), LifecycleExecutionError> {
    let cancellation_token = request
        .policy
        .cancellation_token
        .as_ref()
        .map(|path| path.display().to_string())
        .unwrap_or_else(|| "none".to_string());
    fs::write(
        path,
        format!(
            "schema_version: octon-lifecycle-executor-start-v1\nrun_id: {}\nroute_id: {}\nexecutor_name: {}\nexecutor_bin: {}\ncommand_line: {}\ntimeout_seconds: {}\nretry_attempt: {}\napproval_policy: {}\ncancellation_token: {}\nstarted_at: {}\n",
            yaml_scalar(&request.run_id),
            yaml_scalar(&request.route.route_id),
            yaml_scalar(executor_name),
            yaml_scalar(&executor_bin.display().to_string()),
            yaml_scalar(command_line),
            request.policy.timeout_seconds,
            request.policy.retry_attempt,
            yaml_scalar(&request.policy.approval_policy),
            yaml_scalar(&cancellation_token),
            yaml_scalar(&now_rfc3339()),
        ),
    )?;
    Ok(())
}

fn write_executor_observation(
    path: &Path,
    executor_name: &str,
    pid: u32,
    elapsed: Duration,
    state: &str,
    request: &LifecycleRouteExecutionRequest,
) -> Result<(), LifecycleExecutionError> {
    fs::write(
        path,
        format!(
            "schema_version: octon-lifecycle-executor-observation-v1\nrun_id: {}\nroute_id: {}\nexecutor_name: {}\npid: {}\nelapsed_ms: {}\nstate: {}\nobserved_at: {}\n",
            yaml_scalar(&request.run_id),
            yaml_scalar(&request.route.route_id),
            yaml_scalar(executor_name),
            pid,
            elapsed.as_millis(),
            yaml_scalar(state),
            yaml_scalar(&now_rfc3339()),
        ),
    )?;
    Ok(())
}

fn write_executor_terminal(
    path: &Path,
    executor_name: &str,
    pid: u32,
    state: &str,
    elapsed: Duration,
    status: Option<ExitStatus>,
    process_exit_observed: bool,
    used_force_kill: bool,
    termination_error: Option<&str>,
) -> Result<(), LifecycleExecutionError> {
    fs::write(
        path,
        format!(
            "schema_version: octon-lifecycle-executor-terminal-v1\nexecutor_name: {}\npid: {}\nelapsed_ms: {}\nstate: {}\nexit_status: {}\nprocess_exit_observed: {}\nused_force_kill: {}\ntermination_error: {}\nrecorded_at: {}\n",
            yaml_scalar(executor_name),
            pid,
            elapsed.as_millis(),
            yaml_scalar(state),
            yaml_scalar(
                &status
                    .map(|status| status.to_string())
                    .unwrap_or_else(|| "none".to_string())
            ),
            process_exit_observed,
            used_force_kill,
            yaml_scalar(termination_error.unwrap_or("none")),
            yaml_scalar(&now_rfc3339()),
        ),
    )?;
    Ok(())
}

fn yaml_scalar(value: &str) -> String {
    serde_yaml::to_string(value)
        .map(|value| value.trim().to_string())
        .unwrap_or_else(|_| format!("{value:?}"))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn timeout_boundary_success_with_completion_is_completed() {
        let output = AgentOutput {
            success: true,
            timed_out: true,
            cancelled: false,
        };

        let (status, error_class) = route_status_and_error(&output, true);

        assert_eq!(status, "completed");
        assert_eq!(error_class, None);
        assert_eq!(
            timeout_terminal_state(Some(true)),
            "completed-timeout-boundary"
        );
    }

    #[test]
    fn timeout_boundary_without_completion_remains_timeout() {
        let output = AgentOutput {
            success: true,
            timed_out: true,
            cancelled: false,
        };

        let (status, error_class) = route_status_and_error(&output, false);

        assert_eq!(status, "timed-out");
        assert_eq!(error_class, Some(LifecycleErrorClass::Timeout));
        assert_eq!(timeout_terminal_state(Some(false)), "timed-out");
        assert_eq!(timeout_terminal_state(None), "timed-out");
    }

    #[test]
    fn codex_runtime_preflight_reports_readonly_state_db() {
        let root =
            std::env::temp_dir().join(format!("octon-codex-preflight-{}", std::process::id()));
        let _ = fs::remove_dir_all(&root);
        fs::create_dir_all(root.join(".codex")).unwrap();
        let state_db = root.join(".codex/state_5.sqlite");
        fs::write(&state_db, b"").unwrap();
        let mut permissions = fs::metadata(&state_db).unwrap().permissions();
        permissions.set_readonly(true);
        fs::set_permissions(&state_db, permissions).unwrap();

        let failure = runtime_preflight_failure_for_home(&root).unwrap_or_default();

        let mut permissions = fs::metadata(&state_db).unwrap().permissions();
        permissions.set_readonly(false);
        fs::set_permissions(&state_db, permissions).unwrap();
        let _ = fs::remove_dir_all(&root);
        assert!(
            failure.contains("cannot open Codex state database for write access"),
            "failure: {failure}"
        );
    }
}
