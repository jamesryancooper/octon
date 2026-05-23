use crate::lifecycle::{
    append_lifecycle_event, lifecycle_execution_request_from_run, run_lifecycle_from_octon_dir,
    update_lifecycle_checkpoint_final_verdict, update_lifecycle_execution_summary,
    LifecycleExecutionStrategy, LifecycleRunResult, LifecycleStepBudget, RunLifecycleOptions,
};
use anyhow::{bail, Result};
use octon_core::root::RootResolver;
use octon_lifecycle_executor::{DefaultLifecycleRouteExecutor, LifecycleRouteExecutor};
use std::collections::BTreeMap;
use std::path::{Path, PathBuf};

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
    let executor = DefaultLifecycleRouteExecutor::new(&repo_root);
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
