use crate::lifecycle::{
    append_lifecycle_event, lifecycle_execution_request_from_run, run_lifecycle_from_octon_dir,
    update_lifecycle_checkpoint_final_verdict, update_lifecycle_execution_summary,
    LifecycleExecutionStrategy, LifecycleRunResult, LifecycleStepBudget, RunLifecycleOptions,
};
use crate::pipeline::{self, RunPipelineOptions};
use crate::workflow::ExecutorKind;
use anyhow::{bail, Result};
use octon_core::root::RootResolver;
use octon_lifecycle_executor::{
    observer, DefaultLifecycleRouteExecutor, LifecycleErrorClass, LifecycleExecutionError,
    LifecycleRouteExecutionRequest, LifecycleRouteExecutionResult, LifecycleRouteExecutor,
};
use sha2::{Digest, Sha256};
use std::collections::{BTreeMap, HashMap};
use std::fs;
use std::path::{Path, PathBuf};

const DEFAULT_MAX_STEPS: u32 = 20;
const DEFAULT_TIMEOUT_SECONDS: u64 = 1800;
const MAX_WORKFLOW_RUN_ID_LEN: usize = 128;
const COMPACT_WORKFLOW_RUN_ID_HASH_LEN: usize = 12;

pub(crate) fn run_lifecycle_execute_from_octon_dir(
    octon_dir: &Path,
    options: RunLifecycleOptions,
) -> Result<LifecycleRunResult> {
    let repo_root = octon_dir
        .parent()
        .map(Path::to_path_buf)
        .unwrap_or_else(|| {
            RootResolver::resolve().unwrap_or_else(|_| Path::new(".octon").to_path_buf())
        });
    let workflow_octon_dir = octon_dir.to_path_buf();
    let executor = DefaultLifecycleRouteExecutor::new(&repo_root).with_workflow_runner(
        move |_repo_root, request| execute_workflow_route_in_process(&workflow_octon_dir, request),
    );
    let mut current_run_id = options.run_id.clone();
    let max_steps = options.max_steps.unwrap_or(DEFAULT_MAX_STEPS);
    let mut step_budget = LifecycleStepBudget::new(max_steps);
    let timeout_seconds = options.timeout_seconds.unwrap_or(DEFAULT_TIMEOUT_SECONDS);

    loop {
        let mut run = run_lifecycle_from_octon_dir(
            octon_dir,
            RunLifecycleOptions {
                lifecycle_id: options.lifecycle_id.clone(),
                target: options.target.clone(),
                run_id: current_run_id.clone(),
                executor: options.executor,
                max_iterations: options.max_iterations,
                execute_routes: true,
                max_steps: options.max_steps,
                timeout_seconds: options.timeout_seconds,
                max_child_concurrency: options.max_child_concurrency,
                invocation_authority: options.invocation_authority.clone(),
                run_inputs: options.run_inputs.clone(),
                program_child_filter: options.program_child_filter.clone(),
            },
        )?;
        current_run_id = Some(run.run_id.clone());

        if run.terminal_outcome.is_some()
            || run.selected_route.is_none()
            || matches!(
                run.final_verdict.as_str(),
                "blocked-no-route" | "blocked-gate" | "blocked-max-iterations" | "cancelled"
            )
        {
            return Ok(run);
        }
        if step_budget.exhausted() {
            run.final_verdict = "blocked-max-steps".to_string();
            run.route_execution_mode = "none".to_string();
            update_lifecycle_checkpoint_final_verdict(octon_dir, &run.run_id, &run.final_verdict)?;
            update_lifecycle_execution_summary(octon_dir, &run, &run.final_verdict)?;
            append_packet_event_for_run(
                &repo_root,
                &run,
                "max-steps-exhausted",
                "budget",
                "runtime",
                Some(step_budget.steps_used()),
                Some(step_budget.steps_used().saturating_add(1)),
                Some("no-dispatch"),
                Some("blocked-max-steps"),
                BTreeMap::new(),
            )?;
            return Ok(run);
        }

        let Some(request) = lifecycle_execution_request_from_run(
            octon_dir,
            &run,
            options.executor,
            timeout_seconds,
            &options.invocation_authority,
            step_budget.step_index(),
        )?
        else {
            return Ok(run);
        };
        append_packet_event_for_run(
            &repo_root,
            &run,
            "route-dispatch-started",
            "dispatch",
            "runtime",
            Some(step_budget.step_index()),
            Some(step_budget.step_number()),
            Some("route-dispatch"),
            None,
            BTreeMap::new(),
        )?;
        step_budget.consume_dispatch();
        let execution = executor.execute_route(request)?;
        run.route_execution_mode = "adapter-executed".to_string();
        run.final_verdict = execution.status.clone();
        update_lifecycle_checkpoint_final_verdict(octon_dir, &run.run_id, &run.final_verdict)?;
        update_lifecycle_execution_summary(octon_dir, &run, &execution.status)?;
        let mut event_data = BTreeMap::new();
        event_data.insert("adapter_route_status".to_string(), execution.status.clone());
        append_packet_event_for_run(
            &repo_root,
            &run,
            if execution.status == "human-boundary-blocked" {
                "human-boundary-blocked"
            } else if execution.status == "authorization-proof-failed" {
                "authorization-proof-failed"
            } else if execution.status == "cancelled" {
                "cancelled"
            } else {
                "route-dispatch-finished"
            },
            "dispatch",
            "runtime",
            Some(step_budget.step_index().saturating_sub(1)),
            Some(step_budget.steps_used()),
            Some("route-dispatch"),
            Some(&run.final_verdict),
            event_data,
        )?;

        match execution.status.as_str() {
            "completed" | "no-op" => {
                continue;
            }
            "authorization-proof-failed"
            | "human-boundary-blocked"
            | "failed"
            | "timed-out"
            | "cancelled"
            | "blocked"
            | "executor-preflight-blocked" => {
                return Ok(run);
            }
            other => bail!("unsupported lifecycle execution status: {other}"),
        }
    }
}

#[allow(clippy::too_many_arguments)]
fn append_packet_event_for_run(
    repo_root: &Path,
    run: &LifecycleRunResult,
    event_type: &str,
    event_category: &str,
    actor: &str,
    step_index: Option<u32>,
    step_number: Option<u32>,
    step_kind: Option<&str>,
    final_verdict: Option<&str>,
    mut data: BTreeMap<String, String>,
) -> Result<()> {
    if run.bundle_root.is_empty() || run.checkpoint_path.is_empty() {
        return Ok(());
    }
    let evidence_root = resolve_repo_path(repo_root, Path::new(&run.bundle_root));
    let checkpoint_path = resolve_repo_path(repo_root, Path::new(&run.checkpoint_path));
    let Some(control_root) = checkpoint_path.parent() else {
        return Ok(());
    };
    if let Some(phase_id) = run.current_phase.as_ref() {
        data.insert("phase_id".to_string(), phase_id.clone());
    }
    append_lifecycle_event(
        control_root,
        &evidence_root,
        &run.run_id,
        &run.lifecycle_id,
        LifecycleExecutionStrategy::RouteProgression.as_str(),
        Path::new(&run.target),
        event_type,
        event_category,
        actor,
        step_index,
        step_number,
        step_kind,
        run.selected_route
            .as_ref()
            .map(|route| route.route_id.as_str()),
        None,
        final_verdict,
        data,
    )?;
    Ok(())
}

fn resolve_repo_path(repo_root: &Path, path: &Path) -> PathBuf {
    if path.is_absolute() {
        path.to_path_buf()
    } else {
        repo_root.join(path)
    }
}

fn execute_workflow_route_in_process(
    octon_dir: &Path,
    request: &LifecycleRouteExecutionRequest,
) -> std::result::Result<LifecycleRouteExecutionResult, LifecycleExecutionError> {
    let started_at = now_rfc3339_lifecycle()?;
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
    fs::create_dir_all(&request.evidence_root).map_err(LifecycleExecutionError::from)?;

    let invocation_path = request.evidence_root.join(format!(
        "{}-workflow-in-process-invocation.yml",
        request.route.route_id
    ));
    let terminal_path = request.evidence_root.join(format!(
        "{}-workflow-in-process-terminal.yml",
        request.route.route_id
    ));
    let observation_path = request.evidence_root.join(format!(
        "{}-completion-observation.yml",
        request.route.route_id
    ));
    let workflow_run_id = workflow_in_process_run_id(&request.run_id);
    fs::write(
        &invocation_path,
        format!(
            "schema_version: octon-lifecycle-workflow-in-process-invocation-v1\nrun_id: {}\nroute_id: {}\nworkflow_run_id: {}\nexecutor: {}\nstarted_at: {}\nbound_inputs:\n{}\n",
            request.run_id,
            request.route.route_id,
            workflow_run_id,
            request.executor,
            started_at,
            request
                .bound_inputs
                .iter()
                .map(|(key, value)| format!("  {key}: {}", yaml_string(value)))
                .collect::<Vec<_>>()
                .join("\n")
        ),
    )
    .map_err(LifecycleExecutionError::from)?;

    let pipeline_result = pipeline::run_pipeline_from_octon_dir(
        octon_dir,
        RunPipelineOptions {
            pipeline_id: request.route.route_id.clone(),
            run_id: Some(workflow_run_id.clone()),
            mission_id: None,
            resume_existing: false,
            executor: executor_kind_from_request(request.executor.as_str()),
            executor_bin: None,
            output_slug: None,
            model: None,
            prepare_only: false,
            input_overrides: request
                .bound_inputs
                .iter()
                .map(|(key, value)| (key.clone(), value.clone()))
                .collect::<HashMap<_, _>>(),
        },
    );
    let observation = observer::observe_completion(request, before.clone(), before_target_digest)
        .map_err(LifecycleExecutionError::from)?;
    fs::write(
        &observation_path,
        serde_yaml::to_string(&observation).map_err(LifecycleExecutionError::from)?,
    )
    .map_err(LifecycleExecutionError::from)?;
    let retry_after_target_digest =
        observer::target_digest(&request.target).map_err(LifecycleExecutionError::from)?;

    let (status, error_class, error_message, workflow_bundle, workflow_summary, final_verdict) =
        match pipeline_result {
            Ok(result) if observation.completion_observed => (
                "completed".to_string(),
                None,
                None,
                Some(result.bundle_root),
                Some(result.summary_report),
                Some(result.final_verdict),
            ),
            Ok(result) => (
                "failed".to_string(),
                Some(LifecycleErrorClass::CompletionNotObserved),
                Some("workflow completed but lifecycle completion was not observed".to_string()),
                Some(result.bundle_root),
                Some(result.summary_report),
                Some(result.final_verdict),
            ),
            Err(error) => (
                "failed".to_string(),
                Some(LifecycleErrorClass::ExecutorFailed),
                Some(error.to_string()),
                None,
                None,
                None,
            ),
        };

    let ended_at = now_rfc3339_lifecycle()?;
    fs::write(
        &terminal_path,
        format!(
            "schema_version: octon-lifecycle-workflow-in-process-terminal-v1\nrun_id: {}\nroute_id: {}\nworkflow_run_id: {}\nstatus: {}\nfinal_verdict: {}\nworkflow_bundle: {}\nworkflow_summary: {}\nended_at: {}\nerror_message: {}\n",
            request.run_id,
            request.route.route_id,
            workflow_run_id,
            status,
            final_verdict.as_deref().unwrap_or("none"),
            workflow_bundle
                .as_ref()
                .map(|path| path.display().to_string())
                .unwrap_or_else(|| "none".to_string()),
            workflow_summary
                .as_ref()
                .map(|path| path.display().to_string())
                .unwrap_or_else(|| "none".to_string()),
            ended_at,
            error_message
                .as_deref()
                .map(yaml_string)
                .unwrap_or_else(|| "null".to_string())
        ),
    )
    .map_err(LifecycleExecutionError::from)?;

    let retryable = matches!(
        &error_class,
        Some(LifecycleErrorClass::ExecutorFailed)
            | Some(LifecycleErrorClass::ExecutorUnavailable)
            | Some(LifecycleErrorClass::Timeout)
    ) && before == observation.manifest_status_after
        && retry_before_target_digest == retry_after_target_digest;
    let mut evidence_paths = vec![invocation_path, terminal_path, observation_path];
    if let Some(path) = workflow_bundle {
        evidence_paths.push(path);
    }
    if let Some(path) = workflow_summary {
        evidence_paths.push(path);
    }

    Ok(LifecycleRouteExecutionResult {
        schema_version: "octon-lifecycle-route-execution-result-v1".to_string(),
        run_id: request.run_id.clone(),
        route_id: request.route.route_id.clone(),
        phase_id: request.phase_id.clone(),
        executor_used: "workflow-in-process".to_string(),
        status: status.clone(),
        started_at,
        ended_at,
        manifest_status_before: before,
        manifest_status_after: observation.manifest_status_after,
        receipts_observed: observation.receipts_observed,
        evidence_paths,
        stdout_path: None,
        stderr_path: None,
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

fn executor_kind_from_request(raw: &str) -> ExecutorKind {
    match raw {
        "mock" => ExecutorKind::Mock,
        "codex" => ExecutorKind::Codex,
        "claude" => ExecutorKind::Claude,
        _ => ExecutorKind::Auto,
    }
}

fn workflow_in_process_run_id(request_run_id: &str) -> String {
    let requested = format!("{request_run_id}-workflow");
    let canonical = canonical_workflow_run_id(&requested);
    if canonical.len() <= MAX_WORKFLOW_RUN_ID_LEN {
        return canonical;
    }
    compact_workflow_run_id(&canonical, &requested)
}

fn canonical_workflow_run_id(input: &str) -> String {
    let mut out = String::with_capacity(input.len());
    let mut last_was_hyphen = false;
    for ch in input.chars() {
        let mapped = if ch.is_ascii_alphanumeric() {
            ch.to_ascii_lowercase()
        } else {
            '-'
        };
        if mapped == '-' {
            if !out.is_empty() && !last_was_hyphen {
                out.push('-');
                last_was_hyphen = true;
            }
        } else {
            out.push(mapped);
            last_was_hyphen = false;
        }
    }
    while out.ends_with('-') {
        out.pop();
    }
    if out.is_empty() {
        "workflow".to_string()
    } else {
        out
    }
}

fn compact_workflow_run_id(canonical: &str, requested: &str) -> String {
    let digest = hex::encode(Sha256::digest(requested.as_bytes()));
    let suffix = format!("-workflow-{}", &digest[..COMPACT_WORKFLOW_RUN_ID_HASH_LEN]);
    let max_prefix_len = MAX_WORKFLOW_RUN_ID_LEN.saturating_sub(suffix.len());
    let mut prefix = canonical.chars().take(max_prefix_len).collect::<String>();
    while prefix.ends_with('-') {
        prefix.pop();
    }
    if prefix.is_empty() {
        prefix.push_str("workflow");
    }
    format!("{prefix}{suffix}")
}

fn now_rfc3339_lifecycle() -> std::result::Result<String, LifecycleExecutionError> {
    time::OffsetDateTime::now_utc()
        .format(&time::format_description::well_known::Rfc3339)
        .map_err(|error| LifecycleExecutionError::new(LifecycleErrorClass::Io, error.to_string()))
}

fn yaml_string(value: &str) -> String {
    serde_yaml::to_string(value)
        .map(|value| value.trim().to_string())
        .unwrap_or_else(|_| format!("{value:?}"))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn in_process_workflow_run_id_preserves_short_canonical_ids() {
        assert_eq!(
            workflow_in_process_run_id("lifecycle-test"),
            "lifecycle-test-workflow"
        );
    }

    #[test]
    fn in_process_workflow_run_id_compacts_long_lifecycle_ids() {
        let run_id = "lifecycle-proposal-program-operator-free-lifecycle-delivery-autonomy-hardening-20260620t132759z-proposal-program-execution-mode-normalization-direct-check";
        let workflow_run_id = workflow_in_process_run_id(run_id);

        assert!(workflow_run_id.len() <= MAX_WORKFLOW_RUN_ID_LEN);
        assert!(workflow_run_id
            .chars()
            .all(|ch| ch.is_ascii_lowercase() || ch.is_ascii_digit() || ch == '-'));
        assert!(workflow_run_id.contains("-workflow-"));
        assert_ne!(workflow_run_id, format!("{run_id}-workflow"));
    }
}
