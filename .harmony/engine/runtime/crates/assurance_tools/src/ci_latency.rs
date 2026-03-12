use anyhow::{bail, Context, Result};
use clap::{Args, Subcommand};
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::cmp::Ordering;
use std::collections::{BTreeMap, HashMap, HashSet};
use std::fs;
use std::path::{Path, PathBuf};
use time::format_description::well_known::Rfc3339;
use time::OffsetDateTime;

#[derive(Args, Debug)]
pub(crate) struct CiLatencyArgs {
    #[command(subcommand)]
    command: CiLatencyCommand,
}

#[derive(Subcommand, Debug)]
enum CiLatencyCommand {
    Analyze(CiLatencyAnalyzeArgs),
    RenderMarkdown(CiLatencyRenderMarkdownArgs),
}

#[derive(Args, Debug)]
struct CiLatencyAnalyzeArgs {
    #[arg(long)]
    policy: PathBuf,

    #[arg(long)]
    runs: PathBuf,

    #[arg(long)]
    jobs: PathBuf,

    #[arg(long = "workflow-scan")]
    workflow_scan: PathBuf,

    #[arg(long = "output-json")]
    output_json: PathBuf,

    #[arg(long = "output-markdown")]
    output_markdown: Option<PathBuf>,
}

#[derive(Args, Debug)]
struct CiLatencyRenderMarkdownArgs {
    #[arg(long)]
    summary: PathBuf,

    #[arg(long = "output-markdown")]
    output_markdown: PathBuf,
}

#[derive(Clone, Debug, Deserialize)]
struct LatencyPolicy {
    #[serde(default)]
    required_checks: Vec<String>,
    #[serde(default)]
    required_checks_contract_path: Option<PathBuf>,
    #[serde(default = "default_window_runs")]
    window_runs: usize,
    #[serde(default = "default_bucket_size")]
    newest_bucket: usize,
    #[serde(default = "default_bucket_size")]
    previous_bucket: usize,
    #[serde(default = "default_minimum_bucket_samples")]
    minimum_bucket_samples: usize,
    #[serde(default = "default_required_path_median_seconds")]
    required_path_median_seconds: i64,
    #[serde(default = "default_required_path_p90_seconds")]
    required_path_p90_seconds: i64,
    #[serde(default = "default_workflow_regression_percent")]
    workflow_regression_percent: f64,
    #[serde(default = "default_duplicate_work_cumulative_seconds")]
    duplicate_work_cumulative_seconds: i64,
    #[serde(default = "default_top_workflows")]
    top_workflows: usize,
    #[serde(default = "default_issue_title")]
    issue_title: String,
    #[serde(default = "default_issue_label")]
    issue_label: String,
}

#[derive(Clone, Debug, Deserialize)]
struct RequiredChecksContract {
    rulesets: ContractRulesets,
}

#[derive(Clone, Debug, Deserialize)]
struct ContractRulesets {
    main: ContractMainRuleset,
}

#[derive(Clone, Debug, Deserialize)]
struct ContractMainRuleset {
    required_checks: Vec<String>,
}

#[derive(Clone, Debug, Deserialize)]
struct RawRunRecord {
    workflow_name: String,
    event: String,
    #[serde(default)]
    conclusion: Option<String>,
    #[serde(default)]
    head_sha: Option<String>,
    created_at: String,
    duration_seconds: f64,
    #[serde(default)]
    run_id: Option<u64>,
}

#[derive(Clone, Debug, Deserialize)]
struct RawJobsBundle {
    workflow_name: String,
    jobs: Vec<RawJobRecord>,
}

#[derive(Clone, Debug, Deserialize)]
struct RawJobRecord {
    #[serde(alias = "name")]
    job_name: String,
    steps: Vec<RawStepRecord>,
}

#[derive(Clone, Debug, Deserialize)]
struct RawStepRecord {
    #[serde(alias = "name")]
    step_name: String,
    #[serde(default)]
    duration_seconds: Option<f64>,
    #[serde(default)]
    started_at: Option<String>,
    #[serde(default)]
    completed_at: Option<String>,
}

#[derive(Clone, Debug, Deserialize)]
struct RawWorkflowScan {
    #[serde(default)]
    duplicates: Vec<RawDuplicateRecord>,
}

#[derive(Clone, Debug, Deserialize)]
struct RawDuplicateRecord {
    key: String,
    category: String,
    workflows: Vec<String>,
    occurrences: usize,
    total_estimated_seconds: f64,
    #[serde(default)]
    summary: Option<String>,
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
struct SummaryOutput {
    status: String,
    issue_action: String,
    issue_title: String,
    issue_label: String,
    window: WindowSummary,
    required_path: RequiredPathSummary,
    workflow_metrics: Vec<WorkflowMetricSummary>,
    step_hotspots: Vec<StepHotspotSummary>,
    duplicate_work_candidates: Vec<DuplicateWorkCandidateSummary>,
    recommendations: Vec<RecommendationSummary>,
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
struct WindowSummary {
    window_runs: usize,
    newest_bucket: usize,
    previous_bucket: usize,
    minimum_bucket_samples: usize,
    runs_considered: usize,
    complete_required_sets: usize,
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
struct RequiredPathSummary {
    required_checks: Vec<String>,
    sample_count: usize,
    median_seconds: Option<i64>,
    p90_seconds: Option<i64>,
    target_median_seconds: i64,
    target_p90_seconds: i64,
    recent_median_seconds: Option<i64>,
    previous_median_seconds: Option<i64>,
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
struct WorkflowMetricSummary {
    workflow_name: String,
    status: String,
    run_count: usize,
    median_seconds: i64,
    regression_percent: Option<f64>,
    latest_success_run_id: Option<u64>,
    recent_median_seconds: Option<i64>,
    previous_median_seconds: Option<i64>,
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
struct StepHotspotSummary {
    workflow_name: String,
    step_name: String,
    sample_count: usize,
    median_seconds: i64,
    max_seconds: i64,
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
struct DuplicateWorkCandidateSummary {
    key: String,
    category: String,
    severity: String,
    workflows: Vec<String>,
    occurrences: usize,
    total_estimated_seconds: i64,
    summary: String,
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
struct RecommendationSummary {
    id: String,
    severity: String,
    category: String,
    summary: String,
    why: String,
    targets: Vec<String>,
}

#[derive(Clone, Debug)]
struct RequiredPathSet {
    created_at: String,
    duration_seconds: f64,
}

#[derive(Clone, Debug)]
struct StepAccumulator {
    durations: Vec<f64>,
    max_duration: f64,
}

pub(crate) fn run(args: CiLatencyArgs) -> Result<()> {
    match args.command {
        CiLatencyCommand::Analyze(args) => run_analyze(args),
        CiLatencyCommand::RenderMarkdown(args) => run_render_markdown(args),
    }
}

fn run_analyze(args: CiLatencyAnalyzeArgs) -> Result<()> {
    let policy = load_policy(&args.policy)?;
    let required_checks = load_required_checks(&policy)?;
    let runs = load_runs(&args.runs)?;
    let jobs = load_jobs(&args.jobs)?;
    let workflow_scan = load_workflow_scan(&args.workflow_scan)?;

    let summary = build_summary(&policy, required_checks, runs, jobs, workflow_scan)?;
    write_json(&args.output_json, &summary)?;
    if let Some(path) = args.output_markdown.as_ref() {
        let markdown = render_markdown(&summary);
        write_text(path, &markdown)?;
    }
    Ok(())
}

fn run_render_markdown(args: CiLatencyRenderMarkdownArgs) -> Result<()> {
    let summary = load_summary(&args.summary)?;
    let markdown = render_markdown(&summary);
    write_text(&args.output_markdown, &markdown)?;
    Ok(())
}

fn load_policy(path: &Path) -> Result<LatencyPolicy> {
    let text = fs::read_to_string(path)
        .with_context(|| format!("failed to read latency policy at {}", path.display()))?;
    serde_json::from_str(&text)
        .with_context(|| format!("failed to parse latency policy at {}", path.display()))
}

fn load_required_checks(policy: &LatencyPolicy) -> Result<Vec<String>> {
    if !policy.required_checks.is_empty() {
        return Ok(policy.required_checks.clone());
    }

    let Some(contract_path) = policy.required_checks_contract_path.as_ref() else {
        bail!("latency policy must declare either `required_checks` or `required_checks_contract_path`");
    };

    let text = fs::read_to_string(contract_path).with_context(|| {
        format!(
            "failed to read required checks contract at {}",
            contract_path.display()
        )
    })?;
    let contract: RequiredChecksContract = serde_json::from_str(&text).with_context(|| {
        format!(
            "failed to parse required checks contract at {}",
            contract_path.display()
        )
    })?;
    if contract.rulesets.main.required_checks.is_empty() {
        bail!(
            "required checks contract {} does not declare any required checks",
            contract_path.display()
        );
    }
    Ok(contract.rulesets.main.required_checks)
}

fn load_runs(path: &Path) -> Result<Vec<RawRunRecord>> {
    let value = load_json_value(path)?;
    if let Some(items) = value.get("workflow_runs").and_then(Value::as_array) {
        return deserialize_vec(items.clone())
            .with_context(|| format!("failed to parse workflow_runs in {}", path.display()));
    }
    if let Some(items) = value.as_array() {
        return deserialize_vec(items.clone())
            .with_context(|| format!("failed to parse runs array in {}", path.display()));
    }
    bail!(
        "raw runs JSON at {} must be an array or contain workflow_runs",
        path.display()
    )
}

fn load_jobs(path: &Path) -> Result<Vec<RawJobsBundle>> {
    let value = load_json_value(path)?;
    if let Some(items) = value.get("job_bundles").and_then(Value::as_array) {
        return deserialize_vec(items.clone())
            .with_context(|| format!("failed to parse job_bundles in {}", path.display()));
    }
    if let Some(items) = value.as_array() {
        return deserialize_vec(items.clone())
            .with_context(|| format!("failed to parse jobs array in {}", path.display()));
    }
    bail!(
        "raw jobs JSON at {} must be an array or contain job_bundles",
        path.display()
    )
}

fn load_workflow_scan(path: &Path) -> Result<Vec<RawDuplicateRecord>> {
    let value = load_json_value(path)?;
    if value.is_array() {
        return deserialize_vec(value.as_array().cloned().unwrap_or_default())
            .with_context(|| format!("failed to parse workflow scan array in {}", path.display()));
    }
    let scan: RawWorkflowScan = serde_json::from_value(value)
        .with_context(|| format!("failed to parse workflow scan object in {}", path.display()))?;
    Ok(scan.duplicates)
}

fn load_summary(path: &Path) -> Result<SummaryOutput> {
    let text = fs::read_to_string(path)
        .with_context(|| format!("failed to read summary JSON at {}", path.display()))?;
    serde_json::from_str(&text)
        .with_context(|| format!("failed to parse summary JSON at {}", path.display()))
}

fn deserialize_vec<T>(items: Vec<Value>) -> Result<Vec<T>>
where
    T: for<'de> Deserialize<'de>,
{
    items
        .into_iter()
        .map(serde_json::from_value)
        .collect::<std::result::Result<Vec<T>, _>>()
        .map_err(Into::into)
}

fn load_json_value(path: &Path) -> Result<Value> {
    let text = fs::read_to_string(path)
        .with_context(|| format!("failed to read JSON input at {}", path.display()))?;
    serde_json::from_str(&text)
        .with_context(|| format!("failed to parse JSON input at {}", path.display()))
}

fn write_json(path: &Path, summary: &SummaryOutput) -> Result<()> {
    ensure_parent(path)?;
    let rendered = serde_json::to_string_pretty(summary)?;
    fs::write(path, rendered)
        .with_context(|| format!("failed to write JSON summary to {}", path.display()))
}

fn write_text(path: &Path, body: &str) -> Result<()> {
    ensure_parent(path)?;
    fs::write(path, body).with_context(|| format!("failed to write markdown to {}", path.display()))
}

fn ensure_parent(path: &Path) -> Result<()> {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)
            .with_context(|| format!("failed to create parent directory {}", parent.display()))?;
    }
    Ok(())
}

fn build_summary(
    policy: &LatencyPolicy,
    required_checks: Vec<String>,
    runs: Vec<RawRunRecord>,
    jobs: Vec<RawJobsBundle>,
    workflow_scan: Vec<RawDuplicateRecord>,
) -> Result<SummaryOutput> {
    let required_path_sets = build_required_path_sets(&runs, &required_checks);
    let required_path = summarize_required_path(policy, &required_checks, &required_path_sets);
    let workflow_metrics = summarize_workflows(policy, &runs);
    let top_workflow_names: HashSet<String> = workflow_metrics
        .iter()
        .take(policy.top_workflows)
        .map(|item| item.workflow_name.clone())
        .collect();
    let step_hotspots = summarize_step_hotspots(&jobs, &top_workflow_names, policy.top_workflows);
    let duplicate_work_candidates = summarize_duplicate_work(policy, workflow_scan);

    let recommendations = generate_recommendations(
        policy,
        &required_path,
        &workflow_metrics,
        &step_hotspots,
        &duplicate_work_candidates,
    );
    let status = classify_status(
        &required_path,
        &workflow_metrics,
        &duplicate_work_candidates,
    );
    let issue_action = match status.as_str() {
        "breach" => "open_or_update",
        "watch" => "update_if_open",
        _ => "close_if_open",
    }
    .to_string();

    Ok(SummaryOutput {
        status,
        issue_action,
        issue_title: policy.issue_title.clone(),
        issue_label: policy.issue_label.clone(),
        window: WindowSummary {
            window_runs: policy.window_runs,
            newest_bucket: policy.newest_bucket,
            previous_bucket: policy.previous_bucket,
            minimum_bucket_samples: policy.minimum_bucket_samples,
            runs_considered: count_successful_pr_like_runs(&runs),
            complete_required_sets: required_path_sets.len(),
        },
        required_path,
        workflow_metrics,
        step_hotspots,
        duplicate_work_candidates,
        recommendations,
    })
}

fn build_required_path_sets(
    runs: &[RawRunRecord],
    required_checks: &[String],
) -> Vec<RequiredPathSet> {
    let required_set: HashSet<&str> = required_checks.iter().map(String::as_str).collect();
    let mut grouped: BTreeMap<String, HashMap<String, RawRunRecord>> = BTreeMap::new();

    for run in runs
        .iter()
        .filter(|run| run.event == "pull_request")
        .filter(|run| run.conclusion.as_deref() == Some("success"))
        .filter(|run| required_set.contains(run.workflow_name.as_str()))
    {
        let Some(head_sha) = run.head_sha.as_ref() else {
            continue;
        };
        let by_workflow = grouped.entry(head_sha.clone()).or_default();
        match by_workflow.get(&run.workflow_name) {
            Some(existing) if existing.created_at >= run.created_at => {}
            _ => {
                by_workflow.insert(run.workflow_name.clone(), run.clone());
            }
        }
    }

    let mut sets: Vec<RequiredPathSet> = grouped
        .into_iter()
        .filter_map(|(_head_sha, by_workflow)| {
            let available: HashSet<&str> = by_workflow.keys().map(String::as_str).collect();
            if required_set != available {
                return None;
            }
            let created_at = by_workflow
                .values()
                .map(|item| item.created_at.clone())
                .max()
                .unwrap_or_default();
            let duration_seconds = by_workflow
                .values()
                .map(|item| item.duration_seconds)
                .fold(0.0_f64, f64::max);
            Some(RequiredPathSet {
                created_at,
                duration_seconds,
            })
        })
        .collect();

    sets.sort_by(|left, right| right.created_at.cmp(&left.created_at));
    sets
}

fn summarize_required_path(
    policy: &LatencyPolicy,
    required_checks: &[String],
    sets: &[RequiredPathSet],
) -> RequiredPathSummary {
    let durations = collect_seconds(sets.iter().map(|item| item.duration_seconds));
    let recent_durations = collect_seconds(
        sets.iter()
            .take(policy.newest_bucket)
            .map(|item| item.duration_seconds),
    );
    let previous_durations = collect_seconds(
        sets.iter()
            .skip(policy.newest_bucket)
            .take(policy.previous_bucket)
            .map(|item| item.duration_seconds),
    );

    RequiredPathSummary {
        required_checks: required_checks.to_vec(),
        sample_count: sets.len(),
        median_seconds: rounded_optional(median(&durations)),
        p90_seconds: rounded_optional(percentile(&durations, 0.90)),
        target_median_seconds: policy.required_path_median_seconds,
        target_p90_seconds: policy.required_path_p90_seconds,
        recent_median_seconds: rounded_optional(median(&recent_durations)),
        previous_median_seconds: rounded_optional(median(&previous_durations)),
    }
}

fn summarize_workflows(
    policy: &LatencyPolicy,
    runs: &[RawRunRecord],
) -> Vec<WorkflowMetricSummary> {
    let mut grouped: BTreeMap<String, Vec<&RawRunRecord>> = BTreeMap::new();
    for run in runs
        .iter()
        .filter(|run| matches!(run.event.as_str(), "pull_request" | "pull_request_target"))
        .filter(|run| run.conclusion.as_deref() == Some("success"))
    {
        grouped
            .entry(run.workflow_name.clone())
            .or_default()
            .push(run);
    }

    let mut summaries: Vec<WorkflowMetricSummary> = grouped
        .into_iter()
        .map(|(workflow_name, mut items)| {
            items.sort_by(|left, right| right.created_at.cmp(&left.created_at));
            let latest_success_run_id = items.first().and_then(|item| item.run_id);
            let durations = collect_seconds(items.iter().map(|item| item.duration_seconds));
            let recent = collect_seconds(
                items
                    .iter()
                    .take(policy.newest_bucket)
                    .map(|item| item.duration_seconds),
            );
            let previous = collect_seconds(
                items
                    .iter()
                    .skip(policy.newest_bucket)
                    .take(policy.previous_bucket)
                    .map(|item| item.duration_seconds),
            );
            let recent_median = median(&recent);
            let previous_median = median(&previous);
            let regression_percent =
                match (recent.len(), previous.len(), recent_median, previous_median) {
                    (recent_len, previous_len, Some(new_value), Some(previous_value))
                        if recent_len >= policy.minimum_bucket_samples
                            && previous_len >= policy.minimum_bucket_samples
                            && previous_value > 0.0 =>
                    {
                        Some(round_percent(
                            ((new_value - previous_value) / previous_value) * 100.0,
                        ))
                    }
                    _ => None,
                };
            let regression_status = match regression_percent {
                Some(value) if value >= policy.workflow_regression_percent => "breach",
                Some(value) if value > 0.0 => "watch",
                Some(_) => "stable",
                None => "insufficient-data",
            }
            .to_string();

            WorkflowMetricSummary {
                workflow_name,
                status: regression_status,
                run_count: items.len(),
                median_seconds: round_seconds(median(&durations).unwrap_or(0.0)),
                regression_percent,
                latest_success_run_id,
                recent_median_seconds: rounded_optional(recent_median),
                previous_median_seconds: rounded_optional(previous_median),
            }
        })
        .collect();

    summaries.sort_by(|left, right| workflow_metric_cmp(left, right));
    summaries
}

fn summarize_step_hotspots(
    jobs: &[RawJobsBundle],
    top_workflow_names: &HashSet<String>,
    top_limit: usize,
) -> Vec<StepHotspotSummary> {
    let mut buckets: BTreeMap<(String, String), StepAccumulator> = BTreeMap::new();
    for bundle in jobs
        .iter()
        .filter(|bundle| top_workflow_names.contains(&bundle.workflow_name))
    {
        for job in &bundle.jobs {
            for step in &job.steps {
                let Some(duration_seconds) = step_duration_seconds(step) else {
                    continue;
                };
                let key = (
                    bundle.workflow_name.clone(),
                    format!("{} / {}", job.job_name, step.step_name),
                );
                let entry = buckets.entry(key).or_insert_with(|| StepAccumulator {
                    durations: Vec::new(),
                    max_duration: 0.0,
                });
                entry.durations.push(duration_seconds);
                entry.max_duration = entry.max_duration.max(duration_seconds);
            }
        }
    }

    let mut summaries: Vec<StepHotspotSummary> = buckets
        .into_iter()
        .map(|((workflow_name, step_name), acc)| StepHotspotSummary {
            workflow_name,
            step_name,
            sample_count: acc.durations.len(),
            median_seconds: round_seconds(
                median(&collect_seconds(acc.durations.iter().copied())).unwrap_or(0.0),
            ),
            max_seconds: round_seconds(acc.max_duration),
        })
        .collect();

    summaries.sort_by(|left, right| {
        right
            .median_seconds
            .cmp(&left.median_seconds)
            .then_with(|| left.workflow_name.cmp(&right.workflow_name))
            .then_with(|| left.step_name.cmp(&right.step_name))
    });
    summaries.truncate(top_limit);
    summaries
}

fn summarize_duplicate_work(
    policy: &LatencyPolicy,
    workflow_scan: Vec<RawDuplicateRecord>,
) -> Vec<DuplicateWorkCandidateSummary> {
    let mut candidates: Vec<DuplicateWorkCandidateSummary> = workflow_scan
        .into_iter()
        .filter(|item| item.occurrences >= 2)
        .map(|item| {
            let total_estimated_seconds = round_seconds(item.total_estimated_seconds);
            let severity = if total_estimated_seconds >= policy.duplicate_work_cumulative_seconds {
                "high"
            } else {
                "medium"
            }
            .to_string();
            let summary = item.summary.unwrap_or_else(|| {
                format!(
                    "{} repeated across {} workflows",
                    item.key,
                    item.workflows.len()
                )
            });
            DuplicateWorkCandidateSummary {
                key: item.key,
                category: item.category,
                severity,
                workflows: item.workflows,
                occurrences: item.occurrences,
                total_estimated_seconds,
                summary,
            }
        })
        .collect();

    candidates.sort_by(|left, right| {
        severity_rank(&right.severity)
            .cmp(&severity_rank(&left.severity))
            .then_with(|| {
                right
                    .total_estimated_seconds
                    .cmp(&left.total_estimated_seconds)
            })
            .then_with(|| left.key.cmp(&right.key))
    });
    candidates
}

fn generate_recommendations(
    policy: &LatencyPolicy,
    required_path: &RequiredPathSummary,
    workflow_metrics: &[WorkflowMetricSummary],
    step_hotspots: &[StepHotspotSummary],
    duplicate_work_candidates: &[DuplicateWorkCandidateSummary],
) -> Vec<RecommendationSummary> {
    let mut recommendations = Vec::new();

    if required_path
        .median_seconds
        .is_some_and(|value| value > policy.required_path_median_seconds)
    {
        recommendations.push(RecommendationSummary {
            id: "required-path-over-budget".to_string(),
            severity: "high".to_string(),
            category: "required-path".to_string(),
            summary: format!(
                "Required PR path median is {}s over the {}s target.",
                required_path.median_seconds.unwrap_or_default(),
                policy.required_path_median_seconds
            ),
            why: "Required checks are exceeding the repo latency objective.".to_string(),
            targets: required_path.required_checks.clone(),
        });
    }

    if required_path
        .p90_seconds
        .is_some_and(|value| value > policy.required_path_p90_seconds)
    {
        recommendations.push(RecommendationSummary {
            id: "required-path-tail-over-budget".to_string(),
            severity: "high".to_string(),
            category: "required-path".to_string(),
            summary: format!(
                "Required PR path p90 is {}s over the {}s tail target.",
                required_path.p90_seconds.unwrap_or_default(),
                policy.required_path_p90_seconds
            ),
            why: "Tail latency is too high even when the median is acceptable.".to_string(),
            targets: required_path.required_checks.clone(),
        });
    }

    for workflow in workflow_metrics
        .iter()
        .filter(|workflow| workflow.status == "breach" || workflow.status == "watch")
        .take(policy.top_workflows)
    {
        recommendations.push(RecommendationSummary {
            id: format!("workflow-regression-{}", slugify(&workflow.workflow_name)),
            severity: if workflow.status == "breach" {
                "high".to_string()
            } else {
                "medium".to_string()
            },
            category: "workflow-regression".to_string(),
            summary: match workflow.regression_percent {
                Some(percent) => format!(
                    "{} median regressed by {}% (recent={}s, previous={}s).",
                    workflow.workflow_name,
                    percent,
                    workflow.recent_median_seconds.unwrap_or_default(),
                    workflow.previous_median_seconds.unwrap_or_default()
                ),
                None => format!("{} shows unstable latency and needs review.", workflow.workflow_name),
            },
            why: "Workflow-level regressions usually signal duplicated setup, missing path scoping, or expanded validation scope.".to_string(),
            targets: vec![workflow.workflow_name.clone()],
        });
    }

    for hotspot in step_hotspots
        .iter()
        .filter(|item| item.median_seconds >= 90)
        .take(3)
    {
        recommendations.push(RecommendationSummary {
            id: format!(
                "step-hotspot-{}-{}",
                slugify(&hotspot.workflow_name),
                slugify(&hotspot.step_name)
            ),
            severity: "medium".to_string(),
            category: "step-hotspot".to_string(),
            summary: format!(
                "{} has a repeated hotspot in `{}` at {}s median.",
                hotspot.workflow_name, hotspot.step_name, hotspot.median_seconds
            ),
            why: "Step-level hotspots are good consolidation or caching candidates.".to_string(),
            targets: vec![hotspot.workflow_name.clone(), hotspot.step_name.clone()],
        });
    }

    for duplicate in duplicate_work_candidates.iter().take(3) {
        recommendations.push(RecommendationSummary {
            id: format!("duplicate-work-{}", slugify(&duplicate.key)),
            severity: duplicate.severity.clone(),
            category: "duplicate-work".to_string(),
            summary: format!(
                "{} repeats across {} workflows and costs about {}s.",
                duplicate.key,
                duplicate.workflows.len(),
                duplicate.total_estimated_seconds
            ),
            why: "Repeated heavyweight setup is the clearest tightening target in a report-only control loop.".to_string(),
            targets: duplicate.workflows.clone(),
        });
    }

    recommendations.sort_by(|left, right| {
        severity_rank(&right.severity)
            .cmp(&severity_rank(&left.severity))
            .then_with(|| left.id.cmp(&right.id))
    });
    recommendations
}

fn classify_status(
    required_path: &RequiredPathSummary,
    workflow_metrics: &[WorkflowMetricSummary],
    duplicate_work_candidates: &[DuplicateWorkCandidateSummary],
) -> String {
    if required_path.sample_count == 0 {
        return "watch".to_string();
    }

    let workflow_breach = workflow_metrics
        .iter()
        .any(|workflow| workflow.status == "breach");
    let duplicate_breach = duplicate_work_candidates
        .iter()
        .any(|item| item.severity == "high");
    let required_breach = required_path
        .median_seconds
        .is_some_and(|value| value > required_path.target_median_seconds)
        || required_path
            .p90_seconds
            .is_some_and(|value| value > required_path.target_p90_seconds);
    if workflow_breach || duplicate_breach || required_breach {
        return "breach".to_string();
    }

    let workflow_watch = workflow_metrics
        .iter()
        .any(|workflow| workflow.status == "watch");
    let duplicate_watch = !duplicate_work_candidates.is_empty();
    if workflow_watch || duplicate_watch {
        return "watch".to_string();
    }

    "healthy".to_string()
}

fn count_successful_pr_like_runs(runs: &[RawRunRecord]) -> usize {
    runs.iter()
        .filter(|run| matches!(run.event.as_str(), "pull_request" | "pull_request_target"))
        .filter(|run| run.conclusion.as_deref() == Some("success"))
        .count()
}

fn collect_seconds<I>(iter: I) -> Vec<f64>
where
    I: IntoIterator<Item = f64>,
{
    let mut values: Vec<f64> = iter.into_iter().collect();
    values.sort_by(cmp_f64);
    values
}

fn median(values: &[f64]) -> Option<f64> {
    if values.is_empty() {
        return None;
    }
    let mid = values.len() / 2;
    if values.len() % 2 == 1 {
        Some(values[mid])
    } else {
        Some((values[mid - 1] + values[mid]) / 2.0)
    }
}

fn percentile(values: &[f64], quantile: f64) -> Option<f64> {
    if values.is_empty() {
        return None;
    }
    let rank = ((quantile * values.len() as f64).ceil() as usize).saturating_sub(1);
    values.get(rank).copied().or_else(|| values.last().copied())
}

fn rounded_optional(value: Option<f64>) -> Option<i64> {
    value.map(round_seconds)
}

fn round_seconds(value: f64) -> i64 {
    value.round() as i64
}

fn round_percent(value: f64) -> f64 {
    (value * 10.0).round() / 10.0
}

fn cmp_f64(left: &f64, right: &f64) -> Ordering {
    left.partial_cmp(right).unwrap_or(Ordering::Equal)
}

fn workflow_metric_cmp(left: &WorkflowMetricSummary, right: &WorkflowMetricSummary) -> Ordering {
    severity_rank(&right.status)
        .cmp(&severity_rank(&left.status))
        .then_with(|| right.median_seconds.cmp(&left.median_seconds))
        .then_with(|| {
            right
                .regression_percent
                .unwrap_or(0.0)
                .partial_cmp(&left.regression_percent.unwrap_or(0.0))
                .unwrap_or(Ordering::Equal)
        })
        .then_with(|| left.workflow_name.cmp(&right.workflow_name))
}

fn step_duration_seconds(step: &RawStepRecord) -> Option<f64> {
    if let Some(duration) = step.duration_seconds {
        return Some(duration);
    }
    let started_at = step.started_at.as_deref()?;
    let completed_at = step.completed_at.as_deref()?;
    let started = OffsetDateTime::parse(started_at, &Rfc3339).ok()?;
    let completed = OffsetDateTime::parse(completed_at, &Rfc3339).ok()?;
    let duration = completed - started;
    Some(duration.whole_seconds().max(0) as f64)
}

fn severity_rank(value: &str) -> i32 {
    match value {
        "high" | "breach" => 3,
        "medium" | "watch" => 2,
        "stable" => 1,
        "healthy" => 0,
        "insufficient-data" => -1,
        _ => 0,
    }
}

fn slugify(value: &str) -> String {
    let mut slug = String::new();
    let mut last_dash = false;
    for ch in value.chars() {
        if ch.is_ascii_alphanumeric() {
            slug.push(ch.to_ascii_lowercase());
            last_dash = false;
        } else if !last_dash {
            slug.push('-');
            last_dash = true;
        }
    }
    slug.trim_matches('-').to_string()
}

fn render_markdown(summary: &SummaryOutput) -> String {
    let mut out = String::new();
    out.push_str("# CI Latency Audit\n\n");
    out.push_str(&format!(
        "- Status: `{}`\n- Issue action: `{}`\n- Required-path sample count: `{}`\n\n",
        summary.status, summary.issue_action, summary.required_path.sample_count
    ));

    out.push_str("## Required Path\n\n");
    out.push_str(&format!(
        "- Median: `{}` / target `{}`\n- P90: `{}` / target `{}`\n",
        optional_seconds(summary.required_path.median_seconds),
        summary.required_path.target_median_seconds,
        optional_seconds(summary.required_path.p90_seconds),
        summary.required_path.target_p90_seconds
    ));
    if let Some(value) = summary.required_path.recent_median_seconds {
        out.push_str(&format!(
            "- Recent median: `{}` vs previous `{}`\n",
            value,
            optional_seconds(summary.required_path.previous_median_seconds)
        ));
    }
    out.push('\n');

    out.push_str("## Workflow Metrics\n\n");
    if summary.workflow_metrics.is_empty() {
        out.push_str("No successful workflow samples were available.\n\n");
    } else {
        out.push_str("| Workflow | Samples | Median (s) | Recent (s) | Previous (s) | Regression % | Status |\n");
        out.push_str("| --- | ---: | ---: | ---: | ---: | ---: | --- |\n");
        for workflow in &summary.workflow_metrics {
            out.push_str(&format!(
                "| {} | {} | {} | {} | {} | {} | {} |\n",
                workflow.workflow_name,
                workflow.run_count,
                workflow.median_seconds,
                optional_seconds(workflow.recent_median_seconds),
                optional_seconds(workflow.previous_median_seconds),
                workflow
                    .regression_percent
                    .map(|value| value.to_string())
                    .unwrap_or_else(|| "n/a".to_string()),
                workflow.status
            ));
        }
        out.push('\n');
    }

    out.push_str("## Step Hotspots\n\n");
    if summary.step_hotspots.is_empty() {
        out.push_str("No step hotspot data was available.\n\n");
    } else {
        for hotspot in &summary.step_hotspots {
            out.push_str(&format!(
                "- `{}` :: `{}` median={}s max={}s samples={}\n",
                hotspot.workflow_name,
                hotspot.step_name,
                hotspot.median_seconds,
                hotspot.max_seconds,
                hotspot.sample_count
            ));
        }
        out.push('\n');
    }

    out.push_str("## Duplicate Work Candidates\n\n");
    if summary.duplicate_work_candidates.is_empty() {
        out.push_str("No duplicate-work candidates exceeded the reporting threshold.\n\n");
    } else {
        for duplicate in &summary.duplicate_work_candidates {
            out.push_str(&format!(
                "- `{}` [{}] across {} workflow(s), est {}s: {}\n",
                duplicate.key,
                duplicate.severity,
                duplicate.workflows.len(),
                duplicate.total_estimated_seconds,
                duplicate.summary
            ));
        }
        out.push('\n');
    }

    out.push_str("## Recommendations\n\n");
    if summary.recommendations.is_empty() {
        out.push_str("No tightening recommendations generated.\n");
    } else {
        for recommendation in &summary.recommendations {
            out.push_str(&format!(
                "- **{}** [{} / {}]: {} Targets: {}\n",
                recommendation.id,
                recommendation.severity,
                recommendation.category,
                recommendation.summary,
                recommendation.targets.join(", ")
            ));
            out.push_str(&format!("  - Why: {}\n", recommendation.why));
        }
    }
    out
}

fn optional_seconds(value: Option<i64>) -> String {
    value
        .map(|value| value.to_string())
        .unwrap_or_else(|| "n/a".to_string())
}

fn default_window_runs() -> usize {
    40
}

fn default_bucket_size() -> usize {
    10
}

fn default_minimum_bucket_samples() -> usize {
    5
}

fn default_required_path_median_seconds() -> i64 {
    420
}

fn default_required_path_p90_seconds() -> i64 {
    600
}

fn default_workflow_regression_percent() -> f64 {
    20.0
}

fn default_duplicate_work_cumulative_seconds() -> i64 {
    180
}

fn default_top_workflows() -> usize {
    5
}

fn default_issue_title() -> String {
    "[ci-latency] weekly audit breach".to_string()
}

fn default_issue_label() -> String {
    "ci-latency".to_string()
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;
    use std::time::{SystemTime, UNIX_EPOCH};

    fn temp_file_path(name: &str) -> PathBuf {
        let nanos = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap()
            .as_nanos();
        std::env::temp_dir().join(format!("{}-{}.json", name, nanos))
    }

    fn write_json_fixture(name: &str, value: Value) -> PathBuf {
        let path = temp_file_path(name);
        fs::write(&path, serde_json::to_vec_pretty(&value).unwrap()).unwrap();
        path
    }

    fn base_policy(contract_path: &Path) -> LatencyPolicy {
        LatencyPolicy {
            required_checks: Vec::new(),
            required_checks_contract_path: Some(contract_path.to_path_buf()),
            window_runs: 40,
            newest_bucket: 10,
            previous_bucket: 10,
            minimum_bucket_samples: 5,
            required_path_median_seconds: 420,
            required_path_p90_seconds: 600,
            workflow_regression_percent: 20.0,
            duplicate_work_cumulative_seconds: 180,
            top_workflows: 5,
            issue_title: default_issue_title(),
            issue_label: default_issue_label(),
        }
    }

    fn contract_fixture(required_checks: &[&str]) -> PathBuf {
        write_json_fixture(
            "required-checks",
            json!({
                "rulesets": {
                    "main": {
                        "required_checks": required_checks
                    }
                }
            }),
        )
    }

    fn make_run(
        workflow_name: &str,
        head_sha: &str,
        created_at: &str,
        duration_seconds: f64,
    ) -> RawRunRecord {
        RawRunRecord {
            workflow_name: workflow_name.to_string(),
            event: "pull_request".to_string(),
            conclusion: Some("success".to_string()),
            head_sha: Some(head_sha.to_string()),
            created_at: created_at.to_string(),
            duration_seconds,
            run_id: None,
        }
    }

    #[test]
    fn required_path_median_and_p90_are_grouped_by_head_sha() {
        let runs = vec![
            make_run("a", "sha-1", "2026-03-12T10:00:00Z", 100.0),
            make_run("b", "sha-1", "2026-03-12T10:00:01Z", 150.0),
            make_run("a", "sha-2", "2026-03-11T10:00:00Z", 200.0),
            make_run("b", "sha-2", "2026-03-11T10:00:01Z", 300.0),
            make_run("a", "sha-3", "2026-03-10T10:00:00Z", 400.0),
            make_run("b", "sha-3", "2026-03-10T10:00:01Z", 500.0),
        ];
        let sets = build_required_path_sets(&runs, &["a".to_string(), "b".to_string()]);
        let policy = LatencyPolicy {
            required_checks: Vec::new(),
            required_checks_contract_path: Some(PathBuf::from("unused")),
            ..base_policy(Path::new("unused"))
        };
        let summary = summarize_required_path(&policy, &["a".to_string(), "b".to_string()], &sets);
        assert_eq!(summary.sample_count, 3);
        assert_eq!(summary.median_seconds, Some(300));
        assert_eq!(summary.p90_seconds, Some(500));
    }

    #[test]
    fn workflow_regression_breach_is_detected() {
        let contract_path = contract_fixture(&["required-a", "required-b"]);
        let policy = base_policy(&contract_path);
        let mut runs = Vec::new();
        for index in 0..10 {
            runs.push(RawRunRecord {
                workflow_name: "slow-workflow".to_string(),
                event: "pull_request".to_string(),
                conclusion: Some("success".to_string()),
                head_sha: Some(format!("slow-{index}")),
                created_at: format!("2026-03-{:02}T10:00:00Z", 30 - index),
                duration_seconds: if index < 10 { 300.0 } else { 0.0 },
                run_id: Some(index as u64),
            });
        }
        for index in 0..10 {
            runs.push(RawRunRecord {
                workflow_name: "slow-workflow".to_string(),
                event: "pull_request".to_string(),
                conclusion: Some("success".to_string()),
                head_sha: Some(format!("slow-prev-{index}")),
                created_at: format!("2026-02-{:02}T10:00:00Z", 30 - index),
                duration_seconds: 100.0,
                run_id: Some((index + 100) as u64),
            });
        }

        let metrics = summarize_workflows(&policy, &runs);
        let slow = metrics
            .iter()
            .find(|item| item.workflow_name == "slow-workflow")
            .unwrap();
        assert_eq!(slow.status, "breach");
        assert!(slow.regression_percent.unwrap() >= 20.0);
        assert_eq!(slow.latest_success_run_id, Some(0));
    }

    #[test]
    fn healthy_summary_stays_report_only_without_opening_issue() {
        let contract_path = contract_fixture(&["required-a", "required-b"]);
        let policy = base_policy(&contract_path);
        let mut runs = Vec::new();
        for index in 0..12 {
            let head_sha = format!("sha-{index}");
            let created_at = format!("2026-03-{:02}T10:00:00Z", 20 - index);
            runs.push(make_run("required-a", &head_sha, &created_at, 100.0));
            runs.push(make_run("required-b", &head_sha, &created_at, 140.0));
            runs.push(RawRunRecord {
                workflow_name: "optional-fast".to_string(),
                event: "pull_request".to_string(),
                conclusion: Some("success".to_string()),
                head_sha: Some(head_sha),
                created_at,
                duration_seconds: 80.0,
                run_id: Some(index as u64),
            });
        }

        let summary = build_summary(
            &policy,
            vec!["required-a".into(), "required-b".into()],
            runs,
            Vec::new(),
            Vec::new(),
        )
        .unwrap();
        assert_eq!(summary.status, "healthy");
        assert_eq!(summary.issue_action, "close_if_open");
        assert!(summary.recommendations.is_empty());
    }

    #[test]
    fn watch_summary_triggers_update_only_when_duplicate_work_exists() {
        let contract_path = contract_fixture(&["required-a", "required-b"]);
        let policy = base_policy(&contract_path);
        let mut runs = Vec::new();
        for index in 0..12 {
            let head_sha = format!("sha-{index}");
            let created_at = format!("2026-03-{:02}T10:00:00Z", 20 - index);
            runs.push(make_run("required-a", &head_sha, &created_at, 100.0));
            runs.push(make_run("required-b", &head_sha, &created_at, 120.0));
        }
        let duplicates = vec![RawDuplicateRecord {
            key: "actions/checkout@v4".to_string(),
            category: "setup".to_string(),
            workflows: vec!["wf-a".to_string(), "wf-b".to_string()],
            occurrences: 2,
            total_estimated_seconds: 90.0,
            summary: Some("checkout repeats".to_string()),
        }];
        let summary = build_summary(
            &policy,
            vec!["required-a".into(), "required-b".into()],
            runs,
            Vec::new(),
            duplicates,
        )
        .unwrap();
        assert_eq!(summary.status, "watch");
        assert_eq!(summary.issue_action, "update_if_open");
        assert_eq!(summary.duplicate_work_candidates.len(), 1);
    }

    #[test]
    fn breach_summary_generates_required_path_and_duplicate_recommendations() {
        let contract_path = contract_fixture(&["required-a", "required-b"]);
        let policy = base_policy(&contract_path);
        let mut runs = Vec::new();
        for index in 0..12 {
            let head_sha = format!("sha-{index}");
            let created_at = format!("2026-03-{:02}T10:00:00Z", 20 - index);
            runs.push(make_run("required-a", &head_sha, &created_at, 480.0));
            runs.push(make_run("required-b", &head_sha, &created_at, 510.0));
        }
        let duplicates = vec![RawDuplicateRecord {
            key: "cargo install --locked cargo-component".to_string(),
            category: "setup".to_string(),
            workflows: vec!["wf-a".to_string(), "wf-b".to_string()],
            occurrences: 2,
            total_estimated_seconds: 240.0,
            summary: Some("cargo-component install repeats".to_string()),
        }];
        let summary = build_summary(
            &policy,
            vec!["required-a".into(), "required-b".into()],
            runs,
            Vec::new(),
            duplicates,
        )
        .unwrap();
        assert_eq!(summary.status, "breach");
        assert_eq!(summary.issue_action, "open_or_update");
        assert!(summary
            .recommendations
            .iter()
            .any(|item| item.id == "required-path-over-budget"));
        assert!(summary
            .recommendations
            .iter()
            .any(|item| item.category == "duplicate-work"));
    }

    #[test]
    fn render_markdown_includes_recommendations_and_sections() {
        let summary = SummaryOutput {
            status: "breach".to_string(),
            issue_action: "open_or_update".to_string(),
            issue_title: default_issue_title(),
            issue_label: default_issue_label(),
            window: WindowSummary {
                window_runs: 40,
                newest_bucket: 10,
                previous_bucket: 10,
                minimum_bucket_samples: 5,
                runs_considered: 20,
                complete_required_sets: 10,
            },
            required_path: RequiredPathSummary {
                required_checks: vec!["required-a".to_string()],
                sample_count: 10,
                median_seconds: Some(500),
                p90_seconds: Some(640),
                target_median_seconds: 420,
                target_p90_seconds: 600,
                recent_median_seconds: Some(500),
                previous_median_seconds: Some(300),
            },
            workflow_metrics: vec![WorkflowMetricSummary {
                workflow_name: "workflow-a".to_string(),
                status: "breach".to_string(),
                run_count: 10,
                median_seconds: 200,
                regression_percent: Some(100.0),
                latest_success_run_id: Some(123),
                recent_median_seconds: Some(200),
                previous_median_seconds: Some(100),
            }],
            step_hotspots: vec![StepHotspotSummary {
                workflow_name: "workflow-a".to_string(),
                step_name: "job / build".to_string(),
                sample_count: 3,
                median_seconds: 120,
                max_seconds: 150,
            }],
            duplicate_work_candidates: vec![DuplicateWorkCandidateSummary {
                key: "checkout".to_string(),
                category: "setup".to_string(),
                severity: "high".to_string(),
                workflows: vec!["workflow-a".to_string()],
                occurrences: 2,
                total_estimated_seconds: 200,
                summary: "checkout duplicates".to_string(),
            }],
            recommendations: vec![RecommendationSummary {
                id: "required-path-over-budget".to_string(),
                severity: "high".to_string(),
                category: "required-path".to_string(),
                summary: "over budget".to_string(),
                why: "because".to_string(),
                targets: vec!["required-a".to_string()],
            }],
        };

        let rendered = render_markdown(&summary);
        assert!(rendered.contains("# CI Latency Audit"));
        assert!(rendered.contains("## Required Path"));
        assert!(rendered.contains("## Recommendations"));
        assert!(rendered.contains("required-path-over-budget"));
    }

    #[test]
    fn analyze_supports_wrapped_input_shapes() {
        let contract_path = contract_fixture(&["required-a", "required-b"]);
        let policy_path = write_json_fixture(
            "ci-latency-policy",
            json!({
                "required_checks_contract_path": contract_path,
                "window_runs": 40,
                "newest_bucket": 10,
                "previous_bucket": 10,
                "minimum_bucket_samples": 5,
                "required_path_median_seconds": 420,
                "required_path_p90_seconds": 600,
                "workflow_regression_percent": 20,
                "duplicate_work_cumulative_seconds": 180,
                "top_workflows": 5,
                "issue_title": default_issue_title(),
                "issue_label": default_issue_label(),
            }),
        );
        let runs_path = write_json_fixture(
            "runs",
            json!({
                "workflow_runs": [
                    {
                        "workflow_name": "required-a",
                        "event": "pull_request",
                        "conclusion": "success",
                        "status": "completed",
                        "head_sha": "sha-1",
                        "created_at": "2026-03-12T10:00:00Z",
                        "duration_seconds": 100
                    },
                    {
                        "workflow_name": "required-b",
                        "event": "pull_request",
                        "conclusion": "success",
                        "status": "completed",
                        "head_sha": "sha-1",
                        "created_at": "2026-03-12T10:00:01Z",
                        "duration_seconds": 120
                    }
                ]
            }),
        );
        let jobs_path = write_json_fixture(
            "jobs",
            json!({
                "job_bundles": [
                    {
                        "run_id": 42,
                        "workflow_name": "required-a",
                        "jobs": [
                            {
                                "name": "build",
                                "steps": [
                                    {
                                        "name": "checkout",
                                        "started_at": "2026-03-12T10:00:00Z",
                                        "completed_at": "2026-03-12T10:00:05Z"
                                    }
                                ]
                            }
                        ]
                    }
                ]
            }),
        );
        let scan_path = write_json_fixture(
            "workflow-scan",
            json!({
                "duplicates": []
            }),
        );
        let output_json = temp_file_path("summary");
        let output_markdown = temp_file_path("summary-md");

        run_analyze(CiLatencyAnalyzeArgs {
            policy: policy_path,
            runs: runs_path,
            jobs: jobs_path,
            workflow_scan: scan_path,
            output_json: output_json.clone(),
            output_markdown: Some(output_markdown.clone()),
        })
        .unwrap();

        let summary = load_summary(&output_json).unwrap();
        assert_eq!(summary.required_path.sample_count, 1);
        assert!(output_markdown.exists());
    }

    #[test]
    fn explicit_required_checks_override_contract_path() {
        let contract_path = contract_fixture(&["ignored"]);
        let policy = LatencyPolicy {
            required_checks: vec!["required-a".to_string(), "required-b".to_string()],
            required_checks_contract_path: Some(contract_path),
            ..base_policy(Path::new("unused"))
        };
        let required = load_required_checks(&policy).unwrap();
        assert_eq!(
            required,
            vec!["required-a".to_string(), "required-b".to_string()]
        );
    }
}
