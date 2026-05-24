use crate::authorization;
use crate::auto;
use crate::claude;
use crate::codex;
use crate::errors::{LifecycleErrorClass, LifecycleExecutionError};
use crate::mock;
use crate::observer;
use crate::request::LifecycleRouteExecutionRequest;
use crate::result::LifecycleRouteExecutionResult;
use crate::workflow_leaf;
use std::fs;
use std::path::{Path, PathBuf};
use std::sync::Arc;

type WorkflowRouteRunner = dyn Fn(
        &Path,
        &LifecycleRouteExecutionRequest,
    ) -> Result<LifecycleRouteExecutionResult, LifecycleExecutionError>
    + Send
    + Sync;

pub trait LifecycleRouteExecutor {
    fn execute_route(
        &self,
        request: LifecycleRouteExecutionRequest,
    ) -> Result<LifecycleRouteExecutionResult, LifecycleExecutionError>;
}

#[derive(Clone)]
pub struct DefaultLifecycleRouteExecutor {
    repo_root: PathBuf,
    workflow_runner: Option<Arc<WorkflowRouteRunner>>,
}

impl DefaultLifecycleRouteExecutor {
    pub fn new(repo_root: impl Into<PathBuf>) -> Self {
        Self {
            repo_root: repo_root.into(),
            workflow_runner: None,
        }
    }

    pub fn with_workflow_runner(
        mut self,
        runner: impl Fn(
                &Path,
                &LifecycleRouteExecutionRequest,
            ) -> Result<LifecycleRouteExecutionResult, LifecycleExecutionError>
            + Send
            + Sync
            + 'static,
    ) -> Self {
        self.workflow_runner = Some(Arc::new(runner));
        self
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
        match missing_required_inputs(&self.repo_root, &request) {
            Ok(Some(missing_inputs)) => {
                let result =
                    input_binding_blocked_result(&request, before, receipts, missing_inputs)?;
                write_result(&request.evidence_root, &request.route.route_id, &result)?;
                return Ok(result);
            }
            Ok(None) => {}
            Err(error) => {
                let result = failure_result(&request, before, receipts, error)?;
                write_result(&request.evidence_root, &request.route.route_id, &result)?;
                return Ok(result);
            }
        }
        let authorization_proof = match authorization::authorize_before_dispatch(
            &self.repo_root,
            &request,
            before.clone(),
            receipts.clone(),
        ) {
            Ok(path) => path,
            Err(result) => {
                write_result(&request.evidence_root, &request.route.route_id, &result)?;
                return Ok(result);
            }
        };
        if let Some(result) =
            executor_preflight_blocked(&self.repo_root, &request, before.clone(), receipts.clone())?
        {
            write_result(&request.evidence_root, &request.route.route_id, &result)?;
            return Ok(result);
        }
        let mut result = match match request.executor.as_str() {
            "mock" => mock::execute_mock(&request),
            "codex" | "claude" | "auto" => {
                execute_real(&self.repo_root, self.workflow_runner.as_deref(), &request)
            }
            other => Err(LifecycleExecutionError::new(
                LifecycleErrorClass::ExecutorUnavailable,
                format!("unsupported lifecycle executor: {other}"),
            )),
        } {
            Ok(result) => result,
            Err(error) => failure_result(&request, before, receipts, error)?,
        };
        result.evidence_paths.insert(0, authorization_proof);
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
    if request.route.route_type == "workflow" {
        return Ok(None);
    }
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
    let now = authorization::now_rfc3339();
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
        phase_id: request.phase_id.clone(),
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
    let now = authorization::now_rfc3339();
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
        phase_id: request.phase_id.clone(),
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

fn missing_required_inputs(
    repo_root: &Path,
    request: &LifecycleRouteExecutionRequest,
) -> Result<Option<Vec<String>>, LifecycleExecutionError> {
    let mut required = request.route.required_inputs.clone();
    if request.route.route_type == "workflow" && request.executor != "mock" {
        required.extend(workflow_leaf::required_workflow_inputs(repo_root, request)?);
        required.sort();
        required.dedup();
    }
    let missing = required
        .iter()
        .filter(|input| input_is_missing(request, input))
        .cloned()
        .collect::<Vec<_>>();
    if missing.is_empty() {
        Ok(None)
    } else {
        Ok(Some(missing))
    }
}

fn input_is_missing(request: &LifecycleRouteExecutionRequest, input: &str) -> bool {
    request
        .bound_inputs
        .get(input)
        .map(|value| value.trim().is_empty())
        .unwrap_or(true)
}

fn input_binding_blocked_result(
    request: &LifecycleRouteExecutionRequest,
    manifest_status_before: Option<String>,
    receipts: Vec<crate::result::ReceiptObservation>,
    missing_inputs: Vec<String>,
) -> Result<LifecycleRouteExecutionResult, LifecycleExecutionError> {
    let now = authorization::now_rfc3339();
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
        phase_id: request.phase_id.clone(),
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
    workflow_runner: Option<&WorkflowRouteRunner>,
    request: &LifecycleRouteExecutionRequest,
) -> Result<LifecycleRouteExecutionResult, LifecycleExecutionError> {
    if request.route.route_type == "workflow" {
        if let Some(runner) = workflow_runner {
            return runner(repo_root, request);
        }
        return workflow_leaf::execute_workflow_leaf(repo_root, request);
    }
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

#[cfg(test)]
mod tests {
    use super::*;
    use crate::request::{
        LifecycleExecutionPolicy, LifecycleInvocationAuthority, LifecycleRouteSpec,
    };
    use std::collections::BTreeMap;
    use std::time::{SystemTime, UNIX_EPOCH};

    fn temp_root(name: &str) -> PathBuf {
        let nanos = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap()
            .as_nanos();
        let root = std::env::temp_dir().join(format!(
            "octon-lifecycle-executor-{name}-{}-{nanos}",
            std::process::id()
        ));
        fs::create_dir_all(&root).unwrap();
        root
    }

    fn write_workflow_fixture(root: &Path) {
        fs::create_dir_all(root.join(".octon/instance/governance")).unwrap();
        fs::create_dir_all(root.join(".octon/generated/effective/runtime")).unwrap();
        fs::create_dir_all(
            root.join(".octon/framework/orchestration/runtime/workflows/meta/promote-proposal"),
        )
        .unwrap();
        fs::write(
            root.join(".octon/instance/governance/runtime-resolution.yml"),
            "schema_version: \"octon-runtime-resolution-v1\"\nruntime_effective_route_bundle_ref: \".octon/generated/effective/runtime/route-bundle.yml\"\nruntime_effective_route_bundle_lock_ref: \".octon/generated/effective/runtime/route-bundle.lock.yml\"\nextensions_catalog_ref: \".octon/generated/effective/extensions/catalog.effective.yml\"\n",
        )
        .unwrap();
        fs::write(
            root.join(".octon/generated/effective/runtime/route-bundle.yml"),
            "schema_version: \"octon-runtime-effective-route-bundle-v1\"\ngeneration_id: \"fixture\"\nsource_refs:\n  workflow_manifest_ref: \".octon/framework/orchestration/runtime/workflows/manifest.yml\"\nroutes: []\n",
        )
        .unwrap();
        fs::write(
            root.join(".octon/framework/orchestration/runtime/workflows/manifest.yml"),
            "workflows:\n  - id: promote-proposal\n    path: meta/promote-proposal/\n",
        )
        .unwrap();
        fs::write(
            root.join(
                ".octon/framework/orchestration/runtime/workflows/meta/promote-proposal/workflow.yml",
            ),
            "schema_version: workflow-contract-v2\nname: promote-proposal\ninputs:\n  - name: proposal_path\n    required: true\n  - name: promotion_evidence\n    required: true\n",
        )
        .unwrap();
        fs::create_dir_all(root.join("packet")).unwrap();
        fs::write(root.join("packet/proposal.yml"), "status: accepted\n").unwrap();
    }

    fn workflow_request(
        root: &Path,
        bound_inputs: BTreeMap<String, String>,
    ) -> LifecycleRouteExecutionRequest {
        LifecycleRouteExecutionRequest {
            schema_version: "octon-lifecycle-route-execution-request-v1".to_string(),
            run_id: "run-1".to_string(),
            lifecycle_id: "proposal-packet".to_string(),
            owner_extension: "test-extension".to_string(),
            phase_id: Some("promotion".to_string()),
            target: root.join("packet"),
            manifest_path: "proposal.yml".to_string(),
            status_field: "status".to_string(),
            executor: "codex".to_string(),
            route: LifecycleRouteSpec {
                route_id: "promote-proposal".to_string(),
                route_type: "workflow".to_string(),
                command_id: None,
                skill_id: None,
                prompt_set_id: None,
                required_inputs: Vec::new(),
                completion_replan_required: true,
                delegation_contract: None,
            },
            effective_extension_catalog: root
                .join(".octon/generated/effective/extensions/catalog.effective.yml"),
            runtime_route_bundle: root.join(".octon/generated/effective/runtime/route-bundle.yml"),
            bound_inputs,
            receipts: Vec::new(),
            expected_receipts: Vec::new(),
            expected_paths: Vec::new(),
            expected_manifest_status: Some("implemented".to_string()),
            expected_target_change: true,
            evidence_root: root.join(".octon/state/evidence/runs/workflows/run-1"),
            checkpoint_path: root
                .join(".octon/state/control/execution/runs/run-1/lifecycle-checkpoint.yml"),
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
    fn workflow_declared_required_inputs_are_checked_before_dispatch() {
        let root = temp_root("workflow-required-inputs-missing");
        write_workflow_fixture(&root);
        let mut bound_inputs = BTreeMap::new();
        bound_inputs.insert("proposal_path".to_string(), "packet".to_string());
        let request = workflow_request(&root, bound_inputs);

        let missing = missing_required_inputs(&root, &request)
            .unwrap()
            .expect("promotion evidence should be missing");

        assert_eq!(missing, vec!["promotion_evidence"]);
        let _ = fs::remove_dir_all(root);
    }

    #[test]
    fn workflow_declared_required_inputs_accept_bound_run_inputs() {
        let root = temp_root("workflow-required-inputs-bound");
        write_workflow_fixture(&root);
        let mut bound_inputs = BTreeMap::new();
        bound_inputs.insert("proposal_path".to_string(), "packet".to_string());
        bound_inputs.insert(
            "promotion_evidence".to_string(),
            ".octon/framework/product/features/catalog.yml".to_string(),
        );
        let request = workflow_request(&root, bound_inputs);

        let missing = missing_required_inputs(&root, &request).unwrap();

        assert_eq!(missing, None);
        let _ = fs::remove_dir_all(root);
    }

    #[test]
    fn workflow_routes_use_injected_runner_when_available() {
        let root = temp_root("workflow-injected-runner");
        write_workflow_fixture(&root);
        let mut bound_inputs = BTreeMap::new();
        bound_inputs.insert("proposal_path".to_string(), "packet".to_string());
        bound_inputs.insert(
            "promotion_evidence".to_string(),
            ".octon/framework/product/features/catalog.yml".to_string(),
        );
        let request = workflow_request(&root, bound_inputs);
        let runner = |_repo_root: &Path,
                      request: &LifecycleRouteExecutionRequest|
         -> Result<LifecycleRouteExecutionResult, LifecycleExecutionError> {
            Ok(LifecycleRouteExecutionResult {
                schema_version: "octon-lifecycle-route-execution-result-v1".to_string(),
                run_id: request.run_id.clone(),
                route_id: request.route.route_id.clone(),
                phase_id: request.phase_id.clone(),
                executor_used: "test-workflow-runner".to_string(),
                status: "completed".to_string(),
                started_at: "2026-05-23T00:00:00Z".to_string(),
                ended_at: "2026-05-23T00:00:01Z".to_string(),
                manifest_status_before: Some("accepted".to_string()),
                manifest_status_after: Some("implemented".to_string()),
                receipts_observed: Vec::new(),
                evidence_paths: Vec::new(),
                stdout_path: None,
                stderr_path: None,
                prompt_packet_path: None,
                retryable: false,
                next_action: "replan".to_string(),
                error_class: None,
                error_message: None,
            })
        };

        let result = execute_real(&root, Some(&runner), &request).unwrap();

        assert_eq!(result.executor_used, "test-workflow-runner");
        assert_eq!(result.status, "completed");
        let _ = fs::remove_dir_all(root);
    }
}

fn failure_result(
    request: &LifecycleRouteExecutionRequest,
    manifest_status_before: Option<String>,
    receipts: Vec<crate::result::ReceiptObservation>,
    error: LifecycleExecutionError,
) -> Result<LifecycleRouteExecutionResult, LifecycleExecutionError> {
    let now = authorization::now_rfc3339();
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
        phase_id: request.phase_id.clone(),
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
    let now = authorization::now_rfc3339();
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
        phase_id: request.phase_id.clone(),
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
