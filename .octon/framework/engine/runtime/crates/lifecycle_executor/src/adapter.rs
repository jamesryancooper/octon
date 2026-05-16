use crate::approval;
use crate::auto;
use crate::claude;
use crate::codex;
use crate::errors::{LifecycleErrorClass, LifecycleExecutionError};
use crate::mock;
use crate::observer;
use crate::request::LifecycleRouteExecutionRequest;
use crate::result::LifecycleRouteExecutionResult;
use std::fs;
use std::path::{Path, PathBuf};

pub trait LifecycleRouteExecutor {
    fn execute_route(
        &self,
        request: LifecycleRouteExecutionRequest,
    ) -> Result<LifecycleRouteExecutionResult, LifecycleExecutionError>;
}

#[derive(Clone, Debug)]
pub struct DefaultLifecycleRouteExecutor {
    repo_root: PathBuf,
}

impl DefaultLifecycleRouteExecutor {
    pub fn new(repo_root: impl Into<PathBuf>) -> Self {
        Self {
            repo_root: repo_root.into(),
        }
    }
}

impl LifecycleRouteExecutor for DefaultLifecycleRouteExecutor {
    fn execute_route(
        &self,
        request: LifecycleRouteExecutionRequest,
    ) -> Result<LifecycleRouteExecutionResult, LifecycleExecutionError> {
        fs::create_dir_all(&request.evidence_root)?;
        if let Err(error) = observer::validate_request_paths(&request) {
            let result = failure_result_without_observation(&request, error)?;
            write_result(&request.evidence_root, &request.route.route_id, &result)?;
            return Ok(result);
        }
        let before = observer::manifest_status(
            &request.target,
            &request.manifest_path,
            &request.status_field,
        )
        .map_err(LifecycleExecutionError::from)?;
        let receipts = observer::observe_receipts(&request.target, &request.receipts)
            .map_err(LifecycleExecutionError::from)?;
        if cancellation_token_active(&request) {
            let result = cancellation_result(&request, before, receipts)?;
            write_result(&request.evidence_root, &request.route.route_id, &result)?;
            return Ok(result);
        }
        if let Some(missing_inputs) = missing_required_inputs(&request) {
            let result = input_binding_blocked_result(&request, before, receipts, missing_inputs)?;
            write_result(&request.evidence_root, &request.route.route_id, &result)?;
            return Ok(result);
        }
        if approval::approval_required(&request) {
            let result = approval::write_approval_pause(&request, before, receipts)?;
            write_result(&request.evidence_root, &request.route.route_id, &result)?;
            return Ok(result);
        }
        if let Some(result) =
            executor_preflight_blocked(&self.repo_root, &request, before.clone(), receipts.clone())?
        {
            write_result(&request.evidence_root, &request.route.route_id, &result)?;
            return Ok(result);
        }
        let approval_override = if approval::unattended_override_active(&request) {
            Some(approval::write_unattended_override(&request)?)
        } else {
            None
        };
        let mut result = match match request.executor.as_str() {
            "mock" => mock::execute_mock(&request),
            "codex" | "claude" | "auto" => execute_real(&self.repo_root, &request),
            other => Err(LifecycleExecutionError::new(
                LifecycleErrorClass::ExecutorUnavailable,
                format!("unsupported lifecycle executor: {other}"),
            )),
        } {
            Ok(result) => result,
            Err(error) => failure_result(&request, before, receipts, error)?,
        };
        if let Some(path) = approval_override {
            result.evidence_paths.insert(0, path);
        }
        write_result(&request.evidence_root, &request.route.route_id, &result)?;
        Ok(result)
    }
}

fn executor_preflight_blocked(
    repo_root: &Path,
    request: &LifecycleRouteExecutionRequest,
    manifest_status_before: Option<String>,
    receipts: Vec<crate::result::ReceiptObservation>,
) -> Result<Option<LifecycleRouteExecutionResult>, LifecycleExecutionError> {
    let Some((executor_name, executor_bin)) = auto::resolve_executor(&request.executor) else {
        return Ok(None);
    };
    if executor_name != "codex" {
        return Ok(None);
    }
    let repo_root = repo_root
        .canonicalize()
        .unwrap_or_else(|_| repo_root.to_path_buf());
    let executor_bin = executor_bin
        .canonicalize()
        .unwrap_or_else(|_| executor_bin.clone());
    // Adapter tests install repo-local fake binaries to exercise executor behavior.
    if executor_bin.starts_with(&repo_root) {
        return Ok(None);
    }
    let Some(reason) = codex::runtime_preflight_failure() else {
        return Ok(None);
    };
    let now = approval::now_rfc3339();
    let evidence_path = request.evidence_root.join(format!(
        "{}-executor-preflight-blocked.yml",
        request.route.route_id
    ));
    fs::write(
        &evidence_path,
        format!(
            "schema_version: octon-lifecycle-executor-preflight-blocked-v1\nrun_id: {}\nroute_id: {}\nexecutor: {}\npreflight: codex-runtime-write-access\nstatus: blocked\nretryable: false\nreason: {}\nrecovery_instruction: rerun through the approved escalated execution path so nested Codex can write its local runtime state\nrecorded_at: {}\n",
            request.run_id,
            request.route.route_id,
            executor_name,
            yaml_string(&reason),
            now
        ),
    )?;
    Ok(Some(LifecycleRouteExecutionResult {
        schema_version: "octon-lifecycle-route-execution-result-v1".to_string(),
        run_id: request.run_id.clone(),
        route_id: request.route.route_id.clone(),
        executor_used: request.executor.clone(),
        status: "executor-preflight-blocked".to_string(),
        started_at: now.clone(),
        ended_at: now,
        manifest_status_before: manifest_status_before.clone(),
        manifest_status_after: observer::manifest_status(
            &request.target,
            &request.manifest_path,
            &request.status_field,
        )
        .map_err(LifecycleExecutionError::from)?,
        receipts_observed: receipts,
        evidence_paths: vec![evidence_path],
        stdout_path: None,
        stderr_path: None,
        prompt_packet_path: None,
        retryable: false,
        next_action: "rerun-with-approved-executor-access".to_string(),
        error_class: Some(LifecycleErrorClass::ExecutorUnavailable),
        error_message: Some(format!("nested Codex runtime preflight failed: {reason}")),
    }))
}

fn cancellation_token_active(request: &LifecycleRouteExecutionRequest) -> bool {
    request
        .policy
        .cancellation_token
        .as_ref()
        .map(|token| token.exists())
        .unwrap_or(false)
}

fn cancellation_result(
    request: &LifecycleRouteExecutionRequest,
    manifest_status_before: Option<String>,
    receipts: Vec<crate::result::ReceiptObservation>,
) -> Result<LifecycleRouteExecutionResult, LifecycleExecutionError> {
    let now = approval::now_rfc3339();
    let token = request
        .policy
        .cancellation_token
        .as_ref()
        .map(|path| path.display().to_string())
        .unwrap_or_else(|| "none".to_string());
    let cancelled_path = request
        .evidence_root
        .join(format!("{}-cancelled.yml", request.route.route_id));
    fs::write(
        &cancelled_path,
        format!(
            "schema_version: octon-lifecycle-route-cancelled-v1\nrun_id: {}\nroute_id: {}\ncancellation_token: {}\nrecorded_at: {}\n",
            request.run_id,
            request.route.route_id,
            token,
            now
        ),
    )?;
    Ok(LifecycleRouteExecutionResult {
        schema_version: "octon-lifecycle-route-execution-result-v1".to_string(),
        run_id: request.run_id.clone(),
        route_id: request.route.route_id.clone(),
        executor_used: request.executor.clone(),
        status: "cancelled".to_string(),
        started_at: now.clone(),
        ended_at: now,
        manifest_status_before: manifest_status_before.clone(),
        manifest_status_after: observer::manifest_status(
            &request.target,
            &request.manifest_path,
            &request.status_field,
        )
        .map_err(LifecycleExecutionError::from)?,
        receipts_observed: receipts,
        evidence_paths: vec![cancelled_path],
        stdout_path: None,
        stderr_path: None,
        prompt_packet_path: None,
        retryable: false,
        next_action: "cancelled".to_string(),
        error_class: Some(LifecycleErrorClass::Cancelled),
        error_message: Some(
            "lifecycle cancellation token existed before route dispatch".to_string(),
        ),
    })
}

fn missing_required_inputs(request: &LifecycleRouteExecutionRequest) -> Option<Vec<String>> {
    let missing = request
        .route
        .required_inputs
        .iter()
        .filter(|input| {
            request
                .bound_inputs
                .get(input.as_str())
                .map(|value| value.trim().is_empty())
                .unwrap_or(true)
        })
        .cloned()
        .collect::<Vec<_>>();
    if missing.is_empty() {
        None
    } else {
        Some(missing)
    }
}

fn input_binding_blocked_result(
    request: &LifecycleRouteExecutionRequest,
    manifest_status_before: Option<String>,
    receipts: Vec<crate::result::ReceiptObservation>,
    missing_inputs: Vec<String>,
) -> Result<LifecycleRouteExecutionResult, LifecycleExecutionError> {
    let now = approval::now_rfc3339();
    let blocked_path = request.evidence_root.join(format!(
        "{}-input-binding-blocked.yml",
        request.route.route_id
    ));
    fs::write(
        &blocked_path,
        format!(
            "schema_version: octon-lifecycle-input-binding-blocked-v1\nrun_id: {}\nroute_id: {}\nmissing_required_inputs:\n{}\n",
            request.run_id,
            request.route.route_id,
            missing_inputs
                .iter()
                .map(|input| format!("  - {input}"))
                .collect::<Vec<_>>()
                .join("\n")
        ),
    )?;
    Ok(LifecycleRouteExecutionResult {
        schema_version: "octon-lifecycle-route-execution-result-v1".to_string(),
        run_id: request.run_id.clone(),
        route_id: request.route.route_id.clone(),
        executor_used: request.executor.clone(),
        status: "blocked".to_string(),
        started_at: now.clone(),
        ended_at: now,
        manifest_status_before: manifest_status_before.clone(),
        manifest_status_after: observer::manifest_status(
            &request.target,
            &request.manifest_path,
            &request.status_field,
        )
        .map_err(LifecycleExecutionError::from)?,
        receipts_observed: receipts,
        evidence_paths: vec![blocked_path],
        stdout_path: None,
        stderr_path: None,
        prompt_packet_path: None,
        retryable: false,
        next_action: "manual-intervention".to_string(),
        error_class: Some(LifecycleErrorClass::InputBinding),
        error_message: Some(format!(
            "missing required lifecycle run inputs: {}",
            missing_inputs.join(", ")
        )),
    })
}

fn execute_real(
    repo_root: &Path,
    request: &LifecycleRouteExecutionRequest,
) -> Result<LifecycleRouteExecutionResult, LifecycleExecutionError> {
    let Some((executor_name, executor_bin)) = auto::resolve_executor(&request.executor) else {
        return Err(LifecycleExecutionError::new(
            LifecycleErrorClass::ExecutorUnavailable,
            format!("executor unavailable for mode {}", request.executor),
        ));
    };
    match executor_name {
        "codex" => codex::execute_codex(repo_root, request, executor_bin),
        "claude" => claude::execute_claude(repo_root, request, executor_bin),
        _ => Err(LifecycleExecutionError::new(
            LifecycleErrorClass::ExecutorUnavailable,
            format!("unsupported resolved executor: {executor_name}"),
        )),
    }
}

fn write_result(
    evidence_root: &Path,
    route_id: &str,
    result: &LifecycleRouteExecutionResult,
) -> Result<(), LifecycleExecutionError> {
    let path = evidence_root.join(format!("{route_id}-route-execution.yml"));
    fs::write(
        path,
        serde_yaml::to_string(result).map_err(LifecycleExecutionError::from)?,
    )?;
    Ok(())
}

fn yaml_string(value: &str) -> String {
    serde_yaml::to_string(value)
        .map(|value| value.trim().to_string())
        .unwrap_or_else(|_| format!("{value:?}"))
}

fn failure_result(
    request: &LifecycleRouteExecutionRequest,
    manifest_status_before: Option<String>,
    receipts: Vec<crate::result::ReceiptObservation>,
    error: LifecycleExecutionError,
) -> Result<LifecycleRouteExecutionResult, LifecycleExecutionError> {
    let now = approval::now_rfc3339();
    let error_path = request
        .evidence_root
        .join(format!("{}-error.yml", request.route.route_id));
    fs::write(
        &error_path,
        format!(
            "schema_version: octon-lifecycle-route-error-v1\nrun_id: {}\nroute_id: {}\nerror_class: {}\nmessage: {}\n",
            request.run_id,
            request.route.route_id,
            error.class.as_str(),
            error.message
        ),
    )?;
    Ok(LifecycleRouteExecutionResult {
        schema_version: "octon-lifecycle-route-execution-result-v1".to_string(),
        run_id: request.run_id.clone(),
        route_id: request.route.route_id.clone(),
        executor_used: request.executor.clone(),
        status: "failed".to_string(),
        started_at: now.clone(),
        ended_at: now,
        manifest_status_before: manifest_status_before.clone(),
        manifest_status_after: observer::manifest_status(
            &request.target,
            &request.manifest_path,
            &request.status_field,
        )
        .map_err(LifecycleExecutionError::from)?,
        receipts_observed: receipts,
        evidence_paths: vec![error_path],
        stdout_path: None,
        stderr_path: None,
        prompt_packet_path: None,
        retryable: matches!(
            &error.class,
            LifecycleErrorClass::ExecutorUnavailable
                | LifecycleErrorClass::ExecutorFailed
                | LifecycleErrorClass::Timeout
        ),
        next_action: "manual-intervention".to_string(),
        error_class: Some(error.class),
        error_message: Some(error.message),
    })
}

fn failure_result_without_observation(
    request: &LifecycleRouteExecutionRequest,
    error: LifecycleExecutionError,
) -> Result<LifecycleRouteExecutionResult, LifecycleExecutionError> {
    let now = approval::now_rfc3339();
    let error_path = request
        .evidence_root
        .join(format!("{}-error.yml", request.route.route_id));
    fs::write(
        &error_path,
        format!(
            "schema_version: octon-lifecycle-route-error-v1\nrun_id: {}\nroute_id: {}\nerror_class: {}\nmessage: {}\n",
            request.run_id,
            request.route.route_id,
            error.class.as_str(),
            error.message
        ),
    )?;
    Ok(LifecycleRouteExecutionResult {
        schema_version: "octon-lifecycle-route-execution-result-v1".to_string(),
        run_id: request.run_id.clone(),
        route_id: request.route.route_id.clone(),
        executor_used: request.executor.clone(),
        status: "failed".to_string(),
        started_at: now.clone(),
        ended_at: now,
        manifest_status_before: None,
        manifest_status_after: None,
        receipts_observed: Vec::new(),
        evidence_paths: vec![error_path],
        stdout_path: None,
        stderr_path: None,
        prompt_packet_path: None,
        retryable: false,
        next_action: "manual-intervention".to_string(),
        error_class: Some(error.class),
        error_message: Some(error.message),
    })
}
