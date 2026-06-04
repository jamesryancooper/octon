use crate::errors::{LifecycleErrorClass, LifecycleExecutionError};
use crate::request::LifecycleRouteExecutionRequest;
use crate::result::LifecycleRouteExecutionResult;
use serde::Serialize;
use serde_json::Value;
use sha2::{Digest, Sha256};
use std::collections::BTreeSet;
use std::fs;
use std::path::{Component, Path, PathBuf};
use walkdir::WalkDir;

pub const TOKEN_BUDGET_LEDGER_FILE: &str = "token-budget-ledger.json";
const SCHEMA_VERSION: &str = "token-budget-ledger-v1";
const PRODUCER: &str = "octon_lifecycle_executor::token_budget";
const SPEC_REF: &str = ".octon/framework/engine/runtime/spec/token-budget-ledger-v1.schema.json";

#[derive(Debug, Serialize)]
struct TokenBudgetLedger {
    schema_version: &'static str,
    schema_ref: &'static str,
    ledger_id: String,
    run_id: String,
    lifecycle_id: String,
    route_id: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    phase_id: Option<String>,
    ledger_scope: TokenLedgerScope,
    produced_by: TokenLedgerProducer,
    ledger_role: &'static str,
    token_generation_mode: &'static str,
    provider_usage: ProviderUsage,
    token_summary: TokenSummary,
    levels: Vec<TokenLedgerLevel>,
    source_records: Vec<TokenSourceRecord>,
    regression_guard: RegressionGuard,
    authority_boundary: AuthorityBoundary,
}

#[derive(Debug, Serialize)]
struct TokenLedgerScope {
    level: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    parent_run_id: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    child_id: Option<String>,
    target_ref: String,
    evidence_root_ref: String,
}

#[derive(Debug, Serialize)]
struct TokenLedgerProducer {
    name: &'static str,
    version: &'static str,
    recorded_at: String,
}

#[derive(Debug, Serialize)]
struct ProviderUsage {
    status: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    provider_usage_ref: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    prompt_tokens: Option<u64>,
    #[serde(skip_serializing_if = "Option::is_none")]
    context_tokens: Option<u64>,
    #[serde(skip_serializing_if = "Option::is_none")]
    completion_tokens: Option<u64>,
    #[serde(skip_serializing_if = "Option::is_none")]
    tool_output_tokens: Option<u64>,
    #[serde(skip_serializing_if = "Option::is_none")]
    total_tokens: Option<u64>,
    usage_mismatch_detected: bool,
    notes: Vec<String>,
}

#[derive(Debug, Serialize)]
struct TokenSummary {
    estimated_total_tokens: u64,
    model_visible_estimated_tokens: u64,
    prompt_estimated_tokens: u64,
    context_estimated_tokens: u64,
    completion_estimated_tokens: u64,
    tool_output_estimated_tokens: u64,
    evidence_estimated_tokens: u64,
    repeated_source_percentage: f64,
    repeated_source_token_estimate: u64,
    prompt_boilerplate_percentage: f64,
    prompt_boilerplate_token_estimate: u64,
    generated_state_reread_count: u64,
    raw_log_reread_count: u64,
    high_reasoning_call_count: u64,
}

#[derive(Debug, Serialize)]
struct TokenLedgerLevel {
    level: String,
    subject_id: String,
    estimated_tokens: u64,
    source_count: u64,
    notes: Vec<String>,
}

#[derive(Clone, Debug, Serialize)]
struct TokenSourceRecord {
    source_ref: String,
    sha256: String,
    bytes: u64,
    estimated_tokens: u64,
    source_class: String,
    model_visible: bool,
    inclusion_mode: &'static str,
}

#[derive(Debug, Serialize)]
struct RegressionGuard {
    baseline_ref: Option<String>,
    candidate_ref: String,
    avoidable_regression_threshold_percent: u64,
    status: String,
    notes: Vec<String>,
}

#[derive(Debug, Serialize)]
struct AuthorityBoundary {
    artifact_class: &'static str,
    replaces_source_evidence: bool,
    authorizes_execution: bool,
    raw_evidence_retained: bool,
    proposal_input_authority: &'static str,
    generated_output_authority: &'static str,
    failure_behavior: &'static str,
}

pub fn write_route_token_budget_ledger(
    repo_root: &Path,
    request: &LifecycleRouteExecutionRequest,
    result: &LifecycleRouteExecutionResult,
) -> Result<PathBuf, LifecycleExecutionError> {
    fs::create_dir_all(&request.evidence_root)?;
    let output_path = request.evidence_root.join(TOKEN_BUDGET_LEDGER_FILE);
    let source_records = route_source_records(repo_root, result)?;
    let provider_usage = provider_usage(repo_root, request)?;
    let token_summary = token_summary(&source_records, &provider_usage);
    let child_id = child_id_from_context_or_path(request);
    let parent_run_id = request
        .human_boundary_context
        .as_ref()
        .and_then(|context| context.program_run_id.clone());
    let ledger_scope = TokenLedgerScope {
        level: if child_id.is_some() {
            "child-route".to_string()
        } else {
            "route".to_string()
        },
        parent_run_id,
        child_id: child_id.clone(),
        target_ref: repo_rel(repo_root, &request.target),
        evidence_root_ref: repo_rel(repo_root, &request.evidence_root),
    };
    let levels = route_levels(
        request,
        child_id.as_deref(),
        &source_records,
        &token_summary,
    );
    let ledger = TokenBudgetLedger {
        schema_version: SCHEMA_VERSION,
        schema_ref: SPEC_REF,
        ledger_id: format!("{}:{}", request.run_id, request.route.route_id),
        run_id: request.run_id.clone(),
        lifecycle_id: request.lifecycle_id.clone(),
        route_id: request.route.route_id.clone(),
        phase_id: request.phase_id.clone(),
        ledger_scope,
        produced_by: TokenLedgerProducer {
            name: PRODUCER,
            version: SCHEMA_VERSION,
            recorded_at: now_rfc3339()?,
        },
        ledger_role: "retained-token-measurement-evidence-not-authority",
        token_generation_mode: "deterministic-byte-estimate-provider-usage-when-present",
        provider_usage,
        token_summary,
        levels,
        source_records,
        regression_guard: RegressionGuard {
            baseline_ref: None,
            candidate_ref: repo_rel(repo_root, &output_path),
            avoidable_regression_threshold_percent: 30,
            status: "measurement-only".to_string(),
            notes: vec![
                "route ledger records deterministic estimates; regression decisions are validator-owned"
                    .to_string(),
            ],
        },
        authority_boundary: authority_boundary(),
    };
    write_json(&output_path, &ledger)?;
    Ok(output_path)
}

pub fn write_program_aggregate_token_budget_ledger(
    repo_root: &Path,
    evidence_root: &Path,
    run_id: &str,
    lifecycle_id: &str,
    target_ref: &str,
) -> Result<PathBuf, LifecycleExecutionError> {
    fs::create_dir_all(evidence_root)?;
    let output_path = evidence_root.join(TOKEN_BUDGET_LEDGER_FILE);
    let mut source_paths = Vec::new();
    for rel in [
        "program-plan.yml",
        "scheduler-decision.yml",
        "run-inputs.yml",
        "summary.md",
        "recovery-log.yml",
    ] {
        let path = evidence_root.join(rel);
        if path.is_file() {
            source_paths.push((path, "program-evidence".to_string(), false));
        }
    }
    for entry in WalkDir::new(evidence_root)
        .min_depth(1)
        .max_depth(4)
        .into_iter()
        .filter_map(Result::ok)
    {
        if !entry.file_type().is_file() {
            continue;
        }
        let path = entry.path();
        if path == output_path {
            continue;
        }
        if path.file_name().and_then(|name| name.to_str()) == Some(TOKEN_BUDGET_LEDGER_FILE) {
            source_paths.push((path.to_path_buf(), "token-ledger".to_string(), false));
        }
    }
    source_paths.sort_by(|left, right| left.0.cmp(&right.0));
    source_paths.dedup_by(|left, right| left.0 == right.0);
    let source_records = source_paths
        .iter()
        .filter_map(|(path, source_class, model_visible)| {
            source_record(repo_root, path, source_class, *model_visible).ok()
        })
        .collect::<Vec<_>>();
    let provider_usage = ProviderUsage {
        status: "not_available".to_string(),
        provider_usage_ref: None,
        prompt_tokens: None,
        context_tokens: None,
        completion_tokens: None,
        tool_output_tokens: None,
        total_tokens: None,
        usage_mismatch_detected: false,
        notes: vec![
            "program aggregate sums retained route ledgers and program evidence".to_string(),
        ],
    };
    let token_summary = token_summary(&source_records, &provider_usage);
    let levels = aggregate_levels(evidence_root, &source_records, &token_summary);
    let ledger = TokenBudgetLedger {
        schema_version: SCHEMA_VERSION,
        schema_ref: SPEC_REF,
        ledger_id: format!("{run_id}:program-aggregate"),
        run_id: run_id.to_string(),
        lifecycle_id: lifecycle_id.to_string(),
        route_id: "program-aggregate".to_string(),
        phase_id: None,
        ledger_scope: TokenLedgerScope {
            level: "program".to_string(),
            parent_run_id: Some(run_id.to_string()),
            child_id: None,
            target_ref: target_ref.to_string(),
            evidence_root_ref: repo_rel(repo_root, evidence_root),
        },
        produced_by: TokenLedgerProducer {
            name: PRODUCER,
            version: SCHEMA_VERSION,
            recorded_at: now_rfc3339()?,
        },
        ledger_role: "retained-program-token-measurement-evidence-not-authority",
        token_generation_mode: "deterministic-byte-estimate-provider-usage-when-present",
        provider_usage,
        token_summary,
        levels,
        source_records,
        regression_guard: RegressionGuard {
            baseline_ref: None,
            candidate_ref: repo_rel(repo_root, &output_path),
            avoidable_regression_threshold_percent: 30,
            status: "measurement-only".to_string(),
            notes: vec![
                "program aggregate exposes regression candidate data; CI validator owns pass/fail"
                    .to_string(),
            ],
        },
        authority_boundary: authority_boundary(),
    };
    write_json(&output_path, &ledger)?;
    Ok(output_path)
}

fn route_source_records(
    repo_root: &Path,
    result: &LifecycleRouteExecutionResult,
) -> Result<Vec<TokenSourceRecord>, LifecycleExecutionError> {
    let mut paths = Vec::new();
    if let Some(path) = result.prompt_packet_path.as_ref() {
        paths.push((path.clone(), "prompt".to_string(), true));
    }
    if let Some(path) = result.stdout_path.as_ref() {
        paths.push((path.clone(), "completion".to_string(), false));
    }
    if let Some(path) = result.stderr_path.as_ref() {
        paths.push((path.clone(), "tool-output".to_string(), false));
    }
    for path in &result.evidence_paths {
        if result.prompt_packet_path.as_ref() == Some(path)
            || result.stdout_path.as_ref() == Some(path)
            || result.stderr_path.as_ref() == Some(path)
        {
            continue;
        }
        let source_class = classify_path(path);
        let model_visible = path
            .file_name()
            .and_then(|name| name.to_str())
            .map(|name| name == "model-visible-context.json")
            .unwrap_or(false);
        paths.push((path.clone(), source_class, model_visible));
    }
    paths.sort_by(|left, right| left.0.cmp(&right.0));
    paths.dedup_by(|left, right| left.0 == right.0);
    let mut records = Vec::new();
    for (path, source_class, model_visible) in paths {
        if path.is_file() {
            records.push(source_record(
                repo_root,
                &path,
                &source_class,
                model_visible,
            )?);
        }
    }
    Ok(records)
}

fn source_record(
    repo_root: &Path,
    path: &Path,
    source_class: &str,
    model_visible: bool,
) -> Result<TokenSourceRecord, LifecycleExecutionError> {
    let bytes = fs::read(path)?;
    let sha256 = format!("sha256:{}", hex::encode(Sha256::digest(&bytes)));
    Ok(TokenSourceRecord {
        source_ref: repo_rel(repo_root, path),
        sha256,
        bytes: bytes.len() as u64,
        estimated_tokens: estimate_tokens(bytes.len() as u64),
        source_class: source_class.to_string(),
        model_visible,
        inclusion_mode: if model_visible {
            "full"
        } else {
            "digest-bound"
        },
    })
}

fn classify_path(path: &Path) -> String {
    let name = path
        .file_name()
        .and_then(|name| name.to_str())
        .unwrap_or("");
    if name.ends_with("-prompt.md") || name == "model-visible-context.json" {
        "context".to_string()
    } else if name.ends_with("-stdout.log") {
        "completion".to_string()
    } else if name.ends_with("-stderr.log") || name.ends_with(".log") {
        "tool-output".to_string()
    } else if name == TOKEN_BUDGET_LEDGER_FILE {
        "token-ledger".to_string()
    } else {
        "evidence".to_string()
    }
}

fn token_summary(records: &[TokenSourceRecord], provider_usage: &ProviderUsage) -> TokenSummary {
    let mut total = 0_u64;
    let mut model_visible = 0_u64;
    let mut prompt = 0_u64;
    let mut context = 0_u64;
    let mut completion = 0_u64;
    let mut tool_output = 0_u64;
    let mut evidence = 0_u64;
    let mut seen_sha = BTreeSet::new();
    let mut repeated = 0_u64;
    let mut generated_state_rereads = 0_u64;
    let mut raw_log_rereads = 0_u64;
    let mut prompt_boilerplate = 0_u64;
    for record in records {
        total = total.saturating_add(record.estimated_tokens);
        if record.model_visible {
            model_visible = model_visible.saturating_add(record.estimated_tokens);
        }
        match record.source_class.as_str() {
            "prompt" => {
                prompt = prompt.saturating_add(record.estimated_tokens);
                prompt_boilerplate =
                    prompt_boilerplate.saturating_add(estimate_prompt_boilerplate(record));
            }
            "context" => context = context.saturating_add(record.estimated_tokens),
            "completion" => completion = completion.saturating_add(record.estimated_tokens),
            "tool-output" => tool_output = tool_output.saturating_add(record.estimated_tokens),
            "token-ledger" | "evidence" | "program-evidence" => {
                evidence = evidence.saturating_add(record.estimated_tokens)
            }
            _ => evidence = evidence.saturating_add(record.estimated_tokens),
        }
        if record.source_ref.contains(".octon/generated/") {
            generated_state_rereads = generated_state_rereads.saturating_add(1);
        }
        if record.source_ref.ends_with(".log") {
            raw_log_rereads = raw_log_rereads.saturating_add(1);
        }
        if !seen_sha.insert(record.sha256.as_str()) {
            repeated = repeated.saturating_add(record.estimated_tokens);
        }
    }
    let repeated_source_percentage = percentage(repeated, total);
    let prompt_boilerplate_percentage = percentage(prompt_boilerplate, prompt);
    let high_reasoning_call_count = if provider_usage
        .notes
        .iter()
        .any(|note| note.contains("high_reasoning"))
    {
        1
    } else {
        0
    };
    TokenSummary {
        estimated_total_tokens: total,
        model_visible_estimated_tokens: model_visible.max(prompt),
        prompt_estimated_tokens: provider_usage.prompt_tokens.unwrap_or(prompt),
        context_estimated_tokens: provider_usage.context_tokens.unwrap_or(context),
        completion_estimated_tokens: provider_usage.completion_tokens.unwrap_or(completion),
        tool_output_estimated_tokens: provider_usage.tool_output_tokens.unwrap_or(tool_output),
        evidence_estimated_tokens: evidence,
        repeated_source_percentage,
        repeated_source_token_estimate: repeated,
        prompt_boilerplate_percentage,
        prompt_boilerplate_token_estimate: prompt_boilerplate,
        generated_state_reread_count: generated_state_rereads,
        raw_log_reread_count: raw_log_rereads,
        high_reasoning_call_count,
    }
}

fn route_levels(
    request: &LifecycleRouteExecutionRequest,
    child_id: Option<&str>,
    records: &[TokenSourceRecord],
    summary: &TokenSummary,
) -> Vec<TokenLedgerLevel> {
    let mut levels = Vec::new();
    let parent_subject = request
        .human_boundary_context
        .as_ref()
        .and_then(|context| context.program_run_id.as_deref())
        .unwrap_or(&request.run_id);
    levels.push(TokenLedgerLevel {
        level: "parent".to_string(),
        subject_id: parent_subject.to_string(),
        estimated_tokens: summary.estimated_total_tokens,
        source_count: records.len() as u64,
        notes: vec!["route-level estimate rolled up to parent/program subject".to_string()],
    });
    levels.push(TokenLedgerLevel {
        level: "child".to_string(),
        subject_id: child_id.unwrap_or("none").to_string(),
        estimated_tokens: summary.estimated_total_tokens,
        source_count: records.len() as u64,
        notes: vec!["child subject is explicit only for program child routes".to_string()],
    });
    levels.push(TokenLedgerLevel {
        level: "stage".to_string(),
        subject_id: request
            .phase_id
            .as_deref()
            .unwrap_or(&request.route.route_id)
            .to_string(),
        estimated_tokens: summary.estimated_total_tokens,
        source_count: records.len() as u64,
        notes: vec!["stage derives from phase/group id when available".to_string()],
    });
    levels.push(TokenLedgerLevel {
        level: "source".to_string(),
        subject_id: "source-records".to_string(),
        estimated_tokens: records.iter().map(|record| record.estimated_tokens).sum(),
        source_count: records.len() as u64,
        notes: vec!["source level sums digest-bound source records".to_string()],
    });
    levels.push(TokenLedgerLevel {
        level: "model".to_string(),
        subject_id: request.executor.clone(),
        estimated_tokens: summary
            .prompt_estimated_tokens
            .saturating_add(summary.context_estimated_tokens)
            .saturating_add(summary.completion_estimated_tokens)
            .saturating_add(summary.tool_output_estimated_tokens),
        source_count: records
            .iter()
            .filter(|record| {
                matches!(
                    record.source_class.as_str(),
                    "prompt" | "context" | "completion" | "tool-output"
                )
            })
            .count() as u64,
        notes: vec![
            "model level uses provider usage when present, otherwise deterministic estimates"
                .to_string(),
        ],
    });
    levels
}

fn aggregate_levels(
    evidence_root: &Path,
    records: &[TokenSourceRecord],
    summary: &TokenSummary,
) -> Vec<TokenLedgerLevel> {
    let child_count = evidence_root
        .join("children")
        .read_dir()
        .map(|entries| {
            entries
                .filter_map(Result::ok)
                .filter(|entry| entry.path().is_dir())
                .count()
        })
        .unwrap_or(0);
    let route_ledger_count = records
        .iter()
        .filter(|record| record.source_class == "token-ledger")
        .count();
    vec![
        TokenLedgerLevel {
            level: "parent".to_string(),
            subject_id: "program".to_string(),
            estimated_tokens: summary.estimated_total_tokens,
            source_count: records.len() as u64,
            notes: vec!["program aggregate over parent and child route ledgers".to_string()],
        },
        TokenLedgerLevel {
            level: "child".to_string(),
            subject_id: format!("children:{child_count}"),
            estimated_tokens: records
                .iter()
                .filter(|record| record.source_ref.contains("/children/"))
                .map(|record| record.estimated_tokens)
                .sum(),
            source_count: child_count as u64,
            notes: vec!["child level counts retained child route ledger evidence".to_string()],
        },
        TokenLedgerLevel {
            level: "stage".to_string(),
            subject_id: format!("route-ledgers:{route_ledger_count}"),
            estimated_tokens: records
                .iter()
                .filter(|record| record.source_class == "token-ledger")
                .map(|record| record.estimated_tokens)
                .sum(),
            source_count: route_ledger_count as u64,
            notes: vec!["stage level summarizes route ledger artifacts".to_string()],
        },
        TokenLedgerLevel {
            level: "source".to_string(),
            subject_id: "program-source-records".to_string(),
            estimated_tokens: records.iter().map(|record| record.estimated_tokens).sum(),
            source_count: records.len() as u64,
            notes: vec!["source level sums program evidence and child ledgers".to_string()],
        },
        TokenLedgerLevel {
            level: "model".to_string(),
            subject_id: "program-executors".to_string(),
            estimated_tokens: summary
                .prompt_estimated_tokens
                .saturating_add(summary.context_estimated_tokens)
                .saturating_add(summary.completion_estimated_tokens)
                .saturating_add(summary.tool_output_estimated_tokens),
            source_count: route_ledger_count as u64,
            notes: vec!["model level is derived from route ledger estimates and provider usage where present".to_string()],
        },
    ]
}

fn provider_usage(
    repo_root: &Path,
    request: &LifecycleRouteExecutionRequest,
) -> Result<ProviderUsage, LifecycleExecutionError> {
    let provider_ref = request
        .bound_inputs
        .get("provider_usage_ref")
        .or_else(|| request.bound_inputs.get("model_usage_ref"))
        .cloned()
        .or_else(|| std::env::var("OCTON_PROVIDER_USAGE_REF").ok());
    let Some(raw_ref) = provider_ref else {
        return Ok(ProviderUsage {
            status: "not_available".to_string(),
            provider_usage_ref: None,
            prompt_tokens: None,
            context_tokens: None,
            completion_tokens: None,
            tool_output_tokens: None,
            total_tokens: None,
            usage_mismatch_detected: false,
            notes: vec!["provider usage artifact was not supplied for this route".to_string()],
        });
    };
    let path = if Path::new(&raw_ref).is_absolute() {
        PathBuf::from(&raw_ref)
    } else {
        repo_root.join(&raw_ref)
    };
    if !path.is_file() {
        return Ok(ProviderUsage {
            status: "missing".to_string(),
            provider_usage_ref: Some(raw_ref),
            prompt_tokens: None,
            context_tokens: None,
            completion_tokens: None,
            tool_output_tokens: None,
            total_tokens: None,
            usage_mismatch_detected: true,
            notes: vec!["provider usage ref was supplied but the artifact was missing".to_string()],
        });
    }
    let value: Value = serde_json::from_slice(&fs::read(&path)?).map_err(json_error)?;
    let prompt_tokens = value_u64(&value, &["prompt_tokens", "input_tokens"]);
    let context_tokens = value_u64(&value, &["context_tokens"]);
    let completion_tokens = value_u64(&value, &["completion_tokens", "output_tokens"]);
    let tool_output_tokens = value_u64(&value, &["tool_output_tokens", "tool_tokens"]);
    let total_tokens = value_u64(&value, &["total_tokens"]).or_else(|| {
        Some(
            prompt_tokens
                .unwrap_or(0)
                .saturating_add(context_tokens.unwrap_or(0))
                .saturating_add(completion_tokens.unwrap_or(0))
                .saturating_add(tool_output_tokens.unwrap_or(0)),
        )
    });
    Ok(ProviderUsage {
        status: "available".to_string(),
        provider_usage_ref: Some(repo_rel(repo_root, &path)),
        prompt_tokens,
        context_tokens,
        completion_tokens,
        tool_output_tokens,
        total_tokens,
        usage_mismatch_detected: false,
        notes: vec!["provider usage artifact parsed successfully".to_string()],
    })
}

fn value_u64(value: &Value, keys: &[&str]) -> Option<u64> {
    for key in keys {
        if let Some(value) = value.get(*key).and_then(Value::as_u64) {
            return Some(value);
        }
        if let Some(value) = value
            .get("usage")
            .and_then(|usage| usage.get(*key))
            .and_then(Value::as_u64)
        {
            return Some(value);
        }
    }
    None
}

fn child_id_from_context_or_path(request: &LifecycleRouteExecutionRequest) -> Option<String> {
    request
        .human_boundary_context
        .as_ref()
        .and_then(|context| context.child_id.clone())
        .or_else(|| child_id_from_evidence_path(&request.evidence_root))
}

fn child_id_from_evidence_path(path: &Path) -> Option<String> {
    let components = path.components().collect::<Vec<_>>();
    components.windows(2).find_map(|window| {
        if matches!(window[0], Component::Normal(value) if value == "children") {
            window[1].as_os_str().to_str().map(str::to_string)
        } else {
            None
        }
    })
}

fn estimate_prompt_boilerplate(record: &TokenSourceRecord) -> u64 {
    if record.source_class != "prompt" {
        return 0;
    }
    (record.estimated_tokens / 10).min(record.estimated_tokens)
}

fn estimate_tokens(bytes: u64) -> u64 {
    bytes.saturating_add(3) / 4
}

fn percentage(part: u64, total: u64) -> f64 {
    if total == 0 {
        0.0
    } else {
        (((part as f64 / total as f64) * 10_000.0).round()) / 100.0
    }
}

fn authority_boundary() -> AuthorityBoundary {
    AuthorityBoundary {
        artifact_class: "retained-evidence-read-model",
        replaces_source_evidence: false,
        authorizes_execution: false,
        raw_evidence_retained: true,
        proposal_input_authority: "non-authoritative",
        generated_output_authority: "derived-only",
        failure_behavior: "fail-closed-for-regression-claims-not-for-authorization",
    }
}

fn write_json<T: Serialize>(path: &Path, value: &T) -> Result<(), LifecycleExecutionError> {
    let bytes = serde_json::to_vec_pretty(value).map_err(json_error)?;
    fs::write(path, bytes)?;
    Ok(())
}

fn json_error(error: serde_json::Error) -> LifecycleExecutionError {
    LifecycleExecutionError::new(LifecycleErrorClass::Io, error.to_string())
}

fn now_rfc3339() -> Result<String, LifecycleExecutionError> {
    time::OffsetDateTime::now_utc()
        .format(&time::format_description::well_known::Rfc3339)
        .map_err(|error| LifecycleExecutionError::new(LifecycleErrorClass::Io, error.to_string()))
}

fn repo_rel(repo_root: &Path, path: &Path) -> String {
    path.strip_prefix(repo_root)
        .unwrap_or(path)
        .to_string_lossy()
        .replace('\\', "/")
}
