use crate::errors::{ErrorCode, KernelError, Result};
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::collections::{BTreeMap, BTreeSet};
use std::fs::{self, OpenOptions};
use std::io::Write;
use std::path::{Path, PathBuf};
use time::format_description::well_known::Rfc3339;
use time::OffsetDateTime;

const FLOW_SERVICE_ID: &str = "execution/flow";
const FLOW_ADAPTER_LANGGRAPH_HTTP: &str = "langgraph-http";
const FLOW_DEFAULT_RUNTIME_URL: &str = "http://127.0.0.1:8410/flows/run";

#[derive(Debug, Clone, Default)]
pub struct ServiceCapabilityProfile {
    pub requested_capabilities: Vec<String>,
    pub adapter_id: Option<String>,
    pub network_target_url: Option<String>,
    pub metadata: BTreeMap<String, String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ParsedNetworkTarget {
    pub scheme: String,
    pub host: String,
    pub port: u16,
    pub path: String,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub struct NetworkEgressPolicy {
    #[serde(default)]
    pub schema_version: String,
    #[serde(default)]
    pub rules: Vec<NetworkEgressRule>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct NetworkEgressRule {
    pub id: String,
    #[serde(default)]
    pub services: Vec<String>,
    #[serde(default)]
    pub adapters: Vec<String>,
    #[serde(default)]
    pub executor_profiles: Vec<String>,
    #[serde(default)]
    pub methods: Vec<String>,
    #[serde(default)]
    pub schemes: Vec<String>,
    #[serde(default)]
    pub hosts: Vec<String>,
    #[serde(default)]
    pub ports: Vec<u16>,
    #[serde(default)]
    pub path_prefixes: Vec<String>,
    #[serde(default)]
    pub reason: String,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub struct ExecutionExceptionLeases {
    #[serde(default)]
    pub schema_version: String,
    #[serde(default)]
    pub leases: Vec<ExecutionExceptionLease>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct ExecutionExceptionLease {
    pub id: String,
    #[serde(default)]
    pub state: String,
    #[serde(default)]
    pub lease_kind: String,
    #[serde(default)]
    pub request_id: Option<String>,
    #[serde(default)]
    pub run_id: Option<String>,
    #[serde(default)]
    pub service: Option<String>,
    #[serde(default)]
    pub adapter: Option<String>,
    #[serde(default)]
    pub method: Option<String>,
    #[serde(default)]
    pub scheme: Option<String>,
    #[serde(default)]
    pub host: Option<String>,
    #[serde(default)]
    pub port: Option<u16>,
    #[serde(default)]
    pub path_prefix: Option<String>,
    pub expires_at: String,
    #[serde(default)]
    pub owner: Option<String>,
    #[serde(default)]
    pub reason: Option<String>,
}

#[derive(Debug, Clone)]
pub struct NetworkEgressContext<'a> {
    pub service_id: &'a str,
    pub adapter_id: Option<&'a str>,
    pub executor_profile: Option<&'a str>,
    pub method: &'a str,
}

#[derive(Debug, Clone, Serialize)]
pub struct NetworkEgressDecision {
    pub allowed: bool,
    pub matched_rule_id: String,
    pub reason: String,
    pub source_kind: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub artifact_ref: Option<String>,
}

#[derive(Debug, Clone, Serialize)]
pub struct NetworkEgressEvent {
    pub schema_version: String,
    pub request_id: String,
    pub service_id: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub adapter_id: Option<String>,
    pub method: String,
    pub url: String,
    pub target: ParsedNetworkTarget,
    pub decision: NetworkEgressDecision,
    pub recorded_at: String,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub struct ExecutionBudgetPolicy {
    #[serde(default)]
    pub schema_version: String,
    #[serde(default = "default_missing_cost_action")]
    pub missing_cost_evidence_action: String,
    #[serde(default)]
    pub rules: Vec<ExecutionBudgetRule>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct ExecutionBudgetRule {
    pub id: String,
    #[serde(default)]
    pub path_types: Vec<String>,
    #[serde(default)]
    pub action_types: Vec<String>,
    #[serde(default)]
    pub executor_profiles: Vec<String>,
    #[serde(default)]
    pub providers: Vec<String>,
    #[serde(default)]
    pub model_patterns: Vec<String>,
    #[serde(default)]
    pub require_cost_evidence: bool,
    #[serde(default)]
    pub reason: String,
    #[serde(default)]
    pub thresholds: ExecutionBudgetThresholds,
}

#[derive(Debug, Clone, Default, Deserialize)]
pub struct ExecutionBudgetThresholds {
    #[serde(default)]
    pub warn_estimated_cost_usd: Option<f64>,
    #[serde(default)]
    pub stage_estimated_cost_usd: Option<f64>,
    #[serde(default)]
    pub deny_estimated_cost_usd: Option<f64>,
    #[serde(default)]
    pub max_prompt_bytes: Option<u64>,
    #[serde(default)]
    pub max_estimated_input_tokens: Option<u64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExecutionBudgetState {
    pub schema_version: String,
    pub updated_at: String,
    #[serde(default)]
    pub rules: BTreeMap<String, ExecutionBudgetCounter>,
}

impl Default for ExecutionBudgetState {
    fn default() -> Self {
        Self {
            schema_version: "execution-budget-state-v1".to_string(),
            updated_at: now_rfc3339(),
            rules: BTreeMap::new(),
        }
    }
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct ExecutionBudgetCounter {
    pub run_count: u64,
    pub consumed_estimated_cost_usd: f64,
    #[serde(default)]
    pub consumed_actual_cost_usd: f64,
    #[serde(default)]
    pub last_request_id: Option<String>,
    #[serde(default)]
    pub last_decision: Option<String>,
    #[serde(default)]
    pub last_updated_at: Option<String>,
}

#[derive(Debug, Clone)]
pub struct BudgetCheckContext<'a> {
    pub request_id: &'a str,
    pub path_type: &'a str,
    pub action_type: &'a str,
    pub executor_profile: Option<&'a str>,
    pub provider: Option<&'a str>,
    pub model: Option<&'a str>,
    pub prompt_bytes: Option<u64>,
}

#[derive(Debug, Clone, Serialize)]
pub struct ExecutionCostEvidence {
    pub schema_version: String,
    pub request_id: String,
    pub evaluated_at: String,
    pub decision: String,
    pub reason_codes: Vec<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub matched_rule_id: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub provider: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub model: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub prompt_bytes: Option<u64>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub input_tokens_estimated: Option<u64>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub output_tokens_estimated: Option<u64>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub estimated_cost_usd: Option<f64>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub actual_cost_usd: Option<f64>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub estimation_basis: Option<String>,
}

#[derive(Debug, Clone)]
pub enum BudgetDecision {
    Skip,
    Allow {
        rule_id: String,
        reason_codes: Vec<String>,
        evidence: ExecutionCostEvidence,
    },
    StageOnly {
        rule_id: String,
        reason_codes: Vec<String>,
        message: String,
        evidence: ExecutionCostEvidence,
    },
    Deny {
        rule_id: String,
        reason_codes: Vec<String>,
        message: String,
        evidence: ExecutionCostEvidence,
    },
}

#[derive(Debug, Clone)]
pub struct ModelCostEstimate {
    pub provider: String,
    pub model: String,
    pub prompt_bytes: u64,
    pub input_tokens_estimated: u64,
    pub output_tokens_estimated: u64,
    pub estimated_cost_usd: f64,
}

pub fn service_capability_profile(
    service_id: &str,
    input: &Value,
    manifest_capabilities: &[String],
) -> ServiceCapabilityProfile {
    let mut requested_capabilities = dedupe_strings(manifest_capabilities);
    let mut profile = ServiceCapabilityProfile {
        requested_capabilities: requested_capabilities.clone(),
        adapter_id: None,
        network_target_url: None,
        metadata: BTreeMap::new(),
    };

    if service_id != FLOW_SERVICE_ID {
        return profile;
    }

    let adapter = resolve_flow_adapter(input).unwrap_or_else(|| "native-octon".to_string());
    profile
        .metadata
        .insert("network_egress_service".to_string(), service_id.to_string());
    profile
        .metadata
        .insert("network_egress_adapter".to_string(), adapter.clone());
    profile.adapter_id = Some(adapter.clone());

    if adapter == FLOW_ADAPTER_LANGGRAPH_HTTP {
        let target_url = resolve_flow_runtime_url(input);
        profile
            .metadata
            .insert("network_egress_url".to_string(), target_url.clone());
        profile
            .metadata
            .insert("network_egress_method".to_string(), "POST".to_string());
        profile.network_target_url = Some(target_url);
    } else {
        requested_capabilities.retain(|cap| cap != "net.http");
        profile.requested_capabilities = dedupe_strings(&requested_capabilities);
    }

    profile
}

pub fn parse_network_target(url: &str) -> Result<ParsedNetworkTarget> {
    let (scheme, remainder) = if let Some(rest) = url.strip_prefix("http://") {
        ("http", rest)
    } else if let Some(rest) = url.strip_prefix("https://") {
        ("https", rest)
    } else {
        return Err(KernelError::new(
            ErrorCode::InvalidInput,
            format!("unsupported network target url scheme in '{url}'"),
        ));
    };

    let (authority, raw_path) = match remainder.find('/') {
        Some(index) => (&remainder[..index], &remainder[index..]),
        None => (remainder, "/"),
    };

    if authority.is_empty() {
        return Err(KernelError::new(
            ErrorCode::InvalidInput,
            format!("network target url missing authority in '{url}'"),
        ));
    }

    let (host, port) = if let Some((host, port)) = authority.rsplit_once(':') {
        if host.contains(':') {
            (authority.to_string(), default_port_for_scheme(scheme))
        } else {
            let parsed_port = port.parse::<u16>().map_err(|_| {
                KernelError::new(
                    ErrorCode::InvalidInput,
                    format!("network target url has invalid port in '{url}'"),
                )
            })?;
            (host.to_ascii_lowercase(), parsed_port)
        }
    } else {
        (authority.to_ascii_lowercase(), default_port_for_scheme(scheme))
    };

    Ok(ParsedNetworkTarget {
        scheme: scheme.to_string(),
        host,
        port,
        path: raw_path.to_string(),
    })
}

pub fn load_network_egress_policy(repo_root: &Path) -> Result<NetworkEgressPolicy> {
    load_yaml_or_default(
        &repo_root.join(".octon/instance/governance/policies/network-egress.yml"),
    )
}

pub fn load_execution_exception_leases(repo_root: &Path) -> Result<ExecutionExceptionLeases> {
    let canonical = repo_root.join(".octon/state/control/execution/exceptions/leases.yml");
    if canonical.is_file() {
        return load_yaml_or_default(&canonical);
    }
    load_yaml_or_default(&repo_root.join(".octon/state/control/execution/exception-leases.yml"))
}

pub fn load_execution_budget_policy(repo_root: &Path) -> Result<ExecutionBudgetPolicy> {
    load_yaml_or_default(
        &repo_root.join(".octon/instance/governance/policies/execution-budgets.yml"),
    )
}

pub fn load_execution_budget_state(control_root: &Path) -> Result<ExecutionBudgetState> {
    let path = control_root.join("budget-state.yml");
    if !path.is_file() {
        return Ok(ExecutionBudgetState::default());
    }
    let raw = fs::read_to_string(&path).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to read execution budget state {}: {e}", path.display()),
        )
    })?;
    serde_yaml::from_str(&raw).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to parse execution budget state {}: {e}", path.display()),
        )
    })
}

pub fn save_execution_budget_state(
    control_root: &Path,
    state: &ExecutionBudgetState,
) -> Result<PathBuf> {
    fs::create_dir_all(control_root).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to create execution control root {}: {e}",
                control_root.display()
            ),
        )
    })?;
    let path = control_root.join("budget-state.yml");
    let bytes = serde_yaml::to_string(state).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to serialize execution budget state: {e}"),
        )
    })?;
    fs::write(&path, bytes).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to write execution budget state {}: {e}", path.display()),
        )
    })?;
    Ok(path)
}

pub fn evaluate_network_egress(
    policy: &NetworkEgressPolicy,
    leases: &ExecutionExceptionLeases,
    context: &NetworkEgressContext<'_>,
    url: &str,
) -> Result<NetworkEgressDecision> {
    let parsed = parse_network_target(url)?;
    let method = context.method.to_ascii_uppercase();

    for rule in &policy.rules {
        if network_rule_matches(rule, context, &parsed, &method) {
            return Ok(NetworkEgressDecision {
                allowed: true,
                matched_rule_id: rule.id.clone(),
                reason: if rule.reason.trim().is_empty() {
                    "repo-owned network egress rule matched".to_string()
                } else {
                    rule.reason.clone()
                },
                source_kind: "policy".to_string(),
                artifact_ref: Some(".octon/instance/governance/policies/network-egress.yml".to_string()),
            });
        }
    }

    for lease in &leases.leases {
        if lease.lease_kind != "network-egress" && !lease.lease_kind.is_empty() {
            continue;
        }
        if !lease_is_active(lease)? {
            continue;
        }
        if network_lease_matches(lease, context, &parsed, &method) {
            return Ok(NetworkEgressDecision {
                allowed: true,
                matched_rule_id: lease.id.clone(),
                reason: lease
                    .reason
                    .clone()
                    .unwrap_or_else(|| "time-boxed network egress exception lease matched".to_string()),
                source_kind: "exception-lease".to_string(),
                artifact_ref: Some(format!(".octon/state/control/execution/exceptions/leases.yml#{}", lease.id)),
            });
        }
    }

    Err(KernelError::new(
        ErrorCode::CapabilityDenied,
        format!(
            "network egress denied for {} {}://{}:{}{}",
            method, parsed.scheme, parsed.host, parsed.port, parsed.path
        ),
    )
    .with_details(serde_json::json!({
        "reason_codes": ["NETWORK_EGRESS_DENIED"],
        "service_id": context.service_id,
        "adapter_id": context.adapter_id,
        "method": method,
        "url": url,
    })))
}

pub fn write_network_egress_event(run_root: &Path, event: &NetworkEgressEvent) -> Result<PathBuf> {
    fs::create_dir_all(run_root).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to create run root {}: {e}", run_root.display()),
        )
    })?;
    let path = run_root.join("network-egress.ndjson");
    let line = serde_json::to_string(event).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to encode network egress event: {e}"),
        )
    })?;
    let mut file = OpenOptions::new()
        .create(true)
        .append(true)
        .open(&path)
        .map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!("failed to open network egress log {}: {e}", path.display()),
            )
        })?;
    file.write_all(line.as_bytes()).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to write network egress log {}: {e}", path.display()),
        )
    })?;
    file.write_all(b"\n").map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to write network egress log {}: {e}", path.display()),
        )
    })?;
    Ok(path)
}

pub fn evaluate_execution_budget(
    policy: &ExecutionBudgetPolicy,
    context: &BudgetCheckContext<'_>,
) -> BudgetDecision {
    let Some(rule) = policy
        .rules
        .iter()
        .find(|rule| execution_budget_rule_matches(rule, context))
        .cloned()
    else {
        return BudgetDecision::Skip;
    };

    let estimate = estimate_model_cost(context.model, context.provider, context.prompt_bytes);
    let mut reason_codes = Vec::new();
    let mut evidence = ExecutionCostEvidence {
        schema_version: "execution-cost-evidence-v1".to_string(),
        request_id: context.request_id.to_string(),
        evaluated_at: now_rfc3339(),
        decision: "ALLOW".to_string(),
        reason_codes: Vec::new(),
        matched_rule_id: Some(rule.id.clone()),
        provider: estimate.as_ref().map(|item| item.provider.clone()),
        model: estimate.as_ref().map(|item| item.model.clone()),
        prompt_bytes: context.prompt_bytes,
        input_tokens_estimated: estimate.as_ref().map(|item| item.input_tokens_estimated),
        output_tokens_estimated: estimate.as_ref().map(|item| item.output_tokens_estimated),
        estimated_cost_usd: estimate.as_ref().map(|item| item.estimated_cost_usd),
        actual_cost_usd: None,
        estimation_basis: Some("heuristic-prompt-estimate".to_string()),
    };

    if rule.require_cost_evidence && estimate.is_none() {
        reason_codes.push("EXECUTION_COST_EVIDENCE_MISSING".to_string());
        evidence.reason_codes = reason_codes.clone();
        evidence.decision = normalize_budget_action(&policy.missing_cost_evidence_action);
        let message = format!(
            "execution budget rule '{}' requires cost evidence for model-backed execution",
            rule.id
        );
        return if evidence.decision == "STAGE_ONLY" {
            BudgetDecision::StageOnly {
                rule_id: rule.id,
                reason_codes,
                message,
                evidence,
            }
        } else {
            BudgetDecision::Deny {
                rule_id: rule.id,
                reason_codes,
                message,
                evidence,
            }
        };
    }

    let Some(estimate) = estimate else {
        return BudgetDecision::Allow {
            rule_id: rule.id,
            reason_codes,
            evidence,
        };
    };

    if let Some(max_prompt_bytes) = rule.thresholds.max_prompt_bytes {
        if estimate.prompt_bytes > max_prompt_bytes {
            let rule_id = rule.id.clone();
            reason_codes.push("EXECUTION_BUDGET_PROMPT_TOO_LARGE".to_string());
            evidence.reason_codes = reason_codes.clone();
            evidence.decision = "DENY".to_string();
            return BudgetDecision::Deny {
                rule_id: rule_id.clone(),
                reason_codes,
                message: format!(
                    "execution prompt exceeds max_prompt_bytes for budget rule '{}'",
                    rule_id
                ),
                evidence,
            };
        }
    }

    if let Some(max_tokens) = rule.thresholds.max_estimated_input_tokens {
        if estimate.input_tokens_estimated > max_tokens {
            let rule_id = rule.id.clone();
            reason_codes.push("EXECUTION_BUDGET_INPUT_TOKENS_EXCEEDED".to_string());
            evidence.reason_codes = reason_codes.clone();
            evidence.decision = "DENY".to_string();
            return BudgetDecision::Deny {
                rule_id: rule_id.clone(),
                reason_codes,
                message: format!(
                    "execution input token estimate exceeds budget rule '{}'",
                    rule_id
                ),
                evidence,
            };
        }
    }

    if let Some(deny_cost) = rule.thresholds.deny_estimated_cost_usd {
        if estimate.estimated_cost_usd >= deny_cost {
            let rule_id = rule.id.clone();
            reason_codes.push("EXECUTION_BUDGET_DENY_THRESHOLD_EXCEEDED".to_string());
            evidence.reason_codes = reason_codes.clone();
            evidence.decision = "DENY".to_string();
            return BudgetDecision::Deny {
                rule_id: rule_id.clone(),
                reason_codes,
                message: format!(
                    "estimated execution cost exceeds deny threshold for budget rule '{}'",
                    rule_id
                ),
                evidence,
            };
        }
    }

    if let Some(stage_cost) = rule.thresholds.stage_estimated_cost_usd {
        if estimate.estimated_cost_usd >= stage_cost {
            let rule_id = rule.id.clone();
            reason_codes.push("EXECUTION_BUDGET_STAGE_THRESHOLD_EXCEEDED".to_string());
            evidence.reason_codes = reason_codes.clone();
            evidence.decision = "STAGE_ONLY".to_string();
            return BudgetDecision::StageOnly {
                rule_id: rule_id.clone(),
                reason_codes,
                message: format!(
                    "estimated execution cost exceeds stage threshold for budget rule '{}'",
                    rule_id
                ),
                evidence,
            };
        }
    }

    if let Some(warn_cost) = rule.thresholds.warn_estimated_cost_usd {
        if estimate.estimated_cost_usd >= warn_cost {
            reason_codes.push("EXECUTION_BUDGET_WARN_THRESHOLD_EXCEEDED".to_string());
        }
    }

    evidence.reason_codes = reason_codes.clone();
    BudgetDecision::Allow {
        rule_id: rule.id,
        reason_codes,
        evidence,
    }
}

pub fn write_execution_cost_evidence(
    run_root: &Path,
    evidence: &ExecutionCostEvidence,
) -> Result<PathBuf> {
    fs::create_dir_all(run_root).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to create run root {}: {e}", run_root.display()),
        )
    })?;
    let path = run_root.join("cost.json");
    let bytes = serde_json::to_vec_pretty(evidence).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to encode execution cost evidence: {e}"),
        )
    })?;
    fs::write(&path, bytes).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to write execution cost evidence {}: {e}", path.display()),
        )
    })?;
    Ok(path)
}

pub fn record_budget_consumption(
    control_root: &Path,
    rule_id: &str,
    evidence: &ExecutionCostEvidence,
) -> Result<PathBuf> {
    let mut state = load_execution_budget_state(control_root)?;
    let counter = state.rules.entry(rule_id.to_string()).or_default();
    counter.run_count += 1;
    counter.consumed_estimated_cost_usd += evidence.estimated_cost_usd.unwrap_or(0.0);
    counter.consumed_actual_cost_usd += evidence.actual_cost_usd.unwrap_or(0.0);
    counter.last_request_id = Some(evidence.request_id.clone());
    counter.last_decision = Some(evidence.decision.clone());
    counter.last_updated_at = Some(now_rfc3339());
    state.updated_at = now_rfc3339();
    save_execution_budget_state(control_root, &state)
}

pub fn infer_provider_from_model(model: Option<&str>, executor_hint: Option<&str>) -> Option<String> {
    if let Some(model) = model {
        let normalized = model.trim().to_ascii_lowercase();
        if normalized.starts_with("claude") {
            return Some("anthropic".to_string());
        }
        if normalized.starts_with("gpt")
            || normalized.starts_with("o1")
            || normalized.starts_with("o3")
            || normalized.starts_with("codex")
        {
            return Some("openai".to_string());
        }
        if normalized.starts_with("gemini") {
            return Some("google".to_string());
        }
        if normalized.starts_with("mistral") || normalized.starts_with("codestral") {
            return Some("mistral".to_string());
        }
        if normalized.starts_with("local") || normalized.starts_with("ollama") {
            return Some("local".to_string());
        }
    }

    executor_hint.and_then(|hint| match hint {
        "codex" => Some("openai".to_string()),
        "claude" => Some("anthropic".to_string()),
        _ => None,
    })
}

pub fn estimate_model_cost(
    model: Option<&str>,
    provider: Option<&str>,
    prompt_bytes: Option<u64>,
) -> Option<ModelCostEstimate> {
    let prompt_bytes = prompt_bytes?;
    let model = model
        .map(|value| value.trim().to_string())
        .filter(|value| !value.is_empty())?;
    let provider = provider
        .map(|value| value.trim().to_string())
        .filter(|value| !value.is_empty())
        .or_else(|| infer_provider_from_model(Some(&model), None))
        .unwrap_or_else(|| "unknown".to_string());

    let input_tokens_estimated = ((prompt_bytes.max(1) + 3) / 4).max(1);
    let output_tokens_estimated = input_tokens_estimated.clamp(256, 4096) / 2;
    let (input_price, output_price) = pricing_for_model(&model, &provider);
    let estimated_cost_usd = (((input_tokens_estimated as f64) / 1_000_000.0) * input_price)
        + (((output_tokens_estimated as f64) / 1_000_000.0) * output_price);

    Some(ModelCostEstimate {
        provider,
        model,
        prompt_bytes,
        input_tokens_estimated,
        output_tokens_estimated,
        estimated_cost_usd,
    })
}

fn load_yaml_or_default<T>(path: &Path) -> Result<T>
where
    T: for<'de> Deserialize<'de> + Default,
{
    if !path.is_file() {
        return Ok(T::default());
    }
    let raw = fs::read_to_string(path).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to read {}: {e}", path.display()),
        )
    })?;
    serde_yaml::from_str(&raw).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to parse {}: {e}", path.display()),
        )
    })
}

fn default_port_for_scheme(scheme: &str) -> u16 {
    match scheme {
        "https" => 443,
        _ => 80,
    }
}

fn resolve_flow_adapter(input: &Value) -> Option<String> {
    input
        .get("adapter")
        .and_then(|value| value.as_str())
        .filter(|value| !value.trim().is_empty())
        .map(|value| value.trim().to_string())
        .or_else(|| {
            input
                .get("config")
                .and_then(|value| value.get("runtime"))
                .and_then(|value| value.get("adapter"))
                .and_then(|value| value.as_str())
                .filter(|value| !value.trim().is_empty())
                .map(|value| value.trim().to_string())
        })
        .or_else(|| {
            input
                .get("config")
                .and_then(|value| value.get("runtime"))
                .and_then(|value| value.get("type"))
                .and_then(|value| value.as_str())
                .filter(|value| !value.trim().is_empty())
                .map(|value| value.trim().to_string())
        })
}

fn resolve_flow_runtime_url(input: &Value) -> String {
    input
        .get("config")
        .and_then(|value| value.get("runtime"))
        .and_then(|value| value.get("url"))
        .and_then(|value| value.as_str())
        .filter(|value| !value.trim().is_empty())
        .map(|value| {
            let trimmed = value.trim().trim_end_matches('/');
            if trimmed.ends_with("/flows/run") {
                trimmed.to_string()
            } else {
                format!("{trimmed}/flows/run")
            }
        })
        .unwrap_or_else(|| FLOW_DEFAULT_RUNTIME_URL.to_string())
}

fn dedupe_strings(values: &[String]) -> Vec<String> {
    let mut seen = BTreeSet::new();
    values
        .iter()
        .filter(|value| seen.insert((*value).clone()))
        .cloned()
        .collect()
}

fn network_rule_matches(
    rule: &NetworkEgressRule,
    context: &NetworkEgressContext<'_>,
    target: &ParsedNetworkTarget,
    method: &str,
) -> bool {
    if !rule.services.is_empty() && !rule.services.iter().any(|value| value == context.service_id) {
        return false;
    }
    if !rule.adapters.is_empty()
        && !context
            .adapter_id
            .map(|value| rule.adapters.iter().any(|candidate| candidate == value))
            .unwrap_or(false)
    {
        return false;
    }
    if !rule.executor_profiles.is_empty()
        && !context
            .executor_profile
            .map(|value| {
                rule.executor_profiles
                    .iter()
                    .any(|candidate| candidate == value)
            })
            .unwrap_or(false)
    {
        return false;
    }
    if !rule.methods.is_empty()
        && !rule
            .methods
            .iter()
            .any(|candidate| candidate.eq_ignore_ascii_case(method))
    {
        return false;
    }
    if !rule.schemes.is_empty()
        && !rule
            .schemes
            .iter()
            .any(|candidate| candidate.eq_ignore_ascii_case(&target.scheme))
    {
        return false;
    }
    if !rule.hosts.is_empty()
        && !rule
            .hosts
            .iter()
            .any(|candidate| candidate.eq_ignore_ascii_case(&target.host))
    {
        return false;
    }
    if !rule.ports.is_empty() && !rule.ports.iter().any(|candidate| *candidate == target.port) {
        return false;
    }
    if !rule.path_prefixes.is_empty()
        && !rule
            .path_prefixes
            .iter()
            .any(|candidate| target.path.starts_with(candidate))
    {
        return false;
    }
    true
}

fn lease_is_active(lease: &ExecutionExceptionLease) -> Result<bool> {
    if !lease.state.trim().is_empty() && lease.state != "active" {
        return Ok(false);
    }
    let expires_at = OffsetDateTime::parse(&lease.expires_at, &Rfc3339).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("invalid execution exception lease expiry '{}': {e}", lease.expires_at),
        )
    })?;
    Ok(expires_at > OffsetDateTime::now_utc())
}

fn network_lease_matches(
    lease: &ExecutionExceptionLease,
    context: &NetworkEgressContext<'_>,
    target: &ParsedNetworkTarget,
    method: &str,
) -> bool {
    if let Some(service) = &lease.service {
        if service != context.service_id {
            return false;
        }
    }
    if let Some(adapter) = &lease.adapter {
        if context.adapter_id != Some(adapter.as_str()) {
            return false;
        }
    }
    if let Some(lease_method) = &lease.method {
        if !lease_method.eq_ignore_ascii_case(method) {
            return false;
        }
    }
    if let Some(scheme) = &lease.scheme {
        if !scheme.eq_ignore_ascii_case(&target.scheme) {
            return false;
        }
    }
    if let Some(host) = &lease.host {
        if !host.eq_ignore_ascii_case(&target.host) {
            return false;
        }
    }
    if let Some(port) = lease.port {
        if port != target.port {
            return false;
        }
    }
    if let Some(path_prefix) = &lease.path_prefix {
        if !target.path.starts_with(path_prefix) {
            return false;
        }
    }
    true
}

fn execution_budget_rule_matches(
    rule: &ExecutionBudgetRule,
    context: &BudgetCheckContext<'_>,
) -> bool {
    if !rule.path_types.is_empty() && !rule.path_types.iter().any(|value| value == context.path_type) {
        return false;
    }
    if !rule.action_types.is_empty()
        && !rule
            .action_types
            .iter()
            .any(|value| value == context.action_type)
    {
        return false;
    }
    if !rule.executor_profiles.is_empty()
        && !context
            .executor_profile
            .map(|value| rule.executor_profiles.iter().any(|candidate| candidate == value))
            .unwrap_or(false)
    {
        return false;
    }
    if !rule.providers.is_empty()
        && !context
            .provider
            .map(|value| rule.providers.iter().any(|candidate| candidate == value))
            .unwrap_or(false)
    {
        return false;
    }
    if !rule.model_patterns.is_empty()
        && !context
            .model
            .map(|value| {
                rule.model_patterns
                    .iter()
                    .any(|pattern| model_pattern_matches(pattern, value))
            })
            .unwrap_or(false)
    {
        return false;
    }
    true
}

fn model_pattern_matches(pattern: &str, value: &str) -> bool {
    if let Some(prefix) = pattern.strip_suffix('*') {
        return value.starts_with(prefix);
    }
    pattern == value
}

fn default_missing_cost_action() -> String {
    "deny".to_string()
}

fn normalize_budget_action(value: &str) -> String {
    match value {
        "stage" | "stage_only" | "STAGE_ONLY" => "STAGE_ONLY".to_string(),
        _ => "DENY".to_string(),
    }
}

fn pricing_for_model(model: &str, provider: &str) -> (f64, f64) {
    let normalized = model.to_ascii_lowercase();
    match normalized.as_str() {
        "gpt-4o" => (2.5, 10.0),
        "gpt-4o-mini" | "gpt-4o-mini-2024-07-18" | "gpt-3.5-turbo" => (0.15, 0.6),
        "o1" => (15.0, 60.0),
        "o1-mini" => (3.0, 12.0),
        "o3-mini" => (1.1, 4.4),
        "claude-sonnet" | "claude-3-5-sonnet-20241022" => (3.0, 15.0),
        "claude-haiku" | "claude-3-5-haiku-20241022" => (0.8, 4.0),
        "gemini-2.0-flash" => (0.1, 0.4),
        "mistral-large" => (2.0, 6.0),
        "mistral-small" | "codestral" => (0.2, 0.6),
        value if value.starts_with("ollama-") || value.starts_with("local-") => (0.0, 0.0),
        _ => match provider {
            "anthropic" => (3.0, 15.0),
            "google" => (0.1, 0.4),
            "mistral" => (0.2, 0.6),
            "local" => (0.0, 0.0),
            _ => (0.15, 0.6),
        },
    }
}

fn now_rfc3339() -> String {
    OffsetDateTime::now_utc()
        .format(&Rfc3339)
        .unwrap_or_else(|_| "1970-01-01T00:00:00Z".to_string())
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    #[test]
    fn flow_native_profile_omits_net_http() {
        let manifest_caps = vec![
            "log.write".to_string(),
            "fs.read".to_string(),
            "fs.write".to_string(),
            "net.http".to_string(),
        ];
        let profile = service_capability_profile(
            FLOW_SERVICE_ID,
            &json!({
                "config": {
                    "runtime": {
                        "type": "native-octon"
                    }
                }
            }),
            &manifest_caps,
        );

        assert!(!profile
            .requested_capabilities
            .iter()
            .any(|value| value == "net.http"));
    }

    #[test]
    fn flow_langgraph_profile_requests_net_http_and_default_url() {
        let manifest_caps = vec![
            "log.write".to_string(),
            "fs.read".to_string(),
            "fs.write".to_string(),
            "net.http".to_string(),
        ];
        let profile = service_capability_profile(
            FLOW_SERVICE_ID,
            &json!({
                "adapter": "langgraph-http",
                "config": {
                    "runtime": {
                        "type": "langgraph-http"
                    }
                }
            }),
            &manifest_caps,
        );

        assert!(profile
            .requested_capabilities
            .iter()
            .any(|value| value == "net.http"));
        assert_eq!(
            profile.network_target_url.as_deref(),
            Some("http://127.0.0.1:8410/flows/run")
        );
    }

    #[test]
    fn network_egress_rule_must_match_service_and_target() {
        let policy = NetworkEgressPolicy {
            schema_version: "network-egress-policy-v1".to_string(),
            rules: vec![NetworkEgressRule {
                id: "langgraph".to_string(),
                services: vec![FLOW_SERVICE_ID.to_string()],
                adapters: vec![FLOW_ADAPTER_LANGGRAPH_HTTP.to_string()],
                executor_profiles: Vec::new(),
                methods: vec!["POST".to_string()],
                schemes: vec!["http".to_string()],
                hosts: vec!["127.0.0.1".to_string()],
                ports: vec![8410],
                path_prefixes: vec!["/flows/run".to_string()],
                reason: "fixture".to_string(),
            }],
        };
        let leases = ExecutionExceptionLeases::default();

        let allow = evaluate_network_egress(
            &policy,
            &leases,
            &NetworkEgressContext {
                service_id: FLOW_SERVICE_ID,
                adapter_id: Some(FLOW_ADAPTER_LANGGRAPH_HTTP),
                executor_profile: None,
                method: "POST",
            },
            "http://127.0.0.1:8410/flows/run",
        )
        .expect("matching local langgraph target should allow");
        assert_eq!(allow.matched_rule_id, "langgraph");

        let deny = evaluate_network_egress(
            &policy,
            &leases,
            &NetworkEgressContext {
                service_id: FLOW_SERVICE_ID,
                adapter_id: Some(FLOW_ADAPTER_LANGGRAPH_HTTP),
                executor_profile: None,
                method: "POST",
            },
            "http://example.com:8410/flows/run",
        );
        assert!(deny.is_err());
    }

    #[test]
    fn budget_policy_stages_large_estimates() {
        let policy = ExecutionBudgetPolicy {
            schema_version: "execution-budgets-v1".to_string(),
            missing_cost_evidence_action: "stage_only".to_string(),
            rules: vec![ExecutionBudgetRule {
                id: "workflow-stage-openai".to_string(),
                path_types: vec!["workflow-stage".to_string()],
                action_types: Vec::new(),
                executor_profiles: vec!["read_only_analysis".to_string()],
                providers: vec!["openai".to_string()],
                model_patterns: Vec::new(),
                require_cost_evidence: true,
                reason: "fixture".to_string(),
                thresholds: ExecutionBudgetThresholds {
                    warn_estimated_cost_usd: Some(0.01),
                    stage_estimated_cost_usd: Some(0.02),
                    deny_estimated_cost_usd: Some(100.0),
                    max_prompt_bytes: None,
                    max_estimated_input_tokens: None,
                },
            }],
        };

        let decision = evaluate_execution_budget(
            &policy,
            &BudgetCheckContext {
                request_id: "req-1",
                path_type: "workflow-stage",
                action_type: "execute_stage",
                executor_profile: Some("read_only_analysis"),
                provider: Some("openai"),
                model: Some("gpt-4o"),
                prompt_bytes: Some(80_000),
            },
        );

        match decision {
            BudgetDecision::StageOnly { rule_id, .. } => {
                assert_eq!(rule_id, "workflow-stage-openai");
            }
            other => panic!("expected stage-only decision, got {:?}", other),
        }
    }

    #[test]
    fn budget_policy_treats_missing_model_as_missing_cost_evidence() {
        let policy = ExecutionBudgetPolicy {
            schema_version: "execution-budgets-v1".to_string(),
            missing_cost_evidence_action: "stage_only".to_string(),
            rules: vec![ExecutionBudgetRule {
                id: "workflow-stage-openai".to_string(),
                path_types: vec!["workflow-stage".to_string()],
                action_types: Vec::new(),
                executor_profiles: vec!["read_only_analysis".to_string()],
                providers: vec!["openai".to_string()],
                model_patterns: Vec::new(),
                require_cost_evidence: true,
                reason: "fixture".to_string(),
                thresholds: ExecutionBudgetThresholds::default(),
            }],
        };

        let decision = evaluate_execution_budget(
            &policy,
            &BudgetCheckContext {
                request_id: "req-2",
                path_type: "workflow-stage",
                action_type: "execute_stage",
                executor_profile: Some("read_only_analysis"),
                provider: Some("openai"),
                model: None,
                prompt_bytes: Some(4096),
            },
        );

        match decision {
            BudgetDecision::StageOnly { reason_codes, .. } => {
                assert!(reason_codes
                    .iter()
                    .any(|value| value == "EXECUTION_COST_EVIDENCE_MISSING"));
            }
            other => panic!("expected stage-only for missing model, got {:?}", other),
        }
    }
}
