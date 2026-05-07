use crate::lifecycle::{
    lifecycle_execution_request_from_run, run_lifecycle_from_octon_dir,
    update_lifecycle_checkpoint_final_verdict, update_lifecycle_execution_summary,
    LifecycleRunResult, RunLifecycleOptions,
};
use anyhow::{bail, Result};
use octon_core::root::RootResolver;
use octon_lifecycle_executor::{DefaultLifecycleRouteExecutor, LifecycleRouteExecutor};
use std::path::Path;

const DEFAULT_MAX_STEPS: u32 = 20;
const DEFAULT_TIMEOUT_SECONDS: u64 = 1800;

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
    let executor = DefaultLifecycleRouteExecutor::new(repo_root);
    let mut current_run_id = options.run_id.clone();
    let mut last_result = None;
    let max_steps = options.max_steps.unwrap_or(DEFAULT_MAX_STEPS);
    let timeout_seconds = options.timeout_seconds.unwrap_or(DEFAULT_TIMEOUT_SECONDS);

    for step in 0..max_steps {
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
                approval_policy: options.approval_policy.clone(),
                run_inputs: options.run_inputs.clone(),
            },
        )?;
        current_run_id = Some(run.run_id.clone());

        if run.terminal_outcome.is_some()
            || run.selected_route.is_none()
            || matches!(
                run.final_verdict.as_str(),
                "blocked-no-route" | "blocked-gate" | "blocked-max-iterations"
            )
        {
            return Ok(run);
        }

        let Some(request) = lifecycle_execution_request_from_run(
            octon_dir,
            &run,
            options.executor,
            timeout_seconds,
            &options.approval_policy,
            step,
        )?
        else {
            return Ok(run);
        };
        let execution = executor.execute_route(request)?;
        run.route_execution_mode = "adapter-executed".to_string();
        run.final_verdict = execution.status.clone();
        update_lifecycle_checkpoint_final_verdict(octon_dir, &run.run_id, &run.final_verdict)?;
        update_lifecycle_execution_summary(octon_dir, &run, &execution.status)?;

        match execution.status.as_str() {
            "completed" | "no-op" => {
                last_result = Some(run);
                continue;
            }
            "approval-required" | "failed" | "timed-out" | "cancelled" | "blocked" => {
                return Ok(run);
            }
            other => bail!("unsupported lifecycle execution status: {other}"),
        }
    }

    let mut run = last_result.unwrap_or_else(|| LifecycleRunResult {
        schema_version: "octon-lifecycle-run-result-v1".to_string(),
        run_id: current_run_id.unwrap_or_else(|| "unknown".to_string()),
        lifecycle_id: options.lifecycle_id,
        target: options.target.display().to_string(),
        executor: options.executor.as_str().to_string(),
        route_execution_mode: "none".to_string(),
        bundle_root: String::new(),
        checkpoint_path: String::new(),
        selected_route: None,
        terminal_outcome: None,
        final_verdict: "blocked-max-steps".to_string(),
    });
    run.final_verdict = "blocked-max-steps".to_string();
    if run.run_id != "unknown" {
        update_lifecycle_checkpoint_final_verdict(octon_dir, &run.run_id, &run.final_verdict)?;
        update_lifecycle_execution_summary(octon_dir, &run, &run.final_verdict)?;
    }
    Ok(run)
}
