use anyhow::{anyhow, Context, Result};
use glob::Pattern;
use jsonschema::JSONSchema;
use serde::de::DeserializeOwned;
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::collections::{BTreeSet, HashMap, HashSet};
use std::fs;
use std::path::{Path, PathBuf};
use time::format_description;

pub const ALLOWED_ATOM_TOOLS: &[&str] = &[
    "Read",
    "Glob",
    "Grep",
    "Edit",
    "WebFetch",
    "WebSearch",
    "Task",
    "Shell",
    "Bash",
    "Write",
];

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PolicyV2 {
    pub schema_version: String,
    pub mode: String,
    pub defaults: PolicyDefaults,
    pub exceptions: ExceptionsConfig,
    pub grants: GrantsConfig,
    pub agent_only: AgentOnlyConfig,
    pub kill_switch: KillSwitchConfig,
    pub profiles: HashMap<String, ProfileConfig>,
    pub observability: ObservabilityConfig,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PolicyDefaults {
    pub fail_closed: bool,
    pub deny_unknown_tokens: bool,
    pub deny_unscoped_bash: bool,
    pub deny_unscoped_write: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExceptionsConfig {
    pub state_file: String,
    pub require_owner: bool,
    pub require_reason: bool,
    pub require_created: bool,
    pub require_expires: bool,
    pub max_lease_days: i64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GrantsConfig {
    pub state_dir: String,
    pub default_ttl_seconds: u64,
    pub max_ttl_seconds_by_tier: TierTtls,
    pub allow_auto_grant_low: bool,
    pub allow_auto_grant_medium: bool,
    pub allow_auto_grant_high: bool,
    pub require_provenance: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TierTtls {
    pub low: u64,
    pub medium: u64,
    pub high: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AgentOnlyConfig {
    pub enabled: bool,
    pub risk_tiers: RiskTiers,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RiskTiers {
    pub low: RiskTierConfig,
    pub medium: RiskTierConfig,
    pub high: RiskTierConfig,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RiskTierConfig {
    pub min_distinct_agents: usize,
    pub require_review: bool,
    pub require_quorum_token: bool,
    pub require_rollback_plan: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct KillSwitchConfig {
    pub state_dir: String,
    pub fail_closed: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProfileConfig {
    pub description: String,
    pub auto_grant_tier: String,
    pub tool_bundle: Vec<String>,
    pub write_scope_bundle: Vec<String>,
    pub service_allowlist: Vec<String>,
    pub deny_rules: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ObservabilityConfig {
    pub decision_log_path: String,
    pub friction_slo: FrictionSlo,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FrictionSlo {
    pub false_deny_rate_max: f64,
    pub median_deny_to_unblock_seconds_max: u64,
    pub auto_remediation_success_rate_min: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExceptionLeaseFile {
    pub exceptions: Vec<ExceptionLease>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExceptionLease {
    pub id: Option<String>,
    pub scope: String,
    pub target: String,
    pub rule: String,
    pub owner: Option<String>,
    pub reason: Option<String>,
    pub created: Option<String>,
    pub expires: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct KillSwitchRecord {
    pub id: Option<String>,
    pub scope: String,
    pub state: Option<String>,
    pub owner: Option<String>,
    pub reason: Option<String>,
    pub created: Option<String>,
    pub expires: Option<String>,
    pub incident_id: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ServicesManifest {
    pub services: Vec<ServiceManifestEntry>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ServiceManifestEntry {
    pub id: String,
    pub path: String,
    pub status: String,
    pub interface_type: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SkillsManifest {
    pub skills: Vec<SkillManifestEntry>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SkillManifestEntry {
    pub id: String,
    pub path: String,
    pub status: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DenyPayload {
    pub code: String,
    pub message: String,
    pub scope: String,
    pub target: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub missing_scope: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub expected_token: Option<String>,
    pub remediation_hint: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub risk_tier: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Decision {
    pub allow: bool,
    pub mode: String,
    #[serde(default, skip_serializing_if = "is_false")]
    pub shadow_deny: bool,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub deny: Option<DenyPayload>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub notes: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum ScopeKind {
    Service,
    Skill,
}

impl ScopeKind {
    pub fn as_str(&self) -> &'static str {
        match self {
            ScopeKind::Service => "service",
            ScopeKind::Skill => "skill",
        }
    }
}

#[derive(Debug, Clone)]
pub struct PreflightRequest {
    pub kind: ScopeKind,
    pub target_id: String,
    pub manifest_path: PathBuf,
    pub artifact_path: PathBuf,
    pub policy_path: PathBuf,
    pub exceptions_path: Option<PathBuf>,
}

#[derive(Debug, Clone)]
pub struct EnforceRequest {
    pub preflight: PreflightRequest,
    pub requested_command: Option<String>,
    pub risk_tier: String,
    pub agent_id: Option<String>,
    pub agent_ids_csv: Option<String>,
    pub review_agent_id: Option<String>,
    pub quorum_token: Option<String>,
    pub rollback_plan_id: Option<String>,
    pub category: Option<String>,
}

#[derive(Debug, Clone)]
pub struct GrantEvalRequest {
    pub policy_path: PathBuf,
    pub tier: String,
    pub requested_tools: Vec<String>,
    pub requested_write_scopes: Vec<String>,
    pub requested_ttl_seconds: Option<u64>,
    pub has_review_evidence: bool,
    pub has_quorum_evidence: bool,
    pub request_id: Option<String>,
    pub agent_id: Option<String>,
    pub plan_step_id: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GrantEvalResult {
    pub allow: bool,
    pub tier: String,
    pub mode: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub deny: Option<DenyPayload>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub effective_ttl_seconds: Option<u64>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub notes: Vec<String>,
}

#[derive(Debug, Clone)]
pub struct DoctorRequest {
    pub policy_path: PathBuf,
    pub schema_path: PathBuf,
    pub reason_codes_path: Option<PathBuf>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DoctorReport {
    pub valid: bool,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub schema_errors: Vec<String>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub semantic_errors: Vec<String>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub warnings: Vec<String>,
}

#[derive(Debug, Clone)]
struct ArtifactContext {
    status: String,
    interface_type: Option<String>,
    allowed_tools: Vec<String>,
    fail_closed: Option<String>,
    bash_scopes: Vec<String>,
    has_broad_write: bool,
}

fn is_false(value: &bool) -> bool {
    !*value
}

pub fn today_ymd_utc() -> Result<String> {
    let format = format_description::parse("[year]-[month]-[day]")?;
    Ok(time::OffsetDateTime::now_utc().format(&format)?)
}

pub fn load_policy(path: &Path) -> Result<PolicyV2> {
    let mut policy: PolicyV2 = load_yaml(path)?;

    if let Ok(mode_override) = std::env::var("HARMONY_POLICY_MODE_OVERRIDE") {
        let normalized = mode_override.trim().to_lowercase();
        if matches!(normalized.as_str(), "shadow" | "soft-enforce" | "hard-enforce") {
            policy.mode = normalized;
        }
    }

    Ok(policy)
}

pub fn load_profile<'a>(policy: &'a PolicyV2, profile_id: &str) -> Option<&'a ProfileConfig> {
    policy.profiles.get(profile_id)
}

pub fn split_allowed_tools(raw: &str) -> Vec<String> {
    let mut tokens = Vec::new();
    let mut token = String::new();
    let mut depth: i64 = 0;

    for ch in raw.chars() {
        match ch {
            '(' => {
                depth += 1;
                token.push(ch);
            }
            ')' => {
                if depth > 0 {
                    depth -= 1;
                }
                token.push(ch);
            }
            ' ' | '\t' if depth == 0 => {
                if !token.trim().is_empty() {
                    tokens.push(token.trim().to_string());
                    token.clear();
                }
            }
            _ => token.push(ch),
        }
    }

    if !token.trim().is_empty() {
        tokens.push(token.trim().to_string());
    }

    tokens
}

pub fn is_known_tool_token(token: &str) -> bool {
    if ALLOWED_ATOM_TOOLS.contains(&token) {
        return true;
    }
    if token.starts_with("pack:") {
        return true;
    }
    if token.starts_with("Bash(") && token.ends_with(')') {
        return true;
    }
    if token.starts_with("Write(") && token.ends_with(')') {
        return true;
    }
    false
}

pub fn bash_scope_from_token(token: &str) -> Option<String> {
    if token.starts_with("Bash(") && token.ends_with(')') {
        let scope = token.trim_start_matches("Bash(").trim_end_matches(')');
        return Some(scope.to_string());
    }
    None
}

pub fn write_scope_from_token(token: &str) -> Option<String> {
    if token.starts_with("Write(") && token.ends_with(')') {
        let scope = token.trim_start_matches("Write(").trim_end_matches(')');
        return Some(scope.to_string());
    }
    None
}

pub fn evaluate_preflight(request: &PreflightRequest) -> Result<Decision> {
    let policy = load_policy(&request.policy_path)
        .with_context(|| format!("failed to load policy {}", request.policy_path.display()))?;

    let exceptions_path = request
        .exceptions_path
        .clone()
        .unwrap_or_else(|| PathBuf::from(&policy.exceptions.state_file));

    let exceptions = load_exceptions(&exceptions_path)?;
    let artifact = load_artifact_context(request)?;
    let today = today_ymd_utc()?;

    let mut decision = match request.kind {
        ScopeKind::Service => evaluate_service_preflight(&policy, request, &artifact, &exceptions, &today),
        ScopeKind::Skill => evaluate_skill_preflight(&policy, request, &artifact, &exceptions, &today),
    };

    apply_mode(&policy.mode, &mut decision);
    Ok(decision)
}

pub fn evaluate_enforce(request: &EnforceRequest) -> Result<Decision> {
    let policy = load_policy(&request.preflight.policy_path).with_context(|| {
        format!(
            "failed to load policy {}",
            request.preflight.policy_path.display()
        )
    })?;

    let exceptions_path = request
        .preflight
        .exceptions_path
        .clone()
        .unwrap_or_else(|| PathBuf::from(&policy.exceptions.state_file));
    let exceptions = load_exceptions(&exceptions_path)?;
    let artifact = load_artifact_context(&request.preflight)?;
    let today = today_ymd_utc()?;

    let mut decision = match request.preflight.kind {
        ScopeKind::Service => evaluate_service_preflight(
            &policy,
            &request.preflight,
            &artifact,
            &exceptions,
            &today,
        ),
        ScopeKind::Skill => evaluate_skill_preflight(
            &policy,
            &request.preflight,
            &artifact,
            &exceptions,
            &today,
        ),
    };

    if !decision.allow {
        apply_mode(&policy.mode, &mut decision);
        return Ok(decision);
    }

    if matches!(request.preflight.kind, ScopeKind::Service)
        && artifact
            .interface_type
            .as_deref()
            .map(|value| value == "shell")
            .unwrap_or(false)
    {
        if let Some(command) = &request.requested_command {
            let command_allowed = artifact
                .bash_scopes
                .iter()
                .any(|scope| matches_bash_scope(scope, command));
            if !command_allowed {
                decision = deny(
                    "hard-enforce",
                    "DDB007_BASH_SCOPE_DENIED",
                    "Command invocation not permitted by declared Bash scopes",
                    "service",
                    &request.preflight.target_id,
                    Some(format!("Bash({command})")),
                    Some(format!("Bash({command})")),
                    "Add a minimal Bash scope for this command or run with a matching profile",
                    Some(request.risk_tier.clone()),
                );
            }
        }
    }

    if decision.allow && matches!(request.preflight.kind, ScopeKind::Service) {
        let agent_decision = evaluate_agent_only(&policy, request, &today)?;
        if !agent_decision.allow {
            decision = agent_decision;
        }
    }

    apply_mode(&policy.mode, &mut decision);
    Ok(decision)
}

pub fn evaluate_grant(request: &GrantEvalRequest) -> Result<GrantEvalResult> {
    let policy = load_policy(&request.policy_path)
        .with_context(|| format!("failed to load policy {}", request.policy_path.display()))?;

    let tier = request.tier.to_lowercase();
    if !matches!(tier.as_str(), "low" | "medium" | "high") {
        return Ok(GrantEvalResult {
            allow: false,
            tier,
            mode: policy.mode,
            deny: Some(make_deny(
                "DDB022_GRANT_TIER_REVIEW_REQUIRED",
                "Invalid grant tier",
                "grant",
                "request",
                None,
                None,
                "Use low, medium, or high tier",
                None,
            )),
            effective_ttl_seconds: None,
            notes: Vec::new(),
        });
    }

    for token in &request.requested_tools {
        if !is_known_tool_token(token) {
            return Ok(GrantEvalResult {
                allow: false,
                tier,
                mode: policy.mode,
                deny: Some(make_deny(
                    "DDB003_UNKNOWN_TOOL_TOKEN",
                    "Grant request contains unknown tool token",
                    "grant",
                    "request",
                    None,
                    Some(token.clone()),
                    "Use approved tool tokens only",
                    None,
                )),
                effective_ttl_seconds: None,
                notes: Vec::new(),
            });
        }
    }

    if request
        .requested_write_scopes
        .iter()
        .any(|scope| scope.contains("**"))
    {
        return Ok(GrantEvalResult {
            allow: false,
            tier,
            mode: policy.mode,
            deny: Some(make_deny(
                "DDB021_GRANT_SCOPE_TOO_BROAD",
                "Grant request includes broad write scope",
                "grant",
                "request",
                None,
                None,
                "Request minimal write scopes without recursive wildcard",
                None,
            )),
            effective_ttl_seconds: None,
            notes: Vec::new(),
        });
    }

    if policy.grants.require_provenance
        && (request.request_id.is_none() || request.agent_id.is_none() || request.plan_step_id.is_none())
    {
        return Ok(GrantEvalResult {
            allow: false,
            tier,
            mode: policy.mode,
            deny: Some(make_deny(
                "DDB013_AGENT_ID_MISSING",
                "Grant request missing provenance metadata",
                "grant",
                "request",
                None,
                None,
                "Provide request_id, agent_id, and plan_step_id",
                None,
            )),
            effective_ttl_seconds: None,
            notes: Vec::new(),
        });
    }

    let requested_ttl = request
        .requested_ttl_seconds
        .unwrap_or(policy.grants.default_ttl_seconds);
    let max_ttl = match tier.as_str() {
        "low" => policy.grants.max_ttl_seconds_by_tier.low,
        "medium" => policy.grants.max_ttl_seconds_by_tier.medium,
        "high" => policy.grants.max_ttl_seconds_by_tier.high,
        _ => policy.grants.default_ttl_seconds,
    };

    if requested_ttl > max_ttl {
        return Ok(GrantEvalResult {
            allow: false,
            tier,
            mode: policy.mode,
            deny: Some(make_deny(
                "DDB021_GRANT_SCOPE_TOO_BROAD",
                "Requested grant TTL exceeds policy maximum",
                "grant",
                "request",
                None,
                None,
                "Request a shorter TTL or lower-risk scope",
                None,
            )),
            effective_ttl_seconds: None,
            notes: Vec::new(),
        });
    }

    if (tier == "medium" || tier == "high") && !request.has_review_evidence {
        return Ok(GrantEvalResult {
            allow: false,
            tier,
            mode: policy.mode,
            deny: Some(make_deny(
                "DDB022_GRANT_TIER_REVIEW_REQUIRED",
                "Medium/high grants require review evidence",
                "grant",
                "request",
                None,
                None,
                "Attach review evidence or use low-risk profile",
                None,
            )),
            effective_ttl_seconds: None,
            notes: Vec::new(),
        });
    }

    if tier == "high" && !request.has_quorum_evidence {
        return Ok(GrantEvalResult {
            allow: false,
            tier,
            mode: policy.mode,
            deny: Some(make_deny(
                "DDB022_GRANT_TIER_REVIEW_REQUIRED",
                "High-risk grants require quorum evidence",
                "grant",
                "request",
                None,
                None,
                "Attach quorum evidence for high-risk grant",
                None,
            )),
            effective_ttl_seconds: None,
            notes: Vec::new(),
        });
    }

    let auto_grant_enabled = match tier.as_str() {
        "low" => policy.grants.allow_auto_grant_low,
        "medium" => policy.grants.allow_auto_grant_medium,
        "high" => policy.grants.allow_auto_grant_high,
        _ => false,
    };

    if !auto_grant_enabled {
        return Ok(GrantEvalResult {
            allow: false,
            tier,
            mode: policy.mode,
            deny: Some(make_deny(
                "DDB022_GRANT_TIER_REVIEW_REQUIRED",
                "Auto-grant disabled for requested tier",
                "grant",
                "request",
                None,
                None,
                "Use explicit review/quorum grant path",
                None,
            )),
            effective_ttl_seconds: None,
            notes: Vec::new(),
        });
    }

    Ok(GrantEvalResult {
        allow: true,
        tier,
        mode: policy.mode,
        deny: None,
        effective_ttl_seconds: Some(requested_ttl),
        notes: vec!["grant-policy-pass".to_string()],
    })
}

pub fn doctor(request: &DoctorRequest) -> Result<DoctorReport> {
    let schema_json = load_json_value(&request.schema_path)?;
    let policy_yaml = load_yaml_value(&request.policy_path)?;

    let compiled = JSONSchema::compile(&schema_json)
        .map_err(|err| anyhow!("failed to compile schema: {err}"))?;

    let mut schema_errors = Vec::new();
    if let Err(errors) = compiled.validate(&policy_yaml) {
        for err in errors {
            schema_errors.push(err.to_string());
        }
    }

    let mut semantic_errors = Vec::new();
    let mut warnings = Vec::new();

    let policy_typed: Option<PolicyV2> = if schema_errors.is_empty() {
        match load_policy(&request.policy_path) {
            Ok(policy) => Some(policy),
            Err(err) => {
                semantic_errors.push(format!("failed to parse typed policy: {err}"));
                None
            }
        }
    } else {
        None
    };

    if let Some(policy) = &policy_typed {
        if !policy
            .exceptions
            .state_file
            .starts_with(".harmony/capabilities/_ops/state/")
        {
            semantic_errors.push(
                "exceptions.state_file must remain under .harmony/capabilities/_ops/state/".to_string(),
            );
        }

        if !policy
            .grants
            .state_dir
            .starts_with(".harmony/capabilities/_ops/state/")
        {
            semantic_errors.push(
                "grants.state_dir must remain under .harmony/capabilities/_ops/state/".to_string(),
            );
        }

        if !policy
            .kill_switch
            .state_dir
            .starts_with(".harmony/capabilities/_ops/state/")
        {
            semantic_errors.push(
                "kill_switch.state_dir must remain under .harmony/capabilities/_ops/state/".to_string(),
            );
        }

        if policy.grants.max_ttl_seconds_by_tier.low < policy.grants.max_ttl_seconds_by_tier.medium
            || policy.grants.max_ttl_seconds_by_tier.medium < policy.grants.max_ttl_seconds_by_tier.high
        {
            semantic_errors.push(
                "max_ttl_seconds_by_tier must satisfy low >= medium >= high".to_string(),
            );
        }

        for (profile_id, profile) in &policy.profiles {
            if profile
                .write_scope_bundle
                .iter()
                .any(|scope| scope.contains("**"))
            {
                warnings.push(format!(
                    "profile '{profile_id}' includes broad write scope; prefer explicit subpaths"
                ));
            }
        }

        if let Some(reason_codes_path) = &request.reason_codes_path {
            let known_codes = load_reason_codes(reason_codes_path)?;
            for (profile_id, profile) in &policy.profiles {
                for code in &profile.deny_rules {
                    if !known_codes.contains(code) {
                        semantic_errors.push(format!(
                            "profile '{profile_id}' references unknown reason code '{code}'"
                        ));
                    }
                }
            }
        }

    }

    let valid = schema_errors.is_empty() && semantic_errors.is_empty();
    Ok(DoctorReport {
        valid,
        schema_errors,
        semantic_errors,
        warnings,
    })
}

fn evaluate_service_preflight(
    policy: &PolicyV2,
    request: &PreflightRequest,
    artifact: &ArtifactContext,
    exceptions: &[ExceptionLease],
    today: &str,
) -> Decision {
    if artifact.status != "active" {
        return allow(
            "hard-enforce",
            vec![format!(
                "non-active service status='{}'; policy checks skipped",
                artifact.status
            )],
        );
    }

    if artifact.allowed_tools.is_empty() {
        return deny(
            "hard-enforce",
            "DDB003_UNKNOWN_TOOL_TOKEN",
            "Service has empty or missing allowed-tools",
            "service",
            &request.target_id,
            None,
            None,
            "Declare allowed-tools with scoped permissions",
            None,
        );
    }

    for token in &artifact.allowed_tools {
        if token == "Bash" || token == "Shell" {
            return deny(
                "hard-enforce",
                "DDB004_UNSCOPED_BASH",
                "Unscoped command permission is not allowed for active service",
                "service",
                &request.target_id,
                None,
                Some(token.clone()),
                "Replace with Bash(<scoped-command>)",
                None,
            );
        }

        if token == "Write" {
            return deny(
                "hard-enforce",
                "DDB005_UNSCOPED_WRITE",
                "Unscoped write permission is not allowed for active service",
                "service",
                &request.target_id,
                None,
                Some(token.clone()),
                "Replace with Write(<scoped-path>)",
                None,
            );
        }

        if policy.defaults.deny_unknown_tokens && !is_known_tool_token(token) {
            return deny(
                "hard-enforce",
                "DDB003_UNKNOWN_TOOL_TOKEN",
                "Unknown allowed-tools token",
                "service",
                &request.target_id,
                None,
                Some(token.clone()),
                "Use only approved tool tokens",
                None,
            );
        }
    }

    if artifact.has_broad_write {
        match check_active_exception(exceptions, "service", &request.target_id, "broad_write_scope", today) {
            ExceptionState::Active => {}
            ExceptionState::Missing => {
                return deny(
                    "hard-enforce",
                    "DDB009_EXCEPTION_MISSING",
                    "Broad write scope requires active exception lease",
                    "service",
                    &request.target_id,
                    None,
                    None,
                    "Add temporary exception lease or narrow Write scope",
                    None,
                )
            }
            ExceptionState::Expired => {
                return deny(
                    "hard-enforce",
                    "DDB010_EXCEPTION_EXPIRED",
                    "Broad write scope exception has expired",
                    "service",
                    &request.target_id,
                    None,
                    None,
                    "Renew exception lease or narrow Write scope",
                    None,
                )
            }
        }
    }

    if artifact
        .interface_type
        .as_deref()
        .map(|value| value == "shell")
        .unwrap_or(false)
        && artifact.bash_scopes.is_empty()
    {
        return deny(
            "hard-enforce",
            "DDB006_BASH_SCOPE_MISSING",
            "Active shell service requires at least one Bash(<scope>) token",
            "service",
            &request.target_id,
            None,
            None,
            "Add a scoped Bash token to allowed-tools",
            None,
        );
    }

    let fail_closed = artifact.fail_closed.as_deref().map(str::to_lowercase);
    match fail_closed.as_deref() {
        Some("true") => {}
        Some("false") => {
            match check_active_exception(
                exceptions,
                "service",
                &request.target_id,
                "fail_closed_false",
                today,
            ) {
                ExceptionState::Active => {}
                ExceptionState::Missing => {
                    return deny(
                        "hard-enforce",
                        "DDB011_FAIL_CLOSED_FALSE_REQUIRES_EXCEPTION",
                        "policy.fail_closed=false requires active exception lease",
                        "service",
                        &request.target_id,
                        None,
                        None,
                        "Restore fail_closed=true or add temporary lease",
                        None,
                    )
                }
                ExceptionState::Expired => {
                    return deny(
                        "hard-enforce",
                        "DDB010_EXCEPTION_EXPIRED",
                        "policy.fail_closed=false exception lease is expired",
                        "service",
                        &request.target_id,
                        None,
                        None,
                        "Renew lease or set fail_closed=true",
                        None,
                    )
                }
            }
        }
        _ => {
            return deny(
                "hard-enforce",
                "DDB002_POLICY_INVALID",
                "Service missing or invalid policy.fail_closed setting",
                "service",
                &request.target_id,
                None,
                None,
                "Set policy.fail_closed to true or false in SERVICE.md",
                None,
            )
        }
    }

    allow("hard-enforce", vec!["service-preflight-pass".to_string()])
}

fn evaluate_skill_preflight(
    _policy: &PolicyV2,
    request: &PreflightRequest,
    artifact: &ArtifactContext,
    exceptions: &[ExceptionLease],
    today: &str,
) -> Decision {
    if artifact.status != "active" {
        return allow(
            "hard-enforce",
            vec![format!(
                "non-active skill status='{}'; policy checks skipped",
                artifact.status
            )],
        );
    }

    if artifact.allowed_tools.is_empty() {
        return deny(
            "hard-enforce",
            "DDB003_UNKNOWN_TOOL_TOKEN",
            "Skill has empty or missing allowed-tools",
            "skill",
            &request.target_id,
            None,
            None,
            "Declare allowed-tools with scoped permissions",
            None,
        );
    }

    for token in &artifact.allowed_tools {
        if token == "Bash" || token == "Shell" {
            return deny(
                "hard-enforce",
                "DDB004_UNSCOPED_BASH",
                "Unscoped command permission is not allowed for active skill",
                "skill",
                &request.target_id,
                None,
                Some(token.clone()),
                "Replace with Bash(<scoped-command>)",
                None,
            );
        }

        if token == "Write" {
            return deny(
                "hard-enforce",
                "DDB005_UNSCOPED_WRITE",
                "Unscoped write permission is not allowed for active skill",
                "skill",
                &request.target_id,
                None,
                Some(token.clone()),
                "Replace with Write(<scoped-path>)",
                None,
            );
        }

        if !is_known_tool_token(token) {
            return deny(
                "hard-enforce",
                "DDB003_UNKNOWN_TOOL_TOKEN",
                "Unknown allowed-tools token",
                "skill",
                &request.target_id,
                None,
                Some(token.clone()),
                "Use only approved tool tokens",
                None,
            );
        }
    }

    if artifact.has_broad_write {
        match check_active_exception(exceptions, "skill", &request.target_id, "broad_write_scope", today) {
            ExceptionState::Active => {}
            ExceptionState::Missing => {
                return deny(
                    "hard-enforce",
                    "DDB009_EXCEPTION_MISSING",
                    "Broad write scope requires active exception lease",
                    "skill",
                    &request.target_id,
                    None,
                    None,
                    "Add temporary exception lease or narrow Write scope",
                    None,
                )
            }
            ExceptionState::Expired => {
                return deny(
                    "hard-enforce",
                    "DDB010_EXCEPTION_EXPIRED",
                    "Broad write scope exception has expired",
                    "skill",
                    &request.target_id,
                    None,
                    None,
                    "Renew exception lease or narrow Write scope",
                    None,
                )
            }
        }
    }

    allow("hard-enforce", vec!["skill-preflight-pass".to_string()])
}

fn evaluate_agent_only(policy: &PolicyV2, request: &EnforceRequest, today: &str) -> Result<Decision> {
    if !policy.agent_only.enabled {
        return Ok(deny(
            "hard-enforce",
            "DDB012_AGENT_ONLY_POLICY_DISABLED",
            "Agent-only policy is disabled",
            "service",
            &request.preflight.target_id,
            None,
            None,
            "Set agent_only.enabled=true in deny-by-default.v2 policy",
            Some(request.risk_tier.clone()),
        ));
    }

    let risk_tier = request.risk_tier.to_lowercase();
    let tier = match risk_tier.as_str() {
        "low" => &policy.agent_only.risk_tiers.low,
        "medium" => &policy.agent_only.risk_tiers.medium,
        "high" => &policy.agent_only.risk_tiers.high,
        _ => {
            return Ok(deny(
                "hard-enforce",
                "DDB012_AGENT_ONLY_POLICY_DISABLED",
                "Invalid risk tier",
                "service",
                &request.preflight.target_id,
                None,
                None,
                "Use low, medium, or high risk tier",
                Some(request.risk_tier.clone()),
            ))
        }
    };

    let scope_keys = {
        let mut keys = vec!["global".to_string(), format!("service:{}", request.preflight.target_id)];
        if let Some(category) = &request.category {
            keys.push(format!("category:{category}"));
        }
        keys
    };

    if is_kill_switch_active(policy, &scope_keys, today)? {
        return Ok(deny(
            "hard-enforce",
            "DDB019_KILL_SWITCH_ACTIVE",
            "Matching kill-switch is active for requested scope",
            "service",
            &request.preflight.target_id,
            None,
            None,
            "Clear or expire kill-switch record for this scope",
            Some(request.risk_tier.clone()),
        ));
    }

    let agent_id = match request.agent_id.as_deref() {
        Some(value) if !value.trim().is_empty() => value.trim().to_string(),
        _ => {
            return Ok(deny(
                "hard-enforce",
                "DDB013_AGENT_ID_MISSING",
                "Agent-only mode requires HARMONY_AGENT_ID",
                "service",
                &request.preflight.target_id,
                None,
                None,
                "Set HARMONY_AGENT_ID",
                Some(request.risk_tier.clone()),
            ))
        }
    };

    let ids_csv = request
        .agent_ids_csv
        .as_deref()
        .unwrap_or(agent_id.as_str())
        .to_string();
    let distinct = count_distinct_ids(&ids_csv);
    if distinct < tier.min_distinct_agents {
        return Ok(deny(
            "hard-enforce",
            "DDB014_DISTINCT_AGENT_QUORUM_NOT_MET",
            "Distinct agent quorum not met",
            "service",
            &request.preflight.target_id,
            None,
            None,
            "Provide additional distinct agent ids in HARMONY_AGENT_IDS",
            Some(request.risk_tier.clone()),
        ));
    }

    if tier.require_review {
        let reviewer = match request.review_agent_id.as_deref() {
            Some(value) if !value.trim().is_empty() => value.trim().to_string(),
            _ => {
                return Ok(deny(
                    "hard-enforce",
                    "DDB015_REVIEW_AGENT_REQUIRED",
                    "Risk tier requires review agent",
                    "service",
                    &request.preflight.target_id,
                    None,
                    None,
                    "Set HARMONY_REVIEW_AGENT_ID",
                    Some(request.risk_tier.clone()),
                ))
            }
        };

        if reviewer == agent_id {
            return Ok(deny(
                "hard-enforce",
                "DDB016_REVIEWER_NOT_DISTINCT",
                "Reviewer must differ from acting agent",
                "service",
                &request.preflight.target_id,
                None,
                None,
                "Use distinct reviewer identity",
                Some(request.risk_tier.clone()),
            ));
        }
    }

    if tier.require_quorum_token && request.quorum_token.as_deref().unwrap_or_default().trim().is_empty() {
        return Ok(deny(
            "hard-enforce",
            "DDB017_QUORUM_TOKEN_REQUIRED",
            "Risk tier requires quorum token",
            "service",
            &request.preflight.target_id,
            None,
            None,
            "Set HARMONY_QUORUM_TOKEN",
            Some(request.risk_tier.clone()),
        ));
    }

    if tier.require_rollback_plan
        && request
            .rollback_plan_id
            .as_deref()
            .unwrap_or_default()
            .trim()
            .is_empty()
    {
        return Ok(deny(
            "hard-enforce",
            "DDB018_ROLLBACK_PLAN_REQUIRED",
            "Risk tier requires rollback plan id",
            "service",
            &request.preflight.target_id,
            None,
            None,
            "Set HARMONY_ROLLBACK_PLAN_ID",
            Some(request.risk_tier.clone()),
        ));
    }

    Ok(allow(
        "hard-enforce",
        vec![format!("agent-only-pass:tier={risk_tier}:distinct={distinct}")],
    ))
}

fn is_kill_switch_active(policy: &PolicyV2, scope_keys: &[String], today: &str) -> Result<bool> {
    let state_dir = PathBuf::from(&policy.kill_switch.state_dir);
    if !state_dir.exists() {
        return Ok(false);
    }

    for entry in fs::read_dir(&state_dir)
        .with_context(|| format!("failed to read kill-switch directory {}", state_dir.display()))?
    {
        let entry = entry?;
        let path = entry.path();
        if !path.is_file() {
            continue;
        }

        let ext = path
            .extension()
            .and_then(|value| value.to_str())
            .unwrap_or_default();
        if ext != "yml" && ext != "yaml" && ext != "json" {
            continue;
        }

        let record: KillSwitchRecord = load_yaml(&path)
            .with_context(|| format!("failed to parse kill-switch record {}", path.display()))?;

        let state = record.state.as_deref().unwrap_or("active").to_lowercase();
        if state != "active" {
            continue;
        }

        if !scope_keys.iter().any(|key| key == &record.scope) {
            continue;
        }

        let expires = record.expires.as_deref().unwrap_or("");
        if expires.is_empty() {
            return Ok(true);
        }
        if !is_valid_date(expires) {
            return Ok(true);
        }
        if expires >= today {
            return Ok(true);
        }
    }

    Ok(false)
}

fn apply_mode(mode: &str, decision: &mut Decision) {
    let normalized = mode.to_lowercase();
    decision.mode = normalized.clone();

    if decision.allow {
        return;
    }

    let Some(deny) = decision.deny.as_ref() else {
        return;
    };

    match normalized.as_str() {
        "shadow" => {
            decision.allow = true;
            decision.shadow_deny = true;
            decision
                .notes
                .push(format!("shadow-mode: would deny with {}", deny.code));
        }
        "soft-enforce" => {
            if !is_critical_code(&deny.code) {
                decision.allow = true;
                decision.shadow_deny = true;
                decision
                    .notes
                    .push(format!("soft-enforce: non-critical deny converted to warning ({})", deny.code));
            }
        }
        _ => {}
    }
}

fn is_critical_code(code: &str) -> bool {
    matches!(
        code,
        "DDB001_POLICY_FILE_MISSING"
            | "DDB002_POLICY_INVALID"
            | "DDB019_KILL_SWITCH_ACTIVE"
            | "DDB025_RUNTIME_DECISION_ENGINE_ERROR"
    )
}

fn allow(mode: &str, notes: Vec<String>) -> Decision {
    Decision {
        allow: true,
        mode: mode.to_string(),
        shadow_deny: false,
        deny: None,
        notes,
    }
}

fn deny(
    mode: &str,
    code: &str,
    message: &str,
    scope: &str,
    target: &str,
    missing_scope: Option<String>,
    expected_token: Option<String>,
    remediation_hint: &str,
    risk_tier: Option<String>,
) -> Decision {
    Decision {
        allow: false,
        mode: mode.to_string(),
        shadow_deny: false,
        deny: Some(make_deny(
            code,
            message,
            scope,
            target,
            missing_scope,
            expected_token,
            remediation_hint,
            risk_tier,
        )),
        notes: Vec::new(),
    }
}

fn make_deny(
    code: &str,
    message: &str,
    scope: &str,
    target: &str,
    missing_scope: Option<String>,
    expected_token: Option<String>,
    remediation_hint: &str,
    risk_tier: Option<String>,
) -> DenyPayload {
    DenyPayload {
        code: code.to_string(),
        message: message.to_string(),
        scope: scope.to_string(),
        target: target.to_string(),
        missing_scope,
        expected_token,
        remediation_hint: remediation_hint.to_string(),
        risk_tier,
    }
}

fn load_artifact_context(request: &PreflightRequest) -> Result<ArtifactContext> {
    let contents = fs::read_to_string(&request.artifact_path).with_context(|| {
        format!(
            "failed to read artifact {}",
            request.artifact_path.display()
        )
    })?;

    let raw_allowed = extract_key_line_value(&contents, "allowed-tools").unwrap_or_default();
    let allowed_tools = split_allowed_tools(&raw_allowed);
    let bash_scopes = allowed_tools
        .iter()
        .filter_map(|token| bash_scope_from_token(token))
        .collect::<Vec<_>>();
    let has_broad_write = allowed_tools
        .iter()
        .filter_map(|token| write_scope_from_token(token))
        .any(|scope| scope.contains("**"));

    let fail_closed = parse_frontmatter_value(&contents, "fail_closed");

    match request.kind {
        ScopeKind::Service => {
            let manifest: ServicesManifest = load_yaml(&request.manifest_path)?;
            let entry = manifest
                .services
                .into_iter()
                .find(|service| service.id == request.target_id)
                .ok_or_else(|| {
                    anyhow!(
                        "service '{}' not found in manifest {}",
                        request.target_id,
                        request.manifest_path.display()
                    )
                })?;

            Ok(ArtifactContext {
                status: entry.status,
                interface_type: entry.interface_type,
                allowed_tools,
                fail_closed,
                bash_scopes,
                has_broad_write,
            })
        }
        ScopeKind::Skill => {
            let manifest: SkillsManifest = load_yaml(&request.manifest_path)?;
            let entry = manifest
                .skills
                .into_iter()
                .find(|skill| skill.id == request.target_id)
                .ok_or_else(|| {
                    anyhow!(
                        "skill '{}' not found in manifest {}",
                        request.target_id,
                        request.manifest_path.display()
                    )
                })?;

            Ok(ArtifactContext {
                status: entry.status,
                interface_type: None,
                allowed_tools,
                fail_closed,
                bash_scopes,
                has_broad_write,
            })
        }
    }
}

fn extract_key_line_value(contents: &str, key: &str) -> Option<String> {
    let prefix = format!("{key}:");
    for line in contents.lines() {
        let trimmed = line.trim();
        if let Some(rest) = trimmed.strip_prefix(&prefix) {
            return Some(rest.trim().trim_matches('"').trim_matches('\'').to_string());
        }
    }
    None
}

fn parse_frontmatter_value(contents: &str, key: &str) -> Option<String> {
    let mut in_frontmatter = false;
    let mut delimiter_count = 0;

    for line in contents.lines() {
        let trimmed = line.trim();
        if trimmed == "---" {
            delimiter_count += 1;
            if delimiter_count == 1 {
                in_frontmatter = true;
                continue;
            }
            if delimiter_count == 2 {
                break;
            }
        }

        if in_frontmatter {
            let prefix = format!("{key}:");
            if let Some(rest) = trimmed.strip_prefix(&prefix) {
                return Some(rest.trim().trim_matches('"').trim_matches('\'').to_string());
            }
        }
    }

    None
}

fn matches_bash_scope(scope: &str, command: &str) -> bool {
    if scope == "bash" {
        return command.starts_with("bash ") || command == "bash";
    }

    if let Ok(pattern) = Pattern::new(scope) {
        return pattern.matches(command);
    }

    scope == command
}

#[derive(Debug, Clone, PartialEq, Eq)]
enum ExceptionState {
    Active,
    Missing,
    Expired,
}

fn check_active_exception(
    exceptions: &[ExceptionLease],
    scope: &str,
    target: &str,
    rule: &str,
    today: &str,
) -> ExceptionState {
    let matching = exceptions.iter().find(|lease| {
        lease.scope == scope && lease.target == target && lease.rule == rule
    });

    let Some(lease) = matching else {
        return ExceptionState::Missing;
    };

    let expires = lease.expires.as_deref().unwrap_or("");
    if !is_valid_date(expires) {
        return ExceptionState::Expired;
    }
    if expires < today {
        return ExceptionState::Expired;
    }
    ExceptionState::Active
}

fn is_valid_date(value: &str) -> bool {
    if value.len() != 10 {
        return false;
    }
    let bytes = value.as_bytes();
    for (idx, byte) in bytes.iter().enumerate() {
        match idx {
            4 | 7 => {
                if *byte != b'-' {
                    return false;
                }
            }
            _ => {
                if !byte.is_ascii_digit() {
                    return false;
                }
            }
        }
    }
    true
}

pub fn load_exceptions(path: &Path) -> Result<Vec<ExceptionLease>> {
    if !path.exists() {
        return Ok(Vec::new());
    }

    let file: ExceptionLeaseFile = load_yaml(path)?;
    Ok(file.exceptions)
}

pub fn count_distinct_ids(csv: &str) -> usize {
    let mut set = BTreeSet::new();
    for part in csv.split(',') {
        let value = part.trim();
        if !value.is_empty() {
            set.insert(value.to_string());
        }
    }
    set.len()
}

pub fn load_reason_codes(path: &Path) -> Result<HashSet<String>> {
    let text = fs::read_to_string(path)
        .with_context(|| format!("failed to read reason codes {}", path.display()))?;

    let mut set = HashSet::new();
    for raw in text.split(|ch: char| !ch.is_ascii_alphanumeric() && ch != '_') {
        if raw.starts_with("DDB") && raw.contains('_') {
            set.insert(raw.to_string());
        }
    }

    Ok(set)
}

fn load_json_value(path: &Path) -> Result<Value> {
    let text = fs::read_to_string(path)
        .with_context(|| format!("failed to read JSON file {}", path.display()))?;
    Ok(serde_json::from_str(&text)
        .with_context(|| format!("failed to parse JSON file {}", path.display()))?)
}

fn load_yaml_value(path: &Path) -> Result<Value> {
    let text = fs::read_to_string(path)
        .with_context(|| format!("failed to read YAML file {}", path.display()))?;
    Ok(serde_yaml::from_str(&text)
        .with_context(|| format!("failed to parse YAML file {}", path.display()))?)
}

fn load_yaml<T>(path: &Path) -> Result<T>
where
    T: DeserializeOwned,
{
    let text = fs::read_to_string(path)
        .with_context(|| format!("failed to read YAML file {}", path.display()))?;
    Ok(serde_yaml::from_str(&text)
        .with_context(|| format!("failed to parse YAML file {}", path.display()))?)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn split_allowed_tools_respects_parentheses_depth() {
        let raw = "Read Bash(git diff --name-only) Write(.harmony/output/**) Bash(rg deny-by-default)";
        let tokens = split_allowed_tools(raw);
        assert_eq!(
            tokens,
            vec![
                "Read",
                "Bash(git diff --name-only)",
                "Write(.harmony/output/**)",
                "Bash(rg deny-by-default)",
            ]
        );
    }

    #[test]
    fn distinct_agent_count_deduplicates_values() {
        assert_eq!(count_distinct_ids("a,b,a, c"), 3);
    }

    #[test]
    fn bash_scope_match_supports_glob_patterns() {
        assert!(matches_bash_scope("bash execution/agent/impl/agent.sh *", "bash execution/agent/impl/agent.sh --help"));
        assert!(!matches_bash_scope(
            "bash execution/agent/impl/agent.sh *",
            "bash execution/guard/impl/guard.sh"
        ));
    }
}
